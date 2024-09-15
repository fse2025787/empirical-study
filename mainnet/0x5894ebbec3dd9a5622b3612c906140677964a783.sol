// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-07-16
*/

// 

pragma solidity ^0.6.12;

contract Timestamp {
    event ShowTimestamp(uint _timestamp);

    function getNowTimestamp() public view returns (uint) {
        return now;
    }

    function timestamp() public {
        emit ShowTimestamp(now);
    }
}