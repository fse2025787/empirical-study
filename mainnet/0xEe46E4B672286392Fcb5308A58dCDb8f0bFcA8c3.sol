// SPDX-License-Identifier: Unlicense


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




error Ownable__NotOwner(address owner, address caller);


error Ownable__OwnerZeroAddress();



contract Ownable is IOwnable {
    /// PUBLIC STORAGE ///

    
    address public override owner;

    /// MODIFIERS ///

    
    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert Ownable__NotOwner(owner, msg.sender);
        }
        _;
    }

    /// CONSTRUCTOR ///

    
    constructor() {
        address msgSender = msg.sender;
        owner = msgSender;
        emit TransferOwnership(address(0), msgSender);
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function _renounceOwnership() public virtual override onlyOwner {
        emit TransferOwnership(owner, address(0));
        owner = address(0);
    }

    
    function _transferOwnership(address newOwner) public virtual override onlyOwner {
        if (newOwner == address(0)) {
            revert Ownable__OwnerZeroAddress();
        }
        emit TransferOwnership(owner, newOwner);
        owner = newOwner;
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









contract Fintroller is
    IFintroller, // one dependency
    Ownable // one dependency
{
    /// PUBLIC STORAGE ///

    
    uint256 public override maxBonds;

    
    uint256 public override maxCollaterals;

    /// INTERNAL STORAGE ///

    
    uint256 internal constant COLLATERAL_RATIO_LOWER_BOUND = 1.0e18;

    
    uint256 internal constant COLLATERAL_RATIO_UPPER_BOUND = 1.0e20;

    
    uint256 internal constant DEFAULT_COLLATERAL_RATIO = 1.5e18;

    
    uint256 internal constant DEFAULT_LIQUIDATION_INCENTIVE = 1.1e18;

    
    uint256 internal constant DEFAULT_MAX_BONDS = 10;

    
    uint256 internal constant DEFAULT_MAX_COLLATERALS = 10;

    
    uint256 internal constant LIQUIDATION_INCENTIVE_LOWER_BOUND = 1.0e18;

    
    uint256 internal constant LIQUIDATION_INCENTIVE_UPPER_BOUND = 1.5e18;

    
    mapping(IHToken => Bond) internal bonds;

    
    mapping(IErc20 => Collateral) internal collaterals;

    /// CONSTRUCTOR ///

    constructor() Ownable() {
        // Set the max bonds limit.
        maxBonds = DEFAULT_MAX_BONDS;

        // Set the max collaterals limit
        maxCollaterals = DEFAULT_MAX_COLLATERALS;
    }

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    function getBond(IHToken hToken) external view override returns (Bond memory) {
        return bonds[hToken];
    }

    
    function getBorrowAllowed(IHToken bond) external view override returns (bool) {
        if (!bonds[bond].isListed) {
            revert Fintroller__BondNotListed(bond);
        }
        return bonds[bond].isBorrowAllowed;
    }

    
    function getCollateral(IErc20 collateral) external view override returns (Collateral memory) {
        return collaterals[collateral];
    }

    
    function getCollateralCeiling(IErc20 collateral) external view override returns (uint256) {
        return collaterals[collateral].ceiling;
    }

    
    function getCollateralRatio(IErc20 collateral) external view override returns (uint256) {
        return collaterals[collateral].ratio;
    }

    
    function getDebtCeiling(IHToken bond) external view override returns (uint256) {
        return bonds[bond].debtCeiling;
    }

    
    function getDepositCollateralAllowed(IErc20 collateral) external view override returns (bool) {
        if (!collaterals[collateral].isListed) {
            revert Fintroller__CollateralNotListed(collateral);
        }
        return collaterals[collateral].isDepositCollateralAllowed;
    }

    
    function getDepositUnderlyingAllowed(IHToken bond) external view override returns (bool) {
        if (!bonds[bond].isListed) {
            revert Fintroller__BondNotListed(bond);
        }
        return bonds[bond].isDepositUnderlyingAllowed;
    }

    
    function getLiquidationIncentive(IErc20 collateral) external view override returns (uint256) {
        return collaterals[collateral].liquidationIncentive;
    }

    
    function getLiquidateBorrowAllowed(IHToken bond) external view override returns (bool) {
        if (!bonds[bond].isListed) {
            revert Fintroller__BondNotListed(bond);
        }
        return bonds[bond].isLiquidateBorrowAllowed;
    }

    
    function getRepayBorrowAllowed(IHToken bond) external view override returns (bool) {
        if (!bonds[bond].isListed) {
            revert Fintroller__BondNotListed(bond);
        }
        return bonds[bond].isRepayBorrowAllowed;
    }

    
    function isBondListed(IHToken bond) external view override returns (bool) {
        return bonds[bond].isListed;
    }

    
    
    
    function isCollateralListed(IErc20 collateral) external view override returns (bool) {
        return collaterals[collateral].isListed;
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function listBond(IHToken bond) external override onlyOwner {
        bonds[bond] = Bond({
            debtCeiling: 0,
            isBorrowAllowed: true,
            isDepositUnderlyingAllowed: true,
            isLiquidateBorrowAllowed: true,
            isListed: true,
            isRepayBorrowAllowed: true
        });
        emit ListBond(owner, bond);
    }

    
    function listCollateral(IErc20 collateral) external override onlyOwner {
        // Checks: decimals are between the expected bounds.
        uint256 decimals = collateral.decimals();
        if (decimals == 0) {
            revert Fintroller__CollateralDecimalsZero();
        }
        if (decimals > 18) {
            revert Fintroller__CollateralDecimalsOverflow(decimals);
        }

        // Effects: update storage.
        collaterals[collateral] = Collateral({
            ceiling: 0,
            isDepositCollateralAllowed: true,
            isListed: true,
            liquidationIncentive: DEFAULT_LIQUIDATION_INCENTIVE,
            ratio: DEFAULT_COLLATERAL_RATIO
        });

        emit ListCollateral(owner, collateral);
    }

    
    function setBorrowAllowed(IHToken bond, bool state) external override onlyOwner {
        if (!bonds[bond].isListed) {
            revert Fintroller__BondNotListed(bond);
        }

        if (state && !bonds[bond].isLiquidateBorrowAllowed) {
            revert Fintroller__BondBorrowAllowedWithLiquidateBorrowDisallowed();
        }

        bonds[bond].isBorrowAllowed = state;
        emit SetBorrowAllowed(owner, bond, state);
    }

    
    function setCollateralCeiling(IHToken collateral, uint256 newCollateralCeiling) external override onlyOwner {
        // Checks: collateral is listed.
        if (!collaterals[collateral].isListed) {
            revert Fintroller__CollateralNotListed(collateral);
        }

        // Effects: update storage.
        uint256 oldCollateralCeiling = collaterals[collateral].ceiling;
        collaterals[collateral].ceiling = newCollateralCeiling;

        emit SetCollateralCeiling(owner, collateral, oldCollateralCeiling, newCollateralCeiling);
    }

    
    function setCollateralRatio(IErc20 collateral, uint256 newCollateralRatio) external override onlyOwner {
        // Checks: collateral is listed.
        if (!collaterals[collateral].isListed) {
            revert Fintroller__CollateralNotListed(collateral);
        }

        // Checks: new collateral ratio is within the accepted bounds.
        if (newCollateralRatio > COLLATERAL_RATIO_UPPER_BOUND) {
            revert Fintroller__CollateralRatioOverflow(newCollateralRatio);
        }
        if (newCollateralRatio < COLLATERAL_RATIO_LOWER_BOUND) {
            revert Fintroller__CollateralRatioUnderflow(newCollateralRatio);
        }
        if (newCollateralRatio < collaterals[collateral].liquidationIncentive) {
            revert Fintroller__CollateralRatioBelowLiquidationIncentive(newCollateralRatio);
        }

        // Effects: update storage.
        uint256 oldCollateralRatio = collaterals[collateral].ratio;
        collaterals[collateral].ratio = newCollateralRatio;

        emit SetCollateralRatio(owner, collateral, oldCollateralRatio, newCollateralRatio);
    }

    
    function setDebtCeiling(IHToken bond, uint256 newDebtCeiling) external override onlyOwner {
        // Checks: bond is listed.
        if (!bonds[bond].isListed) {
            revert Fintroller__BondNotListed(bond);
        }

        // Checks: above total supply of hTokens.
        uint256 totalSupply = bond.totalSupply();
        if (newDebtCeiling < totalSupply) {
            revert Fintroller__DebtCeilingUnderflow(newDebtCeiling, totalSupply);
        }

        // Effects: update storage.
        uint256 oldDebtCeiling = bonds[bond].debtCeiling;
        bonds[bond].debtCeiling = newDebtCeiling;

        emit SetDebtCeiling(owner, bond, oldDebtCeiling, newDebtCeiling);
    }

    
    function setDepositCollateralAllowed(IErc20 collateral, bool state) external override onlyOwner {
        if (!collaterals[collateral].isListed) {
            revert Fintroller__CollateralNotListed(collateral);
        }
        collaterals[collateral].isDepositCollateralAllowed = state;
        emit SetDepositCollateralAllowed(owner, collateral, state);
    }

    
    function setDepositUnderlyingAllowed(IHToken bond, bool state) external override onlyOwner {
        if (!bonds[bond].isListed) {
            revert Fintroller__BondNotListed(bond);
        }
        bonds[bond].isDepositUnderlyingAllowed = state;
        emit SetDepositUnderlyingAllowed(owner, bond, state);
    }

    
    function setLiquidateBorrowAllowed(IHToken bond, bool state) external override onlyOwner {
        if (!bonds[bond].isListed) {
            revert Fintroller__BondNotListed(bond);
        }

        if (state && !bonds[bond].isRepayBorrowAllowed) {
            revert Fintroller__BondLiquidateBorrowAllowedWithRepayBorrowDisallowed();
        }
        if (!state && bonds[bond].isBorrowAllowed) {
            revert Fintroller__BondLiquidateBorrowDisallowedWithBorrowAllowed();
        }

        bonds[bond].isLiquidateBorrowAllowed = state;
        emit SetLiquidateBorrowAllowed(owner, bond, state);
    }

    
    function setLiquidationIncentive(IErc20 collateral, uint256 newLiquidationIncentive) external override onlyOwner {
        // Checks: collateral is listed.
        if (!collaterals[collateral].isListed) {
            revert Fintroller__CollateralNotListed(collateral);
        }

        // Checks: new collateral ratio is within the accepted bounds.
        if (newLiquidationIncentive > LIQUIDATION_INCENTIVE_UPPER_BOUND) {
            revert Fintroller__LiquidationIncentiveOverflow(newLiquidationIncentive);
        }
        if (newLiquidationIncentive < LIQUIDATION_INCENTIVE_LOWER_BOUND) {
            revert Fintroller__LiquidationIncentiveUnderflow(newLiquidationIncentive);
        }
        if (newLiquidationIncentive > collaterals[collateral].ratio) {
            revert Fintroller__LiquidationIncentiveAboveCollateralRatio(newLiquidationIncentive);
        }

        // Effects: update storage.
        uint256 oldLiquidationIncentive = collaterals[collateral].liquidationIncentive;
        collaterals[collateral].liquidationIncentive = newLiquidationIncentive;

        emit SetLiquidationIncentive(owner, collateral, oldLiquidationIncentive, newLiquidationIncentive);
    }

    
    function setMaxBonds(uint256 newMaxBonds) external override onlyOwner {
        uint256 oldMaxBonds = maxBonds;
        maxBonds = newMaxBonds;
        emit SetMaxBonds(owner, oldMaxBonds, newMaxBonds);
    }

    
    function setMaxCollaterals(uint256 newMaxCollaterals) external override onlyOwner {
        uint256 oldMaxCollaterals = maxCollaterals;
        maxCollaterals = newMaxCollaterals;
        emit SetMaxCollaterals(owner, oldMaxCollaterals, newMaxCollaterals);
    }

    
    function setRepayBorrowAllowed(IHToken bond, bool state) external override onlyOwner {
        if (!bonds[bond].isListed) {
            revert Fintroller__BondNotListed(bond);
        }

        if (!state && bonds[bond].isLiquidateBorrowAllowed) {
            revert Fintroller__BondRepayBorrowDisallowedWithLiquidateBorrowAllowed();
        }

        bonds[bond].isRepayBorrowAllowed = state;
        emit SetRepayBorrowAllowed(owner, bond, state);
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