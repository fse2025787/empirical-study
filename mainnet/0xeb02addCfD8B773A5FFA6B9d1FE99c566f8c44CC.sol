// SPDX-License-Identifier: MIT


// 
pragma solidity >=0.8.4 <0.9.0;



interface IGovernable {
  // Events

  
  
  event GovernanceSet(address _governance);

  
  
  event GovernanceProposal(address _pendingGovernance);

  // Errors

  
  error OnlyGovernance();

  
  error OnlyPendingGovernance();

  
  error NoGovernanceZeroAddress();

  // Variables

  
  
  function governance() external view returns (address _governance);

  
  
  function pendingGovernance() external view returns (address _pendingGovernance);

  // Methods

  
  
  function setGovernance(address _governance) external;

  
  function acceptGovernance() external;
}

// 
pragma solidity >=0.8.4 <0.9.0;




interface IKeep3rAccountance {
  // Events

  
  
  
  
  event Bonding(address indexed _keeper, address indexed _bonding, uint256 _amount);

  
  
  
  
  event Unbonding(address indexed _keeperOrJob, address indexed _unbonding, uint256 _amount);

  // Variables

  
  
  
  function workCompleted(address _keeper) external view returns (uint256 _workCompleted);

  
  
  
  function firstSeen(address _keeper) external view returns (uint256 timestamp);

  
  
  
  function disputes(address _keeperOrJob) external view returns (bool _disputed);

  
  
  
  
  function bonds(address _keeper, address _bond) external view returns (uint256 _bonds);

  
  
  
  
  function jobTokenCredits(address _job, address _token) external view returns (uint256 _amount);

  
  
  
  
  function pendingBonds(address _keeper, address _bonding) external view returns (uint256 _pendingBonds);

  
  
  
  
  function canActivateAfter(address _keeper, address _bonding) external view returns (uint256 _timestamp);

  
  
  
  
  function canWithdrawAfter(address _keeper, address _bonding) external view returns (uint256 _timestamp);

  
  
  
  
  function pendingUnbonds(address _keeper, address _bonding) external view returns (uint256 _pendingUnbonds);

  
  
  
  function hasBonded(address _keeper) external view returns (bool _hasBonded);

  // Methods

  
  
  function jobs() external view returns (address[] memory _jobList);

  
  
  function keepers() external view returns (address[] memory _keeperList);

  // Errors

  
  error JobUnavailable();

  
  error JobDisputed();
}

// 
pragma solidity >=0.8.4 <0.9.0;



abstract contract Governable is IGovernable {
  
  address public override governance;

  
  address public override pendingGovernance;

  constructor(address _governance) {
    if (_governance == address(0)) revert NoGovernanceZeroAddress();
    governance = _governance;
  }

  
  function setGovernance(address _governance) external override onlyGovernance {
    pendingGovernance = _governance;
    emit GovernanceProposal(_governance);
  }

  
  function acceptGovernance() external override onlyPendingGovernance {
    governance = pendingGovernance;
    delete pendingGovernance;
    emit GovernanceSet(governance);
  }

  
  modifier onlyGovernance {
    if (msg.sender != governance) revert OnlyGovernance();
    _;
  }

  
  modifier onlyPendingGovernance {
    if (msg.sender != pendingGovernance) revert OnlyPendingGovernance();
    _;
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;



interface IKeep3rRoles {
  // Events

  
  
  event SlasherAdded(address _slasher);

  
  
  event SlasherRemoved(address _slasher);

  
  
  event DisputerAdded(address _disputer);

  
  
  event DisputerRemoved(address _disputer);

  // Variables

  
  
  
  function slashers(address _slasher) external view returns (bool _isSlasher);

  
  
  
  function disputers(address _disputer) external view returns (bool _isDisputer);

  // Errors

  
  error SlasherExistent();

  
  error SlasherUnexistent();

  
  error DisputerExistent();

  
  error DisputerUnexistent();

  
  error OnlySlasher();

  
  error OnlyDisputer();

  // Methods

  
  function addSlasher(address _slasher) external;

  
  function removeSlasher(address _slasher) external;

  
  function addDisputer(address _disputer) external;

  
  function removeDisputer(address _disputer) external;
}

// 

pragma solidity >=0.8.4 <0.9.0;

interface IBaseErrors {
  
  error ZeroAddress();
}

// 
pragma solidity >=0.8.4 <0.9.0;




abstract contract Keep3rAccountance is IKeep3rAccountance {
  using EnumerableSet for EnumerableSet.AddressSet;

  
  EnumerableSet.AddressSet internal _keepers;

  
  mapping(address => uint256) public override workCompleted;

  
  mapping(address => uint256) public override firstSeen;

  
  mapping(address => bool) public override disputes;

  
  
  mapping(address => mapping(address => uint256)) public override bonds;

  
  mapping(address => mapping(address => uint256)) public override jobTokenCredits;

  
  mapping(address => uint256) internal _jobLiquidityCredits;

  
  mapping(address => uint256) internal _jobPeriodCredits;

  
  mapping(address => EnumerableSet.AddressSet) internal _jobTokens;

  
  mapping(address => EnumerableSet.AddressSet) internal _jobLiquidities;

  
  mapping(address => address) internal _liquidityPool;

  
  mapping(address => bool) internal _isKP3RToken0;

  
  mapping(address => mapping(address => uint256)) public override pendingBonds;

  
  mapping(address => mapping(address => uint256)) public override canActivateAfter;

  
  mapping(address => mapping(address => uint256)) public override canWithdrawAfter;

  
  mapping(address => mapping(address => uint256)) public override pendingUnbonds;

  
  mapping(address => bool) public override hasBonded;

  
  EnumerableSet.AddressSet internal _jobs;

  
  function jobs() external view override returns (address[] memory _list) {
    _list = _jobs.values();
  }

  
  function keepers() external view override returns (address[] memory _list) {
    _list = _keepers.values();
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;





contract Keep3rRoles is IKeep3rRoles, Governable {
  
  mapping(address => bool) public override slashers;

  
  mapping(address => bool) public override disputers;

  constructor(address _governance) Governable(_governance) {}

  
  function addSlasher(address _slasher) external override onlyGovernance {
    if (slashers[_slasher]) revert SlasherExistent();
    slashers[_slasher] = true;
    emit SlasherAdded(_slasher);
  }

  
  function removeSlasher(address _slasher) external override onlyGovernance {
    if (!slashers[_slasher]) revert SlasherUnexistent();
    delete slashers[_slasher];
    emit SlasherRemoved(_slasher);
  }

  
  function addDisputer(address _disputer) external override onlyGovernance {
    if (disputers[_disputer]) revert DisputerExistent();
    disputers[_disputer] = true;
    emit DisputerAdded(_disputer);
  }

  
  function removeDisputer(address _disputer) external override onlyGovernance {
    if (!disputers[_disputer]) revert DisputerUnexistent();
    delete disputers[_disputer];
    emit DisputerRemoved(_disputer);
  }

  
  modifier onlySlasher {
    if (!slashers[msg.sender]) revert OnlySlasher();
    _;
  }

  
  modifier onlyDisputer {
    if (!disputers[msg.sender]) revert OnlyDisputer();
    _;
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;






interface IKeep3rParameters is IBaseErrors {
  // Events

  
  
  event Keep3rHelperChange(address _keep3rHelper);

  
  
  event Keep3rV1Change(address _keep3rV1);

  
  
  event Keep3rV1ProxyChange(address _keep3rV1Proxy);

  
  
  event Kp3rWethPoolChange(address _kp3rWethPool);

  
  
  event BondTimeChange(uint256 _bondTime);

  
  
  event LiquidityMinimumChange(uint256 _liquidityMinimum);

  
  
  event UnbondTimeChange(uint256 _unbondTime);

  
  
  event RewardPeriodTimeChange(uint256 _rewardPeriodTime);

  
  
  event InflationPeriodChange(uint256 _inflationPeriod);

  
  
  event FeeChange(uint256 _fee);

  // Variables

  
  
  function keep3rHelper() external view returns (address _keep3rHelper);

  
  
  function keep3rV1() external view returns (address _keep3rV1);

  
  
  function keep3rV1Proxy() external view returns (address _keep3rV1Proxy);

  
  
  function kp3rWethPool() external view returns (address _kp3rWethPool);

  
  
  function bondTime() external view returns (uint256 _days);

  
  
  function unbondTime() external view returns (uint256 _days);

  
  
  function liquidityMinimum() external view returns (uint256 _amount);

  
  
  function rewardPeriodTime() external view returns (uint256 _days);

  
  
  function inflationPeriod() external view returns (uint256 _period);

  
  
  function fee() external view returns (uint256 _amount);

  // Errors

  
  error MinRewardPeriod();

  
  error Disputed();

  
  error BondsUnexistent();

  
  error BondsLocked();

  
  error UnbondsUnexistent();

  
  error UnbondsLocked();

  // Methods

  
  
  function setKeep3rHelper(address _keep3rHelper) external;

  
  
  function setKeep3rV1(address _keep3rV1) external;

  
  
  function setKeep3rV1Proxy(address _keep3rV1Proxy) external;

  
  
  function setKp3rWethPool(address _kp3rWethPool) external;

  
  
  function setBondTime(uint256 _bond) external;

  
  
  function setUnbondTime(uint256 _unbond) external;

  
  
  function setLiquidityMinimum(uint256 _liquidityMinimum) external;

  
  
  function setRewardPeriodTime(uint256 _rewardPeriodTime) external;

  
  
  function setInflationPeriod(uint256 _inflationPeriod) external;

  
  
  function setFee(uint256 _fee) external;
}



interface IKeep3rJobOwnership {
  // Events

  
  
  
  
  event JobOwnershipChange(address indexed _job, address indexed _owner, address indexed _pendingOwner);

  
  
  
  
  event JobOwnershipAssent(address indexed _job, address indexed _previousOwner, address indexed _newOwner);

  // Errors

  
  error OnlyJobOwner();

  
  error OnlyPendingJobOwner();

  // Variables

  
  
  
  function jobOwner(address _job) external view returns (address _owner);

  
  
  
  function jobPendingOwner(address _job) external view returns (address _pendingOwner);

  // Methods

  
  
  
  function changeJobOwnership(address _job, address _newOwner) external;

  
  
  function acceptJobOwnership(address _job) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;






abstract contract Keep3rParameters is IKeep3rParameters, Keep3rAccountance, Keep3rRoles {
  
  address public override keep3rV1;

  
  address public override keep3rV1Proxy;

  
  address public override keep3rHelper;

  
  address public override kp3rWethPool;

  
  uint256 public override bondTime = 3 days;

  
  uint256 public override unbondTime = 14 days;

  
  uint256 public override liquidityMinimum = 3 ether;

  
  uint256 public override rewardPeriodTime = 5 days;

  
  uint256 public override inflationPeriod = 34 days;

  
  uint256 public override fee = 30;

  
  uint256 internal constant _BASE = 10_000;

  
  uint256 internal constant _MIN_REWARD_PERIOD_TIME = 1 days;

  constructor(
    address _keep3rHelper,
    address _keep3rV1,
    address _keep3rV1Proxy,
    address _kp3rWethPool
  ) {
    keep3rHelper = _keep3rHelper;
    keep3rV1 = _keep3rV1;
    keep3rV1Proxy = _keep3rV1Proxy;
    kp3rWethPool = _kp3rWethPool;
    _liquidityPool[kp3rWethPool] = kp3rWethPool;
    _isKP3RToken0[_kp3rWethPool] = IKeep3rHelper(keep3rHelper).isKP3RToken0(kp3rWethPool);
  }

  
  function setKeep3rHelper(address _keep3rHelper) external override onlyGovernance {
    if (_keep3rHelper == address(0)) revert ZeroAddress();
    keep3rHelper = _keep3rHelper;
    emit Keep3rHelperChange(_keep3rHelper);
  }

  
  function setKeep3rV1(address _keep3rV1) external override onlyGovernance {
    if (_keep3rV1 == address(0)) revert ZeroAddress();
    keep3rV1 = _keep3rV1;
    emit Keep3rV1Change(_keep3rV1);
  }

  
  function setKeep3rV1Proxy(address _keep3rV1Proxy) external override onlyGovernance {
    if (_keep3rV1Proxy == address(0)) revert ZeroAddress();
    keep3rV1Proxy = _keep3rV1Proxy;
    emit Keep3rV1ProxyChange(_keep3rV1Proxy);
  }

  
  function setKp3rWethPool(address _kp3rWethPool) external override onlyGovernance {
    if (_kp3rWethPool == address(0)) revert ZeroAddress();
    kp3rWethPool = _kp3rWethPool;
    _liquidityPool[kp3rWethPool] = kp3rWethPool;
    _isKP3RToken0[_kp3rWethPool] = IKeep3rHelper(keep3rHelper).isKP3RToken0(_kp3rWethPool);
    emit Kp3rWethPoolChange(_kp3rWethPool);
  }

  
  function setBondTime(uint256 _bondTime) external override onlyGovernance {
    bondTime = _bondTime;
    emit BondTimeChange(_bondTime);
  }

  
  function setUnbondTime(uint256 _unbondTime) external override onlyGovernance {
    unbondTime = _unbondTime;
    emit UnbondTimeChange(_unbondTime);
  }

  
  function setLiquidityMinimum(uint256 _liquidityMinimum) external override onlyGovernance {
    liquidityMinimum = _liquidityMinimum;
    emit LiquidityMinimumChange(_liquidityMinimum);
  }

  
  // TODO: check what happens to credit minting when changing this. Shouldn't we update the cached ticks?
  function setRewardPeriodTime(uint256 _rewardPeriodTime) external override onlyGovernance {
    if (_rewardPeriodTime < _MIN_REWARD_PERIOD_TIME) revert MinRewardPeriod();
    rewardPeriodTime = _rewardPeriodTime;
    emit RewardPeriodTimeChange(_rewardPeriodTime);
  }

  
  function setInflationPeriod(uint256 _inflationPeriod) external override onlyGovernance {
    inflationPeriod = _inflationPeriod;
    emit InflationPeriodChange(_inflationPeriod);
  }

  
  function setFee(uint256 _fee) external override onlyGovernance {
    fee = _fee;
    emit FeeChange(_fee);
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;



abstract contract Keep3rJobOwnership is IKeep3rJobOwnership {
  
  mapping(address => address) public override jobOwner;

  
  mapping(address => address) public override jobPendingOwner;

  
  function changeJobOwnership(address _job, address _newOwner) external override onlyJobOwner(_job) {
    jobPendingOwner[_job] = _newOwner;
    emit JobOwnershipChange(_job, jobOwner[_job], _newOwner);
  }

  
  function acceptJobOwnership(address _job) external override onlyPendingJobOwner(_job) {
    address _previousOwner = jobOwner[_job];

    jobOwner[_job] = jobPendingOwner[_job];
    delete jobPendingOwner[_job];

    emit JobOwnershipAssent(msg.sender, _job, _previousOwner);
  }

  modifier onlyJobOwner(address _job) {
    if (msg.sender != jobOwner[_job]) revert OnlyJobOwner();
    _;
  }

  modifier onlyPendingJobOwner(address _job) {
    if (msg.sender != jobPendingOwner[_job]) revert OnlyPendingJobOwner();
    _;
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;



interface IKeep3rJobFundableCredits {
  // Events

  
  
  
  
  
  event TokenCreditAddition(address indexed _job, address indexed _token, address indexed _provider, uint256 _amount);

  
  
  
  
  
  event TokenCreditWithdrawal(address indexed _job, address indexed _token, address indexed _receiver, uint256 _amount);

  // Errors

  
  error TokenUnallowed();

  
  error JobTokenCreditsLocked();

  
  error InsufficientJobTokenCredits();

  // Variables

  
  
  
  
  function jobTokenCreditsAddedAt(address _job, address _token) external view returns (uint256 _timestamp);

  // Methods

  
  
  
  
  function addTokenCreditsToJob(
    address _job,
    address _token,
    uint256 _amount
  ) external;

  
  
  
  
  
  function withdrawTokenCreditsFromJob(
    address _job,
    address _token,
    uint256 _amount,
    address _receiver
  ) external;
}



interface IKeep3rJobFundableLiquidity {
  // Events

  
  
  event LiquidityApproval(address _liquidity);

  
  
  event LiquidityRevocation(address _liquidity);

  
  
  
  
  
  event LiquidityAddition(address indexed _job, address indexed _liquidity, address indexed _provider, uint256 _amount);

  
  
  
  
  
  event LiquidityWithdrawal(address indexed _job, address indexed _liquidity, address indexed _receiver, uint256 _amount);

  
  
  
  
  
  event LiquidityCreditsReward(address indexed _job, uint256 _rewardedAt, uint256 _currentCredits, uint256 _periodCredits);

  
  
  
  
  event LiquidityCreditsForced(address indexed _job, uint256 _rewardedAt, uint256 _currentCredits);

  // Errors

  
  error LiquidityPairApproved();

  
  error LiquidityPairUnexistent();

  
  error LiquidityPairUnapproved();

  
  error JobLiquidityUnexistent();

  
  error JobLiquidityInsufficient();

  
  error JobLiquidityLessThanMin();

  // Structs

  
  struct TickCache {
    int56 current; // Tracks the current tick
    int56 difference; // Stores the difference between the current tick and the last tick
    uint256 period; // Stores the period at which the last observation was made
  }

  // Variables

  
  
  function approvedLiquidities() external view returns (address[] memory _list);

  
  
  
  
  function liquidityAmount(address _job, address _liquidity) external view returns (uint256 _amount);

  
  
  
  function rewardedAt(address _job) external view returns (uint256 _timestamp);

  
  
  
  function workedAt(address _job) external view returns (uint256 _timestamp);

  // Methods

  
  
  
  function jobLiquidityCredits(address _job) external view returns (uint256 _amount);

  
  
  
  function jobPeriodCredits(address _job) external view returns (uint256 _amount);

  
  
  
  function totalJobCredits(address _job) external view returns (uint256 _amount);

  
  
  
  
  
  function quoteLiquidity(address _liquidity, uint256 _amount) external view returns (uint256 _periodCredits);

  
  
  
  function observeLiquidity(address _liquidity) external view returns (TickCache memory _tickCache);

  
  
  
  function forceLiquidityCreditsToJob(address _job, uint256 _amount) external;

  
  
  function approveLiquidity(address _liquidity) external;

  
  
  function revokeLiquidity(address _liquidity) external;

  
  
  
  
  function addLiquidityToJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) external;

  
  
  
  
  
  function unbondLiquidityFromJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) external;

  
  
  
  
  function withdrawLiquidityFromJob(
    address _job,
    address _liquidity,
    address _receiver
  ) external;
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// 
pragma solidity >=0.8.4 <0.9.0;











abstract contract Keep3rJobFundableCredits is IKeep3rJobFundableCredits, ReentrancyGuard, Keep3rJobOwnership, Keep3rParameters {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;

  
  uint256 internal constant _WITHDRAW_TOKENS_COOLDOWN = 1 minutes;

  
  mapping(address => mapping(address => uint256)) public override jobTokenCreditsAddedAt;

  
  function addTokenCreditsToJob(
    address _job,
    address _token,
    uint256 _amount
  ) external override nonReentrant {
    if (!_jobs.contains(_job)) revert JobUnavailable();
    // KP3R shouldn't be used for direct token payments
    if (_token == keep3rV1) revert TokenUnallowed();
    uint256 _before = IERC20(_token).balanceOf(address(this));
    IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
    uint256 _received = IERC20(_token).balanceOf(address(this)) - _before;
    uint256 _tokenFee = (_received * fee) / _BASE;
    jobTokenCredits[_job][_token] += _received - _tokenFee;
    jobTokenCreditsAddedAt[_job][_token] = block.timestamp;
    IERC20(_token).safeTransfer(governance, _tokenFee);
    _jobTokens[_job].add(_token);

    emit TokenCreditAddition(_job, _token, msg.sender, _received);
  }

  
  function withdrawTokenCreditsFromJob(
    address _job,
    address _token,
    uint256 _amount,
    address _receiver
  ) external override nonReentrant onlyJobOwner(_job) {
    if (block.timestamp <= jobTokenCreditsAddedAt[_job][_token] + _WITHDRAW_TOKENS_COOLDOWN) revert JobTokenCreditsLocked();
    if (jobTokenCredits[_job][_token] < _amount) revert InsufficientJobTokenCredits();
    if (disputes[_job]) revert JobDisputed();

    jobTokenCredits[_job][_token] -= _amount;
    IERC20(_token).safeTransfer(_receiver, _amount);

    if (jobTokenCredits[_job][_token] == 0) {
      _jobTokens[_job].remove(_token);
    }

    emit TokenCreditWithdrawal(_job, _token, _receiver, _amount);
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;














abstract contract Keep3rJobFundableLiquidity is IKeep3rJobFundableLiquidity, ReentrancyGuard, Keep3rJobOwnership, Keep3rParameters {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;

  
  EnumerableSet.AddressSet internal _approvedLiquidities;

  
  mapping(address => mapping(address => uint256)) public override liquidityAmount;

  
  mapping(address => uint256) public override rewardedAt;

  
  mapping(address => uint256) public override workedAt;

  
  mapping(address => TickCache) internal _tick;

  // Views

  
  function approvedLiquidities() external view override returns (address[] memory _list) {
    _list = _approvedLiquidities.values();
  }

  
  function jobPeriodCredits(address _job) public view override returns (uint256 _periodCredits) {
    for (uint256 i; i < _jobLiquidities[_job].length(); i++) {
      address _liquidity = _jobLiquidities[_job].at(i);
      if (_approvedLiquidities.contains(_liquidity)) {
        TickCache memory _tickCache = observeLiquidity(_liquidity);
        if (_tickCache.period != 0) {
          int56 _tickDifference = _isKP3RToken0[_liquidity] ? _tickCache.difference : -_tickCache.difference;
          _periodCredits += _getReward(
            IKeep3rHelper(keep3rHelper).getKP3RsAtTick(liquidityAmount[_job][_liquidity], _tickDifference, rewardPeriodTime)
          );
        }
      }
    }
  }

  
  function jobLiquidityCredits(address _job) public view override returns (uint256 _liquidityCredits) {
    uint256 _periodCredits = jobPeriodCredits(_job);

    // If the job was rewarded in the past 1 period time
    if ((block.timestamp - rewardedAt[_job]) < rewardPeriodTime) {
      // If the job has period credits, update minted job credits to new twap
      _liquidityCredits = _periodCredits > 0
        ? (_jobLiquidityCredits[_job] * _periodCredits) / _jobPeriodCredits[_job] // If the job has period credits, return remaining job credits updated to new twap
        : _jobLiquidityCredits[_job]; // If not, return remaining credits, forced credits should not be updated
    } else {
      // Else return a full period worth of credits if current credits have expired
      _liquidityCredits = _periodCredits;
    }
  }

  
  function totalJobCredits(address _job) external view override returns (uint256 _credits) {
    uint256 _periodCredits = jobPeriodCredits(_job);
    uint256 _cooldown = block.timestamp;

    if ((rewardedAt[_job] > _period(block.timestamp - rewardPeriodTime))) {
      // Will calculate cooldown if it outdated
      if ((block.timestamp - rewardedAt[_job]) >= rewardPeriodTime) {
        // Will calculate cooldown from last reward reference in this period
        _cooldown -= (rewardedAt[_job] + rewardPeriodTime);
      } else {
        // Will calculate cooldown from last reward timestamp
        _cooldown -= rewardedAt[_job];
      }
    } else {
      // Will calculate cooldown from period start if expired
      _cooldown -= _period(block.timestamp);
    }
    _credits = jobLiquidityCredits(_job) + _phase(_cooldown, _periodCredits);
  }

  
  function quoteLiquidity(address _liquidity, uint256 _amount) external view override returns (uint256 _periodCredits) {
    if (_approvedLiquidities.contains(_liquidity)) {
      TickCache memory _tickCache = observeLiquidity(_liquidity);
      if (_tickCache.period != 0) {
        int56 _tickDifference = _isKP3RToken0[_liquidity] ? _tickCache.difference : -_tickCache.difference;
        return _getReward(IKeep3rHelper(keep3rHelper).getKP3RsAtTick(_amount, _tickDifference, rewardPeriodTime));
      }
    }
  }

  
  function observeLiquidity(address _liquidity) public view override returns (TickCache memory _tickCache) {
    if (_tick[_liquidity].period == _period(block.timestamp)) {
      // Will return cached twaps if liquidity is updated
      _tickCache = _tick[_liquidity];
    } else {
      bool success;
      uint256 lastPeriod = _period(block.timestamp - rewardPeriodTime);

      if (_tick[_liquidity].period == lastPeriod) {
        // Will only ask for current period accumulator if liquidity is outdated
        uint32[] memory _secondsAgo = new uint32[](1);
        int56 previousTick = _tick[_liquidity].current;

        _secondsAgo[0] = uint32(block.timestamp - _period(block.timestamp));

        (_tickCache.current, , success) = IKeep3rHelper(keep3rHelper).observe(_liquidityPool[_liquidity], _secondsAgo);

        _tickCache.difference = _tickCache.current - previousTick;
      } else if (_tick[_liquidity].period < lastPeriod) {
        // Will ask for 2 accumulators if liquidity is expired
        uint32[] memory _secondsAgo = new uint32[](2);

        _secondsAgo[0] = uint32(block.timestamp - _period(block.timestamp));
        _secondsAgo[1] = uint32(block.timestamp - _period(block.timestamp) + rewardPeriodTime);

        int56 _tickCumulative2;
        (_tickCache.current, _tickCumulative2, success) = IKeep3rHelper(keep3rHelper).observe(_liquidityPool[_liquidity], _secondsAgo);

        _tickCache.difference = _tickCache.current - _tickCumulative2;
      }
      if (success) {
        _tickCache.period = _period(block.timestamp);
      } else {
        delete _tickCache.period;
      }
    }
  }

  // Methods

  
  function forceLiquidityCreditsToJob(address _job, uint256 _amount) external override onlyGovernance {
    if (!_jobs.contains(_job)) revert JobUnavailable();
    _settleJobAccountance(_job);
    _jobLiquidityCredits[_job] += _amount;
    emit LiquidityCreditsForced(_job, rewardedAt[_job], _jobLiquidityCredits[_job]);
  }

  
  function approveLiquidity(address _liquidity) external override onlyGovernance {
    if (!_approvedLiquidities.add(_liquidity)) revert LiquidityPairApproved();
    _liquidityPool[_liquidity] = IPairManager(_liquidity).pool();
    _isKP3RToken0[_liquidity] = IKeep3rHelper(keep3rHelper).isKP3RToken0(_liquidityPool[_liquidity]);
    _tick[_liquidity] = observeLiquidity(_liquidity);
    emit LiquidityApproval(_liquidity);
  }

  
  function revokeLiquidity(address _liquidity) external override onlyGovernance {
    if (!_approvedLiquidities.remove(_liquidity)) revert LiquidityPairUnexistent();
    emit LiquidityRevocation(_liquidity);
  }

  
  function addLiquidityToJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) external override nonReentrant {
    if (!_approvedLiquidities.contains(_liquidity)) revert LiquidityPairUnapproved();
    if (!_jobs.contains(_job)) revert JobUnavailable();

    _jobLiquidities[_job].add(_liquidity);

    _settleJobAccountance(_job);

    if (_quoteLiquidity(liquidityAmount[_job][_liquidity] + _amount, _liquidity) < liquidityMinimum) revert JobLiquidityLessThanMin();

    emit LiquidityCreditsReward(_job, rewardedAt[_job], _jobLiquidityCredits[_job], _jobPeriodCredits[_job]);

    IERC20(_liquidity).safeTransferFrom(msg.sender, address(this), _amount);
    liquidityAmount[_job][_liquidity] += _amount;
    _jobPeriodCredits[_job] += _getReward(_quoteLiquidity(_amount, _liquidity));
    emit LiquidityAddition(_job, _liquidity, msg.sender, _amount);
  }

  
  function unbondLiquidityFromJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) external override onlyJobOwner(_job) {
    canWithdrawAfter[_job][_liquidity] = block.timestamp + unbondTime;
    pendingUnbonds[_job][_liquidity] += _amount;
    _unbondLiquidityFromJob(_job, _liquidity, _amount);

    uint256 _remainingLiquidity = liquidityAmount[_job][_liquidity];
    if (_remainingLiquidity > 0 && _quoteLiquidity(_remainingLiquidity, _liquidity) < liquidityMinimum) revert JobLiquidityLessThanMin();

    emit Unbonding(_job, _liquidity, _amount);
  }

  
  function withdrawLiquidityFromJob(
    address _job,
    address _liquidity,
    address _receiver
  ) external override onlyJobOwner(_job) {
    if (_receiver == address(0)) revert ZeroAddress();
    if (pendingUnbonds[_job][_liquidity] == 0) revert UnbondsUnexistent();
    if (canWithdrawAfter[_job][_liquidity] >= block.timestamp) revert UnbondsLocked();
    if (disputes[_job]) revert Disputed();

    uint256 _amount = pendingUnbonds[_job][_liquidity];

    delete pendingUnbonds[_job][_liquidity];
    delete canWithdrawAfter[_job][_liquidity];

    IERC20(_liquidity).safeTransfer(_receiver, _amount);
    emit LiquidityWithdrawal(_job, _liquidity, _receiver, _amount);
  }

  // Internal functions

  
  function _updateJobCreditsIfNeeded(address _job) internal returns (bool _rewarded) {
    if (rewardedAt[_job] < _period(block.timestamp)) {
      // Will exit function if job has been rewarded in current period
      if (rewardedAt[_job] <= _period(block.timestamp - rewardPeriodTime)) {
        // Will reset job to period syncronicity if a full period passed without rewards
        _updateJobPeriod(_job);
        _jobLiquidityCredits[_job] = _jobPeriodCredits[_job];
        rewardedAt[_job] = _period(block.timestamp);
        _rewarded = true;
      } else if ((block.timestamp - rewardedAt[_job]) >= rewardPeriodTime) {
        // Will reset job's syncronicity if last reward was more than epoch ago
        _updateJobPeriod(_job);
        _jobLiquidityCredits[_job] = _jobPeriodCredits[_job];
        rewardedAt[_job] += rewardPeriodTime;
        _rewarded = true;
      } else if (workedAt[_job] < _period(block.timestamp)) {
        // First keeper on period has to update job accountance to current twaps
        uint256 previousPeriodCredits = _jobPeriodCredits[_job];
        _updateJobPeriod(_job);
        _jobLiquidityCredits[_job] = (_jobLiquidityCredits[_job] * _jobPeriodCredits[_job]) / previousPeriodCredits;
        // Updating job accountance does not reward job
      }
    }
  }

  
  function _rewardJobCredits(address _job) internal {
    
    /* WARNING: this allows to top up _jobLiquidityCredits to a max of 1.99 but have to spend at least 1 */
    _jobLiquidityCredits[_job] += _phase(block.timestamp - rewardedAt[_job], _jobPeriodCredits[_job]);
    rewardedAt[_job] = block.timestamp;
  }

  
  function _updateJobPeriod(address _job) internal {
    _jobPeriodCredits[_job] = _calculateJobPeriodCredits(_job);
  }

  
  
  function _calculateJobPeriodCredits(address _job) internal returns (uint256 _periodCredits) {
    if (_tick[kp3rWethPool].period != _period(block.timestamp)) {
      // Updates KP3R/WETH quote if needed
      _tick[kp3rWethPool] = observeLiquidity(kp3rWethPool);
    }

    for (uint256 i; i < _jobLiquidities[_job].length(); i++) {
      address _liquidity = _jobLiquidities[_job].at(i);
      if (_approvedLiquidities.contains(_liquidity)) {
        if (_tick[_liquidity].period != _period(block.timestamp)) {
          // Updates liquidity cache only if needed
          _tick[_liquidity] = observeLiquidity(_liquidity);
        }
        _periodCredits += _getReward(_quoteLiquidity(liquidityAmount[_job][_liquidity], _liquidity));
      }
    }
  }

  
  function _unbondLiquidityFromJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) internal nonReentrant {
    if (!_jobLiquidities[_job].contains(_liquidity)) revert JobLiquidityUnexistent();
    if (liquidityAmount[_job][_liquidity] < _amount) revert JobLiquidityInsufficient();

    // Ensures current twaps in job liquidities
    _updateJobPeriod(_job);
    uint256 _periodCreditsToRemove = _getReward(_quoteLiquidity(_amount, _liquidity));

    // A liquidity can be revoked causing a job to have 0 periodCredits
    if (_jobPeriodCredits[_job] > 0) {
      // Removes a % correspondant to a full rewardPeriodTime for the liquidity withdrawn vs all of the liquidities
      _jobLiquidityCredits[_job] -= (_jobLiquidityCredits[_job] * _periodCreditsToRemove) / _jobPeriodCredits[_job];
      _jobPeriodCredits[_job] -= _periodCreditsToRemove;
    }

    liquidityAmount[_job][_liquidity] -= _amount;
    if (liquidityAmount[_job][_liquidity] == 0) {
      _jobLiquidities[_job].remove(_liquidity);
    }
  }

  
  function _phase(uint256 _timePassed, uint256 _multiplier) internal view returns (uint256 _result) {
    if (_timePassed < rewardPeriodTime) {
      _result = (_timePassed * _multiplier) / rewardPeriodTime;
    } else _result = _multiplier;
  }

  
  function _period(uint256 _timestamp) internal view returns (uint256 _periodTimestamp) {
    return _timestamp - (_timestamp % rewardPeriodTime);
  }

  
  function _getReward(uint256 _baseAmount) internal view returns (uint256 _credits) {
    return FullMath.mulDiv(_baseAmount, rewardPeriodTime, inflationPeriod);
  }

  
  function _quoteLiquidity(uint256 _amount, address _liquidity) internal view returns (uint256 _quote) {
    if (_tick[_liquidity].period != 0) {
      int56 _tickDifference = _isKP3RToken0[_liquidity] ? _tick[_liquidity].difference : -_tick[_liquidity].difference;
      _quote = IKeep3rHelper(keep3rHelper).getKP3RsAtTick(_amount, _tickDifference, rewardPeriodTime);
    }
  }

  
  
  function _settleJobAccountance(address _job) internal virtual {
    _updateJobCreditsIfNeeded(_job);
    _rewardJobCredits(_job);
    _jobLiquidityCredits[_job] = Math.min(_jobLiquidityCredits[_job], _jobPeriodCredits[_job]);
  }
}



interface IKeep3rJobMigration {
  // Events

  
  
  
  event JobMigrationRequested(address indexed _fromJob, address _toJob);

  
  
  
  event JobMigrationSuccessful(address _fromJob, address indexed _toJob);

  // Errors

  
  error JobMigrationImpossible();

  
  error JobMigrationUnavailable();

  
  error JobMigrationLocked();

  // Variables

  
  
  function pendingJobMigrations(address _fromJob) external view returns (address _toJob);

  // Methods

  
  
  
  function migrateJob(address _fromJob, address _toJob) external;

  
  
  
  
  function acceptJobMigration(address _fromJob, address _toJob) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;



///         A disputed keeper is slashable and is not able to bond, activate, withdraw or receive direct payments
///         A disputed job is slashable and is not able to pay the keepers, withdraw tokens or to migrate
interface IKeep3rDisputable {
  
  
  
  event Dispute(address indexed _jobOrKeeper, address indexed _disputer);

  
  
  
  event Resolve(address indexed _jobOrKeeper, address indexed _resolver);

  
  error AlreadyDisputed();

  
  error NotDisputed();

  
  
  function dispute(address _jobOrKeeper) external;

  
  
  function resolve(address _jobOrKeeper) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;



interface IKeep3rKeeperFundable {
  // Events

  
  
  
  
  event Activation(address indexed _keeper, address indexed _bond, uint256 _amount);

  
  
  
  
  event Withdrawal(address indexed _keeper, address indexed _bond, uint256 _amount);

  // Errors

  
  error AlreadyAJob();

  // Methods

  
  
  
  function bond(address _bonding, uint256 _amount) external;

  
  
  
  function unbond(address _bonding, uint256 _amount) external;

  
  
  function activate(address _bonding) external;

  
  
  function withdraw(address _bonding) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;





abstract contract Keep3rDisputable is IKeep3rDisputable, Keep3rAccountance, Keep3rRoles {
  
  function dispute(address _jobOrKeeper) external override onlyDisputer {
    if (disputes[_jobOrKeeper]) revert AlreadyDisputed();
    disputes[_jobOrKeeper] = true;
    emit Dispute(_jobOrKeeper, msg.sender);
  }

  
  function resolve(address _jobOrKeeper) external override onlyDisputer {
    if (!disputes[_jobOrKeeper]) revert NotDisputed();
    disputes[_jobOrKeeper] = false;
    emit Resolve(_jobOrKeeper, msg.sender);
  }
}



interface IKeep3rJobManager {
  // Events

  
  
  
  event JobAddition(address indexed _job, address indexed _jobOwner);

  // Errors

  
  error JobAlreadyAdded();

  
  error AlreadyAKeeper();

  // Methods

  
  
  function addJob(address _job) external;
}



interface IKeep3rJobWorkable {
  // Events

  
  
  event KeeperValidation(uint256 _gasLeft);

  
  
  
  
  
  
  event KeeperWork(address indexed _credit, address indexed _job, address indexed _keeper, uint256 _payment, uint256 _gasLeft);

  // Errors

  
  error JobUnapproved();

  
  error InsufficientFunds();

  // Methods

  
  
  
  
  function isKeeper(address _keeper) external returns (bool _isKeeper);

  
  
  
  
  
  
  
  
  function isBondedKeeper(
    address _keeper,
    address _bond,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age
  ) external returns (bool _isBondedKeeper);

  
  
  
  function worked(address _keeper) external;

  
  
  
  
  function bondedPayment(address _keeper, uint256 _payment) external;

  
  
  
  
  
  function directTokenPayment(
    address _token,
    address _keeper,
    uint256 _amount
  ) external;
}



interface IKeep3rJobDisputable is IKeep3rJobFundableCredits, IKeep3rJobFundableLiquidity {
  // Events

  
  
  
  
  
  event JobSlashToken(address indexed _job, address _token, address indexed _slasher, uint256 _amount);

  
  
  
  
  
  event JobSlashLiquidity(address indexed _job, address _liquidity, address indexed _slasher, uint256 _amount);

  // Errors

  
  error JobTokenUnexistent();

  
  error JobTokenInsufficient();

  // Methods

  
  
  
  
  function slashTokenFromJob(
    address _job,
    address _token,
    uint256 _amount
  ) external;

  
  
  
  
  function slashLiquidityFromJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;





abstract contract Keep3rJobMigration is IKeep3rJobMigration, Keep3rJobFundableCredits, Keep3rJobFundableLiquidity {
  using EnumerableSet for EnumerableSet.AddressSet;

  uint256 internal constant _MIGRATION_COOLDOWN = 1 minutes;

  
  mapping(address => address) public override pendingJobMigrations;
  mapping(address => mapping(address => uint256)) internal _migrationCreatedAt;

  
  function migrateJob(address _fromJob, address _toJob) external override onlyJobOwner(_fromJob) {
    if (_fromJob == _toJob) revert JobMigrationImpossible();

    pendingJobMigrations[_fromJob] = _toJob;
    _migrationCreatedAt[_fromJob][_toJob] = block.timestamp;

    emit JobMigrationRequested(_fromJob, _toJob);
  }

  
  function acceptJobMigration(address _fromJob, address _toJob) external override onlyJobOwner(_toJob) {
    if (disputes[_fromJob] || disputes[_toJob]) revert JobDisputed();
    if (pendingJobMigrations[_fromJob] != _toJob) revert JobMigrationUnavailable();
    if (block.timestamp < _migrationCreatedAt[_fromJob][_toJob] + _MIGRATION_COOLDOWN) revert JobMigrationLocked();

    // force job credits update for both jobs
    _settleJobAccountance(_fromJob);
    _settleJobAccountance(_toJob);

    // migrate tokens
    while (_jobTokens[_fromJob].length() > 0) {
      address _tokenToMigrate = _jobTokens[_fromJob].at(0);
      jobTokenCredits[_toJob][_tokenToMigrate] += jobTokenCredits[_fromJob][_tokenToMigrate];
      delete jobTokenCredits[_fromJob][_tokenToMigrate];
      _jobTokens[_fromJob].remove(_tokenToMigrate);
      _jobTokens[_toJob].add(_tokenToMigrate);
    }

    // migrate liquidities
    while (_jobLiquidities[_fromJob].length() > 0) {
      address _liquidity = _jobLiquidities[_fromJob].at(0);

      liquidityAmount[_toJob][_liquidity] += liquidityAmount[_fromJob][_liquidity];
      delete liquidityAmount[_fromJob][_liquidity];

      _jobLiquidities[_toJob].add(_liquidity);
      _jobLiquidities[_fromJob].remove(_liquidity);
    }

    // migrate job balances
    _jobPeriodCredits[_toJob] += _jobPeriodCredits[_fromJob];
    delete _jobPeriodCredits[_fromJob];

    _jobLiquidityCredits[_toJob] += _jobLiquidityCredits[_fromJob];
    delete _jobLiquidityCredits[_fromJob];

    // stop _fromJob from being a job
    delete rewardedAt[_fromJob];
    _jobs.remove(_fromJob);

    // delete unused data slots
    delete jobOwner[_fromJob];
    delete jobPendingOwner[_fromJob];
    delete _migrationCreatedAt[_fromJob][_toJob];
    delete pendingJobMigrations[_fromJob];

    emit JobMigrationSuccessful(_fromJob, _toJob);
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;












abstract contract Keep3rKeeperFundable is IKeep3rKeeperFundable, ReentrancyGuard, Keep3rParameters {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;

  
  function bond(address _bonding, uint256 _amount) external override nonReentrant {
    if (disputes[msg.sender]) revert Disputed();
    if (_jobs.contains(msg.sender)) revert AlreadyAJob();
    canActivateAfter[msg.sender][_bonding] = block.timestamp + bondTime;

    uint256 _before = IERC20(_bonding).balanceOf(address(this));
    IERC20(_bonding).safeTransferFrom(msg.sender, address(this), _amount);
    _amount = IERC20(_bonding).balanceOf(address(this)) - _before;

    hasBonded[msg.sender] = true;
    pendingBonds[msg.sender][_bonding] += _amount;

    emit Bonding(msg.sender, _bonding, _amount);
  }

  
  function activate(address _bonding) external override {
    if (disputes[msg.sender]) revert Disputed();
    if (canActivateAfter[msg.sender][_bonding] == 0) revert BondsUnexistent();
    if (canActivateAfter[msg.sender][_bonding] >= block.timestamp) revert BondsLocked();

    delete canActivateAfter[msg.sender][_bonding];

    uint256 _amount = _activate(msg.sender, _bonding);
    emit Activation(msg.sender, _bonding, _amount);
  }

  
  function unbond(address _bonding, uint256 _amount) external override {
    canWithdrawAfter[msg.sender][_bonding] = block.timestamp + unbondTime;
    bonds[msg.sender][_bonding] -= _amount;
    pendingUnbonds[msg.sender][_bonding] += _amount;

    emit Unbonding(msg.sender, _bonding, _amount);
  }

  
  function withdraw(address _bonding) external override nonReentrant {
    if (pendingUnbonds[msg.sender][_bonding] == 0) revert UnbondsUnexistent();
    if (canWithdrawAfter[msg.sender][_bonding] >= block.timestamp) revert UnbondsLocked();
    if (disputes[msg.sender]) revert Disputed();

    uint256 _amount = pendingUnbonds[msg.sender][_bonding];

    if (_bonding == keep3rV1) {
      IKeep3rV1Proxy(keep3rV1Proxy).mint(_amount);
    }

    delete pendingUnbonds[msg.sender][_bonding];
    delete canWithdrawAfter[msg.sender][_bonding];

    IERC20(_bonding).safeTransfer(msg.sender, _amount);

    emit Withdrawal(msg.sender, _bonding, _amount);
  }

  function _activate(address _keeper, address _bonding) internal returns (uint256 _amount) {
    if (firstSeen[_keeper] == 0) {
      firstSeen[_keeper] = block.timestamp;
    }
    _keepers.add(_keeper);
    _amount = pendingBonds[_keeper][_bonding];
    delete pendingBonds[_keeper][_bonding];

    // bond provided tokens
    bonds[_keeper][_bonding] += _amount;
    if (_bonding == keep3rV1) {
      IKeep3rV1(keep3rV1).burn(_amount);
    }
  }
}



interface IKeep3rKeeperDisputable {
  // Events

  
  
  
  
  event KeeperSlash(address indexed _keeper, address indexed _slasher, uint256 _amount);

  
  
  
  event KeeperRevoke(address indexed _keeper, address indexed _slasher);

  // Methods

  
  
  
  
  
  function slash(
    address _keeper,
    address _bonded,
    uint256 _bondAmount,
    uint256 _unbondAmount
  ) external;

  
  
  function revoke(address _keeper) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;





abstract contract Keep3rJobDisputable is IKeep3rJobDisputable, Keep3rDisputable, Keep3rJobFundableCredits, Keep3rJobFundableLiquidity {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;

  
  function slashTokenFromJob(
    address _job,
    address _token,
    uint256 _amount
  ) external override onlySlasher {
    if (!disputes[_job]) revert NotDisputed();
    if (!_jobTokens[_job].contains(_token)) revert JobTokenUnexistent();
    if (jobTokenCredits[_job][_token] < _amount) revert JobTokenInsufficient();

    try IERC20(_token).transfer(governance, _amount) {} catch {}
    jobTokenCredits[_job][_token] -= _amount;
    if (jobTokenCredits[_job][_token] == 0) {
      _jobTokens[_job].remove(_token);
    }

    emit JobSlashToken(_job, _token, msg.sender, _amount);
  }

  
  function slashLiquidityFromJob(
    address _job,
    address _liquidity,
    uint256 _amount
  ) external override onlySlasher {
    if (!disputes[_job]) revert NotDisputed();

    _unbondLiquidityFromJob(_job, _liquidity, _amount);
    try IERC20(_liquidity).transfer(governance, _amount) {} catch {}
    emit JobSlashLiquidity(_job, _liquidity, msg.sender, _amount);
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;








abstract contract Keep3rJobWorkable is IKeep3rJobWorkable, Keep3rJobMigration {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;

  uint256 internal _initialGas;

  
  function isKeeper(address _keeper) external override returns (bool _isKeeper) {
    _initialGas = _getGasLeft();
    if (_keepers.contains(_keeper)) {
      emit KeeperValidation(_initialGas);
      return true;
    }
  }

  
  function isBondedKeeper(
    address _keeper,
    address _bond,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age
  ) public override returns (bool _isBondedKeeper) {
    _initialGas = _getGasLeft();
    if (
      _keepers.contains(_keeper) &&
      bonds[_keeper][_bond] >= _minBond &&
      workCompleted[_keeper] >= _earned &&
      block.timestamp - firstSeen[_keeper] >= _age
    ) {
      emit KeeperValidation(_initialGas);
      return true;
    }
  }

  
  function worked(address _keeper) external override {
    address _job = msg.sender;
    if (disputes[_job]) revert JobDisputed();
    if (!_jobs.contains(_job)) revert JobUnapproved();

    if (_updateJobCreditsIfNeeded(_job)) {
      emit LiquidityCreditsReward(_job, rewardedAt[_job], _jobLiquidityCredits[_job], _jobPeriodCredits[_job]);
    }

    (uint256 _boost, uint256 _oneEthQuote, uint256 _extraGas) = IKeep3rHelper(keep3rHelper).getPaymentParams(bonds[_keeper][keep3rV1]);

    uint256 _gasLeft = _getGasLeft();
    uint256 _payment = _calculatePayment(_gasLeft, _extraGas, _oneEthQuote, _boost);

    if (_payment > _jobLiquidityCredits[_job]) {
      _rewardJobCredits(_job);
      emit LiquidityCreditsReward(_job, rewardedAt[_job], _jobLiquidityCredits[_job], _jobPeriodCredits[_job]);

      _gasLeft = _getGasLeft();
      _payment = _calculatePayment(_gasLeft, _extraGas, _oneEthQuote, _boost);
    }

    _bondedPayment(_job, _keeper, _payment);
    emit KeeperWork(keep3rV1, _job, _keeper, _payment, _gasLeft);
  }

  
  function bondedPayment(address _keeper, uint256 _payment) public override {
    address _job = msg.sender;

    if (disputes[_job]) revert JobDisputed();
    if (!_jobs.contains(_job)) revert JobUnapproved();

    if (_updateJobCreditsIfNeeded(_job)) {
      emit LiquidityCreditsReward(_job, rewardedAt[_job], _jobLiquidityCredits[_job], _jobPeriodCredits[_job]);
    }

    if (_payment > _jobLiquidityCredits[_job]) {
      _rewardJobCredits(_job);
      emit LiquidityCreditsReward(_job, rewardedAt[_job], _jobLiquidityCredits[_job], _jobPeriodCredits[_job]);
    }

    _bondedPayment(_job, _keeper, _payment);
    emit KeeperWork(keep3rV1, _job, _keeper, _payment, _getGasLeft());
  }

  
  function directTokenPayment(
    address _token,
    address _keeper,
    uint256 _amount
  ) external override {
    address _job = msg.sender;

    if (disputes[_job]) revert JobDisputed();
    if (disputes[_keeper]) revert Disputed();
    if (!_jobs.contains(_job)) revert JobUnapproved();
    if (jobTokenCredits[_job][_token] < _amount) revert InsufficientFunds();
    jobTokenCredits[_job][_token] -= _amount;
    IERC20(_token).safeTransfer(_keeper, _amount);
    emit KeeperWork(_token, _job, _keeper, _amount, _getGasLeft());
  }

  function _bondedPayment(
    address _job,
    address _keeper,
    uint256 _payment
  ) internal {
    if (_payment > _jobLiquidityCredits[_job]) revert InsufficientFunds();

    workedAt[_job] = block.timestamp;
    _jobLiquidityCredits[_job] -= _payment;
    bonds[_keeper][keep3rV1] += _payment;
    workCompleted[_keeper] += _payment;
  }

  
  
  
  
  
  
  function _calculatePayment(
    uint256 _gasLeft,
    uint256 _extraGas,
    uint256 _oneEthQuote,
    uint256 _boost
  ) internal view returns (uint256 _payment) {
    uint256 _accountedGas = _initialGas - _gasLeft + _extraGas;
    _payment = (((_accountedGas * _boost) / _BASE) * _oneEthQuote) / 1 ether;
  }

  
  
  function _getGasLeft() internal view returns (uint256 _gasLeft) {
    _gasLeft = (gasleft() * 64) / 63;
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;






abstract contract Keep3rJobManager is IKeep3rJobManager, Keep3rJobOwnership, Keep3rRoles, Keep3rParameters {
  using EnumerableSet for EnumerableSet.AddressSet;

  
  function addJob(address _job) external override {
    if (_jobs.contains(_job)) revert JobAlreadyAdded();
    if (hasBonded[_job]) revert AlreadyAKeeper();
    _jobs.add(_job);
    jobOwner[_job] = msg.sender;
    emit JobAddition(msg.sender, _job);
  }
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// 
pragma solidity >=0.8.4 <0.9.0;






abstract contract Keep3rKeeperDisputable is IKeep3rKeeperDisputable, Keep3rDisputable, Keep3rKeeperFundable {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;

  
  function slash(
    address _keeper,
    address _bonded,
    uint256 _bondAmount,
    uint256 _unbondAmount
  ) public override onlySlasher {
    if (!disputes[_keeper]) revert NotDisputed();
    _slash(_keeper, _bonded, _bondAmount, _unbondAmount);
    emit KeeperSlash(_keeper, msg.sender, _bondAmount + _unbondAmount);
  }

  
  function revoke(address _keeper) external override onlySlasher {
    if (!disputes[_keeper]) revert NotDisputed();
    _keepers.remove(_keeper);
    _slash(_keeper, keep3rV1, bonds[_keeper][keep3rV1], pendingUnbonds[_keeper][keep3rV1]);
    emit KeeperRevoke(_keeper, msg.sender);
  }

  function _slash(
    address _keeper,
    address _bonded,
    uint256 _bondAmount,
    uint256 _unbondAmount
  ) internal {
    if (_bonded != keep3rV1) {
      try IERC20(_bonded).transfer(governance, _bondAmount + _unbondAmount) returns (bool) {} catch (bytes memory) {}
    }
    bonds[_keeper][_bonded] -= _bondAmount;
    pendingUnbonds[_keeper][_bonded] -= _unbondAmount;
  }
}

// 

pragma solidity >=0.8.4 <0.9.0;



interface IDustCollector is IBaseErrors {
  
  
  
  
  event DustSent(address _token, uint256 _amount, address _to);

  
  
  
  
  function sendDust(
    address _token,
    uint256 _amount,
    address _to
  ) external;
}
// 
pragma solidity >=0.8.4 <0.9.0;





abstract contract Keep3rJobs is Keep3rJobDisputable, Keep3rJobManager, Keep3rJobWorkable {}

// 
pragma solidity >=0.8.4 <0.9.0;



abstract contract Keep3rKeepers is Keep3rKeeperDisputable {}

// 

pragma solidity >=0.8.4 <0.9.0;






abstract contract DustCollector is IDustCollector, Governable {
  using SafeERC20 for IERC20;

  address internal constant _ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  function sendDust(
    address _token,
    uint256 _amount,
    address _to
  ) external override onlyGovernance {
    if (_to == address(0)) revert ZeroAddress();
    if (_token == _ETH_ADDRESS) {
      payable(_to).transfer(_amount);
    } else {
      IERC20(_token).safeTransfer(_to, _amount);
    }
    emit DustSent(_token, _amount, _to);
  }
}

// 

pragma solidity ^0.8.0;



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// 

/*

Coded for The Keep3r Network with ♥ by

██████╗░███████╗███████╗██╗  ░██╗░░░░░░░██╗░█████╗░███╗░░██╗██████╗░███████╗██████╗░██╗░░░░░░█████╗░███╗░░██╗██████╗░
██╔══██╗██╔════╝██╔════╝██║  ░██║░░██╗░░██║██╔══██╗████╗░██║██╔══██╗██╔════╝██╔══██╗██║░░░░░██╔══██╗████╗░██║██╔══██╗
██║░░██║█████╗░░█████╗░░██║  ░╚██╗████╗██╔╝██║░░██║██╔██╗██║██║░░██║█████╗░░██████╔╝██║░░░░░███████║██╔██╗██║██║░░██║
██║░░██║██╔══╝░░██╔══╝░░██║  ░░████╔═████║░██║░░██║██║╚████║██║░░██║██╔══╝░░██╔══██╗██║░░░░░██╔══██║██║╚████║██║░░██║
██████╔╝███████╗██║░░░░░██║  ░░╚██╔╝░╚██╔╝░╚█████╔╝██║░╚███║██████╔╝███████╗██║░░██║███████╗██║░░██║██║░╚███║██████╔╝
╚═════╝░╚══════╝╚═╝░░░░░╚═╝  ░░░╚═╝░░░╚═╝░░░╚════╝░╚═╝░░╚══╝╚═════╝░╚══════╝╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░

https://defi.sucks

*/

pragma solidity >=0.8.4 <0.9.0;








contract Keep3r is DustCollector, Keep3rJobs, Keep3rKeepers {
  constructor(
    address _governance,
    address _keep3rHelper,
    address _keep3rV1,
    address _keep3rV1Proxy,
    address _kp3rWethPool
  ) Keep3rParameters(_keep3rHelper, _keep3rV1, _keep3rV1Proxy, _kp3rWethPool) Keep3rRoles(_governance) DustCollector() {}
}

// solhint-disable-next-line no-empty-blocks
interface IKeep3rJobs is IKeep3rJobOwnership, IKeep3rJobDisputable, IKeep3rJobMigration, IKeep3rJobManager, IKeep3rJobWorkable {

}

// 

pragma solidity ^0.8.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// 

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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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
pragma solidity >=0.8.4 <0.9.0;




interface IKeep3rHelper {
  // Errors

  
  error LiquidityPairInvalid();

  // Methods
  // solhint-enable func-name-mixedcase

  
  
  
  
  function quote(uint256 _eth) external view returns (uint256 _amountOut);

  
  
  
  function bonds(address _keeper) external view returns (uint256 _amountBonded);

  
  
  
  
  function getRewardAmountFor(address _keeper, uint256 _gasUsed) external view returns (uint256 _kp3r);

  
  
  
  function getRewardBoostFor(uint256 _bonds) external view returns (uint256 _rewardBoost);

  
  
  
  function getRewardAmount(uint256 _gasUsed) external view returns (uint256 _amount);

  
  
  
  
  function getPoolTokens(address _pool) external view returns (address _token0, address _token1);

  
  
  
  function isKP3RToken0(address _pool) external view returns (bool _isKP3RToken0);

  
  
  
  
  
  
  function observe(address _pool, uint32[] memory _secondsAgo)
    external
    view
    returns (
      int56 _tickCumulative1,
      int56 _tickCumulative2,
      bool _success
    );

  
  
  
  
  
  function getPaymentParams(uint256 _bonds)
    external
    view
    returns (
      uint256 _boost,
      uint256 _oneEthQuote,
      uint256 _extra
    );

  
  
  
  
  
  function getKP3RsAtTick(
    uint256 _liquidityAmount,
    int56 _tickDifference,
    uint256 _timeInterval
  ) external pure returns (uint256 _kp3rAmount);

  
  
  
  
  
  function getQuoteAtTick(
    uint128 _baseAmount,
    int56 _tickDifference,
    uint256 _timeInterval
  ) external pure returns (uint256 _quoteAmount);
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// 
pragma solidity >=0.8.4 <0.9.0;





interface IPairManager is IERC20Metadata {
  
  
  function factory() external view returns (address _factory);

  
  
  function pool() external view returns (address _pool);

  
  
  function token0() external view returns (address _token0);

  
  
  function token1() external view returns (address _token1);
}

// 
pragma solidity >=0.8.4 <0.9.0;




library FullMath {
  
  
  
  
  
  
  function mulDiv(
    uint256 a,
    uint256 b,
    uint256 denominator
  ) internal pure returns (uint256 result) {
    unchecked {
      // 512-bit multiply [prod1 prod0] = a * b
      // Compute the product mod 2**256 and mod 2**256 - 1
      // then use the Chinese Remainder Theorem to reconstruct
      // the 512 bit result. The result is stored in two 256
      // variables such that product = prod1 * 2**256 + prod0
      uint256 prod0; // Least significant 256 bits of the product
      uint256 prod1; // Most significant 256 bits of the product
      assembly {
        let mm := mulmod(a, b, not(0))
        prod0 := mul(a, b)
        prod1 := sub(sub(mm, prod0), lt(mm, prod0))
      }

      // Handle non-overflow cases, 256 by 256 division
      if (prod1 == 0) {
        require(denominator > 0);
        assembly {
          result := div(prod0, denominator)
        }
        return result;
      }

      // Make sure the result is less than 2**256.
      // Also prevents denominator == 0
      require(denominator > prod1);

      ///////////////////////////////////////////////
      // 512 by 256 division.
      ///////////////////////////////////////////////

      // Make division exact by subtracting the remainder from [prod1 prod0]
      // Compute remainder using mulmod
      uint256 remainder;
      assembly {
        remainder := mulmod(a, b, denominator)
      }
      // Subtract 256 bit number from 512 bit number
      assembly {
        prod1 := sub(prod1, gt(remainder, prod0))
        prod0 := sub(prod0, remainder)
      }

      // Factor powers of two out of denominator
      // Compute largest power of two divisor of denominator.
      // Always >= 1.
      uint256 twos = (~denominator + 1) & denominator;
      // Divide denominator by power of two
      assembly {
        denominator := div(denominator, twos)
      }

      // Divide [prod1 prod0] by the factors of two
      assembly {
        prod0 := div(prod0, twos)
      }
      // Shift in bits from prod1 into prod0. For this we need
      // to flip `twos` such that it is 2**256 / twos.
      // If twos is zero, then it becomes one
      assembly {
        twos := add(div(sub(0, twos), twos), 1)
      }
      prod0 |= prod1 * twos;

      // Invert denominator mod 2**256
      // Now that denominator is an odd number, it has an inverse
      // modulo 2**256 such that denominator * inv = 1 mod 2**256.
      // Compute the inverse by starting with a seed that is correct
      // correct for four bits. That is, denominator * inv = 1 mod 2**4
      uint256 inv = (3 * denominator) ^ 2;
      // Now use Newton-Raphson iteration to improve the precision.
      // Thanks to Hensel's lifting lemma, this also works in modular
      // arithmetic, doubling the correct bits in each step.
      inv *= 2 - denominator * inv; // inverse mod 2**8
      inv *= 2 - denominator * inv; // inverse mod 2**16
      inv *= 2 - denominator * inv; // inverse mod 2**32
      inv *= 2 - denominator * inv; // inverse mod 2**64
      inv *= 2 - denominator * inv; // inverse mod 2**128
      inv *= 2 - denominator * inv; // inverse mod 2**256

      // Because the division is now exact we can divide by multiplying
      // with the modular inverse of denominator. This will give us the
      // correct result modulo 2**256. Since the precoditions guarantee
      // that the outcome is less than 2**256, this is the final result.
      // We don't need to compute the high bits of the result and prod1
      // is no longer required.
      result = prod0 * inv;
      return result;
    }
  }

  
  
  
  
  
  function mulDivRoundingUp(
    uint256 a,
    uint256 b,
    uint256 denominator
  ) internal pure returns (uint256 result) {
    unchecked {
      result = mulDiv(a, b, denominator);
      if (mulmod(a, b, denominator) > 0) {
        require(result < type(uint256).max);
        result++;
      }
    }
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;




// solhint-disable func-name-mixedcase
interface IKeep3rV1 is IERC20, IERC20Metadata {
  // Structs
  struct Checkpoint {
    uint32 fromBlock;
    uint256 votes;
  }

  // Events
  event DelegateChanged(address indexed _delegator, address indexed _fromDelegate, address indexed _toDelegate);
  event DelegateVotesChanged(address indexed _delegate, uint256 _previousBalance, uint256 _newBalance);
  event SubmitJob(address indexed _job, address indexed _liquidity, address indexed _provider, uint256 _block, uint256 _credit);
  event ApplyCredit(address indexed _job, address indexed _liquidity, address indexed _provider, uint256 _block, uint256 _credit);
  event RemoveJob(address indexed _job, address indexed _liquidity, address indexed _provider, uint256 _block, uint256 _credit);
  event UnbondJob(address indexed _job, address indexed _liquidity, address indexed _provider, uint256 _block, uint256 _credit);
  event JobAdded(address indexed _job, uint256 _block, address _governance);
  event JobRemoved(address indexed _job, uint256 _block, address _governance);
  event KeeperWorked(address indexed _credit, address indexed _job, address indexed _keeper, uint256 _block, uint256 _amount);
  event KeeperBonding(address indexed _keeper, uint256 _block, uint256 _active, uint256 _bond);
  event KeeperBonded(address indexed _keeper, uint256 _block, uint256 _activated, uint256 _bond);
  event KeeperUnbonding(address indexed _keeper, uint256 _block, uint256 _deactive, uint256 _bond);
  event KeeperUnbound(address indexed _keeper, uint256 _block, uint256 _deactivated, uint256 _bond);
  event KeeperSlashed(address indexed _keeper, address indexed _slasher, uint256 _block, uint256 _slash);
  event KeeperDispute(address indexed _keeper, uint256 _block);
  event KeeperResolved(address indexed _keeper, uint256 _block);
  event TokenCreditAddition(address indexed _credit, address indexed _job, address indexed _creditor, uint256 _block, uint256 _amount);

  // Variables
  function KPRH() external returns (address);

  function delegates(address _delegator) external view returns (address);

  function checkpoints(address _account, uint32 _checkpoint) external view returns (Checkpoint memory);

  function numCheckpoints(address _account) external view returns (uint32);

  function DOMAIN_TYPEHASH() external returns (bytes32);

  function DOMAINSEPARATOR() external returns (bytes32);

  function DELEGATION_TYPEHASH() external returns (bytes32);

  function PERMIT_TYPEHASH() external returns (bytes32);

  function nonces(address _user) external view returns (uint256);

  function BOND() external returns (uint256);

  function UNBOND() external returns (uint256);

  function LIQUIDITYBOND() external returns (uint256);

  function FEE() external returns (uint256);

  function BASE() external returns (uint256);

  function ETH() external returns (address);

  function bondings(address _user, address _bonding) external view returns (uint256);

  function canWithdrawAfter(address _user, address _bonding) external view returns (uint256);

  function pendingUnbonds(address _keeper, address _bonding) external view returns (uint256);

  function pendingbonds(address _keeper, address _bonding) external view returns (uint256);

  function bonds(address _keeper, address _bonding) external view returns (uint256);

  function votes(address _delegator) external view returns (uint256);

  function firstSeen(address _keeper) external view returns (uint256);

  function disputes(address _keeper) external view returns (bool);

  function lastJob(address _keeper) external view returns (uint256);

  function workCompleted(address _keeper) external view returns (uint256);

  function jobs(address _job) external view returns (bool);

  function credits(address _job, address _credit) external view returns (uint256);

  function liquidityProvided(
    address _provider,
    address _liquidity,
    address _job
  ) external view returns (uint256);

  function liquidityUnbonding(
    address _provider,
    address _liquidity,
    address _job
  ) external view returns (uint256);

  function liquidityAmountsUnbonding(
    address _provider,
    address _liquidity,
    address _job
  ) external view returns (uint256);

  function jobProposalDelay(address _job) external view returns (uint256);

  function liquidityApplied(
    address _provider,
    address _liquidity,
    address _job
  ) external view returns (uint256);

  function liquidityAmount(
    address _provider,
    address _liquidity,
    address _job
  ) external view returns (uint256);

  function keepers(address _keeper) external view returns (bool);

  function blacklist(address _keeper) external view returns (bool);

  function keeperList(uint256 _index) external view returns (address);

  function jobList(uint256 _index) external view returns (address);

  function governance() external returns (address);

  function pendingGovernance() external returns (address);

  function liquidityAccepted(address _liquidity) external view returns (bool);

  function liquidityPairs(uint256 _index) external view returns (address);

  // Methods
  function getCurrentVotes(address _account) external view returns (uint256);

  function addCreditETH(address _job) external payable;

  function addCredit(
    address _credit,
    address _job,
    uint256 _amount
  ) external;

  function addVotes(address _voter, uint256 _amount) external;

  function removeVotes(address _voter, uint256 _amount) external;

  function addKPRCredit(address _job, uint256 _amount) external;

  function approveLiquidity(address _liquidity) external;

  function revokeLiquidity(address _liquidity) external;

  function pairs() external view returns (address[] memory);

  function addLiquidityToJob(
    address _liquidity,
    address _job,
    uint256 _amount
  ) external;

  function applyCreditToJob(
    address _provider,
    address _liquidity,
    address _job
  ) external;

  function unbondLiquidityFromJob(
    address _liquidity,
    address _job,
    uint256 _amount
  ) external;

  function removeLiquidityFromJob(address _liquidity, address _job) external;

  function mint(uint256 _amount) external;

  function burn(uint256 _amount) external;

  function worked(address _keeper) external;

  function receipt(
    address _credit,
    address _keeper,
    uint256 _amount
  ) external;

  function receiptETH(address _keeper, uint256 _amount) external;

  function addJob(address _job) external;

  function getJobs() external view returns (address[] memory);

  function removeJob(address _job) external;

  function setKeep3rHelper(address _keep3rHelper) external;

  function setGovernance(address _governance) external;

  function acceptGovernance() external;

  function isKeeper(address _keeper) external returns (bool);

  function isMinKeeper(
    address _keeper,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age
  ) external returns (bool);

  function isBondedKeeper(
    address _keeper,
    address _bond,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age
  ) external returns (bool);

  function bond(address _bonding, uint256 _amount) external;

  function getKeepers() external view returns (address[] memory);

  function activate(address _bonding) external;

  function unbond(address _bonding, uint256 _amount) external;

  function slash(
    address _bonded,
    address _keeper,
    uint256 _amount
  ) external;

  function withdraw(address _bonding) external;

  function dispute(address _keeper) external;

  function revoke(address _keeper) external;

  function resolve(address _keeper) external;

  function permit(
    address _owner,
    address _spender,
    uint256 _amount,
    uint256 _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external;
}

// solhint-disable-next-line no-empty-blocks


interface IKeep3rKeepers is IKeep3rKeeperDisputable {

}

// 
pragma solidity >=0.8.4 <0.9.0;



interface IKeep3rV1Proxy is IGovernable {
  // Structs
  struct Recipient {
    address recipient;
    uint256 caps;
  }

  // Variables
  function keep3rV1() external view returns (address);

  function minter() external view returns (address);

  function next(address) external view returns (uint256);

  function caps(address) external view returns (uint256);

  function recipients() external view returns (address[] memory);

  function recipientsCaps() external view returns (Recipient[] memory);

  // Errors
  error Cooldown();
  error NoDrawableAmount();
  error ZeroAddress();
  error OnlyMinter();

  // Methods
  function addRecipient(address recipient, uint256 amount) external;

  function removeRecipient(address recipient) external;

  function draw() external returns (uint256 _amount);

  function setKeep3rV1(address _keep3rV1) external;

  function setMinter(address _minter) external;

  function mint(uint256 _amount) external;

  function mint(address _account, uint256 _amount) external;

  function setKeep3rV1Governance(address _governance) external;

  function acceptKeep3rV1Governance() external;

  function dispute(address _keeper) external;

  function slash(
    address _bonded,
    address _keeper,
    uint256 _amount
  ) external;

  function revoke(address _keeper) external;

  function resolve(address _keeper) external;

  function addJob(address _job) external;

  function removeJob(address _job) external;

  function addKPRCredit(address _job, uint256 _amount) external;

  function approveLiquidity(address _liquidity) external;

  function revokeLiquidity(address _liquidity) external;

  function setKeep3rHelper(address _keep3rHelper) external;

  function addVotes(address _voter, uint256 _amount) external;

  function removeVotes(address _voter, uint256 _amount) external;
}
