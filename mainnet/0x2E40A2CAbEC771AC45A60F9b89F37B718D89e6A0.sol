// SPDX-License-Identifier: BUSL-1.1


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

// todo cut out
struct PositionSnapshot {
    uint256 owner;
    uint256 output;
    uint256 slippage;
}

// 
pragma solidity ^0.8.17;

interface IOwnable {
    function owner() external view returns (address);

    function transferOwnership(address newOwner) external;
}

// 
pragma solidity ^0.8.17;




abstract contract AssetsControllerBase is IAssetsController {
    IPositionsController immutable _positionsController;
    mapping(uint256 => bool) _suppressNotifyListener;
    mapping(uint256 => uint256) _counts;
    mapping(uint256 => address) _algorithms;

    constructor(address positionsController_) {
        _positionsController = IPositionsController(positionsController_);
    }

    modifier onlyOwner(uint256 assetId) {
        require(this.owner(assetId) == msg.sender, 'only for asset owner');
        _;
    }

    modifier onlyFactory() {
        require(
            _positionsController.isFactory(msg.sender),
            'only for factories'
        );
        _;
    }

    modifier onlyBuildMode(uint256 assetId) {
        require(
            _positionsController.isBuildMode(
                _positionsController.getAssetPositionId(assetId)
            ),
            'only for factories'
        );
        _;
    }

    modifier onlyPositionsController() {
        require(
            msg.sender == address(_positionsController),
            'only for positions controller'
        );
        _;
    }

    function algorithm(uint256 assetId) external view returns (address) {
        return _algorithms[assetId];
    }

    function positionsController() external view returns (address) {
        return address(_positionsController);
    }

    function getPositionId(uint256 assetId) external view returns (uint256) {
        return _positionsController.getAssetPositionId(assetId);
    }

    function getAlgorithm(uint256 assetId)
        external
        view
        returns (address algorithm)
    {
        return _positionsController.getAlgorithm(this.getPositionId(assetId));
    }

    function owner(uint256 assetId) external view returns (address) {
        return
            _positionsController.ownerOf(
                _positionsController.getAssetPositionId(assetId)
            );
    }

    function isNotifyListener(uint256 assetId) external view returns (bool) {
        return !_suppressNotifyListener[assetId];
    }

    function setNotifyListener(uint256 assetId, bool value)
        external
        onlyFactory
    {
        _suppressNotifyListener[assetId] = !value;
    }

    function transferToAsset(AssetTransferData calldata arg)
        external
        payable
        onlyPositionsController
        returns (uint256 ethSurplus)
    {
        if (!_suppressNotifyListener[arg.asset.id])
            _positionsController.beforeAssetTransfer(arg);
        AssetTransferData memory argNew = arg;
        (uint256 countTransferred, uint256 ethConsumed) = _transferToAsset(
            arg.asset.id,
            arg.from,
            arg.count
        );
        argNew.count = countTransferred;
        if (!_suppressNotifyListener[arg.asset.id])
            _positionsController.afterAssetTransfer(arg);
        // revert surplus
        ethSurplus = msg.value - ethConsumed;
        if (ethSurplus > 0) {
            (bool surplusSent, ) = msg.sender.call{ value: ethSurplus }('');
            require(surplusSent, 'ethereum surplus is not sent');
        }
    }

    function addCount(uint256 assetId, uint256 count)
        external
        onlyPositionsController
    {
        _counts[assetId] += count;
    }

    function removeCount(uint256 assetId, uint256 count)
        external
        onlyPositionsController
    {
        _counts[assetId] -= count;
    }

    function withdraw(
        uint256 assetId,
        address recepient,
        uint256 count
    ) external {
        require(_counts[assetId] >= count, 'not enough asset balance');
        require(
            msg.sender == address(_positionsController) ||
                msg.sender == _algorithms[assetId],
            'only for positions controller or algorithm'
        );

        _withdraw(assetId, recepient, count);
        _counts[assetId] -= count;
    }

    function _withdraw(
        uint256 assetId,
        address recepient,
        uint256 count
    ) internal virtual;

    function count(uint256 assetId) external view returns (uint256) {
        return _counts[assetId];
    }

    function _transferToAsset(
        uint256 assetId,
        address from,
        uint256 count
    ) internal virtual returns (uint256 countTransferred, uint256 ethConsumed);

    function getData(uint256 assetId)
        external
        view
        returns (AssetData memory data)
    {
        uint256 positionId = this.getPositionId(assetId);
        AssetData memory data = AssetData(
            address(this),
            assetId,
            this.assetTypeId(),
            positionId,
            _getCode(positionId, assetId),
            this.owner(assetId),
            this.count(assetId),
            this.contractAddr(assetId),
            this.value(assetId)
        );
        return data;
    }

    function getCode(uint256 assetId) external view returns (uint256) {
        return _getCode(this.getPositionId(assetId), assetId);
    }

    function _getCode(uint256 positionId, uint256 assetId)
        private
        view
        returns (uint256)
    {
        (
            ItemRef memory position1,
            ItemRef memory position2
        ) = _positionsController.getAllPositionAssetReferences(positionId);

        if (position1.id == assetId) return 1;
        if (position2.id == assetId) return 2;
        return 0;
    }
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// 
pragma solidity ^0.8.17;




struct Erc721AssetData {
    IERC721 erc721;
    uint256 tokenId;
}

contract Erc721ItemAssetsController is AssetsControllerBase {
    mapping(uint256 => Erc721AssetData) _data;

    constructor(address positionsController)
        AssetsControllerBase(positionsController)
    {}

    function assetTypeId() external pure returns (uint256) {
        return 3;
    }

    function initialize(
        address from,
        uint256 assetId,
        AssetCreationData calldata data
    ) external payable onlyBuildMode(assetId) returns (uint256 ethSurplus) {
        ethSurplus = msg.value;
        _data[assetId] = Erc721AssetData(
            IERC721(data.contractAddress),
            data.value
        );
        if (data.value > 0) _transferToAsset(assetId, from, data.value);

        // revert eth surplus
        if (ethSurplus > 0) {
            (bool surplusSent, ) = msg.sender.call{ value: ethSurplus }('');
            require(surplusSent, 'ethereum surplus is not sent');
        }
    }

    function value(uint256 assetId) external view returns (uint256) {
        return _data[assetId].tokenId;
    }

    function contractAddr(uint256 assetId) external view returns (address) {
        return address(_data[assetId].erc721);
    }

    function clone(uint256 assetId, address owner)
        external
        returns (ItemRef memory)
    {
        ItemRef memory newAsset = ItemRef(
            address(this),
            _positionsController.createNewAssetId()
        );
        _data[newAsset.id] = _data[assetId];
        _algorithms[newAsset.id] = owner;
        return newAsset;
    }

    function _withdraw(
        uint256 assetId,
        address recepient,
        uint256 count
    ) internal override {
        _data[assetId].erc721.transferFrom(
            address(this),
            recepient,
            _data[assetId].tokenId
        );
    }

    function _transferToAsset(
        uint256 assetId,
        address from,
        uint256 count
    )
        internal
        override
        returns (uint256 countTransferred, uint256 ethConsumed)
    {
        ethConsumed = 0;
        _data[assetId].erc721.transferFrom(
            from,
            address(this),
            _data[assetId].tokenId
        );
        _counts[assetId] = 1;
        countTransferred = 1;
    }
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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


struct ContractData {
    address factory; // factory
    address contractAddr; // contract
}

// 
pragma solidity ^0.8.17;

interface IFeeSettings {
    function feeAddress() external returns (address); // address to pay fee

    function feePercent() external returns (uint256); // fee in 1/decimals for deviding values

    function feeDecimals() external view returns(uint256); // fee decimals

    function feeEth() external returns (uint256); // fee value for not dividing deal points
}
