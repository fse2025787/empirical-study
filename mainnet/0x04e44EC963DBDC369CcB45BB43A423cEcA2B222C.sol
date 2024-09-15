// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.0;



contract Events {
    event LogSubmitAction(
        Position position,
        address sourceDsaSender,
        string actionId,
        uint256 targetDsaId,
        uint256 targetChainId,
        bytes metadata
    );
}

// 
pragma solidity ^0.8.0;



contract Helpers {

    Interop public immutable interopContract;

    constructor(address interop) {
        interopContract = Interop(interop);
    }

    function _submitAction(
        Position memory position,
        string memory actionId,
        uint64 targetDsaId,
        uint256 targetChainId,
        bytes memory metadata
    ) internal {
        interopContract.submitAction(position, msg.sender, actionId, targetDsaId, targetChainId, metadata);
    }
}
// 
pragma solidity ^0.8.0;




contract InteropBetaResolver is Events, Helpers {
    constructor(address interop) Helpers(interop) {}

    function submitAction(
        Position memory position,
        string memory actionId,
        uint256 targetDsaId,
        uint256 targetChainId,
        bytes memory metadata
    ) external returns (string memory _eventName, bytes memory _eventParam) {
        _submitAction(
            position,
            actionId,
            uint64(targetDsaId),
            targetChainId,
            metadata
        );

        _eventName = "LogSourceMagic(Position,address,string,uint256,uint256,bytes)";
        _eventParam = abi.encode(position, msg.sender,actionId, targetDsaId, targetChainId, metadata);
    }
}

contract ConnectV2Interop is InteropBetaResolver {
    constructor(address interop) InteropBetaResolver(interop) {}

    string public constant name = "Interop-v1";
}

// 
pragma solidity ^0.8.0;

struct TokenInfo {
    address sourceToken;
    address targetToken;
    uint256 amount;
}
    
struct Position {
    TokenInfo[] supply;
    TokenInfo[] withdraw;
}

interface Interop {

    function submitAction(
        Position memory position,
        address sourceDsaSender,
        string memory actionId,
        uint64 targetDsaId,
        uint256 targetChainId,
        bytes memory metadata
    ) external ;
}