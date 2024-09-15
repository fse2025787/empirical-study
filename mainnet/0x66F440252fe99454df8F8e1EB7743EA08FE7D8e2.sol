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

pragma solidity 0.8.13;


contract LibCorrectSwapV1 {
    // Exact search for supported function signatures
    bytes4 private constant _FUNC1 = bytes4(keccak256('swapExactETHForTokens(uint256,address[],address,uint256)'));
    bytes4 private constant _FUNC2 = bytes4(keccak256('swapExactAVAXForTokens(uint256,address[],address,uint256)'));
    bytes4 private constant _FUNC3 = bytes4(keccak256('swapExactTokensForETH(uint256,uint256,address[],address,uint256)'));
    bytes4 private constant _FUNC4 = bytes4(keccak256('swapExactTokensForAVAX(uint256,uint256,address[],address,uint256)'));
    bytes4 private constant _FUNC5 = bytes4(keccak256('swapExactTokensForTokens(uint256,uint256,address[],address,uint256)'));
    bytes4 private constant _FUNC6 = ISwapRouter.exactInput.selector;

    //---------------------------------------------------------------------------
    // External Method

    // @dev Correct input of destination chain swapData
    function correctSwap(bytes calldata _data, uint256 _amount)
        external
        view
        returns (bytes memory)
    {
        bytes4 sig = bytes4(_data[:4]);
        if (sig == _FUNC1) {
            return _data;
        } else if (sig == _FUNC2) {
            return _data;
        } else if (sig == _FUNC3) {
            return tryBasicCorrectSwap(_data, _amount);
        } else if (sig == _FUNC4) {
            return tryBasicCorrectSwap(_data, _amount);
        } else if (sig == _FUNC5) {
            return tryBasicCorrectSwap(_data, _amount);
        } else if (sig == _FUNC6) {
            return tryExactInput(_data, _amount);
        }
        // fuzzy matching
        return tryBasicCorrectSwap(_data, _amount);
    }

    function tryBasicCorrectSwap(bytes calldata _data, uint256 _amount)
        public
        view
        returns (bytes memory)
    {
        try this.basicCorrectSwap(_data, _amount) returns (bytes memory _result){
            return _result;
        }catch{
            revert("basicCorrectSwap fail!");
        }
    }

    function basicCorrectSwap(bytes calldata _data, uint256 _amount)
        external
        pure
        returns (bytes memory)
    {
        (
        ,
        uint256 _amountOutMin,
        address[] memory _path,
        address _to,
        uint256 _deadline
        ) = abi.decode(_data[4 :], (uint256, uint256, address[], address, uint256));

        return abi.encodeWithSelector(
            bytes4(_data[:4]),
            _amount,
            _amountOutMin,
            _path,
            _to,
            _deadline
        );
    }

    function tryExactInput(bytes calldata _data, uint256 _amount)
        public
        view
        returns (bytes memory)
    {
        try this.exactInput(_data, _amount) returns (bytes memory _result){
            return _result;
        }catch{
            revert("exactInput fail!");
        }
    }

    function exactInput(bytes calldata _data, uint256 _amount)
        external
        pure
        returns (bytes memory)
    {
        ISwapRouter.ExactInputParams memory params = abi.decode(_data[4 :], (ISwapRouter.ExactInputParams));
        params.amountIn = _amount;

        return abi.encodeWithSelector(
            bytes4(_data[:4]),
            params
        );
    }
}

// 
pragma solidity >=0.7.5;






interface ISwapRouter is IUniswapV3SwapCallback {

    function WETH9() external view returns (address);

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
