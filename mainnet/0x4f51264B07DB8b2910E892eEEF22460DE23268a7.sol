// SPDX-License-Identifier: MIT


// 
pragma solidity >= 0.6.12;

interface IOracle {
    
    
    /// For example:
    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));
    
    
    function get(bytes calldata data) external returns (bool success, uint256 rate);

    
    
    /// For example:
    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));
    
    
    function peek(bytes calldata data) external view returns (bool success, uint256 rate);

    
    
    /// For example:
    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));
    
    function peekSpot(bytes calldata data) external view returns (uint256 rate);

    
    
    /// For example:
    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));
    
    function symbol(bytes calldata data) external view returns (string memory);

    
    
    /// For example:
    /// (string memory collateralSymbol, string memory assetSymbol, uint256 division) = abi.decode(data, (string, string, uint256));
    
    function name(bytes calldata data) external view returns (string memory);
}// 
pragma solidity 0.8.4;


// Chainlink Aggregator

interface IAggregator {
    function latestAnswer() external view returns (int256 answer);
}

contract USTOracle is IOracle {
    IAggregator constant public USTETH = IAggregator(0xa20623070413d42a5C01Db2c8111640DD7A5A03a);
    IAggregator constant public ETH = IAggregator(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

    // Calculates the lastest exchange rate
    // Uses both divide and multiply only for tokens not supported directly by Chainlink, for example MKR/USD
    function _get() internal view returns (uint256) {

        uint256 ustPrice = uint256(USTETH.latestAnswer()) * uint256(ETH.latestAnswer());

        return 1e44 / ustPrice;
    }

    // Get the latest exchange rate
    
    function get(bytes calldata) public view override returns (bool, uint256) {
        return (true, _get());
    }

    // Check the last exchange rate without any state changes
    
    function peek(bytes calldata) public view override returns (bool, uint256) {
        return (true, _get());
    }

    // Check the current spot exchange rate without any state changes
    
    function peekSpot(bytes calldata data) external view override returns (uint256 rate) {
        (, rate) = peek(data);
    }

    
    function name(bytes calldata) public pure override returns (string memory) {
        return "Chainlink UST";
    }

    
    function symbol(bytes calldata) public pure override returns (string memory) {
        return "LINK/UST";
    }
}
