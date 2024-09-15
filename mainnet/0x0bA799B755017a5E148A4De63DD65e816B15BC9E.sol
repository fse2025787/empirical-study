// SPDX-License-Identifier: MIT


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
}

// 
pragma solidity ^0.8.0;

contract AccessRoleCommon {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");
    bytes32 public constant POLICY_ROLE = keccak256("POLICY_ROLE");
}

// 
pragma solidity ^0.8.4;




contract TreasuryStorage {

    string internal notAccepted = "Treasury: not accepted";
    string internal notApproved = "Treasury: not approved";
    string internal invalidToken = "Treasury: invalid token";
    string internal insufficientReserves = "Treasury: insufficient reserves";

    IERC20 public tos;
    address public calculator;
    address public wethAddress;
    address public uniswapV3Factory;
    address public stakingV2;
    address public poolAddressTOSETH;

    uint256 public mintRate;
    uint256 public mintRateDenominator;
    uint256 public foundationAmount;
    uint256 public foundationTotalPercentage;

    mapping(LibTreasury.STATUS => address[]) public registry;
    mapping(LibTreasury.STATUS => mapping(address => bool)) public permissions;
    mapping(address => uint256) public backingIndexPlusOne;

    address[] public backings;
    LibTreasury.Minting[] public mintings;
    uint256[] public lpTokens;


    modifier nonZero(uint256 tokenId) {
        require(tokenId != 0, "Treasury: zero uint");
        _;
    }

    modifier nonZeroAddress(address account) {
        require(
            account != address(0),
            "Treasury:zero address"
        );
        _;
    }

}

// 
pragma solidity ^0.8.0;




contract ProxyAccessCommon is AccessRoleCommon, AccessControl {
    modifier onlyOwner() {
        require(isAdmin(msg.sender) || isProxyAdmin(msg.sender), "Accessible: Caller is not an admin");
        _;
    }

    modifier onlyProxyOwner() {
        require(isProxyAdmin(msg.sender), "Accessible: Caller is not an proxy admin");
        _;
    }

    modifier onlyPolicyOwner() {
        require(isPolicy(msg.sender), "Accessible: Caller is not an policy admin");
        _;
    }

    function addProxyAdmin(address _owner)
        external
        onlyProxyOwner
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
    }

    function removeProxyAdmin()
        public virtual onlyProxyOwner
    {
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function transferProxyAdmin(address newAdmin)
        external virtual
        onlyProxyOwner
    {
        require(newAdmin != address(0), "Accessible: zero address");
        require(msg.sender != newAdmin, "Accessible: same admin");

        grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }


    
    
    function addAdmin(address account) public virtual onlyProxyOwner {
        grantRole(ADMIN_ROLE, account);
    }

    
    function removeAdmin() public virtual onlyOwner {
        renounceRole(ADMIN_ROLE, msg.sender);
    }

    
    
    function transferAdmin(address newAdmin) external virtual onlyOwner {
        require(newAdmin != address(0), "Accessible: zero address");
        require(msg.sender != newAdmin, "Accessible: same admin");

        grantRole(ADMIN_ROLE, newAdmin);
        renounceRole(ADMIN_ROLE, msg.sender);
    }

    function addPolicy(address _account) public virtual onlyProxyOwner {
        grantRole(POLICY_ROLE, _account);
    }

    function removePolicy() public virtual onlyPolicyOwner {
        renounceRole(POLICY_ROLE, msg.sender);
    }

    function deletePolicy(address _account) public virtual onlyProxyOwner {
        revokeRole(POLICY_ROLE, _account);
    }

    
    
    function isAdmin(address account) public view virtual returns (bool) {
        return hasRole(ADMIN_ROLE, account);
    }

    function isProxyAdmin(address account) public view virtual returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    function isPolicy(address account) public view virtual returns (bool) {
        return hasRole(POLICY_ROLE, account);
    }
}

// 
pragma solidity >=0.7.5;



interface ITreasury {


    /* ========== onlyPolicyOwner ========== */
    
    
    
    function enable(uint _status,  address _address) external ;

    
    
    
    function disable(uint _status, address _toDisable) external;

    
    
    
    
    function setMR(uint256 _mrRate, uint256 amount, bool _isBurn) external;

    
    
    function setPoolAddressTOSETH(address _poolAddressTOSETH) external;

    
    
    function setUniswapV3Factory(address _uniswapFactory) external;

    
    
    function setMintRateDenominator(uint256 _mintRateDenominator) external;

    
    
    function addBackingList(address _address) external ;

    
    
    function deleteBackingList(address _address) external;

    
    
    
    function setFoundationDistributeInfo(
        address[] memory  _addr,
        uint256[] memory _percents
    ) external ;


    /* ========== onlyOwner ========== */

    
    
    
    
    function requestMint(uint256 _mintAmount, uint256 _payout, bool _distribute) external ;

    
    
    function addBondAsset(
        address _address
    )
        external;

    /* ========== onlyStaker ========== */

    
    
    
    function requestTransfer(address _recipient, uint256 _amount)  external;

    /* ========== Anyone can execute ========== */

    /* ========== VIEW ========== */

    
    
    function getMintRate() external view returns (uint256);

    
    
    function backingRateETHPerTOS() external view returns (uint256);

    
    
    function indexInRegistry(address _address, LibTreasury.STATUS _status) external view returns (bool, uint256);


    
    
    function enableStaking() external view returns (uint256);

    
    
    function backingReserve() external view returns (uint256) ;

    
    
    function totalBacking() external view returns (uint256);

    
    
    function allBacking() external view returns (
        address[] memory erc20Address
    );

    
    
    function totalMinting() external view returns(uint256) ;

    
    
    
    
    function viewMintingInfo(uint256 _index)
        external view returns(address mintAddress, uint256 mintPercents);

    
    
    
    function allMinting() external view
        returns (
            address[] memory mintAddress,
            uint256[] memory mintPercents
            );

    
    
    
    
    function hasPermission(uint role, address account) external view returns (bool);

    
    
    
    
    function checkTosSolvencyAfterTOSMint (uint256 _checkMintRate, uint256 amount) external view returns (bool);

    
    
    
    
    function checkTosSolvencyAfterTOSBurn (uint256 _checkMintRate, uint256 amount) external view returns (bool);

    
    
    
    function checkTosSolvency (uint256 amount) external view returns (bool);

    
    
    function backingReserveETH() external view returns (uint256);

    
    
    function backingReserveTOS() external view returns (uint256);

    
    
    function getETHPricePerTOS() external view returns (uint256);

    
    
    function getTOSPricePerETH() external view returns (uint256);

    
    
    
    function isBonder(address account) external view returns (bool);

    
    
    
    function isStaker(address account) external view returns (bool);
}

//
pragma solidity ^0.8.4;

interface ITreasuryEvent{

    
    
    event SetCalculator(address calculatorAddress);

    
    
    event SetWethAddress(address _wethAddress);

    
    
    event BurnedTos(uint256 amount);

    
    
    
    
    event Permissioned(address addr, uint indexed status, bool result);

    
    
    
    
    event SetMintRate(uint256 mrRate, uint256 amount, bool isBurn);

    
    
    event SetPoolAddressTOSETH(address _poolAddressTOSETH);

    
    
    event SetUniswapV3Factory(address _uniswapFactory);

    
    
    event SetMintRateDenominator(uint256 _mintRateDenominator);

    
    
    event AddedBackingList(address _address);

    
    
    event DeletedBackingList(
        address _address
    );


    
    
    
    event SetFoundationDistributeInfo(
        address[]  _addr,
        uint256[] _percents
    );

    
    
    
    event DistributedFoundation(
        address to,
        uint256 amount
    );

    
    
    
    
    event RequestedMint(
        uint256 _mintAmount,
        uint256 _payout,
        bool _distribute
    );

    
    
    
    event RequestedTransfer(
        address _recipient,
        uint256 _amount
    );

}
// 
pragma solidity ^0.8.4;










// import "hardhat/console.sol";

interface IITOSValueCalculator {

    function convertAssetBalanceToWethOrTos(address _asset, uint256 _amount)
        external view
        returns (bool existedWethPool, bool existedTosPool,  uint256 priceWethOrTosPerAsset, uint256 convertedAmount);

    function getTOSPricePerETH() external view returns (uint256 price);

    function getETHPricePerTOS() external view returns (uint256 price);
}

interface IIStaking {
    function stakedOfAll() external view returns (uint256) ;
}

interface IIIUniswapV3Pool {
    function liquidity() external view returns (uint128);
}

contract Treasury is
    TreasuryStorage,
    ProxyAccessCommon,
    ITreasury,
    ITreasuryEvent
{
    using SafeERC20 for IERC20;


    constructor() {
    }

    /* ========== onlyPolicyOwner ========== */


    function setCalculator(
        address _calculator
    )
        external nonZeroAddress(_calculator) onlyPolicyOwner
    {
        require(calculator != _calculator, "same address");
        calculator = _calculator;

        emit SetCalculator(_calculator);
    }

    function setWeth(
        address _wethAddress
    )
        external nonZeroAddress(_wethAddress) onlyPolicyOwner
    {
        require(wethAddress != _wethAddress, "same address");
        wethAddress = _wethAddress;

        emit SetWethAddress(_wethAddress);
    }

    function tosBurn(
        uint256 amount
    )
        external onlyProxyOwner
    {
        require(tos.balanceOf(address(this)) >= amount, "balance is insufficient.");
        tos.burn(address(this), amount);

        emit BurnedTos(amount);
    }


    
    function enable(
        uint _status,
        address _address
    )
        external override
        onlyProxyOwner
    {
        LibTreasury.STATUS role = LibTreasury.getStatus(_status);

        require(role != LibTreasury.STATUS.NONE, "NONE permission");
        require(permissions[role][_address] == false, "already set");

        permissions[role][_address] = true;

        (bool registered, ) = indexInRegistry(_address, role);

        if (!registered) {
            registry[role].push(_address);
        }

        emit Permissioned(_address, _status, true);
    }

    
    function disable(uint _status, address _toDisable)
        external override onlyProxyOwner
    {
        LibTreasury.STATUS role = LibTreasury.getStatus(_status);
        require(role != LibTreasury.STATUS.NONE, "NONE permission");
        require(permissions[role][_toDisable] == true, "hasn't permissions");

        permissions[role][_toDisable] = false;

        (bool registered, uint256 _index) = indexInRegistry(_toDisable, role);
        if (registered && registry[role].length > 0) {
            if (_index < registry[role].length-1) registry[role][_index] = registry[role][registry[role].length-1];
            registry[role].pop();
        }

        emit Permissioned(_toDisable, uint(role), false);
    }

    /*
    
    function approve(
        address _address
    ) external override onlyPolicyOwner {
        tos.approve(_address, 1e45);
    }
    */

    
    function setMR(uint256 _mrRate, uint256 amount, bool _isBurn) external override onlyPolicyOwner {

        require(mintRate != _mrRate || amount > 0, "check input value");

        if (_isBurn) {
            require(checkTosSolvencyAfterTOSBurn(_mrRate, amount), "unavailable mintRate");
            if (amount > 0) tos.burn(address(this), amount);

        } else {
            require(checkTosSolvencyAfterTOSMint(_mrRate, amount), "unavailable mintRate");
            if (amount > 0) tos.mint(address(this), amount);
        }

        if (mintRate != _mrRate) mintRate = _mrRate;

        emit SetMintRate(_mrRate, amount, _isBurn);
    }

    
    function setPoolAddressTOSETH(address _poolAddressTOSETH) external override onlyProxyOwner {
        require(poolAddressTOSETH != _poolAddressTOSETH, "same address");
        poolAddressTOSETH = _poolAddressTOSETH;

        emit SetPoolAddressTOSETH(_poolAddressTOSETH);
    }

    
    function setUniswapV3Factory(address _uniswapFactory) external override onlyProxyOwner {
        require(uniswapV3Factory != _uniswapFactory, "same address");
        uniswapV3Factory = _uniswapFactory;

        emit SetUniswapV3Factory(_uniswapFactory);
    }

    
    function setMintRateDenominator(uint256 _mintRateDenominator) external override onlyProxyOwner {
        require(mintRateDenominator != _mintRateDenominator && _mintRateDenominator > 0, "check input value");
        mintRateDenominator = _mintRateDenominator;

        emit SetMintRateDenominator(_mintRateDenominator);
    }

    
    function addBackingList(address _address)
        external override onlyPolicyOwner
        nonZeroAddress(_address)
    {
        _addBackingList(_address);
    }

    function _addBackingList(address _address) internal
    {
        require(backingIndexPlusOne[_address] == 0, "already added.");

        backings.push(_address);
        backingIndexPlusOne[_address] = backings.length;

        emit AddedBackingList(_address);
    }

    
    function deleteBackingList(
        address _address
    )
        external override onlyPolicyOwner
        nonZeroAddress(_address)
    {
        require(backingIndexPlusOne[_address] != 0, "no backing address");

        uint256 len = backings.length;
        uint256 index = backingIndexPlusOne[_address] - 1;

        if (index < len-1) backings[index] = backings[len-1];
        backings.pop();


        emit DeletedBackingList(_address);
    }

    
    function setFoundationDistributeInfo(
        address[] calldata  _address,
        uint256[] calldata _percents
    )
        external override onlyPolicyOwner
    {
        require(_address.length > 0, "zero length");
        require(_address.length == _percents.length, "wrong length");
        foundationTotalPercentage = 0;

        uint256 len = _address.length;
        for (uint256 i = 0; i< len ; i++){
            require(_address[i] != address(0), "zero address");
            require(_percents[i] > 0, "zero _percents");
            foundationTotalPercentage += _percents[i];
        }
        require(foundationTotalPercentage < 10000, "wrong _percents");

        delete mintings;

        for (uint256 i = 0; i< len ; i++) {
            mintings.push(
                LibTreasury.Minting({
                    mintAddress: _address[i],
                    mintPercents: _percents[i]
                })
            );
        }

        emit SetFoundationDistributeInfo(_address, _percents);
    }

    function foundationDistribute() external {
        require(foundationAmount > 0 && foundationTotalPercentage > 0 && mintings.length > 0, "No funds or no distribution");
        uint256 _amount = foundationAmount;

        for (uint256 i = 0; i < mintings.length ; i++) {
            uint256 _distributeAmount = foundationAmount * mintings[i].mintPercents / foundationTotalPercentage;
            _amount -= _distributeAmount;
            tos.safeTransfer(mintings[i].mintAddress, _distributeAmount);
            emit DistributedFoundation(mintings[i].mintAddress, _distributeAmount);
        }

        foundationAmount = _amount;
    }

    /* ========== permissions : LibTreasury.STATUS.RESERVEDEPOSITOR ========== */

    
    function requestMint(
        uint256 _mintAmount,
        uint256 _payout,
        bool _distribute
    ) external override nonZero(_mintAmount)
    {
        require(isBonder(msg.sender), notApproved);

        tos.mint(address(this), _mintAmount);

        if (_distribute && foundationTotalPercentage > 0 )
          foundationAmount += ((_mintAmount - _payout) * foundationTotalPercentage / 10000);

        emit RequestedMint(_mintAmount, _payout, _distribute);

    }

    
    function addBondAsset(address _address)  external override
    {
        require(isBonder(msg.sender), "caller is not bonder");
        require(_address != address(0), "zero asset");
        _addBackingList(_address);
    }

    
    function requestTransfer(
        address _recipient,
        uint256 _amount
    ) external override {
        require(isStaker(msg.sender), notApproved);
        require(_recipient != address(0) && _amount > 0, "zero recipient or amount");

        require(enableStaking() >= _amount, "treasury balance is insufficient");

        tos.safeTransfer(_recipient, _amount);

        emit RequestedTransfer(_recipient, _amount);
    }


    /* ========== VIEW ========== */

    
    function getMintRate() public override view returns (uint256) {
        return mintRate;
    }

    
    function backingRateETHPerTOS() public override view returns (uint256) {
        return (backingReserve() * 1e18 / tos.totalSupply()) ;
    }

    
    function indexInRegistry(
        address _address,
        LibTreasury.STATUS _status
    )
        public override view returns (bool, uint256)
    {
        address[] memory entries = registry[_status];
        for (uint256 i = 0; i < entries.length; i++) {
            if (_address == entries[i]) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    
    function enableStaking() public override view returns (uint256) {
        uint256 _balance = tos.balanceOf(address(this));
        if (_balance >= foundationAmount) return (_balance - foundationAmount);
        return 0;
    }

    
    function backingReserve() public override view returns (uint256) {
        uint256 totalValue = 0;

        bool applyWTON = false;
        uint256 tosETHPricePerTOS = 0;

        uint256 len = backings.length;
        for(uint256 i = 0; i < len; i++) {
            if (i == 0) tosETHPricePerTOS = IITOSValueCalculator(calculator).getETHPricePerTOS();
            if (backings[i] == wethAddress)  {
                totalValue += IERC20(wethAddress).balanceOf(address(this));
                applyWTON = true;

            } else if (backings[i] != address(0) && backings[i] != address(tos))  {

                (bool existedWethPool, bool existedTosPool, , uint256 convertedAmount) =
                    IITOSValueCalculator(calculator).convertAssetBalanceToWethOrTos(backings[i], IERC20(backings[i]).balanceOf(address(this)));

                if (existedWethPool) totalValue += convertedAmount;
                else if (existedTosPool){
                    if (poolAddressTOSETH != address(0) && IIIUniswapV3Pool(poolAddressTOSETH).liquidity() == 0) {
                        //  TOS * 1e18 / (TOS/ETH) = ETH
                        totalValue +=  (convertedAmount * mintRateDenominator / mintRate );
                    } else {
                        // TOS * ETH/TOS / token decimal = ETH
                        totalValue += (convertedAmount * tosETHPricePerTOS / 1e18);
                    }
                }
            }
        }

        if (!applyWTON && wethAddress != address(0)) totalValue += IERC20(wethAddress).balanceOf(address(this));

        totalValue += address(this).balance;

        return totalValue;
    }

    
    function totalBacking() public override view returns(uint256) {
         return backings.length;
    }


    
    function allBacking() external override view
        returns (address[] memory)
    {
        return backings;
    }

    
    function totalMinting() external override view returns(uint256) {
         return mintings.length;
    }

    
    function viewMintingInfo(uint256 _index)
        external override view returns(address mintAddress, uint256 mintPercents)
    {
         return (mintings[_index].mintAddress, mintings[_index].mintPercents);
    }

    
    function allMinting() external override view
        returns (
            address[] memory mintAddress,
            uint256[] memory mintPercents
            )
    {
        uint256 len = mintings.length;
        mintAddress = new address[](len);
        mintPercents = new uint256[](len);

        for (uint256 i = 0; i < len; i++){
            mintAddress[i] = mintings[i].mintAddress;
            mintPercents[i] = mintings[i].mintPercents;
        }
    }

    
    function hasPermission(uint role, address account) public override view returns (bool) {
        return permissions[LibTreasury.getStatus(role)][account];
    }

    
    function checkTosSolvencyAfterTOSMint(uint256 _checkMintRate, uint256 amount)
        public override view returns (bool)
    {
        if (tos.totalSupply() + amount  <= backingReserve() * _checkMintRate / mintRateDenominator)  return true;
        else return false;
    }

    function checkTosSolvencyAfterTOSBurn(uint256 _checkMintRate, uint256 amount)
        public override view returns (bool)
    {
        if (tos.totalSupply() - amount  <= backingReserve() * _checkMintRate / mintRateDenominator)  return true;
        else return false;
    }

    
    function  checkTosSolvency(uint256 amount) public override view returns (bool)
    {
        if ( tos.totalSupply() + amount <= backingReserve() * mintRate / mintRateDenominator)  return true;
        else return false;
    }

    
    function backingReserveETH() public override view returns (uint256) {
        return backingReserve();
    }

    
    function backingReserveTOS() public override view returns (uint256) {

        return backingReserve() * getTOSPricePerETH() / 1e18;
    }

    
    function getETHPricePerTOS() public override view returns (uint256) {
        if (poolAddressTOSETH != address(0) && IIIUniswapV3Pool(poolAddressTOSETH).liquidity() == 0) {
            return  (mintRateDenominator / mintRate);
        } else {
            return IITOSValueCalculator(calculator).getETHPricePerTOS();
        }
    }

    
    function getTOSPricePerETH() public override view returns (uint256) {
        if (poolAddressTOSETH != address(0) && IIIUniswapV3Pool(poolAddressTOSETH).liquidity() == 0) {
            return  mintRate;
        } else {
            return IITOSValueCalculator(calculator).getTOSPricePerETH();
        }
    }

    
    function isBonder(address account) public override view virtual returns (bool) {
        return permissions[LibTreasury.STATUS.BONDER][account];
    }

    
    function isStaker(address account) public override view virtual returns (bool) {
        return permissions[LibTreasury.STATUS.STAKER][account];
    }

    function withdrawEther(address account) external onlyPolicyOwner nonZeroAddress(account) {
        require(address(this).balance > 0, "zero balance");
        payable(account).transfer(address(this).balance);
    }
}

// 
pragma solidity >=0.7.5;





/// Taken from Solmate
library SafeERC20 {
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FAILED");
    }

    function safeApprove(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.approve.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "APPROVE_FAILED");
    }

    function safeTransferETH(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}(new bytes(0));

        require(success, "ETH_TRANSFER_FAILED");
    }
}

// 
pragma solidity ^0.8.4;


library LibTreasury
{

    enum STATUS {
        NONE,              //
        RESERVEDEPOSITOR,  // 트래저리에 예치할수있는 권한
        RESERVESPENDER,    // 트래저리에서 자산 사용할 수 있는 권한
        RESERVETOKEN,      // 트래저리에서 사용가능한 토큰
        RESERVEMANAGER,     // 트래저리 어드민 권한
        LIQUIDITYDEPOSITOR, // 트래저리에 유동성 권한
        LIQUIDITYTOKEN,     // 트래저리에 유동성 토큰으로 사용할 수 있는 토큰
        LIQUIDITYMANAGER,   // 트래저리에 유동성 제공 가능자
        REWARDMANAGER,       // 트래저리에 민트 사용 권한.
        BONDER,              // 본더
        STAKER                  // 스테이커
    }

    // 민트된 양에서 원금(토스 평가금)빼고,
    // 나머지에서 기관에 분배 정보 (기관주소, 남는금액에서 퍼센트)의 구조체
    struct Minting {
        address mintAddress;
        uint256 mintPercents;
    }

    function getStatus(uint role) external pure returns (STATUS _status) {
        if (role == uint(STATUS.RESERVEDEPOSITOR)) return  STATUS.RESERVEDEPOSITOR;
        else if (role == uint(STATUS.RESERVESPENDER)) return  STATUS.RESERVESPENDER;
        else if (role == uint(STATUS.RESERVETOKEN)) return  STATUS.RESERVETOKEN;
        else if (role == uint(STATUS.RESERVEMANAGER)) return  STATUS.RESERVEMANAGER;
        else if (role == uint(STATUS.LIQUIDITYDEPOSITOR)) return  STATUS.LIQUIDITYDEPOSITOR;
        else if (role == uint(STATUS.LIQUIDITYTOKEN)) return  STATUS.LIQUIDITYTOKEN;
        else if (role == uint(STATUS.LIQUIDITYMANAGER)) return  STATUS.LIQUIDITYMANAGER;
        else if (role == uint(STATUS.REWARDMANAGER)) return  STATUS.REWARDMANAGER;
        else if (role == uint(STATUS.BONDER)) return  STATUS.BONDER;
        else if (role == uint(STATUS.STAKER)) return  STATUS.STAKER;
        else   return  STATUS.NONE;
    }
}

// 
pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function mint(address account, uint256 amount) external returns (bool);

    function burn(address account, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
