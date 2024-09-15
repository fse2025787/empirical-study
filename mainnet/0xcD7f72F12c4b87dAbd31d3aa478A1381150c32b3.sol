// SPDX-License-Identifier: MIT


// 

pragma solidity >=0.8.4 <0.9.0;

interface IBaseErrors {
  
  error ZeroAddress();

  
  error WrongLengths();
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

  // views

  
  function governor() external view returns (address _governor);

  
  function pendingGovernor() external view returns (address _pendingGovernor);

  // methods

  
  
  function setPendingGovernor(address _pendingGovernor) external;

  
  function acceptPendingGovernor() external;
}

// 
pragma solidity >=0.8.9 <0.9.0;



abstract contract Governable is IGovernable {
  
  address public governor;
  
  address public pendingGovernor;

  constructor(address _governor) {
    if (_governor == address(0)) revert ZeroAddress();
    governor = _governor;
  }

  // methods

  
  function setPendingGovernor(address _pendingGovernor) external onlyGovernor {
    _setPendingGovernor(_pendingGovernor);
  }

  
  function acceptPendingGovernor() external onlyPendingGovernor {
    _acceptPendingGovernor();
  }

  // modifiers

  modifier onlyGovernor() {
    if (msg.sender != governor) revert OnlyGovernor();
    _;
  }

  modifier onlyPendingGovernor() {
    if (msg.sender != pendingGovernor) revert OnlyPendingGovernor();
    _;
  }

  // internals

  function _setPendingGovernor(address _pendingGovernor) internal {
    if (_pendingGovernor == address(0)) revert ZeroAddress();
    pendingGovernor = _pendingGovernor;
    emit PendingGovernorSet(governor, pendingGovernor);
  }

  function _acceptPendingGovernor() internal {
    governor = pendingGovernor;
    pendingGovernor = address(0);
    emit PendingGovernorAccepted(governor);
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;



interface IKeep3rJob is IGovernable {
  // events

  
  
  event Keep3rSet(address _keep3r);

  // errors

  
  error KeeperNotValid();

  // views

  
  function keep3r() external view returns (address _keep3r);

  // methods

  
  
  function setKeep3r(address _keep3r) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;

interface IMachinery {
  // View helpers
  function mechanicsRegistry() external view returns (address _mechanicsRegistry);

  function isMechanic(address mechanic) external view returns (bool _isMechanic);

  // Setters
  function setMechanicsRegistry(address _mechanicsRegistry) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;





contract Machinery is IMachinery {
  using EnumerableSet for EnumerableSet.AddressSet;

  IMechanicsRegistry internal _mechanicsRegistry;

  constructor(address __mechanicsRegistry) {
    _setMechanicsRegistry(__mechanicsRegistry);
  }

  modifier onlyMechanic() {
    require(_mechanicsRegistry.isMechanic(msg.sender), 'Machinery: not mechanic');
    _;
  }

  function setMechanicsRegistry(address __mechanicsRegistry) external virtual override {
    _setMechanicsRegistry(__mechanicsRegistry);
  }

  function _setMechanicsRegistry(address __mechanicsRegistry) internal {
    _mechanicsRegistry = IMechanicsRegistry(__mechanicsRegistry);
  }

  // View helpers
  function mechanicsRegistry() external view override returns (address _mechanicRegistry) {
    return address(_mechanicsRegistry);
  }

  function isMechanic(address _mechanic) public view override returns (bool _isMechanic) {
    return _mechanicsRegistry.isMechanic(_mechanic);
  }
}

// 
pragma solidity >=0.8.9 <0.9.0;





abstract contract Keep3rJob is IKeep3rJob, Governable {
  
  address public keep3r = 0xeb02addCfD8B773A5FFA6B9d1FE99c566f8c44CC;

  // methods

  
  function setKeep3r(address _keep3r) public onlyGovernor {
    _setKeep3r(_keep3r);
  }

  // modifiers

  modifier upkeep() {
    _isValidKeeper(msg.sender);
    _;
    IKeep3rV2(keep3r).worked(msg.sender);
  }

  // internals

  function _setKeep3r(address _keep3r) internal {
    keep3r = _keep3r;
    emit Keep3rSet(_keep3r);
  }

  function _isValidKeeper(address _keeper) internal virtual {
    if (!IKeep3rV2(keep3r).isKeeper(_keeper)) revert KeeperNotValid();
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;



interface IKeep3rMeteredJob is IKeep3rJob {
  // events

  
  
  event Keep3rHelperSet(address _keep3rHelper);

  
  
  event GasBonusSet(uint256 _gasBonus);

  
  
  event GasMultiplierSet(uint256 _gasMultiplier);

  
  
  event MaxMultiplierSet(uint256 _maxMultiplier);

  
  
  
  
  event GasMetered(uint256 _initialGas, uint256 _gasAfterWork, uint256 _bonus);

  // errors
  error MaxMultiplier();

  // views

  
  function keep3rHelper() external view returns (address _keep3rHelper);

  
  function gasBonus() external view returns (uint256 _gasBonus);

  
  function gasMultiplier() external view returns (uint256 _gasMultiplier);

  
  function maxMultiplier() external view returns (uint256 _maxMultiplier);

  // solhint-disable-next-line func-name-mixedcase, var-name-mixedcase
  function BASE() external view returns (uint32 _BASE);

  // methods

  
  
  function setKeep3rHelper(address _keep3rHelper) external;

  
  
  function setGasBonus(uint256 _gasBonus) external;

  
  
  function setGasMultiplier(uint256 _gasMultiplier) external;

  
  
  function setMaxMultiplier(uint256 _maxMultiplier) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;



interface IKeep3rBondedJob is IKeep3rJob {
  // events

  
  
  
  
  
  event Keep3rRequirementsSet(address _bond, uint256 _minBond, uint256 _earned, uint256 _age);

  // views

  
  function requiredBond() external view returns (address _requiredBond);

  
  function requiredMinBond() external view returns (uint256 _requiredMinBond);

  
  function requiredEarnings() external view returns (uint256 _requiredEarnings);

  
  function requiredAge() external view returns (uint256 _requiredAge);

  // methods

  
  
  
  
  
  function setKeep3rRequirements(
    address _bond,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age
  ) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;

interface IOnlyEOA {
  // events

  
  event OnlyEOASet(bool _onlyEOA);

  // errors

  
  error OnlyEOA();

  // views

  
  function onlyEOA() external returns (bool _onlyEOA);

  // methods

  
  
  function setOnlyEOA(bool _onlyEOA) external;
}
// 

pragma solidity >=0.8.9 <0.9.0;

abstract contract GasBaseFee {
  // internals
  function _gasPrice() internal view virtual returns (uint256) {
    return block.basefee;
  }
}

// 
pragma solidity >=0.8.9 <0.9.0;




abstract contract MachineryReady is Machinery, Governable {
  // errors

  
  error OnlyGovernorOrMechanic();

  constructor(address _mechanicsRegistry) Machinery(_mechanicsRegistry) {}

  // methods

  
  
  function setMechanicsRegistry(address _mechanicsRegistry) external override onlyGovernor {
    _setMechanicsRegistry(_mechanicsRegistry);
  }

  // modifiers

  modifier onlyGovernorOrMechanic() {
    _validateGovernorOrMechanic(msg.sender);
    _;
  }

  // internals

  function _validateGovernorOrMechanic(address _user) internal view {
    if (_user != governor && !isMechanic(_user)) revert OnlyGovernorOrMechanic();
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;


interface IV2KeeperJob {
  // errors

  
  error StrategyAlreadyAdded();
  
  error StrategyNotAdded();
  
  error StrategyNotWorkable();
  
  error ZeroCooldown();

  // events

  
  
  
  event StrategyAdded(address _strategy, uint256 _requiredAmount);

  
  
  
  event StrategyModified(address _strategy, uint256 _requiredAmount);

  
  
  event StrategyRemoved(address _strategy);

  
  
  event KeeperWorked(address _strategy);

  
  
  event ForceWorked(address _strategy);

  // views

  
  function v2Keeper() external view returns (IV2Keeper _v2Keeper);

  
  function strategies() external view returns (address[] memory _strategies);

  
  function workCooldown() external view returns (uint256 _workCooldown);

  
  
  function workable(address _strategy) external view returns (bool _isWorkable);

  
  
  function lastWorkAt(address _strategy) external view returns (uint256 _lastWorkAt);

  
  
  function requiredAmount(address _strategy) external view returns (uint256 _requiredAmount);

  // methods

  
  function setV2Keeper(address _v2Keeper) external;

  
  function setWorkCooldown(uint256 _workCooldown) external;

  
  
  function addStrategy(address _strategy, uint256 _requiredAmount) external;

  
  
  function addStrategies(address[] calldata _strategies, uint256[] calldata _requiredAmount) external;

  
  
  function updateRequiredAmount(address _strategy, uint256 _requiredAmount) external;

  
  
  function updateRequiredAmounts(address[] calldata _strategies, uint256[] calldata _requiredAmounts) external;

  
  function removeStrategy(address _strategy) external;

  
  
  function work(address _strategy) external;

  
  
  
  function forceWork(address _strategy) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;



interface IPausable is IGovernable {
  // events

  
  
  event PauseSet(bool _paused);

  // errors

  
  error Paused();

  
  error NoChangeInPause();

  // views

  
  function paused() external view returns (bool _paused);

  // methods

  
  
  function setPause(bool _paused) external;
}

// 
pragma solidity >=0.8.9 <0.9.0;





abstract contract Keep3rMeteredJob is IKeep3rMeteredJob, Keep3rJob {
  
  address public keep3rHelper = 0xD36Ac9Ff5562abb541F51345f340FB650547a661;
  
  uint256 public gasBonus = 86_000;
  
  uint256 public gasMultiplier = 12_000;
  
  uint32 public constant BASE = 10_000;
  
  uint256 public maxMultiplier = 15_000;

  // setters

  
  function setKeep3rHelper(address _keep3rHelper) public onlyGovernor {
    _setKeep3rHelper(_keep3rHelper);
  }

  
  function setGasBonus(uint256 _gasBonus) external onlyGovernor {
    _setGasBonus(_gasBonus);
  }

  
  function setMaxMultiplier(uint256 _maxMultiplier) external onlyGovernor {
    _setMaxMultiplier(_maxMultiplier);
  }

  
  function setGasMultiplier(uint256 _gasMultiplier) external onlyGovernor {
    _setGasMultiplier(_gasMultiplier);
  }

  // modifiers

  modifier upkeepMetered() {
    uint256 _initialGas = gasleft();
    _isValidKeeper(msg.sender);
    _;
    uint256 _gasAfterWork = gasleft();
    uint256 _reward = (_calculateGas(_initialGas - _gasAfterWork + gasBonus) * gasMultiplier) / BASE;
    uint256 _payment = IKeep3rHelper(keep3rHelper).quote(_reward);
    IKeep3rV2(keep3r).bondedPayment(msg.sender, _payment);
    emit GasMetered(_initialGas, _gasAfterWork, gasBonus);
  }

  // internals

  function _setKeep3rHelper(address _keep3rHelper) internal {
    keep3rHelper = _keep3rHelper;
    emit Keep3rHelperSet(_keep3rHelper);
  }

  function _setGasBonus(uint256 _gasBonus) internal {
    gasBonus = _gasBonus;
    emit GasBonusSet(gasBonus);
  }

  function _setMaxMultiplier(uint256 _maxMultiplier) internal {
    maxMultiplier = _maxMultiplier;
    emit MaxMultiplierSet(maxMultiplier);
  }

  function _setGasMultiplier(uint256 _gasMultiplier) internal {
    if (_gasMultiplier > maxMultiplier) revert MaxMultiplier();
    gasMultiplier = _gasMultiplier;
    emit GasMultiplierSet(gasMultiplier);
  }

  function _calculateGas(uint256 _gasUsed) internal view returns (uint256 _resultingGas) {
    _resultingGas = block.basefee * _gasUsed;
  }

  function _calculateCredits(uint256 _gasUsed) internal view returns (uint256 _credits) {
    return IKeep3rHelper(keep3rHelper).getRewardAmount(_calculateGas(_gasUsed));
  }
}

// 
pragma solidity >=0.8.9 <0.9.0;




abstract contract Keep3rBondedJob is IKeep3rBondedJob, Keep3rJob {
  
  address public requiredBond = 0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44;
  
  uint256 public requiredMinBond = 50 ether;
  
  uint256 public requiredEarnings;
  
  uint256 public requiredAge;

  // methods

  
  function setKeep3rRequirements(
    address _bond,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age
  ) public onlyGovernor {
    _setKeep3rRequirements(_bond, _minBond, _earned, _age);
  }

  // internals

  function _setKeep3rRequirements(
    address _bond,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age
  ) internal {
    requiredBond = _bond;
    requiredMinBond = _minBond;
    requiredEarnings = _earned;
    requiredAge = _age;
    emit Keep3rRequirementsSet(_bond, _minBond, _earned, _age);
  }

  function _isValidKeeper(address _keeper) internal virtual override {
    if (!IKeep3rV2(keep3r).isBondedKeeper(_keeper, requiredBond, requiredMinBond, requiredEarnings, requiredAge)) revert KeeperNotValid();
  }
}

// 
pragma solidity >=0.8.9 <0.9.0;




abstract contract OnlyEOA is IOnlyEOA, Governable {
  
  bool public onlyEOA;

  // methods

  
  function setOnlyEOA(bool _onlyEOA) external onlyGovernor {
    _setOnlyEOA(_onlyEOA);
  }

  // internals

  function _setOnlyEOA(bool _onlyEOA) internal {
    onlyEOA = _onlyEOA;
    emit OnlyEOASet(_onlyEOA);
  }

  function _validateEOA(address _caller) internal view {
    // solhint-disable-next-line avoid-tx-origin
    if (_caller != tx.origin) revert OnlyEOA();
  }
}

// 

pragma solidity >=0.8.9 <0.9.0;








abstract contract V2KeeperJob is IV2KeeperJob, MachineryReady, GasBaseFee {
  using EnumerableSet for EnumerableSet.AddressSet;
  
  IV2Keeper public v2Keeper;

  EnumerableSet.AddressSet internal _availableStrategies;
  
  mapping(address => uint256) public requiredAmount;
  
  mapping(address => uint256) public lastWorkAt;
  
  uint256 public workCooldown;

  constructor(
    address _governor,
    address _v2Keeper,
    address _mechanicsRegistry,
    uint256 _workCooldown
  ) Governable(_governor) MachineryReady(_mechanicsRegistry) {
    v2Keeper = IV2Keeper(_v2Keeper);
    if (_workCooldown > 0) _setWorkCooldown(_workCooldown);
  }

  // views

  
  function strategies() public view returns (address[] memory _strategies) {
    _strategies = new address[](_availableStrategies.length());
    for (uint256 _i; _i < _availableStrategies.length(); _i++) {
      _strategies[_i] = _availableStrategies.at(_i);
    }
  }

  // setters

  
  function setV2Keeper(address _v2Keeper) external onlyGovernor {
    _setV2Keeper(_v2Keeper);
  }

  
  function setWorkCooldown(uint256 _workCooldown) external onlyGovernorOrMechanic {
    _setWorkCooldown(_workCooldown);
  }

  
  function addStrategy(address _strategy, uint256 _requiredAmount) external onlyGovernorOrMechanic {
    _addStrategy(_strategy, _requiredAmount);
  }

  
  function addStrategies(address[] calldata _strategies, uint256[] calldata _requiredAmounts) external onlyGovernorOrMechanic {
    if (_strategies.length != _requiredAmounts.length) revert WrongLengths();
    for (uint256 _i; _i < _strategies.length; _i++) {
      _addStrategy(_strategies[_i], _requiredAmounts[_i]);
    }
  }

  
  function updateRequiredAmount(address _strategy, uint256 _requiredAmount) external onlyGovernorOrMechanic {
    _updateRequiredAmount(_strategy, _requiredAmount);
  }

  
  function updateRequiredAmounts(address[] calldata _strategies, uint256[] calldata _requiredAmounts) external onlyGovernorOrMechanic {
    if (_strategies.length != _requiredAmounts.length) revert WrongLengths();
    for (uint256 _i; _i < _strategies.length; _i++) {
      _updateRequiredAmount(_strategies[_i], _requiredAmounts[_i]);
    }
  }

  
  function removeStrategy(address _strategy) external onlyGovernorOrMechanic {
    _removeStrategy(_strategy);
  }

  // internals

  function _setV2Keeper(address _v2Keeper) internal {
    v2Keeper = IV2Keeper(_v2Keeper);
  }

  function _setWorkCooldown(uint256 _workCooldown) internal {
    if (_workCooldown == 0) revert ZeroCooldown();
    workCooldown = _workCooldown;
  }

  function _addStrategy(address _strategy, uint256 _requiredAmount) internal {
    if (_availableStrategies.contains(_strategy)) revert StrategyAlreadyAdded();
    _setRequiredAmount(_strategy, _requiredAmount);
    emit StrategyAdded(_strategy, _requiredAmount);
    _availableStrategies.add(_strategy);
  }

  function _updateRequiredAmount(address _strategy, uint256 _requiredAmount) internal {
    if (!_availableStrategies.contains(_strategy)) revert StrategyNotAdded();
    _setRequiredAmount(_strategy, _requiredAmount);
    emit StrategyModified(_strategy, _requiredAmount);
  }

  function _removeStrategy(address _strategy) internal {
    if (!_availableStrategies.contains(_strategy)) revert StrategyNotAdded();
    delete requiredAmount[_strategy];
    _availableStrategies.remove(_strategy);
    emit StrategyRemoved(_strategy);
  }

  function _setRequiredAmount(address _strategy, uint256 _requiredAmount) internal {
    requiredAmount[_strategy] = _requiredAmount;
  }

  function _workable(address _strategy) internal view virtual returns (bool) {
    if (!_availableStrategies.contains(_strategy)) revert StrategyNotAdded();
    if (workCooldown == 0 || block.timestamp > lastWorkAt[_strategy] + workCooldown) return true;
    return false;
  }

  function _getCallCosts(address _strategy) internal view returns (uint256 _callCost) {
    uint256 _gasAmount = requiredAmount[_strategy];
    if (_gasAmount == 0) return 0;
    return _gasAmount * _gasPrice();
  }

  function _workInternal(address _strategy) internal {
    if (!_workable(_strategy)) revert StrategyNotWorkable();
    lastWorkAt[_strategy] = block.timestamp;
    _work(_strategy);
    emit KeeperWorked(_strategy);
  }

  function _forceWork(address _strategy) internal {
    _work(_strategy);
    emit ForceWorked(_strategy);
  }

  
  function _work(address _strategy) internal virtual {}
}

// 
pragma solidity >=0.8.9 <0.9.0;




abstract contract Pausable is IPausable, Governable {
  
  bool public paused;

  // setters

  
  function setPause(bool _paused) external onlyGovernor {
    _setPause(_paused);
  }

  // modifiers

  modifier notPaused() {
    if (paused) revert Paused();
    _;
  }

  // internals

  function _setPause(bool _paused) internal {
    if (paused == _paused) revert NoChangeInPause();
    paused = _paused;
    emit PauseSet(_paused);
  }
}

// 
pragma solidity >=0.8.9 <0.9.0;





abstract contract Keep3rMeteredPublicJob is Keep3rMeteredJob, Keep3rBondedJob, OnlyEOA {
  // internals
  function _isValidKeeper(address _keeper) internal override(Keep3rBondedJob, Keep3rJob) {
    if (onlyEOA) _validateEOA(_keeper);
    super._isValidKeeper(_keeper);
  }
}
// 

/*

Coded for Yearn Finance with ♥ by

██████╗░███████╗███████╗██╗  ░██╗░░░░░░░██╗░█████╗░███╗░░██╗██████╗░███████╗██████╗░██╗░░░░░░█████╗░███╗░░██╗██████╗░
██╔══██╗██╔════╝██╔════╝██║  ░██║░░██╗░░██║██╔══██╗████╗░██║██╔══██╗██╔════╝██╔══██╗██║░░░░░██╔══██╗████╗░██║██╔══██╗
██║░░██║█████╗░░█████╗░░██║  ░╚██╗████╗██╔╝██║░░██║██╔██╗██║██║░░██║█████╗░░██████╔╝██║░░░░░███████║██╔██╗██║██║░░██║
██║░░██║██╔══╝░░██╔══╝░░██║  ░░████╔═████║░██║░░██║██║╚████║██║░░██║██╔══╝░░██╔══██╗██║░░░░░██╔══██║██║╚████║██║░░██║
██████╔╝███████╗██║░░░░░██║  ░░╚██╔╝░╚██╔╝░╚█████╔╝██║░╚███║██████╔╝███████╗██║░░██║███████╗██║░░██║██║░╚███║██████╔╝
╚═════╝░╚══════╝╚═╝░░░░░╚═╝  ░░░╚═╝░░░╚═╝░░░╚════╝░╚═╝░░╚══╝╚═════╝░╚══════╝╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░

https://defi.sucks

*/

pragma solidity >=0.8.9 <0.9.0;





contract TendV2Keep3rJob is IKeep3rJob, V2KeeperJob, Pausable, Keep3rMeteredPublicJob {
  constructor(
    address _governor,
    address _mechanicsRegistry,
    address _v2Keeper,
    uint256 _workCooldown,
    address _keep3r,
    address _keep3rHelper,
    address _bond,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age,
    bool _onlyEOA
  ) V2KeeperJob(_governor, _v2Keeper, _mechanicsRegistry, _workCooldown) {
    _setKeep3r(_keep3r);
    _setKeep3rHelper(_keep3rHelper);
    _setKeep3rRequirements(_bond, _minBond, _earned, _age);
    _setOnlyEOA(_onlyEOA);
  }

  // views

  
  function workable(address _strategy) external view returns (bool _isWorkable) {
    return _workable(_strategy);
  }

  // methods

  
  function work(address _strategy) external upkeepMetered notPaused {
    _workInternal(_strategy);
  }

  
  function forceWork(address _strategy) external onlyGovernorOrMechanic {
    _forceWork(_strategy);
  }

  // internals

  function _workable(address _strategy) internal view override returns (bool _isWorkable) {
    if (!super._workable(_strategy)) return false;
    return IBaseStrategy(_strategy).tendTrigger(_getCallCosts(_strategy));
  }

  function _work(address _strategy) internal override {
    v2Keeper.tend(_strategy);
  }
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

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
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
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
pragma solidity >=0.6.8;

interface IV2Keeper {
  // Getters
  function jobs() external view returns (address[] memory);

  event JobAdded(address _job);
  event JobRemoved(address _job);

  // Setters
  function addJobs(address[] calldata _jobs) external;

  function addJob(address _job) external;

  function removeJob(address _job) external;

  // Jobs actions
  function tend(address _strategy) external;

  function harvest(address _strategy) external;
}

// 
pragma solidity ^0.8.4;

interface IBaseStrategy {
  // events
  event Harvested(uint256 _profit, uint256 _loss, uint256 _debtPayment, uint256 _debtOutstanding);

  // views

  function vault() external view returns (address _vault);

  function strategist() external view returns (address _strategist);

  function rewards() external view returns (address _rewards);

  function keeper() external view returns (address _keeper);

  function want() external view returns (address _want);

  function name() external view returns (string memory _name);

  function profitFactor() external view returns (uint256 _profitFactor);

  function maxReportDelay() external view returns (uint256 _maxReportDelay);

  function crv() external view returns (address _crv);

  // setters
  function setStrategist(address _strategist) external;

  function setKeeper(address _keeper) external;

  function setRewards(address _rewards) external;

  function tendTrigger(uint256 _callCost) external view returns (bool);

  function tend() external;

  function harvestTrigger(uint256 _callCost) external view returns (bool);

  function harvest() external;

  function setBorrowCollateralizationRatio(uint256 _c) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;

interface IMechanicsRegistry {
  event MechanicAdded(address _mechanic);
  event MechanicRemoved(address _mechanic);

  function addMechanic(address _mechanic) external;

  function removeMechanic(address _mechanic) external;

  function mechanics() external view returns (address[] memory _mechanicsList);

  function isMechanic(address mechanic) external view returns (bool _isMechanic);
}

// 
pragma solidity >=0.8.0 <0.9.0;



interface IKeep3rHelper {
  // Errors

  
  error LiquidityPairInvalid();

  // Variables

  
  
  // solhint-disable func-name-mixedcase
  function KP3R() external view returns (address _kp3r);

  
  
  function KP3R_WETH_POOL() external view returns (address _kp3rWeth);

  
  ///         For example: if the quoted gas used is 1000, then the minimum amount to be paid will be 1000 * MIN / BOOST_BASE
  
  function MIN() external view returns (uint256 _multiplier);

  
  ///         For example: if the quoted gas used is 1000, then the maximum amount to be paid will be 1000 * MAX / BOOST_BASE
  
  function MAX() external view returns (uint256 _multiplier);

  
  
  function BOOST_BASE() external view returns (uint256 _base);

  
  ///         For example: if the amount of KP3R the keeper has bonded is TARGETBOND or more, then the keeper will get
  ///                      the maximum boost possible in his rewards, if it's less, the reward boost will be proportional
  
  function TARGETBOND() external view returns (uint256 _target);

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

  
  
  function firstSeen(address _keeper) external view returns (uint256 _timestamp);

  
  
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
