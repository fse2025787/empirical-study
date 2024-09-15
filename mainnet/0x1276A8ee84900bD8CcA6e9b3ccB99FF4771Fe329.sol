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
pragma solidity ^0.8.10;







contract Distributor is Ownable {

    /*///////////////////////////////////////////////////////////////
                        IMMUTABLES AND CONSTANTS
    ///////////////////////////////////////////////////////////////*/

    
    address immutable treasury;

    
    IERC20 immutable idle;

    
    uint256 public constant ONE_WEEK = 86400 * 7;

    
    
    uint256 public constant INITIAL_RATE = (178_200 * 10 ** 18) / (26 * ONE_WEEK);

    
    
    uint256 public constant EPOCH_DURATION = ONE_WEEK;

    
    
    uint256 public constant INITIAL_DISTRIBUTION_DELAY = 86400;

    /*///////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    
    address public emergencyAdmin;

    
    uint256 public distributed;

    
    uint256 public rate;

    
    uint256 public startEpochTime = block.timestamp + INITIAL_DISTRIBUTION_DELAY - EPOCH_DURATION;

    
    uint256 public epochStartingDistributed;

    
    uint256 public pendingRate = INITIAL_RATE;

    
    address public distributorProxy;

    
    uint256 public epochNumber;

    
    mapping(uint256 => uint256) public ratePerEpoch;

    /*///////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    
    event UpdateDistributorProxy(address oldProxy, address newProxy);

    
    event UpdatePendingRate(uint256 rate);

    
    event UpdateDistributionParameters(uint256 time, uint256 rate);

    /*///////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    
    
    
    constructor(IERC20 _idle, address _treasury, address _emergencyAdmin) {
        idle = _idle;
        treasury = _treasury;
        emergencyAdmin = _emergencyAdmin;
    }

    
    
    
    function setDistributorProxy(address proxy) external onlyOwner {
        address distributorProxy_ = distributorProxy;
        distributorProxy = proxy;

        emit UpdateDistributorProxy(distributorProxy_, proxy);
    }

    
    
    
    function setPendingRate(uint256 newRate) external onlyOwner {
        pendingRate = newRate;
        emit UpdatePendingRate(newRate);
    }

    
    function _updateDistributionParameters() internal {
        startEpochTime += EPOCH_DURATION; // set start epoch timestamp
        epochStartingDistributed += (rate * EPOCH_DURATION); // set initial distributed floor
        
        uint256 _pendingRate = pendingRate;
        uint256 _epochNumber = ++epochNumber;

        rate = _pendingRate; // set new rate
        ratePerEpoch[_epochNumber] = _pendingRate; // set rate for this epoch

        emit UpdateDistributionParameters(startEpochTime, rate);
    }

    
    
    function updateDistributionParameters() external {
        require(block.timestamp >= startEpochTime + EPOCH_DURATION, "epoch still running");
        _updateDistributionParameters();
    }

    
    
    function startEpochTimeWrite() external returns (uint256 _startEpochTime) {
        _startEpochTime = startEpochTime;

        if (block.timestamp >= _startEpochTime + EPOCH_DURATION) {
            _updateDistributionParameters();
            _startEpochTime = startEpochTime;
        }
    }

    
    
    function futureEpochTimeWrite() external returns (uint256 _futureEpochTime) {
        _futureEpochTime = startEpochTime + EPOCH_DURATION;

        if (block.timestamp >= _futureEpochTime) {
            _updateDistributionParameters();
            _futureEpochTime = startEpochTime + EPOCH_DURATION;
        }
    }

    
    
    function _availableToDistribute() internal view returns (uint256) {
        return epochStartingDistributed + (block.timestamp - startEpochTime) * rate;
    }

    
    
    function availableToDistribute() external view returns (uint256) {
        return _availableToDistribute();
    }

    
    
    
    function distribute(address to, uint256 amount) external returns(bool) {
        require(msg.sender == distributorProxy, "not proxy");
        require(to != address(0), "address zero");

        if (block.timestamp >= startEpochTime + EPOCH_DURATION) {
            _updateDistributionParameters();
        }

        uint256 _distributed = distributed + amount;
        require(_distributed <= _availableToDistribute(), "amount too high");

        distributed = _distributed;
        return idle.transfer(to, amount);
    }

    function setEmergencyAdmin(address emergencyAdmin_) external onlyOwner {
        emergencyAdmin = emergencyAdmin_;
    }

    
    
    function emergencyWithdraw(uint256 amount) external {
        require(msg.sender == emergencyAdmin, "not emergency admin");
        idle.transfer(treasury, amount);
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