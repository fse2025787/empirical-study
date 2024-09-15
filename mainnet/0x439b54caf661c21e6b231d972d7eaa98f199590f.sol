
pragma solidity ^0.4.21;

// File: contracts/external/Controlled.sol

contract Controlled {
    
    ///  a function with this modifier
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    function Controlled() public { controller = msg.sender;}

    
    
    function changeController(address _newController) public onlyController {
        controller = _newController;
    }
}

// File: contracts/external/TokenController.sol


contract TokenController {
    
    
    
    function proxyPayment(address _owner) public payable returns(bool);

    
    ///  controller to react if desired
    
    
    
    
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

    
    ///  controller to react if desired
    
    
    
    
    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool);
}

// File: contracts/external/MiniMeToken.sol

/*
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
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */




///  token using the token distribution at a given block, this will allow DAO's
///  and DApps to upgrade their features in a decentralized manner without
///  affecting the original token




contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data) public;
}


///  that deploys the contract, so usually this token will be deployed by a
///  token controller contract, which Giveth will call a "Campaign"
contract MiniMeToken is Controlled {

    string public name;                //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public version = 'MMT_0.2'; //An arbitrary versioning scheme


    
    ///  given value, the block number attached is the one that last changed the
    ///  value
    struct  Checkpoint {

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

    // Flag that determines if the token is transferable or not.
    bool public transfersEnabled;

    // The factory used to create new clone tokens
    MiniMeTokenFactory public tokenFactory;

////////////////
// Constructor
////////////////

    
    
    ///  will create the Clone token contracts, the token factory needs to be
    ///  deployed first
    
    ///  new token
    
    ///  determine the initial distribution of the clone token, set to 0 if it
    ///  is a new token
    
    
    
    
    function MiniMeToken(
        address _tokenFactory,
        address _parentToken,
        uint _parentSnapShotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) public {
        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                 // Set the name
        decimals = _decimalUnits;                          // Set the decimals
        symbol = _tokenSymbol;                             // Set the symbol
        parentToken = MiniMeToken(_parentToken);
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }


///////////////////
// ERC20 Methods
///////////////////

    
    
    
    
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);
        return doTransfer(msg.sender, _to, _amount);
    }

    
    ///  is approved by `_from`
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _amount
    ) public returns (bool success) {

        // The controller of this contract can move tokens around at will,
        //  this is important to recognize! Confirm that you trust the
        //  controller of this contract, which in most situations should be
        //  another open source smart contract or 0x0
        if (msg.sender != controller) {
            require(transfersEnabled);

            // The standard ERC 20 transferFrom functionality
            if (allowed[_from][msg.sender] < _amount) return false;
            allowed[_from][msg.sender] -= _amount;
        }
        return doTransfer(_from, _to, _amount);
    }

    
    ///  only be called by other functions in this contract.
    
    
    
    
    function doTransfer(address _from, address _to, uint _amount
    ) internal returns(bool) {

           if (_amount == 0) {
               return true;
           }

           require(parentSnapShotBlock < block.number);

           // Do not allow transfer to 0x0 or the token contract itself
           require((_to != 0) && (_to != address(this)));

           // If the amount being transfered is more than the balance of the
           //  account the transfer returns false
           uint previousBalanceFrom = balanceOfAt(_from, block.number);
           if (previousBalanceFrom < _amount) {
               return false;
           }

           // Alerts the token controller of the transfer
           if (isContract(controller)) {
               require(TokenController(controller).onTransfer(_from, _to, _amount));
           }

           // First update the balance array with the new value for the address
           //  sending the tokens
           updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

           // Then update the balance array with the new value for the address
           //  receiving the tokens
           uint previousBalanceTo = balanceOfAt(_to, block.number);
           require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
           updateValueAtNow(balances[_to], previousBalanceTo + _amount);

           // An event to make the transfer easy to find on the blockchain
           Transfer(_from, _to, _amount);

           return true;
    }

    
    
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    
    
    
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);

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
    function allowance(address _owner, address _spender
    ) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    
    ///  its behalf, and then a function is triggered in the contract that is
    ///  being approved, `_spender`. This allows users to use their tokens to
    ///  interact with contracts in one function call instead of two
    
    
    
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) public returns (bool success) {
        require(approve(_spender, _amount));

        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

    
    
    function totalSupply() public constant returns (uint) {
        return totalSupplyAt(block.number);
    }


////////////////
// Query balance and totalSupply in History
////////////////

    
    
    
    
    function balanceOfAt(address _owner, uint _blockNumber) public constant
        returns (uint) {

        // These next few lines are used when the balance of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.balanceOfAt` be queried at the
        //  genesis block for that token as this contains initial balance of
        //  this token
        if ((balances[_owner].length == 0)
            || (balances[_owner][0].fromBlock > _blockNumber)) {
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

    
    
    
    function totalSupplyAt(uint _blockNumber) public constant returns(uint) {

        // These next few lines are used when the totalSupply of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.totalSupplyAt` be queried at the
        //  genesis block for this token as that contains totalSupply of this
        //  token at this block number.
        if ((totalSupplyHistory.length == 0)
            || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
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
        ) public returns(address) {
        if (_snapshotBlock == 0) _snapshotBlock = block.number;
        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            this,
            _snapshotBlock,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
            );

        cloneToken.changeController(msg.sender);

        // An event to make the token easy to find on the blockchain
        NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }

////////////////
// Generate and destroy tokens
////////////////

    
    
    
    
    function generateTokens(address _owner, uint _amount
    ) public onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        Transfer(0, _owner, _amount);
        return true;
    }


    
    
    
    
    function destroyTokens(address _owner, uint _amount
    ) onlyController public returns (bool) {
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
// Enable tokens transfers
////////////////


    
    
    function enableTransfers(bool _transfersEnabled) public onlyController {
        transfersEnabled = _transfersEnabled;
    }

////////////////
// Internal helper functions to query and set a value in a snapshot array
////////////////

    
    
    
    
    function getValueAt(Checkpoint[] storage checkpoints, uint _block
    ) constant internal returns (uint) {
        if (checkpoints.length == 0) return 0;

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        // Binary search of the value in the array
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    
    ///  `totalSupplyHistory`
    
    
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal  {
        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
               Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
               newCheckPoint.fromBlock =  uint128(block.number);
               newCheckPoint.value = uint128(_value);
           } else {
               Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
               oldCheckPoint.value = uint128(_value);
           }
    }

    
    
    
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    
    function min(uint a, uint b) pure internal returns (uint) {
        return a < b ? a : b;
    }

    
    ///  set to 0, then the `proxyPayment` method is called which relays the
    ///  ether and creates tokens as described in the token controller contract
    function () public payable {
        require(isContract(controller));
        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
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

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
    }

////////////////
// Events
////////////////
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}


////////////////
// MiniMeTokenFactory
////////////////


///  In solidity this is the way to create a contract from a contract of the
///  same class
contract MiniMeTokenFactory {

    
    ///  the msg.sender becomes the controller of this clone token
    
    
    ///  determine the initial distribution of the clone token
    
    
    
    
    
    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) public returns (MiniMeToken) {
        MiniMeToken newToken = new MiniMeToken(
            this,
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
            );

        newToken.changeController(msg.sender);
        return newToken;
    }
}

// File: contracts/DTXToken.sol

contract DTXToken is MiniMeToken {

  function DTXToken(address _tokenFactory) public MiniMeToken (
    _tokenFactory,
    0x0,                    // no parent token
    0,                      // no snapshot block number from parent
    "DaTa eXchange Token", // Token name
    18,                     // Decimals
    "DTX",                 // Symbol
    true                   // Enable transfers
    )
  {}

}

// File: contracts/external/ERC20Token.sol

/*
  Abstract contract for the full ERC 20 Token standard
  https://github.com/ethereum/EIPs/issues/20

  Copyright 2017, Jordi Baylina (Giveth)

  Original contract from https://github.com/status-im/status-network-token/blob/master/contracts/ERC20Token.sol
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
  function totalSupply() constant public returns (uint256 balance);

  
  
  function balanceOf(address _owner) constant public returns (uint256 balance);

  
  
  
  
  function transfer(address _to, uint256 _value) public returns (bool success);

  
  
  
  
  
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

  
  
  
  
  function approve(address _spender, uint256 _value) public returns (bool success);

  
  
  
  function allowance(address _owner, address _spender) constant public returns (uint256 remaining);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// File: contracts/external/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/TokenSale.sol

contract TokenSale is TokenController, Controlled {

  using SafeMath for uint256;

  // In UNIX time format - http://www.unixtimestamp.com/
  uint256 public startPresaleTime;
  uint256 public endPresaleTime;
  uint256 public startDayOneTime;
  uint256 public endDayOneTime;
  uint256 public startTime;
  uint256 public endTime;

  // the purchase rates
  uint256 constant public TOKENS_PER_ETHER_EARLYSALE = 6400;
  uint256 constant public TOKENS_PER_ETHER_PRESALE = 6000;
  uint256 constant public TOKENS_PER_ETHER_DAY_ONE = 4400;
  uint256 constant public TOKENS_PER_ETHER = 4000;

  // max amount of 225 million tokens, in their smallest denomination
  uint256 constant public MAX_TOKENS = 225000000 * 10**18;

  // hard cap of 108 million tokens, in their smallest denomination
  uint256 constant public HARD_CAP = 108000000 * 10**18;

  // tokens locked for 3 years
  uint256 public lockedTokens;

  // total amount of tokens issues
  uint256 public totalIssued;

  // total amount of tokens locked in vesting
  uint256 public totalVested;

  // total amount of tokens issues
  uint256 public totalIssuedEarlySale;

  // the tokencontract for the DataBrokerDAO
  DTXToken public tokenContract;

  // the funds end up in this address
  address public vaultAddress;

  // is the token sale paused
  bool public paused;

  // is the token sale finalized
  bool public finalized;

  // are the tokens transferable
  bool public transferable;

  // listing of addresses with allowances
  mapping(address => Vesting) vestedAllowances;

  struct Vesting {
    uint256 amount;
    uint256 cliff;
  }

  
  function TokenSale(
    uint256 _startPresaleTime,
    uint256 _endPresaleTime,
    uint256 _startDayOneTime,
    uint256 _endDayOneTime,
    uint256 _startTime,
    uint256 _endTime,
    address _vaultAddress,
    address _tokenAddress
  ) public {
    // are the dates in the future
    require(_startPresaleTime > now);
    require(_endPresaleTime > now);
    require(_startDayOneTime > now);
    require(_endDayOneTime > now);
    require(_startTime > now);
    require(_endTime > now);
    // are the end dates after the start dates
    require(_endPresaleTime >= _startPresaleTime);
    require(_endDayOneTime >= _startDayOneTime);
    require(_endTime >= _startTime);
    // are the phases in the right order
    require(_startTime >= _endDayOneTime);
    require(_startDayOneTime >= _endPresaleTime);
    // dates are correct, set them!
    startPresaleTime = _startPresaleTime;
    endPresaleTime = _endPresaleTime;
    startDayOneTime = _startDayOneTime;
    endDayOneTime = _endDayOneTime;
    startTime = _startTime;
    endTime = _endTime;
    // make sure the the vault is there
    require(_vaultAddress != 0x0);
    vaultAddress = _vaultAddress;
    // make sure the token is there
    require(_tokenAddress != 0x0);
    tokenContract = DTXToken(_tokenAddress);
    // calculate the amount of tokens we need to lock up
    lockedTokens = MAX_TOKENS.div(100).mul(30);
    // set some stating flags
    paused = false;
    finalized = false;
    transferable = false;
  }

  
  /// simply calls `doPayment()` with the address that sent the ether as the
  /// `_owner`. Payable is a required solidity modifier for functions to receive
  /// ether, without this modifier functions will throw if ether is sent to them
  function () public payable notPaused {
    doPayment(msg.sender);
  }

  
  /// have the tokens created in an address of their choosing
  function proxyPayment(address _owner) public payable notPaused returns(bool success) {
    return doPayment(_owner);
  }

  
  /// transfers are allowed by default and no extra notifications are needed
  function onTransfer(address _from, address /*_to*/, uint /*_amount*/) public returns(bool success) {
    if ( _from == controller || _from == address(this) ) {
      return true;
    }
    return transferable;
  }

  
  /// approvals are allowed by default and no extra notifications are needed
  function onApprove(address _owner, address /*_spender*/, uint /*_amount*/) public returns(bool success) {
    if ( _owner == controller || _owner == address(this) ) {
      return true;
    }
    return transferable;
  }

  
  function makeTransferable() public onlyController {
    transferable = true;
  }

  
  function updateDates(
    uint256 _startPresaleTime,
    uint256 _endPresaleTime,
    uint256 _startDayOneTime,
    uint256 _endDayOneTime,
    uint256 _startTime,
    uint256 _endTime) public onlyController {
    startPresaleTime = _startPresaleTime;
    endPresaleTime = _endPresaleTime;
    startDayOneTime = _startDayOneTime;
    endDayOneTime = _endDayOneTime;
    startTime = _startTime;
    endTime = _endTime;
  }

  
  function handleEarlySaleBuyers(address[] _recipients, uint256[] _ethAmounts) public onlyController {
    // only run if the sale is not finalised yet
    require(!finalized);
    // loop over all recipients, use smallish lists in regards to gas costs (TBD)
    for (uint256 i = 0; i < _recipients.length; i++) {
      // use the fixed conversion rate from ETH to DTX
      uint256 tokensToIssue = TOKENS_PER_ETHER_EARLYSALE.mul(_ethAmounts[i]);
      // keep a separate counter to have a complete records on DTX issued
      totalIssuedEarlySale = totalIssuedEarlySale.add(tokensToIssue);
      // Creates an equal amount of tokens as ether sent. The new tokens are created in the address of the recipient
      require(tokenContract.generateTokens(_recipients[i], tokensToIssue));
    }
  }

  
  function handleExternalBuyers(
    address[] _recipients,
    uint256[] _free,
    uint256[] _locked,
    uint256[] _cliffs
  ) public onlyController {
    // only run if the sale is not finalised yet
    require(!finalized);
    // loop over all recipients, use smallish lists in regards to gas costs (TBD)
    for (uint256 i = 0; i < _recipients.length; i++) {
      // these tokens count for the hard cap limit, but they are guaranteed to succeed so no hardcap check.
      totalIssued = totalIssued.add(_free[i]);
      // Creates an equal amount of tokens as ether sent. The new tokens are created in the address of the recipient
      require(tokenContract.generateTokens(_recipients[i], _free[i]));
      // locks the rest until the cliff is reached
      vestedAllowances[_recipients[i]] = Vesting(_locked[i], _cliffs[i]);
      totalVested.add(_locked[i]);
      require(lockedTokens.add(totalVested.add(totalIssued.add(totalIssuedEarlySale))) <= MAX_TOKENS);
    }
  }

  
  ///  contract receives to the `vault` and creates tokens in the address of the
  ///  `_owner` assuming the TokenSale is still accepting funds
  function doPayment(address _owner) internal returns(bool success) {
    // there is no reason to check anything if there is no ETH being sent
    require(msg.value > 0);

    // if this contract is not the controller, we can fail immediately
    require(tokenContract.controller() == address(this));

    // check in what period we are
    bool isPresale = startPresaleTime <= now && endPresaleTime >= now;
    bool isDayOne = startDayOneTime <= now && endDayOneTime >= now;
    bool isSale = startTime <= now && endTime >= now;

    // check if we are in one of the sale periods
    require(isPresale || isDayOne || isSale);

    // check the minimum for the presale phase
    if (isPresale) {
      require(msg.value >= 10 ether);
    }

    // figure out the rate for this period.
    uint256 tokensPerEther = TOKENS_PER_ETHER;
    if (isPresale) {
      tokensPerEther = TOKENS_PER_ETHER_PRESALE;
    }
    if (isDayOne) {
      tokensPerEther = TOKENS_PER_ETHER_DAY_ONE;
    }

    // calculate the tokens to issue (since the decimals match, we just need to multiply the wei amounts)
    uint256 tokensToIssue = tokensPerEther.mul(msg.value);

    // have we reached the max contribution
    require(totalIssued.add(tokensToIssue) <= HARD_CAP);
    require(tokensToIssue.add(lockedTokens.add(totalVested.add(totalIssued.add(totalIssuedEarlySale)))) <= MAX_TOKENS);

    // Track how much the TokenSale has collected
    totalIssued = totalIssued.add(tokensToIssue);

    // Send the ether to the vault
    vaultAddress.transfer(msg.value);

    // Creates an equal amount of tokens as ether sent. The new tokens are created in the `_owner` address
    require(tokenContract.generateTokens(_owner, tokensToIssue));

    return true;
  }

  
  function changeTokenController(address _newController) public onlyController {
    tokenContract.changeController(_newController);
  }

  
  ///  and set the controller to the referral fee contract.
  
  function finalizeSale() public onlyController {
    // either the end time is passed, or the hard cap is reached
    require(now > endTime || totalIssued >= HARD_CAP);

    // we should only do this function once since it generates tokens
    require(!finalized);

    vestedAllowances[vaultAddress] = Vesting(lockedTokens, now + 3 years);

    // calculate how many tokens are left if we subtract all the issued amounts
    uint256 leftoverTokens = MAX_TOKENS.sub(lockedTokens).sub(totalIssued).sub(totalIssuedEarlySale).sub(totalVested);

    // generate that left over amount in the vault address
    require(tokenContract.generateTokens(vaultAddress, leftoverTokens));
    require(tokenContract.generateTokens(address(this), lockedTokens.add(totalVested)));

    finalized = true;
  }

  function claimLockedTokens(address _owner) public {
    require(vestedAllowances[_owner].cliff > 0 && vestedAllowances[_owner].amount > 0);
    require(now >= vestedAllowances[_owner].cliff);
    uint256 amount = vestedAllowances[_owner].amount;
    vestedAllowances[_owner].amount = 0;
    require(tokenContract.transfer(_owner, amount));
  }

  
  function pauseContribution() public onlyController {
    paused = true;
  }

  
  function resumeContribution() public onlyController {
    paused = false;
  }

  modifier notPaused() {
    require(!paused);
    _;
  }
}