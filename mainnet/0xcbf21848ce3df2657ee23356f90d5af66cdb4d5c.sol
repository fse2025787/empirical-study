
pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------------------------
// Spike Token by Aly Pte.
// An ERC20 standard
//
// author: Spike Team
// Contact: <a href=/cdn-cgi/l/email-protection class=__cf_email__ data-cfemail=d5b6b9b0b8b0bb95b4fbb9ac>[email&#160;protected]</a>

contract ERC20Interface {
    // Get the total token supply
    function totalSupply() public constant returns (uint256 _totalSupply);

    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) public constant returns (uint256 balance);

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);

    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Spike is ERC20Interface {
    uint public constant decimals = 5;

    string public constant symbol = "SPIKE";
    string public constant name = "SPIKE";

    bool public _selling = false;//initial not selling
    uint public _totalSupply = 10 ** 14; // total supply is 10^14 unit, equivalent to 10^9 Spike
    uint public _originalBuyPrice = 3 * 10**8; // original buy 1ETH = 3000 Spike = 3 * 10**8 unit

    // Owner of this contract
    address public owner;

    // Balances Spike for each account
    mapping(address => uint256) balances;

    // List of approved investors
    mapping(address => bool) approvedInvestorList;

    // mapping Deposit
    mapping(address => uint256) deposit;

    // buyers buy token deposit
    address[] buyers;

    // icoPercent
    uint _icoPercent = 30;

    // _icoSupply is the avalable unit. Initially, it is _totalSupply
    uint public _icoSupply = _totalSupply * _icoPercent / 100;

    // minimum buy 0.3 ETH
    uint public _minimumBuy = 3 * 10 ** 17;

    // maximum buy 30 ETH
    uint public _maximumBuy = 30 * 10 ** 18;

    /**
     * Functions with this modifier can only be executed by the owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * Functions with this modifier can only be executed by users except owners
     */
    modifier onlyNotOwner() {
        require(msg.sender != owner);
        _;
    }

    /**
     * Functions with this modifier check on sale status
     * Only allow sale if _selling is on
     */
    modifier onSale() {
        require(_selling && (_icoSupply > 0) );
        _;
    }

    /**
     * Functions with this modifier check the validity of original buy price
     */
    modifier validOriginalBuyPrice() {
        require(_originalBuyPrice > 0);
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
            ( (deposit[msg.sender] + msg.value) <= _maximumBuy) );
        _;
    }

    /**
     * Functions with this modifier check the validity of range [a, b] <= [0, buyers.length-1]
     */
    modifier validRange(uint a, uint b){
        require ( (a>=0 && a<=b) &&
            (b<buyers.length) );
        _;
    }

    
    function()
    public
    payable {
        buySpike();
    }

    
    function buySpike()
    public
    payable
    onSale
    validValue {
        // check the first buy => push to Array
        if (deposit[msg.sender] == 0 && msg.value > 0){
            // add new buyer to List
            buyers.push(msg.sender);
        }
        // increase amount deposit of buyer
        deposit[msg.sender] += msg.value;
    }

    
    function Spike()
    public {
        owner = msg.sender;
        // buyers = new address[](1);
        balances[owner] = _totalSupply;
        Transfer(0x0, owner, _totalSupply);
    }

    
    
    function totalSupply()
    public
    constant
    returns (uint256) {
        return _totalSupply;
    }

    
    
    function setIcoPercent(uint256 newIcoPercent)
    public
    onlyOwner {
        _icoPercent = newIcoPercent;
        _icoSupply = _totalSupply * _icoPercent / 100;
    }

    
    
    function setMinimumBuy(uint256 newMinimumBuy)
    public
    onlyOwner {
        _minimumBuy = newMinimumBuy;
    }

    
    
    function setMaximumBuy(uint256 newMaximumBuy)
    public
    onlyOwner {
        _maximumBuy = newMaximumBuy;
    }

    
    
    
    function balanceOf(address _addr)
    public
    constant
    returns (uint256) {
        return balances[_addr];
    }

    
    
    function isApprovedInvestor(address _addr)
    public
    constant
    returns (bool) {
        return approvedInvestorList[_addr];
    }

    
    
    function filterBuyers(bool isInvestor)
    private
    constant
    returns(address[] filterList){
        address[] memory filterTmp = new address[](buyers.length);
        uint count = 0;
        for (uint i = 0; i < buyers.length; i++){
            if(approvedInvestorList[buyers[i]] == isInvestor){
                filterTmp[count] = buyers[i];
                count++;
            }
        }

        filterList = new address[](count);
        for (i = 0; i < count; i++){
            if(filterTmp[i] != 0x0){
                filterList[i] = filterTmp[i];
            }
        }
    }

    
    function getInvestorBuyers()
    public
    constant
    returns(address[]){
        return filterBuyers(true);
    }

    
    function getNormalBuyers()
    public
    constant
    returns(address[]){
        return filterBuyers(false);
    }

    
    function getAllBuyers()
    public
    constant
    returns(address[]){
        return buyers;
    }

    
    
    
    function getDeposit(address _addr)
    public
    constant
    returns(uint256){
        return deposit[_addr];
    }

    
    
    
    function deliveryToken(uint a, uint b)
    public
    onlyOwner
    validOriginalBuyPrice
    validRange(a, b) {
        //sumary deposit of investors
        uint256 sum = 0;
        // make sure balances owner greater than _icoSupply
        require(balances[owner] >= _icoSupply);

        for (uint i = a; i <= b; i++){
            if(approvedInvestorList[buyers[i]]) {

                // compute amount token of each buyer
                uint256 requestedUnits = (deposit[buyers[i]] * _originalBuyPrice) / 10**18;

                //check requestedUnits > _icoSupply
                if(requestedUnits <= _icoSupply && requestedUnits > 0 ){
                    // prepare transfer data
                    balances[owner] -= requestedUnits;
                    balances[buyers[i]] += requestedUnits;
                    _icoSupply -= requestedUnits;

                    // submit transfer
                    Transfer(owner, buyers[i], requestedUnits);

                    // reset deposit of buyer
                    sum += deposit[buyers[i]];
                    deposit[buyers[i]] = 0;
                }
            }
        }
        //transfer total ETH of investors to owner
        owner.transfer(sum);
    }

    
    
    
    function returnETHforUnqualifiedBuyers(uint a, uint b)
    public
    validRange(a, b)
    onlyOwner{
        for(uint i = a; i <= b; i++){
            // buyer not approve investor
            if (!approvedInvestorList[buyers[i]]) {
                // get deposit of buyer
                uint256 buyerDeposit = deposit[buyers[i]];
                // reset deposit of buyer
                deposit[buyers[i]] = 0;
                // return deposit amount for buyer
                buyers[i].transfer(buyerDeposit);
            }
        }
    }

    
    
    
    
    function transfer(address _to, uint256 _amount)
    public
    returns (bool) {
        // if sender's balance has enough unit and amount >= 0,
        //      and the sum is not overflow,
        // then do transfer
        if ( (balances[msg.sender] >= _amount) &&
        (_amount >= 0) &&
            (balances[_to] + _amount > balances[_to]) ) {

            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);

            return true;

        } else {
            revert();
        }
    }

    
    function turnOnSale() onlyOwner
    public {
        _selling = true;
    }

    
    function turnOffSale() onlyOwner
    public {
        _selling = false;
    }

    
    function isSellingNow()
    public
    constant
    returns (bool) {
        return _selling;
    }

    
    
    function setBuyPrice(uint newBuyPrice)
    onlyOwner
    public {
        _originalBuyPrice = newBuyPrice;
    }

    
    
    function addInvestorList(address[] newInvestorList)
    onlyOwner
    public {
        for (uint i = 0; i < newInvestorList.length; i++){
            approvedInvestorList[newInvestorList[i]] = true;
        }
    }

    
    
    function removeInvestorList(address[] investorList)
    onlyOwner
    public {
        for (uint i = 0; i < investorList.length; i++){
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
        CoinCreation(new Spike());
        flag = false;
    }
}