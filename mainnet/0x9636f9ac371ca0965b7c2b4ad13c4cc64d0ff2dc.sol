
pragma solidity 0.4.24;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
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
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
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
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

contract RepublicToken is PausableToken, BurnableToken {

    string public constant name = "Republic Token";
    string public constant symbol = "REN";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 1000000000 * 10**uint256(decimals);

    
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    function transferTokens(address beneficiary, uint256 amount) public onlyOwner returns (bool) {
        /* solium-disable error-reason */
        require(amount > 0);

        balances[owner] = balances[owner].sub(amount);
        balances[beneficiary] = balances[beneficiary].add(amount);
        emit Transfer(owner, beneficiary, amount);

        return true;
    }
}

/**
 * @notice LinkedList is a library for a circular double linked list.
 */
library LinkedList {

    /*
    * @notice A permanent NULL node (0x0) in the circular double linked list.
    * NULL.next is the head, and NULL.previous is the tail.
    */
    address public constant NULL = 0x0;

    /**
    * @notice A node points to the node before it, and the node after it. If
    * node.previous = NULL, then the node is the head of the list. If
    * node.next = NULL, then the node is the tail of the list.
    */
    struct Node {
        bool inList;
        address previous;
        address next;
    }

    /**
    * @notice LinkedList uses a mapping from address to nodes. Each address
    * uniquely identifies a node, and in this way they are used like pointers.
    */
    struct List {
        mapping (address => Node) list;
    }

    /**
    * @notice Insert a new node before an existing node.
    *
    * @param self The list being used.
    * @param target The existing node in the list.
    * @param newNode The next node to insert before the target.
    */
    function insertBefore(List storage self, address target, address newNode) internal {
        require(!isInList(self, newNode), "already in list");
        require(isInList(self, target) || target == NULL, "not in list");

        // It is expected that this value is sometimes NULL.
        address prev = self.list[target].previous;

        self.list[newNode].next = target;
        self.list[newNode].previous = prev;
        self.list[target].previous = newNode;
        self.list[prev].next = newNode;

        self.list[newNode].inList = true;
    }

    /**
    * @notice Insert a new node after an existing node.
    *
    * @param self The list being used.
    * @param target The existing node in the list.
    * @param newNode The next node to insert after the target.
    */
    function insertAfter(List storage self, address target, address newNode) internal {
        require(!isInList(self, newNode), "already in list");
        require(isInList(self, target) || target == NULL, "not in list");

        // It is expected that this value is sometimes NULL.
        address n = self.list[target].next;

        self.list[newNode].previous = target;
        self.list[newNode].next = n;
        self.list[target].next = newNode;
        self.list[n].previous = newNode;

        self.list[newNode].inList = true;
    }

    /**
    * @notice Remove a node from the list, and fix the previous and next
    * pointers that are pointing to the removed node. Removing anode that is not
    * in the list will do nothing.
    *
    * @param self The list being using.
    * @param node The node in the list to be removed.
    */
    function remove(List storage self, address node) internal {
        require(isInList(self, node), "not in list");
        if (node == NULL) {
            return;
        }
        address p = self.list[node].previous;
        address n = self.list[node].next;

        self.list[p].next = n;
        self.list[n].previous = p;

        // Deleting the node should set this value to false, but we set it here for
        // explicitness.
        self.list[node].inList = false;
        delete self.list[node];
    }

    /**
    * @notice Insert a node at the beginning of the list.
    *
    * @param self The list being used.
    * @param node The node to insert at the beginning of the list.
    */
    function prepend(List storage self, address node) internal {
        // isInList(node) is checked in insertBefore

        insertBefore(self, begin(self), node);
    }

    /**
    * @notice Insert a node at the end of the list.
    *
    * @param self The list being used.
    * @param node The node to insert at the end of the list.
    */
    function append(List storage self, address node) internal {
        // isInList(node) is checked in insertBefore

        insertAfter(self, end(self), node);
    }

    function swap(List storage self, address left, address right) internal {
        // isInList(left) and isInList(right) are checked in remove

        address previousRight = self.list[right].previous;
        remove(self, right);
        insertAfter(self, left, right);
        remove(self, left);
        insertAfter(self, previousRight, left);
    }

    function isInList(List storage self, address node) internal view returns (bool) {
        return self.list[node].inList;
    }

    /**
    * @notice Get the node at the beginning of a double linked list.
    *
    * @param self The list being used.
    *
    * @return A address identifying the node at the beginning of the double
    * linked list.
    */
    function begin(List storage self) internal view returns (address) {
        return self.list[NULL].next;
    }

    /**
    * @notice Get the node at the end of a double linked list.
    *
    * @param self The list being used.
    *
    * @return A address identifying the node at the end of the double linked
    * list.
    */
    function end(List storage self) internal view returns (address) {
        return self.list[NULL].previous;
    }

    function next(List storage self, address node) internal view returns (address) {
        require(isInList(self, node), "not in list");
        return self.list[node].next;
    }

    function previous(List storage self, address node) internal view returns (address) {
        require(isInList(self, node), "not in list");
        return self.list[node].previous;
    }

}


/// contract. The data / fund logic and storage have been separated to improve
/// upgradability.
contract DarknodeRegistryStore is Ownable {
    string public VERSION; // Passed in as a constructor parameter.

    
    /// address that registered the darknode, the bond is the amount of REN that
    /// was transferred during registration, and the public key is the
    /// encryption key that should be used when sending sensitive information to
    /// the darknode.
    struct Darknode {
        // The owner of a Darknode is the address that called the register
        // function. The owner is the only address that is allowed to
        // deregister the Darknode, unless the Darknode is slashed for
        // malicious behavior.
        address owner;

        // The bond is the amount of REN submitted as a bond by the Darknode.
        // This amount is reduced when the Darknode is slashed for malicious
        // behavior.
        uint256 bond;

        // The block number at which the Darknode is considered registered.
        uint256 registeredAt;

        // The block number at which the Darknode is considered deregistered.
        uint256 deregisteredAt;

        // The public key used by this Darknode for encrypting sensitive data
        // off chain. It is assumed that the Darknode has access to the
        // respective private key, and that there is an agreement on the format
        // of the public key.
        bytes publicKey;
    }

    /// Registry data.
    mapping(address => Darknode) private darknodeRegistry;
    LinkedList.List private darknodes;

    // RepublicToken.
    RepublicToken public ren;

    
    ///
    
    
    constructor(
        string _VERSION,
        RepublicToken _ren
    ) public {
        VERSION = _VERSION;
        ren = _ren;
    }

    
    /// linked-list.
    ///
    
    
    
    
    
    
    function appendDarknode(
        address _darknodeID,
        address _darknodeOwner,
        uint256 _bond,
        bytes _publicKey,
        uint256 _registeredAt,
        uint256 _deregisteredAt
    ) external onlyOwner {
        Darknode memory darknode = Darknode({
            owner: _darknodeOwner,
            bond: _bond,
            publicKey: _publicKey,
            registeredAt: _registeredAt,
            deregisteredAt: _deregisteredAt
        });
        darknodeRegistry[_darknodeID] = darknode;
        LinkedList.append(darknodes, _darknodeID);
    }

    
    function begin() external view onlyOwner returns(address) {
        return LinkedList.begin(darknodes);
    }

    
    /// given address.
    function next(address darknodeID) external view onlyOwner returns(address) {
        return LinkedList.next(darknodes, darknodeID);
    }

    
    /// owner of this contract.
    function removeDarknode(address darknodeID) external onlyOwner {
        uint256 bond = darknodeRegistry[darknodeID].bond;
        delete darknodeRegistry[darknodeID];
        LinkedList.remove(darknodes, darknodeID);
        require(ren.transfer(owner, bond), "bond transfer failed");
    }

    
    /// decreased, the difference is sent to the owner of this contract.
    function updateDarknodeBond(address darknodeID, uint256 bond) external onlyOwner {
        uint256 previousBond = darknodeRegistry[darknodeID].bond;
        darknodeRegistry[darknodeID].bond = bond;
        if (previousBond > bond) {
            require(ren.transfer(owner, previousBond - bond), "cannot transfer bond");
        }
    }

    
    function updateDarknodeDeregisteredAt(address darknodeID, uint256 deregisteredAt) external onlyOwner {
        darknodeRegistry[darknodeID].deregisteredAt = deregisteredAt;
    }

    
    function darknodeOwner(address darknodeID) external view onlyOwner returns (address) {
        return darknodeRegistry[darknodeID].owner;
    }

    
    function darknodeBond(address darknodeID) external view onlyOwner returns (uint256) {
        return darknodeRegistry[darknodeID].bond;
    }

    
    function darknodeRegisteredAt(address darknodeID) external view onlyOwner returns (uint256) {
        return darknodeRegistry[darknodeID].registeredAt;
    }

    
    function darknodeDeregisteredAt(address darknodeID) external view onlyOwner returns (uint256) {
        return darknodeRegistry[darknodeID].deregisteredAt;
    }

    
    function darknodePublicKey(address darknodeID) external view onlyOwner returns (bytes) {
        return darknodeRegistry[darknodeID].publicKey;
    }
}


/// deregistration of Darknodes.
contract DarknodeRegistry is Ownable {
    string public VERSION; // Passed in as a constructor parameter.

    
    /// An Epoch stores an epoch hash used as an (insecure) RNG seed, and the
    /// blocknumber which restricts when the next epoch can be called.
    struct Epoch {
        uint256 epochhash;
        uint256 blocknumber;
    }

    uint256 public numDarknodes;
    uint256 public numDarknodesNextEpoch;
    uint256 public numDarknodesPreviousEpoch;

    /// Variables used to parameterize behavior.
    uint256 public minimumBond;
    uint256 public minimumPodSize;
    uint256 public minimumEpochInterval;
    address public slasher;

    /// When one of the above variables is modified, it is only updated when the
    /// next epoch is called. These variables store the values for the next epoch.
    uint256 public nextMinimumBond;
    uint256 public nextMinimumPodSize;
    uint256 public nextMinimumEpochInterval;
    address public nextSlasher;

    /// The current and previous epoch
    Epoch public currentEpoch;
    Epoch public previousEpoch;

    /// Republic ERC20 token contract used to transfer bonds.
    RepublicToken public ren;

    /// Darknode Registry Store is the storage contract for darknodes.
    DarknodeRegistryStore public store;

    
    
    
    event LogDarknodeRegistered(address _darknodeID, uint256 _bond);

    
    
    event LogDarknodeDeregistered(address _darknodeID);

    
    
    
    event LogDarknodeOwnerRefunded(address _owner, uint256 _amount);

    
    event LogNewEpoch();

    
    event LogMinimumBondUpdated(uint256 previousMinimumBond, uint256 nextMinimumBond);
    event LogMinimumPodSizeUpdated(uint256 previousMinimumPodSize, uint256 nextMinimumPodSize);
    event LogMinimumEpochIntervalUpdated(uint256 previousMinimumEpochInterval, uint256 nextMinimumEpochInterval);
    event LogSlasherUpdated(address previousSlasher, address nextSlasher);

    
    modifier onlyDarknodeOwner(address _darknodeID) {
        require(store.darknodeOwner(_darknodeID) == msg.sender, "must be darknode owner");
        _;
    }

    
    modifier onlyRefunded(address _darknodeID) {
        require(isRefunded(_darknodeID), "must be refunded or never registered");
        _;
    }

    
    modifier onlyRefundable(address _darknodeID) {
        require(isRefundable(_darknodeID), "must be deregistered for at least one epoch");
        _;
    }

    
    /// deregister
    modifier onlyDeregisterable(address _darknodeID) {
        require(isDeregisterable(_darknodeID), "must be deregisterable");
        _;
    }

    
    modifier onlySlasher() {
        require(slasher == msg.sender, "must be slasher");
        _;
    }

    
    ///
    
    
    
    
    ///        Darknode.
    
    
    ///        epochs.
    constructor(
        string _VERSION,
        RepublicToken _renAddress,
        DarknodeRegistryStore _storeAddress,
        uint256 _minimumBond,
        uint256 _minimumPodSize,
        uint256 _minimumEpochInterval
    ) public {
        VERSION = _VERSION;

        store = _storeAddress;
        ren = _renAddress;

        minimumBond = _minimumBond;
        nextMinimumBond = minimumBond;

        minimumPodSize = _minimumPodSize;
        nextMinimumPodSize = minimumPodSize;

        minimumEpochInterval = _minimumEpochInterval;
        nextMinimumEpochInterval = minimumEpochInterval;

        currentEpoch = Epoch({
            epochhash: uint256(blockhash(block.number - 1)),
            blocknumber: block.number
        });
        numDarknodes = 0;
        numDarknodesNextEpoch = 0;
        numDarknodesPreviousEpoch = 0;
    }

    
    /// caller must provide a public encryption key for the darknode as well as
    /// a bond in REN. The bond must be provided as an ERC20 allowance. The dark
    /// node will remain pending registration until the next epoch. Only after
    /// this period can the darknode be deregistered. The caller of this method
    /// will be stored as the owner of the darknode.
    ///
    
    
    ///        other darknodes and traders to encrypt messages to the trader.
    
    ///        equal to, the minimum bond.
    function register(address _darknodeID, bytes _publicKey, uint256 _bond) external onlyRefunded(_darknodeID) {
        // REN allowance
        require(_bond >= minimumBond, "insufficient bond");
        // require(ren.allowance(msg.sender, address(this)) >= _bond);
        require(ren.transferFrom(msg.sender, address(this), _bond), "bond transfer failed");
        ren.transfer(address(store), _bond);

        // Flag this darknode for registration
        store.appendDarknode(
            _darknodeID,
            msg.sender,
            _bond,
            _publicKey,
            currentEpoch.blocknumber + minimumEpochInterval,
            0
        );

        numDarknodesNextEpoch += 1;

        // Emit an event.
        emit LogDarknodeRegistered(_darknodeID, _bond);
    }

    
    /// until the end of the epoch. After another epoch, the bond can be
    /// refunded by calling the refund method.
    
    ///        of this method store.darknodeRegisteredAt(_darknodeID) must be
    //         the owner of this darknode.
    function deregister(address _darknodeID) external onlyDeregisterable(_darknodeID) onlyDarknodeOwner(_darknodeID) {
        // Flag the darknode for deregistration
        store.updateDarknodeDeregisteredAt(_darknodeID, currentEpoch.blocknumber + minimumEpochInterval);
        numDarknodesNextEpoch -= 1;

        // Emit an event
        emit LogDarknodeDeregistered(_darknodeID);
    }

    
    /// the current timestamp and current blockhash and overrides the current
    /// epoch.
    function epoch() external {
        if (previousEpoch.blocknumber == 0) {
            // The first epoch must be called by the owner of the contract
            require(msg.sender == owner, "not authorized (first epochs)");
        }

        // Require that the epoch interval has passed
        require(block.number >= currentEpoch.blocknumber + minimumEpochInterval, "epoch interval has not passed");
        uint256 epochhash = uint256(blockhash(block.number - 1));

        // Update the epoch hash and timestamp
        previousEpoch = currentEpoch;
        currentEpoch = Epoch({
            epochhash: epochhash,
            blocknumber: block.number
        });

        // Update the registry information
        numDarknodesPreviousEpoch = numDarknodes;
        numDarknodes = numDarknodesNextEpoch;

        // If any update functions have been called, update the values now
        if (nextMinimumBond != minimumBond) {
            minimumBond = nextMinimumBond;
            emit LogMinimumBondUpdated(minimumBond, nextMinimumBond);
        }
        if (nextMinimumPodSize != minimumPodSize) {
            minimumPodSize = nextMinimumPodSize;
            emit LogMinimumPodSizeUpdated(minimumPodSize, nextMinimumPodSize);
        }
        if (nextMinimumEpochInterval != minimumEpochInterval) {
            minimumEpochInterval = nextMinimumEpochInterval;
            emit LogMinimumEpochIntervalUpdated(minimumEpochInterval, nextMinimumEpochInterval);
        }
        if (nextSlasher != slasher) {
            slasher = nextSlasher;
            emit LogSlasherUpdated(slasher, nextSlasher);
        }

        // Emit an event
        emit LogNewEpoch();
    }

    
    /// DarknodeRegistryStore.
    
    function transferStoreOwnership(address _newOwner) external onlyOwner {
        store.transferOwnership(_newOwner);
    }

    
    
    ///        a darknode.
    function updateMinimumBond(uint256 _nextMinimumBond) external onlyOwner {
        // Will be updated next epoch
        nextMinimumBond = _nextMinimumBond;
    }

    
    
    function updateMinimumPodSize(uint256 _nextMinimumPodSize) external onlyOwner {
        // Will be updated next epoch
        nextMinimumPodSize = _nextMinimumPodSize;
    }

    
    
    function updateMinimumEpochInterval(uint256 _nextMinimumEpochInterval) external onlyOwner {
        // Will be updated next epoch
        nextMinimumEpochInterval = _nextMinimumEpochInterval;
    }

    
    /// address.
    
    function updateSlasher(address _slasher) external onlyOwner {
        nextSlasher = _slasher;
    }

    
    /// bond and deregister it. The bond is distributed as follows:
    ///   1/2 is kept by the guilty prover
    ///   1/8 is rewarded to the first challenger
    ///   1/8 is rewarded to the second challenger
    ///   1/4 becomes unassigned
    
    
    
    function slash(address _prover, address _challenger1, address _challenger2)
        external
        onlySlasher
    {
        uint256 penalty = store.darknodeBond(_prover) / 2;
        uint256 reward = penalty / 4;

        // Slash the bond of the failed prover in half
        store.updateDarknodeBond(_prover, penalty);

        // If the darknode has not been deregistered then deregister it
        if (isDeregisterable(_prover)) {
            store.updateDarknodeDeregisteredAt(_prover, currentEpoch.blocknumber + minimumEpochInterval);
            numDarknodesNextEpoch -= 1;
            emit LogDarknodeDeregistered(_prover);
        }

        // Reward the challengers with less than the penalty so that it is not
        // worth challenging yourself
        ren.transfer(store.darknodeOwner(_challenger1), reward);
        ren.transfer(store.darknodeOwner(_challenger2), reward);
    }

    
    /// darknode available for registration again. Anyone can call this function
    /// but the bond will always be refunded to the darknode owner.
    ///
    
    ///        of this method must be the owner of this darknode.
    function refund(address _darknodeID) external onlyRefundable(_darknodeID) {
        address darknodeOwner = store.darknodeOwner(_darknodeID);

        // Remember the bond amount
        uint256 amount = store.darknodeBond(_darknodeID);

        // Erase the darknode from the registry
        store.removeDarknode(_darknodeID);

        // Refund the owner by transferring REN
        ren.transfer(darknodeOwner, amount);

        // Emit an event.
        emit LogDarknodeOwnerRefunded(darknodeOwner, amount);
    }

    
    
    function getDarknodeOwner(address _darknodeID) external view returns (address) {
        return store.darknodeOwner(_darknodeID);
    }

    
    
    function getDarknodeBond(address _darknodeID) external view returns (uint256) {
        return store.darknodeBond(_darknodeID);
    }

    
    
    function getDarknodePublicKey(address _darknodeID) external view returns (bytes) {
        return store.darknodePublicKey(_darknodeID);
    }

    
    /// current epoch.
    
    ///        0x0, the first dark node will be used. _start won't be
    ///        included it is not registered for the epoch.
    
    ///        If _count is 0, all of the darknodes from _start are
    ///        retrieved. If _count is more than the remaining number of
    ///        registered darknodes, the rest of the list will contain
    ///        0x0s.
    function getDarknodes(address _start, uint256 _count) external view returns (address[]) {
        uint256 count = _count;
        if (count == 0) {
            count = numDarknodes;
        }
        return getDarknodesFromEpochs(_start, count, false);
    }

    
    /// previous epoch. See `getDarknodes` for the parameter documentation.
    function getPreviousDarknodes(address _start, uint256 _count) external view returns (address[]) {
        uint256 count = _count;
        if (count == 0) {
            count = numDarknodesPreviousEpoch;
        }
        return getDarknodesFromEpochs(_start, count, true);
    }

    
    /// at next epoch.
    
    function isPendingRegistration(address _darknodeID) external view returns (bool) {
        uint256 registeredAt = store.darknodeRegisteredAt(_darknodeID);
        return registeredAt != 0 && registeredAt > currentEpoch.blocknumber;
    }

    
    /// this state a darknode is still considered registered.
    function isPendingDeregistration(address _darknodeID) external view returns (bool) {
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        return deregisteredAt != 0 && deregisteredAt > currentEpoch.blocknumber;
    }

    
    function isDeregistered(address _darknodeID) public view returns (bool) {
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        return deregisteredAt != 0 && deregisteredAt <= currentEpoch.blocknumber;
    }

    
    /// darknodes is in the registered state and has not attempted to
    /// deregister yet.
    function isDeregisterable(address _darknodeID) public view returns (bool) {
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        // The Darknode is currently in the registered state and has not been
        // transitioned to the pending deregistration, or deregistered, state
        return isRegistered(_darknodeID) && deregisteredAt == 0;
    }

    
    /// for darknodes that have never been registered, or darknodes that have
    /// been deregistered and refunded.
    function isRefunded(address _darknodeID) public view returns (bool) {
        uint256 registeredAt = store.darknodeRegisteredAt(_darknodeID);
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        return registeredAt == 0 && deregisteredAt == 0;
    }

    
    /// that have been in the deregistered state for one full epoch.
    function isRefundable(address _darknodeID) public view returns (bool) {
        return isDeregistered(_darknodeID) && store.darknodeDeregisteredAt(_darknodeID) <= previousEpoch.blocknumber;
    }

    
    function isRegistered(address _darknodeID) public view returns (bool) {
        return isRegisteredInEpoch(_darknodeID, currentEpoch);
    }

    
    function isRegisteredInPreviousEpoch(address _darknodeID) public view returns (bool) {
        return isRegisteredInEpoch(_darknodeID, previousEpoch);
    }

    
    /// epoch.
    
    
    function isRegisteredInEpoch(address _darknodeID, Epoch _epoch) private view returns (bool) {
        uint256 registeredAt = store.darknodeRegisteredAt(_darknodeID);
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        bool registered = registeredAt != 0 && registeredAt <= _epoch.blocknumber;
        bool notDeregistered = deregisteredAt == 0 || deregisteredAt > _epoch.blocknumber;
        // The Darknode has been registered and has not yet been deregistered,
        // although it might be pending deregistration
        return registered && notDeregistered;
    }

    
    /// or the previous epoch. See `getDarknodes` for documentation on the
    /// parameters `_start` and `_count`.
    
    ///        the current epoch.
    function getDarknodesFromEpochs(address _start, uint256 _count, bool _usePreviousEpoch) private view returns (address[]) {
        uint256 count = _count;
        if (count == 0) {
            count = numDarknodes;
        }

        address[] memory nodes = new address[](count);

        // Begin with the first node in the list
        uint256 n = 0;
        address next = _start;
        if (next == 0x0) {
            next = store.begin();
        }

        // Iterate until all registered Darknodes have been collected
        while (n < count) {
            if (next == 0x0) {
                break;
            }
            // Only include Darknodes that are currently registered
            bool includeNext;
            if (_usePreviousEpoch) {
                includeNext = isRegisteredInPreviousEpoch(next);
            } else {
                includeNext = isRegistered(next);
            }
            if (!includeNext) {
                next = store.next(next);
                continue;
            }
            nodes[n] = next;
            next = store.next(next);
            n += 1;
        }
        return nodes;
    }
}

/**
 * @title Math
 * @dev Assorted math operations
 */
library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}


/// safeApprove for CompatibleERC20.
///
/// See https://github.com/ethereum/solidity/issues/4116
///
/// This library allows interacting with ERC20 tokens that implement any of
/// these interfaces:
///
/// (1) transfer returns true on success, false on failure
/// (2) transfer returns true on success, reverts on failure
/// (3) transfer returns nothing on success, reverts on failure
///
/// Additionally, safeTransferFromWithFees will return the final token
/// value received after accounting for token fees.
library CompatibleERC20Functions {
    using SafeMath for uint256;

    
    function safeTransfer(address token, address to, uint256 amount) internal {
        CompatibleERC20(token).transfer(to, amount);
        require(previousReturnValue(), "transfer failed");
    }

    
    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        CompatibleERC20(token).transferFrom(from, to, amount);
        require(previousReturnValue(), "transferFrom failed");
    }

    
    function safeApprove(address token, address spender, uint256 amount) internal {
        CompatibleERC20(token).approve(spender, amount);
        require(previousReturnValue(), "approve failed");
    }

    
    /// returns the value transferred after fees.
    function safeTransferFromWithFees(address token, address from, address to, uint256 amount) internal returns (uint256) {
        uint256 balancesBefore = CompatibleERC20(token).balanceOf(to);
        CompatibleERC20(token).transferFrom(from, to, amount);
        require(previousReturnValue(), "transferFrom failed");
        uint256 balancesAfter = CompatibleERC20(token).balanceOf(to);
        return Math.min256(amount, balancesAfter.sub(balancesBefore));
    }

    
    /// if the previous function returned 32 non-zero bytes or returned zero
    /// bytes.
    function previousReturnValue() private pure returns (bool)
    {
        uint256 returnData = 0;

        assembly { /* solium-disable-line security/no-inline-assembly */
            // Switch on the number of bytes returned by the previous call
            switch returndatasize

            // 0 bytes: ERC20 of type (3), did not throw
            case 0 {
                returnData := 1
            }

            // 32 bytes: ERC20 of types (1) or (2)
            case 32 {
                // Copy the return data into scratch space
                returndatacopy(0x0, 0x0, 32)

                // Load  the return data into returnData
                returnData := mload(0x0)
            }

            // Other return size: return false
            default { }
        }

        return returnData != 0;
    }
}


/// transferFrom and approve.
interface CompatibleERC20 {
    // Modified to not return boolean
    function transfer(address to, uint256 value) external;
    function transferFrom(address from, address to, uint256 value) external;
    function approve(address spender, uint256 value) external;

    // Not modifier
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/// for darknodes for settling orders. Fees can be withdrawn to the address of
/// the darknode's operator. Fees can be in ETH or in ERC20 tokens.
/// Docs: https://github.com/republicprotocol/republic-sol/blob/master/docs/02-darknode-reward-vault.md
contract DarknodeRewardVault is Ownable {
    using SafeMath for uint256;
    using CompatibleERC20Functions for CompatibleERC20;

    string public VERSION; // Passed in as a constructor parameter.

    
    address constant public ETHEREUM = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    DarknodeRegistry public darknodeRegistry;

    mapping(address => mapping(address => uint256)) public darknodeBalances;

    event LogDarknodeRegistryUpdated(DarknodeRegistry previousDarknodeRegistry, DarknodeRegistry nextDarknodeRegistry);

    
    ///
    
    
    ///        the vault to lookup Darknode owners.
    constructor(string _VERSION, DarknodeRegistry _darknodeRegistry) public {
        VERSION = _VERSION;
        darknodeRegistry = _darknodeRegistry;
    }

    function updateDarknodeRegistry(DarknodeRegistry _newDarknodeRegistry) public onlyOwner {
        emit LogDarknodeRegistryUpdated(darknodeRegistry, _newDarknodeRegistry);
        darknodeRegistry = _newDarknodeRegistry;
    }

    
    /// registration is not checked (to reduce gas fees); the caller must be
    /// careful not to call this function for a Darknode that is not registered
    /// otherwise any fees deposited to that Darknode can be withdrawn by a
    /// malicious adversary (by registering the Darknode before the honest
    /// party and claiming ownership).
    ///
    
    ///        fees.
    
    ///        A special address is used for Ether.
    
    function deposit(address _darknode, ERC20 _token, uint256 _value) public payable {
        uint256 receivedValue = _value;
        if (address(_token) == ETHEREUM) {
            require(msg.value == _value, "mismatched ether value");
        } else {
            require(msg.value == 0, "unexpected ether value");
            receivedValue = CompatibleERC20(_token).safeTransferFromWithFees(msg.sender, address(this), _value);
        }
        darknodeBalances[_darknode][_token] = darknodeBalances[_darknode][_token].add(receivedValue);
    }

    
    /// the owner of the Darknode. If a Darknode is not registered the fees
    /// cannot be withdrawn.
    ///
    
    ///        withdrawn. The owner of this Darknode will receive the fees.
    
    function withdraw(address _darknode, ERC20 _token) public {
        address darknodeOwner = darknodeRegistry.getDarknodeOwner(address(_darknode));

        require(darknodeOwner != 0x0, "invalid darknode owner");

        uint256 value = darknodeBalances[_darknode][_token];
        darknodeBalances[_darknode][_token] = 0;

        if (address(_token) == ETHEREUM) {
            darknodeOwner.transfer(value);
        } else {
            CompatibleERC20(_token).safeTransfer(darknodeOwner, value);
        }
    }

}


/// layer's broker verifier contract must implement.
interface BrokerVerifier {

    
    /// an order.
    ///
    
    
    
    function verifyOpenSignature(
        address _trader,
        bytes _signature,
        bytes32 _orderID
    ) external returns (bool);
}


/// layer must implement.
/// Docs: https://github.com/republicprotocol/republic-sol/blob/nightly/docs/05-settlement.md
interface Settlement {
    function submitOrder(
        bytes _details,
        uint64 _settlementID,
        uint64 _tokens,
        uint256 _price,
        uint256 _volume,
        uint256 _minimumVolume
    ) external;

    function submissionGasPriceLimit() external view returns (uint256);

    function settle(
        bytes32 _buyID,
        bytes32 _sellID
    ) external;

    
    /// be:
    ///     0  - Order not seen before
    ///     1  - Order details submitted
    ///     >1 - Order settled, or settlement no longer possible
    function orderStatus(bytes32 _orderID) external view returns (uint8);
}


/// contracts used for match settlement and for broker signature verification.
contract SettlementRegistry is Ownable {
    string public VERSION; // Passed in as a constructor parameter.

    struct SettlementDetails {
        bool registered;
        Settlement settlementContract;
        BrokerVerifier brokerVerifierContract;
    }

    // Settlement IDs are 64-bit unsigned numbers
    mapping(uint64 => SettlementDetails) public settlementDetails;

    // Events
    event LogSettlementRegistered(uint64 settlementID, Settlement settlementContract, BrokerVerifier brokerVerifierContract);
    event LogSettlementUpdated(uint64 settlementID, Settlement settlementContract, BrokerVerifier brokerVerifierContract);
    event LogSettlementDeregistered(uint64 settlementID);

    
    ///
    
    constructor(string _VERSION) public {
        VERSION = _VERSION;
    }

    
    function settlementRegistration(uint64 _settlementID) external view returns (bool) {
        return settlementDetails[_settlementID].registered;
    }

    
    function settlementContract(uint64 _settlementID) external view returns (Settlement) {
        return settlementDetails[_settlementID].settlementContract;
    }

    
    function brokerVerifierContract(uint64 _settlementID) external view returns (BrokerVerifier) {
        return settlementDetails[_settlementID].brokerVerifierContract;
    }

    
    
    
    ///        broker signatures.
    function registerSettlement(uint64 _settlementID, Settlement _settlementContract, BrokerVerifier _brokerVerifierContract) public onlyOwner {
        bool alreadyRegistered = settlementDetails[_settlementID].registered;
        
        settlementDetails[_settlementID] = SettlementDetails({
            registered: true,
            settlementContract: _settlementContract,
            brokerVerifierContract: _brokerVerifierContract
        });

        if (alreadyRegistered) {
            emit LogSettlementUpdated(_settlementID, _settlementContract, _brokerVerifierContract);
        } else {
            emit LogSettlementRegistered(_settlementID, _settlementContract, _brokerVerifierContract);
        }
    }

    
    
    function deregisterSettlement(uint64 _settlementID) external onlyOwner {
        require(settlementDetails[_settlementID].registered, "not registered");

        delete settlementDetails[_settlementID];

        emit LogSettlementDeregistered(_settlementID);
    }
}

/**
 * @title Eliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */

library ECRecovery {

  /**
   * @dev Recover signer address from a message by using their signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes sig)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

    // Check the signature length
    if (sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    // ecrecover takes the signature parameters, and the only way to get them
    // currently is to use assembly.
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      // solium-disable-next-line arg-overflow
      return ecrecover(hash, v, r, s);
    }
  }

  /**
   * toEthSignedMessageHash
   * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
   * and hash the result
   */
  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
    );
  }
}

library Utils {

    /**
     * @notice Converts a number to its string/bytes representation
     *
     * @param _v the uint to convert
     */
    function uintToBytes(uint256 _v) internal pure returns (bytes) {
        uint256 v = _v;
        if (v == 0) {
            return "0";
        }

        uint256 digits = 0;
        uint256 v2 = v;
        while (v2 > 0) {
            v2 /= 10;
            digits += 1;
        }

        bytes memory result = new bytes(digits);

        for (uint256 i = 0; i < digits; i++) {
            result[digits - i - 1] = bytes1((v % 10) + 48);
            v /= 10;
        }

        return result;
    }

    /**
     * @notice Retrieves the address from a signature
     *
     * @param _hash the message that was signed (any length of bytes)
     * @param _signature the signature (65 bytes)
     */
    function addr(bytes _hash, bytes _signature) internal pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        bytes memory encoded = abi.encodePacked(prefix, uintToBytes(_hash.length), _hash);
        bytes32 prefixedHash = keccak256(encoded);

        return ECRecovery.recover(prefixedHash, _signature);
    }

}


/// allows the Darknodes to easily reach consensus. Eventually, this contract
/// will only store a subset of order states, such as cancellation, to improve
/// the throughput of orders.
contract Orderbook is Ownable {
    string public VERSION; // Passed in as a constructor parameter.

    
    /// orders default to the Undefined state.
    enum OrderState {Undefined, Open, Confirmed, Canceled}

    
    struct Order {
        OrderState state;     // State of the order
        address trader;       // Trader that owns the order
        address confirmer;    // Darknode that confirmed the order in a match
        uint64 settlementID;  // The settlement that signed the order opening
        uint256 priority;     // Logical time priority of this order
        uint256 blockNumber;  // Block number of the most recent state change
        bytes32 matchedOrder; // Order confirmed in a match with this order
    }

    RepublicToken public ren;
    DarknodeRegistry public darknodeRegistry;
    SettlementRegistry public settlementRegistry;

    bytes32[] private orderbook;

    // Order details are exposed through directly accessing this mapping, or
    // through the getter functions below for each of the order's fields.
    mapping(bytes32 => Order) public orders;

    event LogFeeUpdated(uint256 previousFee, uint256 nextFee);
    event LogDarknodeRegistryUpdated(DarknodeRegistry previousDarknodeRegistry, DarknodeRegistry nextDarknodeRegistry);

    
    modifier onlyDarknode(address _sender) {
        require(darknodeRegistry.isRegistered(address(_sender)), "must be registered darknode");
        _;
    }

    
    ///
    
    
    
    
    ///        contract.
    constructor(
        string _VERSION,
        RepublicToken _renAddress,
        DarknodeRegistry _darknodeRegistry,
        SettlementRegistry _settlementRegistry
    ) public {
        VERSION = _VERSION;
        ren = _renAddress;
        darknodeRegistry = _darknodeRegistry;
        settlementRegistry = _settlementRegistry;
    }

    
    /// contract.
    function updateDarknodeRegistry(DarknodeRegistry _newDarknodeRegistry) external onlyOwner {
        emit LogDarknodeRegistryUpdated(darknodeRegistry, _newDarknodeRegistry);
        darknodeRegistry = _newDarknodeRegistry;
    }

    
    /// Undefined state.
    ///
    
    ///        message is "Republic Protocol: open: {orderId}".
    
    function openOrder(uint64 _settlementID, bytes _signature, bytes32 _orderID) external {
        require(orders[_orderID].state == OrderState.Undefined, "invalid order status");

        address trader = msg.sender;

        // Verify the order signature
        require(settlementRegistry.settlementRegistration(_settlementID), "settlement not registered");
        BrokerVerifier brokerVerifier = settlementRegistry.brokerVerifierContract(_settlementID);
        require(brokerVerifier.verifyOpenSignature(trader, _signature, _orderID), "invalid broker signature");

        orders[_orderID] = Order({
            state: OrderState.Open,
            trader: trader,
            confirmer: 0x0,
            settlementID: _settlementID,
            priority: orderbook.length + 1,
            blockNumber: block.number,
            matchedOrder: 0x0
        });

        orderbook.push(_orderID);
    }

    
    /// registered Darknode and the orders must be in the Open state. A
    /// malicious confirmation by a Darknode will result in a bond slash of the
    /// Darknode.
    ///
    
    
    function confirmOrder(bytes32 _orderID, bytes32 _matchedOrderID) external onlyDarknode(msg.sender) {
        require(orders[_orderID].state == OrderState.Open, "invalid order status");
        require(orders[_matchedOrderID].state == OrderState.Open, "invalid order status");

        orders[_orderID].state = OrderState.Confirmed;
        orders[_orderID].confirmer = msg.sender;
        orders[_orderID].matchedOrder = _matchedOrderID;
        orders[_orderID].blockNumber = block.number;

        orders[_matchedOrderID].state = OrderState.Confirmed;
        orders[_matchedOrderID].confirmer = msg.sender;
        orders[_matchedOrderID].matchedOrder = _orderID;
        orders[_matchedOrderID].blockNumber = block.number;
    }

    
    /// by the trader who opened the order, or by the broker verifier contract.
    /// This allows the settlement layer to implement their own logic for
    /// cancelling orders without trader interaction (e.g. to ban a trader from
    /// a specific darkpool, or to use multiple order-matching platforms)
    ///
    
    function cancelOrder(bytes32 _orderID) external {
        require(orders[_orderID].state == OrderState.Open, "invalid order state");

        // Require the msg.sender to be the trader or the broker verifier
        address brokerVerifier = address(settlementRegistry.brokerVerifierContract(orders[_orderID].settlementID));
        require(msg.sender == orders[_orderID].trader || msg.sender == brokerVerifier, "not authorized");

        orders[_orderID].state = OrderState.Canceled;
        orders[_orderID].blockNumber = block.number;
    }

    
    function orderState(bytes32 _orderID) external view returns (OrderState) {
        return orders[_orderID].state;
    }

    
    function orderMatch(bytes32 _orderID) external view returns (bytes32) {
        return orders[_orderID].matchedOrder;
    }

    
    /// The priority is the index of the order in the orderbook.
    function orderPriority(bytes32 _orderID) external view returns (uint256) {
        return orders[_orderID].priority;
    }

    
    /// Trader is the one who signs the message and does the actual trading.
    function orderTrader(bytes32 _orderID) external view returns (address) {
        return orders[_orderID].trader;
    }

    
    function orderConfirmer(bytes32 _orderID) external view returns (address) {
        return orders[_orderID].confirmer;
    }

    
    function orderBlockNumber(bytes32 _orderID) external view returns (uint256) {
        return orders[_orderID].blockNumber;
    }

    
    function orderDepth(bytes32 _orderID) external view returns (uint256) {
        if (orders[_orderID].blockNumber == 0) {
            return 0;
        }
        return (block.number - orders[_orderID].blockNumber);
    }

    
    function ordersCount() external view returns (uint256) {
        return orderbook.length;
    }

    
    function getOrders(uint256 _offset, uint256 _limit) external view returns (bytes32[], address[], uint8[]) {
        if (_offset >= orderbook.length) {
            return;
        }

        // If the provided limit is more than the number of orders after the offset,
        // decrease the limit
        uint256 limit = _limit;
        if (_offset + limit > orderbook.length) {
            limit = orderbook.length - _offset;
        }

        bytes32[] memory orderIDs = new bytes32[](limit);
        address[] memory traderAddresses = new address[](limit);
        uint8[] memory states = new uint8[](limit);

        for (uint256 i = 0; i < limit; i++) {
            bytes32 order = orderbook[i + _offset];
            orderIDs[i] = order;
            traderAddresses[i] = orders[order].trader;
            states[i] = uint8(orders[order].state);
        }

        return (orderIDs, traderAddresses, states);
    }
}


library SettlementUtils {

    struct OrderDetails {
        uint64 settlementID;
        uint64 tokens;
        uint256 price;
        uint256 volume;
        uint256 minimumVolume;
    }

    
    
    ///        execution. They are combined as a single byte array.
    
    function hashOrder(bytes details, OrderDetails memory order) internal pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                details,
                order.settlementID,
                order.tokens,
                order.price,
                order.volume,
                order.minimumVolume
            )
        );
    }

    
    /// price, volumes / minimum volumes and settlement IDs. verifyMatchDetails is used
    /// my the DarknodeSlasher to verify challenges. Settlement layers may also
    /// use this function.
    
    ///   1) verify the orders have been confirmed together
    ///   2) verify the orders' traders are distinct
    
    
    function verifyMatchDetails(OrderDetails memory _buy, OrderDetails memory _sell) internal pure returns (bool) {

        // Buy and sell tokens should match
        if (!verifyTokens(_buy.tokens, _sell.tokens)) {
            return false;
        }

        // Buy price should be greater than sell price
        if (_buy.price < _sell.price) {
            return false;
        }

        // // Buy volume should be greater than sell minimum volume
        if (_buy.volume < _sell.minimumVolume) {
            return false;
        }

        // Sell volume should be greater than buy minimum volume
        if (_sell.volume < _buy.minimumVolume) {
            return false;
        }

        // Require that the orders were submitted to the same settlement layer
        if (_buy.settlementID != _sell.settlementID) {
            return false;
        }

        return true;
    }

    
    /// tokens are formatted correctly.
    
    
    function verifyTokens(uint64 _buyTokens, uint64 _sellToken) internal pure returns (bool) {
        return ((
                uint32(_buyTokens) == uint32(_sellToken >> 32)) && (
                uint32(_sellToken) == uint32(_buyTokens >> 32)) && (
                uint32(_buyTokens >> 32) <= uint32(_buyTokens))
        );
    }
}


contract RenExTokens is Ownable {
    string public VERSION; // Passed in as a constructor parameter.

    struct TokenDetails {
        address addr;
        uint8 decimals;
        bool registered;
    }

    // Storage
    mapping(uint32 => TokenDetails) public tokens;
    mapping(uint32 => bool) private detailsSubmitted;

    // Events
    event LogTokenRegistered(uint32 tokenCode, address tokenAddress, uint8 tokenDecimals);
    event LogTokenDeregistered(uint32 tokenCode);

    
    ///
    
    constructor(string _VERSION) public {
        VERSION = _VERSION;
    }

    
    /// Once details have been submitted, they cannot be overwritten.
    /// To re-register the same token with different details (e.g. if the address
    /// has changed), a different token identifier should be used and the
    /// previous token identifier should be deregistered.
    /// If a token is not Ethereum-based, the address will be set to 0x0.
    ///
    
    
    
    function registerToken(uint32 _tokenCode, address _tokenAddress, uint8 _tokenDecimals) public onlyOwner {
        require(!tokens[_tokenCode].registered, "already registered");

        // If a token is being re-registered, the same details must be provided.
        if (detailsSubmitted[_tokenCode]) {
            require(tokens[_tokenCode].addr == _tokenAddress, "different address");
            require(tokens[_tokenCode].decimals == _tokenDecimals, "different decimals");
        } else {
            detailsSubmitted[_tokenCode] = true;
        }

        tokens[_tokenCode] = TokenDetails({
            addr: _tokenAddress,
            decimals: _tokenDecimals,
            registered: true
        });

        emit LogTokenRegistered(_tokenCode, _tokenAddress, _tokenDecimals);
    }

    
    /// to prevent the token from being re-registered with different details.
    ///
    
    function deregisterToken(uint32 _tokenCode) external onlyOwner {
        require(tokens[_tokenCode].registered, "not registered");

        tokens[_tokenCode].registered = false;

        emit LogTokenDeregistered(_tokenCode);
    }
}


/// the on-chain settlement for the RenEx settlement layer, and the fee payment
/// for the RenExAtomic settlement layer.
contract RenExSettlement is Ownable {
    using SafeMath for uint256;

    string public VERSION; // Passed in as a constructor parameter.

    // This contract handles the settlements with ID 1 and 2.
    uint32 constant public RENEX_SETTLEMENT_ID = 1;
    uint32 constant public RENEX_ATOMIC_SETTLEMENT_ID = 2;

    // Fees in RenEx are 0.2%. To represent this as integers, it is broken into
    // a numerator and denominator.
    uint256 constant public DARKNODE_FEES_NUMERATOR = 2;
    uint256 constant public DARKNODE_FEES_DENOMINATOR = 1000;

    // Constants used in the price / volume inputs.
    int16 constant private PRICE_OFFSET = 12;
    int16 constant private VOLUME_OFFSET = 12;

    // Constructor parameters, updatable by the owner
    Orderbook public orderbookContract;
    RenExTokens public renExTokensContract;
    RenExBalances public renExBalancesContract;
    address public slasherAddress;
    uint256 public submissionGasPriceLimit;

    enum OrderStatus {None, Submitted, Settled, Slashed}

    struct TokenPair {
        RenExTokens.TokenDetails priorityToken;
        RenExTokens.TokenDetails secondaryToken;
    }

    // A uint256 tuple representing a value and an associated fee
    struct ValueWithFees {
        uint256 value;
        uint256 fees;
    }

    // A uint256 tuple representing a fraction
    struct Fraction {
        uint256 numerator;
        uint256 denominator;
    }

    // We use left and right because the tokens do not always represent the
    // priority and secondary tokens.
    struct SettlementDetails {
        uint256 leftVolume;
        uint256 rightVolume;
        uint256 leftTokenFee;
        uint256 rightTokenFee;
        address leftTokenAddress;
        address rightTokenAddress;
    }

    // Events
    event LogOrderbookUpdated(Orderbook previousOrderbook, Orderbook nextOrderbook);
    event LogRenExTokensUpdated(RenExTokens previousRenExTokens, RenExTokens nextRenExTokens);
    event LogRenExBalancesUpdated(RenExBalances previousRenExBalances, RenExBalances nextRenExBalances);
    event LogSubmissionGasPriceLimitUpdated(uint256 previousSubmissionGasPriceLimit, uint256 nextSubmissionGasPriceLimit);
    event LogSlasherUpdated(address previousSlasher, address nextSlasher);

    // Order Storage
    mapping(bytes32 => SettlementUtils.OrderDetails) public orderDetails;
    mapping(bytes32 => address) public orderSubmitter;
    mapping(bytes32 => OrderStatus) public orderStatus;

    // Match storage (match details are indexed by [buyID][sellID])
    mapping(bytes32 => mapping(bytes32 => uint256)) public matchTimestamp;

    
    /// than the specified limit.
    ///
    
    modifier withGasPriceLimit(uint256 _gasPriceLimit) {
        require(tx.gasprice <= _gasPriceLimit, "gas price too high");
        _;
    }

    
    /// address.
    modifier onlySlasher() {
        require(msg.sender == slasherAddress, "unauthorized");
        _;
    }

    
    ///
    
    
    
    ///        contract.
    
    constructor(
        string _VERSION,
        Orderbook _orderbookContract,
        RenExTokens _renExTokensContract,
        RenExBalances _renExBalancesContract,
        address _slasherAddress,
        uint256 _submissionGasPriceLimit
    ) public {
        VERSION = _VERSION;
        orderbookContract = _orderbookContract;
        renExTokensContract = _renExTokensContract;
        renExBalancesContract = _renExBalancesContract;
        slasherAddress = _slasherAddress;
        submissionGasPriceLimit = _submissionGasPriceLimit;
    }

    
    
    function updateOrderbook(Orderbook _newOrderbookContract) external onlyOwner {
        emit LogOrderbookUpdated(orderbookContract, _newOrderbookContract);
        orderbookContract = _newOrderbookContract;
    }

    
    
    ///       contract.
    function updateRenExTokens(RenExTokens _newRenExTokensContract) external onlyOwner {
        emit LogRenExTokensUpdated(renExTokensContract, _newRenExTokensContract);
        renExTokensContract = _newRenExTokensContract;
    }
    
    
    
    ///       contract.
    function updateRenExBalances(RenExBalances _newRenExBalancesContract) external onlyOwner {
        emit LogRenExBalancesUpdated(renExBalancesContract, _newRenExBalancesContract);
        renExBalancesContract = _newRenExBalancesContract;
    }

    
    /// price limit.
    
    function updateSubmissionGasPriceLimit(uint256 _newSubmissionGasPriceLimit) external onlyOwner {
        emit LogSubmissionGasPriceLimitUpdated(submissionGasPriceLimit, _newSubmissionGasPriceLimit);
        submissionGasPriceLimit = _newSubmissionGasPriceLimit;
    }

    
    
    function updateSlasher(address _newSlasherAddress) external onlyOwner {
        emit LogSlasherUpdated(slasherAddress, _newSlasherAddress);
        slasherAddress = _newSlasherAddress;
    }

    
    ///
    
    ///        calculating the order id.
    
    
    ///        the first 32 bytes and sell token is encoded as the last 32
    ///        bytes).
    
    ///        standard unit of the non-priority token, in 1e12 (i.e.
    ///        PRICE_OFFSET) units of the priority token).
    
    ///        number of 1e-12 (i.e. VOLUME_OFFSET) units of the non-priority
    ///        token that can be traded by this order.
    
    ///        accept. Encoded the same as the volume.
    function submitOrder(
        bytes _prefix,
        uint64 _settlementID,
        uint64 _tokens,
        uint256 _price,
        uint256 _volume,
        uint256 _minimumVolume
    ) external withGasPriceLimit(submissionGasPriceLimit) {

        SettlementUtils.OrderDetails memory order = SettlementUtils.OrderDetails({
            settlementID: _settlementID,
            tokens: _tokens,
            price: _price,
            volume: _volume,
            minimumVolume: _minimumVolume
        });
        bytes32 orderID = SettlementUtils.hashOrder(_prefix, order);

        require(orderStatus[orderID] == OrderStatus.None, "order already submitted");
        require(orderbookContract.orderState(orderID) == Orderbook.OrderState.Confirmed, "unconfirmed order");

        orderSubmitter[orderID] = msg.sender;
        orderStatus[orderID] = OrderStatus.Submitted;
        orderDetails[orderID] = order;
    }

    
    /// called for each order before this function is called.
    ///
    
    
    function settle(bytes32 _buyID, bytes32 _sellID) external {
        require(orderStatus[_buyID] == OrderStatus.Submitted, "invalid buy status");
        require(orderStatus[_sellID] == OrderStatus.Submitted, "invalid sell status");

        // Check the settlement ID (only have to check for one, since
        // `verifyMatchDetails` checks that they are the same)
        require(
            orderDetails[_buyID].settlementID == RENEX_ATOMIC_SETTLEMENT_ID ||
            orderDetails[_buyID].settlementID == RENEX_SETTLEMENT_ID,
            "invalid settlement id"
        );

        // Verify that the two order details are compatible.
        require(SettlementUtils.verifyMatchDetails(orderDetails[_buyID], orderDetails[_sellID]), "incompatible orders");

        // Verify that the two orders have been confirmed to one another.
        require(orderbookContract.orderMatch(_buyID) == _sellID, "unconfirmed orders");

        // Retrieve token details.
        TokenPair memory tokens = getTokenDetails(orderDetails[_buyID].tokens);

        // Require that the tokens have been registered.
        require(tokens.priorityToken.registered, "unregistered priority token");
        require(tokens.secondaryToken.registered, "unregistered secondary token");

        address buyer = orderbookContract.orderTrader(_buyID);
        address seller = orderbookContract.orderTrader(_sellID);

        require(buyer != seller, "orders from same trader");

        execute(_buyID, _sellID, buyer, seller, tokens);

        /* solium-disable-next-line security/no-block-members */
        matchTimestamp[_buyID][_sellID] = now;

        // Store that the orders have been settled.
        orderStatus[_buyID] = OrderStatus.Settled;
        orderStatus[_sellID] = OrderStatus.Settled;
    }

    
    /// atomic swap is not executed successfully.
    /// To open an atomic order, a trader must have a balance equivalent to
    /// 0.6% of the trade in the Ethereum-based token. 0.2% is always paid in
    /// darknode fees when the order is matched. If the remaining amount is
    /// is slashed, it is distributed as follows:
    ///   1) 0.2% goes to the other trader, covering their fee
    ///   2) 0.2% goes to the slasher address
    /// Only one order in a match can be slashed.
    ///
    
    function slash(bytes32 _guiltyOrderID) external onlySlasher {
        require(orderDetails[_guiltyOrderID].settlementID == RENEX_ATOMIC_SETTLEMENT_ID, "slashing non-atomic trade");

        bytes32 innocentOrderID = orderbookContract.orderMatch(_guiltyOrderID);

        require(orderStatus[_guiltyOrderID] == OrderStatus.Settled, "invalid order status");
        require(orderStatus[innocentOrderID] == OrderStatus.Settled, "invalid order status");
        orderStatus[_guiltyOrderID] = OrderStatus.Slashed;

        (bytes32 buyID, bytes32 sellID) = isBuyOrder(_guiltyOrderID) ?
            (_guiltyOrderID, innocentOrderID) : (innocentOrderID, _guiltyOrderID);

        TokenPair memory tokens = getTokenDetails(orderDetails[buyID].tokens);

        SettlementDetails memory settlementDetails = calculateAtomicFees(buyID, sellID, tokens);

        // Transfer the fee amount to the other trader
        renExBalancesContract.transferBalanceWithFee(
            orderbookContract.orderTrader(_guiltyOrderID),
            orderbookContract.orderTrader(innocentOrderID),
            settlementDetails.leftTokenAddress,
            settlementDetails.leftTokenFee,
            0,
            0x0
        );

        // Transfer the fee amount to the slasher
        renExBalancesContract.transferBalanceWithFee(
            orderbookContract.orderTrader(_guiltyOrderID),
            slasherAddress,
            settlementDetails.leftTokenAddress,
            settlementDetails.leftTokenFee,
            0,
            0x0
        );
    }

    
    /// For atomic swaps, it returns the full volumes, not the settled fees.
    ///
    
    ///        buy or a sell order.
    
    ///     a boolean representing whether or not the order has been settled,
    ///     a boolean representing whether or not the order is a buy
    ///     the 32-byte order ID of the matched order
    ///     the volume of the priority token,
    ///     the volume of the secondary token,
    ///     the fee paid in the priority token,
    ///     the fee paid in the secondary token,
    ///     the token code of the priority token,
    ///     the token code of the secondary token
    /// ]
    function getMatchDetails(bytes32 _orderID)
    external view returns (
        bool settled,
        bool orderIsBuy,
        bytes32 matchedID,
        uint256 priorityVolume,
        uint256 secondaryVolume,
        uint256 priorityFee,
        uint256 secondaryFee,
        uint32 priorityToken,
        uint32 secondaryToken
    ) {
        matchedID = orderbookContract.orderMatch(_orderID);

        orderIsBuy = isBuyOrder(_orderID);

        (bytes32 buyID, bytes32 sellID) = orderIsBuy ?
            (_orderID, matchedID) : (matchedID, _orderID);

        SettlementDetails memory settlementDetails = calculateSettlementDetails(
            buyID,
            sellID,
            getTokenDetails(orderDetails[buyID].tokens)
        );

        return (
            orderStatus[_orderID] == OrderStatus.Settled || orderStatus[_orderID] == OrderStatus.Slashed,
            orderIsBuy,
            matchedID,
            settlementDetails.leftVolume,
            settlementDetails.rightVolume,
            settlementDetails.leftTokenFee,
            settlementDetails.rightTokenFee,
            uint32(orderDetails[buyID].tokens >> 32),
            uint32(orderDetails[buyID].tokens)
        );
    }

    
    /// order's details. An order hash is used as its ID. See `submitOrder`
    /// for the parameter descriptions.
    ///
    
    function hashOrder(
        bytes _prefix,
        uint64 _settlementID,
        uint64 _tokens,
        uint256 _price,
        uint256 _volume,
        uint256 _minimumVolume
    ) external pure returns (bytes32) {
        return SettlementUtils.hashOrder(_prefix, SettlementUtils.OrderDetails({
            settlementID: _settlementID,
            tokens: _tokens,
            price: _price,
            volume: _volume,
            minimumVolume: _minimumVolume
        }));
    }

    
    /// or distributes the fees for a RenExAtomic swap.
    ///
    
    
    
    
    
    function execute(
        bytes32 _buyID,
        bytes32 _sellID,
        address _buyer,
        address _seller,
        TokenPair memory _tokens
    ) private {
        // Calculate the fees for atomic swaps, and the settlement details
        // otherwise.
        SettlementDetails memory settlementDetails = (orderDetails[_buyID].settlementID == RENEX_ATOMIC_SETTLEMENT_ID) ?
            settlementDetails = calculateAtomicFees(_buyID, _sellID, _tokens) :
            settlementDetails = calculateSettlementDetails(_buyID, _sellID, _tokens);

        // Transfer priority token value
        renExBalancesContract.transferBalanceWithFee(
            _buyer,
            _seller,
            settlementDetails.leftTokenAddress,
            settlementDetails.leftVolume,
            settlementDetails.leftTokenFee,
            orderSubmitter[_buyID]
        );

        // Transfer secondary token value
        renExBalancesContract.transferBalanceWithFee(
            _seller,
            _buyer,
            settlementDetails.rightTokenAddress,
            settlementDetails.rightVolume,
            settlementDetails.rightTokenFee,
            orderSubmitter[_sellID]
        );
    }

    
    ///
    
    
    
    
    function calculateSettlementDetails(
        bytes32 _buyID,
        bytes32 _sellID,
        TokenPair memory _tokens
    ) private view returns (SettlementDetails memory) {

        // Calculate the mid-price (using numerator and denominator to not loose
        // precision).
        Fraction memory midPrice = Fraction(orderDetails[_buyID].price + orderDetails[_sellID].price, 2);

        // Calculate the lower of the two max volumes of each trader
        uint256 commonVolume = Math.min256(orderDetails[_buyID].volume, orderDetails[_sellID].volume);

        uint256 priorityTokenVolume = joinFraction(
            commonVolume.mul(midPrice.numerator),
            midPrice.denominator,
            int16(_tokens.priorityToken.decimals) - PRICE_OFFSET - VOLUME_OFFSET
        );
        uint256 secondaryTokenVolume = joinFraction(
            commonVolume,
            1,
            int16(_tokens.secondaryToken.decimals) - VOLUME_OFFSET
        );

        // Calculate darknode fees
        ValueWithFees memory priorityVwF = subtractDarknodeFee(priorityTokenVolume);
        ValueWithFees memory secondaryVwF = subtractDarknodeFee(secondaryTokenVolume);

        return SettlementDetails({
            leftVolume: priorityVwF.value,
            rightVolume: secondaryVwF.value,
            leftTokenFee: priorityVwF.fees,
            rightTokenFee: secondaryVwF.fees,
            leftTokenAddress: _tokens.priorityToken.addr,
            rightTokenAddress: _tokens.secondaryToken.addr
        });
    }

    
    ///
    
    
    
    
    function calculateAtomicFees(
        bytes32 _buyID,
        bytes32 _sellID,
        TokenPair memory _tokens
    ) private view returns (SettlementDetails memory) {

        // Calculate the mid-price (using numerator and denominator to not loose
        // precision).
        Fraction memory midPrice = Fraction(orderDetails[_buyID].price + orderDetails[_sellID].price, 2);

        // Calculate the lower of the two max volumes of each trader
        uint256 commonVolume = Math.min256(orderDetails[_buyID].volume, orderDetails[_sellID].volume);

        if (isEthereumBased(_tokens.secondaryToken.addr)) {
            uint256 secondaryTokenVolume = joinFraction(
                commonVolume,
                1,
                int16(_tokens.secondaryToken.decimals) - VOLUME_OFFSET
            );

            // Calculate darknode fees
            ValueWithFees memory secondaryVwF = subtractDarknodeFee(secondaryTokenVolume);

            return SettlementDetails({
                leftVolume: 0,
                rightVolume: 0,
                leftTokenFee: secondaryVwF.fees,
                rightTokenFee: secondaryVwF.fees,
                leftTokenAddress: _tokens.secondaryToken.addr,
                rightTokenAddress: _tokens.secondaryToken.addr
            });
        } else if (isEthereumBased(_tokens.priorityToken.addr)) {
            uint256 priorityTokenVolume = joinFraction(
                commonVolume.mul(midPrice.numerator),
                midPrice.denominator,
                int16(_tokens.priorityToken.decimals) - PRICE_OFFSET - VOLUME_OFFSET
            );

            // Calculate darknode fees
            ValueWithFees memory priorityVwF = subtractDarknodeFee(priorityTokenVolume);

            return SettlementDetails({
                leftVolume: 0,
                rightVolume: 0,
                leftTokenFee: priorityVwF.fees,
                rightTokenFee: priorityVwF.fees,
                leftTokenAddress: _tokens.priorityToken.addr,
                rightTokenAddress: _tokens.priorityToken.addr
            });
        } else {
            // Currently, at least one token must be Ethereum-based.
            // This will be implemented in the future.
            revert("non-eth atomic swaps are not supported");
        }
    }

    
    /// whether an order is a buy or a sell.
    
    function isBuyOrder(bytes32 _orderID) private view returns (bool) {
        uint64 tokens = orderDetails[_orderID].tokens;
        uint32 firstToken = uint32(tokens >> 32);
        uint32 secondaryToken = uint32(tokens);
        return (firstToken < secondaryToken);
    }

    
    function subtractDarknodeFee(uint256 _value) private pure returns (ValueWithFees memory) {
        uint256 newValue = (_value * (DARKNODE_FEES_DENOMINATOR - DARKNODE_FEES_NUMERATOR)) / DARKNODE_FEES_DENOMINATOR;
        return ValueWithFees(newValue, _value - newValue);
    }

    
    /// the RenExTokens contract and returns them as a single struct.
    ///
    
    
    function getTokenDetails(uint64 _tokens) private view returns (TokenPair memory) {
        (
            address priorityAddress,
            uint8 priorityDecimals,
            bool priorityRegistered
        ) = renExTokensContract.tokens(uint32(_tokens >> 32));

        (
            address secondaryAddress,
            uint8 secondaryDecimals,
            bool secondaryRegistered
        ) = renExTokensContract.tokens(uint32(_tokens));

        return TokenPair({
            priorityToken: RenExTokens.TokenDetails(priorityAddress, priorityDecimals, priorityRegistered),
            secondaryToken: RenExTokens.TokenDetails(secondaryAddress, secondaryDecimals, secondaryRegistered)
        });
    }

    
    /// on Ethereum
    function isEthereumBased(address _tokenAddress) private pure returns (bool) {
        return (_tokenAddress != address(0x0));
    }

    
    function joinFraction(uint256 _numerator, uint256 _denominator, int16 _scale) private pure returns (uint256) {
        if (_scale >= 0) {
            // Check that (10**_scale) doesn't overflow
            assert(_scale <= 77); // log10(2**256) = 77.06
            return _numerator.mul(10 ** uint256(_scale)) / _denominator;
        } else {
            
            // For now, -_scale > -24 (when a token has 0 decimals and
            // VOLUME_OFFSET and PRICE_OFFSET are each 12). It is unlikely these
            // will be increased to add to more than 77.
            // assert((-_scale) <= 77); // log10(2**256) = 77.06
            return (_numerator / _denominator) / 10 ** uint256(-_scale);
        }
    }
}


/// verifying broker signatures for order opening and fund withdrawal.
contract RenExBrokerVerifier is Ownable {
    string public VERSION; // Passed in as a constructor parameter.

    // Events
    event LogBalancesContractUpdated(address previousBalancesContract, address nextBalancesContract);
    event LogBrokerRegistered(address broker);
    event LogBrokerDeregistered(address broker);

    // Storage
    mapping(address => bool) public brokers;
    mapping(address => uint256) public traderNonces;

    address public balancesContract;

    modifier onlyBalancesContract() {
        require(msg.sender == balancesContract, "not authorized");
        _;
    }

    
    ///
    
    constructor(string _VERSION) public {
        VERSION = _VERSION;
    }

    
    /// RenExBalances contract.
    ///
    
    function updateBalancesContract(address _balancesContract) external onlyOwner {
        emit LogBalancesContractUpdated(balancesContract, _balancesContract);

        balancesContract = _balancesContract;
    }

    
    
    function registerBroker(address _broker) external onlyOwner {
        require(!brokers[_broker], "already registered");
        brokers[_broker] = true;
        emit LogBrokerRegistered(_broker);
    }

    
    
    function deregisterBroker(address _broker) external onlyOwner {
        require(brokers[_broker], "not registered");
        brokers[_broker] = false;
        emit LogBrokerDeregistered(_broker);
    }

    
    /// The data signed by the broker is a prefixed message and the order ID.
    ///
    
    
    
    
    function verifyOpenSignature(
        address _trader,
        bytes _signature,
        bytes32 _orderID
    ) external view returns (bool) {
        bytes memory data = abi.encodePacked("Republic Protocol: open: ", _trader, _orderID);
        address signer = Utils.addr(data, _signature);
        return (brokers[signer] == true);
    }

    
    /// The data signed by the broker is a prefixed message, the trader address
    /// and a 256-bit trader nonce, which is incremented every time a valid
    /// signature is checked.
    ///
    
    
    
    function verifyWithdrawSignature(
        address _trader,
        bytes _signature
    ) external onlyBalancesContract returns (bool) {
        bytes memory data = abi.encodePacked("Republic Protocol: withdraw: ", _trader, traderNonces[_trader]);
        address signer = Utils.addr(data, _signature);
        if (brokers[signer]) {
            traderNonces[_trader] += 1;
            return true;
        }
        return false;
    }
}


contract RenExBalances is Ownable {
    using SafeMath for uint256;
    using CompatibleERC20Functions for CompatibleERC20;

    string public VERSION; // Passed in as a constructor parameter.

    RenExSettlement public settlementContract;
    RenExBrokerVerifier public brokerVerifierContract;
    DarknodeRewardVault public rewardVaultContract;

    
    address constant public ETHEREUM = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    
    // Delay between a trader calling `withdrawSignal` and being able to call
    // `withdraw` without a broker signature.
    uint256 constant public SIGNAL_DELAY = 48 hours;

    // Events
    event LogBalanceDecreased(address trader, ERC20 token, uint256 value);
    event LogBalanceIncreased(address trader, ERC20 token, uint256 value);
    event LogRenExSettlementContractUpdated(address previousRenExSettlementContract, address newRenExSettlementContract);
    event LogRewardVaultContractUpdated(address previousRewardVaultContract, address newRewardVaultContract);
    event LogBrokerVerifierContractUpdated(address previousBrokerVerifierContract, address newBrokerVerifierContract);

    // Storage
    mapping(address => mapping(address => uint256)) public traderBalances;
    mapping(address => mapping(address => uint256)) public traderWithdrawalSignals;

    
    ///
    
    
    constructor(
        string _VERSION,
        DarknodeRewardVault _rewardVaultContract,
        RenExBrokerVerifier _brokerVerifierContract
    ) public {
        VERSION = _VERSION;
        rewardVaultContract = _rewardVaultContract;
        brokerVerifierContract = _brokerVerifierContract;
    }

    
    /// contract.
    modifier onlyRenExSettlementContract() {
        require(msg.sender == address(settlementContract), "not authorized");
        _;
    }

    
    /// RenEx broker is provided, or if a certain amount of time has passed
    /// since a trader has called `signalBackupWithdraw`.
    
    /// this will reset the time to zero, writing to storage.
    modifier withBrokerSignatureOrSignal(address _token, bytes _signature) {
        address trader = msg.sender;
        if (brokerVerifierContract.verifyWithdrawSignature(trader, _signature)) {
            _;
        } else {
            bool hasSignalled = traderWithdrawalSignals[trader][_token] != 0;
            /* solium-disable-next-line security/no-block-members */
            bool hasWaitedDelay = (now - traderWithdrawalSignals[trader][_token]) > SIGNAL_DELAY;
            require(hasSignalled && hasWaitedDelay, "not signalled");
            traderWithdrawalSignals[trader][_token] = 0;
            _;
        }
    }

    
    /// RenExSettlement contract.
    ///
    
    function updateRenExSettlementContract(RenExSettlement _newSettlementContract) external onlyOwner {
        emit LogRenExSettlementContractUpdated(settlementContract, _newSettlementContract);
        settlementContract = _newSettlementContract;
    }

    
    /// DarknodeRewardVault contract.
    ///
    
    function updateRewardVaultContract(DarknodeRewardVault _newRewardVaultContract) external onlyOwner {
        emit LogRewardVaultContractUpdated(rewardVaultContract, _newRewardVaultContract);
        rewardVaultContract = _newRewardVaultContract;
    }

    
    /// RenExBrokerVerifier contract.
    ///
    
    function updateBrokerVerifierContract(RenExBrokerVerifier _newBrokerVerifierContract) external onlyOwner {
        emit LogBrokerVerifierContractUpdated(brokerVerifierContract, _newBrokerVerifierContract);
        brokerVerifierContract = _newBrokerVerifierContract;
    }

    
    /// a fee to the RewardVault. Can only be called by the RenExSettlement
    /// contract.
    ///
    
    
    
    
    ///        token's smallest unit).
    
    
    function transferBalanceWithFee(address _traderFrom, address _traderTo, address _token, uint256 _value, uint256 _fee, address _feePayee)
    external onlyRenExSettlementContract {
        require(traderBalances[_traderFrom][_token] >= _fee, "insufficient funds for fee");

        if (address(_token) == ETHEREUM) {
            rewardVaultContract.deposit.value(_fee)(_feePayee, ERC20(_token), _fee);
        } else {
            CompatibleERC20(_token).safeApprove(rewardVaultContract, _fee);
            rewardVaultContract.deposit(_feePayee, ERC20(_token), _fee);
        }
        privateDecrementBalance(_traderFrom, ERC20(_token), _value + _fee);
        if (_value > 0) {
            privateIncrementBalance(_traderTo, ERC20(_token), _value);
        }
    }

    
    ///
    
    
    function deposit(ERC20 _token, uint256 _value) external payable {
        address trader = msg.sender;

        if (address(_token) == ETHEREUM) {
            require(msg.value == _value, "mismatched value parameter and tx value");
        } else {
            require(msg.value == 0, "unexpected ether transfer");
            CompatibleERC20(_token).safeTransferFromWithFees(trader, this, _value);
        }
        privateIncrementBalance(trader, _token, _value);
    }

    
    /// signature is required to guarantee that the trader has a sufficient
    /// balance after accounting for open orders. As a trustless backup,
    /// traders can withdraw 48 hours after calling `signalBackupWithdraw`.
    ///
    
    
    
    function withdraw(ERC20 _token, uint256 _value, bytes _signature) external withBrokerSignatureOrSignal(_token, _signature) {
        address trader = msg.sender;

        privateDecrementBalance(trader, _token, _value);
        if (address(_token) == ETHEREUM) {
            trader.transfer(_value);
        } else {
            CompatibleERC20(_token).safeTransfer(trader, _value);
        }
    }

    
    /// first call `signalBackupWithdraw` for the token they want to withdraw.
    /// The trader can only withdraw the particular token once for each call to
    /// this function. Traders can signal the intent to withdraw multiple
    /// tokens.
    /// Once this function is called, brokers will not sign order-opens for the
    /// trader until the trader has withdrawn, guaranteeing that they won't have
    /// orders open for the particular token.
    function signalBackupWithdraw(address _token) external {
        /* solium-disable-next-line security/no-block-members */
        traderWithdrawalSignals[msg.sender][_token] = now;
    }

    function privateIncrementBalance(address _trader, ERC20 _token, uint256 _value) private {
        traderBalances[_trader][_token] = traderBalances[_trader][_token].add(_value);

        emit LogBalanceIncreased(_trader, _token, _value);
    }

    function privateDecrementBalance(address _trader, ERC20 _token, uint256 _value) private {
        require(traderBalances[_trader][_token] >= _value, "insufficient funds");
        traderBalances[_trader][_token] = traderBalances[_trader][_token].sub(_value);

        emit LogBalanceDecreased(_trader, _token, _value);
    }
}