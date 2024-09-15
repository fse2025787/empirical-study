pragma experimental ABIEncoderV2;


contract GovernorBravoEvents {
    
    event ProposalCreated(
        uint id,
        address proposer,
        address[] targets,
        uint[] values,
        string[] signatures,
        bytes[] calldatas,
        uint startBlock,
        uint endBlock,
        string description
    );

    
    
    
    
    
    
    event VoteCast(address indexed voter, uint proposalId, uint8 support, uint votes, string reason);

    
    event ProposalCanceled(uint id);

    
    event ProposalQueued(uint id, uint eta);

    
    event ProposalExecuted(uint id);

    
    event VotingDelaySet(uint oldVotingDelay, uint newVotingDelay);

    
    event VotingPeriodSet(uint oldVotingPeriod, uint newVotingPeriod);

    
    event NewImplementation(address oldImplementation, address newImplementation);

    
    event ProposalThresholdSet(uint oldProposalThreshold, uint newProposalThreshold);

    
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    
    event NewAdmin(address oldAdmin, address newAdmin);
}

contract GovernorBravoDelegatorStorage {
    
    address public admin;

    
    address public pendingAdmin;

    
    address public implementation;
}
pragma solidity ^0.7.0;




contract InstaGovernorBravoDelegator is GovernorBravoDelegatorStorage, GovernorBravoEvents {
    constructor(
        address timelock_,
        address admin_,
        address token_,
        address implementation_,
        uint votingPeriod_,
        uint votingDelay_,
        uint proposalThreshold_
    ) {
        // Admin set to msg.sender for initialization
        admin = msg.sender;

        delegateTo(
            implementation_,
            abi.encodeWithSignature(
                "initialize(address,address,uint256,uint256,uint256)",
                timelock_,
                token_,
                votingPeriod_,
                votingDelay_,
                proposalThreshold_
            )
        );

        _setImplementation(implementation_);

        admin = admin_;
    }

    /**
     * @notice Called by the admin to update the implementation of the delegator
     * @param implementation_ The address of the new implementation for delegation
     */
    function _setImplementation(address implementation_) public {
        require(msg.sender == admin, "GovernorBravoDelegator::_setImplementation: admin only");
        require(implementation_ != address(0), "GovernorBravoDelegator::_setImplementation: invalid implementation address");

        address oldImplementation = implementation;
        implementation = implementation_;

        emit NewImplementation(oldImplementation, implementation);
    }

    /**
     * @notice Internal method to delegate execution to another contract
     * @dev It returns to the external caller whatever the implementation returns or forwards reverts
     * @param callee The contract to delegatecall
     * @param data The raw data to delegatecall
     */
    function delegateTo(address callee, bytes memory data) internal {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize())
            }
        }
    }

    /**
     * @dev Delegates execution to an implementation contract.
     * It returns to the external caller whatever the implementation returns
     * or forwards reverts.
     */
    fallback () external payable {
        // delegate all other functions to current implementation
        (bool success, ) = implementation.delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())

            switch success
            case 0 { revert(free_mem_ptr, returndatasize()) }
            default { return(free_mem_ptr, returndatasize()) }
        }
    }
}

pragma solidity ^0.7.0;


interface TimelockInterface {
    function delay() external view returns (uint);
    function GRACE_PERIOD() external view returns (uint);
    function acceptAdmin() external;
    function queuedTransactions(bytes32 hash) external view returns (bool);
    function queueTransaction(address target, uint value, string calldata signature, bytes calldata data, uint eta) external returns (bytes32);
    function cancelTransaction(address target, uint value, string calldata signature, bytes calldata data, uint eta) external;
    function executeTransaction(address target, uint value, string calldata signature, bytes calldata data, uint eta) external payable returns (bytes memory);
}

interface TokenInterface {
    function getPriorVotes(address account, uint blockNumber) external view returns (uint96);
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

    
    uint public proposalThreshold;

    
    uint public proposalCount;

    
    TimelockInterface public timelock;

    
    TokenInterface public token;

    
    mapping (uint => Proposal) public proposals;

    
    mapping (address => uint) public latestProposalIds;

    struct Proposal {
        // Unique id for looking up a proposal
        uint id;

        // Creator of the proposal
        address proposer;

        // The timestamp that the proposal will be available for execution, set once the vote succeeds
        uint eta;

        // the ordered list of target addresses for calls to be made
        address[] targets;

        // The ordered list of values (i.e. msg.value) to be passed to the calls to be made
        uint[] values;

        // The ordered list of function signatures to be called
        string[] signatures;

        // The ordered list of calldata to be passed to each call
        bytes[] calldatas;

        // The block at which voting begins: holders must delegate their votes prior to this block
        uint startBlock;

        // The block at which voting ends: votes must be cast prior to this block
        uint endBlock;

        // Current number of votes in favor of this proposal
        uint forVotes;

        // Current number of votes in opposition to this proposal
        uint againstVotes;

        // Current number of votes for abstaining for this proposal
        uint abstainVotes;

        // Flag marking whether the proposal has been canceled
        bool canceled;

        // Flag marking whether the proposal has been executed
        bool executed;

        // Receipts of ballots for the entire set of voters
        mapping (address => Receipt) receipts;
    }

    
    struct Receipt {
        // Whether or not a vote has been cast
        bool hasVoted;

        // Whether or not the voter supports the proposal or abstains
        uint8 support;

        // The number of votes the voter had, which were cast
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
