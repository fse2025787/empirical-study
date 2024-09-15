
pragma solidity ^0.4.11;

/*
  Copyright 2017, Anton Egorov (Mothership Foundation)
  Copyright 2017, Klaus Hott (BlockchainLabs.nz)
  Copyright 2017, Jordi Baylina (Giveth)


  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

contract ERC20Token {
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
  function totalSupply() constant returns (uint256 balance);

  
  
  function balanceOf(address _owner) constant returns (uint256 balance);

  
  
  
  
  function transfer(address _to, uint256 _value) returns (bool success);

  
  
  
  
  
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

  
  
  
  
  function approve(address _spender, uint256 _value) returns (bool success);

  
  
  
  function allowance(address _owner, address _spender) constant returns (uint256 remaining);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Controlled {
  
  ///  a function with this modifier
  modifier onlyController { if (msg.sender != controller) throw; _; }

  address public controller;

  function Controlled() { controller = msg.sender;}

  
  
  function changeController(address _newController) onlyController {
    controller = _newController;
  }
}

contract Burnable is Controlled {
  
  ///  a function with this modifier, also the burner can call but also the
  /// target of the function must be the burner
  modifier onlyControllerOrBurner(address target) {
    assert(msg.sender == controller || (msg.sender == burner && msg.sender == target));
    _;
  }

  modifier onlyBurner {
    assert(msg.sender == burner);
    _;
  }
  address public burner;

  function Burnable() { burner = msg.sender;}

  
  
  function changeBurner(address _newBurner) onlyBurner {
    burner = _newBurner;
  }
}

contract MiniMeTokenI is ERC20Token, Burnable {

      string public name;                //The Token's name: e.g. DigixDAO Tokens
      uint8 public decimals;             //Number of decimals of the smallest unit
      string public symbol;              //An identifier: e.g. REP
      string public version = 'MMT_0.1'; //An arbitrary versioning scheme

///////////////////
// ERC20 Methods
///////////////////


    
    ///  its behalf, and then a function is triggered in the contract that is
    ///  being approved, `_spender`. This allows users to use their tokens to
    ///  interact with contracts in one function call instead of two
    
    
    
    function approveAndCall(
        address _spender,
        uint256 _amount,
        bytes _extraData
    ) returns (bool success);

////////////////
// Query balance and totalSupply in History
////////////////

    
    
    
    
    function balanceOfAt(
        address _owner,
        uint _blockNumber
    ) constant returns (uint);

    
    
    
    function totalSupplyAt(uint _blockNumber) constant returns(uint);

////////////////
// Clone Token Method
////////////////

    
    ///  this token at `_snapshotBlock`
    
    
    
    
    ///  copied to set the initial distribution of the new clone token;
    ///  if the block is zero than the actual block, the current block is used
    
    
    function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
    ) returns(address);

////////////////
// Generate and destroy tokens
////////////////

    
    
    
    
    function generateTokens(address _owner, uint _amount) returns (bool);


    
    
    
    
    function destroyTokens(address _owner, uint _amount) returns (bool);

////////////////
// Enable tokens transfers
////////////////

    
    
    function enableTransfers(bool _transfersEnabled);

//////////
// Safety Methods
//////////

    
    ///  sent tokens to this contract.
    
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token);

////////////////
// Events
////////////////

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
}

contract ReferalsTokenHolder is Controlled {
  MiniMeTokenI public msp;
  mapping (address => bool) been_spread;

  function ReferalsTokenHolder(address _msp) {
    msp = MiniMeTokenI(_msp);
  }

  function spread(address[] _addresses, uint256[] _amounts) public onlyController {
    require(_addresses.length == _amounts.length);

    for (uint256 i = 0; i < _addresses.length; i++) {
      address addr = _addresses[i];
      if (!been_spread[addr]) {
        uint256 amount = _amounts[i];
        assert(msp.transfer(addr, amount));
        been_spread[addr] = true;
      }
    }
  }

//////////
// Safety Methods
//////////

  
  ///  sent tokens to this contract.
  
  ///  set to 0 in case you want to extract ether.
  function claimTokens(address _token) onlyController {
    if (_token == 0x0) {
      controller.transfer(this.balance);
      return;
    }

    ERC20Token token = ERC20Token(_token);
    uint balance = token.balanceOf(this);
    token.transfer(controller, balance);
    ClaimedTokens(_token, controller, balance);
  }

  event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
}