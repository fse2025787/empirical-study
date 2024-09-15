
pragma solidity ^0.4.21;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

pragma solidity ^0.4.23;


contract Upgradable is Ownable, Pausable {
    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    
    event ContractUpgrade(address newContract);

    
    ///  breaking bug. This method does nothing but keep track of the new contract and
    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    
    function setNewAddress(address _v2Address) external onlyOwner whenPaused {
        require(_v2Address != 0x0);
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }

}


contract SolidStamp is Ownable, Pausable, Upgradable {
    using SafeMath for uint;

    
    uint8 public constant NOT_AUDITED = 0x00;

    
    uint8 public constant AUDITED_AND_APPROVED = 0x01;

    
    uint8 public constant AUDITED_AND_REJECTED = 0x02;

    
    uint public constant MIN_AUDIT_TIME = 24 hours;

    
    uint public constant MAX_AUDIT_TIME = 28 days;

    
    uint public totalRequestsAmount = 0;

    // @dev amount of collected commision available to withdraw
    uint public availableCommission = 0;

    // @dev commission percentage, initially 9%
    uint public commission = 9;

    
    event NewCommission(uint commmission);

    
    constructor() public {
    }

    
    struct AuditRequest {
        // amount of Ethers offered by a particular requestor for an audit
        uint amount;
        // request expiration date
        uint expireDate;
    }

    
    /// the particular contract by the particular auditor.
    /// Map key is: keccack256(auditor address, contract codeHash)
    
    mapping (bytes32 => uint) public rewards;

    
    /// the particular contract by the particular auditor.
    /// Map key is: keccack256(auditor address, contract codeHash)
    
    mapping (bytes32 => uint8) public auditOutcomes;

    
    /// Map key is: keccack256(auditor address, requestor address, contract codeHash)
    mapping (bytes32 => AuditRequest) public auditRequests;

    
    event AuditRequested(address auditor, address bidder, bytes32 codeHash, uint amount, uint expireDate);
    
    event RequestWithdrawn(address auditor, address bidder, bytes32 codeHash, uint amount);
    
    event ContractAudited(address auditor, bytes32 codeHash, uint reward, bool isApproved);

    
    
    
    
    function requestAudit(address _auditor, bytes32 _codeHash, uint _auditTime)
    public whenNotPaused payable
    {
        require(_auditor != 0x0);
        // audit request cannot expire too quickly or last too long
        require(_auditTime >= MIN_AUDIT_TIME);
        require(_auditTime <= MAX_AUDIT_TIME);
        require(msg.value > 0);

        bytes32 hashAuditorCode = keccak256(_auditor, _codeHash);

        // revert if the contract is already audited by the auditor
        uint8 outcome = auditOutcomes[hashAuditorCode];
        require(outcome == NOT_AUDITED);

        uint currentReward = rewards[hashAuditorCode];
        uint expireDate = now.add(_auditTime);
        rewards[hashAuditorCode] = currentReward.add(msg.value);
        totalRequestsAmount = totalRequestsAmount.add(msg.value);

        bytes32 hashAuditorRequestorCode = keccak256(_auditor, msg.sender, _codeHash);
        AuditRequest storage request = auditRequests[hashAuditorRequestorCode];
        if ( request.amount == 0 ) {
            // first request from msg.sender to audit contract _codeHash by _auditor
            auditRequests[hashAuditorRequestorCode] = AuditRequest({
                amount : msg.value,
                expireDate : expireDate
            });
            emit AuditRequested(_auditor, msg.sender, _codeHash, msg.value, expireDate);
        } else {
            // Request already exists. Increasing value
            request.amount = request.amount.add(msg.value);
            // if new expireDate is later than existing one - increase the existing one
            if ( expireDate > request.expireDate )
                request.expireDate = expireDate;
            // event returns the total request value and its expireDate
            emit AuditRequested(_auditor, msg.sender, _codeHash, request.amount, request.expireDate);
        }
    }

    
    
    
    function withdrawRequest(address _auditor, bytes32 _codeHash)
    public
    {
        bytes32 hashAuditorCode = keccak256(_auditor, _codeHash);

        // revert if the contract is already audited by the auditor
        uint8 outcome = auditOutcomes[hashAuditorCode];
        require(outcome == NOT_AUDITED);

        bytes32 hashAuditorRequestorCode = keccak256(_auditor, msg.sender, _codeHash);
        AuditRequest storage request = auditRequests[hashAuditorRequestorCode];
        require(request.amount > 0);
        require(now > request.expireDate);

        uint amount = request.amount;
        delete request.amount;
        delete request.expireDate;
        rewards[hashAuditorCode] = rewards[hashAuditorCode].sub(amount);
        totalRequestsAmount = totalRequestsAmount.sub(amount);
        emit RequestWithdrawn(_auditor, msg.sender, _codeHash, amount);
        msg.sender.transfer(amount);
    }

    
    
    
    function auditContract(bytes32 _codeHash, bool _isApproved)
    public whenNotPaused
    {
        bytes32 hashAuditorCode = keccak256(msg.sender, _codeHash);

        // revert if the contract is already audited by the auditor
        uint8 outcome = auditOutcomes[hashAuditorCode];
        require(outcome == NOT_AUDITED);

        if ( _isApproved )
            auditOutcomes[hashAuditorCode] = AUDITED_AND_APPROVED;
        else
            auditOutcomes[hashAuditorCode] = AUDITED_AND_REJECTED;
        uint reward = rewards[hashAuditorCode];
        totalRequestsAmount = totalRequestsAmount.sub(reward);
        commission = calcCommission(reward);
        availableCommission = availableCommission.add(commission);
        emit ContractAudited(msg.sender, _codeHash, reward, _isApproved);
        msg.sender.transfer(reward.sub(commission));
    }

    
    uint public constant MAX_COMMISION = 33;

    
    
    function changeCommission(uint _newCommission) public onlyOwner whenNotPaused {
        require(_newCommission <= MAX_COMMISION);
        require(_newCommission != commission);
        commission = _newCommission;
        emit NewCommission(commission);
    }

    
    
    function calcCommission(uint _amount) private view returns(uint) {
        return _amount.mul(commission)/100; // service commision
    }

    
    
    function withdrawCommission(uint _amount) public onlyOwner {
        // cannot withdraw money reserved for requests
        require(_amount <= availableCommission);
        availableCommission = availableCommission.sub(_amount);
        msg.sender.transfer(_amount);
    }

    
    ///  because then the contract was upgraded.
    
    ///  without using an expensive CALL.
    function unpause() public onlyOwner whenPaused {
        require(newContractAddress == address(0));

        // Actually unpause the contract.
        super.unpause();
    }

    
    function() payable public {
        revert();
    }
}