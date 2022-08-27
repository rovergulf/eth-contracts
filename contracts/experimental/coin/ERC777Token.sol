// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/// @custom:security-contact team@rovergulf.net
abstract contract ERC777Token is ERC777, Ownable {
    using SafeMath for uint256;

    uint256 public maxSupply = 1e26;
    mapping(address => bool) private _defaultOperators;

    modifier onlyTokenDefaultOperator() {
        require(isDefaultOperator(_msgSender()), "Restricted to token default operators");
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory initialRecipients_,
        uint256[] memory initialAmounts_,
        address[] memory defaultOperators_
    ) ERC777(name_, symbol_, defaultOperators_) {
        _initSupply(initialRecipients_, initialAmounts_);
        for (uint i = 0; i < defaultOperators_.length; i++) {
            _defaultOperators[defaultOperators_[i]] = true;
        }
    }

    function _initSupply(address[] memory initialRecipients_, uint256[] memory initialAmounts_) internal {
        require(initialRecipients_.length == initialAmounts_.length, "Recipients length must be equal to amounts");
        for (uint i = 0; i < initialRecipients_.length; i++) {
            _mint(initialRecipients_[i], initialAmounts_[i], "", "");
        }
    }

    function isDefaultOperator(address operator_) public view returns (bool) {
        return _defaultOperators[operator_];
    }

    function mint(address to, uint256 amount, bytes calldata operatorData) public onlyTokenDefaultOperator {
        require(totalSupply().add(amount) <= maxSupply, "Amount exceeds token mint limit");
        _mint(to, amount, "", operatorData);
    }

}
