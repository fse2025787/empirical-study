
pragma solidity ^0.4.25;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}




contract RBACMixin {
  
  string constant FORBIDDEN = "Haven't enough right to access";
  
  mapping (address => bool) public owners;
  
  mapping (address => bool) public minters;

  
  
  event AddOwner(address indexed who);
  
  
  event DeleteOwner(address indexed who);

  
  
  event AddMinter(address indexed who);
  
  
  event DeleteMinter(address indexed who);

  constructor () public {
    _setOwner(msg.sender, true);
  }

  
  modifier onlyOwner() {
    require(isOwner(msg.sender), FORBIDDEN);
    _;
  }

  
  modifier onlyMinter() {
    require(isMinter(msg.sender), FORBIDDEN);
    _;
  }

  
  
  
  function isOwner(address _who) public view returns (bool) {
    return owners[_who];
  }

  
  
  
  function isMinter(address _who) public view returns (bool) {
    return minters[_who];
  }

  
  
  
  
  function addOwner(address _who) public onlyOwner returns (bool) {
    _setOwner(_who, true);
  }

  
  
  
  
  function deleteOwner(address _who) public onlyOwner returns (bool) {
    _setOwner(_who, false);
  }

  
  
  
  
  function addMinter(address _who) public onlyOwner returns (bool) {
    _setMinter(_who, true);
  }

  
  
  
  
  function deleteMinter(address _who) public onlyOwner returns (bool) {
    _setMinter(_who, false);
  }

  
  
  
  
  function _setOwner(address _who, bool _flag) private returns (bool) {
    require(owners[_who] != _flag);
    owners[_who] = _flag;
    if (_flag) {
      emit AddOwner(_who);
    } else {
      emit DeleteOwner(_who);
    }
    return true;
  }

  
  
  
  
  function _setMinter(address _who, bool _flag) private returns (bool) {
    require(minters[_who] != _flag);
    minters[_who] = _flag;
    if (_flag) {
      emit AddMinter(_who);
    } else {
      emit DeleteMinter(_who);
    }
    return true;
  }
}

interface IMintableToken {
  function mint(address _to, uint256 _amount) external returns (bool);
}






contract ICOBucket is RBACMixin {
  using SafeMath for uint;

  
  
  uint256 public size;
  
  
  uint256 public rate;
  
  
  uint256 public lastMintTime;
  
  uint256 public leftOnLastMint;

  
  
  IMintableToken public token;

  
  
  
  event Leak(address indexed to, uint256 left);

  /// ICO SECTION
  
  uint256 public tokenCost;

  
  mapping(address => bool) public whiteList;

  
  address public wallet;

  
  uint256 public bonus;

  
  uint256 public minimumTokensForPurchase;

  
  modifier onlyWhiteList {
      require(whiteList[msg.sender]);
      _;
  }
  /// END ICO SECTION

  
  
  
  constructor (address _token, uint256 _size, uint256 _rate, uint256 _cost, address _wallet, uint256 _bonus, uint256 _minimum) public {
    token = IMintableToken(_token);
    size = _size;
    rate = _rate;
    leftOnLastMint = _size;
    tokenCost = _cost;
    wallet = _wallet;
    bonus = _bonus;
    minimumTokensForPurchase = _minimum;
  }

  
  
  
  
  function setSize(uint256 _size) public onlyOwner returns (bool) {
    size = _size;
    return true;
  }

  
  
  
  
  function setRate(uint256 _rate) public onlyOwner returns (bool) {
    rate = _rate;
    return true;
  }

  
  
  
  
  
  function setSizeAndRate(uint256 _size, uint256 _rate) public onlyOwner returns (bool) {
    return setSize(_size) && setRate(_rate);
  }

  
  
  function availableTokens() public view returns (uint) {
     // solium-disable-next-line security/no-block-members
    uint256 timeAfterMint = now.sub(lastMintTime);
    uint256 refillAmount = rate.mul(timeAfterMint).add(leftOnLastMint);
    return size < refillAmount ? size : refillAmount;
  }

  /// ICO METHODS
  function addToWhiteList(address _address) public onlyMinter {
    whiteList[_address] = true;
  }

  function removeFromWhiteList(address _address) public onlyMinter {
    whiteList[_address] = false;
  }

  function setWallet(address _wallet) public onlyOwner {
    wallet = _wallet;
  }

  function setBonus(uint256 _bonus) public onlyOwner {
    bonus = _bonus;
  }

  function setMinimumTokensForPurchase(uint256 _minimum) public onlyOwner {
    minimumTokensForPurchase = _minimum;
  }

  
  
  function () public payable onlyWhiteList {
    uint256 tokensAmount = tokensAmountForPurchase();
    uint256 available = availableTokens();
    uint256 minimum = minimumTokensForPurchase;
    require(tokensAmount <= available);
    require(tokensAmount >= minimum);
    // transfer all funcds to external multisig wallet
    wallet.transfer(msg.value);
    leftOnLastMint = available.sub(tokensAmount);
    lastMintTime = now; // solium-disable-line security/no-block-members
    require(token.mint(msg.sender, tokensAmount));
  }

  function tokensAmountForPurchase() private constant returns(uint256) {
    return msg.value.mul(10 ** 18)
                    .div(tokenCost)
                    .mul(100 + bonus)
                    .div(100);
  }
}