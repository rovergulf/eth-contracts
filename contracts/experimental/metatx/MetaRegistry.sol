// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";

/// @custom:security-contact team@rovergulf.net
contract MetaTxRegistry is ERC2771Context {
    event Registered(address indexed who, string name);

    mapping(address => string) public names;
    mapping(string => address) public owners;

    constructor(MinimalForwarder forwarder) ERC2771Context(address(forwarder)) {}

    function register(string memory name) external {
        require(owners[name] == address(0), "Name taken");
        address owner = _msgSender();
        owners[name] = owner;
        names[owner] = name;

        emit Registered(owner, name);
    }
}
