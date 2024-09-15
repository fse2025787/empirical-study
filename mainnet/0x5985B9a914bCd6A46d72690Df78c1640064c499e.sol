// SPDX-License-Identifier: GPL-2.0-or-later
pragma abicoder v2;


// 
pragma solidity ^0.8.6;






interface IDCAPairParameters {
  
  
  
  function globalParameters() external view returns (IDCAGlobalParameters);

  
  
  function tokenA() external view returns (IERC20Metadata);

  
  
  function tokenB() external view returns (IERC20Metadata);

  
  
  
  
  
  
  function swapAmountDelta(
    uint32 _swapInterval,
    address _from,
    uint32 _swap
  ) external view returns (int256 _delta);

  
  
  
  
  function isSwapIntervalActive(uint32 _swapInterval) external view returns (bool _isActive);

  
  
  
  function performedSwaps(uint32 _swapInterval) external view returns (uint32 _swaps);
}

// 

pragma solidity >=0.7.0;

interface IGovernable {
  event PendingGovernorSet(address _pendingGovernor);
  event PendingGovernorAccepted();

  function setPendingGovernor(address _pendingGovernor) external;

  function acceptPendingGovernor() external;

  function governor() external view returns (address);

  function pendingGovernor() external view returns (address);

  function isGovernor(address _account) external view returns (bool _isGovernor);

  function isPendingGovernor(address _account) external view returns (bool _isPendingGovernor);
}

// 

pragma solidity ^0.8.6;





interface ICollectableDust {
  event DustSent(address _to, address token, uint256 amount);

  // solhint-disable-next-line func-name-mixedcase
  function ETH() external view returns (address);

  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external;
}

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
        return msg.data;
    }
}

// 

pragma solidity ^0.8.0;



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
    constructor() {
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
pragma solidity >=0.7.5;





/// to compute the result. They are also not gas efficient and should not be called on-chain.
interface IQuoter {
    
    
    
    
    function quoteExactInput(bytes memory path, uint256 amountIn) external returns (uint256 amountOut);

    
    
    
    
    
    
    
    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountOut);

    
    
    
    
    function quoteExactOutput(bytes memory path, uint256 amountOut) external returns (uint256 amountIn);

    
    
    
    
    
    
    
    function quoteExactOutputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountOut,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountIn);
}

// 
pragma solidity >=0.5.0;



interface IPeripheryImmutableState {
    
    function factory() external view returns (address);

    
    function WETH9() external view returns (address);
}

abstract contract Governable is IGovernable {
  address private _governor;
  address private _pendingGovernor;

  constructor(address __governor) {
    require(__governor != address(0), 'Governable: zero address');
    _governor = __governor;
  }

  function governor() external view override returns (address) {
    return _governor;
  }

  function pendingGovernor() external view override returns (address) {
    return _pendingGovernor;
  }

  function setPendingGovernor(address __pendingGovernor) external virtual override onlyGovernor {
    _setPendingGovernor(__pendingGovernor);
  }

  function _setPendingGovernor(address __pendingGovernor) internal {
    require(__pendingGovernor != address(0), 'Governable: zero address');
    _pendingGovernor = __pendingGovernor;
    emit PendingGovernorSet(__pendingGovernor);
  }

  function acceptPendingGovernor() external virtual override onlyPendingGovernor {
    _acceptPendingGovernor();
  }

  function _acceptPendingGovernor() internal {
    require(_pendingGovernor != address(0), 'Governable: no pending governor');
    _governor = _pendingGovernor;
    _pendingGovernor = address(0);
    emit PendingGovernorAccepted();
  }

  function isGovernor(address _account) public view override returns (bool _isGovernor) {
    return _account == _governor;
  }

  function isPendingGovernor(address _account) public view override returns (bool _isPendingGovernor) {
    return _account == _pendingGovernor;
  }

  modifier onlyGovernor() {
    require(isGovernor(msg.sender), 'Governable: only governor');
    _;
  }

  modifier onlyPendingGovernor() {
    require(isPendingGovernor(msg.sender), 'Governable: only pending governor');
    _;
  }
}

abstract contract CollectableDust is ICollectableDust {
  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.AddressSet;

  address public constant override ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  EnumerableSet.AddressSet internal _protocolTokens;

  function _addProtocolToken(address _token) internal {
    require(!_protocolTokens.contains(_token), 'CollectableDust: token already part of protocol');
    _protocolTokens.add(_token);
  }

  function _removeProtocolToken(address _token) internal {
    require(_protocolTokens.contains(_token), 'CollectableDust: token is not part of protocol');
    _protocolTokens.remove(_token);
  }

  function _sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) internal {
    require(_to != address(0), 'CollectableDust: zero address');
    require(!_protocolTokens.contains(_token), 'CollectableDust: token is part of protocol');
    if (_token == ETH) {
      payable(_to).transfer(_amount);
    } else {
      IERC20(_token).safeTransfer(_to, _amount);
    }
    emit DustSent(_to, _token, _amount);
  }
}

// 
pragma solidity ^0.8.6;






/// in order to return the expected funds and complete the swap
interface IDCASwapper is ICollectableDust {
  
  struct PairToSwap {
    // The pair to swap
    IDCAPair pair;
    // Path to execute the best swap possible
    bytes swapPath;
  }

  
  
  
  event Swapped(PairToSwap[] _pairsToSwap, uint256 _amountSwapped);

  
  error ZeroPairsToSwap();

  
  
  function paused() external view returns (bool _isPaused);

  
  
  
  
  /// Will be empty (length = 0) if there is no path available and the pair can't be swapped.
  function findBestSwap(IDCAPair _pair) external returns (bytes memory _swapPath);

  
  
  /// last pairs in the array are less likely to be swapped.
  /// Will revert with ZeroPairsToSwap if _pairsToSwap is empty
  /// Will revert if called when paused
  
  
  function swapPairs(PairToSwap[] calldata _pairsToSwap) external returns (uint256 _amountSwapped);

  
  function pause() external;

  
  function unpause() external;
}

// 
pragma solidity ^0.8.6;





interface IDCAPairSwapCallee {
  
  
  
  
  
  
  
  
  
  
  // solhint-disable-next-line func-name-mixedcase
  function DCAPairSwapCall(
    address _sender,
    IERC20Metadata _tokenA,
    IERC20Metadata _tokenB,
    uint256 _amountBorrowedTokenA,
    uint256 _amountBorrowedTokenB,
    bool _isRewardTokenA,
    uint256 _rewardAmount,
    uint256 _amountToProvide,
    bytes calldata _data
  ) external;
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3SwapCallback {
    
    
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
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



interface IDCAPairPositionHandler is IDCAPairParameters {
  
  struct UserPosition {
    // The token that the user deposited and will be swapped in exchange for "to"
    IERC20Metadata from;
    // The token that the user will get in exchange for their "from" tokens in each swap
    IERC20Metadata to;
    // How frequently the position's swaps should be executed
    uint32 swapInterval;
    // How many swaps were executed since deposit, last modification, or last withdraw
    uint32 swapsExecuted;
    // How many "to" tokens can currently be withdrawn
    uint256 swapped;
    // How many swaps left the position has to execute
    uint32 swapsLeft;
    // How many "from" tokens there are left to swap
    uint256 remaining;
    // How many "from" tokens need to be traded in each swap
    uint160 rate;
  }

  
  
  
  
  
  event Terminated(address indexed _user, uint256 _dcaId, uint256 _returnedUnswapped, uint256 _returnedSwapped);

  
  
  
  
  
  
  
  
  event Deposited(
    address indexed _user,
    uint256 _dcaId,
    address _fromToken,
    uint160 _rate,
    uint32 _startingSwap,
    uint32 _swapInterval,
    uint32 _lastSwap
  );

  
  
  
  
  
  event Withdrew(address indexed _user, uint256 _dcaId, address _token, uint256 _amount);

  
  
  
  
  
  event WithdrewMany(address indexed _user, uint256[] _dcaIds, uint256 _swappedTokenA, uint256 _swappedTokenB);

  
  
  
  
  
  
  event Modified(address indexed _user, uint256 _dcaId, uint160 _rate, uint32 _startingSwap, uint32 _lastSwap);

  
  error InvalidToken();

  
  error InvalidInterval();

  
  error InvalidPosition();

  
  error UnauthorizedCaller();

  
  error ZeroRate();

  
  error ZeroSwaps();

  
  error ZeroAmount();

  
  error PositionCompleted();

  
  /// is thrown so that the user doesn't lose any funds. The error indicates that the user must perform a withdraw
  /// before modifying their position
  error MandatoryWithdraw();

  
  
  
  function userPosition(uint256 _dcaId) external view returns (UserPosition memory _position);

  
  
  /// With InvalidToken if _tokenAddress is neither token A nor token B
  /// With ZeroRate if _rate is zero
  /// With ZeroSwaps if _amountOfSwaps is zero
  /// With InvalidInterval if _swapInterval is not a valid swap interval
  
  
  
  
  
  function deposit(
    address _tokenAddress,
    uint160 _rate,
    uint32 _amountOfSwaps,
    uint32 _swapInterval
  ) external returns (uint256 _dcaId);

  
  
  /// With InvalidPosition if _dcaId is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position
  
  
  function withdrawSwapped(uint256 _dcaId) external returns (uint256 _swapped);

  
  
  /// With InvalidPosition if any of the ids in _dcaIds is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to any of the positions in _dcaIds
  
  
  
  function withdrawSwappedMany(uint256[] calldata _dcaIds) external returns (uint256 _swappedTokenA, uint256 _swappedTokenB);

  
  /// depending on whether the new rate is greater than the previous one.
  
  /// With InvalidPosition if _dcaId is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position
  /// With PositionCompleted if position has already been completed
  /// With ZeroRate if _newRate is zero
  /// With MandatoryWithdraw if the user must execute a withdraw before modifying their position
  
  
  function modifyRate(uint256 _dcaId, uint160 _newRate) external;

  
  /// deposited funds depending on whether the new amount of swaps is greater than the swaps left.
  
  /// With InvalidPosition if _dcaId is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position
  /// With MandatoryWithdraw if the user must execute a withdraw before modifying their position
  
  
  function modifySwaps(uint256 _dcaId, uint32 _newSwaps) external;

  
  /// deposited funds depending on whether the new parameters require more or less than the the unswapped funds.
  
  /// With InvalidPosition if _dcaId is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position
  /// With ZeroRate if _newRate is zero
  /// With MandatoryWithdraw if the user must execute a withdraw before modifying their position
  
  
  
  function modifyRateAndSwaps(
    uint256 _dcaId,
    uint160 _newRate,
    uint32 _newSwaps
  ) external;

  
  /// it is executed in _newSwaps swaps
  
  /// With InvalidPosition if _dcaId is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position
  /// With ZeroAmount if _amount is zero
  /// With ZeroSwaps if _newSwaps is zero
  /// With MandatoryWithdraw if the user must execute a withdraw before modifying their position
  
  
  
  function addFundsToPosition(
    uint256 _dcaId,
    uint256 _amount,
    uint32 _newSwaps
  ) external;

  
  
  /// With InvalidPosition if _dcaId is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position
  
  function terminate(uint256 _dcaId) external;
}



interface IDCAPairSwapHandler {
  
  struct SwapInformation {
    // The affected swap interval
    uint32 interval;
    // The number of the swap that will be performed
    uint32 swapToPerform;
    // The amount of token A that needs swapping
    uint256 amountToSwapTokenA;
    // The amount of token B that needs swapping
    uint256 amountToSwapTokenB;
  }

  
  struct NextSwapInformation {
    // All swaps that can be executed
    SwapInformation[] swapsToPerform;
    // How many entries of the swapsToPerform array are valid
    uint8 amountOfSwaps;
    // How much can be borrowed in token A during a flash swap
    uint256 availableToBorrowTokenA;
    // How much can be borrowed in token B during a flash swap
    uint256 availableToBorrowTokenB;
    // How much 10**decimals(tokenB) is when converted to token A
    uint256 ratePerUnitBToA;
    // How much 10**decimals(tokenA) is when converted to token B
    uint256 ratePerUnitAToB;
    // How much token A will be sent to the platform in terms of fee
    uint256 platformFeeTokenA;
    // How much token B will be sent to the platform in terms of fee
    uint256 platformFeeTokenB;
    // The amount of tokens that need to be provided by the swapper
    uint256 amountToBeProvidedBySwapper;
    // The amount of tokens that will be sent to the swapper optimistically
    uint256 amountToRewardSwapperWith;
    // The token that needs to be provided by the swapper
    IERC20Metadata tokenToBeProvidedBySwapper;
    // The token that will be sent to the swapper optimistically
    IERC20Metadata tokenToRewardSwapperWith;
  }

  
  
  
  
  
  
  
  event Swapped(
    address indexed _sender,
    address indexed _to,
    uint256 _amountBorrowedTokenA,
    uint256 _amountBorrowedTokenB,
    uint32 _fee,
    NextSwapInformation _nextSwapInformation
  );

  
  error NoSwapsToExecute();

  
  
  
  /// be in the past
  function nextSwapAvailable(uint32 _swapInterval) external view returns (uint32 _when);

  
  
  
  
  function swapAmountAccumulator(uint32 _swapInterval, address _from) external view returns (uint256);

  
  
  function getNextSwapInfo() external view returns (NextSwapInformation memory _nextSwapInformation);

  
  
  /// Paused if swaps are paused by protocol
  /// NoSwapsToExecute if there are no swaps to execute
  /// LiquidityNotReturned if the required tokens were not sent before calling the function
  function swap() external;

  
  
  /// Paused if swaps are paused by protocol
  /// NoSwapsToExecute if there are no swaps to execute
  /// InsufficientLiquidity if asked to borrow more than the actual reserves
  /// LiquidityNotReturned if the required tokens were not back during the callback
  
  
  
  
  function swap(
    uint256 _amountToBorrowTokenA,
    uint256 _amountToBorrowTokenB,
    address _to,
    bytes calldata _data
  ) external;

  
  
  function secondsUntilNextSwap() external view returns (uint32 _secondsUntilNextSwap);
}



interface IDCAPairLoanHandler {
  
  
  
  
  
  
  event Loaned(address indexed _sender, address indexed _to, uint256 _amountBorrowedTokenA, uint256 _amountBorrowedTokenB, uint32 _loanFee);

  // @notice Thrown when trying to execute a flash loan but without actually asking for tokens
  error ZeroLoan();

  
  
  
  function availableToBorrow() external view returns (uint256 _amountToBorrowTokenA, uint256 _amountToBorrowTokenB);

  
  
  /// With ZeroLoan if both _amountToBorrowTokenA & _amountToBorrowTokenB are 0
  /// With Paused if loans are paused by protocol
  /// With InsufficientLiquidity if asked for more that reserves
  
  
  
  
  function loan(
    uint256 _amountToBorrowTokenA,
    uint256 _amountToBorrowTokenB,
    address _to,
    bytes calldata _data
  ) external;
}

// 
pragma solidity >=0.5.0;





interface ITimeWeightedOracle {
  
  
  
  event AddedSupportForPair(address _tokenA, address _tokenB);

  
  
  
  
  
  function canSupportPair(address _tokenA, address _tokenB) external view returns (bool _canSupport);

  
  
  
  
  
  function quote(
    address _tokenIn,
    uint128 _amountIn,
    address _tokenOut
  ) external view returns (uint256 _amountOut);

  
  /// configure the pair for future quotes. Could be called more than one in order to let the oracle re-configure for a new context.
  
  
  
  function addSupportForPair(address _tokenA, address _tokenB) external;
}
// 
pragma solidity ^0.8.6;













interface ICustomQuoter is IQuoter, IPeripheryImmutableState {}

contract DCAUniswapV3Swapper is IDCASwapper, Governable, IDCAPairSwapCallee, CollectableDust, Pausable {
  // solhint-disable-next-line var-name-mixedcase
  uint24[] private _FEE_TIERS = [500, 3000, 10000];
  ISwapRouter public immutable swapRouter;
  ICustomQuoter public immutable quoter;

  constructor(
    address _governor,
    ISwapRouter _swapRouter,
    ICustomQuoter _quoter
  ) Governable(_governor) {
    if (address(_swapRouter) == address(0) || address(_quoter) == address(0)) revert CommonErrors.ZeroAddress();
    swapRouter = _swapRouter;
    quoter = _quoter;
  }

  function swapPairs(PairToSwap[] calldata _pairsToSwap) external override whenNotPaused returns (uint256 _amountSwapped) {
    if (_pairsToSwap.length == 0) revert ZeroPairsToSwap();

    uint256 _maxGasSpent;

    do {
      uint256 _gasLeftStart = gasleft();
      _swap(_pairsToSwap[_amountSwapped++]);
      uint256 _gasSpent = _gasLeftStart - gasleft();

      // Update max gas spent if necessary
      if (_gasSpent > _maxGasSpent) {
        _maxGasSpent = _gasSpent;
      }

      // We will continue to execute swaps if there are more swaps to execute, and (gas left) >= 1.5 * (max gas spent on a swap)
    } while (_amountSwapped < _pairsToSwap.length && gasleft() >= (_maxGasSpent * 3) / 2);

    emit Swapped(_pairsToSwap, _amountSwapped);
  }

  function paused() public view override(IDCASwapper, Pausable) returns (bool) {
    return super.paused();
  }

  function pause() external override onlyGovernor {
    _pause();
  }

  function unpause() external override onlyGovernor {
    _unpause();
  }

  /**
   * This method isn't a view because the Uniswap quoter doesn't support view quotes.
   * Therefore, we highly recommend that this method is not called on-chain.
   * This method will return an empty set of bytes if the pair should not be swapped, and encode(max(uint24)) if there is no need to go to Uniswap
   */
  function findBestSwap(IDCAPair _pair) external override returns (bytes memory _swapPath) {
    IDCAPairSwapHandler.NextSwapInformation memory _nextSwapInformation = _pair.getNextSwapInfo();
    if (_nextSwapInformation.amountOfSwaps > 0) {
      if (_nextSwapInformation.amountToBeProvidedBySwapper == 0) {
        return abi.encode(type(uint24).max);
      } else {
        uint256 _minNecessary;
        uint24 _feeTier;
        for (uint256 i; i < _FEE_TIERS.length; i++) {
          address _factory = quoter.factory();
          address _pool = IUniswapV3Factory(_factory).getPool(
            address(_nextSwapInformation.tokenToRewardSwapperWith),
            address(_nextSwapInformation.tokenToBeProvidedBySwapper),
            _FEE_TIERS[i]
          );
          if (_pool != address(0)) {
            try
              quoter.quoteExactOutputSingle(
                address(_nextSwapInformation.tokenToRewardSwapperWith),
                address(_nextSwapInformation.tokenToBeProvidedBySwapper),
                _FEE_TIERS[i],
                _nextSwapInformation.amountToBeProvidedBySwapper,
                0
              )
            returns (uint256 _inputNecessary) {
              if (_nextSwapInformation.amountToRewardSwapperWith >= _inputNecessary && (_minNecessary == 0 || _inputNecessary < _minNecessary)) {
                _minNecessary = _inputNecessary;
                _feeTier = _FEE_TIERS[i];
              }
            } catch {}
          }
        }
        if (_feeTier > 0) {
          _swapPath = abi.encode(_feeTier);
        }
      }
    }
  }

  function _swap(PairToSwap memory _pair) internal {
    // Execute the swap, making myself the callee so that the `DCAPairSwapCall` function is called
    _pair.pair.swap(0, 0, address(this), _pair.swapPath);
  }

  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external override onlyGovernor {
    _sendDust(_to, _token, _amount);
  }

  // solhint-disable-next-line func-name-mixedcase
  function DCAPairSwapCall(
    address,
    IERC20Metadata _tokenA,
    IERC20Metadata _tokenB,
    uint256,
    uint256,
    bool _isRewardTokenA,
    uint256 _rewardAmount,
    uint256 _amountToProvide,
    bytes calldata _bytes
  ) external override {
    if (_amountToProvide > 0) {
      address _tokenIn = _isRewardTokenA ? address(_tokenA) : address(_tokenB);
      address _tokenOut = _isRewardTokenA ? address(_tokenB) : address(_tokenA);

      // Approve the router to spend the specifed `rewardAmount` of tokenIn.
      TransferHelper.safeApprove(_tokenIn, address(swapRouter), _rewardAmount);

      ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams({
        tokenIn: _tokenIn,
        tokenOut: _tokenOut,
        fee: abi.decode(_bytes, (uint24)),
        recipient: msg.sender, // Send it directly to pair
        deadline: block.timestamp, // Needs to happen now
        amountOut: _amountToProvide,
        amountInMaximum: _rewardAmount,
        sqrtPriceLimitX96: 0
      });

      // Executes the swap returning the amountIn needed to spend to receive the desired amountOut.
      uint256 _amountIn = swapRouter.exactOutputSingle(params);

      // For exact output swaps, the amountInMaximum may not have all been spent.
      // If the actual amount spent (amountIn) is less than the specified maximum amount, we must refund the pair (msg.sender) and approve the swapRouter to spend 0.
      if (_amountIn < _rewardAmount) {
        TransferHelper.safeApprove(_tokenIn, address(swapRouter), 0);
        TransferHelper.safeTransfer(_tokenIn, msg.sender, _rewardAmount - _amountIn);
      }
    }
  }
}

// 
pragma solidity >=0.7.5;






interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    
    
    
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    
    
    
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    
    
    
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    
    
    
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3Factory {
    
    
    
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    
    
    
    
    
    
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    
    
    
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    
    
    
    function owner() external view returns (address);

    
    
    
    
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    
    
    
    
    
    
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    
    
    
    
    
    /// from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
    /// are invalid.
    
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    
    
    
    function setOwner(address _owner) external;

    
    
    
    
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}

// 
pragma solidity >=0.6.0;



library TransferHelper {
    
    
    
    
    
    
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    
    
    
    
    
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    
    
    
    
    
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    
    
    
    
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}

// 
pragma solidity ^0.8.6;

library CommonErrors {
  error ZeroAddress();
  error Paused();
  error InsufficientLiquidity();
  error LiquidityNotReturned();
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// 

pragma solidity ^0.8.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface IDCAPair is IDCAPairParameters, IDCAPairSwapHandler, IDCAPairPositionHandler, IDCAPairLoanHandler {}

// 

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
pragma solidity ^0.8.6;






interface IDCAGlobalParameters {
  
  struct SwapParameters {
    // The address of the fee recipient
    address feeRecipient;
    // Whether swaps are paused or not
    bool isPaused;
    // The swap fee
    uint32 swapFee;
    // The oracle contract
    ITimeWeightedOracle oracle;
  }

  
  struct LoanParameters {
    // The address of the fee recipient
    address feeRecipient;
    // Whether loans are paused or not
    bool isPaused;
    // The loan fee
    uint32 loanFee;
  }

  
  
  event FeeRecipientSet(address _feeRecipient);

  
  
  event NFTDescriptorSet(IDCATokenDescriptor _descriptor);

  
  
  event OracleSet(ITimeWeightedOracle _oracle);

  
  
  event SwapFeeSet(uint32 _feeSet);

  
  
  event LoanFeeSet(uint32 _feeSet);

  
  
  
  event SwapIntervalsAllowed(uint32[] _swapIntervals, string[] _descriptions);

  
  
  event SwapIntervalsForbidden(uint32[] _swapIntervals);

  
  error HighFee();

  
  error InvalidParams();

  
  error ZeroInterval();

  
  error EmptyDescription();

  
  
  function feeRecipient() external view returns (address _feeRecipient);

  
  
  function swapFee() external view returns (uint32 _swapFee);

  
  
  function loanFee() external view returns (uint32 _loanFee);

  
  
  function nftDescriptor() external view returns (IDCATokenDescriptor _nftDescriptor);

  
  
  function oracle() external view returns (ITimeWeightedOracle _oracle);

  
  
  
  // solhint-disable-next-line func-name-mixedcase
  function FEE_PRECISION() external view returns (uint24 _precision);

  
  
  
  // solhint-disable-next-line func-name-mixedcase
  function MAX_FEE() external view returns (uint32 _maxFee);

  
  
  function allowedSwapIntervals() external view returns (uint32[] memory _allowedSwapIntervals);

  
  
  function intervalDescription(uint32 _swapInterval) external view returns (string memory _description);

  
  
  function isSwapIntervalAllowed(uint32 _swapInterval) external view returns (bool _isAllowed);

  
  
  function paused() external view returns (bool _isPaused);

  
  
  function swapParameters() external view returns (SwapParameters memory _swapParameters);

  
  
  function loanParameters() external view returns (LoanParameters memory _loanParameters);

  
  
  
  function setFeeRecipient(address _feeRecipient) external;

  
  
  
  function setSwapFee(uint32 _fee) external;

  
  
  
  function setLoanFee(uint32 _fee) external;

  
  
  
  function setNFTDescriptor(IDCATokenDescriptor _descriptor) external;

  
  
  
  function setOracle(ITimeWeightedOracle _oracle) external;

  
  
  /// InvalidParams if the amount of swap intervals is different from the amount of descriptions passed
  /// ZeroInterval if any of the swap intervals is zero
  /// EmptyDescription if any of the descriptions is empty
  
  
  function addSwapIntervalsToAllowedList(uint32[] calldata _swapIntervals, string[] calldata _descriptions) external;

  
  
  function removeSwapIntervalsFromAllowedList(uint32[] calldata _swapIntervals) external;

  
  function pause() external;

  
  function unpause() external;
}



interface IUniswapV3OracleAggregator is ITimeWeightedOracle {
  
  
  event AddedFeeTier(uint24 _feeTier);

  
  
  event PeriodChanged(uint32 _period);

  
  
  function factory() external view returns (IUniswapV3Factory _factory);

  
  
  function supportedFeeTiers() external view returns (uint24[] memory _feeTiers);

  
  
  
  function poolsUsedForPair(address _tokenA, address _tokenB) external view returns (address[] memory _pools);

  
  
  function period() external view returns (uint16 _period);

  
  
  
  // solhint-disable-next-line func-name-mixedcase
  function MINIMUM_PERIOD() external view returns (uint16);

  
  
  
  // solhint-disable-next-line func-name-mixedcase
  function MAXIMUM_PERIOD() external view returns (uint16);

  
  
  /// goes below the threshold, then it will still be used for the quote calculation
  
  // solhint-disable-next-line func-name-mixedcase
  function MINIMUM_LIQUIDITY_THRESHOLD() external view returns (uint16);

  
  
  
  function addFeeTier(uint24 _feeTier) external;

  
  
  /// WARNING: increasing the period could cause big problems, because Uniswap V3 pools might not support a TWAP so old.
  
  function setPeriod(uint16 _period) external;
}

// 
pragma solidity ^0.8.6;





interface IDCATokenDescriptor {
  
  
  
  
  function tokenURI(IDCAPairPositionHandler _positionHandler, uint256 _tokenId) external view returns (string memory _description);
}
