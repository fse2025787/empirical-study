// SPDX-License-Identifier: MIT


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






contract DropMetadataRenderer is IMetadataRenderer, MetadataRenderAdminCheck {
    error MetadataFrozen();

    /// Event to mark updated metadata information
    event MetadataUpdated(
        address indexed target,
        string metadataBase,
        string metadataExtension,
        string contractURI,
        uint256 freezeAt
    );

    
    event ProvenanceHashUpdated(address indexed target, bytes32 provenanceHash);

    
    struct MetadataURIInfo {
        string base;
        string extension;
        string contractURI;
        uint256 freezeAt;
    }

    
    mapping(address => MetadataURIInfo) public metadataBaseByContract;

    
    mapping(address => bytes32) public provenanceHashes;

    
    
    function initializeWithData(bytes memory data) external {
        // data format: string baseURI, string newContractURI
        (string memory initialBaseURI, string memory initialContractURI) = abi
            .decode(data, (string, string));
        _updateMetadataDetails(
            msg.sender,
            initialBaseURI,
            "",
            initialContractURI,
            0
        );
    }

    
    
    
    function updateProvenanceHash(address target, bytes32 provenanceHash)
        external
        requireSenderAdmin(target)
    {
        provenanceHashes[target] = provenanceHash;
        emit ProvenanceHashUpdated(target, provenanceHash);
    }

    
    
    
    function updateMetadataBase(
        address target,
        string memory baseUri,
        string memory newContractUri
    ) external requireSenderAdmin(target) {
        _updateMetadataDetails(target, baseUri, "", newContractUri, 0);
    }

    
    
    
    
    
    function updateMetadataBaseWithDetails(
        address target,
        string memory metadataBase,
        string memory metadataExtension,
        string memory newContractURI,
        uint256 freezeAt
    ) external requireSenderAdmin(target) {
        _updateMetadataDetails(
            target,
            metadataBase,
            metadataExtension,
            newContractURI,
            freezeAt
        );
    }

    
    
    
    
    function _updateMetadataDetails(
        address target,
        string memory metadataBase,
        string memory metadataExtension,
        string memory newContractURI,
        uint256 freezeAt
    ) internal {
        if (freezeAt != 0 && freezeAt > block.timestamp) {
            revert MetadataFrozen();
        }

        metadataBaseByContract[target] = MetadataURIInfo({
            base: metadataBase,
            extension: metadataExtension,
            contractURI: newContractURI,
            freezeAt: freezeAt
        });
        emit MetadataUpdated({
            target: target,
            metadataBase: metadataBase,
            metadataExtension: metadataExtension,
            contractURI: newContractURI,
            freezeAt: freezeAt
        });
    }

    
    
    
    function contractURI() external view override returns (string memory) {
        string memory uri = metadataBaseByContract[msg.sender].contractURI;
        if (bytes(uri).length == 0) revert();
        return uri;
    }

    
    
    
    function tokenURI(uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        MetadataURIInfo memory info = metadataBaseByContract[msg.sender];

        if (bytes(info.base).length == 0) revert();

        return
            string(
                abi.encodePacked(
                    info.base,
                    StringsUpgradeable.toString(tokenId),
                    info.extension
                )
            );
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

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

    
    
    
    function setMetadataRenderer(IMetadataRenderer newRenderer, bytes memory setupRenderer) external;

    
    
    
    
    function adminMint(address to, uint256 quantity) external returns (uint256);

    
    
    
    function adminMintAirdrop(address[] memory to) external returns (uint256);

    
    
    function isAdmin(address user) external view returns (bool);
}