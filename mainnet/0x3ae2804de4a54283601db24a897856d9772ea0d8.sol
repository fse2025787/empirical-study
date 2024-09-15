// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.10;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This ownership interface matches OZ's ownable interface.
 *
 */
interface IOwnable {
    error ONLY_OWNER();
    error ONLY_PENDING_OWNER();

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event OwnerPending(
        address indexed previousOwner,
        address indexed potentialNewOwner
    );

    event OwnerCanceled(
        address indexed previousOwner,
        address indexed potentialNewOwner
    );

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() external view returns (address);
}

// 
pragma solidity ^0.8.10;







/// - Uses custom errors declared in IOwnable
/// - Adds optional two-step ownership transfer (`safeTransferOwnership` + `acceptOwnership`)
abstract contract OwnableWithConfirmation is IOwnable {
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

    
    
    constructor(address _initialOwner) {
        _owner = _initialOwner;

        emit OwnershipTransferred(address(0), _initialOwner);
    }

    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    
    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    
    
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    
    
    
    function _transferOwnership(address _newOwner) internal {
        emit OwnershipTransferred(_owner, _newOwner);

        _owner = _newOwner;

        if (_pendingOwner != address(0)) delete _pendingOwner;
    }

    
    
    function safeTransferOwnership(address _newOwner) public onlyOwner {
        _pendingOwner = _newOwner;

        emit OwnerPending(_owner, _newOwner);
    }

    
    function acceptOwnership() public onlyPendingOwner {
        emit OwnershipTransferred(_owner, msg.sender);

        _owner = _pendingOwner;

        delete _pendingOwner;
    }

    
    function cancelOwnershipTransfer() public onlyOwner {
        emit OwnerCanceled(_owner, _pendingOwner);

        delete _pendingOwner;
    }
}// 
pragma solidity ^0.8.10;




contract OwnedSubscriptionManager is OwnableWithConfirmation {
    IOperatorFilterRegistry immutable registry =
        IOperatorFilterRegistry(0x000000000000AAeB6D7670E522A718067333cd4E);

    constructor(address _initialOwner) OwnableWithConfirmation(_initialOwner) {
        registry.register(address(this));
    }
}

// 
pragma solidity ^0.8.10;

interface IOperatorFilterRegistry {
    function isOperatorAllowed(address registrant, address operator) external view returns (bool);
    function register(address registrant) external;
    function registerAndSubscribe(address registrant, address subscription) external;
    function registerAndCopyEntries(address registrant, address registrantToCopy) external;
    function updateOperator(address registrant, address operator, bool filtered) external;
    function updateOperators(address registrant, address[] calldata operators, bool filtered) external;
    function updateCodeHash(address registrant, bytes32 codehash, bool filtered) external;
    function updateCodeHashes(address registrant, bytes32[] calldata codeHashes, bool filtered) external;
    function subscribe(address registrant, address registrantToSubscribe) external;
    function unsubscribe(address registrant, bool copyExistingEntries) external;
    function subscriptionOf(address addr) external returns (address registrant);
    function subscribers(address registrant) external returns (address[] memory);
    function subscriberAt(address registrant, uint256 index) external returns (address);
    function copyEntriesOf(address registrant, address registrantToCopy) external;
    function isOperatorFiltered(address registrant, address operator) external returns (bool);
    function isCodeHashOfFiltered(address registrant, address operatorWithCode) external returns (bool);
    function isCodeHashFiltered(address registrant, bytes32 codeHash) external returns (bool);
    function filteredOperators(address addr) external returns (address[] memory);
    function filteredCodeHashes(address addr) external returns (bytes32[] memory);
    function filteredOperatorAt(address registrant, uint256 index) external returns (address);
    function filteredCodeHashAt(address registrant, uint256 index) external returns (bytes32);
    function isRegistered(address addr) external returns (bool);
    function codeHashOf(address addr) external returns (bytes32);

    function unregister(address registrant) external;
}
