// SPDX-License-Identifier: MIT


// 

pragma solidity >=0.8.4 <0.9.0;

interface IBaseErrors {
  
  error ZeroAddress();
}

// 
pragma solidity >=0.8.4 <0.9.0;



interface IGovernable is IBaseErrors {
  // events
  
  event PendingGovernorSet(address _governor, address _pendingGovernor);
  
  event PendingGovernorAccepted(address _newGovernor);

  // errors
  
  error OnlyGovernor();
  
  error OnlyPendingGovernor();

  // variables
  
  
  function governor() external view returns (address _governor);

  
  
  function pendingGovernor() external view returns (address _pendingGovernor);

  // methods
  
  
  function setPendingGovernor(address _pendingGovernor) external;

  
  function acceptPendingGovernor() external;
}

// 
pragma solidity >=0.8.4 <0.9.0;



abstract contract Governable is IGovernable {
  address public override governor;
  address public override pendingGovernor;

  constructor(address _governor) {
    if (_governor == address(0)) revert ZeroAddress();
    governor = _governor;
  }

  function setPendingGovernor(address _pendingGovernor) external override onlyGovernor {
    if (_pendingGovernor == address(0)) revert ZeroAddress();
    pendingGovernor = _pendingGovernor;
    emit PendingGovernorSet(governor, pendingGovernor);
  }

  function acceptPendingGovernor() external override onlyPendingGovernor {
    governor = pendingGovernor;
    pendingGovernor = address(0);
    emit PendingGovernorAccepted(governor);
  }

  modifier onlyGovernor() {
    if (msg.sender != governor) revert OnlyGovernor();
    _;
  }

  modifier onlyPendingGovernor() {
    if (msg.sender != pendingGovernor) revert OnlyPendingGovernor();
    _;
  }
}

// 

pragma solidity >=0.8.4 <0.9.0;



interface IMakerDAOParameters {
  // Events

  
  
  
  event BufferSet(uint256 _minBuffer, uint256 _maxBuffer);

  
  
  
  
  
  
  event VestSet(uint256 indexed _vestId, uint48 _bgn, uint48 _clf, uint48 _fin, uint128 _tot);

  // Errors

  
  error IncorrectVestId();
  
  error OnlyMaker();

  // Views

  
  function DAI() external view returns (address dai);

  
  function DAI_JOIN() external view returns (address daiJoin);

  
  function DSS_VEST() external view returns (address dssVest);

  
  function MAKER_DAO() external view returns (address makerDao);

  
  function VOW() external view returns (address vow);

  
  function minBuffer() external view returns (uint256 minBuffer);

  
  function maxBuffer() external view returns (uint256 maxBuffer);

  
  function buffer() external view returns (uint256 minBuffer, uint256 maxBuffer);

  // Methods

  
  function vestId() external view returns (uint256 vestId);

  
  function setBuffer(uint256 _minBuffer, uint256 _maxBuffer) external;

  
  function setVestId(uint256 _vestId) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;



interface IDustCollector is IGovernable {
  
  
  
  
  event DustSent(address _token, uint256 _amount, address _to);

  
  
  
  
  function sendDust(
    address _token,
    uint256 _amount,
    address _to
  ) external;
}

// 

pragma solidity >=0.8.4 <0.9.0;




contract MakerDAOParameters is IMakerDAOParameters {
  address public constant override DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address public constant override DAI_JOIN = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
  address public constant override DSS_VEST = 0x2Cc583c0AaCDaC9e23CB601fDA8F1A0c56Cdcb71;
  address public constant override MAKER_DAO = 0xBE8E3e3618f7474F8cB1d074A26afFef007E98FB;
  address public constant override VOW = 0xA950524441892A31ebddF91d3cEEFa04Bf454466;

  uint256 public override minBuffer = 4_000 ether;
  uint256 public override maxBuffer = 20_000 ether;
  uint256 public override vestId; // TBD

  constructor() {
    emit BufferSet(minBuffer, maxBuffer);
  }

  // Views

  
  function buffer() external view override returns (uint256 _minBuffer, uint256 _maxBuffer) {
    return (minBuffer, maxBuffer);
  }

  // Setters

  
  function setBuffer(uint256 _minBuffer, uint256 _maxBuffer) external onlyMaker {
    minBuffer = _minBuffer;
    maxBuffer = _maxBuffer;

    emit BufferSet(_minBuffer, _maxBuffer);
  }

  
  function setVestId(uint256 _vestId) public onlyMaker {
    (address _usr, uint48 _bgn, uint48 _clf, uint48 _fin, , , uint128 _tot, ) = IDssVest(DSS_VEST).awards(_vestId);
    if (_usr != address(this)) revert IncorrectVestId();
    vestId = _vestId;

    emit VestSet(_vestId, _bgn, _clf, _fin, _tot);
  }

  // Modifiers

  modifier onlyMaker() {
    if (msg.sender != MAKER_DAO) revert OnlyMaker();
    _;
  }
}

// 

pragma solidity >=0.8.4 <0.9.0;






abstract contract DustCollector is IDustCollector, Governable {
  using SafeERC20 for IERC20;

  address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  function sendDust(
    address _token,
    uint256 _amount,
    address _to
  ) external override onlyGovernor {
    if (_to == address(0)) revert ZeroAddress();
    if (_token == ETH_ADDRESS) {
      payable(_to).transfer(_amount);
    } else {
      IERC20(_token).safeTransfer(_to, _amount);
    }
    emit DustSent(_token, _amount, _to);
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;



interface IMakerDAOBudgetManager {
  // Events

  
  
  
  
  
  event InvoicedGas(uint256 indexed _nonce, uint256 _gasCostETH, uint256 _claimableDai, string _description);

  
  
  event DeletedInvoice(uint256 indexed _nonce);

  
  
  
  
  
  event ClaimedDai(uint256 _claimed, uint256 _refilled, uint256 _returned);

  
  
  
  
  event Keep3rJobSet(address _keep3r, address _job);

  
  
  event KeeperSet(address _keeper);

  // Errors

  
  error MinBuffer();
  
  error InvoiceClaimed();
  
  error OnlyKeeper();

  // Views

  
  
  function daiToClaim() external returns (uint256 _dai);

  
  function keep3r() external returns (address _keep3r);

  
  function job() external returns (address _job);

  
  function keeper() external returns (address _keeper);

  
  
  
  function invoiceAmount(uint256 _invoiceNonce) external returns (uint256 _invoiceDai);

  
  function invoiceNonce() external returns (uint256);

  
  
  function credits() external view returns (uint256 _daiCredits);

  // Methods

  
  
  
  
  function invoiceGas(
    uint256 _gasCostETH,
    uint256 _claimableDai,
    string memory _description
  ) external;

  
  
  function deleteInvoice(uint256 _invoiceNonce) external;

  
  function claimDai() external;

  
  function claimDaiUpkeep() external;

  
  
  
  function setKeep3rJob(address _keep3r, address _job) external;

  
  
  function setKeeper(address _keeper) external;
}
// 

/*

  Coded for MakerDAO and The Keep3r Network with ♥ by
  ██████╗░███████╗███████╗██╗  ░██╗░░░░░░░██╗░█████╗░███╗░░██╗██████╗░███████╗██████╗░██╗░░░░░░█████╗░███╗░░██╗██████╗░
  ██╔══██╗██╔════╝██╔════╝██║  ░██║░░██╗░░██║██╔══██╗████╗░██║██╔══██╗██╔════╝██╔══██╗██║░░░░░██╔══██╗████╗░██║██╔══██╗
  ██║░░██║█████╗░░█████╗░░██║  ░╚██╗████╗██╔╝██║░░██║██╔██╗██║██║░░██║█████╗░░██████╔╝██║░░░░░███████║██╔██╗██║██║░░██║
  ██║░░██║██╔══╝░░██╔══╝░░██║  ░░████╔═████║░██║░░██║██║╚████║██║░░██║██╔══╝░░██╔══██╗██║░░░░░██╔══██║██║╚████║██║░░██║
  ██████╔╝███████╗██║░░░░░██║  ░░╚██╔╝░╚██╔╝░╚█████╔╝██║░╚███║██████╔╝███████╗██║░░██║███████╗██║░░██║██║░╚███║██████╔╝
  ╚═════╝░╚══════╝╚═╝░░░░░╚═╝  ░░░╚═╝░░░╚═╝░░░╚════╝░╚═╝░░╚══╝╚═════╝░╚══════╝╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░
  https://defi.sucks

*/

pragma solidity >=0.8.4 <0.9.0;












contract MakerDAOBudgetManager is IMakerDAOBudgetManager, MakerDAOParameters, Governable, DustCollector {
  address public override keep3r = 0xeb02addCfD8B773A5FFA6B9d1FE99c566f8c44CC;
  address public override job = 0x5D469E1ef75507b0E0439667ae45e280b9D81B9C;
  address public override keeper;

  uint256 public override daiToClaim;
  uint256 public override invoiceNonce;
  mapping(uint256 => uint256) public override invoiceAmount;

  constructor(address _governor) Governable(_governor) {
    emit Keep3rJobSet(keep3r, job);
    IERC20(DAI).approve(DAI_JOIN, type(uint256).max);
  }

  // Views

  
  function credits() public view override returns (uint256 _daiCredits) {
    return IKeep3rV2(keep3r).jobTokenCredits(job, DAI);
  }

  // Methods

  
  function invoiceGas(
    uint256 _gasCostETH,
    uint256 _claimableDai,
    string memory _description
  ) external override onlyGovernor {
    daiToClaim += _claimableDai;
    invoiceAmount[++invoiceNonce] = _claimableDai;

    // emits event to be tracked in DuneAnalytics dashboard & contrast with txs
    emit InvoicedGas(invoiceNonce, _gasCostETH, _claimableDai, _description);
  }

  
  function deleteInvoice(uint256 _invoiceNonce) external override onlyGovernor {
    uint256 deleteAmount = invoiceAmount[_invoiceNonce];
    if (deleteAmount > daiToClaim) revert InvoiceClaimed();

    daiToClaim -= deleteAmount;
    delete invoiceAmount[_invoiceNonce];

    // emits event to filter out InvoicedGas events
    emit DeletedInvoice(_invoiceNonce);
  }

  
  function claimDai() external override onlyGovernor {
    _claimDai();
  }

  
  function claimDaiUpkeep() external override onlyKeeper {
    _claimDai();
  }

  
  function _claimDai() internal {
    // claims DAI
    uint256 daiAmount = IERC20(DAI).balanceOf(address(this));
    IDssVest(DSS_VEST).vest(vestId);
    // removes previous balance from scope
    daiAmount = IERC20(DAI).balanceOf(address(this)) - daiAmount;

    if (daiAmount < minBuffer) revert MinBuffer();

    // returns any DAI above maxBuffer
    uint256 daiToReturn;
    if (daiAmount > maxBuffer) {
      daiToReturn = daiAmount - maxBuffer;
      daiAmount = maxBuffer;
    }

    // checks for DAI debt and reduces debt if applies
    uint256 claimableDai;
    if (daiToClaim > minBuffer) {
      claimableDai = Math.min(daiToClaim, daiAmount);

      // reduces debt accountance
      daiToClaim -= claimableDai;
      daiAmount -= claimableDai;
    }

    // checks for credits on Keep3rJob and refills up to maxBuffer if possible
    uint256 daiCredits = credits();
    uint256 creditsToRefill;
    if (daiCredits < minBuffer && daiAmount > 0) {
      // refill credits up to maxBuffer or available DAI
      creditsToRefill = Math.min(maxBuffer - daiCredits, daiAmount);

      // refill DAI credits on Keep3rJob
      IERC20(DAI).approve(keep3r, uint256(creditsToRefill));
      IKeep3rV2(keep3r).addTokenCreditsToJob(job, DAI, uint256(creditsToRefill));

      daiAmount -= creditsToRefill;
    }

    // returns any excess of DAI
    daiToReturn += daiAmount;
    if (daiToReturn > 0) {
      IDaiJoin(DAI_JOIN).join(VOW, daiToReturn);
    }

    // emits event to be tracked in DuneAnalytics dashboard & tracks DAI flow
    emit ClaimedDai(claimableDai, creditsToRefill, daiToReturn);
  }

  // Parameters

  
  function setKeep3rJob(address _keep3r, address _job) external override onlyGovernor {
    keep3r = _keep3r;
    job = _job;

    emit Keep3rJobSet(_keep3r, _job);
  }

  
  function setKeeper(address _keeper) external override onlyGovernor {
    keeper = _keeper;

    emit KeeperSet(_keeper);
  }

  // Modifiers

  modifier onlyKeeper() {
    if (msg.sender != keeper) revert OnlyKeeper();
    _;
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;

interface IKeep3rV2 {
  
  struct TickCache {
    int56 current; // Tracks the current tick
    int56 difference; // Stores the difference between the current tick and the last tick
    uint256 period; // Stores the period at which the last observation was made
  }

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

  
  
  event SlasherAdded(address _slasher);

  
  
  event SlasherRemoved(address _slasher);

  
  
  event DisputerAdded(address _disputer);

  
  
  event DisputerRemoved(address _disputer);

  
  
  
  
  event Bonding(address indexed _keeper, address indexed _bonding, uint256 _amount);

  
  
  
  
  event Unbonding(address indexed _keeperOrJob, address indexed _unbonding, uint256 _amount);

  
  
  
  
  event Activation(address indexed _keeper, address indexed _bond, uint256 _amount);

  
  
  
  
  event Withdrawal(address indexed _keeper, address indexed _bond, uint256 _amount);

  
  
  
  
  event KeeperSlash(address indexed _keeper, address indexed _slasher, uint256 _amount);

  
  
  
  event KeeperRevoke(address indexed _keeper, address indexed _slasher);

  
  
  
  
  
  event TokenCreditAddition(address indexed _job, address indexed _token, address indexed _provider, uint256 _amount);

  
  
  
  
  
  event TokenCreditWithdrawal(address indexed _job, address indexed _token, address indexed _receiver, uint256 _amount);

  
  
  event LiquidityApproval(address _liquidity);

  
  
  event LiquidityRevocation(address _liquidity);

  
  
  
  
  
  event LiquidityAddition(address indexed _job, address indexed _liquidity, address indexed _provider, uint256 _amount);

  
  
  
  
  
  event LiquidityWithdrawal(address indexed _job, address indexed _liquidity, address indexed _receiver, uint256 _amount);

  
  
  
  
  
  event LiquidityCreditsReward(address indexed _job, uint256 _rewardedAt, uint256 _currentCredits, uint256 _periodCredits);

  
  
  
  
  event LiquidityCreditsForced(address indexed _job, uint256 _rewardedAt, uint256 _currentCredits);

  
  
  
  event JobAddition(address indexed _job, address indexed _jobOwner);

  
  
  event KeeperValidation(uint256 _gasLeft);

  
  
  
  
  
  
  event KeeperWork(address indexed _credit, address indexed _job, address indexed _keeper, uint256 _amount, uint256 _gasLeft);

  
  
  
  
  event JobOwnershipChange(address indexed _job, address indexed _owner, address indexed _pendingOwner);

  
  
  
  
  event JobOwnershipAssent(address indexed _job, address indexed _previousOwner, address indexed _newOwner);

  
  
  
  event JobMigrationRequested(address indexed _fromJob, address _toJob);

  
  
  
  event JobMigrationSuccessful(address _fromJob, address indexed _toJob);

  
  
  
  
  
  event JobSlashToken(address indexed _job, address _token, address indexed _slasher, uint256 _amount);

  
  
  
  
  
  event JobSlashLiquidity(address indexed _job, address _liquidity, address indexed _slasher, uint256 _amount);

  
  
  
  event Dispute(address indexed _jobOrKeeper, address indexed _disputer);

  
  
  
  event Resolve(address indexed _jobOrKeeper, address indexed _resolver);

  // Errors

  
  error MinRewardPeriod();

  
  error Disputed();

  
  error BondsUnexistent();

  
  error BondsLocked();

  
  error UnbondsUnexistent();

  
  error UnbondsLocked();

  
  error SlasherExistent();

  
  error SlasherUnexistent();

  
  error DisputerExistent();

  
  error DisputerUnexistent();

  
  error OnlySlasher();

  
  error OnlyDisputer();

  
  error JobUnavailable();

  
  error JobDisputed();

  
  error AlreadyAJob();

  
  error TokenUnallowed();

  
  error JobTokenCreditsLocked();

  
  error InsufficientJobTokenCredits();

  
  error JobAlreadyAdded();

  
  error AlreadyAKeeper();

  
  error LiquidityPairApproved();

  
  error LiquidityPairUnexistent();

  
  error LiquidityPairUnapproved();

  
  error JobLiquidityUnexistent();

  
  error JobLiquidityInsufficient();

  
  error JobLiquidityLessThanMin();

  
  error ZeroAddress();

  
  error JobUnapproved();

  
  error InsufficientFunds();

  
  error OnlyJobOwner();

  
  error OnlyPendingJobOwner();

  
  error JobMigrationImpossible();

  
  error JobMigrationUnavailable();

  
  error JobMigrationLocked();

  
  error JobTokenUnexistent();

  
  error JobTokenInsufficient();

  
  error AlreadyDisputed();

  
  error NotDisputed();

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

  // solhint-disable func-name-mixedcase
  
  
  function BASE() external view returns (uint256 _base);

  
  
  function MIN_REWARD_PERIOD_TIME() external view returns (uint256 _minPeriod);

  
  
  function slashers(address _slasher) external view returns (bool _isSlasher);

  
  
  function disputers(address _disputer) external view returns (bool _isDisputer);

  
  
  function workCompleted(address _keeper) external view returns (uint256 _workCompleted);

  
  
  function firstSeen(address _keeper) external view returns (uint256 timestamp);

  
  
  function disputes(address _keeperOrJob) external view returns (bool _disputed);

  
  
  function dispute(address _jobOrKeeper) external;

  
  
  function resolve(address _jobOrKeeper) external;

  
  
  function bonds(address _keeper, address _bond) external view returns (uint256 _bonds);

  
  
  function jobTokenCredits(address _job, address _token) external view returns (uint256 _amount);

  
  
  function pendingBonds(address _keeper, address _bonding) external view returns (uint256 _pendingBonds);

  
  
  function canActivateAfter(address _keeper, address _bonding) external view returns (uint256 _timestamp);

  
  
  function canWithdrawAfter(address _keeper, address _bonding) external view returns (uint256 _timestamp);

  
  
  function pendingUnbonds(address _keeper, address _bonding) external view returns (uint256 _pendingUnbonds);

  
  
  function hasBonded(address _keeper) external view returns (bool _hasBonded);

  
  
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

  
  
  function approvedLiquidities() external view returns (address[] memory _list);

  
  
  
  
  function liquidityAmount(address _job, address _liquidity) external view returns (uint256 _amount);

  
  
  
  function rewardedAt(address _job) external view returns (uint256 _timestamp);

  
  
  
  function workedAt(address _job) external view returns (uint256 _timestamp);

  
  
  function jobOwner(address _job) external view returns (address _owner);

  
  
  function jobPendingOwner(address _job) external view returns (address _pendingOwner);

  
  
  function pendingJobMigrations(address _fromJob) external view returns (address _toJob);

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

  
  function addSlasher(address _slasher) external;

  
  function removeSlasher(address _slasher) external;

  
  function addDisputer(address _disputer) external;

  
  function removeDisputer(address _disputer) external;

  
  
  function jobs() external view returns (address[] memory _jobList);

  
  
  function keepers() external view returns (address[] memory _keeperList);

  
  
  
  function bond(address _bonding, uint256 _amount) external;

  
  
  
  function unbond(address _bonding, uint256 _amount) external;

  
  
  function activate(address _bonding) external;

  
  
  function withdraw(address _bonding) external;

  
  
  
  
  function slash(
    address _keeper,
    address _bonded,
    uint256 _amount
  ) external;

  
  
  function revoke(address _keeper) external;

  
  
  function addJob(address _job) external;

  
  
  
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

  
  function changeJobOwnership(address _job, address _newOwner) external;

  
  function acceptJobOwnership(address _job) external;

  
  
  
  function migrateJob(address _fromJob, address _toJob) external;

  
  
  
  
  function acceptJobMigration(address _fromJob, address _toJob) external;

  
  
  
  
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

interface IDaiJoin {
  function join(address usr, uint256 wad) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;

interface IDssVest {
  function vest(uint256 _id) external;

  function vest(uint256 _id, uint256 _maxAmt) external;

  struct Award {
    address usr; // Vesting recipient
    uint48 bgn; // Start of vesting period  [timestamp]
    uint48 clf; // The cliff date           [timestamp]
    uint48 fin; // End of vesting period    [timestamp]
    address mgr; // A manager address that can yank
    uint8 res; // Restricted
    uint128 tot; // Total reward amount
    uint128 rxd; // Amount of vest claimed
  }

  function awards(uint256 _id)
    external
    view
    returns (
      address usr, // Vesting recipient
      uint48 bgn, // Start of vesting period  [timestamp]
      uint48 clf, // The cliff date           [timestamp]
      uint48 fin, // End of vesting period    [timestamp]
      address mgr, // A manager address that can yank
      uint8 res, // Restricted
      uint128 tot, // Total reward amount
      uint128 rxd // Amount of vest claimed
    );
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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