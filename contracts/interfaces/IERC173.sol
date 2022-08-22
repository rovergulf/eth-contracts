// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// interface for https://eips.ethereum.org/EIPS/eip-173

interface IERC173 {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() view external returns (address);

    function transferOwnership(address newOwner) external;
}
