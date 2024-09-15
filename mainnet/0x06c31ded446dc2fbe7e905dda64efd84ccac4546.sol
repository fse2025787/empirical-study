// SPDX-License-Identifier: GPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2021-12-23
*/

// 
pragma solidity ^0.8.4;

/// ============ Libraries ============



library MerkleProof {
  
  function verify(
    bytes32[] memory proof,
    bytes32 root,
    bytes32 leaf
  ) internal pure returns (bool) {
    return processProof(proof, leaf) == root;
  }

  
  function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
    bytes32 computedHash = leaf;
    for (uint256 i = 0; i < proof.length; i++) {
      bytes32 proofElement = proof[i];
      if (computedHash <= proofElement) {
        // Hash(current computed hash + current element of the proof)
        computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
      } else {
        // Hash(current element of the proof + current computed hash)
        computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
      }
    }
    return computedHash;
  }
}

/// ============ Interfaces ============

interface IERC721 {
  
  function transferFrom(address from, address to, uint256 tokenId) external;
}

contract SantaSwapExchange {

  /// ============ Structs ============

  
  struct SantaNFT {
    
    address nftContract;
    
    uint256 tokenId;
  }

  /// ============ Immutable storage ============

  
  uint256 immutable public RECLAIM_OPEN;

  /// ============ Mutable storage ============

  
  address public owner;
  
  
  bytes32 public merkle;
  
  
  mapping(address => uint256) public nftCount;
  
  mapping(address => SantaNFT[]) public nfts;

  // ============ Errors ============

  
  error NotOwner();
  
  error NotClaimable();

  /// ============ Constructor ============

  constructor() {
    // Update contract owner
    owner = msg.sender;
    // Allow reclaiming 7 days after depositing
    RECLAIM_OPEN = block.timestamp + 604_800;
  }

  
  
  
  
  
  function _leaf(
    address giftee, 
    address santa, 
    uint256 santaIndex
  ) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(giftee, santa, santaIndex));
  }

  
  
  
  
  function _verify(
    bytes32 leaf,
    bytes32[] calldata proof
  ) internal view returns (bool) {
    return MerkleProof.verify(proof, merkle, leaf);
  }

  
  
  
  function santaDepositNFT(address nftContract, uint256 tokenId) external {
    // Transfer NFT to contract
    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
    // Mark as deposited by santa
    nftCount[msg.sender]++;
    nfts[msg.sender].push(SantaNFT(nftContract, tokenId));
  }

  
  
  
  
  function gifteeClaimNFT(
    address santa,
    uint256 santaIndex,
    bytes32[] calldata proof
  ) external {
    // Require merkle to be set
    if (merkle == 0) revert NotClaimable();
    // Require giftee to be claiming correct santa NFT
    if (!_verify(_leaf(msg.sender, santa, santaIndex), proof)) revert NotClaimable();

    // Collect NFT
    SantaNFT memory nft = nfts[santa][santaIndex];
    // Transfer NFT
    IERC721(nft.nftContract).transferFrom(address(this), msg.sender, nft.tokenId);
  }

  
  
  function santaReclaimNFT(uint256 index) external {
    // Require reclaim period to be active
    if (block.timestamp < RECLAIM_OPEN) revert NotClaimable();
    // Require provided index to be in range of owned NFTs
    if (index + 1 > nfts[msg.sender].length) revert NotClaimable();

    // Collect NFT
    SantaNFT memory nft = nfts[msg.sender][index];
    // Transfer unclaimed NFT
    IERC721(nft.nftContract).transferFrom(address(this), msg.sender, nft.tokenId);
  }

  
  
  
  
  function adminWithdrawNFT(
    address nftContract,
    uint256 tokenId,
    address recipient
  ) external {
    // Require caller to be owner
    if (msg.sender != owner) revert NotOwner();

    IERC721(nftContract).transferFrom(
      // From this contract
      address(this),
      // To provided recipient
      recipient,
      // Transfer specified NFT tokenId
      tokenId
    );
  }

  
  
  
  
  
  function adminWithdrawNFTBulk(
    address[] calldata contracts,
    uint256[] calldata tokenIds,
    address[] calldata recipients
  ) external {
    // Require caller to be owner
    if (msg.sender != owner) revert NotOwner();

    // For each provided contract
    for (uint256 i = 0; i < contracts.length; i++) {
      IERC721(contracts[i]).transferFrom(
        // From contract
        address(this),
        // To provided recipient
        recipients[i],
        // Transfer specified NFT tokenId
        tokenIds[i]
      );
    }
  }

  
  
  function adminUpdateMerkle(bytes32 merkleRoot) external {
    // Require caller to be owner
    if (msg.sender != owner) revert NotOwner();
    // Update merkle root
    merkle = merkleRoot;
  }

  
  
  function adminUpdateOwner(address newOwner) external {
    // Require caller to be owner
    if (msg.sender != owner) revert NotOwner();
    // Update to new owner
    owner = newOwner;
  }
}