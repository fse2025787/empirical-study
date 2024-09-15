// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-11-01
*/

//
/*****
 ***** this code and any deployments of this code are strictly provided as-is;
 ***** no guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of the code
 ***** or any smart contracts or other software deployed from these files
 ***** this code is not audited, and users, developers, or adapters should proceed with caution and use at their own risk.
 ****/

pragma solidity >=0.8.16;


/** @notice simple programmatic token burn of excess USDC revenue per API3 whitepaper: uses AMM DEX 
 *** to swap half of USDC held by this contract for API3 tokens, half for ETH, to LP;
 *** entire LP is redeemable to this contract after one year, then burns all remaining API3 tokens via the token contract;
 *** also auto-swaps any ETH sent directly to this contract for API3 tokens, which are then burned via the token contract */

/// swapUSDCToAPI3AndBurn() may be called to swap all held USDC and ETH to API3, and burn all API3

interface IUniswapV2Router02 {
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IAPI3 {
    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function burn(uint256 amount) external;

    function updateBurnerStatus(bool burnerStatus) external;
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);
}

contract SwapUSDCAndBurnAPI3 {
    struct Liquidity {
        uint32 withdrawTime;
        uint224 amount;
    }

    address public constant API3_TOKEN_ADDR =
        0x0b38210ea11411557c13457D4dA7dC6ea731B88a;
    address public constant LP_TOKEN_ADDR =
        0x4Dd26482738bE6C06C31467a19dcdA9AD781e8C4;
    address public constant UNI_ROUTER_ADDR =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant USDC_TOKEN_ADDR =
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant WETH_TOKEN_ADDR =
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IUniswapV2Router02 public v2Router;
    IAPI3 public iAPI3Token;
    IERC20 public iUSDCToken;
    IERC20 public iLPToken;

    uint256 public lpAddIndex;
    uint256 public lpRedeemIndex;
    mapping(uint256 => Liquidity) public liquidityAdds;

    error NoAPI3Tokens();
    error NoRedeemableLPTokens();
    error NoUSDCTokens();

    event API3Burned(uint256 amountBurned);
    event LiquidityProvided(uint256 liquidityAdded, uint256 indexed lpIndex);
    event LiquidityRemoved(uint256 liquidityRemoved, uint256 indexed lpIndex);

    constructor() payable {
        address uniRouter = UNI_ROUTER_ADDR;
        v2Router = IUniswapV2Router02(uniRouter);
        iAPI3Token = IAPI3(API3_TOKEN_ADDR);
        iUSDCToken = IERC20(USDC_TOKEN_ADDR);
        iLPToken = IERC20(LP_TOKEN_ADDR);
        iAPI3Token.updateBurnerStatus(true);
        iAPI3Token.approve(uniRouter, type(uint256).max);
        iUSDCToken.approve(uniRouter, type(uint256).max);
        iLPToken.approve(uniRouter, type(uint256).max);
    }

    
    /// also useful for burning any leftover/dust API3 tokens held by or sent to this contract
    receive() external payable {
        if (msg.sender != UNI_ROUTER_ADDR) {
            v2Router.swapExactETHForTokens{value: msg.value}(
                1,
                _getPathForETHtoAPI3(),
                address(this),
                block.timestamp
            );
            _burnAPI3();
        } else {}
    }

    
    
    function swapUSDCToAPI3AndBurn() external {
        uint256 usdcBal = iUSDCToken.balanceOf(address(this));
        if (usdcBal == 0) revert NoUSDCTokens();
        v2Router.swapExactTokensForETH(
            usdcBal,
            0,
            _getPathForUSDCtoETH(),
            payable(address(this)),
            block.timestamp
        );
        v2Router.swapExactETHForTokens{value: (address(this).balance)}(
            1,
            _getPathForETHtoAPI3(),
            address(this),
            block.timestamp
        );
        _burnAPI3();
    }

    
    
    function swapUSDCToAPI3AndLpAndBurn() external {
        uint256 usdcBal = iUSDCToken.balanceOf(address(this));
        if (usdcBal == 0) revert NoUSDCTokens();
        v2Router.swapExactTokensForETH(
            usdcBal,
            0,
            _getPathForUSDCtoETH(),
            payable(address(this)),
            block.timestamp
        );
        v2Router.swapExactETHForTokens{value: (address(this).balance / 2)}(
            0,
            _getPathForETHtoAPI3(),
            address(this),
            block.timestamp
        );
        _lpApi3Eth();
    }

    /** @dev checks earliest Liquidity struct to see if any LP tokens are redeemable,
     ** then redeems that amount of liquidity to this address (which is entirely converted and burned in API3 tokens via _burnAPI3()),
     ** then deletes that mapped struct in liquidityAdds[] and increments the lpRedeemIndex */
    
    function redeemLP() external {
        Liquidity memory liquidity = liquidityAdds[lpRedeemIndex];
        if (uint256(liquidity.withdrawTime) > block.timestamp)
            revert NoRedeemableLPTokens();
        uint256 _redeemableLpTokens = uint256(liquidity.amount);
        if (_redeemableLpTokens == 0) {
            delete liquidityAdds[lpRedeemIndex];
            unchecked {
                ++lpRedeemIndex;
            }
        } else {
            _redeemLP(_redeemableLpTokens);
        }
    }

    /** @dev checks applicable Liquidity struct to see if any LP tokens are redeemable,
     ** then redeems that amount of liquidity to this address (which is entirely converted and burned in API3 tokens via _burnAPI3()),
     ** then deletes that mapped struct in liquidityAdds[]. Implemented in case of lpAddIndex--lpRedeemIndex mismatch */
    
    
    function redeemSpecificLP(uint256 _lpRedeemIndex) external {
        Liquidity memory liquidity = liquidityAdds[_lpRedeemIndex];
        if (uint256(liquidity.withdrawTime) > block.timestamp)
            revert NoRedeemableLPTokens();
        uint256 _redeemableLpTokens = uint256(liquidity.amount);
        if (_redeemableLpTokens == 0) {
            delete liquidityAdds[_lpRedeemIndex];
        } else {
            _redeemSpecificLP(_redeemableLpTokens, _lpRedeemIndex);
        }
    }

    
    function _burnAPI3() internal {
        uint256 api3Bal = iAPI3Token.balanceOf(address(this));
        if (api3Bal == 0) revert NoAPI3Tokens();
        iAPI3Token.burn(api3Bal);
        emit API3Burned(api3Bal);
    }

    
    
    function _lpApi3Eth() internal {
        uint256 api3Bal = iAPI3Token.balanceOf(address(this));
        if (api3Bal == 0) revert NoAPI3Tokens();
        uint256 ethBal = address(this).balance;
        (, , uint256 liquidity) = v2Router.addLiquidityETH{value: ethBal}(
            API3_TOKEN_ADDR,
            api3Bal,
            ((api3Bal * 9) / 10), // 90% of the api3Bal
            ((ethBal * 9) / 10), // 90% of the ethBal
            payable(address(this)),
            block.timestamp
        );
        emit LiquidityProvided(liquidity, lpAddIndex);
        liquidityAdds[lpAddIndex] = Liquidity(
            uint32(block.timestamp + 31557600),
            uint224(liquidity)
        );
        unchecked {
            ++lpAddIndex;
        }
    }

    
    function _redeemLP(uint256 _redeemableLpTokens) internal {
        v2Router.removeLiquidityETH(
            API3_TOKEN_ADDR,
            _redeemableLpTokens,
            0,
            0,
            payable(address(this)),
            block.timestamp
        );
        delete liquidityAdds[lpRedeemIndex];
        emit LiquidityRemoved(_redeemableLpTokens, lpRedeemIndex);
        unchecked {
            ++lpRedeemIndex;
        }
        v2Router.swapExactETHForTokens{value: address(this).balance}(
            1,
            _getPathForETHtoAPI3(),
            address(this),
            block.timestamp
        );
        _burnAPI3();
    }

    
    function _redeemSpecificLP(
        uint256 _redeemableLpTokens,
        uint256 _lpRedeemIndex
    ) internal {
        v2Router.removeLiquidityETH(
            API3_TOKEN_ADDR,
            _redeemableLpTokens,
            0,
            0,
            payable(address(this)),
            block.timestamp
        );
        delete liquidityAdds[_lpRedeemIndex];
        emit LiquidityRemoved(_redeemableLpTokens, _lpRedeemIndex);
        v2Router.swapExactETHForTokens{value: address(this).balance}(
            1,
            _getPathForETHtoAPI3(),
            address(this),
            block.timestamp
        );
        _burnAPI3();
    }

    
    function _getPathForETHtoAPI3() internal pure returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = WETH_TOKEN_ADDR;
        path[1] = API3_TOKEN_ADDR;
        return path;
    }

    
    function _getPathForUSDCtoETH() internal pure returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = USDC_TOKEN_ADDR;
        path[1] = WETH_TOKEN_ADDR;
        return path;
    }
}