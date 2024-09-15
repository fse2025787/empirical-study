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






contract Initializable {
    
    
    
    error InvalidInitialization(uint256 version, uint256 expectedVersion);

    
    
    
    event Initialize(uint256 version, bytes cdata);

    
    
    modifier init(uint256 _version) {
        if (_version != Version.get()) {
            revert InvalidInitialization(_version, Version.get());
        }
        Version.set(_version + 1); // prevents reentrency on the called method
        _;
        emit Initialize(_version, msg.data);
    }
}

//
pragma solidity 0.8.10;




interface IAllowlistV1 {
    
    
    
    event SetAllowlistPermissions(address[] indexed accounts, uint256[] permissions);

    
    
    event SetAllower(address indexed allower);

    
    error InvalidAlloweeCount();

    
    
    error Denied(address _account);

    
    error MismatchedAlloweeAndStatusCount();

    
    
    
    function initAllowlistV1(address _admin, address _allower) external;

    
    
    function getAllower() external view returns (address);

    
    ///         is not in the deny list
    
    
    
    function isAllowed(address _account, uint256 _mask) external view returns (bool);

    
    
    
    function isDenied(address _account) external view returns (bool);

    
    ///         ignoring any deny list membership
    
    
    
    function hasPermission(address _account, uint256 _mask) external view returns (bool);

    
    
    
    function getPermissions(address _account) external view returns (uint256);

    
    ///         if the user hasn't got the required permission or if the user is
    ///         in the deny list.
    
    
    function onlyAllowed(address _account, uint256 _mask) external view;

    
    
    function setAllower(address _newAllowerAddress) external;

    
    
    
    
    function allow(address[] calldata _accounts, uint256[] calldata _permissions) external;
}

//
pragma solidity 0.8.10;
















contract AllowlistV1 is IAllowlistV1, Initializable, Administrable {
    
    uint256 internal constant DENY_MASK = 0x1 << 255;

    
    function initAllowlistV1(address _admin, address _allower) external init(0) {
        _setAdmin(_admin);
        AllowerAddress.set(_allower);
        emit SetAllower(_allower);
    }

    
    function getAllower() external view returns (address) {
        return AllowerAddress.get();
    }

    
    function isAllowed(address _account, uint256 _mask) external view returns (bool) {
        uint256 userPermissions = Allowlist.get(_account);
        if (userPermissions & DENY_MASK == DENY_MASK) {
            return false;
        }
        return userPermissions & _mask == _mask;
    }

    
    function isDenied(address _account) external view returns (bool) {
        return Allowlist.get(_account) & DENY_MASK == DENY_MASK;
    }

    
    function hasPermission(address _account, uint256 _mask) external view returns (bool) {
        return Allowlist.get(_account) & _mask == _mask;
    }

    
    function getPermissions(address _account) external view returns (uint256) {
        return Allowlist.get(_account);
    }

    
    function onlyAllowed(address _account, uint256 _mask) external view {
        uint256 userPermissions = Allowlist.get(_account);
        if (userPermissions & DENY_MASK == DENY_MASK) {
            revert Denied(_account);
        }
        if (userPermissions & _mask != _mask) {
            revert LibErrors.Unauthorized(_account);
        }
    }

    
    function setAllower(address _newAllowerAddress) external onlyAdmin {
        AllowerAddress.set(_newAllowerAddress);
        emit SetAllower(_newAllowerAddress);
    }

    
    function allow(address[] calldata _accounts, uint256[] calldata _permissions) external {
        if (msg.sender != AllowerAddress.get() && msg.sender != _getAdmin()) {
            revert LibErrors.Unauthorized(msg.sender);
        }

        if (_accounts.length == 0) {
            revert InvalidAlloweeCount();
        }

        if (_accounts.length != _permissions.length) {
            revert MismatchedAlloweeAndStatusCount();
        }

        for (uint256 i = 0; i < _accounts.length;) {
            LibSanitize._notZeroAddress(_accounts[i]);
            Allowlist.set(_accounts[i], _permissions[i]);
            unchecked {
                ++i;
            }
        }

        emit SetAllowlistPermissions(_accounts, _permissions);
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






library AllowerAddress {
    
    bytes32 internal constant ALLOWER_ADDRESS_SLOT = bytes32(uint256(keccak256("river.state.allowerAddress")) - 1);

    
    
    function get() internal view returns (address) {
        return LibUnstructuredStorage.getStorageAddress(ALLOWER_ADDRESS_SLOT);
    }

    
    
    function set(address _newValue) internal {
        LibSanitize._notZeroAddress(_newValue);
        LibUnstructuredStorage.setStorageAddress(ALLOWER_ADDRESS_SLOT, _newValue);
    }
}

//
pragma solidity 0.8.10;



library Allowlist {
    
    bytes32 internal constant ALLOWLIST_SLOT = bytes32(uint256(keccak256("river.state.allowlist")) - 1);

    
    struct Slot {
        
        mapping(address => uint256) value;
    }

    
    
    
    function get(address _account) internal view returns (uint256) {
        bytes32 slot = ALLOWLIST_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        return r.value[_account];
    }

    
    
    
    function set(address _account, uint256 _status) internal {
        bytes32 slot = ALLOWLIST_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        r.value[_account] = _status;
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

//
pragma solidity 0.8.10;





library Version {
    
    bytes32 public constant VERSION_SLOT = bytes32(uint256(keccak256("river.state.version")) - 1);

    
    
    function get() internal view returns (uint256) {
        return LibUnstructuredStorage.getStorageUint256(VERSION_SLOT);
    }

    
    
    function set(uint256 _newValue) internal {
        LibUnstructuredStorage.setStorageUint256(VERSION_SLOT, _newValue);
    }
}