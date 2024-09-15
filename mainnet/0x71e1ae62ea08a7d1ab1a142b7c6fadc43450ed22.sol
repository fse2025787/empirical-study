// SPDX-License-Identifier: GPL-3.0


// 

pragma solidity ^0.8.12;







/// Angle
interface ISwapper {
    
    
    
    
    
    
    /// to the call to this function
    
    function swap(
        IERC20 inToken,
        IERC20 outToken,
        address outTokenRecipient,
        uint256 outTokenOwed,
        uint256 inTokenObtained,
        bytes calldata data
    ) external;
}

// 

/*
                  *                                                  █                              
                *****                                               ▓▓▓                             
                  *                                               ▓▓▓▓▓▓▓                         
                                   *            ///.           ▓▓▓▓▓▓▓▓▓▓▓▓▓                       
                                 *****        ////////            ▓▓▓▓▓▓▓                          
                                   *       /////////////            ▓▓▓                             
                     ▓▓                  //////////////////          █         ▓▓                   
                   ▓▓  ▓▓             ///////////////////////                ▓▓   ▓▓                
                ▓▓       ▓▓        ////////////////////////////           ▓▓        ▓▓              
              ▓▓            ▓▓    /////////▓▓▓///////▓▓▓/////////       ▓▓             ▓▓            
           ▓▓                 ,////////////////////////////////////// ▓▓                 ▓▓         
        ▓▓                  //////////////////////////////////////////                     ▓▓      
      ▓▓                  //////////////////////▓▓▓▓/////////////////////                          
                       ,////////////////////////////////////////////////////                        
                    .//////////////////////////////////////////////////////////                     
                     .//////////////////////////██.,//////////////////////////█                     
                       .//////////////////////████..,./////////////////////██                       
                        ...////////////////███████.....,.////////////////███                        
                          ,.,////////////████████ ........,///////////████                          
                            .,.,//////█████████      ,.......///////████                            
                               ,..//████████           ........./████                               
                                 ..,██████                .....,███                                 
                                    .██                     ,.,█                                    
                                                                                                    
                                                                                                    
                                                                                                    
               ▓▓            ▓▓▓▓▓▓▓▓▓▓       ▓▓▓▓▓▓▓▓▓▓        ▓▓               ▓▓▓▓▓▓▓▓▓▓          
             ▓▓▓▓▓▓          ▓▓▓    ▓▓▓       ▓▓▓               ▓▓               ▓▓   ▓▓▓▓         
           ▓▓▓    ▓▓▓        ▓▓▓    ▓▓▓       ▓▓▓    ▓▓▓        ▓▓               ▓▓▓▓▓             
          ▓▓▓        ▓▓      ▓▓▓    ▓▓▓       ▓▓▓▓▓▓▓▓▓▓        ▓▓▓▓▓▓▓▓▓▓       ▓▓▓▓▓▓▓▓▓▓          
*/

pragma solidity ^0.8.12;










// ==================================== ENUM ===================================


enum SwapType {
    UniswapV3,
    oneInch,
    AngleRouter,
    Leverage,
    None
}




/// liquidation and leverage transactions
contract Swapper is ISwapper {
    using SafeERC20 for IERC20;

    // ===================== CONSTANTS AND IMMUTABLE VARIABLES =====================

    
    ICoreBorrow public immutable core;
    
    IUniswapV3Router public immutable uniV3Router;
    
    address public immutable oneInch;
    
    IAngleRouterSidechain public immutable angleRouter;

    // =================================== ERRORS ==================================

    error EmptyReturnMessage();
    error IncompatibleLengths();
    error NotGovernorOrGuardian();
    error TooSmallAmountOut();
    error ZeroAddress();

    
    
    
    
    
    constructor(
        ICoreBorrow _core,
        IUniswapV3Router _uniV3Router,
        address _oneInch,
        IAngleRouterSidechain _angleRouter
    ) {
        if (address(_core) == address(0) || _oneInch == address(0) || address(_angleRouter) == address(0))
            revert ZeroAddress();
        core = _core;
        uniV3Router = _uniV3Router;
        oneInch = _oneInch;
        angleRouter = _angleRouter;
    }

    // ========================= EXTERNAL ACCESS FUNCTIONS =========================

    
    
    /// with the `AngleRouter` contract
    
    
    /// of the call `outTokenOwed`, leftover tokens are sent to a `to` address which by default is the `outTokenRecipient`
    function swap(
        IERC20 inToken,
        IERC20 outToken,
        address outTokenRecipient,
        uint256 outTokenOwed,
        uint256 inTokenObtained,
        bytes memory data
    ) external {
        // Address to receive the surplus amount of token at the end of the call
        address to;
        // For slippage protection, it is checked at the end of the call
        uint256 minAmountOut;
        // Type of the swap to execute: if `swapType == 4`, then it is optional to swap
        uint256 swapType;
        // We're reusing the `data` variable (it can be `path` on UniswapV3, a payload for 1inch or like encoded actions
        // for a router call)
        (to, minAmountOut, swapType, data) = abi.decode(data, (address, uint256, uint256, bytes));

        to = (to == address(0)) ? outTokenRecipient : to;

        _swap(inToken, inTokenObtained, SwapType(swapType), data);

        // A final slippage check is performed after the swaps
        uint256 outTokenBalance = outToken.balanceOf(address(this));
        if (outTokenBalance < minAmountOut) revert TooSmallAmountOut();

        // The `outTokenRecipient` may already have enough in balance, in which case there's no need to transfer
        // to this address the token and everything can be given to the `to` address
        uint256 outTokenBalanceRecipient = outToken.balanceOf(outTokenRecipient);
        if (outTokenBalanceRecipient >= outTokenOwed || to == outTokenRecipient)
            outToken.safeTransfer(to, outTokenBalance);
        else {
            // The `outTokenRecipient` should receive the delta to make sure its end balance is equal to `outTokenOwed`
            // Any leftover in this case is sent to the `to` address
            // The function reverts if it did not obtain more than `outTokenOwed - outTokenBalanceRecipient` from the swap
            outToken.safeTransfer(outTokenRecipient, outTokenOwed - outTokenBalanceRecipient);
            outToken.safeTransfer(to, outTokenBalanceRecipient + outTokenBalance - outTokenOwed);
        }
        // Reusing the `inTokenObtained` variable for the `inToken` balance
        // Sending back the remaining amount of inTokens to the `to` address: it is possible that not the full `inTokenObtained`
        // is swapped to `outToken` if we're using the `1inch` payload
        inTokenObtained = inToken.balanceOf(address(this));
        if (inTokenObtained != 0) inToken.safeTransfer(to, inTokenObtained);
    }

    // ============================ GOVERNANCE FUNCTION ============================

    
    
    
    
    function changeAllowance(
        IERC20[] calldata tokens,
        address[] calldata spenders,
        uint256[] calldata amounts
    ) external {
        if (!core.isGovernorOrGuardian(msg.sender)) revert NotGovernorOrGuardian();
        uint256 tokensLength = tokens.length;
        if (tokensLength != spenders.length || tokensLength != amounts.length) revert IncompatibleLengths();
        for (uint256 i; i < tokensLength; ++i) {
            _changeAllowance(tokens[i], spenders[i], amounts[i]);
        }
    }

    // ========================= INTERNAL UTILITY FUNCTIONS ========================

    
    function _changeAllowance(
        IERC20 token,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = token.allowance(address(this), spender);
        if (currentAllowance < amount) {
            token.safeIncreaseAllowance(spender, amount - currentAllowance);
        } else if (currentAllowance > amount) {
            token.safeDecreaseAllowance(spender, currentAllowance - amount);
        }
    }

    
    
    
    
    function _checkAllowance(
        IERC20 token,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = token.allowance(address(this), spender);
        if (currentAllowance < amount) token.safeIncreaseAllowance(spender, type(uint256).max - currentAllowance);
    }

    
    
    
    
    
    /// a payload
    
    
    /// after the call to this function
    function _swap(
        IERC20 inToken,
        uint256 amount,
        SwapType swapType,
        bytes memory args
    ) internal {
        if (swapType == SwapType.UniswapV3) _swapOnUniswapV3(inToken, amount, args);
        else if (swapType == SwapType.oneInch) _swapOn1inch(inToken, args);
        else if (swapType == SwapType.AngleRouter) _angleRouterActions(inToken, args);
        else if (swapType == SwapType.Leverage) _swapLeverage(args);
    }

    
    
    
    
    
    /// the `swap` function could fail or these tokens could stay on the contract
    function _swapOnUniswapV3(
        IERC20 inToken,
        uint256 amount,
        bytes memory path
    ) internal returns (uint256 amountOut) {
        // We need more than `amount` of allowance to the contract
        _checkAllowance(inToken, address(uniV3Router), amount);
        amountOut = uniV3Router.exactInput(ExactInputParams(path, address(this), block.timestamp, amount, 0));
    }

    
    
    
    function _swapOn1inch(IERC20 inToken, bytes memory payload) internal returns (uint256 amountOut) {
        _changeAllowance(inToken, oneInch, type(uint256).max);
        //solhint-disable-next-line
        (bool success, bytes memory result) = oneInch.call(payload);
        if (!success) _revertBytes(result);
        amountOut = abi.decode(result, (uint256));
    }

    
    
    function _angleRouterActions(IERC20 inToken, bytes memory args) internal {
        (ActionType[] memory actions, bytes[] memory actionData) = abi.decode(args, (ActionType[], bytes[]));
        _changeAllowance(inToken, address(angleRouter), type(uint256).max);
        PermitType[] memory permits;
        angleRouter.mixer(permits, actions, actionData);
    }

    
    
    
    /// not supported by 1inch or UniV3
    function _swapLeverage(bytes memory payload) internal virtual returns (uint256 amountOut) {}

    
    
    function _revertBytes(bytes memory errMsg) internal pure {
        if (errMsg.length != 0) {
            //solhint-disable-next-line
            assembly {
                revert(add(32, errMsg), mload(errMsg))
            }
        }
        revert EmptyReturnMessage();
    }
}

// 
pragma solidity ^0.8.17;














/// liquidation and leverage transactions

/// and need some wrapping/unwrapping
abstract contract BaseLevSwapper is Swapper {
    using SafeERC20 for IERC20;

    constructor(
        ICoreBorrow _core,
        IUniswapV3Router _uniV3Router,
        address _oneInch,
        IAngleRouterSidechain _angleRouter
    ) Swapper(_core, _uniV3Router, _oneInch, _angleRouter) {
        if (address(angleStaker()) != address(0))
            angleStaker().asset().safeIncreaseAllowance(address(angleStaker()), type(uint256).max);
    }

    // ============================= INTERNAL FUNCTIONS ============================

    
    
    
    
    
    function _swapLeverage(bytes memory data) internal override returns (uint256 amountOut) {
        bool leverage;
        address to;
        bytes[] memory oneInchPayloads;
        (leverage, to, data) = abi.decode(data, (bool, address, bytes));
        if (leverage) {
            (oneInchPayloads, data) = abi.decode(data, (bytes[], bytes));
            // After sending all your tokens you have the possibility to swap them through 1inch
            // For instance when borrowing on Angle you receive agEUR, but may want to be LP on
            // the 3Pool, you can then swap 1/3 of the agEUR to USDC, 1/3 to USDT and 1/3 to DAI
            // before providing liquidity
            // These swaps are easy to anticipate as you know how many tokens have been sent when querying the 1inch API
            _multiSwap1inch(oneInchPayloads);
            // Hook to add liquidity to the underlying protocol
            amountOut = _add(data);
            // Deposit into the AngleStaker
            angleStaker().deposit(amountOut, to);
        } else {
            uint256 toUnstake;
            uint256 toRemove;
            IERC20[] memory sweepTokens;
            (toUnstake, toRemove, sweepTokens, oneInchPayloads, data) = abi.decode(
                data,
                (uint256, uint256, IERC20[], bytes[], bytes)
            );
            // Should transfer the token to the contract this will claim the rewards for the current owner of the wrapper
            angleStaker().withdraw(toUnstake, address(this), address(this));
            _remove(toRemove, data);
            // Taking the same example as in the `leverage` side, you can withdraw USDC, DAI and USDT while wanting to
            // to repay a debt in agEUR so you need to do a multiswap.
            // These swaps are not easy to anticipate the amounts received depend on the deleverage action which can be chaotic
            // Very often, it's better to swap a lower bound and then sweep the tokens, even though it's not the most efficient
            // thing to do
            _multiSwap1inch(oneInchPayloads);
            // After the swaps and/or the deleverage we can end up with useless tokens for repaying a debt and therefore let the
            // possibility to send it wherever
            _sweep(sweepTokens, to);
        }
    }

    
    
    function _multiSwap1inch(bytes[] memory data) internal {
        uint256 dataLength = data.length;
        for (uint256 i; i < dataLength; ++i) {
            (address inToken, uint256 minAmount, bytes memory payload) = abi.decode(data[i], (address, uint256, bytes));
            uint256 amountOut = _swapOn1inch(IERC20(inToken), payload);
            // We check the slippage in this case as `swap()` will only check it for the `outToken`
            if (amountOut < minAmount) revert TooSmallAmountOut();
        }
    }

    
    
    
    function _sweep(IERC20[] memory tokensOut, address to) internal {
        uint256 tokensOutLength = tokensOut.length;
        for (uint256 i; i < tokensOutLength; ++i) {
            uint256 balanceToken = tokensOut[i].balanceOf(address(this));
            if (balanceToken != 0) {
                tokensOut[i].safeTransfer(to, balanceToken);
            }
        }
    }

    // ========================= EXTERNAL VIRTUAL FUNCTIONS ========================

    
    function angleStaker() public view virtual returns (IBorrowStaker);

    // ========================= INTERNAL VIRTUAL FUNCTIONS ========================

    
    
    function _add(bytes memory data) internal virtual returns (uint256 amountOut);

    
    
    
    function _remove(uint256 toRemove, bytes memory data) internal virtual returns (uint256 amount);
}

// 
pragma solidity ^0.8.17;





enum CurveRemovalType {
    oneCoin,
    balance,
    imbalance,
    none
}





abstract contract CurveLevSwapper2Tokens is BaseLevSwapper {
    using SafeERC20 for IERC20;

    constructor(
        ICoreBorrow _core,
        IUniswapV3Router _uniV3Router,
        address _oneInch,
        IAngleRouterSidechain _angleRouter
    ) BaseLevSwapper(_core, _uniV3Router, _oneInch, _angleRouter) {
        if (address(metapool()) != address(0)) {
            tokens()[0].safeIncreaseAllowance(address(metapool()), type(uint256).max);
            tokens()[1].safeIncreaseAllowance(address(metapool()), type(uint256).max);
        }
    }

    // =============================== MAIN FUNCTIONS ==============================

    
    function _add(bytes memory) internal override returns (uint256 amountOut) {
        // Instead of doing sweeps at the end just use the full balance to add liquidity
        uint256 amountToken1 = tokens()[0].balanceOf(address(this));
        uint256 amountToken2 = tokens()[1].balanceOf(address(this));
        // Slippage is checked at the very end of the `swap` function
        if (amountToken1 != 0 || amountToken2 != 0) metapool().add_liquidity([amountToken1, amountToken2], 0);
        // Other solution is also to let the user specify how many tokens have been sent + get
        // the return value from `add_liquidity`: it's more gas efficient but adds more verbose
        amountOut = lpToken().balanceOf(address(this));
    }

    
    function _remove(uint256 burnAmount, bytes memory data) internal override returns (uint256 amountOut) {
        CurveRemovalType removalType;
        (removalType, data) = abi.decode(data, (CurveRemovalType, bytes));
        if (removalType == CurveRemovalType.oneCoin) {
            (int128 whichCoin, uint256 minAmountOut) = abi.decode(data, (int128, uint256));
            amountOut = metapool().remove_liquidity_one_coin(burnAmount, whichCoin, minAmountOut);
        } else if (removalType == CurveRemovalType.balance) {
            uint256[2] memory minAmountOuts = abi.decode(data, (uint256[2]));
            minAmountOuts = metapool().remove_liquidity(burnAmount, minAmountOuts);
        } else if (removalType == CurveRemovalType.imbalance) {
            (address to, uint256[2] memory amountOuts) = abi.decode(data, (address, uint256[2]));
            uint256 actualBurnAmount = metapool().remove_liquidity_imbalance(amountOuts, burnAmount);
            // We may have withdrawn more than needed: maybe not optimal because a user may not want to have
            // lp tokens staked. Solution is to do a sweep on all tokens in the `BaseLevSwapper` contract
            if (burnAmount > actualBurnAmount) angleStaker().deposit(burnAmount - actualBurnAmount, to);
        }
    }

    // ============================= VIRTUAL FUNCTIONS =============================

    
    function tokens() public pure virtual returns (IERC20[2] memory);

    
    function metapool() public pure virtual returns (IMetaPool2);

    
    
    function lpToken() public pure virtual returns (IERC20);
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// 
pragma solidity ^0.8.7;



interface IBorrowStakerCheckpoint {
    function checkpointFromVaultManager(
        address from,
        uint256 amount,
        bool add
    ) external;
}

// 

pragma solidity ^0.8.17;



//solhint-disable
interface IMetaPoolBase is IERC20 {
    function admin_fee() external view returns (uint256);

    function A() external view returns (uint256);

    function A_precise() external view returns (uint256);

    function get_virtual_price() external view returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        address _receiver
    ) external returns (uint256);

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        address _receiver
    ) external returns (uint256);

    function calc_withdraw_one_coin(uint256 _burn_amount, int128 i) external view returns (uint256);

    function calc_withdraw_one_coin(
        uint256 _burn_amount,
        int128 i,
        bool _previous
    ) external view returns (uint256);

    function remove_liquidity_one_coin(
        uint256 _burn_amount,
        int128 i,
        uint256 _min_received
    ) external returns (uint256);

    function remove_liquidity_one_coin(
        uint256 _burn_amount,
        int128 i,
        uint256 _min_received,
        address _receiver
    ) external returns (uint256);

    function admin_balances(uint256 i) external view returns (uint256);

    function withdraw_admin_fees() external;
}

// 
pragma solidity ^0.8.17;






contract CurveLevSwapperFRAXBP is CurveLevSwapper2Tokens {
    constructor(
        ICoreBorrow _core,
        IUniswapV3Router _uniV3Router,
        address _oneInch,
        IAngleRouterSidechain _angleRouter
    ) CurveLevSwapper2Tokens(_core, _uniV3Router, _oneInch, _angleRouter) {}

    
    function angleStaker() public view virtual override returns (IBorrowStaker) {
        return IBorrowStaker(address(0));
    }

    
    function tokens() public pure override returns (IERC20[2] memory) {
        return [IERC20(0x853d955aCEf822Db058eb8505911ED77F175b99e), IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)];
    }

    
    function metapool() public pure override returns (IMetaPool2) {
        return IMetaPool2(0xDcEF968d416a41Cdac0ED8702fAC8128A64241A2);
    }

    
    function lpToken() public pure override returns (IERC20) {
        return IERC20(0x3175Df0976dFA876431C2E9eE6Bc45b65d3473CC);
    }
}

interface IBorrowStaker is IBorrowStakerCheckpoint, IERC20 {
    function asset() external returns (IERC20 stakingToken);

    function deposit(uint256 amount, address to) external;

    function withdraw(
        uint256 amount,
        address from,
        address to
    ) external;

    //solhint-disable-next-line
    function claim_rewards(address user) external returns (uint256[] memory);
}

// 

pragma solidity ^0.8.17;



uint256 constant N_COINS = 2;

//solhint-disable
interface IMetaPool2 is IMetaPoolBase {
    function coins() external view returns (uint256[N_COINS] memory);

    // for basis pool
    function balances(uint256) external view returns (uint256);

    function get_balances() external view returns (uint256[N_COINS] memory);

    function get_previous_balances() external view returns (uint256[N_COINS] memory);

    function get_price_cumulative_last() external view returns (uint256[N_COINS] memory);

    function get_twap_balances(
        uint256[N_COINS] memory _first_balances,
        uint256[N_COINS] memory _last_balances,
        uint256 _time_elapsed
    ) external view returns (uint256[N_COINS] memory);

    function calc_token_amount(uint256[N_COINS] memory _amounts, bool _is_deposit) external view returns (uint256);

    function calc_token_amount(
        uint256[N_COINS] memory _amounts,
        bool _is_deposit,
        bool _previous
    ) external view returns (uint256);

    function add_liquidity(uint256[N_COINS] memory _amounts, uint256 _min_mint_amount) external returns (uint256);

    function add_liquidity(
        uint256[N_COINS] memory _amounts,
        uint256 _min_mint_amount,
        address _receiver
    ) external returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx,
        uint256[N_COINS] memory _balances
    ) external view returns (uint256);

    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256[N_COINS] memory _balances
    ) external view returns (uint256);

    function remove_liquidity(uint256 _burn_amount, uint256[N_COINS] memory _min_amounts)
        external
        returns (uint256[N_COINS] memory);

    function remove_liquidity(
        uint256 _burn_amount,
        uint256[N_COINS] memory _min_amounts,
        address _receiver
    ) external returns (uint256[N_COINS] memory);

    function remove_liquidity_imbalance(uint256[N_COINS] memory _amounts, uint256 _max_burn_amount)
        external
        returns (uint256);

    function remove_liquidity_imbalance(
        uint256[N_COINS] memory _amounts,
        uint256 _max_burn_amount,
        address _receiver
    ) external returns (uint256);
}

// 
pragma solidity ^0.8.17;






contract StakeDAOLevSwapperFRAXBP is CurveLevSwapperFRAXBP {
    constructor(
        ICoreBorrow _core,
        IUniswapV3Router _uniV3Router,
        address _oneInch,
        IAngleRouterSidechain _angleRouter
    ) CurveLevSwapperFRAXBP(_core, _uniV3Router, _oneInch, _angleRouter) {}

    
    function angleStaker() public pure override returns (IBorrowStaker) {
        return IBorrowStaker(0xa9d2Eea75C80fF9669cc998c276Ff26D741Dcb26);
    }
}

// 

pragma solidity ^0.8.12;


enum ActionType {
    transfer,
    wrap,
    wrapNative,
    sweep,
    sweepNative,
    unwrap,
    unwrapNative,
    swapIn,
    swapOut,
    uniswapV3,
    oneInch,
    claimRewards,
    gaugeDeposit,
    borrower
}


struct PermitType {
    address token;
    address owner;
    uint256 value;
    uint256 deadline;
    uint8 v;
    bytes32 r;
    bytes32 s;
}




interface IAngleRouterSidechain {
    function mixer(
        PermitType[] memory paramsPermit,
        ActionType[] memory actions,
        bytes[] calldata data
    ) external;
}

// 

pragma solidity ^0.8.12;





/// of this module
interface ICoreBorrow {
    
    /// module initialized on it
    
    
    function isFlashLoanerTreasury(address treasury) external view returns (bool);

    
    
    
    function isGovernor(address admin) external view returns (bool);

    
    
    
    
    /// role by calling the `addGovernor` function
    function isGovernorOrGuardian(address admin) external view returns (bool);
}

// 

pragma solidity ^0.8.12;





/// of this module
interface IWStETH {
    function wrap(uint256 _stETHAmount) external returns (uint256);

    function stETH() external view returns (address);
}

// 

pragma solidity ^0.8.12;

struct ExactInputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
}



interface IUniswapV3Router {
    
    
    
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);
}




interface IUniswapV2Router {
    
    /// other asset (accounting for fees) given reserves.
    
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        uint256 swapAmount,
        uint256 minExpected,
        address[] calldata path,
        address receiver,
        uint256 swapDeadline
    ) external;
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;





/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}