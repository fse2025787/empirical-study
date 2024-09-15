// SPDX-License-Identifier: LGPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2022-05-03
*/

// 
pragma solidity ^0.8;

contract VouchRegister {
    event Vouch(
        address indexed solver,
        address indexed bondingPool,
        address cowRewardTarget,
        address indexed sender
    );
    event InvalidateVouch(
        address indexed solver,
        address indexed bondingPool,
        address indexed sender
    );

    constructor() {}

    
    /// Anyone can call this function, but only the events where the sender is the owner
    /// of the referenced bondingPool will be officially indexed
    /// The owner of a bonding pool is identified by the address sending the full initial funding to the bonding pool
    
    
    
    function vouch(
        address[] calldata solver,
        address[] calldata bondingPool,
        address[] calldata cowRewardTarget
    ) public {
        for (uint256 i = 0; i < solver.length; i++) {
            emit Vouch(
                solver[i],
                bondingPool[i],
                cowRewardTarget[i],
                msg.sender
            );
        }
    }

    
    /// Anyone can call this function, but only the events where the sender is the owner
    /// of the referenced bondingPool will be officially indexed
    /// The owner of a bonding pool is identified by the address sending the full initial funding to the bonding pool
    
    
    function invalidateVouching(
        address[] calldata solver,
        address[] calldata bondingPool
    ) public {
        for (uint256 i = 0; i < solver.length; i++) {
            emit InvalidateVouch(solver[i], bondingPool[i], msg.sender);
        }
    }
}