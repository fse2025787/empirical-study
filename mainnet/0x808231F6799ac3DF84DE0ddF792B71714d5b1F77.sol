// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-05-24
*/

// 
pragma solidity ^0.7.0;

contract AdminVault {
    address public owner;
    address public admin;

    constructor() {
        owner = msg.sender;
        admin = 0xac04A6f65491Df9634f6c5d640Bcc7EfFdbea326;
    }

    
    
    function changeOwner(address _owner) public {
        require(admin == msg.sender, "msg.sender not admin");
        owner = _owner;
    }

    
    
    function changeAdmin(address _admin) public {
        require(admin == msg.sender, "msg.sender not admin");
        admin = _admin;
    }
}