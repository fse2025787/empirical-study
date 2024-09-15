// SPDX-License-Identifier: MIT
pragma abicoder v2;


// 
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

/// 
pragma solidity ^0.8.13;















// import {IWETHGateway} from "gearbox/interfaces/IWETHGateway.sol";
// import {IWETHGateway} from "gearbox/interfaces/IWETHGateway.sol";

contract GearboxRegistry {
    IERC20 public FRAX = IERC20(0x853d955aCEf822Db058eb8505911ED77F175b99e);
    IERC20 public USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 public STETH = IERC20(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);
    IERC20 public WSTETH = IERC20(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0);
    IERC20 public WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public CURVE_STETH_GATEWAY =
        0xEf0D72C594b28252BF7Ea2bfbF098792430815b1;
    address public UNISWAP_V3_ROUTER =
        0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address public LIDO_STETH_GATEWAY =
        0x6f4b4aB5142787c05b7aB9A9692A0f46b997C29D;

    address internal _addressProvider =
        0xcF64698AFF7E5f27A11dff868AF228653ba53be0;
    address internal _wethCreditManager =
        0x5887ad4Cb2352E7F01527035fAa3AE0Ef2cE2b9B;

    constructor(address ap, address cm) {
        _setAddressProvider(ap);
        _setCreditManager(cm);
    }

    function adapter(address _allowedContract) public view returns (address) {
        return
            dataCompressor().getAdapter(
                address(creditManager()),
                _allowedContract
            );
    }

    function addressProvider() public view returns (IAddressProvider) {
        return IAddressProvider(_addressProvider);
    }

    function creditManager() public view returns (ICreditManagerV2) {
        return ICreditManagerV2(_wethCreditManager);
    }

    function creditAccount() public view returns (ICreditAccount) {
        return ICreditAccount(creditManager().creditAccounts(address(this)));
    }

    function acl() public view returns (IACL) {
        return IACL(addressProvider().getACL());
    }

    function contractsRegister() public view returns (IContractsRegister) {
        return IContractsRegister(addressProvider().getContractsRegister());
    }

    function accountFactory() public view returns (IAccountFactory) {
        return IAccountFactory(addressProvider().getAccountFactory());
    }

    function dataCompressor() public view returns (IDataCompressor) {
        return IDataCompressor(addressProvider().getDataCompressor());
    }

    function poolService() public view returns (IPoolService) {
        return IPoolService(creditManager().pool());
    }

    function gearToken() public view returns (IERC20) {
        return IERC20(addressProvider().getGearToken());
    }

    function weth() public view returns (IERC20) {
        return IERC20(addressProvider().getWethToken());
    }

    function wethGateway() public view returns (IWETHGateway) {
        return IWETHGateway(addressProvider().getWETHGateway());
    }

    function priceOracle() public view returns (IPriceOracleV2) {
        return IPriceOracleV2(addressProvider().getPriceOracle());
    }

    function creditFacade() public view returns (ICreditFacade) {
        return ICreditFacade(creditManager().creditFacade());
    }

    
    function _setAddressProvider(address ap) internal {
        _addressProvider = ap;
    }

    
    function _setCreditManager(address cm) internal {
        _wethCreditManager = cm;
    }

    function _setCurveStETHGateway(address gateway) internal {
        CURVE_STETH_GATEWAY = gateway;
    }
}

/// 
pragma solidity ^0.8.4;

interface ITradeExecutor {
    function vault() external view returns (address);

    function totalFunds()
        external
        view
        returns (uint256 posValue, uint256 lastUpdatedBlock);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;


interface IAddressProviderEvents {
    
    event AddressSet(bytes32 indexed service, address indexed newAddress);
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;





contract Claimable is Ownable {
    
    address public pendingOwner;

    
    modifier onlyPendingOwner() {
        if (msg.sender != pendingOwner) {
            revert("Claimable: Sender is not pending owner");
        }
        _;
    }

    
    /// transfer ownership yet
    
    function transferOwnership(address newOwner) public override onlyOwner {
        require(
            newOwner != address(0),
            "Claimable: new owner is the zero address"
        );
        pendingOwner = newOwner;
    }

    
    function claimOwnership() external onlyPendingOwner {
        _transferOwnership(pendingOwner);
        pendingOwner = address(0);
    }
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;


interface IACLExceptions {
    
    error AddressNotPausableAdminException(address addr);

    
    error AddressNotUnpausableAdminException(address addr);
}

interface IACLEvents {
    
    event PausableAdminAdded(address indexed newAdmin);

    
    event PausableAdminRemoved(address indexed admin);

    
    event UnpausableAdminAdded(address indexed newAdmin);

    
    event UnpausableAdminRemoved(address indexed admin);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;


interface IAccountFactoryEvents {
    
    
    event AccountMinerChanged(address indexed miner);

    
    event NewCreditAccount(address indexed account);

    
    event InitializeCreditAccount(
        address indexed account,
        address indexed creditManager
    );

    
    event ReturnCreditAccount(address indexed account);

    
    ///      by root
    event TakeForever(address indexed creditAccount, address indexed to);
}

interface IAccountFactoryGetters {
    
    
    function getNext(address creditAccount) external view returns (address);

    
    function head() external view returns (address);

    
    function tail() external view returns (address);

    
    function countCreditAccountsInStock() external view returns (uint256);

    
    
    function creditAccounts(uint256 id) external view returns (address);

    
    function countCreditAccounts() external view returns (uint256);
}


interface IAddressProvider is IAddressProviderEvents, IVersion {
    
    function getACL() external view returns (address);

    
    function getContractsRegister() external view returns (address);

    
    function getAccountFactory() external view returns (address);

    
    function getDataCompressor() external view returns (address);

    
    function getGearToken() external view returns (address);

    
    function getWethToken() external view returns (address);

    
    function getWETHGateway() external view returns (address);

    
    function getPriceOracle() external view returns (address);

    
    function getTreasuryContract() external view returns (address);

    
    function getLeveragedActions() external view returns (address);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;


interface IContractsRegisterEvents {
    
    event NewPoolAdded(address indexed pool);

    
    event NewCreditManagerAdded(address indexed creditManager);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;




///   - Holds collateral assets
///   - Stores general parameters: borrowed amount, cumulative index at open and block when it was initialized
///   - Transfers assets
///   - Executes financial orders by calling connected protocols on its behalf
///
///  More: https://dev.gearbox.fi/developers/credit/credit_account

interface ICrediAccountExceptions {
    
    error CallerNotCreditManagerException();

    
    error CallerNotFactoryException();
}

interface ICreditFacadeEvents {
    
    ///      Credit Facade
    event OpenCreditAccount(
        address indexed onBehalfOf,
        address indexed creditAccount,
        uint256 borrowAmount,
        uint16 referralCode
    );

    
    event CloseCreditAccount(address indexed borrower, address indexed to);

    
    event LiquidateCreditAccount(
        address indexed borrower,
        address indexed liquidator,
        address indexed to,
        uint256 remainingFunds
    );

    
    event LiquidateExpiredCreditAccount(
        address indexed borrower,
        address indexed liquidator,
        address indexed to,
        uint256 remainingFunds
    );

    
    event IncreaseBorrowedAmount(address indexed borrower, uint256 amount);

    
    event DecreaseBorrowedAmount(address indexed borrower, uint256 amount);

    
    event AddCollateral(
        address indexed onBehalfOf,
        address indexed token,
        uint256 value
    );

    
    event MultiCallStarted(address indexed borrower);

    
    event MultiCallFinished();

    
    event TransferAccount(address indexed oldOwner, address indexed newOwner);

    
    event TransferAccountAllowed(
        address indexed from,
        address indexed to,
        bool state
    );

    
    event TokenEnabled(address indexed borrower, address indexed token);

    
    event TokenDisabled(address indexed borrower, address indexed token);
}

interface ICreditFacadeExceptions is ICreditManagerV2Exceptions {
    
    ///      requires expirability
    error NotAllowedWhenNotExpirableException();

    
    ///      not allowed in whitelisted mode
    error NotAllowedInWhitelistedMode();

    
    error AccountTransferNotAllowedException();

    
    error CantLiquidateWithSuchHealthFactorException();

    
    error CantLiquidateNonExpiredException();

    
    error IncorrectCallDataException();

    
    ///      an account
    error ForbiddenDuringClosureException();

    
    error IncreaseAndDecreaseForbiddenInOneCallException();

    
    ///      during a multicall
    error UnknownMethodException();

    
    error IncreaseDebtForbiddenException();

    
    error CantTransferLiquidatableAccountException();

    
    error BorrowedBlockLimitException();

    
    error BorrowAmountOutOfLimitsException();

    
    ///      at the end of a multicall, if revertIfReceivedLessThan was called
    error BalanceLessThanMinimumDesiredException(address);

    
    error OpenAccountNotAllowedAfterExpirationException();

    
    error ExpectedBalancesAlreadySetException();

    
    ///      that is not allowed with any forbidden tokens enabled
    error ActionProhibitedWithForbiddenTokensException();
}

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

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;




interface IDataCompressorExceptions {
    
    ///      Credit Manager
    error NotCreditManagerException();

    
    ///      pool
    error NotPoolException();
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;



interface IPoolServiceEvents {
    
    event AddLiquidity(
        address indexed sender,
        address indexed onBehalfOf,
        uint256 amount,
        uint256 referralCode
    );

    
    event RemoveLiquidity(
        address indexed sender,
        address indexed to,
        uint256 amount
    );

    
    event Borrow(
        address indexed creditManager,
        address indexed creditAccount,
        uint256 amount
    );

    
    event Repay(
        address indexed creditManager,
        uint256 borrowedAmount,
        uint256 profit,
        uint256 loss
    );

    
    event NewInterestRateModel(address indexed newInterestRateModel);

    
    event NewCreditManagerConnected(address indexed creditManager);

    
    event BorrowForbidden(address indexed creditManager);

    
    event UncoveredLoss(address indexed creditManager, uint256 loss);

    
    event NewExpectedLiquidityLimit(uint256 newLimit);

    
    event NewWithdrawFee(uint256 fee);
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

/// 
pragma solidity ^0.8.4;






abstract contract BaseTradeExecutor is ITradeExecutor {
    uint256 internal constant MAX_INT = type(uint256).max;

    address public override vault;

    constructor(address _vault) {
        vault = _vault;
        IERC20(vaultWantToken()).approve(vault, MAX_INT);
    }

    function vaultWantToken() public view returns (address) {
        return IVault(vault).wantToken();
    }

    function governance() public view returns (address) {
        return IVault(vault).governance();
    }

    function keeper() public view returns (address) {
        return IVault(vault).keeper();
    }

    
    modifier onlyGovernance() {
        require(msg.sender == governance(), "ONLY_GOV");
        _;
    }

    
    modifier onlyKeeper() {
        require(msg.sender == keeper(), "ONLY_KEEPER");
        _;
    }

    
    modifier onlyVault() {
        require(msg.sender == vault, "ONLY_VAULT");
        _;
    }

    modifier keeperOrGovernance() {
        require(
            msg.sender == keeper() || msg.sender == governance(),
            "ONLY_KEEPER_OR_GOVERNANCE"
        );
        _;
    }

    function sweep(address _token) public onlyGovernance {
        IERC20(_token).transfer(
            governance(),
            IERC20(_token).balanceOf(address(this))
        );
    }


}

/// 
pragma solidity ^0.8.13;


// import {IUniswapV3Adapter} from "gearbox/interfaces/adapters/uniswap/IUniswapV3Adapter.sol";






// import {IstETH} from "gearbox_integrations/integrations/lido/IstETH.sol";
// import {ICurvePool} from "./interfaces/ICurvePool.sol";



contract CreditAccountController is GearboxRegistry {
    uint256 public immutable MAX_BPS = 1e4;
    uint256 public CURVE_ETH_STETH_SLIPPAGE = 200;
    uint256 public UNISWAP_ETH_USDC_POOL_SLIPPAGE = 100;
    uint256 public UNISWAP_ETH_FRAX_POOL_SLIPPAGE = 100;
    uint24 public UNISWAP_ETH_USDC_POOL_FEE = 500;
    uint24 public UNISWAP_USDC_FRAX_POOL_FEE = 100;
    uint256 public CURVE_SLIPPAGE_BOUND = 200;
    ICurvePool curvePool =
        ICurvePool(0xDC24316b9AE028F1497c275EB9192a3Ea0f67022);

    constructor(address addressProvider, address creditManager)
        GearboxRegistry(addressProvider, creditManager)
    {}

    function _openCreditAccount(
        uint256 fraxCollateral,
        uint256 ethToBorrow,
        MultiCall memory additionalCall
    ) internal {
        MultiCall[] memory calls = new MultiCall[](2);

        address _creditAccount = address(creditAccount());
        require(_creditAccount == address(0), "CA_ALREADY_EXISTS");
        FRAX.approve(address(creditManager()), fraxCollateral);

        calls[0] = _addCollateralCall(fraxCollateral);
        calls[1] = additionalCall;

        creditFacade().openCreditAccountMulticall(
            ethToBorrow,
            address(this),
            calls,
            0
        );
    }

    function _closeCreditAccount() internal {
        address _creditAccount = address(creditAccount());
        MultiCall[] memory calls = new MultiCall[](1);

        uint256 stETHBal = STETH.balanceOf(_creditAccount);
        if (stETHBal > 1e6) {
            MultiCall[] memory swapCall = new MultiCall[](1);
            uint256 amountOut = priceOracle().convert(
                stETHBal,
                address(STETH),
                address(WETH)
            );
            amountOut = accountOutputSlippage(
                amountOut,
                CURVE_ETH_STETH_SLIPPAGE
            );
            swapCall[0] = (_swapStETHToETHCall(stETHBal, amountOut));

            creditFacade().multicall(swapCall);
        }

        uint256 wethBal = WETH.balanceOf(_creditAccount);
        uint256 wethOwed = _getClosingUnderlyingOwed() + 1;
        /// Line 348 CM
        if (wethOwed > wethBal) {
            uint256 wethRequired = wethOwed - wethBal;

            uint256 fraxNeeded = priceOracle().convert(
                wethRequired,
                address(WETH),
                address(FRAX)
            );
            fraxNeeded = accountInputSlippage(
                fraxNeeded,
                UNISWAP_ETH_FRAX_POOL_SLIPPAGE
            );
            calls[0] = (_swapFRAXToETHCall(wethRequired, fraxNeeded));
        } else if (wethBal > wethOwed) {
            uint256 wethAvailable = wethBal - wethOwed;
            uint256 fraxOut = priceOracle().convert(
                wethAvailable,
                address(WETH),
                address(FRAX)
            );
            fraxOut = accountOutputSlippage(
                fraxOut,
                UNISWAP_ETH_FRAX_POOL_SLIPPAGE
            );
            calls[0] = (_swapETHToFRAXCall(wethAvailable, fraxOut));
        }

        creditFacade().closeCreditAccount(address(this), 0, false, calls);
    }

    function _convertStETHToFrax(uint256 stETHIn)
        internal
        returns (uint256 fraxOut)
    {
        uint256 oldWETHBal = WETH.balanceOf(address(creditAccount()));
        MultiCall[] memory swapCall = new MultiCall[](1);
        uint256 amountOut = priceOracle().convert(
            stETHIn,
            address(STETH),
            address(WETH)
        );
        amountOut = accountOutputSlippage(amountOut, CURVE_ETH_STETH_SLIPPAGE);
        swapCall[0] = (_swapStETHToETHCall(stETHIn, amountOut));

        creditFacade().multicall(swapCall);

        uint256 wethOut = WETH.balanceOf(address(creditAccount())) - oldWETHBal;

        uint256 minFraxOut = priceOracle().convert(
            wethOut,
            address(WETH),
            address(FRAX)
        );
        minFraxOut = accountOutputSlippage(
            fraxOut,
            UNISWAP_ETH_FRAX_POOL_SLIPPAGE
        );

        uint256 oldFraxBal = FRAX.balanceOf(address(creditAccount()));
        swapCall[0] = _swapETHToFRAXCall(wethOut, minFraxOut);
        creditFacade().multicall(swapCall);

        fraxOut = FRAX.balanceOf(address(creditAccount())) - oldFraxBal;
    }

    function _addCollateralCall(uint256 fraxIn)
        internal
        view
        returns (MultiCall memory call)
    {
        call.target = address(creditFacade());
        call.callData = abi.encodeWithSelector(
            ICreditFacade.addCollateral.selector,
            address(this),
            address(FRAX),
            fraxIn
        );
    }

    function _increaseDebtCall(uint256 amountIn)
        internal
        view
        returns (MultiCall memory call)
    {
        call.target = address(creditFacade());
        call.callData = abi.encodeWithSelector(
            ICreditFacade.increaseDebt.selector,
            amountIn
        );
    }

    function _decreaseDebtCall(uint256 amountIn)
        internal
        view
        returns (MultiCall memory call)
    {
        call.target = address(creditFacade());
        call.callData = abi.encodeWithSelector(
            ICreditFacade.decreaseDebt.selector,
            amountIn
        );
    }

    function _getClosingUnderlyingOwed()
        internal
        view
        returns (uint256 amountToPool)
    {
        (uint256 total, ) = creditFacade().calcTotalValue(
            address(creditAccount())
        );

        (
            uint256 borrowedAmount,
            uint256 borrowedAmountWithInterest,

        ) = creditManager().calcCreditAccountAccruedInterest(
                address(creditAccount())
            );

        (amountToPool, , , ) = creditManager().calcClosePayments(
            total,
            ClosureAction.CLOSE_ACCOUNT,
            borrowedAmount,
            borrowedAmountWithInterest
        );
    }

    /// UNISWAP V3 SWAPS

    function _swapETHToFRAXCall(uint256 ethIn, uint256 minFraxOut)
        internal
        view
        returns (MultiCall memory call)
    {
        call = MultiCall({
            target: adapter(UNISWAP_V3_ROUTER),
            callData: abi.encodeWithSelector(
                ISwapRouter.exactInput.selector,
                ISwapRouter.ExactInputParams({
                    path: abi.encodePacked(
                        WETH,
                        UNISWAP_ETH_USDC_POOL_FEE,
                        USDC,
                        UNISWAP_USDC_FRAX_POOL_FEE,
                        FRAX
                    ),
                    recipient: address(creditAccount()),
                    deadline: block.timestamp,
                    amountIn: ethIn,
                    amountOutMinimum: minFraxOut
                })
            )
        });
    }

    function _swapFRAXToETHCall(uint256 ethRequired, uint256 maxFRAXIn)
        internal
        view
        returns (MultiCall memory call)
    {
        call = MultiCall({
            target: adapter(UNISWAP_V3_ROUTER),
            callData: abi.encodeWithSelector(
                ISwapRouter.exactInput.selector,
                ISwapRouter.ExactInputParams({
                    path: abi.encodePacked(
                        FRAX,
                        UNISWAP_USDC_FRAX_POOL_FEE,
                        USDC,
                        UNISWAP_ETH_USDC_POOL_FEE,
                        WETH
                    ),
                    recipient: address(creditAccount()),
                    deadline: block.timestamp,
                    amountIn: maxFRAXIn,
                    amountOutMinimum: ethRequired
                })
            )
        });
    }

    function _swapETHToUSDCCall(uint256 ethIn, uint256 minUSDCOut)
        internal
        view
        returns (MultiCall memory call)
    {
        call = MultiCall({
            target: adapter(UNISWAP_V3_ROUTER),
            callData: abi.encodeWithSelector(
                ISwapRouter.exactInputSingle.selector,
                ISwapRouter.ExactInputSingleParams({
                    tokenIn: address(WETH),
                    tokenOut: address(USDC),
                    fee: UNISWAP_ETH_USDC_POOL_FEE,
                    recipient: address(creditAccount()),
                    deadline: block.timestamp,
                    amountIn: ethIn,
                    amountOutMinimum: minUSDCOut,
                    sqrtPriceLimitX96: 0
                })
            )
        });
    }

    function _swapUSDCToETHCall(uint256 ethRequired, uint256 maxUSDCIn)
        internal
        view
        returns (MultiCall memory call)
    {
        call = MultiCall({
            target: adapter(UNISWAP_V3_ROUTER),
            callData: abi.encodeWithSelector(
                ISwapRouter.exactOutputSingle.selector,
                ISwapRouter.ExactOutputSingleParams({
                    tokenIn: address(USDC),
                    tokenOut: address(WETH),
                    fee: UNISWAP_ETH_USDC_POOL_FEE,
                    recipient: address(creditAccount()),
                    deadline: block.timestamp,
                    amountOut: ethRequired,
                    amountInMaximum: maxUSDCIn,
                    sqrtPriceLimitX96: 0
                })
            )
        });
    }

    /// CURVE SWAPS

    enum CurvePoolIndex {
        ETH,
        STETH
    }

    function _swapETHToStETHCall(uint256 ethAmount, uint256 minStETHAmount)
        internal
        view
        returns (MultiCall memory call)
    {
        uint256 stETHPriceCurve = curvePool.get_dy(0, 1, ethAmount);

        uint256 stETHPriceLido = ethAmount - 1;

        if (stETHPriceCurve > stETHPriceLido) {
            //curve swap
            call = MultiCall({
                target: adapter(CURVE_STETH_GATEWAY),
                callData: abi.encodeWithSelector(
                    ICurvePool.exchange.selector,
                    CurvePoolIndex.ETH, // i
                    CurvePoolIndex.STETH, // j
                    ethAmount, // dx
                    minStETHAmount // min_dy
                )
            });
        } else {
            //lido deposit
            call = MultiCall({
                target: adapter(LIDO_STETH_GATEWAY),
                callData: abi.encodeWithSelector(
                    IstETH.submit.selector,
                    ethAmount
                )
            });
        }
    }

    function _swapStETHToETHCall(uint256 stETHAmount, uint256 minETHAmount)
        internal
        view
        returns (MultiCall memory call)
    {
        call = MultiCall({
            target: adapter(CURVE_STETH_GATEWAY),
            callData: abi.encodeWithSelector(
                ICurvePool.exchange.selector,
                CurvePoolIndex.STETH, // i
                CurvePoolIndex.ETH, // j
                stETHAmount, // dx
                minETHAmount // min_dy
            )
        });
    }

    /// Helper Methods

    function accountOutputSlippage(uint256 amount, uint256 bps)
        internal
        pure
        returns (uint256)
    {
        return (amount * (MAX_BPS - bps)) / MAX_BPS;
    }

    function accountInputSlippage(uint256 amount, uint256 bps)
        internal
        pure
        returns (uint256)
    {
        return (amount * (MAX_BPS + bps)) / MAX_BPS;
    }

    function positionInWantToken() public view returns (uint256 totalEquity) {
        if (isCreditAccountOpen()) {
            (, , uint256 borrowedAmountAndFeesAndInterest) = creditManager()
                .calcCreditAccountAccruedInterest(address(creditAccount()));

            uint256 totalBorrowedETHInWantToken = priceOracle().convert(
                borrowedAmountAndFeesAndInterest,
                address(WETH),
                address(FRAX)
            );

            uint256 totalstETHInWantToken = priceOracle().convert(
                getStETHPriceInETH(STETH.balanceOf(address(creditAccount()))),
                address(WETH),
                address(FRAX)
            );

            totalEquity =
                FRAX.balanceOf(address(creditAccount())) +
                totalstETHInWantToken -
                totalBorrowedETHInWantToken;
        }
    }

    function healthFactor()
        public
        view
        creditAccountRequired
        returns (uint256)
    {
        return
            creditFacade().calcCreditAccountHealthFactor(
                address(creditAccount())
            );
    }

    function getLeverage() public view returns (uint256 leverage) {
        uint256 totalEquity = positionInWantToken();

        (, , uint256 borrowedAmountAndFeesAndInterest) = creditManager()
            .calcCreditAccountAccruedInterest(address(creditAccount()));

        uint256 totalBorrowedETHInWantToken = priceOracle().convert(
            borrowedAmountAndFeesAndInterest,
            address(WETH),
            address(FRAX)
        );
        leverage = (totalBorrowedETHInWantToken * MAX_BPS) / totalEquity;
    }

    function getBorrowingRate() public view returns (uint256 borrowRate) {
        IPoolService ethPool = IPoolService(creditManager().pool());
        borrowRate = ethPool.borrowAPY_RAY();
    }

    function getBalances()
        public
        view
        returns (
            uint256 fraxBalance,
            uint256 ethDebtBalance,
            uint256 stETHbalance
        )
    {
        if (isCreditAccountOpen() == true) {
            fraxBalance = FRAX.balanceOf(address(creditAccount()));

            (, , ethDebtBalance) = creditManager()
                .calcCreditAccountAccruedInterest(address(creditAccount()));

            stETHbalance = STETH.balanceOf(address(creditAccount()));
        }
    }

    function getPrices()
        public
        view
        returns (
            uint256 ethPrice,
            uint256 stETHPrice,
            uint256 stETHPriceOnCurve
        )
    {
        uint256 stETHBalance = STETH.balanceOf(address(creditAccount()));
        ethPrice = priceOracle().convertToUSD(1e18, address(WETH));
        stETHPrice = priceOracle().convertToUSD(1e18, address(STETH));
        stETHPriceOnCurve =
            (curvePool.get_dy(1, 0, stETHBalance) * MAX_BPS) /
            stETHBalance;
    }

    
    
    function getStETHPriceInETH(uint256 amountOfStETH)
        public
        view
        returns (uint256 amountOut)
    {
        uint256 oracleAmount = priceOracle().convert(
            amountOfStETH,
            address(STETH),
            address(WETH)
        );
        uint256 curveAmount = curvePool.get_dy(1, 0, amountOfStETH);
        uint256 boundAmount = (oracleAmount *
            (MAX_BPS - CURVE_SLIPPAGE_BOUND)) / MAX_BPS;
        amountOut = curveAmount < boundAmount ? boundAmount : curveAmount;
    }

    
    function getCMLeverageLimits()
        public
        view
        returns (uint256 minLeverage, uint256 maxLeverage)
    {
        (uint256 minAmountBorrow, uint256 maxAmountBorrow) = creditFacade()
            .limits();
        uint256 minAmount = priceOracle().convert(
            minAmountBorrow,
            address(WETH),
            address(FRAX)
        );
        uint256 maxAmount = priceOracle().convert(
            maxAmountBorrow,
            address(WETH),
            address(FRAX)
        );
        uint256 totalEquity = positionInWantToken();
        minLeverage = (minAmount * MAX_BPS) / totalEquity;

        minLeverage = (minLeverage * (MAX_BPS + 1000)) / MAX_BPS; // added 10% buffer
        maxLeverage = (maxAmount * MAX_BPS) / totalEquity;
        maxLeverage = (maxLeverage * (MAX_BPS - 1000)) / MAX_BPS; // removed 10% buffer
    }

    function _setSlippageBound(uint256 slippage)
        internal
        checkSlippage(slippage)
    {
        CURVE_SLIPPAGE_BOUND = slippage;
    }

    function _setCurveSwapSlippage(uint256 slippage)
        internal
        checkSlippage(slippage)
    {
        CURVE_ETH_STETH_SLIPPAGE = slippage;
    }

    function _setUniETHSlippage(uint256 slippage)
        internal
        checkSlippage(slippage)
    {
        UNISWAP_ETH_USDC_POOL_SLIPPAGE = slippage;
    }

    function _setUniFRAXSlippage(uint256 slippage)
        internal
        checkSlippage(slippage)
    {
        UNISWAP_ETH_FRAX_POOL_SLIPPAGE = slippage;
    }

    modifier checkSlippage(uint256 _slippage) {
        require(_slippage < MAX_BPS / 10, "ILLEGAL_SLIPPAGE");
        _;
    }

    function isCreditAccountOpen() public view returns (bool) {
        return !(address(creditAccount()) == address(0));
    }

    modifier creditAccountRequired() {
        require(isCreditAccountOpen(), "CREDIT_ACCOUNT_NOT_FOUND");
        _;
    }
}

/// 
pragma solidity ^0.8.10;


interface IwstETHGetters is IERC20Metadata {
    function stETH() external view returns (address);

    /**
     * @notice Get amount of wstETH for a given amount of stETH
     * @param _stETHAmount amount of stETH
     * @return Amount of wstETH for a given stETH amount
     */
    function getWstETHByStETH(uint256 _stETHAmount)
        external
        view
        returns (uint256);

    /**
     * @notice Get amount of stETH for a given amount of wstETH
     * @param _wstETHAmount amount of wstETH
     * @return Amount of stETH for a given wstETH amount
     */
    function getStETHByWstETH(uint256 _wstETHAmount)
        external
        view
        returns (uint256);

    /**
     * @notice Get amount of stETH for a one wstETH
     * @return Amount of stETH for 1 wstETH
     */
    function stEthPerToken() external view returns (uint256);

    /**
     * @notice Get amount of wstETH for a one stETH
     * @return Amount of wstETH for a 1 stETH
     */
    function tokensPerStEth() external view returns (uint256);
}
// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;





// Repositories & services
bytes32 constant CONTRACTS_REGISTER = "CONTRACTS_REGISTER";
bytes32 constant ACL = "ACL";
bytes32 constant PRICE_ORACLE = "PRICE_ORACLE";
bytes32 constant ACCOUNT_FACTORY = "ACCOUNT_FACTORY";
bytes32 constant DATA_COMPRESSOR = "DATA_COMPRESSOR";
bytes32 constant TREASURY_CONTRACT = "TREASURY_CONTRACT";
bytes32 constant GEAR_TOKEN = "GEAR_TOKEN";
bytes32 constant WETH_TOKEN = "WETH_TOKEN";
bytes32 constant WETH_GATEWAY = "WETH_GATEWAY";
bytes32 constant LEVERAGED_ACTIONS = "LEVERAGED_ACTIONS";



contract AddressProvider is Claimable, IAddressProvider {
    // Mapping from contract keys to respective addresses
    mapping(bytes32 => address) public addresses;

    // Contract version
    uint256 public constant version = 2;

    constructor() {
        // @dev Emits first event for contract discovery
        emit AddressSet("ADDRESS_PROVIDER", address(this));
    }

    
    function getACL() external view returns (address) {
        return _getAddress(ACL); // F:[AP-3]
    }

    
    
    function setACL(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(ACL, _address); // F:[AP-3]
    }

    
    function getContractsRegister() external view returns (address) {
        return _getAddress(CONTRACTS_REGISTER); // F:[AP-4]
    }

    
    
    function setContractsRegister(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(CONTRACTS_REGISTER, _address); // F:[AP-4]
    }

    
    function getPriceOracle() external view override returns (address) {
        return _getAddress(PRICE_ORACLE); // F:[AP-5]
    }

    
    
    function setPriceOracle(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(PRICE_ORACLE, _address); // F:[AP-5]
    }

    
    function getAccountFactory() external view returns (address) {
        return _getAddress(ACCOUNT_FACTORY); // F:[AP-6]
    }

    
    
    function setAccountFactory(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(ACCOUNT_FACTORY, _address); // F:[AP-6]
    }

    
    function getDataCompressor() external view override returns (address) {
        return _getAddress(DATA_COMPRESSOR); // F:[AP-7]
    }

    
    
    function setDataCompressor(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(DATA_COMPRESSOR, _address); // F:[AP-7]
    }

    
    function getTreasuryContract() external view returns (address) {
        return _getAddress(TREASURY_CONTRACT); // F:[AP-8]
    }

    
    
    function setTreasuryContract(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(TREASURY_CONTRACT, _address); // F:[AP-8]
    }

    
    function getGearToken() external view override returns (address) {
        return _getAddress(GEAR_TOKEN); // F:[AP-9]
    }

    
    
    function setGearToken(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(GEAR_TOKEN, _address); // F:[AP-9]
    }

    
    function getWethToken() external view override returns (address) {
        return _getAddress(WETH_TOKEN); // F:[AP-10]
    }

    
    
    function setWethToken(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(WETH_TOKEN, _address); // F:[AP-10]
    }

    
    function getWETHGateway() external view override returns (address) {
        return _getAddress(WETH_GATEWAY); // F:[AP-11]
    }

    
    
    function setWETHGateway(address _address)
        external
        onlyOwner // F:[AP-12]
    {
        _setAddress(WETH_GATEWAY, _address); // F:[AP-11]
    }

    
    function getLeveragedActions() external view returns (address) {
        return _getAddress(LEVERAGED_ACTIONS); // T:[AP-7]
    }

    
    
    function setLeveragedActions(address _address)
        external
        onlyOwner // T:[AP-15]
    {
        _setAddress(LEVERAGED_ACTIONS, _address); // T:[AP-7]
    }

    
    function _getAddress(bytes32 key) internal view returns (address) {
        address result = addresses[key];
        require(result != address(0), Errors.AS_ADDRESS_NOT_FOUND); // F:[AP-1]
        return result; // F:[AP-3, 4, 5, 6, 7, 8, 9, 10, 11]
    }

    
    
    
    function _setAddress(bytes32 key, address value) internal {
        addresses[key] = value; // F:[AP-3, 4, 5, 6, 7, 8, 9, 10, 11]
        emit AddressSet(key, value); // F:[AP-2]
    }
}


interface IACL is IACLEvents, IACLExceptions, IVersion {
    
    
    function isPausableAdmin(address addr) external view returns (bool);

    
    
    function isUnpausableAdmin(address addr) external view returns (bool);

    
    
    function isConfigurator(address account) external view returns (bool);

    
    function owner() external view returns (address);
}

interface IAccountFactory is
    IAccountFactoryGetters,
    IAccountFactoryEvents,
    IVersion
{
    
    function takeCreditAccount(
        uint256 _borrowedAmount,
        uint256 _cumulativeIndexAtOpen
    ) external returns (address);

    
    
    function returnCreditAccount(address usedAccount) external;
}

interface IContractsRegister is IContractsRegisterEvents, IVersion {
    //
    // POOLS
    //

    
    function getPools() external view returns (address[] memory);

    
    
    function pools(uint256 i) external returns (address);

    
    function getPoolsCount() external view returns (uint256);

    
    function isPool(address) external view returns (bool);

    //
    // CREDIT MANAGERS
    //

    
    function getCreditManagers() external view returns (address[] memory);

    
    
    function creditManagers(uint256 i) external returns (address);

    
    function getCreditManagersCount() external view returns (uint256);

    
    function isCreditManager(address) external view returns (bool);
}

interface ICreditAccount is ICrediAccountExceptions, IVersion {
    
    
    function initialize() external;

    
    
    
    
    function connectTo(
        address _creditManager,
        uint256 _borrowedAmount,
        uint256 _cumulativeIndexAtOpen
    ) external;

    
    
    
    function updateParameters(
        uint256 _borrowedAmount,
        uint256 _cumulativeIndexAtOpen
    ) external;

    
    
    
    function cancelAllowance(address token, address targetContract) external;

    
    
    
    
    function safeTransfer(
        address token,
        address to,
        uint256 amount
    ) external;

    
    function borrowedAmount() external view returns (uint256);

    
    function cumulativeIndexAtOpen() external view returns (uint256);

    
    function since() external view returns (uint256);

    
    function creditManager() external view returns (address);

    
    function factory() external view returns (address);

    
    
    
    function execute(address destination, bytes memory data)
        external
        returns (bytes memory);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;






interface ICreditFacadeExtended {
    
    ///      and compare with actual balances at the end of a multicall, reverts
    ///      if at least one is less than expected
    
    
    ///         itself and can only be used within a multicall
    function revertIfReceivedLessThan(Balance[] memory expected) external;

    
    
    function enableToken(address token) external;

    
    
    
    ///         itself and can only be used within a multicall
    function disableToken(address token) external;

    
    
    
    
    function addCollateral(
        address onBehalfOf,
        address token,
        uint256 amount
    ) external payable;

    
    /// - Borrows the requested amount from the pool
    /// - Updates the CA's borrowAmount / cumulativeIndexOpen
    ///   to correctly compute interest going forward
    /// - Performs a full collateral check
    ///
    
    function increaseDebt(uint256 amount) external;

    
    /// - Decreases the debt by paying the requested amount + accrued interest + fees back to the pool
    /// - It's also include to this payment interest accrued at the moment and fees
    /// - Updates cunulativeIndex to cumulativeIndex now
    ///
    
    function decreaseDebt(uint256 amount) external;
}

interface ICreditFacade is
    ICreditFacadeEvents,
    ICreditFacadeExceptions,
    IVersion
{
    //
    // CREDIT ACCOUNT MANAGEMENT
    //

    
    /// without any additional action.
    
    
    /// msg.sender != obBehalfOf
    
    /// as the user's own collateral, equivalent to 2x leverage.
    
    function openCreditAccount(
        uint256 amount,
        address onBehalfOf,
        uint16 leverageFactor,
        uint16 referralCode
    ) external payable;

    
    
    
    /// msg.sender != obBehalfOf
    
    /// at least a call to addCollateral, as otherwise the health check at the end will fail.
    
    function openCreditAccountMulticall(
        uint256 borrowedAmount,
        address onBehalfOf,
        MultiCall[] calldata calls,
        uint16 referralCode
    ) external payable;

    
    /// - Wraps ETH to WETH and sends it msg.sender if value > 0
    /// - Executes the multicall - the main purpose of a multicall when closing is to convert all assets to underlying
    /// in order to pay the debt.
    /// - Closes credit account:
    ///    + Checks the underlying balance: if it is greater than the amount paid to the pool, transfers the underlying
    ///      from the Credit Account and proceeds. If not, tries to transfer the shortfall from msg.sender.
    ///    + Transfers all enabled assets with non-zero balances to the "to" address, unless they are marked
    ///      to be skipped in skipTokenMask
    ///    + If convertWETH is true, converts WETH into ETH before sending to the recipient
    /// - Emits a CloseCreditAccount event
    ///
    
    
    
    
    function closeCreditAccount(
        address to,
        uint256 skipTokenMask,
        bool convertWETH,
        MultiCall[] calldata calls
    ) external payable;

    
    /// - Computes the total value and checks that hf < 1. An account can't be liquidated when hf >= 1.
    ///   Total value has to be computed before the multicall, otherwise the liquidator would be able
    ///   to manipulate it.
    /// - Wraps ETH to WETH and sends it to msg.sender (liquidator) if value > 0
    /// - Executes the multicall - the main purpose of a multicall when liquidating is to convert all assets to underlying
    ///   in order to pay the debt.
    /// - Liquidate credit account:
    ///    + Computes the amount that needs to be paid to the pool. If totalValue * liquidationDiscount < borrow + interest + fees,
    ///      only totalValue * liquidationDiscount has to be paid. Since liquidationDiscount < 1, the liquidator can take
    ///      totalValue * (1 - liquidationDiscount) as premium. Also computes the remaining funds to be sent to borrower
    ///      as totalValue * liquidationDiscount - amountToPool.
    ///    + Checks the underlying balance: if it is greater than amountToPool + remainingFunds, transfers the underlying
    ///      from the Credit Account and proceeds. If not, tries to transfer the shortfall from the liquidator.
    ///    + Transfers all enabled assets with non-zero balances to the "to" address, unless they are marked
    ///      to be skipped in skipTokenMask. If the liquidator is confident that all assets were converted
    ///      during the multicall, they can set the mask to uint256.max - 1, to only transfer the underlying
    ///    + If convertWETH is true, converts WETH into ETH before sending
    /// - Emits LiquidateCreditAccount event
    ///
    
    
    
    
    function liquidateCreditAccount(
        address borrower,
        address to,
        uint256 skipTokenMask,
        bool convertWETH,
        MultiCall[] calldata calls
    ) external payable;

    
    /// this Credit Facade is expired
    /// The general flow of liquidation is nearly the same as normal liquidations, with two main differences:
    ///     - An account can be liquidated on an expired Credit Facade even with hf > 1. However,
    ///       no accounts can be liquidated through this function if the Credit Facade is not expired.
    ///     - Liquidation premiums and fees for liquidating expired accounts are reduced.
    /// It is still possible to normally liquidate an underwater Credit Account, even when the Credit Facade
    /// is expired.
    
    
    
    
    
    function liquidateExpiredCreditAccount(
        address borrower,
        address to,
        uint256 skipTokenMask,
        bool convertWETH,
        MultiCall[] calldata calls
    ) external payable;

    
    /// - Borrows the requested amount from the pool
    /// - Updates the CA's borrowAmount / cumulativeIndexOpen
    ///   to correctly compute interest going forward
    /// - Performs a full collateral check
    ///
    
    function increaseDebt(uint256 amount) external;

    
    /// - Decreases the debt by paying the requested amount + accrued interest + fees back to the pool
    /// - It's also include to this payment interest accrued at the moment and fees
    /// - Updates cunulativeIndex to cumulativeIndex now
    ///
    
    function decreaseDebt(uint256 amount) external;

    
    
    
    
    function addCollateral(
        address onBehalfOf,
        address token,
        uint256 amount
    ) external payable;

    
    ///  - Wraps ETH and sends it back to msg.sender, if value > 0
    ///  - Executes the Multicall
    ///  - Performs a fullCollateralCheck to verify that hf > 1 after all actions
    
    function multicall(MultiCall[] calldata calls) external payable;

    
    
    function hasOpenedCreditAccount(address borrower)
        external
        view
        returns (bool);

    
    
    
    
    function approve(
        address targetContract,
        address token,
        uint256 amount
    ) external;

    
    
    
    function approveAccountTransfer(address from, bool state) external;

    
    
    function enableToken(address token) external;

    
    /// By default, this action is forbidden, and the user has to approve transfers from sender to itself
    /// by calling approveAccountTransfer.
    /// This is done to prevent malicious actors from transferring compromised accounts to other users.
    
    function transferAccountOwnership(address to) external;

    //
    // GETTERS
    //

    
    ///
    
    
    
    function calcTotalValue(address creditAccount)
        external
        view
        returns (uint256 total, uint256 twv);

    /**
     * @dev Calculates health factor for the credit account
     *
     *          sum(asset[i] * liquidation threshold[i])
     *   Hf = --------------------------------------------
     *         borrowed amount + interest accrued + fees
     *
     *
     * More info: https://dev.gearbox.fi/developers/credit/economy#health-factor
     *
     * @param creditAccount Credit account address
     * @return hf = Health factor in bp (see PERCENTAGE FACTOR in PercentageMath.sol)
     */
    function calcCreditAccountHealthFactor(address creditAccount)
        external
        view
        returns (uint256 hf);

    
    /// otherwise returns false
    
    function isTokenAllowed(address token) external view returns (bool);

    
    function creditManager() external view returns (ICreditManagerV2);

    
    
    
    function transfersAllowed(address from, address to)
        external
        view
        returns (bool);

    
    
    
    function params()
        external
        view
        returns (
            uint128 maxBorrowedAmountPerBlock,
            bool isIncreaseDebtForbidden,
            uint40 expirationDate
        );

    
    
    function limits()
        external
        view
        returns (uint128 minBorrowedAmount, uint128 maxBorrowedAmount);

    
    function degenNFT() external view returns (address);

    
    function underlying() external view returns (address);
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

interface IDataCompressor is IDataCompressorExceptions, IVersion {
    
    
    function getCreditAccountList(address borrower)
        external
        view
        returns (CreditAccountData[] memory);

    
    
    
    function hasOpenedCreditAccount(address creditManager, address borrower)
        external
        view
        returns (bool);

    
    
    
    function getCreditAccountData(address _creditManager, address borrower)
        external
        view
        returns (CreditAccountData memory);

    
    function getCreditManagersList()
        external
        view
        returns (CreditManagerData[] memory);

    
    
    function getCreditManagerData(address _creditManager)
        external
        view
        returns (CreditManagerData memory);

    
    
    function getPoolData(address _pool) external view returns (PoolData memory);

    
    function getPoolsList() external view returns (PoolData[] memory);

    
    function getAdapter(address _creditManager, address _allowedContract)
        external
        view
        returns (address adapter);
}



///   - Adding/removing pool liquidity
///   - Managing diesel tokens & diesel rates
///   - Taking/repaying Credit Manager debt
/// More: https://dev.gearbox.fi/developers/pool/abstractpoolservice
interface IPoolService is IPoolServiceEvents, IVersion {
    //
    // LIQUIDITY MANAGEMENT
    //

    /**
     * @dev Adds liquidity to pool
     * - transfers the underlying to the pool
     * - mints Diesel (LP) tokens to onBehalfOf
     * @param amount Amount of tokens to be deposited
     * @param onBehalfOf The address that will receive the dToken
     * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
     *   0 if the action is executed directly by the user, without a facilitator.
     */
    function addLiquidity(
        uint256 amount,
        address onBehalfOf,
        uint256 referralCode
    ) external;

    /**
     * @dev Removes liquidity from pool
     * - burns LP's Diesel (LP) tokens
     * - returns the equivalent amount of underlying to 'to'
     * @param amount Amount of Diesel tokens to burn
     * @param to Address to transfer the underlying to
     */

    function removeLiquidity(uint256 amount, address to)
        external
        returns (uint256);

    /**
     * @dev Lends pool funds to a Credit Account
     * @param borrowedAmount Credit Account's debt principal
     * @param creditAccount Credit Account's address
     */
    function lendCreditAccount(uint256 borrowedAmount, address creditAccount)
        external;

    /**
     * @dev Repays the Credit Account's debt
     * @param borrowedAmount Amount of principal ro repay
     * @param profit The treasury profit from repayment
     * @param loss Amount of underlying that the CA wan't able to repay
     * @notice Assumes that the underlying (including principal + interest + fees)
     *         was already transferred
     */
    function repayCreditAccount(
        uint256 borrowedAmount,
        uint256 profit,
        uint256 loss
    ) external;

    //
    // GETTERS
    //

    /**
     * @dev Returns the total amount of liquidity in the pool, including borrowed and available funds
     */
    function expectedLiquidity() external view returns (uint256);

    /**
     * @dev Returns the limit on total liquidity
     */
    function expectedLiquidityLimit() external view returns (uint256);

    /**
     * @dev Returns the available liquidity, which is expectedLiquidity - totalBorrowed
     */
    function availableLiquidity() external view returns (uint256);

    /**
     * @dev Calculates the current interest index, RAY format
     */
    function calcLinearCumulative_RAY() external view returns (uint256);

    /**
     * @dev Calculates the current borrow rate, RAY format
     */
    function borrowAPY_RAY() external view returns (uint256);

    /**
     * @dev Returns the total borrowed amount (includes principal only)
     */
    function totalBorrowed() external view returns (uint256);

    /**
     * ç
     **/

    function getDieselRate_RAY() external view returns (uint256);

    /**
     * @dev Returns the address of the underlying
     */
    function underlyingToken() external view returns (address);

    /**
     * @dev Returns the address of the diesel token
     */
    function dieselToken() external view returns (address);

    /**
     * @dev Returns the address of a Credit Manager by its id
     */
    function creditManagers(uint256 id) external view returns (address);

    /**
     * @dev Returns the number of known Credit Managers
     */
    function creditManagersCount() external view returns (uint256);

    /**
     * @dev Maps Credit Manager addresses to their status as a borrower.
     *      Returns false if borrowing is not allowed.
     */
    function creditManagersCanBorrow(address id) external view returns (bool);

    
    function toDiesel(uint256 amount) external view returns (uint256);

    
    function fromDiesel(uint256 amount) external view returns (uint256);

    
    function withdrawFee() external view returns (uint256);

    
    function _timestampLU() external view returns (uint256);

    
    function _cumulativeIndex_RAY() external view returns (uint256);

    
    function addressProvider() external view returns (AddressProvider);
}

interface IPriceOracleV2Ext is IPriceOracleV2 {
    
    
    
    function addPriceFeed(address token, address priceFeed) external;
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;

interface IWETHGateway {
    
    
    
    
    function addLiquidityETH(
        address pool,
        address onBehalfOf,
        uint16 referralCode
    ) external payable;

    
    ///       - burns lp's diesel (LP) tokens
    ///       - unwraps WETH to ETH and sends to the LP
    
    
    
    function removeLiquidityETH(
        address pool,
        uint256 amount,
        address payable to
    ) external;

    
    
    
    function unwrapWETH(address to, uint256 amount) external;
}

// 

pragma solidity >=0.7.4;

interface IWETH {
    
    function deposit() external payable;

    
    function transfer(address to, uint256 value) external returns (bool);

    
    function withdraw(uint256) external;
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;

struct Balance {
    address token;
    uint256 balance;
}

library BalanceOps {
    error UnknownToken(address);

    function copyBalance(Balance memory b)
        internal
        pure
        returns (Balance memory)
    {
        return Balance({ token: b.token, balance: b.balance });
    }

    function addBalance(
        Balance[] memory b,
        address token,
        uint256 amount
    ) internal pure {
        b[getIndex(b, token)].balance += amount;
    }

    function subBalance(
        Balance[] memory b,
        address token,
        uint256 amount
    ) internal pure {
        b[getIndex(b, token)].balance -= amount;
    }

    function getBalance(Balance[] memory b, address token)
        internal
        pure
        returns (uint256 amount)
    {
        return b[getIndex(b, token)].balance;
    }

    function setBalance(
        Balance[] memory b,
        address token,
        uint256 amount
    ) internal pure {
        b[getIndex(b, token)].balance = amount;
    }

    function getIndex(Balance[] memory b, address token)
        internal
        pure
        returns (uint256 index)
    {
        for (uint256 i; i < b.length; ) {
            if (b[i].token == token) {
                return i;
            }

            unchecked {
                ++i;
            }
        }
        revert UnknownToken(token);
    }

    function copy(Balance[] memory b, uint256 len)
        internal
        pure
        returns (Balance[] memory res)
    {
        res = new Balance[](len);
        for (uint256 i; i < len; ) {
            res[i] = copyBalance(b[i]);
            unchecked {
                ++i;
            }
        }
    }

    function clone(Balance[] memory b)
        internal
        pure
        returns (Balance[] memory)
    {
        return copy(b, b.length);
    }

    function getModifiedAfterSwap(
        Balance[] memory b,
        address tokenFrom,
        uint256 amountFrom,
        address tokenTo,
        uint256 amountTo
    ) internal pure returns (Balance[] memory res) {
        res = copy(b, b.length);
        setBalance(res, tokenFrom, getBalance(b, tokenFrom) - amountFrom);
        setBalance(res, tokenTo, getBalance(b, tokenTo) + amountTo);
    }
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;


library Errors {
    //
    // COMMON
    //
    string public constant ZERO_ADDRESS_IS_NOT_ALLOWED = "Z0";
    string public constant NOT_IMPLEMENTED = "NI";
    string public constant INCORRECT_PATH_LENGTH = "PL";
    string public constant INCORRECT_ARRAY_LENGTH = "CR";
    string public constant REGISTERED_CREDIT_ACCOUNT_MANAGERS_ONLY = "CP";
    string public constant REGISTERED_POOLS_ONLY = "RP";
    string public constant INCORRECT_PARAMETER = "IP";

    //
    // MATH
    //
    string public constant MATH_MULTIPLICATION_OVERFLOW = "M1";
    string public constant MATH_ADDITION_OVERFLOW = "M2";
    string public constant MATH_DIVISION_BY_ZERO = "M3";

    //
    // POOL
    //
    string public constant POOL_CONNECTED_CREDIT_MANAGERS_ONLY = "PS0";
    string public constant POOL_INCOMPATIBLE_CREDIT_ACCOUNT_MANAGER = "PS1";
    string public constant POOL_MORE_THAN_EXPECTED_LIQUIDITY_LIMIT = "PS2";
    string public constant POOL_INCORRECT_WITHDRAW_FEE = "PS3";
    string public constant POOL_CANT_ADD_CREDIT_MANAGER_TWICE = "PS4";

    //
    // ACCOUNT FACTORY
    //
    string public constant AF_CANT_CLOSE_CREDIT_ACCOUNT_IN_THE_SAME_BLOCK =
        "AF1";
    string public constant AF_MINING_IS_FINISHED = "AF2";
    string public constant AF_CREDIT_ACCOUNT_NOT_IN_STOCK = "AF3";
    string public constant AF_EXTERNAL_ACCOUNTS_ARE_FORBIDDEN = "AF4";

    //
    // ADDRESS PROVIDER
    //
    string public constant AS_ADDRESS_NOT_FOUND = "AP1";

    //
    // CONTRACTS REGISTER
    //
    string public constant CR_POOL_ALREADY_ADDED = "CR1";
    string public constant CR_CREDIT_MANAGER_ALREADY_ADDED = "CR2";

    //
    // CREDIT ACCOUNT
    //
    string public constant CA_CONNECTED_CREDIT_MANAGER_ONLY = "CA1";
    string public constant CA_FACTORY_ONLY = "CA2";

    //
    // ACL
    //
    string public constant ACL_CALLER_NOT_PAUSABLE_ADMIN = "ACL1";
    string public constant ACL_CALLER_NOT_CONFIGURATOR = "ACL2";

    //
    // WETH GATEWAY
    //
    string public constant WG_DESTINATION_IS_NOT_WETH_COMPATIBLE = "WG1";
    string public constant WG_RECEIVE_IS_NOT_ALLOWED = "WG2";
    string public constant WG_NOT_ENOUGH_FUNDS = "WG3";

    //
    // TOKEN DISTRIBUTOR
    //
    string public constant TD_WALLET_IS_ALREADY_CONNECTED_TO_VC = "TD1";
    string public constant TD_INCORRECT_WEIGHTS = "TD2";
    string public constant TD_NON_ZERO_BALANCE_AFTER_DISTRIBUTION = "TD3";
    string public constant TD_CONTRIBUTOR_IS_NOT_REGISTERED = "TD4";
}

// 
pragma solidity ^0.8.10;

struct MultiCall {
    address target;
    bytes callData;
}

library MultiCallOps {
    function copyMulticall(MultiCall memory call)
        internal
        pure
        returns (MultiCall memory)
    {
        return MultiCall({ target: call.target, callData: call.callData });
    }

    function trim(MultiCall[] memory calls)
        internal
        pure
        returns (MultiCall[] memory trimmed)
    {
        uint256 len = calls.length;

        if (len == 0) return calls;

        uint256 foundLen;
        while (calls[foundLen].target != address(0)) {
            unchecked {
                ++foundLen;
                if (foundLen == len) return calls;
            }
        }

        if (foundLen > 0) return copy(calls, foundLen);
    }

    function copy(MultiCall[] memory calls, uint256 len)
        internal
        pure
        returns (MultiCall[] memory res)
    {
        res = new MultiCall[](len);
        for (uint256 i; i < len; ) {
            res[i] = copyMulticall(calls[i]);
            unchecked {
                ++i;
            }
        }
    }

    function clone(MultiCall[] memory calls)
        internal
        pure
        returns (MultiCall[] memory res)
    {
        return copy(calls, calls.length);
    }

    function append(MultiCall[] memory calls, MultiCall memory newCall)
        internal
        pure
        returns (MultiCall[] memory res)
    {
        uint256 len = calls.length;
        res = new MultiCall[](len + 1);
        for (uint256 i; i < len; ) {
            res[i] = copyMulticall(calls[i]);
            unchecked {
                ++i;
            }
        }
        res[len] = copyMulticall(newCall);
    }

    function prepend(MultiCall[] memory calls, MultiCall memory newCall)
        internal
        pure
        returns (MultiCall[] memory res)
    {
        uint256 len = calls.length;
        res = new MultiCall[](len + 1);
        res[0] = copyMulticall(newCall);

        for (uint256 i = 1; i < len + 1; ) {
            res[i] = copyMulticall(calls[i]);
            unchecked {
                ++i;
            }
        }
    }

    function concat(MultiCall[] memory calls1, MultiCall[] memory calls2)
        internal
        pure
        returns (MultiCall[] memory res)
    {
        uint256 len1 = calls1.length;
        uint256 lenTotal = len1 + calls2.length;

        if (lenTotal == calls1.length) return clone(calls1);
        if (lenTotal == calls2.length) return clone(calls2);

        res = new MultiCall[](lenTotal);

        for (uint256 i; i < lenTotal; ) {
            res[i] = (i < len1)
                ? copyMulticall(calls1[i])
                : copyMulticall(calls2[i - len1]);
            unchecked {
                ++i;
            }
        }
    }
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;



struct Exchange {
    address[] path;
    uint256 amountOutMin;
}

struct TokenBalance {
    address token;
    uint256 balance;
    bool isAllowed;
    bool isEnabled;
}

struct ContractAdapter {
    address allowedContract;
    address adapter;
}

struct CreditAccountData {
    address addr;
    address borrower;
    bool inUse;
    address creditManager;
    address underlying;
    uint256 borrowedAmountPlusInterest;
    uint256 borrowedAmountPlusInterestAndFees;
    uint256 totalValue;
    uint256 healthFactor;
    uint256 borrowRate;
    TokenBalance[] balances;
    uint256 repayAmount; // for v1 accounts only
    uint256 liquidationAmount; // for v1 accounts only
    bool canBeClosed; // for v1 accounts only
    uint256 borrowedAmount;
    uint256 cumulativeIndexAtOpen;
    uint256 since;
    uint8 version;
    uint256 enabledTokenMask;
}

struct CreditManagerData {
    address addr;
    address underlying;
    address pool;
    bool isWETH;
    bool canBorrow;
    uint256 borrowRate;
    uint256 minAmount;
    uint256 maxAmount;
    uint256 maxLeverageFactor; // for V1 only
    uint256 availableLiquidity;
    address[] collateralTokens;
    ContractAdapter[] adapters;
    uint256[] liquidationThresholds;
    uint8 version;
    address creditFacade; // V2 only: address of creditFacade
    address creditConfigurator; // V2 only: address of creditConfigurator
    bool isDegenMode; // V2 only: true if contract is in Degen mode
    address degenNFT; // V2 only: degenNFT, address(0) if not in degen mode
    bool isIncreaseDebtForbidden; // V2 only: true if increasing debt is forbidden
    uint256 forbiddenTokenMask; // V2 only: mask which forbids some particular tokens
    uint8 maxEnabledTokensLength; // V2 only: in V1 as many tokens as the CM can support (256)
    uint16 feeInterest; // Interest fee protocol charges: fee = interest accrues * feeInterest
    uint16 feeLiquidation; // Liquidation fee protocol charges: fee = totalValue * feeLiquidation
    uint16 liquidationDiscount; // Miltiplier to get amount which liquidator should pay: amount = totalValue * liquidationDiscount
    uint16 feeLiquidationExpired; // Liquidation fee protocol charges on expired accounts
    uint16 liquidationDiscountExpired; // Multiplier for the amount the liquidator has to pay when closing an expired account
}

struct PoolData {
    address addr;
    bool isWETH;
    address underlying;
    address dieselToken;
    uint256 linearCumulativeIndex;
    uint256 availableLiquidity;
    uint256 expectedLiquidity;
    uint256 expectedLiquidityLimit;
    uint256 totalBorrowed;
    uint256 depositAPY_RAY;
    uint256 borrowAPY_RAY;
    uint256 dieselRate_RAY;
    uint256 withdrawFee;
    uint256 cumulativeIndex_RAY;
    uint256 timestampLU;
    uint8 version;
}

struct TokenInfo {
    address addr;
    string symbol;
    uint8 decimals;
}

struct AddressProviderData {
    address contractRegister;
    address acl;
    address priceOracle;
    address traderAccountFactory;
    address dataCompressor;
    address farmingFactory;
    address accountMiner;
    address treasuryContract;
    address gearToken;
    address wethToken;
    address wethGateway;
}

struct MiningApproval {
    address token;
    address swapContract;
}

// 
pragma solidity ^0.8.10;

interface ICurvePool {
    function coins(uint256 i) external view returns (address);

    function underlying_coins(uint256 i) external view returns (address);

    function balances(uint256 i) external view returns (uint256);

    function coins(int128) external view returns (address);

    function underlying_coins(int128) external view returns (address);

    function balances(int128) external view returns (uint256);

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;

    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function get_virtual_price() external view returns (uint256);

    function token() external view returns (address);

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_amount
    ) external;

    function A() external view returns (uint256);

    function A_precise() external view returns (uint256);

    function calc_withdraw_one_coin(uint256 _burn_amount, int128 i)
        external
        view
        returns (uint256);

    function admin_balances(uint256 i) external view returns (uint256);

    function admin() external view returns (address);

    function fee() external view returns (uint256);

    function admin_fee() external view returns (uint256);

    function block_timestamp_last() external view returns (uint256);

    function initial_A() external view returns (uint256);

    function future_A() external view returns (uint256);

    function initial_A_time() external view returns (uint256);

    function future_A_time() external view returns (uint256);

    // Some pools implement ERC20

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

// 
pragma solidity >=0.7.5;




interface ISwapRouter {
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

    
    
    
    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    
    
    
    function exactInput(ExactInputParams calldata params)
        external
        payable
        returns (uint256 amountOut);

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

    
    
    
    function exactOutputSingle(ExactOutputSingleParams calldata params)
        external
        payable
        returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    
    
    
    function exactOutput(ExactOutputParams calldata params)
        external
        payable
        returns (uint256 amountIn);
}

/// 
pragma solidity ^0.8.13;







contract GearboxETHTradeExecutor is BaseTradeExecutor, CreditAccountController {
    constructor(
        address _vault,
        address _creditManager,
        address _addressProvider
    )
        BaseTradeExecutor(_vault)
        CreditAccountController(_addressProvider, _creditManager)
    {}

    
    
    
    event OpenCreditAccount(address indexed account, uint256 fraxIn);

    function openCreditAccount(uint256 fraxIn, uint256 leverage)
        external
        onlyKeeper
    {
        uint256 ethValue = priceOracle().convert(
            (fraxIn * leverage) / MAX_BPS,
            address(FRAX),
            address(WETH)
        );

        MultiCall memory call = CreditAccountController._swapETHToStETHCall(
            ethValue,
            ethValue - 1
        );

        CreditAccountController._openCreditAccount(fraxIn, ethValue, call);
        emit OpenCreditAccount(address(creditAccount()), fraxIn);
    }

    
    
    event IncreaseCollateral(uint256 fraxIn);

    function increaseCollateral(uint256 fraxIn)
        external
        onlyKeeper
        creditAccountRequired
    {
        FRAX.approve(address(creditManager()), fraxIn);
        MultiCall[] memory calls = new MultiCall[](1);
        calls[0] = CreditAccountController._addCollateralCall(fraxIn);
        creditFacade().multicall(calls);
        emit IncreaseCollateral(fraxIn);
    }

    
    
    
    event UpdatedLeverage(uint256 oldLeverage, uint256 newLeverage);

    function setLeverage(uint256 newLeverage) external onlyKeeper {
        uint256 currentLeverage = CreditAccountController.getLeverage();
        uint256 totalEquity = CreditAccountController.positionInWantToken();
        bool toBorrow = newLeverage > currentLeverage;

        if (toBorrow) {
            uint256 borrowedInWant = (totalEquity *
                (newLeverage - currentLeverage)) / MAX_BPS;
            uint256 ethIn = priceOracle().convert(
                borrowedInWant,
                address(FRAX),
                address(WETH)
            );
            increaseLeverage(ethIn);
        } else {
            uint256 borrowOutWant = (totalEquity *
                (currentLeverage - newLeverage)) / MAX_BPS;
            uint256 ethOut = priceOracle().convert(
                borrowOutWant,
                address(FRAX),
                address(WETH)
            );

            decreaseLeverage(ethOut);
        }

        emit UpdatedLeverage(currentLeverage, newLeverage);
    }

    
    
    event DebtIncrease(uint256 borrowedFunds);

    function increaseLeverage(uint256 ethIn)
        public
        onlyKeeper
        creditAccountRequired
    {
        MultiCall[] memory calls = new MultiCall[](2);
        calls[0] = CreditAccountController._increaseDebtCall(ethIn);
        uint256 amountOut = priceOracle().convert(
            ethIn,
            address(WETH),
            address(STETH)
        );
        amountOut = accountOutputSlippage(amountOut, CURVE_ETH_STETH_SLIPPAGE);
        calls[1] = CreditAccountController._swapETHToStETHCall(
            ethIn,
            amountOut - 1
        );
        creditFacade().multicall(calls);
        emit DebtIncrease(ethIn);
    }

    
    
    event DebtDecrease(uint256 payedFunds);

    function decreaseLeverage(uint256 ethOut)
        public
        onlyKeeper
        creditAccountRequired
    {
        uint256 wethBal = WETH.balanceOf(address(creditAccount()));
        MultiCall[] memory calls = new MultiCall[](1);
        uint256 amountIn = priceOracle().convert(
            ethOut,
            address(WETH),
            address(STETH)
        );
        amountIn = accountInputSlippage(amountIn, CURVE_ETH_STETH_SLIPPAGE);
        calls[0] = CreditAccountController._swapStETHToETHCall(
            amountIn,
            ethOut
        );
        creditFacade().multicall(calls);

        uint256 swapResult = WETH.balanceOf(address(creditAccount())) - wethBal;

        calls[0] = CreditAccountController._decreaseDebtCall(swapResult);

        creditFacade().multicall(calls);

        emit DebtDecrease(swapResult);
    }

    function multicall(MultiCall[] memory calls) external onlyKeeper {
        creditFacade().multicall(calls);
    }

    
    
    event CloseCreditAccount(address indexed account);

    function closeCreditAccount() external onlyKeeper creditAccountRequired {
        emit CloseCreditAccount(address(creditAccount()));
        CreditAccountController._closeCreditAccount();
    }

    function closeCreditAccountManual(
        uint256 skipTokenMask,
        bool convertWETH,
        MultiCall[] memory additionalCalls
    ) external onlyKeeper creditAccountRequired {
        creditFacade().closeCreditAccount(
            address(this),
            skipTokenMask,
            convertWETH,
            additionalCalls
        );
    }

    
    
    event Claim(uint256 yield);

    function claimYield() external onlyKeeper {
        // yieldAccumulated = stETH value - eth debt
        uint256 totalstETHInWantToken = priceOracle().convert(
            STETH.balanceOf(address(creditAccount())),
            address(STETH),
            address(FRAX)
        );
        (, , uint256 borrowedAmountAndFeesAndInterest) = creditManager()
            .calcCreditAccountAccruedInterest(address(creditAccount()));

        uint256 totalBorrowedETHInWantToken = priceOracle().convert(
            borrowedAmountAndFeesAndInterest,
            address(WETH),
            address(FRAX)
        );

        uint256 yieldAccumulated = totalstETHInWantToken >
            totalBorrowedETHInWantToken
            ? (totalstETHInWantToken - totalBorrowedETHInWantToken)
            : 0;
        if (yieldAccumulated > 0) {
            uint256 yieldAccumulatedInStETH = priceOracle().convert(
                yieldAccumulated,
                address(FRAX),
                address(STETH)
            );

            // convert stETH to wantToken via swap.
            uint256 claimedYield = CreditAccountController._convertStETHToFrax(
                yieldAccumulatedInStETH
            );
            emit Claim(claimedYield);
        }
    }

    function totalFunds()
        external
        view
        returns (uint256 posValue, uint256 lastUpdatedBlock)
    {
        posValue =
            FRAX.balanceOf(address(this)) +
            CreditAccountController.positionInWantToken();
        return (posValue, block.number);
    }

    
    event UpdatedSlippage(
        uint256 indexed oldSlippage,
        uint256 indexed newSlippage,
        uint256 indexed index
    );

    
    
    function setSlippageBound(uint256 _slippage) external onlyGovernance {
        uint256 oldSlippage = CreditAccountController.CURVE_SLIPPAGE_BOUND;

        CreditAccountController._setSlippageBound(_slippage);
        emit UpdatedSlippage(oldSlippage, _slippage, 0);
    }

    
    
    function setCurveSwapSlippage(uint256 _slippage) external onlyGovernance {
        uint256 oldSlippage = CreditAccountController.CURVE_ETH_STETH_SLIPPAGE;

        CreditAccountController._setCurveSwapSlippage(_slippage);
        emit UpdatedSlippage(oldSlippage, _slippage, 1);
    }

    
    
    function setUniETHSlippage(uint256 _slippage) external onlyGovernance {
        uint256 oldSlippage = CreditAccountController
            .UNISWAP_ETH_USDC_POOL_SLIPPAGE;

        CreditAccountController._setUniETHSlippage(_slippage);
        emit UpdatedSlippage(oldSlippage, _slippage, 2);
    }

    
    
    function setUniFRAXSlippage(uint256 _slippage) external onlyGovernance {
        uint256 oldSlippage = CreditAccountController
            .UNISWAP_ETH_FRAX_POOL_SLIPPAGE;

        CreditAccountController._setUniETHSlippage(_slippage);
        emit UpdatedSlippage(oldSlippage, _slippage, 3);
    }
}

/// 
pragma solidity ^0.8.0;

interface IVault {
    function keeper() external view returns (address);

    function governance() external view returns (address);

    function wantToken() external view returns (address);

    function deposit(uint256 amountIn, address receiver) external returns (uint256 shares);

    function withdraw(uint256 sharesIn, address receiver) external returns (uint256 amountOut);
    function batcher() external view returns (address);
    function zapper() external view returns (address);
}

/// 
pragma solidity ^0.8.10;

interface IstETH {
    function submit(uint256 amount) external returns (uint256 value);
}

interface IwstETH is IwstETHGetters {
    /**
     * @notice Exchanges stETH to wstETH
     * @param _stETHAmount amount of stETH to wrap in exchange for wstETH
     * @dev Requirements:
     *  - `_stETHAmount` must be non-zero
     *  - msg.sender must approve at least `_stETHAmount` stETH to this
     *    contract.
     *  - msg.sender must have at least `_stETHAmount` of stETH.
     * User should first approve _stETHAmount to the WstETH contract
     * @return Amount of wstETH user receives after wrap
     */
    function wrap(uint256 _stETHAmount) external returns (uint256);

    /**
     * @notice Exchanges wstETH to stETH
     * @param _wstETHAmount amount of wstETH to uwrap in exchange for stETH
     * @dev Requirements:
     *  - `_wstETHAmount` must be non-zero
     *  - msg.sender must have at least `_wstETHAmount` wstETH.
     * @return Amount of stETH user receives after unwrap
     */
    function unwrap(uint256 _wstETHAmount) external returns (uint256);
}