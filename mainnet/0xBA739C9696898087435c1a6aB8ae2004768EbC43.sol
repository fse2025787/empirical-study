// SPDX-License-Identifier: GPL-2.0-or-later
pragma abicoder v2;


// 
pragma solidity >=0.8.0;






/// to compute the result. They are also not gas efficient and should not be called on-chain.
interface IQuoterV2 {
  struct QuoteOutput {
    uint256 usedAmount;
    uint256 returnedAmount;
    uint160 afterSqrtP;
    uint32 initializedTicksCrossed;
    uint256 gasEstimate;
  }

  
  
  
  
  
  
  
  function quoteExactInput(bytes memory path, uint256 amountIn)
    external
    returns (
      uint256 amountOut,
      uint160[] memory afterSqrtPList,
      uint32[] memory initializedTicksCrossedList,
      uint256 gasEstimate
    );

  struct QuoteExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint256 amountIn;
    uint24 feeUnits;
    uint160 limitSqrtP;
  }

  
  
  /// tokenIn The token being swapped in
  /// tokenOut The token being swapped out
  /// fee The fee of the token pool to consider for the pair
  /// amountIn The desired input amount
  /// limitSqrtP The price limit of the pool that cannot be exceeded by the swap
  function quoteExactInputSingle(QuoteExactInputSingleParams memory params)
    external
    returns (QuoteOutput memory);

  
  
  
  
  
  
  
  function quoteExactOutput(bytes memory path, uint256 amountOut)
    external
    returns (
      uint256 amountIn,
      uint160[] memory afterSqrtPList,
      uint32[] memory initializedTicksCrossedList,
      uint256 gasEstimate
    );

  struct QuoteExactOutputSingleParams {
    address tokenIn;
    address tokenOut;
    uint256 amount;
    uint24 feeUnits;
    uint160 limitSqrtP;
  }

  
  
  /// tokenIn The token being swapped in
  /// tokenOut The token being swapped out
  /// fee The fee of the token pool to consider for the pair
  /// amountOut The desired output amount
  /// limitSqrtP The price limit of the pool that cannot be exceeded by the swap
  function quoteExactOutputSingle(QuoteExactOutputSingleParams memory params)
    external
    returns (QuoteOutput memory);
}

// 
pragma solidity >=0.8.0;



interface ISwapCallback {
  
  
  /// The caller of this method must be checked to be a Pool deployed by the canonical Factory.
  /// deltaQty0 and deltaQty1 can both be 0 if no tokens were swapped.
  
  /// the end of the swap. If positive, the callback must send deltaQty0 of token0 to the pool.
  
  /// the end of the swap. If positive, the callback must send deltaQty1 of token1 to the pool.
  
  function swapCallback(
    int256 deltaQty0,
    int256 deltaQty1,
    bytes calldata data
  ) external;
}

// 
pragma solidity >=0.8.0;





interface IPoolStorage {
  
  
  function factory() external view returns (IFactory);

  
  
  function token0() external view returns (IERC20);

  
  
  function token1() external view returns (IERC20);

  
  
  function swapFeeUnits() external view returns (uint24);

  
  
  /// It remains an int24 to avoid casting even though it is >= 1.
  /// e.g: a tickDistance of 5 means ticks can be initialized every 5th tick, i.e., ..., -10, -5, 0, 5, 10, ...
  
  function tickDistance() external view returns (int24);

  
  
  /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
  
  function maxTickLiquidity() external view returns (uint128);

  
  
  
  /// liquidityNet how much liquidity changes when the pool tick crosses above the tick
  /// feeGrowthOutside the fee growth on the other side of the tick relative to the current tick
  /// secondsPerLiquidityOutside the seconds spent on the other side of the tick relative to the current tick
  function ticks(int24 tick)
    external
    view
    returns (
      uint128 liquidityGross,
      int128 liquidityNet,
      uint256 feeGrowthOutside,
      uint128 secondsPerLiquidityOutside
    );

  
  
  
  function initializedTicks(int24 tick) external view returns (int24 previous, int24 next);

  
  
  
  function getPositions(
    address owner,
    int24 tickLower,
    int24 tickUpper
  ) external view returns (uint128 liquidity, uint256 feeGrowthInsideLast);

  
  
  
  
  
  function getPoolState()
    external
    view
    returns (
      uint160 sqrtP,
      int24 currentTick,
      int24 nearestCurrentTick,
      bool locked
    );

  
  
  
  
  function getLiquidityState()
    external
    view
    returns (
      uint128 baseL,
      uint128 reinvestL,
      uint128 reinvestLLast
    );

  
  function getFeeGrowthGlobal() external view returns (uint256);

  
  
  function getSecondsPerLiquidityData()
    external
    view
    returns (uint128 secondsPerLiquidityGlobal, uint32 lastUpdateTime);

  
  
  
  
  /// between the 2 ticks, per unit of liquidity.
  function getSecondsPerLiquidityInside(int24 tickLower, int24 tickUpper)
    external
    view
    returns (uint128 secondsPerLiquidityInside);
}

// 
pragma solidity >=0.8.0;

interface IPoolEvents {
  
  
  
  
  event Initialize(uint160 sqrtP, int24 tick);

  
  
  
  
  
  
  
  
  
  event Mint(
    address sender,
    address indexed owner,
    int24 indexed tickLower,
    int24 indexed tickUpper,
    uint128 qty,
    uint256 qty0,
    uint256 qty1
  );

  
  
  
  
  
  
  
  
  event Burn(
    address indexed owner,
    int24 indexed tickLower,
    int24 indexed tickUpper,
    uint128 qty,
    uint256 qty0,
    uint256 qty1
  );

  
  
  
  
  
  event BurnRTokens(address indexed owner, uint256 qty, uint256 qty0, uint256 qty1);

  
  
  
  
  
  
  
  
  event Swap(
    address indexed sender,
    address indexed recipient,
    int256 deltaQty0,
    int256 deltaQty1,
    uint160 sqrtP,
    uint128 liquidity,
    int24 currentTick
  );

  
  
  
  
  
  
  
  event Flash(
    address indexed sender,
    address indexed recipient,
    uint256 qty0,
    uint256 qty1,
    uint256 paid0,
    uint256 paid1
  );
}

// 
pragma solidity >=0.8.0;

interface IPoolActions {
  
  
  /// required for initializing reinvestment liquidity prior to calling this function
  
  
  
  function unlockPool(uint160 initialSqrtP) external returns (uint256 qty0, uint256 qty1);

  
  
  /// the IMintCallback#mintCallback is called to this method's caller
  /// The quantity of token0/token1 to be sent depends on
  /// tickLower, tickUpper, the amount of liquidity, and the current price of the pool.
  /// Also sends reinvestment tokens (fees) to the recipient for any fees collected
  /// while the position is in range
  /// Reinvestment tokens have to be burnt via #burnRTokens in exchange for token0 and token1
  
  
  
  
  
  
  
  
  
  function mint(
    address recipient,
    int24 tickLower,
    int24 tickUpper,
    int24[2] calldata ticksPrevious,
    uint128 qty,
    bytes calldata data
  )
    external
    returns (
      uint256 qty0,
      uint256 qty1,
      uint256 feeGrowthInside
    );

  
  /// Also sends reinvestment tokens (fees) to the caller for any fees collected
  /// while the position is in range
  /// Reinvestment tokens have to be burnt via #burnRTokens in exchange for token0 and token1
  
  
  
  
  
  
  function burn(
    int24 tickLower,
    int24 tickUpper,
    uint128 qty
  )
    external
    returns (
      uint256 qty0,
      uint256 qty1,
      uint256 feeGrowthInside
    );

  
  
  
  ///         otherwise should transfer token0/token1 to sender
  
  
  function burnRTokens(uint256 qty, bool isLogicalBurn)
    external
    returns (uint256 qty0, uint256 qty1);

  
  
  
  
  
  
  
  /// could be MAX_SQRT_RATIO-1 when swapping 1 -> 0 and MIN_SQRT_RATIO+1 when swapping 0 -> 1 for no limit swap
  
  
  
  function swap(
    address recipient,
    int256 swapQty,
    bool isToken0,
    uint160 limitSqrtP,
    bytes calldata data
  ) external returns (int256 qty0, int256 qty1);

  
  
  
  
  
  
  
  function flash(
    address recipient,
    uint256 qty0,
    uint256 qty1,
    bytes calldata data
  ) external;
}
// 
pragma solidity 0.8.9;
















/// the swap and check the amounts in the callback.
contract QuoterV2 is IQuoterV2, ISwapCallback {
  using PathHelper for bytes;
  using SafeCast for uint256;

  address public immutable factory;
  bytes32 internal immutable poolInitHash;

  
  uint256 private amountOutCached;

  constructor(address _factory) {
    factory = _factory;
    poolInitHash = IFactory(_factory).poolInitHash();
  }

  /**
   * @dev Returns the pool address for the requested token pair swap fee
   * Because the function calculates it instead of fetching the address from the factory,
   * the returned pool address may not be in existence yet
   */
  function _getPool(
    address tokenA,
    address tokenB,
    uint24 feeUnits
  ) private view returns (IPool) {
    return IPool(PoolAddress.computeAddress(factory, tokenA, tokenB, feeUnits, poolInitHash));
  }

  
  function swapCallback(
    int256 amount0Delta,
    int256 amount1Delta,
    bytes memory path
  ) external view override {
    require(amount0Delta > 0 || amount1Delta > 0); // swaps entirely within 0-liquidity regions are not supported
    (address tokenIn, address tokenOut, uint24 feeUnits) = path.decodeFirstPool();
    IPool pool = _getPool(tokenIn, tokenOut, feeUnits);
    require(address(pool) == msg.sender, 'invalid sender');
    (uint160 afterSqrtP, , int24 nearestCurrentTickAfter, ) = pool.getPoolState();

    (bool isExactInput, uint256 amountToPay, uint256 amountReceived) = amount0Delta > 0
      ? (tokenIn < tokenOut, uint256(amount0Delta), uint256(-amount1Delta))
      : (tokenOut < tokenIn, uint256(amount1Delta), uint256(-amount0Delta));

    if (isExactInput) {
      assembly {
        let ptr := mload(0x40)
        mstore(ptr, amountToPay)
        mstore(add(ptr, 0x20), amountReceived)
        mstore(add(ptr, 0x40), afterSqrtP)
        mstore(add(ptr, 0x60), nearestCurrentTickAfter)
        revert(ptr, 128)
      }
    } else {
      // if the cache has been populated, ensure that the full output amount has been received
      if (amountOutCached != 0) require(amountReceived == amountOutCached);
      assembly {
        let ptr := mload(0x40)
        mstore(ptr, amountReceived)
        mstore(add(ptr, 0x20), amountToPay)
        mstore(add(ptr, 0x40), afterSqrtP)
        mstore(add(ptr, 0x60), nearestCurrentTickAfter)
        revert(ptr, 128)
      }
    }
  }

  
  function _parseRevertReason(bytes memory reason)
    private
    pure
    returns (
      uint256 usedAmount,
      uint256 returnedAmount,
      uint160 afterSqrtP,
      int24 tickAfter
    )
  {
    if (reason.length != 128) {
      if (reason.length < 68) revert('Unexpected error');
      assembly {
        reason := add(reason, 0x04)
      }
      revert(abi.decode(reason, (string)));
    }
    return abi.decode(reason, (uint256, uint256, uint160, int24));
  }

  function _handleRevert(
    bytes memory reason,
    IPool pool,
    uint256 gasEstimate
  ) private view returns (QuoteOutput memory output) {
    int24 nearestCurrentTickBefore;
    int24 nearestCurrentTickAfter;
    (, , nearestCurrentTickBefore, ) = pool.getPoolState();
    (
      output.usedAmount,
      output.returnedAmount,
      output.afterSqrtP,
      nearestCurrentTickAfter
    ) = _parseRevertReason(reason);
    output.initializedTicksCrossed = PoolTicksCounter.countInitializedTicksCrossed(
      pool,
      nearestCurrentTickBefore,
      nearestCurrentTickAfter
    );
    output.gasEstimate = gasEstimate;
  }

  function quoteExactInputSingle(QuoteExactInputSingleParams memory params)
    public
    override
    returns (QuoteOutput memory output)
  {
    // if tokenIn < tokenOut, token input and specified token is token0, swap from 0 to 1
    bool isToken0 = params.tokenIn < params.tokenOut;
    IPool pool = _getPool(params.tokenIn, params.tokenOut, params.feeUnits);
    bytes memory data = abi.encodePacked(params.tokenIn, params.feeUnits, params.tokenOut);
    uint160 priceLimit = params.limitSqrtP == 0
      ? (isToken0 ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1)
      : params.limitSqrtP;
    uint256 gasBefore = gasleft();
    try pool.swap(address(this), params.amountIn.toInt256(), isToken0, priceLimit, data) {} catch (
      bytes memory reason
    ) {
      uint256 gasEstimate = gasBefore - gasleft();
      output = _handleRevert(reason, pool, gasEstimate);
    }
  }

  function quoteExactInput(bytes memory path, uint256 amountIn)
    public
    override
    returns (
      uint256 amountOut,
      uint160[] memory afterSqrtPList,
      uint32[] memory initializedTicksCrossedList,
      uint256 gasEstimate
    )
  {
    afterSqrtPList = new uint160[](path.numPools());
    initializedTicksCrossedList = new uint32[](path.numPools());

    uint256 i = 0;
    while (true) {
      (address tokenIn, address tokenOut, uint24 feeUnits) = path.decodeFirstPool();

      // the outputs of prior swaps become the inputs to subsequent ones
      QuoteOutput memory quoteOutput = quoteExactInputSingle(
        QuoteExactInputSingleParams({
          tokenIn: tokenIn,
          tokenOut: tokenOut,
          feeUnits: feeUnits,
          amountIn: amountIn,
          limitSqrtP: 0
        })
      );

      afterSqrtPList[i] = quoteOutput.afterSqrtP;
      initializedTicksCrossedList[i] = quoteOutput.initializedTicksCrossed;
      amountIn = quoteOutput.returnedAmount;
      gasEstimate += quoteOutput.gasEstimate;
      i++;

      // decide whether to continue or terminate
      if (path.hasMultiplePools()) {
        path = path.skipToken();
      } else {
        return (amountIn, afterSqrtPList, initializedTicksCrossedList, gasEstimate);
      }
    }
  }

  function quoteExactOutputSingle(QuoteExactOutputSingleParams memory params)
    public
    override
    returns (QuoteOutput memory output)
  {
    // if tokenIn > tokenOut, output token and specified token is token0, swap from token1 to token0
    bool isToken0 = params.tokenIn > params.tokenOut;
    IPool pool = _getPool(params.tokenIn, params.tokenOut, params.feeUnits);

    // if no price limit has been specified, cache the output amount for comparison in the swap callback
    if (params.limitSqrtP == 0) amountOutCached = params.amount;
    uint256 gasBefore = gasleft();
    try
      pool.swap(
        address(this), // address(0) might cause issues with some tokens
        -params.amount.toInt256(),
        isToken0,
        params.limitSqrtP == 0
          ? (isToken0 ? TickMath.MAX_SQRT_RATIO - 1 : TickMath.MIN_SQRT_RATIO + 1)
          : params.limitSqrtP,
        abi.encodePacked(params.tokenOut, params.feeUnits, params.tokenIn)
      )
    {} catch (bytes memory reason) {
      uint256 gasEstimate = gasBefore - gasleft();
      if (params.limitSqrtP == 0) delete amountOutCached; // clear cache
      output = _handleRevert(reason, pool, gasEstimate);
    }
  }

  function quoteExactOutput(bytes memory path, uint256 amountOut)
    public
    override
    returns (
      uint256 amountIn,
      uint160[] memory afterSqrtPList,
      uint32[] memory initializedTicksCrossedList,
      uint256 gasEstimate
    )
  {
    afterSqrtPList = new uint160[](path.numPools());
    initializedTicksCrossedList = new uint32[](path.numPools());

    uint256 i = 0;
    while (true) {
      (address tokenOut, address tokenIn, uint24 feeUnits) = path.decodeFirstPool();

      // the inputs of prior swaps become the outputs of subsequent ones
      QuoteOutput memory quoteOutput = quoteExactOutputSingle(
        QuoteExactOutputSingleParams({
          tokenIn: tokenIn,
          tokenOut: tokenOut,
          amount: amountOut,
          feeUnits: feeUnits,
          limitSqrtP: 0
        })
      );
      afterSqrtPList[i] = quoteOutput.afterSqrtP;
      initializedTicksCrossedList[i] = quoteOutput.initializedTicksCrossed;
      amountOut = quoteOutput.returnedAmount;
      gasEstimate += quoteOutput.gasEstimate;
      i++;

      // decide whether to continue or terminate
      if (path.hasMultiplePools()) {
        path = path.skipToken();
      } else {
        return (amountOut, afterSqrtPList, initializedTicksCrossedList, gasEstimate);
      }
    }
  }
}

// 
// (c) 2023 Lyfeloop, Inc.
pragma solidity >=0.8.0;



interface IFactory {
  
  
  
  
  
  
  event PoolCreated(
    address indexed token0,
    address indexed token1,
    uint24 indexed swapFeeUnits,
    int24 tickDistance,
    address pool
  );

  
  
  
  event SwapFeeEnabled(uint24 indexed swapFeeUnits, int24 indexed tickDistance);

  
  
  /// are proportionally burnt upon LP removals
  event VestingPeriodUpdated(uint32 vestingPeriod);

  
  
  
  event ConfigMasterUpdated(address oldConfigMaster, address newConfigMaster);

  
  
  
  /// to be collected out of the fee charged for a pool swap
  event FeeConfigurationUpdated(address feeTo, uint24 governmentFeeUnits);

  
  event WhitelistEnabled();

  
  event WhitelistDisabled();

  
  /// are proportionally burnt upon LP removals
  function vestingPeriod() external view returns (uint32);

  
  
  
  
  function feeAmountTickDistance(uint24 swapFeeUnits) external view returns (int24);

  
  function configMaster() external view returns (address);

  
  /// This is used for pre-computation of pool addresses
  function poolInitHash() external view returns (bytes32);

  
  /// and current government fee charged in fee units
  function feeConfiguration() external view returns (address _feeTo, uint24 _governmentFeeUnits);

  
  /// If true, anyone can mint liquidity tokens
  /// Otherwise, only whitelisted NFT manager(s) are allowed to mint liquidity tokens
  function whitelistDisabled() external view returns (bool);

  
  /// If the whitelisting feature is turned on,
  /// only whitelisted NFT manager(s) are allowed to mint liquidity tokens
  function getWhitelistedNFTManagers() external view returns (address[] memory);

  
  /// If the whitelisting feature is turned on,
  /// only whitelisted NFT manager(s) are allowed to mint liquidity tokens
  
  
  function isWhitelistedNFTManager(address sender) external view returns (bool);

  
  
  
  
  
  
  function getPool(
    address tokenA,
    address tokenB,
    uint24 swapFeeUnits
  ) external view returns (address pool);

  
  
  
  
  
  
  
  function parameters()
    external
    view
    returns (
      address factory,
      address token0,
      address token1,
      uint24 swapFeeUnits,
      int24 tickDistance
    );

  
  
  
  
  
  /// Call will revert under any of these conditions:
  ///     1) pool already exists
  ///     2) invalid swap fee
  ///     3) invalid token arguments
  
  function createPool(
    address tokenA,
    address tokenB,
    uint24 swapFeeUnits
  ) external returns (address pool);

  
  
  
  
  function enableSwapFee(uint24 swapFeeUnits, int24 tickDistance) external;

  
  
  function updateConfigMaster(address) external;

  
  
  function updateVestingPeriod(uint32) external;

  
  
  
  
  /// to be collected out of the fee charged for a pool swap
  function updateFeeConfiguration(address feeTo, uint24 governmentFeeUnits) external;

  
  
  function enableWhitelist() external;

  
  
  function disableWhitelist() external;
}

// 
pragma solidity >=0.8.0;





interface IPool is IPoolActions, IPoolEvents, IPoolStorage {}

// 
pragma solidity 0.8.9;



library PoolTicksCounter {
  function countInitializedTicksCrossed(
    IPool self,
    int24 nearestCurrentTickBefore,
    int24 nearestCurrentTickAfter
  ) internal view returns (uint32 initializedTicksCrossed) {
    initializedTicksCrossed = 0;
    (int24 tickLower, int24 tickUpper) = (nearestCurrentTickBefore < nearestCurrentTickAfter)
      ? (nearestCurrentTickBefore, nearestCurrentTickAfter)
      : (nearestCurrentTickAfter, nearestCurrentTickBefore);
    while (tickLower != tickUpper) {
      initializedTicksCrossed++;
      (, tickLower) = self.initializedTicks(tickLower);
    }
  }
}

// 
pragma solidity 0.8.9;


library PoolAddress {
  
  
  
  
  
  
  
  function computeAddress(
    address factory,
    address token0,
    address token1,
    uint24 swapFee,
    bytes32 poolInitHash
  ) internal pure returns (address pool) {
    (token0, token1) = token0 < token1 ? (token0, token1) : (token1, token0);
    bytes32 hashed = keccak256(
      abi.encodePacked(
        hex'ff',
        factory,
        keccak256(abi.encode(token0, token1, swapFee)),
        poolInitHash
      )
    );
    pool = address(uint160(uint256(hashed)));
  }
}

// 
pragma solidity 0.8.9;




library PathHelper {
  using BytesLib for bytes;

  
  uint256 private constant ADDR_SIZE = 20;
  
  uint256 private constant FEE_SIZE = 3;

  
  uint256 private constant TOKEN_AND_POOL_OFFSET = ADDR_SIZE + FEE_SIZE;
  
  uint256 private constant POOL_DATA_OFFSET = TOKEN_AND_POOL_OFFSET + ADDR_SIZE;
  
  uint256 private constant MULTIPLE_POOLS_MIN_LENGTH = POOL_DATA_OFFSET + TOKEN_AND_POOL_OFFSET;

  
  
  
  function hasMultiplePools(bytes memory path) internal pure returns (bool) {
    return path.length >= MULTIPLE_POOLS_MIN_LENGTH;
  }

  
  
  
  function numPools(bytes memory path) internal pure returns (uint256) {
    // Ignore the first token address. From then on every fee and token offset indicates a pool.
    return ((path.length - ADDR_SIZE) / TOKEN_AND_POOL_OFFSET);
  }

  
  
  
  
  
  function decodeFirstPool(bytes memory path)
    internal
    pure
    returns (
      address tokenA,
      address tokenB,
      uint24 fee
    )
  {
    tokenA = path.toAddress(0);
    fee = path.toUint24(ADDR_SIZE);
    tokenB = path.toAddress(TOKEN_AND_POOL_OFFSET);
  }

  
  
  
  function getFirstPool(bytes memory path) internal pure returns (bytes memory) {
    return path.slice(0, POOL_DATA_OFFSET);
  }

  
  
  
  function skipToken(bytes memory path) internal pure returns (bytes memory) {
    return path.slice(TOKEN_AND_POOL_OFFSET, path.length - TOKEN_AND_POOL_OFFSET);
  }
}

// 
pragma solidity >=0.8.0;



/// prices between 2**-128 and 2**128
library TickMath {
  
  int24 internal constant MIN_TICK = -887272;
  
  int24 internal constant MAX_TICK = -MIN_TICK;

  
  uint160 internal constant MIN_SQRT_RATIO = 4295128739;
  
  uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

  
  
  
  
  /// at the given tick
  function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtP) {
    unchecked {
      uint256 absTick = uint256(tick < 0 ? -int256(tick) : int256(tick));
      require(absTick <= uint256(int256(MAX_TICK)), 'T');

      // do bitwise comparison, if i-th bit is turned on,
      // multiply ratio by hardcoded values of sqrt(1.0001^-(2^i)) * 2^128
      // where 0 <= i <= 19
      uint256 ratio = (absTick & 0x1 != 0)
        ? 0xfffcb933bd6fad37aa2d162d1a594001
        : 0x100000000000000000000000000000000;
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

      // take reciprocal for positive tick values
      if (tick > 0) ratio = type(uint256).max / ratio;

      // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
      // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
      // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
      sqrtP = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }
  }

  
  
  /// ever return.
  
  
  function getTickAtSqrtRatio(uint160 sqrtP) internal pure returns (int24 tick) {
    // second inequality must be < because the price can never reach the price at the max tick
    require(sqrtP >= MIN_SQRT_RATIO && sqrtP < MAX_SQRT_RATIO, 'R');
    uint256 ratio = uint256(sqrtP) << 32;

    uint256 r = ratio;
    uint256 msb = 0;

    unchecked {
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

      tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtP ? tickHi : tickLow;
    }
  }

  function getMaxNumberTicks(int24 _tickDistance) internal pure returns (uint24 numTicks) {
    return uint24(TickMath.MAX_TICK / _tickDistance) * 2;
  }
}

// 
pragma solidity >=0.8.0;



library SafeCast {
  
  
  
  function toUint32(uint256 y) internal pure returns (uint32 z) {
    require((z = uint32(y)) == y);
  }

  
  
  
  function toInt128(uint128 y) internal pure returns (int128 z) {
    require(y < 2**127);
    z = int128(y);
  }

  
  
  
  function toUint128(uint256 y) internal pure returns (uint128 z) {
    require((z = uint128(y)) == y);
  }

  
  
  
  function revToUint128(int128 y) internal pure returns (uint128 z) {
    unchecked {
      return type(uint128).max - uint128(y) + 1;
    }
  }

  
  
  
  function toUint160(uint256 y) internal pure returns (uint160 z) {
    require((z = uint160(y)) == y);
  }

  
  
  
  function toInt256(uint256 y) internal pure returns (int256 z) {
    require(y < 2**255);
    z = int256(y);
  }

  
  
  
  function revToInt256(uint256 y) internal pure returns (int256 z) {
    require(y < 2**255);
    z = -int256(y);
  }

  
  
  
  function revToUint256(int256 y) internal pure returns (uint256 z) {
    unchecked {
      return type(uint256).max - uint256(y) + 1;
    }
  }
}

// 
/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <[email protected]>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */
pragma solidity 0.8.9;

library BytesLib {
  function slice(
    bytes memory _bytes,
    uint256 _start,
    uint256 _length
  ) internal pure returns (bytes memory) {
    require(_length + 31 >= _length, 'slice_overflow');
    require(_bytes.length >= _start + _length, 'slice_outOfBounds');

    bytes memory tempBytes;

    assembly {
      switch iszero(_length)
      case 0 {
        // Get a location of some free memory and store it in tempBytes as
        // Solidity does for memory variables.
        tempBytes := mload(0x40)

        // The first word of the slice result is potentially a partial
        // word read from the original array. To read it, we calculate
        // the length of that partial word and start copying that many
        // bytes into the array. The first word we copy will start with
        // data we don't care about, but the last `lengthmod` bytes will
        // land at the beginning of the contents of the new array. When
        // we're done copying, we overwrite the full first word with
        // the actual length of the slice.
        let lengthmod := and(_length, 31)

        // The multiplication in the next line is necessary
        // because when slicing multiples of 32 bytes (lengthmod == 0)
        // the following copy loop was copying the origin's length
        // and then ending prematurely not copying everything it should.
        let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
        let end := add(mc, _length)

        for {
          // The multiplication in the next line has the same exact purpose
          // as the one above.
          let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
        } lt(mc, end) {
          mc := add(mc, 0x20)
          cc := add(cc, 0x20)
        } {
          mstore(mc, mload(cc))
        }

        mstore(tempBytes, _length)

        // update free-memory pointer
        // allocating the array padded to 32 bytes like the compiler does now
        mstore(0x40, and(add(mc, 31), not(31)))
      }
      //if we want a zero-length slice let's just return a zero-length array
      default {
        tempBytes := mload(0x40)
        // zero out the 32 bytes slice we are about to return
        // we need to do it because Solidity does not garbage collect
        mstore(tempBytes, 0)

        mstore(0x40, add(tempBytes, 0x20))
      }
    }
    return tempBytes;
  }

  function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
    require(_bytes.length >= _start + 20, 'toAddress_outOfBounds');
    address tempAddress;

    assembly {
      tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
    }

    return tempAddress;
  }

  function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {
    require(_bytes.length >= _start + 2, 'toUint16_outOfBounds');
    uint16 tempUint;

    assembly {
      tempUint := mload(add(add(_bytes, 0x2), _start))
    }

    return tempUint;
  }

  function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {
    require(_bytes.length >= _start + 3, 'toUint24_outOfBounds');
    uint24 tempUint;

    assembly {
      tempUint := mload(add(add(_bytes, 0x3), _start))
    }

    return tempUint;
  }
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