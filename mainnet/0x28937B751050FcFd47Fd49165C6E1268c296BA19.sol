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



interface IKeep3rJob is IGovernable {
  // events
  event Keep3rSet(address _keep3r);

  // errors
  error KeeperNotValid();

  // variables
  function keep3r() external view returns (address _keep3r);

  // methods
  function setKeep3r(address _keep3r) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;





abstract contract Keep3rJob is IKeep3rJob, Governable {
  address public override keep3r = 0x4A6cFf9E1456eAa3b6f37572395C6fa0c959edAB;

  function setKeep3r(address _keep3r) public override onlyGovernor {
    keep3r = _keep3r;
    emit Keep3rSet(_keep3r);
  }

  function _isValidKeeper(address _keeper) internal virtual {
    if (!IKeep3rV2(keep3r).isKeeper(_keeper)) revert KeeperNotValid();
  }

  modifier upkeep() {
    _isValidKeeper(msg.sender);
    _;
    IKeep3rV2(keep3r).worked(msg.sender);
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;



interface IKeep3rMeteredJob is IKeep3rJob {
  // Events

  event Keep3rHelperSet(address keep3rHelper);
  event GasBonusSet(uint256 gasBonus);
  event GasMaximumSet(uint256 gasMaximum);
  event GasMultiplierSet(uint256 gasMultiplier);
  event GasMetered(uint256 initialGas, uint256 gasAfterWork, uint256 bonus);

  // Variables

  // solhint-disable-next-line func-name-mixedcase, var-name-mixedcase
  function BASE() external view returns (uint32 _BASE);

  function keep3rHelper() external view returns (address _keep3rHelper);

  function gasBonus() external view returns (uint256 _gasBonus);

  function gasMaximum() external view returns (uint256 _gasMultiplier);

  function gasMultiplier() external view returns (uint256 _gasMultiplier);

  // Methods

  function setKeep3rHelper(address _keep3rHelper) external;

  function setGasBonus(uint256 _gasBonus) external;

  function setGasMaximum(uint256 _gasMaximum) external;

  function setGasMultiplier(uint256 _gasMultiplier) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;



interface IPausable is IGovernable {
  // events
  event PauseSet(bool _paused);

  // errors
  error NoChangeInPause();

  // variables
  function paused() external view returns (bool _paused);

  // methods
  function setPause(bool _paused) external;
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





abstract contract Keep3rMeteredJob is Keep3rJob, IKeep3rMeteredJob {
  address public override keep3rHelper = 0x12038d459166Ab8E68768bb35EC0AF765A36038D;
  
  uint256 public override gasBonus = 86_000;
  uint256 public override gasMaximum = 1_000_000;
  uint256 public override gasMultiplier = 12_000;
  uint32 public constant override BASE = 10_000;

  function setKeep3rHelper(address _keep3rHelper) public override onlyGovernor {
    keep3rHelper = _keep3rHelper;
    emit Keep3rHelperSet(_keep3rHelper);
  }

  function setGasBonus(uint256 _gasBonus) external override onlyGovernor {
    gasBonus = _gasBonus;
    emit GasBonusSet(gasBonus);
  }

  function setGasMaximum(uint256 _gasMaximum) external override onlyGovernor {
    gasMaximum = _gasMaximum;
    emit GasMaximumSet(gasMaximum);
  }

  function setGasMultiplier(uint256 _gasMultiplier) external override onlyGovernor {
    gasMultiplier = _gasMultiplier;
    emit GasMultiplierSet(gasMultiplier);
  }

  modifier upkeepMetered() {
    uint256 _initialGas = gasleft();
    _isValidKeeper(msg.sender);
    _;
    uint256 _gasAfterWork = gasleft();
    
    require(_initialGas - _gasAfterWork <= gasMaximum, 'GasMeteredMaximum');
    uint256 _reward = (_calculateGas(_initialGas - _gasAfterWork + gasBonus) * gasMultiplier) / BASE;
    uint256 _payment = IKeep3rHelper(keep3rHelper).quote(_reward);
    IKeep3rV2(keep3r).bondedPayment(msg.sender, _payment);
    emit GasMetered(_initialGas, _gasAfterWork, gasBonus);
  }

  function _calculateGas(uint256 _gasUsed) internal view returns (uint256 _resultingGas) {
    _resultingGas = block.basefee * _gasUsed;
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;



interface IKeep3rMeteredFallbackJob is IKeep3rMeteredJob {
  // Events

  event FallbackGasBonusSet(uint256 gasBonus);
  event FallbackTokenAddressSet(address fallbackToken);
  event FallbackTokenWETHPoolSet(address fallbackTokenWETHPool);
  event TwapTimeSet(uint256 twapTime);

  // Variables

  function fallbackToken() external view returns (address _fallbackToken);

  function fallbackTokenWETHPool() external view returns (address _fallbackTokenWETHPool);

  function twapTime() external view returns (uint32 _twapTime);

  function fallbackGasBonus() external view returns (uint256 _fallBackGasBonus);

  // solhint-disable-next-line func-name-mixedcase, var-name-mixedcase
  function WETH() external view returns (address _WETH);

  // Methods

  function setFallbackGasBonus(uint256 _fallbackGasBonus) external;

  function setFallbackTokenWETHPool(address _fallbackTokenWETHPool) external;

  function setFallbackToken(address _fallbackToken) external;

  function setTwapTime(uint32 _twapTime) external;
}

// 
pragma solidity >=0.8.4 <0.9.0;



interface IKeep3rBondedJob is IKeep3rJob {
  // Events

  event Keep3rRequirementsSet(address _bond, uint256 _minBond, uint256 _earned, uint256 _age);

  // Variables

  function requiredBond() external view returns (address _requiredBond);

  function requiredMinBond() external view returns (uint256 _requiredMinBond);

  function requiredEarnings() external view returns (uint256 _requiredEarnings);

  function requiredAge() external view returns (uint256 _requiredAge);

  // Methods

  function setKeep3rRequirements(
    address _bond,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age
  ) external;
}
// 
pragma solidity >=0.8.4 <0.9.0;




abstract contract Pausable is IPausable, Governable {
  bool public override paused;

  function setPause(bool _paused) external override onlyGovernor {
    if (paused == _paused) revert NoChangeInPause();
    paused = _paused;
    emit PauseSet(_paused);
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





abstract contract Keep3rMeteredFallbackJob is Keep3rMeteredJob, IKeep3rMeteredFallbackJob {
  address public override fallbackToken;
  address public override fallbackTokenWETHPool;
  
  uint256 public override fallbackGasBonus = 77_000;
  uint32 public override twapTime = 300;

  // solhint-disable-next-line var-name-mixedcase
  address public override WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  constructor(address _fallbackToken, address _fallbackTokenWETHPool) {
    fallbackToken = _fallbackToken;
    fallbackTokenWETHPool = _fallbackTokenWETHPool;
  }

  function setFallbackGasBonus(uint256 _fallbackGasBonus) external override onlyGovernor {
    fallbackGasBonus = _fallbackGasBonus;
    emit FallbackGasBonusSet(fallbackGasBonus);
  }

  function setFallbackTokenWETHPool(address _fallbackTokenWETHPool) external override onlyGovernor {
    fallbackTokenWETHPool = _fallbackTokenWETHPool;
    emit FallbackTokenWETHPoolSet(fallbackTokenWETHPool);
  }

  function setFallbackToken(address _fallbackToken) external override onlyGovernor {
    fallbackToken = _fallbackToken;
    emit FallbackTokenAddressSet(fallbackToken);
  }

  function setTwapTime(uint32 _twapTime) external override onlyGovernor {
    twapTime = _twapTime;
    emit TwapTimeSet(twapTime);
  }

  modifier upkeepFallbackMetered() {
    uint256 _initialGas = gasleft();
    _isValidKeeper(msg.sender);
    _;
    uint256 _bonus = gasBonus;
    uint256 _gasAfterWork = gasleft();
    uint256 _reward = (_calculateGas(_initialGas - _gasAfterWork + _bonus) * gasMultiplier) / BASE;
    uint256 _payment = IKeep3rHelper(keep3rHelper).quote(_reward);
    bool _fallback;
    try IKeep3rV2(keep3r).bondedPayment(msg.sender, _payment) {} catch {
      _fallback = true;
      int24 _twapTick = OracleLibrary.consult(fallbackTokenWETHPool, twapTime);
      _bonus = fallbackGasBonus;
      _gasAfterWork = gasleft();
      _reward = (_calculateGas(_initialGas - _gasAfterWork + _bonus) * gasMultiplier) / BASE;
      uint256 _amount = OracleLibrary.getQuoteAtTick(_twapTick, uint128(_reward), WETH, fallbackToken);
      IKeep3rV2(keep3r).directTokenPayment(fallbackToken, msg.sender, _amount);
    }
    
    require(_fallback || _initialGas - _gasAfterWork <= gasMaximum, 'GasMeteredMaximum');
    emit GasMetered(_initialGas, _gasAfterWork, _bonus);
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;




abstract contract Keep3rBondedJob is Keep3rJob, IKeep3rBondedJob {
  address public override requiredBond = 0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44;
  uint256 public override requiredMinBond = 50 ether;
  uint256 public override requiredEarnings;
  uint256 public override requiredAge;

  function setKeep3rRequirements(
    address _bond,
    uint256 _minBond,
    uint256 _earned,
    uint256 _age
  ) public override onlyGovernor {
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
pragma solidity >=0.8.4 <0.9.0;






interface IMakerDAOUpkeep is IGovernable, IPausable, IKeep3rJob, IDustCollector {
  // event
  event NetworkSet(bytes32 _newNetwork);
  event SequencerAddressSet(address _newSequencerAddress);
  event JobWorked(address _job);

  // errors
  error AvailableCredits();
  error Paused();
  error CallFailed();
  error NotValidJob();

  // variables

  function network() external view returns (bytes32 _network);

  function sequencer() external view returns (address _sequencer);

  // methods

  function work(address _job, bytes calldata _data) external;

  function workMetered(address _job, bytes calldata _data) external;

  function setNetwork(bytes32 _network) external;

  function setSequencerAddress(address _sequencer) external;
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolImmutables {
    
    
    function factory() external view returns (address);

    
    
    function token0() external view returns (address);

    
    
    function token1() external view returns (address);

    
    
    function fee() external view returns (uint24);

    
    
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    
    function tickSpacing() external view returns (int24);

    
    
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    
    function maxLiquidityPerTick() external view returns (uint128);
}

// 
pragma solidity >=0.5.0;



/// per transaction
interface IUniswapV3PoolState {
    
    /// when accessed externally.
    
    /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// observationIndex The index of the last oracle observation that was written,
    /// observationCardinality The current maximum number of observations stored in the pool,
    /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    
    
    function feeGrowthGlobal0X128() external view returns (uint256);

    
    
    function feeGrowthGlobal1X128() external view returns (uint256);

    
    
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    
    
    function liquidity() external view returns (uint128);

    
    
    
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    
    
    
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    
    
    
    /// ago, rather than at a specific index in the array.
    
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}

// 
pragma solidity >=0.5.0;



/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    
    
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    
    
    
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    
    
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    
    
    
    
    
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolActions {
    
    
    
    function initialize(uint160 sqrtPriceX96) external;

    
    
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    
    
    
    
    
    
    
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    
    
    
    
    
    
    
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    
    
    
    
    
    
    
    
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    
    
    
    
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    
    
    
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    
    
    
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    
    
    
    
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    
    
    /// the input observationCardinalityNext.
    
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolOwnerActions {
    
    
    
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    
    
    
    
    
    
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolEvents {
    
    
    
    
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    
    
    
    
    
    
    
    
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    
    
    
    
    
    
    
    
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    
    
    
    
    
    
    
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    
    
    /// just before a mint/swap/burn.
    
    
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    
    
    
    
    
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    
    
    
    
    
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
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











contract MakerDAOUpkeep is IMakerDAOUpkeep, Governable, Keep3rBondedJob, Keep3rMeteredFallbackJob, Pausable, DustCollector {
  address public override sequencer = 0x9566eB72e47E3E20643C0b1dfbEe04Da5c7E4732;
  bytes32 public override network;

  address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address internal constant DAI_WETH_POOL = 0xC2e9F25Be6257c210d7Adf0D4Cd6E3E881ba25f8;

  constructor(address _governor, bytes32 _network) Governable(_governor) Keep3rMeteredFallbackJob(DAI, DAI_WETH_POOL) {
    network = _network;
  }

  function work(address _job, bytes calldata _data) external override upkeep {
    _work(_job, _data);
  }

  function workMetered(address _job, bytes calldata _data) external override upkeepFallbackMetered {
    _work(_job, _data);
  }

  function setNetwork(bytes32 _network) external override onlyGovernor {
    network = _network;
    emit NetworkSet(network);
  }

  function setSequencerAddress(address _sequencer) external override onlyGovernor {
    sequencer = _sequencer;
    emit SequencerAddressSet(sequencer);
  }

  // Internals

  function _work(address _job, bytes calldata _data) internal {
    if (paused) revert Paused();
    if (!ISequencer(sequencer).hasJob(_job)) revert NotValidJob();
    IJob(_job).work(network, _data);
    emit JobWorked(_job);
  }

  function _isValidKeeper(address _keeper) internal override(Keep3rBondedJob, Keep3rJob) {
    super._isValidKeeper(_keeper);
  }
}

// 
pragma solidity >=0.8.4 <0.9.0;

interface ISequencer {
  struct WorkableJob {
    address job;
    bool canWork;
    bytes args;
  }

  event Rely(address indexed usr);
  event Deny(address indexed usr);
  event File(bytes32 indexed what, uint256 data);
  event AddNetwork(bytes32 indexed network);
  event RemoveNetwork(bytes32 indexed network);
  event AddJob(address indexed job);
  event RemoveJob(address indexed job);

  error InvalidFileParam(bytes32 what);
  error NetworkExists(bytes32 network);
  error NetworkDoesNotExist(bytes32 network);
  error JobExists(address job);
  error JobDoesNotExist(address network);
  error IndexTooHigh(uint256 index, uint256 length);
  error BadIndicies(uint256 startIndex, uint256 exclEndIndex);

  function wards(address) external returns (uint256);

  function rely(address usr) external;

  function deny(address usr) external;

  function window() external returns (uint256);

  function file(bytes32 what, uint256 data) external;

  function addNetwork(bytes32 network) external;

  function removeNetwork(uint256 index) external;

  function addJob(address job) external;

  function removeJob(uint256 index) external;

  function isMaster(bytes32 _network) external view returns (bool _isMaster);

  function numNetworks() external view returns (uint256);

  function hasNetwork() external view returns (bool);

  function networkAt(uint256 index) external view returns (bytes32);

  function numJobs() external view returns (uint256);

  function hasJob(address job) external returns (bool);

  function jobAt(uint256 index) external view returns (address);

  function getNextJobs(
    bytes32 network,
    uint256 startIndex,
    uint256 endIndexExcl
  ) external returns (WorkableJob[] memory);

  function getNextJobs(bytes32 network) external returns (WorkableJob[] memory);
}

// 
pragma solidity >=0.8.4 <0.9.0;

interface IJob {
  function work(bytes32 network, bytes calldata args) external;

  function workable(bytes32 network) external returns (bool canWork, bytes memory args);
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
pragma solidity >=0.5.0;







library OracleLibrary {
  
  
  
  
  function consult(address pool, uint32 period) internal view returns (int24 timeWeightedAverageTick) {
    require(period != 0, 'BP');

    uint32[] memory secondAgos = new uint32[](2);
    secondAgos[0] = period;
    secondAgos[1] = 0;

    (int56[] memory tickCumulatives, ) = IUniswapV3Pool(pool).observe(secondAgos);
    int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

    timeWeightedAverageTick = int24(tickCumulativesDelta / int256(uint256(period)));

    // Always round to negative infinity
    if (tickCumulativesDelta < 0 && (tickCumulativesDelta % int256(uint256(period)) != 0)) timeWeightedAverageTick--;
  }

  
  
  
  
  
  
  function getQuoteAtTick(
    int24 tick,
    uint128 baseAmount,
    address baseToken,
    address quoteToken
  ) internal pure returns (uint256 quoteAmount) {
    uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);

    // Calculate quoteAmount with better precision if it doesn't overflow when multiplied by itself
    if (sqrtRatioX96 <= type(uint128).max) {
      uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
      quoteAmount = baseToken < quoteToken ? FullMath.mulDiv(ratioX192, baseAmount, 1 << 192) : FullMath.mulDiv(1 << 192, baseAmount, ratioX192);
    } else {
      uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
      quoteAmount = baseToken < quoteToken ? FullMath.mulDiv(ratioX128, baseAmount, 1 << 128) : FullMath.mulDiv(1 << 128, baseAmount, ratioX128);
    }
  }
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
pragma solidity >=0.5.0;










/// to the ERC20 specification

interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

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
pragma solidity >=0.5.0;

// solhint-disable



///         prices between 2**-128 and 2**128
library TickMath {
  
  int24 internal constant MIN_TICK = -887272;
  
  int24 internal constant MAX_TICK = -MIN_TICK;

  
  uint160 internal constant MIN_SQRT_RATIO = 4295128739;
  
  uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

  
  
  
  
  ///         at the given tick
  function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
    uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
    require(absTick <= uint256(int256(MAX_TICK)), 'T');

    uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
    if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
    if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
    if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
    if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
    if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
    if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
    if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
    if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
    if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
    if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
    if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
    if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
    if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
    if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
    if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
    if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
    if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
    if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
    if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

    if (tick > 0) ratio = type(uint256).max / ratio;

    // Divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
    // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
    // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
    sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
  }

  
  
  
  
  function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
    // Second inequality must be < because the price can never reach the price at the max tick
    require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, 'R');
    uint256 ratio = uint256(sqrtPriceX96) << 32;

    uint256 r = ratio;
    uint256 msb = 0;

    assembly {
      let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(5, gt(r, 0xFFFFFFFF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(4, gt(r, 0xFFFF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(3, gt(r, 0xFF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(2, gt(r, 0xF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(1, gt(r, 0x3))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := gt(r, 0x1)
      msb := or(msb, f)
    }

    if (msb >= 128) r = ratio >> (msb - 127);
    else r = ratio << (127 - msb);

    int256 log_2 = (int256(msb) - 128) << 64;

    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(63, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(62, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(61, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(60, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(59, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(58, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(57, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(56, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(55, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(54, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(53, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(52, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(51, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(50, f))
    }

    int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

    int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
    int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

    tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
  }
}
