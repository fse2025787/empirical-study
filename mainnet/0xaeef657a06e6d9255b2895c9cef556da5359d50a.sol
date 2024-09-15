// SPDX-License-Identifier: MIXED

/**
 *Submitted for verification at Etherscan.io on 2022-12-14
*/

// 

// File contracts/interfaces/IOracle.sol
// License-Identifier: MIT
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

// File contracts/oracles/YVCrvStETHOracle.sol
// License-Identifier: MIT
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
}

interface ICurvePoolOwner {
    function withdraw_admin_fees(ICurvePool pool) external;
}

contract YVCrvStETHOracleV2 is IOracle {
    ICurvePool constant public STETH = ICurvePool(0xDC24316b9AE028F1497c275EB9192a3Ea0f67022);
    IAggregator constant public STETHETH = IAggregator(0x86392dC19c0b719886221c78AB11eb8Cf5c52812);
    IYearnVault constant public YVSTETH = IYearnVault(0xdCD90C7f6324cfa40d7169ef80b12031770B4325);
    IAggregator constant public ETH = IAggregator(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    ICurvePoolOwner constant public curvePoolOwner = ICurvePoolOwner(0xeCb456EA5365865EbAb8a2661B0c503410e9B347);

    /**
     * @dev Returns the smallest of two numbers.
     */
    // FROM: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/6d97f0919547df11be9443b54af2d90631eaa733/contracts/utils/math/Math.sol
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    // Calculates the lastest exchange rate
    // Uses both divide and multiply only for tokens not supported directly by Chainlink, for example MKR/USD
    function _get() internal view returns (uint256) {

        uint256 yVCurvePrice = STETH.get_virtual_price() * (min(uint256(STETHETH.latestAnswer()), uint256(1e18)) / 1e8) * uint256(ETH.latestAnswer()) * YVSTETH.pricePerShare();
        
        return 1e72/ yVCurvePrice;
    }

    // Get the latest exchange rate
    
    function get(bytes calldata) public override returns (bool, uint256) {
        curvePoolOwner.withdraw_admin_fees(STETH);
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
        return "Yearn Chainlink Curve STETH";
    }

    
    function symbol(bytes calldata) public pure override returns (string memory) {
        return "LINK/yvCRVSTETH";
    }
}