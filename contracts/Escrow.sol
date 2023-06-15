// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Escrow is Ownable, ReentrancyGuard {
    using Address for address;

    uint256 public baseFeePercentage;
    uint256 public feeMultiplier;
    // bytes32 public 

    struct Payment {
        uint256 id;
        uint256 amount;
        address sender;
        address receiver;
        address token;
        uint256 timestamp;
        bool cancelled;
    }

    struct trackReceiverAddress{
        address receiver;
        bytes32 pin;
    }

    struct trackReceiverAmount{
        address receiver;
        uint256 amount;
    }

    mapping(uint256 => Payment) public payments;
    mapping (address => trackReceiverAddress) private trackReceiverAddresses;
    mapping (bytes32 => trackReceiverAmount) private trackReceiverAmounts;
    uint256[] public paymentIds;

    event PaymentCreated(uint256 indexed paymentId);
    event PaymentCancelled(uint256 indexed paymentId);
    event PaymentReleased(uint256 indexed paymentId);

    constructor(uint256 _baseFeePercentage, uint256 _feeMultiplier) {
        require(_baseFeePercentage <= 10, "Base fee must be <= 2%");
        baseFeePercentage = _baseFeePercentage;
        feeMultiplier = _feeMultiplier;
    }

    function createPayment(address receiver, address token, uint256 amount) external payable {
        require(receiver != address(0), "Invalid receiver address");
        require(amount > 0, "Amount must be greater than zero");

        if (msg.value == 0) {
            require(msg.sender != receiver, "Cannot create payment to yourself");
        }

        uint256 newPaymentId = paymentIds.length;
        Payment storage payment = payments[newPaymentId];
        payment.id = newPaymentId;
        payment.amount = amount;
        payment.sender = msg.sender;
        payment.receiver = receiver;
        payment.token = token;
        payment.timestamp = block.timestamp;
        payment.cancelled = false;

        paymentIds.push(newPaymentId);

        emit PaymentCreated(newPaymentId);
    }

    function cancelPayment(uint256 paymentId) external nonReentrant {
        Payment storage payment = payments[paymentId];
        require(payment.amount != 0, "Payment does not exist");
        require(payment.sender == msg.sender, "Not authorized to cancel");
        require(!payment.cancelled, "Payment already cancelled");

        payment.cancelled = true;
        payable(payment.sender).transfer(payment.amount);

        emit PaymentCancelled(paymentId);
    }

    function releasePayment(uint256 paymentId) external onlyOwner nonReentrant {
        Payment storage payment = payments[paymentId];
        require(payment.amount != 0, "Payment does not exist");
        require(!payment.cancelled, "Payment already cancelled");
        require(
            block.timestamp >= payment.timestamp + (5 minutes),
            "Release time not reached"
        );

        uint256 feeAmount = calculateFee(payment.amount);
        uint256 amountMinusFee = payment.amount - feeAmount;

        payable(payment.receiver).transfer(amountMinusFee);
        payable(owner()).transfer(feeAmount);

        emit PaymentReleased(paymentId);
    }

    function calculateFee(uint256 amount) internal view returns (uint256) {
        return (amount * baseFeePercentage * feeMultiplier) / 10000;
    }

    function getLastPaymentId() public view returns (uint256) {
        require(paymentIds.length > 0, "No payment exists");
        return paymentIds[paymentIds.length - 1];
    }

    function generatePin () internal returns (bytes32){
        


    }
}
