// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";

import "./ERC777Token.sol";

// Pool is an operator contract
/// @custom:security-contact team@rovergulf.net
contract RCPoolManager is Ownable, IERC165 {
    using Address for address;
    using SafeMath for uint256;

    IERC777 public immutable token;
    uint256 private _totalReleased;
    uint256 private _totalTransferred;
    string private _name;

    event Released(address user, uint256 amount);

    constructor(
        string memory name_,
        address tokenAddress
    ) {
        _name = name_;
        token = IERC777(tokenAddress);
    }

    function asCoin() internal view returns (ERC777Token) {
        return ERC777Token(address(token));
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function available() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    function totalTransferred() public view returns (uint256) {
        return _totalTransferred;
    }

    //    function approveAndCall(
    //        address recipient,
    //        uint256 amount,
    //        bytes memory callData
    //    ) public payable {
    //        IERC20(address(this)).approve(recipient, amount);
    //        (bool success, bytes memory returndata) = targets[i].call{value: msg.value}(callData);
    //        Address.verifyCallResult(success, returndata, "Pool: call reverted with message");
    //    }

    function mint(address recipient, uint256 amount, bytes memory operatorData) public onlyOwner {
        asCoin().mint(recipient, amount, operatorData);
    }

    function send(
        address recipient,
        uint256 amount,
        bytes memory userData
    ) public {
        token.operatorSend(_msgSender(), recipient, amount, userData, "");
        _totalTransferred = _totalTransferred.add(amount);
    }

    function operatorSend(
        address recipient,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) public onlyOwner {
        token.operatorSend(address(this), recipient, amount, userData, operatorData);
        _totalReleased = _totalReleased.add(amount);
        emit Released(recipient, amount);
    }

    // make it ERC165 compatible
    function supportsInterface(bytes4 interfaceId) public view returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
