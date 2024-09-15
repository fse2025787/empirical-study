
pragma solidity ^0.4.20;
// ----------------------------------------------------------------------------------------------
// SPIKE Token by SPIKING Limited.
// An ERC223 standard
//
// author: SPIKE Team
// Contact: clemen@spiking.io

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }

}

contract ERC20 {
    // Get the total token supply
    function totalSupply() public constant returns (uint256 _totalSupply);
 
    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) public constant returns (uint256 balance);
 
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);
    
    // transfer _value amount of token approved by address _from
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    
    // approve an address with _value amount of tokens
    function approve(address _spender, uint256 _value) public returns (bool success);

    // get remaining token approved by _owner to _spender
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
  
    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
 
    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract ERC223 is ERC20{
    function transfer(address _to, uint _value, bytes _data) public returns (bool success);
    function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success);
    event Transfer(address indexed _from, address indexed _to, uint _value, bytes indexed _data);
}

/// contract receiver interface
contract ContractReceiver {  
    function tokenFallback(address _from, uint _value, bytes _data) external;
}

contract BasicSPIKE is ERC223 {
    using SafeMath for uint256;
    
    uint256 public constant decimals = 10;
    string public constant symbol = "SPIKE";
    string public constant name = "Spiking";
    uint256 public _totalSupply = 5 * 10 ** 19; // total supply is 5*10^19 unit, equivalent to 5 Billion SPIKE

    // Owner of this contract
    address public owner;
    address public airdrop;

    // tradable
    bool public tradable = false;

    // Balances SPIKE for each account
    mapping(address => uint256) balances;
    
    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;
            
    /**
     * Functions with this modifier can only be executed by the owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier isTradable(){
        require(tradable == true || msg.sender == airdrop || msg.sender == owner);
        _;
    }

    
    function BasicSPIKE() 
    public {
        owner = msg.sender;
        balances[owner] = _totalSupply;
        Transfer(0x0, owner, _totalSupply);
        airdrop = 0x00227086ab72678903091d315b04a8dacade39647a;
    }
    
    
    
    function totalSupply()
    public 
    constant 
    returns (uint256) {
        return _totalSupply;
    }
        
    
    
    
    function balanceOf(address _addr) 
    public
    constant 
    returns (uint256) {
        return balances[_addr];
    }
    
    
    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) 
    private 
    view 
    returns (bool is_contract) {
        uint length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length>0);
    }
 
    
    
    
    
    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    function transfer(address _to, uint _value) 
    public 
    isTradable
    returns (bool success) {
        require(_to != 0x0);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);
        return true;
    }
    
    
    
    
    
    function transfer(
        address _to, 
        uint _value, 
        bytes _data) 
    public
    isTradable 
    returns (bool success) {
        require(_to != 0x0);
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        Transfer(msg.sender, _to, _value);
        if(isContract(_to)) {
            ContractReceiver receiver = ContractReceiver(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
            Transfer(msg.sender, _to, _value, _data);
        }
        
        return true;
    }
    
    
    
    
    
    
    function transfer(
        address _to, 
        uint _value, 
        bytes _data, 
        string _custom_fallback) 
    public 
    isTradable
    returns (bool success) {
        require(_to != 0x0);
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        Transfer(msg.sender, _to, _value);

        if(isContract(_to)) {
            assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
            Transfer(msg.sender, _to, _value, _data);
        }
        return true;
    }
         
    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(
        address _from,
        address _to,
        uint256 _value)
    public
    isTradable
    returns (bool success) {
        require(_to != 0x0);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(_from, _to, _value);
        return true;
    }
    
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) 
    public
    returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
    
    // get allowance
    function allowance(address _owner, address _spender) 
    public
    constant 
    returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // withdraw any ERC20 token in this contract to owner
    function transferAnyERC20Token(address tokenAddress, uint tokens) public returns (bool success) {
        return ERC223(tokenAddress).transfer(owner, tokens);
    }
    
    // allow people can transfer their token
    // NOTE: can not turn off
    function turnOnTradable() 
    public
    onlyOwner{
        tradable = true;
    }

    // @dev allow owner to update airdrop admin
    function updateAirdrop(address newAirdropAdmin) 
    public 
    onlyOwner{
        airdrop = newAirdropAdmin;
    }
}

contract SPIKE is BasicSPIKE {

    bool public _selling = true;//initial selling
    
    uint256 public _originalBuyPrice = 80000 * 10**10; // original buy 1ETH = 80000 SPIKE = 80000 * 10**10 unit

    // List of approved investors
    mapping(address => bool) private approvedInvestorList;
    
    // deposit
    mapping(address => uint256) private deposit;
    
    // icoPercent
    uint256 public _icoPercent = 30;
    
    // _icoSupply is the avalable unit. Initially, it is _totalSupply
    uint256 public _icoSupply = (_totalSupply * _icoPercent) / 100;
    
    // minimum buy 0.3 ETH
    uint256 public _minimumBuy = 3 * 10 ** 17;
    
    // maximum buy 25 ETH
    uint256 public _maximumBuy = 25 * 10 ** 18;

    // totalTokenSold
    uint256 public totalTokenSold = 0;

    /**
     * Functions with this modifier check on sale status
     * Only allow sale if _selling is on
     */
    modifier onSale() {
        require(_selling);
        _;
    }
    
    /**
     * Functions with this modifier check the validity of address is investor
     */
    modifier validInvestor() {
        require(approvedInvestorList[msg.sender]);
        _;
    }
    
    /**
     * Functions with this modifier check the validity of msg value
     * value must greater than equal minimumBuyPrice
     * total deposit must less than equal maximumBuyPrice
     */
    modifier validValue(){
        // require value >= _minimumBuy AND total deposit of msg.sender <= maximumBuyPrice
        require ( (msg.value >= _minimumBuy) &&
                ( (deposit[msg.sender].add(msg.value)) <= _maximumBuy) );
        _;
    }

    
    function()
    public
    payable {
        buySPIKE();
    }
    
    
    function buySPIKE()
    public
    payable
    onSale
    validValue
    validInvestor {
        uint256 requestedUnits = (msg.value * _originalBuyPrice) / 10**18;
        require(balances[owner] >= requestedUnits);
        // prepare transfer data
        balances[owner] = balances[owner].sub(requestedUnits);
        balances[msg.sender] = balances[msg.sender].add(requestedUnits);
        
        // increase total deposit amount
        deposit[msg.sender] = deposit[msg.sender].add(msg.value);
        
        // check total and auto turnOffSale
        totalTokenSold = totalTokenSold.add(requestedUnits);
        if (totalTokenSold >= _icoSupply){
            _selling = false;
        }
        
        // submit transfer
        Transfer(owner, msg.sender, requestedUnits);
        owner.transfer(msg.value);
    }

    
    function SPIKE() BasicSPIKE()
    public {
        setBuyPrice(_originalBuyPrice);
    }
    
    
    function turnOnSale() onlyOwner 
    public {
        _selling = true;
    }

    
    function turnOffSale() onlyOwner 
    public {
        _selling = false;
    }
    
    
    
    function setIcoPercent(uint256 newIcoPercent)
    public 
    onlyOwner {
        _icoPercent = newIcoPercent;
        _icoSupply = (_totalSupply * _icoPercent) / 100;
    }
    
    
    
    function setMaximumBuy(uint256 newMaximumBuy)
    public 
    onlyOwner {
        _maximumBuy = newMaximumBuy;
    }

    
    
    function setBuyPrice(uint256 newBuyPrice) 
    onlyOwner 
    public {
        require(newBuyPrice>0);
        _originalBuyPrice = newBuyPrice; // unit
        // control _maximumBuy_USD = 10,000 USD, SPIKE price is 0.01USD
        // maximumBuy_SPIKE = 1000,000 SPIKE = 1000,000,0000000000 unit = 10^16
        _maximumBuy = (10**18 * 10**16) /_originalBuyPrice;
    }
    
    
    
    function isApprovedInvestor(address _addr)
    public
    constant
    returns (bool) {
        return approvedInvestorList[_addr];
    }
    
    
    
    
    function getDeposit(address _addr)
    public
    constant
    returns(uint256){
        return deposit[_addr];
}
    
    
    
    function addInvestorList(address[] newInvestorList)
    onlyOwner
    public {
        for (uint256 i = 0; i < newInvestorList.length; i++){
            approvedInvestorList[newInvestorList[i]] = true;
        }
    }

    
    
    function removeInvestorList(address[] investorList)
    onlyOwner
    public {
        for (uint256 i = 0; i < investorList.length; i++){
            approvedInvestorList[investorList[i]] = false;
        }
    }
    
    
    
    function withdraw() onlyOwner 
    public 
    returns (bool) {
        return owner.send(this.balance);
    }
}

contract MultiSigWallet {

    uint constant public MAX_OWNER_COUNT = 50;

    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);
    event CoinCreation(address coin);

    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] public owners;
    uint public required;
    uint public transactionCount;
    bool flag = true;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    modifier onlyWallet() {
        if (msg.sender != address(this))
            revert();
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        if (isOwner[owner])
            revert();
        _;
    }

    modifier ownerExists(address owner) {
        if (!isOwner[owner])
            revert();
        _;
    }

    modifier transactionExists(uint transactionId) {
        if (transactions[transactionId].destination == 0)
            revert();
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        if (!confirmations[transactionId][owner])
            revert();
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        if (confirmations[transactionId][owner])
            revert();
        _;
    }

    modifier notExecuted(uint transactionId) {
        if (transactions[transactionId].executed)
            revert();
        _;
    }

    modifier notNull(address _address) {
        if (_address == 0)
            revert();
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        if (   ownerCount > MAX_OWNER_COUNT
            || _required > ownerCount
            || _required == 0
            || ownerCount == 0)
            revert();
        _;
    }

    
    function()
        payable
    {
        if (msg.value > 0)
            Deposit(msg.sender, msg.value);
    }

    /*
     * Public functions
     */
    
    
    
    function MultiSigWallet(address[] _owners, uint _required)
        public
        validRequirement(_owners.length, _required)
    {
        for (uint i=0; i<_owners.length; i++) {
            if (isOwner[_owners[i]] || _owners[i] == 0)
                revert();
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }

    
    
    function addOwner(address owner)
        public
        onlyWallet
        ownerDoesNotExist(owner)
        notNull(owner)
        validRequirement(owners.length + 1, required)
    {
        isOwner[owner] = true;
        owners.push(owner);
        OwnerAddition(owner);
    }

    
    
    function removeOwner(address owner)
        public
        onlyWallet
        ownerExists(owner)
    {
        isOwner[owner] = false;
        for (uint i=0; i<owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.length -= 1;
        if (required > owners.length)
            changeRequirement(owners.length);
        OwnerRemoval(owner);
    }

    
    
    
    function replaceOwner(address owner, address newOwner)
        public
        onlyWallet
        ownerExists(owner)
        ownerDoesNotExist(newOwner)
    {
        for (uint i=0; i<owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        OwnerRemoval(owner);
        OwnerAddition(newOwner);
    }

    
    
    function changeRequirement(uint _required)
        public
        onlyWallet
        validRequirement(owners.length, _required)
    {
        required = _required;
        RequirementChange(_required);
    }

    
    
    
    
    
    function submitTransaction(address destination, uint value, bytes data)
        public
        returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

    
    
    function confirmTransaction(uint transactionId)
        public
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    
    
    function revokeConfirmation(uint transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        Revocation(msg.sender, transactionId);
    }

    
    
    function executeTransaction(uint transactionId)
        public
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction tx = transactions[transactionId];
            tx.executed = true;
            if (tx.destination.call.value(tx.value)(tx.data))
                Execution(transactionId);
            else {
                ExecutionFailure(transactionId);
                tx.executed = false;
            }
        }
    }

    
    
    
    function isConfirmed(uint transactionId)
        public
        constant
        returns (bool)
    {
        uint count = 0;
        for (uint i=0; i<owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

    /*
     * Internal functions
     */
    
    
    
    
    
    function addTransaction(address destination, uint value, bytes data)
        internal
        notNull(destination)
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        transactionCount += 1;
        Submission(transactionId);
    }

    /*
     * Web3 call functions
     */
    
    
    
    function getConfirmationCount(uint transactionId)
        public
        constant
        returns (uint count)
    {
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
    }

    
    
    
    
    function getTransactionCount(bool pending, bool executed)
        public
        constant
        returns (uint count)
    {
        for (uint i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
                count += 1;
    }

    
    
    function getOwners()
        public
        constant
        returns (address[])
    {
        return owners;
    }

    
    
    
    function getConfirmations(uint transactionId)
        public
        constant
        returns (address[] _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i=0; i<count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

    
    
    
    
    
    
    function getTransactionIds(uint from, uint to, bool pending, bool executed)
        public
        constant
        returns (uint[] _transactionIds)
    {
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;
        for (i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
            {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint[](to - from);
        for (i=from; i<to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }
    
    
    function createCoin()
        external
        onlyWallet
    {
        require(flag == true);
        CoinCreation(new SPIKE());
        flag = false;
    }
}