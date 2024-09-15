

pragma solidity ^0.8.17;
interface IOwnable {
    function owner() external returns (address);

    function transferOwnership(address newOwner) external;
}

pragma solidity ^0.8.17;



/// the owner of the asset is always the algorithm-observer of the asset
interface IAsset is IOwnable {
    
    function count() external view returns (uint256);

    
    function withdraw(address recipient, uint256 amount) external;

    
    function clone(address owner) external returns (IAsset);

    
    function assetTypeId() external returns (uint256);

    
    function isNotifyListener() external returns (bool);

    
    function setNotifyListener(bool value) external;
}

pragma solidity ^0.8.17;



contract OwnableSimple is IOwnable {
    address internal _owner;

    constructor(address owner_) {
        _owner = owner_;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, 'caller is not the owner');
        _;
    }

    function owner() external virtual override returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) external override onlyOwner {
        _owner = newOwner;
    }
}

pragma solidity ^0.8.17;


interface IAssetCloneFactory {
    
    function clone(address asset, address owner) external returns (IAsset);
}

pragma solidity ^0.8.17;




abstract contract AssetFactoryBase is IAssetCloneFactory {
    IPositionsController public positionsController;

    constructor(address positionsController_) {
        positionsController = IPositionsController(positionsController_);
    }

    modifier onlyPositionOwner(uint256 positionId) {
        require(positionsController.ownerOf(positionId) == msg.sender);
        _;
    }

    function _setAsset(
        uint256 positionId,
        uint256 assetCode,
        ContractData memory contractData
    ) internal onlyPositionOwner(positionId) {
        positionsController.setAsset(positionId, assetCode, contractData);
    }

    function clone(address asset, address owner)
        external
        override
        returns (IAsset)
    {
        require(msg.sender == asset, 'only for assets');
        return _clone(asset, owner);
    }

    function _clone(address asset, address owner)
        internal
        virtual
        returns (IAsset);
}

pragma solidity ^0.8.17;






abstract contract AssetBase is IAsset, OwnableSimple {
    IAssetCloneFactory public factory;
    bool internal _isNotifyListener;

    constructor(address owner_, IAssetCloneFactory factory_)
        OwnableSimple(owner_)
    {
        _owner = address(owner_);
        factory = factory_;
    }

    function listener() internal view returns (IAssetListener) {
        return IAssetListener(_owner);
    }

    function withdraw(address recipient, uint256 amount)
        external
        virtual
        override
        onlyOwner
    {
        uint256[] memory data;
        if (_isNotifyListener)
            listener().beforeAssetTransfer(
                address(this),
                address(this),
                recipient,
                amount,
                data
            );
        withdrawInternal(recipient, amount);
        if (_isNotifyListener)
            listener().afterAssetTransfer(
                address(this),
                address(this),
                recipient,
                amount,
                data
            );
    }

    function withdrawInternal(address recipient, uint256 amount)
        internal
        virtual;

    function isNotifyListener() external view returns (bool) {
        return _isNotifyListener;
    }

    function setNotifyListener(bool value) external onlyOwner {
        _isNotifyListener = value;
    }
}

pragma solidity ^0.8.17;


interface IAssetListener {
    function beforeAssetTransfer(
        address asset,
        address from,
        address to,
        uint256 amount,
        uint256[] memory data
    ) external;

    function afterAssetTransfer(
        address asset,
        address from,
        address to,
        uint256 amount,
        uint256[] memory data
    ) external;
}
pragma solidity ^0.8.17;






contract EthAssetFactory is AssetFactoryBase {
    constructor(address positionsController_)
        AssetFactoryBase(positionsController_)
    {}

    function setAsset(uint256 positionId, uint256 assetCode) external {
        _setAsset(positionId, assetCode, createAsset());
    }

    function createAsset() internal returns (ContractData memory) {
        ContractData memory data;
        data.factory = address(this);
        data.contractAddr = address(
            new EthAsset(address(positionsController), this)
        );
        return data;
    }

    function _clone(address, address owner) internal override returns (IAsset) {
        return new EthAsset(owner, this);
    }
}

pragma solidity ^0.8.17;





contract EthAsset is AssetBase {
    constructor(address owner_, IAssetCloneFactory factory_)
        AssetBase(owner_, factory_)
    {}

    function count() external view override returns (uint256) {
        return address(this).balance;
    }

    function withdrawInternal(address recipient, uint256 amount)
        internal
        virtual
        override
    {
        payable(recipient).transfer(amount);
    }

    receive() external payable {} // for silent payable (without alerting the observer)

    function receiveWithData(uint256[] calldata data) external payable {
        listener().beforeAssetTransfer(
            address(this),
            msg.sender,
            address(this),
            msg.value,
            data
        );
        listener().afterAssetTransfer(
            address(this),
            msg.sender,
            address(this),
            msg.value,
            data
        );
    }

    function clone(address owner) external override returns (IAsset) {
        return factory.clone(address(this), owner);
    }

    function assetTypeId() external pure override returns (uint256) {
        return 1;
    }
}

pragma solidity ^0.8.17;

struct ContractData {
    address factory; // factory
    address contractAddr; // contract
}

pragma solidity ^0.8.17;



interface IPositionsController {
    
    function getFeeSettings() external view returns(IFeeSettings);

    
    function ownerOf(uint256 positionId) external view returns (address);

    
    function transferPositionOwnership(uint256 positionId, address newOwner)
        external;

    
    function getAssetPositionId(address assetAddress)
        external
        view
        returns (uint256);

    
    function getAsset(uint256 positionId, uint256 assetCode)
        external
        view
        returns (ContractData memory);

    
    function createPosition() external;

    
    
    
    
    function setAsset(
        uint256 positionId,
        uint256 assetCode,
        ContractData calldata data
    ) external;

    
    function setAlgorithm(uint256 positionId, ContractData calldata data)
        external;

    
    function getAlgorithm(uint256 positionId)
        external
        view
        returns (ContractData memory data);

    
    function disableEdit(uint256 positionId) external;

    
    function positionOfOwnerByIndex(address account, uint256 index)
        external
        view
        returns (uint256);

    
    function ownedPositionsCount(address account)
        external
        view
        returns (uint256);
}

pragma solidity ^0.8.17;
interface IEthAssetFactory {
    function setAsset(uint256 positionId, uint256 assetCode) external;
}

pragma solidity ^0.8.17;
// todo cut out
struct PositionSnapshot {
    uint256 owner;
    uint256 output;
    uint256 slippage;
}

pragma solidity ^0.8.17;


interface IPositionAlgorithm is IAssetListener {
    
    function isPositionLocked(uint256 positionId) external view returns (bool);

    
    function transferAssetOwnerShipTo(address asset, address newOwner) external;
}

pragma solidity ^0.8.17;
interface IErc721ItemAsset {
    function getContractAddress() external returns (address);

    function getTokenId() external returns (uint256);
}

pragma solidity ^0.8.17;
interface IFeeSettings {
    function feeAddress() external returns (address); // address to pay fee

    function feePercent() external returns (uint256); // fee in 1/decimals for deviding values

    function feeDecimals() external view returns(uint256); // fee decimals

    function feeEth() external returns (uint256); // fee value for not dividing deal points
}