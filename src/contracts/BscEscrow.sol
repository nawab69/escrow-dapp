pragma solidity ^0.6.0;

import "../../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/token/ERC20/IERC20.sol";

import "../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";


contract BscEscrow {
    
    using SafeMath for uint256;
    
    address public agent;
    
    uint256 public tradeCount = 0;
    
    uint public feeInPercent = 2;
    
    
    IERC20 private busd;
    
    enum Coin {BNB, BUSD}
    
    struct trade {
        address payee;
        address payeer;
        uint256 amount;
        bool complete;
        Coin coin;
    }
    
    mapping( string => trade)  public trades;
    
    
    constructor(IERC20 _token) public {
        agent = msg.sender;
        busd = IERC20(_token);
    }
    
    modifier onlyAgent(){
        require(msg.sender == agent);
        _;
    }

    event Deposited(string tradeId);
    event Withdrawed(string tradeId);
    event Cancelled(string tradeId);
    
    function updateFee(uint fee) public onlyAgent {
        feeInPercent = fee;
    }
    
   
    
    function escrowFee(uint256 amount) private view returns(uint256) {
        uint256 x = amount.mul(feeInPercent) ;
        uint256 adminFee = x.div(100);
        return adminFee;
    }
    
    
    
    function deposit(address payee, string memory tradeId) public payable {
        require(trades[tradeId].payee === address(0),'trade already exists');
        tradeCount++;
        trades[tradeId].payee = payee;
        trades[tradeId].payeer = msg.sender;
        trades[tradeId].amount = msg.value;
        trades[tradeId].complete = false;
        trades[tradeId].coin = Coin.BNB;
        emit Deposited(tradeId);
    }
    
    function depositBusd(address payee,uint256 amount,string memory tradeId) public {
        tradeCount++;
        trades[tradeId].payee = payee;
        trades[tradeId].payeer = msg.sender;
        trades[tradeId].amount = amount;
        trades[tradeId].complete = false;
        trades[tradeId].coin = Coin.BUSD;
        address owner = msg.sender;
        uint allowed = busd.allowance(owner, address(this));
        require(allowed >= amount, 'Contract is not approved, please approved first');
        busd.transferFrom(owner,address(this),amount);
        emit Deposited(tradeId);
    }
    
    
    
    
    function withdraw(string memory tradeId) public {
        require(!trades[tradeId].complete);
        require(trades[tradeId].payeer == msg.sender);
        address payable  payee = address(uint160(trades[tradeId].payee));
        address  payable admin = address(uint160(agent));
        uint fee = escrowFee(trades[tradeId].amount);
        uint amount = trades[tradeId].amount - fee;
        if(trades[tradeId].coin == Coin.BNB){
            payee.transfer(amount);
            admin.transfer(fee);
        }else if(trades[tradeId].coin == Coin.BUSD){
            busd.transfer(payee,amount);
            busd.transfer(admin,fee);
        }
        
        trades[tradeId].complete = true;
        
        emit Withdrawed(tradeId);
        
    }
    
    
    
    function withdrawFromAgent(string memory tradeId) public onlyAgent{
        require(!trades[tradeId].complete);
        address payable payee = address(uint160(trades[tradeId].payee));
        address payable  admin = address(uint160(agent));
        uint amount = trades[tradeId].amount - escrowFee(trades[tradeId].amount);
        payee.transfer(amount);
        admin.transfer(escrowFee(trades[tradeId].amount));
        trades[tradeId].complete = true;
        emit Withdrawed(tradeId);
    }
    
    function cancel(string memory tradeId) public {
        require(!trades[tradeId].complete,'Trade already completed');
        require(trades[tradeId].payee == msg.sender || agent == msg.sender,'You are not buyer or agent');
        address payable payeer = address(uint160(trades[tradeId].payeer));
        payeer.transfer(trades[tradeId].amount);
        trades[tradeId].complete = true;
        emit Cancelled(tradeId);
    }
    
    
     function changeAgent(address _agent) public onlyAgent {
         agent = _agent;
     }
     
     
    
    
}