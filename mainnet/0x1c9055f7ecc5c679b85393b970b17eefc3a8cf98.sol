
pragma solidity ^0.4.13;


 
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

 
}



 
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}



/// Originally envisioned in FirstBlood ICO contract.
contract Haltable is Ownable {
  bool public halted;

  modifier stopInEmergency {
    require(!halted);
    _;
  }

  modifier onlyInEmergency {
    require(halted);
    _;
  }

  /// called by the owner on emergency, triggers stopped state
  function halt() external onlyOwner {
    halted = true;
  }

  /// called by the owner on end of emergency, returns to normal state
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
  }
}




 
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);
  function mint(address receiver, uint amount);
  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}




contract SolarDaoToken is SafeMath, ERC20, Ownable {
 string public name = "Solar DAO Token";
 string public symbol = "SDAO";
 uint public decimals = 4;

 /// contract that is allowed to create new tokens and allows unlift the transfer limits on this token
 address public crowdsaleAgent;
 /// A crowdsale contract can release us to the wild if ICO success. If false we are are in transfer lock up period.
 bool public released = false;
 /// approve() allowances
 mapping (address => mapping (address => uint)) allowed;
 /// holder balances
 mapping(address => uint) balances;

 
 modifier canTransfer() {
   if(!released) {
       require(msg.sender == crowdsaleAgent);
   }
   _;
 }

 
 
 modifier inReleaseState(bool _released) {
   require(_released == released);
   _;
 }

 
 modifier onlyCrowdsaleAgent() {
   require(msg.sender == crowdsaleAgent);
   _;
 }

 
 
 modifier onlyPayloadSize(uint size) {
    require(msg.data.length >= size + 4);
    _;
 }

 
 modifier canMint() {
    require(!released);
    _;
  }

 
 function SolarDaoToken() {
   owner = msg.sender;
 }

 /// Fallback method will buyout tokens
 function() payable {
   revert();
 }

 
 
 
 function mint(address receiver, uint amount) onlyCrowdsaleAgent canMint public {
    totalSupply = safeAdd(totalSupply, amount);
    balances[receiver] = safeAdd(balances[receiver], amount);
    Transfer(0, receiver, amount);
 }

 
 
 function setCrowdsaleAgent(address _crowdsaleAgent) onlyOwner inReleaseState(false) public {
   crowdsaleAgent = _crowdsaleAgent;
 }
 
 function releaseTokenTransfer() public onlyCrowdsaleAgent {
   released = true;
 }
 
 
 
 
 function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) canTransfer returns (bool success) {
   balances[msg.sender] = safeSub(balances[msg.sender], _value);
   balances[_to] = safeAdd(balances[_to], _value);

   Transfer(msg.sender, _to, _value);
   return true;
 }

 
 
 
 
 
 function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(2 * 32) canTransfer returns (bool success) {
   var _allowance = allowed[_from][msg.sender];

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
 }
 
 
 
 function balanceOf(address _owner) constant returns (uint balance) {
   return balances[_owner];
 }

 
 
 
 
 function approve(address _spender, uint _value) returns (bool success) {
   // To change the approve amount you first have to reduce the addresses`
   //  allowance to zero by calling `approve(_spender, 0)` if it is not
   //  already 0 to mitigate the race condition described here:
   //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   require ((_value == 0) || (allowed[msg.sender][_spender] == 0));

   allowed[msg.sender][_spender] = _value;
   Approval(msg.sender, _spender, _value);
   return true;
 }

 
 
 
 
 function allowance(address _owner, address _spender) constant returns (uint remaining) {
   return allowed[_owner][_spender];
 }
}

contract Killable is Ownable {
 function kill() onlyOwner {
   selfdestruct(owner);
 }
}



contract SolarDaoTokenCrowdsale is Haltable, Killable, SafeMath {

  /// Prefunding goal in USD cents, if the prefunding goal is reached, ico will start
  uint public constant PRE_FUNDING_GOAL = 4e6 * PRICE;

  /// Tokens funding goal in USD cents, if the funding goal is reached, ico will stop
  uint public constant ICO_GOAL = 8e7 * PRICE;

  /// Miminal tokens funding goal in USD cents, if this goal isn't reached during ICO, refund will begin
  uint public constant MIN_ICO_GOAL = 1e7;

  /// Miminal investment value
  uint public constant MIN_INVESTMENT = 5 ether;

  /// Percent of bonus tokens team receives from each investment
  uint public constant TEAM_BONUS_PERCENT = 25;

  /// The token price in USD cents
  uint constant public PRICE = 100;

  /// The token we are selling
  SolarDaoToken public token;

  /// tokens will be transfered from this address
  address public multisigWallet;

  /// the UNIX timestamp start date of the crowdsale
  uint public startsAt;

  /// the UNIX timestamp end date of the crowdsale
  uint public endsAt;

  /// the UNIX timestamp start date of the pre invest crowdsale
  uint public preInvestStart;

  /// the number of tokens already sold through this contract
  uint public tokensSold = 0;

  /// How many wei of funding we have raised
  uint public weiRaised = 0;

  /// How many distinct addresses have invested
  uint public investorCount = 0;

  /// How much wei we have returned back to the contract after a failed crowdfund.
  uint public loadedRefund = 0;

  /// How much wei we have given back to investors.
  uint public weiRefunded = 0;

  /// Has this crowdsale been finalized
  bool public finalized;

  /// USD to Ether rate in cents
  uint public exchangeRate;

  /// exchangeRate timestamp
  uint public exchangeRateTimestamp;

  /// External agent that will can change exchange rate
  address public exchangeRateAgent;

  /// How much ETH each address has invested to this crowdsale
  mapping (address => uint256) public investedAmountOf;

  /// How much tokens this crowdsale has credited for each investor address
  mapping (address => uint256) public tokenAmountOf;

  /// Define preICO pricing schedule using milestones.
  struct Milestone {
      // UNIX timestamp when this milestone kicks in
      uint start;
      // UNIX timestamp when this milestone kicks out
      uint end;
      // How many % tokens will add
      uint bonus;
  }

  Milestone[] public milestones;

  /// State machine
  /// Preparing: All contract initialization calls and variables have not been set yet
  /// Prefunding: We have not passed start time yet
  /// Funding: Active crowdsale
  /// Success: Minimum funding goal reached
  /// Failure: Minimum funding goal not reached before ending time
  /// Finalized: The finalized has been called and succesfully executed\
  /// Refunding: Refunds are loaded on the contract for reclaim.
  enum State{Unknown, Preparing, PreFunding, Funding, Success, Failure, Finalized, Refunding}

  /// A new investment was made
  event Invested(address investor, uint weiAmount, uint tokenAmount);
  /// Refund was processed for a contributor
  event Refund(address investor, uint weiAmount);
  /// Crowdsale end time has been changed
  //event EndsAtChanged(uint endsAt);
  /// Calculated new price
  event ExchangeRateChanged(uint oldValue, uint newValue);

  
  modifier inState(State state) {
    require(getState() == state);
    _;
  }

  modifier onlyExchangeRateAgent() {
    require(msg.sender == exchangeRateAgent);
    _;
  }

  
  
  
  
  
  
  function SolarDaoTokenCrowdsale(address _token, address _multisigWallet, uint _preInvestStart, uint _start, uint _end) {
    require(_multisigWallet != 0);
    require(_preInvestStart != 0);
    require(_start != 0);
    require(_end != 0);
    require(_start < _end);
    require(_end >  1514419199);

    token = SolarDaoToken(_token);

    multisigWallet = _multisigWallet;
    startsAt = _start;
    endsAt = _end;
    preInvestStart = _preInvestStart;

    milestones.push(Milestone(preInvestStart, 1514419199, 40));

    var icoBonuses = [uint(15), 10, 5];
    for (uint i = 1; i <= icoBonuses.length; i++) {
      milestones.push(Milestone(startsAt + i * 1 weeks, startsAt + (i + 1) * 1 weeks, icoBonuses[i - 1]));
    }
    delete icoBonuses;
  }

  function() payable {
    buy();
  }

  
  
  function getCurrentMilestone() private constant returns (Milestone) {
      for (uint i = 0; i < milestones.length; i++) {
        if (milestones[i].start <= now && milestones[i].end > now) {
          return milestones[i];
        }
      }
  }

   
   
  function investInternal(address receiver) stopInEmergency private {
    var state = getState();
    require(state == State.Funding || state == State.PreFunding);
    require(msg.value >= MIN_INVESTMENT);

    uint weiAmount = msg.value;

    uint tokensAmount = calculateTokens(weiAmount);
    assert (tokensAmount > 0);

    if(state == State.PreFunding) {
        tokensAmount += safeDiv(safeMul(tokensAmount, getCurrentMilestone().bonus), 100);
    }

    if(investedAmountOf[receiver] == 0) {
       // A new investor
       investorCount++;
    }

    // Update investor
    investedAmountOf[receiver] = safeAdd(investedAmountOf[receiver], weiAmount);
    tokenAmountOf[receiver] = safeAdd(tokenAmountOf[receiver], tokensAmount);
    // Update totals
    weiRaised = safeAdd(weiRaised, weiAmount);
    tokensSold = safeAdd(tokensSold, tokensAmount);

    assignTokens(receiver, tokensAmount);
    var teamBonusTokens = safeDiv(safeMul(tokensAmount, TEAM_BONUS_PERCENT), 100 - TEAM_BONUS_PERCENT);
    assignTokens(multisigWallet, teamBonusTokens);

    multisigWallet.transfer(weiAmount);
    // Tell us invest was success
    Invested(receiver, weiAmount, tokensAmount);
  }

  
  
  function invest(address receiver) public payable {
    investInternal(receiver);
  }

  
  function buy() public payable {
    invest(msg.sender);
  }

  
  function finalize() public inState(State.Success) onlyOwner stopInEmergency {
    require(!finalized);

    finalized = true;
    finalizeCrowdsale();
  }

  
  function finalizeCrowdsale() internal {
    token.releaseTokenTransfer();
  }

   
   
   
  function setExchangeRate(uint value, uint time) onlyExchangeRateAgent {
    require(value > 0);
    require(time > 0);
    require(exchangeRateTimestamp == 0 || getDifference(int(time), int(now)) <= 1 minutes);
    require(exchangeRate == 0 || (getDifference(int(value), int(exchangeRate)) * 100 / exchangeRate <= 30));

    ExchangeRateChanged(exchangeRate, value);
    exchangeRate = value;
    exchangeRateTimestamp = time;
  }

  
  
 function setExchangeRateAgent(address newAgent) onlyOwner {
   if (newAgent != address(0)) {
     exchangeRateAgent = newAgent;
   }
 }

  
  
  
  
 function setCrowdsaleData(uint _tokensSold, uint _weiRaised, uint _investorCount) onlyOwner {
	require(_tokensSold > 0);
	require(_weiRaised > 0);
	require(_investorCount > 0);

	tokensSold = _tokensSold;
	weiRaised = _weiRaised;
	investorCount = _investorCount;
 }

  function getDifference(int one, int two) private constant returns (uint) {
    var diff = one - two;
    if (diff < 0)
      diff = -diff;
    return uint(diff);
  }

  
  
  function setEndsAt(uint time) onlyOwner {
    require(time >= now);
    endsAt = time;
    //EndsAtChanged(endsAt);
  }

  
  function loadRefund() public payable inState(State.Failure) {
    require(msg.value > 0);
    loadedRefund = safeAdd(loadedRefund, msg.value);
  }

  
  function refund() public inState(State.Refunding) {
    uint256 weiValue = investedAmountOf[msg.sender];
    if (weiValue == 0)
      return;
    investedAmountOf[msg.sender] = 0;
    weiRefunded = safeAdd(weiRefunded, weiValue);
    Refund(msg.sender, weiValue);
    msg.sender.transfer(weiValue);
  }

  
  
  function isMinimumGoalReached() public constant returns (bool reached) {
    return weiToUsdCents(weiRaised) >= MIN_ICO_GOAL;
  }

  
  
  function isCrowdsaleFull() public constant returns (bool) {
    return weiToUsdCents(weiRaised) >= ICO_GOAL;
  }

  
  
  function getState() public constant returns (State) {
    if (finalized)
      return State.Finalized;
    if (address(token) == 0 || address(multisigWallet) == 0 || now < preInvestStart)
      return State.Preparing;
    if (preInvestStart <= now && now < startsAt && !isMaximumPreFundingGoalReached())
      return State.PreFunding;
    if (now <= endsAt && !isCrowdsaleFull())
      return State.Funding;
    if (isMinimumGoalReached())
      return State.Success;
    if (!isMinimumGoalReached() && weiRaised > 0 && loadedRefund >= weiRaised)
      return State.Refunding;
    return State.Failure;
  }

  
  
  
  function calculateTokens(uint weiAmount) internal returns (uint tokenAmount) {
    var multiplier = 10 ** token.decimals();

    uint usdAmount = weiToUsdCents(weiAmount);
    assert (usdAmount >= PRICE);

    return safeMul(usdAmount, safeDiv(multiplier, PRICE));
  }

   
   
   function isMaximumPreFundingGoalReached() public constant returns (bool reached) {
     return weiToUsdCents(weiRaised) >= PRE_FUNDING_GOAL;
   }

   
   
   
   function weiToUsdCents(uint weiValue) private returns (uint) {
     return safeDiv(safeMul(weiValue, exchangeRate), 1e18);
   }

   
   
   
   function assignTokens(address receiver, uint tokenAmount) private {
     token.mint(receiver, tokenAmount);
   }
}