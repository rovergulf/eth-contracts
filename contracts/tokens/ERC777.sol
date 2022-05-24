// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @custom:security-contact team@rovergulf.net
contract DevERC777 is ERC777, Ownable {
    constructor(address[] memory defaultOperators_) ERC777("DevERC777", "RET7", defaultOperators_) {}

    function mint(
        address to,
        uint256 amount
    ) public onlyOwner {
        _mint(to, amount, "", "");
    }
}
