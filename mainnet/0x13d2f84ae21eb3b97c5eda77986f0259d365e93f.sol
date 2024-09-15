// SPDX-License-Identifier: Apache-2.0-or-later
pragma abicoder v2; // in 0.8 solc this is default behaviour

// 
/*

 Copyright 2021 Rigo Intl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

// solhint-disable-next-line
pragma solidity 0.7.6;







interface Token {

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _who) external view returns (uint256);
}


interface IWETH9 {
    
    function deposit() external payable;

    
    function withdraw(uint256) external;
}

contract AUniswapV3 {
    
    using Path for bytes;
    
    address payable immutable private UNISWAP_V3_SWAP_ROUTER_ADDRESS = payable(address(0xE592427A0AEce92De3Edee1F18E0157C05861564));
    bytes4 immutable private APPROVE_SELECTOR = bytes4(keccak256(bytes("approve(address,uint256)")));
    bytes4 immutable private EXACT_INPUT_SELECTOR = bytes4(keccak256("exactInput(ISwapRouter.ExactInputParams)"));
    bytes4 immutable private EXACT_INPUT_SINGLE_SELECTOR = bytes4(keccak256("exactInputSingle(ISwapRouter.ExactInputSingleParams)"));
    bytes4 immutable private EXACT_OUTPUT_SELECTOR = bytes4(keccak256("exactOutput(ISwapRouter.exactOutputParams)"));
    bytes4 immutable private EXACT_OUTPUT_SINGLE_SELECTOR = bytes4(keccak256("exactOutputSingle(ISwapRouter.ExactOutputSingleParams)"));
    bytes4 immutable private REFUND_ETH_SELECTOR = bytes4(keccak256("refundETH()"));
    bytes4 immutable private SWEEP_TOKEN_SELECTOR = bytes4(keccak256("sweepToken(address,uint256,address)"));
    bytes4 immutable private SWEEP_TOKEN_WITH_FEE_SELECTOR = bytes4(keccak256("sweepTokenWithFee(address,uint256,address,uint256,address)"));
    bytes4 immutable private UNWRAP_WETH9_SELECTOR = bytes4(keccak256("unwrapWETH9(uint256,address)"));
    bytes4 immutable private UNWRAP_WETH9_WITH_FEE_SELECTOR = bytes4(keccak256("unwrapWETH9WithFee(uint256,address,uint256,address)"));
    bytes4 immutable private WRAP_ETH_SELECTOR = bytes4(keccak256("wrapETH(uint256)"));
    
    
    
    
    function multicall(bytes[] calldata data) external payable {
        for (uint256 i = 0; i < data.length; i++) {
            bytes memory messagePack = data[i];
            bytes4 selector;
            assembly {
                selector := mload(add(messagePack, 32))
            }
            
            if (selector == EXACT_INPUT_SINGLE_SELECTOR) {
                exactInputSingleInternal(abi.decode(data[i], (ISwapRouter.ExactInputSingleParams)));
            } else if (selector == EXACT_INPUT_SELECTOR) {
                exactInputInternal(abi.decode(data[i], (ISwapRouter.ExactInputParams)));
            } else if (selector == EXACT_OUTPUT_SINGLE_SELECTOR) {
                exactOutputSingleInternal(abi.decode(data[i], (ISwapRouter.ExactOutputSingleParams)));
            } else if (selector == EXACT_OUTPUT_SELECTOR) {
                exactOutputInternal(abi.decode(data[i], (ISwapRouter.ExactOutputParams)));
            } else if (selector == WRAP_ETH_SELECTOR) {
                wrapETHInternal(abi.decode(data[i], (uint256)));
            } else if (selector == UNWRAP_WETH9_SELECTOR) {
                (uint256 amountMinimum, address recipient) = abi.decode(data[i], (uint256, address));
                unwrapWETH9Internal(amountMinimum, recipient);
            } else if (selector == REFUND_ETH_SELECTOR) {
                refundETHInternal();
            } else if (selector == SWEEP_TOKEN_SELECTOR) {
                (address token, uint256 amountMinimum, address recipient) = abi.decode(
                    data[i],
                    (address, uint256, address)
                );
                sweepTokenInternal(token, amountMinimum, recipient);
            } else if (selector == UNWRAP_WETH9_WITH_FEE_SELECTOR) {
                (uint256 amountMinimum, address recipient, uint256 feeBips, address feeRecipient) = abi.decode(
                    data[i],
                    (uint256, address, uint256, address)
                );
                unwrapWETH9WithFeeInternal(amountMinimum, recipient, feeBips, feeRecipient);
            } else if (selector == SWEEP_TOKEN_WITH_FEE_SELECTOR) {
                (
                    address token,
                    uint256 amountMinimum,
                    address recipient,
                    uint256 feeBips,
                    address feeRecipient
                ) = abi.decode(
                    data[i],
                    (address, uint256, address, uint256, address)
                );
                sweepTokenWithFeeInternal(token, amountMinimum, recipient, feeBips, feeRecipient);
            } else revert("UNKNOWN_SELECTOR");
        }
    }
    
    
    
    function wrapETH(uint256 value) external payable {
        wrapETHInternal(value);
    }
    
    function wrapETHInternal(uint256 value) internal {
        if (value > uint256(0)) {
            IWETH9(
                IPeripheryImmutableState(UNISWAP_V3_SWAP_ROUTER_ADDRESS).WETH9()
            ).deposit{value: value}();
        }
    }
    
    
    
    
    function exactInputSingle(ISwapRouter.ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut)
    {
        amountOut = exactInputSingleInternal(params);
    }
    
    function exactInputSingleInternal(ISwapRouter.ExactInputSingleParams memory params)
        internal
        returns (uint256 amountOut)
    {
        // we first set the allowance to the uniswap router
        if (Token(params.tokenIn).allowance(address(this), UNISWAP_V3_SWAP_ROUTER_ADDRESS) < params.amountIn) {
            safeApproveInternal(params.tokenIn, UNISWAP_V3_SWAP_ROUTER_ADDRESS, type(uint).max);
        }
        
        // finally, we swap the tokens
        amountOut = ISwapRouter(UNISWAP_V3_SWAP_ROUTER_ADDRESS).exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: params.tokenIn,
                tokenOut: params.tokenOut,
                fee: params.fee,
                recipient: address(this), // this drago is always the recipient
                deadline: params.deadline,
                amountIn: params.amountIn,
                amountOutMinimum: params.amountOutMinimum,
                sqrtPriceLimitX96: params.sqrtPriceLimitX96
            })
        );
    }
    
    
    
    
    function exactInput(ISwapRouter.ExactInputParams calldata params)
        external
        payable
        returns (uint256 amountOut)
    {
        amountOut = exactInputInternal(params);
    }
    
    function exactInputInternal(ISwapRouter.ExactInputParams memory params)
        internal
        returns (uint256 amountOut)
    {
        (address tokenIn, , ) = params.path.decodeFirstPool();
        
        // we first set the allowance to the uniswap router
        if (Token(tokenIn).allowance(address(this), UNISWAP_V3_SWAP_ROUTER_ADDRESS) < params.amountIn) {
            safeApproveInternal(tokenIn, UNISWAP_V3_SWAP_ROUTER_ADDRESS, type(uint).max);
        }
        
        // finally, we swap the tokens
        amountOut = ISwapRouter(UNISWAP_V3_SWAP_ROUTER_ADDRESS).exactInput(
            ISwapRouter.ExactInputParams({
                path: params.path,
                recipient: address(this), // this drago is always the recipient
                deadline: params.deadline,
                amountIn: params.amountIn,
                amountOutMinimum: params.amountOutMinimum
            })    
        );
    }
    
    
    
    
    function exactOutputSingle(ISwapRouter.ExactOutputSingleParams calldata params)
        external
        payable
        returns (uint256 amountIn)
    {
        amountIn = exactOutputSingleInternal(params);
    }
    
    function exactOutputSingleInternal(ISwapRouter.ExactOutputSingleParams memory params)
        internal
        returns (uint256 amountIn)
    {
        // we first set the allowance to the uniswap router
        if (Token(params.tokenIn).allowance(address(this), UNISWAP_V3_SWAP_ROUTER_ADDRESS) < params.amountInMaximum) {
            safeApproveInternal(params.tokenIn, UNISWAP_V3_SWAP_ROUTER_ADDRESS, type(uint).max);
        }
        
        // finally, we swap the tokens
        amountIn = ISwapRouter(UNISWAP_V3_SWAP_ROUTER_ADDRESS).exactOutputSingle(
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: params.tokenIn,
                tokenOut: params.tokenOut,
                fee: params.fee,
                recipient: address(this), // this drago is always the recipient
                deadline: params.deadline,
                amountOut: params.amountOut,
                amountInMaximum: params.amountInMaximum,
                sqrtPriceLimitX96: params.sqrtPriceLimitX96
            })    
        );
    }
    
    
    
    
    function exactOutput(ISwapRouter.ExactOutputParams calldata params)
        external
        payable
        returns (uint256 amountIn)
    {
        amountIn = exactOutputInternal(params);
    }
    
    function exactOutputInternal(ISwapRouter.ExactOutputParams memory params)
        internal
        returns (uint256 amountIn)
    {
        (address tokenIn, , ) = params.path.decodeFirstPool();
        
        // we first set the allowance to the uniswap router
        if (Token(tokenIn).allowance(address(this), UNISWAP_V3_SWAP_ROUTER_ADDRESS) < params.amountInMaximum) {
            safeApproveInternal(tokenIn, UNISWAP_V3_SWAP_ROUTER_ADDRESS, type(uint).max);
        }
        
        // finally, we swap the tokens
        amountIn = ISwapRouter(UNISWAP_V3_SWAP_ROUTER_ADDRESS).exactOutput(
            ISwapRouter.ExactOutputParams({
                path: params.path,
                recipient: address(this), // this drago is always the recipient
                deadline: params.deadline,
                amountOut: params.amountOut,
                amountInMaximum: params.amountInMaximum
            })
        );
    }
    
    
    
    
    
    function unwrapWETH9(uint256 amountMinimum, address recipient)
        external
        payable
    {
        unwrapWETH9Internal(amountMinimum, recipient);
    }
    
    function unwrapWETH9Internal(uint256 amountMinimum, address recipient)
        internal
    {
        IPeripheryPaymentsWithFee(UNISWAP_V3_SWAP_ROUTER_ADDRESS).unwrapWETH9(
            amountMinimum,
            recipient != address(this) ? address(this) : address(this) // this drago is always the recipient
        );
    }
    
    
    
    /// that use ether for the input amount
    function refundETH()
        external
        payable
    {
        refundETHInternal();
    }
    
    function refundETHInternal()
        internal
    {
        IPeripheryPaymentsWithFee(UNISWAP_V3_SWAP_ROUTER_ADDRESS).refundETH();
    }
    
    
    
    
    
    
    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    )
        external
        payable
    {
        sweepTokenInternal(token, amountMinimum, recipient);
    }
    
    function sweepTokenInternal(
        address token,
        uint256 amountMinimum,
        address recipient
    )
        internal
    {
        IPeripheryPaymentsWithFee(UNISWAP_V3_SWAP_ROUTER_ADDRESS).sweepToken(
            token,
            amountMinimum,
            recipient != address(this) ? address(this) : address(this) // this drago is always the recipient
        );
    }
    
    
    /// 0 (exclusive), and 1 (inclusive) going to feeRecipient
    
    function unwrapWETH9WithFee(
        uint256 amountMinimum,
        address recipient,
        uint256 feeBips,
        address feeRecipient
    )
        external
        payable
    {
        unwrapWETH9WithFeeInternal(amountMinimum, recipient, feeBips, feeRecipient);
    }
    
    function unwrapWETH9WithFeeInternal(
        uint256 amountMinimum,
        address recipient,
        uint256 feeBips,
        address feeRecipient
    )
        internal
    {
        IPeripheryPaymentsWithFee(UNISWAP_V3_SWAP_ROUTER_ADDRESS).unwrapWETH9WithFee(
            amountMinimum,
            recipient != address(this) ? address(this) : address(this),  // this drago is always the recipient
            feeBips,
            feeRecipient
        );
    }
    
    
    /// 0 (exclusive) and 1 (inclusive) going to feeRecipient
    
    function sweepTokenWithFee(
        address token,
        uint256 amountMinimum,
        address recipient,
        uint256 feeBips,
        address feeRecipient
    )
        external
        payable
    {
        sweepTokenWithFeeInternal(token, amountMinimum, recipient, feeBips, feeRecipient);
    }

    function sweepTokenWithFeeInternal(
        address token,
        uint256 amountMinimum,
        address recipient,
        uint256 feeBips,
        address feeRecipient
    )
        internal
    {
        IPeripheryPaymentsWithFee(UNISWAP_V3_SWAP_ROUTER_ADDRESS).sweepTokenWithFee(
            token,
            amountMinimum,
            recipient != address(this) ? address(this) : address(this),  // this drago is always the recipient
            feeBips,
            feeRecipient
        );
    }
    
    function safeApproveInternal(
        address token,
        address spender,
        uint256 value
    )
        internal
    {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(APPROVE_SELECTOR, spender, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "RIGOBLOCK_APPROVE_FAILED"
        );
    }
}

// 
pragma solidity >=0.7.5;




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



interface IPeripheryPaymentsWithFee is IPeripheryPayments {
    
    /// 0 (exclusive), and 1 (inclusive) going to feeRecipient
    
    function unwrapWETH9WithFee(
        uint256 amountMinimum,
        address recipient,
        uint256 feeBips,
        address feeRecipient
    ) external payable;

    
    /// 0 (exclusive) and 1 (inclusive) going to feeRecipient
    
    function sweepTokenWithFee(
        address token,
        uint256 amountMinimum,
        address recipient,
        uint256 feeBips,
        address feeRecipient
    ) external payable;
}

// 
pragma solidity >=0.5.0;



interface IPeripheryImmutableState {
    
    function factory() external view returns (address);

    
    function WETH9() external view returns (address);
}

// 
pragma solidity >=0.6.0;

library BytesLib {
    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        require(_length + 31 >= _length, 'slice_overflow');
        require(_start + _length >= _start, 'slice_overflow');
        require(_bytes.length >= _start + _length, 'slice_outOfBounds');

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
                case 0 {
                    // Get a location of some free memory and store it in tempBytes as
                    // Solidity does for memory variables.
                    tempBytes := mload(0x40)

                    // The first word of the slice result is potentially a partial
                    // word read from the original array. To read it, we calculate
                    // the length of that partial word and start copying that many
                    // bytes into the array. The first word we copy will start with
                    // data we don't care about, but the last `lengthmod` bytes will
                    // land at the beginning of the contents of the new array. When
                    // we're done copying, we overwrite the full first word with
                    // the actual length of the slice.
                    let lengthmod := and(_length, 31)

                    // The multiplication in the next line is necessary
                    // because when slicing multiples of 32 bytes (lengthmod == 0)
                    // the following copy loop was copying the origin's length
                    // and then ending prematurely not copying everything it should.
                    let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                    let end := add(mc, _length)

                    for {
                        // The multiplication in the next line has the same exact purpose
                        // as the one above.
                        let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                    } lt(mc, end) {
                        mc := add(mc, 0x20)
                        cc := add(cc, 0x20)
                    } {
                        mstore(mc, mload(cc))
                    }

                    mstore(tempBytes, _length)

                    //update free-memory pointer
                    //allocating the array padded to 32 bytes like the compiler does now
                    mstore(0x40, and(add(mc, 31), not(31)))
                }
                //if we want a zero-length slice let's just return a zero-length array
                default {
                    tempBytes := mload(0x40)
                    //zero out the 32 bytes slice we are about to return
                    //we need to do it because Solidity does not garbage collect
                    mstore(tempBytes, 0)

                    mstore(0x40, add(tempBytes, 0x20))
                }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_start + 20 >= _start, 'toAddress_overflow');
        require(_bytes.length >= _start + 20, 'toAddress_outOfBounds');
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {
        require(_start + 3 >= _start, 'toUint24_overflow');
        require(_bytes.length >= _start + 3, 'toUint24_outOfBounds');
        uint24 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }

        return tempUint;
    }
}


library Path {
    using BytesLib for bytes;

    
    uint256 private constant ADDR_SIZE = 20;
    
    uint256 private constant FEE_SIZE = 3;

    
    uint256 private constant NEXT_OFFSET = ADDR_SIZE + FEE_SIZE;
    
    uint256 private constant POP_OFFSET = NEXT_OFFSET + ADDR_SIZE;
    
    uint256 private constant MULTIPLE_POOLS_MIN_LENGTH = POP_OFFSET + NEXT_OFFSET;

    
    
    
    function hasMultiplePools(bytes memory path) internal pure returns (bool) {
        return path.length >= MULTIPLE_POOLS_MIN_LENGTH;
    }

    
    
    
    function numPools(bytes memory path) internal pure returns (uint256) {
        // Ignore the first token address. From then on every fee and token offset indicates a pool.
        return ((path.length - ADDR_SIZE) / NEXT_OFFSET);
    }

    
    
    
    
    
    function decodeFirstPool(bytes memory path)
        internal
        pure
        returns (
            address tokenA,
            address tokenB,
            uint24 fee
        )
    {
        tokenA = path.toAddress(0);
        fee = path.toUint24(ADDR_SIZE);
        tokenB = path.toAddress(NEXT_OFFSET);
    }

    
    
    
    function getFirstPool(bytes memory path) internal pure returns (bytes memory) {
        return path.slice(0, POP_OFFSET);
    }

    
    
    
    function skipToken(bytes memory path) internal pure returns (bytes memory) {
        return path.slice(NEXT_OFFSET, path.length - NEXT_OFFSET);
    }
}