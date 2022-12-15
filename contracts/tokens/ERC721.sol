// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

//import "@openzeppelin/contracts/access/Ownable.sol"; // replaced by Administrated.sol
import "../lib/Administrated.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @custom:security-contact team@rovergulf.net
contract DevERC721 is ERC721, ERC721Enumerable, ERC721Burnable, Administrated, EIP712, ERC721Votes {
    using Counters for Counters.Counter;

    string private _baseUri;
    string private _contractUri;

    Counters.Counter private _tokenIdCounter;

    event Mint(address to, uint256 tokenId);

    constructor() ERC721("MyToken", "REN7") EIP712("MyToken", "1") {}

    function safeMint(address to) public onlyOwner {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        emit Mint(to, tokenId);
    }

    function setContractUrl(string memory newUrl) public adminAccess {
        _contractUri = newUrl;
    }

    function contractUrl() public view returns (string memory) {
        return _contractUri;
    }

    function setBaseUrl(string memory newUrl) public adminAccess {
        _baseUri = newUrl;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseUri;
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Votes) {
        super._afterTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
