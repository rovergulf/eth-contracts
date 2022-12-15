// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @custom:security-contact team@rovergulf.net
contract GenerativeNFTsMock is Ownable {

    IERC721 public immutable token;

    constructor(
        address token_
    ) {
        token = IERC721(token_);
    }

    function transferToken(address from, address recipient, uint256 tokenId) external {
        token.transferFrom(from, recipient, tokenId);
    }

}
