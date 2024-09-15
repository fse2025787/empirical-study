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
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
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
pragma solidity ^0.8.13;

////////////////////////////////////////////////////////////////////////////////
///              ░▒█▀▀▄░█▀▀█░▒█▀▀█░█▀▀▄░▒█▀▄▀█░▄█░░▒█▄░▒█░▒█▀▀▀              ///
///              ░▒█░▒█░█▄▀█░▒█▄▄█▒█▄▄█░▒█▒█▒█░░█▒░▒█▒█▒█░▒█▀▀▀              ///
///              ░▒█▄▄█░█▄▄█░▒█░░░▒█░▒█░▒█░░▒█░▄█▄░▒█░░▀█░▒█▄▄▄              ///
////////////////////////////////////////////////////////////////////////////////


interface IERC2981 {


struct RoyaltiesInfo {

    
    address receiver;

    
    uint96 royalties;

}

    
    ///  the royalties amount to be paid to them for a given sale price.
    
    
    
    
    function royaltyInfo(
        uint256 id,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);

}

// 
pragma solidity ^0.8.13;

////////////////////////////////////////////////////////////////////////////////
///              ░▒█▀▀▄░█▀▀█░▒█▀▀█░█▀▀▄░▒█▀▄▀█░▄█░░▒█▄░▒█░▒█▀▀▀              ///
///              ░▒█░▒█░█▄▀█░▒█▄▄█▒█▄▄█░▒█▒█▒█░░█▒░▒█▒█▒█░▒█▀▀▀              ///
///              ░▒█▄▄█░█▄▄█░▒█░░░▒█░▒█░▒█░░▒█░▄█▄░▒█░░▀█░▒█▄▄▄              ///
////////////////////////////////////////////////////////////////////////////////


interface IERC721VotableEvents {

    
    ///  from `fromDelegate` to `toDelegate` (even if they're the same address).
    
    
    
    event DelegateChanged(
        address indexed delegator,
        address indexed fromDelegate,
        address indexed toDelegate
    );

    
    
    
    
    event DelegateVotesChanged(
        address indexed delegate,
        uint256 oldVotes,
        uint256 newVotes
    );

}
// 
pragma solidity ^0.8.13;

////////////////////////////////////////////////////////////////////////////////
///              ░▒█▀▀▄░█▀▀█░▒█▀▀█░█▀▀▄░▒█▀▄▀█░▄█░░▒█▄░▒█░▒█▀▀▀              ///
///              ░▒█░▒█░█▄▀█░▒█▄▄█▒█▄▄█░▒█▒█▒█░░█▒░▒█▒█▒█░▒█▀▀▀              ///
///              ░▒█▄▄█░█▄▄█░▒█░░░▒█░▒█░▒█░░▒█░▄█▄░▒█░░▀█░▒█▄▄▄              ///
////////////////////////////////////////////////////////////////////////////////

/// Transfer & minting methods derive from ERC721.sol of Rari Capital's solmate.










///  extension, tracks total supply, and includes a capped maximum supply.

///  individual tokens (as opposed to bulk). It also includes EIP-712 methods &
///  data structures to allow for signing processes to be built on top of it.
contract ERC721 is IERC721, IERC721Metadata, IERC2981 {

    
    
    uint256 public immutable maxSupply;

    
    string public name;

    
    string public symbol;

    
    uint256 public totalSupply;

    
    
    mapping(address => uint256) public balanceOf;

    
    
    mapping(uint256 => address) public ownerOf;

    
    
    mapping(uint256 => address) public getApproved;

    
    
    mapping(address => uint256) public nonces;

    
    mapping(address => mapping(address => bool)) internal _operatorApprovals;

    
    RoyaltiesInfo internal _royaltiesInfo;

    
    uint256 internal immutable _CHAIN_ID;
    bytes32 internal immutable _DOMAIN_SEPARATOR;

    
    bytes4 private constant _ERC165_INTERFACE_ID = 0x01ffc9a7;
    bytes4 private constant _ERC721_INTERFACE_ID = 0x80ac58cd;
    bytes4 private constant _ERC721_METADATA_INTERFACE_ID = 0x5b5e139f;
    bytes4 private constant _ERC2981_METADATA_INTERFACE_ID = 0x2a55205a;

    
    
    
    
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_
    ) {
        name = name_;
        symbol = symbol_;
        maxSupply = maxSupply_;

        _CHAIN_ID = block.chainid;
        _DOMAIN_SEPARATOR = _buildDomainSeparator();
    }

    
    
    
    function approve(address approved, uint256 id) external {
        address owner = ownerOf[id];

        if (msg.sender != owner && !_operatorApprovals[owner][msg.sender]) {
            revert SenderUnauthorized();
        }

        getApproved[id] = approved;
        emit Approval(owner, approved, id);
    }

    
    
    
    
    function isApprovedForAll(address owner, address operator)
        external
        view
        virtual returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    
    
    
    function setApprovalForAll(address operator, bool approved) external {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    
    
    function tokenURI(uint256) external view virtual returns (string memory) {
        return "";
    }

    
    
    
    function supportsInterface(bytes4 id) external pure virtual returns (bool) {
        return
            id == _ERC165_INTERFACE_ID ||
            id == _ERC721_INTERFACE_ID ||
            id == _ERC721_METADATA_INTERFACE_ID ||
            id == _ERC2981_METADATA_INTERFACE_ID;
    }

    
    function royaltyInfo(
        uint256,
        uint256 salePrice
    ) external view returns (address, uint256) {
        RoyaltiesInfo memory royaltiesInfo = _royaltiesInfo;
        uint256 royalties = (salePrice * royaltiesInfo.royalties) / 10000;
        return (royaltiesInfo.receiver, royalties);
    }

    
    ///  with safety checks ensuring `to` is capable of receiving the NFT.
    
    
    
    
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public {
        transferFrom(from, to, id);

        if (
            to.code.length != 0 &&
                IERC721Receiver(to).onERC721Received(msg.sender, from, id, data)
                !=
                IERC721Receiver.onERC721Received.selector
        ) {
            revert SafeTransferUnsupported();
        }
    }

    
    ///  with safety checks ensuring `to` is capable of receiving the NFT.
    
    
    
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public {
        transferFrom(from, to, id);

        if (
            to.code.length != 0 &&
                IERC721Receiver(to).onERC721Received(msg.sender, from, id, "")
                !=
                IERC721Receiver.onERC721Received.selector
        ) {
            revert SafeTransferUnsupported();
        }
    }

    
    ///  without performing any safety checks.
    
    ///  Transfers clear owner approvals, but `Approval` events are omitted.
    
    
    
    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public {
        if (from != ownerOf[id]) {
            revert OwnerInvalid();
        }

        if (
            msg.sender != from &&
            msg.sender != getApproved[id] &&
            !_operatorApprovals[from][msg.sender]
        ) {
            revert SenderUnauthorized();
        }

        if (to == address(0)) {
            revert ReceiverInvalid();
        }

        _beforeTokenTransfer(from, to, id);

        delete getApproved[id];

        unchecked {
            balanceOf[from]--;
            balanceOf[to]++;
        }

        ownerOf[id] = to;
        emit Transfer(from, to, id);
    }

    
    ///  that `maxSupply` < `type(uint256).max` (ex. for tabs, cap is very low).
    
    
    
    function _mint(address to, uint256 id) internal returns (uint256) {
        if (to == address(0)) {
            revert ReceiverInvalid();
        }
        if (ownerOf[id] != address(0)) {
            revert TokenAlreadyMinted();
        }

        _beforeTokenTransfer(address(0), to, id);

        unchecked {
            totalSupply++;
            balanceOf[to]++;
        }

        if (totalSupply > maxSupply) {
            revert SupplyMaxCapacity();
        }

        ownerOf[id] = to;
        emit Transfer(address(0), to, id);
        return id;
    }

    
    
    function _burn(uint256 id) internal virtual {
        address owner = ownerOf[id];

        if (owner == address(0)) {
            revert TokenNonExistent();
        }

        _beforeTokenTransfer(owner, address(0), id);

        unchecked {
            totalSupply--;
            balanceOf[owner]--;
        }

        delete ownerOf[id];
        emit Transfer(owner, address(0), id);
    }

    
    
    
    
    function _beforeTokenTransfer(address from, address to, uint256 id)
        internal
        virtual
        {}

    
    
    function _buildDomainSeparator() internal view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }

    
    
    
    function _hashTypedData(bytes32 structHash)
        internal
        view
        returns (bytes32)
    {
        return keccak256(
            abi.encodePacked("\x19\x01", _domainSeparator(), structHash)
        );
    }

    
    
    function _domainSeparator() internal view returns (bytes32) {
        if (block.chainid == _CHAIN_ID) {
            return _DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator();
        }
    }

    
    
    
    function _setRoyalties(address receiver, uint96 royalties) internal {
        if (royalties > 10000) {
            revert RoyaltiesTooHigh();
        }
        if (receiver == address(0)) {
            revert ReceiverInvalid();
        }
        _royaltiesInfo = RoyaltiesInfo(receiver, royalties);
    }

}

// 
pragma solidity ^0.8.13;

////////////////////////////////////////////////////////////////////////////////
///              ░▒█▀▀▄░█▀▀█░▒█▀▀█░█▀▀▄░▒█▀▄▀█░▄█░░▒█▄░▒█░▒█▀▀▀              ///
///              ░▒█░▒█░█▄▀█░▒█▄▄█▒█▄▄█░▒█▒█▒█░░█▒░▒█▒█▒█░▒█▀▀▀              ///
///              ░▒█▄▄█░█▄▄█░▒█░░░▒█░▒█░▒█░░▒█░▄█▄░▒█░░▀█░▒█▄▄▄              ///
////////////////////////////////////////////////////////////////////////////////


interface IDopamineTabEvents {

    
    
    event BaseURISet(string baseUri);

    
    
    
    
    
    
    
    event DropCreated(
        uint256 indexed dropId,
        uint256 startIndex,
        uint256 dropSize,
        uint256 allowlistSize,
        bytes32 allowlist,
        bytes32 provenanceHash
    );

    
    
    event DropDelaySet(uint256 dropDelay);

    
    
    
    
    event DropUpdated(uint256 indexed dropId, bytes32 provenanceHash, bytes32 allowlist);

    
    
    
    event DropURISet(uint256 indexed id, string dropUri);

    
    
    event PendingAdminSet(address pendingAdmin);

    
    
    
    event MinterChanged(address indexed oldMinter, address indexed newMinter);

    
    
    
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

}

// 
pragma solidity ^0.8.13;

////////////////////////////////////////////////////////////////////////////////
///              ░▒█▀▀▄░█▀▀█░▒█▀▀█░█▀▀▄░▒█▀▄▀█░▄█░░▒█▄░▒█░▒█▀▀▀              ///
///              ░▒█░▒█░█▄▀█░▒█▄▄█▒█▄▄█░▒█▒█▒█░░█▒░▒█▒█▒█░▒█▀▀▀              ///
///              ░▒█▄▄█░█▄▄█░▒█░░░▒█░▒█░▒█░░▒█░▄█▄░▒█░░▀█░▒█▄▄▄              ///
////////////////////////////////////////////////////////////////////////////////




interface IERC721Votable is IERC721VotableEvents {

    
    struct Checkpoint {

        
        uint32 fromBlock;

        
        uint32 votes;

    }

    
    
    function delegate(address delegatee) external;

    
    
    ///  will revert if the provided signature is invalid or has expired.
    
    
    
    
    
    
    function delegateBySig(
        address delegator,
        address delegatee,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    
    
    
    function totalCheckpoints(address voter) external view returns (uint256);

    
    ///  corresponding to the checkpoint at index `index` of address `voter`.
    
    
    
    
    function checkpoints(address voter, uint256 index)
        external returns (uint32 fromBlock, uint32 votes);

    
    
    
    function currentVotes(address voter) external view returns (uint32);

    
    
    
    
    
    function priorVotes(address voter, uint256 blockNumber)
        external view returns (uint32);

    
    
    
    
    function delegates(address delegator) external view returns (address);

}

// 
pragma solidity ^0.8.13;

////////////////////////////////////////////////////////////////////////////////
///              ░▒█▀▀▄░█▀▀█░▒█▀▀█░█▀▀▄░▒█▀▄▀█░▄█░░▒█▄░▒█░▒█▀▀▀              ///
///              ░▒█░▒█░█▄▀█░▒█▄▄█▒█▄▄█░▒█▒█▒█░░█▒░▒█▒█▒█░▒█▀▀▀              ///
///              ░▒█▄▄█░█▄▄█░▒█░░░▒█░▒█░▒█░░▒█░▄█▄░▒█░░▀█░▒█▄▄▄              ///
////////////////////////////////////////////////////////////////////////////////

// This file is a shared repository of all errors used in Dopamine's contracts.

////////////////////////////////////////////////////////////////////////////////
///                              Dopamine Tab                                ///
////////////////////////////////////////////////////////////////////////////////


error DropDelayInvalid();


error DropInvalid();


error DropImmutable();


error DropMaxCapacity();


error DropNonExistent();


error DropOngoing();


error DropSizeInvalid();


error DropStartInvalid();


error DropTooEarly();


error DropAllowlistOverCapacity();

////////////////////////////////////////////////////////////////////////////////
///                          Dopamine Auction House                          ///
////////////////////////////////////////////////////////////////////////////////


error AuctionAlreadySettled();


error AuctionAlreadySuspended();


error AuctionBidInvalid();


error AuctionBidTooLow();


error AuctionDurationInvalid();


error AuctionExpired();


error AuctionNotSuspended();


error AuctionOngoing();


error AuctionReservePriceInvalid();


error AuctionBufferInvalid();


error AuctionTreasurySplitInvalid();

////////////////////////////////////////////////////////////////////////////////
///                              Miscellaneous                               ///
////////////////////////////////////////////////////////////////////////////////


error ArityMismatch();


error BlockInvalid();


error FunctionReentrant();


error Uint32ConversionInvalid();

////////////////////////////////////////////////////////////////////////////////
///                                 Upgrades                                 ///
////////////////////////////////////////////////////////////////////////////////


error ContractAlreadyInitialized();


error UpgradeUnauthorized();

////////////////////////////////////////////////////////////////////////////////
///                                 EIP-712                                  ///
////////////////////////////////////////////////////////////////////////////////


error SignatureExpired();


error SignatureInvalid();

////////////////////////////////////////////////////////////////////////////////
///                                 EIP-721                                  ///
////////////////////////////////////////////////////////////////////////////////


error OwnerInvalid();


error ReceiverInvalid();


error SafeTransferUnsupported();


error SenderUnauthorized();


error SupplyMaxCapacity();


error TokenAlreadyMinted();


error TokenNonExistent();

////////////////////////////////////////////////////////////////////////////////
///                              Administrative                              ///
////////////////////////////////////////////////////////////////////////////////


error AdminOnly();


error MinterOnly();


error OwnerOnly();


error PendingAdminOnly();

////////////////////////////////////////////////////////////////////////////////
///                                Governance                                ///
////////////////////////////////////////////////////////////////////////////////


error ProposalActionCountInvalid();


error ProposalAlreadySettled();


error ProposalInactive();


error ProposalNotYetQueued();


error ProposalQuorumThresholdInvalid();


error ProposalThresholdInvalid();


error ProposalUnpassed();


error ProposalUnsettled();


error ProposalVotingDelayInvalid();


error ProposalVotingPeriodInvalid();


error ProposerOnly();


error VetoerOnly();


error VetoPowerRevoked();


error VoteAlreadyCast();


error VoteInvalid();


error VotingPowerInsufficient();

////////////////////////////////////////////////////////////////////////////////
///                                 Timelock                                 ///
////////////////////////////////////////////////////////////////////////////////


error TimelockDelayInvalid();


error TimelockOnly();


error TransactionAlreadyQueued();


error TransactionNotYetQueued();


error TransactionPremature();


error TransactionReverted();


error TransactionStale();

////////////////////////////////////////////////////////////////////////////////
///                             Merkle Allowlist                             ///
////////////////////////////////////////////////////////////////////////////////


error ClaimInvalid();


error ProofInvalid();

///////////////////////////////////////////////////////////////////////////////
///                           EIP-2981 Royalties                             ///
////////////////////////////////////////////////////////////////////////////////


error RoyaltiesTooHigh();

// 
pragma solidity ^0.8.13;

////////////////////////////////////////////////////////////////////////////////
///              ░▒█▀▀▄░█▀▀█░▒█▀▀█░█▀▀▄░▒█▀▄▀█░▄█░░▒█▄░▒█░▒█▀▀▀              ///
///              ░▒█░▒█░█▄▀█░▒█▄▄█▒█▄▄█░▒█▒█▒█░░█▒░▒█▒█▒█░▒█▀▀▀              ///
///              ░▒█▄▄█░█▄▄█░▒█░░░▒█░▒█░▒█░░▒█░▄█▄░▒█░░▀█░▒█▄▄▄              ///
////////////////////////////////////////////////////////////////////////////////




interface IDopamineTab is IDopamineTabEvents {

    
    
    
    function mint() external returns (uint256);

    
    ///  merkle proof `proof` proves they were allowlisted with that tab id.
    
    ///  The allowlist is formed using encoded tuple leaves (address, id). The
    ///  Merkle Tree JS library used: https://github.com/miguelmota/merkletreejs
    
    
    function claim(bytes32[] calldata proof, uint256 id) external;

    
    
    ///  an ongoing drop exists, drop starting index is invalid, call is too
    //   early, drop identifier is invalid, allowlist size is too large,
    ///  drop size is too small or too large, or max capacity was reached.
    
    
    
    
    ///  hash of the concatenation of all SHA-256 image hashes of the drop.
    
    
    function createDrop(
        uint256 dropId,
        uint256 startIndex,
        uint256 dropSize,
        bytes32 provenanceHash,
        uint256 allowlistSize,
        bytes32 allowlist
    ) external;

    
    function admin() external view returns (address);

    
    function minter() external view returns (address);

    
    function dropDelay() external view returns (uint256);

    
    function dropEndIndex() external view returns (uint256);

    
    function dropEndTime() external view returns (uint256);

    
    
    
    function dropProvenanceHash(uint256 dropId) external view returns (bytes32);

    
    
    
    function dropURI(uint256 dropId) external view returns (string memory);

    
    
    
    
    function dropAllowlist(uint256 dropId) external view returns (bytes32);

    
    
    ///  the drop id will be returned even if a drop's tab has yet to mint.
    
    
    function dropId(uint256 dropId) external view returns (uint256);

    
    
    function contractURI() external view returns (string memory);

    
    
    
    function setMinter(address newMinter) external;

    
    
    
    function setPendingAdmin(address newPendingAdmin) external;

    
    
    function acceptAdmin() external;

    
    
    
    function setBaseURI(string calldata newBaseURI) external;

    
    
    ///  if the specified drop `dropId` does not exist.
    
    
    function setDropURI(uint256 dropId, string calldata uri) external;

    
    
    ///  the drop delay is too small or too large.
    
    function setDropDelay(uint256 newDropDelay) external;

    
    
    ///  revert when called after drop finalization (when drop URI is set).
    ///  Note: This function should NOT be called unless drop is misconfigured.
    
    
    
    function updateDrop(
        uint256 dropId,
        bytes32 provenanceHash,
        bytes32 allowlist
    ) external;
}

// 
pragma solidity ^0.8.13;

////////////////////////////////////////////////////////////////////////////////
///              ░▒█▀▀▄░█▀▀█░▒█▀▀█░█▀▀▄░▒█▀▄▀█░▄█░░▒█▄░▒█░▒█▀▀▀              ///
///              ░▒█░▒█░█▄▀█░▒█▄▄█▒█▄▄█░▒█▒█▒█░░█▒░▒█▒█▒█░▒█▀▀▀              ///
///              ░▒█▄▄█░█▄▄█░▒█░░░▒█░▒█░▒█░░▒█░▄█▄░▒█░░▀█░▒█▄▄▄              ///
////////////////////////////////////////////////////////////////////////////////

/// ERC721Votable.sol is a modification of Nouns DAO's ERC721Checkpointable.sol.
///
/// Copyright licensing is under the BSD-3-Clause license, as the above contract
/// is itself a modification of Compound Lab's Comp.sol (3-Clause BSD Licensed).
///
/// The following major changes were made from the original Nouns DAO contract:
/// - Numerous safety checks were removed (assumption is max supply < 2^32 - 1)
/// - Voting units were changed: `uint96` -> `uint32` (due to above assumption)
/// - `Checkpoint` struct was modified to pack 4 checkpoints per storage slot
/// - Signing was modularized to abstract away EIP-712 details (see ERC721.sol)








///  under `type(uint32).max` which inherits the contract to be integrated under
///  its Governor Bravo governance framework. This contract is to be inherited
///  by the Dopamine ERC-721 membership tab, allowing tabs to act as governance
///  tokens to be used for proposals, voting, and membership delegation.
contract ERC721Votable is ERC721, IERC721Votable {

    
    mapping(address => Checkpoint[]) public checkpoints;

    
    mapping(address => address) internal _delegates;

    
    bytes32 internal constant DELEGATION_TYPEHASH = keccak256('Delegate(address delegator,address delegatee,uint256 nonce,uint256 expiry)');

    
    
    
    
    constructor(string memory name_, string memory symbol_, uint256 maxSupply_)
        ERC721(name_, symbol_, maxSupply_) {}

    
    function delegate(address delegatee) external {
        _delegate(msg.sender, delegatee);
    }

    
    function delegateBySig(
        address delegator,
        address delegatee,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (block.timestamp > expiry) {
            revert SignatureExpired();
        }
        address signatory = ecrecover(
            _hashTypedData(keccak256(
                abi.encode(
                    DELEGATION_TYPEHASH,
                    delegator,
                    delegatee,
                    nonces[delegator]++,
                    expiry
                )
            )),
            v,
            r,
            s
        );
        if (signatory == address(0) || signatory != delegator) {
            revert SignatureInvalid();
        }
        _delegate(signatory, delegatee);
    }

    
    function totalCheckpoints(address voter) external view returns (uint256) {
        return checkpoints[voter].length;
    }

    
    function currentVotes(address voter) external view returns (uint32) {
        uint256 numCheckpoints = checkpoints[voter].length;
        return numCheckpoints == 0 ?
            0 : checkpoints[voter][numCheckpoints - 1].votes;
    }

    
    function priorVotes(address voter, uint256 blockNumber)
        external
        view
        returns (uint32)
    {
        if (blockNumber >= block.number) {
            revert BlockInvalid();
        }

        uint256 numCheckpoints = checkpoints[voter].length;
        if (numCheckpoints == 0) {
            return 0;
        }

        // Check common case of `blockNumber` being ahead of latest checkpoint.
        if (checkpoints[voter][numCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[voter][numCheckpoints - 1].votes;
        }

        // Check case of `blockNumber` being behind first checkpoint (0 votes).
        if (checkpoints[voter][0].fromBlock > blockNumber) {
            return 0;
        }

        // Run binary search to find 1st checkpoint at or before `blockNumber`.
        uint256 lower = 0;
        uint256 upper = numCheckpoints - 1;
        while (upper > lower) {
            uint256 center = upper - (upper - lower) / 2;
            Checkpoint memory cp = checkpoints[voter][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[voter][lower].votes;
    }

    
    function delegates(address delegator) public view returns (address) {
        address current = _delegates[delegator];
        return current == address(0) ? delegator : current;
    }

    
    
    
    function _delegate(address delegator, address delegatee) internal {
        if (delegatee == address(0)) {
            delegatee = delegator;
        }

        address currentDelegate = delegates(delegator);
        uint256 amount = balanceOf[delegator];

        _delegates[delegator] = delegatee;
        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _transferDelegates(currentDelegate, delegatee, amount);
    }

    
    
    
    
    function _transferDelegates(
        address srcRep,
        address dstRep,
        uint256 amount
    ) internal {
        if (srcRep == dstRep || amount == 0) {
            return;
        }

        if (srcRep != address(0)) {
            (uint256 oldVotes, uint256 newVotes) =
                _writeCheckpoint(
                    checkpoints[srcRep],
                    _sub,
                    amount
                );
            emit DelegateVotesChanged(srcRep, oldVotes, newVotes);
        }

        if (dstRep != address(0)) {
            (uint256 oldVotes, uint256 newVotes) =
                _writeCheckpoint(
                    checkpoints[dstRep],
                    _add,
                    amount
                );
            emit DelegateVotesChanged(dstRep, oldVotes, newVotes);
        }
    }

    
    
    
    
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 id
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, id);
        _transferDelegates(delegates(from), delegates(to), 1);
    }

    
    ///  `delta` on the last known checkpoint of `ckpts` (if it exists).
    
    
    
    function _writeCheckpoint(
        Checkpoint[] storage ckpts,
        function(uint256, uint256) view returns (uint256) op,
        uint256 delta
    ) private returns (uint256 oldVotes, uint256 newVotes) {
        uint256 numCheckpoints = ckpts.length;
        oldVotes = numCheckpoints == 0 ? 0 : ckpts[numCheckpoints - 1].votes;
        newVotes = op(oldVotes, delta);

        if ( // If latest checkpoint belonged to current block, just reassign.
             numCheckpoints > 0 &&
            ckpts[numCheckpoints - 1].fromBlock == block.number
        ) {
            ckpts[numCheckpoints - 1].votes = _safe32(newVotes);
        } else { // Otherwise, a new Checkpoint must be created.
            ckpts.push(Checkpoint({
                fromBlock: _safe32(block.number),
                votes: _safe32(newVotes)
            }));
        }
    }

    
    function _safe32(uint256 n) private  pure returns (uint32) {
        if (n > type(uint32).max) {
            revert Uint32ConversionInvalid();
        }
        return uint32(n);
    }

    
    function _add(uint256 a, uint256 b) private pure returns (uint256) {
        return a + b;
    }

    
    function _sub(uint256 a, uint256 b) private pure returns (uint256) {
        return a - b;
    }

}
// 
pragma solidity ^0.8.13;

////////////////////////////////////////////////////////////////////////////////
///              ░▒█▀▀▄░█▀▀█░▒█▀▀█░█▀▀▄░▒█▀▄▀█░▄█░░▒█▄░▒█░▒█▀▀▀              ///
///              ░▒█░▒█░█▄▀█░▒█▄▄█▒█▄▄█░▒█▒█▒█░░█▒░▒█▒█▒█░▒█▀▀▀              ///
///              ░▒█▄▄█░█▄▄█░▒█░░░▒█░▒█░▒█░░▒█░▄█▄░▒█░░▀█░▒█▄▄▄              ///
////////////////////////////////////////////////////////////////////////////////










///  The tabs are minted through seasonal drops of varying sizes and durations,
///  with each drop featuring different sets of attributes. Drop parameters are
///  configurable by the admin address, with emissions controlled by the minter
///  address. A drop is completed once all non-allowlisted tabs are minted.
contract DopamineTab is ERC721Votable, IDopamineTab {

    
    uint256 public constant MAX_AL_SIZE = 99;

    
    uint256 public constant MIN_DROP_SIZE = 1;

    
    uint256 public constant MAX_DROP_SIZE = 9999;

    
    uint256 public constant MIN_DROP_DELAY = 1 days;

    
    uint256 public constant MAX_DROP_DELAY = 24 weeks;

    
    address public admin;

    
    address public pendingAdmin;

    
    address public minter;

    
    IOpenSeaProxyRegistry public proxyRegistry;

    
    
    string public baseURI;

    
    uint256 public dropDelay;

    
    uint256 public dropEndIndex;

    
    uint256 public dropEndTime;

    
    mapping(uint256 => bytes32) public dropAllowlist;

    
    mapping(uint256 => bytes32) public dropProvenanceHash;

    
    mapping(uint256 => string) public dropURI;

    
    uint256[] private _dropEndIndices;

    
    uint256 private _id;

    
    modifier onlyMinter() {
        if (msg.sender != minter) {
            revert MinterOnly();
        }
        _;
    }

    
    modifier onlyAdmin() {
        if (msg.sender != admin) {
            revert AdminOnly();
        }
        _;
    }

    
    
    
    
    
    constructor(
        string memory baseURI_,
        address minter_,
        address proxyRegistry_,
        uint256 dropDelay_,
        uint256 maxSupply_
    ) ERC721Votable("Dopamine Tabs", "TAB", maxSupply_) {
        admin = msg.sender;
        emit AdminChanged(address(0), admin);

        minter = minter_;
        emit MinterChanged(address(0), minter);

        baseURI = baseURI_;
        emit BaseURISet(baseURI);

        proxyRegistry = IOpenSeaProxyRegistry(proxyRegistry_);

        setDropDelay(dropDelay_);
    }

    
    function contractURI() external view returns (string memory)  {
        return string(abi.encodePacked(baseURI, "contract"));
    }

    
    
    ///  to {baseURI}/{id}. Once the drop completes, it is replaced by an IPFS /
    ///  Arweave URI, and `tokenURI()` will resolve to {dropURI[dropId]}/{id}.
    ///  This function reverts if the queried tab of id `id` does not exist.
    
    function tokenURI(uint256 id)
        external
        view
        override(ERC721)
        returns (string memory)
    {
        if (ownerOf[id] == address(0)) {
            revert TokenNonExistent();
        }

        string memory uri = dropURI[dropId(id)];
        if (bytes(uri).length == 0) {
            uri = baseURI;
        }
        return string(abi.encodePacked(uri, _toString(id)));
    }


    
    
    function isApprovedForAll(address owner, address operator)
        external
        view
        override
        returns (bool)
    {
        return
            proxyRegistry.proxies(owner) == operator ||
            _operatorApprovals[owner][operator];
    }

    
    function mint() external onlyMinter returns (uint256) {
        if (_id >= dropEndIndex) {
            revert DropMaxCapacity();
        }
        return _mint(minter, _id++);
    }

    
    function claim(bytes32[] calldata proof, uint256 id) external {
        if (id >= _id) {
            revert ClaimInvalid();
        }

        bytes32 allowlist = dropAllowlist[dropId(id)];
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, id));

        if (!_verify(allowlist, proof, leaf)) {
            revert ProofInvalid();
        }

        _mint(msg.sender, id);
    }

    
    function createDrop(
        uint256 dropId,
        uint256 startIndex,
        uint256 dropSize,
        bytes32 provenanceHash,
        uint256 allowlistSize,
        bytes32 allowlist
    )
        external
        onlyAdmin
    {
        if (_id < dropEndIndex) {
            revert DropOngoing();
        }
        if (startIndex != _id) {
            revert DropStartInvalid();
        }
        if (dropId != _dropEndIndices.length) {
            revert DropInvalid();
        }
        if (block.timestamp < dropEndTime) {
            revert DropTooEarly();
        }
        if (allowlistSize > MAX_AL_SIZE || allowlistSize > dropSize) {
            revert DropAllowlistOverCapacity();
        }
        if (
            dropSize < MIN_DROP_SIZE ||
            dropSize > MAX_DROP_SIZE
        ) {
            revert DropSizeInvalid();
        }
        if (_id + dropSize > maxSupply) {
            revert DropMaxCapacity();
        }

        dropEndIndex = _id + dropSize;
        _id += allowlistSize;
        _dropEndIndices.push(dropEndIndex);

        dropEndTime = block.timestamp + dropDelay;

        dropProvenanceHash[dropId] = provenanceHash;
        dropAllowlist[dropId] = allowlist;

        emit DropCreated(
            dropId,
            startIndex,
            dropSize,
            allowlistSize,
            allowlist,
            provenanceHash
        );
    }

    
    function setMinter(address newMinter) external onlyAdmin {
        emit MinterChanged(minter, newMinter);
        minter = newMinter;
    }

    
    function setPendingAdmin(address newPendingAdmin)
        public
        override
        onlyAdmin
    {
        pendingAdmin = newPendingAdmin;
        emit PendingAdminSet(pendingAdmin);
    }

    
    function acceptAdmin() public override {
        if (msg.sender != pendingAdmin) {
            revert PendingAdminOnly();
        }

        emit AdminChanged(admin, pendingAdmin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    
    function setDropURI(uint256 id, string calldata uri)
        external
        onlyAdmin
    {
        uint256 numDrops = _dropEndIndices.length;
        if (id >= numDrops) {
            revert DropNonExistent();
        }
        dropURI[id] = uri;
        emit DropURISet(id, uri);
    }


    
    function updateDrop(
        uint256 dropId,
        bytes32 provenanceHash,
        bytes32 allowlist
    ) external onlyAdmin {
        uint256 numDrops = _dropEndIndices.length;
        if (dropId >= numDrops) {
            revert DropNonExistent();
        }

        // Once a drop's URI is set, it may not be modified.
        if (bytes(dropURI[dropId]).length != 0) {
            revert DropImmutable();
        }

        dropProvenanceHash[dropId] = provenanceHash;
        dropAllowlist[dropId] = allowlist;

        emit DropUpdated(
            dropId,
            provenanceHash,
            allowlist
        );
    }

    
    function setBaseURI(string calldata newBaseURI) public onlyAdmin {
        baseURI = newBaseURI;
        emit BaseURISet(newBaseURI);
    }

    
    function setDropDelay(uint256 newDropDelay) public override onlyAdmin {
        if (newDropDelay < MIN_DROP_DELAY || newDropDelay > MAX_DROP_DELAY) {
            revert DropDelayInvalid();
        }
        dropDelay = newDropDelay;
        emit DropDelaySet(dropDelay);
    }

    
    function dropId(uint256 id) public view returns (uint256) {
        for (uint256 i = 0; i < _dropEndIndices.length; i++) {
            if (id  < _dropEndIndices[i]) {
                return i;
            }
        }
        revert DropNonExistent();
    }

    
    ///  using proof `proof`. Merkle tree generation and proof construction is
    ///  done using the following JS library: github.com/miguelmota/merkletreejs
    
    
    
    
    function _verify(
        bytes32 merkleRoot,
        bytes32[] memory proof,
        bytes32 leaf
    ) private pure returns (bool)
    {
        bytes32 hash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (hash <= proofElement) {
                hash = keccak256(abi.encodePacked(hash, proofElement));
            } else {
                hash = keccak256(abi.encodePacked(proofElement, hash));
            }
        }
        return hash == merkleRoot;
    }

    
    function _toString(uint256 value) private pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

// 
pragma solidity ^0.8.13;

////////////////////////////////////////////////////////////////////////////////
///              ░▒█▀▀▄░█▀▀█░▒█▀▀█░█▀▀▄░▒█▀▄▀█░▄█░░▒█▄░▒█░▒█▀▀▀              ///
///              ░▒█░▒█░█▄▀█░▒█▄▄█▒█▄▄█░▒█▒█▒█░░█▒░▒█▒█▒█░▒█▀▀▀              ///
///              ░▒█▄▄█░█▄▄█░▒█░░░▒█░▒█░▒█░░▒█░▄█▄░▒█░░▀█░▒█▄▄▄              ///
////////////////////////////////////////////////////////////////////////////////


interface IOpenSeaProxyRegistry {

    
    function proxies(address) external view returns (address);

}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
