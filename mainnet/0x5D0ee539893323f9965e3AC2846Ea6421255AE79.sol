
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
  //function tokenUri(uint256 _tokenId) public view returns (string);
}


contract HiPrecious is ERC721 {

  /*** EVENTS ***/

  
  event Birth(uint256 tokenId, string name, address owner);

  
  ///  ownership is assigned, including births.
  event Transfer(address from, address to, uint256 tokenId);

  /*** CONSTANTS ***/

  
  string public constant NAME = "HiPrecious"; // solhint-disable-line
  string public constant SYMBOL = "HIP"; // solhint-disable-line

  /*** STORAGE ***/

  
  ///  some valid owner address.
  mapping (uint256 => address) public preciousIndexToOwner;

  // @dev A mapping from owner address to count of precious that address owns.
  //  Used internally inside balanceOf() to resolve ownership count.
  mapping (address => uint256) private ownershipPreciousCount;

  
  ///  transferFrom(). Each Precious can only have one approved address for transfer
  ///  at any time. A zero value means no approval is outstanding.
  mapping (uint256 => address) public preciousIndexToApproved;

  // Addresses of the main roles in HiPrecious.
  address public daVinciAddress; //CPO Product
  address public cresusAddress;  //CFO Finance
  
  
 function () public payable {} // Give the ability of receiving ether

  /*** DATATYPES ***/

  struct Precious {
    string name;  // Edition name like 'Monroe'
    uint256 number; //  Like 12 means #12 out of the edition.worldQuantity possible (here in the example 15)
    uint256 editionId;  // id to find the edition in which this precious Belongs to. Stored in allEditions[precious.editionId]
    uint256 collectionId; // id to find the collection in which this precious Belongs to. Stored in allCollections[precious.collectionId]
    string tokenURI;
  }

  struct Edition {
    uint256 id;
    string name; // Like 'Lee'
    uint256 worldQuantity; // The number of precious composing this edition (ex: if 15 then there will never be more precious in this edition)
    uint256[] preciousIds; // The list of precious ids which compose this edition.
    uint256 collectionId;
  }

  struct Collection {
    uint256 id;
    string name; // Like 'China'
    uint256[] editionIds; // The list of edition ids which compose this collection Ex: allEditions.get[editionIds[0]].name = 'Lee01'dawd'
  }

  Precious[] private allPreciouses;
  Edition[] private allEditions;
  Collection[] private allCollections;

  /*** ACCESS MODIFIERS ***/
  
  modifier onlyDaVinci() {
    require(msg.sender == daVinciAddress);
    _;
  }

  
  modifier onlyCresus() {
    require(msg.sender == cresusAddress);
    _;
  }

  /// Access modifier for contract owner only functionality
  modifier onlyCLevel() {
    require(msg.sender == daVinciAddress || msg.sender == cresusAddress);
    _;
  }

  /*** CONSTRUCTOR ***/
  function HiPrecious() public {
    daVinciAddress = msg.sender;
    cresusAddress = msg.sender;
  }

  /*** PUBLIC FUNCTIONS ***/
  
  
  ///  clear all approvals.
  
  
  function approve(
    address _to,
    uint256 _tokenId
  ) public {
    // Caller must own token.
    require(_owns(msg.sender, _tokenId));

    preciousIndexToApproved[_tokenId] = _to;

    emit Approval(msg.sender, _to, _tokenId);
  }

  /// For querying balance of a particular account
  
  
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return ownershipPreciousCount[_owner];
  }

  
  function createContractCollection(string _name) public onlyDaVinci {
    _createCollection(_name);
  }

  
  function createContractEditionForCollection(string _name, uint256 _collectionId, uint256 _worldQuantity) public onlyDaVinci {
    _createEdition(_name, _collectionId, _worldQuantity);
  }
  
    
  function createContractPreciousForEdition(address _to, uint256 _editionId, string _tokenURI) public onlyDaVinci {
    _createPrecious(_to, _editionId, _tokenURI);
  }

  
  
  function getPrecious(uint256 _tokenId) public view returns (
    string preciousName,
    uint256 number,
    uint256 editionId,
    uint256 collectionId,
    address owner
  ) {
    Precious storage precious = allPreciouses[_tokenId];
    preciousName = precious.name;
    number = precious.number;
    editionId = precious.editionId;
    collectionId = precious.collectionId;
    owner = preciousIndexToOwner[_tokenId];
  }

  
  
  function getEdition(uint256 _editionId) public view returns (
    uint256 id,
    string editionName,
    uint256 worldQuantity,
    uint256[] preciousIds
  ) {
    Edition storage edition = allEditions[_editionId-1];
    id = edition.id;
    editionName = edition.name;
    worldQuantity = edition.worldQuantity;
    preciousIds = edition.preciousIds;
  }

  
  
  function getCollection(uint256 _collectionId) public view returns (
    uint256 id,
    string collectionName,
    uint256[] editionIds
  ) {
    Collection storage collection = allCollections[_collectionId-1];
    id = collection.id;
    collectionName = collection.name;
    editionIds = collection.editionIds;
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
    owner = preciousIndexToOwner[_tokenId];
    require(owner != address(0));
  }

  function payout(address _to) public onlyCresus {
    _payout(_to);
  }

  
  
  function setDaVinci(address _newDaVinci) public onlyDaVinci {
    require(_newDaVinci != address(0));

    daVinciAddress = _newDaVinci;
  }

  
  
  function setCresus(address _newCresus) public onlyCresus {
    require(_newCresus != address(0));

    cresusAddress = _newCresus;
  }

  function tokenURI(uint256 _tokenId) public view returns (string){
      require(_tokenId<allPreciouses.length);
      return allPreciouses[_tokenId].tokenURI;
  }
  
  function setTokenURI(uint256 _tokenId, string newURI) public onlyDaVinci{
      require(_tokenId<allPreciouses.length);
      Precious storage precious = allPreciouses[_tokenId];
      precious.tokenURI = newURI;
  }

  
  function symbol() public pure returns (string) {
    return SYMBOL;
  }

  
  
  
  function takeOwnership(uint256 _tokenId) public {
    address newOwner = msg.sender;
    address oldOwner = preciousIndexToOwner[_tokenId];

    // Safety check to prevent against an unexpected 0x0 default.
    require(_addressNotNull(newOwner));

    // Making sure transfer is approved
    require(_approved(newOwner, _tokenId));

    _transfer(oldOwner, newOwner, _tokenId);
  }

  
  
  ///  expensive (it walks the entire allPreciouses array looking for preciouses belonging to owner),
  ///  but it also returns a dynamic array, which is only supported for web3 calls, and
  ///  not contract-to-contract calls.
  function tokensOfOwner(address _owner) public view returns(uint256[] ownerTokens) {
    uint256 tokenCount = balanceOf(_owner);
    if (tokenCount == 0) {
        // Return an empty array
      return new uint256[](0);
    } else {
      uint256[] memory result = new uint256[](tokenCount);
      uint256 totalPreciouses = totalSupply();
      uint256 resultIndex = 0;

      uint256 preciousId;
      for (preciousId = 0; preciousId <= totalPreciouses; preciousId++) {
        if (preciousIndexToOwner[preciousId] == _owner) {
          result[resultIndex] = preciousId;
          resultIndex++;
        }
      }
      return result;
    }
  }

  /// For querying totalSupply of preciouses
  
  function totalSupply() public view returns (uint256 total) {
    return allPreciouses.length;
  }

  /// Owner initates the transfer of the token to another account
  
  
  
  function transfer(
    address _to,
    uint256 _tokenId
  ) public {
    require(_owns(msg.sender, _tokenId));
    require(_addressNotNull(_to));

    _transfer(msg.sender, _to, _tokenId);
  }

  /// Third-party initiates transfer of token from address _from to address _to
  
  
  
  
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  ) public {
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
    return preciousIndexToApproved[_tokenId] == _to;
  }

  /// For creating Collections
  function _createCollection(string _name) private onlyDaVinci{
    uint256 newCollectionId = allCollections.length+1;
    uint256[] storage newEditionIds;
    Collection memory _collection = Collection({
      id: newCollectionId,
      name: _name,
      editionIds: newEditionIds
    });

    allCollections.push(_collection);
  }

  /// For creating Editions
  function _createEdition(string _name, uint256 _collectionId, uint256 _worldQuantity) private onlyDaVinci{
    Collection storage collection = allCollections[_collectionId-1]; //Would retrieve Bad instruction if not exist

    uint256 newEditionId = allEditions.length+1;
    uint256[] storage newPreciousIds;

    Edition memory _edition = Edition({
      id: newEditionId,
      name: _name,
      worldQuantity: _worldQuantity,
      preciousIds: newPreciousIds,
      collectionId: _collectionId
    });

    allEditions.push(_edition);
    collection.editionIds.push(newEditionId);
  }

  /// For creating Precious
  function _createPrecious(address _owner, uint256 _editionId, string _tokenURI) private onlyDaVinci{
    Edition storage edition = allEditions[_editionId-1]; //if _editionId doesn't exist in array, exits.
    
    //Check if we can still print precious for that specific edition
    require(edition.preciousIds.length < edition.worldQuantity);

    //string memory preciousName = edition.name + '_' + edition.preciousIds.length+1 + '/' + edition.worldQuantity; NOT DOABLE IN SOLIDITY

    Precious memory _precious = Precious({
      name: edition.name,
      number: edition.preciousIds.length+1,
      editionId: _editionId,
      collectionId: edition.collectionId,
      tokenURI: _tokenURI
    });

    uint256 newPreciousId = allPreciouses.push(_precious) - 1;
    edition.preciousIds.push(newPreciousId);

    // It's probably never going to happen, 4 billion preciouses are A LOT, but
    // let's just be 100% sure we never let this happen.
    require(newPreciousId == uint256(uint32(newPreciousId)));

    emit Birth(newPreciousId, edition.name, _owner);

    // This will assign ownership, and also emit the Transfer event as
    // per ERC721 draft
    _transfer(address(0), _owner, newPreciousId);
  }

  /// Check for token ownership
  function _owns(address claimant, uint256 _tokenId) private view returns (bool) {
    return claimant == preciousIndexToOwner[_tokenId];
  }

  /// For paying out balance on contract
  function _payout(address _to) private {
    if (_to == address(0)) {
      cresusAddress.transfer(address(this).balance);
    } else {
      _to.transfer(address(this).balance);
    }
  }

  
  function _transfer(address _from, address _to, uint256 _tokenId) private {
    // Since the number of preciouses is capped to 2^32 we can't overflow this
    ownershipPreciousCount[_to]++;
    //transfer ownership
    preciousIndexToOwner[_tokenId] = _to;

    // When creating new preciouses _from is 0x0, but we can't account that address.
    if (_from != address(0)) {
      ownershipPreciousCount[_from]--;
      // clear any previously approved ownership exchange
      delete preciousIndexToApproved[_tokenId];
    }

    // Emit the transfer event.
    emit Transfer(_from, _to, _tokenId);
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