// SPDX-License-Identifier: MIT


// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;


enum AdapterType {
    ABSTRACT,
    UNISWAP_V2_ROUTER,
    UNISWAP_V3_ROUTER,
    CURVE_V1_EXCHANGE_ONLY,
    YEARN_V2,
    CURVE_V1_2ASSETS,
    CURVE_V1_3ASSETS,
    CURVE_V1_4ASSETS,
    CURVE_V1_STECRV_POOL,
    CURVE_V1_WRAPPER,
    CONVEX_V1_BASE_REWARD_POOL,
    CONVEX_V1_BOOSTER,
    CONVEX_V1_CLAIM_ZAP,
    LIDO_V1,
    UNIVERSAL,
    LIDO_WSTETH_V1
}

interface IAdapterExceptions {
    
    ///      that is not recognized as collateral in the connected
    ///      Credit Manager
    error TokenIsNotInAllowedList(address);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;


interface IPriceOracleV2Events {
    
    event NewPriceFeed(address indexed token, address indexed priceFeed);
}

interface IPriceOracleV2Exceptions {
    
    error ZeroPriceException();

    
    error ChainPriceStaleException();

    
    error PriceOracleNotExistsException();
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;



interface IVersion {
    
    function version() external view returns (uint256);
}
// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;



struct RevocationPair {
    address spender;
    address token;
}

interface IUniversalAdapterExceptions {
    
    error UnexpectedCreditAccountException(address expected, address actual);
}

interface IAdapter is IAdapterExceptions {
    
    function creditManager() external view returns (ICreditManagerV2);

    
    function creditFacade() external view returns (address);

    
    function targetContract() external view returns (address);

    
    function _gearboxAdapterType() external pure returns (AdapterType);

    
    function _gearboxAdapterVersion() external pure returns (uint16);
}

interface IUniversalAdapter is IAdapter, IUniversalAdapterExceptions {
    
    
    function revokeAdapterAllowances(RevocationPair[] calldata revocations)
        external;

    
    /// Checks that the msg.sender CA matches the expected account, since
    /// provided revocations are specific to a particular CA
    
    
    function revokeAdapterAllowances(
        RevocationPair[] calldata revocations,
        address expectedCreditAccount
    ) external;
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;




error ZeroAddressException();


error NotImplementedException();


error AddressIsNotContractException(address);


error IncorrectTokenContractException();


///      correct price feed
error IncorrectPriceFeedException();


error CallerNotConfiguratorException();


error CallerNotPausableAdminException();


error CallerNotUnPausableAdminException();

error TokenIsNotAddedToCreditManagerException(address token);

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;

// Denominations

uint256 constant WAD = 1e18;
uint256 constant RAY = 1e27;

// 25% of type(uint256).max
uint256 constant ALLOWANCE_THRESHOLD = type(uint96).max >> 3;

// FEE = 50%
uint16 constant DEFAULT_FEE_INTEREST = 50_00; // 50%

// LIQUIDATION_FEE 1.5%
uint16 constant DEFAULT_FEE_LIQUIDATION = 1_50; // 1.5%

// LIQUIDATION PREMIUM 4%
uint16 constant DEFAULT_LIQUIDATION_PREMIUM = 4_00; // 4%

// LIQUIDATION_FEE_EXPIRED 2%
uint16 constant DEFAULT_FEE_LIQUIDATION_EXPIRED = 1_00; // 2%

// LIQUIDATION PREMIUM EXPIRED 2%
uint16 constant DEFAULT_LIQUIDATION_PREMIUM_EXPIRED = 2_00; // 2%

// DEFAULT PROPORTION OF MAX BORROWED PER BLOCK TO MAX BORROWED PER ACCOUNT
uint16 constant DEFAULT_LIMIT_PER_BLOCK_MULTIPLIER = 2;

// Seconds in a year
uint256 constant SECONDS_PER_YEAR = 365 days;
uint256 constant SECONDS_PER_ONE_AND_HALF_YEAR = (SECONDS_PER_YEAR * 3) / 2;

// OPERATIONS

// Leverage decimals - 100 is equal to 2x leverage (100% * collateral amount + 100% * borrowed amount)
uint8 constant LEVERAGE_DECIMALS = 100;

// Maximum withdraw fee for pool in PERCENTAGE_FACTOR format
uint8 constant MAX_WITHDRAW_FEE = 100;

uint256 constant EXACT_INPUT = 1;
uint256 constant EXACT_OUTPUT = 2;

address constant UNIVERSAL_CONTRACT = 0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC;

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;




enum ClosureAction {
    CLOSE_ACCOUNT,
    LIQUIDATE_ACCOUNT,
    LIQUIDATE_EXPIRED_ACCOUNT,
    LIQUIDATE_PAUSED
}

interface ICreditManagerV2Events {
    
    event ExecuteOrder(address indexed borrower, address indexed target);

    
    event NewConfigurator(address indexed newConfigurator);
}

interface ICreditManagerV2Exceptions {
    
    ///      the connected Credit Facade, or an allowed adapter
    error AdaptersOrCreditFacadeOnlyException();

    
    ///      the connected Credit Facade
    error CreditFacadeOnlyException();

    
    ///      the connected Credit Configurator
    error CreditConfiguratorOnlyException();

    
    ///      to the zero address or an address that already owns a Credit Account
    error ZeroAddressOrUserAlreadyHasAccountException();

    
    ///      target contract
    error TargetContractNotAllowedException();

    
    error NotEnoughCollateralException();

    
    ///      or was forbidden
    error TokenNotAllowedException();

    
    error AllowanceFailedException();

    
    error HasNoOpenedAccountException();

    
    error TokenAlreadyAddedException();

    
    error TooManyTokensException();

    
    ///      and there are not enough unused token to disable
    error TooManyEnabledTokensException();

    
    error ReentrancyLockException();
}


interface IPriceOracleV2 is
    IPriceOracleV2Events,
    IPriceOracleV2Exceptions,
    IVersion
{
    
    
    
    function convertToUSD(uint256 amount, address token)
        external
        view
        returns (uint256);

    
    
    
    function convertFromUSD(uint256 amount, address token)
        external
        view
        returns (uint256);

    
    ///
    
    
    
    function convert(
        uint256 amount,
        address tokenFrom,
        address tokenTo
    ) external view returns (uint256);

    
    
    
    
    
    
    
    function fastCheck(
        uint256 amountFrom,
        address tokenFrom,
        uint256 amountTo,
        address tokenTo
    ) external view returns (uint256 collateralFrom, uint256 collateralTo);

    
    
    function getPrice(address token) external view returns (uint256);

    
    
    function priceFeeds(address token)
        external
        view
        returns (address priceFeed);

    
    ///      with additional parameters
    
    function priceFeedsWithFlags(address token)
        external
        view
        returns (
            address priceFeed,
            bool skipCheck,
            uint256 decimals
        );
}
// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;










contract UniversalAdapter is IUniversalAdapter {
    
    address public immutable targetContract = UNIVERSAL_CONTRACT;

    
    ICreditManagerV2 public immutable override creditManager;

    
    address public immutable override creditFacade;

    AdapterType public constant _gearboxAdapterType = AdapterType.UNIVERSAL;
    uint16 public constant _gearboxAdapterVersion = 1;

    
    
    constructor(address _creditManager) {
        if (_creditManager == address(0)) revert ZeroAddressException();

        creditManager = ICreditManagerV2(_creditManager);
        creditFacade = ICreditManagerV2(_creditManager).creditFacade();
    }

    
    
    function revokeAdapterAllowances(RevocationPair[] calldata revocations)
        external
    {
        address creditAccount = creditManager.getCreditAccountOrRevert(
            msg.sender
        );

        _revokeAdapterAllowances(revocations, creditAccount);
    }

    
    /// Checks that the msg.sender CA matches the expected account, since the
    /// Provided revocations can be specific to a particular CA
    
    
    function revokeAdapterAllowances(
        RevocationPair[] calldata revocations,
        address expectedCreditAccount
    ) external {
        address creditAccount = creditManager.getCreditAccountOrRevert(
            msg.sender
        );

        if (creditAccount != expectedCreditAccount) {
            revert UnexpectedCreditAccountException(
                expectedCreditAccount,
                creditAccount
            );
        }

        _revokeAdapterAllowances(revocations, creditAccount);
    }

    
    /// Checks that there are no zero addresses in a pair and sets allowance to 1
    /// through CreditManager.approveCreditAccount
    
    
    function _revokeAdapterAllowances(
        RevocationPair[] calldata revocations,
        address creditAccount
    ) internal {
        uint256 numRevocations = revocations.length;

        for (uint256 i; i < numRevocations; ) {
            address spender = revocations[i].spender;
            address token = revocations[i].token;

            if (spender == address(0) || token == address(0)) {
                revert ZeroAddressException();
            }

            uint256 allowance = IERC20(token).allowance(creditAccount, spender);

            if (allowance > 1) {
                creditManager.approveCreditAccount(
                    msg.sender,
                    spender,
                    token,
                    1
                );
            }

            unchecked {
                ++i;
            }
        }
    }

    
    ///
    // function withdraw(address token, uint256 amount) external {
    //     address creditAccount = creditManager.getCreditAccountOrRevert(
    //         msg.sender
    //     );

    //     if (creditManager.tokenMasksMap(token) == 0)
    //         revert("Token contract is not allowed");

    //     creditManager.executeOrder(
    //         msg.sender,
    //         token,
    //         abi.encodeWithSelector(IERC20.transfer.selector, msg.sender, amount)
    //     );

    //     creditManager.fullCollateralCheck(creditAccount);
    // }
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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


///         by the Credit Facade or allowed adapters. Users are not allowed to
///         interact with the Credit Manager directly
interface ICreditManagerV2 is
    ICreditManagerV2Events,
    ICreditManagerV2Exceptions,
    IVersion
{
    //
    // CREDIT ACCOUNT MANAGEMENT
    //

    
    /// - Takes Credit Account from the factory;
    /// - Requests the pool to lend underlying to the Credit Account
    ///
    
    
    function openCreditAccount(uint256 borrowedAmount, address onBehalfOf)
        external
        returns (address);

    
    /// - Checks whether the contract is paused, and, if so, if the payer is an emergency liquidator.
    ///   Only emergency liquidators are able to liquidate account while the CM is paused.
    ///   Emergency liquidations do not pay a liquidator premium or liquidation fees.
    /// - Calculates payments to various recipients on closure:
    ///    + Computes amountToPool, which is the amount to be sent back to the pool.
    ///      This includes the principal, interest and fees, but can't be more than
    ///      total position value
    ///    + Computes remainingFunds during liquidations - these are leftover funds
    ///      after paying the pool and the liquidator, and are sent to the borrower
    ///    + Computes protocol profit, which includes interest and liquidation fees
    ///    + Computes loss if the totalValue is less than borrow amount + interest
    /// - Checks the underlying token balance:
    ///    + if it is larger than amountToPool, then the pool is paid fully from funds on the Credit Account
    ///    + else tries to transfer the shortfall from the payer - either the borrower during closure, or liquidator during liquidation
    /// - Send assets to the "to" address, as long as they are not included into skipTokenMask
    /// - If convertWETH is true, the function converts WETH into ETH before sending
    /// - Returns the Credit Account back to factory
    ///
    
    
    
    
    
    
    
    function closeCreditAccount(
        address borrower,
        ClosureAction closureActionType,
        uint256 totalValue,
        address payer,
        address to,
        uint256 skipTokenMask,
        bool convertWETH
    ) external returns (uint256 remainingFunds);

    
    ///
    /// - Increase debt:
    ///   + Increases debt by transferring funds from the pool to the credit account
    ///   + Updates the cumulative index to keep interest the same. Since interest
    ///     is always computed dynamically as borrowedAmount * (cumulativeIndexNew / cumulativeIndexOpen - 1),
    ///     cumulativeIndexOpen needs to be updated, as the borrow amount has changed
    ///
    /// - Decrease debt:
    ///   + Repays debt partially + all interest and fees accrued thus far
    ///   + Updates cunulativeIndex to cumulativeIndex now
    ///
    
    
    
    
    function manageDebt(
        address creditAccount,
        uint256 amount,
        bool increase
    ) external returns (uint256 newBorrowedAmount);

    
    
    
    
    
    function addCollateral(
        address payer,
        address creditAccount,
        address token,
        uint256 amount
    ) external;

    
    
    
    function transferAccountOwnership(address from, address to) external;

    
    
    
    
    
    function approveCreditAccount(
        address borrower,
        address targetContract,
        address token,
        uint256 amount
    ) external;

    
    /// This is the intended pathway for state-changing interactions with 3rd-party protocols
    
    
    
    function executeOrder(
        address borrower,
        address targetContract,
        bytes memory data
    ) external returns (bytes memory);

    //
    // COLLATERAL VALIDITY AND ACCOUNT HEALTH CHECKS
    //

    
    /// into account health and total value calculations
    
    
    function checkAndEnableToken(address creditAccount, address token) external;

    
    
    ///         participate in the operation and computes a % change in weighted value between
    ///         inbound and outbound collateral. The cumulative negative change across several
    ///         swaps in sequence cannot be larger than feeLiquidation (a fee that the
    ///         protocol is ready to waive if needed). Since this records a % change
    ///         between just two tokens, the corresponding % change in TWV will always be smaller,
    ///         which makes this check safe.
    ///         More details at https://dev.gearbox.fi/docs/documentation/risk/fast-collateral-check#fast-check-protection
    
    
    
    
    
    function fastCollateralCheck(
        address creditAccount,
        address tokenIn,
        address tokenOut,
        uint256 balanceInBefore,
        uint256 balanceOutBefore
    ) external;

    
    /// value of all enabled collateral tokens
    
    function fullCollateralCheck(address creditAccount) external;

    
    ///      does not violate the maximal enabled token limit and tries
    ///      to disable unused tokens if it does
    
    function checkAndOptimizeEnabledTokens(address creditAccount) external;

    
    
    ///         but can also be called separately from the Credit Facade to remove
    ///         unwanted tokens
    
    function disableToken(address creditAccount, address token)
        external
        returns (bool);

    //
    // GETTERS
    //

    
    
    function getCreditAccountOrRevert(address borrower)
        external
        view
        returns (address);

    
    
    
    ///        * CLOSE_ACCOUNT: The account is healthy and is closed normally
    ///        * LIQUIDATE_ACCOUNT: The account is unhealthy and is being liquidated to avoid bad debt
    ///        * LIQUIDATE_EXPIRED_ACCOUNT: The account has expired and is being liquidated (lowered liquidation premium)
    ///        * LIQUIDATE_PAUSED: The account is liquidated while the system is paused due to emergency (no liquidation premium)
    
    
    
    
    
    
    function calcClosePayments(
        uint256 totalValue,
        ClosureAction closureActionType,
        uint256 borrowedAmount,
        uint256 borrowedAmountWithInterest
    )
        external
        view
        returns (
            uint256 amountToPool,
            uint256 remainingFunds,
            uint256 profit,
            uint256 loss
        );

    
    
    
    
    
    function calcCreditAccountAccruedInterest(address creditAccount)
        external
        view
        returns (
            uint256 borrowedAmount,
            uint256 borrowedAmountWithInterest,
            uint256 borrowedAmountWithInterestAndFees
        );

    
    /// Only enabled tokens are counted as collateral for the Credit Account
    
    ///         the bit at the position equal to token's index to 1
    function enabledTokensMap(address creditAccount)
        external
        view
        returns (uint256);

    
    ///      the last full check, in RAY format
    function cumulativeDropAtFastCheckRAY(address creditAccount)
        external
        view
        returns (uint256);

    
    
    function collateralTokens(uint256 id)
        external
        view
        returns (address token, uint16 liquidationThreshold);

    
    
    function collateralTokensByMask(uint256 tokenMask)
        external
        view
        returns (address token, uint16 liquidationThreshold);

    
    function collateralTokensCount() external view returns (uint256);

    
    
    function tokenMasksMap(address token) external view returns (uint256);

    
    function forbiddenTokenMask() external view returns (uint256);

    
    function adapterToContract(address adapter) external view returns (address);

    
    function contractToAdapter(address targetContract)
        external
        view
        returns (address);

    
    function underlying() external view returns (address);

    
    function pool() external view returns (address);

    
    
    function poolService() external view returns (address);

    
    function creditAccounts(address borrower) external view returns (address);

    
    function creditConfigurator() external view returns (address);

    
    function wethAddress() external view returns (address);

    
    
    function liquidationThresholds(address token)
        external
        view
        returns (uint16);

    
    function maxAllowedEnabledTokenLength() external view returns (uint8);

    
    
    /// that are able to liquidate positions while the contracts are paused,
    /// e.g. when there is a risk of bad debt while an exploit is being patched.
    /// In the interest of fairness, emergency liquidators do not receive a premium
    /// And are compensated by the Gearbox DAO separately.
    function canLiquidateWhilePaused(address) external view returns (bool);

    
    
    
    ///         during unhealthy account liquidations
    
    ///         allowing the liquidator to take the unaccounted for remainder as premium. Equal to (1 - liquidationPremium)
    
    ///         during expired account liquidations
    
    ///         allowing the liquidator to take the unaccounted for remainder as premium. Equal to (1 - liquidationPremiumExpired)
    function fees()
        external
        view
        returns (
            uint16 feeInterest,
            uint16 feeLiquidation,
            uint16 liquidationDiscount,
            uint16 feeLiquidationExpired,
            uint16 liquidationDiscountExpired
        );

    
    function creditFacade() external view returns (address);

    
    function priceOracle() external view returns (IPriceOracleV2);

    
    function universalAdapter() external view returns (address);

    
    function version() external view returns (uint256);

    
    function checkEmergencyPausable(address caller, bool state)
        external
        returns (bool);
}

interface IPriceOracleV2Ext is IPriceOracleV2 {
    
    
    
    function addPriceFeed(address token, address priceFeed) external;
}
