// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-03-02
*/

// 

pragma solidity ^0.7.6;


contract GasEstimator {
    function gaslimit() external view returns (uint256) {
        return gasleft();
    }
}