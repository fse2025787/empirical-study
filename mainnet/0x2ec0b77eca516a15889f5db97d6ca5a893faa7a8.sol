
pragma solidity ^0.4.15;



contract AbstractToken {

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


contract Owned {

    address public owner = msg.sender;
    address public potentialOwner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPotentialOwner {
        require(msg.sender == potentialOwner);
        _;
    }

    event NewOwner(address old, address current);
    event NewPotentialOwner(address old, address potential);

    function setOwner(address _new)
        public
        onlyOwner
    {
        NewPotentialOwner(owner, _new);
        potentialOwner = _new;
    }

    function confirmOwnership()
        public
        onlyPotentialOwner
    {
        NewOwner(owner, potentialOwner);
        owner = potentialOwner;
        potentialOwner = 0;
    }
}


/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
contract StandardToken is AbstractToken, Owned {

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




contract SafeMath {
    function mul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function sub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function pow(uint a, uint b) internal returns (uint) {
        uint c = a ** b;
        assert(c >= a);
        return c;
    }
}




contract Token is StandardToken, SafeMath {
    // Time of the contract creation
    uint public creationTime;

    function Token() {
        creationTime = now;
    }


    
    function transferERC20Token(address tokenAddress)
        public
        onlyOwner
        returns (bool)
    {
        uint balance = AbstractToken(tokenAddress).balanceOf(this);
        return AbstractToken(tokenAddress).transfer(owner, balance);
    }

    
    function withDecimals(uint number, uint decimals)
        internal
        returns (uint)
    {
        return mul(number, pow(10, decimals));
    }
}




contract PoetToken is Token {

    /*
     * Token meta data
     */
    string constant public name = "Poet";
    string constant public symbol = "POE";
    uint8 constant public decimals = 8;  // TODO: Confirm this number

    // Address where all investors tokens created during the ICO stage initially allocated
    address constant public icoAllocation = 0x1111111111111111111111111111111111111111;

    // Address where Foundation tokens are allocated
    address constant public foundationReserve = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    // Number of tokens initially allocated to Foundation
    uint foundationTokens;

    // Store number of days in each month
    mapping(uint8 => uint8) daysInMonth;

    // UNIX timestamp for September 1, 2017
    // It's a date when first 2% of foundation reserve will be unlocked
    uint Sept1_2017 = 1504224000;

    // Number of days since September 1, 2017 before all tokens will be unlocked
    uint reserveDelta = 456;


    
    function PoetToken()
    {   
        // Overall, 3,141,592,653 POE tokens are distributed
        totalSupply = withDecimals(3141592653, decimals);

        // Allocate 32% of all tokens to Foundation
        foundationTokens = div(mul(totalSupply, 32), 100);
        balances[foundationReserve] = foundationTokens;

        // Allocate the rest to icoAllocation address
        balances[icoAllocation] = sub(totalSupply, foundationTokens);

        // Allow owner to distribute tokens allocated on the icoAllocation address
        allowed[icoAllocation][owner] = balanceOf(icoAllocation);

        // Fill mapping with numbers of days
        // Note: we consider only February of 2018 that has 28 days
        daysInMonth[1]  = 31; daysInMonth[2]  = 28; daysInMonth[3]  = 31;
        daysInMonth[4]  = 30; daysInMonth[5]  = 31; daysInMonth[6]  = 30;
        daysInMonth[7]  = 31; daysInMonth[8]  = 31; daysInMonth[9]  = 30;
        daysInMonth[10] = 31; daysInMonth[11] = 30; daysInMonth[12] = 31;
    }

    
    function distribute(address investor, uint amount)
        public
        onlyOwner
    {
        transferFrom(icoAllocation, investor, amount);
    }

    
    function confirmOwnership()
        public
        onlyPotentialOwner
    {   
        // Allow new owner to distribute tokens allocated on the icoAllocation address
        allowed[icoAllocation][potentialOwner] = balanceOf(icoAllocation);

        // Forbid old owner to distribute tokens
        allowed[icoAllocation][owner] = 0;

        // Forbid old owner to withdraw tokens from foundation reserve
        allowed[foundationReserve][owner] = 0;

        // Change owner
        super.confirmOwnership();
    }

    
    function allowance(address _owner, address _spender)
        public
        constant
        returns (uint256 remaining)
    {
        if (_owner == foundationReserve && _spender == owner) {
            return availableReserve();
        }

        return allowed[_owner][_spender];
    }

    
    function availableReserve() 
        public
        constant
        returns (uint)
    {   
        // No tokens should be available for withdrawal before September 1, 2017
        if (now < Sept1_2017) {
            return 0;
        }

        // Number of days passed  since September 1, 2017
        uint daysPassed = div(sub(now, Sept1_2017), 1 days);

        // All tokens should be unlocked if reserveDelta days passed
        if (daysPassed >= reserveDelta) {
            return balanceOf(foundationReserve);
        }

        // Percentage of unlocked tokens by the current date
        uint unlockedPercentage = 0;

        uint16 _days = 0;  uint8 month = 9;
        while (_days <= daysPassed) {
            unlockedPercentage += 2;
            _days += daysInMonth[month];
            month = month % 12 + 1;
        }

        // Number of unlocked tokens by the current date
        uint unlockedTokens = div(mul(totalSupply, unlockedPercentage), 100);

        // Number of tokens that should remain locked
        uint lockedTokens = foundationTokens - unlockedTokens;

        return balanceOf(foundationReserve) - lockedTokens;
    }

    
    function withdrawFromReserve(uint amount)
        public
        onlyOwner
    {   
        // Allow owner to withdraw no more than this amount of tokens
        allowed[foundationReserve][owner] = availableReserve();

        // Withdraw tokens from foundation reserve to owner address
        require(transferFrom(foundationReserve, owner, amount));
    }
}