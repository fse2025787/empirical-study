// SPDX-License-Identifier: AGPL-3.0-only

/**
 *Submitted for verification at Etherscan.io on 2021-12-01
*/

// Verified using https://dapp.tools

// hevm: flattened sources of src/ImmutabilityButWorse.sol
// 
pragma solidity =0.8.10;

////// src/ImmutabilityButWorse.sol
/* pragma solidity 0.8.10; */




/// governance tokens to that votes no on every proposal.

contract ImmutabilityButWorse {
    string public constant WHY_I_VOTED_NO = "no.";

    event VotedNo(Governance indexed gov, uint256 id);

    function voteNo(Governance gov, uint256 id) external {
        gov.castVoteWithReason(id, 0, WHY_I_VOTED_NO);

        emit VotedNo(gov, id);
    }
}

interface Governance {
    function castVoteWithReason(
        uint256 proposalId,
        uint8 support,
        string memory reason
    ) external;
}