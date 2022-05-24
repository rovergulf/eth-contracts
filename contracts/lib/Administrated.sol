// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Administrated is Ownable {
    address private _defaultAdmin;

    modifier adminAccess() {
        require(
            _msgSender() == owner() || _msgSender() == _defaultAdmin,
            "Administrated: caller is not an owner, nor admin"
        );
        _;
    }

    constructor() {
        _defaultAdmin = _msgSender();
    }

    function defaultAdmin() public view returns (address) {
        return _defaultAdmin;
    }

    function transferOwnership(address newOwner) public virtual override adminAccess {
        super._transferOwnership(newOwner);
    }
}
