// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {EVT_Faucet} from "../src/Faucet.s.sol";
import {ElevenToken} from "../src/Token.s.sol";

contract FaucetTest is Test {
    EVT_Faucet public faucet;
    ElevenToken public token;
    address user = address(0x1);
    address owner = address(this);

    function setUp() public {
        token = new ElevenToken();
        faucet = new EVT_Faucet(token);
        token.approve(address(faucet), 1000 * (10 ** 18));
        faucet.fundFaucet(1000 * (10 ** 18));
    }

  
    function testFaucetBalance() public view {
        uint256 balance = faucet.getCurrentBalance();
        assertEq(balance, 1000 * (10 ** 18), "Faucet balance mismatch.");
    }

    function testUserCanRequestTokens() public {
        vm.prank(user);
        faucet.requestTokens();
        uint256 userBalance = token.balanceOf(user);
        assertEq(userBalance, 50 * (10 ** 18), "User should receive 50 EVT tokens.");
    }

    function testRequestCooldown() public {
        vm.prank(user);
        faucet.requestTokens(); 
        
       
        vm.expectRevert("Cooldown: Please wait before requesting again");
        vm.prank(user);
        faucet.requestTokens();
    }

      function testOwnerCanFundFaucet() public {
        uint256 initialBalance = faucet.getCurrentBalance();
        token.approve(address(faucet), 500 * (10 ** 18));
        faucet.fundFaucet(500 * (10 ** 18));
        uint256 newBalance = faucet.getCurrentBalance();
        assertEq(newBalance, initialBalance + 500 * (10 ** 18), "Faucet balance should reflect the additional funding.");
    }

    function testOnlyOwnerCanFundFaucet() public {
        vm.prank(address(0x2)); // Non-owner address
        vm.expectRevert("Only the owner can fund the faucet");
        faucet.fundFaucet(50 * (10 ** 18));
    }

    function testFundFaucetWithZeroTokens() public {
        uint256 initialBalance = faucet.getCurrentBalance();
        
        // Expect revert when trying to fund with zero tokens
        vm.expectRevert("Funding amount must be greater than zero");
        faucet.fundFaucet(0);

        // Verify balance remains unchanged
        uint256 finalBalance = faucet.getCurrentBalance();
        assertEq(finalBalance, initialBalance, "Faucet balance should remain unchanged with zero funding.");
    }

    function testGetCurrentBalance() public {
        uint256 initialBalance = faucet.getCurrentBalance();
        assertEq(initialBalance, 1000 * (10 ** 18), "Initial balance should be 1000 EVT");
        token.approve(address(faucet), 200 * (10 ** 18));
        faucet.fundFaucet(200 * (10 ** 18));
        uint256 updatedBalance = faucet.getCurrentBalance();

        assertEq(updatedBalance, initialBalance + 200 * (10 ** 18), "Balance should reflect the additional 200 EVT funding.");
    }

    function testRequestFailsWhenFaucetBalanceLow() public {
        faucet.drain();

        vm.expectRevert("Insufficient tokens in faucet");
        faucet.requestTokens();
    }

    

}

