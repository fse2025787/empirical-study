// SPDX-License-Identifier: GPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2021-05-17
*/

// File: contracts/interface/ICoFiXV2VaultForTrader.sol

// 

pragma solidity 0.6.12;

interface ICoFiXV2VaultForTrader {

    event RouterAllowed(address router);
    event RouterDisallowed(address router);

    event ClearPendingRewardOfCNode(uint256 pendingAmount);
    event ClearPendingRewardOfLP(uint256 pendingAmount);

    function setGovernance(address gov) external;

    function setCofiRate(uint256 cofiRate) external;

    function allowRouter(address router) external;

    function disallowRouter(address router) external;

    function calcMiningRate(address pair, uint256 neededETHAmount) external view returns (uint256);

    function calcNeededETHAmountForAdjustment(address pair, uint256 reserve0, uint256 reserve1, uint256 ethAmount, uint256 erc20Amount) external view returns (uint256);

    function actualMiningAmount(address pair, uint256 reserve0, uint256 reserve1, uint256 ethAmount, uint256 erc20Amount) external view returns (uint256 amount, uint256 totalAccruedAmount, uint256 neededETHAmount);

    function distributeReward(address pair, uint256 ethAmount, uint256 erc20Amount, address rewardTo) external;

    function clearPendingRewardOfCNode() external;

    function clearPendingRewardOfLP(address pair) external;

    function getPendingRewardOfCNode() external view returns (uint256);

    function getPendingRewardOfLP(address pair) external view returns (uint256);

}

// File: contracts/interface/ICoFiXStakingRewards.sol

pragma solidity 0.6.12;


interface ICoFiXStakingRewards {
    // Views

    
    
    function rewardsVault() external view returns (address);

    
    
    function lastBlockRewardApplicable() external view returns (uint256);

    
    function rewardPerToken() external view returns (uint256);

    
    
    
    function earned(address account) external view returns (uint256);

    
    
    function accrued() external view returns (uint256);

    
    
    function rewardRate() external view returns (uint256);

    
    
    function totalSupply() external view returns (uint256);

    
    
    
    function balanceOf(address account) external view returns (uint256);

    
    
    function stakingToken() external view returns (address);

    
    
    function rewardsToken() external view returns (address);

    // Mutative

    
    
    function stake(uint256 amount) external;

    
    
    
    function stakeForOther(address other, uint256 amount) external;

    
    
    function withdraw(uint256 amount) external;

    
    function emergencyWithdraw() external;

    
    function getReward() external;

    function getRewardAndStake() external;

    
    function exit() external;

    
    function addReward(uint256 amount) external;

    // Events
    event RewardAdded(address sender, uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event StakedForOther(address indexed user, address indexed other, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
}
// File: contracts/interface/ICoFiXVaultForLP.sol

pragma solidity 0.6.12;

interface ICoFiXVaultForLP {

    enum POOL_STATE {INVALID, ENABLED, DISABLED}

    event NewPoolAdded(address pool, uint256 index);
    event PoolEnabled(address pool);
    event PoolDisabled(address pool);

    function setGovernance(address _new) external;
    function setInitCoFiRate(uint256 _new) external;
    function setDecayPeriod(uint256 _new) external;
    function setDecayRate(uint256 _new) external;

    function addPool(address pool) external;
    function enablePool(address pool) external;
    function disablePool(address pool) external;
    function setPoolWeight(address pool, uint256 weight) external;
    function batchSetPoolWeight(address[] memory pools, uint256[] memory weights) external;
    function distributeReward(address to, uint256 amount) external;

    function getPendingRewardOfLP(address pair) external view returns (uint256);
    function currentPeriod() external view returns (uint256);
    function currentCoFiRate() external view returns (uint256);
    function currentPoolRate(address pool) external view returns (uint256 poolRate);
    function currentPoolRateByPair(address pair) external view returns (uint256 poolRate);

    
    
    
    function stakingPoolForPair(address pair) external view returns (address pool);

    function getPoolInfo(address pool) external view returns (POOL_STATE state, uint256 weight);
    function getPoolInfoByPair(address pair) external view returns (POOL_STATE state, uint256 weight);

    function getEnabledPoolCnt() external view returns (uint256);

    function getCoFiStakingPool() external view returns (address pool);

}
// File: contracts/interface/ICoFiXERC20.sol

pragma solidity 0.6.12;

interface ICoFiXERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    // function name() external pure returns (string memory);
    // function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

// File: contracts/interface/ICoFiXV2Pair.sol

pragma solidity 0.6.12;


interface ICoFiXV2Pair is ICoFiXERC20 {

    struct OraclePrice {
        uint256 ethAmount;
        uint256 erc20Amount;
        uint256 blockNum;
        uint256 K;
        uint256 theta;
    }

    // All pairs: {ETH <-> ERC20 Token}
    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, address outToken, uint outAmount, address indexed to);
    event Swap(
        address indexed sender,
        uint amountIn,
        uint amountOut,
        address outToken,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1);

    function mint(address to, uint amountETH, uint amountToken) external payable returns (uint liquidity, uint oracleFeeChange);
    function burn(address tokenTo, address ethTo) external payable returns (uint amountTokenOut, uint amountETHOut, uint oracleFeeChange);
    function swapWithExact(address outToken, address to) external payable returns (uint amountIn, uint amountOut, uint oracleFeeChange, uint256[5] memory tradeInfo);
    // function swapForExact(address outToken, uint amountOutExact, address to) external payable returns (uint amountIn, uint amountOut, uint oracleFeeChange, uint256[4] memory tradeInfo);
    function skim(address to) external;
    function sync() external;

    function initialize(address, address, string memory, string memory, uint256, uint256) external;

    
    
    
    
    function getNAVPerShare(uint256 ethAmount, uint256 erc20Amount) external view returns (uint256 navps);

    
    
    
    function getInitialAssetRatio() external view returns (uint256 _initToken0Amount, uint256 _initToken1Amount);
}

// File: contracts/interface/IWETH.sol

pragma solidity 0.6.12;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address account) external view returns (uint);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity >=0.6.0 <0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// File: contracts/interface/ICoFiXV2Router.sol

pragma solidity 0.6.12;

interface ICoFiXV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    enum DEX_TYPE { COFIX, UNISWAP }

    // All pairs: {ETH <-> ERC20 Token}

    
    
    
    
    
    
    
    
    function addLiquidity(
        address token,
        uint amountETH,
        uint amountToken,
        uint liquidityMin,
        address to,
        uint deadline
    ) external payable returns (uint liquidity);

    
    
    
    
    
    
    
    
    function addLiquidityAndStake(
        address token,
        uint amountETH,
        uint amountToken,
        uint liquidityMin,
        address to,
        uint deadline
    ) external payable returns (uint liquidity);

    
    
    
    
    
    
    
    
    function removeLiquidityGetTokenAndETH(
        address token,
        uint liquidity,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH);

    
    
    
    
    
    
    
    
    
    function swapExactETHForTokens(
        address token,
        uint amountIn,
        uint amountOutMin,
        address to,
        address rewardTo,
        uint deadline
    ) external payable returns (uint _amountIn, uint _amountOut);

    
    
    
    
    
    
    
    
    
    function swapExactTokensForETH(
        address token,
        uint amountIn,
        uint amountOutMin,
        address to,
        address rewardTo,
        uint deadline
    ) external payable returns (uint _amountIn, uint _amountOut);

    
    
    
    
    
    
    
    
    
    
    function swapExactTokensForTokens(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        address to,
        address rewardTo,
        uint deadline
    ) external payable returns (uint _amountIn, uint _amountOut);

    
    
    
    
    
    
    
    
    
    function hybridSwapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        DEX_TYPE[] calldata dexes,
        address to,
        address rewardTo,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    
    
    
    
    
    
    
    
    
    function hybridSwapExactETHForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        DEX_TYPE[] calldata dexes,
        address to,
        address rewardTo,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    
    
    
    
    
    
    
    
    
    function hybridSwapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        DEX_TYPE[] calldata dexes,
        address to,
        address rewardTo,
        uint deadline
    ) external payable returns (uint[] memory amounts);

}

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// File: contracts/lib/UniswapV2Library.sol

pragma solidity 0.6.12;


interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// File: contracts/lib/TransferHelper.sol

pragma solidity 0.6.12;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// File: contracts/interface/ICoFiXV2Factory.sol

pragma solidity 0.6.12;

interface ICoFiXV2Factory {
    // All pairs: {ETH <-> ERC20 Token}
    event PairCreated(address indexed token, address pair, uint256);
    event NewGovernance(address _new);
    event NewController(address _new);
    event NewFeeReceiver(address _new);
    event NewFeeVaultForLP(address token, address feeVault);
    event NewVaultForLP(address _new);
    event NewVaultForTrader(address _new);
    event NewVaultForCNode(address _new);
    event NewDAO(address _new);

    
    
    
    
    
    function createPair(
        address token,
	    uint256 initToken0Amount,
        uint256 initToken1Amount
        )
        external
        returns (address pair);

    function getPair(address token) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function getTradeMiningStatus(address token) external view returns (bool status);
    function setTradeMiningStatus(address token, bool status) external;
    function getFeeVaultForLP(address token) external view returns (address feeVault); // for LPs
    function setFeeVaultForLP(address token, address feeVault) external;

    function setGovernance(address _new) external;
    function setController(address _new) external;
    function setFeeReceiver(address _new) external;
    function setVaultForLP(address _new) external;
    function setVaultForTrader(address _new) external;
    function setVaultForCNode(address _new) external;
    function setDAO(address _new) external;
    function getController() external view returns (address controller);
    function getFeeReceiver() external view returns (address feeReceiver); // For CoFi Holders
    function getVaultForLP() external view returns (address vaultForLP);
    function getVaultForTrader() external view returns (address vaultForTrader);
    function getVaultForCNode() external view returns (address vaultForCNode);
    function getDAO() external view returns (address dao);
}

// File: contracts/CoFiXV2Router.sol

pragma solidity 0.6.12;

// Router contract to interact with each CoFiXPair, no owner or governance
contract CoFiXV2Router is ICoFiXV2Router {
    using SafeMath for uint;

    address public immutable override factory;
    address public immutable uniFactory;
    address public immutable override WETH;

    uint256 internal constant NEST_ORACLE_FEE = 0.01 ether;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'CRouter: EXPIRED');
        _;
    }

    constructor(address _factory, address _uniFactory, address _WETH) public {
        factory = _factory;
        uniFactory = _uniFactory;
        WETH = _WETH;
    }

    receive() external payable {}

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address _factory, address token) internal view returns (address pair) {
        // pair = address(uint(keccak256(abi.encodePacked(
        //         hex'ff',
        //         _factory,
        //         keccak256(abi.encodePacked(token)),
        //         hex'fb0c5470b7fbfce7f512b5035b5c35707fd5c7bd43c8d81959891b0296030118' // init code hash
        //     )))); // calc the real init code hash, not suitable for us now, could use this in the future
        return ICoFiXV2Factory(_factory).getPair(token);
    }

    // msg.value = amountETH + oracle fee
    function addLiquidity(
        address token,
        uint amountETH,
        uint amountToken,
        uint liquidityMin,
        address to,
        uint deadline
    ) external override payable ensure(deadline) returns (uint liquidity)
    {
        require(msg.value > amountETH, "CRouter: insufficient msg.value");
        uint256 _oracleFee = msg.value.sub(amountETH);
        address pair = pairFor(factory, token);
        if (amountToken > 0 ) { // support for tokens which do not allow to transfer zero values
            TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        }
        if (amountETH > 0) {
            IWETH(WETH).deposit{value: amountETH}();
            assert(IWETH(WETH).transfer(pair, amountETH));
        }
        uint256 oracleFeeChange;
        (liquidity, oracleFeeChange) = ICoFiXV2Pair(pair).mint{value: _oracleFee}(to, amountETH, amountToken);
        require(liquidity >= liquidityMin, "CRouter: less liquidity than expected");
        // refund oracle fee to msg.sender, if any
        if (oracleFeeChange > 0) TransferHelper.safeTransferETH(msg.sender, oracleFeeChange);
    }

    // msg.value = amountETH + oracle fee
    function addLiquidityAndStake(
        address token,
        uint amountETH,
        uint amountToken,
        uint liquidityMin,
        address to,
        uint deadline
    ) external override payable ensure(deadline) returns (uint liquidity)
    {
        // must create a pair before using this function
        require(msg.value > amountETH, "CRouter: insufficient msg.value");
        uint256 _oracleFee = msg.value.sub(amountETH);
        address pair = pairFor(factory, token);
        require(pair != address(0), "CRouter: invalid pair");
        if (amountToken > 0 ) { // support for tokens which do not allow to transfer zero values
            TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        }
        if (amountETH > 0) {
            IWETH(WETH).deposit{value: amountETH}();
            assert(IWETH(WETH).transfer(pair, amountETH));
        }
        uint256 oracleFeeChange;
        (liquidity, oracleFeeChange) = ICoFiXV2Pair(pair).mint{value: _oracleFee}(address(this), amountETH, amountToken);
        require(liquidity >= liquidityMin, "CRouter: less liquidity than expected");

        // find the staking rewards pool contract for the liquidity token (pair)
        address pool = ICoFiXVaultForLP(ICoFiXV2Factory(factory).getVaultForLP()).stakingPoolForPair(pair);
        require(pool != address(0), "CRouter: invalid staking pool");
        // approve to staking pool
        ICoFiXV2Pair(pair).approve(pool, liquidity);
        ICoFiXStakingRewards(pool).stakeForOther(to, liquidity);
        ICoFiXV2Pair(pair).approve(pool, 0); // ensure
        // refund oracle fee to msg.sender, if any
        if (oracleFeeChange > 0) TransferHelper.safeTransferETH(msg.sender, oracleFeeChange);
    }

    // msg.value = oracle fee
    function removeLiquidityGetTokenAndETH(
        address token,
        uint liquidity,
        uint amountETHMin,
        address to,
        uint deadline
    ) external override payable ensure(deadline) returns (uint amountToken, uint amountETH) 
    {
        require(msg.value > 0, "CRouter: insufficient msg.value");
        
        address pair = pairFor(factory, token);
        ICoFiXV2Pair(pair).transferFrom(msg.sender, pair, liquidity);

        uint oracleFeeChange; 
        (amountToken, amountETH, oracleFeeChange) = ICoFiXV2Pair(pair).burn{value: msg.value}(to, address(this));

        require(amountETH >= amountETHMin, "CRouter: got less than expected");

        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);

        // refund oracle fee to msg.sender, if any
        if (oracleFeeChange > 0) TransferHelper.safeTransferETH(msg.sender, oracleFeeChange);
    }

    // msg.value = amountIn + oracle fee
    function swapExactETHForTokens(
        address token,
        uint amountIn,
        uint amountOutMin,
        address to,
        address rewardTo,
        uint deadline
    ) external override payable ensure(deadline) returns (uint _amountIn, uint _amountOut)
    {
        require(msg.value > amountIn, "CRouter: insufficient msg.value");
        IWETH(WETH).deposit{value: amountIn}();
        address pair = pairFor(factory, token);
        assert(IWETH(WETH).transfer(pair, amountIn));
        uint oracleFeeChange; 
        uint256[5] memory tradeInfo;
        (_amountIn, _amountOut, oracleFeeChange, tradeInfo) = ICoFiXV2Pair(pair).swapWithExact{
            value: msg.value.sub(amountIn)}(token, to);
        require(_amountOut >= amountOutMin, "CRouter: got less than expected");

        // distribute trading rewards - CoFi!
        address vaultForTrader = ICoFiXV2Factory(factory).getVaultForTrader();
        if (tradeInfo[0] > 0 && rewardTo != address(0) && vaultForTrader != address(0)) {
            ICoFiXV2VaultForTrader(vaultForTrader).distributeReward(pair, tradeInfo[1], tradeInfo[2], rewardTo);
        }

        // refund oracle fee to msg.sender, if any
        if (oracleFeeChange > 0) TransferHelper.safeTransferETH(msg.sender, oracleFeeChange);
    }

    // msg.value = oracle fee
    function swapExactTokensForTokens(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        address to,
        address rewardTo,
        uint deadline
    ) external override payable ensure(deadline) returns (uint _amountIn, uint _amountOut) {

        require(msg.value > 0, "CRouter: insufficient msg.value");
        address[2] memory pairs; // [pairIn, pairOut]

        // swapExactTokensForETH
        pairs[0] = pairFor(factory, tokenIn);
        TransferHelper.safeTransferFrom(tokenIn, msg.sender, pairs[0], amountIn);
        uint oracleFeeChange;
        uint256[5] memory tradeInfo;
        (_amountIn, _amountOut, oracleFeeChange, tradeInfo) = ICoFiXV2Pair(pairs[0]).swapWithExact{value: msg.value}(WETH, address(this));

        // distribute trading rewards - CoFi!
        address vaultForTrader = ICoFiXV2Factory(factory).getVaultForTrader();
        if (tradeInfo[0] > 0 && rewardTo != address(0) && vaultForTrader != address(0)) {
            ICoFiXV2VaultForTrader(vaultForTrader).distributeReward(pairs[0], tradeInfo[1], tradeInfo[2], rewardTo);
        }

        // swapExactETHForTokens
        pairs[1] = pairFor(factory, tokenOut);
        assert(IWETH(WETH).transfer(pairs[1], _amountOut)); // swap with all amountOut in last swap
        (, _amountOut, oracleFeeChange, tradeInfo) = ICoFiXV2Pair(pairs[1]).swapWithExact{value: oracleFeeChange}(tokenOut, to);
        require(_amountOut >= amountOutMin, "CRouter: got less than expected");

        // distribute trading rewards - CoFi!
        if (tradeInfo[0] > 0 && rewardTo != address(0) && vaultForTrader != address(0)) {
            ICoFiXV2VaultForTrader(vaultForTrader).distributeReward(pairs[1], tradeInfo[1], tradeInfo[2], rewardTo);
        }

        // refund oracle fee to msg.sender, if any
        if (oracleFeeChange > 0) TransferHelper.safeTransferETH(msg.sender, oracleFeeChange);
    }

    // msg.value = oracle fee
    function swapExactTokensForETH(
        address token,
        uint amountIn,
        uint amountOutMin,
        address to,
        address rewardTo,
        uint deadline
    ) external override payable ensure(deadline) returns (uint _amountIn, uint _amountOut)
    {
        require(msg.value > 0, "CRouter: insufficient msg.value");
        address pair = pairFor(factory, token);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountIn);
        uint oracleFeeChange; 
        uint256[5] memory tradeInfo;
        (_amountIn, _amountOut, oracleFeeChange, tradeInfo) = ICoFiXV2Pair(pair).swapWithExact{value: msg.value}(WETH, address(this));
        require(_amountOut >= amountOutMin, "CRouter: got less than expected");
        IWETH(WETH).withdraw(_amountOut);
        TransferHelper.safeTransferETH(to, _amountOut);

        // distribute trading rewards - CoFi!
        address vaultForTrader = ICoFiXV2Factory(factory).getVaultForTrader();
        if (tradeInfo[0] > 0 && rewardTo != address(0) && vaultForTrader != address(0)) {
            ICoFiXV2VaultForTrader(vaultForTrader).distributeReward(pair, tradeInfo[1], tradeInfo[2], rewardTo);
        }

        // refund oracle fee to msg.sender, if any
        if (oracleFeeChange > 0) TransferHelper.safeTransferETH(msg.sender, oracleFeeChange);
    }

    function hybridSwapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        DEX_TYPE[] calldata dexes,
        address to,
        address rewardTo,
        uint deadline
    ) external override payable ensure(deadline) returns (uint[] memory amounts) {
        // fast check
        require(path.length >= 2, "CRouter: invalid path");
        require(dexes.length == path.length - 1, "CRouter: invalid dexes");
        _checkOracleFee(dexes, msg.value);

        // send amountIn to the first pair
        TransferHelper.safeTransferFrom(
            path[0], msg.sender,  getPairForDEX(path[0], path[1], dexes[0]), amountIn
        );

        // exec hybridSwap
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        _hybridSwap(path, dexes, amounts, to, rewardTo);

        // check amountOutMin in the last
        require(amounts[amounts.length - 1] >= amountOutMin, "CRouter: insufficient output amount ");
    }

    function hybridSwapExactETHForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        DEX_TYPE[] calldata dexes,
        address to,
        address rewardTo,
        uint deadline
    ) external override payable ensure(deadline) returns (uint[] memory amounts) {
        // fast check
        require(path.length >= 2 && path[0] == WETH, "CRouter: invalid path");
        require(dexes.length == path.length - 1, "CRouter: invalid dexes");
        _checkOracleFee(dexes, msg.value.sub(amountIn)); // would revert if msg.value is less than amountIn

        // convert ETH and send amountIn to the first pair
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(getPairForDEX(path[0], path[1], dexes[0]), amountIn));

        // exec hybridSwap
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        _hybridSwap(path, dexes, amounts, to, rewardTo);

        // check amountOutMin in the last
        require(amounts[amounts.length - 1] >= amountOutMin, "CRouter: insufficient output amount ");
    }

    function hybridSwapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        DEX_TYPE[] calldata dexes,
        address to,
        address rewardTo,
        uint deadline
    ) external override payable ensure(deadline) returns (uint[] memory amounts) {
        // fast check
        require(path.length >= 2 && path[path.length - 1] == WETH, "CRouter: invalid path");
        require(dexes.length == path.length - 1, "CRouter: invalid dexes");
        _checkOracleFee(dexes, msg.value);

        // send amountIn to the first pair
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, getPairForDEX(path[0], path[1], dexes[0]), amountIn
        );

        // exec hybridSwap
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        _hybridSwap(path, dexes, amounts, address(this), rewardTo);

        // check amountOutMin in the last
        require(amounts[amounts.length - 1] >= amountOutMin, "CRouter: insufficient output amount ");

        // convert WETH
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }


    function _checkOracleFee(DEX_TYPE[] memory dexes, uint256 oracleFee) internal pure {
        uint cofixCnt;
        for (uint i; i < dexes.length; i++) {
            if (dexes[i] == DEX_TYPE.COFIX) {
                cofixCnt++;
            }
        }
        // strict check here
        // to simplify the verify logic for oracle fee and prevent user from locking oracle fee by mistake
        // if NEST_ORACLE_FEE value changed, this router would not work as expected
        // TODO: refund the oracle fee?
        require(oracleFee == NEST_ORACLE_FEE.mul(cofixCnt), "CRouter: wrong oracle fee");
    }

    function _hybridSwap(address[] memory path, DEX_TYPE[] memory dexes, uint[] memory amounts, address _to, address rewardTo) internal {
        for (uint i; i < path.length - 1; i++) {
            if (dexes[i] == DEX_TYPE.COFIX) {
                _swapOnCoFiX(i, path, dexes, amounts, _to, rewardTo);
            } else if (dexes[i] == DEX_TYPE.UNISWAP) {
                _swapOnUniswap(i, path, dexes, amounts, _to);
            } else {
                revert("CRouter: unknown dex");
            }
        }
    }

    function _swapOnUniswap(uint i, address[] memory path, DEX_TYPE[] memory dexes, uint[] memory amounts, address _to) internal {
        address pair = getPairForDEX(path[i], path[i + 1], DEX_TYPE.UNISWAP);

        (address token0,) = UniswapV2Library.sortTokens(path[i], path[i + 1]);
        {
            (uint reserveIn, uint reserveOut) = UniswapV2Library.getReserves(uniFactory, path[i], path[i + 1]);
            amounts[i + 1] = UniswapV2Library.getAmountOut(amounts[i], reserveIn, reserveOut);
        }
        uint amountOut = amounts[i + 1];
        (uint amount0Out, uint amount1Out) = path[i] == token0 ? (uint(0), amountOut) : (amountOut, uint(0));

        address to;
        {
            if (i < path.length - 2) {
                to = getPairForDEX(path[i + 1], path[i + 2], dexes[i + 1]);
            } else {
                to = _to;
            }
        }

        IUniswapV2Pair(pair).swap(
            amount0Out, amount1Out, to, new bytes(0)
        );
    }
    
    function _swapOnCoFiX(uint i, address[] memory path, DEX_TYPE[] memory dexes, uint[] memory amounts, address _to, address rewardTo) internal {
            address pair = getPairForDEX(path[i], path[i + 1], DEX_TYPE.COFIX);
            address to;
            if (i < path.length - 2) {
                to = getPairForDEX(path[i + 1], path[i + 2], dexes[i + 1]);
            } else {
                to = _to;
            }
            // TODO: dynamic oracle fee
            {
                uint256[5] memory tradeInfo;
                (,amounts[i+1],,tradeInfo) = ICoFiXV2Pair(pair).swapWithExact{value: NEST_ORACLE_FEE}(path[i + 1], to);

                // distribute trading rewards - CoFi!
                address vaultForTrader = ICoFiXV2Factory(factory).getVaultForTrader();
                if (tradeInfo[0] > 0 && rewardTo != address(0) && vaultForTrader != address(0)) {
                    ICoFiXV2VaultForTrader(vaultForTrader).distributeReward(pair, tradeInfo[1], tradeInfo[2], rewardTo);
                }
            }
    } 

    function isCoFiXNativeSupported(address input, address output) public view returns (bool supported, address pair) {
        // NO WETH included
        if (input != WETH && output != WETH)
            return (false, pair);
        if (input != WETH) {
            pair = pairFor(factory, input);
        } else if (output != WETH) {
            pair = pairFor(factory, output);
        }
        // if tokenIn & tokenOut are both WETH, then the pair is zero
        if (pair != address(0)) // TODO: add check for reserves
            supported = true;
        return (supported, pair);
    }

    function getPairForDEX(address input, address output, DEX_TYPE dex) public view returns (address pair) {
        if (dex == DEX_TYPE.COFIX) {
            bool supported;
            (supported, pair) = isCoFiXNativeSupported(input, output);
            if (!supported) {
                revert("CRouter: not available on CoFiX");
            }
        } else if (dex == DEX_TYPE.UNISWAP) {
            pair = UniswapV2Library.pairFor(uniFactory, input, output);
        } else {
            revert("CRouter: unknown dex");
        }
    }

    // TODO: not used currently
    function hybridPair(address input, address output) public view returns (bool useCoFiX, address pair) {
        (useCoFiX, pair) = isCoFiXNativeSupported(input, output);
        if (useCoFiX) {
            return (useCoFiX, pair);
        }
        return (false, UniswapV2Library.pairFor(uniFactory, input, output));
    }
}