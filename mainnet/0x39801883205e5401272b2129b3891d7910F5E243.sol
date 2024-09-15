
pragma solidity ^0.8.6;

interface IRootChainManager {
    function exit(bytes calldata inputData) external;
}

contract AmunWethExit {
    IRootChainManager public immutable rootChainManager;

    constructor(address _rootChainManager) {
        rootChainManager = IRootChainManager(_rootChainManager);
    }

    
    
    
    function exit(
        bytes calldata inputDataWeth,
        bytes calldata inputDataAmunWeth
    ) external {
        rootChainManager.exit(inputDataWeth);
        rootChainManager.exit(inputDataAmunWeth);
    }
}

