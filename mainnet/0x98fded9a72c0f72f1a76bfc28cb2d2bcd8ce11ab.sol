
pragma solidity ^0.4.25;


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




contract CSportsContestBase {

    
    struct Team {
      address owner;              // Address of the owner of the player tokens
      int32 score;                // Score assigned to this team after a contest
      uint32 place;               // Place this team finished in its contest
      bool holdsEntryFee;         // TRUE if this team currently holds an entry fee
      bool ownsPlayerTokens;      // True if the tokens are being escrowed by the Team contract
      uint32[] playerTokenIds;    // IDs of the tokens held by this team
    }

}


/// the mintPlayers(...) function
interface CSportsCoreInterface {

    
    function isCoreContract() external pure returns (bool);

    
    ///   to the teamContract. CAN ONLY BE CALLED BY THE CURRENT TEAM CONTRACT.
    
    
    function batchEscrowToTeamContract(address _owner, uint32[] _tokenIds) external;

    
    
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    
    
    function approve(address _to, uint256 _tokenId) external;

    
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    
    
    
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
}


/// that supports a variable # players per team (set in constructor)
contract CSportsTeamGeneric is CSportsAuth, CSportsTeam,  CSportsContestBase {

  /// STORAGE

  
  CSportsCoreInterface public coreContract;

  
  address public contestContractAddress;

  
  ///   the CEO.
  CSportsRosterInterface public leagueRosterContract;

  // Next team ID to assign
  uint64 uniqueTeamId;

  // Number of players on a team
  uint32 playersPerTeam;

  
  mapping (uint32 => Team) teamIdToTeam;

  /// PUBLIC METHODS

  
  constructor(uint32 _playersPerTeam) public {

      // All C-level roles are the message sender
      ceoAddress = msg.sender;
      cfoAddress = msg.sender;
      cooAddress = msg.sender;
      commissionerAddress = msg.sender;

      // Notice our uniqueTeamId starts at 1, making a 0 value indicate
      // a non-existent team.
      uniqueTeamId = 1;

      // Initialize parent properties
      isTeamContract = true;

      // Players per team
      playersPerTeam = _playersPerTeam;
  }

  
  
  function setContestContractAddress(address _address) public onlyCEO {
    contestContractAddress = _address;
  }

  
  
  function setCoreContractAddress(address _address) public onlyCEO {
    CSportsCoreInterface candidateContract = CSportsCoreInterface(_address);
    require(candidateContract.isCoreContract());
    coreContract = candidateContract;
  }

  
  
  function setLeagueRosterContractAddress(address _address) public onlyCEO {
    CSportsRosterInterface candidateContract = CSportsRosterInterface(_address);
    require(candidateContract.isLeagueRosterContract());
    leagueRosterContract = candidateContract;
  }

  
  function setLeagueRosterAndCoreAndContestContractAddress(address _league, address _core, address _contest) public onlyCEO {
    setLeagueRosterContractAddress(_league);
    setCoreContractAddress(_core);
    setContestContractAddress(_contest);
  }

  
  ///   _escrow(...) Verifies that all of the tokens presented
  ///   are owned by the sender, and transfers ownership to this contract. This
  ///   assures that the PlayerTokens cannot be sold in an auction, or entered
  ///   into a different contest. CALLED ONLY BY CONTEST CONTRACT
  ///
  ///   Also note that the size of the _tokenIds array passed must be 10. This is
  ///   particular to the kind of contest we are running (10 players fielded).
  
  ///   associated with the team.
  
  ///   by _owner and will be held in escrow unless released through an update
  ///   or the team is destroyed.
  function createTeam(address _owner, uint32[] _tokenIds) public returns (uint32) {
    require(msg.sender == contestContractAddress);
    require(_tokenIds.length == playersPerTeam);

    // Escrow the player tokens held by this team
    // it will throw if _owner does not own any of the tokens or this CSportsTeam contract
    // has not been set in the CSportsCore contract.
    coreContract.batchEscrowToTeamContract(_owner, _tokenIds);

    uint32 _teamId =  _createTeam(_owner, _tokenIds);

    emit TeamCreated(_teamId, _owner);

    return _teamId;
  }

  
  ///   message sender does not own the team, or if the team does not
  ///   exist. CALLED ONLY BY CONTEST CONTRACT
  
  
  
  
  ///   currently held at the indices specified.
  function updateTeam(address _owner, uint32 _teamId, uint8[] _indices, uint32[] _tokenIds) public {
    require(msg.sender == contestContractAddress);
    require(_owner != address(0));
    require(_tokenIds.length <= playersPerTeam);
    require(_indices.length <= playersPerTeam);
    require(_indices.length == _tokenIds.length);

    Team storage _team = teamIdToTeam[_teamId];
    require(_owner == _team.owner);

    // Escrow the player tokens that will replace those in the team currently -
    // it will throw if _owner does not own any of the tokens or this CSportsTeam contract
    // has not been set in the CSportsCore contract.
    coreContract.batchEscrowToTeamContract(_owner, _tokenIds);

    // Loop through the indices we are updating, and make the update
    for (uint8 i = 0; i < _indices.length; i++) {
      require(_indices[i] <= playersPerTeam);

      uint256 _oldTokenId = uint256(_team.playerTokenIds[_indices[i]]);
      uint256 _newTokenId = _tokenIds[i];

      // Release the _oldToken back to its original owner.
      // (note _owner == _team.owner == original owner of token we are returning)
      coreContract.approve(_owner, _oldTokenId);
      coreContract.transferFrom(address(this), _owner, _oldTokenId);

      // Update the token ID in the team at the same index as the player token removed.
      _team.playerTokenIds[_indices[i]] = uint32(_newTokenId);

    }

    emit TeamUpdated(_teamId);
  }

  
  ///   the team from our mapping. CALLED ONLY BY CONTEST CONTRACT
  
  function releaseTeam(uint32 _teamId) public {

    require(msg.sender == contestContractAddress);
    Team storage _team = teamIdToTeam[_teamId];
    require(_team.owner != address(0));

    if (_team.ownsPlayerTokens) {
      // Loop through all of the player tokens held by the team, and
      // release them back to the original owner.
      for (uint32 i = 0; i < _team.playerTokenIds.length; i++) {
        uint32 _tokenId = _team.playerTokenIds[i];
        coreContract.approve(_team.owner, _tokenId);
        coreContract.transferFrom(address(this), _team.owner, _tokenId);
      }

      // This team's player tokens are no longer held in escrow
      _team.ownsPlayerTokens = false;

      emit TeamReleased(_teamId);
    }

  }

  
  ///   CALLED ONLY BY CONTEST CONTRACT
  
  function refunded(uint32 _teamId) public {
    require(msg.sender == contestContractAddress);
    Team storage _team = teamIdToTeam[_teamId];
    require(_team.owner != address(0));
    _team.holdsEntryFee = false;
  }

  
  ///   arrays are what tie a particular teamId to score and place.
  ///   CALLED ONLY BY CONTEST CONTRACT
  
  
  
  function scoreTeams(uint32[] _teamIds, int32[] _scores, uint32[] _places) public {

    require(msg.sender == contestContractAddress);
    require ((_teamIds.length == _scores.length) && (_teamIds.length == _places.length)) ;
    for (uint i = 0; i < _teamIds.length; i++) {
      Team storage _team = teamIdToTeam[_teamIds[i]];
      if (_team.owner != address(0)) {
        _team.score = _scores[i];
        _team.place = _places[i];
      }
    }
  }

  
  
  function getScore(uint32 _teamId) public view returns (int32) {
    Team storage _team = teamIdToTeam[_teamId];
    require(_team.owner != address(0));
    return _team.score;
  }

  
  
  function getPlace(uint32 _teamId) public view returns (uint32) {
    Team storage _team = teamIdToTeam[_teamId];
    require(_team.owner != address(0));
    return _team.place;
  }

  
  ///   references in the playerTokenIds property.
  
  function ownsPlayerTokens(uint32 _teamId) public view returns (bool) {
    Team storage _team = teamIdToTeam[_teamId];
    require(_team.owner != address(0));
    return _team.ownsPlayerTokens;
  }

  
  
  function getTeamOwner(uint32 _teamId) public view returns (address) {
    Team storage _team = teamIdToTeam[_teamId];
    require(_team.owner != address(0));
    return _team.owner;
  }

  
  ///   _teamId isn't valid. Anybody can call this, making teams visible to the
  ///   world.
  
  function tokenIdsForTeam(uint32 _teamId) public view returns (uint32 count, uint32[50]) {

     
     uint32[50] memory _tokenIds;

     Team storage _team = teamIdToTeam[_teamId];
     require(_team.owner != address(0));

     for (uint32 i = 0; i < _team.playerTokenIds.length; i++) {
       _tokenIds[i] = _team.playerTokenIds[i];
     }

     return (uint32(_team.playerTokenIds.length), _tokenIds);
  }

  
  
  function getTeam(uint32 _teamId) public view returns (
      address _owner,
      int32 _score,
      uint32 _place,
      bool _holdsEntryFee,
      bool _ownsPlayerTokens
    ) {
    Team storage t = teamIdToTeam[_teamId];
    require(t.owner != address(0));
    _owner = t.owner;
    _score = t.score;
    _place = t.place;
    _holdsEntryFee = t.holdsEntryFee;
    _ownsPlayerTokens = t.ownsPlayerTokens;
  }

  /// INTERNAL METHODS

  
  ///   size of the _tokenIds array is correct at this point (checked in calling method)
  
  
  function _createTeam(address _owner, uint32[] _playerTokenIds) internal returns (uint32) {

    Team memory _team = Team({
      owner: _owner,
      score: 0,
      place: 0,
      holdsEntryFee: true,
      ownsPlayerTokens: true,
      playerTokenIds: _playerTokenIds
    });

    uint32 teamIdToReturn = uint32(uniqueTeamId);
    teamIdToTeam[teamIdToReturn] = _team;

    // Increment our team ID for the next one.
    uniqueTeamId++;

    // It's probably never going to happen, 4 billion teams is A LOT, but
    // let's just be 100% sure we never let this happen because teamIds are
    // often cast as uint32.
    require(uniqueTeamId < 4294967295);

    // We should do additional validation on the team here (like are the player
    // positions correct, etc.)

    return teamIdToReturn;
  }

}