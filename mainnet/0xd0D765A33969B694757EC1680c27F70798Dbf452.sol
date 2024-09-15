// SPDX-License-Identifier: GPL-2.0-or-later
pragma abicoder v2;


// 
pragma solidity >=0.5.0;



interface IPeripheryImmutableState {
    
    function factory() external view returns (address);

    
    function WETH9() external view returns (address);
}

// 
pragma solidity >=0.7.6 <0.9.0;


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
pragma solidity >=0.7.5;



interface IPeripheryPayments {
    
    
    
    
    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;

    
    
    /// that use ether for the input amount
    function refundETH() external payable;

    
    
    
    
    
    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;
}

// 
pragma solidity =0.7.6;





abstract contract PeripheryImmutableState is IPeripheryImmutableState {
    
    address public immutable override factory;
    
    address public immutable override WETH9;

    constructor(address _factory, address _WETH9) {
        factory = _factory;
        WETH9 = _WETH9;
    }
}

// 
pragma solidity >=0.7.6 <0.9.0;



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
abstract contract OwnableSwapper is Context {

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

// 
pragma solidity >=0.5.0;



interface IUniswapV3FlashCallback {
    
    
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    
    
    
    function uniswapV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external;
}

// 
pragma solidity >=0.7.5;










abstract contract PeripheryPayments is IPeripheryPayments, PeripheryImmutableState {
    receive() external payable {
        require(msg.sender == WETH9, 'Not WETH9');
    }

    
    function unwrapWETH9(uint256 amountMinimum, address recipient) public payable override {
        uint256 balanceWETH9 = IWETH9(WETH9).balanceOf(address(this));
        require(balanceWETH9 >= amountMinimum, 'Insufficient WETH9');

        if (balanceWETH9 > 0) {
            IWETH9(WETH9).withdraw(balanceWETH9);
            TransferHelper.safeTransferETH(recipient, balanceWETH9);
        }
    }

    
    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) public payable override {
        uint256 balanceToken = IERC20(token).balanceOf(address(this));
        require(balanceToken >= amountMinimum, 'Insufficient token');

        if (balanceToken > 0) {
            TransferHelper.safeTransfer(token, recipient, balanceToken);
        }
    }

    
    function refundETH() external payable override {
        if (address(this).balance > 0) TransferHelper.safeTransferETH(msg.sender, address(this).balance);
    }

    
    
    
    
    function pay(
        address token,
        address payer,
        address recipient,
        uint256 value
    ) internal {
        if (token == WETH9 && address(this).balance >= value) {
            // pay with WETH9
            IWETH9(WETH9).deposit{value: value}(); // wrap only what is needed to pay
            IWETH9(WETH9).transfer(recipient, value);
        } else if (payer == address(this)) {
            // pay with tokens already in the contract (for the exact input multihop case)
            TransferHelper.safeTransfer(token, recipient, value);
        } else {
            // pull payment
            TransferHelper.safeTransferFrom(token, payer, recipient, value);
        }
    }
}

// 

pragma solidity ^0.7.0;

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
pragma solidity >=0.5.0;



interface IUniswapV3PoolImmutables {
    
    
    function factory() external view returns (address);

    
    
    function token0() external view returns (address);

    
    
    function token1() external view returns (address);

    
    
    function fee() external view returns (uint24);

    
    
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    
    function tickSpacing() external view returns (int24);

    
    
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    
    function maxLiquidityPerTick() external view returns (uint128);
}

// 
pragma solidity >=0.5.0;



/// per transaction
interface IUniswapV3PoolState {
    
    /// when accessed externally.
    
    /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// observationIndex The index of the last oracle observation that was written,
    /// observationCardinality The current maximum number of observations stored in the pool,
    /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    
    
    function feeGrowthGlobal0X128() external view returns (uint256);

    
    
    function feeGrowthGlobal1X128() external view returns (uint256);

    
    
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    
    
    function liquidity() external view returns (uint128);

    
    
    
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    
    
    
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    
    
    
    /// ago, rather than at a specific index in the array.
    
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}

// 
pragma solidity >=0.5.0;



/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    
    
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    
    
    
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    
    
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    
    
    
    
    
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolActions {
    
    
    
    function initialize(uint160 sqrtPriceX96) external;

    
    
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    
    
    
    
    
    
    
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    
    
    
    
    
    
    
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    
    
    
    
    
    
    
    
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    
    
    
    
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    
    
    
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    
    
    
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    
    
    
    
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    
    
    /// the input observationCardinalityNext.
    
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolOwnerActions {
    
    
    
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    
    
    
    
    
    
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolEvents {
    
    
    
    
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    
    
    
    
    
    
    
    
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    
    
    
    
    
    
    
    
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    
    
    
    
    
    
    
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    
    
    /// just before a mint/swap/burn.
    
    
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    
    
    
    
    
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    
    
    
    
    
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}

contract Swapper is OwnableSwapper{

    ISwapRouter public immutable swapRouter; 
    IWallet public wallet; 

    constructor(ISwapRouter _swapRouter,
                address _factory,
                address _WETH9,
                IWallet _wallet
            ) {
        swapRouter = _swapRouter;
        _transferOwnership(msg.sender);
        _setWallet(_wallet);
    }

    function _setWallet(IWallet _add_wallet) internal onlyOwner{
        wallet = _add_wallet;
    }

    function multiHopSwap(uint256 _amountIn, uint256 _amountOut,
                         bytes calldata _path, address _recipient,
                         uint256 _deadLine, bool _isExactInput
                        ) external returns(uint256 amount){
        
        
        if(_isExactInput){
            amount = swapRouter.exactInput(
                ISwapRouter.ExactInputParams({
                    path: _path,
                    recipient: _recipient,
                    deadline: _deadLine,
                    amountIn: _amountIn,
                    amountOutMinimum: _amountOut
                })
            );

        } else{
            amount = swapRouter.exactOutput(
                ISwapRouter.ExactOutputParams({
                    path: _path,
                    recipient: _recipient,
                    deadline: _deadLine,
                    amountOut: _amountOut,
                    amountInMaximum: _amountIn
                })
            );
        }
    }

    function multiHopSwap(bytes calldata _multiHopSwapDatas) public onlyOwner returns (uint256 amount) {
        
        ISwapper.OneTriangularFlashParams memory multiHopSwapDatas = abi.decode(_multiHopSwapDatas, (ISwapper.OneTriangularFlashParams));
        uint256 deadLine = (multiHopSwapDatas.deadLine == 0)? block.timestamp: multiHopSwapDatas.deadLine;

        wallet.approveToSpend(IERC20(multiHopSwapDatas.tokenIn), multiHopSwapDatas.amountIn);
        TransferHelper.safeTransferFrom(multiHopSwapDatas.tokenIn, address(wallet), address(this), multiHopSwapDatas.amountIn);
        TransferHelper.safeApprove(multiHopSwapDatas.tokenIn, address(swapRouter), multiHopSwapDatas.amountIn);

        if(multiHopSwapDatas.isExactInput == true){

            amount = this.multiHopSwap(multiHopSwapDatas.amountIn,
                                    multiHopSwapDatas.amountOut,
                                    abi.encodePacked(multiHopSwapDatas.path.token1,
                                                     multiHopSwapDatas.path.fee1,
                                                     multiHopSwapDatas.path.token2,
                                                     multiHopSwapDatas.path.fee2,
                                                     multiHopSwapDatas.path.token3,
                                                     multiHopSwapDatas.path.fee3,
                                                     multiHopSwapDatas.path.token4
                                                     ),
                                    address(wallet), deadLine,
                                    multiHopSwapDatas.isExactInput
                                );
            wallet.setErc20Balances(multiHopSwapDatas.tokenIn, amount);    

        } else{

            amount = this.multiHopSwap(multiHopSwapDatas.amountIn,
                                  multiHopSwapDatas.amountOut,
                                  abi.encodePacked(multiHopSwapDatas.path.token1,
                                                     multiHopSwapDatas.path.fee1,
                                                     multiHopSwapDatas.path.token2,
                                                     multiHopSwapDatas.path.fee2,
                                                     multiHopSwapDatas.path.token3,
                                                     multiHopSwapDatas.path.fee3,
                                                     multiHopSwapDatas.path.token4
                                                     ),
                                  address(wallet), deadLine,
                                  multiHopSwapDatas.isExactInput
                                );
            wallet.setErc20Balances(multiHopSwapDatas.tokenIn, amount);
            // If the swap did not require the full amountInMaximum to achieve the exact amountOut then we refund msg.sender and approve the router to spend 0.
            if (amount < multiHopSwapDatas.amountIn) {
                TransferHelper.safeApprove(multiHopSwapDatas.tokenIn, address(swapRouter), multiHopSwapDatas.amountIn - amount);
                TransferHelper.safeTransferFrom(multiHopSwapDatas.tokenIn, address(this), address(wallet), multiHopSwapDatas.amountIn - amount);
                wallet.setErc20Balances(multiHopSwapDatas.tokenIn, multiHopSwapDatas.amountIn - amount);
            }


        }
    }

    function oneHopSwap(address _tokenIn, address _tokenOut,
                uint24 _fee, address _recipient,
                uint256 _deadLine, uint256 _amountIn,
                uint256 _amountOutMinimum, uint160 _sqrtPriceLimitX96,
                bool _isExactInput
    ) internal returns(uint256 amount){

        if(_isExactInput){
            amount = swapRouter.exactInputSingle(
                ISwapRouter.ExactInputSingleParams({
                        tokenIn: _tokenIn,
                        tokenOut: _tokenOut,
                        fee: _fee,
                        recipient: _recipient,
                        deadline: _deadLine,
                        amountIn: _amountIn,
                        amountOutMinimum: _amountOutMinimum,
                        sqrtPriceLimitX96: _sqrtPriceLimitX96
                })
            );
        } else{
            amount = swapRouter.exactOutputSingle(            
                ISwapRouter.ExactOutputSingleParams({
                    tokenIn: _tokenIn,
                    tokenOut: _tokenOut,
                    fee: _fee,
                    recipient: _recipient,
                    deadline: _deadLine,
                    amountOut: _amountIn,
                    amountInMaximum: _amountOutMinimum,
                    sqrtPriceLimitX96: _sqrtPriceLimitX96
                })
            );
        }
    }

    function oneHopSwap(bytes calldata _oneHopSwap) public onlyOwner returns (address, uint256) {
        
        ISwapper.oneHopSwapParams memory _oneHopSwapDatas = abi.decode(_oneHopSwap, (ISwapper.oneHopSwapParams));

        wallet.approveToSpend(IERC20(_oneHopSwapDatas.tokenIn), _oneHopSwapDatas.amountIn);
        TransferHelper.safeTransferFrom(_oneHopSwapDatas.tokenIn, address(wallet), address(this), _oneHopSwapDatas.amountIn);
        TransferHelper.safeApprove(_oneHopSwapDatas.tokenIn, address(swapRouter), _oneHopSwapDatas.amountIn);
        
        uint256 deadLine = (_oneHopSwapDatas.deadline == 0)?block.timestamp:_oneHopSwapDatas.deadline;

        if(_oneHopSwapDatas.isExactInput){
            uint256 amountOut = oneHopSwap(_oneHopSwapDatas.tokenIn, _oneHopSwapDatas.tokenOut, _oneHopSwapDatas.fee,
                                address(wallet), deadLine, _oneHopSwapDatas.amountIn,
                                _oneHopSwapDatas.amountOut, _oneHopSwapDatas.sqrtPriceLimitX96, _oneHopSwapDatas.isExactInput);

            uint256 resp = wallet.setErc20Balances(_oneHopSwapDatas.tokenOut, amountOut);
            return  (_oneHopSwapDatas.tokenOut, resp);
        } else{
            uint256 amountIn = oneHopSwap(_oneHopSwapDatas.tokenIn, _oneHopSwapDatas.tokenOut, _oneHopSwapDatas.fee,
                            address(wallet), deadLine, _oneHopSwapDatas.amountIn,
                            _oneHopSwapDatas.amountOut, _oneHopSwapDatas.sqrtPriceLimitX96, _oneHopSwapDatas.isExactInput);
            
            wallet.setErc20Balances(_oneHopSwapDatas.tokenOut, amountIn);
            if (amountIn < _oneHopSwapDatas.amountIn) {
                TransferHelper.safeApprove(_oneHopSwapDatas.tokenIn, address(swapRouter), 0);
                TransferHelper.safeTransfer(_oneHopSwapDatas.tokenIn, address(wallet), _oneHopSwapDatas.amountIn - amountIn);
                wallet.setErc20Balances(_oneHopSwapDatas.tokenOut, _oneHopSwapDatas.amountIn - amountIn);  
            }
            return (_oneHopSwapDatas.tokenIn, amountIn);
        }
    }

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
pragma solidity =0.7.6;









contract FlashSwapper is Swapper, IUniswapV3FlashCallback, PeripheryPayments {
    
    using LowGasSafeMath for uint256;
    using LowGasSafeMath for int256;

    constructor(
        ISwapRouter _swapRouter,
        address _factory,
        address _WETH9,
        IWallet _wallet
    ) PeripheryImmutableState(_factory, _WETH9) Swapper(_swapRouter, _factory, _WETH9, _wallet){
    }
    
    function tArb(ISwapper.TriangularFlashParams calldata _params) public returns(uint256 amountOut0, uint256 amountOut1){
        
        TransferHelper.safeApprove(_params.path1.token1, address(swapRouter), _params.flashTradeParams.amount0);   
        uint256 deadLine = (_params.flashTradeParams.deadLine == 0)? block.timestamp: _params.flashTradeParams.deadLine;
        amountOut1 = this.multiHopSwap(
            _params.flashTradeParams.amount0,
            _params.flashTradeParams.amount0Min,
            abi.encodePacked(_params.path1.token1,
                             _params.path1.fee1,
                             _params.path1.token2,
                             _params.path1.fee2,
                             _params.path1.token3,
                             _params.path1.fee3,
                             _params.path1.token4
                             ),
            address(this),
            deadLine,
            _params.flashTradeParams.isExactInput
        );
        
        TransferHelper.safeApprove(_params.path2.token1, address(swapRouter), _params.flashTradeParams.amount1);   
        amountOut0 = this.multiHopSwap(
            _params.flashTradeParams.amount1,
            _params.flashTradeParams.amount1Min,
            abi.encodePacked(_params.path2.token1,
                             _params.path2.fee1,
                             _params.path2.token2,
                             _params.path2.fee2,
                             _params.path2.token3,
                             _params.path2.fee3,
                             _params.path2.token4
                            ),
            address(this),
            deadLine,
            _params.flashTradeParams.isExactInput
        );
    
    }

    function Payer(ISwapper.PayerParams calldata _datas) public{

        // pay the required amounts back to the pair
        if (_datas.amount0Min > 0) pay(_datas.token0, address(this), msg.sender, _datas.amount0Min);
        if (_datas.amount1Min > 0) pay(_datas.token1, address(this), msg.sender, _datas.amount1Min);

        // if profitable pay profits to wallet
        if (_datas.amountOut0 > _datas.amount0Min) {
            uint256 profit0 = _datas.amountOut0 - _datas.amount0Min;
            pay(_datas.token0, address(this), address(wallet), profit0);
        }
        if (_datas.amountOut1 > _datas.amount1Min) {
            uint256 profit1 = _datas.amountOut1 - _datas.amount1Min;
            pay(_datas.token1, address(this), address(wallet), profit1);
        }
    }

    function sArb(ISwapper.OneSimpleFlashParams calldata _datas) public returns(uint256 amountOut0){

        uint256 deadLine = (_datas.simpleFlashTradeParams.deadLine == 0)?block.timestamp:_datas.simpleFlashTradeParams.deadLine;

        TransferHelper.safeApprove(_datas.pool.token0,
                                    address(swapRouter), _datas.simpleFlashTradeParams.amount0
                                );

        amountOut0 = oneHopSwap(_datas.pool.token0, _datas.pool.token1,
                                    _datas.pool.fee, address(this), deadLine, _datas.simpleFlashTradeParams.amount0,
                                    _datas.simpleFlashTradeParams.amountOutMin, _datas.sqrtPriceLimitX96,
                                    _datas.simpleFlashTradeParams.isExactInput
                                );

    }

    
    
    
    
    
    function uniswapV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external override {

        if(data.length == 288){ // In case of simple arbitrage
            ISwapper.OneSimpleFlashParams memory decoded = abi.decode(data, (ISwapper.OneSimpleFlashParams));
            uint256 amountOut0 = this.sArb(decoded);
            uint256 fee = (fee0 > 0)?fee0:fee1;

            this.Payer(ISwapper.PayerParams({
                    token0: decoded.pool.token0,
                    token1: decoded.pool.token1,
                    amount0Min: LowGasSafeMath.add(decoded.simpleFlashTradeParams.amountOutMin, fee),
                    amountOut0: amountOut0,
                    amount1Min: 0,
                    amountOut1: 0
                })
            );
        
        } else if(data.length == 768){ // In case of triangular arbitrage
        
            ISwapper.TriangularFlashParams memory decoded = abi.decode(data, (ISwapper.TriangularFlashParams));

            (uint256 amountOut0, uint256 amountOut1) = this.tArb(decoded);
            
            this.Payer(ISwapper.PayerParams({
                    token0: decoded.pool.token0,
                    token1: decoded.pool.token1,
                    amount0Min: LowGasSafeMath.add(decoded.flashTradeParams.amount0Min, fee0),
                    amountOut0: amountOut0,
                    amount1Min: LowGasSafeMath.add(decoded.flashTradeParams.amount1Min, fee1),
                    amountOut1: amountOut1
                })
            );
        }
    }

    
    
    function initFlash(bytes calldata _datas) public{

        if(_datas.length == 288){ // In case of one simple arbitrage
            ISwapper.OneSimpleFlashParams memory datas = abi.decode(_datas, (ISwapper.OneSimpleFlashParams));
            IUniswapV3Pool pool = IUniswapV3Pool(datas.pool.poolId);
            
            pool.flash(address(this), 0, datas.simpleFlashTradeParams.amount0, _datas);
        
        } else if(_datas.length == 512){ // In case of double simple arbitrage

            ISwapper.DbSimpleFlashParams memory datas = abi.decode(_datas, (ISwapper.DbSimpleFlashParams));
            
            IUniswapV3Pool pool1 = IUniswapV3Pool(datas.pool1.poolId);
            pool1.flash(
                     address(this),
                     0,
                     datas.flashTradeParams.amount0,
                     abi.encode(
                        ISwapper.OneSimpleFlashParams({
                                simpleFlashTradeParams: ISwapper.SimpleFlashTradeParams({
                                amount0: datas.flashTradeParams.amount0,
                                amountOutMin: datas.flashTradeParams.amount0Min,
                                deadLine: datas.flashTradeParams.deadLine,
                                isExactInput: datas.flashTradeParams.isExactInput
                            }),
                            pool: ISwapper.PoolParams({
                                poolId: datas.pool1.poolId,
                                token0: datas.pool1.token0,
                                token1: datas.pool1.token1,
                                fee: datas.pool1.fee
                            }),
                            sqrtPriceLimitX96: datas.sqrtPriceLimitX96_1
                        })
                     ));

            IUniswapV3Pool pool2 = IUniswapV3Pool(datas.pool2.poolId);
            pool2.flash(
                     address(this),
                     datas.flashTradeParams.amount1,
                     0,
                     abi.encode(
                        ISwapper.OneSimpleFlashParams({
                                simpleFlashTradeParams: ISwapper.SimpleFlashTradeParams({
                                amount0: datas.flashTradeParams.amount1,
                                amountOutMin: datas.flashTradeParams.amount1Min,
                                deadLine: datas.flashTradeParams.deadLine,
                                isExactInput: datas.flashTradeParams.isExactInput
                            }),
                            pool: ISwapper.PoolParams({
                                poolId: datas.pool2.poolId,
                                token0: datas.pool2.token0,
                                token1: datas.pool2.token1,
                                fee: datas.pool2.fee
                            }),
                            sqrtPriceLimitX96: datas.sqrtPriceLimitX96_2
                        })
                     ));
        } else if(_datas.length == 768){ // In case of triangular arbitrage
            ISwapper.TriangularFlashParams memory datas = abi.decode(_datas, (ISwapper.TriangularFlashParams));
            IUniswapV3Pool pool = IUniswapV3Pool(datas.pool.poolId);
            pool.flash(address(this), datas.flashTradeParams.amount0, datas.flashTradeParams.amount1, _datas);
        }
    }

    function swapManyInOneTxn(bytes[] calldata _datas, uint256[] calldata _types) public {
        
        for(uint256 it=0; it<_datas.length; it++){
            if(_types[it] == 30){ // In case of flash swap
                initFlash(_datas[it]);
            } else if(_types[it] == 40){ // In case of single swap
                oneHopSwap(_datas[it]);
            } else if(_types[it] == 50){ // In case of multihop swap
                multiHopSwap(_datas[it]);
            }
        }
    }

}

// 
pragma solidity >=0.7.0;



library LowGasSafeMath {
    
    
    
    
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    
    
    
    
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    
    
    
    
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    
    
    
    
    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x + y) >= x == (y >= 0));
    }

    
    
    
    
    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x - y) <= x == (y >= 0));
    }
}

// 
pragma solidity =0.7.6;




interface IWETH9 is IERC20 {
    
    function deposit() external payable;

    
    function withdraw(uint256) external;
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
pragma solidity =0.7.6;





library CallbackValidation {
    
    
    
    
    
    
    function verifyCallback(
        address factory,
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal view returns (IUniswapV3Pool pool) {
        return verifyCallback(factory, PoolAddress.getPoolKey(tokenA, tokenB, fee));
    }

    
    
    
    
    function verifyCallback(address factory, PoolAddress.PoolKey memory poolKey)
        internal
        view
        returns (IUniswapV3Pool pool)
    {
        pool = IUniswapV3Pool(PoolAddress.computeAddress(factory, poolKey));
        require(msg.sender == address(pool));
    }
}

// 
pragma solidity >=0.5.0;










/// to the ERC20 specification

interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}

// 
pragma solidity >=0.5.0;


library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    
    
    
    
    
    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    
    
    
    
    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encode(key.token0, key.token1, key.fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            )
        );
    }
}

// 
pragma solidity =0.7.6;
 // compute pool address


interface ISwapper{

    struct Path{
        address token1;
        uint24 fee1;
        address token2;
        uint24 fee2;
        address token3;
        uint24 fee3;
        address token4;
    }

    struct PayerParams{
        address token0;
        address token1;
        uint256 amount0Min;
        uint256 amountOut0;
        uint256 amount1Min;
        uint256 amountOut1;
    }

    struct PoolParams{
        address poolId;
        address token0;
        address token1;
        uint24 fee;
    }

    struct SimpleFlashTradeParams{
        uint256 amount0;
        uint256 amountOutMin;
        uint256 deadLine;
        bool isExactInput;
    }

    struct OneSimpleFlashParams{
        SimpleFlashTradeParams simpleFlashTradeParams;
        PoolParams pool;
        uint160 sqrtPriceLimitX96;
    }

    struct FlashTradeParams{
        uint256 amount0;
        uint256 amount1;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadLine;
        bool isExactInput;
    }
    
    struct DbSimpleFlashParams {
        FlashTradeParams flashTradeParams;
        PoolParams pool1;
        PoolParams pool2;
        uint160 sqrtPriceLimitX96_1;
        uint160 sqrtPriceLimitX96_2;
    }

    struct TriangularFlashParams{
        PoolParams pool;
        FlashTradeParams flashTradeParams;
        Path path1;
        Path path2;
    }

    struct OneTriangularFlashParams{
        address tokenIn;
        uint256 amountIn;
        uint256 amountOut;
        uint256 deadLine;
        bool isExactInput;
        Path path;
    }

    struct oneHopSwapParams{
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOut;
        uint160 sqrtPriceLimitX96;
        bool isExactInput;
    }


}

// 
pragma solidity 0.7.6;







interface IWallet{

    function ERC20_Balances(address _erc20Token) external returns(uint256);
    function approveToSpend(IERC20 _erc20Token, uint256 _amount) external returns(bool);
    function setErc20Balances(address _erc20Token, uint256 _amount) external returns(uint256);
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
