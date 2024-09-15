
pragma solidity ^0.4.18;

/*
  Copyright 2017, Anton Egorov (Mothership Foundation)
  Copyright 2017, An Hoang Phan Ngo (Mothership Foundation)
  Copyright 2017, Joel Mislav Kunst (Mothership Fundation)
  Copyright 2016, Jordi Baylina

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

// File: contracts/interface/ApproveAndCallFallBack.sol

contract ApproveAndCallFallBack {
  function receiveApproval(
    address _from,
    uint256 _amount,
    address _token,
    bytes _data) public;
}

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

// File: contracts/MiniMeToken.sol



///  that deploys the contract, so usually this token will be deployed by a
///  token controller contract, which Giveth will call a "Campaign"
contract MiniMeToken is MiniMeTokenI {

  
  ///  given value, the block number attached is the one that last changed the
  ///  value
  struct Checkpoint {

    // `fromBlock` is the block number that the value was generated from
    uint128 fromBlock;

    // `value` is the amount of tokens at a specific block number
    uint128 value;
  }

  // `parentToken` is the Token address that was cloned to produce this token;
  //  it will be 0x0 for a token that was not cloned
  MiniMeToken public parentToken;

  // `parentSnapShotBlock` is the block number from the Parent Token that was
  //  used to determine the initial distribution of the Clone Token
  uint public parentSnapShotBlock;

  // `creationBlock` is the block number that the Clone Token was created
  uint public creationBlock;

  // `balances` is the map that tracks the balance of each address, in this
  //  contract when the balance changes the block number that the change
  //  occurred is also included in the map
  mapping (address => Checkpoint[]) balances;

  // `allowed` tracks any extra transfer rights as in all ERC20 tokens
  mapping (address => mapping (address => uint256)) allowed;

  // Tracks the history of the `totalSupply` of the token
  Checkpoint[] totalSupplyHistory;


  bool public finalized;

  modifier notFinalized() {
    require(!finalized);
    _;
  }

////////////////
// Constructor
////////////////

  
  
  ///  new token
  
  ///  determine the initial distribution of the clone token, set to 0 if it
  ///  is a new token
  
  
  
  function MiniMeToken(
    address _parentToken,
    uint _parentSnapShotBlock,
    string _tokenName,
    uint8 _decimalUnits,
    string _tokenSymbol
  ) public
  {
    name = _tokenName;                                 // Set the name
    decimals = _decimalUnits;                          // Set the decimals
    symbol = _tokenSymbol;                             // Set the symbol
    parentToken = MiniMeToken(_parentToken);
    parentSnapShotBlock = _parentSnapShotBlock;
    creationBlock = block.number;
  }

///////////////////
// ERC20 Methods
///////////////////

  
  
  
  
  function transfer(address _to, uint256 _amount) public returns (bool success) {
    return doTransfer(msg.sender, _to, _amount);
  }

  
  ///  is approved by `_from`
  
  
  
  
  function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
    // The standard ERC 20 transferFrom functionality
    require(allowed[_from][msg.sender] >= _amount);
    allowed[_from][msg.sender] -= _amount;

    return doTransfer(_from, _to, _amount);
  }

  
  ///  only be called by other functions in this contract.
  
  
  
  
  function doTransfer(address _from, address _to, uint _amount) internal returns(bool) {
    if (_amount == 0) {
      return true;
    }

    require(parentSnapShotBlock < block.number);

    // Do not allow transfer to 0x0 or the token contract itself
    require((_to != 0) && (_to != address(this)));

    // If the amount being transfered is more than the balance of the
    //  account the transfer returns false
    var previousBalanceFrom = balanceOfAt(_from, block.number);
    if (previousBalanceFrom < _amount) {
      return false;
    }

    // Alerts the token controller of the transfer
    // Check for transfer enable from controller
    if (isContract(controller)) {
      require(TokenController(controller).onTransfer(_from, _to, _amount));
    }

    // First update the balance array with the new value for the address
    //  sending the tokens
    updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

    // Then update the balance array with the new value for the address
    //  receiving the tokens
    var previousBalanceTo = balanceOfAt(_to, block.number);
    require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
    updateValueAtNow(balances[_to], previousBalanceTo + _amount);

    // An event to make the transfer easy to find on the blockchain
    Transfer(_from, _to, _amount);

    return true;
  }

  
  
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balanceOfAt(_owner, block.number);
  }

  
  ///  its behalf. This is a modified version of the ERC20 approve function
  ///  to be a little bit safer
  
  
  
  function approve(address _spender, uint256 _amount) public returns (bool success) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender,0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

    // Alerts the token controller of the approve function call
    if (isContract(controller)) {
      require(TokenController(controller).onApprove(msg.sender, _spender, _amount));
    }

    allowed[msg.sender][_spender] = _amount;
    Approval(msg.sender, _spender, _amount);
    return true;
  }

  
  
  
  
  ///  to spend
  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  
  ///  its behalf, and then a function is triggered in the contract that is
  ///  being approved, `_spender`. This allows users to use their tokens to
  ///  interact with contracts in one function call instead of two
  
  
  
  function approveAndCall(address _spender, uint256 _amount, bytes _extraData) public returns (bool success) {
    require(approve(_spender, _amount));

    ApproveAndCallFallBack(_spender).receiveApproval(
      msg.sender,
      _amount,
      this,
      _extraData
    );

    return true;
  }

  
  
  function totalSupply() public view returns (uint) {
    return totalSupplyAt(block.number);
  }

////////////////
// Query balance and totalSupply in History
////////////////

  
  
  
  
  function balanceOfAt(address _owner, uint _blockNumber) public view returns (uint) {

    // These next few lines are used when the balance of the token is
    //  requested before a check point was ever created for this token, it
    //  requires that the `parentToken.balanceOfAt` be queried at the
    //  genesis block for that token as this contains initial balance of
    //  this token
    if ((balances[_owner].length == 0) ||
        (balances[_owner][0].fromBlock > _blockNumber)) {
      if (address(parentToken) != 0) {
        return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
      } else {
        // Has no parent
        return 0;
      }

        // This will return the expected balance during normal situations
     } else {
      return getValueAt(balances[_owner], _blockNumber);
     }
  }

  
  
  
  function totalSupplyAt(uint _blockNumber) public view returns(uint) {

    // These next few lines are used when the totalSupply of the token is
    //  requested before a check point was ever created for this token, it
    //  requires that the `parentToken.totalSupplyAt` be queried at the
    //  genesis block for this token as that contains totalSupply of this
    //  token at this block number.
    if ((totalSupplyHistory.length == 0) ||
        (totalSupplyHistory[0].fromBlock > _blockNumber)) {
      if (address(parentToken) != 0) {
        return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
      } else {
        return 0;
      }

        // This will return the expected totalSupply during normal situations
     } else {
      return getValueAt(totalSupplyHistory, _blockNumber);
     }
  }

////////////////
// Mint and destroy tokens
////////////////

  
  
  
  
  function mintTokens(address _owner, uint _amount) public onlyController notFinalized returns (bool) {
    uint curTotalSupply = totalSupply();
    require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
    uint previousBalanceTo = balanceOf(_owner);
    require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
    updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
    updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
    Transfer(0, _owner, _amount);
    return true;
  }

  
  
  
  
  function destroyTokens(address _owner, uint _amount) public onlyControllerOrBurner(_owner) returns (bool) {
    uint curTotalSupply = totalSupply();
    require(curTotalSupply >= _amount);
    uint previousBalanceFrom = balanceOf(_owner);
    require(previousBalanceFrom >= _amount);
    updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
    updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
    Transfer(_owner, 0, _amount);
    return true;
  }

////////////////
// Internal helper functions to query and set a value in a snapshot array
////////////////

  
  
  
  
  function getValueAt(Checkpoint[] storage checkpoints, uint _block) internal view returns (uint) {
    if (checkpoints.length == 0)
      return 0;

    // Shortcut for the actual value
    if (_block >= checkpoints[checkpoints.length-1].fromBlock)
      return checkpoints[checkpoints.length-1].value;
    if (_block < checkpoints[0].fromBlock)
      return 0;

    // Binary search of the value in the array
    uint min = 0;
    uint max = checkpoints.length-1;
    while (max > min) {
      uint mid = (max + min + 1) / 2;
      if (checkpoints[mid].fromBlock<=_block) {
        min = mid;
      } else {
        max = mid-1;
      }
    }
    return checkpoints[min].value;
  }

  
  ///  `totalSupplyHistory`
  
  
  function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value) internal {
    if ((checkpoints.length == 0) ||
      (checkpoints[checkpoints.length - 1].fromBlock < block.number)) {
      Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
      newCheckPoint.fromBlock = uint128(block.number);
      newCheckPoint.value = uint128(_value);
    } else {
      Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
      oldCheckPoint.value = uint128(_value);
    }
  }

  
  
  
  function isContract(address _addr) internal view returns(bool) {
    uint size;
    if (_addr == 0)
      return false;
    assembly {
      size := extcodesize(_addr)
    }
    return size>0;
  }

  
  function min(uint a, uint b) pure internal returns (uint) {
    return a < b ? a : b;
  }

//////////
// Safety Methods
//////////

  
  ///  sent tokens to this contract.
  
  ///  set to 0 in case you want to extract ether.
  function claimTokens(address _token) public onlyController {
    if (_token == 0x0) {
      controller.transfer(this.balance);
      return;
    }

    ERC20Token otherToken = ERC20Token(_token);
    uint balance = otherToken.balanceOf(this);
    otherToken.transfer(controller, balance);
    ClaimedTokens(_token, controller, balance);
  }

  function finalize() public onlyController notFinalized {
    finalized = true;
  }

////////////////
// Events
////////////////

  event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
  event Transfer(address indexed _from, address indexed _to, uint256 _amount);
  event Approval(
    address indexed _owner,
    address indexed _spender,
    uint256 _amount
  );

}

// File: contracts/SEN.sol

contract SEN is MiniMeToken {
  function SEN() public MiniMeToken(
    0x0,                // no parent token
    0,                  // no snapshot block number from parent
    "Consensus Token",  // Token name
    18,                 // Decimals
    "SEN"              // Symbolh
  )
  {}
}