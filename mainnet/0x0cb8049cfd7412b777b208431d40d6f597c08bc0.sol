
/**
 *Submitted for verification at Etherscan.io on 2021-07-02
*/

// File: contracts/SafeMath.sol

pragma solidity ^0.4.6;


/**
 * Math operations with safety checks
 */
contract SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}
// File: contracts/AbstractToken.sol

pragma solidity ^0.4.6;

/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20


contract AbstractToken {
    // This is not an abstract function, because solc won't recognize generated getter functions for public variables as functions
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address owner) constant returns (uint256 balance);
    function transfer(address to, uint256 value) returns (bool success);
    function transferFrom(address from, address to, uint256 value) returns (bool success);
    function approve(address spender, uint256 value) returns (bool success);
    function allowance(address owner, address spender) constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Issuance(address indexed to, uint256 value);
}
// File: contracts/StandardToken.sol

pragma solidity ^0.4.2;


contract StandardToken is AbstractToken {

    /*
     *  Data structures
     */
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

    /*
     *  Read and write storage functions
     */
    
    
    
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    
    
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    
    
    
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
     * Read storage functions
     */
    
    
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

}
// File: contracts/ThisIsAPonziScheme.sol

pragma solidity ^0.4.6;



contract ThisIsAPonziSchemeToken is StandardToken, SafeMath {

    /*
     * Token meta data
     */
    string constant public name = "This Is a Ponzi Scheme";
    string constant public symbol = "PONZI";
    uint8 constant public decimals = 3;

    uint public buyPrice = 25 szabo;
    uint public sellPrice = 6250000000000 wei;
    uint public tierBudget = 100000;

    // Address of the founder of PSToken.
    address public founder = 0xdEE4Eb4942801DDb1c1621e70248F53aE6CD03fE;

    /*
     * Contract functions
     */
    function fund()
      public
      payable 
      returns (bool)
    {
      uint tokenCount = msg.value / buyPrice;
      if (tokenCount > tierBudget) {
        tokenCount = tierBudget;
      }
      
      uint investment = tokenCount * buyPrice;

      balances[msg.sender] += tokenCount;
      Issuance(msg.sender, tokenCount);
      totalSupply += tokenCount;
      tierBudget -= tokenCount;

      if (tierBudget <= 0) {
        tierBudget = 100000;
        buyPrice *= 2;
        sellPrice *= 2;
      }
      if (msg.value > investment) {
        msg.sender.transfer(msg.value - investment);
      }
      return true;
    }

    function withdraw(uint tokenCount)
      public
      returns (bool)
    {
      if (balances[msg.sender] >= tokenCount) {
        uint withdrawal = tokenCount * sellPrice;
        balances[msg.sender] -= tokenCount;
        totalSupply -= tokenCount;
        msg.sender.transfer(withdrawal);
        return true;
      } else {
        return false;
      }
    }

    
    function ThisIsAPonziSchemeToken()
    {   
        balances[founder] = 500000;
        totalSupply += 500000;
    }
}