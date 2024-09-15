// SPDX-License-Identifier: BUSL-1.1

/**
 *Submitted for verification at Etherscan.io on 2021-08-22
*/

// 

pragma solidity 0.8.6;



// Part: IBetaOracle

interface IBetaOracle {
  
  
  function getAssetETHPrice(address token) external returns (uint);

  
  
  
  function getAssetETHValue(address token, uint amount) external returns (uint);

  
  
  
  
  function convert(
    address from,
    address to,
    uint amount
  ) external returns (uint);
}

// Part: IExternalOracle

interface IExternalOracle {
  
  function getETHPx(address token) external view returns (uint);
}

// Part: IUniswapV2Factory

interface IUniswapV2Factory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function createPair(address tokenA, address tokenB) external returns (address pair);
}

// Part: IUniswapV2Pair

interface IUniswapV2Pair {
  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function price0CumulativeLast() external view returns (uint);

  function price1CumulativeLast() external view returns (uint);

  function swap(
    uint amount0Out,
    uint amount1Out,
    address to,
    bytes calldata data
  ) external;
}

// File: BetaOracleUniswapV2.sol

contract BetaOracleUniswapV2 is IBetaOracle {
  event SetGovernor(address governor);
  event SetPendingGovernor(address pendingGovernor);
  event Initialize(address token);
  event Observe(address indexed token, uint224 price);
  event SetExternal(address indexed token, address ext);

  struct Observation {
    uint lastCumu;
    uint224 lastPrice;
    uint32 timestamp;
  }

  address public immutable weth;
  address public immutable factory;
  uint32 public immutable minTwapTime;

  address public governor;
  address public pendingGovernor;
  mapping(address => Observation) public observations;
  mapping(address => address) public exts;

  
  
  
  
  constructor(
    address _weth,
    address _factory,
    uint32 _minTwapTime
  ) {
    require(_weth != address(0), 'constructor/weth-zero-address');
    require(_factory != address(0), 'constructor/factory-zero-address');
    require(_minTwapTime != 0, 'constructor/min-twap-time-zero-value');
    weth = _weth;
    factory = _factory;
    minTwapTime = _minTwapTime;
    governor = msg.sender;
    emit SetGovernor(msg.sender);
  }

  
  
  function setPendingGovernor(address _pendingGovernor) external {
    require(msg.sender == governor, 'setPendingGovernor/not-governor');
    pendingGovernor = _pendingGovernor;
    emit SetPendingGovernor(_pendingGovernor);
  }

  
  function acceptGovernor() external {
    require(msg.sender == pendingGovernor, 'acceptGovernor/not-pending-governor');
    pendingGovernor = address(0);
    governor = msg.sender;
    emit SetGovernor(msg.sender);
  }

  
  
  
  function setExternalOracle(address[] calldata _tokens, address _ext) external {
    require(msg.sender == governor, 'setExternalOracle/not-governor');
    for (uint idx = 0; idx < _tokens.length; idx++) {
      exts[_tokens[idx]] = _ext;
      emit SetExternal(_tokens[idx], _ext);
    }
  }

  
  
  function initPriceFromPair(address token) public {
    Observation storage obs = observations[token];
    require(obs.timestamp == 0, 'initPriceFromPair/already-initialized');
    address pair = IUniswapV2Factory(factory).getPair(token, weth);
    obs.lastCumu = token < weth ? currentPrice0Cumu(pair) : currentPrice1Cumu(pair);
    obs.lastPrice = 0;
    obs.timestamp = uint32(block.timestamp);
    emit Initialize(token);
  }

  
  
  function massInitPriceFromPair(address[] calldata tokens) external {
    for (uint idx = 0; idx < tokens.length; idx++) {
      initPriceFromPair(tokens[idx]);
    }
  }

  
  
  function updatePriceFromPair(address token) public returns (uint) {
    Observation storage obs = observations[token];
    uint32 lastObserved = obs.timestamp;
    require(lastObserved > 0, 'updatePriceFromPair/uninitialized');
    unchecked {
      uint32 timeElapsed = uint32(block.timestamp) - lastObserved; // overflow is desired
      if (timeElapsed < minTwapTime) {
        uint lastPrice = obs.lastPrice;
        require(lastPrice > 0, 'updatePriceFromPair/no-price');
        return lastPrice;
      }
      address pair = IUniswapV2Factory(factory).getPair(token, weth);
      uint currCumu = token < weth ? currentPrice0Cumu(pair) : currentPrice1Cumu(pair);
      uint224 price = uint224((currCumu - obs.lastCumu) / timeElapsed); // overflow is desired
      obs.lastPrice = price;
      obs.lastCumu = currCumu;
      obs.timestamp = uint32(block.timestamp);
      emit Observe(token, price);
      return price;
    }
  }

  
  
  function massUpdatePriceFromPair(address[] calldata tokens)
    external
    returns (uint[] memory prices)
  {
    prices = new uint[](tokens.length);
    for (uint idx = 0; idx < tokens.length; idx++) {
      prices[idx] = updatePriceFromPair(tokens[idx]);
    }
  }

  
  
  function getAssetETHPrice(address token) public override returns (uint) {
    if (token == weth) {
      return (1 << 112);
    }
    address ext = exts[token];
    if (ext != address(0)) {
      return IExternalOracle(ext).getETHPx(token);
    }
    return updatePriceFromPair(token);
  }

  
  
  
  function getAssetETHValue(address token, uint amount) external override returns (uint) {
    uint price = getAssetETHPrice(token);
    return (price * amount) >> 112;
  }

  
  
  
  
  function convert(
    address from,
    address to,
    uint amount
  ) external override returns (uint) {
    uint fromPrice = getAssetETHPrice(from);
    uint toPrice = getAssetETHPrice(to);
    return (amount * fromPrice) / toPrice;
  }

  
  
  function currentPrice0Cumu(address pair) public view returns (uint price0Cumu) {
    uint32 currTime = uint32(block.timestamp);
    price0Cumu = IUniswapV2Pair(pair).price0CumulativeLast();
    // can use reserves without flash-manipulated risks because cumu changes if reserves change
    (uint reserve0, uint reserve1, uint32 lastTime) = IUniswapV2Pair(pair).getReserves();
    if (lastTime != currTime) {
      unchecked {
        uint32 timeElapsed = currTime - lastTime; // overflow is desired
        price0Cumu += uint((reserve1 << 112) / reserve0) * timeElapsed; // overflow is desired
      }
    }
  }

  
  
  function currentPrice1Cumu(address pair) public view returns (uint price1Cumu) {
    uint32 currTime = uint32(block.timestamp);
    price1Cumu = IUniswapV2Pair(pair).price1CumulativeLast();
    // can use reserves without flash-manipulated risks because cumu changes if reserves change
    (uint reserve0, uint reserve1, uint32 lastTime) = IUniswapV2Pair(pair).getReserves();
    if (lastTime != currTime) {
      unchecked {
        uint32 timeElapsed = currTime - lastTime; // overflow is desired
        price1Cumu += uint((reserve0 << 112) / reserve1) * timeElapsed; // overflow is desired
      }
    }
  }
}