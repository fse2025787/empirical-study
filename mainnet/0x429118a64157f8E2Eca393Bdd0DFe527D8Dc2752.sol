// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-07-27
*/

// 

pragma solidity =0.7.6;





contract AdminVault {
    address public owner;
    address public admin;

    constructor() {
        owner = 0xF8f8B3C98Cf2E63Df3041b73f80F362a4cf3A576;
        admin = 0x25eFA336886C74eA8E282ac466BdCd0199f85BB9;
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