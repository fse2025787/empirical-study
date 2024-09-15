// SPDX-License-Identifier: GPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2021-10-05
*/

// 

pragma solidity 0.8.9;

contract TokenFinder {
    address public lexDAO;
    
    mapping(string => address) public tokens;

    modifier onlyLexDAO {
        require(msg.sender == lexDAO, "not LexDAO");
        _;
    }

    constructor() {
        lexDAO = tx.origin;
    }

    function addToken(string calldata symbol_, address tokenAddress_) external onlyLexDAO {
        tokens[symbol_] = tokenAddress_; 
    }

    function getToken(string calldata symbol_) external view returns (address tokenAddress) {
        require(tokens[symbol_] != address(0), "this token does not exist, try entering in all lowercase");
        tokenAddress = tokens[symbol_];
    }
    
    
    
    function updateLexDAO(address _lexDAO) external onlyLexDAO {
        lexDAO = _lexDAO;
    }
}