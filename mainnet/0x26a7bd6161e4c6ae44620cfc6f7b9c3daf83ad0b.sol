// SPDX-License-Identifier: GPL-3.0

// 
pragma solidity 0.8.17;

// Interface for a gatekeeper contract used for private crowdfund instances.
interface IGateKeeper {
    
    
    
    
    
    function isAllowed(
        address participant,
        bytes12 id,
        bytes memory userData
    ) external view returns (bool);
}

// 
pragma solidity 0.8.17;



/**
 * @notice Compatible with both ER20s and ERC721s.
 */
interface Token {
    function balanceOf(address owner) external view returns (uint256);
}

/**
 * @notice a contract that implements an token gatekeeper
 */
contract TokenGateKeeper is IGateKeeper {
    // last gate id
    uint96 private _lastId;

    struct TokenGate {
        Token token;
        uint256 minimumBalance;
    }

    event TokenGateCreated(Token token, uint256 minimumBalance);

    
    mapping(uint96 => TokenGate) public gateInfo;

    
    function isAllowed(
        address participant,
        bytes12 id,
        bytes memory /* userData */
    ) external view returns (bool) {
        TokenGate memory _gate = gateInfo[uint96(id)];
        return _gate.token.balanceOf(participant) >= _gate.minimumBalance;
    }

    
    
    
    
    function createGate(Token token, uint256 minimumBalance)
        external
        returns (bytes12 id)
    {
        uint96 id_ = ++_lastId;
        id = bytes12(id_);
        gateInfo[id_].token = token;
        gateInfo[id_].minimumBalance = minimumBalance;
        emit TokenGateCreated(token, minimumBalance);
    }
}