// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

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

pragma solidity ^0.8.4;


///         `approveAndCall`/`receiveApproval` pattern.
interface IReceiveApproval {
    
    ///         `approveAndCall` call on the token.
    function receiveApproval(
        address from,
        uint256 amount,
        address token,
        bytes calldata extraData
    ) external;
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity 0.8.17;






contract SortitionTree {
  using Branch for uint256;
  using Position for uint256;
  using Leaf for uint256;

  // implicit tree
  // root 8
  // level2 64
  // level3 512
  // level4 4k
  // level5 32k
  // level6 256k
  // level7 2M
  uint256 internal root;

  // A 2-index mapping from layer => (index (0-index) => branch). For example,
  // to access the 6th branch in the 2nd layer (right below the root node; the
  // first branch layer), call branches[2][5]. Mappings are used in place of
  // arrays for efficiency. The root is the first layer, the branches occupy
  // layers 2 through 7, and layer 8 is for the leaves. Following this
  // convention, the first index in `branches` is `2`, and the last index is
  // `7`.
  mapping(uint256 => mapping(uint256 => uint256)) internal branches;

  // A 0-index mapping from index => leaf, acting as an array. For example, to
  // access the 42nd leaf, call leaves[41].
  mapping(uint256 => uint256) internal leaves;

  // the flagged (see setFlag() and unsetFlag() in Position.sol) positions
  // of all operators present in the pool
  mapping(address => uint256) internal flaggedLeafPosition;

  // the leaf after the rightmost occupied leaf of each stack
  uint256 internal rightmostLeaf;

  // the empty leaves in each stack
  // between 0 and the rightmost occupied leaf
  uint256[] internal emptyLeaves;

  // Each operator has an uint32 ID number
  // which is allocated when they first join the pool
  // and remains unchanged even if they leave and rejoin the pool.
  mapping(address => uint32) internal operatorID;

  // The idAddress array records the address corresponding to each ID number.
  // The ID number 0 is initialized with a zero address and is not used.
  address[] internal idAddress;

  constructor() {
    root = 0;
    rightmostLeaf = 0;
    idAddress.push();
  }

  
  /// of 0 means the operator has not been allocated an ID number yet.
  
  
  function getOperatorID(address operator) public view returns (uint32) {
    return operatorID[operator];
  }

  
  /// zero address means the ID number has not been allocated yet.
  
  
  function getIDOperator(uint32 id) public view returns (address) {
    return idAddress.length > id ? idAddress[id] : address(0);
  }

  
  /// numbers. A zero address means the ID number has not been allocated yet.
  /// This function works just like getIDOperator except that it allows to fetch
  /// operator addresses for multiple IDs in one call.
  
  
  function getIDOperators(uint32[] calldata ids)
    public
    view
    returns (address[] memory)
  {
    uint256 idCount = idAddress.length;

    address[] memory operators = new address[](ids.length);
    for (uint256 i = 0; i < ids.length; i++) {
      uint32 id = ids[i];
      operators[i] = idCount > id ? idAddress[id] : address(0);
    }
    return operators;
  }

  
  
  
  function isOperatorRegistered(address operator) public view returns (bool) {
    return getFlaggedLeafPosition(operator) != 0;
  }

  
  
  function operatorsInPool() public view returns (uint256) {
    // Get the number of leaves that might be occupied;
    // if `rightmostLeaf` equals `firstLeaf()` the tree must be empty,
    // otherwise the difference between these numbers
    // gives the number of leaves that may be occupied.
    uint256 nPossiblyUsedLeaves = rightmostLeaf;
    // Get the number of empty leaves
    // not accounted for by the `rightmostLeaf`
    uint256 nEmptyLeaves = emptyLeaves.length;

    return (nPossiblyUsedLeaves - nEmptyLeaves);
  }

  
  
  function totalWeight() public view returns (uint256) {
    return root.sumWeight();
  }

  
  /// Does not check if the operator already has an ID number.
  
  
  function allocateOperatorID(address operator) internal returns (uint256) {
    uint256 id = idAddress.length;

    require(id <= type(uint32).max, "Pool capacity exceeded");

    operatorID[operator] = uint32(id);
    idAddress.push(operator);
    return id;
  }

  
  
  
  function _insertOperator(address operator, uint256 weight) internal {
    require(
      !isOperatorRegistered(operator),
      "Operator is already registered in the pool"
    );

    // Fetch the operator's ID, and if they don't have one, allocate them one.
    uint256 id = getOperatorID(operator);
    if (id == 0) {
      id = allocateOperatorID(operator);
    }

    // Determine which leaf to insert them into
    uint256 position = getEmptyLeafPosition();
    // Record the block the operator was inserted in
    uint256 theLeaf = Leaf.make(operator, block.number, id);

    // Update the leaf, and propagate the weight changes all the way up to the
    // root.
    root = setLeaf(position, theLeaf, weight, root);

    // Without position flags,
    // the position 0x000000 would be treated as empty
    flaggedLeafPosition[operator] = position.setFlag();
  }

  
  
  function _removeOperator(address operator) internal {
    uint256 flaggedPosition = getFlaggedLeafPosition(operator);
    require(flaggedPosition != 0, "Operator is not registered in the pool");
    uint256 unflaggedPosition = flaggedPosition.unsetFlag();

    // Update the leaf, and propagate the weight changes all the way up to the
    // root.
    root = removeLeaf(unflaggedPosition, root);
    removeLeafPositionRecord(operator);
  }

  
  
  
  function updateOperator(address operator, uint256 weight) internal {
    require(
      isOperatorRegistered(operator),
      "Operator is not registered in the pool"
    );

    uint256 flaggedPosition = getFlaggedLeafPosition(operator);
    uint256 unflaggedPosition = flaggedPosition.unsetFlag();
    root = updateLeaf(unflaggedPosition, weight, root);
  }

  
  
  function removeLeafPositionRecord(address operator) internal {
    flaggedLeafPosition[operator] = 0;
  }

  
  
  
  
  function removeLeaf(uint256 position, uint256 _root)
    internal
    returns (uint256)
  {
    uint256 rightmostSubOne = rightmostLeaf - 1;
    bool isRightmost = position == rightmostSubOne;

    // Clears out the data in the leaf node, and then propagates the weight
    // changes all the way up to the root.
    uint256 newRoot = setLeaf(position, 0, 0, _root);

    // Infer if need to fall back on emptyLeaves yet
    if (isRightmost) {
      rightmostLeaf = rightmostSubOne;
    } else {
      emptyLeaves.push(position);
    }
    return newRoot;
  }

  
  
  
  
  
  function updateLeaf(
    uint256 position,
    uint256 weight,
    uint256 _root
  ) internal returns (uint256) {
    if (getLeafWeight(position) != weight) {
      return updateTree(position, weight, _root);
    } else {
      return _root;
    }
  }

  
  /// propagates that change.
  
  
  
  
  
  function setLeaf(
    uint256 position,
    uint256 theLeaf,
    uint256 leafWeight,
    uint256 _root
  ) internal returns (uint256) {
    // set leaf
    leaves[position] = theLeaf;

    return (updateTree(position, leafWeight, _root));
  }

  
  /// eventually returning the updated root.
  
  
  
  
  function updateTree(
    uint256 position,
    uint256 weight,
    uint256 _root
  ) internal returns (uint256) {
    uint256 childSlot;
    uint256 treeNode;
    uint256 newNode;
    uint256 nodeWeight = weight;

    uint256 parent = position;
    // set levels 7 to 2
    for (uint256 level = Constants.LEVELS; level >= 2; level--) {
      childSlot = parent.slot();
      parent = parent.parent();
      treeNode = branches[level][parent];
      newNode = treeNode.setSlot(childSlot, nodeWeight);
      branches[level][parent] = newNode;
      nodeWeight = newNode.sumWeight();
    }

    // set level Root
    childSlot = parent.slot();
    return _root.setSlot(childSlot, nodeWeight);
  }

  
  /// left to right first, ignoring leaf removals, and then fills
  /// most-recent-removals first.
  
  function getEmptyLeafPosition() internal returns (uint256) {
    uint256 rLeaf = rightmostLeaf;
    bool spaceOnRight = (rLeaf + 1) < Constants.POOL_CAPACITY;
    if (spaceOnRight) {
      rightmostLeaf = rLeaf + 1;
      return rLeaf;
    } else {
      uint256 emptyLeafCount = emptyLeaves.length;
      require(emptyLeafCount > 0, "Pool is full");
      uint256 emptyLeaf = emptyLeaves[emptyLeafCount - 1];
      emptyLeaves.pop();
      return emptyLeaf;
    }
  }

  
  
  
  function getFlaggedLeafPosition(address operator)
    internal
    view
    returns (uint256)
  {
    return flaggedLeafPosition[operator];
  }

  
  
  
  function getLeafWeight(uint256 position) internal view returns (uint256) {
    uint256 slot = position.slot();
    uint256 parent = position.parent();

    // A leaf's weight information is stored a 32-bit slot in the branch layer
    // directly above the leaf layer. To access it, we calculate that slot and
    // parent position, and always know the hard-coded layer index.
    uint256 node = branches[Constants.LEVELS][parent];
    return node.getSlot(slot);
  }

  
  
  /// between leaves
  
  function pickWeightedLeaf(uint256 index, uint256 _root)
    internal
    view
    returns (uint256 leafPosition)
  {
    uint256 currentIndex = index;
    uint256 currentNode = _root;
    uint256 currentPosition = 0;
    uint256 currentSlot;

    require(index < currentNode.sumWeight(), "Index exceeds weight");

    // get root slot
    (currentSlot, currentIndex) = currentNode.pickWeightedSlot(currentIndex);

    // get slots from levels 2 to 7
    for (uint256 level = 2; level <= Constants.LEVELS; level++) {
      currentPosition = currentPosition.child(currentSlot);
      currentNode = branches[level][currentPosition];
      (currentSlot, currentIndex) = currentNode.pickWeightedSlot(currentIndex);
    }

    // get leaf position
    leafPosition = currentPosition.child(currentSlot);
  }
}

pragma solidity 0.8.17;



/// present in the pool at payout based on their weight in the pool.
///
/// To facilitate this, we use a global accumulator value
/// to track the total rewards one unit of weight would've earned
/// since the creation of the pool.
///
/// Whenever a reward is paid, the accumulator is increased
/// by the size of the reward divided by the total weight
/// of all eligible operators in the pool.
///
/// Each operator has an individual accumulator value,
/// set to equal the global accumulator when the operator joins the pool.
/// This accumulator reflects the amount of rewards
/// that have already been accounted for with that operator.
///
/// Whenever an operator's weight in the pool changes,
/// we can update the amount of rewards the operator has earned
/// by subtracting the operator's accumulator from the global accumulator.
/// This gives us the amount of rewards one unit of weight has earned
/// since the last time the operator's rewards have been updated.
/// Then we multiply that by the operator's previous (pre-change) weight
/// to determine how much rewards in total the operator has earned,
/// and add this to the operator's earned rewards.
/// Finally, we set the operator's accumulator to the global accumulator value.
contract Rewards {
  struct OperatorRewards {
    // The state of the global accumulator
    // when the operator's rewards were last updated
    uint96 accumulated;
    // The amount of rewards collected by the operator after the latest update.
    // The amount the operator could withdraw may equal `available`
    // or it may be greater, if more rewards have been paid in since then.
    // To evaulate the most recent amount including rewards potentially paid
    // since the last update, use `availableRewards` function.
    uint96 available;
    // If nonzero, the operator is ineligible for rewards
    // and may only re-enable rewards after the specified timestamp.
    // XXX: unsigned 32-bit integer unix seconds, will break around 2106
    uint32 ineligibleUntil;
    // Locally cached weight of the operator,
    // used to reduce the cost of setting operators ineligible.
    uint32 weight;
  }

  // The global accumulator of how much rewards
  // a hypothetical operator of weight 1 would have earned
  // since the creation of the pool.
  uint96 internal globalRewardAccumulator;
  // If the amount of reward tokens paid in
  // does not divide cleanly by pool weight,
  // the difference is recorded as rounding dust
  // and added to the next reward.
  uint96 internal rewardRoundingDust;

  // The amount of rewards that would've been earned by ineligible operators
  // had they not been ineligible.
  uint96 public ineligibleEarnedRewards;

  // Ineligibility times are calculated from this offset,
  // set at contract creation.
  uint256 internal immutable ineligibleOffsetStart;

  mapping(uint32 => OperatorRewards) internal operatorRewards;

  constructor() {
    // solhint-disable-next-line not-rely-on-time
    ineligibleOffsetStart = block.timestamp;
  }

  
  function isEligibleForRewards(uint32 operator) internal view returns (bool) {
    return operatorRewards[operator].ineligibleUntil == 0;
  }

  
  function rewardsEligibilityRestorableAt(uint32 operator)
    internal
    view
    returns (uint256)
  {
    uint32 until = operatorRewards[operator].ineligibleUntil;
    require(until != 0, "Operator already eligible");
    return (uint256(until) + ineligibleOffsetStart);
  }

  
  ///         for rewards right away.
  function canRestoreRewardEligibility(uint32 operator)
    internal
    view
    returns (bool)
  {
    // solhint-disable-next-line not-rely-on-time
    return rewardsEligibilityRestorableAt(operator) <= block.timestamp;
  }

  
  function addRewards(uint96 rewardAmount, uint32 currentPoolWeight) internal {
    require(currentPoolWeight > 0, "No recipients in pool");

    uint96 totalAmount = rewardAmount + rewardRoundingDust;
    uint96 perWeightReward = totalAmount / currentPoolWeight;
    uint96 newRoundingDust = totalAmount % currentPoolWeight;

    globalRewardAccumulator += perWeightReward;
    rewardRoundingDust = newRoundingDust;
  }

  
  function updateOperatorRewards(uint32 operator, uint32 newWeight) internal {
    uint96 acc = globalRewardAccumulator;
    OperatorRewards memory o = operatorRewards[operator];
    uint96 accruedRewards = (acc - o.accumulated) * uint96(o.weight);
    if (o.ineligibleUntil == 0) {
      // If operator is not ineligible, update their earned rewards
      o.available += accruedRewards;
    } else {
      // If ineligible, put the rewards into the ineligible pot
      ineligibleEarnedRewards += accruedRewards;
    }
    // In any case, update their accumulator and weight
    o.accumulated = acc;
    o.weight = newWeight;
    operatorRewards[operator] = o;
  }

  
  /// and return the previous withdrawable amount.
  
  /// but should usually be accompanied by an update.
  function withdrawOperatorRewards(uint32 operator)
    internal
    returns (uint96 withdrawable)
  {
    OperatorRewards storage o = operatorRewards[operator];
    withdrawable = o.available;
    o.available = 0;
  }

  
  /// and return the previous amount.
  function withdrawIneligibleRewards() internal returns (uint96 withdrawable) {
    withdrawable = ineligibleEarnedRewards;
    ineligibleEarnedRewards = 0;
  }

  
  /// The operators can restore their eligibility at the given time.
  function setIneligible(uint32[] memory operators, uint256 until) internal {
    OperatorRewards memory o = OperatorRewards(0, 0, 0, 0);
    uint96 globalAcc = globalRewardAccumulator;
    uint96 accrued = 0;
    // Record ineligibility as seconds after contract creation
    uint32 _until = uint32(until - ineligibleOffsetStart);

    for (uint256 i = 0; i < operators.length; i++) {
      uint32 operator = operators[i];
      OperatorRewards storage r = operatorRewards[operator];
      o.available = r.available;
      o.accumulated = r.accumulated;
      o.ineligibleUntil = r.ineligibleUntil;
      o.weight = r.weight;

      if (o.ineligibleUntil != 0) {
        // If operator is already ineligible,
        // don't earn rewards or shorten its ineligibility
        if (o.ineligibleUntil < _until) {
          o.ineligibleUntil = _until;
        }
      } else {
        // The operator becomes ineligible -> earn rewards
        o.ineligibleUntil = _until;
        accrued = (globalAcc - o.accumulated) * uint96(o.weight);
        o.available += accrued;
      }
      o.accumulated = globalAcc;

      r.available = o.available;
      r.accumulated = o.accumulated;
      r.ineligibleUntil = o.ineligibleUntil;
      r.weight = o.weight;
    }
  }

  
  function restoreEligibility(uint32 operator) internal {
    // solhint-disable-next-line not-rely-on-time
    require(canRestoreRewardEligibility(operator), "Operator still ineligible");
    uint96 acc = globalRewardAccumulator;
    OperatorRewards memory o = operatorRewards[operator];
    uint96 accruedRewards = (acc - o.accumulated) * uint96(o.weight);
    ineligibleEarnedRewards += accruedRewards;
    o.accumulated = acc;
    o.ineligibleUntil = 0;
    operatorRewards[operator] = o;
  }

  
  ///         for the given operator.
  function availableRewards(uint32 operator) internal view returns (uint96) {
    uint96 acc = globalRewardAccumulator;
    OperatorRewards memory o = operatorRewards[operator];
    if (o.ineligibleUntil == 0) {
      // If operator is not ineligible, calculate newly accrued rewards and add
      // them to the available ones, calculated during the last update.
      uint96 accruedRewards = (acc - o.accumulated) * uint96(o.weight);
      return o.available + accruedRewards;
    } else {
      // If ineligible, return only the rewards calculated during the last
      // update.
      return o.available;
    }
  }
}

pragma solidity 0.8.17;



/// mile with monitoring, share their logs with the dev team, and allow to more
/// carefully monitor the bootstrapping network. As the network matures, the
/// beta program will be ended.
contract Chaosnet {
  
  /// after the contract deployment and can be ended with a call to
  /// `deactivateChaosnet()`. Once deactivated chaosnet can not be activated
  /// again.
  bool public isChaosnetActive;

  
  mapping(address => bool) public isBetaOperator;

  
  address public chaosnetOwner;

  event BetaOperatorsAdded(address[] operators);

  event ChaosnetOwnerRoleTransferred(
    address oldChaosnetOwner,
    address newChaosnetOwner
  );

  event ChaosnetDeactivated();

  constructor() {
    _transferChaosnetOwner(msg.sender);
    isChaosnetActive = true;
  }

  modifier onlyChaosnetOwner() {
    require(msg.sender == chaosnetOwner, "Not the chaosnet owner");
    _;
  }

  modifier onlyOnChaosnet() {
    require(isChaosnetActive, "Chaosnet is not active");
    _;
  }

  
  /// chaosnet owner when the chaosnet is active. Once the operator is added
  /// as a beta operator, it can not be removed.
  function addBetaOperators(address[] calldata operators)
    public
    onlyOnChaosnet
    onlyChaosnetOwner
  {
    for (uint256 i = 0; i < operators.length; i++) {
      isBetaOperator[operators[i]] = true;
    }

    emit BetaOperatorsAdded(operators);
  }

  
  /// owner. Once deactivated chaosnet can not be activated again.
  function deactivateChaosnet() public onlyOnChaosnet onlyChaosnetOwner {
    isChaosnetActive = false;
    emit ChaosnetDeactivated();
  }

  
  function transferChaosnetOwnerRole(address newChaosnetOwner)
    public
    onlyChaosnetOwner
  {
    require(
      newChaosnetOwner != address(0),
      "New chaosnet owner must not be zero address"
    );
    _transferChaosnetOwner(newChaosnetOwner);
  }

  function _transferChaosnetOwner(address newChaosnetOwner) internal {
    address oldChaosnetOwner = chaosnetOwner;
    chaosnetOwner = newChaosnetOwner;
    emit ChaosnetOwnerRoleTransferred(oldChaosnetOwner, newChaosnetOwner);
  }
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// 

pragma solidity ^0.8.4;


///         `approveAndCall`/`receiveApproval` pattern.
interface IApproveAndCall {
    
    ///         `IReceiveApproval` interface. Approves spender to withdraw from
    ///         the caller multiple times, up to the `amount`. If this
    ///         function is called again, it overwrites the current allowance
    ///         with `amount`. Reverts if the approval reverted or if
    ///         `receiveApproval` call on the spender reverted.
    function approveAndCall(
        address spender,
        uint256 amount,
        bytes memory extraData
    ) external returns (bool);
}
// 
//
// ▓▓▌ ▓▓ ▐▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
// ▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//   ▓▓▓▓▓▓    ▓▓▓▓▓▓▓▀    ▐▓▓▓▓▓▓    ▐▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
//   ▓▓▓▓▓▓▄▄▓▓▓▓▓▓▓▀      ▐▓▓▓▓▓▓▄▄▄▄         ▓▓▓▓▓▓▄▄▄▄         ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
//   ▓▓▓▓▓▓▓▓▓▓▓▓▓▀        ▐▓▓▓▓▓▓▓▓▓▓         ▓▓▓▓▓▓▓▓▓▓         ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//   ▓▓▓▓▓▓▀▀▓▓▓▓▓▓▄       ▐▓▓▓▓▓▓▀▀▀▀         ▓▓▓▓▓▓▀▀▀▀         ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀
//   ▓▓▓▓▓▓   ▀▓▓▓▓▓▓▄     ▐▓▓▓▓▓▓     ▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌
// ▓▓▓▓▓▓▓▓▓▓ █▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓
// ▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓
//
//

// Initial version copied from Keep Network ECDSA Wallets:
// https://github.com/keep-network/keep-core/blob/5286ebc8ff99b2aa6569f9dd97fd6995f25b4630/solidity/ecdsa/contracts/libraries/EcdsaAuthorization.sol
//
// With the following differences:
// - functions' visibility was changed to public/external to deploy it as a linked
//   library.
// - documentation was updated to be more generic.

pragma solidity 0.8.17;





///         contract and the presence of operators in the sortition
///         pool based on the stake authorized for them.
library BeaconAuthorization {
    struct Parameters {
        // The minimum authorization required by the beacon so that
        // operator can join the sortition pool and do the work.
        uint96 minimumAuthorization;
        // Authorization decrease delay in seconds between the time
        // authorization decrease is requested and the time the authorization
        // decrease can be approved. It is always the same value, no matter if
        // authorization decrease amount is small, significant, or if it is
        // a decrease to zero.
        uint64 authorizationDecreaseDelay;
        // The time period before the authorization decrease delay end,
        // during which the authorization decrease request can be overwritten.
        //
        // When the request is overwritten, the authorization decrease delay is
        // reset.
        //
        // For example, if `authorizationDecraseChangePeriod` is set to 4
        // days, `authorizationDecreaseDelay` is set to 14 days, and someone
        // requested authorization decrease, it means they can not
        // request another decrease for the first 10 days. After 10 days pass,
        // they can request again and overwrite the previous authorization
        // decrease request. The delay time will reset for them and they
        // will have to wait another 10 days to alter it and 14 days to
        // approve it.
        //
        // This value protects against malicious operators who manipulate
        // their weight by overwriting authorization decrease request, and
        // lowering or increasing their eligible stake this way.
        //
        // If set to a value equal to `authorizationDecreaseDelay, it means
        // that authorization decrease request can be always overwritten.
        // If set to zero, it means authorization decrease request can not be
        // overwritten until the delay end, and one needs to wait for the entire
        // authorization decrease delay to approve their decrease and request
        // for another one or to overwrite the pending one.
        //
        //   (1) authorization decrease requested timestamp
        //   (2) from this moment authorization decrease request can be
        //       overwritten
        //   (3) from this moment authorization decrease request can be
        //       approved, assuming it was NOT overwritten in (2)
        //
        //  (1)                            (2)                        (3)
        // --x------------------------------x--------------------------x---->
        //   |                               \________________________/
        //   |                             authorizationDecreaseChangePeriod
        //    \______________________________________________________/
        //                   authorizationDecreaseDelay
        //
        uint64 authorizationDecreaseChangePeriod;
    }

    struct AuthorizationDecrease {
        uint96 decreasingBy; // amount
        uint64 decreasingAt; // timestamp
    }

    struct Data {
        Parameters parameters;
        mapping(address => address) stakingProviderToOperator;
        mapping(address => address) operatorToStakingProvider;
        mapping(address => AuthorizationDecrease) pendingDecreases;
    }

    event OperatorRegistered(
        address indexed stakingProvider,
        address indexed operator
    );

    event AuthorizationIncreased(
        address indexed stakingProvider,
        address indexed operator,
        uint96 fromAmount,
        uint96 toAmount
    );

    event AuthorizationDecreaseRequested(
        address indexed stakingProvider,
        address indexed operator,
        uint96 fromAmount,
        uint96 toAmount,
        uint64 decreasingAt
    );

    event AuthorizationDecreaseApproved(address indexed stakingProvider);

    event InvoluntaryAuthorizationDecreaseFailed(
        address indexed stakingProvider,
        address indexed operator,
        uint96 fromAmount,
        uint96 toAmount
    );

    event OperatorJoinedSortitionPool(
        address indexed stakingProvider,
        address indexed operator
    );

    event OperatorStatusUpdated(
        address indexed stakingProvider,
        address indexed operator
    );

    
    
    ///        the beacon. Without at least the minimum authorization, staking
    ///        provider is not eligible to join and operate in the network.
    
    ///        decrease delay. It is the time in seconds that needs to pass
    ///        between the time authorization decrease is requested and the time
    ///        the authorization decrease can be approved, no matter the
    ///        authorization decrease amount.
    
    ///        decrease change period. It is the time in seconds, before
    ///        authorization decrease delay end, during which the pending
    ///        authorization decrease request can be overwritten.
    ///        If set to 0, pending authorization decrease request can not be
    ///        overwritten until the entire `authorizationDecreaseDelay` ends.
    ///        If set to value equal `authorizationDecreaseDelay`, request can
    ///        always be overwritten.
    function setParameters(
        Data storage self,
        uint96 _minimumAuthorization,
        uint64 _authorizationDecreaseDelay,
        uint64 _authorizationDecreaseChangePeriod
    ) external {
        self.parameters.minimumAuthorization = _minimumAuthorization;
        self
            .parameters
            .authorizationDecreaseDelay = _authorizationDecreaseDelay;
        self
            .parameters
            .authorizationDecreaseChangePeriod = _authorizationDecreaseChangePeriod;
    }

    
    ///         operate a node. The given staking provider can set operator
    ///         address only one time. The operator address can not be changed
    ///         and must be unique. Reverts if the operator is already set for
    ///         the staking provider or if the operator address is already in
    ///         use. Reverts if there is a pending authorization decrease for
    ///         the staking provider.
    function registerOperator(Data storage self, address operator) public {
        address stakingProvider = msg.sender;

        require(operator != address(0), "Operator can not be zero address");
        require(
            self.stakingProviderToOperator[stakingProvider] == address(0),
            "Operator already set for the staking provider"
        );
        require(
            self.operatorToStakingProvider[operator] == address(0),
            "Operator address already in use"
        );

        // Authorization request for a staking provider who has not yet
        // registered their operator can be approved immediately.
        // We need to make sure that the approval happens before operator
        // is registered to do not let the operator join the sortition pool
        // with an unresolved authorization decrease request that can be
        // approved at any point.
        AuthorizationDecrease storage decrease = self.pendingDecreases[
            stakingProvider
        ];
        require(
            decrease.decreasingAt == 0,
            "There is a pending authorization decrease request"
        );

        emit OperatorRegistered(stakingProvider, operator);

        self.stakingProviderToOperator[stakingProvider] = operator;
        self.operatorToStakingProvider[operator] = stakingProvider;
    }

    
    ///         authorized stake amount for the given staking provider increased.
    ///
    ///         Reverts if the authorization amount is below the minimum.
    ///
    ///         The function is not updating the sortition pool. Sortition pool
    ///         state needs to be updated by the operator with a call to
    ///         `joinSortitionPool` or `updateOperatorStatus`.
    ///
    
    function authorizationIncreased(
        Data storage self,
        address stakingProvider,
        uint96 fromAmount,
        uint96 toAmount
    ) external {
        require(
            toAmount >= self.parameters.minimumAuthorization,
            "Authorization below the minimum"
        );

        // Note that this function does not require the operator address to be
        // set for the given staking provider. This allows the stake owner
        // who is also an authorizer to increase the authorization before the
        // staking provider sets the operator. This allows delegating stake
        // and increasing authorization immediately one after another without
        // having to wait for the staking provider to do their part.

        address operator = self.stakingProviderToOperator[stakingProvider];
        emit AuthorizationIncreased(
            stakingProvider,
            operator,
            fromAmount,
            toAmount
        );
    }

    
    ///         authorization decrease for the given staking provider has been
    ///         requested.
    ///
    ///         Reverts if the amount after deauthorization would be non-zero
    ///         and lower than the minimum authorization.
    ///
    ///         Reverts if another authorization decrease request is pending for
    ///         the staking provider and not enough time passed since the
    ///         original request (see `authorizationDecreaseChangePeriod`).
    ///
    ///         If the operator is not known (`registerOperator` was not called)
    ///         it lets to `approveAuthorizationDecrease` immediately. If the
    ///         operator is known (`registerOperator` was called), the operator
    ///         needs to update state of the sortition pool with a call to
    ///         `joinSortitionPool` or `updateOperatorStatus`. After the
    ///         sortition pool state is in sync, authorization decrease delay
    ///         starts.
    ///
    ///         After authorization decrease delay passes, authorization
    ///         decrease request needs to be approved with a call to
    ///         `approveAuthorizationDecrease` function.
    ///
    ///         If there is a pending authorization decrease request, it is
    ///         overwritten, but only if enough time passed since the original
    ///         request. Otherwise, the function reverts.
    ///
    
    function authorizationDecreaseRequested(
        Data storage self,
        address stakingProvider,
        uint96 fromAmount,
        uint96 toAmount
    ) public {
        require(
            toAmount == 0 || toAmount >= self.parameters.minimumAuthorization,
            "Authorization amount should be 0 or above the minimum"
        );

        address operator = self.stakingProviderToOperator[stakingProvider];

        uint64 decreasingAt;

        if (operator == address(0)) {
            // Operator is not known. It means `registerOperator` was not
            // called yet, and there is no chance the operator could
            // call `joinSortitionPool`. We can let to approve authorization
            // decrease immediately because that operator was never in the
            // sortition pool.

            // solhint-disable-next-line not-rely-on-time
            decreasingAt = uint64(block.timestamp);
        } else {
            // Operator is known. It means that this operator is or was in
            // the sortition pool. Before authorization decrease delay starts,
            // the operator needs to update the state of the sortition pool
            // with a call to `joinSortitionPool` or `updateOperatorStatus`.
            // For now, we set `decreasingAt` as "never decreasing" and let
            // it be updated by `joinSortitionPool` or `updateOperatorStatus`
            // once we know the sortition pool is in sync.
            decreasingAt = type(uint64).max;
        }

        uint96 decreasingBy = fromAmount - toAmount;

        AuthorizationDecrease storage decreaseRequest = self.pendingDecreases[
            stakingProvider
        ];

        uint64 pendingDecreaseAt = decreaseRequest.decreasingAt;
        if (pendingDecreaseAt != 0 && pendingDecreaseAt != type(uint64).max) {
            // If there is already a pending authorization decrease request for
            // this staking provider and that request has been activated
            // (sortition pool was updated), require enough time to pass before
            // it can be overwritten.
            require(
                // solhint-disable-next-line not-rely-on-time
                block.timestamp >=
                    pendingDecreaseAt -
                        self.parameters.authorizationDecreaseChangePeriod,
                "Not enough time passed since the original request"
            );
        }

        decreaseRequest.decreasingBy = decreasingBy;
        decreaseRequest.decreasingAt = decreasingAt;

        emit AuthorizationDecreaseRequested(
            stakingProvider,
            operator,
            fromAmount,
            toAmount,
            decreasingAt
        );
    }

    
    ///         request. Reverts if authorization decrease delay have not passed
    ///         yet or if the authorization decrease was not requested for the
    ///         given staking provider.
    function approveAuthorizationDecrease(
        Data storage self,
        IStaking tokenStaking,
        address stakingProvider
    ) public {
        AuthorizationDecrease storage decrease = self.pendingDecreases[
            stakingProvider
        ];
        require(
            decrease.decreasingAt > 0,
            "Authorization decrease not requested"
        );
        require(
            decrease.decreasingAt != type(uint64).max,
            "Authorization decrease request not activated"
        );
        require(
            // solhint-disable-next-line not-rely-on-time
            block.timestamp >= decrease.decreasingAt,
            "Authorization decrease delay not passed"
        );

        emit AuthorizationDecreaseApproved(stakingProvider);

        // slither-disable-next-line unused-return
        tokenStaking.approveAuthorizationDecrease(stakingProvider);
        delete self.pendingDecreases[stakingProvider];
    }

    
    ///         authorization has been decreased for the given staking provider
    ///         involuntarily, as a result of slashing.
    ///
    ///         If the operator is not known (`registerOperator` was not called)
    ///         the function does nothing. The operator was never in a sortition
    ///         pool so there is nothing to update.
    ///
    ///         If the operator is known, sortition pool is unlocked, and the
    ///         operator is in the sortition pool, the sortition pool state is
    ///         updated. If the sortition pool is locked, update needs to be
    ///         postponed. Every other staker is incentivized to call
    ///         `updateOperatorStatus` for the problematic operator to increase
    ///         their own rewards in the pool.
    ///
    
    function involuntaryAuthorizationDecrease(
        Data storage self,
        IStaking tokenStaking,
        SortitionPool sortitionPool,
        address stakingProvider,
        uint96 fromAmount,
        uint96 toAmount
    ) external {
        address operator = self.stakingProviderToOperator[stakingProvider];

        if (operator == address(0)) {
            // Operator is not known. It means `registerOperator` was not
            // called yet, and there is no chance the operator could
            // call `joinSortitionPool`. We can just ignore this update because
            // operator was never in the sortition pool.
            return;
        } else {
            // Operator is known. It means that this operator is or was in the
            // sortition pool and the sortition pool may need to be updated.
            //
            // If the sortition pool is not locked and the operator is in the
            // sortition pool, we are updating it.
            //
            // To keep stakes synchronized between applications when staking
            // providers are slashed, without the risk of running out of gas,
            // the staking contract queues up slashings and let users process
            // the transactions. When an application slashes one or more staking
            // providers, it adds them to the slashing queue on the staking
            // contract. A queue entry contains the staking provider’s address
            // and the amount they are due to be slashed.
            //
            // When there is at least one staking provider in the slashing
            // queue, any account can submit a transaction processing one or
            // more staking providers' slashings, and collecting a reward for
            // doing so. A queued slashing is processed by updating the staking
            // provider’s stake to the post-slashing amount, updating authorized
            // amount for each affected application, and notifying all affected
            // applications that the staking provider’s authorized stake has
            // been reduced due to slashing.
            //
            // The entire idea is that the process transaction is expensive
            // because each application needs to be updated, so the reward for
            // the processor is hefty and comes from the slashed tokens.
            // Practically, it means that if the sortition pool is unlocked, and
            // can be updated, it should be updated because we already paid
            // someone for updating it.
            //
            // If the sortition pool is locked, update needs to wait. Other
            // sortition pool members are incentivized to call
            // `updateOperatorStatus` for the problematic operator because they
            // will increase their rewards this way.
            if (sortitionPool.isOperatorInPool(operator)) {
                if (sortitionPool.isLocked()) {
                    emit InvoluntaryAuthorizationDecreaseFailed(
                        stakingProvider,
                        operator,
                        fromAmount,
                        toAmount
                    );
                } else {
                    updateOperatorStatus(
                        self,
                        tokenStaking,
                        sortitionPool,
                        operator
                    );
                }
            }
        }
    }

    
    ///         must be known - before calling this function, it has to be
    ///         appointed by the staking provider by calling `registerOperator`.
    ///         Also, the operator must have the minimum authorization required
    ///         by the beacon. Function reverts if there is no minimum stake
    ///         authorized or if the operator is not known. If there was an
    ///         authorization decrease requested, it is activated by starting
    ///         the authorization decrease delay.
    function joinSortitionPool(
        Data storage self,
        IStaking tokenStaking,
        SortitionPool sortitionPool
    ) public {
        address operator = msg.sender;

        address stakingProvider = self.operatorToStakingProvider[operator];
        require(stakingProvider != address(0), "Unknown operator");

        AuthorizationDecrease storage decrease = self.pendingDecreases[
            stakingProvider
        ];

        uint96 _eligibleStake = eligibleStake(
            self,
            tokenStaking,
            stakingProvider,
            decrease.decreasingBy
        );

        require(_eligibleStake != 0, "Authorization below the minimum");

        emit OperatorJoinedSortitionPool(stakingProvider, operator);

        sortitionPool.insertOperator(operator, _eligibleStake);

        // If there is a pending authorization decrease request, activate it.
        // At this point, the sortition pool state is up to date so the
        // authorization decrease delay can start counting.
        if (decrease.decreasingAt == type(uint64).max) {
            decrease.decreasingAt =
                // solhint-disable-next-line not-rely-on-time
                uint64(block.timestamp) +
                self.parameters.authorizationDecreaseDelay;
        }
    }

    
    ///         was an authorization decrease requested, it is activated by
    ///         starting the authorization decrease delay.
    ///         Function reverts if the operator is not known.
    function updateOperatorStatus(
        Data storage self,
        IStaking tokenStaking,
        SortitionPool sortitionPool,
        address operator
    ) public {
        address stakingProvider = self.operatorToStakingProvider[operator];
        require(stakingProvider != address(0), "Unknown operator");

        AuthorizationDecrease storage decrease = self.pendingDecreases[
            stakingProvider
        ];

        emit OperatorStatusUpdated(stakingProvider, operator);

        if (sortitionPool.isOperatorInPool(operator)) {
            uint96 _eligibleStake = eligibleStake(
                self,
                tokenStaking,
                stakingProvider,
                decrease.decreasingBy
            );

            sortitionPool.updateOperatorStatus(operator, _eligibleStake);
        }

        // If there is a pending authorization decrease request, activate it.
        // At this point, the sortition pool state is up to date so the
        // authorization decrease delay can start counting.
        if (decrease.decreasingAt == type(uint64).max) {
            decrease.decreasingAt =
                // solhint-disable-next-line not-rely-on-time
                uint64(block.timestamp) +
                self.parameters.authorizationDecreaseDelay;
        }
    }

    
    ///         operator's weight in the sortition pool.
    ///         If the operator is not in the sortition pool and their
    ///         authorized stake is non-zero, function returns false.
    function isOperatorUpToDate(
        Data storage self,
        IStaking tokenStaking,
        SortitionPool sortitionPool,
        address operator
    ) external view returns (bool) {
        address stakingProvider = self.operatorToStakingProvider[operator];
        require(stakingProvider != address(0), "Unknown operator");

        AuthorizationDecrease storage decrease = self.pendingDecreases[
            stakingProvider
        ];

        uint96 _eligibleStake = eligibleStake(
            self,
            tokenStaking,
            stakingProvider,
            decrease.decreasingBy
        );

        if (!sortitionPool.isOperatorInPool(operator)) {
            return _eligibleStake == 0;
        } else {
            return sortitionPool.isOperatorUpToDate(operator, _eligibleStake);
        }
    }

    
    ///         stake. Eligible stake is defined as the currently authorized
    ///         stake minus the pending authorization decrease. Eligible stake
    ///         is what is used for operator's weight in the pool. If the
    ///         authorized stake minus the pending authorization decrease is
    ///         below the minimum authorization, eligible stake is 0.
    
    ///      second variant accepting `decreasingBy` as a parameter.
    function eligibleStake(
        Data storage self,
        IStaking tokenStaking,
        address stakingProvider
    ) external view returns (uint96) {
        return
            eligibleStake(
                self,
                tokenStaking,
                stakingProvider,
                pendingAuthorizationDecrease(self, stakingProvider)
            );
    }

    
    ///         stake. Eligible stake is defined as the currently authorized
    ///         stake minus the pending authorization decrease. Eligible stake
    ///         is what is used for operator's weight in the pool. If the
    ///         authorized stake minus the pending authorization decrease is
    ///         below the minimum authorization, eligible stake is 0.
    
    ///      `decreasingBy` must be fetched from `pendingDecreases` mapping and
    ///      it is passed as a parameter to optimize gas usage of functions that
    ///      call `eligibleStake` and need to use `AuthorizationDecrease`
    ///      fetched from `pendingDecreases` for some additional logic.
    function eligibleStake(
        Data storage self,
        IStaking tokenStaking,
        address stakingProvider,
        uint96 decreasingBy
    ) public view returns (uint96) {
        uint96 authorizedStake = tokenStaking.authorizedStake(
            stakingProvider,
            address(this)
        );

        uint96 _eligibleStake = authorizedStake > decreasingBy
            ? authorizedStake - decreasingBy
            : 0;

        if (_eligibleStake < self.parameters.minimumAuthorization) {
            return 0;
        } else {
            return _eligibleStake;
        }
    }

    
    ///         decrease for the given staking provider. If no authorization
    ///         decrease has been requested, returns zero.
    function pendingAuthorizationDecrease(
        Data storage self,
        address stakingProvider
    ) public view returns (uint96) {
        AuthorizationDecrease storage decrease = self.pendingDecreases[
            stakingProvider
        ];

        return decrease.decreasingBy;
    }

    
    ///         the requested authorization decrease can be approved.
    ///         If the sortition pool state was not updated yet by the operator
    ///         after requesting the authorization decrease, returns
    ///         `type(uint64).max`.
    function remainingAuthorizationDecreaseDelay(
        Data storage self,
        address stakingProvider
    ) external view returns (uint64) {
        AuthorizationDecrease storage decrease = self.pendingDecreases[
            stakingProvider
        ];

        if (decrease.decreasingAt == type(uint64).max) {
            return type(uint64).max;
        }

        // solhint-disable-next-line not-rely-on-time
        uint64 _now = uint64(block.timestamp);
        return _now > decrease.decreasingAt ? 0 : decrease.decreasingAt - _now;
    }
}

pragma solidity 0.8.17;













/// operators weighted by their stakes. It allows to select a group of operators
/// based on the provided pseudo-random seed.
contract SortitionPool is
  SortitionTree,
  Rewards,
  Ownable,
  Chaosnet,
  IReceiveApproval
{
  using Branch for uint256;
  using Leaf for uint256;
  using Position for uint256;

  IERC20WithPermit public immutable rewardToken;

  uint256 public immutable poolWeightDivisor;

  bool public isLocked;

  event IneligibleForRewards(uint32[] ids, uint256 until);

  event RewardEligibilityRestored(address indexed operator, uint32 indexed id);

  
  modifier onlyUnlocked() {
    require(!isLocked, "Sortition pool locked");
    _;
  }

  
  modifier onlyLocked() {
    require(isLocked, "Sortition pool unlocked");
    _;
  }

  constructor(IERC20WithPermit _rewardToken, uint256 _poolWeightDivisor) {
    rewardToken = _rewardToken;
    poolWeightDivisor = _poolWeightDivisor;
  }

  function receiveApproval(
    address sender,
    uint256 amount,
    address token,
    bytes calldata
  ) external override {
    require(token == address(rewardToken), "Unsupported token");
    rewardToken.transferFrom(sender, address(this), amount);
    Rewards.addRewards(uint96(amount), uint32(root.sumWeight()));
  }

  
  ///         given beneficiary.
  
  ///      beneficiary is associated with the provided operator - this needs to
  ///      be done by the owner calling this function.
  
  function withdrawRewards(address operator, address beneficiary)
    public
    onlyOwner
    returns (uint96)
  {
    uint32 id = getOperatorID(operator);
    Rewards.updateOperatorRewards(id, uint32(getPoolWeight(operator)));
    uint96 earned = Rewards.withdrawOperatorRewards(id);
    rewardToken.transfer(beneficiary, uint256(earned));
    return earned;
  }

  
  ///         to the given recipient address.
  
  function withdrawIneligible(address recipient) public onlyOwner {
    uint96 earned = Rewards.withdrawIneligibleRewards();
    rewardToken.transfer(recipient, uint256(earned));
  }

  
  ///         inserted and removed from the pool. Members statuses cannot
  ///         be updated as well.
  
  function lock() public onlyOwner {
    isLocked = true;
  }

  
  ///         the `lock` method.
  
  function unlock() public onlyOwner {
    isLocked = false;
  }

  
  /// already present. Reverts if the operator is not eligible because of their
  /// authorized stake. Reverts if the chaosnet is active and the operator is
  /// not a beta operator.
  
  
  
  function insertOperator(address operator, uint256 authorizedStake)
    public
    onlyOwner
    onlyUnlocked
  {
    uint256 weight = getWeight(authorizedStake);
    require(weight > 0, "Operator not eligible");

    if (isChaosnetActive) {
      require(isBetaOperator[operator], "Not beta operator for chaosnet");
    }

    _insertOperator(operator, weight);
    uint32 id = getOperatorID(operator);
    Rewards.updateOperatorRewards(id, uint32(weight));
  }

  
  /// or remove from the pool if present and ineligible.
  
  
  
  function updateOperatorStatus(address operator, uint256 authorizedStake)
    public
    onlyOwner
    onlyUnlocked
  {
    uint256 weight = getWeight(authorizedStake);

    uint32 id = getOperatorID(operator);
    Rewards.updateOperatorRewards(id, uint32(weight));

    if (weight == 0) {
      _removeOperator(operator);
    } else {
      updateOperator(operator, weight);
    }
  }

  
  ///         The operators can restore their eligibility at the given time.
  function setRewardIneligibility(uint32[] calldata operators, uint256 until)
    public
    onlyOwner
  {
    Rewards.setIneligible(operators, until);
    emit IneligibleForRewards(operators, until);
  }

  
  function restoreRewardEligibility(address operator) public {
    uint32 id = getOperatorID(operator);
    Rewards.restoreEligibility(id);
    emit RewardEligibilityRestored(operator, id);
  }

  
  function isEligibleForRewards(address operator) public view returns (bool) {
    uint32 id = getOperatorID(operator);
    return Rewards.isEligibleForRewards(id);
  }

  
  function rewardsEligibilityRestorableAt(address operator)
    public
    view
    returns (uint256)
  {
    uint32 id = getOperatorID(operator);
    return Rewards.rewardsEligibilityRestorableAt(id);
  }

  
  ///         for rewards right away.
  function canRestoreRewardEligibility(address operator)
    public
    view
    returns (bool)
  {
    uint32 id = getOperatorID(operator);
    return Rewards.canRestoreRewardEligibility(id);
  }

  
  function getAvailableRewards(address operator) public view returns (uint96) {
    uint32 id = getOperatorID(operator);
    return availableRewards(id);
  }

  
  function isOperatorInPool(address operator) public view returns (bool) {
    return getFlaggedLeafPosition(operator) != 0;
  }

  
  /// matches their eligible weight.
  function isOperatorUpToDate(address operator, uint256 authorizedStake)
    public
    view
    returns (bool)
  {
    return getWeight(authorizedStake) == getPoolWeight(operator);
  }

  
  /// which may or may not be out of date.
  function getPoolWeight(address operator) public view returns (uint256) {
    uint256 flaggedPosition = getFlaggedLeafPosition(operator);
    if (flaggedPosition == 0) {
      return 0;
    } else {
      uint256 leafPosition = flaggedPosition.unsetFlag();
      uint256 leafWeight = getLeafWeight(leafPosition);
      return leafWeight;
    }
  }

  
  /// the provided pseudo-random seed. At least one operator has to be
  /// registered in the pool, otherwise the function fails reverting the
  /// transaction.
  
  
  
  function selectGroup(uint256 groupSize, bytes32 seed)
    public
    view
    onlyLocked
    returns (uint32[] memory)
  {
    uint256 _root = root;

    bytes32 rngState = seed;
    uint256 rngRange = _root.sumWeight();
    require(rngRange > 0, "Not enough operators in pool");
    uint256 currentIndex;

    uint256 bits = RNG.bitsRequired(rngRange);

    uint32[] memory selected = new uint32[](groupSize);

    for (uint256 i = 0; i < groupSize; i++) {
      (currentIndex, rngState) = RNG.getIndex(rngRange, rngState, bits);

      uint256 leafPosition = pickWeightedLeaf(currentIndex, _root);

      uint256 leaf = leaves[leafPosition];
      selected[i] = leaf.id();
    }
    return selected;
  }

  function getWeight(uint256 authorization) internal view returns (uint256) {
    return authorization / poolWeightDivisor;
  }
}

// 

// ██████████████     ▐████▌     ██████████████
// ██████████████     ▐████▌     ██████████████
//               ▐████▌    ▐████▌
//               ▐████▌    ▐████▌
// ██████████████     ▐████▌     ██████████████
// ██████████████     ▐████▌     ██████████████
//               ▐████▌    ▐████▌
//               ▐████▌    ▐████▌
//               ▐████▌    ▐████▌
//               ▐████▌    ▐████▌
//               ▐████▌    ▐████▌
//               ▐████▌    ▐████▌

pragma solidity ^0.8.9;



///         and their stake managed by staking providers on their behalf.
///         The staking contract does not define operator role. The operator
///         responsible for running off-chain client software is appointed by
///         the staking provider in the particular application utilizing the
///         staking contract. All off-chain client software should be able
///         to run without exposing operator's or staking provider’s private
///         key and should not require any owner’s keys at all. The stake
///         delegation optimizes the network throughput without compromising the
///         security of the owners’ stake.
interface IStaking {
    enum StakeType {
        NU,
        KEEP,
        T
    }

    //
    //
    // Delegating a stake
    //
    //

    
    ///         staking provider, beneficiary, and authorizer. Transfers the
    ///         given amount of T to the staking contract.
    
    ///      transfer to the staking contract.
    function stake(
        address stakingProvider,
        address payable beneficiary,
        address authorizer,
        uint96 amount
    ) external;

    
    ///         staking contract. No tokens are transferred. Caches the active
    ///         stake amount from KEEP staking contract. Can be called by
    ///         anyone.
    
    ///      staking contract operator.
    function stakeKeep(address stakingProvider) external;

    
    ///         staking contract, additionally appointing staking provider,
    ///         beneficiary and authorizer roles. Caches the amount staked in NU
    ///         staking contract. Can be called only by the original delegation
    ///         owner.
    function stakeNu(
        address stakingProvider,
        address payable beneficiary,
        address authorizer
    ) external;

    
    ///         or their staking provider.
    
    ///      staking contract operator.
    function refreshKeepStakeOwner(address stakingProvider) external;

    
    ///         This amount is required to protect against griefing the staking
    ///         contract and individual applications are allowed to require
    ///         higher minimum stakes if necessary.
    function setMinimumStakeAmount(uint96 amount) external;

    //
    //
    // Authorizing an application
    //
    //

    
    ///         before individual stake authorizers are able to authorize it.
    function approveApplication(address application) external;

    
    ///         the given application by the given amount. Can only be called by
    ///         the authorizer for that staking provider.
    
    ///      on the given application to notify the application about
    ///      authorization change. See `IApplication`.
    function increaseAuthorization(
        address stakingProvider,
        address application,
        uint96 amount
    ) external;

    
    ///         provider on the given application by the provided amount.
    ///         It may not change the authorized amount immediatelly. When
    ///         it happens depends on the application. Can only be called by the
    ///         given staking provider’s authorizer. Overwrites pending
    ///         authorization decrease for the given staking provider and
    ///         application if the application agrees for that. If the
    ///         application does not agree for overwriting, the function
    ///         reverts.
    
    ///      on the given application. See `IApplication`.
    function requestAuthorizationDecrease(
        address stakingProvider,
        address application,
        uint96 amount
    ) external;

    
    ///         provider on all applications by all authorized amount.
    ///         It may not change the authorized amount immediatelly. When
    ///         it happens depends on the application. Can only be called by the
    ///         given staking provider’s authorizer. Overwrites pending
    ///         authorization decrease for the given staking provider and
    ///         application.
    
    ///      for each authorized application. See `IApplication`.
    function requestAuthorizationDecrease(address stakingProvider) external;

    
    ///         previously requested authorization decrease request. Can only be
    ///         called by the application that was previously requested to
    ///         decrease the authorization for that staking provider.
    ///         Returns resulting authorized amount for the application.
    function approveAuthorizationDecrease(address stakingProvider)
        external
        returns (uint96);

    
    ///         the given disabled `application`, for all authorized amount.
    ///         Can be called by anyone.
    function forceDecreaseAuthorization(
        address stakingProvider,
        address application
    ) external;

    
    ///         Besides that stakers can't change authorization to the application.
    ///         Can be called only by the Panic Button of the particular
    ///         application. The paused application can not slash stakes until
    ///         it is approved again by the Governance using `approveApplication`
    ///         function. Should be used only in case of an emergency.
    function pauseApplication(address application) external;

    
    ///         slash stakers. Also stakers can't increase authorization to that
    ///         application but can decrease without waiting by calling
    ///         `requestAuthorizationDecrease` at any moment. Can be called only
    ///         by the governance. The disabled application can't be approved
    ///         again. Should be used only in case of an emergency.
    function disableApplication(address application) external;

    
    ///         provided address. Can only be called by the Governance. If the
    ///         Panic Button for the given application should be disabled, the
    ///         role address should be set to 0x0 address.
    function setPanicButton(address application, address panicButton) external;

    
    ///         have authorized. Used to protect against DoSing slashing queue.
    ///         Can only be called by the Governance.
    function setAuthorizationCeiling(uint256 ceiling) external;

    //
    //
    // Stake top-up
    //
    //

    
    
    ///      transfer to the staking contract.
    function topUp(address stakingProvider, uint96 amount) external;

    
    ///         staking contract to T staking contract. Can be called only by
    ///         the owner or the staking provider.
    function topUpKeep(address stakingProvider) external;

    
    ///         staking contract to T staking contract. Can be called only by
    ///         the owner or the staking provider.
    function topUpNu(address stakingProvider) external;

    //
    //
    // Undelegating a stake (unstaking)
    //
    //

    
    ///         withdraws T to the owner. Reverts if there is at least one
    ///         authorization higher than the sum of the legacy stake and
    ///         remaining liquid T stake or if the unstake amount is higher than
    ///         the liquid T stake amount. Can be called only by the delegation
    ///         owner or the staking provider.
    function unstakeT(address stakingProvider, uint96 amount) external;

    
    ///         in T staking contract to 0. Reverts if the amount of liquid T
    ///         staked in T staking contract is lower than the highest
    ///         application authorization. This function allows to unstake from
    ///         KEEP staking contract and still being able to operate in T
    ///         network and earning rewards based on the liquid T staked. Can be
    ///         called only by the delegation owner or the staking provider.
    function unstakeKeep(address stakingProvider) external;

    
    ///         Reverts if there is at least one authorization higher than the
    ///         sum of remaining legacy NU stake and liquid T stake for that
    ///         staking provider or if the untaked amount is higher than the
    ///         cached legacy stake amount. If succeeded, the legacy NU stake
    ///         can be partially or fully undelegated on the legacy staking
    ///         contract. This function allows to unstake from NU staking
    ///         contract and still being able to operate in T network and
    ///         earning rewards based on the liquid T staked. Can be called only
    ///         by the delegation owner or the staking provider.
    function unstakeNu(address stakingProvider, uint96 amount) external;

    
    ///         amount to 0 and withdraws all liquid T from the stake to the
    ///         owner. Reverts if there is at least one non-zero authorization.
    ///         Can be called only by the delegation owner or the staking
    ///         provider.
    function unstakeAll(address stakingProvider) external;

    //
    //
    // Keeping information in sync
    //
    //

    
    ///         and the amount cached in T staking contract. Slashes the staking
    ///         provider in case the amount cached is higher than the actual
    ///         active stake amount in KEEP staking contract. Needs to update
    ///         authorizations of all affected applications and execute an
    ///         involuntary allocation decrease on all affected applications.
    ///         Can be called by anyone, notifier receives a reward.
    function notifyKeepStakeDiscrepancy(address stakingProvider) external;

    
    ///         and the amount cached in T staking contract. Slashes the
    ///         staking provider in case the amount cached is higher than the
    ///         actual active stake amount in NU staking contract. Needs to
    ///         update authorizations of all affected applications and execute
    ///         an involuntary allocation decrease on all affected applications.
    ///         Can be called by anyone, notifier receives a reward.
    function notifyNuStakeDiscrepancy(address stakingProvider) external;

    
    ///         multiplier for reporting it. The penalty is seized from the
    ///         delegated stake, and 5% of the penalty, scaled by the
    ///         multiplier, is given to the notifier. The rest of the tokens are
    ///         burned. Can only be called by the Governance. See `seize` function.
    function setStakeDiscrepancyPenalty(
        uint96 penalty,
        uint256 rewardMultiplier
    ) external;

    
    ///         of one staking provider. Can only be called by the governance.
    function setNotificationReward(uint96 reward) external;

    
    ///         of misbehaviour
    function pushNotificationReward(uint96 reward) external;

    
    ///         Can only be called by the governance.
    function withdrawNotificationReward(address recipient, uint96 amount)
        external;

    
    ///         amount that should be slashed from each one of them. Can only be
    ///         called by application authorized for all staking providers in
    ///         the array.
    function slash(uint96 amount, address[] memory stakingProviders) external;

    
    ///         amount. The notifier will receive reward per each staking
    ///         provider from notifiers treasury. Can only be called by
    ///         application authorized for all staking providers in the array.
    function seize(
        uint96 amount,
        uint256 rewardMultipier,
        address notifier,
        address[] memory stakingProviders
    ) external;

    
    ///         processes them. Receives 5% of the slashed amount.
    ///         Executes `involuntaryAllocationDecrease` function on each
    ///         affected application.
    function processSlashing(uint256 count) external;

    //
    //
    // Auxiliary functions
    //
    //

    
    ///         the application.
    function authorizedStake(address stakingProvider, address application)
        external
        view
        returns (uint96);

    
    ///         staking provider.
    
    function stakes(address stakingProvider)
        external
        view
        returns (
            uint96 tStake,
            uint96 keepInTStake,
            uint96 nuInTStake
        );

    
    
    function getStartStakingTimestamp(address stakingProvider)
        external
        view
        returns (uint256);

    
    function stakedNu(address stakingProvider) external view returns (uint256);

    
    ///         for the specified staking provider address.
    
    
    
    function rolesOf(address stakingProvider)
        external
        view
        returns (
            address owner,
            address payable beneficiary,
            address authorizer
        );

    
    function getApplicationsLength() external view returns (uint256);

    
    function getSlashingQueueLength() external view returns (uint256);

    
    ///         denomination.
    
    ///      worth of KEEP, and 30 T worth of NU all staked, and the maximum
    ///      application authorization is 40 T, then `getMinStaked` for
    ///      that staking provider returns:
    ///          * 0 T if KEEP stake type specified i.e.
    ///            min = 40 T max - (10 T + 30 T worth of NU) = 0 T
    ///          * 10 T if NU stake type specified i.e.
    ///            min = 40 T max - (10 T + 20 T worth of KEEP) = 10 T
    ///          * 0 T if T stake type specified i.e.
    ///            min = 40 T max - (20 T worth of KEEP + 30 T worth of NU) < 0 T
    ///      In other words, the minimum stake amount for the specified
    ///      stake type is the minimum amount of stake of the given type
    ///      needed to satisfy the maximum application authorization given the
    ///      staked amounts of the other stake types for that staking provider.
    function getMinStaked(address stakingProvider, StakeType stakeTypes)
        external
        view
        returns (uint96);

    
    function getAvailableToAuthorize(
        address stakingProvider,
        address application
    ) external view returns (uint96);
}

// 

pragma solidity ^0.8.4;








///         authorize a transfer of their token with a signature conforming
///         EIP712 standard instead of an on-chain transaction from their
///         address. Anyone can submit this signature on the user's behalf by
///         calling the permit function, as specified in EIP2612 standard,
///         paying gas fees, and possibly performing other actions in the same
///         transaction.
interface IERC20WithPermit is IERC20, IERC20Metadata, IApproveAndCall {
    
    ///         Users can authorize a transfer of their tokens with a signature
    ///         conforming EIP712 standard, rather than an on-chain transaction
    ///         from their address. Anyone can submit this signature on the
    ///         user's behalf by calling the permit function, paying gas fees,
    ///         and possibly performing other actions in the same transaction.
    
    ///         permits that effectively never expire.
    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    
    function burn(uint256 amount) external;

    
    ///         from caller's allowance.
    function burnFrom(address account, uint256 amount) external;

    
    ///         a signing domain and token contract as a verifying contract.
    ///         Used to construct EIP2612 signature provided to `permit`
    ///         function.
    /* solhint-disable-next-line func-name-mixedcase */
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    
    ///         provided token owner for a replay protection. Used to construct
    ///         EIP2612 signature provided to `permit` function.
    function nonce(address owner) external view returns (uint256);

    
    ///         signature provided to `permit` function.
    /* solhint-disable-next-line func-name-mixedcase */
    function PERMIT_TYPEHASH() external pure returns (bytes32);
}

pragma solidity 0.8.17;




library RNG {
  
  /// and the new state of the RNG,
  /// using the provided `state` of the RNG.
  ///
  
  ///
  
  /// The initial state needs to be obtained
  /// from a trusted randomness oracle (the random beacon),
  /// or from a chain of earlier calls to `RNG.getIndex()`
  /// on an originally trusted seed.
  ///
  
  /// takes the least significant bits of `state`
  /// and checks if the obtained index is within the desired range.
  /// The original state is hashed with `keccak256` to get a new state.
  /// If the index is outside the range,
  /// the function retries until it gets a suitable index.
  ///
  
  ///
  
  /// When `getIndex()` is called one or more times,
  /// care must be taken to always use the output `state`
  /// of the most recent call as the input `state` of a subsequent call.
  /// At the end of a transaction calling `RNG.getIndex()`,
  /// the previous stored state must be overwritten with the latest output.
  function getIndex(
    uint256 range,
    bytes32 state,
    uint256 bits
  ) internal view returns (uint256, bytes32) {
    bool found = false;
    uint256 index = 0;
    bytes32 newState = state;
    while (!found) {
      index = truncate(bits, uint256(newState));
      newState = keccak256(abi.encodePacked(newState, address(this)));
      if (index < range) {
        found = true;
      }
    }
    return (index, newState);
  }

  
  /// for an index in the range `[0 .. range-1]`.
  ///
  
  ///
  
  /// that can contain the number `range-1`.
  function bitsRequired(uint256 range) internal pure returns (uint256) {
    unchecked {
      if (range == 1) {
        return 0;
      }

      uint256 bits = Constants.WEIGHT_WIDTH - 1;

      // Left shift by `bits`,
      // so we have a 1 in the (bits + 1)th least significant bit
      // and 0 in other bits.
      // If this number is equal or greater than `range`,
      // the range [0, range-1] fits in `bits` bits.
      //
      // Because we loop from high bits to low bits,
      // we find the highest number of bits that doesn't fit the range,
      // and return that number + 1.
      while (1 << bits >= range) {
        bits--;
      }

      return bits + 1;
    }
  }

  
  function truncate(uint256 bits, uint256 input)
    internal
    pure
    returns (uint256)
  {
    unchecked {
      return input & ((1 << bits) - 1);
    }
  }
}

pragma solidity 0.8.17;



library Leaf {
  function make(
    address _operator,
    uint256 _creationBlock,
    uint256 _id
  ) internal pure returns (uint256) {
    assert(_creationBlock <= type(uint64).max);
    assert(_id <= type(uint32).max);
    // Converting a bytesX type into a larger type
    // adds zero bytes on the right.
    uint256 op = uint256(bytes32(bytes20(_operator)));
    // Bitwise AND the id to erase
    // all but the 32 least significant bits
    uint256 uid = _id & Constants.ID_MAX;
    // Erase all but the 64 least significant bits,
    // then shift left by 32 bits to make room for the id
    uint256 cb = (_creationBlock & Constants.BLOCKHEIGHT_MAX) <<
      Constants.ID_WIDTH;
    // Bitwise OR them all together to get
    // [address operator || uint64 creationBlock || uint32 id]
    return (op | cb | uid);
  }

  function operator(uint256 leaf) internal pure returns (address) {
    // Converting a bytesX type into a smaller type
    // truncates it on the right.
    return address(bytes20(bytes32(leaf)));
  }

  
  function creationBlock(uint256 leaf) internal pure returns (uint256) {
    return ((leaf >> Constants.ID_WIDTH) & Constants.BLOCKHEIGHT_MAX);
  }

  function id(uint256 leaf) internal pure returns (uint32) {
    // Id is stored in the 32 least significant bits.
    // Bitwise AND ensures that we only get the contents of those bits.
    return uint32(leaf & Constants.ID_MAX);
  }
}

pragma solidity 0.8.17;

library Constants {
  ////////////////////////////////////////////////////////////////////////////
  // Parameters for configuration

  // How many bits a position uses per level of the tree;
  // each branch of the tree contains 2**SLOT_BITS slots.
  uint256 constant SLOT_BITS = 3;
  uint256 constant LEVELS = 7;
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  // Derived constants, do not touch
  uint256 constant SLOT_COUNT = 2**SLOT_BITS;
  uint256 constant SLOT_WIDTH = 256 / SLOT_COUNT;
  uint256 constant LAST_SLOT = SLOT_COUNT - 1;
  uint256 constant SLOT_MAX = (2**SLOT_WIDTH) - 1;
  uint256 constant POOL_CAPACITY = SLOT_COUNT**LEVELS;

  uint256 constant ID_WIDTH = SLOT_WIDTH;
  uint256 constant ID_MAX = SLOT_MAX;

  uint256 constant BLOCKHEIGHT_WIDTH = 96 - ID_WIDTH;
  uint256 constant BLOCKHEIGHT_MAX = (2**BLOCKHEIGHT_WIDTH) - 1;

  uint256 constant SLOT_POINTER_MAX = (2**SLOT_BITS) - 1;
  uint256 constant LEAF_FLAG = 1 << 255;

  uint256 constant WEIGHT_WIDTH = 256 / SLOT_COUNT;
  ////////////////////////////////////////////////////////////////////////////
}

pragma solidity 0.8.17;




/// rely on packing 8 "slots" of 32-bit values into each uint256.
/// The Branch library permits efficient calculations on these slots.
library Branch {
  
  /// to make the 32 least significant bits of an uint256
  /// be the bits of the `position`th slot
  /// when treating the uint256 as a uint32[8].
  ///
  
  /// but left to illustrate the meaning of a common pattern.
  /// I wish solidity had macros, even C macros.
  function slotShift(uint256 position) internal pure returns (uint256) {
    unchecked {
      return position * Constants.SLOT_WIDTH;
    }
  }

  
  /// treating `node` as a uint32[32].
  function getSlot(uint256 node, uint256 position)
    internal
    pure
    returns (uint256)
  {
    unchecked {
      uint256 shiftBits = position * Constants.SLOT_WIDTH;
      // Doing a bitwise AND with `SLOT_MAX`
      // clears all but the 32 least significant bits.
      // Because of the right shift by `slotShift(position)` bits,
      // those 32 bits contain the 32 bits in the `position`th slot of `node`.
      return (node >> shiftBits) & Constants.SLOT_MAX;
    }
  }

  
  function clearSlot(uint256 node, uint256 position)
    internal
    pure
    returns (uint256)
  {
    unchecked {
      uint256 shiftBits = position * Constants.SLOT_WIDTH;
      // Shifting `SLOT_MAX` left by `slotShift(position)` bits
      // gives us a number where all bits of the `position`th slot are set,
      // and all other bits are unset.
      //
      // Using a bitwise NOT on this number,
      // we get a uint256 where all bits are set
      // except for those of the `position`th slot.
      //
      // Bitwise ANDing the original `node` with this number
      // sets the bits of `position`th slot to zero,
      // leaving all other bits unchanged.
      return node & ~(Constants.SLOT_MAX << shiftBits);
    }
  }

  
  ///
  
  /// Safely truncated to a 32-bit number,
  /// but this should never be called with an overflowing weight regardless.
  function setSlot(
    uint256 node,
    uint256 position,
    uint256 weight
  ) internal pure returns (uint256) {
    unchecked {
      uint256 shiftBits = position * Constants.SLOT_WIDTH;
      // Clear the `position`th slot like in `clearSlot()`.
      uint256 clearedNode = node & ~(Constants.SLOT_MAX << shiftBits);
      // Bitwise AND `weight` with `SLOT_MAX`
      // to clear all but the 32 least significant bits.
      //
      // Shift this left by `slotShift(position)` bits
      // to obtain a uint256 with all bits unset
      // except in the `position`th slot
      // which contains the 32-bit value of `weight`.
      uint256 shiftedWeight = (weight & Constants.SLOT_MAX) << shiftBits;
      // When we bitwise OR these together,
      // all other slots except the `position`th one come from the left argument,
      // and the `position`th gets filled with `weight` from the right argument.
      return clearedNode | shiftedWeight;
    }
  }

  
  function sumWeight(uint256 node) internal pure returns (uint256 sum) {
    unchecked {
      sum = node & Constants.SLOT_MAX;
      // Iterate through each slot
      // by shifting `node` right in increments of 32 bits,
      // and adding the 32 least significant bits to the `sum`.
      uint256 newNode = node >> Constants.SLOT_WIDTH;
      while (newNode > 0) {
        sum += (newNode & Constants.SLOT_MAX);
        newNode = newNode >> Constants.SLOT_WIDTH;
      }
      return sum;
    }
  }

  
  /// Treats the node like an array of virtual stakers,
  /// the number of virtual stakers in each slot corresponding to its weight,
  /// and picks which slot contains the `index`th virtual staker.
  ///
  
  /// However, this is not enforced for performance reasons.
  /// If `index` exceeds the permitted range,
  /// `pickWeightedSlot()` returns the rightmost slot
  /// and an excessively high `newIndex`.
  ///
  
  ///
  
  /// within the returned slot.
  function pickWeightedSlot(uint256 node, uint256 index)
    internal
    pure
    returns (uint256 slot, uint256 newIndex)
  {
    unchecked {
      newIndex = index;
      uint256 newNode = node;
      uint256 currentSlotWeight = newNode & Constants.SLOT_MAX;
      while (newIndex >= currentSlotWeight) {
        newIndex -= currentSlotWeight;
        slot++;
        newNode = newNode >> Constants.SLOT_WIDTH;
        currentSlotWeight = newNode & Constants.SLOT_MAX;
      }
      return (slot, newIndex);
    }
  }
}

pragma solidity 0.8.17;



library Position {
  // Return the last 3 bits of a position number,
  // corresponding to its slot in its parent
  function slot(uint256 a) internal pure returns (uint256) {
    return a & Constants.SLOT_POINTER_MAX;
  }

  // Return the parent of a position number
  function parent(uint256 a) internal pure returns (uint256) {
    return a >> Constants.SLOT_BITS;
  }

  // Return the location of the child of a at the given slot
  function child(uint256 a, uint256 s) internal pure returns (uint256) {
    return (a << Constants.SLOT_BITS) | (s & Constants.SLOT_POINTER_MAX); // slot(s)
  }

  // Return the uint p as a flagged position uint:
  // the least significant 21 bits contain the position
  // and the 22nd bit is set as a flag
  // to distinguish the position 0x000000 from an empty field.
  function setFlag(uint256 p) internal pure returns (uint256) {
    return p | Constants.LEAF_FLAG;
  }

  // Turn a flagged position into an unflagged position
  // by removing the flag at the 22nd least significant bit.
  //
  // We shouldn't _actually_ need this
  // as all position-manipulating code should ignore non-position bits anyway
  // but it's cheap to call so might as well do it.
  function unsetFlag(uint256 p) internal pure returns (uint256) {
    return p & (~Constants.LEAF_FLAG);
  }
}