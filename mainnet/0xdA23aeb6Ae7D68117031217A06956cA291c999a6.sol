// SPDX-License-Identifier: MIT

// 
pragma solidity >=0.8.9 <0.9.0;

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract BatchTransfer {
    
    ///         Don't forget to execute setApprovalForAll first to authorize this contract.
    
    
    
    function batchTransfer(IERC721 _tokenContract, address[] calldata _recipients, uint256[] calldata _tokenIds) external {
        for (uint256 i; i < _tokenIds.length; i++) {
            _tokenContract.transferFrom(msg.sender, _recipients[i], _tokenIds[i]);
        }
    }
}