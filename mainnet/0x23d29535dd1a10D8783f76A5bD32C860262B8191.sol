// SPDX-License-Identifier: GPL-3.0-or-later


// 
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title ERC721
 * @author naomsa <https://twitter.com/naomsa666>
 * @notice A complete ERC721 implementation including metadata and enumerable
 * functions. Completely gas optimized and extensible.
 */
abstract contract ERC721 {
  /*         _           _            */
  /*        ( )_        ( )_          */
  /*    ___ | ,_)   _ _ | ,_)   __    */
  /*  /',__)| |   /'_` )| |   /'__`\  */
  /*  \__, \| |_ ( (_| || |_ (  ___/  */
  /*  (____/`\__)`\__,_)`\__)`\____)  */

  
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

  
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

  
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  
  string public name;

  
  string public symbol;

  
  address[] private _owners;

  
  mapping(address => uint256) private _balanceOf;

  
  mapping(uint256 => address) private _tokenApprovals;

  
  mapping(address => mapping(address => bool)) private _isApprovedForAll;

  /*   _                            */
  /*  (_ )                _         */
  /*   | |    _      __  (_)   ___  */
  /*   | |  /'_`\  /'_ `\| | /'___) */
  /*   | | ( (_) )( (_) || |( (___  */
  /*  (___)`\___/'`\__  |(_)`\____) */
  /*              ( )_) |           */
  /*               \___/'           */

  constructor(string memory name_, string memory symbol_) {
    name = name_;
    symbol = symbol_;
  }

  
  function balanceOf(address owner) public view virtual returns (uint256) {
    require(owner != address(0), "ERC721: balance query for the zero address");
    return _balanceOf[owner];
  }

  
  function ownerOf(uint256 tokenId) public view virtual returns (address) {
    require(_exists(tokenId), "ERC721: query for nonexistent token");
    address owner = _owners[tokenId];
    return owner;
  }

  
  function tokenURI(uint256) public view virtual returns (string memory);

  
  function approve(address to, uint256 tokenId) public virtual {
    address owner = ownerOf(tokenId);
    require(to != owner, "ERC721: approval to current owner");

    require(
      msg.sender == owner || _isApprovedForAll[owner][msg.sender],
      "ERC721: caller is not owner nor approved for all"
    );

    _approve(to, tokenId);
  }

  
  function getApproved(uint256 tokenId) public view virtual returns (address) {
    require(_exists(tokenId), "ERC721: query for nonexistent token");
    return _tokenApprovals[tokenId];
  }

  
  function setApprovalForAll(address operator, bool approved) public virtual {
    _setApprovalForAll(msg.sender, operator, approved);
  }

  
  function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
    return _isApprovedForAll[owner][operator];
  }

  
  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual {
    require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
    _transfer(from, to, tokenId);
  }

  
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual {
    safeTransferFrom(from, to, tokenId, "");
  }

  
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data_
  ) public virtual {
    require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
    _safeTransfer(from, to, tokenId, data_);
  }

  
  function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId) {
    require(index < balanceOf(owner), "ERC721Enumerable: Index out of bounds");
    uint256 count;
    for (uint256 i; i < _owners.length; ++i) {
      if (owner == _owners[i]) {
        if (count == index) return i;
        else count++;
      }
    }
    revert("ERC721Enumerable: Index out of bounds");
  }

  
  function totalSupply() public view virtual returns (uint256) {
    return _owners.length;
  }

  
  function tokenByIndex(uint256 index) public view virtual returns (uint256) {
    require(index < _owners.length, "ERC721Enumerable: Index out of bounds");
    return index;
  }

  
  function tokensOfOwner(address owner) public view returns (uint256[] memory) {
    uint256 balance = balanceOf(owner);
    uint256[] memory ids = new uint256[](balance);
    for (uint256 i = 0; i < balance; i++) {
      ids[i] = tokenOfOwnerByIndex(owner, i);
    }
    return ids;
  }

  /*             _                               _    */
  /*   _        ( )_                            (_ )  */
  /*  (_)  ___  | ,_)   __   _ __   ___     _ _  | |  */
  /*  | |/' _ `\| |   /'__`\( '__)/' _ `\ /'_` ) | |  */
  /*  | || ( ) || |_ (  ___/| |   | ( ) |( (_| | | |  */
  /*  (_)(_) (_)`\__)`\____)(_)   (_) (_)`\__,_)(___) */

  /**
   * @notice Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
   * are aware of the ERC721 protocol to prevent tokens from being forever locked.
   *
   * `data_` is additional data, it has no specified format and it is sent in call to `to`.
   *
   * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
   * implement alternative mechanisms to perform token transfer, such as signature-based.
   *
   * Requirements:
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
    bytes memory data_
  ) internal virtual {
    _transfer(from, to, tokenId);
    _checkOnERC721Received(from, to, tokenId, data_);
  }

  /**
   * @notice Returns whether `tokenId` exists.
   *
   * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
   *
   * Tokens start existing when they are minted (`_mint`),
   * and stop existing when they are burned (`_burn`).
   */
  function _exists(uint256 tokenId) internal view virtual returns (bool) {
    return tokenId < _owners.length && _owners[tokenId] != address(0);
  }

  /**
   * @notice Returns whether `spender` is allowed to manage `tokenId`.
   *
   * Requirements:
   * - `tokenId` must exist.
   */
  function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
    require(_exists(tokenId), "ERC721: query for nonexistent token");
    address owner = _owners[tokenId];
    return (spender == owner || getApproved(tokenId) == spender || _isApprovedForAll[owner][spender]);
  }

  /**
   * @notice Safely mints `tokenId` and transfers it to `to`.
   *
   * Requirements:
   * - `tokenId` must not exist.
   * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
   *
   * Emits a {Transfer} event.
   */
  function _safeMint(address to, uint256 tokenId) internal virtual {
    _safeMint(to, tokenId, "");
  }

  /**
   * @notice Same as {_safeMint}, but with an additional `data` parameter which is
   * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
   */
  function _safeMint(
    address to,
    uint256 tokenId,
    bytes memory data_
  ) internal virtual {
    _mint(to, tokenId);
    _checkOnERC721Received(address(0), to, tokenId, data_);
  }

  /**
   * @notice Mints `tokenId` and transfers it to `to`.
   *
   * Requirements:
   * - `tokenId` must not exist.
   * - `to` cannot be the zero address.
   *
   * Emits a {Transfer} event.
   */
  function _mint(address to, uint256 tokenId) internal virtual {
    require(!_exists(tokenId), "ERC721: token already minted");

    _beforeTokenTransfer(address(0), to, tokenId);

    _owners.push(to);
    unchecked {
      _balanceOf[to]++;
    }

    emit Transfer(address(0), to, tokenId);
  }

  /**
   * @notice Destroys `tokenId`.
   * The approval is cleared when the token is burned.
   *
   * Requirements:
   * - `tokenId` must exist.
   *
   * Emits a {Transfer} event.
   */
  function _burn(uint256 tokenId) internal virtual {
    address owner = ownerOf(tokenId);

    _beforeTokenTransfer(owner, address(0), tokenId);

    // Clear approvals
    _approve(address(0), tokenId);
    delete _owners[tokenId];
    _balanceOf[owner]--;

    emit Transfer(owner, address(0), tokenId);
  }

  /**
   * @notice Transfers `tokenId` from `from` to `to`.
   *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
   *
   * Requirements:
   * - `tokenId` token must be owned by `from`.
   *
   * Emits a {Transfer} event.
   */
  function _transfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual {
    require(_owners[tokenId] == from, "ERC721: transfer of token that is not own");

    _beforeTokenTransfer(from, to, tokenId);

    // Clear approvals from the previous owner
    _approve(address(0), tokenId);

    _owners[tokenId] = to;
    unchecked {
      _balanceOf[from]--;
      _balanceOf[to]++;
    }

    emit Transfer(from, to, tokenId);
  }

  /**
   * @notice Approve `to` to operate on `tokenId`
   *
   * Emits a {Approval} event.
   */
  function _approve(address to, uint256 tokenId) internal virtual {
    _tokenApprovals[tokenId] = to;
    emit Approval(_owners[tokenId], to, tokenId);
  }

  /**
   * @notice Approve `operator` to operate on all of `owner` tokens
   *
   * Emits a {ApprovalForAll} event.
   */
  function _setApprovalForAll(
    address owner,
    address operator,
    bool approved
  ) internal virtual {
    require(owner != operator, "ERC721: approve to caller");
    _isApprovedForAll[owner][operator] = approved;
    emit ApprovalForAll(owner, operator, approved);
  }

  /**
   * @notice Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
   * The call is not executed if the target address is not a contract.
   *
   * @param from address representing the previous owner of the given token ID
   * @param to target address that will receive the tokens
   * @param tokenId uint256 ID of the token to be transferred
   * @param data bytes optional data to send along with the call
   */
  function _checkOnERC721Received(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data
  ) private {
    if (to.code.length > 0) {
      try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 returned) {
        require(returned == 0x150b7a02, "ERC721: safe transfer to non ERC721Receiver implementation");
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert("ERC721: safe transfer to non ERC721Receiver implementation");
        } else {
          assembly {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    }
  }

  /**
   * @notice Hook that is called before any token transfer. This includes minting
   * and burning.
   *
   * Calling conditions:
   * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
   * transferred to `to`.
   * - When `from` is zero, `tokenId` will be minted for `to`.
   * - When `to` is zero, ``from``'s `tokenId` will be burned.
   * - `from` and `to` are never both zero.
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual {}

  /*    ___  _   _  _ _      __   _ __  */
  /*  /',__)( ) ( )( '_`\  /'__`\( '__) */
  /*  \__, \| (_) || (_) )(  ___/| |    */
  /*  (____/`\___/'| ,__/'`\____)(_)    */
  /*               | |                  */
  /*               (_)                  */

  
  function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
    return
      interfaceId == 0x80ac58cd || // ERC721
      interfaceId == 0x5b5e139f || // ERC721Metadata
      interfaceId == 0x780e9d63 || // ERC721Enumerable
      interfaceId == 0x01ffc9a7; // ERC165
  }
}

// 
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Auth
 * @author naomsa <https://twitter.com/naomsa666>
 * @notice Authing system where the `owner` can authorize function calls
 * to other addresses as well as control the contract by his own.
 */
abstract contract Auth {
  /*         _           _            */
  /*        ( )_        ( )_          */
  /*    ___ | ,_)   _ _ | ,_)   __    */
  /*  /',__)| |   /'_` )| |   /'__`\  */
  /*  \__, \| |_ ( (_| || |_ (  ___/  */
  /*  (____/`\__)`\__,_)`\__)`\____)  */

  
  event OwnershipTransfered(address indexed from, address indexed to);

  
  event AuthorizationGranted(address indexed to, bytes data);

  
  event AuthorizationForbidden(address indexed to, bytes data);

  
  address private _owner;

  
  mapping(address => mapping(bytes => bool)) private _isAuthorized;

  /**
   * @notice A modifier that requires the user to be the owner or authorization to call.
   * After the call, the user loses it's authorization if he's not the owner.
   */
  modifier onlyAuthorized() {
    require(isAuthorized(msg.sender, msg.data), "Auth: sender is not the owner or authorized to call");
    _;
    if (msg.sender != _owner) _isAuthorized[msg.sender][msg.data] = false;
  }

  
  modifier onlyOwner() {
    require(msg.sender == _owner, "Auth: sender is not the owner");
    _;
  }

  /*   _                            */
  /*  (_ )                _         */
  /*   | |    _      __  (_)   ___  */
  /*   | |  /'_`\  /'_ `\| | /'___) */
  /*   | | ( (_) )( (_) || |( (___  */
  /*  (___)`\___/'`\__  |(_)`\____) */
  /*              ( )_) |           */
  /*               \___/'           */

  constructor() {
    _transferOwnership(msg.sender);
  }

  
  function owner() public view returns (address) {
    return _owner;
  }

  
  function isAuthorized(address user_, bytes memory data_) public view returns (bool) {
    return user_ == _owner || _isAuthorized[user_][data_];
  }

  
  function transferOwnership(address owner_) public onlyOwner {
    require(_owner != owner_, "Auth: transfering ownership to current owner");
    _transferOwnership(owner_);
  }

  
  function _transferOwnership(address owner_) internal {
    address oldOwner = _owner;
    _owner = owner_;

    emit OwnershipTransfered(oldOwner, owner_);
  }

  
  function auth(address to_, bytes memory data_) public onlyOwner {
    require(to_ != _owner, "Auth: authorizing call to the owner");
    require(!_isAuthorized[to_][data_], "Auth: authorized calls cannot be authed");
    _isAuthorized[to_][data_] = true;

    emit AuthorizationGranted(to_, data_);
  }

  
  function forbid(address to_, bytes memory data_) public onlyOwner {
    require(_isAuthorized[to_][data_], "Auth: unauthorized calls cannot be forbidden");
    delete _isAuthorized[to_][data_];

    emit AuthorizationForbidden(to_, data_);
  }
}

// 
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title Pausable
 * @author naomsa <https://twitter.com/naomsa666>
 * @notice Freeze your contract with a secure paused mechanism.
 */
abstract contract Pausable {
  /*         _           _            */
  /*        ( )_        ( )_          */
  /*    ___ | ,_)   _ _ | ,_)   __    */
  /*  /',__)| |   /'_` )| |   /'__`\  */
  /*  \__, \| |_ ( (_| || |_ (  ___/  */
  /*  (____/`\__)`\__,_)`\__)`\____)  */

  
  event Paused(address indexed by);

  
  event Unpaused(address indexed by);

  
  bool private _paused;

  
  modifier onlyWhenPaused() {
    require(_paused, "Pausable: contract not paused");
    _;
  }

  
  modifier onlyWhenUnpaused() {
    require(!_paused, "Pausable: contract paused");
    _;
  }

  /*   _                            */
  /*  (_ )                _         */
  /*   | |    _      __  (_)   ___  */
  /*   | |  /'_`\  /'_ `\| | /'___) */
  /*   | | ( (_) )( (_) || |( (___  */
  /*  (___)`\___/'`\__  |(_)`\____) */
  /*              ( )_) |           */
  /*               \___/'           */

  
  function paused() public view returns (bool) {
    return _paused;
  }

  
  function _togglePaused() internal {
    _paused = !_paused;
    if (_paused) emit Unpaused(msg.sender);
    else emit Paused(msg.sender);
  }
}
// 
pragma solidity 0.8.11;








/**
 * @title Ape Runners
 * @author naomsa <https://twitter.com/naomsa666>
 */
contract ApeRunners is Auth, Pausable, ERC721("Ape Runners", "AR") {
  using Strings for uint256;
  using MerkleProof for bytes32[];

  
  uint256 public constant MAX_SUPPLY = 5000;
  
  uint256 public constant MAX_PER_TX = 10;
  
  uint256 public constant PRICE = 0.04 ether;

  
  uint256 public saleState;

  
  string public baseURI;
  
  string public baseExtension;
  
  string public unrevealedURI;

  
  bytes32 public merkleRoot;
  
  mapping(address => uint256) public whitelistMinted;

  
  address public opensea;
  
  address public looksrare;
  
  bool public marketplacesApproved = true;

  constructor(
    string memory unrevealedURI_,
    bytes32 merkleRoot_,
    address opensea_,
    address looksrare_
  ) {
    unrevealedURI = unrevealedURI_;
    merkleRoot = merkleRoot_;
    opensea = opensea_;
    looksrare = looksrare_;

    for (uint256 i = 0; i < 50; i++) _safeMint(msg.sender, i);
  }

  
  function claim(uint256 amount_) external payable {
    uint256 supply = totalSupply();
    require(supply + amount_ <= MAX_SUPPLY, "Max supply exceeded");
    if (msg.sender != owner()) {
      require(saleState == 2, "Public sale is not open");
      require(amount_ > 0 && amount_ <= MAX_PER_TX, "Invalid claim amount");
      require(msg.value == PRICE * amount_, "Invalid ether amount");
    }

    for (uint256 i = 0; i < amount_; i++) _safeMint(msg.sender, supply++);
  }

  
  function claimWhitelist(uint256 amount_, bytes32[] memory proof_)
    external
    payable
  {
    uint256 supply = totalSupply();
    require(supply + amount_ <= MAX_SUPPLY, "Max supply exceeded");
    if (msg.sender != owner()) {
      require(saleState == 1, "Whitelist sale is not open");
      require(
        amount_ > 0 && amount_ + whitelistMinted[msg.sender] <= MAX_PER_TX,
        "Invalid claim amount"
      );
      require(msg.value == PRICE * amount_, "Invalid ether amount");
      require(isWhitelisted(msg.sender, proof_), "Invalid proof");
    }

    whitelistMinted[msg.sender] += amount_;
    for (uint256 i = 0; i < amount_; i++) _safeMint(msg.sender, supply++);
  }

  
  function isWhitelisted(address user_, bytes32[] memory proof_)
    public
    view
    returns (bool)
  {
    bytes32 leaf = keccak256(abi.encodePacked(user_));
    return proof_.verify(merkleRoot, leaf);
  }

  /**
   * @notice See {IERC721-tokenURI}.
   * @dev In order to make a metadata reveal, there must be an unrevealedURI string, which
   * gets set on the constructor and, for optimization purposes, when the owner() sets a new
   * baseURI, the unrevealedURI gets deleted, saving gas and triggering a reveal.
   */
  function tokenURI(uint256 tokenId_)
    public
    view
    override
    returns (string memory)
  {
    if (bytes(unrevealedURI).length > 0) return unrevealedURI;
    return
      string(abi.encodePacked(baseURI, tokenId_.toString(), baseExtension));
  }

  
  function setBaseURI(string memory baseURI_, string memory baseExtension_)
    external
    onlyAuthorized
  {
    baseURI = baseURI_;
    baseExtension = baseExtension_;
    delete unrevealedURI;
  }

  
  function setUnrevealedURI(string memory unrevealedURI_)
    external
    onlyAuthorized
  {
    unrevealedURI = unrevealedURI_;
  }

  
  function setSaleState(uint256 saleState_) external onlyAuthorized {
    saleState = saleState_;
  }

  
  function setMerkleRoot(bytes32 merkleRoot_) external onlyAuthorized {
    merkleRoot = merkleRoot_;
  }

  
  function setOpensea(address opensea_) external onlyAuthorized {
    opensea = opensea_;
  }

  
  function setLooksrare(address looksrare_) external onlyAuthorized {
    looksrare = looksrare_;
  }

  
  function toggleMarketplacesApproved() external onlyAuthorized {
    marketplacesApproved = !marketplacesApproved;
  }

  
  function togglePaused() external onlyAuthorized {
    _togglePaused();
  }

  /**
   * @notice Withdraw `amount_` of ether to msg.sender.
   * @dev Combined with the Auth util, this function can be called by
   * anyone with the authorization from the owner, so a team member can
   * get his shares with a permissioned call and exact data.
   */
  function withdraw(uint256 amount_) external onlyAuthorized {
    payable(msg.sender).transfer(amount_);
  }

  
  function isApprovedForAll(address owner, address operator)
    public
    view
    override
    returns (bool)
  {
    if (!marketplacesApproved) return super.isApprovedForAll(owner, operator);

    return
      operator == OpenSeaProxyRegistry(opensea).proxies(owner) ||
      operator == looksrare ||
      super.isApprovedForAll(owner, operator);
  }

  
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal override {
    require(
      msg.sender == owner() || paused() == false,
      "Pausable: contract paused"
    );
    super._beforeTokenTransfer(from, to, tokenId);
  }
}

contract OpenSeaProxyRegistry {
  mapping(address => address) public proxies;
}

interface IERC721Receiver {
  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes memory data
  ) external returns (bytes4);
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

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

// 
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}