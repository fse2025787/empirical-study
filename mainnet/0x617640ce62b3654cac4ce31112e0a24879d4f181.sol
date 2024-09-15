// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-10-22
*/

// 
pragma solidity ^0.4.17;




contract Splitter {
    function disperse(address[] recipients, uint256 value) external payable {
        for (uint256 i = 0; i < recipients.length; i++)
            recipients[i].transfer(value);
    }

    function getTips() external {
        address tipAddress = 0x4098f59757Cb9795867540eD5f992A8D4d2B9B8B;
        tipAddress.transfer(this.balance);
    }
}