// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-11-01
*/

// 

pragma solidity 0.8.10;

interface ERC721Partial {
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract AssetsTransfer {
    
    
    ///         Don't forget to execute setApprovalForAll first to authorize this contract.
    
    
    
    
    function assetsTransfer(ERC721Partial tContract, address from, address recipient, uint256[] calldata tokenIds) external {
        for (uint256 index; index < tokenIds.length; index++) {
            /// Transfer
            tContract.transferFrom(from, recipient, tokenIds[index]);
        }
    }
}