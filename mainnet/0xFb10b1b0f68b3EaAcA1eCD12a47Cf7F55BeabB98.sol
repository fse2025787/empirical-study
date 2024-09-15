// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts v4.4.1 (utils/Multicall.sol)

pragma solidity ^0.8.0;



/**
 * @dev Provides a function to batch together multiple calls in a single external call.
 *
 * _Available since v4.1._
 */
abstract contract Multicall {
    /**
     * @dev Receives and executes a batch of function calls on this contract.
     */
    function multicall(bytes[] calldata data) external returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), data[i]);
        }
        return results;
    }
}

// 
pragma solidity ^0.8.0;

interface IAccessControlRegistryUser {
    function accessControlRegistry() external view returns (address);
}

// 
pragma solidity ^0.8.0;


/// AccessControlRegistry roles

/// derive roles, it should inherit this contract instead of re-implementing
/// the logic
contract RoleDeriver {
    
    
    
    function _deriveRootRole(address manager)
        internal
        pure
        returns (bytes32 rootRole)
    {
        rootRole = keccak256(abi.encodePacked(manager));
    }

    
    
    /// same description
    
    
    
    function _deriveRole(bytes32 adminRole, string memory description)
        internal
        pure
        returns (bytes32 role)
    {
        role = _deriveRole(adminRole, keccak256(abi.encodePacked(description)));
    }

    
    
    /// same description
    
    
    /// role
    
    function _deriveRole(bytes32 adminRole, bytes32 descriptionHash)
        internal
        pure
        returns (bytes32 role)
    {
        role = keccak256(abi.encodePacked(adminRole, descriptionHash));
    }
}

// 
pragma solidity ^0.8.0;





/// AccessControlRegistry
contract AccessControlRegistryUser is IAccessControlRegistryUser {
    
    address public immutable override accessControlRegistry;

    
    constructor(address _accessControlRegistry) {
        require(_accessControlRegistry != address(0), "ACR address zero");
        accessControlRegistry = _accessControlRegistry;
    }
}

// 
pragma solidity ^0.8.0;



interface IAccessControlRegistryAdminned is IAccessControlRegistryUser {
    function adminRoleDescription() external view returns (string memory);
}

// 
pragma solidity ^0.8.0;

interface IWhitelistRoles {
    // solhint-disable-next-line func-name-mixedcase
    function WHITELIST_EXPIRATION_EXTENDER_ROLE_DESCRIPTION()
        external
        view
        returns (string memory);

    // solhint-disable-next-line func-name-mixedcase
    function WHITELIST_EXPIRATION_SETTER_ROLE_DESCRIPTION()
        external
        view
        returns (string memory);

    // solhint-disable-next-line func-name-mixedcase
    function INDEFINITE_WHITELISTER_ROLE_DESCRIPTION()
        external
        view
        returns (string memory);
}

// 
pragma solidity ^0.8.0;







/// will be implemented using AccessControlRegistry
contract AccessControlRegistryAdminned is
    Multicall,
    RoleDeriver,
    AccessControlRegistryUser,
    IAccessControlRegistryAdminned
{
    
    string public override adminRoleDescription;

    bytes32 internal immutable adminRoleDescriptionHash;

    
    /// the same roles, meaning that granting an account a role will authorize
    /// it in multiple contracts. Unless you want your deployed contract to
    /// share the role configuration of another contract, use a unique admin
    /// role description.
    
    
    constructor(
        address _accessControlRegistry,
        string memory _adminRoleDescription
    ) AccessControlRegistryUser(_accessControlRegistry) {
        require(
            bytes(_adminRoleDescription).length > 0,
            "Admin role description empty"
        );
        adminRoleDescription = _adminRoleDescription;
        adminRoleDescriptionHash = keccak256(
            abi.encodePacked(_adminRoleDescription)
        );
    }

    
    
    
    function _deriveAdminRole(address manager)
        internal
        view
        returns (bytes32 adminRole)
    {
        adminRole = _deriveRole(
            _deriveRootRole(manager),
            adminRoleDescriptionHash
        );
    }
}

// 
pragma solidity ^0.8.0;



interface IAccessControlRegistryAdminnedWithManager is
    IAccessControlRegistryAdminned
{
    function manager() external view returns (address);

    function adminRole() external view returns (bytes32);
}

// 
pragma solidity ^0.8.0;




/// generic AccessControlRegistry roles
contract WhitelistRoles is IWhitelistRoles {
    // There are four roles implemented in this contract:
    // Root
    // └── (1) Admin (can grant and revoke the roles below)
    //     ├── (2) Whitelist expiration extender
    //     ├── (3) Whitelist expiration setter
    //     └── (4) Indefinite whitelister
    // Their IDs are derived from the descriptions below. Refer to
    // AccessControlRegistry for more information.
    // To clarify, the root role of the manager is the admin of (1), while (1)
    // is the admin of (2), (3) and (4). So (1) is more of a "contract admin",
    // while the `adminRole` used in AccessControl and AccessControlRegistry
    // refers to a more general adminship relationship between roles.

    
    string
        public constant
        override WHITELIST_EXPIRATION_EXTENDER_ROLE_DESCRIPTION =
        "Whitelist expiration extender";

    
    string
        public constant
        override WHITELIST_EXPIRATION_SETTER_ROLE_DESCRIPTION =
        "Whitelist expiration setter";

    

    string public constant override INDEFINITE_WHITELISTER_ROLE_DESCRIPTION =
        "Indefinite whitelister";

    bytes32
        internal constant WHITELIST_EXPIRATION_EXTENDER_ROLE_DESCRIPTION_HASH =
        keccak256(
            abi.encodePacked(WHITELIST_EXPIRATION_EXTENDER_ROLE_DESCRIPTION)
        );

    bytes32
        internal constant WHITELIST_EXPIRATION_SETTER_ROLE_DESCRIPTION_HASH =
        keccak256(
            abi.encodePacked(WHITELIST_EXPIRATION_SETTER_ROLE_DESCRIPTION)
        );

    bytes32 internal constant INDEFINITE_WHITELISTER_ROLE_DESCRIPTION_HASH =
        keccak256(abi.encodePacked(INDEFINITE_WHITELISTER_ROLE_DESCRIPTION));
}

// 
pragma solidity ^0.8.0;





/// functionality will be implemented using AccessControlRegistry

/// AccessControlRegistry user that is a multisig/DAO
contract AccessControlRegistryAdminnedWithManager is
    AccessControlRegistryAdminned,
    IAccessControlRegistryAdminnedWithManager
{
    
    /// AccessControlRegistry roles
    
    /// designating an OwnableCallForwarder contract as the manager. The
    /// ownership of this contract can then be transferred, effectively
    /// transferring managership.
    address public immutable override manager;

    
    
    bytes32 public immutable override adminRole;

    
    
    
    constructor(
        address _accessControlRegistry,
        string memory _adminRoleDescription,
        address _manager
    )
        AccessControlRegistryAdminned(
            _accessControlRegistry,
            _adminRoleDescription
        )
    {
        require(_manager != address(0), "Manager address zero");
        manager = _manager;
        adminRole = _deriveAdminRole(_manager);
    }
}

// 
pragma solidity ^0.8.0;




interface IWhitelistRolesWithManager is
    IWhitelistRoles,
    IAccessControlRegistryAdminnedWithManager
{
    function whitelistExpirationExtenderRole() external view returns (bytes32);

    function whitelistExpirationSetterRole() external view returns (bytes32);

    function indefiniteWhitelisterRole() external view returns (bytes32);
}

// 
pragma solidity ^0.8.0;


/// permanent whitelists for services identified by hashes

///   (1) Temporary, ends when the expiration timestamp is in the past
///   (2) Indefinite, ends when the indefinite whitelist count is zero
/// Multiple senders can indefinitely whitelist/unwhitelist independently. The
/// user will be considered whitelisted as long as there is at least one active
/// indefinite whitelisting.

/// inherited and its functions should be exposed with a sort of an
/// authorization scheme.
contract Whitelist {
    struct WhitelistStatus {
        uint64 expirationTimestamp;
        uint192 indefiniteWhitelistCount;
    }

    mapping(bytes32 => mapping(address => WhitelistStatus))
        internal serviceIdToUserToWhitelistStatus;

    mapping(bytes32 => mapping(address => mapping(address => bool)))
        internal serviceIdToUserToSetterToIndefiniteWhitelistStatus;

    
    /// for the service
    
    
    
    /// will expire
    function _extendWhitelistExpiration(
        bytes32 serviceId,
        address user,
        uint64 expirationTimestamp
    ) internal {
        require(
            expirationTimestamp >
                serviceIdToUserToWhitelistStatus[serviceId][user]
                    .expirationTimestamp,
            "Does not extend expiration"
        );
        serviceIdToUserToWhitelistStatus[serviceId][user]
            .expirationTimestamp = expirationTimestamp;
    }

    
    /// the service
    
    
    
    
    /// will expire
    function _setWhitelistExpiration(
        bytes32 serviceId,
        address user,
        uint64 expirationTimestamp
    ) internal {
        serviceIdToUserToWhitelistStatus[serviceId][user]
            .expirationTimestamp = expirationTimestamp;
    }

    
    /// service
    
    /// indefinite whitelist status of the user for the service as true, the
    /// user will be considered whitelisted
    
    
    
    function _setIndefiniteWhitelistStatus(
        bytes32 serviceId,
        address user,
        bool status
    ) internal returns (uint192 indefiniteWhitelistCount) {
        indefiniteWhitelistCount = serviceIdToUserToWhitelistStatus[serviceId][
            user
        ].indefiniteWhitelistCount;
        if (
            status &&
            !serviceIdToUserToSetterToIndefiniteWhitelistStatus[serviceId][
                user
            ][msg.sender]
        ) {
            serviceIdToUserToSetterToIndefiniteWhitelistStatus[serviceId][user][
                msg.sender
            ] = true;
            indefiniteWhitelistCount++;
            serviceIdToUserToWhitelistStatus[serviceId][user]
                .indefiniteWhitelistCount = indefiniteWhitelistCount;
        } else if (
            !status &&
            serviceIdToUserToSetterToIndefiniteWhitelistStatus[serviceId][user][
                msg.sender
            ]
        ) {
            serviceIdToUserToSetterToIndefiniteWhitelistStatus[serviceId][user][
                msg.sender
            ] = false;
            indefiniteWhitelistCount--;
            serviceIdToUserToWhitelistStatus[serviceId][user]
                .indefiniteWhitelistCount = indefiniteWhitelistCount;
        }
    }

    
    /// the service by a specific account
    
    
    
    function _revokeIndefiniteWhitelistStatus(
        bytes32 serviceId,
        address user,
        address setter
    ) internal returns (bool revoked, uint192 indefiniteWhitelistCount) {
        indefiniteWhitelistCount = serviceIdToUserToWhitelistStatus[serviceId][
            user
        ].indefiniteWhitelistCount;
        if (
            serviceIdToUserToSetterToIndefiniteWhitelistStatus[serviceId][user][
                setter
            ]
        ) {
            serviceIdToUserToSetterToIndefiniteWhitelistStatus[serviceId][user][
                setter
            ] = false;
            indefiniteWhitelistCount--;
            serviceIdToUserToWhitelistStatus[serviceId][user]
                .indefiniteWhitelistCount = indefiniteWhitelistCount;
            revoked = true;
        }
    }

    
    
    
    
    function userIsWhitelisted(bytes32 serviceId, address user)
        internal
        view
        returns (bool isWhitelisted)
    {
        WhitelistStatus
            storage whitelistStatus = serviceIdToUserToWhitelistStatus[
                serviceId
            ][user];
        return
            whitelistStatus.indefiniteWhitelistCount > 0 ||
            whitelistStatus.expirationTimestamp > block.timestamp;
    }
}

// 
pragma solidity ^0.8.0;







/// roles where there is a single manager
contract WhitelistRolesWithManager is
    WhitelistRoles,
    AccessControlRegistryAdminnedWithManager,
    IWhitelistRolesWithManager
{
    // Since there will be a single manager, we can derive the roles beforehand

    
    bytes32 public immutable override whitelistExpirationExtenderRole;

    
    bytes32 public immutable override whitelistExpirationSetterRole;

    
    bytes32 public immutable override indefiniteWhitelisterRole;

    
    
    
    constructor(
        address _accessControlRegistry,
        string memory _adminRoleDescription,
        address _manager
    )
        AccessControlRegistryAdminnedWithManager(
            _accessControlRegistry,
            _adminRoleDescription,
            _manager
        )
    {
        whitelistExpirationExtenderRole = _deriveRole(
            adminRole,
            WHITELIST_EXPIRATION_EXTENDER_ROLE_DESCRIPTION_HASH
        );
        whitelistExpirationSetterRole = _deriveRole(
            adminRole,
            WHITELIST_EXPIRATION_SETTER_ROLE_DESCRIPTION_HASH
        );
        indefiniteWhitelisterRole = _deriveRole(
            adminRole,
            INDEFINITE_WHITELISTER_ROLE_DESCRIPTION_HASH
        );
    }

    
    /// or is the manager
    
    
    /// manager
    function hasWhitelistExpirationExtenderRoleOrIsManager(address account)
        internal
        view
        returns (bool)
    {
        return
            manager == account ||
            IAccessControlRegistry(accessControlRegistry).hasRole(
                whitelistExpirationExtenderRole,
                account
            );
    }

    
    /// is the manager
    
    
    /// manager
    function hasWhitelistExpirationSetterRoleOrIsManager(address account)
        internal
        view
        returns (bool)
    {
        return
            manager == account ||
            IAccessControlRegistry(accessControlRegistry).hasRole(
                whitelistExpirationSetterRole,
                account
            );
    }

    
    /// manager
    
    
    /// manager
    function hasIndefiniteWhitelisterRoleOrIsManager(address account)
        internal
        view
        returns (bool)
    {
        return
            manager == account ||
            IAccessControlRegistry(accessControlRegistry).hasRole(
                indefiniteWhitelisterRole,
                account
            );
    }
}

// 
pragma solidity ^0.8.0;



interface IWhitelistWithManager is IWhitelistRolesWithManager {
    event ExtendedWhitelistExpiration(
        bytes32 indexed serviceId,
        address indexed user,
        address indexed sender,
        uint256 expiration
    );

    event SetWhitelistExpiration(
        bytes32 indexed serviceId,
        address indexed user,
        address indexed sender,
        uint256 expiration
    );

    event SetIndefiniteWhitelistStatus(
        bytes32 indexed serviceId,
        address indexed user,
        address indexed sender,
        bool status,
        uint192 indefiniteWhitelistCount
    );

    event RevokedIndefiniteWhitelistStatus(
        bytes32 indexed serviceId,
        address indexed user,
        address indexed setter,
        address sender,
        uint192 indefiniteWhitelistCount
    );

    function extendWhitelistExpiration(
        bytes32 serviceId,
        address user,
        uint64 expirationTimestamp
    ) external;

    function setWhitelistExpiration(
        bytes32 serviceId,
        address user,
        uint64 expirationTimestamp
    ) external;

    function setIndefiniteWhitelistStatus(
        bytes32 serviceId,
        address user,
        bool status
    ) external;

    function revokeIndefiniteWhitelistStatus(
        bytes32 serviceId,
        address user,
        address setter
    ) external;
}

// 
pragma solidity ^0.8.0;

interface IAirnodeRequester {
    function airnodeProtocol() external view returns (address);
}

// 
pragma solidity ^0.8.0;


/// an unrolled implementation

/// argument will be modified.
contract Sort {
    uint256 internal constant MAX_SORT_LENGTH = 9;

    
    
    function sort(int256[] memory array) internal pure {
        uint256 arrayLength = array.length;
        require(arrayLength <= MAX_SORT_LENGTH, "Array too long to sort");
        // Do a binary search
        if (arrayLength < 6) {
            // Possible lengths: 1, 2, 3, 4, 5
            if (arrayLength < 4) {
                // Possible lengths: 1, 2, 3
                if (arrayLength == 3) {
                    // Length: 3
                    swapIfFirstIsLarger(array, 0, 1);
                    swapIfFirstIsLarger(array, 1, 2);
                    swapIfFirstIsLarger(array, 0, 1);
                } else if (arrayLength == 2) {
                    // Length: 2
                    swapIfFirstIsLarger(array, 0, 1);
                }
                // Do nothing for Length: 1
            } else {
                // Possible lengths: 4, 5
                if (arrayLength == 5) {
                    // Length: 5
                    swapIfFirstIsLarger(array, 1, 2);
                    swapIfFirstIsLarger(array, 3, 4);
                    swapIfFirstIsLarger(array, 1, 3);
                    swapIfFirstIsLarger(array, 0, 2);
                    swapIfFirstIsLarger(array, 2, 4);
                    swapIfFirstIsLarger(array, 0, 3);
                    swapIfFirstIsLarger(array, 0, 1);
                    swapIfFirstIsLarger(array, 2, 3);
                    swapIfFirstIsLarger(array, 1, 2);
                } else {
                    // Length: 4
                    swapIfFirstIsLarger(array, 0, 1);
                    swapIfFirstIsLarger(array, 2, 3);
                    swapIfFirstIsLarger(array, 1, 3);
                    swapIfFirstIsLarger(array, 0, 2);
                    swapIfFirstIsLarger(array, 1, 2);
                }
            }
        } else {
            // Possible lengths: 6, 7, 8, 9
            if (arrayLength < 8) {
                // Possible lengths: 6, 7
                if (arrayLength == 7) {
                    // Length: 7
                    swapIfFirstIsLarger(array, 1, 2);
                    swapIfFirstIsLarger(array, 3, 4);
                    swapIfFirstIsLarger(array, 5, 6);
                    swapIfFirstIsLarger(array, 0, 2);
                    swapIfFirstIsLarger(array, 4, 6);
                    swapIfFirstIsLarger(array, 3, 5);
                    swapIfFirstIsLarger(array, 2, 6);
                    swapIfFirstIsLarger(array, 1, 5);
                    swapIfFirstIsLarger(array, 0, 4);
                    swapIfFirstIsLarger(array, 2, 5);
                    swapIfFirstIsLarger(array, 0, 3);
                    swapIfFirstIsLarger(array, 2, 4);
                    swapIfFirstIsLarger(array, 1, 3);
                    swapIfFirstIsLarger(array, 0, 1);
                    swapIfFirstIsLarger(array, 2, 3);
                    swapIfFirstIsLarger(array, 4, 5);
                } else {
                    // Length: 6
                    swapIfFirstIsLarger(array, 0, 1);
                    swapIfFirstIsLarger(array, 2, 3);
                    swapIfFirstIsLarger(array, 4, 5);
                    swapIfFirstIsLarger(array, 1, 3);
                    swapIfFirstIsLarger(array, 3, 5);
                    swapIfFirstIsLarger(array, 1, 3);
                    swapIfFirstIsLarger(array, 2, 4);
                    swapIfFirstIsLarger(array, 0, 2);
                    swapIfFirstIsLarger(array, 2, 4);
                    swapIfFirstIsLarger(array, 3, 4);
                    swapIfFirstIsLarger(array, 1, 2);
                    swapIfFirstIsLarger(array, 2, 3);
                }
            } else {
                // Possible lengths: 8, 9
                if (arrayLength == 9) {
                    // Length: 9
                    swapIfFirstIsLarger(array, 1, 8);
                    swapIfFirstIsLarger(array, 2, 7);
                    swapIfFirstIsLarger(array, 3, 6);
                    swapIfFirstIsLarger(array, 4, 5);
                    swapIfFirstIsLarger(array, 1, 4);
                    swapIfFirstIsLarger(array, 5, 8);
                    swapIfFirstIsLarger(array, 0, 2);
                    swapIfFirstIsLarger(array, 6, 7);
                    swapIfFirstIsLarger(array, 2, 6);
                    swapIfFirstIsLarger(array, 7, 8);
                    swapIfFirstIsLarger(array, 0, 3);
                    swapIfFirstIsLarger(array, 4, 5);
                    swapIfFirstIsLarger(array, 0, 1);
                    swapIfFirstIsLarger(array, 3, 5);
                    swapIfFirstIsLarger(array, 6, 7);
                    swapIfFirstIsLarger(array, 2, 4);
                    swapIfFirstIsLarger(array, 1, 3);
                    swapIfFirstIsLarger(array, 5, 7);
                    swapIfFirstIsLarger(array, 4, 6);
                    swapIfFirstIsLarger(array, 1, 2);
                    swapIfFirstIsLarger(array, 3, 4);
                    swapIfFirstIsLarger(array, 5, 6);
                    swapIfFirstIsLarger(array, 7, 8);
                    swapIfFirstIsLarger(array, 2, 3);
                    swapIfFirstIsLarger(array, 4, 5);
                } else {
                    // Length: 8
                    swapIfFirstIsLarger(array, 0, 7);
                    swapIfFirstIsLarger(array, 1, 6);
                    swapIfFirstIsLarger(array, 2, 5);
                    swapIfFirstIsLarger(array, 3, 4);
                    swapIfFirstIsLarger(array, 0, 3);
                    swapIfFirstIsLarger(array, 4, 7);
                    swapIfFirstIsLarger(array, 1, 2);
                    swapIfFirstIsLarger(array, 5, 6);
                    swapIfFirstIsLarger(array, 0, 1);
                    swapIfFirstIsLarger(array, 2, 3);
                    swapIfFirstIsLarger(array, 4, 5);
                    swapIfFirstIsLarger(array, 6, 7);
                    swapIfFirstIsLarger(array, 3, 5);
                    swapIfFirstIsLarger(array, 2, 4);
                    swapIfFirstIsLarger(array, 1, 2);
                    swapIfFirstIsLarger(array, 3, 4);
                    swapIfFirstIsLarger(array, 5, 6);
                    swapIfFirstIsLarger(array, 2, 3);
                    swapIfFirstIsLarger(array, 4, 5);
                    swapIfFirstIsLarger(array, 3, 4);
                }
            }
        }
    }

    
    /// than the second
    
    
    
    function swapIfFirstIsLarger(
        int256[] memory array,
        uint256 ind1,
        uint256 ind2
    ) private pure {
        if (array[ind1] > array[ind2]) {
            (array[ind1], array[ind2]) = (array[ind2], array[ind1]);
        }
    }
}

// 
pragma solidity ^0.8.0;


/// of the k-th and optionally (k+1)-th largest elements in the array

/// as the argument will be modified.
contract Quickselect {
    
    
    
    
    function quickselectK(int256[] memory array, uint256 k)
        internal
        pure
        returns (uint256 indK)
    {
        (indK, ) = quickselect(array, 0, array.length - 1, k, false);
    }

    
    /// the array
    
    /// searched
    
    
    
    function quickselectKPlusOne(int256[] memory array, uint256 k)
        internal
        pure
        returns (uint256 indK, uint256 indKPlusOne)
    {
        uint256 arrayLength = array.length;
        require(arrayLength > 1, "Array too short to select k+1");
        return quickselect(array, 0, arrayLength - 1, k, true);
    }

    
    /// section of the (potentially unsorted) array
    
    
    /// searched in
    
    /// searched in
    
    
    /// to be returned
    
    
    /// `selectKPlusOne` is `true`)
    function quickselect(
        int256[] memory array,
        uint256 lo,
        uint256 hi,
        uint256 k,
        bool selectKPlusOne
    ) private pure returns (uint256 indK, uint256 indKPlusOne) {
        if (lo == hi) {
            return (k, 0);
        }
        uint256 indPivot = partition(array, lo, hi);
        if (k < indPivot) {
            (indK, ) = quickselect(array, lo, indPivot - 1, k, false);
        } else if (k > indPivot) {
            (indK, ) = quickselect(array, indPivot + 1, hi, k, false);
        } else {
            indK = indPivot;
        }
        // Since Quickselect ends in the array being partitioned around the
        // k-th largest element, we can continue searching towards right for
        // the (k+1)-th largest element, which is useful in calculating the
        // median of an array with even length
        if (selectKPlusOne) {
            indKPlusOne = indK + 1;
            for (uint256 i = indKPlusOne + 1; i < array.length; i++) {
                if (array[i] < array[indKPlusOne]) {
                    indKPlusOne = i;
                }
            }
        }
    }

    
    
    
    /// partitioned
    
    /// partitioned
    
    function partition(
        int256[] memory array,
        uint256 lo,
        uint256 hi
    ) private pure returns (uint256 pivotInd) {
        if (lo == hi) {
            return lo;
        }
        int256 pivot = array[lo];
        uint256 i = lo;
        pivotInd = hi + 1;
        while (true) {
            do {
                i++;
            } while (i < array.length && array[i] < pivot);
            do {
                pivotInd--;
            } while (array[pivotInd] > pivot);
            if (i >= pivotInd) {
                (array[lo], array[pivotInd]) = (array[pivotInd], array[lo]);
                return pivotInd;
            }
            (array[i], array[pivotInd]) = (array[pivotInd], array[i]);
        }
    }
}

// 
pragma solidity ^0.8.0;




/// retrieval of some globally available variables
contract ExtendedMulticall is Multicall {
    
    
    function getChainId() external view returns (uint256) {
        return block.chainid;
    }

    
    
    
    function getBalance(address account) external view returns (uint256) {
        return account.balance;
    }

    
    
    function getBlockNumber() external view returns (uint256) {
        return block.number;
    }

    
    
    function getBlockTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    
    
    function getBlockBasefee() external view returns (uint256) {
        return block.basefee;
    }
}

// 
pragma solidity ^0.8.0;






/// by a manager
contract WhitelistWithManager is
    Whitelist,
    WhitelistRolesWithManager,
    IWhitelistWithManager
{
    
    
    
    constructor(
        address _accessControlRegistry,
        string memory _adminRoleDescription,
        address _manager
    )
        WhitelistRolesWithManager(
            _accessControlRegistry,
            _adminRoleDescription,
            _manager
        )
    {}

    
    /// be able to use the service with `serviceId` if the sender has the
    /// whitelist expiration extender role
    
    
    
    /// will expire
    function extendWhitelistExpiration(
        bytes32 serviceId,
        address user,
        uint64 expirationTimestamp
    ) external override {
        require(
            hasWhitelistExpirationExtenderRoleOrIsManager(msg.sender),
            "Cannot extend expiration"
        );
        require(serviceId != bytes32(0), "Service ID zero");
        require(user != address(0), "User address zero");
        _extendWhitelistExpiration(serviceId, user, expirationTimestamp);
        emit ExtendedWhitelistExpiration(
            serviceId,
            user,
            msg.sender,
            expirationTimestamp
        );
    }

    
    /// able to use the service with `serviceId` if the sender has the
    /// whitelist expiration setter role
    
    
    
    /// will expire
    function setWhitelistExpiration(
        bytes32 serviceId,
        address user,
        uint64 expirationTimestamp
    ) external override {
        require(
            hasWhitelistExpirationSetterRoleOrIsManager(msg.sender),
            "Cannot set expiration"
        );
        require(serviceId != bytes32(0), "Service ID zero");
        require(user != address(0), "User address zero");
        _setWhitelistExpiration(serviceId, user, expirationTimestamp);
        emit SetWhitelistExpiration(
            serviceId,
            user,
            msg.sender,
            expirationTimestamp
        );
    }

    
    /// use the service with `serviceId` if the sender has the indefinite
    /// whitelister role
    
    
    
    function setIndefiniteWhitelistStatus(
        bytes32 serviceId,
        address user,
        bool status
    ) external override {
        require(
            hasIndefiniteWhitelisterRoleOrIsManager(msg.sender),
            "Cannot set indefinite status"
        );
        require(serviceId != bytes32(0), "Service ID zero");
        require(user != address(0), "User address zero");
        uint192 indefiniteWhitelistCount = _setIndefiniteWhitelistStatus(
            serviceId,
            user,
            status
        );
        emit SetIndefiniteWhitelistStatus(
            serviceId,
            user,
            msg.sender,
            status,
            indefiniteWhitelistCount
        );
    }

    
    /// account that no longer has the indefinite whitelister role
    
    
    
    function revokeIndefiniteWhitelistStatus(
        bytes32 serviceId,
        address user,
        address setter
    ) external override {
        require(
            !hasIndefiniteWhitelisterRoleOrIsManager(setter),
            "setter can set indefinite status"
        );
        (
            bool revoked,
            uint192 indefiniteWhitelistCount
        ) = _revokeIndefiniteWhitelistStatus(serviceId, user, setter);
        if (revoked) {
            emit RevokedIndefiniteWhitelistStatus(
                serviceId,
                user,
                setter,
                msg.sender,
                indefiniteWhitelistCount
            );
        }
    }
}

// 
pragma solidity ^0.8.0;





/// requests and receive fulfillments
contract AirnodeRequester is IAirnodeRequester {
    
    address public immutable override airnodeProtocol;

    
    /// this modifier with methods that are meant to receive RRP fulfillments.
    modifier onlyAirnodeProtocol() {
        require(
            msg.sender == address(airnodeProtocol),
            "Sender not Airnode protocol"
        );
        _;
    }

    
    /// methods that are meant to receive RRP and PSP fulfillments.
    
    modifier onlyValidTimestamp(uint256 timestamp) {
        require(timestampIsValid(timestamp), "Timestamp not valid");
        _;
    }

    
    constructor(address _airnodeProtocol) {
        require(_airnodeProtocol != address(0), "AirnodeProtocol address zero");
        airnodeProtocol = _airnodeProtocol;
    }

    
    
    /// prevent replays. Returns `false` if the timestamp is not from the past,
    /// with some leeway to accomodate for some benign time drift. These values
    /// are appropriate in most cases, but you can adjust them if you are aware
    /// of the implications.
    
    function timestampIsValid(uint256 timestamp) internal view returns (bool) {
        return
            timestamp + 1 hours > block.timestamp &&
            timestamp < block.timestamp + 15 minutes;
    }
}

// 
pragma solidity ^0.8.0;





/// of an array

/// argument will be modified.
contract Median is Sort, Quickselect {
    
    
    /// quickselect for longer arrays for gas cost efficiency
    
    
    function median(int256[] memory array) internal pure returns (int256) {
        uint256 arrayLength = array.length;
        if (arrayLength <= MAX_SORT_LENGTH) {
            sort(array);
            if (arrayLength % 2 == 1) {
                return array[arrayLength / 2];
            } else {
                return
                    (array[arrayLength / 2 - 1] + array[arrayLength / 2]) / 2;
            }
        } else {
            if (arrayLength % 2 == 1) {
                return array[quickselectK(array, arrayLength / 2)];
            } else {
                (uint256 mid1, uint256 mid2) = quickselectKPlusOne(
                    array,
                    arrayLength / 2 - 1
                );
                return (array[mid1] + array[mid2]) / 2;
            }
        }
    }
}

// 
pragma solidity ^0.8.0;



interface IDapiServer is IAirnodeRequester {
    event SetRrpBeaconUpdatePermissionStatus(
        address indexed sponsor,
        address indexed rrpBeaconUpdateRequester,
        bool status
    );

    event RequestedRrpBeaconUpdate(
        bytes32 indexed beaconId,
        address indexed sponsor,
        address indexed requester,
        bytes32 requestId,
        address airnode,
        bytes32 templateId
    );

    event RequestedRrpBeaconUpdateRelayed(
        bytes32 indexed beaconId,
        address indexed sponsor,
        address indexed requester,
        bytes32 requestId,
        address airnode,
        address relayer,
        bytes32 templateId
    );

    event UpdatedBeaconWithRrp(
        bytes32 indexed beaconId,
        bytes32 requestId,
        int256 value,
        uint256 timestamp
    );

    event RegisteredBeaconUpdateSubscription(
        bytes32 indexed subscriptionId,
        address airnode,
        bytes32 templateId,
        bytes parameters,
        bytes conditions,
        address relayer,
        address sponsor,
        address requester,
        bytes4 fulfillFunctionId
    );

    event UpdatedBeaconWithPsp(
        bytes32 indexed beaconId,
        bytes32 subscriptionId,
        int224 value,
        uint32 timestamp
    );

    event UpdatedBeaconWithSignedData(
        bytes32 indexed beaconId,
        int256 value,
        uint256 timestamp
    );

    event UpdatedBeaconSetWithBeacons(
        bytes32 indexed beaconSetId,
        int224 value,
        uint32 timestamp
    );

    event UpdatedBeaconSetWithSignedData(
        bytes32 indexed dapiId,
        int224 value,
        uint32 timestamp
    );

    event AddedUnlimitedReader(address indexed unlimitedReader);

    event SetDapiName(
        bytes32 indexed dapiName,
        bytes32 dataFeedId,
        address indexed sender
    );

    function setRrpBeaconUpdatePermissionStatus(
        address rrpBeaconUpdateRequester,
        bool status
    ) external;

    function requestRrpBeaconUpdate(
        address airnode,
        bytes32 templateId,
        address sponsor
    ) external returns (bytes32 requestId);

    function requestRrpBeaconUpdateRelayed(
        address airnode,
        bytes32 templateId,
        address relayer,
        address sponsor
    ) external returns (bytes32 requestId);

    function fulfillRrpBeaconUpdate(
        bytes32 requestId,
        uint256 timestamp,
        bytes calldata data
    ) external;

    function registerBeaconUpdateSubscription(
        address airnode,
        bytes32 templateId,
        bytes memory conditions,
        address relayer,
        address sponsor
    ) external returns (bytes32 subscriptionId);

    function conditionPspBeaconUpdate(
        bytes32 subscriptionId,
        bytes calldata data,
        bytes calldata conditionParameters
    ) external view returns (bool);

    function fulfillPspBeaconUpdate(
        bytes32 subscriptionId,
        address airnode,
        address relayer,
        address sponsor,
        uint256 timestamp,
        bytes calldata data,
        bytes calldata signature
    ) external;

    function updateBeaconWithSignedData(
        address airnode,
        bytes32 beaconId,
        uint256 timestamp,
        bytes calldata data,
        bytes calldata signature
    ) external;

    function updateBeaconSetWithBeacons(bytes32[] memory beaconIds)
        external
        returns (bytes32 beaconSetId);

    function updateBeaconSetWithBeaconsAndReturnCondition(
        bytes32[] memory beaconIds,
        uint256 updateThresholdInPercentage
    ) external returns (bool);

    function conditionPspBeaconSetUpdate(
        bytes32 subscriptionId,
        bytes calldata data,
        bytes calldata conditionParameters
    ) external returns (bool);

    function fulfillPspBeaconSetUpdate(
        bytes32 subscriptionId,
        address airnode,
        address relayer,
        address sponsor,
        uint256 timestamp,
        bytes calldata data,
        bytes calldata signature
    ) external;

    function updateBeaconSetWithSignedData(
        address[] memory airnodes,
        bytes32[] memory templateIds,
        uint256[] memory timestamps,
        bytes[] memory data,
        bytes[] memory signatures
    ) external returns (bytes32 beaconSetId);

    function addUnlimitedReader(address unlimitedReader) external;

    function setDapiName(bytes32 dapiName, bytes32 dataFeedId) external;

    function dapiNameToDataFeedId(bytes32 dapiName)
        external
        view
        returns (bytes32);

    function readDataFeedWithId(bytes32 dataFeedId)
        external
        view
        returns (int224 value, uint32 timestamp);

    function readDataFeedValueWithId(bytes32 dataFeedId)
        external
        view
        returns (int224 value);

    function readDataFeedWithDapiName(bytes32 dapiName)
        external
        view
        returns (int224 value, uint32 timestamp);

    function readDataFeedValueWithDapiName(bytes32 dapiName)
        external
        view
        returns (int224 value);

    function readerCanReadDataFeed(bytes32 dataFeedId, address reader)
        external
        view
        returns (bool);

    function dataFeedIdToReaderToWhitelistStatus(
        bytes32 dataFeedId,
        address reader
    )
        external
        view
        returns (uint64 expirationTimestamp, uint192 indefiniteWhitelistCount);

    function dataFeedIdToReaderToSetterToIndefiniteWhitelistStatus(
        bytes32 dataFeedId,
        address reader,
        address setter
    ) external view returns (bool indefiniteWhitelistStatus);

    function deriveBeaconId(address airnode, bytes32 templateId)
        external
        pure
        returns (bytes32 beaconId);

    function deriveBeaconSetId(bytes32[] memory beaconIds)
        external
        pure
        returns (bytes32 beaconSetId);

    // solhint-disable-next-line func-name-mixedcase
    function DAPI_NAME_SETTER_ROLE_DESCRIPTION()
        external
        view
        returns (string memory);

    // solhint-disable-next-line func-name-mixedcase
    function HUNDRED_PERCENT() external view returns (uint256);

    function dapiNameSetterRole() external view returns (bytes32);

    function sponsorToRrpBeaconUpdateRequesterToPermissionStatus(
        address sponsor,
        address updateRequester
    ) external view returns (bool);

    function subscriptionIdToBeaconId(bytes32 subscriptionId)
        external
        view
        returns (bytes32);
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
pragma solidity ^0.8.0;

interface IStorageUtils {
    event StoredTemplate(
        bytes32 indexed templateId,
        bytes32 endpointId,
        bytes parameters
    );

    event StoredSubscription(
        bytes32 indexed subscriptionId,
        uint256 chainId,
        address airnode,
        bytes32 templateId,
        bytes parameters,
        bytes conditions,
        address relayer,
        address sponsor,
        address requester,
        bytes4 fulfillFunctionId
    );

    function storeTemplate(bytes32 endpointId, bytes calldata parameters)
        external
        returns (bytes32 templateId);

    function storeSubscription(
        uint256 chainId,
        address airnode,
        bytes32 templateId,
        bytes calldata parameters,
        bytes calldata conditions,
        address relayer,
        address sponsor,
        address requester,
        bytes4 fulfillFunctionId
    ) external returns (bytes32 subscriptionId);

    // solhint-disable-next-line func-name-mixedcase
    function MAXIMUM_PARAMETER_LENGTH() external view returns (uint256);

    function templates(bytes32 templateId)
        external
        view
        returns (bytes32 endpointId, bytes memory parameters);

    function subscriptions(bytes32 subscriptionId)
        external
        view
        returns (
            uint256 chainId,
            address airnode,
            bytes32 templateId,
            bytes memory parameters,
            bytes memory conditions,
            address relayer,
            address sponsor,
            address requester,
            bytes4 fulfillFunctionId
        );
}

// 
pragma solidity ^0.8.0;

interface ISponsorshipUtils {
    event SetRrpSponsorshipStatus(
        address indexed sponsor,
        address indexed requester,
        bool status
    );

    event SetPspSponsorshipStatus(
        address indexed sponsor,
        bytes32 indexed subscriptionId,
        bool status
    );

    function setRrpSponsorshipStatus(address requester, bool status) external;

    function setPspSponsorshipStatus(bytes32 subscriptionId, bool status)
        external;

    function sponsorToRequesterToRrpSponsorshipStatus(
        address sponsor,
        address requester
    ) external view returns (bool status);

    function sponsorToSubscriptionIdToPspSponsorshipStatus(
        address sponsor,
        bytes32 subscriptionId
    ) external view returns (bool status);
}

// 
pragma solidity ^0.8.0;

interface IWithdrawalUtils {
    event RequestedWithdrawal(
        address indexed airnodeOrRelayer,
        address indexed sponsor,
        bytes32 indexed withdrawalRequestId,
        uint256 protocolId
    );

    event FulfilledWithdrawal(
        address indexed airnodeOrRelayer,
        address indexed sponsor,
        bytes32 indexed withdrawalRequestId,
        uint256 protocolId,
        address sponsorWallet,
        uint256 amount
    );

    event ClaimedBalance(address indexed sponsor, uint256 amount);

    function requestWithdrawal(address airnodeOrRelayer, uint256 protocolId)
        external;

    function fulfillWithdrawal(
        bytes32 withdrawalRequestId,
        address airnodeOrRelayer,
        uint256 protocolId,
        address sponsor,
        uint256 timestamp,
        bytes calldata signature
    ) external payable;

    function claimBalance() external;

    function withdrawalRequestIsAwaitingFulfillment(bytes32 withdrawalRequestId)
        external
        view
        returns (bool);

    function sponsorToBalance(address sponsor) external view returns (uint256);

    function sponsorToWithdrawalRequestCount(address sponsor)
        external
        view
        returns (uint256);
}
// 
pragma solidity 0.8.9;









/// Airnode protocol

/// from an Airnode address and a template ID. This is suitable where the more
/// recent data point is always more favorable, e.g., in the context of an
/// asset price data feed. Beacons can also be seen as one-Airnode data feeds
/// that can be used individually or combined to build Beacon sets. dAPIs are
/// an abstraction layer over Beacons and Beacon sets.

/// implemented as a central contract, PSP implementation is built into the
/// requester for optimization. Accordingly, the checks that are not required
/// are omitted. Some examples:
/// - While executing a PSP Beacon update, the condition is not verified
/// because Beacon updates where the condition returns `false` (i.e., the
/// on-chain value is already close to the actual value) are not harmful, and
/// are even desirable.
/// - PSP Beacon set update subscription IDs are not verified, as the
/// Airnode/relayer cannot be made to "misreport a Beacon set update" by
/// spoofing a subscription ID.
/// - While executing a PSP Beacon set update, even the signature is not
/// checked because this is a purely keeper job that does not require off-chain
/// data. Similar to Beacon updates, any Beacon set update is welcome.
contract DapiServer is
    ExtendedMulticall,
    WhitelistWithManager,
    AirnodeRequester,
    Median,
    IDapiServer
{
    using ECDSA for bytes32;

    // Airnodes serve their fulfillment data along with timestamps. This
    // contract casts the reported data to `int224` and the timestamp to
    // `uint32`, which works until year 2106.
    struct DataFeed {
        int224 value;
        uint32 timestamp;
    }

    
    string public constant override DAPI_NAME_SETTER_ROLE_DESCRIPTION =
        "dAPI name setter";

    
    
    /// `calculateUpdateInPercentage()`. Since the reported data needs to fit
    /// into 224 bits, its multiplication by 10^8 is guaranteed not to
    /// overflow.
    uint256 public constant override HUNDRED_PERCENT = 1e8;

    
    bytes32 public immutable override dapiNameSetterRole;

    
    mapping(address => bool) public unlimitedReaderStatus;

    
    /// updates at this contract
    mapping(address => mapping(address => bool))
        public
        override sponsorToRrpBeaconUpdateRequesterToPermissionStatus;

    
    mapping(bytes32 => bytes32) public override subscriptionIdToBeaconId;

    mapping(bytes32 => DataFeed) private dataFeeds;

    mapping(bytes32 => bytes32) private requestIdToBeaconId;

    mapping(bytes32 => bytes32) private subscriptionIdToHash;

    mapping(bytes32 => bytes32) private dapiNameHashToDataFeedId;

    
    /// update with the sponsor and is not the sponsor
    
    modifier onlyPermittedUpdateRequester(address sponsor) {
        require(
            sponsor == msg.sender ||
                sponsorToRrpBeaconUpdateRequesterToPermissionStatus[sponsor][
                    msg.sender
                ],
            "Sender not permitted"
        );
        _;
    }

    
    
    
    
    constructor(
        address _accessControlRegistry,
        string memory _adminRoleDescription,
        address _manager,
        address _airnodeProtocol
    )
        WhitelistWithManager(
            _accessControlRegistry,
            _adminRoleDescription,
            _manager
        )
        AirnodeRequester(_airnodeProtocol)
    {
        dapiNameSetterRole = _deriveRole(
            _deriveAdminRole(manager),
            keccak256(abi.encodePacked(DAPI_NAME_SETTER_ROLE_DESCRIPTION))
        );
    }

    ///                     ~~~RRP Beacon updates~~~

    
    /// status of an account
    
    /// address
    
    function setRrpBeaconUpdatePermissionStatus(
        address rrpBeaconUpdateRequester,
        bool status
    ) external override {
        require(
            rrpBeaconUpdateRequester != address(0),
            "Update requester zero"
        );
        sponsorToRrpBeaconUpdateRequesterToPermissionStatus[msg.sender][
            rrpBeaconUpdateRequester
        ] = status;
        emit SetRrpBeaconUpdatePermissionStatus(
            msg.sender,
            rrpBeaconUpdateRequester,
            status
        );
    }

    
    
    /// `setRrpSponsorshipStatus()`), the sponsor must also give update request
    /// permission to the sender (by calling
    /// `setRrpBeaconUpdatePermissionStatus()`) before this method is called.
    /// The template must specify a single point of data of type `int256` to be
    /// returned and for it to be small enough to be castable to `int224`
    /// because this is what `fulfillRrpBeaconUpdate()` expects.
    
    
    
    
    function requestRrpBeaconUpdate(
        address airnode,
        bytes32 templateId,
        address sponsor
    )
        external
        override
        onlyPermittedUpdateRequester(sponsor)
        returns (bytes32 requestId)
    {
        bytes32 beaconId = deriveBeaconId(airnode, templateId);
        requestId = IAirnodeProtocol(airnodeProtocol).makeRequest(
            airnode,
            templateId,
            "",
            sponsor,
            this.fulfillRrpBeaconUpdate.selector
        );
        requestIdToBeaconId[requestId] = beaconId;
        emit RequestedRrpBeaconUpdate(
            beaconId,
            sponsor,
            msg.sender,
            requestId,
            airnode,
            templateId
        );
    }

    
    
    
    
    
    
    function requestRrpBeaconUpdateRelayed(
        address airnode,
        bytes32 templateId,
        address relayer,
        address sponsor
    )
        external
        override
        onlyPermittedUpdateRequester(sponsor)
        returns (bytes32 requestId)
    {
        bytes32 beaconId = deriveBeaconId(airnode, templateId);
        requestId = IAirnodeProtocol(airnodeProtocol).makeRequestRelayed(
            airnode,
            templateId,
            "",
            relayer,
            sponsor,
            this.fulfillRrpBeaconUpdate.selector
        );
        requestIdToBeaconId[requestId] = beaconId;
        emit RequestedRrpBeaconUpdateRelayed(
            beaconId,
            sponsor,
            msg.sender,
            requestId,
            airnode,
            relayer,
            templateId
        );
    }

    
    /// AirnodeProtocol to fulfill the request
    
    
    
    function fulfillRrpBeaconUpdate(
        bytes32 requestId,
        uint256 timestamp,
        bytes calldata data
    ) external override onlyAirnodeProtocol onlyValidTimestamp(timestamp) {
        bytes32 beaconId = requestIdToBeaconId[requestId];
        delete requestIdToBeaconId[requestId];
        int256 decodedData = processBeaconUpdate(beaconId, timestamp, data);
        emit UpdatedBeaconWithRrp(beaconId, requestId, decodedData, timestamp);
    }

    ///                     ~~~PSP Beacon updates~~~

    
    
    /// this contract to recognize the incoming RRP fulfillment, this needs to
    /// be called before the subscription fulfillments.
    /// In addition to the subscription being registered, the sponsor must use
    /// `setPspSponsorshipStatus()` to give permission for its sponsor wallet
    /// to be used for the specific subscription.
    
    
    
    /// to be fulfilled
    
    
    
    function registerBeaconUpdateSubscription(
        address airnode,
        bytes32 templateId,
        bytes memory conditions,
        address relayer,
        address sponsor
    ) external override returns (bytes32 subscriptionId) {
        require(relayer != address(0), "Relayer address zero");
        require(sponsor != address(0), "Sponsor address zero");
        subscriptionId = keccak256(
            abi.encode(
                block.chainid,
                airnode,
                templateId,
                "",
                conditions,
                relayer,
                sponsor,
                address(this),
                this.fulfillPspBeaconUpdate.selector
            )
        );
        subscriptionIdToHash[subscriptionId] = keccak256(
            abi.encodePacked(airnode, relayer, sponsor)
        );
        subscriptionIdToBeaconId[subscriptionId] = deriveBeaconId(
            airnode,
            templateId
        );
        emit RegisteredBeaconUpdateSubscription(
            subscriptionId,
            airnode,
            templateId,
            "",
            conditions,
            relayer,
            sponsor,
            address(this),
            this.fulfillPspBeaconUpdate.selector
        );
    }

    
    /// the fulfillment data and the condition parameters
    
    /// this method can be used to indirectly read a Beacon.
    /// `conditionParameters` are specified within the `conditions` field of a
    /// Subscription.
    
    
    
    /// `uint256` encoded in contract ABI)
    
    function conditionPspBeaconUpdate(
        bytes32 subscriptionId,
        bytes calldata data,
        bytes calldata conditionParameters
    ) external view override returns (bool) {
        require(msg.sender == address(0), "Sender not zero address");
        bytes32 beaconId = subscriptionIdToBeaconId[subscriptionId];
        require(beaconId != bytes32(0), "Subscription not registered");
        DataFeed storage beacon = dataFeeds[beaconId];
        return
            calculateUpdateInPercentage(
                beacon.value,
                decodeFulfillmentData(data)
            ) >=
            decodeConditionParameters(conditionParameters) ||
            beacon.timestamp == 0;
    }

    
    /// fulfill the Beacon update subscription
    
    /// returns `true` because any Beacon update is a good Beacon update
    
    
    
    
    
    
    /// ABI)
    
    /// (and fulfillment data if the relayer is not the Airnode) signed by the
    /// Airnode wallet
    function fulfillPspBeaconUpdate(
        bytes32 subscriptionId,
        address airnode,
        address relayer,
        address sponsor,
        uint256 timestamp,
        bytes calldata data,
        bytes calldata signature
    ) external override onlyValidTimestamp(timestamp) {
        require(
            subscriptionIdToHash[subscriptionId] ==
                keccak256(abi.encodePacked(airnode, relayer, sponsor)),
            "Subscription not registered"
        );
        if (airnode == relayer) {
            require(
                (
                    keccak256(
                        abi.encodePacked(subscriptionId, timestamp, msg.sender)
                    ).toEthSignedMessageHash()
                ).recover(signature) == airnode,
                "Signature mismatch"
            );
        } else {
            require(
                (
                    keccak256(
                        abi.encodePacked(
                            subscriptionId,
                            timestamp,
                            msg.sender,
                            data
                        )
                    ).toEthSignedMessageHash()
                ).recover(signature) == airnode,
                "Signature mismatch"
            );
        }
        bytes32 beaconId = subscriptionIdToBeaconId[subscriptionId];
        // Beacon ID is guaranteed to not be zero because the subscription is
        // registered
        int256 decodedData = processBeaconUpdate(beaconId, timestamp, data);
        emit UpdatedBeaconWithPsp(
            beaconId,
            subscriptionId,
            int224(decodedData),
            uint32(timestamp)
        );
    }

    ///                     ~~~Signed data Beacon updates~~~

    
    /// without requiring a request or subscription
    
    
    
    
    
    /// by the Airnode address
    function updateBeaconWithSignedData(
        address airnode,
        bytes32 templateId,
        uint256 timestamp,
        bytes calldata data,
        bytes calldata signature
    ) external override onlyValidTimestamp(timestamp) {
        require(
            (
                keccak256(abi.encodePacked(templateId, timestamp, data))
                    .toEthSignedMessageHash()
            ).recover(signature) == airnode,
            "Signature mismatch"
        );
        bytes32 beaconId = deriveBeaconId(airnode, templateId);
        int256 decodedData = processBeaconUpdate(beaconId, timestamp, data);
        emit UpdatedBeaconWithSignedData(beaconId, decodedData, timestamp);
    }

    ///                     ~~~PSP Beacon set updates~~~

    
    
    /// to Beacon sets rather than Beacons. However, this is not the intended
    /// use.
    
    
    function updateBeaconSetWithBeacons(bytes32[] memory beaconIds)
        public
        override
        returns (bytes32 beaconSetId)
    {
        uint256 beaconCount = beaconIds.length;
        require(beaconCount > 1, "Specified less than two Beacons");
        int256[] memory values = new int256[](beaconCount);
        uint256 accumulatedTimestamp = 0;
        for (uint256 ind = 0; ind < beaconCount; ind++) {
            DataFeed storage dataFeed = dataFeeds[beaconIds[ind]];
            values[ind] = dataFeed.value;
            accumulatedTimestamp += dataFeed.timestamp;
        }
        uint32 updatedTimestamp = uint32(accumulatedTimestamp / beaconCount);
        beaconSetId = deriveBeaconSetId(beaconIds);
        require(
            updatedTimestamp >= dataFeeds[beaconSetId].timestamp,
            "Updated value outdated"
        );
        int224 updatedValue = int224(median(values));
        dataFeeds[beaconSetId] = DataFeed({
            value: updatedValue,
            timestamp: updatedTimestamp
        });
        emit UpdatedBeaconSetWithBeacons(
            beaconSetId,
            updatedValue,
            updatedTimestamp
        );
    }

    
    /// and returns if this update was justified according to the deviation
    /// threshold
    
    /// set, which is why it does not require the sender to be a void signer
    /// with zero address. This allows the implementation of incentive
    /// mechanisms that rewards keepers that trigger valid dAPI updates.
    
    
    /// where 100% is represented as `HUNDRED_PERCENT`
    function updateBeaconSetWithBeaconsAndReturnCondition(
        bytes32[] memory beaconIds,
        uint256 deviationThresholdInPercentage
    ) public override returns (bool) {
        bytes32 beaconSetId = deriveBeaconSetId(beaconIds);
        DataFeed memory initialBeaconSet = dataFeeds[beaconSetId];
        updateBeaconSetWithBeacons(beaconIds);
        DataFeed storage updatedBeaconSet = dataFeeds[beaconSetId];
        return
            calculateUpdateInPercentage(
                initialBeaconSet.value,
                updatedBeaconSet.value
            ) >=
            deviationThresholdInPercentage ||
            (initialBeaconSet.timestamp == 0 && updatedBeaconSet.timestamp > 0);
    }

    
    /// on the condition parameters
    
    /// be zero, which means the `parameters` field of the Subscription will be
    /// forwarded to this function as `data`. This field should be the Beacon
    /// ID array encoded in contract ABI.
    
    
    /// encoded in contract ABI)
    
    /// `uint256` encoded in contract ABI)
    
    function conditionPspBeaconSetUpdate(
        bytes32 subscriptionId, // solhint-disable-line no-unused-vars
        bytes calldata data,
        bytes calldata conditionParameters
    ) external override returns (bool) {
        require(msg.sender == address(0), "Sender not zero address");
        bytes32[] memory beaconIds = abi.decode(data, (bytes32[]));
        require(
            keccak256(abi.encode(beaconIds)) == keccak256(data),
            "Data length not correct"
        );
        return
            updateBeaconSetWithBeaconsAndReturnCondition(
                beaconIds,
                decodeConditionParameters(conditionParameters)
            );
    }

    
    /// fulfill the Beacon set update subscription
    
    /// Subscription is zero, its `parameters` field will be forwarded to
    /// `data` here, which is expect to be contract ABI-encoded array of Beacon
    /// IDs.
    /// It does not make sense for this subscription to be relayed, as there is
    /// no external data being delivered. Nevertheless, this is allowed for the
    /// lack of a reason to prevent it.
    /// Even though the consistency of the arguments are not being checked, if
    /// a standard implementation of Airnode is being used, these can be
    /// expected to be correct. Either way, the assumption is that it does not
    /// matter for the purposes of a Beacon set update subscription.
    
    
    
    
    
    
    
    /// (and fulfillment data if the relayer is not the Airnode) signed by the
    /// Airnode wallet
    function fulfillPspBeaconSetUpdate(
        bytes32 subscriptionId, // solhint-disable-line no-unused-vars
        address airnode, // solhint-disable-line no-unused-vars
        address relayer, // solhint-disable-line no-unused-vars
        address sponsor, // solhint-disable-line no-unused-vars
        uint256 timestamp, // solhint-disable-line no-unused-vars
        bytes calldata data,
        bytes calldata signature // solhint-disable-line no-unused-vars
    ) external override {
        require(
            keccak256(data) ==
                updateBeaconSetWithBeacons(abi.decode(data, (bytes32[]))),
            "Data length not correct"
        );
    }

    ///                     ~~~Signed data Beacon set updates~~~

    
    /// Airnodes without requiring a request or subscription. The Beacons for
    /// which the signature is omitted will be read from the storage.
    
    
    
    
    /// Beacon)
    
    /// by the respective Airnode address per Beacon
    
    function updateBeaconSetWithSignedData(
        address[] memory airnodes,
        bytes32[] memory templateIds,
        uint256[] memory timestamps,
        bytes[] memory data,
        bytes[] memory signatures
    ) external override returns (bytes32 beaconSetId) {
        uint256 beaconCount = airnodes.length;
        require(
            beaconCount == templateIds.length &&
                beaconCount == timestamps.length &&
                beaconCount == data.length &&
                beaconCount == signatures.length,
            "Parameter length mismatch"
        );
        require(beaconCount > 1, "Specified less than two Beacons");
        bytes32[] memory beaconIds = new bytes32[](beaconCount);
        int256[] memory values = new int256[](beaconCount);
        uint256 accumulatedTimestamp = 0;
        for (uint256 ind = 0; ind < beaconCount; ind++) {
            if (signatures[ind].length != 0) {
                address airnode = airnodes[ind];
                uint256 timestamp = timestamps[ind];
                require(timestampIsValid(timestamp), "Timestamp not valid");
                require(
                    (
                        keccak256(
                            abi.encodePacked(
                                templateIds[ind],
                                timestamp,
                                data[ind]
                            )
                        ).toEthSignedMessageHash()
                    ).recover(signatures[ind]) == airnode,
                    "Signature mismatch"
                );
                values[ind] = decodeFulfillmentData(data[ind]);
                // Timestamp validity is already checked, which means it will
                // be small enough to be typecast into `uint32`
                accumulatedTimestamp += timestamp;
                beaconIds[ind] = deriveBeaconId(airnode, templateIds[ind]);
            } else {
                bytes32 beaconId = deriveBeaconId(
                    airnodes[ind],
                    templateIds[ind]
                );
                DataFeed storage dataFeed = dataFeeds[beaconId];
                values[ind] = dataFeed.value;
                accumulatedTimestamp += dataFeed.timestamp;
                beaconIds[ind] = beaconId;
            }
        }
        beaconSetId = deriveBeaconSetId(beaconIds);
        uint32 updatedTimestamp = uint32(accumulatedTimestamp / beaconCount);
        require(
            updatedTimestamp >= dataFeeds[beaconSetId].timestamp,
            "Updated value outdated"
        );
        int224 updatedValue = int224(median(values));
        dataFeeds[beaconSetId] = DataFeed({
            value: updatedValue,
            timestamp: updatedTimestamp
        });
        emit UpdatedBeaconSetWithSignedData(
            beaconSetId,
            updatedValue,
            updatedTimestamp
        );
    }

    
    
    /// contracts that are adequately restricted should be given this status
    
    function addUnlimitedReader(address unlimitedReader) external override {
        require(msg.sender == manager, "Sender not manager");
        unlimitedReaderStatus[unlimitedReader] = true;
        emit AddedUnlimitedReader(unlimitedReader);
    }

    
    
    /// dAPI names provide a more abstract interface for convenience. This
    /// means a dAPI name that was pointing to a Beacon can be pointed to a
    /// Beacon set, then another Beacon set, etc.
    
    
    function setDapiName(bytes32 dapiName, bytes32 dataFeedId)
        external
        override
    {
        require(dapiName != bytes32(0), "dAPI name zero");
        require(
            msg.sender == manager ||
                IAccessControlRegistry(accessControlRegistry).hasRole(
                    dapiNameSetterRole,
                    msg.sender
                ),
            "Sender cannot set dAPI name"
        );
        dapiNameHashToDataFeedId[
            keccak256(abi.encodePacked(dapiName))
        ] = dataFeedId;
        emit SetDapiName(dapiName, dataFeedId, msg.sender);
    }

    
    
    
    function dapiNameToDataFeedId(bytes32 dapiName)
        external
        view
        override
        returns (bytes32)
    {
        return dapiNameHashToDataFeedId[keccak256(abi.encodePacked(dapiName))];
    }

    
    
    
    
    function readDataFeedWithId(bytes32 dataFeedId)
        external
        view
        override
        returns (int224 value, uint32 timestamp)
    {
        require(
            readerCanReadDataFeed(dataFeedId, msg.sender),
            "Sender cannot read"
        );
        DataFeed storage dataFeed = dataFeeds[dataFeedId];
        return (dataFeed.value, dataFeed.timestamp);
    }

    
    
    
    function readDataFeedValueWithId(bytes32 dataFeedId)
        external
        view
        override
        returns (int224 value)
    {
        require(
            readerCanReadDataFeed(dataFeedId, msg.sender),
            "Sender cannot read"
        );
        DataFeed storage dataFeed = dataFeeds[dataFeedId];
        require(dataFeed.timestamp != 0, "Data feed does not exist");
        return dataFeed.value;
    }

    
    
    /// must be whitelisted for the hash of the dAPI name.
    
    
    
    function readDataFeedWithDapiName(bytes32 dapiName)
        external
        view
        override
        returns (int224 value, uint32 timestamp)
    {
        bytes32 dapiNameHash = keccak256(abi.encodePacked(dapiName));
        require(
            readerCanReadDataFeed(dapiNameHash, msg.sender),
            "Sender cannot read"
        );
        bytes32 dataFeedId = dapiNameHashToDataFeedId[dapiNameHash];
        require(dataFeedId != bytes32(0), "dAPI name not set");
        DataFeed storage dataFeed = dataFeeds[dataFeedId];
        return (dataFeed.value, dataFeed.timestamp);
    }

    
    
    
    function readDataFeedValueWithDapiName(bytes32 dapiName)
        external
        view
        override
        returns (int224 value)
    {
        bytes32 dapiNameHash = keccak256(abi.encodePacked(dapiName));
        require(
            readerCanReadDataFeed(dapiNameHash, msg.sender),
            "Sender cannot read"
        );
        DataFeed storage dataFeed = dataFeeds[
            dapiNameHashToDataFeedId[dapiNameHash]
        ];
        require(dataFeed.timestamp != 0, "Data feed does not exist");
        return dataFeed.value;
    }

    
    
    
    
    function readerCanReadDataFeed(bytes32 dataFeedId, address reader)
        public
        view
        override
        returns (bool)
    {
        return
            reader == address(0) ||
            userIsWhitelisted(dataFeedId, reader) ||
            unlimitedReaderStatus[reader];
    }

    
    /// data feed
    
    
    
    /// reader will expire
    
    /// whitelisted indefinitely for `dataFeedId`
    function dataFeedIdToReaderToWhitelistStatus(
        bytes32 dataFeedId,
        address reader
    )
        external
        view
        override
        returns (uint64 expirationTimestamp, uint192 indefiniteWhitelistCount)
    {
        WhitelistStatus
            storage whitelistStatus = serviceIdToUserToWhitelistStatus[
                dataFeedId
            ][reader];
        expirationTimestamp = whitelistStatus.expirationTimestamp;
        indefiniteWhitelistCount = whitelistStatus.indefiniteWhitelistCount;
    }

    
    /// for the data feed
    
    
    
    /// the reader for the data feed indefinitely
    
    /// whitelisted reader for the data feed
    function dataFeedIdToReaderToSetterToIndefiniteWhitelistStatus(
        bytes32 dataFeedId,
        address reader,
        address setter
    ) external view override returns (bool indefiniteWhitelistStatus) {
        indefiniteWhitelistStatus = serviceIdToUserToSetterToIndefiniteWhitelistStatus[
            dataFeedId
        ][reader][setter];
    }

    
    
    
    
    function deriveBeaconId(address airnode, bytes32 templateId)
        public
        pure
        override
        returns (bytes32 beaconId)
    {
        require(airnode != address(0), "Airnode address zero");
        require(templateId != bytes32(0), "Template ID zero");
        beaconId = keccak256(abi.encodePacked(airnode, templateId));
    }

    
    
    
    
    function deriveBeaconSetId(bytes32[] memory beaconIds)
        public
        pure
        override
        returns (bytes32 beaconSetId)
    {
        beaconSetId = keccak256(abi.encode(beaconIds));
    }

    
    
    
    
    
    function processBeaconUpdate(
        bytes32 beaconId,
        uint256 timestamp,
        bytes calldata data
    ) private returns (int256 updatedBeaconValue) {
        updatedBeaconValue = decodeFulfillmentData(data);
        require(
            timestamp > dataFeeds[beaconId].timestamp,
            "Fulfillment older than Beacon"
        );
        // Timestamp validity is already checked by `onlyValidTimestamp`, which
        // means it will be small enough to be typecast into `uint32`
        dataFeeds[beaconId] = DataFeed({
            value: int224(updatedBeaconValue),
            timestamp: uint32(timestamp)
        });
    }

    
    
    
    function decodeFulfillmentData(bytes memory data)
        private
        pure
        returns (int224)
    {
        require(data.length == 32, "Data length not correct");
        int256 decodedData = abi.decode(data, (int256));
        require(
            decodedData >= type(int224).min && decodedData <= type(int224).max,
            "Value typecasting error"
        );
        return int224(decodedData);
    }

    
    
    /// contract ABI)
    
    /// percentage where 100% is represented as `HUNDRED_PERCENT`
    function decodeConditionParameters(bytes calldata conditionParameters)
        private
        pure
        returns (uint256 deviationThresholdInPercentage)
    {
        require(conditionParameters.length == 32, "Incorrect parameter length");
        deviationThresholdInPercentage = abi.decode(
            conditionParameters,
            (uint256)
        );
    }

    
    /// percentages where 100% is represented as `HUNDRED_PERCENT`
    
    /// value is almost zero, which may trigger updates more frequently than
    /// wanted. To avoid this, Beacons should be defined in a way that the
    /// expected values are not small numbers floating around zero, i.e.,
    /// offset and scale.
    
    
    
    function calculateUpdateInPercentage(
        int224 initialValue,
        int224 updatedValue
    ) private pure returns (uint256 updateInPercentage) {
        int256 delta = int256(updatedValue) - int256(initialValue);
        uint256 absoluteDelta = delta > 0 ? uint256(delta) : uint256(-delta);
        uint256 absoluteInitialValue = initialValue > 0
            ? uint256(int256(initialValue))
            : uint256(-int256(initialValue));
        // Avoid division by 0
        if (absoluteInitialValue == 0) {
            absoluteInitialValue = 1;
        }
        updateInPercentage =
            (absoluteDelta * HUNDRED_PERCENT) /
            absoluteInitialValue;
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;



/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
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
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

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
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
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
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
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
pragma solidity ^0.8.0;



interface IAccessControlRegistry is IAccessControl {
    event InitializedManager(bytes32 indexed rootRole, address indexed manager);

    event InitializedRole(
        bytes32 indexed role,
        bytes32 indexed adminRole,
        string description,
        address sender
    );

    function initializeManager(address manager) external;

    function initializeRoleAndGrantToSender(
        bytes32 adminRole,
        string calldata description
    ) external returns (bytes32 role);

    function deriveRootRole(address manager)
        external
        pure
        returns (bytes32 rootRole);

    function deriveRole(bytes32 adminRole, string calldata description)
        external
        pure
        returns (bytes32 role);
}

// 
pragma solidity ^0.8.0;





interface IAirnodeProtocol is
    IStorageUtils,
    ISponsorshipUtils,
    IWithdrawalUtils
{
    event MadeRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        address requester,
        uint256 requesterRequestCount,
        bytes32 templateId,
        bytes parameters,
        address sponsor,
        bytes4 fulfillFunctionId
    );

    event FulfilledRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        uint256 timestamp,
        bytes data
    );

    event FailedRequest(
        address indexed airnode,
        bytes32 indexed requestId,
        uint256 timestamp,
        string errorMessage
    );

    event MadeRequestRelayed(
        address indexed relayer,
        bytes32 indexed requestId,
        address indexed airnode,
        address requester,
        uint256 requesterRequestCount,
        bytes32 templateId,
        bytes parameters,
        address sponsor,
        bytes4 fulfillFunctionId
    );

    event FulfilledRequestRelayed(
        address indexed relayer,
        bytes32 indexed requestId,
        address indexed airnode,
        uint256 timestamp,
        bytes data
    );

    event FailedRequestRelayed(
        address indexed relayer,
        bytes32 indexed requestId,
        address indexed airnode,
        uint256 timestamp,
        string errorMessage
    );

    function makeRequest(
        address airnode,
        bytes32 templateId,
        bytes calldata parameters,
        address sponsor,
        bytes4 fulfillFunctionId
    ) external returns (bytes32 requestId);

    function fulfillRequest(
        bytes32 requestId,
        address airnode,
        address requester,
        bytes4 fulfillFunctionId,
        uint256 timestamp,
        bytes calldata data,
        bytes calldata signature
    ) external returns (bool callSuccess, bytes memory callData);

    function failRequest(
        bytes32 requestId,
        address airnode,
        address requester,
        bytes4 fulfillFunctionId,
        uint256 timestamp,
        string calldata errorMessage,
        bytes calldata signature
    ) external;

    function makeRequestRelayed(
        address airnode,
        bytes32 templateId,
        bytes calldata parameters,
        address relayer,
        address sponsor,
        bytes4 fulfillFunctionId
    ) external returns (bytes32 requestId);

    function fulfillRequestRelayed(
        bytes32 requestId,
        address airnode,
        address requester,
        address relayer,
        bytes4 fulfillFunctionId,
        uint256 timestamp,
        bytes calldata data,
        bytes calldata signature
    ) external returns (bool callSuccess, bytes memory callData);

    function failRequestRelayed(
        bytes32 requestId,
        address airnode,
        address requester,
        address relayer,
        bytes4 fulfillFunctionId,
        uint256 timestamp,
        string calldata errorMessage,
        bytes calldata signature
    ) external;

    function requestIsAwaitingFulfillment(bytes32 requestId)
        external
        view
        returns (bool);

    function requesterToRequestCount(address requester)
        external
        view
        returns (uint256);
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