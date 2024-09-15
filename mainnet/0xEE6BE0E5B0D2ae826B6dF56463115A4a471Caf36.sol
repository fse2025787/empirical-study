// SPDX-License-Identifier: MIT

// 
pragma solidity ^0.8.0;

interface IERC721Partial {
  function transferFrom(address from, address to, uint256 tokenId) external;
}


///        heavily inspiried by: https://nft.life/batch-transfer 

contract BatchTransfer {
  
  
  ///                         the tokens also drop in a reverse linear pattern from last on the list to the first
  
  
  
  function batchTransfer(IERC721Partial _tokenContract, address[] calldata _to, uint256[] calldata _tokens) external {
    uint256 length = _to.length;
    while (length > 0) {
      unchecked { --length; }
      _tokenContract.transferFrom(msg.sender, _to[length], _tokens[length]);
    }
  }
}