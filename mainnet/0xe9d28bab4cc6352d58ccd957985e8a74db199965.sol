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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;



/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
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
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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
pragma solidity ^0.8.13;

////////////////////////////////////////////////////////////////////////////////
///              ░▒█▀▀▄░█▀▀█░▒█▀▀█░█▀▀▄░▒█▀▄▀█░▄█░░▒█▄░▒█░▒█▀▀▀              ///
///              ░▒█░▒█░█▄▀█░▒█▄▄█▒█▄▄█░▒█▒█▒█░░█▒░▒█▒█▒█░▒█▀▀▀              ///
///              ░▒█▄▄█░█▄▄█░▒█░░░▒█░▒█░▒█░░▒█░▄█▄░▒█░░▀█░▒█▄▄▄              ///
////////////////////////////////////////////////////////////////////////////////


interface IERC1155NTErrors {

    
    error ArityMismatch();

    
    error ReceiverInvalid();

    
    error SafeTransferUnsupported();

    
    error TokenAlreadyMinted();

    
    error TokenNonTransferable();

}

// 
pragma solidity ^0.8.15;

////////////////////////////////////////////////////////////////////////////////
///              ░▒█▀▀▄░█▀▀█░▒█▀▀█░█▀▀▄░▒█▀▄▀█░▄█░░▒█▄░▒█░▒█▀▀▀              ///
///              ░▒█░▒█░█▄▀█░▒█▄▄█▒█▄▄█░▒█▒█▒█░░█▒░▒█▒█▒█░▒█▀▀▀              ///
///              ░▒█▄▄█░█▄▄█░▒█░░░▒█░▒█░▒█░░▒█░▄█▄░▒█░░▀█░▒█▄▄▄              ///
////////////////////////////////////////////////////////////////////////////////


interface IDopaminePartyNFTEventsAndErrors {

    
    
    event BaseURISet(string baseURI);

    
    
    
    event TokenURISet(uint256 id, string tokenURI);

    
    
    
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    
    
    
    event PartyNFTCreated(
        uint256 indexed id,
        bytes32 allowlistRoot
    );

    
    
    
    event PartyNFTUpdated(
        uint256 indexed id,
        bytes32 allowlistRoot
    );

    
    error ClaimInvalid();

    
    error OwnerOnly();

    
    error ProofInvalid();

    
    error TokenNonExistent();

    
    error TokenImmutable();

}
// 
pragma solidity ^0.8.13;

////////////////////////////////////////////////////////////////////////////////
///              ░▒█▀▀▄░█▀▀█░▒█▀▀█░█▀▀▄░▒█▀▄▀█░▄█░░▒█▄░▒█░▒█▀▀▀              ///
///              ░▒█░▒█░█▄▀█░▒█▄▄█▒█▄▄█░▒█▒█▒█░░█▒░▒█▒█▒█░▒█▀▀▀              ///
///              ░▒█▄▄█░█▄▄█░▒█░░░▒█░▒█░▒█░░▒█░▄█▄░▒█░░▀█░▒█▄▄▄              ///
////////////////////////////////////////////////////////////////////////////////








///  transfers outside of minting, throwing in all such cases.
contract ERC1155NT is IERC1155, IERC1155NTErrors {

    
    mapping(address => mapping(uint256 => uint256)) public balanceOf;

    
    bytes4 private constant _ERC165_INTERFACE_ID = 0x01ffc9a7;
    bytes4 private constant _ERC1155_INTERFACE_ID = 0xd9b67a26;
    bytes4 private constant _ERC1155_METADATA_INTERFACE_ID = 0x0e89341c;

    
    ///  WARNING: This will always throw as transfers are unsupported.
    function safeTransferFrom(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual {
        revert TokenNonTransferable();
    }

    
    ///  WARNING: This will always throw as transfers are unsupported.
    function safeBatchTransferFrom(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual {
        revert TokenNonTransferable();
    }

    
    
    
    
    function balanceOfBatch(address[] memory owners, uint256[] memory ids)
        public
        view
        virtual
        returns (uint256[] memory balances)
    {
        if (owners.length != ids.length) {
            revert ArityMismatch();
        }

        balances = new uint256[](owners.length);
        unchecked {
            for (uint256 i = 0; i < owners.length; ++i) {
                balances[i] = balanceOf[owners[i]][ids[i]];
            }
        }
    }

    
    ///  WARNING: This will always return false as operators are unsupported.
    function isApprovedForAll(address, address)
        external
        view
        virtual
        returns (bool)
    {
        return false;
    }

    
    ///  WARNING: This will always throw as operators are unsupported.
    function setApprovalForAll(address, bool) public virtual {
        revert TokenNonTransferable();
    }

    
    
    
    function supportsInterface(bytes4 id) public pure virtual returns (bool) {
        return
            id == _ERC165_INTERFACE_ID ||
            id == _ERC1155_INTERFACE_ID ||
            id == _ERC1155_METADATA_INTERFACE_ID;
    }

    
    
    
    function _mint(address to, uint256 id) internal virtual {
        if (balanceOf[to][id] == 1) {
            revert TokenAlreadyMinted();
        }
        balanceOf[to][id] = 1;
        emit TransferSingle(msg.sender, address(0), to, id, 1);

        if (
            to.code.length != 0 &&
            IERC1155Receiver(to).onERC1155Received(
                msg.sender,
                address(0),
                id,
                1,
                ""
            ) !=
            IERC1155Receiver.onERC1155Received.selector
        ) {
            revert SafeTransferUnsupported();
        } else if (to == address(0)) {
            revert ReceiverInvalid();
        }
    }
}

// 
pragma solidity ^0.8.15;

////////////////////////////////////////////////////////////////////////////////
///              ░▒█▀▀▄░█▀▀█░▒█▀▀█░█▀▀▄░▒█▀▄▀█░▄█░░▒█▄░▒█░▒█▀▀▀              ///
///              ░▒█░▒█░█▄▀█░▒█▄▄█▒█▄▄█░▒█▒█▒█░░█▒░▒█▒█▒█░▒█▀▀▀              ///
///              ░▒█▄▄█░█▄▄█░▒█░░░▒█░▒█░▒█░░▒█░▄█▄░▒█░░▀█░▒█▄▄▄              ///
////////////////////////////////////////////////////////////////////////////////







interface IDopaminePartyNFT is IDopaminePartyNFTEventsAndErrors {

    
    
    function uri(uint256 id) external returns (string memory);

    
    
    
    function setBaseURI(string calldata newBaseURI) external;

    
    
    ///  if the specified NFT of type `id` does not exist.
    
    
    function setTokenURI(uint256 id, string calldata newTokenURI) external;

    
    
    
    function setOwner(address newOwner) external;

    
    
    
    
    function allowlist(uint256 id, bytes32 allowlistRoot) external;

    
    
    
    
    function airdrop(uint256 id, address[] calldata addresses) external;

    
    ///  merkle proof `proof` proves they were allowlisted for that NFT type.
    
    /// The allowlist is formed using sender addresses as leaves.
    
    
    function claim(
        bytes32[] calldata proof,
        uint256 id
    ) external;
}
pragma solidity ^0.8.15;

////////////////////////////////////////////////////////////////////////////////
///              ░▒█▀▀▄░█▀▀█░▒█▀▀█░█▀▀▄░▒█▀▄▀█░▄█░░▒█▄░▒█░▒█▀▀▀              ///
///              ░▒█░▒█░█▄▀█░▒█▄▄█▒█▄▄█░▒█▒█▒█░░█▒░▒█▒█▒█░▒█▀▀▀              ///
///              ░▒█▄▄█░█▄▄█░▒█░░░▒█░▒█░▒█░░▒█░▄█▄░▒█░░▀█░▒█▄▄▄              ///
////////////////////////////////////////////////////////////////////////////////






///  attendees of Dopamine's various IRL or virtual events & parties. This
///  ERC-1155 implementation additionally supports per NFT type supply tracking
///  and minting through airdrops or merkle allowlist claims. Each NFT type
///  uniquely identifies a specific party, thus attendees may own 1 max of each.
contract DopaminePartyNFT is ERC1155NT, IDopaminePartyNFT {

    string public name = "Dopamine Party NFTs";

    string public symbol = "PARTY";

    
    address public owner;

    
    
    string public baseURI;

    
    
    mapping(uint256 => string) public tokenURI;

    
    mapping(uint256 => uint256) public totalSupply;

    // Merkle roots for each NFT type (null if NFT type is not claimable).
    mapping(uint256 => bytes32) private _allowlist;

    // Counter for tracking the current NFT type id.
    uint256 private _id;

    
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert OwnerOnly();
        }
        _;
    }

    
    
    constructor(string memory baseURI_) {
        baseURI = baseURI_;
        emit BaseURISet(baseURI);

        owner = msg.sender;
        emit OwnerChanged(address(0), owner);
    }

    
    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
        emit BaseURISet(newBaseURI);
    }

    
    function setOwner(address newOwner) external onlyOwner {
        emit OwnerChanged(owner, newOwner);
        owner = newOwner;
    }

    
    function setTokenURI(uint256 id, string calldata newTokenURI)
        external
        onlyOwner
    {
        if (id >= _id) {
            revert TokenNonExistent();
        }
        if (bytes(tokenURI[id]).length != 0) {
            revert TokenImmutable();
        }
        tokenURI[id] = newTokenURI;
        emit TokenURISet(id, newTokenURI);
    }

    
    
    function uri(uint256 id) external view returns (string memory) {
        if (totalSupply[id] == 0) {
            revert TokenNonExistent();
        }

        if (bytes(tokenURI[id]).length == 0) {
            return string(abi.encodePacked(baseURI, _toString(id)));
        } else {
            return tokenURI[id];
        }
    }

    
    function allowlist(uint256 id, bytes32 allowlistRoot) external onlyOwner {
        if (id > _id) {
            revert TokenNonExistent();
        }

        // Retroactive claim changes are disallowed once metadata is immutable.
        if (bytes(tokenURI[id]).length != 0) {
            revert TokenImmutable();
        }

        _allowlist[id] = allowlistRoot;
        if (id == _id) {
            _id += 1;
            emit PartyNFTCreated(id, allowlistRoot);
        } else {
            emit PartyNFTUpdated(id, allowlistRoot);
        }
    }

    
    function airdrop(uint256 id, address[] calldata addresses)
        external
        onlyOwner
    {
        if (id > _id) {
            revert TokenNonExistent();
        }

        // Retroactive airdrops are disallowed once metadata is immutable.
        if (bytes(tokenURI[id]).length != 0) {
            revert TokenImmutable();
        }

        if (id == _id) {
            _id += 1;
            emit PartyNFTCreated(id, "");
        } else {
            emit PartyNFTUpdated(id, "");
        }

        uint256 numAddresses = addresses.length;
        for (uint256 i = 0; i < numAddresses; i++) {
            _mint(addresses[i], id);
        }
        totalSupply[id] += numAddresses;
    }

    // @inheritdoc IDopaminePartyNFT
    function claim(bytes32[] calldata proof, uint256 id) external {
        bytes32 tokenAllowlist = _allowlist[id];
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

        if (!_verify(tokenAllowlist, proof, leaf)) {
            revert ProofInvalid();
        }

        _mint(msg.sender, id);
        totalSupply[id]++;
    }

    
    ///  using proof `proof`. Merkle tree generation and proof construction is
    ///  done using the following JS library: github.com/miguelmota/merkletreejs
    
    
    
    
    function _verify(
        bytes32 merkleRoot,
        bytes32[] memory proof,
        bytes32 leaf
    ) private pure returns (bool) {
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;



/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
