// SPDX-License-Identifier: MIT

// 

pragma solidity 0.8.17;

interface ERC721Partial {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

contract BatchTransfer {
    
    ///         Don't forget to execute setApprovalForAll first to authorize this contract.
    
    
    
    function batchTransfer(
        ERC721Partial tokenContract,
        address recipient,
        uint256[] calldata tokenIds
    ) external {
        for (uint256 index; index < tokenIds.length; index++) {
            tokenContract.transferFrom(msg.sender, recipient, tokenIds[index]);
        }
    }
}