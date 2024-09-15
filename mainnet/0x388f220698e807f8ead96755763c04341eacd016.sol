
pragma solidity ^0.4.25;




contract CSportsConstants {

    
    /// by the commissioner.
    uint16 public MAX_MARKETING_TOKENS = 2500;

    
    ///   of the last 2 is less than this, we will use this value)
    ///   A finney is 1/1000 of an ether.
    uint256 public COMMISSIONER_AUCTION_FLOOR_PRICE = 5 finney; // 5 finney for production, 15 for script testing and 1 finney for Rinkeby

    
    uint256 public COMMISSIONER_AUCTION_DURATION = 14 days; // 30 days for testing;

    
    uint32 constant WEEK_SECS = 1 weeks;

}




contract CSportsAuth is CSportsConstants {
    // This facet controls access control for CryptoSports. There are four roles managed here:
    //
    //     - The CEO: The CEO can reassign other roles and change the addresses of our dependent smart
    //         contracts. It is also the only role that can unpause the smart contract. It is initially
    //         set to the address that created the smart contract in the CSportsCore constructor.
    //
    //     - The CFO: The CFO can withdraw funds from CSportsCore and its auction contracts.
    //
    //     - The COO: The COO can perform administrative functions.
    //
    //     - The Commisioner can perform "oracle" functions like adding new real world players,
    //       setting players active/inactive, and scoring contests.
    //

    
    event ContractUpgrade(address newContract);

    /// The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;
    address public commissionerAddress;

    
    bool public paused = false;

    
    /// only functions to be called.
    bool public isDevelopment = true;

    
    modifier onlyUnderDevelopment() {
      require(isDevelopment == true);
      _;
    }

    
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

    
    modifier onlyCommissioner() {
        require(msg.sender == commissionerAddress);
        _;
    }

    
    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress ||
            msg.sender == commissionerAddress
        );
        _;
    }

    
    modifier notContract() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0);
        _;
    }

    
    /// way in that the contract can never be set back into development mode. Calling
    /// this function will block all future calls to functions that are meant for
    /// access only while we are under development. It will also enable more strict
    /// additional checking on various parameters and settings.
    function setProduction() public onlyCEO onlyUnderDevelopment {
      isDevelopment = false;
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

    
    
    function setCommissioner(address _newCommissioner) public onlyCEO {
        require(_newCommissioner != address(0));

        commissionerAddress = _newCommissioner;
    }

    
    
    
    
    
    function setCLevelAddresses(address _ceo, address _cfo, address _coo, address _commish) public onlyCEO {
        require(_ceo != address(0));
        require(_cfo != address(0));
        require(_coo != address(0));
        require(_commish != address(0));
        ceoAddress = _ceo;
        cfoAddress = _cfo;
        cooAddress = _coo;
        commissionerAddress = _commish;
    }

    
    function withdrawBalance() external onlyCFO {
        cfoAddress.transfer(address(this).balance);
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
        paused = false;
    }
}


/// the mintPlayers(...) function
interface CSportsRosterInterface {

    
    function isLeagueRosterContract() external pure returns (bool);

    
    function commissionerAuctionComplete(uint32 _rosterIndex, uint128 _price) external;

    
    function commissionerAuctionCancelled(uint32 _rosterIndex) external view;

    
    function getMetadata(uint128 _md5Token) external view returns (string);

    
    function getRealWorldPlayerRosterIndex(uint128 _md5Token) external view returns (uint128);

    
    function realWorldPlayerFromIndex(uint128 idx) external view returns (uint128 md5Token, uint128 prevCommissionerSalePrice, uint64 lastMintedTime, uint32 mintedCount, bool hasActiveCommissionerAuction, bool mintingEnabled);

    
    function updateRealWorldPlayer(uint32 _rosterIndex, uint128 _prevCommissionerSalePrice, uint64 _lastMintedTime, uint32 _mintedCount, bool _hasActiveCommissionerAuction, bool _mintingEnabled) external;

}


/// contract. Also referenced by CSportsCore.

contract CSportsRosterPlayer {

    struct RealWorldPlayer {

        // The player's certified identification. This is the md5 hash of
        // {player's last name}-{player's first name}-{player's birthday in YYYY-MM-DD format}-{serial number}
        // where the serial number is usually 0, but gives us an ability to deal with making
        // sure all MD5s are unique.
        uint128 md5Token;

        // Stores the average sale price of the most recent 2 commissioner sales
        uint128 prevCommissionerSalePrice;

        // The last time this real world player was minted.
        uint64 lastMintedTime;

        // The number of PlayerTokens minted for this real world player
        uint32 mintedCount;

        // When true, there is an active auction for this player owned by
        // the commissioner (indicating a gen0 minting auction is in progress)
        bool hasActiveCommissionerAuction;

        // Indicates this real world player can be actively minted
        bool mintingEnabled;

        // Any metadata we want to attach to this player (in JSON format)
        string metadata;

    }

}



///   in implementing a contest.

contract CSportsTeam {

    bool public isTeamContract;

    
    event TeamCreated(uint256 teamId, address owner);
    event TeamUpdated(uint256 teamId);
    event TeamReleased(uint256 teamId);
    event TeamScored(uint256 teamId, int32 score, uint32 place);
    event TeamPaid(uint256 teamId);

    function setCoreContractAddress(address _address) public;
    function setLeagueRosterContractAddress(address _address) public;
    function setContestContractAddress(address _address) public;
    function createTeam(address _owner, uint32[] _tokenIds) public returns (uint32);
    function updateTeam(address _owner, uint32 _teamId, uint8[] _indices, uint32[] _tokenIds) public;
    function releaseTeam(uint32 _teamId) public;
    function getTeamOwner(uint32 _teamId) public view returns (address);
    function scoreTeams(uint32[] _teamIds, int32[] _scores, uint32[] _places) public;
    function getScore(uint32 _teamId) public view returns (int32);
    function getPlace(uint32 _teamId) public view returns (uint32);
    function ownsPlayerTokens(uint32 _teamId) public view returns (bool);
    function refunded(uint32 _teamId) public;
    function tokenIdsForTeam(uint32 _teamId) public view returns (uint32, uint32[50]);
    function getTeam(uint32 _teamId) public view returns (
        address _owner,
        int32 _score,
        uint32 _place,
        bool _holdsEntryFee,
        bool _ownsPlayerTokens);
}




contract CSportsBase is CSportsAuth, CSportsRosterPlayer {

    
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

    
    event CommissionerAuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);

    
    event CommissionerAuctionCanceled(uint256 tokenId);

    /******************/
    /*** DATA TYPES ***/
    /******************/

    
    ///  is represented by a single instance of this structure.
    struct PlayerToken {

      // @dev ID of the real world player this token represents. We can only have
      // a max of 4,294,967,295 real world players, which seems to be enough for
      // a while (haha)
      uint32 realWorldPlayerId;

      // @dev Serial number indicating the number of PlayerToken(s) for this
      //  same realWorldPlayerId existed at the time this token was minted.
      uint32 serialNumber;

      // The timestamp from the block when this player token was minted.
      uint64 mintedTime;

      // The most recent sale price of the player token in an auction
      uint128 mostRecentPrice;

    }

    /**************************/
    /*** MAPPINGS (STORAGE) ***/
    /**************************/

    
    /// PlayerTokens have an owner (newly minted PlayerTokens are owned by
    /// the core contract).
    mapping (uint256 => address) public playerTokenToOwner;

    
    mapping (uint256 => address) public playerTokenToApproved;

    // @dev A mapping to a given address' tokens
    mapping(address => uint32[]) public ownedTokens;

    // @dev A mapping that relates a token id to an index into the
    // ownedTokens[currentOwner] array.
    mapping(uint32 => uint32) tokenToOwnedTokensIndex;

    
    mapping(address => mapping(address => bool)) operators;

    // This mapping and corresponding uint16 represent marketing tokens
    // that can be created by the commissioner (up to remainingMarketingTokens)
    // and then given to third parties in the form of 4 words that sha256
    // hash into the key for the mapping.
    //
    // Maps uint256(keccak256) => leagueRosterPlayerMD5
    uint16 public remainingMarketingTokens = MAX_MARKETING_TOKENS;
    mapping (uint256 => uint128) marketingTokens;

    /***************/
    /*** STORAGE ***/
    /***************/

    
    ///   the CEO only once because this immutable tie to the league roster
    ///   is what relates a playerToken to a real world player. If we could
    ///   update the leagueRosterContract, we could in effect de-value the
    ///   ownership of a playerToken by switching the real world player it
    ///   represents.
    CSportsRosterInterface public leagueRosterContract;

    
    ///   tokens for contests.
    CSportsTeam public teamContract;

    
    PlayerToken[] public playerTokens;

    /************************************/
    /*** RESTRICTED C-LEVEL FUNCTIONS ***/
    /************************************/

    
    
    function setLeagueRosterContractAddress(address _address) public onlyCEO {
      // This method may only be called once to guarantee the immutable
      // nature of owning a real world player.
      if (!isDevelopment) {
        require(leagueRosterContract == address(0));
      }

      CSportsRosterInterface candidateContract = CSportsRosterInterface(_address);
      // NOTE: verify that a contract is what we expect (not foolproof, just
      // a sanity check)
      require(candidateContract.isLeagueRosterContract());
      // Set the new contract address
      leagueRosterContract = candidateContract;
    }

    
    ///   on behalf of a contest, and will return them to the original
    ///   owner when the contest is complete (or if entry is canceled by
    ///   the original owner, or if the contest is canceled).
    function setTeamContractAddress(address _address) public onlyCEO {
      CSportsTeam candidateContract = CSportsTeam(_address);
      // NOTE: verify that a contract is what we expect (not foolproof, just
      // a sanity check)
      require(candidateContract.isTeamContract());
      // Set the new contract address
      teamContract = candidateContract;
    }

    /**************************/
    /*** INTERNAL FUNCTIONS ***/
    /**************************/

    
    
    function _isContract(address addressToTest) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addressToTest)
        }
        return (size > 0);
    }

    
    
    function _tokenExists(uint256 _tokenId) internal view returns (bool) {
        return (_tokenId < playerTokens.length);
    }

    
    ///   in the playerTokens array.
    
    
    ///   that exist prior to this to-be-minted playerToken.
    
    function _mintPlayer(uint32 _realWorldPlayerId, uint32 _serialNumber, address _owner) internal returns (uint32) {
        // We are careful here to make sure the calling contract keeps within
        // our structure's size constraints. Highly unlikely we would ever
        // get to a point where these constraints would be a problem.
        require(_realWorldPlayerId < 4294967295);
        require(_serialNumber < 4294967295);

        PlayerToken memory _player = PlayerToken({
          realWorldPlayerId: _realWorldPlayerId,
          serialNumber: _serialNumber,
          mintedTime: uint64(now),
          mostRecentPrice: 0
        });

        uint256 newPlayerTokenId = playerTokens.push(_player) - 1;

        // It's probably never going to happen, 4 billion playerToken(s) is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(newPlayerTokenId < 4294967295);

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, newPlayerTokenId);

        return uint32(newPlayerTokenId);
    }

    
    /// tokenToOwnedTokensIndex mappings for a given address.
    
    
    function _removeTokenFrom(address _from, uint256 _tokenId) internal {

      // Grab the index into the _from owner's ownedTokens array
      uint32 fromIndex = tokenToOwnedTokensIndex[uint32(_tokenId)];

      // Remove the _tokenId from ownedTokens[_from] array
      uint lastIndex = ownedTokens[_from].length - 1;
      uint32 lastToken = ownedTokens[_from][lastIndex];

      // Swap the last token into the fromIndex position (which is _tokenId's
      // location in the ownedTokens array) and shorten the array
      ownedTokens[_from][fromIndex] = lastToken;
      ownedTokens[_from].length--;

      // Since we moved lastToken, we need to update its
      // entry in the tokenToOwnedTokensIndex
      tokenToOwnedTokensIndex[lastToken] = fromIndex;

      // _tokenId is no longer mapped
      tokenToOwnedTokensIndex[uint32(_tokenId)] = 0;

    }

    
    /// tokenToOwnedTokensIndex mappings for a given address.
    
    
    function _addTokenTo(address _to, uint256 _tokenId) internal {
      uint32 toIndex = uint32(ownedTokens[_to].push(uint32(_tokenId))) - 1;
      tokenToOwnedTokensIndex[uint32(_tokenId)] = toIndex;
    }

    
    
    
    
    function _transfer(address _from, address _to, uint256 _tokenId) internal {

        // transfer ownership
        playerTokenToOwner[_tokenId] = _to;

        // When minting brand new PlayerTokens, the _from is 0x0, but we don't deal with
        // owned tokens for the 0x0 address.
        if (_from != address(0)) {

            // Remove the _tokenId from ownedTokens[_from] array (remove first because
            // this method will zero out the tokenToOwnedTokensIndex[_tokenId], which would
            // stomp on the _addTokenTo setting of this value)
            _removeTokenFrom(_from, _tokenId);

            // Clear our approved mapping for this token
            delete playerTokenToApproved[_tokenId];
        }

        // Now add the token to the _to address' ownership structures
        _addTokenTo(_to, _tokenId);

        // Emit the transfer event.
        emit Transfer(_from, _to, _tokenId);
    }

    
    
    function uintToString(uint v) internal pure returns (string str) {
      bytes32 b32 = uintToBytes32(v);
      str = bytes32ToString(b32);
    }

    
    
    function uintToBytes32(uint v) internal pure returns (bytes32 ret) {
        if (v == 0) {
            ret = '0';
        }
        else {
            while (v > 0) {
                ret = bytes32(uint(ret) / (2 ** 8));
                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
                v /= 10;
            }
        }
        return ret;
    }

    
    
    function bytes32ToString (bytes32 data) internal pure returns (string) {

        uint count = 0;
        bytes memory bytesString = new bytes(32); //  = new bytes[]; //(32);
        for (uint j=0; j<32; j++) {
            byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[j] = char;
                count++;
            } else {
              break;
            }
        }

        bytes memory s = new bytes(count);
        for (j = 0; j < count; j++) {
            s[j] = bytesString[j];
        }
        return string(s);

    }

}



///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface ERC721 /* is ERC165 */ {
    
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    ///
    /// MOVED THIS TO CSportsBase because of how class structure is derived.
    ///
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    
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
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    
    
    
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;

    
    
    ///  except this function just sets data to "".
    
    
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    
    
    
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    
    
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    
    
    function approve(address _approved, uint256 _tokenId) external payable;

    
    ///  all of `msg.sender`'s assets
    
    ///  multiple operators per owner.
    
    
    function setApprovalForAll(address _operator, bool _approved) external;

    
    
    
    
    function getApproved(uint256 _tokenId) external view returns (address);

    
    
    
    
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}



///  Note: the ERC-165 identifier for this interface is 0x5b5e139f.
interface ERC721Metadata /* is ERC721 */ {
    
    function name() external view returns (string _name);

    
    function symbol() external view returns (string _symbol);

    
    
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function tokenURI(uint256 _tokenId) external view returns (string);
}



///  Note: the ERC-165 identifier for this interface is 0x780e9d63.
interface ERC721Enumerable /* is ERC721 */ {
    
    
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256);

    
    
    
    
    ///  (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (uint256);

    
    
    ///  `_owner` is the zero address, representing invalid NFTs.
    
    
    
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}


interface ERC721TokenReceiver {
    
    
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    
    
    
    
    
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);
}

interface ERC165 {
    
    
    
    ///  uses less than 30,000 gas.
    
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}




/// See the CSportsCore contract documentation to understand how the various contract facets are arranged.
contract CSportsOwnership is CSportsBase {

  
  string _name;
  string _symbol;
  string _tokenURI;

  // bool public implementsERC721 = true;
  //
  function implementsERC721() public pure returns (bool)
  {
      return true;
  }

  
  function name() external view returns (string) {
    return _name;
  }

  
  function symbol() external view returns (string) {
    return _symbol;
  }

  
  
  ///  3986. The URI may point to a JSON file that conforms to the "ERC721
  ///  Metadata JSON Schema".
  function tokenURI(uint256 _tokenId) external view returns (string ret) {
    string memory tokenIdAsString = uintToString(uint(_tokenId));
    ret = string (abi.encodePacked(_tokenURI, tokenIdAsString, "/"));
  }

  
  
  ///  about them do throw.
  
  
  function ownerOf(uint256 _tokenId)
      public
      view
      returns (address owner)
  {
      owner = playerTokenToOwner[_tokenId];
      require(owner != address(0));
  }

  
  
  ///  function throws for queries about the zero address.
  
  
  function balanceOf(address _owner) public view returns (uint256 count) {
      // I am not a big fan of  referencing a property on an array element
      // that may not exist. But if it does not exist, Solidity will return 0
      // which is right.
      return ownedTokens[_owner].length;
  }

  
  ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
  ///  THEY MAY BE PERMANENTLY LOST
  
  ///  operator, or the approved address for this NFT. Throws if `_from` is
  ///  not the current owner. Throws if `_to` is the zero address. Throws if
  ///  `_tokenId` is not a valid NFT.
  
  
  
  function transferFrom(
      address _from,
      address _to,
      uint256 _tokenId
  )
      public
      whenNotPaused
  {
      require(_to != address(0));
      require (_tokenExists(_tokenId));

      // Check for approval and valid ownership
      require(_approvedFor(_to, _tokenId));
      require(_owns(_from, _tokenId));

      // Validate the sender
      require(_owns(msg.sender, _tokenId) || // sender owns the token
             (msg.sender == playerTokenToApproved[_tokenId]) || // sender is the approved address
             operators[_from][msg.sender]); // sender is an authorized operator for this token

      // Reassign ownership (also clears pending approvals and emits Transfer event).
      _transfer(_from, _to, _tokenId);
  }

  
  ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
  ///  THEY MAY BE PERMANENTLY LOST
  
  ///  operator, or the approved address for all NFTs. Throws if `_from` is
  ///  not the current owner. Throws if `_to` is the zero address. Throws if
  ///  any `_tokenId` is not a valid NFT.
  
  
  
  function batchTransferFrom(
        address _from,
        address _to,
        uint32[] _tokenIds
  )
  public
  whenNotPaused
  {
    for (uint32 i = 0; i < _tokenIds.length; i++) {

        uint32 _tokenId = _tokenIds[i];

        // Check for approval and valid ownership
        require(_approvedFor(_to, _tokenId));
        require(_owns(_from, _tokenId));

        // Validate the sender
        require(_owns(msg.sender, _tokenId) || // sender owns the token
        (msg.sender == playerTokenToApproved[_tokenId]) || // sender is the approved address
        operators[_from][msg.sender]); // sender is an authorized operator for this token

        // Reassign ownership, clear pending approvals (not necessary here),
        // and emit Transfer event.
        _transfer(_from, _to, _tokenId);
    }
  }

  
  
  ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
  ///  operator of the current owner.
  
  
  function approve(
      address _to,
      uint256 _tokenId
  )
      public
      whenNotPaused
  {
      address owner = ownerOf(_tokenId);
      require(_to != owner);

      // Only an owner or authorized operator can grant transfer approval.
      require((msg.sender == owner) || (operators[ownerOf(_tokenId)][msg.sender]));

      // Register the approval (replacing any previous approval).
      _approve(_tokenId, _to);

      // Emit approval event.
      emit Approval(msg.sender, _to, _tokenId);
  }

  
  
  /// Throws unless `msg.sender` is the current NFT owner, or an authorized
  /// operator of the current owner.
  
  ///  clear all approvals.
  
  function batchApprove(
        address _to,
        uint32[] _tokenIds
  )
  public
  whenNotPaused
  {
    for (uint32 i = 0; i < _tokenIds.length; i++) {

        uint32 _tokenId = _tokenIds[i];

        // Only an owner or authorized operator can grant transfer approval.
        require(_owns(msg.sender, _tokenId) || (operators[ownerOf(_tokenId)][msg.sender]));

        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        emit Approval(msg.sender, _to, _tokenId);
    }
  }

  
  ///   to the teamContract. CAN ONLY BE CALLED BY THE CURRENT TEAM CONTRACT.
  
  
  function batchEscrowToTeamContract(
    address _owner,
    uint32[] _tokenIds
  )
    public
    whenNotPaused
  {
    require(teamContract != address(0));
    require(msg.sender == address(teamContract));

    for (uint32 i = 0; i < _tokenIds.length; i++) {

      uint32 _tokenId = _tokenIds[i];

      // Only an owner can transfer the token.
      require(_owns(_owner, _tokenId));

      // Reassign ownership, clear pending approvals (not necessary here),
      // and emit Transfer event.
      _transfer(_owner, teamContract, _tokenId);
    }
  }

  bytes4 constant TOKEN_RECEIVED_SIG = bytes4(keccak256("onERC721Received(address,uint256,bytes)"));

  
  
  ///  operator, or the approved address for this NFT. Throws if `_from` is
  ///  not the current owner. Throws if `_to` is the zero address. Throws if
  ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
  ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
  ///  `onERC721Received` on `_to` and throws if the return value is not
  ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
  
  
  
  
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable {
    transferFrom(_from, _to, _tokenId);
    if (_isContract(_to)) {
        ERC721TokenReceiver receiver = ERC721TokenReceiver(_to);
        bytes4 response = receiver.onERC721Received.gas(50000)(msg.sender, _from, _tokenId, data);
        require(response == TOKEN_RECEIVED_SIG);
    }
  }

  
  
  ///  except this function just sets data to "".
  
  
  
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
    require(_to != address(0));
    transferFrom(_from, _to, _tokenId);
    if (_isContract(_to)) {
        ERC721TokenReceiver receiver = ERC721TokenReceiver(_to);
        bytes4 response = receiver.onERC721Received.gas(50000)(msg.sender, _from, _tokenId, "");
        require(response == TOKEN_RECEIVED_SIG);
    }
  }

  
  
  ///  them has an assigned and queryable owner not equal to the zero address
  function totalSupply() public view returns (uint) {
      return playerTokens.length;
  }

  
  
  ///  `owner` is the zero address, representing invalid NFTs.
  
  
  
  ///   (sort order not specified)
  function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 _tokenId) {
      require(owner != address(0));
      require(index < balanceOf(owner));
      return ownedTokens[owner][index];
  }

  
  
  
  
  ///  (sort order not specified)
  function tokenByIndex(uint256 index) external view returns (uint256) {
      require (_tokenExists(index));
      return index;
  }

  
  ///  all of `msg.sender`'s assets
  
  ///  multiple operators per owner.
  
  
  function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != msg.sender);
        operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  
  
  
  
  function getApproved(uint256 _tokenId) external view returns (address) {
      require(_tokenExists(_tokenId));
      return playerTokenToApproved[_tokenId];
  }

  
  
  
  ///  uses less than 30,000 gas.
  
  ///  `interfaceID` is not 0xffffffff, `false` otherwise
  function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
      return (
          interfaceID == this.supportsInterface.selector || // ERC165
          interfaceID == 0x5b5e139f || // ERC721Metadata
          interfaceID == 0x80ac58cd || // ERC-721
          interfaceID == 0x780e9d63);  // ERC721Enumerable
  }

  // Internal utility functions: These functions all assume that their input arguments
  // are valid. We leave it to public methods to sanitize their inputs and follow
  // the required logic.

  
  
  
  function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
      return playerTokenToOwner[_tokenId] == _claimant;
  }

  
  
  
  function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
      return playerTokenToApproved[_tokenId] == _claimant;
  }

  
  ///  approval. Setting _approved to address(0) clears all transfer approval.
  ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
  ///  _approve() and transferFrom() are used together for putting PlayerToken on auction, and
  ///  there is no value in spamming the log with Approval events in that case.
  function _approve(uint256 _tokenId, address _approved) internal {
      playerTokenToApproved[_tokenId] = _approved;
  }

}


interface CSportsAuctionInterface {

    
    ///  right auction in our setSaleAuctionAddress() call.
    function isSaleClockAuction() external pure returns (bool);

    
    
    
    
    
    
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    ) external;

    
    /// being auctioned by this contract.
    
    
    
    
    
    function repriceAuctions(
        uint256[] _tokenIds,
        uint256[] _startingPrices,
        uint256[] _endingPrices,
        uint256 _duration,
        address _seller
    ) external;

    
    ///   the super(...) and then notifying any listener.
    
    function cancelAuction(uint256 _tokenId) external;

    
    function withdrawBalance() external;

}


contract SaleClockAuctionListener {
    function implementsSaleClockAuctionListener() public pure returns (bool);
    function auctionCreated(uint256 tokenId, address seller, uint128 startingPrice, uint128 endingPrice, uint64 duration) public;
    function auctionSuccessful(uint256 tokenId, uint128 totalPrice, address seller, address buyer) public;
    function auctionCancelled(uint256 tokenId, address seller) public;
}



/// See the CSportsCore contract documentation to understand how the various contract facets are arranged.
contract CSportsAuction is CSportsOwnership, SaleClockAuctionListener {

  // Holds a reference to our saleClockAuctionContract
  CSportsAuctionInterface public saleClockAuctionContract;

  
  function implementsSaleClockAuctionListener() public pure returns (bool) {
    return true;
  }

  
  function auctionCreated(uint256 /* tokenId */, address /* seller */, uint128 /* startingPrice */, uint128 /* endingPrice */, uint64 /* duration */) public {
    require (saleClockAuctionContract != address(0));
    require (msg.sender == address(saleClockAuctionContract));
  }

  
  
  
  
  
  function auctionSuccessful(uint256 tokenId, uint128 totalPrice, address seller, address winner) public {
    require (saleClockAuctionContract != address(0));
    require (msg.sender == address(saleClockAuctionContract));

    // Record the most recent sale price to the token
    PlayerToken storage _playerToken = playerTokens[tokenId];
    _playerToken.mostRecentPrice = totalPrice;

    if (seller == address(this)) {
      // We completed a commissioner auction!
      leagueRosterContract.commissionerAuctionComplete(playerTokens[tokenId].realWorldPlayerId, totalPrice);
      emit CommissionerAuctionSuccessful(tokenId, totalPrice, winner);
    }
  }

  
  
  
  function auctionCancelled(uint256 tokenId, address seller) public {
    require (saleClockAuctionContract != address(0));
    require (msg.sender == address(saleClockAuctionContract));
    if (seller == address(this)) {
      // We cancelled a commissioner auction!
      leagueRosterContract.commissionerAuctionCancelled(playerTokens[tokenId].realWorldPlayerId);
      emit CommissionerAuctionCanceled(tokenId);
    }
  }

  
  
  function setSaleAuctionContractAddress(address _address) public onlyCEO {

      require(_address != address(0));

      CSportsAuctionInterface candidateContract = CSportsAuctionInterface(_address);

      // Sanity check
      require(candidateContract.isSaleClockAuction());

      // Set the new contract address
      saleClockAuctionContract = candidateContract;

  }

  
  ///   by this contract)
  function cancelCommissionerAuction(uint32 tokenId) public onlyCommissioner {
    require(saleClockAuctionContract != address(0));
    saleClockAuctionContract.cancelAuction(tokenId);
  }

  
  ///   player token being put up for auction.
  
  
  
  
  function createSaleAuction(
      uint256 _playerTokenId,
      uint256 _startingPrice,
      uint256 _endingPrice,
      uint256 _duration
  )
      public
      whenNotPaused
  {
      // Auction contract checks input sizes
      // If player is already on any auction, this will throw
      // because it will be owned by the auction contract.
      require(_owns(msg.sender, _playerTokenId));
      _approve(_playerTokenId, saleClockAuctionContract);

      // saleClockAuctionContract.createAuction throws if inputs are invalid and clears
      // transfer after escrowing the player.
      saleClockAuctionContract.createAuction(
          _playerTokenId,
          _startingPrice,
          _endingPrice,
          _duration,
          msg.sender
      );
  }

  
  /// to the CSportsCore contract. We use two-step withdrawal to
  /// avoid two transfer calls in the auction bid function.
  /// To withdraw from this CSportsCore contract, the CFO must call
  /// the withdrawBalance(...) function defined in CSportsAuth.
  function withdrawAuctionBalances() external onlyCOO {
      saleClockAuctionContract.withdrawBalance();
  }
}



/// See the CSportsCore contract documentation to understand how the various contract facets are arranged.
contract CSportsMinting is CSportsAuction {

  
  event MarketingTokenRedeemed(uint256 hash, uint128 rwpMd5, address indexed recipient);

  
  event MarketingTokenCreated(uint256 hash, uint128 rwpMd5);

  
  event MarketingTokenReplaced(uint256 oldHash, uint256 newHash, uint128 rwpMd5);

  
  function isMinter() public pure returns (bool) {
      return true;
  }

  
  /// the exact algorythm used by Solidity.
  function getKeccak256(string stringToHash) public pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(stringToHash)));
  }

  
  /// MAX_MARKETING_TOKENS marketing tokens that can be created if one knows the words
  /// to keccak256 and match the keywordHash passed here. Use web3.utils.soliditySha3(param1 [, param2, ...])
  /// to create this hash.
  ///
  /// ONLY THE COMMISSIONER CAN CREATE MARKETING TOKENS, AND ONLY UP TO MAX_MARKETING_TOKENS OF THEM
  ///
  
  
  /// player token that will be minted and transfered by the redeemMarketingToken(...) method.
  function addMarketingToken(uint256 keywordHash, uint128 md5Token) public onlyCommissioner {

    require(remainingMarketingTokens > 0);
    require(marketingTokens[keywordHash] == 0);

    // Make sure the md5Token exists in the league roster
    uint128 _rosterIndex = leagueRosterContract.getRealWorldPlayerRosterIndex(md5Token);
    require(_rosterIndex != 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

    // Map the keyword Hash to the RWP md5 and decrement the remainingMarketingTokens property
    remainingMarketingTokens--;
    marketingTokens[keywordHash] = md5Token;

    emit MarketingTokenCreated(keywordHash, md5Token);

  }

  
  /// not been used with a new one (new hash and mdt). Since we are replacing, we co not
  /// have to deal with remainingMarketingTokens in any way. This is to allow for replacing
  /// marketing tokens that have not been redeemed and aren't likely to be redeemed (breakage)
  ///
  /// ONLY THE COMMISSIONER CAN ACCESS THIS METHOD
  ///
  
  
  
  function replaceMarketingToken(uint256 oldKeywordHash, uint256 newKeywordHash, uint128 md5Token) public onlyCommissioner {

    uint128 _md5Token = marketingTokens[oldKeywordHash];
    if (_md5Token != 0) {
      marketingTokens[oldKeywordHash] = 0;
      marketingTokens[newKeywordHash] = md5Token;
      emit MarketingTokenReplaced(oldKeywordHash, newKeywordHash, md5Token);
    }

  }

  
  /// value means the keyword string parameter isn't mapped to a marketing token.
  
  //
  /// ANYONE CAN VALIDATE A KEYWORD STRING (MAP IT TO AN MD5 IF IT HAS ONE)
  ///
  
  /// mapping (or not)
  function MD5FromMarketingKeywords(string keyWords) public view returns (uint128) {
    uint256 keyWordsHash = uint256(keccak256(abi.encodePacked(keyWords)));
    uint128 _md5Token = marketingTokens[keyWordsHash];
    return _md5Token;
  }

  
  /// be SHA256'ed to match an entry in our marketingTokens mapping. If a match is found,
  /// a CryptoSports token is created that corresponds to the md5 retrieved
  /// from the marketingTokens mapping and its owner is assigned as the msg.sender.
  ///
  /// ANYONE CAN REDEEM A MARKETING token
  ///
  
  function redeemMarketingToken(string keyWords) public {

    uint256 keyWordsHash = uint256(keccak256(abi.encodePacked(keyWords)));
    uint128 _md5Token = marketingTokens[keyWordsHash];
    if (_md5Token != 0) {

      // Only one redemption per set of keywords
      marketingTokens[keyWordsHash] = 0;

      uint128 _rosterIndex = leagueRosterContract.getRealWorldPlayerRosterIndex(_md5Token);
      if (_rosterIndex != 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) {

        // Grab the real world player record from the leagueRosterContract
        RealWorldPlayer memory _rwp;
        (_rwp.md5Token, _rwp.prevCommissionerSalePrice, _rwp.lastMintedTime, _rwp.mintedCount, _rwp.hasActiveCommissionerAuction, _rwp.mintingEnabled) =  leagueRosterContract.realWorldPlayerFromIndex(_rosterIndex);

        // Mint this player, sending it to the message sender
        _mintPlayer(uint32(_rosterIndex), _rwp.mintedCount, msg.sender);

        // Finally, update our realWorldPlayer record to reflect the fact that we just
        // minted a new one, and there is an active commish auction. The only portion of
        // the RWP record we change here is an update to the mingedCount.
        leagueRosterContract.updateRealWorldPlayer(uint32(_rosterIndex), _rwp.prevCommissionerSalePrice, uint64(now), _rwp.mintedCount + 1, _rwp.hasActiveCommissionerAuction, _rwp.mintingEnabled);

        emit MarketingTokenRedeemed(keyWordsHash, _rwp.md5Token, msg.sender);
      }

    }
  }

  
  /// specified by their MD5s.
  
  function minStartPriceForCommishAuctions(uint128[] _md5Tokens) public view onlyCommissioner returns (uint128[50]) {
    require (_md5Tokens.length <= 50);
    uint128[50] memory minPricesArray;
    for (uint32 i = 0; i < _md5Tokens.length; i++) {
        uint128 _md5Token = _md5Tokens[i];
        uint128 _rosterIndex = leagueRosterContract.getRealWorldPlayerRosterIndex(_md5Token);
        if (_rosterIndex == 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) {
          // Cannot mint a non-existent real world player
          continue;
        }
        RealWorldPlayer memory _rwp;
        (_rwp.md5Token, _rwp.prevCommissionerSalePrice, _rwp.lastMintedTime, _rwp.mintedCount, _rwp.hasActiveCommissionerAuction, _rwp.mintingEnabled) =  leagueRosterContract.realWorldPlayerFromIndex(_rosterIndex);

        // Skip this if there is no player associated with the md5 specified
        if (_rwp.md5Token != _md5Token) continue;

        minPricesArray[i] = uint128(_computeNextCommissionerPrice(_rwp.prevCommissionerSalePrice));
    }
    return minPricesArray;
  }

  
  ///   can only be called by the commissioner, and checks to make sure certian minting
  ///   conditions are met (reverting if not met):
  ///     * The MD5 of the RWP specified must exist in the CSportsLeagueRoster contract
  ///     * Cannot mint a realWorldPlayer that currently has an active commissioner auction
  ///     * Cannot mint realWorldPlayer that does not have minting enabled
  ///     * Cannot mint realWorldPlayer with a start price exceeding our minimum
  ///   If any of the above conditions fails to be met, then no player tokens will be
  ///   minted.
  ///
  /// *** ONLY THE COMMISSIONER OR THE LEAGUE ROSTER CONTRACT CAN CALL THIS FUNCTION ***
  ///
  
  
  function mintPlayers(uint128[] _md5Tokens, uint256 _startPrice, uint256 _endPrice, uint256 _duration) public {

    require(leagueRosterContract != address(0));
    require(saleClockAuctionContract != address(0));
    require((msg.sender == commissionerAddress) || (msg.sender == address(leagueRosterContract)));

    for (uint32 i = 0; i < _md5Tokens.length; i++) {
      uint128 _md5Token = _md5Tokens[i];
      uint128 _rosterIndex = leagueRosterContract.getRealWorldPlayerRosterIndex(_md5Token);
      if (_rosterIndex == 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) {
        // Cannot mint a non-existent real world player
        continue;
      }

      // We don't have to check _rosterIndex here because the getRealWorldPlayerRosterIndex(...)
      // method always returns a valid index.
      RealWorldPlayer memory _rwp;
      (_rwp.md5Token, _rwp.prevCommissionerSalePrice, _rwp.lastMintedTime, _rwp.mintedCount, _rwp.hasActiveCommissionerAuction, _rwp.mintingEnabled) =  leagueRosterContract.realWorldPlayerFromIndex(_rosterIndex);

      if (_rwp.md5Token != _md5Token) continue;
      if (!_rwp.mintingEnabled) continue;

      // Enforce the restrictions that there can ever only be a single outstanding commissioner
      // auction - no new minting if there is an active commissioner auction for this real world player
      if (_rwp.hasActiveCommissionerAuction) continue;

      // Ensure that our price is not less than a minimum
      uint256 _minStartPrice = _computeNextCommissionerPrice(_rwp.prevCommissionerSalePrice);

      // Make sure the start price exceeds our minimum acceptable
      if (_startPrice < _minStartPrice) {
          _startPrice = _minStartPrice;
      }

      // Mint the new player token
      uint32 _playerId = _mintPlayer(uint32(_rosterIndex), _rwp.mintedCount, address(this));

      // @dev Approve ownership transfer to the saleClockAuctionContract (which is required by
      //  the createAuction(...) which will escrow the playerToken)
      _approve(_playerId, saleClockAuctionContract);

      // Apply the default duration
      if (_duration == 0) {
        _duration = COMMISSIONER_AUCTION_DURATION;
      }

      // By setting our _endPrice to zero, we become immune to the USD <==> ether
      // conversion rate. No matter how high ether goes, our auction price will get
      // to a USD value that is acceptable to someone (assuming 0 is acceptable that is).
      // This also helps for players that aren't in very much demand.
      saleClockAuctionContract.createAuction(
          _playerId,
          _startPrice,
          _endPrice,
          _duration,
          address(this)
      );

      // Finally, update our realWorldPlayer record to reflect the fact that we just
      // minted a new one, and there is an active commish auction.
      leagueRosterContract.updateRealWorldPlayer(uint32(_rosterIndex), _rwp.prevCommissionerSalePrice, uint64(now), _rwp.mintedCount + 1, true, _rwp.mintingEnabled);
    }
  }

  
  /// being auctioned by this contract. Since this function can only be called by
  /// the commissioner, we don't do a lot of checking of parameters and things.
  /// The SaleClockAuction's repriceAuctions method assures that the CSportsCore
  /// contract is the "seller" of the token (meaning it is a commissioner auction).
  
  
  
  
  function repriceAuctions(
      uint256[] _tokenIds,
      uint256[] _startingPrices,
      uint256[] _endingPrices,
      uint256 _duration
  ) external onlyCommissioner {

      // We cannot reprice below our player minimum
      for (uint32 i = 0; i < _tokenIds.length; i++) {
          uint32 _tokenId = uint32(_tokenIds[i]);
          PlayerToken memory pt = playerTokens[_tokenId];
          RealWorldPlayer memory _rwp;
          (_rwp.md5Token, _rwp.prevCommissionerSalePrice, _rwp.lastMintedTime, _rwp.mintedCount, _rwp.hasActiveCommissionerAuction, _rwp.mintingEnabled) = leagueRosterContract.realWorldPlayerFromIndex(pt.realWorldPlayerId);
          uint256 _minStartPrice = _computeNextCommissionerPrice(_rwp.prevCommissionerSalePrice);

          // We require the price to be >= our _minStartPrice
          require(_startingPrices[i] >= _minStartPrice);
      }

      // Note we pass in this CSportsCore contract address as the seller, making sure the only auctions
      // that can be repriced by this method are commissioner auctions.
      saleClockAuctionContract.repriceAuctions(_tokenIds, _startingPrices, _endingPrices, _duration, address(this));
  }

  
  ///   that is owned by the core contract. Can only be called when not paused
  ///   and only by the commissioner
  
  
  
  
  function createCommissionerAuction(uint32 _playerTokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration)
        public whenNotPaused onlyCommissioner {

        require(leagueRosterContract != address(0));
        require(_playerTokenId < playerTokens.length);

        // If player is already on any auction, this will throw because it will not be owned by
        // this CSportsCore contract (as all commissioner tokens are if they are not currently
        // on auction).
        // Any token owned by the CSportsCore contract by definition is a commissioner auction
        // that was canceled which makes it OK to re-list.
        require(_owns(address(this), _playerTokenId));

        // (1) Grab the real world token ID (md5)
        PlayerToken memory pt = playerTokens[_playerTokenId];

        // (2) Get the full real world player record from its roster index
        RealWorldPlayer memory _rwp;
        (_rwp.md5Token, _rwp.prevCommissionerSalePrice, _rwp.lastMintedTime, _rwp.mintedCount, _rwp.hasActiveCommissionerAuction, _rwp.mintingEnabled) = leagueRosterContract.realWorldPlayerFromIndex(pt.realWorldPlayerId);

        // Ensure that our starting price is not less than a minimum
        uint256 _minStartPrice = _computeNextCommissionerPrice(_rwp.prevCommissionerSalePrice);
        if (_startingPrice < _minStartPrice) {
            _startingPrice = _minStartPrice;
        }

        // Apply the default duration
        if (_duration == 0) {
            _duration = COMMISSIONER_AUCTION_DURATION;
        }

        // Approve the token for transfer
        _approve(_playerTokenId, saleClockAuctionContract);

        // saleClockAuctionContract.createAuction throws if inputs are invalid and clears
        // transfer after escrowing the player.
        saleClockAuctionContract.createAuction(
            _playerTokenId,
            _startingPrice,
            _endingPrice,
            _duration,
            address(this)
        );
  }

  
  ///  the previous real world player sale price + 25% (with a floor).
  function _computeNextCommissionerPrice(uint128 prevTwoCommissionerSalePriceAve) internal view returns (uint256) {

      uint256 nextPrice = prevTwoCommissionerSalePriceAve + (prevTwoCommissionerSalePriceAve / 4);

      // sanity check to ensure we don't overflow arithmetic (this big number is 2^128-1).
      if (nextPrice > 340282366920938463463374607431768211455) {
        nextPrice = 340282366920938463463374607431768211455;
      }

      // We never auction for less than our floor
      if (nextPrice < COMMISSIONER_AUCTION_FLOOR_PRICE) {
          nextPrice = COMMISSIONER_AUCTION_FLOOR_PRICE;
      }

      return nextPrice;
  }

}




/// break the code down into meaningful amounts of related functions in
/// single files, as opposed to having one big file. The purpose of
/// each facet is given here:
///
///   CSportsConstants - This facet holds constants used throughout.
///   CSportsAuth -
///   CSportsBase -
///   CSportsOwnership -
///   CSportsAuction -
///   CSportsMinting -
///   CSportsCore - This is the main CSports constract implementing the CSports
///         Fantash Football League. It manages contract upgrades (if / when
///         they might occur), and has generally useful helper methods.
///
/// This CSportsCore contract interacts with the CSportsLeagueRoster contract
/// to determine which PlayerTokens to mint.
///
/// This CSportsCore contract interacts with the TimeAuction contract
/// to implement and run PlayerToken auctions (sales).
contract CSportsCore is CSportsMinting {

  
  bool public isCoreContract = true;

  // Set if (hopefully not) the core contract needs to be upgraded. Can be
  // set by the CEO but only when paused. When successfully set, we can never
  // unpause this contract. See the unpause() method overridden by this class.
  address public newContractAddress;

  
  
  
  
  constructor(string nftName, string nftSymbol, string nftTokenURI) public {

      // New contract starts paused.
      paused = true;

      
      _name = nftName;
      _symbol = nftSymbol;
      _tokenURI = nftTokenURI;

      // All C-level roles are the message sender
      ceoAddress = msg.sender;
      cfoAddress = msg.sender;
      cooAddress = msg.sender;
      commissionerAddress = msg.sender;

  }

  
  function() external payable {
    /*require(
        msg.sender == address(saleClockAuctionContract)
    );*/
  }

  /// --------------------------------------------------------------------------- ///
  /// ----------------------------- PUBLIC FUNCTIONS ---------------------------- ///
  /// --------------------------------------------------------------------------- ///

  
  ///  bug. This method does nothing but keep track of the new contract and
  ///  emit a message indicating that the new address is set. It's up to clients of this
  ///  contract to update to the new contract address in that case. (This contract will
  ///  be paused indefinitely if such an upgrade takes place.)
  
  function upgradeContract(address _v2Address) public onlyCEO whenPaused {
      newContractAddress = _v2Address;
      emit ContractUpgrade(_v2Address);
  }

  
  ///  to be set before contract can be unpaused. Also require that we have
  ///  set a valid season and the contract has not been upgraded.
  function unpause() public onlyCEO whenPaused {
      require(leagueRosterContract != address(0));
      require(saleClockAuctionContract != address(0));
      require(newContractAddress == address(0));

      // Actually unpause the contract.
      super.unpause();
  }

  
  function setLeagueRosterAndSaleAndTeamContractAddress(address _leagueAddress, address _saleAddress, address _teamAddress) public onlyCEO {
      setLeagueRosterContractAddress(_leagueAddress);
      setSaleAuctionContractAddress(_saleAddress);
      setTeamContractAddress(_teamAddress);
  }

  
  
  function getPlayerToken(uint32 _playerTokenID) public view returns (
      uint32 realWorldPlayerId,
      uint32 serialNumber,
      uint64 mintedTime,
      uint128 mostRecentPrice) {
    require(_playerTokenID < playerTokens.length);
    PlayerToken storage pt = playerTokens[_playerTokenID];
    realWorldPlayerId = pt.realWorldPlayerId;
    serialNumber = pt.serialNumber;
    mostRecentPrice = pt.mostRecentPrice;
    mintedTime = pt.mintedTime;
  }

  
  
  function realWorldPlayerTokenForPlayerTokenId(uint32 _playerTokenID) public view returns (uint128 md5Token) {
      require(_playerTokenID < playerTokens.length);
      PlayerToken storage pt = playerTokens[_playerTokenID];
      RealWorldPlayer memory _rwp;
      (_rwp.md5Token, _rwp.prevCommissionerSalePrice, _rwp.lastMintedTime, _rwp.mintedCount, _rwp.hasActiveCommissionerAuction, _rwp.mintingEnabled) = leagueRosterContract.realWorldPlayerFromIndex(pt.realWorldPlayerId);
      md5Token = _rwp.md5Token;
  }

  
  
  function realWorldPlayerMetadataForPlayerTokenId(uint32 _playerTokenID) public view returns (string metadata) {
      require(_playerTokenID < playerTokens.length);
      PlayerToken storage pt = playerTokens[_playerTokenID];
      RealWorldPlayer memory _rwp;
      (_rwp.md5Token, _rwp.prevCommissionerSalePrice, _rwp.lastMintedTime, _rwp.mintedCount, _rwp.hasActiveCommissionerAuction, _rwp.mintingEnabled) = leagueRosterContract.realWorldPlayerFromIndex(pt.realWorldPlayerId);
      metadata = leagueRosterContract.getMetadata(_rwp.md5Token);
  }

  /// --------------------------------------------------------------------------- ///
  /// ------------------------- RESTRICTED FUNCTIONS ---------------------------- ///
  /// --------------------------------------------------------------------------- ///

  
  ///   called by the CEO and is used in development stage only as it is only needed by our test suite.
  
  
  
  
  
  
  function updateRealWorldPlayer(uint32 _rosterIndex, uint128 _prevCommissionerSalePrice, uint64 _lastMintedTime, uint32 _mintedCount, bool _hasActiveCommissionerAuction, bool _mintingEnabled) public onlyCEO onlyUnderDevelopment {
    require(leagueRosterContract != address(0));
    leagueRosterContract.updateRealWorldPlayer(_rosterIndex, _prevCommissionerSalePrice, _lastMintedTime, _mintedCount, _hasActiveCommissionerAuction, _mintingEnabled);
  }

}