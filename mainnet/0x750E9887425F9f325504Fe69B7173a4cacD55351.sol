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
pragma solidity 0.8.10;


// Chainlink Aggregator

interface IAggregator {
    function latestAnswer() external view returns (int256 answer);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract WbtcOracle is IOracle {
    IAggregator constant public BTCUSD = IAggregator(0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c);

    // Calculates the lastest exchange rate
    // Uses both divide and multiply only for tokens not supported directly by Chainlink, for example MKR/USD
    function _get() internal view returns (uint256) {

        return 1e16 / uint256(BTCUSD.latestAnswer());
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
        return "Chainlink BTC";
    }

    
    function symbol(bytes calldata) public pure override returns (string memory) {
        return "LINK/BTC";
    }
}
