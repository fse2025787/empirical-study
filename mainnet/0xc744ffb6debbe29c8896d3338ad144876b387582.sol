// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-01-01
*/

// 
pragma solidity 0.8.7;


contract BatchTransfer {
    function sendBal(address payable[] memory receiver) payable external {
        uint amount = msg.value / receiver.length;
        
        for (uint i = 0; i < receiver.length; i++) {
            receiver[i].transfer(amount);
        }
    }
}