// SPDX-License-Identifier: MIT


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







/// demo source: https://github.com/0xProject/0x-api-starter-guide-code/blob/master/contracts/SimpleTokenSwap.sol
contract ZeroExSwap is Ownable {
    using RevertBytes for bytes;

    
    
    
    
    struct SwapInput0x {
        address sellToken;
        address allowanceTarget;
        bytes swapCallData;
    }

    
    /// See https://docs.0x.org/developer-resources/contract-addresses
    /// The `to` field from the API response, but at the same time,
    /// TODO: maybe unit test that will check, if it does not changed?
    // solhint-disable-next-line var-name-mixedcase
    address public immutable EXCHANGE_PROXY;

    event BoughtTokens(address sellToken, address buyToken, uint256 boughtAmount);

    error AddressZero();
    error TargetNotExchangeProxy();
    error ApprovalFailed();

    constructor(address _exchangeProxy) {
        if (_exchangeProxy == address(0)) revert AddressZero();

        EXCHANGE_PROXY = _exchangeProxy;
    }

    
    /// Must attach ETH equal to the `value` field from the API response.
    
    
    
    function fillQuote(address _sellToken, address _spender, bytes memory _swapCallData) public {
        IERC20(_sellToken).approve(_spender, type(uint256).max);

        // Call the encoded swap function call on the contract at `swapTarget`
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory data) = EXCHANGE_PROXY.call(_swapCallData);
        if (!success) data.revertBytes("SWAP_CALL_FAILED");

        IERC20(_sellToken).approve(_spender, 0);
    }
}

// 
pragma solidity >=0.7.6 <0.9.0;








/// like Chainlink to calculate TWAP prices for assets. Each price provider should support a single price source
/// and multiple assets.
abstract contract PriceProvider is IPriceProvider {
    
    IPriceProvidersRepository public immutable priceProvidersRepository;

    
    address public immutable override quoteToken;

    modifier onlyManager() {
        if (priceProvidersRepository.manager() != msg.sender) revert("OnlyManager");
        _;
    }

    
    constructor(IPriceProvidersRepository _priceProvidersRepository) {
        if (
            !Ping.pong(_priceProvidersRepository.priceProvidersRepositoryPing)            
        ) {
            revert("InvalidPriceProviderRepository");
        }

        priceProvidersRepository = _priceProvidersRepository;
        quoteToken = _priceProvidersRepository.quoteToken();
    }

    
    function priceProviderPing() external pure override returns (bytes4) {
        return this.priceProviderPing.selector;
    }

    function _revertBytes(bytes memory _errMsg, string memory _customErr) internal pure {
        if (_errMsg.length > 0) {
            assembly { // solhint-disable-line no-inline-assembly
                revert(add(32, _errMsg), mload(_errMsg))
            }
        }

        revert(_customErr);
    }
}
// 
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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
pragma solidity >=0.7.6 <0.9.0;

interface ISwapper {
    
    
    function swapAmountIn(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        address _priceProvider,
        address _siloAsset
    ) external returns (uint256 amountOut);

    
    
    function swapAmountOut(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountOut,
        address _priceProvider,
        address _siloAsset
    ) external returns (uint256 amountIn);

    
    function spenderToApprove() external view returns (address);
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



interface IWrappedNativeToken is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
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
pragma solidity >=0.7.6 <=0.9.0;

library RevertBytes {
    function revertBytes(bytes memory _errMsg, string memory _customErr) internal pure {
        if (_errMsg.length > 0) {
            assembly { // solhint-disable-line no-inline-assembly
                revert(add(32, _errMsg), mload(_errMsg))
            }
        }

        revert(_customErr);
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





















/// see https://github.com/silo-finance/liquidation#readme for details how liquidation process should look like
contract LiquidationHelper is IFlashLiquidationReceiver, ZeroExSwap {
    using RevertBytes for bytes;
    using SafeERC20 for IERC20;
    using Address for address payable;

    struct MagicianConfig {
        address asset;
        IMagician magician;
    }

    struct SwapperConfig {
        IPriceProvider provider;
        ISwapper swapper;
    }

    
    /// - Internal: fully on-chain, using internal swappers, magicians etc
    ///   When 0x API can not handle the swap, we will use internal.
    /// - Full0x: 0x will handle swap for collateral -> repay asset, then contract needs to do repay.
    ///   Change that left after repay will be swapped to WETH using internal methods.
    ///   This scenario is for A -> B or A, B -> C cases.
    /// - Full0xWithChange: similar to Full0x, but all repay tokens that left, will be send to liquidator.
    ///   BE bot needs to do another tx to swap change to ETH
    ///   This scenario is for A -> B or A, B -> C cases
    ///   Exception: WETH -> A, it should be full or internal
    ///   Helper is supporting all the tokens internally, so only case, when we would need Full0xWithChange is when
    ///   we didn't develop swapper/magician for some new asset yet. Call `liquidationSupported` to check it.
    /// - Collateral0x: 0x will swap collateral to native token, then from native -> repay asset contract handle it
    ///   This is for A -> XAI, WETH, other cases of multiple repay tokens are not supported by 0x
    enum LiquidationScenario { Internal, Collateral0x, Full0x, Full0xWithChange }

    uint256 immutable private _BASE_TX_COST; // solhint-disable-line var-name-mixedcase
    ISiloRepository public immutable SILO_REPOSITORY; // solhint-disable-line var-name-mixedcase
    IPriceProvidersRepository public immutable PRICE_PROVIDERS_REPOSITORY; // solhint-disable-line var-name-mixedcase
    SiloLens public immutable LENS; // solhint-disable-line var-name-mixedcase
    IERC20 public immutable QUOTE_TOKEN; // solhint-disable-line var-name-mixedcase

    ChainlinkV3PriceProvider public immutable CHAINLINK_PRICE_PROVIDER; // solhint-disable-line var-name-mixedcase

    mapping(IPriceProvider => ISwapper) public swappers;
    // asset => magician
    mapping(address => IMagician) public magicians;

    error InvalidSiloLens();
    error InvalidSiloRepository();
    error LiquidationNotProfitable(uint256 inTheRed);
    error NotSilo();
    error PriceProviderNotFound();
    error FallbackPriceProviderNotSet();
    error SwapperNotFound();
    error MagicianNotFound();
    error RepayFailed();
    error SwapAmountInFailed();
    error SwapAmountOutFailed();
    error UsersMustMatchSilos();
    error InvalidChainlinkProviders();
    error InvalidMagicianConfig();
    error InvalidSwapperConfig();
    error InvalidTowardsAssetConvertion();
    error InvalidScenario();
    error Max0xSwapsIs2();

    event SwapperConfigured(IPriceProvider provider, ISwapper swapper);
    event MagicianConfigured(address asset, IMagician magician);
    
    
    
    
    
    
    /// because tokens were not sold for ETH inside transaction
    event LiquidationExecuted(address indexed silo, address indexed user, uint256 earned, bool estimatedEarnings);

    constructor (
        address _repository,
        address _chainlinkPriceProvider,
        address _lens,
        address _exchangeProxy,
        MagicianConfig[] memory _magicians,
        SwapperConfig[] memory _swappers,
        uint256 _baseCost
    ) ZeroExSwap(_exchangeProxy) {
        if (!Ping.pong(SiloLens(_lens).lensPing)) revert InvalidSiloLens();

        if (!Ping.pong(ISiloRepository(_repository).siloRepositoryPing)) {
            revert InvalidSiloRepository();
        }

        SILO_REPOSITORY = ISiloRepository(_repository);
        LENS = SiloLens(_lens);

        // configure swappers
        _configureSwappers(_swappers);
        // configure magicians
        _configureMagicians(_magicians);

        PRICE_PROVIDERS_REPOSITORY = ISiloRepository(_repository).priceProvidersRepository();

        CHAINLINK_PRICE_PROVIDER = ChainlinkV3PriceProvider(_chainlinkPriceProvider);

        QUOTE_TOKEN = IERC20(PRICE_PROVIDERS_REPOSITORY.quoteToken());
        _BASE_TX_COST = _baseCost;
    }

    receive() external payable {}

    function executeLiquidation(
        address _user,
        ISilo _silo,
        LiquidationScenario _scenario,
        SwapInput0x[] calldata _swapsInputs0x
    ) external {
        if (_swapsInputs0x.length > 2) revert Max0xSwapsIs2();

        uint256 gasStart = gasleft();
        address[] memory users = new address[](1);
        users[0] = _user;

        _silo.flashLiquidate(users, abi.encode(msg.sender, gasStart, _scenario, _swapsInputs0x));
    }

    function setSwappers(SwapperConfig[] calldata _swappers) external onlyOwner {
        _configureSwappers(_swappers);
    }

    function setMagicians(MagicianConfig[] calldata _magicians) external onlyOwner {
        _configureMagicians(_magicians);
    }

    
    /// Keep in mind, that this helper might NOT choose the best swap option.
    /// For best results (highest earnings) you probably want to implement your own callback and maybe use some
    /// dex aggregators.
    
    function siloLiquidationCallback(
        address _user,
        address[] calldata _assets,
        uint256[] calldata _receivedCollaterals,
        uint256[] calldata _shareAmountsToRepaid,
        bytes calldata _flashReceiverData
    ) external override {
        if (!SILO_REPOSITORY.isSilo(msg.sender)) revert NotSilo();

        (
            address payable executor,
            uint256 gasStart,
            LiquidationScenario scenario,
            SwapInput0x[] memory swapInputs
        ) = abi.decode(_flashReceiverData, (address, uint256, LiquidationScenario, SwapInput0x[]));

        if (swapInputs.length != 0) {
            _execute0x(swapInputs);
        }

        uint256 earned = _siloLiquidationCallbackExecution(
            scenario,
            _user,
            _assets,
            _receivedCollaterals,
            _shareAmountsToRepaid
        );

        // I needed to move some part of execution from from `_siloLiquidationCallbackExecution`,
        // because of "stack too deep" error
        bool isFull0xWithChange = scenario == LiquidationScenario.Full0xWithChange;

        if (isFull0xWithChange) {
            earned = _estimateEarningsAndTransferChange(_assets, _shareAmountsToRepaid, executor);
        } else {
            _transferNative(executor, earned);
        }

        emit LiquidationExecuted(msg.sender, _user, earned, isFull0xWithChange);
        ensureTxIsProfitable(gasStart, earned);
    }

    
    
    function liquidationSupported(address _asset) external view returns (bool) {
        if (_asset == address(QUOTE_TOKEN)) return true;
        if (address(magicians[_asset]) != address(0)) return true;

        try this.findPriceProvider(_asset) returns (IPriceProvider) {
            return true;
        } catch (bytes memory) {
            // we do not care about reason
        }

        return false;
    }

    function checkSolvency(address[] calldata _users, ISilo[] calldata _silos) external view returns (bool[] memory) {
        if (_users.length != _silos.length) revert UsersMustMatchSilos();

        bool[] memory solvency = new bool[](_users.length);

        for (uint256 i; i < _users.length;) {
            solvency[i] = _silos[i].isSolvent(_users[i]);
            // we will never have that many users to overflow
            unchecked { i++; }
        }

        return solvency;
    }

    function checkDebt(address[] calldata _users, ISilo[] calldata _silos) external view returns (bool[] memory) {
        bool[] memory hasDebt = new bool[](_users.length);

        for (uint256 i; i < _users.length;) {
            hasDebt[i] = LENS.inDebt(_silos[i], _users[i]);
            // we will never have that many users to overflow
            unchecked { i++; }
        }

        return hasDebt;
    }

    function ensureTxIsProfitable(uint256 _gasStart, uint256 _earnedEth) public view returns (uint256 txFee) {
        unchecked {
            // gas calculation will not overflow because values are never that high
            // `gasStart` is external value, but it value that we initiating and Silo contract passing it to us
            uint256 gasSpent = _gasStart - gasleft() + _BASE_TX_COST;
            txFee = tx.gasprice * gasSpent;

            if (txFee > _earnedEth) {
                // it will not underflow because we check above
                revert LiquidationNotProfitable(txFee - _earnedEth);
            }
        }
    }

    function findPriceProvider(address _asset) public view returns (IPriceProvider priceProvider) {
        priceProvider = PRICE_PROVIDERS_REPOSITORY.priceProviders(_asset);

        if (address(priceProvider) == address(0)) revert PriceProviderNotFound();

        if (priceProvider == CHAINLINK_PRICE_PROVIDER) {
            priceProvider = CHAINLINK_PRICE_PROVIDER.getFallbackProvider(_asset);
            if (address(priceProvider) == address(0)) revert FallbackPriceProviderNotSet();
        }
    }

    function _execute0x(SwapInput0x[] memory _swapInputs) internal {
        for (uint256 i; i < _swapInputs.length;) {
            fillQuote(_swapInputs[i].sellToken, _swapInputs[i].allowanceTarget, _swapInputs[i].swapCallData);
            // we can not have that much data in array to overflow
            unchecked { i++; }
        }
    }

    function _siloLiquidationCallbackExecution(
        LiquidationScenario _scenario,
        address _user,
        address[] calldata _assets,
        uint256[] calldata _receivedCollaterals,
        uint256[] calldata _shareAmountsToRepaid
    ) internal returns (uint256 earned) {
        if (_scenario == LiquidationScenario.Full0x) {
            earned = _runFull0xScenario(
                _user,
                _assets,
                _shareAmountsToRepaid
            );
        } else if (_scenario == LiquidationScenario.Full0xWithChange) {
            // we should have repay tokens ready to repay
            _repay(ISilo(msg.sender), _user, _assets, _shareAmountsToRepaid);
            // change that left after repay will be send to `_liquidator` by `_estimateEarningsAndTransferChange`
        } else if (_scenario == LiquidationScenario.Collateral0x) {
            earned = _runCollateral0xScenario(
                _user,
                _assets,
                _shareAmountsToRepaid
            );
        } else if (_scenario == LiquidationScenario.Internal) {
            earned = _runInternalScenario(
                _user,
                _assets,
                _receivedCollaterals,
                _shareAmountsToRepaid
            );
        } else revert InvalidScenario();
    }

    function _runFull0xScenario(
        address _user,
        address[] calldata _assets,
        uint256[] calldata _shareAmountsToRepaid
    ) internal returns (uint256 earned) {
        // we should have repay tokens ready to repay
        _repay(ISilo(msg.sender), _user, _assets, _shareAmountsToRepaid);

        // we left with some change, let's try to swap to WETH
        earned = _swapAssetsForQuote(_assets, _shareAmountsToRepaid);
    }

    function _runCollateral0xScenario(
        address _user,
        address[] calldata _assets,
        uint256[] calldata _shareAmountsToRepaid
    ) internal returns (uint256 earned) {
        // we have WETH, we need to deal with swap WETH -> repay asset internally
        _swapWrappedNativeForRepayAssets(_assets, _shareAmountsToRepaid);

        _repay(ISilo(msg.sender), _user, _assets, _shareAmountsToRepaid);

        earned = QUOTE_TOKEN.balanceOf(address(this));
    }

    function _runInternalScenario(
        address _user,
        address[] calldata _assets,
        uint256[] calldata _receivedCollaterals,
        uint256[] calldata _shareAmountsToRepaid
    ) internal returns (uint256 earned) {
        uint256 quoteAmountFromCollaterals = _swapAllForQuote(_assets, _receivedCollaterals);
        uint256 quoteSpentOnRepay = _swapWrappedNativeForRepayAssets(_assets, _shareAmountsToRepaid);

        _repay(ISilo(msg.sender), _user, _assets, _shareAmountsToRepaid);
        earned = quoteAmountFromCollaterals - quoteSpentOnRepay;
    }

    function _estimateEarningsAndTransferChange(
        address[] calldata _assets,
        uint256[] calldata _shareAmountsToRepaid,
        address payable _liquidator
    ) internal returns (uint256 earned) {
        // change that left after repay will be send to `_liquidator`
        for (uint256 i = 0; i < _assets.length;) {
            if (_shareAmountsToRepaid[i] != 0) {
                uint256 amount = IERC20(_assets[i]).balanceOf(address(this));

                if (_assets[i] == address(QUOTE_TOKEN)) {
                    // balance wil not overflow
                    unchecked { earned += amount; }
                    _transferNative(_liquidator, amount);
                } else {
                    // we processing numbers that Silo created, if Silo did not over/under flow, we will not as well
                    unchecked { earned += amount * PRICE_PROVIDERS_REPOSITORY.getPrice(_assets[i]); }
                    IERC20(_assets[i]).transfer(_liquidator, amount);
                }
            }

            // we will never have that many assets to overflow
            unchecked { i++; }
        }
    }

    function _swapAllForQuote(
        address[] calldata _assets,
        uint256[] calldata _receivedCollaterals
    ) internal returns (uint256 quoteAmount) {
        // swap all for quote token

        unchecked {
            // we will not overflow with `i` in a lifetime
            for (uint256 i = 0; i < _assets.length; i++) {
                // if silo was able to handle solvency calculations, then we can handle quoteAmount without safe math
                quoteAmount += _swapForQuote(_assets[i], _receivedCollaterals[i]);
            }
        }
    }

    function _swapWrappedNativeForRepayAssets(
        address[] calldata _assets,
        uint256[] calldata _shareAmountsToRepaid
    ) internal returns (uint256 quoteSpendOnRepay) {
        for (uint256 i = 0; i < _assets.length;) {
            if (_shareAmountsToRepaid[i] != 0) {
                // if silo was able to handle solvency calculations, then we can handle amounts without safe math here
                unchecked {
                    quoteSpendOnRepay += _swapForAsset(_assets[i], _shareAmountsToRepaid[i]);
                }
            }

            // we will never have that many assets to overflow
            unchecked { i++; }
        }
    }

    function _repay(
        ISilo _silo,
        address _user,
        address[] calldata _assets,
        uint256[] calldata _shareAmountsToRepaid
    ) internal {
        for (uint256 i = 0; i < _assets.length;) {
            if (_shareAmountsToRepaid[i] != 0) {
                _repayAsset(_silo, _user, _assets[i], _shareAmountsToRepaid[i]);
            }

            // we will never have that many assets to overflow
            unchecked { i++; }
        }
    }

    function _repayAsset(
        ISilo _silo,
        address _user,
        address _asset,
        uint256 _shareAmountToRepaid
    ) internal {
        // Low level call needed to support non-standard `ERC20.approve` eg like `USDT.approve`
        // solhint-disable-next-line avoid-low-level-calls
        _asset.call(abi.encodeCall(IERC20.approve, (address(_silo), _shareAmountToRepaid)));
        _silo.repayFor(_asset, _user, _shareAmountToRepaid);

        // DEFLATIONARY TOKENS ARE NOT SUPPORTED
        // we are not using lower limits for swaps so we may not get enough tokens to do full repay
        // our assumption here is that `_shareAmountsToRepaid[i]` is total amount to repay the full debt
        // if after repay user has no debt in this asset, the swap is acceptable
        if (_silo.assetStorage(_asset).debtToken.balanceOf(_user) != 0) {
            revert RepayFailed();
        }
    }

    
    function _transferNative(address payable _to, uint256 _amount) internal {
        IWrappedNativeToken(address(QUOTE_TOKEN)).withdraw(_amount);
        _to.sendValue(_amount);
    }

    function _swapAssetsForQuote(
        address[] calldata _assets,
        uint256[] calldata _amounts
    ) internal returns (uint256 received) {
        for (uint256 i = 0; i < _assets.length;) {
            if (_amounts[i] != 0) {
                uint256 amount = IERC20(_assets[i]).balanceOf(address(this));
                received += _swapForQuote(_assets[i], amount);
            }

            // we will never have that many assets to overflow
            unchecked { i++; }
        }
    }
    
    
    
    
    
    function _swapForQuote(address _asset, uint256 _amount) internal returns (uint256) {
        address quoteToken = address(QUOTE_TOKEN);

        if (_amount == 0 || _asset == quoteToken) return _amount;

        address magician = address(magicians[_asset]);

        if (magician != address(0)) {
            bytes memory result = _safeDelegateCall(
                magician,
                abi.encodeCall(IMagician.towardsNative, (_asset, _amount)),
                "towardsNativeFailed"
            );

            (address tokenOut, uint256 amountOut) = abi.decode(result, (address, uint256));

            return _swapForQuote(tokenOut, amountOut);
        }

        (IPriceProvider provider, ISwapper swapper) = _resolveProviderAndSwapper(_asset);

        // no need for safe approval, because we always using 100%
        // Low level call needed to support non-standard `ERC20.approve` eg like `USDT.approve`
        // solhint-disable-next-line avoid-low-level-calls
        _asset.call(abi.encodeCall(IERC20.approve, (swapper.spenderToApprove(), _amount)));

        bytes memory callData = abi.encodeCall(ISwapper.swapAmountIn, (
            _asset, quoteToken, _amount, address(provider), _asset
        ));

        bytes memory data = _safeDelegateCall(address(swapper), callData, "swapAmountIn");

        return abi.decode(data, (uint256));
    }

    
    
    
    
    function _swapForAsset(address _asset, uint256 _amount) internal returns (uint256) {
        address quoteToken = address(QUOTE_TOKEN);

        if (_amount == 0 || quoteToken == _asset) return _amount;

        address magician = address(magicians[_asset]);

        if (magician != address(0)) {
            bytes memory result = _safeDelegateCall(
                magician,
                abi.encodeCall(IMagician.towardsAsset, (_asset, _amount)),
                "towardsAssetFailed"
            );

            (address tokenOut, uint256 amountOut) = abi.decode(result, (address, uint256));

            // towardsAsset should convert to `_asset`
            if (tokenOut != _asset) revert InvalidTowardsAssetConvertion();

            return amountOut;
        }

        (IPriceProvider provider, ISwapper swapper) = _resolveProviderAndSwapper(_asset);

        address spender = swapper.spenderToApprove();

        IERC20(quoteToken).approve(spender, type(uint256).max);

        bytes memory callData = abi.encodeCall(ISwapper.swapAmountOut, (
            quoteToken, _asset, _amount, address(provider), _asset
        ));

        bytes memory data = _safeDelegateCall(address(swapper), callData, "SwapAmountOutFailed");

        IERC20(quoteToken).approve(spender, 0);

        return abi.decode(data, (uint256));
    }

    function _resolveProviderAndSwapper(address _asset) internal view returns (IPriceProvider, ISwapper) {
        IPriceProvider priceProvider = findPriceProvider(_asset);

        ISwapper swapper = _resolveSwapper(priceProvider);

        return (priceProvider, swapper);
    }

    function _resolveSwapper(IPriceProvider priceProvider) internal view returns (ISwapper) {
        ISwapper swapper = swappers[priceProvider];

        if (address(swapper) == address(0)) {
            revert SwapperNotFound();
        }

        return swapper;
    }

    function _safeDelegateCall(
        address _target,
        bytes memory _callData,
        string memory _mgs
    )
        internal
        returns (bytes memory data)
    {
        bool success;
        // solhint-disable-next-line avoid-low-level-calls
        (success, data) = address(_target).delegatecall(_callData);
        if (!success || data.length == 0) data.revertBytes(_mgs);
    }

    function _configureSwappers(SwapperConfig[] memory _swappers) internal {
        for (uint256 i = 0; i < _swappers.length; i++) {
            IPriceProvider provider = _swappers[i].provider;
            ISwapper swapper = _swappers[i].swapper;

            if (address(provider) == address(0) || address(swapper) == address(0)) {
                revert InvalidSwapperConfig();
            }

            swappers[provider] = swapper;

            emit SwapperConfigured(provider, swapper);
        }
    }

    function _configureMagicians(MagicianConfig[] memory _magicians) internal {
        for (uint256 i = 0; i < _magicians.length; i++) {
            address asset = _magicians[i].asset;
            IMagician magician = _magicians[i].magician;

            if (asset == address(0) || address(magician) == address(0)) {
                revert InvalidMagicianConfig();
            }

            magicians[asset] = magician;

            emit MagicianConfigured(asset, magician);
        }
    }
}

// 
pragma solidity >=0.7.6 <0.9.0;


interface IMagician {
    
    
    
    
    
    function towardsNative(address _asset, uint256 _amount) external returns (address tokenOut, uint256 amountOut);

    
    
    
    
    
    function towardsAsset(address _asset, uint256 _amount) external returns (address tokenOut, uint256 amountOut);
}

// 
pragma solidity 0.8.13;







contract ChainlinkV3PriceProvider is PriceProvider {
    using SafeMath for uint256;

    struct AssetData {
        // Time threshold to invalidate stale prices
        uint256 heartbeat;
        // If true, we bypass the aggregator and consult the fallback provider directly
        bool forceFallback;
        // If true, the aggregator returns price in USD, so we need to convert to QUOTE
        bool convertToQuote;
        // Chainlink aggregator proxy
        AggregatorV3Interface aggregator;
        // Provider used if the aggregator's price is invalid or if it became disabled
        IPriceProvider fallbackProvider;
    }

    
    AggregatorV3Interface internal immutable _QUOTE_AGGREGATOR; // solhint-disable-line var-name-mixedcase

    
    uint8 internal immutable _QUOTE_AGGREGATOR_DECIMALS; // solhint-disable-line var-name-mixedcase

    
    // solhint-disable-next-line var-name-mixedcase
    uint256 internal immutable _MAX_PRICE_DIFF = type(uint256).max / (100 * EMERGENCY_PRECISION);
    
    // @dev Precision to use for the EMERGENCY_THRESHOLD
    uint256 public constant EMERGENCY_PRECISION = 1e6;

    
    uint256 public constant EMERGENCY_THRESHOLD = 10 * EMERGENCY_PRECISION; // solhint-disable-line var-name-mixedcase

    
    uint8 internal immutable _QUOTE_TOKEN_DECIMALS; // solhint-disable-line var-name-mixedcase

    
    address public emergencyManager;

    
    uint256 public quoteAggregatorHeartbeat;

    
    mapping(address => AssetData) public assetData;

    event NewAggregator(address indexed asset, AggregatorV3Interface indexed aggregator, bool convertToQuote);
    event NewFallbackPriceProvider(address indexed asset, IPriceProvider indexed fallbackProvider);
    event NewHeartbeat(address indexed asset, uint256 heartbeat);
    event NewQuoteAggregatorHeartbeat(uint256 heartbeat);
    event NewEmergencyManager(address indexed emergencyManager);
    event AggregatorDisabled(address indexed asset, AggregatorV3Interface indexed aggregator);

    error AggregatorDidNotChange();
    error AggregatorPriceNotAvailable();
    error AssetNotSupported();
    error EmergencyManagerDidNotChange();
    error EmergencyThresholdNotReached();
    error FallbackProviderAlreadySet();
    error FallbackProviderDidNotChange();
    error FallbackProviderNotSet();
    error HeartbeatDidNotChange();
    error InvalidAggregator();
    error InvalidAggregatorDecimals();
    error InvalidFallbackPriceProvider();
    error InvalidHeartbeat();
    error OnlyEmergencyManager();
    error QuoteAggregatorHeartbeatDidNotChange();

    modifier onlyAssetSupported(address _asset) {
        if (!assetSupported(_asset)) {
            revert AssetNotSupported();
        }

        _;
    }

    constructor(
        IPriceProvidersRepository _priceProvidersRepository,
        address _emergencyManager,
        AggregatorV3Interface _quoteAggregator,
        uint256 _quoteAggregatorHeartbeat
    ) PriceProvider(_priceProvidersRepository) {
        _setEmergencyManager(_emergencyManager);
        _QUOTE_TOKEN_DECIMALS = IERC20LikeV2(quoteToken).decimals();
        _QUOTE_AGGREGATOR = _quoteAggregator;
        _QUOTE_AGGREGATOR_DECIMALS = _quoteAggregator.decimals();
        quoteAggregatorHeartbeat = _quoteAggregatorHeartbeat;
    }

    
    function assetSupported(address _asset) public view virtual override returns (bool) {
        AssetData storage data = assetData[_asset];

        // Asset is supported if:
        //     - the asset is the quote token
        //       OR
        //     - the aggregator address is defined AND
        //         - the aggregator is not disabled
        //           OR
        //         - the fallback is defined

        if (_asset == quoteToken) {
            return true;
        }

        if (address(data.aggregator) != address(0)) {
            return !data.forceFallback || address(data.fallbackProvider) != address(0);
        }

        return false;
    }

    
    
    function getAggregatorPrice(address _asset) public view virtual returns (bool success, uint256 price) {
        (success, price) = _getAggregatorPrice(_asset);
    }
    
    
    function getPrice(address _asset) public view virtual override returns (uint256) {
        address quote = quoteToken;

        if (_asset == quote) {
            return 10 ** _QUOTE_TOKEN_DECIMALS;
        }

        (bool success, uint256 price) = _getAggregatorPrice(_asset);

        return success ? price : _getFallbackPrice(_asset);
    }

    
    
    
    
    
    function setupAsset(
        address _asset,
        AggregatorV3Interface _aggregator,
        IPriceProvider _fallbackProvider,
        uint256 _heartbeat,
        bool _convertToQuote
    ) external virtual onlyManager {
        // This has to be done first so that `_setAggregator` works
        _setHeartbeat(_asset, _heartbeat);

        if (!_setAggregator(_asset, _aggregator, _convertToQuote)) revert AggregatorDidNotChange();

        // We don't care if this doesn't change
        _setFallbackPriceProvider(_asset, _fallbackProvider);
    }

    
    
    
    function setAggregator(address _asset, AggregatorV3Interface _aggregator, bool _convertToQuote)
        external
        virtual
        onlyManager
        onlyAssetSupported(_asset)
    {
        if (!_setAggregator(_asset, _aggregator, _convertToQuote)) revert AggregatorDidNotChange();
    }

    
    
    
    function setFallbackPriceProvider(address _asset, IPriceProvider _fallbackProvider)
        external
        virtual
        onlyManager
        onlyAssetSupported(_asset)
    {
        if (!_setFallbackPriceProvider(_asset, _fallbackProvider)) {
            revert FallbackProviderDidNotChange();
        }
    }

    
    
    
    function setHeartbeat(address _asset, uint256 _heartbeat)
        external
        virtual
        onlyManager
        onlyAssetSupported(_asset)
    {
        if (!_setHeartbeat(_asset, _heartbeat)) revert HeartbeatDidNotChange();
    }

    
    
    function setQuoteAggregatorHeartbeat(uint256 _heartbeat)
        external
        virtual
        onlyManager
    {
        if (!_setQuoteAggregatorHeartbeat(_heartbeat)) revert QuoteAggregatorHeartbeatDidNotChange();
    }

    
    
    function setEmergencyManager(address _emergencyManager) external virtual onlyManager {
        if (!_setEmergencyManager(_emergencyManager)) revert EmergencyManagerDidNotChange();
    }

    
    /// fallback provider. The only way to reenable the asset is by calling setupAsset or setAggregator again.
    /// Can only be called by the emergencyManager.
    
    function emergencyDisable(address _asset) external virtual {
        if (msg.sender != emergencyManager) {
            revert OnlyEmergencyManager();
        }

        (bool success, uint256 price) = _getAggregatorPrice(_asset);

        if (!success) {
            revert AggregatorPriceNotAvailable();
        }

        uint256 fallbackPrice = _getFallbackPrice(_asset);

        uint256 diff;

        unchecked {
            // It is ok to uncheck because of the initial fallbackPrice >= price check
            diff = fallbackPrice >= price ? fallbackPrice - price : price - fallbackPrice;
        }

        if (diff > _MAX_PRICE_DIFF || (diff * 100 * EMERGENCY_PRECISION) / price < EMERGENCY_THRESHOLD) {
            revert EmergencyThresholdNotReached();
        }

        // Disable main aggregator, fallback stays enabled
        assetData[_asset].forceFallback = true;

        emit AggregatorDisabled(_asset, assetData[_asset].aggregator);
    }

    function getFallbackProvider(address _asset) external view virtual returns (IPriceProvider) {
        return assetData[_asset].fallbackProvider;
    }

    function _getAggregatorPrice(address _asset) internal view virtual returns (bool success, uint256 price) {
        AssetData storage data = assetData[_asset];

        uint256 heartbeat = data.heartbeat;
        bool forceFallback = data.forceFallback;
        AggregatorV3Interface aggregator = data.aggregator;

        if (address(aggregator) == address(0)) revert AssetNotSupported();

        (
            /*uint80 roundID*/,
            int256 aggregatorPrice,
            /*uint256 startedAt*/,
            uint256 timestamp,
            /*uint80 answeredInRound*/
        ) = aggregator.latestRoundData();

        // If a valid price is returned and it was updated recently
        if (!forceFallback && _isValidPrice(aggregatorPrice, timestamp, heartbeat)) {
            uint256 result;

            if (data.convertToQuote) {
                // _toQuote performs decimal normalization internally
                result = _toQuote(uint256(aggregatorPrice));
            } else {
                uint8 aggregatorDecimals = aggregator.decimals();
                result = _normalizeWithDecimals(uint256(aggregatorPrice), aggregatorDecimals);
            }

            return (true, result);
        }

        return (false, 0);
    }

    function _getFallbackPrice(address _asset) internal view virtual returns (uint256) {
        IPriceProvider fallbackProvider = assetData[_asset].fallbackProvider;

        if (address(fallbackProvider) == address(0)) revert FallbackProviderNotSet();

        return fallbackProvider.getPrice(_asset);
    }

    function _setEmergencyManager(address _emergencyManager) internal virtual returns (bool changed) {
        if (_emergencyManager == emergencyManager) {
            return false;
        }

        emergencyManager = _emergencyManager;

        emit NewEmergencyManager(_emergencyManager);

        return true;
    }

    function _setAggregator(
        address _asset,
        AggregatorV3Interface _aggregator,
        bool _convertToQuote
    ) internal virtual returns (bool changed) {
        if (address(_aggregator) == address(0)) revert InvalidAggregator();

        AssetData storage data = assetData[_asset];

        if (data.aggregator == _aggregator && data.forceFallback == false) {
            return false;
        }

        // There doesn't seem to be a way to verify if this is a "valid" aggregator (other than getting the price)
        data.forceFallback = false;
        data.aggregator = _aggregator;

        (bool success,) = _getAggregatorPrice(_asset);

        if (!success) revert AggregatorPriceNotAvailable();

        if (_convertToQuote && _aggregator.decimals() != _QUOTE_AGGREGATOR_DECIMALS) {
            revert InvalidAggregatorDecimals();
        }

        // We want to always update this
        assetData[_asset].convertToQuote = _convertToQuote;

        emit NewAggregator(_asset, _aggregator, _convertToQuote);

        return true;
    }

    function _setFallbackPriceProvider(address _asset, IPriceProvider _fallbackProvider)
        internal
        virtual
        returns (bool changed)
    {
        if (_fallbackProvider == assetData[_asset].fallbackProvider) {
            return false;
        }

        assetData[_asset].fallbackProvider = _fallbackProvider;

        if (address(_fallbackProvider) != address(0)) {
            if (
                !priceProvidersRepository.isPriceProvider(_fallbackProvider) ||
                !_fallbackProvider.assetSupported(_asset) ||
                _fallbackProvider.quoteToken() != quoteToken
            ) {
                revert InvalidFallbackPriceProvider();
            }

            // Make sure it doesn't revert
            _getFallbackPrice(_asset);
        }

        emit NewFallbackPriceProvider(_asset, _fallbackProvider);

        return true;
    }

    function _setHeartbeat(address _asset, uint256 _heartbeat) internal virtual returns (bool changed) {
        // Arbitrary limit, Chainlink's threshold is always less than a day
        if (_heartbeat > 2 days) revert InvalidHeartbeat();

        if (_heartbeat == assetData[_asset].heartbeat) {
            return false;
        }

        assetData[_asset].heartbeat = _heartbeat;

        emit NewHeartbeat(_asset, _heartbeat);

        return true;
    }

    function _setQuoteAggregatorHeartbeat(uint256 _heartbeat) internal virtual returns (bool changed) {
        // Arbitrary limit, Chainlink's threshold is always less than a day
        if (_heartbeat > 2 days) revert InvalidHeartbeat();

        if (_heartbeat == quoteAggregatorHeartbeat) {
            return false;
        }

        quoteAggregatorHeartbeat = _heartbeat;

        emit NewQuoteAggregatorHeartbeat(_heartbeat);

        return true;
    }

    
    
    
    function _normalizeWithDecimals(uint256 _price, uint8 _decimals) internal view virtual returns (uint256) {
        // We want to return the price of 1 asset token, but with the decimals of the quote token
        if (_QUOTE_TOKEN_DECIMALS == _decimals) {
            return _price;
        } else if (_QUOTE_TOKEN_DECIMALS < _decimals) {
            return _price / 10 ** (_decimals - _QUOTE_TOKEN_DECIMALS);
        } else {
            return _price * 10 ** (_QUOTE_TOKEN_DECIMALS - _decimals);
        }
    }

    
    function _toQuote(uint256 _price) internal view virtual returns (uint256) {
       (
            /*uint80 roundID*/,
            int256 aggregatorPrice,
            /*uint256 startedAt*/,
            uint256 timestamp,
            /*uint80 answeredInRound*/
        ) = _QUOTE_AGGREGATOR.latestRoundData();

        // If an invalid price is returned
        if (!_isValidPrice(aggregatorPrice, timestamp, quoteAggregatorHeartbeat)) {
            revert AggregatorPriceNotAvailable();
        }

        // _price and aggregatorPrice should both have the same decimals so we normalize here
        return _price * 10 ** _QUOTE_TOKEN_DECIMALS / uint256(aggregatorPrice);
    }

    function _isValidPrice(int256 _price, uint256 _timestamp, uint256 _heartbeat) internal view virtual returns (bool) {
        return _price > 0 && block.timestamp - _timestamp < _heartbeat;
    }
}

// 
pragma solidity >=0.7.6;


/// Solidity version than the rest of the codebase. This way de won't need to include
/// an additional version of OpenZeppelin's library.
interface IERC20LikeV2 {
    function decimals() external view returns (uint8);
    function balanceOf(address) external view returns(uint256);
}

// 
pragma solidity 0.8.13;










contract SiloLens {
    using EasyMath for uint256;

    ISiloRepository immutable public siloRepository;

    error InvalidRepository();

    constructor (ISiloRepository _siloRepo) {
        if (!Ping.pong(_siloRepo.siloRepositoryPing)) revert InvalidRepository();

        siloRepository = _siloRepo;
    }

    
    
    
    
    function liquidity(ISilo _silo, address _asset) external view returns (uint256) {
        return ERC20(_asset).balanceOf(address(_silo)) - _silo.assetStorage(_asset).collateralOnlyDeposits;
    }

    
    
    
    
    
    function totalDeposits(ISilo _silo, address _asset) external view returns (uint256) {
        return _silo.utilizationData(_asset).totalDeposits;
    }

    
    
    
    
    
    function collateralOnlyDeposits(ISilo _silo, address _asset) external view returns (uint256) {
        return _silo.assetStorage(_asset).collateralOnlyDeposits;
    }

    
    
    
    
    
    function totalBorrowAmount(ISilo _silo, address _asset) external view returns (uint256) {
        return _silo.assetStorage(_asset).totalBorrowAmount;
    }

    
    
    
    
    
    function protocolFees(ISilo _silo, address _asset) external view returns (uint256) {
        return _silo.interestData(_asset).protocolFees;
    }

    
    
    /// a sum of all deposits and all borrows denominated in quote token. Returns fraction between borrow value
    /// and deposit value with 18 decimals.
    
    
    
    function getUserLTV(ISilo _silo, address _user) external view returns (uint256 userLTV) {
        (address[] memory assets, ISilo.AssetStorage[] memory assetsStates) = _silo.getAssetsWithState();

        (userLTV, ) = Solvency.calculateLTVs(
            Solvency.SolvencyParams(
                siloRepository,
                _silo,
                assets,
                assetsStates,
                _user
            ),
            Solvency.TypeofLTV.MaximumLTV
        );
    }

    
    
    
    
    
    function totalBorrowShare(ISilo _silo, address _asset) external view returns (uint256) {
        return _silo.assetStorage(_asset).debtToken.totalSupply();
    }

    
    
    
    
    
    
    
    function getBorrowAmount(ISilo _silo, address _asset, address _user, uint256 _timestamp)
        external
        view
        returns (uint256)
    {
        return Solvency.getUserBorrowAmount(
            _silo.assetStorage(_asset),
            _user,
            Solvency.getRcomp(_silo, siloRepository, _asset, _timestamp)
        );
    }

    
    
    /// on that token.
    
    
    
    
    function borrowShare(ISilo _silo, address _asset, address _user) external view returns (uint256) {
        return _silo.assetStorage(_asset).debtToken.balanceOf(_user);
    }

    
    /// deposits
    
    
    
    
    
    function collateralBalanceOfUnderlying(ISilo _silo, address _asset, address _user) external view returns (uint256) {
        ISilo.AssetStorage memory _state = _silo.assetStorage(_asset);

        // Overflow shouldn't happen if the underlying token behaves correctly, as the total supply of underlying
        // tokens can't overflow by definition
        unchecked {
            return balanceOfUnderlying(_state.totalDeposits, _state.collateralToken, _user) +
                balanceOfUnderlying(_state.collateralOnlyDeposits, _state.collateralOnlyToken, _user);
        }
    }

    
    
    
    
    
    
    function debtBalanceOfUnderlying(ISilo _silo, address _asset, address _user) external view returns (uint256) {
        ISilo.AssetStorage memory _state = _silo.assetStorage(_asset);

        return balanceOfUnderlying(_state.totalBorrowAmount, _state.debtToken, _user);
    }

    
    
    
    
    
    
    function calculateCollateralValue(ISilo _silo, address _user, address _asset)
        external
        view
        returns (uint256)
    {
        IPriceProvidersRepository priceProviderRepo = siloRepository.priceProvidersRepository();
        ISilo.AssetStorage memory assetStorage = _silo.assetStorage(_asset);

        uint256 assetPrice = priceProviderRepo.getPrice(_asset);
        uint8 assetDecimals = ERC20(_asset).decimals();
        uint256 userCollateralTokenBalance = assetStorage.collateralToken.balanceOf(_user);
        uint256 userCollateralOnlyTokenBalance = assetStorage.collateralOnlyToken.balanceOf(_user);

        uint256 assetAmount = Solvency.getUserCollateralAmount(
            assetStorage,
            userCollateralTokenBalance,
            userCollateralOnlyTokenBalance,
            Solvency.getRcomp(_silo, siloRepository, _asset, block.timestamp),
            siloRepository
        );

        return assetAmount.toValue(assetPrice, assetDecimals);
    }

    
    
    
    
    
    
    function calculateBorrowValue(ISilo _silo, address _user, address _asset)
        external
        view
        returns (uint256)
    {
        IPriceProvidersRepository priceProviderRepo = siloRepository.priceProvidersRepository();
        uint256 assetPrice = priceProviderRepo.getPrice(_asset);
        uint256 assetDecimals = ERC20(_asset).decimals();

        uint256 rcomp = Solvency.getRcomp(_silo, siloRepository, _asset, block.timestamp);
        uint256 borrowAmount = Solvency.getUserBorrowAmount(_silo.assetStorage(_asset), _user, rcomp);

        return borrowAmount.toValue(assetPrice, assetDecimals);
    }

    
    
    /// assets (bridge assets + unique asset). Each of these assets may have different liquidation threshold.
    /// That means effective liquidation threshold must be calculated per asset based on current deposits and
    /// borrows of given account.
    
    
    
    function getUserLiquidationThreshold(ISilo _silo, address _user)
        external
        view
        returns (uint256 liquidationThreshold)
    {
        (address[] memory assets, ISilo.AssetStorage[] memory assetsStates) = _silo.getAssetsWithState();

        liquidationThreshold = Solvency.calculateLTVLimit(
            Solvency.SolvencyParams(
                siloRepository,
                _silo,
                assets,
                assetsStates,
                _user
            ),
            Solvency.TypeofLTV.LiquidationThreshold
        );
    }

    
    
    /// (bridge assets + unique asset). Each of these assets may have different maximum Loan-To-Value for
    /// opening borrow position. That means effective maximum LTV must be calculated per asset based on
    /// current deposits and borrows of given account.
    
    
    
    function getUserMaximumLTV(ISilo _silo, address _user) external view returns (uint256 maximumLTV) {
        (address[] memory assets, ISilo.AssetStorage[] memory assetsStates) = _silo.getAssetsWithState();

        maximumLTV = Solvency.calculateLTVLimit(
            Solvency.SolvencyParams(
                siloRepository,
                _silo,
                assets,
                assetsStates,
                _user
            ),
            Solvency.TypeofLTV.MaximumLTV
        );
    }

    
    
    
    
    function inDebt(ISilo _silo, address _user) external view returns (bool) {
        address[] memory allAssets = _silo.getAssets();

        for (uint256 i; i < allAssets.length;) {
            if (_silo.assetStorage(allAssets[i]).debtToken.balanceOf(_user) != 0) return true;

            unchecked {
                i++;
            }
        }

        return false;
    }

    
    
    
    
    function hasPosition(ISilo _silo, address _user) external view returns (bool) {
        (, ISilo.AssetStorage[] memory assetsStorage) = _silo.getAssetsWithState();

        for (uint256 i; i < assetsStorage.length; i++) {
            if (assetsStorage[i].debtToken.balanceOf(_user) != 0) return true;
            if (assetsStorage[i].collateralToken.balanceOf(_user) != 0) return true;
            if (assetsStorage[i].collateralOnlyToken.balanceOf(_user) != 0) return true;
        }

        return false;
    }

    
    /// denominated in percentage
    
    /// interest and ever-increasing total borrow amount. It assumes `Model.DP()` = 100%.
    
    
    
    function getUtilization(ISilo _silo, address _asset) external view returns (uint256) {
        ISilo.UtilizationData memory data = ISilo(_silo).utilizationData(_asset);

        return EasyMath.calculateUtilization(
            getModel(_silo, _asset).DP(),
            data.totalDeposits,
            data.totalBorrowAmount
        );
    }

    
    
    
    
    function depositAPY(ISilo _silo, address _asset) external view returns (uint256) {
        uint256 dp = getModel(_silo, _asset).DP();

        // amount of deposits in asset decimals
        uint256 totalDepositsAmount = totalDepositsWithInterest(_silo, _asset);

        if (totalDepositsAmount == 0) return 0;

        // amount of debt generated per year in asset decimals
        uint256 generatedDebtAmount = totalBorrowAmountWithInterest(_silo, _asset) * borrowAPY(_silo, _asset) / dp;

        return generatedDebtAmount * Solvency._PRECISION_DECIMALS / totalDepositsAmount;
    }

    
    
    
    function calcFee(uint256 _amount) external view returns (uint256) {
        uint256 entryFee = siloRepository.entryFee();
        if (entryFee == 0) return 0; // no fee

        unchecked {
            // If we overflow on multiplication it should not revert tx, we will get lower fees
            return _amount * entryFee / Solvency._PRECISION_DECIMALS;
        }
    }

    
    
    function lensPing() external pure returns (bytes4) {
        return this.lensPing.selector;
    }

    
    
    
    
    function borrowAPY(ISilo _silo, address _asset) public view returns (uint256) {
        return getModel(_silo, _asset).getCurrentInterestRate(address(_silo), _asset, block.timestamp);
    }

    
    
    
    function totalDepositsWithInterest(ISilo _silo, address _asset) public view returns (uint256 _totalDeposits) {
        uint256 rcomp = getModel(_silo, _asset).getCompoundInterestRate(address(_silo), _asset, block.timestamp);
        uint256 protocolShareFee = siloRepository.protocolShareFee();
        ISilo.UtilizationData memory data = _silo.utilizationData(_asset);

        return Solvency.totalDepositsWithInterest(data.totalDeposits, protocolShareFee, rcomp);
    }

    
    
    
    function totalBorrowAmountWithInterest(ISilo _silo, address _asset)
        public
        view
        returns (uint256 _totalBorrowAmount)
    {
        uint256 rcomp = Solvency.getRcomp(_silo, siloRepository, _asset, block.timestamp);
        ISilo.UtilizationData memory data = _silo.utilizationData(_asset);

        return Solvency.totalBorrowAmountWithInterest(data.totalBorrowAmount, rcomp);
    }

    
    
    /// debt or collateral in given Silo. This method converts that ownership to exact amount of underlying token.
    
    /// use `totalDeposits` to get this value. For debt token, use `totalBorrowAmount` to get this value.
    
    /// these addresses in:
    /// - `ISilo.AssetStorage.collateralToken`
    /// - `ISilo.AssetStorage.collateralOnlyToken`
    /// - `ISilo.AssetStorage.debtToken`
    
    
    function balanceOfUnderlying(uint256 _assetTotalDeposits, IShareToken _shareToken, address _user)
        public
        view
        returns (uint256)
    {
        uint256 share = _shareToken.balanceOf(_user);
        return share.toAmount(_assetTotalDeposits, _shareToken.totalSupply());
    }

    
    
    
    
    function getModel(ISilo _silo, address _asset) public view returns (IInterestRateModel) {
        return IInterestRateModel(siloRepository.getInterestRateModel(address(_silo), _asset));
    }
}