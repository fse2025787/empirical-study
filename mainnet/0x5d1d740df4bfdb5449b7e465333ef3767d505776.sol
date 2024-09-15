// SPDX-License-Identifier: UNLICENSED

/**
 *Submitted for verification at Etherscan.io on 2021-06-09
*/

/*
aqoleg.com

These are shares of the aqoleg company.
They are used to raise money and estimate the value of the company.

The contract contains the erc20 token aqo with the built-in exchange.
The token is created when buying and destroyed when selling.
Just send eth to this address for purchase.

Each aqo token can be sold at any time using this contract.
The token price depends on the total number of tokens.
The larger the total supply, the higher the price.
The minimum guaranteed price of the token is 1 eth/aqo, the maximum price is unlimited.

t - total supply, aqo, 0 <= t < 100
p - price, eth/aqo, p >= 1
p = 10000 / (100 - t)^2

p |
  |                                             /
  |                                            -
  |                                          _-
  |                                        _-
  |                                     __-
  |                                 __--
  |                            ___--
  |                      ___---
3 |               ____---
  |      _____----
1 |------
0 |________________________________________________________
  0                    40                            100  t

b - contract balance, eth, b >= 0
b = integral p(t) dt, total balance is the sum of the prices of all tokens
b = 10000 / (100 - t) - 100
t = 100 - 10000 / (b + 100)

b |
  |                                   /
  |                                  -
  |                                 -
  |                               _-
  |                             _-
  |                          __-
  |                      __--
  |                  __--
  |              __--
  |         ___--
5 |   ___---
0 |---_____________________________________________________
  0    5                                             100  t

The token strictly complies with the erc20 standard.

The contract was developed with a focus on low gas consumption.
Each transaction uses 20000 - 70000 gas.

If you find any tokens on this contract address,
it would be great if you grab them (with the 'clean' function) and use them.

All users are equal, including the creator.

Enjoy!

App - aqoleg.com/aqo
*/

// 
pragma solidity 0.8.4;





contract Aqo {
    
    
    
    uint256 public totalSupply;

    
    
    mapping(address => uint256) public balanceOf;

    
    
    
    mapping(address => mapping(address => uint256)) public allowance;

    
    uint8 public constant decimals = 18;

    
    string public constant name = "aqoleg";

    
    string public constant symbol = "aqo";

    
    
    
    
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    
    
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    
    
    event Price(uint256 _price);

    constructor() {
        emit Price(price());
    }

    
    fallback () external payable {
        buy();
    }

    
    receive () external payable {
        buy();
    }

    
    
    function price() public view returns (uint256) {
        return 1e58 / (1e20 - totalSupply) ** 2;
    }

    
    
    function buy() public payable returns (uint256) {
        uint256 newTotalSupply = 1e20 - 1e40 / (address(this).balance + 1e20);
        uint256 tokens = newTotalSupply - totalSupply;
        totalSupply = newTotalSupply;
        balanceOf[msg.sender] += tokens;
        emit Transfer(address(0), msg.sender, tokens);
        emit Price(price());
        return tokens;
    }

    
    
    
    function sell(uint256 _tokens) external returns (uint256) {
        require(balanceOf[msg.sender] >= _tokens, "incufficient token balance");
        totalSupply -= _tokens;
        balanceOf[msg.sender] -= _tokens;
        uint256 value = address(this).balance - (1e40 / (1e20 - totalSupply) - 1e20);
        payable(msg.sender).transfer(value);
        emit Transfer(msg.sender, address(0), _tokens);
        emit Price(price());
        return value;
    }

    
    
    
    
    
    function transfer(address _to, uint256 _value) public returns (bool) {
        return _transfer(msg.sender, _to, _value);
    }

    
    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(allowance[_from][msg.sender] >= _value, "not allowed");
        allowance[_from][msg.sender] -= _value;
        return _transfer(_from, _to, _value);
    }

    function _transfer(address _from, address _to, uint256 _value) private returns (bool) {
        require(_to != address(0), "zero recipient");
        require(balanceOf[_from] >= _value, "insufficient token balance");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    
    
    
    
    
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(0), "zero spender");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    
    
    
    function clean(address _token, uint256 _value) external {
        Erc20(_token).transfer(msg.sender, _value);
    }
}



interface Erc20 {
    function transfer(address _to, uint256 _value) external;
}