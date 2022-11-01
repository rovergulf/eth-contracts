// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";

/// @custom:security-contact team@rovergulf.net
contract MetaForwarder is Ownable, MinimalForwarder {

    constructor() {}

    function name() external pure returns (string memory) {
        return "Simple Meta Tx Forwarder";
    }

}
