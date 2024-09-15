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

// 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// 
pragma solidity ^0.8.12;

interface IBase721A {
    
    
    
    
    function mintTo(
        address to,
        uint256 amount,
        uint24 extraData
    ) external;
}
//
pragma solidity ^0.8.12;







interface ITPLRevealedParts is IBase721A {
    struct TokenData {
        uint256 generation;
        uint256 originalId;
        uint256 bodyPart;
        uint256 model;
        uint256[] stats;
    }

    
    
    
    
    function isOwnerOfBatch(address account, uint256[] calldata tokenIds) external view returns (bool);

    
    
    
    function partData(uint256 tokenId) external view returns (TokenData memory);

    
    
    
    function partDataBatch(uint256[] calldata tokenIds) external view returns (TokenData[] memory);

    
    
    function burnBatch(uint256[] calldata tokenIds) external;
}

//
pragma solidity ^0.8.12;










contract TPLSwap is IERC1155Receiver, ERC165 {
    error UnknownContract();

    address public immutable UNREVEALED_PARTS;
    address public immutable REVEALED_PARTS;

    modifier onlyKnownContract() {
        if (msg.sender != UNREVEALED_PARTS) {
            revert UnknownContract();
        }
        _;
    }

    constructor(address unrevealed, address revealed) {
        UNREVEALED_PARTS = unrevealed;
        REVEALED_PARTS = revealed;
    }

    /////////////////////////////////////////////////////////
    // Getters                                             //
    /////////////////////////////////////////////////////////

    function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }

    /////////////////////////////////////////////////////////
    // Interaction                                         //
    /////////////////////////////////////////////////////////

    
    
    
    
    function swap(uint256[] calldata ids, uint256[] calldata amounts) external {
        IERC1155Burnable(UNREVEALED_PARTS).burnBatch(msg.sender, ids, amounts);

        uint256 length = ids.length;
        for (uint256 i; i < length; i++) {
            _mintBodyPartFrom(msg.sender, ids[i], amounts[i]);
        }
    }

    /////////////////////////////////////////////////////////
    // Callbacks / Hooks                                   //
    /////////////////////////////////////////////////////////

    
    
    function onERC1155Received(
        address, /*operator*/
        address from,
        uint256 id,
        uint256 value,
        bytes calldata
    ) external onlyKnownContract returns (bytes4) {
        // burn
        IERC1155Burnable(msg.sender).burn(address(this), id, value);

        // mint
        _mintBodyPartFrom(from, id, value);

        // ACK
        return this.onERC1155Received.selector;
    }

    
    
    function onERC1155BatchReceived(
        address, /* operator */
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata
    ) external onlyKnownContract returns (bytes4) {
        // burn
        IERC1155Burnable(msg.sender).burnBatch(address(this), ids, values);

        // mint
        uint256 length = ids.length;
        for (uint256 i; i < length; i++) {
            _mintBodyPartFrom(from, ids[i], values[i]);
        }

        // ACK
        return this.onERC1155BatchReceived.selector;
    }

    /////////////////////////////////////////////////////////
    // Internals                                           //
    /////////////////////////////////////////////////////////

    
    
    
    
    function _mintBodyPartFrom(
        address to,
        uint256 id,
        uint256 amount
    ) internal {
        // most left 12 bits are the original unrevealed id
        // most right 12 bits is the "generation" of the part. Here all parts are Genesis parts
        uint24 packedData = uint24((id << 12) | 1);

        // mint `amount` revealed parts to `to` with `packedData`
        ITPLRevealedParts(REVEALED_PARTS).mintTo(to, amount, packedData);
    }
}

interface IERC1155Burnable {
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
