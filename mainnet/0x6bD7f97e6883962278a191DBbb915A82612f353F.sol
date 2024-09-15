// SPDX-License-Identifier: MIT

// 

pragma solidity ^0.8.15;


contract UniSwapProxy {

    // Uniswap SwapRouter02
    // Ethereum: 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45
    // Rinkeby: 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45
    // Goerli: 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45
    address public constant SwapRouter02 = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address payableAmount;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    
    
    /// and swap the entire amount, enabling contracts to send tokens before calling this function.
    function exactInputSingle(ExactInputSingleParams calldata /* params */) external payable {
        assembly {
            calldatacopy(0, 0, calldatasize())
            mstore(0x64, address())
            if iszero(call(gas(), SwapRouter02, calldataload(0x64), 0, calldatasize(), 0, 0)) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }

    struct ExactInputParams {
        bytes path;
        address payableAmount;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    
    
    /// and swap the entire amount, enabling contracts to send tokens before calling this function.
    function exactInput(ExactInputParams calldata /* params */) external payable {
        assembly {
            calldatacopy(0, 0, calldatasize())
            mstore(0x24, address())
            if iszero(call(gas(), SwapRouter02, calldataload(0x24), 0, calldatasize(), 0, 0)) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address payableAmount;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    
    /// that may remain in the router after the swap.
    function exactOutputSingle(ExactOutputSingleParams calldata /* params */) external payable {
        assembly {
            calldatacopy(0, 0, calldatasize())
            mstore(0x64, address())
            if iszero(call(gas(), SwapRouter02, calldataload(0x64), 0, calldatasize(), 0, 0)) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }

    struct ExactOutputParams {
        bytes path;
        address payableAmount;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    
    /// that may remain in the router after the swap.
    function exactOutput(ExactOutputParams calldata /* params */) external payable {
        assembly {
            calldatacopy(0, 0, calldatasize())
            mstore(0x24, address())
            if iszero(call(gas(), SwapRouter02, calldataload(0x24), 0, calldatasize(), 0, 0)) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }
}