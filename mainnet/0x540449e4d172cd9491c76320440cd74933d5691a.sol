
pragma solidity ^0.4.8;

// accepted from zeppelin-solidity https://github.com/OpenZeppelin/zeppelin-solidity
/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
    uint public totalSupply;
    function balanceOf(address who) constant returns (uint);
    function allowance(address owner, address spender) constant returns (uint);

    function transfer(address to, uint value) returns (bool ok);
    function transferFrom(address from, address to, uint value) returns (bool ok);
    function approve(address spender, uint value) returns (bool ok);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

// accepted from zeppelin-solidity https://github.com/OpenZeppelin/zeppelin-solidity

/**
 * Math operations with safety checks
 */
contract SafeMath {
    function safeMul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b) internal returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
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

    function assert(bool assertion) internal {
        if (!assertion) {
            throw;
        }
    }

}



contract MultiSigWallet {

    // flag to determine if address is for a real contract or not
    bool public isMultiSigWallet = false;

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

    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] public owners;
    uint public required;
    uint public transactionCount;

    struct Transaction {
    address destination;
    uint value;
    bytes data;
    bool executed;
    }

    modifier onlyWallet() {
        if (msg.sender != address(this)) throw;
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        if (isOwner[owner]) throw;
        _;
    }

    modifier ownerExists(address owner) {
        if (!isOwner[owner]) throw;
        _;
    }

    modifier transactionExists(uint transactionId) {
        if (transactions[transactionId].destination == 0) throw;
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        if (!confirmations[transactionId][owner]) throw;
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        if (confirmations[transactionId][owner]) throw;
        _;
    }

    modifier notExecuted(uint transactionId) {
        if (transactions[transactionId].executed) throw;
        _;
    }

    modifier notNull(address _address) {
        if (_address == 0) throw;
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        if (ownerCount > MAX_OWNER_COUNT) throw;
        if (_required > ownerCount) throw;
        if (_required == 0) throw;
        if (ownerCount == 0) throw;
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
            if (isOwner[_owners[i]] || _owners[i] == 0) throw;
            isOwner[_owners[i]] = true;
        }
        isMultiSigWallet = true;
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

    
    
    
    
    function replaceOwnerIndexed(address owner, address newOwner, uint index)
    public
    onlyWallet
    ownerExists(owner)
    ownerDoesNotExist(newOwner)
    {
        if (owners[index] != owner) throw;
        owners[index] = newOwner;
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

    
    
    function executeTransaction(uint transactionId)
    internal
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
        if ((pending && !transactions[i].executed) ||
        (executed && transactions[i].executed))
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
        if ((pending && !transactions[i].executed) ||
        (executed && transactions[i].executed))
        {
            transactionIdsTemp[count] = i;
            count += 1;
        }
        _transactionIds = new uint[](to - from);
        for (i=from; i<to; i++)
        _transactionIds[i - from] = transactionIdsTemp[i];
    }

}

contract UpgradeAgent is SafeMath {
    address public owner;

    bool public isUpgradeAgent;

    function upgradeFrom(address _from, uint256 _value) public;

    function finalizeUpgrade() public;

    function setOriginalSupply() public;
}


contract DecentBetVault is SafeMath {

    // flag to determine if address is for a real contract or not
    bool public isDecentBetVault = false;

    DecentBetToken decentBetToken;

    address decentBetMultisig;

    uint256 unlockedAtTime;

    // smaller lock for testing
    uint256 public constant timeOffset = 1 years;

    
    /// total number of locked tokens to transfer
    function DecentBetVault(address _decentBetMultisig) /** internal */ {
        if (_decentBetMultisig == 0x0) throw;
        decentBetToken = DecentBetToken(msg.sender);
        decentBetMultisig = _decentBetMultisig;
        isDecentBetVault = true;

        // 1 year later
        unlockedAtTime = safeAdd(getTime(), timeOffset);
    }

    
    function unlock() external {
        // Wait your turn!
        if (getTime() < unlockedAtTime) throw;
        // Will fail if allocation (and therefore toTransfer) is 0.
        if (!decentBetToken.transfer(decentBetMultisig, decentBetToken.balanceOf(this))) throw;
    }

    function getTime() internal returns (uint256) {
        return now;
    }

    // disallow ETH payments to TimeVault
    function() payable {
        throw;
    }

}



contract DecentBetToken is SafeMath, ERC20 {

    // flag to determine if address is for a real contract or not
    bool public isDecentBetToken = false;

    // State machine
    enum State{Waiting, PreSale, CommunitySale, PublicSale, Success}

    // Token information
    string public constant name = "Decent.Bet Token";

    string public constant symbol = "DBET";

    uint256 public constant decimals = 18;  // decimal places

    uint256 public constant housePercentOfTotal = 10;

    uint256 public constant vaultPercentOfTotal = 18;

    uint256 public constant bountyPercentOfTotal = 2;

    uint256 public constant crowdfundPercentOfTotal = 70;

    uint256 public constant hundredPercent = 100;

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

    // Authorized addresses
    address public team;

    // Upgrade information
    bool public finalizedUpgrade = false;

    address public upgradeMaster;

    UpgradeAgent public upgradeAgent;

    uint256 public totalUpgraded;

    // Crowdsale information
    bool public finalizedCrowdfunding = false;

    // Whitelisted addresses for pre-sale
    address[] public preSaleWhitelist;
    mapping (address => bool) public preSaleAllowed;

    // Whitelisted addresses from community
    address[] public communitySaleWhitelist;
    mapping (address => bool) public communitySaleAllowed;
    uint[2] public communitySaleCap = [100000 ether, 200000 ether];
    mapping (address => uint[2]) communitySalePurchases;

    uint256 public preSaleStartTime; // Pre-sale start block timestamp
    uint256 public fundingStartTime; // crowdsale start block timestamp
    uint256 public fundingEndTime; // crowdsale end block timestamp
    // DBET:ETH exchange rate - Needs to be updated at time of ICO.
    // Price of ETH/0.125. For example: If ETH/USD = 300, it would be 2400 DBETs per ETH.
    uint256 public baseTokensPerEther;
    uint256 public tokenCreationMax = safeMul(250000 ether, 1000); // A maximum of 250M DBETs can be minted during ICO.

    // Amount of tokens alloted to pre-sale investors.
    uint256 public preSaleAllotment;
    // Address of pre-sale investors.
    address public preSaleAddress;

    // for testing on testnet
    //uint256 public constant tokenCreationMax = safeMul(10 ether, baseTokensPerEther);
    //uint256 public constant tokenCreationMin = safeMul(3 ether, baseTokensPerEther);

    address public decentBetMultisig;

    DecentBetVault public timeVault; // DecentBet's time-locked vault

    event Upgrade(address indexed _from, address indexed _to, uint256 _value);

    event UpgradeFinalized(address sender, address upgradeAgent);

    event UpgradeAgentSet(address agent);

    // Allow only the team address to continue
    modifier onlyTeam() {
        if(msg.sender != team) throw;
        _;
    }

    function DecentBetToken(address _decentBetMultisig,
    address _upgradeMaster, address _team,
    uint256 _baseTokensPerEther, uint256 _fundingStartTime,
    uint256 _fundingEndTime) {

        if (_decentBetMultisig == 0) throw;
        if (_team == 0) throw;
        if (_upgradeMaster == 0) throw;
        if (_baseTokensPerEther == 0) throw;

        // For testing/dev
        //         if(_fundingStartTime == 0) throw;
        // Crowdsale can only officially start during/after the current block timestamp.
        if (_fundingStartTime < getTime()) throw;

        if (_fundingEndTime <= _fundingStartTime) throw;

        isDecentBetToken = true;

        upgradeMaster = _upgradeMaster;
        team = _team;

        baseTokensPerEther = _baseTokensPerEther;

        preSaleStartTime = _fundingStartTime - 1 days;
        fundingStartTime = _fundingStartTime;
        fundingEndTime = _fundingEndTime;

        // Pre-sale issuance from pre-sale contract
        // 0x7be601aab2f40cc23653965749b84e5cb8cfda43
        preSaleAddress = 0x87f7beeda96216ec2a325e417a45ed262495686b;
        preSaleAllotment = 45000000 ether;

        balances[preSaleAddress] = preSaleAllotment;
        totalSupply = safeAdd(totalSupply, preSaleAllotment);

        timeVault = new DecentBetVault(_decentBetMultisig);
        if (!timeVault.isDecentBetVault()) throw;

        decentBetMultisig = _decentBetMultisig;
        if (!MultiSigWallet(decentBetMultisig).isMultiSigWallet()) throw;
    }

    function balanceOf(address who) constant returns (uint) {
        return balances[who];
    }

    
    /// `msg.sender` to provided account address `to`.
    
    
    
    
    
    function transfer(address to, uint256 value) returns (bool ok) {
        if (getState() != State.Success) throw;
        // Abort if crowdfunding was not a success.
        uint256 senderBalance = balances[msg.sender];
        if (senderBalance >= value && value > 0) {
            senderBalance = safeSub(senderBalance, value);
            balances[msg.sender] = senderBalance;
            balances[to] = safeAdd(balances[to], value);
            Transfer(msg.sender, to, value);
            return true;
        }
        return false;
    }

    
    /// to provided account address `to`.
    
    
    
    
    
    
    function transferFrom(address from, address to, uint256 value) returns (bool ok) {
        if (getState() != State.Success) throw;
        // Abort if not in Success state.
        // protect against wrapping uints
        if (balances[from] >= value &&
        allowed[from][msg.sender] >= value &&
        safeAdd(balances[to], value) > balances[to])
        {
            balances[to] = safeAdd(balances[to], value);
            balances[from] = safeSub(balances[from], value);
            allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], value);
            Transfer(from, to, value);
            return true;
        }
        else {return false;}
    }

    
    
    
    
    function approve(address spender, uint256 value) returns (bool ok) {
        if (getState() != State.Success) throw;
        // Abort if not in Success state.
        allowed[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        return true;
    }

    
    
    
    function allowance(address owner, address spender) constant returns (uint) {
        return allowed[owner][spender];
    }

    // Token upgrade functionality

    
    
    
    function upgrade(uint256 value) external {
        if (getState() != State.Success) throw;
        // Abort if not in Success state.
        if (upgradeAgent.owner() == 0x0) throw;
        // need a real upgradeAgent address
        if (finalizedUpgrade) throw;
        // cannot upgrade if finalized

        // Validate input value.
        if (value == 0) throw;
        if (value > balances[msg.sender]) throw;

        // update the balances here first before calling out (reentrancy)
        balances[msg.sender] = safeSub(balances[msg.sender], value);
        totalSupply = safeSub(totalSupply, value);
        totalUpgraded = safeAdd(totalUpgraded, value);
        upgradeAgent.upgradeFrom(msg.sender, value);
        Upgrade(msg.sender, upgradeAgent, value);
    }

    
    /// process.
    
    
    function setUpgradeAgent(address agent) external {
        if (getState() != State.Success) throw;
        // Abort if not in Success state.
        if (agent == 0x0) throw;
        // don't set agent to nothing
        if (msg.sender != upgradeMaster) throw;
        // Only a master can designate the next agent
        upgradeAgent = UpgradeAgent(agent);
        if (!upgradeAgent.isUpgradeAgent()) throw;
        // this needs to be called in success condition to guarantee the invariant is true
        upgradeAgent.setOriginalSupply();
        UpgradeAgentSet(upgradeAgent);
    }

    
    /// process.
    
    
    function setUpgradeMaster(address master) external {
        if (getState() != State.Success) throw;
        // Abort if not in Success state.
        if (master == 0x0) throw;
        if (msg.sender != upgradeMaster) throw;
        // Only a master can designate the next master
        upgradeMaster = master;
    }

    
    
    function finalizeUpgrade() external {
        if (getState() != State.Success) throw;
        // Abort if not in Success state.
        if (upgradeAgent.owner() == 0x0) throw;
        // we need a valid upgrade agent
        if (msg.sender != upgradeMaster) throw;
        // only upgradeMaster can finalize
        if (finalizedUpgrade) throw;
        // can't finalize twice

        finalizedUpgrade = true;
        // prevent future upgrades

        upgradeAgent.finalizeUpgrade();
        // call finalize upgrade on new contract
        UpgradeFinalized(msg.sender, upgradeAgent);
    }

    // Allow users to purchase by sending Ether to the contract
    function() payable {
        invest();
    }

    // Updates tokens per ETH rates before the pre-sale
    function updateBaseTokensPerEther(uint _baseTokensPerEther) onlyTeam {
        if(getState() != State.Waiting) throw;

        baseTokensPerEther = _baseTokensPerEther;
    }

    // Returns the current rate after adding bonuses for the time period
    function getTokensAtCurrentRate(uint weiValue) constant returns (uint) {
        /* Pre-sale */
        if(getTime() >= preSaleStartTime && getTime() < fundingStartTime) {
            return safeDiv(safeMul(weiValue, safeMul(baseTokensPerEther, 120)), 100); // 20% bonus
        }

        /* Community sale */
        else if(getTime() >= fundingStartTime && getTime() < fundingStartTime + 1 days) {
            return safeDiv(safeMul(weiValue, safeMul(baseTokensPerEther, 120)), 100); // 20% bonus
        } else if(getTime() >= (fundingStartTime + 1 days) && getTime() < fundingStartTime + 2 days) {
            return safeDiv(safeMul(weiValue, safeMul(baseTokensPerEther, 120)), 100); // 20% bonus
        }

        /* Public sale */
        else if(getTime() >= (fundingStartTime + 2 days) && getTime() < fundingStartTime + 1 weeks) {
            return safeDiv(safeMul(weiValue, safeMul(baseTokensPerEther, 110)), 100); // 10% bonus
        } else if(getTime() >= fundingStartTime + 1 weeks && getTime() < fundingStartTime + 2 weeks) {
            return safeDiv(safeMul(weiValue, safeMul(baseTokensPerEther, 105)), 100); // 5% bonus
        } else if(getTime() >= fundingStartTime + 2 weeks && getTime() < fundingEndTime) {
            return safeMul(weiValue, baseTokensPerEther); // 0% bonus
        }
    }

    // Allows the owner to add an address to the pre-sale whitelist.
    function addToPreSaleWhitelist(address _address) onlyTeam {

        // Add to pre-sale whitelist only if state is Waiting right now.
        if(getState() != State.Waiting) throw;

        // Address already added to whitelist.
        if (preSaleAllowed[_address]) throw;

        preSaleWhitelist.push(_address);
        preSaleAllowed[_address] = true;
    }

    // Allows the owner to add an address to the community whitelist.
    function addToCommunitySaleWhitelist(address[] addresses) onlyTeam {

        // Add to community sale whitelist only if state is Waiting or Presale right now.
        if(getState() != State.Waiting &&
        getState() != State.PreSale) throw;

        for(uint i = 0; i < addresses.length; i++) {
            if(!communitySaleAllowed[addresses[i]]) {
                communitySaleWhitelist.push(addresses[i]);
                communitySaleAllowed[addresses[i]] = true;
            }
        }
    }

    
    
    
    function invest() payable {

        // Abort if not in PreSale, CommunitySale or PublicSale state.
        if (getState() != State.PreSale &&
        getState() != State.CommunitySale &&
        getState() != State.PublicSale) throw;

        // User hasn't been whitelisted for pre-sale.
        if(getState() == State.PreSale && !preSaleAllowed[msg.sender]) throw;

        // User hasn't been whitelisted for community sale.
        if(getState() == State.CommunitySale && !communitySaleAllowed[msg.sender]) throw;

        // Do not allow creating 0 tokens.
        if (msg.value == 0) throw;

        // multiply by exchange rate to get newly created token amount
        uint256 createdTokens = getTokensAtCurrentRate(msg.value);

        allocateTokens(msg.sender, createdTokens);
    }

    // Allocates tokens to an investors' address
    function allocateTokens(address _address, uint amount) internal {

        // we are creating tokens, so increase the totalSupply.
        totalSupply = safeAdd(totalSupply, amount);

        // don't go over the limit!
        if (totalSupply > tokenCreationMax) throw;

        // Don't allow community whitelisted addresses to purchase more than their cap.
        if(getState() == State.CommunitySale) {
            // Community sale day 1.
            // Whitelisted addresses can purchase a maximum of 100k DBETs (10k USD).
            if(getTime() >= fundingStartTime &&
            getTime() < fundingStartTime + 1 days) {
                if(safeAdd(communitySalePurchases[msg.sender][0], amount) > communitySaleCap[0])
                throw;
                else
                communitySalePurchases[msg.sender][0] =
                safeAdd(communitySalePurchases[msg.sender][0], amount);
            }

            // Community sale day 2.
            // Whitelisted addresses can purchase a maximum of 200k DBETs (20k USD).
            else if(getTime() >= (fundingStartTime + 1 days) &&
            getTime() < fundingStartTime + 2 days) {
                if(safeAdd(communitySalePurchases[msg.sender][1], amount) > communitySaleCap[1])
                throw;
                else
                communitySalePurchases[msg.sender][1] =
                safeAdd(communitySalePurchases[msg.sender][1], amount);
            }
        }

        // Assign new tokens to the sender.
        balances[_address] = safeAdd(balances[_address], amount);

        // Log token creation event
        Transfer(0, _address, amount);
    }

    
    
    /// create DBET for the DecentBet Multisig and team,
    /// transfer ETH to the DecentBet Multisig address.
    
    function finalizeCrowdfunding() external {
        // Abort if not in Funding Success state.
        if (getState() != State.Success) throw;
        // don't finalize unless we won
        if (finalizedCrowdfunding) throw;
        // can't finalize twice (so sneaky!)

        // prevent more creation of tokens
        finalizedCrowdfunding = true;

        // Founder's supply : 18% of total goes to vault, time locked for 6 months
        uint256 vaultTokens = safeDiv(safeMul(totalSupply, vaultPercentOfTotal), crowdfundPercentOfTotal);
        balances[timeVault] = safeAdd(balances[timeVault], vaultTokens);
        Transfer(0, timeVault, vaultTokens);

        // House: 10% of total goes to Decent.bet for initial house setup
        uint256 houseTokens = safeDiv(safeMul(totalSupply, housePercentOfTotal), crowdfundPercentOfTotal);
        balances[timeVault] = safeAdd(balances[decentBetMultisig], houseTokens);
        Transfer(0, decentBetMultisig, houseTokens);

        // Bounties: 2% of total goes to Decent bet for bounties
        uint256 bountyTokens = safeDiv(safeMul(totalSupply, bountyPercentOfTotal), crowdfundPercentOfTotal);
        balances[decentBetMultisig] = safeAdd(balances[decentBetMultisig], bountyTokens);
        Transfer(0, decentBetMultisig, bountyTokens);

        // Transfer ETH to the DBET Multisig address.
        if (!decentBetMultisig.send(this.balance)) throw;
    }

    // Interface marker
    function isDecentBetCrowdsale() returns (bool) {
        return true;
    }

    function getTime() constant returns (uint256) {
        return now;
    }

    
    /// We make it a function and do not assign the result to a variable
    /// So there is no chance of the variable being stale
    function getState() public constant returns (State){
        /* Successful if crowdsale was finalized */
        if(finalizedCrowdfunding) return State.Success;

        /* Pre-sale not started */
        else if (getTime() < preSaleStartTime) return State.Waiting;

        /* Pre-sale */
        else if (getTime() >= preSaleStartTime &&
        getTime() < fundingStartTime &&
        totalSupply < tokenCreationMax) return State.PreSale;

        /* Community sale */
        else if (getTime() >= fundingStartTime &&
        getTime() < fundingStartTime + 2 days &&
        totalSupply < tokenCreationMax) return State.CommunitySale;

        /* Public sale */
        else if (getTime() >= (fundingStartTime + 2 days) &&
        getTime() < fundingEndTime &&
        totalSupply < tokenCreationMax) return State.PublicSale;

        /* Success */
        else if (getTime() >= fundingEndTime ||
        totalSupply == tokenCreationMax) return State.Success;
    }

}