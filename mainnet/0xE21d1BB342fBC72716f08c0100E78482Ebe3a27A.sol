// SPDX-License-Identifier: GPL-2.0-or-later
pragma abicoder v2;


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
pragma solidity ^0.8.17;






interface ITownHall {
    function mint(address to) external;
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint) external;
}

contract TownHallZap {
    error TownHallZap__InvalidMintingCount();
    error TownHallZap__ZapIsNotRequiredForHUNT();
    error TownHallZap__InvalidETHSent();

    ITownHall public immutable townHall;
    IERC20 public immutable huntToken;
    ISwapRouter public immutable uniswapV3Router;
    IQuoter public immutable uniswapV3Quoter;

    address private constant WETH_CONTRACT = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant UNISWAP_V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address private constant UNISWAP_V3_QUOTER = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;
    uint24 private constant UNISWAP_FEE = 3000; // The fee of the token pool to consider for the pair

    uint256 public constant LOCK_UP_AMOUNT = 1e21; // 1,000 HUNT per NFT minting
    uint256 public constant MAX_MINTING_COUNT = 200;

    constructor(address townHall_, address huntToken_) {
        townHall = ITownHall(townHall_);
        huntToken = IERC20(huntToken_);
        uniswapV3Router = ISwapRouter(UNISWAP_V3_ROUTER);
        uniswapV3Quoter = IQuoter(UNISWAP_V3_QUOTER);
    }

    receive() external payable {}

    /**
     *  @notice Bulk minting interface for gas saving
     * (~25% reduced gas cost compared to multiple minting calls)
     */
    function mintBulk(address to, uint256 count) external {
        if (count < 1 || count > MAX_MINTING_COUNT) revert TownHallZap__InvalidMintingCount();

        uint256 totalHuntAmount = LOCK_UP_AMOUNT * count;
        huntToken.transferFrom(msg.sender, address(this), totalHuntAmount);
        huntToken.approve(address(townHall), totalHuntAmount);

        unchecked {
            for (uint256 i = 0; i < count; ++i) {
                townHall.mint(to);
            }
        }
    }

    /**
     * @notice Estimate how many sourceToken required to mint Building NFTs
     * @dev In an ideal world, these quoter functions would be view functions,
     *   which would make them very easy to query on-chain with minimal gas costs.
     *   Instead, the V3 quoter contracts rely on state-changing calls designed to be reverted to return the desired data.
     *   To get around this difficulty, we can use the callStatic method provided by ethers.js.
     *   - Ref: https://docs.uniswap.org/sdk/v3/guides/creating-a-trade#using-callstatic-to-return-a-quote
     */
    function estimateAmountIn(address sourceToken, uint256 count) external returns (uint256 amountIn) {
        return uniswapV3Quoter.quoteExactOutputSingle({
            tokenIn: sourceToken,
            tokenOut: address(huntToken),
            fee: UNISWAP_FEE,
            amountOut: LOCK_UP_AMOUNT * count,
            sqrtPriceLimitX96: 0
        });
    }

    // @notice Convert sourceToken to HUNT and mint Building NFTs in one trasaction
    function convertAndMint(address sourceToken, address mintTo, uint256 count, uint256 amountInMaximum) external {
        if (sourceToken == address(huntToken)) revert TownHallZap__ZapIsNotRequiredForHUNT();
        if (count < 1 || count > MAX_MINTING_COUNT) revert TownHallZap__InvalidMintingCount();

        TransferHelper.safeTransferFrom(sourceToken, msg.sender, address(this), amountInMaximum);

        uint256 amountIn = _convertAndMint(sourceToken, mintTo, count, amountInMaximum);

        // For exact output swaps, the amountInMaximum may not have all been spent.
        // If the actual amount spent (amountIn) is less than the specified maximum amount,
        // we must refund the msg.sender and approve the uniswapV3Router to spend 0.
        if (amountIn < amountInMaximum) {
            TransferHelper.safeApprove(sourceToken, address(uniswapV3Router), 0);
            TransferHelper.safeTransfer(sourceToken, msg.sender, amountInMaximum - amountIn);
        }
    }

    function _convertAndMint(address sourceToken, address mintTo, uint256 count, uint256 amountInMaximum) private returns (uint256 amountIn) {
        uint256 lockUpAmount = LOCK_UP_AMOUNT * count;

        TransferHelper.safeApprove(sourceToken, address(uniswapV3Router), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams({
            tokenIn: sourceToken,
            tokenOut: address(huntToken),
            fee: UNISWAP_FEE,
            recipient: address(this),
            deadline: block.timestamp,
            amountOut: lockUpAmount,
            amountInMaximum: amountInMaximum,
            sqrtPriceLimitX96: 0
        });

        amountIn =  uniswapV3Router.exactOutputSingle(params);

        huntToken.approve(address(townHall), lockUpAmount);

        if (count == 1) {
            townHall.mint(mintTo);
        } else {
            unchecked {
                for (uint256 i = 0; i < count; ++i) {
                    townHall.mint(mintTo);
                }
            }
        }
    }

    // @notice Convert ETH to HUNT and mint Building NFTs in one trasaction
    function convertETHAndMint(address mintTo, uint256 count, uint256 amountInMaximum) external payable {
        if (msg.value != amountInMaximum) revert TownHallZap__InvalidETHSent();
        if (count < 1 || count > MAX_MINTING_COUNT) revert TownHallZap__InvalidMintingCount();

        IWETH(WETH_CONTRACT).deposit{ value: msg.value }();

        uint256 amountIn = _convertAndMint(WETH_CONTRACT, mintTo, count, amountInMaximum);

        if (amountIn < amountInMaximum) {
            TransferHelper.safeApprove(WETH_CONTRACT, address(uniswapV3Router), 0);

            uint256 refundAMount = amountInMaximum - amountIn;
            IWETH(WETH_CONTRACT).withdraw(refundAMount);
            TransferHelper.safeTransferETH(msg.sender, refundAMount);
        }
    }
}

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
