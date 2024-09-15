// SPDX-License-Identifier: GPL-3.0-or-later

// 
// Deployed with donations via Gitcoin GR9

pragma solidity 0.7.5;

// a library for performing various math operations

library Math {
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x > y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// 
// Deployed with donations via Gitcoin GR9

pragma solidity 0.7.5;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, 'SM_ADD_OVERFLOW');
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = sub(x, y, 'SM_SUB_UNDERFLOW');
    }

    function sub(
        uint256 x,
        uint256 y,
        string memory message
    ) internal pure returns (uint256 z) {
        require((z = x - y) <= x, message);
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, 'SM_MUL_OVERFLOW');
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, 'SM_DIV_BY_ZERO');
        uint256 c = a / b;
        return c;
    }

    function ceil_div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = div(a, b);
        if (c == mul(a, b)) {
            return c;
        } else {
            return add(c, 1);
        }
    }

    function add96(uint96 a, uint96 b) internal pure returns (uint96 c) {
        c = a + b;
        require(c >= a, 'SM_ADD_OVERFLOW');
    }

    function sub96(uint96 a, uint96 b) internal pure returns (uint96) {
        require(b <= a, 'SM_SUB_UNDERFLOW');
        return a - b;
    }

    function mul96(uint96 x, uint96 y) internal pure returns (uint96 z) {
        require(y == 0 || (z = x * y) / y == x, 'SM_MUL_OVERFLOW');
    }

    function div96(uint96 a, uint96 b) internal pure returns (uint96) {
        require(b > 0, 'SM_DIV_BY_ZERO');
        uint96 c = a / b;
        return c;
    }
}

// 
// Deployed with donations via Gitcoin GR9

pragma solidity 0.7.5;




library FixedSafeMath {
    int256 private constant _INT256_MIN = -2**255;
    int256 internal constant ONE = 10**18;

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), 'FM_ADDITION_OVERFLOW');

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), 'FM_SUBTRACTION_OVERFLOW');

        return c;
    }

    function f18Mul(int256 a, int256 b) internal pure returns (int256) {
        return div(mul(a, b), ONE);
    }

    function f18Div(int256 a, int256 b) internal pure returns (int256) {
        return div(mul(a, ONE), b);
    }

    function f18Sqrt(int256 value) internal pure returns (int256) {
        require(value >= 0, 'FM_SQUARE_ROOT_OF_NEGATIVE');
        return int256(Math.sqrt(SafeMath.mul(uint256(value), uint256(ONE))));
    }

    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), 'FM_MULTIPLICATION_OVERFLOW');

        int256 c = a * b;
        require(c / a == b, 'FM_MULTIPLICATION_OVERFLOW');

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, 'FM_DIVISION_BY_ZERO');
        require(!(b == -1 && a == _INT256_MIN), 'FM_DIVISION_OVERFLOW');

        int256 c = a / b;

        return c;
    }
}

// 
// Deployed with donations via Gitcoin GR9

pragma solidity 0.7.5;



library Normalizer {
    using SafeMath for uint256;

    function normalize(uint256 amount, uint8 decimals) internal pure returns (uint256) {
        if (decimals == 18) {
            return amount;
        } else if (decimals > 18) {
            return amount.div(10**(decimals - 18));
        } else {
            return amount.mul(10**(18 - decimals));
        }
    }

    function denormalize(uint256 amount, uint8 decimals) internal pure returns (uint256) {
        if (decimals == 18) {
            return amount;
        } else if (decimals > 18) {
            return amount.mul(10**(decimals - 18));
        } else {
            return amount.div(10**(18 - decimals));
        }
    }
}

// 
// Deployed with donations via Gitcoin GR9

pragma solidity 0.7.5;

interface IIntegralOracleV3 {
    event OwnerSet(address owner);
    event UniswapPairSet(address uniswapPair);
    event PriceUpdateIntervalSet(uint32 interval);
    event PriceBoundsSet(int256 minPrice, int256 maxPrice);
    event ParametersSet(uint32 epoch, int256[] bidExponents, int256[] bidQs, int256[] askExponents, int256[] askQs);

    function owner() external view returns (address);

    function setOwner(address) external;

    function epoch() external view returns (uint32);

    function xDecimals() external view returns (uint8);

    function yDecimals() external view returns (uint8);

    function getParameters()
        external
        view
        returns (
            int256[] memory bidExponents,
            int256[] memory bidQs,
            int256[] memory askExponents,
            int256[] memory askQs
        );

    function setParameters(
        int256[] calldata bidExponents,
        int256[] calldata bidQs,
        int256[] calldata askExponents,
        int256[] calldata askQs
    ) external;

    function price() external view returns (int256);

    function minPrice() external view returns (int256);

    function maxPrice() external view returns (int256);

    function priceUpdateInterval() external view returns (uint32);

    function updatePrice() external returns (uint32 _epoch);

    function setPriceUpdateInterval(uint32 interval) external;

    function setPriceBounds(int256 _minPrice, int256 _maxPrice) external;

    function blockTimestampLast() external view returns (uint32);

    function tradeX(
        uint256 xAfter,
        uint256 xBefore,
        uint256 yBefore
    ) external view returns (uint256 yAfter);

    function tradeY(
        uint256 yAfter,
        uint256 xBefore,
        uint256 yBefore
    ) external view returns (uint256 xAfter);

    function getSpotPrice(uint256 xCurrent, uint256 xBefore) external view returns (uint256 spotPrice);
}

// 
// Deployed with donations via Gitcoin GR9

pragma solidity 0.7.5;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
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
// Deployed with donations via Gitcoin GR9

pragma solidity 0.7.5;








contract IntegralOracleV3 is IIntegralOracleV3 {
    using FixedSafeMath for int256;
    using SafeMath for int256;
    using SafeMath for uint256;
    using Normalizer for uint256;

    address public override owner;
    address public uniswapPair;
    address public token0;
    address public token1;

    int256 public override price;
    int256 public override minPrice = 0;
    int256 public override maxPrice = type(int256).max;
    uint32 public override epoch;

    int256 private constant _ONE = 10**18;
    int256 private constant _TWO = 2 * 10**18;
    uint128 private _ONE_IN_X;

    uint8 public override xDecimals;
    uint8 public override yDecimals;

    int256[] private bidExponents;
    int256[] private bidQs;
    int256[] private askExponents;
    int256[] private askQs;

    uint32 public override priceUpdateInterval = 2 minutes;
    uint32 public override blockTimestampLast;

    constructor(uint8 _xDecimals, uint8 _yDecimals) {
        require(_xDecimals <= 100 && _yDecimals <= 100, 'IO_DECIMALS_HIGHER_THAN_100');
        owner = msg.sender;
        xDecimals = _xDecimals;
        yDecimals = _yDecimals;
        _ONE_IN_X = uint128(10**xDecimals);
    }

    function isContract(address addr) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function _blockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2**32);
    }

    function setOwner(address _owner) external override {
        require(msg.sender == owner, 'IO_FORBIDDEN');
        owner = _owner;
        emit OwnerSet(owner);
    }

    function setUniswapPair(address _uniswapPair) external {
        require(msg.sender == owner, 'IO_FORBIDDEN');
        require(_uniswapPair != address(0), 'IO_ADDRESS_ZERO');
        require(isContract(_uniswapPair), 'IO_UNISWAP_PAIR_MUST_BE_CONTRACT');
        IUniswapV3Pool uniswapV3Pool = IUniswapV3Pool(_uniswapPair);
        require(uniswapV3Pool.liquidity() != 0, 'IO_NO_UNISWAP_LIQUIDITY');

        uniswapPair = _uniswapPair;
        token0 = uniswapV3Pool.token0();
        token1 = uniswapV3Pool.token1();
        require(
            IERC20(token0).decimals() == xDecimals && IERC20(token1).decimals() == yDecimals,
            'IO_INVALID_DECIMALS'
        );
        _updatePrice();
        blockTimestampLast = _blockTimestamp();

        emit UniswapPairSet(uniswapPair);
    }

    function setPriceUpdateInterval(uint32 interval) external override {
        require(msg.sender == owner, 'IO_FORBIDDEN');
        require(interval > 0, 'IO_INTERVAL_CANNOT_BE_ZERO');
        priceUpdateInterval = interval;
        emit PriceUpdateIntervalSet(interval);
    }

    function setPriceBounds(int256 _minPrice, int256 _maxPrice) external override {
        require(msg.sender == owner, 'IO_FORBIDDEN');
        require(_minPrice <= _maxPrice, 'IO_INVALID_BOUNDS');
        minPrice = _minPrice;
        maxPrice = _maxPrice;
        emit PriceBoundsSet(minPrice, maxPrice);
    }

    function updatePrice() external override returns (uint32 _epoch) {
        if (uniswapPair == address(0)) {
            return epoch;
        }

        uint32 blockTimestamp = _blockTimestamp();
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed >= priceUpdateInterval) {
            _updatePrice();
            blockTimestampLast = blockTimestamp;

            epoch += 1; // overflow is desired
        }

        return epoch;
    }

    function _updatePrice() internal {
        int24 tick = OracleLibrary.consult(uniswapPair, priceUpdateInterval);
        uint256 uniswapPrice = OracleLibrary.getQuoteAtTick(tick, _ONE_IN_X, token0, token1);
        price = normalizeAmount(yDecimals, uniswapPrice);
        require(price >= minPrice && price <= maxPrice, 'IO_PRICE_OUT_OF_BOUNDS');
    }

    function normalizeAmount(uint8 decimals, uint256 amount) internal pure returns (int256 result) {
        result = int256(amount.normalize(decimals));
        require(result >= 0, 'IO_INPUT_OVERFLOW');
    }

    function getParameters()
        external
        view
        override
        returns (
            int256[] memory _bidExponents,
            int256[] memory _bidQs,
            int256[] memory _askExponents,
            int256[] memory _askQs
        )
    {
        _bidExponents = bidExponents;
        _bidQs = bidQs;
        _askExponents = askExponents;
        _askQs = askQs;
    }

    function setParameters(
        int256[] calldata _bidExponents,
        int256[] calldata _bidQs,
        int256[] calldata _askExponents,
        int256[] calldata _askQs
    ) public override {
        require(msg.sender == owner, 'IO_FORBIDDEN');
        require(_bidExponents.length == _bidQs.length, 'IO_LENGTH_MISMATCH');
        require(_askExponents.length == _askQs.length, 'IO_LENGTH_MISMATCH');

        bidExponents = _bidExponents;
        bidQs = _bidQs;
        askExponents = _askExponents;
        askQs = _askQs;

        epoch += 1; // overflow is desired
        emit ParametersSet(epoch, bidExponents, bidQs, askExponents, askQs);
    }

    // TRADE

    function tradeX(
        uint256 xAfter,
        uint256 xBefore,
        uint256 yBefore
    ) public view override returns (uint256 yAfter) {
        int256 xAfterInt = normalizeAmount(xDecimals, xAfter);
        int256 xBeforeInt = normalizeAmount(xDecimals, xBefore);
        int256 yBeforeInt = normalizeAmount(yDecimals, yBefore);
        // We define the balances in terms of change from the the beginning of the epoch
        int256 yAfterInt = yBeforeInt.sub(integral(xAfterInt.sub(xBeforeInt)));
        require(yAfterInt >= 0, 'IO_NEGATIVE_Y_BALANCE');
        return uint256(yAfterInt).denormalize(yDecimals);
    }

    function tradeY(
        uint256 yAfter,
        uint256 xBefore,
        uint256 yBefore
    ) public view override returns (uint256 xAfter) {
        int256 yAfterInt = normalizeAmount(yDecimals, yAfter);
        int256 xBeforeInt = normalizeAmount(xDecimals, xBefore);
        int256 yBeforeInt = normalizeAmount(yDecimals, yBefore);
        // We define the balances in terms of change from the the beginning of the epoch
        int256 xAfterInt = xBeforeInt.add(integralInverted(yBeforeInt.sub(yAfterInt)));
        require(xAfterInt >= 0, 'IO_NEGATIVE_X_BALANCE');
        return uint256(xAfterInt).denormalize(xDecimals);
    }

    // INTEGRALS

    function integral(int256 q) private view returns (int256) {
        // we are integrating over a curve that represents the order book
        if (q > 0) {
            // integrate over bid orders, our trade can be a bid or an ask
            return integralBid(q);
        } else if (q < 0) {
            // integrate over ask orders, our trade can be a bid or an ask
            return integralAsk(q);
        } else {
            return 0;
        }
    }

    function integralBid(int256 q) private view returns (int256) {
        int256 C = 0;
        for (uint256 i = 1; i < bidExponents.length; i++) {
            // find the corresponding range of prices for the piecewise function  (pPrevious, pCurrent)
            // price * e^(i-1) = price * constant, so we can create a lookup table
            int256 pPrevious = price.f18Mul(bidExponents[i - 1]);
            int256 pCurrent = price.f18Mul(bidExponents[i]);

            // pull the corresponding accumulated quantity up to pPrevious and pCurrent
            int256 qPrevious = bidQs[i - 1];
            int256 qCurrent = bidQs[i];

            // the quantity q falls between the range (pPrevious, pCurrent)
            if (q <= qCurrent) {
                int256 X = pPrevious.add(pCurrent).mul(qCurrent.sub(qPrevious)).add(
                    pCurrent.sub(pPrevious).mul(q.sub(qCurrent))
                );
                int256 Y = q.sub(qPrevious);
                int256 Z = qCurrent.sub(qPrevious);
                int256 A = X.mul(Y).div(Z).div(_TWO);
                return C.add(A);
            } else {
                // the quantity q exceeds the current range (pPrevious, pCurrent)
                // evaluate integral of entire segment
                int256 A = pPrevious.add(pCurrent).f18Mul(qCurrent.sub(qPrevious)).div(2);
                C = C.add(A);
            }
        }
        // this means we've run out of quantity in our curve's orderbook to satisfy the order quantity
        // this is highly unlikely, but it is possible if the user specifies an extremely large order or
        // the orderbook has gone too far in a single direction
        // but if things are operating correctly, this should almost never happen
        revert('IO_OVERFLOW');
    }

    function integralAsk(int256 q) private view returns (int256) {
        int256 C = 0;
        for (uint256 i = 1; i < askExponents.length; i++) {
            int256 pPrevious = price.f18Mul(askExponents[i - 1]);
            int256 pCurrent = price.f18Mul(askExponents[i]);

            int256 qPrevious = askQs[i - 1];
            int256 qCurrent = askQs[i];

            if (q >= qCurrent) {
                int256 X = pPrevious.add(pCurrent).mul(qCurrent.sub(qPrevious)).add(
                    pCurrent.sub(pPrevious).mul(q.sub(qCurrent))
                );
                int256 Y = q.sub(qPrevious);
                int256 Z = qCurrent.sub(qPrevious);
                int256 A = X.mul(Y).div(Z).div(_TWO);
                return C.add(A);
            } else {
                int256 A = pPrevious.add(pCurrent).f18Mul(qCurrent.sub(qPrevious)).div(2);
                C = C.add(A);
            }
        }
        revert('IO_OVERFLOW');
    }

    function integralInverted(int256 s) private view returns (int256) {
        if (s > 0) {
            return integralBidInverted(s);
        } else if (s < 0) {
            return integralAskInverted(s);
        } else {
            return 0;
        }
    }

    function integralBidInverted(int256 s) private view returns (int256) {
        int256 _s = s.add(1);
        int256 C = 0;
        for (uint256 i = 1; i < bidExponents.length; i++) {
            int256 pPrevious = price.f18Mul(bidExponents[i - 1]);
            int256 pCurrent = price.f18Mul(bidExponents[i]);
            int256 qPrevious = bidQs[i - 1];
            int256 qCurrent = bidQs[i];
            int256 A = pPrevious.add(pCurrent).f18Mul(qCurrent.sub(qPrevious)).div(2);
            if (_s <= C.add(A)) {
                int256 c = C.sub(_s);
                int256 b = pPrevious;
                int256 a = pCurrent.sub(b);
                int256 d = qCurrent.sub(qPrevious);
                int256 h = f18SolveQuadratic(a, b, c, d);
                return qPrevious.add(h);
            } else {
                C = C.add(A);
            }
        }
        revert('IO_OVERFLOW');
    }

    function integralAskInverted(int256 s) private view returns (int256) {
        int256 C = 0;
        for (uint256 i = 1; i < askExponents.length; i++) {
            int256 pPrevious = price.f18Mul(askExponents[i - 1]);
            int256 pCurrent = price.f18Mul(askExponents[i]);
            int256 qPrevious = askQs[i - 1];
            int256 qCurrent = askQs[i];
            int256 A = pPrevious.add(pCurrent).f18Mul(qCurrent.sub(qPrevious)).div(2);
            if (s >= C.add(A)) {
                int256 a = pCurrent.sub(pPrevious);
                int256 d = qCurrent.sub(qPrevious);
                int256 b = pPrevious;
                int256 c = C.sub(s);
                int256 h = f18SolveQuadratic(a, b, c, d);
                return qPrevious.add(h).sub(1);
            } else {
                C = C.add(A);
            }
        }
        revert('IO_OVERFLOW');
    }

    function f18SolveQuadratic(
        int256 A,
        int256 B,
        int256 C,
        int256 D
    ) private pure returns (int256) {
        int256 inside = B.mul(B).sub(_TWO.mul(A).mul(C).div(D));
        int256 sqroot = int256(Math.sqrt(uint256(inside)));
        int256 x = sqroot.sub(B).mul(D).div(A);
        for (uint256 i = 0; i < 16; i++) {
            int256 xPrev = x;
            int256 z = A.mul(x);
            x = z.mul(x).div(2).sub(C.mul(D).mul(_ONE)).div(z.add(B.mul(D)));
            if (x > xPrev) {
                if (x.sub(xPrev) <= int256(1)) {
                    return x;
                }
            } else {
                if (xPrev.sub(x) <= int256(1)) {
                    return x;
                }
            }
        }
        revert('IO_OVERFLOW');
    }

    // SPOT PRICE

    function getSpotPrice(uint256 xCurrent, uint256 xBefore) public view override returns (uint256 spotPrice) {
        int256 xCurrentInt = normalizeAmount(xDecimals, xCurrent);
        int256 xBeforeInt = normalizeAmount(xDecimals, xBefore);
        int256 spotPriceInt = derivative(xCurrentInt.sub(xBeforeInt));
        require(spotPriceInt >= 0, 'IO_NEGATIVE_SPOT_PRICE');
        return uint256(spotPriceInt);
    }

    // DERIVATIVES

    function derivative(int256 t) public view returns (int256) {
        if (t > 0) {
            return derivativeBid(t);
        } else if (t < 0) {
            return derivativeAsk(t);
        } else {
            return price;
        }
    }

    function derivativeBid(int256 t) public view returns (int256) {
        for (uint256 i = 1; i < bidExponents.length; i++) {
            int256 pPrevious = price.f18Mul(bidExponents[i - 1]);
            int256 pCurrent = price.f18Mul(bidExponents[i]);
            int256 qPrevious = bidQs[i - 1];
            int256 qCurrent = bidQs[i];
            if (t <= qCurrent) {
                return (pCurrent.sub(pPrevious)).f18Mul(t.sub(qCurrent)).f18Div(qCurrent.sub(qPrevious)).add(pCurrent);
            }
        }
        revert('IO_OVERFLOW');
    }

    function derivativeAsk(int256 t) public view returns (int256) {
        for (uint256 i = 1; i < askExponents.length; i++) {
            int256 pPrevious = price.f18Mul(askExponents[i - 1]);
            int256 pCurrent = price.f18Mul(askExponents[i]);
            int256 qPrevious = askQs[i - 1];
            int256 qCurrent = askQs[i];
            if (t >= qCurrent) {
                return (pCurrent.sub(pPrevious)).f18Mul(t.sub(qCurrent)).f18Div(qCurrent.sub(qPrevious)).add(pCurrent);
            }
        }
        revert('IO_OVERFLOW');
    }
}

