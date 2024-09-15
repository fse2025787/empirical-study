// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.8;




interface IERC165 {
    
    
    
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool supported);
}

// 
pragma solidity ^0.8.8;






abstract contract InterfaceDetection is IERC165 {
    using InterfaceDetectionStorage for InterfaceDetectionStorage.Layout;

    
    function supportsInterface(bytes4 interfaceId) external view override returns (bool) {
        return InterfaceDetectionStorage.layout().supportsInterface(interfaceId);
    }
}

// 
pragma solidity ^0.8.8;







abstract contract ForwarderRegistryContextBase {
    IForwarderRegistry internal immutable _forwarderRegistry;

    constructor(IForwarderRegistry forwarderRegistry) {
        _forwarderRegistry = forwarderRegistry;
    }

    
    function _msgSender() internal view virtual returns (address) {
        // Optimised path in case of an EOA-initiated direct tx to the contract or a call from a contract not complying with EIP-2771
        // solhint-disable-next-line avoid-tx-origin
        if (msg.sender == tx.origin || msg.data.length < 24) {
            return msg.sender;
        }

        address sender = ERC2771Calldata.msgSender();

        // Return the EIP-2771 calldata-appended sender address if the message was forwarded by the ForwarderRegistry or an approved forwarder
        if (msg.sender == address(_forwarderRegistry) || _forwarderRegistry.isApprovedForwarder(sender, msg.sender)) {
            return sender;
        }

        return msg.sender;
    }

    
    function _msgData() internal view virtual returns (bytes calldata) {
        // Optimised path in case of an EOA-initiated direct tx to the contract or a call from a contract not complying with EIP-2771
        // solhint-disable-next-line avoid-tx-origin
        if (msg.sender == tx.origin || msg.data.length < 24) {
            return msg.data;
        }

        // Return the EIP-2771 calldata (minus the appended sender) if the message was forwarded by the ForwarderRegistry or an approved forwarder
        if (msg.sender == address(_forwarderRegistry) || _forwarderRegistry.isApprovedForwarder(ERC2771Calldata.msgSender(), msg.sender)) {
            return ERC2771Calldata.msgData();
        }

        return msg.data;
    }
}

// 
pragma solidity ^0.8.8;



interface IERC2771 {
    
    
    
    function isTrustedForwarder(address forwarder) external view returns (bool isTrusted);
}

// 
pragma solidity ^0.8.8;





interface IERC20Receiver {
    
    
    
    
    
    
    
    function onERC20Received(address operator, address from, uint256 value, bytes calldata data) external returns (bytes4 magicValue);
}

// 
pragma solidity ^0.8.8;








abstract contract ForwarderRegistryContext is ForwarderRegistryContextBase, IERC2771 {
    constructor(IForwarderRegistry forwarderRegistry_) ForwarderRegistryContextBase(forwarderRegistry_) {}

    function forwarderRegistry() external view returns (IForwarderRegistry) {
        return _forwarderRegistry;
    }

    
    function isTrustedForwarder(address forwarder) external view virtual override returns (bool) {
        return forwarder == address(_forwarderRegistry);
    }
}

// 
pragma solidity ^0.8.8;







abstract contract ERC20Receiver is IERC20Receiver, InterfaceDetection {
    using InterfaceDetectionStorage for InterfaceDetectionStorage.Layout;

    
    constructor() {
        InterfaceDetectionStorage.layout().setSupportedInterface(type(IERC20Receiver).interfaceId, true);
    }
}

// 
pragma solidity ^0.8.0;

// Create2 adds common methods for minimal proxy with create2
abstract contract Create2 {
    // creates clone using minimal proxy
    function createClone(bytes32 _salt, address _target) internal returns (address _result) {
        bytes20 _targetBytes = bytes20(_target);

        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), _targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            _result := create2(0, clone, 0x37, _salt)
        }

        require(_result != address(0), "Create2: Failed on minimal deploy");
    }

    // get minimal proxy creation code
    function minimalProxyCreationCode(address logic) internal pure returns (bytes memory) {
        bytes10 creation = 0x3d602d80600a3d3981f3;
        bytes10 prefix = 0x363d3d373d3d3d363d73;
        bytes20 targetBytes = bytes20(logic);
        bytes15 suffix = 0x5af43d82803e903d91602b57fd5bf3;
        return abi.encodePacked(creation, prefix, targetBytes, suffix);
    }

    // get computed create2 address
    function computedCreate2Address(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) public pure returns (address) {
        bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return address(uint160(uint256(_data)));
    }
}

abstract contract FxBaseRootTunnel {
    using RLPReader for RLPReader.RLPItem;
    using Merkle for bytes32;
    using ExitPayloadReader for bytes;
    using ExitPayloadReader for ExitPayloadReader.ExitPayload;
    using ExitPayloadReader for ExitPayloadReader.Log;
    using ExitPayloadReader for ExitPayloadReader.LogTopics;
    using ExitPayloadReader for ExitPayloadReader.Receipt;

    // keccak256(MessageSent(bytes))
    bytes32 public constant SEND_MESSAGE_EVENT_SIG = 0x8c5261668696ce22758910d05bab8f186d6eb247ceac2af2e82c7dc17669b036;

    // state sender contract
    IFxStateSender public fxRoot;
    // root chain manager
    ICheckpointManager public checkpointManager;
    // child tunnel contract which receives and sends messages
    address public fxChildTunnel;

    // storage to avoid duplicate exits
    mapping(bytes32 => bool) public processedExits;

    constructor(address _checkpointManager, address _fxRoot) {
        checkpointManager = ICheckpointManager(_checkpointManager);
        fxRoot = IFxStateSender(_fxRoot);
    }

    // set fxChildTunnel if not set already
    function setFxChildTunnel(address _fxChildTunnel) public virtual {
        require(fxChildTunnel == address(0x0), "FxBaseRootTunnel: CHILD_TUNNEL_ALREADY_SET");
        fxChildTunnel = _fxChildTunnel;
    }

    /**
     * @notice Send bytes message to Child Tunnel
     * @param message bytes message that will be sent to Child Tunnel
     * some message examples -
     *   abi.encode(tokenId);
     *   abi.encode(tokenId, tokenMetadata);
     *   abi.encode(messageType, messageData);
     */
    function _sendMessageToChild(bytes memory message) internal {
        fxRoot.sendMessageToChild(fxChildTunnel, message);
    }

    function _validateAndExtractMessage(bytes memory inputData) internal returns (bytes memory) {
        ExitPayloadReader.ExitPayload memory payload = inputData.toExitPayload();

        bytes memory branchMaskBytes = payload.getBranchMaskAsBytes();
        uint256 blockNumber = payload.getBlockNumber();
        // checking if exit has already been processed
        // unique exit is identified using hash of (blockNumber, branchMask, receiptLogIndex)
        bytes32 exitHash = keccak256(
            abi.encodePacked(
                blockNumber,
                // first 2 nibbles are dropped while generating nibble array
                // this allows branch masks that are valid but bypass exitHash check (changing first 2 nibbles only)
                // so converting to nibble array and then hashing it
                MerklePatriciaProof._getNibbleArray(branchMaskBytes),
                payload.getReceiptLogIndex()
            )
        );
        require(processedExits[exitHash] == false, "FxRootTunnel: EXIT_ALREADY_PROCESSED");
        processedExits[exitHash] = true;

        ExitPayloadReader.Receipt memory receipt = payload.getReceipt();
        ExitPayloadReader.Log memory log = receipt.getLog();

        // check child tunnel
        require(fxChildTunnel == log.getEmitter(), "FxRootTunnel: INVALID_FX_CHILD_TUNNEL");

        bytes32 receiptRoot = payload.getReceiptRoot();
        // verify receipt inclusion
        require(
            MerklePatriciaProof.verify(receipt.toBytes(), branchMaskBytes, payload.getReceiptProof(), receiptRoot),
            "FxRootTunnel: INVALID_RECEIPT_PROOF"
        );

        // verify checkpoint inclusion
        _checkBlockMembershipInCheckpoint(
            blockNumber,
            payload.getBlockTime(),
            payload.getTxRoot(),
            receiptRoot,
            payload.getHeaderNumber(),
            payload.getBlockProof()
        );

        ExitPayloadReader.LogTopics memory topics = log.getTopics();

        require(
            bytes32(topics.getField(0).toUint()) == SEND_MESSAGE_EVENT_SIG, // topic0 is event sig
            "FxRootTunnel: INVALID_SIGNATURE"
        );

        // received message data
        bytes memory message = abi.decode(log.getData(), (bytes)); // event decodes params again, so decoding bytes to get message
        return message;
    }

    function _checkBlockMembershipInCheckpoint(
        uint256 blockNumber,
        uint256 blockTime,
        bytes32 txRoot,
        bytes32 receiptRoot,
        uint256 headerNumber,
        bytes memory blockProof
    ) private view returns (uint256) {
        (bytes32 headerRoot, uint256 startBlock, , uint256 createdAt, ) = checkpointManager.headerBlocks(headerNumber);

        require(
            keccak256(abi.encodePacked(blockNumber, blockTime, txRoot, receiptRoot)).checkMembership(
                blockNumber - startBlock,
                headerRoot,
                blockProof
            ),
            "FxRootTunnel: INVALID_HEADER"
        );
        return createdAt;
    }

    /**
     * @notice receive message from  L2 to L1, validated by proof
     * @dev This function verifies if the transaction actually happened on child chain
     *
     * @param inputData RLP encoded data of the reference tx containing following list of fields
     *  0 - headerNumber - Checkpoint header block number containing the reference tx
     *  1 - blockProof - Proof that the block header (in the child chain) is a leaf in the submitted merkle root
     *  2 - blockNumber - Block number containing the reference tx on child chain
     *  3 - blockTime - Reference tx block time
     *  4 - txRoot - Transactions root of block
     *  5 - receiptRoot - Receipts root of block
     *  6 - receipt - Receipt of the reference transaction
     *  7 - receiptProof - Merkle proof of the reference receipt
     *  8 - branchMask - 32 bits denoting the path of receipt in merkle tree
     *  9 - receiptLogIndex - Log Index to read from the receipt
     */
    function receiveMessage(bytes memory inputData) public virtual {
        bytes memory message = _validateAndExtractMessage(inputData);
        _processMessageFromChild(message);
    }

    /**
     * @notice Process message received from Child Tunnel
     * @dev function needs to be implemented to handle message as per requirement
     * This is called by onStateReceive function.
     * Since it is called via a system call, any event will not be emitted during its execution.
     * @param message bytes message that was sent from Child Tunnel
     */
    function _processMessageFromChild(bytes memory message) internal virtual;
}

// 
pragma solidity ^0.8.8;

abstract contract FxERC20TunnelEvents {
    
    
    
    event FxERC20TokenMapping(address indexed rootToken, address indexed childToken);

    
    
    
    
    
    
    event FxERC20Withdrawal(address indexed rootToken, address indexed childToken, address withdrawer, address recipient, uint256 amount);

    
    
    
    
    
    
    event FxERC20Deposit(address indexed rootToken, address indexed childToken, address depositor, address recipient, uint256 amount);
}

// 
pragma solidity ^0.8.8;

abstract contract FxTokenMapping {
    bytes32 public constant DEPOSIT = keccak256("DEPOSIT");
    bytes32 public constant MAP_TOKEN = keccak256("MAP_TOKEN");

    mapping(address => address) public rootToChildToken;
}
// 
pragma solidity ^0.8.8;












abstract contract FxERC20RootTunnel is FxBaseRootTunnel, FxTokenMapping, FxERC20TunnelEvents, ERC20Receiver, Create2, ForwarderRegistryContext {
    bytes32 public immutable childTokenProxyCodeHash;

    
    
    
    
    error FxERC20InvalidMappingOnExit(address childToken, address expectedRootToken, address actualRootToken);

    
    error FxERC20InvalidDepositAddress();

    constructor(
        address checkpointManager,
        address fxRoot,
        address fxERC20Token,
        IForwarderRegistry forwarderRegistry
    ) FxBaseRootTunnel(checkpointManager, fxRoot) ForwarderRegistryContext(forwarderRegistry) {
        // compute child token proxy code hash
        childTokenProxyCodeHash = keccak256(minimalProxyCreationCode(fxERC20Token));
    }

    
    
    function mapToken(address rootToken) public returns (address childToken) {
        childToken = rootToChildToken[rootToken];
        if (childToken != address(0x0)) {
            return childToken;
        }

        // send the mapping request to the child chain
        _sendMessageToChild(abi.encode(MAP_TOKEN, abi.encode(rootToken, _encodeChildTokenInitArgs(rootToken))));

        // compute child token address before deployment using create2
        bytes32 salt = keccak256(abi.encodePacked(rootToken));
        childToken = computedCreate2Address(salt, childTokenProxyCodeHash, fxChildTunnel);

        // add into mapped tokens
        rootToChildToken[rootToken] = childToken;
        emit FxERC20TokenMapping(rootToken, childToken);
    }

    
    
    // @param operator The initiator of the safe transfer.
    
    
    
    
    function onERC20Received(address, address from, uint256 value, bytes calldata data) external returns (bytes4 magicValue) {
        address receiver = from;
        if (data.length != 0) {
            (receiver) = abi.decode(data, (address));
            if (receiver == address(0)) {
                revert FxERC20InvalidDepositAddress();
            }
        }
        _deposit(msg.sender, from, receiver, value);
        _depositReceivedTokens(msg.sender, value);

        return ERC20Storage.ERC20_RECEIVED;
    }

    
    
    
    
    
    function deposit(address rootToken, uint256 amount) external {
        address depositor = _msgSender();
        _deposit(rootToken, depositor, depositor, amount);
        _depositTokensFrom(rootToken, depositor, amount);
    }

    
    
    
    
    
    
    
    function depositTo(address rootToken, address receiver, uint256 amount) external {
        if (receiver == address(0)) {
            revert FxERC20InvalidDepositAddress();
        }
        address depositor = _msgSender();
        _deposit(rootToken, depositor, receiver, amount);
        _depositTokensFrom(rootToken, depositor, amount);
    }

    function _deposit(address rootToken, address depositor, address receiver, uint256 amount) internal {
        bytes memory message = abi.encode(DEPOSIT, abi.encode(rootToken, depositor, receiver, amount));
        _sendMessageToChild(message);
        emit FxERC20Deposit(rootToken, mapToken(rootToken), depositor, receiver, amount);
    }

    // exit processor
    function _processMessageFromChild(bytes memory data) internal override {
        (address rootToken, address childToken, address withdrawer, address receiver, uint256 amount) = abi.decode(
            data,
            (address, address, address, address, uint256)
        );

        // validate mapping for root to child
        address mappedChildToken = rootToChildToken[rootToken];
        if (childToken != mappedChildToken) {
            revert FxERC20InvalidMappingOnExit(rootToken, childToken, mappedChildToken);
        }

        _withdraw(rootToken, receiver, amount);

        emit FxERC20Withdrawal(rootToken, childToken, withdrawer, receiver, amount);
    }

    
    
    function _encodeChildTokenInitArgs(address rootToken) internal virtual returns (bytes memory);

    
    
    
    
    function _depositReceivedTokens(address rootToken, uint256 amount) internal virtual;

    
    
    
    
    
    function _depositTokensFrom(address rootToken, address depositor, uint256 amount) internal virtual;

    
    
    
    
    function _withdraw(address rootToken, address receiver, uint256 amount) internal virtual;
}
// 
pragma solidity ^0.8.8;




interface IERC173 {
    
    
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    
    
    
    function transferOwnership(address newOwner) external;

    
    
    function owner() external view returns (address contractOwner);
}

// 
pragma solidity ^0.8.8;



library InterfaceDetectionStorage {
    struct Layout {
        mapping(bytes4 => bool) supportedInterfaces;
    }

    bytes32 internal constant LAYOUT_STORAGE_SLOT = bytes32(uint256(keccak256("animoca.core.introspection.InterfaceDetection.storage")) - 1);

    bytes4 internal constant ILLEGAL_INTERFACE_ID = 0xffffffff;

    
    
    
    
    function setSupportedInterface(Layout storage s, bytes4 interfaceId, bool supported) internal {
        require(interfaceId != ILLEGAL_INTERFACE_ID, "InterfaceDetection: wrong value");
        s.supportedInterfaces[interfaceId] = supported;
    }

    
    
    
    
    function supportsInterface(Layout storage s, bytes4 interfaceId) internal view returns (bool supported) {
        if (interfaceId == ILLEGAL_INTERFACE_ID) {
            return false;
        }
        if (interfaceId == type(IERC165).interfaceId) {
            return true;
        }
        return s.supportedInterfaces[interfaceId];
    }

    function layout() internal pure returns (Layout storage s) {
        bytes32 position = LAYOUT_STORAGE_SLOT;
        assembly {
            s.slot := position
        }
    }
}

// 
pragma solidity ^0.8.8;



interface IForwarderRegistry {
    
    
    
    
    function isApprovedForwarder(address sender, address forwarder) external view returns (bool isApproved);
}

// 
pragma solidity ^0.8.8;



library ERC2771Calldata {
    
    function msgSender() internal pure returns (address sender) {
        assembly {
            sender := shr(96, calldataload(sub(calldatasize(), 20)))
        }
    }

    
    function msgData() internal pure returns (bytes calldata data) {
        unchecked {
            return msg.data[:msg.data.length - 20];
        }
    }
}

// 
pragma solidity ^0.8.8;




library ProxyInitialization {
    
    
    
    
    function setPhase(bytes32 storageSlot, uint256 phase) internal {
        StorageSlot.Uint256Slot storage currentVersion = StorageSlot.getUint256Slot(storageSlot);
        require(currentVersion.value < phase, "Storage: phase reached");
        currentVersion.value = phase;
    }
}

// 
pragma solidity ^0.8.8;




interface IERC20 {
    
    
    
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    
    
    
    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    
    ///  the new allowance by unfortunate transaction ordering. One possible solution to mitigate this race condition is to first reduce
    ///  the spender's allowance to 0 and set the desired value afterwards: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    
    
    
    
    
    function approve(address spender, uint256 value) external returns (bool result);

    
    
    
    
    
    
    
    function transfer(address to, uint256 value) external returns (bool result);

    
    
    
    
    
    
    
    
    
    
    function transferFrom(address from, address to, uint256 value) external returns (bool result);

    
    
    function totalSupply() external view returns (uint256 supply);

    
    
    
    function balanceOf(address owner) external view returns (uint256 balance);

    
    
    
    
    function allowance(address owner, address spender) external view returns (uint256 value);
}

// 
pragma solidity ^0.8.8;




interface IERC20Allowance {
    
    
    
    
    
    
    
    
    function increaseAllowance(address spender, uint256 value) external returns (bool result);

    
    
    
    
    
    
    
    
    function decreaseAllowance(address spender, uint256 value) external returns (bool result);
}

// 
pragma solidity ^0.8.8;




interface IERC20BatchTransfers {
    
    
    
    
    
    
    
    
    function batchTransfer(address[] calldata recipients, uint256[] calldata values) external returns (bool result);

    
    
    
    
    
    
    
    
    
    
    
    function batchTransferFrom(address from, address[] calldata recipients, uint256[] calldata values) external returns (bool result);
}

// 
pragma solidity ^0.8.8;




interface IERC20Burnable {
    
    
    
    
    
    function burn(uint256 value) external returns (bool result);

    
    
    
    
    
    
    
    
    function burnFrom(address from, uint256 value) external returns (bool result);

    
    
    
    
    
    
    
    
    
    function batchBurnFrom(address[] calldata owners, uint256[] calldata values) external returns (bool result);
}

// 
pragma solidity ^0.8.8;




interface IERC20Detailed {
    
    
    function name() external view returns (string memory tokenName);

    
    
    function symbol() external view returns (string memory tokenSymbol);

    
    
    
    
    
    function decimals() external view returns (uint8 nbDecimals);
}

// 
pragma solidity ^0.8.8;




interface IERC20Metadata {
    
    
    function tokenURI() external view returns (string memory uri);
}

// 
pragma solidity ^0.8.8;




interface IERC20Mintable {
    
    
    
    
    
    
    function mint(address to, uint256 value) external;

    
    
    
    
    
    
    
    function batchMint(address[] calldata recipients, uint256[] calldata values) external;
}

// 
pragma solidity ^0.8.8;




interface IERC20SafeTransfers {
    
    
    
    
    
    
    
    
    
    function safeTransfer(address to, uint256 value, bytes calldata data) external returns (bool result);

    
    
    
    
    
    
    
    
    
    
    
    
    function safeTransferFrom(address from, address to, uint256 value, bytes calldata data) external returns (bool result);
}

// 
pragma solidity ^0.8.8;












library ERC20Storage {
    using Address for address;
    using ERC20Storage for ERC20Storage.Layout;
    using InterfaceDetectionStorage for InterfaceDetectionStorage.Layout;

    struct Layout {
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
        uint256 supply;
    }

    bytes32 internal constant LAYOUT_STORAGE_SLOT = bytes32(uint256(keccak256("animoca.core.token.ERC20.ERC20.storage")) - 1);

    bytes4 internal constant ERC20_RECEIVED = IERC20Receiver.onERC20Received.selector;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    function init() internal {
        InterfaceDetectionStorage.Layout storage erc165Layout = InterfaceDetectionStorage.layout();
        erc165Layout.setSupportedInterface(type(IERC20).interfaceId, true);
        erc165Layout.setSupportedInterface(type(IERC20Allowance).interfaceId, true);
    }

    
    function initERC20BatchTransfers() internal {
        InterfaceDetectionStorage.layout().setSupportedInterface(type(IERC20BatchTransfers).interfaceId, true);
    }

    
    function initERC20SafeTransfers() internal {
        InterfaceDetectionStorage.layout().setSupportedInterface(type(IERC20SafeTransfers).interfaceId, true);
    }

    
    function initERC20Mintable() internal {
        InterfaceDetectionStorage.layout().setSupportedInterface(type(IERC20Mintable).interfaceId, true);
    }

    
    function initERC20Burnable() internal {
        InterfaceDetectionStorage.layout().setSupportedInterface(type(IERC20Burnable).interfaceId, true);
    }

    
    
    
    
    
    
    
    function approve(Layout storage s, address owner, address spender, uint256 value) internal {
        require(spender != address(0), "ERC20: approval to address(0)");
        s.allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    
    
    
    
    
    
    
    
    function increaseAllowance(Layout storage s, address owner, address spender, uint256 value) internal {
        require(spender != address(0), "ERC20: approval to address(0)");
        uint256 allowance_ = s.allowances[owner][spender];
        if (value != 0) {
            unchecked {
                uint256 newAllowance = allowance_ + value;
                require(newAllowance > allowance_, "ERC20: allowance overflow");
                s.allowances[owner][spender] = newAllowance;
                allowance_ = newAllowance;
            }
        }
        emit Approval(owner, spender, allowance_);
    }

    
    
    
    
    
    
    
    
    function decreaseAllowance(Layout storage s, address owner, address spender, uint256 value) internal {
        require(spender != address(0), "ERC20: approval to address(0)");
        uint256 allowance_ = s.allowances[owner][spender];

        if (allowance_ != type(uint256).max && value != 0) {
            unchecked {
                // save gas when allowance is maximal by not reducing it (see https://github.com/ethereum/EIPs/issues/717)
                uint256 newAllowance = allowance_ - value;
                require(newAllowance < allowance_, "ERC20: insufficient allowance");
                s.allowances[owner][spender] = newAllowance;
                allowance_ = newAllowance;
            }
        }
        emit Approval(owner, spender, allowance_);
    }

    
    
    
    
    
    
    
    
    function transfer(Layout storage s, address from, address to, uint256 value) internal {
        require(to != address(0), "ERC20: transfer to address(0)");

        if (value != 0) {
            uint256 balance = s.balances[from];
            unchecked {
                uint256 newBalance = balance - value;
                require(newBalance < balance, "ERC20: insufficient balance");
                if (from != to) {
                    s.balances[from] = newBalance;
                    s.balances[to] += value;
                }
            }
        }

        emit Transfer(from, to, value);
    }

    
    
    
    
    
    
    
    
    
    
    
    function transferFrom(Layout storage s, address sender, address from, address to, uint256 value) internal {
        if (from != sender) {
            s.decreaseAllowance(from, sender, value);
        }
        s.transfer(from, to, value);
    }

    //================================================= Batch Transfers ==================================================//

    
    
    
    
    
    
    
    
    
    function batchTransfer(Layout storage s, address from, address[] calldata recipients, uint256[] calldata values) internal {
        uint256 length = recipients.length;
        require(length == values.length, "ERC20: inconsistent arrays");

        if (length == 0) return;

        uint256 balance = s.balances[from];

        uint256 totalValue;
        uint256 selfTransferTotalValue;
        unchecked {
            for (uint256 i; i != length; ++i) {
                address to = recipients[i];
                require(to != address(0), "ERC20: transfer to address(0)");

                uint256 value = values[i];
                if (value != 0) {
                    uint256 newTotalValue = totalValue + value;
                    require(newTotalValue > totalValue, "ERC20: values overflow");
                    totalValue = newTotalValue;
                    if (from != to) {
                        s.balances[to] += value;
                    } else {
                        require(value <= balance, "ERC20: insufficient balance");
                        selfTransferTotalValue += value; // cannot overflow as 'selfTransferTotalValue <= totalValue' is always true
                    }
                }
                emit Transfer(from, to, value);
            }

            if (totalValue != 0 && totalValue != selfTransferTotalValue) {
                uint256 newBalance = balance - totalValue;
                require(newBalance < balance, "ERC20: insufficient balance"); // balance must be sufficient, including self-transfers
                s.balances[from] = newBalance + selfTransferTotalValue; // do not deduct self-transfers from the sender balance
            }
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    function batchTransferFrom(Layout storage s, address sender, address from, address[] calldata recipients, uint256[] calldata values) internal {
        uint256 length = recipients.length;
        require(length == values.length, "ERC20: inconsistent arrays");

        if (length == 0) return;

        uint256 balance = s.balances[from];

        uint256 totalValue;
        uint256 selfTransferTotalValue;
        unchecked {
            for (uint256 i; i != length; ++i) {
                address to = recipients[i];
                require(to != address(0), "ERC20: transfer to address(0)");

                uint256 value = values[i];

                if (value != 0) {
                    uint256 newTotalValue = totalValue + value;
                    require(newTotalValue > totalValue, "ERC20: values overflow");
                    totalValue = newTotalValue;
                    if (from != to) {
                        s.balances[to] += value;
                    } else {
                        require(value <= balance, "ERC20: insufficient balance");
                        selfTransferTotalValue += value; // cannot overflow as 'selfTransferTotalValue <= totalValue' is always true
                    }
                }

                emit Transfer(from, to, value);
            }

            if (totalValue != 0 && totalValue != selfTransferTotalValue) {
                uint256 newBalance = balance - totalValue;
                require(newBalance < balance, "ERC20: insufficient balance"); // balance must be sufficient, including self-transfers
                s.balances[from] = newBalance + selfTransferTotalValue; // do not deduct self-transfers from the sender balance
            }
        }

        if (from != sender) {
            s.decreaseAllowance(from, sender, totalValue);
        }
    }

    //================================================= Safe Transfers ==================================================//

    
    
    
    
    
    
    
    
    
    
    
    function safeTransfer(Layout storage s, address from, address to, uint256 value, bytes calldata data) internal {
        s.transfer(from, to, value);
        if (to.isContract()) {
            _callOnERC20Received(from, from, to, value, data);
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function safeTransferFrom(Layout storage s, address sender, address from, address to, uint256 value, bytes calldata data) internal {
        s.transferFrom(sender, from, to, value);
        if (to.isContract()) {
            _callOnERC20Received(sender, from, to, value, data);
        }
    }

    //================================================= Minting ==================================================//

    
    
    
    
    
    
    
    function mint(Layout storage s, address to, uint256 value) internal {
        require(to != address(0), "ERC20: mint to address(0)");
        if (value != 0) {
            uint256 supply = s.supply;
            unchecked {
                uint256 newSupply = supply + value;
                require(newSupply > supply, "ERC20: supply overflow");
                s.supply = newSupply;
                s.balances[to] += value; // balance cannot overflow if supply does not
            }
        }
        emit Transfer(address(0), to, value);
    }

    
    
    
    
    
    
    
    
    function batchMint(Layout storage s, address[] memory recipients, uint256[] memory values) internal {
        uint256 length = recipients.length;
        require(length == values.length, "ERC20: inconsistent arrays");

        if (length == 0) return;

        uint256 totalValue;
        unchecked {
            for (uint256 i; i != length; ++i) {
                address to = recipients[i];
                require(to != address(0), "ERC20: mint to address(0)");

                uint256 value = values[i];
                if (value != 0) {
                    uint256 newTotalValue = totalValue + value;
                    require(newTotalValue > totalValue, "ERC20: values overflow");
                    totalValue = newTotalValue;
                    s.balances[to] += value; // balance cannot overflow if supply does not
                }
                emit Transfer(address(0), to, value);
            }

            if (totalValue != 0) {
                uint256 supply = s.supply;
                uint256 newSupply = supply + totalValue;
                require(newSupply > supply, "ERC20: supply overflow");
                s.supply = newSupply;
            }
        }
    }

    //================================================= Burning ==================================================//

    
    
    
    
    
    
    function burn(Layout storage s, address from, uint256 value) internal {
        if (value != 0) {
            uint256 balance = s.balances[from];
            unchecked {
                uint256 newBalance = balance - value;
                require(newBalance < balance, "ERC20: insufficient balance");
                s.balances[from] = newBalance;
                s.supply -= value; // will not underflow if balance does not
            }
        }

        emit Transfer(from, address(0), value);
    }

    
    
    
    
    
    
    
    
    
    function burnFrom(Layout storage s, address sender, address from, uint256 value) internal {
        if (from != sender) {
            s.decreaseAllowance(from, sender, value);
        }
        s.burn(from, value);
    }

    
    
    
    
    
    
    
    
    
    
    function batchBurnFrom(Layout storage s, address sender, address[] calldata owners, uint256[] calldata values) internal {
        uint256 length = owners.length;
        require(length == values.length, "ERC20: inconsistent arrays");

        if (length == 0) return;

        uint256 totalValue;
        unchecked {
            for (uint256 i; i != length; ++i) {
                address from = owners[i];
                uint256 value = values[i];

                if (from != sender) {
                    s.decreaseAllowance(from, sender, value);
                }

                if (value != 0) {
                    uint256 balance = s.balances[from];
                    uint256 newBalance = balance - value;
                    require(newBalance < balance, "ERC20: insufficient balance");
                    s.balances[from] = newBalance;
                    totalValue += value; // totalValue cannot overflow if the individual balances do not underflow
                }

                emit Transfer(from, address(0), value);
            }

            if (totalValue != 0) {
                s.supply -= totalValue; // _totalSupply cannot underfow as balances do not underflow
            }
        }
    }

    
    
    
    function totalSupply(Layout storage s) internal view returns (uint256 supply) {
        return s.supply;
    }

    
    
    
    
    function balanceOf(Layout storage s, address owner) internal view returns (uint256 balance) {
        return s.balances[owner];
    }

    
    
    
    
    
    function allowance(Layout storage s, address owner, address spender) internal view returns (uint256 value) {
        return s.allowances[owner][spender];
    }

    function layout() internal pure returns (Layout storage s) {
        bytes32 position = LAYOUT_STORAGE_SLOT;
        assembly {
            s.slot := position
        }
    }

    
    
    
    
    
    
    
    function _callOnERC20Received(address sender, address from, address to, uint256 value, bytes memory data) private {
        require(IERC20Receiver(to).onERC20Received(sender, from, value, data) == ERC20_RECEIVED, "ERC20: safe transfer rejected");
    }
}

pragma solidity ^0.8.0;



library ExitPayloadReader {
    using RLPReader for bytes;
    using RLPReader for RLPReader.RLPItem;

    uint8 constant WORD_SIZE = 32;

    struct ExitPayload {
        RLPReader.RLPItem[] data;
    }

    struct Receipt {
        RLPReader.RLPItem[] data;
        bytes raw;
        uint256 logIndex;
    }

    struct Log {
        RLPReader.RLPItem data;
        RLPReader.RLPItem[] list;
    }

    struct LogTopics {
        RLPReader.RLPItem[] data;
    }

    // copy paste of private copy() from RLPReader to avoid changing of existing contracts
    function copy(
        uint256 src,
        uint256 dest,
        uint256 len
    ) private pure {
        if (len == 0) return;

        // copy as many word sizes as possible
        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }
        
        if (len == 0) return;

        // left over bytes. Mask is used to remove unwanted bytes from the word
        uint256 mask = 256**(WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask)) // zero out src
            let destpart := and(mload(dest), mask) // retrieve the bytes
            mstore(dest, or(destpart, srcpart))
        }
    }

    function toExitPayload(bytes memory data) internal pure returns (ExitPayload memory) {
        RLPReader.RLPItem[] memory payloadData = data.toRlpItem().toList();

        return ExitPayload(payloadData);
    }

    function getHeaderNumber(ExitPayload memory payload) internal pure returns (uint256) {
        return payload.data[0].toUint();
    }

    function getBlockProof(ExitPayload memory payload) internal pure returns (bytes memory) {
        return payload.data[1].toBytes();
    }

    function getBlockNumber(ExitPayload memory payload) internal pure returns (uint256) {
        return payload.data[2].toUint();
    }

    function getBlockTime(ExitPayload memory payload) internal pure returns (uint256) {
        return payload.data[3].toUint();
    }

    function getTxRoot(ExitPayload memory payload) internal pure returns (bytes32) {
        return bytes32(payload.data[4].toUint());
    }

    function getReceiptRoot(ExitPayload memory payload) internal pure returns (bytes32) {
        return bytes32(payload.data[5].toUint());
    }

    function getReceipt(ExitPayload memory payload) internal pure returns (Receipt memory receipt) {
        receipt.raw = payload.data[6].toBytes();
        RLPReader.RLPItem memory receiptItem = receipt.raw.toRlpItem();

        if (receiptItem.isList()) {
            // legacy tx
            receipt.data = receiptItem.toList();
        } else {
            // pop first byte before parsting receipt
            bytes memory typedBytes = receipt.raw;
            bytes memory result = new bytes(typedBytes.length - 1);
            uint256 srcPtr;
            uint256 destPtr;
            assembly {
                srcPtr := add(33, typedBytes)
                destPtr := add(0x20, result)
            }

            copy(srcPtr, destPtr, result.length);
            receipt.data = result.toRlpItem().toList();
        }

        receipt.logIndex = getReceiptLogIndex(payload);
        return receipt;
    }

    function getReceiptProof(ExitPayload memory payload) internal pure returns (bytes memory) {
        return payload.data[7].toBytes();
    }

    function getBranchMaskAsBytes(ExitPayload memory payload) internal pure returns (bytes memory) {
        return payload.data[8].toBytes();
    }

    function getBranchMaskAsUint(ExitPayload memory payload) internal pure returns (uint256) {
        return payload.data[8].toUint();
    }

    function getReceiptLogIndex(ExitPayload memory payload) internal pure returns (uint256) {
        return payload.data[9].toUint();
    }

    // Receipt methods
    function toBytes(Receipt memory receipt) internal pure returns (bytes memory) {
        return receipt.raw;
    }

    function getLog(Receipt memory receipt) internal pure returns (Log memory) {
        RLPReader.RLPItem memory logData = receipt.data[3].toList()[receipt.logIndex];
        return Log(logData, logData.toList());
    }

    // Log methods
    function getEmitter(Log memory log) internal pure returns (address) {
        return RLPReader.toAddress(log.list[0]);
    }

    function getTopics(Log memory log) internal pure returns (LogTopics memory) {
        return LogTopics(log.list[1].toList());
    }

    function getData(Log memory log) internal pure returns (bytes memory) {
        return log.list[2].toBytes();
    }

    function toRlpBytes(Log memory log) internal pure returns (bytes memory) {
        return log.data.toRlpBytes();
    }

    // LogTopics methods
    function getField(LogTopics memory topics, uint256 index) internal pure returns (RLPReader.RLPItem memory) {
        return topics.data[index];
    }
}

// 
pragma solidity ^0.8.0;

library Merkle {
    function checkMembership(
        bytes32 leaf,
        uint256 index,
        bytes32 rootHash,
        bytes memory proof
    ) internal pure returns (bool) {
        require(proof.length % 32 == 0, "Invalid proof length");
        uint256 proofHeight = proof.length / 32;
        // Proof of size n means, height of the tree is n+1.
        // In a tree of height n+1, max #leafs possible is 2 ^ n
        require(index < 2**proofHeight, "Leaf index is too big");

        bytes32 proofElement;
        bytes32 computedHash = leaf;
        for (uint256 i = 32; i <= proof.length; i += 32) {
            assembly {
                proofElement := mload(add(proof, i))
            }

            if (index % 2 == 0) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }

            index = index / 2;
        }
        return computedHash == rootHash;
    }
}

// 
pragma solidity ^0.8.0;



library MerklePatriciaProof {
    /*
     * @dev Verifies a merkle patricia proof.
     * @param value The terminating value in the trie.
     * @param encodedPath The path in the trie leading to value.
     * @param rlpParentNodes The rlp encoded stack of nodes.
     * @param root The root hash of the trie.
     * @return The boolean validity of the proof.
     */
    function verify(
        bytes memory value,
        bytes memory encodedPath,
        bytes memory rlpParentNodes,
        bytes32 root
    ) internal pure returns (bool) {
        RLPReader.RLPItem memory item = RLPReader.toRlpItem(rlpParentNodes);
        RLPReader.RLPItem[] memory parentNodes = RLPReader.toList(item);

        bytes memory currentNode;
        RLPReader.RLPItem[] memory currentNodeList;

        bytes32 nodeKey = root;
        uint256 pathPtr = 0;

        bytes memory path = _getNibbleArray(encodedPath);
        if (path.length == 0) {
            return false;
        }

        for (uint256 i = 0; i < parentNodes.length; i++) {
            if (pathPtr > path.length) {
                return false;
            }

            currentNode = RLPReader.toRlpBytes(parentNodes[i]);
            if (nodeKey != keccak256(currentNode)) {
                return false;
            }
            currentNodeList = RLPReader.toList(parentNodes[i]);

            if (currentNodeList.length == 17) {
                if (pathPtr == path.length) {
                    if (keccak256(RLPReader.toBytes(currentNodeList[16])) == keccak256(value)) {
                        return true;
                    } else {
                        return false;
                    }
                }

                uint8 nextPathNibble = uint8(path[pathPtr]);
                if (nextPathNibble > 16) {
                    return false;
                }
                nodeKey = bytes32(RLPReader.toUintStrict(currentNodeList[nextPathNibble]));
                pathPtr += 1;
            } else if (currentNodeList.length == 2) {
                uint256 traversed = _nibblesToTraverse(RLPReader.toBytes(currentNodeList[0]), path, pathPtr);
                if (pathPtr + traversed == path.length) {
                    //leaf node
                    if (keccak256(RLPReader.toBytes(currentNodeList[1])) == keccak256(value)) {
                        return true;
                    } else {
                        return false;
                    }
                }

                //extension node
                if (traversed == 0) {
                    return false;
                }

                pathPtr += traversed;
                nodeKey = bytes32(RLPReader.toUintStrict(currentNodeList[1]));
            } else {
                return false;
            }
        }
    }

    function _nibblesToTraverse(
        bytes memory encodedPartialPath,
        bytes memory path,
        uint256 pathPtr
    ) private pure returns (uint256) {
        uint256 len = 0;
        // encodedPartialPath has elements that are each two hex characters (1 byte), but partialPath
        // and slicedPath have elements that are each one hex character (1 nibble)
        bytes memory partialPath = _getNibbleArray(encodedPartialPath);
        bytes memory slicedPath = new bytes(partialPath.length);

        // pathPtr counts nibbles in path
        // partialPath.length is a number of nibbles
        for (uint256 i = pathPtr; i < pathPtr + partialPath.length; i++) {
            bytes1 pathNibble = path[i];
            slicedPath[i - pathPtr] = pathNibble;
        }

        if (keccak256(partialPath) == keccak256(slicedPath)) {
            len = partialPath.length;
        } else {
            len = 0;
        }
        return len;
    }

    // bytes b must be hp encoded
    function _getNibbleArray(bytes memory b) internal pure returns (bytes memory) {
        bytes memory nibbles = "";
        if (b.length > 0) {
            uint8 offset;
            uint8 hpNibble = uint8(_getNthNibbleOfBytes(0, b));
            if (hpNibble == 1 || hpNibble == 3) {
                nibbles = new bytes(b.length * 2 - 1);
                bytes1 oddNibble = _getNthNibbleOfBytes(1, b);
                nibbles[0] = oddNibble;
                offset = 1;
            } else {
                nibbles = new bytes(b.length * 2 - 2);
                offset = 0;
            }

            for (uint256 i = offset; i < nibbles.length; i++) {
                nibbles[i] = _getNthNibbleOfBytes(i - offset + 2, b);
            }
        }
        return nibbles;
    }

    function _getNthNibbleOfBytes(uint256 n, bytes memory str) private pure returns (bytes1) {
        return bytes1(n % 2 == 0 ? uint8(str[n / 2]) / 0x10 : uint8(str[n / 2]) % 0x10);
    }
}

/*
 * @author Hamdi Allam [email protected]
 * Please reach out with any questions or concerns
 */
pragma solidity ^0.8.0;

library RLPReader {
    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START = 0xb8;
    uint8 constant LIST_SHORT_START = 0xc0;
    uint8 constant LIST_LONG_START = 0xf8;
    uint8 constant WORD_SIZE = 32;

    struct RLPItem {
        uint256 len;
        uint256 memPtr;
    }

    struct Iterator {
        RLPItem item; // Item that's being iterated over.
        uint256 nextPtr; // Position of the next item in the list.
    }

    /*
     * @dev Returns the next element in the iteration. Reverts if it has not next element.
     * @param self The iterator.
     * @return The next element in the iteration.
     */
    function next(Iterator memory self) internal pure returns (RLPItem memory) {
        require(hasNext(self));

        uint256 ptr = self.nextPtr;
        uint256 itemLength = _itemLength(ptr);
        self.nextPtr = ptr + itemLength;

        return RLPItem(itemLength, ptr);
    }

    /*
     * @dev Returns true if the iteration has more elements.
     * @param self The iterator.
     * @return true if the iteration has more elements.
     */
    function hasNext(Iterator memory self) internal pure returns (bool) {
        RLPItem memory item = self.item;
        return self.nextPtr < item.memPtr + item.len;
    }

    /*
     * @param item RLP encoded bytes
     */
    function toRlpItem(bytes memory item) internal pure returns (RLPItem memory) {
        uint256 memPtr;
        assembly {
            memPtr := add(item, 0x20)
        }

        return RLPItem(item.length, memPtr);
    }

    /*
     * @dev Create an iterator. Reverts if item is not a list.
     * @param self The RLP item.
     * @return An 'Iterator' over the item.
     */
    function iterator(RLPItem memory self) internal pure returns (Iterator memory) {
        require(isList(self));

        uint256 ptr = self.memPtr + _payloadOffset(self.memPtr);
        return Iterator(self, ptr);
    }

    /*
     * @param item RLP encoded bytes
     */
    function rlpLen(RLPItem memory item) internal pure returns (uint256) {
        return item.len;
    }

    /*
     * @param item RLP encoded bytes
     */
    function payloadLen(RLPItem memory item) internal pure returns (uint256) {
        return item.len - _payloadOffset(item.memPtr);
    }

    /*
     * @param item RLP encoded list in bytes
     */
    function toList(RLPItem memory item) internal pure returns (RLPItem[] memory) {
        require(isList(item));

        uint256 items = numItems(item);
        RLPItem[] memory result = new RLPItem[](items);

        uint256 memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 dataLen;
        for (uint256 i = 0; i < items; i++) {
            dataLen = _itemLength(memPtr);
            result[i] = RLPItem(dataLen, memPtr);
            memPtr = memPtr + dataLen;
        }

        return result;
    }

    // @return indicator whether encoded payload is a list. negate this function call for isData.
    function isList(RLPItem memory item) internal pure returns (bool) {
        if (item.len == 0) return false;

        uint8 byte0;
        uint256 memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START) return false;
        return true;
    }

    /*
     * @dev A cheaper version of keccak256(toRlpBytes(item)) that avoids copying memory.
     * @return keccak256 hash of RLP encoded bytes.
     */
    function rlpBytesKeccak256(RLPItem memory item) internal pure returns (bytes32) {
        uint256 ptr = item.memPtr;
        uint256 len = item.len;
        bytes32 result;
        assembly {
            result := keccak256(ptr, len)
        }
        return result;
    }

    function payloadLocation(RLPItem memory item) internal pure returns (uint256, uint256) {
        uint256 offset = _payloadOffset(item.memPtr);
        uint256 memPtr = item.memPtr + offset;
        uint256 len = item.len - offset; // data length
        return (memPtr, len);
    }

    /*
     * @dev A cheaper version of keccak256(toBytes(item)) that avoids copying memory.
     * @return keccak256 hash of the item payload.
     */
    function payloadKeccak256(RLPItem memory item) internal pure returns (bytes32) {
        (uint256 memPtr, uint256 len) = payloadLocation(item);
        bytes32 result;
        assembly {
            result := keccak256(memPtr, len)
        }
        return result;
    }

    /** RLPItem conversions into data types **/

    // @returns raw rlp encoding in bytes
    function toRlpBytes(RLPItem memory item) internal pure returns (bytes memory) {
        bytes memory result = new bytes(item.len);
        if (result.length == 0) return result;

        uint256 ptr;
        assembly {
            ptr := add(0x20, result)
        }

        copy(item.memPtr, ptr, item.len);
        return result;
    }

    // any non-zero byte is considered true
    function toBoolean(RLPItem memory item) internal pure returns (bool) {
        require(item.len == 1);
        uint256 result;
        uint256 memPtr = item.memPtr;
        assembly {
            result := byte(0, mload(memPtr))
        }

        return result == 0 ? false : true;
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {
        // 1 byte for the length prefix
        require(item.len == 21);

        return address(uint160(toUint(item)));
    }

    function toUint(RLPItem memory item) internal pure returns (uint256) {
        require(item.len > 0 && item.len <= 33);

        uint256 offset = _payloadOffset(item.memPtr);
        uint256 len = item.len - offset;

        uint256 result;
        uint256 memPtr = item.memPtr + offset;
        assembly {
            result := mload(memPtr)

            // shfit to the correct location if neccesary
            if lt(len, 32) {
                result := div(result, exp(256, sub(32, len)))
            }
        }

        return result;
    }

    // enforces 32 byte length
    function toUintStrict(RLPItem memory item) internal pure returns (uint256) {
        // one byte prefix
        require(item.len == 33);

        uint256 result;
        uint256 memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {
        require(item.len > 0);

        uint256 offset = _payloadOffset(item.memPtr);
        uint256 len = item.len - offset; // data length
        bytes memory result = new bytes(len);

        uint256 destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(item.memPtr + offset, destPtr, len);
        return result;
    }

    /*
     * Private Helpers
     */

    // @return number of payload items inside an encoded list.
    function numItems(RLPItem memory item) private pure returns (uint256) {
        if (item.len == 0) return 0;

        uint256 count = 0;
        uint256 currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
            currPtr = currPtr + _itemLength(currPtr); // skip over an item
            count++;
        }

        return count;
    }

    // @return entire rlp item byte length
    function _itemLength(uint256 memPtr) private pure returns (uint256) {
        uint256 itemLen;
        uint256 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) itemLen = 1;
        else if (byte0 < STRING_LONG_START) itemLen = byte0 - STRING_SHORT_START + 1;
        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                memPtr := add(memPtr, 1) // skip over the first byte
                /* 32 byte word size */
                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len
                itemLen := add(dataLen, add(byteLen, 1))
            }
        } else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        } else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                memPtr := add(memPtr, 1)

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        return itemLen;
    }

    // @return number of bytes until the data
    function _payloadOffset(uint256 memPtr) private pure returns (uint256) {
        uint256 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) return 0;
        else if (byte0 < STRING_LONG_START || (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START)) return 1;
        else if (byte0 < LIST_SHORT_START)
            // being explicit
            return byte0 - (STRING_LONG_START - 1) + 1;
        else return byte0 - (LIST_LONG_START - 1) + 1;
    }

    /*
     * @param src Pointer to source
     * @param dest Pointer to destination
     * @param len Amount of memory to copy from the source
     */
    function copy(
        uint256 src,
        uint256 dest,
        uint256 len
    ) private pure {
        if (len == 0) return;

        // copy as many word sizes as possible
        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }

        if (len == 0) return;

        // left over bytes. Mask is used to remove unwanted bytes from the word
        uint256 mask = 256**(WORD_SIZE - len) - 1;

        assembly {
            let srcpart := and(mload(src), not(mask)) // zero out src
            let destpart := and(mload(dest), mask) // retrieve the bytes
            mstore(dest, or(destpart, srcpart))
        }
    }
}

// 
pragma solidity ^0.8.0;






interface IFxStateSender {
    function sendMessageToChild(address _receiver, bytes calldata _data) external;
}

contract ICheckpointManager {
    struct HeaderBlock {
        bytes32 root;
        uint256 start;
        uint256 end;
        uint256 createdAt;
        address proposer;
    }

    /**
     * @notice mapping of checkpoint header numbers to block details
     * @dev These checkpoints are submited by plasma contracts
     */
    mapping(uint256 => HeaderBlock) public headerBlocks;
}

// 
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        
        assembly {
            r.slot := slot
        }
    }
}

// 
pragma solidity 0.8.17;











contract FxERC20MintBurnRootTunnel is FxERC20RootTunnel {
    constructor(
        address checkpointManager,
        address fxRoot,
        address fxERC20Token,
        IForwarderRegistry forwarderRegistry
    ) FxERC20RootTunnel(checkpointManager, fxRoot, fxERC20Token, forwarderRegistry) {}

    
    function _encodeChildTokenInitArgs(address rootToken) internal virtual override returns (bytes memory) {
        IERC20Detailed rootTokenContract = IERC20Detailed(rootToken);
        string memory name = rootTokenContract.name();
        string memory symbol = rootTokenContract.symbol();
        uint8 decimals = rootTokenContract.decimals();
        string memory tokenURI = IERC20Metadata(rootToken).tokenURI();
        address owner = IERC173(rootToken).owner();

        return abi.encode(name, symbol, decimals, tokenURI, owner);
    }

    
    
    function _depositReceivedTokens(address rootToken, uint256 amount) internal virtual override {
        IERC20Burnable(rootToken).burn(amount);
    }

    
    
    function _depositTokensFrom(address rootToken, address depositor, uint256 amount) internal virtual override {
        IERC20Burnable(rootToken).burnFrom(depositor, amount);
    }

    
    
    function _withdraw(address rootToken, address receiver, uint256 amount) internal virtual override {
        IERC20Mintable(rootToken).mint(receiver, amount);
    }
}
