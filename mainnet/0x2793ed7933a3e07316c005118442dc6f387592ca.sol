// SPDX-License-Identifier: UNLICENSED

// 
pragma solidity ^0.8.13;


contract FakeTransfer {
  event Transfer(address indexed from, address indexed to, uint);

  function fakeTransfer() public returns(uint) {
    emit Transfer(msg.sender, address(this),  block.number);
    return block.number;
  }
}