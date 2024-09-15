
pragma solidity ^0.4.24;



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
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
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
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
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


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

    
    uint public constant MIN_AUDIT_TIME = 24 hours;

    
    uint public constant MAX_AUDIT_TIME = 28 days;

    
    uint public TotalRequestsAmount = 0;

    // @dev amount of collected commision available to withdraw
    uint public AvailableCommission = 0;

    // @dev commission percentage, initially 1%
    uint public Commission = 1;

    
    event NewCommission(uint commmission);

    address public SolidStampRegisterAddress;

    
    constructor(address _addressRegistrySolidStamp) public {
        SolidStampRegisterAddress = _addressRegistrySolidStamp;
    }

    
    struct AuditRequest {
        // amount of Ethers offered by a particular requestor for an audit
        uint amount;
        // request expiration date
        uint expireDate;
    }

    
    /// the particular contract by the particular auditor.
    /// Map key is: keccack256(auditor address, contract codeHash)
    
    mapping (bytes32 => uint) public Rewards;

    
    /// Map key is: keccack256(auditor address, requestor address, contract codeHash)
    mapping (bytes32 => AuditRequest) public AuditRequests;

    
    event AuditRequested(address auditor, address bidder, bytes32 codeHash, uint amount, uint expireDate);
    
    event RequestWithdrawn(address auditor, address bidder, bytes32 codeHash, uint amount);
    
    event ContractAudited(address auditor, bytes32 codeHash, bytes reportIPFS, bool isApproved, uint reward);

    
    
    
    
    function requestAudit(address _auditor, bytes32 _codeHash, uint _auditTime)
    public whenNotPaused payable
    {
        require(_auditor != 0x0, "_auditor cannot be 0x0");
        // audit request cannot expire too quickly or last too long
        require(_auditTime >= MIN_AUDIT_TIME, "_auditTime should be >= MIN_AUDIT_TIME");
        require(_auditTime <= MAX_AUDIT_TIME, "_auditTime should be <= MIN_AUDIT_TIME");
        require(msg.value > 0, "msg.value should be >0");

        // revert if the contract is already audited by the auditor
        uint8 outcome = SolidStampRegister(SolidStampRegisterAddress).getAuditOutcome(_auditor, _codeHash);
        require(outcome == NOT_AUDITED, "contract already audited");

        bytes32 hashAuditorCode = keccak256(abi.encodePacked(_auditor, _codeHash));
        uint currentReward = Rewards[hashAuditorCode];
        uint expireDate = now.add(_auditTime);
        Rewards[hashAuditorCode] = currentReward.add(msg.value);
        TotalRequestsAmount = TotalRequestsAmount.add(msg.value);

        bytes32 hashAuditorRequestorCode = keccak256(abi.encodePacked(_auditor, msg.sender, _codeHash));
        AuditRequest storage request = AuditRequests[hashAuditorRequestorCode];
        if ( request.amount == 0 ) {
            // first request from msg.sender to audit contract _codeHash by _auditor
            AuditRequests[hashAuditorRequestorCode] = AuditRequest({
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
        bytes32 hashAuditorCode = keccak256(abi.encodePacked(_auditor, _codeHash));

        // revert if the contract is already audited by the auditor
        uint8 outcome = SolidStampRegister(SolidStampRegisterAddress).getAuditOutcome(_auditor, _codeHash);
        require(outcome == NOT_AUDITED, "contract already audited");

        bytes32 hashAuditorRequestorCode = keccak256(abi.encodePacked(_auditor, msg.sender, _codeHash));
        AuditRequest storage request = AuditRequests[hashAuditorRequestorCode];
        require(request.amount > 0, "nothing to withdraw");
        require(now > request.expireDate, "cannot withdraw before request.expireDate");

        uint amount = request.amount;
        delete request.amount;
        delete request.expireDate;
        Rewards[hashAuditorCode] = Rewards[hashAuditorCode].sub(amount);
        TotalRequestsAmount = TotalRequestsAmount.sub(amount);
        emit RequestWithdrawn(_auditor, msg.sender, _codeHash, amount);
        msg.sender.transfer(amount);
    }

    
    
    
    
    
    function auditContract(address _auditor, bytes32 _codeHash, bytes _reportIPFS, bool _isApproved)
    public whenNotPaused onlySolidStampRegisterContract
    {
        bytes32 hashAuditorCode = keccak256(abi.encodePacked(_auditor, _codeHash));
        uint reward = Rewards[hashAuditorCode];
        TotalRequestsAmount = TotalRequestsAmount.sub(reward);
        uint commissionKept = calcCommission(reward);
        AvailableCommission = AvailableCommission.add(commissionKept);
        emit ContractAudited(_auditor, _codeHash, _reportIPFS, _isApproved, reward);
        _auditor.transfer(reward.sub(commissionKept));
    }

    /**
     * @dev Throws if called by any account other than the contractSolidStamp
     */
    modifier onlySolidStampRegisterContract() {
      require(msg.sender == SolidStampRegisterAddress, "can be only run by SolidStampRegister contract");
      _;
    }

    
    uint public constant MAX_COMMISSION = 9;

    
    
    function changeCommission(uint _newCommission) public onlyOwner whenNotPaused {
        require(_newCommission <= MAX_COMMISSION, "commission should be <= MAX_COMMISSION");
        require(_newCommission != Commission, "_newCommission==Commmission");
        Commission = _newCommission;
        emit NewCommission(Commission);
    }

    
    
    function calcCommission(uint _amount) private view returns(uint) {
        return _amount.mul(Commission)/100; // service commision
    }

    
    
    function withdrawCommission(uint _amount) public onlyOwner {
        // cannot withdraw money reserved for requests
        require(_amount <= AvailableCommission, "Cannot withdraw more than available");
        AvailableCommission = AvailableCommission.sub(_amount);
        msg.sender.transfer(_amount);
    }

    
    ///  because then the contract was upgraded.
    
    ///  without using an expensive CALL.
    function unpause() public onlyOwner whenPaused {
        require(newContractAddress == address(0), "new contract cannot be 0x0");

        // Actually unpause the contract.
        super.unpause();
    }

    
    function() payable public {
        revert();
    }
}

contract SolidStampRegister is Ownable
{

    address public ContractSolidStamp;

    
    uint8 public constant NOT_AUDITED = 0x00;

    
    uint8 public constant AUDITED_AND_APPROVED = 0x01;

    
    uint8 public constant AUDITED_AND_REJECTED = 0x02;

    
    struct Audit {
        
        uint8 outcome;
        
        bytes reportIPFS;
    }

    
    /// Map key is: keccack256(auditor address, contract codeHash)
    
    mapping (bytes32 => Audit) public Audits;

    
    event AuditRegistered(address auditor, bytes32 codeHash, bytes reportIPFS, bool isApproved);

    
    constructor() public {
    }

    
    
    
    function getAuditOutcome(address _auditor, bytes32 _codeHash) public view returns (uint8)
    {
        bytes32 hashAuditorCode = keccak256(abi.encodePacked(_auditor, _codeHash));
        return Audits[hashAuditorCode].outcome;
    }

    
    
    
    function getAuditReportIPFS(address _auditor, bytes32 _codeHash) public view returns (bytes)
    {
        bytes32 hashAuditorCode = keccak256(abi.encodePacked(_auditor, _codeHash));
        return Audits[hashAuditorCode].reportIPFS;
    }

    
    
    
    
    function registerAudit(bytes32 _codeHash, bytes _reportIPFS, bool _isApproved) public
    {
        require(_codeHash != 0x0, "codeHash cannot be 0x0");
        require(_reportIPFS.length != 0x0, "report IPFS cannot be 0x0");
        bytes32 hashAuditorCode = keccak256(abi.encodePacked(msg.sender, _codeHash));

        Audit storage audit = Audits[hashAuditorCode];
        require(audit.outcome == NOT_AUDITED, "already audited");

        if ( _isApproved )
            audit.outcome = AUDITED_AND_APPROVED;
        else
            audit.outcome = AUDITED_AND_REJECTED;
        audit.reportIPFS = _reportIPFS;
        SolidStamp(ContractSolidStamp).auditContract(msg.sender, _codeHash, _reportIPFS, _isApproved);
        emit AuditRegistered(msg.sender, _codeHash, _reportIPFS, _isApproved);
    }

    
    
    
    
    function registerAudits(bytes32[] _codeHashes, bytes _reportIPFS, bool _isApproved) public
    {
        for(uint i=0; i<_codeHashes.length; i++ )
        {
            registerAudit(_codeHashes[i], _reportIPFS, _isApproved);
        }
    }


    event SolidStampContractChanged(address newSolidStamp);

    
    
    function changeSolidStampContract(address _newSolidStamp) public onlyOwner {
      require(_newSolidStamp != address(0), "SolidStamp contract cannot be 0x0");
      emit SolidStampContractChanged(_newSolidStamp);
      ContractSolidStamp = _newSolidStamp;
    }

    
    function() payable public {
        revert();
    }    
}