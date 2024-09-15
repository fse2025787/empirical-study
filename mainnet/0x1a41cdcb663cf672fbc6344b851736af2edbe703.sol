
pragma solidity ^0.4.11;


/**
 * Math operations with safety checks
 */
library SafeMath {
    function mul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a < b ? a : b;
    }
}

///  later changed
contract Owned {

    
    /// modifier
    modifier onlyOwner() {
        if(msg.sender != owner) throw;
        _;
    }

    address public owner;

    
    function Owned() {
        owner = msg.sender;
    }

    address public newOwner;

    
    
    ///  an unowned neutral vault, however that cannot be undone
    function changeOwner(address _newOwner) onlyOwner {
        newOwner = _newOwner;
    }


    function acceptOwnership() {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }
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

    
    
    function balanceOf(address _owner) constant returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) returns (bool success);

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) returns (bool success);

    
    
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract TokenController {
    
    
    
    function proxyPayment(address _owner) payable returns(bool);

    
    ///  controller to react if desired
    
    
    
    
    function onTransfer(address _from, address _to, uint _amount) returns(bool);

    
    ///  controller to react if desired
    
    
    
    
    function onApprove(address _owner, address _spender, uint _amount)
    returns(bool);
}

contract Controlled {
    
    ///  a function with this modifier
    modifier onlyController { if (msg.sender != controller) throw; _; }

    address public controller;

    function Controlled() { controller = msg.sender;}

    
    
    function changeController(address _newController) onlyController {
        controller = _newController;
    }
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data);
}


///  that deploys the contract, so usually this token will be deployed by a
///  token controller contract, which Giveth will call a "Campaign"
contract MiniMeToken is Controlled {

    string public name;                //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public version = 'MMT_0.1'; //An arbitrary versioning scheme


    
    ///  given value, the block number attached is the one that last changed the
    ///  value
    struct  Checkpoint {

    // `fromBlock` is the block number that the value was generated from
    uint128 fromBlock;

    // `value` is the amount of tokens at a specific block number
    uint128 value;
    }

    // `parentToken` is the Token address that was cloned to produce this token;
    //  it will be 0x0 for a token that was not cloned
    MiniMeToken public parentToken;

    // `parentSnapShotBlock` is the block number from the Parent Token that was
    //  used to determine the initial distribution of the Clone Token
    uint public parentSnapShotBlock;

    // `creationBlock` is the block number that the Clone Token was created
    uint public creationBlock;

    // `balances` is the map that tracks the balance of each address, in this
    //  contract when the balance changes the block number that the change
    //  occurred is also included in the map
    mapping (address => Checkpoint[]) balances;

    // `allowed` tracks any extra transfer rights as in all ERC20 tokens
    mapping (address => mapping (address => uint256)) allowed;

    // Tracks the history of the `totalSupply` of the token
    Checkpoint[] totalSupplyHistory;

    // Flag that determines if the token is transferable or not.
    bool public transfersEnabled;

    // The factory used to create new clone tokens
    MiniMeTokenFactory public tokenFactory;

    ////////////////
    // Constructor
    ////////////////

    
    
    ///  will create the Clone token contracts, the token factory needs to be
    ///  deployed first
    
    ///  new token
    
    ///  determine the initial distribution of the clone token, set to 0 if it
    ///  is a new token
    
    
    
    
    function MiniMeToken(
    address _tokenFactory,
    address _parentToken,
    uint _parentSnapShotBlock,
    string _tokenName,
    uint8 _decimalUnits,
    string _tokenSymbol,
    bool _transfersEnabled
    ) {
        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                 // Set the name
        decimals = _decimalUnits;                          // Set the decimals
        symbol = _tokenSymbol;                             // Set the symbol
        parentToken = MiniMeToken(_parentToken);
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = getBlockNumber();
    }


    ///////////////////
    // ERC20 Methods
    ///////////////////

    
    
    
    
    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (!transfersEnabled) throw;
        return doTransfer(msg.sender, _to, _amount);
    }

    
    ///  is approved by `_from`
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _amount
    ) returns (bool success) {

        // The controller of this contract can move tokens around at will,
        //  this is important to recognize! Confirm that you trust the
        //  controller of this contract, which in most situations should be
        //  another open source smart contract or 0x0
        if (msg.sender != controller) {
            if (!transfersEnabled) throw;

            // The standard ERC 20 transferFrom functionality
            if (allowed[_from][msg.sender] < _amount) return false;
            allowed[_from][msg.sender] -= _amount;
        }
        return doTransfer(_from, _to, _amount);
    }

    
    ///  only be called by other functions in this contract.
    
    
    
    
    function doTransfer(address _from, address _to, uint _amount
    ) internal returns(bool) {

        if (_amount == 0) {
            return true;
        }

        if (parentSnapShotBlock >= getBlockNumber()) throw;

        // Do not allow transfer to 0x0 or the token contract itself
        if ((_to == 0) || (_to == address(this))) throw;

        // If the amount being transfered is more than the balance of the
        //  account the transfer returns false
        var previousBalanceFrom = balanceOfAt(_from, getBlockNumber());
        if (previousBalanceFrom < _amount) {
            return false;
        }

        // Alerts the token controller of the transfer
        if (isContract(controller)) {
            if (!TokenController(controller).onTransfer(_from, _to, _amount))
            throw;
        }

        // First update the balance array with the new value for the address
        //  sending the tokens
        updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

        // Then update the balance array with the new value for the address
        //  receiving the tokens
        var previousBalanceTo = balanceOfAt(_to, getBlockNumber());
        if (previousBalanceTo + _amount < previousBalanceTo) throw; // Check for overflow
        updateValueAtNow(balances[_to], previousBalanceTo + _amount);

        // An event to make the transfer easy to find on the blockchain
        Transfer(_from, _to, _amount);

        return true;
    }

    
    
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balanceOfAt(_owner, getBlockNumber());
    }

    
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    
    
    
    function approve(address _spender, uint256 _amount) returns (bool success) {
        if (!transfersEnabled) throw;

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if ((_amount!=0) && (allowed[msg.sender][_spender] !=0)) throw;

        // Alerts the token controller of the approve function call
        if (isContract(controller)) {
            if (!TokenController(controller).onApprove(msg.sender, _spender, _amount))
            throw;
        }

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    
    
    
    
    ///  to spend
    function allowance(address _owner, address _spender
    ) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    
    ///  its behalf, and then a function is triggered in the contract that is
    ///  being approved, `_spender`. This allows users to use their tokens to
    ///  interact with contracts in one function call instead of two
    
    
    
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) returns (bool success) {
        if (!approve(_spender, _amount)) throw;

        ApproveAndCallFallBack(_spender).receiveApproval(
        msg.sender,
        _amount,
        this,
        _extraData
        );

        return true;
    }

    
    
    function totalSupply() constant returns (uint) {
        return totalSupplyAt(getBlockNumber());
    }


    ////////////////
    // Query balance and totalSupply in History
    ////////////////

    
    
    
    
    function balanceOfAt(address _owner, uint _blockNumber) constant
    returns (uint) {

        // These next few lines are used when the balance of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.balanceOfAt` be queried at the
        //  genesis block for that token as this contains initial balance of
        //  this token
        if ((balances[_owner].length == 0)
        || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
            } else {
                // Has no parent
                return 0;
            }

            // This will return the expected balance during normal situations
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    
    
    
    function totalSupplyAt(uint _blockNumber) constant returns(uint) {

        // These next few lines are used when the totalSupply of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.totalSupplyAt` be queried at the
        //  genesis block for this token as that contains totalSupply of this
        //  token at this block number.
        if ((totalSupplyHistory.length == 0)
        || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

            // This will return the expected totalSupply during normal situations
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

    ////////////////
    // Clone Token Method
    ////////////////

    
    ///  this token at `_snapshotBlock`
    
    
    
    
    ///  copied to set the initial distribution of the new clone token;
    ///  if the block is zero than the actual block, the current block is used
    
    
    function createCloneToken(
    string _cloneTokenName,
    uint8 _cloneDecimalUnits,
    string _cloneTokenSymbol,
    uint _snapshotBlock,
    bool _transfersEnabled
    ) returns(address) {
        if (_snapshotBlock == 0) _snapshotBlock = getBlockNumber();
        MiniMeToken cloneToken = tokenFactory.createCloneToken(
        this,
        _snapshotBlock,
        _cloneTokenName,
        _cloneDecimalUnits,
        _cloneTokenSymbol,
        _transfersEnabled
        );

        cloneToken.changeController(msg.sender);

        // An event to make the token easy to find on the blockchain
        NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }

    ////////////////
    // Generate and destroy tokens
    ////////////////

    
    
    
    
    function generateTokens(address _owner, uint _amount
    ) onlyController returns (bool) {
        uint curTotalSupply = getValueAt(totalSupplyHistory, getBlockNumber());
        if (curTotalSupply + _amount < curTotalSupply) throw; // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        var previousBalanceTo = balanceOf(_owner);
        if (previousBalanceTo + _amount < previousBalanceTo) throw; // Check for overflow
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        Transfer(0, _owner, _amount);
        return true;
    }


    
    
    
    
    function destroyTokens(address _owner, uint _amount
    ) onlyController returns (bool) {
        uint curTotalSupply = getValueAt(totalSupplyHistory, getBlockNumber());
        if (curTotalSupply < _amount) throw;
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        var previousBalanceFrom = balanceOf(_owner);
        if (previousBalanceFrom < _amount) throw;
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        Transfer(_owner, 0, _amount);
        return true;
    }

    ////////////////
    // Enable tokens transfers
    ////////////////


    
    
    function enableTransfers(bool _transfersEnabled) onlyController {
        transfersEnabled = _transfersEnabled;
    }

    ////////////////
    // Internal helper functions to query and set a value in a snapshot array
    ////////////////

    
    
    
    
    function getValueAt(Checkpoint[] storage checkpoints, uint _block
    ) constant internal returns (uint) {
        if (checkpoints.length == 0) return 0;

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
        return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        // Binary search of the value in the array
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    
    ///  `totalSupplyHistory`
    
    
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal  {
        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < getBlockNumber())) {
            Checkpoint newCheckPoint = checkpoints[ checkpoints.length++ ];
            newCheckPoint.fromBlock =  uint128(getBlockNumber());
            newCheckPoint.value = uint128(_value);
        } else {
            Checkpoint oldCheckPoint = checkpoints[checkpoints.length-1];
            oldCheckPoint.value = uint128(_value);
        }
    }

    
    
    
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
        size := extcodesize(_addr)
        }
        return size>0;
    }

    
    function min(uint a, uint b) internal returns (uint) {
        return a < b ? a : b;
    }

    
    ///  set to 0, then the `proxyPayment` method is called which relays the
    ///  ether and creates tokens as described in the token controller contract
    function ()  payable {
        if (isContract(controller)) {
            if (! TokenController(controller).proxyPayment.value(msg.value)(msg.sender))
            throw;
        } else {
            throw;
        }
    }


    //////////
    // Testing specific methods
    //////////

    
    function getBlockNumber() internal constant returns (uint256) {
        return block.number;
    }

    //////////
    // Safety Methods
    //////////

    
    ///  sent tokens to this contract.
    
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) onlyController {
        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        ERC20Token token = ERC20Token(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
    }

    ////////////////
    // Events
    ////////////////

    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
    address indexed _owner,
    address indexed _spender,
    uint256 _amount
    );

}


////////////////
// MiniMeTokenFactory
////////////////


///  In solidity this is the way to create a contract from a contract of the
///  same class
contract MiniMeTokenFactory {

    
    ///  the msg.sender becomes the controller of this clone token
    
    
    ///  determine the initial distribution of the clone token
    
    
    
    
    
    function createCloneToken(
    address _parentToken,
    uint _snapshotBlock,
    string _tokenName,
    uint8 _decimalUnits,
    string _tokenSymbol,
    bool _transfersEnabled
    ) returns (MiniMeToken) {
        MiniMeToken newToken = new MiniMeToken(
        this,
        _parentToken,
        _snapshotBlock,
        _tokenName,
        _decimalUnits,
        _tokenSymbol,
        _transfersEnabled
        );

        newToken.changeController(msg.sender);
        return newToken;
    }
}

contract FCCContribution is Owned, TokenController {

    using SafeMath for uint256;
    MiniMeToken public FCC;

    uint256 public constant MIN_FUND = (0.001 ether);
    uint256 public constant CRAWDSALE_END_DAY = 2;

    uint256 public dayCycle = 10 days;
    uint256 public startTimeEarlyBird=0 ;
    uint256 public startTime=0 ;
    uint256 public endTime =0;
    uint256 public finalizedBlock=0;
    uint256 public finalizedTime=0;

    bool public isFinalize = false;
    bool public isPause = false;

    uint256 public totalContributedETH = 0;
    uint256 public totalTokenSaled=0;

    uint256 public MaxEth=5000 ether;

    uint256[] public ratio;

    address public fccController;
    address public destEthFoundationDev;
    address public destEthFoundation;
    uint256 public proportion;

    bool public paused;

    modifier initialized() {
        require(address(FCC) != 0x0);
        _;
    }

    modifier contributionOpen() {
        require(time() >= startTimeEarlyBird &&
        time() <= endTime &&
        finalizedBlock == 0 &&
        address(FCC) != 0x0);
        _;
    }

    modifier notPaused() {
        require(!paused);
        _;
    }

    function FCCContribution() {
        paused = false;
        ratio.push(19500);
        ratio.push(18500);
        ratio.push(17500);
    }


    
    ///  period starts This initializes most of the parameters
    
    
    ///  the contribution finalizes.
    
    
    
    
    
    function initialize(
    address _fcc,
    address _fccController,
    uint256 _startTimeEarlyBird,
    uint256 _startTime,
    uint256 _endTime,
    uint256 _dayCycle,
    address _destEthFoundationDev,
    address _destEthFoundation,
    uint256 _proportion    //30 mean 0.3
    ) public onlyOwner {
        // Initialize only once
        require(address(FCC) == 0x0);

        FCC = MiniMeToken(_fcc);
        require(FCC.totalSupply() == 0);
        require(FCC.controller() == address(this));
        require(FCC.decimals() == 18);  // Same amount of decimals as ETH

        startTime = _startTime;
        startTimeEarlyBird=_startTimeEarlyBird;
        endTime = _endTime;
        dayCycle=_dayCycle;

        assert(startTime < endTime);

        require(_fccController != 0x0);
        fccController = _fccController;

        require(_destEthFoundationDev != 0x0);
        destEthFoundationDev = _destEthFoundationDev;

        require(_destEthFoundation != 0x0);
        destEthFoundation = _destEthFoundation;

        proportion=_proportion;

    }

    function changeRatio(uint256 _day,uint256 _ratio)onlyOwner{
        ratio[_day]=_ratio;
    }

    
    ///  getting FCCs.
    function () public payable notPaused {
        if(totalContributedETH>=MaxEth) throw;
        proxyPayment(msg.sender);
    }


    //////////
    // MiniMe Controller functions
    //////////

    
    ///  acquire FCCs. Or directly from third parties that want to acquire FCCs in
    ///  behalf of a token holder.
    
    function proxyPayment(address _account) public payable initialized contributionOpen returns (bool) {
        require(_account != 0x0);
        uint256 day = today();

        require( msg.value >= MIN_FUND );

        uint256 toDev;
        if(proportion<100){
            toDev=msg.value*100/proportion;
            destEthFoundationDev.transfer(toDev);
            destEthFoundation.transfer(msg.value-toDev);
        }else
        {
            destEthFoundationDev.transfer(msg.value);
        }

        uint256 r=ratio[day];
        require(r>0);

        uint256 tokenSaling=r.mul(msg.value);
        assert(FCC.generateTokens(_account,tokenSaling));

        totalContributedETH += msg.value;
        totalTokenSaled+=tokenSaling;

        NewSale(day, msg.sender, msg.value);
    }
    function onTransfer(address, address, uint256) public returns (bool) {
        return false;
    }

    function onApprove(address, address, uint256) public returns (bool) {
        return false;
    }
    function issueTokenToAddress(address _account, uint256 _amount,uint256 _ethAmount) onlyOwner initialized {


        assert(FCC.generateTokens(_account, _amount));

        totalContributedETH +=_amount;

        NewIssue(_account, _amount, _ethAmount);

    }

    function finalize() public onlyOwner initialized {
        require(time() >= startTime);

        require(finalizedBlock == 0);

        finalizedTime = getBlockNumber();
        finalizedTime = now;

        FCC.changeController(fccController);
        Finalized();
    }

    
    
    
    function isContract(address _addr) constant internal returns (bool) {
        if (_addr == 0) return false;
        uint256 size;
        assembly {
        size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function time() constant returns (uint) {
        return block.timestamp;
    }

    //////////
    // Constant functions
    //////////

    
    function tokensIssued() public constant returns (uint256) {
        return FCC.totalSupply();
    }

    //////////
    // Testing specific methods
    //////////

    
    function getBlockNumber() internal constant returns (uint256) {
        return block.number;
    }

    //////////
    // Safety Methods
    //////////

    
    ///  sent tokens to this contract.
    
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) public onlyOwner {
        if (FCC.controller() == address(this)) {
            FCC.claimTokens(_token);
        }
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }

        ERC20Token token = ERC20Token(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(owner, balance);
        ClaimedTokens(_token, owner, balance);
    }

    
    function pauseContribution() onlyOwner {
        paused = true;
    }

    
    function resumeContribution() onlyOwner {
        paused = false;
    }

    function today() constant returns (uint) {
        if(now<startTime)
        return 0;
        return now.sub( startTime) / dayCycle + 1;
    }
    event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
    event NewSale(uint256 _day ,address _account, uint256 _amount);
    event NewIssue(address indexed _th, uint256 _amount, uint256  _ethAmount);
    event Finalized();
}
contract FCCPlaceHolder is TokenController, Owned {
    using SafeMath for uint256;

    MiniMeToken public fcc;
    FCCContribution public contribution;
    uint256 public activationTime;

    mapping(address => bool) public whitelist;

    
    
    
    
    function FCCPlaceHolder(address _owner, address _fcc, address _contribution) {
        owner = _owner;
        fcc = MiniMeToken(_fcc);
        contribution = FCCContribution(_contribution);
    }

    
    ///  Please, be sure that the owner is a trusted agent or 0x0 address.
    
    function changeController(address _newController) public onlyOwner {
        fcc.changeController(_newController);
        ControllerChanged(_newController);
    }


    //////////
    // MiniMe Controller Interface functions
    //////////

    // In between the offering and the network. Default settings for allowing token transfers.
    function proxyPayment(address) public payable returns (bool) {
        return false;
    }

    function onTransfer(address _from, address, uint256) public returns (bool) {
        return transferable(_from);
    }

    function onApprove(address _from, address, uint256) public returns (bool) {
        return transferable(_from);
    }

    function transferable(address _from) internal returns (bool) {
        // Allow the exchanger to work from the beginning
        if (activationTime == 0) {
            uint256 f = contribution.finalizedTime();
            if (f > 0) {
                activationTime = f.add(60);
            } else {
                return false;
            }
        }
        return (getTime() > activationTime) || (whitelist[_from] == true);
    }


    //////////
    // Testing specific methods
    //////////

    
    function getTime() internal returns (uint256) {
        return now;
    }


    //////////
    // Safety Methods
    //////////

    
    ///  sent tokens to this contract.
    
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) public onlyOwner {
        if (fcc.controller() == address(this)) {
            fcc.claimTokens(_token);
        }
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }

        ERC20Token token = ERC20Token(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(owner, balance);
        ClaimedTokens(_token, owner, balance);
    }

    event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
    event ControllerChanged(address indexed _newController);
}