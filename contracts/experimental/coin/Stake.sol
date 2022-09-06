// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";

/// @custom:security-contact team@rovergulf.net
contract RCStake is Ownable, IERC165, IERC777Recipient {
    using SafeMath for uint256;

    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    IERC777 public immutable token;
    address private _operator;
    string private _name;

    struct Balance {
        uint256 amount;
        uint256 start;
        uint256 expires;
        uint256 boost;
        uint256 nonce;
        bool lock;
    }

    mapping(address => Balance) _balances;
    uint256 private _available; // reward amount
    uint256 private _deposited; // total deposit amount
    uint256 private _maxLock; // most high lock timestamp
    uint256 private _totalBoostDebt; // total boost reward amount as dept
    uint256 private _totalWeight; // total deposit weight

    // internal values
    uint256 public lockedWithdrawFee = 25; // takes out 25% of profits due lock break
    uint256 public minDepositAmount = 1 ether;
    uint256 public minLockDelay = 7 days;
    uint256 public maxLockDelay = 1000 days;

    constructor(
        string memory name_,
        address tokenAddress_,
        address operator_
    ) {
        _name = name_;
        _operator = operator_;
        token = IERC777(tokenAddress_);

        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
    }

    function available() public view returns (uint256) {
        return _available;
    }

    function deposited() public view returns (uint256) {
        return _deposited;
    }

    function totalAssets() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function account(address account) public view returns (Balance memory) {
        return _balances[account];
    }

    function _accountWeight(address account) internal view returns (uint256) {
        return _balances[account].amount.div(_balances[account].expires);
    }

    function computeShares(address account) public view returns (uint256) {
        return _available.mul(_accountWeight(account).div(_deposited));
    }

    function updateShares(address account, uint256 amount) internal {
        Balance storage account = _balances[_msgSender()];

        if (account.amount > 0) {

        }
    }

    function deposit(uint256 amount, uint256 expiresIn) public {
        require(amount > minDepositAmount, "Not meets the minimal limit");
        require(expiresIn >= minLockDelay, "At least 7 days of expire time is required");
        require(expiresIn <= maxLockDelay, "Expire time exceeds limit");
        Balance storage b = _balances[_msgSender()];

        if (b.lock) {
            require(block.timestamp.add(expiresIn) >= b.expires, "Invalid expire period");

            if (expiresIn > _maxLock) {
                _maxLock = expiresIn;
            }
        } else {
            _balances[_msgSender()].start = block.timestamp;
        }

        if (b.amount > 0) {
            uint256 currentWeight = _accountWeight(_msgSender());
            _totalWeight = _totalWeight.add(currentWeight);
        } else {
            _totalWeight = _totalWeight.add(_accountWeight(_msgSender()));
        }

        if (b.start == 0) {
            b.start = block.timestamp;
        } else {
//            if (b.start + b.expires) {}
        }

        token.operatorSend(_msgSender(), address(this), amount, "", abi.encode(expiresIn));
        _balances[_msgSender()].amount = b.amount.add(amount);
        _balances[_msgSender()].expires = block.timestamp + expiresIn;
    }

    function lock(uint256 expiresIn) public virtual {
        require(expiresIn >= minLockDelay, "At least 7 days of expire time is required");
        require(expiresIn <= maxLockDelay, "Expire time exceeds limit of 1000 days");

        Balance storage b = _balances[_msgSender()];
        require(expiresIn >= b.expires, "Invalid expire period");
        if (expiresIn > _maxLock) {
            _maxLock = expiresIn;
        }

        _balances[_msgSender()].lock = true;
        _balances[_msgSender()].boost = expiresIn;
        _balances[_msgSender()].expires = expiresIn;
    }

    function withdraw() public virtual {
        Balance storage b = _balances[_msgSender()];

    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) public virtual {
        if (operator == address(this)) {
            _deposited = _deposited.add(amount);
        } else if (operator == _operator) {
            _available = _available.add(amount);
        }
    }

    // make it ERC165 compatible
    function supportsInterface(bytes4 interfaceId) public view returns (bool) {
        return interfaceId == type(IERC165).interfaceId ||
        interfaceId == type(IERC777Recipient).interfaceId;
    }
}
