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






interface IOperatorsRegistryV1 {
    
    
    
    
    event AddedOperator(uint256 indexed index, string name, address indexed operatorAddress);

    
    
    
    event SetOperatorStatus(uint256 indexed index, bool active);

    
    
    
    event SetOperatorLimit(uint256 indexed index, uint256 newLimit);

    
    
    
    event SetOperatorStoppedValidatorCount(uint256 indexed index, uint256 newStoppedValidatorCount);

    
    
    
    event SetOperatorAddress(uint256 indexed index, address indexed newOperatorAddress);

    
    
    
    event SetOperatorName(uint256 indexed index, string newName);

    
    
    
    
    
    
    
    event AddedValidatorKeys(uint256 indexed index, bytes publicKeysAndSignatures);

    
    
    
    event RemovedValidatorKey(uint256 indexed index, bytes publicKey);

    
    
    event SetRiver(address indexed river);

    
    
    
    
    
    
    
    
    event OperatorEditsAfterSnapshot(
        uint256 indexed index,
        uint256 currentLimit,
        uint256 newLimit,
        uint256 indexed latestKeysEditBlockNumber,
        uint256 indexed snapshotBlock
    );

    
    
    
    event OperatorLimitUnchanged(uint256 indexed index, uint256 limit);

    
    
    error InactiveOperator(uint256 index);

    
    error InvalidFundedKeyDeletionAttempt();

    
    error InvalidUnsortedIndexes();

    
    error InvalidArrayLengths();

    
    error InvalidEmptyArray();

    
    error InvalidKeyCount();

    
    error InvalidKeysLength();

    
    error InvalidIndexOutOfBounds();

    
    
    
    
    error OperatorLimitTooHigh(uint256 index, uint256 limit, uint256 keyCount);

    
    
    
    
    error OperatorLimitTooLow(uint256 index, uint256 limit, uint256 fundedKeyCount);

    
    error UnorderedOperatorList();

    
    
    
    function initOperatorsRegistryV1(address _admin, address _river) external;

    
    
    function getRiver() external view returns (address);

    
    
    
    function getOperator(uint256 _index) external view returns (Operators.Operator memory);

    
    
    function getOperatorCount() external view returns (uint256);

    
    
    
    
    
    
    function getValidator(uint256 _operatorIndex, uint256 _validatorIndex)
        external
        view
        returns (bytes memory publicKey, bytes memory signature, bool funded);

    
    
    function listActiveOperators() external view returns (Operators.Operator[] memory);

    
    
    
    
    
    function addOperator(string calldata _name, address _operator) external returns (uint256);

    
    
    
    
    function setOperatorAddress(uint256 _index, address _newOperatorAddress) external;

    
    
    
    
    function setOperatorName(uint256 _index, string calldata _newName) external;

    
    
    
    
    function setOperatorStatus(uint256 _index, bool _newStatus) external;

    
    
    
    
    function setOperatorStoppedValidatorCount(uint256 _index, uint256 _newStoppedValidatorCount) external;

    
    
    
    
    
    
    
    
    
    function setOperatorLimits(
        uint256[] calldata _operatorIndexes,
        uint256[] calldata _newLimits,
        uint256 _snapshotBlock
    ) external;

    
    
    
    
    
    function addValidators(uint256 _index, uint256 _keyCount, bytes calldata _publicKeysAndSignatures) external;

    
    
    
    
    
    
    
    
    
    
    
    function removeValidators(uint256 _index, uint256[] calldata _indexes) external;

    
    
    
    
    function pickNextValidators(uint256 _count)
        external
        returns (bytes[] memory publicKeys, bytes[] memory signatures);
}

//
pragma solidity 0.8.10;















contract OperatorsRegistryV1 is IOperatorsRegistryV1, Initializable, Administrable {
    
    uint256 internal constant MAX_VALIDATOR_ATTRIBUTION_PER_ROUND = 5;

    
    function initOperatorsRegistryV1(address _admin, address _river) external init(0) {
        _setAdmin(_admin);
        RiverAddress.set(_river);
        emit SetRiver(_river);
    }

    
    modifier onlyRiver() virtual {
        if (msg.sender != RiverAddress.get()) {
            revert LibErrors.Unauthorized(msg.sender);
        }
        _;
    }

    
    
    
    modifier onlyOperatorOrAdmin(uint256 _index) {
        if (msg.sender == _getAdmin()) {
            _;
            return;
        }
        Operators.Operator storage operator = Operators.get(_index);
        if (!operator.active) {
            revert InactiveOperator(_index);
        }
        if (msg.sender != operator.operator) {
            revert LibErrors.Unauthorized(msg.sender);
        }
        _;
    }

    
    function getRiver() external view returns (address) {
        return RiverAddress.get();
    }

    
    function getOperator(uint256 _index) external view returns (Operators.Operator memory) {
        return Operators.get(_index);
    }

    
    function getOperatorCount() external view returns (uint256) {
        return Operators.getCount();
    }

    
    function getValidator(uint256 _operatorIndex, uint256 _validatorIndex)
        external
        view
        returns (bytes memory publicKey, bytes memory signature, bool funded)
    {
        (publicKey, signature) = ValidatorKeys.get(_operatorIndex, _validatorIndex);
        funded = _validatorIndex < Operators.get(_operatorIndex).funded;
    }

    
    function listActiveOperators() external view returns (Operators.Operator[] memory) {
        return Operators.getAllActive();
    }

    
    function addOperator(string calldata _name, address _operator) external onlyAdmin returns (uint256) {
        Operators.Operator memory newOperator = Operators.Operator({
            active: true,
            operator: _operator,
            name: _name,
            limit: 0,
            funded: 0,
            keys: 0,
            stopped: 0,
            latestKeysEditBlockNumber: block.number
        });

        uint256 operatorIndex = Operators.push(newOperator) - 1;

        emit AddedOperator(operatorIndex, _name, _operator);
        return operatorIndex;
    }

    
    function setOperatorAddress(uint256 _index, address _newOperatorAddress) external onlyOperatorOrAdmin(_index) {
        LibSanitize._notZeroAddress(_newOperatorAddress);
        Operators.Operator storage operator = Operators.get(_index);

        operator.operator = _newOperatorAddress;

        emit SetOperatorAddress(_index, _newOperatorAddress);
    }

    
    function setOperatorName(uint256 _index, string calldata _newName) external onlyOperatorOrAdmin(_index) {
        LibSanitize._notEmptyString(_newName);
        Operators.Operator storage operator = Operators.get(_index);
        operator.name = _newName;

        emit SetOperatorName(_index, _newName);
    }

    
    function setOperatorStatus(uint256 _index, bool _newStatus) external onlyAdmin {
        Operators.Operator storage operator = Operators.get(_index);
        operator.active = _newStatus;

        emit SetOperatorStatus(_index, _newStatus);
    }

    
    function setOperatorStoppedValidatorCount(uint256 _index, uint256 _newStoppedValidatorCount) external onlyAdmin {
        Operators.Operator storage operator = Operators.get(_index);

        if (_newStoppedValidatorCount > operator.funded) {
            revert LibErrors.InvalidArgument();
        }

        operator.stopped = _newStoppedValidatorCount;

        emit SetOperatorStoppedValidatorCount(_index, _newStoppedValidatorCount);
    }

    
    function setOperatorLimits(
        uint256[] calldata _operatorIndexes,
        uint256[] calldata _newLimits,
        uint256 _snapshotBlock
    ) external onlyAdmin {
        if (_operatorIndexes.length != _newLimits.length) {
            revert InvalidArrayLengths();
        }
        if (_operatorIndexes.length == 0) {
            revert InvalidEmptyArray();
        }
        for (uint256 idx = 0; idx < _operatorIndexes.length;) {
            uint256 operatorIndex = _operatorIndexes[idx];
            uint256 newLimit = _newLimits[idx];

            // prevents duplicates
            if (idx > 0 && !(operatorIndex > _operatorIndexes[idx - 1])) {
                revert UnorderedOperatorList();
            }

            Operators.Operator storage operator = Operators.get(operatorIndex);

            uint256 currentLimit = operator.limit;
            if (newLimit == currentLimit) {
                emit OperatorLimitUnchanged(operatorIndex, newLimit);
                unchecked {
                    ++idx;
                }
                continue;
            }

            // we enter this condition if the operator edited its keys after the off-chain key audit was made
            // we will skip any limit update on that operator unless it was a decrease in the initial limit
            if (_snapshotBlock < operator.latestKeysEditBlockNumber && newLimit > currentLimit) {
                emit OperatorEditsAfterSnapshot(
                    operatorIndex, currentLimit, newLimit, operator.latestKeysEditBlockNumber, _snapshotBlock
                    );
                unchecked {
                    ++idx;
                }
                continue;
            }

            // otherwise, we check for limit invariants that shouldn't happen if the off-chain key audit
            // was made properly, and if everything is respected, we update the limit

            if (newLimit > operator.keys) {
                revert OperatorLimitTooHigh(operatorIndex, newLimit, operator.keys);
            }

            if (newLimit < operator.funded) {
                revert OperatorLimitTooLow(operatorIndex, newLimit, operator.funded);
            }

            operator.limit = newLimit;
            emit SetOperatorLimit(operatorIndex, newLimit);

            unchecked {
                ++idx;
            }
        }
    }

    
    function addValidators(uint256 _index, uint256 _keyCount, bytes calldata _publicKeysAndSignatures)
        external
        onlyOperatorOrAdmin(_index)
    {
        if (_keyCount == 0) {
            revert InvalidKeyCount();
        }

        if (
            _publicKeysAndSignatures.length
                != _keyCount * (ValidatorKeys.PUBLIC_KEY_LENGTH + ValidatorKeys.SIGNATURE_LENGTH)
        ) {
            revert InvalidKeysLength();
        }

        Operators.Operator storage operator = Operators.get(_index);

        for (uint256 idx = 0; idx < _keyCount;) {
            bytes memory publicKeyAndSignature = LibBytes.slice(
                _publicKeysAndSignatures,
                idx * (ValidatorKeys.PUBLIC_KEY_LENGTH + ValidatorKeys.SIGNATURE_LENGTH),
                ValidatorKeys.PUBLIC_KEY_LENGTH + ValidatorKeys.SIGNATURE_LENGTH
            );
            ValidatorKeys.set(_index, operator.keys + idx, publicKeyAndSignature);
            unchecked {
                ++idx;
            }
        }
        Operators.setKeys(_index, operator.keys + _keyCount);

        emit AddedValidatorKeys(_index, _publicKeysAndSignatures);
    }

    
    function removeValidators(uint256 _index, uint256[] calldata _indexes) external onlyOperatorOrAdmin(_index) {
        uint256 indexesLength = _indexes.length;
        if (indexesLength == 0) {
            revert InvalidKeyCount();
        }

        Operators.Operator storage operator = Operators.get(_index);

        uint256 totalKeys = operator.keys;

        if (!(_indexes[0] < totalKeys)) {
            revert InvalidIndexOutOfBounds();
        }

        uint256 lastIndex = _indexes[indexesLength - 1];

        if (lastIndex < operator.funded) {
            revert InvalidFundedKeyDeletionAttempt();
        }

        bool limitEqualsKeyCount = operator.keys == operator.limit;
        Operators.setKeys(_index, totalKeys - indexesLength);

        uint256 idx;
        for (; idx < indexesLength;) {
            uint256 keyIndex = _indexes[idx];

            if (idx > 0 && !(keyIndex < _indexes[idx - 1])) {
                revert InvalidUnsortedIndexes();
            }

            unchecked {
                ++idx;
            }

            uint256 lastKeyIndex = totalKeys - idx;

            (bytes memory removedPublicKey,) = ValidatorKeys.get(_index, keyIndex);
            (bytes memory lastPublicKeyAndSignature) = ValidatorKeys.getRaw(_index, lastKeyIndex);
            ValidatorKeys.set(_index, keyIndex, lastPublicKeyAndSignature);
            ValidatorKeys.set(_index, lastKeyIndex, new bytes(0));

            emit RemovedValidatorKey(_index, removedPublicKey);
        }

        if (limitEqualsKeyCount) {
            operator.limit = operator.keys;
        } else if (lastIndex < operator.limit) {
            operator.limit = lastIndex;
        }
    }

    
    function pickNextValidators(uint256 _count)
        external
        onlyRiver
        returns (bytes[] memory publicKeys, bytes[] memory signatures)
    {
        return _pickNextValidatorsFromActiveOperators(_count);
    }

    
    
    
    
    function _concatenateByteArrays(bytes[] memory _arr1, bytes[] memory _arr2)
        internal
        pure
        returns (bytes[] memory)
    {
        bytes[] memory res = new bytes[](_arr1.length + _arr2.length);
        for (uint256 idx = 0; idx < _arr1.length;) {
            res[idx] = _arr1[idx];
            unchecked {
                ++idx;
            }
        }
        for (uint256 idx = 0; idx < _arr2.length;) {
            res[idx + _arr1.length] = _arr2[idx];
            unchecked {
                ++idx;
            }
        }
        return res;
    }

    
    
    
    function _hasFundableKeys(Operators.CachedOperator memory _operator) internal pure returns (bool) {
        return (_operator.funded + _operator.picked) < _operator.limit;
    }

    
    
    
    function _getActiveKeyCount(Operators.CachedOperator memory _operator) internal pure returns (uint256) {
        return (_operator.funded + _operator.picked) - _operator.stopped;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function _pickNextValidatorsFromActiveOperators(uint256 _count)
        internal
        returns (bytes[] memory publicKeys, bytes[] memory signatures)
    {
        Operators.CachedOperator[] memory operators = Operators.getAllFundable();

        if (operators.length == 0) {
            return (new bytes[](0), new bytes[](0));
        }

        while (_count > 0) {
            // loop on operators to find the first that has fundable keys, taking into account previous loop round attributions
            uint256 selectedOperatorIndex = 0;
            for (; selectedOperatorIndex < operators.length;) {
                if (_hasFundableKeys(operators[selectedOperatorIndex])) {
                    break;
                }
                unchecked {
                    ++selectedOperatorIndex;
                }
            }

            // if we reach the end, we have allocated all keys
            if (selectedOperatorIndex == operators.length) {
                break;
            }

            // we start from the next operator and we try to find one that has fundable keys but a lower (funded + picked) - stopped value
            for (uint256 idx = selectedOperatorIndex + 1; idx < operators.length;) {
                if (
                    _getActiveKeyCount(operators[idx]) < _getActiveKeyCount(operators[selectedOperatorIndex])
                        && _hasFundableKeys(operators[idx])
                ) {
                    selectedOperatorIndex = idx;
                }
                unchecked {
                    ++idx;
                }
            }

            // we take the smallest value between limit - (funded + picked), _requestedAmount and MAX_VALIDATOR_ATTRIBUTION_PER_ROUND
            uint256 pickedKeyCount = LibUint256.min(
                LibUint256.min(
                    operators[selectedOperatorIndex].limit
                        - (operators[selectedOperatorIndex].funded + operators[selectedOperatorIndex].picked),
                    MAX_VALIDATOR_ATTRIBUTION_PER_ROUND
                ),
                _count
            );

            // we update the cached picked amount
            operators[selectedOperatorIndex].picked += pickedKeyCount;

            // we update the requested amount count
            _count -= pickedKeyCount;
        }

        // we loop on all operators
        for (uint256 idx = 0; idx < operators.length; ++idx) {
            // if we picked keys on any operator, we extract the keys from storage and concatenate them in the result
            // we then update the funded value
            if (operators[idx].picked > 0) {
                (bytes[] memory _publicKeys, bytes[] memory _signatures) =
                    ValidatorKeys.getKeys(operators[idx].index, operators[idx].funded, operators[idx].picked);
                publicKeys = _concatenateByteArrays(publicKeys, _publicKeys);
                signatures = _concatenateByteArrays(signatures, _signatures);
                (Operators.get(operators[idx].index)).funded += operators[idx].picked;
            }
        }
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



library LibBytes {
    
    error SliceOverflow();

    
    error SliceOutOfBounds();

    
    
    
    
    
    function slice(bytes memory _bytes, uint256 _start, uint256 _length) internal pure returns (bytes memory) {
        unchecked {
            if (_length + 31 < _length) {
                revert SliceOverflow();
            }
        }
        if (_bytes.length < _start + _length) {
            revert SliceOutOfBounds();
        }

        bytes memory tempBytes;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } { mstore(mc, mload(cc)) }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)
                //zero out the 32 bytes slice we are about to return
                //we need to do it because Solidity does not garbage collect
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }
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



library LibUint256 {
    
    
    
    function toLittleEndian64(uint256 _value) internal pure returns (uint256 result) {
        result = 0;
        uint256 tempValue = _value;
        result = tempValue & 0xFF;
        tempValue >>= 8;

        result = (result << 8) | (tempValue & 0xFF);
        tempValue >>= 8;

        result = (result << 8) | (tempValue & 0xFF);
        tempValue >>= 8;

        result = (result << 8) | (tempValue & 0xFF);
        tempValue >>= 8;

        result = (result << 8) | (tempValue & 0xFF);
        tempValue >>= 8;

        result = (result << 8) | (tempValue & 0xFF);
        tempValue >>= 8;

        result = (result << 8) | (tempValue & 0xFF);
        tempValue >>= 8;

        result = (result << 8) | (tempValue & 0xFF);
        tempValue >>= 8;

        assert(0 == tempValue); // fully converted
        result <<= (24 * 8);
    }

    
    
    
    
    function min(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return (_a > _b ? _b : _a);
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





library Operators {
    
    bytes32 internal constant OPERATORS_SLOT = bytes32(uint256(keccak256("river.state.operators")) - 1);

    
    struct Operator {
        
        bool active;
        
        string name;
        
        address operator;
        
        

        
        uint256 limit;
        
        uint256 funded;
        
        uint256 keys;
        
        ///                   that exited the consensus layer (voluntary or slashed)
        uint256 stopped;
        uint256 latestKeysEditBlockNumber;
    }

    
    struct CachedOperator {
        
        bool active;
        
        string name;
        
        address operator;
        
        uint256 limit;
        
        uint256 funded;
        
        uint256 keys;
        
        uint256 stopped;
        
        ///                   that exited the consensus layer (voluntary or slashed)
        uint256 index;
        
        uint256 picked;
    }

    
    struct SlotOperator {
        
        Operator[] value;
    }

    
    
    error OperatorNotFound(uint256 index);

    
    
    
    function get(uint256 _index) internal view returns (Operator storage) {
        bytes32 slot = OPERATORS_SLOT;

        SlotOperator storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        if (r.value.length <= _index) {
            revert OperatorNotFound(_index);
        }

        return r.value[_index];
    }

    
    
    function getCount() internal view returns (uint256) {
        bytes32 slot = OPERATORS_SLOT;

        SlotOperator storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        return r.value.length;
    }

    
    
    function getAllActive() internal view returns (Operator[] memory) {
        bytes32 slot = OPERATORS_SLOT;

        SlotOperator storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        uint256 activeCount = 0;
        uint256 operatorCount = r.value.length;

        for (uint256 idx = 0; idx < operatorCount;) {
            if (r.value[idx].active) {
                unchecked {
                    ++activeCount;
                }
            }
            unchecked {
                ++idx;
            }
        }

        Operator[] memory activeOperators = new Operator[](activeCount);

        uint256 activeIdx = 0;
        for (uint256 idx = 0; idx < operatorCount;) {
            if (r.value[idx].active) {
                activeOperators[activeIdx] = r.value[idx];
                unchecked {
                    ++activeIdx;
                }
            }
            unchecked {
                ++idx;
            }
        }

        return activeOperators;
    }

    
    
    function getAllFundable() internal view returns (CachedOperator[] memory) {
        bytes32 slot = OPERATORS_SLOT;

        SlotOperator storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        uint256 activeCount = 0;
        uint256 operatorCount = r.value.length;

        for (uint256 idx = 0; idx < operatorCount;) {
            if (_hasFundableKeys(r.value[idx])) {
                unchecked {
                    ++activeCount;
                }
            }
            unchecked {
                ++idx;
            }
        }

        CachedOperator[] memory activeOperators = new CachedOperator[](activeCount);

        uint256 activeIdx = 0;
        for (uint256 idx = 0; idx < operatorCount;) {
            Operator memory op = r.value[idx];
            if (_hasFundableKeys(op)) {
                activeOperators[activeIdx] = CachedOperator({
                    active: op.active,
                    name: op.name,
                    operator: op.operator,
                    limit: op.limit,
                    funded: op.funded,
                    keys: op.keys,
                    stopped: op.stopped,
                    index: idx,
                    picked: 0
                });
                unchecked {
                    ++activeIdx;
                }
            }
            unchecked {
                ++idx;
            }
        }

        return activeOperators;
    }

    
    
    
    function push(Operator memory _newOperator) internal returns (uint256) {
        LibSanitize._notZeroAddress(_newOperator.operator);
        LibSanitize._notEmptyString(_newOperator.name);
        bytes32 slot = OPERATORS_SLOT;

        SlotOperator storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        r.value.push(_newOperator);

        return r.value.length;
    }

    
    
    
    function setKeys(uint256 _index, uint256 _newKeys) internal {
        Operator storage op = get(_index);

        op.keys = _newKeys;
        op.latestKeysEditBlockNumber = block.number;
    }

    
    
    
    function _hasFundableKeys(Operators.Operator memory _operator) internal pure returns (bool) {
        return (_operator.active && _operator.limit > _operator.funded);
    }
}

//
pragma solidity 0.8.10;





library ValidatorKeys {
    
    bytes32 internal constant VALIDATOR_KEYS_SLOT = bytes32(uint256(keccak256("river.state.validatorKeys")) - 1);

    
    uint256 internal constant PUBLIC_KEY_LENGTH = 48;

    
    uint256 internal constant SIGNATURE_LENGTH = 96;

    
    error InvalidPublicKey();

    
    error InvalidSignature();

    
    struct Slot {
        
        mapping(uint256 => mapping(uint256 => bytes)) value;
    }

    
    
    
    
    
    function get(uint256 _operatorIndex, uint256 _idx)
        internal
        view
        returns (bytes memory publicKey, bytes memory signature)
    {
        bytes32 slot = VALIDATOR_KEYS_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        bytes storage entry = r.value[_operatorIndex][_idx];

        publicKey = LibBytes.slice(entry, 0, PUBLIC_KEY_LENGTH);
        signature = LibBytes.slice(entry, PUBLIC_KEY_LENGTH, SIGNATURE_LENGTH);
    }

    
    
    
    
    function getRaw(uint256 _operatorIndex, uint256 _idx) internal view returns (bytes memory) {
        bytes32 slot = VALIDATOR_KEYS_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        return r.value[_operatorIndex][_idx];
    }

    
    
    
    
    
    
    function getKeys(uint256 _operatorIndex, uint256 _startIdx, uint256 _amount)
        internal
        view
        returns (bytes[] memory publicKeys, bytes[] memory signatures)
    {
        publicKeys = new bytes[](_amount);
        signatures = new bytes[](_amount);

        bytes32 slot = VALIDATOR_KEYS_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }
        uint256 idx;
        for (; idx < _amount;) {
            bytes memory rawCredentials = r.value[_operatorIndex][idx + _startIdx];
            publicKeys[idx] = LibBytes.slice(rawCredentials, 0, PUBLIC_KEY_LENGTH);
            signatures[idx] = LibBytes.slice(rawCredentials, PUBLIC_KEY_LENGTH, SIGNATURE_LENGTH);
            unchecked {
                ++idx;
            }
        }
    }

    
    
    
    
    function set(uint256 _operatorIndex, uint256 _idx, bytes memory _publicKeyAndSignature) internal {
        bytes32 slot = VALIDATOR_KEYS_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        r.value[_operatorIndex][_idx] = _publicKeyAndSignature;
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






library RiverAddress {
    
    bytes32 internal constant RIVER_ADDRESS_SLOT = bytes32(uint256(keccak256("river.state.riverAddress")) - 1);

    
    
    function get() internal view returns (address) {
        return LibUnstructuredStorage.getStorageAddress(RIVER_ADDRESS_SLOT);
    }

    
    
    function set(address _newValue) internal {
        LibSanitize._notZeroAddress(_newValue);
        LibUnstructuredStorage.setStorageAddress(RIVER_ADDRESS_SLOT, _newValue);
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