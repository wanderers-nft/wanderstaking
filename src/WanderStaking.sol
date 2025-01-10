// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract WanderStaking is Initializable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    using SafeERC20 for IERC20;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    event Stake(address indexed user, uint256 amount);
    event Unstake(address indexed user, uint256 amount);
    event SpendFromStake(address indexed user, address indexed to, uint256 amount);

    error ZeroAmount();
    error InsufficientBalance();

    IERC20 public token;
    uint256 internal totalStaked;
    mapping(address => uint256) userStake;

    // @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address admin, IERC20 _token) public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        token = _token;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

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

    function spendFromStake(address to, uint256 amount) external whenNotPaused {
        if (amount == 0) {
            revert ZeroAmount();
        }

        if (userStake[msg.sender] < amount) {
            revert InsufficientBalance();
        }

        userStake[msg.sender] -= amount;
        totalStaked -= amount;

        emit Unstake(msg.sender, amount);
        emit SpendFromStake(msg.sender, to, amount);

        token.safeTransfer(to, amount);
    }

    function getTotalStaked() external view returns (uint256) {
        return totalStaked;
    }

    function getAmountStaked(address user) external view returns (uint256) {
        return userStake[user];
    }
}
