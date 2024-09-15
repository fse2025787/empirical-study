
pragma solidity ^0.4.13;

interface RiskMgmtInterface {

    // METHODS
    // PUBLIC VIEW METHODS

    
    
    
    
    
    
    
    
    function isMakePermitted(
        uint orderPrice,
        uint referencePrice,
        address sellAsset,
        address buyAsset,
        uint sellQuantity,
        uint buyQuantity
    ) view returns (bool);

    
    
    
    
    
    
    
    
    function isTakePermitted(
        uint orderPrice,
        uint referencePrice,
        address sellAsset,
        address buyAsset,
        uint sellQuantity,
        uint buyQuantity
    ) view returns (bool);
}

contract NoRiskMgmt is RiskMgmtInterface {

    // PUBLIC VIEW METHODS

    
    
    
    
    
    
    
    
    function isMakePermitted(
        uint orderPrice,
        uint referencePrice,
        address sellAsset,
        address buyAsset,
        uint sellQuantity,
        uint buyQuantity
    )
        view
        returns (bool)
    {
        return true; // For testing purposes
    }

    
    
    
    
    
    
    
    
    function isTakePermitted(
        uint orderPrice,
        uint referencePrice,
        address sellAsset,
        address buyAsset,
        uint sellQuantity,
        uint buyQuantity
    )
        view
        returns (bool)
    {
        return true; // For testing purposes
    }
}