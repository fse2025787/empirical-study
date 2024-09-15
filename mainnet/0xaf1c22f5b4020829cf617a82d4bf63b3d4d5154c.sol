// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2022-03-01
*/

// 

pragma solidity ^0.6.0;


contract BadgerBridgeUtils {
    
    function encodeUserParams(
        // user args
        address _token, // either renBTC or wBTC
        uint256 _slippage,
        address _user,
        address _vault
    ) external pure returns (bytes memory encoded, bytes32 hashed) {
        encoded = abi.encode(_token, _slippage, _user, _vault);
        hashed = keccak256(encoded);
    }
}