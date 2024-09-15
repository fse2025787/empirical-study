// SPDX-License-Identifier: GPL-2.0-or-later
pragma abicoder v2;


// 
pragma solidity >=0.8.0;

interface IRouterTokenHelper {
  
  
  
  
  function unwrapWeth(uint256 minAmount, address recipient) external payable;

  
  
  /// that use ether for the input amount
  function refundEth() external payable;

  
  
  
  
  
  function transferAllTokens(
    address token,
    uint256 minAmount,
    address recipient
  ) external payable;
}

// 
pragma solidity 0.8.9;





abstract contract ImmutablePeripheryStorage {
  address public immutable factory;
  address public immutable WETH;
  bytes32 internal immutable poolInitHash;

  constructor(address _factory, address _WETH) {
    factory = _factory;
    WETH = _WETH;
    poolInitHash = IFactory(_factory).poolInitHash();
  }
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




interface IMulticall {
  
  
  
  
  function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);
}

// 
pragma solidity >=0.8.0;



interface IRouterTokenHelperWithFee is IRouterTokenHelper {
  
  /// 0 (exclusive), and 1 (inclusive) going to feeRecipient
  
  function unwrapWethWithFee(
    uint256 minAmount,
    address recipient,
    uint256 feeUnits,
    address feeRecipient
  ) external payable;

  
  /// 0 (exclusive) and 1 (inclusive) going to feeRecipient
  
  function transferAllTokensWithFee(
    address token,
    uint256 minAmount,
    address recipient,
    uint256 feeBips,
    address feeRecipient
  ) external payable;
}

// 
pragma solidity 0.8.9;










abstract contract RouterTokenHelper is IRouterTokenHelper, ImmutablePeripheryStorage {
  constructor(address _factory, address _WETH) ImmutablePeripheryStorage(_factory, _WETH) {}

  receive() external payable {
    require(msg.sender == WETH, 'Not WETH');
  }

  
  function unwrapWeth(uint256 minAmount, address recipient) external payable override {
    uint256 balanceWETH = IWETH(WETH).balanceOf(address(this));
    require(balanceWETH >= minAmount, 'Insufficient WETH');

    if (balanceWETH > 0) {
      IWETH(WETH).withdraw(balanceWETH);
      TokenHelper.transferEth(recipient, balanceWETH);
    }
  }

  
  function transferAllTokens(
    address token,
    uint256 minAmount,
    address recipient
  ) public payable virtual override {
    uint256 balanceToken = IERC20(token).balanceOf(address(this));
    require(balanceToken >= minAmount, 'Insufficient token');

    if (balanceToken > 0) {
      TokenHelper.transferToken(IERC20(token), balanceToken, address(this), recipient);
    }
  }

  
  function refundEth() external payable override {
    if (address(this).balance > 0) TokenHelper.transferEth(msg.sender, address(this).balance);
  }

  
  function _transferTokens(
    address token,
    address sender,
    address recipient,
    uint256 tokenAmount
  ) internal {
    if (token == WETH && address(this).balance >= tokenAmount) {
      IWETH(WETH).deposit{value: tokenAmount}();
      IWETH(WETH).transfer(recipient, tokenAmount);
    } else {
      TokenHelper.transferToken(IERC20(token), tokenAmount, sender, recipient);
    }
  }
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// 
pragma solidity >=0.8.0;





/// - Support swap with exact input or exact output
/// - Support swap with a price limit
/// - Support swap within a single pool and between multiple pools
interface IRouter is ISwapCallback {
  
  
  
  
  
  
  
  
  
  struct ExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 minAmountOut;
    uint160 limitSqrtP;
  }

  
  
  
  function swapExactInputSingle(ExactInputSingleParams calldata params)
    external
    payable
    returns (uint256 amountOut);

  
  
  ///   If the swap is from token0 -> token1 -> token2, then path is encoded as [token0, fee01, token1, fee12, token2]
  
  
  
  
  struct ExactInputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 minAmountOut;
  }

  
  
  
  function swapExactInput(ExactInputParams calldata params)
    external
    payable
    returns (uint256 amountOut);

  
  
  
  
  
  
  
  
  
  struct ExactOutputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 deadline;
    uint256 amountOut;
    uint256 maxAmountIn;
    uint160 limitSqrtP;
  }

  
  
  
  function swapExactOutputSingle(ExactOutputSingleParams calldata params)
    external
    payable
    returns (uint256 amountIn);

  
  
  ///   If the swap is from token0 -> token1 -> token2, then path is encoded as [token2, fee12, token1, fee01, token0]
  
  
  
  
  struct ExactOutputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountOut;
    uint256 maxAmountIn;
  }

  
  
  
  function swapExactOutput(ExactOutputParams calldata params)
    external
    payable
    returns (uint256 amountIn);
}

// 
pragma solidity 0.8.9;


abstract contract DeadlineValidation {
  modifier onlyNotExpired(uint256 deadline) {
    require(_blockTimestamp() <= deadline, 'Expired');
    _;
  }

  
  function _blockTimestamp() internal view virtual returns (uint256) {
    return block.timestamp;
  }
}

// 
pragma solidity 0.8.9;






abstract contract Multicall is IMulticall {
  
  function multicall(bytes[] calldata data)
    external
    payable
    override
    returns (bytes[] memory results)
  {
    results = new bytes[](data.length);
    for (uint256 i = 0; i < data.length; i++) {
      (bool success, bytes memory result) = address(this).delegatecall(data[i]);

      if (!success) {
        // Next 5 lines from https://ethereum.stackexchange.com/a/83577
        if (result.length < 68) revert();
        assembly {
          result := add(result, 0x04)
        }
        revert(abi.decode(result, (string)));
      }
      results[i] = result;
    }
  }
}

// 
pragma solidity 0.8.9;










abstract contract RouterTokenHelperWithFee is RouterTokenHelper, IRouterTokenHelperWithFee {
  uint256 constant FEE_UNITS = 100000;

  constructor(address _factory, address _WETH) RouterTokenHelper(_factory, _WETH) {}

  function unwrapWethWithFee(
    uint256 minAmount,
    address recipient,
    uint256 feeUnits,
    address feeRecipient
  ) public payable override {
    require(feeUnits > 0 && feeUnits <= 1000, 'High fee');

    uint256 balanceWETH = IWETH(WETH).balanceOf(address(this));
    require(balanceWETH >= minAmount, 'Insufficient WETH');

    if (balanceWETH > 0) {
      IWETH(WETH).withdraw(balanceWETH);
      uint256 feeAmount = (balanceWETH * feeUnits) / FEE_UNITS;
      if (feeAmount > 0) TokenHelper.transferEth(feeRecipient, feeAmount);
      TokenHelper.transferEth(recipient, balanceWETH - feeAmount);
    }
  }

  function transferAllTokensWithFee(
    address token,
    uint256 minAmount,
    address recipient,
    uint256 feeUnits,
    address feeRecipient
  ) public payable override {
    require(feeUnits > 0 && feeUnits <= 1000, 'High fee');

    uint256 balanceToken = IERC20(token).balanceOf(address(this));
    require(balanceToken >= minAmount, 'Insufficient token');

    if (balanceToken > 0) {
      uint256 feeAmount = (balanceToken * feeUnits) / FEE_UNITS;
      if (feeAmount > 0)
        TokenHelper.transferToken(IERC20(token), feeAmount, address(this), feeRecipient);
      TokenHelper.transferToken(IERC20(token), balanceToken - feeAmount, address(this), recipient);
    }
  }
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
pragma solidity 0.8.9;



















contract Router is IRouter, RouterTokenHelperWithFee, Multicall, DeadlineValidation {
  using PathHelper for bytes;
  using SafeCast for uint256;

  
  uint256 private constant DEFAULT_AMOUNT_IN_CACHED = type(uint256).max;

  
  uint256 private amountInCached = DEFAULT_AMOUNT_IN_CACHED;

  constructor(address _factory, address _WETH) RouterTokenHelperWithFee(_factory, _WETH) {}

  struct SwapCallbackData {
    bytes path;
    address source;
  }

  function swapCallback(
    int256 deltaQty0,
    int256 deltaQty1,
    bytes calldata data
  ) external override {
    require(deltaQty0 > 0 || deltaQty1 > 0, 'Router: invalid delta qties');
    SwapCallbackData memory swapData = abi.decode(data, (SwapCallbackData));
    (address tokenIn, address tokenOut, uint24 fee) = swapData.path.decodeFirstPool();
    require(
      msg.sender == address(_getPool(tokenIn, tokenOut, fee)),
      'Router: invalid callback sender'
    );

    (bool isExactInput, uint256 amountToTransfer) = deltaQty0 > 0
      ? (tokenIn < tokenOut, uint256(deltaQty0))
      : (tokenOut < tokenIn, uint256(deltaQty1));
    if (isExactInput) {
      // transfer token from source to the pool which is the msg.sender
      // wrap eth -> weth and transfer if needed
      _transferTokens(tokenIn, swapData.source, msg.sender, amountToTransfer);
    } else {
      if (swapData.path.hasMultiplePools()) {
        swapData.path = swapData.path.skipToken();
        _swapExactOutputInternal(amountToTransfer, msg.sender, 0, swapData);
      } else {
        amountInCached = amountToTransfer;
        // transfer tokenOut to the pool (it's the original tokenIn)
        // wrap eth -> weth and transfer if user uses passes eth with the swap
        _transferTokens(tokenOut, swapData.source, msg.sender, amountToTransfer);
      }
    }
  }

  function swapExactInputSingle(ExactInputSingleParams calldata params)
    external
    payable
    override
    onlyNotExpired(params.deadline)
    returns (uint256 amountOut)
  {
    amountOut = _swapExactInputInternal(
      params.amountIn,
      params.recipient,
      params.limitSqrtP,
      SwapCallbackData({
        path: abi.encodePacked(params.tokenIn, params.fee, params.tokenOut),
        source: msg.sender
      })
    );
    require(amountOut >= params.minAmountOut, 'Router: insufficient amountOut');
  }

  function swapExactInput(ExactInputParams memory params)
    external
    payable
    override
    onlyNotExpired(params.deadline)
    returns (uint256 amountOut)
  {
    address source = msg.sender; // msg.sender is the source of tokenIn for the first swap

    while (true) {
      bool hasMultiplePools = params.path.hasMultiplePools();

      params.amountIn = _swapExactInputInternal(
        params.amountIn,
        hasMultiplePools ? address(this) : params.recipient, // for intermediate swaps, this contract custodies
        0,
        SwapCallbackData({path: params.path.getFirstPool(), source: source})
      );

      if (hasMultiplePools) {
        source = address(this);
        params.path = params.path.skipToken();
      } else {
        amountOut = params.amountIn;
        break;
      }
    }

    require(amountOut >= params.minAmountOut, 'Router: insufficient amountOut');
  }

  function swapExactOutputSingle(ExactOutputSingleParams calldata params)
    external
    payable
    override
    onlyNotExpired(params.deadline)
    returns (uint256 amountIn)
  {
    amountIn = _swapExactOutputInternal(
      params.amountOut,
      params.recipient,
      params.limitSqrtP,
      SwapCallbackData({
        path: abi.encodePacked(params.tokenOut, params.fee, params.tokenIn),
        source: msg.sender
      })
    );
    require(amountIn <= params.maxAmountIn, 'Router: amountIn is too high');
    // has to be reset even though we don't use it in the single hop case
    amountInCached = DEFAULT_AMOUNT_IN_CACHED;
  }

  function swapExactOutput(ExactOutputParams calldata params)
    external
    payable
    override
    onlyNotExpired(params.deadline)
    returns (uint256 amountIn)
  {
    _swapExactOutputInternal(
      params.amountOut,
      params.recipient,
      0,
      SwapCallbackData({path: params.path, source: msg.sender})
    );

    amountIn = amountInCached;
    require(amountIn <= params.maxAmountIn, 'Router: amountIn is too high');
    amountInCached = DEFAULT_AMOUNT_IN_CACHED;
  }

  
  function _swapExactInputInternal(
    uint256 amountIn,
    address recipient,
    uint160 limitSqrtP,
    SwapCallbackData memory data
  ) private returns (uint256 amountOut) {
    // allow swapping to the router address with address 0
    if (recipient == address(0)) recipient = address(this);

    (address tokenIn, address tokenOut, uint24 fee) = data.path.decodeFirstPool();

    bool isFromToken0 = tokenIn < tokenOut;

    (int256 amount0, int256 amount1) = _getPool(tokenIn, tokenOut, fee).swap(
      recipient,
      amountIn.toInt256(),
      isFromToken0,
      limitSqrtP == 0
        ? (isFromToken0 ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1)
        : limitSqrtP,
      abi.encode(data)
    );
    return uint256(-(isFromToken0 ? amount1 : amount0));
  }

  
  function _swapExactOutputInternal(
    uint256 amountOut,
    address recipient,
    uint160 limitSqrtP,
    SwapCallbackData memory data
  ) private returns (uint256 amountIn) {
    // consider address 0 as the router address
    if (recipient == address(0)) recipient = address(this);

    (address tokenOut, address tokenIn, uint24 fee) = data.path.decodeFirstPool();

    bool isFromToken0 = tokenOut < tokenIn;

    (int256 amount0Delta, int256 amount1Delta) = _getPool(tokenIn, tokenOut, fee).swap(
      recipient,
      -amountOut.toInt256(),
      isFromToken0,
      limitSqrtP == 0
        ? (isFromToken0 ? TickMath.MAX_SQRT_RATIO - 1 : TickMath.MIN_SQRT_RATIO + 1)
        : limitSqrtP,
      abi.encode(data)
    );

    uint256 receivedAmountOut;
    (amountIn, receivedAmountOut) = isFromToken0
      ? (uint256(amount1Delta), uint256(-amount0Delta))
      : (uint256(amount0Delta), uint256(-amount1Delta));

    // if no price limit has been specified, receivedAmountOut should be equals to amountOut
    assert(limitSqrtP != 0 || receivedAmountOut == amountOut);
  }

  
  ///   Because the function calculates it instead of fetching the address from the factory,
  ///   the returned pool address may not be in existence yet
  function _getPool(
    address tokenA,
    address tokenB,
    uint24 fee
  ) private view returns (IPool) {
    return IPool(PoolAddress.computeAddress(factory, tokenA, tokenB, fee, poolInitHash));
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
pragma solidity >=0.8.0;





interface IPool is IPoolActions, IPoolEvents, IPoolStorage {}

// 
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




interface IWETH is IERC20 {
  
  function deposit() external payable;

  
  function withdraw(uint256) external;
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
pragma solidity 0.8.9;





library TokenHelper {
  using SafeERC20 for IERC20;

  
  
  ///   otherwise, tansfer tokens from the sender to the receiver
  function transferToken(
    IERC20 token,
    uint256 amount,
    address sender,
    address receiver
  ) internal {
    if (sender == address(this)) {
      token.safeTransfer(receiver, amount);
    } else {
      token.safeTransferFrom(sender, receiver, amount);
    }
  }

  
  function transferEth(address receiver, uint256 amount) internal {
    if (receiver == address(this)) return;
    (bool success, ) = payable(receiver).call{value: amount}('');
    require(success, 'transfer eth failed');
  }
}

// 

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

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
