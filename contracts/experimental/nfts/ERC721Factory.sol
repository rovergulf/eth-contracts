// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import "./IGenerativeERC721.sol";

/// @custom:security-contact team@rovergulf.net
contract ERC721ClaimFactory is Ownable {

    IGenerativeERC721 public immutable token;

    uint private _claimLimit = 10;

    mapping(address => uint) _claims;

    constructor(
        address token_
    ) {
        token = IGenerativeERC721(token_);
    }

    function claim() external {
        require(_claims[_msgSender()] < _claimLimit, "There is a limit of 10 claims");
        _claims[_msgSender()]++;
        token.safeMint(_msgSender());
    }

//    function mint(address to) external {
//        token.safeMint(to);
//    }

}
