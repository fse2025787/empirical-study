// SPDX-License-Identifier: MIT


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

// 
pragma solidity 0.8.13;





interface IBaseSilo {
    enum AssetStatus { Undefined, Active, Removed }

    
    struct AssetStorage {
        
        IShareToken collateralToken;
        
        IShareToken collateralOnlyToken;
        
        IShareToken debtToken;
        
        /// It also includes token amount that has been borrowed.
        uint256 totalDeposits;
        
        /// as collateral. These deposits do NOT earn interest and CANNOT be borrowed.
        uint256 collateralOnlyDeposits;
        
        uint256 totalBorrowAmount;
    }

    
    struct AssetInterestData {
        
        uint256 harvestedProtocolFees;
        
        /// generated interest.
        uint256 protocolFees;
        
        uint64 interestRateTimestamp;
        
        /// for that asset
        AssetStatus status;
    }

    
    struct UtilizationData {
        uint256 totalDeposits;
        uint256 totalBorrowAmount;
        
        uint64 interestRateTimestamp;
    }

    
    struct AssetSharesMetadata {
        
        string collateralName;
        
        string collateralSymbol;
        
        string protectedName;
        
        string protectedSymbol;
        
        string debtName;
        
        string debtSymbol;
    }

    
    
    
    
    
    event Deposit(address indexed asset, address indexed depositor, uint256 amount, bool collateralOnly);

    
    
    
    
    
    
    event Withdraw(
        address indexed asset,
        address indexed depositor,
        address indexed receiver,
        uint256 amount,
        bool collateralOnly
    );

    
    
    
    
    event Borrow(address indexed asset, address indexed user, uint256 amount);

    
    
    
    
    event Repay(address indexed asset, address indexed user, uint256 amount);

    
    
    
    
    /// ownership of underlying deposit.
    
    event Liquidate(address indexed asset, address indexed user, uint256 shareAmountRepaid, uint256 seizedCollateral);

    
    
    
    event AssetStatusUpdate(address indexed asset, AssetStatus indexed status);

    
    function VERSION() external returns (uint128); // solhint-disable-line func-name-mixedcase

    
    
    /// called every time a bridged asset is added or removed. When bridge asset is removed, depositing and borrowing
    /// should be disabled during asset sync.
    function syncBridgeAssets() external;

    
    
    function siloRepository() external view returns (ISiloRepository);

    
    
    
    function assetStorage(address _asset) external view returns (AssetStorage memory);

    
    
    
    function interestData(address _asset) external view returns (AssetInterestData memory);

    
    function utilizationData(address _asset) external view returns (UtilizationData memory data);

    
    
    
    function isSolvent(address _user) external view returns (bool);

    
    
    function getAssets() external view returns (address[] memory assets);

    
    /// with corresponding state
    
    
    function getAssetsWithState() external view returns (address[] memory assets, AssetStorage[] memory assetsStorage);

    
    
    
    
    
    function depositPossible(address _asset, address _depositor) external view returns (bool);

    
    
    
    
    
    function borrowPossible(address _asset, address _borrower) external view returns (bool);

    
    
    
    function liquidity(address _asset) external view returns (uint256);
}
// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// 
pragma solidity 0.8.13;


interface IFlashLiquidationReceiver {
    
    ///         one can NOT assume, that if _seizedCollateral[i] != 0, then _shareAmountsToRepaid[i] must be 0
    ///         one should assume, that any combination of amounts is possible
    ///         on callback, one must call `Silo.repayFor` because at the end of transaction,
    ///         Silo will check if borrower is solvent.
    
    
    ///         this array contains all assets (collateral borrowed) without any order
    
    ///         indexes of amounts are related to `_assets`,
    
    ///         indexes of amounts are related to `_assets`,
    
    function siloLiquidationCallback(
        address _user,
        address[] calldata _assets,
        uint256[] calldata _receivedCollaterals,
        uint256[] calldata _shareAmountsToRepaid,
        bytes memory _flashReceiverData
    ) external;
}

// 
pragma solidity 0.8.13;

interface IInterestRateModel {
    /* solhint-disable */
    struct Config {
        // uopt ∈ (0, 1) – optimal utilization;
        int256 uopt;
        // ucrit ∈ (uopt, 1) – threshold of large utilization;
        int256 ucrit;
        // ulow ∈ (0, uopt) – threshold of low utilization
        int256 ulow;
        // ki > 0 – integrator gain
        int256 ki;
        // kcrit > 0 – proportional gain for large utilization
        int256 kcrit;
        // klow ≥ 0 – proportional gain for low utilization
        int256 klow;
        // klin ≥ 0 – coefficient of the lower linear bound
        int256 klin;
        // beta ≥ 0 - a scaling factor
        int256 beta;
        // ri ≥ 0 – initial value of the integrator
        int256 ri;
        // Tcrit ≥ 0 - the time during which the utilization exceeds the critical value
        int256 Tcrit;
    }
    /* solhint-enable */

    
    /// in different Silo can have different configs.
    /// It will try to call `_silo.accrueInterest(_asset)` before updating config, but it is not guaranteed,
    /// that this call will be successful, if it fail config will be set anyway.
    
    
    function setConfig(address _silo, address _asset, Config calldata _config) external;

    
    
    
    
    function getCompoundInterestRateAndUpdate(
        address _asset,
        uint256 _blockTimestamp
    ) external returns (uint256 rcomp);

    
    
    
    
    function getConfig(address _silo, address _asset) external view returns (Config memory);

    
    
    
    
    
    function getCompoundInterestRate(
        address _silo,
        address _asset,
        uint256 _blockTimestamp
    ) external view returns (uint256 rcomp);

    
    
    
    
    
    function getCurrentInterestRate(
        address _silo,
        address _asset,
        uint256 _blockTimestamp
    ) external view returns (uint256 rcur);

    
    /// overflow boolean flag to detect rcomp restriction
    function overflowDetected(
        address _silo,
        address _asset,
        uint256 _blockTimestamp
    ) external view returns (bool overflow);

    
    
    
    
    
    
    
    function calculateCurrentInterestRate(
        Config memory _c,
        uint256 _totalDeposits,
        uint256 _totalBorrowAmount,
        uint256 _interestRateTimestamp,
        uint256 _blockTimestamp
    ) external pure returns (uint256 rcur);

    
    
    
    
    
    
    
    
    
    
    function calculateCompoundInterestRateWithOverflowDetection(
        Config memory _c,
        uint256 _totalDeposits,
        uint256 _totalBorrowAmount,
        uint256 _interestRateTimestamp,
        uint256 _blockTimestamp
    ) external pure returns (
        uint256 rcomp,
        int256 ri,
        int256 Tcrit, // solhint-disable-line var-name-mixedcase
        bool overflow
    );

    
    
    
    
    
    
    
    
    
    function calculateCompoundInterestRate(
        Config memory _c,
        uint256 _totalDeposits,
        uint256 _totalBorrowAmount,
        uint256 _interestRateTimestamp,
        uint256 _blockTimestamp
    ) external pure returns (
        uint256 rcomp,
        int256 ri,
        int256 Tcrit // solhint-disable-line var-name-mixedcase
    );

    
    function DP() external pure returns (uint256); // solhint-disable-line func-name-mixedcase

    
    
    function interestRateModelPing() external pure returns (bytes4);
}

// 
pragma solidity 0.8.13;


interface INotificationReceiver {
    
    
    
    
    
    function onAfterTransfer(address _token, address _from, address _to, uint256 _amount) external;

    
    
    function notificationReceiverPing() external pure returns (bytes4);
}

// 
pragma solidity >=0.7.6 <0.9.0;


interface IPriceProvider {
    
    /// It unifies all tokens decimal to 18, examples:
    /// - if asses == quote it returns 1e18
    /// - if asset is USDC and quote is ETH and ETH costs ~$3300 then it returns ~0.0003e18 WETH per 1 USDC
    
    
    function getPrice(address _asset) external view returns (uint256 price);

    
    /// Some providers implementations need time to "build" buffer for TWAP price,
    /// so price may not be available yet but this method will return true.
    
    
    function assetSupported(address _asset) external view returns (bool);

    
    
    function quoteToken() external view returns (address);

    
    
    /// but this should NOT be treated as security check
    
    function priceProviderPing() external pure returns (bytes4);
}

// 
pragma solidity >=0.7.6 <0.9.0;



interface IPriceProvidersRepository {
    
    
    event NewPriceProvider(IPriceProvider indexed newPriceProvider);

    
    
    event PriceProviderRemoved(IPriceProvider indexed priceProvider);

    
    
    
    event PriceProviderForAsset(address indexed asset, IPriceProvider indexed priceProvider);

    
    
    function addPriceProvider(IPriceProvider _priceProvider) external;

    
    
    function removePriceProvider(IPriceProvider _priceProvider) external;

    
    
    
    
    function setPriceProviderForAsset(address _asset, IPriceProvider _priceProvider) external;

    
    
    
    function getPrice(address _asset) external view returns (uint256 price);

    
    
    
    function priceProviders(address _asset) external view returns (IPriceProvider priceProvider);

    
    
    function quoteToken() external view returns (address);

    
    
    function manager() external view returns (address);

    
    
    
    function providersReadyForAsset(address _asset) external view returns (bool);

    
    
    
    function isPriceProvider(IPriceProvider _provider) external view returns (bool);

    
    
    function providersCount() external view returns (uint256);

    
    
    function providerList() external view returns (address[] memory);

    
    
    function priceProvidersRepositoryPing() external pure returns (bytes4);
}

// 
pragma solidity 0.8.13;





interface IShareToken is IERC20Metadata {
    
    
    
    event NotificationSent(
        INotificationReceiver indexed notificationReceiver,
        bool success
    );

    
    
    
    function mint(address _account, uint256 _amount) external;

    
    
    
    function burn(address _account, uint256 _amount) external;
}

// 
pragma solidity 0.8.13;



interface ISilo is IBaseSilo {
    
    
    
    
    
    
    function deposit(address _asset, uint256 _amount, bool _collateralOnly)
        external
        returns (uint256 collateralAmount, uint256 collateralShare);

    
    
    
    
    
    
    
    function depositFor(address _asset, address _depositor, uint256 _amount, bool _collateralOnly)
        external
        returns (uint256 collateralAmount, uint256 collateralShare);

    
    
    
    
    
    
    function withdraw(address _asset, uint256 _amount, bool _collateralOnly)
        external
        returns (uint256 withdrawnAmount, uint256 withdrawnShare);

    
    
    
    /// it should be the one initiating the withdrawal through the router
    
    
    
    
    
    function withdrawFor(
        address _asset,
        address _depositor,
        address _receiver,
        uint256 _amount,
        bool _collateralOnly
    ) external returns (uint256 withdrawnAmount, uint256 withdrawnShare);

    
    
    
    
    
    function borrow(address _asset, uint256 _amount) external returns (uint256 debtAmount, uint256 debtShare);

    
    
    
    /// it should be the one initiating the borrowing through the router
    
    
    
    
    function borrowFor(address _asset, address _borrower, address _receiver, uint256 _amount)
        external
        returns (uint256 debtAmount, uint256 debtShare);

    
    
    
    
    
    function repay(address _asset, uint256 _amount) external returns (uint256 repaidAmount, uint256 burnedShare);

    
    
    
    
    
    
    function repayFor(address _asset, address _borrower, uint256 _amount)
        external
        returns (uint256 repaidAmount, uint256 burnedShare);

    
    
    function harvestProtocolFees() external returns (uint256[] memory harvestedAmounts);

    
    
    
    function accrueInterest(address _asset) external returns (uint256 interest);

    
    
    /// msg.sender needs to be `IFlashLiquidationReceiver`
    
    
    
    
    /// amounts of collaterals send to `_flashReceiver`
    
    /// required amounts of debt to be repaid
    function flashLiquidate(address[] memory _users, bytes memory _flashReceiverData)
        external
        returns (
            address[] memory assets,
            uint256[][] memory receivedCollaterals,
            uint256[][] memory shareAmountsToRepaid
        );
}

// 
pragma solidity 0.8.13;

interface ISiloFactory {
    
    
    
    
    event NewSiloCreated(address indexed silo, address indexed asset, uint128 version);

    
    
    function initRepository(address _siloRepository) external;

    
    
    
    
    
    function createSilo(address _siloAsset, uint128 _version, bytes memory _data) external returns (address silo);

    
    function siloFactoryPing() external pure returns (bytes4);
}

// 
pragma solidity 0.8.13;







interface ISiloRepository {
    
    struct Fees {
        
        uint64 entryFee;
        
        uint64 protocolShareFee;
        
        /// It's calculated from total collateral amount to be transferred to liquidator.
        uint64 protocolLiquidationFee;
    }

    struct SiloVersion {
        
        uint128 byDefault;

        
        uint128 latest;
    }

    
    struct AssetConfig {
        
        ///      For example, if the collateral asset has an LTV of 75%, the user can borrow up to 0.75 worth
        ///      of quote token in the principal currency for every quote token worth of collateral.
        ///      value uses 18 decimals eg. 100% == 1e18
        ///      max valid value is 1e18 so it needs storage of 60 bits
        uint64 maxLoanToValue;

        
        ///      undercollateralized and subject to liquidation for each collateral. For example,
        ///      if a collateral has a liquidation threshold of 80%, it means that the loan will be
        ///      liquidated when the borrowAmount value is worth 80% of the collateral value.
        ///      value uses 18 decimals eg. 100% == 1e18
        uint64 liquidationThreshold;

        
        IInterestRateModel interestRateModel;
    }

    event NewDefaultMaximumLTV(uint64 defaultMaximumLTV);

    event NewDefaultLiquidationThreshold(uint64 defaultLiquidationThreshold);

    
    
    
    
    event NewSilo(address indexed silo, address indexed asset, uint128 siloVersion);

    
    
    /// is treated as bridge pool
    event BridgePool(address indexed pool);

    
    
    event BridgeAssetAdded(address indexed newBridgeAsset);

    
    
    event BridgeAssetRemoved(address indexed bridgeAssetRemoved);

    
    
    event InterestRateModel(IInterestRateModel indexed newModel);

    
    
    event PriceProvidersRepositoryUpdate(
        IPriceProvidersRepository indexed newProvider
    );

    
    
    event TokensFactoryUpdate(address indexed newTokensFactory);

    
    
    event RouterUpdate(address indexed newRouter);

    
    
    event NotificationReceiverUpdate(INotificationReceiver indexed newIncentiveContract);

    
    
    
    
    event RegisterSiloVersion(address indexed factory, uint128 siloLatestVersion, uint128 siloDefaultVersion);

    
    
    
    event UnregisterSiloVersion(address indexed factory, uint128 siloVersion);

    
    
    event SiloDefaultVersion(uint128 newDefaultVersion);

    
    
    
    
    event FeeUpdate(
        uint64 newEntryFee,
        uint64 newProtocolShareFee,
        uint64 newProtocolLiquidationFee
    );

    
    
    
    
    event AssetConfigUpdate(address indexed silo, address indexed asset, AssetConfig assetConfig);

    
    
    
    event VersionForAsset(address indexed asset, uint128 version);

    
    
    function getVersionForAsset(address _siloAsset) external returns (uint128);

    
    
    
    function setVersionForAsset(address _siloAsset, uint128 _version) external;

    
    
    
    
    
    function newSilo(address _siloAsset, bytes memory _siloData) external returns (address createdSilo);

    
    /// Only owner (DAO) can replace.
    
    
    
    /// for 99% of cases.
    
    
    function replaceSilo(
        address _siloAsset,
        uint128 _siloVersion,
        bytes memory _siloData
    ) external returns (address createdSilo);

    
    
    
    function setTokensFactory(address _tokensFactory) external;

    
    
    
    /// - _entryFee one time protocol fee for opening a borrow position in precision points
    /// (Solvency._PRECISION_DECIMALS)
    /// - _protocolShareFee protocol revenue share in interest paid in precision points
    /// (Solvency._PRECISION_DECIMALS)
    /// - _protocolLiquidationFee protocol share in liquidation profit in precision points
    /// (Solvency._PRECISION_DECIMALS). It's calculated from total collateral amount to be transferred
    /// to liquidator.
    function setFees(Fees calldata _fees) external;

    
    
    
    
    
    ///    - _maxLoanToValue maximum Loan-to-Value, for details see `Repository.AssetConfig.maxLoanToValue`
    ///    - _liquidationThreshold liquidation threshold, for details see `Repository.AssetConfig.maxLoanToValue`
    ///    - _interestRateModel interest rate model address, for details see `Repository.AssetConfig.interestRateModel`
    function setAssetConfig(
        address _silo,
        address _asset,
        AssetConfig calldata _assetConfig
    ) external;

    
    
    
    function setDefaultInterestRateModel(IInterestRateModel _defaultInterestRateModel) external;

    
    
    
    function setDefaultMaximumLTV(uint64 _defaultMaxLTV) external;

    
    
    
    /// (Solvency._PRECISION_DECIMALS)
    function setDefaultLiquidationThreshold(uint64 _defaultLiquidationThreshold) external;

    
    
    
    function setPriceProvidersRepository(IPriceProvidersRepository _repository) external;

    
    
    
    function setRouter(address _router) external;

    
    
    
    
    function setNotificationReceiver(address _silo, INotificationReceiver _notificationReceiver) external;

    
    
    /// bridge asset that has been removed in the past. Note that all Silos must be synced manually. Callable
    /// only by owner.
    
    function addBridgeAsset(address _newBridgeAsset) external;

    
    
    
    function removeBridgeAsset(address _bridgeAssetToRemove) external;

    
    
    /// Callable only by owner.
    
    
    function registerSiloVersion(ISiloFactory _factory, bool _isDefault) external;

    
    
    
    function unregisterSiloVersion(uint128 _siloVersion) external;

    
    
    
    function setDefaultSiloVersion(uint128 _defaultVersion) external;

    
    
    
    function isSilo(address _silo) external view returns (bool);

    
    
    
    function getSilo(address _asset) external view returns (address);

    
    
    
    function siloFactory(uint256 _siloVersion) external view returns (ISiloFactory);

    
    
    function tokensFactory() external view returns (ITokensFactory);

    
    
    function router() external view returns (address);

    
    
    /// assets in that list are not part of given Silo.
    
    function getBridgeAssets() external view returns (address[] memory);

    
    
    /// assets in that list are still part of given Silo.
    
    function getRemovedBridgeAssets() external view returns (address[] memory);

    
    
    
    
    
    function getMaximumLTV(address _silo, address _asset) external view returns (uint256);

    
    
    
    
    
    function getInterestRateModel(address _silo, address _asset) external view returns (IInterestRateModel);

    
    
    
    
    
    function getLiquidationThreshold(address _silo, address _asset) external view returns (uint256);

    
    /// to debt and/or collateral token holders of given Silo
    
    
    function getNotificationReceiver(address _silo) external view returns (INotificationReceiver);

    
    
    function owner() external view returns (address);

    
    
    function priceProvidersRepository() external view returns (IPriceProvidersRepository);

    
    
    function entryFee() external view returns (uint256);

    
    
    function protocolShareFee() external view returns (uint256);

    
    
    function protocolLiquidationFee() external view returns (uint256);

    
    
    
    function ensureCanCreateSiloFor(address _asset, bool _assetIsABridge) external view;

    function siloRepositoryPing() external pure returns (bytes4);
}

// 
pragma solidity 0.8.13;



interface ITokensFactory {
    
    
    event NewShareCollateralTokenCreated(address indexed token);

    
    
    event NewShareDebtTokenCreated(address indexed token);

    
    
    function initRepository(address _siloRepository) external;

    
    
    
    
    
    function createShareCollateralToken(
        string memory _name,
        string memory _symbol,
        address _asset
    ) external returns (IShareToken);

    
    
    
    
    
    function createShareDebtToken(
        string memory _name,
        string memory _symbol,
        address _asset
    )
        external
        returns (IShareToken);

    
    
    function tokensFactoryPing() external pure returns (bytes4);
}

// 
pragma solidity 0.8.13;

library EasyMath {
    error ZeroAssets();
    error ZeroShares();

    function toShare(uint256 amount, uint256 totalAmount, uint256 totalShares) internal pure returns (uint256) {
        if (totalShares == 0 || totalAmount == 0) {
            return amount;
        }

        uint256 result = amount * totalShares / totalAmount;

        // Prevent rounding error
        if (result == 0 && amount != 0) {
            revert ZeroShares();
        }

        return result;
    }

    function toShareRoundUp(uint256 amount, uint256 totalAmount, uint256 totalShares) internal pure returns (uint256) {
        if (totalShares == 0 || totalAmount == 0) {
            return amount;
        }

        uint256 numerator = amount * totalShares;
        uint256 result = numerator / totalAmount;
        
        // Round up
        if (numerator % totalAmount != 0) {
            result += 1;
        }

        return result;
    }

    function toAmount(uint256 share, uint256 totalAmount, uint256 totalShares) internal pure returns (uint256) {
        if (totalShares == 0 || totalAmount == 0) {
            return 0;
        }

        uint256 result = share * totalAmount / totalShares;

        // Prevent rounding error
        if (result == 0 && share != 0) {
            revert ZeroAssets();
        }

        return result;
    }

    function toAmountRoundUp(uint256 share, uint256 totalAmount, uint256 totalShares) internal pure returns (uint256) {
        if (totalShares == 0 || totalAmount == 0) {
            return 0;
        }

        uint256 numerator = share * totalAmount;
        uint256 result = numerator / totalShares;
        
        // Round up
        if (numerator % totalShares != 0) {
            result += 1;
        }

        return result;
    }

    function toValue(uint256 _assetAmount, uint256 _assetPrice, uint256 _assetDecimals)
        internal
        pure
        returns (uint256)
    {
        return _assetAmount * _assetPrice / 10 ** _assetDecimals;
    }

    function sum(uint256[] memory _numbers) internal pure returns (uint256 s) {
        for(uint256 i; i < _numbers.length; i++) {
            s += _numbers[i];
        }
    }

    
    
    
    
    
    
    function calculateUtilization(uint256 _dp, uint256 _totalDeposits, uint256 _totalBorrowAmount)
        internal
        pure
        returns (uint256)
    {
        if (_totalDeposits == 0 || _totalBorrowAmount == 0) return 0;

        return _totalBorrowAmount * _dp / _totalDeposits;
    }
}

// 
pragma solidity >=0.7.6 <0.9.0;


library Ping {
    function pong(function() external pure returns(bytes4) pingFunction) internal pure returns (bool) {
        return pingFunction.address != address(0) && pingFunction.selector == pingFunction();
    }
}

// 
pragma solidity 0.8.13;









library Solvency {
    using EasyMath for uint256;

    
    /// MaximumLTV - Maximum Loan-to-Value ratio represents the maximum borrowing power of all user's collateral
    /// positions in a Silo
    /// LiquidationThreshold - Liquidation Threshold represents the threshold at which all user's borrow positions
    /// in a Silo will be considered under collateralized and subject to liquidation
    enum TypeofLTV { MaximumLTV, LiquidationThreshold }

    error DifferentArrayLength();
    error UnsupportedLTVType();

    struct SolvencyParams {
        
        ISiloRepository siloRepository;
        
        ISilo silo;
        
        address[] assets;
        
        ISilo.AssetStorage[] assetStates;
        
        address user;
    }

    
    uint256 internal constant _PRECISION_DECIMALS = 1e18;
    uint256 internal constant _INFINITY = type(uint256).max;

    
    
    /// going and predefined results can be returned.
    
    
    
    
    /// or the collateral are zero
    function calculateLTVs(SolvencyParams memory _params, TypeofLTV _secondLtvType)
        internal
        view
        returns (uint256 currentUserLTV, uint256 secondLTV)
    {
        uint256[] memory totalBorrowAmounts = getBorrowAmounts(_params);

        // this return avoids eg. additional checks on withdraw, when user did not borrow any asset
        if (EasyMath.sum(totalBorrowAmounts) == 0) return (0, 0);

        IPriceProvidersRepository priceProvidersRepository = _params.siloRepository.priceProvidersRepository();

        uint256[] memory borrowValues = convertAmountsToValues(
            priceProvidersRepository,
            _params.assets,
            totalBorrowAmounts
        );

        // value of user's total debt
        uint256 borrowTotalValue = EasyMath.sum(borrowValues);

        if (borrowTotalValue == 0) return (0, 0);

        uint256[] memory collateralValues = getUserCollateralValues(priceProvidersRepository, _params);

        // value of user's collateral
        uint256 collateralTotalValue = EasyMath.sum(collateralValues);

        if (collateralTotalValue == 0) return (_INFINITY, 0);

        // value of theoretical debt user can have depending on TypeofLTV
        uint256 borrowAvailableTotalValue = _getTotalAvailableToBorrowValue(
            _params.siloRepository,
            address(_params.silo),
            _params.assets,
            _secondLtvType,
            collateralValues
        );

        currentUserLTV = borrowTotalValue * _PRECISION_DECIMALS / collateralTotalValue;

        // one of Solvency.TypeofLTV
        secondLTV = borrowAvailableTotalValue * _PRECISION_DECIMALS / collateralTotalValue;
    }

    
    
    /// optimized for protocol use and may not return second LVT calculation when they are not needed.
    
    
    
    function calculateLTVLimit(SolvencyParams memory _params, TypeofLTV _ltvType)
        internal
        view
        returns (uint256 limit)
    {
        IPriceProvidersRepository priceProvidersRepository = _params.siloRepository.priceProvidersRepository();

        uint256[] memory collateralValues = getUserCollateralValues(priceProvidersRepository, _params);

        // value of user's collateral
        uint256 collateralTotalValue = EasyMath.sum(collateralValues);

        if (collateralTotalValue == 0) return 0;

        // value of theoretical debt user can have depending on TypeofLTV
        uint256 borrowAvailableTotalValue = _getTotalAvailableToBorrowValue(
            _params.siloRepository,
            address(_params.silo),
            _params.assets,
            _ltvType,
            collateralValues
        );

        limit = borrowAvailableTotalValue * _PRECISION_DECIMALS / collateralTotalValue;
    }

    
    
    
    
    function getUserCollateralValues(IPriceProvidersRepository _priceProvidersRepository, SolvencyParams memory _params)
        internal
        view
        returns(uint256[] memory collateralValues)
    {
        uint256[] memory collateralAmounts = getCollateralAmounts(_params);
        collateralValues = convertAmountsToValues(_priceProvidersRepository, _params.assets, collateralAmounts);
    }

    
    
    
    
    
    function convertAmountsToValues(
        IPriceProvidersRepository _priceProviderRepo,
        address[] memory _assets,
        uint256[] memory _amounts
    ) internal view returns (uint256[] memory values) {
        if (_assets.length != _amounts.length) revert DifferentArrayLength();

        values = new uint256[](_assets.length);

        for (uint256 i = 0; i < _assets.length; i++) {
            if (_amounts[i] == 0) continue;

            uint256 assetPrice = _priceProviderRepo.getPrice(_assets[i]);
            uint8 assetDecimals = ERC20(_assets[i]).decimals();

            values[i] = _amounts[i].toValue(assetPrice, assetDecimals);
        }
    }

    
    
    
    /// did not deposit given collateral token.
    function getCollateralAmounts(SolvencyParams memory _params)
        internal
        view
        returns (uint256[] memory collateralAmounts)
    {
        if (_params.assets.length != _params.assetStates.length) {
            revert DifferentArrayLength();
        }

        collateralAmounts = new uint256[](_params.assets.length);

        for (uint256 i = 0; i < _params.assets.length; i++) {
            uint256 userCollateralTokenBalance = _params.assetStates[i].collateralToken.balanceOf(_params.user);
            uint256 userCollateralOnlyTokenBalance = _params.assetStates[i].collateralOnlyToken.balanceOf(_params.user);

            if (userCollateralTokenBalance + userCollateralOnlyTokenBalance == 0) continue;

            uint256 rcomp = getRcomp(_params.silo, _params.siloRepository, _params.assets[i], block.timestamp);

            collateralAmounts[i] = getUserCollateralAmount(
                _params.assetStates[i],
                userCollateralTokenBalance,
                userCollateralOnlyTokenBalance,
                rcomp,
                _params.siloRepository
            );
        }
    }

    
    
    
    /// did not borrow given token.
    function getBorrowAmounts(SolvencyParams memory _params)
        internal
        view
        returns (uint256[] memory totalBorrowAmounts)
    {
        if (_params.assets.length != _params.assetStates.length) {
            revert DifferentArrayLength();
        }

        totalBorrowAmounts = new uint256[](_params.assets.length);

        for (uint256 i = 0; i < _params.assets.length; i++) {
            uint256 rcomp = getRcomp(_params.silo, _params.siloRepository, _params.assets[i], block.timestamp);
            totalBorrowAmounts[i] = getUserBorrowAmount(_params.assetStates[i], _params.user, rcomp);
        }
    }

    
    
    
    
    
    
    
    function getUserCollateralAmount(
        ISilo.AssetStorage memory _assetStates,
        uint256 _userCollateralTokenBalance,
        uint256 _userCollateralOnlyTokenBalance,
        uint256 _rcomp,
        ISiloRepository _siloRepository
    ) internal view returns (uint256) {
        uint256 assetAmount = _userCollateralTokenBalance == 0 ? 0 : _userCollateralTokenBalance.toAmount(
            totalDepositsWithInterest(_assetStates.totalDeposits, _siloRepository.protocolShareFee(), _rcomp),
            _assetStates.collateralToken.totalSupply()
        );

        uint256 assetCollateralOnlyAmount = _userCollateralOnlyTokenBalance == 0
            ? 0
            : _userCollateralOnlyTokenBalance.toAmount(
                _assetStates.collateralOnlyDeposits,
                _assetStates.collateralOnlyToken.totalSupply()
            );

        return assetAmount + assetCollateralOnlyAmount;
    }

    
    
    
    
    
    function getUserBorrowAmount(ISilo.AssetStorage memory _assetStates, address _user, uint256 _rcomp)
        internal
        view
        returns (uint256)
    {
        uint256 balance = _assetStates.debtToken.balanceOf(_user);
        if (balance == 0) return 0;

        uint256 totalBorrowAmountCached = totalBorrowAmountWithInterest(_assetStates.totalBorrowAmount, _rcomp);
        return balance.toAmountRoundUp(totalBorrowAmountCached, _assetStates.debtToken.totalSupply());
    }

    
    
    
    
    
    
    function getRcomp(ISilo _silo, ISiloRepository _siloRepository, address _asset, uint256 _timestamp)
        internal
        view
        returns (uint256 rcomp)
    {
        IInterestRateModel model = _siloRepository.getInterestRateModel(address(_silo), _asset);
        rcomp = model.getCompoundInterestRate(address(_silo), _asset, _timestamp);
    }

    
    
    
    
    
    function totalDepositsWithInterest(uint256 _assetTotalDeposits, uint256 _protocolShareFee, uint256 _rcomp)
        internal
        pure
        returns (uint256 _totalDepositsWithInterests)
    {
        uint256 depositorsShare = _PRECISION_DECIMALS - _protocolShareFee;

        return _assetTotalDeposits + _assetTotalDeposits * _rcomp / _PRECISION_DECIMALS * depositorsShare /
            _PRECISION_DECIMALS;
    }

    
    
    
    
    function totalBorrowAmountWithInterest(uint256 _totalBorrowAmount, uint256 _rcomp)
        internal
        pure
        returns (uint256 totalBorrowAmountWithInterests)
    {
        totalBorrowAmountWithInterests = _totalBorrowAmount + _totalBorrowAmount * _rcomp / _PRECISION_DECIMALS;
    }

    
    
    
    
    
    
    function calculateLiquidationFee(uint256 _protocolEarnedFees, uint256 _amount, uint256 _liquidationFee)
        internal
        pure
        returns (uint256 liquidationFeeAmount, uint256 newProtocolEarnedFees)
    {
        unchecked {
            // If we overflow on multiplication it should not revert tx, we will get lower fees
            liquidationFeeAmount = _amount * _liquidationFee / Solvency._PRECISION_DECIMALS;

            if (_protocolEarnedFees > type(uint256).max - liquidationFeeAmount) {
                newProtocolEarnedFees = type(uint256).max;
                liquidationFeeAmount = type(uint256).max - _protocolEarnedFees;
            } else {
                newProtocolEarnedFees = _protocolEarnedFees + liquidationFeeAmount;
            }
        }
    }

    
    
    
    
    
    
    
    function _getAvailableToBorrowValue(
        ISiloRepository _siloRepository,
        address _silo,
        address _asset,
        TypeofLTV _type,
        uint256 _collateralValue
    ) private view returns (uint256 availableToBorrow) {
        uint256 assetLTV;

        if (_type == TypeofLTV.MaximumLTV) {
            assetLTV = _siloRepository.getMaximumLTV(_silo, _asset);
        } else if (_type == TypeofLTV.LiquidationThreshold) {
            assetLTV = _siloRepository.getLiquidationThreshold(_silo, _asset);
        } else {
            revert UnsupportedLTVType();
        }

        // value that can be borrowed against the deposit
        // ie. for assetLTV = 50%, 1 ETH * 50% = 0.5 ETH of available to borrow
        availableToBorrow = _collateralValue * assetLTV / _PRECISION_DECIMALS;
    }

    
    
    
    
    
    /// acceptable values are only TypeofLTV.MaximumLTV or TypeofLTV.LiquidationThreshold
    
    
    function _getTotalAvailableToBorrowValue(
        ISiloRepository _siloRepository,
        address _silo,
        address[] memory _assets,
        TypeofLTV _ltvType,
        uint256[] memory _collateralValues
    ) private view returns (uint256 totalAvailableToBorrowValue) {
        if (_assets.length != _collateralValues.length) revert DifferentArrayLength();

        for (uint256 i = 0; i < _assets.length; i++) {
            totalAvailableToBorrowValue += _getAvailableToBorrowValue(
                _siloRepository,
                _silo,
                _assets[i],
                _ltvType,
                _collateralValues[i]
            );
        }
    }
}

// 
pragma solidity 0.8.13;








contract SiloLiquidationLens {
    using EasyMath for uint256;

    ISiloRepository immutable public siloRepository;

    error InvalidSiloRepository();

    constructor (ISiloRepository _siloRepo) {
        if (!Ping.pong(_siloRepo.siloRepositoryPing)) revert InvalidSiloRepository();

        siloRepository = _siloRepo;
    }

    
    
    
    
    
    /// amounts of collaterals send to `_flashReceiver`
    
    /// required amounts of debt to be repaid
    function flashLiquidateView(ISilo _silo, address[] memory _users)
        external
        view
        returns (
            address[] memory assets,
            uint256[][] memory receivedCollaterals,
            uint256[][] memory shareAmountsToRepay
        )
    {
        assets = _silo.getAssets();
        uint256 usersLength = _users.length;
        receivedCollaterals = new uint256[][](usersLength);
        shareAmountsToRepay = new uint256[][](usersLength);

        for (uint256 i = 0; i < usersLength; i++) {
            (receivedCollaterals[i], shareAmountsToRepay[i]) = _userLiquidationView(_silo, assets, _users[i]);
        }
    }

    
    
    
    
    function getModel(ISilo _silo, address _asset) public view returns (IInterestRateModel) {
        return IInterestRateModel(siloRepository.getInterestRateModel(address(_silo), _asset));
    }

    function _userLiquidationView(ISilo _silo, address[] memory _assets, address _user)
        internal
        view
        returns (uint256[] memory receivedCollaterals, uint256[] memory shareAmountsToRepay)
    {
        // gracefully fail if _user is solvent
        if (_silo.isSolvent(_user)) {
            uint256[] memory empty = new uint256[](_assets.length);
            return (empty, empty);
        }

        (receivedCollaterals, shareAmountsToRepay) = _flashUserLiquidationView(_silo, _assets, _user);
    }

    function _flashUserLiquidationView(ISilo _silo, address[] memory _allSiloAssets, address _borrower)
        internal
        view
        returns (uint256[] memory receivedCollaterals, uint256[] memory amountsToRepay)
    {
        uint256 assetsLength = _allSiloAssets.length;
        receivedCollaterals = new uint256[](assetsLength);
        amountsToRepay = new uint256[](assetsLength);

        uint256 protocolLiquidationFee = siloRepository.protocolLiquidationFee();

        for (uint256 i = 0; i < assetsLength; i++) {
            ISilo.AssetStorage memory _state = _silo.assetStorage(_allSiloAssets[i]);
            ISilo.AssetInterestData memory _assetInterestData = _silo.interestData(_allSiloAssets[i]);

            _accrueInterestView(_silo, _state, _assetInterestData, _allSiloAssets[i]);
            // we do not allow for partial repayment on liquidation, that's why max
            (amountsToRepay[i],) = _calculateDebtAmountAndShare(_state, _borrower);

            uint256 withdrawnOnlyAmount = _calculateWithdrawAssetAmount(
                _state.collateralOnlyDeposits,
                _state.collateralOnlyToken,
                _borrower,
                protocolLiquidationFee,
                _assetInterestData.protocolFees
            );

            uint256 withdrawnAmount = _calculateWithdrawAssetAmount(
                _state.totalDeposits,
                _state.collateralToken,
                _borrower,
                protocolLiquidationFee,
                _assetInterestData.protocolFees
            );

            receivedCollaterals[i] = withdrawnOnlyAmount + withdrawnAmount;
        }
    }

    function _accrueInterestView(
        ISilo _silo,
        ISilo.AssetStorage memory _state,
        ISilo.AssetInterestData memory _assetInterestData,
        address _asset
    )
        internal
        view
    {
        uint256 lastTimestamp = _assetInterestData.interestRateTimestamp;

        // This is the first time, so we can return early and save some gas
        if (lastTimestamp == 0) {
            _assetInterestData.interestRateTimestamp = uint64(block.timestamp);
            return;
        }

        // Interest has already been accrued this block
        if (lastTimestamp == block.timestamp) {
            return;
        }

        uint256 rcomp = getModel(_silo, _asset).getCompoundInterestRate(address(_silo), _asset, block.timestamp);
        uint256 protocolShareFee = siloRepository.protocolShareFee();

        uint256 totalBorrowAmountCached = _state.totalBorrowAmount;

        uint256 totalInterest = totalBorrowAmountCached * rcomp / Solvency._PRECISION_DECIMALS;
        uint256 protocolShare = totalInterest * protocolShareFee / Solvency._PRECISION_DECIMALS;
        uint256 depositorsShare = totalInterest - protocolShare;

        // update contract state
        _state.totalBorrowAmount = totalBorrowAmountCached + totalInterest;
        _state.totalDeposits = _state.totalDeposits + depositorsShare;
        _assetInterestData.protocolFees = _assetInterestData.protocolFees + protocolShare;
        _assetInterestData.interestRateTimestamp = uint64(block.timestamp);
    }

    function _calculateDebtAmountAndShare(ISilo.AssetStorage memory _assetStorage, address _borrower)
        internal
        view
        returns (uint256 amount, uint256 repayShare)
    {
        repayShare = _assetStorage.debtToken.balanceOf(_borrower);
        uint256 debtTokenTotalSupply = _assetStorage.debtToken.totalSupply();
        uint256 totalBorrowed = _assetStorage.totalBorrowAmount;
        amount = repayShare.toAmountRoundUp(totalBorrowed, debtTokenTotalSupply);
    }

    function _calculateWithdrawAssetAmount(
        uint256 _assetTotalDeposits,
        IShareToken _shareToken,
        address _depositor,
        uint256 _protocolLiquidationFee,
        uint256 _protocolFees
    )
        internal
        view
        returns (uint256 withdrawnAmount)
    {
        uint256 burnedShare = _shareToken.balanceOf(_depositor);
        withdrawnAmount = burnedShare.toAmount(_assetTotalDeposits, _shareToken.totalSupply());

        if (withdrawnAmount == 0) return 0;

        if (_protocolLiquidationFee != 0) {
            withdrawnAmount = _applyLiquidationFee(withdrawnAmount, _protocolLiquidationFee, _protocolFees);
        }
    }

    function _applyLiquidationFee(
        uint256 _amount,
        uint256 _protocolLiquidationFee,
        uint256 _protocolFees
    )
        internal
        pure
        returns (uint256 change)
    {
        uint256 liquidationFeeAmount;

        (liquidationFeeAmount,) = Solvency.calculateLiquidationFee(_protocolFees, _amount, _protocolLiquidationFee);

        unchecked {
            // if fees will not be higher than 100% this will not underflow, this is responsibility of siloRepository
            // in case we do underflow, we can expect liquidator reject tx because of too little change
            change = _amount - liquidationFeeAmount;
        }
    }
}