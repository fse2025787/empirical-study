// SPDX-License-Identifier: MIT


// 
pragma solidity 0.8.10;

interface IRentable {

    
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



contract DecentralandAdminOperatorUpdater {
    function updateAssetsAdministrativeState(
        address _landWorks,
        uint256[] memory _assets
    ) public {
        IDecentralandFacet landWorks = IDecentralandFacet(_landWorks);
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

    
    
    
    
    
    
    function rentDecentraland(
        uint256 _assetId,
        uint256 _period,
        address _operator,
        address _paymentToken,
        uint256 _amount
    ) external payable;

    
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

    
    function administrativeOperator() external view returns (address);

    
    
    
    function operatorFor(uint256 _assetId, uint256 _rentId)
        external
        view
        returns (address);
}
