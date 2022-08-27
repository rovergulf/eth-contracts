// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC4626.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RCStake is Ownable, IERC165, IERC777Recipient {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    IERC777 public immutable _token;
    address private _operator;
    string private _name;

    uint256 public minLockDelay = 7 days;
    uint256 public maxLockDelay = 1000 days;

    constructor(
        string memory name_,
        address tokenAddress_,
        address operator_
    ) {
        _name = name_;
        _token = IERC777(tokenAddress_);
        _operator = operator_;

        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
    }

    function computeShares(address account) public view returns (uint256) {

        return 0;
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) public virtual {
        require(operator == _operator, "Only can be called by vesting operator");


    }

    // make it ERC165 compatible
    function supportsInterface(bytes4 interfaceId) public view returns (bool) {
        return interfaceId == type(IERC165).interfaceId ||
        interfaceId == type(IERC777Recipient).interfaceId;
    }
}
