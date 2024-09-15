// SPDX-License-Identifier: ISC


// 
pragma solidity ^0.8.17;

interface IRateCalculatorV2 {
    function name() external view returns (string memory);

    function version() external view returns (uint256, uint256, uint256);

    function getNewRate(uint256 _deltaTime, uint256 _utilization, uint64 _maxInterest)
        external
        view
        returns (uint64 _newRatePerSec, uint64 _newMaxInterest);
}// 
pragma solidity ^0.8.17;

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ====================== VariableInterestRate ========================
// ====================================================================
// Frax Finance: https://github.com/FraxFinance

// Primary Author
// Drake Evans: https://github.com/DrakeEvans

// Reviewers
// Dennis: https://github.com/denett

// ====================================================================






contract VariableInterestRate is IRateCalculatorV2 {
    // Utilization Settings
    
    uint256 public immutable MIN_TARGET_UTIL;
    
    uint256 public immutable MAX_TARGET_UTIL;
    
    uint256 public immutable VERTEX_UTILIZATION;
    
    uint256 public constant UTIL_PREC = 1e5; // 5 decimals

    // Interest Rate Settings (all rates are per second), 365.24 days per year
    
    uint64 public immutable MIN_INT; // 18 decimals
    
    uint64 public immutable MAX_INT; // 18 decimals
    
    uint256 public immutable INT_HALF_LIFE; // 1 decimals
    
    uint256 public immutable VERTEX_INTEREST_PERCENT; // 18 decimals
    
    uint256 public constant INT_PREC = 1e18; // 18 decimals

    
    
    
    
    
    
    
    
    constructor(
        uint256 _vertexUtilization,
        uint256 _vertexInterestPercentOfMax,
        uint256 _minUtil,
        uint256 _maxUtil,
        uint64 _minInterest,
        uint64 _maxInterest,
        uint256 _interestHalfLife
    ) {
        MIN_TARGET_UTIL = _minUtil;
        MAX_TARGET_UTIL = _maxUtil;
        VERTEX_UTILIZATION = _vertexUtilization;

        MIN_INT = _minInterest;
        MAX_INT = _maxInterest;
        INT_HALF_LIFE = _interestHalfLife;
        VERTEX_INTEREST_PERCENT = _vertexInterestPercentOfMax;
    }

    
    
    function name() external pure returns (string memory) {
        return "Variable Time-Weighted Interest Rate V2";
    }

    
    
    
    
    
    function version() external pure returns (uint256 _major, uint256 _minor, uint256 _patch) {
        _major = 2;
        _minor = 0;
        _patch = 0;
    }

    
    
    
    
    
    
    function getFullUtilizationInterest(uint256 _deltaTime, uint256 _utilization, uint64 _fullUtilizationInterest)
        internal
        view
        returns (uint64 _newFullUtilizationInterest)
    {
        if (_utilization < MIN_TARGET_UTIL) {
            // 18 decimals
            uint256 _deltaUtilization = ((MIN_TARGET_UTIL - _utilization) * 1e18) / MIN_TARGET_UTIL;
            // 36 decimals
            uint256 _decayGrowth = (INT_HALF_LIFE * 1e36) + (_deltaUtilization * _deltaUtilization * _deltaTime);
            // 18 decimals
            _newFullUtilizationInterest = uint64((_fullUtilizationInterest * (INT_HALF_LIFE * 1e36)) / _decayGrowth);
        } else if (_utilization > MAX_TARGET_UTIL) {
            // 18 decimals
            uint256 _deltaUtilization = ((_utilization - MAX_TARGET_UTIL) * 1e18) / (UTIL_PREC - MAX_TARGET_UTIL);
            // 36 decimals
            uint256 _decayGrowth = (INT_HALF_LIFE * 1e36) + (_deltaUtilization * _deltaUtilization * _deltaTime);
            // 18 decimals
            _newFullUtilizationInterest = uint64((_fullUtilizationInterest * _decayGrowth) / (INT_HALF_LIFE * 1e36));
        } else {
            _newFullUtilizationInterest = _fullUtilizationInterest;
        }
        if (_newFullUtilizationInterest > MAX_INT) {
            _newFullUtilizationInterest = uint64(MAX_INT);
        } else if (_newFullUtilizationInterest < MIN_INT) {
            _newFullUtilizationInterest = uint64(MIN_INT);
        }
    }

    
    
    
    
    
    
    function getNewRate(uint256 _deltaTime, uint256 _utilization, uint64 _oldFullUtilizationInterest)
        external
        view
        returns (uint64 _newRatePerSec, uint64 _newFullUtilizationInterest)
    {
        _newFullUtilizationInterest = getFullUtilizationInterest(_deltaTime, _utilization, _oldFullUtilizationInterest);

        // _vertexInterest is calculated as the percentage of the detla between min and max interest
        uint256 _vertexInterest = (((_newFullUtilizationInterest - MIN_INT) * VERTEX_INTEREST_PERCENT) / INT_PREC) +
            MIN_INT;
        if (_utilization < VERTEX_UTILIZATION) {
            // For readability, the following formula is equivalent to:
            // uint256 _slope = ((_vertexInterest - MIN_INT) * UTIL_PREC) / VERTEX_UTILIZATION;
            // _newRatePerSec = uint64(MIN_INT + ((_utilization * _slope) / UTIL_PREC));

            // 18 decimals
            _newRatePerSec = uint64(MIN_INT + (_utilization * (_vertexInterest - MIN_INT)) / VERTEX_UTILIZATION);
        } else {
            // For readability, the following formula is equivalent to:
            // uint256 _slope = (((_newFullUtilizationInterest - _vertexInterest) * UTIL_PREC) / (UTIL_PREC - VERTEX_UTILIZATION));
            // _newRatePerSec = uint64(_vertexInterest + (((_utilization - VERTEX_UTILIZATION) * _slope) / UTIL_PREC));

            // 18 decimals
            _newRatePerSec = uint64(
                _vertexInterest +
                    ((_utilization - VERTEX_UTILIZATION) * (_newFullUtilizationInterest - _vertexInterest)) /
                    (UTIL_PREC - VERTEX_UTILIZATION)
            );
        }
        if (_newRatePerSec < MIN_INT) {
            _newRatePerSec = uint64(MIN_INT);
        } else if (_newRatePerSec > MAX_INT) {
            _newRatePerSec = uint64(MAX_INT);
        }
    }
}
