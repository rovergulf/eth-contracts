// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

/// @custom:security-contact team@rovergulf.net
contract Exchange is Ownable, EIP712 {
    using ECDSA for bytes32;

    event Match(address caller, bytes32 sellHash, bytes32 buyHash);

    constructor() EIP712("Exchange", "v1") {}

    struct Order {
        address maker;
        address taker;
        address target;
        bytes callData;
        uint256 value;
    }

    function name() public pure returns (string memory) {
        return "Rovergulf Exchange";
    }

    function matchOrders(
        Order memory sell,
        Order memory buy,
        bytes memory signatures
    ) public payable {
        (bytes memory sig1, bytes memory sig2) = abi.decode(signatures, (bytes, bytes));
        bytes32 sellHash = hashTypedData(sell);
        bytes32 buyHash = hashTypedData(buy);
        require(SignatureChecker.isValidSignatureNow(sell.maker, sellHash, sig1), "Invalid sell order signature");
        require(SignatureChecker.isValidSignatureNow(buy.maker, buyHash, sig2), "Invalid buy order signature");

        (bool success1, bytes memory returndata1) = sell.target.call{value : sell.value}(sell.callData);
        Address.verifyCallResult(success1, returndata1, "Exchange: call reverted with message");

        (bool success2, bytes memory returndata2) = buy.target.call{value : buy.value}(buy.callData);
        Address.verifyCallResult(success2, returndata2, "Exchange: call reverted with message");

        emit Match(_msgSender(), sellHash, buyHash);
    }

    function hashTypedData(Order memory order) public view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
                keccak256("Order(address maker,address taker,address target,bytes callData,uint256 value)"),
                order.maker,
                order.taker,
                order.target,
                order.callData,
                order.value
            )));
    }

}
