// SPDX-License-Identifier: MIT
pragma abicoder v2;

// 
pragma solidity 0.7.6; // some underlying uniswap library require version <0.8.0  








	
struct UniV3SortPoolQuery{
    address _pool;
    address _token0;
    address _token1;
    uint24 _fee;
    uint256 amountIn;
    bool zeroForOne;
}

interface IERC20 {
    function balanceOf(address _owner) external view returns (uint256);
}

interface IUniswapV3PoolSwapTick {
    function slot0() external view returns (uint160 sqrtPriceX96, int24, uint16, uint16, uint16, uint8, bool);
    function liquidity() external view returns (uint128);
    function tickSpacing() external view returns (int24);
    function ticks(int24 tick) external view returns (uint128 liquidityGross, int128 liquidityNet, uint256 feeGrowthOutside0X128, uint256 feeGrowthOutside1X128, int56 tickCumulativeOutside, uint160 secondsPerLiquidityOutsideX128, uint32 secondsOutside, bool initialized);
}

// simplified version of https://github.com/Uniswap/v3-core/blob/main/contracts/UniswapV3Pool.sol#L561
struct SwapStatus{
    int256 _amountSpecifiedRemaining;
    uint160 _sqrtPriceX96;
    int24 _tick;
    uint128 _liquidity;
    int256 _amountCalculated;
}


contract UniV3SwapSimulator {
    using LowGasSafeMath for uint256;
    using LowGasSafeMath for int256;
    using SafeCast for uint256;
    using SafeCast for int256;
    
    
    
    
    
    function simulateUniV3Swap(address _pool, address _token0, address _token1, bool _zeroForOne, uint24 _fee, uint256 _amountIn) external view returns (uint256){        
        // Get current state of the pool
        int24 _tickSpacing = IUniswapV3PoolSwapTick(_pool).tickSpacing();
        // lower limit if zeroForOne in terms of slippage, or upper limit for the other direction
        uint160 _sqrtPriceLimitX96;
        // Temporary state holding key data across swap steps
        SwapStatus memory state;
		
        {
           (uint160 _currentPX96, int24 _currentTick,,,,,) = IUniswapV3PoolSwapTick(_pool).slot0();
           _sqrtPriceLimitX96 = _getLimitPrice(_zeroForOne);
           state = SwapStatus(_amountIn.toInt256(), _currentPX96, _currentTick, IUniswapV3PoolSwapTick(_pool).liquidity(), 0);
        }
		
        // Loop over ticks until we exhaust all _amountIn or hit the slippage-allowed price limit
        while (state._amountSpecifiedRemaining != 0 && state._sqrtPriceX96 != _sqrtPriceLimitX96) {
           {
               _stepInTick(state, TickNextWithWordQuery(_pool, state._tick, _tickSpacing, _zeroForOne), _fee, _zeroForOne, _sqrtPriceLimitX96);	
           }			
        }
		
        return uint256(state._amountCalculated);
    }	
	
    
    
    function checkInRangeLiquidity(UniV3SortPoolQuery memory _sortQuery) public view returns (bool, uint256) {	
        uint128 _liq = IUniswapV3PoolSwapTick(_sortQuery._pool).liquidity();
		
        // are we swapping in a liquid-enough pool?
        if (_liq <= 0) {
           return (false, 0);
        }		
			 
        {
           (uint160 _swapAfterPrice, uint160 _tickNextPrice, uint160 _currentPriceX96) = _findSwapPriceExactIn(_sortQuery, _liq);           
           bool _crossTick = _sortQuery.zeroForOne? (_swapAfterPrice <= _tickNextPrice) : (_swapAfterPrice >= _tickNextPrice);
           if (_crossTick){
               return (true, 0);
           } else{            
               return (false, _getAmountOutputDelta(_swapAfterPrice, _currentPriceX96, _liq, _sortQuery.zeroForOne));
           }
        }             
	}
	
    
    function _getNextInitializedTick(TickNextWithWordQuery memory _nextTickQuery) internal view returns (int24, bool, uint160) {	
        (int24 tickNext, bool initialized) = TickBitmap.nextInitializedTickWithinOneWord(_nextTickQuery);
        if (tickNext < TickMath.MIN_TICK) {
           tickNext = TickMath.MIN_TICK;
        } else if (tickNext > TickMath.MAX_TICK) {
           tickNext = TickMath.MAX_TICK;
        }
        uint160 sqrtPriceNextX96 = TickMath.getSqrtRatioAtTick(tickNext);
        return (tickNext, initialized, sqrtPriceNextX96);
    }
	
    
    
    
    function _getAmountOutputDelta(uint160 _nextPrice, uint160 _currentPrice, uint128 _liquidity, bool _zeroForOne) internal pure returns (uint256) {
        return _zeroForOne? SqrtPriceMath.getAmount1Delta(_nextPrice, _currentPrice, _liquidity, false) : SqrtPriceMath.getAmount0Delta(_currentPrice, _nextPrice, _liquidity, false);
    }
	
    
    function _stepInTick(SwapStatus memory state, TickNextWithWordQuery memory _nextTickQuery, uint24 _fee, bool _zeroForOne, uint160 _sqrtPriceLimitX96) view internal{
		
        /// Fetch NEXT-STEP tick to prepare for crossing
        (int24 tickNext, bool initialized, uint160 sqrtPriceNextX96) = _getNextInitializedTick(_nextTickQuery);
        uint160 sqrtPriceStartX96 = state._sqrtPriceX96;
        uint160 _targetPX96 = _getTargetPriceForSwapStep(_zeroForOne, sqrtPriceNextX96, _sqrtPriceLimitX96);
		
        /// Trying to perform in-tick swap
        {		    
           _swapCalculation(state, _targetPX96, _fee);
        }
						
        /// Check if we have to cross ticks for NEXT-STEP
        if (state._sqrtPriceX96 == sqrtPriceNextX96) {
           // if the tick is initialized, run the tick transition
           if (initialized) {
               (,int128 liquidityNet,,,,,,) = IUniswapV3PoolSwapTick(_nextTickQuery.pool).ticks(tickNext);
               // if we're moving leftward, we interpret liquidityNet as the opposite sign safe because liquidityNet cannot be type(int128).min
               if (_zeroForOne) liquidityNet = -liquidityNet;
               state._liquidity = LiquidityMath.addDelta(state._liquidity, liquidityNet);
           }
           state._tick = _zeroForOne ? tickNext - 1 : tickNext;				
        } else if (state._sqrtPriceX96 != sqrtPriceStartX96) {
           // recompute unless we're on a lower tick boundary (i.e. already transitioned ticks), and haven't moved
           state._tick = TickMath.getTickAtSqrtRatio(state._sqrtPriceX96);
        }
    } 
	
    function _findSwapPriceExactIn(UniV3SortPoolQuery memory _sortQuery, uint128 _liq) internal view returns (uint160, uint160, uint160) {
        uint160 _tickNextPrice;
        uint160 _swapAfterPrice;
        (uint160 _currentPriceX96, int24 _tick,,,,,) = IUniswapV3PoolSwapTick(_sortQuery._pool).slot0();
		
        {
           TickNextWithWordQuery memory _nextTickQ = TickNextWithWordQuery(_sortQuery._pool, _tick, IUniswapV3PoolSwapTick(_sortQuery._pool).tickSpacing(), _sortQuery.zeroForOne);
           (,,uint160 _nxtTkP) = _getNextInitializedTick(_nextTickQ);
           _tickNextPrice = _nxtTkP;
        }
		
        {		
           uint160 _targetPX96 = _getTargetPriceForSwapStep(_sortQuery.zeroForOne, _tickNextPrice, _getLimitPrice(_sortQuery.zeroForOne));
           SwapExactInParam memory _exactInParams = SwapExactInParam(_sortQuery.amountIn, _sortQuery._fee, _currentPriceX96, _targetPX96, _liq, _sortQuery.zeroForOne);
           (uint256 _amtIn, uint160 _newPrice) = SwapMath._getExactInNextPrice(_exactInParams);
           _swapAfterPrice = _newPrice;
        }
        
        return (_swapAfterPrice, _tickNextPrice, _currentPriceX96);
    }
	
    
    function _getLimitPrice(bool _zeroForOne) internal pure returns (uint160) {
        return _zeroForOne? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1;
    }
	
    function _getTargetPriceForSwapStep(bool _zeroForOne, uint160 sqrtPriceNextX96, uint160 _sqrtPriceLimitX96) internal pure returns (uint160) {
        return (_zeroForOne ? sqrtPriceNextX96 < _sqrtPriceLimitX96 : sqrtPriceNextX96 > _sqrtPriceLimitX96)? _sqrtPriceLimitX96 : sqrtPriceNextX96;
    }
	
    function _swapCalculation(SwapStatus memory state, uint160 _targetPX96, uint24 _fee) internal view {
        (uint160 sqrtPriceX96, uint256 amountIn, uint256 amountOut, uint256 feeAmount) = SwapMath.computeSwapStep(state._sqrtPriceX96, _targetPX96, state._liquidity, state._amountSpecifiedRemaining, _fee);
			
        /// Update amounts for swap pair tokens
        state._sqrtPriceX96 = sqrtPriceX96; 
        state._amountSpecifiedRemaining -= (amountIn + feeAmount).toInt256();
        state._amountCalculated = state._amountCalculated.add(amountOut.toInt256());
    }

}

// 
pragma solidity 0.7.6;





struct SwapExactInParam{
    uint256 _amountIn;
    uint24 _fee;
    uint160 _currentPriceX96;
    uint160 _targetPriceX96;
    uint128 _liquidity;
    bool _zeroForOne;
}

// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/SwapMath.sol
library SwapMath {
    
    
    
    
    
    
    
    
    
    
    
    function computeSwapStep(
        uint160 sqrtRatioCurrentX96,
        uint160 sqrtRatioTargetX96,
        uint128 liquidity,
        int256 amountRemaining,
        uint24 feePips
    )
        internal
        pure
        returns (
            uint160 sqrtRatioNextX96,
            uint256 amountIn,
            uint256 amountOut,
            uint256 feeAmount
        )
    {
        bool zeroForOne = sqrtRatioCurrentX96 >= sqrtRatioTargetX96;
        bool exactIn = amountRemaining >= 0;

        {
          if (exactIn) {
            SwapExactInParam memory _exactInParams = SwapExactInParam(uint256(amountRemaining), feePips, sqrtRatioCurrentX96, sqrtRatioTargetX96, liquidity, zeroForOne);
            (uint256 _amtIn, uint160 _nextPrice) = _getExactInNextPrice(_exactInParams);
            amountIn = _amtIn;
            sqrtRatioNextX96 = _nextPrice;
          } else {
            amountOut = zeroForOne
                ? SqrtPriceMath.getAmount1Delta(sqrtRatioTargetX96, sqrtRatioCurrentX96, liquidity, false)
                : SqrtPriceMath.getAmount0Delta(sqrtRatioCurrentX96, sqrtRatioTargetX96, liquidity, false);
            if (uint256(-amountRemaining) >= amountOut) sqrtRatioNextX96 = sqrtRatioTargetX96;
            else
                sqrtRatioNextX96 = SqrtPriceMath.getNextSqrtPriceFromOutput(
                    sqrtRatioCurrentX96,
                    liquidity,
                    uint256(-amountRemaining),
                    zeroForOne
                );
          }
        }

        bool max = sqrtRatioTargetX96 == sqrtRatioNextX96;

        // get the input/output amounts
        {
          if (zeroForOne) {
            amountIn = max && exactIn
                ? amountIn
                : SqrtPriceMath.getAmount0Delta(sqrtRatioNextX96, sqrtRatioCurrentX96, liquidity, true);
            amountOut = max && !exactIn
                ? amountOut
                : SqrtPriceMath.getAmount1Delta(sqrtRatioNextX96, sqrtRatioCurrentX96, liquidity, false);
          }else {
            amountIn = max && exactIn
                ? amountIn
                : SqrtPriceMath.getAmount1Delta(sqrtRatioCurrentX96, sqrtRatioNextX96, liquidity, true);
            amountOut = max && !exactIn
                ? amountOut
                : SqrtPriceMath.getAmount0Delta(sqrtRatioCurrentX96, sqrtRatioNextX96, liquidity, false);
          }
        }

        // cap the output amount to not exceed the remaining output amount
        if (!exactIn && amountOut > uint256(-amountRemaining)) {
            amountOut = uint256(-amountRemaining);
        }

        if (exactIn && sqrtRatioNextX96 != sqrtRatioTargetX96) {
            // we didn't reach the target, so take the remainder of the maximum input as fee
            feeAmount = uint256(amountRemaining) - amountIn;
        } else {
            feeAmount = FullMath.mulDivRoundingUp(amountIn, feePips, 1e6 - feePips);
        }
    }
	
    function _getExactInNextPrice(SwapExactInParam memory _exactInParams) internal pure returns (uint256, uint160){
        uint160 sqrtRatioNextX96;
        uint256 amountRemainingLessFee = FullMath.mulDiv(_exactInParams._amountIn, 1e6 - (_exactInParams._fee), 1e6);
        uint256 amountIn = _exactInParams._zeroForOne? SqrtPriceMath.getAmount0Delta(_exactInParams._targetPriceX96, _exactInParams._currentPriceX96, _exactInParams._liquidity, true) : 
                                                       SqrtPriceMath.getAmount1Delta(_exactInParams._currentPriceX96, _exactInParams._targetPriceX96, _exactInParams._liquidity, true);
        if (amountRemainingLessFee >= amountIn) sqrtRatioNextX96 = _exactInParams._targetPriceX96;
        else sqrtRatioNextX96 = SqrtPriceMath.getNextSqrtPriceFromInput(_exactInParams._currentPriceX96, _exactInParams._liquidity, amountRemainingLessFee, _exactInParams._zeroForOne);
        return (amountIn, sqrtRatioNextX96);
    }
}

// 
pragma solidity 0.7.6;


// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/FullMath.sol
library FullMath {
    
    
    
    
    
    
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remainder Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        // Make sure the result is less than 2**256.
        // Also prevents denominator == 0
        require(denominator > prod1);

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1.
        uint256 twos = -denominator & denominator;
        // Divide denominator by power of two
        assembly {
            denominator := div(denominator, twos)
        }

        // Divide [prod1 prod0] by the factors of two
        assembly {
            prod0 := div(prod0, twos)
        }
        // Shift in bits from prod1 into prod0. For this we need
        // to flip `twos` such that it is 2**256 / twos.
        // If twos is zero, then it becomes one
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        // Invert denominator mod 2**256
        // Now that denominator is an odd number, it has an inverse
        // modulo 2**256 such that denominator * inv = 1 mod 2**256.
        // Compute the inverse by starting with a seed that is correct
        // correct for four bits. That is, denominator * inv = 1 mod 2**4
        uint256 inv = (3 * denominator) ^ 2;
        // Now use Newton-Raphson iteration to improve the precision.
        // Thanks to Hensel's lifting lemma, this also works in modular
        // arithmetic, doubling the correct bits in each step.
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        // Because the division is now exact we can divide by multiplying
        // with the modular inverse of denominator. This will give us the
        // correct result modulo 2**256. Since the precoditions guarantee
        // that the outcome is less than 2**256, this is the final result.
        // We don't need to compute the high bits of the result and prod1
        // is no longer required.
        result = prod0 * inv;
        return result;
    }

    
    
    
    
    
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}

// 
pragma solidity 0.7.6;








// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/SqrtPriceMath.sol
library SqrtPriceMath {
    using LowGasSafeMath for uint256;
    using SafeCast for uint256;

    
    
    /// far enough to get the desired output amount, and in the exact input case (decreasing price) we need to move the
    /// price less in order to not send too much output.
    /// The most precise formula for this is liquidity * sqrtPX96 / (liquidity +- amount * sqrtPX96),
    /// if this is impossible because of overflow, we calculate liquidity / (liquidity / sqrtPX96 +- amount).
    
    
    
    
    
    function getNextSqrtPriceFromAmount0RoundingUp(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) internal pure returns (uint160) {
        // we short circuit amount == 0 because the result is otherwise not guaranteed to equal the input price
        if (amount == 0) return sqrtPX96;
        uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;

        if (add) {
            uint256 product;
            if ((product = amount * sqrtPX96) / amount == sqrtPX96) {
                uint256 denominator = numerator1 + product;
                if (denominator >= numerator1)
                    // always fits in 160 bits
                    return uint160(FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator));
            }

            return uint160(UnsafeMath.divRoundingUp(numerator1, (numerator1 / sqrtPX96).add(amount)));
        } else {
            uint256 product;
            // if the product overflows, we know the denominator underflows
            // in addition, we must check that the denominator does not underflow
            require((product = amount * sqrtPX96) / amount == sqrtPX96 && numerator1 > product);
            uint256 denominator = numerator1 - product;
            return FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator).toUint160();
        }
    }

    
    
    /// far enough to get the desired output amount, and in the exact input case (increasing price) we need to move the
    /// price less in order to not send too much output.
    /// The formula we compute is within <1 wei of the lossless version: sqrtPX96 +- amount / liquidity
    
    
    
    
    
    function getNextSqrtPriceFromAmount1RoundingDown(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) internal pure returns (uint160) {
        // if we're adding (subtracting), rounding down requires rounding the quotient down (up)
        // in both cases, avoid a mulDiv for most inputs
        if (add) {
            uint256 quotient =
                (
                    amount <= type(uint160).max
                        ? (amount << FixedPoint96.RESOLUTION) / liquidity
                        : FullMath.mulDiv(amount, FixedPoint96.Q96, liquidity)
                );

            return uint256(sqrtPX96).add(quotient).toUint160();
        } else {
            uint256 quotient =
                (
                    amount <= type(uint160).max
                        ? UnsafeMath.divRoundingUp(amount << FixedPoint96.RESOLUTION, liquidity)
                        : FullMath.mulDivRoundingUp(amount, FixedPoint96.Q96, liquidity)
                );

            require(sqrtPX96 > quotient);
            // always fits 160 bits
            return uint160(sqrtPX96 - quotient);
        }
    }

    
    
    
    
    
    
    
    function getNextSqrtPriceFromInput(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amountIn,
        bool zeroForOne
    ) internal pure returns (uint160 sqrtQX96) {
        require(sqrtPX96 > 0);
        require(liquidity > 0);

        // round to make sure that we don't pass the target price
        return
            zeroForOne
                ? getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amountIn, true)
                : getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amountIn, true);
    }

    
    
    
    
    
    
    
    function getNextSqrtPriceFromOutput(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amountOut,
        bool zeroForOne
    ) internal pure returns (uint160 sqrtQX96) {
        require(sqrtPX96 > 0);
        require(liquidity > 0);

        // round to make sure that we pass the target price
        return
            zeroForOne
                ? getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amountOut, false)
                : getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amountOut, false);
    }

    
    
    /// i.e. liquidity * (sqrt(upper) - sqrt(lower)) / (sqrt(upper) * sqrt(lower))
    
    
    
    
    
    function getAmount0Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount0) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;
        uint256 numerator2 = sqrtRatioBX96 - sqrtRatioAX96;

        require(sqrtRatioAX96 > 0);

        return
            roundUp
                ? UnsafeMath.divRoundingUp(
                    FullMath.mulDivRoundingUp(numerator1, numerator2, sqrtRatioBX96),
                    sqrtRatioAX96
                )
                : FullMath.mulDiv(numerator1, numerator2, sqrtRatioBX96) / sqrtRatioAX96;
    }

    
    
    
    
    
    
    
    function getAmount1Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount1) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return
            roundUp
                ? FullMath.mulDivRoundingUp(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96)
                : FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96);
    }

    
    
    
    
    
    function getAmount0Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        int128 liquidity
    ) internal pure returns (int256 amount0) {
        return
            liquidity < 0
                ? -getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(-liquidity), false).toInt256()
                : getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(liquidity), true).toInt256();
    }

    
    
    
    
    
    function getAmount1Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        int128 liquidity
    ) internal pure returns (int256 amount1) {
        return
            liquidity < 0
                ? -getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(-liquidity), false).toInt256()
                : getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(liquidity), true).toInt256();
    }
}

// 
pragma solidity 0.7.6;


// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/LowGasSafeMath.sol
library LowGasSafeMath {
    
    
    
    
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    
    
    
    
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    
    
    
    
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    
    
    
    
    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x + y) >= x == (y >= 0));
    }

    
    
    
    
    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x - y) <= x == (y >= 0));
    }
}

// 
pragma solidity 0.7.6;


// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/SafeCast.sol
library SafeCast {
    
    
    
    function toUint160(uint256 y) internal pure returns (uint160 z) {
        require((z = uint160(y)) == y);
    }

    
    
    
    function toInt128(int256 y) internal pure returns (int128 z) {
        require((z = int128(y)) == y);
    }

    
    
    
    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y < 2**255);
        z = int256(y);
    }
}

// 
pragma solidity 0.7.6;


// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/UnsafeMath.sol
library UnsafeMath {
    
    
    
    
    
    function divRoundingUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := add(div(x, y), gt(mod(x, y), 0))
        }
    }
}

// 
pragma solidity 0.7.6;


// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/FixedPoint96.sol
library FixedPoint96 {
    uint8 internal constant RESOLUTION = 96;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
}

// 
pragma solidity 0.7.6;




interface IUniswapV3PoolBitmap {
    function tickBitmap(int16 wordPosition) external view returns (uint256);
}

struct TickNextWithWordQuery{
    address pool;
    int24 tick;
    int24 tickSpacing;
    bool lte;
}

// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/TickBitmap.sol
library TickBitmap {
    
    
    
    
    function position(int24 tick) private pure returns (int16 wordPos, uint8 bitPos) {
        wordPos = int16(tick >> 8);
        bitPos = uint8(tick % 256);
    }

    
    /// to the left (less than or equal to) or right (greater than) of the given tick
    
    
    
    
    
    
    function nextInitializedTickWithinOneWord(TickNextWithWordQuery memory _query) internal view returns (int24 next, bool initialized) {
        int24 compressed = _query.tick / _query.tickSpacing;
        if (_query.tick < 0 && _query.tick % _query.tickSpacing != 0) compressed--; // round towards negative infinity

        if (_query.lte) {
            (int16 wordPos, uint8 bitPos) = position(compressed);
            // all the 1s at or to the right of the current bitPos
            uint256 mask = (1 << bitPos) - 1 + (1 << bitPos);
            uint256 masked = IUniswapV3PoolBitmap(_query.pool).tickBitmap(wordPos) & mask;

            // if there are no initialized ticks to the right of or at the current tick, return rightmost in the word
            initialized = masked != 0;
            // overflow/underflow is possible, but prevented externally by limiting both tickSpacing and tick
            next = initialized
                ? (compressed - int24(bitPos - BitMath.mostSignificantBit(masked))) * _query.tickSpacing
                : (compressed - int24(bitPos)) * _query.tickSpacing;
        } else {
            // start from the word of the next tick, since the current tick state doesn't matter
            (int16 wordPos, uint8 bitPos) = position(compressed + 1);
            // all the 1s at or to the left of the bitPos
            uint256 mask = ~((1 << bitPos) - 1);
            uint256 masked =  IUniswapV3PoolBitmap(_query.pool).tickBitmap(wordPos) & mask;

            // if there are no initialized ticks to the left of the current tick, return leftmost in the word
            initialized = masked != 0;
            // overflow/underflow is possible, but prevented externally by limiting both tickSpacing and tick
            next = initialized
                ? (compressed + 1 + int24(BitMath.leastSignificantBit(masked) - bitPos)) *_query. tickSpacing
                : (compressed + 1 + int24(type(uint8).max - bitPos)) * _query.tickSpacing;
        }
    }
}

// 
pragma solidity 0.7.6;


// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/BitMath.sol
library BitMath {
    
    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    
    ///     x >= 2**mostSignificantBit(x) and x < 2**(mostSignificantBit(x)+1)
    
    
    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0);

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        if (x >= 0x2) r += 1;
    }

    
    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    
    ///     (x & 2**leastSignificantBit(x)) != 0 and (x & (2**(leastSignificantBit(x)) - 1)) == 0)
    
    
    function leastSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0);

        r = 255;
        if (x & type(uint128).max > 0) {
            r -= 128;
        } else {
            x >>= 128;
        }
        if (x & type(uint64).max > 0) {
            r -= 64;
        } else {
            x >>= 64;
        }
        if (x & type(uint32).max > 0) {
            r -= 32;
        } else {
            x >>= 32;
        }
        if (x & type(uint16).max > 0) {
            r -= 16;
        } else {
            x >>= 16;
        }
        if (x & type(uint8).max > 0) {
            r -= 8;
        } else {
            x >>= 8;
        }
        if (x & 0xf > 0) {
            r -= 4;
        } else {
            x >>= 4;
        }
        if (x & 0x3 > 0) {
            r -= 2;
        } else {
            x >>= 2;
        }
        if (x & 0x1 > 0) r -= 1;
    }
}

// 
pragma solidity 0.7.6;


// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/TickMath.sol
library TickMath {
    
    int24 internal constant MIN_TICK = -887272;
    
    int24 internal constant MAX_TICK = -MIN_TICK;

    
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    
    
    
    
    /// at the given tick
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        require(absTick <= uint256(MAX_TICK), 'T');

        uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
        // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
        // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }
	
	
    
    /// ever return.
    
    
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        // second inequality must be < because the price can never reach the price at the max tick
        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, 'R');
        uint256 ratio = uint256(sqrtPriceX96) << 32;

        uint256 r = ratio;
        uint256 msb = 0;

        assembly {
            let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(5, gt(r, 0xFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(4, gt(r, 0xFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(3, gt(r, 0xFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(2, gt(r, 0xF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(1, gt(r, 0x3))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := gt(r, 0x1)
            msb := or(msb, f)
        }

        if (msb >= 128) r = ratio >> (msb - 127);
        else r = ratio << (127 - msb);

        int256 log_2 = (int256(msb) - 128) << 64;

        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(63, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(62, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(61, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(60, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(59, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(58, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(57, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(56, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(55, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(54, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(53, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(52, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(51, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(50, f))
        }

        int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

        int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
        int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

        tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
    }
}

// 
pragma solidity 0.7.6;


// https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/LiquidityMath.sol
library LiquidityMath {
    
    
    
    
    function addDelta(uint128 x, int128 y) internal pure returns (uint128 z) {
        if (y < 0) {
            require((z = x - uint128(-y)) < x, 'LS');
        } else {
            require((z = x + uint128(y)) >= x, 'LA');
        }
    }
}