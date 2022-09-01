// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../Proxy.sol";

/// @custom:security-contact team@rovergulf.net
contract ProxyMock is Ownable {

    Proxy public proxy;

    constructor(
        address proxyAddr
    ) {
        proxy = Proxy(payable(proxyAddr));
    }

    function proxyCall(bytes memory callData) public {

    }
}
