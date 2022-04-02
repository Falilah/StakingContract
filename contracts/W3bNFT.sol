//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Web3Bridge", "W3B") {}

    function createNFT(string memory baseURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(0x90597146Ad1A57f913cF9Ee896496d7b8d9C7eF0, newItemId);
        _setTokenURI(newItemId, baseURI);

        return newItemId;
    }

    function updateTokenURI(uint256 newItemId, string memory baseURI) public {
        _setTokenURI(newItemId, baseURI);
    }
}
