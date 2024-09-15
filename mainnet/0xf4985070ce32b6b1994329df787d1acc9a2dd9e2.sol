
pragma solidity ^0.4.19;

// File: contracts/erc/erc721/IERC721Base.sol



///  Note: the ERC-165 identifier for this interface is 0x6466353c
interface IERC721Base /* is IERC165  */ {
  
  ///  This event emits when NFTs are created (`from` == 0) and destroyed
  ///  (`to` == 0). Exception: during contract creation, any number of NFTs
  ///  may be created and assigned without emitting Transfer. At the time of
  ///  any transfer, the approved address for that NFT (if any) is reset to none.
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

  
  ///  reaffirmed. The zero address indicates there is no approved address.
  ///  When a Transfer event emits, this also indicates that the approved
  ///  address for that NFT (if any) is reset to none.
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

  
  ///  The operator can manage all NFTs of the owner.
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  
  
  ///  function throws for queries about the zero address.
  
  
  function balanceOf(address _owner) external view returns (uint256);

  
  
  
  ///  about them do throw.
  
  function ownerOf(uint256 _tokenId) external view returns (address);

  
  
  ///  operator, or the approved address for this NFT. Throws if `_from` is
  ///  not the current owner. Throws if `_to` is the zero address. Throws if
  ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
  ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
  ///  `onERC721Received` on `_to` and throws if the return value is not
  ///  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`.
  
  
  
  
  // solium-disable-next-line arg-overflow
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) external payable;

  
  
  ///  except this function just sets data to []
  
  
  
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

  
  ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
  ///  THEY MAY BE PERMANENTLY LOST
  
  ///  operator, or the approved address for this NFT. Throws if `_from` is
  ///  not the current owner. Throws if `_to` is the zero address. Throws if
  ///  `_tokenId` is not a valid NFT.
  
  
  
  function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

  
  
  
  ///  operator of the current owner.
  
  
  function approve(address _approved, uint256 _tokenId) external payable;

  
  ///  all your asset.
  
  
  
  function setApprovalForAll(address _operator, bool _approved) external;

  
  
  
  
  function getApproved(uint256 _tokenId) external view returns (address);

  
  
  
  
  function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

// File: zeppelin/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: zeppelin/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

// File: zeppelin/contracts/ownership/HasNoEther.sol

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="f88a9d959b97b8ca">[email&#160;protected]</span>π.com>
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up
 * in the contract, it will allow the owner to reclaim this ether.
 * @notice Ether can still be send to this contract by:
 * calling functions labeled `payable`
 * `selfdestruct(contract_address)`
 * mining directly to the contract address
*/
contract HasNoEther is Ownable {

  /**
  * @dev Constructor that rejects incoming Ether
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
  * we could use assembly to access msg.value.
  */
  function HasNoEther() payable {
    require(msg.value == 0);
  }

  /**
   * @dev Disallows direct send by settings a default function without the `payable` flag.
   */
  function() external {
  }

  /**
   * @dev Transfer all Ether held by the contract to the owner.
   */
  function reclaimEther() external onlyOwner {
    assert(owner.send(this.balance));
  }
}

// File: contracts/marketplace/AxieClockAuction.sol


contract AxieClockAuction is HasNoEther, Pausable {

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

  // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
  // Values 0-10,000 map to 0%-100%
  uint256 public ownerCut;

  // Map from token ID to their corresponding auction.
  mapping (address => mapping (uint256 => Auction)) public auctions;

  event AuctionCreated(
    address indexed _nftAddress,
    uint256 indexed _tokenId,
    uint256 _startingPrice,
    uint256 _endingPrice,
    uint256 _duration,
    address _seller
  );

  event AuctionSuccessful(
    address indexed _nftAddress,
    uint256 indexed _tokenId,
    uint256 _totalPrice,
    address _winner
  );

  event AuctionCancelled(
    address indexed _nftAddress,
    uint256 indexed _tokenId
  );

  
  ///  and verifies the owner cut is in the valid range.
  
  ///  between 0-10,000.
  function AxieClockAuction(uint256 _ownerCut) public {
    require(_ownerCut <= 10000);
    ownerCut = _ownerCut;
  }

  
  function () external {}

  // Modifiers to check that inputs can be safely stored with a certain
  // number of bits. We use constants and multiple modifiers to save gas.
  modifier canBeStoredWith64Bits(uint256 _value) {
    require(_value <= 18446744073709551615);
    _;
  }

  modifier canBeStoredWith128Bits(uint256 _value) {
    require(_value < 340282366920938463463374607431768211455);
    _;
  }

  
  
  
  function getAuction(
    address _nftAddress,
    uint256 _tokenId
  )
    external
    view
    returns (
      address seller,
      uint256 startingPrice,
      uint256 endingPrice,
      uint256 duration,
      uint256 startedAt
    )
  {
    Auction storage _auction = auctions[_nftAddress][_tokenId];
    require(_isOnAuction(_auction));
    return (
      _auction.seller,
      _auction.startingPrice,
      _auction.endingPrice,
      _auction.duration,
      _auction.startedAt
    );
  }

  
  
  
  function getCurrentPrice(
    address _nftAddress,
    uint256 _tokenId
  )
    external
    view
    returns (uint256)
  {
    Auction storage _auction = auctions[_nftAddress][_tokenId];
    require(_isOnAuction(_auction));
    return _getCurrentPrice(_auction);
  }

  
  
  ///  the Nonfungible Interface.
  
  
  
  
  ///  price and ending price (in seconds).
  function createAuction(
    address _nftAddress,
    uint256 _tokenId,
    uint256 _startingPrice,
    uint256 _endingPrice,
    uint256 _duration
  )
    external
    whenNotPaused
    canBeStoredWith128Bits(_startingPrice)
    canBeStoredWith128Bits(_endingPrice)
    canBeStoredWith64Bits(_duration)
  {
    address _seller = msg.sender;
    require(_owns(_nftAddress, _seller, _tokenId));
    _escrow(_nftAddress, _seller, _tokenId);
    Auction memory _auction = Auction(
      _seller,
      uint128(_startingPrice),
      uint128(_endingPrice),
      uint64(_duration),
      uint64(now)
    );
    _addAuction(_nftAddress, _tokenId, _auction, _seller);
  }

  
  ///  ownership of the NFT if enough Ether is supplied.
  
  ///  the Nonfungible Interface.
  
  function bid(
    address _nftAddress,
    uint256 _tokenId
  )
    external
    payable
    whenNotPaused
  {
    // _bid will throw if the bid or funds transfer fails
    _bid(_nftAddress, _tokenId, msg.value);
    _transfer(_nftAddress, msg.sender, _tokenId);
  }

  
  ///  Returns the NFT to original owner.
  
  ///  be called while the contract is paused.
  
  
  function cancelAuction(address _nftAddress, uint256 _tokenId) external {
    Auction storage _auction = auctions[_nftAddress][_tokenId];
    require(_isOnAuction(_auction));
    require(msg.sender == _auction.seller);
    _cancelAuction(_nftAddress, _tokenId, _auction.seller);
  }

  
  ///  Only the owner may do this, and NFTs are returned to
  ///  the seller. This should only be used in emergencies.
  
  
  function cancelAuctionWhenPaused(
    address _nftAddress,
    uint256 _tokenId
  )
    external
    whenPaused
    onlyOwner
  {
    Auction storage _auction = auctions[_nftAddress][_tokenId];
    require(_isOnAuction(_auction));
    _cancelAuction(_nftAddress, _tokenId, _auction.seller);
  }

  
  
  function _isOnAuction(Auction storage _auction) internal view returns (bool) {
    return (_auction.startedAt > 0);
  }

  
  
  function _getNftContract(address _nftAddress) internal pure returns (IERC721Base) {
    IERC721Base candidateContract = IERC721Base(_nftAddress);
    // require(candidateContract.implementsERC721());
    return candidateContract;
  }

  
  ///  functions (this one, that computes the duration from the auction
  ///  structure, and the other that does the price computation) so we
  ///  can easily test that the price computation works correctly.
  function _getCurrentPrice(
    Auction storage _auction
  )
    internal
    view
    returns (uint256)
  {
    uint256 _secondsPassed = 0;

    // A bit of insurance against negative values (or wraparound).
    // Probably not necessary (since Ethereum guarantees that the
    // now variable doesn't ever go backwards).
    if (now > _auction.startedAt) {
      _secondsPassed = now - _auction.startedAt;
    }

    return _computeCurrentPrice(
      _auction.startingPrice,
      _auction.endingPrice,
      _auction.duration,
      _secondsPassed
    );
  }

  
  ///  from _currentPrice so we can run extensive unit tests.
  ///  When testing, make this function external and turn on
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
    //  all of our external functions carefully cap the maximum values for
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
      int256 _totalPriceChange = int256(_endingPrice) - int256(_startingPrice);

      // This multiplication can't overflow, _secondsPassed will easily fit within
      // 64-bits, and _totalPriceChange will easily fit within 128-bits, their product
      // will always fit within 256-bits.
      int256 _currentPriceChange = _totalPriceChange * int256(_secondsPassed) / int256(_duration);

      // _currentPriceChange can be negative, but if so, will have a magnitude
      // less that _startingPrice. Thus, this result will always end up positive.
      int256 _currentPrice = int256(_startingPrice) + _currentPriceChange;

      return uint256(_currentPrice);
    }
  }

  
  
  
  
  function _owns(address _nftAddress, address _claimant, uint256 _tokenId) private view returns (bool) {
    IERC721Base _nftContract = _getNftContract(_nftAddress);
    return (_nftContract.ownerOf(_tokenId) == _claimant);
  }

  
  ///  AuctionCreated event.
  
  
  function _addAuction(
    address _nftAddress,
    uint256 _tokenId,
    Auction _auction,
    address _seller
  ) internal {
    // Require that all auctions have a duration of
    // at least one minute. (Keeps our math from getting hairy!)
    require(_auction.duration >= 1 minutes);

    auctions[_nftAddress][_tokenId] = _auction;

    AuctionCreated(
      _nftAddress,
      _tokenId,
      uint256(_auction.startingPrice),
      uint256(_auction.endingPrice),
      uint256(_auction.duration),
      _seller
    );
  }

  
  
  function _removeAuction(address _nftAddress, uint256 _tokenId) internal {
    delete auctions[_nftAddress][_tokenId];
  }

  
  function _cancelAuction(address _nftAddress, uint256 _tokenId, address _seller) internal {
    _removeAuction(_nftAddress, _tokenId);
    _transfer(_nftAddress, _seller, _tokenId);
    AuctionCancelled(_nftAddress, _tokenId);
  }

  
  /// Throws if the escrow fails.
  
  
  
  function _escrow(address _nftAddress, address _owner, uint256 _tokenId) private {
    IERC721Base _nftContract = _getNftContract(_nftAddress);

    // It will throw if transfer fails
    _nftContract.transferFrom(_owner, this, _tokenId);
  }

  
  /// Returns true if the transfer succeeds.
  
  
  
  function _transfer(address _nftAddress, address _receiver, uint256 _tokenId) internal {
    IERC721Base _nftContract = _getNftContract(_nftAddress);

    // It will throw if transfer fails
    _nftContract.transferFrom(this, _receiver, _tokenId);
  }

  
  
  function _computeCut(uint256 _price) internal view returns (uint256) {
    // NOTE: We don't use SafeMath (or similar) in this function because
    //  all of our entry functions carefully cap the maximum values for
    //  currency (at 128-bits), and ownerCut <= 10000 (see the require()
    //  statement in the ClockAuction constructor). The result of this
    //  function is always guaranteed to be <= _price.
    return _price * ownerCut / 10000;
  }

  
  /// Does NOT transfer ownership of token.
  function _bid(
    address _nftAddress,
    uint256 _tokenId,
    uint256 _bidAmount
  )
    internal
    returns (uint256)
  {
    // Get a reference to the auction struct
    Auction storage _auction = auctions[_nftAddress][_tokenId];

    // Explicitly check that this auction is currently live.
    // (Because of how Ethereum mappings work, we can't just count
    // on the lookup above failing. An invalid _tokenId will just
    // return an auction object that is all zeros.)
    require(_isOnAuction(_auction));

    // Check that the incoming bid is higher than the current
    // price
    uint256 _price = _getCurrentPrice(_auction);
    require(_bidAmount >= _price);

    // Grab a reference to the seller before the auction struct
    // gets deleted.
    address _seller = _auction.seller;

    // The bid is good! Remove the auction before sending the fees
    // to the sender so we can't have a reentrancy attack.
    _removeAuction(_nftAddress, _tokenId);

    // Transfer proceeds to seller (if there are any!)
    if (_price > 0) {
      //  Calculate the auctioneer's cut.
      // (NOTE: _computeCut() is guaranteed to return a
      //  value <= price, so this subtraction can't go negative.)
      uint256 _auctioneerCut = _computeCut(_price);
      uint256 _sellerProceeds = _price - _auctioneerCut;

      // NOTE: Doing a transfer() in the middle of a complex
      // method like this is generally discouraged because of
      // reentrancy attacks and DoS attacks if the seller is
      // a contract with an invalid fallback function. We explicitly
      // guard against reentrancy attacks by removing the auction
      // before calling transfer(), and the only thing the seller
      // can DoS is the sale of their own asset! (And if it's an
      // accident, they can call cancelAuction(). )
      _seller.transfer(_sellerProceeds);
    }

    if (_bidAmount > _price) {
      // Calculate any excess funds included with the bid. If the excess
      // is anything worth worrying about, transfer it back to bidder.
      // NOTE: We checked above that the bid amount is greater than or
      // equal to the price so this cannot underflow.
      uint256 _bidExcess = _bidAmount - _price;

      // Return the funds. Similar to the previous transfer, this is
      // not susceptible to a re-entry attack because the auction is
      // removed before any transfers occur.
      msg.sender.transfer(_bidExcess);
    }

    // Tell the world!
    AuctionSuccessful(_nftAddress, _tokenId, _price, msg.sender);

    return _price;
  }
}