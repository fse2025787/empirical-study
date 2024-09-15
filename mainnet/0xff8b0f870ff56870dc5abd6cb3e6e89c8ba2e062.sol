// SPDX-License-Identifier: MIT


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
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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
pragma solidity ^0.8.4;




interface IERC1967Upgrade {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    
    event Upgraded(address impl);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    
    error INVALID_UPGRADE(address impl);

    
    error UNSUPPORTED_UUID();

    
    error ONLY_UUPS();
}

// 
pragma solidity 0.8.15;

/**
 * Curator interfaces
 */
interface ICurator {
    
    function CURATION_TYPE_GENERIC() external view returns (uint16);
    
    function CURATION_TYPE_NFT_CONTRACT() external view returns (uint16);
    
    function CURATION_TYPE_CONTRACT() external view returns (uint16);
    
    function CURATION_TYPE_CURATION_CONTRACT() external view returns (uint16);
    
    function CURATION_TYPE_NFT_ITEM() external view returns (uint16);
    
    function CURATION_TYPE_WALLET() external view returns (uint16);
    
    function CURATION_TYPE_ZORA_EDITION() external view returns (uint16);

    
    struct Listing {
        
        address curatedAddress;
        
        uint96 selectedTokenId;
        
        address curator;
        
        uint16 curationTargetType;
        
        int32 sortOrder;
        
        bool hasTokenId;
        
        uint16 chainId;
    }

    
    function getListing(uint256 listingIndex) external view returns (Listing memory);

    
    function getListings() external view returns (Listing[] memory activeListings);

    
    function totalSupply() external view returns (uint256);

    
    function removeListings(uint256[] calldata listingIds) external;

    
    function burn(uint256 listingId) external;

    
    event ListingAdded(address indexed curator, Listing listing);

    
    event ListingRemoved(address indexed curator, Listing listing);

    
    
    event TokenPassUpdated(address indexed owner, address tokenPass);

    
    event SetRenderer(address);

    
    event CurationPauseUpdated(address indexed owner, bool isPaused);

    
    event UpdatedCurationLimit(uint256 newLimit);

    
    event UpdatedSortOrder(uint256[] ids, int32[] sorts, address updatedBy);

    
    event ScheduledFreeze(uint256 timestamp);

    
    error PASS_REQUIRED();

    
    error ONLY_CURATOR();

    
    error WRONG_CURATOR_FOR_LISTING(address setCurator, address expectedCurator);

    
    error CURATION_PAUSED();

    
    error CANNOT_SET_SAME_PAUSED_STATE();

    
    error CURATION_FROZEN();

    
    error TOO_MANY_ENTRIES();

    
    error ACCESS_NOT_ALLOWED();

    
    error TOKEN_HAS_NO_OWNER();

    
    error INVALID_INPUT_LENGTH();

    
    error CANNOT_UPDATE_CURATION_LIMIT_DOWN();

    function initialize(
        address _owner,
        string memory _name,
        string memory _symbol,
        address _tokenPass,
        bool _pause,
        uint256 _curationLimit,
        address _renderer,
        bytes memory _rendererInitializer,
        Listing[] memory _initialListings
    ) external;
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// 
pragma solidity ^0.8.4;




interface IInitializable {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    event Initialized(uint256 version);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error ADDRESS_ZERO();

    
    error INITIALIZING();

    
    error NOT_INITIALIZING();

    
    error ALREADY_INITIALIZED();
}

// 
pragma solidity ^0.8.15;







interface IUUPS is IERC1967Upgrade, IERC1822Proxiable {
    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error ONLY_CALL();

    
    error ONLY_DELEGATECALL();

    
    error ONLY_PROXY();

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    function upgradeTo(address newImpl) external;

    
    
    
    function upgradeToAndCall(address newImpl, bytes memory data) external payable;
}

// 
pragma solidity ^0.8.4;










/// - Uses custom errors declared in IERC1967Upgrade
/// - Removes ERC1967 admin and beacon support
abstract contract ERC1967Upgrade is IERC1967Upgrade {
    ///                                                          ///
    ///                          CONSTANTS                       ///
    ///                                                          ///

    
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    ///                                                          ///
    ///                          FUNCTIONS                       ///
    ///                                                          ///

    
    
    
    function _upgradeToAndCallUUPS(
        address _newImpl,
        bytes memory _data,
        bool _forceCall
    ) internal {
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(_newImpl);
        } else {
            try IERC1822Proxiable(_newImpl).proxiableUUID() returns (bytes32 slot) {
                if (slot != _IMPLEMENTATION_SLOT) revert UNSUPPORTED_UUID();
            } catch {
                revert ONLY_UUPS();
            }

            _upgradeToAndCall(_newImpl, _data, _forceCall);
        }
    }

    
    
    
    function _upgradeToAndCall(
        address _newImpl,
        bytes memory _data,
        bool _forceCall
    ) internal {
        _upgradeTo(_newImpl);

        if (_data.length > 0 || _forceCall) {
            Address.functionDelegateCall(_newImpl, _data);
        }
    }

    
    
    function _upgradeTo(address _newImpl) internal {
        _setImplementation(_newImpl);

        emit Upgraded(_newImpl);
    }

    
    
    function _setImplementation(address _impl) private {
        if (!Address.isContract(_impl)) revert INVALID_UPGRADE(_impl);

        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = _impl;
    }

    
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }
}

// 
pragma solidity ^0.8.4;




interface IOwnable {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    
    
    event OwnerUpdated(address indexed prevOwner, address indexed newOwner);

    
    
    
    event OwnerPending(address indexed owner, address indexed pendingOwner);

    
    
    
    event OwnerCanceled(address indexed owner, address indexed canceledOwner);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error ONLY_OWNER();

    
    error ONLY_PENDING_OWNER();

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    function owner() external view returns (address);

    
    function pendingOwner() external view returns (address);

    
    
    function transferOwnership(address newOwner) external;

    
    
    function safeTransferOwnership(address newOwner) external;

    
    function acceptOwnership() external;

    
    function cancelOwnershipTransfer() external;
}

// 
pragma solidity ^0.8.4;







/// - Uses custom errors declared in IInitializable
abstract contract Initializable is IInitializable {
    ///                                                          ///
    ///                           STORAGE                        ///
    ///                                                          ///

    
    uint8 internal _initialized;

    
    bool internal _initializing;

    ///                                                          ///
    ///                          MODIFIERS                       ///
    ///                                                          ///

    
    modifier onlyInitializing() {
        if (!_initializing) revert NOT_INITIALIZING();
        _;
    }

    
    modifier initializer() {
        bool isTopLevelCall = !_initializing;

        if ((!isTopLevelCall || _initialized != 0) && (Address.isContract(address(this)) || _initialized != 1)) revert ALREADY_INITIALIZED();

        _initialized = 1;

        if (isTopLevelCall) {
            _initializing = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;

            emit Initialized(1);
        }
    }

    
    
    modifier reinitializer(uint8 _version) {
        if (_initializing || _initialized >= _version) revert ALREADY_INITIALIZED();

        _initialized = _version;

        _initializing = true;

        _;

        _initializing = false;

        emit Initialized(_version);
    }

    ///                                                          ///
    ///                          FUNCTIONS                       ///
    ///                                                          ///

    
    function _disableInitializers() internal virtual {
        if (_initializing) revert INITIALIZING();

        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;

            emit Initialized(type(uint8).max);
        }
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// 
pragma solidity ^0.8.0;

interface IERC5192 {
  
  
  
  event Locked(uint256 tokenId);

  
  
  
  event Unlocked(uint256 tokenId);

  
  
  /// about them do throw.
  
  function locked(uint256 tokenId) external view returns (bool);
}// 
pragma solidity 0.8.15;








/**
 * @notice Storage contracts
 */
abstract contract CuratorFactoryStorageV1 {
    address public defaultMetadataRenderer;

    mapping(address => mapping(address => bool)) internal isUpgrade;

    uint256[50] __gap;
}

// 
pragma solidity ^0.8.4;







/// - Uses custom errors declared in IUUPS
/// - Inherits a modern, minimal ERC1967Upgrade
abstract contract UUPS is IUUPS, ERC1967Upgrade {
    ///                                                          ///
    ///                          IMMUTABLES                      ///
    ///                                                          ///

    
    address private immutable __self = address(this);

    ///                                                          ///
    ///                           MODIFIERS                      ///
    ///                                                          ///

    
    modifier onlyProxy() {
        if (address(this) == __self) revert ONLY_DELEGATECALL();
        if (_getImplementation() != __self) revert ONLY_PROXY();
        _;
    }

    
    modifier notDelegated() {
        if (address(this) != __self) revert ONLY_CALL();
        _;
    }

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    function _authorizeUpgrade(address _newImpl) internal virtual;

    
    
    function upgradeTo(address _newImpl) external onlyProxy {
        _authorizeUpgrade(_newImpl);
        _upgradeToAndCallUUPS(_newImpl, "", false);
    }

    
    
    
    function upgradeToAndCall(address _newImpl, bytes memory _data) external payable onlyProxy {
        _authorizeUpgrade(_newImpl);
        _upgradeToAndCallUUPS(_newImpl, _data, true);
    }

    
    function proxiableUUID() external view notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }
}

// 
pragma solidity ^0.8.4;







/// - Uses custom errors declared in IOwnable
/// - Adds optional two-step ownership transfer (`safeTransferOwnership` + `acceptOwnership`)
abstract contract Ownable is IOwnable, Initializable {
    ///                                                          ///
    ///                            STORAGE                       ///
    ///                                                          ///

    
    address internal _owner;

    
    address internal _pendingOwner;

    ///                                                          ///
    ///                           MODIFIERS                      ///
    ///                                                          ///

    
    modifier onlyOwner() {
        if (msg.sender != _owner) revert ONLY_OWNER();
        _;
    }

    
    modifier onlyPendingOwner() {
        if (msg.sender != _pendingOwner) revert ONLY_PENDING_OWNER();
        _;
    }

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    function __Ownable_init(address _initialOwner) internal onlyInitializing {
        _owner = _initialOwner;

        emit OwnerUpdated(address(0), _initialOwner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    
    
    function transferOwnership(address _newOwner) public onlyOwner {
        emit OwnerUpdated(_owner, _newOwner);

        _owner = _newOwner;
    }

    
    
    function safeTransferOwnership(address _newOwner) public onlyOwner {
        _pendingOwner = _newOwner;

        emit OwnerPending(_owner, _newOwner);
    }

    
    function acceptOwnership() public onlyPendingOwner {
        emit OwnerUpdated(_owner, msg.sender);

        _owner = _pendingOwner;

        delete _pendingOwner;
    }

    
    function cancelOwnershipTransfer() public onlyOwner {
        emit OwnerCanceled(_owner, _pendingOwner);

        delete _pendingOwner;
    }
}

// 
pragma solidity 0.8.15;

/**
 * @notice Curator factory allows deploying and setting up new curators
 * @author [email protected]
 */
interface ICuratorFactory {
    
    event CuratorDeployed(address curator, address owner, address deployer);
    
    event RegisteredUpgradePath(address implFrom, address implTo);
    
    event HasNewMetadataRenderer(address);

    
    function isValidUpgrade(address baseImpl, address newImpl) external view returns (bool);
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

// 
pragma solidity ^0.8.10;










abstract contract CuratorSkeletonNFT is
    IERC165Upgradeable,
    IERC721Upgradeable,
    IERC721MetadataUpgradeable,
    IERC5192
{
    
    modifier notSupported() {
        revert("Fn not supported: nontransferrable NFT");
        _;
    }

    /**
        Common NFT functions
     */

    
    function name() virtual external view returns (string memory);

    
    function symbol() virtual external view returns (string memory);

    /*
     *  EIP-5192 Functions
     */
    function locked(uint256) external pure returns (bool) {
      return true;
    }


    /*
     *  NFT Functions
     */

    
    function balanceOf(address user) public virtual view returns (uint256);

    
    function ownerOf(uint256 id) public virtual view returns (address);

    
    function getApproved(uint256) public pure returns (address) {
        return address(0x0);
    }

    
    function tokenURI(uint256 tokenId) external virtual view returns (string memory);

    
    function contractURI() external virtual view returns (string memory);

    
    function isApprovedForAll(address, address) public pure returns (bool) {
        return false;
    }

    
    function approve(address, uint256) public notSupported {}

    
    function setApprovalForAll(address, bool) public notSupported {}

    
    function _mint(address to, uint256 id) internal {
        require(
            to != address(0x0),
            "Mint: cannot mint to 0x0"
        );
        emit Locked(id);
        _transferFrom(address(0x0), to, id);
    }

    
    function _burn(uint256 id) internal {
      _transferFrom(ownerOf(id), address(0x0), id);
    }

    
    function transferFrom(
        address from,
        address to,
        uint256 checkTokenId
    ) external virtual {}

    
    function safeTransferFrom(
        address,
        address,
        uint256
    ) public notSupported {
        // no impl
    }

    
    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes memory
    ) public notSupported {
        // no impl
    }

    
    
    
    
    
    function _transferFrom(
        address from,
        address to,
        uint256 id
    ) internal {
        emit Transfer(from, to, id);
    }

    
    function totalSupply() public virtual view returns (uint256);

    
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC165Upgradeable).interfaceId ||
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            interfaceId == type(IERC5192).interfaceId;
    }

    
    function _exists(uint256 id) internal virtual view returns (bool);
}

// 
pragma solidity 0.8.15;






/**
 @notice Curator storage variables contract.
 @author [email protected]
 */
abstract contract CuratorStorageV1 is ICurator {
    
    string internal contractName;

    
    string internal contractSymbol;

    /// Curation pass as an ERC721 that allows other users to curate.
    
    IERC721Upgradeable public curationPass;

    /// Stores virtual mapping array length parameters
    
    uint40 public numAdded;

    
    
    uint40 public numRemoved;

    
    bool public isPaused;

    
    uint256 public frozenAt;

    
    uint256 public curationLimit;

    
    IMetadataRenderer public renderer;

    
    
    mapping(uint256 => Listing) public idToListing;

    
    uint256[49] __gap;
}

/**
 * @notice Base contract for curation functioanlity. Inherits ERC721 standard from CuratorSkeletonNFT.sol
 *      (curation information minted as non-transferable "listingRecords" to curators to allow for easy integration with NFT indexers)
 * @dev For curation contracts: assumes 1. linear mint order
 * @author [email protected]
 *
 */
contract CuratorFactory is ICuratorFactory, UUPS, Ownable, CuratorFactoryStorageV1 {
    address public immutable curatorImpl;
    bytes32 public immutable curatorHash;

    constructor(address _curatorImpl) payable initializer {
        curatorImpl = _curatorImpl;
        curatorHash = keccak256(abi.encodePacked(type(ERC1967Proxy).creationCode, abi.encode(_curatorImpl, "")));
    }

    function setDefaultMetadataRenderer(address _renderer) external {
        defaultMetadataRenderer = _renderer;

        emit HasNewMetadataRenderer(_renderer);
    }

    function initialize(address _owner, address _defaultMetadataRenderer) external initializer {
        __Ownable_init(_owner);
        defaultMetadataRenderer = _defaultMetadataRenderer;
    }

    function deploy(
        address curationManager,
        string memory name,
        string memory symbol,
        address tokenPass,
        bool initialPause,
        uint256 curationLimit,
        address renderer,
        bytes memory rendererInitializer,
        ICurator.Listing[] memory listings
    ) external returns (address curator) {
        if (renderer == address(0)) {
            renderer = defaultMetadataRenderer;
        }

        curator = address(
            new ERC1967Proxy(
                curatorImpl,
                abi.encodeWithSelector(
                    ICurator.initialize.selector,
                    curationManager,
                    name,
                    symbol,
                    tokenPass,
                    initialPause,
                    curationLimit,
                    renderer,
                    rendererInitializer,
                    listings
                )
            )
        );

        emit CuratorDeployed(curator, curationManager, msg.sender);
    }

    function isValidUpgrade(address _baseImpl, address _newImpl) external view returns (bool) {
        return isUpgrade[_baseImpl][_newImpl];
    }

    function addValidUpgradePath(address _baseImpl, address _newImpl) external onlyOwner {
        isUpgrade[_baseImpl][_newImpl] = true;
        emit RegisteredUpgradePath(_baseImpl, _newImpl);
    }

    function _authorizeUpgrade(address _newImpl) internal override onlyOwner {}
}

// 
pragma solidity ^0.8.4;









/// - Inherits a modern, minimal ERC1967Upgrade
contract ERC1967Proxy is IERC1967Upgrade, Proxy, ERC1967Upgrade {
    ///                                                          ///
    ///                         CONSTRUCTOR                      ///
    ///                                                          ///

    
    
    
    constructor(address _logic, bytes memory _data) payable {
        _upgradeToAndCall(_logic, _data, false);
    }

    ///                                                          ///
    ///                          FUNCTIONS                       ///
    ///                                                          ///

    
    function _implementation() internal view virtual override returns (address) {
        return ERC1967Upgrade._getImplementation();
    }
}

// 
pragma solidity 0.8.15;










/**
 * @notice Base contract for curation functioanlity. Inherits ERC721 standard from CuratorSkeletonNFT.sol
 *      (curation information minted as non-transferable "listingRecords" to curators to allow for easy integration with NFT indexers)
 * @dev For curation contracts: assumes 1. linear mint order
 * @author [email protected]
 *
 */

contract Curator is 
    ICurator, 
    UUPS, 
    Ownable, 
    CuratorStorageV1, 
    CuratorSkeletonNFT 
{
    // Public constants for curation types.
    // Allows for adding new types later easily compared to a enum.
    uint16 public constant CURATION_TYPE_GENERIC = 0;
    uint16 public constant CURATION_TYPE_NFT_CONTRACT = 1;
    uint16 public constant CURATION_TYPE_CURATION_CONTRACT = 2;
    uint16 public constant CURATION_TYPE_CONTRACT = 3;
    uint16 public constant CURATION_TYPE_NFT_ITEM = 4;
    uint16 public constant CURATION_TYPE_WALLET = 5;
    uint16 public constant CURATION_TYPE_ZORA_EDITION = 6;

    
    ICuratorFactory private immutable curatorFactory;

    
    modifier onlyActive() {
        if (isPaused && msg.sender != owner()) {
            revert CURATION_PAUSED();
        }

        if (frozenAt != 0 && frozenAt < block.timestamp) {
            revert CURATION_FROZEN();
        }

        _;
    }

    
    
    modifier onlyCuratorOrAdmin(uint256 listingId) {
        if (owner() != msg.sender || idToListing[listingId].curator != msg.sender) {
            revert ACCESS_NOT_ALLOWED();
        }

        _;
    }

    
    
    constructor(address _curatorFactory) payable initializer {
        curatorFactory = ICuratorFactory(_curatorFactory);
    }


    
    
    
    
    
    
    
    
    
    
    function initialize(
        address _owner,
        string memory _name,
        string memory _symbol,
        address _curationPass,
        bool _pause,
        uint256 _curationLimit,
        address _renderer,
        bytes memory _rendererInitializer,
        Listing[] memory _initialListings
    ) external initializer {
        // Setup owner role
        __Ownable_init(_owner);
        // Setup contract name + symbol
        contractName = _name;
        contractSymbol = _symbol;
        // Setup curation pass. MUST be set to a valid ERC721 address
        curationPass = IERC721Upgradeable(_curationPass);
        // Setup metadata renderer
        _updateRenderer(IMetadataRenderer(_renderer), _rendererInitializer);
        // Setup initial curation active state
        if (_pause) {
            _setCurationPaused(_pause);
        }
        // Setup intial curation limit
        if (_curationLimit != 0) {
            _updateCurationLimit(_curationLimit);
        }
        // Setup initial listings to curate
        if (_initialListings.length != 0) {
            _addListings(_initialListings, _owner);
        }
    }

    
    
    function getListing(uint256 index) external view override returns (Listing memory) {
        ownerOf(index);
        return idToListing[index];
    }

    
    function getListings() external view override returns (Listing[] memory activeListings) {
        unchecked {
            activeListings = new Listing[](numAdded - numRemoved);

            uint256 activeIndex;

            for (uint256 i; i < numAdded; ++i) {
                if (idToListing[i].curator == address(0)) {
                    continue;
                }

                activeListings[activeIndex] = idToListing[i];
                ++activeIndex;
            }
        }
    }

    /**
     *** ---------------------------------- ***
     ***                                    ***
     ***          ADMIN FUNCTIONS           ***
     ***                                    ***
     *** ---------------------------------- ***
     ***/

    
    
    function updateCurationLimit(uint256 newLimit) external onlyOwner {
        _updateCurationLimit(newLimit);
    }

    function _updateCurationLimit(uint256 newLimit) internal {

        // Prevents owner from updating curationLimit below current number of active Listings
        if (curationLimit < newLimit && curationLimit != 0) {
            revert CANNOT_UPDATE_CURATION_LIMIT_DOWN();
        }
        curationLimit = newLimit;
        emit UpdatedCurationLimit(newLimit);
    }

    
    
    function freezeAt(uint256 timestamp) external onlyOwner {

        // Prevents owner from adjusting freezeAt time if contract alrady frozen
        if (frozenAt != 0 && frozenAt < block.timestamp) {
            revert CURATION_FROZEN();
        }
        frozenAt = timestamp;
        emit ScheduledFreeze(frozenAt);
    }

    
    
    
    function updateRenderer(address _newRenderer, bytes memory _rendererInitializer) external onlyOwner {
        _updateRenderer(IMetadataRenderer(_newRenderer), _rendererInitializer);
    }

    function _updateRenderer(IMetadataRenderer _newRenderer, bytes memory _rendererInitializer) internal {
        renderer = _newRenderer;

        // If data provided, call initalize to new renderer replacement.
        if (_rendererInitializer.length > 0) {
            renderer.initializeWithData(_rendererInitializer);
        }
        emit SetRenderer(address(renderer));
    }

    
    
    function updateCurationPass(IERC721Upgradeable _curationPass) public onlyOwner {
        curationPass = _curationPass;

        emit TokenPassUpdated(msg.sender, address(_curationPass));
    }

    
    
    function setCurationPaused(bool _setPaused) public onlyOwner {
        
        // Prevents owner from updating the curation active state to the current active state
        if (isPaused == _setPaused) {
            revert CANNOT_SET_SAME_PAUSED_STATE();
        }

        _setCurationPaused(_setPaused);
    }

    function _setCurationPaused(bool _setPaused) internal {
        isPaused = _setPaused;

        emit CurationPauseUpdated(msg.sender, isPaused);
    }

    /**
     *** ---------------------------------- ***
     ***                                    ***
     ***         CURATOR FUNCTIONS          ***
     ***                                    ***
     *** ---------------------------------- ***
     ***/

    
    
    function addListings(Listing[] memory listings) external onlyActive {
        
        // Access control for non owners to acess addListings functionality 
        if (msg.sender != owner()) {
            
            // ensures that curationPass is a valid ERC721 address
            if (address(curationPass).code.length == 0) {
                revert PASS_REQUIRED();
            }

            // checks if non-owner msg.sender owns the Curation Pass
            try curationPass.balanceOf(msg.sender) returns (uint256 count) {
                if (count == 0) {
                    revert PASS_REQUIRED();
                }
            } catch {
                revert PASS_REQUIRED();
            }
        }

        _addListings(listings, msg.sender);
    }

    function _addListings(Listing[] memory listings, address sender) internal {
        if (curationLimit != 0 && numAdded - numRemoved + listings.length > curationLimit) {
            revert TOO_MANY_ENTRIES();
        }

        for (uint256 i = 0; i < listings.length; ++i) {
            if (listings[i].curator != sender) {
                revert WRONG_CURATOR_FOR_LISTING(listings[i].curator, msg.sender);
            }
            if (listings[i].chainId == 0) {
                listings[i].chainId = uint16(block.chainid);
            }
            idToListing[numAdded] = listings[i];
            _mint(listings[i].curator, numAdded);
            ++numAdded;
        }
    }

    
    
    
    function updateSortOrders(uint256[] calldata tokenIds, int32[] calldata sortOrders) external onlyActive {
        
        // prevents users from submitting invalid inputs
        if (tokenIds.length != sortOrders.length) {
            revert INVALID_INPUT_LENGTH();
        }
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _setSortOrder(tokenIds[i], sortOrders[i]);
        }
        emit UpdatedSortOrder(tokenIds, sortOrders, msg.sender);
    }

    // prevents non-owners from updating the SortOrder on a listingRecord they did not curate themselves 
    function _setSortOrder(uint256 listingId, int32 sortOrder) internal onlyCuratorOrAdmin(listingId) {
        idToListing[listingId].sortOrder = sortOrder;
    }

    /**
     *** ---------------------------------- ***
     ***                                    ***
     ***     listingRecord NFT Functions    ***
     ***                                    ***
     *** ---------------------------------- ***
     ***/

    
    
    function burn(uint256 listingId) public onlyActive {

        // ensures that msg.sender must be contract owner or the curator of the specific listingId 
        _burnTokenWithChecks(listingId);
    }


    
    
    function removeListings(uint256[] calldata listingIds) external onlyActive {
        unchecked {
            for (uint256 i = 0; i < listingIds.length; ++i) {
                _burnTokenWithChecks(listingIds[i]);
            }
        }
    }

    function _exists(uint256 id) internal view virtual override returns (bool) {
        return idToListing[id].curator != address(0);
    }

    function balanceOf(address _owner) public view override returns (uint256 balance) {
        for (uint256 i = 0; i < numAdded; ++i) {
            if (idToListing[i].curator == _owner) {
                ++balance;
            }
        }
    }

    function name() external view override returns (string memory) {
        return contractName;
    }

    function symbol() external view override returns (string memory) {
        return contractSymbol;
    }

    function totalSupply() public view override(CuratorSkeletonNFT, ICurator) returns (uint256) {
        return numAdded - numRemoved;
    }

    
    function ownerOf(uint256 id) public view virtual override returns (address) {
        if (!_exists(id)) {
            revert TOKEN_HAS_NO_OWNER();
        }
        return idToListing[id].curator;
    }

    
    
    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        return renderer.tokenURI(tokenId);
    }

    
    function contractURI() external view override returns (string memory) {
        return renderer.contractURI();
    }

    function _burnTokenWithChecks(uint256 listingId) internal onlyActive onlyCuratorOrAdmin(listingId) {
        Listing memory _listing = idToListing[listingId];
        // Process NFT Burn
        _burn(listingId);

        // Remove listing
        delete idToListing[listingId];
        unchecked {
            ++numRemoved;
        }

        emit ListingRemoved(msg.sender, _listing);
    }

    /**
     *** ---------------------------------- ***
     ***                                    ***
     ***         UPGRADE FUNCTIONS          ***
     ***                                    ***
     *** ---------------------------------- ***
     ***/

    
    
    
    function _authorizeUpgrade(address _newImpl) internal view override onlyOwner {
        if (!curatorFactory.isValidUpgrade(_getImplementation(), _newImpl)) {
            revert INVALID_UPGRADE(_newImpl);
        }
    }
}

// 
pragma solidity ^0.8.15;

interface IMetadataRenderer {
    function tokenURI(uint256) external view returns (string memory);
    function contractURI() external view returns (string memory);
    function initializeWithData(bytes memory initData) external;
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        
        assembly {
            r.slot := slot
        }
    }
}

// 
pragma solidity ^0.8.4;




/// - Uses custom errors `INVALID_TARGET()` & `DELEGATE_CALL_FAILED()`
/// - Adds util converting address to bytes32
library Address {
    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error INVALID_TARGET();

    
    error DELEGATE_CALL_FAILED();

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    function toBytes32(address _account) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_account)) << 96);
    }

    
    function isContract(address _account) internal view returns (bool rv) {
        assembly {
            rv := gt(extcodesize(_account), 0)
        }
    }

    
    function functionDelegateCall(address _target, bytes memory _data) internal returns (bytes memory) {
        if (!isContract(_target)) revert INVALID_TARGET();

        (bool success, bytes memory returndata) = _target.delegatecall(_data);

        return verifyCallResult(success, returndata);
    }

    
    function verifyCallResult(bool _success, bytes memory _returndata) internal pure returns (bytes memory) {
        if (_success) {
            return _returndata;
        } else {
            if (_returndata.length > 0) {
                assembly {
                    let returndata_size := mload(_returndata)

                    revert(add(32, _returndata), returndata_size)
                }
            } else {
                revert DELEGATE_CALL_FAILED();
            }
        }
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
