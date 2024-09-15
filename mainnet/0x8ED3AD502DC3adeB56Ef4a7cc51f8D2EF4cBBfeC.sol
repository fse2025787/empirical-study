// SPDX-License-Identifier: BSD-3-Clause

// 



/*

&_--~- ,_                     /""\      ,
{        ",       THE       <>^  L____/|
(  )_ ,{ ,[email protected]       FARM	     `) /`   , /
 |/  {|\{           GAME       \ `---' /
 ""   " "                       `'";\)`
W: https://thefarm.game           _/_Y
T: @The_Farm_Game

 * Howdy folks! Thanks for glancing over our contracts
 * If you're interested in working with us, you can email us at [email protected]
 * Found a broken egg in our contracts? We have a bug bounty program [email protected]
 * Y'all have a nice day

*/

// LICENSE
// TheFarmDAOInterfaces.sol is a modified version of Compound Lab's GovernorBravoInterfaces.sol:
// https://github.com/compound-finance/compound-protocol/blob/b9b14038612d846b83f8a009a82c38974ff2dcfe/contracts/Governance/GovernorBravoInterfaces.sol
//
// GovernorBravoInterfaces.sol source code Copyright 2020 Compound Labs, Inc. licensed under the BSD-3-Clause license.
// With modifications by Nounders DAO.
//
// Additional conditions of BSD-3-Clause can be found here: https://opensource.org/licenses/BSD-3-Clause
//
// MODIFICATIONS
// TheFarmDAOEvents, TheFarmDAOProxyStorage, TheFarmDAOStorageV1 adds support for changes made by TheFarm DAO to GovernorBravo.sol
// See TheFarmDAOLogicV1.sol for more details.

pragma solidity ^0.8.17;

contract TheFarmDAOEvents {
  
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

  event ProposalCreatedWithRequirements(
    uint256 id,
    address proposer,
    address[] targets,
    uint256[] values,
    string[] signatures,
    bytes[] calldatas,
    uint256 startBlock,
    uint256 endBlock,
    uint256 proposalThreshold,
    uint256 quorumVotes,
    string description
  );

  
  
  
  
  
  
  event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 votes, string reason);

  
  event ProposalCanceled(uint256 id);

  
  event ProposalQueued(uint256 id, uint256 eta);

  
  event ProposalExecuted(uint256 id);

  
  event ProposalVetoed(uint256 id);

  
  event VotingDelaySet(uint256 oldVotingDelay, uint256 newVotingDelay);

  
  event VotingPeriodSet(uint256 oldVotingPeriod, uint256 newVotingPeriod);

  
  event NewImplementation(address oldImplementation, address newImplementation);

  
  event ProposalThresholdBPSSet(uint256 oldProposalThresholdBPS, uint256 newProposalThresholdBPS);

  
  event QuorumVotesBPSSet(uint256 oldQuorumVotesBPS, uint256 newQuorumVotesBPS);

  
  event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

  
  event NewAdmin(address oldAdmin, address newAdmin);

  
  event NewVetoer(address oldVetoer, address newVetoer);
}

contract TheFarmDAOProxyStorage {
  
  address public admin;

  
  address public pendingAdmin;

  
  address public implementation;
}

/**
 * @title Storage for Governor Bravo Delegate
 * @notice For future upgrades, do not change TheFarmDAOStorageV1. Create a new
 * contract which implements TheFarmDAOStorageV1 and following the naming convention
 * TheFarmDAOStorageVX.
 */
contract TheFarmDAOStorageV1 is TheFarmDAOProxyStorage {
  
  address public vetoer;

  
  uint256 public votingDelay;

  
  uint256 public votingPeriod;

  
  uint256 public proposalThresholdBPS;

  
  uint256 public quorumVotesBPS;

  
  uint256 public proposalCount;

  
  ITheFarmDAOExecutor public timelock;

  
  FarmAnimalsNFTLike public farmAnimals;

  
  mapping(uint256 => Proposal) public proposals;

  
  mapping(address => uint256) public latestProposalIds;

  struct Proposal {
    
    uint256 id;
    
    address proposer;
    
    uint256 proposalThreshold;
    
    uint256 quorumVotes;
    
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
    
    bool vetoed;
    
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
    Executed,
    Vetoed
  }
}

interface ITheFarmDAOExecutor {
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

interface FarmAnimalsNFTLike {
  function getPriorVotes(address account, uint256 blockNumber) external view returns (uint96);

  function totalSupply() external view returns (uint96);
}

// 



/*

&_--~- ,_                     /""\      ,
{        ",       THE       <>^  L____/|
(  )_ ,{ ,[email protected]       FARM	     `) /`   , /
 |/  {|\{           GAME       \ `---' /
 ""   " "                       `'";\)`
W: https://thefarm.game           _/_Y
T: @The_Farm_Game

 * Howdy folks! Thanks for glancing over our contracts
 * If you're interested in working with us, you can email us at [email protected]
 * Found a broken egg in our contracts? We have a bug bounty program [email protected]
 * Y'all have a nice day

*/

// LICENSE
// TheFarmDAOProxy.sol is a modified version of Compound Lab's GovernorBravoDelegator.sol:
// https://github.com/compound-finance/compound-protocol/blob/b9b14038612d846b83f8a009a82c38974ff2dcfe/contracts/Governance/GovernorBravoDelegator.sol
//
// GovernorBravoDelegator.sol source code Copyright 2020 Compound Labs, Inc. licensed under the BSD-3-Clause license.
// With modifications by Nounders DAO.
//
// Additional conditions of BSD-3-Clause can be found here: https://opensource.org/licenses/BSD-3-Clause
//
//
// TheFarmDAOProxy.sol uses parts of Open Zeppelin's Proxy.sol:
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/5c8746f56b4bed8cc9e0e044f5f69ab2f9428ce1/contracts/proxy/Proxy.sol
//
// Proxy.sol source code licensed under MIT License.
//
// MODIFICATIONS
// The fallback() and receive() functions of Proxy.sol have been used to allow Solidity > 0.6.0 compatibility

pragma solidity ^0.8.17;



contract TheFarmDAOProxy is TheFarmDAOProxyStorage, TheFarmDAOEvents {
  constructor(
    address timelock_,
    address farmAnimals_,
    address vetoer_,
    address admin_,
    address implementation_,
    uint256 votingPeriod_,
    uint256 votingDelay_,
    uint256 proposalThresholdBPS_,
    uint256 quorumVotesBPS_
  ) {
    // Admin set to msg.sender for initialization
    admin = msg.sender;

    delegateTo(
      implementation_,
      abi.encodeWithSignature(
        'initialize(address,address,address,uint256,uint256,uint256,uint256)',
        timelock_,
        farmAnimals_,
        vetoer_,
        votingPeriod_,
        votingDelay_,
        proposalThresholdBPS_,
        quorumVotesBPS_
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
    require(msg.sender == admin, 'TheFarmDAOProxy::_setImplementation: admin only');
    require(implementation_ != address(0), 'TheFarmDAOProxy::_setImplementation: invalid implementation address');

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
  function _fallback() internal {
    // delegate all other functions to current implementation
    (bool success, ) = implementation.delegatecall(msg.data);

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

  /**
   * @dev Fallback function that delegates calls to the `implementation`. Will run if no other
   * function in the contract matches the call data.
   */
  fallback() external payable {
    _fallback();
  }

  /**
   * @dev Fallback function that delegates calls to `implementation`. Will run if call data
   * is empty.
   */
  receive() external payable {
    _fallback();
  }
}