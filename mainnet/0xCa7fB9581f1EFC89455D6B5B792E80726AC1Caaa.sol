// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// 
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

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
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
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
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
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
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;







/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// 
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;




/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
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
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-FileCopyrightText: 2021 ShardLabs
// 
pragma solidity 0.8.7;











interface IStMATIC is IERC20Upgradeable {
    
    
    
    
    
    struct RequestWithdraw {
        uint256 amount2WithdrawFromStMATIC;
        uint256 validatorNonce;
        uint256 requestEpoch;
        address validatorAddress;
    }

    
    
    
    
    struct FeeDistribution {
        uint8 dao;
        uint8 operators;
        uint8 insurance;
    }

    
    function nodeOperatorRegistry()
        external
        view
        returns (INodeOperatorRegistry);

    
    
    
    
    function entityFees()
        external
        view
        returns (
            uint8,
            uint8,
            uint8
        );

    
    function stakeManager() external view returns (IStakeManager);

    
    function poLidoNFT() external view returns (IPoLidoNFT);

    
    function fxStateRootTunnel() external view returns (IFxStateRootTunnel);

    
    function version() external view returns (string memory);

    
    function dao() external view returns (address);

    
    function insurance() external view returns (address);

    
    function token() external view returns (address);

    
    function lastWithdrawnValidatorId() external view returns (uint256);

    
    function totalBuffered() external view returns (uint256);

    
    function delegationLowerBound() external view returns (uint256);

    
    function rewardDistributionLowerBound() external view returns (uint256);

    
    function reservedFunds() external view returns (uint256);

    
    function submitThreshold() external view returns (uint256);

    
    function submitHandler() external view returns (bool);

    
    function token2WithdrawRequest(uint256 _requestId)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            address
        );

    
    function DAO() external view returns (bytes32);

    
    function PAUSE_ROLE() external view returns (bytes32);

    
    function UNPAUSE_ROLE() external view returns (bytes32);

    
    function protocolFee() external view returns (uint8);

    
    
    
    
    
    
    
    function initialize(
        address _nodeOperatorRegistry,
        address _token,
        address _dao,
        address _insurance,
        address _stakeManager,
        address _poLidoNFT,
        address _fxStateRootTunnel
    ) external;

    
    
    
    
    function submit(uint256 _amount) external returns (uint256);

    
    
    function requestWithdraw(uint256 _amount) external;

    
    
    function delegate() external;

    
    /// StMATIC contract
    
    function claimTokens(uint256 _tokenId) external;

    
    /// in entityFee.
    function distributeRewards() external;

    
    
    function withdrawTotalDelegated(address _validatorShare) external;

    
    /// StMATIC contract
    
    function claimTokensFromValidatorToContract(uint256 _tokenId) external;

    
    /// more token delegated to them.
    function rebalanceDelegatedTokens() external;

    
    
    function getTotalStake(IValidatorShare _validatorShare)
        external
        view
        returns (uint256, uint256);

    
    
    
    function getLiquidRewards(IValidatorShare _validatorShare)
        external
        view
        returns (uint256);

    
    
    function getTotalStakeAcrossAllValidators() external view returns (uint256);

    
    
    function getTotalPooledMatic() external view returns (uint256);

    
    
    
    function getMaticFromTokenId(uint256 _tokenId)
        external
        view
        returns (uint256);

    
    /// stMatic contract.
    
    function calculatePendingBufferedTokens() external view returns(uint256);

    
    
    
    
    
    function convertStMaticToMatic(uint256 _amountInStMatic)
        external
        view
        returns (
            uint256 amountInMatic,
            uint256 totalStMaticAmount,
            uint256 totalPooledMatic
        );

    
    
    
    
    
    function convertMaticToStMatic(uint256 _amountInMatic)
        external
        view
        returns (
            uint256 amountInStMatic,
            uint256 totalStMaticSupply,
            uint256 totalPooledMatic
        );

    
    
    
    
    function setFees(
        uint8 _daoFee,
        uint8 _operatorsFee,
        uint8 _insuranceFee
    ) external;

    
    
    function setProtocolFee(uint8 _newProtocolFee) external;

    
    
    function setDaoAddress(address _newDaoAddress) external;

    
    
    function setInsuranceAddress(address _newInsuranceAddress) external;

    
    
    function setNodeOperatorRegistryAddress(address _newNodeOperatorRegistry)
        external;

    
    
    function setDelegationLowerBound(uint256 _delegationLowerBound) external;

    
    
    function setRewardDistributionLowerBound(
        uint256 _rewardDistributionLowerBound
    ) external;

    
    
    function setPoLidoNFT(address _poLidoNFT) external;

    
    
    function setFxStateRootTunnel(address _fxStateRootTunnel) external;

    
    
    function setVersion(string calldata _newVersion) external;

    ////////////////////////////////////////////////////////////
    /////                                                    ///
    /////                 ***EVENTS***                       ///
    /////                                                    ///
    ////////////////////////////////////////////////////////////

    
    
    
    event SubmitEvent(address indexed _from, uint256 indexed _amount);

    
    
    
    event RequestWithdrawEvent(address indexed _from, uint256 indexed _amount);

    
    
    event DistributeRewardsEvent(uint256 indexed _amount);

    
    
    
    event WithdrawTotalDelegatedEvent(
        address indexed _from,
        uint256 indexed _amount
    );

    
    
    
    event DelegateEvent(
        uint256 indexed _amountDelegated,
        uint256 indexed _remainder
    );

    
    
    
    
    
    event ClaimTokensEvent(
        address indexed _from,
        uint256 indexed _id,
        uint256 indexed _amountClaimed,
        uint256 _amountBurned
    );

    
    
    event SetInsuranceAddress(address indexed _newInsuranceAddress);

    
    
    event SetNodeOperatorRegistryAddress(
        address indexed _newNodeOperatorRegistryAddress
    );

    
    
    event SetDelegationLowerBound(uint256 indexed _delegationLowerBound);

    
    
    
    event SetRewardDistributionLowerBound(
        uint256 oldRewardDistributionLowerBound,
        uint256 newRewardDistributionLowerBound
    );

    
    
    
    event SetLidoNFT(address oldLidoNFT, address newLidoNFT);

    
    
    
    event SetFxStateRootTunnel(
        address oldFxStateRootTunnel,
        address newFxStateRootTunnel
    );

    
    
    
    event SetDaoAddress(address oldDaoAddress, address newDaoAddress);

    
    
    
    
    event SetFees(uint256 daoFee, uint256 operatorsFee, uint256 insuranceFee);

    
    
    
    event SetProtocolFee(uint8 oldProtocolFee, uint8 newProtocolFee);

    
    
    
    event ClaimTotalDelegatedEvent(
        address indexed validatorShare,
        uint256 indexed amountClaimed
    );

    
    
    
    event Version(
        string oldVersion,
        string indexed newVersion
    );
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}// SPDX-FileCopyrightText: 2021 ShardLabs
// 
pragma solidity 0.8.7;
















contract StMATIC is
    IStMATIC,
    ERC20Upgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    
    INodeOperatorRegistry public override nodeOperatorRegistry;

    
    FeeDistribution public override entityFees;

    
    IStakeManager public override stakeManager;

    
    IPoLidoNFT public override poLidoNFT;

    
    IFxStateRootTunnel public override fxStateRootTunnel;

    
    string public override version;

    
    address public override dao;

    
    address public override insurance;

    
    address public override token;

    
    uint256 public override lastWithdrawnValidatorId;

    
    uint256 public override totalBuffered;

    
    uint256 public override delegationLowerBound;

    
    uint256 public override rewardDistributionLowerBound;

    
    uint256 public override reservedFunds;

    
    uint256 public override submitThreshold;

    
    bool public override submitHandler;

    
    mapping(uint256 => RequestWithdraw) public override token2WithdrawRequest;

    
    bytes32 public constant override DAO = keccak256("DAO");
    bytes32 public constant override PAUSE_ROLE =
        keccak256("LIDO_PAUSE_OPERATOR");
    bytes32 public constant override UNPAUSE_ROLE =
        keccak256("LIDO_UNPAUSE_OPERATOR");

    
    /// to it. The request is stored inside this array.
    RequestWithdraw[] public stMaticWithdrawRequest;

    
    mapping(uint256 => RequestWithdraw[]) public token2WithdrawRequests;

    
    uint8 public override protocolFee;

    // @notice these state variable are used to mark entrance and exit form a contract function
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    
    modifier nonReentrant() {
        _nonReentrant();
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    
    
    
    
    
    
    
    function initialize(
        address _nodeOperatorRegistry,
        address _token,
        address _dao,
        address _insurance,
        address _stakeManager,
        address _poLidoNFT,
        address _fxStateRootTunnel
    ) external override initializer {
        __AccessControl_init_unchained();
        __Pausable_init_unchained();
        __ERC20_init_unchained("Staked MATIC", "stMATIC");

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DAO, _dao);
        _grantRole(PAUSE_ROLE, msg.sender);
        _grantRole(UNPAUSE_ROLE, _dao);

        nodeOperatorRegistry = INodeOperatorRegistry(_nodeOperatorRegistry);
        stakeManager = IStakeManager(_stakeManager);
        poLidoNFT = IPoLidoNFT(_poLidoNFT);
        fxStateRootTunnel = IFxStateRootTunnel(_fxStateRootTunnel);
        dao = _dao;
        token = _token;
        insurance = _insurance;

        entityFees = FeeDistribution(25, 50, 25);
    }

    
    
    
    
    function submit(uint256 _amount)
        external
        override
        whenNotPaused
        nonReentrant
        returns (uint256)
    {
        _require(_amount > 0, "Invalid amount");

        IERC20Upgradeable(token).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        (
            uint256 amountToMint,
            uint256 totalShares,
            uint256 totalPooledMatic
        ) = convertMaticToStMatic(_amount);

        _require(amountToMint > 0, "Mint ZERO");

        _mint(msg.sender, amountToMint);

        totalBuffered += _amount;

        fxStateRootTunnel.sendMessageToChild(
            abi.encode(totalShares + amountToMint, totalPooledMatic + _amount)
        );

        emit SubmitEvent(msg.sender, _amount);

        return amountToMint;
    }

    
    
    function requestWithdraw(uint256 _amount)
        external
        override
        whenNotPaused
        nonReentrant
    {
        _require(
            _amount > 0 && balanceOf(msg.sender) >= _amount,
            "Invalid amount"
        );

        (
            INodeOperatorRegistry.ValidatorData[] memory activeNodeOperators,
            uint256 totalDelegated,
            uint256 bigNodeOperatorLength,
            uint256[] memory bigNodeOperatorIds,
            uint256 smallNodeOperatorLength,
            uint256[] memory smallNodeOperatorIds,
            uint256[] memory allowedAmountToRequestFromOperators,
            uint256 totalValidatorsToWithdrawFrom
        ) = nodeOperatorRegistry.getValidatorsRequestWithdraw(_amount);

        uint256 totalPooledMatic = _getTotalPooledMatic(totalDelegated);
        uint256 totalAmount2WithdrawInMatic = _convertStMaticToMatic(
            _amount,
            totalPooledMatic
        );
        _require(totalAmount2WithdrawInMatic > 0, "Withdraw ZERO Matic");

        {
            uint256 localActiveBalance = totalBuffered > reservedFunds
                ? totalBuffered - reservedFunds
                : 0;
            uint256 liquidity = totalDelegated + localActiveBalance;
            _require(
                liquidity >= totalAmount2WithdrawInMatic,
                "Too much to withdraw"
            );
        }

        uint256 currentAmount2WithdrawInMatic = totalAmount2WithdrawInMatic;
        uint256 tokenId = poLidoNFT.mint(msg.sender);

        if (totalDelegated != 0) {
            if (totalValidatorsToWithdrawFrom != 0) {
                currentAmount2WithdrawInMatic = _requestWithdrawBalanced(
                    tokenId,
                    activeNodeOperators,
                    totalAmount2WithdrawInMatic,
                    totalValidatorsToWithdrawFrom,
                    totalDelegated,
                    currentAmount2WithdrawInMatic
                );
            } else {
                // request withdraw from big delegated validators
                currentAmount2WithdrawInMatic = _requestWithdrawUnbalanced(
                    tokenId,
                    activeNodeOperators,
                    bigNodeOperatorLength,
                    bigNodeOperatorIds,
                    allowedAmountToRequestFromOperators,
                    currentAmount2WithdrawInMatic
                );

                // request withdraw from small delegated validators
                if (currentAmount2WithdrawInMatic != 0) {
                    currentAmount2WithdrawInMatic = _requestWithdrawUnbalanced(
                        tokenId,
                        activeNodeOperators,
                        smallNodeOperatorLength,
                        smallNodeOperatorIds,
                        allowedAmountToRequestFromOperators,
                        currentAmount2WithdrawInMatic
                    );
                }
            }
        }

        if (_amount > totalDelegated) {
            token2WithdrawRequests[tokenId].push(
                RequestWithdraw(
                    currentAmount2WithdrawInMatic,
                    0,
                    stakeManager.epoch() + stakeManager.withdrawalDelay(),
                    address(0)
                )
            );
            reservedFunds += currentAmount2WithdrawInMatic;
            currentAmount2WithdrawInMatic = 0;
        }

        _burn(msg.sender, _amount);

        fxStateRootTunnel.sendMessageToChild(
            abi.encode(
                totalSupply(),
                totalPooledMatic - totalAmount2WithdrawInMatic
            )
        );

        emit RequestWithdrawEvent(msg.sender, _amount);
    }

    
    function _requestWithdrawBalanced(
        uint256 tokenId,
        INodeOperatorRegistry.ValidatorData[] memory activeNodeOperators,
        uint256 totalAmount2WithdrawInMatic,
        uint256 totalValidatorsToWithdrawFrom,
        uint256 totalDelegated,
        uint256 currentAmount2WithdrawInMatic
    ) private returns (uint256) {
        uint256 totalAmount = totalDelegated > totalAmount2WithdrawInMatic
            ? totalAmount2WithdrawInMatic
            : totalDelegated;
        uint256 amount2WithdrawFromValidator = totalAmount /
            totalValidatorsToWithdrawFrom;

        for (uint256 idx = 0; idx < totalValidatorsToWithdrawFrom; idx++) {
            address validatorShare = activeNodeOperators[idx].validatorShare;

            _require(
                _calculateValidatorShares(
                    validatorShare,
                    amount2WithdrawFromValidator
                ) > 0,
                "ZERO shares to withdraw"
            );

            currentAmount2WithdrawInMatic = _requestWithdraw(
                tokenId,
                validatorShare,
                amount2WithdrawFromValidator,
                currentAmount2WithdrawInMatic
            );
        }
        return currentAmount2WithdrawInMatic;
    }

    
    function _requestWithdrawUnbalanced(
        uint256 tokenId,
        INodeOperatorRegistry.ValidatorData[] memory activeNodeOperators,
        uint256 nodeOperatorLength,
        uint256[] memory nodeOperatorIds,
        uint256[] memory allowedAmountToRequestFromOperators,
        uint256 currentAmount2WithdrawInMatic
    ) private returns (uint256) {
        for (uint256 idx = 0; idx < nodeOperatorLength; idx++) {
            uint256 id = nodeOperatorIds[idx];
            uint256 amountCanBeRequested = allowedAmountToRequestFromOperators[
                id
            ];
            if (amountCanBeRequested == 0) continue;

            uint256 amount2WithdrawFromValidator = amountCanBeRequested >
                currentAmount2WithdrawInMatic
                ? currentAmount2WithdrawInMatic
                : allowedAmountToRequestFromOperators[id];

            address validatorShare = activeNodeOperators[id].validatorShare;

            _require(
                _calculateValidatorShares(
                    validatorShare,
                    amount2WithdrawFromValidator
                ) > 0,
                "ZERO shares to withdraw"
            );

            currentAmount2WithdrawInMatic = _requestWithdraw(
                tokenId,
                validatorShare,
                amount2WithdrawFromValidator,
                currentAmount2WithdrawInMatic
            );
            if (currentAmount2WithdrawInMatic == 0) break;
        }
        return currentAmount2WithdrawInMatic;
    }

    function _requestWithdraw(
        uint256 tokenId,
        address validatorShare,
        uint256 amount2WithdrawFromValidator,
        uint256 currentAmount2WithdrawInMatic
    ) private returns (uint256) {
        sellVoucher_new(
            validatorShare,
            amount2WithdrawFromValidator,
            type(uint256).max
        );

        token2WithdrawRequests[tokenId].push(
            RequestWithdraw(
                0,
                IValidatorShare(validatorShare).unbondNonces(address(this)),
                stakeManager.epoch() + stakeManager.withdrawalDelay(),
                validatorShare
            )
        );
        currentAmount2WithdrawInMatic -= amount2WithdrawFromValidator;
        return currentAmount2WithdrawInMatic;
    }

    
    
    function delegate() external override whenNotPaused nonReentrant {
        uint256 ltotalBuffered = totalBuffered;
        uint256 lreservedFunds = reservedFunds;
        _require(
            ltotalBuffered > delegationLowerBound + lreservedFunds,
            "Amount to delegate lower than minimum"
        );

        uint256 amountToDelegate = ltotalBuffered - lreservedFunds;

        (
            INodeOperatorRegistry.ValidatorData[]
                memory delegatableNodeOperators,
            uint256 totalDelegatableNodeOperators,
            uint256[] memory operatorRatios,
            uint256 totalRatio
        ) = nodeOperatorRegistry.getValidatorsDelegationAmount(
                amountToDelegate
            );

        uint256 remainder;
        uint256 amountDelegated;

        IERC20Upgradeable(token).safeApprove(address(stakeManager), 0);
        IERC20Upgradeable(token).safeApprove(
            address(stakeManager),
            amountToDelegate
        );

        for (uint256 i = 0; i < totalDelegatableNodeOperators; i++) {
            uint256 amountToDelegatePerOperator;

            // If the total Ratio is equal to ZERO that means the system is balanced so we
            // distribute the buffered tokens equally between the validators
            if (totalRatio == 0) {
                amountToDelegatePerOperator =
                    amountToDelegate /
                    totalDelegatableNodeOperators;
            } else {
                if (operatorRatios[i] == 0) continue;
                amountToDelegatePerOperator =
                    (operatorRatios[i] * amountToDelegate) /
                    totalRatio;
            }
            address _validatorAddress = delegatableNodeOperators[i]
                .validatorShare;

            uint256 shares = _calculateValidatorShares(
                _validatorAddress,
                amountToDelegatePerOperator
            );
            if (shares == 0) continue;

            buyVoucher(_validatorAddress, amountToDelegatePerOperator, 0);

            amountDelegated += amountToDelegatePerOperator;
        }

        remainder = amountToDelegate - amountDelegated;
        totalBuffered = remainder + lreservedFunds;

        emit DelegateEvent(amountDelegated, remainder);
    }

    
    /// user if his request is in the userToWithdrawRequest
    
    function claimTokens(uint256 _tokenId) external override whenNotPaused {
        _require(
            poLidoNFT.isApprovedOrOwner(msg.sender, _tokenId),
            "Not owner"
        );

        if (token2WithdrawRequest[_tokenId].requestEpoch != 0) {
            _claimTokensV1(_tokenId);
        } else if (token2WithdrawRequests[_tokenId].length != 0) {
            _claimTokensV2(_tokenId);
        } else {
            revert("Invalid claim token");
        }
    }

    
    function _claimTokensV2(uint256 _tokenId) private {
        RequestWithdraw[] memory usersRequest = token2WithdrawRequests[
            _tokenId
        ];
        _require(
            stakeManager.epoch() >= usersRequest[0].requestEpoch,
            "Not able to claim yet"
        );

        poLidoNFT.burn(_tokenId);
        uint256 length = usersRequest.length;
        uint256 amountToClaim;

        uint256 balanceBeforeClaim = IERC20Upgradeable(token).balanceOf(
            address(this)
        );

        for (uint256 idx = 0; idx < length; idx++) {
            if (usersRequest[idx].validatorAddress != address(0)) {
                unstakeClaimTokens_new(
                    usersRequest[idx].validatorAddress,
                    usersRequest[idx].validatorNonce
                );
            } else {
                uint256 _amountToClaim = usersRequest[idx]
                    .amount2WithdrawFromStMATIC;
                reservedFunds -= _amountToClaim;
                totalBuffered -= _amountToClaim;
                amountToClaim += _amountToClaim;
            }
        }

        amountToClaim +=
            IERC20Upgradeable(token).balanceOf(address(this)) -
            balanceBeforeClaim;

        IERC20Upgradeable(token).safeTransfer(msg.sender, amountToClaim);

        emit ClaimTokensEvent(msg.sender, _tokenId, amountToClaim, 0);
    }

    
    function _claimTokensV1(uint256 _tokenId) private {
        RequestWithdraw storage usersRequest = token2WithdrawRequest[_tokenId];

        _require(
            stakeManager.epoch() >= usersRequest.requestEpoch,
            "Not able to claim yet"
        );

        poLidoNFT.burn(_tokenId);

        uint256 amountToClaim;

        if (usersRequest.validatorAddress != address(0)) {
            uint256 balanceBeforeClaim = IERC20Upgradeable(token).balanceOf(
                address(this)
            );

            unstakeClaimTokens_new(
                usersRequest.validatorAddress,
                usersRequest.validatorNonce
            );

            amountToClaim =
                IERC20Upgradeable(token).balanceOf(address(this)) -
                balanceBeforeClaim;
        } else {
            amountToClaim = usersRequest.amount2WithdrawFromStMATIC;

            reservedFunds -= amountToClaim;
            totalBuffered -= amountToClaim;
        }

        IERC20Upgradeable(token).safeTransfer(msg.sender, amountToClaim);

        emit ClaimTokensEvent(msg.sender, _tokenId, amountToClaim, 0);
    }

    
    /// in entityFee.
    function distributeRewards() external override whenNotPaused nonReentrant {
        (
            INodeOperatorRegistry.ValidatorData[] memory operatorInfos,
            uint256 totalActiveOperatorInfos
        ) = nodeOperatorRegistry.listDelegatedNodeOperators();

        for (uint256 i = 0; i < totalActiveOperatorInfos; i++) {
            IValidatorShare validatorShare = IValidatorShare(
                operatorInfos[i].validatorShare
            );
            uint256 stMaticReward = validatorShare.getLiquidRewards(
                address(this)
            );
            uint256 rewardThreshold = validatorShare.minAmount();
            if (stMaticReward > rewardThreshold) {
                validatorShare.withdrawRewards();
            }
        }

        uint256 totalRewards = IERC20Upgradeable(token).balanceOf(
            address(this)
        ) - totalBuffered;

        uint256 protocolRewards = totalRewards * protocolFee / 100;

        _require(
            protocolRewards > rewardDistributionLowerBound,
            "Amount to distribute lower than minimum"
        );

        uint256 balanceBeforeDistribution = IERC20Upgradeable(token).balanceOf(
            address(this)
        );

        uint256 daoRewards = (protocolRewards * entityFees.dao) / 100;
        uint256 insuranceRewards = (protocolRewards * entityFees.insurance) / 100;
        uint256 operatorsRewards = (protocolRewards * entityFees.operators) / 100;
        uint256 operatorReward = operatorsRewards / totalActiveOperatorInfos;

        IERC20Upgradeable(token).safeTransfer(dao, daoRewards);
        IERC20Upgradeable(token).safeTransfer(insurance, insuranceRewards);

        for (uint256 i = 0; i < totalActiveOperatorInfos; i++) {
            IERC20Upgradeable(token).safeTransfer(
                operatorInfos[i].rewardAddress,
                operatorReward
            );
        }

        uint256 currentBalance = IERC20Upgradeable(token).balanceOf(
            address(this)
        );

        uint256 totalDistributed = balanceBeforeDistribution - currentBalance;

        // Add the remainder to totalBuffered
        totalBuffered = currentBalance;

        emit DistributeRewardsEvent(totalDistributed);
    }

    
    
    
    function withdrawTotalDelegated(address _validatorShare)
        external
        override
        nonReentrant
    {
        _require(
            msg.sender == address(nodeOperatorRegistry),
            "Not a node operator"
        );

        (uint256 stakedAmount, ) = getTotalStake(
            IValidatorShare(_validatorShare)
        );

        // Check if the validator has enough shares.
        uint256 shares = _calculateValidatorShares(
            _validatorShare,
            stakedAmount
        );
        if (shares == 0) {
            return;
        }

        _createWithdrawRequest(_validatorShare, stakedAmount);
        emit WithdrawTotalDelegatedEvent(_validatorShare, stakedAmount);
    }

    
    /// more token delegated to them.
    function rebalanceDelegatedTokens() external override onlyRole(DAO) {
        uint256 amountToReDelegate = totalBuffered -
            reservedFunds +
            calculatePendingBufferedTokens();
        (
            INodeOperatorRegistry.ValidatorData[] memory nodeOperators,
            uint256 totalActiveNodeOperator,
            uint256[] memory operatorRatios,
            uint256 totalRatio,
            uint256 totalToWithdraw
        ) = nodeOperatorRegistry.getValidatorsRebalanceAmount(
                amountToReDelegate
            );

        uint256 amountToWithdraw;
        address _validatorAddress;
        for (uint256 i = 0; i < totalActiveNodeOperator; i++) {
            if (operatorRatios[i] == 0) continue;

            amountToWithdraw =
                (operatorRatios[i] * totalToWithdraw) /
                totalRatio;
            if (amountToWithdraw == 0) continue;

            _validatorAddress = nodeOperators[i].validatorShare;
            uint256 shares = _calculateValidatorShares(
                _validatorAddress,
                amountToWithdraw
            );
            if (shares == 0) continue;

            _createWithdrawRequest(
                nodeOperators[i].validatorShare,
                amountToWithdraw
            );
        }
    }

    function _createWithdrawRequest(address _validatorShare, uint256 amount)
        private
    {
        sellVoucher_new(_validatorShare, amount, type(uint256).max);
        stMaticWithdrawRequest.push(
            RequestWithdraw(
                0,
                IValidatorShare(_validatorShare).unbondNonces(address(this)),
                stakeManager.epoch() + stakeManager.withdrawalDelay(),
                _validatorShare
            )
        );
    }

    
    
    function calculatePendingBufferedTokens()
        public
        view
        override
        returns (uint256 pendingBufferedTokens)
    {
        uint256 pendingWithdrawalLength = stMaticWithdrawRequest.length;

        for (uint256 i = 0; i < pendingWithdrawalLength; i++) {
            pendingBufferedTokens += _getMaticFromRequestData(
                stMaticWithdrawRequest[i]
            );
        }
        return pendingBufferedTokens;
    }

    
    function claimTokensFromValidatorToContract(uint256 _index)
        external
        override
        whenNotPaused
        nonReentrant
    {
        uint256 length = stMaticWithdrawRequest.length;
        _require(_index < length, "invalid index");
        RequestWithdraw memory lidoRequest = stMaticWithdrawRequest[_index];

        _require(
            stakeManager.epoch() >= lidoRequest.requestEpoch,
            "Not able to claim yet"
        );

        uint256 balanceBeforeClaim = IERC20Upgradeable(token).balanceOf(
            address(this)
        );

        unstakeClaimTokens_new(
            lidoRequest.validatorAddress,
            lidoRequest.validatorNonce
        );

        uint256 claimedAmount = IERC20Upgradeable(token).balanceOf(
            address(this)
        ) - balanceBeforeClaim;

        totalBuffered += claimedAmount;

        if (_index != length - 1 && length != 1) {
            stMaticWithdrawRequest[_index] = stMaticWithdrawRequest[length - 1];
        }
        stMaticWithdrawRequest.pop();

        fxStateRootTunnel.sendMessageToChild(
            abi.encode(totalSupply(), getTotalPooledMatic())
        );

        emit ClaimTotalDelegatedEvent(
            lidoRequest.validatorAddress,
            claimedAmount
        );
    }

    
    function pause() external onlyRole(PAUSE_ROLE) {
        _pause();
    }

    
    function unpause() external onlyRole(UNPAUSE_ROLE) {
        _unpause();
    }

    ////////////////////////////////////////////////////////////
    /////                                                    ///
    /////             ***ValidatorShare API***               ///
    /////                                                    ///
    ////////////////////////////////////////////////////////////

    
    function getTotalWithdrawRequest()
        public
        view
        returns (RequestWithdraw[] memory)
    {
        return stMaticWithdrawRequest;
    }

    
    
    
    
    
    function buyVoucher(
        address _validatorShare,
        uint256 _amount,
        uint256 _minSharesToMint
    ) private returns (uint256) {
        uint256 amountSpent = IValidatorShare(_validatorShare).buyVoucher(
            _amount,
            _minSharesToMint
        );

        return amountSpent;
    }

    
    
    
    function unstakeClaimTokens_new(
        address _validatorShare,
        uint256 _unbondNonce
    ) private {
        IValidatorShare(_validatorShare).unstakeClaimTokens_new(_unbondNonce);
    }

    
    
    
    
    function sellVoucher_new(
        address _validatorShare,
        uint256 _claimAmount,
        uint256 _maximumSharesToBurn
    ) private {
        IValidatorShare(_validatorShare).sellVoucher_new(
            _claimAmount,
            _maximumSharesToBurn
        );
    }

    
    
    
    function getTotalStake(IValidatorShare _validatorShare)
        public
        view
        override
        returns (uint256, uint256)
    {
        return _validatorShare.getTotalStake(address(this));
    }

    
    
    
    function getLiquidRewards(IValidatorShare _validatorShare)
        external
        view
        override
        returns (uint256)
    {
        return _validatorShare.getLiquidRewards(address(this));
    }

    ////////////////////////////////////////////////////////////
    /////                                                    ///
    /////            ***Helpers & Utilities***               ///
    /////                                                    ///
    ////////////////////////////////////////////////////////////

    
    
    function getTotalStakeAcrossAllValidators()
        public
        view
        override
        returns (uint256)
    {
        uint256 totalStake;
        (
            INodeOperatorRegistry.ValidatorData[] memory nodeOperators,
            uint256 operatorsLength
        ) = nodeOperatorRegistry.listWithdrawNodeOperators();

        for (uint256 i = 0; i < operatorsLength; i++) {
            (uint256 currValidatorShare, ) = getTotalStake(
                IValidatorShare(nodeOperators[i].validatorShare)
            );

            totalStake += currValidatorShare;
        }

        return totalStake;
    }

    
    
    function getTotalPooledMatic() public view override returns (uint256) {
        uint256 totalStaked = getTotalStakeAcrossAllValidators();
        return _getTotalPooledMatic(totalStaked);
    }

    function _getTotalPooledMatic(uint256 _totalStaked)
        private
        view
        returns (uint256)
    {
        return
            _totalStaked +
            totalBuffered +
            calculatePendingBufferedTokens() -
            reservedFunds;
    }

    
    
    
    
    
    function convertStMaticToMatic(uint256 _amountInStMatic)
        external
        view
        override
        returns (
            uint256 amountInMatic,
            uint256 totalStMaticAmount,
            uint256 totalPooledMatic
        )
    {
        totalStMaticAmount = totalSupply();
        uint256 totalPooledMATIC = getTotalPooledMatic();
        return (
            _convertStMaticToMatic(_amountInStMatic, totalPooledMATIC),
            totalStMaticAmount,
            totalPooledMATIC
        );
    }

    
    
    
    function _convertStMaticToMatic(
        uint256 _stMaticAmount,
        uint256 _totalPooledMatic
    ) private view returns (uint256) {
        uint256 totalStMaticSupply = totalSupply();
        totalStMaticSupply = totalStMaticSupply == 0 ? 1 : totalStMaticSupply;
        _totalPooledMatic = _totalPooledMatic == 0 ? 1 : _totalPooledMatic;
        uint256 amountInMatic = (_stMaticAmount * _totalPooledMatic) /
            totalStMaticSupply;
        return amountInMatic;
    }

    
    
    
    
    
    function convertMaticToStMatic(uint256 _amountInMatic)
        public
        view
        override
        returns (
            uint256 amountInStMatic,
            uint256 totalStMaticSupply,
            uint256 totalPooledMatic
        )
    {
        totalStMaticSupply = totalSupply();
        totalPooledMatic = getTotalPooledMatic();
        return (
            _convertMaticToStMatic(_amountInMatic, totalPooledMatic),
            totalStMaticSupply,
            totalPooledMatic
        );
    }

    function getToken2WithdrawRequests(uint256 _tokenId)
        external
        view
        returns (RequestWithdraw[] memory)
    {
        return token2WithdrawRequests[_tokenId];
    }

    
    
    
    function _convertMaticToStMatic(
        uint256 _maticAmount,
        uint256 _totalPooledMatic
    ) private view returns (uint256) {
        uint256 totalStMaticSupply = totalSupply();
        totalStMaticSupply = totalStMaticSupply == 0 ? 1 : totalStMaticSupply;
        _totalPooledMatic = _totalPooledMatic == 0 ? 1 : _totalPooledMatic;
        uint256 amountInStMatic = (_maticAmount * totalStMaticSupply) /
            _totalPooledMatic;
        return amountInStMatic;
    }

    ////////////////////////////////////////////////////////////
    /////                                                    ///
    /////                 ***Setters***                      ///
    /////                                                    ///
    ////////////////////////////////////////////////////////////

    
    
    
    
    
    function setFees(
        uint8 _daoFee,
        uint8 _operatorsFee,
        uint8 _insuranceFee
    ) external override onlyRole(DAO) {
        _require(
            _daoFee + _operatorsFee + _insuranceFee == 100,
            "sum(fee)!=100"
        );
        entityFees.dao = _daoFee;
        entityFees.operators = _operatorsFee;
        entityFees.insurance = _insuranceFee;

        emit SetFees(_daoFee, _operatorsFee, _insuranceFee);
    }

    
    
    function setProtocolFee(uint8 _newProtocolFee)
        external
        override
        onlyRole(DAO)
    {
        _require(
            _newProtocolFee > 0 && _newProtocolFee <= 100,
            "Invalid protcol fee"
        );
        uint8 oldProtocolFee = protocolFee;
        protocolFee = _newProtocolFee;

        emit SetProtocolFee(oldProtocolFee, _newProtocolFee);
    }

    
    
    
    function setDaoAddress(address _newDAO) external override onlyRole(DAO) {
        address oldDAO = dao;
        dao = _newDAO;
        emit SetDaoAddress(oldDAO, _newDAO);
    }

    
    
    
    function setInsuranceAddress(address _address)
        external
        override
        onlyRole(DAO)
    {
        insurance = _address;
        emit SetInsuranceAddress(_address);
    }

    
    
    
    function setNodeOperatorRegistryAddress(address _address)
        external
        override
        onlyRole(DAO)
    {
        nodeOperatorRegistry = INodeOperatorRegistry(_address);
        emit SetNodeOperatorRegistryAddress(_address);
    }

    
    
    
    function setDelegationLowerBound(uint256 _delegationLowerBound)
        external
        override
        onlyRole(DAO)
    {
        delegationLowerBound = _delegationLowerBound;
        emit SetDelegationLowerBound(_delegationLowerBound);
    }

    
    
    
    function setRewardDistributionLowerBound(
        uint256 _newRewardDistributionLowerBound
    ) external override onlyRole(DAO) {
        uint256 oldRewardDistributionLowerBound = rewardDistributionLowerBound;
        rewardDistributionLowerBound = _newRewardDistributionLowerBound;

        emit SetRewardDistributionLowerBound(
            oldRewardDistributionLowerBound,
            _newRewardDistributionLowerBound
        );
    }

    
    
    function setPoLidoNFT(address _newLidoNFT) external override onlyRole(DAO) {
        address oldPoLidoNFT = address(poLidoNFT);
        poLidoNFT = IPoLidoNFT(_newLidoNFT);
        emit SetLidoNFT(oldPoLidoNFT, _newLidoNFT);
    }

    
    
    function setFxStateRootTunnel(address _newFxStateRootTunnel)
        external
        override
        onlyRole(DAO)
    {
        address oldFxStateRootTunnel = address(fxStateRootTunnel);
        fxStateRootTunnel = IFxStateRootTunnel(_newFxStateRootTunnel);

        emit SetFxStateRootTunnel(oldFxStateRootTunnel, _newFxStateRootTunnel);
    }

    
    
    function setVersion(string calldata _newVersion)
        external
        override
        onlyRole(DAO)
    {
        emit Version(version, _newVersion);
        version = _newVersion;
    }

    
    
    function getMaticFromTokenId(uint256 _tokenId)
        external
        view
        override
        returns (uint256)
    {
        if (token2WithdrawRequest[_tokenId].requestEpoch != 0) {
            return _getMaticFromRequestData(token2WithdrawRequest[_tokenId]);
        } else if (token2WithdrawRequests[_tokenId].length != 0) {
            RequestWithdraw[] memory requestsData = token2WithdrawRequests[
                _tokenId
            ];
            uint256 totalMatic;
            for (uint256 idx = 0; idx < requestsData.length; idx++) {
                totalMatic += _getMaticFromRequestData(requestsData[idx]);
            }
            return totalMatic;
        }
        return 0;
    }

    function _getMaticFromRequestData(RequestWithdraw memory requestData)
        private
        view
        returns (uint256)
    {
        if (requestData.validatorAddress == address(0)) {
            return requestData.amount2WithdrawFromStMATIC;
        }
        IValidatorShare validatorShare = IValidatorShare(
            requestData.validatorAddress
        );
        uint256 exchangeRatePrecision = _getExchangeRatePrecision(
            validatorShare.validatorId()
        );
        uint256 withdrawExchangeRate = validatorShare.withdrawExchangeRate();
        IValidatorShare.DelegatorUnbond memory unbond = validatorShare
            .unbonds_new(address(this), requestData.validatorNonce);

        return (withdrawExchangeRate * unbond.shares) / exchangeRatePrecision;
    }

    function _nonReentrant() private view {
        _require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    }

    function _require(bool _condition, string memory _message) private pure {
        require(_condition, _message);
    }

    
    /// More details: https://github.com/maticnetwork/contracts/blob/v0.3.0-backport/contracts/staking/validatorShare/ValidatorShare.sol#L21
    /// https://github.com/maticnetwork/contracts/blob/v0.3.0-backport/contracts/staking/validatorShare/ValidatorShare.sol#L87
    function _getExchangeRatePrecision(uint256 _validatorId)
        private
        pure
        returns (uint256)
    {
        return _validatorId < 8 ? 100 : 10**29;
    }

    
    function _calculateValidatorShares(
        address _validatorAddress,
        uint256 _amountInMatic
    ) private view returns (uint256) {
        IValidatorShare validatorShare = IValidatorShare(_validatorAddress);
        uint256 exchangeRatePrecision = _getExchangeRatePrecision(
            validatorShare.validatorId()
        );
        uint256 rate = validatorShare.exchangeRate();
        return (_amountInMatic * exchangeRatePrecision) / rate;
    }
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
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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

// SPDX-FileCopyrightText: 2021 ShardLabs
// 
pragma solidity 0.8.7;




interface IValidatorShare {
    struct DelegatorUnbond {
        uint256 shares;
        uint256 withdrawEpoch;
    }

    function unbondNonces(address _address) external view returns (uint256);

    function activeAmount() external view returns (uint256);

    function validatorId() external view returns (uint256);

    function withdrawExchangeRate() external view returns (uint256);

    function withdrawRewards() external;

    function unstakeClaimTokens() external;

    function minAmount() external view returns (uint256);

    function getLiquidRewards(address user) external view returns (uint256);

    function delegation() external view returns (bool);

    function updateDelegation(bool _delegation) external;

    function buyVoucher(uint256 _amount, uint256 _minSharesToMint)
        external
        returns (uint256);

    function sellVoucher_new(uint256 claimAmount, uint256 maximumSharesToBurn)
        external;

    function unstakeClaimTokens_new(uint256 unbondNonce) external;

    function unbonds_new(address _address, uint256 _unbondNonce)
        external
        view
        returns (DelegatorUnbond memory);

    function getTotalStake(address user)
        external
        view
        returns (uint256, uint256);

    function owner() external view returns (address);

    function restake() external returns (uint256, uint256);

    function unlock() external;

    function lock() external;

    function drain(
        address token,
        address payable destination,
        uint256 amount
    ) external;

    function slash(uint256 _amount) external;

    function migrateOut(address user, uint256 amount) external;

    function migrateIn(address user, uint256 amount) external;

    function exchangeRate() external view returns (uint256);
}

// SPDX-FileCopyrightText: 2021 ShardLabs
// 
pragma solidity 0.8.7;




interface INodeOperatorRegistry {
    
    /// StakeManager statuses: https://github.com/maticnetwork/contracts/blob/v0.3.0-backport/contracts/staking/stakeManager/StakeManagerStorage.sol#L13
    /// ACTIVE: (validator.status == status.Active && validator.deactivationEpoch == 0)
    /// JAILED: (validator.status == status.Locked && validator.deactivationEpoch == 0)
    /// EJECTED: ((validator.status == status.Active || validator.status == status.Locked) && validator.deactivationEpoch != 0)
    /// UNSTAKED: (validator.status == status.Unstaked)
    enum NodeOperatorRegistryStatus {
        INACTIVE,
        ACTIVE,
        JAILED,
        EJECTED,
        UNSTAKED
    }

    
    
    
    
    
    
    
    struct FullNodeOperatorRegistry {
        uint256 validatorId;
        uint256 commissionRate;
        address validatorShare;
        address rewardAddress;
        bool delegation;
        NodeOperatorRegistryStatus status;
    }

    
    
    
    struct ValidatorData {
        address validatorShare;
        address rewardAddress;
    }

    
    /// ONLY DAO can execute this function.
    
    
    function addNodeOperator(uint256 validatorId, address rewardAddress)
        external;

    
    /// ONLY the owner of the node operator can call this function
    function exitNodeOperatorRegistry() external;

    
    /// ONLY DAO can execute this function.
    /// withdraw delegated tokens from it.
    
    function removeNodeOperator(uint256 validatorId) external;

    
    /// 1. If the commission of the Node Operator is less than the standard commission.
    /// 2. If the Node Operator is either Unstaked or Ejected.
    
    function removeInvalidNodeOperator(uint256 validatorId) external;

    
    /// ONLY DAO can call this function
    
    function setStMaticAddress(address newStMatic) external;

    
    /// ONLY Operator owner can call this function
    
    function setRewardAddress(address newRewardAddress) external;

    
    /// ONLY DAO can call this function
    
    /// a validator in the delegation process.
    function setDistanceThreshold(uint256 distanceThreshold) external;

    
    /// ONLY DAO can call this function
    
    function setMinRequestWithdrawRange(uint8 minRequestWithdrawRange) external;

    
    /// ONLY DAO can call this function
    
    /// withdraw from a validator per rebalance.
    function setMaxWithdrawPercentagePerRebalance(
        uint256 maxWithdrawPercentagePerRebalance
    ) external;

    
    
    function setVersion(string memory _newVersion) external;

    
    
    
    function listDelegatedNodeOperators()
        external
        view
        returns (ValidatorData[] memory, uint256);

    
    
    
    
    function listWithdrawNodeOperators()
        external
        view
        returns (ValidatorData[] memory, uint256);

    
    /// depending on if the system is balanced or not. If validators are in EJECTED or UNSTAKED
    /// status the function will revert.
    
    
    
    
    
    ///  It will be calculated if the system is not balanced.
    function getValidatorsDelegationAmount(uint256 amountToDelegate)
        external
        view
        returns (
            ValidatorData[] memory validators,
            uint256 totalActiveNodeOperator,
            uint256[] memory operatorRatios,
            uint256 totalRatio
        );

    
    /// buffered tokens. If validators are in EJECTED or UNSTAKED status the function will revert.
    /// If the system is balanced the function will revert.
    
    
    
    
    
    
    
    function getValidatorsRebalanceAmount(uint256 totalBuffered)
        external
        view
        returns (
            ValidatorData[] memory validators,
            uint256 totalActiveNodeOperator,
            uint256[] memory operatorRatios,
            uint256 totalRatio,
            uint256 totalToWithdraw
        );

    
    
    
    
    
    
    
    
    
    
    function getValidatorsRequestWithdraw(uint256 _withdrawAmount)
        external
        view
        returns (
            ValidatorData[] memory validators,
            uint256 totalDelegated,
            uint256 bigNodeOperatorLength,
            uint256[] memory bigNodeOperatorIds,
            uint256 smallNodeOperatorLength,
            uint256[] memory smallNodeOperatorIds,
            uint256[] memory operatorAmountCanBeRequested,
            uint256 totalValidatorToWithdrawFrom
        );

    
    
    
    function getNodeOperator(uint256 validatorId)
        external
        view
        returns (FullNodeOperatorRegistry memory operatorStatus);

    
    
    
    function getNodeOperator(address rewardAddress)
        external
        view
        returns (FullNodeOperatorRegistry memory operatorStatus);

    
    
    
    function getNodeOperatorStatus(uint256 validatorId)
        external
        view
        returns (NodeOperatorRegistryStatus operatorStatus);

    
    function getValidatorIds() external view returns (uint256[] memory);

    
    
    
    
    
    function getProtocolStats()
        external
        view
        returns (
            bool isBalanced,
            uint256 distanceThreshold,
            uint256 minAmount,
            uint256 maxAmount
        );

    
    
    
    
    
    
    function getStats()
        external
        view
        returns (
            uint256 inactiveNodeOperator,
            uint256 activeNodeOperator,
            uint256 jailedNodeOperator,
            uint256 ejectedNodeOperator,
            uint256 unstakedNodeOperator
        );

    ////////////////////////////////////////////////////////////
    /////                                                    ///
    /////                 ***EVENTS***                       ///
    /////                                                    ///
    ////////////////////////////////////////////////////////////

    
    
    
    event AddNodeOperator(uint256 validatorId, address rewardAddress);

    
    
    
    event RemoveNodeOperator(uint256 validatorId, address rewardAddress);

    
    
    
    event RemoveInvalidNodeOperator(uint256 validatorId, address rewardAddress);

    
    
    
    event SetStMaticAddress(address oldStMatic, address newStMatic);

    
    
    
    
    event SetRewardAddress(
        uint256 validatorId,
        address oldRewardAddress,
        address newRewardAddress
    );

    
    
    
    event SetDistanceThreshold(
        uint256 oldDistanceThreshold,
        uint256 newDistanceThreshold
    );

    
    
    
    event SetMinRequestWithdrawRange(
        uint8 oldMinRequestWithdrawRange,
        uint8 newMinRequestWithdrawRange
    );

    
    
    
    event SetMaxWithdrawPercentagePerRebalance(
        uint256 oldMaxWithdrawPercentagePerRebalance,
        uint256 newMaxWithdrawPercentagePerRebalance
    );

    
    
    
    event SetVersion(string oldVersion, string newVersion);

    
    
    
    event ExitNodeOperator(uint256 validatorId, address rewardAddress);
}

// SPDX-FileCopyrightText: 2021 ShardLabs
// 
pragma solidity 0.8.7;



interface IStakeManager {
    
    /// https://github.com/maticnetwork/contracts/blob/v0.3.0-backport/contracts/staking/stakeManager/StakeManagerStorage.sol
    enum Status {
        Inactive,
        Active,
        Locked,
        Unstaked
    }

    struct Validator {
        uint256 amount;
        uint256 reward;
        uint256 activationEpoch;
        uint256 deactivationEpoch;
        uint256 jailTime;
        address signer;
        address contractAddress;
        Status status;
        uint256 commissionRate;
        uint256 lastCommissionUpdate;
        uint256 delegatorsReward;
        uint256 delegatedAmount;
        uint256 initialRewardPerStake;
    }

    
    
    
    function getValidatorContract(uint256 validatorId)
        external
        view
        returns (address);

    
    function delegationDeposit(
        uint256 validatorId,
        uint256 amount,
        address delegator
    ) external returns (bool);

    function epoch() external view returns (uint256);

    function validators(uint256 _index)
        external
        view
        returns (Validator memory);

    
    function withdrawalDelay() external  view returns (uint256);
}

// SPDX-FileCopyrightText: 2021 ShardLabs
// 
pragma solidity 0.8.7;





interface IPoLidoNFT is IERC721Upgradeable {
    
    
    
    
    function mint(address _to) external returns (uint256);

    
    
    function burn(uint256 _tokenId) external;

    
    
    
    
    function isApprovedOrOwner(address _spender, uint256 _tokenId)
        external
        view
        returns (bool);

    
    
    function setStMATIC(address _stMATIC) external;

    
    
    
    function getOwnedTokens(address _owner) external view returns (uint256[] memory);

    
    function togglePause() external;

    
    
    function setVersion(string calldata _newVersion) external;
}

// SPDX-FileCopyrightText: 2021 ShardLabs
// 
pragma solidity 0.8.7;

interface IFxStateRootTunnel {

    
    
    function sendMessageToChild(bytes memory _message) external;

    
    
    function setStMATIC(address _newStMATIC) external;
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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}
