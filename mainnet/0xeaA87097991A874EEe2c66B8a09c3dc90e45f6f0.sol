pragma experimental ABIEncoderV2;


contract GovernorBravoDelegatorStorage {
  
  address public admin;

  
  address public pendingAdmin;

  
  address public implementation;
}

pragma solidity ^0.5.16;


contract GovernorBravoEvents {
  
  event ProposalCreated(
    uint256 id,
    address proposer,
    address[] targets,
    uint256[] values,
    string[] signatures,
    bytes[] calldatas,
    uint256 startBlock,
    uint256 endBlock,
    string description
  );

  
  
  
  
  
  
  event VoteCast(
    address indexed voter,
    uint256 proposalId,
    uint8 support,
    uint256 votes,
    string reason
  );

  
  event ProposalCanceled(uint256 id);

  
  event ProposalQueued(uint256 id, uint256 eta);

  
  event ProposalExecuted(uint256 id);

  
  event VotingDelaySet(uint256 oldVotingDelay, uint256 newVotingDelay);

  
  event VotingPeriodSet(uint256 oldVotingPeriod, uint256 newVotingPeriod);

  
  event NewImplementation(address oldImplementation, address newImplementation);

  
  event ProposalThresholdSet(
    uint256 oldProposalThreshold,
    uint256 newProposalThreshold
  );

  
  event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

  
  event NewAdmin(address oldAdmin, address newAdmin);

  
  event WhitelistAccountExpirationSet(address account, uint256 expiration);

  
  event WhitelistGuardianSet(address oldGuardian, address newGuardian);
}

/**
 * @title Storage for Governor Bravo Delegate
 * @notice For future upgrades, do not change GovernorBravoDelegateStorageV1. Create a new
 * contract which implements GovernorBravoDelegateStorageV1 and following the naming convention
 * GovernorBravoDelegateStorageVX.
 */
contract GovernorBravoDelegateStorageV1 is GovernorBravoDelegatorStorage {
  
  uint256 public votingDelay;

  
  uint256 public votingPeriod;

  
  uint256 public proposalThreshold;

  
  uint256 public initialProposalId;

  
  uint256 public proposalCount;

  
  TimelockInterface public timelock;

  
  OndoInterface public ondo;

  
  mapping(uint256 => Proposal) public proposals;

  
  mapping(address => uint256) public latestProposalIds;

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
    
    mapping(address => Receipt) receipts;
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
pragma solidity ^0.5.16;




contract GovernorBravoDelegator is
  GovernorBravoDelegatorStorage,
  GovernorBravoEvents
{
  constructor(
    address timelock_,
    address ondo_,
    address admin_,
    address implementation_,
    uint256 votingPeriod_,
    uint256 votingDelay_,
    uint256 proposalThreshold_
  ) public {
    // Admin set to msg.sender for initialization
    admin = msg.sender;

    delegateTo(
      implementation_,
      abi.encodeWithSignature(
        "initialize(address,address,uint256,uint256,uint256)",
        timelock_,
        ondo_,
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
    require(
      msg.sender == admin,
      "GovernorBravoDelegator::_setImplementation: admin only"
    );
    require(
      implementation_ != address(0),
      "GovernorBravoDelegator::_setImplementation: invalid implementation address"
    );

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
        revert(add(returnData, 0x20), returndatasize)
      }
    }
  }

  /**
   * @dev Delegates execution to an implementation contract.
   * It returns to the external caller whatever the implementation returns
   * or forwards reverts.
   */
  function() external payable {
    // delegate all other functions to current implementation
    (bool success, ) = implementation.delegatecall(msg.data);

    assembly {
      let free_mem_ptr := mload(0x40)
      returndatacopy(free_mem_ptr, 0, returndatasize)

      switch success
        case 0 {
          revert(free_mem_ptr, returndatasize)
        }
        default {
          return(free_mem_ptr, returndatasize)
        }
    }
  }
}

contract GovernorBravoDelegateStorageV2 is GovernorBravoDelegateStorageV1 {
  
  mapping(address => uint256) public whitelistAccountExpirations;

  
  address public whitelistGuardian;
}

interface TimelockInterface {
  function delay() external view returns (uint256);

  function GRACE_PERIOD() external view returns (uint256);

  function acceptAdmin() external;

  function queuedTransactions(bytes32 hash) external view returns (bool);

  function queueTransaction(
    address target,
    uint256 value,
    string calldata signature,
    bytes calldata data,
    uint256 eta
  ) external returns (bytes32);

  function cancelTransaction(
    address target,
    uint256 value,
    string calldata signature,
    bytes calldata data,
    uint256 eta
  ) external;

  function executeTransaction(
    address target,
    uint256 value,
    string calldata signature,
    bytes calldata data,
    uint256 eta
  ) external payable returns (bytes memory);
}

interface OndoInterface {
  function getPriorVotes(address account, uint256 blockNumber)
    external
    view
    returns (uint96);
}