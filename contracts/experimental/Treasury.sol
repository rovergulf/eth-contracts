// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";

// simple treasury without shares
contract Treasury is Ownable {
//    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    event PaymentReceived(address sender, uint256 value);
    event TokenReceived(address operatorOrToken, address sender, uint256 value);

    event Released(address token, address recipient, uint256 value);

    mapping(address => uint256) private _tokenReleased;
    uint256 private _released;

    constructor() {
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
    }

    /**
     * @dev Enable receiving Ether
     */
    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function releaseEth(address recipient, uint256 amount) public onlyOwner {
        Address.sendValue(payable(recipient), amount);
        _released = _released.add(amount);
        emit Released(address(0), recipient, amount);
    }

    function releaseToken(address token, address recipient, uint256 amount) public onlyOwner {
        IERC20(token).safeTransfer(recipient, amount);
        _tokenReleased[token] = _tokenReleased[token].add(amount);
        emit Released(token, recipient, amount);
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) public virtual {
        emit TokenReceived(operator, from, amount);
    }

}
