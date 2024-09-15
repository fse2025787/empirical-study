// SPDX-License-Identifier: MIT

//
pragma solidity ^0.8.9;

interface TheNahikosGameModule {
    function claim(
        address to,
        uint256 typeId,
        bytes memory signature
    ) external payable;
}




contract NahikosGameModuleMultipleClaim {
    address public immutable nahikosGameModuleAddr;

    
    
    constructor(address nahikosGameModuleAddr_) {
        nahikosGameModuleAddr = nahikosGameModuleAddr_;
    }

    function claimBatch(
        address to,
        uint256[] memory typeIds,
        bytes[] memory signatures
    ) public {
        TheNahikosGameModule module = TheNahikosGameModule(
            nahikosGameModuleAddr
        );
        require(typeIds.length == signatures.length, '!LENGTH_MISMATCH!');
        for (uint256 i; i < typeIds.length; i++) {
            module.claim(to, typeIds[i], signatures[i]);
        }
    }
}