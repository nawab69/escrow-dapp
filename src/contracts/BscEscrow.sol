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
    
    enum Coin {ETH, BUSD}
    
    struct trade {
        address payee;
        address payeer;
        uint256 amount;
        bool complete;
        Coin coin;
    }
    
    mapping( uint256 => trade)  public trades;
    
    
    constructor(IERC20 _token) public {
        agent = msg.sender;
        busd = IERC20(_token);
    }
    
    modifier onlyAgent(){
        require(msg.sender == agent);
        _;
    }
    
    function updateFee(uint fee) public onlyAgent {
        feeInPercent = fee;
    }
    
   
    
    function escrowFee(uint256 amount) private view returns(uint256) {
        uint256 x = amount.mul(feeInPercent) ;
        uint256 adminFee = x.div(100);
        return adminFee;
    }
    
    
    
    function deposit(address payee) public payable {
        tradeCount++;
        trades[tradeCount].payee = payee;
        trades[tradeCount].payeer = msg.sender;
        trades[tradeCount].amount = msg.value;
        trades[tradeCount].complete = false;
        trades[tradeCount].coin = Coin.ETH;
    }
    
    function depositBusd(address payee,uint256 amount) public {
        tradeCount++;
        trades[tradeCount].payee = payee;
        trades[tradeCount].payeer = msg.sender;
        trades[tradeCount].amount = amount;
        trades[tradeCount].complete = false;
        trades[tradeCount].coin = Coin.BUSD;
        address owner = msg.sender;
        uint allowed = busd.allowance(owner, address(this));
        require(allowed >= amount, 'Contract is not approved, please approved first');
        busd.transferFrom(owner,address(this),amount);
        
    }
    
    
    
    
    function withdraw(uint256 id) public {
        
        require(!trades[id].complete);
        require(trades[id].payeer == msg.sender);
        address payable  payee = address(uint160(trades[id].payee));
        address  payable admin = address(uint160(agent));
        uint fee = escrowFee(trades[id].amount);
        uint amount = trades[id].amount - fee;
        if(trades[tradeCount].coin == Coin.ETH){
            payee.transfer(amount);
            admin.transfer(fee);
        }else if(trades[tradeCount].coin == Coin.BUSD){
            busd.transfer(payee,amount);
            busd.transfer(admin,fee);
        }
        
        trades[id].complete = true;
        
    }
    
    
    
    function withdrawFromAgent(uint256 id) public onlyAgent{
        require(!trades[id].complete);
        address payable payee = address(uint160(trades[id].payee));
        address payable  admin = address(uint160(agent));
        uint amount = trades[id].amount - escrowFee(trades[id].amount);
        payee.transfer(amount);
        admin.transfer(escrowFee(trades[id].amount));
        trades[id].complete = true;
    }
    
    function cancel(uint256 id) public {
        require(!trades[id].complete);
        require(trades[id].payee == msg.sender || agent == msg.sender);
        address payable payeer = address(uint160(trades[id].payeer));
        payeer.transfer(trades[id].amount);
        trades[id].complete = true;
    }
    
    
     function changeAgent(address _agent) public onlyAgent {
         agent = _agent;
     }
     
     
    
    
}