// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC777Token.sol";

/// @custom:security-contact team@rovergulf.net
contract RovergulfCoin is ERC777Token {
    constructor(
        address[] memory initialRecipients_,
        uint256[] memory initialAmounts_,
        address[] memory defaultOperators_
    ) ERC777Token("Rovergulf Coin", "tRC0", initialRecipients_, initialAmounts_, defaultOperators_) {}
}
