// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./LibExchange.sol";

/// @custom:security-contact team@rovergulf.net
contract Exchange is LibExchange {

    function name() public pure returns (string memory) {
        return "Rovergulf NFT Exchange";
    }

    function atomicMatch(
        Order memory sell,
        Order memory buy,
        bytes memory sellSignature,
        bytes memory buySignature
    ) external payable {
        _atomicMatch(sell, buy, sellSignature, buySignature);
    }

    function hashTypedData(Order memory order) external view returns (bytes32) {
        return _hashTypedData(order);
    }

}
