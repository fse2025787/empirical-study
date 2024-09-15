// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-05-27
*/

// 

pragma solidity ^0.8.0;

contract EraxTools{

    function hashToSign(bytes32 hash32) external pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash32));
    }
}