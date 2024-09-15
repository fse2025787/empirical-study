// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-05-14
*/

// File: contracts/Migrations.sol

// 
pragma solidity ^0.8.0;

contract Migrations {
  address public owner;
  uint public last_completed_migration;

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  constructor() {
    owner = msg.sender;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }
}