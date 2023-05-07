// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Escrow is Ownable, ReentrancyGuard {
    using Address for address payable;

    uint256 public serviceFee = 7;

    struct Payment {
        uint256 amount;
        address sender;
        address receiver;
        address token;
        uint256 timestamp;
        bool cancelled;
    }

    mapping(bytes20 => Payment) public payments;

    event PaymentCreated(bytes20 indexed paymentId);
    event PaymentCancelled(bytes20 indexed paymentId);
    event PaymentReleased(bytes20 indexed paymentId);

    function createPayment(
        bytes20 paymentId,
        address receiver,
        address token,
        uint256 amount
    ) external payable {
        require(payments[paymentId].amount == 0, "Payment already exists");
        require(receiver != address(0), "Invalid receiver address");
        require(address(this).balance >= amount, "Insufficient balance");

        if (token != address(0)) {
            require(
                IERC20(token).allowance(msg.sender, address(this)) >= amount,
                "Insufficient allowance"
            );
            require(
                IERC20(token).transferFrom(msg.sender, address(this), amount),
                "Token transfer failed"
            );
        } else {
            require(msg.value == amount, "Incorrect ETH amount");
        }

        Payment storage payment = payments[paymentId];
        payment.amount = amount;
        payment.sender = msg.sender;
        payment.receiver = receiver;
        payment.token = token;
        payment.timestamp = block.timestamp;

        emit PaymentCreated(paymentId);
    }

    function cancelPayment(bytes20 paymentId) external {
        Payment storage payment = payments[paymentId];
        require(payment.amount != 0, "Payment does not exist");
        require(payment.sender == msg.sender, "Not authorized to cancel");
        require(!payment.cancelled, "Payment already cancelled");

        payment.cancelled = true;
        payable(payment.sender).sendValue(payment.amount);

        emit PaymentCancelled(paymentId);
    }

    function releasePayment(bytes20 paymentId) external onlyOwner {
        Payment storage payment = payments[paymentId];
        require(payment.amount != 0, "Payment does not exist");
        require(!payment.cancelled, "Payment already cancelled");
        require(
            block.timestamp >= payment.timestamp + (5 minutes),
            "Release time not reached"
        );

        uint256 amountMinusFee = (payment.amount * (100 - serviceFee)) / 100;
        payable(payment.receiver).sendValue(amountMinusFee);
        payable(owner()).sendValue(payment.amount - amountMinusFee);

        emit PaymentReleased(paymentId);
    }

    function setServiceFee(uint256 _serviceFee) external onlyOwner {
        require(_serviceFee <= 10, "Service fee must be <= 10%");
        serviceFee = _serviceFee;
    }
}