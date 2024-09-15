
/*
	IOB ERC20 token by IOB llc.
	IOB token is a Security Token. 
	The token holders are qualified to receive dividends from time to time when the dividend distributions are declared by the management.
	
	As we're exploring the "Same Token, Multiple Offerings and Listings," Token Contract may be updated in the future to meet different local requirements by various jurisdictions and exchanges.
*/

pragma solidity 0.4.23;

contract Token {
    /// total amount of tokens
    uint256 public totalSupply;

    
    
    function balanceOf(address _owner) public view returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) public returns (bool success);

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) public returns (bool success);

    
    
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value); 
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_value == 0 || allowed[msg.sender][_spender] == 0);
		allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}


contract HumanStandardToken is StandardToken {

    /* Public variables of the token */

    string public name;                   //Token Name is "IOB Token"
    uint8 public decimals;                //Decimals is 18
    string public symbol;                 //Token symbol is "IOB"
    string public version = "H0.1";       //human 0.1 standard. Just an arbitrary versioning scheme.

    constructor (
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) public {
        balances[msg.sender] = _initialAmount;               // Initial Amount = 1,000,000,000 * (10 ** uint256(decimals))
        totalSupply = _initialAmount;                        // Total supply = 1,000,000,000 * (10 ** uint256(decimals))
        name = _tokenName;                                   // Set the name to "IOB Token"
        decimals = _decimalUnits;                            // Amount of decimals for display purposes，set to 18
        symbol = _tokenSymbol;                               // Set the symbol for display purposes,set to "IOB"
    }

}