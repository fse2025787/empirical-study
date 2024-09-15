// SPDX-License-Identifier: UNLICENSED

/**
 *Submitted for verification at Etherscan.io on 2021-03-18
*/

// 
pragma solidity ^0.6.12;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
interface IMultiSig { 
    function isSigner(address _recepient) external returns(bool);
}

contract MultiSigWallet is Context, ReentrancyGuard, IMultiSig {

    event SignerChanged(address indexed previousSigner, address indexed newSigner);
    event Deposit(address indexed signer, uint256 value);
    event Withdraw(address indexed recepient, uint256 value);

    event TxSubmitted(address indexed signer, uint256 indexed transactionId);

    event TxConfirmed(address indexed signer, uint256 indexed transactionId);
    event TxConfirmationRevoked(address indexed signer, uint256 indexed transactionId);
    
    event TxExecuted(uint256 indexed transactionId);
    event TxExecutionFailed(uint256 indexed transactionId);
    
    
    /*
     *  Constants
     */
    uint256 constant MAX_SIGNERS = 15;
    uint256 constant THRESHOLD_SIGNERS = 3;


    /*
     *  Storage
     */
    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public override isSigner;
    address[] public signers;

    uint public transactionCount;

    struct Transaction {
        string name;
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    /*
     *  Modifiers
     */
    modifier onlyMultisig() {
        require(_msgSender() == address(this), "Not multisig");
        _;
    }

    modifier isNotSigner(address _account) {
        require(_account != address(0), "Zero address");
        require(!isSigner[_account], "Already a signer");
        _;
    }

    modifier isAllowedSigner(address _account) {
        require(isSigner[_account], "Is not a signer");
        _;
    }

    modifier transactionExists(uint256 transactionId) {
        require(transactions[transactionId].destination != address(0), "Incorrect id");
        _;
    }

    modifier confirmed(uint256 transactionId, address signer) {
        require(confirmations[transactionId][signer], "Not confirmed");
        _;
    }

    modifier notConfirmed(uint256 transactionId, address signer) {
        require(!confirmations[transactionId][signer], "Already confirmed");
        _;
    }

    modifier notExecuted(uint256 transactionId) {
        require(!transactions[transactionId].executed, "Already executed");
        _;
    }

    
    receive() external payable
    {
        if (msg.value > 0)
            emit Deposit(msg.sender, msg.value);
    }

    /*
     * Public functions
     */
    
    
    constructor(address[] memory _signers) public
    {
        require(_signers.length == MAX_SIGNERS, "Incorrect signers number");
        signers = new address[](MAX_SIGNERS);
        for (uint256 i = 0; i < MAX_SIGNERS; i++) {
            require(_signers[i] != address(0), "Zero address");
            require(!isSigner[_signers[i]], "Signer already registered");
            isSigner[_signers[i]] = true;
            signers[i] = _signers[i];
        }

        transactionCount = 0;
    }

    
    
    
    function returnDeposit(address payable _recepient, uint256 _amount) external onlyMultisig
        isAllowedSigner(_recepient)
    {
        require(_amount <= address(this).balance, "Incorrect amount");

        emit Withdraw(_recepient, _amount);
        _recepient.transfer(_amount);
    }

    
    
    
    function replaceSigner(address _previousSigner, address _newSigner) external onlyMultisig
        isAllowedSigner(_previousSigner)
        isNotSigner(_newSigner)
    {
        for (uint i = 0; i < MAX_SIGNERS; i++) {
            if (signers[i] == _previousSigner) {
                signers[i] = _newSigner;
                break;
            }
        }
        isSigner[_previousSigner] = false;
        isSigner[_newSigner] = true;

        emit SignerChanged(_previousSigner, _newSigner);
    }

    
    
    
    
    
    function submitTransaction(string memory _name, address _destination, uint256 _ethValue, bytes memory _data) external
        isAllowedSigner(_msgSender())
        returns (uint256 transactionId)
    {
        require(_destination != address(0), "Zero address");
        transactionId = transactionCount;

        transactions[transactionId] = Transaction({
            name: _name,
            destination: _destination,
            value: _ethValue,
            data: _data,
            executed: false
        });

        transactionCount += 1;
        emit TxSubmitted(_msgSender(), transactionId);

        confirmTransaction(transactionId);
    }

    
    
    function confirmTransaction(uint256 transactionId) public
        isAllowedSigner(_msgSender())
        transactionExists(transactionId)
        notConfirmed(transactionId, _msgSender())
    {
        confirmations[transactionId][_msgSender()] = true;

        emit TxConfirmed(_msgSender(), transactionId);

        /// Execute the transaction if it is the last confirmation
        executeTransaction(transactionId);
    }

    
    
    function revokeConfirmation(uint transactionId) external
        isAllowedSigner(_msgSender())
        transactionExists(transactionId)
        confirmed(transactionId, _msgSender())
        notExecuted(transactionId)
    {
        confirmations[transactionId][_msgSender()] = false;
        emit TxConfirmationRevoked(_msgSender(), transactionId);
    }

    
    
    function executeTransaction(uint transactionId) internal
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            if (external_call(transactionId)) {
                transactions[transactionId].executed = true;
                emit TxExecuted(transactionId);
            }
            else {
                confirmations[transactionId][_msgSender()] = false;
                emit TxExecutionFailed(transactionId);
            }
        }
    }

    function external_call(uint256 transactionId) internal returns (bool) {
        bool result;
        Transaction storage txn = transactions[transactionId];
        address destination = txn.destination;
        uint256 value = txn.value;
        bytes memory data =  txn.data;
        uint256 len = data.length;
        assembly {
            let x := mload(0x40)   // Memory for output
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas(), 34710),   // 34710 is the value that solidity is currently emitting
                                   // It includes callGas (700) + callVeryLow (3) + callValueTransferGas (9000) +
                                   // callNewAccountGas (25000, if destination address does not exist)
                destination,
                value,
                d,
                len,        // Size of the input (in bytes) - this is what fixes the padding problem
                x,
                0                  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }

    
    
    
    function isConfirmed(uint256 transactionId) public view returns (bool)
    {
        if (transactions[transactionId].executed) {
            return true;
        }

        uint256 count = 0;
        for (uint256 i = 0; i < MAX_SIGNERS; i++) {
            if (confirmations[transactionId][signers[i]])
                count += 1;
            if (count == THRESHOLD_SIGNERS)
                return true;
        }
        return false;
    }

    
    
    
    function getConfirmationCount(uint256 transactionId) external view returns (uint256 count)
    {
        if (transactions[transactionId].executed) {
            return THRESHOLD_SIGNERS;
        }

        for (uint256 i = 0; i < MAX_SIGNERS; i++)
            if (confirmations[transactionId][signers[i]])
                count += 1;
    }

    
    
    function getPendingTransactionCount() external view returns (uint256 count)
    {
        for (uint256 i = 0; i < transactionCount; i++)
            if (!transactions[i].executed)
                count += 1;
    }

    
    
    function getSigners() external view returns (address[] memory)
    {
        return signers;
    }

    
    
    
    function getConfirmations(uint256 transactionId) external view
        returns (address[] memory _confirmations)
    {
        address[] memory confirmationsTemp = new address[](MAX_SIGNERS);
        uint256 count = 0;
        uint i;
        for (i = 0; i < MAX_SIGNERS; i++)
            if (confirmations[transactionId][signers[i]]) {
                confirmationsTemp[count] = signers[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

    
    
    
    
    function getPendingTransactionIds(uint256 from, uint256 to) external view
        returns (uint[] memory _transactionIds)
    {
        require(to > from && to <= transactionCount, "Incorrect indeces");
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint penNumCount = 0;
        uint i;
        for (i = 0; i < transactionCount; i++)
        {
            if ( !transactions[i].executed)
            {
                if (penNumCount < from)
                {
                    penNumCount += 1;
                    continue;
                }
                if (penNumCount < to)
                {
                    transactionIdsTemp[count] = i;
                    count += 1;
                }
                else
                    break;
            }
        }

        _transactionIds = new uint[](to - from);
        for (i = from; i < to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }
}