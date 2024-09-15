// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

// 
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
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
}// 
pragma solidity ^0.8.14;





contract RoundIdFetcher {

    constructor() {}

    
    
    
    
    
    
    function getPhaseForTimestamp(AggregatorV2V3Interface _feed, uint256 _targetTime) public view returns (uint80, uint256, uint80) {
        uint16 currentPhase = uint16(_feed.latestRound() >> 64);
        uint80 firstRoundOfCurrentPhase = (uint80(currentPhase) << 64) + 1;
        
        for (uint16 phase = currentPhase; phase >= 1; phase--) {
            uint80 firstRoundOfPhase = (uint80(phase) << 64) + 1;
            uint256 firstTimeOfPhase = _feed.getTimestamp(firstRoundOfPhase);

            if (_targetTime > firstTimeOfPhase) {
                return (firstRoundOfPhase, firstTimeOfPhase, firstRoundOfCurrentPhase);
            }
        }
        return (0,0, firstRoundOfCurrentPhase);
    }

    
    
    
    
    
    
    
    function _binarySearchForTimestamp(AggregatorV2V3Interface _feed, uint256 _targetTime, uint80 _lhRound, uint256 _lhTime, uint80 _rhRound) public view returns (uint80 targetRound) {

        if (_lhTime > _targetTime) return 0; // targetTime not in range

        uint80 guessRound = _rhRound;
        while (_rhRound - _lhRound > 1) {
            guessRound = uint80(int80(_lhRound) + int80(_rhRound - _lhRound)/2);
            uint256 guessTime = _feed.getTimestamp(uint256(guessRound));
            if (guessTime == 0 || guessTime > _targetTime) {
                _rhRound = guessRound;
            } else if (guessTime < _targetTime) {
                (_lhRound, _lhTime) = (guessRound, guessTime);
            }
        }
        return guessRound;
    }

    
    
    
    
    function getRoundId(AggregatorV2V3Interface _feed, uint256 _timeStamp) public view returns (uint80 roundId) {

        (uint80 lhRound, uint256 lhTime, uint80 firstRoundOfCurrentPhase) = getPhaseForTimestamp(_feed, _timeStamp);

        uint80 rhRound;
        if (lhRound == 0) {
            // Date is too far in the past, no data available
            return 0;
        } else if (lhRound == firstRoundOfCurrentPhase) {
            (rhRound,,,,) = _feed.latestRoundData();
        } else {
            // No good way to get last round of phase from Chainlink feed, so our binary search function will have to use trial & error.
            // Use 2**16 == 65536 as a upper bound on the number of rounds to search in a single Chainlink phase.
            
            rhRound = lhRound + 2**16; 
        } 

        uint80 foundRoundId = _binarySearchForTimestamp(_feed, _timeStamp, lhRound, lhTime, rhRound);
        roundId = getRoundIdForTimestamp(_feed, _timeStamp, foundRoundId, lhRound);
        
        return roundId;
    }

    function getRoundIdForTimestamp(AggregatorV2V3Interface _feed, uint256 _timeStamp, uint80 _roundId, uint80 _firstRoundOfPhase) internal view returns (uint80) {
        uint256 roundTimeStamp = _feed.getTimestamp(_roundId);

        if (roundTimeStamp > _timeStamp && _roundId > _firstRoundOfPhase) {
            _roundId = getRoundIdForTimestamp(_feed, _timeStamp, _roundId - 1, _firstRoundOfPhase);
        } else if (roundTimeStamp > _timeStamp && _roundId == _firstRoundOfPhase) {
            _roundId = 0;
        }
            return _roundId;
    }
}

// 
pragma solidity ^0.8.0;




interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface {}
