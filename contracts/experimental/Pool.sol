// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenStacking is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;

    struct UserInfo {
        address user;
        uint256 expires;
        uint256 balance;
        uint256 boost;
        uint256 shares;
        uint256 lockedAt;
        uint256 updatedAt;
        bool isLocked;
    }

    mapping(uint256 => UserInfo) internal _users;

    uint256 public constant WITHDRAW_DELAY = 14 days; // 2 weeks
    uint256 public constant MIN_LOCK_DURATION = 7 days; // 1 week
    uint256 public constant MAX_LOCK_DURATION = 365 days; // 1 year

    constructor(
        address tokenAddress_
    ) {
        token = IERC20(tokenAddress_);
    }

    function deposit(uint256 amount, uint256 period) public payable {
        require(period > MIN_LOCK_DURATION, "locking period must be more than one week");
        require(period < MAX_LOCK_DURATION, "locking period must be less than one year");
    }

    function computeShares(address stacker) internal returns (uint256) {
        return 0;
    }

    function lock(uint256 amount, uint256 period) public {}

    function withdraw() public {}
}
