// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-03-24
*/

// 

pragma solidity 0.8.13;

contract BlockTime {
    function getTime() external view returns (uint256) {
        return block.timestamp;
    }
}