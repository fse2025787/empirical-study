// SPDX-License-Identifier: GPL-2.0-or-later


// 
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external view returns (address);

    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external view returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external view returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external view returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}
// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;


enum AdapterType {
    ABSTRACT,
    UNISWAP_V2_ROUTER,
    UNISWAP_V3_ROUTER,
    CURVE_V1_EXCHANGE_ONLY,
    YEARN_V2,
    CURVE_V1_2ASSETS,
    CURVE_V1_3ASSETS,
    CURVE_V1_4ASSETS,
    CURVE_V1_STECRV_POOL,
    CURVE_V1_WRAPPER,
    CONVEX_V1_BASE_REWARD_POOL,
    CONVEX_V1_BOOSTER,
    CONVEX_V1_CLAIM_ZAP,
    LIDO_V1,
    UNIVERSAL,
    LIDO_WSTETH_V1
}

interface IAdapterExceptions {
    
    ///      that is not recognized as collateral in the connected
    ///      Credit Manager
    error TokenIsNotInAllowedList(address);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;


interface IPriceOracleV2Events {
    
    event NewPriceFeed(address indexed token, address indexed priceFeed);
}

interface IPriceOracleV2Exceptions {
    
    error ZeroPriceException();

    
    error ChainPriceStaleException();

    
    error PriceOracleNotExistsException();
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;



interface IVersion {
    
    function version() external view returns (uint256);
}

interface IAdapter is IAdapterExceptions {
    
    function creditManager() external view returns (ICreditManagerV2);

    
    function creditFacade() external view returns (address);

    
    function targetContract() external view returns (address);

    
    function _gearboxAdapterType() external pure returns (AdapterType);

    
    function _gearboxAdapterVersion() external pure returns (uint16);
}

// 
pragma solidity >=0.6.2;



interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external view override returns (address);

    function WETH() external view override returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        override
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        override
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external override returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external override returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable override returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable override returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external view override returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external view override returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external view override returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        override
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        override
        returns (uint256[] memory amounts);
}

// 
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;

// Denominations

uint256 constant WAD = 1e18;
uint256 constant RAY = 1e27;

// 25% of type(uint256).max
uint256 constant ALLOWANCE_THRESHOLD = type(uint96).max >> 3;

// FEE = 50%
uint16 constant DEFAULT_FEE_INTEREST = 50_00; // 50%

// LIQUIDATION_FEE 1.5%
uint16 constant DEFAULT_FEE_LIQUIDATION = 1_50; // 1.5%

// LIQUIDATION PREMIUM 4%
uint16 constant DEFAULT_LIQUIDATION_PREMIUM = 4_00; // 4%

// LIQUIDATION_FEE_EXPIRED 2%
uint16 constant DEFAULT_FEE_LIQUIDATION_EXPIRED = 1_00; // 2%

// LIQUIDATION PREMIUM EXPIRED 2%
uint16 constant DEFAULT_LIQUIDATION_PREMIUM_EXPIRED = 2_00; // 2%

// DEFAULT PROPORTION OF MAX BORROWED PER BLOCK TO MAX BORROWED PER ACCOUNT
uint16 constant DEFAULT_LIMIT_PER_BLOCK_MULTIPLIER = 2;

// Seconds in a year
uint256 constant SECONDS_PER_YEAR = 365 days;
uint256 constant SECONDS_PER_ONE_AND_HALF_YEAR = (SECONDS_PER_YEAR * 3) / 2;

// OPERATIONS

// Leverage decimals - 100 is equal to 2x leverage (100% * collateral amount + 100% * borrowed amount)
uint8 constant LEVERAGE_DECIMALS = 100;

// Maximum withdraw fee for pool in PERCENTAGE_FACTOR format
uint8 constant MAX_WITHDRAW_FEE = 100;

uint256 constant EXACT_INPUT = 1;
uint256 constant EXACT_OUTPUT = 2;

address constant UNIVERSAL_CONTRACT = 0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC;

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;






abstract contract AbstractAdapter is IAdapter {
    using Address for address;

    ICreditManagerV2 public immutable override creditManager;
    address public immutable override creditFacade;
    address public immutable override targetContract;

    constructor(address _creditManager, address _targetContract) {
        if (_creditManager == address(0) || _targetContract == address(0))
            revert ZeroAddressException(); // F:[AA-2]

        creditManager = ICreditManagerV2(_creditManager); // F:[AA-1]
        creditFacade = ICreditManagerV2(_creditManager).creditFacade(); // F:[AA-1]
        targetContract = _targetContract; // F:[AA-1]
    }

    
    
    
    function _approveToken(address token, uint256 amount) internal {
        creditManager.approveCreditAccount(
            msg.sender,
            targetContract,
            token,
            amount
        );
    }

    
    
    function _execute(bytes memory callData)
        internal
        returns (bytes memory result)
    {
        result = creditManager.executeOrder(
            msg.sender,
            targetContract,
            callData
        );
    }

    
    
    
    
    
    
    
    
    function _executeMaxAllowanceFastCheck(
        address creditAccount,
        address tokenIn,
        address tokenOut,
        bytes memory callData,
        bool allowTokenIn,
        bool disableTokenIn
    ) internal returns (bytes memory result) {
        uint256 balanceInBefore;
        uint256 balanceOutBefore;

        if (msg.sender != creditFacade) {
            balanceInBefore = IERC20(tokenIn).balanceOf(creditAccount); // F:[AA-4A]
            balanceOutBefore = IERC20(tokenOut).balanceOf(creditAccount); // F:[AA-4A]
        }

        if (allowTokenIn) {
            _approveToken(tokenIn, type(uint256).max);
        }

        result = creditManager.executeOrder(
            msg.sender,
            targetContract,
            callData
        );

        if (allowTokenIn) {
            _approveToken(tokenIn, type(uint256).max);
        }

        _fastCheck(
            creditAccount,
            tokenIn,
            tokenOut,
            balanceInBefore,
            balanceOutBefore,
            disableTokenIn
        );
    }

    
    /// See params and other details above
    function _executeMaxAllowanceFastCheck(
        address tokenIn,
        address tokenOut,
        bytes memory callData,
        bool allowTokenIn,
        bool disableTokenIn
    ) internal returns (bytes memory result) {
        address creditAccount = creditManager.getCreditAccountOrRevert(
            msg.sender
        ); // F:[AA-3]

        result = _executeMaxAllowanceFastCheck(
            creditAccount,
            tokenIn,
            tokenOut,
            callData,
            allowTokenIn,
            disableTokenIn
        );
    }

    
    
    
    
    
    
    
    function _safeExecuteFastCheck(
        address creditAccount,
        address tokenIn,
        address tokenOut,
        bytes memory callData,
        bool allowTokenIn,
        bool disableTokenIn
    ) internal returns (bytes memory result) {
        uint256 balanceInBefore;
        uint256 balanceOutBefore;

        if (msg.sender != creditFacade) {
            balanceInBefore = IERC20(tokenIn).balanceOf(creditAccount);
            balanceOutBefore = IERC20(tokenOut).balanceOf(creditAccount); // F:[AA-4A]
        }

        if (allowTokenIn) {
            _approveToken(tokenIn, type(uint256).max);
        }

        result = creditManager.executeOrder(
            msg.sender,
            targetContract,
            callData
        );

        if (allowTokenIn) {
            _approveToken(tokenIn, 1);
        }

        _fastCheck(
            creditAccount,
            tokenIn,
            tokenOut,
            balanceInBefore,
            balanceOutBefore,
            disableTokenIn
        );
    }

    
    /// See params and other details above
    function _safeExecuteFastCheck(
        address tokenIn,
        address tokenOut,
        bytes memory callData,
        bool allowTokenIn,
        bool disableTokenIn
    ) internal returns (bytes memory result) {
        address creditAccount = creditManager.getCreditAccountOrRevert(
            msg.sender
        );

        result = _safeExecuteFastCheck(
            creditAccount,
            tokenIn,
            tokenOut,
            callData,
            allowTokenIn,
            disableTokenIn
        );
    }

    //
    // HEALTH CHECK FUNCTIONS
    //

    
    /// it for multicalls (since a full collateral check is always performed after a multicall)
    
    
    
    
    
    
    function _fastCheck(
        address creditAccount,
        address tokenIn,
        address tokenOut,
        uint256 balanceInBefore,
        uint256 balanceOutBefore,
        bool disableTokenIn
    ) private {
        if (msg.sender != creditFacade) {
            creditManager.fastCollateralCheck(
                creditAccount,
                tokenIn,
                tokenOut,
                balanceInBefore,
                balanceOutBefore
            );
        } else {
            if (disableTokenIn)
                creditManager.disableToken(creditAccount, tokenIn);
            creditManager.checkAndEnableToken(creditAccount, tokenOut);
        }
    }

    
    /// it for multicalls (since a full collateral check is always performed after a multicall)
    
    function _fullCheck(address creditAccount) internal {
        if (msg.sender != creditFacade) {
            creditManager.fullCollateralCheck(creditAccount);
        }
    }

    
    /// it for multicalls (since a full collateral check is always performed after a multicall,
    /// and includes enabled token optimization by default)
    
    
    ///         (e.g., claiming rewards)
    function _checkAndOptimizeEnabledTokens(address creditAccount) internal {
        if (msg.sender != creditFacade) {
            creditManager.checkAndOptimizeEnabledTokens(creditAccount);
        }
    }
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;




interface IUniswapV2Adapter is IAdapter, IUniswapV2Router02 {
    
    
    
    ///        addresses must exist and have liquidity.
    
    
    function swapAllTokensForTokens(
        uint256 rateMinRAY,
        address[] calldata path,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;




enum ClosureAction {
    CLOSE_ACCOUNT,
    LIQUIDATE_ACCOUNT,
    LIQUIDATE_EXPIRED_ACCOUNT,
    LIQUIDATE_PAUSED
}

interface ICreditManagerV2Events {
    
    event ExecuteOrder(address indexed borrower, address indexed target);

    
    event NewConfigurator(address indexed newConfigurator);
}

interface ICreditManagerV2Exceptions {
    
    ///      the connected Credit Facade, or an allowed adapter
    error AdaptersOrCreditFacadeOnlyException();

    
    ///      the connected Credit Facade
    error CreditFacadeOnlyException();

    
    ///      the connected Credit Configurator
    error CreditConfiguratorOnlyException();

    
    ///      to the zero address or an address that already owns a Credit Account
    error ZeroAddressOrUserAlreadyHasAccountException();

    
    ///      target contract
    error TargetContractNotAllowedException();

    
    error NotEnoughCollateralException();

    
    ///      or was forbidden
    error TokenNotAllowedException();

    
    error AllowanceFailedException();

    
    error HasNoOpenedAccountException();

    
    error TokenAlreadyAddedException();

    
    error TooManyTokensException();

    
    ///      and there are not enough unused token to disable
    error TooManyEnabledTokensException();

    
    error ReentrancyLockException();
}


interface IPriceOracleV2 is
    IPriceOracleV2Events,
    IPriceOracleV2Exceptions,
    IVersion
{
    
    
    
    function convertToUSD(uint256 amount, address token)
        external
        view
        returns (uint256);

    
    
    
    function convertFromUSD(uint256 amount, address token)
        external
        view
        returns (uint256);

    
    ///
    
    
    
    function convert(
        uint256 amount,
        address tokenFrom,
        address tokenTo
    ) external view returns (uint256);

    
    
    
    
    
    
    
    function fastCheck(
        uint256 amountFrom,
        address tokenFrom,
        uint256 amountTo,
        address tokenTo
    ) external view returns (uint256 collateralFrom, uint256 collateralTo);

    
    
    function getPrice(address token) external view returns (uint256);

    
    
    function priceFeeds(address token)
        external
        view
        returns (address priceFeed);

    
    ///      with additional parameters
    
    function priceFeedsWithFlags(address token)
        external
        view
        returns (
            address priceFeed,
            bool skipCheck,
            uint256 decimals
        );
}
// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;











// EXCEPTIONS



contract UniswapV2Adapter is
    AbstractAdapter,
    IUniswapV2Adapter,
    ReentrancyGuard
{
    AdapterType public constant _gearboxAdapterType =
        AdapterType.UNISWAP_V2_ROUTER;
    uint16 public constant _gearboxAdapterVersion = 2;

    
    
    
    constructor(address _creditManager, address _router)
        AbstractAdapter(_creditManager, _router)
    {}

    /**
     * @dev Sends an order to swap tokens to exact tokens using a Uniswap-compatible protocol
     * - Makes a max allowance fast check call to target, replacing the `to` parameter with the CA address
     * @param amountOut The amount of output tokens to receive.
     * @param amountInMax The maximum amount of input tokens that can be required before the transaction reverts.
     * @param path An array of token addresses. path.length must be >= 2. Pools for each consecutive pair of
     *        addresses must exist and have liquidity.
     * @param deadline Unix timestamp after which the transaction will revert.
     * for more information, see: https://uniswap.org/docs/v2/smart-contracts/router02/
     * @notice `to` is ignored, since it is forbidden to transfer funds from a CA
     * @notice Fast check parameters:
     * Input token: First token in the path
     * Output token: Last token in the path
     * Input token is allowed, since the target does a transferFrom for the input token
     * The input token does not need to be disabled, because this does not spend the entire
     * balance, generally
     */
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address,
        uint256 deadline
    ) external override nonReentrant returns (uint256[] memory amounts) {
        address creditAccount = creditManager.getCreditAccountOrRevert(
            msg.sender
        ); // F:[AUV2-1]

        address tokenIn = path[0]; // F:[AUV2-2]
        address tokenOut = path[path.length - 1]; // F:[AUV2-2]

        amounts = abi.decode(
            _executeMaxAllowanceFastCheck(
                creditAccount,
                tokenIn,
                tokenOut,
                abi.encodeWithSelector(
                    IUniswapV2Router02.swapTokensForExactTokens.selector,
                    amountOut,
                    amountInMax,
                    path,
                    creditAccount,
                    deadline
                ),
                true,
                false
            ),
            (uint256[])
        ); // F:[AUV2-2]
    }

    /**
     * @dev Sends an order to swap an exact amount of token to another token using a Uniswap-compatible protocol
     * - Makes a max allowance fast check call to target, replacing the `to` parameter with the CA address
     * @param amountIn The amount of input tokens to send.
     * @param amountOutMin The minimum amount of output tokens that must be received for the transaction not to revert.
     * @param path An array of token addresses. path.length must be >= 2. Pools for each consecutive pair of
     *        addresses must exist and have liquidity.
     * @param deadline Unix timestamp after which the transaction will revert.
     * for more information, see: https://uniswap.org/docs/v2/smart-contracts/router02/
     * @notice `to` is ignored, since it is forbidden to transfer funds from a CA
     * @notice Fast check parameters:
     * Input token: First token in the path
     * Output token: Last token in the path
     * Input token is allowed, since the target does a transferFrom for the input token
     * The input token does not need to be disabled, because this does not spend the entire
     * balance, generally
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address,
        uint256 deadline
    ) external override nonReentrant returns (uint256[] memory amounts) {
        address creditAccount = creditManager.getCreditAccountOrRevert(
            msg.sender
        ); // F:[AUV2-1]

        address tokenIn = path[0]; // F:[AUV2-3]
        address tokenOut = path[path.length - 1]; // F:[AUV2-3]

        amounts = abi.decode(
            _executeMaxAllowanceFastCheck(
                creditAccount,
                tokenIn,
                tokenOut,
                abi.encodeWithSelector(
                    IUniswapV2Router02.swapExactTokensForTokens.selector,
                    amountIn,
                    amountOutMin,
                    path,
                    creditAccount,
                    deadline
                ),
                true,
                false
            ),
            (uint256[])
        ); // F:[AUV2-3]
    }

    /**
     * @dev Sends an order to swap the entire token balance to another token using a Uniswap-compatible protocol
     * - Makes a max allowance fast check call to target, replacing the `to` parameter with the CA address
     * @param rateMinRAY The minimal exchange rate between the input and the output tokens.
     * @param path An array of token addresses. path.length must be >= 2. Pools for each consecutive pair of
     *        addresses must exist and have liquidity.
     * @param deadline Unix timestamp after which the transaction will revert.
     * for more information, see: https://uniswap.org/docs/v2/smart-contracts/router02/
     * @notice Under the hood, calls swapExactTokensForTokens, passing balance minus 1 as the amount
     * @notice Fast check parameters:
     * Input token: First token in the path
     * Output token: Last token in the path
     * Input token is allowed, since the target does a transferFrom for the input token
     * The input token does need to be disabled, because this spends the entire balance
     */
    function swapAllTokensForTokens(
        uint256 rateMinRAY,
        address[] calldata path,
        uint256 deadline
    ) external override nonReentrant returns (uint256[] memory amounts) {
        address creditAccount = creditManager.getCreditAccountOrRevert(
            msg.sender
        ); // F:[AUV2-1]

        address tokenIn = path[0]; // F:[AUV2-4]
        address tokenOut = path[path.length - 1]; // F:[AUV2-4]

        uint256 balanceInBefore = IERC20(tokenIn).balanceOf(creditAccount); // F:[AUV2-4]

        if (balanceInBefore > 1) {
            unchecked {
                balanceInBefore--;
            }

            amounts = abi.decode(
                _executeMaxAllowanceFastCheck(
                    creditAccount,
                    tokenIn,
                    tokenOut,
                    abi.encodeWithSelector(
                        IUniswapV2Router02.swapExactTokensForTokens.selector,
                        balanceInBefore,
                        (balanceInBefore * rateMinRAY) / RAY,
                        path,
                        creditAccount,
                        deadline
                    ),
                    true,
                    true
                ),
                (uint256[])
            ); // F:[AUV2-4]
        }
    }

    
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address, // token,
        uint256, // liquidity,
        uint256, // amountTokenMin,
        uint256, // amountETHMin,
        address, // to,
        uint256 // deadline
    ) external pure override returns (uint256) {
        revert NotImplementedException();
    }

    
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address, // token,
        uint256, // liquidity,
        uint256, // amountTokenMin,
        uint256, // amountETHMin,
        address, // to,
        uint256, // deadline,
        bool, // approveMax,
        uint8, // v,
        bytes32, // r,
        bytes32 // s
    ) external pure override returns (uint256) {
        revert NotImplementedException();
    }

    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256, // amountIn,
        uint256, // amountOutMin,
        address[] calldata, // path,
        address, // to,
        uint256 // deadline
    ) external pure override {
        revert NotImplementedException();
    }

    
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256, // amountOutMin,
        address[] calldata, // path,
        address, // to,
        uint256 // deadline
    ) external payable override {
        revert NotImplementedException();
    }

    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256, // amountIn,
        uint256, // amountOutMin,
        address[] calldata, // path,
        address, // to,
        uint256 // deadline
    ) external pure override {
        revert NotImplementedException();
    }

    
    function factory() external view override returns (address) {
        return IUniswapV2Router02(targetContract).factory();
    }

    
    function WETH() external view override returns (address) {
        return IUniswapV2Router02(targetContract).WETH();
    }

    
    function addLiquidity(
        address, // tokenA,
        address, // tokenB,
        uint256, // amountADesired,
        uint256, // amountBDesired,
        uint256, // amountAMin,
        uint256, // amountBMin,
        address, // to,
        uint256 // deadline
    )
        external
        pure
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        revert NotImplementedException();
    }

    
    function addLiquidityETH(
        address, // token,
        uint256, // amountTokenDesired,
        uint256, // amountTokenMin,
        uint256, // amountETHMin,
        address, // to,
        uint256 // deadline
    )
        external
        payable
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        revert NotImplementedException();
    }

    
    function removeLiquidity(
        address, // tokenA,
        address, // tokenB,
        uint256, // liquidity,
        uint256, // amountAMin,
        uint256, // amountBMin,
        address, // to,
        uint256 // deadline
    ) external pure override returns (uint256, uint256) {
        revert NotImplementedException();
    }

    
    function removeLiquidityETH(
        address, // token,
        uint256, // liquidity,
        uint256, // amountTokenMin,
        uint256, // amountETHMin,
        address, // to,
        uint256 // deadline
    ) external pure override returns (uint256, uint256) {
        revert NotImplementedException();
    }

    
    function removeLiquidityWithPermit(
        address, // tokenA,
        address, // tokenB,
        uint256, // liquidity,
        uint256, // amountAMin,
        uint256, // amountBMin,
        address, // to,
        uint256, // deadline,
        bool, // approveMax,
        uint8, // v,
        bytes32, // r,
        bytes32 // s
    ) external pure override returns (uint256, uint256) {
        revert NotImplementedException();
    }

    
    function removeLiquidityETHWithPermit(
        address, // token,
        uint256, // liquidity,
        uint256, // amountTokenMin,
        uint256, // amountETHMin,
        address, // to,
        uint256, // deadline,
        bool, // approveMax,
        uint8, // v,
        bytes32, // r,
        bytes32 // s
    ) external pure override returns (uint256, uint256) {
        revert NotImplementedException();
    }

    
    function swapExactETHForTokens(
        uint256, // amountOutMin,
        address[] calldata, // path,
        address, // to,
        uint256 // deadline
    ) external payable override returns (uint256[] memory) {
        revert NotImplementedException();
    }

    
    function swapTokensForExactETH(
        uint256, // amountOut,
        uint256, // amountInMax,
        address[] calldata, // path,
        address, // to,
        uint256 // deadline
    ) external pure override returns (uint256[] memory) {
        revert NotImplementedException();
    }

    
    function swapExactTokensForETH(
        uint256, // amountIn,
        uint256, //amountOutMin,
        address[] calldata, // path,
        address, // to,
        uint256 // deadline
    ) external pure override returns (uint256[] memory) {
        revert NotImplementedException();
    }

    
    function swapETHForExactTokens(
        uint256, // amountOut,
        address[] calldata, // path,
        address, // to,
        uint256 // deadline
    ) external payable override returns (uint256[] memory) {
        revert NotImplementedException();
    }

    
    /// to a specifed amount of token A, not accounting for fees
    
    
    
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external view override returns (uint256 amountB) {
        return
            IUniswapV2Router02(targetContract).quote(
                amountA,
                reserveA,
                reserveB
            ); // F:[AUV2-5]
    }

    
    /// a specific amount of the input token
    
    
    
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external view override returns (uint256 amountOut) {
        return
            IUniswapV2Router02(targetContract).getAmountOut(
                amountIn,
                reserveIn,
                reserveOut
            ); // F:[AUV2-6]
    }

    
    /// receive a specified amount of the output token
    
    
    
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external view override returns (uint256 amountIn) {
        return
            IUniswapV2Router02(targetContract).getAmountIn(
                amountOut,
                reserveIn,
                reserveOut
            ); // F:[AUV2-7]
    }

    
    /// receive a specified amount of the output token
    
    
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        override
        returns (uint256[] memory amounts)
    {
        return IUniswapV2Router02(targetContract).getAmountsOut(amountIn, path); // F:[AUV2-8]
    }

    
    /// in order to receive the spcified amount
    /// receive a specified amount of the output token
    
    
    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        override
        returns (uint256[] memory amounts)
    {
        return IUniswapV2Router02(targetContract).getAmountsIn(amountOut, path); // F:[AUV2-9]
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.10;




error ZeroAddressException();


error NotImplementedException();


error AddressIsNotContractException(address);


error IncorrectTokenContractException();


///      correct price feed
error IncorrectPriceFeedException();


error CallerNotConfiguratorException();


error CallerNotPausableAdminException();


error CallerNotUnPausableAdminException();

error TokenIsNotAddedToCreditManagerException(address token);

// 
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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


///         by the Credit Facade or allowed adapters. Users are not allowed to
///         interact with the Credit Manager directly
interface ICreditManagerV2 is
    ICreditManagerV2Events,
    ICreditManagerV2Exceptions,
    IVersion
{
    //
    // CREDIT ACCOUNT MANAGEMENT
    //

    
    /// - Takes Credit Account from the factory;
    /// - Requests the pool to lend underlying to the Credit Account
    ///
    
    
    function openCreditAccount(uint256 borrowedAmount, address onBehalfOf)
        external
        returns (address);

    
    /// - Checks whether the contract is paused, and, if so, if the payer is an emergency liquidator.
    ///   Only emergency liquidators are able to liquidate account while the CM is paused.
    ///   Emergency liquidations do not pay a liquidator premium or liquidation fees.
    /// - Calculates payments to various recipients on closure:
    ///    + Computes amountToPool, which is the amount to be sent back to the pool.
    ///      This includes the principal, interest and fees, but can't be more than
    ///      total position value
    ///    + Computes remainingFunds during liquidations - these are leftover funds
    ///      after paying the pool and the liquidator, and are sent to the borrower
    ///    + Computes protocol profit, which includes interest and liquidation fees
    ///    + Computes loss if the totalValue is less than borrow amount + interest
    /// - Checks the underlying token balance:
    ///    + if it is larger than amountToPool, then the pool is paid fully from funds on the Credit Account
    ///    + else tries to transfer the shortfall from the payer - either the borrower during closure, or liquidator during liquidation
    /// - Send assets to the "to" address, as long as they are not included into skipTokenMask
    /// - If convertWETH is true, the function converts WETH into ETH before sending
    /// - Returns the Credit Account back to factory
    ///
    
    
    
    
    
    
    
    function closeCreditAccount(
        address borrower,
        ClosureAction closureActionType,
        uint256 totalValue,
        address payer,
        address to,
        uint256 skipTokenMask,
        bool convertWETH
    ) external returns (uint256 remainingFunds);

    
    ///
    /// - Increase debt:
    ///   + Increases debt by transferring funds from the pool to the credit account
    ///   + Updates the cumulative index to keep interest the same. Since interest
    ///     is always computed dynamically as borrowedAmount * (cumulativeIndexNew / cumulativeIndexOpen - 1),
    ///     cumulativeIndexOpen needs to be updated, as the borrow amount has changed
    ///
    /// - Decrease debt:
    ///   + Repays debt partially + all interest and fees accrued thus far
    ///   + Updates cunulativeIndex to cumulativeIndex now
    ///
    
    
    
    
    function manageDebt(
        address creditAccount,
        uint256 amount,
        bool increase
    ) external returns (uint256 newBorrowedAmount);

    
    
    
    
    
    function addCollateral(
        address payer,
        address creditAccount,
        address token,
        uint256 amount
    ) external;

    
    
    
    function transferAccountOwnership(address from, address to) external;

    
    
    
    
    
    function approveCreditAccount(
        address borrower,
        address targetContract,
        address token,
        uint256 amount
    ) external;

    
    /// This is the intended pathway for state-changing interactions with 3rd-party protocols
    
    
    
    function executeOrder(
        address borrower,
        address targetContract,
        bytes memory data
    ) external returns (bytes memory);

    //
    // COLLATERAL VALIDITY AND ACCOUNT HEALTH CHECKS
    //

    
    /// into account health and total value calculations
    
    
    function checkAndEnableToken(address creditAccount, address token) external;

    
    
    ///         participate in the operation and computes a % change in weighted value between
    ///         inbound and outbound collateral. The cumulative negative change across several
    ///         swaps in sequence cannot be larger than feeLiquidation (a fee that the
    ///         protocol is ready to waive if needed). Since this records a % change
    ///         between just two tokens, the corresponding % change in TWV will always be smaller,
    ///         which makes this check safe.
    ///         More details at https://dev.gearbox.fi/docs/documentation/risk/fast-collateral-check#fast-check-protection
    
    
    
    
    
    function fastCollateralCheck(
        address creditAccount,
        address tokenIn,
        address tokenOut,
        uint256 balanceInBefore,
        uint256 balanceOutBefore
    ) external;

    
    /// value of all enabled collateral tokens
    
    function fullCollateralCheck(address creditAccount) external;

    
    ///      does not violate the maximal enabled token limit and tries
    ///      to disable unused tokens if it does
    
    function checkAndOptimizeEnabledTokens(address creditAccount) external;

    
    
    ///         but can also be called separately from the Credit Facade to remove
    ///         unwanted tokens
    
    function disableToken(address creditAccount, address token)
        external
        returns (bool);

    //
    // GETTERS
    //

    
    
    function getCreditAccountOrRevert(address borrower)
        external
        view
        returns (address);

    
    
    
    ///        * CLOSE_ACCOUNT: The account is healthy and is closed normally
    ///        * LIQUIDATE_ACCOUNT: The account is unhealthy and is being liquidated to avoid bad debt
    ///        * LIQUIDATE_EXPIRED_ACCOUNT: The account has expired and is being liquidated (lowered liquidation premium)
    ///        * LIQUIDATE_PAUSED: The account is liquidated while the system is paused due to emergency (no liquidation premium)
    
    
    
    
    
    
    function calcClosePayments(
        uint256 totalValue,
        ClosureAction closureActionType,
        uint256 borrowedAmount,
        uint256 borrowedAmountWithInterest
    )
        external
        view
        returns (
            uint256 amountToPool,
            uint256 remainingFunds,
            uint256 profit,
            uint256 loss
        );

    
    
    
    
    
    function calcCreditAccountAccruedInterest(address creditAccount)
        external
        view
        returns (
            uint256 borrowedAmount,
            uint256 borrowedAmountWithInterest,
            uint256 borrowedAmountWithInterestAndFees
        );

    
    /// Only enabled tokens are counted as collateral for the Credit Account
    
    ///         the bit at the position equal to token's index to 1
    function enabledTokensMap(address creditAccount)
        external
        view
        returns (uint256);

    
    ///      the last full check, in RAY format
    function cumulativeDropAtFastCheckRAY(address creditAccount)
        external
        view
        returns (uint256);

    
    
    function collateralTokens(uint256 id)
        external
        view
        returns (address token, uint16 liquidationThreshold);

    
    
    function collateralTokensByMask(uint256 tokenMask)
        external
        view
        returns (address token, uint16 liquidationThreshold);

    
    function collateralTokensCount() external view returns (uint256);

    
    
    function tokenMasksMap(address token) external view returns (uint256);

    
    function forbiddenTokenMask() external view returns (uint256);

    
    function adapterToContract(address adapter) external view returns (address);

    
    function contractToAdapter(address targetContract)
        external
        view
        returns (address);

    
    function underlying() external view returns (address);

    
    function pool() external view returns (address);

    
    
    function poolService() external view returns (address);

    
    function creditAccounts(address borrower) external view returns (address);

    
    function creditConfigurator() external view returns (address);

    
    function wethAddress() external view returns (address);

    
    
    function liquidationThresholds(address token)
        external
        view
        returns (uint16);

    
    function maxAllowedEnabledTokenLength() external view returns (uint8);

    
    
    /// that are able to liquidate positions while the contracts are paused,
    /// e.g. when there is a risk of bad debt while an exploit is being patched.
    /// In the interest of fairness, emergency liquidators do not receive a premium
    /// And are compensated by the Gearbox DAO separately.
    function canLiquidateWhilePaused(address) external view returns (bool);

    
    
    
    ///         during unhealthy account liquidations
    
    ///         allowing the liquidator to take the unaccounted for remainder as premium. Equal to (1 - liquidationPremium)
    
    ///         during expired account liquidations
    
    ///         allowing the liquidator to take the unaccounted for remainder as premium. Equal to (1 - liquidationPremiumExpired)
    function fees()
        external
        view
        returns (
            uint16 feeInterest,
            uint16 feeLiquidation,
            uint16 liquidationDiscount,
            uint16 feeLiquidationExpired,
            uint16 liquidationDiscountExpired
        );

    
    function creditFacade() external view returns (address);

    
    function priceOracle() external view returns (IPriceOracleV2);

    
    function universalAdapter() external view returns (address);

    
    function version() external view returns (uint256);

    
    function checkEmergencyPausable(address caller, bool state)
        external
        returns (bool);
}

interface IPriceOracleV2Ext is IPriceOracleV2 {
    
    
    
    function addPriceFeed(address token, address priceFeed) external;
}
