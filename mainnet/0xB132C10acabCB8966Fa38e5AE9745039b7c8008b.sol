// SPDX-License-Identifier: MIT


// 

pragma solidity ^0.8.0;

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes4` identifier. These are expected to be the 
 * signatures for all the functions in the contract. Special roles should be exposed
 * in the external API and be unique:
 *
 * ```
 * bytes4 public constant ROOT = 0x00000000;
 * ```
 *
 * Roles represent restricted access to a function call. For that purpose, use {auth}:
 *
 * ```
 * function foo() public auth {
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `ROOT`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {setRoleAdmin}.
 *
 * WARNING: The `ROOT` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
contract AccessControl {
    struct RoleData {
        mapping (address => bool) members;
        bytes4 adminRole;
    }

    mapping (bytes4 => RoleData) private _roles;

    bytes4 public constant ROOT = 0x00000000;
    bytes4 public constant ROOT4146650865 = 0x00000000; // Collision protection for ROOT, test with ROOT12007226833()
    bytes4 public constant LOCK = 0xFFFFFFFF;           // Used to disable further permissioning of a function
    bytes4 public constant LOCK8605463013 = 0xFFFFFFFF; // Collision protection for LOCK, test with LOCK10462387368()

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role
     *
     * `ROOT` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes4 indexed role, bytes4 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call.
     */
    event RoleGranted(bytes4 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes4 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Give msg.sender the ROOT role and create a LOCK role with itself as the admin role and no members. 
     * Calling setRoleAdmin(msg.sig, LOCK) means no one can grant that msg.sig role anymore.
     */
    constructor () {
        _grantRole(ROOT, msg.sender);   // Grant ROOT to msg.sender
        _setRoleAdmin(LOCK, LOCK);      // Create the LOCK role by setting itself as its own admin, creating an independent role tree
    }

    /**
     * @dev Each function in the contract has its own role, identified by their msg.sig signature.
     * ROOT can give and remove access to each function, lock any further access being granted to
     * a specific action, or even create other roles to delegate admin control over a function.
     */
    modifier auth() {
        require (_hasRole(msg.sig, msg.sender), "Access denied");
        _;
    }

    /**
     * @dev Allow only if the caller has been granted the admin role of `role`.
     */
    modifier admin(bytes4 role) {
        require (_hasRole(_getRoleAdmin(role), msg.sender), "Only admin");
        _;
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes4 role, address account) external view returns (bool) {
        return _hasRole(role, account);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes4 role) external view returns (bytes4) {
        return _getRoleAdmin(role);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.

     * If ``role``'s admin role is not `adminRole` emits a {RoleAdminChanged} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function setRoleAdmin(bytes4 role, bytes4 adminRole) external virtual admin(role) {
        _setRoleAdmin(role, adminRole);
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
    function grantRole(bytes4 role, address account) external virtual admin(role) {
        _grantRole(role, account);
    }

    
    /**
     * @dev Grants all of `role` in `roles` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - For each `role` in `roles`, the caller must have ``role``'s admin role.
     */
    function grantRoles(bytes4[] memory roles, address account) external virtual {
        for (uint256 i = 0; i < roles.length; i++) {
            require (_hasRole(_getRoleAdmin(roles[i]), msg.sender), "Only admin");
            _grantRole(roles[i], account);
        }
    }

    /**
     * @dev Sets LOCK as ``role``'s admin role. LOCK has no members, so this disables admin management of ``role``.

     * Emits a {RoleAdminChanged} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function lockRole(bytes4 role) external virtual admin(role) {
        _setRoleAdmin(role, LOCK);
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
    function revokeRole(bytes4 role, address account) external virtual admin(role) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes all of `role` in `roles` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - For each `role` in `roles`, the caller must have ``role``'s admin role.
     */
    function revokeRoles(bytes4[] memory roles, address account) external virtual {
        for (uint256 i = 0; i < roles.length; i++) {
            require (_hasRole(_getRoleAdmin(roles[i]), msg.sender), "Only admin");
            _revokeRole(roles[i], account);
        }
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
    function renounceRole(bytes4 role, address account) external virtual {
        require(account == msg.sender, "Renounce only for self");

        _revokeRole(role, account);
    }

    function _hasRole(bytes4 role, address account) internal view returns (bool) {
        return _roles[role].members[account];
    }

    function _getRoleAdmin(bytes4 role) internal view returns (bytes4) {
        return _roles[role].adminRole;
    }

    function _setRoleAdmin(bytes4 role, bytes4 adminRole) internal virtual {
        if (_getRoleAdmin(role) != adminRole) {
            _roles[role].adminRole = adminRole;
            emit RoleAdminChanged(role, adminRole);
        }
    }

    function _grantRole(bytes4 role, address account) internal {
        if (!_hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
    }

    function _revokeRole(bytes4 role, address account) internal {
        if (_hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
    }
}

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
pragma solidity >=0.8.13;













/// the vault collateral in exchange for underlying to pay its debt. The amount of collateral
/// given increases over time, until it offers to sell all the collateral for underlying to pay
/// all the debt. The auction is held open at the final price indefinitely.

contract Witch is AccessControl {
    using WMul for uint256;
    using WDiv for uint256;
    using WDivUp for uint256;
    using CastU256U128 for uint256;

    // ==================== Errors ====================

    error VaultAlreadyUnderAuction(bytes12 vaultId, address witch);
    error VaultNotLiquidatable(bytes6 ilkId, bytes6 baseId);
    error AuctionIsCorrect(bytes12 vaultId);
    error AuctioneerRewardTooHigh(uint256 max, uint256 actual);
    error WitchIsDead();
    error CollateralLimitExceeded(uint256 current, uint256 max);
    error NotUnderCollateralised(bytes12 vaultId);
    error UnderCollateralised(bytes12 vaultId);
    error VaultNotUnderAuction(bytes12 vaultId);
    error NotEnoughBought(uint256 expected, uint256 got);
    error JoinNotFound(bytes6 id);
    error UnrecognisedParam(bytes32 param);
    error LeavesDust(uint256 remainder, uint256 min);

    // ==================== User events ====================

    event Auctioned(
        bytes12 indexed vaultId,
        DataTypes.Auction auction,
        uint256 duration,
        uint256 initialCollateralProportion
    );
    event Cancelled(bytes12 indexed vaultId);
    event Cleared(bytes12 indexed vaultId);
    event Ended(bytes12 indexed vaultId);
    event Bought(
        bytes12 indexed vaultId,
        address indexed buyer,
        uint256 ink,
        uint256 art
    );

    // ==================== Governance events ====================

    event Point(
        bytes32 indexed param,
        address indexed oldValue,
        address indexed newValue
    );
    event LineSet(
        bytes6 indexed ilkId,
        bytes6 indexed baseId,
        uint32 duration,
        uint64 vaultProportion,
        uint64 collateralProportion
    );
    event LimitSet(bytes6 indexed ilkId, bytes6 indexed baseId, uint128 max);
    event ProtectedSet(address indexed value, bool protected);
    event AuctioneerRewardSet(uint256 auctioneerReward);

    ICauldron public immutable cauldron;
    ILadle public ladle;

    uint128 public constant ONE_HUNDRED_PERCENT = 1e18;
    uint128 public constant ONE_PERCENT = 0.01e18;

    // Reward given to whomever calls `auction`. It represents a % of the bought collateral
    uint256 public auctioneerReward;

    mapping(bytes12 => DataTypes.Auction) public auctions;
    mapping(bytes6 => mapping(bytes6 => DataTypes.Line)) public lines;
    mapping(bytes6 => mapping(bytes6 => DataTypes.Limits)) public limits;
    mapping(address => bool) public protected;

    constructor(ICauldron cauldron_, ILadle ladle_) {
        cauldron = cauldron_;
        ladle = ladle_;
        auctioneerReward = ONE_PERCENT;
    }

    // ======================================================================
    // =                        Governance functions                        =
    // ======================================================================

    
    
    
    function point(bytes32 param, address value) external auth {
        if (param != "ladle") {
            revert UnrecognisedParam(param);
        }
        address oldLadle = address(ladle);
        ladle = ILadle(value);
        emit Point(param, oldLadle, value);
    }

    
    
    
    
    
    
    
    function setLineAndLimit(
        bytes6 ilkId,
        bytes6 baseId,
        uint32 duration,
        uint64 vaultProportion,
        uint64 collateralProportion,
        uint128 max
    ) external auth {
        require(
            collateralProportion <= ONE_HUNDRED_PERCENT,
            "Collateral Proportion above 100%"
        );
        require(
            vaultProportion <= ONE_HUNDRED_PERCENT,
            "Vault Proportion above 100%"
        );
        require(
            collateralProportion >= ONE_PERCENT,
            "Collateral Proportion below 1%"
        );
        require(vaultProportion >= ONE_PERCENT, "Vault Proportion below 1%");

        lines[ilkId][baseId] = DataTypes.Line({
            duration: duration,
            vaultProportion: vaultProportion,
            collateralProportion: collateralProportion
        });
        emit LineSet(
            ilkId,
            baseId,
            duration,
            vaultProportion,
            collateralProportion
        );

        limits[ilkId][baseId] = DataTypes.Limits({
            max: max,
            sum: limits[ilkId][baseId].sum // sum is initialized at zero, and doesn't change when changing any ilk parameters
        });
        emit LimitSet(ilkId, baseId, max);
    }

    
    
    
    function setProtected(address owner, bool _protected) external auth {
        protected[owner] = _protected;
        emit ProtectedSet(owner, _protected);
    }

    
    
    function setAuctioneerReward(uint256 auctioneerReward_) external auth {
        if (auctioneerReward_ > ONE_HUNDRED_PERCENT) {
            revert AuctioneerRewardTooHigh(
                ONE_HUNDRED_PERCENT,
                auctioneerReward_
            );
        }
        auctioneerReward = auctioneerReward_;
        emit AuctioneerRewardSet(auctioneerReward_);
    }

    // ======================================================================
    // =                    Auction management functions                    =
    // ======================================================================

    
    
    
    
    
    
    function auction(bytes12 vaultId, address to)
        external
        returns (
            DataTypes.Auction memory auction_,
            DataTypes.Vault memory vault,
            DataTypes.Series memory series
        )
    {
        // If the world has not turned to ashes and darkness, auctions will malfunction on
        // the 7th of February 2106, at 06:28:16 GMT
        // TODO: Replace this contract before then 😰
        // UPDATE: Enshrined issue in a folk song that will be remembered ✅
        if (block.timestamp > type(uint32).max) {
            revert WitchIsDead();
        }
        vault = cauldron.vaults(vaultId);
        if (auctions[vaultId].start != 0 || protected[vault.owner]) {
            revert VaultAlreadyUnderAuction(vaultId, vault.owner);
        }
        series = cauldron.series(vault.seriesId);

        DataTypes.Limits memory limits_ = limits[vault.ilkId][series.baseId];
        if (limits_.max == 0) {
            revert VaultNotLiquidatable(vault.ilkId, series.baseId);
        }
        // There is a limit on how much collateral can be concurrently put at auction, but it is a soft limit.
        // This means that the first auction to reach the limit is allowed to pass it,
        // so that there is never the situation where a vault would be too big to ever be auctioned.
        if (limits_.sum > limits_.max) {
            revert CollateralLimitExceeded(limits_.sum, limits_.max);
        }

        if (cauldron.level(vaultId) >= 0) {
            revert NotUnderCollateralised(vaultId);
        }

        DataTypes.Balances memory balances = cauldron.balances(vaultId);
        DataTypes.Debt memory debt = cauldron.debt(series.baseId, vault.ilkId);
        DataTypes.Line memory line;

        (auction_, line) = _calcAuction(vault, series, to, balances, debt);

        limits_.sum += auction_.ink;
        limits[vault.ilkId][series.baseId] = limits_;

        auctions[vaultId] = auction_;

        vault = _auctionStarted(vaultId, auction_, line);
    }

    
    /// Useful as a method so it can be overridden by specialised witches that may need to do extra accounting or notify 3rd parties
    
    function _auctionStarted(
        bytes12 vaultId,
        DataTypes.Auction memory auction_,
        DataTypes.Line memory line
    ) internal virtual returns (DataTypes.Vault memory vault) {
        // The Witch is now in control of the vault under auction
        vault = cauldron.give(vaultId, address(this));
        emit Auctioned(
            vaultId,
            auction_,
            line.duration,
            line.collateralProportion
        );
    }

    
    /// and what's the max ink that will be offered in exchange. For the realtime amount of ink that's on offer
    /// use `_calcPayout`
    
    
    
    
    
    
    
    function _calcAuction(
        DataTypes.Vault memory vault,
        DataTypes.Series memory series,
        address to,
        DataTypes.Balances memory balances,
        DataTypes.Debt memory debt
    )
        internal
        view
        returns (DataTypes.Auction memory auction_, DataTypes.Line memory line)
    {
        // We try to partially liquidate the vault if possible.
        line = lines[vault.ilkId][series.baseId];
        uint256 vaultProportion = line.vaultProportion;

        // There's a min amount of debt that a vault can hold,
        // this limit is set so liquidations are big enough to be attractive,
        // so 2 things have to be true:
        //      a) what we are putting up for liquidation has to be over the min
        //      b) what we leave in the vault has to be over the min (or zero) in case another liquidation has to be performed
        uint256 min = debt.min * (10**debt.dec);

        uint256 art;
        uint256 ink;

        if (balances.art > min) {
            // We optimistically assume the vaultProportion to be liquidated is correct.
            art = uint256(balances.art).wmul(vaultProportion);

            // If the vaultProportion we'd be liquidating is too small
            if (art < min) {
                // We up the amount to the min
                art = min;
                // We calculate the new vaultProportion of the vault that we're liquidating
                vaultProportion = art.wdivup(balances.art);
            }

            // If the debt we'd be leaving in the vault is too small
            if (balances.art - art < min) {
                // We liquidate everything
                art = balances.art;
                // Proportion is set to 100%
                vaultProportion = ONE_HUNDRED_PERCENT;
            }

            // We calculate how much ink has to be put for sale based on how much art are we asking to be repaid
            ink = uint256(balances.ink).wmul(vaultProportion);
        } else {
            // If min debt was raised, any vault that's left below the new min should be liquidated 100%
            art = balances.art;
            ink = balances.ink;
        }

        auction_ = DataTypes.Auction({
            owner: vault.owner,
            start: uint32(block.timestamp), // Overflow can't happen as max value is checked before
            seriesId: vault.seriesId,
            baseId: series.baseId,
            ilkId: vault.ilkId,
            art: art.u128(),
            ink: ink.u128(),
            auctioneer: to
        });
    }

    
    
    function cancel(bytes12 vaultId) external {
        DataTypes.Auction memory auction_ = _auction(vaultId);
        if (cauldron.level(vaultId) < 0) {
            revert UnderCollateralised(vaultId);
        }

        // Update concurrent collateral under auction
        limits[auction_.ilkId][auction_.baseId].sum -= auction_.ink;

        _auctionEnded(vaultId, auction_.owner);

        emit Cancelled(vaultId);
    }

    
    /// Useful as a method so it can be overridden by specialised witches that may need to do extra accounting or notify 3rd parties
    
    function _auctionEnded(bytes12 vaultId, address owner) internal virtual {
        cauldron.give(vaultId, owner);
        delete auctions[vaultId];
        emit Ended(vaultId);
    }

    
    
    
    function clear(bytes12 vaultId) external {
        DataTypes.Auction memory auction_ = _auction(vaultId);
        if (cauldron.vaults(vaultId).owner == address(this)) {
            revert AuctionIsCorrect(vaultId);
        }

        // Update concurrent collateral under auction
        limits[auction_.ilkId][auction_.baseId].sum -= auction_.ink;
        delete auctions[vaultId];
        emit Cleared(vaultId);
    }

    // ======================================================================
    // =                          Bidding functions                         =
    // ======================================================================

    
    
    
    
    
    
    
    
    
    function payBase(
        bytes12 vaultId,
        address to,
        uint128 minInkOut,
        uint128 maxBaseIn
    )
        external
        returns (
            uint256 liquidatorCut,
            uint256 auctioneerCut,
            uint256 baseIn
        )
    {
        DataTypes.Auction memory auction_ = _auction(vaultId);

        // Find out how much debt is being repaid
        uint256 artIn = cauldron.debtFromBase(auction_.seriesId, maxBaseIn);

        // If offering too much base, take only the necessary.
        if (artIn > auction_.art) {
            artIn = auction_.art;
        }
        baseIn = cauldron.debtToBase(auction_.seriesId, artIn.u128());

        // Calculate the collateral to be sold
        (liquidatorCut, auctioneerCut) = _calcPayout(auction_, to, artIn);
        if (liquidatorCut < minInkOut) {
            revert NotEnoughBought(minInkOut, liquidatorCut);
        }

        // Update Cauldron and local auction data
        _updateAccounting(
            vaultId,
            auction_,
            (liquidatorCut + auctioneerCut).u128(),
            artIn.u128()
        );

        // Move the assets
        (liquidatorCut, auctioneerCut) = _payInk(
            auction_,
            to,
            liquidatorCut,
            auctioneerCut
        );

        if (baseIn != 0) {
            // Take underlying from liquidator
            IJoin baseJoin = ladle.joins(auction_.baseId);
            if (baseJoin == IJoin(address(0))) {
                revert JoinNotFound(auction_.baseId);
            }
            baseJoin.join(msg.sender, baseIn.u128());
        }

        _collateralBought(vaultId, to, liquidatorCut + auctioneerCut, artIn);
    }

    
    
    
    
    
    
    
    
    
    function payFYToken(
        bytes12 vaultId,
        address to,
        uint128 minInkOut,
        uint128 maxArtIn
    )
        external
        returns (
            uint256 liquidatorCut,
            uint256 auctioneerCut,
            uint128 artIn
        )
    {
        DataTypes.Auction memory auction_ = _auction(vaultId);

        // If offering too much fyToken, take only the necessary.
        artIn = maxArtIn > auction_.art ? auction_.art : maxArtIn;

        // Calculate the collateral to be sold
        (liquidatorCut, auctioneerCut) = _calcPayout(auction_, to, artIn);
        if (liquidatorCut < minInkOut) {
            revert NotEnoughBought(minInkOut, liquidatorCut);
        }

        // Update Cauldron and local auction data
        _updateAccounting(
            vaultId,
            auction_,
            (liquidatorCut + auctioneerCut).u128(),
            artIn
        );

        // Move the assets
        (liquidatorCut, auctioneerCut) = _payInk(
            auction_,
            to,
            liquidatorCut,
            auctioneerCut
        );

        if (artIn != 0) {
            // Burn fyToken from liquidator
            cauldron.series(auction_.seriesId).fyToken.burn(msg.sender, artIn);
        }

        _collateralBought(vaultId, to, liquidatorCut + auctioneerCut, artIn);
    }

    
    
    
    
    
    
    function _payInk(
        DataTypes.Auction memory auction_,
        address to,
        uint256 liquidatorCut,
        uint256 auctioneerCut
    ) internal returns (uint256, uint256) {
        IJoin ilkJoin = ladle.joins(auction_.ilkId);
        if (ilkJoin == IJoin(address(0))) {
            revert JoinNotFound(auction_.ilkId);
        }

        // Pay auctioneer's cut if necessary
        if (auctioneerCut > 0) {
            // A transfer revert would block the auction, in that case the liquidator gets the auctioneer's cut as well
            try
                ilkJoin.exit(auction_.auctioneer, auctioneerCut.u128())
            returns (uint128) {} catch {
                liquidatorCut += auctioneerCut;
                auctioneerCut = 0;
            }
        }

        // Give collateral to the liquidator
        if (liquidatorCut > 0) {
            ilkJoin.exit(to, liquidatorCut.u128());
        }

        return (liquidatorCut, auctioneerCut);
    }

    
    
    
    
    
    /// This function doesn't verify the vaultId matches the vault and auction passed. Check before calling.
    function _updateAccounting(
        bytes12 vaultId,
        DataTypes.Auction memory auction_,
        uint128 inkOut,
        uint128 artIn
    ) internal {
        // Duplicate check, but guarantees data integrity
        if (auction_.start == 0) {
            revert VaultNotUnderAuction(vaultId);
        }

        DataTypes.Limits memory limits_ = limits[auction_.ilkId][
            auction_.baseId
        ];

        // Update local auction
        {
            if (auction_.art == artIn) {
                // If there is no debt left, return the vault with the collateral to the owner
                _auctionEnded(vaultId, auction_.owner);

                // Update limits - reduce it by the whole auction
                limits_.sum -= auction_.ink;
            } else {
                // Ensure enough dust is left
                DataTypes.Debt memory debt = cauldron.debt(
                    auction_.baseId,
                    auction_.ilkId
                );

                uint256 remainder = auction_.art - artIn;
                uint256 min = debt.min * (10**debt.dec);
                if (remainder < min) {
                    revert LeavesDust(remainder, min);
                }

                // Update the auction
                auction_.ink -= inkOut;
                auction_.art -= artIn;

                // Store auction changes
                auctions[vaultId] = auction_;

                // Update limits - reduce it by whatever was bought
                limits_.sum -= inkOut;
            }
        }

        // Store limit changes
        limits[auction_.ilkId][auction_.baseId] = limits_;

        // Update accounting at Cauldron
        cauldron.slurp(vaultId, inkOut, artIn);
    }

    
    /// Useful as a method so it can be overridden by specialised witches that may need to do extra accounting or notify 3rd parties
    
    
    
    
    function _collateralBought(
        bytes12 vaultId,
        address buyer,
        uint256 ink,
        uint256 art
    ) internal virtual {
        emit Bought(vaultId, buyer, ink, art);
    }

    // ======================================================================
    // =                         Quoting functions                          =
    // ======================================================================

    /*

       x x x
     x      x    Hi Fren!
    x  .  .  x   I want to buy this vault under auction!  I'll pay
    x        x   you in the same `base` currency of the debt, or in fyToken, but
    x        x   I want no less than `uint min` of the collateral, ok?
    x   ===  x
    x       x
      xxxxx
        x                             __  Ok Fren!
        x     ┌────────────┐  _(\    |@@|
        xxxxxx│ BASE BUCKS │ (__/\__ \--/ __
        x     │     OR     │    \___|----|  |   __
        x     │   FYTOKEN  │        \ }{ /\ )_ / _\
       x x    └────────────┘        /\__/\ \__O (__
                                   (--/\--)    \__/
                            │      _)(  )(_
                            │     `---''---`
                            ▼
      _______
     /  12   \  First lets check how much time `t` is left on the auction
    |    |    | because that helps us determine the price we will accept
    |9   |   3| for the debt! Yay!
    |     \   |                       p + (1 - p) * t
    |         |
     \___6___/          (p is the auction starting price!)

                            │
                            │
                            ▼                  (\
                                                \ \
    Then the Cauldron updates our internal    __    \/ ___,.-------..__        __
    accounting by slurping up the debt      //\\ _,-'\\               `'--._ //\\
    and the collateral from the vault!      \\ ;'      \\                   `: //
                                             `(          \\                   )'
    The Join then dishes out the collateral    :.          \\,----,         ,;
    to you, dear user. And the debt is          `.`--.___   (    /  ___.--','
    settled with the base join or debt fyToken.   `.     ``-----'-''     ,'
                                                    -.               ,-
                                                       `-._______.-'


    */
    
    
    
    
    
    
    
    function calcPayout(
        bytes12 vaultId,
        address to,
        uint256 maxArtIn
    )
        external
        view
        returns (
            uint256 liquidatorCut,
            uint256 auctioneerCut,
            uint256 artIn
        )
    {
        DataTypes.Auction memory auction_ = auctions[vaultId];
        DataTypes.Vault memory vault = cauldron.vaults(vaultId);

        // If the vault hasn't been auctioned yet, we calculate what values it'd have if it was started right now
        if (auction_.start == 0) {
            DataTypes.Series memory series = cauldron.series(vault.seriesId);
            DataTypes.Balances memory balances = cauldron.balances(vaultId);
            DataTypes.Debt memory debt = cauldron.debt(
                series.baseId,
                vault.ilkId
            );
            (auction_, ) = _calcAuction(vault, series, to, balances, debt);
        }

        // GT check is to cater for partial buys right before this method executes
        artIn = maxArtIn > auction_.art ? auction_.art : maxArtIn;

        (liquidatorCut, auctioneerCut) = _calcPayout(auction_, to, artIn);
    }

    
    
    
    
    
    
    
    /// Formula: (artIn / totalArt) * totalInk * (initialProportion + (1 - initialProportion) * t)
    function _calcPayout(
        DataTypes.Auction memory auction_,
        address to,
        uint256 artIn
    ) internal view returns (uint256 liquidatorCut, uint256 auctioneerCut) {
        DataTypes.Line memory line_ = lines[auction_.ilkId][auction_.baseId];
        uint256 duration = line_.duration;
        uint256 initialCollateralProportion = line_.collateralProportion;

        uint256 collateralProportionNow;
        uint256 elapsed = block.timestamp - auction_.start;
        if (duration == type(uint32).max) {
            // Interpreted as infinite duration
            collateralProportionNow = initialCollateralProportion;
        } else if (elapsed >= duration) {
            collateralProportionNow = ONE_HUNDRED_PERCENT;
        } else {
            collateralProportionNow =
                initialCollateralProportion +
                ((ONE_HUNDRED_PERCENT - initialCollateralProportion) *
                    elapsed) /
                duration;
        }

        uint256 inkAtEnd = artIn.wdiv(auction_.art).wmul(auction_.ink);
        liquidatorCut = inkAtEnd.wmul(collateralProportionNow);
        if (auction_.auctioneer != to) {
            auctioneerCut = liquidatorCut.wmul(auctioneerReward);
            liquidatorCut -= auctioneerCut;
        }
    }

    
    
    
    function _auction(bytes12 vaultId)
        internal
        view
        returns (DataTypes.Auction memory auction_)
    {
        auction_ = auctions[vaultId];

        if (auction_.start == 0) {
            revert VaultNotUnderAuction(vaultId);
        }
    }
}

// 
pragma solidity >=0.8.13;



interface IERC5095 is IERC20 {
    
    function underlying() external view returns (address underlyingAddress);

    
    function maturity() external view returns (uint256 timestamp);

    
    function convertToUnderlying(uint256 principalAmount) external returns (uint256 underlyingAmount);

    
    function convertToPrincipal(uint256 underlyingAmount) external returns (uint256 principalAmount);

    
    function maxRedeem(address holder) external view returns (uint256 maxPrincipalAmount);

    
    function previewRedeem(uint256 principalAmount) external returns (uint256 underlyingAmount);

    
    function redeem(uint256 principalAmount, address to, address from) external returns (uint256 underlyingAmount);

    
    function maxWithdraw(address holder) external returns (uint256 maxUnderlyingAmount);

    
    function previewWithdraw(uint256 underlyingAmount) external returns (uint256 principalAmount);

    
    function withdraw(uint256 underlyingAmount, address to, address from) external returns (uint256 principalAmount);
}// 
pragma solidity >=0.8.13;




contract ContangoWitch is Witch {
    IContangoWitchListener public immutable contango;

    constructor(
        IContangoWitchListener contango_,
        ICauldron cauldron_,
        ILadle ladle_
    ) Witch(cauldron_, ladle_) {
        contango = contango_;
    }

    function _auctionStarted(
        bytes12 vaultId,
        DataTypes.Auction memory auction_,
        DataTypes.Line memory line
    ) internal override returns (DataTypes.Vault memory vault) {
        vault = super._auctionStarted(vaultId, auction_, line);
        contango.auctionStarted(vaultId);
    }

    function _collateralBought(
        bytes12 vaultId,
        address buyer,
        uint256 ink,
        uint256 art
    ) internal override {
        super._collateralBought(vaultId, buyer, ink, art);
        contango.collateralBought(vaultId, buyer, ink, art);
    }

    function _auctionEnded(bytes12 vaultId, address owner) internal override {
        super._auctionEnded(vaultId, owner);
        contango.auctionEnded(vaultId, owner);
    }
}

// 
pragma solidity ^0.8.0;

interface IContangoWitchListener {
    function auctionStarted(bytes12 vaultId) external;

    function collateralBought(
        bytes12 vaultId,
        address buyer,
        uint256 ink,
        uint256 art
    ) external;

    function auctionEnded(bytes12 vaultId, address owner) external;
}

// 
pragma solidity ^0.8.0;


library WMul {
    // Taken from https://github.com/usmfum/USM/blob/master/contracts/WadMath.sol
    
    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * y;
        unchecked { z /= 1e18; }
    }
}

// 
pragma solidity ^0.8.0;


library WDiv { // Fixed point arithmetic in 18 decimal units
    // Taken from https://github.com/usmfum/USM/blob/master/contracts/WadMath.sol
    
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = (x * 1e18) / y;
    }
}

// 
pragma solidity ^0.8.0;


library CastU256U128 {
    
    function u128(uint256 x) internal pure returns (uint128 y) {
        require (x <= type(uint128).max, "Cast overflow");
        y = uint128(x);
    }
}

// 
pragma solidity ^0.8.0;


library WDivUp { // Fixed point arithmetic in 18 decimal units
    // Taken from https://github.com/usmfum/USM/blob/master/contracts/WadMath.sol
    
    function wdivup(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * 1e18 + y;            // 101 (1.01) / 1000 (10) -> (101 * 100 + 1000 - 1) / 1000 -> 11 (0.11 = 0.101 rounded up).
        unchecked { z -= 1; }       // Can do unchecked subtraction since division in next line will catch y = 0 case anyway
        z /= y;
    }
}

// 
pragma solidity ^0.8.0;



interface ILadle {
    function joins(bytes6) external view returns (IJoin);

    function pools(bytes6) external view returns (address);

    function cauldron() external view returns (ICauldron);

    function build(
        bytes6 seriesId,
        bytes6 ilkId,
        uint8 salt
    ) external returns (bytes12 vaultId, DataTypes.Vault memory vault);

    function destroy(bytes12 vaultId) external;

    function pour(
        bytes12 vaultId,
        address to,
        int128 ink,
        int128 art
    ) external payable;

    function serve(
        bytes12 vaultId,
        address to,
        uint128 ink,
        uint128 base,
        uint128 max
    ) external payable returns (uint128 art);

    function close(
        bytes12 vaultId,
        address to,
        int128 ink,
        int128 art
    ) external;
}

// 
pragma solidity ^0.8.0;




interface ICauldron {
    
    function lendingOracles(bytes6 baseId) external view returns (IOracle);

    
    function vaults(bytes12 vault)
        external
        view
        returns (DataTypes.Vault memory);

    
    function series(bytes6 seriesId)
        external
        view
        returns (DataTypes.Series memory);

    
    function assets(bytes6 assetsId) external view returns (address);

    
    function balances(bytes12 vault)
        external
        view
        returns (DataTypes.Balances memory);

    
    function debt(bytes6 baseId, bytes6 ilkId)
        external
        view
        returns (DataTypes.Debt memory);

    // @dev Spot price oracle addresses and collateralization ratios
    function spotOracles(bytes6 baseId, bytes6 ilkId)
        external
        view
        returns (DataTypes.SpotOracle memory);

    
    function build(
        address owner,
        bytes12 vaultId,
        bytes6 seriesId,
        bytes6 ilkId
    ) external returns (DataTypes.Vault memory);

    
    function destroy(bytes12 vault) external;

    
    function tweak(
        bytes12 vaultId,
        bytes6 seriesId,
        bytes6 ilkId
    ) external returns (DataTypes.Vault memory);

    
    function give(bytes12 vaultId, address receiver)
        external
        returns (DataTypes.Vault memory);

    
    function stir(
        bytes12 from,
        bytes12 to,
        uint128 ink,
        uint128 art
    ) external returns (DataTypes.Balances memory, DataTypes.Balances memory);

    
    function pour(
        bytes12 vaultId,
        int128 ink,
        int128 art
    ) external returns (DataTypes.Balances memory);

    
    /// The module calling this function also needs to buy underlying in the pool for the new series, and sell it in pool for the old series.
    function roll(
        bytes12 vaultId,
        bytes6 seriesId,
        int128 art
    ) external returns (DataTypes.Vault memory, DataTypes.Balances memory);

    
    function slurp(
        bytes12 vaultId,
        uint128 ink,
        uint128 art
    ) external returns (DataTypes.Balances memory);

    // ==== Helpers ====

    
    
    function debtFromBase(bytes6 seriesId, uint128 base)
        external
        returns (uint128 art);

    
    function debtToBase(bytes6 seriesId, uint128 art)
        external
        returns (uint128 base);

    // ==== Accounting ====

    
    function mature(bytes6 seriesId) external;

    
    function accrual(bytes6 seriesId) external returns (uint256);

    
    function level(bytes12 vaultId) external returns (int256);
}

// 
pragma solidity ^0.8.0;


interface IJoin {
    
    function asset() external view returns (address);

    
    function storedBalance() external view returns (uint256);

    
    function join(address user, uint128 wad) external returns (uint128);

    
    function exit(address user, uint128 wad) external returns (uint128);

    
    function retrieve(IERC20 token, address to) external;
}

// 
pragma solidity ^0.8.0;



library DataTypes {
    // ======== Cauldron data types ========
    struct Series {
        IFYToken fyToken; // Redeemable token for the series.
        bytes6 baseId; // Asset received on redemption.
        uint32 maturity; // Unix time at which redemption becomes possible.
        // bytes2 free
    }

    struct Debt {
        uint96 max; // Maximum debt accepted for a given underlying, across all series
        uint24 min; // Minimum debt accepted for a given underlying, across all series
        uint8 dec; // Multiplying factor (10**dec) for max and min
        uint128 sum; // Current debt for a given underlying, across all series
    }

    struct SpotOracle {
        IOracle oracle; // Address for the spot price oracle
        uint32 ratio; // Collateralization ratio to multiply the price for
        // bytes8 free
    }

    struct Vault {
        address owner;
        bytes6 seriesId; // Each vault is related to only one series, which also determines the underlying.
        bytes6 ilkId; // Asset accepted as collateral
    }

    struct Balances {
        uint128 art; // Debt amount
        uint128 ink; // Collateral amount
    }

    // ======== Witch data types ========
    struct Auction {
        address owner;
        uint32 start;
        bytes6 baseId; // We cache the baseId here
        uint128 ink;
        uint128 art;
        address auctioneer;
        bytes6 ilkId; // We cache the ilkId here
        bytes6 seriesId; // We cache the seriesId here
    }

    struct Line {
        uint32 duration; // Time that auctions take to go to minimal price and stay there
        uint64 vaultProportion; // Proportion of the vault that is available each auction (1e18 = 100%)
        uint64 collateralProportion; // Proportion of collateral that is sold at auction start (1e18 = 100%)
    }

    struct Limits {
        uint128 max; // Maximum concurrent auctioned collateral
        uint128 sum; // Current concurrent auctioned collateral
    }
}

// 
pragma solidity ^0.8.0;




interface IFYToken is IERC5095 {

    
    function oracle() view external returns (IOracle);

    
    function join() view external returns (IJoin); 

    
    function underlying() view external returns (address);

    
    function underlyingId() view external returns (bytes6);

    
    function maturity() view external returns (uint256);

    
    function chiAtMaturity() view external returns (uint256);
    
    
    function mature() external;

    
    function mintWithUnderlying(address to, uint256 amount) external;

    
    function redeem(address to, uint256 amount) external returns (uint256);

    
    /// This function can only be called by other Yield contracts, not users directly.
    
    
    function mint(address to, uint256 fyTokenAmount) external;

    
    /// This function can only be called by other Yield contracts, not users directly.
    
    
    function burn(address from, uint256 fyTokenAmount) external;
}

// 
pragma solidity ^0.8.0;

interface IOracle {
    /**
     * @notice Doesn't refresh the price, but returns the latest value available without doing any transactional operations
     * @param base The asset in which the `amount` to be converted is represented
     * @param quote The asset in which the converted `value` will be represented
     * @param amount The amount to be converted from `base` to `quote`
     * @return value The converted value of `amount` from `base` to `quote`
     * @return updateTime The timestamp when the conversion price was taken
     */
    function peek(
        bytes32 base,
        bytes32 quote,
        uint256 amount
    ) external view returns (uint256 value, uint256 updateTime);

    /**
     * @notice Does whatever work or queries will yield the most up-to-date price, and returns it.
     * @param base The asset in which the `amount` to be converted is represented
     * @param quote The asset in which the converted `value` will be represented
     * @param amount The amount to be converted from `base` to `quote`
     * @return value The converted value of `amount` from `base` to `quote`
     * @return updateTime The timestamp when the conversion price was taken
     */
    function get(
        bytes32 base,
        bytes32 quote,
        uint256 amount
    ) external returns (uint256 value, uint256 updateTime);
}
