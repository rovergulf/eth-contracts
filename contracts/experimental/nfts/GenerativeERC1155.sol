// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

/// @custom:security-contact team@rovergulf.net
contract GenerativeERC1155 is Ownable, AccessControl, ERC1155, ERC1155Supply {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("TRANSFER_OPERATOR_ROLE");

    string private _name;
    string private _symbol;

    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, _msgSender()), "Restricted to minter role only");
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _name = name_;
        _symbol = symbol_;
    }

    string private _contractUri;

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function setURI(string memory newUri) external onlyOwner {
        _setURI(newUri);
    }

    function setContractUrl(string memory newUrl) external onlyOwner {
        _contractUri = newUrl;
    }

    function contractUrl() external view returns (string memory) {
        return _contractUri;
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external onlyMinter {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external onlyMinter {
        _mintBatch(to, ids, amounts, data);
    }

    // rewrite isApprovedForAll to handle operator role
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        if (hasRole(OPERATOR_ROLE, operator)) {
            return true;
        }

        return super.isApprovedForAll(account, operator);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return AccessControl.supportsInterface(interfaceId) ||
        ERC1155.supportsInterface(interfaceId) ||
        super.supportsInterface(interfaceId);
    }
}
