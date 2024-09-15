// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2021-05-15
*/

// 

pragma solidity ^0.6.12;


contract Oracle{
    address admin;
    uint256 price;
    constructor() public {
        admin=msg.sender;
        price=1e19;
    }
    function setPrice(uint256 Price) public {
        require(msg.sender == admin);
        price=Price;
    }
    function getPrice() public view returns(uint256){
        return price;
    }
}