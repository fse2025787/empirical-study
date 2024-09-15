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
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
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

pragma solidity ^0.8.0;


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// 
pragma solidity 0.8.10;

interface IIdleCDOStrategy {
  function strategyToken() external view returns(address);
  function token() external view returns(address);
  function tokenDecimals() external view returns(uint256);
  function oneToken() external view returns(uint256);
  function redeemRewards(bytes calldata _extraData) external returns(uint256[] memory);
  function pullStkAAVE() external returns(uint256);
  function price() external view returns(uint256);
  function getRewardTokens() external view returns(address[] memory);
  function deposit(uint256 _amount) external returns(uint256);
  // _amount in `strategyToken`
  function redeem(uint256 _amount) external returns(uint256);
  // _amount in `token`
  function redeemUnderlying(uint256 _amount) external returns(uint256);
  function getApr() external view returns(uint256);
}

// 

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}

// 

pragma solidity ^0.8.0;


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// 

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
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overloaded;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
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
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

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
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
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
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
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
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    uint256[45] private __gap;
}

// 
pragma solidity 0.8.10;









abstract contract BaseStrategy is
    Initializable,
    OwnableUpgradeable,
    ERC20Upgradeable,
    ReentrancyGuardUpgradeable,
    IIdleCDOStrategy
{
    using SafeERC20Upgradeable for IERC20Detailed;

    uint256 internal constant EXP_SCALE = 1e18;

    
    uint256 private constant YEAR = 365 days;

    
    address public override token;

    
    address public override strategyToken;

    
    uint256 public override tokenDecimals;

    
    uint256 public override oneToken;

    
    IERC20Detailed public underlyingToken;

    
    address public idleCDO;

    
    uint256 public totalTokensStaked;

    
    uint256 public totalTokensLocked;

    
    uint256 public lastIndexedTime;

    
    
    uint128 public latestHarvestBlock;

    
    uint96 internal lastApr;

    
    uint32 public releaseBlocksPeriod;

    
    constructor() {
        token = address(1);
    }

    
    
    
    
    function _initialize(
        string memory _name,
        string memory _symbol,
        address _token,
        address _owner
    ) internal initializer {
        OwnableUpgradeable.__Ownable_init();
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        require(token == address(0), "Token is already initialized");

        //----- // -------//
        strategyToken = address(this);
        token = _token;
        underlyingToken = IERC20Detailed(token);
        tokenDecimals = underlyingToken.decimals();
        oneToken = 10**(tokenDecimals); // underlying decimals
        // note tokenized position has 18 decimals

        // Set basic parameters
        lastIndexedTime = block.timestamp;
        releaseBlocksPeriod = 6400;

        ERC20Upgradeable.__ERC20_init(_name, _symbol);
        //------//-------//

        transferOwnership(_owner);
    }

    
    
    function _deposit(uint256 _amount) internal virtual returns (uint256 amountUsed);

    
    
    function _withdraw(uint256 _amountToWithdraw, address _destination)
        internal
        virtual
        returns (uint256 amountWithdrawn);

    
    
    
    function deposit(uint256 _amount) external virtual override onlyIdleCDO returns (uint256 shares) {
        if (_amount != 0) {
            // Get current price
            uint256 _price = price();

            // Send tokens to the strategy
            IERC20Detailed(token).safeTransferFrom(msg.sender, address(this), _amount);

            // Calls our internal deposit function
            _amount = _deposit(_amount);

            // Adjust with actual staked amount
            if (_amount != 0) {
                totalTokensStaked += _amount;
            }

            // Mint shares
            shares = (_amount * EXP_SCALE) / _price;
            _mint(msg.sender, shares);
        }
    }

    
    
    
    function redeem(uint256 _shares) external virtual override onlyIdleCDO returns (uint256 amountRedeemed) {
        if (_shares != 0) {
            amountRedeemed = _positionWithdraw(_shares, msg.sender, price(), 0);
        }
    }

    
    
    
    function redeemUnderlying(uint256 _amount) external virtual onlyIdleCDO returns (uint256 amountRedeemed) {
        uint256 _price = price(); // in underlying terms
        uint256 _shares = (_amount * EXP_SCALE) / _price;
        if (_shares != 0) {
            amountRedeemed = _positionWithdraw(_shares, msg.sender, _price, 0);
        }
    }

    
    
    
    
    
    
    function _positionWithdraw(
        uint256 _shares,
        address _destination,
        uint256 _underlyingPerShare,
        uint256 _minUnderlying
    ) internal virtual returns (uint256 amountWithdrawn) {
        uint256 amountNeeded = (_shares * _underlyingPerShare) / EXP_SCALE;

        _burn(msg.sender, _shares);

        // Withdraw amount needed
        amountWithdrawn = _withdraw(amountNeeded, _destination);

        // Adjust with actual unstaked amount
        if (amountWithdrawn != 0) {
            totalTokensStaked -= amountWithdrawn;
        }

        // We revert if this call doesn't produce enough underlying
        // This security feature is useful in some edge cases
        require(amountWithdrawn >= _minUnderlying, "Not enough underlying");
    }

    
    
    ///         rewards[0] : mintedUnderlyings
    function redeemRewards(bytes calldata data)
        public
        virtual
        onlyIdleCDO
        nonReentrant
        returns (uint256[] memory rewards)
    {
        rewards = _redeemRewards(data);
        uint256 mintedUnderlyings = rewards[0];
        if (mintedUnderlyings == 0) {
            return rewards;
        }

        // reinvest the generated/minted underlying to the the `strategy`
        uint256 underlyingsStaked = _reinvest(mintedUnderlyings);
        // save the block in which rewards are swapped and the amount
        latestHarvestBlock = uint128(block.number);
        totalTokensLocked = underlyingsStaked;
        totalTokensStaked += underlyingsStaked;

        // update the apr after claiming the rewards
        _updateApr(underlyingsStaked);
    }

    
    ///      this method should be used in the `_redeemRewards` method
    ///      Ussually don't mint new shares.
    function _reinvest(uint256 underlyings) internal virtual returns (uint256 underlyingsStaked) {
        underlyingsStaked = _deposit(underlyings);
    }

    
    function _redeemRewards(bytes calldata data) internal virtual returns (uint256[] memory rewards);

    
    
    function _updateApr(uint256 _gain) internal {
        uint256 _totalSupply = totalSupply();
        uint256 timeIncrease = block.timestamp - lastIndexedTime;

        if (_totalSupply != 0 && timeIncrease != 0) {
            uint256 priceIncrease = (_gain * EXP_SCALE) / _totalSupply;
            // normalized to 1e18 decimals
            lastApr = uint96(
                priceIncrease * (YEAR / timeIncrease) * 100 * (10 ** (18 - tokenDecimals))
            ); // prettier-ignore
            lastIndexedTime = block.timestamp;
        }
    }

    
    
    function pullStkAAVE() external override returns (uint256 pulledAmount) {}

    
    
    function price() public view virtual override returns (uint256 _price) {
        uint256 _totalSupply = totalSupply();

        if (_totalSupply == 0) {
            _price = oneToken;
        } else {
            _price = ((totalTokensStaked - _lockedTokens()) * EXP_SCALE) / _totalSupply;
        }
    }

    function _lockedTokens() internal view returns (uint256 _locked) {
        uint256 _totalLockedTokens = totalTokensLocked;
        uint256 _releaseBlocksPeriod = releaseBlocksPeriod;
        uint256 _blocksSinceLastHarvest = block.number - latestHarvestBlock;

        if (_totalLockedTokens != 0 && _blocksSinceLastHarvest < _releaseBlocksPeriod) {
            // progressively release harvested rewards
            _locked = (_totalLockedTokens * (_releaseBlocksPeriod - _blocksSinceLastHarvest)) / _releaseBlocksPeriod; // prettier-ignore
        }
    }

    function getApr() external view virtual returns (uint256 apr) {
        apr = lastApr;
    }

    function setReleaseBlocksPeriod(uint32 _releaseBlocksPeriod) external onlyOwner {
        require(_releaseBlocksPeriod != 0, "IS_0");
        releaseBlocksPeriod = _releaseBlocksPeriod;
    }

    
    
    
    
    
    function transferToken(
        address _token,
        uint256 value,
        address _to
    ) external onlyOwner nonReentrant {
        IERC20Detailed(_token).safeTransfer(_to, value);
    }

    
    function setWhitelistedCDO(address _cdo) external onlyOwner {
        require(_cdo != address(0), "IS_0");
        idleCDO = _cdo;
    }

    
    modifier onlyIdleCDO() {
        require(idleCDO == msg.sender, "Only IdleCDO can call");
        _;
    }
}

// 
pragma solidity 0.8.10;








// One line change is needed for solidity 0.8.X to make it compile check here 
// https://ethereum.stackexchange.com/questions/96642/unary-operator-minus-cannot-be-applied-to-type-uint256








/// The contract is upgradable, to add storage slots, add them after the last `###### End of storage VXX`
contract IdleEulerStakingStrategy is BaseStrategy {
    using SafeERC20Upgradeable for IERC20Detailed;

    /// ###### End of storage BaseStrategy

    
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant UNI_V3_FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    uint256 internal constant SUB_ACCOUNT_ID = 0;
    
    IERC20Detailed internal constant EUL = IERC20Detailed(0xd9Fcd98c322942075A5C3860693e9f4f03AAE07b);
    
    IMarkets internal constant EULER_MARKETS = IMarkets(0x3520d5a913427E6F0D6A83E07ccD4A4da316e4d3);
    
    IEulerGeneralView internal constant EULER_GENERAL_VIEW =
        IEulerGeneralView(0xACC25c4d40651676FEEd43a3467F3169e3E68e42);

    IEToken public eToken;
    IStakingRewards public stakingRewards;

    /// ###### End of storage IdleEulerStakingStrategy

    // ###################
    // Initializer
    // ###################

    
    
    
    
    
    
    
    function initialize(
        address _eToken,
        address _underlyingToken,
        address _eulerMain,
        address _stakingRewards,
        address _owner
    ) public virtual initializer {
        _initialize(
            string(abi.encodePacked("Idle Euler ", IERC20Detailed(_eToken).name(), " Staking Strategy")),
            string(abi.encodePacked("idleEulStk_", IERC20Detailed(_eToken).symbol())),
            _underlyingToken,
            _owner
        );
        eToken = IEToken(_eToken);
        stakingRewards = IStakingRewards(_stakingRewards);

        // approve Euler protocol uint256 max for deposits
        underlyingToken.safeApprove(_eulerMain, type(uint256).max);
        // approve stakingRewards contract uint256 max for staking
        IERC20Detailed(_eToken).safeApprove(_stakingRewards, type(uint256).max);
    }

    // ###################
    // Public methods
    // ###################

    
    
    
    function deposit(uint256 _amount) external virtual override onlyIdleCDO returns (uint256 shares) {
        if (_amount != 0) {
            IEToken _eToken = eToken;
            IStakingRewards _stakingRewards = stakingRewards;
            uint256 eTokenBalanceBefore = _eToken.balanceOf(address(this));
            // Send tokens to the strategy
            underlyingToken.safeTransferFrom(msg.sender, address(this), _amount);

            _eToken.deposit(SUB_ACCOUNT_ID, _amount);

            // Mint shares 1:1 ratio
            shares = _eToken.balanceOf(address(this)) - eTokenBalanceBefore;
            if (address(_stakingRewards) != address(0)) {
                _stakingRewards.stake(shares);
            }

            _mint(msg.sender, shares);
        }
    }

    function redeemRewards(bytes calldata data)
        public
        override
        onlyIdleCDO
        nonReentrant
        returns (uint256[] memory rewards)
    {
        rewards = _redeemRewards(data);
    }

    
    
    
    function redeem(uint256 _shares) external override onlyIdleCDO returns (uint256 amountRedeemed) {
        if (_shares != 0) {
            _burn(msg.sender, _shares);
            // Withdraw amount needed
            amountRedeemed = _withdraw((_shares * price()) / EXP_SCALE, msg.sender);
        }
    }

    
    
    
    function redeemUnderlying(uint256 _amount) external override onlyIdleCDO returns (uint256 amountRedeemed) {
        uint256 _shares = (_amount * EXP_SCALE) / price();
        if (_shares != 0) {
            _burn(msg.sender, _shares);
            // Withdraw amount needed
            amountRedeemed = _withdraw(_amount, msg.sender);
        }
    }

    // ###################
    // Internal
    // ###################

    
    function _deposit(uint256 _amount) internal override returns (uint256 amountUsed) {}

    
    
    
    function _withdraw(uint256 _amountToWithdraw, address _destination)
        internal
        virtual
        override
        returns (uint256 amountWithdrawn)
    {
        IEToken _eToken = eToken;
        IERC20Detailed _underlyingToken = underlyingToken;
        IStakingRewards _stakingRewards = stakingRewards;

        if (address(_stakingRewards) != address(0)) {
            // Unstake from StakingRewards
            _stakingRewards.withdraw(_eToken.convertUnderlyingToBalance(_amountToWithdraw));
        }

        uint256 underlyingsInEuler = _eToken.balanceOfUnderlying(address(this));
        if (_amountToWithdraw > underlyingsInEuler) {
            _amountToWithdraw = underlyingsInEuler;
        }

        // Withdraw from Euler
        uint256 underlyingBalanceBefore = _underlyingToken.balanceOf(address(this));
        _eToken.withdraw(SUB_ACCOUNT_ID, _amountToWithdraw);
        amountWithdrawn = _underlyingToken.balanceOf(address(this)) - underlyingBalanceBefore;
        // Send tokens to the destination
        _underlyingToken.safeTransfer(_destination, amountWithdrawn);
    }

    
    function _redeemRewards(bytes calldata) internal override returns (uint256[] memory rewards) {
        IStakingRewards _stakingRewards = stakingRewards;
        if (address(_stakingRewards) != address(0)) {
            // Get rewards from StakingRewards contract
            _stakingRewards.getReward();
        }
        // transfer rewards to the IdleCDO contract
        rewards = new uint256[](1);
        rewards[0] = EUL.balanceOf(address(this));
        EUL.safeTransfer(idleCDO, rewards[0]);
    }

    // ###################
    // Views
    // ###################

    
    function price() public view virtual override returns (uint256) {
        IEToken _eToken = eToken;
        uint256 eTokenDecimals = _eToken.decimals();
        // return price of 1 eToken in underlying
        return _eToken.convertBalanceToUnderlying(10**eTokenDecimals);
    }

    
    
    function getApr() external view override returns (uint256 apr) {
        // Use the markets module:
        address _token = token;
        IMarkets markets = IMarkets(EULER_MARKETS);
        IDToken dToken = IDToken(markets.underlyingToDToken(_token));
        uint256 borrowSPY = uint256(int256(markets.interestRate(_token)));
        uint256 totalBorrows = dToken.totalSupply();
        uint256 totalBalancesUnderlying = eToken.totalSupplyUnderlying();
        uint32 reserveFee = markets.reserveFee(_token);
        // (borrowAPY, supplyAPY)
        (, apr) = IEulerGeneralView(EULER_GENERAL_VIEW).computeAPYs(
            borrowSPY,
            totalBorrows,
            totalBalancesUnderlying,
            reserveFee
        );
        // apr is eg 0.024300334 * 1e27 for 2.43% apr
        // while the method needs to return the value in the format 2.43 * 1e18
        // so we do apr / 1e9 * 100 -> apr / 1e7
        // then we add the staking apr
        apr = apr / 1e7 + _getStakingApr();
    }

    
    
    function _getStakingApr() internal view returns (uint256 _apr) {
        IStakingRewards _stakingRewards = stakingRewards;
        IERC20Detailed _underlying = underlyingToken;
        uint256 _tokenDec = tokenDecimals;

        // get quote of 1 EUL in underlyings, 1% fee pool for EUL. 
        uint256 eulPrice = _getPriceUniV3(address(EUL), WETH, uint24(10000));
        if (address(_underlying) != WETH) {
            // 0.05% fee pool. This returns a price with tokenDecimals
            uint256 wethToUnderlying = _getPriceUniV3(WETH, address(_underlying), uint24(500));
            eulPrice = eulPrice * wethToUnderlying / EXP_SCALE; // in underlyings
        }

        // USDC as example (6 decimals)
        // underlyingsPerPoolYear = EULPerSec * EULPrice * 365 days / 1e18 => 1e6
        uint256 underlyingsPerPoolYear = _stakingRewards.rewardRate() * eulPrice * 365 days / EXP_SCALE;
        uint256 eTokensStaked = eToken.balanceOf(address(_stakingRewards));
        // underlyings_per_year_per_token  = underlyings_per_year_whole_pool * 1e18 / (eTokensStaked * eTokenPrice / 1e6) => 1e6 
        uint256 underlyingsPerTokenYear = underlyingsPerPoolYear * EXP_SCALE / (eTokensStaked * price() / 10**(_tokenDec));
        // we normalize underlyingsPerTokenYear and multiply by 100 to get the apr % with 18 decimals
        _apr = underlyingsPerTokenYear * 10**(18-_tokenDec) * 100;
    }

    
    function _getPriceUniV3(address tokenIn, address tokenOut, uint24 _fee)
        internal
        view
        returns (uint256 _price)
    {
        IUniswapV3Pool pool = IUniswapV3Pool(IUniswapV3Factory(UNI_V3_FACTORY).getPool(tokenIn, tokenOut, _fee));
        (uint160 sqrtPriceX96,,,,,,) =  pool.slot0();
        uint256 _scaledPrice = uint256(sqrtPriceX96) * uint256(sqrtPriceX96);
        if (tokenOut == pool.token0()) {
            // token1Price -> ratio of token0 over token1
            _price = FullMath.mulDiv(2**192, EXP_SCALE, _scaledPrice);
        } else {
            // token0Price -> ratio of token1 over token0 
            _price = FullMath.mulDiv(EXP_SCALE, _scaledPrice, 2**192);
        }
    }

    
    function getRewardTokens() external pure override returns (address[] memory tokens) {
        tokens = new address[](1);
        tokens[0] = address(EUL);
    }

    // ###################
    // Protected
    // ###################

    
    function exitStaking() external onlyOwner {
        stakingRewards.exit();
    }

    function setStakingRewards(address _stakingRewards) external onlyOwner {
        stakingRewards = IStakingRewards(_stakingRewards);
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;



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
pragma solidity >=0.5.0;



interface IUniswapV3PoolImmutables {
    
    
    function factory() external view returns (address);

    
    
    function token0() external view returns (address);

    
    
    function token1() external view returns (address);

    
    
    function fee() external view returns (uint24);

    
    
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    
    function tickSpacing() external view returns (int24);

    
    
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    
    function maxLiquidityPerTick() external view returns (uint128);
}

// 
pragma solidity >=0.5.0;



/// per transaction
interface IUniswapV3PoolState {
    
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

    
    
    function feeGrowthGlobal0X128() external view returns (uint256);

    
    
    function feeGrowthGlobal1X128() external view returns (uint256);

    
    
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    
    
    function liquidity() external view returns (uint128);

    
    
    
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    
    
    
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    
    
    
    /// ago, rather than at a specific index in the array.
    
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}

// 
pragma solidity >=0.5.0;



/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    
    
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    
    
    
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    
    
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    
    
    
    
    
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolActions {
    
    
    
    function initialize(uint160 sqrtPriceX96) external;

    
    
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    
    
    
    
    
    
    
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    
    
    
    
    
    
    
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    
    
    
    
    
    
    
    
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    
    
    
    
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    
    
    
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    
    
    
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    
    
    
    
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    
    
    /// the input observationCardinalityNext.
    
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolOwnerActions {
    
    
    
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    
    
    
    
    
    
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolEvents {
    
    
    
    
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    
    
    
    
    
    
    
    
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    
    
    
    
    
    
    
    
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    
    
    
    
    
    
    
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    
    
    /// just before a mint/swap/burn.
    
    
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    
    
    
    
    
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    
    
    
    
    
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}
// 
pragma solidity 0.8.10;







contract IdleEulerStakingStrategyPSM is IdleEulerStakingStrategy {
    using SafeERC20Upgradeable for IERC20Detailed;

    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    IPSM public constant DAIPSM = IPSM(0x89B78CfA322F6C5dE0aBcEecab66Aee45393cC5A);
    // ###################
    // Initializer
    // ###################

    
    
    
    
    
    
    
    function initialize(
        address _eToken,
        address _underlyingToken,
        address _eulerMain,
        address _stakingRewards,
        address _owner
    ) public virtual override initializer {
        super.initialize(_eToken, _underlyingToken, _eulerMain, _stakingRewards, _owner);

        // approve psm and helper to spend DAI and USDC
        IERC20Detailed(DAI).safeApprove(address(DAIPSM), type(uint256).max);
        // underlying here is USDC
        underlyingToken.safeApprove(address(DAIPSM.gemJoin()), type(uint256).max);
    }

    
    
    function price() public view override returns (uint256 _price) {
        // 18 decimals, ie DAI decimals
        _price = super.price() * 10**12; // 12 => 18 - tokenDecimals which for usdc is 6
    }

     
    
    
    function deposit(uint256 _amount)
        external
        override
        onlyIdleCDO
        returns (uint256 shares)
    {
        if (_amount > 0) {
            IERC20Detailed(DAI).safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );
            // convert amount of DAI in USDC, 1-to-1
            // Maker expect amount to be in `gem` (ie USDC in this case)
            _amount = _amount / 10**12; // 12 => 18 - tokenDecimals which for usdc is 6
            sellDAI(_amount);
            IEToken _eToken = eToken;
            IStakingRewards _stakingRewards = stakingRewards;
            uint256 eTokenBalanceBefore = _eToken.balanceOf(address(this));
            // the amount passed here is in USDC (6 decimals)
            _eToken.deposit(SUB_ACCOUNT_ID, _amount);
            shares = _eToken.balanceOf(address(this)) - eTokenBalanceBefore;
            // stake in euler
            if (address(_stakingRewards) != address(0)) {
                _stakingRewards.stake(shares);
            }
            // Mint shares 1:1 ratio, shares have 18 decimals like eUSDC
            _mint(msg.sender, shares);
        }
    }

    
    
    
    function _withdraw(uint256 _amountToWithdraw, address _destination)
        internal
        override
        returns (uint256 amountWithdrawn)
    {
        IEToken _eToken = eToken;
        IERC20Detailed _underlyingToken = underlyingToken;
        IStakingRewards _stakingRewards = stakingRewards;

        // _amountToWithdraw has 18 decimals and we need to pass an amount in underlyings (USDC) so 6 decimals
        _amountToWithdraw = _amountToWithdraw / 10**12;

        if (address(_stakingRewards) != address(0)) {
            // Unstake from StakingRewards
            _stakingRewards.withdraw(_eToken.convertUnderlyingToBalance(_amountToWithdraw));
        }

        uint256 underlyingsInEuler = _eToken.balanceOfUnderlying(address(this));
        if (_amountToWithdraw > underlyingsInEuler) {
            _amountToWithdraw = underlyingsInEuler;
        }

        // Withdraw from Euler
        uint256 underlyingBalanceBefore = _underlyingToken.balanceOf(address(this));
        _eToken.withdraw(SUB_ACCOUNT_ID, _amountToWithdraw);
        amountWithdrawn = _underlyingToken.balanceOf(address(this)) - underlyingBalanceBefore;

        // Modified from here wrt the original _withdraw
        // buy DAI with USDC redeemed via PSM, Maker expect 18 decimals here
        buyDAI(amountWithdrawn);
        // Send DAI to the destination
        IERC20Detailed dai = IERC20Detailed(DAI);
        amountWithdrawn = dai.balanceOf(address(this));
        dai.safeTransfer(_destination, amountWithdrawn);
    }

    function sellDAI(uint256 _amount) internal {
        // 1inch fallback?
        require(DAIPSM.tin() == 0 && DAIPSM.tout() == 0, 'FEE!0');
        DAIPSM.buyGem(address(this), _amount);
    }

    function buyDAI(uint256 _amount) internal {
        // 1inch fallback?
        require(DAIPSM.tin() == 0 && DAIPSM.tout() == 0, 'FEE!0');
        DAIPSM.sellGem(address(this), _amount);
    }
}

// 
pragma solidity 0.8.10;
interface IPSM {
    function gemJoin() external view returns (address);
    function tin() external view returns (uint256);
    function tout() external view returns (uint256);
    function sellGem(address _to, uint256 _amount) external;
    function buyGem(address _to, uint256 _amount) external;
}

// 
pragma solidity 0.8.10;



interface IEToken is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);

    
    
    
    function deposit(uint256 subAccountId, uint256 amount) external;

    
    
    
    function mint(uint256 subAccountId, uint256 amount) external;

    
    
    
    function withdraw(uint256 subAccountId, uint256 amount) external;

    
    
    
    function burn(uint256 subAccountId, uint256 amount) external;

    
    function balanceOfUnderlying(address account) external view returns (uint256);

    
    
    
    function convertBalanceToUnderlying(uint256 balance) external view returns (uint256);

    
    
    
    function convertUnderlyingToBalance(uint256 underlyingAmount) external view returns (uint256);

    
    function totalSupplyUnderlying() external view returns (uint256);
}

// 
pragma solidity 0.8.10;



interface IDToken is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);

    
    
    
    function borrow(uint256 subAccountId, uint256 amount) external;

    
    
    
    function repay(uint256 subAccountId, uint256 amount) external;
}

// 
pragma solidity 0.8.10;

interface IMarkets {
    struct AssetConfig {
        address eTokenAddress;
        bool borrowIsolated;
        uint32 collateralFactor;
        uint32 borrowFactor;
        uint24 twapWindow;
    }

    
    
    
    function underlyingToDToken(address underlying) external view returns (address);
    function underlyingToEToken(address underlying) external view returns (address);

    
    
    
    function interestRate(address underlying) external view returns (int96);
    function interestRateModel(address underlying) external view returns (uint256);

    
    
    
    function reserveFee(address underlying) external view returns (uint32);

    function enterMarket(uint256 subAccountId, address newMarket) external;

    function underlyingToAssetConfig(address underlying) external view returns (AssetConfig memory);
}

// 
pragma solidity 0.8.10;

interface IEulerGeneralView {
    function computeAPYs(uint borrowSPY, uint totalBorrows, uint totalBalancesUnderlying, uint32 reserveFee) external pure returns (uint borrowAPY, uint supplyAPY);
    function computeSPY(address eulerContract, address underlying, uint totalBorrows, uint totalBalancesUnderlying) external view returns (uint borrowSPY);
}

// 

pragma solidity ^0.8.0;

// Original contract can be found under the following link:
// https://github.com/Synthetixio/synthetix/blob/master/contracts/interfaces/IStakingRewards.sol
interface IStakingRewards {
    // Views

    function balanceOf(address account) external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function getRewardForDuration() external view returns (uint256);

    function lastTimeRewardApplicable() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);
    function rewardRate() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    // Mutative

    function exit() external;
    function exit(uint subAccountId) external;

    function getReward() external;

    function stake(uint256 amount) external;
    function stake(uint subAccountId, uint256 amount) external;

    function withdraw(uint256 amount) external;
    function withdraw(uint subAccountId, uint256 amount) external;
}

// 
pragma solidity >=0.5.0;










/// to the ERC20 specification

interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}

// 
pragma solidity >=0.5.0;



interface IUniswapV3Factory {
    
    
    
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    
    
    
    
    
    
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    
    
    
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    
    
    
    function owner() external view returns (address);

    
    
    
    
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    
    
    
    
    
    
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    
    
    
    
    
    /// from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
    /// are invalid.
    
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    
    
    
    function setOwner(address _owner) external;

    
    
    
    
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}

// 
pragma solidity >=0.4.0;




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
        // uint256 twos = -denominator & denominator;
        // check here https://ethereum.stackexchange.com/questions/96642/unary-operator-minus-cannot-be-applied-to-type-uint256
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

// 
pragma solidity 0.8.10;



interface IERC20Detailed is IERC20Upgradeable {
  function name() external view returns(string memory);
  function symbol() external view returns(string memory);
  function decimals() external view returns(uint256);
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