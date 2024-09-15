// SPDX-License-Identifier: MIT

// 
pragma solidity ^0.8.0;



library CheckAddress {

    /// Check whether an address is a smart contract.
    
    
    
    function isContract(address account) external view returns (bool) {
        return getSize(account) > 0;
    }

    /// Check whether an address is an external wallet.
    
    
    
    function isExternal(address account) external view returns (bool) {
        return getSize(account) == 0;
    }

    /// Get the size of the code of an address
    
    
    
    function getSize(address account) internal view returns (uint256) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size;
    }
}

