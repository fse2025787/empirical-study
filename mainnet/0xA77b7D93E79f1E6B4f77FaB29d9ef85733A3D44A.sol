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

/**
  @title ITypeface

  @author peri

  @notice Interface for Typeface contract
 */

pragma solidity ^0.8.8;

struct Font {
    uint256 weight;
    string style;
}

interface ITypeface {
    
    
    event SetSource(Font font);

    
    
    
    event SetSourceHash(Font font, bytes32 sourceHash);

    
    
    event SetDonationAddress(address donationAddress);

    
    function name() external view returns (string memory);

    
    
    
    
    function supportsCodePoint(bytes3 codePoint) external view returns (bool);

    
    
    
    function sourceOf(Font memory font) external view returns (bytes memory);

    
    
    
    function hasSource(Font memory font) external view returns (bool);

    
    
    
    function setSource(Font memory font, bytes memory source) external;

    
    
    function setDonationAddress(address donationAddress) external;

    
    
    function donationAddress() external view returns (address);
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
pragma solidity ^0.8.8;




/**
  @title Typeface

  @author peri

  @notice The Typeface contract allows storing and retrieving a "source", such as a base64-encoded file, for all fonts in a typeface.

  Sources may be large and require a high gas fee to store. To reduce gas costs while deploying a contract containing source data, or to avoid surpassing gas limits of the deploy transaction block, only a hash of each source is stored when the contract is deployed. This allows sources to be stored in later transactions, ensuring the hash of the source matches the hash already stored for that font.

  Once the Typeface contract has been deployed, source hashes can't be added or modified.

  Fonts are identified by the Font struct, which includes "style" and "weight" properties.
 */

abstract contract Typeface is ITypeface, ERC165 {
    modifier onlyDonationAddress() {
        if (msg.sender != _donationAddress) {
            revert("Typeface: Not donation address");
        }
        _;
    }

    
    mapping(string => mapping(uint256 => bytes)) private _source;

    
    mapping(string => mapping(uint256 => bytes32)) private _sourceHash;

    
    
    mapping(string => mapping(uint256 => bool)) private _hasSource;

    
    address _donationAddress;

    
    string private _name;

    
    
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    
    
    
    function sourceOf(Font memory font)
        public
        view
        virtual
        returns (bytes memory)
    {
        return _source[font.style][font.weight];
    }

    
    
    
    function hasSource(Font memory font) public view virtual returns (bool) {
        return _hasSource[font.style][font.weight];
    }

    
    
    
    function sourceHash(Font memory font)
        public
        view
        virtual
        returns (bytes32)
    {
        return _sourceHash[font.style][font.weight];
    }

    
    
    function donationAddress() external view returns (address) {
        return _donationAddress;
    }

    
    
    function setDonationAddress(address __donationAddress) external {
        _setDonationAddress(__donationAddress);
    }

    function _setDonationAddress(address __donationAddress) internal {
        _donationAddress = payable(__donationAddress);

        emit SetDonationAddress(__donationAddress);
    }

    
    
    
    
    function setSource(Font calldata font, bytes calldata source) public {
        require(!hasSource(font), "Typeface: Source already exists");

        require(
            keccak256(source) == sourceHash(font),
            "Typeface: Invalid font"
        );

        _beforeSetSource(font, source);

        _source[font.style][font.weight] = source;
        _hasSource[font.style][font.weight] = true;

        emit SetSource(font);

        _afterSetSource(font, source);
    }

    
    
    
    
    function _setSourceHashes(Font[] memory fonts, bytes32[] memory hashes)
        internal
    {
        require(
            fonts.length == hashes.length,
            "Typeface: Unequal number of fonts and hashes"
        );

        for (uint256 i; i < fonts.length; i++) {
            _sourceHash[fonts[i].style][fonts[i].weight] = hashes[i];

            emit SetSourceHash(fonts[i], hashes[i]);
        }
    }

    constructor(string memory __name, address __donationAddress) {
        _name = __name;
        _setDonationAddress(__donationAddress);
    }

    
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165)
        returns (bool)
    {
        return
            interfaceId == type(ITypeface).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    
    function _beforeSetSource(Font calldata font, bytes calldata src)
        internal
        virtual
    {}

    
    function _afterSetSource(Font calldata font, bytes calldata src)
        internal
        virtual
    {}
}

// 

/**
  @title ITypeface

  @author peri

  @notice Interface for Typeface contract
 */

pragma solidity ^0.8.8;



interface ITypefaceExpandable is ITypeface {
    event SetOperator(address operator);

    function operator() external view returns (address);

    function setSourceHashes(Font[] memory fonts, bytes32[] memory hashes)
        external;

    function setOperator(address operator) external;
}
// 
pragma solidity ^0.8.8;





/**
  @title TypefaceExpandable

  @author peri

  @notice TypefaceExpandable is an extension of the Typeface contract that allows an operator to add or modify font hashes after the contract has been deployed, as long as a source for the font hasn't been stored yet.
 */

abstract contract TypefaceExpandable is Typeface, ITypefaceExpandable {
    
    modifier onlyOperator() {
        if (msg.sender != _operator) revert("TypefaceExpandable: Not operator");
        _;
    }

    
    modifier onlyUnstoredFonts(Font[] calldata fonts) {
        for (uint256 i; i < fonts.length; i++) {
            Font memory font = fonts[i];
            if (hasSource(font)) {
                revert("TypefaceExpandable: Source already exists");
            }
        }
        _;
    }

    /// Address with permission to add or modify font hashes, as long as no source has been stored for that font.
    address internal _operator;

    
    
    
    
    function setSourceHashes(Font[] calldata fonts, bytes32[] calldata hashes)
        external
        onlyOperator
        onlyUnstoredFonts(fonts)
    {
        _setSourceHashes(fonts, hashes);
    }

    
    
    function operator() external view returns (address) {
        return _operator;
    }

    
    
    function setOperator(address __operator) external onlyOperator {
        _setOperator(__operator);
    }

    constructor(
        string memory __name,
        address donationAddress,
        address __operator
    ) Typeface(__name, donationAddress) {
        _setOperator(__operator);
    }

    
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(Typeface)
        returns (bool)
    {
        return
            interfaceId == type(ITypefaceExpandable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _setOperator(address __operator) internal {
        _operator = __operator;

        emit SetOperator(__operator);
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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

/**
  @title Capsules Typeface

  @author peri

  @notice Capsules typeface stored on-chain using the TypefaceExpandable contract, allowing additional fonts to be added later.
 */

pragma solidity ^0.8.8;




contract CapsulesTypeface is TypefaceExpandable {
    /// Address of CapsuleToken contract
    ICapsuleToken public immutable capsuleToken;

    /// Mapping of style => weight => address that stored the font.
    mapping(string => mapping(uint256 => address)) private _patronOf;

    constructor(
        address _capsuleToken,
        address donationAddress,
        address operator
    ) TypefaceExpandable("Capsules", donationAddress, operator) {
        capsuleToken = ICapsuleToken(_capsuleToken);
    }

    
    
    
    function patronOf(Font calldata font) external view returns (address) {
        return _patronOf[font.style][font.weight];
    }

    
    
    
    function supportsCodePoint(bytes3 cp) external pure returns (bool) {
        // Optimize gas by first checking outer bounds of byte ranges
        if (cp < 0x000020 || cp > 0x00ffe6) return false;

        return ((cp >= 0x000020 && cp <= 0x00007e) ||
            (cp >= 0x0000a0 && cp <= 0x0000a8) ||
            (cp >= 0x0000ab && cp <= 0x0000ac) ||
            (cp >= 0x0000af && cp <= 0x0000b1) ||
            cp == 0x0000b4 ||
            (cp >= 0x0000b6 && cp <= 0x0000b7) ||
            (cp >= 0x0000ba && cp <= 0x0000bb) ||
            (cp >= 0x0000bf && cp <= 0x0000c4) ||
            (cp >= 0x0000c6 && cp <= 0x0000cf) ||
            (cp >= 0x0000d1 && cp <= 0x0000d7) ||
            (cp >= 0x0000d9 && cp <= 0x0000dc) ||
            (cp >= 0x0000e0 && cp <= 0x0000e4) ||
            (cp >= 0x0000e6 && cp <= 0x0000ef) ||
            (cp >= 0x0000f1 && cp <= 0x0000fc) ||
            (cp >= 0x0000ff && cp <= 0x000101) ||
            (cp >= 0x000112 && cp <= 0x000113) ||
            (cp >= 0x000128 && cp <= 0x00012b) ||
            cp == 0x000131 ||
            (cp >= 0x00014c && cp <= 0x00014d) ||
            (cp >= 0x000168 && cp <= 0x00016b) ||
            cp == 0x000178 ||
            cp == 0x000192 ||
            cp == 0x000262 ||
            cp == 0x00026a ||
            cp == 0x000274 ||
            cp == 0x000280 ||
            cp == 0x00028f ||
            cp == 0x000299 ||
            cp == 0x00029c ||
            cp == 0x00029f ||
            (cp >= 0x0002c2 && cp <= 0x0002c3) ||
            cp == 0x0002c6 ||
            cp == 0x0002dc ||
            cp == 0x000394 ||
            cp == 0x00039e ||
            cp == 0x0003c0 ||
            cp == 0x000e3f ||
            (cp >= 0x001d00 && cp <= 0x001d01) ||
            cp == 0x001d05 ||
            cp == 0x001d07 ||
            (cp >= 0x001d0a && cp <= 0x001d0b) ||
            cp == 0x001d0d ||
            cp == 0x001d18 ||
            cp == 0x001d1b ||
            (cp >= 0x002013 && cp <= 0x002015) ||
            (cp >= 0x002017 && cp <= 0x00201a) ||
            (cp >= 0x00201c && cp <= 0x00201e) ||
            (cp >= 0x002020 && cp <= 0x002022) ||
            cp == 0x002026 ||
            cp == 0x002030 ||
            (cp >= 0x002032 && cp <= 0x002033) ||
            (cp >= 0x002039 && cp <= 0x00203a) ||
            cp == 0x00203c ||
            cp == 0x00203e ||
            cp == 0x002044 ||
            cp == 0x00204e ||
            (cp >= 0x002058 && cp <= 0x00205b) ||
            (cp >= 0x00205d && cp <= 0x00205e) ||
            (cp >= 0x0020a3 && cp <= 0x0020a4) ||
            (cp >= 0x0020a6 && cp <= 0x0020a9) ||
            (cp >= 0x0020ac && cp <= 0x0020ad) ||
            (cp >= 0x0020b2 && cp <= 0x0020b6) ||
            cp == 0x0020b8 ||
            cp == 0x0020ba ||
            (cp >= 0x0020bc && cp <= 0x0020bd) ||
            cp == 0x0020bf ||
            cp == 0x00211e ||
            cp == 0x002126 ||
            (cp >= 0x002190 && cp <= 0x002199) ||
            (cp >= 0x0021ba && cp <= 0x0021bb) ||
            cp == 0x002206 ||
            cp == 0x00220f ||
            (cp >= 0x002211 && cp <= 0x002214) ||
            cp == 0x00221a ||
            cp == 0x00221e ||
            cp == 0x00222b ||
            cp == 0x002238 ||
            cp == 0x002243 ||
            cp == 0x002248 ||
            (cp >= 0x002254 && cp <= 0x002255) ||
            cp == 0x002260 ||
            (cp >= 0x002264 && cp <= 0x002267) ||
            (cp >= 0x00229e && cp <= 0x0022a1) ||
            cp == 0x0022c8 ||
            (cp >= 0x002302 && cp <= 0x002304) ||
            cp == 0x002310 ||
            cp == 0x00231b ||
            cp == 0x0023cf ||
            (cp >= 0x0023e9 && cp <= 0x0023ea) ||
            (cp >= 0x0023ed && cp <= 0x0023ef) ||
            (cp >= 0x0023f8 && cp <= 0x0023fa) ||
            (cp >= 0x002506 && cp <= 0x002507) ||
            cp == 0x00250c ||
            (cp >= 0x00250f && cp <= 0x002510) ||
            (cp >= 0x002513 && cp <= 0x002514) ||
            (cp >= 0x002517 && cp <= 0x002518) ||
            (cp >= 0x00251b && cp <= 0x00251c) ||
            (cp >= 0x002523 && cp <= 0x002524) ||
            (cp >= 0x00252b && cp <= 0x00252c) ||
            (cp >= 0x002533 && cp <= 0x002534) ||
            (cp >= 0x00253b && cp <= 0x00253c) ||
            (cp >= 0x00254b && cp <= 0x00254f) ||
            (cp >= 0x00256d && cp <= 0x00257b) ||
            (cp >= 0x002580 && cp <= 0x002590) ||
            (cp >= 0x002594 && cp <= 0x002595) ||
            (cp >= 0x002599 && cp <= 0x0025a1) ||
            (cp >= 0x0025b0 && cp <= 0x0025b2) ||
            cp == 0x0025b6 ||
            cp == 0x0025bc ||
            cp == 0x0025c0 ||
            cp == 0x0025ca ||
            (cp >= 0x0025cf && cp <= 0x0025d3) ||
            (cp >= 0x0025d6 && cp <= 0x0025d7) ||
            (cp >= 0x0025e0 && cp <= 0x0025e5) ||
            (cp >= 0x0025e7 && cp <= 0x0025eb) ||
            (cp >= 0x0025f0 && cp <= 0x0025f3) ||
            (cp >= 0x0025f8 && cp <= 0x0025fa) ||
            (cp >= 0x0025ff && cp <= 0x002600) ||
            cp == 0x002610 ||
            cp == 0x002612 ||
            (cp >= 0x002630 && cp <= 0x002637) ||
            (cp >= 0x002639 && cp <= 0x00263a) ||
            cp == 0x00263c ||
            cp == 0x002665 ||
            (cp >= 0x002680 && cp <= 0x002685) ||
            (cp >= 0x00268a && cp <= 0x002691) ||
            cp == 0x0026a1 ||
            cp == 0x002713 ||
            cp == 0x002795 ||
            cp == 0x002797 ||
            (cp >= 0x0029d1 && cp <= 0x0029d5) ||
            cp == 0x0029fa ||
            cp == 0x002a25 ||
            (cp >= 0x002a2a && cp <= 0x002a2c) ||
            (cp >= 0x002a71 && cp <= 0x002a72) ||
            cp == 0x002a75 ||
            (cp >= 0x002a99 && cp <= 0x002a9a) ||
            (cp >= 0x002b05 && cp <= 0x002b0d) ||
            (cp >= 0x002b16 && cp <= 0x002b19) ||
            (cp >= 0x002b90 && cp <= 0x002b91) ||
            cp == 0x002b95 ||
            cp == 0x00a730 ||
            cp == 0x00a7af ||
            (cp >= 0x00e000 && cp <= 0x00e02c) ||
            (cp >= 0x00e02e && cp <= 0x00e032) ||
            cp == 0x00e069 ||
            (cp >= 0x00e420 && cp <= 0x00e421) ||
            cp == 0x00fe69 ||
            cp == 0x00ff04 ||
            (cp >= 0x00ffe0 && cp <= 0x00ffe1) ||
            (cp >= 0x00ffe5 && cp <= 0x00ffe6));
    }

    
    function _afterSetSource(Font calldata font, bytes calldata)
        internal
        override(Typeface)
    {
        _patronOf[font.style][font.weight] = msg.sender;

        capsuleToken.mintPureColorForFont(msg.sender, font);
    }
}

// 

/**
  @title ICapsuleToken

  @author peri

  @notice Interface for CapsuleToken contract
 */

pragma solidity ^0.8.8;






struct Capsule {
    uint256 id;
    bytes3 color;
    Font font;
    bytes32[8] text;
    bool isPure;
}

interface ICapsuleToken {
    event AddValidRenderer(address renderer);
    event MintCapsule(
        uint256 indexed id,
        address indexed to,
        bytes3 indexed color,
        Font font,
        bytes32[8] text
    );
    event MintGift(address minter);
    event SetDefaultRenderer(address renderer);
    event SetFeeReceiver(address receiver);
    event SetMetadata(address metadata);
    event SetPureColors(bytes3[] colors);
    event SetRoyalty(uint256 royalty);
    event SetCapsuleFont(uint256 indexed id, Font font);
    event SetCapsuleRenderer(uint256 indexed id, address renderer);
    event SetCapsuleText(uint256 indexed id, bytes32[8] text);
    event SetContractURI(string contractURI);
    event SetGiftCount(address _address, uint256 count);
    event Withdraw(address to, uint256 amount);

    function capsuleOf(uint256 capsuleId)
        external
        view
        returns (Capsule memory);

    function isPureColor(bytes3 color) external view returns (bool);

    function colorOf(uint256 capsuleId) external view returns (bytes3);

    function textOf(uint256 capsuleId)
        external
        view
        returns (bytes32[8] memory);

    function fontOf(uint256 capsuleId) external view returns (Font memory);

    function svgOf(uint256 capsuleId) external view returns (string memory);

    function mint(
        bytes3 color,
        Font calldata font,
        bytes32[8] memory text
    ) external payable returns (uint256);

    function mintPureColorForFont(address to, Font calldata font)
        external
        returns (uint256);

    function mintAsOwner(
        address to,
        bytes3 color,
        Font calldata font,
        bytes32[8] calldata text
    ) external payable returns (uint256);

    function setGiftCounts(
        address[] calldata addresses,
        uint256[] calldata counts
    ) external;

    function setTextAndFont(
        uint256 capsuleId,
        bytes32[8] calldata text,
        Font calldata font
    ) external;

    function setText(uint256 capsuleId, bytes32[8] calldata text) external;

    function setFont(uint256 capsuleId, Font calldata font) external;

    function setRendererOf(uint256 capsuleId, address renderer) external;

    function setDefaultRenderer(address renderer) external;

    function addValidRenderer(address renderer) external;

    function burn(uint256 capsuleId) external;

    function isValidFontForRenderer(Font memory font, address renderer)
        external
        view
        returns (bool);

    function isValidColor(bytes3 color) external view returns (bool);

    function isValidCapsuleText(uint256 capsuleId) external view returns (bool);

    function isValidRenderer(address renderer) external view returns (bool);

    function contractURI() external view returns (string memory);

    function withdraw() external;

    function setFeeReceiver(address _feeReceiver) external;

    function setRoyalty(uint256 _royalty) external;

    function setContractURI(string calldata _contractURI) external;

    function pause() external;

    function unpause() external;
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

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
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
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
