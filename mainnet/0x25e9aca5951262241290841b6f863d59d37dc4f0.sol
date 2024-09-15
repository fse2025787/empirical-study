// SPDX-License-Identifier: GPL-2.0-or-later
pragma abicoder v2;

/**
 *Submitted for verification at Etherscan.io on 2022-12-20
*/

// 
pragma solidity >=0.8.0;

// Sources flattened with hardhat v2.12.0 https://hardhat.org

// File @openzeppelin/contracts/security/[email protected]

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)


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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)


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


// File @uniswap/v3-core/contracts/libraries/[email protected]




library SafeCast {
    
    
    
    function toUint160(uint256 y) internal pure returns (uint160 z) {
        require((z = uint160(y)) == y);
    }

    
    
    
    function toInt128(int256 y) internal pure returns (int128 z) {
        require((z = int128(y)) == y);
    }

    
    
    
    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y < 2**255);
        z = int256(y);
    }
}


// File @uniswap/v2-periphery/contracts/interfaces/[email protected]


interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}


// File @uniswap/v3-periphery/contracts/libraries/[email protected]


library TransferHelper {
    
    
    
    
    
    
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    
    
    
    
    
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    
    
    
    
    
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    
    
    
    
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}


// File @uniswap/v3-core/contracts/interfaces/pool/[email protected]




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


// File @uniswap/v3-core/contracts/interfaces/pool/[email protected]




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


// File @uniswap/v3-core/contracts/interfaces/pool/[email protected]




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


// File @uniswap/v3-core/contracts/interfaces/pool/[email protected]




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


// File @uniswap/v3-core/contracts/interfaces/pool/[email protected]




interface IUniswapV3PoolOwnerActions {
    
    
    
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    
    
    
    
    
    
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}


// File @uniswap/v3-core/contracts/interfaces/pool/[email protected]




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


// File @uniswap/v3-core/contracts/interfaces/[email protected]









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


// File @uniswap/v2-core/contracts/interfaces/[email protected]


interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
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

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


// File @uniswap/v3-core/contracts/interfaces/callback/[email protected]




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


// File contracts/Fraxswap/periphery/FraxswapRouterMultihop.sol



// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ===================== Fraxswap Router Multihop =====================
// ====================================================================
// Fraxswap Router Multihop

// Frax Finance: https://github.com/FraxFinance

// Primary Author(s)
// Rich: https://github.com/zer0blockchain
// Dennis: https://github.com/denett

// Reviewer(s) / Contributor(s)
// Travis Moore: https://github.com/FortisFortuna
// Sam Kazemian: https://github.com/samkazemian
// Drake Evans:  https://github.com/DrakeEvans
// Jack Corddry: https://github.com/corddry
// Justin Moore: https://github.com/0xJM


contract FraxswapRouterMultihop is ReentrancyGuard, Ownable {
    using SafeCast for uint256;
    using SafeCast for int256;

    IWETH WETH9;
    address FRAX;

    constructor(IWETH _WETH9, address _FRAX) {
        WETH9 = _WETH9;
        FRAX = _FRAX;
    }

    
    modifier checkDeadline(uint256 deadline) {
        require(block.timestamp <= deadline, "Transaction too old");
        _;
    }

    
    receive() external payable {
        assert(msg.sender == address(WETH9));
    }

    /// ---------------------------
    /// --------- Public ----------
    /// ---------------------------

    
    
    
    function swap(FraxswapParams memory params)
        external
        payable
        nonReentrant
        checkDeadline(params.deadline)
        returns (uint256 amountOut)
    {
        if (params.tokenIn == address(0)) {
            // ETH sent in via msg.value
            require(msg.value == params.amountIn, "FSR:II"); // Insufficient input ETH
        } else {
            if (params.v != 0) {
                // use permit instead of approval
                uint256 amount = params.approveMax
                    ? type(uint256).max
                    : params.amountIn;
                IERC20Permit(params.tokenIn).permit(
                    msg.sender,
                    address(this),
                    amount,
                    params.deadline,
                    params.v,
                    params.r,
                    params.s
                );
            }
            // Pull tokens into the Router Contract
            TransferHelper.safeTransferFrom(
                params.tokenIn,
                msg.sender,
                address(this),
                params.amountIn
            );
        }

        FraxswapRoute memory route = abi.decode(params.route, (FraxswapRoute));
        route.tokenOut = params.tokenIn;
        route.amountOut = params.amountIn;

        for (uint256 i; i < route.nextHops.length; ++i) {
            FraxswapRoute memory nextRoute = abi.decode(
                route.nextHops[i],
                (FraxswapRoute)
            );
            executeAllHops(route, nextRoute);
        }

        bool outputETH = params.tokenOut == address(0); // save gas

        amountOut = outputETH
            ? address(this).balance
            : IERC20(params.tokenOut).balanceOf(address(this));

        // Check output amounts and send to recipient (IMPORTANT CHECK)
        require(amountOut >= params.amountOutMinimum, "FSR:IO"); // Insufficient output

        if (outputETH) {
            // sending ETH
            (bool success, ) = payable(params.recipient).call{value: amountOut}(
                ""
            );
            require(success, "FSR:Invalid transfer");
        } else {
            TransferHelper.safeTransfer(
                params.tokenOut,
                params.recipient,
                amountOut
            );
        }

        emit Routed(
            params.tokenIn,
            params.tokenOut,
            params.amountIn,
            amountOut
        );
    }

    
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata _data
    ) external {
        require(amount0Delta > 0 || amount1Delta > 0);
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        if (!data.directFundThisPool) {
            // it isn't directly funded we pay from the router address
            TransferHelper.safeTransfer(
                data.tokenIn,
                msg.sender,
                uint256(amount0Delta > 0 ? amount0Delta : amount1Delta)
            );
        }
    }

    /// ---------------------------
    /// --------- Internal --------
    /// ---------------------------

    
    
    
    
    
    function executeSwap(
        FraxswapRoute memory prevRoute,
        FraxswapRoute memory route,
        FraxswapStepData memory step
    ) internal returns (uint256 amountOut) {
        uint256 amountIn = getAmountForPct(
            step.percentOfHop,
            route.percentOfHop,
            prevRoute.amountOut
        );
        if (step.swapType < 2) {
            // Fraxswap/Uni v2
            bool zeroForOne = prevRoute.tokenOut < step.tokenOut;
            if (step.swapType == 0) {
                // Execute virtual orders for Fraxswap
                PoolInterface(step.pool).executeVirtualOrders(block.timestamp);
            }
            if (step.extraParam1 == 1) {
                // Fraxswap V2 has getAmountOut in the pair (different fees)
                amountOut = PoolInterface(step.pool).getAmountOut(
                    amountIn,
                    prevRoute.tokenOut
                );
            } else {
                // use the reserves and helper function for Uniswap V2 and Fraxswap V1
                (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(
                    step.pool
                ).getReserves();
                amountOut = getAmountOut(
                    amountIn,
                    zeroForOne ? reserve0 : reserve1,
                    zeroForOne ? reserve1 : reserve0
                );
            }
            if (step.directFundThisPool == 0) {
                // this pool is funded by router
                TransferHelper.safeTransfer(
                    prevRoute.tokenOut,
                    step.pool,
                    amountIn
                );
            }
            IUniswapV2Pair(step.pool).swap(
                zeroForOne ? 0 : amountOut,
                zeroForOne ? amountOut : 0,
                step.directFundNextPool == 1
                    ? getNextDirectFundingPool(route)
                    : address(this),
                new bytes(0)
            );
        } else if (step.swapType == 2) {
            // Uni v3
            bool zeroForOne = prevRoute.tokenOut < step.tokenOut;
            (int256 amount0, int256 amount1) = IUniswapV3Pool(step.pool).swap(
                step.directFundNextPool == 1
                    ? getNextDirectFundingPool(route)
                    : address(this),
                zeroForOne,
                amountIn.toInt256(),
                zeroForOne
                    ? 4295128740
                    : 1461446703485210103287273052203988822378723970341, // Do not fail because of price
                abi.encode(
                    SwapCallbackData({
                        tokenIn: prevRoute.tokenOut,
                        directFundThisPool: step.directFundThisPool == 1
                    })
                )
            );
            amountOut = uint256(zeroForOne ? -amount1 : -amount0);
        } else if (step.swapType == 3) {
            // Curve exchange V2
            TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
            PoolInterface(step.pool).exchange(
                step.extraParam1,
                step.extraParam2,
                amountIn,
                0
            );
            amountOut = IERC20(step.tokenOut).balanceOf(address(this));
        } else if (step.swapType == 4) {
            // Curve exchange, with returns
            uint256 value = 0;
            if (prevRoute.tokenOut == address(WETH9)) {
                // WETH send as ETH
                WETH9.withdraw(amountIn);
                value = amountIn;
            } else {
                TransferHelper.safeApprove(
                    prevRoute.tokenOut,
                    step.pool,
                    amountIn
                );
            }
            amountOut = PoolInterface(step.pool).exchange{value: value}(
                int128(int256(step.extraParam1)),
                int128(int256(step.extraParam2)),
                amountIn,
                0
            );
            if (route.tokenOut == address(WETH9)) {
                // Wrap the received ETH as WETH
                WETH9.deposit{value: amountOut}();
            }
        } else if (step.swapType == 5) {
            // Curve exchange_underlying
            TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
            amountOut = PoolInterface(step.pool).exchange_underlying(
                int128(int256(step.extraParam1)),
                int128(int256(step.extraParam2)),
                amountIn,
                0
            );
        } else if (step.swapType == 6) {
            // Saddle
            TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
            amountOut = PoolInterface(step.pool).swap(
                uint8(step.extraParam1),
                uint8(step.extraParam2),
                amountIn,
                0,
                block.timestamp
            );
        } else if (step.swapType == 7) {
            // FPIController
            TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
            if (prevRoute.tokenOut == FRAX) {
                amountOut = PoolInterface(step.pool).mintFPI(amountIn, 0);
            } else {
                amountOut = PoolInterface(step.pool).redeemFPI(amountIn, 0);
            }
        } else if (step.swapType == 8) {
            // Fraxlend
            TransferHelper.safeApprove(prevRoute.tokenOut, step.pool, amountIn);
            amountOut = PoolInterface(step.pool).deposit(
                amountIn,
                address(this)
            );
        } else if (step.swapType == 9) {
            // FrxETHMinter
            if (step.extraParam1 == 0 && prevRoute.tokenOut == address(WETH9)) {
                // Unwrap WETH
                WETH9.withdraw(amountIn);
            }
            PoolInterface(step.pool).submitAndGive{value: amountIn}(
                step.directFundNextPool == 1
                    ? getNextDirectFundingPool(route)
                    : address(this)
            );
            amountOut = amountIn; // exchange 1 for 1
        } else if (step.swapType == 10) {
            // WETH
            if (prevRoute.tokenOut == address(WETH9)) {
                // Unwrap WETH
                WETH9.withdraw(amountIn);
            } else {
                // Wrap the ETH
                WETH9.deposit{value: amountIn}();
            }
            amountOut = amountIn; // exchange 1 for 1
        } else if (step.swapType == 999) {
            // Generic Pool
            if (step.directFundThisPool == 0) {
                // this pool is funded by router
                TransferHelper.safeTransfer(
                    prevRoute.tokenOut,
                    step.pool,
                    amountIn
                );
            }
            amountOut = PoolInterface(step.pool).swap(
                prevRoute.tokenOut,
                route.tokenOut,
                amountIn,
                step.directFundNextPool == 1
                    ? getNextDirectFundingPool(route)
                    : address(this)
            );
        }

        emit Swapped(
            step.pool,
            prevRoute.tokenOut,
            step.tokenOut,
            amountIn,
            amountOut
        );
    }

    
    
    
    function executeAllStepsForRoute(
        FraxswapRoute memory prevRoute,
        FraxswapRoute memory route
    ) internal {
        for (uint256 j; j < route.steps.length; ++j) {
            FraxswapStepData memory step = abi.decode(
                route.steps[j],
                (FraxswapStepData)
            );
            route.amountOut += executeSwap(prevRoute, route, step);
        }
    }

    
    
    
    function executeAllHops(
        FraxswapRoute memory prevRoute,
        FraxswapRoute memory route
    ) internal {
        executeAllStepsForRoute(prevRoute, route);
        for (uint256 i; i < route.nextHops.length; ++i) {
            FraxswapRoute memory nextRoute = abi.decode(
                route.nextHops[i],
                (FraxswapRoute)
            );
            executeAllHops(route, nextRoute);
        }
    }

    /// ---------------------------
    /// ------ Views / Pure -------
    /// ---------------------------

    
    
    
    
    
    
    function encodeRoute(
        address tokenOut,
        uint256 percentOfHop,
        bytes[] memory steps,
        bytes[] memory nextHops
    ) external pure returns (bytes memory out) {
        FraxswapRoute memory route;
        route.tokenOut = tokenOut;
        route.amountOut = 0;
        route.percentOfHop = percentOfHop;
        route.steps = steps;
        route.nextHops = nextHops;
        out = abi.encode(route);
    }

    
    
    
    
    
    
    
    
    
    
    function encodeStep(
        uint8 swapType,
        uint8 directFundNextPool,
        uint8 directFundThisPool,
        address tokenOut,
        address pool,
        uint256 extraParam1,
        uint256 extraParam2,
        uint256 percentOfHop
    ) external pure returns (bytes memory out) {
        FraxswapStepData memory step;
        step.swapType = swapType;
        step.directFundNextPool = directFundNextPool;
        step.directFundThisPool = directFundThisPool;
        step.tokenOut = tokenOut;
        step.pool = pool;
        step.extraParam1 = extraParam1;
        step.extraParam2 = extraParam2;
        step.percentOfHop = percentOfHop;
        out = abi.encode(step);
    }

    
    
    function getAmountForPct(
        uint256 pctOfHop1,
        uint256 pctOfHop2,
        uint256 amountIn
    ) internal pure returns (uint256 amountOut) {
        return (pctOfHop1 * pctOfHop2 * amountIn) / 100_000_000;
    }

    
    
    function getNextDirectFundingPool(FraxswapRoute memory route)
        internal
        pure
        returns (address nextPoolAddress)
    {
        require(
            route.steps.length == 1 && route.nextHops.length == 1,
            "FSR: DFRoutes"
        ); // directFunding
        FraxswapRoute memory nextRoute = abi.decode(
            route.nextHops[0],
            (FraxswapRoute)
        );

        require(nextRoute.steps.length == 1, "FSR: DFSteps"); // directFunding
        FraxswapStepData memory nextStep = abi.decode(
            nextRoute.steps[0],
            (FraxswapStepData)
        );

        return nextStep.pool; // pool to send funds to
    }

    
    
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) internal pure returns (uint amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        uint amountInWithFee = amountIn * 997;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    /// ---------------------------
    /// --------- Structs ---------
    /// ---------------------------

    
    
    
    
    
    
    
    
    
    
    
    
    struct FraxswapParams {
        address tokenIn;
        uint256 amountIn;
        address tokenOut;
        uint256 amountOutMinimum;
        address recipient;
        uint256 deadline;
        bool approveMax;
        uint8 v;
        bytes32 r;
        bytes32 s;
        bytes route;
    }

    
    
    
    
    
    
    
    struct FraxswapRoute {
        address tokenOut;
        uint256 amountOut;
        uint256 percentOfHop;
        bytes[] steps;
        bytes[] nextHops;
    }

    
    
    
    
    
    
    
    
    
    
    struct FraxswapStepData {
        uint8 swapType;
        uint8 directFundNextPool;
        uint8 directFundThisPool;
        address tokenOut;
        address pool;
        uint256 extraParam1;
        uint256 extraParam2;
        uint256 percentOfHop;
    }

    
    
    
    struct SwapCallbackData {
        address tokenIn;
        bool directFundThisPool;
    }

    /// ---------------------------
    /// --------- Events ----------
    /// ---------------------------

    
    
    
    
    
    
    event Swapped(
        address pool,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    
    
    
    
    
    event Routed(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );
}

// Interface for ERC20 Permit
interface IERC20Permit is IERC20 {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// Interface used to call pool specific functions
interface PoolInterface {
    // Fraxswap
    function executeVirtualOrders(uint256 blockNumber) external;

    function getAmountOut(uint amountIn, address tokenIn)
        external
        view
        returns (uint);

    // Fraxlend
    function deposit(uint256 userId, address userAddress)
        external
        returns (uint256 _sharesReceived);

    // FrxETHMinter
    function submitAndGive(address recipient) external payable;

    // Curve
    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external;

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external payable returns (uint256);

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    // Saddle
    function swap(
        uint8 tokenIndexFrom,
        uint8 tokenIndexTo,
        uint256 dx,
        uint256 minDy,
        uint256 deadline
    ) external returns (uint256);

    //FPI Mint/Redeem
    function mintFPI(uint256 frax_in, uint256 min_fpi_out)
        external
        returns (uint256 fpi_out);

    function redeemFPI(uint256 fpi_in, uint256 min_frax_out)
        external
        returns (uint256 frax_out);

    // generic swap wrapper
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address target
    ) external returns (uint256 amountOut);
}