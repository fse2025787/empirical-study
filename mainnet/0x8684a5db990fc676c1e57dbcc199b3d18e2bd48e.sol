
pragma solidity ^0.4.18;

// File: contracts/Ownable.sol



/// this simplifies the implementation of "user permissions".


contract Ownable {
    address public owner;
    address public newOwnerCandidate;

    event OwnershipRequested(address indexed by, address indexed to);
    event OwnershipTransferred(address indexed from, address indexed to);

    
    function Ownable() public {
        owner = msg.sender;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwnerCandidate() {
        require(msg.sender == newOwnerCandidate);
        _;
    }

    
    
    function requestOwnershipTransfer(address _newOwnerCandidate) external onlyOwner {
        require(_newOwnerCandidate != address(0));

        newOwnerCandidate = _newOwnerCandidate;

        OwnershipRequested(msg.sender, newOwnerCandidate);
    }

    
    function acceptOwnership() external onlyOwnerCandidate {
        address previousOwner = owner;

        owner = newOwnerCandidate;
        newOwnerCandidate = address(0);

        OwnershipTransferred(previousOwner, owner);
    }
}

// File: contracts/SafeMath.sol


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // require(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // require(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function toPower2(uint256 a) internal pure returns (uint256) {
        return mul(a, a);
    }

    function sqrt(uint256 a) internal pure returns (uint256) {
        uint256 c = (a + 1) / 2;
        uint256 b = a;
        while (c < b) {
            b = c;
            c = (a / c + c) / 2;
        }
        return b;
    }
}

// File: contracts/ERC20.sol


contract ERC20 {
    uint public totalSupply;
    function balanceOf(address _owner) constant public returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint remaining);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

// File: contracts/BasicToken.sol



contract BasicToken is ERC20 {
    using SafeMath for uint256;

    uint256 public totalSupply;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) balances;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    
    
    function approve(address _spender, uint256 _value) public returns (bool) {
        // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approve (see NOTE)
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
            revert();
        }

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }

    
    
    
    
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }


    
    
    
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }

    
    
    
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;
    }

    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        uint256 _allowance = allowed[_from][msg.sender];

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = _allowance.sub(_value);

        Transfer(_from, _to, _value);

        return true;
    }
}

// File: contracts/ERC223Receiver.sol



contract ERC223Receiver {
    function tokenFallback(address _sender, uint _value, bytes _data) external returns (bool ok);
}

// File: contracts/ERC677.sol


contract ERC677 is ERC20 {
    function transferAndCall(address to, uint value, bytes data) public returns (bool ok);

    event TransferAndCall(address indexed from, address indexed to, uint value, bytes data);
}

// File: contracts/Standard677Token.sol



contract Standard677Token is ERC677, BasicToken {

  
  
  
  
  function transferAndCall(address _to, uint _value, bytes _data) public returns (bool) {
    require(super.transfer(_to, _value)); // do a normal token transfer
    TransferAndCall(msg.sender, _to, _value, _data);
    //filtering if the target is a contract with bytecode inside it
    if (isContract(_to)) return contractFallback(_to, _value, _data);
    return true;
  }

  
  
  
  
  function contractFallback(address _to, uint _value, bytes _data) private returns (bool) {
    ERC223Receiver receiver = ERC223Receiver(_to);
    require(receiver.tokenFallback(msg.sender, _value, _data));
    return true;
  }

  
  /// assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  
  function isContract(address _addr) private constant returns (bool is_contract) {
    // retrieve the size of the code on target address, this needs assembly
    uint length;
    assembly { length := extcodesize(_addr) }
    return length > 0;
  }
}

// File: contracts/TokenHolder.sol


contract TokenHolder is Ownable {
    
    
    
    function transferAnyERC20Token(address _tokenAddress, uint256 _amount) public onlyOwner returns (bool success) {
        return ERC20(_tokenAddress).transfer(owner, _amount);
    }
}

// File: contracts/ColuLocalCurrency.sol



contract ColuLocalCurrency is Ownable, Standard677Token, TokenHolder {
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8 public decimals;
    string public tokenURI;

    event TokenURIChanged(string newTokenURI);

    
    
    
    
    
    
    function ColuLocalCurrency(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply, string _tokenURI) public {
        require(_totalSupply != 0);
        require(bytes(_name).length != 0);
        require(bytes(_symbol).length != 0);

        totalSupply = _totalSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        tokenURI = _tokenURI;
        balances[msg.sender] = totalSupply;
    }

    
    
    function setTokenURI(string _tokenURI) public onlyOwner {
      tokenURI = _tokenURI;
      TokenURIChanged(_tokenURI);
    }
}

// File: contracts/Standard223Receiver.sol



contract Standard223Receiver is ERC223Receiver {
  Tkn tkn;

  struct Tkn {
    address addr;
    address sender; // the transaction caller
    uint256 value;
  }

  bool __isTokenFallback;

  modifier tokenPayable {
    require(__isTokenFallback);
    _;
  }

  
  
  
  
  function tokenFallback(address _sender, uint _value, bytes _data) external returns (bool ok) {
    if (!supportsToken(msg.sender)) {
      return false;
    }

    // Problem: This will do a sstore which is expensive gas wise. Find a way to keep it in memory.
    // Solution: Remove the the data
    tkn = Tkn(msg.sender, _sender, _value);
    __isTokenFallback = true;
    if (!address(this).delegatecall(_data)) {
      __isTokenFallback = false;
      return false;
    }
    // avoid doing an overwrite to .token, which would be more expensive
    // makes accessing .tkn values outside tokenPayable functions unsafe
    __isTokenFallback = false;

    return true;
  }

  function supportsToken(address token) public constant returns (bool);
}

// File: contracts/TokenOwnable.sol




contract TokenOwnable is Standard223Receiver, Ownable {
    
    modifier onlyTokenOwner() {
        require(tkn.sender == owner);
        _;
    }
}

// File: contracts/EllipseMarketMaker.sol




contract EllipseMarketMaker is TokenOwnable {

  // precision for price representation (as in ether or tokens).
  uint256 public constant PRECISION = 10 ** 18;

  // The tokens pair.
  ERC20 public token1;
  ERC20 public token2;

  // The tokens reserves.
  uint256 public R1;
  uint256 public R2;

  // The tokens full suplly.
  uint256 public S1;
  uint256 public S2;

  // State flags.
  bool public operational;
  bool public openForPublic;

  // Library contract address.
  address public mmLib;

  
  function EllipseMarketMaker(address _mmLib, address _token1, address _token2) public {
    require(_mmLib != address(0));
    // Signature of the mmLib's constructor function
    // bytes4 sig = bytes4(keccak256("constructor(address,address,address)"));
    bytes4 sig = 0x6dd23b5b;

    // 3 arguments of size 32
    uint256 argsSize = 3 * 32;
    // sig + arguments size
    uint256 dataSize = 4 + argsSize;


    bytes memory m_data = new bytes(dataSize);

    assembly {
        // Add the signature first to memory
        mstore(add(m_data, 0x20), sig)
        // Add the parameters
        mstore(add(m_data, 0x24), _mmLib)
        mstore(add(m_data, 0x44), _token1)
        mstore(add(m_data, 0x64), _token2)
    }

    // delegatecall to the library contract
    require(_mmLib.delegatecall(m_data));
  }

  
  
  function supportsToken(address token) public constant returns (bool) {
    return (token1 == token || token2 == token);
  }

  
  function() public {
    address _mmLib = mmLib;
    if (msg.data.length > 0) {
      assembly {
        calldatacopy(0xff, 0, calldatasize)
        let retVal := delegatecall(gas, _mmLib, 0xff, calldatasize, 0, 0x20)
        switch retVal case 0 { revert(0,0) } default { return(0, 0x20) }
      }
    }
  }
}

// File: contracts/MarketMaker.sol



contract MarketMaker is ERC223Receiver {

  function getCurrentPrice() public constant returns (uint _price);
  function change(address _fromToken, uint _amount, address _toToken) public returns (uint _returnAmount);
  function change(address _fromToken, uint _amount, address _toToken, uint _minReturn) public returns (uint _returnAmount);
  function change(address _toToken) public returns (uint _returnAmount);
  function change(address _toToken, uint _minReturn) public returns (uint _returnAmount);
  function quote(address _fromToken, uint _amount, address _toToken) public constant returns (uint _returnAmount);
  function openForPublicTrade() public returns (bool success);
  function isOpenForPublic() public returns (bool success);

  event Change(address indexed fromToken, uint inAmount, address indexed toToken, uint returnAmount, address indexed account);
}

// File: contracts/IEllipseMarketMaker.sol



contract IEllipseMarketMaker is MarketMaker {

    // precision for price representation (as in ether or tokens).
    uint256 public constant PRECISION = 10 ** 18;

    // The tokens pair.
    ERC20 public token1;
    ERC20 public token2;

    // The tokens reserves.
    uint256 public R1;
    uint256 public R2;

    // The tokens full suplly.
    uint256 public S1;
    uint256 public S2;

    // State flags.
    bool public operational;
    bool public openForPublic;

    // Library contract address.
    address public mmLib;

    function supportsToken(address token) public constant returns (bool);

    function calcReserve(uint256 _R1, uint256 _S1, uint256 _S2) public pure returns (uint256);

    function validateReserves() public view returns (bool);

    function withdrawExcessReserves() public returns (uint256);

    function initializeAfterTransfer() public returns (bool);

    function initializeOnTransfer() public returns (bool);

    function getPrice(uint256 _R1, uint256 _R2, uint256 _S1, uint256 _S2) public constant returns (uint256);
}

// File: contracts/CurrencyFactory.sol



contract CurrencyFactory is Standard223Receiver, TokenHolder {

  struct CurrencyStruct {
    string name;
    uint8 decimals;
    uint256 totalSupply;
    address owner;
    address mmAddress;
  }


  // map of Market Maker owners: token address => currency struct
  mapping (address => CurrencyStruct) public currencyMap;
  // address of the deployed CLN contract (ERC20 Token)
  address public clnAddress;
  // address of the deployed elipse market maker contract
  address public mmLibAddress;

  address[] public tokens;

  event MarketOpen(address indexed marketMaker);
  event TokenCreated(address indexed token, address indexed owner);

  // modifier to check if called by issuer of the token
  modifier tokenIssuerOnly(address token, address owner) {
    require(currencyMap[token].owner == owner);
    _;
  }
  // modifier to only accept transferAndCall from CLN token
  modifier CLNOnly() {
    require(msg.sender == clnAddress);
    _;
  }

  
  
  modifier marketClosed(address _token) {
  	require(!MarketMaker(currencyMap[_token].mmAddress).isOpenForPublic());
  	_;
  }

  
  
  modifier marketOpen(address _token) {
    require(MarketMaker(currencyMap[_token].mmAddress).isOpenForPublic());
    _;
  }

  
  
  
  function CurrencyFactory(address _mmLib, address _clnAddress) public {
  	require(_mmLib != address(0));
  	require(_clnAddress != address(0));
  	mmLibAddress = _mmLib;
  	clnAddress = _clnAddress;
  }

  
  
  
  
  
  
  function createCurrency(string _name,
                          string _symbol,
                          uint8 _decimals,
                          uint256 _totalSupply,
                          string _tokenURI) public
                          returns (address) {

  	ColuLocalCurrency subToken = new ColuLocalCurrency(_name, _symbol, _decimals, _totalSupply, _tokenURI);
  	EllipseMarketMaker newMarketMaker = new EllipseMarketMaker(mmLibAddress, clnAddress, subToken);
  	//set allowance
  	require(subToken.transfer(newMarketMaker, _totalSupply));
  	require(IEllipseMarketMaker(newMarketMaker).initializeAfterTransfer());
  	currencyMap[subToken] = CurrencyStruct({ name: _name, decimals: _decimals, totalSupply: _totalSupply, mmAddress: newMarketMaker, owner: msg.sender});
    tokens.push(subToken);
  	TokenCreated(subToken, msg.sender);
  	return subToken;
  }

  
  
  
  
  
  function createCurrency(string _name,
                          string _symbol,
                          uint8 _decimals,
                          uint256 _totalSupply) public
                          returns (address) {
    return createCurrency(_name, _symbol, _decimals, _totalSupply, '');
  }

  
  
  
  
  function insertCLNtoMarketMaker(address _token,
                                  uint256 _clnAmount) public
                                  tokenIssuerOnly(_token, msg.sender)
                                  returns (uint256 _subTokenAmount) {
  	require(_clnAmount > 0);
  	address marketMakerAddress = getMarketMakerAddressFromToken(_token);
  	require(ERC20(clnAddress).transferFrom(msg.sender, this, _clnAmount));
  	require(ERC20(clnAddress).approve(marketMakerAddress, _clnAmount));
  	_subTokenAmount = IEllipseMarketMaker(marketMakerAddress).change(clnAddress, _clnAmount, _token);
    require(ERC20(_token).transfer(msg.sender, _subTokenAmount));
  }

  
  
  
  function insertCLNtoMarketMaker(address _token) public
                                  tokenPayable
                                  CLNOnly
                                  tokenIssuerOnly(_token, tkn.sender)
                                  returns (uint256 _subTokenAmount) {
  	address marketMakerAddress = getMarketMakerAddressFromToken(_token);
  	require(ERC20(clnAddress).approve(marketMakerAddress, tkn.value));
  	_subTokenAmount = IEllipseMarketMaker(marketMakerAddress).change(clnAddress, tkn.value, _token);
    require(ERC20(_token).transfer(tkn.sender, _subTokenAmount));
  }

  
  
  
  
  function extractCLNfromMarketMaker(address _token,
                                     uint256 _ccAmount) public
                                     tokenIssuerOnly(_token, msg.sender)
                                     returns (uint256 _clnTokenAmount) {
  	address marketMakerAddress = getMarketMakerAddressFromToken(_token);
  	require(ERC20(_token).transferFrom(msg.sender, this, _ccAmount));
  	require(ERC20(_token).approve(marketMakerAddress, _ccAmount));
  	_clnTokenAmount = IEllipseMarketMaker(marketMakerAddress).change(_token, _ccAmount, clnAddress);
  	require(ERC20(clnAddress).transfer(msg.sender, _clnTokenAmount));
  }

  
  
  function extractCLNfromMarketMaker() public
                                    tokenPayable
                                    tokenIssuerOnly(msg.sender, tkn.sender)
                                    returns (uint256 _clnTokenAmount) {
  	address marketMakerAddress = getMarketMakerAddressFromToken(msg.sender);
  	require(ERC20(msg.sender).approve(marketMakerAddress, tkn.value));
  	_clnTokenAmount = IEllipseMarketMaker(marketMakerAddress).change(msg.sender, tkn.value, clnAddress);
  	require(ERC20(clnAddress).transfer(tkn.sender, _clnTokenAmount));
  }

  
  
  
  function openMarket(address _token) public
                      tokenIssuerOnly(_token, msg.sender)
                      returns (bool) {
  	address marketMakerAddress = getMarketMakerAddressFromToken(_token);
  	require(MarketMaker(marketMakerAddress).openForPublicTrade());
  	Ownable(marketMakerAddress).requestOwnershipTransfer(msg.sender);
    Ownable(_token).requestOwnershipTransfer(msg.sender);
  	MarketOpen(marketMakerAddress);
  	return true;
  }

  
  
  function supportsToken(address _token) public constant returns (bool) {
  	return (clnAddress == _token || currencyMap[_token].totalSupply > 0);
  }

  
  
  
  function setTokenURI(address _token, string _tokenURI) public
                              tokenIssuerOnly(_token, msg.sender)
                              marketClosed(_token)
                              returns (bool) {
    ColuLocalCurrency(_token).setTokenURI(_tokenURI);
    return true;
  }

  
  
  function getMarketMakerAddressFromToken(address _token) public constant returns (address _marketMakerAddress) {
  	_marketMakerAddress = currencyMap[_token].mmAddress;
    require(_marketMakerAddress != address(0));
  }
}