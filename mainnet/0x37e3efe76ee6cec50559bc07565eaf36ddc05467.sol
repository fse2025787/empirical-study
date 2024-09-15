
pragma solidity ^0.4.11;


contract ERC20 {

  function balanceOf(address who) constant public returns (uint);
  function allowance(address owner, address spender) constant public returns (uint);

  function transfer(address to, uint value) public returns (bool ok);
  function transferFrom(address from, address to, uint value) public returns (bool ok);
  function approve(address spender, uint value) public returns (bool ok);

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);

}





// Controller for Token interface
// Taken from https://github.com/Giveth/minime/blob/master/contracts/MiniMeToken.sol


contract TokenController {
    
    
    
    function proxyPayment(address _owner) payable public returns(bool);

    
    ///  controller to react if desired
    
    
    
    
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

    
    ///  controller to react if desired
    
    
    
    
    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool);
}


contract Controlled {
    
    ///  a function with this modifier
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    function Controlled() public { controller = msg.sender;}

    
    
    function changeController(address _newController) onlyController public {
        controller = _newController;
    }
}


contract ControlledToken is ERC20, Controlled {

    uint256 constant MAX_UINT256 = 2**256 - 1;

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg SBX
    string public version = '1.0';       //human 0.1 standard. Just an arbitrary versioning scheme.
    uint256 public totalSupply;

    function ControlledToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }


    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(balances[msg.sender] >= _value);

        if (isContract(controller)) {
            require(TokenController(controller).onTransfer(msg.sender, _to, _value));
        }

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        // Alerts the token controller of the transfer

        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);

        if (isContract(controller)) {
            require(TokenController(controller).onTransfer(_from, _to, _value));
        }

        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {

        // Alerts the token controller of the approve function call
        if (isContract(controller)) {
            require(TokenController(controller).onApprove(msg.sender, _spender, _value));
        }

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    ////////////////
// Generate and destroy tokens
////////////////

    
    
    
    
    function generateTokens(address _owner, uint _amount ) onlyController returns (bool) {
        uint curTotalSupply = totalSupply;
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        totalSupply = curTotalSupply + _amount;
        balances[_owner]  = previousBalanceTo + _amount;
        Transfer(0, _owner, _amount);
        return true;
    }


    
    
    
    
    function destroyTokens(address _owner, uint _amount
    ) onlyController returns (bool) {
        uint curTotalSupply = totalSupply;
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        totalSupply = curTotalSupply - _amount;
        balances[_owner] = previousBalanceFrom - _amount;
        Transfer(_owner, 0, _amount);
        return true;
    }

    
    ///  set to 0, then the `proxyPayment` method is called which relays the
    ///  ether and creates tokens as described in the token controller contract
    function ()  payable {
        require(isContract(controller));
        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
    }

    
    
    
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    
    ///  sent tokens to this contract.
    
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) onlyController {
        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        ControlledToken token = ControlledToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
    }


    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;


}



/// `Owned` is a base level contract that assigns an `owner` that can be later changed
contract Owned {
    
    /// modifier
    modifier onlyOwner { require (msg.sender == owner); _; }

    address public owner;

    
    function Owned() { owner = msg.sender;}

    
    
    ///  an unowned neutral vault, however that cannot be undone
    function changeOwner(address _newOwner)  onlyOwner {
        owner = _newOwner;
    }
}

/**
 * https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 *
 */
contract SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract TokenSaleAfterSplit is TokenController, Owned, SafeMath {


    uint public startFundingTime;           // In UNIX Time Format
    uint public endFundingTime;             // In UNIX Time Format

    uint public tokenCap;                   // Maximum amount of tokens to be distributed
    uint public totalTokenCount;            // Actual amount of tokens distributed

    uint public totalCollected;             // In wei
    ControlledToken public tokenContract;   // The new token for this TokenSale
    address public vaultAddress;            // The address to hold the funds donated
    bool public transfersAllowed;           // If the token transfers are allowed
    uint256 public exchangeRate;            // USD/ETH rate * 100
    uint public exchangeRateAt;             // Block number when exchange rate was set

    
    /// parameters
    
    
    /// start receiving funds
    
    /// to receive funds
    
    
    
    
    
    function TokenSaleAfterSplit (
        uint _startFundingTime,
        uint _endFundingTime,
        uint _tokenCap,
        address _vaultAddress,
        address _tokenAddress,
        bool _transfersAllowed,
        uint256 _exchangeRate
    ) public {
        require ((_endFundingTime >= now) &&           // Cannot end in the past
            (_endFundingTime > _startFundingTime) &&
            (_vaultAddress != 0));                    // To prevent burning ETH
        startFundingTime = _startFundingTime;
        endFundingTime = _endFundingTime;
        tokenCap = _tokenCap;
        tokenContract = ControlledToken(_tokenAddress);// The Deployed Token Contract
        vaultAddress = _vaultAddress;
        transfersAllowed = _transfersAllowed;
        exchangeRate = _exchangeRate;
        exchangeRateAt = block.number;
    }

    
    /// simply calls `doPayment()` with the address that sent the ether as the
    /// `_owner`. Payable is a required solidity modifier for functions to receive
    /// ether, without this modifier functions will throw if ether is sent to them
    function ()  payable public {
        doPayment(msg.sender);
    }


    
    ///  contract receives to the `vault` and creates tokens in the address of the
    ///  `_owner` assuming the TokenSale is still accepting funds
    

    function doPayment(address _owner) internal {

        // First check that the TokenSale is allowed to receive this donation
        require ((now >= startFundingTime) &&
            (now <= endFundingTime) &&
            (tokenContract.controller() != 0) &&
            (msg.value != 0) );

        uint256 tokensAmount = mul(msg.value, exchangeRate);

        require( totalTokenCount + tokensAmount <= tokenCap );

        //Track how much the TokenSale has collected
        totalCollected += msg.value;

        //Send the ether to the vault
        require (vaultAddress.call.gas(28000).value(msg.value)());

        // Creates an  amount of tokens base on ether sent and exchange rate. The new tokens are created
        //  in the `_owner` address
        require (tokenContract.generateTokens(_owner, tokensAmount));

        totalTokenCount += tokensAmount;

        return;
    }

    function distributeTokens(address[] _owners, uint256[] _tokens) onlyOwner public {

        require( _owners.length == _tokens.length );
        for(uint i=0;i<_owners.length;i++){
            require (tokenContract.generateTokens(_owners[i], _tokens[i]));
        }

    }


    
    
    function setVault(address _newVaultAddress) onlyOwner public{
        vaultAddress = _newVaultAddress;
    }

    
    
    function setTransfersAllowed(bool _allow) onlyOwner public{
        transfersAllowed = _allow;
    }

    
    
    function setExchangeRate(uint256 _exchangeRate) onlyOwner public{
        exchangeRate = _exchangeRate;
        exchangeRateAt = block.number;
    }

    
    
    function changeController(address _newController) onlyOwner public {
        tokenContract.changeController(_newController);
    }

    /////////////////
    // TokenController interface
    /////////////////

    
    /// have the tokens created in an address of their choosing
    

    function proxyPayment(address _owner) payable public returns(bool) {
        doPayment(_owner);
        return true;
    }



    
    ///  transfers are allowed by default and no extra notifications are needed
    
    
    
    
    function onTransfer(address _from, address _to, uint _amount) public returns(bool) {
        return transfersAllowed;
    }

    
    ///  approvals are allowed by default and no extra notifications are needed
    
    
    
    
    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool)
    {
        return transfersAllowed;
    }


}