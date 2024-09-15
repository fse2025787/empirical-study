
pragma solidity ^0.4.18;
/* ==================================================================== */
/* Copyright (c) 2018 The Priate Conquest Project.  All rights reserved.
/* 
/* https://www.pirateconquest.com One of the world's slg games of blockchain 
/*  
/* authors rainy@livestar.com/Jonny.Fu@livestar.com
/*                 
/* ==================================================================== */


///  Note: the ERC-165 identifier for this interface is 0x80ac58cd
contract ERC721 /* is ERC165 */ {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  function balanceOf(address _owner) external view returns (uint256);
  function ownerOf(uint256 _tokenId) external view returns (address);
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
  function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
  function approve(address _approved, uint256 _tokenId) external payable;
  function setApprovalForAll(address _operator, bool _approved) external;
  function getApproved(uint256 _tokenId) external view returns (address);
  function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface ERC165 {
     function supportsInterface(bytes4 interfaceID) external view returns (bool);
}


interface ERC721TokenReceiver {
	function onERC721Received(address _from, uint256 _tokenId, bytes data) external returns(bytes4);
}



///  Note: the ERC-165 identifier for this interface is 0x5b5e139f
interface ERC721Metadata /* is ERC721 */ {
    function name() external view returns (string _name);
    function symbol() external view returns (string _symbol);
    function tokenURI(uint256 _tokenId) external view returns (string);
}



///  Note: the ERC-165 identifier for this interface is 0x780e9d63
interface ERC721Enumerable /* is ERC721 */ {
    function totalSupply() external view returns (uint256);
    function tokenByIndex(uint256 _index) external view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /*
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
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


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
  function pause() external onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() external onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
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

  function mul32(uint32 a, uint32 b) internal pure returns (uint32) {
    if (a == 0) {
      return 0;
    }
    uint32 c = a * b;
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

  function div32(uint32 a, uint32 b) internal pure returns (uint32) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint32 c = a / b;
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

  function sub32(uint32 a, uint32 b) internal pure returns (uint32) {
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

  function add32(uint32 a, uint32 b) internal pure returns (uint32) {
    uint32 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract AccessAdmin is Pausable {

  
  mapping (address => bool) adminContracts;

  
  mapping (address => bool) actionContracts;

  function setAdminContract(address _addr, bool _useful) public onlyOwner {
    require(_addr != address(0));
    adminContracts[_addr] = _useful;
  }

  modifier onlyAdmin {
    require(adminContracts[msg.sender]); 
    _;
  }

  function setActionContract(address _actionAddr, bool _useful) public onlyAdmin {
    actionContracts[_actionAddr] = _useful;
  }

  modifier onlyAccess() {
    require(actionContracts[msg.sender]);
    _;
  }
}


contract KittyToken is AccessAdmin, ERC721 {
  using SafeMath for SafeMath;
  //event 
  event CreateGift(uint tokenId,uint32 cardId, address _owner, uint256 _price);
  //ERC721
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  struct Kitty {
    uint32 kittyId;
  }

  Kitty[] public kitties; //dynamic Array
  function KittyToken() public {
    kitties.length += 1;
    setAdminContract(msg.sender,true);
    setActionContract(msg.sender,true);
  }

  /**MAPPING**/
  
  mapping (uint256 => address) public TokenIdToOwner;
  
  mapping (uint256 => uint256) kittyIdToOwnerIndex;  
  
  mapping (address => uint256[]) ownerTokittyArray;
  
  mapping (uint256 => uint256) TokenIdToPrice;
  
  mapping (uint32 => uint256) tokenCountOfkitty;
  
  mapping (uint256 => uint32) IndexTokitty;
  
  mapping (uint256 => address) kittyTokenIdToApprovals;
  
  mapping (address => mapping (address => bool)) operatorToApprovals;
  mapping(uint256 => bool) tokenToSell;
  

  /*** CONSTRUCTOR ***/
  
  uint256 destroyKittyCount;
  uint256 onAuction;
  // modifier
  
  modifier isValidToken(uint256 _tokenId) {
    require(_tokenId >= 1 && _tokenId <= kitties.length);
    require(TokenIdToOwner[_tokenId] != address(0)); 
    _;
  }
  modifier canTransfer(uint256 _tokenId) {
    require(msg.sender == TokenIdToOwner[_tokenId]);
    _;
  }
  
  function CreateKittyToken(address _owner,uint256 _price, uint32 _cardId) public onlyAccess {
    _createKittyToken(_owner,_price,_cardId);
  }

    /// For creating GiftToken
  function _createKittyToken(address _owner, uint256 _price, uint32 _kittyId) 
  internal {
    uint256 newTokenId = kitties.length;
    Kitty memory _kitty = Kitty({
      kittyId: _kittyId
    });
    kitties.push(_kitty);
    //event
    CreateGift(newTokenId, _kittyId, _owner, _price);
    TokenIdToPrice[newTokenId] = _price;
    IndexTokitty[newTokenId] = _kittyId;
    tokenCountOfkitty[_kittyId] = SafeMath.add(tokenCountOfkitty[_kittyId],1);
    // This will assign ownership, and also emit the Transfer event as
    // per ERC721 draft
    _transfer(address(0), _owner, newTokenId);
  } 
  
  function setTokenPriceByOwner(uint256 _tokenId, uint256 _price) external {
    require(TokenIdToOwner[_tokenId] == msg.sender);
    TokenIdToPrice[_tokenId] = _price;
  }

    
  function setTokenPrice(uint256 _tokenId, uint256 _price) external onlyAccess {
    TokenIdToPrice[_tokenId] = _price;
  }

  
  
  function getKittyInfo(uint256 _tokenId) external view returns (
    uint32 kittyId,  
    uint256 price,
    address owner,
    bool selled
  ) {
    Kitty storage kitty = kitties[_tokenId];
    kittyId = kitty.kittyId;
    price = TokenIdToPrice[_tokenId];
    owner = TokenIdToOwner[_tokenId];
    selled = tokenToSell[_tokenId];
  }
  
  
  
  
  function _transfer(address _from, address _to, uint256 _tokenId) internal {
    if (_from != address(0)) {
      uint256 indexFrom = kittyIdToOwnerIndex[_tokenId];  // tokenId -> kittyId
      uint256[] storage cpArray = ownerTokittyArray[_from];
      require(cpArray[indexFrom] == _tokenId);

      // If the kitty is not the element of array, change it to with the last
      if (indexFrom != cpArray.length - 1) {
        uint256 lastTokenId = cpArray[cpArray.length - 1];
        cpArray[indexFrom] = lastTokenId; 
        kittyIdToOwnerIndex[lastTokenId] = indexFrom;
      }
      cpArray.length -= 1; 
    
      if (kittyTokenIdToApprovals[_tokenId] != address(0)) {
        delete kittyTokenIdToApprovals[_tokenId];
      }      
    }

    // Give the kitty to '_to'
    TokenIdToOwner[_tokenId] = _to;
    ownerTokittyArray[_to].push(_tokenId);
    kittyIdToOwnerIndex[_tokenId] = ownerTokittyArray[_to].length - 1;
        
    Transfer(_from != address(0) ? _from : this, _to, _tokenId);
  }

  
  function getAuctions() external view returns (uint256[]) {
    uint256 totalgifts = kitties.length - destroyKittyCount - 1;

    uint256[] memory result = new uint256[](onAuction);
    uint256 tokenId = 1;
    for (uint i=0;i< totalgifts;i++) {
      if (tokenToSell[tokenId] == true) {
        result[i] = tokenId;
        tokenId ++;
      }
    }
    return result;
  }
  /// ERC721 

  function balanceOf(address _owner) external view returns (uint256) {
    require(_owner != address(0));
    return ownerTokittyArray[_owner].length;
  }

  function ownerOf(uint256 _tokenId) external view returns (address) {
    return TokenIdToOwner[_tokenId];
  }
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable {
    _safeTransferFrom(_from, _to, _tokenId, data);
  }
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
    _safeTransferFrom(_from, _to, _tokenId, "");
  }

  
  function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) 
    internal
    isValidToken(_tokenId) 
    canTransfer(_tokenId)
    {
    address owner = TokenIdToOwner[_tokenId];
    require(owner != address(0) && owner == _from);
    require(_to != address(0));
        
    _transfer(_from, _to, _tokenId);

    // Do the callback after everything is done to avoid reentrancy attack
    /*uint256 codeSize;
    assembly { codeSize := extcodesize(_to) }
    if (codeSize == 0) {
      return;
    }*/
    bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(_from, _tokenId, data);
    // bytes4(keccak256("onERC721Received(address,uint256,bytes)")) = 0xf0b9e5ba;
    require(retval == 0xf0b9e5ba);
  }
    
  
  
  
  
  function transferFrom(address _from, address _to, uint256 _tokenId)
        external
        whenNotPaused
        isValidToken(_tokenId)
        canTransfer(_tokenId)
        payable
    {
    address owner = TokenIdToOwner[_tokenId];
    require(owner != address(0));
    require(owner == _from);
    require(_to != address(0));
        
    _transfer(_from, _to, _tokenId);
  }

  
  function safeTransferByContract(address _from,address _to, uint256 _tokenId) 
  external
  whenNotPaused
  {
    require(actionContracts[msg.sender]);

    require(_tokenId >= 1 && _tokenId <= kitties.length);
    address owner = TokenIdToOwner[_tokenId];
    require(owner != address(0));
    require(_to != address(0));
    require(owner != _to);
    require(_from == owner);

    _transfer(owner, _to, _tokenId);
  }

  
  
  
  function approve(address _approved, uint256 _tokenId)
    external
    whenNotPaused 
    payable
  {
    address owner = TokenIdToOwner[_tokenId];
    require(owner != address(0));
    require(msg.sender == owner || operatorToApprovals[owner][msg.sender]);

    kittyTokenIdToApprovals[_tokenId] = _approved;
    Approval(owner, _approved, _tokenId);
  }

  
  
  
  function setApprovalForAll(address _operator, bool _approved) 
    external 
    whenNotPaused
  {
    operatorToApprovals[msg.sender][_operator] = _approved;
    ApprovalForAll(msg.sender, _operator, _approved);
  }

  
  
  
  function getApproved(uint256 _tokenId) external view isValidToken(_tokenId) returns (address) {
    return kittyTokenIdToApprovals[_tokenId];
  }
  
  
  
  
  
  function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
    return operatorToApprovals[_owner][_operator];
  }
  
  function name() public pure returns(string) {
    return "Pirate Kitty Token";
  }
  
  function symbol() public pure returns(string) {
    return "KCT";
  }
  
  
  ///  3986. The URI may point to a JSON file that conforms to the "ERC721
  ///  Metadata JSON Schema".
  //function tokenURI(uint256 _tokenId) external view returns (string);

  
  
  ///  them has an assigned and queryable owner not equal to the zero address
  function totalSupply() external view returns (uint256) {
    return kitties.length - destroyKittyCount -1;
  }
  
  
  
  
  ///  (sort order not specified)
  function tokenByIndex(uint256 _index) external view returns (uint256) {
    require(_index<(kitties.length - destroyKittyCount));
    //return kittyIdToOwnerIndex[_index];
    return _index;
  }
  
  
  ///  `_owner` is the zero address, representing invalid NFTs.
  
  
  
  ///   (sort order not specified)
  function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256) {
    require(_index < ownerTokittyArray[_owner].length);
    if (_owner != address(0)) {
      uint256 tokenId = ownerTokittyArray[_owner][_index];
      return tokenId;
    }
  }

  
  
  ///  expensive (it walks the entire Persons array looking for persons belonging to owner),
  ///  but it also returns a dynamic array, which is only supported for web3 calls, and
  ///  not contract-to-contract calls.
  function tokensOfOwner(address _owner) external view returns (uint256[],uint32[]) {
    uint256 len = ownerTokittyArray[_owner].length;
    uint256[] memory tokens = new uint256[](len);
    uint32[] memory kittyss = new uint32[](len);
    uint256 icount;
    if (_owner != address(0)) {
      for (uint256 i=0;i<len;i++) {
        tokens[i] = ownerTokittyArray[_owner][icount];
        kittyss[i] = IndexTokitty[ownerTokittyArray[_owner][icount]];
        icount++;
      }
    }
    return (tokens,kittyss);
  }

  
  
  ///  expensive (it walks the entire Persons array looking for persons belonging to owner),
  ///  but it also returns a dynamic array, which is only supported for web3 calls, and
  ///  not contract-to-contract calls.
  function tokensOfkitty(uint32 _kittyId) public view returns(uint256[] kittyTokens) {
    uint256 tokenCount = tokenCountOfkitty[_kittyId];
    if (tokenCount == 0) {
        // Return an empty array
      return new uint256[](0);
    } else {
      uint256[] memory result = new uint256[](tokenCount);
      uint256 totalkitties = kitties.length - destroyKittyCount - 1;
      uint256 resultIndex = 0;

      uint256 tokenId;
      for (tokenId = 0; tokenId <= totalkitties; tokenId++) {
        if (IndexTokitty[tokenId] == _kittyId) {
          result[resultIndex] = tokenId;
          resultIndex++;
        }
      }
      return result;
    }
  } 
}