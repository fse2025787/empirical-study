// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.13;



/// stuck with a 2-word storage layout. engine + dropNodeId is 28 bytes, leaving
/// us with only 4 bytes for the remaining parameters.
struct SequenceData {
    uint64 sealedBeforeTimestamp;
    uint64 sealedAfterTimestamp;
    uint64 maxSupply;
    uint64 minted;
    IEngine engine;
    uint64 dropNodeId;
    // 4 bytes remaining
}


/// computation, and royalty computation.
interface IEngine {
    
    
    /// collection that can be used to pass setup and configuration data
    function configureSequence(
        uint16 sequenceId,
        SequenceData calldata sequence,
        bytes calldata engineData
    ) external;

    
    function getTokenURI(address collection, uint256 tokenId)
        external
        view
        returns (string memory);

    
    function getRoyaltyInfo(
        address collection,
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);
}// 
pragma solidity >=0.8.0;




library LibString {
    function toString(uint256 value) internal pure returns (string memory str) {
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but we allocate 160 bytes
            // to keep the free memory pointer word aligned. We'll need 1 word for the length, 1 word for the
            // trailing zeros padding, and 3 other words for a max of 78 digits. In total: 5 * 32 = 160 bytes.
            let newFreeMemoryPointer := add(mload(0x40), 160)

            // Update the free memory pointer to avoid overriding our string.
            mstore(0x40, newFreeMemoryPointer)

            // Assign str to the end of the zone of newly allocated memory.
            str := sub(newFreeMemoryPointer, 32)

            // Clean the last word of memory it may not be overwritten.
            mstore(str, 0)

            // Cache the end of the memory to calculate the length later.
            let end := str

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                // Move the pointer 1 byte to the left.
                str := sub(str, 1)

                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))

                // Keep dividing temp until zero.
                temp := div(temp, 10)

                 // prettier-ignore
                if iszero(temp) { break }
            }

            // Compute and cache the final total length of the string.
            let length := sub(end, str)

            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 32)

            // Store the string's length at the start of memory allocated for our string.
            mstore(str, length)
        }
    }
}

// 
pragma solidity ^0.8.13;

/*

███╗   ███╗███████╗████████╗ █████╗ ██╗      █████╗ ██████╗ ███████╗██╗
████╗ ████║██╔════╝╚══██╔══╝██╔══██╗██║     ██╔══██╗██╔══██╗██╔════╝██║
██╔████╔██║█████╗     ██║   ███████║██║     ███████║██████╔╝█████╗  ██║
██║╚██╔╝██║██╔══╝     ██║   ██╔══██║██║     ██╔══██║██╔══██╗██╔══╝  ██║
██║ ╚═╝ ██║███████╗   ██║   ██║  ██║███████╗██║  ██║██████╔╝███████╗███████╗
╚═╝     ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝


Deployed by Metalabel with 💖 as a permanent application on the Ethereum blockchain.

Metalabel is a growing universe of tools, knowledge, and resources for
metalabels and cultural collectives.

Our purpose is to establish the metalabel as key infrastructure for creative
collectives and to inspire a new culture of creative collaboration and mutual
support.

OUR SQUAD

Anna Bulbrook (Curator)
Austin Robey (Community)
Brandon Valosek (Engineer)
Ilya Yudanov (Designer)
Lauren Dorman (Engineer)
Rob Kalin (Board)
Yancey Strickler (Director)

https://metalabel.xyz

*/







/// per record is (2^80-1)/1e18 = 1,208,925 ETH. Royalty percentage is stored as
/// basis points, 5% = 500, max value of 100% = 10000 fits within 2byte int
struct DropData {
    uint80 price;
    uint16 royaltyBps;
    address payable revenueRecipient;
    // no bytes left
}


/// - Token data stores edition number on mint (immutable)
/// - Token URIs are derived from as single base URI + edition number
/// - All tokens are the same price
/// - Primary sales and royalties go to the same revenue recipient
contract DropEngine is IEngine {
    // ---
    // Errors
    // ---

    
    error IncorrectPaymentAmount();

    
    error InvalidPriceOrRecipient();

    
    /// sent from an invalid msg.sender
    error NotMintAuthority();

    
    /// mint authority set. Public mint opens after the mint authority is
    /// removed
    error PublicMintNotActive();

    
    error MinterMustBeEOA();

    // ---
    // Events
    // ---

    
    
    /// emitting the additonal engine-specific data here.
    event DropCreated(
        address collection,
        uint16 sequenceId,
        uint80 price,
        uint16 royaltyBps,
        address recipient,
        string uriPrefix,
        address mintAuthority
    );

    
    event PublicMintEnabled(address collection, uint16 sequenceId);

    // ---
    // Storage
    // ---

    
    mapping(address => mapping(uint16 => DropData)) public drops;

    
    
    /// storage reads on mint.
    mapping(address => mapping(uint16 => string)) public baseTokenURIs;

    
    /// mint.
    mapping(address => mapping(uint16 => address)) public mintAuthorities;

    // ---
    // Mint functionality
    // ---

    
    function mint(ICollection collection, uint16 sequenceId)
        external
        payable
        returns (uint256 tokenId)
    {
        if (msg.sender != tx.origin) revert MinterMustBeEOA();

        DropData storage drop = drops[address(collection)][sequenceId];
        if (msg.value != drop.price) revert IncorrectPaymentAmount();

        // Check if this sequence is permissioned -- so long as their is a mint
        // authority, public mint is not active
        if (mintAuthorities[address(collection)][sequenceId] != address(0)) {
            revert PublicMintNotActive();
        }

        // Immediately forward payment to the recipient. revenueRecipient could
        // be a malicious contract but transfer has a 2300 gas limit
        if (drop.price > 0) {
            drop.revenueRecipient.transfer(msg.value);
        }

        // Collection enforces max mint supply and mint window, so we're not
        // checking that here

        // If collection is a malicious contract, that does not impact any state
        // in the engine.  If it's a valid protocol-deployed collection, then it
        // will work as expected.
        tokenId = collection.mintRecord(msg.sender, sequenceId);
    }

    // ---
    // Permissioned functionality
    // ---

    
    /// permissioned mint authority for the sequence.
    function permissionedMint(
        ICollection collection,
        uint16 sequenceId,
        address to
    ) external returns (uint256 tokenId) {
        // Ensure msg.sender is the permissioned mint authority
        if (mintAuthorities[address(collection)][sequenceId] != msg.sender) {
            revert NotMintAuthority();
        }

        // Not loading drop data here or sending ETH, permissioned mints are
        // free. Max supply and mint window are still enforced by the downstream
        // collection.

        tokenId = collection.mintRecord(to, sequenceId);
    }

    
    function clearMintAuthority(ICollection collection, uint16 sequenceId)
        external
    {
        if (mintAuthorities[address(collection)][sequenceId] != msg.sender) {
            revert NotMintAuthority();
        }

        delete mintAuthorities[address(collection)][sequenceId];
        emit PublicMintEnabled(address(collection), sequenceId);
    }

    // ---
    // IEngine setup
    // ---

    
    
    /// collection from msg.sender, and use that to key the stored data. If
    /// somebody calls this function with bogus info (instead of it getting
    /// called via the collection), it just wastes storage but does not impact
    /// contract functionality
    function configureSequence(
        uint16 sequenceId,
        SequenceData calldata, /* sequenceData */
        bytes calldata engineData
    ) external {
        (
            uint80 price,
            uint16 royaltyBps,
            address payable recipient,
            string memory uriPrefix,
            address mintAuthority
        ) = abi.decode(engineData, (uint80, uint16, address, string, address));

        // Ensure that if a price is set, a recipient is set, and vice versa
        if ((price == 0) != (recipient == address(0))) {
            revert InvalidPriceOrRecipient();
        }

        // Set the permissioned mint authority if provided
        if (mintAuthority != address(0)) {
            mintAuthorities[msg.sender][sequenceId] = mintAuthority;
        }

        // Write engine data (passed through from the collection when the
        // collection admin calls `configureSequence`) to a struct in the engine
        // with all the needed info.
        drops[msg.sender][sequenceId] = DropData({
            price: price,
            royaltyBps: royaltyBps,
            revenueRecipient: recipient
        });
        baseTokenURIs[msg.sender][sequenceId] = uriPrefix;
        emit DropCreated(
            msg.sender,
            sequenceId,
            price,
            royaltyBps,
            recipient,
            uriPrefix,
            mintAuthority
        );
    }

    // ---
    // IEngine views
    // ---

    
    
    /// number is written to immutable token data on mint.
    function getTokenURI(address collection, uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        uint16 sequenceId = ICollection(collection).tokenSequenceId(tokenId);
        uint80 editionNumber = ICollection(collection).tokenMintData(tokenId);

        return
            string(
                abi.encodePacked(
                    baseTokenURIs[collection][sequenceId],
                    LibString.toString(editionNumber),
                    ".json"
                )
            );
    }

    
    
    function getRoyaltyInfo(
        address collection,
        uint256 tokenId,
        uint256 salePrice
    ) external view override returns (address, uint256) {
        uint16 sequenceId = ICollection(collection).tokenSequenceId(tokenId);
        DropData memory drop = drops[collection][sequenceId];
        return (drop.revenueRecipient, (salePrice * drop.royaltyBps) / 10000);
    }
}

// 
pragma solidity ^0.8.13;


interface ICollection {
    
    /// callable by the sequence-specific engine.
    function mintRecord(
        address to,
        uint16 sequenceId,
        uint80 tokenData
    ) external returns (uint256 tokenId);

    
    /// written to the immutable token data. Only callable by the
    /// sequence-specific engine.
    function mintRecord(address to, uint16 sequenceId)
        external
        returns (uint256 tokenId);

    
    function tokenSequenceId(uint256 tokenId)
        external
        view
        returns (uint16 sequenceId);

    
    function tokenMintData(uint256 tokenId) external view returns (uint80 data);
}
