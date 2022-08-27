// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../ERC777Token.sol";

/// @custom:security-contact team@rovergulf.net
contract CoinMock is Ownable {

    ERC777Token public immutable token;

    constructor(
        address tokenAddress_
    ) {
        token = ERC777Token(tokenAddress_);
    }

    function mint(address recipient, uint256 amount, bytes memory operatorData) public onlyOwner {
        token.mint(recipient, amount, operatorData);
    }

    function send(address recipient, uint256 amount, bytes memory data) public {
        token.send(recipient, amount, data);
    }
}
