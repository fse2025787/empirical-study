// SPDX-License-Identifier: ISC
pragma abicoder v2;


// 
pragma solidity 0.7.5;




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
pragma solidity 0.7.5;




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
pragma solidity 0.7.5;





interface IUniswapV3StateMulticall {
    struct Slot0 {
        uint160 sqrtPriceX96;
        int24 tick;
        uint16 observationIndex;
        uint16 observationCardinality;
        uint16 observationCardinalityNext;
        uint8 feeProtocol;
        bool unlocked;
    }

    struct TickBitMapMappings {
        int16 index;
        uint256 value;
    }

    struct TickInfo {
        uint128 liquidityGross;
        int128 liquidityNet;
        int56 tickCumulativeOutside;
        uint160 secondsPerLiquidityOutsideX128;
        uint32 secondsOutside;
        bool initialized;
    }

    struct TickInfoMappings {
        int24 index;
        TickInfo value;
    }

    struct Observation {
        uint32 blockTimestamp;
        int56 tickCumulative;
        uint160 secondsPerLiquidityCumulativeX128;
        bool initialized;
    }

    struct StateResult {
        IUniswapV3Pool pool;
        uint256 blockTimestamp;
        Slot0 slot0;
        uint128 liquidity;
        int24 tickSpacing;
        uint128 maxLiquidityPerTick;
        Observation observation;
        TickBitMapMappings[] tickBitmap;
        TickInfoMappings[] ticks;
    }

    function getFullState(
        IUniswapV3Factory factory,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        int16 tickBitmapStart,
        int16 tickBitmapEnd
    ) external view returns (StateResult memory state);

    function getFullStateWithoutTicks(
        IUniswapV3Factory factory,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        int16 tickBitmapStart,
        int16 tickBitmapEnd
    ) external view returns (StateResult memory state);

    function getFullStateWithRelativeBitmaps(
        IUniswapV3Factory factory,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        int16 leftBitmapAmount,
        int16 rightBitmapAmount
    ) external view returns (StateResult memory state);

    function getAdditionalBitmapWithTicks(
        IUniswapV3Factory factory,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        int16 tickBitmapStart,
        int16 tickBitmapEnd
    ) external view returns (TickBitMapMappings[] memory tickBitmap, TickInfoMappings[] memory ticks);

    function getAdditionalBitmapWithoutTicks(
        IUniswapV3Factory factory,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        int16 tickBitmapStart,
        int16 tickBitmapEnd
    ) external view returns (TickBitMapMappings[] memory tickBitmap);
}// 
pragma solidity 0.7.5;






contract UniswapV3StateMulticall is IUniswapV3StateMulticall {
    function getFullState(
        IUniswapV3Factory factory,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        int16 tickBitmapStart,
        int16 tickBitmapEnd
    ) external view override returns (StateResult memory state) {
        require(tickBitmapEnd >= tickBitmapStart, "tickBitmapEnd < tickBitmapStart");

        state = _fillStateWithoutTicks(factory, tokenIn, tokenOut, fee, tickBitmapStart, tickBitmapEnd);
        state.ticks = _calcTicksFromBitMap(factory, tokenIn, tokenOut, fee, state.tickBitmap);
    }

    function getFullStateWithoutTicks(
        IUniswapV3Factory factory,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        int16 tickBitmapStart,
        int16 tickBitmapEnd
    ) external view override returns (StateResult memory state) {
        require(tickBitmapEnd >= tickBitmapStart, "tickBitmapEnd < tickBitmapStart");

        return _fillStateWithoutTicks(factory, tokenIn, tokenOut, fee, tickBitmapStart, tickBitmapEnd);
    }

    function getFullStateWithRelativeBitmaps(
        IUniswapV3Factory factory,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        int16 leftBitmapAmount,
        int16 rightBitmapAmount
    ) external view override returns (StateResult memory state) {
        require(leftBitmapAmount > 0, "leftBitmapAmount <= 0");
        require(rightBitmapAmount > 0, "rightBitmapAmount <= 0");

        state = _fillStateWithoutBitmapsAndTicks(factory, tokenIn, tokenOut, fee);
        int16 currentBitmapIndex = _getBitmapIndexFromTick(state.slot0.tick / state.tickSpacing);

        state.tickBitmap = _calcTickBitmaps(
            factory,
            tokenIn,
            tokenOut,
            fee,
            currentBitmapIndex - leftBitmapAmount,
            currentBitmapIndex + rightBitmapAmount
        );
        state.ticks = _calcTicksFromBitMap(factory, tokenIn, tokenOut, fee, state.tickBitmap);
    }

    function getAdditionalBitmapWithTicks(
        IUniswapV3Factory factory,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        int16 tickBitmapStart,
        int16 tickBitmapEnd
    ) external view override returns (TickBitMapMappings[] memory tickBitmap, TickInfoMappings[] memory ticks) {
        require(tickBitmapEnd >= tickBitmapStart, "tickBitmapEnd < tickBitmapStart");

        tickBitmap = _calcTickBitmaps(factory, tokenIn, tokenOut, fee, tickBitmapStart, tickBitmapEnd);
        ticks = _calcTicksFromBitMap(factory, tokenIn, tokenOut, fee, tickBitmap);
    }

    function getAdditionalBitmapWithoutTicks(
        IUniswapV3Factory factory,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        int16 tickBitmapStart,
        int16 tickBitmapEnd
    ) external view override returns (TickBitMapMappings[] memory tickBitmap) {
        require(tickBitmapEnd >= tickBitmapStart, "tickBitmapEnd < tickBitmapStart");

        return _calcTickBitmaps(factory, tokenIn, tokenOut, fee, tickBitmapStart, tickBitmapEnd);
    }

    function _fillStateWithoutTicks(
        IUniswapV3Factory factory,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        int16 tickBitmapStart,
        int16 tickBitmapEnd
    ) internal view returns (StateResult memory state) {
        state = _fillStateWithoutBitmapsAndTicks(factory, tokenIn, tokenOut, fee);
        state.tickBitmap = _calcTickBitmaps(factory, tokenIn, tokenOut, fee, tickBitmapStart, tickBitmapEnd);
    }

    function _fillStateWithoutBitmapsAndTicks(
        IUniswapV3Factory factory,
        address tokenIn,
        address tokenOut,
        uint24 fee
    ) internal view returns (StateResult memory state) {
        IUniswapV3Pool pool = _getPool(factory, tokenIn, tokenOut, fee);

        state.pool = pool;
        state.blockTimestamp = block.timestamp;
        state.liquidity = pool.liquidity();
        state.tickSpacing = pool.tickSpacing();
        state.maxLiquidityPerTick = pool.maxLiquidityPerTick();

        (
            state.slot0.sqrtPriceX96,
            state.slot0.tick,
            state.slot0.observationIndex,
            state.slot0.observationCardinality,
            state.slot0.observationCardinalityNext,
            state.slot0.feeProtocol,
            state.slot0.unlocked
        ) = pool.slot0();

        (
            state.observation.blockTimestamp,
            state.observation.tickCumulative,
            state.observation.secondsPerLiquidityCumulativeX128,
            state.observation.initialized
        ) = pool.observations(state.slot0.observationIndex);
    }

    function _calcTickBitmaps(
        IUniswapV3Factory factory,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        int16 tickBitmapStart,
        int16 tickBitmapEnd
    ) internal view returns (TickBitMapMappings[] memory tickBitmap) {
        IUniswapV3Pool pool = _getPool(factory, tokenIn, tokenOut, fee);

        uint256 numberOfPopulatedBitmaps = 0;
        for (int256 i = tickBitmapStart; i <= tickBitmapEnd; i++) {
            uint256 bitmap = pool.tickBitmap(int16(i));
            if (bitmap == 0) continue;
            numberOfPopulatedBitmaps++;
        }

        tickBitmap = new TickBitMapMappings[](numberOfPopulatedBitmaps);
        uint256 globalIndex = 0;
        for (int256 i = tickBitmapStart; i <= tickBitmapEnd; i++) {
            int16 index = int16(i);
            uint256 bitmap = pool.tickBitmap(index);
            if (bitmap == 0) continue;

            tickBitmap[globalIndex] = TickBitMapMappings({ index: index, value: bitmap });
            globalIndex++;
        }
    }

    function _calcTicksFromBitMap(
        IUniswapV3Factory factory,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        TickBitMapMappings[] memory tickBitmap
    ) internal view returns (TickInfoMappings[] memory ticks) {
        IUniswapV3Pool pool = _getPool(factory, tokenIn, tokenOut, fee);

        uint256 numberOfPopulatedTicks = 0;
        for (uint256 i = 0; i < tickBitmap.length; i++) {
            uint256 bitmap = tickBitmap[i].value;

            for (uint256 j = 0; j < 256; j++) {
                if (bitmap & (1 << j) > 0) numberOfPopulatedTicks++;
            }
        }

        ticks = new TickInfoMappings[](numberOfPopulatedTicks);
        int24 tickSpacing = pool.tickSpacing();

        uint256 globalIndex = 0;
        for (uint256 i = 0; i < tickBitmap.length; i++) {
            uint256 bitmap = tickBitmap[i].value;

            for (uint256 j = 0; j < 256; j++) {
                if (bitmap & (1 << j) > 0) {
                    int24 populatedTick = ((int24(tickBitmap[i].index) << 8) + int24(j)) * tickSpacing;

                    ticks[globalIndex].index = populatedTick;
                    TickInfo memory newTickInfo = ticks[globalIndex].value;

                    (
                        newTickInfo.liquidityGross,
                        newTickInfo.liquidityNet,
                        ,
                        ,
                        newTickInfo.tickCumulativeOutside,
                        newTickInfo.secondsPerLiquidityOutsideX128,
                        newTickInfo.secondsOutside,
                        newTickInfo.initialized
                    ) = pool.ticks(populatedTick);

                    globalIndex++;
                }
            }
        }
    }

    function _getPool(
        IUniswapV3Factory factory,
        address tokenIn,
        address tokenOut,
        uint24 fee
    ) internal view returns (IUniswapV3Pool pool) {
        pool = IUniswapV3Pool(factory.getPool(tokenIn, tokenOut, fee));
        require(address(pool) != address(0), "Pool does not exist");
    }

    function _getBitmapIndexFromTick(int24 tick) internal pure returns (int16) {
        return int16(tick >> 8);
    }
}

// 
pragma solidity 0.7.5;







/// to the ERC20 specification

// solhint-disable-next-line no-empty-blocks
interface IUniswapV3Pool is IUniswapV3PoolImmutables, IUniswapV3PoolState {

}

// 
pragma solidity 0.7.5;




interface IUniswapV3Factory {
    
    
    
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    
    
    
    
    
    
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    
    
    
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    
    
    
    function owner() external view returns (address);

    
    
    
    
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    
    
    
    
    
    
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    
    
    
    
    
    /// from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
    /// are invalid.
    
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    
    
    
    function setOwner(address _owner) external;

    
    
    
    
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}
