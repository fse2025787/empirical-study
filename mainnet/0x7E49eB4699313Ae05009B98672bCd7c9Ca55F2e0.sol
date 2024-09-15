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
}//
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








interface IOracleV1 {
    
    
    
    
    
    event CLReported(uint256 epochId, uint128 newCLBalance, uint32 newCLValidatorCount, address oracleMember);

    
    
    event SetQuorum(uint256 newQuorum);

    
    
    event ExpectedEpochIdUpdated(uint256 epochId);

    
    
    
    
    
    event PostTotalShares(uint256 postTotalEth, uint256 prevTotalEth, uint256 timeElapsed, uint256 totalShares);

    
    
    event AddMember(address indexed member);

    
    
    event RemoveMember(address indexed member);

    
    
    
    event SetMember(address indexed oldAddress, address indexed newAddress);

    
    
    event SetRiver(address _river);

    
    
    
    
    
    event SetSpec(uint64 epochsPerFrame, uint64 slotsPerEpoch, uint64 secondsPerSlot, uint64 genesisTime);

    
    
    
    event SetBounds(uint256 annualAprUpperBound, uint256 relativeLowerBound);

    
    
    
    error EpochTooOld(uint256 providedEpochId, uint256 minExpectedEpochId);

    
    
    
    error NotFrameFirstEpochId(uint256 providedEpochId, uint256 expectedFrameFirstEpochId);

    
    
    
    error AlreadyReported(uint256 epochId, address member);

    
    
    
    
    
    error TotalValidatorBalanceIncreaseOutOfBound(
        uint256 prevTotalEth, uint256 postTotalEth, uint256 timeElapsed, uint256 annualAprUpperBound
    );

    
    
    
    
    
    error TotalValidatorBalanceDecreaseOutOfBound(
        uint256 prevTotalEth, uint256 postTotalEth, uint256 timeElapsed, uint256 relativeLowerBound
    );

    
    
    error AddressAlreadyInUse(address newAddress);

    
    
    
    
    
    
    
    
    
    function initOracleV1(
        address _river,
        address _administratorAddress,
        uint64 _epochsPerFrame,
        uint64 _slotsPerEpoch,
        uint64 _secondsPerSlot,
        uint64 _genesisTime,
        uint256 _annualAprUpperBound,
        uint256 _relativeLowerBound
    ) external;

    
    
    function getRiver() external view returns (address);

    
    
    function getTime() external view returns (uint256);

    
    
    function getExpectedEpochId() external view returns (uint256);

    
    
    
    function getMemberReportStatus(address _oracleMember) external view returns (bool);

    
    
    function getGlobalReportStatus() external view returns (uint256);

    
    
    function getReportVariantsCount() external view returns (uint256);

    
    
    
    
    
    function getReportVariant(uint256 _idx)
        external
        view
        returns (uint64 _clBalance, uint32 _clValidators, uint16 _reportCount);

    
    
    function getLastCompletedEpochId() external view returns (uint256);

    
    
    function getCurrentEpochId() external view returns (uint256);

    
    
    function getQuorum() external view returns (uint256);

    
    
    function getCLSpec() external view returns (CLSpec.CLSpecStruct memory);

    
    
    
    
    function getCurrentFrame() external view returns (uint256 _startEpochId, uint256 _startTime, uint256 _endTime);

    
    
    
    function getFrameFirstEpochId(uint256 _epochId) external view returns (uint256);

    
    
    function getReportBounds() external view returns (ReportBounds.ReportBoundsStruct memory);

    
    
    function getOracleMembers() external view returns (address[] memory);

    
    
    
    
    function isMember(address _memberAddress) external view returns (bool);

    
    
    
    
    
    function addMember(address _newOracleMember, uint256 _newQuorum) external;

    
    
    
    
    
    
    function removeMember(address _oracleMember, uint256 _newQuorum) external;

    
    
    
    
    
    
    function setMember(address _oracleMember, address _newAddress) external;

    
    
    
    
    
    
    function setCLSpec(uint64 _epochsPerFrame, uint64 _slotsPerEpoch, uint64 _secondsPerSlot, uint64 _genesisTime)
        external;

    
    
    
    
    function setReportBounds(uint256 _annualAprUpperBound, uint256 _relativeLowerBound) external;

    
    
    
    function setQuorum(uint256 _newQuorum) external;

    
    
    
    
    
    
    
    
    
    
    function reportConsensusLayerData(uint256 _epochId, uint64 _clValidatorsBalance, uint32 _clValidatorCount)
        external;
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


















contract OracleV1 is IOracleV1, Initializable, Administrable {
    
    uint256 internal constant ONE_YEAR = 365 days;

    
    uint128 internal constant DENOMINATION_OFFSET = 1e9;

    
    function initOracleV1(
        address _river,
        address _administratorAddress,
        uint64 _epochsPerFrame,
        uint64 _slotsPerEpoch,
        uint64 _secondsPerSlot,
        uint64 _genesisTime,
        uint256 _annualAprUpperBound,
        uint256 _relativeLowerBound
    ) external init(0) {
        _setAdmin(_administratorAddress);
        RiverAddress.set(_river);
        emit SetRiver(_river);
        CLSpec.set(
            CLSpec.CLSpecStruct({
                epochsPerFrame: _epochsPerFrame,
                slotsPerEpoch: _slotsPerEpoch,
                secondsPerSlot: _secondsPerSlot,
                genesisTime: _genesisTime
            })
        );
        emit SetSpec(_epochsPerFrame, _slotsPerEpoch, _secondsPerSlot, _genesisTime);
        ReportBounds.set(
            ReportBounds.ReportBoundsStruct({
                annualAprUpperBound: _annualAprUpperBound,
                relativeLowerBound: _relativeLowerBound
            })
        );
        emit SetBounds(_annualAprUpperBound, _relativeLowerBound);
        Quorum.set(0);
        emit SetQuorum(0);
    }

    
    function getRiver() external view returns (address) {
        return RiverAddress.get();
    }

    
    function getTime() external view returns (uint256) {
        return _getTime();
    }

    
    function getExpectedEpochId() external view returns (uint256) {
        return ExpectedEpochId.get();
    }

    
    function getMemberReportStatus(address _oracleMember) external view returns (bool) {
        int256 memberIndex = OracleMembers.indexOf(_oracleMember);
        return memberIndex != -1 && ReportsPositions.get(uint256(memberIndex));
    }

    
    function getGlobalReportStatus() external view returns (uint256) {
        return ReportsPositions.getRaw();
    }

    
    function getReportVariantsCount() external view returns (uint256) {
        return ReportsVariants.get().length;
    }

    
    function getReportVariant(uint256 _idx)
        external
        view
        returns (uint64 _clBalance, uint32 _clValidators, uint16 _reportCount)
    {
        uint256 report = ReportsVariants.get()[_idx];
        (_clBalance, _clValidators) = _decodeReport(report);
        _reportCount = _getReportCount(report);
    }

    
    function getLastCompletedEpochId() external view returns (uint256) {
        return LastEpochId.get();
    }

    
    function getCurrentEpochId() external view returns (uint256) {
        CLSpec.CLSpecStruct memory clSpec = CLSpec.get();
        return _getCurrentEpochId(clSpec);
    }

    
    function getQuorum() external view returns (uint256) {
        return Quorum.get();
    }

    
    function getCLSpec() external view returns (CLSpec.CLSpecStruct memory) {
        return CLSpec.get();
    }

    
    function getCurrentFrame() external view returns (uint256 _startEpochId, uint256 _startTime, uint256 _endTime) {
        CLSpec.CLSpecStruct memory clSpec = CLSpec.get();
        _startEpochId = _getFrameFirstEpochId(_getCurrentEpochId(clSpec), clSpec);
        uint256 secondsPerEpoch = clSpec.secondsPerSlot * clSpec.slotsPerEpoch;
        _startTime = clSpec.genesisTime + _startEpochId * secondsPerEpoch;
        _endTime = _startTime + secondsPerEpoch * clSpec.epochsPerFrame - 1;
    }

    
    function getFrameFirstEpochId(uint256 _epochId) external view returns (uint256) {
        CLSpec.CLSpecStruct memory clSpec = CLSpec.get();
        return _getFrameFirstEpochId(_epochId, clSpec);
    }

    
    function getReportBounds() external view returns (ReportBounds.ReportBoundsStruct memory) {
        return ReportBounds.get();
    }

    
    function getOracleMembers() external view returns (address[] memory) {
        return OracleMembers.get();
    }

    
    function isMember(address _memberAddress) external view returns (bool) {
        return OracleMembers.indexOf(_memberAddress) >= 0;
    }

    
    function addMember(address _newOracleMember, uint256 _newQuorum) external onlyAdmin {
        int256 memberIdx = OracleMembers.indexOf(_newOracleMember);
        if (memberIdx >= 0) {
            revert AddressAlreadyInUse(_newOracleMember);
        }
        OracleMembers.push(_newOracleMember);
        uint256 previousQuorum = Quorum.get();
        _clearReportsAndSetQuorum(_newQuorum, previousQuorum);
        emit AddMember(_newOracleMember);
    }

    
    function removeMember(address _oracleMember, uint256 _newQuorum) external onlyAdmin {
        int256 memberIdx = OracleMembers.indexOf(_oracleMember);
        if (memberIdx < 0) {
            revert LibErrors.InvalidCall();
        }
        OracleMembers.deleteItem(uint256(memberIdx));
        uint256 previousQuorum = Quorum.get();
        _clearReportsAndSetQuorum(_newQuorum, previousQuorum);
        emit RemoveMember(_oracleMember);
    }

    
    function setMember(address _oracleMember, address _newAddress) external onlyAdmin {
        LibSanitize._notZeroAddress(_newAddress);
        if (OracleMembers.indexOf(_newAddress) >= 0) {
            revert AddressAlreadyInUse(_newAddress);
        }
        int256 memberIdx = OracleMembers.indexOf(_oracleMember);
        if (memberIdx < 0) {
            revert LibErrors.InvalidCall();
        }
        OracleMembers.set(uint256(memberIdx), _newAddress);
        emit SetMember(_oracleMember, _newAddress);
        _clearReports();
    }

    
    function setCLSpec(uint64 _epochsPerFrame, uint64 _slotsPerEpoch, uint64 _secondsPerSlot, uint64 _genesisTime)
        external
        onlyAdmin
    {
        CLSpec.set(
            CLSpec.CLSpecStruct({
                epochsPerFrame: _epochsPerFrame,
                slotsPerEpoch: _slotsPerEpoch,
                secondsPerSlot: _secondsPerSlot,
                genesisTime: _genesisTime
            })
        );
        emit SetSpec(_epochsPerFrame, _slotsPerEpoch, _secondsPerSlot, _genesisTime);
    }

    
    function setReportBounds(uint256 _annualAprUpperBound, uint256 _relativeLowerBound) external onlyAdmin {
        ReportBounds.set(
            ReportBounds.ReportBoundsStruct({
                annualAprUpperBound: _annualAprUpperBound,
                relativeLowerBound: _relativeLowerBound
            })
        );
        emit SetBounds(_annualAprUpperBound, _relativeLowerBound);
    }

    
    function setQuorum(uint256 _newQuorum) external onlyAdmin {
        uint256 previousQuorum = Quorum.get();
        if (previousQuorum == _newQuorum) {
            revert LibErrors.InvalidArgument();
        }
        _clearReportsAndSetQuorum(_newQuorum, previousQuorum);
    }

    
    function reportConsensusLayerData(uint256 _epochId, uint64 _clValidatorsBalance, uint32 _clValidatorCount)
        external
    {
        int256 memberIndex = OracleMembers.indexOf(msg.sender);
        if (memberIndex == -1) {
            revert LibErrors.Unauthorized(msg.sender);
        }

        CLSpec.CLSpecStruct memory clSpec = CLSpec.get();
        uint256 expectedEpochId = ExpectedEpochId.get();
        if (_epochId < expectedEpochId) {
            revert EpochTooOld(_epochId, expectedEpochId);
        }

        if (_epochId > expectedEpochId) {
            uint256 frameFirstEpochId = _getFrameFirstEpochId(_getCurrentEpochId(clSpec), clSpec);
            if (_epochId != frameFirstEpochId) {
                revert NotFrameFirstEpochId(_epochId, frameFirstEpochId);
            }
            _clearReportsAndUpdateExpectedEpochId(_epochId);
        }

        if (ReportsPositions.get(uint256(memberIndex))) {
            revert AlreadyReported(_epochId, msg.sender);
        }
        ReportsPositions.register(uint256(memberIndex));

        uint128 clBalanceEth1 = DENOMINATION_OFFSET * uint128(_clValidatorsBalance);
        emit CLReported(_epochId, clBalanceEth1, _clValidatorCount, msg.sender);

        uint256 report = _encodeReport(_clValidatorsBalance, _clValidatorCount);
        int256 reportIndex = ReportsVariants.indexOfReport(report);
        uint256 quorum = Quorum.get();

        if (reportIndex >= 0) {
            uint256 registeredReport = ReportsVariants.get()[uint256(reportIndex)];
            if (_getReportCount(registeredReport) + 1 >= quorum) {
                _pushToRiver(_epochId, clBalanceEth1, _clValidatorCount, clSpec);
            } else {
                ReportsVariants.set(uint256(reportIndex), registeredReport + 1);
            }
        } else {
            if (quorum == 1) {
                _pushToRiver(_epochId, clBalanceEth1, _clValidatorCount, clSpec);
            } else {
                ReportsVariants.push(report + 1);
            }
        }
    }

    
    
    
    
    
    
    
    function _clearReportsAndSetQuorum(uint256 _newQuorum, uint256 _previousQuorum) internal {
        uint256 memberCount = OracleMembers.get().length;
        if ((_newQuorum == 0 && memberCount > 0) || _newQuorum > memberCount) {
            revert LibErrors.InvalidArgument();
        }
        _clearReports();
        if (_newQuorum != _previousQuorum) {
            Quorum.set(_newQuorum);
            emit SetQuorum(_newQuorum);
        }
    }

    
    
    function _getTime() internal view returns (uint256) {
        return block.timestamp; // solhint-disable-line not-rely-on-time
    }

    
    
    
    function _getCurrentEpochId(CLSpec.CLSpecStruct memory _clSpec) internal view returns (uint256) {
        return (_getTime() - _clSpec.genesisTime) / (_clSpec.slotsPerEpoch * _clSpec.secondsPerSlot);
    }

    
    
    
    
    function _getFrameFirstEpochId(uint256 _epochId, CLSpec.CLSpecStruct memory _clSpec)
        internal
        pure
        returns (uint256)
    {
        return (_epochId / _clSpec.epochsPerFrame) * _clSpec.epochsPerFrame;
    }

    
    
    function _clearReportsAndUpdateExpectedEpochId(uint256 _epochId) internal {
        _clearReports();
        ExpectedEpochId.set(_epochId);
        emit ExpectedEpochIdUpdated(_epochId);
    }

    
    function _clearReports() internal {
        ReportsPositions.clear();
        ReportsVariants.clear();
    }

    
    
    
    
    function _encodeReport(uint64 _clBalance, uint32 _clValidators) internal pure returns (uint256) {
        return (uint256(_clBalance) << 48) | (uint256(_clValidators) << 16);
    }

    
    
    function _decodeReport(uint256 _value) internal pure returns (uint64 _clBalance, uint32 _clValidators) {
        _clBalance = uint64(_value >> 48);
        _clValidators = uint32(_value >> 16);
    }

    
    
    
    function _getReportCount(uint256 _report) internal pure returns (uint16) {
        return uint16(_report);
    }

    
    
    
    
    function _maxIncrease(uint256 _prevTotalEth, uint256 _timeElapsed) internal view returns (uint256) {
        uint256 annualAprUpperBound = ReportBounds.get().annualAprUpperBound;
        return (_prevTotalEth * annualAprUpperBound * _timeElapsed) / (LibBasisPoints.BASIS_POINTS_MAX * ONE_YEAR);
    }

    
    
    
    
    function _sanityChecks(uint256 _postTotalEth, uint256 _prevTotalEth, uint256 _timeElapsed) internal view {
        if (_postTotalEth >= _prevTotalEth) {
            // increase                 = _postTotalPooledEther - _preTotalPooledEther,
            // relativeIncrease         = increase / _preTotalPooledEther,
            // annualRelativeIncrease   = relativeIncrease / (timeElapsed / 365 days),
            // annualRelativeIncreaseBp = annualRelativeIncrease * 10000, in basis points 0.01% (1e-4)
            uint256 annualAprUpperBound = ReportBounds.get().annualAprUpperBound;
            // check that annualRelativeIncreaseBp <= allowedAnnualRelativeIncreaseBp
            if (
                LibBasisPoints.BASIS_POINTS_MAX * ONE_YEAR * (_postTotalEth - _prevTotalEth)
                    > annualAprUpperBound * _prevTotalEth * _timeElapsed
            ) {
                revert TotalValidatorBalanceIncreaseOutOfBound(
                    _prevTotalEth, _postTotalEth, _timeElapsed, annualAprUpperBound
                );
            }
        } else {
            // decrease           = _preTotalPooledEther - _postTotalPooledEther
            // relativeDecrease   = decrease / _preTotalPooledEther
            // relativeDecreaseBp = relativeDecrease * 10000, in basis points 0.01% (1e-4)
            uint256 relativeLowerBound = ReportBounds.get().relativeLowerBound;
            // check that relativeDecreaseBp <= allowedRelativeDecreaseBp
            if (LibBasisPoints.BASIS_POINTS_MAX * (_prevTotalEth - _postTotalEth) > relativeLowerBound * _prevTotalEth)
            {
                revert TotalValidatorBalanceDecreaseOutOfBound(
                    _prevTotalEth, _postTotalEth, _timeElapsed, relativeLowerBound
                );
            }
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    function _pushToRiver(
        uint256 _epochId,
        uint128 _totalBalance,
        uint32 _validatorCount,
        CLSpec.CLSpecStruct memory _clSpec
    ) internal {
        _clearReportsAndUpdateExpectedEpochId(_epochId + _clSpec.epochsPerFrame);

        IRiverV1 river = IRiverV1(payable(RiverAddress.get()));
        uint256 prevTotalEth = river.totalUnderlyingSupply();
        uint256 timeElapsed = (_epochId - LastEpochId.get()) * _clSpec.slotsPerEpoch * _clSpec.secondsPerSlot;
        uint256 maxIncrease = _maxIncrease(prevTotalEth, timeElapsed);
        river.setConsensusLayerData(_validatorCount, _totalBalance, bytes32(_epochId), maxIncrease);
        uint256 postTotalEth = river.totalUnderlyingSupply();

        _sanityChecks(postTotalEth, prevTotalEth, timeElapsed);
        LastEpochId.set(_epochId);

        emit PostTotalShares(postTotalEth, prevTotalEth, timeElapsed, river.totalSupply());
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



library CLSpec {
    
    bytes32 internal constant CL_SPEC_SLOT = bytes32(uint256(keccak256("river.state.clSpec")) - 1);

    
    struct CLSpecStruct {
        
        uint64 epochsPerFrame;
        
        uint64 slotsPerEpoch;
        
        uint64 secondsPerSlot;
        
        uint64 genesisTime;
    }

    
    struct Slot {
        
        CLSpecStruct value;
    }

    
    
    function get() internal view returns (CLSpecStruct memory) {
        bytes32 slot = CL_SPEC_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        return r.value;
    }

    
    
    function set(CLSpecStruct memory _newCLSpec) internal {
        bytes32 slot = CL_SPEC_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        r.value = _newCLSpec;
    }
}

//
pragma solidity 0.8.10;





library ExpectedEpochId {
    
    bytes32 internal constant EXPECTED_EPOCH_ID_SLOT = bytes32(uint256(keccak256("river.state.expectedEpochId")) - 1);

    
    
    function get() internal view returns (uint256) {
        return LibUnstructuredStorage.getStorageUint256(EXPECTED_EPOCH_ID_SLOT);
    }

    
    
    function set(uint256 _newValue) internal {
        LibUnstructuredStorage.setStorageUint256(EXPECTED_EPOCH_ID_SLOT, _newValue);
    }
}

//
pragma solidity 0.8.10;





library LastEpochId {
    
    bytes32 internal constant LAST_EPOCH_ID_SLOT = bytes32(uint256(keccak256("river.state.lastEpochId")) - 1);

    
    
    function get() internal view returns (uint256) {
        return LibUnstructuredStorage.getStorageUint256(LAST_EPOCH_ID_SLOT);
    }

    
    
    function set(uint256 _newValue) internal {
        LibUnstructuredStorage.setStorageUint256(LAST_EPOCH_ID_SLOT, _newValue);
    }
}

//
pragma solidity 0.8.10;






library OracleMembers {
    
    bytes32 internal constant ORACLE_MEMBERS_SLOT = bytes32(uint256(keccak256("river.state.oracleMembers")) - 1);

    
    struct Slot {
        
        address[] value;
    }

    
    
    function get() internal view returns (address[] memory) {
        bytes32 slot = ORACLE_MEMBERS_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        return r.value;
    }

    
    
    function push(address _newOracleMember) internal {
        LibSanitize._notZeroAddress(_newOracleMember);

        bytes32 slot = ORACLE_MEMBERS_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        r.value.push(_newOracleMember);
    }

    
    
    
    function set(uint256 _index, address _newOracleAddress) internal {
        bytes32 slot = ORACLE_MEMBERS_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        r.value[_index] = _newOracleAddress;
    }

    
    
    
    function indexOf(address _memberAddress) internal view returns (int256) {
        bytes32 slot = ORACLE_MEMBERS_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        for (uint256 idx = 0; idx < r.value.length;) {
            if (r.value[idx] == _memberAddress) {
                return int256(idx);
            }
            unchecked {
                ++idx;
            }
        }

        return int256(-1);
    }

    
    
    function deleteItem(uint256 _idx) internal {
        bytes32 slot = ORACLE_MEMBERS_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        uint256 lastIdx = r.value.length - 1;
        if (lastIdx != _idx) {
            r.value[_idx] = r.value[lastIdx];
        }

        r.value.pop();
    }
}

//
pragma solidity 0.8.10;





library Quorum {
    
    bytes32 internal constant QUORUM_SLOT = bytes32(uint256(keccak256("river.state.quorum")) - 1);

    
    
    function get() internal view returns (uint256) {
        return LibUnstructuredStorage.getStorageUint256(QUORUM_SLOT);
    }

    
    
    function set(uint256 _newValue) internal {
        return LibUnstructuredStorage.setStorageUint256(QUORUM_SLOT, _newValue);
    }
}

//
pragma solidity 0.8.10;



library ReportBounds {
    
    bytes32 internal constant REPORT_BOUNDS_SLOT = bytes32(uint256(keccak256("river.state.reportBounds")) - 1);

    
    struct ReportBoundsStruct {
        
        uint256 annualAprUpperBound;
        
        uint256 relativeLowerBound;
    }

    
    struct Slot {
        
        ReportBoundsStruct value;
    }

    
    
    function get() internal view returns (ReportBoundsStruct memory) {
        bytes32 slot = REPORT_BOUNDS_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        return r.value;
    }

    
    
    function set(ReportBoundsStruct memory _newReportBounds) internal {
        bytes32 slot = REPORT_BOUNDS_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        r.value = _newReportBounds;
    }
}

//
pragma solidity 0.8.10;






library ReportsPositions {
    
    bytes32 internal constant REPORTS_POSITIONS_SLOT = bytes32(uint256(keccak256("river.state.reportsPositions")) - 1);

    
    
    
    function get(uint256 _idx) internal view returns (bool) {
        uint256 mask = 1 << _idx;
        return LibUnstructuredStorage.getStorageUint256(REPORTS_POSITIONS_SLOT) & mask == mask;
    }

    
    
    function getRaw() internal view returns (uint256) {
        return LibUnstructuredStorage.getStorageUint256(REPORTS_POSITIONS_SLOT);
    }

    
    
    function register(uint256 _idx) internal {
        uint256 mask = 1 << _idx;
        return LibUnstructuredStorage.setStorageUint256(
            REPORTS_POSITIONS_SLOT, LibUnstructuredStorage.getStorageUint256(REPORTS_POSITIONS_SLOT) | mask
        );
    }

    
    function clear() internal {
        return LibUnstructuredStorage.setStorageUint256(REPORTS_POSITIONS_SLOT, 0);
    }
}

//
pragma solidity 0.8.10;



library ReportsVariants {
    
    bytes32 internal constant REPORTS_VARIANTS_SLOT = bytes32(uint256(keccak256("river.state.reportsVariants")) - 1);

    
    
    
    
    
    
    
    
    
    
    
    uint256 internal constant COUNT_OUTMASK = 0xFFFFFFFFFFFFFFFFFFFFFFFF0000;

    
    struct Slot {
        
        uint256[] value;
    }

    
    
    function get() internal view returns (uint256[] memory) {
        bytes32 slot = REPORTS_VARIANTS_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        return r.value;
    }

    
    
    
    function set(uint256 _idx, uint256 _val) internal {
        bytes32 slot = REPORTS_VARIANTS_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        r.value[_idx] = _val;
    }

    
    
    function push(uint256 _variant) internal {
        bytes32 slot = REPORTS_VARIANTS_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        r.value.push(_variant);
    }

    
    
    
    function indexOfReport(uint256 _variant) internal view returns (int256) {
        bytes32 slot = REPORTS_VARIANTS_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        for (uint256 idx = 0; idx < r.value.length;) {
            if (r.value[idx] & COUNT_OUTMASK == _variant) {
                return int256(idx);
            }
            unchecked {
                ++idx;
            }
        }

        return int256(-1);
    }

    
    function clear() internal {
        bytes32 slot = REPORTS_VARIANTS_SLOT;

        Slot storage r;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            r.slot := slot
        }

        delete r.value;
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
