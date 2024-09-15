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
}

// 
pragma solidity >= 0.6.12;

interface IPopsicle {
    function pool() external view returns (address);

    function usersAmounts() external view returns (uint256 amount0, uint256 amount1);

    function totalSupply() external view returns (uint256 amount);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function withdraw(uint256 shares, address to) external returns (uint256 amount0, uint256 amount1);

    function tickLower() external view returns(int24);
    function tickUpper() external view returns(int24);
    
    function deposit(
        uint256 amount0Desired,
        uint256 amount1Desired,
        address to
    )
        external
        returns (
            uint256 shares,
            uint256 amount0,
            uint256 amount1
        );
}

// 
pragma solidity 0.8.9;



// Chainlink Aggregator
interface IAggregator {
    function latestAnswer() external view returns (int256 answer);
}

contract PopsicleUSDCWETHOracle is IOracle {
    IAggregator public constant USDC = IAggregator(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6);
    IAggregator public constant ETH = IAggregator(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    IPopsicle public immutable popsicle;

    constructor(IPopsicle _popsicle) {
        popsicle = _popsicle;
    }

    // Calculates the lastest exchange rate
    // Uses both divide and multiply only for tokens not supported directly by Chainlink, for example MKR/USD
    function _get() internal view returns (uint256) {
        (uint256 amount0, uint256 amount1) = popsicle.usersAmounts();
        uint256 popsiclePrice = (amount0 * 1e12 * uint256(USDC.latestAnswer()) + amount1 * uint256(ETH.latestAnswer())) /
            popsicle.totalSupply() /
            1e8;
        return 1e36 / popsiclePrice;
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
        return "Chainlink Popsicle";
    }

    
    function symbol(bytes calldata) public pure override returns (string memory) {
        return "LINK/PLP";
    }
}