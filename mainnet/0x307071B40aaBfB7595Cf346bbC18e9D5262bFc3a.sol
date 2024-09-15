// SPDX-License-Identifier: MIT
pragma abicoder v2;

// 

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute.
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// 
pragma solidity >=0.5.0;



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
pragma solidity >=0.7.5;





/// to compute the result. They are also not gas efficient and should not be called on-chain.
interface IQuoter {
    
    
    
    
    function quoteExactInput(bytes memory path, uint256 amountIn) external returns (uint256 amountOut);

    
    
    
    
    
    
    
    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountOut);

    
    
    
    
    function quoteExactOutput(bytes memory path, uint256 amountOut) external returns (uint256 amountIn);

    
    
    
    
    
    
    
    function quoteExactOutputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountOut,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountIn);
}

// 
pragma solidity 0.8.7;

address constant GELATO = 0x3CACa7b48D0573D793d3b0279b5F0029180E83b6;
string constant OK = "OK";

// 
pragma solidity 0.8.7;

address constant SWAP_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
address constant FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
address constant QUOTER = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;
uint24 constant LOW_FEES = 500;
uint24 constant MEDIUM_FEES = 3000;
uint24 constant HIGH_FEES = 10000;

// "
pragma solidity 0.8.7;

library GelatoString {
    function startsWithOK(string memory _str) internal pure returns (bool) {
        if (
            bytes(_str).length >= 2 &&
            bytes(_str)[0] == "O" &&
            bytes(_str)[1] == "K"
        ) return true;
        return false;
    }

    function revertWithInfo(string memory _error, string memory _tracingInfo)
        internal
        pure
    {
        revert(string(abi.encodePacked(_tracingInfo, _error)));
    }

    function prefix(string memory _second, string memory _first)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(_first, _second));
    }

    function suffix(string memory _first, string memory _second)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(_first, _second));
    }
}

// 
pragma solidity 0.8.7;










contract UniswapV3Resolver {
    using GelatoString for string;
    using Math for uint256;

    // should be called with callstatic of etherjs,
    // because quoteExactInputSingle is not a view function.
    function multicallGetAmountsOut(UniswapV3Data[] calldata datas_)
        public
        returns (UniswapV3Result[] memory results)
    {
        results = new UniswapV3Result[](datas_.length);

        for (uint256 i = 0; i < datas_.length; i++) {
            try this.getBestPool(datas_[i]) returns (
                UniswapV3Result memory result
            ) {
                results[i] = result;
            } catch Error(string memory error) {
                results[i] = UniswapV3Result({
                    id: datas_[i].id,
                    amountOut: 0,
                    fee: 0,
                    message: error.prefix(
                        "UniswapV3Resolver.getBestPool failed:"
                    )
                });
            } catch {
                results[i] = UniswapV3Result({
                    id: datas_[i].id,
                    amountOut: 0,
                    fee: 0,
                    message: "UniswapV3Resolver.getBestPool failed:undefined"
                });
            }
        }
    }

    function getBestPool(UniswapV3Data memory data_)
        public
        returns (UniswapV3Result memory)
    {
        uint256 amountOut = _quoteExactInputSingle(data_, LOW_FEES);
        uint24 fee = LOW_FEES;

        uint256 amountOutMediumFee;
        if (
            (amountOutMediumFee = _quoteExactInputSingle(data_, MEDIUM_FEES)) >
            amountOut
        ) {
            amountOut = amountOutMediumFee;
            fee = MEDIUM_FEES;
        }

        uint256 amountOutHighFee;
        if (
            (amountOutHighFee = _quoteExactInputSingle(data_, HIGH_FEES)) >
            amountOut
        ) {
            amountOut = amountOutHighFee;
            fee = HIGH_FEES;
        }

        return
            UniswapV3Result({
                id: data_.id,
                amountOut: amountOut,
                fee: fee,
                message: OK
            });
    }

    function _quoteExactInputSingle(UniswapV3Data memory data_, uint24 fee_)
        internal
        returns (uint256)
    {
        PoolKey memory poolKey = _getPoolKey(
            data_.tokenIn,
            data_.tokenOut,
            fee_
        );
        if (
            IUniswapV3Factory(FACTORY).getPool(
                poolKey.token0,
                poolKey.token1,
                poolKey.fee
            ) == address(0)
        ) return 0;
        return
            IQuoter(QUOTER).quoteExactInputSingle(
                data_.tokenIn,
                data_.tokenOut,
                fee_,
                data_.amountIn,
                0
            );
    }

    function _getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }
}

// 
pragma solidity 0.8.7;

struct UniswapV3Result {
    bytes32 id;
    uint256 amountOut;
    uint24 fee;
    string message;
}

struct UniswapV3Data {
    bytes32 id;
    address tokenIn;
    address tokenOut;
    uint256 amountIn;
}

struct PoolKey {
    address token0;
    address token1;
    uint24 fee;
}