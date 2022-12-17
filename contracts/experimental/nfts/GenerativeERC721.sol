// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./IGenerativeERC721.sol";

/// @custom:security-contact team@rovergulf.net
contract GenerativeERC721 is Ownable, AccessControl, ERC721, ERC721Enumerable, IGenerativeERC721 {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("TRANSFER_OPERATOR_ROLE");

    using Counters for Counters.Counter;

    string private _baseUri;
    string private _contractUri;


    uint256 private _maxSupply;
    Counters.Counter private _tokenIdCounter;

    event Mint(address to, uint256 tokenId);

    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, _msgSender()), "Restricted to minter role only");
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_
    ) ERC721(name_, symbol_) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _maxSupply = maxSupply_;
    }

    function maxTotalSupply() external view returns (uint256) {
        return _maxSupply;
    }

    function safeMint(address to) public onlyMinter {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId <= _maxSupply, "Mint exceeds supply limit");
        _safeMint(to, tokenId);
        emit Mint(to, tokenId);
    }

    function setContractUrl(string memory newUrl) public onlyOwner {
        _contractUri = newUrl;
    }

    function contractUrl() public view returns (string memory) {
        return _contractUri;
    }

    function setBaseUrl(string memory newUrl) public onlyOwner {
        _baseUri = newUrl;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseUri;
    }

    // rewrite isApprovedForAll to handle operator role
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        if (hasRole(OPERATOR_ROLE, operator)) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, AccessControl) returns (bool) {
        return AccessControl.supportsInterface(interfaceId) ||
        ERC721.supportsInterface(interfaceId) ||
        ERC721Enumerable.supportsInterface(interfaceId) ||
        super.supportsInterface(interfaceId);
    }
}
