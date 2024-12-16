//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// Compatible with OpenZeppelin Contracts ^5.0.0

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * A smart contract for an ERC20 token implementation with the Ownable pattern
 * It also allows the owner to mint new tokens
 * @author MarcelaWojtasik
 */

contract TokenA is ERC20, Ownable {
    // Constructor: Called once on contract deployment
    constructor(address initialOwner)
        ERC20("TokenA", "TkA")
        Ownable(initialOwner)
    {
        //Initial Ownership and Supply
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    //Minting Functionality: create new tokens and assign them to a specified address.
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

//Successfully verified contract TokenA on the block explorer.
//https://sepolia.etherscan.io/address/0xf3945912c8F996B67575C4aB937b21802c37BA42#code