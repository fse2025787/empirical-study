// SPDX-License-Identifier: BUSL-1.1


//
pragma solidity 0.8.10;




interface IAdministrable {
    
    
    event SetPendingAdmin(address indexed pendingAdmin);

    
    
    event SetAdmin(address indexed admin);

    
    
    function getAdmin() external view returns (address);

    
    
    function getPendingAdmin() external view returns (address);

    
    
    
    
    
    function proposeAdmin(address _newAdmin) external;

    
    
    function acceptAdmin() external;
}
//
pragma solidity 0.8.10;









abstract contract Administrable is IAdministrable {
    
    modifier onlyAdmin() {
        if (msg.sender != LibAdministrable._getAdmin()) {
            revert LibErrors.Unauthorized(msg.sender);
        }
        _;
    }

    
    modifier onlyPendingAdmin() {
        if (msg.sender != LibAdministrable._getPendingAdmin()) {
            revert LibErrors.Unauthorized(msg.sender);
        }
        _;
    }

    
    function getAdmin() external view returns (address) {
        return LibAdministrable._getAdmin();
    }

    
    function getPendingAdmin() external view returns (address) {
        return LibAdministrable._getPendingAdmin();
    }

    
    function proposeAdmin(address _newAdmin) external onlyAdmin {
        _setPendingAdmin(_newAdmin);
    }

    
    function acceptAdmin() external onlyPendingAdmin {
        _setAdmin(LibAdministrable._getPendingAdmin());
        _setPendingAdmin(address(0));
    }

    
    
    function _setAdmin(address _admin) internal {
        LibSanitize._notZeroAddress(_admin);
        LibAdministrable._setAdmin(_admin);
        emit SetAdmin(_admin);
    }

    
    
    function _setPendingAdmin(address _pendingAdmin) internal {
        LibAdministrable._setPendingAdmin(_pendingAdmin);
        emit SetPendingAdmin(_pendingAdmin);
    }

    
    
    function _getAdmin() internal view returns (address) {
        return LibAdministrable._getAdmin();
    }
}

//
pragma solidity 0.8.10;




interface IFirewall {
    
    
    event SetExecutor(address indexed executor);

    
    
    event SetDestination(address indexed destination);

    
    
    
    event SetExecutorPermissions(bytes4 selector, bool status);

    
    
    function executor() external view returns (address);

    
    
    function destination() external view returns (address);

    
    
    
    function executorCanCall(bytes4 _selector) external view returns (bool);

    
    
    function setExecutor(address _newExecutor) external;

    
    
    
    function allowExecutor(bytes4 _functionSelector, bool _executorCanCall) external;

    
    fallback() external payable;

    
    receive() external payable;
}

//
pragma solidity 0.8.10;








///         ensures the caller holds an appropriate role for calling that function. There are two roles:
///          - An Admin can call anything
///          - An Executor can call specific functions. The list of function is customisable.
///         Random callers cannot call anything through this contract, even if the underlying function
///         is unpermissioned in the underlying contract.
///         Calls to non-admin functions should be called at the underlying contract directly.
contract Firewall is IFirewall, Administrable {
    
    address public executor;

    
    address public destination;

    
    mapping(bytes4 => bool) public executorCanCall;

    
    
    
    constructor(address _admin, address _executor, address _destination, bytes4[] memory _executorCallableSelectors) {
        LibSanitize._notZeroAddress(_executor);
        LibSanitize._notZeroAddress(_destination);
        _setAdmin(_admin);
        executor = _executor;
        destination = _destination;

        emit SetExecutor(_executor);
        emit SetDestination(_destination);

        for (uint256 i; i < _executorCallableSelectors.length;) {
            executorCanCall[_executorCallableSelectors[i]] = true;
            emit SetExecutorPermissions(_executorCallableSelectors[i], true);
            unchecked {
                ++i;
            }
        }
    }

    
    modifier onlyAdminOrExecutor() {
        if (_getAdmin() != msg.sender && msg.sender != executor) {
            revert LibErrors.Unauthorized(msg.sender);
        }
        _;
    }

    
    function setExecutor(address _newExecutor) external onlyAdminOrExecutor {
        LibSanitize._notZeroAddress(_newExecutor);
        executor = _newExecutor;
        emit SetExecutor(_newExecutor);
    }

    
    function allowExecutor(bytes4 _functionSelector, bool _executorCanCall) external onlyAdmin {
        executorCanCall[_functionSelector] = _executorCanCall;
        emit SetExecutorPermissions(_functionSelector, _executorCanCall);
    }

    
    fallback() external payable virtual {
        _fallback();
    }

    
    receive() external payable virtual {
        _fallback();
    }

    
    function _checkCallerRole() internal view {
        if (msg.sender == _getAdmin() || (executorCanCall[msg.sig] && msg.sender == executor)) {
            return;
        }
        revert LibErrors.Unauthorized(msg.sender);
    }

    
    
    
    function _forward(address _destination, uint256 _value) internal {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the destination.
            // out and outsize are 0 because we don't know the size yet.
            let result := call(gas(), _destination, _value, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // call returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    
    function _fallback() internal virtual {
        _checkCallerRole();
        _forward(destination, msg.value);
    }
}

//
pragma solidity 0.8.10;







library LibAdministrable {
    
    
    function _getAdmin() internal view returns (address) {
        return AdministratorAddress.get();
    }

    
    
    function _getPendingAdmin() internal view returns (address) {
        return PendingAdministratorAddress.get();
    }

    
    
    function _setAdmin(address _admin) internal {
        AdministratorAddress.set(_admin);
    }

    
    
    function _setPendingAdmin(address _pendingAdmin) internal {
        PendingAdministratorAddress.set(_pendingAdmin);
    }
}

//
pragma solidity 0.8.10;



library LibBasisPoints {
    
    uint256 internal constant BASIS_POINTS_MAX = 10_000;
}

//
pragma solidity 0.8.10;



library LibErrors {
    
    
    error Unauthorized(address caller);

    
    error InvalidCall();

    
    error InvalidArgument();

    
    error InvalidZeroAddress();

    
    error InvalidEmptyString();

    
    error InvalidFee();
}

//
pragma solidity 0.8.10;






library LibSanitize {
    
    
    function _notZeroAddress(address _address) internal pure {
        if (_address == address(0)) {
            revert LibErrors.InvalidZeroAddress();
        }
    }

    
    
    function _notEmptyString(string memory _string) internal pure {
        if (bytes(_string).length == 0) {
            revert LibErrors.InvalidEmptyString();
        }
    }

    
    
    function _validFee(uint256 _fee) internal pure {
        if (_fee > LibBasisPoints.BASIS_POINTS_MAX) {
            revert LibErrors.InvalidFee();
        }
    }
}

// 

pragma solidity 0.8.10;



library LibUnstructuredStorage {
    
    
    
    function getStorageBool(bytes32 _position) internal view returns (bool data) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            data := sload(_position)
        }
    }

    
    
    
    function getStorageAddress(bytes32 _position) internal view returns (address data) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            data := sload(_position)
        }
    }

    
    
    
    function getStorageBytes32(bytes32 _position) internal view returns (bytes32 data) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            data := sload(_position)
        }
    }

    
    
    
    function getStorageUint256(bytes32 _position) internal view returns (uint256 data) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            data := sload(_position)
        }
    }

    
    
    
    function setStorageBool(bytes32 _position, bool _data) internal {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(_position, _data)
        }
    }

    
    
    
    function setStorageAddress(bytes32 _position, address _data) internal {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(_position, _data)
        }
    }

    
    
    
    function setStorageBytes32(bytes32 _position, bytes32 _data) internal {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(_position, _data)
        }
    }

    
    
    
    function setStorageUint256(bytes32 _position, uint256 _data) internal {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(_position, _data)
        }
    }
}

//
pragma solidity 0.8.10;






library AdministratorAddress {
    
    bytes32 public constant ADMINISTRATOR_ADDRESS_SLOT =
        bytes32(uint256(keccak256("river.state.administratorAddress")) - 1);

    
    
    function get() internal view returns (address) {
        return LibUnstructuredStorage.getStorageAddress(ADMINISTRATOR_ADDRESS_SLOT);
    }

    
    
    function set(address _newValue) internal {
        LibSanitize._notZeroAddress(_newValue);
        LibUnstructuredStorage.setStorageAddress(ADMINISTRATOR_ADDRESS_SLOT, _newValue);
    }
}

//
pragma solidity 0.8.10;





library PendingAdministratorAddress {
    
    bytes32 public constant PENDING_ADMINISTRATOR_ADDRESS_SLOT =
        bytes32(uint256(keccak256("river.state.pendingAdministratorAddress")) - 1);

    
    
    function get() internal view returns (address) {
        return LibUnstructuredStorage.getStorageAddress(PENDING_ADMINISTRATOR_ADDRESS_SLOT);
    }

    
    
    function set(address _newValue) internal {
        LibUnstructuredStorage.setStorageAddress(PENDING_ADMINISTRATOR_ADDRESS_SLOT, _newValue);
    }
}