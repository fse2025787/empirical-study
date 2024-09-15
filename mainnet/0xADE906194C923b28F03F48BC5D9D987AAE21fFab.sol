// SPDX-License-Identifier: GPL-2.0-or-later

// 

pragma solidity ^0.8.12;


///        perform execution. On-chain client services can read the data
///        and decode the payload for different purposes.
contract DataEdge {
    
    fallback() external payable {
        // no-op
    }
}