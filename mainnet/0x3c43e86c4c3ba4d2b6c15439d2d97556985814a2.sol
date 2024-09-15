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
}// 
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





/** @dev Loosely forked from NounsDAOExecutor.sol (0x0bc3807ec262cb779b38d65b38158acc3bfede10) with following major modifications:
- DELAY and GRACE_PERIOD are hardcoded
- we move admin check logic into a modifier and rename admin to governance
- governance address cannot be changed (in the event of an upgrade, we will first transfer funds to new Executor)
- we don't allow queueing of identical transactions
- we don't check whether transactions are past their grace period because that is checked in Governance */
contract Executor is IExecutor, FrankenDAOErrors {

    
    uint256 public constant DELAY = 2 days;

    
    uint256 public constant GRACE_PERIOD = 14 days;

    
    address public governance;

    
    
    mapping(bytes32 => bool) public queuedTransactions;

    /////////////////////////////////
    ////////// CONSTRUCTOR //////////
    /////////////////////////////////

    
    constructor(address _governance) {
        governance = _governance;
    }

    /////////////////////////////////
    /////////// MODIFIERS ///////////
    /////////////////////////////////

    
    modifier onlyGovernance() {
        if (msg.sender != governance) revert NotAuthorized();
        _;
    }

    /////////////////////////////////
    ////////// TX EXECUTION /////////
    /////////////////////////////////

    
    
    
    
    
    
    
    function queueTransaction(
        uint256 _id,
        address _target,
        uint256 _value,
        string memory _signature,
        bytes memory _data,
        uint256 _eta
    ) public onlyGovernance returns (bytes32 txHash) {
        if (block.timestamp + DELAY > _eta) revert DelayNotSatisfied();

        txHash = keccak256(abi.encode(_id, _target, _value, _signature, _data, _eta));
        if (queuedTransactions[txHash]) revert IdenticalTransactionAlreadyQueued();
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, _id, _target, _value, _signature, _data, _eta);
    }

    
    
    
    
    
    
    
    /** @dev This function is only called by _removeTransactionWithQueuedOrExpiredCheck() in the Governance contract,
            which shows up in cancel(), clear() and veto() */
    function cancelTransaction(
        uint256 _id,
        address _target,
        uint256 _value,
        string memory _signature,
        bytes memory _data,
        uint256 _eta
    ) public onlyGovernance {
        bytes32 txHash = keccak256(abi.encode(_id, _target, _value, _signature, _data, _eta));
        if (!queuedTransactions[txHash]) revert TransactionNotQueued();
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, _id, _target, _value, _signature, _data, _eta);
    }

    
    
    
    
    
    
    
    
    function executeTransaction(
        uint256 _id,
        address _target,
        uint256 _value,
        string memory _signature,
        bytes memory _data,
        uint256 _eta
    ) public onlyGovernance returns (bytes memory) {
        bytes32 txHash = keccak256(abi.encode(_id, _target, _value, _signature, _data, _eta));

        // We don't need to check if it's expired, because this will be caught by the Governance contract.
        // (ie. If we are past the grace period, proposal state will be Expired and execute() will revert.)
        if (!queuedTransactions[txHash]) revert TransactionNotQueued();
        if (_eta > block.timestamp) revert TimelockNotMet();

        queuedTransactions[txHash] = false;

        if (bytes(_signature).length > 0) {
            _data = abi.encodePacked(bytes4(keccak256(bytes(_signature))), _data);
        }

        (bool success, bytes memory returnData) = _target.call{ value: _value }(_data);
        if (!success) revert TransactionReverted();

        emit ExecuteTransaction(txHash, _id, _target, _value, _signature, _data, _eta);
        return returnData;
    }

    
    receive() external payable {}

    
    fallback() external payable {}
}
