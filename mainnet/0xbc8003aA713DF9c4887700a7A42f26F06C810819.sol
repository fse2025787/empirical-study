
/**
 *Submitted for verification at Etherscan.io on 2023-01-31
*/

// Sources flattened with hardhat v2.9.9 https://hardhat.org

// File lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

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


// File src/base/ErrorMessages.sol

pragma solidity >=0.8.4;


///         inappropriate.
///

error IllegalArgument(string message);


///

error IllegalState(string message);


///

error UnsupportedOperation(string message);


///

error Unauthorized(string message);


// File src/base/MutexLock.sol



///

abstract contract MutexLock {
    enum State {
        RESERVED,
        UNLOCKED,
        LOCKED
    }

    
    State private _lockState = State.UNLOCKED;

    
    modifier lock() {
        _claimLock();

        _;

        _freeLock();
    }

    
    ///
    
    function _isLocked() internal view returns (bool) {
        return _lockState == State.LOCKED;
    }

    
    function _claimLock() internal {
        // Check that the lock has not been claimed yet.
        if (_lockState != State.UNLOCKED) {
            revert IllegalState("Lock already claimed");
        }

        // Claim the lock.
        _lockState = State.LOCKED;
    }

    
    function _freeLock() internal {
        _lockState = State.UNLOCKED;
    }
}


// File src/interfaces/IERC20Metadata.sol

pragma solidity >=0.5.0;



interface IERC20Metadata {
    
    ///
    
    function name() external view returns (string memory);

    
    ///
    
    function symbol() external view returns (string memory);

    
    ///
    
    function decimals() external view returns (uint8);
}


// File src/libraries/SafeERC20.sol

pragma solidity >=0.8.4;



library SafeERC20 {
    
    ///
    
    
    
    ///                success. Otherwise, this is malformed data when the call was a success.
    error ERC20CallFailed(address target, bool success, bytes data);

    
    ///
    
    ///      unexpected value.
    ///
    
    ///
    
    function expectDecimals(address token) internal view returns (uint8) {
        (bool success, bytes memory data) = token.staticcall(
            abi.encodeWithSelector(IERC20Metadata.decimals.selector)
        );

        if (!success || data.length < 32) {
            revert ERC20CallFailed(token, success, data);
        }

        return abi.decode(data, (uint8));
    }

    
    ///
    
    ///      unexpected value.
    ///
    
    
    
    function safeTransfer(address token, address recipient, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transfer.selector, recipient, amount)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///      unexpected value.
    ///
    
    
    
    function safeApprove(address token, address spender, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.approve.selector, spender, value)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///      unexpected value.
    ///
    
    
    
    
    function safeTransferFrom(address token, address owner, address recipient, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, owner, recipient, amount)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }
}


// File src/interfaces/ITokenAdapter.sol

pragma solidity >=0.5.0;



interface ITokenAdapter {
    
    ///
    
    function version() external view returns (string memory);

    
    ///
    
    function token() external view returns (address);

    
    ///
    
    function underlyingToken() external view returns (address);

    
    ///         for.
    ///
    
    function price() external view returns (uint256);

    
    ///
    
    
    ///
    
    function wrap(uint256 amount, address recipient)
        external
        returns (uint256 amountYieldTokens);

    
    ///
    
    
    ///
    
    function unwrap(uint256 amount, address recipient)
        external
        returns (uint256 amountUnderlyingTokens);
}


// File src/interfaces/external/IWETH9.sol

pragma solidity >=0.5.0;


interface IWETH9 is IERC20, IERC20Metadata {
  
  function deposit() external payable;

  
  ///
  
  ///      that is allowed to be utilized to be exactly 2300 when receiving ethereum.
  ///
  
  function withdraw(uint256 amount) external;
}


// File src/interfaces/external/vesper/IVesperPool.sol

pragma solidity >=0.5.0;

interface IVesperPool is IERC20 {
    function deposit() external payable;

    function deposit(uint256 _share) external;

    function governor() external returns (address);

    function keepers() external returns (address);

    function multiTransfer(address[] memory _recipients, uint256[] memory _amounts)
        external
        returns (bool);

    function excessDebt(address _strategy) external view returns (uint256);

    function permit(
        address,
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external;

    function reportEarning(
        uint256 _profit,
        uint256 _loss,
        uint256 _payback
    ) external;

    function resetApproval() external;

    function sweepERC20(address _fromToken) external;

    function withdraw(uint256 _amount) external;

    function withdrawETH(uint256 _amount) external;

    function whitelistedWithdraw(uint256 _amount) external;

    function feeCollector() external view returns (address);

    function pricePerShare() external view returns (uint256);

    function token() external view returns (address);

    function tokensHere() external view returns (uint256);

    function totalDebtOf(address _strategy) external view returns (uint256);

    function totalValue() external view returns (uint256);

    function withdrawFee() external view returns (uint256);

    function poolRewards() external view returns (address);

    function getStrategies() external view returns (address[] memory);
}


// File src/interfaces/external/vesper/IVesperRewards.sol


pragma solidity >=0.6.12;

interface IVesperRewards {
    function claimReward(address) external;

    function claimable(address) external view returns (address[] memory, uint256[] memory);

    function rewardTokens(uint256) external view returns (address);
}


// File src/adapters/vesper/VesperAdapterV1.sol





struct InitializationParams {
    address alchemist;
    address token;
    address underlyingToken;
}

contract VesperAdapterV1 is ITokenAdapter, MutexLock {

    string public override version = "1.0.0";

    address public immutable alchemist;
    address public immutable override token;
    address public immutable override underlyingToken;

    constructor(InitializationParams memory params) {
        alchemist       = params.alchemist;
        token           = params.token;
        underlyingToken = params.underlyingToken;
    }

    
    modifier onlyAlchemist() {
        if (msg.sender != alchemist) {
            revert Unauthorized("Not alchemist");
        }
        _;
    }

    
    function price() external view returns (uint256) {
        return IVesperPool(token).pricePerShare();
    }

    
    function wrap(
        uint256 amount,
        address recipient
    ) external onlyAlchemist returns (uint256) {
        // Transfer the underlying tokens from the message sender.
        SafeERC20.safeTransferFrom(underlyingToken, msg.sender, address(this), amount);
        SafeERC20.safeApprove(underlyingToken, token, amount);

        uint256 balanceBefore = IERC20(token).balanceOf(address(this));

        // Vesper deposit does not accept a recipient argument and does not return mint amount
        IVesperPool(token).deposit(amount);

        uint256 balanceAfter = IERC20(token).balanceOf(address(this));

        uint256 minted = balanceAfter - balanceBefore;

        // We must transfer to recipient after and use IERC20.balanceOf() for amount
        SafeERC20.safeTransfer(token, recipient, minted);

        return minted;
    }

    // @inheritdoc ITokenAdapter
    function unwrap(
        uint256 amount,
        address recipient
    ) external lock onlyAlchemist returns (uint256) {
        // Transfer the tokens from the message sender.
        SafeERC20.safeTransferFrom(token, msg.sender, address(this), amount);

        uint256 balanceBeforeUnderlying = IERC20(underlyingToken).balanceOf(address(this));
        uint256 balanceBeforeYieldToken = IERC20(token).balanceOf(address(this));
        
        // Vesper withdraw does not accept a recipient argument and does not return withdrawn amount
        IVesperPool(token).withdraw(amount);

        uint256 balanceAfterUnderlying = IERC20(underlyingToken).balanceOf(address(this));
        uint256 balanceAfterYieldToken = IERC20(token).balanceOf(address(this));

        uint256 withdrawn = balanceAfterUnderlying - balanceBeforeUnderlying;

        if (balanceBeforeYieldToken - balanceAfterYieldToken != amount) {
            revert IllegalState("Not all shares were burned");
        }

        // We must transfer to recipient after and use IERC20.balanceOf() for amount
        SafeERC20.safeTransfer(underlyingToken, recipient, withdrawn);

        return withdrawn;
    }
}