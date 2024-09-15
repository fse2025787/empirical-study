// SPDX-License-Identifier: BUSL-1.1


// Copyright 2021-2022, Offchain Labs, Inc.
// For license information, see https://github.com/nitro/blob/master/LICENSE
// 

// solhint-disable-next-line compiler-version
pragma solidity >=0.6.9 <0.9.0;



interface IOutbox {
    event SendRootUpdated(bytes32 indexed blockHash, bytes32 indexed outputRoot);
    event OutBoxTransactionExecuted(
        address indexed to,
        address indexed l2Sender,
        uint256 indexed zero,
        uint256 transactionIndex
    );

    function rollup() external view returns (address); // the rollup contract

    function bridge() external view returns (IBridge); // the bridge contract

    function spent(uint256) external view returns (bytes32); // packed spent bitmap

    function roots(bytes32) external view returns (bytes32); // maps root hashes => L2 block hash

    // solhint-disable-next-line func-name-mixedcase
    function OUTBOX_VERSION() external view returns (uint128); // the outbox version

    function updateSendRoot(bytes32 sendRoot, bytes32 l2BlockHash) external;

    
    ///         When the return value is zero, that means this is a system message
    
    function l2ToL1Sender() external view returns (address);

    
    function l2ToL1Block() external view returns (uint256);

    
    function l2ToL1EthBlock() external view returns (uint256);

    
    function l2ToL1Timestamp() external view returns (uint256);

    
    function l2ToL1OutputId() external view returns (bytes32);

    /**
     * @notice Executes a messages in an Outbox entry.
     * @dev Reverts if dispute period hasn't expired, since the outbox entry
     *      is only created once the rollup confirms the respective assertion.
     * @dev it is not possible to execute any L2-to-L1 transaction which contains data
     *      to a contract address without any code (as enforced by the Bridge contract).
     * @param proof Merkle proof of message inclusion in send root
     * @param index Merkle path to message
     * @param l2Sender sender if original message (i.e., caller of ArbSys.sendTxToL1)
     * @param to destination address for L1 contract call
     * @param l2Block l2 block number at which sendTxToL1 call was made
     * @param l1Block l1 block number at which sendTxToL1 call was made
     * @param l2Timestamp l2 Timestamp at which sendTxToL1 call was made
     * @param value wei in L1 message
     * @param data abi-encoded L1 message data
     */
    function executeTransaction(
        bytes32[] calldata proof,
        uint256 index,
        address l2Sender,
        address to,
        uint256 l2Block,
        uint256 l1Block,
        uint256 l2Timestamp,
        uint256 value,
        bytes calldata data
    ) external;

    /**
     *  @dev function used to simulate the result of a particular function call from the outbox
     *       it is useful for things such as gas estimates. This function includes all costs except for
     *       proof validation (which can be considered offchain as a somewhat of a fixed cost - it's
     *       not really a fixed cost, but can be treated as so with a fixed overhead for gas estimation).
     *       We can't include the cost of proof validation since this is intended to be used to simulate txs
     *       that are included in yet-to-be confirmed merkle roots. The simulation entrypoint could instead pretend
     *       to confirm a pending merkle root, but that would be less pratical for integrating with tooling.
     *       It is only possible to trigger it when the msg sender is address zero, which should be impossible
     *       unless under simulation in an eth_call or eth_estimateGas
     */
    function executeTransactionSimulation(
        uint256 index,
        address l2Sender,
        address to,
        uint256 l2Block,
        uint256 l1Block,
        uint256 l2Timestamp,
        uint256 value,
        bytes calldata data
    ) external;

    /**
     * @param index Merkle path to message
     * @return true if the message has been spent
     */
    function isSpent(uint256 index) external view returns (bool);

    function calculateItemHash(
        address l2Sender,
        address to,
        uint256 l2Block,
        uint256 l1Block,
        uint256 l2Timestamp,
        uint256 value,
        bytes calldata data
    ) external pure returns (bytes32);

    function calculateMerkleRoot(
        bytes32[] memory proof,
        uint256 path,
        bytes32 item
    ) external pure returns (bytes32);
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

pragma solidity ^0.8.4;








error SimulationOnlyEntrypoint();

contract Outbox is DelegateCallAware, IOutbox {
    address public rollup; // the rollup contract
    IBridge public bridge; // the bridge contract

    mapping(uint256 => bytes32) public spent; // packed spent bitmap
    mapping(bytes32 => bytes32) public roots; // maps root hashes => L2 block hash

    struct L2ToL1Context {
        uint128 l2Block;
        uint128 l1Block;
        uint128 timestamp;
        bytes32 outputId;
        address sender;
    }
    // Note, these variables are set and then wiped during a single transaction.
    // Therefore their values don't need to be maintained, and their slots will
    // be empty outside of transactions
    L2ToL1Context internal context;

    // default context values to be used in storage instead of zero, to save on storage refunds
    // it is assumed that arb-os never assigns these values to a valid leaf to be redeemed
    uint128 private constant L2BLOCK_DEFAULT_CONTEXT = type(uint128).max;
    uint128 private constant L1BLOCK_DEFAULT_CONTEXT = type(uint128).max;
    uint128 private constant TIMESTAMP_DEFAULT_CONTEXT = type(uint128).max;
    bytes32 private constant OUTPUTID_DEFAULT_CONTEXT = bytes32(type(uint256).max);
    address private constant SENDER_DEFAULT_CONTEXT = address(type(uint160).max);

    uint128 public constant OUTBOX_VERSION = 2;

    function initialize(IBridge _bridge) external onlyDelegated {
        if (address(_bridge) == address(0)) revert HadZeroInit();
        if (address(bridge) != address(0)) revert AlreadyInit();
        // address zero is returned if no context is set, but the values used in storage
        // are non-zero to save users some gas (as storage refunds are usually maxed out)
        // EIP-1153 would help here
        context = L2ToL1Context({
            l2Block: L2BLOCK_DEFAULT_CONTEXT,
            l1Block: L1BLOCK_DEFAULT_CONTEXT,
            timestamp: TIMESTAMP_DEFAULT_CONTEXT,
            outputId: OUTPUTID_DEFAULT_CONTEXT,
            sender: SENDER_DEFAULT_CONTEXT
        });
        bridge = _bridge;
        rollup = address(_bridge.rollup());
    }

    function updateSendRoot(bytes32 root, bytes32 l2BlockHash) external {
        if (msg.sender != rollup) revert NotRollup(msg.sender, rollup);
        roots[root] = l2BlockHash;
        emit SendRootUpdated(root, l2BlockHash);
    }

    
    function l2ToL1Sender() external view returns (address) {
        address sender = context.sender;
        // we don't return the default context value to avoid a breaking change in the API
        if (sender == SENDER_DEFAULT_CONTEXT) return address(0);
        return sender;
    }

    
    function l2ToL1Block() external view returns (uint256) {
        uint128 l2Block = context.l2Block;
        // we don't return the default context value to avoid a breaking change in the API
        if (l2Block == L1BLOCK_DEFAULT_CONTEXT) return uint256(0);
        return uint256(l2Block);
    }

    
    function l2ToL1EthBlock() external view returns (uint256) {
        uint128 l1Block = context.l1Block;
        // we don't return the default context value to avoid a breaking change in the API
        if (l1Block == L1BLOCK_DEFAULT_CONTEXT) return uint256(0);
        return uint256(l1Block);
    }

    
    function l2ToL1Timestamp() external view returns (uint256) {
        uint128 timestamp = context.timestamp;
        // we don't return the default context value to avoid a breaking change in the API
        if (timestamp == TIMESTAMP_DEFAULT_CONTEXT) return uint256(0);
        return uint256(timestamp);
    }

    
    function l2ToL1BatchNum() external pure returns (uint256) {
        return 0;
    }

    
    function l2ToL1OutputId() external view returns (bytes32) {
        bytes32 outputId = context.outputId;
        // we don't return the default context value to avoid a breaking change in the API
        if (outputId == OUTPUTID_DEFAULT_CONTEXT) return bytes32(0);
        return outputId;
    }

    
    function executeTransaction(
        bytes32[] calldata proof,
        uint256 index,
        address l2Sender,
        address to,
        uint256 l2Block,
        uint256 l1Block,
        uint256 l2Timestamp,
        uint256 value,
        bytes calldata data
    ) external {
        bytes32 userTx = calculateItemHash(
            l2Sender,
            to,
            l2Block,
            l1Block,
            l2Timestamp,
            value,
            data
        );

        recordOutputAsSpent(proof, index, userTx);

        executeTransactionImpl(index, l2Sender, to, l2Block, l1Block, l2Timestamp, value, data);
    }

    
    function executeTransactionSimulation(
        uint256 index,
        address l2Sender,
        address to,
        uint256 l2Block,
        uint256 l1Block,
        uint256 l2Timestamp,
        uint256 value,
        bytes calldata data
    ) external {
        if (msg.sender != address(0)) revert SimulationOnlyEntrypoint();
        executeTransactionImpl(index, l2Sender, to, l2Block, l1Block, l2Timestamp, value, data);
    }

    function executeTransactionImpl(
        uint256 outputId,
        address l2Sender,
        address to,
        uint256 l2Block,
        uint256 l1Block,
        uint256 l2Timestamp,
        uint256 value,
        bytes calldata data
    ) internal {
        emit OutBoxTransactionExecuted(to, l2Sender, 0, outputId);

        // we temporarily store the previous values so the outbox can naturally
        // unwind itself when there are nested calls to `executeTransaction`
        L2ToL1Context memory prevContext = context;

        context = L2ToL1Context({
            sender: l2Sender,
            l2Block: uint128(l2Block),
            l1Block: uint128(l1Block),
            timestamp: uint128(l2Timestamp),
            outputId: bytes32(outputId)
        });

        // set and reset vars around execution so they remain valid during call
        executeBridgeCall(to, value, data);

        context = prevContext;
    }

    function _calcSpentIndexOffset(uint256 index)
        internal
        view
        returns (
            uint256,
            uint256,
            bytes32
        )
    {
        uint256 spentIndex = index / 255; // Note: Reserves the MSB.
        uint256 bitOffset = index % 255;
        bytes32 replay = spent[spentIndex];
        return (spentIndex, bitOffset, replay);
    }

    function _isSpent(uint256 bitOffset, bytes32 replay) internal pure returns (bool) {
        return ((replay >> bitOffset) & bytes32(uint256(1))) != bytes32(0);
    }

    
    function isSpent(uint256 index) external view returns (bool) {
        (, uint256 bitOffset, bytes32 replay) = _calcSpentIndexOffset(index);
        return _isSpent(bitOffset, replay);
    }

    function recordOutputAsSpent(
        bytes32[] memory proof,
        uint256 index,
        bytes32 item
    ) internal {
        if (proof.length >= 256) revert ProofTooLong(proof.length);
        if (index >= 2**proof.length) revert PathNotMinimal(index, 2**proof.length);

        // Hash the leaf an extra time to prove it's a leaf
        bytes32 calcRoot = calculateMerkleRoot(proof, index, item);
        if (roots[calcRoot] == bytes32(0)) revert UnknownRoot(calcRoot);

        (uint256 spentIndex, uint256 bitOffset, bytes32 replay) = _calcSpentIndexOffset(index);

        if (_isSpent(bitOffset, replay)) revert AlreadySpent(index);
        spent[spentIndex] = (replay | bytes32(1 << bitOffset));
    }

    function executeBridgeCall(
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        (bool success, bytes memory returndata) = bridge.executeCall(to, value, data);
        if (!success) {
            if (returndata.length > 0) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert BridgeCallFailed();
            }
        }
    }

    function calculateItemHash(
        address l2Sender,
        address to,
        uint256 l2Block,
        uint256 l1Block,
        uint256 l2Timestamp,
        uint256 value,
        bytes calldata data
    ) public pure returns (bytes32) {
        return
            keccak256(abi.encodePacked(l2Sender, to, l2Block, l1Block, l2Timestamp, value, data));
    }

    function calculateMerkleRoot(
        bytes32[] memory proof,
        uint256 path,
        bytes32 item
    ) public pure returns (bytes32) {
        return MerkleLib.calculateRoot(proof, path, keccak256(abi.encodePacked(item)));
    }
}

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

// Bridge Errors



error NotDelayedInbox(address sender);



error NotSequencerInbox(address sender);



error NotOutbox(address sender);



error InvalidOutboxSet(address outbox);

// Inbox Errors


error AlreadyPaused();


error AlreadyUnpaused();


error Paused();


error InsufficientValue(uint256 expected, uint256 actual);


error InsufficientSubmissionCost(uint256 expected, uint256 actual);


error NotAllowedOrigin(address origin);


/// this follows a pattern similar to EIP-3668 where reverts surface call information
error RetryableData(
    address from,
    address to,
    uint256 l2CallValue,
    uint256 deposit,
    uint256 maxSubmissionCost,
    address excessFeeRefundAddress,
    address callValueRefundAddress,
    uint256 gasLimit,
    uint256 maxFeePerGas,
    bytes data
);

// Outbox Errors



error ProofTooLong(uint256 proofLength);




error PathNotMinimal(uint256 index, uint256 maxIndex);



error UnknownRoot(bytes32 root);



error AlreadySpent(uint256 index);


error BridgeCallFailed();

// Sequencer Inbox Errors


error DelayedBackwards();


error DelayedTooFar();


error ForceIncludeBlockTooSoon();


error ForceIncludeTimeTooSoon();


error IncorrectMessagePreimage();


error NotBatchPoster();


error BadSequencerNumber(uint256 stored, uint256 received);


error DataNotAuthenticated();


error AlreadyValidDASKeyset(bytes32);


error NoSuchKeyset(bytes32);

// Copyright 2021-2022, Offchain Labs, Inc.
// For license information, see https://github.com/nitro/blob/master/LICENSE
// 

// solhint-disable-next-line compiler-version
pragma solidity >=0.6.9 <0.9.0;



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

    function allowedDelayedInboxList(uint256) external returns (address);

    function allowedOutboxList(uint256) external returns (address);

    
    function delayedInboxAccs(uint256) external view returns (bytes32);

    
    function sequencerInboxAccs(uint256) external view returns (bytes32);

    function rollup() external view returns (IOwnable);

    function sequencerInbox() external view returns (address);

    function activeOutbox() external view returns (address);

    function allowedDelayedInboxes(address inbox) external view returns (bool);

    function allowedOutboxes(address outbox) external view returns (bool);

    /**
     * @dev Enqueue a message in the delayed inbox accumulator.
     *      These messages are later sequenced in the SequencerInbox, either
     *      by the sequencer as part of a normal batch, or by force inclusion.
     */
    function enqueueDelayedMessage(
        uint8 kind,
        address sender,
        bytes32 messageDataHash
    ) external payable returns (uint256);

    function executeCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool success, bytes memory returnData);

    function delayedMessageCount() external view returns (uint256);

    function sequencerMessageCount() external view returns (uint256);

    // ---------- onlySequencerInbox functions ----------

    function enqueueSequencerMessage(bytes32 dataHash, uint256 afterDelayedMessagesRead)
        external
        returns (
            uint256 seqMessageIndex,
            bytes32 beforeAcc,
            bytes32 delayedAcc,
            bytes32 acc
        );

    /**
     * @dev Allows the sequencer inbox to submit a delayed message of the batchPostingReport type
     *      This is done through a separate function entrypoint instead of allowing the sequencer inbox
     *      to call `enqueueDelayedMessage` to avoid the gas overhead of an extra SLOAD in either
     *      every delayed inbox or every sequencer inbox call.
     */
    function submitBatchSpendingReport(address batchPoster, bytes32 dataHash)
        external
        returns (uint256 msgNum);

    // ---------- onlyRollupOrOwner functions ----------

    function setSequencerInbox(address _sequencerInbox) external;

    function setDelayedInbox(address inbox, bool enabled) external;

    function setOutbox(address inbox, bool enabled) external;

    // ---------- initializer ----------

    function initialize(IOwnable rollup_) external;
}

// Copyright 2021-2022, Offchain Labs, Inc.
// For license information, see https://github.com/nitro/blob/master/LICENSE
// 

pragma solidity ^0.8.4;



library MerkleLib {
    function generateRoot(bytes32[] memory _hashes) internal pure returns (bytes32) {
        bytes32[] memory prevLayer = _hashes;
        while (prevLayer.length > 1) {
            bytes32[] memory nextLayer = new bytes32[]((prevLayer.length + 1) / 2);
            for (uint256 i = 0; i < nextLayer.length; i++) {
                if (2 * i + 1 < prevLayer.length) {
                    nextLayer[i] = keccak256(
                        abi.encodePacked(prevLayer[2 * i], prevLayer[2 * i + 1])
                    );
                } else {
                    nextLayer[i] = prevLayer[2 * i];
                }
            }
            prevLayer = nextLayer;
        }
        return prevLayer[0];
    }

    function calculateRoot(
        bytes32[] memory nodes,
        uint256 route,
        bytes32 item
    ) internal pure returns (bytes32) {
        uint256 proofItems = nodes.length;
        if (proofItems > 256) revert MerkleProofTooLong(proofItems, 256);
        bytes32 h = item;
        for (uint256 i = 0; i < proofItems; ) {
            bytes32 node = nodes[i];
            if ((route & (1 << i)) == 0) {
                assembly {
                    mstore(0x00, h)
                    mstore(0x20, node)
                    h := keccak256(0x00, 0x40)
                }
            } else {
                assembly {
                    mstore(0x00, node)
                    mstore(0x20, h)
                    h := keccak256(0x00, 0x40)
                }
            }
            unchecked {
                ++i;
            }
        }
        return h;
    }
}

// Copyright 2021-2022, Offchain Labs, Inc.
// For license information, see https://github.com/nitro/blob/master/LICENSE
// 

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.21 <0.9.0;

interface IOwnable {
    function owner() external view returns (address);
}