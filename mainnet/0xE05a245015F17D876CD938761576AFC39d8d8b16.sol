// SPDX-License-Identifier: MIT
pragma abicoder v2;


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
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
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
}

// 
pragma solidity ^0.7.6;

contract AccessRoleCommon {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER");
}

//
pragma solidity ^0.7.6;

interface IStake1Logic {
    
    
    
    
    event CreatedVault(address indexed vault, address paytoken, uint256 cap);

    
    
    
    
    event CreatedStakeContract(
        address indexed vault,
        address indexed stakeContract,
        uint256 phase
    );

    
    
    event ClosedSale(address indexed vault);

    
    
    event SetStakeRegistry(address stakeRegistry);

    /// Set initial variables
    
    
    
    
    
    
    
    
    function setStore(
        address _tos,
        address _stakeRegistry,
        address _stakeFactory,
        address _stakeVaultFactory,
        address _ton,
        address _wton,
        address _depositManager,
        address _seigManager
    ) external;

    

    
    
    function setFactoryByStakeType(uint256 _stakeType, address _factory)
        external;

    
    
    
    
    
    
    
    
    
    function createVault(
        address _paytoken,
        uint256 _cap,
        uint256 _saleStartBlock,
        uint256 _stakeStartBlock,
        uint256 _phase,
        bytes32 _vaultName,
        uint256 _stakeType,
        address _defiAddr
    ) external;

    
    
    
    
    
    
    
    function createStakeContract(
        uint256 _phase,
        address _vault,
        address token,
        address paytoken,
        uint256 periodBlock,
        string memory _name
    ) external;

    
    
    
    
    function addVault(
        uint256 _phase,
        bytes32 _vaultName,
        address _vault
    ) external;

    
    
    function closeSale(address _vault) external;

    
    
    function stakeContractsOfVault(address _vault)
        external
        view
        returns (address[] memory);

    
    
    function vaultsOfPhase(uint256 _phase)
        external
        view
        returns (address[] memory);

    
    
    
    
    function tokamakStaking(
        address _stakeContract,
        address _layer2,
        uint256 stakeAmount
    ) external;

    
    
    
    
    function tokamakRequestUnStaking(
        address _stakeContract,
        address _layer2,
        uint256 amount
    ) external;

    
    
    
    function tokamakRequestUnStakingAll(address _stakeContract, address _layer2)
        external;

    
    
    
    function tokamakProcessUnStaking(address _stakeContract, address _layer2)
        external;

    
    
    
    
    
    
    
    
    function exchangeWTONtoTOS(
        address _stakeContract,
        uint256 amountIn,
        uint256 amountOutMinimum,
        uint256 deadline,
        uint160 sqrtPriceLimitX96,
        uint256 _type
    ) external returns (uint256 amountOut);
}

// 
pragma solidity ^0.7.6;



contract AccessibleCommon is AccessRoleCommon, AccessControl {
    modifier onlyOwner() {
        require(isAdmin(msg.sender), "Accessible: Caller is not an admin");
        _;
    }

    
    
    function addAdmin(address account) public virtual onlyOwner {
        grantRole(ADMIN_ROLE, account);
    }

    
    
    function removeAdmin(address account) public virtual onlyOwner {
        renounceRole(ADMIN_ROLE, account);
    }

    
    
    function transferAdmin(address newAdmin) external virtual onlyOwner {
        require(newAdmin != address(0), "Accessible: zero address");
        require(msg.sender != newAdmin, "Accessible: same admin");

        grantRole(ADMIN_ROLE, newAdmin);
        renounceRole(ADMIN_ROLE, msg.sender);
    }

    
    
    function isAdmin(address account) public view virtual returns (bool) {
        return hasRole(ADMIN_ROLE, account);
    }
}

//
pragma solidity ^0.7.6;

//import "../interfaces/IStakeProxyStorage.sol";





contract StakeProxyStorage {
    
    IStakeRegistry public stakeRegistry;

    
    IStakeFactory public stakeFactory;

    
    IStakeVaultFactory public stakeVaultFactory;

    
    address public tos;

    
    address public ton;

    
    address public wton;

    
    address public depositManager;

    
    address public seigManager;

    
    bool public pauseProxy;

    
    mapping(uint256 => address) public proxyImplementation;

    mapping(address => bool) public aliveImplementation;

    mapping(bytes4 => address) public selectorImplementation;
}
// 
pragma solidity ^0.7.6;















/// User can excute the tokamak staking function of each contract through this logic.
contract Stake1Logic is StakeProxyStorage, AccessibleCommon, IStake1Logic {
    modifier nonZeroAddress(address _addr) {
        require(_addr != address(0), "Stake1Logic:zero address");
        _;
    }

    /*
    
    
    
    
    event CreatedVault(address indexed vault, address paytoken, uint256 cap);

    
    
    
    
    event CreatedStakeContract(
        address indexed vault,
        address indexed stakeContract,
        uint256 phase
    );

    
    
    event ClosedSale(address indexed vault);

    
    
    event SetStakeRegistry(address stakeRegistry);
*/

    constructor() {}

    
    
    
    function upgradeStakeTo(address _stakeProxy, address _implementation)
        external
        onlyOwner
    {
        IProxy(_stakeProxy).upgradeTo(_implementation);
    }

    
    
    
    
    function grantRole(
        address target,
        bytes32 role,
        address account
    ) external onlyOwner {
        AccessControl(target).grantRole(role, account);
    }

    
    
    
    
    function revokeRole(
        address target,
        bytes32 role,
        address account
    ) external onlyOwner {
        AccessControl(target).revokeRole(role, account);
    }

    
    
    function setTOS(address _tos) public onlyOwner nonZeroAddress(_tos) {
        tos = _tos;
    }

    
    
    function setStakeRegistry(address _stakeRegistry)
        public
        onlyOwner
        nonZeroAddress(_stakeRegistry)
    {
        stakeRegistry = IStakeRegistry(_stakeRegistry);
        emit SetStakeRegistry(_stakeRegistry);
    }

    
    
    function setStakeFactory(address _stakeFactory)
        public
        onlyOwner
        nonZeroAddress(_stakeFactory)
    {
        stakeFactory = IStakeFactory(_stakeFactory);
    }

    
    
    
    function setFactoryByStakeType(uint256 _stakeType, address _factory)
        external
        override
        onlyOwner
        nonZeroAddress(address(stakeFactory))
    {
        stakeFactory.setFactoryByStakeType(_stakeType, _factory);
    }

    
    
    function setStakeVaultFactory(address _stakeVaultFactory)
        external
        onlyOwner
        nonZeroAddress(_stakeVaultFactory)
    {
        stakeVaultFactory = IStakeVaultFactory(_stakeVaultFactory);
    }

    /// Set initial variables
    
    
    
    
    
    
    
    
    function setStore(
        address _tos,
        address _stakeRegistry,
        address _stakeFactory,
        address _stakeVaultFactory,
        address _ton,
        address _wton,
        address _depositManager,
        address _seigManager
    )
        external
        override
        onlyOwner
        nonZeroAddress(_stakeVaultFactory)
        nonZeroAddress(_ton)
        nonZeroAddress(_wton)
        nonZeroAddress(_depositManager)
    {
        setTOS(_tos);
        setStakeRegistry(_stakeRegistry);
        setStakeFactory(_stakeFactory);
        stakeVaultFactory = IStakeVaultFactory(_stakeVaultFactory);

        ton = _ton;
        wton = _wton;
        depositManager = _depositManager;
        seigManager = _seigManager;
    }

    
    
    
    
    
    
    
    
    
    function createVault(
        address _paytoken,
        uint256 _cap,
        uint256 _saleStartBlock,
        uint256 _stakeStartBlock,
        uint256 _phase,
        bytes32 _vaultName,
        uint256 _stakeType,
        address _defiAddr
    ) external override onlyOwner nonZeroAddress(address(stakeVaultFactory)) {
        address vault =
            stakeVaultFactory.create(
                _phase,
                [tos, _paytoken, address(stakeFactory), _defiAddr],
                [_stakeType, _cap, _saleStartBlock, _stakeStartBlock],
                address(this)
            );
        require(vault != address(0), "Stake1Logic: vault is zero");
        stakeRegistry.addVault(vault, _phase, _vaultName);

        emit CreatedVault(vault, _paytoken, _cap);
    }

    
    
    
    
    
    
    
    function createStakeContract(
        uint256 _phase,
        address _vault,
        address token,
        address paytoken,
        uint256 periodBlock,
        string memory _name
    ) external override onlyOwner {
        require(
            stakeRegistry.validVault(_phase, _vault),
            "Stake1Logic: unvalidVault"
        );

        IStake1Vault vault = IStake1Vault(_vault);

        (
            address[2] memory addrInfos,
            ,
            uint256 stakeType,
            uint256[3] memory iniInfo,
            ,

        ) = vault.infos();

        require(paytoken == addrInfos[0], "Stake1Logic: differrent paytoken");
        uint256 phase = _phase;
        address[4] memory _addr = [token, addrInfos[0], _vault, addrInfos[1]];

        // solhint-disable-next-line max-line-length
        address _contract =
            stakeFactory.create(
                stakeType,
                _addr,
                address(stakeRegistry),
                [iniInfo[0], iniInfo[1], periodBlock]
            );
        require(_contract != address(0), "Stake1Logic: deploy fail");

        IStake1Vault(_vault).addSubVaultOfStake(_name, _contract, periodBlock);
        stakeRegistry.addStakeContract(address(vault), _contract);

        emit CreatedStakeContract(address(vault), _contract, phase);
    }

    
    
    
    
    function addVault(
        uint256 _phase,
        bytes32 _vaultName,
        address _vault
    ) external override onlyOwner {
        stakeRegistry.addVault(_vault, _phase, _vaultName);
    }

    
    
    function closeSale(address _vault) external override {
        IStake1Vault(_vault).closeSale();

        emit ClosedSale(_vault);
    }

    
    
    function stakeContractsOfVault(address _vault)
        external
        view
        override
        nonZeroAddress(_vault)
        returns (address[] memory)
    {
        return IStake1Vault(_vault).stakeAddressesAll();
    }

    
    
    function vaultsOfPhase(uint256 _phase)
        external
        view
        override
        returns (address[] memory)
    {
        return stakeRegistry.phasesAll(_phase);
    }

    
    
    
    
    function tokamakStaking(
        address _stakeContract,
        address _layer2,
        uint256 stakeAmount
    ) external override {
        IStakeTONTokamak(_stakeContract).tokamakStaking(_layer2, stakeAmount);
    }

    
    
    
    
    function tokamakRequestUnStaking(
        address _stakeContract,
        address _layer2,
        uint256 amount
    ) external override {
        IStakeTONTokamak(_stakeContract).tokamakRequestUnStaking(
            _layer2,
            amount
        );
    }

    
    
    
    function tokamakRequestUnStakingAll(address _stakeContract, address _layer2)
        external
        override
    {
        IStakeTONTokamak(_stakeContract).tokamakRequestUnStakingAll(_layer2);
    }

    
    
    
    function tokamakProcessUnStaking(address _stakeContract, address _layer2)
        external
        override
    {
        IStakeTONTokamak(_stakeContract).tokamakProcessUnStaking(_layer2);
    }

    
    
    
    
    
    
    
    
    function exchangeWTONtoTOS(
        address _stakeContract,
        uint256 amountIn,
        uint256 amountOutMinimum,
        uint256 deadline,
        uint160 sqrtPriceLimitX96,
        uint256 _type
    ) external override returns (uint256 amountOut) {
        return
            IStakeTONTokamak(_stakeContract).exchangeWTONtoTOS(
                amountIn,
                amountOutMinimum,
                deadline,
                sqrtPriceLimitX96,
                _type
            );
    }
}

// 
pragma solidity ^0.7.6;

interface IProxy {
    function upgradeTo(address impl) external;
}

//
pragma solidity ^0.7.6;

interface IStakeFactory {
    
    
    
    
    
    
    function create(
        uint256 stakeType,
        address[4] calldata _addr,
        address registry,
        uint256[3] calldata _intdata
    ) external returns (address);

    
    
    
    function setFactoryByStakeType(uint256 _stakeType, address _factory)
        external;
}

//
pragma solidity ^0.7.6;

interface IStakeRegistry {
    
    
    
    
    
    
    function setTokamak(
        address _ton,
        address _wton,
        address _depositManager,
        address _seigManager,
        address _swapProxy
    ) external;

    
    
    
    
    
    
    
    function addDefiInfo(
        string calldata _name,
        address _router,
        address _ex1,
        address _ex2,
        uint256 _fee,
        address _routerV2
    ) external;

    
    
    
    
    
    function addVault(
        address _vault,
        uint256 _phase,
        bytes32 _vaultName
    ) external;

    
    
    
    
    function addStakeContract(address _vault, address _stakeContract) external;

    
    
    function getTokamak()
        external
        view
        returns (
            address,
            address,
            address,
            address,
            address
        );

    
    
    function getUniswap()
        external
        view
        returns (
            address,
            address,
            address,
            uint256,
            address
        );

    
    
    
    
    function validVault(uint256 _phase, address _vault)
        external
        view
        returns (bool valid);

    function phasesAll(uint256 _index) external view returns (address[] memory);

    function stakeContractsOfVaultAll(address _vault)
        external
        view
        returns (address[] memory);

    
    
    
    
    
    
    
    

    function defiInfo(bytes32 _name)
        external
        returns (
            string calldata name,
            address router,
            address ext1,
            address ext2,
            uint256 fee,
            address routerV2
        );
}

//
pragma solidity ^0.7.6;



interface IStake1Vault {
    
    
    function setTOS(address _tos) external;

    
    
    function changeCap(uint256 _cap) external;

    
    
    function setDefiAddr(address _defiAddr) external;

    
    
    function withdrawReward(uint256 _amount) external;

    
    
    
    
    function addSubVaultOfStake(
        string memory _name,
        address stakeContract,
        uint256 periodBlocks
    ) external;

    
    function closeSale() external;

    
    
    
    
    
    
    
    function claim(address _to, uint256 _amount) external returns (bool);

    
    
    
    
    function canClaim(address _to, uint256 _amount)
        external
        view
        returns (bool);

    
    
    function infos()
        external
        view
        returns (
            address[2] memory,
            uint256,
            uint256,
            uint256[3] memory,
            uint256,
            bool
        );

    
    
    function balanceTOSAvailableAmount() external view returns (uint256);

    
    
    function totalRewardAmount(address _account)
        external
        view
        returns (uint256);

    
    
    function stakeAddressesAll() external view returns (address[] memory);

    
    
    function orderedEndBlocksAll() external view returns (uint256[] memory);
}

//
pragma solidity ^0.7.6;

interface IStakeTONTokamak {
    
    
    
    function tokamakStaking(address _layer2, uint256 stakeAmount) external;

    
    
    
    function tokamakRequestUnStaking(address _layer2, uint256 wtonAmount)
        external;

    
    
    function tokamakRequestUnStakingAll(address _layer2) external;

    
    
    function tokamakProcessUnStaking(address _layer2) external;

    
    
    
    
    
    
    
    function exchangeWTONtoTOS(
        uint256 _amountIn,
        uint256 _amountOutMinimum,
        uint256 _deadline,
        uint160 sqrtPriceLimitX96,
        uint256 _kind
    ) external returns (uint256 amountOut);
}

//
pragma solidity ^0.7.6;

interface IStakeUniswapV3 {
    
    
    
    
    
    
    function stake(
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function getClaimLiquidity(uint256 tokenId)
        external
        returns (
            uint256 realReward,
            uint256 unableClaimReward,
            uint160 secondsPerLiquidityInsideX128,
            uint256 balanceCoinageOfUser,
            uint256 _coinageReward
        );

    
    function withdraw(uint256 tokenId) external;

    
    function claim(uint256 tokenId) external;

    // function setPool(
    //     address token0,
    //     address token1,
    //     string calldata defiInfoName
    // ) external;

    
    function getUserStakedTokenIds(address user)
        external
        view
        returns (uint256[] memory ids);

    
    
    
    
    
    
    
    function getDepositToken(uint256 tokenId)
        external
        view
        returns (
            address poolAddress,
            int24[2] memory tick,
            uint128 liquidity,
            uint256[6] memory args,
            uint160[2] memory secondsPL
        );

    function getUserStakedTotal(address user)
        external
        view
        returns (
            uint256 totalDepositAmount,
            uint256 totalClaimedAmount,
            uint256 totalUnableClaimAmount
        );

    
    
    
    
    function infos()
        external
        view
        returns (
            address[4] memory,
            address[4] memory,
            uint256[4] memory
        );
}

//
pragma solidity ^0.7.6;

library LibTokenStake1 {
    enum DefiStatus {
        NONE,
        APPROVE,
        DEPOSITED,
        REQUESTWITHDRAW,
        REQUESTWITHDRAWALL,
        WITHDRAW,
        END
    }
    struct DefiInfo {
        string name;
        address router;
        address ext1;
        address ext2;
        uint256 fee;
        address routerV2;
    }
    struct StakeInfo {
        string name;
        uint256 startBlock;
        uint256 endBlock;
        uint256 balance;
        uint256 totalRewardAmount;
        uint256 claimRewardAmount;
    }

    struct StakedAmount {
        uint256 amount;
        uint256 claimedBlock;
        uint256 claimedAmount;
        uint256 releasedBlock;
        uint256 releasedAmount;
        uint256 releasedTOSAmount;
        bool released;
    }

    struct StakedAmountForSTOS {
        uint256 amount;
        uint256 startBlock;
        uint256 periodBlock;
        uint256 rewardPerBlock;
        uint256 claimedBlock;
        uint256 claimedAmount;
        uint256 releasedBlock;
        uint256 releasedAmount;
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
library EnumerableSet {
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
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
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
        return address(uint256(_at(set._inner, index)));
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
pragma solidity ^0.7.6;

interface IStakeVaultFactory {
    
    
    
    
    
    
    function create(
        uint256 _phase,
        address[4] calldata _addr,
        uint256[4] calldata _intInfo,
        address owner
    ) external returns (address);

    
    
    
    
    
    
    
    function create2(
        uint256 _phase,
        address[2] calldata _addr,
        uint256[3] calldata _intInfo,
        string memory _name,
        address owner
    ) external returns (address);

    
    
    
    function setVaultLogicByPhase(uint256 _phase, address _logic) external;
}
