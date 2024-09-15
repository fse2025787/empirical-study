
pragma solidity ^0.4.18;

contract TokenRecipient {
  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; 
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

contract ExtraHolderContract is TokenRecipient {
  using SafeMath for uint;

  
  
  mapping(address => uint) public shares;

  
  mapping(address => uint) public totalAtWithdrawal;

  
  
  address public holdingToken;

  
  uint public totalReceived;

  
  
  
  
  
  
  function ExtraHolderContract(
    address _holdingToken,
    address[] _recipients,
    uint[] _partions)
  public
  {
    require(_holdingToken != address(0x0));
    require(_recipients.length > 0);
    require(_recipients.length == _partions.length);

    uint ensureFullfield;

    for(uint index = 0; index < _recipients.length; index++) {
      // overflow check isn't required.. I suppose :D
      ensureFullfield = ensureFullfield + _partions[index];
      require(_partions[index] > 0);
      require(_recipients[index] != address(0x0));

      shares[_recipients[index]] = _partions[index];
    }

    holdingToken = _holdingToken;

    // Require to setup exact 100% sum of partions
    require(ensureFullfield == 10000);
  }

  
  
  
  
  
  
  function receiveApproval(
    address _from, 
    uint256 _value,
    address _token,
    bytes _extraData) public
  {
    _extraData;
    require(_token == holdingToken);

    // Take tokens of fail with exception
    ERC20(holdingToken).transferFrom(_from, address(this), _value);
    totalReceived = totalReceived.add(_value);
  }

  
  
  
  function withdraw(
    address _recipient)
  public returns (bool) 
  {
    require(shares[_recipient] > 0);
    require(totalAtWithdrawal[_recipient] < totalReceived);

    uint left = totalReceived.sub(totalAtWithdrawal[_recipient]);
    uint share = left.mul(shares[_recipient]).div(10000);
    totalAtWithdrawal[_recipient] = totalReceived;
    ERC20(holdingToken).transfer(_recipient, share);
    return true;
  }
}

contract AltExtraHolderContract is ExtraHolderContract {
  address[] private altRecipients = [
    // Transfer two percent of all ALT tokens to bounty program participants on the day of tokens issue.
    // Final distribution will be done by our partner Bountyhive.io who will transfer coins from
    // the provided wallet to all bounty hunters community.
    address(0xd251D75064DacBC5FcCFca91Cb4721B163a159fc),
    // Transfer thirty eight percent of all ALT tokens for future Network Growth and Team and Advisors remunerations.
    address(0xAd089b3767cf58c7647Db2E8d9C049583bEA045A)
  ];
  uint[] private altPartions = [
    500,
    9500
  ];

  function AltExtraHolderContract(address _holdingToken)
    ExtraHolderContract(_holdingToken, altRecipients, altPartions)
    public
  {}
}