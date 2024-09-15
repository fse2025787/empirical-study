// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-04-19
*/

//
/**** 
***** this code and any deployments of this code are strictly provided as-is; no guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of the code 
***** or any smart contracts or other software deployed from these files, in accordance with the disclosures and licenses found here: https://github.com/V4R14/firm_utils/blob/main/LICENSE
***** this code is not audited, and users, developers, or adapters of these files should proceed with caution and use at their own risk.
****/

pragma solidity >=0.8.4;




interface IUniswapV2Router02 {
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);
}

contract PayInETHtoGUSD {

    address constant GUSD_ADDR = 0x056Fd409E1d7A124BD7017459dFEa2F387b6d5Cd; // GUSD mainnet token contract address
    address constant UNI_ROUTER_ADDR = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Uniswap v2 router contract address
    address constant WETH_ADDR = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH mainnet token address, alteratively could call uniRouter.WETH() for the path
    address receiver; 

    IUniswapV2Router02 public uniRouter;

    error CallerNotCurrentReceiver();

    constructor() payable {
        uniRouter = IUniswapV2Router02(UNI_ROUTER_ADDR);
        receiver = msg.sender;
    }

    
    receive() external payable {
        uniRouter.swapExactETHForTokens{ value: msg.value }(0, _getPathForETHtoGUSD(), receiver, block.timestamp);
    }

    
    function _getPathForETHtoGUSD() internal pure returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = WETH_ADDR;
        path[1] = GUSD_ADDR;
        return path;
    }
    
    
    
    
    function changeReceiver(address _newReceiver) external returns (address) {
        if (msg.sender != receiver) revert CallerNotCurrentReceiver();
        receiver = _newReceiver;
        return (receiver);
    }
}