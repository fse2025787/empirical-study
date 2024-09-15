// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;



/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
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

// 
pragma solidity >=0.8.4;




/// account (an owner) that can be granted exclusive access to specific functions.
///
/// By default, the owner account will be the one that deploys the contract. This can later be
/// changed with {transfer}.
///
/// This module is used through inheritance. It will make available the modifier `onlyOwner`,
/// which can be applied to your functions to restrict their use to the owner.
///

/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/Ownable.sol
interface IOwnable {
    /// EVENTS ///

    
    
    
    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    /// NON-CONSTANT FUNCTIONS ///

    
    /// functions anymore.
    ///
    /// WARNING: Doing this will leave the contract without an owner, thereby removing any
    /// functionality that is only available to the owner.
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    function _renounceOwnership() external;

    
    /// called by the current owner.
    
    function _transferOwnership(address newOwner) external;

    /// CONSTANT FUNCTIONS ///

    
    
    function owner() external view returns (address);
}

// 
pragma solidity >=0.8.4;




///
/// We have followed general OpenZeppelin guidelines: functions revert instead of returning
/// `false` on failure. This behavior is nonetheless conventional and does not conflict with
/// the with the expectations of Erc20 applications.
///
/// Additionally, an {Approval} event is emitted on calls to {transferFrom}. This allows
/// applications to reconstruct the allowance for all accounts just by listening to said
/// events. Other implementations of the Erc may not emit these events, as it isn't
/// required by the specification.
///
/// Finally, the non-standard {decreaseAllowance} and {increaseAllowance} functions have been
/// added to mitigate the well-known issues around setting allowances.
///

/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/ERC20.sol
interface IErc20 {
    /// EVENTS ///

    
    
    
    
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    
    
    
    
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// CONSTANT FUNCTIONS ///

    
    /// on behalf of `owner` through {transferFrom}. This is zero by default.
    ///
    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function decimals() external view returns (uint8);

    
    function name() external view returns (string memory);

    
    function symbol() external view returns (string memory);

    
    function totalSupply() external view returns (uint256);

    /// NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// IMPORTANT: Beware that changing an allowance with this method brings the risk that someone may
    /// use both the old and the new allowance by unfortunate transaction ordering. One possible solution
    /// to mitigate this race condition is to first reduce the spender's allowance to 0 and set the desired
    /// value afterwards: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    ///
    /// Requirements:
    ///
    /// - `spender` cannot be the zero address.
    ///
    
    function approve(address spender, uint256 amount) external returns (bool);

    
    ///
    
    ///
    /// This is an alternative to {approve} that can be used as a mitigation for problems described
    /// in {Erc20Interface-approve}.
    ///
    /// Requirements:
    ///
    /// - `spender` cannot be the zero address.
    /// - `spender` must have allowance for the caller of at least `subtractedAmount`.
    function decreaseAllowance(address spender, uint256 subtractedAmount) external returns (bool);

    
    ///
    
    ///
    /// This is an alternative to {approve} that can be used as a mitigation for the problems described above.
    ///
    /// Requirements:
    ///
    /// - `spender` cannot be the zero address.
    function increaseAllowance(address spender, uint256 addedAmount) external returns (bool);

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - `recipient` cannot be the zero address.
    /// - The caller must have a balance of at least `amount`.
    ///
    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    /// `is then deducted from the caller's allowance.
    ///
    
    /// not required by the Erc. See the note at the beginning of {Erc20}.
    ///
    /// Requirements:
    ///
    /// - `sender` and `recipient` cannot be the zero address.
    /// - `sender` must have a balance of at least `amount`.
    /// - The caller must have approed `sender` to spent at least `amount` tokens.
    ///
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// 
pragma solidity >=0.8.4;



interface IOwnableUpgradeable {
    /// CUSTOM ERRORS ///

    
    error OwnableUpgradeable__NotOwner(address owner, address caller);

    
    error OwnableUpgradeable__OwnerZeroAddress();

    /// EVENTS ///

    
    
    
    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    /// CONSTANT FUNCTIONS ///

    
    
    function owner() external view returns (address);

    /// NON-CONSTANT FUNCTIONS ///

    
    /// functions anymore.
    ///
    /// WARNING: Doing this will leave the contract without an owner, thereby removing any
    /// functionality that is only available to the owner.
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    function _renounceOwnership() external;

    
    /// called by the current owner.
    
    function _transferOwnership(address newOwner) external;
}

// 
pragma solidity ^0.8.4;









abstract contract SBalanceSheetV1 {
    /// STRUCTS ///

    
    struct Vault {
        IHToken[] bondList;
        mapping(IErc20 => uint256) collateralAmounts;
        IErc20[] collateralList;
        mapping(IHToken => uint256) debtAmounts;
    }

    /// PUBLIC STORAGE ///

    
    IFintroller public fintroller;

    
    IChainlinkOperator public oracle;

    
    mapping(address => Vault) internal vaults;
}
// 
pragma solidity >=0.8.4;











interface IBalanceSheetV2 is IOwnableUpgradeable {
    /// CUSTOM ERRORS ///

    
    error BalanceSheet__BondMatured(IHToken bond);

    
    error BalanceSheet__BorrowMaxBonds(IHToken bond, uint256 newBondListLength, uint256 maxBonds);

    
    error BalanceSheet__DepositMaxCollaterals(
        IErc20 collateral,
        uint256 newCollateralListLength,
        uint256 maxCollaterals
    );

    
    error BalanceSheet__BorrowNotAllowed(IHToken bond);

    
    error BalanceSheet__BorrowZero();

    
    error BalanceSheet__CollateralCeilingOverflow(uint256 newTotalSupply, uint256 debtCeiling);

    
    error BalanceSheet__DebtCeilingOverflow(uint256 newCollateralAmount, uint256 debtCeiling);

    
    error BalanceSheet__DepositCollateralNotAllowed(IErc20 collateral);

    
    error BalanceSheet__DepositCollateralZero();

    
    error BalanceSheet__FintrollerZeroAddress();

    
    error BalanceSheet__LiquidateBorrowInsufficientCollateral(
        address account,
        uint256 vaultCollateralAmount,
        uint256 seizableAmount
    );

    
    error BalanceSheet__LiquidateBorrowNotAllowed(IHToken bond);

    
    error BalanceSheet__LiquidateBorrowSelf(address account);

    
    error BalanceSheet__LiquidityShortfall(address account, uint256 shortfallLiquidity);

    
    error BalanceSheet__NoLiquidityShortfall(address account);

    
    error BalanceSheet__OracleZeroAddress();

    
    error BalanceSheet__RepayBorrowInsufficientBalance(IHToken bond, uint256 repayAmount, uint256 hTokenBalance);

    
    error BalanceSheet__RepayBorrowInsufficientDebt(IHToken bond, uint256 repayAmount, uint256 debtAmount);

    
    error BalanceSheet__RepayBorrowNotAllowed(IHToken bond);

    
    error BalanceSheet__RepayBorrowZero();

    
    error BalanceSheet__WithdrawCollateralUnderflow(
        address account,
        uint256 vaultCollateralAmount,
        uint256 withdrawAmount
    );

    
    error BalanceSheet__WithdrawCollateralZero();

    /// EVENTS ///

    
    
    
    
    event Borrow(address indexed account, IHToken indexed bond, uint256 borrowAmount);

    
    
    
    
    event DepositCollateral(address indexed account, IErc20 indexed collateral, uint256 collateralAmount);

    
    
    
    
    
    
    
    event LiquidateBorrow(
        address indexed liquidator,
        address indexed borrower,
        IHToken indexed bond,
        uint256 repayAmount,
        IErc20 collateral,
        uint256 seizedCollateralAmount
    );

    
    
    
    
    
    
    event RepayBorrow(
        address indexed payer,
        address indexed borrower,
        IHToken indexed bond,
        uint256 repayAmount,
        uint256 newDebtAmount
    );

    
    
    
    
    event SetFintroller(address indexed owner, address oldFintroller, address newFintroller);

    
    
    
    
    event SetOracle(address indexed owner, address oldOracle, address newOracle);

    
    
    
    
    event WithdrawCollateral(address indexed account, IErc20 indexed collateral, uint256 collateralAmount);

    /// CONSTANT FUNCTIONS ///

    
    
    
    function getBondList(address account) external view returns (IHToken[] memory);

    
    
    
    
    function getCollateralAmount(address account, IErc20 collateral) external view returns (uint256 collateralAmount);

    
    
    
    function getCollateralList(address account) external view returns (IErc20[] memory);

    
    
    
    
    function getCurrentAccountLiquidity(address account)
        external
        view
        returns (uint256 excessLiquidity, uint256 shortfallLiquidity);

    
    
    
    
    function getDebtAmount(address account, IHToken bond) external view returns (uint256 debtAmount);

    
    /// using the current prices provided by the oracle.
    ///
    
    /// respective collateral ratio, then dividing the sum by the total amount of debt drawn by the user.
    ///
    /// Caveats:
    /// - This function expects that the "collateralList" and the "bondList" are each modified in advance to include
    /// the collateral and bond due to be modified.
    ///
    
    
    
    
    
    
    
    function getHypotheticalAccountLiquidity(
        address account,
        IErc20 collateralModify,
        uint256 collateralAmountModify,
        IHToken bondModify,
        uint256 debtAmountModify
    ) external view returns (uint256 excessLiquidity, uint256 shortfallLiquidity);

    
    /// Note that this is for informational purposes only, it doesn't say anything about whether the user can be
    /// liquidated.
    
    /// repayAmount = (seizableCollateralAmount * collateralPriceUsd) / (liquidationIncentive * underlyingPriceUsd)
    
    
    
    
    function getRepayAmount(
        IErc20 collateral,
        uint256 seizableCollateralAmount,
        IHToken bond
    ) external view returns (uint256 repayAmount);

    
    /// is for informational purposes only, it doesn't say anything about whether the user can be liquidated.
    
    /// seizableCollateralAmount = repayAmount * liquidationIncentive * underlyingPriceUsd / collateralPriceUsd
    
    
    
    
    function getSeizableCollateralAmount(
        IHToken bond,
        uint256 repayAmount,
        IErc20 collateral
    ) external view returns (uint256 seizableCollateralAmount);

    /// NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The Fintroller must allow this action to be performed.
    /// - The maturity of the bond must be in the future.
    /// - The amount to borrow cannot be zero.
    /// - The new length of the bond list must be below the max bonds limit.
    /// - The new total amount of debt cannot exceed the debt ceiling.
    /// - The caller must not end up having a shortfall of liquidity.
    ///
    
    
    function borrow(IHToken bond, uint256 borrowAmount) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The Fintroller must allow this action to be performed.
    /// - The amount to deposit cannot be zero.
    /// - The caller must have allowed this contract to spend `collateralAmount` tokens.
    /// - The new collateral amount cannot exceed the collateral ceiling.
    ///
    
    
    function depositCollateral(IErc20 collateral, uint256 depositAmount) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - All from "repayBorrow".
    /// - The caller cannot be the same with the borrower.
    /// - The Fintroller must allow this action to be performed.
    /// - The borrower must have a shortfall of liquidity if the bond didn't mature.
    /// - The amount of seized collateral cannot be more than what the borrower has in the vault.
    ///
    
    
    
    
    function liquidateBorrow(
        address borrower,
        IHToken bond,
        uint256 repayAmount,
        IErc20 collateral
    ) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The amount to repay cannot be zero.
    /// - The Fintroller must allow this action to be performed.
    /// - The caller must have at least `repayAmount` hTokens.
    /// - The caller must have at least `repayAmount` debt.
    ///
    
    
    function repayBorrow(IHToken bond, uint256 repayAmount) external;

    
    ///
    
    ///
    /// Requirements:
    /// - Same as the `repayBorrow` function, but here `borrower` is the account that must have at least
    /// `repayAmount` hTokens to repay the borrow.
    ///
    
    
    
    function repayBorrowBehalf(
        address borrower,
        IHToken bond,
        uint256 repayAmount
    ) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The new address cannot be the zero address.
    ///
    
    function setFintroller(IFintroller newFintroller) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The new address cannot be the zero address.
    ///
    
    function setOracle(IChainlinkOperator newOracle) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The amount to withdraw cannot be zero.
    /// - There must be enough collateral in the vault.
    /// - The caller's account cannot fall below the collateral ratio.
    ///
    
    
    function withdrawCollateral(IErc20 collateral, uint256 withdrawAmount) external;
}

// 
pragma solidity ^0.8.4;





abstract contract SBalanceSheetV2 is SBalanceSheetV1 {
    // solhint-disable-previous-line no-empty-blocks
}

// 
pragma solidity ^0.8.4;








/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/Ownable.sol
contract OwnableUpgradeable is
    IOwnableUpgradeable, // no dependency
    Initializable // no dependency
{
    /// PUBLIC STORAGE ///

    
    address public override owner;

    /// PRIVATE STORAGE ///

    
    uint256[50] private __gap;

    /// MODIFIERS ///

    
    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert OwnableUpgradeable__NotOwner(owner, msg.sender);
        }
        _;
    }

    /// INITIALIZER ///

    
    
    function __Ownable_init() internal onlyInitializing {
        owner = msg.sender;
        emit TransferOwnership(address(0), msg.sender);
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function _renounceOwnership() external virtual override onlyOwner {
        emit TransferOwnership(owner, address(0));
        owner = address(0);
    }

    
    function _transferOwnership(address newOwner) external virtual override onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableUpgradeable__OwnerZeroAddress();
        }
        emit TransferOwnership(owner, newOwner);
        owner = newOwner;
    }
}

// 
// solhint-disable func-name-mixedcase
pragma solidity >=0.8.4;






/// transactions by setting the allowance with a signature using the `permit` method, and then spend
/// them via `transferFrom`.

interface IErc20Permit is IErc20 {
    /// NON-CONSTANT FUNCTIONS ///

    
    /// signed approval.
    ///
    
    ///
    /// IMPORTANT: The same issues Erc20 `approve` has related to transaction
    /// ordering also apply here.
    ///
    /// Requirements:
    ///
    /// - `owner` cannot be the zero address.
    /// - `spender` cannot be the zero address.
    /// - `deadline` must be a timestamp in the future.
    /// - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner` over the Eip712-formatted
    /// function arguments.
    /// - The signature must use `owner`'s current nonce.
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /// CONSTANT FUNCTIONS ///

    
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    
    function nonces(address account) external view returns (uint256);

    
    function PERMIT_TYPEHASH() external view returns (bytes32);

    
    function version() external view returns (string memory);
}

// 
// solhint-disable var-name-mixedcase
pragma solidity >=0.8.4;







/// (accidentally, or not) to the contract.
interface IErc20Recover is IOwnable {
    /// EVENTS ///

    
    
    
    
    event Recover(address indexed owner, IErc20 token, uint256 recoverAmount);

    
    
    
    event SetNonRecoverableTokens(address indexed owner, IErc20[] nonRecoverableTokens);

    /// NON-CONSTANT FUNCTIONS ///

    
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The contract must be initialized.
    /// - The amount to recover cannot be zero.
    /// - The token to recover cannot be among the non-recoverable tokens.
    ///
    
    
    function _recover(IErc20 token, uint256 recoverAmount) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The contract cannot be already initialized.
    ///
    
    function _setNonRecoverableTokens(IErc20[] calldata tokens) external;

    /// CONSTANT FUNCTIONS ///

    
    function nonRecoverableTokens(uint256 index) external view returns (IErc20);
}
// 
pragma solidity ^0.8.4;














contract BalanceSheetV2 is
    Initializable, // no dependency
    OwnableUpgradeable, // two dependencies
    IBalanceSheetV2, // one dependency
    SBalanceSheetV2 // no dependency
{
    using PRBMathUD60x18 for uint256;
    using SafeErc20 for IErc20;

    /// INITIALIZER ///

    
    
    
    function initialize(IFintroller fintroller_, IChainlinkOperator oracle_) public initializer {
        // Initialize the owner.
        __Ownable_init();

        // Set the Fintroller contract.
        fintroller = fintroller_;

        // Set the oracle contract.
        oracle = oracle_;
    }

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    function getBondList(address account) external view override returns (IHToken[] memory) {
        return vaults[account].bondList;
    }

    
    function getCollateralAmount(address account, IErc20 collateral)
        external
        view
        override
        returns (uint256 collateralAmount)
    {
        return vaults[account].collateralAmounts[collateral];
    }

    
    function getCollateralList(address account) external view override returns (IErc20[] memory) {
        return vaults[account].collateralList;
    }

    
    function getCurrentAccountLiquidity(address account)
        public
        view
        override
        returns (uint256 excessLiquidity, uint256 shortfallLiquidity)
    {
        return getHypotheticalAccountLiquidity(account, IErc20(address(0)), 0, IHToken(address(0)), 0);
    }

    
    function getDebtAmount(address account, IHToken bond) external view override returns (uint256 debtAmount) {
        return vaults[account].debtAmounts[bond];
    }

    struct HypotheticalAccountLiquidityLocalVars {
        uint256 bondListLength;
        uint256 collateralAmount;
        uint256 collateralDecimals;
        uint256 collateralListLength;
        uint256 collateralRatio;
        uint256 collateralValueUsd;
        uint256 debtAmount;
        uint256 debtValueUsd;
        uint256 normalizedCollateralAmount;
        uint256 normalizedCollateralPrice;
        uint256 totalDebtValueUsd;
        uint256 totalWeightedCollateralValueUsd;
        uint256 normalizedUnderlyingPrice;
        uint256 weightedCollateralValueUsd;
    }

    
    function getHypotheticalAccountLiquidity(
        address account,
        IErc20 collateralModify,
        uint256 collateralAmountModify,
        IHToken bondModify,
        uint256 debtAmountModify
    ) public view override returns (uint256 excessLiquidity, uint256 shortfallLiquidity) {
        HypotheticalAccountLiquidityLocalVars memory vars;

        // Load into memory for faster iteration.
        IErc20[] memory collateralList = vaults[account].collateralList;
        vars.collateralListLength = collateralList.length;

        // Sum up each collateral USD value divided by the collateral ratio.
        for (uint256 i = 0; i < vars.collateralListLength; i++) {
            IErc20 collateral = collateralList[i];

            if (collateralModify != collateral) {
                vars.collateralAmount = vaults[account].collateralAmounts[collateral];
            } else {
                vars.collateralAmount = collateralAmountModify;
            }

            // Normalize the collateral amount.
            vars.collateralDecimals = collateral.decimals();
            if (vars.collateralDecimals != 18) {
                vars.normalizedCollateralAmount = vars.collateralAmount.div(10**vars.collateralDecimals);
            } else {
                vars.normalizedCollateralAmount = vars.collateralAmount;
            }

            // Grab the normalized USD price of the collateral.
            vars.normalizedCollateralPrice = oracle.getNormalizedPrice(collateral.symbol());

            // Calculate the USD value of the collateral amount.
            vars.collateralValueUsd = vars.normalizedCollateralAmount.mul(vars.normalizedCollateralPrice);

            // Calculate the USD value of the weighted collateral by dividing the USD value of the collateral amount
            // by the collateral ratio.
            vars.collateralRatio = fintroller.getCollateralRatio(collateral);
            vars.weightedCollateralValueUsd = vars.collateralValueUsd.div(vars.collateralRatio);

            // Add the previously calculated USD value of the weighted collateral to the totals.
            vars.totalWeightedCollateralValueUsd += vars.weightedCollateralValueUsd;
        }

        // Load into memory for faster iteration.
        IHToken[] memory bondList = vaults[account].bondList;
        vars.bondListLength = bondList.length;

        // Sum up all bond debts.
        for (uint256 i = 0; i < vars.bondListLength; i++) {
            IHToken bond = bondList[i];

            if (bondModify != bond) {
                vars.debtAmount = vaults[account].debtAmounts[bond];
            } else {
                vars.debtAmount = debtAmountModify;
            }

            // Grab the normalized USD price of the underlying.
            vars.normalizedUnderlyingPrice = oracle.getNormalizedPrice(bond.underlying().symbol());

            // Calculate the USD value of the collateral amount.
            vars.debtValueUsd = vars.debtAmount.mul(vars.normalizedUnderlyingPrice);

            // Add the previously calculated USD value to the totals.
            vars.totalDebtValueUsd += vars.debtValueUsd;
        }

        // Excess liquidity when there is more weighted collateral than debt, and shortfall liquidity when there is
        // less weighted collateral than debt.
        unchecked {
            if (vars.totalWeightedCollateralValueUsd > vars.totalDebtValueUsd) {
                excessLiquidity = vars.totalWeightedCollateralValueUsd - vars.totalDebtValueUsd;
            } else {
                shortfallLiquidity = vars.totalDebtValueUsd - vars.totalWeightedCollateralValueUsd;
            }
        }
    }

    
    function getRepayAmount(
        IErc20 collateral,
        uint256 seizableCollateralAmount,
        IHToken bond
    ) public view override returns (uint256 repayAmount) {
        // Normalize the collateral amount.
        uint256 normalizedSeizableAmount;
        uint256 collateralDecimals = collateral.decimals();
        if (collateralDecimals != 18) {
            normalizedSeizableAmount = seizableCollateralAmount.div(10**collateralDecimals);
        } else {
            normalizedSeizableAmount = seizableCollateralAmount;
        }

        // Grab the normalized USD price of the collateral.
        uint256 normalizedCollateralPrice = oracle.getNormalizedPrice(collateral.symbol());

        // Grab the normalized USD price of the underlying.
        uint256 normalizedUnderlyingPrice = oracle.getNormalizedPrice(bond.underlying().symbol());

        // Calculate the top part of the equation.
        uint256 numerator = normalizedSeizableAmount.mul(normalizedCollateralPrice);

        // Calculate the repay amount.
        uint256 liquidationIncentive = fintroller.getLiquidationIncentive(collateral);
        repayAmount = numerator.div(liquidationIncentive.mul(normalizedUnderlyingPrice));
    }

    
    function getSeizableCollateralAmount(
        IHToken bond,
        uint256 repayAmount,
        IErc20 collateral
    ) public view override returns (uint256 seizableCollateralAmount) {
        // Grab the normalized USD price of the collateral.
        uint256 normalizedCollateralPrice = oracle.getNormalizedPrice(collateral.symbol());

        // Grab the normalized USD price of the underlying.
        uint256 normalizedUnderlyingPrice = oracle.getNormalizedPrice(bond.underlying().symbol());

        // Calculate the top part of the equation.
        uint256 liquidationIncentive = fintroller.getLiquidationIncentive(collateral);
        uint256 numerator = repayAmount.mul(liquidationIncentive.mul(normalizedUnderlyingPrice));

        // Calculate the normalized seizable collateral amount.
        uint256 normalizedSeizableCollateralAmount = numerator.div(normalizedCollateralPrice);

        // Denormalize the collateral amount.
        unchecked {
            uint256 collateralDecimals = collateral.decimals();
            if (collateralDecimals != 18) {
                seizableCollateralAmount = normalizedSeizableCollateralAmount.mul(10**collateralDecimals);
            } else {
                seizableCollateralAmount = normalizedSeizableCollateralAmount;
            }
        }
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    // @inheritdoc IHToken
    function borrow(IHToken bond, uint256 borrowAmount) public override {
        // Checks: the Fintroller allows this action to be performed.
        if (!fintroller.getBorrowAllowed(bond)) {
            revert BalanceSheet__BorrowNotAllowed(bond);
        }

        // Checks: bond not matured.
        if (bond.isMatured()) {
            revert BalanceSheet__BondMatured(bond);
        }

        // Checks: the zero edge case.
        if (borrowAmount == 0) {
            revert BalanceSheet__BorrowZero();
        }

        // Checks: debt ceiling.
        uint256 newTotalSupply = bond.totalSupply() + borrowAmount;
        uint256 debtCeiling = fintroller.getDebtCeiling(bond);
        if (newTotalSupply > debtCeiling) {
            revert BalanceSheet__DebtCeilingOverflow(newTotalSupply, debtCeiling);
        }

        // Add the borrow amount to the borrower account's current debt.
        uint256 newDebtAmount = vaults[msg.sender].debtAmounts[bond] + borrowAmount;

        // Effects: add the bond to the redundant list if it hasn't been added already.
        if (vaults[msg.sender].debtAmounts[bond] == 0) {
            // Checks: below max bonds limit.
            unchecked {
                uint256 newBondListLength = vaults[msg.sender].bondList.length + 1;
                uint256 maxBonds = fintroller.maxBonds();
                if (newBondListLength > maxBonds) {
                    revert BalanceSheet__BorrowMaxBonds(bond, newBondListLength, maxBonds);
                }
            }
            vaults[msg.sender].bondList.push(bond);
        }

        // Checks: there is no liquidity shortfall.
        (, uint256 hypotheticalShortfallLiquidity) = getHypotheticalAccountLiquidity(
            msg.sender,
            IErc20(address(0)),
            0,
            bond,
            newDebtAmount
        );
        if (hypotheticalShortfallLiquidity > 0) {
            revert BalanceSheet__LiquidityShortfall(msg.sender, hypotheticalShortfallLiquidity);
        }

        // Effects: increase the amount of debt in the vault.
        vaults[msg.sender].debtAmounts[bond] = newDebtAmount;

        // Interactions: print the new hTokens into existence.
        bond.mint(msg.sender, borrowAmount);

        // Emit a Borrow event.
        emit Borrow(msg.sender, bond, borrowAmount);
    }

    
    function depositCollateral(IErc20 collateral, uint256 depositAmount) external override {
        // Checks: the Fintroller allows this action to be performed.
        if (!fintroller.getDepositCollateralAllowed(collateral)) {
            revert BalanceSheet__DepositCollateralNotAllowed(collateral);
        }

        // Checks: the zero edge case.
        if (depositAmount == 0) {
            revert BalanceSheet__DepositCollateralZero();
        }

        // Checks: collateral ceiling.
        uint256 newCollateralAmount = collateral.balanceOf(address(this)) + depositAmount;
        uint256 collateralCeiling = fintroller.getCollateralCeiling(collateral);
        if (newCollateralAmount > collateralCeiling) {
            revert BalanceSheet__CollateralCeilingOverflow(newCollateralAmount, collateralCeiling);
        }

        // Effects: add the collateral to the redundant list, if this is the first time collateral is added.
        uint256 collateralAmount = vaults[msg.sender].collateralAmounts[collateral];
        if (collateralAmount == 0) {
            // Checks: below max collaterals limit.
            unchecked {
                uint256 newCollateralListLength = vaults[msg.sender].collateralList.length + 1;
                uint256 maxCollaterals = fintroller.maxCollaterals();
                if (newCollateralListLength > maxCollaterals) {
                    revert BalanceSheet__DepositMaxCollaterals(collateral, newCollateralListLength, maxCollaterals);
                }
            }
            vaults[msg.sender].collateralList.push(collateral);
        }

        // Effects: increase the amount of collateral in the vault.
        vaults[msg.sender].collateralAmounts[collateral] = collateralAmount + depositAmount;

        // Interactions: perform the Erc20 transfer.
        collateral.safeTransferFrom(msg.sender, address(this), depositAmount);

        // Emit a DepositCollateral event.
        emit DepositCollateral(msg.sender, collateral, depositAmount);
    }

    
    function liquidateBorrow(
        address borrower,
        IHToken bond,
        uint256 repayAmount,
        IErc20 collateral
    ) external override {
        // Checks: caller not the borrower.
        if (msg.sender == borrower) {
            revert BalanceSheet__LiquidateBorrowSelf(borrower);
        }

        // Checks: the Fintroller allows this action to be performed.
        if (!fintroller.getLiquidateBorrowAllowed(bond)) {
            revert BalanceSheet__LiquidateBorrowNotAllowed(bond);
        }

        // After maturation, any vault can be liquidated, irrespective of account liquidity.
        if (!bond.isMatured()) {
            // Checks: the borrower has a shortfall of liquidity.
            (, uint256 shortfallLiquidity) = getCurrentAccountLiquidity(borrower);
            if (shortfallLiquidity == 0) {
                revert BalanceSheet__NoLiquidityShortfall(borrower);
            }
        }

        // Checks: there is enough collateral in the vault.
        uint256 vaultCollateralAmount = vaults[borrower].collateralAmounts[collateral];
        uint256 seizableCollateralAmount = getSeizableCollateralAmount(bond, repayAmount, collateral);
        if (vaultCollateralAmount < seizableCollateralAmount) {
            revert BalanceSheet__LiquidateBorrowInsufficientCollateral(
                borrower,
                vaultCollateralAmount,
                seizableCollateralAmount
            );
        }

        // Effects & Interactions: repay the borrower's debt.
        repayBorrowInternal(msg.sender, borrower, bond, repayAmount);

        // Calculate the new collateral amount.
        uint256 newCollateralAmount;
        unchecked {
            newCollateralAmount = vaults[borrower].collateralAmounts[collateral] - seizableCollateralAmount;
        }

        // Effects: decrease the amount of collateral in the vault.
        vaults[borrower].collateralAmounts[collateral] = newCollateralAmount;

        // Effects: delete the collateral from the redundant list, if the resultant amount of collateral is zero.
        if (newCollateralAmount == 0) {
            removeCollateralFromList(borrower, collateral);
        }

        // Interactions: seize the collateral.
        collateral.safeTransfer(msg.sender, seizableCollateralAmount);

        // Emit a LiquidateBorrow event.
        emit LiquidateBorrow(msg.sender, borrower, bond, repayAmount, collateral, seizableCollateralAmount);
    }

    
    function repayBorrow(IHToken bond, uint256 repayAmount) external override {
        repayBorrowInternal(msg.sender, msg.sender, bond, repayAmount);
    }

    
    function repayBorrowBehalf(
        address borrower,
        IHToken bond,
        uint256 repayAmount
    ) external override onlyOwner {
        repayBorrowInternal(msg.sender, borrower, bond, repayAmount);
    }

    
    function setFintroller(IFintroller newFintroller) external override onlyOwner {
        if (address(newFintroller) == address(0)) {
            revert BalanceSheet__FintrollerZeroAddress();
        }
        address oldFintroller = address(fintroller);
        fintroller = newFintroller;
        emit SetFintroller(owner, oldFintroller, address(newFintroller));
    }

    
    function setOracle(IChainlinkOperator newOracle) external override onlyOwner {
        if (address(newOracle) == address(0)) {
            revert BalanceSheet__OracleZeroAddress();
        }
        address oldOracle = address(oracle);
        oracle = newOracle;
        emit SetOracle(owner, oldOracle, address(newOracle));
    }

    
    function withdrawCollateral(IErc20 collateral, uint256 withdrawAmount) external override {
        // Checks: the zero edge case.
        if (withdrawAmount == 0) {
            revert BalanceSheet__WithdrawCollateralZero();
        }

        // Checks: there is enough collateral in the vault.
        uint256 vaultCollateralAmount = vaults[msg.sender].collateralAmounts[collateral];
        if (vaultCollateralAmount < withdrawAmount) {
            revert BalanceSheet__WithdrawCollateralUnderflow(msg.sender, vaultCollateralAmount, withdrawAmount);
        }

        // Calculate the new collateral amount.
        uint256 newCollateralAmount;
        unchecked {
            newCollateralAmount = vaultCollateralAmount - withdrawAmount;
        }

        // Checks: the hypothetical account liquidity is okay.
        if (vaults[msg.sender].bondList.length > 0) {
            (, uint256 hypotheticalShortfallLiquidity) = getHypotheticalAccountLiquidity(
                msg.sender,
                collateral,
                newCollateralAmount,
                IHToken(address(0)),
                0
            );
            if (hypotheticalShortfallLiquidity > 0) {
                revert BalanceSheet__LiquidityShortfall(msg.sender, hypotheticalShortfallLiquidity);
            }
        }

        // Effects: decrease the amount of collateral in the vault.
        vaults[msg.sender].collateralAmounts[collateral] = newCollateralAmount;

        // Effects: delete the collateral from the redundant list, if the resultant amount of collateral is zero.
        if (newCollateralAmount == 0) {
            removeCollateralFromList(msg.sender, collateral);
        }

        // Interactions: perform the Erc20 transfer.
        collateral.safeTransfer(msg.sender, withdrawAmount);

        // Emit a WithdrawCollateral event.
        emit WithdrawCollateral(msg.sender, collateral, withdrawAmount);
    }

    /// INTERNAL NON-CONSTANT FUNCTIONS ///

    
    function removeBondFromList(address account, IHToken bond) internal {
        // Load into memory for faster iteration.
        IHToken[] memory memoryBondList = vaults[account].bondList;
        uint256 length = memoryBondList.length;

        // Find the index where the bond is stored at.
        uint256 bondIndex = length;
        for (uint256 i = 0; i < length; i++) {
            if (memoryBondList[i] == bond) {
                bondIndex = i;
                break;
            }
        }

        // We must have found the bond in the list or the redundant data structure is broken.
        assert(bondIndex < length);

        // Copy last item in list to location of item to be removed, reduce length by 1.
        IHToken[] storage storedBondList = vaults[account].bondList;
        storedBondList[bondIndex] = storedBondList[length - 1];
        storedBondList.pop();
    }

    
    function removeCollateralFromList(address account, IErc20 collateral) internal {
        // Load into memory for faster iteration.
        IErc20[] memory memoryCollateralList = vaults[account].collateralList;
        uint256 length = memoryCollateralList.length;

        // Find the index where the collateral is stored at.
        uint256 collateralIndex = length;
        for (uint256 i = 0; i < length; i++) {
            if (memoryCollateralList[i] == collateral) {
                collateralIndex = i;
                break;
            }
        }

        // We must have found the collateral in the list or the redundant data structure is broken.
        assert(collateralIndex < length);

        // Copy last item in list to location of item to be removed, reduce length by 1.
        IErc20[] storage storedCollateralList = vaults[account].collateralList;
        storedCollateralList[collateralIndex] = storedCollateralList[length - 1];
        storedCollateralList.pop();
    }

    
    function repayBorrowInternal(
        address payer,
        address borrower,
        IHToken bond,
        uint256 repayAmount
    ) internal {
        // Checks: the Fintroller allows this action to be performed.
        if (!fintroller.getRepayBorrowAllowed(bond)) {
            revert BalanceSheet__RepayBorrowNotAllowed(bond);
        }

        // Checks: the zero edge case.
        if (repayAmount == 0) {
            revert BalanceSheet__RepayBorrowZero();
        }

        // Checks: borrower has debt.
        uint256 debtAmount = vaults[borrower].debtAmounts[bond];
        if (debtAmount < repayAmount) {
            revert BalanceSheet__RepayBorrowInsufficientDebt(bond, repayAmount, debtAmount);
        }

        // Checks: the payer has enough hTokens.
        uint256 hTokenBalance = bond.balanceOf(payer);
        if (hTokenBalance < repayAmount) {
            revert BalanceSheet__RepayBorrowInsufficientBalance(bond, repayAmount, hTokenBalance);
        }

        // Effects: decrease the amount of debt in the vault.
        uint256 newDebtAmount;
        unchecked {
            newDebtAmount = vaults[borrower].debtAmounts[bond] - repayAmount;
            vaults[borrower].debtAmounts[bond] = newDebtAmount;
        }

        // Effects: delete the bond from the redundant list, if the resultant amount of debt is zero.
        if (newDebtAmount == 0) {
            removeBondFromList(borrower, bond);
        }

        // Interactions: burn the hTokens.
        bond.burn(payer, repayAmount);

        // Emit a RepayBorrow event.
        emit RepayBorrow(payer, borrower, bond, repayAmount, newDebtAmount);
    }
}

// 
pragma solidity >=0.8.4;





error SafeErc20__CallToNonContract(address target);


error SafeErc20__NoReturnData();




/// returns false). Tokens that return no value (and instead revert or throw
/// on failure) are also supported, non-reverting calls are assumed to be successful.
///
/// To use this library you can add a `using SafeErc20 for IErc20;` statement to your contract,
/// which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
///

/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/utils/Address.sol
library SafeErc20 {
    using Address for address;

    /// INTERNAL FUNCTIONS ///

    function safeTransfer(
        IErc20 token,
        address to,
        uint256 amount
    ) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, amount));
    }

    function safeTransferFrom(
        IErc20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, amount));
    }

    /// PRIVATE FUNCTIONS ///

    
    /// on the return value: the return value is optional (but if data is returned, it cannot be false).
    
    
    function callOptionalReturn(IErc20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.
        bytes memory returndata = functionCall(address(token), data, "SafeErc20LowLevelCall");
        if (returndata.length > 0) {
            // Return data is optional.
            if (!abi.decode(returndata, (bool))) {
                revert SafeErc20__NoReturnData();
            }
        }
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) private returns (bytes memory) {
        if (!target.isContract()) {
            revert SafeErc20__CallToNonContract(target);
        }

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present.
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly.
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
pragma solidity >=0.8.4;






/// trailing decimals. We call this number representation unsigned 60.18-decimal fixed-point, since there can be up to 60
/// digits in the integer part and up to 18 decimals in the fractional part. The numbers are bound by the minimum and the
/// maximum values permitted by the Solidity type uint256.
library PRBMathUD60x18 {
    
    uint256 internal constant HALF_SCALE = 5e17;

    
    uint256 internal constant LOG2_E = 1_442695040888963407;

    
    uint256 internal constant MAX_UD60x18 =
        115792089237316195423570985008687907853269984665640564039457_584007913129639935;

    
    uint256 internal constant MAX_WHOLE_UD60x18 =
        115792089237316195423570985008687907853269984665640564039457_000000000000000000;

    
    uint256 internal constant SCALE = 1e18;

    
    
    
    
    function avg(uint256 x, uint256 y) internal pure returns (uint256 result) {
        // The operations can never overflow.
        unchecked {
            // The last operand checks if both x and y are odd and if that is the case, we add 1 to the result. We need
            // to do this because if both numbers are odd, the 0.5 remainder gets truncated twice.
            result = (x >> 1) + (y >> 1) + (x & y & 1);
        }
    }

    
    ///
    
    /// See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
    ///
    /// Requirements:
    /// - x must be less than or equal to MAX_WHOLE_UD60x18.
    ///
    
    
    function ceil(uint256 x) internal pure returns (uint256 result) {
        if (x > MAX_WHOLE_UD60x18) {
            revert PRBMathUD60x18__CeilOverflow(x);
        }
        assembly {
            // Equivalent to "x % SCALE" but faster.
            let remainder := mod(x, SCALE)

            // Equivalent to "SCALE - remainder" but faster.
            let delta := sub(SCALE, remainder)

            // Equivalent to "x + delta * (remainder > 0 ? 1 : 0)" but faster.
            result := add(x, mul(delta, gt(remainder, 0)))
        }
    }

    
    ///
    
    ///
    /// Requirements:
    /// - The denominator cannot be zero.
    ///
    
    
    
    function div(uint256 x, uint256 y) internal pure returns (uint256 result) {
        result = PRBMath.mulDiv(x, SCALE, y);
    }

    
    
    function e() internal pure returns (uint256 result) {
        result = 2_718281828459045235;
    }

    
    ///
    
    ///
    /// Requirements:
    /// - All from "log2".
    /// - x must be less than 133.084258667509499441.
    ///
    
    
    function exp(uint256 x) internal pure returns (uint256 result) {
        // Without this check, the value passed to "exp2" would be greater than 192.
        if (x >= 133_084258667509499441) {
            revert PRBMathUD60x18__ExpInputTooBig(x);
        }

        // Do the fixed-point multiplication inline to save gas.
        unchecked {
            uint256 doubleScaleProduct = x * LOG2_E;
            result = exp2((doubleScaleProduct + HALF_SCALE) / SCALE);
        }
    }

    
    ///
    
    ///
    /// Requirements:
    /// - x must be 192 or less.
    /// - The result must fit within MAX_UD60x18.
    ///
    
    
    function exp2(uint256 x) internal pure returns (uint256 result) {
        // 2^192 doesn't fit within the 192.64-bit format used internally in this function.
        if (x >= 192e18) {
            revert PRBMathUD60x18__Exp2InputTooBig(x);
        }

        unchecked {
            // Convert x to the 192.64-bit fixed-point format.
            uint256 x192x64 = (x << 64) / SCALE;

            // Pass x to the PRBMath.exp2 function, which uses the 192.64-bit fixed-point number representation.
            result = PRBMath.exp2(x192x64);
        }
    }

    
    
    /// See https://en.wikipedia.org/wiki/Floor_and_ceiling_functions.
    
    
    function floor(uint256 x) internal pure returns (uint256 result) {
        assembly {
            // Equivalent to "x % SCALE" but faster.
            let remainder := mod(x, SCALE)

            // Equivalent to "x - remainder * (remainder > 0 ? 1 : 0)" but faster.
            result := sub(x, mul(remainder, gt(remainder, 0)))
        }
    }

    
    
    
    
    function frac(uint256 x) internal pure returns (uint256 result) {
        assembly {
            result := mod(x, SCALE)
        }
    }

    
    ///
    
    /// - x must be less than or equal to MAX_UD60x18 divided by SCALE.
    ///
    
    
    function fromUint(uint256 x) internal pure returns (uint256 result) {
        unchecked {
            if (x > MAX_UD60x18 / SCALE) {
                revert PRBMathUD60x18__FromUintOverflow(x);
            }
            result = x * SCALE;
        }
    }

    
    ///
    
    /// - x * y must fit within MAX_UD60x18, lest it overflows.
    ///
    
    
    
    function gm(uint256 x, uint256 y) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        unchecked {
            // Checking for overflow this way is faster than letting Solidity do it.
            uint256 xy = x * y;
            if (xy / x != y) {
                revert PRBMathUD60x18__GmOverflow(x, y);
            }

            // We don't need to multiply by the SCALE here because the x*y product had already picked up a factor of SCALE
            // during multiplication. See the comments within the "sqrt" function.
            result = PRBMath.sqrt(xy);
        }
    }

    
    ///
    
    /// - x cannot be zero.
    ///
    
    
    function inv(uint256 x) internal pure returns (uint256 result) {
        unchecked {
            // 1e36 is SCALE * SCALE.
            result = 1e36 / x;
        }
    }

    
    ///
    
    ///
    /// Requirements:
    /// - All from "log2".
    ///
    /// Caveats:
    /// - All from "log2".
    /// - This doesn't return exactly 1 for 2.718281828459045235, for that we would need more fine-grained precision.
    ///
    
    
    function ln(uint256 x) internal pure returns (uint256 result) {
        // Do the fixed-point multiplication inline to save gas. This is overflow-safe because the maximum value that log2(x)
        // can return is 196205294292027477728.
        unchecked {
            result = (log2(x) * SCALE) / LOG2_E;
        }
    }

    
    ///
    
    /// logarithm based on the insight that log10(x) = log2(x) / log2(10).
    ///
    /// Requirements:
    /// - All from "log2".
    ///
    /// Caveats:
    /// - All from "log2".
    ///
    
    
    function log10(uint256 x) internal pure returns (uint256 result) {
        if (x < SCALE) {
            revert PRBMathUD60x18__LogInputTooSmall(x);
        }

        // Note that the "mul" in this block is the assembly multiplication operation, not the "mul" function defined
        // in this contract.
        // prettier-ignore
        assembly {
            switch x
            case 1 { result := mul(SCALE, sub(0, 18)) }
            case 10 { result := mul(SCALE, sub(1, 18)) }
            case 100 { result := mul(SCALE, sub(2, 18)) }
            case 1000 { result := mul(SCALE, sub(3, 18)) }
            case 10000 { result := mul(SCALE, sub(4, 18)) }
            case 100000 { result := mul(SCALE, sub(5, 18)) }
            case 1000000 { result := mul(SCALE, sub(6, 18)) }
            case 10000000 { result := mul(SCALE, sub(7, 18)) }
            case 100000000 { result := mul(SCALE, sub(8, 18)) }
            case 1000000000 { result := mul(SCALE, sub(9, 18)) }
            case 10000000000 { result := mul(SCALE, sub(10, 18)) }
            case 100000000000 { result := mul(SCALE, sub(11, 18)) }
            case 1000000000000 { result := mul(SCALE, sub(12, 18)) }
            case 10000000000000 { result := mul(SCALE, sub(13, 18)) }
            case 100000000000000 { result := mul(SCALE, sub(14, 18)) }
            case 1000000000000000 { result := mul(SCALE, sub(15, 18)) }
            case 10000000000000000 { result := mul(SCALE, sub(16, 18)) }
            case 100000000000000000 { result := mul(SCALE, sub(17, 18)) }
            case 1000000000000000000 { result := 0 }
            case 10000000000000000000 { result := SCALE }
            case 100000000000000000000 { result := mul(SCALE, 2) }
            case 1000000000000000000000 { result := mul(SCALE, 3) }
            case 10000000000000000000000 { result := mul(SCALE, 4) }
            case 100000000000000000000000 { result := mul(SCALE, 5) }
            case 1000000000000000000000000 { result := mul(SCALE, 6) }
            case 10000000000000000000000000 { result := mul(SCALE, 7) }
            case 100000000000000000000000000 { result := mul(SCALE, 8) }
            case 1000000000000000000000000000 { result := mul(SCALE, 9) }
            case 10000000000000000000000000000 { result := mul(SCALE, 10) }
            case 100000000000000000000000000000 { result := mul(SCALE, 11) }
            case 1000000000000000000000000000000 { result := mul(SCALE, 12) }
            case 10000000000000000000000000000000 { result := mul(SCALE, 13) }
            case 100000000000000000000000000000000 { result := mul(SCALE, 14) }
            case 1000000000000000000000000000000000 { result := mul(SCALE, 15) }
            case 10000000000000000000000000000000000 { result := mul(SCALE, 16) }
            case 100000000000000000000000000000000000 { result := mul(SCALE, 17) }
            case 1000000000000000000000000000000000000 { result := mul(SCALE, 18) }
            case 10000000000000000000000000000000000000 { result := mul(SCALE, 19) }
            case 100000000000000000000000000000000000000 { result := mul(SCALE, 20) }
            case 1000000000000000000000000000000000000000 { result := mul(SCALE, 21) }
            case 10000000000000000000000000000000000000000 { result := mul(SCALE, 22) }
            case 100000000000000000000000000000000000000000 { result := mul(SCALE, 23) }
            case 1000000000000000000000000000000000000000000 { result := mul(SCALE, 24) }
            case 10000000000000000000000000000000000000000000 { result := mul(SCALE, 25) }
            case 100000000000000000000000000000000000000000000 { result := mul(SCALE, 26) }
            case 1000000000000000000000000000000000000000000000 { result := mul(SCALE, 27) }
            case 10000000000000000000000000000000000000000000000 { result := mul(SCALE, 28) }
            case 100000000000000000000000000000000000000000000000 { result := mul(SCALE, 29) }
            case 1000000000000000000000000000000000000000000000000 { result := mul(SCALE, 30) }
            case 10000000000000000000000000000000000000000000000000 { result := mul(SCALE, 31) }
            case 100000000000000000000000000000000000000000000000000 { result := mul(SCALE, 32) }
            case 1000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 33) }
            case 10000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 34) }
            case 100000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 35) }
            case 1000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 36) }
            case 10000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 37) }
            case 100000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 38) }
            case 1000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 39) }
            case 10000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 40) }
            case 100000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 41) }
            case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 42) }
            case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 43) }
            case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 44) }
            case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 45) }
            case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 46) }
            case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 47) }
            case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 48) }
            case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 49) }
            case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 50) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 51) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 52) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 53) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 54) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 55) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 56) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 57) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 58) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 59) }
            default {
                result := MAX_UD60x18
            }
        }

        if (result == MAX_UD60x18) {
            // Do the fixed-point division inline to save gas. The denominator is log2(10).
            unchecked {
                result = (log2(x) * SCALE) / 3_321928094887362347;
            }
        }
    }

    
    ///
    
    /// https://en.wikipedia.org/wiki/Binary_logarithm#Iterative_approximation
    ///
    /// Requirements:
    /// - x must be greater than or equal to SCALE, otherwise the result would be negative.
    ///
    /// Caveats:
    /// - The results are nor perfectly accurate to the last decimal, due to the lossy precision of the iterative approximation.
    ///
    
    
    function log2(uint256 x) internal pure returns (uint256 result) {
        if (x < SCALE) {
            revert PRBMathUD60x18__LogInputTooSmall(x);
        }
        unchecked {
            // Calculate the integer part of the logarithm and add it to the result and finally calculate y = x * 2^(-n).
            uint256 n = PRBMath.mostSignificantBit(x / SCALE);

            // The integer part of the logarithm as an unsigned 60.18-decimal fixed-point number. The operation can't overflow
            // because n is maximum 255 and SCALE is 1e18.
            result = n * SCALE;

            // This is y = x * 2^(-n).
            uint256 y = x >> n;

            // If y = 1, the fractional part is zero.
            if (y == SCALE) {
                return result;
            }

            // Calculate the fractional part via the iterative approximation.
            // The "delta >>= 1" part is equivalent to "delta /= 2", but shifting bits is faster.
            for (uint256 delta = HALF_SCALE; delta > 0; delta >>= 1) {
                y = (y * y) / SCALE;

                // Is y^2 > 2 and so in the range [2,4)?
                if (y >= 2 * SCALE) {
                    // Add the 2^(-m) factor to the logarithm.
                    result += delta;

                    // Corresponds to z/2 on Wikipedia.
                    y >>= 1;
                }
            }
        }
    }

    
    /// fixed-point number.
    
    
    
    
    function mul(uint256 x, uint256 y) internal pure returns (uint256 result) {
        result = PRBMath.mulDivFixedPoint(x, y);
    }

    
    function pi() internal pure returns (uint256 result) {
        result = 3_141592653589793238;
    }

    
    ///
    
    ///
    /// Requirements:
    /// - All from "exp2", "log2" and "mul".
    ///
    /// Caveats:
    /// - All from "exp2", "log2" and "mul".
    /// - Assumes 0^0 is 1.
    ///
    
    
    
    function pow(uint256 x, uint256 y) internal pure returns (uint256 result) {
        if (x == 0) {
            result = y == 0 ? SCALE : uint256(0);
        } else {
            result = exp2(mul(log2(x), y));
        }
    }

    
    /// famous algorithm "exponentiation by squaring".
    ///
    
    ///
    /// Requirements:
    /// - The result must fit within MAX_UD60x18.
    ///
    /// Caveats:
    /// - All from "mul".
    /// - Assumes 0^0 is 1.
    ///
    
    
    
    function powu(uint256 x, uint256 y) internal pure returns (uint256 result) {
        // Calculate the first iteration of the loop in advance.
        result = y & 1 > 0 ? x : SCALE;

        // Equivalent to "for(y /= 2; y > 0; y /= 2)" but faster.
        for (y >>= 1; y > 0; y >>= 1) {
            x = PRBMath.mulDivFixedPoint(x, x);

            // Equivalent to "y % 2 == 1" but faster.
            if (y & 1 > 0) {
                result = PRBMath.mulDivFixedPoint(result, x);
            }
        }
    }

    
    function scale() internal pure returns (uint256 result) {
        result = SCALE;
    }

    
    
    ///
    /// Requirements:
    /// - x must be less than MAX_UD60x18 / SCALE.
    ///
    
    
    function sqrt(uint256 x) internal pure returns (uint256 result) {
        unchecked {
            if (x > MAX_UD60x18 / SCALE) {
                revert PRBMathUD60x18__SqrtOverflow(x);
            }
            // Multiply x by the SCALE to account for the factor of SCALE that is picked up when multiplying two unsigned
            // 60.18-decimal fixed-point numbers together (in this case, those two numbers are both the square root).
            result = PRBMath.sqrt(x * SCALE);
        }
    }

    
    
    
    function toUint(uint256 x) internal pure returns (uint256 result) {
        unchecked {
            result = x / SCALE;
        }
    }
}

// 
pragma solidity >=0.8.4;









interface IFintroller is IOwnable {
    /// CUSTOM ERRORS ///

    
    error Fintroller__BondNotListed(IHToken bond);

    
    error Fintroller__BondBorrowAllowedWithLiquidateBorrowDisallowed();

    
    error Fintroller__BondLiquidateBorrowAllowedWithRepayBorrowDisallowed();

    
    error Fintroller__BondLiquidateBorrowDisallowedWithBorrowAllowed();

    
    error Fintroller__BondRepayBorrowDisallowedWithLiquidateBorrowAllowed();

    
    error Fintroller__CollateralDecimalsOverflow(uint256 decimals);

    
    error Fintroller__CollateralDecimalsZero();

    
    error Fintroller__CollateralNotListed(IErc20 collateral);

    
    error Fintroller__CollateralRatioBelowLiquidationIncentive(uint256 newCollateralRatio);

    
    error Fintroller__CollateralRatioOverflow(uint256 newCollateralRatio);

    
    error Fintroller__CollateralRatioUnderflow(uint256 newCollateralRatio);

    
    error Fintroller__DebtCeilingUnderflow(uint256 newDebtCeiling, uint256 totalSupply);

    
    error Fintroller__LiquidationIncentiveAboveCollateralRatio(uint256 newLiquidationIncentive);

    
    error Fintroller__LiquidationIncentiveOverflow(uint256 newLiquidationIncentive);

    
    error Fintroller__LiquidationIncentiveUnderflow(uint256 newLiquidationIncentive);

    /// EVENTS ///

    
    
    
    event ListBond(address indexed owner, IHToken indexed bond);

    
    
    
    event ListCollateral(address indexed owner, IErc20 indexed collateral);

    
    
    
    
    event SetBorrowAllowed(address indexed owner, IHToken indexed bond, bool state);

    
    
    
    
    
    event SetCollateralCeiling(
        address indexed owner,
        IErc20 indexed collateral,
        uint256 oldCollateralCeiling,
        uint256 newCollateralCeiling
    );

    
    
    
    
    
    event SetCollateralRatio(
        address indexed owner,
        IErc20 indexed collateral,
        uint256 oldCollateralRatio,
        uint256 newCollateralRatio
    );

    
    
    
    
    
    event SetDebtCeiling(address indexed owner, IHToken indexed bond, uint256 oldDebtCeiling, uint256 newDebtCeiling);

    
    
    
    event SetDepositCollateralAllowed(address indexed owner, IErc20 indexed collateral, bool state);

    
    
    
    
    event SetDepositUnderlyingAllowed(address indexed owner, IHToken indexed bond, bool state);

    
    
    
    
    event SetLiquidateBorrowAllowed(address indexed owner, IHToken indexed bond, bool state);

    
    
    
    
    
    event SetLiquidationIncentive(
        address indexed owner,
        IErc20 collateral,
        uint256 oldLiquidationIncentive,
        uint256 newLiquidationIncentive
    );

    
    
    
    
    event SetMaxBonds(address indexed owner, uint256 oldMaxBonds, uint256 newMaxBonds);

    
    
    
    
    event SetMaxCollaterals(address indexed owner, uint256 oldMaxCollaterals, uint256 newMaxCollaterals);

    
    
    
    
    event SetRepayBorrowAllowed(address indexed owner, IHToken indexed bond, bool state);

    /// STRUCTS ///

    struct Bond {
        uint256 debtCeiling;
        bool isBorrowAllowed;
        bool isDepositUnderlyingAllowed;
        bool isLiquidateBorrowAllowed;
        bool isListed;
        bool isRepayBorrowAllowed;
    }

    struct Collateral {
        uint256 ceiling;
        uint256 ratio;
        uint256 liquidationIncentive;
        bool isDepositCollateralAllowed;
        bool isListed;
    }

    /// CONSTANT FUNCTIONS ///

    
    
    
    
    function getBond(IHToken bond) external view returns (Bond memory);

    
    
    
    
    function getBorrowAllowed(IHToken bond) external view returns (bool);

    
    
    
    
    function getCollateral(IErc20 collateral) external view returns (Collateral memory);

    
    
    
    
    function getCollateralCeiling(IErc20 collateral) external view returns (uint256);

    
    
    
    
    function getCollateralRatio(IErc20 collateral) external view returns (uint256);

    
    
    
    
    function getDebtCeiling(IHToken bond) external view returns (uint256);

    
    
    
    
    function getDepositCollateralAllowed(IErc20 collateral) external view returns (bool);

    
    
    
    
    function getDepositUnderlyingAllowed(IHToken bond) external view returns (bool);

    
    
    
    
    function getLiquidationIncentive(IErc20 collateral) external view returns (uint256);

    
    
    
    
    function getLiquidateBorrowAllowed(IHToken bond) external view returns (bool);

    
    
    
    
    function getRepayBorrowAllowed(IHToken bond) external view returns (bool);

    
    
    
    function isBondListed(IHToken bond) external view returns (bool);

    
    
    
    function isCollateralListed(IErc20 collateral) external view returns (bool);

    
    function maxBonds() external view returns (uint256);

    
    function maxCollaterals() external view returns (uint256);

    /// NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    function listBond(IHToken bond) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The collateral must have between 1 and 18 decimals.
    ///
    
    function listCollateral(IErc20 collateral) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The bond must be listed.
    ///
    
    
    function setBorrowAllowed(IHToken bond, bool state) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The collateral must be listed.
    ///
    
    
    function setCollateralCeiling(IHToken collateral, uint256 newCollateralCeiling) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The collateral must be listed.
    /// - The new collateral ratio cannot be higher than the maximum collateral ratio.
    /// - The new collateral ratio cannot be lower than the minimum collateral ratio.
    ///
    
    
    function setCollateralRatio(IErc20 collateral, uint256 newCollateralRatio) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The bond must be listed.
    /// - The debt ceiling cannot fall below the current total supply of hTokens.
    ///
    
    
    function setDebtCeiling(IHToken bond, uint256 newDebtCeiling) external;

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    
    function setDepositCollateralAllowed(IErc20 collateral, bool state) external;

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    
    function setDepositUnderlyingAllowed(IHToken bond, bool state) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The collateral must be listed.
    /// - The new liquidation incentive cannot be higher than the maximum liquidation incentive.
    /// - The new liquidation incentive cannot be lower than the minimum liquidation incentive.
    ///
    
    
    function setLiquidationIncentive(IErc20 collateral, uint256 newLiquidationIncentive) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The bond must be listed.
    ///
    
    
    function setLiquidateBorrowAllowed(IHToken bond, bool state) external;

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    function setMaxBonds(uint256 newMaxBonds) external;

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    function setMaxCollaterals(uint256 newMaxCollaterals) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The bond must be listed.
    ///
    
    
    function setRepayBorrowAllowed(IHToken bond, bool state) external;
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
pragma solidity >=0.8.4;





/// https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/v3.4.0/contracts/utils/Address.sol
library Address {
    
    ///
    /// IMPORTANT: It is unsafe to assume that an address for which this function returns false is an
    /// externally-owned account (EOA) and not a contract.
    ///
    /// Among others, `isContract` will return false for the following types of addresses:
    ///
    /// - An externally-owned account
    /// - A contract in construction
    /// - An address where a contract will be created
    /// - An address where a contract lived, but was destroyed
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`.
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }
}

// 
pragma solidity >=0.8.4;


error PRBMath__MulDivFixedPointOverflow(uint256 prod1);


error PRBMath__MulDivOverflow(uint256 prod1, uint256 denominator);


error PRBMath__MulDivSignedInputTooSmall();


error PRBMath__MulDivSignedOverflow(uint256 rAbs);


error PRBMathSD59x18__AbsInputTooSmall();


error PRBMathSD59x18__CeilOverflow(int256 x);


error PRBMathSD59x18__DivInputTooSmall();


error PRBMathSD59x18__DivOverflow(uint256 rAbs);


error PRBMathSD59x18__ExpInputTooBig(int256 x);


error PRBMathSD59x18__Exp2InputTooBig(int256 x);


error PRBMathSD59x18__FloorUnderflow(int256 x);


error PRBMathSD59x18__FromIntOverflow(int256 x);


error PRBMathSD59x18__FromIntUnderflow(int256 x);


error PRBMathSD59x18__GmNegativeProduct(int256 x, int256 y);


error PRBMathSD59x18__GmOverflow(int256 x, int256 y);


error PRBMathSD59x18__LogInputTooSmall(int256 x);


error PRBMathSD59x18__MulInputTooSmall();


error PRBMathSD59x18__MulOverflow(uint256 rAbs);


error PRBMathSD59x18__PowuOverflow(uint256 rAbs);


error PRBMathSD59x18__SqrtNegativeInput(int256 x);


error PRBMathSD59x18__SqrtOverflow(int256 x);


error PRBMathUD60x18__AddOverflow(uint256 x, uint256 y);


error PRBMathUD60x18__CeilOverflow(uint256 x);


error PRBMathUD60x18__ExpInputTooBig(uint256 x);


error PRBMathUD60x18__Exp2InputTooBig(uint256 x);


error PRBMathUD60x18__FromUintOverflow(uint256 x);


error PRBMathUD60x18__GmOverflow(uint256 x, uint256 y);


error PRBMathUD60x18__LogInputTooSmall(uint256 x);


error PRBMathUD60x18__SqrtOverflow(uint256 x);


error PRBMathUD60x18__SubUnderflow(uint256 x, uint256 y);


/// does not always assume the signed 59.18-decimal fixed-point or the unsigned 60.18-decimal fixed-point
/// representation. When it does not, it is explicitly mentioned in the NatSpec documentation.
library PRBMath {
    /// STRUCTS ///

    struct SD59x18 {
        int256 value;
    }

    struct UD60x18 {
        uint256 value;
    }

    /// STORAGE ///

    
    uint256 internal constant SCALE = 1e18;

    
    uint256 internal constant SCALE_LPOTD = 262144;

    
    uint256 internal constant SCALE_INVERSE =
        78156646155174841979727994598816262306175212592076161876661_508869554232690281;

    /// FUNCTIONS ///

    
    
    /// See https://ethereum.stackexchange.com/a/96594/24693.
    
    
    function exp2(uint256 x) internal pure returns (uint256 result) {
        unchecked {
            // Start from 0.5 in the 192.64-bit fixed-point format.
            result = 0x800000000000000000000000000000000000000000000000;

            // Multiply the result by root(2, 2^-i) when the bit at position i is 1. None of the intermediary results overflows
            // because the initial result is 2^191 and all magic factors are less than 2^65.
            if (x & 0x8000000000000000 > 0) {
                result = (result * 0x16A09E667F3BCC909) >> 64;
            }
            if (x & 0x4000000000000000 > 0) {
                result = (result * 0x1306FE0A31B7152DF) >> 64;
            }
            if (x & 0x2000000000000000 > 0) {
                result = (result * 0x1172B83C7D517ADCE) >> 64;
            }
            if (x & 0x1000000000000000 > 0) {
                result = (result * 0x10B5586CF9890F62A) >> 64;
            }
            if (x & 0x800000000000000 > 0) {
                result = (result * 0x1059B0D31585743AE) >> 64;
            }
            if (x & 0x400000000000000 > 0) {
                result = (result * 0x102C9A3E778060EE7) >> 64;
            }
            if (x & 0x200000000000000 > 0) {
                result = (result * 0x10163DA9FB33356D8) >> 64;
            }
            if (x & 0x100000000000000 > 0) {
                result = (result * 0x100B1AFA5ABCBED61) >> 64;
            }
            if (x & 0x80000000000000 > 0) {
                result = (result * 0x10058C86DA1C09EA2) >> 64;
            }
            if (x & 0x40000000000000 > 0) {
                result = (result * 0x1002C605E2E8CEC50) >> 64;
            }
            if (x & 0x20000000000000 > 0) {
                result = (result * 0x100162F3904051FA1) >> 64;
            }
            if (x & 0x10000000000000 > 0) {
                result = (result * 0x1000B175EFFDC76BA) >> 64;
            }
            if (x & 0x8000000000000 > 0) {
                result = (result * 0x100058BA01FB9F96D) >> 64;
            }
            if (x & 0x4000000000000 > 0) {
                result = (result * 0x10002C5CC37DA9492) >> 64;
            }
            if (x & 0x2000000000000 > 0) {
                result = (result * 0x1000162E525EE0547) >> 64;
            }
            if (x & 0x1000000000000 > 0) {
                result = (result * 0x10000B17255775C04) >> 64;
            }
            if (x & 0x800000000000 > 0) {
                result = (result * 0x1000058B91B5BC9AE) >> 64;
            }
            if (x & 0x400000000000 > 0) {
                result = (result * 0x100002C5C89D5EC6D) >> 64;
            }
            if (x & 0x200000000000 > 0) {
                result = (result * 0x10000162E43F4F831) >> 64;
            }
            if (x & 0x100000000000 > 0) {
                result = (result * 0x100000B1721BCFC9A) >> 64;
            }
            if (x & 0x80000000000 > 0) {
                result = (result * 0x10000058B90CF1E6E) >> 64;
            }
            if (x & 0x40000000000 > 0) {
                result = (result * 0x1000002C5C863B73F) >> 64;
            }
            if (x & 0x20000000000 > 0) {
                result = (result * 0x100000162E430E5A2) >> 64;
            }
            if (x & 0x10000000000 > 0) {
                result = (result * 0x1000000B172183551) >> 64;
            }
            if (x & 0x8000000000 > 0) {
                result = (result * 0x100000058B90C0B49) >> 64;
            }
            if (x & 0x4000000000 > 0) {
                result = (result * 0x10000002C5C8601CC) >> 64;
            }
            if (x & 0x2000000000 > 0) {
                result = (result * 0x1000000162E42FFF0) >> 64;
            }
            if (x & 0x1000000000 > 0) {
                result = (result * 0x10000000B17217FBB) >> 64;
            }
            if (x & 0x800000000 > 0) {
                result = (result * 0x1000000058B90BFCE) >> 64;
            }
            if (x & 0x400000000 > 0) {
                result = (result * 0x100000002C5C85FE3) >> 64;
            }
            if (x & 0x200000000 > 0) {
                result = (result * 0x10000000162E42FF1) >> 64;
            }
            if (x & 0x100000000 > 0) {
                result = (result * 0x100000000B17217F8) >> 64;
            }
            if (x & 0x80000000 > 0) {
                result = (result * 0x10000000058B90BFC) >> 64;
            }
            if (x & 0x40000000 > 0) {
                result = (result * 0x1000000002C5C85FE) >> 64;
            }
            if (x & 0x20000000 > 0) {
                result = (result * 0x100000000162E42FF) >> 64;
            }
            if (x & 0x10000000 > 0) {
                result = (result * 0x1000000000B17217F) >> 64;
            }
            if (x & 0x8000000 > 0) {
                result = (result * 0x100000000058B90C0) >> 64;
            }
            if (x & 0x4000000 > 0) {
                result = (result * 0x10000000002C5C860) >> 64;
            }
            if (x & 0x2000000 > 0) {
                result = (result * 0x1000000000162E430) >> 64;
            }
            if (x & 0x1000000 > 0) {
                result = (result * 0x10000000000B17218) >> 64;
            }
            if (x & 0x800000 > 0) {
                result = (result * 0x1000000000058B90C) >> 64;
            }
            if (x & 0x400000 > 0) {
                result = (result * 0x100000000002C5C86) >> 64;
            }
            if (x & 0x200000 > 0) {
                result = (result * 0x10000000000162E43) >> 64;
            }
            if (x & 0x100000 > 0) {
                result = (result * 0x100000000000B1721) >> 64;
            }
            if (x & 0x80000 > 0) {
                result = (result * 0x10000000000058B91) >> 64;
            }
            if (x & 0x40000 > 0) {
                result = (result * 0x1000000000002C5C8) >> 64;
            }
            if (x & 0x20000 > 0) {
                result = (result * 0x100000000000162E4) >> 64;
            }
            if (x & 0x10000 > 0) {
                result = (result * 0x1000000000000B172) >> 64;
            }
            if (x & 0x8000 > 0) {
                result = (result * 0x100000000000058B9) >> 64;
            }
            if (x & 0x4000 > 0) {
                result = (result * 0x10000000000002C5D) >> 64;
            }
            if (x & 0x2000 > 0) {
                result = (result * 0x1000000000000162E) >> 64;
            }
            if (x & 0x1000 > 0) {
                result = (result * 0x10000000000000B17) >> 64;
            }
            if (x & 0x800 > 0) {
                result = (result * 0x1000000000000058C) >> 64;
            }
            if (x & 0x400 > 0) {
                result = (result * 0x100000000000002C6) >> 64;
            }
            if (x & 0x200 > 0) {
                result = (result * 0x10000000000000163) >> 64;
            }
            if (x & 0x100 > 0) {
                result = (result * 0x100000000000000B1) >> 64;
            }
            if (x & 0x80 > 0) {
                result = (result * 0x10000000000000059) >> 64;
            }
            if (x & 0x40 > 0) {
                result = (result * 0x1000000000000002C) >> 64;
            }
            if (x & 0x20 > 0) {
                result = (result * 0x10000000000000016) >> 64;
            }
            if (x & 0x10 > 0) {
                result = (result * 0x1000000000000000B) >> 64;
            }
            if (x & 0x8 > 0) {
                result = (result * 0x10000000000000006) >> 64;
            }
            if (x & 0x4 > 0) {
                result = (result * 0x10000000000000003) >> 64;
            }
            if (x & 0x2 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
            if (x & 0x1 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }

            // We're doing two things at the same time:
            //
            //   1. Multiply the result by 2^n + 1, where "2^n" is the integer part and the one is added to account for
            //      the fact that we initially set the result to 0.5. This is accomplished by subtracting from 191
            //      rather than 192.
            //   2. Convert the result to the unsigned 60.18-decimal fixed-point format.
            //
            // This works because 2^(191-ip) = 2^ip / 2^191, where "ip" is the integer part "2^n".
            result *= SCALE;
            result >>= (191 - (x >> 64));
        }
    }

    
    
    
    
    function mostSignificantBit(uint256 x) internal pure returns (uint256 msb) {
        if (x >= 2**128) {
            x >>= 128;
            msb += 128;
        }
        if (x >= 2**64) {
            x >>= 64;
            msb += 64;
        }
        if (x >= 2**32) {
            x >>= 32;
            msb += 32;
        }
        if (x >= 2**16) {
            x >>= 16;
            msb += 16;
        }
        if (x >= 2**8) {
            x >>= 8;
            msb += 8;
        }
        if (x >= 2**4) {
            x >>= 4;
            msb += 4;
        }
        if (x >= 2**2) {
            x >>= 2;
            msb += 2;
        }
        if (x >= 2**1) {
            // No need to shift x any more.
            msb += 1;
        }
    }

    
    ///
    
    ///
    /// Requirements:
    /// - The denominator cannot be zero.
    /// - The result must fit within uint256.
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers.
    ///
    
    
    
    
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
        // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2^256 + prod0.
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division.
        if (prod1 == 0) {
            unchecked {
                result = prod0 / denominator;
            }
            return result;
        }

        // Make sure the result is less than 2^256. Also prevents denominator == 0.
        if (prod1 >= denominator) {
            revert PRBMath__MulDivOverflow(prod1, denominator);
        }

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0].
        uint256 remainder;
        assembly {
            // Compute remainder using mulmod.
            remainder := mulmod(x, y, denominator)

            // Subtract 256 bit number from 512 bit number.
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
        // See https://cs.stackexchange.com/q/138556/92363.
        unchecked {
            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 lpotdod = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by lpotdod.
                denominator := div(denominator, lpotdod)

                // Divide [prod1 prod0] by lpotdod.
                prod0 := div(prod0, lpotdod)

                // Flip lpotdod such that it is 2^256 / lpotdod. If lpotdod is zero, then it becomes one.
                lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * lpotdod;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    
    ///
    
    /// final result, we add 1 if (x * y) % SCALE >= HALF_SCALE. Without this, 6.6e-19 would be truncated to 0 instead of
    /// being rounded to 1e-18.  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717.
    ///
    /// Requirements:
    /// - The result must fit within uint256.
    ///
    /// Caveats:
    /// - The body is purposely left uncommented; see the NatSpec comments in "PRBMath.mulDiv" to understand how this works.
    /// - It is assumed that the result can never be type(uint256).max when x and y solve the following two equations:
    ///     1. x * y = type(uint256).max * SCALE
    ///     2. (x * y) % SCALE >= SCALE / 2
    ///
    
    
    
    function mulDivFixedPoint(uint256 x, uint256 y) internal pure returns (uint256 result) {
        uint256 prod0;
        uint256 prod1;
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 >= SCALE) {
            revert PRBMath__MulDivFixedPointOverflow(prod1);
        }

        uint256 remainder;
        uint256 roundUpUnit;
        assembly {
            remainder := mulmod(x, y, SCALE)
            roundUpUnit := gt(remainder, 499999999999999999)
        }

        if (prod1 == 0) {
            unchecked {
                result = (prod0 / SCALE) + roundUpUnit;
                return result;
            }
        }

        assembly {
            result := add(
                mul(
                    or(
                        div(sub(prod0, remainder), SCALE_LPOTD),
                        mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, SCALE_LPOTD), SCALE_LPOTD), 1))
                    ),
                    SCALE_INVERSE
                ),
                roundUpUnit
            )
        }
    }

    
    ///
    
    ///
    /// Requirements:
    /// - None of the inputs can be type(int256).min.
    /// - The result must fit within int256.
    ///
    
    
    
    
    function mulDivSigned(
        int256 x,
        int256 y,
        int256 denominator
    ) internal pure returns (int256 result) {
        if (x == type(int256).min || y == type(int256).min || denominator == type(int256).min) {
            revert PRBMath__MulDivSignedInputTooSmall();
        }

        // Get hold of the absolute values of x, y and the denominator.
        uint256 ax;
        uint256 ay;
        uint256 ad;
        unchecked {
            ax = x < 0 ? uint256(-x) : uint256(x);
            ay = y < 0 ? uint256(-y) : uint256(y);
            ad = denominator < 0 ? uint256(-denominator) : uint256(denominator);
        }

        // Compute the absolute value of (x*y)÷denominator. The result must fit within int256.
        uint256 rAbs = mulDiv(ax, ay, ad);
        if (rAbs > uint256(type(int256).max)) {
            revert PRBMath__MulDivSignedOverflow(rAbs);
        }

        // Get the signs of x, y and the denominator.
        uint256 sx;
        uint256 sy;
        uint256 sd;
        assembly {
            sx := sgt(x, sub(0, 1))
            sy := sgt(y, sub(0, 1))
            sd := sgt(denominator, sub(0, 1))
        }

        // XOR over sx, sy and sd. This is checking whether there are one or three negative signs in the inputs.
        // If yes, the result should be negative.
        result = sx ^ sy ^ sd == 0 ? -int256(rAbs) : int256(rAbs);
    }

    
    
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers.
    ///
    
    
    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        // Set the initial guess to the least power of two that is greater than or equal to sqrt(x).
        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        // The operations can never overflow because the result is max 2^127 when it enters this block.
        unchecked {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }
}

// 
pragma solidity >=0.8.4;












interface IHToken is
    IOwnable, // no dependency
    IErc20Permit, // one dependency
    IErc20Recover // one dependency
{
    /// CUSTOM ERRORS ///

    
    error HToken__BondMatured(uint256 now, uint256 maturity);

    
    error HToken__BondNotMatured(uint256 now, uint256 maturity);

    
    error HToken__BurnNotAuthorized(address caller);

    
    error HToken__DepositUnderlyingNotAllowed();

    
    error HToken__DepositUnderlyingZero();

    
    error HToken__MaturityPassed(uint256 now, uint256 maturity);

    
    error HToken__MintNotAuthorized(address caller);

    
    error HToken__RedeemInsufficientLiquidity(uint256 underlyingAmount, uint256 totalUnderlyingReserve);

    
    error HToken__RedeemZero();

    
    error HToken__UnderlyingDecimalsOverflow(uint256 decimals);

    
    error HToken__UnderlyingDecimalsZero();

    
    error HToken__WithdrawUnderlyingUnderflow(address depositor, uint256 availableAmount, uint256 underlyingAmount);

    
    error HToken__WithdrawUnderlyingZero();

    /// EVENTS ///

    
    
    
    event Burn(address indexed holder, uint256 burnAmount);

    
    
    
    
    event DepositUnderlying(address indexed depositor, uint256 depositUnderlyingAmount, uint256 hTokenAmount);

    
    
    
    event Mint(address indexed beneficiary, uint256 mintAmount);

    
    
    
    
    event Redeem(address indexed account, uint256 underlyingAmount, uint256 hTokenAmount);

    
    
    
    
    event SetBalanceSheet(address indexed owner, IBalanceSheetV2 oldBalanceSheet, IBalanceSheetV2 newBalanceSheet);

    
    
    
    
    event WithdrawUnderlying(address indexed depositor, uint256 underlyingAmount, uint256 hTokenAmount);

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    function balanceSheet() external view returns (IBalanceSheetV2);

    
    function getDepositorBalance(address depositor) external view returns (uint256 amount);

    
    function fintroller() external view returns (IFintroller);

    
    
    function isMatured() external view returns (bool);

    
    function maturity() external view returns (uint256);

    
    function totalUnderlyingReserve() external view returns (uint256);

    
    function underlying() external view returns (IErc20);

    
    function underlyingPrecisionScalar() external view returns (uint256);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// Requirements:
    /// - Can only be called by the BalanceSheet contract.
    ///
    
    
    function burn(address holder, uint256 burnAmount) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The Fintroller must allow this action to be performed.
    /// - The underlying amount to deposit cannot be zero.
    /// - The caller must have allowed this contract to spend `underlyingAmount` tokens.
    ///
    
    function depositUnderlying(uint256 underlyingAmount) external;

    
    ///
    
    ///
    /// Requirements:
    /// - Can only be called by the BalanceSheet contract.
    ///
    
    
    function mint(address beneficiary, uint256 mintAmount) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - Can only be called after maturation.
    /// - The amount of underlying to redeem cannot be zero.
    /// - There must be enough liquidity in the contract.
    ///
    
    function redeem(uint256 underlyingAmount) external;

    
    ///
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    function _setBalanceSheet(IBalanceSheetV2 newBalanceSheet) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The underlying amount to withdraw cannot be zero.
    /// - Can only be called before maturation.
    ///
    
    function withdrawUnderlying(uint256 underlyingAmount) external;
}

// 
pragma solidity >=0.8.4;









interface IChainlinkOperator {
    /// CUSTOM ERRORS ///

    
    error ChainlinkOperator__DecimalsMismatch(string symbol, uint256 decimals);

    
    error ChainlinkOperator__FeedNotSet(string symbol);

    
    error ChainlinkOperator__PriceLessThanOrEqualToZero(string symbol);

    
    error ChainlinkOperator__PriceStale(string symbol);

    /// EVENTS ///

    
    
    
    event DeleteFeed(IErc20 indexed asset, IAggregatorV3 indexed feed);

    
    
    
    event SetFeed(IErc20 indexed asset, IAggregatorV3 indexed feed);

    
    
    
    event SetPriceStalenessThreshold(uint256 oldPriceStalenessThreshold, uint256 newPriceStalenessThreshold);

    /// STRUCTS ///

    struct Feed {
        IErc20 asset;
        IAggregatorV3 id;
        bool isSet;
    }

    /// CONSTANT FUNCTIONS ///

    
    
    
    function getFeed(string memory symbol)
        external
        view
        returns (
            IErc20,
            IAggregatorV3,
            bool
        );

    
    /// format used by Chainlink, which has 8 decimals.
    ///
    
    /// - The normalized price cannot overflow.
    ///
    
    
    function getNormalizedPrice(string memory symbol) external view returns (uint256);

    
    /// has 8 decimals.
    ///
    
    ///
    /// - The feed must be set.
    /// - The price returned by the oracle cannot be zero.
    ///
    
    
    function getPrice(string memory symbol) external view returns (uint256);

    
    function pricePrecision() external view returns (uint256);

    
    function pricePrecisionScalar() external view returns (uint256);

    
    function priceStalenessThreshold() external view returns (uint256);

    /// NON-CONSTANT FUNCTIONS ///

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The feed must be set already.
    ///
    
    function deleteFeed(string memory symbol) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    /// - The number of decimals of the feed must be 8.
    ///
    
    
    function setFeed(IErc20 asset, IAggregatorV3 feed) external;

    
    ///
    
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    ///
    
    function setPriceStalenessThreshold(uint256 newPriceStalenessThreshold) external;
}

// 
pragma solidity >=0.8.4;




/// github.com/smartcontractkit/chainlink/blob/v1.2.0/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
interface IAggregatorV3 {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    /// getRoundData and latestRoundData should both raise "No data present" if they do not have
    /// data to report, instead of returning unset values which could be misinterpreted as
    /// actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}
