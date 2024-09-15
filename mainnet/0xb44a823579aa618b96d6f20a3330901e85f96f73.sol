
pragma solidity ^0.4.14;
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}



contract ERC721 {
    // Required methods
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);

    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);
}


///  it has one function that will return the data as bytes.
contract ERC721Metadata {
    
    function getMetadata(uint256 _tokenId, string) public pure returns (bytes32[4] buffer, uint256 count) {
        if (_tokenId == 1) {
            buffer[0] = "Hello World! :D";
            count = 15;
        } else if (_tokenId == 2) {
            buffer[0] = "I would definitely choose a medi";
            buffer[1] = "um length string.";
            count = 49;
        } else if (_tokenId == 3) {
            buffer[0] = "Lorem ipsum dolor sit amet, mi e";
            buffer[1] = "st accumsan dapibus augue lorem,";
            buffer[2] = " tristique vestibulum id, libero";
            buffer[3] = " suscipit varius sapien aliquam.";
            count = 128;
        }
    }
}




contract ClockAuctionBase {

    // Represents an auction on an NFT
    struct Auction {
        // Current owner of NFT
        address seller;
        // Price (in wei) at beginning of auction
        uint128 startingPrice;
        // Price (in wei) at end of auction
        uint128 endingPrice;
        // Duration (in seconds) of auction
        uint64 duration;
        // Time when auction started
        // NOTE: 0 if this auction has been concluded
        uint64 startedAt;
    }

    // Reference to contract tracking NFT ownership
    ERC721 public nonFungibleContract;

    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // Values 0-10,000 map to 0%-100%
    uint256 public ownerCut;

    // Map from token ID to their corresponding auction.
    mapping (uint256 => Auction) internal tokenIdToAuction;

    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration, uint256 startedAt);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);
    event AuctionCancelled(uint256 tokenId);

    
    
    
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }

    
    /// Throws if the escrow fails.
    
    
    function _escrow(address _owner, uint256 _tokenId) internal {
        // it will throw if transfer fails
        nonFungibleContract.transferFrom(_owner, this, _tokenId);
    }

    
    /// Returns true if the transfer succeeds.
    
    
    function _transfer(address _receiver, uint256 _tokenId) internal {
        // it will throw if transfer fails
        nonFungibleContract.transfer(_receiver, _tokenId);
    }

    
    ///  AuctionCreated event.
    
    
    function _addAuction(uint256 _tokenId, Auction _auction) internal {
        // Require that all auctions have a duration of
        // at least one minute. (Keeps our math from getting hairy!)
        require(_auction.duration >= 1 minutes);

        tokenIdToAuction[_tokenId] = _auction;

        AuctionCreated(
            uint256(_tokenId),
            uint256(_auction.startingPrice),
            uint256(_auction.endingPrice),
            uint256(_auction.duration),
            uint256(_auction.startedAt)
        );
    }

    
    function _cancelAuction(uint256 _tokenId, address _seller) internal {
        _removeAuction(_tokenId);
        _transfer(_seller, _tokenId);
        AuctionCancelled(_tokenId);
    }

    
    /// Does NOT transfer ownership of token.
    function _bid(uint256 _tokenId, uint256 _bidAmount) internal returns (uint256) {
        // Get a reference to the auction struct
        Auction storage auction = tokenIdToAuction[_tokenId];

        // Explicitly check that this auction is currently live.
        //(Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(_isOnAuction(auction));

        // Check that the bid is greater than or equal to the current price
        uint256 price = _currentPrice(auction);
        require(_bidAmount >= price);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address seller = auction.seller;

        // The bid is good! Remove the auction before sending the fees
        // to the sender so we can't have a reentrancy attack.
        _removeAuction(_tokenId);

        // Transfer proceeds to seller (if there are any!)
        if (price > 0) {
            // Calculate the auctioneer's cut. (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 auctioneerCut = _computeCut(price);
            uint256 sellerProceeds = price - auctioneerCut;
            // NOTE: Doing a transfer() in the middle of a complex
            // method like this is generally discouraged because of
            // reentrancy attacks and DoS attacks if the seller is
            // a contract with an invalid fallback function. We explicitly
            // guard against reentrancy attacks by removing the auction
            // before calling transfer(), and the only thing the seller
            // can DoS is the sale of their own asset! (And if it's an
            // accident, they can call cancelAuction(). )
            seller.transfer(sellerProceeds);
        }
        // Calculate any excess funds included with the bid. If the excess
        // is anything worth worrying about, transfer it back to bidder.
        // NOTE: We checked above that the bid amount is greater than or
        // equal to the price so this cannot underflow.
        uint256 bidExcess = _bidAmount - price;

        // Return the funds. Similar to the previous transfer, this is
        // not susceptible to a re-entry attack because the auction is
        // removed before any transfers occur.
        msg.sender.transfer(bidExcess);
        // Tell the world!
        AuctionSuccessful(_tokenId, price, msg.sender);
        return price;
    }

    
    
    function _removeAuction(uint256 _tokenId) internal {
        delete tokenIdToAuction[_tokenId];
    }

    
    
    function _isOnAuction(Auction storage _auction) internal view returns (bool) {
        return (_auction.startedAt > 0);
    }

    
    ///  functions (this one, that computes the duration from the auction
    ///  structure, and the other that does the price computation) so we
    ///  can easily test that the price computation works correctly.
    function _currentPrice(Auction storage _auction)
        internal
        view
        returns (uint256)
    {
        uint256 secondsPassed = 0;

        // A bit of insurance against negative values (or wraparound).
        // Probably not necessary (since Ethereum guarnatees that the
        // now variable doesn't ever go backwards).
        if (now > _auction.startedAt) {
            secondsPassed = now - _auction.startedAt;
        }

        return _computeCurrentPrice(
            _auction.startingPrice,
            _auction.endingPrice,
            _auction.duration,
            secondsPassed
        );
    }

    
    ///  from _currentPrice so we can run extensive unit tests.
    ///  When testing, make this function public and turn on
    ///  `Current price computation` test suite.
    function _computeCurrentPrice(
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _secondsPassed
    )
        internal
        pure
        returns (uint256)
    {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our public functions carefully cap the maximum values for
        //  time (at 64-bits) and currency (at 128-bits). _duration is
        //  also known to be non-zero (see the require() statement in
        //  _addAuction())
        if (_secondsPassed >= _duration) {
            // We've reached the end of the dynamic pricing portion
            // of the auction, just return the end price.
            return _endingPrice;
        } else {
            // Starting price can be higher than ending price (and often is!), so
            // this delta can be negative.
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);

            // This multiplication can't overflow, _secondsPassed will easily fit within
            // 64-bits, and totalPriceChange will easily fit within 128-bits, their product
            // will always fit within 256-bits.
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);

            // currentPriceChange can be negative, but if so, will have a magnitude
            // less that _startingPrice. Thus, this result will always end up positive.
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;

            return uint256(currentPrice);
        }
    }

    
    
    function _computeCut(uint256 _price) internal view returns (uint256) {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our entry functions carefully cap the maximum values for
        //  currency (at 128-bits), and ownerCut <= 10000 (see the require()
        //  statement in the ClockAuction constructor). The result of this
        //  function is always guaranteed to be <= _price.
        return _price * ownerCut / 10000;
    }

}



contract ClockAuction is Ownable, ClockAuctionBase {

    
    ///  Ref: https://github.com/ethereum/EIPs/issues/165
    ///  Ref: https://github.com/ethereum/EIPs/issues/721
    bytes4 public constant  INTERFACE_SIGNATURE_ERC721 = bytes4(0x9a20483d);

    
    ///  and verifies the owner cut is in the valid range.
    
    ///  the Nonfungible Interface.
    
    ///  between 0-10,000.
    function ClockAuction(address _nftAddress, uint256 _cut) public {
        require(_cut <= 10000);
        ownerCut = _cut;

        ERC721 candidateContract = ERC721(_nftAddress);
        require(candidateContract.supportsInterface(INTERFACE_SIGNATURE_ERC721));
        nonFungibleContract = candidateContract;
    }

    
    ///  as well as any Ether sent directly to the contract address.
    ///  Always transfers to the NFT contract, but can be called either by
    ///  the owner or the NFT contract.
    function withdrawBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(
            msg.sender == owner ||
            msg.sender == nftAddress
        );
        // We are using this boolean method to make sure that even if one fails it will still work
        bool res = nftAddress.send(this.balance);
    }

    
    
    
    
    
    ///  price and ending price (in seconds).
    
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external
    {
        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the auction struct.
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(_owns(msg.sender, _tokenId));
        _escrow(msg.sender, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    
    ///  ownership of the NFT if enough Ether is supplied.
    
    function bid(uint256 _tokenId)
        external
        payable
    {
        // _bid will throw if the bid or funds transfer fails
        _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);
    }

    
    ///  Returns the NFT to original owner.
    
    ///  be called while the contract is paused.
    
    function cancelAuction(uint256 _tokenId)
        external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }

    
    
    function getAuction(uint256 _tokenId) external view returns (
        address seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt
    ) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return (
            auction.seller,
            auction.startingPrice,
            auction.endingPrice,
            auction.duration,
            auction.startedAt
        );
    }

    
    
    function getCurrentPrice(uint256 _tokenId)
        external
        view
        returns (uint256)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return _currentPrice(auction);
    }

}



contract SaleClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public isSaleClockAuction = true;

    // Tracks last 5 sale price of artwork sales
    uint256 public artworkSaleCount;
    uint256[5] public lastArtworkSalePrices;
    uint256 internal value;

    // Delegate constructor
    function SaleClockAuction(address _nftAddr, uint256 _cut) public ClockAuction(_nftAddr, _cut) {}

    
    
    
    
    
    
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external
    {
        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the auction struct.
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));
        require(msg.sender == address(nonFungibleContract));

        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    
    /// Otherwise, works the same as default bid method.
    function bid(uint256 _tokenId)
        external
        payable
    {
        // _bid verifies token ID size
        address seller = tokenIdToAuction[_tokenId].seller;
        uint256 price = _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);

        // If not a gen0 auction, exit
        if (seller == address(nonFungibleContract)) {
            // Track gen0 sale prices
            lastArtworkSalePrices[artworkSaleCount % 5] = price;
            value += price;
            artworkSaleCount++;
        }
    }

    function averageArtworkSalePrice() external view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 5; i++) {
            sum += lastArtworkSalePrices[i];
        }
        return sum / 5;
    }

    function getValue() external view returns (uint256) {
        return value;
    }

}


contract ArtworkAccessControl {
    // This facet controls access control for CryptoArtworks. There are four roles managed here:
    //
    //     - The CEO: The CEO can reassign other roles and change the addresses of our dependent smart
    //         contracts. It is also the only role that can unpause the smart contract. It is initially
    //         set to the address that created the smart contract in the ArtworkCore constructor.
    //
    //     - The CFO: The CFO can withdraw funds from ArtworkCore and its auction contracts.
    //
    //     - The COO: The COO can release artworks to auction, and mint promo arts.
    //
    // It should be noted that these roles are distinct without overlap in their access abilities, the
    // abilities listed for each role above are exhaustive. In particular, while the CEO can assign any
    // address to any role, the CEO address itself doesn't have the ability to act in those roles. This
    // restriction is intentional so that we aren't tempted to use the CEO address frequently out of
    // convenience. The less we use an address, the less likely it is that we somehow compromise the
    // account.

    
    event ContractUpgrade(address newContract);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;

    
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }

    
    
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    
    
    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    
    
    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }

    /*** Pausable functionality adapted from OpenZeppelin ***/
    
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    
    modifier whenPaused {
        require(paused);
        _;
    }

    
    ///  derived contracts.
    function unpause() public onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}




contract ArtworkBase is ArtworkAccessControl {
    /*** EVENTS ***/

    
    ///  includes any time a artwork is created through the giveBirth method, but it is also called
    ///  when a new artwork is created.
    event Birth(address owner, uint256 artworkId, string name, string author, uint32 series);

    
    ///  ownership is assigned, including births.
    event Transfer(address from, address to, uint256 tokenId);

    /*** DATA TYPES ***/
    
    ///  of this structure, so great care was taken to ensure that it fits neatly into
    ///  exactly two 256-bit words. Note that the order of the members in this structure
    ///  is important because of the byte-packing rules used by Ethereum.
    ///  Ref: http://solidity.readthedocs.io/en/develop/miscellaneous.html
    struct Artwork {
         // The timestamp from the block when this artwork came into existence.
        uint64 birthTime;
        // The name of the artwork
        string name;
        string author;
        //sometimes artists produce a series of paintings with the same name
        //in order to separate them from each other by introducing a variable series.
        //Series with number 0 means that the picture was without series
        uint32 series;
    }

    // An approximation of currently how many seconds are in between blocks.
    // uint256 public secondsPerBlock = 15;
    /*** STORAGE ***/
    
    ///  of each artwork is actually an index into this array.
    ///  Artwork ID 0 is invalid... ;-)
    Artwork[] internal artworks;
    
    ///  some valid owner address.
    mapping (uint256 => address) public artworkIndexToOwner;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) internal ownershipTokenCount;

    
    ///  transferFrom(). Each Artwork can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public artworkIndexToApproved;


    
    ///  same contract handles both peer-to-peer sales as well as the initial sales which are
    ///  initiated every 15 minutes.
    SaleClockAuction public saleAuction;

    
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // Since the number of artworks is capped to 2^32 we can't overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        artworkIndexToOwner[_tokenId] = _to;
        // When creating new artworks _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            // clear any previously approved ownership exchange
            delete artworkIndexToApproved[_tokenId];
        }
        // Emit the transfer event.
        Transfer(_from, _to, _tokenId);
    }

    
    ///  method doesn't do any checking and should only be called when the
    ///  input data is known to be valid. Will generate both a Birth event
    ///  and a Transfer event.
    
    
         // The timestamp from the block when this artwork came into existence.
    uint64 internal birthTime;
    string internal author;
    // The name of the artwork
    string internal name;
    uint32 internal series;

    function _createArtwork(string _name, string _author, uint32 _series, address _owner ) internal returns (uint) {
        Artwork memory _artwork = Artwork({ birthTime: uint64(now), name: _name, author: _author, series: _series});
        uint256 newArtworkId = artworks.push(_artwork) - 1;

        // It's probably never going to happen, 4 billion artworks is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(newArtworkId == uint256(uint32(newArtworkId)));

        // emit the birth event
        Birth(_owner, newArtworkId, _artwork.name, _artwork.author, _series);

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, newArtworkId);

        return newArtworkId;
    }

}


    // Creates dictionary with unique keys, if the key is already used then its value will be true.
    // It is not possible to create a duplicate.
contract ArtworkUnique {

    //mapping with unique key
    mapping  (bytes32 => bool) internal uniqueArtworks;
    
    //Creates a unique key based on the artwork name, author, and series
    function getUniqueKey(string name, string author, uint32 _version)  internal pure returns(bytes32) {
        string memory version = _uintToString(_version);
        string memory main = _strConcat(name, author, version, "$%)");
        string memory lowercased = _toLower(main);
        return keccak256(lowercased);
    }
    
    //https://gist.github.com/thomasmaclean/276cb6e824e48b7ca4372b194ec05b97
    //transform to lowercase
    function _toLower(string str) internal pure returns (string)  {
		bytes memory bStr = bytes(str);
		bytes memory bLower = new bytes(bStr.length);
		for (uint i = 0; i < bStr.length; i++) {
			// Uppercase character...
			if ((bStr[i] >= 65) && (bStr[i] <= 90)) {
				// So we add 32 to make it lowercase
				bLower[i] = bytes1(int(bStr[i]) + 32);
			} else {
				bLower[i] = bStr[i];
			}
		}
		return string(bLower);
	}
	
    //creates a unique key from all variables
    function _strConcat(string _a, string _b, string _c, string _separator) internal pure returns (string) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_separator);
        bytes memory _bc = bytes(_b);
        bytes memory _bd = bytes(_separator);
        bytes memory _be = bytes(_c);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    //convert uint To String
    function _uintToString(uint v) internal pure returns (string) {
        bytes32 data = _uintToBytes(v);
        return _bytes32ToString(data);
    }

    /// title String Utils - String utility functions
    
    ///https://github.com/pipermerriam/ethereum-string-utils
    function _uintToBytes(uint v) private pure returns (bytes32 ret) {
        if (v == 0) {
            ret = "0";
        } else {
            while (v > 0) {
                ret = bytes32(uint(ret) / (2 ** 8));
                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
                v /= 10;
            }
        }
        return ret;
    }

    function _bytes32ToString(bytes32 x) private pure returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
}




///  See the ArtworkCore contract documentation to understand how the various contract facets are arranged.
contract ArtworkOwnership is ArtworkBase, ArtworkUnique, ERC721 {

    
    string public constant NAME = "CryptoArtworks";
    string public constant SYMBOL = "CA";

    // The contract that will return artwork metadata
    ERC721Metadata public erc721Metadata;

    bytes4 private constant INTERFACE_SIGNATURE_ERC165 =
    bytes4(keccak256("supportsInterface(bytes4)"));

    bytes4 private constant INTERFACE_SIGNATURE_ERC721 =
        bytes4(keccak256("name()")) ^
        bytes4(keccak256("symbol()")) ^
        bytes4(keccak256("totalSupply()")) ^
        bytes4(keccak256("balanceOf(address)")) ^
        bytes4(keccak256("ownerOf(uint256)")) ^
        bytes4(keccak256("approve(address,uint256)")) ^
        bytes4(keccak256("transfer(address,uint256)")) ^
        bytes4(keccak256("transferFrom(address,address,uint256)")) ^
        bytes4(keccak256("tokensOfOwner(address)")) ^
    bytes4(keccak256("tokenMetadata(uint256,string)"));

    
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    
    ///  clear all approvals.
    
    
    function approve(
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // Only an owner can grant transfer approval.
        require(_owns(msg.sender, _tokenId));

        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        Approval(msg.sender, _to, _tokenId);
    }

    
    ///  has previously been granted transfer approval by the owner.
    
    
    ///  including the caller.
    
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any artworks (except very briefly
        // after a artwork is created and before it goes on auction).
        require(_to != address(this));
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }

    
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or
    ///  CryptoArtworks specifically) or your Artwork may be lost forever. Seriously.
    
    
    
    function transfer(address _to, uint256 _tokenId) external whenNotPaused {

        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));

        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any Artworks (except very briefly
        // after a  artwork is created and before it goes on auction).
        require(_to != address(this));

        // Disallow transfers to the auction contracts to prevent accidental
        // misuse. Auction contracts should only take ownership of artworks
        // through the allow + transferFrom flow.
        require(_to != address(saleAuction));

        // You can only send your own artwork.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);

    }

    
    
    
    ///  expensive (it walks the entire Artwork array looking for arts belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalArts = totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all arts have IDs starting at 1 and increasing
            // sequentially up to the totalArt count.
            uint256 artworkId;

            for (artworkId = 1; artworkId <= totalArts; artworkId++) {
                if (artworkIndexToOwner[artworkId] == _owner) {
                    result[resultIndex] = artworkId;
                    resultIndex++;
                }
            }

            return result;
        }
    }

    
    ///  Returns true for any standardized interfaces implemented by this contract. We implement
    ///  ERC-165 (obviously!) and ERC-721.
    function supportsInterface(bytes4 _interfaceID) external view returns (bool) {
        // DEBUG ONLY
        //require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9a20483d));

        return ((_interfaceID == INTERFACE_SIGNATURE_ERC165) || (_interfaceID == INTERFACE_SIGNATURE_ERC721));
    }

    
    ///  ERC-721 (https://github.com/ethereum/EIPs/issues/721)
    
    function tokenMetadata(uint256 _tokenId, string _preferredTransport) external view returns (string infoUrl) {
        require(erc721Metadata != address(0));
        bytes32[4] memory buffer;
        uint256 count;
        (buffer, count) = erc721Metadata.getMetadata(_tokenId, _preferredTransport);

        return _toString(buffer, count);
    }

    
    
    function ownerOf(uint256 _tokenId) external view returns (address owner) {
        owner = artworkIndexToOwner[_tokenId];

        require(owner != address(0));
    }

    
    ///  CEO only.
    function setMetadataAddress(address _contractAddress) public onlyCEO {
        erc721Metadata = ERC721Metadata(_contractAddress);
    }

    
    
    function totalSupply() public view returns (uint) {
        return artworks.length - 1;
    }

    
    
    
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    // Internal utility functions: These functions all assume that their input arguments
    // are valid. We leave it to public methods to sanitize their inputs and follow
    // the required logic.
    
    
    
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return artworkIndexToOwner[_tokenId] == _claimant;
    }

    
    
    
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return artworkIndexToApproved[_tokenId] == _claimant;
    }

    
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting Artworks on auction, and
    ///  there is no value in spamming the log with Approval events in that case.
    function _approve(uint256 _tokenId, address _approved) internal {
        artworkIndexToApproved[_tokenId] = _approved;
    }

    
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _memcpy(uint _dest, uint _src, uint _len) private view {
        // Copy word-length chunks while possible
        for (; _len >= 32; _len -= 32) {
            assembly {
                mstore(_dest, mload(_src))
            }
            _dest += 32;
            _src += 32;
        }

        // Copy remaining bytes
        uint256 mask = 256 ** (32 - _len) - 1;
        assembly {
            let srcpart := and(mload(_src), not(mask))
            let destpart := and(mload(_dest), mask)
            mstore(_dest, or(destpart, srcpart))
        }
    }

    
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _toString(bytes32[4] _rawBytes, uint256 _stringLength) private view returns (string) {
        var outputString = new string(_stringLength);
        uint256 outputPtr;
        uint256 bytesPtr;

        assembly {
            outputPtr := add(outputString, 32)
            bytesPtr := _rawBytes
        }

        _memcpy(outputPtr, bytesPtr, _stringLength);

        return outputString;
    }
}



///  This wrapper of ReverseAuction exists only so that users can create
///  auctions with only one transaction.
contract ArtworkAuction is ArtworkOwnership {

    // @notice The auction contract variables are defined in ArtworkBase to allow
    //  us to refer to _createArtworkthem in ArtworkOwnership to prevent accidental transfers.
    // `saleAuction` refers to the auction for created artworks and p2p sale of artworks.


    
    
    function setSaleAuctionAddress(address _address) external onlyCEO {
        SaleClockAuction candidateContract = SaleClockAuction(_address);

        // NOTE: verify that a contract is what we expect -
        //https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSaleClockAuction());

        // Set the new contract address
        saleAuction = candidateContract;
    }

    
    ///  Does some ownership trickery to create auctions in one tx.
    function createSaleAuction(
        uint256 _artworkId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {
        // Auction contract checks input sizes
        // If artwork is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _artworkId));
        _approve(_artworkId, saleAuction);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the artwork.
        saleAuction.createAuction(
            _artworkId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }

    
    /// to the ArtworkCore contract. We use two-step withdrawal to
    /// prevent two transfer calls in the auction bid function.
    function withdrawAuctionBalances() external onlyCLevel {
        saleAuction.withdrawBalance();
    }
}



contract ArtworkMinting is ArtworkAuction {

    // Limits the number of arts the contract owner can ever create.
    uint256 public constant PROMO_CREATION_LIMIT = 5000;
    uint256 public constant CREATION_LIMIT = 450000;

    // Constants for auctions.
    uint256 public constant ARTWORK_STARTING_PRICE = 10 finney;
    uint256 public constant ARTWORK_AUCTION_DURATION = 1 days;

    // Counts the number of arts the contract owner has created.
    uint256 public promoCreatedCount;
    uint256 public artsCreatedCount;

    
    
    function createPromoArtwork(string _name, string _author, uint32 _series, address _owner) external onlyCOO {
        bytes32 uniqueKey = getUniqueKey(_name, _author, _series);
        (require(!uniqueArtworks[uniqueKey]));
        if (_series != 0) {
            bytes32 uniqueKeyForZero = getUniqueKey(_name, _author, 0);
            (require(!uniqueArtworks[uniqueKeyForZero]));
        }
        address artworkOwner = _owner;
        if (artworkOwner == address(0)) {
            artworkOwner = cooAddress;
        }
        require(promoCreatedCount < PROMO_CREATION_LIMIT);

        promoCreatedCount++;
        _createArtwork(_name, _author, _series, artworkOwner);
        uniqueArtworks[uniqueKey] = true;
    }

    
    ///  creates an auction for it.
    function createArtworkAuction(string _name, string _author, uint32 _series) external onlyCOO {
        bytes32 uniqueKey = getUniqueKey(_name, _author, _series);
        (require(!uniqueArtworks[uniqueKey]));
        require(artsCreatedCount < CREATION_LIMIT);
        if (_series != 0) {
            bytes32 uniqueKeyForZero = getUniqueKey(_name, _author, 0);
            (require(!uniqueArtworks[uniqueKeyForZero]));
        }
        uint256 artworkId = _createArtwork(_name, _author, _series, address(this));
        _approve(artworkId, saleAuction);
        uint256 price = _computeNextArtworkPrice();
        saleAuction.createAuction(
            artworkId,
            price,
            0,
            ARTWORK_AUCTION_DURATION,
            address(this)
        );
        artsCreatedCount++;
        uniqueArtworks[uniqueKey] = true;
    }

    
    ///  the average of the past 5 prices + 50%.
    function _computeNextArtworkPrice() internal view returns (uint256) {
        uint256 avePrice = saleAuction.averageArtworkSalePrice();

        // Sanity check to ensure we don't overflow arithmetic
        require(avePrice == uint256(uint128(avePrice)));

        uint256 nextPrice = avePrice + (avePrice / 2);

        // We never auction for less than starting price
        if (nextPrice < ARTWORK_STARTING_PRICE) {
            nextPrice = ARTWORK_STARTING_PRICE;
        }

        return nextPrice;
    }
}


/**
 * The contractName contract does this and that...
 */
contract ArtworkQuestions is ArtworkMinting {
    string private constant QUESTION  = "What is the value? Nothing is ";
    string public constant MAIN_QUESTION = "What is a masterpiece? ";
    
    function getQuestion() public view returns (string) {
        uint256 value = saleAuction.getValue();
        string memory auctionValue = _uintToString(value);
        return _strConcat(QUESTION, auctionValue, "", "");
    }
}





contract ArtworkCore is ArtworkQuestions {

    // This is the main CryptoArtworks contract. In order to keep our code seperated into logical sections,
    // we've broken it up in two ways. First, we have several seperately-instantiated sibling contracts
    // that handle auctions and our super-top-secret genetic combination algorithm. The auctions are
    // seperate since their logic is somewhat complex and there's always a risk of subtle bugs. By keeping
    // them in their own contracts, we can upgrade them without disrupting the main contract that tracks
    // artwork ownership. The genetic combination algorithm is kept seperate so we can open-source all of
    // the rest of our code without making it _too_ easy for folks to figure out how the genetics work.
    // Don't worry, I'm sure someone will reverse engineer it soon enough!
    //
    // Secondly, we break the core contract into multiple files using inheritence, one for each major
    // facet of functionality of CK. This allows us to keep related code bundled together while still
    // avoiding a single giant file with everything in it. The breakdown is as follows:
    //
    //      - ArtworkBase: This is where we define the most fundamental code shared throughout the core
    //             functionality. This includes our main data storage, constants and data types, plus
    //             internal functions for managing these items.
    //
    //      - ArtworkAccessControl: This contract manages the various addresses and constraints for operations
    //             that can be executed only by specific roles. Namely CEO, CFO and COO.
    //
    //      - ArtworkOwnership: This provides the methods required for basic non-fungible token
    //             transactions, following the draft ERC-721 spec (https://github.com/ethereum/EIPs/issues/721).
    //
    //      - ArtworkAuctions: Here we have the public methods for auctioning or bidding on arts.
    //             The actual auction functionality is handled in contract
    //             for sales, while auction creation and bidding is mostly mediated
    //             through this facet of the core contract.
    //
    //      - ArtworkMinting: This final facet contains the functionality we use for creating new arts.
    //             We can make up to 5000 "promo" arts that can be given away (especially important when
    //             the community is new), and all others can only be created and then immediately put up
    //             for auction via an algorithmically determined starting price. Regardless of how they
    //             are created, there is a hard limit of 450k arts.

    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    
    function ArtworkCore() public {
        // Starts paused.
        paused = true;

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;

        // start with the art
        _createArtwork("none", "none", 0, address(0));
    }

    
    
    ///  two auction contracts. (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(
            msg.sender == address(saleAuction)
        );
    }

    
    ///  breaking bug. This method does nothing but keep track of the new contract and
    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    
    function setNewAddress(address _v2Address) external onlyCEO whenPaused {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        ContractUpgrade(_v2Address);
    }

    // @dev Allows the CFO to capture the balance available to the contract.
    function withdrawBalance() external onlyCFO {
        uint256 balance = this.balance;
        cfoAddress.send(balance);
    }

    
    
    function getArtwork(uint256 _id)
        external
        view
        returns (
        uint256 birthTime,
        string name,
        string author,
        uint32 series
    ) {
        Artwork storage art = artworks[_id];
        birthTime = uint256(art.birthTime);
        name = string(art.name);
        author = string(art.author);
        series = uint32(art.series);
    }

    
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    
    ///  without using an expensive CALL.
    function unpause() public onlyCEO whenPaused {
        require(saleAuction != address(0));
        require(newContractAddress == address(0));
        // Actually unpause the contract.
        super.unpause();
    }

}