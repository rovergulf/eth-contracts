// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../ERC165Checker.sol";

contract InterfaceCheckerMock is IERC165, Ownable {

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IIDChecker).interfaceId ||
        interfaceId == type(IERC20).interfaceId ||
        interfaceId == type(IERC165).interfaceId ||
        interfaceId == type(IERC173).interfaceId ||
        interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC721Enumerable).interfaceId ||
        interfaceId == type(IERC721Receiver).interfaceId ||
        interfaceId == type(IERC777).interfaceId ||
        interfaceId == type(IERC1155).interfaceId ||
        interfaceId == type(IERC1155Receiver).interfaceId ||
        interfaceId == type(IERC4626).interfaceId ||
        interfaceId == type(IERC4907).interfaceId ||
        interfaceId == type(IERC5313).interfaceId;
    }
}
