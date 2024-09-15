// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2023-01-17
*/

// 

pragma solidity ^0.8.0;

contract Counter {
    uint256 internal counter;
    function increment() external {
        unchecked {
            ++counter;
        }
    }

    function getCurrent() external view returns(uint256) {
        return counter;
    }
}