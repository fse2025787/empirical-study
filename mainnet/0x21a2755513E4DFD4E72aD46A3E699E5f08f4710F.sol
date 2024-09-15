// SPDX-License-Identifier: GPL-3.0

/**
 *Submitted for verification at Etherscan.io on 2021-06-24
*/

// 

pragma solidity ^0.8.0;

abstract contract Token {

    
    function totalSupply() external virtual returns (uint256 supply);

    
    
    function balanceOf(address _owner) virtual public returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) virtual public returns (bool success);

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) virtual public returns (bool success);

    
    
    
    function allowance(address _owner, address _spender) virtual public returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}



abstract contract StandardToken is Token {

    function transfer(address _to, uint256 _value) override public returns (bool success) {
        require(paused == false, "Contract Paused");
        
        // Assumes totalSupply can't be over max (2^256 - 1).
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) override public returns (bool success) {
        require(paused == false, "Contract Paused");
        
        // Assumes totalSupply can't be over max (2^256 - 1).
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) override public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) override public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) override public view returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    function setPaused(bool _paused) public {
        require(msg.sender == owner, "You are not the owner");
        paused = _paused;
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public override totalSupply;
    bool public paused;
    address public owner;
}


contract SMILECoin is StandardToken {
    
    /* Public variables of the token */
    mapping (address => uint256) public amount;
    string public name;
    string public symbol;
    uint256 public decimals;
    string public version;

    // if ETH is sent to this address, send it back.
    fallback() external payable { revert(); }
    receive() external payable { revert(); }
    
    constructor () {
        // Tokennomics
        name = "Smile Coin";
        decimals = 10;
        symbol = "SMILE";
        version = "1.0";
        
        owner = msg.sender;
        setPaused(false);
        
        // Mint 10,000,000,000 Tokens and assign them to the Smile Reserve Wallet
        totalSupply = 10000000000 * (10 ** uint256(decimals));
        balances[msg.sender] = totalSupply;
    }
}