// SPDX-License-Identifier: GNU AGPLv3

/**
 *Submitted for verification at Etherscan.io on 2022-08-19
*/

// 
pragma solidity 0.8.16;



contract MectSwapApprover {
    /// EVENTS ///

    
    
    
    event ApprovalSet(address indexed approver, bool approval);

    /// STORAGE ///

    mapping(address => bool) public approvals; // Approvals. approver -> approval

    /// EXTERNAL ///

    
    
    function setApproval(bool _approval) external {
        approvals[msg.sender] = _approval;

        emit ApprovalSet({ approver: msg.sender, approval: _approval });
    }
}