
pragma solidity ^0.4.11;

/*
  Copyright 2017, Anton Egorov (Mothership Foundation)
  Copyright 2017, Klaus Hott (BlockchainLabs.nz)
  Copyright 2017, Jorge Izquierdo (Aragon Foundation)
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

library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

contract Refundable {
  function refund(address th, uint amount) returns (bool);
}


contract TokenController {
  
  
  
  function proxyPayment(address _owner) payable returns(bool);

  
  ///  controller to react if desired
  
  
  
  
  function onTransfer(address _from, address _to, uint _amount) returns(bool);

  
  ///  controller to react if desired
  
  
  
  
  function onApprove(address _owner, address _spender, uint _amount)
    returns(bool);
}

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

contract Finalizable {
  uint256 public finalizedBlock;
  bool public goalMet;

  function finalize();
}

contract Contribution is Controlled, TokenController, Finalizable {
  using SafeMath for uint256;

  uint256 public totalSupplyCap; // Total MSP supply to be generated
  uint256 public exchangeRate; // ETH-MSP exchange rate
  uint256 public totalSold; // How much tokens sold
  uint256 public totalSaleSupplyCap; // Token sale cap

  MiniMeTokenI public sit;
  MiniMeTokenI public msp;

  uint256 public startBlock;
  uint256 public endBlock;

  address public destEthDevs;
  address public destTokensSit;
  address public destTokensTeam;
  address public destTokensReferals;

  address public mspController;

  uint256 public initializedBlock;
  uint256 public finalizedTime;

  uint256 public minimum_investment;
  uint256 public minimum_goal;

  bool public paused;

  modifier initialized() {
    assert(address(msp) != 0x0);
    _;
  }

  modifier contributionOpen() {
    assert(getBlockNumber() >= startBlock &&
            getBlockNumber() <= endBlock &&
            finalizedBlock == 0 &&
            address(msp) != 0x0);
    _;
  }

  modifier notPaused() {
    require(!paused);
    _;
  }

  function Contribution() {
    // Booleans are false by default consider removing this
    paused = false;
  }

  
  ///  period starts This initializes most of the parameters
  
  
  ///  the contribution finalizes.
  
  
  
  
  
  
  ///  to be distributed to the SIT holders.
  
  
  
  function initialize(
      address _msp,
      address _mspController,

      uint256 _totalSupplyCap,
      uint256 _exchangeRate,
      uint256 _minimum_goal,

      uint256 _startBlock,
      uint256 _endBlock,

      address _destEthDevs,
      address _destTokensSit,
      address _destTokensTeam,
      address _destTokensReferals,

      address _sit
  ) public onlyController {
    // Initialize only once
    assert(address(msp) == 0x0);

    msp = MiniMeTokenI(_msp);
    assert(msp.totalSupply() == 0);
    assert(msp.controller() == address(this));
    assert(msp.decimals() == 18);  // Same amount of decimals as ETH

    require(_mspController != 0x0);
    mspController = _mspController;

    require(_exchangeRate > 0);
    exchangeRate = _exchangeRate;

    assert(_startBlock >= getBlockNumber());
    require(_startBlock < _endBlock);
    startBlock = _startBlock;
    endBlock = _endBlock;

    require(_destEthDevs != 0x0);
    destEthDevs = _destEthDevs;

    require(_destTokensSit != 0x0);
    destTokensSit = _destTokensSit;

    require(_destTokensTeam != 0x0);
    destTokensTeam = _destTokensTeam;

    require(_destTokensReferals != 0x0);
    destTokensReferals = _destTokensReferals;

    require(_sit != 0x0);
    sit = MiniMeTokenI(_sit);

    initializedBlock = getBlockNumber();
    // SIT amount should be no more than 20% of MSP total supply cap
    assert(sit.totalSupplyAt(initializedBlock) * 5 <= _totalSupplyCap);
    totalSupplyCap = _totalSupplyCap;

    // We are going to sale 70% of total supply cap
    totalSaleSupplyCap = percent(70).mul(_totalSupplyCap).div(percent(100));

    minimum_goal = _minimum_goal;
  }

  function setMinimumInvestment(
      uint _minimum_investment
  ) public onlyController {
    minimum_investment = _minimum_investment;
  }

  function setExchangeRate(
      uint _exchangeRate
  ) public onlyController {
    assert(getBlockNumber() < startBlock);
    exchangeRate = _exchangeRate;
  }

  
  ///  getting MSPs.
  function () public payable notPaused {
    proxyPayment(msg.sender);
  }


  //////////
  // TokenController functions
  //////////

  
  ///  acquire MSPs. Or directly from third parties that want to acquire MSPs in
  ///  behalf of a token holder.
  
  function proxyPayment(address _th) public payable notPaused initialized contributionOpen returns (bool) {
    require(_th != 0x0);
    doBuy(_th);
    return true;
  }

  function onTransfer(address, address, uint256) public returns (bool) {
    return false;
  }

  function onApprove(address, address, uint256) public returns (bool) {
    return false;
  }

  function doBuy(address _th) internal {
    require(msg.value >= minimum_investment);

    // Antispam mechanism
    address caller;
    if (msg.sender == address(msp)) {
      caller = _th;
    } else {
      caller = msg.sender;
    }

    // Do not allow contracts to game the system
    assert(!isContract(caller));

    uint256 toFund = msg.value;
    uint256 leftForSale = tokensForSale();
    if (toFund > 0) {
      if (leftForSale > 0) {
        uint256 tokensGenerated = toFund.mul(exchangeRate);

        // Check total supply cap reached, sell the all remaining tokens
        if (tokensGenerated > leftForSale) {
          tokensGenerated = leftForSale;
          toFund = leftForSale.div(exchangeRate);
        }

        assert(msp.generateTokens(_th, tokensGenerated));
        totalSold = totalSold.add(tokensGenerated);
        if (totalSold >= minimum_goal) {
          goalMet = true;
        }
        destEthDevs.transfer(toFund);
        NewSale(_th, toFund, tokensGenerated);
      } else {
        toFund = 0;
      }
    }

    uint256 toReturn = msg.value.sub(toFund);
    if (toReturn > 0) {
      // If the call comes from the Token controller,
      // then we return it to the token Holder.
      // Otherwise we return to the sender.
      if (msg.sender == address(msp)) {
        _th.transfer(toReturn);
      } else {
        msg.sender.transfer(toReturn);
      }
    }
  }

  
  
  
  function isContract(address _addr) constant internal returns (bool) {
    if (_addr == 0) return false;
    uint256 size;
    assembly {
      size := extcodesize(_addr)
    }
    return (size > 0);
  }

  function refund() public {
    require(finalizedBlock != 0);
    require(!goalMet);

    uint256 amountTokens = msp.balanceOf(msg.sender);
    require(amountTokens > 0);
    uint256 amountEther = amountTokens.div(exchangeRate);
    address th = msg.sender;

    Refundable(mspController).refund(th, amountTokens);
    Refundable(destEthDevs).refund(th, amountEther);

    Refund(th, amountTokens, amountEther);
  }

  event Refund(address _token_holder, uint256 _amount_tokens, uint256 _amount_ether);

  
  ///  end or by anybody after the `endBlock`. This method finalizes the contribution period
  ///  by creating the remaining tokens and transferring the controller to the configured
  ///  controller.
  function finalize() public initialized {
    assert(getBlockNumber() >= startBlock);
    assert(msg.sender == controller || getBlockNumber() > endBlock || tokensForSale() == 0);
    require(finalizedBlock == 0);

    finalizedBlock = getBlockNumber();
    finalizedTime = now;

    if (goalMet) {
      // Generate 5% for the team
      assert(msp.generateTokens(
        destTokensTeam,
        percent(5).mul(totalSupplyCap).div(percent(100))));

      // Generate 5% for the referal bonuses
      assert(msp.generateTokens(
        destTokensReferals,
        percent(5).mul(totalSupplyCap).div(percent(100))));

      // Generate tokens for SIT exchanger
      assert(msp.generateTokens(
        destTokensSit,
        sit.totalSupplyAt(initializedBlock)));
    }

    msp.changeController(mspController);
    Finalized();
  }

  function percent(uint256 p) internal returns (uint256) {
    return p.mul(10**16);
  }


  //////////
  // Constant functions
  //////////

  
  function tokensIssued() public constant returns (uint256) {
    return msp.totalSupply();
  }

  
  function tokensForSale() public constant returns(uint256) {
    return totalSaleSupplyCap > totalSold ? totalSaleSupplyCap - totalSold : 0;
  }


  //////////
  // Testing specific methods
  //////////

  
  function getBlockNumber() internal constant returns (uint256) {
    return block.number;
  }


  //////////
  // Safety Methods
  //////////

  
  ///  sent tokens to this contract.
  
  ///  set to 0 in case you want to extract ether.
  function claimTokens(address _token) public onlyController {
    if (msp.controller() == address(this)) {
      msp.claimTokens(_token);
    }
    if (_token == 0x0) {
      controller.transfer(this.balance);
      return;
    }

    ERC20Token token = ERC20Token(_token);
    uint256 balance = token.balanceOf(this);
    token.transfer(controller, balance);
    ClaimedTokens(_token, controller, balance);
  }


  
  function pauseContribution() onlyController {
    paused = true;
  }

  
  function resumeContribution() onlyController {
    paused = false;
  }

  event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
  event NewSale(address indexed _th, uint256 _amount, uint256 _tokens);
  event Finalized();
}




///  SIT token is not transferable, and we just keep an accounting between all tokens
///  deposited and the tokens collected.
///  The controllerShip of SIT should be transferred to this contract before the
///  contribution period starts.

contract SITExchanger is Controlled, TokenController {
  using SafeMath for uint256;

  mapping (address => uint256) public collected;
  uint256 public totalCollected;
  MiniMeTokenI public sit;
  MiniMeTokenI public msp;
  Contribution public contribution;

  function SITExchanger(address _sit, address _msp, address _contribution) {
    sit = MiniMeTokenI(_sit);
    msp = MiniMeTokenI(_msp);
    contribution = Contribution(_contribution);
  }

  
  ///  corresponding MSPs
  function collect() public {
    // SIT sholder could collect MSP right after contribution started
    assert(getBlockNumber() > contribution.startBlock());

    // Get current MSP ballance
    uint256 balance = sit.balanceOfAt(msg.sender, contribution.initializedBlock());

    // And then subtract the amount already collected
    uint256 amount = balance.sub(collected[msg.sender]);

    require(amount > 0);  // Notify the user that there are no tokens to exchange

    totalCollected = totalCollected.add(amount);
    collected[msg.sender] = collected[msg.sender].add(amount);

    assert(msp.transfer(msg.sender, amount));

    TokensCollected(msg.sender, amount);
  }

  function proxyPayment(address) public payable returns (bool) {
    throw;
  }

  function onTransfer(address, address, uint256) public returns (bool) {
    return false;
  }

  function onApprove(address, address, uint256) public returns (bool) {
    return false;
  }

  //////////
  // Testing specific methods
  //////////

  
  function getBlockNumber() internal constant returns (uint256) {
    return block.number;
  }

  //////////
  // Safety Method
  //////////

  
  ///  sent tokens to this contract.
  
  ///  set to 0 in case you want to extract ether.
  function claimTokens(address _token) public onlyController {
    assert(_token != address(msp));
    if (_token == 0x0) {
      controller.transfer(this.balance);
      return;
    }

    ERC20Token token = ERC20Token(_token);
    uint256 balance = token.balanceOf(this);
    token.transfer(controller, balance);
    ClaimedTokens(_token, controller, balance);
  }

  event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
  event TokensCollected(address indexed _holder, uint256 _amount);

}