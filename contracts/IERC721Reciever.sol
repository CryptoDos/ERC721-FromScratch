//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC721Receiver {
    function onERC721Recieved(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
