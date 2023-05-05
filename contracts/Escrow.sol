// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract Escrow is ReentrancyGuard{
    using SafeMath for uint256;

    address public escrowAddr;
    uint256 escrowFee;
    uint256 escrowBal;
    uint256 totalTxn;
    uint256 totalConfirmedTxn; 
    uint256 duration;

    enum Status {
        PAYMENT_SENT,
        VALIDATING,
        PATMENT_CLAIMED,
        REFUND
        
    }

    struct TxnStatus {
        uint256 txnId;
        uint256 amount;
        uint256 timeStamp;
        address sender;
        string purpose;
        Status status;
    }

    mapping (address => TxnStatus) addrToTxn;
    mapping (address => TxnStatus[]) txnOf;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public etherBalances;
    mapping(address => mapping(address => uint256)) public releaseTimes;
    mapping(address => mapping(address => uint256)) public tokenBalances;

    
    event Deposit(address indexed depositor, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);
    event TokenWithdrawn(address , address _token, uint256 amount);



    constructor (uint256 _escrowFee) {
        escrowAddr = msg.sender;
        escrowFee = _escrowFee;
    }

    modifier onlyOwner {
    require(msg.sender == escrowAddr, "Only Owner can call this fuunction"); 
    _;
   }

   modifier Duration{
    require(block.timestamp + 5 minutes == duration, "cant perform this action now");
    _;
   }

    // function sendToken (address from, address to, uint256 _amount ) internal{
    //     require(to != address(0), "to address can't be address zero");
    //     TxnStatus memory _status = addrToTxn[from];
    //     _status.txnId = txnId++;
    //     checkToAddress(to);

    // }

    // function sendEth () internal{

    // }

    function checkToAddress(address _to) internal pure {
        // return (bytes(address(_to)).length == 20);
        // return (_to != address(0) && uint256(_to) &gt &gt, 96 == 0);
        require(_to != address(0), "Receiver address cannot be zero.");
        require(bytes20(_to) == bytes20(_to), "Invalid receiver address length.");
    }
    

    function sendFunds (address _token, address payable to_ ) external payable{
        // IERC20 token = IERC20(_token);
        require(to_ != address(0), "to address can't be address zero");
        require(to_ != address(0), "Invalid beneficiary address");
        require(to_ != msg.sender, "Sender cannot be beneficiary");
        checkToAddress(to_);
        if (_token == address(0)) {
            require(msg.value > 0, "Deposit amount must be greater than zero");
            balances[to_] += msg.value;
            emit Deposit(msg.sender, msg.value);
        } else {
            uint256 amount = IERC20(_token).balanceOf(msg.sender);
            require(amount > 0, "Insufficient token balance");
            require(IERC20(_token).transferFrom(msg.sender, address(this), amount), "Token transfer failed");
            balances[to_] += amount;
            emit Deposit(msg.sender, amount);
        }
        

    }

    function claimFunds (address _token) external nonReentrant {
        if(_token == address(0)){
        require(tokenBalances[msg.sender][_token] > 0, "No token balance to withdraw.");
        require(block.timestamp >= releaseTimes[msg.sender][_token], "Release time not reached.");
        uint256 amount = tokenBalances[msg.sender][_token];
        tokenBalances[msg.sender][_token] = 0;
        IERC20(_token).transfer(msg.sender, amount);
        emit TokenWithdrawn(msg.sender, _token, amount);
    

        } else {
        require(etherBalances[msg.sender] > 0, "No Ether balance to withdraw.");
        require(block.timestamp >= releaseTimes[msg.sender], "Release time not reached.");
        uint256 amount = etherBalances[msg.sender];
        etherBalances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit EtherWithdrawn(msg.sender, amount);
        }
        
    }

    function cancelTxn (address payable _to) external {
        require(msg.sender == owner, "Only the contract owner can cancel a transaction");
        require(balances[_to] > 0, "No funds available for cancellation");
        balances[_to] = 0;
        emit Withdrawal(_to, balances[_to]);

    }

    function withdraw () external onlyOwner {

    }



}