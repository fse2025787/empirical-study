pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2020-09-15
*/

pragma solidity 0.5.17;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

  
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

contract GovernorAlpha is Initializable {
    
    string public constant name = "ASTR Governor Alpha";
    
    uint private quorumVote;
    
    uint private minVoterCount;
    
    uint private minProposalTimeIntervalSec;
    
    uint public lastProposalTimeIntervalSec;

    uint256 public proposalTokens;

    uint256 public lastProposal;

    uint256 public stakeVault;

    
    uint256 public startTime;

    
    function quorumVotes() public view returns (uint) { return quorumVote; }

    
    function proposalMaxOperations() public pure returns (uint) { return 10; } // 10 actions

    
    function votingDelay() public pure returns (uint) { return 1; } // 1 block

    
    function votingPeriod() public pure returns (uint) { return 45500; } // ~7 days in blocks (assuming 15s blocks)
    
    
    function minVotersCount() external view returns (uint) { return minVoterCount; }

    
    TimelockInterface public timelock;

    
    ASTRInterface public ASTR;

    
    IHolders public topTraders;

    
    uint public proposalCount;
    
    // @notice voter info 
    struct VoterInfo {
        
        mapping (address => bool) voterAddress;
        
        uint voterCount;
        
        uint256 governors;
    }

    struct Proposal {
        
        uint id;

        
        address proposer;

        
        uint eta;

        
        address[] targets;

        
        uint[] values;

        
        string[] signatures;

        
        bytes[] calldatas;

        
        uint startBlock;

        
        uint endBlock;

        
        uint forVotes;

        
        uint againstVotes;

        
        bool canceled;

        
        bool executed;

        
        bool fundamentalchanges;

        
        mapping (address => Receipt) receipts;
    }

    
    mapping(uint256 => uint256)public proposalCreatedTime;

    
    struct Receipt {
        
        bool hasVoted;

        
        bool support;

        
        uint votes;
    }

    
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }
    
    
    address public chefAddress;

    
    mapping (uint => VoterInfo) public votersInfo;

    
    mapping (uint => Proposal) public proposals;

    
    mapping (address => uint) public latestProposalIds;

    
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    
    bytes32 public constant BALLOT_TYPEHASH = keccak256("Ballot(uint256 proposalId,bool support)");

    
    event ProposalCreated(uint id, address proposer, address[] targets, uint[] values, string[] signatures, bytes[] calldatas, uint startBlock, uint endBlock, string description);

    
    event VoteCast(address voter, uint proposalId, bool support, uint votes);

    
    event ProposalCanceled(uint id);

    
    event ProposalQueued(uint id, uint eta);

    
    event ProposalExecuted(uint id);

    function initialize(address timelock_, address ASTR_,address _chef) external initializer {
        require(timelock_ != address(0), "Zero Address");
        require(ASTR_ != address(0), "Zero Address");
        require(_chef != address(0), "Zero Address");
        timelock = TimelockInterface(timelock_);
        ASTR = ASTRInterface(ASTR_);
        // topTraders = IHolders(_holders);
        chefAddress = _chef;
        startTime = block.timestamp;
        quorumVote = 40e18;
        minVoterCount = 1;
        minProposalTimeIntervalSec = 1 days;
        proposalTokens = 50000000 * 10**18;
        stakeVault = 6 ;
    }
    /**
     * @notice Update Quorum Value
     * @param _quorumValue New quorum Value.
	 * @dev Update Quorum Votes
     */
    function updateQuorumValue(uint256 _quorumValue) external {
        require(msg.sender == address(timelock), "Call must come from Timelock.");
        quorumVote = _quorumValue; 
    }

    /**
     * @notice Update Stake Vault
     * @param _stakeVault New stake vault value.
	 * @dev Update stake vault value
     */
    function updateStakeVault(uint256 _stakeVault) external {
        require(msg.sender == address(timelock), "Call must come from Timelock.");
        stakeVault = _stakeVault; 
    }

    /**
     * @notice Update Min Voter Value
     * @param _minVotersValue New minimum Votes Value.
	 * @dev Update nummber of minimum voters
     */
    
    function updateMinVotersValue(uint256 _minVotersValue) external {
        require(msg.sender == address(timelock), "Call must come from Timelock.");
        minVoterCount = _minVotersValue; 
    }
    
     /**
     * @notice update Minimum  Proposal Time Interval Sec.
     * @param _minProposalTimeIntervalSec New minimum proposal interval.
	 * @dev Update number of minimum Time for Proposal.
     */
    function updateMinProposalTimeIntervalSec(uint256 _minProposalTimeIntervalSec) external {
        require(msg.sender == address(timelock), "Call must come from Timelock.");
        minProposalTimeIntervalSec = _minProposalTimeIntervalSec; 
    }

     /**
     * @notice update Minimum  Proposal Tokens required.
     * @param _proposalTokens New minimum tokens amount.
	 * @dev Update number of minimum Astra required.
     */

    function updateProposalTokens(uint256 _proposalTokens) external {
        require(msg.sender == address(timelock), "Call must come from Timelock.");
        proposalTokens = _proposalTokens; 
    }
    
    function _acceptAdmin() external {
        timelock.acceptAdmin();
    }

    /**
     * @notice Create a new Proposal
     * @param targets Target contract whose functions will be called.
     * @param values Amount of ether required for function calling.
     * @param signatures Function that will be called.
     * @param calldatas Paramete that will be passed in function paramt in bytes format.
     * @param description Description about proposal.
     * @param _fundametalChanges Check if proposal involved fundamental changes or not.
	 * @dev Create new proposal. Her only top stakers can create proposal and Need to submit 50000000 Astra tokens to create proposal
     */
    function propose(address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description, bool _fundametalChanges) public returns (uint) {
        // Check if entered configuration is correct or not.
        require(targets.length == values.length && targets.length == signatures.length && targets.length == calldatas.length, "GovernorAlpha::propose: proposal function information arity mismatch");
        require(targets.length != 0, "GovernorAlpha::propose: must provide actions");
        require(targets.length <= proposalMaxOperations(), "GovernorAlpha::propose: too many actions");
        // Check if called is top staker or not.
        bool isTopStaker = ChefInterface(chefAddress).checkHighestStaker(0,msg.sender);
        // Check if contract is deployed 90 days ago or not. If yes then caller must be top staker.
        if(block.timestamp<add256(startTime,7776000)){
        require(isTopStaker == true,"GovernorAlpha::propose: Only Top stakers can create proposal");
        }
        // Deposit some Astra tokens to create proposal.
        (bool transferStatus) = depositToken(msg.sender, address(this), proposalTokens);
        stakeToken(msg.sender, proposalTokens);
        // Check transfer status
        require(transferStatus == true, "GovernorAlpha::propose: need to transfer some tokens on contract to create proposal");
        // Check the minimum proposal that can be created in a single day.
        require(add256(lastProposalTimeIntervalSec, sub256(minProposalTimeIntervalSec, mod256(lastProposalTimeIntervalSec, minProposalTimeIntervalSec))) < now, "GovernorAlpha::propose: Only one proposal can be create in one day");

        // Check if caller has active proposal or not. If so previous proposal must be accepted or failed first.
        uint latestProposalId = latestProposalIds[msg.sender];
        if (latestProposalId != 0) {
          ProposalState proposersLatestProposalState = state(latestProposalId);
          require(proposersLatestProposalState != ProposalState.Active, "GovernorAlpha::propose: one live proposal per proposer, found an already active proposal");
          require(proposersLatestProposalState != ProposalState.Pending, "GovernorAlpha::propose: one live proposal per proposer, found an already pending proposal");
        }
        uint256 returnValue = setProposalDetail( targets, values, signatures, calldatas, description, _fundametalChanges);
        return returnValue;
    }

    /**
	 * @dev Internal function for creating proposal parameter details is similar to propose functions.
     */

    function setProposalDetail(address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description, bool _fundametalChanges)internal returns (uint){
        // Set voting time for proposal.
        uint startBlock = add256(block.number, votingDelay());
        uint endBlock = add256(startBlock, votingPeriod());
        proposalCount = add256(proposalCount,1);
        Proposal memory newProposal = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            eta: 0,
            targets: targets,
            values: values,
            signatures: signatures,
            calldatas: calldatas,
            startBlock: startBlock,
            endBlock: endBlock,
            forVotes: 0,
            againstVotes: 0,
            canceled: false,
            executed: false,
            fundamentalchanges:_fundametalChanges
        });

        // Update details for proposal.
        proposalCreatedTime[proposalCount] = block.number;

        proposals[newProposal.id] = newProposal;
        latestProposalIds[newProposal.proposer] = newProposal.id;
        lastProposalTimeIntervalSec = block.timestamp;
        
        emit ProposalCreated(newProposal.id, msg.sender, targets, values, signatures, calldatas, startBlock, endBlock, description);
        return newProposal.id;
    }

    /**
     * @notice Deposit Astra tokens.
     * @param sender Sender Address
     * @param recipient Reciever Address
     * @param amount Amount to spent
	 * @dev Deposit Astra token at time new proposal
     */

    function depositToken(address sender, address recipient, uint256 amount) internal returns(bool) {
        bool transferStatus = ASTR.transferFrom(sender, recipient, amount);
        return transferStatus;
    }
    /**
     * @notice Stake Astra tokens.
     * @param sender Sender Address
     * @param amount Amount to spent
	 * @dev Stake Astra token at time new proposal
     */

    function stakeToken(address sender, uint256 amount) internal {
        ASTR.approve(address(chefAddress),amount);
        ChefInterface(chefAddress).depositFromDaaAndDAO(0,amount,stakeVault,sender,false);
    }


    /**
     * @notice Queue your proposal.
     * @param proposalId Proposal Id.
	 * @dev Once proposal is accepted put them in queue over timelock. Proposal can only be put in queue if it is succeeded and crossed minimum voter.
     */

    function queue(uint proposalId) external {
        require(state(proposalId) == ProposalState.Succeeded, "GovernorAlpha::queue: proposal can only be queued if it is succeeded");
        require(votersInfo[proposalId].voterCount >= minVoterCount, "GovernorAlpha::queue: proposal require atleast min governers quorum");
        Proposal storage proposal = proposals[proposalId];
        uint eta = add256(block.timestamp, timelock.delay()); 
        for (uint i = 0; i < proposal.targets.length; i++) {
            _queueOrRevert(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], eta);
        }
        proposal.eta = eta;
        emit ProposalQueued(proposalId, eta);
    }

     /**
	 * @dev Internal function called by queue to check if proposal can be queued or not.
     */

    function _queueOrRevert(address target, uint value, string memory signature, bytes memory data, uint eta) internal {
        require(!timelock.queuedTransactions(keccak256(abi.encode(target, value, signature, data, eta))), "GovernorAlpha::_queueOrRevert: proposal action already queued at eta");
        timelock.queueTransaction(target, value, signature, data, eta);
    }

    /**
     * @notice Execute your proposal.
     * @param proposalId Proposal Id.
	 * @dev Once queue time is over you can execute proposal fucntion from here.
     */

    function execute(uint256 proposalId) external payable {
        require(state(proposalId) == ProposalState.Queued, "GovernorAlpha::execute: proposal can only be executed if it is queued");
        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;
        for (uint i = 0; i < proposal.targets.length; i++) {
            timelock.executeTransaction.value(proposal.values[i])(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], proposal.eta);
        }
        lastProposal = proposalId;
        emit ProposalExecuted(proposalId);
    }

    /**
     * @notice Cancel your proposal.
     * @param proposalId Proposal Id.
	 * @dev If proposal is not executed you can cancel that proposal from here.
     */

    function cancel(uint proposalId) external {
        ProposalState state = state(proposalId);
        require(state != ProposalState.Executed, "GovernorAlpha::cancel: cannot cancel executed proposal");

        Proposal storage proposal = proposals[proposalId];

        proposal.canceled = true;
        for (uint i = 0; i < proposal.targets.length; i++) {
            timelock.cancelTransaction(proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], proposal.eta);
        }

        emit ProposalCanceled(proposalId);
    }

    /**
     * @notice Get Actions details
     * @param proposalId Proposal Id.
	 * @dev Get the details of Functions that will be called.
     */

    function getActions(uint proposalId) external view returns (address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory calldatas) {
        Proposal storage p = proposals[proposalId];
        return (p.targets, p.values, p.signatures, p.calldatas);
    }

        /**
     * @notice Get Receipt
     * @param proposalId Proposal Id.
     * @param voter Voter address
	 * @dev Get the details of voted on a particular proposal for a user.
     */

    function getReceipt(uint proposalId, address voter) external view returns (Receipt memory) {
        return proposals[proposalId].receipts[voter];
    }

    /**
     * @notice Get state of proposal
     * @param proposalId Proposal Id.
	 * @dev Check the status of proposal
     */

    function state(uint proposalId) public view returns (ProposalState) {
        require(proposalCount >= proposalId && proposalId > 0, "GovernorAlpha::state: invalid proposal id");
        Proposal storage proposal = proposals[proposalId];
        // Check min governor vote required. Each proposal require some minimum proposal based on its type.
        // For testnet and testing these values are set to lower.
        bool checkifMinGovenor;
        bool checkFastVote = checkfastvote(proposalId);
        uint256 percentage = 10;
        // Check if proposal is fundamental or not. For both different requirment is set.
        // This is used to check if proposal passed minimum governor barrier.
        if(proposal.fundamentalchanges){
            percentage = 20;
            if(votersInfo[proposalId].governors>=51){
                checkifMinGovenor = true;
            }else{
                checkifMinGovenor = false;
            }
        }else{
            if(votersInfo[proposalId].governors>=33){
                checkifMinGovenor = true;
            }else{
                checkifMinGovenor = false;
            }
        }
        // Check if proposal is fast vote or not. Only for non fundamental proposal.
        if(checkFastVote && checkifMinGovenor){
            return ProposalState.Succeeded;
        }
        else if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (block.number <= proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.number <= proposal.endBlock) {
            return ProposalState.Active;
        } else if (proposal.forVotes <= proposal.againstVotes || proposal.forVotes < quorumVotes()) {
            return ProposalState.Defeated;
        } else if (proposal.eta == 0) {
            // Check if proposal matched all the conditions for acceptance.
            if(checkifMinGovenor){
                    if(proposal.againstVotes==0){
                        return ProposalState.Succeeded;
                    }else{
                    uint256 voteper=  div256(mul256(sub256(proposal.forVotes, proposal.againstVotes),100), proposal.againstVotes);
                     if(voteper>percentage){
                        return ProposalState.Succeeded;
                    }
                    }
            }
            return ProposalState.Defeated;
        } else if (proposal.executed) {
            return ProposalState.Executed;
        } else if (block.timestamp >= add256(proposal.eta, timelock.GRACE_PERIOD())) {
            return ProposalState.Expired;
        } else {
            return ProposalState.Queued;
        }
    }

     /**
     * @notice Get fast vote state of proposal
     * @param proposalId Proposal Id.
	 * @dev Check the fast vote status of proposal
     */

    function checkfastvote(uint proposalId) public view returns (bool){
        require(proposalCount >= proposalId && proposalId > 0, "GovernorAlpha::state: invalid proposal id");
        Proposal storage proposal = proposals[proposalId];
        uint256 oneday = add256(proposalCreatedTime[proposalId],6500);
        uint256 percentage = 10;
        bool returnValue;
        // Check if proposal is non fundamental and block number is less than for 1 day since the proposal created.
        if(proposal.fundamentalchanges==false && block.number <= oneday){
            // Check if all conditions are matched or not.
            if (block.number <= proposal.endBlock && proposal.againstVotes <= proposal.forVotes && proposal.forVotes >= quorumVotes()) {
                    // uint256 voteper= proposal.forVotes.sub(proposal.againstVotes).mul(100).div(proposal.againstVotes);
                    if(proposal.againstVotes==0){
                        returnValue = true;
                    }else{
                        uint256 voteper=  div256(mul256(sub256(proposal.forVotes, proposal.againstVotes),100), proposal.againstVotes);
                    if(voteper>percentage){
                        returnValue = true;
                    }
                    }
            }
        }
        return returnValue;
    }

     /**
     * @notice Vote on any proposal
     * @param proposalId Proposal Id.
     * @param support Bool value for your vote
	 * @dev Vote on any proposal true for acceptance and false for defeat.
     */

    function castVote(uint proposalId, bool support) external {
        return _castVote(msg.sender, proposalId, support);
    }

    /**
     * @notice Vote on any proposal
     * @param proposalId Proposal Id.
     * @param support Bool value for your vote
     * @param v Used for signature
     * @param r Used for signature
     * @param s Used for signature
	 * @dev Vote on any proposal true for acceptance and false for defeat. Here you will vote by signature
     */

    function castVoteBySig(uint proposalId, bool support, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(BALLOT_TYPEHASH, proposalId, support));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "GovernorAlpha::castVoteBySig: invalid signature");
        return _castVote(signatory, proposalId, support);
    }
    /**
    * @dev Cast vote internal function.
    */

    function _castVote(address voter, uint proposalId, bool support) internal {
        require(state(proposalId) == ProposalState.Active, "GovernorAlpha::_castVote: voting is closed");
        bool isTopStaker = ChefInterface(chefAddress).checkHighestStaker(0,msg.sender);
        if(!votersInfo[proposalId].voterAddress[voter])
        {
          votersInfo[proposalId].voterAddress[voter] = true;
          votersInfo[proposalId].voterCount = add256(votersInfo[proposalId].voterCount,1);
          if(isTopStaker){
              votersInfo[proposalId].governors = add256(votersInfo[proposalId].governors,1);
          }
        }
        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];
        require(receipt.hasVoted == false, "GovernorAlpha::_castVote: voter already voted");
        // uint256 votes = ASTR.getPriorVotes(voter, proposal.startBlock);
        uint256 votes = ChefInterface(chefAddress).stakingScore(0,voter);
        // votes = votes.mul(ChefInterface(chefAddress).getRewardMultiplier(0,voter)).div(10);
         votes = div256(mul256(votes,ChefInterface(chefAddress).getRewardMultiplier(0,voter)),10);
        if (support) {
            proposal.forVotes = add256(proposal.forVotes, votes);
        } else {
            proposal.againstVotes = add256(proposal.againstVotes, votes);
        }

        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;

        emit VoteCast(voter, proposalId, support, votes);
    }

   /**
    * @dev Functions used for internal safemath purpose.
    */
    function add256(uint256 a, uint256 b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    function sub256(uint256 a, uint256 b) internal pure returns (uint) {
        require(b <= a, "subtraction underflow");
        return a - b;
    }
    
    function mod256(uint a, uint b) internal pure returns (uint) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
    function mul256(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div256(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    } 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }


    function getChainId() internal pure returns (uint) {
        uint chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}

interface TimelockInterface {
    function delay() external view returns (uint);
    function GRACE_PERIOD() external view returns (uint);
    function acceptAdmin() external;
    function queuedTransactions(bytes32 hash) external view returns (bool);
    function queueTransaction(address target, uint value, string calldata signature, bytes calldata data, uint eta) external returns (bytes32);
    function cancelTransaction(address target, uint value, string calldata signature, bytes calldata data, uint eta) external;
    function executeTransaction(address target, uint value, string calldata signature, bytes calldata data, uint eta) external payable returns (bytes memory);
}

interface ASTRInterface {
    function getPriorVotes(address account, uint blockNumber) external view returns (uint);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface ChefInterface{
    function checkHighestStaker(uint256 _pid,address user) external view returns (bool);
   function getRewardMultiplier(uint256 _pid, address _user) external view returns (uint256);
   function stakingScore(uint256 _pid, address _userAddress) external view returns (uint256);
   function depositFromDaaAndDAO(uint256 _pid, uint256 _amount, uint256 vault, address _sender,bool isPremium) external;
}

interface IHolders {
    function checktoptrader(address _addr) external view returns (bool);
}