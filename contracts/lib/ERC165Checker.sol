// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/interfaces/IERC4626.sol";

import "../interfaces/IERC173.sol";
import "../interfaces/IERC4907.sol";
import "../interfaces/IERC5313.sol";

interface IIDChecker {
    function isERC5313(address addr) external view returns (bool);

    function isERC173(address addr) external view returns (bool);

    function isERC20(address addr) external view returns (bool);

    function isERC721(address addr) external view returns (bool);

    function isERC721Receiver(address addr) external view returns (bool);

    function isERC777(address addr) external view returns (bool);

    function isERC1155(address addr) external view returns (bool);

    function isERC1155Receiver(address addr) external view returns (bool);

    function isERC4626(address addr) external view returns (bool);

    function isERC4907(address addr) external view returns (bool);
}

contract InterfaceChecker is IIDChecker, ERC165, Ownable {
    using ERC165Checker for address;

    bytes4 public constant IID_SELF = type(IIDChecker).interfaceId;
    bytes4 public constant IID_IERC173 = type(IERC173).interfaceId;
    bytes4 public constant IID_IERC165 = type(IERC165).interfaceId;
    bytes4 public constant IID_IERC1155 = type(IERC1155).interfaceId;
    bytes4 public constant IID_IERC1155Receiver = type(IERC1155Receiver).interfaceId;
    bytes4 public constant IID_IERC721 = type(IERC721).interfaceId;
    bytes4 public constant IID_IERC721Enumerable = type(IERC721Enumerable).interfaceId;
    bytes4 public constant IID_IERC721Receiver = type(IERC721Receiver).interfaceId;
    bytes4 public constant IID_IERC20 = type(IERC20).interfaceId;
    bytes4 public constant IID_IERC777 = type(IERC777).interfaceId;
    bytes4 public constant IID_IERC4626 = type(IERC4626).interfaceId;
    bytes4 public constant IID_IERC4907 = type(IERC4907).interfaceId;
    bytes4 public constant IID_IERC5313 = type(IERC5313).interfaceId;

    function isERC20(address addr) external view returns (bool) {
        return addr.supportsInterface(IID_IERC20);
    }

    function isERC173(address addr) external view returns (bool) {
        return addr.supportsInterface(IID_IERC173);
    }

    function isERC721(address addr) external view returns (bool) {
        return addr.supportsInterface(IID_IERC721);
    }

    function isERC721Receiver(address addr) external view returns (bool) {
        return addr.supportsInterface(IID_IERC721Receiver);
    }

    function isERC721Enumerable(address addr) external view returns (bool) {
        return addr.supportsInterface(IID_IERC721Enumerable);
    }

    function isERC777(address addr) external view returns (bool) {
        return addr.supportsInterface(IID_IERC777);
    }

    function isERC1155(address addr) external view returns (bool) {
        return addr.supportsInterface(IID_IERC1155);
    }

    function isERC1155Receiver(address addr) external view returns (bool) {
        return addr.supportsInterface(IID_IERC1155Receiver);
    }

    function isERC4626(address addr) external view returns (bool) {
        return addr.supportsInterface(IID_IERC4626);
    }

    function isERC4907(address addr) external view returns (bool) {
        return addr.supportsInterface(IID_IERC4907);
    }

    function isERC5313(address addr) external view returns (bool) {
        return addr.supportsInterface(IID_IERC5313);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == IID_SELF || interfaceId == IID_IERC165;
    }
}
