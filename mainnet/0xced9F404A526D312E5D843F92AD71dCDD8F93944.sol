// SPDX-License-Identifier: BUSL-1.1


// 
pragma solidity ^0.8.17;

// todo cut out
struct PositionSnapshot {
    uint256 owner;
    uint256 output;
    uint256 slippage;
}

// 
pragma solidity ^0.8.17;


struct AssetTransferData {
    uint256 positionId;
    ItemRef asset;
    uint256 assetCode;
    address from;
    address to;
    uint256 count;
    uint256[] data;
}

// 
pragma solidity ^0.8.17;

interface IOwnable {
    function owner() external view returns (address);

    function transferOwnership(address newOwner) external;
}
// 
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

    function owner() external view virtual returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) external override onlyOwner {
        _owner = newOwner;
    }
}

// 
pragma solidity ^0.8.17;


struct AssetData {
    address addr; // the asset contract address
    uint256 id; // asset id or zero if asset is not exists
    uint256 assetTypeId; // 1-eth 2-erc20 3-erc721Item 4-Erc721Count
    uint256 positionId;
    uint256 positionAssetCode; // code of the asset - 1 or 2
    address owner;
    uint256 count; // current count of the asset
    address contractAddr; // contract, using in asset  or zero if ether
    uint256 value; // extended asset value (nft id for example)
}

// 
pragma solidity ^0.8.17;


struct ItemRef {
    address addr; // referenced contract address
    uint256 id; // id of the item
}

// 
pragma solidity ^0.8.17;





interface IAssetListener {
    function beforeAssetTransfer(AssetTransferData calldata arg) external;

    function afterAssetTransfer(AssetTransferData calldata arg)
        external
        payable;
}

// 
pragma solidity ^0.8.17;



interface IHasFactories is IOwnable {
    
    function isFactory(address addr) external view returns (bool);

    
    function addFactory(address factory) external;

    
    function removeFactory(address factory) external;

    
    function setFactories(address[] calldata addresses, bool isFactory_)
        external;
}
// 
pragma solidity ^0.8.17;











contract PositionsFactory is OwnableSimple {
    using ItemRefAsAssetLibrary for ItemRef;
    IPositionsController public positionsController;
    IAssetsController public ethAssetsController; // assetType 1
    IAssetsController public erc20AssetsController; // assetType 2
    IAssetsController public erc721AssetsController; // assetType 3
    IPositionAlgorithm public lockAlgorithm;
    ITradingPairAlgorithm public tradingPair;

    constructor(
        address positionsController_,
        address ethAssetsController_,
        address erc20AssetsController_,
        address erc721AssetsController_,
        address lockAlgorithm_,
        address tradingPair_
    ) OwnableSimple(msg.sender) {
        positionsController = IPositionsController(positionsController_);
        ethAssetsController = IAssetsController(ethAssetsController_);
        erc20AssetsController = IAssetsController(erc20AssetsController_);
        erc721AssetsController = IAssetsController(erc721AssetsController_);
        lockAlgorithm = IPositionAlgorithm(lockAlgorithm_);
        tradingPair = ITradingPairAlgorithm(tradingPair_);
    }

    receive() external payable {}

    function createLockPosition(
        AssetCreationData calldata data1,
        uint256 lockSeconds
    ) external payable returns (uint256 ethSurplus) {
        ethSurplus = msg.value;

        // create a position
        uint256 positionId = positionsController.createPosition(msg.sender);

        // set assets
        ethSurplus = _createAsset(positionId, 1, data1, ethSurplus);

        // set algorithm
        positionsController.setAlgorithm(positionId, address(lockAlgorithm));

        if (lockSeconds > 0)
            lockAlgorithm.lockPosition(positionId, lockSeconds);

        positionsController.stopBuild(positionId);

        // revert eth surplus
        if (ethSurplus > 0) {
            (bool surplusSent, ) = msg.sender.call{ value: ethSurplus }('');
            require(surplusSent, 'ethereum surplus is not sent');
        }
    }

    function createTradingPairPosition(
        AssetCreationData calldata data1,
        AssetCreationData calldata data2,
        FeeSettings calldata feeSettings
    ) external payable returns (uint256 ethSurplus) {
        require(
            !(data1.assetTypeCode == 1 && data2.assetTypeCode == 1),
            'can not create eth/eth trading pair'
        );

        ethSurplus = msg.value;
        // create a position
        uint256 positionId = positionsController.createPosition(msg.sender);

        // set assets
        ethSurplus = _createAsset(positionId, 1, data1, ethSurplus);
        ethSurplus = _createAsset(positionId, 2, data2, ethSurplus);

        // set algorithm
        tradingPair.createAlgorithm(positionId, feeSettings);

        positionsController.stopBuild(positionId);

        // revert eth surplus
        if (ethSurplus > 0) {
            (bool surplusSent, ) = msg.sender.call{ value: ethSurplus }('');
            require(surplusSent, 'ethereum surplus is not sent');
        }
    }

    function _createAsset(
        uint256 positionId,
        uint256 assetCode,
        AssetCreationData calldata data,
        uint256 ethSurplus
    ) internal returns (uint256) {
        IAssetsController controller;
        uint256 value;

        if (data.assetTypeCode == 1) {
            value = msg.value;
            controller = ethAssetsController;
        } else if (data.assetTypeCode == 2) {
            controller = erc20AssetsController;
        } else if (data.assetTypeCode == 3) {
            controller = erc721AssetsController;
        } else revert('unknown asset type code');

        ItemRef memory asset = positionsController.createAsset(
            positionId,
            assetCode,
            address(controller)
        );

        return
            asset.assetsController().initialize{ value: ethSurplus }(
                msg.sender,
                asset.id,
                data
            );
    }
}

// 
pragma solidity ^0.8.17;








interface IPositionsController is IHasFactories, IAssetListener {
    
    event NewPosition(
        address indexed account,
        address indexed algorithmAddress,
        uint256 positionId
    );

    
    function getFeeSettings() external view returns (IFeeSettings);

    
    
    
    /// only factory, only build mode
    function createPosition(address owner) external returns (uint256);

    
    function getPosition(uint256 positionId)
        external
        view
        returns (
            address algorithm,
            AssetData memory asset1,
            AssetData memory asset2
        );

    
    function positionsCount() external returns (uint256);

    
    function ownerOf(uint256 positionId) external view returns (address);

    
    function getAsset(uint256 positionId, uint256 assetCode)
        external
        view
        returns (AssetData memory data);

    
    function getAllPositionAssetReferences(uint256 positionId)
        external
        view
        returns (ItemRef memory position1, ItemRef memory position2);

    
    function getAssetReference(uint256 positionId, uint256 assetCode)
        external
        view
        returns (ItemRef memory);

    
    function getAssetPositionId(uint256 assetId)
        external
        view
        returns (uint256);

    
    
    
    
    /// only factories, only build mode
    function createAsset(
        uint256 positionId,
        uint256 assetCode,
        address assetsController
    ) external returns (ItemRef memory);

    
    /// id of algorithm is id of the position
    /// only factory, only build mode
    function setAlgorithm(uint256 positionId, address algorithmController)
        external;

    
    function getAlgorithm(uint256 positionId) external view returns (address);

    
    function isBuildMode(uint256 positionId) external view returns (bool);

    
    /// onlyFactories, onlyBuildMode
    function stopBuild(uint256 positionId) external;

    
    function assetsCount() external view returns (uint256);

    
    /// only factories
    function createNewAssetId() external returns (uint256);

    
    function transferToAsset(
        uint256 positionId,
        uint256 assetCode,
        uint256 count,
        uint256[] calldata data
    ) external payable returns (uint256 ethSurplus);

    
    
    /// onlyFactory
    function transferToAssetFrom(
        address from,
        uint256 positionId,
        uint256 assetCode,
        uint256 count,
        uint256[] calldata data
    ) external payable returns (uint256 ethSurplus);

    
    /// only position owner
    function withdraw(
        uint256 positionId,
        uint256 assetCode,
        uint256 count
    ) external;

    
    /// only position owner
    function withdrawTo(
        uint256 positionId,
        uint256 assetCode,
        address to,
        uint256 count
    ) external;

    
    /// oplyPositionAlgorithm
    function withdrawInternal(
        ItemRef calldata asset,
        address to,
        uint256 count
    ) external;

    
    /// oplyPositionAlgorithm
    function transferToAnotherAssetInternal(
        ItemRef calldata from,
        ItemRef calldata to,
        uint256 count
    ) external;

    
    function count(ItemRef calldata asset) external view returns (uint256);

    
    /// usefull for get snapshot for same algotithms
    function getCounts(uint256 positionId)
        external
        view
        returns (uint256, uint256);

    
    function positionLocked(uint256 positionId) external view returns (bool);
}

// 
pragma solidity ^0.8.17;







interface IAssetsController {
    
    /// onlyBuildMode
    function initialize(
        address from,
        uint256 assetId,
        AssetCreationData calldata data
    ) external payable returns (uint256 ethSurplus);

    
    function algorithm(uint256 assetId) external view returns (address);

    
    function positionsController() external view returns (address);

    
    
    function assetTypeId() external pure returns (uint256);

    
    function getPositionId(uint256 assetId) external view returns (uint256);

    
    function getAlgorithm(uint256 assetId)
        external
        view
        returns (address algorithm);

    
    function getCode(uint256 assetId) external view returns (uint256);

    
    function count(uint256 assetId) external view returns (uint256);

    
    function value(uint256 assetId) external view returns (uint256);

    
    function contractAddr(uint256 assetId) external view returns (address);

    
    function getData(uint256 assetId) external view returns (AssetData memory);

    
    
    
    /// onlyPositionsController or algorithm
    function withdraw(
        uint256 assetId,
        address recepient,
        uint256 count
    ) external;

    
    /// onlyPositionsController
    function addCount(uint256 assetId, uint256 count) external;

    
    /// onlyPositionsController
    function removeCount(uint256 assetId, uint256 count) external;

    
    
    /// onlyPositionsController
    function transferToAsset(AssetTransferData calldata arg)
        external
        payable
        returns (uint256 ethSurplus);

    
    
    function clone(uint256 assetId, address owner)
        external
        returns (ItemRef memory);

    
    function owner(uint256 assetId) external view returns (address);

    
    function isNotifyListener(uint256 assetId) external view returns (bool);

    
    /// only factories
    function setNotifyListener(uint256 assetId, bool value) external;
}

// 
pragma solidity ^0.8.17;


struct ContractData {
    address factory; // factory
    address contractAddr; // contract
}

// 
pragma solidity ^0.8.17;



interface IPositionAlgorithm is IAssetListener {
    
    function checkCanWithdraw(
        ItemRef calldata asset,
        uint256 assetCode,
        uint256 count
    ) external view;

    
    function positionLocked(uint256 positionId) external view returns (bool);

    
    /// only position owner
    function lockPosition(uint256 positionId, uint256 lockSeconds) external;
}

// 
pragma solidity ^0.8.17;




interface ITradingPairAlgorithm {
    
    event OnSwap(
        uint256 indexed positionId,
        address indexed account,
        uint256 inputAssetId,
        uint256 outputAssetId,
        uint256 inputCount,
        uint256 outputCount
    );

    
    event OnAddLiquidity(
        uint256 indexed positionId,
        address indexed account,
        uint256 asset1Count,
        uint256 asset2Count,
        uint256 liquidityTokensCount
    );

    
    event OnRemoveLiquidity(
        uint256 indexed positionId,
        address indexed account,
        uint256 asset1Count,
        uint256 asset2Count,
        uint256 liquidityTokensCount
    );

    
    event OnClaimFeeReward(
        uint256 indexed positionId,
        address indexed account,
        uint256 asset1Count,
        uint256 asset2Count,
        uint256 feeTokensCount
    );

    
    /// onlyFactory
    function createAlgorithm(
        uint256 positionId,
        FeeSettings calldata feeSettings
    ) external;

    
    function getPositionsController() external view returns (address);

    
    function getLiquidityToken(uint256 positionId)
        external
        view
        returns (address);

    
    function getFeeToken(uint256 positionId) external view returns (address);

    
    function getFeeSettings(uint256 positionId)
        external
        view
        returns (FeeSettings memory);

    
    function getFeeDistributer(uint256 positionId)
        external
        view
        returns (address);

    
    function withdraw(uint256 positionId, uint256 liquidityCount) external;

    
    
    
    
    function addLiquidity(
        uint256 position,
        uint256 assetCode,
        uint256 count
    ) external payable returns (uint256 ethSurplus);

    
    
    
    function getSnapshot(uint256 positionId, uint256 slippage)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    
    /// only for fee distributers
    function ClaimFeeReward(
        uint256 positionId,
        address account,
        uint256 asset1Count,
        uint256 asset2Count,
        uint256 feeTokensCount
    ) external;
}

// 
pragma solidity ^0.8.17;

struct AssetFee {
    uint256 input; // position entry fee 1/10000
    uint256 output; // position exit fee 1/10000
}

struct FeeSettings {
    uint256 feeRoundIntervalHours;
    AssetFee asset1;
    AssetFee asset2;
}

// 
pragma solidity ^0.8.17;


struct AssetCreationData {
    
    /// 0 - asset is missing
    /// 1 - EthAsset
    /// 2 - Erc20Asset
    /// 3 - Erc721ItemAsset
    uint256 assetTypeCode;
    address contractAddress;
    
    uint256 value;
}

// 
pragma solidity ^0.8.17;





library ItemRefAsAssetLibrary {
    function assetsController(ItemRef memory ref)
        internal
        pure
        returns (IAssetsController)
    {
        return IAssetsController(ref.addr);
    }

    function assetTypeId(ItemRef memory ref) internal pure returns (uint256) {
        return assetsController(ref).assetTypeId();
    }

    function count(ItemRef memory ref) internal view returns (uint256) {
        return assetsController(ref).count(ref.id);
    }

    function addCount(ItemRef memory ref, uint256 countToAdd) internal {
        assetsController(ref).addCount(ref.id, countToAdd);
    }

    function removeCount(ItemRef memory ref, uint256 countToRemove) internal {
        assetsController(ref).removeCount(ref.id, countToRemove);
    }

    function withdraw(
        ItemRef memory ref,
        address recepient,
        uint256 cnt
    ) internal {
        assetsController(ref).withdraw(ref.id, recepient, cnt);
    }

    function getPositionId(ItemRef memory ref) internal view returns (uint256) {
        return assetsController(ref).getPositionId(ref.id);
    }

    function clone(ItemRef memory ref, address owner)
        internal
        returns (ItemRef memory)
    {
        return assetsController(ref).clone(ref.id, owner);
    }

    function setNotifyListener(ItemRef memory ref, bool value) internal {
        assetsController(ref).setNotifyListener(ref.id, value);
    }

    function initialize(
        ItemRef memory ref,
        address from,
        AssetCreationData calldata data
    ) internal {
        assetsController(ref).initialize(from, ref.id, data);
    }

    function getData(ItemRef memory ref)
        internal
        view
        returns (AssetData memory data)
    {
        return assetsController(ref).getData(ref.id);
    }

    function getCode(ItemRef memory ref) internal view returns (uint256) {
        return assetsController(ref).getCode(ref.id);
    }

    function contractAddr(ItemRef memory ref)
        internal
        view
        returns (address)
    {
        return assetsController(ref).contractAddr(ref.id);
    }
}

// 
pragma solidity ^0.8.17;

interface IFeeSettings {
    function feeAddress() external returns (address); // address to pay fee

    function feePercent() external returns (uint256); // fee in 1/decimals for deviding values

    function feeDecimals() external view returns(uint256); // fee decimals

    function feeEth() external returns (uint256); // fee value for not dividing deal points
}
