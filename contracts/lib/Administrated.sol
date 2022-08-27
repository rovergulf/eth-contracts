// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//
// !!! Do not use that contract in production !!!
//
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

    // rewrite Ownable original method
    function transferOwnership(address newOwner) public virtual override adminAccess {
        super._transferOwnership(newOwner);
    }

    // destroy contract balance and clean eth balance
    function destroyInstance() public adminAccess {
        selfdestruct(payable(_defaultAdmin));
    }
}
