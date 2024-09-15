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











/** @dev Loosely forked from NounsDAOLogicV1.sol (0xa43afe317985726e4e194eb061af77fbcb43f944) with following major modifications:
- add gas refunding for voting and creating proposals
- pack proposal struct into fewer storage slots 
- track votes, proposals created, and proposal passed by user for community score calculation
- track votes, proposals created, and proposal passed across all users counting towards community voting power
- removed tempProposal from the proposal creation process
- added a verification step for new proposals to confirm they passed Snapshot pre-governance
- adjusted roles and permissions
- added an array to track Active Proposals and a clear() function to remove them 
- removed the ability to pass a reason along with a vote, and to vote by EIP-712 signature
- allow the contract to receive Ether (for gas refunds)
 */
contract Governance is IGovernance, Admin, Refundable {
    using SafeCast for uint;

    
    string public constant name = "FrankenDAO";

    
    IStaking public staking;

    //////////////////////////
    //// Voting Constants ////
    //////////////////////////

    
    
    uint256 public constant MIN_VOTING_DELAY = 1 hours;

    
    
    uint256 public constant MAX_VOTING_DELAY = 1 weeks;

    
    
    uint256 public constant MIN_VOTING_PERIOD = 1 days; 

    
    
    uint256 public constant MAX_VOTING_PERIOD = 14 days;

    
    
    uint256 public constant MIN_PROPOSAL_THRESHOLD_BPS = 1; // 1 basis point or 0.01%

    
    
    uint256 public constant MAX_PROPOSAL_THRESHOLD_BPS = 1_000; // 1,000 basis points or 10%

    
    
    uint256 public constant MIN_QUORUM_VOTES_BPS = 200; // 200 basis points or 2%

    
    
    uint256 public constant MAX_QUORUM_VOTES_BPS = 2_000; // 2,000 basis points or 20%

    
    uint256 public constant PROPOSAL_MAX_OPERATIONS = 10; // 10 actions

    ///////////////////////////
    //// Voting Parameters ////
    ///////////////////////////

    
    uint256 public votingDelay;

    
    uint256 public votingPeriod;

    
    uint256 public proposalThresholdBPS;

    
    uint256 public quorumVotesBPS;

    
    bool public votingRefund;

    
    bool public proposalRefund;

    //////////////////
    //// Proposal ////
    //////////////////

    
    uint256 public proposalCount;

    
    mapping(uint256 => Proposal) public proposals;

    
    /** @dev Admins (or anyone else) will regularly clear out proposals that have been defeated 
             by calling clear() to keep gas costs of iterating through this array low  */
    uint256[] public activeProposals;

    
    mapping(address => uint256) public latestProposalIds;

    
    mapping(address => bool) public bannedProposers;

    
    mapping(address => CommunityScoreData) public userCommunityScoreData;

    
    /** @dev Users only get community voting power if they currently have token voting power (ie have staked, undelegated tokens 
            or are delegated to). These totals adjust as users stake, undelegate, or delegate to ensure they only reflect the current 
            total community score. Therefore, these totals will not equal the sum of the totals in the userCommunityScoreData mapping. */
    
    CommunityScoreData public totalCommunityScoreData;


    
    
    
    
    
    
    
    
    
    function initialize(
        address _staking,
        address _executor,
        address _founders,
        address _council,
        uint256 _votingPeriod,
        uint256 _votingDelay,
        uint256 _proposalThresholdBPS,
        uint256 _quorumVotesBPS
    ) public {
        // Check whether this contract has already been initialized.
        if (address(executor) != address(0)) revert AlreadyInitialized();
        if (address(_executor) == address(0)) revert ZeroAddress();

        if (_votingDelay < MIN_VOTING_DELAY || _votingDelay > MAX_VOTING_DELAY) revert ParameterOutOfBounds();
        if (_votingPeriod < MIN_VOTING_PERIOD || _votingPeriod > MAX_VOTING_PERIOD) revert ParameterOutOfBounds();
        if (_proposalThresholdBPS < MIN_PROPOSAL_THRESHOLD_BPS || _proposalThresholdBPS > MAX_PROPOSAL_THRESHOLD_BPS) revert ParameterOutOfBounds();
        if (_quorumVotesBPS < MIN_QUORUM_VOTES_BPS || _quorumVotesBPS > MAX_QUORUM_VOTES_BPS) revert ParameterOutOfBounds();

        executor = IExecutor(_executor);
        founders = _founders;
        council = _council;
        staking = IStaking(_staking);

        votingRefund = true;
        proposalRefund = true;

        emit VotingDelaySet(0, votingDelay = _votingDelay);
        emit VotingPeriodSet(0, votingPeriod = _votingPeriod);
        emit ProposalThresholdBPSSet(0, proposalThresholdBPS = _proposalThresholdBPS);
        emit QuorumVotesBPSSet(0, quorumVotesBPS = _quorumVotesBPS);
    }

    ///////////////////
    //// Modifiers ////
    ///////////////////

    modifier cancelable(uint _proposalId) {
        Proposal storage proposal = proposals[_proposalId];

        if (
            // Proposals that are executed, canceled, or vetoed have already been removed from
            // ActiveProposals array and the Executor queue.
            state(_proposalId) == ProposalState.Executed ||
            state(_proposalId) == ProposalState.Canceled ||
            state(_proposalId) == ProposalState.Vetoed ||

            // Proposals that are Defeated or Expired should be cleared instead, to preserve their state.
            state(_proposalId) == ProposalState.Defeated ||
            state(_proposalId) == ProposalState.Expired
        ) revert InvalidStatus();

        _;
    }

    ///////////////
    //// Views ////
    ///////////////

    
    
    
    
    
    
    function getActions(uint256 _proposalId) external view returns (
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas
    ) {
        Proposal storage p = proposals[_proposalId];
        return (p.targets, p.values, p.signatures, p.calldatas);
    }

    
    
    
    
    
    function getProposalData(uint256 _proposalId) public view returns (uint256, address, uint256) {
        Proposal storage p = proposals[_proposalId];
        return (p.id, p.proposer, p.quorumVotes);
    }

    
    
    
    
    
    
    function getProposalStatus(uint256 _proposalId) public view returns (bool, bool, bool, bool) {
        Proposal storage p = proposals[_proposalId];
        return (p.verified, p.canceled, p.vetoed, p.executed);
    }

    
    
    
    
    
    function getProposalVotes(uint256 _proposalId) public view returns (uint256, uint256, uint256) {
        Proposal storage p = proposals[_proposalId];
        return (p.forVotes, p.againstVotes, p.abstainVotes);
    }

    
    
    function getActiveProposals() public view returns (uint256[] memory) {
        return activeProposals;
    }

    
    
    
    
    
    function getReceipt(uint256 _proposalId, address _voter) external view returns (Receipt memory) {
        return proposals[_proposalId].receipts[_voter];
    }

    
    
    
    function state(uint256 _proposalId) public view returns (ProposalState) {
        if (_proposalId > proposalCount) revert InvalidId();
        Proposal storage proposal = proposals[_proposalId];

        // If the proposal has been vetoed, it should always return Vetoed.
        if (proposal.vetoed) {
            return ProposalState.Vetoed;

        // If the proposal isn't verified by the time it ends, it's Canceled.
        } else if (proposal.canceled || (!proposal.verified && block.timestamp > proposal.endTime)) {
            return ProposalState.Canceled;

        // If it's unverified at any time before end time, or if it is verified but is before start time, it's Pending.
        }  else if (block.timestamp < proposal.startTime || !proposal.verified) {
            return ProposalState.Pending;
        
        // If it's verified and after start time but before end time, it's Active.
        } else if (block.timestamp <= proposal.endTime) {
            return ProposalState.Active;

        // If this is the case, it means it was verified and it's after the end time. 
        // The YES votes must be greater than the NO votes, and greater than or equal to quorumVotes to pass.
        // If it doesn't meet these criteria, it's Defeated.
        } else if (proposal.forVotes <= proposal.againstVotes || proposal.forVotes < proposal.quorumVotes) {
            return ProposalState.Defeated;

        // If this is the case, the proposal passed, but it hasn't been queued yet, so it's Succeeded.
        } else if (proposal.eta == 0) {
            return ProposalState.Succeeded;

        // execute() has been called, so the transaction has been run and the proposal is Executed.
        } else if (proposal.executed) {
            return ProposalState.Executed;

        // If execute() hasn't been run and we're GRACE_PERIOD after the eta, it's Expired.
        } else if (block.timestamp >= proposal.eta + executor.GRACE_PERIOD()) {
            return ProposalState.Expired;
        
        // Otherwise, it's queued, unexecuted, and within the GRACE_PERIOD, so we're Queued.
        } else {
            return ProposalState.Queued;
        }
    }

    
    
    function proposalThreshold() public view returns (uint256) {
        return bps2Uint(proposalThresholdBPS, staking.getTotalVotingPower());
    }

    
    
    function quorumVotes() public view returns (uint256) {
        return bps2Uint(quorumVotesBPS, staking.getTotalVotingPower());
    }

    ///////////////////
    //// Proposals ////
    ///////////////////

    
    
    
    
    
    
    
    function propose(
        address[] memory _targets,
        uint256[] memory _values,
        string[] memory _signatures,
        bytes[] memory _calldatas,
        string memory _description
    ) public returns (uint256) {
        uint proposalId;

        // Refunds gas if proposalRefund is true
        if (proposalRefund) {
            uint256 startGas = gasleft();
            proposalId = _propose(_targets, _values, _signatures, _calldatas, _description);
            _refundGas(startGas);
        } else {
            proposalId = _propose(_targets, _values, _signatures, _calldatas, _description);
        }
        return proposalId;
    }

    
    
    
    
    
    
    
    function _propose(
        address[] memory _targets,
        uint256[] memory _values,
        string[] memory _signatures,
        bytes[] memory _calldatas,
        string memory _description
    ) internal returns (uint256) {
        // Confirm the user hasn't been banned
        if (bannedProposers[msg.sender]) revert NotAuthorized();

        // Confirm the proposer meets the proposalThreshold
        uint votesNeededToPropose = proposalThreshold();
        if (staking.getVotes(msg.sender) < votesNeededToPropose) revert NotEligible();

        // Validate the proposal's actions
        if (_targets.length == 0) revert InvalidProposal();
        if (_targets.length > PROPOSAL_MAX_OPERATIONS) revert InvalidProposal();
        if (
            _targets.length != _values.length ||
            _targets.length != _signatures.length ||
            _targets.length != _calldatas.length
        ) revert InvalidProposal();

        // Ensure the proposer doesn't already have an active or pending proposal
        uint latestProposalId = latestProposalIds[msg.sender];
        if (latestProposalId != 0) {
            ProposalState proposersLatestProposalState = state(latestProposalId);
            if (
                proposersLatestProposalState == ProposalState.Active || 
                proposersLatestProposalState == ProposalState.Pending
            ) revert NotEligible();
        }
        
        // Create a new proposal in storage, and fill it with the correct data
        uint newProposalId = ++proposalCount;
        Proposal storage newProposal = proposals[newProposalId];

        // All non-array values in the Proposal struct are packed into 2 storage slots:
        // Slot 1: id (96) + proposer (address, 160)
        // Slot 2: quorumVotes (24), eta (32), startTime (32), endTime (32), forVotes (24), 
        //         againstVotes (24), canceled (8), vetoed (8), executed (8), verified (8)
        
        // All times are stored as uint32s, which takes us through the year 2106 (we can upgrade then :))
        // All votes are stored as uint24s with lots of buffer, since max votes in system is < 4 million
        // (10k punks * (max 50 token VP + max ~100 community VP) + 10k monsters * (max 25 token VP + max ~100 community VP))
        
        newProposal.id = newProposalId.toUint96();
        newProposal.proposer = msg.sender;
        newProposal.targets = _targets;
        newProposal.values = _values;
        newProposal.signatures = _signatures;
        newProposal.calldatas = _calldatas;
        newProposal.quorumVotes = quorumVotes().toUint24();
        newProposal.startTime = (block.timestamp + votingDelay).toUint32();
        newProposal.endTime = (block.timestamp + votingDelay + votingPeriod).toUint32();
        
        // Other values are set automatically:
        //  - forVotes, againstVotes, and abstainVotes = 0
        //  - verified, canceled, executed, and vetoed = false
        //  - eta = 0

        latestProposalIds[newProposal.proposer] = newProposalId;
        activeProposals.push(newProposalId);

        emit ProposalCreated(
            newProposalId,
            msg.sender,
            _targets,
            _values,
            _signatures,
            _calldatas,
            newProposal.startTime,
            newProposal.endTime,
            newProposal.quorumVotes,
            _description
        );

        return newProposalId;
    }

    
    
    
    
    function verifyProposal(uint _proposalId) external onlyVerifierOrAdmins {
        // Can only verify proposals that are currently in the Pending state
        if (state(_proposalId) != ProposalState.Pending) revert InvalidStatus();

        Proposal storage proposal = proposals[_proposalId];
        
        if (proposal.verified) revert InvalidStatus();
        proposal.verified = true;

        // If a proposal was valid, we are ready to award the community voting power bonuses to the proposer
        ++userCommunityScoreData[proposal.proposer].proposalsCreated;
        
        // We don't need to check whether the proposer is accruing community voting power because
        // they needed that voting power to propose, and once they have an Active Proposal, their
        // tokens are locked from delegating and unstaking.
        ++totalCommunityScoreData.proposalsCreated;
    }

    /////////////////
    //// Execute ////
    /////////////////

    
    
    function queue(uint256 _proposalId) external {
        // Succeeded means we're past the endTime, yes votes outweigh no votes, and quorum threshold is met
        if(state(_proposalId) != ProposalState.Succeeded) revert InvalidStatus();

        Proposal storage proposal = proposals[_proposalId];

        // Set the ETA (time for execution) to the soonest time based on the Executor's delay
        uint256 eta = block.timestamp + executor.DELAY();
        proposal.eta = eta.toUint32();

        // Queue separate transactions for each action in the proposal
        uint numTargets = proposal.targets.length;
        for (uint256 i = 0; i < numTargets; i++) {
            executor.queueTransaction(i, proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], eta);
        }

        // If a proposal is queued, we are ready to award the community voting power bonuses to the proposer
        ++userCommunityScoreData[proposal.proposer].proposalsPassed;

        // We don't need to check whether the proposer is accruing community voting power because
        // they needed that voting power to propose, and once they have an Active Proposal, their
        // tokens are locked from delegating and unstaking.
        ++totalCommunityScoreData.proposalsPassed;

        // Remove the proposal from the Active Proposals array
        _removeFromActiveProposals(_proposalId);

        emit ProposalQueued(_proposalId, eta);
    }

    
    
    function execute(uint256 _proposalId) external {
        // Queued means the proposal is passed, queued, and within the grace period.
        if (state(_proposalId) != ProposalState.Queued) revert InvalidStatus();

        Proposal storage proposal = proposals[_proposalId];
        proposal.executed = true;

        // Separate transactions were queued for each action in the proposal, so execute each separately
        for (uint256 i = 0; i < proposal.targets.length; i++) {
            executor.executeTransaction(
                i, proposal.targets[i], proposal.values[i], proposal.signatures[i], proposal.calldatas[i], proposal.eta
            );
        }

        emit ProposalExecuted(_proposalId);
    }

    ////////////////////////////////
    //// Cancel / Veto Proposal ////
    ////////////////////////////////

    
    
    
    function veto(uint256 _proposalId) external cancelable(_proposalId) onlyAdmins {
        Proposal storage proposal = proposals[_proposalId];

        // If the proposal is queued or executed, remove it from the Executor's queuedTransactions mapping
        // Otherwise, remove it from the Active Proposals array
        _removeTransactionWithQueuedOrExpiredCheck(proposal);

        // Update the vetoed flag so the proposal's state is Vetoed
        proposal.vetoed = true;

        // Remove Community Voting Power someone might have earned from creating
        // the proposal
        if (proposal.verified) {
            --userCommunityScoreData[proposal.proposer].proposalsCreated;
            --totalCommunityScoreData.proposalsCreated;
        }

        if (state(_proposalId) == ProposalState.Queued) {
            --userCommunityScoreData[proposal.proposer].proposalsPassed;
            --totalCommunityScoreData.proposalsPassed;
        }

        emit ProposalVetoed(_proposalId);
    }

    
    
    function cancel(uint256 _proposalId) external cancelable(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];

        // Proposals can be canceled if proposer themselves decide to cancel the proposal (at any time before execution)
        // Nouns allows anyone to cancel if proposer falls below threshold, but because tokens are locked, this isn't possible
        if (msg.sender != proposal.proposer) revert NotEligible();

        // If the proposal is queued or executed, remove it from the Executor's queuedTransactions mapping
        // Otherwise, remove it from the Active Proposals array
        _removeTransactionWithQueuedOrExpiredCheck(proposal);

        // Set the canceled flag to true to change the status to Canceled
        proposal.canceled = true;   

        emit ProposalCanceled(_proposalId);
    }

    
    
    function clear(uint256 _proposalId) external {
        Proposal storage proposal = proposals[_proposalId];

        // This function can only be called in three situations:
        // 1. EXPIRED: The proposal was queued but the grace period has passed (removes it from Executor's 
        //    queuedTransactions). We use this instead of using cancel() so Expired state is preserved.
        // 2. DEFEATED: The proposal is over and was not passed (removes it from ActiveProposals array).
        //    We use this instead of using cancel() so Defeated state is preserved.
        // 3. UNVERIFIED AFTER END TIME (CANCELED): The proposal remained unverified through the endTime and is 
        //    now considered canceled (removes it from ActiveProposals array). We use this because cancel() is 
        //    not allowed to be called on canceled proposals, but this situation is a special case where the 
        //    proposal still needs to be removed from the ActiveProposals array.
        if (
            state(_proposalId) != ProposalState.Expired &&
            state(_proposalId) != ProposalState.Defeated && 
            (proposal.verified || block.timestamp <= proposal.endTime)
        ) revert NotEligible();

        // If the proposal is Expired, remove it from the Executor's queuedTransactions mapping
        // If the proposal is Defeated or Canceled, remove it from the Active Proposals array
        _removeTransactionWithQueuedOrExpiredCheck(proposal);

        emit ProposalCanceled(_proposalId);
    }

    ////////////////
    //// Voting ////
    ////////////////

    
    
    
    function castVote(uint256 _proposalId, uint8 _support) external {
        // Refunds gas if votingRefund is true
        if (votingRefund) {
            uint256 startGas = gasleft();
            uint votes = _castVote(msg.sender, _proposalId, _support);
            emit VoteCast( msg.sender, _proposalId, _support, votes);
            _refundGas(startGas);
        } else {
            uint votes = _castVote(msg.sender, _proposalId, _support);
            emit VoteCast( msg.sender, _proposalId, _support, votes);
        }
    }

    
    
    
    
    
    function _castVote(address _voter, uint256 _proposalId, uint8 _support) internal returns (uint) {
        // Only Active proposals can be voted on
        if (state(_proposalId) != ProposalState.Active) revert InvalidStatus();
        
        // Only valid values for _support are 0 (against), 1 (for), and 2 (abstain)
        if (_support > 2) revert InvalidInput();

        Proposal storage proposal = proposals[_proposalId];

        // If the voter has already voted, revert        
        Receipt storage receipt = proposal.receipts[_voter];
        if (receipt.hasVoted) revert AlreadyVoted();

        // Calculate the number of votes a user is able to cast
        // This takes into account delegation and community voting power
        uint24 votes = (staking.getVotes(_voter)).toUint24();

        if (votes == 0) revert NotEligible();

        // Update the proposal's total voting records based on the votes
        if (_support == 0) {
            proposal.againstVotes = proposal.againstVotes + votes;
        } else if (_support == 1) {
            proposal.forVotes = proposal.forVotes + votes;
        } else if (_support == 2) {
            proposal.abstainVotes = proposal.abstainVotes + votes;
        }

        // Update the user's receipt for this proposal
        receipt.hasVoted = true;
        receipt.support = _support;
        receipt.votes = votes;

        // Make these updates after the vote so it doesn't impact voting power for this vote.
        ++totalCommunityScoreData.votes;

        // We can update the total community voting power with no check because if you can vote, 
        // it means you have votes so you haven't delegated.
        ++userCommunityScoreData[_voter].votes;

        return votes;
    }


    /////////////////
    //// Helpers ////
    /////////////////
    
    
    
    
    function bps2Uint(uint256 _bps, uint256 _number) internal pure returns (uint256) {
        return (_number * _bps) / 10000;
    }

    
    
    function _removeTransactionWithQueuedOrExpiredCheck(Proposal storage _proposal) internal {
        if (
            state(_proposal.id) == ProposalState.Queued || 
            state(_proposal.id) == ProposalState.Expired
        ) {
            for (uint256 i = 0; i < _proposal.targets.length; i++) {
                executor.cancelTransaction(
                    i,
                    _proposal.targets[i],
                    _proposal.values[i],
                    _proposal.signatures[i],
                    _proposal.calldatas[i],
                    _proposal.eta
                );
            }
        } else {
            _removeFromActiveProposals(_proposal.id);
        }
    }

    
    
    
    function _removeFromActiveProposals(uint256 _id) private {
        uint256 index;
        uint[] memory actives = activeProposals;

        bool found = false;
        for (uint256 i = 0; i < actives.length; i++) {
            if (actives[i] == _id) {
                found = true;
                index = i;
                break;
            }
        }

        // This is important because otherwise, if the proposal is not found, it will remove the first index
        // There shouldn't be any ways to call this with an ID that isn't in the array, but this is here for extra safety
        if (!found) revert NotInActiveProposals();

        activeProposals[index] = activeProposals[actives.length - 1];
        activeProposals.pop();
    }
    
    
    
    
    
    /** @dev This is used by the staking contract to update these values when users stake, unstake, delegate, 
        so that we are able to calculate total community score that equals the sum of individual community scores,
        since these actions can move their scores to 0 and back. */
    function updateTotalCommunityScoreData(uint64 _votes, uint64 _proposalsCreated, uint64 _proposalsPassed) external {
        if (msg.sender != address(staking)) revert NotAuthorized();

        totalCommunityScoreData.proposalsCreated = _proposalsCreated;
        totalCommunityScoreData.proposalsPassed = _proposalsPassed;
        totalCommunityScoreData.votes = _votes;

        emit TotalCommunityScoreDataUpdated(_proposalsCreated, _proposalsPassed, _votes);
    }

    ///////////////
    //// Admin ////
    ///////////////

    
    
    
    function setRefunds(bool _votingRefund, bool _proposalRefund) external onlyExecutor {
        
        emit RefundSet(false, votingRefund, _votingRefund);
        emit RefundSet(true, proposalRefund, _proposalRefund);
        
        votingRefund = _votingRefund;
        proposalRefund = _proposalRefund;
    }

    
    
    function setVotingDelay(uint256 _newVotingDelay) external onlyExecutor {
        if (_newVotingDelay < MIN_VOTING_DELAY || _newVotingDelay > MAX_VOTING_DELAY) revert ParameterOutOfBounds();

        emit VotingDelaySet(votingDelay, _newVotingDelay);

        votingDelay = _newVotingDelay;
    }

    
    
    function setVotingPeriod(uint256 _newVotingPeriod) external onlyExecutor {
        if (_newVotingPeriod < MIN_VOTING_PERIOD || _newVotingPeriod > MAX_VOTING_PERIOD) revert ParameterOutOfBounds();

        emit VotingPeriodSet(votingPeriod, _newVotingPeriod);

        votingPeriod = _newVotingPeriod;        
    }

    
    
    /** @dev This function can be called by the multisigs or by governance, to ensure
        it can be decreased in the event that governance isn't able to hit the threshold. */
    function setProposalThresholdBPS(uint256 _newProposalThresholdBPS) external onlyExecutorOrAdmins {
        if (_newProposalThresholdBPS < MIN_PROPOSAL_THRESHOLD_BPS || _newProposalThresholdBPS > MAX_PROPOSAL_THRESHOLD_BPS) revert ParameterOutOfBounds();
        
        emit ProposalThresholdBPSSet(proposalThresholdBPS, _newProposalThresholdBPS);
        
        proposalThresholdBPS = _newProposalThresholdBPS;
    }

    
    
    /** @dev This function can be called by the multisigs or by governance, to ensure
        it can be decreased in the event that governance isn't able to hit the threshold. */
    function setQuorumVotesBPS(uint256 _newQuorumVotesBPS) external onlyExecutorOrAdmins {
        if (_newQuorumVotesBPS < MIN_QUORUM_VOTES_BPS || _newQuorumVotesBPS > MAX_QUORUM_VOTES_BPS) revert ParameterOutOfBounds();

        emit QuorumVotesBPSSet(quorumVotesBPS, _newQuorumVotesBPS);
        
        quorumVotesBPS = _newQuorumVotesBPS;
    }

    
    
    
    
    function banProposer(address _proposer, bool _banned) external onlyExecutorOrAdmins {
        bannedProposers[_proposer] = _banned;
    }

    
    
    
    function setStakingAddress(IStaking _newStaking) external onlyExecutor {
        try _newStaking.isFrankenPunksStakingContract() returns (bool isStaking) {
            if (!isStaking) revert NotStakingContract();
        } catch {
            revert NotStakingContract();
        }

        staking = _newStaking;

        emit NewStakingContract(address(_newStaking));
    }

    
    receive() external payable {}

    
    fallback() external payable {}
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