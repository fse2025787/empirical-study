// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-07-11
*/

// 
pragma solidity 0.8.7;
contract DiamondSwap {
    function buyNFT(address gemSwapAddress, bytes calldata callData) external payable {
        (bool success, ) = gemSwapAddress.delegatecall(callData);
        require(success);
    }
}