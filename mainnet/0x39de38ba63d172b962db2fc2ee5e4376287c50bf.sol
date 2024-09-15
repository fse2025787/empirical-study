
pragma solidity ^0.4.15;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {
  function mul(uint256 a, uint256 b) constant internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) constant internal returns (uint256) {
    assert(b != 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) constant internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) constant internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
  function mulByFraction(uint256 number, uint256 numerator, uint256 denominator) internal returns (uint256) {
      return div(mul(number, numerator), denominator);
  }
}


/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20


contract AbstractToken {
    // This is not an abstract function, because solc won't recognize generated getter functions for public variables as functions
    function totalSupply() constant returns (uint256) {}
    function balanceOf(address owner) constant returns (uint256 balance);
    function transfer(address to, uint256 value) returns (bool success);
    function transferFrom(address from, address to, uint256 value) returns (bool success);
    function approve(address spender, uint256 value) returns (bool success);
    function allowance(address owner, address spender) constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Issuance(address indexed to, uint256 value);
}

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


contract ImmlaToken is StandardToken, SafeMath {
    /*
     * Token meta data
     */
    string public constant name = "IMMLA";
    string public constant symbol = "IML";
    uint public constant decimals = 18;
    uint public constant supplyLimit = 550688955000000000000000000;
    
    address public icoContract = 0x0;
    /*
     * Modifiers
     */
    
    modifier onlyIcoContract() {
        // only ICO contract is allowed to proceed
        require(msg.sender == icoContract);
        _;
    }
    
    /*
     * Contract functions
     */
    
    
    
    function ImmlaToken(address _icoContract) {
        assert(_icoContract != 0x0);
        icoContract = _icoContract;
    }
    
    
    
    
    function burnTokens(address _from, uint _value) onlyIcoContract {
        assert(_from != 0x0);
        require(_value > 0);
        
        balances[_from] = sub(balances[_from], _value);
    }
    
    
    
    
    function emitTokens(address _to, uint _value) onlyIcoContract {
        assert(_to != 0x0);
        require(_value > 0);
        
        balances[_to] = add(balances[_to], _value);
    }
}


contract ImmlaIco is SafeMath {
    /*
     * ICO meta data
     */
    ImmlaToken public immlaToken;
    AbstractToken public preIcoToken;

    // Address of account to which ethers will be tranfered in case of successful ICO
    address public escrow;
    // Address of manager
    address public icoManager;
    // Address of a account, that will transfer tokens from pre-ICO
    address public tokenImporter = 0x0;
    // Addresses of founders, team and bountyOwner
    address public founder1;
    address public founder2;
    address public founder3;
    address public team;
    address public bountyOwner;
    
    // 38548226,7 IML is reward for team
    uint public constant teamsReward = 38548226701232220000000000;
    //  9361712,2 IML is token for bountyOwner
    uint public constant bountyOwnersTokens = 9361712198870680000000000;
    
    // BASE = 10^18
    uint constant BASE = 1000000000000000000;
    
    // 2017.09.14 21:00 UTC or 2017.09.15 0:00 MSK
    uint public constant defaultIcoStart = 1505422800;
    // ICO start time
    uint public icoStart = defaultIcoStart;
    
    // 2017.10.15 21:00 UTC or 2017.10.16 0:00 MSK
    uint public constant defaultIcoDeadline = 1508101200;
    // ICO end time
    uint public  icoDeadline = defaultIcoDeadline;
    
    // 2018.03.14 21:00 UTC or 2018.03.15 0:00 MSK
    uint public constant defaultFoundersRewardTime = 1521061200;
    // founders' reward time
    uint public foundersRewardTime = defaultFoundersRewardTime;
    
    // Min limit of tokens is 18 000 000 IML
    uint public constant minIcoTokenLimit = 18000000 * BASE;
    // Max limit of tokens is 434 477 177 IML
    uint public constant maxIcoTokenLimit = 434477177 * BASE;
    
    // Amount of imported tokens from pre-ICO
    uint public importedTokens = 0;
    // Amount of sold tokens on ICO
    uint public soldTokensOnIco = 0;
    // Amount of issued tokens on pre-ICO = 13232941,7 IML
    uint public constant soldTokensOnPreIco = 13232941687168431951684000;
    
    // There are 170053520 tokens in stage 1
    // 1 ETH = 3640 IML
    uint tokenPrice1 = 3640;
    uint tokenSupply1 = 170053520 * BASE;
    
    // There are 103725856 tokens in stage 2
    // 1 ETH = 3549 IML
    uint tokenPrice2 = 3549;
    uint tokenSupply2 = 103725856 * BASE;
    
    // There are 100319718 tokens in stage 3
    // 1 ETH = 3458 IML
    uint tokenPrice3 = 3458;
    uint tokenSupply3 = 100319718 * BASE;
    
    // There are 60378083 tokens in stage 4
    // 1 ETH = 3367 IML
    uint tokenPrice4 = 3367;
    uint tokenSupply4 = 60378083 * BASE;
    
    // Token's prices in stages in array
    uint[] public tokenPrices;
    // Token's remaining amounts in stages in array
    uint[] public tokenSupplies;
    
    // Check if manager can be setted
    bool public initialized = false;
    // If flag migrated=false, token can be burned
    bool public migrated = false;
    // Tokens to founders can be sent only if sentTokensToFounders == false and time > foundersRewardTime
    bool public sentTokensToFounders = false;
    // If stopICO is called, then ICO 
    bool public icoStoppedManually = false;
    
    // mapping of ether balances info
    mapping (address => uint) public balances;
    
    /*
     * Events
     */
    
    event BuyTokens(address buyer, uint value, uint amount);
    event WithdrawEther();
    event StopIcoManually();
    event SendTokensToFounders(uint founder1Reward, uint founder2Reward, uint founder3Reward);
    event ReturnFundsFor(address account);
    
    /*
     * Modifiers
     */
    
    modifier whenInitialized() {
        // only when contract is initialized
        require(initialized);
        _;
    } 
    
    modifier onlyManager() {
        // only ICO manager can do this action
        require(msg.sender == icoManager);
        _;
    }
    
    modifier onIcoRunning() {
        // Checks, if ICO is running and has not been stopped
        require(!icoStoppedManually && now >= icoStart && now <= icoDeadline);
        _;
    }
    
    modifier onGoalAchievedOrDeadline() {
        // Checks if amount of sold tokens >= min limit or deadline is reached
        require(soldTokensOnIco >= minIcoTokenLimit || now > icoDeadline || icoStoppedManually);
        _;
    }
    
    modifier onIcoStopped() {
        // Checks if ICO was stopped or deadline is reached
        require(icoStoppedManually || now > icoDeadline);
        _;
    }
    
    modifier notMigrated() {
        // Checks if base can be migrated
        require(!migrated);
        _;
    }
    
    
    /// address of preIcoToken, time of start ICO (or zero),
    /// time of ICO deadline (or zero), founders' reward time (or zero)
    
    
    
    
    
    /// (if equals 0, sets defaultFoundersRewardTime)
    function ImmlaIco(address _icoManager, address _preIcoToken, 
        uint _icoStart, uint _icoDeadline, uint _foundersRewardTime) {
        assert(_preIcoToken != 0x0);
        assert(_icoManager != 0x0);
        
        immlaToken = new ImmlaToken(this);
        icoManager = _icoManager;
        preIcoToken = AbstractToken(_preIcoToken);
        
        if (_icoStart != 0) {
            icoStart = _icoStart;
        }
        if (_icoDeadline != 0) {
            icoDeadline = _icoDeadline;
        }
        if (_foundersRewardTime != 0) {
            foundersRewardTime = _foundersRewardTime;
        }
        
        // tokenPrices and tokenSupplies arrays initialisation
        tokenPrices.push(tokenPrice1);
        tokenPrices.push(tokenPrice2);
        tokenPrices.push(tokenPrice3);
        tokenPrices.push(tokenPrice4);
        
        tokenSupplies.push(tokenSupply1);
        tokenSupplies.push(tokenSupply2);
        tokenSupplies.push(tokenSupply3);
        tokenSupplies.push(tokenSupply4);
    }
    
    
    /// Initialises balances of team and tokens owner
    
    
    
    
    
    
    function init(
        address _founder1, address _founder2, address _founder3, 
        address _team, address _bountyOwner, address _escrow) onlyManager {
        assert(!initialized);
        assert(_founder1 != 0x0);
        assert(_founder2 != 0x0);
        assert(_founder3 != 0x0);
        assert(_team != 0x0);
        assert(_bountyOwner != 0x0);
        assert(_escrow != 0x0);
        
        founder1 = _founder1;
        founder2 = _founder2;
        founder3 = _founder3;
        team = _team;
        bountyOwner = _bountyOwner;
        escrow = _escrow;
        
        immlaToken.emitTokens(team, teamsReward);
        immlaToken.emitTokens(bountyOwner, bountyOwnersTokens);
        
        initialized = true;
    }
    
    
    
    function setNewManager(address _newIcoManager) onlyManager {
        assert(_newIcoManager != 0x0);
        
        icoManager = _newIcoManager;
    }
    
    
    
    function setNewTokenImporter(address _newTokenImporter) onlyManager {
        tokenImporter = _newTokenImporter;
    } 
    
    // saves info if account's tokens were imported from pre-ICO
    mapping (address => bool) private importedFromPreIco;
    
    
    function importTokens(address _account) {
        // only tokens holder or manager or tokenImporter can do migration
        require(msg.sender == tokenImporter || msg.sender == icoManager || msg.sender == _account);
        require(!importedFromPreIco[_account]);
        
        uint preIcoBalance = preIcoToken.balanceOf(_account);
        if (preIcoBalance > 0) {
            immlaToken.emitTokens(_account, preIcoBalance);

        }
        

    }
    
    
    function stopIco() onlyManager /* onGoalAchievedOrDeadline */ {
        icoStoppedManually = true;
        StopIcoManually();
    }
    
    
    function withdrawEther() onGoalAchievedOrDeadline {
        if (soldTokensOnIco >= minIcoTokenLimit) {
            assert(initialized);
            assert(this.balance > 0);
            assert(msg.sender == icoManager);
            
            escrow.transfer(this.balance);
            WithdrawEther();
        } 
        else {
            returnFundsFor(msg.sender);
        }
    }
    
    
    
    function returnFundsFor(address _account) onGoalAchievedOrDeadline {
        assert(msg.sender == address(this) || msg.sender == icoManager || msg.sender == _account);
        assert(soldTokensOnIco < minIcoTokenLimit);
        assert(balances[_account] > 0);
        
        _account.transfer(balances[_account]);
        balances[_account] = 0;
        
        ReturnFundsFor(_account);
    }
    
    
    
    function countTokens(uint _weis) private returns(uint) { 
        uint result = 0;
        uint stage;
        for (stage = 0; stage < 4; stage++) {
            if (_weis == 0) {
                break;
            }
            if (tokenSupplies[stage] == 0) {
                continue;
            }
            uint maxTokenAmount = tokenPrices[stage] * _weis;
            if (maxTokenAmount <= tokenSupplies[stage]) {
                result = add(result, maxTokenAmount);
                break;
            }
            result = add(result, tokenSupplies[stage]);
            _weis = sub(_weis, div(tokenSupplies[stage], tokenPrices[stage]));
        }
        
        if (stage == 4) {
            result = add(result, tokenPrices[3] * _weis);
        }
        
        return result;
    }
    
    
    
    function removeTokens(uint _amount) private {
        for (uint i = 0; i < 4; i++) {
            if (_amount == 0) {
                break;
            }
            if (tokenSupplies[i] > _amount) {
                tokenSupplies[i] = sub(tokenSupplies[i], _amount);
                break;
            }
            _amount = sub(_amount, tokenSupplies[i]);
            tokenSupplies[i] = 0;
        }
    }
    
    
    
    function buyTokens(address _buyer) private {
        assert(_buyer != 0x0);
        require(msg.value > 0);
        require(soldTokensOnIco < maxIcoTokenLimit);
        
        uint boughtTokens = countTokens(msg.value);
        assert(add(soldTokensOnIco, boughtTokens) <= maxIcoTokenLimit);
        
        removeTokens(boughtTokens);
        soldTokensOnIco = add(soldTokensOnIco, boughtTokens);
        immlaToken.emitTokens(_buyer, boughtTokens);
        
        balances[_buyer] = add(balances[_buyer], msg.value);
        
        BuyTokens(_buyer, msg.value, boughtTokens);
    }
    
    
    function () payable onIcoRunning {
        buyTokens(msg.sender);
    }
    
    
    
    function burnTokens(address _from, uint _value) onlyManager notMigrated {
        immlaToken.burnTokens(_from, _value);
    }
    
    
    function setStateMigrated() onlyManager {
        migrated = true;
    }
    
    
    /// Sends 43% * 10% of all tokens to founder 1
    /// Sends 43% * 10% of all tokens to founder 2
    /// Sends 14% * 10% of all tokens to founder 3
    function sendTokensToFounders() onlyManager whenInitialized {
        require(!sentTokensToFounders && now >= foundersRewardTime);
        
        // soldTokensOnPreIco + soldTokensOnIco is ~81.3% of tokens 
        uint totalCountOfTokens = mulByFraction(add(soldTokensOnIco, soldTokensOnPreIco), 1000, 813);
        uint totalRewardToFounders = mulByFraction(totalCountOfTokens, 1, 10);
        
        uint founder1Reward = mulByFraction(totalRewardToFounders, 43, 100);
        uint founder2Reward = mulByFraction(totalRewardToFounders, 43, 100);
        uint founder3Reward = mulByFraction(totalRewardToFounders, 14, 100);
        immlaToken.emitTokens(founder1, founder1Reward);
        immlaToken.emitTokens(founder2, founder2Reward);
        immlaToken.emitTokens(founder3, founder3Reward);
        SendTokensToFounders(founder1Reward, founder2Reward, founder3Reward);
        sentTokensToFounders = true;
    }
}