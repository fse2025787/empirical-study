// SPDX-License-Identifier: GPL-3.0-or-later
pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2021-04-30
*/

// File: iface/IERC20.sol

// 
pragma solidity ^0.6.12;

interface IERC20 {
	function decimals() external view returns (uint8);
	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// File: lib/SafeMath.sol


pragma solidity ^0.6.12;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }

    function div(uint x, uint y) internal pure returns (uint z) {
        require(y > 0, "ds-math-div-zero");
        z = x / y;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    }
}
// File: iface/INTokenController.sol

pragma solidity ^0.6.12;


interface INTokenController {
    
    
    
    function getNTokenAddress(address tokenAddress) external view returns (address);
}
// File: iface/INestPriceFacade.sol

pragma solidity ^0.6.12;


interface INestPriceFacade {
	
    struct Config {

        // Single query fee（0.0001 ether, DIMI_ETHER). 100
        uint16 singleFee;

        // Double query fee（0.0001 ether, DIMI_ETHER). 100
        uint16 doubleFee;

        // The normal state flag of the call address. 0
        uint8 normalFlag;
    }
    
    
    function getConfig() external view returns (Config memory);

    
    
    
    
    
    
    
    ///         the volatility cannot exceed 1. Correspondingly, when the return value is equal to 999999999999996447, 
    ///         it means that the volatility has exceeded the range that can be expressed
    
    
    
    
    ///         the volatility cannot exceed 1. Correspondingly, when the return value is equal to 999999999999996447,
    ///         it means that the volatility has exceeded the range that can be expressed
    function triggeredPriceInfo2(address tokenAddress, address paybackAddress) external payable returns (uint blockNumber, uint price, uint avgPrice, uint sigmaSQ, uint ntokenBlockNumber, uint ntokenPrice, uint ntokenAvgPrice, uint ntokenSigmaSQ);

    
    
    
    
    
    
    
    ///         the volatility cannot exceed 1. Correspondingly, when the return value is equal to 999999999999996447,
    ///         it means that the volatility has exceeded the range that can be expressed
    function triggeredPriceInfo(address tokenAddress, address paybackAddress) external payable returns (uint blockNumber, uint price, uint avgPrice, uint sigmaSQ);



}
// File: PriceController.sol

pragma solidity ^0.6.12;



contract PriceController {
	using SafeMath for uint256;

	// Nest price contract
    INestPriceFacade nestPriceFacade;
    // NTokenController
    INTokenController ntokenController;

    
    
    
	constructor (address _nestPriceFacade, address _ntokenController) public {
		nestPriceFacade = INestPriceFacade(_nestPriceFacade);
        ntokenController = INTokenController(_ntokenController);
    }

    
    
    
    function checkNToken(address tokenOne, address tokenTwo) public view returns(bool) {
        if (ntokenController.getNTokenAddress(tokenOne) == tokenTwo) {
            return true;
        }
        return false;
    }

    
    
    
    
    
    function getDecimalConversion(address inputToken, 
    	                          uint256 inputTokenAmount, 
    	                          address outputToken) public view returns(uint256) {
    	uint256 inputTokenDec = 18;
    	uint256 outputTokenDec = 18;
    	if (inputToken != address(0x0)) {
    		inputTokenDec = IERC20(inputToken).decimals();
    	}
    	if (outputToken != address(0x0)) {
    		outputTokenDec = IERC20(outputToken).decimals();
    	}
    	return inputTokenAmount.mul(10**outputTokenDec).div(10**inputTokenDec);
    }

    
    
    
    
    
    
    function getPriceForPToken(address token, 
                               address uToken,
                               address payback) public payable returns (uint256 tokenPrice, 
                                                                        uint256 pTokenPrice) {
        if (token == address(0x0)) {
            // The mortgage asset is ETH，get ERC20-ETH price
            (,,uint256 avg,) = nestPriceFacade.triggeredPriceInfo{value:msg.value}(uToken, payback);
            require(avg > 0, "Log:PriceController:!avg1");
            return (1 ether, getDecimalConversion(uToken, avg, address(0x0)));
        } else if (uToken == address(0x0)) {
            // The underlying asset is ETH，get ERC20-ETH price
            (,,uint256 avg,) = nestPriceFacade.triggeredPriceInfo{value:msg.value}(token, payback);
            require(avg > 0, "Log:PriceController:!avg2");
            return (getDecimalConversion(uToken, avg, address(0x0)), 1 ether);
        } else {
            // Get ERC20-ERC20 price
            if (checkNToken(token, uToken)) {
                (,,uint256 avg1,,,,uint256 avg2,) = nestPriceFacade.triggeredPriceInfo2{value:msg.value}(token, payback);
                require(avg1 > 0 && avg2 > 0, "Log:PriceController:!avg3");
                return (avg1, getDecimalConversion(uToken, avg2, address(0x0)));
            } else if (checkNToken(uToken, token)) {
                (,,uint256 avg1,,,,uint256 avg2,) = nestPriceFacade.triggeredPriceInfo2{value:msg.value}(uToken, payback);
                require(avg1 > 0 && avg2 > 0, "Log:PriceController:!avg4");
                return (avg2, getDecimalConversion(uToken, avg1, address(0x0)));
            } else {
                (,,uint256 avg1,) = nestPriceFacade.triggeredPriceInfo{value:uint256(msg.value).div(2)}(token, payback);
                (,,uint256 avg2,) = nestPriceFacade.triggeredPriceInfo{value:uint256(msg.value).div(2)}(uToken, payback);
                require(avg1 > 0 && avg2 > 0, "Log:PriceController:!avg5");
                return (avg1, getDecimalConversion(uToken, avg2, address(0x0)));
            }
        }
    }
}