// SPDX-License-Identifier: GPL-3.0

/**
 *Submitted for verification at Etherscan.io on 2023-01-28
*/

// 
pragma solidity ^0.8.6;

interface INounsTokenLike {
    function balanceOf(address account) external view returns (uint256);

    function getCurrentVotes(address account) external view returns (uint96);

    function delegates(address delegator) external view returns (address);
}


contract LilNounsDelegateVotes {
    INounsTokenLike public immutable nouns = INounsTokenLike(0x4b10701Bfd7BFEdc47d50562b76b436fbB5BdB3B);

    
    
    function balanceOf(address account) public view returns (uint256) {
        address delegate = nouns.delegates(account);
        uint256 balance = nouns.balanceOf(account);
        uint256 votes = uint256(nouns.getCurrentVotes(account));
        if (delegate == account) return votes - balance;
        return votes;
    }
}