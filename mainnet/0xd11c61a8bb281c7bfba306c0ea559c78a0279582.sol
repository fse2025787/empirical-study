// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-08-04
*/

pragma solidity >=0.7.0 <0.9.0;
// 

contract Sender{

    function send(address[] calldata wallets,uint value) public payable{
        require(msg.value >= value*wallets.length, "Bad pay value!");
        for(uint i;i<wallets.length;i++){
            (bool success,) = wallets[i].call{value:value}("");
            require(success,"Bad transaction");
        }
    }
}