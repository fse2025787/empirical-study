
pragma solidity ^0.4.18;

// File: contracts-origin/AetherAccessControl.sol



contract AetherAccessControl {
    // This facet controls access control for Laputa. There are four roles managed here:
    //
    //     - The CEO: The CEO can reassign other roles and change the addresses of our dependent smart
    //         contracts. It is also the only role that can unpause the smart contract. It is initially
    //         set to the address that created the smart contract in the AetherCore constructor.
    //
    //     - The CFO: The CFO can withdraw funds from AetherCore and its auction contracts.
    //
    //     - The COO: The COO can release properties to auction.
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

    
    
    function setCEO(address _newCEO) public onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    
    
    function setCFO(address _newCFO) public onlyCEO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    
    
    function setCOO(address _newCOO) public onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }

    function withdrawBalance() external onlyCFO {
        cfoAddress.transfer(this.balance);
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

    
    ///  a bug or exploit is detected and we need to limit damage.
    function pause() public onlyCLevel whenNotPaused {
        paused = true;
    }

    
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    function unpause() public onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}

// File: contracts-origin/AetherBase.sol




contract AetherBase is AetherAccessControl {
    /*** EVENTS ***/

    
    event Construct (
      address indexed owner,
      uint256 propertyId,
      PropertyClass class,
      uint8 x,
      uint8 y,
      uint8 z,
      uint8 dx,
      uint8 dz,
      string data
    );

    
    ///  time a property ownership is assigned.
    event Transfer(
      address indexed from,
      address indexed to,
      uint256 indexed tokenId
    );

    /*** DATA ***/

    enum PropertyClass { DISTRICT, BUILDING, UNIT }

    
    ///  by a variant of this structure.
    struct Property {
        uint32 parent;
        PropertyClass class;
        uint8 x;
        uint8 y;
        uint8 z;
        uint8 dx;
        uint8 dz;
    }

    /*** STORAGE ***/

    
    bool[100][100][100] public world;

    
    ///  of each property is actually an index into this array.
    Property[] properties;

    
    uint256[] districts;

    
    uint256 public progress;

    
    uint256 public unitCreationFee = 0.05 ether;

    
    bool public updateEnabled = true;

    
    ///  some valid owner address, even gen0 properties are created with a non-zero owner.
    mapping (uint256 => address) public propertyIndexToOwner;

    
    mapping (uint256 => string) public propertyIndexToData;

    
    ///  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) ownershipTokenCount;

    
    mapping (uint256 => uint256) public districtToBuildingsCount;
    mapping (uint256 => uint256[]) public districtToBuildings;
    mapping (uint256 => uint256) public buildingToUnitCount;
    mapping (uint256 => uint256[]) public buildingToUnits;

    
    mapping (uint256 => bool) public buildingIsPublic;

    
    ///  transferFrom(). Each Property can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public propertyIndexToApproved;

    
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
      // since the number of properties is capped to 2^32
      // there is no way to overflow this
      ownershipTokenCount[_to]++;
      // transfer ownership
      propertyIndexToOwner[_tokenId] = _to;
      // When creating new properties _from is 0x0, but we can't account that address.
      if (_from != address(0)) {
          ownershipTokenCount[_from]--;
          // clear any previously approved ownership exchange
          delete propertyIndexToApproved[_tokenId];
      }
      // Emit the transfer event.
      Transfer(_from, _to, _tokenId);
    }

    function _createUnit(
      uint256 _parent,
      uint256 _x,
      uint256 _y,
      uint256 _z,
      address _owner
    )
        internal
        returns (uint)
    {
      require(_x == uint256(uint8(_x)));
      require(_y == uint256(uint8(_y)));
      require(_z == uint256(uint8(_z)));
      require(!world[_x][_y][_z]);
      world[_x][_y][_z] = true;
      return _createProperty(
        _parent,
        PropertyClass.UNIT,
        _x,
        _y,
        _z,
        0,
        0,
        _owner
      );
    }

    function _createBuilding(
      uint256 _parent,
      uint256 _x,
      uint256 _y,
      uint256 _z,
      uint256 _dx,
      uint256 _dz,
      address _owner,
      bool _public
    )
        internal
        returns (uint)
    {
      require(_x == uint256(uint8(_x)));
      require(_y == uint256(uint8(_y)));
      require(_z == uint256(uint8(_z)));
      require(_dx == uint256(uint8(_dx)));
      require(_dz == uint256(uint8(_dz)));

      // Looping over world space.
      for(uint256 i = 0; i < _dx; i++) {
          for(uint256 j = 0; j <_dz; j++) {
              if (world[_x + i][0][_z + j]) {
                  revert();
              }
              world[_x + i][0][_z + j] = true;
          }
      }

      uint propertyId = _createProperty(
        _parent,
        PropertyClass.BUILDING,
        _x,
        _y,
        _z,
        _dx,
        _dz,
        _owner
      );

      districtToBuildingsCount[_parent]++;
      districtToBuildings[_parent].push(propertyId);
      buildingIsPublic[propertyId] = _public;
      return propertyId;
    }

    function _createDistrict(
      uint256 _x,
      uint256 _z,
      uint256 _dx,
      uint256 _dz
    )
        internal
        returns (uint)
    {
      require(_x == uint256(uint8(_x)));
      require(_z == uint256(uint8(_z)));
      require(_dx == uint256(uint8(_dx)));
      require(_dz == uint256(uint8(_dz)));

      uint propertyId = _createProperty(
        districts.length,
        PropertyClass.DISTRICT,
        _x,
        0,
        _z,
        _dx,
        _dz,
        cooAddress
      );

      districts.push(propertyId);
      return propertyId;

    }


    
    ///  method doesn't do any checking and should only be called when the
    ///  input data is known to be valid. Will generate both a Construct event
    ///  and a Transfer event.
    function _createProperty(
        uint256 _parent,
        PropertyClass _class,
        uint256 _x,
        uint256 _y,
        uint256 _z,
        uint256 _dx,
        uint256 _dz,
        address _owner
    )
        internal
        returns (uint)
    {
        require(_x == uint256(uint8(_x)));
        require(_y == uint256(uint8(_y)));
        require(_z == uint256(uint8(_z)));
        require(_dx == uint256(uint8(_dx)));
        require(_dz == uint256(uint8(_dz)));
        require(_parent == uint256(uint32(_parent)));
        require(uint256(_class) <= 3);

        Property memory _property = Property({
            parent: uint32(_parent),
            class: _class,
            x: uint8(_x),
            y: uint8(_y),
            z: uint8(_z),
            dx: uint8(_dx),
            dz: uint8(_dz)
        });
        uint256 _tokenId = properties.push(_property) - 1;

        // It's never going to happen, 4 billion properties is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(_tokenId <= 4294967295);

        Construct(
            _owner,
            _tokenId,
            _property.class,
            _property.x,
            _property.y,
            _property.z,
            _property.dx,
            _property.dz,
            ""
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, _tokenId);

        return _tokenId;
    }

    
    function _computeHeight(
      uint256 _x,
      uint256 _z,
      uint256 _height
    ) internal view returns (uint256) {
        uint256 x = _x < 50 ? 50 - _x : _x - 50;
        uint256 z = _z < 50 ? 50 - _z : _z - 50;
        uint256 distance = x > z ? x : z;
        if (distance > progress) {
          return 1;
        }
        uint256 scale = 100 - (distance * 100) / progress ;
        uint256 height = 2 * progress * _height * scale / 10000;
        return height > 0 ? height : 1;
    }

    
    function canCreateUnit(uint256 _buildingId)
        public
        view
        returns(bool)
    {
      Property storage _property = properties[_buildingId];
      if (_property.class == PropertyClass.BUILDING &&
            (buildingIsPublic[_buildingId] ||
              propertyIndexToOwner[_buildingId] == msg.sender)
      ) {
        uint256 totalVolume = _property.dx * _property.dz *
          (_computeHeight(_property.x, _property.z, _property.y) - 1);
        uint256 totalUnits = buildingToUnitCount[_buildingId];
        return totalUnits < totalVolume;
      }
      return false;
    }

    
    //   canCreateUnit() is required before calling this method.
    function _createUnitHelper(uint256 _buildingId, address _owner)
        internal
        returns(uint256)
    {
        // Grab a reference to the property in storage.
        Property storage _property = properties[_buildingId];
        uint256 totalArea = _property.dx * _property.dz;
        uint256 index = buildingToUnitCount[_buildingId];

        // Calculate next location.
        uint256 y = index / totalArea + 1;
        uint256 intermediate = index % totalArea;
        uint256 z = intermediate / _property.dx;
        uint256 x = intermediate % _property.dx;

        uint256 unitId = _createUnit(
          _buildingId,
          x + _property.x,
          y,
          z + _property.z,
          _owner
        );

        buildingToUnitCount[_buildingId]++;
        buildingToUnits[_buildingId].push(unitId);

        // Return the new unit's ID.
        return unitId;
    }

    
    function updateBuildingPrivacy(uint _tokenId, bool _public) public {
        require(propertyIndexToOwner[_tokenId] == msg.sender);
        buildingIsPublic[_tokenId] = _public;
    }

    
    function updatePropertyData(uint _tokenId, string _data) public {
        require(updateEnabled);
        address _owner = propertyIndexToOwner[_tokenId];
        require(msg.sender == _owner);
        propertyIndexToData[_tokenId] = _data;
        Property memory _property = properties[_tokenId];
        Construct(
            _owner,
            _tokenId,
            _property.class,
            _property.x,
            _property.y,
            _property.z,
            _property.dx,
            _property.dz,
            _data
        );
    }
}

// File: contracts-origin/ERC721Draft.sol



contract ERC721 {
    function implementsERC721() public pure returns (bool);
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) public view returns (address owner);
    function approve(address _to, uint256 _tokenId) public;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function transfer(address _to, uint256 _tokenId) public;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId) public view returns (string infoUrl);
}

// File: contracts-origin/AetherOwnership.sol



///  See the PropertyCore contract documentation to understand how the various contract facets are arranged.
contract AetherOwnership is AetherBase, ERC721 {

    
    string public name = "Aether";
    string public symbol = "AETH";

    function implementsERC721() public pure returns (bool)
    {
        return true;
    }

    // Internal utility functions: These functions all assume that their input arguments
    // are valid. We leave it to public methods to sanitize their inputs and follow
    // the required logic.

    
    
    
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return propertyIndexToOwner[_tokenId] == _claimant;
    }

    
    
    
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return propertyIndexToApproved[_tokenId] == _claimant;
    }

    
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting Properties on auction, and
    ///  there is no value in spamming the log with Approval events in that case.
    function _approve(uint256 _tokenId, address _approved) internal {
        propertyIndexToApproved[_tokenId] = _approved;
    }

    
    ///  Used to rescue lost properties. (There is no "proper" flow where this contract
    ///  should be the owner of any Property. This function exists for us to reassign
    ///  the ownership of Properties that users may have accidentally sent to our address.)
    
    
    function rescueLostProperty(uint256 _propertyId, address _recipient) public onlyCOO whenNotPaused {
        require(_owns(this, _propertyId));
        _transfer(this, _recipient, _propertyId);
    }

    
    
    
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or
    ///  Laputa specifically) or your Property may be lost forever. Seriously.
    
    
    
    function transfer(
        address _to,
        uint256 _tokenId
    )
        public
        whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // You can only send your own property.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }

    
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    
    ///  clear all approvals.
    
    
    function approve(
        address _to,
        uint256 _tokenId
    )
        public
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
        public
        whenNotPaused
    {
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }

    
    
    function totalSupply() public view returns (uint) {
        return properties.length;
    }

    function totalDistrictSupply() public view returns(uint count) {
        return districts.length;
    }

    
    
    function ownerOf(uint256 _tokenId)
        public
        view
        returns (address owner)
    {
        owner = propertyIndexToOwner[_tokenId];

        require(owner != address(0));
    }


    
    
    
    ///  expensive (it walks the entire Kitty array looking for cats belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalProperties = totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all properties have IDs starting at 1 and increasing
            // sequentially up to the totalProperties count.
            uint256 tokenId;

            for (tokenId = 1; tokenId <= totalProperties; tokenId++) {
                if (propertyIndexToOwner[tokenId] == _owner) {
                    result[resultIndex] = tokenId;
                    resultIndex++;
                }
            }

            return result;
        }
    }
}

// File: contracts-origin/Auction/ClockAuctionBase.sol



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
    mapping (uint256 => Auction) tokenIdToAuction;

    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);
    event AuctionCancelled(uint256 tokenId);

    
    function() external {}

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
            uint256(_auction.duration)
        );
    }

    
    function _cancelAuction(uint256 _tokenId, address _seller) internal {
        _removeAuction(_tokenId);
        _transfer(_seller, _tokenId);
        AuctionCancelled(_tokenId);
    }

    
    /// Does NOT transfer ownership of token.
    function _bid(uint256 _tokenId, uint256 _bidAmount)
        internal
        returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage auction = tokenIdToAuction[_tokenId];

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(_isOnAuction(auction));

        // Check that the incoming bid is higher than the current
        // price
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
            //  Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            //  value <= price, so this subtraction can't go negative.)
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

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

// File: contracts-origin/Auction/ClockAuction.sol


contract ClockAuction is Pausable, ClockAuctionBase {

    
    ///  and verifies the owner cut is in the valid range.
    
    ///  the Nonfungible Interface.
    
    ///  between 0-10,000.
    function ClockAuction(address _nftAddress, uint256 _cut) public {
        require(_cut <= 10000);
        ownerCut = _cut;
        
        ERC721 candidateContract = ERC721(_nftAddress);
        require(candidateContract.implementsERC721());
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
        nftAddress.transfer(this.balance);
    }

    
    
    
    
    
    ///  price and ending price (in seconds).
    
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        public
        whenNotPaused
        canBeStoredWith128Bits(_startingPrice)
        canBeStoredWith128Bits(_endingPrice)
        canBeStoredWith64Bits(_duration)
    {
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
        public
        payable
        whenNotPaused
    {
        // _bid will throw if the bid or funds transfer fails
        _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);
    }

    
    ///  Returns the NFT to original owner.
    
    ///  be called while the contract is paused.
    
    function cancelAuction(uint256 _tokenId)
        public
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }

    
    ///  Only the owner may do this, and NFTs are returned to
    ///  the seller. This should only be used in emergencies.
    
    function cancelAuctionWhenPaused(uint256 _tokenId)
        whenPaused
        onlyOwner
        public
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        _cancelAuction(_tokenId, auction.seller);
    }

    
    
    function getAuction(uint256 _tokenId)
        public
        view
        returns
    (
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
        public
        view
        returns (uint256)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return _currentPrice(auction);
    }

}

// File: contracts-origin/Auction/AetherClockAuction.sol


contract AetherClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public isAetherClockAuction = true;

    // Tracks last 5 sale price of gen0 property sales
    uint256 public saleCount;
    uint256[5] public lastSalePrices;

    // Delegate constructor
    function AetherClockAuction(address _nftAddr, uint256 _cut) public
      ClockAuction(_nftAddr, _cut) {}


    
    
    
    
    
    
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        public
        canBeStoredWith128Bits(_startingPrice)
        canBeStoredWith128Bits(_endingPrice)
        canBeStoredWith64Bits(_duration)
    {
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
        public
        payable
    {
        // _bid verifies token ID size
        address seller = tokenIdToAuction[_tokenId].seller;
        uint256 price = _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);

        // If not a gen0 auction, exit
        if (seller == address(nonFungibleContract)) {
            // Track gen0 sale prices
            lastSalePrices[saleCount % 5] = price;
            saleCount++;
        }
    }

    function averageSalePrice() public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 5; i++) {
            sum += lastSalePrices[i];
        }
        return sum / 5;
    }
}

// File: contracts-origin/AetherAuction.sol


///  This wrapper of ReverseAuction exists only so that users can create
///  auctions with only one transaction.
contract AetherAuction is AetherOwnership{

    
    ///  same contract handles both peer-to-peer sales as well as the gen0 sales which are
    ///  initiated every 15 minutes.
    AetherClockAuction public saleAuction;

    
    
    function setSaleAuctionAddress(address _address) public onlyCEO {
        AetherClockAuction candidateContract = AetherClockAuction(_address);

        // NOTE: verify that a contract is what we expect
        require(candidateContract.isAetherClockAuction());

        // Set the new contract address
        saleAuction = candidateContract;
    }

    
    ///  Does some ownership trickery to create auctions in one tx.
    function createSaleAuction(
        uint256 _propertyId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        public
        whenNotPaused
    {
        // Auction contract checks input sizes
        // If property is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _propertyId));
        _approve(_propertyId, saleAuction);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the property.
        saleAuction.createAuction(
            _propertyId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }

    
    /// to the AetherCore contract. We use two-step withdrawal to
    /// prevent two transfer calls in the auction bid function.
    function withdrawAuctionBalances() external onlyCOO {
        saleAuction.withdrawBalance();
    }
}

// File: contracts-origin/AetherConstruct.sol

// Auction wrapper functions



contract AetherConstruct is AetherAuction {

    uint256 public districtLimit = 16;
    uint256 public startingPrice = 1 ether;
    uint256 public auctionDuration = 1 days;

    
    function createUnit(uint256 _buildingId)
        public
        payable
        returns(uint256)
    {
        require(canCreateUnit(_buildingId));
        require(msg.value >= unitCreationFee);
        if (msg.value > unitCreationFee)
            msg.sender.transfer(msg.value - unitCreationFee);
        uint256 propertyId = _createUnitHelper(_buildingId, msg.sender);
        return propertyId;
    }

    
    function createUnitOmni(
      uint32 _buildingId,
      address _owner
    )
      public
      onlyCOO
    {
        if (_owner == address(0)) {
             _owner = cooAddress;
        }
        require(canCreateUnit(_buildingId));
        _createUnitHelper(_buildingId, _owner);
    }

    
    function createBuildingOmni(
      uint32 _districtId,
      uint8 _x,
      uint8 _y,
      uint8 _z,
      uint8 _dx,
      uint8 _dz,
      address _owner,
      bool _open
    )
      public
      onlyCOO
    {
        if (_owner == address(0)) {
             _owner = cooAddress;
        }
        _createBuilding(_districtId, _x, _y, _z, _dx, _dz, _owner, _open);
    }

    
    function createDistrictOmni(
      uint8 _x,
      uint8 _z,
      uint8 _dx,
      uint8 _dz
    )
      public
      onlyCOO
    {
      require(districts.length < districtLimit);
      _createDistrict(_x, _z, _dx, _dz);
    }


    
    ///  creates an auction for it. Only callable by COO.
    function createBuildingAuction(
      uint32 _districtId,
      uint8 _x,
      uint8 _y,
      uint8 _z,
      uint8 _dx,
      uint8 _dz,
      bool _open
    ) public onlyCOO {
        uint256 propertyId = _createBuilding(_districtId, _x, _y, _z, _dx, _dz, address(this), _open);
        _approve(propertyId, saleAuction);

        saleAuction.createAuction(
            propertyId,
            _computeNextPrice(),
            0,
            auctionDuration,
            address(this)
        );
    }

    
    ///  be called by the COO address.
    function setUnitCreationFee(uint256 _value) public onlyCOO {
        unitCreationFee = _value;
    }

    
    //   as the city expands. Only callable by COO.
    function setProgress(uint256 _progress) public onlyCOO {
        require(_progress <= 100);
        require(_progress > progress);
        progress = _progress;
    }

    
    function setUpdateState(bool _updateEnabled) public onlyCOO {
        updateEnabled = _updateEnabled;
    }

    
    ///  5 prices + 50%.
    function _computeNextPrice() internal view returns (uint256) {
        uint256 avePrice = saleAuction.averageSalePrice();

        // sanity check to ensure we don't overflow arithmetic (this big number is 2^128-1).
        require(avePrice < 340282366920938463463374607431768211455);

        uint256 nextPrice = avePrice + (avePrice / 2);

        // We never auction for less than starting price
        if (nextPrice < startingPrice) {
            nextPrice = startingPrice;
        }

        return nextPrice;
    }
}

// File: contracts-origin/AetherCore.sol



contract AetherCore is AetherConstruct {

    // This is the main Aether contract. In order to keep our code seperated into logical sections,
    // we've broken it up in two ways.  The auctions are seperate since their logic is somewhat complex
    // and there's always a risk of subtle bugs. By keeping them in their own contracts, we can upgrade
    // them without disrupting the main contract that tracks property ownership.
    //
    // Secondly, we break the core contract into multiple files using inheritence, one for each major
    // facet of functionality of Aether. This allows us to keep related code bundled together while still
    // avoiding a single giant file with everything in it. The breakdown is as follows:
    //
    //      - AetherBase: This is where we define the most fundamental code shared throughout the core
    //             functionality. This includes our main data storage, constants and data types, plus
    //             internal functions for managing these items.
    //
    //      - AetherAccessControl: This contract manages the various addresses and constraints for operations
    //             that can be executed only by specific roles. Namely CEO, CFO and COO.
    //
    //      - AetherOwnership: This provides the methods required for basic non-fungible token
    //             transactions, following the draft ERC-721 spec (https://github.com/ethereum/EIPs/issues/721).
    //
    //      - AetherAuction: Here we have the public methods for auctioning or bidding on property.
    //             The actual auction functionality is handled in two sibling contracts while auction
    //             creation and bidding is mostly mediated through this facet of the core contract.
    //
    //      - AetherConstruct: This final facet contains the functionality we use for creating new gen0 cats.

    //             the community is new).

    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    
    function AetherCore() public {
        // Starts paused.
        paused = true;

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;
    }

    
    ///  breaking bug. This method does nothing but keep track of the new contract and
    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    
    function setNewAddress(address _v2Address) public onlyCEO whenPaused {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        ContractUpgrade(_v2Address);
    }

    
    
    ///  two auction contracts. (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(
            msg.sender == address(saleAuction)
        );
    }

    
    
    function getProperty(uint256 _id)
        public
        view
        returns (
        uint32 parent,
        uint8 class,
        uint8 x,
        uint8 y,
        uint8 z,
        uint8 dx,
        uint8 dz,
        uint8 height
    ) {
        Property storage property = properties[_id];
        parent = uint32(property.parent);
        class = uint8(property.class);

        height = uint8(property.y);
        if (property.class == PropertyClass.BUILDING) {
          y = uint8(_computeHeight(property.x, property.z, property.y));
        } else {
          y = uint8(property.y);
        }

        x = uint8(property.x);
        z = uint8(property.z);
        dx = uint8(property.dx);
        dz = uint8(property.dz);
    }

    
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    function unpause() public onlyCEO whenPaused {
        require(saleAuction != address(0));
        require(newContractAddress == address(0));
        // Actually unpause the contract.
        super.unpause();
    }
}