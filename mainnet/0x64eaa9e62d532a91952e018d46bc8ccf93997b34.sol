// SPDX-License-Identifier: UNLICENSED

/**
 *Submitted for verification at Etherscan.io on 2021-02-23
*/

// 

pragma solidity ^0.8.0;

contract Verifier {

  event Verification(uint _uid);

  function verify(uint _uid) public {
    emit Verification(_uid);
  }
}