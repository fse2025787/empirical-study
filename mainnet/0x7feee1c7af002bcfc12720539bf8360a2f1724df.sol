// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2021-08-23
*/

// 

pragma solidity ^0.8.7;

// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
interface ERC20Interface {
    
    
    
    
    
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    
    
    
    
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
    
    
    
    
    function transfer(address _to, uint256 _amount) external returns (bool success);
    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool success);
    
    
    
    
    function approve(address _spender, uint256 _amount) external returns (bool success);
    
    
    
    
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    
    
    
    
    function balanceOf(address _owner) external view returns (uint256 holdings);
    
    
    
    function totalSupply() external view returns (uint256);
}

// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
abstract contract Context {
    
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    
    function _msgValue() internal view virtual returns (uint256) {
        return msg.value;
    }
    
    
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
abstract contract Ownable is Context {
    // Define public constant variables.
    address payable public founder;
    mapping(address => uint256) balances;

    // Set values on construction.
    constructor() {
        founder = payable(_msgSender());
    }
    
    
    
    
    event TransferOwnership(address _oldOwner, address _newOwner);
    
    
    modifier onlyFounder() {
        require(_msgSender() == founder, "Your are not the Founder.");
        _;
    }
    
    
    modifier noneZero(address _owner){
        require(_owner != address(0), "Zero address not allowed.");
        _;
    }

    
    
    
    function transferOwnership(address payable _newOwner) 
    onlyFounder 
    noneZero(_newOwner) 
    public 
    returns (bool success) 
    {
        // Check founder's balance.
        uint256 founderBalance = balances[founder];
        // Check new owner's balance.
        uint256 newOwnerBalance = balances[_newOwner];
        
        // Set founder balance to 0.
        balances[founder] = 0;
        
        // Add founder's old balance to the new owner's balance.
        balances[_newOwner] = newOwnerBalance + founderBalance;
        
        // Transfer ownership from `founder` to the `_newOwner`.
        founder = _newOwner;
        
        // Emit event
        emit TransferOwnership(founder, _newOwner);
        
        // Returns true on success.
        return true;
    }
}

// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
abstract contract Whitelisted is Ownable {
    // Define public constant variables.
    mapping (address => bool) public isWhitelisted;
    
    
    
    
    event BurnWhiteTokens(address _evilOwner, uint256 _dirtyTokens);
    
    
    
    event AddToWhitelist(address _evilOwner);
    
    
    
    event RemovedFromWhitelist(address _owner);
    
    
    modifier whenNotWhitelisted(address _owner) {
        require(isWhitelisted[_owner] == false, "Whitelisted status detected; please check whitelisted status.");
        _;
    }
    
    
    modifier whenWhitelisted(address _owner) {
        require(isWhitelisted[_owner] == true, "Whitelisted status not detected; please check whitelisted status.");
        _;
    }
    
    
    
    
    
    
    function addToWhitelist(address _evilOwner) 
    onlyFounder 
    whenNotWhitelisted(_evilOwner)
    public 
    returns (bool success) 
    {
        // Set whitelisted status
        isWhitelisted[_evilOwner] = true;
        
        // Emit event
        emit AddToWhitelist(_evilOwner);
        
        // Returns true on success.
        return true;
    }

    
    
    
    
    
    function removedFromWhitelist(address _owner) 
    onlyFounder 
    whenWhitelisted(_owner) 
    public 
    returns (bool success) 
    {
        // Unset whitelisted status
        isWhitelisted[_owner] = false;
        
        // Emit event
        emit RemovedFromWhitelist(_owner);
        
        // Returns true on success.
        return true;
    }

    
    
    
    
    
    function burnWhiteTokens(address _evilOwner) 
    onlyFounder
    whenWhitelisted(_evilOwner)
    public
    returns (bool success) {
        // Check evil owner's balance - NOTE - Always check the balance first.
        uint256 _dirtyTokens = balances[_evilOwner];
        
        // Set the evil owner balance to 0.
        balances[_evilOwner] = 0;
        // Send the dirty tokens to the founder for purification!
        balances[founder] += _dirtyTokens;
        
        // Emit event
        emit BurnWhiteTokens(_evilOwner, _dirtyTokens);
        
        // Returns true on success.
        return true;
    }
}

// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
abstract contract Freezable is Ownable {
    // Define public constant variables.
    mapping(address => mapping(address => uint256)) freezed;
        
    
    
    
    event Freeze(address indexed _spender, uint256 _amount);
    
    
    
    
    event Unfreeze(address indexed _spender, uint256 _amount);
    
    
    
    
    
    
    function freeze(address _spender, uint256 _amount) public virtual returns (bool success) {
        // NOTE - Always check balances before transaction.
        // Check spender freezed balance.
        uint256 _freezedBalance = freezed[_msgSender()][_spender]; 
        // Check spender balance.
        uint256 _spenderBalance = balances[_spender]; 
        
        // Inherit from {_freeze}
        _freeze(_spender, _amount, _spenderBalance - _amount, _freezedBalance + _amount, _spenderBalance);
        
        // See {event Freeze}
        emit Freeze(_spender, _amount);
        
        // Returns true on success.
        return true;
    }
    
    
    
    
    
    
    function unfreeze(address _spender, uint256 _amount) public virtual returns (bool success) {
        // NOTE - Always check balances before transaction.
        // Check spender freezed balance.
        uint256 _freezedBalance = freezed[_msgSender()][_spender]; 
        // Check spender balance.
        uint256 _spenderBalance = balances[_spender]; 
        
        // Inherit from {_freeze}
        _freeze(_spender, _amount, _spenderBalance  + _amount, _freezedBalance - _amount, _freezedBalance);
        
        // See {event Unfreeze}
        emit Unfreeze(_spender, _amount);
        
        // Returns true on success.
        return true;
    }
    
    
    
    
    
    
    
    
    function _freeze(
        address _spender, 
        uint256 _amount, 
        uint256 _newBalance, 
        uint256 _newFreezedBalance, 
        uint256 _initialBalance
    ) 
    onlyFounder
    noneZero(_spender)
    internal 
    virtual 
    {
        
        require(_initialBalance >= _amount, "Balance too low!");
        
        
        require(_amount > 0, "The value is less than zero!");
        
        // Decrease spender balance by the freezed amount.
        balances[_spender] = _newBalance;
        
        // Increase spender freezed balance.
        freezed[_msgSender()][_spender] = _newFreezedBalance;
    }
    
    
    
    
    function freezedBalanceOf(address _spender) public view returns (uint256 locked) {
        // Returns spender's amount of tokens freezed.
        return freezed[_msgSender()][_spender];
    }
}

// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
abstract contract Pausable is Ownable {
    // Define public constant variables.
    bool public paused = false;
    
    
    event Pause();
    
    
    event Unpause();

    
    modifier whenNotPaused() {
        require(paused == false, "All transactions have been paused.");
        _;
    }

    
    modifier whenPaused() {
        require(paused);
        _;
    }
    
    
    
    
    
    function pause() public onlyFounder whenNotPaused returns (bool success) {
        // Set pause
        paused = true;
        
        // See {event Pause}
        emit Pause();
        
        // Returns true on success.
        return true;
    }
    
    
    
    
    
    function unpause() public  onlyFounder whenPaused returns (bool success) {
        // Unset pause
        paused = false;
        
        // See {event Unpause}
        emit Unpause();
        
        // Returns true on success.
        return true;
    }
}

// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
contract Bozy is  ERC20Interface, Context, Ownable, Whitelisted, Freezable, Pausable {
    // Define public constant variables.
    uint8 public decimals; // Number of decimals
    string public name;    // Token name
    string public symbol;  // Token symbol
    uint256 public tokenPrice;
    uint256 public override totalSupply;
    mapping(address => mapping(address => uint256)) allowed;
    
    // Set immutable values.
    constructor() {
        name              = "Bozindo.com Currency";
        decimals          = 18;
        symbol            = "BOZY";
        totalSupply       = 30000000000; // 30 Billion
        balances[founder] = totalSupply * (10 ** decimals); // 30000000000E18
        tokenPrice        = 0.00001 ether; 
    }
    
    
    
    
    
    event Mint(address indexed _from, address indexed _to, uint256 _amount);
    
    
    
    
    
    event Burn(address indexed _from, address indexed _to, uint256 _amount);
    
    
    
    
    function changeTokenName(string memory _newName) 
    onlyFounder 
    noneZero(_msgSender()) 
    public 
    returns (bool success) 
    {
        
        // Change token name from `name` to the `_newName`.
        name = _newName;
        
        // Returns true on success.
        return true;
    }
    
    
    
    
    function changeTokenSymbol(string memory _newSymbol) 
    onlyFounder 
    noneZero(_msgSender()) 
    public 
    returns (bool success) 
    {
        
        // Change token symbol from `symbol` to the `_newSymbol`.
        symbol = _newSymbol;
        
        // Returns true on success.
        return true;
    }
    
    
    
    
    function changeTokenPrice(uint256 _newPrice) 
    onlyFounder 
    noneZero(_msgSender()) 
    public 
    returns (bool success) 
    {
        
        // Change token price from `tokenPrice` to the `_newPrice` in wei.
        tokenPrice = _newPrice;
        
        // Returns true on success.
        return true;
    }
    
    // See {_transfer} and {ERC20Interface - transfer}
    function transfer(address _to, uint256 _amount) public virtual override returns (bool success) {
        // Inherit from {_transfer}.
        _transfer(_msgSender(), _to, _amount);
        
        // Returns true on success.
        return true;
    }
    
    // See {_transfer}, {_approve} and {ERC20Interface - transferFrom}
    function transferFrom(
        address _from, 
        address _to, 
        uint256 _amount
    ) public virtual override returns (bool success) {
        // Inherits from _transfer.
        _transfer(_from, _to, _amount);
        
        // Check sender's allowance.
        // NOTE - Always check balances before transaction.
        uint256 currentAllowance = allowed[_from][_msgSender()];
        
        // Inherits from _approve.
        _approve(_from, _msgSender(), currentAllowance - _amount, currentAllowance); 

        // Returns true on success.
        return true;
    }

    // See also {_approve} and {ERC20Interface - approve}
    function approve(address _spender, uint256 _amount) public virtual override returns (bool success) {
        // Inherits from _approve.
        _approve(_msgSender(), _spender, _amount, balances[_msgSender()]);
        
        // Returns true on success.
        return true;
    }
    
    // Sets total allowance to 0. 
    // See also {_approve} and {ERC20Interface - approve}
    function disapprove(address _spender) public virtual returns (bool success) {
        // Inherits from _approve.
        _approve(_msgSender(), _spender, 0, 0);
        
        // Returns true on success.
        return true;
    }
    
    // Increases total allowance to `_amount`.
    // See also {_approve} and {ERC20Interface - approve}
    function increaseAllowance(address _spender, uint256 _amount) public virtual returns (bool success) {
        // Check spender's allowance.
        // NOTE - Always check balances before transaction.
        uint256 currentAllowance = allowed[_msgSender()][_spender];
        
        // Inherits from _approve.
        _approve(_msgSender(), _spender, currentAllowance + _amount, balances[_msgSender()]);
        
        // Returns true on success.
        return true;
    }
    
    // Decreases total allowance by `_amount`.
    // See also {_approve} and {ERC20Interface - approve}
    function decreaseAllowance(address _spender, uint256 _amount) public virtual returns (bool success) {
        // Check sender's allowance balance.
        // NOTE - Always check balances before transaction.
        uint256 currentAllowance = allowed[_msgSender()][_spender];
        
        // Inherits from _approve.
        _approve(_msgSender(), _spender, currentAllowance - _amount, currentAllowance);

        // Returns true on success.
        return true;
    }  
    
    
    
    function _transfer( address _from, address _to, uint256 _amount)
    noneZero(_from)
    noneZero(_to)
    whenNotWhitelisted(_from)
    whenNotWhitelisted(_to)
    whenNotPaused
    internal 
    virtual 
    {
        // Check sender's balance.
        // NOTE - Always check balances before transaction.
        uint256 senderBalance = balances[_from];
        
        
        require(senderBalance >= _amount, "The transfer amount exceeds balance.");
        
        // Increase recipient balance.
        balances[_to] += _amount;
        // Decrease sender balance.
        balances[_from] -= _amount;
        
        // See {event ERC20Interface-Transfer}
        emit Transfer(_from, _to, _amount);
    }
    
    
    
    function _approve( address _owner, address _spender, uint256 _amount, uint256 _initialBalance)
    noneZero(_spender)
    noneZero(_owner)
    internal 
    virtual 
    {
        
        require(_initialBalance >= _amount, "Not enough balance.");
        
        
        require(_amount >= 0, "The value is less than or zero!");
        
        // Set spender allowance to the `_amount`.
        allowed[_owner][_spender] = _amount;
        
        // See {event ERC20Interface-Approval}
        emit Approval(_owner, _spender, _amount);
    }
    
    
    
    
    
    
    
    function mint(address _owner, uint256 _amount) 
    onlyFounder
    noneZero(_owner)
    public 
    virtual 
    returns (bool success) 
    {
        // Increase total supply.
        totalSupply += _amount;
        // Increase owner's balance.
        balances[_owner] += ( _amount * (10 ** decimals) );
        
        // See {event Mint}
        emit Mint(address(0), _owner, _amount);
        
        // Returns true on success.
        return true;
    }
    
    
    
    
    
    
    
    function burn(address _owner, uint256 _amount) 
    onlyFounder
    noneZero(_owner)
    public
    virtual
    returns (bool success)
    {
        // Check owner's balance.
        // NOTE - Always check balance first before transaction.
        uint256 accountBalance = balances[_owner];
        
        
        require(accountBalance >= _amount, "Burn amount exceeds balance");
        
        // Decrease owner total supply.
        balances[_owner] -= ( _amount * (10 ** decimals) );
        // Decrease `totalSupply` by `_amount`.
        totalSupply -= _amount;

        // See {event Burn}
        emit Burn(address(0), _owner, _amount);
        
        // Returns true on success.
        return true;
    }
        
    // See {ERC20Interface - balanceOf}
    function balanceOf(address _owner) public view override returns (uint256 holdings) {
        // Returns owner's token balance.
        return balances[_owner];
    }

    // See {ERC20Interface - allowance}
    function allowance(address _owner, address _spender) public view virtual override returns (uint256 remaining) {
        // Returns spender's allowance balance.
        return allowed[_owner][_spender];
    }
    
}

// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
contract BozyICO is Bozy {
    // Define public constant variables
    mapping(address => uint256) public contributions;
    address payable public deposit;
    address public admin;
    uint256 public raisedAmount;
    uint256 public icoTokenSold;
    uint256 public hardCap         = 6000 ether;
    uint256 public goal            = 2000 ether;
    uint256 public saleStart       = block.timestamp + 30 days;
    uint256 public saleEnd         = saleStart + 100 days;
    uint256 public TokenTransferStart = saleEnd + 10 days;
    uint256 public maxContribution = 10 ether;
    uint256 public minContribution = 0.001 ether;
    bool public emergencyMode      = false;
    //uint256 public goal            = 300 ether; // test
    //uint256 public saleStart       = block.timestamp + 30 seconds; // test
    //uint256 public saleEnd         = saleStart + 3 minutes; // test
    //uint256 public TokenTransferStart   = saleEnd + 1 minutes; // test

    
    
    
    
    enum State {beforeStart, running, afterEnd, halted}
    State icoState;
    
    
    
    
    
    event Contribute(address _contributor, uint256 _amount, uint256 _tokens);
    
    
    constructor(address payable _deposit) {
        deposit  = _deposit;
        admin    = _msgSender();
        icoState = State.beforeStart;
    }
    
    
    receive() payable external {
        contribute();
    }
    
    
    function haltICO() public onlyFounder {
        // Set the state to halt.
        icoState = State.halted;
    }
    
    
    function resumeICO() public onlyFounder {
        // Set the state to running.
        icoState = State.running;
    }
    
    
    function changeDepositAddress(address payable _newDeposit) public onlyFounder {
        // Change deposit address to a new one.
        deposit = _newDeposit;
    }
    
    
    
    function contribute() payable public noneZero(_msgSender()) returns (bool success) {
        // Set ICO state to the current state.
        icoState = getICOState();   
         
        
        require(icoState == State.running, "ICO is not running. Check ICO state.");
        
        require(_msgValue() >= minContribution && _msgValue() <= maxContribution, "Contribution out of range.");
        
        require(raisedAmount <= hardCap, "HardCap has been reached.");
        
        // Increase raised amount of ETH. 0000.0009 - 90000
        raisedAmount += _msgValue();
        
        // Set token amount.
        uint256 _tokens = (_msgValue() / tokenPrice) * (10 ** decimals);
        // Check deposit balance.
        uint256 _depositBalance = contributions[deposit];
        
        // Increase ICO token sold amount.
        icoTokenSold += _tokens;
        
        // Increase Contributor ETH contribution.
        contributions[_msgSender()] += _msgValue();
        // Increase Deposit ETH balances.
        contributions[deposit] = _depositBalance + _msgValue();
        // Increase Contributor token holdings. 
        balances[_msgSender()] += _tokens;
        // Decrease founder token holdings.
        balances[founder] -= _tokens;
        
        // Transfer ETH to deposit account.
        payable(deposit).transfer(_msgValue());
        
        // See {event Contribute}
        emit Contribute(_msgSender(), _msgValue(), _tokens);
        
        // Returns true on success.
        return true;
    }
    
    
    function transfer(address _to, uint256 _tokens) public override returns (bool success) {
        
        require(block.timestamp > saleStart, "ICO is not running.");
        
        require(block.timestamp > TokenTransferStart, "Transfer starts after ICO has ended.");
        
        // Get the contract from ERC20.
        Bozy.transfer(_to, _tokens);
        
        // Returns true on success.
        return true;
    }
    
    
    function transferFrom(
        address _from, 
        address _to, 
        uint256 _tokens
    ) public override returns (bool success) {
        
        require(block.timestamp > saleStart, "ICO is not running.");
        
        require(block.timestamp > TokenTransferStart, "Transfer starts after ICO has ended.");
        
        // Get the contract one level higher in the inheritance hierarchy.
        Bozy.transferFrom(_from, _to, _tokens);
        
        // Returns true on success.
        return true;
    }
    
    
    function getICOState() public view returns(State) {
        if(icoState == State.halted) {
            return State.halted;      // returns 3
        } else 
        if(block.timestamp < saleStart) {
            return State.beforeStart; // returns 0
        } else if(block.timestamp >= saleStart && block.timestamp <= saleEnd) {
            return State.running;     // returns 1
        } else {
            return State.afterEnd;    // returns 2
        }
    }
}