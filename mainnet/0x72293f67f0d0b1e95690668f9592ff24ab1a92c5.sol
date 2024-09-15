// SPDX-License-Identifier: MIT


// 

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// 

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
pragma solidity ^0.8.9;



interface IERC2981Royalties {
    
    //          is owed and to whom.
    
    
    
    
    function royaltyInfo(uint256 _tokenId, uint256 _value)
        external
        view
        returns (address _receiver, uint256 _royaltyAmount);
}

// 
pragma solidity ^0.8.9;

interface IFoundationSecondarySales {
    
    
    
    function getFees(uint256 tokenId)
        external
        view
        returns (address payable[] memory, uint256[] memory);
}

// 
pragma solidity ^0.8.9;

interface IRaribleSecondarySales {
    
    
    
    function getFeeRecipients(uint256 tokenId)
        external
        view
        returns (address payable[] memory);

    
    
    
    function getFeeBps(uint256 tokenId)
        external
        view
        returns (uint256[] memory);
}
// 

pragma solidity ^0.8.0;


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// 

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// 
pragma solidity ^0.8.9;



interface IERC721WithMutableURI {
    function mutableURI(uint256 tokenId) external view returns (string memory);
}

// 
pragma solidity ^0.8.9;







interface IERC721WithRoyalties is
    IERC2981Royalties,
    IRaribleSecondarySales,
    IFoundationSecondarySales
{

}
// 

pragma solidity ^0.8.0;




/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

//
pragma solidity ^0.8.9;





contract ForgeMasterStorage {
    // if creation is locked or not
    bool internal _locked;

    // fee to pay to create a contract
    uint256 internal _fee;

    // how many creations are still free
    uint256 internal _freeCreations;

    // current ERC721 implementation
    address internal _erc721Implementation;

    // current ERC1155 implementation
    // although this won't be used at the start
    address internal _erc1155Implementation;

    // opensea erc721 ProxyRegistry / Proxy contract address
    address internal _openseaERC721ProxyRegistry;

    // opensea erc1155 ProxyRegistry / Proxy contract address
    address internal _openseaERC1155ProxyRegistry;

    // list of all registries created
    EnumerableSetUpgradeable.AddressSet internal _registries;

    // list of all "official" modules
    EnumerableSetUpgradeable.AddressSet internal _modules;

    // slugs used for registries
    mapping(bytes32 => address) internal _slugsToRegistry;
    mapping(address => bytes32) internal _registryToSlug;

    // this is used for the reindexing requests
    mapping(address => uint256) public lastIndexing;

    // Flagging might be used if there  are abuses, and we need a way to "flag" elements
    // in The Graph

    // used to flag a registry
    mapping(address => bool) public flaggedRegistries;

    // used to flag a token in a registry
    mapping(address => mapping(uint256 => bool)) internal _flaggedTokens;

    address internal _erc721SlimImplementation;

    // gap
    uint256[49] private __gap;
}

//
pragma solidity ^0.8.9;






interface IForgeMaster {
    
    
    function isLocked() external view returns (bool);

    
    function getERC721Implementation() external view returns (address);

    
    function getERC1155Implementation() external view returns (address);

    
    function getERC721ProxyRegistry() external view returns (address);

    
    function getERC1155ProxyRegistry() external view returns (address);

    
    
    
    function isSlugFree(string memory slug) external view returns (bool);

    
    
    
    function getRegistryBySlug(string memory slug)
        external
        view
        returns (address);

    
    
    
    
    function listRegistries(uint256 startAt, uint256 limit)
        external
        view
        returns (address[] memory list);

    
    
    function listModules() external view returns (address[] memory list);

    
    
    
    function isTokenFlagged(address registry, uint256 tokenId)
        external
        view
        returns (bool);

    
    
    
    
    
    
    
    
    
    
    
    function createERC721(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        string memory baseURI_,
        address owner_,
        INiftyForge721.ModuleInit[] memory modulesInit,
        address contractRoyaltiesRecipient,
        uint256 contractRoyaltiesValue,
        string memory slug,
        string memory context
    ) external returns (address newContract);

    
    
    
    
    
    
    
    
    
    
    
    function createERC721Slim(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        string memory baseURI_,
        address owner_,
        address minter,
        address contractRoyaltiesRecipient,
        uint256 contractRoyaltiesValue,
        string memory slug,
        string memory context
    ) external returns (address newContract);

    
    ///         (for example if baseURI changes)
    ///         This will be listen to by the NiftyForgeMetadata graph, and launch;
    ///         - either a reindexation of alist of tokenIds (if tokenIds.length != 0)
    ///         - a full reindexation if tokenIds.length == 0
    ///         This can be very long and block the indexer
    ///         so calling this with a list of tokenIds > 10 or for a full reindexation is limited
    ///         Abuse on this function can also result in the Registry banned.
    ///         Only an Editor on the Registry can request a full reindexing
    
    
    function forceReindexing(address registry, uint256[] memory tokenIds)
        external;

    
    
    
    function flagRegistry(address registry, string memory reason) external;

    
    
    
    
    function flagToken(
        address registry,
        uint256 tokenId,
        string memory reason
    ) external;

    
    
    function setLocked(bool locked) external;

    
    
    function setERC721Implementation(address implementation) external;

    
    
    function setERC1155Implementation(address implementation) external;

    
    
    function setERC721ProxyRegistry(address proxy) external;

    
    
    function setERC1155ProxyRegistry(address proxy) external;

    
    
    function addModule(address module) external;

    
    
    function removeModule(address module) external;

    
    
    
    ///        be aware that slugs will only work in the frontend if
    ///        they are composed of a-zA-Z0-9 and -
    ///        with no double dashed (--) allowed.
    ///        Any other character will render the slug invalid.
    
    function setSlug(string memory slug, address registry) external;
}

//
pragma solidity ^0.8.9;








///      ERC721 / URIStorage / Royalties
///      This contract does not use ERC721enumerable because Enumerable adds quite some
///      gas to minting costs and I am trying to make this cheap for creators.
///      Also, since all NiftyForge contracts will be fully indexed in TheGraph it will easily
///      Be possible to get tokenIds of an owner off-chain, before passing them to a contract
///      which can verify ownership at the processing time

interface IERC721Full is
    IERC721Upgradeable,
    IERC721WithRoyalties,
    IERC721WithMutableURI
{
    function baseURI() external view returns (string memory);

    function contractURI() external view returns (string memory);

    
    ///         any balance / ERC20 / ERC721 / ERC1155 it can have
    ///         this contract has no payable nor receive function so it should not get any nativ token
    ///         but this could save some ERC20, 721 or 1155
    
    
    
    function withdraw(
        address token,
        uint256 amount,
        uint256 tokenId
    ) external;

    
    
    function canEdit(address account) external view returns (bool);

    
    
    function canMint(address account) external view returns (bool);

    
    
    function isEditor(address account) external view returns (bool);

    
    
    function isMinter(address account) external view returns (bool);

    
    
    
    
    
    
    
    
    function safeTransferFromWithPermit(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data,
        uint256 deadline,
        bytes memory signature
    ) external;

    
    
    
    function setBaseURI(string memory baseURI_) external;

    
    
    function setBaseMutableURI(string memory baseMutableURI_) external;

    
    
    ///         -> if there is a baseMutableURI and a mutableURI, concat baseMutableURI + mutableURI
    ///         -> else if there is only mutableURI, return mutableURI
    //.         -> else if there is only baseMutableURI, concat baseMutableURI + tokenId
    
    
    
    function setMutableURI(uint256 tokenId, string memory mutableURI_) external;

    
    
    
    function addEditors(address[] memory users) external;

    
    
    
    function removeEditors(address[] memory users) external;

    
    
    
    function addMinters(address[] memory users) external;

    
    
    
    function removeMinters(address[] memory users) external;

    
    
    
    function setDefaultRoyaltiesRecipient(address recipient) external;

    
    
    
    
    function setTokenRoyaltiesRecipient(uint256 tokenId, address recipient)
        external;

    
    
    
    function setContractURI(string memory contractURI_) external;
}

//
pragma solidity ^0.8.9;






///      Slim ERC721 do not have all the bells and whistle that the ERC721Full have
///      Slim is made for series (like PFPs or Generative series)
///      The mint starts from 1 and ups
///      Not even the owner can mint directly on this collection.
///      It has to be the module passed as initialization

interface IERC721Slim is IERC721Upgradeable, IERC721WithRoyalties {
    function baseURI() external view returns (string memory);

    function contractURI() external view returns (string memory);

    // receive() external payable {}

    
    ///         any balance / ERC20 / ERC721 / ERC1155 it can have
    ///         this contract has no payable nor receive function so it should not get any nativ token
    ///         but this could save some ERC20, 721 or 1155
    
    
    
    function withdraw(
        address token,
        uint256 amount,
        uint256 tokenId
    ) external;

    
    
    function canEdit(address account) external view returns (bool);

    
    
    
    
    
    
    
    
    function safeTransferFromWithPermit(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data,
        uint256 deadline,
        bytes memory signature
    ) external;

    
    
    
    function setBaseURI(string memory baseURI_) external;

    
    
    
    function setDefaultRoyaltiesRecipient(address recipient) external;

    
    
    
    function setContractURI(string memory contractURI_) external;
}

// 

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library ClonesUpgradeable {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

//
pragma solidity ^0.8.9;















///         modules, Permits, on-chain Royalties, for pretty cheap.
///         Those contract & nfts are all referenced in the same Subgraph that can be used to create
///         a small, customizable, Storefront for anyone that wishes to.
contract ForgeMaster is IForgeMaster, OwnableUpgradeable, ForgeMasterStorage {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    // emitted when a registry is created
    event RegistryCreated(address indexed registry, string context);

    // emitted when a slug is registered for a registry
    event RegistrySlug(address indexed registry, string slug);

    // emitted when a module is added to the list of official modules
    event ModuleAdded(address indexed module);

    // emitted when a module is removed from the list of official modules
    event ModuleRemoved(address indexed module);

    // Force reindexing for a registry
    // if tokenIds.length == 0 then a full reindexing will be performed
    // this will be done automatically in the "niftyforge metadata" graph
    // It might create a *very* long indexing process. Do not use for fun.
    // Abuse of reindexing might result in the registry being flagged
    // and banned from the public indexer
    event ForceIndexing(address registry, uint256[] tokenIds);

    // Flags a registry
    event FlagRegistry(address registry, address operator, string reason);

    // Flags a token
    event FlagToken(
        address registry,
        uint256 tokenId,
        address operator,
        string reason
    );

    function initialize(bool locked, address owner_) external initializer {
        __Ownable_init();

        _locked = locked;

        if (owner_ != address(0)) {
            transferOwnership(owner_);
        }
    }

    
    
    function isLocked() external view returns (bool) {
        return _locked;
    }

    
    function getERC721Implementation() public view returns (address) {
        return _erc721Implementation;
    }

    
    function getERC1155Implementation() public view returns (address) {
        return _erc1155Implementation;
    }

    
    function getERC721ProxyRegistry() public view returns (address) {
        return _openseaERC721ProxyRegistry;
    }

    
    function getERC1155ProxyRegistry() public view returns (address) {
        return _openseaERC1155ProxyRegistry;
    }

    
    
    
    function isSlugFree(string memory slug) external view returns (bool) {
        bytes32 bSlug = keccak256(bytes(slug));
        // verifies that the slug is not already in use
        return _slugsToRegistry[bSlug] != address(0);
    }

    
    
    
    function getRegistryBySlug(string memory slug)
        external
        view
        returns (address)
    {
        bytes32 bSlug = keccak256(bytes(slug));
        // verifies that the slug is not already in use
        require(_slugsToRegistry[bSlug] != address(0), '!UNKNOWN_SLUG!');
        return _slugsToRegistry[bSlug];
    }

    
    
    
    
    function listRegistries(uint256 startAt, uint256 limit)
        external
        view
        returns (address[] memory list)
    {
        uint256 count = _registries.length();

        require(startAt < count, '!OVERFLOW!');

        if (startAt + limit > count) {
            limit = count - startAt;
        }

        list = new address[](limit);
        for (uint256 i; i < limit; i++) {
            list[i] = _registries.at(startAt + i);
        }
    }

    
    
    function listModules() external view returns (address[] memory list) {
        uint256 count = _modules.length();
        list = new address[](count);
        for (uint256 i; i < count; i++) {
            list[i] = _modules.at(i);
        }
    }

    
    
    
    function isTokenFlagged(address registry, uint256 tokenId)
        public
        view
        returns (bool)
    {
        return _flaggedTokens[registry][tokenId];
    }

    
    
    
    
    
    
    
    
    
    
    
    function createERC721(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        string memory baseURI_,
        address owner_,
        INiftyForge721.ModuleInit[] memory modulesInit,
        address contractRoyaltiesRecipient,
        uint256 contractRoyaltiesValue,
        string memory slug,
        string memory context
    ) external returns (address newContract) {
        require(_erc721Implementation != address(0), '!NO_721_IMPLEMENTATION!');

        // verify not locked or not owner
        require(_locked == false || msg.sender == owner(), '!LOCKED!');

        // create minimal proxy to _erc721Implementation
        newContract = ClonesUpgradeable.clone(_erc721Implementation);

        // initialize the non upgradeable proxy
        INiftyForge721(payable(newContract)).initialize(
            name_,
            symbol_,
            contractURI_,
            baseURI_,
            owner_ != address(0) ? owner_ : msg.sender,
            modulesInit,
            contractRoyaltiesRecipient,
            contractRoyaltiesValue
        );

        // add the new contract to the registry
        _addRegistry(newContract, context);

        if (bytes(slug).length > 0) {
            setSlug(slug, newContract);
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    function createERC721Slim(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        string memory baseURI_,
        address owner_,
        address minter,
        address contractRoyaltiesRecipient,
        uint256 contractRoyaltiesValue,
        string memory slug,
        string memory context
    ) external returns (address newContract) {
        require(
            _erc721SlimImplementation != address(0),
            '!NO_721SLIM_IMPLEMENTATION!'
        );

        // verify not locked or not owner
        require(_locked == false || msg.sender == owner(), '!LOCKED!');

        // create minimal proxy to _erc721SlimImplementation
        newContract = ClonesUpgradeable.clone(_erc721SlimImplementation);

        // initialize the non upgradeable proxy
        INiftyForge721Slim(newContract).initialize(
            name_,
            symbol_,
            contractURI_,
            baseURI_,
            owner_ != address(0) ? owner_ : msg.sender,
            minter,
            contractRoyaltiesRecipient,
            contractRoyaltiesValue
        );

        // add the new contract to the registry
        _addRegistry(newContract, context);

        if (bytes(slug).length > 0) {
            setSlug(slug, newContract);
        }
    }

    
    ///         (for example if baseURI changes)
    ///         This will be listen to by the NiftyForgeMetadata graph, and launch;
    ///         - either a reindexation of alist of tokenIds (if tokenIds.length != 0)
    ///         - a full reindexation if tokenIds.length == 0
    ///         This can be very long and block the indexer
    ///         so calling this with a list of tokenIds > 10 or for a full reindexation is limited
    ///         Abuse on this function can also result in the Registry banned.
    ///         Only an Editor on the Registry can request a full reindexing
    
    
    function forceReindexing(address registry, uint256[] memory tokenIds)
        external
    {
        require(_registries.contains(registry), '!UNKNOWN_REGISTRY!');
        require(flaggedRegistries[registry] == false, '!FLAGGED_REGISTRY!');

        // only an editor can ask for a "big indexing"
        if (tokenIds.length == 0 || tokenIds.length > 10) {
            uint256 lastKnownIndexing = lastIndexing[registry];
            require(
                block.timestamp - lastKnownIndexing > 1 days,
                '!INDEXING_DELAY!'
            );

            require(
                INiftyForge721(payable(registry)).canEdit(msg.sender),
                '!NOT_EDITOR!'
            );
            lastIndexing[registry] = block.timestamp;
        }

        emit ForceIndexing(registry, tokenIds);
    }

    
    
    
    function flagRegistry(address registry, string memory reason)
        external
        onlyOwner
    {
        require(_registries.contains(registry), '!UNKNOWN_REGISTRY!');
        require(
            flaggedRegistries[registry] == false,
            '!REGISTRY_ALREADY_FLAGGED!'
        );

        flaggedRegistries[registry] = true;

        emit FlagRegistry(registry, msg.sender, reason);
    }

    
    
    
    
    function flagToken(
        address registry,
        uint256 tokenId,
        string memory reason
    ) external {
        require(_registries.contains(registry), '!UNKNOWN_REGISTRY!');
        require(
            flaggedRegistries[registry] == false,
            '!REGISTRY_ALREADY_FLAGGED!'
        );
        require(
            _flaggedTokens[registry][tokenId] == false,
            '!TOKEN_ALREADY_FLAGGED!'
        );

        // only this contract owner, or an editor on the registry, can flag a token
        // tokens when they are flagged are not shown on the
        require(
            msg.sender == owner() ||
                INiftyForge721(payable(registry)).canEdit(msg.sender),
            '!NOT_EDITOR!'
        );

        _flaggedTokens[registry][tokenId] = true;

        emit FlagToken(registry, tokenId, msg.sender, reason);
    }

    
    
    function setLocked(bool locked) external onlyOwner {
        _locked = locked;
    }

    
    
    function setERC721Implementation(address implementation) public onlyOwner {
        _setERC721Implementation(implementation);
    }

    
    
    function setERC721SlimImplementation(address implementation)
        public
        onlyOwner
    {
        _setERC721SlimImplementation(implementation);
    }

    
    
    function setERC1155Implementation(address implementation) public onlyOwner {
        _setERC1155Implementation(implementation);
    }

    
    
    function setERC721ProxyRegistry(address proxy) public onlyOwner {
        _openseaERC721ProxyRegistry = proxy;
    }

    
    
    function setERC1155ProxyRegistry(address proxy) public onlyOwner {
        _openseaERC1155ProxyRegistry = proxy;
    }

    
    
    function addModule(address module) external onlyOwner {
        if (_modules.add(module)) {
            emit ModuleAdded(module);
        }
    }

    
    
    function removeModule(address module) external onlyOwner {
        if (_modules.remove(module)) {
            emit ModuleRemoved(module);
        }
    }

    
    
    
    ///        be aware that slugs will only work in the frontend if
    ///        they are composed of a-zA-Z0-9 and -
    ///        with no double dashed (--) allowed.
    ///        Any other character will render the slug invalid.
    
    function setSlug(string memory slug, address registry) public {
        bytes32 bSlug = keccak256(bytes(slug));

        // verifies that the slug is not already in use
        require(_slugsToRegistry[bSlug] == address(0), '!SLUG_IN_USE!');

        // verifies that the sender is a collection Editor or Owner
        require(
            INiftyForge721(payable(registry)).canEdit(msg.sender),
            '!NOT_EDITOR!'
        );

        // if the registry is already linked to a slug, free it
        bytes32 currentSlug = _registryToSlug[registry];
        if (currentSlug.length > 0) {
            delete _slugsToRegistry[currentSlug];
        }

        // if the new slug is not empty
        if (bytes(slug).length > 0) {
            _slugsToRegistry[bSlug] = registry;
            _registryToSlug[registry] = bSlug;
        } else {
            // remove registry to slug
            delete _registryToSlug[registry];
        }

        emit RegistrySlug(registry, slug);
    }

    
    
    function _setERC721Implementation(address implementation) internal {
        _erc721Implementation = implementation;
    }

    
    
    function _setERC721SlimImplementation(address implementation) internal {
        _erc721SlimImplementation = implementation;
    }

    
    
    function _setERC1155Implementation(address implementation) internal {
        _erc1155Implementation = implementation;
    }

    
    
    function _addRegistry(address registry, string memory context) internal {
        _registries.add(registry);
        emit RegistryCreated(registry, context);
    }
}

//
pragma solidity ^0.8.9;






interface INiftyForge721 is IERC721Full {
    struct ModuleInit {
        address module;
        bool enabled;
        bool minter;
    }

    
    ///         Although it uses what are called upgradeable contracts, this is only to
    ///         be able to make deployment cheap using a Proxy but NiftyForge contracts
    ///         ARE NOT UPGRADEABLE => the proxy used is not an upgradeable proxy, the implementation is immutable
    
    
    
    
    
    
    
    
    function initialize(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        string memory baseURI_,
        address owner_,
        ModuleInit[] memory modulesInit_,
        address contractRoyaltiesRecipient,
        uint256 contractRoyaltiesValue
    ) external;

    
    
    /// erc: 00 => ERC721 | 01 => ERC1155
    /// type: 00 => full | 01 => slim
    /// version: 00, 01, 02, 03...
    function version() external view returns (bytes3);

    
    function totalSupply() external view returns (uint256);

    
    function isMintingOpenToAll() external view returns (bool);

    
    
    function setMintingOpenToAll(bool isOpen) external;

    
    function setMaxSupply(uint256 maxSupply_) external;

    
    
    
    function mint(address to) external returns (uint256 tokenId);

    
    
    
    
    function mint(address to, address transferTo)
        external
        returns (uint256 tokenId);

    
    
    
    
    
    ///        where 10000 == 100.00%; 1000 == 10.00%; 250 == 2.50%
    
    ///        this is used when we want to mint the NFT to the creator address
    ///        before transferring it to a recipient
    
    function mint(
        address to,
        string memory uri,
        address feeRecipient,
        uint256 feeAmount,
        address transferTo
    ) external returns (uint256 tokenId);

    
    
    
    
    
    ///        where 10000 == 100.00%; 1000 == 10.00%; 250 == 2.50%
    
    
    function mintBatch(
        address[] memory to,
        string[] memory uris,
        address[] memory feeRecipients,
        uint256[] memory feeAmounts
    ) external returns (uint256 startId, uint256 endId);

    
    ///         Because not all tokenIds have incremental ids
    ///         be careful with this function, it does not increment lastTokenId
    ///         and expects the minter to actually know what it is doing.
    ///         this also means, this function does not verify _maxTokenId
    
    
    
    
    
    ///        where 10000 == 100.00%; 1000 == 10.00%; 250 == 2.50%
    
    ///        this is used when we want to mint the NFT to the creator address
    ///        before transferring it to a recipient
    
    function mint(
        address to,
        string memory uri,
        uint256 tokenId_,
        address feeRecipient,
        uint256 feeAmount,
        address transferTo
    ) external returns (uint256 tokenId);

    
    ///         Because not all tokenIds have incremental ids
    ///         be careful with this function, it does not increment lastTokenId
    ///         and expects the minter to actually know what it's doing.
    ///         this also means, this function does not verify _maxTokenId
    
    
    
    
    
    ///        where 10000 == 100.00%; 1000 == 10.00%; 250 == 2.50%
    function mintBatch(
        address[] memory to,
        string[] memory uris,
        uint256[] memory tokenIds,
        address[] memory feeRecipients,
        uint256[] memory feeAmounts
    ) external;

    
    
    
    
    function attachModule(
        address module,
        bool enabled,
        bool canModuleMint
    ) external;

    
    
    
    function enableModule(address module, bool canModuleMint) external;

    
    
    function disableModule(address module, bool keepListeners) external;

    
    function startAtZero() external;

    
    
    
    function renderTokenURI(uint256 tokenId)
        external
        view
        returns (string memory);
}

//
pragma solidity ^0.8.9;





interface INiftyForge721Slim is IERC721Slim {
    
    ///         Although it uses what are called upgradeable contracts, this is only to
    ///         be able to make deployment cheap using a Proxy but NiftyForge contracts
    ///         ARE NOT UPGRADEABLE => the proxy used is not an upgradeable proxy, the implementation is immutable
    
    
    
    
    
    
    
    
    function initialize(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        string memory baseURI_,
        address owner_,
        address minter_,
        address contractRoyaltiesRecipient,
        uint256 contractRoyaltiesValue
    ) external;

    
    
    /// erc: 00 => ERC721 | 01 => ERC1155
    /// type: 00 => full | 01 => slim
    /// version: 00, 01, 02, 03...
    function version() external view returns (bytes3);

    
    function minter() external view returns (address);

    
    function totalSupply() external view returns (uint256);

    
    function minted() external view returns (uint256);

    
    function maxSupply() external view returns (uint256);

    
    
    
    function mint(address to) external returns (uint256 tokenId);

    
    
    
    
    function mint(address to, address transferTo)
        external
        returns (uint256 tokenId);

    
    
    
    function mintBatch(address to, uint256 count)
        external
        returns (uint256 startId, uint256 endId);
}
