// SPDX-License-Identifier: GPL-3.0

/**
 *Submitted for verification at Etherscan.io on 2021-03-11
*/

// 
pragma solidity >=0.7.0 <0.8.0;

contract ERC20Interface {
    
    
    function totalSupply() public virtual view returns (uint256 supply) {}

    
    
    function balanceOf(address tokenOwner) public virtual view returns (uint256 balance) {}

    
    
    
    
    function transfer(address _to, uint256 _value) public virtual returns (bool success) {}

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool success) {}

    
    
    
    
    function approve(address _spender, uint256 _value) public virtual returns (bool success) {}

    
    
    
    function allowance(address tokenOwner, address _spender) public virtual view returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is ERC20Interface {
    uint256 public _totalSupply;
    
    mapping (address => uint256) balances;
    //[tokenOwner][spender] = value
    //tokenOwner allows the spender to spend *value* of tokenOwner money
    mapping (address => mapping (address => uint256)) allowed;
    
    function transfer(address _to, uint256 _value) public override returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address tokenOwner) public view override returns (uint256 balance) {
        return balances[tokenOwner];
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address tokenOwner, address _spender) public view override returns (uint256 remaining) {
      return allowed[tokenOwner][_spender];
    }
    
    function totalSupply() public view override returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

}

contract MobiToken is StandardToken {

    
    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H0.1';

    constructor() {
        _totalSupply = 410000000;                        // Update total supply
        balances[msg.sender] = _totalSupply;          // Give the creator all initial tokens
        name = "Mobi Coin";                                   // Set the name for display purposes
        decimals = 2;                            // Amount of decimals for display purposes
        symbol = "MOBI";                               // Set the symbol for display purposes
    }
    
}