// SPDX-License-Identifier: GPL-2.0-or-later


// 

pragma solidity 0.8.13;

interface IDepositManager {
    
    
    function addVToken(address _vToken) external;

    
    
    function removeVToken(address _vToken) external;

    
    
    function setDepositInterval(uint32 _interval) external;

    
    
    
    function setMaxLoss(uint16 _maxLoss) external;

    
    function updateDeposits() external;

    
    
    function registry() external view returns (address);

    
    
    function maxLossInBP() external view returns (uint16);

    
    
    function depositInterval() external view returns (uint32);

    
    
    
    function lastDepositTimestamp(address _vToken) external view returns (uint96);

    
    
    function canUpdateDeposits() external view returns (bool);

    
    
    
    function containsVToken(address _vToken) external view returns (bool);
}

// 

pragma solidity 0.8.13;








contract DepositManager is IDepositManager {
    using EnumerableSet for EnumerableSet.AddressSet;

    
    uint16 internal constant BP = 10_000;

    
    bytes32 internal immutable RESERVE_MANAGER_ROLE;
    
    address public immutable override registry;

    
    EnumerableSet.AddressSet internal vTokens;

    
    uint32 public override depositInterval;

    
    uint16 public override maxLossInBP;

    
    mapping(address => uint96) public override lastDepositTimestamp;

    
    
    modifier onlyRole(bytes32 _role) {
        require(IAccessControl(registry).hasRole(_role, msg.sender), "DepositManager: FORBIDDEN");
        _;
    }

    
    modifier isValidMaxLoss(uint16 _maxLossInBP) {
        require(_maxLossInBP <= BP, "DepositManager: MAX_LOSS");
        _;
    }

    constructor(
        address _registry,
        uint16 _maxLossInBP,
        uint32 _depositInterval
    ) isValidMaxLoss(_maxLossInBP) {
        RESERVE_MANAGER_ROLE = keccak256("RESERVE_MANAGER_ROLE");

        registry = _registry;
        maxLossInBP = _maxLossInBP;
        depositInterval = _depositInterval;
    }

    
    function addVToken(address _vToken) external override onlyRole(RESERVE_MANAGER_ROLE) {
        require(vTokens.add(_vToken), "DepositManager: EXISTS");
    }

    
    function removeVToken(address _vToken) external override onlyRole(RESERVE_MANAGER_ROLE) {
        require(vTokens.remove(_vToken), "DepositManager: !FOUND");
    }

    
    function setDepositInterval(uint32 _interval) external override onlyRole(RESERVE_MANAGER_ROLE) {
        require(_interval > 0, "DepositManager: INVALID");
        depositInterval = _interval;
    }

    
    function setMaxLoss(uint16 _maxLossInBP) external isValidMaxLoss(_maxLossInBP) onlyRole(RESERVE_MANAGER_ROLE) {
        maxLossInBP = _maxLossInBP;
    }

    
    function canUpdateDeposits() external view override returns (bool) {
        uint count = vTokens.length();
        for (uint i; i < count; ++i) {
            address vToken = vTokens.at(i);
            if (block.timestamp - lastDepositTimestamp[vToken] >= depositInterval) {
                return true;
            }
        }
        return false;
    }

    
    function containsVToken(address _vToken) external view override returns (bool) {
        return vTokens.contains(_vToken);
    }

    
    function updateDeposits() public virtual override {
        bool deposited;
        uint count = vTokens.length();
        for (uint i; i < count; ++i) {
            IvToken vToken = IvToken(vTokens.at(i));
            if (block.timestamp - lastDepositTimestamp[address(vToken)] >= depositInterval) {
                uint _depositedBefore = vToken.deposited();
                uint _totalBefore = vToken.totalAssetSupply();

                vToken.deposit();

                require(
                    _isValidMaxLoss(_depositedBefore, _totalBefore, vToken.totalAssetSupply()),
                    "DepositManager: MAX_LOSS"
                );

                lastDepositTimestamp[address(vToken)] = uint96(block.timestamp);
                deposited = true;
            }
        }

        require(deposited, "DepositManager: !DEPOSITED");
    }

    function _isValidMaxLoss(
        uint _depositedBefore,
        uint _totalBefore,
        uint _totalAfter
    ) internal view returns (bool) {
        if (_totalAfter < _totalBefore) {
            return _totalBefore - _totalAfter <= (_depositedBefore * maxLossInBP) / BP;
        }
        return true;
    }
}
// 

pragma solidity 0.8.13;





contract DepositManagerJob is DepositManager {
    
    address public immutable keep3r;

    constructor(
        address _keep3r,
        address _registry,
        uint16 _maxLossInBP,
        uint32 _depositInterval
    ) DepositManager(_registry, _maxLossInBP, _depositInterval) {
        keep3r = _keep3r;
    }

    
    function updateDeposits() public override {
        require(IKeep3r(keep3r).isKeeper(msg.sender), "DepositManager: !KEEP3R");

        super.updateDeposits();

        IKeep3r(keep3r).worked(msg.sender);
    }
}

// 

pragma solidity >=0.8.13;

interface IKeep3r {
    function isKeeper(address _keeper) external returns (bool _isKeeper);

    function worked(address _keeper) external;
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

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
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

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
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// 

pragma solidity >=0.8.13;



interface IvToken {
    struct AssetData {
        uint maxShares;
        uint amountInAsset;
    }

    event UpdateDeposit(address indexed account, uint depositedAmount);
    event SetVaultController(address vaultController);
    event VTokenTransfer(address indexed from, address indexed to, uint amount);

    
    
    
    function initialize(address _asset, address _registry) external;

    
    
    function setController(address _vaultController) external;

    
    function deposit() external;

    
    function withdraw() external;

    
    
    
    
    function transferFrom(
        address _from,
        address _to,
        uint _shares
    ) external;

    
    
    
    
    function transferAsset(address _recipient, uint _amount) external;

    
    
    function mint() external returns (uint shares);

    
    
    
    function burn(address _recipient) external returns (uint amount);

    
    
    
    function transfer(address _recipient, uint _amount) external;

    
    function sync() external;

    
    
    
    function mintFor(address _recipient) external returns (uint);

    
    
    
    function burnFor(address _recipient) external returns (uint);

    
    
    function virtualTotalAssetSupply() external view returns (uint);

    
    
    function totalAssetSupply() external view returns (uint);

    
    
    function deposited() external view returns (uint);

    
    
    
    function mintableShares(uint _amount) external view returns (uint);

    
    
    function assetDataOf(address _account, uint _shares) external view returns (AssetData memory);

    
    
    
    function assetBalanceForShares(uint _shares) external view returns (uint);

    
    
    
    function assetBalanceOf(address _account) external view returns (uint);

    
    
    
    function lastAssetBalanceOf(address _account) external view returns (uint);

    
    
    function lastAssetBalance() external view returns (uint);

    
    
    function totalSupply() external view returns (uint);

    
    
    
    function balanceOf(address _account) external view returns (uint);

    
    
    
    
    
    function shareChange(address _account, uint _amountInAsset) external view returns (uint newShares, uint oldShares);

    
    
    function vaultController() external view returns (address);

    
    
    function asset() external view returns (address);

    
    
    function registry() external view returns (address);

    
    
    function currentDepositedPercentageInBP() external view returns (uint);
}

// 

pragma solidity >=0.8.13;



interface IVaultController {
    event Deposit(uint amount);
    event Withdraw(uint amount);
    event SetDepositInfo(uint _targetDepositPercentageInBP, uint percentageInBPPerStep, uint stepDuration);

    
    
    
    
    function setDepositInfo(
        uint16 _targetDepositPercentageInBP,
        uint16 _percentageInBPPerStep,
        uint32 _stepDuration
    ) external;

    
    function deposit() external;

    
    function withdraw() external;

    
    
    function asset() external view returns (address);

    
    
    function vToken() external view returns (address);

    
    
    function registry() external view returns (address);

    
    
    function expectedWithdrawableAmount() external view returns (uint);

    
    
    function targetDepositPercentageInBP() external view returns (uint16);

    
    
    function percentageInBPPerStep() external view returns (uint16);

    
    
    
    ///         Deposited amount is calculated as timeElapsedFromLastDeposit / stepDuration * percentageInBPPerStep
    function stepDuration() external view returns (uint32);

    
    
    
    function calculatedDepositAmount(uint _currentDepositedPercentageInBP) external view returns (uint);
}