
pragma solidity ^0.4.11;

/**
 * @title Owned contract with safe ownership pass.
 *
 * Note: all the non constant functions return false instead of throwing in case if state change
 * didn't happen yet.
 */
contract Owned {
    /**
     * Contract owner address
     */
    address public contractOwner;

    /**
     * Contract owner address
     */
    address public pendingContractOwner;

    function Owned() {
        contractOwner = msg.sender;
    }

    /**
    * @dev Owner check modifier
    */
    modifier onlyContractOwner() {
        if (contractOwner == msg.sender) {
            _;
        }
    }

    /**
     * @dev Destroy contract and scrub a data
     * @notice Only owner can call it
     */
    function destroy() onlyContractOwner {
        suicide(msg.sender);
    }

    /**
     * Prepares ownership pass.
     *
     * Can only be called by current owner.
     *
     * @param _to address of the next owner. 0x0 is not allowed.
     *
     * @return success.
     */
    function changeContractOwnership(address _to) onlyContractOwner() returns(bool) {
        if (_to  == 0x0) {
            return false;
        }

        pendingContractOwner = _to;
        return true;
    }

    /**
     * Finalize ownership pass.
     *
     * Can only be called by pending owner.
     *
     * @return success.
     */
    function claimContractOwnership() returns(bool) {
        if (pendingContractOwner != msg.sender) {
            return false;
        }

        contractOwner = pendingContractOwner;
        delete pendingContractOwner;

        return true;
    }
}


contract ERC20Interface {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed spender, uint256 value);
    string public symbol;

    function totalSupply() constant returns (uint256 supply);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
}

/**
 * @title Generic owned destroyable contract
 */
contract Object is Owned {
    /**
    *  Common result code. Means everything is fine.
    */
    uint constant OK = 1;
    uint constant OWNED_ACCESS_DENIED_ONLY_CONTRACT_OWNER = 8;

    function withdrawnTokens(address[] tokens, address _to) onlyContractOwner returns(uint) {
        for(uint i=0;i<tokens.length;i++) {
            address token = tokens[i];
            uint balance = ERC20Interface(token).balanceOf(this);
            if(balance != 0)
                ERC20Interface(token).transfer(_to,balance);
        }
        return OK;
    }

    function checkOnlyContractOwner() internal constant returns(uint) {
        if (contractOwner == msg.sender) {
            return OK;
        }

        return OWNED_ACCESS_DENIED_ONLY_CONTRACT_OWNER;
    }
}


/**
 * @title General MultiEventsHistory user.
 *
 */
contract MultiEventsHistoryAdapter {

    /**
    *   @dev It is address of MultiEventsHistory caller assuming we are inside of delegate call.
    */
    function _self() constant internal returns (address) {
        return msg.sender;
    }
}

contract DelayedPaymentsEmitter is MultiEventsHistoryAdapter {
    event Error(bytes32 message);

    function emitError(bytes32 _message) {
        Error(_message);
    }
}

contract DelayedPayments is Object {
   
    uint constant DELAYED_PAYMENTS_SCOPE = 52000;
    uint constant DELAYED_PAYMENTS_INVALID_INVOCATION = DELAYED_PAYMENTS_SCOPE + 17;

    
    ///  each payment making it easy to track the movement of funds
    ///  transparently
    struct Payment {
        address spender;        // Who is sending the funds
        uint earliestPayTime;   // The earliest a payment can be made (Unix Time)
        bool canceled;         // If True then the payment has been canceled
        bool paid;              // If True then the payment has been paid
        address recipient;      // Who is receiving the funds
        uint amount;            // The amount of wei sent in the payment
        uint securityGuardDelay;// The seconds `securityGuard` can delay payment
    }

    Payment[] public authorizedPayments;

    address public securityGuard;
    uint public absoluteMinTimeLock;
    uint public timeLock;
    uint public maxSecurityGuardDelay;

    // Should use interface of the emitter, but address of events history.
    address public eventsHistory;

    
    ///  payments from this vault
    mapping (address => bool) public allowedSpenders;

    
    ///  addresses that can call a function with this modifier
    modifier onlySecurityGuard { if (msg.sender != securityGuard) throw; _; }

    // @dev Events to make the payment movements easy to find on the blockchain
    event PaymentAuthorized(uint indexed idPayment, address indexed recipient, uint amount);
    event PaymentExecuted(uint indexed idPayment, address indexed recipient, uint amount);
    event PaymentCanceled(uint indexed idPayment);
    event EtherReceived(address indexed from, uint amount);
    event SpenderAuthorization(address indexed spender, bool authorized);

/////////
// Constructor
/////////

    
    
    ///  be set to, if set to 0 the `owner` can remove the `timeLock` completely
    
    ///  after they are authorized (a security precaution)
    
    ///   that `securityGuard` can delay a payment so that the owner can cancel
    ///   the payment if needed
    function DelayedPayments(
        uint _absoluteMinTimeLock,
        uint _timeLock,
        uint _maxSecurityGuardDelay) 
    {
        absoluteMinTimeLock = _absoluteMinTimeLock;
        timeLock = _timeLock;
        securityGuard = msg.sender;
        maxSecurityGuardDelay = _maxSecurityGuardDelay;
    }

    /**
     * Emits Error event with specified error message.
     *
     * Should only be used if no state changes happened.
     *
     * @param _errorCode code of an error
     * @param _message error message.
     */
    function _error(uint _errorCode, bytes32 _message) internal returns(uint) {
        DelayedPaymentsEmitter(eventsHistory).emitError(_message);
        return _errorCode;
    }

    /**
     * Sets EventsHstory contract address.
     *
     * Can be set only once, and only by contract owner.
     *
     * @param _eventsHistory MultiEventsHistory contract address.
     *
     * @return success.
     */
    function setupEventsHistory(address _eventsHistory) returns(uint errorCode) {
        errorCode = checkOnlyContractOwner();
        if (errorCode != OK) {
            return errorCode;
        }
        if (eventsHistory != 0x0 && eventsHistory != _eventsHistory) {
            return DELAYED_PAYMENTS_INVALID_INVOCATION;
        }
        eventsHistory = _eventsHistory;
        return OK;
    }

/////////
// Helper functions
/////////

    
    
    function numberOfAuthorizedPayments() constant returns (uint) {
        return authorizedPayments.length;
    }

//////
// Receive Ether
//////

    
    /// to more easily track the incoming transactions
    function receiveEther() payable {
        EtherReceived(msg.sender, msg.value);
    }

    
    ///  contract
    function () payable {
        receiveEther();
    }

////////
// Spender Interface
////////

    
    
    
    
    ///  this value is below `timeLock` then the `timeLock` determines the delay
    
    function authorizePayment(
        address _recipient,
        uint _amount,
        uint _paymentDelay
    ) returns(uint) {

        // Fail if you arent on the `allowedSpenders` white list
        if (!allowedSpenders[msg.sender]) throw;
        uint idPayment = authorizedPayments.length;       // Unique Payment ID
        authorizedPayments.length++;

        // The following lines fill out the payment struct
        Payment p = authorizedPayments[idPayment];
        p.spender = msg.sender;

        // Overflow protection
        if (_paymentDelay > 10**18) throw;

        // Determines the earliest the recipient can receive payment (Unix time)
        p.earliestPayTime = _paymentDelay >= timeLock ?
                                now + _paymentDelay :
                                now + timeLock;
        p.recipient = _recipient;
        p.amount = _amount;
        PaymentAuthorized(idPayment, p.recipient, p.amount);
        return idPayment;
    }

    
    ///  function to send themselves the ether after the `earliestPayTime` has
    ///  expired
    
    function collectAuthorizedPayment(uint _idPayment) {

        // Check that the `_idPayment` has been added to the payments struct
        if (_idPayment >= authorizedPayments.length) return;

        Payment p = authorizedPayments[_idPayment];

        // Checking for reasons not to execute the payment
        if (msg.sender != p.recipient) return;
        if (now < p.earliestPayTime) return;
        if (p.canceled) return;
        if (p.paid) return;
        if (this.balance < p.amount) return;

        p.paid = true; // Set the payment to being paid
        if (!p.recipient.send(p.amount)) {  // Make the payment
            return;
        }
        PaymentExecuted(_idPayment, p.recipient, p.amount);
     }

/////////
// SecurityGuard Interface
/////////

    
    
    
    function delayPayment(uint _idPayment, uint _delay) onlySecurityGuard {
        if (_idPayment >= authorizedPayments.length) throw;

        // Overflow test
        if (_delay > 10**18) throw;

        Payment p = authorizedPayments[_idPayment];

        if ((p.securityGuardDelay + _delay > maxSecurityGuardDelay) ||
            (p.paid) ||
            (p.canceled))
            throw;

        p.securityGuardDelay += _delay;
        p.earliestPayTime += _delay;
    }

////////
// Owner Interface
///////

    
    
    function cancelPayment(uint _idPayment) onlyContractOwner {
        if (_idPayment >= authorizedPayments.length) throw;

        Payment p = authorizedPayments[_idPayment];


        if (p.canceled) throw;
        if (p.paid) throw;

        p.canceled = true;
        PaymentCanceled(_idPayment);
    }

    
    
    
    function authorizeSpender(address _spender, bool _authorize) onlyContractOwner {
        allowedSpenders[_spender] = _authorize;
        SpenderAuthorization(_spender, _authorize);
    }

    
    
    function setSecurityGuard(address _newSecurityGuard) onlyContractOwner {
        securityGuard = _newSecurityGuard;
    }

    
    ///  lower than `absoluteMinTimeLock`
    
    ///  pending payments maintain their `earliestPayTime`
    function setTimelock(uint _newTimeLock) onlyContractOwner {
        if (_newTimeLock < absoluteMinTimeLock) throw;
        timeLock = _newTimeLock;
    }

    
    /// `securityGuard` can delay a payment
    
    ///  `securityGuard` can delay the payment's execution in total
    function setMaxSecurityGuardDelay(uint _maxSecurityGuardDelay) onlyContractOwner {
        maxSecurityGuardDelay = _maxSecurityGuardDelay;
    }
}