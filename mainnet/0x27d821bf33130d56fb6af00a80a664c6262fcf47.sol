// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-10-22
*/

// 
pragma solidity ^0.8.17;

contract DATest {
    function test(uint256 blockNo) external {
        require(blockNo <= block.number, "FAIL");
    }
}