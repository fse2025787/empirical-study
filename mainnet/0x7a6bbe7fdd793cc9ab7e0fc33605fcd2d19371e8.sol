pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2022-06-02
*/

pragma solidity 0.6.7;


interface DSDelegateTokenLike {
    function totalSupply() external view returns (uint);
    function getPriorVotes(address account, uint blockNumber) external view returns (uint256);
}

interface DSPauseLike {
    function proxy() external view returns (address);
    function delay() external view returns (uint);
    function scheduleTransaction(address, bytes32, bytes calldata, uint) external;
    function executeTransaction(address, bytes32, bytes calldata, uint) external;
    function abandonTransaction(address, bytes32, bytes calldata, uint) external;
    function authority() external view returns (address);
    function getTransactionDataHash(address, bytes32, bytes calldata, uint) external pure returns (bytes32);
    function scheduledTransactions(bytes32) external view returns (bool);
}

contract GovernorBravoEvents {
    
    event ProposalCreated(uint id, address proposer, address[] targets, uint[] values, string[] signatures, bytes[] calldatas, uint startBlock, uint endBlock, string description);

    
    
    
    
    
    
    event VoteCast(address indexed voter, uint proposalId, uint8 support, uint votes, string reason);

    
    event ProposalCanceled(uint id);

    
    event ProposalQueued(uint id, uint eta);

    
    event ProposalExecuted(uint id);

    
    event VotingDelaySet(uint oldVotingDelay, uint newVotingDelay);

    
    event VotingPeriodSet(uint oldVotingPeriod, uint newVotingPeriod);

    
    event NewImplementation(address oldImplementation, address newImplementation);

    
    event QuorumVotesSet(uint oldProposalThreshold, uint newProposalThreshold);

    
    event ProposalThresholdSet(uint oldQuorumVotes, uint newQuorumVotes);

    
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    
    event NewAdmin(address oldAdmin, address newAdmin);

    
    event NewTimelock(address oldTimelock, address newTimelock);
}

contract GovernorBravoDelegatorStorage {
    
    address public admin;

    
    address public pendingAdmin;
}

/**
 * @title Storage for Governor Bravo Delegate
 * @notice For future upgrades, do not change GovernorBravoDelegateStorageV1. Create a new
 * contract which implements GovernorBravoDelegateStorageV1 and following the naming convention
 * GovernorBravoDelegateStorageVX.
 */
contract GovernorBravoDelegateStorageV1 is GovernorBravoDelegatorStorage {

    
    uint public votingDelay;

    
    uint public votingPeriod;

    
    uint public quorumVotes;

    
    uint public proposalThreshold;

    
    uint public proposalCount;

    
    DSPauseLike public timelock;

    
    DSDelegateTokenLike public governanceToken;

    
    mapping (uint => Proposal) public proposals;

    
    mapping (address => uint) public latestProposalIds;


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

        
        uint abstainVotes;

        
        bool canceled;

        
        bool executed;

        
        mapping (address => Receipt) receipts;
    }

    
    struct Receipt {
        
        bool hasVoted;

        
        uint8 support;

        
        uint96 votes;
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
}

contract GovernorBravo is GovernorBravoDelegateStorageV1, GovernorBravoEvents {

    
    string public constant name = "RAI Governor";

    
    uint public constant MIN_PROPOSAL_THRESHOLD = 1000 ether; // 15,000 protocol tokens

    
    uint public constant MAX_PROPOSAL_THRESHOLD = 15000 ether; // 50,000 protocol tokens

    
    uint public constant MIN_VOTING_PERIOD = 6600; // About 24 hours

    
    uint public constant MAX_VOTING_PERIOD = 46500; // About 7 days

    
    uint public constant MIN_VOTING_DELAY = 1;

    
    uint public constant MAX_VOTING_DELAY = 6600; // About 24 hours

    
    uint public constant MIN_QUORUM_VOTES = 10000 ether; // 10,000 protocol tokens

    
    uint public constant MAX_QUORUM_VOTES = 100000 ether; // 100,000 protocol tokens

    
    uint public constant proposalMaxOperations = 10; // 10 actions

    
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    
    bytes32 public constant BALLOT_TYPEHASH = keccak256("Ballot(uint256 proposalId,uint8 support)");

    /**
      * @notice Constructor
      * @param timelock_ The address of the tmelock
      * @param governanceToken_ The address of the (un)governance token
      * @param votingPeriod_ The initial voting period
      * @param votingDelay_ The initial voting delay
      * @param proposalThreshold_ The initial proposal threshold
      */
    constructor(address timelock_, address governanceToken_, uint votingPeriod_, uint votingDelay_, uint quorumVotes_, uint proposalThreshold_) public {
        require(timelock_ != address(0), "GovernorBravo::initialize: invalid timelock address");
        require(governanceToken_ != address(0), "GovernorBravo::initialize: invalid gov token address");
        require(votingPeriod_ >= MIN_VOTING_PERIOD && votingPeriod_ <= MAX_VOTING_PERIOD, "GovernorBravo::initialize: invalid voting period");
        require(votingDelay_ >= MIN_VOTING_DELAY && votingDelay_ <= MAX_VOTING_DELAY, "GovernorBravo::initialize: invalid voting delay");
        require(quorumVotes_ >= MIN_QUORUM_VOTES && quorumVotes_ <= MAX_QUORUM_VOTES, "GovernorBravo::initialize: invalid vote quorum");
        require(proposalThreshold_ >= MIN_PROPOSAL_THRESHOLD && proposalThreshold_ <= MAX_PROPOSAL_THRESHOLD, "GovernorBravo::initialize: invalid proposal threshold");

        timelock = DSPauseLike(timelock_);
        governanceToken = DSDelegateTokenLike(governanceToken_);
        votingPeriod = votingPeriod_;
        votingDelay = votingDelay_;
        quorumVotes = quorumVotes_;
        proposalThreshold = proposalThreshold_;
        admin = timelock.proxy();
    }

    /**
      * @notice Function used to propose a new proposal. Sender must have delegates above the proposal threshold
      * @param targets Target addresses for proposal calls
      * @param calldatas Calldatas for proposal calls
      * @param description String description of the proposal
      * @return Proposal id of new proposal
      */
    function propose(address[] memory targets, uint[] memory /* values */, string[] memory /* signatures */, bytes[] memory calldatas, string memory description) public returns (uint) {
        require(governanceToken.getPriorVotes(msg.sender, sub256(block.number, 1)) > proposalThreshold, "GovernorBravo::propose: proposer votes below proposal threshold");
        require(targets.length == calldatas.length, "GovernorBravo::propose: proposal function information arity mismatch");
        require(targets.length != 0, "GovernorBravo::propose: must provide actions");
        require(targets.length <= proposalMaxOperations, "GovernorBravo::propose: too many actions");

        uint latestProposalId = latestProposalIds[msg.sender];
        if (latestProposalId != 0) {
          ProposalState proposersLatestProposalState = state(latestProposalId);
          require(proposersLatestProposalState != ProposalState.Active, "GovernorBravo::propose: one live proposal per proposer, found an already active proposal");
          require(proposersLatestProposalState != ProposalState.Pending, "GovernorBravo::propose: one live proposal per proposer, found an already pending proposal");
        }

        uint startBlock = add256(block.number, votingDelay);
        uint endBlock = add256(startBlock, votingPeriod);

        proposalCount++;
        Proposal memory newProposal = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            eta: 0,
            targets: targets,
            values: new uint[](0),
            signatures: new string[](0),
            calldatas: calldatas,
            startBlock: startBlock,
            endBlock: endBlock,
            forVotes: 0,
            againstVotes: 0,
            abstainVotes: 0,
            canceled: false,
            executed: false
        });

        proposals[newProposal.id] = newProposal;
        latestProposalIds[newProposal.proposer] = newProposal.id;

        emit ProposalCreated(newProposal.id, msg.sender, targets, new uint[](0), new string[](0), calldatas, startBlock, endBlock, description);
        return newProposal.id;
    }

    /**
      * @notice Queues a proposal of state succeeded
      * @param proposalId The id of the proposal to queue
      */
    function queue(uint proposalId) external {
        require(state(proposalId) == ProposalState.Succeeded, "GovernorBravo::queue: proposal can only be queued if it is succeeded");
        Proposal storage proposal = proposals[proposalId];
        uint eta = add256(block.timestamp, timelock.delay());
        bytes32 codeHash;
        address usr;
        for (uint i = 0; i < proposal.targets.length; i++) {
            usr = proposal.targets[i];
            assembly { codeHash := extcodehash(usr) }
            timelock.scheduleTransaction(usr, codeHash, proposal.calldatas[i], eta);
        }
        proposal.eta = eta;
        emit ProposalQueued(proposalId, eta);
    }

    /**
      * @notice Executes a queued proposal if eta has passed
      * @param proposalId The id of the proposal to execute
      */
    function execute(uint proposalId) external payable {
        require(state(proposalId) == ProposalState.Queued, "GovernorBravo::execute: proposal can only be executed if it is queued");
        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;

        bytes32 codeHash;
        address usr;
        bytes32 scheduledTransactionHash;
        for (uint i = 0; i < proposal.targets.length; i++) {
            usr = proposal.targets[i];
            assembly { codeHash := extcodehash(usr) }
            scheduledTransactionHash = timelock.getTransactionDataHash(usr, codeHash, proposal.calldatas[i], proposal.eta);
            if (timelock.scheduledTransactions(scheduledTransactionHash)) // will skip proposals already executed straight into pause
                timelock.executeTransaction(usr, codeHash, proposal.calldatas[i], proposal.eta);
        }
        emit ProposalExecuted(proposalId);
    }

    /**
      * @notice Cancels a proposal only if sender is the proposer, or proposer delegates dropped below proposal threshold
      * @param proposalId The id of the proposal to cancel
      */
    function cancel(uint proposalId) external {
        require(state(proposalId) != ProposalState.Executed, "GovernorBravo::cancel: cannot cancel executed proposal");

        Proposal storage proposal = proposals[proposalId];
        require(msg.sender == proposal.proposer || governanceToken.getPriorVotes(proposal.proposer, sub256(block.number, 1)) < proposalThreshold, "GovernorBravo::cancel: proposer above threshold");
        proposal.canceled = true;

        if (state(proposalId) == ProposalState.Queued) {
            bytes32 codeHash;
            address usr;
            for (uint i = 0; i < proposal.targets.length; i++) {
                usr = proposal.targets[i];
                assembly { codeHash := extcodehash(usr) }
                timelock.abandonTransaction(usr, codeHash, proposal.calldatas[i], proposal.eta);
            }
        }

        emit ProposalCanceled(proposalId);
    }

    /**
      * @notice Gets actions of a proposal
      * @param proposalId the id of the proposal
      * @return Targets, values, signatures, and calldatas of the proposal actions
      */
    function getActions(uint proposalId) external view returns (address[] memory, uint[] memory, string[] memory, bytes[] memory) {
        Proposal storage p = proposals[proposalId];
        return (p.targets, p.values, p.signatures, p.calldatas);
    }

    /**
      * @notice Gets the receipt for a voter on a given proposal
      * @param proposalId the id of proposal
      * @param voter The address of the voter
      * @return The voting receipt
      */
    function getReceipt(uint proposalId, address voter) external view returns (Receipt memory) {
        return proposals[proposalId].receipts[voter];
    }

    /**
      * @notice Gets the state of a proposal
      * @param proposalId The id of the proposal
      * @return Proposal state
      */
    function state(uint proposalId) public view returns (ProposalState) {
        require(proposalCount >= proposalId, "GovernorBravo::state: invalid proposal id");
        Proposal storage proposal = proposals[proposalId];
        if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (block.number <= proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.number <= proposal.endBlock) {
            return ProposalState.Active;
        } else if (proposal.forVotes <= proposal.againstVotes || proposal.forVotes < quorumVotes) {
            return ProposalState.Defeated;
        } else if (proposal.eta == 0) {
            return ProposalState.Succeeded;
        } else if (proposal.executed) {
            return ProposalState.Executed;
        } else {
            return ProposalState.Queued;
        }
    }

    /**
      * @notice Cast a vote for a proposal
      * @param proposalId The id of the proposal to vote on
      * @param support The support value for the vote. 0=against, 1=for, 2=abstain
      */
    function castVote(uint proposalId, uint8 support) external {
        emit VoteCast(msg.sender, proposalId, support, castVoteInternal(msg.sender, proposalId, support), "");
    }

    /**
      * @notice Cast a vote for a proposal with a reason
      * @param proposalId The id of the proposal to vote on
      * @param support The support value for the vote. 0=against, 1=for, 2=abstain
      * @param reason The reason given for the vote by the voter
      */
    function castVoteWithReason(uint proposalId, uint8 support, string calldata reason) external {
        emit VoteCast(msg.sender, proposalId, support, castVoteInternal(msg.sender, proposalId, support), reason);
    }

    /**
      * @notice Cast a vote for a proposal by signature
      * @dev External function that accepts EIP-712 signatures for voting on proposals.
      */
    function castVoteBySig(uint proposalId, uint8 support, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainIdInternal(), address(this)));
        bytes32 structHash = keccak256(abi.encode(BALLOT_TYPEHASH, proposalId, support));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "GovernorBravo::castVoteBySig: invalid signature");
        emit VoteCast(signatory, proposalId, support, castVoteInternal(signatory, proposalId, support), "");
    }

    /**
      * @notice Internal function that caries out voting logic
      * @param voter The voter that is casting their vote
      * @param proposalId The id of the proposal to vote on
      * @param support The support value for the vote. 0=against, 1=for, 2=abstain
      * @return The number of votes cast
      */
    function castVoteInternal(address voter, uint proposalId, uint8 support) internal returns (uint96) {
        require(state(proposalId) == ProposalState.Active, "GovernorBravo::castVoteInternal: voting is closed");
        require(support <= 2, "GovernorBravo::castVoteInternal: invalid vote type");
        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];
        require(receipt.hasVoted == false, "GovernorBravo::castVoteInternal: voter already voted");
        uint96 votes = uint96(governanceToken.getPriorVotes(voter, proposal.startBlock));

        if (support == 0) {
            proposal.againstVotes = add256(proposal.againstVotes, votes);
        } else if (support == 1) {
            proposal.forVotes = add256(proposal.forVotes, votes);
        } else if (support == 2) {
            proposal.abstainVotes = add256(proposal.abstainVotes, votes);
        }

        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;

        return votes;
    }

    /**
      * @notice Admin function for setting the voting delay
      * @param newVotingDelay new voting delay, in blocks
      */
    function _setVotingDelay(uint newVotingDelay) external {
        require(msg.sender == admin, "GovernorBravo::_setVotingDelay: admin only");
        require(newVotingDelay >= MIN_VOTING_DELAY && newVotingDelay <= MAX_VOTING_DELAY, "GovernorBravo::_setVotingDelay: invalid voting delay");
        emit VotingDelaySet(votingDelay, newVotingDelay);
        votingDelay = newVotingDelay;
    }

    /**
      * @notice Admin function for setting the voting period
      * @param newVotingPeriod new voting period, in blocks
      */
    function _setVotingPeriod(uint newVotingPeriod) external {
        require(msg.sender == admin, "GovernorBravo::_setVotingPeriod: admin only");
        require(newVotingPeriod >= MIN_VOTING_PERIOD && newVotingPeriod <= MAX_VOTING_PERIOD, "GovernorBravo::_setVotingPeriod: invalid voting period");
        emit VotingPeriodSet(votingPeriod, newVotingPeriod);
        votingPeriod = newVotingPeriod;
    }

    /**
      * @notice Admin function for setting the vote quorum to validate a proposal
      * @dev newQuorumVotes must be greater than the hardcoded min
      * @param newQuorumVotes new proposal quorum
      */
    function _setQuorumVotes(uint newQuorumVotes) external {
        require(msg.sender == admin, "GovernorBravo::_setProposalThreshold: admin only");
        require(newQuorumVotes >= MIN_QUORUM_VOTES && newQuorumVotes <= MAX_QUORUM_VOTES, "GovernorBravo::initialize: invalid vote quorum");
        emit QuorumVotesSet(quorumVotes, newQuorumVotes);
        quorumVotes = newQuorumVotes;
    }

    /**
      * @notice Admin function for setting the proposal threshold
      * @dev newProposalThreshold must be greater than the hardcoded min
      * @param newProposalThreshold new proposal threshold
      */
    function _setProposalThreshold(uint newProposalThreshold) external {
        require(msg.sender == admin, "GovernorBravo::_setProposalThreshold: admin only");
        require(newProposalThreshold >= MIN_PROPOSAL_THRESHOLD && newProposalThreshold <= MAX_PROPOSAL_THRESHOLD, "GovernorBravo::_setProposalThreshold: invalid proposal threshold");
        emit ProposalThresholdSet(proposalThreshold, newProposalThreshold);
        proposalThreshold = newProposalThreshold;
    }

    /**
      * @notice Begins transfer of admin rights. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @dev Admin function to begin change of admin. The newPendingAdmin must call `_acceptAdmin` to finalize the transfer.
      * @param newPendingAdmin New pending admin.
      */
    function _setPendingAdmin(address newPendingAdmin) external {
        // Check caller = admin
        require(msg.sender == admin, "GovernorBravo:_setPendingAdmin: admin only");

        // Save current value, if any, for inclusion in log
        address oldPendingAdmin = pendingAdmin;

        // Store pendingAdmin with value newPendingAdmin
        pendingAdmin = newPendingAdmin;

        // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    /**
      * @notice Accepts transfer of admin rights. msg.sender must be pendingAdmin
      * @dev Admin function for pending admin to accept role and update admin
      */
    function _acceptAdmin() external {
        // Check caller is pendingAdmin and pendingAdmin ≠ address(0)
        require(msg.sender == pendingAdmin && msg.sender != address(0), "GovernorBravo:_acceptAdmin: pending admin only");

        // Save current values for inclusion in log
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        // Store admin with value pendingAdmin
        admin = pendingAdmin;

        // Clear the pending value
        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

    /**
      * @notice Admin function for changing the timelock address
      * @dev If timelock.proxy() is the admin, it is also swapped for newTimelock.proxy()
      * @param newTimelock new timelock address
      */
    function _setTimelock(address newTimelock) external {
        require(msg.sender == admin, "GovernorBravo::_setProposalThreshold: admin only");

        // if admin is timelock.proxy also swap it
        if (admin == timelock.proxy()) {
            admin = DSPauseLike(newTimelock).proxy();
            emit NewAdmin(timelock.proxy(), admin);
        }

        emit NewTimelock(address(timelock), newTimelock);
        timelock = DSPauseLike(newTimelock);
    }

    function add256(uint256 a, uint256 b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    function sub256(uint256 a, uint256 b) internal pure returns (uint) {
        require(b <= a, "subtraction underflow");
        return a - b;
    }

    function getChainIdInternal() internal pure returns (uint) {
        uint chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}