// SPDX-License-Identifier: GPL-2.0-or-later


// 
pragma solidity >=0.8.7 <0.9.0;







interface IDCAHubParameters {
  
  struct SwapData {
    // How many swaps have been executed
    uint32 performedSwaps;
    // How much of token A will be swapped on the next swap
    uint224 nextAmountToSwapAToB;
    // Timestamp of the last swap
    uint32 lastSwappedAt;
    // How much of token B will be swapped on the next swap
    uint224 nextAmountToSwapBToA;
  }

  
  struct SwapDelta {
    // How much less of token A will the following swap require
    uint128 swapDeltaAToB;
    // How much less of token B will the following swap require
    uint128 swapDeltaBToA;
  }

  
  struct AccumRatio {
    // The sum of all ratios from A to B
    uint256 accumRatioAToB;
    // The sum of all ratios from B to A
    uint256 accumRatioBToA;
  }

  
  
  
  
  
  
  
  function swapAmountDelta(
    address _tokenA,
    address _tokenB,
    bytes1 _swapIntervalMask,
    uint32 _swapNumber
  ) external view returns (SwapDelta memory);

  
  
  
  
  
  
  
  function accumRatio(
    address _tokenA,
    address _tokenB,
    bytes1 _swapIntervalMask,
    uint32 _swapNumber
  ) external view returns (AccumRatio memory);

  
  
  
  
  
  
  function swapData(
    address _tokenA,
    address _tokenB,
    bytes1 _swapIntervalMask
  ) external view returns (SwapData memory);

  
  
  
  
  
  function activeSwapIntervals(address _tokenA, address _tokenB) external view returns (bytes1);

  
  
  
  function platformBalance(address _token) external view returns (uint256);
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
interface IERC165 {
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
pragma solidity >=0.8.7 <0.9.0;





abstract contract DCAHubParameters is IDCAHubParameters {
  using SafeERC20 for IERC20Metadata;

  
  mapping(address => mapping(address => bytes1)) public activeSwapIntervals; // token A => token B => active swap intervals
  
  mapping(address => uint256) public platformBalance; // token => balance
  mapping(address => mapping(address => mapping(bytes1 => mapping(uint32 => SwapDelta)))) internal _swapAmountDelta; // token A => token B => swap interval => swap number => delta
  mapping(address => mapping(address => mapping(bytes1 => mapping(uint32 => AccumRatio)))) internal _accumRatio; // token A => token B => swap interval => swap number => accum
  mapping(address => mapping(address => mapping(bytes1 => SwapData))) internal _swapData; // token A => token B => swap interval => swap data

  
  function swapAmountDelta(
    address _tokenA,
    address _tokenB,
    bytes1 _swapIntervalMask,
    uint32 _swapNumber
  ) external view returns (SwapDelta memory) {
    (address __tokenA, address __tokenB) = TokenSorting.sortTokens(_tokenA, _tokenB);
    return _swapAmountDelta[__tokenA][__tokenB][_swapIntervalMask][_swapNumber];
  }

  
  function accumRatio(
    address _tokenA,
    address _tokenB,
    bytes1 _swapIntervalMask,
    uint32 _swapNumber
  ) external view returns (AccumRatio memory) {
    (address __tokenA, address __tokenB) = TokenSorting.sortTokens(_tokenA, _tokenB);
    return _accumRatio[__tokenA][__tokenB][_swapIntervalMask][_swapNumber];
  }

  
  function swapData(
    address _tokenA,
    address _tokenB,
    bytes1 _swapIntervalMask
  ) external view returns (SwapData memory) {
    (address __tokenA, address __tokenB) = TokenSorting.sortTokens(_tokenA, _tokenB);
    return _swapData[__tokenA][__tokenB][_swapIntervalMask];
  }

  function _assertNonZeroAddress(address _address) internal pure {
    if (_address == address(0)) revert IDCAHub.ZeroAddress();
  }

  function _calculateMagnitude(address _token) internal view returns (uint120) {
    return uint120(10**IERC20Metadata(_token).decimals());
  }

  function _transfer(
    address _token,
    address _to,
    uint256 _amount
  ) internal {
    IERC20Metadata(_token).safeTransfer(_to, _amount);
  }

  function _balanceOf(address _token) internal view returns (uint256) {
    return IERC20Metadata(_token).balanceOf(address(this));
  }
}

// 
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}



interface IDCAHubConfigHandler {
  
  
  event OracleSet(IPriceOracle _oracle);

  
  
  event SwapFeeSet(uint32 _feeSet);

  
  
  event LoanFeeSet(uint32 _feeSet);

  
  
  event SwapIntervalsAllowed(uint32[] _swapIntervals);

  
  
  event SwapIntervalsForbidden(uint32[] _swapIntervals);

  
  
  event PlatformFeeRatioSet(uint16 _platformFeeRatio);

  
  error HighFee();

  
  error InvalidFee();

  
  error HighPlatformFeeRatio();

  
  
  
  // solhint-disable-next-line func-name-mixedcase
  function MAX_PLATFORM_FEE_RATIO() external view returns (uint16);

  
  
  function swapFee() external view returns (uint32 _swapFee);

  
  
  function loanFee() external view returns (uint32 _loanFee);

  
  
  function oracle() external view returns (IPriceOracle _oracle);

  
  
  function platformFeeRatio() external view returns (uint16);

  
  
  
  // solhint-disable-next-line func-name-mixedcase
  function MAX_FEE() external view returns (uint32 _maxFee);

  
  
  function allowedSwapIntervals() external view returns (bytes1 _allowedSwapIntervals);

  
  
  function paused() external view returns (bool _isPaused);

  
  
  
  
  function setSwapFee(uint32 _fee) external;

  
  
  
  
  function setLoanFee(uint32 _fee) external;

  
  
  
  function setOracle(IPriceOracle _oracle) external;

  
  
  
  function setPlatformFeeRatio(uint16 _platformFeeRatio) external;

  
  
  function addSwapIntervalsToAllowedList(uint32[] calldata _swapIntervals) external;

  
  
  function removeSwapIntervalsFromAllowedList(uint32[] calldata _swapIntervals) external;

  
  function pause() external;

  
  function unpause() external;
}

// 
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

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
abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
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
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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
abstract contract Pausable is Context {
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
    constructor() {
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
}

// 
pragma solidity >=0.8.7 <0.9.0;








abstract contract DCAHubConfigHandler is DCAHubParameters, AccessControl, Pausable, IDCAHubConfigHandler {
  // Internal constants (all should be constants, but apparently the byte code size increases when they are)
  // solhint-disable var-name-mixedcase
  bytes32 public IMMEDIATE_ROLE = keccak256('IMMEDIATE_ROLE');
  bytes32 public TIME_LOCKED_ROLE = keccak256('TIME_LOCKED_ROLE');
  bytes32 public PLATFORM_WITHDRAW_ROLE = keccak256('PLATFORM_WITHDRAW_ROLE');
  // solhint-enable var-name-mixedcase
  
  uint32 public constant MAX_FEE = 100000; // 10%
  
  uint16 public constant MAX_PLATFORM_FEE_RATIO = 10000;

  
  IPriceOracle public oracle;
  
  uint32 public swapFee = 6000; // 0.6%
  
  uint32 public loanFee = 100; // 0.01%
  
  bytes1 public allowedSwapIntervals = 0xF0; // Start allowing weekly, daily, every 4 hours, hourly
  
  uint16 public platformFeeRatio = 2500; // 25%

  constructor(
    address _immediateGovernor,
    address _timeLockedGovernor,
    IPriceOracle _oracle
  ) {
    if (_immediateGovernor == address(0) || _timeLockedGovernor == address(0) || address(_oracle) == address(0)) revert IDCAHub.ZeroAddress();
    _setupRole(IMMEDIATE_ROLE, _immediateGovernor);
    _setupRole(TIME_LOCKED_ROLE, _timeLockedGovernor);
    _setRoleAdmin(PLATFORM_WITHDRAW_ROLE, TIME_LOCKED_ROLE);
    // We set each role as its own admin, so they can assign new addresses with the same role
    _setRoleAdmin(IMMEDIATE_ROLE, IMMEDIATE_ROLE);
    _setRoleAdmin(TIME_LOCKED_ROLE, TIME_LOCKED_ROLE);
    oracle = _oracle;
  }

  
  function setOracle(IPriceOracle _oracle) external onlyRole(TIME_LOCKED_ROLE) {
    _assertNonZeroAddress(address(_oracle));
    oracle = _oracle;
    emit OracleSet(_oracle);
  }

  
  function setSwapFee(uint32 _swapFee) external onlyRole(TIME_LOCKED_ROLE) {
    _validateFee(_swapFee);
    swapFee = _swapFee;
    emit SwapFeeSet(_swapFee);
  }

  
  function setLoanFee(uint32 _loanFee) external onlyRole(TIME_LOCKED_ROLE) {
    _validateFee(_loanFee);
    loanFee = _loanFee;
    emit LoanFeeSet(_loanFee);
  }

  
  function setPlatformFeeRatio(uint16 _platformFeeRatio) external onlyRole(TIME_LOCKED_ROLE) {
    if (_platformFeeRatio > MAX_PLATFORM_FEE_RATIO) revert HighPlatformFeeRatio();
    platformFeeRatio = _platformFeeRatio;
    emit PlatformFeeRatioSet(_platformFeeRatio);
  }

  
  function addSwapIntervalsToAllowedList(uint32[] calldata _swapIntervals) external onlyRole(IMMEDIATE_ROLE) {
    for (uint256 i; i < _swapIntervals.length; i++) {
      allowedSwapIntervals |= Intervals.intervalToMask(_swapIntervals[i]);
    }
    emit SwapIntervalsAllowed(_swapIntervals);
  }

  
  function removeSwapIntervalsFromAllowedList(uint32[] calldata _swapIntervals) external onlyRole(IMMEDIATE_ROLE) {
    for (uint256 i; i < _swapIntervals.length; i++) {
      allowedSwapIntervals &= ~Intervals.intervalToMask(_swapIntervals[i]);
    }
    emit SwapIntervalsForbidden(_swapIntervals);
  }

  
  function pause() external onlyRole(IMMEDIATE_ROLE) {
    _pause();
  }

  
  function unpause() external onlyRole(IMMEDIATE_ROLE) {
    _unpause();
  }

  
  function paused() public view virtual override(IDCAHubConfigHandler, Pausable) returns (bool) {
    return super.paused();
  }

  function _validateFee(uint32 _fee) internal pure {
    if (_fee > MAX_FEE) revert HighFee();
    if (_fee % 100 != 0) revert InvalidFee();
  }
}



interface IDCAHubPositionHandler {
  
  struct UserPosition {
    // The token that the user deposited and will be swapped in exchange for "to"
    IERC20Metadata from;
    // The token that the user will get in exchange for their "from" tokens in each swap
    IERC20Metadata to;
    // How frequently the position's swaps should be executed
    uint32 swapInterval;
    // How many swaps were executed since deposit, last modification, or last withdraw
    uint32 swapsExecuted;
    // How many "to" tokens can currently be withdrawn
    uint256 swapped;
    // How many swaps left the position has to execute
    uint32 swapsLeft;
    // How many "from" tokens there are left to swap
    uint256 remaining;
    // How many "from" tokens need to be traded in each swap
    uint120 rate;
  }

  
  struct PositionSet {
    // The `to` token
    address token;
    // The position ids
    uint256[] positionIds;
  }

  
  
  
  
  
  
  
  event Terminated(
    address indexed user,
    address indexed recipientUnswapped,
    address indexed recipientSwapped,
    uint256 positionId,
    uint256 returnedUnswapped,
    uint256 returnedSwapped
  );

  
  
  
  
  
  
  
  
  
  
  
  event Deposited(
    address indexed depositor,
    address indexed owner,
    uint256 positionId,
    address fromToken,
    address toToken,
    uint32 swapInterval,
    uint120 rate,
    uint32 startingSwap,
    uint32 lastSwap,
    IDCAPermissionManager.PermissionSet[] permissions
  );

  
  
  
  event Miscellaneous(uint256 positionId, bytes data);

  
  
  
  
  
  
  event Withdrew(address indexed withdrawer, address indexed recipient, uint256 positionId, address token, uint256 amount);

  
  
  
  
  
  event WithdrewMany(address indexed withdrawer, address indexed recipient, PositionSet[] positions, uint256[] withdrew);

  
  
  
  
  
  
  event Modified(address indexed user, uint256 positionId, uint120 rate, uint32 startingSwap, uint32 lastSwap);

  
  error InvalidToken();

  
  error IntervalNotAllowed();

  
  error InvalidPosition();

  
  error UnauthorizedCaller();

  
  error ZeroSwaps();

  
  error ZeroAmount();

  
  error PositionDoesNotMatchToken();

  
  error AmountTooBig();

  
  
  function permissionManager() external view returns (IDCAPermissionManager);

  
  
  
  function userPosition(uint256 _positionId) external view returns (UserPosition memory _position);

  
  
  /// With ZeroAddress if _from, _to or _owner are zero
  /// With InvalidToken if _from == _to
  /// With ZeroAmount if _amount is zero
  /// With AmountTooBig if _amount is too big
  /// With ZeroSwaps if _amountOfSwaps is zero
  /// With IntervalNotAllowed if _swapInterval is not allowed
  
  
  
  
  
  
  
  
  function deposit(
    address _from,
    address _to,
    uint256 _amount,
    uint32 _amountOfSwaps,
    uint32 _swapInterval,
    address _owner,
    IDCAPermissionManager.PermissionSet[] calldata _permissions
  ) external returns (uint256 _positionId);

  
  
  /// With ZeroAddress if _from, _to or _owner are zero
  /// With InvalidToken if _from == _to
  /// With ZeroAmount if _amount is zero
  /// With AmountTooBig if _amount is too big
  /// With ZeroSwaps if _amountOfSwaps is zero
  /// With IntervalNotAllowed if _swapInterval is not allowed
  
  
  
  
  
  
  
  
  
  function deposit(
    address _from,
    address _to,
    uint256 _amount,
    uint32 _amountOfSwaps,
    uint32 _swapInterval,
    address _owner,
    IDCAPermissionManager.PermissionSet[] calldata _permissions,
    bytes calldata _miscellaneous
  ) external returns (uint256 _positionId);

  
  
  /// With InvalidPosition if _positionId is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position
  /// With ZeroAddress if recipient is zero
  
  
  
  function withdrawSwapped(uint256 _positionId, address _recipient) external returns (uint256 _swapped);

  
  
  /// With InvalidPosition if any of the position ids are invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position to any of the given positions
  /// With ZeroAddress if recipient is zero
  /// With PositionDoesNotMatchToken if any of the positions do not match the token in their position set
  
  
  
  function withdrawSwappedMany(PositionSet[] calldata _positions, address _recipient) external returns (uint256[] memory _withdrawn);

  
  /// it is executed in _newSwaps swaps
  
  /// With InvalidPosition if _positionId is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position
  /// With AmountTooBig if _amount is too big
  
  
  
  function increasePosition(
    uint256 _positionId,
    uint256 _amount,
    uint32 _newSwaps
  ) external;

  
  /// it is executed in _newSwaps swaps
  
  /// With InvalidPosition if _positionId is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position
  /// With ZeroSwaps if _newSwaps is zero and _amount is not the total unswapped balance
  
  
  
  
  function reducePosition(
    uint256 _positionId,
    uint256 _amount,
    uint32 _newSwaps,
    address _recipient
  ) external;

  
  
  /// With InvalidPosition if _positionId is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position
  /// With ZeroAddress if _recipientUnswapped or _recipientSwapped is zero
  
  
  
  
  
  function terminate(
    uint256 _positionId,
    address _recipientUnswapped,
    address _recipientSwapped
  ) external returns (uint256 _unswapped, uint256 _swapped);
}



interface IDCAHubSwapHandler {
  
  struct SwapInfo {
    // The tokens involved in the swap
    TokenInSwap[] tokens;
    // The pairs involved in the swap
    PairInSwap[] pairs;
  }

  
  struct TokenInSwap {
    // The token's address
    address token;
    // How much will be given of this token as a reward
    uint256 reward;
    // How much of this token needs to be provided by swapper
    uint256 toProvide;
    // How much of this token will be paid to the platform
    uint256 platformFee;
  }

  
  struct PairInSwap {
    // The address of one of the tokens
    address tokenA;
    // The address of the other token
    address tokenB;
    // How much is 1 unit of token A when converted to B
    uint256 ratioAToB;
    // How much is 1 unit of token B when converted to A
    uint256 ratioBToA;
    // The swap intervals involved in the swap, represented as a byte
    bytes1 intervalsInSwap;
  }

  
  struct PairIndexes {
    // The index of the token A
    uint8 indexTokenA;
    // The index of the token B
    uint8 indexTokenB;
  }

  
  
  
  
  
  
  
  event Swapped(
    address indexed sender,
    address indexed rewardRecipient,
    address indexed callbackHandler,
    SwapInfo swapInformation,
    uint256[] borrowed,
    uint32 fee
  );

  
  error InvalidPairs();

  
  error NoSwapsToExecute();

  
  
  /// With InvalidTokens if _tokens are not sorted, or if there are duplicates
  /// With InvalidPairs if _pairs are not sorted (first by indexTokenA and then indexTokenB), or if indexTokenA >= indexTokenB for any pair
  
  
  
  function getNextSwapInfo(address[] calldata _tokens, PairIndexes[] calldata _pairs) external view returns (SwapInfo memory _swapInformation);

  
  
  /// With InvalidTokens if _tokens are not sorted, or if there are duplicates
  /// With InvalidPairs if _pairs are not sorted (first by indexTokenA and then indexTokenB), or if indexTokenA >= indexTokenB for any pair
  /// Paused if swaps are paused by protocol
  /// NoSwapsToExecute if there are no swaps to execute for the given pairs
  /// LiquidityNotReturned if the required tokens were not back during the callback
  
  
  
  
  
  
  
  function swap(
    address[] calldata _tokens,
    PairIndexes[] calldata _pairsToSwap,
    address _rewardRecipient,
    address _callbackHandler,
    uint256[] calldata _borrow,
    bytes calldata _data
  ) external returns (SwapInfo memory);
}



interface IDCAHubLoanHandler {
  
  
  
  
  
  event Loaned(address indexed sender, address indexed to, IDCAHub.AmountOfToken[] loan, uint32 fee);

  
  
  /// With Paused if loans are paused by protocol
  /// With InvalidTokens if the tokens in `_loan` are not sorted
  
  
  
  function loan(
    IDCAHub.AmountOfToken[] calldata _loan,
    address _to,
    bytes calldata _data
  ) external;
}



interface IDCAHubPlatformHandler {
  
  
  
  
  event WithdrewFromPlatform(address indexed sender, address indexed recipient, IDCAHub.AmountOfToken[] amounts);

  
  
  
  function withdrawFromPlatformBalance(IDCAHub.AmountOfToken[] calldata _amounts, address _recipient) external;
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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

// 
pragma solidity >=0.8.7 <0.9.0;






abstract contract DCAHubPositionHandler is ReentrancyGuard, DCAHubConfigHandler, IDCAHubPositionHandler {
  struct DCA {
    uint32 swapWhereLastUpdated; // Includes both modify and withdraw
    uint32 finalSwap;
    bytes1 swapIntervalMask;
    address from;
    uint24 rateLower; // We are splitting the rate into two different uints, so that we can use only 2 storage slots
    uint96 rateHigher;
    address to;
  }

  using SafeERC20 for IERC20Metadata;

  
  IDCAPermissionManager public permissionManager;
  mapping(uint256 => DCA) internal _userPositions;
  mapping(uint256 => uint256) internal _swappedBeforeModified;
  uint256 internal _idCounter;

  constructor(IDCAPermissionManager _permissionManager) {
    _assertNonZeroAddress(address(_permissionManager));
    permissionManager = _permissionManager;
  }

  
  function userPosition(uint256 _positionId) external view returns (UserPosition memory _userPosition) {
    DCA memory _position = _userPositions[_positionId];
    uint32 _performedSwaps = _getPerformedSwaps(_position.from, _position.to, _position.swapIntervalMask);
    uint32 _newestSwapToConsider = _min(_performedSwaps, _position.finalSwap);
    _userPosition.from = IERC20Metadata(_position.from);
    _userPosition.to = IERC20Metadata(_position.to);
    _userPosition.swapsExecuted = _subtractIfPossible(_newestSwapToConsider, _position.swapWhereLastUpdated);
    _userPosition.swapsLeft = _subtractIfPossible(_position.finalSwap, _performedSwaps);
    _userPosition.remaining = _calculateUnswapped(_position, _performedSwaps);
    _userPosition.rate = _mergeRate(_position);
    if (_position.swapIntervalMask > 0) {
      _userPosition.swapInterval = Intervals.maskToInterval(_position.swapIntervalMask);
      _userPosition.swapped = _calculateSwapped(_positionId, _position, _performedSwaps);
    }
  }

  
  function deposit(
    address _from,
    address _to,
    uint256 _amount,
    uint32 _amountOfSwaps,
    uint32 _swapInterval,
    address _owner,
    IDCAPermissionManager.PermissionSet[] calldata _permissions
  ) public nonReentrant whenNotPaused returns (uint256) {
    if (_from == address(0) || _to == address(0) || _owner == address(0)) revert IDCAHub.ZeroAddress();
    if (_from == _to) revert InvalidToken();
    if (_amount == 0) revert ZeroAmount();
    if (_amountOfSwaps == 0) revert ZeroSwaps();
    uint120 _rate = _calculateRate(_amount, _amountOfSwaps);
    uint256 _positionId = ++_idCounter;
    DCA memory _userPosition = _buildPosition(_from, _to, _amountOfSwaps, Intervals.intervalToMask(_swapInterval), _rate);
    if (allowedSwapIntervals & _userPosition.swapIntervalMask == 0) revert IntervalNotAllowed();
    permissionManager.mint(_positionId, _owner, _permissions);
    _updateActiveIntervalsAndOracle(_from, _to, _userPosition.swapIntervalMask);
    _addToDelta(_from, _to, _userPosition.swapIntervalMask, _userPosition.finalSwap, _rate);
    _userPositions[_positionId] = _userPosition;
    IERC20Metadata(_from).safeTransferFrom(msg.sender, address(this), _amount);
    emit Deposited(
      msg.sender,
      _owner,
      _positionId,
      _from,
      _to,
      _swapInterval,
      _rate,
      _userPosition.swapWhereLastUpdated + 1,
      _userPosition.finalSwap,
      _permissions
    );
    return _positionId;
  }

  
  function deposit(
    address _from,
    address _to,
    uint256 _amount,
    uint32 _amountOfSwaps,
    uint32 _swapInterval,
    address _owner,
    IDCAPermissionManager.PermissionSet[] calldata _permissions,
    bytes calldata _miscellaneous
  ) external returns (uint256 _positionId) {
    _positionId = deposit(_from, _to, _amount, _amountOfSwaps, _swapInterval, _owner, _permissions);
    if (_miscellaneous.length > 0) {
      emit Miscellaneous(_positionId, _miscellaneous);
    }
  }

  
  function withdrawSwapped(uint256 _positionId, address _recipient) external nonReentrant returns (uint256) {
    _assertNonZeroAddress(_recipient);

    (uint256 _swapped, address _to) = _executeWithdraw(_positionId);
    _transfer(_to, _recipient, _swapped);
    emit Withdrew(msg.sender, _recipient, _positionId, _to, _swapped);
    return _swapped;
  }

  
  function withdrawSwappedMany(PositionSet[] calldata _positions, address _recipient) external nonReentrant returns (uint256[] memory _swapped) {
    _assertNonZeroAddress(_recipient);
    _swapped = new uint256[](_positions.length);
    for (uint256 i; i < _positions.length; i++) {
      address _token = _positions[i].token;
      for (uint256 j; j < _positions[i].positionIds.length; j++) {
        (uint256 _swappedByPosition, address _to) = _executeWithdraw(_positions[i].positionIds[j]);
        if (_to != _token) revert PositionDoesNotMatchToken();
        _swapped[i] += _swappedByPosition;
      }
      _transfer(_token, _recipient, _swapped[i]);
    }
    emit WithdrewMany(msg.sender, _recipient, _positions, _swapped);
  }

  
  function terminate(
    uint256 _positionId,
    address _recipientUnswapped,
    address _recipientSwapped
  ) external nonReentrant returns (uint256 _unswapped, uint256 _swapped) {
    if (_recipientUnswapped == address(0) || _recipientSwapped == address(0)) revert IDCAHub.ZeroAddress();

    DCA memory _userPosition = _userPositions[_positionId];
    _assertPositionExistsAndCallerHasPermission(_positionId, _userPosition, IDCAPermissionManager.Permission.TERMINATE);
    uint32 _performedSwaps = _getPerformedSwaps(_userPosition.from, _userPosition.to, _userPosition.swapIntervalMask);

    _swapped = _calculateSwapped(_positionId, _userPosition, _performedSwaps);
    _unswapped = _calculateUnswapped(_userPosition, _performedSwaps);

    _removeFromDelta(_userPosition, _performedSwaps);
    delete _userPositions[_positionId];
    delete _swappedBeforeModified[_positionId];
    permissionManager.burn(_positionId);

    if (_swapped > 0) {
      _transfer(_userPosition.to, _recipientSwapped, _swapped);
    }

    if (_unswapped > 0) {
      _transfer(_userPosition.from, _recipientUnswapped, _unswapped);
    }

    emit Terminated(msg.sender, _recipientUnswapped, _recipientSwapped, _positionId, _unswapped, _swapped);
  }

  
  function increasePosition(
    uint256 _positionId,
    uint256 _amount,
    uint32 _newAmountOfSwaps
  ) external nonReentrant whenNotPaused {
    _modify(_positionId, _amount, _newAmountOfSwaps, address(0));
  }

  
  function reducePosition(
    uint256 _positionId,
    uint256 _amount,
    uint32 _newAmountOfSwaps,
    address _recipient
  ) external nonReentrant {
    _assertNonZeroAddress(_recipient);
    _modify(_positionId, _amount, _newAmountOfSwaps, _recipient);
  }

  function _modify(
    uint256 _positionId,
    uint256 _amount,
    uint32 _newAmountOfSwaps,
    address _recipient
  ) internal {
    DCA memory _userPosition = _userPositions[_positionId];
    bool _increase = _recipient == address(0);
    _assertPositionExistsAndCallerHasPermission(
      _positionId,
      _userPosition,
      _increase ? IDCAPermissionManager.Permission.INCREASE : IDCAPermissionManager.Permission.REDUCE
    );

    uint32 _performedSwaps = _getPerformedSwaps(_userPosition.from, _userPosition.to, _userPosition.swapIntervalMask);
    uint256 _unswapped = _calculateUnswapped(_userPosition, _performedSwaps);
    uint256 _total = _increase ? _unswapped + _amount : _unswapped - _amount;
    if (_total != 0 && _newAmountOfSwaps == 0) revert ZeroSwaps();
    if (_total == 0 && _newAmountOfSwaps > 0) _newAmountOfSwaps = 0;

    uint120 _newRate = _newAmountOfSwaps == 0 ? 0 : _calculateRate(_total, _newAmountOfSwaps);
    (_userPositions[_positionId].rateLower, _userPositions[_positionId].rateHigher) = _splitRate(_newRate);

    uint32 _finalSwap = _performedSwaps + _newAmountOfSwaps;
    _userPositions[_positionId].swapWhereLastUpdated = _performedSwaps;
    _userPositions[_positionId].finalSwap = _finalSwap;
    _swappedBeforeModified[_positionId] = _calculateSwapped(_positionId, _userPosition, _performedSwaps);

    _removeFromDelta(_userPosition, _performedSwaps);
    _addToDelta(_userPosition.from, _userPosition.to, _userPosition.swapIntervalMask, _finalSwap, _newRate);

    if (_amount > 0) {
      if (_increase) {
        IERC20Metadata(_userPosition.from).safeTransferFrom(msg.sender, address(this), _amount);
      } else {
        _transfer(_userPosition.from, _recipient, _amount);
      }
    }

    emit Modified(msg.sender, _positionId, _newRate, _performedSwaps + 1, _finalSwap);
  }

  function _assertPositionExistsAndCallerHasPermission(
    uint256 _positionId,
    DCA memory _userPosition,
    IDCAPermissionManager.Permission _permission
  ) internal view {
    if (_userPosition.swapIntervalMask == 0) revert InvalidPosition();
    if (!permissionManager.hasPermission(_positionId, msg.sender, _permission)) revert UnauthorizedCaller();
  }

  function _addToDelta(
    address _from,
    address _to,
    bytes1 _swapIntervalMask,
    uint32 _finalSwap,
    uint120 _rate
  ) internal {
    _modifyDelta(_from, _to, _swapIntervalMask, _finalSwap, _rate, true);
  }

  function _removeFromDelta(DCA memory _userPosition, uint32 _performedSwaps) internal {
    if (_userPosition.finalSwap > _performedSwaps) {
      _modifyDelta(
        _userPosition.from,
        _userPosition.to,
        _userPosition.swapIntervalMask,
        _userPosition.finalSwap,
        _mergeRate(_userPosition),
        false
      );
    }
  }

  function _modifyDelta(
    address _from,
    address _to,
    bytes1 _swapIntervalMask,
    uint32 _finalSwap,
    uint120 _rate,
    bool _add
  ) internal {
    if (_from < _to) {
      if (_add) {
        _swapData[_from][_to][_swapIntervalMask].nextAmountToSwapAToB += _rate;
        _swapAmountDelta[_from][_to][_swapIntervalMask][_finalSwap + 1].swapDeltaAToB += _rate;
      } else {
        _swapData[_from][_to][_swapIntervalMask].nextAmountToSwapAToB -= _rate;
        _swapAmountDelta[_from][_to][_swapIntervalMask][_finalSwap + 1].swapDeltaAToB -= _rate;
      }
    } else {
      if (_add) {
        _swapData[_to][_from][_swapIntervalMask].nextAmountToSwapBToA += _rate;
        _swapAmountDelta[_to][_from][_swapIntervalMask][_finalSwap + 1].swapDeltaBToA += _rate;
      } else {
        _swapData[_to][_from][_swapIntervalMask].nextAmountToSwapBToA -= _rate;
        _swapAmountDelta[_to][_from][_swapIntervalMask][_finalSwap + 1].swapDeltaBToA -= _rate;
      }
    }
  }

  function _updateActiveIntervalsAndOracle(
    address _from,
    address _to,
    bytes1 _mask
  ) internal {
    (address _tokenA, address _tokenB) = TokenSorting.sortTokens(_from, _to);
    bytes1 _activeIntervals = activeSwapIntervals[_tokenA][_tokenB];
    if (_activeIntervals & _mask == 0) {
      if (_activeIntervals == 0) {
        oracle.addSupportForPairIfNeeded(_tokenA, _tokenB);
      }
      activeSwapIntervals[_tokenA][_tokenB] = _activeIntervals | _mask;
    }
  }

  /** Returns the amount of tokens swapped in TO */
  function _calculateSwapped(
    uint256 _positionId,
    DCA memory _userPosition,
    uint32 _performedSwaps
  ) internal view returns (uint256 _swapped) {
    uint32 _newestSwapToConsider = _min(_performedSwaps, _userPosition.finalSwap);

    if (_userPosition.swapWhereLastUpdated > _newestSwapToConsider) {
      // If last update happened after the position's final swap, then a withdraw was executed, and we just return 0
      return 0;
    } else if (_userPosition.swapWhereLastUpdated == _newestSwapToConsider) {
      // If the last update matches the positions's final swap, then we can avoid all calculation below
      return _swappedBeforeModified[_positionId];
    }

    uint256 _accumRatio = _userPosition.from < _userPosition.to
      ? _accumRatio[_userPosition.from][_userPosition.to][_userPosition.swapIntervalMask][_newestSwapToConsider].accumRatioAToB -
        _accumRatio[_userPosition.from][_userPosition.to][_userPosition.swapIntervalMask][_userPosition.swapWhereLastUpdated].accumRatioAToB
      : _accumRatio[_userPosition.to][_userPosition.from][_userPosition.swapIntervalMask][_newestSwapToConsider].accumRatioBToA -
        _accumRatio[_userPosition.to][_userPosition.from][_userPosition.swapIntervalMask][_userPosition.swapWhereLastUpdated].accumRatioBToA;
    uint256 _magnitude = _calculateMagnitude(_userPosition.from);
    uint120 _rate = _mergeRate(_userPosition);
    (bool _ok, uint256 _mult) = SafeMath.tryMul(_accumRatio, _rate);
    uint256 _swappedInCurrentPosition = _ok ? _mult / _magnitude : (_accumRatio / _magnitude) * _rate;
    _swapped = _swappedInCurrentPosition + _swappedBeforeModified[_positionId];
  }

  /** Returns how many FROM remains unswapped  */
  function _calculateUnswapped(DCA memory _userPosition, uint32 _performedSwaps) internal pure returns (uint256 _unswapped) {
    _unswapped = uint256(_subtractIfPossible(_userPosition.finalSwap, _performedSwaps)) * _mergeRate(_userPosition);
  }

  function _executeWithdraw(uint256 _positionId) internal returns (uint256 _swapped, address _to) {
    DCA memory _userPosition = _userPositions[_positionId];
    _assertPositionExistsAndCallerHasPermission(_positionId, _userPosition, IDCAPermissionManager.Permission.WITHDRAW);
    uint32 _performedSwaps = _getPerformedSwaps(_userPosition.from, _userPosition.to, _userPosition.swapIntervalMask);
    _swapped = _calculateSwapped(_positionId, _userPosition, _performedSwaps);
    _to = _userPosition.to;
    _userPositions[_positionId].swapWhereLastUpdated = _performedSwaps;
    delete _swappedBeforeModified[_positionId];
  }

  function _getPerformedSwaps(
    address _from,
    address _to,
    bytes1 _swapIntervalMask
  ) internal view returns (uint32) {
    (address _tokenA, address _tokenB) = TokenSorting.sortTokens(_from, _to);
    return _swapData[_tokenA][_tokenB][_swapIntervalMask].performedSwaps;
  }

  function _buildPosition(
    address _from,
    address _to,
    uint32 _amountOfSwaps,
    bytes1 _mask,
    uint120 _rate
  ) internal view returns (DCA memory _userPosition) {
    uint32 _performedSwaps = _getPerformedSwaps(_from, _to, _mask);
    (uint24 _lower, uint96 _higher) = _splitRate(_rate);
    _userPosition = DCA({
      swapWhereLastUpdated: _performedSwaps,
      finalSwap: _performedSwaps + _amountOfSwaps,
      swapIntervalMask: _mask,
      rateLower: _lower,
      rateHigher: _higher,
      from: _from,
      to: _to
    });
  }

  function _calculateRate(uint256 _amount, uint32 _amountOfSwaps) internal pure returns (uint120) {
    uint256 _rate = _amount / _amountOfSwaps;
    if (_rate > type(uint120).max) revert AmountTooBig();
    return uint120(_rate);
  }

  function _mergeRate(DCA memory _userPosition) internal pure returns (uint120) {
    return (uint120(_userPosition.rateHigher) << 24) + _userPosition.rateLower;
  }

  function _splitRate(uint120 _rate) internal pure returns (uint24 _lower, uint96 _higher) {
    _lower = uint24(_rate);
    _higher = uint96(_rate >> 24);
  }

  function _min(uint32 _a, uint32 _b) internal pure returns (uint32) {
    return _a > _b ? _b : _a;
  }

  function _subtractIfPossible(uint32 _a, uint32 _b) internal pure returns (uint32) {
    return _a > _b ? _a - _b : 0;
  }
}

// 
pragma solidity >=0.8.7 <0.9.0;









abstract contract DCAHubSwapHandler is ReentrancyGuard, DCAHubConfigHandler, IDCAHubSwapHandler {
  using SafeERC20 for IERC20Metadata;

  function _registerSwap(
    address _tokenA,
    address _tokenB,
    bytes1 _swapIntervalMask,
    uint256 _ratioAToB,
    uint256 _ratioBToA,
    uint32 _timestamp
  ) internal virtual {
    SwapData memory _swapDataMem = _swapData[_tokenA][_tokenB][_swapIntervalMask];
    if (_swapDataMem.nextAmountToSwapAToB > 0 || _swapDataMem.nextAmountToSwapBToA > 0) {
      AccumRatio memory _accumRatioMem = _accumRatio[_tokenA][_tokenB][_swapIntervalMask][_swapDataMem.performedSwaps];
      _accumRatio[_tokenA][_tokenB][_swapIntervalMask][_swapDataMem.performedSwaps + 1] = AccumRatio({
        accumRatioAToB: _accumRatioMem.accumRatioAToB + _ratioAToB,
        accumRatioBToA: _accumRatioMem.accumRatioBToA + _ratioBToA
      });
      SwapDelta memory _swapDeltaMem = _swapAmountDelta[_tokenA][_tokenB][_swapIntervalMask][_swapDataMem.performedSwaps + 2];
      _swapData[_tokenA][_tokenB][_swapIntervalMask] = SwapData({
        performedSwaps: _swapDataMem.performedSwaps + 1,
        lastSwappedAt: _timestamp,
        nextAmountToSwapAToB: _swapDataMem.nextAmountToSwapAToB - _swapDeltaMem.swapDeltaAToB,
        nextAmountToSwapBToA: _swapDataMem.nextAmountToSwapBToA - _swapDeltaMem.swapDeltaBToA
      });
      delete _swapAmountDelta[_tokenA][_tokenB][_swapIntervalMask][_swapDataMem.performedSwaps + 2];
    } else {
      activeSwapIntervals[_tokenA][_tokenB] &= ~_swapIntervalMask;
    }
  }

  function _convertTo(
    uint256 _fromTokenMagnitude,
    uint256 _amountFrom,
    uint256 _rateFromTo,
    uint32 _swapFee
  ) internal pure returns (uint256 _amountTo) {
    uint256 _numerator = _amountFrom * FeeMath.subtractFeeFromAmount(_swapFee, _rateFromTo);
    _amountTo = _numerator / _fromTokenMagnitude;
    // Note: we need to round up because we can't ask for less than what we actually need
    if (_numerator % _fromTokenMagnitude != 0) _amountTo++;
  }

  function _getTimestamp() internal view virtual returns (uint32 _blockTimestamp) {
    _blockTimestamp = uint32(block.timestamp);
  }

  function _getTotalAmountsToSwap(address _tokenA, address _tokenB)
    internal
    view
    virtual
    returns (
      uint256 _totalAmountToSwapTokenA,
      uint256 _totalAmountToSwapTokenB,
      bytes1 _intervalsInSwap
    )
  {
    bytes1 _activeIntervals = activeSwapIntervals[_tokenA][_tokenB];
    uint32 _blockTimestamp = _getTimestamp();
    bytes1 _mask = 0x01;
    while (_activeIntervals >= _mask && _mask > 0) {
      if (_activeIntervals & _mask != 0) {
        SwapData memory _swapDataMem = _swapData[_tokenA][_tokenB][_mask];
        uint32 _swapInterval = Intervals.maskToInterval(_mask);
        if (((_swapDataMem.lastSwappedAt / _swapInterval) + 1) * _swapInterval > _blockTimestamp) {
          // Note: this 'break' is both an optimization and a search for more CoW. Since this loop starts with the smaller intervals, it is
          // highly unlikely that if a small interval can't be swapped, a bigger interval can. It could only happen when a position was just
          // created for a new swap interval. At the same time, by adding this check, we force intervals to be swapped together. Therefore
          // increasing the chance of CoW (Coincidence of Wants), and reducing the need for external funds.
          break;
        }
        _intervalsInSwap |= _mask;
        _totalAmountToSwapTokenA += _swapDataMem.nextAmountToSwapAToB;
        _totalAmountToSwapTokenB += _swapDataMem.nextAmountToSwapBToA;
      }
      _mask <<= 1;
    }

    if (_totalAmountToSwapTokenA == 0 && _totalAmountToSwapTokenB == 0) {
      // Note: if there are no tokens to swap, then we don't want to execute any swaps for this pair
      _intervalsInSwap = 0;
    }
  }

  function _calculateRatio(
    address _tokenA,
    address _tokenB,
    uint256 _magnitudeA,
    uint256 _magnitudeB,
    IPriceOracle _oracle
  ) internal view virtual returns (uint256 _ratioAToB, uint256 _ratioBToA) {
    _ratioBToA = _oracle.quote(_tokenB, uint128(_magnitudeB), _tokenA);
    _ratioAToB = (_magnitudeB * _magnitudeA) / _ratioBToA;
  }

  
  function getNextSwapInfo(address[] calldata _tokens, PairIndexes[] calldata _pairs)
    public
    view
    virtual
    returns (SwapInfo memory _swapInformation)
  {
    // Note: we are caching these variables in memory so we can read storage only once (it's cheaper that way)
    uint32 _swapFee = swapFee;
    IPriceOracle _oracle = oracle;

    uint256[] memory _total = new uint256[](_tokens.length);
    uint256[] memory _needed = new uint256[](_tokens.length);
    _swapInformation.pairs = new PairInSwap[](_pairs.length);

    for (uint256 i; i < _pairs.length; i++) {
      uint8 indexTokenA = _pairs[i].indexTokenA;
      uint8 indexTokenB = _pairs[i].indexTokenB;
      if (
        indexTokenA >= indexTokenB ||
        (i > 0 &&
          (indexTokenA < _pairs[i - 1].indexTokenA || (indexTokenA == _pairs[i - 1].indexTokenA && indexTokenB <= _pairs[i - 1].indexTokenB)))
      ) {
        // Note: this confusing condition verifies that the pairs are sorted, first by token A, and then by token B
        revert InvalidPairs();
      }

      PairInSwap memory _pairInSwap;
      _pairInSwap.tokenA = _tokens[indexTokenA];
      _pairInSwap.tokenB = _tokens[indexTokenB];
      uint120 _magnitudeA = _calculateMagnitude(_pairInSwap.tokenA);
      uint120 _magnitudeB = _calculateMagnitude(_pairInSwap.tokenB);

      uint256 _amountToSwapTokenA;
      uint256 _amountToSwapTokenB;

      (_amountToSwapTokenA, _amountToSwapTokenB, _pairInSwap.intervalsInSwap) = _getTotalAmountsToSwap(_pairInSwap.tokenA, _pairInSwap.tokenB);

      _total[indexTokenA] += _amountToSwapTokenA;
      _total[indexTokenB] += _amountToSwapTokenB;

      (_pairInSwap.ratioAToB, _pairInSwap.ratioBToA) = _calculateRatio(
        _pairInSwap.tokenA,
        _pairInSwap.tokenB,
        _magnitudeA,
        _magnitudeB,
        _oracle
      );

      _needed[indexTokenA] += _convertTo(_magnitudeB, _amountToSwapTokenB, _pairInSwap.ratioBToA, _swapFee);
      _needed[indexTokenB] += _convertTo(_magnitudeA, _amountToSwapTokenA, _pairInSwap.ratioAToB, _swapFee);

      _swapInformation.pairs[i] = _pairInSwap;
    }

    // Note: we are caching this variable in memory so we can read storage only once (it's cheaper that way)
    uint16 _platformFeeRatio = platformFeeRatio;

    _swapInformation.tokens = new TokenInSwap[](_tokens.length);
    for (uint256 i; i < _swapInformation.tokens.length; i++) {
      if (i > 0 && _tokens[i] <= _tokens[i - 1]) {
        revert IDCAHub.InvalidTokens();
      }

      TokenInSwap memory _tokenInSwap;
      _tokenInSwap.token = _tokens[i];

      uint256 _neededInSwap = _needed[i];
      uint256 _totalBeingSwapped = _total[i];

      if (_neededInSwap > 0 || _totalBeingSwapped > 0) {
        uint256 _totalFee = FeeMath.calculateSubtractedFee(_swapFee, _neededInSwap);

        int256 _platformFee = int256((_totalFee * _platformFeeRatio) / MAX_PLATFORM_FEE_RATIO);

        // If diff is negative, we need tokens. If diff is positive, then we have more than is needed
        int256 _diff = int256(_totalBeingSwapped) - int256(_neededInSwap);

        // Instead of checking if diff is positive or not, we compare against the platform fee. This is to avoid any rounding issues
        if (_diff > _platformFee) {
          _tokenInSwap.reward = uint256(_diff - _platformFee);
        } else if (_diff < _platformFee) {
          _tokenInSwap.toProvide = uint256(_platformFee - _diff);
        }
        _tokenInSwap.platformFee = uint256(_platformFee);
      }
      _swapInformation.tokens[i] = _tokenInSwap;
    }
  }

  
  function swap(
    address[] calldata _tokens,
    PairIndexes[] calldata _pairsToSwap,
    address _rewardRecipient,
    address _callbackHandler,
    uint256[] calldata _borrow,
    bytes calldata _data
  ) public nonReentrant whenNotPaused returns (SwapInfo memory _swapInformation) {
    // Note: we are caching this variable in memory so we can read storage only once (it's cheaper that way)
    uint32 _swapFee = swapFee;

    {
      _swapInformation = getNextSwapInfo(_tokens, _pairsToSwap);

      uint32 _timestamp = _getTimestamp();
      bool _executedAPair;
      for (uint256 i; i < _swapInformation.pairs.length; i++) {
        PairInSwap memory _pairInSwap = _swapInformation.pairs[i];
        bytes1 _intervalsInSwap = _pairInSwap.intervalsInSwap;
        bytes1 _mask = 0x01;
        while (_intervalsInSwap >= _mask && _mask > 0) {
          if (_intervalsInSwap & _mask != 0) {
            _registerSwap(
              _pairInSwap.tokenA,
              _pairInSwap.tokenB,
              _mask,
              FeeMath.subtractFeeFromAmount(_swapFee, _pairInSwap.ratioAToB),
              FeeMath.subtractFeeFromAmount(_swapFee, _pairInSwap.ratioBToA),
              _timestamp
            );
          }
          _mask <<= 1;
        }
        _executedAPair = _executedAPair || _intervalsInSwap > 0;
      }

      if (!_executedAPair) {
        revert NoSwapsToExecute();
      }
    }

    uint256[] memory _beforeBalances = new uint256[](_swapInformation.tokens.length);
    for (uint256 i; i < _swapInformation.tokens.length; i++) {
      TokenInSwap memory _tokenInSwap = _swapInformation.tokens[i];
      uint256 _amountToBorrow = _borrow[i];

      // Remember balances before callback
      if (_tokenInSwap.toProvide > 0 || _amountToBorrow > 0) {
        _beforeBalances[i] = _balanceOf(_tokenInSwap.token);
      }

      // Optimistically transfer tokens
      if (_rewardRecipient == _callbackHandler) {
        uint256 _amountToSend = _tokenInSwap.reward + _amountToBorrow;
        if (_amountToSend > 0) {
          _transfer(_tokenInSwap.token, _callbackHandler, _amountToSend);
        }
      } else {
        if (_tokenInSwap.reward > 0) {
          _transfer(_tokenInSwap.token, _rewardRecipient, _tokenInSwap.reward);
        }
        if (_amountToBorrow > 0) {
          _transfer(_tokenInSwap.token, _callbackHandler, _amountToBorrow);
        }
      }
    }

    // Make call
    IDCAHubSwapCallee(_callbackHandler).DCAHubSwapCall(msg.sender, _swapInformation.tokens, _borrow, _data);

    // Checks and balance updates
    for (uint256 i; i < _swapInformation.tokens.length; i++) {
      TokenInSwap memory _tokenInSwap = _swapInformation.tokens[i];
      uint256 _addToPlatformBalance = _tokenInSwap.platformFee;

      if (_tokenInSwap.toProvide > 0 || _borrow[i] > 0) {
        uint256 _amountToHave = _beforeBalances[i] + _tokenInSwap.toProvide - _tokenInSwap.reward;

        uint256 _currentBalance = _balanceOf(_tokenInSwap.token);

        // Make sure tokens were sent back
        if (_currentBalance < _amountToHave) {
          revert IDCAHub.LiquidityNotReturned();
        }

        // Any extra tokens that might have been received, are set as platform balance
        _addToPlatformBalance += (_currentBalance - _amountToHave);
      }

      // Update platform balance
      if (_addToPlatformBalance > 0) {
        platformBalance[_tokenInSwap.token] += _addToPlatformBalance;
      }
    }

    // Emit event
    emit Swapped(msg.sender, _rewardRecipient, _callbackHandler, _swapInformation, _borrow, _swapFee);
  }
}

// 
pragma solidity >=0.8.7 <0.9.0;







abstract contract DCAHubLoanHandler is ReentrancyGuard, DCAHubConfigHandler, IDCAHubLoanHandler {
  using SafeERC20 for IERC20Metadata;

  
  function loan(
    IDCAHub.AmountOfToken[] calldata _loan,
    address _to,
    bytes calldata _data
  ) external nonReentrant whenNotPaused {
    // Note: we are caching this variable in memory so we can read storage only once (it's cheaper that way)
    uint32 _loanFee = loanFee;

    // Remember balances before callback
    uint256[] memory _beforeBalances = new uint256[](_loan.length);
    for (uint256 i; i < _beforeBalances.length; i++) {
      // We are now making sure that tokens are sorted, as an easy way to detect duplicates
      if (i > 0 && _loan[i].token <= _loan[i - 1].token) revert IDCAHub.InvalidTokens();

      _beforeBalances[i] = _balanceOf(_loan[i].token);
    }

    // Transfer tokens
    for (uint256 i; i < _loan.length; i++) {
      _transfer(_loan[i].token, _to, _loan[i].amount);
    }

    // Make call
    IDCAHubLoanCallee(_to).DCAHubLoanCall(msg.sender, _loan, _loanFee, _data);

    for (uint256 i; i < _loan.length; i++) {
      uint256 _afterBalance = _balanceOf(_loan[i].token);

      // Make sure that they sent the tokens back
      if (_afterBalance < _beforeBalances[i] + FeeMath.calculateFeeForAmount(_loanFee, _loan[i].amount)) {
        revert IDCAHub.LiquidityNotReturned();
      }

      // Update platform balance
      platformBalance[_loan[i].token] += _afterBalance - _beforeBalances[i];
    }

    // Emit event
    emit Loaned(msg.sender, _to, _loan, _loanFee);
  }
}

// 
pragma solidity >=0.8.7 <0.9.0;





abstract contract DCAHubPlatformHandler is ReentrancyGuard, DCAHubConfigHandler, IDCAHubPlatformHandler {
  using SafeERC20 for IERC20Metadata;

  
  function withdrawFromPlatformBalance(IDCAHub.AmountOfToken[] calldata _amounts, address _recipient)
    external
    nonReentrant
    onlyRole(PLATFORM_WITHDRAW_ROLE)
  {
    for (uint256 i; i < _amounts.length; i++) {
      platformBalance[_amounts[i].token] -= _amounts[i].amount;
      IERC20Metadata(_amounts[i].token).safeTransfer(_recipient, _amounts[i].amount);
    }

    emit WithdrewFromPlatform(msg.sender, _recipient, _amounts);
  }
}

interface IDCAHub is
  IDCAHubParameters,
  IDCAHubConfigHandler,
  IDCAHubSwapHandler,
  IDCAHubPositionHandler,
  IDCAHubLoanHandler,
  IDCAHubPlatformHandler
{
  
  struct AmountOfToken {
    // The tokens' address
    address token;
    // How much to borrow or withdraw of the specified token
    uint256 amount;
  }

  
  error ZeroAddress();

  
  error LiquidityNotReturned();

  
  error InvalidTokens();
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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
}
// 
pragma solidity >=0.8.7 <0.9.0;








contract DCAHub is
  DCAHubParameters,
  DCAHubConfigHandler,
  DCAHubSwapHandler,
  DCAHubPositionHandler,
  DCAHubLoanHandler,
  DCAHubPlatformHandler,
  IDCAHub
{
  constructor(
    address _immediateGovernor,
    address _timeLockedGovernor,
    IPriceOracle _oracle,
    IDCAPermissionManager _permissionManager
  ) DCAHubPositionHandler(_permissionManager) DCAHubConfigHandler(_immediateGovernor, _timeLockedGovernor, _oracle) {}

  
  function paused() public view override(IDCAHubConfigHandler, DCAHubConfigHandler) returns (bool) {
    return super.paused();
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
pragma solidity >0.6;



library TokenSorting {
  
  
  
  
  
  function sortTokens(address _tokenA, address _tokenB) internal pure returns (address __tokenA, address __tokenB) {
    (__tokenA, __tokenB) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
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
pragma solidity >=0.8.7 <0.9.0;






interface IDCAPermissionManager is IERC721 {
  
  enum Permission {
    INCREASE,
    REDUCE,
    WITHDRAW,
    TERMINATE
  }

  
  struct PermissionSet {
    // The address of the operator
    address operator;
    // The permissions given to the overator
    Permission[] permissions;
  }

  
  
  
  event Modified(uint256 tokenId, PermissionSet[] permissions);

  
  
  event NFTDescriptorSet(IDCATokenDescriptor descriptor);

  
  error HubAlreadySet();

  
  error ZeroAddress();

  
  error OnlyHubCanExecute();

  
  error NotOwner();

  
  error ExpiredDeadline();

  
  error InvalidSignature();

  
  
  // solhint-disable-next-line func-name-mixedcase
  function PERMIT_TYPEHASH() external pure returns (bytes32);

  
  
  // solhint-disable-next-line func-name-mixedcase
  function PERMISSION_PERMIT_TYPEHASH() external pure returns (bytes32);

  
  
  // solhint-disable-next-line func-name-mixedcase
  function PERMISSION_SET_TYPEHASH() external pure returns (bytes32);

  
  
  // solhint-disable-next-line func-name-mixedcase
  function DOMAIN_SEPARATOR() external view returns (bytes32);

  
  
  function nftDescriptor() external returns (IDCATokenDescriptor);

  
  
  function hub() external returns (address);

  
  
  
  function nonces(address _user) external returns (uint256 _nonce);

  
  
  
  
  
  function hasPermission(
    uint256 _id,
    address _address,
    Permission _permission
  ) external view returns (bool);

  
  
  
  
  
  function hasPermissions(
    uint256 _id,
    address _address,
    Permission[] calldata _permissions
  ) external view returns (bool[] memory _hasPermissions);

  
  
  /// Will revert:
  /// With ZeroAddress if address is zero
  /// With HubAlreadySet if the hub has already been set
  
  function setHub(address _hub) external;

  
  
  
  
  
  function mint(
    uint256 _id,
    address _owner,
    PermissionSet[] calldata _permissions
  ) external;

  
  
  
  function burn(uint256 _id) external;

  
  
  /// Operators that are not part of the given permission sets do not see their permissions modified.
  /// In order to remove permissions to an operator, provide an empty list of permissions for them
  
  
  function modify(uint256 _id, PermissionSet[] calldata _permissions) external;

  
  
  
  
  
  
  
  function permit(
    address _spender,
    uint256 _tokenId,
    uint256 _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external;

  
  
  
  
  
  
  
  
  function permissionPermit(
    PermissionSet[] calldata _permissions,
    uint256 _tokenId,
    uint256 _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external;

  
  
  
  function setNFTDescriptor(IDCATokenDescriptor _descriptor) external;
}

// 
pragma solidity >=0.5.0;



interface IPriceOracle {
  
  
  
  
  
  function canSupportPair(address _tokenA, address _tokenB) external view returns (bool);

  
  
  
  
  
  function quote(
    address _tokenIn,
    uint128 _amountIn,
    address _tokenOut
  ) external view returns (uint256 _amountOut);

  
  /// preparation for future quotes. Can be called many times in order to let the oracle re-configure for a new context.
  
  
  
  function reconfigureSupportForPair(address _tokenA, address _tokenB) external;

  
  /// then nothing will happen. This function will let the oracle take some actions to configure the pair, in preparation for future quotes.
  
  
  
  function addSupportForPairIfNeeded(address _tokenA, address _tokenB) external;
}

// 
pragma solidity >=0.8.7 <0.9.0;



interface IDCATokenDescriptor {
  
  error InvalidInterval();

  
  
  
  
  function tokenURI(address _hub, uint256 _tokenId) external view returns (string memory _description);

  
  
  
  
  function intervalToDescription(uint32 _swapInterval) external pure returns (string memory _description);
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
pragma solidity >=0.8.7 <0.9.0;



library Intervals {
  
  error InvalidInterval();

  
  error InvalidMask();

  
  
  
  
  function intervalToMask(uint32 _swapInterval) internal pure returns (bytes1) {
    if (_swapInterval == 1 minutes) return 0x01;
    if (_swapInterval == 5 minutes) return 0x02;
    if (_swapInterval == 15 minutes) return 0x04;
    if (_swapInterval == 30 minutes) return 0x08;
    if (_swapInterval == 1 hours) return 0x10;
    if (_swapInterval == 4 hours) return 0x20;
    if (_swapInterval == 1 days) return 0x40;
    if (_swapInterval == 1 weeks) return 0x80;
    revert InvalidInterval();
  }

  
  
  
  
  function maskToInterval(bytes1 _mask) internal pure returns (uint32) {
    if (_mask == 0x01) return 1 minutes;
    if (_mask == 0x02) return 5 minutes;
    if (_mask == 0x04) return 15 minutes;
    if (_mask == 0x08) return 30 minutes;
    if (_mask == 0x10) return 1 hours;
    if (_mask == 0x20) return 4 hours;
    if (_mask == 0x40) return 1 days;
    if (_mask == 0x80) return 1 weeks;
    revert InvalidMask();
  }

  
  
  
  
  function intervalsInByte(bytes1 _byte) internal pure returns (uint32[] memory _intervals) {
    _intervals = new uint32[](8);
    uint8 _index;
    bytes1 _mask = 0x01;
    while (_byte >= _mask && _mask > 0) {
      if (_byte & _mask != 0) {
        _intervals[_index++] = maskToInterval(_mask);
      }
      _mask <<= 1;
    }
  }
}

// 
pragma solidity >=0.8.7 <0.9.0;



library FeeMath {
  
  uint24 public constant FEE_PRECISION = 10000;

  
  
  
  
  function calculateSubtractedFee(uint32 _fee, uint256 _subtractionResult) internal pure returns (uint256) {
    return (_subtractionResult * _fee) / (FEE_PRECISION * 100 - _fee);
  }

  
  
  
  
  function calculateFeeForAmount(uint32 _fee, uint256 _amount) internal pure returns (uint256) {
    return (_amount * _fee) / FEE_PRECISION / 100;
  }

  
  
  
  
  function subtractFeeFromAmount(uint32 _fee, uint256 _amount) internal pure returns (uint256) {
    return (_amount * (FEE_PRECISION - _fee / 100)) / FEE_PRECISION;
  }
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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

// 
// OpenZeppelin Contracts v4.4.1 (utils/math/Math.sol)

pragma solidity ^0.8.0;

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
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// 
pragma solidity >=0.8.7 <0.9.0;






interface IDCAHubSwapCallee {
  // solhint-disable-next-line func-name-mixedcase
  function DCAHubSwapCall(
    address _sender,
    IDCAHub.TokenInSwap[] calldata _tokens,
    uint256[] calldata _borrowed,
    bytes calldata _data
  ) external;
}

// 
pragma solidity >=0.8.7 <0.9.0;






interface IDCAHubLoanCallee {
  // solhint-disable-next-line func-name-mixedcase
  function DCAHubLoanCall(
    address _sender,
    IDCAHub.AmountOfToken[] calldata _loan,
    uint32 _loanFee,
    bytes calldata _data
  ) external;
}