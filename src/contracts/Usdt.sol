pragma solidity ^0.6.0;

import "../../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Usdt is ERC20 {
    constructor(uint256 initialSupply) public ERC20("USDT", "USDT") {
        _mint(msg.sender, initialSupply);
    }
}