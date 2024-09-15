// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-02-19
*/

// 
// 13 February 2021
pragma solidity ^0.7.0;


contract UpgradableProxy 
{
    
    address public implementation;

    constructor(address _implementation) {
        implementation = _implementation;
    }

    
    /// call.
    fallback() external payable {
        // CG: using this assembly instead of the delegate call of solidity allows us to return values in this 
        // fallback function.
        assembly
        {
            let _target := sload(0)
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(gas(), _target, 0x0, calldatasize(), 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize())
            switch result case 0 {revert(0, returndatasize())} default {return (0, returndatasize())}
        }
    }
}