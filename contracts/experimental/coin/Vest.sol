// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RCVest is Ownable, IERC165, IERC777Recipient {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    Counters.Counter private _depositIdCounter;

    IERC777 public immutable token;

    struct Deposit {
        address account;
        uint256 amount;
        uint256 start;
        uint256 lock;
        uint256 period;
        uint256 parts;
    }

    // balances by deposits
    mapping(uint256 => Deposit) internal _deposits;
    // deposit id
    mapping(address => mapping(uint256 => uint256)) private _depositsOfOwnerByIndex;
    // counts by user address
    mapping(address => Counters.Counter) private _accountDepositsCounter;

    string private _name;
    address private _operator;
    uint256 private _totalReleased;
    mapping(address => uint256) public released;

    event Deposited(address account, uint256 amount, uint256 lockDuration, uint256 period, uint256 index);
    event Released(address account, uint256 amount);

    constructor(
        string memory name_,
        address tokenAddress_,
        address defaultOperator_
    ) {
        _operator = defaultOperator_;
        _name = name_;
        token = IERC777(tokenAddress_);

        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
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

    function totalDeposits() public view returns (uint256) {
        return _depositIdCounter.current();
    }

    function totalDepositsByOwner(address account) public view returns (uint256) {
        return _accountDepositsCounter[account].current();
    }

    function depositsOfOwnerByIndex(address account, uint256 index) public view returns (uint256) {
        return _depositsOfOwnerByIndex[account][index];
    }

    // balanceOf returns total amount of tokens owned by account address
    function balanceOf(address account) public view returns (uint256) {
        uint256 count = totalDepositsByOwner(account);
        if (count == 0) {
            return 0;
        }

        uint256 balance = 0;
        for (uint i = 0; i < count; i++) {
            uint256 depositId = depositsOfOwnerByIndex(account, i);
            balance = balance.add(_deposits[depositId].amount);
        }

        return balance;
    }

    // returns amount of unlocked tokens for specified deposit
    function depositUnlockedAmount(uint256 id) internal view returns (uint256) {
        Deposit storage d = _deposits[id];

        uint256 now = block.timestamp;

        uint256 lockUntil = d.start.add(d.lock);
        if (now < lockUntil) {
            return 0;
        }

        uint256 expiresAt = lockUntil.add(d.period);
        if (now < expiresAt) {
            uint256 timeDiff = now.sub(lockUntil);
            uint256 partDelay = d.period.div(d.parts);
            uint256 partsCompleted = timeDiff.div(partDelay);
            uint256 perPartTokenAmount = d.amount.div(d.parts);

            uint256 unlockedAmount = partsCompleted.mul(perPartTokenAmount);
            uint256 mod = unlockedAmount.mod(1 ether);

            return unlockedAmount.sub(mod);
        } else {
            return d.amount;
        }

    }

    // returns tokens amount available to withdraw for specified account
    function computeShares(address account) public view returns (uint256) {
        uint256 count = totalDepositsByOwner(account);
        if (count == 0) {
            return 0;
        }

        uint256 shares = 0;
        for (uint i = 0; i < count; i++) {
            uint256 depositId = depositsOfOwnerByIndex(account, i);
            shares = shares.add(depositUnlockedAmount(depositId));
        }

        return shares.sub(released[account]);
    }

    function release(uint256 amount) public {
        require(computeShares(_msgSender()) >= amount, "Requested withdraw exceeds available balance");
        _release(_msgSender(), amount);
    }

    function releaseTo(address to, uint256 amount) public {
        require(computeShares(_msgSender()) >= amount, "Requested withdraw exceeds available balance");
        require(to != address(0), "Recipient must be the valid address");
        _release(to, amount);
    }

    function _release(address recipient_, uint256 amount_) internal {
        token.operatorSend(address(this), recipient_, amount_, "", "");
        released[_msgSender()] = released[_msgSender()].add(amount_);
        _totalReleased = _totalReleased.add(amount_);
        emit Released(recipient_, amount_);
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) public virtual {
        require(operator == _operator, "Only can be called by vesting operator");

        (uint256 delay,
        uint256 period,
        uint256 parts,
        address account) = abi.decode(operatorData, (uint256, uint256, uint256, address));

        uint256 id = _depositIdCounter.current();
        uint256 depositIndex = _accountDepositsCounter[account].current();

        Deposit memory newDeposit = Deposit(account, amount, block.timestamp, delay, period, parts);

        _deposits[id] = newDeposit;
        _depositsOfOwnerByIndex[account][depositIndex] = id;
        _depositIdCounter.increment();
        _accountDepositsCounter[account].increment();

        emit Deposited(account, amount, delay, period, id);
    }

    // make it ERC165 compatible
    function supportsInterface(bytes4 interfaceId) public view returns (bool) {
        return interfaceId == type(IERC165).interfaceId ||
        //        interfaceId == type(Vault).interfaceId ||
        interfaceId == type(IERC777Recipient).interfaceId;
    }
}
