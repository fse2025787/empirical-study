// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-03-25
*/

// 

pragma solidity 0.7.6;

contract Migrations {
    address public owner = msg.sender;
    uint public last_completed_migration;

    modifier restricted() {
        require(
            msg.sender == owner,
            "This function is restricted to the contract's owner"
        );
        _;
    }

    function setCompleted(uint completed) public restricted {
        last_completed_migration = completed;
    }
}