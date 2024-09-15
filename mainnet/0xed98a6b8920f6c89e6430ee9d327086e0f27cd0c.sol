// SPDX-License-Identifier: MIT
pragma abicoder v2;


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
}// 

pragma solidity >=0.8.0 <0.9.0;





contract RenBtcEthConverterMainnet {
  ICurveInt128 rencrv = ICurveInt128(0x93054188d876f558f4a66B2EF1d97d16eDf0895B);
  address constant renbtc = address(0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D);
  address constant wbtc = address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
  address constant weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  ISwapRouter constant router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
  uint256 constant MaxUintApprove = type(uint256).max;

  constructor() {}

  function initialize() public {
    bool success;
    (success, ) = renbtc.call(abi.encodeWithSelector(IERC20.approve.selector, address(rencrv), MaxUintApprove));
    require(success, "!renbtc");
    (success, ) = wbtc.call(abi.encodeWithSelector(IERC20.approve.selector, address(router), MaxUintApprove));
    require(success, "!wbtc");
    (success, ) = weth.call(abi.encodeWithSelector(IERC20.approve.selector, address(router), MaxUintApprove));
    require(success, "!weth");
  }

  function convertToEth(uint256 minOut) public returns (uint256 amount) {
    uint256 wbtcAmount = IERC20(wbtc).balanceOf(address(this));
    //minout encoded to 1 because of intermediate call
    (bool success, ) = address(rencrv).call(
      abi.encodeWithSelector(rencrv.exchange.selector, 0, 1, IERC20(renbtc).balanceOf(address(this)), 1)
    );
    require(success, "!curve");
    wbtcAmount = IERC20(wbtc).balanceOf(address(this)) - wbtcAmount;
    bytes memory path = abi.encodePacked(wbtc, uint24(500), weth);
    ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
      recipient: address(this),
      deadline: block.timestamp + 1,
      amountIn: wbtcAmount,
      amountOutMinimum: minOut,
      path: path
    });
    amount = router.exactInput(params);
    IWETH(weth).withdraw(amount);
    address payable sender = payable(msg.sender);
    sender.transfer(amount);
  }

  receive() external payable {
    // no-op
  }
}

// 

pragma solidity >=0.7.0;

interface ICurveInt128 {
  function get_dy(
    int128,
    int128,
    uint256
  ) external view returns (uint256);

  function get_dy_underlying(
    int128,
    int128,
    uint256
  ) external view returns (uint256);

  function exchange(
    int128,
    int128,
    uint256,
    uint256
  ) external returns (uint256);

  function exchange_underlying(
    int128,
    int128,
    uint256,
    uint256
  ) external returns (uint256);

  function coins(int128) external view returns (address);
}

// 

pragma solidity >=0.5.0 <0.9.0;



interface IWETH is IERC20 {
  function withdraw(uint256) external;
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
