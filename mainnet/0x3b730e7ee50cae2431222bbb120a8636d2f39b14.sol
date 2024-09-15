// SPDX-License-Identifier: CC0-1.0

/**
 *Submitted for verification at Etherscan.io on 2022-08-10
*/

// 
pragma solidity ^0.8.16;

interface IImmutablesArt {
    function ownerOf(uint) external view returns (address);
    function tokenIdToProjectId(uint) external view returns (uint);
    function projectIdToTokenIds(uint, uint) external view returns (uint);
}

interface IMinter {
    function mint(address to) external payable;
}

contract SyncretHolderMint {
    
    IImmutablesArt public immutable immutablesArt;
    
    IMinter public immutable minter;
    
    uint public immutable claimableProject;

    
    mapping(uint => bool) public claimedToken;

    event TokenClaimed(uint indexed tokenId);

    error AlreadyClaimed();
    error NotTokenOwner();
    error TokenNotEligible();

    constructor(IMinter minter_, IImmutablesArt immutablesArt_, uint claimableProject_) {
        minter = minter_;
        immutablesArt = immutablesArt_;
        claimableProject = claimableProject_;
    }

    
    function claimedEdition(uint editionId) external view returns (bool) {
        unchecked {
            return claimedToken[immutablesArt.projectIdToTokenIds(claimableProject, editionId - 1)];
        }
    }

    
    function claimEdition(uint editionId) external {
        uint tokenId;
        unchecked {
            tokenId = immutablesArt.projectIdToTokenIds(claimableProject, editionId - 1);
        }

        if (msg.sender != immutablesArt.ownerOf(tokenId)) revert NotTokenOwner();
        if (claimedToken[tokenId]) revert AlreadyClaimed();

        claimedToken[tokenId] = true;
        emit TokenClaimed(tokenId);
        minter.mint(msg.sender);
    }

    
    function claimToken(uint tokenId) external {
        if (msg.sender != immutablesArt.ownerOf(tokenId)) revert NotTokenOwner();
        if (claimedToken[tokenId]) revert AlreadyClaimed();
        if (immutablesArt.tokenIdToProjectId(tokenId) != claimableProject) revert TokenNotEligible();

        claimedToken[tokenId] = true;
        emit TokenClaimed(tokenId);
        minter.mint(msg.sender);
    }
}