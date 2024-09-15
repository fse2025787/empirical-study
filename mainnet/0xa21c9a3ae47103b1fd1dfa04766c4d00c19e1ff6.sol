
pragma solidity ^0.4.18; // solhint-disable-line



contract ERC721 {
  // Required methods
  function approve(address _to, uint256 _tokenId) public;
  function balanceOf(address _owner) public view returns (uint256 balance);
  function implementsERC721() public pure returns (bool);
  function ownerOf(uint256 _tokenId) public view returns (address addr);
  function takeOwnership(uint256 _tokenId) public;
  function totalSupply() public view returns (uint256 total);
  function transferFrom(address _from, address _to, uint256 _tokenId) public;
  function transfer(address _to, uint256 _tokenId) public;

  event Transfer(address indexed from, address indexed to, uint256 tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 tokenId);

  // Optional
  // function name() public view returns (string name);
  // function symbol() public view returns (string symbol);
  // function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 tokenId);
  // function tokenMetadata(uint256 _tokenId) public view returns (string infoUrl);
}


contract CryptoOscarsToken is ERC721 {

  /*** EVENTS ***/

  
  event Birth(uint256 tokenId, string name, address owner);

  
  event TokenSold(uint256 tokenId, uint256 oldPrice, uint256 newPrice, address prevOwner, address winner, string name);

  
  ///  ownership is assigned, including births.
  event Transfer(address from, address to, uint256 tokenId);

  /*** CONSTANTS ***/

  
  string public constant NAME = "CryptoOscars"; // solhint-disable-line
  string public constant SYMBOL = "CryptoOscarsToken"; // solhint-disable-line

  uint256 private startingPrice = 0.001 ether;
  uint256 private constant PROMO_CREATION_LIMIT = 20000;

  /*** STORAGE ***/

  
  ///  some valid owner address.
  mapping (uint256 => address) public movieIndexToOwner;

  // @dev A mapping from owner address to count of tokens that address owns.
  //  Used internally inside balanceOf() to resolve ownership count.
  mapping (address => uint256) private ownershipTokenCount;

  
  ///  transferFrom(). Each Movie can only have one approved address for transfer
  ///  at any time. A zero value means no approval is outstanding.
  mapping (uint256 => address) public movieIndexToApproved;

  // @dev A mapping from MovieIDs to the price of the token.
  mapping (uint256 => uint256) private movieIndexToPrice;

  // The addresses of the accounts (or contracts) that can execute actions within each roles.
  address public ceoAddress;
  address public cooAddress;

  uint256 public promoCreatedCount;

  /*** DATATYPES ***/
  struct Movie {
    string name;
  }

  Movie[] private movies;

  /*** ACCESS MODIFIERS ***/
  
  modifier onlyCEO() {
    require(msg.sender == ceoAddress);
    _;
  }

  
  modifier onlyCOO() {
    require(msg.sender == cooAddress);
    _;
  }

  /// Access modifier for contract owner only functionality
  modifier onlyCLevel() {
    require(
      msg.sender == ceoAddress ||
      msg.sender == cooAddress
    );
    _;
  }

  /*** CONSTRUCTOR ***/
  function CryptoMoviesToken() public {
    ceoAddress = msg.sender;
    cooAddress = msg.sender;
  }

  /*** PUBLIC FUNCTIONS ***/
  
  
  ///  clear all approvals.
  
  
  function approve(address _to, uint256 _tokenId) public {
    // Caller must own token.
    require(_owns(msg.sender, _tokenId));

    movieIndexToApproved[_tokenId] = _to;

    Approval(msg.sender, _to, _tokenId);
  }

  /// For querying balance of a particular account
  
  
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return ownershipTokenCount[_owner];
  }

  
  function createPromoMovie(address _owner, string _name, uint256 _price) public onlyCOO {
    require(promoCreatedCount < PROMO_CREATION_LIMIT);

    address movieOwner = _owner;
    if (movieOwner == address(0)) {
      movieOwner = cooAddress;
    }

    if (_price <= 0) {
      _price = startingPrice;
    }

    promoCreatedCount++;
    _createMovie(_name, movieOwner, _price);
  }

  
  function createContractMovie(string _name) public onlyCOO {
    _createMovie(_name, address(this), startingPrice);
  }

  
  
  function getMovie(uint256 _tokenId) public view returns (
    string movieName,
    uint256 sellingPrice,
    address owner
  ) {
    Movie storage movie = movies[_tokenId];
    movieName = movie.name;
    sellingPrice = movieIndexToPrice[_tokenId];
    owner = movieIndexToOwner[_tokenId];
  }

  function implementsERC721() public pure returns (bool) {
    return true;
  }

  
  function name() public pure returns (string) {
    return NAME;
  }

  /// For querying owner of token
  
  
  function ownerOf(uint256 _tokenId)
    public
    view
    returns (address owner)
  {
    owner = movieIndexToOwner[_tokenId];
    require(owner != address(0));
  }

  function payout(address _to) public onlyCLevel {
    _payout(_to);
  }

  // Allows someone to send ether and obtain the token
  function purchase(uint256 _tokenId) public payable {
    address oldOwner = movieIndexToOwner[_tokenId];
    address newOwner = msg.sender;

    uint256 sellingPrice = movieIndexToPrice[_tokenId];

    // Making sure token owner is not sending to self
    require(oldOwner != newOwner);

    // Safety check to prevent against an unexpected 0x0 default.
    require(_addressNotNull(newOwner));

    // Making sure sent amount is greater than or equal to the sellingPrice
    require(msg.value >= sellingPrice);

    uint256 payment = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 80), 100));
    uint256 purchaseExcess = SafeMath.sub(msg.value, sellingPrice);

    // Update prices
    movieIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 150), 80);

    _transfer(oldOwner, newOwner, _tokenId);

    // Pay previous tokenOwner if owner is not contract
    if (oldOwner != address(this)) {
      oldOwner.transfer(payment);
    }

    TokenSold(_tokenId, sellingPrice, movieIndexToPrice[_tokenId], oldOwner, newOwner, movies[_tokenId].name);

    msg.sender.transfer(purchaseExcess);
  }

  function priceOf(uint256 _tokenId) public view returns (uint256 price) {
    return movieIndexToPrice[_tokenId];
  }

  
  
  function setCEO(address _newCEO) public onlyCEO {
    require(_newCEO != address(0));

    ceoAddress = _newCEO;
  }

  
  
  function setCOO(address _newCOO) public onlyCEO {
    require(_newCOO != address(0));

    cooAddress = _newCOO;
  }

  
  function symbol() public pure returns (string) {
    return SYMBOL;
  }

  
  
  
  function takeOwnership(uint256 _tokenId) public {
    address newOwner = msg.sender;
    address oldOwner = movieIndexToOwner[_tokenId];

    // Safety check to prevent against an unexpected 0x0 default.
    require(_addressNotNull(newOwner));

    // Making sure transfer is approved
    require(_approved(newOwner, _tokenId));

    _transfer(oldOwner, newOwner, _tokenId);
  }

  
  
  ///  expensive (it walks the entire Movies array looking for movies belonging to owner),
  ///  but it also returns a dynamic array, which is only supported for web3 calls, and
  ///  not contract-to-contract calls.
  function tokensOfOwner(address _owner) public view returns(uint256[] ownerTokens) {
    uint256 tokenCount = balanceOf(_owner);
    if (tokenCount == 0) {
        // Return an empty array
      return new uint256[](0);
    } else {
      uint256[] memory result = new uint256[](tokenCount);
      uint256 totalMovies = totalSupply();
      uint256 resultIndex = 0;

      uint256 movieId;
      for (movieId = 0; movieId <= totalMovies; movieId++) {
        if (movieIndexToOwner[movieId] == _owner) {
          result[resultIndex] = movieId;
          resultIndex++;
        }
      }
      return result;
    }
  }

  /// For querying totalSupply of token
  
  function totalSupply() public view returns (uint256 total) {
    return movies.length;
  }

  /// Owner initates the transfer of the token to another account
  
  
  
  function transfer(address _to, uint256 _tokenId) public {
    require(_owns(msg.sender, _tokenId));
    require(_addressNotNull(_to));

    _transfer(msg.sender, _to, _tokenId);
  }

  /// Third-party initiates transfer of token from address _from to address _to
  
  
  
  
  function transferFrom(address _from, address _to, uint256 _tokenId) public {
    require(_owns(_from, _tokenId));
    require(_approved(_to, _tokenId));
    require(_addressNotNull(_to));

    _transfer(_from, _to, _tokenId);
  }

  /*** PRIVATE FUNCTIONS ***/
  /// Safety check on _to address to prevent against an unexpected 0x0 default.
  function _addressNotNull(address _to) private pure returns (bool) {
    return _to != address(0);
  }

  /// For checking approval of transfer for address _to
  function _approved(address _to, uint256 _tokenId) private view returns (bool) {
    return movieIndexToApproved[_tokenId] == _to;
  }

  /// For creating Movie
  function _createMovie(string _name, address _owner, uint256 _price) private {
    Movie memory _movie = Movie({
      name: _name
    });
    uint256 newMovieId = movies.push(_movie) - 1;

    // It's probably never going to happen, 4 billion tokens are A LOT, but
    // let's just be 100% sure we never let this happen.
    require(newMovieId == uint256(uint32(newMovieId)));

    Birth(newMovieId, _name, _owner);

    movieIndexToPrice[newMovieId] = _price;

    // This will assign ownership, and also emit the Transfer event as
    // per ERC721 draft
    _transfer(address(0), _owner, newMovieId);
  }

  /// Check for token ownership
  function _owns(address claimant, uint256 _tokenId) private view returns (bool) {
    return claimant == movieIndexToOwner[_tokenId];
  }

  /// For paying out balance on contract
  function _payout(address _to) private {
    if (_to == address(0)) {
      ceoAddress.transfer(this.balance);
    } else {
      _to.transfer(this.balance);
    }
  }

  
  function _transfer(address _from, address _to, uint256 _tokenId) private {
    // Since the number of movies is capped to 2^32 we can't overflow this
    ownershipTokenCount[_to]++;
    // transfer ownership
    movieIndexToOwner[_tokenId] = _to;

    // When creating new movies _from is 0x0, but we can't account that address.
    if (_from != address(0)) {
      ownershipTokenCount[_from]--;
      // clear any previously approved ownership exchange
      delete movieIndexToApproved[_tokenId];
    }

    // Emit the transfer event.
    Transfer(_from, _to, _tokenId);
  }
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}