// SPDX-License-Identifier: UNLICENSED

/**
 *Submitted for verification at Etherscan.io on 2021-05-18
*/

// File: @openzeppelin/contracts/GSN/Context.sol
// 

pragma solidity ^0.7.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity ^0.7.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File: @uniswap/v3-core/contracts/libraries/FullMath.sol

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

// File: @uniswap/v3-core/contracts/libraries/FixedPoint96.sol

pragma solidity >=0.4.0;




library FixedPoint96 {
  uint8 internal constant RESOLUTION = 96;
  uint256 internal constant Q96 = 0x1000000000000000000000000;
}

// File: @uniswap/v3-core/contracts/libraries/TickMath.sol

pragma solidity >=0.5.0;



/// prices between 2**-128 and 2**128
library TickMath {
  
  int24 internal constant MIN_TICK = -887272;
  
  int24 internal constant MAX_TICK = -MIN_TICK;

  
  uint160 internal constant MIN_SQRT_RATIO = 4295128739;
  
  uint160 internal constant MAX_SQRT_RATIO =
    1461446703485210103287273052203988822378723970342;

  
  
  
  
  /// at the given tick
  function getSqrtRatioAtTick(int24 tick)
    internal
    pure
    returns (uint160 sqrtPriceX96)
  {
    uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
    require(absTick <= uint256(MAX_TICK), "T");

    uint256 ratio =
      absTick & 0x1 != 0
        ? 0xfffcb933bd6fad37aa2d162d1a594001
        : 0x100000000000000000000000000000000;
    if (absTick & 0x2 != 0)
      ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
    if (absTick & 0x4 != 0)
      ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
    if (absTick & 0x8 != 0)
      ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
    if (absTick & 0x10 != 0)
      ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
    if (absTick & 0x20 != 0)
      ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
    if (absTick & 0x40 != 0)
      ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
    if (absTick & 0x80 != 0)
      ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
    if (absTick & 0x100 != 0)
      ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
    if (absTick & 0x200 != 0)
      ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
    if (absTick & 0x400 != 0)
      ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
    if (absTick & 0x800 != 0)
      ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
    if (absTick & 0x1000 != 0)
      ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
    if (absTick & 0x2000 != 0)
      ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
    if (absTick & 0x4000 != 0)
      ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
    if (absTick & 0x8000 != 0)
      ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
    if (absTick & 0x10000 != 0)
      ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
    if (absTick & 0x20000 != 0)
      ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
    if (absTick & 0x40000 != 0)
      ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
    if (absTick & 0x80000 != 0)
      ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

    if (tick > 0) ratio = type(uint256).max / ratio;

    // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
    // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
    // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
    sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
  }

  
  
  /// ever return.
  
  
  function getTickAtSqrtRatio(uint160 sqrtPriceX96)
    internal
    pure
    returns (int24 tick)
  {
    // second inequality must be < because the price can never reach the price at the max tick
    require(
      sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO,
      "R"
    );
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

    int24 tickLow =
      int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
    int24 tickHi =
      int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

    tick = tickLow == tickHi
      ? tickLow
      : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96
      ? tickHi
      : tickLow;
  }
}

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   *
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   *
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   *
   * - Subtraction cannot overflow.
   */
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   *
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   *
   * - The divisor cannot be zero.
   */
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

// File: contracts/Interfaces/CalculatorInterface.sol

pragma solidity ^0.7.1;

interface DogeV3CalculatorInterface {
  function newTicks(
    int24 currentTick,
    int24 startTick,
    int24 endTick,
    int24 denominator,
    uint32 startTimestamp
  )
    external
    view
    returns (
      int24 upperTick,
      int24 lowerTick,
      bool isSafeIncrement
    );

  function setInitialTicks(int24 currentTick, int24 denominator)
    external
    view
    returns (int24 upperTick, int24 lowerTick);

  function getCurrentLiquidity(
    uint160 sqrtRatioX96,
    int24 upperTick,
    int24 lowerTick,
    uint256 amount0,
    uint256 amount1
  ) external pure returns (uint128 fullLiquidity, uint128 limitedLiquidity);

  function ratioE8() external view returns (uint64);

  function getPriceE8FromSQRTPrice(uint160 sqrtPriceX96)
    external
    pure
    returns (uint256 priceE8);

  function getPriceE8FromTick(int24 tick)
    external
    pure
    returns (uint256 priceE8);

  function roundDown(int24 tick, int24 denominator)
    external
    pure
    returns (int24 ans);

  function getTickFromSQRTPrice(uint160 sqrtPriceX96)
    external
    pure
    returns (int24);

  function getDifference() external view returns (int24 tickDifference);
}

// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolImmutables.sol

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

// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolState.sol

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

  
  
  function protocolFees()
    external
    view
    returns (uint128 token0, uint128 token1);

  
  
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

// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolDerivedState.sol

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
    returns (
      int56[] memory tickCumulatives,
      uint160[] memory secondsPerLiquidityCumulativeX128s
    );

  
  
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

// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolActions.sol

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
  
  function increaseObservationCardinalityNext(uint16 observationCardinalityNext)
    external;
}

// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolOwnerActions.sol

pragma solidity >=0.5.0;



interface IUniswapV3PoolOwnerActions {
  
  
  
  function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

  
  
  
  
  
  
  function collectProtocol(
    address recipient,
    uint128 amount0Requested,
    uint128 amount1Requested
  ) external returns (uint128 amount0, uint128 amount1);
}

// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolEvents.sol

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

  
  
  
  
  
  event SetFeeProtocol(
    uint8 feeProtocol0Old,
    uint8 feeProtocol1Old,
    uint8 feeProtocol0New,
    uint8 feeProtocol1New
  );

  
  
  
  
  
  event CollectProtocol(
    address indexed sender,
    address indexed recipient,
    uint128 amount0,
    uint128 amount1
  );
}

// File: @uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol

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

// File: contracts/Interfaces/DogeV3Interface.sol

pragma solidity 0.7.1;

interface DogeV3Interface {
  /*
  function getNFTInfo(uint16 stageID)
    external
    view
    returns (
      uint96 nonce,
      address operator,
      address token0,
      address token1,
      uint24 fee,
      int24 tickLower,
      int24 tickUpper,
      uint128 liquidity,
      uint256 feeGrowthInside0LastX128,
      uint256 feeGrowthInside1LastX128,
      uint128 tokensOwed0,
      uint128 tokensOwed1
    );
*/

  function currentStage() external view returns (uint16);

  function incrementStage() external;

  function changeCalculator(DogeV3CalculatorInterface newCalc) external;

  function depositFirstStage(uint256 amount, IUniswapV3Pool _swap) external;

  function getSwapInfo()
    external
    view
    returns (int24 tick, address swapAddress);

  function isReversedSwap() external view returns (bool);

  function getStageInfo(uint16 stageID)
    external
    view
    returns (
      bool isReversedSwap,
      int24 upterTick,
      int24 lowerTick,
      uint32 startTimestamp,
      uint128 tokenId,
      uint128 tokenId2
    );

  function isUpgradable() external view returns (bool upgradable);

  function currentStatus()
    external
    view
    returns (
      uint16 currentStageId,
      uint32 startTimestamp,
      uint128 tokenId,
      uint128 tokenId2,
      uint256 upperPrice,
      uint256 lowerPrice,
      uint256 currentPrice
    );
}

// File: contracts/DogeCalculator.sol

pragma solidity 0.7.1;

contract DogeCalculator is Ownable, DogeV3CalculatorInterface {
  using TickMath for int24;
  using TickMath for uint160;
  using SafeMath for uint256;
  uint160 internal constant MIN_SQRT_RATIO = 4295128739;
  uint160 internal constant MAX_SQRT_RATIO =
    1461446703485210103287273052203988822378723970342;
  uint160 internal constant MID_SQRT_RATIO = 79228162514264337593543950336;
  uint256 ONE_ETH = 10**18;

  
  
  
  function toUint128(uint256 x) private pure returns (uint128 y) {
    require((y = uint128(x)) == x);
  }

  uint32 interval;
  uint16 threshholdTick;
  uint16 limitTick;
  uint64 public override ratioE8;

  constructor(
    uint32 _interval,
    uint16 _threshholdTick,
    uint16 _limitTick
  ) {
    interval = _interval;
    threshholdTick = _threshholdTick;
    limitTick = _limitTick;
    uint128 fullLiquidity =
      getLiquidityForAmounts(
        MID_SQRT_RATIO,
        MIN_SQRT_RATIO,
        MAX_SQRT_RATIO,
        ONE_ETH,
        ONE_ETH
      );
    uint128 limitedLiquidity =
      getLiquidityForAmounts(
        MID_SQRT_RATIO,
        (int24(_limitTick) * -1).getSqrtRatioAtTick(),
        (int24(_limitTick)).getSqrtRatioAtTick(),
        ONE_ETH,
        ONE_ETH
      );
    ratioE8 = uint64(
      uint256(fullLiquidity).mul(10**8).div(limitedLiquidity).mul(8).div(10)
    );
  }

  function newTicks(
    int24 currentTick,
    int24 startTick,
    int24 endTick,
    int24 denominator,
    uint32 startTimestamp
  )
    external
    view
    override
    returns (
      int24 upperTick,
      int24 lowerTick,
      bool isSafeIncrement
    )
  {
    int24 midTick = (startTick + endTick) / 2;
    if (
      midTick + threshholdTick <= currentTick ||
      midTick - threshholdTick >= currentTick
    ) {
      return (
        roundDown(currentTick + limitTick, denominator),
        roundDown(currentTick - limitTick, denominator),
        true
      );
    }
    if (block.timestamp > startTimestamp + interval) {
      return (
        roundDown(currentTick + limitTick, denominator),
        roundDown(currentTick - limitTick, denominator),
        true
      );
    }
    return (0, 0, false);
  }

  function setInitialTicks(int24 currentTick, int24 denominator)
    external
    view
    override
    returns (int24 upperTick, int24 lowerTick)
  {
    return (
      roundDown(currentTick + limitTick, denominator),
      roundDown(currentTick - limitTick, denominator)
    );
  }

  function getCurrentLiquidity(
    uint160 sqrtRatioX96,
    int24 upperTick,
    int24 lowerTick,
    uint256 amount0,
    uint256 amount1
  )
    public
    pure
    override
    returns (uint128 fullLiquidity, uint128 limitedLiquidity)
  {
    fullLiquidity = getLiquidityForAmounts(
      sqrtRatioX96,
      MIN_SQRT_RATIO,
      MAX_SQRT_RATIO,
      amount0,
      amount1
    );
    limitedLiquidity = getLiquidityForAmounts(
      sqrtRatioX96,
      lowerTick.getSqrtRatioAtTick(),
      upperTick.getSqrtRatioAtTick(),
      amount0,
      amount1
    );
  }

  function getLiquidityForAmount0(
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint256 amount0
  ) internal pure returns (uint128 liquidity) {
    if (sqrtRatioAX96 > sqrtRatioBX96)
      (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
    uint256 intermediate =
      FullMath.mulDiv(sqrtRatioAX96, sqrtRatioBX96, FixedPoint96.Q96);
    return
      toUint128(
        FullMath.mulDiv(amount0, intermediate, sqrtRatioBX96 - sqrtRatioAX96)
      );
  }

  function getLiquidityForAmount1(
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint256 amount1
  ) internal pure returns (uint128 liquidity) {
    if (sqrtRatioAX96 > sqrtRatioBX96)
      (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
    return
      toUint128(
        FullMath.mulDiv(
          amount1,
          FixedPoint96.Q96,
          sqrtRatioBX96 - sqrtRatioAX96
        )
      );
  }

  function getLiquidityForAmounts(
    uint160 sqrtRatioX96,
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint256 amount0,
    uint256 amount1
  ) internal pure returns (uint128 liquidity) {
    if (sqrtRatioAX96 > sqrtRatioBX96)
      (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

    if (sqrtRatioX96 <= sqrtRatioAX96) {
      liquidity = getLiquidityForAmount0(sqrtRatioAX96, sqrtRatioBX96, amount0);
    } else if (sqrtRatioX96 < sqrtRatioBX96) {
      uint128 liquidity0 =
        getLiquidityForAmount0(sqrtRatioX96, sqrtRatioBX96, amount0);
      uint128 liquidity1 =
        getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioX96, amount1);

      liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
    } else {
      liquidity = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioBX96, amount1);
    }
  }

  function roundDown(int24 tick, int24 denominator)
    public
    pure
    override
    returns (int24 ans)
  {
    ans = (tick / denominator) * denominator;
  }

  function getPriceE8FromTick(int24 tick)
    external
    pure
    override
    returns (uint256 priceE15)
  {
    return getPriceE8FromSQRTPrice(tick.getSqrtRatioAtTick());
  }

  function getPriceE8FromSQRTPrice(uint160 sqrtPriceX96)
    public
    pure
    override
    returns (uint256 priceE18)
  {
    priceE18 = (((uint256(sqrtPriceX96)**2) >> 64) * 10**18) >> 128;
  }

  function getTickFromSQRTPrice(uint160 sqrtPriceX96)
    external
    pure
    override
    returns (int24)
  {
    return sqrtPriceX96.getTickAtSqrtRatio();
  }

  function getDifference()
    external
    view
    override
    returns (int24 tickDifference)
  {
    return limitTick - threshholdTick;
  }
}