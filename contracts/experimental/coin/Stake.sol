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
        uint256 boost;
        uint256 nonce;
        uint256 lockedUntil;
        bool lock;
    }

    mapping(address => Balance) _balances;
    uint256 private _available; // reward amount
    uint256 private _deposited; // total deposit amount
    uint256 private _totalBoostDebt; // total boost reward amount as debt

    // internal values
    uint256 public lockedWithdrawFee = 25; // takes out 25% of profits due lock break, which funds boost rewards
    uint256 public minDepositAmount = 1 ether;

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

    function totalWeight() public view returns (uint256) {
        return 0;
    }

    function account(address account) public view returns (Balance memory) {
        return _balances[account];
    }

    function accountWeight(address account) public view returns (uint256) {
        uint256 lockDuration = block.timestamp.sub(_balances[account].start);
        return _balances[account].amount.div(lockDuration);
    }

    function computeShares(address account) public view returns (uint256) {
        return _available.div(totalWeight().div(accountWeight(account)));
    }

    function computeReward(address account) public view returns (uint256) {
        Balance storage b = _balances[account];
        if (b.amount == 0) {
            return 0;
        }

        uint256 shares = computeShares(account);
        return b.amount.add(shares);
    }

    function deposit(uint256 amount) public {
        require(amount > minDepositAmount, "Not meets the minimal limit");
        address account = _msgSender();
        Balance storage b = _balances[account];

        token.operatorSend(account, address(this), amount, "", "");
        if (b.start == 0) {
            _balances[account].start = block.timestamp;
        }
        _balances[account].amount = b.amount.add(amount);
        _balances[account].nonce++;
    }

    function withdraw() public virtual {
        address account = _msgSender();
        Balance storage b = _balances[account];
    }

    function tokensReceived(
        address operator,
        address,
        address,
        uint256 amount,
        bytes calldata,
        bytes calldata
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
