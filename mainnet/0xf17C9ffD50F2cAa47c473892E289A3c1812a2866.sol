// SPDX-License-Identifier: GPL-3.0-only

/**
 *Submitted for verification at Etherscan.io on 2022-07-06
*/

// 

pragma solidity 0.8.12;

interface IVoterID {
    /**
        @notice Minting function
    */
    function createIdentityFor(address newId, uint tokenId, string calldata uri) external;

    /**
        @notice Who has the authority to override metadata uri
    */
    function owner() external view returns (address);

    /**
        @notice How many of these things exist?
    */
    function totalSupply() external view returns (uint);
}
interface IPriceGate {

    
    function getCost(uint) external view returns (uint ethCost);

    
    function passThruGate(uint, address) external payable;
}
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








contract MerkleIdentity {
    using MerkleLib for bytes32;

    // this represents a mint of a single NFT contract with a fixed price gate and eligibility gate
    struct MerkleTree {
        bytes32 metadataMerkleRoot;  // root of merkle tree whose leaves are uri strings to be assigned to minted NFTs
        bytes32 ipfsHash; // ipfs hash of complete uri dataset, as redundancy so that merkle proof remain computable
        address nftAddress; // address of NFT contract to be minted
        address priceGateAddress;  // address price gate contract
        address eligibilityAddress;  // address of eligibility gate contract
        uint eligibilityIndex; // enables re-use of eligibility contracts
        uint priceIndex; // enables re-use of price gate contracts
    }

    // array-like mapping of index to MerkleTree structs
    mapping (uint => MerkleTree) public merkleTrees;
    // count the trees
    uint public numTrees;

    // management key used to set ipfs hashes and treeAdder addresses
    address public management;
    // treeAdder is address that can add trees, separated from management to prevent switching it to a broken contract
    address public treeAdder;

    // every time a merkle tree is added
    event MerkleTreeAdded(uint indexed index, address indexed nftAddress);

    error ManagementOnly(address notManagement);
    error TreeAdderOnly(address notTreeAdder);
    error BadMerkleIndex(uint index);
    error BadMerkleProof(bytes32[] proof, bytes32 root);

    // simple call gate
    modifier managementOnly() {
        if (msg.sender != management) {
            revert ManagementOnly(msg.sender);
        }
        _;
    }

    
    
    constructor(address _mgmt) {
        management = _mgmt;
        treeAdder = _mgmt;
    }

    
    
    
    function setManagement(address newMgmt) external managementOnly {
        management = newMgmt;
    }

    
    
    
    function setTreeAdder(address newAdder) external managementOnly {
        treeAdder = newAdder;
    }

    
    
    
    
    function setIpfsHash(uint merkleIndex, bytes32 hash) external managementOnly {
        MerkleTree storage tree = merkleTrees[merkleIndex];
        tree.ipfsHash = hash;
    }

    
    
    
    
    
    
    
    
    
    function addMerkleTree(
        bytes32 metadataMerkleRoot,
        bytes32 ipfsHash,
        address nftAddress,
        address priceGateAddress,
        address eligibilityAddress,
        uint eligibilityIndex,
        uint priceIndex) external returns (uint) {
        if (msg.sender != treeAdder) {
            revert TreeAdderOnly(msg.sender);
        }
        MerkleTree storage tree = merkleTrees[++numTrees];
        tree.metadataMerkleRoot = metadataMerkleRoot;
        tree.ipfsHash = ipfsHash;
        tree.nftAddress = nftAddress;
        tree.priceGateAddress = priceGateAddress;
        tree.eligibilityAddress = eligibilityAddress;
        tree.eligibilityIndex = eligibilityIndex;
        tree.priceIndex = priceIndex;
        emit MerkleTreeAdded(numTrees, nftAddress);
        return numTrees;
    }

    
    
    
    
    
    
    
    function withdraw(uint merkleIndex, uint tokenId, string calldata uri, bytes32[] calldata addressProof, bytes32[] calldata metadataProof) external payable {
        MerkleTree storage tree = merkleTrees[merkleIndex];
        IVoterID id = IVoterID(tree.nftAddress);

        // mint an identity first, this keeps the token-collision gas cost down
        id.createIdentityFor(msg.sender, tokenId, uri);

        // check that the merkle index is real
        if (merkleIndex > numTrees || merkleIndex == 0) {
            revert BadMerkleIndex(merkleIndex);
        }

        // verify that the metadata is real
        if (verifyMetadata(tree.metadataMerkleRoot, tokenId, uri, metadataProof) == false) {
            revert BadMerkleProof(metadataProof, tree.metadataMerkleRoot);
        }

        // check eligibility of address
        IEligibility(tree.eligibilityAddress).passThruGate(tree.eligibilityIndex, msg.sender, addressProof);

        // check that the price is right
        IPriceGate(tree.priceGateAddress).passThruGate{value: msg.value}(tree.priceIndex, msg.sender);

    }

    
    
    
    function getPrice(uint merkleIndex) public view returns (uint) {
        MerkleTree storage tree = merkleTrees[merkleIndex];
        return IPriceGate(tree.priceGateAddress).getCost(tree.priceIndex);
    }

    
    
    
    
    
    
    function isEligible(uint merkleIndex, address recipient, bytes32[] calldata proof) public view returns (bool) {
        MerkleTree storage tree = merkleTrees[merkleIndex];
        return IEligibility(tree.eligibilityAddress).isEligible(tree.eligibilityIndex, recipient, proof);
    }

    
    
    
    
    
    
    function verifyMetadata(bytes32 root, uint tokenId, string calldata uri, bytes32[] calldata proof) public pure returns (bool) {
        bytes32 leaf = keccak256(abi.encode(tokenId, uri));
        return root.verifyProof(leaf, proof);
    }

}