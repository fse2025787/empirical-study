// SPDX-License-Identifier: BUSL-1.1


// Copyright 2021-2022, Offchain Labs, Inc.
// For license information, see https://github.com/nitro/blob/master/LICENSE
// 

pragma solidity ^0.8.0;



interface IRollupEventInbox {
    function bridge() external view returns (IBridge);

    function initialize(IBridge _bridge) external;

    function rollup() external view returns (address);

    function rollupInitialized(uint256 chainId) external;
}

// Copyright 2021-2022, Offchain Labs, Inc.
// For license information, see https://github.com/nitro/blob/master/LICENSE
// 

pragma solidity ^0.8.0;

interface IDelayedMessageProvider {
    
    event InboxMessageDelivered(uint256 indexed messageNum, bytes data);

    
    /// same as InboxMessageDelivered but the batch data is available in tx.input
    event InboxMessageDeliveredFromOrigin(uint256 indexed messageNum);
}

// Copyright 2021-2022, Offchain Labs, Inc.
// For license information, see https://github.com/nitro/blob/master/LICENSE
// 

pragma solidity ^0.8.0;




/// Pattern used here is from UUPS implementation by the OpenZeppelin team
abstract contract DelegateCallAware {
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegate call. This allows a function to be
     * callable on the proxy contract but not on the logic contract.
     */
    modifier onlyDelegated() {
        require(address(this) != __self, "Function must be called through delegatecall");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "Function must not be called through delegatecall");
        _;
    }

    
    modifier onlyProxyOwner() {
        // Storage slot with the admin of the proxy contract
        // This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1
        bytes32 slot = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
        address admin;
        assembly {
            admin := sload(slot)
        }
        if (msg.sender != admin) revert NotOwner(msg.sender, admin);
        _;
    }
}
// Copyright 2021-2022, Offchain Labs, Inc.
// For license information, see https://github.com/nitro/blob/master/LICENSE
// 

pragma solidity ^0.8.0;







/**
 * @title The inbox for rollup protocol events
 */
contract RollupEventInbox is IRollupEventInbox, IDelayedMessageProvider, DelegateCallAware {
    uint8 internal constant CREATE_NODE_EVENT = 0;
    uint8 internal constant CONFIRM_NODE_EVENT = 1;
    uint8 internal constant REJECT_NODE_EVENT = 2;
    uint8 internal constant STAKE_CREATED_EVENT = 3;

    IBridge public override bridge;
    address public override rollup;

    modifier onlyRollup() {
        require(msg.sender == rollup, "ONLY_ROLLUP");
        _;
    }

    function initialize(IBridge _bridge) external override onlyDelegated {
        require(address(bridge) == address(0), "ALREADY_INIT");
        bridge = _bridge;
        rollup = address(_bridge.rollup());
    }

    function rollupInitialized(uint256 chainId) external override onlyRollup {
        bytes memory initMsg = abi.encodePacked(chainId);
        uint256 num = bridge.enqueueDelayedMessage(
            INITIALIZATION_MSG_TYPE,
            address(0),
            keccak256(initMsg)
        );
        emit InboxMessageDelivered(num, initMsg);
    }
}

// Copyright 2021-2022, Offchain Labs, Inc.
// For license information, see https://github.com/nitro/blob/master/LICENSE
// 

pragma solidity ^0.8.4;






error NotDelayedInbox(address sender);



error NotSequencerInbox(address sender);



error NotOutbox(address sender);



error InvalidOutboxSet(address outbox);

interface IBridge {
    event MessageDelivered(
        uint256 indexed messageIndex,
        bytes32 indexed beforeInboxAcc,
        address inbox,
        uint8 kind,
        address sender,
        bytes32 messageDataHash,
        uint256 baseFeeL1,
        uint64 timestamp
    );

    event BridgeCallTriggered(
        address indexed outbox,
        address indexed to,
        uint256 value,
        bytes data
    );

    event InboxToggle(address indexed inbox, bool enabled);

    event OutboxToggle(address indexed outbox, bool enabled);

    event SequencerInboxUpdated(address newSequencerInbox);

    function enqueueDelayedMessage(
        uint8 kind,
        address sender,
        bytes32 messageDataHash
    ) external payable returns (uint256);

    function enqueueSequencerMessage(bytes32 dataHash, uint256 afterDelayedMessagesRead)
        external
        returns (
            uint256 seqMessageIndex,
            bytes32 beforeAcc,
            bytes32 delayedAcc,
            bytes32 acc
        );

    function submitBatchSpendingReport(address batchPoster, bytes32 dataHash)
        external
        returns (uint256 msgNum);

    function executeCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool success, bytes memory returnData);

    // These are only callable by the admin
    function setDelayedInbox(address inbox, bool enabled) external;

    function setOutbox(address inbox, bool enabled) external;

    function setSequencerInbox(address _sequencerInbox) external;

    // View functions

    function sequencerInbox() external view returns (address);

    function activeOutbox() external view returns (address);

    function allowedDelayedInboxes(address inbox) external view returns (bool);

    function allowedOutboxes(address outbox) external view returns (bool);

    function delayedInboxAccs(uint256 index) external view returns (bytes32);

    function sequencerInboxAccs(uint256 index) external view returns (bytes32);

    function delayedMessageCount() external view returns (uint256);

    function sequencerMessageCount() external view returns (uint256);

    function rollup() external view returns (IOwnable);
}

// Copyright 2021-2022, Offchain Labs, Inc.
// For license information, see https://github.com/nitro/blob/master/LICENSE
// 

pragma solidity ^0.8.4;

uint8 constant L2_MSG = 3;
uint8 constant L1MessageType_L2FundedByL1 = 7;
uint8 constant L1MessageType_submitRetryableTx = 9;
uint8 constant L1MessageType_ethDeposit = 12;
uint8 constant L1MessageType_batchPostingReport = 13;
uint8 constant L2MessageType_unsignedEOATx = 0;
uint8 constant L2MessageType_unsignedContractTx = 1;

uint8 constant ROLLUP_PROTOCOL_EVENT_TYPE = 8;
uint8 constant INITIALIZATION_MSG_TYPE = 11;

// Copyright 2021-2022, Offchain Labs, Inc.
// For license information, see https://github.com/nitro/blob/master/LICENSE
// 

pragma solidity ^0.8.4;


error AlreadyInit();

/// Init was called with param set to zero that must be nonzero
error HadZeroInit();




error NotOwner(address sender, address owner);




error NotRollup(address sender, address rollup);


error NotOrigin();




error DataTooLarge(uint256 dataLength, uint256 maxDataLength);



error NotContract(address addr);




error MerkleProofTooLong(uint256 actualLength, uint256 maxProofLength);





error NotRollupOrOwner(address sender, address rollup, address owner);

// Copyright 2021-2022, Offchain Labs, Inc.
// For license information, see https://github.com/nitro/blob/master/LICENSE
// 

pragma solidity ^0.8.4;

interface IOwnable {
    function owner() external view returns (address);
}