// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
pragma solidity ^0.8.11;


///         `msg.origin` is not authorized.
error Unauthorized();


///         or entered an illegal condition which is not recoverable from.
error IllegalState();


///         to the function.
error IllegalArgument();

pragma solidity ^0.8.11;







interface IWhitelist {
  
  ///
  
  event AccountAdded(address account);

  
  ///
  
  event AccountRemoved(address account);

  
  event WhitelistDisabled();

  
  ///
  
  function getAddresses() external view returns (address[] memory addresses);

  
  ///
  
  function disabled() external view returns (bool);

  
  ///
  
  function add(address caller) external;

  
  ///
  
  function remove(address caller) external;

  
  ///
  /// This can only occur once. Once the whitelist is disabled, then it cannot be reenabled.
  function disable() external;

  
  ///
  
  ///
  
  function isWhitelisted(address account) external view returns (bool);
}

// 
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;



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
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
pragma solidity ^0.8.11;








contract Whitelist is IWhitelist, Ownable {
  using Sets for Sets.AddressSet;
  Sets.AddressSet addresses;

  
  bool public override disabled;

  constructor() Ownable() {}

  
  function getAddresses() external view returns (address[] memory) {
    return addresses.values;
  }

  
  function add(address caller) external override {
    _onlyAdmin();
    if (disabled) {
      revert IllegalState();
    }
    addresses.add(caller);
    emit AccountAdded(caller);
  }

  
  function remove(address caller) external override {
    _onlyAdmin();
    if (disabled) {
      revert IllegalState();
    }
    addresses.remove(caller);
    emit AccountRemoved(caller);
  }

  
  function disable() external override {
    _onlyAdmin();
    disabled = true;
    emit WhitelistDisabled();
  }

  
  function isWhitelisted(address account) external view override returns (bool) {
    return disabled || addresses.contains(account);
  }

  
  function _onlyAdmin() internal view {
    if (msg.sender != owner()) {
      revert Unauthorized();
    }
  }
}

pragma solidity ^0.8.11;



library Sets {
    using Sets for AddressSet;

    
    struct AddressSet {
        address[] values;
        mapping(address => uint256) indexes;
    }

    
    ///
    
    
    ///
    
    function add(AddressSet storage self, address value) internal returns (bool) {
        if (self.contains(value)) {
            return false;
        }
        self.values.push(value);
        self.indexes[value] = self.values.length;
        return true;
    }

    
    ///
    
    
    ///
    
    function remove(AddressSet storage self, address value) internal returns (bool) {
        uint256 index = self.indexes[value];
        if (index == 0) {
            return false;
        }

        // Normalize the index since we know that the element is in the set.
        index--;

        uint256 lastIndex = self.values.length - 1;

        if (index != lastIndex) {
            address lastValue = self.values[lastIndex];
            self.values[index] = lastValue;
            self.indexes[lastValue] = index + 1;
        }

        self.values.pop();

        delete self.indexes[value];

        return true;
    }

    
    ///
    
    
    ///
    
    function contains(AddressSet storage self, address value) internal view returns (bool) {
        return self.indexes[value] != 0;
    }
}
