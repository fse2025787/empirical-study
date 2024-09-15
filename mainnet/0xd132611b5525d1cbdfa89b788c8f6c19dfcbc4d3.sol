// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-07-16
*/

// 
pragma solidity ^0.8.1;



interface IProxy {
    function masterCopy() external view returns (address);
}




contract YieldsterVaultProxy {
    // masterCopy always needs to be first declared variable, to ensure that it is at the same location in the contracts to which calls are delegated.
    // To reduce deployment costs this variable is internal and needs to be retrieved via `getStorageAt`
    address internal masterCopy;

    
    
    constructor(address _masterCopy)  {
        require(
            _masterCopy != address(0),
            "Invalid master copy address provided"
        );
        masterCopy = _masterCopy;
    }

    
    fallback() external payable {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let _masterCopy := and(
                sload(0),
                0xffffffffffffffffffffffffffffffffffffffff
            )
            // 0xa619486e == keccak("masterCopy()"). The value is right padded to 32-bytes with 0s
            if eq(
                calldataload(0),
                0xa619486e00000000000000000000000000000000000000000000000000000000
            ) {
                mstore(0, _masterCopy)
                return(0, 0x20)
            }
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(
                gas(),
                _masterCopy,
                0,
                calldatasize(),
                0,
                0
            )
            returndatacopy(0, 0, returndatasize())
            if eq(success, 0) {
                revert(0, returndatasize())
            }
            return(0, returndatasize())
        }
    }
}