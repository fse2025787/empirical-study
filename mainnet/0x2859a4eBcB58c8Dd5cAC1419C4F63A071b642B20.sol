// SPDX-License-Identifier: GPL-3.0


// 

pragma solidity ^0.8.7;




/// from just UniswapV3 or from just Chainlink
interface IOracle {
    function read() external view returns (uint256);

    function readAll() external view returns (uint256 lowerRate, uint256 upperRate);

    function readLower() external view returns (uint256);

    function readUpper() external view returns (uint256);

    function readQuote(uint256 baseAmount) external view returns (uint256);

    function readQuoteLower(uint256 baseAmount) external view returns (uint256);

    function inBase() external view returns (uint256);
}

// 

pragma solidity ^0.8.7;






abstract contract ChainlinkUtils {
    
    /// the out-currency
    
    
    
    /// to the `quoteAmount`
    
    
    /// This is mostly used in the `_changeUniswapNotFinal` function of the oracles
    
    
    function _readChainlinkFeed(
        uint256 quoteAmount,
        AggregatorV3Interface feed,
        uint8 multiplied,
        uint256 decimals,
        uint256 castedRatio
    ) internal view returns (uint256, uint256) {
        if (castedRatio == 0) {
            (, int256 ratio, , , ) = feed.latestRoundData();
            require(ratio > 0, "100");
            castedRatio = uint256(ratio);
        }
        // Checking whether we should multiply or divide by the ratio computed
        if (multiplied == 1) quoteAmount = (quoteAmount * castedRatio) / (10**decimals);
        else quoteAmount = (quoteAmount * (10**decimals)) / castedRatio;
        return (quoteAmount, castedRatio);
    }
}
// 

pragma solidity ^0.8.7;








/// if the out-currency is ETH worth 1000 USD, then the rate ETH-USD is 10**21
abstract contract OracleAbstract is IOracle {
    
    uint256 public constant BASE = 10**18;
    
    uint256 public override inBase;
    
    bytes32 public description;

    
    
    
    /// this function will return the Uniswap price
    
    function read() external view virtual override returns (uint256 rate);

    
    /// else returns twice the same price
    
    
    function readAll() external view override returns (uint256, uint256) {
        return _readAll(inBase);
    }

    
    /// and returns either the highest of both rates or the lowest
    
    
    /// regardless of the value of the `lower` parameter
    
    function readLower() external view override returns (uint256 rate) {
        (rate, ) = _readAll(inBase);
    }

    
    /// and returns either the highest of both rates or the lowest
    
    
    /// regardless of the value of the `lower` parameter
    
    function readUpper() external view override returns (uint256 rate) {
        (, rate) = _readAll(inBase);
    }

    
    /// contract
    
    
    
    /// will use the Uniswap price to compute the out quoteAmount
    
    function readQuote(uint256 quoteAmount) external view virtual override returns (uint256);

    
    /// contract only involves a single feed, then this returns the value of this feed
    
    
    
    function readQuoteLower(uint256 quoteAmount) external view override returns (uint256) {
        (uint256 quoteSmall, ) = _readAll(quoteAmount);
        return quoteSmall;
    }

    
    /// if just Uniswap or just Chainlink is used
    
    
    
    
    function _readAll(uint256 quoteAmount) internal view virtual returns (uint256, uint256) {}
}

// 

pragma solidity ^0.8.7;








abstract contract ModuleChainlinkSingle is ChainlinkUtils {
    
    AggregatorV3Interface public immutable poolChainlink;
    
    uint8 public immutable isChainlinkMultiplied;
    
    uint8 public immutable chainlinkDecimals;

    
    
    
    constructor(address _poolChainlink, uint8 _isChainlinkMultiplied) {
        require(_poolChainlink != address(0), "105");
        poolChainlink = AggregatorV3Interface(_poolChainlink);
        chainlinkDecimals = AggregatorV3Interface(_poolChainlink).decimals();
        isChainlinkMultiplied = _isChainlinkMultiplied;
    }

    
    
    
    function _quoteChainlink(uint256 quoteAmount) internal view returns (uint256, uint256) {
        // No need for a for loop here as there is only a single pool we are looking at
        return _readChainlinkFeed(quoteAmount, poolChainlink, isChainlinkMultiplied, chainlinkDecimals, 0);
    }
}
// 
pragma solidity ^0.8.0;

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

// 

// contracts/oracle/OracleChainlinkSingle.sol
pragma solidity ^0.8.7;










/// base functions
contract OracleChainlinkSingle is OracleAbstract, ModuleChainlinkSingle {
    
    
    
    /// in-currency amount to get the out-currency amount
    
    
    constructor(
        address _poolChainlink,
        uint8 _isChainlinkMultiplied,
        uint256 _inBase,
        bytes32 _description
    ) ModuleChainlinkSingle(_poolChainlink, _isChainlinkMultiplied) {
        inBase = _inBase;
        description = _description;
    }

    
    
    function read() external view override returns (uint256 rate) {
        (rate, ) = _quoteChainlink(BASE);
    }

    
    
    
    
    function readQuote(uint256 quoteAmount) external view override returns (uint256) {
        return _readQuote(quoteAmount);
    }

    
    
    
    
    
    function _readAll(uint256 quoteAmount) internal view override returns (uint256, uint256) {
        uint256 quote = _readQuote(quoteAmount);
        return (quote, quote);
    }

    
    
    
    function _readQuote(uint256 quoteAmount) internal view returns (uint256) {
        quoteAmount = (quoteAmount * BASE) / inBase;
        (quoteAmount, ) = _quoteChainlink(quoteAmount);
        // We return only rates with base BASE
        return quoteAmount;
    }
}
