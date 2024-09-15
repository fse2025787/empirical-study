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

// 
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;



// 
pragma solidity ^0.8.4;

interface IBondGovernor {
  struct Policy {
    uint256 controlVariable; // [ray]
    uint256 lastControlVariableUpdate; // [unix timestamp]
    uint256 targetControlVariable; // [ray]
    uint256 timeToTargetControlVariable; // [seconds]
    uint256 minimumPrice; // [wad]
  }

  function initializePolicy(
    address asset,
    uint256 controlVariable,
    uint256 minimumPrice
  ) external;

  function adjustPolicy(
    address asset,
    uint256 targetControlVariable,
    uint256 timeToTargetControlVariable,
    uint256 minimumPrice
  ) external;

  function updateControlVariable(address asset) external;

  function setFees(uint256 _fees) external;

  function setMinimumSize(uint256 _minimumSize) external;

  function setMaximumRatio(uint256 _maximumRatio) external;

  function getControlVariable(address asset)
    external
    view
    returns (uint256 controlVariable);

  function maximumBondSize() external view returns (uint256 maxBondSize);

  function getPolicy(address asset)
    external
    view
    returns (
      uint256 currentControlVariable,
      uint256 minPrice,
      uint256 minSize,
      uint256 maxBondSize,
      uint256 fees
    );

  event UpdatedFees(uint256 fees);
  event UpdatedMinimumSize(uint256 fees);
  event UpdatedMaximumRatio(uint256 fees);
  event CreatedPolicy(
    address indexed asset,
    uint256 controlVariable,
    uint256 minPrice
  );
  event UpdatedPolicy(
    address indexed asset,
    uint256 targetControlVariable,
    uint256 minPrice,
    uint256 timeToTargetControlVariable
  );
}
// 
pragma solidity ^0.8.4;









/// a ramping function for bond control variable changes.

contract BondGovernor is Ownable, IBondGovernor {
  uint256 private constant WAD = 10**18;
  uint256 private constant RAY = 10**27;

  
  IERC20 public immutable BLU;

  
  
  uint256 public minimumSize;

  
  
  /// bond prices to be updated
  uint256 public maximumRatio;

  
  uint256 public fees;

  
  mapping(address => Policy) public policies;

  
  modifier policyExist(address asset) {
    require(policies[asset].controlVariable != 0, "Policy not initialized");
    _;
  }

  
  
  
  constructor(address _BLU, uint256 _maximumRatio) {
    BLU = IERC20(_BLU);
    minimumSize = WAD / 1000; // 1 thousandth of the token [wad]
    fees = WAD / 5; // 20% of sale proceeds [wad]
    maximumRatio = _maximumRatio;
  }

  // =============================== PUBLIC FUNCTIONS =================================

  
  
  /// control variable on the ramp.
  function updateControlVariable(address asset) public override {
    uint256 currentControlVariable = getControlVariable(asset);
    uint256 timeElapsed = block.timestamp -
      policies[asset].lastControlVariableUpdate;

    policies[asset].controlVariable = currentControlVariable;
    policies[asset].lastControlVariableUpdate = block.timestamp;
    if (timeElapsed > policies[asset].timeToTargetControlVariable) {
      policies[asset].timeToTargetControlVariable = 0;
    } else {
      unchecked {
        policies[asset].timeToTargetControlVariable -= timeElapsed;
      }
    }
  }

  // =============================== ADMIN FUNCTIONS =================================

  
  
  
  
  function initializePolicy(
    address asset,
    uint256 controlVariable,
    uint256 minimumPrice
  ) public override onlyOwner {
    require(
      policies[asset].controlVariable == 0,
      "Policy has been initialized"
    );
    require(controlVariable >= RAY, "Control variable less than 1");
    policies[asset] = Policy({
      controlVariable: controlVariable,
      lastControlVariableUpdate: block.timestamp,
      targetControlVariable: controlVariable,
      timeToTargetControlVariable: 0,
      minimumPrice: minimumPrice
    });
    emit CreatedPolicy(asset, controlVariable, minimumPrice);
  }

  
  
  /// period specified in `timeToTargetControlVariable` to prevent sudden changes.
  
  
  
  
  function adjustPolicy(
    address asset,
    uint256 targetControlVariable,
    uint256 timeToTargetControlVariable,
    uint256 minimumPrice
  ) public override onlyOwner {
    require(
      targetControlVariable >= RAY,
      "Target control variable less than 1"
    );
    require(timeToTargetControlVariable != 0, "Time cannot be 0");

    updateControlVariable(asset);
    policies[asset].targetControlVariable = targetControlVariable;
    policies[asset].timeToTargetControlVariable = timeToTargetControlVariable;
    policies[asset].minimumPrice = minimumPrice;
    emit UpdatedPolicy(
      asset,
      targetControlVariable,
      minimumPrice,
      timeToTargetControlVariable
    );
  }

  
  
  function setFees(uint256 _fees) public override onlyOwner {
    require(_fees <= WAD, "Fees greater than 100%");
    fees = _fees;
    emit UpdatedFees(fees);
  }

  
  
  function setMinimumSize(uint256 _minimumSize) public override onlyOwner {
    minimumSize = _minimumSize;
    emit UpdatedMinimumSize(minimumSize);
  }

  
  
  function setMaximumRatio(uint256 _maximumRatio) public override onlyOwner {
    require(_maximumRatio <= WAD, "Maximum ratio greater than 100%");
    maximumRatio = _maximumRatio;
    emit UpdatedMaximumRatio(maximumRatio);
  }

  // =============================== VIEW FUNCTIONS =================================

  
  
  
  function getControlVariable(address asset)
    public
    view
    override
    policyExist(asset)
    returns (uint256)
  {
    Policy memory policy = policies[asset];

    // Target control variable is reached
    if (
      policy.lastControlVariableUpdate + policy.timeToTargetControlVariable <=
      block.timestamp
    ) {
      return policy.targetControlVariable;
    }

    // Target control variable is not reached
    unchecked {
      if (policy.controlVariable <= policy.targetControlVariable) {
        return
          policy.controlVariable +
          ((block.timestamp - policy.lastControlVariableUpdate) *
            (policy.targetControlVariable - policy.controlVariable)) /
          policy.timeToTargetControlVariable;
      } else {
        return
          policy.controlVariable -
          ((block.timestamp - policy.lastControlVariableUpdate) *
            (policy.controlVariable - policy.targetControlVariable)) /
          policy.timeToTargetControlVariable;
      }
    }
  }

  
  
  function maximumBondSize()
    public
    view
    override
    returns (uint256 maximumSize)
  {
    maximumSize = (BLU.totalSupply() * maximumRatio) / WAD;
  }

  
  
  
  
  
  
  
  function getPolicy(address asset)
    public
    view
    override
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    return (
      getControlVariable(asset),
      policies[asset].minimumPrice,
      minimumSize,
      maximumBondSize(),
      fees
    );
  }
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}