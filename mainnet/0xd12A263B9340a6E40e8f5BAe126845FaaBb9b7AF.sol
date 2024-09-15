// SPDX-License-Identifier: MIT

// 

pragma solidity ^0.8.0;

interface ERC721Partial {
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract BatchTransfer {
    
    ///         Don't forget to execute setApprovalForAll first to authorize this contract.
    
    
    
    function batchTransfer(ERC721Partial tokenContract, address recipient, uint256[] calldata tokenIds) external {
        for (uint256 index; index < tokenIds.length; index++) {
            tokenContract.transferFrom(msg.sender, recipient, tokenIds[index]);
        }
    }

    
    ///         Don't forget to execute setApprovalForAll first to authorize this contract.
    
    
    
    function batchTransfers(ERC721Partial tokenContract, address[] calldata recipients, uint256[] calldata tokenIds) external {
        require(tokenIds.length == recipients.length, "length must be same");
        for (uint256 index; index < tokenIds.length; index++) {
            tokenContract.transferFrom(msg.sender, recipients[index], tokenIds[index]);
        }
    }
}