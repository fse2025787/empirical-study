// SPDX-License-Identifier: MIT

// 
pragma solidity >=0.8.0;

interface IAggregator {
    function decimals() external view returns (uint8);

    function latestAnswer() external view returns (int256 answer);

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
}

// 
pragma solidity >=0.8.0;

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

// 
pragma solidity >=0.8.0;




contract InverseOracle is IOracle {
    IAggregator public immutable denominatorOracle;
    IAggregator public immutable oracle;
    uint256 public immutable decimalScale;
    bool public immutable useDenominator;

    string private desc;

    constructor(
        IAggregator _oracle,
        IAggregator _denominatorOracle,
        string memory _desc
    ) {
        oracle = _oracle;
        denominatorOracle = _denominatorOracle;
        desc = _desc;
        useDenominator = address(_denominatorOracle) != address(0);
        decimalScale = useDenominator ? 10**(18 + _oracle.decimals() + _denominatorOracle.decimals()) : 10**(18 + _oracle.decimals());
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function _get() internal view returns (uint256) {
        return decimalScale / uint256(oracle.latestAnswer());
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

    
    function name(bytes calldata) public view override returns (string memory) {
        return desc;
    }

    
    function symbol(bytes calldata) public view override returns (string memory) {
        return desc;
    }
}