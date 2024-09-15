// SPDX-License-Identifier: GPL-3.0

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;






contract UsdEthSimulatedAggregator {
    // The quote asset of this feed is ETH, so 18 decimals makes sense,
    // both in terms of a mocked Chainlink aggregator and for greater precision
    uint8 private constant DECIMALS = 18;
    // 10 ** (Local precision (DECIMALS) + EthUsd aggregator decimals)
    int256 private constant INVERSE_RATE_NUMERATOR = 10**26;

    IChainlinkAggregator private immutable ETH_USD_AGGREGATOR_CONTRACT;

    constructor(address _ethUsdAggregator) public {
        ETH_USD_AGGREGATOR_CONTRACT = IChainlinkAggregator(_ethUsdAggregator);
    }

    
    
    function decimals() external pure returns (uint8 decimals_) {
        return DECIMALS;
    }

    
    
    
    
    
    
    
    /// other than `answer_`, which is inverted to give the USD/ETH rate,
    /// and is given the local precision of `DECIMALS`.
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId_,
            int256 answer_,
            uint256 startedAt_,
            uint256 updatedAt_,
            uint80 answeredInRound_
        )
    {
        int256 ethUsdAnswer;
        (
            roundId_,
            ethUsdAnswer,
            startedAt_,
            updatedAt_,
            answeredInRound_
        ) = ETH_USD_AGGREGATOR_CONTRACT.latestRoundData();

        // Does not attempt to make sense of a negative answer
        if (ethUsdAnswer > 0) {
            answer_ = INVERSE_RATE_NUMERATOR / ethUsdAnswer;
        }

        return (roundId_, answer_, startedAt_, updatedAt_, answeredInRound_);
    }
}

// 

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;



interface IChainlinkAggregator {
    function latestRoundData()
        external
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        );
}