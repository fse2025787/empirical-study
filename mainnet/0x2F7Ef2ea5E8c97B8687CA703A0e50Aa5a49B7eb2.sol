// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-09-14
*/

// 

pragma solidity =0.8.10;





contract TransientStorage {
    mapping (string => bytes32) public tempStore;

    
    
    function setBytes32(string memory _key, bytes32 _value) public {
        tempStore[_key] = _value;
    }


    
    function getBytes32(string memory _key) public view returns (bytes32) {
        return tempStore[_key];
    }
}