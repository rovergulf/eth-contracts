// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//import "@openzeppelin/contracts/access/Ownable.sol"; // replaced by Administrated.sol
import "../lib/Administrated.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

/// @custom:security-contact team@rovergulf.net
contract DevERC1155 is ERC1155, Administrated, ERC1155Burnable, ERC1155Supply {

    constructor() ERC1155("") {}

    string private _contractUri;

    function name() public pure returns (string memory) {
        return "DevERC1155 Token";
    }

    function symbol() public pure returns (string memory) {
        return "RET15";
    }

    function setURI(string memory newUri) public adminAccess {
        _setURI(newUri);
    }

    function setContractUrl(string memory newUrl) public adminAccess {
        _contractUri = newUrl;
    }

    function contractUrl() public view returns (string memory) {
        return _contractUri;
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyOwner {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
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
}
