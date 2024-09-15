// SPDX-License-Identifier: agpl-3.0

// 
pragma solidity 0.8.5;

/**
    Error codes:
    - O1 = ERROR_ORACLE_AGGREGATOR_DATA_ALREADY_EXISTS
    - O2 = ERROR_ORACLE_AGGREGATOR_DATA_DOESNT_EXIST
 */


contract OracleAggregator {
    event LogDataProvided(address indexed _oracleId, uint256 indexed _timestamp, uint256 indexed _data);
    // Storage for the `oracleId` results
    // dataCache[oracleId][timestamp] => data
    mapping(address => mapping(uint256 => uint256)) private dataCache;

    // Flags whether data were provided
    // dataExist[oracleId][timestamp] => bool
    mapping(address => mapping(uint256 => bool)) private dataExist;

    // EXTERNAL FUNCTIONS

    
    
    
    function __callback(uint256 timestamp, uint256 data) external {
        // Don't allow to push data twice
        require(!dataExist[msg.sender][timestamp], "O1");

        // Saving data
        dataCache[msg.sender][timestamp] = data;

        // Flagging that data were received
        dataExist[msg.sender][timestamp] = true;

        emit LogDataProvided(msg.sender, timestamp, data);
    }

    // VIEW FUNCTIONS

    
    
    
    
    function getData(address oracleId, uint256 timestamp) external view returns (uint256 dataResult) {
        // Check if Opium.OracleAggregator has data
        require(hasData(oracleId, timestamp), "O2");

        // Return cached data
        dataResult = dataCache[oracleId][timestamp];
    }

    
    
    
    
    function hasData(address oracleId, uint256 timestamp) public view returns (bool result) {
        return dataExist[oracleId][timestamp];
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private __gap;
}