// SPDX-License-Identifier: MIT

// 

// solhint-disable-next-line compiler-version
pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// 
pragma solidity ^0.8.4;




abstract contract ModuleMapConsumer is Initializable {
  IModuleMap public moduleMap;

  function __ModuleMapConsumer_init(address moduleMap_) internal initializer {
    moduleMap = IModuleMap(moduleMap_);
  }
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
pragma solidity ^0.8.4;





abstract contract Controlled is Initializable, ModuleMapConsumer {
  // controller address => is a controller
  mapping(address => bool) internal _controllers;
  address[] public controllers;

  function __Controlled_init(address[] memory controllers_, address moduleMap_)
    public
    initializer
  {
    for (uint256 i; i < controllers_.length; i++) {
      _controllers[controllers_[i]] = true;
    }
    controllers = controllers_;
    __ModuleMapConsumer_init(moduleMap_);
  }

  function addController(address controller) external onlyOwner {
    _controllers[controller] = true;
    bool added;
    for (uint256 i; i < controllers.length; i++) {
      if (controller == controllers[i]) {
        added = true;
      }
    }
    if (!added) {
      controllers.push(controller);
    }
  }

  modifier onlyOwner() {
    require(
      IKernel(moduleMap.getModuleAddress(Modules.Kernel)).isOwner(msg.sender),
      "Controlled::onlyOwner: Caller is not owner"
    );
    _;
  }

  modifier onlyManager() {
    require(
      IKernel(moduleMap.getModuleAddress(Modules.Kernel)).isManager(msg.sender),
      "Controlled::onlyManager: Caller is not manager"
    );
    _;
  }

  modifier onlyController() {
    require(
      _controllers[msg.sender],
      "Controlled::onlyController: Caller is not controller"
    );
    _;
  }
}

// 
pragma solidity ^0.8.4;

interface IUniswapTrader {
  struct Path {
    address tokenOut;
    uint256 firstPoolFee;
    address tokenInTokenOut;
    uint256 secondPoolFee;
    address tokenIn;
  }

  
  
  
  
  /// to calculate the allowable slippage
  function addPool(
    address tokenA,
    address tokenB,
    uint24 fee,
    uint24 slippageNumerator
  ) external;

  
  
  
  
  function updatePoolSlippageNumerator(
    address tokenA,
    address tokenB,
    uint256 poolIndex,
    uint24 slippageNumerator
  ) external;

  
  
  
  
  
  function updatePairPrimaryPool(
    address tokenA,
    address tokenB,
    uint256 primaryPoolIndex
  ) external;

  
  
  
  
  
  function swapExactInput(
    address tokenIn,
    address tokenOut,
    address recipient,
    uint256 amountIn
  ) external returns (bool tradeSuccess);

  
  
  
  
  
  function swapExactOutput(
    address tokenIn,
    address tokenOut,
    address recipient,
    uint256 amountOut
  ) external returns (bool tradeSuccess);

  
  
  
  
  function getAmountInMaximum(
    address tokenIn,
    address tokenOut,
    uint256 amountOut
  ) external view returns (uint256 amountInMaximum);

  
  
  
  
  function getEstimatedTokenOut(
    address tokenIn,
    address tokenOut,
    uint256 amountIn
  ) external view returns (uint256 amountOut);

  function getPathFor(address tokenOut, address tokenIn)
    external
    view
    returns (Path memory);

  function setPathFor(
    address tokenOut,
    address tokenIn,
    uint256 firstPoolFee,
    address tokenInTokenOut,
    uint256 secondPoolFee
  ) external;

  
  
  
  
  function getTokensSorted(address tokenA, address tokenB)
    external
    pure
    returns (address token0, address token1);

  
  function getTokenPairsLength() external view returns (uint256);

  
  
  
  function getTokenPairPoolsLength(address tokenA, address tokenB)
    external
    view
    returns (uint256);

  
  
  
  
  function getPoolFeeNumerator(
    address tokenA,
    address tokenB,
    uint256 poolId
  ) external view returns (uint24 feeNumerator);

  function getPoolAddress(address tokenA, address tokenB)
    external
    view
    returns (address pool);
}

// 

pragma solidity ^0.8.0;



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
library AddressUpgradeable {
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
pragma solidity ^0.8.4;

















contract UniswapTrader is
  Initializable,
  ModuleMapConsumer,
  Controlled,
  IUniswapTrader
{
  using SafeERC20Upgradeable for IERC20MetadataUpgradeable;

  struct Pool {
    uint24 feeNumerator;
    uint24 slippageNumerator;
  }

  struct TokenPair {
    address token0;
    address token1;
  }

  uint24 private constant FEE_DENOMINATOR = 1_000_000;
  uint24 private constant SLIPPAGE_DENOMINATOR = 1_000_000;
  address private factoryAddress;
  address private swapRouterAddress;

  mapping(address => mapping(address => Pool[])) private pools;
  mapping(address => mapping(address => Path)) private paths;
  mapping(address => mapping(address => bool)) private isMultihopPair;

  TokenPair[] private tokenPairs;

  event UniswapPoolAdded(
    address indexed token0,
    address indexed token1,
    uint24 fee,
    uint24 slippageNumerator
  );
  event UniswapPoolSlippageNumeratorUpdated(
    address indexed token0,
    address indexed token1,
    uint256 poolIndex,
    uint24 slippageNumerator
  );
  event UniswapPairPrimaryPoolUpdated(
    address indexed token0,
    address indexed token1,
    uint256 primaryPoolIndex
  );

  
  
  
  
  function initialize(
    address[] memory controllers_,
    address moduleMap_,
    address factoryAddress_,
    address swapRouterAddress_
  ) public initializer {
    __Controlled_init(controllers_, moduleMap_);
    __ModuleMapConsumer_init(moduleMap_);
    factoryAddress = factoryAddress_;
    swapRouterAddress = swapRouterAddress_;
  }

  
  
  
  
  /// to calculate the allowable slippage
  /// positions is enabled for this pool
  function addPool(
    address tokenA,
    address tokenB,
    uint24 feeNumerator,
    uint24 slippageNumerator
  ) external override onlyManager {
    require(
      IIntegrationMap(moduleMap.getModuleAddress(Modules.IntegrationMap))
        .getIsTokenAdded(tokenA),
      "UniswapTrader::addPool: TokenA has not been added in the Integration Map"
    );
    require(
      IIntegrationMap(moduleMap.getModuleAddress(Modules.IntegrationMap))
        .getIsTokenAdded(tokenB),
      "UniswapTrader::addPool: TokenB has not been added in the Integration Map"
    );
    require(
      slippageNumerator <= SLIPPAGE_DENOMINATOR,
      "UniswapTrader::addPool: Slippage numerator cannot be greater than slippapge denominator"
    );
    require(
      IUniswapFactory(factoryAddress).getPool(tokenA, tokenB, feeNumerator) !=
        address(0),
      "UniswapTrader::addPool: Pool does not exist"
    );

    (address token0, address token1) = getTokensSorted(tokenA, tokenB);

    bool poolAdded;
    for (
      uint256 poolIndex;
      poolIndex < pools[token0][token1].length;
      poolIndex++
    ) {
      if (pools[token0][token1][poolIndex].feeNumerator == feeNumerator) {
        poolAdded = true;
      }
    }

    require(!poolAdded, "UniswapTrader::addPool: Pool has already been added");

    Pool memory newPool;
    newPool.feeNumerator = feeNumerator;
    newPool.slippageNumerator = slippageNumerator;
    pools[token0][token1].push(newPool);

    bool tokenPairAdded;
    for (uint256 pairIndex; pairIndex < tokenPairs.length; pairIndex++) {
      if (
        tokenPairs[pairIndex].token0 == token0 &&
        tokenPairs[pairIndex].token1 == token1
      ) {
        tokenPairAdded = true;
      }
    }

    if (!tokenPairAdded) {
      TokenPair memory newTokenPair;
      newTokenPair.token0 = token0;
      newTokenPair.token1 = token1;
      tokenPairs.push(newTokenPair);

      if (
        IERC20MetadataUpgradeable(token0).allowance(
          address(this),
          moduleMap.getModuleAddress(Modules.YieldManager)
        ) == 0
      ) {
        IERC20MetadataUpgradeable(token0).safeApprove(
          moduleMap.getModuleAddress(Modules.YieldManager),
          type(uint256).max
        );
      }

      if (
        IERC20MetadataUpgradeable(token1).allowance(
          address(this),
          moduleMap.getModuleAddress(Modules.YieldManager)
        ) == 0
      ) {
        IERC20MetadataUpgradeable(token1).safeApprove(
          moduleMap.getModuleAddress(Modules.YieldManager),
          type(uint256).max
        );
      }

      if (
        IERC20MetadataUpgradeable(token0).allowance(
          address(this),
          swapRouterAddress
        ) == 0
      ) {
        IERC20MetadataUpgradeable(token0).safeApprove(
          swapRouterAddress,
          type(uint256).max
        );
      }

      if (
        IERC20MetadataUpgradeable(token1).allowance(
          address(this),
          swapRouterAddress
        ) == 0
      ) {
        IERC20MetadataUpgradeable(token1).safeApprove(
          swapRouterAddress,
          type(uint256).max
        );
      }
    }

    emit UniswapPoolAdded(token0, token1, feeNumerator, slippageNumerator);
  }

  
  
  
  
  function updatePoolSlippageNumerator(
    address tokenA,
    address tokenB,
    uint256 poolIndex,
    uint24 slippageNumerator
  ) external override onlyManager {
    require(
      slippageNumerator <= SLIPPAGE_DENOMINATOR,
      "UniswapTrader:updatePoolSlippageNumerator: Slippage numerator must not be greater than slippage denominator"
    );
    (address token0, address token1) = getTokensSorted(tokenA, tokenB);
    require(
      pools[token0][token1][poolIndex].slippageNumerator != slippageNumerator,
      "UniswapTrader:updatePoolSlippageNumerator: Slippage numerator must be updated to a new number"
    );
    require(
      pools[token0][token1].length > poolIndex,
      "UniswapTrader:updatePoolSlippageNumerator: Pool does not exist"
    );

    pools[token0][token1][poolIndex].slippageNumerator = slippageNumerator;

    emit UniswapPoolSlippageNumeratorUpdated(
      token0,
      token1,
      poolIndex,
      slippageNumerator
    );
  }

  
  
  
  
  
  function updatePairPrimaryPool(
    address tokenA,
    address tokenB,
    uint256 primaryPoolIndex
  ) external override onlyManager {
    require(
      primaryPoolIndex != 0,
      "UniswapTrader::updatePairPrimaryPool: Specified index is already the primary pool"
    );
    (address token0, address token1) = getTokensSorted(tokenA, tokenB);
    require(
      primaryPoolIndex < pools[token0][token1].length,
      "UniswapTrader::updatePairPrimaryPool: Specified pool index does not exist"
    );

    uint24 newPrimaryPoolFeeNumerator = pools[token0][token1][primaryPoolIndex]
      .feeNumerator;
    uint24 newPrimaryPoolSlippageNumerator = pools[token0][token1][
      primaryPoolIndex
    ].slippageNumerator;

    pools[token0][token1][primaryPoolIndex].feeNumerator = pools[token0][
      token1
    ][0].feeNumerator;
    pools[token0][token1][primaryPoolIndex].slippageNumerator = pools[token0][
      token1
    ][0].slippageNumerator;

    pools[token0][token1][0].feeNumerator = newPrimaryPoolFeeNumerator;
    pools[token0][token1][0]
      .slippageNumerator = newPrimaryPoolSlippageNumerator;

    emit UniswapPairPrimaryPoolUpdated(token0, token1, primaryPoolIndex);
  }

  
  
  
  
  
  function swapExactInput(
    address tokenIn,
    address tokenOut,
    address recipient,
    uint256 amountIn
  ) external override onlyController returns (bool tradeSuccess) {
    IERC20MetadataUpgradeable tokenInErc20 = IERC20MetadataUpgradeable(tokenIn);

    if (isMultihopPair[tokenIn][tokenOut]) {
      Path memory path = getPathFor(tokenIn, tokenOut);
      IUniswapSwapRouter.ExactInputParams memory params = IUniswapSwapRouter
        .ExactInputParams({
          path: abi.encodePacked(
            path.tokenIn,
            path.firstPoolFee,
            path.tokenInTokenOut,
            path.secondPoolFee,
            path.tokenOut
          ),
          recipient: recipient,
          deadline: block.timestamp,
          amountIn: amountIn,
          amountOutMinimum: 0
        });

      // Executes the swap.
      try IUniswapSwapRouter(swapRouterAddress).exactInput(params) {
        tradeSuccess = true;
      } catch {
        tradeSuccess = false;
        tokenInErc20.safeTransfer(
          recipient,
          tokenInErc20.balanceOf(address(this))
        );
      }

      return tradeSuccess;
    }

    (address token0, address token1) = getTokensSorted(tokenIn, tokenOut);

    require(
      pools[token0][token1].length > 0,
      "UniswapTrader::swapExactInput: Pool has not been added"
    );
    require(
      tokenInErc20.balanceOf(address(this)) >= amountIn,
      "UniswapTrader::swapExactInput: Balance is less than trade amount"
    );

    uint256 amountOutMinimum = getAmountOutMinimum(tokenIn, tokenOut, amountIn);

    IUniswapSwapRouter.ExactInputSingleParams memory exactInputSingleParams;
    exactInputSingleParams.tokenIn = tokenIn;
    exactInputSingleParams.tokenOut = tokenOut;
    exactInputSingleParams.fee = pools[token0][token1][0].feeNumerator;
    exactInputSingleParams.recipient = recipient;
    exactInputSingleParams.deadline = block.timestamp;
    exactInputSingleParams.amountIn = amountIn;
    exactInputSingleParams.amountOutMinimum = amountOutMinimum;
    exactInputSingleParams.sqrtPriceLimitX96 = 0;

    try
      IUniswapSwapRouter(swapRouterAddress).exactInputSingle(
        exactInputSingleParams
      )
    {
      tradeSuccess = true;
    } catch {
      tradeSuccess = false;
      tokenInErc20.safeTransfer(
        recipient,
        tokenInErc20.balanceOf(address(this))
      );
    }
  }

  
  
  
  
  
  function swapExactOutput(
    address tokenIn,
    address tokenOut,
    address recipient,
    uint256 amountOut
  ) external override onlyController returns (bool tradeSuccess) {
    IERC20MetadataUpgradeable tokenInErc20 = IERC20MetadataUpgradeable(tokenIn);

    if (isMultihopPair[tokenIn][tokenOut]) {
      Path memory path = getPathFor(tokenIn, tokenOut);
      IUniswapSwapRouter.ExactOutputParams memory params = IUniswapSwapRouter
        .ExactOutputParams({
          path: abi.encodePacked(
            path.tokenIn,
            path.firstPoolFee,
            path.tokenInTokenOut,
            path.secondPoolFee,
            path.tokenOut
          ),
          recipient: recipient,
          deadline: block.timestamp,
          amountOut: amountOut,
          amountInMaximum: 0
        });

      // Executes the swap.
      try IUniswapSwapRouter(swapRouterAddress).exactOutput(params) {
        tradeSuccess = true;
      } catch {
        tradeSuccess = false;
        tokenInErc20.safeTransfer(
          recipient,
          tokenInErc20.balanceOf(address(this))
        );
      }

      return tradeSuccess;
    }
    (address token0, address token1) = getTokensSorted(tokenIn, tokenOut);
    require(
      pools[token0][token1][0].feeNumerator > 0,
      "UniswapTrader::swapExactOutput: Pool has not been added"
    );
    uint256 amountInMaximum = getAmountInMaximum(tokenIn, tokenOut, amountOut);
    require(
      tokenInErc20.balanceOf(address(this)) >= amountInMaximum,
      "UniswapTrader::swapExactOutput: Balance is less than trade amount"
    );

    IUniswapSwapRouter.ExactOutputSingleParams memory exactOutputSingleParams;
    exactOutputSingleParams.tokenIn = tokenIn;
    exactOutputSingleParams.tokenOut = tokenOut;
    exactOutputSingleParams.fee = pools[token0][token1][0].feeNumerator;
    exactOutputSingleParams.recipient = recipient;
    exactOutputSingleParams.deadline = block.timestamp;
    exactOutputSingleParams.amountOut = amountOut;
    exactOutputSingleParams.amountInMaximum = amountInMaximum;
    exactOutputSingleParams.sqrtPriceLimitX96 = 0;

    try
      IUniswapSwapRouter(swapRouterAddress).exactOutputSingle(
        exactOutputSingleParams
      )
    {
      tradeSuccess = true;
    } catch {
      tradeSuccess = false;
      tokenInErc20.safeTransfer(
        recipient,
        tokenInErc20.balanceOf(address(this))
      );
    }
  }

  
  
  
  function getPoolAddress(address tokenA, address tokenB)
    public
    view
    override
    returns (address pool)
  {
    uint24 feeNumerator = getPoolFeeNumerator(tokenA, tokenB, 0);
    pool = IUniswapFactory(factoryAddress).getPool(
      tokenA,
      tokenB,
      feeNumerator
    );
  }

  
  function getSqrtPriceX96(address tokenA, address tokenB)
    public
    view
    returns (uint256)
  {
    (uint160 sqrtPriceX96, , , , , , ) = IUniswapPool(
      getPoolAddress(tokenA, tokenB)
    ).slot0();
    return uint256(sqrtPriceX96);
  }

  function getPathFor(address tokenIn, address tokenOut)
    public
    view
    override
    returns (Path memory)
  {
    require(
      isMultihopPair[tokenIn][tokenOut],
      "There is an existing Pool for this pair"
    );

    return paths[tokenIn][tokenOut];
  }

  function setPathFor(
    address tokenIn,
    address tokenOut,
    uint256 firstPoolFee,
    address tokenInTokenOut,
    uint256 secondPoolFee
  ) public override onlyManager {
    paths[tokenIn][tokenOut] = Path(
      tokenIn,
      firstPoolFee,
      tokenInTokenOut,
      secondPoolFee,
      tokenOut
    );
    isMultihopPair[tokenIn][tokenOut] = true;
  }

  
  
  
  
  function getAmountOutMinimum(
    address tokenIn,
    address tokenOut,
    uint256 amountIn
  ) public view returns (uint256 amountOutMinimum) {
    uint256 estimatedAmountOut = getEstimatedTokenOut(
      tokenIn,
      tokenOut,
      amountIn
    );
    uint24 poolSlippageNumerator = getPoolSlippageNumerator(
      tokenIn,
      tokenOut,
      0
    );
    amountOutMinimum =
      (estimatedAmountOut * (SLIPPAGE_DENOMINATOR - poolSlippageNumerator)) /
      SLIPPAGE_DENOMINATOR;
  }

  
  
  
  
  function getAmountInMaximum(
    address tokenIn,
    address tokenOut,
    uint256 amountOut
  ) public view override returns (uint256 amountInMaximum) {
    uint256 estimatedAmountIn = getEstimatedTokenIn(
      tokenIn,
      tokenOut,
      amountOut
    );
    uint24 poolSlippageNumerator = getPoolSlippageNumerator(
      tokenIn,
      tokenOut,
      0
    );
    amountInMaximum =
      (estimatedAmountIn * (SLIPPAGE_DENOMINATOR + poolSlippageNumerator)) /
      SLIPPAGE_DENOMINATOR;
  }

  
  
  
  
  function getEstimatedTokenOut(
    address tokenIn,
    address tokenOut,
    uint256 amountIn
  ) public view override returns (uint256 amountOut) {
    if (isMultihopPair[tokenIn][tokenOut]) {
      Path memory path = getPathFor(tokenIn, tokenOut);
      uint256 amountOutTemp = getEstimatedTokenOut(
        path.tokenIn,
        path.tokenInTokenOut,
        amountIn
      );
      return
        getEstimatedTokenOut(
          path.tokenInTokenOut,
          path.tokenOut,
          amountOutTemp
        );
    }

    uint24 feeNumerator = getPoolFeeNumerator(tokenIn, tokenOut, 0);
    uint256 sqrtPriceX96 = getSqrtPriceX96(tokenIn, tokenOut);

    // FullMath is used to allow intermediate calculation values of up to 2^512
    if (tokenIn < tokenOut) {
      amountOut =
        (FullMath.mulDiv(
          FullMath.mulDiv(amountIn, sqrtPriceX96, 2**96),
          sqrtPriceX96,
          2**96
        ) * (FEE_DENOMINATOR - feeNumerator)) /
        FEE_DENOMINATOR;
    } else {
      amountOut =
        (FullMath.mulDiv(
          FullMath.mulDiv(amountIn, 2**96, sqrtPriceX96),
          2**96,
          sqrtPriceX96
        ) * (FEE_DENOMINATOR - feeNumerator)) /
        FEE_DENOMINATOR;
    }
  }

  
  
  
  
  function getEstimatedTokenIn(
    address tokenIn,
    address tokenOut,
    uint256 amountOut
  ) public view returns (uint256 amountIn) {
    if (isMultihopPair[tokenIn][tokenOut]) {
      Path memory path = getPathFor(tokenIn, tokenOut);
      uint256 amountInTemp = getEstimatedTokenIn(
        path.tokenInTokenOut,
        path.tokenOut,
        amountOut
      );
      return
        getEstimatedTokenIn(path.tokenIn, path.tokenInTokenOut, amountInTemp);
    }

    uint24 feeNumerator = getPoolFeeNumerator(tokenIn, tokenOut, 0);
    uint256 sqrtPriceX96 = getSqrtPriceX96(tokenIn, tokenOut);

    // FullMath is used to allow intermediate calculation values of up to 2^512
    if (tokenIn < tokenOut) {
      amountIn =
        (FullMath.mulDiv(
          FullMath.mulDiv(amountOut, 2**96, sqrtPriceX96),
          2**96,
          sqrtPriceX96
        ) * (FEE_DENOMINATOR - feeNumerator)) /
        FEE_DENOMINATOR;
    } else {
      amountIn =
        (FullMath.mulDiv(
          FullMath.mulDiv(amountOut, sqrtPriceX96, 2**96),
          sqrtPriceX96,
          2**96
        ) * (FEE_DENOMINATOR - feeNumerator)) /
        FEE_DENOMINATOR;
    }
  }

  
  
  
  
  function getPoolFeeNumerator(
    address tokenA,
    address tokenB,
    uint256 poolId
  ) public view override returns (uint24 feeNumerator) {
    (address token0, address token1) = getTokensSorted(tokenA, tokenB);
    require(
      poolId < pools[token0][token1].length,
      "UniswapTrader::getPoolFeeNumerator: Pool ID does not exist"
    );
    feeNumerator = pools[token0][token1][poolId].feeNumerator;
  }

  
  
  
  
  function getPoolSlippageNumerator(
    address tokenA,
    address tokenB,
    uint256 poolId
  ) public view returns (uint24 slippageNumerator) {
    (address token0, address token1) = getTokensSorted(tokenA, tokenB);
    return pools[token0][token1][poolId].slippageNumerator;
  }

  
  
  
  
  function getTokensSorted(address tokenA, address tokenB)
    public
    pure
    override
    returns (address token0, address token1)
  {
    if (tokenA < tokenB) {
      token0 = tokenA;
      token1 = tokenB;
    } else {
      token0 = tokenB;
      token1 = tokenA;
    }
  }

  
  
  
  
  
  
  
  
  function getTokensAndAmountsSorted(
    address tokenA,
    address tokenB,
    uint256 amountA,
    uint256 amountB
  )
    public
    pure
    returns (
      address token0,
      address token1,
      uint256 amount0,
      uint256 amount1
    )
  {
    if (tokenA < tokenB) {
      token0 = tokenA;
      token1 = tokenB;
      amount0 = amountA;
      amount1 = amountB;
    } else {
      token0 = tokenB;
      token1 = tokenA;
      amount0 = amountB;
      amount1 = amountA;
    }
  }

  
  function getFeeDenominator() external pure returns (uint24) {
    return FEE_DENOMINATOR;
  }

  
  function getSlippageDenominator() external pure returns (uint24) {
    return SLIPPAGE_DENOMINATOR;
  }

  
  function getTokenPairsLength() external view override returns (uint256) {
    return tokenPairs.length;
  }

  
  
  
  function getTokenPairPoolsLength(address tokenA, address tokenB)
    external
    view
    override
    returns (uint256)
  {
    (address token0, address token1) = getTokensSorted(tokenA, tokenB);
    return pools[token0][token1].length;
  }

  
  
  
  function getTokenPair(uint256 tokenPairIndex)
    external
    view
    returns (address, address)
  {
    require(
      tokenPairIndex < tokenPairs.length,
      "UniswapTrader::getTokenPair: Token pair does not exist"
    );
    return (
      tokenPairs[tokenPairIndex].token0,
      tokenPairs[tokenPairIndex].token1
    );
  }

  
  
  
  
  
  function getPool(
    address token0,
    address token1,
    uint256 poolIndex
  ) external view returns (uint24, uint24) {
    require(
      poolIndex < pools[token0][token1].length,
      "UniswapTrader:getPool: Pool does not exist"
    );
    return (
      pools[token0][token1][poolIndex].feeNumerator,
      pools[token0][token1][poolIndex].slippageNumerator
    );
  }
}

// 
pragma solidity ^0.8.4;

interface IIntegrationMap {
  struct Integration {
    bool added;
    string name;
  }

  struct Token {
    uint256 id;
    bool added;
    bool acceptingDeposits;
    bool acceptingWithdrawals;
    uint256 biosRewardWeight;
    uint256 reserveRatioNumerator;
  }

  
  
  function addIntegration(address contractAddress, string memory name) external;

  
  
  
  
  
  function addToken(
    address tokenAddress,
    bool acceptingDeposits,
    bool acceptingWithdrawals,
    uint256 biosRewardWeight,
    uint256 reserveRatioNumerator
  ) external;

  
  function enableTokenDeposits(address tokenAddress) external;

  
  function disableTokenDeposits(address tokenAddress) external;

  
  function enableTokenWithdrawals(address tokenAddress) external;

  
  function disableTokenWithdrawals(address tokenAddress) external;

  
  
  function updateTokenRewardWeight(address tokenAddress, uint256 rewardWeight)
    external;

  
  
  function updateTokenReserveRatioNumerator(
    address tokenAddress,
    uint256 reserveRatioNumerator
  ) external;

  
  
  function getIntegrationAddress(uint256 integrationId)
    external
    view
    returns (address);

  
  
  function getIntegrationName(address integrationAddress)
    external
    view
    returns (string memory);

  
  function getWethTokenAddress() external view returns (address);

  
  function getBiosTokenAddress() external view returns (address);

  
  
  function getTokenAddress(uint256 tokenId) external view returns (address);

  
  
  function getTokenId(address tokenAddress) external view returns (uint256);

  
  
  function getTokenBiosRewardWeight(address tokenAddress)
    external
    view
    returns (uint256);

  
  function getBiosRewardWeightSum()
    external
    view
    returns (uint256 rewardWeightSum);

  
  
  function getTokenAcceptingDeposits(address tokenAddress)
    external
    view
    returns (bool);

  
  
  function getTokenAcceptingWithdrawals(address tokenAddress)
    external
    view
    returns (bool);

  // @param tokenAddress The address of the token ERC20 contract
  // @return bool indicating whether the token has been added
  function getIsTokenAdded(address tokenAddress) external view returns (bool);

  // @param integrationAddress The address of the integration contract
  // @return bool indicating whether the integration has been added
  function getIsIntegrationAdded(address tokenAddress)
    external
    view
    returns (bool);

  
  
  function getTokenAddressesLength() external view returns (uint256);

  
  
  function getIntegrationAddressesLength() external view returns (uint256);

  
  
  function getTokenReserveRatioNumerator(address tokenAddress)
    external
    view
    returns (uint256);

  
  function getReserveRatioDenominator() external view returns (uint32);
}

// 
pragma solidity ^0.8.4;

interface IKernel {
  
  
  function isManager(address account) external view returns (bool);

  
  
  function isOwner(address account) external view returns (bool);
}

// 
pragma solidity ^0.8.4;

enum Modules {
  Kernel, // 0
  UserPositions, // 1
  YieldManager, // 2
  IntegrationMap, // 3
  BiosRewards, // 4
  EtherRewards, // 5
  SushiSwapTrader, // 6
  UniswapTrader, // 7
  StrategyMap, // 8
  StrategyManager // 9
}

interface IModuleMap {
  function getModuleAddress(Modules key) external view returns (address);
}

// 
pragma solidity ^0.8.4;

interface IUniswapFactory {
  
  
  
  
  function getPool(
    address tokenA,
    address tokenB,
    uint24 fee
  ) external view returns (address pool);
}

// 
pragma solidity ^0.8.4;

interface IUniswapPool {
  
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
}

// 
pragma solidity ^0.8.4;

interface IUniswapPositionManager {
  struct MintParams {
    address token0;
    address token1;
    uint24 fee;
    int24 tickLower;
    int24 tickUpper;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    address recipient;
    uint256 deadline;
  }

  struct IncreaseLiquidityParams {
    uint256 tokenId;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
  }

  struct DecreaseLiquidityParams {
    uint256 tokenId;
    uint128 liquidity;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
  }

  struct CollectParams {
    uint256 tokenId;
    address recipient;
    uint128 amount0Max;
    uint128 amount1Max;
  }

  
  
  /// a method does not exist, i.e. the pool is assumed to be initialized.
  
  
  
  
  
  function mint(MintParams calldata params)
    external
    payable
    returns (
      uint256 tokenId,
      uint128 liquidity,
      uint256 amount0,
      uint256 amount1
    );

  
  
  /// amount0Desired The desired amount of token0 to be spent,
  /// amount1Desired The desired amount of token1 to be spent,
  /// amount0Min The minimum amount of token0 to spend, which serves as a slippage check,
  /// amount1Min The minimum amount of token1 to spend, which serves as a slippage check,
  /// deadline The time by which the transaction must be included to effect the change
  
  
  
  function increaseLiquidity(IncreaseLiquidityParams calldata params)
    external
    payable
    returns (
      uint128 liquidity,
      uint256 amount0,
      uint256 amount1
    );

  
  
  /// amount The amount by which liquidity will be decreased,
  /// amount0Min The minimum amount of token0 that should be accounted for the burned liquidity,
  /// amount1Min The minimum amount of token1 that should be accounted for the burned liquidity,
  /// deadline The time by which the transaction must be included to effect the change
  
  
  function decreaseLiquidity(DecreaseLiquidityParams calldata params)
    external
    payable
    returns (uint256 amount0, uint256 amount1);

  
  
  /// recipient The account that should receive the tokens,
  /// amount0Max The maximum amount of token0 to collect,
  /// amount1Max The maximum amount of token1 to collect
  
  
  function collect(CollectParams calldata params)
    external
    payable
    returns (uint256 amount0, uint256 amount1);

  
  /// must be collected first.
  
  function burn(uint256 tokenId) external payable;

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  function positions(uint256 tokenId)
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
}

// 
pragma solidity ^0.8.4;

interface IUniswapSwapRouter {
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

  struct ExactInputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
  }

  struct ExactOutputParams {
    bytes path;
    address recipient;
    uint256 deadline;
    uint256 amountOut;
    uint256 amountInMaximum;
  }

  
  
  
  function exactInputSingle(ExactInputSingleParams calldata params)
    external
    payable
    returns (uint256 amountOut);

  
  
  
  function exactOutputSingle(ExactOutputSingleParams calldata params)
    external
    payable
    returns (uint256 amountIn);

  function exactInput(ExactInputParams calldata params)
    external
    returns (uint256 amountOut);

  function exactOutput(ExactOutputParams calldata params)
    external
    returns (uint256 amountIn);
}

// 
pragma solidity >=0.7.6;




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
        uint256 twos = denominator & (~denominator + 1);
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