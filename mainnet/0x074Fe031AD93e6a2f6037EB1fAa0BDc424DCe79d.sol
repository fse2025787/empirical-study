// SPDX-License-Identifier: MIT


// 
pragma solidity >=0.5.0;



interface IDexPriceAggregator {
    
    
    
    
    
    
    function assetToAsset(
        address tokenIn,
        uint256 amountIn,
        address tokenOut,
        uint256 twapPeriod
    ) external view returns (uint256 amountOut);
}

// 
// Adapted from https://github.com/Synthetixio/synthetix/blob/v2.46.0/contracts/Owned.sol
pragma solidity >=0.5.0 <0.8.0;



abstract contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor(address _owner) {
        require(_owner != address(0), 'Owner address cannot be 0');
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, 'You must be nominated before you can accept ownership');
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {
        require(msg.sender == owner, 'Only the contract owner may perform this action');
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolImmutables {
    
    
    function factory() external view returns (address);

    
    
    function token0() external view returns (address);

    
    
    function token1() external view returns (address);

    
    
    function fee() external view returns (uint24);

    
    
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    
    function tickSpacing() external view returns (int24);

    
    
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    
    function maxLiquidityPerTick() external view returns (uint128);
}

// 
pragma solidity >=0.5.0;



/// per transaction
interface IUniswapV3PoolState {
    
    /// when accessed externally.
    
    /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// observationIndex The index of the last oracle observation that was written,
    /// observationCardinality The current maximum number of observations stored in the pool,
    /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    
    
    function feeGrowthGlobal0X128() external view returns (uint256);

    
    
    function feeGrowthGlobal1X128() external view returns (uint256);

    
    
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    
    
    function liquidity() external view returns (uint128);

    
    
    
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    
    
    
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    
    
    
    /// ago, rather than at a specific index in the array.
    
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}

// 
pragma solidity >=0.5.0;



/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    
    
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    
    
    
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    
    
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    
    
    
    
    
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolActions {
    
    
    
    function initialize(uint160 sqrtPriceX96) external;

    
    
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    
    
    
    
    
    
    
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    
    
    
    
    
    
    
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    
    
    
    
    
    
    
    
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    
    
    
    
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    
    
    
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    
    
    
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    
    
    
    
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    
    
    /// the input observationCardinalityNext.
    
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolOwnerActions {
    
    
    
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    
    
    
    
    
    
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolEvents {
    
    
    
    
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    
    
    
    
    
    
    
    
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    
    
    
    
    
    
    
    
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    
    
    
    
    
    
    
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    
    
    /// just before a mint/swap/burn.
    
    
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    
    
    
    
    
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    
    
    
    
    
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}
// 
pragma solidity =0.7.6;












///         Provides the minimum output between an asset's "spot" price and TWAP from the last n seconds.
///         The "spot" price is always the last block's ending price.
contract DexPriceAggregatorUniswapV3 is IDexPriceAggregator, Owned {
    address public immutable uniswapV3Factory;
    address public immutable weth;
    uint24 public immutable defaultPoolFee;

    mapping(bytes32 => address) public overriddenPoolForRoute;

    constructor(
        address _owner,
        address _uniswapV3Factory,
        address _weth,
        uint24 _defaultPoolFee
    ) Owned(_owner) {
        uniswapV3Factory = _uniswapV3Factory;
        weth = _weth;
        defaultPoolFee = _defaultPoolFee;
    }

    /********************
     * Oracle functions *
     ********************/

    
    function assetToAsset(
        address _tokenIn,
        uint256 _amountIn,
        address _tokenOut,
        uint256 _twapPeriod
    ) public view override returns (uint256 amountOut) {
        if (_tokenIn == weth) {
            return ethToAsset(_amountIn, _tokenOut, _twapPeriod);
        } else if (_tokenOut == weth) {
            return assetToEth(_tokenIn, _amountIn, _twapPeriod);
        } else {
            return _fetchAmountCrossingPools(_tokenIn, _amountIn, _tokenOut, _twapPeriod);
        }
    }

    
    
    
    
    
    function assetToEth(
        address _tokenIn,
        uint256 _amountIn,
        uint256 _twapPeriod
    ) public view returns (uint256 ethAmountOut) {
        address tokenOut = weth;
        address pool = _getPoolForRoute(PoolAddress.getPoolKey(_tokenIn, tokenOut, defaultPoolFee));
        return _fetchAmountFromSinglePool(_tokenIn, _amountIn, tokenOut, pool, _twapPeriod);
    }

    
    
    
    
    
    function ethToAsset(
        uint256 _ethAmountIn,
        address _tokenOut,
        uint256 _twapPeriod
    ) public view returns (uint256 amountOut) {
        address tokenIn = weth;
        address pool = _getPoolForRoute(PoolAddress.getPoolKey(tokenIn, _tokenOut, defaultPoolFee));
        return _fetchAmountFromSinglePool(tokenIn, _ethAmountIn, _tokenOut, pool, _twapPeriod);
    }

    /************************
     * Management functions *
     ************************/

    
    
    
    
    
    function setPoolForRoute(
        address _tokenA,
        address _tokenB,
        address _pool
    ) public onlyOwner {
        PoolAddress.PoolKey memory poolKey = PoolAddress.getPoolKey(
            _tokenA,
            _tokenB,
            uint24(0) // pool fee is unused
        );
        if (_pool != address(0)) {
            require(
                poolKey.token0 == IUniswapV3Pool(_pool).token0() && poolKey.token1 == IUniswapV3Pool(_pool).token1(),
                'Tokens or pool not correct'
            );
        }
        overriddenPoolForRoute[_identifyRouteFromPoolKey(poolKey)] = _pool;
        emit PoolForRouteSet(poolKey.token0, poolKey.token1, _pool);
    }

    
    
    
    
    function getPoolForRoute(address _tokenA, address _tokenB) public view returns (address pool) {
        return _getPoolForRoute(PoolAddress.getPoolKey(_tokenA, _tokenB, defaultPoolFee));
    }

    /**************************
     * Utility view functions *
     **************************/

    
    
    
    
    
    function fetchCurrentTicks(address _pool, uint32 _twapPeriod) public view returns (int24 spotTick, int24 twapTick) {
        spotTick = SpotOracleLibrary.consult(_pool);
        twapTick = OracleLibrary.consult(_pool, _twapPeriod);
    }

    
    
    
    
    
    
    function getQuoteAtTick(
        address _tokenIn,
        uint128 _amountIn,
        address _tokenOut,
        int24 _tick
    ) public pure returns (uint256 amountOut) {
        return OracleLibrary.getQuoteAtTick(_tick, _amountIn, _tokenIn, _tokenOut);
    }

    
    ///         by first adjusting into ETH
    ///         (ie. when a route goes through an intermediary pool with ETH)
    
    
    
    
    
    
    function getQuoteCrossingTicksThroughWeth(
        address _tokenIn,
        uint128 _amountIn,
        address _tokenOut,
        int24 _tick1,
        int24 _tick2
    ) public view returns (uint256 amountOut) {
        return _getQuoteCrossingTicksThroughWeth(_tokenIn, _amountIn, _tokenOut, _tick1, _tick2);
    }

    /*************
     * Internals *
     *************/

    
    ///         within a single liquidity pool
    
    ///      It is exposed as a parameter only as a gas optimization.
    
    
    
    
    
    
    function _fetchAmountFromSinglePool(
        address _tokenIn,
        uint256 _amountIn,
        address _tokenOut,
        address _pool,
        uint256 _twapPeriod
    ) internal view returns (uint256 amountOut) {
        // Leave ticks as int256s to avoid solidity casting
        int256 spotTick = SpotOracleLibrary.consult(_pool);
        int256 twapTick = OracleLibrary.consult(_pool, SafeCast.toUint32(_twapPeriod));

        // Return min amount between spot price and twap
        // Ticks are based on the ratio between token0:token1 so if the input token is token1 then
        // we need to treat the tick as an inverse
        int256 minTick;
        if (_tokenIn < _tokenOut) {
            minTick = spotTick < twapTick ? spotTick : twapTick;
        } else {
            minTick = spotTick > twapTick ? spotTick : twapTick;
        }

        return
            OracleLibrary.getQuoteAtTick(
                int24(minTick), // can assume safe being result from consult()
                SafeCast.toUint128(_amountIn),
                _tokenIn,
                _tokenOut
            );
    }

    
    ///         liquidity across an intermediary pool with ETH (ie. _tokenIn:ETH and ETH:_tokenOut)
    
    ///      used directly in lieu of "crossing" against an intermediary pool with ETH
    
    
    
    
    
    function _fetchAmountCrossingPools(
        address _tokenIn,
        uint256 _amountIn,
        address _tokenOut,
        uint256 _twapPeriod
    ) internal view returns (uint256 amountOut) {
        // If the tokenIn:tokenOut route was overridden to use a single pool, derive price directly from that pool
        address overriddenPool = _getOverriddenPool(
            PoolAddress.getPoolKey(
                _tokenIn,
                _tokenOut,
                uint24(0) // pool fee is unused
            )
        );
        if (overriddenPool != address(0)) {
            return _fetchAmountFromSinglePool(_tokenIn, _amountIn, _tokenOut, overriddenPool, _twapPeriod);
        }

        // Otherwise, derive the price by "crossing" through tokenIn:ETH -> ETH:tokenOut
        // To keep consistency, we cross through with the same price source (spot vs. twap)
        address pool1 = _getPoolForRoute(PoolAddress.getPoolKey(_tokenIn, weth, defaultPoolFee));
        address pool2 = _getPoolForRoute(PoolAddress.getPoolKey(_tokenOut, weth, defaultPoolFee));

        int24 spotTick1 = SpotOracleLibrary.consult(pool1);
        int24 spotTick2 = SpotOracleLibrary.consult(pool2);
        uint256 spotAmountOut = _getQuoteCrossingTicksThroughWeth(_tokenIn, _amountIn, _tokenOut, spotTick1, spotTick2);

        uint32 castedTwapPeriod = SafeCast.toUint32(_twapPeriod);
        int24 twapTick1 = OracleLibrary.consult(pool1, castedTwapPeriod);
        int24 twapTick2 = OracleLibrary.consult(pool2, castedTwapPeriod);
        uint256 twapAmountOut = _getQuoteCrossingTicksThroughWeth(_tokenIn, _amountIn, _tokenOut, twapTick1, twapTick2);

        // Return min amount between spot price and twap
        return spotAmountOut < twapAmountOut ? spotAmountOut : twapAmountOut;
    }

    
    ///         in exchange by first adjusting into ETH
    ///         (ie. when a route goes through an intermediary pool with ETH)
    
    
    
    
    
    
    function _getQuoteCrossingTicksThroughWeth(
        address _tokenIn,
        uint256 _amountIn,
        address _tokenOut,
        int24 _tick1,
        int24 _tick2
    ) internal view returns (uint256 amountOut) {
        uint256 ethAmountOut = OracleLibrary.getQuoteAtTick(_tick1, SafeCast.toUint128(_amountIn), _tokenIn, weth);
        return OracleLibrary.getQuoteAtTick(_tick2, SafeCast.toUint128(ethAmountOut), weth, _tokenOut);
    }

    
    
    
    function _getPoolForRoute(PoolAddress.PoolKey memory _poolKey) internal view returns (address pool) {
        pool = _getOverriddenPool(_poolKey);
        if (pool == address(0)) {
            pool = PoolAddress.computeAddress(uniswapV3Factory, _poolKey);
        }
    }

    
    
    
    function _identifyRouteFromPoolKey(PoolAddress.PoolKey memory _poolKey) internal pure returns (bytes32 id) {
        return keccak256(abi.encodePacked(_poolKey.token0, _poolKey.token1));
    }

    
    
    
    ///              address(0) if no overridden pool has been set.
    function _getOverriddenPool(PoolAddress.PoolKey memory _poolKey) internal view returns (address pool) {
        return overriddenPoolForRoute[_identifyRouteFromPoolKey(_poolKey)];
    }

    /**********
     * Events *
     **********/

    event PoolForRouteSet(address indexed token0, address indexed token1, address indexed pool);
}

// 
pragma solidity >=0.5.0;










/// to the ERC20 specification

interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}

// 
pragma solidity >=0.5.0 <0.8.0;









library OracleLibrary {
    
    
    
    
    function consult(address pool, uint32 period) internal view returns (int24 timeWeightedAverageTick) {
        require(period != 0, 'BP');

        uint32[] memory secondAgos = new uint32[](2);
        secondAgos[0] = period;
        secondAgos[1] = 0;

        (int56[] memory tickCumulatives, ) = IUniswapV3Pool(pool).observe(secondAgos);
        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        timeWeightedAverageTick = int24(tickCumulativesDelta / period);

        // Always round to negative infinity
        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % period != 0)) timeWeightedAverageTick--;
    }

    
    
    
    
    
    
    function getQuoteAtTick(
        int24 tick,
        uint128 baseAmount,
        address baseToken,
        address quoteToken
    ) internal pure returns (uint256 quoteAmount) {
        uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);

        // Calculate quoteAmount with better precision if it doesn't overflow when multiplied by itself
        if (sqrtRatioX96 <= type(uint128).max) {
            uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX192, baseAmount, 1 << 192)
                : FullMath.mulDiv(1 << 192, baseAmount, ratioX192);
        } else {
            uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX128, baseAmount, 1 << 128)
                : FullMath.mulDiv(1 << 128, baseAmount, ratioX128);
        }
    }
}

// 
pragma solidity >=0.5.0;


library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    
    
    
    
    
    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    
    
    
    
    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encode(key.token0, key.token1, key.fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            )
        );
    }
}

// 
pragma solidity >=0.5.0 <0.8.0;









library SpotOracleLibrary {
    
    
    
    function consult(address pool) internal view returns (int24 spotTick) {
        (, int24 currentTick, uint16 currentObservationIndex, uint16 observationCardinality, , , ) = IUniswapV3Pool(pool).slot0();
        (uint32 currentObservationTimestamp, int56 currentTickCumulative , , ) = IUniswapV3Pool(pool).observations(currentObservationIndex);
        // Stored timestamps are truncated, so assume the last observation was made within a uint32 second time window (~136 years)
        if (beforeNow(currentObservationTimestamp)) {
            // The last observation was written prior to this block, so no trades have occurred since then
            // The pool's current tick can be considered its spot tick
            spotTick = currentTick;
        } else {
            // The last observation was written in this block, making the current tick value
            // unreliable as it could have been manipulated.
            // Instead, provide spot as prior block's ending tick.
            (uint32 priorTimestamp, int56 priorTickCumulative) =
                fetchPriorObservation(pool, 1, currentObservationIndex, observationCardinality);
            spotTick = untransformCumulativesIntoTick(
                currentObservationTimestamp,
                currentTickCumulative,
                priorTimestamp,
                priorTickCumulative
            );
        }
    }

    
    
    
    
    function consultPreviouslyObservedTick(address pool, uint16 prevSteps) internal view returns (int24 observedTick) {
        (, , uint16 currentObservationIndex, uint16 observationCardinality, , , ) = IUniswapV3Pool(pool).slot0();

        (uint32 targetTimestamp, int56 targetTickCumulative) =
            fetchPriorObservation(pool, prevSteps, currentObservationIndex, observationCardinality);
        (uint32 targetMinusOneTimestamp, int56 targetMinusOneTickCumulative) =
            fetchPriorObservation(pool, prevSteps + 1, currentObservationIndex, observationCardinality);

        observedTick = untransformCumulativesIntoTick(
            targetTimestamp,
            targetTickCumulative,
            targetMinusOneTimestamp,
            targetMinusOneTickCumulative
        );
    }

    
    ///      Safe in comparisons across uint32 overflow boundaries.
    ///      `beforeOrNow` _must_ originally have been within one uint32 time period chronologically
    ///      before or equal to `block.timestamp`.
    
    
    function beforeNow(uint32 beforeOrNow) private view returns (bool) {
        // If `beforeOrNow` was within one uint32 period to `block.timestamp` then a lower value is
        // naturally an earlier time and a higher value is also an earlier time, only pre-overflow
        return beforeOrNow != uint32(block.timestamp); // truncation is desired
    }

    
    ///      Handles cardinality wrapping and uninitialized observations after cardinality growth.
    
    
    
    
    
    
    function fetchPriorObservation(
        address pool,
        uint16 prevSteps,
        uint16 startingObservationIndex,
        uint16 observationCardinality
    ) private view returns (uint32 timestamp, int56 tickCumulative) {
        bool initialized;
        for(; !initialized && prevSteps < observationCardinality; ++prevSteps) {
            // This loop handles a specific case when the pool's cardinality has increased but has
            // not yet observed enough new trades to fill out the new indices.
            // If we loop back from 0 to the last index, we will find uninitialized observations and
            // will have to keep looking back.
            uint16 observationIndex = prevObservationIndex(prevSteps, startingObservationIndex, observationCardinality);
            (timestamp, tickCumulative, , initialized) = IUniswapV3Pool(pool).observations(observationIndex);
        }
        require(initialized, 'BC'); // ensure found observation is initialized and within cardinality
    }

    
    ///      Handles cardinality wrapping.
    ///      `prevSteps` _must_ be lte `cardinality`.
    
    
    
    
    function prevObservationIndex(uint16 prevSteps, uint16 starting, uint16 cardinality) private pure returns (uint16) {
        if (starting < prevSteps) {
            return cardinality - prevSteps + starting;
        } else {
            return starting - prevSteps;
        }
    }

    
    
    
    
    
    
    function untransformCumulativesIntoTick(
        uint32 soonerTimestamp,
        int56 soonerTickCumulative,
        uint32 laterTimestamp,
        int56 laterTickCumulative
    ) private pure returns (int24 tick) {
        // "Untransform" sooner and later into the sooner's tick value
        // Assume these two observations were made within a uint32 second time window (~136 years)
        uint32 timeDelta = soonerTimestamp - laterTimestamp; // underflow is desired
        int56 tickDelta = soonerTickCumulative - laterTickCumulative;

        tick = int24(tickDelta / timeDelta);
        // Always round observed tick to negative infinity
        if (tickDelta < 0 && (tickDelta % timeDelta != 0)) tick--;
    }
}

// 
pragma solidity >=0.5.0;



///         Adapted from UniswapV3: https://github.com/Uniswap/uniswap-v3-core/blob/v1.0.0/contracts/libraries/SafeCast.sol
library SafeCast {
    
    
    
    function toUint128(uint256 y) internal pure returns (uint128 z) {
        require((z = uint128(y)) == y);
    }

    
    
    
    function toUint32(uint256 y) internal pure returns (uint32 z) {
        require((z = uint32(y)) == y);
    }
}

// 
pragma solidity >=0.4.0;




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
pragma solidity >=0.5.0;



/// prices between 2**-128 and 2**128
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
pragma solidity >=0.7.0;



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
