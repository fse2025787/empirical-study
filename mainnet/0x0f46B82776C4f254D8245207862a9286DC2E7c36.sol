// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;


// 
pragma solidity ^0.7.4;




interface IClaimingRegistry {
    enum ClaimStatus {
        CAN_CLAIM,
        UNCLAIMABLE,
        PENDING,
        AWAITING_CALCULATION,
        REJECTED_CAN_APPEAL,
        REJECTED,
        ACCEPTED
    }

    struct ClaimInfo {
        address claimer;
        address policyBookAddress;
        string evidenceURI;
        uint256 dateSubmitted;
        uint256 dateEnded;
        bool appeal;
        ClaimStatus status;
        uint256 claimAmount;
    }

    
    function anonymousVotingDuration(uint256 index) external view returns (uint256);

    
    function votingDuration(uint256 index) external view returns (uint256);

    
    function anyoneCanCalculateClaimResultAfter(uint256 index) external view returns (uint256);

    
    function canBuyNewPolicy(address buyer, address policyBookAddress)
        external
        view
        returns (bool);

    
    function submitClaim(
        address user,
        address policyBookAddress,
        string calldata evidenceURI,
        uint256 cover,
        bool appeal
    ) external returns (uint256);

    
    function claimExists(uint256 index) external view returns (bool);

    
    function claimSubmittedTime(uint256 index) external view returns (uint256);

    
    function claimEndTime(uint256 index) external view returns (uint256);

    
    function isClaimAnonymouslyVotable(uint256 index) external view returns (bool);

    
    function isClaimExposablyVotable(uint256 index) external view returns (bool);

    
    function isClaimVotable(uint256 index) external view returns (bool);

    
    function canClaimBeCalculatedByAnyone(uint256 index) external view returns (bool);

    
    function isClaimPending(uint256 index) external view returns (bool);

    
    function countPolicyClaimerClaims(address user) external view returns (uint256);

    
    function countPendingClaims() external view returns (uint256);

    
    function countClaims() external view returns (uint256);

    
    function claimOfOwnerIndexAt(address claimer, uint256 orderIndex)
        external
        view
        returns (uint256);

    
    function pendingClaimIndexAt(uint256 orderIndex) external view returns (uint256);

    
    function claimIndexAt(uint256 orderIndex) external view returns (uint256);

    
    function claimIndex(address claimer, address policyBookAddress)
        external
        view
        returns (uint256);

    
    function isClaimAppeal(uint256 index) external view returns (bool);

    
    function policyStatus(address claimer, address policyBookAddress)
        external
        view
        returns (ClaimStatus);

    
    function claimStatus(uint256 index) external view returns (ClaimStatus);

    
    function claimOwner(uint256 index) external view returns (address);

    
    function claimPolicyBook(uint256 index) external view returns (address);

    
    function claimInfo(uint256 index) external view returns (ClaimInfo memory _claimInfo);

    function getAllPendingClaimsAmount() external view returns (uint256 _totalClaimsAmount);

    function getClaimableAmounts(uint256[] memory _claimIndexes) external view returns (uint256);

    
    function acceptClaim(uint256 index) external;

    
    function rejectClaim(uint256 index) external;

    
    ///         or offensive.
    
    
    
    function updateImageUriOfClaim(uint256 _claimIndex, string calldata _newEvidenceURI) external;
}

// 
pragma solidity ^0.7.4;



abstract contract AbstractDependant {
    
    bytes32 private constant _INJECTOR_SLOT =
        0xd6b8f2e074594ceb05d47c27386969754b6ad0c15e5eb8f691399cd0be980e76;

    modifier onlyInjectorOrZero() {
        address _injector = injector();

        require(_injector == address(0) || _injector == msg.sender, "Dependant: Not an injector");
        _;
    }

    function setInjector(address _injector) external onlyInjectorOrZero {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            sstore(slot, _injector)
        }
    }

    
    function setDependencies(IContractsRegistry) external virtual;

    function injector() public view returns (address _injector) {
        bytes32 slot = _INJECTOR_SLOT;

        assembly {
            _injector := sload(slot)
        }
    }
}

// 

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 * 
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 * 
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// 
pragma solidity ^0.7.4;















contract ClaimingRegistry is IClaimingRegistry, Initializable, AbstractDependant {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 internal constant ANONYMOUS_VOTING_DURATION_CONTRACT = 1 weeks;
    uint256 internal constant ANONYMOUS_VOTING_DURATION_EXCHANGE = 90 days;

    uint256 internal constant EXPOSE_VOTE_DURATION = 1 weeks;
    uint256 internal constant PRIVATE_CLAIM_DURATION = 3 days;

    IPolicyRegistry public policyRegistry;
    address public claimVotingAddress;

    mapping(address => EnumerableSet.UintSet) internal _myClaims; // claimer -> claim indexes

    mapping(address => mapping(address => uint256)) internal _allClaimsToIndex; // book -> claimer -> index

    mapping(uint256 => ClaimInfo) internal _allClaimsByIndexInfo; // index -> info

    EnumerableSet.UintSet internal _pendingClaimsIndexes;
    EnumerableSet.UintSet internal _allClaimsIndexes;

    uint256 private _claimIndex;

    address internal policyBookAdminAddress;

    ICapitalPool public capitalPool;

    event AppealPending(address claimer, address policyBookAddress, uint256 claimIndex);
    event ClaimPending(address claimer, address policyBookAddress, uint256 claimIndex);
    event ClaimAccepted(
        address claimer,
        address policyBookAddress,
        uint256 claimAmount,
        uint256 claimIndex
    );
    event ClaimRejected(address claimer, address policyBookAddress, uint256 claimIndex);
    event AppealRejected(address claimer, address policyBookAddress, uint256 claimIndex);

    modifier onlyClaimVoting() {
        require(
            claimVotingAddress == msg.sender,
            "ClaimingRegistry: Caller is not a ClaimVoting contract"
        );
        _;
    }

    modifier onlyPolicyBookAdmin() {
        require(
            policyBookAdminAddress == msg.sender,
            "ClaimingRegistry: Caller is not a PolicyBookAdmin"
        );
        _;
    }

    modifier withExistingClaim(uint256 index) {
        require(claimExists(index), "ClaimingRegistry: This claim doesn't exist");
        _;
    }

    function __ClaimingRegistry_init() external initializer {
        _claimIndex = 1;
    }

    function setDependencies(IContractsRegistry _contractsRegistry)
        external
        override
        onlyInjectorOrZero
    {
        policyRegistry = IPolicyRegistry(_contractsRegistry.getPolicyRegistryContract());
        claimVotingAddress = _contractsRegistry.getClaimVotingContract();
        policyBookAdminAddress = _contractsRegistry.getPolicyBookAdminContract();
        capitalPool = ICapitalPool(_contractsRegistry.getCapitalPoolContract());
    }

    function _isClaimAwaitingCalculation(uint256 index)
        internal
        view
        withExistingClaim(index)
        returns (bool)
    {
        return (_allClaimsByIndexInfo[index].status == ClaimStatus.PENDING &&
            _allClaimsByIndexInfo[index].dateSubmitted.add(votingDuration(index)) <=
            block.timestamp);
    }

    function _isClaimAppealExpired(uint256 index)
        internal
        view
        withExistingClaim(index)
        returns (bool)
    {
        return (_allClaimsByIndexInfo[index].status == ClaimStatus.REJECTED_CAN_APPEAL &&
            _allClaimsByIndexInfo[index].dateEnded.add(policyRegistry.STILL_CLAIMABLE_FOR()) <=
            block.timestamp);
    }

    function anonymousVotingDuration(uint256 index)
        public
        view
        override
        withExistingClaim(index)
        returns (uint256)
    {
        return
            IPolicyBook(_allClaimsByIndexInfo[index].policyBookAddress).contractType() ==
                IPolicyBookFabric.ContractType.EXCHANGE
                ? ANONYMOUS_VOTING_DURATION_EXCHANGE
                : ANONYMOUS_VOTING_DURATION_CONTRACT;
    }

    function votingDuration(uint256 index) public view override returns (uint256) {
        return anonymousVotingDuration(index).add(EXPOSE_VOTE_DURATION);
    }

    function anyoneCanCalculateClaimResultAfter(uint256 index)
        public
        view
        override
        returns (uint256)
    {
        return votingDuration(index).add(PRIVATE_CLAIM_DURATION);
    }

    function canBuyNewPolicy(address buyer, address policyBookAddress)
        external
        view
        override
        returns (bool)
    {
        uint256 index = _allClaimsToIndex[policyBookAddress][buyer];

        return
            !claimExists(index) ||
            (!_pendingClaimsIndexes.contains(index) &&
                claimStatus(index) != ClaimStatus.REJECTED_CAN_APPEAL);
    }

    function submitClaim(
        address claimer,
        address policyBookAddress,
        string calldata evidenceURI,
        uint256 cover,
        bool appeal
    ) external override onlyClaimVoting returns (uint256 _newClaimIndex) {
        uint256 index = _allClaimsToIndex[policyBookAddress][claimer];
        ClaimStatus status =
            _myClaims[claimer].contains(index) ? claimStatus(index) : ClaimStatus.CAN_CLAIM;
        bool active = policyRegistry.isPolicyActive(claimer, policyBookAddress);

        /* (1) a new claim or a claim after rejected appeal (policy has to be active)
         * (2) a regular appeal (appeal should not be expired)
         * (3) a new claim cycle after expired appeal or a NEW policy when OLD one is accepted
         *     (PB shall not allow user to buy new policy when claim is pending or REJECTED_CAN_APPEAL)
         *     (policy has to be active)
         */
        require(
            (!appeal && active && status == ClaimStatus.CAN_CLAIM) ||
                (appeal && status == ClaimStatus.REJECTED_CAN_APPEAL) ||
                (!appeal &&
                    active &&
                    (status == ClaimStatus.REJECTED ||
                        (policyRegistry.policyStartTime(claimer, policyBookAddress) >
                            _allClaimsByIndexInfo[index].dateSubmitted &&
                            status == ClaimStatus.ACCEPTED))),
            "ClaimingRegistry: The claimer can't submit this claim"
        );

        if (appeal) {
            _allClaimsByIndexInfo[index].status = ClaimStatus.REJECTED;
        }

        _myClaims[claimer].add(_claimIndex);

        _allClaimsToIndex[policyBookAddress][claimer] = _claimIndex;

        _allClaimsByIndexInfo[_claimIndex] = ClaimInfo(
            claimer,
            policyBookAddress,
            evidenceURI,
            block.timestamp,
            0,
            appeal,
            ClaimStatus.PENDING,
            cover
        );

        _pendingClaimsIndexes.add(_claimIndex);
        _allClaimsIndexes.add(_claimIndex);

        _newClaimIndex = _claimIndex++;

        if (!appeal) {
            emit ClaimPending(claimer, policyBookAddress, _newClaimIndex);
        } else {
            emit AppealPending(claimer, policyBookAddress, _newClaimIndex);
        }
    }

    function claimExists(uint256 index) public view override returns (bool) {
        return _allClaimsIndexes.contains(index);
    }

    function claimSubmittedTime(uint256 index) external view override returns (uint256) {
        return _allClaimsByIndexInfo[index].dateSubmitted;
    }

    function claimEndTime(uint256 index) external view override returns (uint256) {
        return _allClaimsByIndexInfo[index].dateEnded;
    }

    function isClaimAnonymouslyVotable(uint256 index) external view override returns (bool) {
        return (_pendingClaimsIndexes.contains(index) &&
            _allClaimsByIndexInfo[index].dateSubmitted.add(anonymousVotingDuration(index)) >
            block.timestamp);
    }

    function isClaimExposablyVotable(uint256 index) external view override returns (bool) {
        if (!_pendingClaimsIndexes.contains(index)) {
            return false;
        }

        uint256 dateSubmitted = _allClaimsByIndexInfo[index].dateSubmitted;
        uint256 anonymousDuration = anonymousVotingDuration(index);

        return (dateSubmitted.add(anonymousDuration.add(EXPOSE_VOTE_DURATION)) > block.timestamp &&
            dateSubmitted.add(anonymousDuration) < block.timestamp);
    }

    function isClaimVotable(uint256 index) external view override returns (bool) {
        return (_pendingClaimsIndexes.contains(index) &&
            _allClaimsByIndexInfo[index].dateSubmitted.add(votingDuration(index)) >
            block.timestamp);
    }

    function canClaimBeCalculatedByAnyone(uint256 index) external view override returns (bool) {
        return
            _allClaimsByIndexInfo[index].status == ClaimStatus.PENDING &&
            _allClaimsByIndexInfo[index].dateSubmitted.add(
                anyoneCanCalculateClaimResultAfter(index)
            ) <=
            block.timestamp;
    }

    function isClaimPending(uint256 index) external view override returns (bool) {
        return _pendingClaimsIndexes.contains(index);
    }

    function countPolicyClaimerClaims(address claimer) external view override returns (uint256) {
        return _myClaims[claimer].length();
    }

    function countPendingClaims() external view override returns (uint256) {
        return _pendingClaimsIndexes.length();
    }

    function countClaims() external view override returns (uint256) {
        return _allClaimsIndexes.length();
    }

    
    
    
    
    function claimOfOwnerIndexAt(address claimer, uint256 orderIndex)
        external
        view
        override
        returns (uint256)
    {
        return _myClaims[claimer].at(orderIndex);
    }

    function pendingClaimIndexAt(uint256 orderIndex) external view override returns (uint256) {
        return _pendingClaimsIndexes.at(orderIndex);
    }

    function claimIndexAt(uint256 orderIndex) external view override returns (uint256) {
        return _allClaimsIndexes.at(orderIndex);
    }

    function claimIndex(address claimer, address policyBookAddress)
        external
        view
        override
        returns (uint256)
    {
        return _allClaimsToIndex[policyBookAddress][claimer];
    }

    function isClaimAppeal(uint256 index) external view override returns (bool) {
        return _allClaimsByIndexInfo[index].appeal;
    }

    function policyStatus(address claimer, address policyBookAddress)
        external
        view
        override
        returns (ClaimStatus)
    {
        if (!policyRegistry.isPolicyActive(claimer, policyBookAddress)) {
            return ClaimStatus.UNCLAIMABLE;
        }

        uint256 index = _allClaimsToIndex[policyBookAddress][claimer];

        if (!_myClaims[claimer].contains(index)) {
            return ClaimStatus.CAN_CLAIM;
        }

        ClaimStatus status = claimStatus(index);
        bool newPolicyBought =
            policyRegistry.policyStartTime(claimer, policyBookAddress) >
                _allClaimsByIndexInfo[index].dateSubmitted;

        if (
            status == ClaimStatus.REJECTED || (newPolicyBought && status == ClaimStatus.ACCEPTED)
        ) {
            return ClaimStatus.CAN_CLAIM;
        }

        return status;
    }

    function claimStatus(uint256 index) public view override returns (ClaimStatus) {
        if (_isClaimAppealExpired(index)) {
            return ClaimStatus.REJECTED;
        }

        if (_isClaimAwaitingCalculation(index)) {
            return ClaimStatus.AWAITING_CALCULATION;
        }

        return _allClaimsByIndexInfo[index].status;
    }

    function claimOwner(uint256 index) external view override returns (address) {
        return _allClaimsByIndexInfo[index].claimer;
    }

    
    
    
    function claimPolicyBook(uint256 index) external view override returns (address) {
        return _allClaimsByIndexInfo[index].policyBookAddress;
    }

    
    
    
    function claimInfo(uint256 index)
        external
        view
        override
        withExistingClaim(index)
        returns (ClaimInfo memory _claimInfo)
    {
        _claimInfo = ClaimInfo(
            _allClaimsByIndexInfo[index].claimer,
            _allClaimsByIndexInfo[index].policyBookAddress,
            _allClaimsByIndexInfo[index].evidenceURI,
            _allClaimsByIndexInfo[index].dateSubmitted,
            _allClaimsByIndexInfo[index].dateEnded,
            _allClaimsByIndexInfo[index].appeal,
            claimStatus(index),
            _allClaimsByIndexInfo[index].claimAmount
        );
    }

    
    
    function getAllPendingClaimsAmount()
        external
        view
        override
        returns (uint256 _totalClaimsAmount)
    {
        uint256 index;
        for (uint256 i = 0; i < _pendingClaimsIndexes.length(); i++) {
            index = _pendingClaimsIndexes.at(i);
            
            /// + 1 hr (spare time for transaction execution time)
            if (
                block.timestamp >=
                _allClaimsByIndexInfo[index].dateSubmitted.add(votingDuration(index)).sub(
                    capitalPool.rebalanceDuration().add(60 * 60)
                )
            ) {
                _totalClaimsAmount = _totalClaimsAmount.add(
                    _allClaimsByIndexInfo[index].claimAmount
                );
            }
        }
    }

    
    
    
    function getClaimableAmounts(uint256[] memory _claimIndexes)
        external
        view
        override
        returns (uint256)
    {
        uint256 _acumulatedClaimAmount;
        for (uint256 i = 0; i < _claimIndexes.length; i++) {
            _acumulatedClaimAmount = _acumulatedClaimAmount.add(
                _allClaimsByIndexInfo[i].claimAmount
            );
        }
        return _acumulatedClaimAmount;
    }

    function _modifyClaim(uint256 index, bool accept) internal {
        require(_isClaimAwaitingCalculation(index), "ClaimingRegistry: The claim is not awaiting");

        address claimer = _allClaimsByIndexInfo[index].claimer;
        address policyBookAddress = _allClaimsByIndexInfo[index].policyBookAddress;
        uint256 claimAmount = _allClaimsByIndexInfo[index].claimAmount;

        if (accept) {
            _allClaimsByIndexInfo[index].status = ClaimStatus.ACCEPTED;

            emit ClaimAccepted(claimer, policyBookAddress, claimAmount, index);
        } else if (!_allClaimsByIndexInfo[index].appeal) {
            _allClaimsByIndexInfo[index].status = ClaimStatus.REJECTED_CAN_APPEAL;

            emit ClaimRejected(claimer, policyBookAddress, index);
        } else {
            _allClaimsByIndexInfo[index].status = ClaimStatus.REJECTED;
            delete _allClaimsToIndex[policyBookAddress][claimer];

            emit AppealRejected(claimer, policyBookAddress, index);
        }

        _allClaimsByIndexInfo[index].dateEnded = block.timestamp;

        _pendingClaimsIndexes.remove(index);
    }

    function acceptClaim(uint256 index) external override onlyClaimVoting {
        _modifyClaim(index, true);
    }

    function rejectClaim(uint256 index) external override onlyClaimVoting {
        _modifyClaim(index, false);
    }

    
    ///         or offensive.
    
    
    
    function updateImageUriOfClaim(uint256 _claimIndex, string calldata _newEvidenceURI)
        external
        override
        onlyPolicyBookAdmin
    {
        _allClaimsByIndexInfo[_claimIndex].evidenceURI = _newEvidenceURI;
    }
}

// 
pragma solidity ^0.7.4;





interface IPolicyRegistry {
    struct PolicyInfo {
        uint256 coverAmount;
        uint256 premium;
        uint256 startTime;
        uint256 endTime;
    }

    struct PolicyUserInfo {
        string symbol;
        address insuredContract;
        IPolicyBookFabric.ContractType contractType;
        uint256 coverTokens;
        uint256 startTime;
        uint256 endTime;
        uint256 paid;
    }

    function STILL_CLAIMABLE_FOR() external view returns (uint256);

    
    
    
    function getPoliciesLength(address _userAddr) external view returns (uint256);

    
    
    
    
    function policyExists(address _userAddr, address _policyBookAddr) external view returns (bool);

    
    
    
    
    function isPolicyActive(address _userAddr, address _policyBookAddr)
        external
        view
        returns (bool);

    
    function policyStartTime(address _userAddr, address _policyBookAddr)
        external
        view
        returns (uint256);

    
    function policyEndTime(address _userAddr, address _policyBookAddr)
        external
        view
        returns (uint256);

    
    
    
    
    
    
    
    function getPoliciesInfo(
        address _userAddr,
        bool _isActive,
        uint256 _offset,
        uint256 _limit
    )
        external
        view
        returns (
            uint256 _policiesCount,
            address[] memory _policyBooksArr,
            PolicyInfo[] memory _policies,
            IClaimingRegistry.ClaimStatus[] memory _policyStatuses
        );

    
    function getUsersInfo(address[] calldata _users, address[] calldata _policyBooks)
        external
        view
        returns (PolicyUserInfo[] memory _stats);

    function getPoliciesArr(address _userAddr) external view returns (address[] memory _arr);

    
    
    
    
    
    function addPolicy(
        address _userAddr,
        uint256 _coverAmount,
        uint256 _premium,
        uint256 _durationDays
    ) external;

    
    
    function removePolicy(address _userAddr) external;
}

// 
pragma solidity ^0.7.4;




interface IPolicyBookFacade {
    
    
    
    function buyPolicy(uint256 _epochsNumber, uint256 _coverTokens) external;

    
    
    
    function buyPolicyFor(
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens
    ) external;

    function policyBook() external view returns (IPolicyBook);

    function userLiquidity(address account) external view returns (uint256);

    
    function VUreinsurnacePool() external view returns (uint256);

    
    function LUreinsurnacePool() external view returns (uint256);

    
    function LUuserLeveragePool(address userLeveragePool) external view returns (uint256);

    
    function totalLeveragedLiquidity() external view returns (uint256);

    function userleveragedMPL() external view returns (uint256);

    function reinsurancePoolMPL() external view returns (uint256);

    function rebalancingThreshold() external view returns (uint256);

    function safePricingModel() external view returns (bool);

    
    
    function __PolicyBookFacade_init(
        address pbProxy,
        address liquidityProvider,
        uint256 initialDeposit
    ) external;

    
    
    
    function buyPolicyFromDistributor(
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _distributor
    ) external;

    
    
    
    
    function buyPolicyFromDistributorFor(
        address _buyer,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _distributor
    ) external;

    
    
    function addLiquidity(uint256 _liquidityAmount) external;

    
    
    
    function addLiquidityFromDistributorFor(address _user, uint256 _liquidityAmount) external;

    function addLiquidityAndStakeFor(
        address _liquidityHolderAddr,
        uint256 _liquidityAmount,
        uint256 _stakeSTBLAmount
    ) external;

    
    
    function addLiquidityAndStake(uint256 _liquidityAmount, uint256 _stakeSTBLAmount) external;

    
    function withdrawLiquidity() external;

    
    
    
    function deployLeverageFundsAfterRebalance(
        uint256 deployedAmount,
        ILeveragePortfolio.LeveragePortfolio leveragePool
    ) external;

    
    
    function deployVirtualFundsAfterRebalance(uint256 deployedAmount) external;

    
    function reevaluateProvidedLeverageStable() external;

    
    
    
    function setMPLs(uint256 _userLeverageMPL, uint256 _reinsuranceLeverageMPL) external;

    
    
    function setRebalancingThreshold(uint256 _newRebalancingThreshold) external;

    
    
    function setSafePricingModel(bool _safePricingModel) external;

    
    function getClaimApprovalAmount(address user) external view returns (uint256);

    
    
    
    function requestWithdrawal(uint256 _tokensToWithdraw) external;

    function listUserLeveragePools(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _userLeveragePools);

    function countUserLeveragePools() external view returns (uint256);

    
    function getUtilizationRatioPercentage(bool withLeverage) external view returns (uint256);
}

// 
pragma solidity ^0.7.4;

interface IPolicyBookFabric {
    enum ContractType {CONTRACT, STABLECOIN, SERVICE, EXCHANGE, VARIOUS}

    
    
    
    
    
    
    
    function create(
        address _contract,
        ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol,
        uint256 _initialDeposit,
        address _shieldMiningToken
    ) external returns (address);

    function createLeveragePools(
        address _insuranceContract,
        ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol
    ) external returns (address);
}

// 
pragma solidity ^0.7.4;






interface IPolicyBook {
    enum WithdrawalStatus {NONE, PENDING, READY, EXPIRED}

    struct PolicyHolder {
        uint256 coverTokens;
        uint256 startEpochNumber;
        uint256 endEpochNumber;
        uint256 paid;
        uint256 reinsurancePrice;
    }

    struct WithdrawalInfo {
        uint256 withdrawalAmount;
        uint256 readyToWithdrawDate;
        bool withdrawalAllowed;
    }

    struct BuyPolicyParameters {
        address buyer;
        address holder;
        uint256 epochsNumber;
        uint256 coverTokens;
        uint256 distributorFee;
        address distributor;
    }

    function policyHolders(address _holder)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

    function policyBookFacade() external view returns (IPolicyBookFacade);

    function setPolicyBookFacade(address _policyBookFacade) external;

    function EPOCH_DURATION() external view returns (uint256);

    function stblDecimals() external view returns (uint256);

    function READY_TO_WITHDRAW_PERIOD() external view returns (uint256);

    function whitelisted() external view returns (bool);

    function epochStartTime() external view returns (uint256);

    // @TODO: should we let DAO to change contract address?
    
    
    function insuranceContractAddress() external view returns (address _contract);

    
    
    function contractType() external view returns (IPolicyBookFabric.ContractType _type);

    function totalLiquidity() external view returns (uint256);

    function totalCoverTokens() external view returns (uint256);

    // 
    // function userleveragedMPL() external view returns (uint256);

    // 
    // function reinsurancePoolMPL() external view returns (uint256);

    // function bmiRewardMultiplier() external view returns (uint256);

    function withdrawalsInfo(address _userAddr)
        external
        view
        returns (
            uint256 _withdrawalAmount,
            uint256 _readyToWithdrawDate,
            bool _withdrawalAllowed
        );

    function __PolicyBook_init(
        address _insuranceContract,
        IPolicyBookFabric.ContractType _contractType,
        string calldata _description,
        string calldata _projectSymbol
    ) external;

    function whitelist(bool _whitelisted) external;

    function getEpoch(uint256 time) external view returns (uint256);

    
    function convertBMIXToSTBL(uint256 _amount) external view returns (uint256);

    
    function convertSTBLToBMIX(uint256 _amount) external view returns (uint256);

    
    function submitClaimAndInitializeVoting(string calldata evidenceURI) external;

    
    function submitAppealAndInitializeVoting(string calldata evidenceURI) external;

    
    function commitClaim(
        address claimer,
        uint256 claimAmount,
        uint256 claimEndTime,
        IClaimingRegistry.ClaimStatus status
    ) external;

    
    function forceUpdateBMICoverStakingRewardMultiplier() external;

    
    function getNewCoverAndLiquidity()
        external
        view
        returns (uint256 newTotalCoverTokens, uint256 newTotalLiquidity);

    
    
    
    
    
    
    function getPolicyPrice(
        uint256 _epochsNumber,
        uint256 _coverTokens,
        address _buyer
    )
        external
        view
        returns (
            uint256 totalSeconds,
            uint256 totalPrice,
            uint256 pricePercentage
        );

    
    
    
    
    
    
    
    function buyPolicy(
        address _buyer,
        address _holder,
        uint256 _epochsNumber,
        uint256 _coverTokens,
        uint256 _distributorFee,
        address _distributor
    ) external returns (uint256, uint256);

    function updateEpochsInfo() external;

    function secondsToEndCurrentEpoch() external view returns (uint256);

    
    
    
    function addLiquidityFor(address _liquidityHolderAddr, uint256 _liqudityAmount) external;

    
    
    
    
    
    function addLiquidity(
        address _liquidityBuyerAddr,
        address _liquidityHolderAddr,
        uint256 _liquidityAmount,
        uint256 _stakeSTBLAmount
    ) external returns (uint256);

    function getAvailableBMIXWithdrawableAmount(address _userAddr) external view returns (uint256);

    function getWithdrawalStatus(address _userAddr) external view returns (WithdrawalStatus);

    function requestWithdrawal(uint256 _tokensToWithdraw, address _user) external;

    // function requestWithdrawalWithPermit(
    //     uint256 _tokensToWithdraw,
    //     uint8 _v,
    //     bytes32 _r,
    //     bytes32 _s
    // ) external;

    function unlockTokens() external;

    
    function withdrawLiquidity(address sender) external returns (uint256);

    
    function updateLiquidity(uint256 _newLiquidity) external;

    function getAPY() external view returns (uint256);

    
    function userStats(address _user) external view returns (PolicyHolder memory);

    
    
    
    
    
    
    
    function numberStats()
        external
        view
        returns (
            uint256 _maxCapacities,
            uint256 _totalSTBLLiquidity,
            uint256 _totalLeveragedLiquidity,
            uint256 _stakedSTBL,
            uint256 _annualProfitYields,
            uint256 _annualInsuranceCost,
            uint256 _bmiXRatio
        );

    
    
    
    
    
    function info()
        external
        view
        returns (
            string memory _symbol,
            address _insuredContract,
            IPolicyBookFabric.ContractType _contractType,
            bool _whitelisted
        );
}

// 
pragma solidity ^0.7.4;

interface ILeveragePortfolio {
    enum LeveragePortfolio {USERLEVERAGEPOOL, REINSURANCEPOOL}
    struct LevFundsFactors {
        uint256 netMPL;
        uint256 netMPLn;
        address policyBookAddr;
    }

    function targetUR() external view returns (uint256);

    function d_ProtocolConstant() external view returns (uint256);

    function a_ProtocolConstant() external view returns (uint256);

    function max_ProtocolConstant() external view returns (uint256);

    
    
    function deployLeverageStableToCoveragePools(LeveragePortfolio leveragePoolType)
        external
        returns (uint256);

    
    function deployVirtualStableToCoveragePools() external returns (uint256);

    
    
    function setRebalancingThreshold(uint256 threshold) external;

    
    
    
    
    
    function setProtocolConstant(
        uint256 _targetUR,
        uint256 _d_ProtocolConstant,
        uint256 _a1_ProtocolConstant,
        uint256 _max_ProtocolConstant
    ) external;

    
    
    
    //function calcM(uint256 poolUR) external returns (uint256);

    
    function totalLiquidity() external view returns (uint256);

    
    /// add the 20% of premium + portion of 80% of premium where reisnurance pool participate in coverage pools (vStable)  : access policybook
    
    
    function addPolicyPremium(uint256 epochsNumber, uint256 premiumAmount) external;

    
    
    function listleveragedCoveragePools(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory _coveragePools);

    
    function countleveragedCoveragePools() external view returns (uint256);

    function updateLiquidity(uint256 _lostLiquidity) external;

    function forceUpdateBMICoverStakingRewardMultiplier() external;
}

// 
pragma solidity ^0.7.4;


interface IContractsRegistry {
    function getUniswapRouterContract() external view returns (address);

    function getUniswapBMIToETHPairContract() external view returns (address);

    function getUniswapBMIToUSDTPairContract() external view returns (address);

    function getSushiswapRouterContract() external view returns (address);

    function getSushiswapBMIToETHPairContract() external view returns (address);

    function getSushiswapBMIToUSDTPairContract() external view returns (address);

    function getSushiSwapMasterChefV2Contract() external view returns (address);

    function getWETHContract() external view returns (address);

    function getUSDTContract() external view returns (address);

    function getBMIContract() external view returns (address);

    function getPriceFeedContract() external view returns (address);

    function getPolicyBookRegistryContract() external view returns (address);

    function getPolicyBookFabricContract() external view returns (address);

    function getBMICoverStakingContract() external view returns (address);

    function getBMICoverStakingViewContract() external view returns (address);

    function getLegacyRewardsGeneratorContract() external view returns (address);

    function getRewardsGeneratorContract() external view returns (address);

    function getBMIUtilityNFTContract() external view returns (address);

    function getNFTStakingContract() external view returns (address);

    function getLiquidityBridgeContract() external view returns (address);

    function getClaimingRegistryContract() external view returns (address);

    function getPolicyRegistryContract() external view returns (address);

    function getLiquidityRegistryContract() external view returns (address);

    function getClaimVotingContract() external view returns (address);

    function getReinsurancePoolContract() external view returns (address);

    function getLeveragePortfolioViewContract() external view returns (address);

    function getCapitalPoolContract() external view returns (address);

    function getPolicyBookAdminContract() external view returns (address);

    function getPolicyQuoteContract() external view returns (address);

    function getLegacyBMIStakingContract() external view returns (address);

    function getBMIStakingContract() external view returns (address);

    function getSTKBMIContract() external view returns (address);

    function getVBMIContract() external view returns (address);

    function getLegacyLiquidityMiningStakingContract() external view returns (address);

    function getLiquidityMiningStakingETHContract() external view returns (address);

    function getLiquidityMiningStakingUSDTContract() external view returns (address);

    function getReputationSystemContract() external view returns (address);

    function getAaveProtocolContract() external view returns (address);

    function getAaveLendPoolAddressProvdierContract() external view returns (address);

    function getAaveATokenContract() external view returns (address);

    function getCompoundProtocolContract() external view returns (address);

    function getCompoundCTokenContract() external view returns (address);

    function getCompoundComptrollerContract() external view returns (address);

    function getYearnProtocolContract() external view returns (address);

    function getYearnVaultContract() external view returns (address);

    function getYieldGeneratorContract() external view returns (address);

    function getShieldMiningContract() external view returns (address);
}

// 
pragma solidity ^0.7.4;




interface ICapitalPool {
    struct PremiumFactors {
        uint256 epochsNumber;
        uint256 premiumPrice;
        uint256 vStblDeployedByRP;
        uint256 vStblOfCP;
        uint256 poolUtilizationRation;
        uint256 premiumPerDeployment;
        uint256 userLeveragePoolsCount;
        IPolicyBookFacade policyBookFacade;
    }

    enum PoolType {COVERAGE, LEVERAGE, REINSURANCE}

    function virtualUsdtAccumulatedBalance() external view returns (uint256);

    function liquidityCushionBalance() external view returns (uint256);

    
    
    
    
    
    function addPolicyHoldersHardSTBL(
        uint256 _stblAmount,
        uint256 _epochsNumber,
        uint256 _protocolFee
    ) external returns (uint256);

    
    
    
    function addCoverageProvidersHardSTBL(uint256 _stblAmount) external;

    
    
    
    function addLeverageProvidersHardSTBL(uint256 _stblAmount) external;

    
    
    
    function addReinsurancePoolHardSTBL(uint256 _stblAmount) external;

    
    
    function rebalanceLiquidityCushion() external;

    
    
    
    function fundClaim(address _claimer, uint256 _stblAmount) external;

    
    
    
    
    function withdrawLiquidity(
        address _sender,
        uint256 _stblAmount,
        bool _isLeveragePool
    ) external;

    function rebalanceDuration() external view returns (uint256);
}

// 
pragma solidity ^0.7.4;


uint256 constant SECONDS_IN_THE_YEAR = 365 * 24 * 60 * 60; // 365 days * 24 hours * 60 minutes * 60 seconds
uint256 constant DAYS_IN_THE_YEAR = 365;
uint256 constant MAX_INT = type(uint256).max;

uint256 constant DECIMALS18 = 10**18;

uint256 constant PRECISION = 10**25;
uint256 constant PERCENTAGE_100 = 100 * PRECISION;

uint256 constant BLOCKS_PER_DAY = 6450;
uint256 constant BLOCKS_PER_YEAR = BLOCKS_PER_DAY * 365;

uint256 constant APY_TOKENS = DECIMALS18;

uint256 constant PROTOCOL_PERCENTAGE = 20 * PRECISION;

uint256 constant DEFAULT_REBALANCING_THRESHOLD = 10**23;

uint256 constant EPOCH_DAYS_AMOUNT = 7;

// 

pragma solidity ^0.7.0;

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
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
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
        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
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
        return address(uint256(_at(set._inner, index)));
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
}

// 

pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
