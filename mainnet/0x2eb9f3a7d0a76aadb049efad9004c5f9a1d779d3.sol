// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-03-30
*/

// 

pragma solidity 0.8.10;

interface ERC721Partial {
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract BatchTransfer {
    
    
    
    
    /// Loop the transfer function for the number of tokens to be sent
    function batchTransfer(ERC721Partial NFTContract, address recipient, uint256[] calldata tokenIds) external {
        for (uint256 index; index < tokenIds.length; index++) {
            NFTContract.transferFrom(msg.sender, recipient, tokenIds[index]);
        }
    }
}