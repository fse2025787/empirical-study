
/*
  Copyright 2017 Delphy Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

//   /$$$$$$$            /$$           /$$
//  | $$__  $$          | $$          | $$
//  | $$  \ $$  /$$$$$$ | $$  /$$$$$$ | $$$$$$$  /$$   /$$
//  | $$  | $$ /$$__  $$| $$ /$$__  $$| $$__  $$| $$  | $$
//  | $$  | $$| $$$$$$$$| $$| $$  \ $$| $$  \ $$| $$  | $$
//  | $$  | $$| $$_____/| $$| $$  | $$| $$  | $$| $$  | $$
//  | $$$$$$$/|  $$$$$$$| $$| $$$$$$$/| $$  | $$|  $$$$$$$
//  |_______/  \_______/|__/| $$____/ |__/  |__/ \____  $$
//                          | $$                 /$$  | $$
//                          | $$                |  $$$$$$/
//                          |__/                 \______/

pragma solidity ^0.4.11;



contract Token {

    /*
     *  Events
     */
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    /*
     *  Public functions
     */
    
    
    
    
    function transfer(address _to, uint _value) public returns (bool);

    
    
    
    
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool);

    
    
    
    
    function approve(address _spender, uint _value) public returns (bool);

    
    
    function balanceOf(address _owner) public constant returns (uint);

    
    
    
    function allowance(address _owner, address _spender) public constant returns (uint);

    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;
}

library Math {
    
    
    
    
    function safeToAdd(uint a, uint b)
        public
        constant
        returns (bool)
    {
        return a + b >= a;
    }

    
    
    
    
    function safeToSub(uint a, uint b)
        public
        constant
        returns (bool)
    {
        return a >= b;
    }

    
    
    
    
    function safeToMul(uint a, uint b)
        public
        constant
        returns (bool)
    {
        return b == 0 || a * b / b == a;
    }

    
    
    
    
    function add(uint a, uint b)
        public
        constant
        returns (uint)
    {
        require(safeToAdd(a, b));
        return a + b;
    }

    
    
    
    
    function sub(uint a, uint b)
        public
        constant
        returns (uint)
    {
        require(safeToSub(a, b));
        return a - b;
    }

    
    
    
    
    function mul(uint a, uint b)
        public
        constant
        returns (uint)
    {
        require(safeToMul(a, b));
        return a * b;
    }
}



contract StandardToken is Token {
    using Math for *;

    /*
     *  Storage
     */
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowances;

    /*
     *  Public functions
     */
    
    
    
    
    function transfer(address to, uint value)
        public
        returns (bool)
    {
        if (!balances[msg.sender].safeToSub(value)
            || !balances[to].safeToAdd(value))
            return false;
        balances[msg.sender] -= value;
        balances[to] += value;
        Transfer(msg.sender, to, value);
        return true;
    }

    
    
    
    
    
    function transferFrom(address from, address to, uint value)
        public
        returns (bool)
    {
        if (   !balances[from].safeToSub(value)
            || !allowances[from][msg.sender].safeToSub(value)
            || !balances[to].safeToAdd(value))
            return false;
        balances[from] -= value;
        allowances[from][msg.sender] -= value;
        balances[to] += value;
        Transfer(from, to, value);
        return true;
    }

    
    
    
    
    function approve(address spender, uint value)
        public
        returns (bool)
    {
        allowances[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        return true;
    }

    
    
    
    
    function allowance(address owner, address spender)
        public
        constant
        returns (uint)
    {
        return allowances[owner][spender];
    }

    
    
    
    function balanceOf(address owner)
        public
        constant
        returns (uint)
    {
        return balances[owner];
    }
}


/// For Delphy ICO details: https://delphy.org/index.html#ICO
/// For Delphy Project: https://delphy.org

contract DelphyToken is StandardToken {
    /*
     *  Constants
     */

    string constant public name = "Delphy Token";
    string constant public symbol = "DPY";
    uint8 constant public decimals = 18;

    /// Delphy token total supply
    uint public constant TOTAL_TOKENS = 100000000 * 10**18; // 1e

    /*
     *  Public functions
     */

    
    
    
    function DelphyToken(address[] owners, uint[] tokens)
        public
    {
        totalSupply = 0;

        for (uint i=0; i<owners.length; i++) {
            require (owners[i] != 0);

            balances[owners[i]] += tokens[i];
            Transfer(0, owners[i], tokens[i]);
            totalSupply += tokens[i];
        }

        require (totalSupply == TOTAL_TOKENS);
    }
}