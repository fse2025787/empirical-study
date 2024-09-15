// SPDX-License-Identifier: UNLICENSED

/**
 *Submitted for verification at Etherscan.io on 2022-06-19
*/

// 

pragma solidity >=0.8.15;



contract FlashLoanLaGrig {
    event DaiAmount(uint256 daiAmount);
    event UsdcAmount(uint256 usdcAmount);

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external {
        emit DaiAmount(amount0);
        emit UsdcAmount(amount1);
    }
}