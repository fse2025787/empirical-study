// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-10-02
*/

// 
pragma solidity 0.6.12;

contract Migrations {
  address public owner;
  uint public lastCompletedMigration;

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  constructor() public {
    owner = msg.sender;
  }

  function setCompleted(uint completed) public restricted {
    lastCompletedMigration = completed;
  }
}