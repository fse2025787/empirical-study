// SPDX-License-Identifier: UNLICENSED


// 

pragma solidity ^0.8.10;

interface IPropertyValidator {
    
    ///      Should revert if the asset does not satisfy the specified properties.
    
    
    
    function validateProperty(
        address tokenAddress,
        uint256 tokenId,
        bytes calldata propertyData
    ) external view;
}// 

pragma solidity ^0.8.10;





library Types {
    enum Operation {
        Ignore,
        LessThanOrEqualTo,
        GreaterThanOrEqualTo,
        Equal
    }
}

contract PropertyValidator is IPropertyValidator {
    function validateProperty(
        address tokenAddress,
        uint256 tokenId,
        bytes calldata propertyData
    ) external view override {
        (
            uint256 strikePrice,
            Types.Operation strikePriceOperation,
            uint256 expiry,
            Types.Operation expiryOperation,
            bool withinRange,
            uint256 tokenIdLow,
            uint256 tokenIdHigh
        ) = abi.decode(
                propertyData,
                (
                    uint256,
                    Types.Operation,
                    uint256,
                    Types.Operation,
                    bool,
                    uint256,
                    uint256
                )
            );

        IHookCallOption optionContract = IHookCallOption(tokenAddress);

        compare(
            optionContract.getStrikePrice(tokenId),
            strikePrice,
            strikePriceOperation
        );

        if (withinRange) {
            uint32 assetId = optionContract.getAssetId(tokenId);
            if (assetId > 0) {
                /// if the assetId is non-zero, we know that this asset is
                /// within a multivault and we can simply get the data from the call
                ensureInRange(assetId, tokenIdLow, tokenIdHigh);
            } else {
                IHookVault vault = IHookVault(
                    optionContract.getVaultAddress(tokenId)
                );
                ensureInRange(
                    vault.assetTokenId(assetId),
                    tokenIdLow,
                    tokenIdHigh
                );
            }
        }

        compare(optionContract.getExpiration(tokenId), expiry, expiryOperation);
    }

    function ensureInRange(
        uint256 tokenId,
        uint256 lowerBound,
        uint256 upperBound
    ) internal pure {
        require(tokenId >= lowerBound, "tokenId must be above the lower bound");
        require(tokenId <= upperBound, "tokenId must be below the upper bound");
    }

    function compare(
        uint256 actual,
        uint256 comparingTo,
        Types.Operation operation
    ) internal pure {
        if (operation == Types.Operation.Equal) {
            require(actual == comparingTo, "values are not equal");
        } else if (operation == Types.Operation.LessThanOrEqualTo) {
            require(
                actual <= comparingTo,
                "actual value is not <= comparison value"
            );
        } else if (operation == Types.Operation.GreaterThanOrEqualTo) {
            require(
                actual >= comparingTo,
                "actual value is not >= comparison value"
            );
        }
    }

    function encode(
        uint256 strikePrice,
        Types.Operation strikePriceOperation,
        uint256 expiry,
        Types.Operation expiryOperation,
        bool withinRange,
        uint256 tokenIdLow,
        uint256 tokenIdHigh
    ) external pure returns (bytes memory) {
        return
            abi.encode(
                strikePrice,
                strikePriceOperation,
                expiry,
                expiryOperation,
                withinRange,
                tokenIdLow,
                tokenIdHigh
            );
    }
}

// 

pragma solidity ^0.8.10;

interface IHookCallOption {
    
    function getStrikePrice(uint256 optionId) external view returns (uint256);

    
    /// option is invalid
    function getExpiration(uint256 optionId) external view returns (uint256);

    function createOption(
        address tokenAddress,
        uint256 tokenId,
        uint128 strikePrice,
        uint32 expirationTime,
        bool solo
    ) external returns (uint256);

    function getAssetId(uint256 optionId) external view returns (uint32);

    function getVaultAddress(uint256 optionId) external view returns (address);
}

// 

pragma solidity ^0.8.10;

interface IHookVault {
    function assetTokenId(uint32 assetId) external view returns (uint256);
}
