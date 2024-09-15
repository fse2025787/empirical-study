// SPDX-License-Identifier: BSD-3-Clause


contract AlpsDAOProxyStorage {
    
    address public admin;

    
    address public pendingAdmin;

    
    address public implementation;
}

// 



/*********************************
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░██░░░████░░██░░░████░░░ *
 * ░░██████░░░████████░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *********************************/

// LICENSE
// AlpsDAOInterfaces.sol is a modified version of Compound Lab's GovernorBravoInterfaces.sol:
// https://github.com/compound-finance/compound-protocol/blob/b9b14038612d846b83f8a009a82c38974ff2dcfe/contracts/Governance/GovernorBravoInterfaces.sol
//
// GovernorBravoInterfaces.sol source code Copyright 2020 Compound Labs, Inc. licensed under the BSD-3-Clause license.
// With modifications by Alpers DAO.
//
// Additional conditions of BSD-3-Clause can be found here: https://opensource.org/licenses/BSD-3-Clause
//
// MODIFICATIONS
// AlpsDAOEvents, AlpsDAOProxyStorage, AlpsDAOStorageV1 add support for changes made by Alps DAO to GovernorBravo.sol
// See AlpsDAOLogicV1.sol for more details.
// AlpsDAOStorageV1Adjusted and AlpsDAOStorageV2 add support for a dynamic vote quorum.
// See AlpsDAOLogicV2.sol for more details.

pragma solidity ^0.8.6;

contract AlpsDAOEvents {
    
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

/**
 * @title Extra fields added to the `Proposal` struct from AlpsDAOStorageV1
 * @notice The following fields were added to the `Proposal` struct:
 * - `Proposal.totalSupply`
 * - `Proposal.creationBlock`
 */
contract AlpsDAOStorageV1Adjusted is AlpsDAOProxyStorage {
    
    address public vetoer;

    
    uint256 public votingDelay;

    
    uint256 public votingPeriod;

    
    uint256 public proposalThresholdBPS;

    
    uint256 public quorumVotesBPS;

    
    uint256 public proposalCount;

    
    IAlpsDAOExecutor public timelock;

    
    AlpsTokenLike public alps;

    
    mapping(uint256 => Proposal) internal _proposals;

    
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
        
        uint256 totalSupply;
        
        uint256 creationBlock;
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
// 



/*********************************
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░██░░░████░░██░░░████░░░ *
 * ░░██████░░░████████░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *********************************/

// LICENSE
// AlpsDAOProxy.sol is a modified version of Compound Lab's GovernorBravoDelegator.sol:
// https://github.com/compound-finance/compound-protocol/blob/b9b14038612d846b83f8a009a82c38974ff2dcfe/contracts/Governance/GovernorBravoDelegator.sol
//
// GovernorBravoDelegator.sol source code Copyright 2020 Compound Labs, Inc. licensed under the BSD-3-Clause license.
// With modifications by Alpers DAO.
//
// Additional conditions of BSD-3-Clause can be found here: https://opensource.org/licenses/BSD-3-Clause
//
//
// AlpsDAOProxy.sol uses parts of Open Zeppelin's Proxy.sol:
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/5c8746f56b4bed8cc9e0e044f5f69ab2f9428ce1/contracts/proxy/Proxy.sol
//
// Proxy.sol source code licensed under MIT License.
//
// MODIFICATIONS
// The fallback() and receive() functions of Proxy.sol have been used to allow Solidity > 0.6.0 compatibility

pragma solidity ^0.8.6;



contract AlpsDAOProxy is AlpsDAOProxyStorage, AlpsDAOEvents {
    constructor(
        address timelock_,
        address alps_,
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
                alps_,
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
        require(msg.sender == admin, 'AlpsDAOProxy::_setImplementation: admin only');
        require(implementation_ != address(0), 'AlpsDAOProxy::_setImplementation: invalid implementation address');

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

contract AlpsDAOEventsV2 is AlpsDAOEvents {
    
    event MinQuorumVotesBPSSet(uint16 oldMinQuorumVotesBPS, uint16 newMinQuorumVotesBPS);

    
    event MaxQuorumVotesBPSSet(uint16 oldMaxQuorumVotesBPS, uint16 newMaxQuorumVotesBPS);

    
    event QuorumCoefficientSet(uint32 oldQuorumCoefficient, uint32 newQuorumCoefficient);

    
    event RefundableVote(address indexed voter, uint256 refundAmount, bool refundSent);

    
    event Withdraw(uint256 amount, bool sent);

    
    event NewPendingVetoer(address oldPendingVetoer, address newPendingVetoer);
}

/**
 * @title Storage for Governor Bravo Delegate
 * @notice For future upgrades, do not change AlpsDAOStorageV1. Create a new
 * contract which implements AlpsDAOStorageV1 and following the naming convention
 * AlpsDAOStorageVX.
 */
contract AlpsDAOStorageV1 is AlpsDAOProxyStorage {
    
    address public vetoer;

    
    uint256 public votingDelay;

    
    uint256 public votingPeriod;

    
    uint256 public proposalThresholdBPS;

    
    uint256 public quorumVotesBPS;

    
    uint256 public proposalCount;

    
    IAlpsDAOExecutor public timelock;

    
    AlpsTokenLike public alps;

    
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

/**
 * @title Storage for Governor Bravo Delegate
 * @notice For future upgrades, do not change AlpsDAOStorageV2. Create a new
 * contract which implements AlpsDAOStorageV2 and following the naming convention
 * AlpsDAOStorageVX.
 */
contract AlpsDAOStorageV2 is AlpsDAOStorageV1Adjusted {
    DynamicQuorumParamsCheckpoint[] public quorumParamsCheckpoints;

    
    address public pendingVetoer;

    struct DynamicQuorumParams {
        
        uint16 minQuorumVotesBPS;
        
        uint16 maxQuorumVotesBPS;
        
        
        uint32 quorumCoefficient;
    }

    
    struct DynamicQuorumParamsCheckpoint {
        
        uint32 fromBlock;
        
        DynamicQuorumParams params;
    }

    struct ProposalCondensed {
        
        uint256 id;
        
        address proposer;
        
        uint256 proposalThreshold;
        
        uint256 quorumVotes;
        
        uint256 eta;
        
        uint256 startBlock;
        
        uint256 endBlock;
        
        uint256 forVotes;
        
        uint256 againstVotes;
        
        uint256 abstainVotes;
        
        bool canceled;
        
        bool vetoed;
        
        bool executed;
        
        uint256 totalSupply;
        
        uint256 creationBlock;
    }
}

interface IAlpsDAOExecutor {
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

interface AlpsTokenLike {
    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint96);

    function totalSupply() external view returns (uint256);
}