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
pragma solidity 0.8.13;




/// in the sense that the recipient of a transfer needs to approve the transfer amount first
interface IERC20R is IERC20 {
    
    /// a call to {changeReceiveApproval}. `value` is the new allowance.
    
    
    
    event ReceiveApproval(address indexed _owner, address indexed _receiver, uint256 _value);

    
    /// This is an alternative to {receive approve} that can be used as a mitigation for problems
    /// described in {IERC20-approve}.
    /// Emits an {ReceiveApproval} event indicating the updated receive allowance.
    
    
    function decreaseReceiveAllowance(address _owner, uint256 _subtractedValue) external;

    
    /// This is an alternative to {receive approve} that can be used as a mitigation for problems
    /// described in {IERC20-approve}.
    /// Emits an {ReceiveApproval} event indicating the updated receive allowance.
    
    
    function increaseReceiveAllowance(address _owner, uint256 _addedValue) external;

    
    /// Returns a boolean value indicating whether the operation succeeded.
    /// IMPORTANT: Beware that changing an allowance with this method brings the risk
    /// that someone may use both the old and the new allowance by unfortunate
    /// transaction ordering. One possible solution to mitigate this race
    /// condition is to first reduce the spender's allowance to 0 and set the
    /// desired value afterwards:
    /// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    /// OR use increase/decrease approval method instead.
    /// Emits an {ReceiveApproval} event.
    
    
    function setReceiveApproval(address _owner, uint256 _amount) external;

    
    /// through {transferFrom}. This is zero by default.
    
    
    
    function receiveAllowance(address _owner, address _receiver) external view returns (uint256);
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












abstract contract ShareToken is ERC20, IShareToken {
    
    /// that way losses caused by division will be reduced to acceptable level
    uint256 public constant MINIMUM_SHARE_AMOUNT = 1e5;

    
    ISilo public immutable silo;

    
    address public immutable asset;

    
    uint8 internal immutable _decimals;

    error OnlySilo();
    error MinimumShareRequirement();

    modifier onlySilo {
        if (msg.sender != address(silo)) revert OnlySilo();

        _;
    }

    
    
    
    constructor(address _silo, address _asset) {
        silo = ISilo(_silo);
        asset = _asset;
        _decimals = IERC20Metadata(_asset).decimals();
    }

    
    function mint(address _account, uint256 _amount) external onlySilo override {
        _mint(_account, _amount);
    }

    
    function burn(address _account, uint256 _amount) external onlySilo override {
        _burn(_account, _amount);
    }

    
    function symbol() public view virtual override(IERC20Metadata, ERC20) returns (string memory) {
        return ERC20.symbol();
    }

    
    function decimals() public view virtual override(IERC20Metadata, ERC20) returns (uint8) {
        return _decimals;
    }

    function _afterTokenTransfer(address _sender, address _recipient, uint256) internal override virtual {
        // fixing precision error on mint and burn
        if (_isTransfer(_sender, _recipient)) {
            return;
        }

        uint256 total = totalSupply();
        // we require minimum amount to be present from first mint
        // and after burning, we do not allow for small leftover
        if (total != 0 && total < MINIMUM_SHARE_AMOUNT) revert MinimumShareRequirement();
    }

    
    
    
    
    function _notifyAboutTransfer(address _from, address _to, uint256 _amount) internal {
        INotificationReceiver notificationReceiver =
            IBaseSilo(silo).siloRepository().getNotificationReceiver(address(silo));

        if (address(notificationReceiver) != address(0)) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success,) = address(notificationReceiver).call(
                abi.encodeWithSelector(
                    INotificationReceiver.onAfterTransfer.selector,
                    address(this),
                    _from,
                    _to,
                    _amount
                )
            );

            emit NotificationSent(notificationReceiver, success);
        }
    }

    
    
    
    
    function _isTransfer(address _sender, address _recipient) internal pure returns (bool) {
        // in order this check to be true, is is required to have:
        // require(sender != address(0), "ERC20: transfer from the zero address");
        // require(recipient != address(0), "ERC20: transfer to the zero address");
        // on transfer. ERC20 has them, so we good.
        return _sender != address(0) && _recipient != address(0);
    }
}
// 
pragma solidity 0.8.13;








contract TokensFactory is ITokensFactory {
    ISiloRepository public siloRepository;

    event InitSiloRepository();

    error OnlySilo();
    error SiloRepositoryAlreadySet();

    modifier onlySilo() {
        if (!siloRepository.isSilo(msg.sender)) revert OnlySilo();
        _;
    }

    
    function initRepository(address _repository) external {
        // We don't perform a ping to the repository because this is meant to be called in its constructor
        if (address(siloRepository) != address(0)) revert SiloRepositoryAlreadySet();

        siloRepository = ISiloRepository(_repository);
        emit InitSiloRepository();
    }

    
    function createShareCollateralToken(
        string memory _name,
        string memory _symbol,
        address _asset
    )
        external
        override
        onlySilo
        returns (IShareToken token)
    {
        token = new ShareCollateralToken(_name, _symbol, msg.sender, _asset);
        emit NewShareCollateralTokenCreated(address(token));
    }

    
    function createShareDebtToken(
        string memory _name,
        string memory _symbol,
        address _asset
    )
        external
        override
        onlySilo
        returns (IShareToken token)
    {
        token = new ShareDebtToken(_name, _symbol, msg.sender, _asset);
        emit NewShareDebtTokenCreated(address(token));
    }

    function tokensFactoryPing() external pure override returns (bytes4) {
        return this.tokensFactoryPing.selector;
    }
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







contract ShareCollateralToken is ShareToken {

    error SenderNotSolventAfterTransfer();
    error ShareTransferNotAllowed();

    
    
    
    
    
    constructor (
        string memory _name,
        string memory _symbol,
        address _silo,
        address _asset
    ) ERC20(_name, _symbol) ShareToken(_silo, _asset) {
        // all setup is done in parent contracts, nothing to do here
    }

    function _afterTokenTransfer(address _sender, address _recipient, uint256 _amount) internal override {
        ShareToken._afterTokenTransfer(_sender, _recipient, _amount);

        // if we minting or burning, Silo is responsible to check all necessary conditions
        // make sure that _sender is solvent after transfer
        if (_isTransfer(_sender, _recipient) && !silo.isSolvent(_sender)) {
            revert SenderNotSolventAfterTransfer();
        }

        // report mint or transfer
        _notifyAboutTransfer(_sender, _recipient, _amount);
    }

    function _beforeTokenTransfer(address _sender, address _recipient, uint256) internal view override {
        // if we minting or burning, Silo is responsible to check all necessary conditions
        if (!_isTransfer(_sender, _recipient)) {
            return;
        }

        // Silo forbids having debt and collateral position of the same asset in given Silo
        if (!silo.depositPossible(asset, _recipient)) revert ShareTransferNotAllowed();
    }
}

// 
pragma solidity 0.8.13;









///
/// It is assumed that there is no attack vector on taking someone else's debt because we don't see
/// economical reason why one would do such thing. For that reason anyone can transfer owner's token
/// to any recipient as long as receiving wallet approves the transfer. In other words, anyone can
/// take someone else's debt without asking.

contract ShareDebtToken is IERC20R, ShareToken {
    
    mapping(address => mapping(address => uint256)) private _receiveAllowances;

    error OwnerIsZero();
    error RecipientIsZero();
    error ShareTransferNotAllowed();
    error AmountExceedsAllowance();
    error RecipientNotSolventAfterTransfer();

    constructor (
        string memory _name,
        string memory _symbol,
        address _silo,
        address _asset
    ) ERC20(_name, _symbol) ShareToken(_silo, _asset) {
        // all setup is done in parent contracts, nothing to do here
    }

    
    function setReceiveApproval(address owner, uint256 _amount) external virtual override {
        _setReceiveApproval(owner, _msgSender(), _amount);
    }

    
    function decreaseReceiveAllowance(address _owner, uint256 _subtractedValue) public virtual override {
        uint256 currentAllowance = _receiveAllowances[_owner][_msgSender()];
        _setReceiveApproval(_owner, _msgSender(), currentAllowance - _subtractedValue);
    }

    
    function increaseReceiveAllowance(address _owner, uint256 _addedValue) public virtual override {
        uint256 currentAllowance = _receiveAllowances[_owner][_msgSender()];
        _setReceiveApproval(_owner, _msgSender(), currentAllowance + _addedValue);
    }

    
    function receiveAllowance(address _owner, address _recipient) public view virtual override returns (uint256) {
        return _receiveAllowances[_owner][_recipient];
    }

    
    
    
    
    function _setReceiveApproval(
        address _owner,
        address _recipient,
        uint256 _amount
    ) internal virtual {
        if (_owner == address(0)) revert OwnerIsZero();
        if (_recipient == address(0)) revert RecipientIsZero();

        _receiveAllowances[_owner][_recipient] = _amount;

        emit ReceiveApproval(_owner, _recipient, _amount);
    }

    function _beforeTokenTransfer(address _sender, address _recipient, uint256 _amount) internal override {
        // If we are minting or burning, Silo is responsible to check all necessary conditions
        if (!_isTransfer(_sender, _recipient)) {
            return;
        }

        // Silo forbids having debt and collateral position of the same asset in given Silo
        if (!silo.borrowPossible(asset, _recipient)) revert ShareTransferNotAllowed();

        // _recipient must approve debt transfer, _sender does not have to
        uint256 currentAllowance = receiveAllowance(_sender, _recipient);
        if (currentAllowance < _amount) revert AmountExceedsAllowance();

        // There can't be an underflow in the subtraction because of the previous check
        unchecked {
            // update debt allowance
            _setReceiveApproval(_sender, _recipient, currentAllowance - _amount);
        }
    }

    function _afterTokenTransfer(address _sender, address _recipient, uint256 _amount) internal override {
        ShareToken._afterTokenTransfer(_sender, _recipient, _amount);

        // if we are minting or burning, Silo is responsible to check all necessary conditions
        // if we are NOT minting and not burning, it means we are transferring
        // make sure that _recipient is solvent after transfer
        if (_isTransfer(_sender, _recipient) && !silo.isSolvent(_recipient)) {
            revert RecipientNotSolventAfterTransfer();
        }
        
        // report mint or transfer
        _notifyAboutTransfer(_sender, _recipient, _amount);
    }
}
