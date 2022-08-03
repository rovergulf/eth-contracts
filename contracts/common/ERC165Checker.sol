//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

abstract contract ERC165Check is ERC165 {
    using ERC165Checker for address;

    function supportsInterface(address target, bytes4 interfaceId) internal view returns (bool) {
        return target.supportsInterface(interfaceId);
    }
}

