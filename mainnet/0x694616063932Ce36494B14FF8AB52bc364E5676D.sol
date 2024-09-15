// SPDX-License-Identifier: MIT


// 
pragma solidity >=0.7.6 <0.9.0;


interface IMagician {
    
    
    
    
    
    function towardsNative(address _asset, uint256 _amount) external returns (address tokenOut, uint256 amountOut);

    
    
    
    
    
    function towardsAsset(address _asset, uint256 _amount) external returns (address tokenOut, uint256 amountOut);
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
}// 
pragma solidity 0.8.13;







/// IT IS NOT PART OF THE PROTOCOL. SILO CREATED THIS TOOL, MOSTLY AS AN EXAMPLE.
contract GOHMMagician is IMagician {
    
    uint256 public constant TWO_EXTRA_WEIS = (1 wei) + (1 wei);

    
    bool public constant OLYMPUS_STAKING_CLAIM = true;

    
    bool public constant OLYMPUS_STAKING_REBASING = false;

    
    bool public constant OLYMPUS_STAKING_TRIGGER = false;

    
    uint256 public constant SWAP_AMOUNT_OUT_LIMIT = type(uint256).max;

    
    uint256 public constant SWAP_AMOUNT_IN_LIMIT = 1;

    
    // solhint-disable-next-line var-name-mixedcase
    IBalancerVaultLike public immutable BALANCER_VAULT;

    
    // solhint-disable-next-line var-name-mixedcase
    bytes32 public immutable BALANCER_OHM_POOL;

    
    // solhint-disable-next-line var-name-mixedcase
    address public immutable QUOTE;

    
    // solhint-disable-next-line var-name-mixedcase
    uint256 public immutable TEN_POW_GOHM_DECIMALS;

    
    // solhint-disable-next-line var-name-mixedcase
    address public immutable OHM;

    
    // solhint-disable-next-line var-name-mixedcase
    IGOHMLikeV2 public immutable GOHM;

    
    // solhint-disable-next-line var-name-mixedcase
    IOlympusStakingV3Like public immutable OLYMPUS_STAKING_V3;

    error InvalidAsset();
    error InvalidBalancerPool();

    constructor(
        address _quote,
        IOlympusStakingV3Like _olympusStakingV3,
        IBalancerVaultLike _balancerVault,
        bytes32 _balancerOhmPool
    ) {
        QUOTE = _quote;

        GOHM = IGOHMLikeV2(_olympusStakingV3.gOHM());
        TEN_POW_GOHM_DECIMALS = 10 ** GOHM.decimals();
        OHM = _olympusStakingV3.OHM();

        OLYMPUS_STAKING_V3 = _olympusStakingV3;
        BALANCER_VAULT = _balancerVault;
        BALANCER_OHM_POOL = _balancerOhmPool;

        if (!verifyPoolAndVault(_balancerVault, _balancerOhmPool)) revert InvalidBalancerPool();
    }

    
    function towardsNative(address _asset, uint256 _amount) external returns (address, uint256) {
        if (_asset != address(GOHM)) revert InvalidAsset();

        GOHM.approve(address(OLYMPUS_STAKING_V3), _amount);

        uint256 ohmAmount = OLYMPUS_STAKING_V3.unstake(
            address(this),
                _amount,
                OLYMPUS_STAKING_TRIGGER,
                OLYMPUS_STAKING_REBASING
        );

        return (QUOTE, _swapOHMForQuote(ohmAmount));
    }

    
    function towardsAsset(address _asset, uint256 _amount) external returns (address, uint256) {
        if (_asset != address(GOHM)) revert InvalidAsset();

        uint256 ohmAmount = ohmBalanceFrom(_amount);
        uint256 quoteSpent = _swapQuoteForOHM(ohmAmount);

        IERC20(OHM).approve(address(OLYMPUS_STAKING_V3), ohmAmount);
        OLYMPUS_STAKING_V3.stake(address(this), ohmAmount, OLYMPUS_STAKING_REBASING, OLYMPUS_STAKING_CLAIM);

        return (address(GOHM), quoteSpent);
    }

    
    ///     Our goal is to calculate right amount of OHM that will give us `_gOhmAmount` when we stake it.
    ///     2 extra weis added to make sure that we will not receive less than `_gOhmAmount`.
    ///     First `1 wei` explanation:
    ///     We can lose up to one wei on step of OHM -> gOHM inside OlympusStaking.stake():
    ///     OHM -> gOHM formula: `ohmAmount * (10**18) / (index);`.
    ///     The operation of `/(index)` can cause the lost of [0..index-1] from `ohmAmount * (10**18)`.
    ///     If we add 1 wei to `ohmAmount`, `(ohmAmount + 1 wei) * (10**18) > ohmAmount * (10**18) - (index - 1)`.
    ///     Index has 9 basis points, it will work until it will not increase 10**18.
    ///     Second `1 wei` explanation:
    ///     We can lose up to one wei on step of gOHM -> OHM calculation below.
    ///     gOHM -> OHM formula: `(gOhmAmount * index) / (10**18)`.
    ///     The operation of `/ (10**18)` can cause the lost of [0..10**18 - 1] from `(gOhmAmount * index)`.
    ///     Let's add extra wei to gOHM -> OHM formula.
    ///     Then on gOHM -> OHM calculations, worst case scenario:
    ///     ((gOhmAmount * index) / (10**18) + 1) * (10**18) / (index) >=
    ///     = (gOhmAmount * index - (10**18 - 1) + 10**18) / index =
    ///     = (gOhmAmount * index + 1) / index >= gOhmAmount
    
    
    function ohmBalanceFrom(uint256 _gOhmAmount) public view returns (uint256 ohmAmount) {
        ohmAmount = _gOhmAmount * GOHM.index();

        // we can safely divide by 10 ** 18 and add 2
        unchecked {
            ohmAmount = ohmAmount / TEN_POW_GOHM_DECIMALS + TWO_EXTRA_WEIS;
        }
    }

    
    ///     Pool is valid if it has OHMv2 and quote tokens.
    
    
    
    function verifyPoolAndVault(IBalancerVaultLike _balancerVault, bytes32 _poolId) public view returns (bool) {
        (address[] memory tokens,,) = IBalancerVaultLike(_balancerVault).getPoolTokens(_poolId);
        bool isQuote;
        bool isOhm;

        for (uint256 i; i < tokens.length && !(isOhm && isQuote);) {
            if (!isOhm && tokens[i] == OHM) {
                isOhm = true;
            } else if (!isQuote && tokens[i] == QUOTE) {
                isQuote = true;
            }

            unchecked {
                i++;
            }
        }

        return isQuote && isOhm;
    }

    
    
    
    function _swapOHMForQuote(uint256 _ohmAmount) internal returns (uint256 quoteReceived) {
        IERC20(OHM).approve(address(BALANCER_VAULT), _ohmAmount);
        quoteReceived = _swapAmountIn(OHM, QUOTE, _ohmAmount, BALANCER_OHM_POOL);
    }

    
    
    
    function _swapQuoteForOHM(uint256 _ohmAmount) internal returns (uint256 quoteSpent) {
        IERC20(QUOTE).approve(address(BALANCER_VAULT), SWAP_AMOUNT_OUT_LIMIT);
        quoteSpent = _swapAmountOut(QUOTE, OHM, _ohmAmount, BALANCER_OHM_POOL);
    }

    
    
    
    
    
    
    function _swapAmountOut(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountOut,
        bytes32 _poolId
    ) internal returns (uint256) {
        IBalancerVaultLike.SingleSwap memory singleSwap = IBalancerVaultLike.SingleSwap(
            _poolId, IBalancerVaultLike.SwapKind.GIVEN_OUT, address(_tokenIn), address(_tokenOut), _amountOut, ""
        );

        IBalancerVaultLike.FundManagement memory funds = IBalancerVaultLike.FundManagement(
            address(this), false, payable(address(this)), false
        );

        return BALANCER_VAULT.swap(singleSwap, funds, SWAP_AMOUNT_OUT_LIMIT, block.timestamp);
    }

    
    
    
    
    
    
    function _swapAmountIn(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        bytes32 _poolId
    ) internal returns (uint256) {
        IBalancerVaultLike.SingleSwap memory singleSwap = IBalancerVaultLike.SingleSwap(
            _poolId, IBalancerVaultLike.SwapKind.GIVEN_IN, address(_tokenIn), address(_tokenOut), _amountIn, ""
        );

        IBalancerVaultLike.FundManagement memory funds = IBalancerVaultLike.FundManagement(
            address(this), false, payable(address(this)), false
        );

        return BALANCER_VAULT.swap(singleSwap, funds, SWAP_AMOUNT_IN_LIMIT, block.timestamp);
    }
}

// 
pragma solidity 0.8.13;


/// that are required for the gOHM magician contract.
interface IOlympusStakingV3Like {
    function unstake(
        address _to,
        uint256 _amount,
        bool _trigger,
        bool _rebasing
    ) external returns (uint256 amount_);

    function stake(
        address _to,
        uint256 _amount,
        bool _rebasing,
        bool _claim
    ) external returns (uint256);

    // solhint-disable-next-line func-name-mixedcase
    function OHM() external view returns (address);
    function gOHM() external view returns (address);
}

// 
pragma solidity 0.8.13;



interface IGOHMLikeV2 is IERC20 {
    function index() external view returns (uint256);
    function decimals() external view returns (uint256);
}

// 
pragma solidity 0.8.13;

interface IBalancerVaultLike {
    enum SwapKind { GIVEN_IN, GIVEN_OUT }

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        address assetIn;
        address assetOut;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    ) external payable returns (uint256);

    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (
            address[] memory tokens,
            uint256[] memory balances,
            uint256 lastChangeBlock
        );
}
