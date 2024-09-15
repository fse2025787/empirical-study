// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// 
pragma solidity 0.8.9;

interface IOracle {
    
    
    
    
    /// The safety indexes are:
    ///
    /// 1 - unsafe, this is typically a spot price that can be easily manipulated,
    ///
    /// 2 - 4 - more or less safe, this is typically a uniV3 oracle, where the safety is defined by the timespan of the average price
    ///
    /// 5 - safe - this is typically a chailink oracle
    
    
    
    
    
    function priceX96(
        address token0,
        address token1,
        uint256 safetyIndicesSet
    ) external view returns (uint256[] memory pricesX96, uint256[] memory safetyIndices);
}

// 
pragma solidity 0.8.9;

interface IContractMeta {
    function contractName() external view returns (string memory);
    function contractNameBytes() external view returns (bytes32);

    function contractVersion() external view returns (string memory);
    function contractVersionBytes() external view returns (bytes32);
}
// 
// OpenZeppelin Contracts v4.4.0 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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
pragma solidity =0.8.9;



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

    
    
    function protocolPerformanceFees() external view returns (uint128 token0, uint128 token1);

    
    
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
pragma solidity 0.8.9;








interface IMellowOracle is IOracle {
    
    function univ2Oracle() external view returns (IUniV2Oracle);

    
    function univ3Oracle() external view returns (IUniV3Oracle);

    
    function chainlinkOracle() external view returns (IChainlinkOracle);
}

// 
pragma solidity 0.8.9;



abstract contract ContractMeta is IContractMeta {
    // -------------------  EXTERNAL, VIEW  -------------------

    function contractName() external pure returns (string memory) {
        return _bytes32ToString(_contractName());
    }

    function contractNameBytes() external pure returns (bytes32) {
        return _contractName();
    }

    function contractVersion() external pure returns (string memory) {
        return _bytes32ToString(_contractVersion());
    }

    function contractVersionBytes() external pure returns (bytes32) {
        return _contractVersion();
    }

    // -------------------  INTERNAL, VIEW  -------------------

    function _contractName() internal pure virtual returns (bytes32);

    function _contractVersion() internal pure virtual returns (bytes32);

    function _bytes32ToString(bytes32 b) internal pure returns (string memory s) {
        s = new string(32);
        uint256 len = 32;
        for (uint256 i = 0; i < 32; ++i) {
            if (uint8(b[i]) == 0) {
                len = i;
                break;
            }
        }
        assembly {
            mstore(s, len)
            mstore(add(s, 0x20), b)
        }
    }
}
// 
pragma solidity ^0.8.0;

interface IAggregatorV3 {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

// 
pragma solidity 0.8.9;

interface IUniswapV2Factory {
    function getPair(address token0, address token1) external view returns (address);
}

// 
pragma solidity =0.8.9;



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

// 
pragma solidity >=0.5.0;








/// to the ERC20 specification

interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions
{

}

// 
pragma solidity 0.8.9;




interface IChainlinkOracle is IOracle {
    
    function safetyIndex() external view returns (uint8);

    
    
    
    function hasOracle(address token) external view returns (bool);

    
    function supportedTokens() external view returns (address[] memory);

    
    
    
    function oraclesIndex(address token) external view returns (address);

    
    
    
    function decimalsIndex(address token) external view returns (int256);

    /// Add a Chainlink price feed for a token
    
    
    function addChainlinkOracles(address[] memory tokens, address[] memory oracles) external;
}

// 
pragma solidity 0.8.9;




interface IUniV2Oracle is IOracle {
    
    function factory() external returns (IUniswapV2Factory);

    
    function safetyIndex() external view returns (uint8);
}

// 
pragma solidity 0.8.9;





interface IUniV3Oracle is IOracle {
    
    function factory() external view returns (IUniswapV3Factory);

    
    function LOW_OBS_DELTA() external view returns (uint32);

    
    function MID_OBS_DELTA() external view returns (uint32);

    
    function HIGH_OBS_DELTA() external view returns (uint32);

    
    
    
    
    function poolsIndex(address token0, address token1) external view returns (IUniswapV3Pool);

    
    
    function addUniV3Pools(IUniswapV3Pool[] memory pools) external;
}

// 
pragma solidity 0.8.9;








contract MellowOracle is ContractMeta, IMellowOracle, ERC165 {
    
    IUniV2Oracle public immutable univ2Oracle;
    
    IUniV3Oracle public immutable univ3Oracle;
    
    IChainlinkOracle public immutable chainlinkOracle;

    constructor(
        IUniV2Oracle univ2Oracle_,
        IUniV3Oracle univ3Oracle_,
        IChainlinkOracle chainlinkOracle_
    ) {
        univ2Oracle = univ2Oracle_;
        univ3Oracle = univ3Oracle_;
        chainlinkOracle = chainlinkOracle_;
    }

    // -------------------------  EXTERNAL, VIEW  ------------------------------

    function priceX96(
        address token0,
        address token1,
        uint256 safetyIndicesSet
    ) external view returns (uint256[] memory pricesX96, uint256[] memory safetyIndices) {
        IOracle[] memory oracles = _oracles();
        pricesX96 = new uint256[](6);
        safetyIndices = new uint256[](6);
        uint256 len;
        for (uint256 i = 0; i < oracles.length; i++) {
            IOracle oracle = oracles[i];
            (uint256[] memory oPrices, uint256[] memory oSafetyIndixes) = oracle.priceX96(
                token0,
                token1,
                safetyIndicesSet
            );
            for (uint256 j = 0; j < oPrices.length; j++) {
                pricesX96[len] = oPrices[j];
                safetyIndices[len] = oSafetyIndixes[j];
                len += 1;
            }
        }
        assembly {
            mstore(pricesX96, len)
            mstore(safetyIndices, len)
        }
    }

    
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return super.supportsInterface(interfaceId) || type(IOracle).interfaceId == interfaceId;
    }

    // -------------------------  INTERNAL, VIEW  ------------------------------

    function _contractName() internal pure override returns (bytes32) {
        return bytes32("MellowOracle");
    }

    function _contractVersion() internal pure override returns (bytes32) {
        return bytes32("1.0.0");
    }

    function _oracles() internal view returns (IOracle[] memory oracles) {
        oracles = new IOracle[](3);
        uint256 len;
        if (address(univ2Oracle) != address(0)) {
            oracles[len] = univ2Oracle;
            len += 1;
        }
        if (address(univ3Oracle) != address(0)) {
            oracles[len] = univ3Oracle;
            len += 1;
        }
        if (address(chainlinkOracle) != address(0)) {
            oracles[len] = chainlinkOracle;
            len += 1;
        }
        assembly {
            mstore(oracles, len)
        }
    }
}
