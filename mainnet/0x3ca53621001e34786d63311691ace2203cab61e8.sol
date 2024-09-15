
pragma solidity ^0.4.18;

/*
  Copyright 2017, Anton Egorov (Mothership Foundation)
  Copyright 2017, An Hoang Phan Ngo (Mothership Foundation)

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

// File: contracts/interface/Controlled.sol

contract Controlled {
  
  ///  a function with this modifier
  modifier onlyController {
    require(msg.sender == controller);
    _;
  }

  address public controller;

  function Controlled() public { controller = msg.sender; }

  
  
  function changeController(address _newController) public onlyController {
    controller = _newController;
  }
}

// File: contracts/interface/Burnable.sol


///  tokens. The burner address could be changed by himself.
contract Burnable is Controlled {
  address public burner;

  
  /// as well as by a burner. But burner could use the onlt his/her address as
  /// a target.
  modifier onlyControllerOrBurner(address target) {
    assert(msg.sender == controller || (msg.sender == burner && msg.sender == target));
    _;
  }

  modifier onlyBurner {
    assert(msg.sender == burner);
    _;
  }

  /// Contract creator become a burner by default
  function Burnable() public { burner = msg.sender;}

  
  
  function changeBurner(address _newBurner) public onlyBurner {
    burner = _newBurner;
  }
}

// File: contracts/interface/ERC20Token.sol

// @dev Abstract contract for the full ERC 20 Token standard
//  https://github.com/ethereum/EIPs/issues/20
contract ERC20Token {
  /// total amount of tokens
  function totalSupply() public view returns (uint256 balance);

  
  
  function balanceOf(address _owner) public view returns (uint256 balance);

  
  
  
  
  function transfer(address _to, uint256 _value) public returns (bool success);

  
  
  
  
  
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

  
  
  
  
  function approve(address _spender, uint256 _value) public returns (bool success);

  
  
  
  function allowance(address _owner, address _spender) public view returns (uint256 remaining);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// File: contracts/interface/MiniMeTokenI.sol


///  will reduce contract sise and gas cost
contract MiniMeTokenI is ERC20Token, Burnable {

  string public name;                //The Token's name: e.g. DigixDAO Tokens
  uint8 public decimals;             //Number of decimals of the smallest unit
  string public symbol;              //An identifier: e.g. REP
  string public version = "MMT_0.1"; //An arbitrary versioning scheme

///////////////////
// ERC20 Methods
///////////////////

  
  ///  its behalf, and then a function is triggered in the contract that is
  ///  being approved, `_spender`. This allows users to use their tokens to
  ///  interact with contracts in one function call instead of two
  
  
  
  function approveAndCall(
    address _spender,
    uint256 _amount,
    bytes _extraData) public returns (bool success);

////////////////
// Query balance and totalSupply in History
////////////////

  
  
  
  
  function balanceOfAt(
    address _owner,
    uint _blockNumber) public constant returns (uint);

  
  
  
  function totalSupplyAt(uint _blockNumber) public constant returns(uint);

////////////////
// Generate and destroy tokens
////////////////

  
  
  
  
  function mintTokens(address _owner, uint _amount) public returns (bool);


  
  
  
  
  function destroyTokens(address _owner, uint _amount) public returns (bool);

/////////////////
// Finalize 
////////////////
  function finalize() public;

//////////
// Safety Methods
//////////

  
  ///  sent tokens to this contract.
  
  ///  set to 0 in case you want to extract ether.
  function claimTokens(address _token) public;

////////////////
// Events
////////////////

  event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
}

// File: contracts/interface/TokenController.sol


contract TokenController {
    
    
    
  function proxyMintTokens(
    address _owner, 
    uint _amount,
    bytes32 _paidTxID) public returns(bool);

    
    ///  controller to react if desired
    
    
    
    
  function onTransfer(address _from, address _to, uint _amount) public returns(bool);

    
    ///  controller to react if desired
    
    
    
    
  function onApprove(address _owner, address _spender, uint _amount) public
    returns(bool);
}

// File: contracts/Distribution.sol

contract Distribution is Controlled, TokenController {

  /// Record tx details for each minting operation
  struct Transaction {
    uint256 amount;
    bytes32 paidTxID;
  }

  MiniMeTokenI public token;

  address public reserveWallet; // Team's wallet address

  uint256 public totalSupplyCap; // Total Token supply to be generated
  uint256 public totalReserve; // A number of tokens to reserve for the team/bonuses

  uint256 public finalizedBlock;

  /// Record all transaction details for all minting operations
  mapping (address => Transaction[]) allTransactions;

  
  ///  the contribution finalizes.
  
  
  
  function Distribution(
    address _token,
    address _reserveWallet,
    uint256 _totalSupplyCap,
    uint256 _totalReserve
  ) public onlyController
  {
    // Initialize only once
    assert(address(token) == 0x0);

    token = MiniMeTokenI(_token);
    reserveWallet = _reserveWallet;

    require(_totalReserve < _totalSupplyCap);
    totalSupplyCap = _totalSupplyCap;
    totalReserve = _totalReserve;

    assert(token.totalSupply() == 0);
    assert(token.decimals() == 18); // Same amount of decimals as ETH
  }

  function distributionCap() public constant returns (uint256) {
    return totalSupplyCap - totalReserve;
  }

  
  function finalize() public onlyController {
    assert(token.totalSupply() >= distributionCap());

    // Mint reserve pool
    doMint(reserveWallet, totalReserve);

    finalizedBlock = getBlockNumber();
    token.finalize(); // Token becomes unmintable after this

    // Distribution controller becomes a Token controller
    token.changeController(controller);

    Finalized();
  }

//////////
// TokenController functions
//////////

  function proxyMintTokens(
    address _th,
    uint256 _amount,
    bytes32 _paidTxID
  ) public onlyController returns (bool)
  {
    require(_th != 0x0);

    require(_amount + token.totalSupply() <= distributionCap());

    doMint(_th, _amount);
    addTransaction(
      allTransactions[_th],
      _amount,
      _paidTxID);

    Purchase(
      _th,
      _amount,
      _paidTxID);

    return true;
  }

  function onTransfer(address, address, uint256) public returns (bool) {
    return false;
  }

  function onApprove(address, address, uint256) public returns (bool) {
    return false;
  }

  //////////
  // Safety Methods
  //////////

  
  ///  sent tokens to this contract.
  
  ///  set to 0 in case you want to extract ether.
  function claimTokens(address _token) public onlyController {
    if (token.controller() == address(this)) {
      token.claimTokens(_token);
    }
    if (_token == 0x0) {
      controller.transfer(this.balance);
      return;
    }

    ERC20Token otherToken = ERC20Token(_token);
    uint256 balance = otherToken.balanceOf(this);
    otherToken.transfer(controller, balance);
    ClaimedTokens(_token, controller, balance);
  }

  //////////////////////////////////
  // Minting tokens and oraclization
  //////////////////////////////////

  /// Total transaction count belong to an address
  function totalTransactionCount(address _owner) public constant returns(uint) {
    return allTransactions[_owner].length;
  }

  /// Query a transaction details by address and its index in transactions array
  function getTransactionAtIndex(address _owner, uint index) public constant returns(
    uint256 _amount,
    bytes32 _paidTxID
  ) {
    _amount = allTransactions[_owner][index].amount;
    _paidTxID = allTransactions[_owner][index].paidTxID;
  }

  /// Save transaction details belong to an address
  
  
  
  function addTransaction(
    Transaction[] storage transactions,
    uint _amount,
    bytes32 _paidTxID
    ) internal
  {
    Transaction storage newTx = transactions[transactions.length++];
    newTx.amount = _amount;
    newTx.paidTxID = _paidTxID;
  }

  function doMint(address _th, uint256 _amount) internal {
    assert(token.mintTokens(_th, _amount));
  }

//////////
// Testing specific methods
//////////

  
  function getBlockNumber() internal constant returns (uint256) { return block.number; }


////////////////
// Events
////////////////
  event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
  event Purchase(
    address indexed _owner,
    uint256 _amount,
    bytes32 _paidTxID
  );
  event Finalized();
}