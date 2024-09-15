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
pragma solidity ^0.8;



/**
 *  Cedar's 'Drop' contracts are distribution mechanisms for tokens.
 *
 *  A contract admin (i.e. a holder of `DEFAULT_ADMIN_ROLE`) can set a series of claim conditions,
 *  ordered by their respective `startTimestamp`. A claim condition defines criteria under which
 *  accounts can mint tokens. Claim conditions can be overwritten or added to by the contract admin.
 *  At any moment, there is only one active claim condition.
 */

interface IDropClaimConditionV0 {
    /**
     *  @notice The criteria that make up a claim condition.
     *
     *  @param startTimestamp                 The unix timestamp after which the claim condition applies.
     *                                        The same claim condition applies until the `startTimestamp`
     *                                        of the next claim condition.
     *
     *  @param maxClaimableSupply             The maximum total number of tokens that can be claimed under
     *                                        the claim condition.
     *
     *  @param supplyClaimed                  At any given point, the number of tokens that have been claimed
     *                                        under the claim condition.
     *
     *  @param quantityLimitPerTransaction    The maximum number of tokens that can be claimed in a single
     *                                        transaction.
     *
     *  @param waitTimeInSecondsBetweenClaims The least number of seconds an account must wait after claiming
     *                                        tokens, to be able to claim tokens again.
     *
     *  @param merkleRoot                     The allowlist of addresses that can claim tokens under the claim
     *                                        condition.
     *
     *  @param pricePerToken                  The price required to pay per token claimed.
     *
     *  @param currency                       The currency in which the `pricePerToken` must be paid.
     */
    struct ClaimCondition {
        uint256 startTimestamp;
        uint256 maxClaimableSupply;
        uint256 supplyClaimed;
        uint256 quantityLimitPerTransaction;
        uint256 waitTimeInSecondsBetweenClaims;
        bytes32 merkleRoot;
        uint256 pricePerToken;
        address currency;
    }

    /**
     *  @notice The set of all claim conditions, at any given moment.
     *  Claim Phase ID = [currentStartId, currentStartId + length - 1];
     *
     *  @param currentStartId           The uid for the first claim condition amongst the current set of
     *                                  claim conditions. The uid for each next claim condition is one
     *                                  more than the previous claim condition's uid.
     *
     *  @param count                    The total number of phases / claim conditions in the list
     *                                  of claim conditions.
     *
     *  @param phases                   The claim conditions at a given uid. Claim conditions
     *                                  are ordered in an ascending order by their `startTimestamp`.
     *
     *  @param claimDetails             Map from an account and uid for a claim condition, to the claim
     *                                  records an account has done.
     *
     */
    struct ClaimConditionList {
        uint256 currentStartId;
        uint256 count;
        mapping(uint256 => ClaimCondition) phases;
        mapping(uint256 => mapping(address => ClaimDetails)) userClaims;
    }

    /**
     *  @notice Claim detail for a user claim.
     *
     *  @param lastClaimTimestamp    The timestamp at which the last token was claimed.
     *
     *  @param claimedBalance        The number of tokens claimed.
     *
     */
    struct ClaimDetails {
        uint256 lastClaimTimestamp;
        uint256 claimedBalance;
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;



/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;



/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * 
 * constructor() initializer {}
 * ```
 * ====
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

interface IDropClaimConditionV1 {
    /**
     *  @notice The criteria that make up a claim condition.
     *
     *  @param startTimestamp                 The unix timestamp after which the claim condition applies.
     *                                        The same claim condition applies until the `startTimestamp`
     *                                        of the next claim condition.
     *
     *  @param maxClaimableSupply             The maximum total number of tokens that can be claimed under
     *                                        the claim condition.
     *
     *  @param supplyClaimed                  At any given point, the number of tokens that have been claimed
     *                                        under the claim condition.
     *
     *  @param quantityLimitPerTransaction    The maximum number of tokens that can be claimed in a single
     *                                        transaction.
     *
     *  @param waitTimeInSecondsBetweenClaims The least number of seconds an account must wait after claiming
     *                                        tokens, to be able to claim tokens again.
     *
     *  @param merkleRoot                     The allowlist of addresses that can claim tokens under the claim
     *                                        condition.
     *
     *  @param pricePerToken                  The price required to pay per token claimed.
     *
     *  @param currency                       The currency in which the `pricePerToken` must be paid.
     */
    struct ClaimCondition {
        uint256 startTimestamp;
        uint256 maxClaimableSupply;
        uint256 supplyClaimed;
        uint256 quantityLimitPerTransaction;
        uint256 waitTimeInSecondsBetweenClaims;
        bytes32 merkleRoot;
        uint256 pricePerToken;
        address currency;
        bytes32 phaseId;
    }

    /**
     *  @notice The set of all claim conditions, at any given moment.
     *  Claim Phase ID = [currentStartId, currentStartId + length - 1];
     *
     *  @param currentStartId           The uid for the first claim condition amongst the current set of
     *                                  claim conditions. The uid for each next claim condition is one
     *                                  more than the previous claim condition's uid.
     *
     *  @param count                    The total number of phases / claim conditions in the list
     *                                  of claim conditions.
     *
     *  @param phases                   The claim conditions at a given uid. Claim conditions
     *                                  are ordered in an ascending order by their `startTimestamp`.
     *
     *  @param claimDetails             Map from an account and uid for a claim condition, to the claim
     *                                  records an account has done.
     *
     */
    struct ClaimConditionList {
        uint256 currentStartId;
        uint256 count;
        mapping(uint256 => ClaimCondition) phases;
        mapping(uint256 => mapping(address => ClaimDetails)) userClaims;
    }

    /**
     *  @notice Claim detail for a user claim.
     *
     *  @param lastClaimTimestamp    The timestamp at which the last token was claimed.
     *
     *  @param claimedBalance        The number of tokens claimed.
     *
     */
    struct ClaimDetails {
        uint256 lastClaimTimestamp;
        uint256 claimedBalance;
    }
}

interface IRestrictedRoyaltyV0 {
    
    function setDefaultRoyaltyInfo(address _royaltyRecipient, uint256 _royaltyBps) external;

    
    function setRoyaltyInfoForToken(
        uint256 tokenId,
        address recipient,
        uint256 bps
    ) external;
}

interface IRestrictedMetadataV0 {
    
    function setContractURI(string calldata _uri) external;
}

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

interface IAspenFactoryEventsV0 {
    // Primarily for the benefit of Etherscan verification
    event AspenImplementationDeployed(
        address indexed implementationAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion,
        string contractName
    );
}

interface ICedarImplementationVersionedV0 {
    
    function implementationVersion()
        external
        view
        returns (
            uint256 major,
            uint256 minor,
            uint256 patch
        );
}

interface IAspenVersionedV2 is IERC165Upgradeable {
    function minorVersion() external view returns (uint256 minor, uint256 patch);

    
    function implementationVersion()
        external
        view
        returns (
            uint256 major,
            uint256 minor,
            uint256 patch
        );

    
    function implementationInterfaceId() external view returns (string memory interfaceId);
}

// 

pragma solidity ^0.8;



interface ICedarSplitPaymentV0 {
    function getTotalReleased() external view returns (uint256);

    function getTotalReleased(IERC20Upgradeable token) external view returns (uint256);

    function getReleased(address account) external view returns (uint256);

    function getReleased(IERC20Upgradeable token, address account) external view returns (uint256);

    function releasePayment(address payable account) external;

    function releasePayment(IERC20Upgradeable token, address account) external;
}

// 
pragma solidity ^0.8;



/**
 *  Cedar's 'Drop' contracts are distribution mechanisms for tokens. The
 *  `DropERC721` contract is a distribution mechanism for ERC721 tokens.
 *
 *  A minter wallet (i.e. holder of `MINTER_ROLE`) can (lazy)mint 'n' tokens
 *  at once by providing a single base URI for all tokens being lazy minted.
 *  The URI for each of the 'n' tokens lazy minted is the provided base URI +
 *  `{tokenId}` of the respective token. (e.g. "ipsf://Qmece.../1").
 *
 *  A contract admin (i.e. holder of `DEFAULT_ADMIN_ROLE`) can create claim conditions
 *  with non-overlapping time windows, and accounts can claim the tokens according to
 *  restrictions defined in the claim condition that is active at the time of the transaction.
 */

interface ICedarNFTIssuanceV0 is IDropClaimConditionV0 {
    
    event TokensClaimed(
        uint256 indexed claimConditionIndex,
        address indexed claimer,
        address indexed receiver,
        uint256 startTokenId,
        uint256 quantityClaimed
    );

    
    event ClaimConditionsUpdated(ClaimCondition[] claimConditions);

    /**
     *  @notice Lets a contract admin (account with `DEFAULT_ADMIN_ROLE`) set claim conditions.
     *
     *  @param phases                Claim conditions in ascending order by `startTimestamp`.
     *  @param resetClaimEligibility Whether to reset `limitLastClaimTimestamp` and
     *                               `limitMerkleProofClaim` values when setting new
     *                               claim conditions.
     */
    function setClaimConditions(ClaimCondition[] calldata phases, bool resetClaimEligibility) external;

    /**
     *  @notice Lets an account claim a given quantity of NFTs.
     *
     *  @param receiver                       The receiver of the NFTs to claim.
     *  @param quantity                       The quantity of NFTs to claim.
     *  @param currency                       The currency in which to pay for the claim.
     *  @param pricePerToken                  The price per token to pay for the claim.
     *  @param proofs                         The proof of the claimer's inclusion in the merkle root allowlist
     *                                        of the claim conditions that apply.
     *  @param proofMaxQuantityPerTransaction (Optional) The maximum number of NFTs an address included in an
     *                                        allowlist can claim.
     */
    function claim(
        address receiver,
        uint256 quantity,
        address currency,
        uint256 pricePerToken,
        bytes32[] calldata proofs,
        uint256 proofMaxQuantityPerTransaction
    ) external payable;
}

// 

pragma solidity ^0.8;

interface IERC2981V0 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be payed in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

// 

pragma solidity ^0.8;



interface IERC1155V0 is IERC1155Upgradeable {}

interface IAspenFeaturesV0 is IERC165Upgradeable {
    // Marker interface to make an ERC165 clash less likely
    function isIAspenFeaturesV0() external pure returns (bool);

    // List of features that contract supports and may be passed to featureVersion
    function supportedFeatures() external pure returns (string[] memory features);
}

// 

pragma solidity ^0.8;

// See https://docs.openzeppelin.com/contracts/4.x/utilities#multicall
interface IMulticallableV0 {
    function multicall(bytes[] calldata data) external returns (bytes[] memory results);
}

interface IAspenSplitPaymentV1 is ICedarSplitPaymentV0 {
    function getPendingPayment(address account) external view returns (uint256);

    function getPendingPayment(IERC20Upgradeable token, address account) external view returns (uint256);
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

interface IRestrictedNFTIssuanceV2 is IDropClaimConditionV1 {
    
    event ClaimConditionsUpdated(IDropClaimConditionV1.ClaimCondition[] claimConditions);
    
    event TokensIssued(
        uint256 indexed startTokenId,
        address indexed issuer,
        address indexed receiver,
        uint256 quantity
    );
    
    event TokenIssued(uint256 indexed tokenId, address indexed issuer, address indexed receiver, string tokenURI);
    
    event TokenURIUpdated(uint256 indexed tokenId, address indexed updater, string tokenURI);

    /**
     *  @notice Lets a contract admin (account with `DEFAULT_ADMIN_ROLE`) set claim conditions.
     *
     *  @param phases                Claim conditions in ascending order by `startTimestamp`.
     *  @param resetClaimEligibility Whether to reset `limitLastClaimTimestamp` and
     *                               `limitMerkleProofClaim` values when setting new
     *                               claim conditions.
     */
    function setClaimConditions(ClaimCondition[] calldata phases, bool resetClaimEligibility) external;

    
    function issue(address receiver, uint256 quantity) external;

    
    /// Emits TokenIssued event.
    function issueWithTokenURI(address receiver, string calldata tokenURI) external;

    
    /// be generated from the baseURI. This function keeps tracks of whether the tokenURI or baseURI is fresher for a
    /// particular token. Emits "TokenURIUpdated" event.
    function setTokenURI(uint256 tokenId, string memory _tokenURI) external;
}

// 
pragma solidity ^0.8;

interface IRestrictedNFTLimitSupplyV0 {
    function setMaxTotalSupply(uint256 _maxTotalSupply) external;
}

// 

pragma solidity ^0.8;

interface INFTSupplyV0 {
    /**
     * @dev Total amount of tokens minted.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) external view returns (bool);
}

interface IERC721V1 is IERC721Upgradeable {
    function burn(uint256 tokenId) external;
}

interface IRestrictedLazyMintV0 {
    /**
     *  @notice Lets an account with `MINTER_ROLE` lazy mint 'n' NFTs.
     *          The URIs for each token is the provided `_baseURIForTokens` + `{tokenId}`.
     *
     *  @param amount           The amount of NFTs to lazy mint.
     *  @param baseURIForTokens The URI for the NFTs to lazy mint. If lazy minting
     *                           'delayed-reveal' NFTs, the is a URI for NFTs in the
     *                           un-revealed state.
     */
    function lazyMint(uint256 amount, string calldata baseURIForTokens) external;
}

interface IPublicAgreementV0 {
    function acceptTerms() external;

    function getTermsDetails()
        external
        view
        returns (
            string memory termsURI,
            uint8 termsVersion,
            bool termsActivated
        );

    function hasAcceptedTerms(address _address) external view returns (bool hasAccepted);

    function hasAcceptedTerms(address _address, uint8 _termsVersion) external view returns (bool hasAccepted);
}

interface IRestrictedAgreementV0 {
    function acceptTerms(address _acceptor) external;

    function setTermsActivation(bool _active) external;

    function setTermsURI(string calldata _termsURI) external;
}

interface IRestrictedRoyaltyV1 is IRestrictedRoyaltyV0 {
    
    event DefaultRoyalty(address newRoyaltyRecipient, uint256 newRoyaltyBps);
    
    event RoyaltyForToken(uint256 indexed tokenId, address royaltyRecipient, uint256 royaltyBps);
}

interface IOwnableEventV0 {
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

interface IRestrictedUpdateBaseURIV0 {
    /**
     *  @notice Lets a minter (account with `MINTER_ROLE`) update base URI
     */
    function updateBaseURI(uint256 baseURIIndex, string calldata _baseURIForTokens) external;
}

interface IRestrictedPausableV0 {
    
    function setClaimPauseStatus(bool _pause) external;
}

interface IRestrictedPrimarySaleV1 {
    
    function setPrimarySaleRecipient(address _saleRecipient) external;
}

interface IRestrictedMetadataV1 is IRestrictedMetadataV0 {
    
    event ContractURIUpdated(address indexed updater, string uri);
}

// 
pragma solidity ^0.8;

interface IRestrictedSFTLimitSupplyV0 {
    function setMaxTotalSupply(uint256 _tokenId, uint256 _maxTotalSupply) external;
}

interface IERC1155V1 is IERC1155Upgradeable {
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) external;

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) external;
}

// 

pragma solidity ^0.8;

interface ISFTSupplyV0 {
    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) external view returns (uint256);

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) external view returns (bool);

    /**
     * @dev Amount of unique tokens minted.
     */
    function getLargestTokenId() external view returns (uint256);
}

interface IRestrictedSFTIssuanceV2 is IDropClaimConditionV1 {
    
    event TokensIssued(uint256 indexed tokenId, address indexed claimer, address receiver, uint256 quantityClaimed);

    
    event ClaimConditionsUpdated(uint256 indexed tokenId, ClaimCondition[] claimConditions);

    /**
     *  @notice Lets a contract admin (account with `DEFAULT_ADMIN_ROLE`) set claim conditions.
     *
     *  @param tokenId               The token ID for which to set mint conditions.
     *  @param phases                Claim conditions in ascending order by `startTimestamp`.
     *  @param resetClaimEligibility Whether to reset `limitLastClaimTimestamp` and
     *                               `limitMerkleProofClaim` values when setting new
     *                               claim conditions.
     */
    function setClaimConditions(
        uint256 tokenId,
        ClaimCondition[] calldata phases,
        bool resetClaimEligibility
    ) external;

    /**
     *  @notice Lets an account with ISSUER_ROLE issue NFTs.
     *
     *  @param receiver                       The receiver of the NFTs to claim.
     *  @param tokenId                       The unique ID of the token to claim.
     *  @param quantity                       The quantity of NFTs to claim.
     */
    function issue(
        address receiver,
        uint256 tokenId,
        uint256 quantity
    ) external;
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// 

pragma solidity ^0.8;





// Events deployed by AspenDeployer directly (not by factories)
interface IAspenDeployerOwnEventsV1 {
    event AspenInterfaceDeployed(
        address indexed contractAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion,
        string implementationInterfaceId
    );
}

interface IAspenPaymentSplitterEventsV0 is IAspenFactoryEventsV0 {
    event AspenPaymentSplitterDeployment(
        address indexed contractAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion,
        address[] payees,
        uint256[] shares
    );
}

// 
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// 

// Generated by impl.ts. Will be overwritten.
// Filename: './BaseAspenPaymentSplitterV1.sol'

pragma solidity ^0.8.4;







/// Inherit from this base to implement introspection
abstract contract BaseAspenPaymentSplitterV1 is IAspenFeaturesV0, IAspenVersionedV2, IMulticallableV0, IAspenSplitPaymentV1 {
    function supportedFeatures() override public pure returns (string[] memory features) {
        features = new string[](4);
        features[0] = "IAspenFeatures.sol:IAspenFeaturesV0";
        features[1] = "IAspenVersioned.sol:IAspenVersionedV2";
        features[2] = "IMulticallable.sol:IMulticallableV0";
        features[3] = "splitpayment/ISplitPayment.sol:IAspenSplitPaymentV1";
    }

    /// This needs to be public to be callable from initialize via delegatecall
    function minorVersion() virtual override public pure returns (uint256 minor, uint256 patch);

    function implementationVersion() override public pure returns (uint256 major, uint256 minor, uint256 patch) {
        (minor, patch) = minorVersion();
        major = 1;
    }

    function implementationInterfaceId() virtual override public pure returns (string memory interfaceId) {
        interfaceId = "impl/IAspenPaymentSplitter.sol:IAspenPaymentSplitterV1";
    }

    function supportsInterface(bytes4 interfaceID) virtual override public view returns (bool) {
        return (interfaceID == type(IERC165Upgradeable).interfaceId) || ((interfaceID == type(IAspenFeaturesV0).interfaceId) || ((interfaceID == type(IAspenVersionedV2).interfaceId) || ((interfaceID == type(IMulticallableV0).interfaceId) || ((interfaceID == type(IAspenSplitPaymentV1).interfaceId) || (interfaceID == type(IAspenPaymentSplitterV1).interfaceId)))));
    }

    function isIAspenFeaturesV0() override public pure returns (bool) {
        return true;
    }
}

// 
pragma solidity ^0.8;

error PayeeSharesArrayMismatch(uint256 payeesLength, uint256 sharesLength);
error PayeeAlreadyExists(address payee);
error InvalidTotalShares(uint256 totalShares);

// 
// OpenZeppelin Contracts v4.4.1 (finance/PaymentSplitter.sol)

pragma solidity ^0.8.0;






/**
 * @title PaymentSplitter
 * @dev This contract allows to split Ether payments among a group of accounts. The sender does not need to be aware
 * that the Ether will be split in this way, since it is handled transparently by the contract.
 *
 * The split can be in equal parts or in any other arbitrary proportion. The way this is specified is by assigning each
 * account to a number of shares. Of all the Ether that this contract receives, each account will then be able to claim
 * an amount proportional to the percentage of total shares they were assigned.
 *
 * `PaymentSplitter` follows a _pull payment_ model. This means that payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {release}
 * function.
 *
 * NOTE: This contract assumes that ERC20 tokens will behave similarly to native tokens (Ether). Rebasing tokens, and
 * tokens that apply fees during transfers, are likely to not be supported as expected. If in doubt, we encourage you
 * to run tests before sending real value to this contract.
 */
contract PaymentSplitterUpgradeable is Initializable, ContextUpgradeable {
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event ERC20PaymentReleased(IERC20Upgradeable indexed token, address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalShares;
    uint256 private _totalReleased;

    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;
    address[] private _payees;

    mapping(IERC20Upgradeable => uint256) private _erc20TotalReleased;
    mapping(IERC20Upgradeable => mapping(address => uint256)) private _erc20Released;

    /**
     * @dev Creates an instance of `PaymentSplitter` where each account in `payees` is assigned the number of shares at
     * the matching position in the `shares` array.
     *
     * All addresses in `payees` must be non-zero. Both arrays must have the same non-zero length, and there must be no
     * duplicates in `payees`.
     */
    function __PaymentSplitter_init(address[] memory payees, uint256[] memory shares_) internal onlyInitializing {
        __PaymentSplitter_init_unchained(payees, shares_);
    }

    function __PaymentSplitter_init_unchained(address[] memory payees, uint256[] memory shares_) internal onlyInitializing {
        require(payees.length == shares_.length, "PaymentSplitter: payees and shares length mismatch");
        require(payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares_[i]);
        }
    }

    /**
     * @dev The Ether received will be logged with {PaymentReceived} events. Note that these events are not fully
     * reliable: it's possible for a contract to receive Ether without triggering this function. This only affects the
     * reliability of the events, and not the actual splitting of Ether.
     *
     * To learn more about this see the Solidity documentation for
     * https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function[fallback
     * functions].
     */
    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    /**
     * @dev Getter for the total shares held by payees.
     */
    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    /**
     * @dev Getter for the total amount of Ether already released.
     */
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    /**
     * @dev Getter for the total amount of `token` already released. `token` should be the address of an IERC20
     * contract.
     */
    function totalReleased(IERC20Upgradeable token) public view returns (uint256) {
        return _erc20TotalReleased[token];
    }

    /**
     * @dev Getter for the amount of shares held by an account.
     */
    function shares(address account) public view returns (uint256) {
        return _shares[account];
    }

    /**
     * @dev Getter for the amount of Ether already released to a payee.
     */
    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    /**
     * @dev Getter for the amount of `token` tokens already released to a payee. `token` should be the address of an
     * IERC20 contract.
     */
    function released(IERC20Upgradeable token, address account) public view returns (uint256) {
        return _erc20Released[token][account];
    }

    /**
     * @dev Getter for the address of the payee number `index`.
     */
    function payee(uint256 index) public view returns (address) {
        return _payees[index];
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     */
    function release(address payable account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = address(this).balance + totalReleased();
        uint256 payment = _pendingPayment(account, totalReceived, released(account));

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] += payment;
        _totalReleased += payment;

        AddressUpgradeable.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of `token` tokens they are owed, according to their
     * percentage of the total shares and their previous withdrawals. `token` must be the address of an IERC20
     * contract.
     */
    function release(IERC20Upgradeable token, address account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = token.balanceOf(address(this)) + totalReleased(token);
        uint256 payment = _pendingPayment(account, totalReceived, released(token, account));

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _erc20Released[token][account] += payment;
        _erc20TotalReleased[token] += payment;

        SafeERC20Upgradeable.safeTransfer(token, account, payment);
        emit ERC20PaymentReleased(token, account, payment);
    }

    /**
     * @dev internal logic for computing the pending payment of an `account` given the token historical balances and
     * already released amounts.
     */
    function _pendingPayment(
        address account,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) private view returns (uint256) {
        return (totalReceived * _shares[account]) / _totalShares - alreadyReleased;
    }

    /**
     * @dev Add a new payee to the contract.
     * @param account The address of the payee to add.
     * @param shares_ The number of shares owned by the payee.
     */
    function _addPayee(address account, uint256 shares_) private {
        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(_shares[account] == 0, "PaymentSplitter: account already has shares");

        _payees.push(account);
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        emit PayeeAdded(account, shares_);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[43] private __gap;
}

// 

pragma solidity ^0.8;



interface ICedarMinorVersionedV0 {
    function minorVersion() external view returns (uint256 minor, uint256 patch);
}

interface ICedarImplementationVersionedV1 is ICedarImplementationVersionedV0 {
    
    /// allows us to reliably emit the correct events
    function implementationInterfaceName() external view returns (string memory interfaceName);
}

interface ICedarImplementationVersionedV2 is ICedarImplementationVersionedV0 {
    
    function implementationInterfaceId() external view returns (string memory interfaceId);
}

interface ICedarNFTIssuanceV1 is ICedarNFTIssuanceV0 {
    
    function getActiveClaimConditions()
        external
        view
        returns (
            ClaimCondition memory condition,
            uint256 conditionId,
            uint256 walletMaxClaimCount,
            uint256 remainingSupply
        );

    
    function getUserClaimConditions(address _claimer)
        external
        view
        returns (
            uint256 conditionId,
            uint256 walletClaimedCount,
            uint256 lastClaimTimestamp,
            uint256 nextValidClaimTimestamp
        );

    
    function verifyClaim(
        uint256 _conditionId,
        address _claimer,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        bool verifyMaxQuantityPerTransaction
    ) external view;
}

interface IPublicNFTIssuanceV0 is IDropClaimConditionV0 {
    /**
     *  @notice Lets an account claim a given quantity of NFTs.
     *
     *  @param receiver                       The receiver of the NFTs to claim.
     *  @param quantity                       The quantity of NFTs to claim.
     *  @param currency                       The currency in which to pay for the claim.
     *  @param pricePerToken                  The price per token to pay for the claim.
     *  @param proofs                         The proof of the claimer's inclusion in the merkle root allowlist
     *                                        of the claim conditions that apply.
     *  @param proofMaxQuantityPerTransaction (Optional) The maximum number of NFTs an address included in an
     *                                        allowlist can claim.
     */
    function claim(
        address receiver,
        uint256 quantity,
        address currency,
        uint256 pricePerToken,
        bytes32[] calldata proofs,
        uint256 proofMaxQuantityPerTransaction
    ) external payable;

    
    function getActiveClaimConditions()
        external
        view
        returns (
            ClaimCondition memory condition,
            uint256 conditionId,
            uint256 walletMaxClaimCount,
            // FIXME[Silas]: maxTotalSupply and tokenSupply are the _opposite_ was here than in ICedarSFTIssuance.
            //   I think it is more logical to have maxTokenSupply *last* but I am changing here to account for the fact
            //   that the actual implementation had these two swapped!
            uint256 maxTotalSupply,
            uint256 tokenSupply,
            bool isClaimPaused
        );

    
    function getUserClaimConditions(address _claimer)
        external
        view
        returns (
            uint256 conditionId,
            uint256 walletClaimedCount,
            uint256 walletClaimedCountInPhase,
            uint256 lastClaimTimestamp,
            uint256 nextValidClaimTimestamp
        );

    
    function verifyClaim(
        uint256 _conditionId,
        address _claimer,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        bool verifyMaxQuantityPerTransaction
    ) external view;
}

interface IPublicNFTIssuanceV2 is IDropClaimConditionV1 {
    
    event TokensClaimed(
        uint256 indexed claimConditionIndex,
        address indexed claimer,
        address indexed receiver,
        uint256 startTokenId,
        uint256 quantityClaimed,
        bytes32 phaseId
    );

    /**
     *  @notice Lets an account claim a given quantity of NFTs.
     *
     *  @param receiver                       The receiver of the NFTs to claim.
     *  @param quantity                       The quantity of NFTs to claim.
     *  @param currency                       The currency in which to pay for the claim.
     *  @param pricePerToken                  The price per token to pay for the claim.
     *  @param proofs                         The proof of the claimer's inclusion in the merkle root allowlist
     *                                        of the claim conditions that apply.
     *  @param proofMaxQuantityPerTransaction (Optional) The maximum number of NFTs an address included in an
     *                                        allowlist can claim.
     */
    function claim(
        address receiver,
        uint256 quantity,
        address currency,
        uint256 pricePerToken,
        bytes32[] calldata proofs,
        uint256 proofMaxQuantityPerTransaction
    ) external payable;

    
    function getActiveClaimConditions()
        external
        view
        returns (
            ClaimCondition memory condition,
            uint256 conditionId,
            uint256 walletMaxClaimCount,
            uint256 tokenSupply,
            uint256 maxTotalSupply,
            bool isClaimPaused
        );

    
    function getUserClaimConditions(address _claimer)
        external
        view
        returns (
            uint256 conditionId,
            uint256 walletClaimedCount,
            uint256 walletClaimedCountInPhase,
            uint256 lastClaimTimestamp,
            uint256 nextValidClaimTimestamp
        );

    
    function getClaimConditionById(uint256 _conditionId) external view returns (ClaimCondition memory condition);

    
    function verifyClaim(
        uint256 _conditionId,
        address _claimer,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        bool verifyMaxQuantityPerTransaction
    ) external view;
}

interface IRestrictedNFTIssuanceV0 is IDropClaimConditionV0 {
    /**
     *  @notice Lets a contract admin (account with `DEFAULT_ADMIN_ROLE`) set claim conditions.
     *
     *  @param phases                Claim conditions in ascending order by `startTimestamp`.
     *  @param resetClaimEligibility Whether to reset `limitLastClaimTimestamp` and
     *                               `limitMerkleProofClaim` values when setting new
     *                               claim conditions.
     */
    function setClaimConditions(ClaimCondition[] calldata phases, bool resetClaimEligibility) external;

    
    function issue(address receiver, uint256 quantity) external;

    
    /// Emits TokenIssued event.
    function issueWithTokenURI(address receiver, string calldata tokenURI) external;

    
    /// be generated from the baseURI. This function keeps tracks of whether the tokenURI or baseURI is fresher for a
    /// particular token. Emits TokenURIUpdated event.
    function setTokenURI(uint256 tokenId, string memory _tokenURI) external;
}

interface IRestrictedNFTIssuanceV3 is IRestrictedNFTIssuanceV2 {
    
    /// be generated from the baseURI. This function keeps tracks of whether the tokenURI or baseURI is fresher for a
    /// particular token. Emits a "TokenURIUpdated" and a "PermanentURI" event.
    function setPermantentTokenURI(uint256 tokenId, string memory _tokenURI) external;

    
    event PermanentURI(string _value, uint256 indexed _id);
}

interface IRestrictedNFTLimitSupplyV1 is IRestrictedNFTLimitSupplyV0 {
    
    event MaxTotalSupplyUpdated(uint256 maxTotalSupply);
}

interface INFTSupplyV1 is INFTSupplyV0 {
    
    function getSmallestTokenId() external view returns (uint8);
}

interface IERC721V2 is IERC721V1 {
    function name() external returns (string memory);

    function symbol() external returns (string memory);
}

// 

pragma solidity ^0.8;

// Note: So that it can be included in Delegated logic contract
interface IRestrictedERC4906V0 {
    
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFT.
    event MetadataUpdate(uint256 _tokenId);

    
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFTs.
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
}

interface IRestrictedLazyMintV1 is IRestrictedLazyMintV0 {
    
    event TokensLazyMinted(uint256 startTokenId, uint256 endTokenId, string baseURI);
}

interface IPublicAgreementV1 is IPublicAgreementV0 {
    
    event TermsAccepted(string termsURI, uint8 termsVersion, address indexed acceptor);
}

interface IRestrictedAgreementV1 is IRestrictedAgreementV0 {
    
    event TermsAcceptedForAddress(string termsURI, uint8 termsVersion, address indexed acceptor, address caller);
    
    event TermsActivationStatusUpdated(bool isActivated);
    
    event TermsUpdated(string termsURI, uint8 termsVersion);
}

interface IDelegatedAgreementV0 {
    
    event TermsWithSignatureAccepted(string termsURI, uint8 termsVersion, address indexed acceptor, bytes signature);

    function acceptTerms(address _acceptor, bytes calldata _signature) external;

    function batchAcceptTerms(address[] calldata _acceptors) external;
}

interface IPublicRoyaltyV0 is IERC2981V0 {
    struct RoyaltyInfo {
        address recipient;
        uint256 bps;
    }

    
    function getDefaultRoyaltyInfo() external view returns (address, uint16);

    
    function getRoyaltyInfoForToken(uint256 tokenId) external view returns (address, uint16);
}

interface IRestrictedRoyaltyV2 is IRestrictedRoyaltyV1 {
    
    event OperatorFilterStatusUpdated(bool enabled);

    
    function setOperatorFiltererStatus(bool _enabled) external;
}

interface IPublicOwnableV0 is IOwnableEventV0 {
    
    function owner() external view returns (address);
}

interface IRestrictedOwnableV0 is IOwnableEventV0 {
    
    function setOwner(address _newOwner) external;
}

interface IPublicUpdateBaseURIV0 {
    /**
     *  @dev Gets the base URI indices
     */
    function getBaseURIIndices() external view returns (uint256[] memory);
}

interface IRestrictedUpdateBaseURIV1 is IRestrictedUpdateBaseURIV0 {
    
    event BaseURIUpdated(uint256 baseURIIndex, string baseURI);
}

interface IRestrictedPausableV1 is IRestrictedPausableV0 {
    
    event ClaimPauseStatusUpdated(bool pauseStatus);
}

interface IAspenNFTMetadataV1 {
    
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

interface IPublicPrimarySaleV1 {
    
    function primarySaleRecipient() external view returns (address);
}

interface IRestrictedPrimarySaleV2 is IRestrictedPrimarySaleV1 {
    
    event PrimarySaleRecipientUpdated(address indexed recipient);
}

// 
pragma solidity ^0.8;

interface IPublicPlatformFeeV0 {
    
    function getPlatformFeeInfo() external view returns (address, uint16);
}

interface IRestrictedPlatformFeeV0 {
    
    event PlatformFeeInfoUpdated(address platformFeeRecipient, uint256 platformFeeBps);

    
    function setPlatformFeeInfo(address _platformFeeRecipient, uint256 _platformFeeBps) external;
}

interface IPublicMetadataV0 {
    
    function contractURI() external view returns (string memory);
}

interface IRestrictedMetadataV2 is IRestrictedMetadataV1 {
    
    function setTokenNameAndSymbol(string calldata _name, string calldata _symbol) external;

    
    event TokenNameAndSymbolUpdated(address indexed updater, string name, string symbol);
}

interface IRestrictedSFTLimitSupplyV1 is IRestrictedSFTLimitSupplyV0 {
    
    event MaxTotalSupplyUpdated(uint256 tokenId, uint256 maxTotalSupply);
}

interface IERC1155V2 is IERC1155V1 {
    function name() external returns (string memory);

    function symbol() external returns (string memory);
}

interface IERC1155SupplyV0 is IERC1155V0 {
    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) external view returns (uint256);

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) external view returns (bool);
}

interface ISFTSupplyV1 is ISFTSupplyV0 {
    
    function getSmallestTokenId() external view returns (uint8);
}

interface IAspenSFTMetadataV1 {
    
    function uri(uint256 _tokenId) external view returns (string memory);
}

// 
pragma solidity ^0.8;



/**
 *  Cedar's 'Drop' contracts are distribution mechanisms for tokens. The
 *  `DropERC721` contract is a distribution mechanism for ERC721 tokens.
 *
 *  A minter wallet (i.e. holder of `MINTER_ROLE`) can (lazy)mint 'n' tokens
 *  at once by providing a single base URI for all tokens being lazy minted.
 *  The URI for each of the 'n' tokens lazy minted is the provided base URI +
 *  `{tokenId}` of the respective token. (e.g. "ipsf://Qmece.../1").
 *
 *  A contract admin (i.e. holder of `DEFAULT_ADMIN_ROLE`) can create claim conditions
 *  with non-overlapping time windows, and accounts can claim the tokens according to
 *  restrictions defined in the claim condition that is active at the time of the transaction.
 */

interface ICedarSFTIssuanceV0 is IDropClaimConditionV0 {
    
    event TokensClaimed(
        uint256 indexed claimConditionIndex,
        uint256 indexed tokenId,
        address indexed claimer,
        address receiver,
        uint256 quantityClaimed
    );

    
    event TokensIssued(uint256 indexed tokenId, address indexed claimer, address receiver, uint256 quantityClaimed);

    
    event ClaimConditionsUpdated(uint256 indexed tokenId, ClaimCondition[] claimConditions);

    /**
     *  @notice Lets a contract admin (account with `DEFAULT_ADMIN_ROLE`) set claim conditions.
     *
     *  @param tokenId               The token ID for which to set mint conditions.
     *  @param phases                Claim conditions in ascending order by `startTimestamp`.
     *  @param resetClaimEligibility Whether to reset `limitLastClaimTimestamp` and
     *                               `limitMerkleProofClaim` values when setting new
     *                               claim conditions.
     */
    function setClaimConditions(
        uint256 tokenId,
        ClaimCondition[] calldata phases,
        bool resetClaimEligibility
    ) external;

    /**
     *  @notice Lets an account claim a given quantity of NFTs.
     *
     *  @param receiver                       The receiver of the NFTs to claim.
     *  @param tokenId                       The unique ID of the token to claim.
     *  @param quantity                       The quantity of NFTs to claim.
     *  @param currency                       The currency in which to pay for the claim.
     *  @param pricePerToken                  The price per token to pay for the claim.
     *  @param proofs                         The proof of the claimer's inclusion in the merkle root allowlist
     *                                        of the claim conditions that apply.
     *  @param proofMaxQuantityPerTransaction (Optional) The maximum number of NFTs an address included in an
     *                                        allowlist can claim.
     */
    function claim(
        address receiver,
        uint256 tokenId,
        uint256 quantity,
        address currency,
        uint256 pricePerToken,
        bytes32[] calldata proofs,
        uint256 proofMaxQuantityPerTransaction
    ) external payable;

    /**
     *  @notice Lets an account with ISSUER_ROLE issue NFTs.
     *
     *  @param receiver                       The receiver of the NFTs to claim.
     *  @param tokenId                       The unique ID of the token to claim.
     *  @param quantity                       The quantity of NFTs to claim.
     */
    function issue(
        address receiver,
        uint256 tokenId,
        uint256 quantity
    ) external;
}

interface IPublicSFTIssuanceV0 is IDropClaimConditionV0 {
    /**
     *  @notice Lets an account claim a given quantity of NFTs.
     *
     *  @param receiver                       The receiver of the NFTs to claim.
     *  @param tokenId                       The unique ID of the token to claim.
     *  @param quantity                       The quantity of NFTs to claim.
     *  @param currency                       The currency in which to pay for the claim.
     *  @param pricePerToken                  The price per token to pay for the claim.
     *  @param proofs                         The proof of the claimer's inclusion in the merkle root allowlist
     *                                        of the claim conditions that apply.
     *  @param proofMaxQuantityPerTransaction (Optional) The maximum number of NFTs an address included in an
     *                                        allowlist can claim.
     */
    function claim(
        address receiver,
        uint256 tokenId,
        uint256 quantity,
        address currency,
        uint256 pricePerToken,
        bytes32[] calldata proofs,
        uint256 proofMaxQuantityPerTransaction
    ) external payable;

    
    function getActiveClaimConditions(uint256 _tokenId)
        external
        view
        returns (
            ClaimCondition memory condition,
            uint256 conditionId,
            uint256 walletMaxClaimCount,
            uint256 tokenSupply,
            uint256 maxTotalSupply,
            bool isClaimPaused
        );

    
    function getUserClaimConditions(uint256 _tokenId, address _claimer)
        external
        view
        returns (
            uint256 conditionId,
            uint256 walletClaimedCount,
            uint256 walletClaimedCountInPhase,
            uint256 lastClaimTimestamp,
            uint256 nextValidClaimTimestamp
        );

    
    function verifyClaim(
        uint256 _conditionId,
        address _claimer,
        uint256 _tokenId,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        bool verifyMaxQuantityPerTransaction
    ) external view;
}

interface IPublicSFTIssuanceV2 is IDropClaimConditionV1 {
    
    event TokensClaimed(
        uint256 indexed claimConditionIndex,
        uint256 indexed tokenId,
        address indexed claimer,
        address receiver,
        uint256 quantityClaimed,
        bytes32 phaseId
    );

    /**
     *  @notice Lets an account claim a given quantity of NFTs.
     *
     *  @param receiver                       The receiver of the NFTs to claim.
     *  @param tokenId                       The unique ID of the token to claim.
     *  @param quantity                       The quantity of NFTs to claim.
     *  @param currency                       The currency in which to pay for the claim.
     *  @param pricePerToken                  The price per token to pay for the claim.
     *  @param proofs                         The proof of the claimer's inclusion in the merkle root allowlist
     *                                        of the claim conditions that apply.
     *  @param proofMaxQuantityPerTransaction (Optional) The maximum number of NFTs an address included in an
     *                                        allowlist can claim.
     */
    function claim(
        address receiver,
        uint256 tokenId,
        uint256 quantity,
        address currency,
        uint256 pricePerToken,
        bytes32[] calldata proofs,
        uint256 proofMaxQuantityPerTransaction
    ) external payable;

    
    function getActiveClaimConditions(uint256 _tokenId)
        external
        view
        returns (
            ClaimCondition memory condition,
            uint256 conditionId,
            uint256 walletMaxClaimCount,
            uint256 tokenSupply,
            uint256 maxTotalSupply,
            bool isClaimPaused
        );

    
    function getUserClaimConditions(uint256 _tokenId, address _claimer)
        external
        view
        returns (
            uint256 conditionId,
            uint256 walletClaimedCount,
            uint256 walletClaimedCountInPhase,
            uint256 lastClaimTimestamp,
            uint256 nextValidClaimTimestamp
        );

    
    function getClaimConditionById(uint256 _tokenId, uint256 _conditionId)
        external
        view
        returns (ClaimCondition memory condition);

    
    function verifyClaim(
        uint256 _conditionId,
        address _claimer,
        uint256 _tokenId,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        bool verifyMaxQuantityPerTransaction
    ) external view;
}

interface IRestrictedSFTIssuanceV0 is IDropClaimConditionV0 {
    /**
     *  @notice Lets a contract admin (account with `DEFAULT_ADMIN_ROLE`) set claim conditions.
     *
     *  @param tokenId               The token ID for which to set mint conditions.
     *  @param phases                Claim conditions in ascending order by `startTimestamp`.
     *  @param resetClaimEligibility Whether to reset `limitLastClaimTimestamp` and
     *                               `limitMerkleProofClaim` values when setting new
     *                               claim conditions.
     */
    function setClaimConditions(
        uint256 tokenId,
        ClaimCondition[] calldata phases,
        bool resetClaimEligibility
    ) external;

    /**
     *  @notice Lets an account with ISSUER_ROLE issue NFTs.
     *
     *  @param receiver                       The receiver of the NFTs to claim.
     *  @param tokenId                       The unique ID of the token to claim.
     *  @param quantity                       The quantity of NFTs to claim.
     */
    function issue(
        address receiver,
        uint256 tokenId,
        uint256 quantity
    ) external;
}

interface IRestrictedSFTIssuanceV3 is IRestrictedSFTIssuanceV2 {
    
    /// be generated from the baseURI. This function keeps tracks of whether the tokenURI or baseURI is fresher for a
    /// particular token. Emits a "TokenURIUpdated" and a "PermanentURI" event.
    function setPermantentTokenURI(uint256 tokenId, string memory _tokenURI) external;

    
    event PermanentURI(string _value, uint256 indexed _id);

    
    /// be generated from the baseURI. This function keeps tracks of whether the tokenURI or baseURI is fresher for a
    /// particular token. Emits TokenURIUpdated event.
    function setTokenURI(uint256 tokenId, string memory _tokenURI) external;

    
    event TokenURIUpdated(uint256 indexed tokenId, address indexed updater, string tokenURI);
}
// 

pragma solidity ^0.8;






contract AspenPaymentSplitterFactory is Ownable, IAspenPaymentSplitterEventsV0, ICedarImplementationVersionedV0 {
    AspenPaymentSplitter public implementation;

    struct EventParams {
        address contractAddress;
        uint256 majorVersion;
        uint256 minorVersion;
        uint256 patchVersion;
        address[] payees;
        uint256[] shares;
    }

    constructor() {
        // Deploy the implementation contract and set implementationAddress
        implementation = new AspenPaymentSplitter();
        address[] memory recipients = new address[](1);
        recipients[0] = msg.sender;
        uint256[] memory shares = new uint256[](1);
        shares[0] = 10000;

        implementation.initialize(recipients, shares);

        (uint256 major, uint256 minor, uint256 patch) = implementation.implementationVersion();
        emit AspenImplementationDeployed(address(implementation), major, minor, patch, "AspenPaymentSplitter");
    }

    function emitEvent(EventParams memory params) private {
        emit AspenPaymentSplitterDeployment(
            params.contractAddress,
            params.majorVersion,
            params.minorVersion,
            params.patchVersion,
            params.payees,
            params.shares
        );
    }

    function deploy(address[] memory payees, uint256[] memory shares_)
        external
        onlyOwner
        returns (AspenPaymentSplitter)
    {
        // newClone = PaymentSplitter(Clones.clone(address((implementation)));
        AspenPaymentSplitter newClone = new AspenPaymentSplitter();
        newClone.initialize(payees, shares_);

        (uint256 major, uint256 minor, uint256 patch) = newClone.implementationVersion();

        EventParams memory params;
        params.contractAddress = address(newClone);
        params.majorVersion = major;
        params.minorVersion = minor;
        params.patchVersion = patch;
        params.payees = payees;
        params.shares = shares_;

        emitEvent(params);
        return newClone;
    }

    function implementationVersion()
        external
        view
        override
        returns (
            uint256 major,
            uint256 minor,
            uint256 patch
        )
    {
        return implementation.implementationVersion();
    }
}

// 

pragma solidity ^0.8;

//  ==========  External imports    ==========






contract AspenPaymentSplitter is PaymentSplitterUpgradeable, BaseAspenPaymentSplitterV1 {
    mapping(address => bool) private payeeExists;

    function initialize(address[] memory _payees, uint256[] memory _shares) external initializer {
        if (_payees.length != _shares.length) revert PayeeSharesArrayMismatch(_payees.length, _shares.length);
        uint256 totalShares = 0;
        for (uint256 i = 0; i < _shares.length; i++) {
            totalShares = totalShares + _shares[i];

            if (payeeExists[_payees[i]] == true) revert PayeeAlreadyExists(_payees[i]);
            payeeExists[_payees[i]] = true;
        }

        if (totalShares != 10000) revert InvalidTotalShares(totalShares);

        __PaymentSplitter_init(_payees, _shares);
    }

    /// ==================================
    /// ========== Relase logic ==========
    /// ==================================
    
    ///     total shares and their previous withdrawals.
    
    function releasePayment(address payable account) external override {
        release(account);
    }

    
    ///     percentage of the total shares and their previous withdrawals. `token` must be the address of an IERC20
    ///     contract.
    
    
    function releasePayment(IERC20Upgradeable token, address account) external override {
        release(token, account);
    }

    /// ======================================
    /// ========== Getter functions ==========
    /// ======================================
    
    function getTotalReleased() external view override returns (uint256) {
        return totalReleased();
    }

    
    
    function getTotalReleased(IERC20Upgradeable token) external view override returns (uint256) {
        return totalReleased(token);
    }

    
    
    function getReleased(address account) external view override returns (uint256) {
        return released(account);
    }

    
    
    
    function getReleased(IERC20Upgradeable token, address account) external view override returns (uint256) {
        return released(token, account);
    }

    
    
    function getPendingPayment(address account) external view override returns (uint256) {
        if (shares(account) == 0) return 0;
        uint256 totalReceived = address(this).balance + totalReleased();

        return _getPendingPayment(account, totalReceived, released(account));
    }

    
    
    
    function getPendingPayment(IERC20Upgradeable token, address account) external view override returns (uint256) {
        if (shares(account) == 0) return 0;
        uint256 totalReceived = token.balanceOf(address(this)) + totalReleased(token);

        return _getPendingPayment(account, totalReceived, released(token, account));
    }

    
    ///     already released amounts.
    ///     private logic taken from _pendingPayment() function from openzeppelin/contracts-upgradeable/finance/PaymentSplitterUpgradeable.sol
    function _getPendingPayment(
        address account,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) internal view returns (uint256) {
        return (totalReceived * shares(account)) / totalShares() - alreadyReleased;
    }

    /// ======================================
    /// =========== Miscellaneous ============
    /// ======================================
    
    function multicall(bytes[] calldata data) external virtual override returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), data[i]);
        }
        return results;
    }

    
    ///         provided for completeness but not designed to be the point of dispatch
    function minorVersion() public pure override returns (uint256 minor, uint256 patch) {
        minor = 0;
        patch = 0;
    }
}

// Update this interface by bumping the version then updating in-place.
// Previous versions will be immortalised in manifest but do not need to be kept around to clutter
// solidity code
interface IAspenDeployerV1 is IAspenDeployerOwnEventsV1, IAspenVersionedV2 {
    function deployAspenERC1155Drop(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _saleRecipient,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        string memory _userAgreement,
        uint128 _platformFeeBps,
        address _platformFeeRecipient
    ) external payable returns (IAspenERC1155DropV1);

    function deployAspenERC721Drop(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        address[] memory _trustedForwarders,
        address _saleRecipient,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        string memory _userAgreement,
        uint128 _platformFeeBps,
        address _platformFeeRecipient
    ) external payable returns (IAspenERC721DropV1);

    function deployAspenPaymentSplitter(address[] memory payees, uint256[] memory shares)
        external
        returns (IAspenPaymentSplitterV1);

    function getDeploymentFeeDetails() external view returns (uint256 _deploymentFee, address _feeReceiver);

    /// Versions
    function aspenERC721DropVersion()
        external
        view
        returns (
            uint256 major,
            uint256 minor,
            uint256 patch
        );

    function aspenERC1155DropVersion()
        external
        view
        returns (
            uint256 major,
            uint256 minor,
            uint256 patch
        );

    function aspenPaymentSplitterVersion()
        external
        view
        returns (
            uint256 major,
            uint256 minor,
            uint256 patch
        );

    /// Features

    function aspenERC721DropFeatures() external view returns (string[] memory features);

    function aspenERC1155DropFeatures() external view returns (string[] memory features);

    function aspenPaymentSplitterFeatures() external view returns (string[] memory features);
}

interface ICedarFactoryEventsV0 {
    // Primarily for the benefit of Etherscan verification
    event AspenImplementationDeployed(
        address indexed implementationAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion,
        string contractName
    );
}

/// Factory specific events (emitted by factories, but included in ICedarDeployer interfaces because they can be
/// expected to be emitted on transactions that call the deploy functions

interface IAspenERC721PremintFactoryEventsV1 is IAspenFactoryEventsV0 {
    event AspenERC721PremintDeployment(
        address indexed contractAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion,
        address adminAddress,
        string name,
        string symbol,
        uint256 maxLimit,
        string userAgreement,
        string baseURI
    );
}

interface IAspenERC721DropFactoryEventsV0 is IAspenFactoryEventsV0 {
    event AspenERC721DropV2Deployment(
        address indexed contractAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion
    );
}

interface IAspenERC1155DropFactoryEventsV0 is IAspenFactoryEventsV0 {
    event AspenERC1155DropV2Deployment(
        address indexed contractAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion
    );
}

interface IDropFactoryEventsV0 is IAspenFactoryEventsV0 {
    
    ///     Emitted when the `deploy()` from Factory contracts is called
    event DropContractDeployment(
        address indexed contractAddress,
        uint256 indexed majorVersion,
        uint256 indexed minorVersion,
        uint256 patchVersion,
        address adminAddress,
        string name,
        string symbol,
        //        string contractURI,
        //        address[] trustedForwarders,
        address saleRecipient,
        address defaultRoyaltyRecipient,
        uint128 defaultRoyaltyBps,
        string userAgreement,
        uint128 platformFeeBps,
        address platformFeeRecipient
    );
}

// 
// OpenZeppelin Contracts v4.4.1 (proxy/Clones.sol)

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
library Clones {
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// 

pragma solidity ^0.8;



interface ICedarFeaturesV0 is IERC165Upgradeable {
    // Marker interface to make an ERC165 clash less likely
    function isICedarFeaturesV0() external pure returns (bool);

    // List of features that contract supports and may be passed to featureVersion
    function supportedFeatures() external pure returns (string[] memory features);
}

interface ICedarVersionedV0 is ICedarImplementationVersionedV0, ICedarMinorVersionedV0, IERC165Upgradeable {}

interface ICedarVersionedV1 is ICedarImplementationVersionedV1, ICedarMinorVersionedV0, IERC165Upgradeable {}

interface ICedarVersionedV2 is ICedarImplementationVersionedV2, ICedarMinorVersionedV0, IERC165Upgradeable {}

// 

pragma solidity ^0.8;






interface IAspenPaymentSplitterV1 is IAspenFeaturesV0, IAspenVersionedV2, IMulticallableV0, IAspenSplitPaymentV1 {}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// 

pragma solidity ^0.8;





















// Each AspenERC721 contract should implement a maximal version of the interfaces it supports and should itself carry
// the version major version suffix, in this case CedarERC721V0

interface IAspenERC721DropV1 is
    IAspenFeaturesV0,
    IAspenVersionedV2,
    IMulticallableV0,
    IPublicNFTIssuanceV2,
    INFTSupplyV1,
    // NOTE: keep this standard interfaces around to generate supportsInterface
    IERC721V2,
    IERC2981V0,
    IRestrictedERC4906V0,
    // NOTE: keep this standard interfaces around to generate supportsInterface ˆˆ
    IPublicRoyaltyV0,
    IPublicUpdateBaseURIV0,
    IPublicMetadataV0,
    IPublicOwnableV0,
    IAspenNFTMetadataV1,
    IPublicAgreementV1,
    IPublicPrimarySaleV1,
    IPublicPlatformFeeV0,
    IRestrictedAgreementV1,
    IDelegatedAgreementV0,
    IRestrictedNFTIssuanceV3,
    IRestrictedLazyMintV1,
    IRestrictedPausableV1,
    IRestrictedMetadataV2,
    IRestrictedUpdateBaseURIV1,
    IRestrictedRoyaltyV2,
    IRestrictedPrimarySaleV2,
    IRestrictedNFTLimitSupplyV1,
    IRestrictedOwnableV0,
    IRestrictedPlatformFeeV0
{

}

// 

pragma solidity ^0.8;





















interface IAspenERC1155DropV1 is
    IAspenFeaturesV0,
    IAspenVersionedV2,
    IMulticallableV0,
    IPublicSFTIssuanceV2,
    ISFTSupplyV1,
    // NOTE: keep this standard interfaces around to generate supportsInterface
    IERC1155V2,
    IERC2981V0,
    IRestrictedERC4906V0,
    // NOTE: keep this standard interfaces around to generate supportsInterface ˆˆ
    IPublicRoyaltyV0,
    IPublicUpdateBaseURIV0,
    IPublicMetadataV0,
    IPublicOwnableV0,
    IAspenSFTMetadataV1,
    IPublicAgreementV1,
    IPublicPrimarySaleV1,
    IPublicPlatformFeeV0,
    IRestrictedAgreementV1,
    IDelegatedAgreementV0,
    IRestrictedSFTIssuanceV3,
    IRestrictedLazyMintV1,
    IRestrictedPausableV1,
    IRestrictedMetadataV2,
    IRestrictedUpdateBaseURIV1,
    IRestrictedRoyaltyV2,
    IRestrictedPrimarySaleV2,
    IRestrictedSFTLimitSupplyV1,
    IRestrictedOwnableV0,
    IRestrictedPlatformFeeV0
{}

interface ICedarNFTIssuanceV2 is ICedarNFTIssuanceV1 {
    event TokensIssued(
        uint256 indexed startTokenId,
        address indexed issuer,
        address indexed receiver,
        uint256 quantity
    );

    event TokenIssued(uint256 indexed tokenId, address indexed issuer, address indexed receiver, string tokenURI);

    event TokenURIUpdated(uint256 indexed tokenId, address indexed updater, string tokenURI);

    
    function issue(address receiver, uint256 quantity) external;

    
    /// Emits TokenIssued event.
    function issueWithTokenURI(address receiver, string calldata tokenURI) external;

    
    /// be generated from the baseURI. This function keeps tracks of whether the tokenURI or baseURI is fresher for a
    /// particular token. Emits TokenURIUpdated event.
    function setTokenURI(uint256 tokenId, string memory _tokenURI) external;
}

interface ICedarNFTIssuanceV3 is ICedarNFTIssuanceV0 {
    event TokensIssued(
        uint256 indexed startTokenId,
        address indexed issuer,
        address indexed receiver,
        uint256 quantity
    );

    event TokenIssued(uint256 indexed tokenId, address indexed issuer, address indexed receiver, string tokenURI);

    event TokenURIUpdated(uint256 indexed tokenId, address indexed updater, string tokenURI);

    
    function issue(address receiver, uint256 quantity) external;

    
    /// Emits TokenIssued event.
    function issueWithTokenURI(address receiver, string calldata tokenURI) external;

    
    /// be generated from the baseURI. This function keeps tracks of whether the tokenURI or baseURI is fresher for a
    /// particular token. Emits TokenURIUpdated event.
    function setTokenURI(uint256 tokenId, string memory _tokenURI) external;

    
    function getActiveClaimConditions()
        external
        view
        returns (
            ClaimCondition memory condition,
            uint256 conditionId,
            uint256 walletMaxClaimCount,
            uint256 remainingSupply,
            bool isClaimPaused
        );

    
    function getUserClaimConditions(address _claimer)
        external
        view
        returns (
            uint256 conditionId,
            uint256 walletClaimedCount,
            uint256 walletClaimedCountInPhase,
            uint256 lastClaimTimestamp,
            uint256 nextValidClaimTimestamp
        );

    
    function verifyClaim(
        uint256 _conditionId,
        address _claimer,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        bool verifyMaxQuantityPerTransaction
    ) external view;
}

interface ICedarNFTIssuanceV4 is ICedarNFTIssuanceV0 {
    event TokensIssued(
        uint256 indexed startTokenId,
        address indexed issuer,
        address indexed receiver,
        uint256 quantity
    );

    event TokenIssued(uint256 indexed tokenId, address indexed issuer, address indexed receiver, string tokenURI);

    event TokenURIUpdated(uint256 indexed tokenId, address indexed updater, string tokenURI);

    
    function issue(address receiver, uint256 quantity) external;

    
    /// Emits TokenIssued event.
    function issueWithTokenURI(address receiver, string calldata tokenURI) external;

    
    /// be generated from the baseURI. This function keeps tracks of whether the tokenURI or baseURI is fresher for a
    /// particular token. Emits TokenURIUpdated event.
    function setTokenURI(uint256 tokenId, string memory _tokenURI) external;

    
    function getActiveClaimConditions()
        external
        view
        returns (
            ClaimCondition memory condition,
            uint256 conditionId,
            uint256 walletMaxClaimCount,
            uint256 tokenSupply,
            uint256 maxTotalSupply,
            bool isClaimPaused
        );

    
    function getUserClaimConditions(address _claimer)
        external
        view
        returns (
            uint256 conditionId,
            uint256 walletClaimedCount,
            uint256 walletClaimedCountInPhase,
            uint256 lastClaimTimestamp,
            uint256 nextValidClaimTimestamp
        );

    
    function verifyClaim(
        uint256 _conditionId,
        address _claimer,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        bool verifyMaxQuantityPerTransaction
    ) external view;
}

interface IPublicNFTIssuanceV1 is IPublicNFTIssuanceV0 {
    
    event TokensClaimed(
        uint256 indexed claimConditionIndex,
        address indexed claimer,
        address indexed receiver,
        uint256 startTokenId,
        uint256 quantityClaimed
    );
}

interface IRestrictedNFTIssuanceV1 is IRestrictedNFTIssuanceV0 {
    
    event ClaimConditionsUpdated(IDropClaimConditionV0.ClaimCondition[] claimConditions);
    
    event TokensIssued(
        uint256 indexed startTokenId,
        address indexed issuer,
        address indexed receiver,
        uint256 quantity
    );
    
    event TokenIssued(uint256 indexed tokenId, address indexed issuer, address indexed receiver, string tokenURI);
    
    event TokenURIUpdated(uint256 indexed tokenId, address indexed updater, string tokenURI);
}

// 

pragma solidity ^0.8;



interface IERC721V0 is IERC721Upgradeable {}

// 

pragma solidity ^0.8.4;

interface ICedarLazyMintV0 {
    
    event TokensLazyMinted(uint256 startTokenId, uint256 endTokenId, string baseURI);

    /**
     *  @notice Lets an account with `MINTER_ROLE` lazy mint 'n' NFTs.
     *          The URIs for each token is the provided `_baseURIForTokens` + `{tokenId}`.
     *
     *  @param amount           The amount of NFTs to lazy mint.
     *  @param baseURIForTokens The URI for the NFTs to lazy mint. If lazy minting
     *                           'delayed-reveal' NFTs, the is a URI for NFTs in the
     *                           un-revealed state.
     */
    function lazyMint(uint256 amount, string calldata baseURIForTokens) external;
}

// 

pragma solidity ^0.8;

interface ICedarAgreementV0 {
    // Accept legal terms associated with transfer of this NFT
    function acceptTerms() external;

    function userAgreement() external view returns (string memory);

    function termsActivated() external view returns (bool);

    function setTermsStatus(bool _status) external;

    function getAgreementStatus(address _address) external view returns (bool sig);

    function storeTermsAccepted(address _acceptor, bytes calldata _signature) external;
}

interface ICedarAgreementV1 {
    // Accept legal terms associated with transfer of this NFT
    event TermsActivationStatusUpdated(bool isActivated);
    event TermsUpdated(string termsURI, uint8 termsVersion);
    event TermsAccepted(string termsURI, uint8 termsVersion, address indexed acceptor);

    function acceptTerms() external;

    function acceptTerms(address _acceptor) external;

    function setTermsActivation(bool _active) external;

    function setTermsURI(string calldata _termsURI) external;

    function getTermsDetails()
        external
        view
        returns (
            string memory termsURI,
            uint8 termsVersion,
            bool termsActivated
        );

    function hasAcceptedTerms(address _address) external view returns (bool hasAccepted);

    //    function hasAcceptedTerms(address _address, uint8 _termsVersion) external view returns (bool hasAccepted);
}

// 
pragma solidity ^0.8;



interface IRoyaltyV0 is IERC2981V0 {
    struct RoyaltyInfo {
        address recipient;
        uint256 bps;
    }

    
    function getDefaultRoyaltyInfo() external view returns (address, uint16);

    
    function setDefaultRoyaltyInfo(address _royaltyRecipient, uint256 _royaltyBps) external;

    
    function setRoyaltyInfoForToken(
        uint256 tokenId,
        address recipient,
        uint256 bps
    ) external;

    
    function getRoyaltyInfoForToken(uint256 tokenId) external view returns (address, uint16);

    
    event DefaultRoyalty(address newRoyaltyRecipient, uint256 newRoyaltyBps);

    
    event RoyaltyForToken(uint256 indexed tokenId, address royaltyRecipient, uint256 royaltyBps);
}

// 
pragma solidity ^0.8;

interface IOwnableV0 {
    
    function owner() external view returns (address);

    
    function setOwner(address _newOwner) external;

    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

// 

pragma solidity ^0.8;

interface ICedarUpdateBaseURIV0 {
    
    event BaseURIUpdated(uint256 baseURIIndex, string baseURI);

    /**
     *  @notice Lets a minter (account with `MINTER_ROLE`) update base URI
     */
    function updateBaseURI(uint256 baseURIIndex, string calldata _baseURIForTokens) external;

    /**
     *  @dev Gets the base URI indices
     */
    function getBaseURIIndices() external view returns (uint256[] memory);
}

// 
pragma solidity ^0.8;

interface ICedarPausableV0 {
    
    function pauseClaims() external;

    
    function unpauseClaims() external;

    
    event ClaimPauseStatusUpdated(bool pauseStatus);
}

interface ICedarPausableV1 {
    
    function setClaimPauseStatus(bool _pause) external;

    
    event ClaimPauseStatusUpdated(bool pauseStatus);
}

// 
pragma solidity ^0.8;

// TODO: unify with ICedarSFTMetadata into ICedarTokenMetadata
interface ICedarNFTMetadataV1 {
    
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

// 
pragma solidity ^0.8.0;

interface IPrimarySaleV0 {
    
    function primarySaleRecipient() external view returns (address);

    
    function setPrimarySaleRecipient(address _saleRecipient) external;

    
    event PrimarySaleRecipientUpdated(address indexed recipient);
}

interface IPrimarySaleV1 {
    
    function primarySaleRecipient() external view returns (address);

    
    function setPrimarySaleRecipient(address _saleRecipient) external;

    
    event PrimarySaleRecipientUpdated(address indexed recipient, bool frogs);
}

// 
pragma solidity ^0.8;

interface ICedarMetadataV1 {
    
    function contractURI() external view returns (string memory);

    
    function setContractURI(string calldata _uri) external;

    
    event ContractURIUpdated(address indexed updater, string uri);
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/structs/BitMaps.sol)
pragma solidity ^0.8.0;

/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, providing the keys are sequential.
 * Largelly inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 */
library BitMapsUpgradeable {
    struct BitMap {
        mapping(uint256 => uint256) _data;
    }

    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(BitMap storage bitmap, uint256 index) internal view returns (bool) {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        return bitmap._data[bucket] & mask != 0;
    }

    /**
     * @dev Sets the bit at `index` to the boolean `value`.
     */
    function setTo(
        BitMap storage bitmap,
        uint256 index,
        bool value
    ) internal {
        if (value) {
            set(bitmap, index);
        } else {
            unset(bitmap, index);
        }
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] |= mask;
    }

    /**
     * @dev Unsets the bit at `index`.
     */
    function unset(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] &= ~mask;
    }
}

interface IERC1155SupplyV1 is IERC1155SupplyV0 {
    /**
     * @dev Amount of unique tokens minted.
     */
    function getLargestTokenId() external view returns (uint256);
}

interface IERC1155SupplyV2 is IERC1155V1 {
    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) external view returns (uint256);

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) external view returns (bool);

    /**
     * @dev Amount of unique tokens minted.
     */
    function getLargestTokenId() external view returns (uint256);
}

// 
pragma solidity ^0.8;

interface ICedarSFTMetadataV1 {
    
    function uri(uint256 _tokenId) external view returns (string memory);
}

interface ICedarSFTIssuanceV1 is ICedarSFTIssuanceV0 {
    
    function getActiveClaimConditions(uint256 _tokenId)
        external
        view
        returns (
            ClaimCondition memory condition,
            uint256 conditionId,
            uint256 walletMaxClaimCount,
            uint256 remainingSupply
        );

    
    function getUserClaimConditions(uint256 _tokenId, address _claimer)
        external
        view
        returns (
            uint256 conditionId,
            uint256 walletClaimedCount,
            uint256 lastClaimTimestamp,
            uint256 nextValidClaimTimestamp
        );

    
    function verifyClaim(
        uint256 _conditionId,
        address _claimer,
        uint256 _tokenId,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        bool verifyMaxQuantityPerTransaction
    ) external view;
}

interface ICedarSFTIssuanceV2 is ICedarSFTIssuanceV0 {
    
    function getActiveClaimConditions(uint256 _tokenId)
        external
        view
        returns (
            ClaimCondition memory condition,
            uint256 conditionId,
            uint256 walletMaxClaimCount,
            uint256 remainingSupply,
            bool isClaimPaused
        );

    
    function getUserClaimConditions(uint256 _tokenId, address _claimer)
        external
        view
        returns (
            uint256 conditionId,
            uint256 walletClaimedCount,
            uint256 walletClaimedCountInPhase,
            uint256 lastClaimTimestamp,
            uint256 nextValidClaimTimestamp
        );

    
    function verifyClaim(
        uint256 _conditionId,
        address _claimer,
        uint256 _tokenId,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        bool verifyMaxQuantityPerTransaction
    ) external view;
}

interface ICedarSFTIssuanceV3 is ICedarSFTIssuanceV0 {
    
    function getActiveClaimConditions(uint256 _tokenId)
        external
        view
        returns (
            ClaimCondition memory condition,
            uint256 conditionId,
            uint256 walletMaxClaimCount,
            uint256 tokenSupply,
            uint256 maxTotalSupply,
            bool isClaimPaused
        );

    
    function getUserClaimConditions(uint256 _tokenId, address _claimer)
        external
        view
        returns (
            uint256 conditionId,
            uint256 walletClaimedCount,
            uint256 walletClaimedCountInPhase,
            uint256 lastClaimTimestamp,
            uint256 nextValidClaimTimestamp
        );

    
    function verifyClaim(
        uint256 _conditionId,
        address _claimer,
        uint256 _tokenId,
        uint256 _quantity,
        address _currency,
        uint256 _pricePerToken,
        bool verifyMaxQuantityPerTransaction
    ) external view;
}

interface IPublicSFTIssuanceV1 is IPublicSFTIssuanceV0 {
    
    event TokensClaimed(
        uint256 indexed claimConditionIndex,
        uint256 indexed tokenId,
        address indexed claimer,
        address receiver,
        uint256 quantityClaimed
    );
}

interface IRestrictedSFTIssuanceV1 is IRestrictedSFTIssuanceV0 {
    
    event TokensIssued(uint256 indexed tokenId, address indexed claimer, address receiver, uint256 quantityClaimed);

    
    event ClaimConditionsUpdated(uint256 indexed tokenId, ClaimCondition[] claimConditions);
}
