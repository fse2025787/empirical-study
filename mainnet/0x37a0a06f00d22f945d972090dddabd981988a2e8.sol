// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.13;

contract FrankenDAOErrors {
    // General purpose
    error NotAuthorized();

    // Staking
    error NonExistentToken();
    error InvalidDelegation();
    error Paused();
    error InvalidParameter();
    error TokenLocked();
    error StakedTokensCannotBeTransferred();

    // Governance
    error ZeroAddress();
    error AlreadyInitialized();
    error ParameterOutOfBounds();
    error InvalidId();
    error InvalidProposal();
    error InvalidStatus();
    error InvalidInput();
    error AlreadyVoted();
    error NotEligible();
    error NotInActiveProposals();
    error NotStakingContract();

    // Executor
    error DelayNotSatisfied();
    error IdenticalTransactionAlreadyQueued();
    error TransactionNotQueued();
    error TimelockNotMet();
    error TransactionReverted();
}

pragma solidity ^0.8.10;



interface IAdmin {

    ////////////////////
    ////// Events //////
    ////////////////////

    
    event NewCouncil(address oldCouncil, address newCouncil);
    
    event NewFounders(address oldFounders, address newFounders);
    
    event NewPauser(address oldPauser, address newPauser);
    
    event NewVerifier(address oldVerifier, address newVerifier);
    
    event NewPendingFounders(address oldPendingFounders, address newPendingFounders);

    /////////////////////
    ////// Methods //////
    /////////////////////

    function acceptFounders() external;
    function council() external view returns (address);
    function executor() external view returns (IExecutor);
    function founders() external view returns (address);
    function pauser() external view returns (address);
    function pendingFounders() external view returns (address);
    function revokeFounders() external;
    function setCouncil(address _newCouncil) external;
    function setPauser(address _newPauser) external;
    function setPendingFounders(address _newPendingFounders) external;
}

pragma solidity ^0.8.10;

interface IRefundable {

    ////////////////////
    ////// Events //////
    ////////////////////

    
    event IssueRefund(address refunded, uint256 amount, bool sent, uint256 remainingBalance);

    
    event InsufficientFundsForRefund(address refunded, uint256 intendedAmount, uint256 sentAmount);

    /////////////////////
    ////// Methods //////
    /////////////////////

    function MAX_REFUND_PRIORITY_FEE() external view returns (uint256);
    function REFUND_BASE_GAS() external view returns (uint256);
}
// 
pragma solidity >=0.8.0;



abstract contract ERC721 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) internal _ownerOf;

    mapping(address => uint256) internal _balanceOf;

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        require((owner = _ownerOf[id]) != address(0), "NOT_MINTED");
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");

        return _balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual {
        address owner = _ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == _ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");

        require(_ownerOf[id] == address(0), "ALREADY_MINTED");

        // Counter overflow is incredibly unrealistic.
        unchecked {
            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id];

        require(owner != address(0), "NOT_MINTED");

        // Ownership check above ensures no underflow.
        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}

pragma solidity ^0.8.10;

interface IStaking {

    ////////////////////
    ////// Events //////
    ////////////////////

    
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    
    event StakingPause(bool status);
    
    event BaseURIChanged(string _baseURI);
    
    event ContractURIChanged(string _contractURI);
    
    event RefundSettingsChanged(bool _stakingRefund, bool _delegatingRefund, uint256 _newCooldown);
    
    event MonsterMultiplierChanged(uint256 _monsterMultiplier);
    
    event ProposalPassedMultiplierChanged(uint64 _proposalPassedMultiplier);
    
    event StakeTimeChanged(uint128 _stakeTime);
    
    event StakeAmountChanged(uint128 _stakeAmount);
    
    event VotesMultiplierChanged(uint64 _votesMultiplier);
    
    event ProposalsCreatedMultiplierChanged(uint64 _proposalsCreatedMultiplier);
    
    event BaseVotesChanged(uint256 _baseVotes);

    /////////////////////
    ////// Storage //////
    /////////////////////

    struct CommunityPowerMultipliers {
        uint64 votes;
        uint64 proposalsCreated;
        uint64 proposalsPassed;
    }

    struct StakingSettings {
        uint128 maxStakeBonusTime;
        uint128 maxStakeBonusAmount;
    }

    enum RefundStatus { 
        StakingAndDelegatingRefund,
        StakingRefund, 
        DelegatingRefund, 
        NoRefunds
    }

    /////////////////////
    ////// Methods //////
    /////////////////////

    function baseTokenURI() external view returns (string memory);
    function BASE_VOTES() external view returns (uint256);
    function changeStakeAmount(uint128 _newMaxStakeBonusAmount) external;
    function changeStakeTime(uint128 _newMaxStakeBonusTime) external;
    function communityPowerMultipliers()
        external
        view
        returns (uint64 votes, uint64 proposalsCreated, uint64 proposalsPassed);
    function delegate(address _delegatee) external;
    function delegatingRefund() external view returns (bool);
    function evilBonus(uint256 _tokenId) external view returns (uint256);
    function getCommunityVotingPower(address _voter) external view returns (uint256);
    function getDelegate(address _delegator) external view returns (address);
    function getStakedTokenSupplies() external view returns (uint128, uint128);
    function getTokenVotingPower(uint256 _tokenId) external view returns (uint256);
    function getTotalVotingPower() external view returns (uint256);
    function getVotes(address _account) external view returns (uint256);
    function isFrankenPunksStakingContract() external pure returns (bool);
    function lastDelegatingRefund(address) external view returns (uint256);
    function lastStakingRefund(address) external view returns (uint256);
    function paused() external view returns (bool);
    function setBaseURI(string memory _baseURI) external;
    function setPause(bool _paused) external;
    function setProposalsCreatedMultiplier(uint64 _proposalsCreatedMultiplier) external;
    function setProposalsPassedMultiplier(uint64 _proposalsPassedMultiplier) external;
    function setRefunds(bool _stakingRefund, bool _delegatingRefund, uint256 _newCooldown) external;
    function setVotesMultiplier(uint64 _votesmultiplier) external;
    function stake(uint256[] memory _tokenIds, uint256 _unlockTime) external;
    function stakedFrankenMonsters() external view returns (uint128);
    function stakedFrankenPunks() external view returns (uint128);
    function stakingRefund() external view returns (bool);
    function stakingSettings() external view returns (uint128 maxStakeBonusTime, uint128 maxStakeBonusAmount);
    function tokenVotingPower(address) external view returns (uint256);
    function unlockTime(uint256) external view returns (uint256);
    function unstake(uint256[] memory _tokenIds, address _to) external;
    function votesFromOwnedTokens(address) external view returns (uint256);
}

// 
pragma solidity ^0.8.13;







abstract contract Admin is IAdmin, FrankenDAOErrors {
    
    address public founders;

    
    address public council;

    
    IExecutor public executor;

    
    
    
    address public pauser;

    
    
    address public verifier;

    
    
    address public pendingFounders;

    /////////////////////////////
    ///////// MODIFIERS /////////
    /////////////////////////////

    
    
    modifier onlyExecutor() {
        if(msg.sender != address(executor)) revert NotAuthorized();
        _;
    }

    
    modifier onlyAdmins() {
        if(msg.sender != founders && msg.sender != council) revert NotAuthorized();
        _;
    }

    
    modifier onlyPauserOrAdmins() {
        if(msg.sender != founders && msg.sender != council && msg.sender != pauser) revert NotAuthorized();
        _;
    }

    modifier onlyVerifierOrAdmins() {
        if(msg.sender != founders && msg.sender != council && msg.sender != verifier) revert NotAuthorized();
        _;
    }

    
    modifier onlyExecutorOrAdmins() {
        if (
            msg.sender != address(executor) && 
            msg.sender != council && 
            msg.sender != founders
        ) revert NotAuthorized();
        _;
    }

    /////////////////////////////
    ////// ADMIN TRANSFERS //////
    /////////////////////////////

    
    
    
    function setPendingFounders(address _newPendingFounders) external {
        if (msg.sender != founders) revert NotAuthorized();
        emit NewPendingFounders(pendingFounders, _newPendingFounders);
        pendingFounders = _newPendingFounders;
    }

    
    function acceptFounders() external {
        if (msg.sender != pendingFounders) revert NotAuthorized();
        emit NewFounders(founders, pendingFounders);
        founders = pendingFounders;
        pendingFounders = address(0);
    }

    
    
    
    
    function revokeFounders() external {
        if (msg.sender != founders) revert NotAuthorized();
        
        emit NewFounders(founders, address(0));
        
        founders = address(0);
        pendingFounders = address(0);
    }

    
    
    
    function setCouncil(address _newCouncil) external onlyAdmins {
       
        emit NewCouncil(council, _newCouncil);
       
        council = _newCouncil;
    }

    
    
    function setVerifier(address _newVerifier) external onlyAdmins {

        emit NewVerifier(verifier, _newVerifier);
        
        verifier = _newVerifier;
    }

    
    
    function setPauser(address _newPauser) external onlyExecutorOrAdmins {
        
        emit NewPauser(pauser, _newPauser);
        
        pauser = _newPauser;
    }
}

// 
pragma solidity ^0.8.13;






contract Refundable is IRefundable, FrankenDAOErrors {

    
    uint256 public constant MAX_REFUND_PRIORITY_FEE = 2 gwei;

    
    
    /** @dev This will be slightly different depending on which function is used, but all are within a few 
        thousand gas, so approximation is fine. */
    uint256 public constant REFUND_BASE_GAS = 27_000;

    
    
    
    function _refundGas(uint256 _startGas) internal {
        unchecked {
            uint256 gasPrice = _min(tx.gasprice, block.basefee + MAX_REFUND_PRIORITY_FEE);
            uint256 gasUsed = _startGas - gasleft() + REFUND_BASE_GAS;
            uint refundAmount = gasPrice * gasUsed;
            
            // If gas fund runs out, pay out as much as possible and emit warning event.
            if (address(this).balance < refundAmount) {
                emit InsufficientFundsForRefund(msg.sender, refundAmount, address(this).balance);
                refundAmount = address(this).balance;
            }

            // There shouldn't be any reentrancy risk, as this is called last at all times.
            // They also can't exploit the refund by wasting gas before we've already finalized amount.
            (bool refundSent, ) = msg.sender.call{ value: refundAmount }('');

            // Includes current balance in event so team can listen and filter to know when to propose refill.
            emit IssueRefund(msg.sender, refundAmount, refundSent, address(this).balance);
        }
    }

    
    
    
    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}



abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}

// 
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

/**
 _______  _______  _______  _        _        _______  _          _______           _        _        _______
(  ____ \(  ____ )(  ___  )( (    /|| \    /\(  ____ \( (    /|  (  ____ )|\     /|( (    /|| \    /\(  ____ \
| (    \/| (    )|| (   ) ||  \  ( ||  \  / /| (    \/|  \  ( |  | (    )|| )   ( ||  \  ( ||  \  / /| (    \/
| (__    | (____)|| (___) ||   \ | ||  (_/ / | (__    |   \ | |  | (____)|| |   | ||   \ | ||  (_/ / | (_____
|  __)   |     __)|  ___  || (\ \) ||   _ (  |  __)   | (\ \) |  |  _____)| |   | || (\ \) ||   _ (  (_____  )
| (      | (\ (   | (   ) || | \   ||  ( \ \ | (      | | \   |  | (      | |   | || | \   ||  ( \ \       ) |
| )      | ) \ \__| )   ( || )  \  ||  /  \ \| (____/\| )  \  |  | )      | (___) || )  \  ||  /  \ \/\____) |
|/       |/   \__/|/     \||/    )_)|_/    \/(_______/|/    )_)  |/       (_______)|/    )_)|_/    \/\_______)

*/
















contract Staking is IStaking, ERC721, Admin, Refundable {
  using LibString for uint256;

  
  IERC721 frankenpunks;
  
  
  IERC721 frankenmonsters;

  
  IGovernance governance;

  
  uint constant public BASE_VOTES = 20;

  
  
  StakingSettings public stakingSettings;

  
  
  
  
  CommunityPowerMultipliers public communityPowerMultipliers;

  
  uint constant PERCENT = 100;

  
  bool public stakingRefund;

  
  mapping(address => uint256) public lastStakingRefund;

  
  bool public delegatingRefund;

  
  mapping(address => uint256) public lastDelegatingRefund;

  
  uint256 public refundCooldown;

  
  bool public paused;

  
  
  mapping(uint => uint) stakedTimeBonus; 
  
  
  
  mapping(uint => uint) public unlockTime;

  
  
  mapping(address => address) private _delegates;

  
  
  
  mapping(address => uint) public votesFromOwnedTokens;

  
  
  mapping(address => uint) public tokenVotingPower;

  
  uint totalTokenVotingPower;

  
  string public baseTokenURI;

  
  string public contractURI;

  
  uint128 public stakedFrankenPunks;

  
  uint128 public stakedFrankenMonsters;

  
  
  uint[40] EVIL_BITMAPS = [
    883425322698150530263834307704826599123904599330160270537777278655401984, // 0
    14488147225470816109160058996749687396265978336526515174837584423109802852352, // 1
    38566513062215815139428642218823858442255833421860837338906624, // 2
    105312291668557186697918027683670432324476705909712387428719788032, // 3
    14474011154664524427946373126085988481660077311200856629730921422678596263936, // 4
    3618502788692465607655909614339766499850336868450542774889103259212619972609, // 5
    441711772776714745308416192199486840791445460561420424832198410539892736, // 6
    6901746759773641161995257390185172072446268286034776944761674561224712, // 7
    883423532414903565819785182543377466397133986207912949084155019599544320, // 8
    14474011155086185177904289442148664541270784730116237084843513087002589265920, // 9
    107839786668798718607898896909541540930351713584408019687362806153216, // 10
    904625700641838402593673198335004289144275540958779302917589231213362556944, // 11
    220859253090631447287862539909960206022391538433640386622889848771706880, // 12
    1393839110204029063653915313866451565150208, // 13
    784637716923340670665773318162647287385528792673206407169, // 14
    107839786668602559178668060353525740564723109496935832847049186869248, // 15
    51422802054004612152481822571560984362335820545231474237898784, // 16
    6582018229284824169333500576582381960460086447259084614308728832, // 17
    365732221255902219560809532335122355265736818688, // 18
    445162639419413381705829464770174011933371831432841644599383048677490688, // 19
    6935446280124502090171244984389489167294584349705235353545399909482504, // 20
    452312848583266388373372050675839373643513806386188657447441353755011973120, // 21
    51422023594160337932957247212003666383914706547133656225284128, // 22
    2923003274661805998666646494941077336069228208128, // 23
    215679573337205118357336126271343355406346657833909405071980653182976, // 24
    26959946667150639794667015087041235820865508444839585222888876146720, // 25
    3731581108651760187459529718884681603688140590625042088037390915407571845120, // 26
    33372889303170710042455474178259135664197736114694375141005066752, // 27
    28948022309329151699928351061631107912622119818910282538292189430411643863044, // 28
    55214023430470347690952963241066788995217469738067023806554216123598848, // 29
    55213971185700649632772712790212230970723509677757939395778641765335297, // 30
    50216813883139118038214077107913983031541181002059654103040, // 31
    45671926166601100787582220677640905906662146176, // 32
    431359146674410260659915067596052074490887103277477952745659311325184, // 33
    6741683593362397442763285474207733540211166501858783908538903166976, // 34
    421249166674235107246797774824181756792478284093098635821743865856, // 35
    53919893334350319447007114026840783409769671338355940037889148190720, // 36
    401740641047276407850947922339698016834483256774579142524928, // 37
    220855883097304318299647574273628650268020954052697685772267193358090240, // 38
    0 // 39
  ];

  /////////////////////////////////
  /////////// MODIFIERS ///////////
  /////////////////////////////////

  
  
  
  modifier lockedWhileVotesCast() {
    uint[] memory activeProposals = governance.getActiveProposals();
    for (uint i = 0; i < activeProposals.length; i++) {
      if (governance.getReceipt(activeProposals[i], getDelegate(msg.sender)).hasVoted) revert TokenLocked();
      (, address proposer,) = governance.getProposalData(activeProposals[i]);
      if (proposer == getDelegate(msg.sender)) revert TokenLocked();
    }
    _;
  }

  /////////////////////////////////
  ////////// CONSTRUCTOR //////////
  /////////////////////////////////

  
  
  
  
  
  
  
  
  constructor(
    address _frankenpunks, 
    address _frankenmonsters,
    address _governance, 
    address _executor, 
    address _founders,
    address _council,
    string memory _baseTokenURI,
    string memory _contractURI
  ) ERC721("Staked FrankenPunks", "sFP") {
    frankenpunks = IERC721(_frankenpunks);
    frankenmonsters = IERC721(_frankenmonsters);
    governance = IGovernance( _governance );

    executor = IExecutor(_executor);
    founders = _founders;
    council = _council;

    // Staking bonus increases linearly from 0 to 20 votes over 4 weeks
    stakingSettings = StakingSettings({
      maxStakeBonusTime: uint128(4 weeks), 
      maxStakeBonusAmount: uint128(20)
    });

    // Users get a bonus 1 vote per vote, 2 votes per proposal created, and 2 votes per proposal passed
    communityPowerMultipliers = CommunityPowerMultipliers({
      votes: uint64(100), 
      proposalsCreated: uint64(200),
      proposalsPassed: uint64(200)
    });

    // Refunds are initially turned on with 1 day cooldown.
    delegatingRefund = true;
    stakingRefund = true;
    refundCooldown = 1 days;

    // Set the base token URI.
    baseTokenURI = _baseTokenURI;

    // Set the contract URI.
    contractURI = _contractURI;
  }

  /////////////////////////////////
  // OVERRIDE & REVERT TRANSFERS //
  /////////////////////////////////  

  
  
  function transferFrom(address, address, uint256) public pure override(ERC721) {
    revert StakedTokensCannotBeTransferred();
  }

  /////////////////////////////////
  /////// TOKEN URI FUNCTIONS /////
  /////////////////////////////////

  
  
  function tokenURI(uint256 _tokenId) public view virtual override(ERC721) returns (string memory) {
    if (ownerOf(_tokenId) == address(0)) revert NonExistentToken();

    string memory baseURI = baseTokenURI;
    return bytes(baseURI).length > 0
      ? string(abi.encodePacked(baseURI, _tokenId.toString(), ".json"))
      : "";
  }

  /////////////////////////////////
  /////// DELEGATION LOGIC ////////
  /////////////////////////////////

  
  
  
  
  function getDelegate(address _delegator) public view returns (address) {
    address current = _delegates[_delegator];
    return current == address(0) ? _delegator : current;
  }

  
  
  
  function delegate(address _delegatee) public {
    if (_delegatee == address(0)) _delegatee = msg.sender;
    
    // Refunds gas if delegatingRefund is true and hasn't been used by this user in the past 24 hours
    if (delegatingRefund && lastDelegatingRefund[msg.sender] + refundCooldown <= block.timestamp) {
      uint256 startGas = gasleft();
      _delegate(msg.sender, _delegatee);
      lastDelegatingRefund[msg.sender] = block.timestamp;
      _refundGas(startGas);
    } else {
      _delegate(msg.sender, _delegatee);
    }
  }

  
  
  
  function _delegate(address _delegator, address _delegatee) internal lockedWhileVotesCast {
    address currentDelegate = getDelegate(_delegator);
    // If currentDelegate == _delegatee, then this function will not do anything
    if (currentDelegate == _delegatee) revert InvalidDelegation();

    // Set the _delegates mapping to the correct address, subbing in address(0) if they are delegating to themselves
    _delegates[_delegator] = _delegatee == _delegator ? address(0) : _delegatee;
    uint amount = votesFromOwnedTokens[_delegator];

    // If the delegator has no votes, then this function will not do anything
    // This is explicitly blocked to ensure that users without votes cannot abuse the refund mechanism
    if (amount == 0) revert InvalidDelegation();
    
    // Move the votes from the currentDelegate to the new delegatee
    // Neither of these addresses can be address(0) because: 
    // - currentDelegate calls getDelegate(), which replaces address(0) with the delegator's address
    // - delegatee is changed to msg.sender in the external functions if address(0) is passed
    tokenVotingPower[currentDelegate] -= amount;
    tokenVotingPower[_delegatee] += amount; 

    // If this moved the current delegate down to zero voting power, then remove their community VP from the totals
    if (tokenVotingPower[currentDelegate] == 0) {
        _updateTotalCommunityVotingPower(currentDelegate, false);
    }

    // If the new delegate previously had zero voting power, then add their community VP to the totals
    if (tokenVotingPower[_delegatee] == amount) {
      _updateTotalCommunityVotingPower(_delegatee, true);
    }

    emit DelegateChanged(_delegator, currentDelegate, _delegatee);
  }

  
  
  
  
  function _updateTotalCommunityVotingPower(address _delegator, bool _increase) internal {
    (uint64 votes, uint64 proposalsCreated, uint64 proposalsPassed) = governance.userCommunityScoreData(_delegator);
    (uint64 totalVotes, uint64 totalProposalsCreated, uint64 totalProposalsPassed) = governance.totalCommunityScoreData();

    if (_increase) {
      governance.updateTotalCommunityScoreData(totalVotes + votes, totalProposalsCreated + proposalsCreated, totalProposalsPassed + proposalsPassed);
    } else {
      governance.updateTotalCommunityScoreData(totalVotes - votes, totalProposalsCreated - proposalsCreated, totalProposalsPassed - proposalsPassed);
    }
  }

  /////////////////////////////////
  /// STAKE & UNSTAKE FUNCTIONS ///
  /////////////////////////////////

  
  
  
  
  function stake(uint[] calldata _tokenIds, uint _unlockTime) public {
    // Refunds gas if stakingRefund is true and hasn't been used by this user in the past 24 hours
    if (stakingRefund && lastStakingRefund[msg.sender] + refundCooldown <= block.timestamp) {
      uint256 startGas = gasleft();
      _stake(_tokenIds, _unlockTime);
      lastStakingRefund[msg.sender] = block.timestamp;
      _refundGas(startGas);
    } else {
      _stake(_tokenIds, _unlockTime);
    }
  }

  
  
  
  function _stake(uint[] calldata _tokenIds, uint _unlockTime) internal {
    if (paused) revert Paused();
    if (_unlockTime > 0 && _unlockTime < block.timestamp) revert InvalidParameter();

    uint maxStakeTime = stakingSettings.maxStakeBonusTime;
    if (_unlockTime > 0 && _unlockTime - block.timestamp > maxStakeTime) {
      _unlockTime = block.timestamp + maxStakeTime;
    }

    uint numTokens = _tokenIds.length;
    // This is required to ensure the gas refunds are not abused
    if (numTokens == 0) revert InvalidParameter();
    
    uint newVotingPower;
    for (uint i = 0; i < numTokens; i++) {
        newVotingPower += _stakeToken(_tokenIds[i], _unlockTime);
    }

    votesFromOwnedTokens[msg.sender] += newVotingPower;
    tokenVotingPower[getDelegate(msg.sender)] += newVotingPower;
    totalTokenVotingPower += newVotingPower;

    // If the delegate (including self) had no tokenVotingPower before, they just unlocked their community voting power
    if (tokenVotingPower[getDelegate(msg.sender)] == newVotingPower) {
      // The delegate's community voting power is reactivated, so we add it to the total community voting power
      _updateTotalCommunityVotingPower(getDelegate(msg.sender), true);
    }
  }

  
  
  
  function _stakeToken(uint _tokenId, uint _unlockTime) internal returns (uint) {
    if (_unlockTime > 0) {
      unlockTime[_tokenId] = _unlockTime;
      uint fullStakedTimeBonus = ((_unlockTime - block.timestamp) * stakingSettings.maxStakeBonusAmount) / stakingSettings.maxStakeBonusTime;
      stakedTimeBonus[_tokenId] = _tokenId < 10000 ? fullStakedTimeBonus : fullStakedTimeBonus / 2;
    }

    // Transfer the underlying token from the owner to this contract
    IERC721 collection;
    if (_tokenId < 10000) {
      collection = frankenpunks;
      stakedFrankenPunks++;
    } else {
      collection = frankenmonsters;
      stakedFrankenMonsters++;
    }

    address owner = collection.ownerOf(_tokenId);
    if (msg.sender != owner) revert NotAuthorized();
    collection.transferFrom(owner, address(this), _tokenId);

    // Mint the staker a new ERC721 token representing their staked token
    _mint(msg.sender, _tokenId);

    // Return the voting power for this token based on staked time bonus and evil score
    return getTokenVotingPower(_tokenId);
  }

  
  
  
  function unstake(uint[] calldata _tokenIds, address _to) public {
    _unstake(_tokenIds, _to);
  }

  
  
  
  function _unstake(uint[] calldata _tokenIds, address _to) internal lockedWhileVotesCast {
    uint numTokens = _tokenIds.length;
    if (numTokens == 0) revert InvalidParameter();
    
    uint lostVotingPower;
    for (uint i = 0; i < numTokens; i++) {
        lostVotingPower += _unstakeToken(_tokenIds[i], _to);
    }

    votesFromOwnedTokens[msg.sender] -= lostVotingPower;
    // Since the delegate currently has the voting power, it must be removed from their balance
    // If the user doesn't delegate, delegates(msg.sender) will return self
    tokenVotingPower[getDelegate(msg.sender)] -= lostVotingPower;
    totalTokenVotingPower -= lostVotingPower;

    // If this unstaking reduced the user or their delegate's tokenVotingPower to 0, then someone just lost their community voting power
    // First, check if the user is their own delegate
    if (msg.sender == getDelegate(msg.sender)) {
      // Did their tokenVotingPower just become 0?
      if (tokenVotingPower[msg.sender] == 0) {
        // If so, reduce the total voting power to capture this decrease in the user's community voting power
        _updateTotalCommunityVotingPower(msg.sender, false);
      }
    // If they aren't their own delegate...
    } else {
      // If their delegate's tokenVotingPower reaches 0, that means they were the final unstake and the delegate loses community voting power
      if (tokenVotingPower[getDelegate(msg.sender)] == 0) {
        // The delegate's community voting power is forfeited, so we adjust total community power balances down
        _updateTotalCommunityVotingPower(getDelegate(msg.sender), false);
      }
    }
  }

  
  
  
  function _unstakeToken(uint _tokenId, address _to) internal returns(uint) {
    address owner = ownerOf(_tokenId);
    if (msg.sender != owner) revert NotAuthorized();
    if (unlockTime[_tokenId] > block.timestamp) revert TokenLocked();
    
    // Transfer the underlying token from the owner to this contract
    IERC721 collection;
    if (_tokenId < 10000) {
      collection = frankenpunks;
      --stakedFrankenPunks;
    } else {
      collection = frankenmonsters;
      --stakedFrankenMonsters;
    }
    collection.safeTransferFrom(address(this), _to, _tokenId);

    // Voting power needs to be calculated before staked time bonus is zero'd out, as it uses this value
    uint lostVotingPower = getTokenVotingPower(_tokenId);
    _burn(_tokenId);

    if (unlockTime[_tokenId] > 0) {
      delete unlockTime[_tokenId];
      delete stakedTimeBonus[_tokenId];
    }

    return lostVotingPower;
  }

    //////////////////////////////////////////////
    ///// VOTING POWER CALCULATION FUNCTIONS /////
    //////////////////////////////////////////////
    
    
    
    
    
    function getVotes(address _account) public view returns (uint) {
        return tokenVotingPower[_account] + getCommunityVotingPower(_account);
    }
    
    
    
    
    
    function getTokenVotingPower(uint _tokenId) public override view returns (uint) {
      if (ownerOf(_tokenId) == address(0)) revert NonExistentToken();

      // If tokenId < 10000, it's a FrankenPunk, so BASE_VOTES, otherwise, divide by 2 for monsters
      uint baseVotes = _tokenId < 10_000 ? BASE_VOTES : BASE_VOTES / 2;
      
      // evilBonus will return 0 for all FrankenMonsters, as they are not eligible for the evil bonus
      return baseVotes + stakedTimeBonus[_tokenId] + evilBonus(_tokenId);
    }

    
    
    
    function getCommunityVotingPower(address _voter) public override view returns (uint) {
      uint64 votes;
      uint64 proposalsCreated;
      uint64 proposalsPassed;
      
      // We allow this function to be called with the max uint value to get the total community voting power
      if (_voter == address(type(uint160).max)) {
        (votes, proposalsCreated, proposalsPassed) = governance.totalCommunityScoreData();
      } else {
        // This is only the case if they are delegated or unstaked, both of which should zero out the result
        if (tokenVotingPower[_voter] == 0) return 0;

        (votes, proposalsCreated, proposalsPassed) = governance.userCommunityScoreData(_voter);
      }

      CommunityPowerMultipliers memory cpMultipliers = communityPowerMultipliers;

      return (
          (votes * cpMultipliers.votes) + 
          (proposalsCreated * cpMultipliers.proposalsCreated) + 
          (proposalsPassed * cpMultipliers.proposalsPassed)
        ) / PERCENT;
    }

    
    
    
    function getTotalVotingPower() public view returns (uint) {
      return totalTokenVotingPower + getCommunityVotingPower(address(type(uint160).max));
    }

    function getStakedTokenSupplies() public view returns (uint128, uint128) {
      return (stakedFrankenPunks, stakedFrankenMonsters);
    }

    
    
    
    
    function evilBonus(uint _tokenId) public view returns (uint) {
      if (_tokenId >= 10000) return 0; 
      return (EVIL_BITMAPS[_tokenId >> 8] >> (255 - (_tokenId & 255)) & 1) * 10;
    }

  /////////////////////////////////
  //////// OWNER OPERATIONS ///////
  /////////////////////////////////

  
  
  
  function changeStakeTime(uint128 _newMaxStakeBonusTime) external onlyExecutor {
    if (_newMaxStakeBonusTime == 0) revert InvalidParameter();
    emit StakeTimeChanged(stakingSettings.maxStakeBonusTime = _newMaxStakeBonusTime);
  }

  
  
  
  function changeStakeAmount(uint128 _newMaxStakeBonusAmount) external onlyExecutor {
    emit StakeAmountChanged(stakingSettings.maxStakeBonusAmount = _newMaxStakeBonusAmount);
  }

  
  
  
  function setVotesMultiplier(uint64 _votesMultiplier) external onlyExecutor {
    emit VotesMultiplierChanged(communityPowerMultipliers.votes = _votesMultiplier);
  }

  
  
  
  function setProposalsCreatedMultiplier(uint64 _proposalsCreatedMultiplier) external onlyExecutor {
    emit ProposalsCreatedMultiplierChanged(communityPowerMultipliers.proposalsCreated = _proposalsCreatedMultiplier);
  }

  
  
  
  function setProposalsPassedMultiplier(uint64 _proposalsPassedMultiplier) external onlyExecutor {
    emit ProposalPassedMultiplierChanged(communityPowerMultipliers.proposalsPassed =  _proposalsPassedMultiplier);
  }

  
  
  
  
  function setRefunds(bool _stakingRefund, bool _delegatingRefund, uint _newCooldown) external onlyExecutor {
    emit RefundSettingsChanged(
      stakingRefund = _stakingRefund, 
      delegatingRefund = _delegatingRefund,
      refundCooldown = _newCooldown
    );
  }

  
  
  
  function setPause(bool _paused) external onlyPauserOrAdmins {
    emit StakingPause(paused = _paused);
  }

  
  
  function setBaseURI(string calldata _baseURI) external onlyAdmins {
    emit BaseURIChanged(baseTokenURI = _baseURI);
  }

  
  
  function setContractURI(string calldata _newContractURI) external onlyAdmins {
    emit ContractURIChanged(contractURI = _newContractURI);
  }

  
  
  
  function isFrankenPunksStakingContract() external pure returns (bool) {
    return true;
  }

  
  receive() external payable {}

  
  fallback() external payable {}
}

pragma solidity ^0.8.13;

interface IERC721 {
    function approve(address spender, uint id) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
    function balanceOf(address owner) external view returns (uint256);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function getApproved(uint256 tokenId) external view returns (address);
}

pragma solidity ^0.8.10;

interface IExecutor {

    ////////////////////
    ////// Events //////
    ////////////////////

    
    event CancelTransaction(bytes32 indexed txHash, uint256 id, address indexed target, uint256 value, string signature, bytes data, uint256 eta);
    
    event ExecuteTransaction(bytes32 indexed txHash, uint256 id, address indexed target, uint256 value, string signature, bytes data, uint256 eta);
    
    event NewDelay(uint256 indexed newDelay);
    
    event QueueTransaction(bytes32 indexed txHash, uint256 id, address indexed target, uint256 value, string signature, bytes data, uint256 eta);

    /////////////////////
    ////// Methods //////
    /////////////////////

    function DELAY() external view returns (uint256);

    function GRACE_PERIOD() external view returns (uint256);

    function cancelTransaction(uint256 _id, address _target, uint256 _value, string memory _signature, bytes memory _data, uint256 _eta) external;

    function executeTransaction(uint256 _id, address _target, uint256 _value, string memory _signature, bytes memory _data, uint256 _eta) external returns (bytes memory);

    function queueTransaction(uint256 _id, address _target, uint256 _value, string memory _signature, bytes memory _data, uint256 _eta) external returns (bytes32 txHash);

    function queuedTransactions(bytes32) external view returns (bool);
}

pragma solidity ^0.8.10;



interface IGovernance {

    ////////////////////
    ////// Events //////
    ////////////////////

    
    event ProposalCanceled(uint256 id);
    
    event ProposalCreated( uint256 id, address proposer, address[] targets, uint256[] values, string[] signatures, bytes[] calldatas, uint32 startTime, uint32 endTime, uint24 quorumVotes, string description);
    
    event ProposalExecuted(uint256 id);
    
    event ProposalQueued(uint256 id, uint256 eta);
    
    event ProposalVetoed(uint256 id);
    
    event ProposalThresholdBPSSet(uint256 oldProposalThresholdBPS, uint256 newProposalThresholdBPS);
    
    event QuorumVotesBPSSet(uint256 oldQuorumVotesBPS, uint256 newQuorumVotesBPS);
    
    event RefundSet(bool isProposingRefund, bool oldStatus, bool newStatus);
    
    event TotalCommunityScoreDataUpdated(uint64 proposalsCreated, uint64 proposalsPassed, uint64 votes);
    
    event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 votes);
    
    event VotingDelaySet(uint256 oldVotingDelay, uint256 newVotingDelay);
    
    event VotingPeriodSet(uint256 oldVotingPeriod, uint256 newVotingPeriod);
    
    event NewStakingContract(address stakingContract);

    /////////////////////
    ////// Storage //////
    /////////////////////

    struct CommunityScoreData {
        uint64 votes;
        uint64 proposalsCreated;
        uint64 proposalsPassed;
    }

    struct Proposal {
        
        uint96 id;
        
        address proposer;
        
        address[] targets;
        
        uint256[] values;
        
        string[] signatures;
        
        bytes[] calldatas;
        
        uint24 quorumVotes;
        
        uint32 eta;
        
        uint32 startTime;
        
        uint32 endTime;
        
        uint24 forVotes;
        
        uint24 againstVotes;
        
        uint24 abstainVotes;
        
        bool verified;
        
        bool canceled;
        
        bool vetoed;
        
        bool executed;
        
        mapping(address => Receipt) receipts;
    }

    
    struct Receipt {
        
        bool hasVoted;
        
        uint8 support;
        
        uint24 votes;
    }

    
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed,
        Vetoed
    }

    /////////////////////
    ////// Methods //////
    /////////////////////

    function MAX_PROPOSAL_THRESHOLD_BPS() external view returns (uint256);
    function MAX_QUORUM_VOTES_BPS() external view returns (uint256);
    function MAX_VOTING_DELAY() external view returns (uint256);
    function MAX_VOTING_PERIOD() external view returns (uint256);
    function MIN_PROPOSAL_THRESHOLD_BPS() external view returns (uint256);
    function MIN_QUORUM_VOTES_BPS() external view returns (uint256);
    function MIN_VOTING_DELAY() external view returns (uint256);
    function MIN_VOTING_PERIOD() external view returns (uint256);
    function PROPOSAL_MAX_OPERATIONS() external view returns (uint256);
    function activeProposals(uint256) external view returns (uint256);
    function cancel(uint256 _proposalId) external;
    function castVote(uint256 _proposalId, uint8 _support) external;
    function clear(uint256 _proposalId) external;
    function execute(uint256 _proposalId) external;
    function getActions(uint256 _proposalId)
        external
        view
        returns (
            address[] memory targets,
            uint256[] memory values,
            string[] memory signatures,
            bytes[] memory calldatas
        );
    function getActiveProposals() external view returns (uint256[] memory);
    function getProposalData(uint256 _proposalId) external view returns (uint256, address, uint256);
    function getProposalStatus(uint256 _proposalId) external view returns (bool, bool, bool, bool);
    function getProposalVotes(uint256 _proposalId) external view returns (uint256, uint256, uint256);
    function getReceipt(uint256 _proposalId, address _voter) external view returns (Receipt memory);
    function initialize(
        address _staking,
        address _executor,
        address _founders,
        address _council,
        uint256 _votingPeriod,
        uint256 _votingDelay,
        uint256 _proposalThresholdBPS,
        uint256 _quorumVotesBPS
    ) external;
    function latestProposalIds(address) external view returns (uint256);
    function name() external view returns (string memory);
    function proposalCount() external view returns (uint256);
    function proposalRefund() external view returns (bool);
    function proposalThreshold() external view returns (uint256);
    function proposalThresholdBPS() external view returns (uint256);
    function proposals(uint256)
        external
        view
        returns (
            uint96 id,
            address proposer,
            uint24 quorumVotes,
            uint32 eta,
            uint32 startTime,
            uint32 endTime,
            uint24 forVotes,
            uint24 againstVotes,
            uint24 abstainVotes,
            bool verified,
            bool canceled,
            bool vetoed,
            bool executed
        );
    function propose(
        address[] memory _targets,
        uint256[] memory _values,
        string[] memory _signatures,
        bytes[] memory _calldatas,
        string memory _description
    ) external returns (uint256);
    function queue(uint256 _proposalId) external;
    function quorumVotes() external view returns (uint256);
    function quorumVotesBPS() external view returns (uint256);
    function setProposalThresholdBPS(uint256 _newProposalThresholdBPS) external;
    function setQuorumVotesBPS(uint256 _newQuorumVotesBPS) external;
    function setRefunds(bool _votingRefund, bool _proposalRefund) external;
    function setStakingAddress(IStaking _newStaking) external;
    function setVotingDelay(uint256 _newVotingDelay) external;
    function setVotingPeriod(uint256 _newVotingPeriod) external;
    function staking() external view returns (IStaking);
    function state(uint256 _proposalId) external view returns (ProposalState);
    function totalCommunityScoreData()
        external
        view
        returns (uint64 votes, uint64 proposalsCreated, uint64 proposalsPassed);
    function updateTotalCommunityScoreData(uint64 _votes, uint64 _proposalsCreated, uint64 _proposalsPassed) external;
    function userCommunityScoreData(address)
        external
        view
        returns (uint64 votes, uint64 proposalsCreated, uint64 proposalsPassed);
    function verifyProposal(uint256 _proposalId) external;
    function veto(uint256 _proposalId) external;
    function votingDelay() external view returns (uint256);
    function votingPeriod() external view returns (uint256);
    function votingRefund() external view returns (bool);
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }
}