// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;

// 

pragma solidity 0.6.12;





contract LendingPlatformLens {
    address public immutable foldingRegistry;

    constructor(address registry) public {
        require(registry != address(0), 'ICP0');
        foldingRegistry = registry;
    }

    function getAssetMetadata(address[] calldata platforms, address[] calldata assets)
        external
        returns (AssetMetadata[] memory assetsData)
    {
        require(platforms.length == assets.length, 'LPL1');
        assetsData = new AssetMetadata[](assets.length);

        for (uint256 i = 0; i < assets.length; i++) {
            address lender = getLender(platforms[i]);
            assetsData[i] = ILendingPlatform(lender).getAssetMetadata(platforms[i], assets[i]);
        }
    }

    function getLender(address platform) internal view returns (address) {
        return ILendingPlatformAdapterProvider(foldingRegistry).getPlatformAdapter(platform);
    }
}

// 

pragma solidity 0.6.12;



struct AssetMetadata {
    address assetAddress;
    string assetSymbol;
    uint8 assetDecimals;
    uint256 referencePrice;
    uint256 totalLiquidity;
    uint256 totalSupply;
    uint256 totalBorrow;
    uint256 totalReserves;
    uint256 supplyAPR;
    uint256 borrowAPR;
    address rewardTokenAddress;
    string rewardTokenSymbol;
    uint8 rewardTokenDecimals;
    uint256 estimatedSupplyRewardsPerYear;
    uint256 estimatedBorrowRewardsPerYear;
    uint256 collateralFactor;
    uint256 liquidationFactor;
    bool canSupply;
    bool canBorrow;
}

interface ILendingPlatform {
    function getAssetMetadata(address platform, address asset) external returns (AssetMetadata memory assetMetadata);

    function getCollateralUsageFactor(address platform) external returns (uint256 collateralUsageFactor);

    function getCollateralFactorForAsset(address platform, address asset) external returns (uint256);

    function getReferencePrice(address platform, address token) external returns (uint256 referencePrice);

    function getBorrowBalance(address platform, address token) external returns (uint256 borrowBalance);

    function getSupplyBalance(address platform, address token) external returns (uint256 supplyBalance);

    function claimRewards(address platform) external returns (address rewardsToken, uint256 rewardsAmount);

    function enterMarkets(address platform, address[] memory markets) external;

    function supply(
        address platform,
        address token,
        uint256 amount
    ) external;

    function borrow(
        address platform,
        address token,
        uint256 amount
    ) external;

    function redeemSupply(
        address platform,
        address token,
        uint256 amount
    ) external;

    function repayBorrow(
        address platform,
        address token,
        uint256 amount
    ) external;
}

// 

pragma solidity 0.6.12;

interface ILendingPlatformAdapterProvider {
    function getPlatformAdapter(address platform) external view returns (address platformAdapter);
}