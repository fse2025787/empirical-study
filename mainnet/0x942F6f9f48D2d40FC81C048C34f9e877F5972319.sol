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

interface IYieldManager {
  
  function updateGasAccountTargetEthBalance(uint256 gasAccountTargetEthBalance_)
    external;

  
  
  
  
  function updateEthDistributionWeights(
    uint32 biosBuyBackEthWeight_,
    uint32 treasuryEthWeight_,
    uint32 protocolFeeEthWeight_,
    uint32 rewardsEthWeight_
  ) external;

  
  function updateGasAccount(address payable gasAccount_) external;

  
  function updateTreasuryAccount(address payable treasuryAccount_) external;

  
  function rebalance() external;

  
  function deploy() external;

  
  function harvestYield() external;

  
  function processYield() external;

  
  function distributeEth() external;

  
  function biosBuyBack() external;

  
  
  function getHarvestedTokenBalance(address tokenAddress)
    external
    view
    returns (uint256);

  
  
  function getReserveTokenBalance(address tokenAddress)
    external
    view
    returns (uint256);

  
  
  function getDesiredReserveTokenBalance(address tokenAddress)
    external
    view
    returns (uint256);

  
  function getEthWeightSum() external view returns (uint32 ethWeightSum);

  
  function getProcessedWethSum()
    external
    view
    returns (uint256 processedWethSum);

  
  
  function getProcessedWethByToken(address tokenAddress)
    external
    view
    returns (uint256);

  
  function getProcessedWethByTokenSum()
    external
    view
    returns (uint256 processedWethByTokenSum);

  
  
  function getTokenTotalIntegrationBalance(address tokenAddress)
    external
    view
    returns (uint256 tokenTotalIntegrationBalance);

  
  function getGasAccount() external view returns (address);

  
  function getTreasuryAccount() external view returns (address);

  
  function getLastEthRewardsAmount() external view returns (uint256);

  
  function getGasAccountTargetEthBalance() external view returns (uint256);

  
  
  
  
  function getEthDistributionWeights()
    external
    view
    returns (
      uint32,
      uint32,
      uint32,
      uint32
    );
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


















contract YieldManager is
  Initializable,
  ModuleMapConsumer,
  Controlled,
  IYieldManager
{
  using SafeERC20Upgradeable for IERC20MetadataUpgradeable;

  uint256 private gasAccountTargetEthBalance;
  uint32 private biosBuyBackEthWeight;
  uint32 private treasuryEthWeight;
  uint32 private protocolFeeEthWeight;
  uint32 private rewardsEthWeight;
  uint256 private lastEthRewardsAmount;

  address payable private gasAccount;
  address payable private treasuryAccount;

  mapping(address => uint256) private processedWethByToken;

  receive() external payable {}

  
  
  
  
  
  
  
  
  
  function initialize(
    address[] memory controllers_,
    address moduleMap_,
    uint256 gasAccountTargetEthBalance_,
    uint32 biosBuyBackEthWeight_,
    uint32 treasuryEthWeight_,
    uint32 protocolFeeEthWeight_,
    uint32 rewardsEthWeight_,
    address payable gasAccount_,
    address payable treasuryAccount_
  ) public initializer {
    __Controlled_init(controllers_, moduleMap_);
    __ModuleMapConsumer_init(moduleMap_);
    gasAccountTargetEthBalance = gasAccountTargetEthBalance_;
    biosBuyBackEthWeight = biosBuyBackEthWeight_;
    treasuryEthWeight = treasuryEthWeight_;
    protocolFeeEthWeight = protocolFeeEthWeight_;
    rewardsEthWeight = rewardsEthWeight_;
    gasAccount = gasAccount_;
    treasuryAccount = treasuryAccount_;
  }

  
  function updateGasAccountTargetEthBalance(uint256 gasAccountTargetEthBalance_)
    external
    override
    onlyController
  {
    gasAccountTargetEthBalance = gasAccountTargetEthBalance_;
  }

  
  
  
  
  function updateEthDistributionWeights(
    uint32 biosBuyBackEthWeight_,
    uint32 treasuryEthWeight_,
    uint32 protocolFeeEthWeight_,
    uint32 rewardsEthWeight_
  ) external override onlyController {
    biosBuyBackEthWeight = biosBuyBackEthWeight_;
    treasuryEthWeight = treasuryEthWeight_;
    protocolFeeEthWeight = protocolFeeEthWeight_;
    rewardsEthWeight = rewardsEthWeight_;
  }

  
  function updateGasAccount(address payable gasAccount_)
    external
    override
    onlyController
  {
    gasAccount = gasAccount_;
  }

  
  function updateTreasuryAccount(address payable treasuryAccount_)
    external
    override
    onlyController
  {
    treasuryAccount = treasuryAccount_;
  }

  
  function rebalance() external override onlyController {
    _deploy();
  }

  
  function deploy() external override onlyController {
    _deploy();
  }

  function _deploy() internal {
    bool shouldRedeploy = _rebalance();
    if (shouldRedeploy) {
      _rebalance();
    }
  }

  function _rebalance() internal returns (bool redeploy) {
    IIntegrationMap integrationMap = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    );
    IStrategyMap strategyMap = IStrategyMap(
      moduleMap.getModuleAddress(Modules.StrategyMap)
    );
    uint256 tokenCount = integrationMap.getTokenAddressesLength();
    uint256 integrationCount = integrationMap.getIntegrationAddressesLength();
    uint256 denominator = integrationMap.getReserveRatioDenominator();

    for (uint256 i = 0; i < integrationCount; i++) {
      address integration = integrationMap.getIntegrationAddress(i);
      for (uint256 j = 0; j < tokenCount; j++) {
        address token = integrationMap.getTokenAddress(j);
        uint256 numerator = integrationMap.getTokenReserveRatioNumerator(token);

        uint256 grossAmountInvested = strategyMap.getExpectedBalance(
          integration,
          token
        );

        uint256 desiredBalance = grossAmountInvested -
          _calculateReserveAmount(grossAmountInvested, numerator, denominator);

        uint256 actualBalance = IIntegration(integration).getBalance(token);

        if (desiredBalance > actualBalance) {
          // Underfunded, top up
          redeploy = true;
          uint256 shortage = desiredBalance - actualBalance;
          if (
            IERC20MetadataUpgradeable(token).balanceOf(
              moduleMap.getModuleAddress(Modules.Kernel)
            ) >= shortage
          ) {
            uint256 balanceBefore = IERC20MetadataUpgradeable(token).balanceOf(
              integration
            );
            IERC20MetadataUpgradeable(token).safeTransferFrom(
              moduleMap.getModuleAddress(Modules.Kernel),
              integration,
              shortage
            );
            uint256 balanceAfter = IERC20MetadataUpgradeable(token).balanceOf(
              integration
            );

            IIntegration(integration).deposit(
              token,
              balanceAfter - balanceBefore
            );
          }
        } else if (actualBalance > desiredBalance) {
          // Overfunded, give it a haircut
          redeploy = true;
          IIntegration(integration).withdraw(
            token,
            actualBalance - desiredBalance
          );
        }
      }
      IIntegration(integration).deploy();
    }
  }

  function _calculateReserveAmount(
    uint256 amount,
    uint256 numerator,
    uint256 denominator
  ) internal pure returns (uint256) {
    return (amount * numerator) / denominator;
  }

  
  function harvestYield() public override onlyController {
    IIntegrationMap integrationMap = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    );
    uint256 tokenCount = integrationMap.getTokenAddressesLength();
    uint256 integrationCount = integrationMap.getIntegrationAddressesLength();

    for (
      uint256 integrationId;
      integrationId < integrationCount;
      integrationId++
    ) {
      IIntegration(integrationMap.getIntegrationAddress(integrationId))
        .harvestYield();
    }

    for (uint256 tokenId; tokenId < tokenCount; tokenId++) {
      IERC20MetadataUpgradeable token = IERC20MetadataUpgradeable(
        integrationMap.getTokenAddress(tokenId)
      );

      uint256 tokenDesiredReserve = getDesiredReserveTokenBalance(
        address(token)
      );
      uint256 tokenActualReserve = getReserveTokenBalance(address(token));

      uint256 harvestedTokenAmount = token.balanceOf(address(this));

      // Check if reserves need to be replenished
      if (tokenDesiredReserve > tokenActualReserve) {
        // Need to replenish reserves
        if (tokenDesiredReserve - tokenActualReserve <= harvestedTokenAmount) {
          // Need to send portion of harvested token to Kernel to replenish reserves
          token.safeTransfer(
            moduleMap.getModuleAddress(Modules.Kernel),
            tokenDesiredReserve - tokenActualReserve
          );
        } else {
          // Need to send all of harvested token to Kernel to partially replenish reserves
          token.safeTransfer(
            moduleMap.getModuleAddress(Modules.Kernel),
            token.balanceOf(address(this))
          );
        }
      }
    }
  }

  
  function processYield() external override onlyController {
    IIntegrationMap integrationMap = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    );
    uint256 tokenCount = integrationMap.getTokenAddressesLength();
    IERC20MetadataUpgradeable weth = IERC20MetadataUpgradeable(
      integrationMap.getWethTokenAddress()
    );

    for (uint256 tokenId; tokenId < tokenCount; tokenId++) {
      IERC20MetadataUpgradeable token = IERC20MetadataUpgradeable(
        integrationMap.getTokenAddress(tokenId)
      );

      if (token.balanceOf(address(this)) > 0) {
        uint256 wethReceived;

        if (address(token) != address(weth)) {
          // If token is not WETH, need to swap it for WETH
          uint256 wethBalanceBefore = weth.balanceOf(address(this));

          // Swap token harvested yield for WETH. If trade succeeds, update accounting. Otherwise, do not update accounting
          token.safeTransfer(
            moduleMap.getModuleAddress(Modules.UniswapTrader),
            token.balanceOf(address(this))
          );

          IUniswapTrader(moduleMap.getModuleAddress(Modules.UniswapTrader))
            .swapExactInput(
              address(token),
              address(weth),
              address(this),
              token.balanceOf(moduleMap.getModuleAddress(Modules.UniswapTrader))
            );

          wethReceived = weth.balanceOf(address(this)) - wethBalanceBefore;
        } else {
          // If token is WETH, no swap is needed
          wethReceived =
            weth.balanceOf(address(this)) -
            getProcessedWethByTokenSum();
        }

        // Update accounting
        processedWethByToken[address(token)] += wethReceived;
      }
    }
  }

  
  function distributeEth() external override onlyController {
    IIntegrationMap integrationMap = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    );
    address wethAddress = IIntegrationMap(integrationMap).getWethTokenAddress();

    // First fill up gas wallet with ETH
    ethToGasAccount();

    uint256 wethToDistribute = IERC20MetadataUpgradeable(wethAddress).balanceOf(
      address(this)
    );

    if (wethToDistribute > 0) {
      uint256 biosBuyBackWethAmount = (wethToDistribute *
        biosBuyBackEthWeight) / getEthWeightSum();
      uint256 treasuryWethAmount = (wethToDistribute * treasuryEthWeight) /
        getEthWeightSum();
      uint256 protocolFeeWethAmount = (wethToDistribute *
        protocolFeeEthWeight) / getEthWeightSum();
      uint256 rewardsWethAmount = wethToDistribute -
        biosBuyBackWethAmount -
        treasuryWethAmount -
        protocolFeeWethAmount;

      // Send WETH to SushiSwap trader for BIOS buy back
      IERC20MetadataUpgradeable(wethAddress).safeTransfer(
        moduleMap.getModuleAddress(Modules.SushiSwapTrader),
        biosBuyBackWethAmount
      );

      // Swap WETH for ETH and transfer to the treasury account
      IWeth9(wethAddress).withdraw(treasuryWethAmount);
      payable(treasuryAccount).transfer(treasuryWethAmount);

      // Send ETH to protocol fee accrual rewards (BIOS stakers)
      ethToProtocolFeeAccrual(protocolFeeWethAmount);

      // Send ETH to token rewards
      ethToRewards(rewardsWethAmount);
    }
  }

  
  function ethToGasAccount() private {
    address wethAddress = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    ).getWethTokenAddress();
    uint256 wethBalance = IERC20MetadataUpgradeable(wethAddress).balanceOf(
      address(this)
    );

    if (wethBalance > 0) {
      uint256 gasAccountActualEthBalance = gasAccount.balance;
      if (gasAccountActualEthBalance < gasAccountTargetEthBalance) {
        // Need to send ETH to gas account
        uint256 ethAmountToGasAccount;
        if (
          wethBalance < gasAccountTargetEthBalance - gasAccountActualEthBalance
        ) {
          // Send all of WETH to gas wallet
          ethAmountToGasAccount = wethBalance;
          IWeth9(wethAddress).withdraw(ethAmountToGasAccount);
          gasAccount.transfer(ethAmountToGasAccount);
        } else {
          // Send portion of WETH to gas wallet
          ethAmountToGasAccount =
            gasAccountTargetEthBalance -
            gasAccountActualEthBalance;
          IWeth9(wethAddress).withdraw(ethAmountToGasAccount);
          gasAccount.transfer(ethAmountToGasAccount);
        }
      }
    }
  }

  
  function biosBuyBack() external override onlyController {
    if (
      IERC20MetadataUpgradeable(
        IIntegrationMap(moduleMap.getModuleAddress(Modules.IntegrationMap))
          .getWethTokenAddress()
      ).balanceOf(moduleMap.getModuleAddress(Modules.SushiSwapTrader)) > 0
    ) {
      // Use all ETH sent to the SushiSwap trader to buy BIOS
      ISushiSwapTrader(moduleMap.getModuleAddress(Modules.SushiSwapTrader))
        .biosBuyBack();

      // Use all BIOS transferred to the Kernel to increase bios rewards
      IUserPositions(moduleMap.getModuleAddress(Modules.UserPositions))
        .increaseBiosRewards();
    }
  }

  
  
  function ethToRewards(uint256 ethRewardsAmount) private {
    uint256 processedWethByTokenSum = getProcessedWethSum();
    require(
      processedWethByTokenSum > 0,
      "YieldManager::ethToRewards: No processed WETH to distribute"
    );

    IIntegrationMap integrationMap = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    );
    address wethAddress = integrationMap.getWethTokenAddress();
    uint256 tokenCount = integrationMap.getTokenAddressesLength();

    for (uint256 tokenId; tokenId < tokenCount; tokenId++) {
      address tokenAddress = integrationMap.getTokenAddress(tokenId);

      if (processedWethByToken[tokenAddress] > 0) {
        IEtherRewards(moduleMap.getModuleAddress(Modules.EtherRewards))
          .increaseEthRewards(
            tokenAddress,
            (ethRewardsAmount * processedWethByToken[tokenAddress]) /
              processedWethByTokenSum
          );

        processedWethByToken[tokenAddress] = 0;
      }
    }

    lastEthRewardsAmount = ethRewardsAmount;

    IWeth9(wethAddress).withdraw(ethRewardsAmount);

    payable(moduleMap.getModuleAddress(Modules.Kernel)).transfer(
      ethRewardsAmount
    );
  }

  
  
  function ethToProtocolFeeAccrual(uint256 protocolFeeEthRewardsAmount)
    private
  {
    IIntegrationMap integrationMap = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    );
    address biosAddress = integrationMap.getBiosTokenAddress();
    address wethAddress = integrationMap.getWethTokenAddress();

    if (
      IStrategyMap(moduleMap.getModuleAddress(Modules.StrategyMap))
        .getTokenTotalBalance(biosAddress) > 0
    ) {
      // BIOS has been deposited, increase Ether rewards for BIOS depositors
      IEtherRewards(moduleMap.getModuleAddress(Modules.EtherRewards))
        .increaseEthRewards(biosAddress, protocolFeeEthRewardsAmount);

      IWeth9(wethAddress).withdraw(protocolFeeEthRewardsAmount);

      payable(moduleMap.getModuleAddress(Modules.Kernel)).transfer(
        protocolFeeEthRewardsAmount
      );
    } else {
      // No BIOS has been deposited, send WETH back to Kernel as reserves
      IERC20MetadataUpgradeable(wethAddress).transfer(
        moduleMap.getModuleAddress(Modules.Kernel),
        protocolFeeEthRewardsAmount
      );
    }
  }

  
  
  function getHarvestedTokenBalance(address tokenAddress)
    external
    view
    override
    returns (uint256 harvestedTokenBalance)
  {
    if (
      tokenAddress ==
      IIntegrationMap(moduleMap.getModuleAddress(Modules.IntegrationMap))
        .getWethTokenAddress()
    ) {
      harvestedTokenBalance =
        IERC20MetadataUpgradeable(tokenAddress).balanceOf(address(this)) -
        getProcessedWethSum();
    } else {
      harvestedTokenBalance = IERC20MetadataUpgradeable(tokenAddress).balanceOf(
          address(this)
        );
    }
  }

  
  
  function getReserveTokenBalance(address tokenAddress)
    public
    view
    override
    returns (uint256)
  {
    require(
      IIntegrationMap(moduleMap.getModuleAddress(Modules.IntegrationMap))
        .getIsTokenAdded(tokenAddress),
      "YieldManager::getReserveTokenBalance: Token not added"
    );
    return
      IERC20MetadataUpgradeable(tokenAddress).balanceOf(
        moduleMap.getModuleAddress(Modules.Kernel)
      );
  }

  
  
  function getDesiredReserveTokenBalance(address tokenAddress)
    public
    view
    override
    returns (uint256)
  {
    require(
      IIntegrationMap(moduleMap.getModuleAddress(Modules.IntegrationMap))
        .getIsTokenAdded(tokenAddress),
      "YieldManager::getDesiredReserveTokenBalance: Token not added"
    );
    uint256 tokenReserveRatioNumerator = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    ).getTokenReserveRatioNumerator(tokenAddress);
    uint256 tokenTotalBalance = IStrategyMap(
      moduleMap.getModuleAddress(Modules.StrategyMap)
    ).getTokenTotalBalance(tokenAddress);
    return
      (tokenTotalBalance * tokenReserveRatioNumerator) /
      IIntegrationMap(moduleMap.getModuleAddress(Modules.IntegrationMap))
        .getReserveRatioDenominator();
  }

  
  function getEthWeightSum()
    public
    view
    override
    returns (uint32 ethWeightSum)
  {
    ethWeightSum =
      biosBuyBackEthWeight +
      treasuryEthWeight +
      protocolFeeEthWeight +
      rewardsEthWeight;
  }

  
  function getProcessedWethSum()
    public
    view
    override
    returns (uint256 processedWethSum)
  {
    uint256 tokenCount = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    ).getTokenAddressesLength();

    for (uint256 tokenId; tokenId < tokenCount; tokenId++) {
      address tokenAddress = IIntegrationMap(
        moduleMap.getModuleAddress(Modules.IntegrationMap)
      ).getTokenAddress(tokenId);
      processedWethSum += processedWethByToken[tokenAddress];
    }
  }

  
  
  function getProcessedWethByToken(address tokenAddress)
    public
    view
    override
    returns (uint256)
  {
    return processedWethByToken[tokenAddress];
  }

  
  function getProcessedWethByTokenSum()
    public
    view
    override
    returns (uint256 processedWethByTokenSum)
  {
    IIntegrationMap integrationMap = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    );
    uint256 tokenCount = integrationMap.getTokenAddressesLength();

    for (uint256 tokenId; tokenId < tokenCount; tokenId++) {
      processedWethByTokenSum += processedWethByToken[
        integrationMap.getTokenAddress(tokenId)
      ];
    }
  }

  
  
  function getTokenTotalIntegrationBalance(address tokenAddress)
    public
    view
    override
    returns (uint256 tokenTotalIntegrationBalance)
  {
    IIntegrationMap integrationMap = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    );
    uint256 integrationCount = integrationMap.getIntegrationAddressesLength();

    for (
      uint256 integrationId;
      integrationId < integrationCount;
      integrationId++
    ) {
      tokenTotalIntegrationBalance += IIntegration(
        integrationMap.getIntegrationAddress(integrationId)
      ).getBalance(tokenAddress);
    }
  }

  
  function getGasAccount() public view override returns (address) {
    return gasAccount;
  }

  
  function getTreasuryAccount() public view override returns (address) {
    return treasuryAccount;
  }

  
  function getLastEthRewardsAmount() public view override returns (uint256) {
    return lastEthRewardsAmount;
  }

  
  function getGasAccountTargetEthBalance()
    public
    view
    override
    returns (uint256)
  {
    return gasAccountTargetEthBalance;
  }

  
  
  
  
  function getEthDistributionWeights()
    public
    view
    override
    returns (
      uint32,
      uint32,
      uint32,
      uint32
    )
  {
    return (
      biosBuyBackEthWeight,
      treasuryEthWeight,
      protocolFeeEthWeight,
      rewardsEthWeight
    );
  }
}

// 
pragma solidity ^0.8.4;

interface IEtherRewards {
  
  
  function updateUserRewards(address token, address user) external;

  
  
  function increaseEthRewards(address token, uint256 ethRewardsAmount) external;

  
  
  function claimEthRewards(address user) external returns (uint256 ethRewards);

  
  
  
  function getUserTokenEthRewards(address token, address user)
    external
    view
    returns (uint256 ethRewards);

  
  
  function getUserEthRewards(address user)
    external
    view
    returns (uint256 ethRewards);

  
  
  function getTokenEthRewards(address token) external view returns (uint256);

  
  function getTotalClaimedEthRewards() external view returns (uint256);

  
  function getTotalUserClaimedEthRewards(address user)
    external
    view
    returns (uint256);

  
  function getEthRewards() external view returns (uint256);
}

// 
pragma solidity ^0.8.4;

interface IIntegration {
  
  
  function deposit(address tokenAddress, uint256 amount) external;

  
  
  function withdraw(address tokenAddress, uint256 amount) external;

  
  function deploy() external;

  
  function harvestYield() external;

  
  
  
  
  function getBalance(address tokenAddress) external view returns (uint256);
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


interface IStrategyMap {
  // #### Structs
  struct WeightedIntegration {
    address integration;
    uint256 weight;
  }

  struct Strategy {
    string name;
    uint256 totalStrategyWeight;
    mapping(address => bool) enabledTokens;
    address[] tokens;
    WeightedIntegration[] integrations;
  }

  struct StrategySummary {
    string name;
    uint256 totalStrategyWeight;
    address[] tokens;
    WeightedIntegration[] integrations;
  }

  struct StrategyTransaction {
    uint256 amount;
    address token;
  }

  // #### Events
  event NewStrategy(
    uint256 indexed id,
    string name,
    WeightedIntegration[] integrations,
    address[] tokens
  );
  event UpdateName(uint256 indexed id, string name);
  event UpdateIntegrations(
    uint256 indexed id,
    WeightedIntegration[] integrations
  );
  event UpdateTokens(uint256 indexed id, address[] tokens);
  event DeleteStrategy(
    uint256 indexed id,
    string name,
    address[] tokens,
    WeightedIntegration[] integrations
  );

  event EnterStrategy(
    uint256 indexed id,
    address indexed user,
    address[] tokens,
    uint256[] amounts
  );
  event ExitStrategy(
    uint256 indexed id,
    address indexed user,
    address[] tokens,
    uint256[] amounts
  );

  // #### Functions
  /**
     @notice Adds a new strategy to the list of available strategies
     @param name  the name of the new strategy
     @param integrations  the integrations and weights that form the strategy
     */
  function addStrategy(
    string calldata name,
    WeightedIntegration[] memory integrations,
    address[] calldata tokens
  ) external;

  /**
    @notice Updates the strategy name
    @param name  the new name
     */
  function updateName(uint256 id, string calldata name) external;

  /**
  @notice Updates a strategy's accepted tokens
  @param id  The strategy ID
  @param tokens  The new tokens to allow
  */
  function updateTokens(uint256 id, address[] calldata tokens) external;

  /**
    @notice Updates the strategy integrations 
    @param integrations  the new integrations
     */
  function updateIntegrations(
    uint256 id,
    WeightedIntegration[] memory integrations
  ) external;

  /**
    @notice Deletes a strategy
    @dev This can only be called successfully if the strategy being deleted doesn't have any assets invested in it
    @param id  the strategy to delete
     */
  function deleteStrategy(uint256 id) external;

  /**
    @notice Increases the amount of a set of tokens in a strategy
    @param id  the strategy to deposit into
    @param tokens  the tokens to deposit
    @param amounts  The amounts to be deposited
     */
  function enterStrategy(
    uint256 id,
    address user,
    address[] calldata tokens,
    uint256[] calldata amounts
  ) external;

  /**
    @notice Decreases the amount of a set of tokens invested in a strategy
    @param id  the strategy to withdraw assets from
    @param tokens  the tokens to withdraw
    @param amounts  The amounts to be withdrawn
     */
  function exitStrategy(
    uint256 id,
    address user,
    address[] calldata tokens,
    uint256[] calldata amounts
  ) external;

  /**
    @notice Getter function to return the nested arrays as well as the name
    @param id  the strategy to return
     */
  function getStrategy(uint256 id)
    external
    view
    returns (StrategySummary memory);

  /**
    @notice Returns the expected balance of a given token in a given integration
    @param integration  the integration the amount should be invested in
    @param token  the token that is being invested
    @return balance  the balance of the token that should be currently invested in the integration 
     */
  function getExpectedBalance(address integration, address token)
    external
    view
    returns (uint256 balance);

  /**
    @notice Returns the amount of a given token currently invested in a strategy
    @param id  the strategy id to check
    @param token  The token to retrieve the balance for
    @return amount  the amount of token that is invested in the strategy
     */
  function getStrategyTokenBalance(uint256 id, address token)
    external
    view
    returns (uint256 amount);

  /**
    @notice returns the amount of a given token a user has invested in a given strategy
    @param id  the strategy id
    @param token  the token address
    @param user  the user who holds the funds
    @return amount  the amount of token that the user has invested in the strategy 
     */
  function getUserStrategyBalanceByToken(
    uint256 id,
    address token,
    address user
  ) external view returns (uint256 amount);

  /**
    @notice Returns the amount of a given token that a user has invested across all strategies
    @param token  the token address
    @param user  the user holding the funds
    @return amount  the amount of tokens the user has invested across all strategies
     */
  function getUserInvestedAmountByToken(address token, address user)
    external
    view
    returns (uint256 amount);

  /**
    @notice Returns the total amount of a token invested across all strategies
    @param token  the token to fetch the balance for
    @return amount  the amount of the token currently invested
    */
  function getTokenTotalBalance(address token)
    external
    view
    returns (uint256 amount);

  /**
  @notice Returns the weight of an individual integration within the system
  @param integration  the integration to look up
  @return The weight of the integration
   */
  function getIntegrationWeight(address integration)
    external
    view
    returns (uint256);

  /**
  @notice Returns the sum of all weights in the system.
  @return The sum of all integration weights within the system
   */
  function getIntegrationWeightSum() external view returns (uint256);

  
  function idCounter() external view returns(uint256);
}

// 
pragma solidity ^0.8.4;

interface ISushiSwapTrader {
  
  function updateSlippageNumerator(uint24 slippageNumerator_) external;

  
  
  function biosBuyBack() external returns (bool);

  
  
  
  
  
  
  function swapExactInput(
    address tokenIn,
    address tokenOut,
    address recipient,
    uint256 amountIn,
    uint256 amountOutMin
  ) external returns (bool);
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
pragma solidity ^0.8.4;

interface IUserPositions {
  
  function setBiosRewardsDuration(uint32 biosRewardsDuration_) external;

  
  
  function seedBiosRewards(address sender, uint256 biosAmount) external;

  
  function increaseBiosRewards() external;

  
  
  
  
  
  function deposit(
    address depositor,
    address[] memory tokens,
    uint256[] memory amounts,
    uint256 ethAmount
  ) external;

  
  
  
  
  
  function withdraw(
    address recipient,
    address[] memory tokens,
    uint256[] memory amounts,
    bool withdrawWethAsEth
  ) external returns (uint256 ethWithdrawn);

  
  
  
  
  
  
  
  
  function withdrawAllAndClaim(
    address recipient,
    address[] memory tokens,
    bool withdrawWethAsEth
  )
    external
    returns (
      uint256[] memory tokenAmounts,
      uint256 ethWithdrawn,
      uint256 ethClaimed,
      uint256 biosClaimed
    );

  
  function claimEthRewards(address user) external returns (uint256 ethClaimed);

  
  
  function claimBiosRewards(address recipient)
    external
    returns (uint256 biosClaimed);

  
  
  function totalTokenBalance(address asset) external view returns (uint256);

  
  
  function userTokenBalance(address asset, address account)
    external
    view
    returns (uint256);

  
  function getBiosRewardsDuration() external view returns (uint32);

  
  
  
  
  
  function transferToStrategy(
    address recipient,
    address[] memory tokens,
    uint256[] memory amounts
  ) external;

  
  
  
  
  
  function transferFromStrategy(
    address recipient,
    address[] memory tokens,
    uint256[] memory amounts
  ) external;
}

// 
pragma solidity ^0.8.4;

interface IWeth9 {
  event Deposit(address indexed dst, uint256 wad);
  event Withdrawal(address indexed src, uint256 wad);

  function deposit() external payable;

  
  function withdraw(uint256 wad) external;
}
