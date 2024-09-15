// SPDX-License-Identifier: Unlicensed


// 
pragma solidity 0.8.4;


contract GovernorEvents {
    
    event ProposalCreated(uint256 id, address proposer, address[] targets, uint256[] values, string[] signatures, bytes[] calldatas, uint256 startBlock, uint256 endBlock, string description);

    
    
    
    
    
    
    event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 votes, string reason);

    
    event ProposalCanceled(uint256 id);

    
    event ProposalQueued(uint256 id, uint256 eta);

    
    event ProposalExecuted(uint256 id);

    
    event VotingDelaySet(uint256 oldVotingDelay, uint256 newVotingDelay);

    
    event VotingPeriodSet(uint256 oldVotingPeriod, uint256 newVotingPeriod);

    
    event NewImplementation(address oldImplementation, address newImplementation);

    
    event ProposalThresholdSet(uint256 oldProposalThreshold, uint256 newProposalThreshold);

    
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    
    event NewAdmin(address oldAdmin, address newAdmin);
}

// 
pragma solidity 0.8.4;





/**
 * @title Storage for Governor Delegate
 * @notice For future upgrades, do not change GovernorStorage. Create a new
 * contract which implements GovernorStorage and following the naming convention
 * Governor DelegateStorageVX.
 */
contract GovernorStorage {
    
    address public admin;

    
    address public pendingAdmin;

    
    address public implementation;

    
    uint256 public votingDelay;

    
    uint256 public votingPeriod;

    
    uint256 public proposalThreshold;

    
    uint256 public initialProposalId;

    
    uint256 public proposalCount;

    
    ITokenTimelock public timelock;

    
    IDetf public detf;

    
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

        
        uint256 votes;
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

// 

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}// 
pragma solidity 0.8.4;









contract GovernorProxy is GovernorStorage, GovernorEvents {

    //  --------------------
    //  CONSTRUCTOR
    //  --------------------


	constructor(
        address timelock_,
        address detf_,
        address admin_,
        address implementation_,
        uint256 votingPeriod_,
        uint256 votingDelay_,
        uint256 proposalThreshold_
    ) {
        // Admin set to msg.sender for initialization
        admin = msg.sender;

        _delegateTo(
            implementation_,
            abi.encodeWithSignature(
                "initialize(address,address,uint256,uint256,uint256)",
                timelock_,
                detf_,
                votingPeriod_,
                votingDelay_,
                proposalThreshold_
            )
        );

        setImplementation(implementation_);

		admin = admin_;
	}

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable {
        _fallback();
    }


    //  --------------------
    //  INTERNAL
    //  --------------------


	/**
     * @notice Called by the admin to update the implementation of the delegator
     * @param implementation_ The address of the new implementation for delegation
     */
    function setImplementation(address implementation_) public {
        require(msg.sender == admin, "setImplementation: Admin only.");
        require(implementation_ != address(0), "setImplementation: Invalid implementation address.");

        address oldImplementation = implementation;
        implementation = implementation_;

        emit NewImplementation(oldImplementation, implementation);
    }


    //  --------------------
    //  INTERNAL
    //  --------------------


    /**
     * @notice Internal method to delegate execution to another contract
     * @dev It returns to the external caller whatever the implementation returns or forwards reverts
     * @param callee The contract to delegatecall
     * @param data The raw data to delegatecall
     */
    function _delegateTo(address callee, bytes memory data) internal {
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
            case 0 { revert(free_mem_ptr, returndatasize()) }
            default { return(free_mem_ptr, returndatasize()) }
        }
    }
}

// 
pragma solidity 0.8.4;


interface ITokenTimelock {
    function acceptAdmin() external;
    function delay() external view returns (uint256);
    function GRACE_PERIOD() external view returns (uint256);
    function queuedTransactions(bytes32 hash) external view returns (bool);
    function cancelTransaction(address target, uint256 value, string calldata signature, bytes calldata data, uint256 eta) external;
    function queueTransaction(address target, uint256 value, string calldata signature, bytes calldata data, uint256 eta) external returns (bytes32);
    function executeTransaction(address target, uint256 value, string calldata signature, bytes calldata data, uint256 eta) external payable returns (bytes memory);
}

// 
pragma solidity 0.8.4;




interface IDetf is IERC20 {
    function reflect(uint256 tAmount) external;
    function delegate(address delegatee) external;
    function withdraw(address recipient) external;
    function decimals() external pure returns (uint8);
    function excludeAccount(address account) external;
    function includeAccount(address account) external;
    function totalFees() external view returns (uint256);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function changeWithdrawLimit(uint256 newLimit) external;
    function getHoldingFee() external pure returns (uint256);
    function getTreasureFee() external pure returns (uint256);
    function isExcluded(address account) external view returns (bool);
    function getCurrentVotes(address account) external view returns (uint256);
    function tokenFromReflection(uint256 rAmount) external view returns (uint256);
    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256);
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) external view returns (uint256);
    function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) external;
}
