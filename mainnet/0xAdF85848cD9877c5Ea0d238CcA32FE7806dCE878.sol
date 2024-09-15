// SPDX-License-Identifier: MIT


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
}

// 

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

pragma solidity ^0.8.0;









/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// 

pragma solidity ^0.8.0;



/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// 
pragma solidity 0.8.14;





///         proxy storage after an "upgradeToAndCall()" (delegatecall).

abstract contract OwnableProxyDelegation is Context {
    
    address private _owner;

    
    bytes32 internal constant _ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    
    bool public initialized;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    
    function initialize(address ownerAddr) external {
        require(ownerAddr != address(0), "OPD: INVALID_ADDRESS");
        require(!initialized, "OPD: INITIALIZED");
        require(StorageSlot.getAddressSlot(_ADMIN_SLOT).value == msg.sender, "OPD: FORBIDDEN");

        _setOwner(ownerAddr);

        initialized = true;
    }

    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(owner() == _msgSender(), "OPD: NOT_OWNER");
        _;
    }

    
    /// `onlyOwner` functions anymore. Can only be called by the current owner.
    ///
    /// NOTE: Renouncing ownership will leave the contract without an owner,
    /// thereby removing any functionality that is only available to the owner.
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    
    /// Can only be called by the current owner.
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "OPD: INVALID_ADDRESS");
        _setOwner(newOwner);
    }

    
    
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// 
pragma solidity 0.8.14;







abstract contract MixinOperatorResolver {
    
    
    
    event CacheUpdated(bytes32 name, IOperatorResolver.Operator destination);

    
    OperatorResolver public immutable resolver;

    
    mapping(bytes32 => IOperatorResolver.Operator) internal operatorCache;

    constructor(address _resolver) {
        require(_resolver != address(0), "MOR: INVALID_ADDRESS");
        resolver = OperatorResolver(_resolver);
    }

    
    ///      invoked via super in subclasses
    function resolverOperatorsRequired() public view virtual returns (bytes32[] memory) {}

    
    function rebuildCache() public {
        bytes32[] memory requiredOperators = resolverOperatorsRequired();
        bytes32 name;
        IOperatorResolver.Operator memory destination;
        // The resolver must call this function whenever it updates its state
        for (uint256 i = 0; i < requiredOperators.length; i++) {
            name = requiredOperators[i];
            // Note: can only be invoked once the resolver has all the targets needed added
            destination = resolver.getOperator(name);
            if (destination.implementation != address(0)) {
                operatorCache[name] = destination;
            } else {
                delete operatorCache[name];
            }
            emit CacheUpdated(name, destination);
        }
    }

    
    function isResolverCached() external view returns (bool) {
        bytes32[] memory requiredOperators = resolverOperatorsRequired();
        bytes32 name;
        IOperatorResolver.Operator memory cacheTmp;
        IOperatorResolver.Operator memory actualValue;
        for (uint256 i = 0; i < requiredOperators.length; i++) {
            name = requiredOperators[i];
            cacheTmp = operatorCache[name];
            actualValue = resolver.getOperator(name);
            // false if our cache is invalid or if the resolver doesn't have the required address
            if (
                actualValue.implementation != cacheTmp.implementation ||
                actualValue.selector != cacheTmp.selector ||
                cacheTmp.implementation == address(0)
            ) {
                return false;
            }
        }
        return true;
    }

    
    
    
    function requireAndGetAddress(bytes32 name) internal view returns (IOperatorResolver.Operator memory) {
        IOperatorResolver.Operator memory _foundAddress = operatorCache[name];
        require(_foundAddress.implementation != address(0), string(abi.encodePacked("MOR: MISSING_OPERATOR: ", name)));
        return _foundAddress;
    }

    
    
    
    
    
    
    ///         - amounts[0] : The amount of output token
    ///         - amounts[1] : The amount of input token USED by the operator (can be different than expected)
    function callOperator(
        INestedFactory.Order calldata _order,
        address _inputToken,
        address _outputToken
    ) internal returns (bool success, uint256[] memory amounts) {
        IOperatorResolver.Operator memory _operator = requireAndGetAddress(_order.operator);
        // Parameters are concatenated and padded to 32 bytes.
        // We are concatenating the selector + given params
        bytes memory data;
        (success, data) = _operator.implementation.delegatecall(bytes.concat(_operator.selector, _order.callData));

        if (success) {
            address[] memory tokens;
            (amounts, tokens) = abi.decode(data, (uint256[], address[]));
            require(tokens[0] == _outputToken, "MOR: INVALID_OUTPUT_TOKEN");
            require(tokens[1] == _inputToken, "MOR: INVALID_INPUT_TOKEN");
        }
    }
}

// 
pragma solidity 0.8.14;






interface INestedFactory {
    /* ------------------------------ EVENTS ------------------------------ */

    
    
    event FeeSplitterUpdated(address feeSplitter);

    
    
    event EntryFeesUpdated(uint256 entryFees);

    
    
    event ExitFeesUpdated(uint256 exitFees);

    
    
    event ReserveUpdated(address reserve);

    
    
    
    event NftCreated(uint256 indexed nftId, uint256 originalNftId);

    
    
    event NftUpdated(uint256 indexed nftId);

    
    
    event OperatorAdded(bytes32 newOperator);

    
    
    event OperatorRemoved(bytes32 oldOperator);

    
    
    
    event TokensUnlocked(address token, uint256 amount);

    /* ------------------------------ STRUCTS ------------------------------ */

    
    
    
    
    struct Order {
        bytes32 operator;
        address token;
        bytes callData;
    }

    
    
    
    
    
    ///        Note: fromReserve can be read as "from portfolio"
    struct BatchedInputOrders {
        IERC20 inputToken;
        uint256 amount;
        Order[] orders;
        bool fromReserve;
    }

    
    
    
    
    
    ///        Note: toReserve can be read as "to portfolio"
    struct BatchedOutputOrders {
        IERC20 outputToken;
        uint256[] amounts;
        Order[] orders;
        bool toReserve;
    }

    /* ------------------------------ OWNER FUNCTIONS ------------------------------ */

    
    
    function addOperator(bytes32 operator) external;

    
    
    function removeOperator(bytes32 operator) external;

    
    
    function setFeeSplitter(FeeSplitter _feeSplitter) external;

    
    ///         Where 1 = 0.01% and 10000 = 100%
    
    function setEntryFees(uint256 _entryFees) external;

    
    ///         Where 1 = 0.01% and 10000 = 100%
    
    function setExitFees(uint256 _exitFees) external;

    
    /// bad manipulations and send tokens to the contract.
    /// In response to that, the owner can retrieve the factory balance of a given token
    /// to later return users funds.
    
    function unlockTokens(IERC20 _token) external;

    /* ------------------------------ USERS FUNCTIONS ------------------------------ */

    
    
    
    function create(uint256 _originalTokenId, BatchedInputOrders[] calldata _batchedOrders) external payable;

    
    
    
    function processInputOrders(uint256 _nftId, BatchedInputOrders[] calldata _batchedOrders) external payable;

    
    
    
    function processOutputOrders(uint256 _nftId, BatchedOutputOrders[] calldata _batchedOrders) external;

    
    
    
    
    function processInputAndOutputOrders(
        uint256 _nftId,
        BatchedInputOrders[] calldata _batchedInputOrders,
        BatchedOutputOrders[] calldata _batchedOutputOrders
    ) external payable;

    
    
    
    
    
    function destroy(
        uint256 _nftId,
        IERC20 _buyToken,
        Order[] calldata _orders
    ) external;

    
    
    
    function withdraw(uint256 _nftId, uint256 _tokenIndex) external;

    
    /// Note: Can only increase the lock timestamp.
    
    
    function updateLockTimestamp(uint256 _nftId, uint256 _timestamp) external;
}

// 
pragma solidity 0.8.14;




interface IOperatorResolver {
    
    
    
    struct Operator {
        address implementation;
        bytes4 selector;
    }

    
    
    
    event OperatorImported(bytes32 name, Operator destination);

    
    
    
    function getOperator(bytes32 name) external view returns (Operator memory);

    
    
    
    
    function requireAndGetOperator(bytes32 name, string calldata reason) external view returns (Operator memory);

    
    
    
    
    
    function areOperatorsImported(bytes32[] calldata names, Operator[] calldata destinations)
        external
        view
        returns (bool);

    
    
    
    
    
    function importOperators(
        bytes32[] calldata names,
        Operator[] calldata operatorsToImport,
        MixinOperatorResolver[] calldata destinations
    ) external;
}

// 
pragma solidity 0.8.14;




abstract contract OwnableFactoryHandler is Ownable {
    
    
    event FactoryAdded(address newFactory);

    
    
    event FactoryRemoved(address oldFactory);

    
    mapping(address => bool) public supportedFactories;

    
    modifier onlyFactory() {
        require(supportedFactories[msg.sender], "OFH: FORBIDDEN");
        _;
    }

    
    
    function addFactory(address _factory) external onlyOwner {
        require(_factory != address(0), "OFH: INVALID_ADDRESS");
        supportedFactories[_factory] = true;
        emit FactoryAdded(_factory);
    }

    
    
    function removeFactory(address _factory) external onlyOwner {
        require(supportedFactories[_factory], "OFH: NOT_SUPPORTED");
        supportedFactories[_factory] = false;
        emit FactoryRemoved(_factory);
    }
}

// 

pragma solidity ^0.8.0;




/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}
// 
pragma solidity 0.8.14;

















contract NestedFactory is INestedFactory, ReentrancyGuard, OwnableProxyDelegation, MixinOperatorResolver {
    /* ----------------------------- VARIABLES ----------------------------- */

    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    
    bytes32[] private operators;

    
    FeeSplitter public feeSplitter;

    
    NestedReserve public immutable reserve;

    
    NestedAsset public immutable nestedAsset;

    
    /// Note: Will be WMATIC, WAVAX, WBNB,... Depending on the chain.
    IWETH public immutable weth;

    
    NestedRecords public immutable nestedRecords;

    
    Withdrawer private immutable withdrawer;

    
    ///      From 1 to 10,000 (0.01% to 100%)
    uint256 public entryFees;

    
    ///      From 1 to 10,000 (0.01% to 100%)
    uint256 public exitFees;

    /* ---------------------------- CONSTRUCTOR ---------------------------- */

    constructor(
        NestedAsset _nestedAsset,
        NestedRecords _nestedRecords,
        NestedReserve _reserve,
        FeeSplitter _feeSplitter,
        IWETH _weth,
        address _operatorResolver,
        Withdrawer _withdrawer
    ) MixinOperatorResolver(_operatorResolver) {
        require(
            address(_nestedAsset) != address(0) &&
                address(_nestedRecords) != address(0) &&
                address(_reserve) != address(0) &&
                address(_feeSplitter) != address(0) &&
                address(_weth) != address(0) &&
                _operatorResolver != address(0) &&
                address(_withdrawer) != address(0),
            "NF: INVALID_ADDRESS"
        );
        nestedAsset = _nestedAsset;
        nestedRecords = _nestedRecords;
        reserve = _reserve;
        feeSplitter = _feeSplitter;
        weth = _weth;
        withdrawer = _withdrawer;
    }

    
    ///      an address other than the withdrawer sends ether to
    ///      to the contract. The factory cannot handle ether but
    ///      has functions to withdraw ERC20 tokens if needed.
    receive() external payable {
        if (msg.sender != address(withdrawer)) {
            weth.deposit{ value: msg.value }();
        }
    }

    /* ------------------------------ MODIFIERS ---------------------------- */

    
    
    modifier onlyTokenOwner(uint256 _nftId) {
        require(nestedAsset.ownerOf(_nftId) == _msgSender(), "NF: CALLER_NOT_OWNER");
        _;
    }

    
    /// The block.timestamp must be greater than NFT record lock timestamp
    
    modifier isUnlocked(uint256 _nftId) {
        require(block.timestamp > nestedRecords.getLockTimestamp(_nftId), "NF: LOCKED_NFT");
        _;
    }

    /* ------------------------------- VIEWS ------------------------------- */

    
    function resolverOperatorsRequired() public view override returns (bytes32[] memory) {
        return operators;
    }

    /* -------------------------- OWNER FUNCTIONS -------------------------- */

    
    function addOperator(bytes32 operator) external override onlyOwner {
        require(operator != bytes32(""), "NF: INVALID_OPERATOR_NAME");
        bytes32[] memory operatorsCache = operators;
        for (uint256 i = 0; i < operatorsCache.length; i++) {
            require(operatorsCache[i] != operator, "NF: EXISTENT_OPERATOR");
        }
        operators.push(operator);
        rebuildCache();
        emit OperatorAdded(operator);
    }

    
    function removeOperator(bytes32 operator) external override onlyOwner {
        bytes32[] storage operatorsCache = operators;
        uint256 operatorsLength = operatorsCache.length;
        for (uint256 i = 0; i < operatorsLength; i++) {
            if (operatorsCache[i] == operator) {
                operatorsCache[i] = operators[operatorsLength - 1];
                operatorsCache.pop();
                if (operatorCache[operator].implementation != address(0)) {
                    delete operatorCache[operator]; // remove from cache
                }
                rebuildCache();
                emit OperatorRemoved(operator);
                return;
            }
        }
        revert("NF: NON_EXISTENT_OPERATOR");
    }

    
    function setFeeSplitter(FeeSplitter _feeSplitter) external override onlyOwner {
        require(address(_feeSplitter) != address(0), "NF: INVALID_FEE_SPLITTER_ADDRESS");
        feeSplitter = _feeSplitter;
        emit FeeSplitterUpdated(address(_feeSplitter));
    }

    
    function setEntryFees(uint256 _entryFees) external override onlyOwner {
        require(_entryFees != 0, "NF: ZERO_FEES");
        require(_entryFees <= 10000, "NF: FEES_OVERFLOW");
        entryFees = _entryFees;
        emit EntryFeesUpdated(_entryFees);
    }

    
    function setExitFees(uint256 _exitFees) external override onlyOwner {
        require(_exitFees != 0, "NF: ZERO_FEES");
        require(_exitFees <= 10000, "NF: FEES_OVERFLOW");
        exitFees = _exitFees;
        emit ExitFeesUpdated(_exitFees);
    }

    
    function unlockTokens(IERC20 _token) external override onlyOwner {
        uint256 amount = _token.balanceOf(address(this));
        SafeERC20.safeTransfer(_token, msg.sender, amount);
        emit TokensUnlocked(address(_token), amount);
    }

    /* -------------------------- USERS FUNCTIONS -------------------------- */

    
    function create(uint256 _originalTokenId, BatchedInputOrders[] calldata _batchedOrders)
        external
        payable
        override
        nonReentrant
    {
        uint256 batchedOrdersLength = _batchedOrders.length;
        require(batchedOrdersLength != 0, "NF: INVALID_MULTI_ORDERS");

        _checkMsgValue(_batchedOrders);
        uint256 nftId = nestedAsset.mint(_msgSender(), _originalTokenId);

        for (uint256 i = 0; i < batchedOrdersLength; i++) {
            (uint256 fees, IERC20 tokenSold) = _submitInOrders(nftId, _batchedOrders[i], false);
            _transferFeeWithRoyalty(fees, tokenSold, nftId);
        }

        emit NftCreated(nftId, _originalTokenId);
    }

    
    function processInputOrders(uint256 _nftId, BatchedInputOrders[] calldata _batchedOrders)
        external
        payable
        override
        nonReentrant
        onlyTokenOwner(_nftId)
        isUnlocked(_nftId)
    {
        _checkMsgValue(_batchedOrders);
        _processInputOrders(_nftId, _batchedOrders);
        emit NftUpdated(_nftId);
    }

    
    function processOutputOrders(uint256 _nftId, BatchedOutputOrders[] calldata _batchedOrders)
        external
        override
        nonReentrant
        onlyTokenOwner(_nftId)
        isUnlocked(_nftId)
    {
        _processOutputOrders(_nftId, _batchedOrders);
        emit NftUpdated(_nftId);
    }

    
    function processInputAndOutputOrders(
        uint256 _nftId,
        BatchedInputOrders[] calldata _batchedInputOrders,
        BatchedOutputOrders[] calldata _batchedOutputOrders
    ) external payable override nonReentrant onlyTokenOwner(_nftId) isUnlocked(_nftId) {
        _checkMsgValue(_batchedInputOrders);
        _processInputOrders(_nftId, _batchedInputOrders);
        _processOutputOrders(_nftId, _batchedOutputOrders);
        emit NftUpdated(_nftId);
    }

    
    function destroy(
        uint256 _nftId,
        IERC20 _buyToken,
        Order[] calldata _orders
    ) external override nonReentrant onlyTokenOwner(_nftId) isUnlocked(_nftId) {
        address[] memory tokens = nestedRecords.getAssetTokens(_nftId);
        uint256 tokensLength = tokens.length;
        require(_orders.length != 0, "NF: INVALID_ORDERS");
        require(tokensLength == _orders.length, "NF: INPUTS_LENGTH_MUST_MATCH");
        require(nestedRecords.getAssetReserve(_nftId) == address(reserve), "NF: RESERVE_MISMATCH");

        uint256 buyTokenInitialBalance = _buyToken.balanceOf(address(this));

        for (uint256 i = 0; i < tokensLength; i++) {
            address token = tokens[i];
            uint256 amount = _safeWithdraw(token, _nftId);
            _safeSubmitOrder(token, address(_buyToken), amount, _nftId, _orders[i]);
        }

        // Amount calculation to send fees and tokens
        uint256 amountBought = _buyToken.balanceOf(address(this)) - buyTokenInitialBalance;
        uint256 amountFees = (amountBought * exitFees) / 10000; // Exit Fees
        unchecked {
            amountBought -= amountFees;

            _transferFeeWithRoyalty(amountFees, _buyToken, _nftId);
            _safeTransferAndUnwrap(_buyToken, amountBought, _msgSender());
        }

        // Burn NFT
        nestedRecords.removeNFT(_nftId);
        nestedAsset.burn(_msgSender(), _nftId);
    }

    
    function withdraw(uint256 _nftId, uint256 _tokenIndex)
        external
        override
        nonReentrant
        onlyTokenOwner(_nftId)
        isUnlocked(_nftId)
    {
        uint256 assetTokensLength = nestedRecords.getAssetTokensLength(_nftId);
        require(assetTokensLength > _tokenIndex, "NF: INVALID_TOKEN_INDEX");
        // Use destroy instead if NFT has a single holding
        require(assetTokensLength > 1, "NF: UNALLOWED_EMPTY_PORTFOLIO");
        require(nestedRecords.getAssetReserve(_nftId) == address(reserve), "NF: RESERVE_MISMATCH");

        address token = nestedRecords.getAssetTokens(_nftId)[_tokenIndex];

        uint256 amount = _safeWithdraw(token, _nftId);
        _safeTransferWithFees(IERC20(token), amount, _msgSender(), _nftId);

        nestedRecords.deleteAsset(_nftId, _tokenIndex);
        emit NftUpdated(_nftId);
    }

    
    function updateLockTimestamp(uint256 _nftId, uint256 _timestamp) external override onlyTokenOwner(_nftId) {
        nestedRecords.updateLockTimestamp(_nftId, _timestamp);
    }

    /* ------------------------- PRIVATE FUNCTIONS ------------------------- */

    
    
    
    function _processInputOrders(uint256 _nftId, BatchedInputOrders[] calldata _batchedOrders) private {
        uint256 batchedOrdersLength = _batchedOrders.length;
        require(batchedOrdersLength != 0, "NF: INVALID_MULTI_ORDERS");
        require(nestedRecords.getAssetReserve(_nftId) == address(reserve), "NF: RESERVE_MISMATCH");

        for (uint256 i = 0; i < batchedOrdersLength; i++) {
            (uint256 fees, IERC20 tokenSold) = _submitInOrders(
                _nftId,
                _batchedOrders[i],
                _batchedOrders[i].fromReserve
            );
            _transferFeeWithRoyalty(fees, tokenSold, _nftId);
        }
    }

    
    
    
    function _processOutputOrders(uint256 _nftId, BatchedOutputOrders[] calldata _batchedOrders) private {
        uint256 batchedOrdersLength = _batchedOrders.length;
        require(batchedOrdersLength != 0, "NF: INVALID_MULTI_ORDERS");
        require(nestedRecords.getAssetReserve(_nftId) == address(reserve), "NF: RESERVE_MISMATCH");

        for (uint256 i = 0; i < batchedOrdersLength; i++) {
            (uint256 feesAmount, uint256 amountBought) = _submitOutOrders(
                _nftId,
                _batchedOrders[i],
                _batchedOrders[i].toReserve
            );
            _transferFeeWithRoyalty(feesAmount, _batchedOrders[i].outputToken, _nftId);
            if (!_batchedOrders[i].toReserve) {
                _safeTransferAndUnwrap(_batchedOrders[i].outputToken, amountBought - feesAmount, _msgSender());
            }
        }
    }

    
    /// to submit orders (where the input is one asset).
    
    
    
    
    
    function _submitInOrders(
        uint256 _nftId,
        BatchedInputOrders calldata _batchedOrders,
        bool _fromReserve
    ) private returns (uint256 feesAmount, IERC20 tokenSold) {
        uint256 batchLength = _batchedOrders.orders.length;
        require(batchLength != 0, "NF: INVALID_ORDERS");
        uint256 _inputTokenAmount;
        (tokenSold, _inputTokenAmount) = _transferInputTokens(
            _nftId,
            _batchedOrders.inputToken,
            _batchedOrders.amount,
            _fromReserve
        );

        uint256 amountSpent;
        for (uint256 i = 0; i < batchLength; i++) {
            uint256 spent = _submitOrder(
                address(tokenSold),
                _batchedOrders.orders[i].token,
                _nftId,
                _batchedOrders.orders[i],
                true // always to the reserve
            );
            amountSpent += spent;
            // Entry fees are computed on each order to make it easy to predict rounding errors
            feesAmount += (spent * entryFees) / 10000;
        }
        require(amountSpent <= _inputTokenAmount - feesAmount, "NF: OVERSPENT");
        unchecked {
            uint256 underSpentAmount = _inputTokenAmount - feesAmount - amountSpent;
            if (underSpentAmount != 0) {
                SafeERC20.safeTransfer(tokenSold, _fromReserve ? address(reserve) : _msgSender(), underSpentAmount);
            }

            // If input is from the reserve, update the records
            if (_fromReserve) {
                _decreaseHoldingAmount(_nftId, address(tokenSold), _inputTokenAmount - underSpentAmount);
            }
        }
    }

    
    /// to submit sell orders (where the output is one asset).
    
    
    
    
    
    function _submitOutOrders(
        uint256 _nftId,
        BatchedOutputOrders calldata _batchedOrders,
        bool _toReserve
    ) private returns (uint256 feesAmount, uint256 amountBought) {
        uint256 batchLength = _batchedOrders.orders.length;
        require(batchLength != 0, "NF: INVALID_ORDERS");
        require(_batchedOrders.amounts.length == batchLength, "NF: INPUTS_LENGTH_MUST_MATCH");
        amountBought = _batchedOrders.outputToken.balanceOf(address(this));

        IERC20 _inputToken;
        uint256 _inputTokenAmount;
        for (uint256 i = 0; i < batchLength; i++) {
            (_inputToken, _inputTokenAmount) = _transferInputTokens(
                _nftId,
                IERC20(_batchedOrders.orders[i].token),
                _batchedOrders.amounts[i],
                true
            );

            // Submit order and update holding of spent token
            uint256 amountSpent = _submitOrder(
                address(_inputToken),
                address(_batchedOrders.outputToken),
                _nftId,
                _batchedOrders.orders[i],
                false
            );
            require(amountSpent <= _inputTokenAmount, "NF: OVERSPENT");

            unchecked {
                uint256 underSpentAmount = _inputTokenAmount - amountSpent;
                if (underSpentAmount != 0) {
                    SafeERC20.safeTransfer(_inputToken, address(reserve), underSpentAmount);
                }
                _decreaseHoldingAmount(_nftId, address(_inputToken), _inputTokenAmount - underSpentAmount);
            }
        }

        amountBought = _batchedOrders.outputToken.balanceOf(address(this)) - amountBought;

        unchecked {
            // Entry or Exit Fees
            feesAmount = (amountBought * (_toReserve ? entryFees : exitFees)) / 10000;

            if (_toReserve) {
                _transferToReserveAndStore(_batchedOrders.outputToken, amountBought - feesAmount, _nftId);
            }
        }
    }

    
    /// assets to the reserve (if needed).
    
    
    
    
    
    
    function _submitOrder(
        address _inputToken,
        address _outputToken,
        uint256 _nftId,
        Order calldata _order,
        bool _toReserve
    ) private returns (uint256 amountSpent) {
        (bool success, uint256[] memory amounts) = callOperator(_order, _inputToken, _outputToken);
        // We raise the following error in case the call to the operator failed
        // We do not check the calldata to raise the specific error for now
        require(success, "NF: OPERATOR_CALL_FAILED");

        if (_toReserve) {
            _transferToReserveAndStore(IERC20(_outputToken), amounts[0], _nftId);
        }
        amountSpent = amounts[1];
    }

    
    ///      It will send the input token back to the msg.sender.
    /// Note : The _toReserve Boolean has been removed (compare to _submitOrder) since it was
    ///        useless for the only use case (destroy).
    
    
    
    
    
    function _safeSubmitOrder(
        address _inputToken,
        address _outputToken,
        uint256 _amountToSpend,
        uint256 _nftId,
        Order calldata _order
    ) private {
        (bool success, uint256[] memory amounts) = callOperator(_order, _inputToken, _outputToken);
        if (success) {
            require(amounts[1] <= _amountToSpend, "NF: OVERSPENT");
            unchecked {
                uint256 underSpentAmount = _amountToSpend - amounts[1];
                if (underSpentAmount != 0) {
                    _safeTransferWithFees(IERC20(_inputToken), underSpentAmount, _msgSender(), _nftId);
                }
            }
        } else {
            _safeTransferWithFees(IERC20(_inputToken), _amountToSpend, _msgSender(), _nftId);
        }
    }

    
    /// in the records. We need to know the amount received in case of deflationary tokens.
    
    
    
    function _transferToReserveAndStore(
        IERC20 _token,
        uint256 _amount,
        uint256 _nftId
    ) private {
        address reserveAddr = address(reserve);
        uint256 balanceReserveBefore = _token.balanceOf(reserveAddr);

        // Send output to reserve
        SafeERC20.safeTransfer(_token, reserveAddr, _amount);

        uint256 balanceReserveAfter = _token.balanceOf(reserveAddr);

        nestedRecords.store(_nftId, address(_token), balanceReserveAfter - balanceReserveBefore, reserveAddr);
    }

    
    ///      or the user wallet, to the factory.
    
    
    
    
    
    
    function _transferInputTokens(
        uint256 _nftId,
        IERC20 _inputToken,
        uint256 _inputTokenAmount,
        bool _fromReserve
    ) private returns (IERC20, uint256) {
        if (address(_inputToken) == ETH) {
            require(!_fromReserve, "NF: NO_ETH_FROM_RESERVE");
            require(address(this).balance >= _inputTokenAmount, "NF: INVALID_AMOUNT_IN");
            weth.deposit{ value: _inputTokenAmount }();
            return (IERC20(address(weth)), _inputTokenAmount);
        }

        uint256 balanceBefore = _inputToken.balanceOf(address(this));
        if (_fromReserve) {
            require(
                nestedRecords.getAssetHolding(_nftId, address(_inputToken)) >= _inputTokenAmount,
                "NF: INSUFFICIENT_AMOUNT_IN"
            );
            // Get input from reserve
            reserve.withdraw(_inputToken, _inputTokenAmount);
        } else {
            SafeERC20.safeTransferFrom(_inputToken, _msgSender(), address(this), _inputTokenAmount);
        }
        return (_inputToken, _inputToken.balanceOf(address(this)) - balanceBefore);
    }

    
    
    
    
    function _transferFeeWithRoyalty(
        uint256 _amount,
        IERC20 _token,
        uint256 _nftId
    ) private {
        address originalOwner = nestedAsset.originalOwner(_nftId);
        ExchangeHelpers.setMaxAllowance(_token, address(feeSplitter));
        if (originalOwner != address(0)) {
            feeSplitter.sendFeesWithRoyalties(originalOwner, _token, _amount);
        } else {
            feeSplitter.sendFees(_token, _amount);
        }
    }

    
    
    
    
    function _decreaseHoldingAmount(
        uint256 _nftId,
        address _inputToken,
        uint256 _amount
    ) private {
        nestedRecords.updateHoldingAmount(
            _nftId,
            _inputToken,
            nestedRecords.getAssetHolding(_nftId, _inputToken) - _amount
        );
    }

    
    ///      The token is unwrapped if WETH.
    
    
    
    function _safeTransferAndUnwrap(
        IERC20 _token,
        uint256 _amount,
        address _dest
    ) private {
        // if buy token is WETH, unwrap it instead of transferring it to the sender
        if (address(_token) == address(weth)) {
            ExchangeHelpers.setMaxAllowance(IERC20(address(weth)), address(withdrawer));
            withdrawer.withdraw(_amount);
            (bool success, ) = _dest.call{ value: _amount }("");
            require(success, "NF: ETH_TRANSFER_ERROR");
        } else {
            SafeERC20.safeTransfer(_token, _dest, _amount);
        }
    }

    
    
    
    
    
    function _safeTransferWithFees(
        IERC20 _token,
        uint256 _amount,
        address _dest,
        uint256 _nftId
    ) private {
        uint256 feeAmount = (_amount * exitFees) / 10000; // Exit Fee
        unchecked {
            _transferFeeWithRoyalty(feeAmount, _token, _nftId);
            SafeERC20.safeTransfer(_token, _dest, _amount - feeAmount);
        }
    }

    
    
    
    
    function _safeWithdraw(address _token, uint256 _nftId) private returns (uint256) {
        uint256 holdingAmount = nestedRecords.getAssetHolding(_nftId, _token);
        uint256 balanceBefore = IERC20(_token).balanceOf(address(this));
        reserve.withdraw(IERC20(_token), holdingAmount);
        return IERC20(_token).balanceOf(address(this)) - balanceBefore;
    }

    
    
    function _checkMsgValue(BatchedInputOrders[] calldata _batchedOrders) private {
        uint256 ethNeeded;
        for (uint256 i = 0; i < _batchedOrders.length; i++) {
            if (address(_batchedOrders[i].inputToken) == ETH) {
                ethNeeded += _batchedOrders[i].amount;
            }
        }
        require(msg.value == ethNeeded, "NF: WRONG_MSG_VALUE");
    }
}

// 

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
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
pragma solidity 0.8.14;




library ExchangeHelpers {
    using SafeERC20 for IERC20;

    
    
    
    
    
    function fillQuote(
        IERC20 _sellToken,
        address _swapTarget,
        bytes memory _swapCallData
    ) internal returns (bool) {
        setMaxAllowance(_sellToken, _swapTarget);
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = _swapTarget.call(_swapCallData);
        return success;
    }

    
    
    
    function setMaxAllowance(IERC20 _token, address _spender) internal {
        uint256 _currentAllowance = _token.allowance(address(this), _spender);
        if (_currentAllowance != type(uint256).max) {
            // Decrease to 0 first for tokens mitigating the race condition
            _token.safeDecreaseAllowance(_spender, _currentAllowance);
            _token.safeIncreaseAllowance(_spender, type(uint256).max);
        }
    }
}

// 
pragma solidity 0.8.14;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;

    function totalSupply() external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function balanceOf(address recipien) external returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// 
pragma solidity 0.8.14;










/// shareholders (the NFT owners, Nested treasury and a NST buybacker contract).
contract FeeSplitter is Ownable, ReentrancyGuard {
    /* ------------------------------ EVENTS ------------------------------ */

    
    
    
    
    event PaymentReleased(address to, address token, uint256 amount);

    
    
    
    
    event PaymentReceived(address from, address token, uint256 amount);

    
    
    event RoyaltiesWeightUpdated(uint256 weight);

    
    
    
    event ShareholdersAdded(address account, uint256 weight);

    
    
    
    event ShareholderUpdated(address account, uint256 weight);

    
    
    
    
    event RoyaltiesReceived(address to, address token, uint256 value);

    /* ------------------------------ STRUCTS ------------------------------ */

    
    
    
    struct Shareholder {
        address account;
        uint96 weight;
    }

    
    struct TokenRecords {
        uint256 totalShares;
        uint256 totalReleased;
        mapping(address => uint256) shares;
        mapping(address => uint256) released;
    }

    /* ----------------------------- VARIABLES ----------------------------- */

    
    mapping(address => TokenRecords) private tokenRecords;

    
    Shareholder[] private shareholders;

    
    uint256 public royaltiesWeight;

    uint256 public totalWeights;

    address public immutable weth;

    /* ---------------------------- CONSTRUCTOR ---------------------------- */

    constructor(
        address[] memory _accounts,
        uint96[] memory _weights,
        uint256 _royaltiesWeight,
        address _weth
    ) {
        require(_weth != address(0), "FS: INVALID_ADDRESS");
        // Initial shareholders addresses and weights
        setShareholders(_accounts, _weights);
        setRoyaltiesWeight(_royaltiesWeight);
        weth = _weth;
    }

    
    receive() external payable {
        require(msg.sender == weth, "FS: ETH_SENDER_NOT_WETH");
    }

    /* -------------------------- OWNER FUNCTIONS -------------------------- */

    
    
    function setRoyaltiesWeight(uint256 _weight) public onlyOwner {
        require(_weight != 0, "FS: WEIGHT_ZERO");
        totalWeights = totalWeights + _weight - royaltiesWeight;
        royaltiesWeight = _weight;
        emit RoyaltiesWeightUpdated(_weight);
    }

    
    
    
    function setShareholders(address[] memory _accounts, uint96[] memory _weights) public onlyOwner {
        delete shareholders;
        uint256 accountsLength = _accounts.length;
        require(accountsLength != 0, "FS: EMPTY_ARRAY");
        require(accountsLength == _weights.length, "FS: INPUTS_LENGTH_MUST_MATCH");
        totalWeights = royaltiesWeight;

        for (uint256 i = 0; i < accountsLength; i++) {
            _addShareholder(_accounts[i], _weights[i]);
        }
    }

    
    
    
    function updateShareholder(uint256 _accountIndex, uint96 _weight) external onlyOwner {
        require(_weight != 0, "FS: INVALID_WEIGHT");
        require(_accountIndex < shareholders.length, "FS: INVALID_ACCOUNT_INDEX");
        Shareholder storage _shareholder = shareholders[_accountIndex];
        totalWeights = totalWeights + _weight - _shareholder.weight;
        require(totalWeights != 0, "FS: TOTAL_WEIGHTS_ZERO");
        _shareholder.weight = _weight;
        emit ShareholderUpdated(_shareholder.account, _weight);
    }

    /* -------------------------- USERS FUNCTIONS -------------------------- */

    
    
    function releaseTokens(IERC20[] calldata _tokens) external nonReentrant {
        uint256 amount;
        for (uint256 i = 0; i < _tokens.length; i++) {
            amount = _releaseToken(_msgSender(), _tokens[i]);
            if (address(_tokens[i]) == weth) {
                IWETH(weth).withdraw(amount);
                (bool success, ) = _msgSender().call{ value: amount }("");
                require(success, "FS: ETH_TRANFER_ERROR");
            } else {
                SafeERC20.safeTransfer(_tokens[i], _msgSender(), amount);
            }
            emit PaymentReleased(_msgSender(), address(_tokens[i]), amount);
        }
    }

    
    
    function releaseTokensNoETH(IERC20[] calldata _tokens) external nonReentrant {
        uint256 amount;
        for (uint256 i = 0; i < _tokens.length; i++) {
            amount = _releaseToken(_msgSender(), _tokens[i]);
            SafeERC20.safeTransfer(_tokens[i], _msgSender(), amount);
            emit PaymentReleased(_msgSender(), address(_tokens[i]), amount);
        }
    }

    
    
    
    function sendFees(IERC20 _token, uint256 _amount) external nonReentrant {
        uint256 weights;
        unchecked {
            weights = totalWeights - royaltiesWeight;
        }

        uint256 balanceBeforeTransfer = _token.balanceOf(address(this));
        SafeERC20.safeTransferFrom(_token, _msgSender(), address(this), _amount);

        _sendFees(_token, _token.balanceOf(address(this)) - balanceBeforeTransfer, weights);
    }

    
    
    
    
    function sendFeesWithRoyalties(
        address _royaltiesTarget,
        IERC20 _token,
        uint256 _amount
    ) external nonReentrant {
        require(_royaltiesTarget != address(0), "FS: INVALID_ROYALTIES_TARGET");

        uint256 balanceBeforeTransfer = _token.balanceOf(address(this));
        SafeERC20.safeTransferFrom(_token, _msgSender(), address(this), _amount);
        uint256 amountReceived = _token.balanceOf(address(this)) - balanceBeforeTransfer;

        uint256 _totalWeights = totalWeights;
        uint256 royaltiesAmount = (amountReceived * royaltiesWeight) / _totalWeights;

        _sendFees(_token, amountReceived, _totalWeights);
        _addShares(_royaltiesTarget, royaltiesAmount, address(_token));

        emit RoyaltiesReceived(_royaltiesTarget, address(_token), royaltiesAmount);
    }

    /* ------------------------------- VIEWS ------------------------------- */

    
    
    
    
    function getAmountDue(address _account, IERC20 _token) public view returns (uint256) {
        TokenRecords storage _tokenRecords = tokenRecords[address(_token)];
        uint256 _totalShares = _tokenRecords.totalShares;
        if (_totalShares == 0) return 0;

        uint256 totalReceived = _tokenRecords.totalReleased + _token.balanceOf(address(this));
        return (totalReceived * _tokenRecords.shares[_account]) / _totalShares - _tokenRecords.released[_account];
    }

    
    
    
    function totalShares(address _token) external view returns (uint256) {
        return tokenRecords[_token].totalShares;
    }

    
    
    
    function totalReleased(address _token) external view returns (uint256) {
        return tokenRecords[_token].totalReleased;
    }

    
    
    
    
    function shares(address _account, address _token) external view returns (uint256) {
        return tokenRecords[_token].shares[_account];
    }

    
    
    
    
    function released(address _account, address _token) external view returns (uint256) {
        return tokenRecords[_token].released[_account];
    }

    
    
    
    function findShareholder(address _account) external view returns (uint256) {
        for (uint256 i = 0; i < shareholders.length; i++) {
            if (shareholders[i].account == _account) return i;
        }
        revert("FS: SHAREHOLDER_NOT_FOUND");
    }

    /* ------------------------- PRIVATE FUNCTIONS ------------------------- */

    
    
    
    
    
    function _sendFees(
        IERC20 _token,
        uint256 _amount,
        uint256 _totalWeights
    ) private {
        Shareholder[] memory shareholdersCache = shareholders;
        for (uint256 i = 0; i < shareholdersCache.length; i++) {
            _addShares(
                shareholdersCache[i].account,
                (_amount * shareholdersCache[i].weight) / _totalWeights,
                address(_token)
            );
        }
        emit PaymentReceived(_msgSender(), address(_token), _amount);
    }

    
    
    
    
    function _addShares(
        address _account,
        uint256 _shares,
        address _token
    ) private {
        TokenRecords storage _tokenRecords = tokenRecords[_token];
        _tokenRecords.shares[_account] += _shares;
        _tokenRecords.totalShares += _shares;
    }

    function _releaseToken(address _account, IERC20 _token) private returns (uint256) {
        uint256 amountToRelease = getAmountDue(_account, _token);
        require(amountToRelease != 0, "FS: NO_PAYMENT_DUE");

        TokenRecords storage _tokenRecords = tokenRecords[address(_token)];
        _tokenRecords.released[_account] += amountToRelease;
        _tokenRecords.totalReleased += amountToRelease;

        return amountToRelease;
    }

    function _addShareholder(address _account, uint96 _weight) private {
        require(_weight != 0, "FS: ZERO_WEIGHT");
        require(_account != address(0), "FS: INVALID_ADDRESS");
        for (uint256 i = 0; i < shareholders.length; i++) {
            require(shareholders[i].account != _account, "FS: ALREADY_SHAREHOLDER");
        }

        shareholders.push(Shareholder(_account, _weight));
        totalWeights += _weight;
        emit ShareholdersAdded(_account, _weight);
    }
}

// 
pragma solidity 0.8.14;






///         holds funds present in this contract. Only the factory can withdraw/transfer assets.
contract NestedReserve is OwnableFactoryHandler {
    
    
    
    
    function transfer(
        address _recipient,
        IERC20 _token,
        uint256 _amount
    ) external onlyFactory {
        require(_recipient != address(0), "NRS: INVALID_ADDRESS");
        SafeERC20.safeTransfer(_token, _recipient, _amount);
    }

    
    
    
    function withdraw(IERC20 _token, uint256 _amount) external onlyFactory {
        SafeERC20.safeTransfer(_token, msg.sender, _amount);
    }
}

// 
pragma solidity 0.8.14;







contract NestedAsset is ERC721Enumerable, OwnableFactoryHandler {
    using Counters for Counters.Counter;

    /* ----------------------------- VARIABLES ----------------------------- */

    Counters.Counter private _tokenIds;

    
    string public baseUri;

    
    string public unrevealedTokenUri;

    
    string public contractUri;

    
    mapping(uint256 => uint256) public originalAsset;

    
    mapping(uint256 => address) public lastOwnerBeforeBurn;

    
    bool public isRevealed;

    /* ---------------------------- CONSTRUCTORS --------------------------- */

    constructor() ERC721("NestedNFT", "NESTED") {}

    /* ----------------------------- MODIFIERS ----------------------------- */

    
    modifier onlyTokenOwner(address _address, uint256 _tokenId) {
        require(_address == ownerOf(_tokenId), "NA: FORBIDDEN_NOT_OWNER");
        _;
    }

    /* ------------------------------- VIEWS ------------------------------- */

    
    
    
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "URI query for nonexistent token");
        if (isRevealed) {
            return super.tokenURI(_tokenId);
        } else {
            return unrevealedTokenUri;
        }
    }

    
    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    
    /// If the original asset was burnt, the last owner before burn is returned
    
    
    function originalOwner(uint256 _tokenId) external view returns (address) {
        uint256 originalAssetId = originalAsset[_tokenId];

        if (originalAssetId != 0) {
            return _exists(originalAssetId) ? ownerOf(originalAssetId) : lastOwnerBeforeBurn[originalAssetId];
        }
        return address(0);
    }

    /* ---------------------------- ONLY FACTORY --------------------------- */

    
    
    
    
    function mint(address _owner, uint256 _replicatedTokenId) public onlyFactory returns (uint256) {
        _tokenIds.increment();

        uint256 tokenId = _tokenIds.current();
        _safeMint(_owner, tokenId);

        // Stores the first asset of the replication chain as the original
        if (_replicatedTokenId == 0) {
            return tokenId;
        }

        require(_exists(_replicatedTokenId), "NA: NON_EXISTENT_TOKEN_ID");
        require(tokenId != _replicatedTokenId, "NA: SELF_DUPLICATION");

        uint256 originalTokenId = originalAsset[_replicatedTokenId];
        originalAsset[tokenId] = originalTokenId != 0 ? originalTokenId : _replicatedTokenId;

        return tokenId;
    }

    
    
    
    function burn(address _owner, uint256 _tokenId) external onlyFactory onlyTokenOwner(_owner, _tokenId) {
        lastOwnerBeforeBurn[_tokenId] = _owner;
        _burn(_tokenId);
    }

    /* ----------------------------- ONLY OWNER ---------------------------- */

    
    function setIsRevealed(bool _isRevealed) external onlyOwner {
        isRevealed = _isRevealed;
    }

    
    
    function setBaseURI(string memory _baseUri) external onlyOwner {
        require(bytes(_baseUri).length != 0, "NA: EMPTY_URI");
        baseUri = _baseUri;
    }

    
    
    function setUnrevealedTokenURI(string memory _newUri) external onlyOwner {
        require(bytes(_newUri).length != 0, "NA: EMPTY_URI");
        unrevealedTokenUri = _newUri;
    }

    
    
    function setContractURI(string memory _newUri) external onlyOwner {
        contractUri = _newUri;
    }
}

// 
pragma solidity 0.8.14;




contract NestedRecords is OwnableFactoryHandler {
    /* ------------------------------ EVENTS ------------------------------ */

    
    
    event MaxHoldingsChanges(uint256 maxHoldingsCount);

    
    
    
    event LockTimestampIncreased(uint256 nftId, uint256 timestamp);

    
    
    
    event ReserveUpdated(uint256 nftId, address newReserve);

    /* ------------------------------ STRUCTS ------------------------------ */

    
    struct NftRecord {
        mapping(address => uint256) holdings;
        address[] tokens;
        address reserve;
        uint256 lockTimestamp;
    }

    /* ----------------------------- VARIABLES ----------------------------- */

    
    mapping(uint256 => NftRecord) public records;

    
    uint256 public maxHoldingsCount;

    /* ---------------------------- CONSTRUCTOR ---------------------------- */

    constructor(uint256 _maxHoldingsCount) {
        maxHoldingsCount = _maxHoldingsCount;
    }

    /* -------------------------- OWNER FUNCTIONS -------------------------- */

    
    
    function setMaxHoldingsCount(uint256 _maxHoldingsCount) external onlyOwner {
        require(_maxHoldingsCount != 0, "NRC: INVALID_MAX_HOLDINGS");
        maxHoldingsCount = _maxHoldingsCount;
        emit MaxHoldingsChanges(maxHoldingsCount);
    }

    /* ------------------------- FACTORY FUNCTIONS ------------------------- */

    
    /// the holding if the amount is zero.
    
    
    
    function updateHoldingAmount(
        uint256 _nftId,
        address _token,
        uint256 _amount
    ) public onlyFactory {
        if (_amount == 0) {
            uint256 tokenIndex = 0;
            address[] memory tokens = getAssetTokens(_nftId);
            while (tokenIndex < tokens.length) {
                if (tokens[tokenIndex] == _token) {
                    deleteAsset(_nftId, tokenIndex);
                    break;
                }
                tokenIndex++;
            }
        } else {
            records[_nftId].holdings[_token] = _amount;
        }
    }

    
    
    
    function deleteAsset(uint256 _nftId, uint256 _tokenIndex) public onlyFactory {
        address[] storage tokens = records[_nftId].tokens;
        address token = tokens[_tokenIndex];

        require(records[_nftId].holdings[token] != 0, "NRC: HOLDING_INACTIVE");

        delete records[_nftId].holdings[token];
        tokens[_tokenIndex] = tokens[tokens.length - 1];
        tokens.pop();
    }

    
    
    
    function freeHolding(uint256 _nftId, address _token) public onlyFactory {
        delete records[_nftId].holdings[_token];
    }

    
    
    
    
    
    function store(
        uint256 _nftId,
        address _token,
        uint256 _amount,
        address _reserve
    ) external onlyFactory {
        NftRecord storage _nftRecord = records[_nftId];

        uint256 amount = records[_nftId].holdings[_token];
        require(_amount != 0, "NRC: INVALID_AMOUNT");
        if (amount != 0) {
            require(_nftRecord.reserve == _reserve, "NRC: RESERVE_MISMATCH");
            updateHoldingAmount(_nftId, _token, amount + _amount);
            return;
        }
        require(_nftRecord.tokens.length < maxHoldingsCount, "NRC: TOO_MANY_TOKENS");
        require(
            _reserve != address(0) && (_reserve == _nftRecord.reserve || _nftRecord.reserve == address(0)),
            "NRC: INVALID_RESERVE"
        );

        _nftRecord.holdings[_token] = _amount;
        _nftRecord.tokens.push(_token);
        _nftRecord.reserve = _reserve;
    }

    
    /// The new timestamp must be greater than the records lockTimestamp
    //  if block.timestamp > actual lock timestamp
    
    
    function updateLockTimestamp(uint256 _nftId, uint256 _timestamp) external onlyFactory {
        require(_timestamp > records[_nftId].lockTimestamp, "NRC: LOCK_PERIOD_CANT_DECREASE");
        records[_nftId].lockTimestamp = _timestamp;
        emit LockTimestampIncreased(_nftId, _timestamp);
    }

    
    
    function removeNFT(uint256 _nftId) external onlyFactory {
        delete records[_nftId];
    }

    
    
    
    function setReserve(uint256 _nftId, address _nextReserve) external onlyFactory {
        records[_nftId].reserve = _nextReserve;
        emit ReserveUpdated(_nftId, _nextReserve);
    }

    /* ------------------------------- VIEWS ------------------------------- */

    
    
    
    function getAssetTokens(uint256 _nftId) public view returns (address[] memory) {
        return records[_nftId].tokens;
    }

    
    
    
    function getAssetReserve(uint256 _nftId) external view returns (address) {
        return records[_nftId].reserve;
    }

    
    
    
    function getAssetTokensLength(uint256 _nftId) external view returns (uint256) {
        return records[_nftId].tokens.length;
    }

    
    
    
    
    function getAssetHolding(uint256 _nftId, address _token) public view returns (uint256) {
        return records[_nftId].holdings[_token];
    }

    
    
    
    ///         - The token addresses in the portfolio
    ///         - The respective amounts
    function tokenHoldings(uint256 _nftId) external view returns (address[] memory, uint256[] memory) {
        address[] memory tokens = getAssetTokens(_nftId);
        uint256 tokensCount = tokens.length;
        uint256[] memory amounts = new uint256[](tokensCount);

        for (uint256 i = 0; i < tokensCount; i++) {
            amounts[i] = getAssetHolding(_nftId, tokens[i]);
        }
        return (tokens, amounts);
    }

    
    
    
    function getLockTimestamp(uint256 _nftId) external view returns (uint256) {
        return records[_nftId].lockTimestamp;
    }
}

// 
pragma solidity 0.8.14;







///      of the sender. Upgradeable proxy contracts are not able to receive
///      native tokens from contracts via `transfer` (EIP1884), they need a
///      middleman forwarding all available gas and reverting on errors.
contract Withdrawer is ReentrancyGuard {
    IWETH public immutable weth;

    constructor(IWETH _weth) {
        weth = _weth;
    }

    receive() external payable {
        require(msg.sender == address(weth), "WD: ETH_SENDER_NOT_WETH");
    }

    
    
    function withdraw(uint256 amount) external nonReentrant {
        weth.transferFrom(msg.sender, address(this), amount);
        weth.withdraw(amount);
        Address.sendValue(payable(msg.sender), amount);
    }
}

// 

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
pragma solidity 0.8.14;







contract OperatorResolver is IOperatorResolver, Ownable {
    
    mapping(bytes32 => Operator) public operators;

    
    function getOperator(bytes32 name) external view override returns (Operator memory) {
        return operators[name];
    }

    
    function requireAndGetOperator(bytes32 name, string calldata reason)
        external
        view
        override
        returns (Operator memory)
    {
        Operator memory _foundOperator = operators[name];
        require(_foundOperator.implementation != address(0), reason);
        return _foundOperator;
    }

    
    function areOperatorsImported(bytes32[] calldata names, Operator[] calldata destinations)
        external
        view
        override
        returns (bool)
    {
        uint256 namesLength = names.length;
        require(namesLength == destinations.length, "OR: INPUTS_LENGTH_MUST_MATCH");
        for (uint256 i = 0; i < namesLength; i++) {
            if (
                operators[names[i]].implementation != destinations[i].implementation ||
                operators[names[i]].selector != destinations[i].selector
            ) {
                return false;
            }
        }
        return true;
    }

    
    function importOperators(
        bytes32[] calldata names,
        Operator[] calldata operatorsToImport,
        MixinOperatorResolver[] calldata destinations
    ) external override onlyOwner {
        require(names.length == operatorsToImport.length, "OR: INPUTS_LENGTH_MUST_MATCH");
        bytes32 name;
        Operator calldata destination;
        for (uint256 i = 0; i < names.length; i++) {
            name = names[i];
            destination = operatorsToImport[i];
            operators[name] = destination;
            emit OperatorImported(name, destination);
        }

        // rebuild caches atomically
        // see. https://github.com/code-423n4/2021-11-nested-findings/issues/217
        rebuildCaches(destinations);
    }

    
    
    function rebuildCaches(MixinOperatorResolver[] calldata destinations) public onlyOwner {
        for (uint256 i = 0; i < destinations.length; i++) {
            destinations[i].rebuildCache();
        }
    }
}

// 

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
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

// 

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// 

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

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

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}
