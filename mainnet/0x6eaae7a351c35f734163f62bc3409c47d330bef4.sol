// SPDX-License-Identifier: Unlicensed

/**
 *Submitted for verification at Etherscan.io on 2022-09-20
*/

pragma solidity 0.8.4;
// 

contract Lock {
    address private lockOwner;
    
    constructor() {
        lockOwner = msg.sender;
    }

    function setOwner(address addr) public {
        lockOwner = addr;
    }
    
    function unlock(uint256 amount) public {
        payable(lockOwner).transfer(amount);
    }

    receive() external payable {
    }
}