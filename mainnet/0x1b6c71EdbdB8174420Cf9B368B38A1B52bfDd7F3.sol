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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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











contract NodeOperatorRegistry is
    INodeOperatorRegistry,
    PausableUpgradeable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable
{
    
    IStakeManager public stakeManager;

    
    IStMATIC public stMATIC;

    
    string public version;

    
    bytes32 public constant DAO_ROLE = keccak256("LIDO_DAO");
    bytes32 public constant PAUSE_ROLE = keccak256("LIDO_PAUSE_OPERATOR");
    bytes32 public constant UNPAUSE_ROLE = keccak256("LIDO_UNPAUSE_OPERATOR");
    bytes32 public constant ADD_NODE_OPERATOR_ROLE =
        keccak256("ADD_NODE_OPERATOR_ROLE");
    bytes32 public constant REMOVE_NODE_OPERATOR_ROLE =
        keccak256("REMOVE_NODE_OPERATOR_ROLE");

    
    uint256 public DISTANCE_THRESHOLD_PERCENTS;

    
    uint256 public MAX_WITHDRAW_PERCENTAGE_PER_REBALANCE;

    
    /// when the system is balanced.
    uint8 public MIN_REQUEST_WITHDRAW_RANGE_PERCENTS;

    
    uint256[] public validatorIds;

    
    /// extend the struct.
    mapping(uint256 => address) public validatorIdToRewardAddress;

    
    /// extend the struct.
    mapping(address => uint256) public validatorRewardAddressToId;

    
    function initialize(
        IStakeManager _stakeManager,
        IStMATIC _stMATIC,
        address _dao
    ) external initializer {
        __Pausable_init_unchained();
        __AccessControl_init_unchained();
        __ReentrancyGuard_init_unchained();

        stakeManager = _stakeManager;
        stMATIC = _stMATIC;

        DISTANCE_THRESHOLD_PERCENTS = 120;
        MAX_WITHDRAW_PERCENTAGE_PER_REBALANCE = 20;
        MIN_REQUEST_WITHDRAW_RANGE_PERCENTS = 15;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSE_ROLE, msg.sender);
        _grantRole(UNPAUSE_ROLE, _dao);
        _grantRole(DAO_ROLE, _dao);
        _grantRole(ADD_NODE_OPERATOR_ROLE, _dao);
        _grantRole(REMOVE_NODE_OPERATOR_ROLE, _dao);
        version = "2.0.0";
    }

    
    /// ONLY ADD_NODE_OPERATOR_ROLE can execute this function.
    
    
    function addNodeOperator(uint256 _validatorId, address _rewardAddress)
        external
        override
        onlyRole(ADD_NODE_OPERATOR_ROLE)
        nonReentrant
    {
        require(_validatorId != 0, "ValidatorId=0");
        require(
            validatorIdToRewardAddress[_validatorId] == address(0),
            "Validator exists"
        );
        require(
            validatorRewardAddressToId[_rewardAddress] == 0,
            "Reward Address already used"
        );
        require(_rewardAddress != address(0), "Invalid reward address");

        IStakeManager.Validator memory validator = stakeManager.validators(
            _validatorId
        );

        require(
            validator.status == IStakeManager.Status.Active &&
                validator.deactivationEpoch == 0,
            "Validator isn't ACTIVE"
        );

        require(
            validator.contractAddress != address(0),
            "Validator has no ValidatorShare"
        );

        require(
            IValidatorShare(validator.contractAddress).delegation(),
            "Delegation is disabled"
        );

        validatorIdToRewardAddress[_validatorId] = _rewardAddress;
        validatorRewardAddressToId[_rewardAddress] = _validatorId;
        validatorIds.push(_validatorId);

        emit AddNodeOperator(_validatorId, _rewardAddress);
    }

    
    /// ONLY the owner of the node operator can call this function
    function exitNodeOperatorRegistry() external override nonReentrant {
        uint256 validatorId = validatorRewardAddressToId[msg.sender];
        address rewardAddress = validatorIdToRewardAddress[validatorId];
        require(rewardAddress == msg.sender, "Unauthorized");

        IStakeManager.Validator memory validator = stakeManager.validators(
            validatorId
        );
        _removeOperator(validatorId, validator.contractAddress, rewardAddress);
        emit ExitNodeOperator(validatorId, rewardAddress);
    }

    
    /// ONLY DAO can execute this function.
    /// withdraw delegated tokens from it.
    
    function removeNodeOperator(uint256 _validatorId)
        external
        override
        onlyRole(REMOVE_NODE_OPERATOR_ROLE)
        nonReentrant
    {
        address rewardAddress = validatorIdToRewardAddress[_validatorId];
        require(rewardAddress != address(0), "Validator doesn't exist");

        IStakeManager.Validator memory validator = stakeManager.validators(
            _validatorId
        );

        _removeOperator(_validatorId, validator.contractAddress, rewardAddress);

        emit RemoveNodeOperator(_validatorId, rewardAddress);
    }

    
    /// If the Node Operator is either Unstaked or Ejected.
    
    function removeInvalidNodeOperator(uint256 _validatorId)
        external
        override
        whenNotPaused
        nonReentrant
    {
        (
            NodeOperatorRegistryStatus operatorStatus,
            IStakeManager.Validator memory validator
        ) = _getOperatorStatusAndValidator(_validatorId);

        require(
            operatorStatus == NodeOperatorRegistryStatus.UNSTAKED ||
                operatorStatus == NodeOperatorRegistryStatus.EJECTED,
            "Cannot remove valid operator."
        );
        address rewardAddress = validatorIdToRewardAddress[_validatorId];

        _removeOperator(_validatorId, validator.contractAddress, rewardAddress);

        emit RemoveInvalidNodeOperator(_validatorId, rewardAddress);
    }

    function _removeOperator(
        uint256 _validatorId,
        address _contractAddress,
        address _rewardAddress
    ) private {
        uint256 length = validatorIds.length;
        for (uint256 idx = 0; idx < length - 1; idx++) {
            if (_validatorId == validatorIds[idx]) {
                validatorIds[idx] = validatorIds[validatorIds.length - 1];
                break;
            }
        }
        validatorIds.pop();
        stMATIC.withdrawTotalDelegated(_contractAddress);
        delete validatorIdToRewardAddress[_validatorId];
        delete validatorRewardAddressToId[_rewardAddress];
    }

    ////////////////////////////////////////////////////////////
    /////                                                    ///
    /////                 ***Setters***                      ///
    /////                                                    ///
    ////////////////////////////////////////////////////////////

    
    /// ONLY DAO can call this function
    
    function setStMaticAddress(address _newStMatic)
        external
        override
        onlyRole(DAO_ROLE)
    {
        require(_newStMatic != address(0), "Invalid stMatic address");

        address oldStMATIC = address(stMATIC);
        stMATIC = IStMATIC(_newStMatic);

        emit SetStMaticAddress(oldStMATIC, _newStMatic);
    }

    
    /// ONLY Operator owner can call this function
    
    function setRewardAddress(address _newRewardAddress)
        external
        override
        whenNotPaused
    {
        uint256 validatorId = validatorRewardAddressToId[msg.sender];
        address oldRewardAddress = validatorIdToRewardAddress[validatorId];
        require(oldRewardAddress == msg.sender, "Unauthorized");
        require(_newRewardAddress != address(0), "Invalid reward address");

        validatorIdToRewardAddress[validatorId] = _newRewardAddress;
        validatorRewardAddressToId[_newRewardAddress] = validatorId;
        delete validatorRewardAddressToId[msg.sender];

        emit SetRewardAddress(validatorId, oldRewardAddress, _newRewardAddress);
    }

    
    /// ONLY DAO can call this function
    
    /// a validator in the delegation process.
    function setDistanceThreshold(uint256 _newDistanceThreshold)
        external
        override
        onlyRole(DAO_ROLE)
    {
        require(_newDistanceThreshold >= 100, "Invalid distance threshold");
        uint256 _oldDistanceThreshold = DISTANCE_THRESHOLD_PERCENTS;
        DISTANCE_THRESHOLD_PERCENTS = _newDistanceThreshold;

        emit SetDistanceThreshold(_oldDistanceThreshold, _newDistanceThreshold);
    }

    
    /// ONLY DAO can call this function
    
    function setMinRequestWithdrawRange(
        uint8 _newMinRequestWithdrawRangePercents
    ) external override onlyRole(DAO_ROLE) {
        require(
            _newMinRequestWithdrawRangePercents <= 100,
            "Invalid minRequestWithdrawRange"
        );
        uint8 _oldMinRequestWithdrawRange = MIN_REQUEST_WITHDRAW_RANGE_PERCENTS;
        MIN_REQUEST_WITHDRAW_RANGE_PERCENTS = _newMinRequestWithdrawRangePercents;

        emit SetMinRequestWithdrawRange(
            _oldMinRequestWithdrawRange,
            _newMinRequestWithdrawRangePercents
        );
    }

    
    /// ONLY DAO can call this function
    
    /// withdraw from a validator per rebalance.
    function setMaxWithdrawPercentagePerRebalance(
        uint256 _newMaxWithdrawPercentagePerRebalance
    ) external override onlyRole(DAO_ROLE) {
        require(
            _newMaxWithdrawPercentagePerRebalance <= 100,
            "Invalid maxWithdrawPercentagePerRebalance"
        );
        uint256 _oldMaxWithdrawPercentagePerRebalance = MAX_WITHDRAW_PERCENTAGE_PER_REBALANCE;
        MAX_WITHDRAW_PERCENTAGE_PER_REBALANCE = _newMaxWithdrawPercentagePerRebalance;

        emit SetMaxWithdrawPercentagePerRebalance(
            _oldMaxWithdrawPercentagePerRebalance,
            _newMaxWithdrawPercentagePerRebalance
        );
    }

    
    
    function setVersion(string memory _newVersion)
        external
        override
        onlyRole(DAO_ROLE)
    {
        string memory oldVersion = version;
        version = _newVersion;
        emit SetVersion(oldVersion, _newVersion);
    }

    
    function pause() external onlyRole(PAUSE_ROLE) {
        _pause();
    }

    
    function unpause() external onlyRole(UNPAUSE_ROLE) {
        _unpause();
    }

    ////////////////////////////////////////////////////////////
    /////                                                    ///
    /////                 ***Getters***                      ///
    /////                                                    ///
    ////////////////////////////////////////////////////////////

    
    
    
    function listDelegatedNodeOperators()
        external
        view
        override
        returns (ValidatorData[] memory, uint256)
    {
        uint256 totalActiveNodeOperators = 0;
        IStakeManager.Validator memory validator;
        NodeOperatorRegistryStatus operatorStatus;
        ValidatorData[] memory activeValidators = new ValidatorData[](validatorIds.length);

        for (uint256 i = 0; i < validatorIds.length; i++) {
            (operatorStatus, validator) = _getOperatorStatusAndValidator(
                validatorIds[i]
            );
            if (operatorStatus == NodeOperatorRegistryStatus.ACTIVE) {
                if (!IValidatorShare(validator.contractAddress).delegation())
                    continue;

                activeValidators[totalActiveNodeOperators] = ValidatorData(
                    validator.contractAddress,
                    validatorIdToRewardAddress[validatorIds[i]]
                );
                totalActiveNodeOperators++;
            }
        }
        return (activeValidators, totalActiveNodeOperators);
    }

    
    /// includes ACTIVE, JAILED, ejected, and UNSTAKED operators.
    
    
    function listWithdrawNodeOperators()
        external
        view
        override
        returns (ValidatorData[] memory, uint256)
    {
        uint256 totalNodeOperators = 0;
        uint256[] memory memValidatorIds = validatorIds;
        uint256 length = memValidatorIds.length;
        IStakeManager.Validator memory validator;
        NodeOperatorRegistryStatus operatorStatus;
        ValidatorData[] memory withdrawValidators = new ValidatorData[](length);

        for (uint256 i = 0; i < length; i++) {
            (operatorStatus, validator) = _getOperatorStatusAndValidator(
                memValidatorIds[i]
            );
            if (operatorStatus == NodeOperatorRegistryStatus.INACTIVE) continue;

            validator = stakeManager.validators(memValidatorIds[i]);
            withdrawValidators[totalNodeOperators] = ValidatorData(
                validator.contractAddress,
                validatorIdToRewardAddress[memValidatorIds[i]]
            );
            totalNodeOperators++;
        }

        return (withdrawValidators, totalNodeOperators);
    }

    
    
    
    
    
    
    function _getValidatorsDelegationInfos()
        private
        view
        returns (
            ValidatorData[] memory validators,
            uint256 activeOperatorCount,
            uint256[] memory stakePerOperator,
            uint256 totalStaked,
            uint256 distanceThreshold
        )
    {
        uint256 length = validatorIds.length;
        validators = new ValidatorData[](length);
        stakePerOperator = new uint256[](length);

        uint256 validatorId;
        IStakeManager.Validator memory validator;
        NodeOperatorRegistryStatus status;

        uint256 maxAmount;
        uint256 minAmount;

        for (uint256 i = 0; i < length; i++) {
            validatorId = validatorIds[i];
            (status, validator) = _getOperatorStatusAndValidator(validatorId);
            if (status == NodeOperatorRegistryStatus.INACTIVE) continue;

            require(
                !(status == NodeOperatorRegistryStatus.EJECTED),
                "Could not calculate the stake data, an operator was EJECTED"
            );

            require(
                !(status == NodeOperatorRegistryStatus.UNSTAKED),
                "Could not calculate the stake data, an operator was UNSTAKED"
            );

            // Get the total staked tokens by the StMatic contract in a validatorShare.
            (uint256 amount, ) = IValidatorShare(validator.contractAddress)
                .getTotalStake(address(stMATIC));

            totalStaked += amount;

            if (maxAmount < amount) {
                maxAmount = amount;
            }

            if (minAmount > amount || minAmount == 0) {
                minAmount = amount;
            }

            bool isDelegationEnabled = IValidatorShare(
                validator.contractAddress
            ).delegation();

            if (
                status == NodeOperatorRegistryStatus.ACTIVE &&
                isDelegationEnabled
            ) {
                stakePerOperator[activeOperatorCount] = amount;

                validators[activeOperatorCount] = ValidatorData(
                    validator.contractAddress,
                    validatorIdToRewardAddress[validatorIds[i]]
                );

                activeOperatorCount++;
            }
        }

        require(activeOperatorCount > 0, "There are no active validator");

        // The max amount is multiplied by 100 to have a precise value.
        minAmount = minAmount == 0 ? 1 : minAmount;
        distanceThreshold = ((maxAmount * 100) / minAmount);
    }

    
    /// depending on if the system is balanced or not. If validators are in EJECTED or UNSTAKED
    /// status the function will revert.
    
    
    
    
    
    ///  It will be calculated if the system is not balanced.
    function getValidatorsDelegationAmount(uint256 _amountToDelegate)
        external
        view
        override
        returns (
            ValidatorData[] memory validators,
            uint256 totalActiveNodeOperator,
            uint256[] memory operatorRatios,
            uint256 totalRatio
        )
    {
        require(validatorIds.length > 0, "Not enough operators to delegate");
        uint256[] memory stakePerOperator;
        uint256 totalStaked;
        uint256 distanceThreshold;
        (
            validators,
            totalActiveNodeOperator,
            stakePerOperator,
            totalStaked,
            distanceThreshold
        ) = _getValidatorsDelegationInfos();

        uint256 distanceThresholdPercents = DISTANCE_THRESHOLD_PERCENTS;
        bool isTheSystemBalanced = distanceThreshold <=
            distanceThresholdPercents;
        if (isTheSystemBalanced) {
            return (
                validators,
                totalActiveNodeOperator,
                operatorRatios,
                totalRatio
            );
        }

        // If the system is not balanced calculate ratios
        operatorRatios = new uint256[](totalActiveNodeOperator);
        uint256 rebalanceTarget = (totalStaked + _amountToDelegate) /
            totalActiveNodeOperator;

        uint256 operatorRatioToDelegate;

        for (uint256 idx = 0; idx < totalActiveNodeOperator; idx++) {
            operatorRatioToDelegate = stakePerOperator[idx] >= rebalanceTarget
                ? 0
                : rebalanceTarget - stakePerOperator[idx];

            if (operatorRatioToDelegate != 0 && stakePerOperator[idx] != 0) {
                operatorRatioToDelegate = (rebalanceTarget * 100) /
                    stakePerOperator[idx] >=
                    distanceThresholdPercents
                    ? operatorRatioToDelegate
                    : 0;
            }

            operatorRatios[idx] = operatorRatioToDelegate;
            totalRatio += operatorRatioToDelegate;
        }
    }

    
    /// buffered tokens. If validators are in EJECTED or UNSTAKED status the function will revert.
    /// If the system is balanced the function will revert.
    
    
    
    
    
    
    
    function getValidatorsRebalanceAmount(uint256 _amountToReDelegate)
        external
        view
        override
        returns (
            ValidatorData[] memory validators,
            uint256 totalActiveNodeOperator,
            uint256[] memory operatorRatios,
            uint256 totalRatio,
            uint256 totalToWithdraw
        )
    {
        require(validatorIds.length > 1, "Not enough operator to rebalance");
        uint256[] memory stakePerOperator;
        uint256 totalStaked;
        uint256 distanceThreshold;
        (
            validators,
            totalActiveNodeOperator,
            stakePerOperator,
            totalStaked,
            distanceThreshold
        ) = _getValidatorsDelegationInfos();

        require(
            totalActiveNodeOperator > 1,
            "Not enough active operators to rebalance"
        );

        uint256 distanceThresholdPercents = DISTANCE_THRESHOLD_PERCENTS;
        require(
            distanceThreshold >= distanceThresholdPercents && totalStaked > 0,
            "The system is balanced"
        );

        operatorRatios = new uint256[](totalActiveNodeOperator);
        uint256 rebalanceTarget = totalStaked / totalActiveNodeOperator;
        uint256 operatorRatioToRebalance;

        for (uint256 idx = 0; idx < totalActiveNodeOperator; idx++) {
            operatorRatioToRebalance = stakePerOperator[idx] > rebalanceTarget
                ? stakePerOperator[idx] - rebalanceTarget
                : 0;

            operatorRatioToRebalance = (stakePerOperator[idx] * 100) /
                rebalanceTarget >=
                distanceThresholdPercents
                ? operatorRatioToRebalance
                : 0;

            operatorRatios[idx] = operatorRatioToRebalance;
            totalRatio += operatorRatioToRebalance;
        }
        totalToWithdraw = totalRatio > _amountToReDelegate
            ? totalRatio - _amountToReDelegate
            : 0;

        totalToWithdraw =
            (totalToWithdraw * MAX_WITHDRAW_PERCENTAGE_PER_REBALANCE) /
            100;
        require(totalToWithdraw > 0, "Zero total to withdraw");
    }

    
    
    
    
    
    
    function _getValidatorsRequestWithdraw()
        private
        view
        returns (
            ValidatorData[] memory nonInactiveValidators,
            uint256[] memory stakePerOperator,
            uint256 totalDelegated,
            uint256 minAmount,
            uint256 maxAmount
        )
    {
        uint256 length = validatorIds.length;
        nonInactiveValidators = new ValidatorData[](length);
        stakePerOperator = new uint256[](length);

        uint256 validatorId;
        IStakeManager.Validator memory validator;

        for (uint256 i = 0; i < length; i++) {
            validatorId = validatorIds[i];
            (, validator) = _getOperatorStatusAndValidator(validatorId);

            // Get the total staked tokens by the StMatic contract in a validatorShare.
            (uint256 amount, ) = IValidatorShare(validator.contractAddress)
                .getTotalStake(address(stMATIC));

            stakePerOperator[i] = amount;
            totalDelegated += amount;

            if (maxAmount < amount) {
                maxAmount = amount;
            }

            if ((minAmount > amount && amount != 0) || minAmount == 0) {
                minAmount = amount;
            }

            nonInactiveValidators[i] = ValidatorData(
                validator.contractAddress,
                validatorIdToRewardAddress[validatorIds[i]]
            );
        }
        minAmount = minAmount == 0 ? 1 : minAmount;
    }

    
    
    
    
    
    
    
    
    
    
    function getValidatorsRequestWithdraw(uint256 _withdrawAmount)
        external
        view
        override
        returns (
            ValidatorData[] memory validators,
            uint256 totalDelegated,
            uint256 bigNodeOperatorLength,
            uint256[] memory bigNodeOperatorIds,
            uint256 smallNodeOperatorLength,
            uint256[] memory smallNodeOperatorIds,
            uint256[] memory operatorAmountCanBeRequested,
            uint256 totalValidatorToWithdrawFrom
        )
    {
        if (validatorIds.length == 0) {
            return (
                validators,
                totalDelegated,
                bigNodeOperatorLength,
                bigNodeOperatorIds,
                smallNodeOperatorLength,
                smallNodeOperatorIds,
                operatorAmountCanBeRequested,
                totalValidatorToWithdrawFrom
            );
        }
        uint256[] memory stakePerOperator;
        uint256 minAmount;
        uint256 maxAmount;

        (
            validators,
            stakePerOperator,
            totalDelegated,
            minAmount,
            maxAmount
        ) = _getValidatorsRequestWithdraw();

        if (totalDelegated == 0) {
            return (
                validators,
                totalDelegated,
                bigNodeOperatorLength,
                bigNodeOperatorIds,
                smallNodeOperatorLength,
                smallNodeOperatorIds,
                operatorAmountCanBeRequested,
                totalValidatorToWithdrawFrom
            );
        }

        uint256 length = validators.length;
        uint256 withdrawAmountPercentage = (_withdrawAmount * 100) /
            totalDelegated;

        totalValidatorToWithdrawFrom =
            (((withdrawAmountPercentage + MIN_REQUEST_WITHDRAW_RANGE_PERCENTS) *
                length) / 100) +
            1;

        totalValidatorToWithdrawFrom = totalValidatorToWithdrawFrom > length
            ? length
            : totalValidatorToWithdrawFrom;

        if (
            (maxAmount * 100) / minAmount <= DISTANCE_THRESHOLD_PERCENTS &&
            minAmount * totalValidatorToWithdrawFrom >= _withdrawAmount
        ) {
            return (
                validators,
                totalDelegated,
                bigNodeOperatorLength,
                bigNodeOperatorIds,
                smallNodeOperatorLength,
                smallNodeOperatorIds,
                operatorAmountCanBeRequested,
                totalValidatorToWithdrawFrom
            );
        }
        totalValidatorToWithdrawFrom = 0;
        operatorAmountCanBeRequested = new uint256[](length);
        withdrawAmountPercentage = withdrawAmountPercentage == 0
            ? 1
            : withdrawAmountPercentage;
        uint256 rebalanceTarget = totalDelegated > _withdrawAmount
            ? (totalDelegated - _withdrawAmount) / length
            : 0;

        rebalanceTarget = rebalanceTarget > minAmount
            ? minAmount
            : rebalanceTarget;

        uint256 averageTarget = totalDelegated / length;
        bigNodeOperatorIds = new uint256[](length);
        smallNodeOperatorIds = new uint256[](length);

        for (uint256 idx = 0; idx < length; idx++) {
            if (stakePerOperator[idx] > averageTarget) {
                bigNodeOperatorIds[bigNodeOperatorLength] = idx;
                bigNodeOperatorLength++;
            } else {
                smallNodeOperatorIds[smallNodeOperatorLength] = idx;
                smallNodeOperatorLength++;
            }

            uint256 operatorRatioToRebalance = stakePerOperator[idx] != 0 &&
                stakePerOperator[idx] > rebalanceTarget
                ? stakePerOperator[idx] - rebalanceTarget
                : 0;
            operatorAmountCanBeRequested[idx] = operatorRatioToRebalance;
        }
    }

    
    
    
    function getNodeOperator(uint256 _validatorId)
        external
        view
        override
        returns (FullNodeOperatorRegistry memory nodeOperator)
    {
        (
            NodeOperatorRegistryStatus operatorStatus,
            IStakeManager.Validator memory validator
        ) = _getOperatorStatusAndValidator(_validatorId);
        nodeOperator.validatorShare = validator.contractAddress;
        nodeOperator.validatorId = _validatorId;
        nodeOperator.rewardAddress = validatorIdToRewardAddress[_validatorId];
        nodeOperator.status = operatorStatus;
        nodeOperator.commissionRate = validator.commissionRate;
    }

    
    
    
    function getNodeOperator(address _rewardAddress)
        external
        view
        override
        returns (FullNodeOperatorRegistry memory nodeOperator)
    {
        uint256 validatorId = validatorRewardAddressToId[_rewardAddress];
        (
            NodeOperatorRegistryStatus operatorStatus,
            IStakeManager.Validator memory validator
        ) = _getOperatorStatusAndValidator(validatorId);

        nodeOperator.status = operatorStatus;
        nodeOperator.rewardAddress = _rewardAddress;
        nodeOperator.validatorId = validatorId;
        nodeOperator.validatorShare = validator.contractAddress;
        nodeOperator.commissionRate = validator.commissionRate;
    }

    
    
    
    function getNodeOperatorStatus(uint256 _validatorId)
        external
        view
        override
        returns (NodeOperatorRegistryStatus operatorStatus)
    {
        (operatorStatus, ) = _getOperatorStatusAndValidator(_validatorId);
    }

    
    
    
    
    function _getOperatorStatusAndValidator(uint256 _validatorId)
        private
        view
        returns (
            NodeOperatorRegistryStatus operatorStatus,
            IStakeManager.Validator memory validator
        )
    {
        address rewardAddress = validatorIdToRewardAddress[_validatorId];
        require(rewardAddress != address(0), "Operator not found");
        validator = stakeManager.validators(_validatorId);

        if (
            validator.status == IStakeManager.Status.Active &&
            validator.deactivationEpoch == 0
        ) {
            operatorStatus = NodeOperatorRegistryStatus.ACTIVE;
        } else if (
            validator.status == IStakeManager.Status.Locked &&
            validator.deactivationEpoch == 0
        ) {
            operatorStatus = NodeOperatorRegistryStatus.JAILED;
        } else if (
            (validator.status == IStakeManager.Status.Active ||
                validator.status == IStakeManager.Status.Locked) &&
            validator.deactivationEpoch != 0
        ) {
            operatorStatus = NodeOperatorRegistryStatus.EJECTED;
        } else if ((validator.status == IStakeManager.Status.Unstaked)) {
            operatorStatus = NodeOperatorRegistryStatus.UNSTAKED;
        } else {
            operatorStatus = NodeOperatorRegistryStatus.INACTIVE;
        }

        return (operatorStatus, validator);
    }

    
    function getValidatorIds()
        external
        view
        override
        returns (uint256[] memory)
    {
        return validatorIds;
    }

    
    
    
    
    
    function getProtocolStats()
        external
        view
        override
        returns (
            bool isBalanced,
            uint256 distanceThreshold,
            uint256 minAmount,
            uint256 maxAmount
        )
    {
        uint256 length = validatorIds.length;
        uint256 validatorId;
        for (uint256 i = 0; i < length; i++) {
            validatorId = validatorIds[i];
            (
                ,
                IStakeManager.Validator memory validator
            ) = _getOperatorStatusAndValidator(validatorId);

            (uint256 amount, ) = IValidatorShare(validator.contractAddress)
                .getTotalStake(address(stMATIC));
            if (maxAmount < amount) {
                maxAmount = amount;
            }

            if (minAmount > amount || minAmount == 0) {
                minAmount = amount;
            }
        }

        uint256 min = minAmount == 0 ? 1 : minAmount;
        distanceThreshold = ((maxAmount * 100) / min);
        isBalanced = distanceThreshold <= DISTANCE_THRESHOLD_PERCENTS;
    }

    
    
    
    
    
    
    function getStats()
        external
        view
        override
        returns (
            uint256 inactiveNodeOperator,
            uint256 activeNodeOperator,
            uint256 jailedNodeOperator,
            uint256 ejectedNodeOperator,
            uint256 unstakedNodeOperator
        )
    {
        uint256 length = validatorIds.length;
        for (uint256 idx = 0; idx < length; idx++) {
            (
                NodeOperatorRegistryStatus operatorStatus,

            ) = _getOperatorStatusAndValidator(validatorIds[idx]);
            if (operatorStatus == NodeOperatorRegistryStatus.ACTIVE) {
                activeNodeOperator++;
            } else if (operatorStatus == NodeOperatorRegistryStatus.JAILED) {
                jailedNodeOperator++;
            } else if (operatorStatus == NodeOperatorRegistryStatus.EJECTED) {
                ejectedNodeOperator++;
            } else if (operatorStatus == NodeOperatorRegistryStatus.UNSTAKED) {
                unstakedNodeOperator++;
            } else {
                inactiveNodeOperator++;
            }
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
