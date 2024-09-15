// SPDX-License-Identifier: GPL-2.0-or-later


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

pragma solidity 0.8.4;



interface IGUniRouter02 {
    function addLiquidity(
        IGUniPool _pool,
        uint256 _amount0Max,
        uint256 _amount1Max,
        uint256 _amount0Min,
        uint256 _amount1Min,
        address _receiver
    )
        external
        returns (
            uint256 amount0,
            uint256 amount1,
            uint256 mintAmount
        );

    function addLiquidityETH(
        IGUniPool _pool,
        uint256 _amount0Max,
        uint256 _amount1Max,
        uint256 _amount0Min,
        uint256 _amount1Min,
        address _receiver
    )
        external
        payable
        returns (
            uint256 amount0,
            uint256 amount1,
            uint256 mintAmount
        );

    function rebalanceAndAddLiquidity(
        IGUniPool _pool,
        uint256 _amount0In,
        uint256 _amount1In,
        uint256 _amountSwap,
        bool _zeroForOne,
        address[] calldata _swapActions,
        bytes[] calldata _swapDatas,
        uint256 _amount0Min,
        uint256 _amount1Min,
        address _receiver
    )
        external
        returns (
            uint256 amount0,
            uint256 amount1,
            uint256 mintAmount
        );

    function rebalanceAndAddLiquidityETH(
        IGUniPool _pool,
        uint256 _amount0In,
        uint256 _amount1In,
        uint256 _amountSwap,
        bool _zeroForOne,
        address[] calldata _swapActions,
        bytes[] calldata _swapDatas,
        uint256 _amount0Min,
        uint256 _amount1Min,
        address _receiver
    )
        external
        payable
        returns (
            uint256 amount0,
            uint256 amount1,
            uint256 mintAmount
        );

    function removeLiquidity(
        IGUniPool _pool,
        uint256 _burnAmount,
        uint256 _amount0Min,
        uint256 _amount1Min,
        address _receiver
    )
        external
        returns (
            uint256 amount0,
            uint256 amount1,
            uint128 liquidityBurned
        );

    function removeLiquidityETH(
        IGUniPool _pool,
        uint256 _burnAmount,
        uint256 _amount0Min,
        uint256 _amount1Min,
        address payable _receiver
    )
        external
        returns (
            uint256 amount0,
            uint256 amount1,
            uint128 liquidityBurned
        );
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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity 0.8.4;








contract GUniRouter02 is IGUniRouter02 {
    using Address for address payable;
    using SafeERC20 for IERC20;

    IWETH public immutable weth;

    constructor(IWETH _weth) {
        weth = _weth;
    }

    
    
    
    
    
    
    
    
    
    
    function addLiquidity(
        IGUniPool _pool,
        uint256 _amount0Max,
        uint256 _amount1Max,
        uint256 _amount0Min,
        uint256 _amount1Min,
        address _receiver
    )
        external
        override
        returns (
            uint256 amount0,
            uint256 amount1,
            uint256 mintAmount
        )
    {
        (amount0, amount1, mintAmount) = _pool.getMintAmounts(
            _amount0Max,
            _amount1Max
        );
        require(
            amount0 >= _amount0Min && amount1 >= _amount1Min,
            "below min amounts"
        );
        if (amount0 > 0) {
            _pool.token0().safeTransferFrom(msg.sender, address(this), amount0);
        }
        if (amount1 > 0) {
            _pool.token1().safeTransferFrom(msg.sender, address(this), amount1);
        }

        _deposit(_pool, amount0, amount1, mintAmount, _receiver);
    }

    
    // solhint-disable-next-line code-complexity, function-max-lines
    function addLiquidityETH(
        IGUniPool _pool,
        uint256 _amount0Max,
        uint256 _amount1Max,
        uint256 _amount0Min,
        uint256 _amount1Min,
        address _receiver
    )
        external
        payable
        override
        returns (
            uint256 amount0,
            uint256 amount1,
            uint256 mintAmount
        )
    {
        (amount0, amount1, mintAmount) = _pool.getMintAmounts(
            _amount0Max,
            _amount1Max
        );
        require(
            amount0 >= _amount0Min && amount1 >= _amount1Min,
            "below min amounts"
        );

        if (isToken0Weth(address(_pool.token0()), address(_pool.token1()))) {
            require(
                _amount0Max == msg.value,
                "mismatching amount of ETH forwarded"
            );
            if (amount0 > 0) {
                weth.deposit{value: amount0}();
            }
            if (amount1 > 0) {
                _pool.token1().safeTransferFrom(
                    msg.sender,
                    address(this),
                    amount1
                );
            }
        } else {
            require(
                _amount1Max == msg.value,
                "mismatching amount of ETH forwarded"
            );
            if (amount1 > 0) {
                weth.deposit{value: amount1}();
            }
            if (amount0 > 0) {
                _pool.token0().safeTransferFrom(
                    msg.sender,
                    address(this),
                    amount0
                );
            }
        }

        _deposit(_pool, amount0, amount1, mintAmount, _receiver);

        if (address(this).balance > 0) {
            payable(msg.sender).sendValue(address(this).balance);
        }
    }

    
    /// but we rebalance msg.sender's holdings (perform a swap) before adding liquidity.
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /// will revert on "overshot" swap (receive more outToken from swap than can be deposited)
    /// swapping for erroneous tokens will not necessarily revert in all cases
    /// and could result in loss of funds so be careful with swapActions and swapDatas params.
    // solhint-disable-next-line function-max-lines
    function rebalanceAndAddLiquidity(
        IGUniPool _pool,
        uint256 _amount0In,
        uint256 _amount1In,
        uint256 _amountSwap,
        bool _zeroForOne,
        address[] memory _swapActions,
        bytes[] memory _swapDatas,
        uint256 _amount0Min,
        uint256 _amount1Min,
        address _receiver
    )
        external
        override
        returns (
            uint256 amount0,
            uint256 amount1,
            uint256 mintAmount
        )
    {
        (amount0, amount1, mintAmount) = _prepareRebalanceDeposit(
            _pool,
            _amount0In,
            _amount1In,
            _amountSwap,
            _zeroForOne,
            _swapActions,
            _swapDatas
        );
        require(
            amount0 >= _amount0Min && amount1 >= _amount1Min,
            "below min amounts"
        );

        _deposit(_pool, amount0, amount1, mintAmount, _receiver);
    }

    
    /// except this function expects ETH transfer (instead of WETH)
    
    /// swaps which try to execute token -> ETH instead of WETH will revert
    // solhint-disable-next-line function-max-lines, code-complexity
    function rebalanceAndAddLiquidityETH(
        IGUniPool _pool,
        uint256 _amount0In,
        uint256 _amount1In,
        uint256 _amountSwap,
        bool _zeroForOne,
        address[] memory _swapActions,
        bytes[] memory _swapDatas,
        uint256 _amount0Min,
        uint256 _amount1Min,
        address _receiver
    )
        external
        payable
        override
        returns (
            uint256 amount0,
            uint256 amount1,
            uint256 mintAmount
        )
    {
        (amount0, amount1, mintAmount) = _prepareRebalanceDepositETH(
            _pool,
            _amount0In,
            _amount1In,
            _amountSwap,
            _zeroForOne,
            _swapActions,
            _swapDatas
        );
        require(
            amount0 >= _amount0Min && amount1 >= _amount1Min,
            "below min amounts"
        );

        _deposit(_pool, amount0, amount1, mintAmount, _receiver);

        if (address(this).balance > 0) {
            payable(msg.sender).sendValue(address(this).balance);
        }
    }

    
    
    
    
    
    
    
    
    
    function removeLiquidity(
        IGUniPool _pool,
        uint256 _burnAmount,
        uint256 _amount0Min,
        uint256 _amount1Min,
        address _receiver
    )
        external
        override
        returns (
            uint256 amount0,
            uint256 amount1,
            uint128 liquidityBurned
        )
    {
        IERC20(address(_pool)).safeTransferFrom(
            msg.sender,
            address(this),
            _burnAmount
        );
        (amount0, amount1, liquidityBurned) = _pool.burn(
            _burnAmount,
            _receiver
        );
        require(
            amount0 >= _amount0Min && amount1 >= _amount1Min,
            "received below minimum"
        );
    }

    
    /// except this function unwraps WETH and sends ETH to receiver account
    // solhint-disable-next-line code-complexity, function-max-lines
    function removeLiquidityETH(
        IGUniPool _pool,
        uint256 _burnAmount,
        uint256 _amount0Min,
        uint256 _amount1Min,
        address payable _receiver
    )
        external
        override
        returns (
            uint256 amount0,
            uint256 amount1,
            uint128 liquidityBurned
        )
    {
        bool wethToken0 =
            isToken0Weth(address(_pool.token0()), address(_pool.token1()));

        IERC20(address(_pool)).safeTransferFrom(
            msg.sender,
            address(this),
            _burnAmount
        );
        (amount0, amount1, liquidityBurned) = _pool.burn(
            _burnAmount,
            address(this)
        );
        require(
            amount0 >= _amount0Min && amount1 >= _amount1Min,
            "received below minimum"
        );

        if (wethToken0) {
            if (amount0 > 0) {
                weth.withdraw(amount0);
                _receiver.sendValue(amount0);
            }
            if (amount1 > 0) {
                _pool.token1().safeTransfer(_receiver, amount1);
            }
        } else {
            if (amount1 > 0) {
                weth.withdraw(amount1);
                _receiver.sendValue(amount1);
            }
            if (amount0 > 0) {
                _pool.token0().safeTransfer(_receiver, amount0);
            }
        }
    }

    function _deposit(
        IGUniPool _pool,
        uint256 _amount0,
        uint256 _amount1,
        uint256 _mintAmount,
        address _receiver
    ) internal {
        if (_amount0 > 0) {
            _pool.token0().safeIncreaseAllowance(address(_pool), _amount0);
        }
        if (_amount1 > 0) {
            _pool.token1().safeIncreaseAllowance(address(_pool), _amount1);
        }

        (uint256 amount0Check, uint256 amount1Check, ) =
            _pool.mint(_mintAmount, _receiver);
        require(
            _amount0 == amount0Check && _amount1 == amount1Check,
            "unexpected amounts deposited"
        );
    }

    // solhint-disable-next-line function-max-lines
    function _prepareRebalanceDeposit(
        IGUniPool _pool,
        uint256 _amount0In,
        uint256 _amount1In,
        uint256 _amountSwap,
        bool _zeroForOne,
        address[] memory _swapActions,
        bytes[] memory _swapDatas
    )
        internal
        returns (
            uint256 amount0Use,
            uint256 amount1Use,
            uint256 mintAmount
        )
    {
        if (_zeroForOne) {
            _pool.token0().safeTransferFrom(
                msg.sender,
                address(this),
                _amountSwap
            );
            _amount0In = _amount0In - _amountSwap;
        } else {
            _pool.token1().safeTransferFrom(
                msg.sender,
                address(this),
                _amountSwap
            );
            _amount1In = _amount1In - _amountSwap;
        }

        (uint256 balance0, uint256 balance1) =
            _swap(_pool, 0, _zeroForOne, _swapActions, _swapDatas);

        (amount0Use, amount1Use, mintAmount) = _postSwap(
            _pool,
            _amount0In,
            _amount1In,
            balance0,
            balance1
        );
    }

    // solhint-disable-next-line function-max-lines
    function _prepareRebalanceDepositETH(
        IGUniPool _pool,
        uint256 _amount0In,
        uint256 _amount1In,
        uint256 _amountSwap,
        bool _zeroForOne,
        address[] memory _swapActions,
        bytes[] memory _swapDatas
    )
        internal
        returns (
            uint256 amount0Use,
            uint256 amount1Use,
            uint256 mintAmount
        )
    {
        bool wethToken0 =
            isToken0Weth(address(_pool.token0()), address(_pool.token1()));

        if (_zeroForOne) {
            if (wethToken0) {
                require(
                    _amount0In == msg.value,
                    "mismatching amount of ETH forwarded"
                );
            } else {
                _pool.token0().safeTransferFrom(
                    msg.sender,
                    address(this),
                    _amountSwap
                );
            }
            _amount0In = _amount0In - _amountSwap;
        } else {
            if (wethToken0) {
                _pool.token1().safeTransferFrom(
                    msg.sender,
                    address(this),
                    _amountSwap
                );
            } else {
                require(
                    _amount1In == msg.value,
                    "mismatching amount of ETH forwarded"
                );
            }
            _amount1In = _amount1In - _amountSwap;
        }

        (uint256 balance0, uint256 balance1) =
            _swap(
                _pool,
                wethToken0 == _zeroForOne ? _amountSwap : 0,
                _zeroForOne,
                _swapActions,
                _swapDatas
            );

        (amount0Use, amount1Use, mintAmount) = _postSwapETH(
            _pool,
            _amount0In,
            _amount1In,
            balance0,
            balance1,
            wethToken0
        );
    }

    // solhint-disable-next-line code-complexity
    function _swap(
        IGUniPool _pool,
        uint256 _ethValue,
        bool _zeroForOne,
        address[] memory _swapActions,
        bytes[] memory _swapDatas
    ) internal returns (uint256 balance0, uint256 balance1) {
        require(
            _swapActions.length == _swapDatas.length,
            "swap actions length != swap datas length"
        );
        uint256 balanceBefore =
            _zeroForOne
                ? _pool.token1().balanceOf(address(this))
                : _pool.token0().balanceOf(address(this));

        if (_ethValue > 0 && _swapActions.length == 1) {
            (bool success, bytes memory returnsData) =
                _swapActions[0].call{value: _ethValue}(_swapDatas[0]);
            if (!success) GelatoBytes.revertWithError(returnsData, "swap: ");
        } else {
            for (uint256 i; i < _swapActions.length; i++) {
                (bool success, bytes memory returnsData) =
                    _swapActions[i].call(_swapDatas[i]);
                if (!success)
                    GelatoBytes.revertWithError(returnsData, "swap: ");
            }
        }
        balance0 = _pool.token0().balanceOf(address(this));
        balance1 = _pool.token1().balanceOf(address(this));
        if (_zeroForOne) {
            require(balance1 > balanceBefore, "swap for incorrect token");
        } else {
            require(balance0 > balanceBefore, "swap for incorrect token");
        }
    }

    // solhint-disable-next-line function-max-lines
    function _postSwap(
        IGUniPool _pool,
        uint256 _amount0In,
        uint256 _amount1In,
        uint256 _balance0,
        uint256 _balance1
    )
        internal
        returns (
            uint256 amount0Use,
            uint256 amount1Use,
            uint256 mintAmount
        )
    {
        (amount0Use, amount1Use, mintAmount) = _pool.getMintAmounts(
            _amount0In + _balance0,
            _amount1In + _balance1
        );

        if (_balance0 > amount0Use) {
            _pool.token0().safeTransfer(msg.sender, _balance0 - amount0Use);
        } else if (_balance0 < amount0Use) {
            _pool.token0().safeTransferFrom(
                msg.sender,
                address(this),
                amount0Use - _balance0
            );
        }

        if (_balance1 > amount1Use) {
            _pool.token1().safeTransfer(msg.sender, _balance1 - amount1Use);
        } else if (_balance1 < amount1Use) {
            _pool.token1().safeTransferFrom(
                msg.sender,
                address(this),
                amount1Use - _balance1
            );
        }
    }

    // solhint-disable-next-line code-complexity, function-max-lines
    function _postSwapETH(
        IGUniPool _pool,
        uint256 _amount0In,
        uint256 _amount1In,
        uint256 _balance0,
        uint256 _balance1,
        bool _wethToken0
    )
        internal
        returns (
            uint256 amount0Use,
            uint256 amount1Use,
            uint256 mintAmount
        )
    {
        (amount0Use, amount1Use, mintAmount) = _pool.getMintAmounts(
            _amount0In + _balance0,
            _amount1In + _balance1
        );

        if (amount0Use > _balance0) {
            if (_wethToken0) {
                weth.deposit{value: amount0Use - _balance0}();
            } else {
                _pool.token0().safeTransferFrom(
                    msg.sender,
                    address(this),
                    amount0Use - _balance0
                );
            }
        } else if (_balance0 > amount0Use) {
            if (_wethToken0) {
                weth.withdraw(_balance0 - amount0Use);
            } else {
                _pool.token0().safeTransfer(msg.sender, _balance0 - amount0Use);
            }
        }
        if (amount1Use > _balance1) {
            if (_wethToken0) {
                _pool.token1().safeTransferFrom(
                    msg.sender,
                    address(this),
                    amount1Use - _balance1
                );
            } else {
                weth.deposit{value: amount1Use - _balance1}();
            }
        } else if (_balance1 > amount1Use) {
            if (_wethToken0) {
                _pool.token1().safeTransfer(msg.sender, _balance1 - amount1Use);
            } else {
                weth.withdraw(_balance1 - amount1Use);
            }
        }
    }

    function isToken0Weth(address _token0, address _token1)
        public
        view
        returns (bool wethToken0)
    {
        if (_token0 == address(weth)) {
            wethToken0 = true;
        } else if (_token1 == address(weth)) {
            wethToken0 = false;
        } else {
            revert("one pool token must be WETH");
        }
    }

    receive() external payable {
        require(
            msg.sender == address(weth),
            "only receive ETH from WETH address"
        );
    }
}

// 
pragma solidity 0.8.4;





interface IGUniPool {
    function token0() external view returns (IERC20);

    function token1() external view returns (IERC20);

    function upperTick() external view returns (int24);

    function lowerTick() external view returns (int24);

    function pool() external view returns (IUniswapV3Pool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function mint(uint256 mintAmount, address receiver)
        external
        returns (
            uint256 amount0,
            uint256 amount1,
            uint128 liquidityMinted
        );

    function burn(uint256 burnAmount, address receiver)
        external
        returns (
            uint256 amount0,
            uint256 amount1,
            uint128 liquidityBurned
        );

    function getMintAmounts(uint256 amount0Max, uint256 amount1Max)
        external
        view
        returns (
            uint256 amount0,
            uint256 amount1,
            uint256 mintAmount
        );

    function getUnderlyingBalances()
        external
        view
        returns (uint256 amount0, uint256 amount1);

    function getPositionID() external view returns (bytes32 positionID);
}

// 
pragma solidity 0.8.4;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

// "
pragma solidity 0.8.4;

library GelatoBytes {
    function calldataSliceSelector(bytes calldata _bytes)
        internal
        pure
        returns (bytes4 selector)
    {
        selector =
            _bytes[0] |
            (bytes4(_bytes[1]) >> 8) |
            (bytes4(_bytes[2]) >> 16) |
            (bytes4(_bytes[3]) >> 24);
    }

    function memorySliceSelector(bytes memory _bytes)
        internal
        pure
        returns (bytes4 selector)
    {
        selector =
            _bytes[0] |
            (bytes4(_bytes[1]) >> 8) |
            (bytes4(_bytes[2]) >> 16) |
            (bytes4(_bytes[3]) >> 24);
    }

    function revertWithError(bytes memory _bytes, string memory _tracingInfo)
        internal
        pure
    {
        // 68: 32-location, 32-length, 4-ErrorSelector, UTF-8 err
        if (_bytes.length % 32 == 4) {
            bytes4 selector;
            assembly {
                selector := mload(add(0x20, _bytes))
            }
            if (selector == 0x08c379a0) {
                // Function selector for Error(string)
                assembly {
                    _bytes := add(_bytes, 68)
                }
                revert(string(abi.encodePacked(_tracingInfo, string(_bytes))));
            } else {
                revert(
                    string(abi.encodePacked(_tracingInfo, "NoErrorSelector"))
                );
            }
        } else {
            revert(
                string(abi.encodePacked(_tracingInfo, "UnexpectedReturndata"))
            );
        }
    }

    function returnError(bytes memory _bytes, string memory _tracingInfo)
        internal
        pure
        returns (string memory)
    {
        // 68: 32-location, 32-length, 4-ErrorSelector, UTF-8 err
        if (_bytes.length % 32 == 4) {
            bytes4 selector;
            assembly {
                selector := mload(add(0x20, _bytes))
            }
            if (selector == 0x08c379a0) {
                // Function selector for Error(string)
                assembly {
                    _bytes := add(_bytes, 68)
                }
                return string(abi.encodePacked(_tracingInfo, string(_bytes)));
            } else {
                return
                    string(abi.encodePacked(_tracingInfo, "NoErrorSelector"));
            }
        } else {
            return
                string(abi.encodePacked(_tracingInfo, "UnexpectedReturndata"));
        }
    }
}
