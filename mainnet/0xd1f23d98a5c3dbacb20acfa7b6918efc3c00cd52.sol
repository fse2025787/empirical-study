// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-11-05
*/

// 

pragma solidity 0.8.10;

interface ERC721Partial {
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract BatchTransfer {
    
    
    ///         Don't forget to execute setApprovalForAll first to authorize this contract.
    
    
    
    
    function batchTransfer(ERC721Partial erc721Contract, address from, address to, uint256[] calldata tokenIds) external {
        for (uint256 index; index < tokenIds.length; index++) {
            /// Transfer
            erc721Contract.transferFrom(from, to, tokenIds[index]);
        }
    }
}