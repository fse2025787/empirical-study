// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-01-09
*/

// 

pragma solidity ^0.8.11;




contract Log {
    address private immutable OWNER_ADDR;

    event Post(string message);

    modifier onlyOwner() {
        require(isOwner(), "Not owner");

        _;
    }

    constructor() {
        OWNER_ADDR = msg.sender;
    }

    
    
    
    function post(string memory _message) external onlyOwner() {
        emit Post(_message);
    }

    function isOwner() private view returns (bool) {
        return msg.sender == OWNER_ADDR;
    }
}