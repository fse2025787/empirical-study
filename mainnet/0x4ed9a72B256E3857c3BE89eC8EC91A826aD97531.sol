// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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




interface IELFeeRecipientV1 {
    
    
    event SetRiver(address indexed river);

    
    error InvalidCall();

    
    
    function initELFeeRecipientV1(address _riverAddress) external;

    
    
    
    function pullELFees(uint256 _maxAmount) external;

    
    receive() external payable;

    
    fallback() external payable;
}

//
pragma solidity 0.8.10;




interface IConsensusLayerDepositManagerV1 {
    
    
    event FundedValidatorKey(bytes publicKey);

    
    
    event SetDepositContractAddress(address indexed depositContract);

    
    
    event SetWithdrawalCredentials(bytes32 withdrawalCredentials);

    
    error NotEnoughFunds();

    
    error InconsistentPublicKeys();

    
    error InconsistentSignatures();

    
    error NoAvailableValidatorKeys();

    
    error InvalidPublicKeyCount();

    
    error InvalidSignatureCount();

    
    error InvalidWithdrawalCredentials();

    
    error ErrorOnDeposit();

    
    
    function getBalanceToDeposit() external view returns (uint256);

    
    
    function getWithdrawalCredentials() external view returns (bytes32);

    
    
    function getDepositedValidatorCount() external view returns (uint256);

    
    
    function depositToConsensusLayer(uint256 _maxCount) external;
}

//
pragma solidity 0.8.10;




interface IOracleManagerV1 {
    
    
    event SetOracle(address indexed oracleAddress);

    
    
    
    
    event ConsensusLayerDataUpdate(uint256 validatorCount, uint256 validatorTotalBalance, bytes32 roundId);

    
    
    
    error InvalidValidatorCountReport(uint256 providedValidatorCount, uint256 depositedValidatorCount);

    
    
    function getOracle() external view returns (address);

    
    
    function getCLValidatorTotalBalance() external view returns (uint256);

    
    
    function getCLValidatorCount() external view returns (uint256);

    
    
    function setOracle(address _oracleAddress) external;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function setConsensusLayerData(
        uint256 _validatorCount,
        uint256 _validatorTotalBalance,
        bytes32 _roundId,
        uint256 _maxIncrease
    ) external;
}

//
pragma solidity 0.8.10;






interface ISharesManagerV1 is IERC20 {
    
    error BalanceTooLow();

    
    
    
    
    
    error AllowanceTooLow(address _from, address _operator, uint256 _allowance, uint256 _value);

    
    error NullTransfer();

    
    
    
    error UnauthorizedTransfer(address _from, address _to);

    
    
    function name() external pure returns (string memory);

    
    
    function symbol() external pure returns (string memory);

    
    
    function decimals() external pure returns (uint8);

    
    
    function totalSupply() external view returns (uint256);

    
    
    function totalUnderlyingSupply() external view returns (uint256);

    
    
    
    function balanceOf(address _owner) external view returns (uint256);

    
    
    
    function balanceOfUnderlying(address _owner) external view returns (uint256);

    
    
    
    function underlyingBalanceFromShares(uint256 _shares) external view returns (uint256);

    
    
    
    function sharesFromUnderlyingBalance(uint256 _underlyingAssetAmount) external view returns (uint256);

    
    
    
    
    function allowance(address _owner, address _spender) external view returns (uint256);

    
    
    
    
    function transfer(address _to, uint256 _value) external returns (bool);

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    
    
    
    
    
    function approve(address _spender, uint256 _value) external returns (bool);

    
    
    
    
    function increaseAllowance(address _spender, uint256 _additionalValue) external returns (bool);

    
    
    
    
    function decreaseAllowance(address _spender, uint256 _subtractableValue) external returns (bool);
}

//
pragma solidity 0.8.10;




interface IUserDepositManagerV1 {
    
    
    
    
    event UserDeposit(address indexed depositor, address indexed recipient, uint256 amount);

    
    error EmptyDeposit();

    
    function deposit() external payable;

    
    
    function depositAndTransfer(address _recipient) external payable;

    
    receive() external payable;

    
    fallback() external payable;
}
//
pragma solidity 0.8.10;













contract ELFeeRecipientV1 is Initializable, IELFeeRecipientV1 {
    
    function initELFeeRecipientV1(address _riverAddress) external init(0) {
        RiverAddress.set(_riverAddress);
        emit SetRiver(_riverAddress);
    }

    
    function pullELFees(uint256 _maxAmount) external {
        address river = RiverAddress.get();
        if (msg.sender != river) {
            revert LibErrors.Unauthorized(msg.sender);
        }
        uint256 amount = LibUint256.min(_maxAmount, address(this).balance);

        IRiverV1(payable(river)).sendELFees{value: amount}();
    }

    
    receive() external payable {
        this;
    }

    
    fallback() external payable {
        revert InvalidCall();
    }
}

//
pragma solidity 0.8.10;









interface IRiverV1 is IConsensusLayerDepositManagerV1, IUserDepositManagerV1, ISharesManagerV1, IOracleManagerV1 {
    
    
    event PulledELFees(uint256 amount);

    
    
    event SetELFeeRecipient(address indexed elFeeRecipient);

    
    
    event SetCollector(address indexed collector);

    
    
    event SetAllowlist(address indexed allowlist);

    
    
    event SetGlobalFee(uint256 fee);

    
    
    event SetOperatorsRegistry(address indexed operatorRegistry);

    
    
    
    
    
    
    event RewardsEarned(
        address indexed _collector,
        uint256 _oldTotalUnderlyingBalance,
        uint256 _oldTotalSupply,
        uint256 _newTotalUnderlyingBalance,
        uint256 _newTotalSupply
    );

    
    error ZeroMintedShares();

    
    
    error Denied(address account);

    
    
    
    
    
    
    
    
    
    
    function initRiverV1(
        address _depositContractAddress,
        address _elFeeRecipientAddress,
        bytes32 _withdrawalCredentials,
        address _oracleAddress,
        address _systemAdministratorAddress,
        address _allowlistAddress,
        address _operatorRegistryAddress,
        address _collectorAddress,
        uint256 _globalFee
    ) external;

    
    
    function getGlobalFee() external view returns (uint256);

    
    
    function getAllowlist() external view returns (address);

    
    
    function getCollector() external view returns (address);

    
    
    function getELFeeRecipient() external view returns (address);

    
    
    function getOperatorsRegistry() external view returns (address);

    
    
    function setGlobalFee(uint256 newFee) external;

    
    
    function setAllowlist(address _newAllowlist) external;

    
    
    function setCollector(address _newCollector) external;

    
    
    function setELFeeRecipient(address _newELFeeRecipient) external;

    
    function sendELFees() external payable;
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
