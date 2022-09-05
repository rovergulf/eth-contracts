// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";

/// @custom:security-contact team@rovergulf.net
contract AbstractProxy is Ownable, IERC165, Proxy {

    address payable private proxyTo;

    constructor(
        address implementation_
    ) {
        proxyTo = payable(implementation_);
    }

    function setImplementation(address implementation_) public onlyOwner {
        proxyTo = payable(implementation_);
    }

    function _implementation() internal override view returns (address) {
        return proxyTo;
    }

    // make it ERC165 compatible
    function supportsInterface(bytes4 interfaceId) public view returns (bool) {
        return interfaceId == type(IERC165).interfaceId || IERC165(_implementation()).supportsInterface(interfaceId);
    }
}
