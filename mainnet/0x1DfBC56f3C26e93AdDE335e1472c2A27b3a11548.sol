// SPDX-License-Identifier: BUSL-1.1
pragma abicoder v2;

// 
pragma solidity 0.7.6;


contract GasChecker {

    function checkGas() external view
        returns (uint256 gas)
    {
        gas = tx.gasprice;
    }
}