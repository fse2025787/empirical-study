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
// solhint-disable func-name-mixedcase

pragma solidity 0.8.4;


// Chainlink Aggregator

interface IAggregator {
    function latestAnswer() external view returns (int256 answer);
}

interface IYearnVault {
    function pricePerShare() external view returns (uint256 price);
}

interface ICurvePool {
    function get_virtual_price() external view returns (uint256 price);
    function lp_price() external view returns (uint256 price);
}

contract YVDAIOracle is IOracle {
    IYearnVault public constant YVDAI = IYearnVault(0xdA816459F1AB5631232FE5e97a05BBBb94970c95);

    function _get() internal view returns (uint256) {
        return 1e36 / YVDAI.pricePerShare();
    }

    
    function get(bytes calldata) public view override returns (bool, uint256) {
        return (true, _get());
    }

    
    function peek(bytes calldata) public view override returns (bool, uint256) {
        return (true, _get());
    }

    
    function peekSpot(bytes calldata data) external view override returns (uint256 rate) {
        (, rate) = peek(data);
    }

    
    function name(bytes calldata) public pure override returns (string memory) {
        return "Chainlink YVDAI";
    }

    
    function symbol(bytes calldata) public pure override returns (string memory) {
        return "LINK/YVDAI";
    }
}
