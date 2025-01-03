// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {WanderStaking} from "../src/WanderStaking.sol";
import {TestToken} from "../src/TestToken.sol";

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract WanderStakingTest is Test {
    WanderStaking public staking;
    TestToken public token;

    function setUp() public {
        token = new TestToken();
        
        staking = new WanderStaking(address(this), IERC20(token));
        token.approve(address(staking), ~uint256(0));
    }

    function test_stake(uint64 _amount) public {
        vm.assume(_amount > 0);

        uint256 amount = uint256(_amount) * (10 ** 18);
        token.mint(address(this), amount);

        staking.stake(amount);

        assert(staking.getTotalStaked() == amount);
    }

    function test_stake_insufficient_balance(uint64 _amount) public {
        vm.assume(_amount > 0);
        uint256 amount = uint256(_amount) * (10 ** 18);

        token.mint(address(this), amount);

        vm.expectRevert();
        staking.stake(amount * 2);
    }

    function test_unstake(uint64 _amount, uint64 _unstakeAmount) public {
        vm.assume(_amount > 0);
        vm.assume(_unstakeAmount > 0);
        vm.assume(_amount >= _unstakeAmount);
        uint256 amount = uint256(_amount) * (10 ** 18);
        uint256 unstakeAmount = uint256(_unstakeAmount) * (10 ** 18);

        token.mint(address(this), amount);

        staking.stake(amount);
        staking.unstake(unstakeAmount);

        assert(staking.getTotalStaked() == (amount - unstakeAmount));
    }

    function test_unstake_over(uint64 _amount, uint64 _unstakeAmount) public {
        vm.assume(_amount > 0);
        vm.assume(_unstakeAmount > 0);
        vm.assume(_amount < _unstakeAmount);
        uint256 amount = uint256(_amount) * (10 ** 18);
        uint256 unstakeAmount = uint256(_unstakeAmount) * (10 ** 18);

        // Pad staking contract with some tokens first
        vm.startPrank(msg.sender);
            token.mint(msg.sender, amount * 2);
            token.approve(address(staking), ~uint256(0));
            staking.stake(amount * 2);
        vm.stopPrank();

        token.mint(address(this), amount);
        staking.stake(amount);

        vm.expectRevert(WanderStaking.InsufficientBalance.selector);
        staking.unstake(unstakeAmount);
    }

    function test_unstake_new(uint64 _unstakeAmount) public {
        vm.assume(_unstakeAmount > 0);
        uint256 unstakeAmount = uint256(_unstakeAmount) * (10 ** 18);

        vm.expectRevert();
        staking.unstake(unstakeAmount);
    }
}
