// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;

// 
pragma solidity ^0.6.12;


contract RewardProgram {
    event AddLink (address indexed ethereumAddress, string target, bytes signature, string message);

    function linkAddresses(string memory target, bytes memory signature, string memory message) public {
        emit AddLink(msg.sender, target, signature, message);
    }
}