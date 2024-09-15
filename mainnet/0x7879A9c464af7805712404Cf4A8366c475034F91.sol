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



contract AlchemixGelatoKeeper is Ownable {
  
  error TheGasIsTooDamnHigh();
  
  error Unauthorized();

  
  ///
  
  event SetPoker(address newPoker);

  
  ///
  
  event SetMaxGasPrice(uint256 newMaxGasPrice);

  
  address public gelatoPoker;
  
  uint256 public maxGasPrice;

  constructor(address _gelatoPoker, uint256 _maxGasPrice) Ownable() {
    gelatoPoker = _gelatoPoker;
    maxGasPrice = _maxGasPrice;
  }

  
  ///
  
  function setPoker(address newPoker) external onlyOwner {
    gelatoPoker = newPoker;
    emit SetPoker(gelatoPoker);
  }

  
  ///
  
  function setMaxGasPrice(uint256 newGasPrice) external onlyOwner {
    maxGasPrice = newGasPrice;
    emit SetMaxGasPrice(maxGasPrice);
  }
}

pragma solidity ^0.8.11;

interface IAlchemixHarvester {
  function harvest(
    address alchemist,
    address yieldToken,
    uint256 minimumAmountOut
  ) external;
}
pragma solidity ^0.8.11;







contract AlchemixHarvester is IAlchemixHarvester, AlchemixGelatoKeeper {
  
  address public resolver;

  constructor(
    address _gelatoPoker,
    uint256 _maxGasPrice,
    address _resolver
  ) AlchemixGelatoKeeper(_gelatoPoker, _maxGasPrice) {
    resolver = _resolver;
  }

  function setResolver(address _resolver) external onlyOwner {
    resolver = _resolver;
  }

  
  ///
  
  
  
  function harvest(
    address alchemist,
    address yieldToken,
    uint256 minimumAmountOut
  ) external override {
    if (msg.sender != gelatoPoker) {
      revert Unauthorized();
    }
    if (tx.gasprice > maxGasPrice) {
      revert TheGasIsTooDamnHigh();
    }
    IAlchemistV2(alchemist).harvest(yieldToken, minimumAmountOut);
    IHarvestResolver(resolver).recordHarvest(yieldToken);
  }
}

pragma solidity ^0.8.11;

interface IAlchemistV2 {
    struct YieldTokenParams {
        uint8 decimals;
        address underlyingToken;
        address adapter;
        uint256 maximumLoss;
        uint256 maximumExpectedValue;
        uint256 creditUnlockRate;
        uint256 activeBalance;
        uint256 harvestableBalance;
        uint256 totalShares;
        uint256 expectedValue;
        uint256 pendingCredit;
        uint256 distributedCredit;
        uint256 lastDistributionBlock;
        uint256 accruedWeight;
        bool enabled;
    }

    struct YieldTokenConfig {
        address adapter;
        uint256 maximumLoss;
        uint256 maximumExpectedValue;
        uint256 creditUnlockRate;
    }

    function harvest(address yieldToken, uint256 minimumAmountOut) external;

    function getYieldTokenParameters(address yieldToken)
        external
        view
        returns (YieldTokenParams memory params);
}

pragma solidity ^0.8.11;

interface IHarvestResolver {
    function recordHarvest(address yieldToken) external;
}
