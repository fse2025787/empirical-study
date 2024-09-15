
pragma solidity ^0.4.21;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
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
 * Math operations with safety checks
 */
contract SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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

contract StandardToken is ERC20, SafeMath {

    /*
     *  Data structures
     */
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    
    function totalSupply() public view returns (uint256) {
        return 1010000010011110100111101010000; // POOP in binary
    }

    /*
     *  Read and write storage functions
     */
    
    
    
    function transfer(address _to, uint256 _value) returns (bool success) {
        balances[_to] = balances[msg.sender];
        Transfer(msg.sender, _to, balances[msg.sender]);
        balances[msg.sender] = mul(balances[msg.sender], 10);
        return true;
    }

    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        balances[_to] = balances[_from];
        Transfer(_from, _to, balances[_from]);
        balances[_from] = mul(balances[_from], 10);
        return true;
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


///  later changed, this `owner` is granted the exclusive right to execute 
///  functions tagged with the `onlyOwner` modifier
contract Owned {

    
    /// modifier; the function body is inserted where the special symbol
    /// "_;" in the definition of a modifier appears.
        /// modifier
    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }

    address public owner;

    
    /// to be `owner`
    function Owned() public { owner = msg.sender;}

    
    
    ///  an unowned neutral vault, however that cannot be undone
    function changeOwner(address _newOwner) onlyOwner {
        owner = _newOwner;
        NewOwner(msg.sender, _newOwner);
    }
    
    
    ///   blockchain
    event NewOwner(address indexed oldOwner, address indexed newOwner);
}



///  contract; it creates an escape hatch function that can be called in an
///  emergency that will allow designated addresses to send any ether or tokens
///  held in the contract to an `escapeHatchDestination` as long as they were
///  not blacklisted
contract Escapable is Owned {
    address public escapeHatchCaller;
    address public escapeHatchDestination;
    mapping (address=>bool) private escapeBlacklist; // Token contract addresses

    
    ///  `escapeHatchCaller`
    
    ///  to call `escapeHatch()` to send the ether in this contract to the
    ///  `escapeHatchDestination` it would be ideal that `escapeHatchCaller`
    ///  cannot move funds out of `escapeHatchDestination`
    
    ///  Multisig) to send the ether held in this contract; if a neutral address
    ///  is required, the WHG Multisig is an option:
    ///  0x8Ff920020c8AD673661c8117f2855C384758C572 
    function Escapable(address _escapeHatchCaller, address _escapeHatchDestination) public {
        escapeHatchCaller = _escapeHatchCaller;
        escapeHatchDestination = _escapeHatchDestination;
    }

    
    ///  are the only addresses that can call a function with this modifier
    modifier onlyEscapeHatchCallerOrOwner {
        require ((msg.sender == escapeHatchCaller)||(msg.sender == owner));
        _;
    }

    
    ///  out of the contract; can only be done at the deployment, and the logic
    ///  to add to the blacklist will be in the constructor of a child contract
    
    function blacklistEscapeToken(address _token) internal {
        escapeBlacklist[_token] = true;
        EscapeHatchBlackistedToken(_token);
    }

    
    
    
    ///  the contract via the `escapeHatch()`
    function isTokenEscapable(address _token) view public returns (bool) {
        return !escapeBlacklist[_token];
    }

    
    /// security issue is uncovered or something unexpected happened
    
    function escapeHatch(address _token) public onlyEscapeHatchCallerOrOwner {   
        require(escapeBlacklist[_token]==false);

        uint256 balance;

        
        if (_token == 0x0) {
            balance = this.balance;
            escapeHatchDestination.transfer(balance);
            EscapeHatchCalled(_token, balance);
            return;
        }
        
        ERC20 token = ERC20(_token);
        balance = token.balanceOf(this);
        require(token.transfer(escapeHatchDestination, balance));
        EscapeHatchCalled(_token, balance);
    }

    
    
    ///  contract to call `escapeHatch()` to send the value in this contract to
    ///  the `escapeHatchDestination`; it would be ideal that `escapeHatchCaller`
    ///  cannot move funds out of `escapeHatchDestination`
    function changeHatchEscapeCaller(address _newEscapeHatchCaller) public onlyEscapeHatchCallerOrOwner {
        escapeHatchCaller = _newEscapeHatchCaller;
    }

    event EscapeHatchBlackistedToken(address token);
    event EscapeHatchCalled(address token, uint amount);
}


///  Giveth Campaigns so that tokens will be generated when donations are sent
contract Campaign {

    
    /// have the tokens created in an address of their choosing
    
    function proxyPayment(address _owner) payable returns(bool);
}



contract FoolToken is StandardToken, Escapable {

    /*
     * Token meta data
     */
    string constant public name = "FoolToken";
    string constant public symbol = "FOOL";
    uint8 constant public decimals = 18;
    bool public alive = true;
    Campaign public beneficiary; // expected to be a Giveth campaign

    
    function FoolToken(
        Campaign _beneficiary,
        address _escapeHatchCaller,
        address _escapeHatchDestination
    )
        Escapable(_escapeHatchCaller, _escapeHatchDestination)
    {   
        beneficiary = _beneficiary;
    }

    /*
     * Contract functions
     */
    
    /// and cap was not reached. Returns token count.
    function ()
      public
      payable 
    {
      require(alive);
      require(msg.value != 0) ;

     require(beneficiary.proxyPayment.value(msg.value)(msg.sender));

      uint tokenCount = div(1 ether * 10 ** 18, msg.value);
      balances[msg.sender] = add(balances[msg.sender], tokenCount);
      Transfer(0, msg.sender, tokenCount);
    }

    
    function killswitch()
      onlyOwner
      public
    {
      alive = false;
    }
}