// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Vault is Ownable, IERC165, IERC777Recipient {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    Counters.Counter private _depositIdCounter;

    IERC777 public immutable token;

    struct UserInfo {
        address user;
        uint256 amount;
        uint256 expires;
        uint256 startedAt;
        uint256 lockPeriod;
        uint256 rewardPeriod;
    }

    // balances by deposits
    mapping(uint256 => UserInfo) internal _users;
    // deposit id
    mapping(address => mapping(uint256 => uint256)) private _depositsOfOwnerByIndex;
    // counts by user address
    mapping(address => Counters.Counter) private _accountUserInfosCounter;
    // released funds by user
    mapping(address => uint256) public released;

    uint256 private _totalReleased;

    event Deposit(address user, uint256 amount, uint256 lockDuration, uint256 period, uint256 index);
    event Released(address user, uint256 amount);

    constructor(
        address tokenAddress
    ) {
        token = IERC777(tokenAddress);

        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
    }

    function available() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    function totalUserInfos() public view returns (uint256) {
        return _depositIdCounter.current();
    }

    function totalUserInfosByOwner(address beneficiary) public view returns (uint256) {
        return _accountUserInfosCounter[beneficiary].current();
    }

    function depositsOfOwnerByIndex(address beneficiary, uint256 index) public view returns (uint256) {
        return _depositsOfOwnerByIndex[beneficiary][index];
    }

    // balanceOf returns total amount of tokens owned by beneficiary address
    function balanceOf(address beneficiary) public view returns (uint256) {
        uint256 balance = 0;
        return balance;
    }

    // returns amount of unlocked tokens for specified deposit
    function unlocked(uint256 id) internal view returns (uint256) {
        return 0;
    }

    // returns tokens amount available to withdraw for specified beneficiary
    function shares(address user) public view returns (uint256) {
        return 0;
    }

    function withdraw(uint256 amount) public {
        require(shares(_msgSender()) >= amount, "Requested withdraw exceeds available balance");
        _withdraw(_msgSender(), amount);
    }

    function withdrawTo(address to, uint256 amount) public {
        require(to != address(0), "Recipient must be the valid address");
        require(shares(_msgSender()) >= amount, "Requested withdraw exceeds available balance");
        _withdraw(to, amount);
    }

    function _withdraw(address recipient_, uint256 amount_) internal {
        token.operatorSend(address(this), recipient_, amount_, "", "");
        released[recipient_] = released[recipient_].add(amount_);
        _totalReleased = _totalReleased.add(amount_);
        emit Released(recipient_, amount_);
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) public virtual {
        (uint256 delay,
        uint256 period,
        uint256 parts,
        address beneficiary) = abi.decode(operatorData, (uint256, uint256, uint256, address));


    }

    // make it ERC165 compatible
    function supportsInterface(bytes4 interfaceId) public view returns (bool) {
        return interfaceId == type(IERC165).interfaceId ||
        //        interfaceId == type(Vault).interfaceId ||
        interfaceId == type(IERC777Recipient).interfaceId;
    }
}
