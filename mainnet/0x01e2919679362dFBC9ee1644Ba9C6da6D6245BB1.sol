// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;


// 

pragma solidity ^0.6.0;

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

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 

pragma solidity ^0.6.0;






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
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
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
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
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
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
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
}

// 

pragma solidity >=0.4.24 <0.7.0;


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
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

contract EnsResolve {
  function resolve(bytes32 node) public view virtual returns (address) {
    ENS Registry = ENS(
      getChainId() == 1 ? 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e : 0x8595bFb0D940DfEDC98943FA8a907091203f25EE
    );
    return Registry.resolver(node).addr(node);
  }

  function bulkResolve(bytes32[] memory domains) public view returns (address[] memory result) {
    result = new address[](domains.length);
    for (uint256 i = 0; i < domains.length; i++) {
      result[i] = resolve(domains[i]);
    }
  }

  function getChainId() internal pure returns (uint256) {
    uint256 chainId;
    assembly {
      chainId := chainid()
    }
    return chainId;
  }
}

// 

pragma solidity ^0.6.0;




/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}

// 

pragma solidity ^0.6.0;



/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// 

pragma solidity ^0.6.0;

// Adapted copy from https://github.com/OpenZeppelin/openzeppelin-contracts/pull/2237/files




/**
 * @dev Extension of {ERC20} that allows token holders to use their tokens
 * without sending any transactions by setting {IERC20-allowance} with a
 * signature using the {permit} method, and then spend them via
 * {IERC20-transferFrom}.
 *
 * The {permit} signature mechanism conforms to the {IERC2612Permit} interface.
 */
abstract contract ERC20Permit is ERC20 {
  mapping(address => uint256) private _nonces;

  bytes32 private constant _PERMIT_TYPEHASH = keccak256(
    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
  );

  // Mapping of ChainID to domain separators. This is a very gas efficient way
  // to not recalculate the domain separator on every call, while still
  // automatically detecting ChainID changes.
  mapping(uint256 => bytes32) private _domainSeparators;

  constructor() internal {
    _updateDomainSeparator();
  }

  /**
   * @dev See {IERC2612Permit-permit}.
   *
   * If https://eips.ethereum.org/EIPS/eip-1344[ChainID] ever changes, the
   * EIP712 Domain Separator is automatically recalculated.
   */
  function permit(
    address owner,
    address spender,
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public {
    require(blockTimestamp() <= deadline, "ERC20Permit: expired deadline");

    bytes32 hashStruct = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, amount, _nonces[owner], deadline));

    bytes32 hash = keccak256(abi.encodePacked(uint16(0x1901), _domainSeparator(), hashStruct));

    address signer = ECDSA.recover(hash, v, r, s);
    require(signer == owner, "ERC20Permit: invalid signature");

    _nonces[owner]++;
    _approve(owner, spender, amount);
  }

  /**
   * @dev See {IERC2612Permit-nonces}.
   */
  function nonces(address owner) public view returns (uint256) {
    return _nonces[owner];
  }

  function _updateDomainSeparator() private returns (bytes32) {
    uint256 _chainID = chainID();

    bytes32 newDomainSeparator = keccak256(
      abi.encode(
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
        keccak256(bytes(name())),
        keccak256(bytes("1")), // Version
        _chainID,
        address(this)
      )
    );

    _domainSeparators[_chainID] = newDomainSeparator;

    return newDomainSeparator;
  }

  // Returns the domain separator, updating it if chainID changes
  function _domainSeparator() private returns (bytes32) {
    bytes32 domainSeparator = _domainSeparators[chainID()];
    if (domainSeparator != 0x00) {
      return domainSeparator;
    } else {
      return _updateDomainSeparator();
    }
  }

  function chainID() public view virtual returns (uint256 _chainID) {
    assembly {
      _chainID := chainid()
    }
  }

  function blockTimestamp() public view virtual returns (uint256) {
    return block.timestamp;
  }
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
}// 

pragma solidity ^0.6.12;















struct RelayerState {
  uint256 balance;
  bytes32 ensHash;
}

/**
 * @notice Registry contract, one of the main contracts of this protocol upgrade.
 *         The contract should store relayers' addresses and data attributed to the
 *         master address of the relayer. This data includes the relayers stake and
 *         his ensHash.
 *         A relayers master address has a number of subaddresses called "workers",
 *         these are all addresses which burn stake in communication with the proxy.
 *         If a relayer is not registered, he is not displayed on the frontend.
 * @dev CONTRACT RISKS:
 *      - if setter functions are compromised, relayer metadata would be at risk, including the noted amount of his balance
 *      - if burn function is compromised, relayers run the risk of being unable to handle withdrawals
 *      - the above risk also applies to the nullify balance function
 * */
contract RelayerRegistry is Initializable, EnsResolve {
  using SafeMath for uint256;
  using SafeERC20 for TORN;
  using ENSNamehash for bytes;

  TORN public immutable torn;
  address public immutable governance;
  IENS public immutable ens;
  TornadoStakingRewards public immutable staking;
  FeeManager public immutable feeManager;

  address public tornadoRouter;
  uint256 public minStakeAmount;

  mapping(address => RelayerState) public relayers;
  mapping(address => address) public workers;

  event RelayerBalanceNullified(address relayer);
  event WorkerRegistered(address relayer, address worker);
  event WorkerUnregistered(address relayer, address worker);
  event StakeAddedToRelayer(address relayer, uint256 amountStakeAdded);
  event StakeBurned(address relayer, uint256 amountBurned);
  event MinimumStakeAmount(uint256 minStakeAmount);
  event RouterRegistered(address tornadoRouter);
  event RelayerRegistered(bytes32 relayer, string ensName, address relayerAddress, uint256 stakedAmount);

  modifier onlyGovernance() {
    require(msg.sender == governance, "only governance");
    _;
  }

  modifier onlyTornadoRouter() {
    require(msg.sender == tornadoRouter, "only proxy");
    _;
  }

  modifier onlyRelayer(address sender, address relayer) {
    require(workers[sender] == relayer, "only relayer");
    _;
  }

  constructor(
    address _torn,
    address _governance,
    address _ens,
    bytes32 _staking,
    bytes32 _feeManager
  ) public {
    torn = TORN(_torn);
    governance = _governance;
    ens = IENS(_ens);
    staking = TornadoStakingRewards(resolve(_staking));
    feeManager = FeeManager(resolve(_feeManager));
  }

  /**
   * @notice initialize function for upgradeability
   * @dev this contract will be deployed behind a proxy and should not assign values at logic address,
   *      params left out because self explainable
   * */
  function initialize(bytes32 _tornadoRouter) external initializer {
    tornadoRouter = resolve(_tornadoRouter);
  }

  /**
   * @notice This function should register a master address and optionally a set of workeres for a relayer + metadata
   * @dev Relayer can't steal other relayers workers since they are registered, and a wallet (msg.sender check) can always unregister itself
   * @param ensName ens name of the relayer
   * @param stake the initial amount of stake in TORN the relayer is depositing
   * */
  function register(
    string calldata ensName,
    uint256 stake,
    address[] calldata workersToRegister
  ) external {
    _register(msg.sender, ensName, stake, workersToRegister);
  }

  /**
   * @dev Register function equivalent with permit-approval instead of regular approve.
   * */
  function registerPermit(
    string calldata ensName,
    uint256 stake,
    address[] calldata workersToRegister,
    address relayer,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external {
    torn.permit(relayer, address(this), stake, deadline, v, r, s);
    _register(relayer, ensName, stake, workersToRegister);
  }

  function _register(
    address relayer,
    string calldata ensName,
    uint256 stake,
    address[] calldata workersToRegister
  ) internal {
    bytes32 ensHash = bytes(ensName).namehash();
    require(relayer == ens.owner(ensHash), "only ens owner");
    require(workers[relayer] == address(0), "cant register again");
    RelayerState storage metadata = relayers[relayer];

    require(metadata.ensHash == bytes32(0), "registered already");
    require(stake >= minStakeAmount, "!min_stake");

    torn.safeTransferFrom(relayer, address(staking), stake);
    emit StakeAddedToRelayer(relayer, stake);

    metadata.balance = stake;
    metadata.ensHash = ensHash;
    workers[relayer] = relayer;

    for (uint256 i = 0; i < workersToRegister.length; i++) {
      address worker = workersToRegister[i];
      _registerWorker(relayer, worker);
    }

    emit RelayerRegistered(ensHash, ensName, relayer, stake);
  }

  /**
   * @notice This function should allow relayers to register more workeres
   * @param relayer Relayer which should send message from any worker which is already registered
   * @param worker Address to register
   * */
  function registerWorker(address relayer, address worker) external onlyRelayer(msg.sender, relayer) {
    _registerWorker(relayer, worker);
  }

  function _registerWorker(address relayer, address worker) internal {
    require(workers[worker] == address(0), "can't steal an address");
    workers[worker] = relayer;
    emit WorkerRegistered(relayer, worker);
  }

  /**
   * @notice This function should allow anybody to unregister an address they own
   * @dev designed this way as to allow someone to unregister themselves in case a relayer misbehaves
   *      - this should be followed by an action like burning relayer stake
   *      - there was an option of allowing the sender to burn relayer stake in case of malicious behaviour, this feature was not included in the end
   *      - reverts if trying to unregister master, otherwise contract would break. in general, there should be no reason to unregister master at all
   * */
  function unregisterWorker(address worker) external {
    if (worker != msg.sender) require(workers[worker] == msg.sender, "only owner of worker");
    require(workers[worker] != worker, "cant unregister master");
    emit WorkerUnregistered(workers[worker], worker);
    workers[worker] = address(0);
  }

  /**
   * @notice This function should allow anybody to stake to a relayer more TORN
   * @param relayer Relayer main address to stake to
   * @param stake Stake to be added to relayer
   * */
  function stakeToRelayer(address relayer, uint256 stake) external {
    _stakeToRelayer(msg.sender, relayer, stake);
  }

  /**
   * @dev stakeToRelayer function equivalent with permit-approval instead of regular approve.
   * @param staker address from that stake is paid
   * */
  function stakeToRelayerPermit(
    address relayer,
    uint256 stake,
    address staker,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external {
    torn.permit(staker, address(this), stake, deadline, v, r, s);
    _stakeToRelayer(staker, relayer, stake);
  }

  function _stakeToRelayer(
    address staker,
    address relayer,
    uint256 stake
  ) internal {
    require(workers[relayer] == relayer, "!registered");
    torn.safeTransferFrom(staker, address(staking), stake);
    relayers[relayer].balance = stake.add(relayers[relayer].balance);
    emit StakeAddedToRelayer(relayer, stake);
  }

  /**
   * @notice This function should burn some relayer stake on withdraw and notify staking of this
   * @dev IMPORTANT FUNCTION:
   *      - This should be only called by the tornado proxy
   *      - Should revert if relayer does not call proxy from valid worker
   *      - Should not overflow
   *      - Should underflow and revert (SafeMath) on not enough stake (balance)
   * @param sender worker to check sender == relayer
   * @param relayer address of relayer who's stake is being burned
   * @param pool instance to get fee for
   * */
  function burn(
    address sender,
    address relayer,
    ITornadoInstance pool
  ) external onlyTornadoRouter {
    address masterAddress = workers[sender];
    if (masterAddress == address(0)) {
      require(workers[relayer] == address(0), "Only custom relayer");
      return;
    }

    require(masterAddress == relayer, "only relayer");
    uint256 toBurn = feeManager.instanceFeeWithUpdate(pool);
    relayers[relayer].balance = relayers[relayer].balance.sub(toBurn);
    staking.addBurnRewards(toBurn);
    emit StakeBurned(relayer, toBurn);
  }

  /**
   * @notice This function should allow governance to set the minimum stake amount
   * @param minAmount new minimum stake amount
   * */
  function setMinStakeAmount(uint256 minAmount) external onlyGovernance {
    minStakeAmount = minAmount;
    emit MinimumStakeAmount(minAmount);
  }

  /**
   * @notice This function should allow governance to set a new tornado proxy address
   * @param tornadoRouterAddress address of the new proxy
   * */
  function setTornadoRouter(address tornadoRouterAddress) external onlyGovernance {
    tornadoRouter = tornadoRouterAddress;
    emit RouterRegistered(tornadoRouterAddress);
  }

  /**
   * @notice This function should allow governance to nullify a relayers balance
   * @dev IMPORTANT FUNCTION:
   *      - Should nullify the balance
   *      - Adding nullified balance as rewards was refactored to allow for the flexibility of these funds (for gov to operate with them)
   * @param relayer address of relayer who's balance is to nullify
   * */
  function nullifyBalance(address relayer) external onlyGovernance {
    address masterAddress = workers[relayer];
    require(relayer == masterAddress, "must be master");
    relayers[masterAddress].balance = 0;
    emit RelayerBalanceNullified(relayer);
  }

  /**
   * @notice This function should check if a worker is associated with a relayer
   * @param toResolve address to check
   * @return true if is associated
   * */
  function isRelayer(address toResolve) external view returns (bool) {
    return workers[toResolve] != address(0);
  }

  /**
   * @notice This function should check if a worker is registered to the relayer stated
   * @param relayer relayer to check
   * @param toResolve address to check
   * @return true if registered
   * */
  function isRelayerRegistered(address relayer, address toResolve) external view returns (bool) {
    return workers[toResolve] == relayer;
  }

  /**
   * @notice This function should get a relayers ensHash
   * @param relayer address to fetch for
   * @return relayer's ensHash
   * */
  function getRelayerEnsHash(address relayer) external view returns (bytes32) {
    return relayers[workers[relayer]].ensHash;
  }

  /**
   * @notice This function should get a relayers balance
   * @param relayer relayer who's balance is to fetch
   * @return relayer's balance
   * */
  function getRelayerBalance(address relayer) external view returns (uint256) {
    return relayers[workers[relayer]].balance;
  }
}

// 

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// 

pragma solidity ^0.6.0;





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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// 

pragma solidity ^0.6.0;

interface ENS {
  function resolver(bytes32 node) external view returns (Resolver);
}

interface Resolver {
  function addr(bytes32 node) external view returns (address);
}

// 

pragma solidity ^0.6.0;

/*
 * @dev Solidity implementation of the ENS namehash algorithm.
 *
 * Warning! Does not normalize or validate names before hashing.
 * Original version can be found here https://github.com/JonahGroendal/ens-namehash/
 */
library ENSNamehash {
  function namehash(bytes memory domain) internal pure returns (bytes32) {
    return namehash(domain, 0);
  }

  function namehash(bytes memory domain, uint256 i) internal pure returns (bytes32) {
    if (domain.length <= i) return 0x0000000000000000000000000000000000000000000000000000000000000000;

    uint256 len = labelLength(domain, i);

    return keccak256(abi.encodePacked(namehash(domain, i + len + 1), keccak(domain, i, len)));
  }

  function labelLength(bytes memory domain, uint256 i) private pure returns (uint256) {
    uint256 len;
    while (i + len != domain.length && domain[i + len] != 0x2e) {
      len++;
    }
    return len;
  }

  function keccak(
    bytes memory data,
    uint256 offset,
    uint256 len
  ) private pure returns (bytes32 ret) {
    require(offset + len <= data.length);
    assembly {
      ret := keccak256(add(add(data, 32), offset), len)
    }
  }
}

// 

pragma solidity ^0.6.0;












contract TORN is ERC20("TornadoCash", "TORN"), ERC20Burnable, ERC20Permit, Pausable, EnsResolve {
  using SafeERC20 for IERC20;

  uint256 public immutable canUnpauseAfter;
  address public immutable governance;
  mapping(address => bool) public allowedTransferee;

  event Allowed(address target);
  event Disallowed(address target);

  struct Recipient {
    bytes32 to;
    uint256 amount;
  }

  constructor(
    bytes32 _governance,
    uint256 _pausePeriod,
    Recipient[] memory _vestings
  ) public {
    address _resolvedGovernance = resolve(_governance);
    governance = _resolvedGovernance;
    allowedTransferee[_resolvedGovernance] = true;

    for (uint256 i = 0; i < _vestings.length; i++) {
      address to = resolve(_vestings[i].to);
      _mint(to, _vestings[i].amount);
      allowedTransferee[to] = true;
    }

    canUnpauseAfter = blockTimestamp().add(_pausePeriod);
    _pause();
    require(totalSupply() == 10000000 ether, "TORN: incorrect distribution");
  }

  modifier onlyGovernance() {
    require(_msgSender() == governance, "TORN: only governance can perform this action");
    _;
  }

  function changeTransferability(bool decision) public onlyGovernance {
    require(blockTimestamp() > canUnpauseAfter, "TORN: cannot change transferability yet");
    if (decision) {
      _unpause();
    } else {
      _pause();
    }
  }

  function addToAllowedList(address[] memory target) public onlyGovernance {
    for (uint256 i = 0; i < target.length; i++) {
      allowedTransferee[target[i]] = true;
      emit Allowed(target[i]);
    }
  }

  function removeFromAllowedList(address[] memory target) public onlyGovernance {
    for (uint256 i = 0; i < target.length; i++) {
      allowedTransferee[target[i]] = false;
      emit Disallowed(target[i]);
    }
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal override {
    super._beforeTokenTransfer(from, to, amount);
    require(!paused() || allowedTransferee[from] || allowedTransferee[to], "TORN: paused");
    require(to != address(this), "TORN: invalid recipient");
  }

  
  function rescueTokens(
    IERC20 _token,
    address payable _to,
    uint256 _balance
  ) external onlyGovernance {
    require(_to != address(0), "TORN: can not send to zero address");

    if (_token == IERC20(0)) {
      // for Ether
      uint256 totalBalance = address(this).balance;
      uint256 balance = _balance == 0 ? totalBalance : Math.min(totalBalance, _balance);
      _to.transfer(balance);
    } else {
      // any other erc20
      uint256 totalBalance = _token.balanceOf(address(this));
      uint256 balance = _balance == 0 ? totalBalance : Math.min(totalBalance, _balance);
      require(balance > 0, "TORN: trying to send 0 balance");
      _token.safeTransfer(_to, balance);
    }
  }
}

// 

pragma solidity ^0.6.12;









/**
 * @notice This is the staking contract of the governance staking upgrade.
 *         This contract should hold the staked funds which are received upon relayer registration,
 *         and properly attribute rewards to addresses without security issues.
 * @dev CONTRACT RISKS:
 *      - Relayer staked TORN at risk if contract is compromised.
 * */
contract TornadoStakingRewards is Initializable, EnsResolve {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  
  uint256 public immutable ratioConstant;
  ITornadoGovernance public immutable Governance;
  IERC20 public immutable torn;
  address public immutable relayerRegistry;

  
  uint256 public accumulatedRewardPerTorn;
  
  mapping(address => uint256) public accumulatedRewardRateOnLastUpdate;
  
  mapping(address => uint256) public accumulatedRewards;

  event RewardsUpdated(address indexed account, uint256 rewards);
  event RewardsClaimed(address indexed account, uint256 rewardsClaimed);

  modifier onlyGovernance() {
    require(msg.sender == address(Governance), "only governance");
    _;
  }

  constructor(
    address governanceAddress,
    address tornAddress,
    bytes32 _relayerRegistry
  ) public {
    Governance = ITornadoGovernance(governanceAddress);
    torn = IERC20(tornAddress);
    relayerRegistry = resolve(_relayerRegistry);
    ratioConstant = IERC20(tornAddress).totalSupply();
  }

  /**
   * @notice This function should safely send a user his rewards.
   * @dev IMPORTANT FUNCTION:
   *      We know that rewards are going to be updated every time someone locks or unlocks
   *      so we know that this function can't be used to falsely increase the amount of
   *      lockedTorn by locking in governance and subsequently calling it.
   *      - set rewards to 0 greedily
   */
  function getReward() external {
    uint256 rewards = _updateReward(msg.sender, Governance.lockedBalance(msg.sender));
    rewards = rewards.add(accumulatedRewards[msg.sender]);
    accumulatedRewards[msg.sender] = 0;
    torn.safeTransfer(msg.sender, rewards);
    emit RewardsClaimed(msg.sender, rewards);
  }

  /**
   * @notice This function should increment the proper amount of rewards per torn for the contract
   * @dev IMPORTANT FUNCTION:
   *      - calculation must not overflow with extreme values
   *        (amount <= 1e25) * 1e25 / (balance of vault <= 1e25) -> (extreme values)
   * @param amount amount to add to the rewards
   */
  function addBurnRewards(uint256 amount) external {
    require(msg.sender == address(Governance) || msg.sender == relayerRegistry, "unauthorized");
    accumulatedRewardPerTorn = accumulatedRewardPerTorn.add(
      amount.mul(ratioConstant).div(torn.balanceOf(address(Governance.userVault())))
    );
  }

  /**
   * @notice This function should allow governance to properly update the accumulated rewards rate for an account
   * @param account address of account to update data for
   * @param amountLockedBeforehand the balance locked beforehand in the governance contract
   * */
  function updateRewardsOnLockedBalanceChange(address account, uint256 amountLockedBeforehand) external onlyGovernance {
    uint256 claimed = _updateReward(account, amountLockedBeforehand);
    accumulatedRewards[account] = accumulatedRewards[account].add(claimed);
  }

  /**
   * @notice This function should allow governance rescue tokens from the staking rewards contract
   * */
  function withdrawTorn(uint256 amount) external onlyGovernance {
    if (amount == type(uint256).max) amount = torn.balanceOf(address(this));
    torn.safeTransfer(address(Governance), amount);
  }

  /**
   * @notice This function should calculated the proper amount of rewards attributed to user since the last update
   * @dev IMPORTANT FUNCTION:
   *      - calculation must not overflow with extreme values
   *        (accumulatedReward <= 1e25) * (lockedBeforehand <= 1e25) / 1e25
   *      - result may go to 0, since this implies on 1 TORN locked => accumulatedReward <= 1e7, meaning a very small reward
   * @param account address of account to calculate rewards for
   * @param amountLockedBeforehand the balance locked beforehand in the governance contract
   * @return claimed the rewards attributed to user since the last update
   */
  function _updateReward(address account, uint256 amountLockedBeforehand) private returns (uint256 claimed) {
    if (amountLockedBeforehand != 0)
      claimed = (accumulatedRewardPerTorn.sub(accumulatedRewardRateOnLastUpdate[account])).mul(amountLockedBeforehand).div(
        ratioConstant
      );
    accumulatedRewardRateOnLastUpdate[account] = accumulatedRewardPerTorn;
    emit RewardsUpdated(account, claimed);
  }

  /**
   * @notice This function should show a user his rewards.
   * @param account address of account to calculate rewards for
   */
  function checkReward(address account) external view returns (uint256 rewards) {
    uint256 amountLocked = Governance.lockedBalance(account);
    if (amountLocked != 0)
      rewards = (accumulatedRewardPerTorn.sub(accumulatedRewardRateOnLastUpdate[account])).mul(amountLocked).div(ratioConstant);
    rewards = rewards.add(accumulatedRewards[account]);
  }
}

// 

pragma solidity ^0.6.12;

interface IENS {
  function owner(bytes32 node) external view returns (address);
}

// 

pragma solidity >=0.6.0 <0.8.0;










contract TornadoRouter is EnsResolve {
  using SafeERC20 for IERC20;

  event EncryptedNote(address indexed sender, bytes encryptedNote);

  address public immutable governance;
  InstanceRegistry public immutable instanceRegistry;
  RelayerRegistry public immutable relayerRegistry;

  modifier onlyGovernance() {
    require(msg.sender == governance, "Not authorized");
    _;
  }

  modifier onlyInstanceRegistry() {
    require(msg.sender == address(instanceRegistry), "Not authorized");
    _;
  }

  constructor(
    address _governance,
    bytes32 _instanceRegistry,
    bytes32 _relayerRegistry
  ) public {
    governance = _governance;
    instanceRegistry = InstanceRegistry(resolve(_instanceRegistry));
    relayerRegistry = RelayerRegistry(resolve(_relayerRegistry));
  }

  function deposit(
    ITornadoInstance _tornado,
    bytes32 _commitment,
    bytes calldata _encryptedNote
  ) public payable virtual {
    (bool isERC20, IERC20 token, InstanceRegistry.InstanceState state, , ) = instanceRegistry.instances(_tornado);
    require(state != InstanceRegistry.InstanceState.DISABLED, "The instance is not supported");

    if (isERC20) {
      token.safeTransferFrom(msg.sender, address(this), _tornado.denomination());
    }
    _tornado.deposit{ value: msg.value }(_commitment);
    emit EncryptedNote(msg.sender, _encryptedNote);
  }

  function withdraw(
    ITornadoInstance _tornado,
    bytes calldata _proof,
    bytes32 _root,
    bytes32 _nullifierHash,
    address payable _recipient,
    address payable _relayer,
    uint256 _fee,
    uint256 _refund
  ) public payable virtual {
    (, , InstanceRegistry.InstanceState state, , ) = instanceRegistry.instances(_tornado);
    require(state != InstanceRegistry.InstanceState.DISABLED, "The instance is not supported");
    relayerRegistry.burn(msg.sender, _relayer, _tornado);

    _tornado.withdraw{ value: msg.value }(_proof, _root, _nullifierHash, _recipient, _relayer, _fee, _refund);
  }

  /**
   * @dev Sets `amount` allowance of `_spender` over the router's (this contract) tokens.
   */
  function approveExactToken(
    IERC20 _token,
    address _spender,
    uint256 _amount
  ) external onlyInstanceRegistry {
    _token.safeApprove(_spender, _amount);
  }

  /**
   * @notice Manually backup encrypted notes
   */
  function backupNotes(bytes[] calldata _encryptedNotes) external virtual {
    for (uint256 i = 0; i < _encryptedNotes.length; i++) {
      emit EncryptedNote(msg.sender, _encryptedNotes[i]);
    }
  }

  
  function rescueTokens(
    IERC20 _token,
    address payable _to,
    uint256 _amount
  ) external virtual onlyGovernance {
    require(_to != address(0), "TORN: can not send to zero address");

    if (_token == IERC20(0)) {
      // for Ether
      uint256 totalBalance = address(this).balance;
      uint256 balance = Math.min(totalBalance, _amount);
      _to.transfer(balance);
    } else {
      // any other erc20
      uint256 totalBalance = _token.balanceOf(address(this));
      uint256 balance = Math.min(totalBalance, _amount);
      require(balance > 0, "TORN: trying to send 0 balance");
      _token.safeTransfer(_to, balance);
    }
  }
}

// 

pragma solidity ^0.6.12;











contract FeeManager is EnsResolve {
  using SafeMath for uint256;

  uint256 public constant PROTOCOL_FEE_DIVIDER = 10000;
  address public immutable torn;
  address public immutable governance;
  InstanceRegistry public immutable registry;

  uint24 public uniswapTornPoolSwappingFee;
  uint32 public uniswapTimePeriod;

  uint24 public updateFeeTimeLimit;

  mapping(ITornadoInstance => uint160) public instanceFee;
  mapping(ITornadoInstance => uint256) public instanceFeeUpdated;

  event FeeUpdated(address indexed instance, uint256 newFee);
  event UniswapTornPoolSwappingFeeChanged(uint24 newFee);

  modifier onlyGovernance() {
    require(msg.sender == governance);
    _;
  }

  struct Deviation {
    address instance;
    int256 deviation; // in 10**-1 percents, so it can be like -2.3% if the price of TORN declined
  }

  constructor(
    address _torn,
    address _governance,
    bytes32 _registry
  ) public {
    torn = _torn;
    governance = _governance;
    registry = InstanceRegistry(resolve(_registry));
  }

  /**
   * @notice This function should update the fees of each pool
   */
  function updateAllFees() external {
    updateFees(registry.getAllInstanceAddresses());
  }

  /**
   * @notice This function should update the fees for tornado instances
   *         (here called pools)
   * @param _instances pool addresses to update fees for
   * */
  function updateFees(ITornadoInstance[] memory _instances) public {
    for (uint256 i = 0; i < _instances.length; i++) {
      updateFee(_instances[i]);
    }
  }

  /**
   * @notice This function should update the fee of a specific pool
   * @param _instance address of the pool to update fees for
   */
  function updateFee(ITornadoInstance _instance) public {
    uint160 newFee = calculatePoolFee(_instance);
    instanceFee[_instance] = newFee;
    instanceFeeUpdated[_instance] = now;
    emit FeeUpdated(address(_instance), newFee);
  }

  /**
   * @notice This function should return the fee of a specific pool and update it if the time has come
   * @param _instance address of the pool to get fees for
   */
  function instanceFeeWithUpdate(ITornadoInstance _instance) public returns (uint160) {
    if (now - instanceFeeUpdated[_instance] > updateFeeTimeLimit) {
      updateFee(_instance);
    }
    return instanceFee[_instance];
  }

  /**
   * @notice function to update a single fee entry
   * @param _instance instance for which to update data
   * @return newFee the new fee pool
   */
  function calculatePoolFee(ITornadoInstance _instance) public view returns (uint160) {
    (bool isERC20, IERC20 token, , uint24 uniswapPoolSwappingFee, uint32 protocolFeePercentage) = registry.instances(_instance);
    if (protocolFeePercentage == 0) {
      return 0;
    }

    token = token == IERC20(0) && !isERC20 ? IERC20(UniswapV3OracleHelper.WETH) : token; // for eth instances
    uint256 tokenPriceRatio = UniswapV3OracleHelper.getPriceRatioOfTokens(
      [torn, address(token)],
      [uniswapTornPoolSwappingFee, uniswapPoolSwappingFee],
      uniswapTimePeriod
    );
    // prettier-ignore
    return
      uint160(
        _instance
        .denomination()
        .mul(UniswapV3OracleHelper.RATIO_DIVIDER)
        .div(tokenPriceRatio)
        .mul(uint256(protocolFeePercentage))
        .div(PROTOCOL_FEE_DIVIDER)
      );
  }

  /**
   * @notice function to update the uniswap fee
   * @param _uniswapTornPoolSwappingFee new uniswap fee
   */
  function setUniswapTornPoolSwappingFee(uint24 _uniswapTornPoolSwappingFee) public onlyGovernance {
    uniswapTornPoolSwappingFee = _uniswapTornPoolSwappingFee;
    emit UniswapTornPoolSwappingFeeChanged(uniswapTornPoolSwappingFee);
  }

  /**
   * @notice This function should allow governance to set a new period for twap measurement
   * @param newPeriod the new period to use
   * */
  function setPeriodForTWAPOracle(uint32 newPeriod) external onlyGovernance {
    uniswapTimePeriod = newPeriod;
  }

  /**
   * @notice This function should allow governance to set a new update fee time limit for instance fee updating
   * @param newLimit the new time limit to use
   * */
  function setUpdateFeeTimeLimit(uint24 newLimit) external onlyGovernance {
    updateFeeTimeLimit = newLimit;
  }

  /**
   * @notice returns fees deviations for each instance, so it can be easily seen what instance requires an update
   */
  function feeDeviations() public view returns (Deviation[] memory results) {
    ITornadoInstance[] memory instances = registry.getAllInstanceAddresses();
    results = new Deviation[](instances.length);

    for (uint256 i = 0; i < instances.length; i++) {
      uint256 marketFee = calculatePoolFee(instances[i]);
      int256 deviation;
      if (marketFee != 0) {
        deviation = int256((instanceFee[instances[i]] * 1000) / marketFee) - 1000;
      }

      results[i] = Deviation({ instance: address(instances[i]), deviation: deviation });
    }
  }
}

// 

pragma solidity ^0.6.2;

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
        // This method relies in extcodesize, which returns 0 for contracts in
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

// 

pragma solidity ^0.6.0;


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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}

// 

pragma solidity ^0.6.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// 

pragma solidity ^0.6.0;

// A copy from https://github.com/OpenZeppelin/openzeppelin-contracts/pull/2237/files

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
  /**
   * @dev Returns the address that signed a hashed message (`hash`) with
   * `signature`. This address can then be used for verification purposes.
   *
   * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
   * this function rejects them by requiring the `s` value to be in the lower
   * half order, and the `v` value to be either 27 or 28.
   *
   * IMPORTANT: `hash` _must_ be the result of a hash operation for the
   * verification to be secure: it is possible to craft signatures that
   * recover to arbitrary addresses for non-hashed data. A safe way to ensure
   * this is by receiving a hash of the original message (which may otherwise
   * be too long), and then calling {toEthSignedMessageHash} on it.
   */
  function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
    // Check the signature length
    if (signature.length != 65) {
      revert("ECDSA: invalid signature length");
    }

    // Divide the signature in r, s and v variables
    bytes32 r;
    bytes32 s;
    uint8 v;

    // ecrecover takes the signature parameters, and the only way to get them
    // currently is to use assembly.
    // solhint-disable-next-line no-inline-assembly
    assembly {
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := mload(add(signature, 0x41))
    }

    return recover(hash, v, r, s);
  }

  /**
   * @dev Overload of {ECDSA-recover-bytes32-bytes-} that receives the `v`,
   * `r` and `s` signature fields separately.
   */
  function recover(
    bytes32 hash,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal pure returns (address) {
    // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
    // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
    // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
    // signatures from current libraries generate a unique signature with an s-value in the lower half order.
    //
    // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
    // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
    // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
    // these malleable signatures as well.
    require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
    require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

    // If the signature is valid (and not malleable), return the signer address
    address signer = ecrecover(hash, v, r, s);
    require(signer != address(0), "ECDSA: invalid signature");

    return signer;
  }

  /**
   * @dev Returns an Ethereum Signed Message, created from a `hash`. This
   * replicates the behavior of the
   * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
   * JSON-RPC method.
   *
   * See {recover}.
   */
  function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
  }
}

// 

pragma solidity ^0.6.12;



interface ITornadoGovernance {
  function lockedBalance(address account) external view returns (uint256);

  function userVault() external view returns (ITornadoVault);
}

// 

pragma solidity ^0.6.12;


interface ITornadoVault {
  function withdrawTorn(address recipient, uint256 amount) external;
}

// 

pragma solidity >=0.6.0 <0.8.0;

interface ITornadoInstance {
  function token() external view returns (address);

  function denomination() external view returns (uint256);

  function deposit(bytes32 commitment) external payable;

  function withdraw(
    bytes calldata proof,
    bytes32 root,
    bytes32 nullifierHash,
    address payable recipient,
    address payable relayer,
    uint256 fee,
    uint256 refund
  ) external payable;
}

// 

pragma solidity ^0.6.12;










contract InstanceRegistry is Initializable, EnsResolve {
  using SafeERC20 for IERC20;

  enum InstanceState {
    DISABLED,
    ENABLED
  }

  struct Instance {
    bool isERC20;
    IERC20 token;
    InstanceState state;
    // the fee of the uniswap pool which will be used to get a TWAP
    uint24 uniswapPoolSwappingFee;
    // the fee the protocol takes from relayer, it should be multiplied by PROTOCOL_FEE_DIVIDER from FeeManager.sol
    uint32 protocolFeePercentage;
  }

  struct Tornado {
    ITornadoInstance addr;
    Instance instance;
  }

  address public immutable governance;
  TornadoRouter public router;

  mapping(ITornadoInstance => Instance) public instances;
  ITornadoInstance[] public instanceIds;

  event InstanceStateUpdated(ITornadoInstance indexed instance, InstanceState state);
  event RouterRegistered(address tornadoRouter);

  modifier onlyGovernance() {
    require(msg.sender == governance, "Not authorized");
    _;
  }

  constructor(address _governance) public {
    governance = _governance;
  }

  function initialize(Tornado[] memory _instances, bytes32 _router) external initializer {
    router = TornadoRouter(resolve(_router));
    for (uint256 i = 0; i < _instances.length; i++) {
      _updateInstance(_instances[i]);
      instanceIds.push(_instances[i].addr);
    }
  }

  /**
   * @dev Add or update an instance.
   */
  function updateInstance(Tornado calldata _tornado) external virtual onlyGovernance {
    require(_tornado.instance.state != InstanceState.DISABLED, "Use removeInstance() for remove");
    if (instances[_tornado.addr].state == InstanceState.DISABLED) {
      instanceIds.push(_tornado.addr);
    }
    _updateInstance(_tornado);
  }

  /**
   * @dev Remove an instance.
   * @param _instanceId The instance id in `instanceIds` mapping to remove.
   */
  function removeInstance(uint256 _instanceId) external virtual onlyGovernance {
    ITornadoInstance _instance = instanceIds[_instanceId];
    (bool isERC20, IERC20 token) = (instances[_instance].isERC20, instances[_instance].token);

    if (isERC20) {
      uint256 allowance = token.allowance(address(router), address(_instance));
      if (allowance != 0) {
        router.approveExactToken(token, address(_instance), 0);
      }
    }

    delete instances[_instance];
    instanceIds[_instanceId] = instanceIds[instanceIds.length - 1];
    instanceIds.pop();
    emit InstanceStateUpdated(_instance, InstanceState.DISABLED);
  }

  /**
   * @notice This function should allow governance to set a new protocol fee for relayers
   * @param instance the to update
   * @param newFee the new fee to use
   * */
  function setProtocolFee(ITornadoInstance instance, uint32 newFee) external onlyGovernance {
    instances[instance].protocolFeePercentage = newFee;
  }

  /**
   * @notice This function should allow governance to set a new tornado proxy address
   * @param routerAddress address of the new proxy
   * */
  function setTornadoRouter(address routerAddress) external onlyGovernance {
    router = TornadoRouter(routerAddress);
    emit RouterRegistered(routerAddress);
  }

  function _updateInstance(Tornado memory _tornado) internal virtual {
    instances[_tornado.addr] = _tornado.instance;
    if (_tornado.instance.isERC20) {
      IERC20 token = IERC20(_tornado.addr.token());
      require(token == _tornado.instance.token, "Incorrect token");
      uint256 allowance = token.allowance(address(router), address(_tornado.addr));

      if (allowance == 0) {
        router.approveExactToken(token, address(_tornado.addr), type(uint256).max);
      }
    }
    emit InstanceStateUpdated(_tornado.addr, _tornado.instance.state);
  }

  /**
   * @dev Returns all instance configs
   */
  function getAllInstances() public view returns (Tornado[] memory result) {
    result = new Tornado[](instanceIds.length);
    for (uint256 i = 0; i < instanceIds.length; i++) {
      ITornadoInstance _instance = instanceIds[i];
      result[i] = Tornado({ addr: _instance, instance: instances[_instance] });
    }
  }

  /**
   * @dev Returns all instance addresses
   */
  function getAllInstanceAddresses() public view returns (ITornadoInstance[] memory result) {
    result = new ITornadoInstance[](instanceIds.length);
    for (uint256 i = 0; i < instanceIds.length; i++) {
      result[i] = instanceIds[i];
    }
  }

  
  
  function getPoolToken(ITornadoInstance instance) external view returns (address) {
    return address(instances[instance].token);
  }
}

// 

pragma solidity ^0.6.12;





interface IERC20Decimals {
  function decimals() external view returns (uint8);
}

library UniswapV3OracleHelper {
  using LowGasSafeMath for uint256;

  IUniswapV3Factory internal constant UniswapV3Factory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);
  address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  uint256 internal constant RATIO_DIVIDER = 1e18;

  /**
   * @notice This function should return the price of baseToken in quoteToken, as in: quote/base (WETH/TORN)
   * @dev uses the Uniswap written OracleLibrary "getQuoteAtTick", does not call external libraries,
   *      uses decimals() for the correct power of 10
   * @param baseToken token which will be denominated in quote token
   * @param quoteToken token in which price will be denominated
   * @param fee the uniswap pool fee, pools have different fees so this is a pool selector for our usecase
   * @param period the amount of seconds we are going to look into the past for the new token price
   * @return returns the price of baseToken in quoteToken
   * */
  function getPriceOfTokenInToken(
    address baseToken,
    address quoteToken,
    uint24 fee,
    uint32 period
  ) internal view returns (uint256) {
    uint128 base = uint128(10)**uint128(IERC20Decimals(quoteToken).decimals());
    if (baseToken == quoteToken) return base;
    else
      return
        OracleLibrary.getQuoteAtTick(
          OracleLibrary.consult(UniswapV3Factory.getPool(baseToken, quoteToken, fee), period),
          base,
          baseToken,
          quoteToken
        );
  }

  /**
   * @notice This function should return the price of token in WETH
   * @dev simply feeds WETH in to the above function
   * @param token token which will be denominated in WETH
   * @param fee the uniswap pool fee, pools have different fees so this is a pool selector for our usecase
   * @param period the amount of seconds we are going to look into the past for the new token price
   * @return returns the price of token in WETH
   * */
  function getPriceOfTokenInWETH(
    address token,
    uint24 fee,
    uint32 period
  ) internal view returns (uint256) {
    return getPriceOfTokenInToken(token, WETH, fee, period);
  }

  /**
   * @notice This function should return the price of WETH in token
   * @dev simply feeds WETH into getPriceOfTokenInToken
   * @param token token which WETH will be denominated in
   * @param fee the uniswap pool fee, pools have different fees so this is a pool selector for our usecase
   * @param period the amount of seconds we are going to look into the past for the new token price
   * @return returns the price of token in WETH
   * */
  function getPriceOfWETHInToken(
    address token,
    uint24 fee,
    uint32 period
  ) internal view returns (uint256) {
    return getPriceOfTokenInToken(WETH, token, fee, period);
  }

  /**
   * @notice This function returns the price of token[0] in token[1], but more precisely and importantly the price ratio of the tokens in WETH
   * @dev this is done as to always have good prices due to WETH-token pools mostly always having the most liquidity
   * @param tokens array of tokens to get ratio for
   * @param fees the uniswap pool FEES, since these are two independent tokens
   * @param period the amount of seconds we are going to look into the past for the new token price
   * @return returns the price of token[0] in token[1]
   * */
  function getPriceRatioOfTokens(
    address[2] memory tokens,
    uint24[2] memory fees,
    uint32 period
  ) internal view returns (uint256) {
    return
      getPriceOfTokenInWETH(tokens[0], fees[0], period).mul(RATIO_DIVIDER) / getPriceOfTokenInWETH(tokens[1], fees[1], period);
  }
}

// 
pragma solidity >=0.5.0;









library OracleLibrary {
    
    
    
    
    function consult(address pool, uint32 period) internal view returns (int24 timeWeightedAverageTick) {
        require(period != 0, 'BP');

        uint32[] memory secondAgos = new uint32[](2);
        secondAgos[0] = period;
        secondAgos[1] = 0;

        (int56[] memory tickCumulatives, ) = IUniswapV3Pool(pool).observe(secondAgos);
        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        timeWeightedAverageTick = int24(tickCumulativesDelta / int(uint256(period)));

        // Always round to negative infinity
        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % int(uint256(period)) != 0)) timeWeightedAverageTick--;
    }

    
    
    
    
    
    
    function getQuoteAtTick(
        int24 tick,
        uint128 baseAmount,
        address baseToken,
        address quoteToken
    ) internal pure returns (uint256 quoteAmount) {
        uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);

        // Calculate quoteAmount with better precision if it doesn't overflow when multiplied by itself
        if (sqrtRatioX96 <= type(uint128).max) {
            uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX192, baseAmount, 1 << 192)
                : FullMath.mulDiv(1 << 192, baseAmount, ratioX192);
        } else {
            uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX128, baseAmount, 1 << 128)
                : FullMath.mulDiv(1 << 128, baseAmount, ratioX128);
        }
    }
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
pragma solidity >=0.6.12;



library LowGasSafeMath {
    
    
    
    
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    
    
    
    
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    
    
    
    
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    
    
    
    
    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x + y) >= x == (y >= 0));
    }

    
    
    
    
    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x - y) <= x == (y >= 0));
    }
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
        uint256 twos = (type(uint256).max - denominator + 1) & denominator;
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
pragma solidity >=0.5.0;



/// prices between 2**-128 and 2**128
library TickMath {
    
    int24 internal constant MIN_TICK = -887272;
    
    int24 internal constant MAX_TICK = -MIN_TICK;

    
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    
    
    
    
    /// at the given tick
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        require(absTick <= uint256(int(MAX_TICK)), 'T');

        uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
        // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
        // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }

    
    
    /// ever return.
    
    
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        // second inequality must be < because the price can never reach the price at the max tick
        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, 'R');
        uint256 ratio = uint256(sqrtPriceX96) << 32;

        uint256 r = ratio;
        uint256 msb = 0;

        assembly {
            let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(5, gt(r, 0xFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(4, gt(r, 0xFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(3, gt(r, 0xFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(2, gt(r, 0xF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(1, gt(r, 0x3))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := gt(r, 0x1)
            msb := or(msb, f)
        }

        if (msb >= 128) r = ratio >> (msb - 127);
        else r = ratio << (127 - msb);

        int256 log_2 = (int256(msb) - 128) << 64;

        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(63, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(62, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(61, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(60, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(59, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(58, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(57, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(56, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(55, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(54, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(53, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(52, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(51, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(50, f))
        }

        int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

        int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
        int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

        tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
    }
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


library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    
    
    
    
    
    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    
    
    
    
    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex'ff',
                            factory,
                            keccak256(abi.encode(key.token0, key.token1, key.fee)),
                            POOL_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }
}
