// SPDX-License-Identifier: MIT

// 
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// 
pragma solidity 0.8.16;




interface IERC1967Upgrade {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    
    event Upgraded(address impl);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    
    error INVALID_UPGRADE(address impl);

    
    error UNSUPPORTED_UUID();

    
    error ONLY_UUPS();
}

// 
pragma solidity 0.8.16;




interface IInitializable {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    event Initialized(uint256 version);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error ADDRESS_ZERO();

    
    error INITIALIZING();

    
    error NOT_INITIALIZING();

    
    error ALREADY_INITIALIZED();
}

// 
pragma solidity 0.8.16;




interface IOwnable {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    
    
    event OwnerUpdated(address indexed prevOwner, address indexed newOwner);

    
    
    
    event OwnerPending(address indexed owner, address indexed pendingOwner);

    
    
    
    event OwnerCanceled(address indexed owner, address indexed canceledOwner);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error ONLY_OWNER();

    
    error ONLY_PENDING_OWNER();

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    function owner() external view returns (address);

    
    function pendingOwner() external view returns (address);

    
    
    function transferOwnership(address newOwner) external;

    
    
    function safeTransferOwnership(address newOwner) external;

    
    function acceptOwnership() external;

    
    function cancelOwnershipTransfer() external;
}

// 
pragma solidity ^0.8.16;







interface IUUPS is IERC1967Upgrade, IERC1822Proxiable {
    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error ONLY_CALL();

    
    error ONLY_DELEGATECALL();

    
    error ONLY_PROXY();

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    function upgradeTo(address newImpl) external;

    
    
    
    function upgradeToAndCall(address newImpl, bytes memory data) external payable;
}

// 
pragma solidity 0.8.16;




contract TreasuryTypesV1 {
    
    
    
    struct Settings {
        uint128 gracePeriod;
        uint128 delay;
    }
}

// 
pragma solidity 0.8.16;










/// - Uses custom errors declared in IERC1967Upgrade
/// - Removes ERC1967 admin and beacon support
abstract contract ERC1967Upgrade is IERC1967Upgrade {
    ///                                                          ///
    ///                          CONSTANTS                       ///
    ///                                                          ///

    
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    ///                                                          ///
    ///                          FUNCTIONS                       ///
    ///                                                          ///

    
    
    
    function _upgradeToAndCallUUPS(
        address _newImpl,
        bytes memory _data,
        bool _forceCall
    ) internal {
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(_newImpl);
        } else {
            try IERC1822Proxiable(_newImpl).proxiableUUID() returns (bytes32 slot) {
                if (slot != _IMPLEMENTATION_SLOT) revert UNSUPPORTED_UUID();
            } catch {
                revert ONLY_UUPS();
            }

            _upgradeToAndCall(_newImpl, _data, _forceCall);
        }
    }

    
    
    
    function _upgradeToAndCall(
        address _newImpl,
        bytes memory _data,
        bool _forceCall
    ) internal {
        _upgradeTo(_newImpl);

        if (_data.length > 0 || _forceCall) {
            Address.functionDelegateCall(_newImpl, _data);
        }
    }

    
    
    function _upgradeTo(address _newImpl) internal {
        _setImplementation(_newImpl);

        emit Upgraded(_newImpl);
    }

    
    
    function _setImplementation(address _impl) private {
        if (!Address.isContract(_impl)) revert INVALID_UPGRADE(_impl);

        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = _impl;
    }

    
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }
}

// 
pragma solidity 0.8.16;







/// - Uses custom errors declared in IInitializable
abstract contract Initializable is IInitializable {
    ///                                                          ///
    ///                           STORAGE                        ///
    ///                                                          ///

    
    uint8 internal _initialized;

    
    bool internal _initializing;

    ///                                                          ///
    ///                          MODIFIERS                       ///
    ///                                                          ///

    
    modifier onlyInitializing() {
        if (!_initializing) revert NOT_INITIALIZING();
        _;
    }

    
    modifier initializer() {
        bool isTopLevelCall = !_initializing;

        if ((!isTopLevelCall || _initialized != 0) && (Address.isContract(address(this)) || _initialized != 1)) revert ALREADY_INITIALIZED();

        _initialized = 1;

        if (isTopLevelCall) {
            _initializing = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;

            emit Initialized(1);
        }
    }

    
    
    modifier reinitializer(uint8 _version) {
        if (_initializing || _initialized >= _version) revert ALREADY_INITIALIZED();

        _initialized = _version;

        _initializing = true;

        _;

        _initializing = false;

        emit Initialized(_version);
    }

    ///                                                          ///
    ///                          FUNCTIONS                       ///
    ///                                                          ///

    
    function _disableInitializers() internal virtual {
        if (_initializing) revert INITIALIZING();

        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;

            emit Initialized(type(uint8).max);
        }
    }
}

// 
pragma solidity 0.8.16;

abstract contract VersionedContract {
    function contractVersion() external pure returns (string memory) {
        return "1.2.0";
    }
}

// 
pragma solidity 0.8.16;




abstract contract ProposalHasher {
    ///                                                          ///
    ///                         HASH PROPOSAL                    ///
    ///                                                          ///

    
    
    
    
    
    
    function hashProposal(
        address[] memory _targets,
        uint256[] memory _values,
        bytes[] memory _calldatas,
        bytes32 _descriptionHash,
        address _proposer
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_targets, _values, _calldatas, _descriptionHash, _proposer));
    }
}

// 
pragma solidity 0.8.16;







interface ITreasury is IUUPS, IOwnable {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    event TransactionScheduled(bytes32 proposalId, uint256 timestamp);

    
    event TransactionCanceled(bytes32 proposalId);

    
    event TransactionExecuted(bytes32 proposalId, address[] targets, uint256[] values, bytes[] payloads);

    
    event DelayUpdated(uint256 prevDelay, uint256 newDelay);

    
    event GracePeriodUpdated(uint256 prevGracePeriod, uint256 newGracePeriod);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error PROPOSAL_ALREADY_QUEUED();

    
    error PROPOSAL_NOT_QUEUED();

    
    
    error EXECUTION_NOT_READY(bytes32 proposalId);

    
    
    error EXECUTION_FAILED(uint256 txIndex);

    
    error EXECUTION_EXPIRED();

    
    error ONLY_TREASURY();

    
    error ONLY_MANAGER();

    ///                                                          ///
    ///                          FUNCTIONS                       ///
    ///                                                          ///

    
    
    
    function initialize(address governor, uint256 timelockDelay) external;

    
    
    function timestamp(bytes32 proposalId) external view returns (uint256);

    
    
    function isQueued(bytes32 proposalId) external view returns (bool);

    
    
    function isReady(bytes32 proposalId) external view returns (bool);

    
    
    function isExpired(bytes32 proposalId) external view returns (bool);

    
    
    function queue(bytes32 proposalId) external returns (uint256 eta);

    
    
    function cancel(bytes32 proposalId) external;

    
    
    
    
    
    
    function execute(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata calldatas,
        bytes32 descriptionHash,
        address proposer
    ) external payable;

    
    function delay() external view returns (uint256);

    
    function gracePeriod() external view returns (uint256);

    
    
    function updateDelay(uint256 newDelay) external;

    
    
    function updateGracePeriod(uint256 newGracePeriod) external;
}

// 
pragma solidity 0.8.16;






contract TreasuryStorageV1 is TreasuryTypesV1 {
    
    Settings internal settings;

    
    
    mapping(bytes32 => uint256) internal timestamps;
}

// 
pragma solidity 0.8.16;







/// - Uses custom errors declared in IUUPS
/// - Inherits a modern, minimal ERC1967Upgrade
abstract contract UUPS is IUUPS, ERC1967Upgrade {
    ///                                                          ///
    ///                          IMMUTABLES                      ///
    ///                                                          ///

    
    address private immutable __self = address(this);

    ///                                                          ///
    ///                           MODIFIERS                      ///
    ///                                                          ///

    
    modifier onlyProxy() {
        if (address(this) == __self) revert ONLY_DELEGATECALL();
        if (_getImplementation() != __self) revert ONLY_PROXY();
        _;
    }

    
    modifier notDelegated() {
        if (address(this) != __self) revert ONLY_CALL();
        _;
    }

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    function _authorizeUpgrade(address _newImpl) internal virtual;

    
    
    function upgradeTo(address _newImpl) external onlyProxy {
        _authorizeUpgrade(_newImpl);
        _upgradeToAndCallUUPS(_newImpl, "", false);
    }

    
    
    
    function upgradeToAndCall(address _newImpl, bytes memory _data) external payable onlyProxy {
        _authorizeUpgrade(_newImpl);
        _upgradeToAndCallUUPS(_newImpl, _data, true);
    }

    
    function proxiableUUID() external view notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }
}

// 
pragma solidity 0.8.16;







/// - Uses custom errors declared in IOwnable
/// - Adds optional two-step ownership transfer (`safeTransferOwnership` + `acceptOwnership`)
abstract contract Ownable is IOwnable, Initializable {
    ///                                                          ///
    ///                            STORAGE                       ///
    ///                                                          ///

    
    address internal _owner;

    
    address internal _pendingOwner;

    ///                                                          ///
    ///                           MODIFIERS                      ///
    ///                                                          ///

    
    modifier onlyOwner() {
        if (msg.sender != _owner) revert ONLY_OWNER();
        _;
    }

    
    modifier onlyPendingOwner() {
        if (msg.sender != _pendingOwner) revert ONLY_PENDING_OWNER();
        _;
    }

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    function __Ownable_init(address _initialOwner) internal onlyInitializing {
        _owner = _initialOwner;

        emit OwnerUpdated(address(0), _initialOwner);
    }

    
    function owner() public virtual view returns (address) {
        return _owner;
    }

    
    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    
    
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    
    
    
    function _transferOwnership(address _newOwner) internal {
        emit OwnerUpdated(_owner, _newOwner);

        _owner = _newOwner;

        if (_pendingOwner != address(0)) delete _pendingOwner;
    }

    
    
    function safeTransferOwnership(address _newOwner) public onlyOwner {
        _pendingOwner = _newOwner;

        emit OwnerPending(_owner, _newOwner);
    }

    
    function acceptOwnership() public onlyPendingOwner {
        emit OwnerUpdated(_owner, msg.sender);

        _owner = _pendingOwner;

        delete _pendingOwner;
    }

    
    function cancelOwnershipTransfer() public onlyOwner {
        emit OwnerCanceled(_owner, _pendingOwner);

        delete _pendingOwner;
    }
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        
        assembly {
            r.slot := slot
        }
    }
}

// 
pragma solidity 0.8.16;
















/// Modified from:
/// - OpenZeppelin Contracts v4.7.3 (governance/TimelockController.sol)
/// - NounsDAOExecutor.sol commit 2cbe6c7 - licensed under the BSD-3-Clause license.
contract Treasury is ITreasury, VersionedContract, UUPS, Ownable, ProposalHasher, TreasuryStorageV1 {
    ///                                                          ///
    ///                         CONSTANTS                        ///
    ///                                                          ///

    
    uint128 private constant INITIAL_GRACE_PERIOD = 2 weeks;

    ///                                                          ///
    ///                         IMMUTABLES                       ///
    ///                                                          ///

    
    IManager private immutable manager;

    ///                                                          ///
    ///                         CONSTRUCTOR                      ///
    ///                                                          ///

    
    constructor(address _manager) payable initializer {
        manager = IManager(_manager);
    }

    ///                                                          ///
    ///                         INITIALIZER                      ///
    ///                                                          ///

    
    
    
    function initialize(address _governor, uint256 _delay) external initializer {
        // Ensure the caller is the contract manager
        if (msg.sender != address(manager)) revert ONLY_MANAGER();

        // Ensure a governor address was provided
        if (_governor == address(0)) revert ADDRESS_ZERO();

        // Grant ownership to the governor
        __Ownable_init(_governor);

        // Store the time delay
        settings.delay = SafeCast.toUint128(_delay);

        // Set the default grace period
        settings.gracePeriod = INITIAL_GRACE_PERIOD;

        emit DelayUpdated(0, _delay);
    }

    ///                                                          ///
    ///                      TRANSACTION STATE                   ///
    ///                                                          ///

    
    
    function timestamp(bytes32 _proposalId) external view returns (uint256) {
        return timestamps[_proposalId];
    }

    
    
    function isExpired(bytes32 _proposalId) external view returns (bool) {
        unchecked {
            return block.timestamp > (timestamps[_proposalId] + settings.gracePeriod);
        }
    }

    
    
    function isQueued(bytes32 _proposalId) public view returns (bool) {
        return timestamps[_proposalId] != 0;
    }

    
    
    function isReady(bytes32 _proposalId) public view returns (bool) {
        return timestamps[_proposalId] != 0 && block.timestamp >= timestamps[_proposalId];
    }

    ///                                                          ///
    ///                        QUEUE PROPOSAL                    ///
    ///                                                          ///

    
    
    function queue(bytes32 _proposalId) external onlyOwner returns (uint256 eta) {
        // Ensure the proposal was not already queued
        if (isQueued(_proposalId)) revert PROPOSAL_ALREADY_QUEUED();

        // Cannot realistically overflow
        unchecked {
            // Compute the timestamp that the proposal will be valid to execute
            eta = block.timestamp + settings.delay;
        }

        // Store the timestamp
        timestamps[_proposalId] = eta;

        emit TransactionScheduled(_proposalId, eta);
    }

    ///                                                          ///
    ///                       EXECUTE PROPOSAL                   ///
    ///                                                          ///

    
    
    
    
    
    
    function execute(
        address[] calldata _targets,
        uint256[] calldata _values,
        bytes[] calldata _calldatas,
        bytes32 _descriptionHash,
        address _proposer
    ) external payable onlyOwner {
        // Get the proposal id
        bytes32 proposalId = hashProposal(_targets, _values, _calldatas, _descriptionHash, _proposer);

        // Ensure the proposal is ready to execute
        if (!isReady(proposalId)) revert EXECUTION_NOT_READY(proposalId);

        // Remove the proposal from the queue
        delete timestamps[proposalId];

        // Cache the number of targets
        uint256 numTargets = _targets.length;

        // Cannot realistically overflow
        unchecked {
            // For each target:
            for (uint256 i = 0; i < numTargets; ++i) {
                // Execute the transaction
                (bool success, ) = _targets[i].call{ value: _values[i] }(_calldatas[i]);

                // Ensure the transaction succeeded
                if (!success) revert EXECUTION_FAILED(i);
            }
        }

        emit TransactionExecuted(proposalId, _targets, _values, _calldatas);
    }

    ///                                                          ///
    ///                       CANCEL PROPOSAL                    ///
    ///                                                          ///

    
    
    function cancel(bytes32 _proposalId) external onlyOwner {
        // Ensure the proposal is queued
        if (!isQueued(_proposalId)) revert PROPOSAL_NOT_QUEUED();

        // Remove the proposal from the queue
        delete timestamps[_proposalId];

        emit TransactionCanceled(_proposalId);
    }

    ///                                                          ///
    ///                      TREASURY SETTINGS                   ///
    ///                                                          ///

    
    function delay() external view returns (uint256) {
        return settings.delay;
    }

    
    function gracePeriod() external view returns (uint256) {
        return settings.gracePeriod;
    }

    ///                                                          ///
    ///                       UPDATE SETTINGS                    ///
    ///                                                          ///

    
    
    function updateDelay(uint256 _newDelay) external {
        // Ensure the caller is the treasury itself
        if (msg.sender != address(this)) revert ONLY_TREASURY();

        emit DelayUpdated(settings.delay, _newDelay);

        // Update the delay
        settings.delay = SafeCast.toUint128(_newDelay);
    }

    
    
    function updateGracePeriod(uint256 _newGracePeriod) external {
        // Ensure the caller is the treasury itself
        if (msg.sender != address(this)) revert ONLY_TREASURY();

        emit GracePeriodUpdated(settings.gracePeriod, _newGracePeriod);

        // Update the grace period
        settings.gracePeriod = SafeCast.toUint128(_newGracePeriod);
    }

    ///                                                          ///
    ///                        RECEIVE TOKENS                    ///
    ///                                                          ///

    
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public pure returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }

    
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public pure returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    
    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public pure returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }

    
    receive() external payable {}

    ///                                                          ///
    ///                       TREASURY UPGRADE                   ///
    ///                                                          ///

    
    
    
    function _authorizeUpgrade(address _newImpl) internal view override {
        // Ensure the caller is the treasury itself
        if (msg.sender != address(this)) revert ONLY_TREASURY();

        // Ensure the new implementation is a registered upgrade
        if (!manager.isRegisteredUpgrade(_getImplementation(), _newImpl)) revert INVALID_UPGRADE(_newImpl);
    }
}

// 
pragma solidity 0.8.16;




/// - Uses custom errors `INVALID_TARGET()` & `DELEGATE_CALL_FAILED()`
/// - Adds util converting address to bytes32
library Address {
    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error INVALID_TARGET();

    
    error DELEGATE_CALL_FAILED();

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    function toBytes32(address _account) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_account)) << 96);
    }

    
    function isContract(address _account) internal view returns (bool rv) {
        assembly {
            rv := gt(extcodesize(_account), 0)
        }
    }

    
    function functionDelegateCall(address _target, bytes memory _data) internal returns (bytes memory) {
        if (!isContract(_target)) revert INVALID_TARGET();

        (bool success, bytes memory returndata) = _target.delegatecall(_data);

        return verifyCallResult(success, returndata);
    }

    
    function verifyCallResult(bool _success, bytes memory _returndata) internal pure returns (bytes memory) {
        if (_success) {
            return _returndata;
        } else {
            if (_returndata.length > 0) {
                assembly {
                    let returndata_size := mload(_returndata)

                    revert(add(32, _returndata), returndata_size)
                }
            } else {
                revert DELEGATE_CALL_FAILED();
            }
        }
    }
}

// 
pragma solidity 0.8.16;


/// - Uses custom error `UNSAFE_CAST()`
library SafeCast {
    error UNSAFE_CAST();

    function toUint128(uint256 x) internal pure returns (uint128) {
        if (x > type(uint128).max) revert UNSAFE_CAST();

        return uint128(x);
    }

    function toUint64(uint256 x) internal pure returns (uint64) {
        if (x > type(uint64).max) revert UNSAFE_CAST();

        return uint64(x);
    }

    function toUint48(uint256 x) internal pure returns (uint48) {
        if (x > type(uint48).max) revert UNSAFE_CAST();

        return uint48(x);
    }

    function toUint40(uint256 x) internal pure returns (uint40) {
        if (x > type(uint40).max) revert UNSAFE_CAST();

        return uint40(x);
    }

    function toUint32(uint256 x) internal pure returns (uint32) {
        if (x > type(uint32).max) revert UNSAFE_CAST();

        return uint32(x);
    }

    function toUint16(uint256 x) internal pure returns (uint16) {
        if (x > type(uint16).max) revert UNSAFE_CAST();

        return uint16(x);
    }

    function toUint8(uint256 x) internal pure returns (uint8) {
        if (x > type(uint8).max) revert UNSAFE_CAST();

        return uint8(x);
    }
}

// 
pragma solidity ^0.8.0;


abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }
}


abstract contract ERC1155TokenReceiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// 
pragma solidity 0.8.16;







interface IManager is IUUPS, IOwnable {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    
    
    
    
    
    event DAODeployed(address token, address metadata, address auction, address treasury, address governor);

    
    
    
    event UpgradeRegistered(address baseImpl, address upgradeImpl);

    
    
    
    event UpgradeRemoved(address baseImpl, address upgradeImpl);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error FOUNDER_REQUIRED();

    ///                                                          ///
    ///                            STRUCTS                       ///
    ///                                                          ///

    
    
    
    
    struct FounderParams {
        address wallet;
        uint256 ownershipPct;
        uint256 vestExpiry;
    }

    
    struct DAOVersionInfo {
        string token;
        string metadata;
        string auction;
        string treasury;
        string governor; 
    }

    
    
    struct TokenParams {
        bytes initStrings;
    }

    
    
    
    struct AuctionParams {
        uint256 reservePrice;
        uint256 duration;
    }

    
    
    
    
    
    
    
    struct GovParams {
        uint256 timelockDelay;
        uint256 votingDelay;
        uint256 votingPeriod;
        uint256 proposalThresholdBps;
        uint256 quorumThresholdBps;
        address vetoer;
    }

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    function tokenImpl() external view returns (address);

    
    function metadataImpl() external view returns (address);

    
    function auctionImpl() external view returns (address);

    
    function treasuryImpl() external view returns (address);

    
    function governorImpl() external view returns (address);

    
    
    
    
    
    function deploy(
        FounderParams[] calldata founderParams,
        TokenParams calldata tokenParams,
        AuctionParams calldata auctionParams,
        GovParams calldata govParams
    )
        external
        returns (
            address token,
            address metadataRenderer,
            address auction,
            address treasury,
            address governor
        );

    
    
    function getAddresses(address token)
        external
        returns (
            address metadataRenderer,
            address auction,
            address treasury,
            address governor
        );

    
    
    
    function isRegisteredUpgrade(address baseImpl, address upgradeImpl) external view returns (bool);

    
    
    
    function registerUpgrade(address baseImpl, address upgradeImpl) external;

    
    
    
    function removeUpgrade(address baseImpl, address upgradeImpl) external;
}