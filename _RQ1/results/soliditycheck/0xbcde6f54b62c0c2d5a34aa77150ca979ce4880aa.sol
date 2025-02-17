// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;


// 

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;



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
        return !AddressUpgradeable.isContract(address(this));
    }
}

// 

pragma solidity >=0.6.0 <0.8.0;


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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// 

pragma solidity >=0.6.0 <0.8.0;






/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
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
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

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
     * bearer except when using {_setupRole}.
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
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
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
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

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
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

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
    function renounceRole(bytes32 role, address account) public virtual {
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
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}

// 

pragma solidity 0.7.6;



contract RoleCheckable is AccessControlUpgradeable {
    /* ACR Roles*/

    // keccak256("DEFAULT_ADMIN_ROLE");
    bytes32 internal constant ADMIN_ROLE = 0x1effbbff9c66c5e59634f24fe842750c60d18891155c32dd155fc2d661a4c86d;
    // keccak256("CONTROLLER_ROLE")
    bytes32 internal constant CONTROLLER_ROLE = 0x7b765e0e932d348852a6f810bfa1ab891e259123f02db8cdcde614c570223357;
    // keccak256("START_FUTURE")
    bytes32 internal constant START_FUTURE = 0xeb5092aab714e6356486bc97f25dd7a5c1dc5c7436a9d30e8d4a527fba24de1c;
    // keccak256("FUTURE_ROLE")
    bytes32 internal constant FUTURE_ROLE = 0x52d2dbc4d362e84c42bdfb9941433968ba41423559d7559b32db1183b22b148f;
    // keccak256("HARVEST_REWARDS")
    bytes32 internal constant HARVEST_REWARDS = 0xf2683e58e5a2a04c1ed32509bfdbf1e9ebc725c63f4c95425d2afd482bfdb0f8;

    /* Modifiers */

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "RoleCheckable: Caller should be ADMIN");
        _;
    }

    modifier onlyStartFuture() {
        require(hasRole(START_FUTURE, msg.sender), "RoleCheckable: Caller should have START FUTURE Role");
        _;
    }

    modifier onlyHarvestReward() {
        require(hasRole(HARVEST_REWARDS, msg.sender), "RoleCheckable: Caller should have HARVEST REWARDS Role");
        _;
    }

    modifier onlyController() {
        require(hasRole(CONTROLLER_ROLE, msg.sender), "RoleCheckable: Caller should be CONTROLLER");
        _;
    }
}
// 

pragma solidity >=0.6.0 <0.8.0;


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

pragma solidity 0.7.6;





contract RegistryStorage is RoleCheckable {
    IRegistry internal registry;

    event RegistryChanged(IRegistry _registry);

    /* User Methods */

    /**
     * @notice Setter for the registry address
     * @param _registry the address of the new registry
     */
    function setRegistry(IRegistry _registry) external onlyAdmin {
        registry = _registry;
        emit RegistryChanged(_registry);
    }
}

// 

pragma solidity 0.7.6;



















/**
 * @title Main future abstraction contract
 * @notice Handles the future mechanisms
 * @dev Basis of all mecanisms for futures (registrations, period switch)
 */
abstract contract FutureVault is Initializable, RegistryStorage, ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using SafeERC20Upgradeable for IERC20;

    /* State variables */
    mapping(uint256 => uint256) internal collectedFYTSByPeriod;
    mapping(uint256 => uint256) internal premiumsTotal;

    mapping(address => uint256) internal lastPeriodClaimed;
    mapping(address => uint256) internal premiumToBeRedeemed;
    mapping(address => uint256) internal FYTsOfUserPremium;

    mapping(address => uint256) internal claimableFYTByUser;
    mapping(uint256 => uint256) internal yieldOfPeriod;
    uint256 internal totalUnderlyingDeposited;

    bool private terminated;
    uint256 internal performanceFeeFactor;

    IFutureYieldToken[] internal fyts;
    /* Delegation */
    struct Delegation {
        address receiver;
        uint256 delegatedAmount;
    }

    mapping(address => Delegation[]) internal delegationsByDelegator;
    mapping(address => uint256) internal totalDelegationsReceived;

    /* External contracts */
    IFutureWallet internal futureWallet;
    IERC20 internal ibt;
    IPT internal pt;
    IController internal controller;

    /* Settings */
    uint256 public PERIOD_DURATION;
    string public PLATFORM_NAME;

    /* Constants */
    uint256 internal IBT_UNIT;
    uint256 internal IBT_UNITS_MULTIPLIED_VALUE;
    uint256 constant UNIT = 10**18;

    /* Events */
    event NewPeriodStarted(uint256 _newPeriodIndex);
    event FutureWalletSet(IFutureWallet _futureWallet);
    event FundsDeposited(address _user, uint256 _amount);
    event FundsWithdrawn(address _user, uint256 _amount);
    event PTSet(IPT _pt);
    event LiquidityTransfersPaused();
    event LiquidityTransfersResumed();
    event DelegationCreated(address _delegator, address _receiver, uint256 _amount);
    event DelegationRemoved(address _delegator, address _receiver, uint256 _amount);

    /* Modifiers */
    modifier nextPeriodAvailable() {
        uint256 controllerDelay = controller.STARTING_DELAY();
        require(
            controller.getNextPeriodStart(PERIOD_DURATION) < block.timestamp.add(controllerDelay),
            "FutureVault: ERR_PERIOD_RANGE"
        );
        _;
    }

    modifier periodsActive() {
        require(!terminated, "PERIOD_TERMINATED");
        _;
    }

    modifier withdrawalsEnabled() {
        require(!controller.isWithdrawalsPaused(address(this)), "FutureVault: WITHDRAWALS_DISABLED");
        _;
    }

    modifier depositsEnabled() {
        require(
            !controller.isDepositsPaused(address(this)) && getCurrentPeriodIndex() != 0,
            "FutureVault: DEPOSITS_DISABLED"
        );
        _;
    }

    /* Initializer */
    /**
     * @notice Intializer
     * @param _controller the address of the controller
     * @param _ibt the address of the corresponding IBT
     * @param _periodDuration the length of the period (in days)
     * @param _platformName the name of the platform and tools
     * @param _admin the address of the ACR admin
     */
    function initialize(
        IController _controller,
        IERC20 _ibt,
        uint256 _periodDuration,
        string memory _platformName,
        address _admin
    ) public virtual initializer {
        controller = _controller;
        ibt = _ibt;
        IBT_UNIT = 10**ibt.decimals();
        IBT_UNITS_MULTIPLIED_VALUE = UNIT * IBT_UNIT;
        PERIOD_DURATION = _periodDuration * (1 days);
        PLATFORM_NAME = _platformName;
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(ADMIN_ROLE, _admin);
        _setupRole(CONTROLLER_ROLE, address(_controller));

        fyts.push();

        registry = IRegistry(controller.getRegistryAddress());

        pt = IPT(
            ITokensFactory(IRegistry(controller.getRegistryAddress()).getTokensFactoryAddress()).deployPT(
                ibt.symbol(),
                ibt.decimals(),
                PLATFORM_NAME,
                PERIOD_DURATION
            )
        );

        emit PTSet(pt);
    }

    /* Period functions */

    /**
     * @notice Start a new period
     * @dev needs corresponding permissions for sender
     */
    function startNewPeriod() public virtual;

    function _switchPeriod() internal periodsActive {
        uint256 nextPeriodID = getNextPeriodIndex();
        uint256 yield = getUnrealisedYieldPerPT().mul(totalUnderlyingDeposited) / IBT_UNIT;

        uint256 reinvestedYield;
        if (yield > 0) {
            uint256 currentPeriodIndex = getCurrentPeriodIndex();
            uint256 premiums = convertUnderlyingtoIBT(premiumsTotal[currentPeriodIndex]);
            uint256 performanceFee = (yield.mul(performanceFeeFactor) / UNIT).sub(premiums);
            uint256 remainingYield = yield.sub(performanceFee);
            yieldOfPeriod[currentPeriodIndex] = convertIBTToUnderlying(
                remainingYield.mul(UNIT).div(totalUnderlyingDeposited)
            );
            uint256 collectedYield = remainingYield.mul(collectedFYTSByPeriod[currentPeriodIndex]).div(
                totalUnderlyingDeposited
            );
            reinvestedYield = remainingYield.sub(collectedYield);
            futureWallet.registerExpiredFuture(collectedYield); // Yield deposit in the futureWallet contract

            if (performanceFee > 0) ibt.safeTransfer(registry.getTreasuryAddress(), performanceFee);
            if (remainingYield > 0) ibt.safeTransfer(address(futureWallet), collectedYield);
        } else {
            futureWallet.registerExpiredFuture(0);
        }

        /* Period Switch*/
        totalUnderlyingDeposited = totalUnderlyingDeposited.add(convertIBTToUnderlying(reinvestedYield)); // Add newly reinvested yield as underlying
        if (!controller.isFutureSetToBeTerminated(address(this))) {
            _deployNewFutureYieldToken(nextPeriodID);
            emit NewPeriodStarted(nextPeriodID);
        } else {
            terminated = true;
        }

        uint256 nextPerformanceFeeFactor = controller.getNextPerformanceFeeFactor(address(this));
        if (nextPerformanceFeeFactor != performanceFeeFactor) performanceFeeFactor = nextPerformanceFeeFactor;
    }

    /* User state */

    /**
     * @notice Update the state of the user and mint claimable pt
     * @param _user user adress
     */
    function updateUserState(address _user) public {
        uint256 currentPeriodIndex = getCurrentPeriodIndex();
        uint256 lastPeriodClaimedOfUser = lastPeriodClaimed[_user];
        if (lastPeriodClaimedOfUser < currentPeriodIndex && lastPeriodClaimedOfUser != 0) {
            pt.mint(_user, _preparePTClaim(_user));
        }
        if (lastPeriodClaimedOfUser != currentPeriodIndex) lastPeriodClaimed[_user] = currentPeriodIndex;
    }

    function _preparePTClaim(address _user) internal virtual returns (uint256 claimablePT) {
        uint256 currentPeriodIndex = getCurrentPeriodIndex();
        if (lastPeriodClaimed[_user] < currentPeriodIndex) {
            claimablePT = getClaimablePT(_user);
            delete premiumToBeRedeemed[_user];
            delete FYTsOfUserPremium[_user];
            lastPeriodClaimed[_user] = currentPeriodIndex;
            claimableFYTByUser[_user] = pt.balanceOf(_user).add(totalDelegationsReceived[_user]).sub(
                getTotalDelegated(_user)
            );
        }
    }

    /**
     * @notice Deposit funds into ongoing period
     * @param _user user adress
     * @param _amount amount of funds to unlock
     * @dev part of the amount deposited will be used to buy back the yield already generated proportionally to the amount deposited
     */
    function deposit(address _user, uint256 _amount) external virtual periodsActive depositsEnabled onlyController {
        require((_amount > 0) && (_amount <= ibt.balanceOf(_user)), "FutureVault: ERR_AMOUNT");
        _deposit(_user, _amount);
        emit FundsDeposited(_user, _amount);
    }

    function _deposit(address _user, uint256 _amount) internal {
        uint256 underlyingDeposited = getPTPerAmountDeposited(_amount);
        uint256 ptToMint = _preparePTClaim(_user).add(underlyingDeposited);
        uint256 currentPeriodIndex = getCurrentPeriodIndex();

        /* Update premium */
        uint256 redeemable = getPremiumPerUnderlyingDeposited(convertIBTToUnderlying(_amount));
        premiumToBeRedeemed[_user] = premiumToBeRedeemed[_user].add(redeemable);
        FYTsOfUserPremium[_user] = FYTsOfUserPremium[_user].add(ptToMint);
        premiumsTotal[currentPeriodIndex] = premiumsTotal[currentPeriodIndex].add(redeemable);

        /* Update State and mint pt*/
        totalUnderlyingDeposited = totalUnderlyingDeposited.add(underlyingDeposited);
        claimableFYTByUser[_user] = claimableFYTByUser[_user].add(ptToMint);

        pt.mint(_user, ptToMint);
    }

    /**
     * @notice Sender unlocks the locked funds corresponding to their pt holding
     * @param _user user adress
     * @param _amount amount of funds to unlock
     * @dev will require a transfer of FYT of the ongoing period corresponding to the funds unlocked
     */
    function withdraw(address _user, uint256 _amount) external virtual nonReentrant withdrawalsEnabled onlyController {
        require((_amount > 0) && (_amount <= pt.balanceOf(_user)), "FutureVault: ERR_AMOUNT");
        require(_amount <= fyts[getCurrentPeriodIndex()].balanceOf(_user), "FutureVault: ERR_FYT_AMOUNT");
        _withdraw(_user, _amount);

        uint256 FYTsToBurn;
        uint256 currentPeriodIndex = getCurrentPeriodIndex();
        uint256 FYTSMinted = fyts[currentPeriodIndex].recordedBalanceOf(_user);
        if (_amount > FYTSMinted) {
            FYTsToBurn = FYTSMinted;
            uint256 ClaimableFYTsToBurn = _amount - FYTsToBurn;
            claimableFYTByUser[_user] = claimableFYTByUser[_user].sub(ClaimableFYTsToBurn, "FutureVault: ERR_AMOUNT");
            collectedFYTSByPeriod[currentPeriodIndex] = collectedFYTSByPeriod[currentPeriodIndex].add(ClaimableFYTsToBurn);
        } else {
            FYTsToBurn = _amount;
        }

        if (FYTsToBurn > 0) fyts[currentPeriodIndex].burnFrom(_user, FYTsToBurn);

        emit FundsWithdrawn(_user, _amount);
    }

    /**
     * @notice Internal function for withdrawing funds corresponding to the pt holding of an address
     * @param _user user adress
     * @param _amount amount of funds to unlock
     * @dev handle the logic of withdraw but does not burn fyts
     */
    function _withdraw(address _user, uint256 _amount) internal virtual {
        updateUserState(_user);
        uint256 fundsToBeUnlocked = _amount.mul(getUnlockableFunds(_user)).div(pt.balanceOf(_user));
        uint256 yieldToBeUnlocked = _amount.mul(getUnrealisedYieldPerPT()) / IBT_UNIT;

        uint256 premiumToBeUnlocked = _prepareUserEarlyPremiumUnlock(_user, _amount);

        uint256 treasuryFee = (yieldToBeUnlocked.mul(performanceFeeFactor) / UNIT).sub(premiumToBeUnlocked);
        uint256 yieldToBeRedeemed = yieldToBeUnlocked - treasuryFee;
        ibt.safeTransfer(_user, fundsToBeUnlocked.add(yieldToBeRedeemed).add(premiumToBeUnlocked));

        if (treasuryFee > 0) {
            ibt.safeTransfer(registry.getTreasuryAddress(), treasuryFee);
        }
        totalUnderlyingDeposited = totalUnderlyingDeposited.sub(_amount);
        pt.burnFrom(_user, _amount);
    }

    function _prepareUserEarlyPremiumUnlock(address _user, uint256 _ptShares)
        internal
        returns (uint256 premiumToBeUnlocked)
    {
        uint256 unlockablePremium = premiumToBeRedeemed[_user];
        uint256 userFYTsInPremium = FYTsOfUserPremium[_user];
        if (unlockablePremium > 0) {
            if (_ptShares > userFYTsInPremium) {
                premiumToBeUnlocked = convertUnderlyingtoIBT(unlockablePremium);
                delete premiumToBeRedeemed[_user];
                delete FYTsOfUserPremium[_user];
            } else {
                uint256 premiumForAmount = unlockablePremium.mul(_ptShares).div(userFYTsInPremium);
                premiumToBeUnlocked = convertUnderlyingtoIBT(premiumForAmount);
                premiumToBeRedeemed[_user] = unlockablePremium - premiumForAmount;
                FYTsOfUserPremium[_user] = userFYTsInPremium - _ptShares;
            }
        }
    }

    /**
     * @notice Getter for the amount (in underlying) of premium redeemable with the corresponding amount of fyt/pt to be burned
     * @param _user user adress
     * @return premiumLocked the premium amount unlockage at this period (in underlying), amountRequired the amount of pt/fyt required for that operation
     */
    function getUserEarlyUnlockablePremium(address _user)
        public
        view
        returns (uint256 premiumLocked, uint256 amountRequired)
    {
        premiumLocked = premiumToBeRedeemed[_user];
        amountRequired = FYTsOfUserPremium[_user];
    }

    /* Delegation */

    /**
     * @notice Create a delegation from one address to another
     * @param _delegator the address delegating its future FYTs
     * @param _receiver the address receiving the future FYTs
     * @param _amount the of future FYTs to delegate
     */
    function createFYTDelegationTo(
        address _delegator,
        address _receiver,
        uint256 _amount
    ) public nonReentrant periodsActive {
        require(hasRole(CONTROLLER_ROLE, msg.sender), "ERR_CALLER");
        updateUserState(_delegator);
        updateUserState(_receiver);
        uint256 totalDelegated = getTotalDelegated(_delegator);
        uint256 numberOfDelegations = delegationsByDelegator[_delegator].length;
        require(_amount > 0 && _amount <= pt.balanceOf(_delegator).sub(totalDelegated), "FutureVault: ERR_AMOUNT");

        bool delegated;
        for (uint256 i = 0; i < numberOfDelegations; i++) {
            if (delegationsByDelegator[_delegator][i].receiver == _receiver) {
                delegationsByDelegator[_delegator][i].delegatedAmount = delegationsByDelegator[_delegator][i]
                    .delegatedAmount
                    .add(_amount);
                delegated = true;
                break;
            }
        }
        if (!delegated) {
            delegationsByDelegator[_delegator].push(Delegation({ receiver: _receiver, delegatedAmount: _amount }));
        }
        totalDelegationsReceived[_receiver] = totalDelegationsReceived[_receiver].add(_amount);
        emit DelegationCreated(_delegator, _receiver, _amount);
    }

    /**
     * @notice Remove a delegation from one address to another
     * @param _delegator the address delegating its future FYTs
     * @param _receiver the address receiving the future FYTs
     * @param _amount the of future FYTs to remove from the delegation
     */
    function withdrawFYTDelegationFrom(
        address _delegator,
        address _receiver,
        uint256 _amount
    ) public {
        require(hasRole(CONTROLLER_ROLE, msg.sender), "ERR_CALLER");
        updateUserState(_delegator);
        updateUserState(_receiver);

        uint256 numberOfDelegations = delegationsByDelegator[_delegator].length;
        bool removed;
        for (uint256 i = 0; i < numberOfDelegations; i++) {
            if (delegationsByDelegator[_delegator][i].receiver == _receiver) {
                delegationsByDelegator[_delegator][i].delegatedAmount = delegationsByDelegator[_delegator][i]
                    .delegatedAmount
                    .sub(_amount, "ERR_AMOUNT");
                removed = true;
                break;
            }
        }
        require(_amount > 0 && removed, "FutureVault: ERR_AMOUNT");
        totalDelegationsReceived[_receiver] = totalDelegationsReceived[_receiver].sub(_amount);
        emit DelegationRemoved(_delegator, _receiver, _amount);
    }

    /**
     * @notice Getter the total number of FYTs on address is delegating
     * @param _delegator the delegating address
     * @return totalDelegated the number of FYTs delegated
     */
    function getTotalDelegated(address _delegator) public view returns (uint256 totalDelegated) {
        uint256 numberOfDelegations = delegationsByDelegator[_delegator].length;
        for (uint256 i = 0; i < numberOfDelegations; i++) {
            totalDelegated = totalDelegated.add(delegationsByDelegator[_delegator][i].delegatedAmount);
        }
    }

    /* Claim functions */

    /**
     * @notice Send the user their owed FYT (and pt if there are some claimable)
     * @param _user address of the user to send the FYT to
     */
    function claimFYT(address _user, uint256 _amount) external virtual nonReentrant {
        require(msg.sender == address(fyts[getCurrentPeriodIndex()]), "FutureVault: ERR_CALLER");
        updateUserState(_user);
        _claimFYT(_user, _amount);
    }

    function _claimFYT(address _user, uint256 _amount) internal virtual {
        uint256 currentPeriodIndex = getCurrentPeriodIndex();
        claimableFYTByUser[_user] = claimableFYTByUser[_user].sub(_amount, "ERR_CLAIMED_FYT_AMOUNT");
        fyts[currentPeriodIndex].mint(_user, _amount);
        collectedFYTSByPeriod[currentPeriodIndex] = collectedFYTSByPeriod[currentPeriodIndex].add(_amount);
    }

    /* Termination of the pool */

    /**
     * @notice Exit a terminated pool
     * @param _user the user to exit from the pool
     * @dev only pt are required as there  aren't any new FYTs
     */
    function exitTerminatedFuture(address _user) external nonReentrant onlyController {
        require(terminated, "FutureVault: ERR_NOT_TERMINATED");
        uint256 amount = pt.balanceOf(_user);
        require(amount > 0, "FutureVault: ERR_PT_BALANCE");
        _withdraw(_user, amount);
        emit FundsWithdrawn(_user, amount);
    }

    /* Utilitary functions */

    function convertIBTToUnderlying(uint256 _amount) public view virtual returns (uint256);

    function convertUnderlyingtoIBT(uint256 _amount) public view virtual returns (uint256);

    function _deployNewFutureYieldToken(uint256 newPeriodIndex) internal {
        IFutureYieldToken newToken = IFutureYieldToken(
            ITokensFactory(registry.getTokensFactoryAddress()).deployNextFutureYieldToken(newPeriodIndex)
        );
        fyts.push(newToken);
    }

    /* Getters */

    /**
     * @notice Getter for the amount of pt that the user can claim
     * @param _user user to check the check the claimable pt of
     * @return the amount of pt claimable by the user
     */
    function getClaimablePT(address _user) public view virtual returns (uint256) {
        uint256 currentPeriodIndex = getCurrentPeriodIndex();

        if (lastPeriodClaimed[_user] < currentPeriodIndex) {
            uint256 recordedBalance = pt.recordedBalanceOf(_user);
            uint256 mintablePT = (recordedBalance).add(premiumToBeRedeemed[_user]); // add premium
            mintablePT = mintablePT.add(totalDelegationsReceived[_user]).sub(getTotalDelegated(_user)); // add delegated FYTs
            uint256 userStackingGrowthFactor = yieldOfPeriod[lastPeriodClaimed[_user]];
            if (userStackingGrowthFactor > 0) {
                mintablePT = mintablePT.add(claimableFYTByUser[_user].mul(userStackingGrowthFactor) / IBT_UNIT); // add reinvested FYTs
            }
            for (uint256 i = lastPeriodClaimed[_user] + 1; i < currentPeriodIndex; i++) {
                mintablePT = mintablePT.add(yieldOfPeriod[i].mul(mintablePT) / IBT_UNIT);
            }
            return mintablePT.add(getTotalDelegated(_user)).sub(recordedBalance).sub(totalDelegationsReceived[_user]);
        } else {
            return 0;
        }
    }

    /**
     * @notice Getter for user IBT amount that is unlockable
     * @param _user the user to unlock the IBT from
     * @return the amount of IBT the user can unlock
     */
    function getUnlockableFunds(address _user) public view virtual returns (uint256) {
        return pt.balanceOf(_user);
    }

    /**
     * @notice Getter for the amount of FYT that the user can claim for a certain period
     * @param _user the user to check the claimable FYT of
     * @param _periodIndex period ID to check the claimable FYT of
     * @return the amount of FYT claimable by the user for this period ID
     */
    function getClaimableFYTForPeriod(address _user, uint256 _periodIndex) external view virtual returns (uint256) {
        uint256 currentPeriodIndex = getCurrentPeriodIndex();

        if (_periodIndex != currentPeriodIndex || _user == address(this)) {
            return 0;
        } else if (_periodIndex == currentPeriodIndex && lastPeriodClaimed[_user] == currentPeriodIndex) {
            return claimableFYTByUser[_user];
        } else {
            return pt.balanceOf(_user).add(totalDelegationsReceived[_user]).sub(getTotalDelegated(_user));
        }
    }

    /**
     * @notice Getter for the yield currently generated by one pt for the current period
     * @return the amount of yield (in IBT) generated during the current period
     */
    function getUnrealisedYieldPerPT() public view virtual returns (uint256);

    /**
     * @notice Getter for the number of pt that can be minted for an amoumt deposited now
     * @param _amount the amount to of IBT to deposit
     * @return the number of pt that can be minted for that amount
     */
    function getPTPerAmountDeposited(uint256 _amount) public view virtual returns (uint256);

    /**
     * @notice Getter for premium in underlying tokens that can be redeemed at the end of the period of the deposit
     * @param _amount the amount to of underlying deposited
     * @return the number of underlying of the ibt deposited that will be redeemable
     */
    function getPremiumPerUnderlyingDeposited(uint256 _amount) public view virtual returns (uint256) {
        if (totalUnderlyingDeposited == 0) {
            return 0;
        }
        uint256 yieldPerFYT = getUnrealisedYieldPerPT();
        uint256 premiumToRefundInIBT = _amount.mul(yieldPerFYT).mul(performanceFeeFactor) / IBT_UNITS_MULTIPLIED_VALUE;
        return convertIBTToUnderlying(premiumToRefundInIBT);
    }

    /**
     * @notice Getter for the value (in underlying) of the unlockable premium
     * @param _user user adress
     * @return the unlockable premium
     */
    function getUnlockablePremium(address _user) public view returns (uint256) {
        if (lastPeriodClaimed[_user] != getCurrentPeriodIndex()) {
            return 0;
        } else {
            return premiumToBeRedeemed[_user];
        }
    }

    /**
     * @notice Getter for the total yield generated during one period
     * @param _periodID the period id
     * @return the total yield in underlying value
     */
    function getYieldOfPeriod(uint256 _periodID) external view returns (uint256) {
        require(getCurrentPeriodIndex() > _periodID, "FutureVault: Invalid period ID");
        return yieldOfPeriod[_periodID];
    }

    /**
     * @notice Getter for next period index
     * @return next period index
     * @dev index starts at 1
     */
    function getNextPeriodIndex() public view virtual returns (uint256) {
        return fyts.length;
    }

    /**
     * @notice Getter for current period index
     * @return current period index
     * @dev index starts at 1
     */
    function getCurrentPeriodIndex() public view virtual returns (uint256) {
        return fyts.length - 1;
    }

    /**
     * @notice Getter for total underlying deposited in the vault
     * @return the total amount of funds deposited in the vault (in underlying)
     */
    function getTotalUnderlyingDeposited() external view returns (uint256) {
        return totalUnderlyingDeposited;
    }

    /**
     * @notice Getter for controller address
     * @return the controller address
     */
    function getControllerAddress() public view returns (address) {
        return address(controller);
    }

    /**
     * @notice Getter for futureWallet address
     * @return futureWallet address
     */
    function getFutureWalletAddress() public view returns (address) {
        return address(futureWallet);
    }

    /**
     * @notice Getter for the IBT address
     * @return IBT address
     */
    function getIBTAddress() public view returns (address) {
        return address(ibt);
    }

    /**
     * @notice Getter for future pt address
     * @return pt address
     */
    function getPTAddress() public view returns (address) {
        return address(pt);
    }

    /**
     * @notice Getter for FYT address of a particular period
     * @param _periodIndex period index
     * @return FYT address
     */
    function getFYTofPeriod(uint256 _periodIndex) public view returns (address) {
        return address(fyts[_periodIndex]);
    }

    /**
     * @notice Getter for the terminated state of the future
     * @return true if this vault is terminated
     */
    function isTerminated() public view returns (bool) {
        return terminated;
    }

    /**
     * @notice Getter for the performance fee factor of the current period
     * @return the performance fee factor of the futureVault
     */
    function getPerformanceFeeFactor() external view returns (uint256) {
        return performanceFeeFactor;
    }

    /* Admin function */
    /**
     * @notice Set futureWallet address
     * @param _futureWallet the address of the new futureWallet
     * @dev needs corresponding permissions for sender
     */
    function setFutureWallet(IFutureWallet _futureWallet) external onlyAdmin {
        futureWallet = _futureWallet;
        emit FutureWalletSet(_futureWallet);
    }

    /**
     * @notice Pause liquidity transfers
     */
    function pauseLiquidityTransfers() public {
        require(hasRole(ADMIN_ROLE, msg.sender), "ERR_CALLER");
        pt.pause();
        emit LiquidityTransfersPaused();
    }

    /**
     * @notice Resume liquidity transfers
     */
    function resumeLiquidityTransfers() public {
        require(hasRole(ADMIN_ROLE, msg.sender), "ERR_CALLER");
        pt.unpause();
        emit LiquidityTransfersResumed();
    }
}

// 

pragma solidity 0.7.6;



/**
 * @title Rewards future abstraction
 * @notice Handles all future mechanisms along with reward-specific functionality
 * @dev Allows for better decoupling of rewards logic with core future logic
 */
abstract contract RewardsFutureVault is FutureVault {
    using SafeERC20Upgradeable for IERC20;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    /* Rewards mecanisms */
    EnumerableSetUpgradeable.AddressSet internal rewardTokens;

    /* External contracts */
    address internal rewardsRecipient;

    /* Events */
    event RewardsHarvested();
    event RewardTokenAdded(address _token);
    event RewardTokenRedeemed(IERC20 _token, uint256 _amount);
    event RewardsRecipientUpdated(address _recipient);

    /* Public */

    /**
     * @notice Harvest all rewards from the vault
     */
    function harvestRewards() public virtual {
        require(hasRole(CONTROLLER_ROLE, msg.sender), "ERR_CALLER");
        _harvestRewards();
        emit RewardsHarvested();
    }

    /**
     * @notice Should be overridden and implemented by the future depending on platform-specific details
     */
    function _harvestRewards() internal virtual {}

    /**
     * @notice Transfer all the redeemable rewards to set defined recipient
     */
    function redeemAllVaultRewards() external virtual onlyController {
        require(rewardsRecipient != address(0), "RewardsFutureVault: ERR_RECIPIENT");
        uint256 numberOfRewardTokens = rewardTokens.length();
        for (uint256 i; i < numberOfRewardTokens; i++) {
            IERC20 rewardToken = IERC20(rewardTokens.at(i));
            uint256 rewardTokenBalance = rewardToken.balanceOf(address(this));
            rewardToken.safeTransfer(rewardsRecipient, rewardTokenBalance);
            emit RewardTokenRedeemed(rewardToken, rewardTokenBalance);
        }
    }

    /**
     * @notice Transfer the specified token reward balance tot the defined recipient
     * @param _rewardToken the reward token to redeem the balance of
     */
    function redeemVaultRewards(IERC20 _rewardToken) external virtual onlyController {
        require(rewardsRecipient != address(0), "RewardsFutureVault: ERR_RECIPIENT");
        require(rewardTokens.contains(address(_rewardToken)), "RewardsFutureVault: ERR_TOKEN_ADDRESS");
        uint256 rewardTokenBalance = _rewardToken.balanceOf(address(this));
        _rewardToken.safeTransfer(rewardsRecipient, rewardTokenBalance);
        emit RewardTokenRedeemed(_rewardToken, rewardTokenBalance);
    }

    /**
     * @notice Add a token to the list of reward tokens
     * @param _token the reward token to add to the list
     * @dev the token must be different than the ibt
     */
    function addRewardsToken(address _token) external onlyAdmin {
        require(_token != address(ibt), "RewardsFutureVault: ERR_TOKEN_ADDRESS");
        rewardTokens.add(_token);
        emit RewardTokenAdded(_token);
    }

    /**
     * @notice Setter for the address of the rewards recipient
     */
    function setRewardRecipient(address _recipient) external {
        require(hasRole(ADMIN_ROLE, msg.sender), "ERR_CALLER");
        rewardsRecipient = _recipient;
        emit RewardsRecipientUpdated(_recipient);
    }

    /**
     * @notice Getter to check if a token is in the reward tokens list
     * @param _token the token to check if it is in the list
     * @return true if the token is a reward token
     */
    function isRewardToken(IERC20 _token) external view returns (bool) {
        return rewardTokens.contains(address(_token));
    }

    /**
     * @notice Getter for the reward token at an index
     * @param _index the index of the reward token in the list
     * @return the address of the token at this index
     */
    function getRewardTokenAt(uint256 _index) external view returns (address) {
        return rewardTokens.at(_index);
    }

    /**
     * @notice Getter for the size of the list of reward tokens
     * @return the number of token in the list
     */
    function getRewardTokensCount() external view returns (uint256) {
        return rewardTokens.length();
    }

    /**
     * @notice Getter for the address of the rewards recipient
     * @return the address of the rewards recipient
     */
    function getRewardsRecipient() external view returns (address) {
        return rewardsRecipient;
    }
}

// 

pragma solidity 0.7.6;



/**
 * @title Main future abstraction contract for the rate futures
 * @notice Handles the rates future mecanisms
 * @dev Basis of all mecanisms for futures (registrations, period switch)
 */
abstract contract RateFutureVault is RewardsFutureVault {
    using SafeMathUpgradeable for uint256;

    mapping(uint256 => uint256) internal IBTRates;

    /**
     * @notice Intializer
     * @param _controller the address of the controller
     * @param _ibt the address of the corresponding IBT
     * @param _periodDuration the length of the period (in days)
     * @param _platformName the name of the platform and tools
     * @param _admin the address of the ACR admin
     */
    function initialize(
        IController _controller,
        IERC20 _ibt,
        uint256 _periodDuration,
        string memory _platformName,
        address _admin
    ) public virtual override initializer {
        super.initialize(_controller, _ibt, _periodDuration, _platformName, _admin);
        IBTRates[getCurrentPeriodIndex()] = getIBTRate();
    }

    /**
     * @notice Start a new period
     * @dev needs corresponding permissions for sender
     */
    function startNewPeriod() public virtual override nextPeriodAvailable periodsActive nonReentrant {
        require(hasRole(CONTROLLER_ROLE, msg.sender), "ERR_CALLER");
        _switchPeriod();
        IBTRates[getCurrentPeriodIndex()] = getIBTRate();
    }

    function convertIBTToUnderlying(uint256 _amount) public view virtual override returns (uint256) {
        return _convertIBTToUnderlyingAtRate(_amount, getIBTRate());
    }

    function _convertIBTToUnderlyingAtRate(uint256 _amount, uint256 _rate) internal view virtual returns (uint256) {
        return (_amount.mul(_rate) / IBT_UNIT);
    }

    function convertUnderlyingtoIBT(uint256 _amount) public view virtual override returns (uint256) {
        return _convertUnderlyingtoIBTAtRate(_amount, getIBTRate());
    }

    function _convertUnderlyingtoIBTAtRate(uint256 _amount, uint256 _rate) internal view virtual returns (uint256) {
        return _amount.mul(IBT_UNIT).div(_rate);
    }

    /**
     * @notice Getter for user IBT amount that is unlockable
     * @param _user user to unlock the IBT from
     * @return the amount of IBT the user can unlock
     */
    function getUnlockableFunds(address _user) public view virtual override returns (uint256) {
        return convertUnderlyingtoIBT(super.getUnlockableFunds(_user));
    }

    /**
     * @notice Getter for the yield currently generated by one pt for the current period
     * @return the amount of yield (in IBT) generated during the current period
     */
    function getUnrealisedYieldPerPT() public view virtual override returns (uint256) {
        uint256 currRate = getIBTRate();
        uint256 currPeriodStartRate = IBTRates[getCurrentPeriodIndex()];
        if (currRate == currPeriodStartRate) return 0;
        uint256 amountOfIBTsAtStart = _convertUnderlyingtoIBTAtRate(IBT_UNIT, currPeriodStartRate);
        uint256 amountOfIBTsNow = _convertUnderlyingtoIBTAtRate(IBT_UNIT, currRate);
        return amountOfIBTsAtStart.sub(amountOfIBTsNow);
    }

    /**
     * @notice Getter for the rate of the IBT
     * @return the uint256 rate, IBT x rate must be equal to the quantity of underlying tokens
     */
    function getIBTRate() public view virtual returns (uint256);

    /**
     * @notice Getter for the number of pt that can be minted for an amoumt deposited now
     * @param _amount the amount to of IBT to deposit
     * @return the number of pt that can be minted for that amount
     */
    function getPTPerAmountDeposited(uint256 _amount) public view virtual override returns (uint256) {
        return _convertIBTToUnderlyingAtRate(_amount, IBTRates[getCurrentPeriodIndex()]);
    }
}

// 

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity 0.7.6;



/**
 * @title Main future abstraction contract for the hybrid futures
 * @notice Handles the rates and scaled amounts for future mecanisms
 * @dev Basis of all mecanisms for futures (registrations, period switch)
 */
abstract contract HybridFutureVault is RateFutureVault {
    using SafeMathUpgradeable for uint256;

    mapping(uint256 => uint256) internal scaledTotals; // scaled IBT amount

    /**
     * @notice Deposit funds into ongoing period
     * @param _user user adress
     * @param _amount amount of ibt to deposit
     * @dev part of the amount deposited will be used to buy back the yield already generated proportionally to the amount deposited
     */
    function deposit(address _user, uint256 _amount) external virtual override periodsActive depositsEnabled onlyController {
        require((_amount > 0) && (_amount <= ibt.balanceOf(_user)), "HybridFutureVault: ERR_AMOUNT");
        _deposit(_user, _amount);
        uint256 currScaledTotals = scaledTotals[getCurrentPeriodIndex()];
        if (currScaledTotals == 0) {
            require(_amount > IBT_UNIT, "HybridFutureVault: ERR_FUTURE_INIT"); // require 1 ibt unit as first deposit to avoid maths scaling issue
            scaledTotals[getCurrentPeriodIndex()] = _amount;
        } else {
            scaledTotals[getCurrentPeriodIndex()] = currScaledTotals.add(
                convertUnderlyingtoIBT(getPTPerAmountDeposited(_amount))
            );
        }
        emit FundsDeposited(_user, _amount);
    }

    /**
     * @notice Internal function for withdrawing funds corresponding to the pt holding of an address
     * @param _user user adress
     * @param _amount amount of funds to unlock
     * @dev handle the logic of withdraw but does not burn fyts
     */
    function _withdraw(address _user, uint256 _amount) internal virtual override {
        uint256 scaledAmountToRemove = convertUnderlyingtoIBT(getPTPerAmountDeposited(_amount));
        super._withdraw(_user, _amount);
        uint256 currentPeriodIndex = getCurrentPeriodIndex();
        scaledTotals[currentPeriodIndex] = scaledTotals[currentPeriodIndex].sub(scaledAmountToRemove);
    }

    /**
     * @notice Start a new period
     * @dev needs corresponding permissions for sender
     */
    function startNewPeriod() public virtual override nextPeriodAvailable periodsActive nonReentrant {
        require(hasRole(CONTROLLER_ROLE, msg.sender), "ERR_CALLER");
        _switchPeriod();
        // Rate
        IBTRates[getCurrentPeriodIndex()] = getIBTRate();
        // Stream
        scaledTotals[getCurrentPeriodIndex()] = ibt.balanceOf(address(this));
    }

    /**
     * @notice Getter for the yield currently generated by one pt for the current period
     * @return the amount of yield (in IBT) generated during the current period
     */
    function getUnrealisedYieldPerPT() public view override returns (uint256) {
        uint256 totalUnderlyingAtStart = totalUnderlyingDeposited;
        if (totalUnderlyingAtStart == 0) return 0;
        uint256 totalUnderlyingNow = convertIBTToUnderlying(ibt.balanceOf(address(this)));
        uint256 yieldForAllPT = convertUnderlyingtoIBT(totalUnderlyingNow.sub(totalUnderlyingAtStart));
        return yieldForAllPT.mul(IBT_UNIT).div(totalUnderlyingAtStart);
    }

    /**
     * @notice Getter for the number of pt that can be minted for an amoumt deposited now
     * @param _amount the amount to of IBT to deposit
     * @return the number of pt that can be minted for that amount
     */
    function getPTPerAmountDeposited(uint256 _amount) public view override returns (uint256) {
        uint256 scaledAmount = APWineMaths.getScaledInput(
            _amount,
            scaledTotals[getCurrentPeriodIndex()],
            ibt.balanceOf(address(this))
        );
        return _convertIBTToUnderlyingAtRate(scaledAmount, IBTRates[getCurrentPeriodIndex()]);
    }
}

// 

pragma solidity 0.7.6;



interface IERC20 is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external returns (string memory);

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external returns (string memory);

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
    function decimals() external view returns (uint8);

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
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

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
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
}
// 

pragma solidity 0.7.6;



/**
 * @title Contract for Paladin Future
 * @notice Handles the future mechanisms for palStTokens
 */
contract PaladinFutureVault is HybridFutureVault {
    IpalStTokenPool public constant POOL_CONTRACT = IpalStTokenPool(0xCDc3DD86C99b58749de0F697dfc1ABE4bE22216d);

    /**
     * @notice Getter for the rate of the IBT
     * @return the uint256 rate, IBT x rate must be equal to the quantity of underlying tokens
     */
    function getIBTRate() public view virtual override returns (uint256) {
        return POOL_CONTRACT.exchangeRateStored();
    }
}

// 

pragma solidity 0.7.6;

interface IpalStTokenPool {
    function exchangeRateStored() external view returns (uint256);
}

// 

pragma solidity >=0.6.0 <0.8.0;

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
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// 

pragma solidity >=0.6.0 <0.8.0;





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
    using SafeMathUpgradeable for uint256;
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
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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

pragma solidity 0.7.6;



interface IFutureYieldToken is IERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) external;

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
    function burnFrom(address account, uint256 amount) external;

    /**
     * @dev Creates `amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 amount) external;

    /**
     * @notice Returns the current balance of one user (without the claimable amount)
     * @param account the address of the account to check the balance of
     * @return the current fyt balance of this address
     */
    function recordedBalanceOf(address account) external view returns (uint256);

    /**
     * @notice Returns the current balance of one user including unclaimed FYT
     * @param account the address of the account to check the balance of
     * @return the total FYT balance of one address
     */
    function balanceOf(address account) external view override returns (uint256);

    /**
     * @notice Getter for the future vault link to this fyt
     * @return the address of the future vault
     */
    function futureVault() external view returns (address);

    /**
     * @notice Getter for the internal period index of this fyt
     * @return the internal period index
     */
    function internalPeriodID() external view returns (uint256);
}

// 

pragma solidity 0.7.6;



interface IPT is IERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) external;

    /**
     * @dev Creates `amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 amount) external;

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
    function burnFrom(address account, uint256 amount) external;

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() external;

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() external;

    /**
     * @notice Returns the current balance of one user (without the claimable amount)
     * @param account the address of the account to check the balance of
     * @return the current pt balance of this address
     */
    function recordedBalanceOf(address account) external view returns (uint256);

    /**
     * @notice Returns the current balance of one user including the pt that were not claimed yet
     * @param account the address of the account to check the balance of
     * @return the total pt balance of one address
     */
    function balanceOf(address account) external view override returns (uint256);

    /**
     * @notice Getter for the future vault link to this pt
     * @return the address of the future vault
     */
    function futureVault() external view returns (address);
}

// 

pragma solidity 0.7.6;

interface IFutureWallet {
    /* Events */

    event YieldRedeemed(address _user, uint256 _periodIndex);
    event WithdrawalsPaused();
    event WithdrawalsResumed();

    /**
     * @notice register the yield of an expired period
     * @param _amount the amount of yield to be registered
     */
    function registerExpiredFuture(uint256 _amount) external;

    /**
     * @notice redeem the yield of the underlying yield of the FYT held by the sender
     * @param _periodIndex the index of the period to redeem the yield from
     */
    function redeemYield(uint256 _periodIndex) external;

    /**
     * @notice return the yield that could be redeemed by an address for a particular period
     * @param _periodIndex the index of the corresponding period
     * @param _user the FYT holder
     * @return the yield that could be redeemed by the token holder for this period
     */
    function getRedeemableYield(uint256 _periodIndex, address _user) external view returns (uint256);

    /**
     * @notice getter for the address of the future corresponding to this future wallet
     * @return the address of the future
     */
    function getFutureVaultAddress() external view returns (address);

    /**
     * @notice getter for the address of the IBT corresponding to this future wallet
     * @return the address of the IBT
     */
    function getIBTAddress() external view returns (address);

    /* Rewards mecanisms*/

    /**
     * @notice Harvest all rewards from the future wallet
     */
    function harvestRewards() external;

    /**
     * @notice Transfer all the redeemable rewards to set defined recipient
     */
    function redeemAllWalletRewards() external;

    /**
     * @notice Transfer the specified token reward balance tot the defined recipient
     * @param _rewardToken the reward token to redeem the balance of
     */
    function redeemWalletRewards(address _rewardToken) external;

    /**
     * @notice Getter for the address of the rewards recipient
     * @return the address of the rewards recipient
     */
    function getRewardsRecipient() external view returns (address);

    /**
     * @notice Setter for the address of the rewards recipient
     */
    function setRewardRecipient(address _recipient) external;
}

// 

pragma solidity 0.7.6;



interface IController {
    /* Events */

    event NextPeriodSwitchSet(uint256 _periodDuration, uint256 _nextSwitchTimestamp);
    event NewPeriodDurationIndexSet(uint256 _periodIndex);
    event FutureRegistered(IFutureVault _futureVault);
    event FutureUnregistered(IFutureVault _futureVault);
    event StartingDelaySet(uint256 _startingDelay);
    event NewPerformanceFeeFactor(IFutureVault _futureVault, uint256 _feeFactor);
    event FutureTerminated(IFutureVault _futureVault);
    event DepositsPaused(IFutureVault _futureVault);
    event DepositsResumed(IFutureVault _futureVault);
    event WithdrawalsPaused(IFutureVault _futureVault);
    event WithdrawalsResumed(IFutureVault _futureVault);
    event RegistryChanged(IRegistry _registry);
    event FutureSetToBeTerminated(IFutureVault _futureVault);

    /* Params */

    function STARTING_DELAY() external view returns (uint256);

    /* User Methods */

    /**
     * @notice Deposit funds into ongoing period
     * @param _futureVault the address of the futureVault to be deposit the funds in
     * @param _amount the amount to deposit on the ongoing period
     * @dev part of the amount depostied will be used to buy back the yield already generated proportionaly to the amount deposited
     */
    function deposit(address _futureVault, uint256 _amount) external;

    /**
     * @notice Withdraw deposited funds from APWine
     * @param _futureVault the address of the futureVault to withdraw the IBT from
     * @param _amount the amount to withdraw
     */
    function withdraw(address _futureVault, uint256 _amount) external;

    /**
     * @notice Exit a terminated pool
     * @param _futureVault the address of the futureVault to exit from from
     * @param _user the user to exit from the pool
     * @dev only pt are required as there  aren't any new FYTs
     */
    function exitTerminatedFuture(address _futureVault, address _user) external;

    /**
     * @notice Create a delegation from one address to another for a futureVault
     * @param _futureVault the corresponding futureVault address
     * @param _receiver the address receiving the futureVault FYTs
     * @param _amount the of futureVault FYTs to delegate
     */
    function createFYTDelegationTo(
        address _futureVault,
        address _receiver,
        uint256 _amount
    ) external;

    /**
     * @notice Remove a delegation from one address to another for a futureVault
     * @param _futureVault the corresponding futureVault address
     * @param _receiver the address receiving the futureVault FYTs
     * @param _amount the of futureVault FYTs to remove from the delegation
     */
    function withdrawFYTDelegationFrom(
        address _futureVault,
        address _receiver,
        uint256 _amount
    ) external;

    /* Getters */

    /**
     * @notice Getter for the registry address of the protocol
     * @return the address of the protocol registry
     */
    function getRegistryAddress() external view returns (address);

    /**
     * @notice Getter for the period index depending on the period duration of the futureVault
     * @param _periodDuration the duration of the periods
     * @return the period index
     */
    function getPeriodIndex(uint256 _periodDuration) external view returns (uint256);

    /**
     * @notice Getter for the beginning timestamp of the next period for the futures with a defined period duration
     * @param _periodDuration the duration of the periods
     * @return the timestamp of the beginning of the next period
     */
    function getNextPeriodStart(uint256 _periodDuration) external view returns (uint256);

    /**
     * @notice Getter for the next performance fee factor of one futureVault
     * @param _futureVault the address of the futureVault
     * @return the next performance fee factor of the futureVault
     */
    function getNextPerformanceFeeFactor(address _futureVault) external view returns (uint256);

    /**
     * @notice Getter for the performance fee factor of one futureVault
     * @param _futureVault the address of the futureVault
     * @return the performance fee factor of the futureVault
     */
    function getCurrentPerformanceFeeFactor(address _futureVault) external view returns (uint256);

    /**
     * @notice Getter for the list of futureVault durations registered in the contract
     * @return durationsList which consists of futureVault durations
     */
    function getDurations() external view returns (uint256[] memory durationsList);

    /**
     * @notice Getter for the futures by period duration
     * @param _periodDuration the period duration of the futures to return
     */
    function getFuturesWithDuration(uint256 _periodDuration) external view returns (address[] memory filteredFutures);

    /**
     * @notice Getter for the futureVault period state
     * @param _futureVault the address of the futureVault
     * @return true if the futureVault is terminated
     */
    function isFutureTerminated(address _futureVault) external view returns (bool);

    /**
     * @notice Getter for the futureVault period state
     * @param _futureVault the address of the futureVault
     * @return true if the futureVault is set to be terminated at its expiration
     */
    function isFutureSetToBeTerminated(address _futureVault) external view returns (bool);

    /**
     * @notice Getter for the futureVault withdrawals state
     * @param _futureVault the address of the futureVault
     * @return true is new withdrawals are paused, false otherwise
     */
    function isWithdrawalsPaused(address _futureVault) external view returns (bool);

    /**
     * @notice Getter for the futureVault deposits state
     * @param _futureVault the address of the futureVault
     * @return true is new deposits are paused, false otherwise
     */
    function isDepositsPaused(address _futureVault) external view returns (bool);
}

// 

pragma solidity 0.7.6;


interface IRegistry {
    /* Setters */
    /**
     * @notice Setter for the treasury address
     * @param _newTreasury the address of the new treasury
     */
    function setTreasury(address _newTreasury) external;

    /**
     * @notice Setter for the controller address
     * @param _newController the address of the new controller
     */
    function setController(address _newController) external;

    /**
     * @notice Setter for the APWine IBT logic address
     * @param _PTLogic the address of the new APWine IBT logic
     */
    function setPTLogic(address _PTLogic) external;

    /**
     * @notice Setter for the APWine FYT logic address
     * @param _FYTLogic the address of the new APWine FYT logic
     */
    function setFYTLogic(address _FYTLogic) external;

    /**
     * @notice Getter for the controller address
     * @return the address of the controller
     */
    function getControllerAddress() external view returns (address);

    /**
     * @notice Getter for the treasury address
     * @return the address of the treasury
     */
    function getTreasuryAddress() external view returns (address);

    /**
     * @notice Getter for the token factory address
     * @return the token factory address
     */
    function getTokensFactoryAddress() external view returns (address);

    /**
     * @notice Getter for APWine IBT logic address
     * @return the APWine IBT logic address
     */
    function getPTLogicAddress() external view returns (address);

    /**
     * @notice Getter for APWine FYT logic address
     * @return the APWine FYT logic address
     */
    function getFYTLogicAddress() external view returns (address);

    /* Futures */
    /**
     * @notice Add a future to the registry
     * @param _future the address of the future to add to the registry
     */
    function addFutureVault(address _future) external;

    /**
     * @notice Remove a future from the registry
     * @param _future the address of the future to remove from the registry
     */
    function removeFutureVault(address _future) external;

    /**
     * @notice Getter to check if a future is registered
     * @param _future the address of the future to check the registration of
     * @return true if it is, false otherwise
     */
    function isRegisteredFutureVault(address _future) external view returns (bool);

    /**
     * @notice Getter for the future registered at an index
     * @param _index the index of the future to return
     * @return the address of the corresponding future
     */
    function getFutureVaultAt(uint256 _index) external view returns (address);

    /**
     * @notice Getter for number of future registered
     * @return the number of future registered
     */
    function futureVaultCount() external view returns (uint256);
}

// 

pragma solidity 0.7.6;

interface ITokensFactory {
    function deployNextFutureYieldToken(uint256 nextPeriodIndex) external returns (address newToken);

    function deployPT(
        string memory _ibtSymbol,
        uint256 _ibtDecimals,
        string memory _platformName,
        uint256 _perioDuration
    ) external returns (address newToken);
}

// 

pragma solidity 0.7.6;



library APWineMaths {
    using SafeMathUpgradeable for uint256;

    /**
     * @notice scale an input
     * @param _actualValue the original value of the input
     * @param _initialSum the scaled value of the sum of the inputs
     * @param _actualSum the current value of the sum of the inputs
     */
    function getScaledInput(
        uint256 _actualValue,
        uint256 _initialSum,
        uint256 _actualSum
    ) internal pure returns (uint256) {
        if (_initialSum == 0 || _actualSum == 0) return _actualValue;
        return (_actualValue.mul(_initialSum)).div(_actualSum);
    }

    /**
     * @notice scale back a value to the output
     * @param _scaledOutput the current scaled output
     * @param _initialSum the scaled value of the sum of the inputs
     * @param _actualSum the current value of the sum of the inputs
     */
    function getActualOutput(
        uint256 _scaledOutput,
        uint256 _initialSum,
        uint256 _actualSum
    ) internal pure returns (uint256) {
        if (_initialSum == 0 || _actualSum == 0) return 0;
        return (_scaledOutput.mul(_actualSum)).div(_initialSum);
    }
}

// 

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// 

pragma solidity >=0.6.2 <0.8.0;

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

// 

pragma solidity 0.7.6;





interface IFutureVault {
    /* Events */
    event NewPeriodStarted(uint256 _newPeriodIndex);
    event FutureWalletSet(address _futureWallet);
    event RegistrySet(IRegistry _registry);
    event FundsDeposited(address _user, uint256 _amount);
    event FundsWithdrawn(address _user, uint256 _amount);
    event PTSet(IPT _pt);
    event LiquidityTransfersPaused();
    event LiquidityTransfersResumed();
    event DelegationCreated(address _delegator, address _receiver, uint256 _amount);
    event DelegationRemoved(address _delegator, address _receiver, uint256 _amount);

    /* Params */
    /**
     * @notice Getter for the PERIOD future parameter
     * @return returns the period duration of the future
     */
    function PERIOD_DURATION() external view returns (uint256);

    /**
     * @notice Getter for the PLATFORM_NAME future parameter
     * @return returns the platform of the future
     */
    function PLATFORM_NAME() external view returns (string memory);

    /**
     * @notice Start a new period
     * @dev needs corresponding permissions for sender
     */
    function startNewPeriod() external;

    /**
     * @notice Exit a terminated pool
     * @param _user the user to exit from the pool
     * @dev only pt are required as there  aren't any new FYTs
     */
    function exitTerminatedFuture(address _user) external;

    /**
     * @notice Update the state of the user and mint claimable pt
     * @param _user user adress
     */
    function updateUserState(address _user) external;

    /**
     * @notice Send the user their owed FYT (and pt if there are some claimable)
     * @param _user address of the user to send the FYT to
     */
    function claimFYT(address _user, uint256 _amount) external;

    /**
     * @notice Deposit funds into ongoing period
     * @param _user user adress
     * @param _amount amount of funds to unlock
     * @dev part of the amount deposited will be used to buy back the yield already generated proportionally to the amount deposited
     */
    function deposit(address _user, uint256 _amount) external;

    /**
     * @notice Sender unlocks the locked funds corresponding to their pt holding
     * @param _user user adress
     * @param _amount amount of funds to unlock
     * @dev will require a transfer of FYT of the ongoing period corresponding to the funds unlocked
     */
    function withdraw(address _user, uint256 _amount) external;

    /**
     * @notice Create a delegation from one address to another
     * @param _delegator the address delegating its future FYTs
     * @param _receiver the address receiving the future FYTs
     * @param _amount the of future FYTs to delegate
     */
    function createFYTDelegationTo(
        address _delegator,
        address _receiver,
        uint256 _amount
    ) external;

    /**
     * @notice Remove a delegation from one address to another
     * @param _delegator the address delegating its future FYTs
     * @param _receiver the address receiving the future FYTs
     * @param _amount the of future FYTs to remove from the delegation
     */
    function withdrawFYTDelegationFrom(
        address _delegator,
        address _receiver,
        uint256 _amount
    ) external;

    /* Getters */

    /**
     * @notice Getter the total number of FYTs on address is delegating
     * @param _delegator the delegating address
     * @return totalDelegated the number of FYTs delegated
     */
    function getTotalDelegated(address _delegator) external view returns (uint256 totalDelegated);

    /**
     * @notice Getter for next period index
     * @return next period index
     * @dev index starts at 1
     */
    function getNextPeriodIndex() external view returns (uint256);

    /**
     * @notice Getter for current period index
     * @return current period index
     * @dev index starts at 1
     */
    function getCurrentPeriodIndex() external view returns (uint256);

    /**
     * @notice Getter for the amount of pt that the user can claim
     * @param _user user to check the check the claimable pt of
     * @return the amount of pt claimable by the user
     */
    function getClaimablePT(address _user) external view returns (uint256);

    /**
     * @notice Getter for the amount (in underlying) of premium redeemable with the corresponding amount of fyt/pt to be burned
     * @param _user user adress
     * @return premiumLocked the premium amount unlockage at this period (in underlying), amountRequired the amount of pt/fyt required for that operation
     */
    function getUserEarlyUnlockablePremium(address _user)
        external
        view
        returns (uint256 premiumLocked, uint256 amountRequired);

    /**
     * @notice Getter for user IBT amount that is unlockable
     * @param _user the user to unlock the IBT from
     * @return the amount of IBT the user can unlock
     */
    function getUnlockableFunds(address _user) external view returns (uint256);

    /**
     * @notice Getter for the amount of FYT that the user can claim for a certain period
     * @param _user the user to check the claimable FYT of
     * @param _periodIndex period ID to check the claimable FYT of
     * @return the amount of FYT claimable by the user for this period ID
     */
    function getClaimableFYTForPeriod(address _user, uint256 _periodIndex) external view returns (uint256);

    /**
     * @notice Getter for the yield currently generated by one pt for the current period
     * @return the amount of yield (in IBT) generated during the current period
     */
    function getUnrealisedYieldPerPT() external view returns (uint256);

    /**
     * @notice Getter for the number of pt that can be minted for an amoumt deposited now
     * @param _amount the amount to of IBT to deposit
     * @return the number of pt that can be minted for that amount
     */
    function getPTPerAmountDeposited(uint256 _amount) external view returns (uint256);

    /**
     * @notice Getter for premium in underlying tokens that can be redeemed at the end of the period of the deposit
     * @param _amount the amount of underlying deposited
     * @return the number of underlying of the ibt deposited that will be redeemable
     */
    function getPremiumPerUnderlyingDeposited(uint256 _amount) external view returns (uint256);

    /**
     * @notice Getter for total underlying deposited in the vault
     * @return the total amount of funds deposited in the vault (in underlying)
     */
    function getTotalUnderlyingDeposited() external view returns (uint256);

    /**
     * @notice Getter for the total yield generated during one period
     * @param _periodID the period id
     * @return the total yield in underlying value
     */
    function getYieldOfPeriod(uint256 _periodID) external view returns (uint256);

    /**
     * @notice Getter for controller address
     * @return the controller address
     */
    function getControllerAddress() external view returns (address);

    /**
     * @notice Getter for futureWallet address
     * @return futureWallet address
     */
    function getFutureWalletAddress() external view returns (address);

    /**
     * @notice Getter for the IBT address
     * @return IBT address
     */
    function getIBTAddress() external view returns (address);

    /**
     * @notice Getter for future pt address
     * @return pt address
     */
    function getPTAddress() external view returns (address);

    /**
     * @notice Getter for FYT address of a particular period
     * @param _periodIndex period index
     * @return FYT address
     */
    function getFYTofPeriod(uint256 _periodIndex) external view returns (address);

    /**
     * @notice Getter for the terminated state of the future
     * @return true if this vault is terminated
     */
    function isTerminated() external view returns (bool);

    /**
     * @notice Getter for the performance fee factor of the current period
     * @return the performance fee factor of the futureVault
     */
    function getPerformanceFeeFactor() external view returns (uint256);

    /* Rewards mecanisms*/

    /**
     * @notice Harvest all rewards from the vault
     */
    function harvestRewards() external;

    /**
     * @notice Transfer all the redeemable rewards to set defined recipient
     */
    function redeemAllVaultRewards() external;

    /**
     * @notice Transfer the specified token reward balance tot the defined recipient
     * @param _rewardToken the reward token to redeem the balance of
     */
    function redeemVaultRewards(address _rewardToken) external;

    /**
     * @notice Add a token to the list of reward tokens
     * @param _token the reward token to add to the list
     * @dev the token must be different than the ibt
     */
    function addRewardsToken(address _token) external;

    /**
     * @notice Getter to check if a token is in the reward tokens list
     * @param _token the token to check if it is in the list
     * @return true if the token is a reward token
     */
    function isRewardToken(address _token) external view returns (bool);

    /**
     * @notice Getter for the reward token at an index
     * @param _index the index of the reward token in the list
     * @return the address of the token at this index
     */
    function getRewardTokenAt(uint256 _index) external view returns (address);

    /**
     * @notice Getter for the size of the list of reward tokens
     * @return the number of token in the list
     */
    function getRewardTokensCount() external view returns (uint256);

    /**
     * @notice Getter for the address of the rewards recipient
     * @return the address of the rewards recipient
     */
    function getRewardsRecipient() external view returns (address);

    /**
     * @notice Setter for the address of the rewards recipient
     */
    function setRewardRecipient(address _recipient) external;

    /* Admin functions */

    /**
     * @notice Set futureWallet address
     */
    function setFutureWallet(IFutureWallet _futureWallet) external;

    /**
     * @notice Set Registry
     */
    function setRegistry(IRegistry _registry) external;

    /**
     * @notice Pause liquidity transfers
     */
    function pauseLiquidityTransfers() external;

    /**
     * @notice Resume liquidity transfers
     */
    function resumeLiquidityTransfers() external;

    /**
     * @notice Convert an amount of IBTs in its equivalent in underlying tokens
     * @param _amount the amount of IBTs
     * @return the corresponding amount of underlying
     */
    function convertIBTToUnderlying(uint256 _amount) external view returns (uint256);

    /**
     * @notice Convert an amount of underlying tokens in its equivalent in IBTs
     * @param _amount the amount of underlying tokens
     * @return the corresponding amount of IBTs
     */
    function convertUnderlyingtoIBT(uint256 _amount) external view returns (uint256);
}
