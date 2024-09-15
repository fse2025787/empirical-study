// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-03-06
*/

// 

pragma solidity 0.6.12;


interface ISushiSwapETH {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}


contract ShwapETH {
    address constant sushiToken = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2; // SUSHI token contract 
    address constant wETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Wrapped ETH token contract
    ISushiSwapETH constant sushiETHpair = ISushiSwapETH(0x795065dCc9f64b5614C407a6EFDC400DA6221FB0); // SUSHI/ETH pair for SushiSwap
    ISushiSwapETH constant sushiSwapRouter = ISushiSwapETH(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F); // SushiSwap router contract
    
    
    receive() external payable {
        (uint256 reserve0, uint256 reserve1, ) = sushiETHpair.getReserves(); // get `sushiETHpair` reserve balances for rate calculation
        uint256 sushiOutMin = msg.value * (reserve0 / reserve1) 
        - msg.value * ((reserve0 / reserve1) / 200); // calculate minimum SUSHI return with 0.5% slippage threshold based on `msg.value` ETH
        address[] memory path = new address[](2); // load SUSHI/ETH `path` for router
        path[0] = address(wETH);
        path[1] = address(sushiToken);
        sushiSwapRouter.swapExactETHForTokens{value: msg.value}
        (sushiOutMin, path, msg.sender, block.timestamp + 1200); // stage swap tx in router with 20 minute deadline
    }
}