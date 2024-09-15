// SPDX-License-Identifier: GPL-3.0-only

/**
 *Submitted for verification at Etherscan.io on 2022-07-06
*/

// 

pragma solidity 0.8.12;

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
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}
interface IVoterID {
    /**
        @notice Minting function
    */
    function createIdentityFor(address newId, uint tokenId, string calldata uri) external;

    /**
        @notice Who has the authority to override metadata uri
    */
    function owner() external view returns (address);

    /**
        @notice How many of these things exist?
    */
    function totalSupply() external view returns (uint);
}





contract VoterID is IVoterID {

    // mapping from tokenId to owner of that tokenId
    mapping (uint => address) public owners;
    // mapping from address to amount of NFTs they own
    mapping (address => uint) public balances;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) public operatorApprovals;
    // weird single-address-per-token-id mapping (why not just use operatorApprovals??)
    mapping (uint => address) public tokenApprovals;

    // forward and backward mappings used for enumerable standard
    // owner -> array of tokens owned...  ownershipMapIndexToToken[owner][index] = tokenNumber
    // owner -> array of tokens owned...  ownershipMapTokenToIndex[owner][tokenNumber] = index
    mapping (address => mapping (uint => uint)) public ownershipMapIndexToToken;
    mapping (address => mapping (uint => uint)) public ownershipMapTokenToIndex;

    // array-like map of all tokens in existence #enumeration
    mapping (uint => uint) public allTokens;

    // tokenId -> uri ... typically ipfs://...
    mapping (uint => string) public uriMap;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c5 ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;

    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant INTERFACE_ID_ERC165 = 0x01ffc9a7;

    bytes4 private constant INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;
    bytes4 private constant INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    string _name;
    string _symbol;

    // count the number of NFTs minted
    uint public numIdentities;

    // owner is a special name in the OpenZeppelin standard that opensea annoyingly expects for their management page
    address public _owner_;
    // minter has the sole, permanent authority to mint identities, in practice this will be a contract
    address public _minter;

    event OwnerUpdated(address oldOwner, address newOwner);
    event IdentityCreated(address indexed owner, uint indexed token);


    
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    error TokenAlreadyExists(uint tokenId);
    error OnlyMinter(address notMinter);
    error OnlyOwner(address notOwner);
    error InvalidToken(uint tokenId);
    error InvalidIndex(uint tokenIndex);
    error ZeroAddress();
    error TokenOwnershipRequired(uint tokenId, address notOwner);
    error UnauthorizedApproval(uint tokenId, address unauthorized);
    error SelfApproval(uint tokenId, address owner);
    error NFTUnreceivable(address receiver);
    error UnapprovedTransfer(uint tokenId, address notApproved);

    
    
    
    
    
    
    constructor(address ooner, address minter, string memory nomen, string memory symbowl) {
        _owner_ = ooner;
        // we set it here with no resetting allowed so we cannot commit to NFTs and then reset
        _minter = minter;
        _name = nomen;
        _symbol = symbowl;
    }

    
    
    
    
    
    
    function createIdentityFor(address thisOwner, uint thisToken, string calldata uri) external override {
        if (msg.sender != _minter) {
            revert OnlyMinter(msg.sender);
        }
        if (owners[thisToken] != address(0)) {
            revert TokenAlreadyExists(thisToken);
        }

        // for getTokenByIndex below, 0 based index so we do it before incrementing numIdentities
        allTokens[numIdentities++] = thisToken;

        // two way mapping for enumeration
        ownershipMapIndexToToken[thisOwner][balances[thisOwner]] = thisToken;
        ownershipMapTokenToIndex[thisOwner][thisToken] = balances[thisOwner];


        // set owner of new token
        owners[thisToken] = thisOwner;
        // increment balances for owner
        ++balances[thisOwner];
        uriMap[thisToken] = uri;
        emit Transfer(address(0), thisOwner, thisToken);
        emit IdentityCreated(thisOwner, thisToken);
    }

    /// ================= SETTERS =======================================

    
    
    
    function setOwner(address newOwner) external {
        if (msg.sender != _owner_) {
            revert OnlyOwner(msg.sender);
        }

        address oldOwner = _owner_;
        _owner_ = newOwner;
        emit OwnerUpdated(oldOwner, newOwner);
    }

    // manually set the token URI
    
    
    
    
    function setTokenURI(uint token, string calldata uri) external {
        if (msg.sender != _owner_) {
            revert OnlyOwner(msg.sender);
        }

        uriMap[token] = uri;
    }

    function endMinting() external {
        if (msg.sender != _owner_) {
            revert OnlyOwner(msg.sender);
        }

        _minter = address(0);
    }

    /// ================= ERC 721 FUNCTIONS =============================================

    
    
    ///  function throws for queries about the zero address.
    
    
    function balanceOf(address _address) external view returns (uint256) {
        if (_address == address(0)) {
            revert ZeroAddress();
        }
        return balances[_address];
    }

    
    
    ///  about them do throw.
    
    
    function ownerOf(uint256 tokenId) external view returns (address)  {
        address ooner = owners[tokenId];
        if (ooner == address(0)) {
            revert InvalidToken(tokenId);
        }
        return ooner;
    }

    
    ///  TO CONFIRM THAT `to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    
    ///  operator, or the approved address for this NFT. Throws if `from` is
    ///  not the current owner. Throws if `to` is the zero address. Throws if
    ///  `tokenId` is not a valid NFT.
    
    
    
    function transferFrom(address from, address to, uint256 tokenId) public {
        if (isApproved(msg.sender, tokenId) == false) {
            revert UnapprovedTransfer(tokenId, msg.sender);
        }
        transfer(from, to, tokenId);
    }

    
    
    ///  operator, or the approved address for this NFT. Throws if `from` is
    ///  not the current owner. Throws if `to` is the zero address. Throws if
    ///  `tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    
    
    
    
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        if (checkOnERC721Received(from, to, tokenId, data) == false) {
            revert NFTUnreceivable(to);
        }
        transferFrom(from, to, tokenId);
    }

    
    
    ///  except this function just sets data to "".
    
    
    
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, '');
    }

    
    
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    
    
    function approve(address approved, uint256 tokenId) public {
        address holder = owners[tokenId];
        if (isApproved(msg.sender, tokenId) == false) {
            revert UnauthorizedApproval(tokenId, msg.sender);
        }
        if (holder == approved) {
            revert SelfApproval(tokenId, holder);
        }
        tokenApprovals[tokenId] = approved;
        emit Approval(holder, approved, tokenId);
    }

    
    ///  all of `msg.sender`'s assets
    
    ///  multiple operators per owner.
    
    
    function setApprovalForAll(address operator, bool approved) external {
        operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    
    
    
    
    function getApproved(uint256 tokenId) external view returns (address) {
        address holder = owners[tokenId];
        if (holder == address(0)) {
            revert InvalidToken(tokenId);
        }
        return tokenApprovals[tokenId];
    }

    
    
    
    
    function isApprovedForAll(address _address, address operator) public view returns (bool) {
        return operatorApprovals[_address][operator];
    }

    /// ================ UTILS =========================

    
    
    
    
    
    function isApproved(address operator, uint tokenId) public view returns (bool) {
        address holder = owners[tokenId];
        return (
            operator == holder ||
            operatorApprovals[holder][operator] ||
            tokenApprovals[tokenId] == operator
        );
    }

    /**
     * @notice Standard NFT transfer logic
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     * @param from current owner of the NFT
     * @param to new owner of the NFT
     * @param tokenId which NFT is getting transferred
     */
    function transfer(address from, address to, uint256 tokenId) internal {
        if (owners[tokenId] != from) {
            revert TokenOwnershipRequired(tokenId, from);
        }
        if (to == address(0)) {
            revert ZeroAddress();
        }

        // Clear approvals from the previous owner
        approve(address(0), tokenId);

        owners[tokenId] = to;

        // update balances
        balances[from] -= 1;


        // zero out two way mapping
        uint ownershipIndex = ownershipMapTokenToIndex[from][tokenId];
        ownershipMapTokenToIndex[from][tokenId] = 0;
        if (ownershipIndex != balances[from]) {
            uint reslottedToken = ownershipMapIndexToToken[from][balances[from]];
            ownershipMapIndexToToken[from][ownershipIndex] = reslottedToken;
            ownershipMapIndexToToken[from][balances[from]] = 0;
            ownershipMapTokenToIndex[from][reslottedToken] = ownershipIndex;
        } else {
            ownershipMapIndexToToken[from][ownershipIndex] = 0;
        }

        // set two way mapping
        ownershipMapIndexToToken[to][balances[to]] = tokenId;
        ownershipMapTokenToIndex[to][tokenId] = balances[to];

        balances[to] += 1;


        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data)
        private returns (bool)
    {
        if (to.code.length == 0) {
            return true;
        }
        IERC721Receiver target = IERC721Receiver(to);
        bytes4 retval = target.onERC721Received(from, to, tokenId, data);
        return ERC721_RECEIVED == retval;
    }

    /**
     * @notice ERC165 function to tell other contracts which interfaces we support
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     * @dev This whole interface thing is a little pointless, because contracts can lie or mis-implement the interface
     * @dev so you might as well just use a try catch
     * @param interfaceId the first four bytes of the hash of the signatures of the functions of the interface in question
     * @return supports true if the interface is supported, false otherwise
     */
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return (
            interfaceId == INTERFACE_ID_ERC721 ||
            interfaceId == INTERFACE_ID_ERC165 ||
            interfaceId == INTERFACE_ID_ERC721_ENUMERABLE ||
            interfaceId == INTERFACE_ID_ERC721_METADATA
        );
    }

    /// ================= ERC721Metadata FUNCTIONS =============================================

    
    
    function name() external view returns (string memory) {
        return _name;
    }

    
    
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    
    
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    
    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        if (owners[_tokenId] == address(0)) {
            revert InvalidToken(_tokenId);
        }
        return uriMap[_tokenId];
    }

    
    
    function owner() public view override returns (address) {
        return _owner_;
    }

    /// ================= ERC721Enumerable FUNCTIONS =============================================


    
    
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view override returns (uint256) {
        return numIdentities;
    }

    
    
    
    
    ///  (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (uint256) {
        if (_index >= numIdentities) {
            revert InvalidIndex(_index);
        }
        return allTokens[_index];
    }

    
    
    ///  `_owner_` is the zero address, representing invalid NFTs.
    
    
    
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address _address, uint256 _index) external view returns (uint256) {
        if (_index >= balances[_address]) {
            revert InvalidIndex(_index);
        }
        if (_address == address(0)) {
            revert ZeroAddress();
        }
        return ownershipMapIndexToToken[_address][_index];
    }


}