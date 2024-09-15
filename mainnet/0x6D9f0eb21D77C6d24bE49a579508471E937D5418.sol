// SPDX-License-Identifier: MIT


// 
pragma solidity =0.8.10;


interface IAntfarmPairState {
    
    
    function factory() external view returns (address);

    
    
    function token0() external view returns (address);

    
    
    function token1() external view returns (address);

    
    
    function fee() external view returns (uint16);

    
    
    function totalSupply() external view returns (uint256);

    
    
    function antfarmTokenReserve() external view returns (uint256);
}

// 
pragma solidity =0.8.10;

interface IAntfarmPairActions {
    
    
    
    
    
    function mint(address to, uint256 positionId)
        external
        returns (uint256 liquidity);

    
    
    
    
    
    
    
    function burn(
        address to,
        uint256 liquidity,
        uint256 positionId
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    
    
    
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to
    ) external;

    
    
    function skim(address to) external;

    
    function sync() external;

    
    
    
    
    function claimDividend(address to, uint256 positionId)
        external
        returns (uint256 claimedAmount);
}

// 
pragma solidity =0.8.10;

interface IAntfarmPairEvents {
    
    
    
    
    
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );

    
    
    
    
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);

    
    
    
    
    
    
    
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );

    
    
    
    event Sync(uint112 reserve0, uint112 reserve1);
}

// 
pragma solidity =0.8.10;

interface IAntfarmPairDerivedState {
    
    
    
    
    function getPositionLP(address operator, uint256 positionId)
        external
        view
        returns (uint128);

    
    
    
    
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    
    
    
    
    function claimableDividends(address operator, uint256 positionId)
        external
        view
        returns (uint256 amount);
}

// 
pragma solidity =0.8.10;

interface IAntfarmRouter {
    function factory() external view returns (address);

    function WETH() external view returns (address);

    function antfarmToken() external view returns (address);

    struct swapParams {
        address[] path;
        uint16[] fees;
        address to;
    }

    struct swapExactTokensForTokensParams {
        uint256 amountIn;
        uint256 amountOutMin;
        uint256 maxFee;
        address[] path;
        uint16[] fees;
        address to;
        uint256 deadline;
    }

    function swapExactTokensForTokens(
        swapExactTokensForTokensParams calldata params
    ) external returns (uint256[] memory amounts);

    struct swapTokensForExactTokensParams {
        uint256 amountOut;
        uint256 amountInMax;
        uint256 maxFee;
        address[] path;
        uint16[] fees;
        address to;
        uint256 deadline;
    }

    function swapTokensForExactTokens(
        swapTokensForExactTokensParams calldata params
    ) external returns (uint256[] memory amounts);

    struct swapExactETHForTokensParams {
        uint256 amountOutMin;
        uint256 maxFee;
        address[] path;
        uint16[] fees;
        address to;
        uint256 deadline;
    }

    function swapExactETHForTokens(swapExactETHForTokensParams calldata params)
        external
        payable
        returns (uint256[] memory amounts);

    struct swapTokensForExactETHParams {
        uint256 amountOut;
        uint256 amountInMax;
        uint256 maxFee;
        address[] path;
        uint16[] fees;
        address to;
        uint256 deadline;
    }

    function swapTokensForExactETH(swapTokensForExactETHParams calldata params)
        external
        returns (uint256[] memory amounts);

    struct swapExactTokensForETHParams {
        uint256 amountIn;
        uint256 amountOutMin;
        uint256 maxFee;
        address[] path;
        uint16[] fees;
        address to;
        uint256 deadline;
    }

    function swapExactTokensForETH(swapExactTokensForETHParams calldata params)
        external
        returns (uint256[] memory amounts);

    struct swapETHForExactTokensParams {
        uint256 amountOut;
        uint256 maxFee;
        address[] path;
        uint16[] fees;
        address to;
        uint256 deadline;
    }

    function swapETHForExactTokens(swapETHForExactTokensParams calldata params)
        external
        payable
        returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        swapExactTokensForTokensParams calldata params
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        swapExactETHForTokensParams calldata params
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        swapExactTokensForETHParams calldata params
    ) external;

    // fetches and sorts the reserves for a pair
    function getReserves(
        address tokenA,
        address tokenB,
        uint16 fee
    ) external view returns (uint256 reserveA, uint256 reserveB);
}

// 
pragma solidity =0.8.10;






interface IAntfarmBase is
    IAntfarmPairState,
    IAntfarmPairEvents,
    IAntfarmPairActions,
    IAntfarmPairDerivedState
{}
// 
pragma solidity =0.8.10;












contract AntfarmRouter is IAntfarmRouter {
    address public immutable factory;
    address public immutable WETH;
    address public immutable antfarmToken;

    modifier ensure(uint256 deadline) {
        if (deadline < block.timestamp) revert Expired();
        _;
    }

    constructor(
        address _factory,
        address _WETH,
        address _antfarmToken
    ) {
        require(_factory != address(0), "NULL_FACTORY_ADDRESS");
        require(_WETH != address(0), "NULL_WETH_ADDRESS");
        require(_antfarmToken != address(0), "NULL_ATF_ADDRESS");
        factory = _factory;
        WETH = _WETH;
        antfarmToken = _antfarmToken;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    
    
    // @param amountIn The amount of input tokens to send
    // @param amountOutMin The minimum amount of output tokens that must be received for the transaction not to revert
    // @param maxFee Maximum fees to be paid
    // @param path An array of token addresses
    // @param fees Associated fee for each two token addresses within the path
    // @param to Recipient of the output tokens
    // @param deadline Unix timestamp after which the transaction will revert
    
    function swapExactTokensForTokens(
        swapExactTokensForTokensParams calldata params
    )
        external
        virtual
        ensure(params.deadline)
        returns (uint256[] memory amounts)
    {
        uint256 amountIn = params.path[0] == antfarmToken
            ? (params.amountIn * (1000 + params.fees[0])) / 1000
            : params.amountIn;
        amounts = getAmountsOut(amountIn, params.path, params.fees);
        if (amounts[amounts.length - 1] < params.amountOutMin) {
            revert InsufficientOutputAmount();
        }
        TransferHelper.safeTransferFrom(
            params.path[0],
            msg.sender,
            pairFor(params.path[0], params.path[1], params.fees[0]),
            amounts[0]
        );
        if (
            _swap(amounts, params.path, params.fees, params.to) > params.maxFee
        ) {
            revert InsufficientMaxFee();
        }
    }

    
    
    // @param amountOut The amount of output tokens to receive
    // @param amountInMax The maximum amount of input tokens that can be required before the transaction reverts
    // @param maxFee Maximum fees to be paid
    // @param path An array of token addresses
    // @param fees Associated fee for each two token addresses within the path
    // @param to Recipient of the output tokens
    // @param deadline Unix timestamp after which the transaction will revert
    
    function swapTokensForExactTokens(
        swapTokensForExactTokensParams calldata params
    )
        external
        virtual
        ensure(params.deadline)
        returns (uint256[] memory amounts)
    {
        uint256 amountInMax = params.path[0] == antfarmToken
            ? (params.amountInMax * (1000 + params.fees[0])) / 1000
            : params.amountInMax;
        amounts = getAmountsIn(params.amountOut, params.path, params.fees);
        if (amounts[0] > amountInMax) revert ExcessiveInputAmount();
        TransferHelper.safeTransferFrom(
            params.path[0],
            msg.sender,
            pairFor(params.path[0], params.path[1], params.fees[0]),
            amounts[0]
        );
        if (
            _swap(amounts, params.path, params.fees, params.to) > params.maxFee
        ) {
            revert InsufficientMaxFee();
        }
    }

    
    
    // @param amountOutMin The minimum amount of output tokens that must be received for the transaction not to revert
    // @param maxFee Maximum fees to be paid
    // @param path An array of token addresses
    // @param fees Associated fee for each two token addresses within the path
    // @param to Recipient of the output tokens
    // @param deadline Unix timestamp after which the transaction will revert
    
    function swapExactETHForTokens(swapExactETHForTokensParams calldata params)
        external
        payable
        virtual
        ensure(params.deadline)
        returns (uint256[] memory amounts)
    {
        if (params.path[0] != WETH) revert InvalidPath();
        amounts = getAmountsOut(msg.value, params.path, params.fees);
        if (amounts[amounts.length - 1] < params.amountOutMin) {
            revert InsufficientOutputAmount();
        }
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(
            IWETH(WETH).transfer(
                pairFor(params.path[0], params.path[1], params.fees[0]),
                amounts[0]
            )
        );
        if (
            _swap(amounts, params.path, params.fees, params.to) > params.maxFee
        ) {
            revert InsufficientMaxFee();
        }
    }

    
    
    // @param amountOut The amount of ETH to receive
    // @param amountInMax The maximum amount of input tokens that can be required before the transaction reverts
    // @param maxFee Maximum fees to be paid
    // @param path An array of token addresses
    // @param fees Associated fee for each two token addresses within the path
    // @param to Recipient of the output tokens
    // @param deadline Unix timestamp after which the transaction will revert
    
    function swapTokensForExactETH(swapTokensForExactETHParams calldata params)
        external
        virtual
        ensure(params.deadline)
        returns (uint256[] memory amounts)
    {
        if (params.path[params.path.length - 1] != WETH) revert InvalidPath();
        uint256 amountInMax = params.path[0] == antfarmToken
            ? (params.amountInMax * (1000 + params.fees[0])) / 1000
            : params.amountInMax;
        amounts = getAmountsIn(params.amountOut, params.path, params.fees);
        if (amounts[0] > amountInMax) revert ExcessiveInputAmount();
        TransferHelper.safeTransferFrom(
            params.path[0],
            msg.sender,
            pairFor(params.path[0], params.path[1], params.fees[0]),
            amounts[0]
        );
        if (
            _swap(amounts, params.path, params.fees, address(this)) >
            params.maxFee
        ) {
            revert InsufficientMaxFee();
        }
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(params.to, amounts[amounts.length - 1]);
    }

    
    
    // @param amountIn The amount of input tokens to send
    // @param amountOutMin The minimum amount of output tokens that must be received for the transaction not to revert
    // @param maxFee Maximum fees to be paid
    // @param path An array of token addresses
    // @param fees Associated fee for each two token addresses within the path
    // @param to Recipient of the output tokens
    // @param deadline Unix timestamp after which the transaction will revert
    
    function swapExactTokensForETH(swapExactTokensForETHParams calldata params)
        external
        virtual
        ensure(params.deadline)
        returns (uint256[] memory amounts)
    {
        uint256 amountIn = params.path[0] == antfarmToken
            ? (params.amountIn * (1000 + params.fees[0])) / 1000
            : params.amountIn;
        if (params.path[params.path.length - 1] != WETH) revert InvalidPath();
        amounts = getAmountsOut(amountIn, params.path, params.fees);
        if (amounts[amounts.length - 1] < params.amountOutMin) {
            revert InsufficientOutputAmount();
        }
        TransferHelper.safeTransferFrom(
            params.path[0],
            msg.sender,
            pairFor(params.path[0], params.path[1], params.fees[0]),
            amounts[0]
        );
        if (
            _swap(amounts, params.path, params.fees, address(this)) >
            params.maxFee
        ) {
            revert InsufficientMaxFee();
        }
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(params.to, amounts[amounts.length - 1]);
    }

    
    
    // @param amountOut The amount of tokens to receive
    // @param maxFee Maximum fees to be paid
    // @param path An array of token addresses
    // @param fees Associated fee for each two token addresses within the path
    // @param to Recipient of the output tokens
    // @param deadline Unix timestamp after which the transaction will revert
    
    function swapETHForExactTokens(swapETHForExactTokensParams calldata params)
        external
        payable
        virtual
        ensure(params.deadline)
        returns (uint256[] memory amounts)
    {
        if (params.path[0] != WETH) revert InvalidPath();
        amounts = getAmountsIn(params.amountOut, params.path, params.fees);
        if (amounts[0] > msg.value) revert ExcessiveInputAmount();
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(
            IWETH(WETH).transfer(
                pairFor(params.path[0], params.path[1], params.fees[0]),
                amounts[0]
            )
        );
        if (
            _swap(amounts, params.path, params.fees, params.to) > params.maxFee
        ) {
            revert InsufficientMaxFee();
        }
        // refund dust ETH if any
        if (msg.value > amounts[0])
            TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    
    
    // @param amountIn The amount of input tokens to send
    // @param amountOutMin The minimum amount of output tokens that must be received for the transaction not to revert
    // @param path An array of token addresses
    // @param fees Associated fee for each two token addresses within the path
    // @param to Recipient of the output tokens
    // @param deadline Unix timestamp after which the transaction will revert
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        swapExactTokensForTokensParams calldata params
    ) external virtual ensure(params.deadline) {
        TransferHelper.safeTransferFrom(
            params.path[0],
            msg.sender,
            pairFor(params.path[0], params.path[1], params.fees[0]),
            params.amountIn
        );
        uint256 balanceBefore = IERC20(params.path[params.path.length - 1])
            .balanceOf(params.to);
        swapParams memory sParams = swapParams(
            params.path,
            params.fees,
            params.to
        );
        if (_swapSupportingFeeOnTransferTokens(sParams) > params.maxFee) {
            revert InsufficientMaxFee();
        }
        if (
            IERC20(params.path[params.path.length - 1]).balanceOf(params.to) -
                balanceBefore <
            params.amountOutMin
        ) {
            revert InsufficientOutputAmount();
        }
    }

    
    
    // @param amountOutMin The minimum amount of output tokens that must be received for the transaction not to revert
    // @param path An array of token addresses
    // @param fees Associated fee for each two token addresses within the path
    // @param to Recipient of the output tokens
    // @param deadline Unix timestamp after which the transaction will revert
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        swapExactETHForTokensParams calldata params
    ) external payable virtual ensure(params.deadline) {
        if (params.path[0] != WETH) revert InvalidPath();
        uint256 amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        assert(
            IWETH(WETH).transfer(
                pairFor(params.path[0], params.path[1], params.fees[0]),
                amountIn
            )
        );
        uint256 balanceBefore = IERC20(params.path[params.path.length - 1])
            .balanceOf(params.to);
        swapParams memory sParams = swapParams(
            params.path,
            params.fees,
            params.to
        );
        if (_swapSupportingFeeOnTransferTokens(sParams) > params.maxFee) {
            revert InsufficientMaxFee();
        }
        if (
            IERC20(params.path[params.path.length - 1]).balanceOf(params.to) -
                balanceBefore <
            params.amountOutMin
        ) {
            revert InsufficientOutputAmount();
        }
    }

    
    
    // @param amountIn The amount of input tokens to send
    // @param amountOutMin The minimum amount of output tokens that must be received for the transaction not to revert
    // @param path An array of token addresses
    // @param fees Associated fee for each two token addresses within the path
    // @param to Recipient of the output tokens
    // @param deadline Unix timestamp after which the transaction will revert
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        swapExactTokensForETHParams calldata params
    ) external virtual ensure(params.deadline) {
        if (params.path[params.path.length - 1] != WETH) revert InvalidPath();
        TransferHelper.safeTransferFrom(
            params.path[0],
            msg.sender,
            pairFor(params.path[0], params.path[1], params.fees[0]),
            params.amountIn
        );
        swapParams memory sParams = swapParams(
            params.path,
            params.fees,
            address(this)
        );
        if (_swapSupportingFeeOnTransferTokens(sParams) > params.maxFee) {
            revert InsufficientMaxFee();
        }
        uint256 amountOut = IERC20(WETH).balanceOf(address(this));
        if (amountOut < params.amountOutMin) revert InsufficientOutputAmount();
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(params.to, amountOut);
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address tokenA,
        address tokenB,
        uint16 fee
    ) public view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IAntfarmPair(
            pairFor(tokenA, tokenB, fee)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    // SWAP
    // requires the initial amount to have already been sent to the first pair
    function _swap(
        uint256[] memory amounts,
        address[] memory path,
        uint16[] memory fees,
        address _to
    ) internal virtual returns (uint256 totalFee) {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            uint16 fee = fees[i];
            IAntfarmPair antfarmPair = IAntfarmPair(
                pairFor(input, output, fee)
            );

            (address token0, ) = sortTokens(input, output);
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amounts[i + 1])
                : (amounts[i + 1], uint256(0));

            {
                uint256 amountIn = amounts[i];

                if (input == antfarmToken) {
                    totalFee = totalFee + ((amountIn * fee) / (1000 + fee));
                } else if (output == antfarmToken) {
                    totalFee =
                        totalFee +
                        ((amounts[i + 1] * fee) / (1000 - fee));
                } else {
                    uint256 feeToPay = antfarmPair.getFees(
                        amount0Out,
                        input == token0 ? amountIn : uint256(0),
                        amount1Out,
                        input == token0 ? uint256(0) : amountIn
                    );

                    TransferHelper.safeTransferFrom(
                        antfarmToken,
                        msg.sender,
                        address(antfarmPair),
                        feeToPay
                    );

                    totalFee = totalFee + feeToPay;
                }
            }

            address to = i < path.length - 2
                ? pairFor(output, path[i + 2], fees[i + 1])
                : _to;
            antfarmPair.swap(amount0Out, amount1Out, to);
        }
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    function _swapSupportingFeeOnTransferTokens(swapParams memory sParams)
        internal
        virtual
        returns (uint256 totalFee)
    {
        for (uint256 i; i < sParams.path.length - 1; i++) {
            (address input, address output) = (
                sParams.path[i],
                sParams.path[i + 1]
            );
            uint16 fee = sParams.fees[i];
            IAntfarmPair antfarmPair = IAntfarmPair(
                pairFor(input, output, fee)
            );

            (address token0, ) = sortTokens(input, output);

            uint256 amountIn;
            uint256 amountOut;
            {
                (uint256 reserve0, uint256 reserve1, ) = antfarmPair
                    .getReserves();
                (uint256 reserveIn, uint256 reserveOut) = input == token0
                    ? (reserve0, reserve1)
                    : (reserve1, reserve0);

                amountIn =
                    IERC20(input).balanceOf(address(antfarmPair)) -
                    reserveIn;

                if (input == antfarmToken) {
                    amountOut = getAmountOut(
                        (amountIn * 1000) / (1000 + fee),
                        reserveIn,
                        reserveOut
                    );
                } else if (output == antfarmToken) {
                    amountOut =
                        (getAmountOut(amountIn, reserveIn, reserveOut) *
                            (1000 - fee)) /
                        1000;
                } else {
                    amountOut = getAmountOut(amountIn, reserveIn, reserveOut);
                }
            }

            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));

            if (input == antfarmToken) {
                totalFee = totalFee + ((amountIn * fee) / (1000 + fee));
            } else if (output == antfarmToken) {
                totalFee = totalFee + ((amountIn * fee) / 1000);
            } else {
                uint256 feeToPay = antfarmPair.getFees(
                    amount0Out,
                    input == token0 ? amountIn : uint256(0),
                    amount1Out,
                    input == token0 ? uint256(0) : amountIn
                );

                TransferHelper.safeTransferFrom(
                    antfarmToken,
                    msg.sender,
                    address(antfarmPair),
                    feeToPay
                );

                totalFee = totalFee + feeToPay;
            }

            address to = i < sParams.path.length - 2
                ? pairFor(output, sParams.path[i + 2], sParams.fees[i + 1])
                : sParams.to;
            antfarmPair.swap(amount0Out, amount1Out, to);
        }
    }

    // **** LIBRARY FUNCTIONS ADDED INTO THE CONTRACT ****
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB)
        internal
        view
        returns (address token0, address token1)
    {
        if (tokenA == tokenB) revert IdenticalAddresses();
        if (tokenA == antfarmToken || tokenB == antfarmToken) {
            (token0, token1) = tokenA == antfarmToken
                ? (antfarmToken, tokenB)
                : (antfarmToken, tokenA);
            if (token1 == address(0)) revert ZeroAddress();
        } else {
            (token0, token1) = tokenA < tokenB
                ? (tokenA, tokenB)
                : (tokenB, tokenA);
            if (token0 == address(0)) revert ZeroAddress();
        }
    }

    
    
    
    
    
    function pairFor(
        address tokenA,
        address tokenB,
        uint16 fee
    ) internal view returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(
                                abi.encodePacked(
                                    token0,
                                    token1,
                                    fee,
                                    antfarmToken
                                )
                            ),
                            token0 == antfarmToken
                                ? hex"b174de46ec9038ead3d74ed04c79d4885d8e642175833c4da037d5e052492e5b" // AtfPair init code hash
                                : hex"2f47d72b208014a5ba4f32371ac96dd421a39152dcaf104e8232b6c9f1a92280" // Pair init code hash
                        )
                    )
                )
            )
        );
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        uint256 amountIn,
        address[] memory path,
        uint16[] memory fees
    ) internal view returns (uint256[] memory) {
        if (path.length < 2) revert InvalidPath();
        uint256[] memory amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                path[i],
                path[i + 1],
                fees[i]
            );
            if (path[i] == antfarmToken) {
                amounts[i + 1] = getAmountOut(
                    (amounts[i] * 1000) / (1000 + fees[i]),
                    reserveIn,
                    reserveOut
                );
            } else if (path[i + 1] == antfarmToken) {
                amounts[i + 1] =
                    (getAmountOut(amounts[i], reserveIn, reserveOut) *
                        (1000 - fees[i])) /
                    1000;
            } else {
                amounts[i + 1] = getAmountOut(
                    amounts[i],
                    reserveIn,
                    reserveOut
                );
            }
        }
        return amounts;
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        uint256 amountOut,
        address[] memory path,
        uint16[] memory fees
    ) internal view returns (uint256[] memory) {
        if (path.length < 2) revert InvalidPath();
        uint256[] memory amounts = new uint256[](path.length);
        amounts[path.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                path[i - 1],
                path[i],
                fees[i - 1]
            );
            if (path[i - 1] == antfarmToken) {
                amounts[i - 1] =
                    (getAmountIn(amounts[i], reserveIn, reserveOut) *
                        (1000 + fees[i - 1])) /
                    1000;
            } else if (path[i] == antfarmToken) {
                amounts[i - 1] = getAmountIn(
                    (amounts[i] * 1000) / (1000 - fees[i - 1]),
                    reserveIn,
                    reserveOut
                );
            } else {
                amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
            }
        }
        return amounts;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256) {
        if (amountIn == 0) revert InsufficientInputAmount();
        if (reserveIn == 0 || reserveOut == 0) revert InsufficientLiquidity();
        uint256 numerator = amountIn * reserveOut;
        uint256 denominator = reserveIn + amountIn;
        return numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256) {
        if (amountOut == 0) revert InsufficientOutputAmount();
        if (reserveIn == 0 || reserveOut == 0) revert InsufficientLiquidity();
        uint256 numerator = reserveIn * amountOut;
        uint256 denominator = reserveOut - amountOut;
        return (numerator / denominator) + 1;
    }
}

// 
pragma solidity =0.8.10;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes("approve(address,uint256)")));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes("transfer(address,uint256)")));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}

// 
pragma solidity =0.8.10;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

// 
pragma solidity =0.8.10;

interface IAntfarmFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint16 fee,
        uint256 allPairsLength
    );

    function possibleFees(uint256) external view returns (uint16);

    function allPairs(uint256) external view returns (address);

    function antfarmToken() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB,
        uint16 fee
    ) external view returns (address pair);

    function feesForPair(
        address tokenA,
        address tokenB,
        uint256
    ) external view returns (uint16);

    function getFeesForPair(address tokenA, address tokenB)
        external
        view
        returns (uint16[8] memory fees);

    function allPairsLength() external view returns (uint256);

    function createPair(
        address tokenA,
        address tokenB,
        uint16 fee
    ) external returns (address pair);
}

// 
pragma solidity =0.8.10;



interface IAntfarmPair is IAntfarmBase {
    
    
    function initialize(
        address,
        address,
        uint16,
        address
    ) external;

    
    
    function antfarmToken() external view returns (address);

    
    
    function antfarmOracle() external view returns (address);

    
    
    
    
    
    
    function getFees(
        uint256 amount0Out,
        uint256 amount0In,
        uint256 amount1Out,
        uint256 amount1In
    ) external view returns (uint256 feeToPay);

    
    
    
    
    function scanOracles(uint112 maxReserve)
        external
        view
        returns (address bestOracle);

    
    
    function updateOracle() external;
}

// 
pragma solidity =0.8.10;



error InvalidToken();



contract AntfarmOracle {
    using FixedPoint for *;

    uint256 public constant PERIOD = 1 hours;

    address public token1;
    address public pair;

    uint256 public price1CumulativeLast;
    uint32 public blockTimestampLast;
    FixedPoint.uq112x112 public price1Average;

    bool public firstUpdateCall;

    constructor(
        address _token1,
        uint256 _price1CumulativeLast,
        uint32 _blockTimestampLast
    ) {
        token1 = _token1;
        pair = msg.sender;
        price1CumulativeLast = _price1CumulativeLast; // fetch the current accumulated price value (1 / 0)
        blockTimestampLast = _blockTimestampLast;
        firstUpdateCall = true;
    }

    
    
    
    
    function update(uint256 price1Cumulative, uint32 blockTimestamp) external {
        require(msg.sender == pair);
        unchecked {
            uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
            // ensure that at least one full period has passed since the last update
            if (timeElapsed >= PERIOD || firstUpdateCall) {
                // overflow is desired, casting never truncates
                // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
                price1Average = FixedPoint.uq112x112(
                    uint224(
                        (price1Cumulative - price1CumulativeLast) / timeElapsed
                    )
                );
                price1CumulativeLast = price1Cumulative;
                blockTimestampLast = blockTimestamp;
                if (firstUpdateCall) {
                    firstUpdateCall = false;
                }
            }
        }
    }

    
    
    
    
    function consult(address token, uint256 amountIn)
        external
        view
        returns (uint256 amountOut)
    {
        if (token == token1) {
            amountOut = price1Average.mul(amountIn).decode144();
        } else {
            revert InvalidToken();
        }
    }
}

// 
pragma solidity =0.8.10;

error Expired();
error InsufficientOutputAmount();
error InsufficientInputAmount();
error InsufficientLiquidity();
error InsufficientMaxFee();
error ExcessiveInputAmount();
error InvalidPath();
error IdenticalAddresses();
error ZeroAddress();

// 
pragma solidity =0.8.10;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// 
pragma solidity =0.8.10;

interface IAntfarmToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function nonces(address owner) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function burn(uint256 _amount) external;
}

// 
pragma solidity >=0.8.0;





// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))
library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // range: [0, 2**144 - 1]
    // resolution: 1 / 2**112
    struct uq144x112 {
        uint256 _x;
    }

    uint8 public constant RESOLUTION = 112;
    uint256 public constant Q112 = 0x10000000000000000000000000000; // 2**112
    uint256 private constant Q224 = 0x100000000000000000000000000000000000000000000000000000000; // 2**224
    uint256 private constant LOWER_MASK = 0xffffffffffffffffffffffffffff; // decimal of UQ*x112 (lower 112 bits)

    // encode a uint112 as a UQ112x112
    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    // encodes a uint144 as a UQ144x112
    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    // decode a UQ144x112 into a uint144 by truncating after the radix point
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }

    // multiply a UQ112x112 by a uint, returning a UQ144x112
    // reverts on overflow
    function mul(uq112x112 memory self, uint256 y) internal pure returns (uq144x112 memory) {
        uint256 z = 0;
        require(y == 0 || (z = self._x * y) / y == self._x, "FixedPoint::mul: overflow");
        return uq144x112(z);
    }

    // multiply a UQ112x112 by an int and decode, returning an int
    // reverts on overflow
    function muli(uq112x112 memory self, int256 y) internal pure returns (int256) {
        uint256 z = FullMath.mulDiv(self._x, uint256(y < 0 ? -y : y), Q112);
        require(z < 2**255, "FixedPoint::muli: overflow");
        return y < 0 ? -int256(z) : int256(z);
    }

    // multiply a UQ112x112 by a UQ112x112, returning a UQ112x112
    // lossy
    function muluq(uq112x112 memory self, uq112x112 memory other) internal pure returns (uq112x112 memory) {
        if (self._x == 0 || other._x == 0) {
            return uq112x112(0);
        }
        uint112 upper_self = uint112(self._x >> RESOLUTION); // * 2^0
        uint112 lower_self = uint112(self._x & LOWER_MASK); // * 2^-112
        uint112 upper_other = uint112(other._x >> RESOLUTION); // * 2^0
        uint112 lower_other = uint112(other._x & LOWER_MASK); // * 2^-112

        // partial products
        uint224 upper = uint224(upper_self) * upper_other; // * 2^0
        uint224 lower = uint224(lower_self) * lower_other; // * 2^-224
        uint224 uppers_lowero = uint224(upper_self) * lower_other; // * 2^-112
        uint224 uppero_lowers = uint224(upper_other) * lower_self; // * 2^-112

        // so the bit shift does not overflow
        require(upper <= type(uint112).max, "FixedPoint::muluq: upper overflow");

        // this cannot exceed 256 bits, all values are 224 bits
        uint256 sum = uint256(upper << RESOLUTION) + uppers_lowero + uppero_lowers + (lower >> RESOLUTION);

        // so the cast does not overflow
        require(sum <= type(uint224).max, "FixedPoint::muluq: sum overflow");

        return uq112x112(uint224(sum));
    }

    // divide a UQ112x112 by a UQ112x112, returning a UQ112x112
    function divuq(uq112x112 memory self, uq112x112 memory other) internal pure returns (uq112x112 memory) {
        require(other._x > 0, "FixedPoint::divuq: division by zero");
        if (self._x == other._x) {
            return uq112x112(uint224(Q112));
        }
        if (self._x <= type(uint144).max) {
            uint256 value = (uint256(self._x) << RESOLUTION) / other._x;
            require(value <= type(uint224).max, "FixedPoint::divuq: overflow");
            return uq112x112(uint224(value));
        }

        uint256 result = FullMath.mulDiv(Q112, self._x, other._x);
        require(result <= type(uint224).max, "FixedPoint::divuq: overflow");
        return uq112x112(uint224(result));
    }

    // returns a UQ112x112 which represents the ratio of the numerator to the denominator
    // can be lossy
    function fraction(uint256 numerator, uint256 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint::fraction: division by zero");
        if (numerator == 0) return FixedPoint.uq112x112(0);

        if (numerator <= type(uint144).max) {
            uint256 result = (numerator << RESOLUTION) / denominator;
            require(result <= type(uint224).max, "FixedPoint::fraction: overflow");
            return uq112x112(uint224(result));
        } else {
            uint256 result = FullMath.mulDiv(numerator, Q112, denominator);
            require(result <= type(uint224).max, "FixedPoint::fraction: overflow");
            return uq112x112(uint224(result));
        }
    }

    // take the reciprocal of a UQ112x112
    // reverts on overflow
    // lossy
    function reciprocal(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        require(self._x != 0, "FixedPoint::reciprocal: reciprocal of zero");
        require(self._x != 1, "FixedPoint::reciprocal: overflow");
        return uq112x112(uint224(Q224 / self._x));
    }

    // square root of a UQ112x112
    // lossy between 0/1 and 40 bits
    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        if (self._x <= type(uint144).max) {
            return uq112x112(uint224(Babylonian.sqrt(uint256(self._x) << 112)));
        }

        uint8 safeShiftBits = 255 - BitMath.mostSignificantBit(self._x);
        safeShiftBits -= safeShiftBits % 2;
        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x) << safeShiftBits) << ((112 - safeShiftBits) / 2)));
    }
}

// 

pragma solidity >=0.8.0;

// computes square roots using the babylonian method
// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method
library Babylonian {
    // credit for this implementation goes to
    // https://github.com/abdk-consulting/abdk-libraries-solidity/blob/master/ABDKMath64x64.sol#L687
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        // this block is equivalent to r = uint256(1) << (BitMath.mostSignificantBit(x) / 2);
        // however that code costs significantly more gas
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }
}

// 
pragma solidity >=0.8.0;

library BitMath {
    // returns the 0 indexed position of the most significant bit of the input x
    // s.t. x >= 2**msb and x < 2**(msb+1)
    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0, "BitMath::mostSignificantBit: zero");

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        if (x >= 0x2) r += 1;
    }

    // returns the 0 indexed position of the least significant bit of the input x
    // s.t. (x & 2**lsb) != 0 and (x & (2**(lsb) - 1)) == 0)
    // i.e. the bit at the index is set and the mask of all lower bits is 0
    function leastSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0, "BitMath::leastSignificantBit: zero");

        r = 255;
        if (x & type(uint128).max > 0) {
            r -= 128;
        } else {
            x >>= 128;
        }
        if (x & type(uint64).max > 0) {
            r -= 64;
        } else {
            x >>= 64;
        }
        if (x & type(uint32).max > 0) {
            r -= 32;
        } else {
            x >>= 32;
        }
        if (x & type(uint16).max > 0) {
            r -= 16;
        } else {
            x >>= 16;
        }
        if (x & type(uint16).max > 0) {
            r -= 8;
        } else {
            x >>= 8;
        }
        if (x & 0xf > 0) {
            r -= 4;
        } else {
            x >>= 4;
        }
        if (x & 0x3 > 0) {
            r -= 2;
        } else {
            x >>= 2;
        }
        if (x & 0x1 > 0) r -= 1;
    }
}

// 
pragma solidity >=0.8.0;

// taken from https://medium.com/coinmonks/math-in-solidity-part-3-percents-and-proportions-4db014e080b1
// license is CC-BY-4.0
library FullMath {
    function fullMul(uint256 x, uint256 y) internal pure returns (uint256 l, uint256 h) {
        uint256 mm = mulmod(x, y, type(uint256).max);
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }

    function fullDiv(
        uint256 l,
        uint256 h,
        uint256 d
    ) private pure returns (uint256) {
        uint256 pow2 = d & (type(uint256).max - d + 1) & d;
        d /= pow2;
        l /= pow2;
        l += h * (((type(uint256).max - pow2 + 1) & pow2) / pow2 + 1);
        uint256 r = 1;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        return l * r;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 d
    ) internal pure returns (uint256) {
        (uint256 l, uint256 h) = fullMul(x, y);

        uint256 mm = mulmod(x, y, d);
        if (mm > l) h -= 1;
        l -= mm;

        if (h == 0) return l / d;

        require(h < d, "FullMath: FULLDIV_OVERFLOW");
        return fullDiv(l, h, d);
    }
}