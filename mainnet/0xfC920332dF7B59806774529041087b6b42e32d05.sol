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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
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
pragma solidity ^0.8.9;



interface IERC2981Royalties {
    
    //          is owed and to whom.
    
    
    
    
    function royaltyInfo(uint256 _tokenId, uint256 _value)
        external
        view
        returns (address _receiver, uint256 _royaltyAmount);
}

// 

pragma solidity ^0.8.0;










/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

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
    function __ERC721_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);

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
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
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
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
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
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
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
    uint256[44] private __gap;
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



interface IERC721WithMutableURI {
    function mutableURI(uint256 tokenId) external view returns (string memory);
}

//
pragma solidity ^0.8.9;




///      gas-less trading and contractURI support
contract BaseOpenSea {
    event NewContractURI(string contractURI);

    string private _contractURI;
    address private _proxyRegistry;

    
    //          about a contract (owner, royalties etc...)
    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    
    function proxyRegistry() public view returns (address) {
        return _proxyRegistry;
    }

    
    ///         for owner
    
    ///      or to check if operator is OpenSea's proxy contract on Polygon and Mumbai
    
    
    function isOwnersOpenSeaProxy(address owner, address operator)
        public
        view
        returns (bool)
    {
        address proxyRegistry_ = _proxyRegistry;

        // if we have a proxy registry
        if (proxyRegistry_ != address(0)) {
            // on ethereum mainnet or rinkeby use "ProxyRegistry" to
            // get owner's proxy
            if (block.chainid == 1 || block.chainid == 4) {
                return
                    address(ProxyRegistry(proxyRegistry_).proxies(owner)) ==
                    operator;
            } else if (block.chainid == 137 || block.chainid == 80001) {
                // on Polygon and Mumbai just try with OpenSea's proxy contract
                // https://docs.opensea.io/docs/polygon-basic-integration
                return proxyRegistry_ == operator;
            }
        }

        return false;
    }

    
    
    function _setContractURI(string memory contractURI_) internal {
        _contractURI = contractURI_;
        emit NewContractURI(contractURI_);
    }

    
    
    function _setOpenSeaRegistry(address proxyRegistryAddress) internal {
        _proxyRegistry = proxyRegistryAddress;
    }
}

// 
pragma solidity ^0.8.9;




abstract contract ERC2981Royalties is IERC2981Royalties {
    struct RoyaltyData {
        address recipient;
        uint96 amount;
    }

    // this variable is set to true, whenever "contract wide" royalties are set
    // this can not be undone and this takes precedence to any other royalties already set.
    bool private _useContractRoyalties;

    // those are the "contract wide" royalties, used for collections that all pay royalties to
    // the same recipient, with the same value
    // once set, like any other royalties, it can not be modified
    RoyaltyData private _contractRoyalties;

    mapping(uint256 => RoyaltyData) private _royalties;

    function hasPerTokenRoyalties() public view returns (bool) {
        return !_useContractRoyalties;
    }

    
    function royaltyInfo(uint256 tokenId, uint256 value)
        public
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        // get base values
        (receiver, royaltyAmount) = _getTokenRoyalty(tokenId);

        // calculate due amount
        if (royaltyAmount != 0) {
            royaltyAmount = (value * royaltyAmount) / 10000;
        }
    }

    
    
    function _removeRoyalty(uint256 id) internal {
        delete _royalties[id];
    }

    
    
    
    
    function _setTokenRoyalty(
        uint256 id,
        address recipient,
        uint256 value
    ) internal {
        // you can't set per token royalties if using "contract wide" ones
        require(
            !_useContractRoyalties,
            '!ERC2981Royalties:ROYALTIES_CONTRACT_WIDE!'
        );
        require(value <= 10000, '!ERC2981Royalties:TOO_HIGH!');

        _royalties[id] = RoyaltyData(recipient, uint96(value));
    }

    
    
    function _getTokenRoyalty(uint256 id)
        internal
        view
        virtual
        returns (address, uint256)
    {
        RoyaltyData memory data;
        if (_useContractRoyalties) {
            data = _contractRoyalties;
        } else {
            data = _royalties[id];
        }

        return (data.recipient, uint256(data.amount));
    }

    
    ///      This can only be set once, because we are of the idea that royalties
    ///      Amounts should never change after they have been set
    ///      Once default values are set, it will be used for all royalties inquiries
    
    
    function _setDefaultRoyalties(address recipient, uint256 value) internal {
        require(
            _useContractRoyalties == false,
            '!ERC2981Royalties:DEFAULT_ALREADY_SET!'
        );
        require(value <= 10000, '!ERC2981Royalties:TOO_HIGH!');
        _useContractRoyalties = true;
        _contractRoyalties = RoyaltyData(recipient, uint96(value));
    }

    
    
    function _setDefaultRoyaltiesRecipient(address recipient) internal {
        _contractRoyalties.recipient = recipient;
    }

    
    
    
    function _setTokenRoyaltiesRecipient(uint256 tokenId, address recipient)
        internal
    {
        _royalties[tokenId].recipient = recipient;
    }
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
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be irreversibly burned (destroyed).
 */
abstract contract ERC721BurnableUpgradeable is Initializable, ContextUpgradeable, ERC721Upgradeable {
    function __ERC721Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Burnable_init_unchained();
    }

    function __ERC721Burnable_init_unchained() internal initializer {
    }
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
    uint256[50] private __gap;
}

// 

pragma solidity ^0.8.0;




/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorageUpgradeable is Initializable, ERC721Upgradeable {
    function __ERC721URIStorage_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721URIStorage_init_unchained();
    }

    function __ERC721URIStorage_init_unchained() internal initializer {
    }
    using StringsUpgradeable for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
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
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
    uint256[49] private __gap;
}

//
pragma solidity ^0.8.9;








contract ERC721Ownable is OwnableUpgradeable, ERC721Upgradeable, BaseOpenSea {
    
    ///         editors that are not only the owner
    modifier onlyEditor(address sender) virtual {
        require(sender == owner(), '!NOT_EDITOR!');
        _;
    }

    
    
    
    
    
    
    function __ERC721Ownable_init(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        address openseaProxyRegistry_,
        address owner_
    ) internal initializer {
        __Ownable_init();
        __ERC721_init_unchained(name_, symbol_);

        // set contract uri if present
        if (bytes(contractURI_).length > 0) {
            _setContractURI(contractURI_);
        }

        // set OpenSea proxyRegistry for gas-less trading if present
        if (address(0) != openseaProxyRegistry_) {
            _setOpenSeaRegistry(openseaProxyRegistry_);
        }

        // transferOwnership if needed
        if (address(0) != owner_) {
            transferOwnership(owner_);
        }
    }

    
    
    
    function isApprovedForAll(address owner_, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        // allows gas less trading on OpenSea
        return
            super.isApprovedForAll(owner_, operator) ||
            isOwnersOpenSeaProxy(owner_, operator);
    }

    
    
    
    function setContractURI(string memory contractURI_)
        external
        onlyEditor(msg.sender)
    {
        _setContractURI(contractURI_);
    }

    
    
    
    function setOpenSeaRegistry(address osProxyRegistry)
        external
        onlyEditor(msg.sender)
    {
        _setOpenSeaRegistry(osProxyRegistry);
    }
}

// 
pragma solidity ^0.8.9;








contract ERC721WithMutableURI is IERC721WithMutableURI, ERC721Upgradeable {
    using StringsUpgradeable for uint256;

    // base mutable meta URI
    string public baseMutableURI;

    mapping(uint256 => string) private _tokensMutableURIs;

    
    function mutableURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), '!UNKNOWN_TOKEN!');

        string memory _tokenMutableURI = _tokensMutableURIs[tokenId];
        string memory base = _baseMutableURI();

        // If both are set, concatenate the baseURI and mutableURI (via abi.encodePacked).
        if (bytes(base).length > 0 && bytes(_tokenMutableURI).length > 0) {
            return string(abi.encodePacked(base, _tokenMutableURI));
        }

        // If only token mutable URI is set
        if (bytes(_tokenMutableURI).length > 0) {
            return _tokenMutableURI;
        }

        // else return base + tokenId
        return
            bytes(base).length > 0
                ? string(abi.encodePacked(base, tokenId.toString()))
                : '';
    }

    
    
    function _baseMutableURI() internal view returns (string memory) {
        return baseMutableURI;
    }

    
    
    function _setBaseMutableURI(string memory baseMutableURI_) internal {
        baseMutableURI = baseMutableURI_;
    }

    
    
    
    function _setMutableURI(uint256 tokenId, string memory mutableURI_)
        internal
    {
        if (bytes(mutableURI_).length == 0) {
            if (bytes(_tokensMutableURIs[tokenId]).length > 0) {
                delete _tokensMutableURIs[tokenId];
            }
        } else {
            _tokensMutableURIs[tokenId] = mutableURI_;
        }
    }
}

//
pragma solidity ^0.8.9;








///         My take on Permits for NFTs is that the nonce should be linked to the tokens
///         and not to an owner.
///         Whenever a token is transfered, its nonce should increase.
///         This allows to emit a lot of Permit (for sales for example) but ensure they
///         will get invalidated after the token is transfered
///         This also allows an owner to emit several Permit on different tokens
///         and not have Permit to be used one after the other
///         Example:
///         An owner sign a Permit of sale on OpenSea and on Rarible at the same time
///         Only the first one that will sell the item will be able to use the permit
///         The nonce being incremented, this Permits won't be usable anymore
abstract contract ERC721WithPermit is ERC721Upgradeable {
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            'Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)'
        );

    bytes32 public DOMAIN_SEPARATOR;

    mapping(uint256 => uint256) private _nonces;

    // function to initialize the contract
    function __ERC721WithPermit_init(string memory name_) internal {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    'EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'
                ),
                keccak256(bytes(name_)),
                keccak256(bytes('1')),
                block.chainid,
                address(this)
            )
        );
    }

    
    
    
    function nonce(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), '!UNKNOWN_TOKEN!');
        return _nonces[tokenId];
    }

    function makePermitDigest(
        address spender,
        uint256 tokenId,
        uint256 nonce_,
        uint256 deadline
    ) public view returns (bytes32) {
        return
            ECDSAUpgradeable.toTypedDataHash(
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        spender,
                        tokenId,
                        nonce_,
                        deadline
                    )
                )
            );
    }

    
    
    
    
    
    
    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        bytes memory signature
    ) public {
        require(deadline >= block.timestamp, '!PERMIT_DEADLINE_EXPIRED!');

        // this will revert if token is burned
        address owner_ = ownerOf(tokenId);

        bytes32 digest = makePermitDigest(
            spender,
            tokenId,
            _nonces[tokenId],
            deadline
        );

        (address recoveredAddress, ) = ECDSAUpgradeable.tryRecover(
            digest,
            signature
        );
        require(
            (
                // no need to check for recoveredAddress == 0
                // because if it's 0, it won't work
                (recoveredAddress == owner_ ||
                    isApprovedForAll(owner_, recoveredAddress))
            ) ||
                // if owner is a contract, try to recover signature using SignatureChecker
                SignatureCheckerUpgradeable.isValidSignatureNow(
                    owner_,
                    digest,
                    signature
                ),
            '!INVALID_PERMIT_SIGNATURE!'
        );

        _approve(spender, tokenId);
    }

    
    
    function _incrementNonce(uint256 tokenId) internal {
        _nonces[tokenId]++;
    }

    
    
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._transfer(from, to, tokenId);
        // increment the permit nonce linked to this tokenId.
        // this will ensure that a Permit can not be used on a token
        // if it were to leave the owner's hands and come back later
        // this if saves 20k on the mint, which is already expensive enough
        if (from != address(0)) {
            _incrementNonce(tokenId);
        }
    }
}

//
pragma solidity ^0.8.9;





abstract contract ERC721WithRoles {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    
    
    
    event RoleGranted(bytes32 indexed role, address indexed user);

    
    
    
    event RoleRevoked(bytes32 indexed role, address indexed user);

    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet)
        private _roleMembers;

    
    
    
    function hasRole(bytes32 role, address user) public view returns (bool) {
        return _roleMembers[role].contains(user);
    }

    
    
    function listRole(bytes32 role)
        external
        view
        returns (address[] memory list)
    {
        uint256 count = _roleMembers[role].length();
        list = new address[](count);
        for (uint256 i; i < count; i++) {
            list[i] = _roleMembers[role].at(i);
        }
    }

    
    
    
    function _grantRole(bytes32 role, address user) internal returns (bool) {
        if (_roleMembers[role].add(user)) {
            emit RoleGranted(role, user);
            return true;
        }

        return false;
    }

    
    
    
    function _revokeRole(bytes32 role, address user) internal returns (bool) {
        if (_roleMembers[role].remove(user)) {
            emit RoleRevoked(role, user);
            return true;
        }
        return false;
    }
}

// 
pragma solidity ^0.8.9;








contract ERC721WithRoyalties is
    ERC2981Royalties,
    IRaribleSecondarySales,
    IFoundationSecondarySales
{
    
    function getFeeRecipients(uint256 tokenId)
        public
        view
        override
        returns (address payable[] memory recipients)
    {
        // using ERC2981 implementation to get the recipient & amount
        (address recipient, uint256 amount) = _getTokenRoyalty(tokenId);
        if (amount != 0) {
            recipients = new address payable[](1);
            recipients[0] = payable(recipient);
        }
    }

    
    function getFeeBps(uint256 tokenId)
        public
        view
        override
        returns (uint256[] memory fees)
    {
        // using ERC2981 implementation to get the amount
        (, uint256 amount) = _getTokenRoyalty(tokenId);
        if (amount != 0) {
            fees = new uint256[](1);
            fees[0] = amount;
        }
    }

    function getFees(uint256 tokenId)
        external
        view
        virtual
        override
        returns (address payable[] memory recipients, uint256[] memory fees)
    {
        // using ERC2981 implementation to get the recipient & amount
        (address recipient, uint256 amount) = _getTokenRoyalty(tokenId);
        if (amount != 0) {
            recipients = new address payable[](1);
            recipients[0] = payable(recipient);

            fees = new uint256[](1);
            fees[0] = amount;
        }
    }
}

//
pragma solidity ^0.8.9;





interface INiftyForgeModules {
    enum ModuleStatus {
        UNKNOWN,
        ENABLED,
        DISABLED
    }

    
    
    function listModules()
        external
        view
        returns (address[] memory list, uint256[] memory status);

    
    
    function addEventListener(INFModuleWithEvents.Events eventType) external;

    
    
    function removeEventListener(INFModuleWithEvents.Events eventType) external;
}

//
pragma solidity ^0.8.9;



interface INiftyForge721 {
    struct ModuleInit {
        address module;
        bool enabled;
        bool minter;
    }

    
    function totalSupply() external view returns (uint256);

    
    function isMintingOpenToAll() external view returns (bool);

    
    
    function setMintingOpenToAll(bool isOpen) external;

    
    
    
    
    
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
    ) external returns (uint256[] memory tokenIds);

    
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
    ) external returns (uint256[] memory);

    
    
    
    
    function attachModule(
        address module,
        bool enabled,
        bool canModuleMint
    ) external;

    
    
    
    function enableModule(address module, bool canModuleMint) external;

    
    
    function disableModule(address module, bool keepListeners) external;

    
    
    
    function renderTokenURI(uint256 tokenId)
        external
        view
        returns (string memory);
}

//
pragma solidity ^0.8.9;














///      ERC721 / URIStorage / Royalties
///      This contract does not use ERC721enumerable because Enumerable adds quite some
///      gas to minting costs and I am trying to make this cheap for creators.
///      Also, since all NiftyForge contracts will be fully indexed in TheGraph it will easily
///      Be possible to get tokenIds of an owner off-chain, before passing them to a contract
///      which can verify ownership at the processing time

abstract contract ERC721Full is
    ERC721Ownable,
    ERC721BurnableUpgradeable,
    ERC721URIStorageUpgradeable,
    ERC721WithRoles,
    ERC721WithRoyalties,
    ERC721WithPermit,
    ERC721WithMutableURI
{
    bytes32 public constant ROLE_EDITOR = keccak256('EDITOR');
    bytes32 public constant ROLE_MINTER = keccak256('MINTER');

    // base token uri
    string public baseURI;

    
    ///         safeListed addresses have roles Minter, Editor or Owner
    modifier onlyMinter(address minter) virtual {
        require(canMint(minter), '!NOT_MINTER!');
        _;
    }

    
    modifier onlyEditor(address sender) virtual override {
        require(canEdit(sender), '!NOT_EDITOR!');
        _;
    }

    
    
    
    
    
    
    function __ERC721Full_init(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        address openseaProxyRegistry_,
        address owner_
    ) internal {
        __ERC721Ownable_init(
            name_,
            symbol_,
            contractURI_,
            openseaProxyRegistry_,
            owner_
        );

        __ERC721WithPermit_init(name_);
    }

    // receive() external payable {}

    
    ///         any balance / ERC20 / ERC721 / ERC1155 it can have
    ///         this contract has no payable nor receive function so it should not get any nativ token
    ///         but this could save some ERC20, 721 or 1155
    
    
    
    function withdraw(
        address token,
        uint256 amount,
        uint256 tokenId
    ) external onlyOwner {
        if (token == address(0)) {
            require(
                amount == 0 || address(this).balance >= amount,
                '!WRONG_VALUE!'
            );
            (bool success, ) = msg.sender.call{value: amount}('');
            require(success, '!TRANSFER_FAILED!');
        } else {
            // if token is ERC1155
            if (
                IERC165Upgradeable(token).supportsInterface(
                    type(IERC1155Upgradeable).interfaceId
                )
            ) {
                IERC1155Upgradeable(token).safeTransferFrom(
                    address(this),
                    msg.sender,
                    tokenId,
                    amount,
                    ''
                );
            } else if (
                IERC165Upgradeable(token).supportsInterface(
                    type(IERC721Upgradeable).interfaceId
                )
            ) {
                //else if ERC721
                IERC721Upgradeable(token).safeTransferFrom(
                    address(this),
                    msg.sender,
                    tokenId,
                    ''
                );
            } else {
                // we consider it's an ERC20
                require(
                    IERC20Upgradeable(token).transfer(msg.sender, amount),
                    '!TRANSFER_FAILED!'
                );
            }
        }
    }

    
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        // all moved here to have less "jumps" when checking an interface
        return
            interfaceId == type(IERC721WithMutableURI).interfaceId ||
            interfaceId == type(IERC2981Royalties).interfaceId ||
            interfaceId == type(IRaribleSecondarySales).interfaceId ||
            interfaceId == type(IFoundationSecondarySales).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    
    function isApprovedForAll(address owner_, address operator)
        public
        view
        override(ERC721Upgradeable, ERC721Ownable)
        returns (bool)
    {
        return super.isApprovedForAll(owner_, operator);
    }

    
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    
    
    function canEdit(address user) public view virtual returns (bool) {
        return isEditor(user) || owner() == user;
    }

    
    
    function canMint(address user) public view virtual returns (bool) {
        return isMinter(user) || canEdit(user);
    }

    
    
    function isEditor(address user) public view returns (bool) {
        return hasRole(ROLE_EDITOR, user);
    }

    
    
    function isMinter(address user) public view returns (bool) {
        return hasRole(ROLE_MINTER, user);
    }

    
    
    
    
    
    
    
    
    function safeTransferFromWithPermit(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data,
        uint256 deadline,
        bytes memory signature
    ) external {
        // use the permit to get msg.sender approved
        permit(msg.sender, tokenId, deadline, signature);

        // do the transfer
        safeTransferFrom(from, to, tokenId, _data);
    }

    
    
    
    function setBaseURI(string memory baseURI_)
        external
        onlyEditor(msg.sender)
    {
        baseURI = baseURI_;
    }

    
    
    function setBaseMutableURI(string memory baseMutableURI_)
        external
        onlyEditor(msg.sender)
    {
        _setBaseMutableURI(baseMutableURI_);
    }

    
    
    ///         -> if there is a baseMutableURI and a mutableURI, concat baseMutableURI + mutableURI
    ///         -> else if there is only mutableURI, return mutableURI
    //.         -> else if there is only baseMutableURI, concat baseMutableURI + tokenId
    
    
    
    function setMutableURI(uint256 tokenId, string memory mutableURI_)
        external
        onlyEditor(msg.sender)
    {
        require(_exists(tokenId), '!UNKNOWN_TOKEN!');
        _setMutableURI(tokenId, mutableURI_);
    }

    
    
    
    function addEditors(address[] memory users) public onlyOwner {
        for (uint256 i; i < users.length; i++) {
            _grantRole(ROLE_MINTER, users[i]);
        }
    }

    
    
    
    function removeEditors(address[] memory users) public onlyOwner {
        for (uint256 i; i < users.length; i++) {
            _revokeRole(ROLE_MINTER, users[i]);
        }
    }

    
    
    
    function addMinters(address[] memory users) public onlyEditor(msg.sender) {
        for (uint256 i; i < users.length; i++) {
            _grantRole(ROLE_MINTER, users[i]);
        }
    }

    
    
    
    function removeMinters(address[] memory users)
        public
        onlyEditor(msg.sender)
    {
        for (uint256 i; i < users.length; i++) {
            _revokeRole(ROLE_MINTER, users[i]);
        }
    }

    
    
    
    function setDefaultRoyaltiesRecipient(address recipient)
        external
        onlyEditor(msg.sender)
    {
        require(!hasPerTokenRoyalties(), '!PER_TOKEN_ROYALTIES!');
        _setDefaultRoyaltiesRecipient(recipient);
    }

    
    
    
    
    function setTokenRoyaltiesRecipient(uint256 tokenId, address recipient)
        external
    {
        require(hasPerTokenRoyalties(), '!CONTRACT_WIDE_ROYALTIES!');

        (address currentRecipient, ) = _getTokenRoyalty(tokenId);
        require(msg.sender == currentRecipient, '!NOT_ALLOWED!');

        _setTokenRoyaltiesRecipient(tokenId, recipient);
    }

    
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Upgradeable, ERC721WithPermit) {
        super._transfer(from, to, tokenId);
    }

    
    function _burn(uint256 tokenId)
        internal
        virtual
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        // remove royalties
        _removeRoyalty(tokenId);

        // remove mutableURI
        _setMutableURI(tokenId, '');

        // burn ERC721URIStorage
        super._burn(tokenId);
    }

    
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}

//
pragma solidity ^0.8.9;



interface INFModule is IERC165Upgradeable {
    
    
    function onAttach() external returns (bool);

    
    
    function onEnable() external returns (bool);

    
    function onDisable() external;

    
    
    function contractURI() external view returns (string memory);
}

//
pragma solidity ^0.8.9;









///         They can be used to mint elements (need Minter Role) but also can listen
///         To events like MINT, TRANSFER and BURN
///
///         To module developers:
///         Remember cross contract calls have a high cost, and reads too.
///         Do not abuse of Events and only use them if there is a high value to it
///         Gas is not cheap, always think of users first.
contract NiftyForgeModules is INiftyForgeModules {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    // event emitted whenever a module status changed
    event ModuleChanged(address module);

    // 3 types of events Mint, Transfer and Burn
    EnumerableSetUpgradeable.AddressSet[3] private _listeners;

    // modules list
    // should create a module role instead?
    EnumerableSetUpgradeable.AddressSet internal modules;

    // modules status
    mapping(address => ModuleStatus) public modulesStatus;

    modifier onlyEnabledModule() {
        require(
            modulesStatus[msg.sender] == ModuleStatus.ENABLED,
            '!MODULE_NOT_ENABLED!'
        );
        _;
    }

    
    
    function listModules()
        external
        view
        override
        returns (address[] memory list, uint256[] memory status)
    {
        uint256 count = modules.length();
        list = new address[](count);
        status = new uint256[](count);
        for (uint256 i; i < count; i++) {
            list[i] = modules.at(i);
            status[i] = uint256(modulesStatus[list[i]]);
        }
    }

    
    
    function addEventListener(INFModuleWithEvents.Events eventType)
        external
        override
        onlyEnabledModule
    {
        _listeners[uint256(eventType)].add(msg.sender);
    }

    
    
    function removeEventListener(INFModuleWithEvents.Events eventType)
        external
        override
        onlyEnabledModule
    {
        _listeners[uint256(eventType)].remove(msg.sender);
    }

    
    
    
    function _attachModule(address module, bool enabled) internal {
        require(
            modulesStatus[module] == ModuleStatus.UNKNOWN,
            '!ALREADY_ATTACHED!'
        );

        // add to modules list
        modules.add(module);

        // tell the module it's attached
        // making sure module can be attached to this contract
        require(INFModule(module).onAttach(), '!ATTACH_FAILED!');

        if (enabled) {
            _enableModule(module);
        } else {
            _disableModule(module, true);
        }
    }

    
    
    function _enableModule(address module) internal {
        require(
            modulesStatus[module] != ModuleStatus.ENABLED,
            '!NOT_DISABLED!'
        );
        modulesStatus[module] = ModuleStatus.ENABLED;

        // making sure module can be enabled on this contract
        require(INFModule(module).onEnable(), '!ENABLING_FAILED!');
        emit ModuleChanged(module);
    }

    
    
    
    ///        meaning the module can not interact with the contract anymore but is still working
    ///        for example: a module that transfers an ERC20 to people Minting
    function _disableModule(address module, bool keepListeners)
        internal
        virtual
    {
        require(
            modulesStatus[module] != ModuleStatus.DISABLED,
            '!NOT_ENABLED!'
        );
        modulesStatus[module] = ModuleStatus.DISABLED;

        // we do a try catch without checking return or error here
        // because owners should be able to disable a module any time without the module being ok
        // with it or not
        try INFModule(module).onDisable() {} catch {}

        // remove all listeners if not explicitely asked to keep them
        if (!keepListeners) {
            _listeners[uint256(INFModuleWithEvents.Events.MINT)].remove(module);
            _listeners[uint256(INFModuleWithEvents.Events.TRANSFER)].remove(
                module
            );
            _listeners[uint256(INFModuleWithEvents.Events.BURN)].remove(module);
        }

        emit ModuleChanged(module);
    }

    
    
    
    
    
    function _fireEvent(
        INFModuleWithEvents.Events eventType,
        uint256 tokenId,
        address from,
        address to
    ) internal {
        EnumerableSetUpgradeable.AddressSet storage listeners = _listeners[
            uint256(eventType)
        ];
        uint256 length = listeners.length();
        for (uint256 i; i < length; i++) {
            INFModuleWithEvents(listeners.at(i)).onEvent(
                eventType,
                tokenId,
                from,
                to
            );
        }
    }
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 *
 * _Available since v4.1._
 */
interface IERC1271Upgradeable {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}

// 

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

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
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
 * @dev String operations.
 */
library StringsUpgradeable {
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

// 

pragma solidity ^0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// 

pragma solidity ^0.8.0;





/**
 * @dev Signature verification helper: Provide a single mechanism to verify both private-key (EOA) ECDSA signature and
 * ERC1271 contract sigantures. Using this instead of ECDSA.recover in your contract will make them compatible with
 * smart contract wallets such as Argent and Gnosis.
 *
 * Note: unlike ECDSA signatures, contract signature's are revocable, and the outcome of this function can thus change
 * through time. It could return true at block N and false at block N+1 (or the opposite).
 *
 * _Available since v4.1._
 */
library SignatureCheckerUpgradeable {
    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (address recovered, ECDSAUpgradeable.RecoverError error) = ECDSAUpgradeable.tryRecover(hash, signature);
        if (error == ECDSAUpgradeable.RecoverError.NoError && recovered == signer) {
            return true;
        }

        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeWithSelector(IERC1271Upgradeable.isValidSignature.selector, hash, signature)
        );
        return (success && result.length == 32 && abi.decode(result, (bytes4)) == IERC1271Upgradeable.isValidSignature.selector);
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

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

//
pragma solidity ^0.8.9;



interface INFModuleMutableURI is INFModule {
    function mutableURI(uint256 tokenId) external view returns (string memory);

    function mutableURI(address registry, uint256 tokenId)
        external
        view
        returns (string memory);
}

//
pragma solidity ^0.8.9;



interface INFModuleRenderTokenURI is INFModule {
    function renderTokenURI(uint256 tokenId)
        external
        view
        returns (string memory);

    function renderTokenURI(address registry, uint256 tokenId)
        external
        view
        returns (string memory);
}

//
pragma solidity ^0.8.9;



interface INFModuleTokenURI is INFModule {
    function tokenURI(uint256 tokenId) external view returns (string memory);

    function tokenURI(address registry, uint256 tokenId)
        external
        view
        returns (string memory);
}

//
pragma solidity ^0.8.9;



interface INFModuleWithEvents is INFModule {
    enum Events {
        MINT,
        TRANSFER,
        BURN
    }

    
    
    
    
    
    function onEvent(
        Events eventType,
        uint256 tokenId,
        address from,
        address to
    ) external;
}

//
pragma solidity ^0.8.9;



interface INFModuleWithRoyalties is INFModule {
    
    
    ///      This in order to allow right royalties on marketplaces not supporting 2981 (like Rarible)
    
    
    function royaltyInfo(uint256 tokenId)
        external
        view
        returns (address recipient, uint256 basisPoint);

    
    
    ///      This in order to allow right royalties on marketplaces not supporting 2981 (like Rarible)
    
    
    
    function royaltyInfo(address registry, uint256 tokenId)
        external
        view
        returns (address recipient, uint256 basisPoint);
}

//
pragma solidity ^0.8.9;














contract NiftyForge721 is INiftyForge721, NiftyForgeModules, ERC721Full {
    
    uint256 public lastTokenId;

    uint256 public totalSupply;

    bool private _mintingOpenToAll;

    // this can be set only once by the owner of the contract
    // this is used to ensure a max token creation that can be used
    // for example when people create a series of XX elements
    // since this contract works with "Minters", it is good to
    // be able to set in it that there is a max number of elements
    // and that this can not change
    uint256 public maxTokenId;

    mapping(uint256 => address) public tokenIdToModule;

    
    ///         safeListed addresses have roles Minter, Editor or Owner
    modifier onlyMinter(address minter) virtual override {
        require(isMintingOpenToAll() || canMint(minter), '!NOT_MINTER!');
        _;
    }

    
    ///         Although it uses what are called upgradeable contracts, this is only to
    ///         be able to make deployment cheap using a Proxy but NiftyForge contracts
    ///         ARE NOT UPGRADEABLE => the proxy used is not an upgradeable proxy, the implementation is immutable
    
    
    
    
    
    
    
    
    function initialize(
        string memory name_,
        string memory symbol_,
        string memory contractURI_,
        address openseaProxyRegistry_,
        address owner_,
        ModuleInit[] memory modulesInit_,
        address contractRoyaltiesRecipient,
        uint256 contractRoyaltiesValue
    ) external initializer {
        __ERC721Full_init(
            name_,
            symbol_,
            contractURI_,
            openseaProxyRegistry_,
            owner_
        );

        for (uint256 i; i < modulesInit_.length; i++) {
            _attachModule(modulesInit_[i].module, modulesInit_[i].enabled);
            if (modulesInit_[i].enabled && modulesInit_[i].minter) {
                _grantRole(ROLE_MINTER, modulesInit_[i].module);
            }
        }

        // here, if  contractRoyaltiesRecipient is not address(0) but
        // contractRoyaltiesValue is 0, this will mean that this contract will
        // NEVER have royalties, because whenever default royalties are set, it is
        // always used for every tokens.
        if (
            contractRoyaltiesRecipient != address(0) ||
            contractRoyaltiesValue != 0
        ) {
            _setDefaultRoyalties(
                contractRoyaltiesRecipient,
                contractRoyaltiesValue
            );
        }
    }

    
    function isMintingOpenToAll() public view override returns (bool) {
        return _mintingOpenToAll;
    }

    
    
    ///      if not it will check if the token comes from a Module, and if yes, try to get the tokenURI from it
    ///
    
    
    
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory uri)
    {
        require(_exists(tokenId), '!UNKNOWN_TOKEN!');

        // first, try to get the URI from the module that might have created it
        (bool support, address module) = _moduleSupports(
            tokenId,
            type(INFModuleTokenURI).interfaceId
        );
        if (support) {
            uri = INFModuleTokenURI(module).tokenURI(tokenId);
        }

        // if uri not set, get it with the normal tokenURI
        if (bytes(uri).length == 0) {
            uri = super.tokenURI(tokenId);
        }
    }

    
    ///         this can be an URL but also any other data uri
    ///         This is something that I would like to present as an EIP later to allow dynamique
    ///         render URL
    
    
    function renderTokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory uri)
    {
        require(_exists(tokenId), '!UNKNOWN_TOKEN!');

        // Try to get the URI from the module that might have created this token
        (bool support, address module) = _moduleSupports(
            tokenId,
            type(INFModuleRenderTokenURI).interfaceId
        );
        if (support) {
            uri = INFModuleRenderTokenURI(module).renderTokenURI(tokenId);
        }
    }

    
    
    function setMintingOpenToAll(bool isOpen)
        external
        override
        onlyEditor(msg.sender)
    {
        _mintingOpenToAll = isOpen;
    }

    
    
    ///      When set, the maxTokenId can not be reverted nor changed
    
    function setMaxTokenId(uint256 maxTokenId_)
        external
        onlyEditor(msg.sender)
    {
        require(maxTokenId == 0, '!MAX_TOKEN_ALREADY_SET!');
        maxTokenId = maxTokenId_;
    }

    
    ///         This function has been added because sometimes, we want some metadata to be completly immutable
    ///         But to have others that aren't (for example if a token is linked to a physical token, and the physical
    ///         token state can change over time)
    ///         This way we can reflect those changes without risking breaking the base meta (tokenURI)
    
    
    function mutableURI(uint256 tokenId)
        public
        view
        override
        returns (string memory uri)
    {
        require(_exists(tokenId), '!UNKNOWN_TOKEN!');

        // first, try to get the URI from the module that might have created it
        (bool support, address module) = _moduleSupports(
            tokenId,
            type(INFModuleMutableURI).interfaceId
        );
        if (support) {
            uri = INFModuleMutableURI(module).mutableURI(tokenId);
        }

        // if uri not set, get it with the normal mutableURI
        if (bytes(uri).length == 0) {
            uri = super.mutableURI(tokenId);
        }
    }

    
    
    
    
    
    ///        where 10000 == 100.00%; 1000 == 10.00%; 250 == 2.50%
    
    ///        this is used when we want to mint the NFT to the creator address
    ///        before transfering it to a recipient
    
    function mint(
        address to,
        string memory uri,
        address feeRecipient,
        uint256 feeAmount,
        address transferTo
    ) public override onlyMinter(msg.sender) returns (uint256 tokenId) {
        tokenId = lastTokenId + 1;
        lastTokenId = mint(
            to,
            uri,
            tokenId,
            feeRecipient,
            feeAmount,
            transferTo
        );
    }

    
    
    
    
    
    ///        where 10000 == 100.00%; 1000 == 10.00%; 250 == 2.50%
    
    function mintBatch(
        address[] memory to,
        string[] memory uris,
        address[] memory feeRecipients,
        uint256[] memory feeAmounts
    )
        public
        override
        onlyMinter(msg.sender)
        returns (uint256[] memory tokenIds)
    {
        require(
            to.length == uris.length &&
                to.length == feeRecipients.length &&
                to.length == feeAmounts.length,
            '!LENGTH_MISMATCH!'
        );

        uint256 tokenId = lastTokenId;

        tokenIds = new uint256[](to.length);
        // verify that we don't overflow
        // done here instead of in _mint so we do one read
        // instead of to.length
        _verifyMaxTokenId(tokenId + to.length);

        bool isModule = modulesStatus[msg.sender] == ModuleStatus.ENABLED;
        for (uint256 i; i < to.length; i++) {
            tokenId++;
            _mint(
                to[i],
                uris[i],
                tokenId,
                feeRecipients[i],
                feeAmounts[i],
                isModule
            );
            tokenIds[i] = tokenId;
        }

        // setting lastTokenId after will ensure that any reEntrancy will fail
        // to mint, because the minting will throw with a duplicate id
        lastTokenId = tokenId;
    }

    
    ///         Because not all tokenIds have incremental ids
    ///         be careful with this function, it does not increment lastTokenId
    ///         and expects the minter to actually know what it is doing.
    ///         this also means, this function does not verify maxTokenId
    
    
    
    
    
    ///        where 10000 == 100.00%; 1000 == 10.00%; 250 == 2.50%
    
    ///        this is used when we want to mint the NFT to the creator address
    ///        before transfering it to a recipient
    
    function mint(
        address to,
        string memory uri,
        uint256 tokenId_,
        address feeRecipient,
        uint256 feeAmount,
        address transferTo
    ) public override onlyMinter(msg.sender) returns (uint256) {
        // minting will throw if the tokenId_ already exists

        // we also verify maxTokenId in this case
        // because else it would allow owners to mint arbitrary tokens
        // after setting the max
        _verifyMaxTokenId(tokenId_);

        _mint(
            to,
            uri,
            tokenId_,
            feeRecipient,
            feeAmount,
            modulesStatus[msg.sender] == ModuleStatus.ENABLED
        );

        if (transferTo != address(0)) {
            _transfer(to, transferTo, tokenId_);
        }

        return tokenId_;
    }

    
    ///         Because not all tokenIds have incremental ids
    ///         be careful with this function, it does not increment lastTokenId
    ///         and expects the minter to actually know what it's doing.
    ///         this also means, this function does not verify maxTokenId
    
    
    
    
    
    ///        where 10000 == 100.00%; 1000 == 10.00%; 250 == 2.50%
    
    function mintBatch(
        address[] memory to,
        string[] memory uris,
        uint256[] memory tokenIds,
        address[] memory feeRecipients,
        uint256[] memory feeAmounts
    ) public override onlyMinter(msg.sender) returns (uint256[] memory) {
        // minting will throw if any tokenIds[i] already exists

        require(
            to.length == uris.length &&
                to.length == tokenIds.length &&
                to.length == feeRecipients.length &&
                to.length == feeAmounts.length,
            '!LENGTH_MISMATCH!'
        );

        uint256 highestId;
        for (uint256 i; i < tokenIds.length; i++) {
            if (tokenIds[i] > highestId) {
                highestId = tokenIds[i];
            }
        }

        // we also verify maxTokenId in this case
        // because else it would allow owners to mint arbitrary tokens
        // after setting the max
        _verifyMaxTokenId(highestId);

        bool isModule = modulesStatus[msg.sender] == ModuleStatus.ENABLED;
        for (uint256 i; i < to.length; i++) {
            if (tokenIds[i] > highestId) {
                highestId = tokenIds[i];
            }

            _mint(
                to[i],
                uris[i],
                tokenIds[i],
                feeRecipients[i],
                feeAmounts[i],
                isModule
            );
        }

        return tokenIds;
    }

    
    
    
    
    function attachModule(
        address module,
        bool enabled,
        bool moduleCanMint
    ) external override onlyEditor(msg.sender) {
        // give the minter role if enabled and moduleCanMint
        if (moduleCanMint && enabled) {
            _grantRole(ROLE_MINTER, module);
        }

        _attachModule(module, enabled);
    }

    
    
    
    function enableModule(address module, bool moduleCanMint)
        external
        override
        onlyEditor(msg.sender)
    {
        // give the minter role if moduleCanMint
        if (moduleCanMint) {
            _grantRole(ROLE_MINTER, module);
        }

        _enableModule(module);
    }

    
    
    function disableModule(address module, bool keepListeners)
        external
        override
        onlyEditor(msg.sender)
    {
        _disableModule(module, keepListeners);
    }

    
    
    
    
    
    
    ///        where 10000 == 100.00%; 1000 == 10.00%; 250 == 2.50%
    
    function _mint(
        address to,
        string memory uri,
        uint256 tokenId,
        address feeRecipient,
        uint256 feeAmount,
        bool isModule
    ) internal {
        _safeMint(to, tokenId, '');

        if (bytes(uri).length > 0) {
            _setTokenURI(tokenId, uri);
        }

        if (feeAmount > 0) {
            _setTokenRoyalty(tokenId, feeRecipient, feeAmount);
        }

        if (isModule) {
            tokenIdToModule[tokenId] = msg.sender;
        }
    }

    // here we override _mint, _transfer and _burn because we want the event to be fired
    // only after the action is done
    // else we would have done that in _beforeTokenTransfer
    
    
    function _mint(address to, uint256 tokenId) internal virtual override {
        super._mint(to, tokenId);
        totalSupply++;

        _fireEvent(INFModuleWithEvents.Events.MINT, tokenId, address(0), to);
    }

    
    
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._transfer(from, to, tokenId);

        if (to == address(0xdEaD)) {
            _fireEvent(INFModuleWithEvents.Events.BURN, tokenId, from, to);
        } else {
            _fireEvent(INFModuleWithEvents.Events.TRANSFER, tokenId, from, to);
        }
    }

    
    
    function _burn(uint256 tokenId) internal virtual override {
        address owner_ = ownerOf(tokenId);
        super._burn(tokenId);
        totalSupply--;
        _fireEvent(
            INFModuleWithEvents.Events.BURN,
            tokenId,
            owner_,
            address(0)
        );
    }

    function _disableModule(address module, bool keepListeners)
        internal
        override
    {
        // always revoke the minter role when disabling a module
        _revokeRole(ROLE_MINTER, module);

        super._disableModule(module, keepListeners);
    }

    
    
    function _verifyMaxTokenId(uint256 tokenId) internal view {
        uint256 maxTokenId_ = maxTokenId;
        require(maxTokenId_ == 0 || tokenId <= maxTokenId_, '!MAX_TOKEN_ID!');
    }

    
    
    function _getTokenRoyalty(uint256 tokenId)
        internal
        view
        override
        returns (address royaltyRecipient, uint256 royaltyAmount)
    {
        (royaltyRecipient, royaltyAmount) = super._getTokenRoyalty(tokenId);

        // if there are no royalties set either contract wide or per token
        if (royaltyAmount == 0) {
            // try to see if the token was created by a module that manages royalties
            (bool support, address module) = _moduleSupports(
                tokenId,
                type(INFModuleWithRoyalties).interfaceId
            );
            if (support) {
                (royaltyRecipient, royaltyAmount) = INFModuleWithRoyalties(
                    module
                ).royaltyInfo(tokenId);
            }
        }
    }

    function _moduleSupports(uint256 tokenId, bytes4 interfaceId)
        internal
        view
        returns (bool support, address module)
    {
        module = tokenIdToModule[tokenId];
        support =
            module != address(0) &&
            IERC165Upgradeable(module).supportsInterface(interfaceId);
    }
}