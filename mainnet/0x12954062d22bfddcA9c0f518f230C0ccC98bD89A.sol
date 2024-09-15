// SPDX-License-Identifier: UNLICENSED

/**
 *Submitted for verification at Etherscan.io on 2022-02-02
*/
// 
pragma solidity 0.8.12;

interface IERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
}

interface IERC1155 {
    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes calldata data) external;
}




contract MerkleValidator {
    
    error InvalidProof();

    
    error UnnecessaryProof();

    
    
    
    
    
    
    
    
    function matchERC721UsingCriteria(
        address from,
        address to,
        IERC721 token,
        uint256 tokenId,
        bytes32 root,
        bytes32[] calldata proof
    ) external returns (bool) {
    	// Proof verification is performed when there's a non-zero root.
    	if (root != bytes32(0)) {
    		_verifyProof(tokenId, root, proof);
    	} else if (proof.length != 0) {
    		// A root of zero should never have a proof.
    		revert UnnecessaryProof();
    	}

    	// Transfer the token.
        token.transferFrom(from, to, tokenId);

        return true;
    }

    
    
    
    
    
    
    
    
    function matchERC721WithSafeTransferUsingCriteria(
        address from,
        address to,
        IERC721 token,
        uint256 tokenId,
        bytes32 root,
        bytes32[] calldata proof
    ) external returns (bool) {
        // Proof verification is performed when there's a non-zero root.
        if (root != bytes32(0)) {
            _verifyProof(tokenId, root, proof);
        } else if (proof.length != 0) {
            // A root of zero should never have a proof.
            revert UnnecessaryProof();
        }

        // Transfer the token.
        token.safeTransferFrom(from, to, tokenId);

        return true;
    }

    
    
    
    
    
    
    
    
    
    function matchERC1155UsingCriteria(
        address from,
        address to,
        IERC1155 token,
        uint256 tokenId,
        uint256 amount,
        bytes32 root,
        bytes32[] calldata proof,
        bytes memory data
    ) external returns (bool) {
        // Proof verification is performed when there's a non-zero root.
        if (root != bytes32(0)) {
            _verifyProof(tokenId, root, proof);
        } else if (proof.length != 0) {
            // A root of zero should never have a proof.
            revert UnnecessaryProof();
        }

        // Transfer the token.
        token.safeTransferFrom(from, to, tokenId, amount, data);

        return true;
    }

    
    
    
    
    function _verifyProof(
        uint256 leaf,
        bytes32 root,
        bytes32[] memory proof
    ) private pure {
        bytes32 computedHash = bytes32(leaf);
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        if (computedHash != root) {
            revert InvalidProof();
        }
    }

    
    
    
    
    function _efficientHash(
        bytes32 a,
        bytes32 b
    ) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}