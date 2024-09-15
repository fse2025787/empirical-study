
pragma solidity ^0.4.13;


contract Emoji {
    /* Public variables of the token */
    string public name;
    string public standard = 'Token 0.1';
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

   

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function Emoji () {
        totalSupply = 600600600600600600600600600;                        // Update total supply
        name = "Emoji";                                   // Set the name for display purposes
        symbol = ":)";                               // Set the symbol for display purposes
        decimals = 3;                            // Amount of decimals for display purposes
        balanceOf[msg.sender] = totalSupply;              // Give the creator all initial tokens
    }

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] > _value);                // Check if the sender has enough
        require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(_from, _to, _value);
    }

    
    
    
    function transfer(address _to, uint256 _value) {
        _transfer(msg.sender, _to, _value);
    }

    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require (_value < allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    
    
    
    function approve(address _spender, uint256 _value)
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

}