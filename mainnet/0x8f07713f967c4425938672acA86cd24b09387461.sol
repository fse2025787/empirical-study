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
pragma solidity 0.8.4;


interface ICVNXStake {
    struct Stake {
        uint256 amount;
        uint256 endTimestamp;
    }

    
    
    
    
    function stake(uint256 _amount, address _address, uint256 _endTimestamp) external;

    
    function unstake() external;

    
    
    function getStakesList(address _address) external view returns(Stake[] memory stakes);

    
    
    function getStakedAmount(address _address) external view returns(uint256);
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
pragma solidity 0.8.4;






contract CVNXStake is ICVNXStake, Ownable {
    
    event Staked(uint256 indexed amount, address accountAddress);
    
    event Unstaked(uint256 indexed amount, address accountAddress, uint256 indexed timestamp);

    
    ICVNX public cvnxToken;

    mapping(address => Stake[]) accountToStakes;
    mapping(address => uint256) accountToStaked;

    
    constructor(address _cvnxToken) {
        cvnxToken = ICVNX(_cvnxToken);
    }

    
    
    
    
    function stake(uint256 _amount, address _address, uint256 _endTimestamp) external override onlyOwner {
        require(_amount > 0, "[E-57] - Amount can't be a zero.");
        require(_endTimestamp > block.timestamp, "[E-58] - End timestamp should be more than current timestamp.");
        require(_address != address(0), "[E-59] - Zero address.");

        uint256 _accountToStaked = accountToStaked[_address];

        Stake memory _stake = Stake(_amount, _endTimestamp);

        cvnxToken.transferFrom(_address, address(this), _amount);

        accountToStaked[_address] = _accountToStaked + _amount;
        accountToStakes[_address].push(_stake);

        emit Staked(_amount, _address);
    }

    
    function unstake() external override {
        uint256 _accountToStaked = accountToStaked[msg.sender];
        uint256 _unavailableToUnstake;

        for (uint256 i = 0; i < accountToStakes[msg.sender].length; i++) {
            if (accountToStakes[msg.sender][i].endTimestamp > block.timestamp) {
                _unavailableToUnstake += accountToStakes[msg.sender][i].amount;
            }
        }

        uint256 _toUnstake = _accountToStaked - _unavailableToUnstake;

        require(_toUnstake > 0, "[E-46] - Nothing to unstake.");

        accountToStaked[msg.sender] -= _toUnstake;
        cvnxToken.transfer(msg.sender, _toUnstake);

        emit Unstaked(_toUnstake, msg.sender, block.timestamp);
    }

    
    
    function getStakesList(address _address) external view override onlyOwner returns(Stake[] memory stakes) {
        return accountToStakes[_address];
    }

    
    
    function getStakedAmount(address _address) external view override returns(uint256) {
        return accountToStaked[_address];
    }
}

// 
pragma solidity 0.8.4;




interface ICVNX is IERC20 {
    
    
    
    function mint(address _account, uint256 _amount) external;

    
    
    
    function lock(address _tokenOwner, uint256 _tokenAmount) external;

    
    
    
    function unlock(address _tokenOwner, uint256 _tokenAmount) external;

    
    
    function swap(uint256 _amount) external returns (bool);

    
    
    
    
    function transferStuckERC20(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external;

    
    
    function setCvnxGovernanceContract(address _address) external;

    
    
    
    
    function setLimit(uint256 _percent, uint256 _limitAmount, uint256 _period) external;

    
    
    function addFromWhitelist(address _newAddress) external;

    
    
    function removeFromWhitelist(address _oldAddress) external;

    
    
    function addToWhitelist(address _newAddress) external;

    
    
    function removeToWhitelist(address _oldAddress) external;

    
    function changeLimitActivityStatus() external;
}
