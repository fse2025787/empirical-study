// SPDX-License-Identifier: MIT
pragma abicoder v2;


// 
pragma solidity 0.8.16;




interface CTokenLike {
  error TransferComptrollerRejection(uint256);

  function balanceOf(address holder) external returns (uint);
  function borrow(uint amount) external returns (uint);
  function transfer(address dst, uint256 amt) external returns (bool);
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
  function redeem(uint redeemTokens) external returns (uint);
  function borrowBalanceCurrent(address account) external returns (uint);
  function approve(address spender, uint256 amount) external returns (bool);
  function exchangeRateCurrent() external returns (uint);
  function exchangeRateStored() external view returns (uint);
}

// 
pragma solidity 0.8.16;

/**
 * @title IERC20NonStandard
 * @dev Version of ERC20 with no return values for `transfer` and `transferFrom`
 *  See https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
 */
interface IERC20NonStandard {
    function approve(address spender, uint256 amount) external;
    function transfer(address to, uint256 value) external;
    function transferFrom(address from, address to, uint256 value) external;
    function balanceOf(address account) external view returns (uint256);
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
pragma solidity >=0.5.0;



interface IUniswapV3FlashCallback {
    
    
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    
    
    
    function uniswapV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external;
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3SwapCallback {
    
    
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
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
pragma solidity 0.8.16;










/**
 * @title Compound III Migrator v2
 * @notice A contract to help migrate a Compound II or Aave v2 position into a similar Compound III position.
 * @author Compound
 */
contract CometMigratorV2 is IUniswapV3FlashCallback {
  error Reentrancy(uint256 loc);
  error CompoundV2Error(uint256 loc, uint256 code);
  error SweepFailure(uint256 loc);
  error CTokenTransferFailure();
  error InvalidConfiguration(uint256 loc);
  error InvalidCallback(uint256 loc);
  error InvalidInputs(uint256 loc);
  error ERC20TransferFailure(uint256 loc);

  /** Events **/
  event Migrated(
    address indexed user,
    CompoundV2Position compoundV2Position,
    AaveV2Position aaveV2Position,
    uint256 flashAmount,
    uint256 flashAmountWithFee);

  event Sweep(
    address indexed sweeper,
    address indexed recipient,
    address indexed asset,
    uint256 amount);

  
  struct Swap {
    bytes path; // empty path if no swap is required (e.g. repaying USDC borrow)
    uint256 amountInMaximum; // Note: Can be set as `type(uint256).max`
  }

  
  struct CompoundV2Position {
    CompoundV2Collateral[] collateral;
    CompoundV2Borrow[] borrows;
    Swap[] swaps;
  }

  
  struct CompoundV2Collateral {
    CTokenLike cToken;
    uint256 amount; // Note: This is the amount of the cToken
  }

  
  struct CompoundV2Borrow {
    CTokenLike cToken;
    uint256 amount; // Note: This is the amount of the underlying, not the cToken
  }

  
  struct AaveV2Position {
    AaveV2Collateral[] collateral;
    AaveV2Borrow[] borrows;
    Swap[] swaps;
  }

  
  struct AaveV2Collateral {
    ATokenLike aToken;
    uint256 amount;
  }

  
  struct AaveV2Borrow {
    ADebtTokenLike aDebtToken; // Note: Aave has two separate debt tokens per asset: stable and variable rate
    uint256 amount;
  }

  
  struct MigrationCallbackData {
    address user;
    uint256 flashAmount;
    CompoundV2Position compoundV2Position;
    AaveV2Position aaveV2Position;
  }

  
  Comet public immutable comet;

  
  IUniswapV3Pool public immutable uniswapLiquidityPool;

  
  bool public immutable isUniswapLiquidityPoolToken0;

  
  ISwapRouter public immutable swapRouter;

  
  IERC20NonStandard public immutable baseToken;

  
  CTokenLike public immutable cETH;

  
  IWETH9 public immutable weth;

  
  ILendingPool public immutable aaveV2LendingPool;

  
  address payable public immutable sweepee;

  
  uint256 public inMigration;

  /**
   * @notice Construct a new CometMigratorV2
   * @param comet_ The Comet Ethereum mainnet USDC contract.
   * @param baseToken_ The base token of the Compound III market (e.g. `USDC`).
   * @param cETH_ The address of the `cETH` token.
   * @param weth_ The address of the `WETH9` token.
   * @param aaveV2LendingPool_ The address of the Aave v2 LendingPool contract. This is the contract that all `withdraw` and `repay` transactions go through.
   * @param uniswapLiquidityPool_ The Uniswap pool used by this contract to source liquidity (i.e. flash loans).
   * @param swapRouter_ The Uniswap router for facilitating token swaps.
   * @param sweepee_ Sweep excess tokens to this address.
   **/
  constructor(
    Comet comet_,
    IERC20NonStandard baseToken_,
    CTokenLike cETH_,
    IWETH9 weth_,
    ILendingPool aaveV2LendingPool_,
    IUniswapV3Pool uniswapLiquidityPool_,
    ISwapRouter swapRouter_,
    address payable sweepee_
  ) {
    // **WRITE IMMUTABLE** `comet = comet_`
    comet = comet_;

    // **WRITE IMMUTABLE** `baseToken = baseToken_`
    baseToken = baseToken_;

    // **WRITE IMMUTABLE** `cETH = cETH_`
    cETH = cETH_;

    // **WRITE IMMUTABLE** `weth = weth_`
    weth = weth_;

    // **WRITE IMMUTABLE** `aaveV2LendingPool = aaveV2LendingPool_`
    aaveV2LendingPool = aaveV2LendingPool_;

    // **WRITE IMMUTABLE** `uniswapLiquidityPool = uniswapLiquidityPool_`
    uniswapLiquidityPool = uniswapLiquidityPool_;

    // **WRITE IMMUTABLE** `isUniswapLiquidityPoolToken0 = uniswapLiquidityPool.token0() == baseToken`
    isUniswapLiquidityPoolToken0 = uniswapLiquidityPool.token0() == address(baseToken);

    // **REQUIRE** `isUniswapLiquidityPoolToken0 || uniswapLiquidityPool.token1() == baseToken`
    if (!isUniswapLiquidityPoolToken0 && uniswapLiquidityPool.token1() != address(baseToken)) {
      revert InvalidConfiguration(0);
    }

    // **WRITE IMMUTABLE** `swapRouter = swapRouter_`
    swapRouter = swapRouter_;

    // **WRITE IMMUTABLE** `sweepee = sweepee_`
    sweepee = sweepee_;

    // **CALL** `baseToken.approve(address(swapRouter), type(uint256).max)`
    baseToken.approve(address(swapRouter), type(uint256).max);
  }

  /**
   * @notice This is the core function of this contract, migrating a position from Compound II to Compound III. We use a flash loan from Uniswap to provide liquidity to move the position.
   * @param compoundV2Position Structure containing the user’s Compound II collateral and borrow positions to migrate to Compound III. See notes below.
   * @param aaveV2Position Structure containing the user’s Aave v2 collateral and borrow positions to migrate to Compound III. See notes below.
   * @param flashAmount Amount of base asset to borrow from the Uniswap flash loan to facilitate the migration. See notes below.
   * @dev **N.B.** Collateral requirements may be different in Compound II and Compound III. This may lead to a migration failing or being less collateralized after the migration. There are fees associated with the flash loan, which may affect position or cause migration to fail.
   * @dev Note: each `collateral` market must be supported in Compound III.
   * @dev Note: `collateral` amounts of 0 are strictly ignored. Collateral amounts of max uint256 are set to the user's current balance.
   * @dev Note: `flashAmount` is provided by the user as a hint to the Migrator to know the maximum expected cost (in terms of the base asset) of the migration. If `flashAmount` is less than the total amount needed to migrate the user’s positions, the transaction will revert.
   **/
  function migrate(CompoundV2Position calldata compoundV2Position, AaveV2Position calldata aaveV2Position, uint256 flashAmount) external {
    // **REQUIRE** `inMigration == 0`
    if (inMigration != 0) {
      revert Reentrancy(0);
    }

    // **STORE** `inMigration += 1`
    inMigration += 1;

    // **BIND** `user = msg.sender`
    address user = msg.sender;

    // **REQUIRE** `compoundV2Position.borrows.length == compoundV2Position.swaps.length`
    if (compoundV2Position.borrows.length != compoundV2Position.swaps.length) {
      revert InvalidInputs(0);
    }

    // **REQUIRE** `aaveV2Position.borrows.length == aaveV2Position.swaps.length`
    if (aaveV2Position.borrows.length != aaveV2Position.swaps.length) {
      revert InvalidInputs(1);
    }

    // **BIND** `data = abi.encode(MigrationCallbackData{user, flashAmount, compoundV2Position, aaveV2Position, makerPositions})`
    bytes memory data = abi.encode(MigrationCallbackData({
      user: user,
      flashAmount: flashAmount,
      compoundV2Position: compoundV2Position,
      aaveV2Position: aaveV2Position
    }));

    // **CALL** `uniswapLiquidityPool.flash(address(this), isUniswapLiquidityPoolToken0 ? flashAmount : 0, isUniswapLiquidityPoolToken0 ? 0 : flashAmount, data)`
    uniswapLiquidityPool.flash(address(this), isUniswapLiquidityPoolToken0 ? flashAmount : 0, isUniswapLiquidityPoolToken0 ? 0 : flashAmount, data);

    // **STORE** `inMigration -= 1`
    inMigration -= 1;
  }

  /**
   * @notice This function handles a callback from the Uniswap Liquidity Pool after it has sent this contract the requested tokens. We are responsible for repaying those tokens, with a fee, before we return from this function call.
   * @param fee0 The fee for borrowing token0 from pool.
   * @param fee1 The fee for borrowing token1 from pool.
   * @param data The data encoded above, which is the ABI-encoding of `MigrationCallbackData`.
   **/
  function uniswapV3FlashCallback(uint256 fee0, uint256 fee1, bytes calldata data) external {
    // **REQUIRE** `inMigration == 1`
    if (inMigration != 1) {
      revert Reentrancy(1);
    }

    // **REQUIRE** `msg.sender == uniswapLiquidityPool`
    if (msg.sender != address(uniswapLiquidityPool)) {
      revert InvalidCallback(0);
    }

    // **BIND** `MigrationCallbackData{user, flashAmount, compoundV2Position, aaveV2Position, cdpPositions} = abi.decode(data, (MigrationCallbackData))`
    MigrationCallbackData memory migrationData = abi.decode(data, (MigrationCallbackData));

    // **BIND** `flashAmountWithFee = flashAmount + isUniswapLiquidityPoolToken0 ? fee0 : fee1`
    uint256 flashAmountWithFee = migrationData.flashAmount + ( isUniswapLiquidityPoolToken0 ? fee0 : fee1 );

    // **EXEC** `migrateCompoundV2Position(user, compoundV2Position)`
    migrateCompoundV2Position(migrationData.user, migrationData.compoundV2Position);

    // **EXEC** `migrateAaveV2Position(user, aaveV2Position)`
    migrateAaveV2Position(migrationData.user, migrationData.aaveV2Position);

    // **WHEN** `baseToken.balanceOf(address(this)) < flashAmountWithFee`:
    uint256 baseTokenBalance = baseToken.balanceOf(address(this));
    if (baseTokenBalance < flashAmountWithFee) {
      // **CALL** `comet.withdrawFrom(user, address(this), baseToken, flashAmountWithFee - baseToken.balanceOf(address(this)))`
      comet.withdrawFrom(migrationData.user, address(this), address(baseToken), flashAmountWithFee - baseTokenBalance);
    }

    // **CALL** `baseToken.transfer(address(uniswapLiquidityPool), flashAmountWithFee)`
    if (!doTransferOut(baseToken, address(uniswapLiquidityPool), flashAmountWithFee)) {
      revert ERC20TransferFailure(0);
    }

    // **EMIT** `Migrated(user, compoundV2Position, aaveV2Position, cdpPositions, flashAmount, flashAmountWithFee)`
    emit Migrated(migrationData.user, migrationData.compoundV2Position, migrationData.aaveV2Position, migrationData.flashAmount, flashAmountWithFee);
  }

  /**
   * @notice This internal helper function repays the user’s borrow positions on Compound II (executing swaps first if necessary) before migrating their collateral over to Compound III.
   * @param user Alias for the `msg.sender` of the original `migrate` call.
   * @param position Structure containing the user’s Compound II collateral and borrow positions to migrate to Compound III.
   **/
  function migrateCompoundV2Position(address user, CompoundV2Position memory position) internal {
    // **FOREACH** `(cToken, borrowAmount): CompoundV2Borrow, swap: Swap` in `position`:
    for (uint i = 0; i < position.borrows.length; i++) {
      CompoundV2Borrow memory borrow = position.borrows[i];

      uint256 repayAmount;
      // **WHEN** `borrowAmount == type(uint256).max)`:
      if (borrow.amount == type(uint256).max) {
        // **BIND READ** `repayAmount = cToken.borrowBalanceCurrent(user)`
        repayAmount = borrow.cToken.borrowBalanceCurrent(user);
      } else {
        // **BIND** `repayAmount = borrowAmount`
        repayAmount = borrow.amount;
      }

      // **WHEN** `swap.path.length > 0`:
      if (position.swaps[i].path.length > 0) {
        // **CALL** `ISwapRouter.exactOutput(ExactOutputParams({path: swap.path, recipient: address(this), amountOut: repayAmount, amountInMaximum: swap.amountInMaximum})`
        uint256 amountIn = swapRouter.exactOutput(
          ISwapRouter.ExactOutputParams({
              path: position.swaps[i].path,
              recipient: address(this),
              amountOut: repayAmount,
              amountInMaximum: position.swaps[i].amountInMaximum,
              deadline: block.timestamp
          })
        );
      }

      // **WHEN** `cToken == cETH`
      if (borrow.cToken == cETH) {
        CEther cToken = CEther(address(borrow.cToken));

        // **CALL** `weth.withdraw(repayAmount)`
        weth.withdraw(repayAmount);

        // **CALL** `cToken.repayBorrowBehalf{value: repayAmount}(user)
        cToken.repayBorrowBehalf{ value: repayAmount }(user);
      } else {
        CErc20 cToken = CErc20(address(borrow.cToken));

        // **CALL** `cToken.underlying().approve(address(cToken), repayAmount)`
        IERC20NonStandard(cToken.underlying()).approve(address(borrow.cToken), repayAmount);

        // **CALL** `cToken.repayBorrowBehalf(user, repayAmount)`
        uint256 err = cToken.repayBorrowBehalf(user, repayAmount);
        if (err != 0) {
          revert CompoundV2Error(0, err);
        }
      }
    }

    // **FOREACH** `(cToken, amount): CompoundV2Collateral` in `position.collateral`:
    for (uint i = 0; i < position.collateral.length; i++) {
      CompoundV2Collateral memory collateral = position.collateral[i];

      // **BIND** `cTokenAmount = amount == type(uint256).max ? cToken.balanceOf(user) : amount)`
      uint256 cTokenAmount = collateral.amount == type(uint256).max ? collateral.cToken.balanceOf(user) : collateral.amount;

      // **CALL** `cToken.transferFrom(user, address(this), cTokenAmount)`
      bool transferSuccess = collateral.cToken.transferFrom(
        user,
        address(this),
        cTokenAmount
      );
      if (!transferSuccess) {
        revert CTokenTransferFailure();
      }

      // **CALL** `cToken.redeem(cTokenAmount)`
      uint256 err = collateral.cToken.redeem(cTokenAmount);
      if (err != 0) {
        revert CompoundV2Error(1 + i, err);
      }

      // Note: Safe to use `exchangeRateStored` since `accrue` is already called in `redeem`
      // **BIND** `underlyingCollateralAmount = collateral.cToken.exchangeRateStored() * cTokenAmount / 1e18`
      uint256 underlyingCollateralAmount = collateral.cToken.exchangeRateStored() * cTokenAmount / 1e18;

      IERC20NonStandard underlying;

      // **WHEN** `cToken == cETH`:
      if (collateral.cToken == cETH) {
        // **CALL** `weth.deposit{value: underlyingCollateralAmount}()`
        weth.deposit{value: underlyingCollateralAmount}();

        // **BIND** `underlying = weth`
        underlying = weth;
      } else {
        // **BIND** `underlying = cToken.underlying()`
        underlying = IERC20NonStandard(CErc20(address(collateral.cToken)).underlying());
      }

      // **CALL** `underlying.approve(address(comet), underlyingCollateralAmount)`
      underlying.approve(address(comet), underlyingCollateralAmount);

      // **CALL** `comet.supplyTo(user, underlying, underlyingCollateralAmount)`
      comet.supplyTo(
        user,
        address(underlying),
        underlyingCollateralAmount
      );
    }
  }

  /**
   * @notice This internal helper function repays the user’s borrow positions on Aave v2 (executing swaps first if necessary) before migrating their collateral over to Compound III.
   * @param user Alias for the `msg.sender` of the original `migrate` call.
   * @param position Structure containing the user’s Aave v2 collateral and borrow positions to migrate to Compound III.
   **/
  function migrateAaveV2Position(address user, AaveV2Position memory position) internal {
    // **FOREACH** `(aDebtToken, borrowAmount): AaveV2Borrow, swap: Swap` in `position`:
    for (uint i = 0; i < position.borrows.length; i++) {
      AaveV2Borrow memory borrow = position.borrows[i];
      uint256 repayAmount;
      //  **WHEN** `borrowAmount == type(uint256).max)`:
      if (borrow.amount == type(uint256).max) {
        // **BIND READ** `repayAmount = aDebtToken.balanceOf(user)`
        repayAmount = borrow.aDebtToken.balanceOf(user);
      } else {
        //  **BIND** `repayAmount = borrowAmount`
        repayAmount = borrow.amount;
      }
      // **WHEN** `swap.path.length > 0`:
      if (position.swaps[i].path.length > 0) {
        // **CALL** `ISwapRouter.exactOutput(ExactOutputParams({path: swap.path, recipient: address(this), amountOut: repayAmount, amountInMaximum: swap.amountInMaximum})`
        uint256 amountIn = swapRouter.exactOutput(
          ISwapRouter.ExactOutputParams({
              path: position.swaps[i].path,
              recipient: address(this),
              amountOut: repayAmount,
              amountInMaximum: position.swaps[i].amountInMaximum,
              deadline: block.timestamp
          })
        );
      }

      // **BIND READ** `underlyingDebt = aDebtToken.UNDERLYING_ASSET_ADDRESS()`
      IERC20NonStandard underlyingDebt = IERC20NonStandard(borrow.aDebtToken.UNDERLYING_ASSET_ADDRESS());

      // **BIND READ** `rateMode = aDebtToken.DEBT_TOKEN_REVISION()`
      uint256 rateMode = borrow.aDebtToken.DEBT_TOKEN_REVISION();

      // **CALL** `underlyingDebt.approve(address(aaveV2LendingPool), repayAmount)`
      underlyingDebt.approve(address(aaveV2LendingPool), repayAmount);

      // **CALL** `aaveV2LendingPool.repay(underlyingDebt, repayAmount, rateMode, user)`
      aaveV2LendingPool.repay(address(underlyingDebt), repayAmount, rateMode, user);
    }

    // **FOREACH** `(aToken, amount): AaveV2Collateral` in `position.collateral`:
    for (uint i = 0; i < position.collateral.length; i++) {
      AaveV2Collateral memory collateral = position.collateral[i];

      // **BIND** `aTokenAmount = amount == type(uint256).max ? aToken.balanceOf(user) : amount)`
      uint256 aTokenAmount = collateral.amount == type(uint256).max ? collateral.aToken.balanceOf(user) : collateral.amount;

      // **CALL** `aToken.transferFrom(user, address(this), aTokenAmount)`
      collateral.aToken.transferFrom(
        user,
        address(this),
        aTokenAmount
      );

      // **BIND READ** `underlyingCollateral = aToken.UNDERLYING_ASSET_ADDRESS()`
      IERC20NonStandard underlyingCollateral = IERC20NonStandard(collateral.aToken.UNDERLYING_ASSET_ADDRESS());

      // **CALL** `aaveV2LendingPool.withdraw(underlyingCollateral, aTokenAmount, address(this))`
      aaveV2LendingPool.withdraw(address(underlyingCollateral), aTokenAmount, address(this));

      // **CALL** `underlyingCollateral.approve(address(comet), aTokenAmount)`
      underlyingCollateral.approve(address(comet), aTokenAmount);

      // **CALL** `comet.supplyTo(user, underlyingCollateral, aTokenAmount)`
      comet.supplyTo(
        user,
        address(underlyingCollateral),
        aTokenAmount
      );
    }
  }

  /**
    * @notice Similar to ERC-20 transfer, except it also properly handles `transfer` from non-standard ERC-20 tokens.
    * @param asset The ERC-20 token to transfer out.
    * @param to The recipient of the token transfer.
    * @param amount The amount of the token to transfer.
    * @return Boolean indicating the success of the transfer.
    * @dev Note: This wrapper safely handles non-standard ERC-20 tokens that do not return a value. See here: https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
    **/
  function doTransferOut(IERC20NonStandard asset, address to, uint amount) internal returns (bool) {
      asset.transfer(to, amount);

      bool success;
      assembly {
          switch returndatasize()
              case 0 {                      // This is a non-standard ERC-20
                  success := not(0)          // set success to true
              }
              case 32 {                     // This is a compliant ERC-20
                  returndatacopy(0, 0, 32)
                  success := mload(0)        // Set `success = returndata` of override external call
              }
              default {                     // This is an excessively non-compliant ERC-20, revert.
                  revert(0, 0)
              }
      }
      return success;
  }

  /**
   * @notice Sends any tokens in this contract to the sweepee address. This contract should never hold tokens, so this is just to fix any anomalistic situations where tokens end up locked in the contract.
   * @param token The token to sweep
   **/
  function sweep(IERC20NonStandard token) external {
    // **REQUIRE** `inMigration == 0`
    if (inMigration != 0) {
      revert Reentrancy(2);
    }

    // **WHEN** `token == 0x0000000000000000000000000000000000000000`:
    if (token == IERC20NonStandard(0x0000000000000000000000000000000000000000)) {
      // **EXEC** `sweepee.send(address(this).balance)`
      uint256 amount = address(this).balance;
      if (!sweepee.send(amount)) {
        revert SweepFailure(0);
      }

      // **EMIT** `Sweep(msg.sender, sweepee, address(0), address(this).balance)`
      emit Sweep(msg.sender, sweepee, address(0), amount);
    } else {
      // **CALL** `token.transfer(sweepee, token.balanceOf(address(this)))`
      uint256 amount = token.balanceOf(address(this));
      if (!doTransferOut(token, sweepee, amount)) {
        revert SweepFailure(1);
      }

      // **EMIT** `Sweep(msg.sender, sweepee, address(token), token.balanceOf(address(this)))`
      emit Sweep(msg.sender, sweepee, address(token), amount);
    }
  }

  receive() external payable {
    // NO-OP
  }
}

// 
pragma solidity 0.8.16;



interface ATokenLike is IERC20 {
  /**
   * @dev Returns the address of the underlying asset of this aToken (E.g. WETH for aWETH)
   **/
  function UNDERLYING_ASSET_ADDRESS() external view returns (address);
}

interface ADebtTokenLike is IERC20 {
    function approveDelegation(address delegatee, uint256 amount) external;
    function DEBT_TOKEN_REVISION() external view returns (uint);
    function UNDERLYING_ASSET_ADDRESS() external view returns (address);
}

interface ILendingPool {
  /**
   * @dev Withdraws an `amount` of underlying asset from the reserve, burning the equivalent aTokens owned
   * E.g. User has 100 aUSDC, calls withdraw() and receives 100 USDC, burning the 100 aUSDC
   * @param asset The address of the underlying asset to withdraw
   * @param amount The underlying amount to be withdrawn
   *   - Send the value type(uint256).max in order to withdraw the whole aToken balance
   * @param to Address that will receive the underlying, same as msg.sender if the user
   *   wants to receive it on his own wallet, or a different address if the beneficiary is a
   *   different wallet
   * @return The final amount withdrawn
   **/
  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256);

  /**
   * @dev Allows users to borrow a specific `amount` of the reserve underlying asset, provided that the borrower
   * already deposited enough collateral, or he was given enough allowance by a credit delegator on the
   * corresponding debt token (StableDebtToken or VariableDebtToken)
   * - E.g. User borrows 100 USDC passing as `onBehalfOf` his own address, receiving the 100 USDC in his wallet
   *   and 100 stable/variable debt tokens, depending on the `interestRateMode`
   * @param asset The address of the underlying asset to borrow
   * @param amount The amount to be borrowed
   * @param interestRateMode The interest rate mode at which the user wants to borrow: 1 for Stable, 2 for Variable
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the action is executed directly by the user, without any middle-man
   * @param onBehalfOf Address of the user who will receive the debt. Should be the address of the borrower itself
   * calling the function if he wants to borrow against his own collateral, or the address of the credit delegator
   * if he has been given credit delegation allowance
   **/
  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referralCode,
    address onBehalfOf
  ) external;

  /**
   * @notice Repays a borrowed `amount` on a specific reserve, burning the equivalent debt tokens owned
   * - E.g. User repays 100 USDC, burning 100 variable/stable debt tokens of the `onBehalfOf` address
   * @param asset The address of the borrowed underlying asset previously borrowed
   * @param amount The amount to repay
   * - Send the value type(uint256).max in order to repay the whole debt for `asset` on the specific `debtMode`
   * @param rateMode The interest rate mode at of the debt the user wants to repay: 1 for Stable, 2 for Variable
   * @param onBehalfOf Address of the user who will get his debt reduced/removed. Should be the address of the
   * user calling the function if he wants to reduce/remove his own debt, or the address of any other
   * other borrower whose debt should be removed
   * @return The final amount repaid
   **/
  function repay(
    address asset,
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external returns (uint256);
}

interface CErc20 is CTokenLike {
  function underlying() external returns (address);
  function mint(uint mintAmount) external returns (uint);
  function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);
}

interface CEther is CTokenLike {
  function repayBorrowBehalf(address borrower) external payable;
}

// 
pragma solidity 0.8.16;

interface Comet {
    error Absurd();
    error AlreadyInitialized();
    error BadAsset();
    error BadDecimals();
    error BadDiscount();
    error BadMinimum();
    error BadPrice();
    error BorrowTooSmall();
    error BorrowCFTooLarge();
    error InsufficientReserves();
    error LiquidateCFTooLarge();
    error NoSelfTransfer();
    error NotCollateralized();
    error NotForSale();
    error NotLiquidatable();
    error Paused();
    error SupplyCapExceeded();
    error TimestampTooLarge();
    error TooManyAssets();
    error TooMuchSlippage();
    error TransferInFailed();
    error TransferOutFailed();
    error Unauthorized();
    error BadAmount();
    error BadNonce();
    error BadSignatory();
    error InvalidValueS();
    error InvalidValueV();
    error SignatureExpired();

    struct AssetInfo {
        uint8 offset;
        address asset;
        address priceFeed;
        uint64 scale;
        uint64 borrowCollateralFactor;
        uint64 liquidateCollateralFactor;
        uint64 liquidationFactor;
        uint128 supplyCap;
    }

    event Supply(address indexed from, address indexed dst, uint amount);
    event Transfer(address indexed from, address indexed to, uint amount);
    event Withdraw(address indexed src, address indexed to, uint amount);

    event SupplyCollateral(address indexed from, address indexed dst, address indexed asset, uint amount);
    event TransferCollateral(address indexed from, address indexed to, address indexed asset, uint amount);
    event WithdrawCollateral(address indexed src, address indexed to, address indexed asset, uint amount);

    
    event AbsorbDebt(address indexed absorber, address indexed borrower, uint basePaidOut, uint usdValue);

    
    event AbsorbCollateral(address indexed absorber, address indexed borrower, address indexed asset, uint collateralAbsorbed, uint usdValue);

    
    event BuyCollateral(address indexed buyer, address indexed asset, uint baseAmount, uint collateralAmount);

    
    event PauseAction(bool supplyPaused, bool transferPaused, bool withdrawPaused, bool absorbPaused, bool buyPaused);

    
    event WithdrawReserves(address indexed to, uint amount);

    function supply(address asset, uint amount) external;
    function supplyTo(address dst, address asset, uint amount) external;
    function supplyFrom(address from, address dst, address asset, uint amount) external;

    function transfer(address dst, uint amount) external returns (bool);
    function transferFrom(address src, address dst, uint amount) external returns (bool);

    function transferAsset(address dst, address asset, uint amount) external;
    function transferAssetFrom(address src, address dst, address asset, uint amount) external;

    function withdraw(address asset, uint amount) external;
    function withdrawTo(address to, address asset, uint amount) external;
    function withdrawFrom(address src, address to, address asset, uint amount) external;

    function approveThis(address manager, address asset, uint amount) external;
    function withdrawReserves(address to, uint amount) external;

    function absorb(address absorber, address[] calldata accounts) external;
    function buyCollateral(address asset, uint minAmount, uint baseAmount, address recipient) external;
    function quoteCollateral(address asset, uint baseAmount) external view returns (uint);

    function getAssetInfo(uint8 i) external view returns (AssetInfo memory);
    function getAssetInfoByAddress(address asset) external view returns (AssetInfo memory);
    function getReserves() external view returns (int);
    function getPrice(address priceFeed) external view returns (uint);

    function isBorrowCollateralized(address account) external view returns (bool);
    function isLiquidatable(address account) external view returns (bool);

    function totalSupply() external view returns (uint256);
    function totalBorrow() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function borrowBalanceOf(address account) external view returns (uint256);

    function pause(bool supplyPaused, bool transferPaused, bool withdrawPaused, bool absorbPaused, bool buyPaused) external;
    function isSupplyPaused() external view returns (bool);
    function isTransferPaused() external view returns (bool);
    function isWithdrawPaused() external view returns (bool);
    function isAbsorbPaused() external view returns (bool);
    function isBuyPaused() external view returns (bool);

    function accrueAccount(address account) external;
    function getSupplyRate(uint utilization) external view returns (uint64);
    function getBorrowRate(uint utilization) external view returns (uint64);
    function getUtilization() external view returns (uint);

    function governor() external view returns (address);
    function pauseGuardian() external view returns (address);
    function baseToken() external view returns (address);
    function baseTokenPriceFeed() external view returns (address);
    function extensionDelegate() external view returns (address);

    
    function supplyKink() external view returns (uint);
    
    function supplyPerSecondInterestRateSlopeLow() external view returns (uint);
    
    function supplyPerSecondInterestRateSlopeHigh() external view returns (uint);
    
    function supplyPerSecondInterestRateBase() external view returns (uint);
    
    function borrowKink() external view returns (uint);
    
    function borrowPerSecondInterestRateSlopeLow() external view returns (uint);
    
    function borrowPerSecondInterestRateSlopeHigh() external view returns (uint);
    
    function borrowPerSecondInterestRateBase() external view returns (uint);
    
    function storeFrontPriceFactor() external view returns (uint);

    
    function baseScale() external view returns (uint);
    
    function trackingIndexScale() external view returns (uint);

    
    function baseTrackingSupplySpeed() external view returns (uint);
    
    function baseTrackingBorrowSpeed() external view returns (uint);
    
    function baseMinForRewards() external view returns (uint);
    
    function baseBorrowMin() external view returns (uint);
    
    function targetReserves() external view returns (uint);

    function numAssets() external view returns (uint8);
    function decimals() external view returns (uint8);

    function initializeStorage() external;

    function collateralBalanceOf(address account, address asset) external view returns (uint128);
    function allow(address manager, bool isAllowed_) external;
}

// 
pragma solidity 0.8.16;




interface IWETH9 is IERC20NonStandard {
    
    function deposit() external payable;

    
    function withdraw(uint256) external;
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
pragma solidity >=0.7.5;






interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    
    
    
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    
    
    
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    
    
    
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    
    
    
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}