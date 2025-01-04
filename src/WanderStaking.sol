// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract WanderStaking is Initializable, PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    using SafeERC20 for IERC20;

    event Stake(address indexed user, uint256 amount);
    event Unstake(address indexed user, uint256 amount);

    error ZeroAmount();
    error InsufficientBalance();

    IERC20 public token;
    uint256 internal totalStaked;
    mapping(address => uint256) userStake;

    // @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, IERC20 _token) public initializer {
        __Pausable_init();
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();

        token = _token;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

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
