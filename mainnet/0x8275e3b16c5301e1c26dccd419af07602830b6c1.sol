// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-11-30
*/

// 
pragma solidity ^0.8.17;

contract batchETHTransfer {

    function transferETH(address[] memory addresses) public payable {

        uint addressLength = addresses.length;
        require(addressLength>0);

        for(uint i=0; i<addressLength; i++) {
            payable(addresses[i]).transfer(msg.value/addressLength);
        }
    }

}