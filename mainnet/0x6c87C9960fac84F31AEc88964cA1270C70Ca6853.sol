// SPDX-License-Identifier: MIT


// 

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 

pragma solidity >=0.6.0 <0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// 

pragma solidity >=0.6.0 <0.8.0;



/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// 

pragma solidity 0.7.6;

interface KeeperCompatibleInterface {

  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(
    bytes calldata checkData
  )
    external
    returns (
      bool upkeepNeeded,
      bytes memory performData
    );
  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(
    bytes calldata performData
  ) external;
}
// 

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// 

pragma solidity >=0.6.12 <=0.7.6;






contract AddressRegistry is Ownable {

    using MappedSinglyLinkedList for MappedSinglyLinkedList.Mapping;

    MappedSinglyLinkedList.Mapping internal addressList;

    
    event AddressAdded(address indexed _address);
    
    
    event AddressRemoved(address indexed _address);

    
    event AllAddressesCleared();

    
    string public addressType;    

    
    
    
    constructor(string memory _addressType, address _owner) Ownable() {
        addressType = _addressType;
        addressList.initialize();
        transferOwnership(_owner);
    }

    
    
    function getAddresses() view external returns(address[] memory) {
        return addressList.addressArray();
    } 

    
    
    function addAddresses(address[] calldata _addresses) public onlyOwner {
        for(uint256 _address = 0; _address < _addresses.length; _address++ ){
            addressList.addAddress(_addresses[_address]);
            emit AddressAdded(_addresses[_address]);
        }
    }

    
    
    
    function removeAddress(address _previousContract, address _address) public onlyOwner {
        addressList.removeAddress(_previousContract, _address); 
        emit AddressRemoved(_address);
    } 

    
    function clearAll() public onlyOwner {
        addressList.clearAll();
        emit AllAddressesCleared();
    }
    
    
    
    
    function contains(address _addr) public returns (bool) {
        return addressList.contains(_addr);
    }

    
    
    function start() public view returns (address) {
        return addressList.addressMap[MappedSinglyLinkedList.SENTINEL];
    }

    
    
    
    function next(address current) public view returns (address) {
        return addressList.addressMap[current];
    }
    
    
    
    function end() public pure returns (address) {
        return MappedSinglyLinkedList.SENTINEL;
    }

}

// 

pragma solidity ^0.7.6;



library MappedSinglyLinkedList {

  
  address public constant SENTINEL = address(0x1);

  
  struct Mapping {
    uint256 count;

    mapping(address => address) addressMap;
  }

  
  
  function initialize(Mapping storage self) internal {
    require(self.count == 0, "Already init");
    self.addressMap[SENTINEL] = SENTINEL;
  }

  function start(Mapping storage self) internal view returns (address) {
    return self.addressMap[SENTINEL];
  }

  function next(Mapping storage self, address current) internal view returns (address) {
    return self.addressMap[current];
  }

  function end(Mapping storage) internal pure returns (address) {
    return SENTINEL;
  }

  function addAddresses(Mapping storage self, address[] memory addresses) internal {
    for (uint256 i = 0; i < addresses.length; i++) {
      addAddress(self, addresses[i]);
    }
  }

  
  
  
  function addAddress(Mapping storage self, address newAddress) internal {
    require(newAddress != SENTINEL && newAddress != address(0), "Invalid address");
    require(self.addressMap[newAddress] == address(0), "Already added");
    self.addressMap[newAddress] = self.addressMap[SENTINEL];
    self.addressMap[SENTINEL] = newAddress;
    self.count = self.count + 1;
  }

  
  
  
  
  function removeAddress(Mapping storage self, address prevAddress, address addr) internal {
    require(addr != SENTINEL && addr != address(0), "Invalid address");
    require(self.addressMap[prevAddress] == addr, "Invalid prevAddress");
    self.addressMap[prevAddress] = self.addressMap[addr];
    delete self.addressMap[addr];
    self.count = self.count - 1;
  }

  
  
  
  
  function contains(Mapping storage self, address addr) internal view returns (bool) {
    return addr != SENTINEL && addr != address(0) && self.addressMap[addr] != address(0);
  }

  
  
  
  
  function addressArray(Mapping storage self) internal view returns (address[] memory) {
    address[] memory array = new address[](self.count);
    uint256 count;
    address currentAddress = self.addressMap[SENTINEL];
    while (currentAddress != address(0) && currentAddress != SENTINEL) {
      array[count] = currentAddress;
      currentAddress = self.addressMap[currentAddress];
      count++;
    }
    return array;
  }

  
  
  function clearAll(Mapping storage self) internal {
    address currentAddress = self.addressMap[SENTINEL];
    while (currentAddress != address(0) && currentAddress != SENTINEL) {
      address nextAddress = self.addressMap[currentAddress];
      delete self.addressMap[currentAddress];
      currentAddress = nextAddress;
    }
    self.addressMap[SENTINEL] = SENTINEL;
    self.count = 0;
  }
}

// 

pragma solidity ^0.7.6;











contract PodsUpkeep is KeeperCompatibleInterface, Ownable, Pausable {

    using SafeMathUpgradeable for uint256;
    
    
    AddressRegistry public podsRegistry;

    
    uint8 constant PODS_PACKED_ARRAY_SIZE = 10;

    uint256[PODS_PACKED_ARRAY_SIZE] internal lastUpkeepBlockNumber;

    
    uint256 public upkeepBlockInterval;    

    
    event UpkeepBlockIntervalUpdated(uint upkeepBlockInterval);

    
    event UpkeepBatchLimitUpdated(uint upkeepBatchLimit);
    
    
    event PodsRegistryUpdated(AddressRegistry addressRegistry);

    
    uint256 public upkeepBatchLimit;

    
    constructor(AddressRegistry _podsRegistry, address _owner, uint256 _upkeepBlockInterval, uint256 _upkeepBatchLimit) Ownable() {
        
        podsRegistry = _podsRegistry;
        emit PodsRegistryUpdated(_podsRegistry);

        transferOwnership(_owner);
        
        upkeepBlockInterval = _upkeepBlockInterval;
        emit UpkeepBlockIntervalUpdated(_upkeepBlockInterval);

        upkeepBatchLimit = _upkeepBatchLimit;
        emit UpkeepBatchLimitUpdated(_upkeepBatchLimit);
    }

    
    
    
    
    function _updateLastBlockNumberForPodIndex(uint256 _existingUpkeepBlockNumbers, uint8 _podIndex, uint32 _value) internal pure returns (uint256) { 

        uint256 mask =  (type(uint32).max | uint256(0)) << (_podIndex * 32); // get a mask of all 1's at the pod index    
        uint256 updateBits =  (uint256(0) | _value) << (_podIndex * 32); // position value at index with 0's in every other position

        /* 
        (updateBits | ~mask) 
            negation of the mask is 0's at the location of the block number, 1's everywhere else
            OR'ing it with updateBits will give 1's everywhere else, block number intact
        
        (_existingUpkeepBlockNumbers | mask)
            OR'ing the exstingUpkeepBlockNumbers with mask will give maintain other blocknumber, put all 1's at podIndex
        
            finally AND'ing the two halves will filter through 1's if they are supposed to be there
        */
        return (updateBits | ~mask) & (_existingUpkeepBlockNumbers | mask); 
    }

    
    
    
    function _readLastBlockNumberForPodIndex(uint256 _existingUpkeepBlockNumbers, uint8 _podIndex) internal pure returns (uint32) { 
  
        uint256 mask =  (type(uint32).max | uint256(0)) << (_podIndex * 32);
        return uint32((_existingUpkeepBlockNumbers & mask) >> (_podIndex * 32));
    }

    
    
    function readLastBlockNumberForPodIndex(uint256 podIndex) public view returns (uint32) {
        
        uint256 wordIndex = podIndex / 8;
        return _readLastBlockNumberForPodIndex(lastUpkeepBlockNumber[wordIndex], uint8(podIndex % 8));
    }

    
    
    
    function checkUpkeep(bytes calldata checkData) override external view returns (bool upkeepNeeded, bytes memory performData) {
        
        if(paused()) return (false, performData);   

        address[] memory pods = podsRegistry.getAddresses();
        uint256 _upkeepBlockInterval = upkeepBlockInterval;
        uint256 podsLength = pods.length;

        for(uint256 podWord = 0; podWord <= podsLength / 8; podWord++){

            uint256 _lastUpkeep = lastUpkeepBlockNumber[podWord]; // this performs the SLOAD
            for(uint256 i = 0; i + (podWord * 8) < podsLength; i++){
                
                uint32 podLastUpkeepBlockNumber = _readLastBlockNumberForPodIndex(_lastUpkeep, uint8(i));
                if(block.number > podLastUpkeepBlockNumber + _upkeepBlockInterval){
                    return (true, "");
                }
            }
        }       
        return (false, "");    
    }

    
    
    function performUpkeep(bytes calldata performData) override external whenNotPaused{
    
        address[] memory pods = podsRegistry.getAddresses();
        uint256 podsLength = pods.length;
        uint256 _batchLimit = upkeepBatchLimit;
        uint256 batchesPerformed = 0;

        for(uint8 podWord = 0; podWord <= podsLength / 8; podWord++){ // give word index
            
            uint256 _updateBlockNumber = lastUpkeepBlockNumber[podWord]; // this performs the SLOAD

            for(uint8 i = 0; i + (podWord * 8) < podsLength; i++){ // pod index within word
                
                if(batchesPerformed >= _batchLimit) {
                    break;
                }
                // get the 32 bit block number from the 256 bit word
                uint32 podLastUpkeepBlockNumber = _readLastBlockNumberForPodIndex(_updateBlockNumber, i);
                if(block.number > podLastUpkeepBlockNumber + upkeepBlockInterval) {
                    IPod(pods[i + (podWord * 8)]).drop();
                    batchesPerformed++;
                    // updated pod's most recent upkeep block number and store update to that 256 bit word
                    _updateBlockNumber = _updateLastBlockNumberForPodIndex(_updateBlockNumber, i, uint32(block.number));                   
                }
            }         
            lastUpkeepBlockNumber[podWord] = _updateBlockNumber; // update the entire 256 bit word at once
        }
    }

    
    
    function updateBlockUpkeepInterval(uint256 _upkeepBlockInterval) external onlyOwner {
        upkeepBlockInterval = _upkeepBlockInterval;
        emit UpkeepBlockIntervalUpdated(_upkeepBlockInterval);
    }

    
    
    function updateUpkeepBatchLimit(uint256 _upkeepBatchLimit) external onlyOwner {
        upkeepBatchLimit = _upkeepBatchLimit;
        emit UpkeepBatchLimitUpdated(_upkeepBatchLimit);
    }

    
    
    function updatePodsRegistry(AddressRegistry _addressRegistry) external onlyOwner {
        podsRegistry = _addressRegistry;
        emit PodsRegistryUpdated(_addressRegistry);
    }

    
    function pause() external onlyOwner {
        _pause();
    }

    
    function unpause() external onlyOwner {
        _unpause();
    }
}

// 

pragma solidity ^0.7.6;


interface IPod {     
 
     function drop() external returns (uint256);
    

}
