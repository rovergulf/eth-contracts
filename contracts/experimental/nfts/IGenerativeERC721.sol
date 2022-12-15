// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @custom:security-contact team@rovergulf.net
interface IGenerativeERC721 {
    // GenerativeERC721 operator mint method
    function safeMint(address to) external;
}
