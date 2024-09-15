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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Metadata.sol)

pragma solidity ^0.8.0;



// 
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
pragma solidity ^0.8.10;

interface IMetadataRenderer {
    function tokenURI(uint256) external view returns (string memory);
    function contractURI() external view returns (string memory);
    function initializeWithData(bytes memory initData) external;
}

// 
pragma solidity ^0.8.10;



contract MetadataRenderAdminCheck {
    error Access_OnlyAdmin();

    
    
    modifier requireSenderAdmin(address target) {
        if (target != msg.sender && !IERC721Drop(target).isAdmin(msg.sender)) {
            revert Access_OnlyAdmin();
        }

        _;
    }
}

// 
pragma solidity ^0.8.10;

interface ITokenUriMetadataRenderer {
    function updateTokenURI(address, uint256, string memory) external;
    function updateContractURI(address, string memory) external;
}// 
// Creator: Chiru Labs

pragma solidity ^0.8.4;




/**
 * @dev Interface of an ERC721A compliant contract.
 */
interface IERC721AUpgradeable is IERC721Upgradeable, IERC721MetadataUpgradeable {
    /**
     * The caller must own the token or be an approved operator.
     */
    error ApprovalCallerNotOwnerNorApproved();

    /**
     * The token does not exist.
     */
    error ApprovalQueryForNonexistentToken();

    /**
     * The caller cannot approve to their own address.
     */
    error ApproveToCaller();

    /**
     * The caller cannot approve to the current owner.
     */
    error ApprovalToCurrentOwner();

    /**
     * Cannot query the balance for the zero address.
     */
    error BalanceQueryForZeroAddress();

    /**
     * Cannot mint to the zero address.
     */
    error MintToZeroAddress();

    /**
     * The quantity of tokens minted must be more than zero.
     */
    error MintZeroQuantity();

    /**
     * The token does not exist.
     */
    error OwnerQueryForNonexistentToken();

    /**
     * The caller must own the token or be an approved operator.
     */
    error TransferCallerNotOwnerNorApproved();

    /**
     * The token must be owned by `from`.
     */
    error TransferFromIncorrectOwner();

    /**
     * Cannot safely transfer to a contract that does not implement the ERC721Receiver interface.
     */
    error TransferToNonERC721ReceiverImplementer();

    /**
     * Cannot transfer to the zero address.
     */
    error TransferToZeroAddress();

    /**
     * The token does not exist.
     */
    error URIQueryForNonexistentToken();

    // Compiler will pack this into a single 256bit word.
    struct TokenOwnership {
        // The address of the owner.
        address addr;
        // Keeps track of the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
    }

    // Compiler will pack this into a single 256bit word.
    struct AddressData {
        // Realistically, 2**64-1 is more than enough.
        uint64 balance;
        // Keeps track of mint count with minimal overhead for tokenomics.
        uint64 numberMinted;
        // Keeps track of burn count with minimal overhead for tokenomics.
        uint64 numberBurned;
        // For miscellaneous variable(s) pertaining to the address
        // (e.g. number of whitelist mint slots used).
        // If there are multiple variables, please pack them into a uint64.
        uint64 aux;
    }

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     * @dev Burned tokens are calculated here, use _totalMinted() if you want to count just minted tokens.
     */
    function totalSupply() external view returns (uint256);
}

// 
pragma solidity ^0.8.10;



/**

 ________   _____   ____    ______      ____
/\_____  \ /\  __`\/\  _`\ /\  _  \    /\  _`\
\/____//'/'\ \ \/\ \ \ \L\ \ \ \L\ \   \ \ \/\ \  _ __   ___   _____     ____
     //'/'  \ \ \ \ \ \ ,  /\ \  __ \   \ \ \ \ \/\`'__\/ __`\/\ '__`\  /',__\
    //'/'___ \ \ \_\ \ \ \\ \\ \ \/\ \   \ \ \_\ \ \ \//\ \L\ \ \ \L\ \/\__, `\
    /\_______\\ \_____\ \_\ \_\ \_\ \_\   \ \____/\ \_\\ \____/\ \ ,__/\/\____/
    \/_______/ \/_____/\/_/\/ /\/_/\/_/    \/___/  \/_/ \/___/  \ \ \/  \/___/
                                                                 \ \_\
                                                                  \/_/

*/


interface IERC721Drop {
    // Access errors

    
    error Access_OnlyAdmin();
    
    error Access_MissingRoleOrAdmin(bytes32 role);
    
    error Access_WithdrawNotAllowed();
    
    error Withdraw_FundsSendFailure();

    
    
    error OperatorNotAllowed(address operator);

    
    
    error MarketFilterDAOAddressNotSupportedForChain();

    
    
    error RemoteOperatorFilterRegistryCallFailed();

    // Sale/Purchase errors
    
    error Sale_Inactive();
    
    error Presale_Inactive();
    
    error Presale_MerkleNotApproved();
    
    error Purchase_WrongPrice(uint256 correctPrice);
    
    error Mint_SoldOut();
    
    error Purchase_TooManyForAddress();
    
    error Presale_TooManyForAddress();

    // Admin errors
    
    error Setup_RoyaltyPercentageTooHigh(uint16 maxRoyaltyBPS);
    
    error Admin_InvalidUpgradeAddress(address proposedAddress);
    
    error Admin_UnableToFinalizeNotOpenEdition();

    
    
    
    
    
    event Sale(
        address indexed to,
        uint256 indexed quantity,
        uint256 indexed pricePerToken,
        uint256 firstPurchasedTokenId
    );

    
    
    
    event SalesConfigChanged(address indexed changedBy);

    
    
    
    event FundsRecipientChanged(
        address indexed newAddress,
        address indexed changedBy
    );

    
    
    
    
    
    
    event FundsWithdrawn(
        address indexed withdrawnBy,
        address indexed withdrawnTo,
        uint256 amount,
        address feeRecipient,
        uint256 feeAmount
    );

    
    
    
    event OpenMintFinalized(address indexed sender, uint256 numberOfMints);

    
    
    
    event UpdatedMetadataRenderer(address sender, IMetadataRenderer renderer);

    
    struct Configuration {
        
        IMetadataRenderer metadataRenderer;
        
        uint64 editionSize;
        
        uint16 royaltyBPS;
        
        address payable fundsRecipient;
    }

    
    
    struct SalesConfiguration {
        
        uint104 publicSalePrice;
        
        
        uint32 maxSalePurchasePerAddress;
        
        
        uint64 publicSaleStart;
        
        uint64 publicSaleEnd;
        
        
        uint64 presaleStart;
        
        uint64 presaleEnd;
        
        bytes32 presaleMerkleRoot;
    }

    
    struct SaleDetails {
        // Synthesized status variables for sale and presale
        bool publicSaleActive;
        bool presaleActive;
        // Price for public sale
        uint256 publicSalePrice;
        // Timed sale actions for public sale
        uint64 publicSaleStart;
        uint64 publicSaleEnd;
        // Timed sale actions for presale
        uint64 presaleStart;
        uint64 presaleEnd;
        // Merkle root (includes address, quantity, and price data for each entry)
        bytes32 presaleMerkleRoot;
        // Limit public sale to a specific number of mints per wallet
        uint256 maxSalePurchasePerAddress;
        // Information about the rest of the supply
        // Total that have been minted
        uint256 totalMinted;
        // The total supply available
        uint256 maxSupply;
    }

    
    struct AddressMintDetails {
        /// Number of total mints from the given address
        uint256 totalMints;
        /// Number of presale mints from the given address
        uint256 presaleMints;
        /// Number of public mints from the given address
        uint256 publicMints;
    }

    
    
    
    function purchase(uint256 quantity) external payable returns (uint256);

    
    
    
    
    
    
    function purchasePresale(
        uint256 quantity,
        uint256 maxQuantity,
        uint256 pricePerToken,
        bytes32[] memory merkleProof
    ) external payable returns (uint256);

    
    function saleDetails() external view returns (SaleDetails memory);

    
    
    function mintedPerAddress(address minter)
        external
        view
        returns (AddressMintDetails memory);

    
    function owner() external view returns (address);

    
    
    
    function setMetadataRenderer(
        IMetadataRenderer newRenderer,
        bytes memory setupRenderer
    ) external;

    
    
    
    
    function adminMint(address to, uint256 quantity) external returns (uint256);

    
    
    
    function adminMintAirdrop(address[] memory to) external returns (uint256);

    
    
    function isAdmin(address user) external view returns (bool);
}

// 
pragma solidity ^0.8.15;








/** 
 * @title TokenUriMetadataRenderer
 * @dev External metadata registry that maps initialized token ids to specific unique tokenURIs
 * @dev Can be used by any contract
 * @author Max Bochman
 */
contract TokenUriMetadataRenderer is 
    MetadataRenderAdminCheck,
    IMetadataRenderer, 
    ITokenUriMetadataRenderer 
{

    // ||||||||||||||||||||||||||||||||
    // ||| ERRORS |||||||||||||||||||||
    // ||||||||||||||||||||||||||||||||     

    error No_MetadataAccess();
    error No_WildcardAccess();
    error Cannot_SetBlank();
    error Token_DoesntExist();
    error Address_NotInitialized();

    // ||||||||||||||||||||||||||||
    // ||| EVENTS |||||||||||||||||
    // ||||||||||||||||||||||||||||    

    
    event TokenURIInitialized(
        address indexed target,
        address sender,
        uint256 indexed tokenId,
        string indexed tokenURI
    );    

    
    event TokenURIUpdated(
        address indexed target,
        address sender,
        uint256 indexed tokenId,
        string indexed tokenURI
    );

    
    event ContractURIUpdated(
        address indexed target,
        address sender,
        string indexed contractURI
    );    

    
    
    event CollectionInitialized(
        address indexed target,
        string indexed contractURI,
        address indexed wildcardAddress
    );    

    
    event WildcardAddressUpdated(
        address indexed sender,
        address indexed newWildcardAddress
    );    

    // ||||||||||||||||||||||||||||||||
    // ||| VARIABLES ||||||||||||||||||
    // ||||||||||||||||||||||||||||||||     

    
    mapping(address => string) public contractURIInfo;

    
    mapping(address => address) public wildcardInfo;

    
    mapping(address => mapping(uint256 => string)) public tokenURIInfo;

    // ||||||||||||||||||||||||||||||||
    // ||| MODIFIERS ||||||||||||||||||
    // |||||||||||||||||||||||||||||||| 

    
    
    
    modifier metadataAccessCheck(address target, uint256 tokenId ) {
        if ( 
            // check if msg.sender is admin of underlying Zora Drop Contract
            target != msg.sender && !IERC721Drop(target).isAdmin(msg.sender) 
                // check if msg.sender owns specific tokenId 
                && IERC721AUpgradeable(target).ownerOf(tokenId) != msg.sender
                // check if msg.sender is wildcard address for target
                && wildcardInfo[target] != msg.sender
        ) {
            revert No_MetadataAccess();
        }    
        _;
    }         

    // ||||||||||||||||||||||||||||||||
    // ||| EXTNERAL WRITE FUNCTIONS |||
    // ||||||||||||||||||||||||||||||||  

    
    
    
    function updateContractURI(address target, string memory newContractURI)
        external
        requireSenderAdmin(target)
    {
        if (bytes(contractURIInfo[target]).length == 0) {
            revert Address_NotInitialized();
        }

        contractURIInfo[target] = newContractURI;

        emit ContractURIUpdated({
            target: target,
            sender: msg.sender,
            contractURI: newContractURI
        });
    }

    
    
    
    
    function updateTokenURI(address target, uint256 tokenId, string memory newTokenURI)
        external
    {

        // check if target collection has been initialized
        if (bytes(contractURIInfo[target]).length == 0) {
            revert Address_NotInitialized();
        }

        // check if newTokenURI is empty string
        if (bytes(newTokenURI).length == 0) {
            revert Cannot_SetBlank();
        }

        // check if tokenURI has been set before
        if (bytes(tokenURIInfo[target][tokenId]).length == 0) {

            _initializeTokenURI(target, tokenId, newTokenURI);        
        } else {

            _updateTokenURI(target, tokenId, newTokenURI);
        }

        tokenURIInfo[target][tokenId] = newTokenURI;
    }
    
    
    
    
    function updateWildcardAddress(address target, address newWildcardAddress)
        external
    {
        if (
            // check if msg.sender is admin of underlying Zora Drop Contract
            target != msg.sender && !IERC721Drop(target).isAdmin(msg.sender)
                // check if msg.sender is wildcard address for target
                && msg.sender != wildcardInfo[target]
        ) {
            revert No_WildcardAccess();
        }

        // check if target collection has been initialized
        if (bytes(contractURIInfo[target]).length == 0) {
            revert Address_NotInitialized();
        }        

        wildcardInfo[target] = newWildcardAddress;

        emit WildcardAddressUpdated({
            sender: msg.sender,
            newWildcardAddress: newWildcardAddress        
        });
    }

    
    
    
    function initializeWithData(bytes memory data) external {
        // data format: contractURI, wildcardAddress
        (string memory initContractURI, address initWildcard) = abi.decode(data, (string, address));

        // check if contractURI is being set to empty string
        if (bytes(initContractURI).length == 0) {
            revert Cannot_SetBlank();
        }

        contractURIInfo[msg.sender] = initContractURI;

        // wildcardAddress can be set to address(0)
        wildcardInfo[msg.sender] = initWildcard;
        
        emit CollectionInitialized({
            target: msg.sender,
            contractURI: initContractURI,
            wildcardAddress: initWildcard
        });
    }    

    // ||||||||||||||||||||||||||||||||
    // ||| INTERNAL WRITE FUNCTIONS |||
    // ||||||||||||||||||||||||||||||||     

    function _initializeTokenURI(address target, uint256 tokenId, string memory newTokenURI)
        internal
    {
        tokenURIInfo[target][tokenId] = newTokenURI;

        emit TokenURIInitialized({
            target: target,
            sender: msg.sender,
            tokenId: tokenId,
            tokenURI: newTokenURI 
        });
    }

    function _updateTokenURI(address target, uint256 tokenId, string memory newTokenURI)
        internal
        metadataAccessCheck(target, tokenId)
    {
        tokenURIInfo[target][tokenId] = newTokenURI;

        emit TokenURIUpdated({
            target: target,
            sender: msg.sender,
            tokenId: tokenId,
            tokenURI: newTokenURI 
        });
    }     

    // ||||||||||||||||||||||||||||||||
    // ||| VIEW FUNCTIONS |||||||||||||
    // ||||||||||||||||||||||||||||||||    

    
    
    
    function contractURI() 
        external 
        view 
        override 
        returns (string memory) 
    {
        string memory uri = contractURIInfo[msg.sender];
        if (bytes(uri).length == 0) revert Address_NotInitialized();
        return uri;
    }

    
    
    
    
    function tokenURI(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        string memory uri = tokenURIInfo[msg.sender][tokenId];
        if (bytes(uri).length == 0) revert Token_DoesntExist();
        return tokenURIInfo[msg.sender][tokenId];
    }
}
