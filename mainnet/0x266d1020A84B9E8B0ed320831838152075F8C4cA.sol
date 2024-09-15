// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;


// 
pragma solidity 0.8.9;




interface IGovernorCharlieDelegator {
  function _setImplementation(address implementation_) external;

  fallback() external payable;

  receive() external payable;
}


interface GovernorCharlieEvents {
  
  event ProposalCreated(
    uint256 indexed id,
    address indexed proposer,
    address[] targets,
    uint256[] values,
    string[] signatures,
    bytes[] calldatas,
    uint256 indexed startBlock,
    uint256 endBlock,
    string description
  );

  
  
  
  
  
  
  event VoteCast(address indexed voter, uint256 indexed proposalId, uint8 support, uint256 votes, string reason);

  
  event ProposalCanceled(uint256 indexed id);

  
  event ProposalQueued(uint256 indexed id, uint256 eta);

  
  event ProposalExecuted(uint256 indexed id);

  
  event VotingDelaySet(uint256 oldVotingDelay, uint256 newVotingDelay);

  
  event VotingPeriodSet(uint256 oldVotingPeriod, uint256 newVotingPeriod);

  
  event EmergencyVotingPeriodSet(uint256 oldEmergencyVotingPeriod, uint256 emergencyVotingPeriod);

  
  event NewImplementation(address oldImplementation, address newImplementation);

  
  event ProposalThresholdSet(uint256 oldProposalThreshold, uint256 newProposalThreshold);

  
  event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

  
  event NewAdmin(address oldAdmin, address newAdmin);

  
  event WhitelistAccountExpirationSet(address account, uint256 expiration);

  
  event WhitelistGuardianSet(address oldGuardian, address newGuardian);

  
  event NewDelay(uint256 oldTimelockDelay, uint256 proposalTimelockDelay);

  
  event NewEmergencyDelay(uint256 oldEmergencyTimelockDelay, uint256 emergencyTimelockDelay);

  
  event NewQuorum(uint256 oldQuorumVotes, uint256 quorumVotes);

  
  event NewEmergencyQuorum(uint256 oldEmergencyQuorumVotes, uint256 emergencyQuorumVotes);

  
  event CancelTransaction(
    bytes32 indexed txHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 eta
  );

  
  event ExecuteTransaction(
    bytes32 indexed txHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 eta
  );

  
  event QueueTransaction(
    bytes32 indexed txHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 eta
  );
}

// 
pragma solidity 0.8.9;




contract GovernorCharlieDelegatorStorage {
  
  address public implementation;
}
// 
pragma solidity 0.8.9;





contract GovernorCharlieDelegator is GovernorCharlieDelegatorStorage, GovernorCharlieEvents, IGovernorCharlieDelegator {
  constructor(
    address ipt_,
    address implementation_,
    uint256 votingPeriod_,
    uint256 votingDelay_,
    uint256 proposalThreshold_,
    uint256 proposalTimelockDelay_,
    uint256 quorumVotes_,
    uint256 emergencyQuorumVotes_,
    uint256 emergencyVotingPeriod_,
    uint256 emergencyTimelockDelay_
  ) {
    delegateTo(
      implementation_,
      abi.encodeWithSignature(
        "initialize(address,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256)",
        ipt_,
        votingPeriod_,
        votingDelay_,
        proposalThreshold_,
        proposalTimelockDelay_,
        quorumVotes_,
        emergencyQuorumVotes_,
        emergencyVotingPeriod_,
        emergencyTimelockDelay_
      )
    );
    address oldImplementation = implementation;
    implementation = implementation_;
    emit NewImplementation(oldImplementation, implementation);
  }

  /**
   * @notice Called by itself via governance to update the implementation of the delegator
   * @param implementation_ The address of the new implementation for delegation
   */
  function _setImplementation(address implementation_) public override {
    require(msg.sender == address(this), "governance proposal required");
    require(implementation_ != address(0), "invalid implementation address");

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
    //solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returnData) = callee.delegatecall(data);
    //solhint-disable-next-line no-inline-assembly
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
  // solhint-disable-next-line no-complex-fallback
  fallback() external payable override {
    // delegate all other functions to current implementation
    //solhint-disable-next-line avoid-low-level-calls
    (bool success, ) = implementation.delegatecall(msg.data);

    //solhint-disable-next-line no-inline-assembly
    assembly {
      let free_mem_ptr := mload(0x40)
      returndatacopy(free_mem_ptr, 0, returndatasize())

      switch success
      case 0 {
        revert(free_mem_ptr, returndatasize())
      }
      default {
        return(free_mem_ptr, returndatasize())
      }
    }
  }

  receive() external payable override {}
}


interface IGovernorCharlieDelegate {
  function initialize(
    address ipt_,
    uint256 votingPeriod_,
    uint256 votingDelay_,
    uint256 proposalThreshold_,
    uint256 proposalTimelockDelay_,
    uint256 quorumVotes_,
    uint256 emergencyQuorumVotes_,
    uint256 emergencyVotingPeriod_,
    uint256 emergencyTimelockDelay_
  ) external;

  function propose(
    address[] memory targets,
    uint256[] memory values,
    string[] memory signatures,
    bytes[] memory calldatas,
    string memory description,
    bool emergency
  ) external returns (uint256);

  function queue(uint256 proposalId) external;

  function execute(uint256 proposalId) external payable;

  function executeTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 eta
  ) external payable;

  function cancel(uint256 proposalId) external;

  function getActions(uint256 proposalId)
    external
    view
    returns (
      address[] memory targets,
      uint256[] memory values,
      string[] memory signatures,
      bytes[] memory calldatas
    );

  function getReceipt(uint256 proposalId, address voter) external view returns (Receipt memory);

  function state(uint256 proposalId) external view returns (ProposalState);

  function castVote(uint256 proposalId, uint8 support) external;

  function castVoteWithReason(
    uint256 proposalId,
    uint8 support,
    string calldata reason
  ) external;

  function castVoteBySig(
    uint256 proposalId,
    uint8 support,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  function isWhitelisted(address account) external view returns (bool);

  function _setDelay(uint256 proposalTimelockDelay_) external;

  function _setEmergencyDelay(uint256 emergencyTimelockDelay_) external;

  function _setVotingDelay(uint256 newVotingDelay) external;

  function _setVotingPeriod(uint256 newVotingPeriod) external;

  function _setEmergencyVotingPeriod(uint256 newEmergencyVotingPeriod) external;

  function _setProposalThreshold(uint256 newProposalThreshold) external;

  function _setQuorumVotes(uint256 newQuorumVotes) external;

  function _setEmergencyQuorumVotes(uint256 newEmergencyQuorumVotes) external;

  function _setWhitelistAccountExpiration(address account, uint256 expiration) external;

  function _setWhitelistGuardian(address account) external;
}

/**
 * @title Storage for Governor Charlie Delegate
 * @notice For future upgrades, do not change GovernorCharlieDelegateStorage. Create a new
 * contract which implements GovernorCharlieDelegateStorage and following the naming convention
 * GovernorCharlieDelegateStorageVX.
 */
//solhint-disable-next-line max-states-count
contract GovernorCharlieDelegateStorage is GovernorCharlieDelegatorStorage {
  
  uint256 public quorumVotes;

  
  uint256 public emergencyQuorumVotes;

  
  uint256 public votingDelay;

  
  uint256 public votingPeriod;

  
  uint256 public proposalThreshold;

  
  uint256 public initialProposalId;

  
  uint256 public proposalCount;

  
  IIpt public ipt;

  
  mapping(uint256 => Proposal) public proposals;

  
  mapping(address => uint256) public latestProposalIds;

  
  mapping(bytes32 => bool) public queuedTransactions;

  
  uint256 public proposalTimelockDelay;

  
  mapping(address => uint256) public whitelistAccountExpirations;

  
  address public whitelistGuardian;

  
  uint256 public emergencyVotingPeriod;

  
  uint256 public emergencyTimelockDelay;

  /// all receipts for proposal
  mapping(uint256 => mapping(address => Receipt)) public proposalReceipts;

  
  bool public initialized;
}

// 
pragma solidity 0.8.9;

struct Proposal {
  
  uint256 id;
  
  address proposer;
  
  uint256 eta;
  
  address[] targets;
  
  uint256[] values;
  
  string[] signatures;
  
  bytes[] calldatas;
  
  uint256 startBlock;
  
  uint256 endBlock;
  
  uint256 forVotes;
  
  uint256 againstVotes;
  
  uint256 abstainVotes;
  
  bool canceled;
  
  bool executed;
  
  bool emergency;
  
  uint256 quorumVotes;
  
  uint256 delay;
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

// 
pragma solidity 0.8.9;

interface IIpt {
  function getPriorVotes(address account, uint256 blockNumber) external view returns (uint96);
}