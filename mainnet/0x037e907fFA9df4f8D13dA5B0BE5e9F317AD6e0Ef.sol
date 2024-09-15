// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;


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
        return addressList.start();
    }

    
    
    
    function next(address current) public view returns (address) {
        return addressList.next(current);
    }
    
    
    
    function end() public view returns (address) {
        return addressList.end();
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













contract PrizeStrategyUpkeep is KeeperCompatibleInterface, Ownable, Pausable {

    
    using SafeAwardable for address;

    
    AddressRegistry public prizePoolRegistry;

    
    
    uint256 public upkeepBatchSize;

    
    uint256 public upkeepLastUpkeepBlockNumber;

    
    uint256 public upkeepMinimumBlockInterval;

    
    event UpkeepBatchSizeUpdated(uint256 upkeepBatchSize);

    
    event UpkeepPrizePoolRegistryUpdated(AddressRegistry prizePoolRegistry);

    
    event UpkeepMinimumBlockIntervalUpdated(uint256 upkeepMinimumBlockInterval);

    
    event UpkeepPerformed(uint256 startAwardsPerformed, uint256 completeAwardsPerformed);


    constructor(AddressRegistry _prizePoolRegistry, uint256 _upkeepBatchSize, uint256 _upkeepMinimumBlockInterval) public Ownable() {
        prizePoolRegistry = _prizePoolRegistry;
        emit UpkeepPrizePoolRegistryUpdated(_prizePoolRegistry);

        upkeepBatchSize = _upkeepBatchSize;
        emit UpkeepBatchSizeUpdated(_upkeepBatchSize);

        upkeepMinimumBlockInterval = _upkeepMinimumBlockInterval;
        emit UpkeepMinimumBlockIntervalUpdated(_upkeepMinimumBlockInterval);
    }


    
    
    
    function checkUpkeep(bytes calldata checkData) external view override returns (bool upkeepNeeded, bytes memory performData) {

        if(block.number < upkeepLastUpkeepBlockNumber + upkeepMinimumBlockInterval){
            return (false, performData);
        }
        
        address[] memory prizePools = prizePoolRegistry.getAddresses();

        // check if canStartAward()
        for(uint256 pool = 0; pool < prizePools.length; pool++){
            address prizeStrategy = PrizePoolInterface(prizePools[pool]).prizeStrategy();
            if(prizeStrategy.canStartAward()){
                return (true, performData);
            } 
        }
        // check if canCompleteAward()
        for(uint256 pool = 0; pool < prizePools.length; pool++){
            address prizeStrategy = PrizePoolInterface(prizePools[pool]).prizeStrategy();
            if(prizeStrategy.canCompleteAward()){
                return (true, performData);
            } 
        }
        return (false, performData);
    }
    
    
    
    function performUpkeep(bytes calldata performData) external override whenNotPaused {

        uint256 _upkeepLastUpkeepBlockNumber = upkeepLastUpkeepBlockNumber; // SLOAD
        require(block.number > _upkeepLastUpkeepBlockNumber + upkeepMinimumBlockInterval, "PrizeStrategyUpkeep::minimum block interval not reached");

        address[] memory prizePools = prizePoolRegistry.getAddresses();

      
        uint256 batchCounter = upkeepBatchSize; //counter for batch

        uint256 poolIndex = 0;
        uint256 startAwardCounter = 0;
        uint256 completeAwardCounter = 0;

        uint256 updatedUpkeepBlockNumber;

        while(batchCounter > 0 && poolIndex < prizePools.length){
            
            address prizeStrategy = PrizePoolInterface(prizePools[poolIndex]).prizeStrategy();
            
            if(prizeStrategy.canStartAward()){
                PeriodicPrizeStrategyInterface(prizeStrategy).startAward();
                startAwardCounter++;
                batchCounter--;
            }
            else if(prizeStrategy.canCompleteAward()){
                PeriodicPrizeStrategyInterface(prizeStrategy).completeAward();       
                completeAwardCounter++;
                batchCounter--;
            }
            poolIndex++;            
        }
        
        if(startAwardCounter > 0 || completeAwardCounter > 0){
            updatedUpkeepBlockNumber = block.number;
        }

        // update if required
        if(_upkeepLastUpkeepBlockNumber != updatedUpkeepBlockNumber){
            upkeepLastUpkeepBlockNumber = updatedUpkeepBlockNumber; //SSTORE
            emit UpkeepPerformed(startAwardCounter, completeAwardCounter);
        }
  
    }


    
    
    function updateUpkeepBatchSize(uint256 _upkeepBatchSize) external onlyOwner {
        upkeepBatchSize = _upkeepBatchSize;
        emit UpkeepBatchSizeUpdated(_upkeepBatchSize);
    }


    
    
    function updatePrizePoolRegistry(AddressRegistry _prizePoolRegistry) external onlyOwner {
        prizePoolRegistry = _prizePoolRegistry;
        emit UpkeepPrizePoolRegistryUpdated(_prizePoolRegistry);
    }


    
    
    function updateUpkeepMinimumBlockInterval(uint256 _upkeepMinimumBlockInterval) external onlyOwner {
        upkeepMinimumBlockInterval = _upkeepMinimumBlockInterval;
        emit UpkeepMinimumBlockIntervalUpdated(_upkeepMinimumBlockInterval);
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

interface PeriodicPrizeStrategyInterface {
  function startAward() external;
  function completeAward() external;
  function canStartAward() external view returns (bool);
  function canCompleteAward() external view returns (bool);
}

// 

pragma solidity ^0.7.6;

interface PrizePoolInterface {
    function prizeStrategy() external view returns (address);
}

// 

pragma solidity ^0.7.6;

interface PrizePoolRegistryInterface {
    function getPrizePools() external view returns(address[] memory);
}

// 

pragma solidity ^0.7.6;






library SafeAwardable{

    
    function canCompleteAward(address self) internal view returns (bool canCompleteAward){
        if(supportsFunction(self, PeriodicPrizeStrategyInterface.canCompleteAward.selector)){
            return PeriodicPrizeStrategyInterface(self).canCompleteAward();      
        }
        return false;
    }

    
    function canStartAward(address self) internal view returns (bool canStartAward){
        if(supportsFunction(self, PeriodicPrizeStrategyInterface.canStartAward.selector)){
            return PeriodicPrizeStrategyInterface(self).canStartAward();
        }
        return false;
    }
    
    
    
    function supportsFunction(address self, bytes4 selector) internal view returns (bool success){
        bytes memory encodedParams = abi.encodeWithSelector(selector);
        (bool success, bytes memory result) = self.staticcall{ gas: 30000 }(encodedParams);
        if (result.length < 32){
            return (false);
        }
        if(!success && result.length > 0){
            revert(string(result));
        }
        return (success);
    }
}
