// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    error MoodNft__CantFlipMoodIfNotOwner();

    uint256 private s_tokenCounter;
    string private s_sadSvgImageUri;
    string private s_happySvgImageUri;

    enum Mood {
        Happy,
        Sad
    }

    mapping(uint256 => Mood) private s_tokenIdToMood;

    constructor(string memory sadSvgImageUri, string memory happySvgImageUri) ERC721("Mood NFT", "MN") {
        s_tokenCounter = 0;
        s_sadSvgImageUri = sadSvgImageUri;
        s_happySvgImageUri = happySvgImageUri;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.Happy;
        s_tokenCounter++;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory imageURI;

        if (s_tokenIdToMood[tokenId] == Mood.Happy) {
            imageURI = s_happySvgImageUri;
        } else {
            imageURI = s_sadSvgImageUri;
        }
        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    abi.encodePacked(
                        '{"name": "',
                        name(),
                        '", "description": "An NFT that reflects the owners mood.", "attributes": "[{"trait_type": "moodiness", "value": "100"}], "image": "',
                        imageURI,
                        '"}'
                    )
                )
            )
        );
    }

    function flipMood(uint256 tokenId) public {
        if (!_isAuthorized(msg.sender, msg.sender, tokenId)) {
            revert MoodNft__CantFlipMoodIfNotOwner();
        }
        if (s_tokenIdToMood[tokenId] == Mood.Happy) {
            s_tokenIdToMood[tokenId] = Mood.Sad;
        } else {
            s_tokenIdToMood[tokenId] = Mood.Happy;
        }
    }

    function getTokenCounter() external view returns (uint256) {
        return s_tokenCounter;
    }

    function getSadSvgImageUri() external view returns (string memory) {
        return s_sadSvgImageUri;
    }

    function getHappySvgImageUri() external view returns (string memory) {
        return s_happySvgImageUri;
    }

    function getTokenIdToMood(uint256 tokenId) external view returns (Mood) {
        return s_tokenIdToMood[tokenId];
    }
}
