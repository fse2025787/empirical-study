
pragma solidity ^0.4.13;

/**
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    require(assertion);
  }
}

// inspired by Zeppelin's Vested Token deriving MiniMeToken

contract Controlled {
    
    ///  a function with this modifier
    modifier onlyController{ require(msg.sender==controller); _; }


    address public controller;

    function Controlled() { controller = msg.sender;}

    
    
    function changeController(address _newController) onlyController {
        controller = _newController;
    }
}


contract Controller {
    
    
    
    function proxyPayment(address _owner) payable returns(bool);

    
    ///  controller to react if desired
    
    
    
    
    function onTransfer(address _from, address _to, uint _amount) returns(bool);

    
    ///  controller to react if desired
    
    
    
    
    function onApprove(address _owner, address _spender, uint _amount)
        returns(bool);
}

contract ApproveAndCallReceiver {
    function receiveApproval(address _from, uint256 _amount, address _token, bytes _data);
}

/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  function totalSupply() constant returns (uint);
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract MiniMeToken is ERC20, Controlled {
    string public name;                //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public version = 'MMT_0.1'; //An arbitrary versioning scheme


    
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
    ) {
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

    
    
    
    
    function transfer(address _to, uint256 _amount) returns (bool success) {
        require (transfersEnabled);
    ////if (!transfersEnabled) throw;
        return doTransfer(msg.sender, _to, _amount);
    }

    
    ///  is approved by `_from`
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _amount
    ) returns (bool success) {

        // The controller of this contract can move tokens around at will,
        //  this is important to recognize! Confirm that you trust the
        //  controller of this contract, which in most situations should be
        //  another open source smart contract or 0x0
        if (msg.sender != controller) {
            require (transfersEnabled);

            ////if (!transfersEnabled) throw;

            // The standard ERC 20 transferFrom functionality
            assert (allowed[_from][msg.sender]>=_amount);

            ////if (allowed[_from][msg.sender] < _amount) throw;
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

           // Do not allow transfer to 0x0 or the token contract itself
           require((_to>0)&&(_to!=address(this)));

           //// if ((_to == 0) || (_to == address(this))) throw;

           // If the amount being transfered is more than the balance of the
           //  account the transfer returns false
           var previousBalanceFrom = balanceOfAt(_from, block.number);
           assert(previousBalanceFrom >= _amount);

           // Alerts the token controller of the transfer
           if (isContract(controller)) {
               assert(Controller(controller).onTransfer(_from,_to,_amount));

           }

           // First update the balance array with the new value for the address
           //  sending the tokens
           updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

           // Then update the balance array with the new value for the address
           //  receiving the tokens
           var previousBalanceTo = balanceOfAt(_to, block.number);
           assert(previousBalanceTo+_amount>=previousBalanceTo); 
           
           //// if (previousBalanceTo + _amount < previousBalanceTo) throw; // Check for overflow
           updateValueAtNow(balances[_to], previousBalanceTo + _amount);

           // An event to make the transfer easy to find on the blockchain
           Transfer(_from, _to, _amount);

           return true;
    }

    
    
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    
    
    
    function approve(address _spender, uint256 _amount) returns (bool success) {
        require(transfersEnabled);

        // To change the approve amount you first have to reduce the addresses&#180;
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_amount==0)||(allowed[msg.sender][_spender]==0));

        // Alerts the token controller of the approve function call
        if (isContract(controller)) {
            assert(Controller(controller).onApprove(msg.sender,_spender,_amount));

            //  if (!Controller(controller).onApprove(msg.sender, _spender, _amount))
            //        throw;
        }

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    
    
    
    
    ///  to spend
    function allowance(address _owner, address _spender
    ) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    
    ///  its behalf, and then a function is triggered in the contract that is
    ///  being approved, `_spender`. This allows users to use their tokens to
    ///  interact with contracts in one function call instead of two
    
    
    
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) returns (bool success) {
        approve(_spender, _amount);

        // This portion is copied from ConsenSys's Standard Token Contract. It
        //  calls the receiveApproval function that is part of the contract that
        //  is being approved (`_spender`). The function should look like:
        //  `receiveApproval(address _from, uint256 _amount, address
        //  _tokenContract, bytes _extraData)` It is assumed that the call
        //  *should* succeed, otherwise the plain vanilla approve would be used
        ApproveAndCallReceiver(_spender).receiveApproval(
           msg.sender,
           _amount,
           this,
           _extraData
        );
        return true;
    }

    
    
    function totalSupply() constant returns (uint) {
        return totalSupplyAt(block.number);
    }


////////////////
// Query balance and totalSupply in History
////////////////

    
    
    
    
    function balanceOfAt(address _owner, uint _blockNumber) constant
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

    
    
    
    function totalSupplyAt(uint _blockNumber) constant returns(uint) {

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

    function min(uint a, uint b) internal returns (uint) {
      return a < b ? a : b;
    }

////////////////
// Clone Token Method
////////////////

    
    ///  this token at `_snapshotBlock`
    
    
    
    
    ///  copied to set the initial distribution of the new clone token;
    ///  if the block is higher than the actual block, the current block is used
    
    
    function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
        ) returns(address) {
        if (_snapshotBlock > block.number) _snapshotBlock = block.number;
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
    ) onlyController returns (bool) {
        uint curTotalSupply = getValueAt(totalSupplyHistory, block.number);
        assert(curTotalSupply+_amount>=curTotalSupply);
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        var previousBalanceTo = balanceOf(_owner);
        assert(previousBalanceTo+_amount>=previousBalanceTo);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        Transfer(0, _owner, _amount);
        return true;
    }


    
    
    
    
    function destroyTokens(address _owner, uint _amount
    ) onlyController returns (bool) {
        uint curTotalSupply = getValueAt(totalSupplyHistory, block.number);
        assert(curTotalSupply >= _amount);
        
        //// if (curTotalSupply < _amount) throw;

        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        var previousBalanceFrom = balanceOf(_owner);
        assert(previousBalanceFrom >=_amount);

        //// if (previousBalanceFrom < _amount) throw;
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        Transfer(_owner, 0, _amount);
        return true;
    }

////////////////
// Enable tokens transfers
////////////////


    
    
    function enableTransfers(bool _transfersEnabled) onlyController {
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

    
    ///  set to 0, then the `proxyPayment` method is called which relays the
    ///  ether and creates tokens as described in the token controller contract
    function ()  payable {
        require(isContract(controller));
        assert(Controller(controller).proxyPayment.value(msg.value)(msg.sender));
    }


////////////////
// Events
////////////////
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
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
    ) returns (MiniMeToken) {
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


// @dev MiniMeIrrevocableVestedToken is a derived version of MiniMeToken adding the
// ability to createTokenGrants which are basically a transfer that limits the
// receiver of the tokens.


contract MiniMeIrrevocableVestedToken is MiniMeToken, SafeMath {

  uint256 MAX_GRANTS_PER_ADDRESS = 20;

  // Keep the struct at 3 sstores ( total value  20+32+24 =76 bytes)
  struct TokenGrant {
    address granter;  // 20 bytes
    uint256 value;    // 32 bytes
    uint64 cliff;
    uint64 vesting;
    uint64 start;     // 3*8 =24 bytes
  }

  event NewTokenGrant(address indexed from, address indexed to, uint256 value, uint64 start, uint64 cliff, uint64 vesting);

  mapping (address => TokenGrant[]) public grants;

  mapping (address => bool) canCreateGrants;
  address vestingWhitelister;

  modifier canTransfer(address _sender, uint _value) {
    require(_value<=spendableBalanceOf(_sender));
    _;
  }

  modifier onlyVestingWhitelister {
    require(msg.sender==vestingWhitelister);
    _;
  }

  function MiniMeIrrevocableVestedToken (
      address _tokenFactory,
      address _parentToken,
      uint _parentSnapShotBlock,
      string _tokenName,
      uint8 _decimalUnits,
      string _tokenSymbol,
      bool _transfersEnabled
  ) MiniMeToken(_tokenFactory, _parentToken, _parentSnapShotBlock, _tokenName, _decimalUnits, _tokenSymbol, _transfersEnabled) {
    vestingWhitelister = msg.sender;
    doSetCanCreateGrants(vestingWhitelister, true);
  }

  // @dev Checks modifier and allows transfer if tokens are not locked.
  function transfer(address _to, uint _value)
           canTransfer(msg.sender, _value)
           public
           returns (bool success) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value)
           canTransfer(_from, _value)
           public
           returns (bool success) {
    return super.transferFrom(_from, _to, _value);
  }

  function spendableBalanceOf(address _holder) constant public returns (uint) {
    return transferableTokens(_holder, uint64(now));
  }

  // main func for token grant

  function grantVestedTokens(
    address _to,
    uint256 _value,
    uint64 _start,
    uint64 _cliff,
    uint64 _vesting) public {

    // Check start, cliff and vesting are properly order to ensure correct functionality of the formula.
    require(_cliff >= _start && _vesting >= _cliff);
    require(tokenGrantsCount(_to)<=MAX_GRANTS_PER_ADDRESS); //// To prevent a user being spammed and have his balance locked (out of gas attack when calculating vesting).

    assert(canCreateGrants[msg.sender]);


    TokenGrant memory grant = TokenGrant(msg.sender, _value, _cliff, _vesting, _start);
    grants[_to].push(grant);

    assert(transfer(_to,_value));

    NewTokenGrant(msg.sender, _to, _value, _cliff, _vesting, _start);
  }

  function setCanCreateGrants(address _addr, bool _allowed)
           onlyVestingWhitelister public {
    doSetCanCreateGrants(_addr, _allowed);
  }

  function doSetCanCreateGrants(address _addr, bool _allowed)
           internal {
    canCreateGrants[_addr] = _allowed;
  }

  function changeVestingWhitelister(address _newWhitelister) onlyVestingWhitelister public {
    doSetCanCreateGrants(vestingWhitelister, false);
    vestingWhitelister = _newWhitelister;
    doSetCanCreateGrants(vestingWhitelister, true);
  }

  function tokenGrantsCount(address _holder) constant public returns (uint index) {
    return grants[_holder].length;
  }

  function tokenGrant(address _holder, uint _grantId) constant public returns (address granter, uint256 value, uint256 vested, uint64 start, uint64 cliff, uint64 vesting) {
    TokenGrant storage grant = grants[_holder][_grantId];

    granter = grant.granter;
    value = grant.value;
    start = grant.start;
    cliff = grant.cliff;
    vesting = grant.vesting;

    vested = vestedTokens(grant, uint64(now));
  }

  function vestedTokens(TokenGrant grant, uint64 time) internal constant returns (uint256) {
    return calculateVestedTokens(
      grant.value,
      uint256(time),
      uint256(grant.start),
      uint256(grant.cliff),
      uint256(grant.vesting)
    );
  }

  //  transferableTokens
  //   |                         _/--------   NonVestedTokens
  //   |                       _/
  //   |                     _/
  //   |                   _/
  //   |                 _/
  //   |                /
  //   |              .|
  //   |            .  |
  //   |          .    |
  //   |        .      |
  //   |      .        |
  //   |    .          |
  //   +===+===========+---------+----------> time
  //      Start       Cliff    Vesting

  function calculateVestedTokens(
    uint256 tokens,
    uint256 time,
    uint256 start,
    uint256 cliff,
    uint256 vesting) internal constant returns (uint256)
    {

    // Shortcuts for before cliff and after vesting cases.
    if (time < cliff) return 0;
    if (time >= vesting) return tokens;

    // Interpolate all vested tokens.
    // As before cliff the shortcut returns 0, we can use just this function to
    // calculate it.

    // vestedTokens = tokens * (time - start) / (vesting - start)
    uint256 vestedTokens = safeDiv(
                                  safeMul(
                                    tokens,
                                    safeSub(time, start)
                                    ),
                                  safeSub(vesting, start)
                                  );

    return vestedTokens;
  }

  function nonVestedTokens(TokenGrant grant, uint64 time) internal constant returns (uint256) {
    return safeSub(grant.value, vestedTokens(grant, time));
  }

  // @dev The date in which all tokens are transferable for the holder
  // Useful for displaying purposes (not used in any logic calculations)
  function lastTokenIsTransferableDate(address holder) constant public returns (uint64 date) {
    date = uint64(now);
    uint256 grantIndex = tokenGrantsCount(holder);
    for (uint256 i = 0; i < grantIndex; i++) {
      date = max64(grants[holder][i].vesting, date);
    }
    return date;
  }

  // @dev How many tokens can a holder transfer at a point in time
  function transferableTokens(address holder, uint64 time) constant public returns (uint256) {
    uint256 grantIndex = tokenGrantsCount(holder);

    if (grantIndex == 0) return balanceOf(holder); // shortcut for holder without grants

    // Iterate through all the grants the holder has, and add all non-vested tokens
    uint256 nonVested = 0;
    for (uint256 i = 0; i < grantIndex; i++) {
      nonVested = safeAdd(nonVested, nonVestedTokens(grants[holder][i], time));
    }

    // Balance - totalNonVested is the amount of tokens a holder can transfer at any given time
    return safeSub(balanceOf(holder), nonVested);
  }
}

contract GNR is MiniMeIrrevocableVestedToken {
  // @dev GNR constructor just parametrizes the MiniMeIrrevocableVestedToken constructor
  function GNR(
    address _tokenFactory
  ) MiniMeIrrevocableVestedToken(
    _tokenFactory,
    0x0,                    // no parent token
    0,                      // no snapshot block number from parent
    "Genaro Network Token", // Token name
    9,                     // Decimals
    "GNR",                  // Symbol
    true                    // Enable transfers
    ) {}
}