// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFT is ERC721URIStorage {
    constructor() ERC721("Cool Nft", "CT") {}
    uint public tokenId = 0;

    function mint(string memory tokenURI) external returns (uint) {
        tokenId++;
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return tokenId;
    }
}