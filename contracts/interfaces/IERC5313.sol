// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// https://eips.ethereum.org/EIPS/eip-5313

/// @title EIP-5313 Light Contract Ownership Standard
interface IERC5313 {
    /// @notice Get the address of the owner
    /// @return The address of the owner
    function owner() view external returns (address);
}
