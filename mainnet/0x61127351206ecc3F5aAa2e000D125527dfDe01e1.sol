// SPDX-License-Identifier: GPL-3.0-only

/**
 *Submitted for verification at Etherscan.io on 2022-07-06
*/

// 

pragma solidity 0.8.12;

interface IEligibility {

//    function getGate(uint) external view returns (struct Gate)
//    function addGate(uint...) external

    
    
    
    function isEligible(uint, address, bytes32[] calldata) external view returns (bool eligible);

    
    
    function passThruGate(uint, address, bytes32[] calldata) external;
}
library MerkleLib {

    function verifyProof(bytes32 root, bytes32 leaf, bytes32[] calldata proof) public pure returns (bool) {
        bytes32 currentHash = leaf;

        uint proofLength = proof.length;
        for (uint i; i < proofLength;) {
            currentHash = parentHash(currentHash, proof[i]);
            unchecked { ++i; }
        }

        return currentHash == root;
    }

    function parentHash(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return keccak256(a < b ? abi.encode(a, b) : abi.encode(b, a));
    }

}





contract MerkleEligibility is IEligibility {
    using MerkleLib for bytes32;

    // the address of the MerkleIdentity contract
    address public immutable gateMaster;

    // This represents a single gate or whitelist
    struct Gate {
        bytes32 root;  // merkle root of whitelist
        uint maxWithdrawalsAddress; // maximum amount of withdrawals per address
        uint maxWithdrawalsTotal;  // maximum total withdrawals allowed, summed across all addresses
        uint totalWithdrawals;  // number of withdrawals already made
    }

    // array-like mapping of gate structs
    mapping (uint => Gate) public gates;
    // count withdrawals per address timesWithdrawn[gateIndex][user] = count
    mapping(uint => mapping(address => uint)) public timesWithdrawn;
    // count the gates
    uint public numGates;

    error GateMasterOnly(address notGateMaster);
    error IneligibleRecipient(address recipient);

    
    
    constructor(address _gateMaster) {
        gateMaster = _gateMaster;
    }

    
    
    
    
    
    
    function addGate(bytes32 merkleRoot, uint maxWithdrawalsAddress, uint maxWithdrawalsTotal) external returns (uint) {
        // increment the number of roots
        numGates += 1;

        gates[numGates] = Gate(merkleRoot, maxWithdrawalsAddress, maxWithdrawalsTotal, 0);
        return numGates;
    }

    
    
    
    
    
    
    function getGate(uint index) external view returns (bytes32, uint, uint, uint) {
        Gate storage gate = gates[index];
        return (gate.root, gate.maxWithdrawalsAddress, gate.maxWithdrawalsTotal, gate.totalWithdrawals);
    }

    
    
    
    
    
    
    function isEligible(uint index, address recipient, bytes32[] calldata proof) public override view returns (bool) {
        Gate storage gate = gates[index];
        // We need to pack the 20 bytes address to the 32 bytes value, so we call abi.encode
        bytes32 leaf = keccak256(abi.encode(recipient));
        // Check the per-address count first
        bool countValid = timesWithdrawn[index][recipient] < gate.maxWithdrawalsAddress;
        // Then check global count and merkle proof
        return countValid && gate.totalWithdrawals < gate.maxWithdrawalsTotal && gate.root.verifyProof(leaf, proof);
    }

    
    
    
    
    
    function passThruGate(uint index, address recipient, bytes32[] calldata proof) external override {
        if (msg.sender != gateMaster) {
            revert GateMasterOnly(msg.sender);
        }

        // close re-entrance gate, prevent double withdrawals
        if (isEligible(index, recipient, proof) == false) {
            revert IneligibleRecipient(recipient);
        }

        timesWithdrawn[index][recipient] += 1;
        Gate storage gate = gates[index];
        gate.totalWithdrawals += 1;
    }
}