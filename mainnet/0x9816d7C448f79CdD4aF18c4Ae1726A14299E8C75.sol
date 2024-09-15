// SPDX-License-Identifier: MIT


// 
pragma solidity 0.8.9;



interface IOracleRelay {
  // returns  price with 18 decimals
  function currentValue() external view returns (uint256);
}
// 
pragma solidity 0.8.9;








contract ChainlinkTokenOracleRelay is IOracleRelay {
  IAggregator private immutable _aggregator;

  //Previously deployed chainlink relay for ETH/USD
  IOracleRelay public constant _ethPriceFeed = IOracleRelay(0xd38D3b40F5C2a52823AE0932B8D658932FDb9ED1);

  uint256 public immutable _multiply;
  uint256 public immutable _divide;

  
  
  
  
  constructor(
    address feed_address,
    uint256 mul,
    uint256 div
  ) {
    _aggregator = IAggregator(feed_address);
    _multiply = mul;
    _divide = div;
  }

  
  
  
  function currentValue() external view override returns (uint256) {
    uint256 priceInEth = getLastSecond();

    uint256 ethPrice = _ethPriceFeed.currentValue();

    return (ethPrice * priceInEth) / 1e18;
  }

  function getLastSecond() private view returns (uint256) {
    int256 latest = _aggregator.latestAnswer();
    require(latest > 0, "chainlink: px < 0");
    uint256 scaled = (uint256(latest) * _multiply) / _divide;
    return scaled;
  }
}

// 
pragma solidity 0.8.9;

interface IAggregator {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}