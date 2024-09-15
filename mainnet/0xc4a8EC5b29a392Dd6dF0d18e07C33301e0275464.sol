// SPDX-License-Identifier: GPL-2.0-or-later
pragma abicoder v2;


pragma solidity >=0.7.6;

interface IULMEvents {
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        address indexed pool,
        uint24 fee,
        uint160 sqrtPriceX96
    );

    event PoolReajusted(
        address pool,
        uint128 baseLiquidity,
        uint128 rangeLiquidity,
        int24 newBaseTickLower,
        int24 newBaseTickUpper,
        int24 newRangeTickLower,
        int24 newRangeTickUpper
    );

    event Deposited(
        address indexed pool,
        uint256 tokenId,
        uint256 amount0,
        uint256 amount1,
        uint256 liquidity
    );

    event Collect(
        uint256 tokenId,
        uint256 userAmount0,
        uint256 userAmount1,
        uint256 pilotAmount,
        address pool,
        address recipient
    );

    event Withdrawn(
        address indexed pool,
        address indexed recipient,
        uint256 tokenId,
        uint256 amount0,
        uint256 amount1
    );
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
}// 

pragma solidity >=0.7.6;





contract ULMState {
    function getPositionDetails(uint256 tokenId, address liquidityManagerAddress)
        external
        view
        returns (
            address pool,
            address token0,
            address token1,
            int24 currentTick,
            uint24 fee,
            uint256 liquidity,
            uint256 amount0,
            uint256 amount1,
            uint256 totalLiquidity
        )
    {
        IUniswapLiquidityManager liquidityManager = IUniswapLiquidityManager(
            liquidityManagerAddress
        );
        IUniswapLiquidityManager.Position memory userPosition = liquidityManager
            .userPositions(tokenId);
        (amount0, amount1, totalLiquidity) = liquidityManager.updatePositionTotalAmounts(
            userPosition.pool
        );
        (token0, token1, fee, , , , currentTick) = getPoolDetails(userPosition.pool);
        pool = userPosition.pool;
        liquidity = userPosition.liquidity;
    }

    function getPoolDetails(address pool)
        public
        view
        returns (
            address token0,
            address token1,
            uint24 fee,
            uint16 poolCardinality,
            uint128 liquidity,
            uint160 sqrtPriceX96,
            int24 currentTick
        )
    {
        IUniswapV3Pool uniswapPool = IUniswapV3Pool(pool);
        token0 = uniswapPool.token0();
        token1 = uniswapPool.token1();
        fee = uniswapPool.fee();
        liquidity = uniswapPool.liquidity();
        (sqrtPriceX96, currentTick, , poolCardinality, , , ) = uniswapPool.slot0();
    }
}

// 

pragma solidity >=0.7.6;




interface IUniswapLiquidityManager is IULMEvents {
    struct LiquidityPosition {
        // base order position
        int24 baseTickLower;
        int24 baseTickUpper;
        uint128 baseLiquidity;
        // range order position
        int24 rangeTickLower;
        int24 rangeTickUpper;
        uint128 rangeLiquidity;
        // accumulated fees
        uint256 fees0;
        uint256 fees1;
        uint256 feeGrowthGlobal0;
        uint256 feeGrowthGlobal1;
        // total liquidity
        uint256 totalLiquidity;
        // pool premiums
        bool feesInPilot;
        // oracle address for tokens to fetch prices from
        address oracle0;
        address oracle1;
        // rebase
        uint256 timestamp;
        uint8 counter;
        bool status;
        bool managed;
    }

    struct Position {
        uint256 nonce;
        address pool;
        uint256 liquidity;
        uint256 feeGrowth0;
        uint256 feeGrowth1;
        uint256 tokensOwed0;
        uint256 tokensOwed1;
    }

    struct ReadjustVars {
        bool zeroForOne;
        address poolAddress;
        int24 currentTick;
        uint160 sqrtPriceX96;
        uint160 exactSqrtPriceImpact;
        uint160 sqrtPriceLimitX96;
        uint128 baseLiquidity;
        uint256 amount0;
        uint256 amount1;
        uint256 amountIn;
        uint256 amount0Added;
        uint256 amount1Added;
        uint256 amount0Range;
        uint256 amount1Range;
        uint256 currentTimestamp;
        uint256 gasUsed;
        uint256 pilotAmount;
    }

    struct VarsEmerency {
        address token;
        address pool;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
    }

    struct WithdrawVars {
        address recipient;
        uint256 amount0Removed;
        uint256 amount1Removed;
        uint256 userAmount0;
        uint256 userAmount1;
        uint256 pilotAmount;
    }

    struct WithdrawTokenOwedParams {
        address token0;
        address token1;
        uint256 tokensOwed0;
        uint256 tokensOwed1;
    }

    struct MintCallbackData {
        address payer;
        address token0;
        address token1;
        uint24 fee;
    }

    struct UnipilotProtocolDetails {
        uint8 swapPercentage;
        uint24 swapPriceThreshold;
        uint256 premium;
        uint256 gasPriceLimit;
        uint256 userPilotPercentage;
        uint256 feesPercentageIndexFund;
        address pilotWethPair;
        address oracle;
        address indexFund; // 10%
        address uniStrategy;
        address unipilot;
    }

    struct SwapCallbackData {
        address token0;
        address token1;
        uint24 fee;
    }

    struct AddLiquidityParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
    }

    struct RemoveLiquidity {
        uint256 amount0;
        uint256 amount1;
        uint128 liquidityRemoved;
        uint256 feesCollected0;
        uint256 feesCollected1;
    }

    struct Tick {
        int24 baseTickLower;
        int24 baseTickUpper;
        int24 bidTickLower;
        int24 bidTickUpper;
        int24 rangeTickLower;
        int24 rangeTickUpper;
    }

    struct TokenDetails {
        address token0;
        address token1;
        uint24 fee;
        int24 currentTick;
        uint16 poolCardinality;
        uint128 baseLiquidity;
        uint128 bidLiquidity;
        uint128 rangeLiquidity;
        uint256 amount0Added;
        uint256 amount1Added;
    }

    struct DistributeFeesParams {
        bool pilotToken;
        bool wethToken;
        address pool;
        address recipient;
        uint256 tokenId;
        uint256 liquidity;
        uint256 amount0Removed;
        uint256 amount1Removed;
    }

    struct AddLiquidityManagerParams {
        address pool;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 shares;
    }

    struct DepositVars {
        uint24 fee;
        address pool;
        uint256 amount0Base;
        uint256 amount1Base;
        uint256 amount0Range;
        uint256 amount1Range;
    }

    struct RangeLiquidityVars {
        address token0;
        address token1;
        uint24 fee;
        uint128 rangeLiquidity;
        uint256 amount0Range;
        uint256 amount1Range;
    }

    struct IncreaseParams {
        address token0;
        address token1;
        uint24 fee;
        int24 currentTick;
        uint128 baseLiquidity;
        uint256 baseAmount0;
        uint256 baseAmount1;
        uint128 rangeLiquidity;
        uint256 rangeAmount0;
        uint256 rangeAmount1;
    }

    
    
    
    
    
    function uniswapV3MintCallback(
        uint256 amount0Owed,
        uint256 amount1Owed,
        bytes calldata data
    ) external;

    
    
    
    
    
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;

    
    
    
    /// - nonce The nonce for permits
    /// - pool Address of the uniswap V3 pool
    /// - liquidity The liquidity of the position
    /// - feeGrowth0 The fee growth of token0 as of the last action on the individual position
    /// - feeGrowth1 The fee growth of token1 as of the last action on the individual position
    /// - tokensOwed0 The uncollected amount of token0 owed to the position as of the last computation
    /// - tokensOwed1 The uncollected amount of token1 owed to the position as of the last computation
    function userPositions(uint256 tokenId) external view returns (Position memory);

    
    
    
    /// - baseTickLower The lower tick of the base position
    /// - baseTickUpper The upper tick of the base position
    /// - baseLiquidity The total liquidity of the base position
    /// - rangeTickLower The lower tick of the range position
    /// - rangeTickUpper The upper tick of the range position
    /// - rangeLiquidity The total liquidity of the range position
    /// - fees0 Total amount of fees collected by unipilot positions in terms of token0
    /// - fees1 Total amount of fees collected by unipilot positions in terms of token1
    /// - feeGrowthGlobal0 The fee growth of token0 collected per unit of liquidity for
    /// the entire life of the unipilot vault
    /// - feeGrowthGlobal1 The fee growth of token1 collected per unit of liquidity for
    /// the entire life of the unipilot vault
    /// - totalLiquidity Total amount of liquidity of vault including base & range orders
    function poolPositions(address pool) external view returns (LiquidityPosition memory);

    
    /// other words, how much of each token the vault would hold if it withdrew
    /// all its liquidity from Uniswap.
    
    
    
    
    function updatePositionTotalAmounts(address _pool)
        external
        view
        returns (
            uint256 amount0,
            uint256 amount1,
            uint256 totalLiquidity
        );

    
    /// other words, how much of each token the vault would hold if it withdrew
    /// all its liquidity from Uniswap.
    
    
    
    
    
    
    
    function getReserves(
        address token0,
        address token1,
        bytes calldata data
    )
        external
        returns (
            uint256 totalAmount0,
            uint256 totalAmount1,
            uint256 totalLiquidity
        );

    
    
    
    
    /// In data we will provide the `fee` amount of the v3 pool for the specified token pair,
    /// also `sqrtPriceX96` The initial square root price of the pool
    
    function createPair(
        address _token0,
        address _token1,
        bytes memory data
    ) external returns (address _pool);

    
    /// `Unipilot`s NFT.
    
    
    
    
    
    
    
    
    function deposit(
        address token0,
        address token1,
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 shares,
        uint256 tokenId,
        bool isTokenMinted,
        bytes memory data
    ) external payable;

    
    
    
    
    
    
    function withdraw(
        bool pilotToken,
        bool wethToken,
        uint256 liquidity,
        uint256 tokenId,
        bytes memory data
    ) external payable;

    
    
    
    
    
    
    function collect(
        bool pilotToken,
        bool wethToken,
        uint256 tokenId,
        bytes memory data
    ) external payable;
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
