// SPDX-License-Identifier: MIT


// 
pragma solidity >=0.6.12;

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

interface IYearnVault {
    function pricePerShare() external view returns (uint256 price);
}

contract YearnChainlinkOracleV3 is IOracle {
    // Calculates the lastest exchange rate
    // Uses both divide and multiply only for tokens not supported directly by Chainlink, for example MKR/USD
    function _get(
        address multiply,
        address divide,
        uint256 decimals,
        address yearnVault
    ) internal view returns (uint256) {
        uint256 price = uint256(1e36);
        if (multiply != address(0)) {
            price = price * uint256(IAggregator(multiply).latestAnswer());
        } else {
            price = price * 1e18;
        }

        if (divide != address(0)) {
            price = price / uint256(IAggregator(divide).latestAnswer());
        }

        // @note decimals have to take into account the decimals of the vault asset
        return price / (decimals * IYearnVault(yearnVault).pricePerShare());
    }

    function getDataParameter(
        address multiply,
        address divide,
        uint256 decimals,
        address yearnVault
    ) public pure returns (bytes memory) {
        return abi.encode(multiply, divide, decimals, yearnVault);
    }

    // Get the latest exchange rate
    
    function get(bytes calldata data) public view override returns (bool, uint256) {
        (address multiply, address divide, uint256 decimals, address yearnVault) = abi.decode(data, (address, address, uint256, address));
        return (true, _get(multiply, divide, decimals, yearnVault));
    }
    
    // Check the last exchange rate without any state changes
    
    function peek(bytes calldata data) public view override returns (bool, uint256) {
        (address multiply, address divide, uint256 decimals, address yearnVault) = abi.decode(data, (address, address, uint256, address));
        return (true, _get(multiply, divide, decimals, yearnVault));
    }

    // Check the current spot exchange rate without any state changes
    
    function peekSpot(bytes calldata data) external view override returns (uint256 rate) {
        (, rate) = peek(data);
    }

    
    function name(bytes calldata) public view override returns (string memory) {
        return "Chainlink";
    }

    
    function symbol(bytes calldata) public view override returns (string memory) {
        return "LINK";
    }
}
