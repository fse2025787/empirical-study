
/**
 *Submitted for verification at Etherscan.io on 2021-04-21
*/

pragma solidity ^0.7.6;




contract PoolTest {
    uint public swapFeePercentage;
    function setSwapFeePercentage(uint256 _swapFeePercentage) public {
        swapFeePercentage = _swapFeePercentage;
    }
    function getSwapFeePercentage() view public returns (uint256){
        return swapFeePercentage;
    }
}