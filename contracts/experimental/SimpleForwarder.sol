// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @custom:security-contact team@rovergulf.net
contract SimpleForwarder is Ownable {

    event Executed(address caller, string description);

    constructor() {}

    function name() public pure returns (string memory) {
        return "Simple Forwarder";
    }

    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory callDatas,
        string memory description
    ) public payable onlyOwner {
        require(targets.length > 0, "At least one target are required");
        require(targets.length == values.length, "Targets length must be equal to values");
        require(values.length == callDatas.length, "Values length must be equal to callDatas");

        for (uint i = 0; i < targets.length; i++) {
            (bool success, bytes memory returndata) = targets[i].call{value : values[i]}(callDatas[i]);
            Address.verifyCallResult(success, returndata, "SimpleForwarder: call reverted with message");
        }

        emit Executed(msg.sender, description);
    }
}
