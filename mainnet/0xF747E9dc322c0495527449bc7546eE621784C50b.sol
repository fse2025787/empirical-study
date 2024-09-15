// SPDX-License-Identifier: GPL-2.0-or-later


pragma solidity >=0.5.0;



interface IERC20Minimal {
    
    ///
    
    
    
    event Transfer(address indexed owner, address indexed recipient, uint256 amount);

    
    ///
    
    
    
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    
    ///
    
    function totalSupply() external view returns (uint256);

    
    ///
    
    ///
    
    function balanceOf(address account) external view returns (uint256);

    
    ///
    
    
    ///
    
    function allowance(address owner, address spender) external view returns (uint256);

    
    ///
    
    ///
    
    
    ///
    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    ///
    
    ///
    
    
    ///
    
    function approve(address spender, uint256 amount) external returns (bool);

    
    ///
    
    
    ///
    
    
    
    ///
    
    function transferFrom(address owner, address recipient, uint256 amount) external returns (bool);
}

// 
pragma solidity >=0.5.0;



///


interface IMulticall {
    
    ///
    
    
    error MulticallFailed(bytes data, bytes result);

    
    ///
    
    ///
    
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);
}

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
    
    
    function sweepTokens(address rewardToken, uint256 amount) external ;
}

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

pragma solidity >=0.5.0;



interface IAlchemistV2Immutables {
    
    ///
    
    function version() external view returns (string memory);

    
    ///
    
    function debtToken() external view returns (address);
}

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
    
    
    event SweepTokens(address indexed rewardToken, uint256 amount);

    
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

// 
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

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
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * 
 * constructor() initializer {}
 * ```
 * ====
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

pragma solidity ^0.8.11;


///         `msg.origin` is not authorized.
error Unauthorized();


///         or entered an illegal condition which is not recoverable from.
error IllegalState();


///         to the function.
error IllegalArgument();

// 
pragma solidity ^0.8.11;





///

abstract contract Multicall is IMulticall {
    
    function multicall(bytes[] calldata data) external payable override returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                revert MulticallFailed(data[i], result);
            }

            results[i] = result;
        }
    }
}

// 
pragma solidity ^0.8.11;



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

pragma solidity >=0.5.0;










interface IAlchemistV2 is
    IAlchemistV2Actions,
    IAlchemistV2AdminActions,
    IAlchemistV2Errors,
    IAlchemistV2Immutables,
    IAlchemistV2Events,
    IAlchemistV2State
{ }

pragma solidity >=0.5.0;





interface IERC20Burnable is IERC20Minimal {
    
    ///
    
    ///
    
    function burn(uint256 amount) external returns (bool);

    
    ///
    
    
    ///
    
    function burnFrom(address owner, uint256 amount) external returns (bool);
}

pragma solidity >=0.5.0;





interface IERC20Mintable is IERC20Minimal {
    
    ///
    
    
    ///
    
    function mint(address recipient, uint256 amount) external returns (bool);
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
pragma solidity ^0.8.11;






















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

    
    uint256 public constant BPS = 10000;

    
    ///         implementation have 18 decimals of resolution, meaning that 1 is represented as 1e18, 0.5 is
    ///         represented as 5e17, and 2 is represented as 2e18.
    uint256 public constant FIXED_POINT_SCALAR = 1e18;

    
    string public constant override version = "2.2.7";

    
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

    constructor() initializer {}

    
    function getYieldTokensPerShare(address yieldToken) external view override returns (uint256) {
        return _convertSharesToYieldTokens(yieldToken, 10**_yieldTokens[yieldToken].decimals);
    }

    
    function getUnderlyingTokensPerShare(address yieldToken) external view override returns (uint256) {
        return _convertSharesToUnderlyingTokens(yieldToken, 10**_yieldTokens[yieldToken].decimals);
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
        emit ProtocolFeeReceiverUpdated(protocolFeeReceiver);
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

        uint256 expectedValue = _convertYieldTokensToUnderlying(yieldToken, _yieldTokens[yieldToken].activeBalance);

        _yieldTokens[yieldToken].expectedValue = expectedValue;

        emit Snap(yieldToken, expectedValue);
    }

    
    function sweepTokens(address rewardToken, uint256 amount) external override lock {
        _onlyAdmin();

        if (_supportedYieldTokens.contains(rewardToken)) {
            revert UnsupportedToken(rewardToken);
        }

        if (_supportedUnderlyingTokens.contains(rewardToken)) {
            revert UnsupportedToken(rewardToken);
        }

        TokenUtils.safeTransfer(rewardToken, admin, amount);

        emit SweepTokens(rewardToken, amount);
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
        uint256 maximumAmount = _normalizeDebtTokensToUnderlying(underlyingToken, uint256(debt));

        // Limit the number of underlying tokens to repay up to the maximum allowed.
        uint256 actualAmount = amount > maximumAmount ? maximumAmount : amount;

        Limiters.LinearGrowthLimiter storage limiter = _repayLimiters[underlyingToken];

        // Check to make sure that the underlying token repay limit has not been breached.
        uint256 currentRepayLimit = limiter.get();
        if (actualAmount > currentRepayLimit) {
          revert RepayLimitExceeded(underlyingToken, actualAmount, currentRepayLimit);
        }

        uint256 credit = _normalizeUnderlyingTokensToDebt(underlyingToken, actualAmount);

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
        uint256 maximumShares = _convertUnderlyingTokensToShares(
          yieldToken,
          _normalizeDebtTokensToUnderlying(underlyingToken, uint256(unrealizedDebt))
        );

        // Limit the number of shares to liquidate up to the maximum allowed.
        uint256 actualShares = shares > maximumShares ? maximumShares : shares;

        // Unwrap the yield tokens that the shares are worth.
        uint256 amountYieldTokens      = _convertSharesToYieldTokens(yieldToken, actualShares);
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

        uint256 credit = _normalizeUnderlyingTokensToDebt(underlyingToken, amountUnderlyingTokens);

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
        _checkArgument(amount != 0);

        // Distribute any unlocked credit so that the accrued weight is up to date.
        _distributeUnlockedCredit(yieldToken);

        // Update the message sender's account. This will assure that any credit that was earned is not overridden.
        _poke(msg.sender);

        uint256 shares = _yieldTokens[yieldToken].totalShares - _accounts[msg.sender].balances[yieldToken];

        _yieldTokens[yieldToken].accruedWeight += amount * FIXED_POINT_SCALAR / shares;
        _accounts[msg.sender].lastAccruedWeights[yieldToken] = _yieldTokens[yieldToken].accruedWeight;

        TokenUtils.safeBurnFrom(debtToken, msg.sender, amount);

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

        uint256 credit = _normalizeUnderlyingTokensToDebt(underlyingToken, distributeAmount);

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
    
    function _preemptivelyHarvestDeposited(address owner) internal {
        Sets.AddressSet storage depositedTokens = _accounts[owner].depositedTokens;
        for (uint256 i = 0; i < depositedTokens.values.length; i++) {
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

        uint256 currentValue = _convertYieldTokensToUnderlying(yieldToken, activeBalance);
        uint256 expectedValue = _yieldTokens[yieldToken].expectedValue;
        if (currentValue <= expectedValue) {
            return;
        }

        uint256 harvestable = _convertUnderlyingTokensToYield(yieldToken, currentValue - expectedValue);
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

        uint256 amountYieldTokens = _convertSharesToYieldTokens(yieldToken, shares);

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

        uint256 amountUnderlyingTokens = _convertYieldTokensToUnderlying(yieldToken, amount);
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

        uint256 amountUnderlyingTokens = _convertYieldTokensToUnderlying(yieldToken, yieldTokenParams.activeBalance);
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
        for (uint256 i = 0; i < depositedTokens.values.length; i++) {
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
        for (uint256 i = 0; i < depositedTokens.values.length; i++) {
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

        uint256 collateralization = _totalValue(owner) * FIXED_POINT_SCALAR / uint256(debt);

        if (collateralization < minimumCollateralization) {
            revert Undercollateralized();
        }
    }

    
    ///
    
    ///
    
    function _totalValue(address owner) internal view returns (uint256) {
        uint256 totalValue = 0;

        Sets.AddressSet storage depositedTokens = _accounts[owner].depositedTokens;
        for (uint256 i = 0; i < depositedTokens.values.length; i++) {
            address yieldToken             = depositedTokens.values[i];
            address underlyingToken        = _yieldTokens[yieldToken].underlyingToken;
            uint256 shares                 = _accounts[owner].balances[yieldToken];
            uint256 amountUnderlyingTokens = _convertSharesToUnderlyingTokens(yieldToken, shares);

            totalValue += _normalizeUnderlyingTokensToDebt(underlyingToken, amountUnderlyingTokens);
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
        uint256 shares = _convertYieldTokensToShares(yieldToken, amount);

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
        for (uint256 i = 0; i < depositedTokens.values.length; i++) {
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

        uint256 currentValue = _convertYieldTokensToUnderlying(yieldToken, activeBalance);
        uint256 expectedValue = yieldTokenParams.expectedValue;
        if (currentValue <= expectedValue) {
          return activeBalance;
        }

        uint256 harvestable = _convertUnderlyingTokensToYield(yieldToken, currentValue - expectedValue);
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
    
    function _convertYieldTokensToShares(address yieldToken, uint256 amount) internal view returns (uint256) {
        if (_yieldTokens[yieldToken].totalShares == 0) {
            return amount;
        }
        return amount * _yieldTokens[yieldToken].totalShares / _calculateUnrealizedActiveBalance(yieldToken);
    }

    
    ///
    
    
    ///
    
    function _convertSharesToYieldTokens(address yieldToken, uint256 shares) internal view returns (uint256) {
        uint256 totalShares = _yieldTokens[yieldToken].totalShares;
        if (totalShares == 0) {
          return shares;
        }
        return (shares * _calculateUnrealizedActiveBalance(yieldToken)) / totalShares;
    }

    
    ///
    
    
    ///
    
    function _convertSharesToUnderlyingTokens(address yieldToken, uint256 shares) internal view returns (uint256) {
        uint256 amountYieldTokens = _convertSharesToYieldTokens(yieldToken, shares);
        return _convertYieldTokensToUnderlying(yieldToken, amountYieldTokens);
    }

    
    ///
    
    
    ///
    
    function _convertYieldTokensToUnderlying(address yieldToken, uint256 amount) internal view returns (uint256) {
        YieldTokenParams storage yieldTokenParams = _yieldTokens[yieldToken];
        ITokenAdapter adapter = ITokenAdapter(yieldTokenParams.adapter);
        return amount * adapter.price() / 10**yieldTokenParams.decimals;
    }

    
    ///
    
    
    ///
    
    function _convertUnderlyingTokensToYield(address yieldToken, uint256 amount) internal view returns (uint256) {
        YieldTokenParams storage yieldTokenParams = _yieldTokens[yieldToken];
        ITokenAdapter adapter = ITokenAdapter(yieldTokenParams.adapter);
        return amount * 10**yieldTokenParams.decimals / adapter.price();
    }

    
    ///
    
    
    ///
    
    function _convertUnderlyingTokensToShares(address yieldToken, uint256 amount) internal view returns (uint256) {
        uint256 amountYieldTokens = _convertUnderlyingTokensToYield(yieldToken, amount);
        return _convertYieldTokensToShares(yieldToken, amountYieldTokens);
    }

    
    ///
    
    
    ///
    
    function _normalizeUnderlyingTokensToDebt(address underlyingToken, uint256 amount) internal view returns (uint256) {
        return amount * _underlyingTokens[underlyingToken].conversionFactor;
    }

    
    ///
    
    ///      truncation amount will be the least significant N digits where N is the difference in decimals between
    ///      the debt token and the underlying token.
    ///
    
    
    ///
    
    function _normalizeDebtTokensToUnderlying(address underlyingToken, uint256 amount) internal view returns (uint256) {
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

pragma solidity >=0.5.0;



interface IERC20TokenReceiver {
    
    ///
    
    
    function onERC20Received(address token, uint256 value) external;
}

pragma solidity >=0.5.0;



interface ITokenAdapter {
    
    ///
    
    function version() external view returns (string memory);

    
    ///
    
    function token() external view returns (address);

    
    ///
    
    function underlyingToken() external view returns (address);

    
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

// 
pragma solidity >=0.5.0;







interface IAlchemicToken is IERC20Minimal, IERC20Burnable, IERC20Mintable {
  
  ///
  
  ///
  
  function hasMinted(address account) external view returns (uint256);

  
  ///
  /// This reverts if the `msg.sender` is not whitelisted.
  ///
  
  function lowerHasMinted(uint256 amount) external;
}

pragma solidity ^0.8.11;







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

// 
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

pragma solidity ^0.8.11;



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

pragma solidity ^0.8.11;








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

        if (!success || data.length < 32) {
            revert ERC20CallFailed(token, success, data);
        }

        return abi.decode(data, (uint8));
    }

    
    ///
    
    ///
    
    
    ///
    
    function safeBalanceOf(address token, address account) internal view returns (uint256) {
        (bool success, bytes memory data) = token.staticcall(
            abi.encodeWithSelector(IERC20Minimal.balanceOf.selector, account)
        );

        if (!success || data.length < 32) {
            revert ERC20CallFailed(token, success, data);
        }

        return abi.decode(data, (uint256));
    }

    
    ///
    
    ///
    
    
    
    function safeTransfer(address token, address recipient, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Minimal.transfer.selector, recipient, amount)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///
    
    
    
    function safeApprove(address token, address spender, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Minimal.approve.selector, spender, value)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///
    
    
    
    
    function safeTransferFrom(address token, address owner, address recipient, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Minimal.transferFrom.selector, owner, recipient, amount)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///
    
    
    
    function safeMint(address token, address recipient, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Mintable.mint.selector, recipient, amount)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
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

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///
    
    
    
    function safeBurnFrom(address token, address owner, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Burnable.burnFrom.selector, owner, amount)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }
}

pragma solidity ^0.8.11;





library Limiters {
    using Limiters for LinearGrowthLimiter;

    
    
    uint256 constant public MAX_COOLDOWN_BLOCKS = 7200;

    
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

// 
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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
        assembly {
            size := extcodesize(account)
        }
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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
}

// 
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;



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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity >=0.5.0;



interface IERC20Metadata {
    
    ///
    
    function name() external view returns (string memory);

    
    ///
    
    function symbol() external view returns (string memory);

    
    ///
    
    function decimals() external view returns (uint8);
}