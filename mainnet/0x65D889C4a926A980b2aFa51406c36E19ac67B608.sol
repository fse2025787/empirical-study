// SPDX-License-Identifier: MIT

// License-Identifier: MIT
pragma solidity 0.8.7;


interface IwOHM {
    function sOHMTowOHM( uint256 amountSOHM ) external view returns ( uint256 amountWOHM);
}

interface IAggregator {
    function latestAnswer() external view returns (int256 answer);
}

contract wOHMOracle is IAggregator {
    IAggregator private constant ohmOracle = IAggregator(0x90c2098473852E2F07678Fe1B6d595b1bd9b16Ed);
    IwOHM public constant wOHM = IwOHM(0xCa76543Cf381ebBB277bE79574059e32108e3E65);

    // Calculates the lastest exchange rate
    // Uses ohm rate and wOHM conversion
    function latestAnswer() external view override returns (int256) {
        return int256(wOHM.sOHMTowOHM(uint256(ohmOracle.latestAnswer())) / 1e9);
    }
}

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
}

