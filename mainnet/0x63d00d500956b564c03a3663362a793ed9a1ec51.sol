
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
interface CSportsMinter {

    
    function isMinter() external pure returns (bool);

    
    function mintPlayers(uint128[] _md5Tokens, uint256 _startPrice, uint256 _endPrice, uint256 _duration) external;
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


/// added by the commissioner and represents an on-blockchain database of
/// players in the league.

contract CSportsLeagueRoster is CSportsAuth, CSportsRosterPlayer  {

  /*** STORAGE ***/

  
  CSportsMinter public minterContract;

  
  /// current league (e.g. NFL). There can be a maximum of 4,294,967,295
  /// entries in this array (plenty) because it is indexed by a uint32.
  /// This structure is constantly updated by a commissioner. If the
  /// realWorldPlayer[<whatever].mintingEnabled property is true, then playerTokens
  /// tied to this realWorldPlayer entry will automatically be minted.
  RealWorldPlayer[] public realWorldPlayers;

  mapping (uint128 => uint32) public md5TokenToRosterIndex;

  /*** MODIFIERS ***/

  
  modifier onlyCoreContract() {
      require(msg.sender == address(minterContract));
      _;
  }

  /*** FUNCTIONS ***/

  
  /// are set to the contract creator.
  constructor() public {
    ceoAddress = msg.sender;
    cfoAddress = msg.sender;
    cooAddress = msg.sender;
    commissionerAddress = msg.sender;
  }

  
  function isLeagueRosterContract() public pure returns (bool) {
    return true;
  }

  
  
  function realWorldPlayerFromIndex(uint128 idx) public view returns (uint128 md5Token, uint128 prevCommissionerSalePrice, uint64 lastMintedTime, uint32 mintedCount, bool hasActiveCommissionerAuction, bool mintingEnabled) {
    RealWorldPlayer memory _rwp;
    _rwp = realWorldPlayers[idx];
    md5Token = _rwp.md5Token;
    prevCommissionerSalePrice = _rwp.prevCommissionerSalePrice;
    lastMintedTime = _rwp.lastMintedTime;
    mintedCount = _rwp.mintedCount;
    hasActiveCommissionerAuction = _rwp.hasActiveCommissionerAuction;
    mintingEnabled = _rwp.mintingEnabled;
  }

  
  /// to certin functions
  function setCoreContractAddress(address _address) public onlyCEO {

    CSportsMinter candidateContract = CSportsMinter(_address);
    // NOTE: verify that a contract is what we expect (not foolproof, just
    // a sanity check)
    require(candidateContract.isMinter());
    // Set the new contract address
    minterContract = candidateContract;

  }

  
  function playerCount() public view returns (uint32 count) {
    return uint32(realWorldPlayers.length);
  }

  
  /// auction as a commissioner auction.
  
  
  ///        (if an entry is not true, that player will not be minted and no auction created)
  
  
  
  function addAndMintPlayers(uint128[] _md5Tokens, bool[] _mintingEnabled, uint256 _startPrice, uint256 _endPrice, uint256 _duration) public onlyCommissioner {

    // Add the real world players to the roster
    addRealWorldPlayers(_md5Tokens, _mintingEnabled);

    // Mint the newly added players and create commissioner auctions
    minterContract.mintPlayers(_md5Tokens, _startPrice, _endPrice, _duration);

  }

  
  
  
  function addRealWorldPlayers(uint128[] _md5Tokens, bool[] _mintingEnabled) public onlyCommissioner {
    if (_md5Tokens.length != _mintingEnabled.length) {
      revert();
    }
    for (uint32 i = 0; i < _md5Tokens.length; i++) {
      // We won't try to put an md5Token duplicate by using the md5TokenToRosterIndex
      // mapping (notice we need to deal with the fact that a non-existent mapping returns 0)
      if ( (realWorldPlayers.length == 0) ||
           ((md5TokenToRosterIndex[_md5Tokens[i]] == 0) && (realWorldPlayers[0].md5Token != _md5Tokens[i])) ) {
        RealWorldPlayer memory _realWorldPlayer = RealWorldPlayer({
                                                      md5Token: _md5Tokens[i],
                                                      prevCommissionerSalePrice: 0,
                                                      lastMintedTime: 0,
                                                      mintedCount: 0,
                                                      hasActiveCommissionerAuction: false,
                                                      mintingEnabled: _mintingEnabled[i],
                                                      metadata: ""
                                                  });
        uint256 _rosterIndex = realWorldPlayers.push(_realWorldPlayer) - 1;

        // It's probably never going to happen, but just in case, we need
        // to make sure our realWorldPlayers can be indexed by a uint32
        require(_rosterIndex < 4294967295);

        // Map the md5Token to its rosterIndex
        md5TokenToRosterIndex[_md5Tokens[i]] = uint32(_rosterIndex);
      }
    }
  }

  
  
  
  function setMetadata(uint128 _md5Token, string _metadata) public onlyCommissioner {
      uint32 _rosterIndex = md5TokenToRosterIndex[_md5Token];
      if ((_rosterIndex > 0) || ((realWorldPlayers.length > 0) && (realWorldPlayers[0].md5Token == _md5Token))) {
        // Valid MD5 token
        realWorldPlayers[_rosterIndex].metadata = _metadata;
      }
  }

  
  
  function getMetadata(uint128 _md5Token) public view returns (string metadata) {
    uint32 _rosterIndex = md5TokenToRosterIndex[_md5Token];
    if ((_rosterIndex > 0) || ((realWorldPlayers.length > 0) && (realWorldPlayers[0].md5Token == _md5Token))) {
      // Valid MD5 token
      metadata = realWorldPlayers[_rosterIndex].metadata;
    } else {
      metadata = "";
    }
  }

  
  ///   will be blocked after we are completed with development. Deleting entries would
  ///   screw up the ids of realWorldPlayers held by the core contract's playerTokens structure.
  
  function removeRealWorldPlayer(uint128 _md5Token) public onlyCommissioner onlyUnderDevelopment  {
    for (uint32 i = 0; i < uint32(realWorldPlayers.length); i++) {
      RealWorldPlayer memory player = realWorldPlayers[i];
      if (player.md5Token == _md5Token) {
        uint32 stopAt = uint32(realWorldPlayers.length - 1);
        for (uint32 j = i; j < stopAt; j++){
            realWorldPlayers[j] = realWorldPlayers[j+1];
            md5TokenToRosterIndex[realWorldPlayers[j].md5Token] = j;
        }
        delete realWorldPlayers[realWorldPlayers.length-1];
        realWorldPlayers.length--;
        break;
      }
    }
  }

  
  
  function hasOpenCommissionerAuction(uint128 _md5Token) public view onlyCommissioner returns (bool) {
    uint128 _rosterIndex = this.getRealWorldPlayerRosterIndex(_md5Token);
    if (_rosterIndex == 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) {
      revert();
    } else {
      return realWorldPlayers[_rosterIndex].hasActiveCommissionerAuction;
    }
  }

  
  
  function getRealWorldPlayerRosterIndex(uint128 _md5Token) public view returns (uint128) {

    uint32 _rosterIndex = md5TokenToRosterIndex[_md5Token];
    if (_rosterIndex == 0) {
      // Deal with the fact that mappings return 0 for non-existent members and 0 is
      // a valid rosterIndex for the 0th (first) entry in the realWorldPlayers array.
      if ((realWorldPlayers.length > 0) && (realWorldPlayers[0].md5Token == _md5Token)) {
        return uint128(0);
      }
    } else {
      return uint128(_rosterIndex);
    }

    // Intentionally returning an invalid rosterIndex (too big) as an indicator that
    // the md5 passed was not found.
    return uint128(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
  }

  
  
  
  function enableRealWorldPlayerMinting(uint128[] _md5Tokens, bool[] _mintingEnabled) public onlyCommissioner {
    if (_md5Tokens.length != _mintingEnabled.length) {
      revert();
    }
    for (uint32 i = 0; i < _md5Tokens.length; i++) {
      uint32 _rosterIndex = md5TokenToRosterIndex[_md5Tokens[i]];
      if ((_rosterIndex > 0) || ((realWorldPlayers.length > 0) && (realWorldPlayers[0].md5Token == _md5Tokens[i]))) {
        // _rosterIndex is valid
        realWorldPlayers[_rosterIndex].mintingEnabled = _mintingEnabled[i];
      } else {
        // Tried to enable/disable minting on non-existent realWorldPlayer
        revert();
      }
    }
  }

  
  
  function isRealWorldPlayerMintingEnabled(uint128 _md5Token) public view returns (bool) {
    // Have to deal with the fact that the 0th entry is a valid one.
    uint32 _rosterIndex = md5TokenToRosterIndex[_md5Token];
    if ((_rosterIndex > 0) || ((realWorldPlayers.length > 0) && (realWorldPlayers[0].md5Token == _md5Token))) {
      // _rosterIndex is valid
      return realWorldPlayers[_rosterIndex].mintingEnabled;
    } else {
      // Tried to enable/disable minting on non-existent realWorldPlayer
      revert();
    }
  }

  
  ///   called by the core contract.
  
  
  
  
  
  
  function updateRealWorldPlayer(uint32 _rosterIndex, uint128 _prevCommissionerSalePrice, uint64 _lastMintedTime, uint32 _mintedCount, bool _hasActiveCommissionerAuction, bool _mintingEnabled) public onlyCoreContract {
    require(_rosterIndex < realWorldPlayers.length);
    RealWorldPlayer storage _realWorldPlayer = realWorldPlayers[_rosterIndex];
    _realWorldPlayer.prevCommissionerSalePrice = _prevCommissionerSalePrice;
    _realWorldPlayer.lastMintedTime = _lastMintedTime;
    _realWorldPlayer.mintedCount = _mintedCount;
    _realWorldPlayer.hasActiveCommissionerAuction = _hasActiveCommissionerAuction;
    _realWorldPlayer.mintingEnabled = _mintingEnabled;
  }

  
  ///   Will throw if there is hasActiveCommissionerAuction was already true upon entry.
  
  function setHasCommissionerAuction(uint32 _rosterIndex) public onlyCoreContract {
    require(_rosterIndex < realWorldPlayers.length);
    RealWorldPlayer storage _realWorldPlayer = realWorldPlayers[_rosterIndex];
    require(!_realWorldPlayer.hasActiveCommissionerAuction);
    _realWorldPlayer.hasActiveCommissionerAuction = true;
  }

  
  ///   no longer an active commissioner auction.
  
  function commissionerAuctionComplete(uint32 _rosterIndex, uint128 _price) public onlyCoreContract {
    require(_rosterIndex < realWorldPlayers.length);
    RealWorldPlayer storage _realWorldPlayer = realWorldPlayers[_rosterIndex];
    require(_realWorldPlayer.hasActiveCommissionerAuction);
    if (_realWorldPlayer.prevCommissionerSalePrice == 0) {
      _realWorldPlayer.prevCommissionerSalePrice = _price;
    } else {
      _realWorldPlayer.prevCommissionerSalePrice = (_realWorldPlayer.prevCommissionerSalePrice + _price)/2;
    }
    _realWorldPlayer.hasActiveCommissionerAuction = false;

    // Finally, re-mint another player token for this realWorldPlayer and put him up for auction
    // at the default pricing and duration (auto mint)
    if (_realWorldPlayer.mintingEnabled) {
      uint128[] memory _md5Tokens = new uint128[](1);
      _md5Tokens[0] = _realWorldPlayer.md5Token;
      minterContract.mintPlayers(_md5Tokens, 0, 0, 0);
    }
  }

  
  ///   no longer an active commissioner auction.
  function commissionerAuctionCancelled(uint32 _rosterIndex) public view onlyCoreContract {
    require(_rosterIndex < realWorldPlayers.length);
    RealWorldPlayer storage _realWorldPlayer = realWorldPlayers[_rosterIndex];
    require(_realWorldPlayer.hasActiveCommissionerAuction);

    // We do not clear the hasActiveCommissionerAuction bit on a cancel. This will
    // continue to block the minting of new commissioner tokens (limiting supply).
    // The only way this RWP can be back on a commissioner auction is by the commish
    // putting the token corresponding to the canceled auction back on auction.
  }

}