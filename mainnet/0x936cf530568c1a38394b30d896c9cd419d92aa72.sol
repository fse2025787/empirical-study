
pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract owned {
    address public Owner; 

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */    
    function owned() public{
        Owner = msg.sender;
    }
    
  /**
   * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner(){
        require(msg.sender == Owner);
        _;
    }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */   
    function TransferOwnership(address newOwner) onlyOwner public {
        Owner = newOwner;
    }
    
  /**
   * @dev Terminates contract when called by the owner.
   */
    function abort() onlyOwner public {
        selfdestruct(Owner);
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract ZegartToken is owned {
    // Public variables of the token
    string public name;
    string public symbol;
    string public version;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default
    uint256 public totalSupply;
    bool tradable;

    // This creates an array with all balances
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => bool) public frozenAccounts;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
    // ether received to contract
    event RecieveEth(address indexed _from, uint256 _value);
    // ether transferred from contract
    event WithdrawEth(address indexed _to, uint256 _value);
    // allowance for other addresses
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    //tokens sold to users
    event SoldToken(address _buyer, uint256 _value, string note);
    // tokens granted to users
    event BonusToken(address _customer, uint256 _value, string note);

    /// fallback function
    function () payable public {
        RecieveEth(msg.sender, msg.value);     
    }
    
    function withdrawal(address _to, uint256 Ether, uint256 Token) onlyOwner public {
        require(this.balance >= Ether && balances[this] >= Token );
        
        if(Ether >0){
            _to.transfer(Ether);
            WithdrawEth(_to, Ether);
        }
        
        if(Token > 0)
		{
			require(balances[_to] + Token > balances[_to]);
			balances[this] -= Token;
			balances[_to] += Token;
			Transfer(this, _to, Token);
		}
        
    }


    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function ZegartToken(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
        string contractversion
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balances[msg.sender] = totalSupply;         // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        version = contractversion;                          // Set the contract version for display purposes
        
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balances[_from] >= _value);
        // Check for overflows
        require(balances[_to] + _value > balances[_to]);
        // Check if sender is frozen
        require(!frozenAccounts[_from]); 
        // Check if recipient is frozen                    
        require(!frozenAccounts[_to]);                       
        // Save this for an assertion in the future
        uint previousBalanceOf = balances[_from] + balances[_to];
        // Subtract from the sender
        balances[_from] -= _value;
        // Add the same to the recipient
        balances[_to] += _value;
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balances[_from] + balances[_to] == previousBalanceOf);
    }

    
    
    
    function GrantToken(address _customer, uint256 _value, string note) onlyOwner public {
        require(balances[msg.sender] >= _value && balances[_customer] + _value > balances[_customer]);
        
        BonusToken( _customer,  _value,  note);
        balances[msg.sender] -= _value;
        balances[_customer] += _value;
        Transfer(msg.sender, _customer, _value);
    }
    
    
    
    
    function BuyToken(address _buyer, uint256 _value, string note) onlyOwner public {
        require(balances[msg.sender] >= _value && balances[_buyer] + _value > balances[_buyer]);
        
        SoldToken( _buyer,  _value,  note);
        balances[msg.sender] -= _value;
        balances[_buyer] += _value;
        Transfer(msg.sender, _buyer, _value);
    }

    
    function FreezeAccount(address toFreeze) onlyOwner public {
        frozenAccounts[toFreeze] = true;
    }
    
    function UnfreezeAccount(address toUnfreeze) onlyOwner public {
        delete frozenAccounts[toUnfreeze];
    }
    
    function MakeTradable(bool t) onlyOwner public {
        tradable = t;
    }
    
    function Tradable() public view returns(bool) {
        return tradable;
    }
    
    modifier notFrozen(){
       require (!frozenAccounts[msg.sender]);
       _;
    }
    
    
    
    
    function transfer(address _to, uint256 _value) public notFrozen returns (bool success) {
        require(tradable);
         if (balances[msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
             balances[msg.sender] -= _value;
             balances[_to] += _value;
             Transfer( msg.sender, _to,  _value);
             return true;
         } else {
             return false;
         }
     }
     
     
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) public notFrozen returns (bool success) {
        require(!frozenAccounts[_from] && !frozenAccounts[_to]);
        require(tradable);
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
            balances[_from] -= _value;
            balances[_to] += _value;
            allowed[_from][msg.sender] -= _value;
            Transfer( _from, _to,  _value);
            return true;
        } else {
            return false;
        }
    }

    
    
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }

    
    
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        Approval(msg.sender,  _spender, _value);
        allowed[msg.sender][_spender] = _value;
        return true;
    }

    
    
    
    
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    
    
    
    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }


    
    
    
    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);   // Check if the sender has enough
        balances[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

   
    
    
    
    
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowed[_from][msg.sender]);    // Check allowance
        balances[_from] -= _value;                         // Subtract from the targeted balance
        allowed[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }

}