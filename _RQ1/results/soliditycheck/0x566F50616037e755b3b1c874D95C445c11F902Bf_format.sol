         pragma solidity 0.6.12;
 interface IPriceFeed {
 function getLatestPrice() external view returns (int256, uint256);
 function latestRoundData() external view returns ( uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound );
 function decimals() external view returns (uint8);
 }
 pragma solidity 0.6.12;
 contract ChainlinkPriceFeed is IPriceFeed {
 address public chainlinkFeedAddress;
 constructor(address _source) public {
 require(_source != address(0), "ChainlinkPriceFeed: Invalid source");
 chainlinkFeedAddress = _source;
 }
 function getLatestPrice() external override view returns (int256, uint256) {
 (, int256 price, , uint256 lastUpdate, ) = IChainlinkPriceFeed(chainlinkFeedAddress).latestRoundData();
 return (price, lastUpdate);
 }
 function latestRoundData() external override view returns ( uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound ) {
 return IChainlinkPriceFeed(chainlinkFeedAddress).latestRoundData();
 }
 function decimals() external override view returns (uint8) {
 return IChainlinkPriceFeed(chainlinkFeedAddress).decimals();
 }
 }
 pragma solidity 0.6.12;
 interface IChainlinkPriceFeed {
 function decimals() external view returns (uint8);
 function latestRoundData() external view returns ( uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound );
 function getAnswer(uint256 roundId) external view returns (int256);
 function getTimestamp(uint256 roundId) external view returns (uint256);
 }
