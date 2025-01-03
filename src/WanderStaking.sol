// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

contract WanderStaking is Ownable, Pausable {
    using SafeERC20 for IERC20;
    IERC20 public immutable token;

    event Stake(address indexed user, uint256 amount);
    event Unstake(address indexed user, uint256 amount);

    error ZeroAmount();
    error InsufficientBalance();

    mapping(address => uint256) userStake;
    uint256 internal totalStaked;

    constructor(address initialOwner, IERC20 _token)
        Ownable(initialOwner)
    {
        token = _token;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner() {
        _unpause();
    }

    function stake(uint256 amount) external whenNotPaused {
        if (amount == 0) {
            revert ZeroAmount();
        }

        userStake[msg.sender] += amount;
        totalStaked += amount;

        emit Stake(msg.sender, amount);

        token.safeTransferFrom(msg.sender, address(this), amount);
    }

    function unstake(uint256 amount) external whenNotPaused {
        if (amount == 0) {
            revert ZeroAmount();
        }

        if (userStake[msg.sender] < amount) {
            revert InsufficientBalance();
        }

        userStake[msg.sender] -= amount;
        totalStaked -= amount;

        emit Unstake(msg.sender, amount);

        token.safeTransfer(msg.sender, amount);
    }

    function getTotalStaked() external view returns (uint256) {
        return totalStaked;
    }

    function getAmountStaked(address user) external view returns (uint256) {
        return userStake[user];
    }
}
