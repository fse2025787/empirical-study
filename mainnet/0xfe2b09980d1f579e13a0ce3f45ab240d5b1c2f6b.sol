// SPDX-License-Identifier: MIXED
pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2021-06-04
*/

// 

// File @boringcrypto/boring-solidity/contracts/[email protected]
// License-Identifier: MIT
pragma solidity 0.6.12;


// Audit on 5-Jan-2021 by Keno and BoringCrypto
// Source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol + Claimable.sol
// Edited by BoringCrypto

contract BoringOwnableData {
    address public owner;
    address public pendingOwner;
}

contract BoringOwnable is BoringOwnableData {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() public {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    
    /// Can only be invoked by the current `owner`.
    
    
    
    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) public onlyOwner {
        if (direct) {
            // Checks
            require(newOwner != address(0) || renounce, "Ownable: zero address");

            // Effects
            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            pendingOwner = address(0);
        } else {
            // Effects
            pendingOwner = newOwner;
        }
    }

    
    function claimOwnership() public {
        address _pendingOwner = pendingOwner;

        // Checks
        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        // Effects
        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}

// File contracts/MinimalTimeLock.sol
//License-Identifier: BSD-3-Clause

// Modified from https://etherscan.io/address/0x6d903f6003cca6255d85cca4d3b5e5146dc33925#code and https://github.com/boringcrypto/dictator-dao/blob/main/contracts/DictatorDAO.sol#L225
contract MinimalTimeLockFlat is BoringOwnable {
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint256 value, bytes data, uint256 eta);
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint256 value, bytes data);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint256 value, bytes data);

    uint256 public constant GRACE_PERIOD = 14 days;
    uint256 public constant DELAY = 2 days;
    mapping(bytes32 => uint256) public queuedTransactions;

    function queueTransaction(
        address target,
        uint256 value,
        bytes memory data
    ) public onlyOwner returns (bytes32) {
        bytes32 txHash = keccak256(abi.encode(target, value, data));
        uint256 eta = block.timestamp + DELAY;
        queuedTransactions[txHash] = eta;

        emit QueueTransaction(txHash, target, value, data, eta);
        return txHash;
    }

    function cancelTransaction(
        address target,
        uint256 value,
        bytes memory data
    ) public onlyOwner {
        bytes32 txHash = keccak256(abi.encode(target, value, data));
        queuedTransactions[txHash] = 0;

        emit CancelTransaction(txHash, target, value, data);
    }

    function executeTransaction(
        address target,
        uint256 value,
        bytes memory data
    ) public payable onlyOwner returns (bytes memory) {
        bytes32 txHash = keccak256(abi.encode(target, value, data));
        uint256 eta = queuedTransactions[txHash];
        require(block.timestamp >= eta, "Too early");
        require(block.timestamp <= eta + GRACE_PERIOD, "Tx stale");

        queuedTransactions[txHash] = 0;

        // solium-disable-next-line security/no-call-value
        (bool success, bytes memory returnData) = target.call{value: value}(data);
        require(success, "Tx reverted :(");

        emit ExecuteTransaction(txHash, target, value, data);

        return returnData;
    }
}