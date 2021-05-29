pragma solidity ^0.6.0;

import "../../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Busd is ERC20 {
    constructor(uint256 initialSupply) public ERC20("BUSD", "BUSD") {
        _mint(msg.sender, initialSupply);
    }
}