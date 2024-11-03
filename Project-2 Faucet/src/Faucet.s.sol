// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.13;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

event Deposit(address from, uint256 value);

contract EVT_Faucet {
    ERC20 public token;
    address public owner;
    uint256 public amountPerRequest = 50 * (10 ** 18); // Amount of EVT tokens to give per request
    mapping(address => uint256) public lastRequestTime;
    uint256 public requestCooldown = 1 seconds; // Cooldown period of 30 sec

    constructor(ERC20 _token) {
        token = _token;
        owner = payable(msg.sender); // Set the contract deployer as the owner
    }

    // Function to allow users to request tokens
    function requestTokens() external {
        require(msg.sender != address(0), "Invalid address");
        require(block.timestamp >= lastRequestTime[msg.sender] + requestCooldown, "Cooldown: Please wait before requesting again");
        require(token.balanceOf(address(this)) >= amountPerRequest, "Insufficient tokens in faucet");

        lastRequestTime[msg.sender] = block.timestamp; // Update last request time
        token.transfer(msg.sender, amountPerRequest); // Transfer tokens to the user
    }
     receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    // Function to fund the faucet
    // Only owner can fund it
    function fundFaucet(uint256 amount) external {
        require(msg.sender == owner, "Only the owner can fund the faucet");
        require(amount > 0, "Funding amount must be greater than zero");
        token.transferFrom(msg.sender, address(this), amount); // Transfer tokens to the faucet
    }

    // Function to check the current balance of the faucet contract in EVT
    function getCurrentBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    // Function to drain the faucet balance to the owner
    function drain() external {
        require(msg.sender == owner, "Only the owner can drain the faucet");
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to drain"); // Ensure there are tokens to drain
        token.transfer(owner, balance); // Transfer all tokens to the owner
    }


}