
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

contract ApproveAndCallReceiver {
    function receiveApproval(
        address _from, 
        uint256 _amount, 
        address _token, 
        bytes _data
    ) public;
}

//normal contract. already compiled as bin
contract Controlled {
    
    ///  a function with this modifier
    modifier onlyController { 
        require(msg.sender == controller); 
        _; 
    }

    //block for check//bool private initialed = false;
    address public controller;

    constructor() public {
      controller = msg.sender;
    }

    
    
    function changeController(address _newController) onlyController public {
        controller = _newController;
    }
}

//abstract contract. used for interface
contract TokenController {
    
    
    
    function proxyPayment(address _owner) payable public returns(bool);

    
    ///  controller to react if desired
    
    
    
    
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

    
    ///  controller to react if desired
    
    
    
    
    function onApprove(address _owner, address _spender, uint _amount) public returns(bool);
}

contract ERC20Token {
    /* This is a slight change to the ERC20 base standard.
      function totalSupply() constant returns (uint256 supply);
      is replaced with:
      uint256 public totalSupply;
      This automatically creates a getter function for the totalSupply.
      This is moved to the base contract since public getter functions are not
      currently recognised as an implementation of the matching abstract
      function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;
    //function totalSupply() public constant returns (uint256 balance);

    
    
    mapping (address => uint256) public balanceOf;
    //function balanceOf(address _owner) public constant returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) public returns (bool success);

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) public returns (bool success);

    
    
    
    mapping (address => mapping (address => uint256)) public allowance;
    //function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract TokenI is ERC20Token, Controlled {

    string public name;                //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals = 18;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP


    // ERC20 Methods

    
    ///  its behalf, and then a function is triggered in the contract that is
    ///  being approved, `_spender`. This allows users to use their tokens to
    ///  interact with contracts in one function call instead of two
    
    
    
    function approveAndCall(
        address _spender,
        uint256 _amount,
        bytes _extraData
    ) public returns (bool success);


    // Generate and destroy tokens

    
    
    
    
    function generateTokens(address _owner, uint _amount) public returns (bool);


    
    
    
    
    function destroyTokens(address _owner, uint _amount) public returns (bool);

    
    
    function enableTransfers(bool _transfersEnabled) public;


    // Safety Methods

    
    ///  sent tokens to this contract.
    
    ///  set to 0 in case you want to extract ether.
    
    function claimTokens(address[] _tokens, address _to) public;


    // Events

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
}

contract Token is TokenI {
    using SafeMath for uint256;

    string public techProvider = "WeYii Tech";
    string public officialSite = "http://www.beautybloc.io";

    //owner是最初的币持有者。对比之下，controller 是合约操作者
    address public owner;

    struct FreezeInfo {
        address user;
        uint256 amount;
    }
    //Key1: step(募资阶段); Key2: user sequence(用户序列)
    mapping (uint8 => mapping (uint32 => FreezeInfo)) public freezeOf; //所有锁仓，key 使用序号向上增加，方便程序查询。
    mapping (uint8 => uint32) public lastFreezeSeq; //最后的 freezeOf 键值。key: step; value: sequence

    bool public transfersEnabled = true;

    /* This generates a public event on the blockchain that will notify clients */
    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);
    
    /* This notifies clients about the amount frozen */
    event Freeze(address indexed from, uint256 value);
    
    /* This notifies clients about the amount unfrozen */
    event Unfreeze(address indexed from, uint256 value);

    event TransferMulti(uint256 userLen, uint256 valueAmount);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
        address initialOwner
        ) public {
        owner = initialOwner;
        totalSupply = initialSupply * uint256(10) ** decimals;
        balanceOf[owner] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier ownerOrController() {
        require(msg.sender == owner || msg.sender == controller);
        _;
    }

    modifier transable(){
        require(transfersEnabled == true);
        _;
    }

    modifier realUser(address user){
        require(user != 0x0);
        _;
    }

    
    
    
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) {
            return false;
        }
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) realUser(_to) transable public returns (bool) {
        require(balanceOf[msg.sender] >= _value);          // Check if the sender has enough
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
        return true;
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) transable public returns (bool success) {
        require(_value == 0 || (allowance[msg.sender][_spender] == 0));
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @notice `msg.sender` approves `_spender` to send `_amount` tokens on
     *  its behalf, and then a function is triggered in the contract that is
     *  being approved, `_spender`. This allows users to use their tokens to
     *  interact with contracts in one function call instead of two
     * @param _spender The address of the contract able to transfer the tokens
     * @param _amount The amount of tokens to be approved for transfer
     * @return True if the function call was successful
     */
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData) transable public returns (bool success) {
        require(approve(_spender, _amount));

        ApproveAndCallReceiver(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) realUser(_from) realUser(_to) transable public returns (bool success) {
        require(balanceOf[_from] >= _value);                 // Check if the sender has enough
        require(balanceOf[_to] + _value > balanceOf[_to]);   // Check for overflows
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        balanceOf[_from] = balanceOf[_from].sub(_value);                           // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value);                             // Add the same to the recipient
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transferMulti(address[] _to, uint256[] _value) transable public returns (uint256 amount){
        require(_to.length == _value.length && _to.length <= 1024);
        uint256 balanceOfSender = balanceOf[msg.sender];
        uint256 len = _to.length;
        for(uint256 j; j<len; j++){
            amount = amount.add(_value[j]);
        }
        balanceOf[msg.sender] = balanceOfSender.sub(amount);
        address _toI;
        uint256 _valueI;
        for(uint256 i; i<len; i++){
            _toI = _to[i];
            _valueI = _value[i];
            balanceOf[_toI] = balanceOf[_toI].add(_valueI);
            emit Transfer(msg.sender, _toI, _valueI);
        }
        emit TransferMulti(len, amount);
    }
    
    //对多人按相同数量转账
    function transferMultiSameVaule(address[] _to, uint256 _value) transable public returns (bool success){
        uint256 len = _to.length;
        uint256 amount = _value.mul(len);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount); //this will check enough automatically
        address _toI;
        for(uint256 i; i<len; i++){
            _toI = _to[i];
            balanceOf[_toI] = balanceOf[_toI].add(_value);
            emit Transfer(msg.sender, _toI, _value);
        }
        emit TransferMulti(len, amount);
        return true;
    }
    
    //只owner和controller 才能冻结账户
    function freeze(address _user, uint256 _value, uint8 _step) ownerOrController public returns (bool success) {
        require(balanceOf[_user] >= _value);
        balanceOf[_user] = balanceOf[_user] - _value;
        freezeOf[_step][lastFreezeSeq[_step]] = FreezeInfo({user:_user, amount:_value});
        lastFreezeSeq[_step]++;
        emit Freeze(_user, _value);
        return true;
    }
    
    //为用户解锁账户资金
    function unFreeze(uint8 _step) ownerOrController public returns (bool unlockOver) {
        uint32 _end = lastFreezeSeq[_step];
        require(_end > 0);
        unlockOver = (_end <= 99);
        uint32 _start = (_end > 99) ? _end-100 : 0;
        for(; _end>_start; _end--){
            FreezeInfo storage fInfo = freezeOf[_step][_end-1];
            uint256 _amount = fInfo.amount;
            balanceOf[fInfo.user] += _amount;
            delete freezeOf[_step][_end-1];
            lastFreezeSeq[_step]--;
            emit Unfreeze(fInfo.user, _amount);
        }
    }
    
    //accept ether
    function() payable public {
        //屏蔽控制方的合约类型检查，以兼容发行方无控制合约的情况。
        require(isContract(controller));
        bool proxyPayment = TokenController(controller).proxyPayment.value(msg.value)(msg.sender);
        require(proxyPayment);
    }

    ////////////////
    // Generate and destroy tokens
    ////////////////

    
    
    
    
    function generateTokens(address _user, uint _amount) onlyController public returns (bool) {
        require(balanceOf[owner] >= _amount);
        balanceOf[_user] += _amount;
        balanceOf[owner] -= _amount;
        emit Transfer(0, _user, _amount);
        return true;
    }

    
    
    
    
    function destroyTokens(address _user, uint _amount) onlyController public returns (bool) {
        require(balanceOf[_user] >= _amount);
        balanceOf[owner] += _amount;
        balanceOf[_user] -= _amount;
        emit Transfer(_user, 0, _amount);
        emit Burn(_user, _amount);
        return true;
    }

    ////////////////
    // Enable tokens transfers
    ////////////////

    
    
    function enableTransfers(bool _transfersEnabled) ownerOrController public {
        transfersEnabled = _transfersEnabled;
    }

    //////////
    // Safety Methods
    //////////

    
    ///  sent tokens to this contract.
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address[] tokens, address to) onlyOwner public {
        if(to == 0x0){
            to = owner;
        }
        address _token;
        uint256 balance;
        uint256 len = tokens.length;
        for(uint256 i; i<len; i++){
            _token = tokens[i];
            if (_token == 0x0) {
                balance = address(this).balance;
                if(balance > 0){
                    to.transfer(balance);
                }
            }else{
                ERC20Token token = ERC20Token(_token);
                balance = token.balanceOf(address(this));
                token.transfer(to, balance);
                emit ClaimedTokens(_token, to, balance);
            }
        }
    }

    function changeOwner(address newOwner) onlyOwner public returns (bool) {
        balanceOf[newOwner] = balanceOf[owner].add(balanceOf[newOwner]);
        balanceOf[owner] = 0;
        owner = newOwner;
        return true;
    }
}