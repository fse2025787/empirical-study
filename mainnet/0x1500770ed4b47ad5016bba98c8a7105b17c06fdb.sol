
pragma solidity ^0.4.18;

contract Token {

    
    function totalSupply() constant returns (uint256 supply) {}

    
    
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    
    
    
    
    function transfer(address _to, uint256 _value) returns (bool success) {}

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    
    
    
    
    function approve(address _spender, uint256 _value) returns (bool success) {}

    
    
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/*
This implements ONLY the standard functions and NOTHING else.
For a token like you would want to deploy in something like Mist, see HumanStandardToken.sol.

If you deploy this, you won't have anything useful.

Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
.*/

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

/*
This Token Contract implements the standard token functionality (https://github.com/ethereum/EIPs/issues/20) as well as the following OPTIONAL extras intended for use by humans.

In other words. This is intended for deployment in something like a Token Factory or Mist wallet, and then used by humans.
Imagine coins, currencies, shares, voting weight, etc.
Machine-based, rapid creation of many tokens would not necessarily need these extra features or will be minted in other manners.

1) Initial Finite Supply (upon creation one specifies how much is minted).
2) In the absence of a token registry: Optional Decimal, Symbol & Name.
3) Optional approveAndCall() functionality to notify a contract if an approval() has occurred.

.*/

contract HumanStandardToken is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

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
    string public version = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

    function HumanStandardToken(
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

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        
        return true;
    }

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



contract TokenSwap is Ownable {

    /* neverdie token contract address and its instance, can be set by owner only */
    HumanStandardToken public ndc;
    /* neverdie token contract address and its instance, can be set by owner only */
    HumanStandardToken public tpt;
    /* signer address, verified in 'swap' method, can be set by owner only */
    address public neverdieSigner;
    /* minimal amount for swap, the amount passed to 'swap method can't be smaller
       than this value, can be set by owner only */
    uint256 public minSwapAmount = 40;

    event Swap(
        address indexed to,
        address indexed PTaddress,
        uint256 rate,
        uint256 amount,
        uint256 ptAmount
    );

    event BuyNDC(
        address indexed to,
        uint256 NDCprice,
        uint256 value,
        uint256 amount
    );

    event BuyTPT(
        address indexed to,
        uint256 TPTprice,
        uint256 value,
        uint256 amount
    );

    
    /// NOTE: min swap amount is left with default value, set it manually if needed
    
    
    
    function TokenSwap(address _teleportContractAddress, address _neverdieContractAddress, address _signer) public {
        tpt = HumanStandardToken(_teleportContractAddress);
        ndc = HumanStandardToken(_neverdieContractAddress);
        neverdieSigner = _signer;
    }

    function setTeleportContractAddress(address _to) external onlyOwner {
        tpt = HumanStandardToken(_to);
    }

    function setNeverdieContractAddress(address _to) external onlyOwner {
        ndc = HumanStandardToken(_to);
    }

    function setNeverdieSignerAddress(address _to) external onlyOwner {
        neverdieSigner = _to;
    }

    function setMinSwapAmount(uint256 _amount) external onlyOwner {
        minSwapAmount = _amount;
    }

    
    
    
    
    
    function receiveApproval(address _sender, uint256 _value, address _tokenContract, bytes _extraData) external {
        require(_tokenContract == address(ndc));
        assert(this.call(_extraData));
    }

    

    
    
    
    ///              of purchasable tokens equals to (_amount * _rate) / 1000
    
    
    
    
    
    
    function swapFor(address _spender,
                     uint256 _rate,
                     address _PTaddress,
                     uint256 _amount,
                     uint256 _expiration,
                     uint8 _v,
                     bytes32 _r,
                     bytes32 _s) public {

        // Check if the signature did not expire yet by inspecting the timestamp
        require(_expiration >= block.timestamp);

        // Check if the signature is coming from the neverdie signer address
        address signer = ecrecover(keccak256(_spender, _rate, _PTaddress, _amount, _expiration), _v, _r, _s);
        require(signer == neverdieSigner);

        // Check if the amount of NDC is higher than the minimum amount 
        require(_amount >= minSwapAmount);
       
        // Check that we hold enough tokens
        HumanStandardToken ptoken = HumanStandardToken(_PTaddress);
        uint256 ptAmount;
        uint8 decimals = ptoken.decimals();
        if (decimals <= 18) {
          ptAmount = SafeMath.div(SafeMath.div(SafeMath.mul(_amount, _rate), 1000), 10**(uint256(18 - decimals)));
        } else {
          ptAmount = SafeMath.div(SafeMath.mul(SafeMath.mul(_amount, _rate), 10**(uint256(decimals - 18))), 1000);
        }

        assert(ndc.transferFrom(_spender, this, _amount) && ptoken.transfer(_spender, ptAmount));

        // Emit Swap event
        Swap(_spender, _PTaddress, _rate, _amount, ptAmount);
    }

    
    
    
    
    
    
    
    
    function swap(uint256 _rate,
                  address _PTaddress,
                  uint256 _amount,
                  uint256 _expiration,
                  uint8 _v,
                  bytes32 _r,
                  bytes32 _s) external {
        swapFor(msg.sender, _rate, _PTaddress, _amount, _expiration, _v, _r, _s);
    }

    
    
    
    
    
    
    function buyNDC(uint256 _NDCprice,
                    uint256 _expiration,
                    uint8 _v,
                    bytes32 _r,
                    bytes32 _s
                   ) payable external {
        // Check if the signature did not expire yet by inspecting the timestamp
        require(_expiration >= block.timestamp);

        // Check if the signature is coming from the neverdie address
        address signer = ecrecover(keccak256(_NDCprice, _expiration), _v, _r, _s);
        require(signer == neverdieSigner);

        uint256 a = SafeMath.div(SafeMath.mul(msg.value, 10**18), _NDCprice);
        assert(ndc.transfer(msg.sender, a));

        // Emit BuyNDC event
        BuyNDC(msg.sender, _NDCprice, msg.value, a);
    }

    
    
    
    
    
    
    function buyTPT(uint256 _TPTprice,
                    uint256 _expiration,
                    uint8 _v,
                    bytes32 _r,
                    bytes32 _s
                   ) payable external {
        // Check if the signature did not expire yet by inspecting the timestamp
        require(_expiration >= block.timestamp);

        // Check if the signature is coming from the neverdie address
        address signer = ecrecover(keccak256(_TPTprice, _expiration), _v, _r, _s);
        require(signer == neverdieSigner);

        uint256 a = SafeMath.div(SafeMath.mul(msg.value, 10**18), _TPTprice);
        assert(tpt.transfer(msg.sender, a));

        // Emit BuyNDC event
        BuyTPT(msg.sender, _TPTprice, msg.value, a);
    }

    
    function () payable public { 
        revert(); 
    }

    
    function withdrawEther() external onlyOwner {
        owner.transfer(this.balance);
    }

    
    
    function withdraw(address _tokenContract) external onlyOwner {
        ERC20 token = ERC20(_tokenContract);
        uint256 balance = token.balanceOf(this);
        assert(token.transfer(owner, balance));
    }

    
    function kill() onlyOwner public {
        uint256 allNDC = ndc.balanceOf(this);
        uint256 allTPT = tpt.balanceOf(this);
        assert(ndc.transfer(owner, allNDC) && tpt.transfer(owner, allTPT));
        selfdestruct(owner);
    }

}