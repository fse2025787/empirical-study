// SPDX-License-Identifier: MIT

// 

pragma solidity 0.8.17;

interface ERC721Partial {
  function transferFrom(address from, address to, uint256 tokenId) external;
}

contract BatchERC721Transfer {
  error RecipientsAndTokenIdsAreNotSameLength();
  
  
  ///         Don't forget to execute setApprovalForAll first to authorize this contract.
  
  
  
  function batchTransfer(ERC721Partial tokenContract, address[] calldata recipients, uint256[] calldata tokenIds) external {
    if (recipients.length != tokenIds.length) revert RecipientsAndTokenIdsAreNotSameLength();
  
    for (uint256 index; index < tokenIds.length; index++) {
      tokenContract.transferFrom(msg.sender, recipients[index], tokenIds[index]);
    }
  }
}