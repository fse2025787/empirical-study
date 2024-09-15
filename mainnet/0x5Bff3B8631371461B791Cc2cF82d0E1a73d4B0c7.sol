// SPDX-License-Identifier: MIT


// 

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 

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
    constructor () {
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

pragma solidity ^0.8.3;



///   * start and end date of the staking period (the earlier you enter, and
///     the longer you stay, the greater your overall reward)
///
///   * At each point, the the current reward is described by a downward curve
///     (https://www.desmos.com/calculator/dz8vk1urep)
///
///   * Computing your total reward (which is done upfront in order to lock and
///     guarantee your reward) means computing the integral of the curve period from
///     your enter date until the end
///     (https://www.wolframalpha.com/input/?i=integrate+%28100-x%29%5E2)
///
///   * This integral is the one being calculated in the `integralAtPoint` function
///
///   * Besides this rule, rewards are also capped by a maximum percentage
///     provided at contract instantiation time (a cap of 40 means your maximum
///     possible reward is 40% of your initial stake
///

contract CappedRewardCalculator {
  
  uint public immutable startDate;
  
  uint public immutable endDate;
  
  uint public immutable cap;

  uint constant private year = 365 days;
  uint constant private day = 1 days;
  uint private constant mul = 1000000;

  
  
  
  
  constructor(
    uint _start,
    uint _end,
    uint _cap
  ) {
    require(block.timestamp <= _start, "CappedRewardCalculator: start date must be in the future");
    require(
      _start < _end,
      "CappedRewardCalculator: end date must be after start date"
    );

    require(_cap > 0, "CappedRewardCalculator: curve cap cannot be 0");

    startDate = _start;
    endDate = _end;
    cap = _cap;
  }

  
  
  
  
  
  function calculateReward(
    uint _start,
    uint _end,
    uint _amount
  ) public view returns (uint) {
    (uint start, uint end) = truncatePeriod(_start, _end);
    (uint startPercent, uint endPercent) = toPeriodPercents(start, end);

    uint percentage = curvePercentage(startPercent, endPercent);

    uint reward = _amount * cap * percentage / (mul * 100);

    return reward;
  }

  
  
  function currentAPY() public view returns (uint) {
    uint amount = 100 ether;
    uint today = block.timestamp;

    if (today < startDate) {
      today = startDate;
    }

    uint todayReward = calculateReward(startDate, today, amount);

    uint tomorrow = today + day;
    uint tomorrowReward = calculateReward(startDate, tomorrow, amount);

    uint delta = tomorrowReward - todayReward;
    uint apy = delta * 365 * 100 / amount;

    return apy;
  }

  function toPeriodPercents(
    uint _start,
    uint _end
  ) internal view returns (uint, uint) {
    uint totalDuration = endDate - startDate;

    if (totalDuration == 0) {
      return (0, mul);
    }

    uint startPercent = (_start - startDate) * mul / totalDuration;
    uint endPercent = (_end - startDate) * mul / totalDuration;

    return (startPercent, endPercent);
  }

  function truncatePeriod(
    uint _start,
    uint _end
  ) internal view returns (uint, uint) {
    if (_end <= startDate || _start >= endDate) {
      return (startDate, startDate);
    }

    uint start = _start < startDate ? startDate : _start;
    uint end = _end > endDate ? endDate : _end;

    return (start, end);
  }

  function curvePercentage(uint _start, uint _end) internal pure returns (uint) {
    int maxArea = integralAtPoint(mul) - integralAtPoint(0);
    int actualArea = integralAtPoint(_end) - integralAtPoint(_start);

    uint ratio = uint(actualArea * int(mul) / maxArea);

    return ratio;
  }


  function integralAtPoint(uint _x) internal pure returns (int) {
    int x = int(_x);
    int p1 = ((x - int(mul)) ** 3) / (3 * int(mul));

    return p1;
  }
}

// 

pragma solidity ^0.8.3;





interface IClaimsRegistryVerifier {
  
  
  
  
  
  function verifyClaim(address subject, address attester, bytes calldata sig) external view returns (bool);
}

// 

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// 

pragma solidity ^0.8.3;



contract Verifier {

  
  ///   was signed by the provided issuer. Assumes data was signed using the
  ///   Ethereum prefix to protect against unkonwingly signing transactions
  
  
  
  
  function verifyWithPrefix(bytes32 hash, bytes calldata sig, address signer) public pure returns (bool) {
    return verify(addPrefix(hash), sig, signer);
  }

  
  ///  was signed using the Ethereum prefix to protect against unknowingly signing
  ///  transaction.s
  
  
  
  function recoverWithPrefix(bytes32 hash, bytes calldata sig) public pure returns (address) {
    return recover(addPrefix(hash), sig);
  }

  function verify(bytes32 hash, bytes calldata sig, address signer) internal pure returns (bool) {
    return recover(hash, sig) == signer;
  }

  function recover(bytes32 hash, bytes calldata _sig) internal pure returns (address) {
    bytes memory sig = _sig;
    bytes32 r;
    bytes32 s;
    uint8 v;

    if (sig.length != 65) {
      return address(0);
    }

    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := and(mload(add(sig, 65)), 255)
    }

    if (v < 27) {
      v += 27;
    }

    if (v != 27 && v != 28) {
      return address(0);
    }

    return ecrecover(hash, v, r, s);
  }

  function addPrefix(bytes32 hash) private pure returns (bytes32) {
    bytes memory prefix = "\x19Ethereum Signed Message:\n32";

    return keccak256(abi.encodePacked(prefix, hash));
  }
}
// 

pragma solidity ^0.8.3;









contract Staking is CappedRewardCalculator, Ownable {
  
  ERC20 public immutable erc20;

  
  IClaimsRegistryVerifier public immutable registry;

  
  ///   (i.e. they must be signed by this address)
  address public immutable claimAttester;

  
  uint public immutable minAmount;

  
  uint public immutable maxAmount;

  
  uint public lockedReward = 0;

  
  uint public distributedReward = 0;

  
  uint public stakedAmount = 0;

  
  mapping(address => Subscription) public subscriptions;

  
  event Subscribed(
    address subscriber,
    uint date,
    uint stakedAmount,
    uint maxReward
  );

  
  event Withdrawn(
    address subscriber,
    uint date,
    uint withdrawAmount
  );

  
  struct Subscription {
    bool active;
    address subscriberAddress; // addres the subscriptions refers to
    uint startDate;      // Block timestamp at which the subscription was made
    uint stakedAmount;   // How much was staked
    uint maxReward;      // Maximum reward given if user stays until the end of the staking period
    uint withdrawAmount; // Total amount withdrawn (initial amount + final calculated reward)
    uint withdrawDate;   // Block timestamp at which the subscription was withdrawn (or 0 while staking is in progress)
  }

  
  
  
  
  
  
  
  
  
  constructor(
    address _token,
    address _registry,
    address _attester,
    uint _startDate,
    uint _endDate,
    uint _minAmount,
    uint _maxAmount,
    uint _cap
  ) CappedRewardCalculator(_startDate, _endDate, _cap) {
    require(_token != address(0), "Staking: token address cannot be 0x0");
    require(_registry != address(0), "Staking: claims registry address cannot be 0x0");
    require(_attester != address(0), "Staking: claim attester cannot be 0x0");
    require(block.timestamp <= _startDate, "Staking: start date must be in the future");
    require(_minAmount > 0, "Staking: invalid individual min amount");
    require(_maxAmount > _minAmount, "Staking: max amount must be higher than min amount");

    erc20 = ERC20(_token);
    registry = IClaimsRegistryVerifier(_registry);
    claimAttester = _attester;

    minAmount = _minAmount;
    maxAmount = _maxAmount;
  }

  
  
  function totalPool() public view returns (uint) {
    return erc20.balanceOf(address(this)) - stakedAmount + distributedReward;
  }

  
  
  function availablePool() public view returns (uint) {
    return erc20.balanceOf(address(this)) - stakedAmount - lockedReward;
  }

  
  ///   created, maximum rewards are calculated upfront, and a valid claim
  ///   signature needs to be provided, which will be checked against the expected
  ///   attester on the registry contract
  
  
  function stake(uint _amount, bytes calldata claimSig) external {
    uint time = block.timestamp;
    address subscriber = msg.sender;

    require(registry.verifyClaim(msg.sender, claimAttester, claimSig), "Staking: could not verify claim");
    require(_amount >= minAmount, "Staking: staked amount needs to be greater than or equal to minimum amount");
    require(_amount <= maxAmount, "Staking: staked amount needs to be lower than or equal to maximum amount");
    require(time >= startDate, "Staking: staking period not started");
    require(time < endDate, "Staking: staking period finished");
    require(subscriptions[subscriber].active == false, "Staking: this account has already staked");


    uint maxReward = calculateReward(time, endDate, _amount);
    require(maxReward <= availablePool(), "Staking: not enough tokens available in the pool");
    lockedReward += maxReward;
    stakedAmount += _amount;

    subscriptions[subscriber] = Subscription(
      true,
      subscriber,
      time,
      _amount,
      maxReward,
      0,
      0
    );

    // transfer tokens from subscriber to the contract
    require(erc20.transferFrom(subscriber, address(this), _amount),
      "Staking: Could not transfer tokens from subscriber");

    emit Subscribed(subscriber, time, _amount, maxReward);
  }

  
  function withdraw() external {
    address subscriber = msg.sender;
    uint time = block.timestamp;

    require(subscriptions[subscriber].active == true, "Staking: no active subscription found for this address");

    Subscription memory sub = subscriptions[subscriber];

    uint actualReward = calculateReward(sub.startDate, time, sub.stakedAmount);
    uint total = sub.stakedAmount + actualReward;

    // update subscription state
    sub.withdrawAmount = total;
    sub.withdrawDate = time;
    sub.active = false;
    subscriptions[subscriber] = sub;

    // update locked amount
    lockedReward -= sub.maxReward;
    distributedReward += actualReward;
    stakedAmount -= sub.stakedAmount;

    // transfer tokens back to subscriber
    require(erc20.transfer(subscriber, total), "Staking: Transfer has failed");

    emit Withdrawn(subscriber, time, total);
  }

  
  
  
  function getStakedAmount(address _subscriber) external view returns (uint) {
    if (subscriptions[_subscriber].stakedAmount > 0 && subscriptions[_subscriber].withdrawDate == 0) {
      return subscriptions[_subscriber].stakedAmount;
    } else {
      return 0;
    }
  }

  
  
  
  function getMaxStakeReward(address _subscriber) external view returns (uint) {
    Subscription memory sub = subscriptions[_subscriber];

    if (sub.active) {
      return subscriptions[_subscriber].maxReward;
    } else {
      return 0;
    }
  }

  
  
  
  function getCurrentReward(address _subscriber) external view returns (uint) {
    Subscription memory sub = subscriptions[_subscriber];

    if (sub.active) {
      return calculateReward(sub.startDate, block.timestamp, sub.stakedAmount);
    } else {
      return 0;
    }
  }

  
  function withdrawPool() external onlyOwner {
    require(block.timestamp > endDate, "Staking: staking not over yet");

    erc20.transfer(owner(), availablePool());
  }
}

// 

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overloaded;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}



contract ClaimsRegistry is IClaimsRegistryVerifier, Verifier {
  
  mapping(bytes32 => Claim) public registry;

  
  struct Claim {
    address subject; // Subject the claim refers to
    bool revoked;    // Whether the claim is revoked or not
  }

  
  event ClaimStored(
    bytes sig
  );

  
  event ClaimRevoked(
    bytes sig
  );

  
  ///   actual data, receives only `claimHash` and `sig`, and checks whether the
  ///   signature matches the expected key, and is signed by `attester`
  
  
  
  
  function setClaimWithSignature(
    address subject,
    address attester,
    bytes32 claimHash,
    bytes calldata sig
  ) public {
    bytes32 signable = computeSignableKey(subject, claimHash);

    require(verifyWithPrefix(signable, sig, attester), "ClaimsRegistry: Claim signature does not match attester");

    bytes32 key = computeKey(attester, sig);

    registry[key] = Claim(subject, false);

    emit ClaimStored(sig);
  }

  
  
  
  
  function getClaim(
    address attester,
    bytes calldata sig
  ) public view returns (address) {
    bytes32 key = keccak256(abi.encodePacked(attester, sig));

    if (registry[key].revoked) {
      return address(0);
    } else {
      return registry[key].subject;
    }

  }

  
  
  
  
  
  function verifyClaim(
    address subject,
    address attester,
    bytes calldata sig
  ) override external view returns (bool) {
    return getClaim(attester, sig) == subject;
  }

  
  
  function revokeClaim(
    bytes calldata sig
  ) public {
    bytes32 key = computeKey(msg.sender, sig);

    require(registry[key].subject != address(0), "ClaimsRegistry: Claim not found");

    registry[key].revoked = true;

    emit ClaimRevoked(sig);
  }

  
  
  
  
  function computeSignableKey(address subject, bytes32 claimHash) public pure returns (bytes32) {
    return keccak256(abi.encodePacked(subject, claimHash));
  }

  function computeKey(address attester, bytes calldata sig) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(attester, sig));
  }
}
