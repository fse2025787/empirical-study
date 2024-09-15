
pragma solidity ^0.4.24;



library SafeMath {
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




contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}




contract ERC20Token{
    // Get the total token supply
    function totalSupply() public view returns (uint256 supply);

    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) public view returns (uint256 balance);

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount. 
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _value) public returns (bool success);

    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}



contract GTLToken is ERC20Token, owned {
    using SafeMath for uint256;

    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 _totalSupply;

    // Balances for each account
    mapping (address => uint256) public balances;
    // Owner of account approves the transfer of an amount to another account
    mapping (address => mapping (address => uint256)) public allowance;

    // Struct of Freeze Information
    struct FreezeAccountInfo {
        uint256 freezeStartTime;
        uint256 freezePeriod;
        uint256 freezeTotal;
    }



    // Freeze Information of accounts
    mapping (address => FreezeAccountInfo) public freezeAccount;

    // Triggered when tokens are issue and freeze
    event IssueAndFreeze(address indexed to, uint256 _value, uint256 _freezePeriod);

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor(string _tokenName, string _tokenSymbol, uint256 _initialSupply) public {
        _totalSupply = _initialSupply * 10 ** uint256(decimals);  // Total supply with the decimal amount
        balances[msg.sender] = _totalSupply;                // Give the creator all initial tokens
        name = _tokenName;                                   // Set the name for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    
    
    
    function totalSupply() public view returns (uint256 supply) {
        return _totalSupply;
    }

    
    
    
    
    function balanceOf(address _owner) public view returns (uint256 balance){
        return balances[_owner];
    }

    
    
    
    
    
    function issueAndFreeze(address _to, uint _value, uint _freezePeriod) onlyOwner public {
        _transfer(msg.sender, _to, _value);

        freezeAccount[_to] = FreezeAccountInfo({
            freezeStartTime : now,
            freezePeriod : _freezePeriod,
            freezeTotal : _value
        });

        emit IssueAndFreeze(_to, _value, _freezePeriod);
    }

    
    
    
    
    function getFreezeInfo(address _target) public view returns(
        uint _freezeStartTime, 
        uint _freezePeriod, 
        uint _freezeTotal, 
        uint _freezeDeadline) {
            
        FreezeAccountInfo storage targetFreezeInfo = freezeAccount[_target];
        uint freezeDeadline = targetFreezeInfo.freezeStartTime.add(targetFreezeInfo.freezePeriod.mul(1 minutes));
        return (
            targetFreezeInfo.freezeStartTime, 
            targetFreezeInfo.freezePeriod,
            targetFreezeInfo.freezeTotal,
            freezeDeadline
        );
    }

    
    
    
    
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address
        require(_to != 0x0);
        // Check if the sender has enough
        require(balances[_from] >= _value);
        // Check for overflows
        require(balances[_to].add(_value) > balances[_to]);

        uint256 freezeStartTime;
        uint256 freezePeriod;
        uint256 freezeTotal;
        uint256 freezeDeadline;

        // Get freeze information of sender
        (freezeStartTime,freezePeriod,freezeTotal,freezeDeadline) = getFreezeInfo(_from);

        // The free amount of _from
        uint256 freeTotalFrom = balances[_from].sub(freezeTotal);

        //Check if it is a freeze account
        //Check if in Lock-up Period
        //Check if the transfer amount > free amount
        require(freezeStartTime == 0 || freezeDeadline < now || freeTotalFrom >= _value); 

        // Save this for an assertion in the future
        uint previousBalances = balances[_from].add(balances[_to]);
        // Subtract from the sender
        balances[_from] = balances[_from].sub(_value);
        // Add the same to the recipient
        balances[_to] = balances[_to].add(_value);

        // Notify client the transfer
        emit Transfer(_from, _to, _value);
        // Asserting that the total balances before and after the transaction should be the same
        assert(balances[_from].add(balances[_to]) == previousBalances);
    }

    
    
    
    
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    
    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    
    
    
    
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    
    
    
    
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        return allowance[_owner][_spender];
    }
}