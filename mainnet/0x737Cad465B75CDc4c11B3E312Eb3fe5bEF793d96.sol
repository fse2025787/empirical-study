// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2022-11-30
*/

/**
 * 
 **/

pragma solidity ^0.8.17;


interface IWETH {
    function withdraw(uint256) external;
    function balanceOf(address) external returns (uint256);
}




contract UnwrapAndSendETH {
    receive() external payable {}

    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    
    
    function unwrapAndSendETH(address to) external {
        uint256 wethBalance = IWETH(WETH).balanceOf(address(this));
        require(wethBalance > 0, "Insufficient WETH");
        IWETH(WETH).withdraw(wethBalance);
        (bool success, ) = to.call{value: address(this).balance}(
            new bytes(0)
        );
        require(success, "Eth transfer Failed.");
    }
}