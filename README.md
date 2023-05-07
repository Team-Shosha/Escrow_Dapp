## About project

This is a Solidity smart contract for an escrow service. The contract allows two parties to make a payment to be held in escrow until certain conditions are met. The contract owner charges a service fee for providing the escrow service.

### The contract has the following features:

A createPayment function to create a new payment with a unique ID, an amount, a sender, a receiver, and an optional token address. If the token address is provided, the contract checks the sender has approved the contract to spend the token on their behalf and transfers the token from the sender to the contract. Otherwise, the contract checks that the amount of ETH sent by the sender matches the amount of the payment.
A cancelPayment function to cancel a payment if the sender is the one who created it and it has not already been cancelled.
A releasePayment function to release the payment to the receiver and deduct the service fee from the payment amount. The remaining amount is transferred to the receiver and the service fee is transferred to the contract owner.

The contract uses the OpenZeppelin Solidity library for ReentrancyGuard and Ownable. It also uses IERC20 interface for token transfers and SafeMath for mathematical operations.

### DEPLOYED ON POLYGON MUMBAI TESTNET:

[0x3078c32dCa9C4A7f51489f159Cc53e173e9eCE4c](https://mumbai.polygonscan.com/address/0x3078c32dCa9C4A7f51489f159Cc53e173e9eCE4c)
