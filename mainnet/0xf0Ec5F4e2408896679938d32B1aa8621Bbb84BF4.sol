// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.0;

interface ITokenRegistry {
    function owner() external view returns (address);
    function tokenFormulas(address) external view returns (address);
    function setTokenFormula(address token, address formula) external;
    function removeToken(address token) external;
    function changeOwner(address newOwner) external;
    event ChangedOwner(address indexed oldOwner, address indexed newOwner);
    event TokenAdded(address indexed token, address indexed formula);
    event TokenRemoved(address indexed token);
    event TokenFormulaUpdated(address indexed token, address indexed formula);
}
// 
pragma solidity ^0.8.0;



/**
 * @title TokenRegistry
 * @dev Registry of tokens that Eden supports as stake for voting power 
 * + their respective conversion formulas
 */
contract TokenRegistry is ITokenRegistry {

    
    address public override owner;

    
    mapping (address => address) public override tokenFormulas;

    
    modifier onlyOwner {
        require(msg.sender == owner, "not owner");
        _;
    }

    /**
     * @notice Construct a new token registry contract
     * @param _owner contract owner
     * @param _tokens initially supported tokens
     * @param _formulas formula contracts for initial tokens
     */
    constructor(
        address _owner, 
        address[] memory _tokens, 
        address[] memory _formulas
    ) {
        require(_tokens.length == _formulas.length, "TR::constructor: not same length");
        for (uint i = 0; i < _tokens.length; i++) {
            tokenFormulas[_tokens[i]] = _formulas[i];
            emit TokenFormulaUpdated(_tokens[i], _formulas[i]);
        }
        owner = _owner;
        emit ChangedOwner(address(0), owner);
    }

    /**
     * @notice Set conversion formula address for token
     * @param token token for formula
     * @param formula address of formula contract
     */
    function setTokenFormula(address token, address formula) external override onlyOwner {
        tokenFormulas[token] = formula;
        emit TokenFormulaUpdated(token, formula);
    }

    /**
     * @notice Remove conversion formula address for token
     * @param token token address to remove
     */
    function removeToken(address token) external override onlyOwner {
        tokenFormulas[token] = address(0);
        emit TokenRemoved(token);
    }

    /**
     * @notice Change owner of token registry contract
     * @param newOwner New owner address
     */
    function changeOwner(address newOwner) external override onlyOwner {
        emit ChangedOwner(owner, newOwner);
        owner = newOwner;
    }
}
