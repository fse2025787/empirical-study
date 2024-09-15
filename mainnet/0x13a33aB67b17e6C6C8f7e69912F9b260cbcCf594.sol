// SPDX-License-Identifier: MIT


// 
pragma solidity 0.8.10;

interface IRentable {
    
    event AccrueReferralFee(
        uint256 indexed _assetId,
        uint256 _rentId,
        address indexed _referrer,
        address indexed _paymentToken,
        uint256 _fee
    );

    
    event Rent(
        uint256 indexed _assetId,
        uint256 _rentId,
        address indexed _renter,
        uint256 _start,
        uint256 _end,
        address indexed _paymentToken,
        uint256 _rent,
        uint256 _protocolFee
    );
}// 
pragma solidity 0.8.10;



contract LandWorksDecentralandAdminOperatorUpdater {
    IDecentralandFacet immutable landWorks;

    constructor(address _landWorks) {
        landWorks = IDecentralandFacet(_landWorks);
    }

    function updateAssetsAdministrativeState(uint256[] memory _assets)
        external
    {
        for (uint256 i = 0; i < _assets.length; i++) {
            landWorks.updateAdministrativeState(_assets[i]);
        }
    }
}

// 
pragma solidity 0.8.10;



interface IDecentralandFacet is IRentable {
    event UpdateState(
        uint256 indexed _assetId,
        uint256 _rentId,
        address indexed _operator
    );
    event UpdateAdministrativeState(
        uint256 indexed _assetId,
        address indexed _operator
    );
    event UpdateOperator(
        uint256 indexed _assetId,
        uint256 _rentId,
        address indexed _operator
    );
    event UpdateAdministrativeOperator(address _administrativeOperator);

    
    /// Transfers and locks the provided metaverse asset to the contract.
    /// and mints an asset, representing the locked asset.
    /// Listing with a referrer might lead to additional rewards upon rents.
    /// Additional reward may vary depending on the referrer's requested portion for listers.
    /// If the referrer is blacklisted after the listing,
    /// listers will not receive additional rewards.
    /// See {IReferralFacet-setMetaverseRegistryReferrers}, {IReferralFacet-setReferrers}.
    /// Updates the corresponding Estate/LAND operator with the administrative operator.
    
    
    
    
    
    
    /// the asset to be rented at an any given moment.
    
    /// Provide 0x0000000000000000000000000000000000000001 for ETH.
    
    
    
    function listDecentraland(
        uint256 _metaverseId,
        address _metaverseRegistry,
        uint256 _metaverseAssetId,
        uint256 _minPeriod,
        uint256 _maxPeriod,
        uint256 _maxFutureTime,
        address _paymentToken,
        uint256 _pricePerSecond,
        address _referrer
    ) external returns (uint256);

    
    
    
    
    
    
    
    
    
    
    function rentDecentraland(
        uint256 _assetId,
        uint256 _period,
        uint256 _maxRentStart,
        address _operator,
        address _paymentToken,
        uint256 _amount,
        address _referrer
    ) external payable returns (uint256 rentId_, bool rentStartsNow_);

    
    /// When the rent becomes active (the current block.timestamp is between the rent's start and end),
    /// this function should be executed to set the provided rent operator to the Estate/LAND scene operator.
    
    
    function updateState(uint256 _assetId, uint256 _rentId) external;

    
    
    function updateAdministrativeState(uint256 _assetId) external;

    
    
    
    
    
    function updateOperator(
        uint256 _assetId,
        uint256 _rentId,
        address _newOperator
    ) external;

    
    
    function updateAdministrativeOperator(address _administrativeOperator)
        external;

    
    
    /// The function's goal is to have the possibility to clear the operators of LANDs, which have been set
    /// before the estate has been listed in LandWorks, otherwise whenever someone rents the estate, there might
    /// be other operators, who can override the renter's scene.
    
    
    function clearEstateLANDOperators(
        uint256[] memory _assetIds,
        uint256[][] memory _landIds
    ) external;

    
    function administrativeOperator() external view returns (address);

    
    
    
    function operatorFor(uint256 _assetId, uint256 _rentId)
        external
        view
        returns (address);
}
