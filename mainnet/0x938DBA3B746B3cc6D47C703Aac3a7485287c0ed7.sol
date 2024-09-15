
/**
 *Submitted for verification at Etherscan.io on 2022-11-21
*/

// Sources flattened with hardhat v2.9.9 https://hardhat.org

// File lib/openzeppelin-contracts-upgradeable/contracts/utils/AddressUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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


// File lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * 
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}


// File src/base/Errors.sol

pragma solidity ^0.8.13;


///         `msg.origin` is not authorized.
error Unauthorized();


///         or entered an illegal condition which is not recoverable from.
error IllegalState();


///         to the function.
error IllegalArgument();


// File src/base/Multicall.sol

pragma solidity 0.8.13;



///

abstract contract Multicall {
    error MulticallFailed(bytes data, bytes result);

    function multicall(
        bytes[] calldata data
    ) external payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; ++i) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                revert MulticallFailed(data[i], result);
            }

            results[i] = result;
        }
    }
}


// File src/base/Mutex.sol

pragma solidity ^0.8.13;



///

abstract contract Mutex {
    
    error LockAlreadyClaimed();

    
    uint256 private _lockState;

    
    modifier lock() {
        _claimLock();

        _;

        _freeLock();
    }

    
    ///
    
    function _isLocked() internal returns (bool) {
        return _lockState == 1;
    }

    
    function _claimLock() internal {
        // Check that the lock has not been claimed yet.
        if (_lockState != 0) {
            revert LockAlreadyClaimed();
        }

        // Claim the lock.
        _lockState = 1;
    }

    
    function _freeLock() internal {
        _lockState = 0;
    }
}


// File src/interfaces/alchemist/IAlchemistV2Actions.sol

pragma solidity >=0.5.0;



///

interface IAlchemistV2Actions {
    
    ///
    /// **_NOTE:_** This function is WHITELISTED.
    ///
    
    
    function approveMint(address spender, uint256 amount) external;

    
    ///
    
    ///
    
    
    
    function approveWithdraw(
        address spender,
        address yieldToken,
        uint256 shares
    ) external;

    
    ///
    
    function poke(address owner) external;

    
    ///
    
    ///
    
    
    
    
    
    ///
    
    ///
    
    ///
    
    ///
    
    
    
    
    
    
    
    ///
    
    
    
    ///
    
    function deposit(
        address yieldToken,
        uint256 amount,
        address recipient
    ) external returns (uint256 sharesIssued);

    
    ///
    
    ///
    
    
    
    ///
    
    ///
    
    
    ///
    
    
    
    
    
    
    ///
    
    
    
    
    ///
    
    function depositUnderlying(
        address yieldToken,
        uint256 amount,
        address recipient,
        uint256 minimumAmountOut
    ) external returns (uint256 sharesIssued);

    
    ///
    
    
    ///
    
    ///
    
    ///
    
    
    
    
    
    
    
    ///
    
    
    
    ///
    
    function withdraw(
        address yieldToken,
        uint256 shares,
        address recipient
    ) external returns (uint256 amountWithdrawn);

    
    ///
    
    ///
    
    
    ///
    
    ///
    
    ///
    
    
    
    
    
    
    
    ///
    
    
    
    
    ///
    
    function withdrawFrom(
        address owner,
        address yieldToken,
        uint256 shares,
        address recipient
    ) external returns (uint256 amountWithdrawn);

    
    ///
    
    
    
    ///
    
    ///
    
    
    ///
    
    
    
    
    
    
    
    ///
    
    
    
    
    ///
    
    function withdrawUnderlying(
        address yieldToken,
        uint256 shares,
        address recipient,
        uint256 minimumAmountOut
    ) external returns (uint256 amountWithdrawn);

    
    ///
    
    
    
    ///
    
    ///
    
    
    ///
    
    
    
    
    
    
    
    ///
    
    
    
    
    
    ///
    
    function withdrawUnderlyingFrom(
        address owner,
        address yieldToken,
        uint256 shares,
        address recipient,
        uint256 minimumAmountOut
    ) external returns (uint256 amountWithdrawn);

    
    ///
    
    
    ///
    
    ///
    
    ///
    
    
    
    
    
    ///
    
    
    function mint(uint256 amount, address recipient) external;

    
    ///
    
    
    ///
    
    ///
    
    
    ///
    
    
    
    
    
    ///
    
    
    
    function mintFrom(
        address owner,
        uint256 amount,
        address recipient
    ) external;

    
    ///
    
    ///
    
    
    
    ///
    
    ///
    
    ///
    
    
    
    
    
    ///
    
    
    ///
    
    function burn(uint256 amount, address recipient) external returns (uint256 amountBurned);

    
    ///
    
    ///
    
    
    
    
    ///
    
    
    ///
    
    
    
    
    
    
    ///
    
    
    
    ///
    
    function repay(
        address underlyingToken,
        uint256 amount,
        address recipient
    ) external returns (uint256 amountRepaid);

    
    ///
    
    ///
    
    
    
    
    
    
    ///
    
    ///
    
    ///
    
    
    
    
    
    
    ///
    
    
    
    ///
    
    function liquidate(
        address yieldToken,
        uint256 shares,
        uint256 minimumAmountOut
    ) external returns (uint256 sharesLiquidated);

    
    ///
    
    
    ///
    
    ///
    
    ///
    
    
    
    
    
    
    ///
    
    
    function donate(address yieldToken, uint256 amount) external;

    
    ///
    
    
    
    ///
    
    ///
    
    
    function harvest(address yieldToken, uint256 minimumAmountOut) external;
}


// File src/interfaces/alchemist/IAlchemistV2AdminActions.sol

pragma solidity >=0.5.0;



///

interface IAlchemistV2AdminActions {
    
    struct InitializationParams {
        // The initial admin account.
        address admin;
        // The ERC20 token used to represent debt.
        address debtToken;
        // The initial transmuter or transmuter buffer.
        address transmuter;
        // The minimum collateralization ratio that an account must maintain.
        uint256 minimumCollateralization;
        // The percentage fee taken from each harvest measured in units of basis points.
        uint256 protocolFee;
        // The address that receives protocol fees.
        address protocolFeeReceiver;
        // A limit used to prevent administrators from making minting functionality inoperable.
        uint256 mintingLimitMinimum;
        // The maximum number of tokens that can be minted per period of time.
        uint256 mintingLimitMaximum;
        // The number of blocks that it takes for the minting limit to be refreshed.
        uint256 mintingLimitBlocks;
        // The address of the whitelist.
        address whitelist;
    }

    
    struct UnderlyingTokenConfig {
        // A limit used to prevent administrators from making repayment functionality inoperable.
        uint256 repayLimitMinimum;
        // The maximum number of underlying tokens that can be repaid per period of time.
        uint256 repayLimitMaximum;
        // The number of blocks that it takes for the repayment limit to be refreshed.
        uint256 repayLimitBlocks;
        // A limit used to prevent administrators from making liquidation functionality inoperable.
        uint256 liquidationLimitMinimum;
        // The maximum number of underlying tokens that can be liquidated per period of time.
        uint256 liquidationLimitMaximum;
        // The number of blocks that it takes for the liquidation limit to be refreshed.
        uint256 liquidationLimitBlocks;
    }

    
    struct YieldTokenConfig {
        // The adapter used by the system to interop with the token.
        address adapter;
        // The maximum percent loss in expected value that can occur before certain actions are disabled measured in
        // units of basis points.
        uint256 maximumLoss;
        // The maximum value that can be held by the system before certain actions are disabled measured in the
        // underlying token.
        uint256 maximumExpectedValue;
        // The number of blocks that credit will be distributed over to depositors.
        uint256 creditUnlockBlocks;
    }

    
    ///
    
    
    ///
    
    
    
    
    
    
    ///
    
    function initialize(InitializationParams memory params) external;

    
    ///
    
    ///
    
    ///
    
    ///
    
    function setPendingAdmin(address value) external;

    
    ///
    
    
    ///
    
    ///
    
    
    function acceptAdmin() external;

    
    ///
    
    ///
    
    
    function setSentinel(address sentinel, bool flag) external;

    
    ///
    
    ///
    
    
    function setKeeper(address keeper, bool flag) external;

    
    ///
    
    ///
    
    
    function addUnderlyingToken(
        address underlyingToken,
        UnderlyingTokenConfig calldata config
    ) external;

    
    ///
    
    ///
    
    
    
    ///
    
    
    function addYieldToken(address yieldToken, YieldTokenConfig calldata config)
        external;

    
    ///
    
    
    ///
    
    ///
    
    
    function setUnderlyingTokenEnabled(address underlyingToken, bool enabled)
        external;

    
    ///
    
    
    ///
    
    ///
    
    
    function setYieldTokenEnabled(address yieldToken, bool enabled) external;

    
    ///
    
    
    ///
    
    ///
    
    
    
    function configureRepayLimit(
        address underlyingToken,
        uint256 maximum,
        uint256 blocks
    ) external;

    
    ///
    
    
    ///
    
    ///
    
    
    
    function configureLiquidationLimit(
        address underlyingToken,
        uint256 maximum,
        uint256 blocks
    ) external;

    
    ///
    
    
    ///
    
    ///
    
    function setTransmuter(address value) external;

    
    ///
    
    ///
    
    ///
    
    function setMinimumCollateralization(uint256 value) external;

    
    ///
    
    
    ///
    
    ///
    
    function setProtocolFee(uint256 value) external;

    
    ///
    
    
    ///
    
    ///
    
    function setProtocolFeeReceiver(address value) external;

    
    ///
    
    ///
    
    ///
    
    
    function configureMintingLimit(uint256 maximum, uint256 blocks) external;

    
    ///
    
    ///
    
    
    function configureCreditUnlockRate(address yieldToken, uint256 blocks) external;

    
    ///
    
    
    
    ///
    
    ///
    
    
    function setTokenAdapter(address yieldToken, address adapter) external;

    
    ///
    
    
    ///
    
    
    function setMaximumExpectedValue(address yieldToken, uint256 value)
        external;

    
    ///
    
    
    ///
    
    ///
    
    
    function setMaximumLoss(address yieldToken, uint256 value) external;

    
    ///
    
    
    ///
    
    ///
    
    function snap(address yieldToken) external;

    
    ///
    
    
    ///
    
    
    function sweepRewardTokens(address rewardToken, address yieldToken) external;

    
    ///
    
    ///
    
    function setTransferAdapterAddress(address transferAdapterAddress) external;

    
    ///
    
    ///
    
    
    function transferDebtV1(address owner, int256 debt) external;
}


// File src/interfaces/alchemist/IAlchemistV2Errors.sol

pragma solidity >=0.5.0;



///

interface IAlchemistV2Errors {
    
    ///
    
    error UnsupportedToken(address token);

    
    ///
    
    error TokenDisabled(address token);

    
    error Undercollateralized();

    
    ///
    
    
    
    error ExpectedValueExceeded(address yieldToken, uint256 expectedValue, uint256 maximumExpectedValue);

    
    ///
    
    
    
    error LossExceeded(address yieldToken, uint256 loss, uint256 maximumLoss);

    
    ///
    
    
    error MintingLimitExceeded(uint256 amount, uint256 available);

    
    ///
    
    
    
    error RepayLimitExceeded(address underlyingToken, uint256 amount, uint256 available);

    
    ///
    
    
    
    error LiquidationLimitExceeded(address underlyingToken, uint256 amount, uint256 available);

    
    ///
    
    
    ///                         the operation.
    error SlippageExceeded(uint256 amount, uint256 minimumAmountOut);
}


// File src/interfaces/alchemist/IAlchemistV2Immutables.sol

pragma solidity >=0.5.0;



interface IAlchemistV2Immutables {
    
    ///
    
    function version() external view returns (string memory);

    
    ///
    
    function debtToken() external view returns (address);
}


// File src/interfaces/alchemist/IAlchemistV2Events.sol

pragma solidity >=0.5.0;



interface IAlchemistV2Events {
    
    ///
    
    event PendingAdminUpdated(address pendingAdmin);

    
    ///
    
    event AdminUpdated(address admin);

    
    ///
    
    
    event SentinelSet(address sentinel, bool flag);

    
    ///
    
    
    event KeeperSet(address sentinel, bool flag);

    
    ///
    
    event AddUnderlyingToken(address indexed underlyingToken);

    
    ///
    
    event AddYieldToken(address indexed yieldToken);

    
    ///
    
    
    event UnderlyingTokenEnabled(address indexed underlyingToken, bool enabled);

    
    ///
    
    
    event YieldTokenEnabled(address indexed yieldToken, bool enabled);

    
    ///
    
    
    
    event RepayLimitUpdated(address indexed underlyingToken, uint256 maximum, uint256 blocks);

    
    ///
    
    
    
    event LiquidationLimitUpdated(address indexed underlyingToken, uint256 maximum, uint256 blocks);

    
    ///
    
    event TransmuterUpdated(address transmuter);

    
    ///
    
    event MinimumCollateralizationUpdated(uint256 minimumCollateralization);

    
    ///
    
    event ProtocolFeeUpdated(uint256 protocolFee);
    
    
    ///
    
    event ProtocolFeeReceiverUpdated(address protocolFeeReceiver);

    
    ///
    
    
    event MintingLimitUpdated(uint256 maximum, uint256 blocks);

    
    ///
    
    
    event CreditUnlockRateUpdated(address yieldToken, uint256 blocks);

    
    ///
    
    
    event TokenAdapterUpdated(address yieldToken, address tokenAdapter);

    
    ///
    
    
    event MaximumExpectedValueUpdated(address indexed yieldToken, uint256 maximumExpectedValue);

    
    ///
    
    
    event MaximumLossUpdated(address indexed yieldToken, uint256 maximumLoss);

    
    ///
    
    
    event Snap(address indexed yieldToken, uint256 expectedValue);

    
    ///
    
    
    event SweepRewardTokens(address indexed rewardToken, uint256 amount);

    
    ///
    
    
    event SweepTokens(address indexed token, uint256 amount);

    
    ///
    
    
    
    event ApproveMint(address indexed owner, address indexed spender, uint256 amount);

    
    ///
    
    
    
    
    event ApproveWithdraw(address indexed owner, address indexed spender, address indexed yieldToken, uint256 amount);

    
    ///
    
    ///         underlying tokens were wrapped.
    ///
    
    
    
    
    event Deposit(address indexed sender, address indexed yieldToken, uint256 amount, address recipient);

    
    ///         by `owner` to `recipient`.
    ///
    
    ///         were unwrapped.
    ///
    
    
    
    
    event Withdraw(address indexed owner, address indexed yieldToken, uint256 shares, address recipient);

    
    ///
    
    
    
    event Mint(address indexed owner, uint256 amount, address recipient);

    
    ///
    
    
    
    event Burn(address indexed sender, uint256 amount, address recipient);

    
    ///
    
    
    
    
    
    event Repay(address indexed sender, address indexed underlyingToken, uint256 amount, address recipient, uint256 credit);

    
    ///
    
    
    
    
    
    event Liquidate(address indexed owner, address indexed yieldToken, address indexed underlyingToken, uint256 shares, uint256 credit);

    
    ///
    
    
    
    event Donate(address indexed sender, address indexed yieldToken, uint256 amount);

    
    ///
    
    
    
    
    event Harvest(address indexed yieldToken, uint256 minimumAmountOut, uint256 totalHarvested, uint256 credit);
}


// File src/interfaces/alchemist/IAlchemistV2State.sol

pragma solidity >=0.5.0;



interface IAlchemistV2State {
    
    struct UnderlyingTokenParams {
        // The number of decimals the token has. This value is cached once upon registering the token so it is important
        // that the decimals of the token are immutable or the system will begin to have computation errors.
        uint8 decimals;
        // A coefficient used to normalize the token to a value comparable to the debt token. For example, if the
        // underlying token is 8 decimals and the debt token is 18 decimals then the conversion factor will be
        // 10^10. One unit of the underlying token will be comparably equal to one unit of the debt token.
        uint256 conversionFactor;
        // A flag to indicate if the token is enabled.
        bool enabled;
    }

    
    struct YieldTokenParams {
        // The number of decimals the token has. This value is cached once upon registering the token so it is important
        // that the decimals of the token are immutable or the system will begin to have computation errors.
        uint8 decimals;
        // The associated underlying token that can be redeemed for the yield-token.
        address underlyingToken;
        // The adapter used by the system to wrap, unwrap, and lookup the conversion rate of this token into its
        // underlying token.
        address adapter;
        // The maximum percentage loss that is acceptable before disabling certain actions.
        uint256 maximumLoss;
        // The maximum value of yield tokens that the system can hold, measured in units of the underlying token.
        uint256 maximumExpectedValue;
        // The percent of credit that will be unlocked per block. The representation of this value is a 18  decimal
        // fixed point integer.
        uint256 creditUnlockRate;
        // The current balance of yield tokens which are held by users.
        uint256 activeBalance;
        // The current balance of yield tokens which are earmarked to be harvested by the system at a later time.
        uint256 harvestableBalance;
        // The total number of shares that have been minted for this token.
        uint256 totalShares;
        // The expected value of the tokens measured in underlying tokens. This value controls how much of the token
        // can be harvested. When users deposit yield tokens, it increases the expected value by how much the tokens
        // are exchangeable for in the underlying token. When users withdraw yield tokens, it decreases the expected
        // value by how much the tokens are exchangeable for in the underlying token.
        uint256 expectedValue;
        // The current amount of credit which is will be distributed over time to depositors.
        uint256 pendingCredit;
        // The amount of the pending credit that has been distributed.
        uint256 distributedCredit;
        // The block number which the last credit distribution occurred.
        uint256 lastDistributionBlock;
        // The total accrued weight. This is used to calculate how much credit a user has been granted over time. The
        // representation of this value is a 18 decimal fixed point integer.
        uint256 accruedWeight;
        // A flag to indicate if the token is enabled.
        bool enabled;
    }

    
    ///
    
    function admin() external view returns (address admin);

    
    ///
    
    function pendingAdmin() external view returns (address pendingAdmin);

    
    ///
    
    function transferAdapter() external view returns (address transferAdapter);

    
    ///
    
    ///
    
    function sentinels(address sentinel) external view returns (bool isSentinel);

    
    ///
    
    ///
    
    function keepers(address keeper) external view returns (bool isKeeper);

    
    ///
    
    function transmuter() external view returns (address transmuter);

    
    ///
    
    ///
    
    ///
    
    function minimumCollateralization() external view returns (uint256 minimumCollateralization);

    
    ///
    
    function protocolFee() external view returns (uint256 protocolFee);

    
    ///
    
    function protocolFeeReceiver() external view returns (address protocolFeeReceiver);

    
    ///
    
    function whitelist() external view returns (address whitelist);
    
    
    ///
    
    ///
    
    function getUnderlyingTokensPerShare(address yieldToken) external view returns (uint256 rate);

    
    ///
    
    ///
    
    function getYieldTokensPerShare(address yieldToken) external view returns (uint256 rate);

    
    ///
    
    ///
    
    function getSupportedUnderlyingTokens() external view returns (address[] memory tokens);

    
    ///
    
    ///
    
    function getSupportedYieldTokens() external view returns (address[] memory tokens);

    
    ///
    
    ///
    
    function isSupportedUnderlyingToken(address underlyingToken) external view returns (bool isSupported);

    
    ///
    
    ///
    
    function isSupportedYieldToken(address yieldToken) external view returns (bool isSupported);

    
    ///
    
    ///
    
    
    function accounts(address owner) external view returns (int256 debt, address[] memory depositedTokens);

    
    ///
    
    
    ///
    
    
    function positions(address owner, address yieldToken)
        external view
        returns (
            uint256 shares,
            uint256 lastAccruedWeight
        );

    
    ///
    
    
    ///
    
    function mintAllowance(address owner, address spender) external view returns (uint256 allowance);

    
    ///
    
    
    
    ///
    
    function withdrawAllowance(address owner, address spender, address yieldToken) external view returns (uint256 allowance);

    
    ///
    
    ///
    
    function getUnderlyingTokenParameters(address underlyingToken)
        external view
        returns (UnderlyingTokenParams memory params);

    
    ///
    
    ///
    
    function getYieldTokenParameters(address yieldToken)
        external view
        returns (YieldTokenParams memory params);

    
    ///
    
    
    
    function getMintLimitInfo()
        external view
        returns (
            uint256 currentLimit,
            uint256 rate,
            uint256 maximum
        );

    
    ///
    
    ///
    
    
    
    function getRepayLimitInfo(address underlyingToken)
        external view
        returns (
            uint256 currentLimit,
            uint256 rate,
            uint256 maximum
        );

    
    ///
    
    ///
    
    
    
    function getLiquidationLimitInfo(address underlyingToken)
        external view
        returns (
            uint256 currentLimit,
            uint256 rate,
            uint256 maximum
        );
}


// File src/interfaces/IAlchemistV2.sol

pragma solidity >=0.5.0;








interface IAlchemistV2 is
    IAlchemistV2Actions,
    IAlchemistV2AdminActions,
    IAlchemistV2Errors,
    IAlchemistV2Immutables,
    IAlchemistV2Events,
    IAlchemistV2State
{ }


// File src/interfaces/IERC20TokenReceiver.sol

pragma solidity >=0.5.0;



interface IERC20TokenReceiver {
    
    ///
    
    
    function onERC20Received(address token, uint256 value) external;
}


// File src/interfaces/ITokenAdapter.sol

pragma solidity >=0.5.0;



interface ITokenAdapter {
    
    ///
    
    function version() external view returns (string memory);

    
    ///
    
    function token() external view returns (address);

    
    ///
    
    function underlyingToken() external view returns (address);

    
    ///         for.
    ///
    
    function price() external view returns (uint256);

    
    ///
    
    
    ///
    
    function wrap(uint256 amount, address recipient)
        external
        returns (uint256 amountYieldTokens);

    
    ///
    
    
    ///
    
    function unwrap(uint256 amount, address recipient)
        external
        returns (uint256 amountUnderlyingTokens);
}


// File lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

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


// File src/interfaces/IAlchemicToken.sol

pragma solidity >=0.5.0;



interface IAlchemicToken is IERC20 {
  
  ///
  
  ///
  
  function hasMinted(address account) external view returns (uint256);

  
  ///
  /// This reverts if the `msg.sender` is not whitelisted.
  ///
  
  function lowerHasMinted(uint256 amount) external;

  
  ///
  /// This reverts if the `msg.sender` is not admin
  ///
  
  
  function setCeiling(address toSetCeiling, uint256 ceiling) external;

  
  ///
  /// This reverts if msg.sender is not admin
  ///
  
  
  function setWhitelist(address toWhitelist, bool state) external;

  function mint(address recipient, uint256 amount) external;

  function burn(uint256 amount) external;
}


// File src/interfaces/IWhitelist.sol

pragma solidity ^0.8.13;



interface IWhitelist {
  
  ///
  
  event AccountAdded(address account);

  
  ///
  
  event AccountRemoved(address account);

  
  event WhitelistDisabled();

  
  ///
  
  function getAddresses() external view returns (address[] memory addresses);

  
  ///
  
  function disabled() external view returns (bool);

  
  ///
  
  function add(address caller) external;

  
  ///
  
  function remove(address caller) external;

  
  ///
  /// This can only occur once. Once the whitelist is disabled, then it cannot be reenabled.
  function disable() external;

  
  ///
  
  ///
  
  function isWhitelisted(address account) external view returns (bool);
}


// File src/interfaces/IRewardCollector.sol

pragma solidity ^0.8.13;

interface IRewardCollector {
    
    ///
    
    function version() external view returns (string memory);

    
    ///
    
    function rewardToken() external view returns (address);

    
    ///
    
    function swapRouter() external view returns (address);

    
    ///
    
    function debtToken() external view returns (address);

    
    ///
    
    
    ///
    
    function claimAndDistributeRewards(address token, uint256 minimumAmountOut) external returns (uint256 claimed);
}


// File src/interfaces/external/vesper/IVesperRewards.sol


pragma solidity >=0.6.12;

interface IVesperRewards {
    function claimReward(address) external;

    function claimable(address) external view returns (address[] memory, uint256[] memory);

    function rewardTokens(uint256) external view returns (address);
}


// File src/interfaces/external/vesper/IVesperPool.sol

pragma solidity >=0.5.0;

interface IVesperPool is IERC20 {
    function deposit() external payable;

    function deposit(uint256 _share) external;

    function governor() external returns (address);

    function keepers() external returns (address);

    function multiTransfer(address[] memory _recipients, uint256[] memory _amounts)
        external
        returns (bool);

    function excessDebt(address _strategy) external view returns (uint256);

    function permit(
        address,
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external;

    function reportEarning(
        uint256 _profit,
        uint256 _loss,
        uint256 _payback
    ) external;

    function resetApproval() external;

    function sweepERC20(address _fromToken) external;

    function withdraw(uint256 _amount) external;

    function withdrawETH(uint256 _amount) external;

    function whitelistedWithdraw(uint256 _amount) external;

    function feeCollector() external view returns (address);

    function pricePerShare() external view returns (uint256);

    function token() external view returns (address);

    function tokensHere() external view returns (uint256);

    function totalDebtOf(address _strategy) external view returns (uint256);

    function totalValue() external view returns (uint256);

    function withdrawFee() external view returns (uint256);

    function poolRewards() external view returns (address);

    function getStrategies() external view returns (address[] memory);
}


// File src/libraries/SafeCast.sol

pragma solidity >=0.5.0;



library SafeCast {
  
  
  
  function toInt256(uint256 y) internal pure returns (int256 z) {
    if (y >= 2**255) {
      revert IllegalArgument();
    }
    z = int256(y);
  }

  
  
  
  function toUint256(int256 y) internal pure returns (uint256 z) {
    if (y < 0) {
      revert IllegalArgument();
    }
    z = uint256(y);
  }
}


// File src/libraries/Sets.sol

pragma solidity ^0.8.13;



library Sets {
    using Sets for AddressSet;

    
    struct AddressSet {
        address[] values;
        mapping(address => uint256) indexes;
    }

    
    ///
    
    
    ///
    
    function add(AddressSet storage self, address value) internal returns (bool) {
        if (self.contains(value)) {
            return false;
        }
        self.values.push(value);
        self.indexes[value] = self.values.length;
        return true;
    }

    
    ///
    
    
    ///
    
    function remove(AddressSet storage self, address value) internal returns (bool) {
        uint256 index = self.indexes[value];
        if (index == 0) {
            return false;
        }

        // Normalize the index since we know that the element is in the set.
        index--;

        uint256 lastIndex = self.values.length - 1;

        if (index != lastIndex) {
            address lastValue = self.values[lastIndex];
            self.values[index] = lastValue;
            self.indexes[lastValue] = index + 1;
        }

        self.values.pop();

        delete self.indexes[value];

        return true;
    }

    
    ///
    
    
    ///
    
    function contains(AddressSet storage self, address value) internal view returns (bool) {
        return self.indexes[value] != 0;
    }
}


// File lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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


// File src/interfaces/IERC20Burnable.sol

pragma solidity >=0.5.0;



interface IERC20Burnable is IERC20 {
    
    ///
    
    ///
    
    function burn(uint256 amount) external returns (bool);

    
    ///
    
    
    ///
    
    function burnFrom(address owner, uint256 amount) external returns (bool);
}


// File src/interfaces/IERC20Mintable.sol

pragma solidity >=0.5.0;



interface IERC20Mintable is IERC20 {
    
    ///
    
    
    function mint(address recipient, uint256 amount) external;
}


// File src/libraries/TokenUtils.sol

pragma solidity ^0.8.13;






library TokenUtils {
    
    ///
    
    
    
    ///                this is malformed data when the call was a success.
    error ERC20CallFailed(address target, bool success, bytes data);

    
    ///
    
    ///
    
    ///
    
    function expectDecimals(address token) internal view returns (uint8) {
        (bool success, bytes memory data) = token.staticcall(
            abi.encodeWithSelector(IERC20Metadata.decimals.selector)
        );

        if (token.code.length == 0 || !success || data.length < 32) {
            revert ERC20CallFailed(token, success, data);
        }

        return abi.decode(data, (uint8));
    }

    
    ///
    
    ///
    
    
    ///
    
    function safeBalanceOf(address token, address account) internal view returns (uint256) {
        (bool success, bytes memory data) = token.staticcall(
            abi.encodeWithSelector(IERC20.balanceOf.selector, account)
        );

        if (token.code.length == 0 || !success || data.length < 32) {
            revert ERC20CallFailed(token, success, data);
        }

        return abi.decode(data, (uint256));
    }

    
    ///
    
    ///
    
    
    
    function safeTransfer(address token, address recipient, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transfer.selector, recipient, amount)
        );

        if (token.code.length == 0 || !success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///
    
    
    
    function safeApprove(address token, address spender, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.approve.selector, spender, value)
        );

        if (token.code.length == 0 || !success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///
    
    
    
    
    function safeTransferFrom(address token, address owner, address recipient, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, owner, recipient, amount)
        );

        if (token.code.length == 0 || !success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///
    
    
    
    function safeMint(address token, address recipient, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Mintable.mint.selector, recipient, amount)
        );

        if (token.code.length == 0 || !success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    /// Reverts with a `CallFailed` error if execution of the burn fails or returns an unexpected value.
    ///
    
    
    function safeBurn(address token, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Burnable.burn.selector, amount)
        );

        if (token.code.length == 0 || !success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///
    
    
    
    function safeBurnFrom(address token, address owner, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Burnable.burnFrom.selector, owner, amount)
        );

        if (token.code.length == 0 || !success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }
}


// File src/libraries/Limiters.sol

pragma solidity ^0.8.13;



library Limiters {
    using Limiters for LinearGrowthLimiter;

    
    
    uint256 constant public MAX_COOLDOWN_BLOCKS = 1 days / 12 seconds;

    
    uint256 constant public FIXED_POINT_SCALAR = 1e18;

    
    struct LinearGrowthLimiter {
        uint256 maximum;        /// The maximum limit of the function.
        uint256 rate;           /// The rate at which the function increases back to its maximum.
        uint256 lastValue;      /// The most recently saved value of the function.
        uint256 lastBlock;      /// The block that `lastValue` was recorded.
        uint256 minLimit;       /// A minimum limit to avoid malicious governance bricking the contract
    }

    
    ///
    
    
    
    ///
    
    function createLinearGrowthLimiter(uint256 maximum, uint256 blocks, uint256 _minLimit) internal view returns (LinearGrowthLimiter memory) {
        if (blocks > MAX_COOLDOWN_BLOCKS) {
            revert IllegalArgument();
        }

        if (maximum < _minLimit) {
            revert IllegalArgument();
        }

        return LinearGrowthLimiter({
            maximum: maximum,
            rate: maximum * FIXED_POINT_SCALAR / blocks,
            lastValue: maximum,
            lastBlock: block.number,
            minLimit: _minLimit
        });
    }

    
    ///
    
    
    
    function configure(LinearGrowthLimiter storage self, uint256 maximum, uint256 blocks) internal {
        if (blocks > MAX_COOLDOWN_BLOCKS) {
            revert IllegalArgument();
        }

        if (maximum < self.minLimit) {
            revert IllegalArgument();
        }

        if (self.lastValue > maximum) {
            self.lastValue = maximum;
        }

        self.maximum = maximum;
        self.rate = maximum * FIXED_POINT_SCALAR / blocks;
    }

    
    ///
    
    function update(LinearGrowthLimiter storage self) internal {
        self.lastValue = self.get();
        self.lastBlock = block.number;
    }

    
    ///
    
    
    function increase(LinearGrowthLimiter storage self, uint256 amount) internal {
        uint256 value = self.get();
        self.lastValue = value + amount;
        self.lastBlock = block.number;
    }

    
    ///
    
    
    function decrease(LinearGrowthLimiter storage self, uint256 amount) internal {
        uint256 value = self.get();
        self.lastValue = value - amount;
        self.lastBlock = block.number;
    }

    
    ///
    
    function get(LinearGrowthLimiter storage self) internal view returns (uint256) {
        uint256 elapsed = block.number - self.lastBlock;
        if (elapsed == 0) {
            return self.lastValue;
        }
        uint256 delta = elapsed * self.rate / FIXED_POINT_SCALAR;
        uint256 value = self.lastValue + delta;
        return value > self.maximum ? self.maximum : value;
    }
}


// File src/AlchemistV2.sol

pragma solidity ^0.8.13;














contract AlchemistV2 is IAlchemistV2, Initializable, Multicall, Mutex {
    using Limiters for Limiters.LinearGrowthLimiter;
    using Sets for Sets.AddressSet;

    
    struct Account {
        // A signed value which represents the current amount of debt or credit that the account has accrued.
        // Positive values indicate debt, negative values indicate credit.
        int256 debt;
        // The share balances for each yield token.
        mapping(address => uint256) balances;
        // The last values recorded for accrued weights for each yield token.
        mapping(address => uint256) lastAccruedWeights;
        // The set of yield tokens that the account has deposited into the system.
        Sets.AddressSet depositedTokens;
        // The allowances for mints.
        mapping(address => uint256) mintAllowances;
        // The allowances for withdrawals.
        mapping(address => mapping(address => uint256)) withdrawAllowances;
    }

    
    uint256 public constant BPS = 10_000;

    
    ///         implementation have 18 decimals of resolution, meaning that 1 is represented as 1e18, 0.5 is
    ///         represented as 5e17, and 2 is represented as 2e18.
    uint256 public constant FIXED_POINT_SCALAR = 1e18;

    
    string public constant override version = "2.2.8";

    
    address public override debtToken;

    
    address public override admin;

    
    address public override pendingAdmin;

    
    mapping(address => bool) public override sentinels;

    
    mapping(address => bool) public override keepers;

    
    address public override transmuter;

    
    uint256 public override minimumCollateralization;

    
    uint256 public override protocolFee;

    
    address public override protocolFeeReceiver;

    
    address public override whitelist;

    
    Limiters.LinearGrowthLimiter private _mintingLimiter;

    // @dev The repay limiters for each underlying token.
    mapping(address => Limiters.LinearGrowthLimiter) private _repayLimiters;

    // @dev The liquidation limiters for each underlying token.
    mapping(address => Limiters.LinearGrowthLimiter) private _liquidationLimiters;

    
    mapping(address => Account) private _accounts;

    
    mapping(address => UnderlyingTokenParams) private _underlyingTokens;

    
    mapping(address => YieldTokenParams) private _yieldTokens;

    
    Sets.AddressSet private _supportedUnderlyingTokens;

    
    Sets.AddressSet private _supportedYieldTokens;

    
    address public override transferAdapter;

    constructor() initializer {}

    
    function getYieldTokensPerShare(address yieldToken) external view override returns (uint256) {
        return convertSharesToYieldTokens(yieldToken, 10**_yieldTokens[yieldToken].decimals);
    }

    
    function getUnderlyingTokensPerShare(address yieldToken) external view override returns (uint256) {
        return convertSharesToUnderlyingTokens(yieldToken, 10**_yieldTokens[yieldToken].decimals);
    }

    
    function getSupportedUnderlyingTokens() external view override returns (address[] memory) {
        return _supportedUnderlyingTokens.values;
    }

    
    function getSupportedYieldTokens() external view override returns (address[] memory) {
        return _supportedYieldTokens.values;
    }

    
    function isSupportedUnderlyingToken(address underlyingToken) external view override returns (bool) {
        return _supportedUnderlyingTokens.contains(underlyingToken);
    }

    
    function isSupportedYieldToken(address yieldToken) external view override returns (bool) {
        return _supportedYieldTokens.contains(yieldToken);
    }

    
    function accounts(address owner)
        external view override
        returns (
            int256 debt,
            address[] memory depositedTokens
        )
    {
        Account storage account = _accounts[owner];

        return (
            _calculateUnrealizedDebt(owner),
            account.depositedTokens.values
        );
    }

    
    function positions(address owner, address yieldToken)
        external view override
        returns (
            uint256 shares,
            uint256 lastAccruedWeight
        )
    {
        Account storage account = _accounts[owner];
        return (account.balances[yieldToken], account.lastAccruedWeights[yieldToken]);
    }

    
    function mintAllowance(address owner, address spender)
        external view override
        returns (uint256)
    {
        Account storage account = _accounts[owner];
        return account.mintAllowances[spender];
    }

    
    function withdrawAllowance(address owner, address spender, address yieldToken)
        external view override
        returns (uint256)
    {
        Account storage account = _accounts[owner];
        return account.withdrawAllowances[spender][yieldToken];
    }

    
    function getUnderlyingTokenParameters(address underlyingToken)
        external view override
        returns (UnderlyingTokenParams memory)
    {
        return _underlyingTokens[underlyingToken];
    }

    
    function getYieldTokenParameters(address yieldToken)
        external view override
        returns (YieldTokenParams memory)
    {
        return _yieldTokens[yieldToken];
    }

    
    function getMintLimitInfo()
        external view override
        returns (
            uint256 currentLimit,
            uint256 rate,
            uint256 maximum
        )
    {
        return (
            _mintingLimiter.get(),
            _mintingLimiter.rate,
            _mintingLimiter.maximum
        );
    }

    
    function getRepayLimitInfo(address underlyingToken)
        external view override
        returns (
            uint256 currentLimit,
            uint256 rate,
            uint256 maximum
        )
    {
        Limiters.LinearGrowthLimiter storage limiter = _repayLimiters[underlyingToken];
        return (
            limiter.get(),
            limiter.rate,
            limiter.maximum
        );
    }

    
    function getLiquidationLimitInfo(address underlyingToken)
        external view override
        returns (
            uint256 currentLimit,
            uint256 rate,
            uint256 maximum
        )
    {
        Limiters.LinearGrowthLimiter storage limiter = _liquidationLimiters[underlyingToken];
        return (
            limiter.get(),
            limiter.rate,
            limiter.maximum
        );
    }

    
    function initialize(InitializationParams memory params) external initializer {
        _checkArgument(params.protocolFee <= BPS);

        debtToken                = params.debtToken;
        admin                    = params.admin;
        transmuter               = params.transmuter;
        minimumCollateralization = params.minimumCollateralization;
        protocolFee              = params.protocolFee;
        protocolFeeReceiver      = params.protocolFeeReceiver;
        whitelist                = params.whitelist;

        _mintingLimiter = Limiters.createLinearGrowthLimiter(
            params.mintingLimitMaximum,
            params.mintingLimitBlocks,
            params.mintingLimitMinimum
        );

        emit AdminUpdated(admin);
        emit TransmuterUpdated(transmuter);
        emit MinimumCollateralizationUpdated(minimumCollateralization);
        emit ProtocolFeeUpdated(protocolFee);
        emit MintingLimitUpdated(params.mintingLimitMaximum, params.mintingLimitBlocks);
    }

    
    function setPendingAdmin(address value) external override {
        _onlyAdmin();
        pendingAdmin = value;
        emit PendingAdminUpdated(value);
    }

    
    function acceptAdmin() external override {
        _checkState(pendingAdmin != address(0));

        if (msg.sender != pendingAdmin) {
            revert Unauthorized();
        }

        admin = pendingAdmin;
        pendingAdmin = address(0);

        emit AdminUpdated(admin);
        emit PendingAdminUpdated(address(0));
    }

    
    function setSentinel(address sentinel, bool flag) external override {
        _onlyAdmin();
        sentinels[sentinel] = flag;
        emit SentinelSet(sentinel, flag);
    }

    
    function setKeeper(address keeper, bool flag) external override {
        _onlyAdmin();
        keepers[keeper] = flag;
        emit KeeperSet(keeper, flag);
    }

    
    function addUnderlyingToken(address underlyingToken, UnderlyingTokenConfig calldata config) external override lock {
        _onlyAdmin();
        _checkState(!_supportedUnderlyingTokens.contains(underlyingToken));

        uint8 tokenDecimals = TokenUtils.expectDecimals(underlyingToken);
        uint8 debtTokenDecimals = TokenUtils.expectDecimals(debtToken);

        _checkArgument(tokenDecimals <= debtTokenDecimals);

        _underlyingTokens[underlyingToken] = UnderlyingTokenParams({
            decimals:         tokenDecimals,
            conversionFactor: 10**(debtTokenDecimals - tokenDecimals),
            enabled:          false
        });

        _repayLimiters[underlyingToken] = Limiters.createLinearGrowthLimiter(
            config.repayLimitMaximum,
            config.repayLimitBlocks,
            config.repayLimitMinimum
        );

        _liquidationLimiters[underlyingToken] = Limiters.createLinearGrowthLimiter(
            config.liquidationLimitMaximum,
            config.liquidationLimitBlocks,
            config.liquidationLimitMinimum
        );

        _supportedUnderlyingTokens.add(underlyingToken);

        emit AddUnderlyingToken(underlyingToken);
    }

    
    function addYieldToken(address yieldToken, YieldTokenConfig calldata config) external override lock {
        _onlyAdmin();
        _checkArgument(config.maximumLoss <= BPS);
        _checkArgument(config.creditUnlockBlocks > 0);

        _checkState(!_supportedYieldTokens.contains(yieldToken));

        ITokenAdapter adapter = ITokenAdapter(config.adapter);

        _checkState(yieldToken == adapter.token());
        _checkSupportedUnderlyingToken(adapter.underlyingToken());

        _yieldTokens[yieldToken] = YieldTokenParams({
            decimals:              TokenUtils.expectDecimals(yieldToken),
            underlyingToken:       adapter.underlyingToken(),
            adapter:               config.adapter,
            maximumLoss:           config.maximumLoss,
            maximumExpectedValue:  config.maximumExpectedValue,
            creditUnlockRate:      FIXED_POINT_SCALAR / config.creditUnlockBlocks,
            activeBalance:         0,
            harvestableBalance:    0,
            totalShares:           0,
            expectedValue:         0,
            accruedWeight:         0,
            pendingCredit:         0,
            distributedCredit:     0,
            lastDistributionBlock: 0,
            enabled:               false
        });

        _supportedYieldTokens.add(yieldToken);

        TokenUtils.safeApprove(yieldToken, config.adapter, type(uint256).max);
        TokenUtils.safeApprove(adapter.underlyingToken(), config.adapter, type(uint256).max);

        emit AddYieldToken(yieldToken);
        emit TokenAdapterUpdated(yieldToken, config.adapter);
        emit MaximumLossUpdated(yieldToken, config.maximumLoss);
    }

    
    function setUnderlyingTokenEnabled(address underlyingToken, bool enabled) external override {
        _onlySentinelOrAdmin();
        _checkSupportedUnderlyingToken(underlyingToken);
        _underlyingTokens[underlyingToken].enabled = enabled;
        emit UnderlyingTokenEnabled(underlyingToken, enabled);
    }

    
    function setYieldTokenEnabled(address yieldToken, bool enabled) external override {
        _onlySentinelOrAdmin();
        _checkSupportedYieldToken(yieldToken);
        _yieldTokens[yieldToken].enabled = enabled;
        emit YieldTokenEnabled(yieldToken, enabled);
    }

    
    function configureRepayLimit(address underlyingToken, uint256 maximum, uint256 blocks) external override {
        _onlyAdmin();
        _checkSupportedUnderlyingToken(underlyingToken);
        _repayLimiters[underlyingToken].update();
        _repayLimiters[underlyingToken].configure(maximum, blocks);
        emit RepayLimitUpdated(underlyingToken, maximum, blocks);
    }

    
    function configureLiquidationLimit(address underlyingToken, uint256 maximum, uint256 blocks) external override {
        _onlyAdmin();
        _checkSupportedUnderlyingToken(underlyingToken);
        _liquidationLimiters[underlyingToken].update();
        _liquidationLimiters[underlyingToken].configure(maximum, blocks);
        emit LiquidationLimitUpdated(underlyingToken, maximum, blocks);
    }

    
    function setTransmuter(address value) external override {
        _onlyAdmin();
        _checkArgument(value != address(0));
        transmuter = value;
        emit TransmuterUpdated(value);
    }

    
    function setMinimumCollateralization(uint256 value) external override {
        _onlyAdmin();
        _checkArgument(value >= 1e18);
        minimumCollateralization = value;
        emit MinimumCollateralizationUpdated(value);
    }

    
    function setProtocolFee(uint256 value) external override {
        _onlyAdmin();
        _checkArgument(value <= BPS);
        protocolFee = value;
        emit ProtocolFeeUpdated(value);
    }

    
    function setProtocolFeeReceiver(address value) external override {
        _onlyAdmin();
        _checkArgument(value != address(0));
        protocolFeeReceiver = value;
        emit ProtocolFeeReceiverUpdated(value);
    }

    
    function configureMintingLimit(uint256 maximum, uint256 rate) external override {
        _onlyAdmin();
        _mintingLimiter.update();
        _mintingLimiter.configure(maximum, rate);
        emit MintingLimitUpdated(maximum, rate);
    }

    
    function configureCreditUnlockRate(address yieldToken, uint256 blocks) external override {
        _onlyAdmin();
        _checkArgument(blocks > 0);
        _checkSupportedYieldToken(yieldToken);
        _yieldTokens[yieldToken].creditUnlockRate = FIXED_POINT_SCALAR / blocks;
        emit CreditUnlockRateUpdated(yieldToken, blocks);
    }

    
    function setTokenAdapter(address yieldToken, address adapter) external override {
        _onlyAdmin();
        _checkState(yieldToken == ITokenAdapter(adapter).token());
        _checkSupportedYieldToken(yieldToken);
        _yieldTokens[yieldToken].adapter = adapter;
        TokenUtils.safeApprove(yieldToken, adapter, type(uint256).max);
        TokenUtils.safeApprove(ITokenAdapter(adapter).underlyingToken(), adapter, type(uint256).max);
        emit TokenAdapterUpdated(yieldToken, adapter);
    }

    
    function setMaximumExpectedValue(address yieldToken, uint256 value) external override {
        _onlyAdmin();
        _checkSupportedYieldToken(yieldToken);
        _yieldTokens[yieldToken].maximumExpectedValue = value;
        emit MaximumExpectedValueUpdated(yieldToken, value);
    }

    
    function setMaximumLoss(address yieldToken, uint256 value) external override {
        _onlyAdmin();
        _checkArgument(value <= BPS);
        _checkSupportedYieldToken(yieldToken);

        _yieldTokens[yieldToken].maximumLoss = value;

        emit MaximumLossUpdated(yieldToken, value);
    }

    
    function snap(address yieldToken) external override lock {
        _onlyAdmin();
        _checkSupportedYieldToken(yieldToken);

        uint256 expectedValue = convertYieldTokensToUnderlying(yieldToken, _yieldTokens[yieldToken].activeBalance);

        _yieldTokens[yieldToken].expectedValue = expectedValue;

        emit Snap(yieldToken, expectedValue);
    }

    
    function sweepRewardTokens(address rewardToken, address yieldToken) external override lock {
        _onlyKeeper();

        if (_supportedYieldTokens.contains(rewardToken) || _supportedUnderlyingTokens.contains(rewardToken)) {
            revert UnsupportedToken(rewardToken);
        }

        msg.sender.delegatecall(abi.encodeWithSignature("claim(address)", yieldToken));

        TokenUtils.safeTransfer(rewardToken, msg.sender, TokenUtils.safeBalanceOf(rewardToken, address(this)));
    }

    
    function setTransferAdapterAddress(address transferAdapterAddress) external override lock {
        _onlyAdmin();
        transferAdapter = transferAdapterAddress;
    }

    
    function transferDebtV1(
        address owner, 
        int256 debt
    ) external override lock {
        _onlyTransferAdapter();
        _poke(owner);
        _updateDebt(owner, debt);
        _validate(owner);
    }

    
    function approveMint(address spender, uint256 amount) external override {
        _onlyWhitelisted();
        _approveMint(msg.sender, spender, amount);
    }

    
    function approveWithdraw(address spender, address yieldToken, uint256 shares) external override {
        _onlyWhitelisted();
        _checkSupportedYieldToken(yieldToken);
        _approveWithdraw(msg.sender, spender, yieldToken, shares);
    }

    
    function poke(address owner) external override lock {
        _onlyWhitelisted();
        _preemptivelyHarvestDeposited(owner);
        _distributeUnlockedCreditDeposited(owner);
        _poke(owner);
    }

    
    function deposit(
        address yieldToken,
        uint256 amount,
        address recipient
    ) external override lock returns (uint256) {
        _onlyWhitelisted();
        _checkArgument(recipient != address(0));
        _checkSupportedYieldToken(yieldToken);

        // Deposit the yield tokens to the recipient.
        uint256 shares = _deposit(yieldToken, amount, recipient);

        // Transfer tokens from the message sender now that the internal storage updates have been committed.
        TokenUtils.safeTransferFrom(yieldToken, msg.sender, address(this), amount);

        return shares;
    }

    
    function depositUnderlying(
        address yieldToken,
        uint256 amount,
        address recipient,
        uint256 minimumAmountOut
    ) external override lock returns (uint256) {
        _onlyWhitelisted();
        _checkArgument(recipient != address(0));
        _checkSupportedYieldToken(yieldToken);

        // Before depositing, the underlying tokens must be wrapped into yield tokens.
        uint256 amountYieldTokens = _wrap(yieldToken, amount, minimumAmountOut);

        // Deposit the yield-tokens to the recipient.
        return _deposit(yieldToken, amountYieldTokens, recipient);
    }

    
    function withdraw(
        address yieldToken,
        uint256 shares,
        address recipient
    ) external override lock returns (uint256) {
        _onlyWhitelisted();
        _checkArgument(recipient != address(0));
        _checkSupportedYieldToken(yieldToken);

        // Withdraw the shares from the system.
        uint256 amountYieldTokens = _withdraw(yieldToken, msg.sender, shares, recipient);

        // Transfer the yield tokens to the recipient.
        TokenUtils.safeTransfer(yieldToken, recipient, amountYieldTokens);

        return amountYieldTokens;
    }

    
    function withdrawFrom(
        address owner,
        address yieldToken,
        uint256 shares,
        address recipient
    ) external override lock returns (uint256) {
        _onlyWhitelisted();
        _checkArgument(recipient != address(0));
        _checkSupportedYieldToken(yieldToken);

        // Preemptively try and decrease the withdrawal allowance. This will save gas when the allowance is not
        // sufficient for the withdrawal.
        _decreaseWithdrawAllowance(owner, msg.sender, yieldToken, shares);

        // Withdraw the shares from the system.
        uint256 amountYieldTokens = _withdraw(yieldToken, owner, shares, recipient);

        // Transfer the yield tokens to the recipient.
        TokenUtils.safeTransfer(yieldToken, recipient, amountYieldTokens);

        return amountYieldTokens;
    }

    
    function withdrawUnderlying(
        address yieldToken,
        uint256 shares,
        address recipient,
        uint256 minimumAmountOut
    ) external override lock returns (uint256) {
        _onlyWhitelisted();
        _checkArgument(recipient != address(0));
        _checkSupportedYieldToken(yieldToken);
        _checkLoss(yieldToken);

        uint256 amountYieldTokens = _withdraw(yieldToken, msg.sender, shares, recipient);

        return _unwrap(yieldToken, amountYieldTokens, recipient, minimumAmountOut);
    }

    
    function withdrawUnderlyingFrom(
        address owner,
        address yieldToken,
        uint256 shares,
        address recipient,
        uint256 minimumAmountOut
    ) external override lock returns (uint256) {
        _onlyWhitelisted();
        _checkArgument(recipient != address(0));
        _checkSupportedYieldToken(yieldToken);
        _checkLoss(yieldToken);
        _decreaseWithdrawAllowance(owner, msg.sender, yieldToken, shares);

        uint256 amountYieldTokens = _withdraw(yieldToken, owner, shares, recipient);

        return _unwrap(yieldToken, amountYieldTokens, recipient, minimumAmountOut);
    }

    
    function mint(uint256 amount, address recipient) external override lock {
        _onlyWhitelisted();
        _checkArgument(amount > 0);
        _checkArgument(recipient != address(0));

        // Mint tokens from the message sender's account to the recipient.
        _mint(msg.sender, amount, recipient);
    }

    
    function mintFrom(
        address owner,
        uint256 amount,
        address recipient
    ) external override lock {
        _onlyWhitelisted();
        _checkArgument(amount > 0);
        _checkArgument(recipient != address(0));

        // Preemptively try and decrease the minting allowance. This will save gas when the allowance is not sufficient
        // for the mint.
        _decreaseMintAllowance(owner, msg.sender, amount);

        // Mint tokens from the owner's account to the recipient.
        _mint(owner, amount, recipient);
    }

    
    function burn(uint256 amount, address recipient) external override lock returns (uint256) {
        _onlyWhitelisted();

        _checkArgument(amount > 0);
        _checkArgument(recipient != address(0));

        // Distribute unlocked credit to depositors.
        _distributeUnlockedCreditDeposited(recipient);

        // Update the recipient's account, decrease the debt of the recipient by the number of tokens burned.
        _poke(recipient);

        // Check that the debt is greater than zero.
        //
        // It is possible that the number of debt which is repayable is equal to or less than zero after realizing the
        // credit that was earned since the last update. We do not want to perform a noop so we need to check that the
        // amount of debt to repay is greater than zero.
        int256 debt;
        _checkState((debt = _accounts[recipient].debt) > 0);

        // Limit how much debt can be repaid up to the current amount of debt that the account has. This prevents
        // situations where the user may be trying to repay their entire debt, but it decreases since they send the
        // transaction and causes a revert because burning can never decrease the debt below zero.
        //
        // Casts here are safe because it is asserted that debt is greater than zero.
        uint256 credit = amount > uint256(debt) ? uint256(debt) : amount;

        // Update the recipient's debt.
        _updateDebt(recipient, -SafeCast.toInt256(credit));

        // Burn the tokens from the message sender.
        TokenUtils.safeBurnFrom(debtToken, msg.sender, credit);

        // Increase the global amount of mintable debt tokens.
        // Do this after burning instead of before because mint limit increase is an action beneficial to the user.
        _mintingLimiter.increase(credit);

        emit Burn(msg.sender, credit, recipient);

        return credit;
    }

    
    function repay(address underlyingToken, uint256 amount, address recipient) external override lock returns (uint256) {
        _onlyWhitelisted();

        _checkArgument(amount > 0);
        _checkArgument(recipient != address(0));

        _checkSupportedUnderlyingToken(underlyingToken);
        _checkUnderlyingTokenEnabled(underlyingToken);

        // Distribute unlocked credit to depositors.
        _distributeUnlockedCreditDeposited(recipient);

        // Update the recipient's account and decrease the amount of debt incurred.
        _poke(recipient);

        // Check that the debt is greater than zero.
        //
        // It is possible that the amount of debt which is repayable is equal to or less than zero after realizing the
        // credit that was earned since the last update. We do not want to perform a noop so we need to check that the
        // amount of debt to repay is greater than zero.
        int256 debt;
        _checkState((debt = _accounts[recipient].debt) > 0);

        // Determine the maximum amount of underlying tokens that can be repaid.
        //
        // It is implied that this value is greater than zero because `debt` is greater than zero so a noop is not possible
        // beyond this point. Casting the debt to an unsigned integer is also safe because `debt` is greater than zero.
        uint256 maximumAmount = normalizeDebtTokensToUnderlying(underlyingToken, uint256(debt));

        // Limit the number of underlying tokens to repay up to the maximum allowed.
        uint256 actualAmount = amount > maximumAmount ? maximumAmount : amount;

        Limiters.LinearGrowthLimiter storage limiter = _repayLimiters[underlyingToken];

        // Check to make sure that the underlying token repay limit has not been breached.
        uint256 currentRepayLimit = limiter.get();
        if (actualAmount > currentRepayLimit) {
          revert RepayLimitExceeded(underlyingToken, actualAmount, currentRepayLimit);
        }

        uint256 credit = normalizeUnderlyingTokensToDebt(underlyingToken, actualAmount);

        // Update the recipient's debt.
        _updateDebt(recipient, -SafeCast.toInt256(credit));

        // Decrease the amount of the underlying token which is globally available to be repaid.
        limiter.decrease(actualAmount);

        // Transfer the repaid tokens to the transmuter.
        TokenUtils.safeTransferFrom(underlyingToken, msg.sender, transmuter, actualAmount);

        // Inform the transmuter that it has received tokens.
        IERC20TokenReceiver(transmuter).onERC20Received(underlyingToken, actualAmount);

        emit Repay(msg.sender, underlyingToken, actualAmount, recipient, credit);

        return actualAmount;
    }

    
    function liquidate(
        address yieldToken,
        uint256 shares,
        uint256 minimumAmountOut
    ) external override lock returns (uint256) {
        _onlyWhitelisted();

        _checkArgument(shares > 0);

        YieldTokenParams storage yieldTokenParams = _yieldTokens[yieldToken];
        address underlyingToken = yieldTokenParams.underlyingToken;

        _checkSupportedYieldToken(yieldToken);
        _checkYieldTokenEnabled(yieldToken);
        _checkUnderlyingTokenEnabled(underlyingToken);
        _checkLoss(yieldToken);

        // Calculate the unrealized debt.
        //
        // It is possible that the number of debt which is repayable is equal to or less than zero after realizing the
        // credit that was earned since the last update. We do not want to perform a noop so we need to check that the
        // amount of debt to repay is greater than zero.
        int256 unrealizedDebt;
        _checkState((unrealizedDebt = _calculateUnrealizedDebt(msg.sender)) > 0);

        // Determine the maximum amount of shares that can be liquidated from the unrealized debt.
        //
        // It is implied that this value is greater than zero because `debt` is greater than zero. Casting the debt to an
        // unsigned integer is also safe for this reason.
        uint256 maximumShares = convertUnderlyingTokensToShares(
          yieldToken,
          normalizeDebtTokensToUnderlying(underlyingToken, uint256(unrealizedDebt))
        );

        // Limit the number of shares to liquidate up to the maximum allowed.
        uint256 actualShares = shares > maximumShares ? maximumShares : shares;

        // Unwrap the yield tokens that the shares are worth.
        uint256 amountYieldTokens      = convertSharesToYieldTokens(yieldToken, actualShares);
        uint256 amountUnderlyingTokens = _unwrap(yieldToken, amountYieldTokens, address(this), minimumAmountOut);

        // Again, perform another noop check. It is possible that the amount of underlying tokens that were received by
        // unwrapping the yield tokens was zero because the amount of yield tokens to unwrap was too small.
        _checkState(amountUnderlyingTokens > 0);

        Limiters.LinearGrowthLimiter storage limiter = _liquidationLimiters[underlyingToken];

        // Check to make sure that the underlying token liquidation limit has not been breached.
        uint256 liquidationLimit = limiter.get();
        if (amountUnderlyingTokens > liquidationLimit) {
          revert LiquidationLimitExceeded(underlyingToken, amountUnderlyingTokens, liquidationLimit);
        }

        // Buffers any harvestable yield tokens. This will properly synchronize the balance which is held by users
        // and the balance which is held by the system. This is required for `_sync` to function correctly.
        _preemptivelyHarvest(yieldToken);

        // Distribute unlocked credit to depositors.
        _distributeUnlockedCreditDeposited(msg.sender);

        uint256 credit = normalizeUnderlyingTokensToDebt(underlyingToken, amountUnderlyingTokens);

        // Update the message sender's account, proactively burn shares, decrease the amount of debt incurred, and then
        // decrease the value of the token that the system is expected to hold.
        _poke(msg.sender, yieldToken);
        _burnShares(msg.sender, yieldToken, actualShares);
        _updateDebt(msg.sender, -SafeCast.toInt256(credit));
        _sync(yieldToken, amountYieldTokens, _usub);

        // Decrease the amount of the underlying token which is globally available to be liquidated.
        limiter.decrease(amountUnderlyingTokens);

        // Transfer the liquidated tokens to the transmuter.
        TokenUtils.safeTransfer(underlyingToken, transmuter, amountUnderlyingTokens);

        // Inform the transmuter that it has received tokens.
        IERC20TokenReceiver(transmuter).onERC20Received(underlyingToken, amountUnderlyingTokens);

        emit Liquidate(msg.sender, yieldToken, underlyingToken, actualShares, credit);

        return actualShares;
    }

    
    function donate(address yieldToken, uint256 amount) external override lock {
        _onlyWhitelisted();
        _checkArgument(amount > 0);

        // Distribute any unlocked credit so that the accrued weight is up to date.
        _distributeUnlockedCredit(yieldToken);

        // Update the message sender's account. This will assure that any credit that was earned is not overridden.
        _poke(msg.sender);

        uint256 shares = _yieldTokens[yieldToken].totalShares - _accounts[msg.sender].balances[yieldToken];

        _yieldTokens[yieldToken].accruedWeight += amount * FIXED_POINT_SCALAR / shares;
        _accounts[msg.sender].lastAccruedWeights[yieldToken] = _yieldTokens[yieldToken].accruedWeight;

        TokenUtils.safeBurnFrom(debtToken, msg.sender, amount);

        // Increase the global amount of mintable debt tokens.
        // Do this after burning instead of before because mint limit increase is an action beneficial to the user.
        _mintingLimiter.increase(amount);

        emit Donate(msg.sender, yieldToken, amount);
    }

    
    function harvest(address yieldToken, uint256 minimumAmountOut) external override lock {
        _onlyKeeper();
        _checkSupportedYieldToken(yieldToken);

        YieldTokenParams storage yieldTokenParams = _yieldTokens[yieldToken];

        // Buffer any harvestable yield tokens. This will properly synchronize the balance which is held by users
        // and the balance which is held by the system to be harvested during this call.
        _preemptivelyHarvest(yieldToken);

        // Load and proactively clear the amount of harvestable tokens so that future calls do not rely on stale data.
        // Because we cannot call an external unwrap until the amount of harvestable tokens has been calculated,
        // clearing this data immediately prevents any potential reentrancy attacks which would use stale harvest
        // buffer values.
        uint256 harvestableAmount = yieldTokenParams.harvestableBalance;
        yieldTokenParams.harvestableBalance = 0;

        // Check that the harvest will not be a no-op.
        _checkState(harvestableAmount != 0);

        address underlyingToken = yieldTokenParams.underlyingToken;
        uint256 amountUnderlyingTokens = _unwrap(yieldToken, harvestableAmount, address(this), minimumAmountOut);

        // Calculate how much of the unwrapped underlying tokens will be allocated for fees and distributed to users.
        uint256 feeAmount = amountUnderlyingTokens * protocolFee / BPS;
        uint256 distributeAmount = amountUnderlyingTokens - feeAmount;

        uint256 credit = normalizeUnderlyingTokensToDebt(underlyingToken, distributeAmount);

        // Distribute credit to all of the users who hold shares of the yield token.
        _distributeCredit(yieldToken, credit);

        // Transfer the tokens to the fee receiver and transmuter.
        TokenUtils.safeTransfer(underlyingToken, protocolFeeReceiver, feeAmount);
        TokenUtils.safeTransfer(underlyingToken, transmuter, distributeAmount);

        // Inform the transmuter that it has received tokens.
        IERC20TokenReceiver(transmuter).onERC20Received(underlyingToken, distributeAmount);

        emit Harvest(yieldToken, minimumAmountOut, amountUnderlyingTokens, credit);
    }

    
    ///
    
    function _onlyAdmin() internal view {
        if (msg.sender != admin) {
            revert Unauthorized();
        }
    }

    
    ///
    
    ///      {Unauthorized} error.
    function _onlySentinelOrAdmin() internal view {
        // Check if the message sender is the administrator.
        if (msg.sender == admin) {
            return;
        }

        // Check if the message sender is a sentinel. After this check we can revert since we know that it is neither
        // the administrator or a sentinel.
        if (!sentinels[msg.sender]) {
            revert Unauthorized();
        }
    }

    
    ///
    
    function _onlyKeeper() internal view {
        if (!keepers[msg.sender]) {
            revert Unauthorized();
        }
    }

    
    ///
    
    function _onlyTransferAdapter() internal view {
        if (msg.sender != transferAdapter) {
            revert Unauthorized();
        }
    }

    
    ///
    
    function _preemptivelyHarvestDeposited(address owner) internal {
        Sets.AddressSet storage depositedTokens = _accounts[owner].depositedTokens;
        for (uint256 i = 0; i < depositedTokens.values.length; ++i) {
            _preemptivelyHarvest(depositedTokens.values[i]);
        }
    }

    
    ///
    
    ///      greater than the expected value. The purpose of this function is to synchronize the balance of the yield
    ///      token which is held by users versus tokens which will be seized by the protocol.
    ///
    
    function _preemptivelyHarvest(address yieldToken) internal {
        uint256 activeBalance = _yieldTokens[yieldToken].activeBalance;
        if (activeBalance == 0) {
            return;
        }

        uint256 currentValue = convertYieldTokensToUnderlying(yieldToken, activeBalance);
        uint256 expectedValue = _yieldTokens[yieldToken].expectedValue;
        if (currentValue <= expectedValue) {
            return;
        }

        uint256 harvestable = convertUnderlyingTokensToYield(yieldToken, currentValue - expectedValue);
        if (harvestable == 0) {
            return;
        }
        _yieldTokens[yieldToken].activeBalance -= harvestable;
        _yieldTokens[yieldToken].harvestableBalance += harvestable;
    }

    
    ///
    
    function _checkYieldTokenEnabled(address yieldToken) internal view {
        if (!_yieldTokens[yieldToken].enabled) {
          revert TokenDisabled(yieldToken);
        }
    }

    
    ///
    
    function _checkUnderlyingTokenEnabled(address underlyingToken) internal view {
        if (!_underlyingTokens[underlyingToken].enabled) {
          revert TokenDisabled(underlyingToken);
        }
    }

    
    ///
    /// If the address is not a supported yield token, this function will revert using a {UnsupportedToken} error.
    ///
    
    function _checkSupportedYieldToken(address yieldToken) internal view {
        if (!_supportedYieldTokens.contains(yieldToken)) {
            revert UnsupportedToken(yieldToken);
        }
    }

    
    ///
    /// If the address is not a supported yield token, this function will revert using a {UnsupportedToken} error.
    ///
    
    function _checkSupportedUnderlyingToken(address underlyingToken) internal view {
        if (!_supportedUnderlyingTokens.contains(underlyingToken)) {
            revert UnsupportedToken(underlyingToken);
        }
    }

    
    ///
    
    ///      {MintingLimitExceeded} error.
    ///
    
    function _checkMintingLimit(uint256 amount) internal view {
        uint256 limit = _mintingLimiter.get();
        if (amount > limit) {
            revert MintingLimitExceeded(amount, limit);
        }
    }

    
    ///
    
    ///      revert with a {LossExceeded} error.
    ///
    
    function _checkLoss(address yieldToken) internal view {
        uint256 loss = _loss(yieldToken);
        uint256 maximumLoss = _yieldTokens[yieldToken].maximumLoss;
        if (loss > maximumLoss) {
            revert LossExceeded(yieldToken, loss, maximumLoss);
        }
    }

    
    ///
    
    ///
    
    
    
    ///
    
    function _deposit(
        address yieldToken,
        uint256 amount,
        address recipient
    ) internal returns (uint256) {
        _checkArgument(amount > 0);

        YieldTokenParams storage yieldTokenParams = _yieldTokens[yieldToken];
        address underlyingToken = yieldTokenParams.underlyingToken;

        // Check that the yield token and it's underlying token are enabled. Disabling the yield token and or the
        // underlying token prevents the system from holding more of the disabled yield token or underlying token.
        _checkYieldTokenEnabled(yieldToken);
        _checkUnderlyingTokenEnabled(underlyingToken);

        // Check to assure that the token has not experienced a sudden unexpected loss. This prevents users from being
        // able to deposit funds and then have them siphoned if the price recovers.
        _checkLoss(yieldToken);

        // Buffers any harvestable yield tokens. This will properly synchronize the balance which is held by users
        // and the balance which is held by the system to eventually be harvested.
        _preemptivelyHarvest(yieldToken);

        // Distribute unlocked credit to depositors.
        _distributeUnlockedCreditDeposited(recipient);

        // Update the recipient's account, proactively issue shares for the deposited tokens to the recipient, and then
        // increase the value of the token that the system is expected to hold.
        _poke(recipient, yieldToken);
        uint256 shares = _issueSharesForAmount(recipient, yieldToken, amount);
        _sync(yieldToken, amount, _uadd);

        // Check that the maximum expected value has not been breached.
        uint256 maximumExpectedValue = yieldTokenParams.maximumExpectedValue;
        if (yieldTokenParams.expectedValue > maximumExpectedValue) {
          revert ExpectedValueExceeded(yieldToken, amount, maximumExpectedValue);
        }

        emit Deposit(msg.sender, yieldToken, amount, recipient);

        return shares;
    }

    
    ///      equivalent value.
    ///
    
    ///
    
    
    
    
    ///
    
    function _withdraw(
        address yieldToken,
        address owner,
        uint256 shares,
        address recipient
    ) internal returns (uint256) {
        // Buffers any harvestable yield tokens that the owner of the account has deposited. This will properly
        // synchronize the balance of all the tokens held by the owner so that the validation check properly
        // computes the total value of the tokens held by the owner.
        _preemptivelyHarvestDeposited(owner);

        // Distribute unlocked credit for all of the tokens that the user has deposited into the system. This updates
        // the accrued weights so that the debt is properly calculated before the account is validated.
        _distributeUnlockedCreditDeposited(owner);

        uint256 amountYieldTokens = convertSharesToYieldTokens(yieldToken, shares);

        // Update the owner's account, burn shares from the owner's account, and then decrease the value of the token
        // that the system is expected to hold.
        _poke(owner);
        _burnShares(owner, yieldToken, shares);
        _sync(yieldToken, amountYieldTokens, _usub);

        // Valid the owner's account to assure that the collateralization invariant is still held.
        _validate(owner);

        emit Withdraw(owner, yieldToken, shares, recipient);

        return amountYieldTokens;
    }

    
    ///
    
    ///
    
    
    
    function _mint(address owner, uint256 amount, address recipient) internal {
        // Check that the system will allow for the specified amount to be minted.
        _checkMintingLimit(amount);

        // Preemptively harvest all tokens that the user has deposited into the system. This allows the debt to be
        // properly calculated before the account is validated.
        _preemptivelyHarvestDeposited(owner);

        // Distribute unlocked credit for all of the tokens that the user has deposited into the system. This updates
        // the accrued weights so that the debt is properly calculated before the account is validated.
        _distributeUnlockedCreditDeposited(owner);

        // Update the owner's account, increase their debt by the amount of tokens to mint, and then finally validate
        // their account to assure that the collateralization invariant is still held.
        _poke(owner);
        _updateDebt(owner, SafeCast.toInt256(amount));
        _validate(owner);

        // Decrease the global amount of mintable debt tokens.
        _mintingLimiter.decrease(amount);

        // Mint the debt tokens to the recipient.
        TokenUtils.safeMint(debtToken, recipient, amount);

        emit Mint(owner, amount, recipient);
    }

    
    ///
    
    
    
    function _sync(
        address yieldToken,
        uint256 amount,
        function(uint256, uint256) internal pure returns (uint256) operation
    ) internal {
        YieldTokenParams memory yieldTokenParams = _yieldTokens[yieldToken];

        uint256 amountUnderlyingTokens = convertYieldTokensToUnderlying(yieldToken, amount);
        uint256 updatedActiveBalance   = operation(yieldTokenParams.activeBalance, amount);
        uint256 updatedExpectedValue   = operation(yieldTokenParams.expectedValue, amountUnderlyingTokens);

        _yieldTokens[yieldToken].activeBalance = updatedActiveBalance;
        _yieldTokens[yieldToken].expectedValue = updatedExpectedValue;
    }

    
    ///      underlying value is less than the actual value, this will return zero.
    ///
    
    ///
    
    function _loss(address yieldToken) internal view returns (uint256) {
        YieldTokenParams memory yieldTokenParams = _yieldTokens[yieldToken];

        uint256 amountUnderlyingTokens = convertYieldTokensToUnderlying(yieldToken, yieldTokenParams.activeBalance);
        uint256 expectedUnderlyingValue = yieldTokenParams.expectedValue;

        return expectedUnderlyingValue > amountUnderlyingTokens
            ? ((expectedUnderlyingValue - amountUnderlyingTokens) * BPS) / expectedUnderlyingValue
            : 0;
    }

    
    ///
    
    
    function _distributeCredit(address yieldToken, uint256 amount) internal {
        YieldTokenParams storage yieldTokenParams = _yieldTokens[yieldToken];

        uint256 pendingCredit     = yieldTokenParams.pendingCredit;
        uint256 distributedCredit = yieldTokenParams.distributedCredit;
        uint256 unlockedCredit    = _calculateUnlockedCredit(yieldToken);
        uint256 lockedCredit      = pendingCredit - (distributedCredit + unlockedCredit);

        // Distribute any unlocked credit before overriding it.
        if (unlockedCredit > 0) {
            yieldTokenParams.accruedWeight += unlockedCredit * FIXED_POINT_SCALAR / yieldTokenParams.totalShares;
        }

        yieldTokenParams.pendingCredit         = amount + lockedCredit;
        yieldTokenParams.distributedCredit     = 0;
        yieldTokenParams.lastDistributionBlock = block.number;
    }

    
    ///      by `owner`.
    ///
    
    function _distributeUnlockedCreditDeposited(address owner) internal {
        Sets.AddressSet storage depositedTokens = _accounts[owner].depositedTokens;
        for (uint256 i = 0; i < depositedTokens.values.length; ++i) {
            _distributeUnlockedCredit(depositedTokens.values[i]);
        }
    }

    
    ///
    
    function _distributeUnlockedCredit(address yieldToken) internal {
        YieldTokenParams storage yieldTokenParams = _yieldTokens[yieldToken];

        uint256 unlockedCredit = _calculateUnlockedCredit(yieldToken);
        if (unlockedCredit == 0) {
            return;
        }

        yieldTokenParams.accruedWeight     += unlockedCredit * FIXED_POINT_SCALAR / yieldTokenParams.totalShares;
        yieldTokenParams.distributedCredit += unlockedCredit;
    }

    
    ///
    
    
    
    ///
    
    function _wrap(
        address yieldToken,
        uint256 amount,
        uint256 minimumAmountOut
    ) internal returns (uint256) {
        YieldTokenParams storage yieldTokenParams = _yieldTokens[yieldToken];

        ITokenAdapter adapter = ITokenAdapter(yieldTokenParams.adapter);
        address underlyingToken = yieldTokenParams.underlyingToken;

        TokenUtils.safeTransferFrom(underlyingToken, msg.sender, address(this), amount);
        uint256 wrappedShares = adapter.wrap(amount, address(this));
        if (wrappedShares < minimumAmountOut) {
            revert SlippageExceeded(wrappedShares, minimumAmountOut);
        }

        return wrappedShares;
    }

    
    ///
    
    
    
    
    ///                         operation.
    ///
    
    function _unwrap(
        address yieldToken,
        uint256 amount,
        address recipient,
        uint256 minimumAmountOut
    ) internal returns (uint256) {
        ITokenAdapter adapter = ITokenAdapter(_yieldTokens[yieldToken].adapter);
        uint256 amountUnwrapped = adapter.unwrap(amount, recipient);
        if (amountUnwrapped < minimumAmountOut) {
            revert SlippageExceeded(amountUnwrapped, minimumAmountOut);
        }
        return amountUnwrapped;
    }

    
    ///
    
    function _poke(address owner) internal {
        Sets.AddressSet storage depositedTokens = _accounts[owner].depositedTokens;
        for (uint256 i = 0; i < depositedTokens.values.length; ++i) {
            _poke(owner, depositedTokens.values[i]);
        }
    }

    
    ///
    
    
    function _poke(address owner, address yieldToken) internal {
        Account storage account = _accounts[owner];

        uint256 currentAccruedWeight = _yieldTokens[yieldToken].accruedWeight;
        uint256 lastAccruedWeight    = account.lastAccruedWeights[yieldToken];

        if (currentAccruedWeight == lastAccruedWeight) {
            return;
        }

        uint256 balance          = account.balances[yieldToken];
        uint256 unrealizedCredit = (currentAccruedWeight - lastAccruedWeight) * balance / FIXED_POINT_SCALAR;

        account.debt                           -= SafeCast.toInt256(unrealizedCredit);
        account.lastAccruedWeights[yieldToken]  = currentAccruedWeight;
    }

    
    ///
    
    
    function _updateDebt(address owner, int256 amount) internal {
        Account storage account = _accounts[owner];
        account.debt += amount;
    }

    
    ///
    
    
    
    function _approveMint(address owner, address spender, uint256 amount) internal {
        Account storage account = _accounts[owner];
        account.mintAllowances[spender] = amount;
        emit ApproveMint(owner, spender, amount);
    }

    
    ///
    
    
    
    function _decreaseMintAllowance(address owner, address spender, uint256 amount) internal {
        Account storage account = _accounts[owner];
        account.mintAllowances[spender] -= amount;
    }

    
    ///
    
    
    
    
    function _approveWithdraw(address owner, address spender, address yieldToken, uint256 shares) internal {
        Account storage account = _accounts[owner];
        account.withdrawAllowances[spender][yieldToken] = shares;
        emit ApproveWithdraw(owner, spender, yieldToken, shares);
    }

    
    ///
    
    
    
    
    function _decreaseWithdrawAllowance(address owner, address spender, address yieldToken, uint256 amount) internal {
        Account storage account = _accounts[owner];
        account.withdrawAllowances[spender][yieldToken] -= amount;
    }

    
    ///
    
    ///
    
    function _validate(address owner) internal view {
        int256 debt = _accounts[owner].debt;
        if (debt <= 0) {
            return;
        }

        uint256 collateralization = totalValue(owner) * FIXED_POINT_SCALAR / uint256(debt);

        if (collateralization < minimumCollateralization) {
            revert Undercollateralized();
        }
    }

    
    ///
    
    ///
    
    function totalValue(address owner) public view returns (uint256) {
        uint256 totalValue = 0;

        Sets.AddressSet storage depositedTokens = _accounts[owner].depositedTokens;
        for (uint256 i = 0; i < depositedTokens.values.length; ++i) {
            address yieldToken             = depositedTokens.values[i];
            address underlyingToken        = _yieldTokens[yieldToken].underlyingToken;
            uint256 shares                 = _accounts[owner].balances[yieldToken];
            uint256 amountUnderlyingTokens = convertSharesToUnderlyingTokens(yieldToken, shares);

            totalValue += normalizeUnderlyingTokensToDebt(underlyingToken, amountUnderlyingTokens);
        }

        return totalValue;
    }

    
    ///
    /// IMPORTANT: `amount` must never be 0.
    ///
    
    
    
    ///
    
    function _issueSharesForAmount(
        address recipient,
        address yieldToken,
        uint256 amount
    ) internal returns (uint256) {
        uint256 shares = convertYieldTokensToShares(yieldToken, amount);

        if (_accounts[recipient].balances[yieldToken] == 0) {
          _accounts[recipient].depositedTokens.add(yieldToken);
        }

        _accounts[recipient].balances[yieldToken] += shares;
        _yieldTokens[yieldToken].totalShares += shares;

        return shares;
    }

    
    ///
    
    
    
    function _burnShares(address owner, address yieldToken, uint256 shares) internal {
        Account storage account = _accounts[owner];

        account.balances[yieldToken] -= shares;
        _yieldTokens[yieldToken].totalShares -= shares;

        if (account.balances[yieldToken] == 0) {
            account.depositedTokens.remove(yieldToken);
        }
    }

    
    ///
    
    ///
    
    function _calculateUnrealizedDebt(address owner) internal view returns (int256) {
        int256 debt = _accounts[owner].debt;

        Sets.AddressSet storage depositedTokens = _accounts[owner].depositedTokens;
        for (uint256 i = 0; i < depositedTokens.values.length; ++i) {
            address yieldToken = depositedTokens.values[i];

            uint256 currentAccruedWeight = _yieldTokens[yieldToken].accruedWeight;
            uint256 lastAccruedWeight    = _accounts[owner].lastAccruedWeights[yieldToken];
            uint256 unlockedCredit       = _calculateUnlockedCredit(yieldToken);

            currentAccruedWeight += unlockedCredit > 0
                ? unlockedCredit * FIXED_POINT_SCALAR / _yieldTokens[yieldToken].totalShares
                : 0;

            if (currentAccruedWeight == lastAccruedWeight) {
                continue;
            }

            uint256 balance = _accounts[owner].balances[yieldToken];
            uint256 unrealizedCredit = ((currentAccruedWeight - lastAccruedWeight) * balance) / FIXED_POINT_SCALAR;

            debt -= SafeCast.toInt256(unrealizedCredit);
        }

        return debt;
    }

    
    ///
    
    ///
    
    ///
    
    function _calculateUnrealizedActiveBalance(address yieldToken) internal view returns (uint256) {
        YieldTokenParams storage yieldTokenParams = _yieldTokens[yieldToken];

        uint256 activeBalance = yieldTokenParams.activeBalance;
        if (activeBalance == 0) {
          return activeBalance;
        }

        uint256 currentValue = convertYieldTokensToUnderlying(yieldToken, activeBalance);
        uint256 expectedValue = yieldTokenParams.expectedValue;
        if (currentValue <= expectedValue) {
          return activeBalance;
        }

        uint256 harvestable = convertUnderlyingTokensToYield(yieldToken, currentValue - expectedValue);
        if (harvestable == 0) {
          return activeBalance;
        }

        return activeBalance - harvestable;
    }

    
    ///
    
    ///
    
    function _calculateUnlockedCredit(address yieldToken) internal view returns (uint256) {
        YieldTokenParams storage yieldTokenParams = _yieldTokens[yieldToken];

        uint256 pendingCredit = yieldTokenParams.pendingCredit;
        if (pendingCredit == 0) {
            return 0;
        }

        uint256 creditUnlockRate      = yieldTokenParams.creditUnlockRate;
        uint256 distributedCredit     = yieldTokenParams.distributedCredit;
        uint256 lastDistributionBlock = yieldTokenParams.lastDistributionBlock;

        uint256 percentUnlocked = (block.number - lastDistributionBlock) * creditUnlockRate;

        return percentUnlocked < FIXED_POINT_SCALAR
            ? (pendingCredit * percentUnlocked / FIXED_POINT_SCALAR) - distributedCredit
            : pendingCredit - distributedCredit;
    }

    
    ///
    
    
    ///
    
    function convertYieldTokensToShares(address yieldToken, uint256 amount) public view returns (uint256) {
        if (_yieldTokens[yieldToken].totalShares == 0) {
            return amount;
        }
        return amount * _yieldTokens[yieldToken].totalShares / _calculateUnrealizedActiveBalance(yieldToken);
    }

    
    ///
    
    
    ///
    
    function convertSharesToYieldTokens(address yieldToken, uint256 shares) public view returns (uint256) {
        uint256 totalShares = _yieldTokens[yieldToken].totalShares;
        if (totalShares == 0) {
          return shares;
        }
        return (shares * _calculateUnrealizedActiveBalance(yieldToken)) / totalShares;
    }

    
    ///
    
    
    ///
    
    function convertSharesToUnderlyingTokens(address yieldToken, uint256 shares) public view returns (uint256) {
        uint256 amountYieldTokens = convertSharesToYieldTokens(yieldToken, shares);
        return convertYieldTokensToUnderlying(yieldToken, amountYieldTokens);
    }

    
    ///
    
    
    ///
    
    function convertYieldTokensToUnderlying(address yieldToken, uint256 amount) public view returns (uint256) {
        YieldTokenParams storage yieldTokenParams = _yieldTokens[yieldToken];
        ITokenAdapter adapter = ITokenAdapter(yieldTokenParams.adapter);
        return amount * adapter.price() / 10**yieldTokenParams.decimals;
    }

    
    ///
    
    
    ///
    
    function convertUnderlyingTokensToYield(address yieldToken, uint256 amount) public view returns (uint256) {
        YieldTokenParams storage yieldTokenParams = _yieldTokens[yieldToken];
        ITokenAdapter adapter = ITokenAdapter(yieldTokenParams.adapter);
        return amount * 10**yieldTokenParams.decimals / adapter.price();
    }

    
    ///
    
    
    ///
    
    function convertUnderlyingTokensToShares(address yieldToken, uint256 amount) public view returns (uint256) {
        uint256 amountYieldTokens = convertUnderlyingTokensToYield(yieldToken, amount);
        return convertYieldTokensToShares(yieldToken, amountYieldTokens);
    }

    
    ///
    
    
    ///
    
    function normalizeUnderlyingTokensToDebt(address underlyingToken, uint256 amount) public view returns (uint256) {
        return amount * _underlyingTokens[underlyingToken].conversionFactor;
    }

    
    ///
    
    ///      truncation amount will be the least significant N digits where N is the difference in decimals between
    ///      the debt token and the underlying token.
    ///
    
    
    ///
    
    function normalizeDebtTokensToUnderlying(address underlyingToken, uint256 amount) public view returns (uint256) {
        return amount / _underlyingTokens[underlyingToken].conversionFactor;
    }

    
    ///
    /// Reverts if msg.sender is not in the whitelist.
    function _onlyWhitelisted() internal view {
        // Check if the message sender is an EOA. In the future, this potentially may break. It is important that functions
        // which rely on the whitelist not be explicitly vulnerable in the situation where this no longer holds true.
        if (tx.origin == msg.sender) {
          return;
        }

        // Only check the whitelist for calls from contracts.
        if (!IWhitelist(whitelist).isWhitelisted(msg.sender)) {
          revert Unauthorized();
        }
    }

    
    ///
    
    function _checkArgument(bool expression) internal pure {
        if (!expression) {
            revert IllegalArgument();
        }
    }

    
    ///
    
    function _checkState(bool expression) internal pure {
        if (!expression) {
            revert IllegalState();
        }
    }

    
    ///
    
    ///
    
    
    ///
    
    function _uadd(uint256 x, uint256 y) internal pure returns (uint256 z) { z = x + y; }

    
    ///
    
    ///
    
    
    ///
    
    function _usub(uint256 x, uint256 y) internal pure returns (uint256 z) { z = x - y; }
}