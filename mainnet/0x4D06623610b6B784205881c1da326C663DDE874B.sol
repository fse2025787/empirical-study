// SPDX-License-Identifier: MIT


// 

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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
contract ERC20 is Context, IERC20, IERC20Metadata {
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
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
}

// 

pragma solidity ^0.8.0;



/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;
    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                block.chainid,
                address(this)
            )
        );
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// 

pragma solidity ^0.8.0;







/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping (address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private immutable _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {
    }

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _useNonce(owner),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3MintCallback {
    
    
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    
    
    
    function uniswapV3MintCallback(
        uint256 amount0Owed,
        uint256 amount1Owed,
        bytes calldata data
    ) external;
}

// 
pragma solidity ^0.8.0;



contract AloePoolERC20 is ERC20Permit {
    constructor() ERC20Permit("Aloe V1") ERC20("Aloe V1", "ALOE-V1") {}
}

// 
pragma solidity ^0.8.0;












contract UniswapMinter is IUniswapV3MintCallback {
    using SafeERC20 for IERC20;

    IUniswapV3Pool public immutable UNI_POOL;

    uint24 public immutable UNI_FEE;

    int24 public immutable TICK_SPACING;

    IERC20 public immutable TOKEN0;

    IERC20 public immutable TOKEN1;

    uint256 internal lastMintedAmount0;

    uint256 internal lastMintedAmount1;

    constructor(IUniswapV3Pool uniPool) {
        UNI_POOL = uniPool;
        UNI_FEE = uniPool.fee();
        TICK_SPACING = uniPool.tickSpacing();
        TOKEN0 = IERC20(uniPool.token0());
        TOKEN1 = IERC20(uniPool.token1());
    }

    
    function _uniswapPoke(Ticks memory ticks) internal {
        (uint128 liquidity, , , , ) = _position(ticks);
        if (liquidity == 0) return;
        UNI_POOL.burn(ticks.lower, ticks.upper, 0);
    }

    
    function _uniswapEnter(Ticks memory ticks, uint128 liquidity) internal {
        if (liquidity == 0) return;
        UNI_POOL.mint(address(this), ticks.lower, ticks.upper, liquidity, "");
    }

    
    function _uniswapExit(Ticks memory ticks, uint128 liquidity)
        internal
        returns (
            uint256 burned0,
            uint256 burned1,
            uint256 earned0,
            uint256 earned1
        )
    {
        if (liquidity != 0) {
            (burned0, burned1) = UNI_POOL.burn(ticks.lower, ticks.upper, liquidity);
        }

        // Collect all owed tokens including earned fees
        (uint256 collected0, uint256 collected1) =
            UNI_POOL.collect(address(this), ticks.lower, ticks.upper, type(uint128).max, type(uint128).max);

        earned0 = collected0 - burned0;
        earned1 = collected1 - burned1;
    }

    /**
     * @notice Amounts of TOKEN0 and TOKEN1 held in vault's position. Includes
     * owed fees, except those accrued since last poke.
     */
    function _collectableAmountsAsOfLastPoke(Ticks memory ticks) public view returns (uint256, uint256) {
        (uint128 liquidity, , , uint128 earnable0, uint128 earnable1) = _position(ticks);
        (uint160 sqrtPriceX96, , , , , , ) = UNI_POOL.slot0();
        (uint256 burnable0, uint256 burnable1) = _amountsForLiquidity(ticks, liquidity, sqrtPriceX96);

        return (burnable0 + earnable0, burnable1 + earnable1);
    }

    
    function _position(Ticks memory ticks)
        internal
        view
        returns (
            uint128, // liquidity
            uint256, // feeGrowthInside0LastX128
            uint256, // feeGrowthInside1LastX128
            uint128, // tokensOwed0
            uint128 // tokensOwed1
        )
    {
        return UNI_POOL.positions(keccak256(abi.encodePacked(address(this), ticks.lower, ticks.upper)));
    }

    
    function _amountsForLiquidity(Ticks memory ticks, uint128 liquidity, uint160 sqrtPriceX96) internal pure returns (uint256, uint256) {
        return
            LiquidityAmounts.getAmountsForLiquidity(
                sqrtPriceX96,
                TickMath.getSqrtRatioAtTick(ticks.lower),
                TickMath.getSqrtRatioAtTick(ticks.upper),
                liquidity
            );
    }

    
    function _liquidityForAmounts(
        Ticks memory ticks,
        uint160 sqrtPriceX96,
        uint256 amount0,
        uint256 amount1
    ) internal pure returns (uint128) {
        return
            LiquidityAmounts.getLiquidityForAmounts(
                sqrtPriceX96,
                TickMath.getSqrtRatioAtTick(ticks.lower),
                TickMath.getSqrtRatioAtTick(ticks.upper),
                amount0,
                amount1
            );
    }

    
    function _liquidityForAmount0(Ticks memory ticks, uint256 amount0) internal pure returns (uint128) {
        return
            LiquidityAmounts.getLiquidityForAmount0(
                TickMath.getSqrtRatioAtTick(ticks.lower),
                TickMath.getSqrtRatioAtTick(ticks.upper),
                amount0
            );
    }

    
    function _liquidityForAmount1(Ticks memory ticks, uint256 amount1) internal pure returns (uint128) {
        return
            LiquidityAmounts.getLiquidityForAmount1(
                TickMath.getSqrtRatioAtTick(ticks.lower),
                TickMath.getSqrtRatioAtTick(ticks.upper),
                amount1
            );
    }

    
    function uniswapV3MintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external override {
        require(msg.sender == address(UNI_POOL), "Fake callback");
        if (amount0 != 0) TOKEN0.safeTransfer(msg.sender, amount0);
        if (amount1 != 0) TOKEN1.safeTransfer(msg.sender, amount1);

        lastMintedAmount0 = amount0;
        lastMintedAmount1 = amount1;
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
}

// 
pragma solidity ^0.8.0;

interface IAloePredictionsActions {
    
    function advance() external;

    /**
     * @notice Allows users to submit proposals in `epoch`. These proposals specify aggregate position
     * in `epoch + 1` and adjusted stakes become claimable in `epoch + 2`
     * @param lower The Q128.48 price at the lower bound, unless `shouldInvertPrices`, in which case
     * this should be `1 / (priceAtUpperBound * 2 ** 16)`
     * @param upper The Q128.48 price at the upper bound, unless `shouldInvertPrices`, in which case
     * this should be `1 / (priceAtLowerBound * 2 ** 16)`
     * @param stake The amount of ALOE to stake on this proposal. Once submitted, you can't unsubmit!
     * @return key The unique ID of this proposal, used to update bounds and claim reward
     */
    function submitProposal(
        uint176 lower,
        uint176 upper,
        uint80 stake
    ) external returns (uint40 key);

    /**
     * @notice Allows users to update bounds of a proposal they submitted previously. This only
     * works if the epoch hasn't increased since submission
     * @param key The key of the proposal that should be updated
     * @param lower The Q128.48 price at the lower bound, unless `shouldInvertPrices`, in which case
     * this should be `1 / (priceAtUpperBound * 2 ** 16)`
     * @param upper The Q128.48 price at the upper bound, unless `shouldInvertPrices`, in which case
     * this should be `1 / (priceAtLowerBound * 2 ** 16)`
     */
    function updateProposal(
        uint40 key,
        uint176 lower,
        uint176 upper
    ) external;

    /**
     * @notice Allows users to reclaim ALOE that they staked in previous epochs, as long as
     * the epoch has ground truth information
     * @dev ALOE is sent to `proposal.source` not `msg.sender`, so anyone can trigger a claim
     * for anyone else
     * @param key The key of the proposal that should be judged and rewarded
     * @param extras An array of tokens for which extra incentives should be claimed
     */
    function claimReward(uint40 key, address[] calldata extras) external;
}

// 
pragma solidity ^0.8.0;



interface IAloePredictionsDerivedState {
    /**
     * @notice Statistics for the most recent crowdsourced probability density function, evaluated about current price
     * @return areInverted Whether the reported values are for inverted prices
     * @return mean Result of `computeMean()`
     * @return sigmaL The sqrt of the lower semivariance
     * @return sigmaU The sqrt of the upper semivariance
     */
    function current()
        external
        view
        returns (
            bool areInverted,
            uint176 mean,
            uint128 sigmaL,
            uint128 sigmaU
        );

    
    function epochExpectedEndTime() external view returns (uint32);

    /**
     * @notice Aggregates proposals in the previous `epoch`. Only the top `NUM_PROPOSALS_TO_AGGREGATE`, ordered by
     * stake, will be considered.
     * @return mean The mean of the crowdsourced probability density function (1st Raw Moment)
     */
    function computeMean() external view returns (uint176 mean);

    /**
     * @notice Aggregates proposals in the previous `epoch`. Only the top `NUM_PROPOSALS_TO_AGGREGATE`, ordered by
     * stake, will be considered.
     * @return lower The lower semivariance of the crowdsourced probability density function (2nd Central Moment, Lower)
     * @return upper The upper semivariance of the crowdsourced probability density function (2nd Central Moment, Upper)
     */
    function computeSemivariancesAbout(uint176 center) external view returns (uint256 lower, uint256 upper);

    /**
     * @notice Fetches Uniswap prices over 10 discrete intervals in the past hour. Computes mean and standard
     * deviation of these samples, and returns "ground truth" bounds that should enclose ~95% of trading activity
     * @return bounds The "ground truth" price range that will be used when computing rewards
     * @return shouldInvertPricesNext Whether proposals in the next epoch should be submitted with inverted bounds
     */
    function fetchGroundTruth() external view returns (Bounds memory bounds, bool shouldInvertPricesNext);

    /**
     * @notice Builds a memory array that can be passed to Uniswap V3's `observe` function to specify
     * intervals over which mean prices should be fetched
     * @return secondsAgos From how long ago each cumulative tick and liquidity value should be returned
     */
    function selectedOracleTimetable() external pure returns (uint32[] memory secondsAgos);
}

// 
pragma solidity ^0.8.0;

interface IAloePredictionsEvents {
    event ProposalSubmitted(
        address indexed source,
        uint24 indexed epoch,
        uint40 key,
        uint176 lower,
        uint176 upper,
        uint80 stake
    );

    event ProposalUpdated(address indexed source, uint24 indexed epoch, uint40 key, uint176 lower, uint176 upper);

    event FetchedGroundTruth(uint176 lower, uint176 upper, bool didInvertPrices);

    event Advanced(uint24 epoch, uint32 epochStartTime);

    event ClaimedReward(address indexed recipient, uint24 indexed epoch, uint40 key, uint80 amount);
}

// 
pragma solidity ^0.8.0;




interface IAloePredictionsState {
    
    function proposals(uint40 key)
        external
        view
        returns (
            address source,
            uint24 submissionEpoch,
            uint176 lower,
            uint176 upper,
            uint80 stake
        );

    
    function nextProposalKey() external view returns (uint40);

    
    function epoch() external view returns (uint24);

    
    function epochStartTime() external view returns (uint32);

    
    function shouldInvertPrices() external view returns (bool);

    
    function didInvertPrices() external view returns (bool);
}

// 
pragma solidity ^0.8.0;

















uint256 constant TWO_144 = 2**144;

struct PDF {
    bool isInverted;
    uint176 mean;
    uint128 sigmaL;
    uint128 sigmaU;
}

contract AloePool is AloePoolERC20, UniswapMinter {
    using SafeERC20 for IERC20;

    event Deposit(address indexed sender, uint256 shares, uint256 amount0, uint256 amount1);

    event Withdraw(address indexed sender, uint256 shares, uint256 amount0, uint256 amount1);

    event Snapshot(int24 tick, uint256 totalAmount0, uint256 totalAmount1, uint256 totalSupply);

    
    uint48 public K = 5;

    
    uint32 public constant CURRENT_PRICE_WINDOW = 360;

    
    IAloePredictions public immutable PREDICTIONS;

    
    uint24 public epoch;

    
    Ticks public elastic;

    
    Ticks public cushion;

    
    Ticks public excess;

    
    PDF public pdf;

    
    bool public didHaveExcessToken0;

    
    bool private locked;

    bool public allowRebalances = true;

    modifier lock() {
        require(!locked, "Aloe: Locked");
        locked = true;
        _;
        locked = false;
    }

    constructor(address predictions)
        AloePoolERC20()
        UniswapMinter(IUniswapV3Pool(IAloePredictionsImmutables(predictions).UNI_POOL()))
    {
        PREDICTIONS = IAloePredictions(predictions);
    }

    /**
     * @notice Calculates the vault's total holdings of TOKEN0 and TOKEN1 - in
     * other words, how much of each token the vault would hold if it withdrew
     * all its liquidity from Uniswap.
     */
    function getReserves() public view returns (uint256 reserve0, uint256 reserve1) {
        reserve0 = TOKEN0.balanceOf(address(this));
        reserve1 = TOKEN1.balanceOf(address(this));
        uint256 temp0;
        uint256 temp1;
        (temp0, temp1) = _collectableAmountsAsOfLastPoke(elastic);
        reserve0 += temp0;
        reserve1 += temp1;
        (temp0, temp1) = _collectableAmountsAsOfLastPoke(cushion);
        reserve0 += temp0;
        reserve1 += temp1;
        (temp0, temp1) = _collectableAmountsAsOfLastPoke(excess);
        reserve0 += temp0;
        reserve1 += temp1;
    }

    function getNextElasticTicks() public view returns (Ticks memory) {
        // Define the window over which we want to fetch price
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = CURRENT_PRICE_WINDOW;
        secondsAgos[1] = 0;

        // Fetch price and account for possible inversion
        (int56[] memory tickCumulatives, ) = UNI_POOL.observe(secondsAgos);
        uint176 price =
            TickMath.getSqrtRatioAtTick(
                int24((tickCumulatives[1] - tickCumulatives[0]) / int56(uint56(CURRENT_PRICE_WINDOW)))
            );
        if (pdf.isInverted) price = type(uint160).max / price;
        price = uint176(FullMath.mulDiv(price, price, TWO_144));

        return _getNextElasticTicks(price, pdf.mean, pdf.sigmaL, pdf.sigmaU, pdf.isInverted);
    }

    function _getNextElasticTicks(
        uint176 price,
        uint176 mean,
        uint128 sigmaL,
        uint128 sigmaU,
        bool areInverted
    ) private view returns (Ticks memory ticks) {
        uint48 n;
        uint176 widthL;
        uint176 widthU;

        if (price < mean) {
            n = uint48((mean - price) / sigmaL);
            widthL = uint176(sigmaL) * uint176(K + n);
            widthU = uint176(sigmaU) * uint176(K);
        } else {
            n = uint48((price - mean) / sigmaU);
            widthL = uint176(sigmaL) * uint176(K);
            widthU = uint176(sigmaU) * uint176(K + n);
        }

        uint176 l = mean > widthL ? mean - widthL : 1;
        uint176 u = mean < type(uint176).max - widthU ? mean + widthU : type(uint176).max;
        uint160 sqrtPriceX96;

        if (areInverted) {
            sqrtPriceX96 = uint160(uint256(type(uint128).max) / Math.sqrt(u << 80));
            ticks.lower = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
            sqrtPriceX96 = uint160(uint256(type(uint128).max) / Math.sqrt(l << 80));
            ticks.upper = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        } else {
            sqrtPriceX96 = uint160(Math.sqrt(l << 80) << 32);
            ticks.lower = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
            sqrtPriceX96 = uint160(Math.sqrt(u << 80) << 32);
            ticks.upper = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        }
    }

    /**
     * @notice Deposits tokens in proportion to the vault's current holdings.
     * @dev These tokens sit in the vault and are not used for liquidity on
     * Uniswap until the next rebalance. Also note it's not necessary to check
     * if user manipulated price to deposit cheaper, as the value of range
     * orders can only by manipulated higher.
     * @dev LOCK MODIFIER IS APPLIED IN AloePoolCapped!!!
     * @param amount0Max Max amount of TOKEN0 to deposit
     * @param amount1Max Max amount of TOKEN1 to deposit
     * @param amount0Min Ensure `amount0` is greater than this
     * @param amount1Min Ensure `amount1` is greater than this
     * @return shares Number of shares minted
     * @return amount0 Amount of TOKEN0 deposited
     * @return amount1 Amount of TOKEN1 deposited
     */
    function deposit(
        uint256 amount0Max,
        uint256 amount1Max,
        uint256 amount0Min,
        uint256 amount1Min
    )
        public
        virtual
        returns (
            uint256 shares,
            uint256 amount0,
            uint256 amount1
        )
    {
        require(amount0Max != 0 || amount1Max != 0, "Aloe: 0 deposit");

        _uniswapPoke(elastic);
        _uniswapPoke(cushion);
        _uniswapPoke(excess);

        (shares, amount0, amount1) = _computeLPShares(amount0Max, amount1Max);
        require(shares != 0, "Aloe: 0 shares");
        require(amount0 >= amount0Min, "Aloe: amount0 too low");
        require(amount1 >= amount1Min, "Aloe: amount1 too low");

        // Pull in tokens from sender
        if (amount0 != 0) TOKEN0.safeTransferFrom(msg.sender, address(this), amount0);
        if (amount1 != 0) TOKEN1.safeTransferFrom(msg.sender, address(this), amount1);

        // Mint shares
        _mint(msg.sender, shares);
        emit Deposit(msg.sender, shares, amount0, amount1);
    }

    
    /// they're in the same proportion as total amounts, but not greater than
    /// `amount0Max` and `amount1Max` respectively.
    function _computeLPShares(uint256 amount0Max, uint256 amount1Max)
        internal
        view
        returns (
            uint256 shares,
            uint256 amount0,
            uint256 amount1
        )
    {
        uint256 totalSupply = totalSupply();
        (uint256 reserve0, uint256 reserve1) = getReserves();

        // If total supply > 0, pool can't be empty
        assert(totalSupply == 0 || reserve0 != 0 || reserve1 != 0);

        if (totalSupply == 0) {
            // For first deposit, just use the amounts desired
            amount0 = amount0Max;
            amount1 = amount1Max;
            shares = amount0 > amount1 ? amount0 : amount1; // max
        } else if (reserve0 == 0) {
            amount1 = amount1Max;
            shares = FullMath.mulDiv(amount1, totalSupply, reserve1);
        } else if (reserve1 == 0) {
            amount0 = amount0Max;
            shares = FullMath.mulDiv(amount0, totalSupply, reserve0);
        } else {
            amount0 = FullMath.mulDiv(amount1Max, reserve0, reserve1);

            if (amount0 < amount0Max) {
                amount1 = amount1Max;
                shares = FullMath.mulDiv(amount1, totalSupply, reserve1);
            } else {
                amount0 = amount0Max;
                amount1 = FullMath.mulDiv(amount0, reserve1, reserve0);
                shares = FullMath.mulDiv(amount0, totalSupply, reserve0);
            }
        }
    }

    /**
     * @notice Withdraws tokens in proportion to the vault's holdings.
     * @param shares Shares burned by sender
     * @param amount0Min Revert if resulting `amount0` is smaller than this
     * @param amount1Min Revert if resulting `amount1` is smaller than this
     * @return amount0 Amount of TOKEN0 sent to recipient
     * @return amount1 Amount of TOKEN1 sent to recipient
     */
    function withdraw(
        uint256 shares,
        uint256 amount0Min,
        uint256 amount1Min
    ) external lock returns (uint256 amount0, uint256 amount1) {
        require(shares != 0, "Aloe: 0 shares");
        uint256 totalSupply = totalSupply() + 1;

        // Calculate token amounts proportional to unused balances
        amount0 = FullMath.mulDiv(TOKEN0.balanceOf(address(this)), shares, totalSupply);
        amount1 = FullMath.mulDiv(TOKEN1.balanceOf(address(this)), shares, totalSupply);

        // Withdraw proportion of liquidity from Uniswap pool
        uint256 temp0;
        uint256 temp1;
        (temp0, temp1) = _uniswapExitFraction(shares, totalSupply, elastic);
        amount0 += temp0;
        amount1 += temp1;
        (temp0, temp1) = _uniswapExitFraction(shares, totalSupply, cushion);
        amount0 += temp0;
        amount1 += temp1;
        (temp0, temp1) = _uniswapExitFraction(shares, totalSupply, excess);
        amount0 += temp0;
        amount1 += temp1;

        // Check constraints
        require(amount0 >= amount0Min, "Aloe: amount0 too low");
        require(amount1 >= amount1Min, "Aloe: amount1 too low");

        // Transfer tokens
        if (amount0 != 0) TOKEN0.safeTransfer(msg.sender, amount0);
        if (amount1 != 0) TOKEN1.safeTransfer(msg.sender, amount1);

        // Burn shares
        _burn(msg.sender, shares);
        emit Withdraw(msg.sender, shares, amount0, amount1);
    }

    
    /// will be collected and left unused afterwards
    function _uniswapExitFraction(
        uint256 numerator,
        uint256 denominator,
        Ticks memory ticks
    ) internal returns (uint256 amount0, uint256 amount1) {
        assert(numerator < denominator);

        (uint128 liquidity, , , , ) = _position(ticks);
        liquidity = uint128(FullMath.mulDiv(liquidity, numerator, denominator));

        uint256 earned0;
        uint256 earned1;
        (amount0, amount1, earned0, earned1) = _uniswapExit(ticks, liquidity);

        // Add share of fees
        amount0 += FullMath.mulDiv(earned0, numerator, denominator);
        amount1 += FullMath.mulDiv(earned1, numerator, denominator);
    }

    function rebalance() external lock {
        require(allowRebalances, "Disabled");
        uint24 _epoch = PREDICTIONS.epoch();
        require(_epoch > epoch, "Aloe: Too early");

        // Update P.D.F from prediction market
        (pdf.isInverted, pdf.mean, pdf.sigmaL, pdf.sigmaU) = PREDICTIONS.current();
        epoch = _epoch;

        int24 tickSpacing = TICK_SPACING;
        (uint160 sqrtPriceX96, int24 tick, , , , , ) = UNI_POOL.slot0();

        // Exit all current Uniswap positions
        {
            (uint128 liquidityElastic, , , , ) = _position(elastic);
            (uint128 liquidityCushion, , , , ) = _position(cushion);
            (uint128 liquidityExcess, , , , ) = _position(excess);
            _uniswapExit(elastic, liquidityElastic);
            _uniswapExit(cushion, liquidityCushion);
            _uniswapExit(excess, liquidityExcess);
        }

        // Emit snapshot to record balances and supply
        uint256 balance0 = TOKEN0.balanceOf(address(this));
        uint256 balance1 = TOKEN1.balanceOf(address(this));
        emit Snapshot(tick, balance0, balance1, totalSupply());

        // Place elastic order on Uniswap
        Ticks memory elasticNew = _coerceTicksToSpacing(getNextElasticTicks());
        uint128 liquidity = _liquidityForAmounts(elasticNew, sqrtPriceX96, balance0, balance1);
        delete lastMintedAmount0;
        delete lastMintedAmount1;
        _uniswapEnter(elasticNew, liquidity);
        elastic = elasticNew;

        // Place excess order on Uniswap
        Ticks memory active = _coerceTicksToSpacing(Ticks(tick, tick));
        if (lastMintedAmount0 * balance1 < lastMintedAmount1 * balance0) {
            _placeExcessUpper(active, TOKEN0.balanceOf(address(this)), tickSpacing);
            didHaveExcessToken0 = true;
        } else {
            _placeExcessLower(active, TOKEN1.balanceOf(address(this)), tickSpacing);
            didHaveExcessToken0 = false;
        }
    }

    function shouldStretch() external view returns (bool) {
        Ticks memory elasticNew = _coerceTicksToSpacing(getNextElasticTicks());
        return elasticNew.lower != elastic.lower || elasticNew.upper != elastic.upper;
    }

    function stretch() external lock {
        require(allowRebalances, "Disabled");
        int24 tickSpacing = TICK_SPACING;
        (uint160 sqrtPriceX96, int24 tick, , , , , ) = UNI_POOL.slot0();

        // Check if stretching is necessary
        Ticks memory elasticNew = _coerceTicksToSpacing(getNextElasticTicks());
        require(elasticNew.lower != elastic.lower || elasticNew.upper != elastic.upper, "Aloe: Already stretched");

        // Exit previous elastic and cushion, and place as much value as possible in new elastic
        (uint256 elastic0, uint256 elastic1, , , uint256 available0, uint256 available1) =
            _exit2Enter1(sqrtPriceX96, elastic, cushion, elasticNew);
        elastic = elasticNew;

        // Place new cushion
        Ticks memory active = _coerceTicksToSpacing(Ticks(tick, tick));
        if (lastMintedAmount0 * elastic1 < lastMintedAmount1 * elastic0) {
            _placeCushionUpper(active, available0, tickSpacing);
        } else {
            _placeCushionLower(active, available1, tickSpacing);
        }
    }

    function snipe() external lock {
        require(allowRebalances, "Disabled");
        int24 tickSpacing = TICK_SPACING;
        (uint160 sqrtPriceX96, int24 tick, , , , uint8 feeProtocol, ) = UNI_POOL.slot0();

        (
            uint256 excess0,
            uint256 excess1,
            uint256 maxReward0,
            uint256 maxReward1,
            uint256 available0,
            uint256 available1
        ) = _exit2Enter1(sqrtPriceX96, excess, cushion, elastic);

        Ticks memory active = _coerceTicksToSpacing(Ticks(tick, tick));
        uint128 reward = UNI_FEE;

        if (didHaveExcessToken0) {
            // Reward caller
            if (feeProtocol >> 4 != 0) reward -= UNI_FEE / (feeProtocol >> 4);
            reward = (uint128(excess1) * reward) / 1e6;
            assert(reward <= maxReward1);
            if (reward != 0) TOKEN1.safeTransfer(msg.sender, reward);

            // Replace excess and cushion positions
            if (excess0 >= available0) {
                // We converted so much token0 to token1 that the cushion has to go
                // on the other side now
                _placeExcessUpper(active, available0, tickSpacing);
                _placeCushionLower(active, available1, tickSpacing);
            } else {
                // Both excess and cushion still have token0 to eat through
                _placeExcessUpper(active, excess0, tickSpacing);
                _placeCushionUpper(active, available0 - excess0, tickSpacing);
            }
        } else {
            // Reward caller
            if (feeProtocol % 16 != 0) reward -= UNI_FEE / (feeProtocol % 16);
            reward = (uint128(excess0) * reward) / 1e6;
            assert(reward <= maxReward0);
            if (reward != 0) TOKEN0.safeTransfer(msg.sender, reward);

            // Replace excess and cushion positions
            if (excess1 >= available1) {
                // We converted so much token1 to token0 that the cushion has to go
                // on the other side now
                _placeExcessLower(active, available1, tickSpacing);
                _placeCushionUpper(active, available0, tickSpacing);
            } else {
                // Both excess and cushion still have token1 to eat through
                _placeExcessLower(active, excess1, tickSpacing);
                _placeCushionLower(active, available1 - excess1, tickSpacing);
            }
        }
    }

    
    /// Position a must have non-zero liquidity.
    function _exit2Enter1(
        uint160 sqrtPriceX96,
        Ticks memory a,
        Ticks memory b,
        Ticks memory c
    )
        private
        returns (
            uint256 a0,
            uint256 a1,
            uint256 aEarned0,
            uint256 aEarned1,
            uint256 available0,
            uint256 available1
        )
    {
        // Exit position A
        (uint128 liquidity, , , , ) = _position(a);
        require(liquidity != 0, "Aloe: Expected liquidity");
        (a0, a1, aEarned0, aEarned1) = _uniswapExit(a, liquidity);

        // Exit position B if it exists
        uint256 b0;
        uint256 b1;
        (liquidity, , , , ) = _position(b);
        if (liquidity != 0) {
            (b0, b1, , ) = _uniswapExit(b, liquidity);
        }

        // Add to position c
        available0 = a0 + b0;
        available1 = a1 + b1;
        liquidity = _liquidityForAmounts(c, sqrtPriceX96, available0, available1);
        delete lastMintedAmount0;
        delete lastMintedAmount1;
        _uniswapEnter(c, liquidity);

        unchecked {
            available0 = available0 > lastMintedAmount0 ? available0 - lastMintedAmount0 : 0;
            available1 = available1 > lastMintedAmount1 ? available1 - lastMintedAmount1 : 0;
        }
    }

    function _placeCushionLower(
        Ticks memory active,
        uint256 balance1,
        int24 tickSpacing
    ) private {
        Ticks memory _cushion;
        (_cushion.lower, _cushion.upper) = (elastic.lower, active.lower);
        if (_cushion.lower == _cushion.upper) _cushion.lower -= tickSpacing;
        _uniswapEnter(_cushion, _liquidityForAmount1(_cushion, balance1));
        cushion = _cushion;
    }

    function _placeCushionUpper(
        Ticks memory active,
        uint256 balance0,
        int24 tickSpacing
    ) private {
        Ticks memory _cushion;
        (_cushion.lower, _cushion.upper) = (active.upper, elastic.upper);
        if (_cushion.lower == _cushion.upper) _cushion.upper += tickSpacing;
        _uniswapEnter(_cushion, _liquidityForAmount0(_cushion, balance0));
        cushion = _cushion;
    }

    function _placeExcessLower(
        Ticks memory active,
        uint256 balance1,
        int24 tickSpacing
    ) private {
        Ticks memory _excess;
        (_excess.lower, _excess.upper) = (active.lower - tickSpacing, active.lower);
        _uniswapEnter(_excess, _liquidityForAmount1(_excess, balance1));
        excess = _excess;
    }

    function _placeExcessUpper(
        Ticks memory active,
        uint256 balance0,
        int24 tickSpacing
    ) private {
        Ticks memory _excess;
        (_excess.lower, _excess.upper) = (active.upper, active.upper + tickSpacing);
        _uniswapEnter(_excess, _liquidityForAmount0(_excess, balance0));
        excess = _excess;
    }

    function _coerceTicksToSpacing(Ticks memory ticks) private view returns (Ticks memory ticksCoerced) {
        ticksCoerced.lower =
            ticks.lower -
            (ticks.lower < 0 ? TICK_SPACING + (ticks.lower % TICK_SPACING) : ticks.lower % TICK_SPACING);
        ticksCoerced.upper =
            ticks.upper +
            (ticks.upper < 0 ? -ticks.upper % TICK_SPACING : TICK_SPACING - (ticks.upper % TICK_SPACING));
        assert(ticksCoerced.lower <= ticks.lower);
        assert(ticksCoerced.upper >= ticks.upper);
    }
}
// 
pragma solidity ^0.8.0;
















interface ICHI {
    function mint(uint256 value) external;

    function freeUpTo(uint256 value) external returns (uint256);
}

contract Helper {
    using SafeERC20 for IERC20;

    address public constant CHI = 0x0000000000004946c0e9F43F4Dee607b0eF1fA1c;

    address public constant ALOE = 0xa10Ee8A7bFA188E762a7bc7169512222a621Fab4;

    address public constant MULTISIG = 0xf63ff43C9155F25E3272F2b092943333C3Db6308;

    AloePoolCapped public constant pool = AloePoolCapped(0xf5F30EaF55Fd9fFc70651b13b791410aAd663846);

    IAloePredictions public constant predictions = IAloePredictions(0x263C5BDFe39c48aDdE8362DC0Ec2BbD770A09c3a);

    IncentiveVault public constant incentives = IncentiveVault(0xec0c69449dBc79CB3483FC3e3A4285C8A2D3dD45);

    modifier discountCHI {
        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
        ICHI(CHI).freeUpTo((gasSpent + 14154) / 41947);
    }

    
    
    function shouldAdvance() public view returns (bool) {
        return uint32(block.timestamp) > predictions.epochExpectedEndTime();
    }

    
    function shouldRebalance() public view returns (bool) {
        return predictions.epoch() > pool.epoch();
    }

    
    function shouldStretch() public view returns (bool) {
        return pool.shouldStretch();
    }

    
    function wouldSnipeHaveImpact() public view returns (bool) {
        IUniswapV3Pool uniPool = pool.UNI_POOL();
        int24 tickSpacing = uniPool.tickSpacing();
        (, int24 tick, , , , , ) = uniPool.slot0();
        (int24 lower, int24 upper) = pool.excess();

        if (pool.didHaveExcessToken0()) {
            return tick < upper || tick - upper > tickSpacing;
        } else {
            return tick > lower || lower - tick > tickSpacing;
        }
    }

    
    function computeSnipeReward() public view returns (uint256 reward0, uint256 reward1) {
        IUniswapV3Pool uniPool = pool.UNI_POOL();
        (uint160 sqrtPriceX96, , , , , uint8 feeProtocol, ) = uniPool.slot0();

        (int24 lower, int24 upper) = pool.excess();
        (uint128 liquidity, , , , ) = uniPool.positions(keccak256(abi.encodePacked(address(pool), lower, upper)));
        (uint256 amount0, uint256 amount1) =
            LiquidityAmounts.getAmountsForLiquidity(
                sqrtPriceX96,
                TickMath.getSqrtRatioAtTick(lower),
                TickMath.getSqrtRatioAtTick(upper),
                liquidity
            );

        if (pool.didHaveExcessToken0()) {
            if (feeProtocol >> 4 != 0) reward1 -= uniPool.fee() / (feeProtocol >> 4);
            reward1 = (uint128(amount1) * reward1) / 1e6;
        } else {
            if (feeProtocol % 16 != 0) reward0 -= uniPool.fee() / (feeProtocol % 16);
            reward0 = (uint128(amount0) * reward0) / 1e6;
        }
    }

    function go() external discountCHI {
        if (shouldAdvance()) {
            try predictions.advance() {
                IERC20(ALOE).transfer(msg.sender, IERC20(ALOE).balanceOf(address(this)));
                return;
            } catch {}
        }

        if (shouldRebalance()) {
            pool.rebalance();
        } else if (shouldStretch()) {
            pool.stretch();
        } else {
            pool.snipe();
        }

        incentives.claimAdvanceIncentive(ALOE, msg.sender);
    }

    function sweep(IERC20 token, uint256 amount) external {
        token.safeTransfer(MULTISIG, amount);
    }
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
library SafeERC20 {
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
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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






library LiquidityAmounts {
    
    
    
    function toUint128(uint256 x) private pure returns (uint128 y) {
        require((y = uint128(x)) == x);
    }

    
    
    
    
    
    
    function getLiquidityForAmount0(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount0
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        uint256 intermediate = FullMath.mulDiv(sqrtRatioAX96, sqrtRatioBX96, FixedPoint96.Q96);
        return toUint128(FullMath.mulDiv(amount0, intermediate, sqrtRatioBX96 - sqrtRatioAX96));
    }

    
    
    
    
    
    
    function getLiquidityForAmount1(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        return toUint128(FullMath.mulDiv(amount1, FixedPoint96.Q96, sqrtRatioBX96 - sqrtRatioAX96));
    }

    
    /// pool prices and the prices at the tick boundaries
    
    
    
    
    
    
    function getLiquidityForAmounts(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount0,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            liquidity = getLiquidityForAmount0(sqrtRatioAX96, sqrtRatioBX96, amount0);
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            uint128 liquidity0 = getLiquidityForAmount0(sqrtRatioX96, sqrtRatioBX96, amount0);
            uint128 liquidity1 = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioX96, amount1);

            liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
        } else {
            liquidity = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioBX96, amount1);
        }
    }

    
    
    
    
    
    function getAmount0ForLiquidity(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return
            FullMath.mulDiv(
                uint256(liquidity) << FixedPoint96.RESOLUTION,
                sqrtRatioBX96 - sqrtRatioAX96,
                sqrtRatioBX96
            ) / sqrtRatioAX96;
    }

    
    
    
    
    
    function getAmount1ForLiquidity(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount1) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96);
    }

    
    /// pool prices and the prices at the tick boundaries
    
    
    
    
    
    
    function getAmountsForLiquidity(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            amount0 = getAmount0ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            amount0 = getAmount0ForLiquidity(sqrtRatioX96, sqrtRatioBX96, liquidity);
            amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioX96, liquidity);
        } else {
            amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
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
        require(absTick <= uint256(uint24(MAX_TICK)), "T");

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
        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, "R");
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
pragma solidity ^0.8.0;








interface IAloePredictions is
    IAloePredictionsActions,
    IAloePredictionsDerivedState,
    IAloePredictionsEvents,
    IAloePredictionsState
{

}

// 
pragma solidity ^0.8.0;

struct Ticks {
    // Lower tick of a Uniswap position
    int24 lower;
    // Upper tick of a Uniswap position
    int24 upper;
}

// 
pragma solidity ^0.8.0;






contract AloePoolCapped is AloePool {
    using SafeERC20 for IERC20;

    address public immutable MULTISIG;
    uint256 public maxTotalSupply = 100000000000000000000;

    constructor(address predictions, address multisig) AloePool(predictions) {
        MULTISIG = multisig;
    }

    modifier restricted() {
        require(msg.sender == MULTISIG, "Not authorized");
        _;
    }

    function deposit(
        uint256 amount0Max,
        uint256 amount1Max,
        uint256 amount0Min,
        uint256 amount1Min
    )
        public
        override
        lock
        returns (
            uint256 shares,
            uint256 amount0,
            uint256 amount1
        )
    {
        (shares, amount0, amount1) = super.deposit(amount0Max, amount1Max, amount0Min, amount1Min);
        require(totalSupply() <= maxTotalSupply, "Aloe: Pool already full");
    }

    /**
     * @notice Removes tokens accidentally sent to this vault.
     */
    function sweep(
        IERC20 token,
        uint256 amount,
        address to
    ) external restricted {
        require(token != TOKEN0 && token != TOKEN1, "Not sweepable");
        token.safeTransfer(to, amount);
    }

    /**
     * @notice Used to change deposit cap for a guarded launch or to ensure
     * vault doesn't grow too large relative to the UNI_POOL. Cap is on total
     * supply rather than amounts of TOKEN0 and TOKEN1 as those amounts
     * fluctuate naturally over time.
     */
    function setMaxTotalSupply(uint256 _maxTotalSupply) external restricted {
        maxTotalSupply = _maxTotalSupply;
    }

    function toggleRebalances() external restricted {
        allowRebalances = !allowRebalances;
    }

    function setK(uint48 _K) external restricted {
        K = _K;
    }
}

// 
pragma solidity ^0.8.0;




contract IncentiveVault {
    using SafeERC20 for IERC20;

    
    mapping(address => mapping(address => uint256)) public stakingIncentivesPerEpoch;

    
    mapping(address => mapping(address => uint256)) public advanceIncentives;

    
    mapping(bytes32 => bool) public claimed;

    address immutable multisig;

    constructor(address _multisig) {
        multisig = _multisig;
    }

    function getClaimHash(
        address market,
        uint40 key,
        address token
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(market, key, token));
    }

    function didClaim(
        address market,
        uint40 key,
        address token
    ) public view returns (bool) {
        return claimed[getClaimHash(market, key, token)];
    }

    function setClaimed(
        address market,
        uint40 key,
        address token
    ) private {
        claimed[getClaimHash(market, key, token)] = true;
    }

    function transfer(address to, address token) external {
        require(msg.sender == multisig, "Not authorized");
        IERC20(token).safeTransfer(to, IERC20(token).balanceOf(address(this)));
    }

    /**
     * @notice Allows owner to set staking incentive amounts on a per-token per-market basis
     * @param market The predictions market to incentivize
     * @param token The token in which incentives should be denominated
     * @param incentivePerEpoch The maximum number of tokens to give out each epoch
     */
    function setStakingIncentive(
        address market,
        address token,
        uint256 incentivePerEpoch
    ) external {
        require(msg.sender == multisig, "Not authorized");
        stakingIncentivesPerEpoch[market][token] = incentivePerEpoch;
    }

    /**
     * @notice Allows a predictions contract to claim staking incentives on behalf of a user
     * @dev Should only be called once per proposal. And fails if vault has insufficient
     * funds to make good on incentives
     * @param key The key of the proposal for which incentives are being claimed
     * @param tokens An array of tokens for which incentives should be claimed
     * @param to The user to whom incentives should be sent
     * @param reward The preALOE reward earned by the user
     * @param stakeTotal The total amount of preALOE staked in the pertinent epoch
     */
    function claimStakingIncentives(
        uint40 key,
        address[] calldata tokens,
        address to,
        uint80 reward,
        uint80 stakeTotal
    ) external {
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 incentivePerEpoch = stakingIncentivesPerEpoch[msg.sender][tokens[i]];
            if (incentivePerEpoch == 0) continue;

            if (didClaim(msg.sender, key, tokens[i])) continue;
            setClaimed(msg.sender, key, tokens[i]);

            IERC20(tokens[i]).safeTransfer(to, (incentivePerEpoch * uint256(reward)) / uint256(stakeTotal));
        }
    }

    /**
     * @notice Allows owner to set advance incentive amounts on a per-market basis
     * @param market The predictions market to incentivize
     * @param token The token in which incentives should be denominated
     * @param amount The number of tokens to give out on each `advance()`
     */
    function setAdvanceIncentive(
        address market,
        address token,
        uint80 amount
    ) external {
        require(msg.sender == multisig, "Not authorized");
        advanceIncentives[market][token] = amount;
    }

    /**
     * @notice Allows a predictions contract to claim advance incentives on behalf of a user
     * @param token The token for which incentive should be claimed
     * @param to The user to whom incentive should be sent
     */
    function claimAdvanceIncentive(address token, address to) external {
        uint256 amount = advanceIncentives[msg.sender][token];
        if (amount == 0) return;

        IERC20(token).safeTransfer(to, amount);
    }
}

// 

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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
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

// 
pragma solidity >=0.4.0;




library FixedPoint96 {
    uint8 internal constant RESOLUTION = 96;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
}

// 
pragma solidity >=0.4.0;




library FullMath {
    
    
    
    
    
    
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
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
            // https://ethereum.stackexchange.com/a/96646
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

    
    function mul512(uint256 a, uint256 b) internal pure returns (uint256 r0, uint256 r1) {
        assembly {
            let mm := mulmod(a, b, not(0))
            r0 := mul(a, b)
            r1 := sub(sub(mm, r0), lt(mm, r0))
        }
    }

    
    function square512(uint256 a) internal pure returns (uint256 r0, uint256 r1) {
        assembly {
            let mm := mulmod(a, a, not(0))
            r0 := mul(a, a)
            r1 := sub(sub(mm, r0), lt(mm, r0))
        }
    }

    
    function log2floor(uint256 x) internal pure returns (uint256 msb) {
        unchecked {
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
    }

    
    function log2ceil(uint256 x) internal pure returns (uint256 y) {
        assembly {
            let arg := x
            x := sub(x, 1)
            x := or(x, div(x, 0x02))
            x := or(x, div(x, 0x04))
            x := or(x, div(x, 0x10))
            x := or(x, div(x, 0x100))
            x := or(x, div(x, 0x10000))
            x := or(x, div(x, 0x100000000))
            x := or(x, div(x, 0x10000000000000000))
            x := or(x, div(x, 0x100000000000000000000000000000000))
            x := add(x, 1)
            let m := mload(0x40)
            mstore(m, 0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
            mstore(add(m, 0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
            mstore(add(m, 0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
            mstore(add(m, 0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
            mstore(add(m, 0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
            mstore(add(m, 0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
            mstore(add(m, 0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
            mstore(add(m, 0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
            mstore(0x40, add(m, 0x100))
            let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
            let shift := 0x100000000000000000000000000000000000000000000000000000000000000
            let a := div(mul(x, magic), shift)
            y := div(mload(add(m, sub(255, a))), shift)
            y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
        }
    }
}

// 
pragma solidity ^0.8.0;

struct Bounds {
    // Q128.48 price at tickLower of a Uniswap position
    uint176 lower;
    // Q128.48 price at tickUpper of a Uniswap position
    uint176 upper;
}

// 
pragma solidity ^0.8.0;




struct EpochSummary {
    Bounds groundTruth;
    Accumulators accumulators;
}

// 
pragma solidity ^0.8.0;

struct Proposal {
    // The address that submitted the proposal
    address source;
    // The epoch in which the proposal was submitted
    uint24 epoch;
    // Q128.48 price at tickLower of proposed Uniswap position
    uint176 lower;
    // Q128.48 price at tickUpper of proposed Uniswap position
    uint176 upper;
    // The amount of ALOE held; fits in uint80 because max supply is 1000000 with 18 decimals
    uint80 stake;
}

// 
pragma solidity ^0.8.0;



struct Accumulators {
    // The number of (proposals added - proposals removed) during the epoch
    uint40 proposalCount;
    // The total amount of ALOE staked; fits in uint80 because max supply is 1000000 with 18 decimals
    uint80 stakeTotal;
    // For the remaining properties, read comments as if `stake`, `lower`, and `upper` are NumPy arrays.
    // Each index represents a proposal, e.g. proposal 0 would be `(stake[0], lower[0], upper[0])`

    // `(stake * (upper - lower)).sum()`
    uint256 stake0thMomentRaw;
    // `lower.sum()`
    uint256 sumOfLowerBounds;
    // `(stake * lower).sum()`
    uint256 sumOfLowerBoundsWeighted;
    // `upper.sum()`
    uint256 sumOfUpperBounds;
    // `(stake * upper).sum()`
    uint256 sumOfUpperBoundsWeighted;
    // `(np.square(lower) + np.square(upper)).sum()`
    UINT512 sumOfSquaredBounds;
    // `(stake * (np.square(lower) + np.square(upper))).sum()`
    UINT512 sumOfSquaredBoundsWeighted;
}

// 
pragma solidity ^0.8.0;



struct UINT512 {
    // Least significant bits
    uint256 LS;
    // Most significant bits
    uint256 MS;
}

library UINT512Math {
    
    function iadd(
        UINT512 storage self,
        uint256 LS,
        uint256 MS
    ) internal {
        unchecked {
            if (self.LS > type(uint256).max - LS) {
                self.LS = addmod(self.LS, LS, type(uint256).max);
                self.MS += 1 + MS;
            } else {
                self.LS += LS;
                self.MS += MS;
            }
        }
    }

    
    function add(
        UINT512 memory self,
        uint256 LS,
        uint256 MS
    ) internal pure returns (uint256, uint256) {
        unchecked {
            return
                (self.LS > type(uint256).max - LS)
                    ? (addmod(self.LS, LS, type(uint256).max), self.MS + MS + 1)
                    : (self.LS + LS, self.MS + MS);
        }
    }

    
    function isub(
        UINT512 storage self,
        uint256 LS,
        uint256 MS
    ) internal {
        unchecked {
            if (self.LS < LS) {
                self.LS = type(uint256).max + self.LS - LS;
                self.MS -= 1 + MS;
            } else {
                self.LS -= LS;
                self.MS -= MS;
            }
        }
    }

    
    function sub(
        UINT512 memory self,
        uint256 LS,
        uint256 MS
    ) internal pure returns (uint256, uint256) {
        unchecked {
            return (self.LS < LS) ? (type(uint256).max + self.LS - LS, self.MS - MS - 1) : (self.LS - LS, self.MS - MS);
        }
    }

    
    function muls(UINT512 memory self, uint256 s) internal pure returns (uint256, uint256) {
        unchecked {
            self.MS *= s;
            (self.LS, s) = FullMath.mul512(self.LS, s);
            return (self.LS, self.MS + s);
        }
    }
}

// 
pragma solidity ^0.8.0;

library Math {
    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        unchecked {
            if (y > 3) {
                z = y;
                uint256 x = y / 2 + 1;
                while (x < z) {
                    z = x;
                    x = (y / x + x) / 2;
                }
            } else if (y != 0) {
                z = 1;
            }
        }
    }
}

// 
pragma solidity ^0.8.0;

interface IAloePredictionsImmutables {
    
    function NUM_PROPOSALS_TO_AGGREGATE() external view returns (uint8);

    
    function GROUND_TRUTH_STDDEV_SCALE() external view returns (uint256);

    
    function EPOCH_LENGTH_SECONDS() external view returns (uint32);

    
    function ALOE() external view returns (address);

    
    function UNI_POOL() external view returns (address);

    
    function INCENTIVE_VAULT() external view returns (address);
}

// 

pragma solidity ^0.8.0;

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
        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            // solhint-disable-next-line no-inline-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            // solhint-disable-next-line no-inline-assembly
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
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
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// 

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
}
