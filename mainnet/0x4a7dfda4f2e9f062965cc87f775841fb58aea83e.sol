// SPDX-License-Identifier: GPL-3.0-only

/**
 *Submitted for verification at Etherscan.io on 2021-07-22
*/

// 
pragma solidity ^0.7.5;

// @notice Used to create Radicle Link identity claims
contract Claims {
    
    
    event Claimed(address indexed addr);

    
    /// Every new claim invalidates previous ones made with the same account.
    /// The claims have no expiration date and don't need to be renewed.
    /// If either `format` is unsupported or `payload` is malformed as per `format`,
    /// the previous claim is revoked, but a new one isn't created.
    /// Don't send a malformed transactions on purpose, to properly revoke a claim see `format`.
    
    /// - `1` - `payload` is exactly 20 bytes and contains an SHA-1 Radicle Identity root hash
    /// - `2` - `payload` is exactly 32 bytes and contains an SHA-256 Radicle Identity root hash
    /// To revoke a claim without creating a new one, pass payload `0`,
    /// which is guaranteed to not match any existing identity.
    
    function claim(uint256 format, bytes calldata payload) public {
        format;
        payload;
        emit Claimed(msg.sender);
    }
}