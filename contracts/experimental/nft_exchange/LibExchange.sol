// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/// @custom:security-contact team@rovergulf.net
abstract contract LibExchange is Ownable, EIP712 {
    using ECDSA for bytes32;
    using SignatureChecker for address;
    using SafeMath for uint256;

    uint256 private feeDenominator = 10000;

    mapping(address => bool) private _allowedTokens;

    event Match(address caller, bytes32 sellHash, bytes32 buyHash);

    constructor() EIP712("NFTExchange", "v1") {}

    enum TokenInterface {
        ZeroTokenInterface,
        ERC721,
        ERC1155
    }

    struct Order {
        // who placed the order
        address maker;
        // reserve for
        address taker;
        // ERC721 or ERC1155
        TokenInterface tokenInterface;
        // address of nft contract
        address nftAddress;
        // nft token id
        uint256 nftTokenId;
        // nft token amount (erc1155 only)
        uint256 nftAmount;
        // payment token, zero address if to use native network token, like ETH or BNB
        address token;
        // token value amount
        uint256 value;
        // fees are free to fill
        address[] feeRecipients;
        uint256[] feeAmounts;
    }

    // type hash order
    function _hashTypedData(Order memory order) internal view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
                keccak256("Order(address maker,address taker,TokenInterface tokenInterface,address nftAddress,uint256 nftTokenId,uint256 nftAmount,address token,uint256 value)"),
                order.maker,
                order.taker,
                order.tokenInterface,
                order.nftAddress,
                order.nftTokenId,
                order.nftAmount,
                order.token,
                order.value
            )));
    }

    // verified sell order ownership
    function _verifySellOrder(Order memory order) internal view returns (bool, string memory) {
        if (order.tokenInterface == TokenInterface.ERC721) {
            if (IERC721(order.nftAddress).ownerOf(order.nftTokenId) != order.maker) {
                return (false, "Order maker is not an owner of token");
            }

            if (!IERC721(order.nftAddress).isApprovedForAll(order.maker, address(this))) {
                return (false, "Exchange is not approved for token transfers");
            }
        } else if (order.tokenInterface == TokenInterface.ERC1155) {

            if (IERC1155(order.nftAddress).balanceOf(order.maker, order.nftTokenId) < order.nftAmount) {
                return (false, "Order maker is not an owner of token(s)");
            }

            if (!IERC1155(order.nftAddress).isApprovedForAll(order.maker, address(this))) {
                return (false, "Exchange is not approved for token transfers");
            }
        } else {
            return (false, "Invalid token interface");
        }

        return (true, "");
    }

    // verifies buy order allowance and balance
    function _verifyBuyOrder(Order memory order) internal view returns (bool, string memory) {
        if (order.token != address(0)) {
            if (!_allowedTokens[order.token]) {
                return (false, "Specified token is not allowed");
            }

            if (IERC20(order.token).allowance(order.maker, address(this)) < order.value) {
                return (false, "Not enough of ERC20 allowed funds");
            }
        } else {
            if (order.maker.balance < order.value) {
                return (false, "ETH Balance is too low");
            }
        }
        return (true, "");
    }

    // check if signature valid
    function _validateSignature(address signer, bytes32 hash, bytes memory sig) internal view returns (bool) {
        return signer.isValidSignatureNow(hash.toEthSignedMessageHash(), sig) || signer.isValidSignatureNow(hash, sig);
    }

    // transfers funds
    function _transferOrderFunds(
        address from,
        address tokenAddress,
        uint256 transferAmount,
        address[] memory recipients,
        uint256[] memory amounts
    ) internal {
        if (tokenAddress == address(0)) {
            for (uint i = 0; i < recipients.length; i++) {
                address recipient = recipients[i];
                uint256 fee = amounts[i];
                uint256 denominator = SafeMath.div(msg.value, feeDenominator);
                uint256 feeValue = SafeMath.mul(denominator, fee);
                Address.sendValue(payable(recipient), feeValue);
            }
        } else {
            for (uint i = 0; i < recipients.length; i++) {
                address recipient = recipients[i];
                uint256 fee = amounts[i];
                uint256 denominator = SafeMath.div(transferAmount, feeDenominator);
                uint256 feeValue = SafeMath.mul(denominator, fee);
                IERC20(tokenAddress).transferFrom(from, recipient, feeValue);
            }
        }
    }

    // transfers NFT assets
    function _transferOrderNFTs(
        TokenInterface tokenInterface,
        address nftAddress,
        uint256 nftTokenId,
        uint256 nftAmount,
        address from,
        address recipient
    ) internal {
        if (tokenInterface == TokenInterface.ERC721) {
            IERC721(nftAddress).safeTransferFrom(from, recipient, nftTokenId);
        } else if (tokenInterface == TokenInterface.ERC1155) {
            IERC1155(nftAddress).safeTransferFrom(from, recipient, nftTokenId, nftAmount, "");
        }
    }

    // match orders, transfer NFTs and tokens
    function _atomicMatch(
        Order memory sell,
        Order memory buy,
        bytes memory sellSignature,
        bytes memory buySignature
    ) internal {
        bytes32 sellHash = _hashTypedData(sell);
        bytes32 buyHash = _hashTypedData(buy);

        require(_validateSignature(sell.maker, sellHash, sellSignature), "Invalid sell order signature");
        require(_validateSignature(buy.maker, buyHash, buySignature), "Invalid buy order signature");

        _transferOrderFunds(buy.maker, sell.token, sell.value, sell.feeRecipients, sell.feeAmounts);
        _transferOrderNFTs(sell.tokenInterface, sell.nftAddress, sell.nftTokenId, sell.nftAmount, sell.maker, buy.maker);

        emit Match(_msgSender(), sellHash, buyHash);
    }
}
