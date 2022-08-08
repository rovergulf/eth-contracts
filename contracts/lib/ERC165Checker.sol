// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

interface IIDChecker {
    function isERC20(address addr) external view returns (bool);
    function isERC721(address addr) external view returns (bool);
    function isERC777(address addr) external view returns (bool);
    function isERC1155(address addr) external view returns (bool);
}

contract InterfaceChecker is IIDChecker, IERC165 {
    using ERC165Checker for address;

    bytes4 public constant IID_SELF = type(IIDChecker).interfaceId;
    bytes4 public constant IID_IERC165 = type(IERC165).interfaceId;
    bytes4 public constant IID_IERC1155 = type(IERC1155).interfaceId;
    bytes4 public constant IID_IERC721 = type(IERC721).interfaceId;
    bytes4 public constant IID_IERC20 = type(IERC20).interfaceId;
    bytes4 public constant IID_IERC777 = type(IERC777).interfaceId;


    function isERC20(address addr) external view override returns (bool) {
        return addr.supportsInterface(IID_IERC20);
    }

    function isERC721(address addr) external view override returns (bool) {
        return addr.supportsInterface(IID_IERC721);
    }

    function isERC777(address addr) external view override returns (bool) {
        return addr.supportsInterface(IID_IERC777);
    }

    function isERC1155(address addr) external view override returns (bool) {
        return addr.supportsInterface(IID_IERC1155);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == IID_SELF || interfaceId == IID_IERC165;
    }
}
