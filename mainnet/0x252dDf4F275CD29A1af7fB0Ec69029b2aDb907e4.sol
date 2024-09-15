// SPDX-License-Identifier: MPL-2.0

/// 

pragma solidity =0.8.15;




contract SecureRpcProvider {

   
   function getCurrentBlockTimestamp() public view returns (uint256 timestamp) {
        timestamp = block.timestamp;
    }
    
    
    function blockGaslimit() external view returns (uint256) {
        return block.gaslimit;
    }
    
    function blockNumber() external view returns (uint256) {
        return block.number;
    }

    
    function blockTimestamp() external view returns (uint256) {
        return block.timestamp;
    }
    
    
    function isSecureRpcProvider() external view returns (bool) {
        return false;
    }

    
    function getBlockTimeStamp() external view returns (uint256) {
        return block.timestamp;
    }
    

    
    function getChainId() external view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }
}