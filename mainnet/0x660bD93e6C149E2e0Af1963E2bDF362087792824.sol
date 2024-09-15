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



















abstract contract ConsensusLayerDepositManagerV1 is IConsensusLayerDepositManagerV1 {
    
    uint256 public constant PUBLIC_KEY_LENGTH = 48;
    
    uint256 public constant SIGNATURE_LENGTH = 96;
    
    uint256 public constant DEPOSIT_SIZE = 32 ether;

    
    
    function _getRiverAdmin() internal view virtual returns (address);

    
    modifier onlyAdmin_CDMV1() {
        if (msg.sender != _getRiverAdmin()) {
            revert LibErrors.Unauthorized(msg.sender);
        }
        _;
    }

    
    
    
    function _getNextValidators(uint256 _keyCount)
        internal
        virtual
        returns (bytes[] memory publicKeys, bytes[] memory signatures);

    
    
    
    function initConsensusLayerDepositManagerV1(address _depositContractAddress, bytes32 _withdrawalCredentials)
        internal
    {
        DepositContractAddress.set(_depositContractAddress);
        emit SetDepositContractAddress(_depositContractAddress);

        WithdrawalCredentials.set(_withdrawalCredentials);
        emit SetWithdrawalCredentials(_withdrawalCredentials);
    }

    
    function getBalanceToDeposit() external view returns (uint256) {
        return BalanceToDeposit.get();
    }

    
    function getWithdrawalCredentials() external view returns (bytes32) {
        return WithdrawalCredentials.get();
    }

    
    function getDepositedValidatorCount() external view returns (uint256) {
        return DepositedValidatorCount.get();
    }

    
    function depositToConsensusLayer(uint256 _maxCount) external onlyAdmin_CDMV1 {
        uint256 balanceToDeposit = BalanceToDeposit.get();
        uint256 keyToDepositCount = LibUint256.min(balanceToDeposit / DEPOSIT_SIZE, _maxCount);

        if (keyToDepositCount == 0) {
            revert NotEnoughFunds();
        }

        (bytes[] memory publicKeys, bytes[] memory signatures) = _getNextValidators(keyToDepositCount);

        uint256 receivedPublicKeyCount = publicKeys.length;

        if (receivedPublicKeyCount == 0) {
            revert NoAvailableValidatorKeys();
        }

        if (receivedPublicKeyCount > keyToDepositCount) {
            revert InvalidPublicKeyCount();
        }

        uint256 receivedSignatureCount = signatures.length;

        if (receivedSignatureCount != receivedPublicKeyCount) {
            revert InvalidSignatureCount();
        }

        bytes32 withdrawalCredentials = WithdrawalCredentials.get();

        if (withdrawalCredentials == 0) {
            revert InvalidWithdrawalCredentials();
        }

        for (uint256 idx = 0; idx < receivedPublicKeyCount;) {
            _depositValidator(publicKeys[idx], signatures[idx], withdrawalCredentials);
            unchecked {
                ++idx;
            }
        }
        BalanceToDeposit.set(balanceToDeposit - DEPOSIT_SIZE * receivedPublicKeyCount);
        DepositedValidatorCount.set(DepositedValidatorCount.get() + receivedPublicKeyCount);
    }

    
    
    
    
    function _depositValidator(bytes memory _publicKey, bytes memory _signature, bytes32 _withdrawalCredentials)
        internal
    {
        if (_publicKey.length != PUBLIC_KEY_LENGTH) {
            revert InconsistentPublicKeys();
        }

        if (_signature.length != SIGNATURE_LENGTH) {
            revert InconsistentSignatures();
        }
        uint256 value = DEPOSIT_SIZE;

        uint256 depositAmount = value / 1 gwei;

        bytes32 pubkeyRoot = sha256(bytes.concat(_publicKey, bytes16(0)));
        bytes32 signatureRoot = sha256(
            bytes.concat(
                sha256(LibBytes.slice(_signature, 0, 64)),
                sha256(bytes.concat(LibBytes.slice(_signature, 64, SIGNATURE_LENGTH - 64), bytes32(0)))
            )
        );

        bytes32 depositDataRoot = sha256(
            bytes.concat(
                sha256(bytes.concat(pubkeyRoot, _withdrawalCredentials)),
                sha256(bytes.concat(bytes32(LibUint256.toLittleEndian64(depositAmount)), signatureRoot))
            )
        );

        uint256 targetBalance = address(this).balance - value;

        IDepositContract(DepositContractAddress.get()).deposit{value: value}(
            _publicKey, abi.encodePacked(_withdrawalCredentials), _signature, depositDataRoot
        );
        if (address(this).balance != targetBalance) {
            revert ErrorOnDeposit();
        }
        emit FundedValidatorKey(_publicKey);
    }
}

//
pragma solidity 0.8.10;
















abstract contract OracleManagerV1 is IOracleManagerV1 {
    
    
    
    function _onEarnings(uint256 _profits) internal virtual;

    
    
    
    
    function _pullELFees(uint256 _max) internal virtual returns (uint256);

    
    
    
    function _getRiverAdmin() internal view virtual returns (address);

    
    modifier onlyAdmin_OMV1() {
        if (msg.sender != _getRiverAdmin()) {
            revert LibErrors.Unauthorized(msg.sender);
        }
        _;
    }

    
    
    function initOracleManagerV1(address _oracle) internal {
        OracleAddress.set(_oracle);
        emit SetOracle(_oracle);
    }

    
    function getOracle() external view returns (address) {
        return OracleAddress.get();
    }

    
    function getCLValidatorTotalBalance() external view returns (uint256) {
        return CLValidatorTotalBalance.get();
    }

    
    function getCLValidatorCount() external view returns (uint256) {
        return CLValidatorCount.get();
    }

    
    function setOracle(address _oracleAddress) external onlyAdmin_OMV1 {
        OracleAddress.set(_oracleAddress);
        emit SetOracle(_oracleAddress);
    }

    
    function setConsensusLayerData(
        uint256 _validatorCount,
        uint256 _validatorTotalBalance,
        bytes32 _roundId,
        uint256 _maxIncrease
    ) external {
        if (msg.sender != OracleAddress.get()) {
            revert LibErrors.Unauthorized(msg.sender);
        }

        if (_validatorCount > DepositedValidatorCount.get()) {
            revert InvalidValidatorCountReport(_validatorCount, DepositedValidatorCount.get());
        }

        uint256 newValidators = _validatorCount - CLValidatorCount.get();
        uint256 previousValidatorTotalBalance = CLValidatorTotalBalance.get() + (newValidators * 32 ether);

        CLValidatorTotalBalance.set(_validatorTotalBalance);
        CLValidatorCount.set(_validatorCount);
        LastOracleRoundId.set(_roundId);

        uint256 executionLayerFees;

        // if there's a margin left for pulling the execution layer fees that would leave our delta under the allowed maxIncrease value, do it
        if ((_maxIncrease + previousValidatorTotalBalance) > _validatorTotalBalance) {
            executionLayerFees = _pullELFees((_maxIncrease + previousValidatorTotalBalance) - _validatorTotalBalance);
        }

        if (previousValidatorTotalBalance < _validatorTotalBalance + executionLayerFees) {
            _onEarnings((_validatorTotalBalance + executionLayerFees) - previousValidatorTotalBalance);
        }

        emit ConsensusLayerDataUpdate(_validatorCount, _validatorTotalBalance, _roundId);
    }
}

//
pragma solidity 0.8.10;












abstract contract SharesManagerV1 is ISharesManagerV1 {
    
    
    
    
    function _onTransfer(address _from, address _to) internal view virtual;

    
    
    
    function _assetBalance() internal view virtual returns (uint256);

    
    
    
    modifier transferAllowed(address _from, address _to) {
        _onTransfer(_from, _to);
        _;
    }

    
    
    modifier isNotZero(uint256 _value) {
        if (_value == 0) {
            revert NullTransfer();
        }
        _;
    }

    
    
    
    modifier hasFunds(address _owner, uint256 _value) {
        if (_balanceOf(_owner) < _value) {
            revert BalanceTooLow();
        }
        _;
    }

    
    function name() external pure returns (string memory) {
        return "Liquid Staked ETH";
    }

    
    function symbol() external pure returns (string memory) {
        return "LsETH";
    }

    
    function decimals() external pure returns (uint8) {
        return 18;
    }

    
    function totalSupply() external view returns (uint256) {
        return _totalSupply();
    }

    
    function totalUnderlyingSupply() external view returns (uint256) {
        return _assetBalance();
    }

    
    function balanceOf(address _owner) external view returns (uint256) {
        return _balanceOf(_owner);
    }

    
    function balanceOfUnderlying(address _owner) public view returns (uint256) {
        return _balanceFromShares(SharesPerOwner.get(_owner));
    }

    
    function underlyingBalanceFromShares(uint256 _shares) external view returns (uint256) {
        return _balanceFromShares(_shares);
    }

    
    function sharesFromUnderlyingBalance(uint256 _underlyingAssetAmount) external view returns (uint256) {
        return _sharesFromBalance(_underlyingAssetAmount);
    }

    
    function allowance(address _owner, address _spender) external view returns (uint256) {
        return ApprovalsPerOwner.get(_owner, _spender);
    }

    
    function transfer(address _to, uint256 _value)
        external
        transferAllowed(msg.sender, _to)
        isNotZero(_value)
        hasFunds(msg.sender, _value)
        returns (bool)
    {
        if (_to == address(0)) {
            revert UnauthorizedTransfer(msg.sender, address(0));
        }
        return _transfer(msg.sender, _to, _value);
    }

    
    function transferFrom(address _from, address _to, uint256 _value)
        external
        transferAllowed(_from, _to)
        isNotZero(_value)
        hasFunds(_from, _value)
        returns (bool)
    {
        if (_to == address(0)) {
            revert UnauthorizedTransfer(_from, address(0));
        }
        _spendAllowance(_from, _value);
        return _transfer(_from, _to, _value);
    }

    
    function approve(address _spender, uint256 _value) external returns (bool) {
        _approve(msg.sender, _spender, _value);
        return true;
    }

    
    function increaseAllowance(address _spender, uint256 _additionalValue) external returns (bool) {
        _approve(msg.sender, _spender, ApprovalsPerOwner.get(msg.sender, _spender) + _additionalValue);
        return true;
    }

    
    function decreaseAllowance(address _spender, uint256 _subtractableValue) external returns (bool) {
        _approve(msg.sender, _spender, ApprovalsPerOwner.get(msg.sender, _spender) - _subtractableValue);
        return true;
    }

    
    
    
    function _spendAllowance(address _from, uint256 _value) internal {
        uint256 currentAllowance = ApprovalsPerOwner.get(_from, msg.sender);
        if (currentAllowance < _value) {
            revert AllowanceTooLow(_from, msg.sender, currentAllowance, _value);
        }
        if (currentAllowance != type(uint256).max) {
            _approve(_from, msg.sender, currentAllowance - _value);
        }
    }

    
    
    
    
    function _approve(address _owner, address _spender, uint256 _value) internal {
        LibSanitize._notZeroAddress(_owner);
        LibSanitize._notZeroAddress(_spender);
        ApprovalsPerOwner.set(_owner, _spender, _value);
        emit Approval(_owner, _spender, _value);
    }

    
    
    function _totalSupply() internal view returns (uint256) {
        return Shares.get();
    }

    
    
    
    
    
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
        SharesPerOwner.set(_from, SharesPerOwner.get(_from) - _value);
        SharesPerOwner.set(_to, SharesPerOwner.get(_to) + _value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    
    
    
    function _balanceFromShares(uint256 _shares) internal view returns (uint256) {
        uint256 _totalSharesValue = Shares.get();

        if (_totalSharesValue == 0) {
            return 0;
        }

        return ((_shares * _assetBalance())) / _totalSharesValue;
    }

    
    
    
    function _sharesFromBalance(uint256 _balance) internal view returns (uint256) {
        uint256 _totalSharesValue = Shares.get();

        if (_totalSharesValue == 0) {
            return 0;
        }

        return (_balance * _totalSharesValue) / _assetBalance();
    }

    
    
    
    
    
    function _mintShares(address _owner, uint256 _underlyingAssetValue) internal returns (uint256 sharesToMint) {
        uint256 oldTotalAssetBalance = _assetBalance() - _underlyingAssetValue;

        if (oldTotalAssetBalance == 0) {
            sharesToMint = _underlyingAssetValue;
            _mintRawShares(_owner, _underlyingAssetValue);
        } else {
            sharesToMint = (_underlyingAssetValue * _totalSupply()) / oldTotalAssetBalance;
            _mintRawShares(_owner, sharesToMint);
        }
    }

    
    
    
    function _mintRawShares(address _owner, uint256 _value) internal {
        Shares.set(Shares.get() + _value);
        SharesPerOwner.set(_owner, SharesPerOwner.get(_owner) + _value);
        emit Transfer(address(0), _owner, _value);
    }

    
    
    
    function _balanceOf(address _owner) internal view returns (uint256) {
        return SharesPerOwner.get(_owner);
    }
}

//
pragma solidity 0.8.10;










abstract contract UserDepositManagerV1 is IUserDepositManagerV1 {
    
    
    
    
    
    function _onDeposit(address _depositor, address _recipient, uint256 _amount) internal virtual;

    
    function deposit() external payable {
        _deposit(msg.sender);
    }

    
    function depositAndTransfer(address _recipient) external payable {
        LibSanitize._notZeroAddress(_recipient);
        _deposit(_recipient);
    }

    
    receive() external payable {
        _deposit(msg.sender);
    }

    
    fallback() external payable {
        revert LibErrors.InvalidCall();
    }

    
    
    function _deposit(address _recipient) internal {
        if (msg.value == 0) {
            revert EmptyDeposit();
        }

        BalanceToDeposit.set(BalanceToDeposit.get() + msg.value);

        _onDeposit(msg.sender, _recipient, msg.value);

        emit UserDeposit(msg.sender, _recipient, msg.value);
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



































































contract RiverV1 is
    ConsensusLayerDepositManagerV1,
    UserDepositManagerV1,
    SharesManagerV1,
    OracleManagerV1,
    Initializable,
    Administrable,
    IRiverV1
{
    
    uint256 internal constant DEPOSIT_MASK = 0x1;

    
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
    ) external init(0) {
        _setAdmin(_systemAdministratorAddress);

        CollectorAddress.set(_collectorAddress);
        emit SetCollector(_collectorAddress);

        GlobalFee.set(_globalFee);
        emit SetGlobalFee(_globalFee);

        ELFeeRecipientAddress.set(_elFeeRecipientAddress);
        emit SetELFeeRecipient(_elFeeRecipientAddress);

        AllowlistAddress.set(_allowlistAddress);
        emit SetAllowlist(_allowlistAddress);

        OperatorsRegistryAddress.set(_operatorRegistryAddress);
        emit SetOperatorsRegistry(_operatorRegistryAddress);

        ConsensusLayerDepositManagerV1.initConsensusLayerDepositManagerV1(
            _depositContractAddress, _withdrawalCredentials
        );

        OracleManagerV1.initOracleManagerV1(_oracleAddress);
    }

    
    function getGlobalFee() external view returns (uint256) {
        return GlobalFee.get();
    }

    
    function getAllowlist() external view returns (address) {
        return AllowlistAddress.get();
    }

    
    function getCollector() external view returns (address) {
        return CollectorAddress.get();
    }

    
    function getELFeeRecipient() external view returns (address) {
        return ELFeeRecipientAddress.get();
    }

    
    function setGlobalFee(uint256 newFee) external onlyAdmin {
        GlobalFee.set(newFee);
        emit SetGlobalFee(newFee);
    }

    
    function setAllowlist(address _newAllowlist) external onlyAdmin {
        AllowlistAddress.set(_newAllowlist);
        emit SetAllowlist(_newAllowlist);
    }

    
    function setCollector(address _newCollector) external onlyAdmin {
        CollectorAddress.set(_newCollector);
        emit SetCollector(_newCollector);
    }

    
    function setELFeeRecipient(address _newELFeeRecipient) external onlyAdmin {
        ELFeeRecipientAddress.set(_newELFeeRecipient);
        emit SetELFeeRecipient(_newELFeeRecipient);
    }

    
    function getOperatorsRegistry() external view returns (address) {
        return OperatorsRegistryAddress.get();
    }

    
    function sendELFees() external payable {
        if (msg.sender != ELFeeRecipientAddress.get()) {
            revert LibErrors.Unauthorized(msg.sender);
        }
    }

    
    
    function _getRiverAdmin()
        internal
        view
        override (OracleManagerV1, ConsensusLayerDepositManagerV1)
        returns (address)
    {
        return Administrable._getAdmin();
    }

    
    
    
    function _onTransfer(address _from, address _to) internal view override {
        IAllowlistV1 allowlist = IAllowlistV1(AllowlistAddress.get());
        if (allowlist.isDenied(_from)) {
            revert Denied(_from);
        }
        if (allowlist.isDenied(_to)) {
            revert Denied(_to);
        }
    }

    
    
    
    function _onDeposit(address _depositor, address _recipient, uint256 _amount) internal override {
        uint256 mintedShares = SharesManagerV1._mintShares(_depositor, _amount);
        IAllowlistV1 allowlist = IAllowlistV1(AllowlistAddress.get());
        if (_depositor == _recipient) {
            allowlist.onlyAllowed(_depositor, DEPOSIT_MASK); // this call reverts if unauthorized or denied
        } else {
            allowlist.onlyAllowed(_depositor, DEPOSIT_MASK); // this call reverts if unauthorized or denied
            if (allowlist.isDenied(_recipient)) {
                revert Denied(_recipient);
            }
            _transfer(_depositor, _recipient, mintedShares);
        }
    }

    
    
    
    
    function _getNextValidators(uint256 _requestedAmount)
        internal
        override
        returns (bytes[] memory publicKeys, bytes[] memory signatures)
    {
        return IOperatorsRegistryV1(OperatorsRegistryAddress.get()).pickNextValidators(_requestedAmount);
    }

    
    
    
    function _pullELFees(uint256 _max) internal override returns (uint256) {
        address elFeeRecipient = ELFeeRecipientAddress.get();
        if (elFeeRecipient == address(0)) {
            return 0;
        }
        uint256 initialBalance = address(this).balance;
        IELFeeRecipientV1(payable(elFeeRecipient)).pullELFees(_max);
        uint256 collectedELFees = address(this).balance - initialBalance;
        BalanceToDeposit.set(BalanceToDeposit.get() + collectedELFees);
        emit PulledELFees(collectedELFees);
        return collectedELFees;
    }

    
    
    function _onEarnings(uint256 _amount) internal override {
        uint256 oldTotalSupply = _totalSupply();
        if (oldTotalSupply == 0) {
            revert ZeroMintedShares();
        }
        uint256 newTotalBalance = _assetBalance();
        uint256 globalFee = GlobalFee.get();
        uint256 numerator = _amount * oldTotalSupply * globalFee;
        uint256 denominator = (newTotalBalance * LibBasisPoints.BASIS_POINTS_MAX) - (_amount * globalFee);
        uint256 sharesToMint = denominator == 0 ? 0 : (numerator / denominator);

        if (sharesToMint > 0) {
            address collector = CollectorAddress.get();
            _mintRawShares(collector, sharesToMint);
            uint256 newTotalSupply = _totalSupply();
            uint256 oldTotalBalance = newTotalBalance - _amount;
            emit RewardsEarned(collector, oldTotalBalance, oldTotalSupply, newTotalBalance, newTotalSupply);
        }
    }

    
    
    function _assetBalance() internal view override returns (uint256) {
        uint256 clValidatorCount = CLValidatorCount.get();
        uint256 depositedValidatorCount = DepositedValidatorCount.get();
        if (clValidatorCount < depositedValidatorCount) {
            return CLValidatorTotalBalance.get() + BalanceToDeposit.get()
                + (depositedValidatorCount - clValidatorCount) * ConsensusLayerDepositManagerV1.DEPOSIT_SIZE;
        } else {
            return CLValidatorTotalBalance.get() + BalanceToDeposit.get();
        }
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



interface IDepositContract {
    
    
    
    
    
    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawalCredentials,
        bytes calldata signature,
        bytes32 depositDataRoot
    ) external payable;
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






library AllowlistAddress {
    
    bytes32 internal constant ALLOWLIST_ADDRESS_SLOT = bytes32(uint256(keccak256("river.state.allowlistAddress")) - 1);

    
    
    function get() internal view returns (address) {
        return LibUnstructuredStorage.getStorageAddress(ALLOWLIST_ADDRESS_SLOT);
    }

    
    
    function set(address _newValue) internal {
        LibSanitize._notZeroAddress(_newValue);
        LibUnstructuredStorage.setStorageAddress(ALLOWLIST_ADDRESS_SLOT, _newValue);
    }
}

//
pragma solidity 0.8.10;



library BalanceToDeposit {
    bytes32 internal constant BALANCE_TO_DEPOSIT_SLOT = bytes32(uint256(keccak256("river.state.balanceToDeposit")) - 1);

    function get() internal view returns (uint256) {
        return LibUnstructuredStorage.getStorageUint256(BALANCE_TO_DEPOSIT_SLOT);
    }

    function set(uint256 newValue) internal {
        LibUnstructuredStorage.setStorageUint256(BALANCE_TO_DEPOSIT_SLOT, newValue);
    }
}

//
pragma solidity 0.8.10;





library CLValidatorCount {
    
    bytes32 internal constant CL_VALIDATOR_COUNT_SLOT = bytes32(uint256(keccak256("river.state.clValidatorCount")) - 1);

    
    
    function get() internal view returns (uint256) {
        return LibUnstructuredStorage.getStorageUint256(CL_VALIDATOR_COUNT_SLOT);
    }

    
    
    function set(uint256 _newValue) internal {
        LibUnstructuredStorage.setStorageUint256(CL_VALIDATOR_COUNT_SLOT, _newValue);
    }
}

//
pragma solidity 0.8.10;





library CLValidatorTotalBalance {
    
    bytes32 internal constant CL_VALIDATOR_TOTAL_BALANCE_SLOT =
        bytes32(uint256(keccak256("river.state.clValidatorTotalBalance")) - 1);

    
    
    function get() internal view returns (uint256) {
        return LibUnstructuredStorage.getStorageUint256(CL_VALIDATOR_TOTAL_BALANCE_SLOT);
    }

    
    
    function set(uint256 _newValue) internal {
        LibUnstructuredStorage.setStorageUint256(CL_VALIDATOR_TOTAL_BALANCE_SLOT, _newValue);
    }
}

//
pragma solidity 0.8.10;






library CollectorAddress {
    
    bytes32 internal constant COLLECTOR_ADDRESS_SLOT = bytes32(uint256(keccak256("river.state.collectorAddress")) - 1);

    
    
    function get() internal view returns (address) {
        return LibUnstructuredStorage.getStorageAddress(COLLECTOR_ADDRESS_SLOT);
    }

    
    
    function set(address _newValue) internal {
        LibSanitize._notZeroAddress(_newValue);
        LibUnstructuredStorage.setStorageAddress(COLLECTOR_ADDRESS_SLOT, _newValue);
    }
}

//
pragma solidity 0.8.10;






library DepositContractAddress {
    
    bytes32 internal constant DEPOSIT_CONTRACT_ADDRESS_SLOT =
        bytes32(uint256(keccak256("river.state.depositContractAddress")) - 1);

    
    
    function get() internal view returns (address) {
        return LibUnstructuredStorage.getStorageAddress(DEPOSIT_CONTRACT_ADDRESS_SLOT);
    }

    
    
    function set(address _newValue) internal {
        LibSanitize._notZeroAddress(_newValue);
        LibUnstructuredStorage.setStorageAddress(DEPOSIT_CONTRACT_ADDRESS_SLOT, _newValue);
    }
}

//
pragma solidity 0.8.10;





library DepositedValidatorCount {
    
    bytes32 internal constant DEPOSITED_VALIDATOR_COUNT_SLOT =
        bytes32(uint256(keccak256("river.state.depositedValidatorCount")) - 1);

    
    
    function get() internal view returns (uint256) {
        return LibUnstructuredStorage.getStorageUint256(DEPOSITED_VALIDATOR_COUNT_SLOT);
    }

    
    
    function set(uint256 _newValue) internal {
        LibUnstructuredStorage.setStorageUint256(DEPOSITED_VALIDATOR_COUNT_SLOT, _newValue);
    }
}

//
pragma solidity 0.8.10;





library ELFeeRecipientAddress {
    
    bytes32 internal constant EL_FEE_RECIPIENT_ADDRESS =
        bytes32(uint256(keccak256("river.state.elFeeRecipientAddress")) - 1);

    
    
    function get() internal view returns (address) {
        return LibUnstructuredStorage.getStorageAddress(EL_FEE_RECIPIENT_ADDRESS);
    }

    
    
    function set(address _newValue) internal {
        LibUnstructuredStorage.setStorageAddress(EL_FEE_RECIPIENT_ADDRESS, _newValue);
    }
}

//
pragma solidity 0.8.10;






library GlobalFee {
    
    bytes32 internal constant GLOBAL_FEE_SLOT = bytes32(uint256(keccak256("river.state.globalFee")) - 1);

    
    
    function get() internal view returns (uint256) {
        return LibUnstructuredStorage.getStorageUint256(GLOBAL_FEE_SLOT);
    }

    
    
    function set(uint256 _newValue) internal {
        LibSanitize._validFee(_newValue);
        LibUnstructuredStorage.setStorageUint256(GLOBAL_FEE_SLOT, _newValue);
    }
}

//
pragma solidity 0.8.10;





library LastOracleRoundId {
    
    bytes32 internal constant LAST_ORACLE_ROUND_ID_SLOT =
        bytes32(uint256(keccak256("river.state.lastOracleRoundId")) - 1);

    
    
    function get() internal view returns (bytes32) {
        return LibUnstructuredStorage.getStorageBytes32(LAST_ORACLE_ROUND_ID_SLOT);
    }

    
    
    function set(bytes32 _newValue) internal {
        LibUnstructuredStorage.setStorageBytes32(LAST_ORACLE_ROUND_ID_SLOT, _newValue);
    }
}

//
pragma solidity 0.8.10;






library OperatorsRegistryAddress {
    
    bytes32 internal constant OPERATORS_REGISTRY_ADDRESS_SLOT =
        bytes32(uint256(keccak256("river.state.operatorsRegistryAddress")) - 1);

    
    
    function get() internal view returns (address) {
        return LibUnstructuredStorage.getStorageAddress(OPERATORS_REGISTRY_ADDRESS_SLOT);
    }

    
    
    function set(address _newValue) internal {
        LibSanitize._notZeroAddress(_newValue);
        LibUnstructuredStorage.setStorageAddress(OPERATORS_REGISTRY_ADDRESS_SLOT, _newValue);
    }
}

//
pragma solidity 0.8.10;






library OracleAddress {
    
    bytes32 internal constant ORACLE_ADDRESS_SLOT = bytes32(uint256(keccak256("river.state.oracleAddress")) - 1);

    
    
    function get() internal view returns (address) {
        return LibUnstructuredStorage.getStorageAddress(ORACLE_ADDRESS_SLOT);
    }

    
    
    function set(address _newValue) internal {
        LibSanitize._notZeroAddress(_newValue);
        LibUnstructuredStorage.setStorageAddress(ORACLE_ADDRESS_SLOT, _newValue);
    }
}

//
pragma solidity 0.8.10;





library Shares {
    
    bytes32 internal constant SHARES_SLOT = bytes32(uint256(keccak256("river.state.shares")) - 1);

    
    
    function get() internal view returns (uint256) {
        return LibUnstructuredStorage.getStorageUint256(SHARES_SLOT);
    }

    
    
    function set(uint256 _newValue) internal {
        LibUnstructuredStorage.setStorageUint256(SHARES_SLOT, _newValue);
    }
}

//
pragma solidity 0.8.10;



library SharesPerOwner {
    
    bytes32 internal constant SHARES_PER_OWNER_SLOT = bytes32(uint256(keccak256("river.state.sharesPerOwner")) - 1);

    
    struct Slot {
        
        mapping(address => uint256) value;
    }

    
    
    
    function get(address _owner) internal view returns (uint256) {
        bytes32 slot = SHARES_PER_OWNER_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        return r.value[_owner];
    }

    
    
    
    function set(address _owner, uint256 _newValue) internal {
        bytes32 slot = SHARES_PER_OWNER_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        r.value[_owner] = _newValue;
    }
}

//
pragma solidity 0.8.10;






library WithdrawalCredentials {
    
    bytes32 internal constant WITHDRAWAL_CREDENTIALS_SLOT =
        bytes32(uint256(keccak256("river.state.withdrawalCredentials")) - 1);

    
    
    function get() internal view returns (bytes32) {
        return LibUnstructuredStorage.getStorageBytes32(WITHDRAWAL_CREDENTIALS_SLOT);
    }

    
    
    function set(bytes32 _newValue) internal {
        if (_newValue == bytes32(0)) {
            revert LibErrors.InvalidArgument();
        }
        LibUnstructuredStorage.setStorageBytes32(WITHDRAWAL_CREDENTIALS_SLOT, _newValue);
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



library ApprovalsPerOwner {
    
    bytes32 internal constant APPROVALS_PER_OWNER_SLOT =
        bytes32(uint256(keccak256("river.state.approvalsPerOwner")) - 1);

    
    struct Slot {
        
        mapping(address => mapping(address => uint256)) value;
    }

    
    
    
    
    function get(address _owner, address _operator) internal view returns (uint256) {
        bytes32 slot = APPROVALS_PER_OWNER_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        return r.value[_owner][_operator];
    }

    
    
    
    
    function set(address _owner, address _operator, uint256 _newValue) internal {
        bytes32 slot = APPROVALS_PER_OWNER_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        r.value[_owner][_operator] = _newValue;
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
