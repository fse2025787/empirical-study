// SPDX-License-Identifier: MIT

//
pragma solidity 0.8.16;



interface IWallet {
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
    }

    struct Proposition {
        
        uint256 endsAt;
        
        Transaction tx;
        
        /// For example in EIP1271 `isValidSignature` function.
        /// Note: Pass zero hash (0x0) if you don't need this.
        bytes32 relevantHash;
    }

    
    
    
    
    event ExecutedTransaction(
        bytes32 indexed hash,
        uint256 value,
        bool successful
    );

    
    
    
    
    
    
    function enactProposition(
        Proposition memory proposition,
        bytes[] memory signatures
    ) external returns (bool successful, bytes memory returnData);

    
    function isPropositionEnacted(bytes32 propositionHash)
        external
        view
        returns (bool);

    
    function maxAllowedTransfer() external view returns (uint256);
}

//
pragma solidity 0.8.16;






/// This needs to be encoded (you can use `JoinDataCodec`) and be passed to `join`
struct JoinData {
    address member;
    IWallet.Proposition proposition;
    bytes[] signatures;
    
    uint256 ownershipUnits;
}


contract JoinDataCodec {
    function encode(JoinData memory joinData)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(joinData);
    }

    function decode(bytes memory data) external pure returns (JoinData memory) {
        return abi.decode(data, (JoinData));
    }
}