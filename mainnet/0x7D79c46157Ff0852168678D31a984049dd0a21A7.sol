// SPDX-License-Identifier: AGPL-3.0


pragma solidity ^0.8.10;



error UNAUTHORIZED();
error AUTHORITY_INITIALIZED();


/// instead of pointing towards the logic to execute. Over many
/// functions this bloats contract size unnecessarily.
/// imho modifiers are a meme.
abstract contract OlympusAccessControlledV2 {
    /* ========== EVENTS ========== */

    event AuthorityUpdated(IOlympusAuthority authority);

    /* ========== STATE VARIABLES ========== */

    IOlympusAuthority public authority;

    /* ========== Constructor ========== */

    constructor(IOlympusAuthority _authority) {
        authority = _authority;
        emit AuthorityUpdated(_authority);
    }

    /* ========== "MODIFIERS" ========== */

    modifier onlyGovernor {
	_onlyGovernor();
	_;
    }

    modifier onlyGuardian {
	_onlyGuardian();
	_;
    }

    modifier onlyPolicy {
	_onlyPolicy();
	_;
    }

    modifier onlyVault {
	_onlyVault();
	_;
    }

    /* ========== GOV ONLY ========== */

    function initializeAuthority(IOlympusAuthority _newAuthority) internal {
        if (authority != IOlympusAuthority(address(0))) revert AUTHORITY_INITIALIZED();
        authority = _newAuthority;
        emit AuthorityUpdated(_newAuthority);
    }

    function setAuthority(IOlympusAuthority _newAuthority) external {
        _onlyGovernor();
        authority = _newAuthority;
        emit AuthorityUpdated(_newAuthority);
    }

    /* ========== INTERNAL CHECKS ========== */

    function _onlyGovernor() internal view {
        if (msg.sender != authority.governor()) revert UNAUTHORIZED();
    }

    function _onlyGuardian() internal view {
        if (msg.sender != authority.guardian()) revert UNAUTHORIZED();
    }

    function _onlyPolicy() internal view {
        if (msg.sender != authority.policy()) revert UNAUTHORIZED();
    }

    function _onlyVault() internal view {
        if (msg.sender != authority.vault()) revert UNAUTHORIZED();
    }
}

// 
pragma solidity >=0.7.5;

interface IUniswapV2ERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
// 
pragma solidity 0.8.10;








///         to make use of this contract ensure contract address is RESERVEMANAGER IN OHM Treasury
contract SushiMigrator is OlympusAccessControlledV2 {
    using SafeERC20 for IERC20;

    struct Amounts {
        uint128 sushiLpBeforeMigration;
        uint128 leftoverSushiLpAfterMigration;
        uint128 uniPoolToken0AddedToPool;
        uint128 uniPoolToken1AddedToPool;
        uint128 uniPoolLpReceived;
        uint128 uniPoolToken0ReturnedToTreasury;
        uint128 uniPoolToken1ReturnedToTreasury;
    }

    uint256 public txCount;

    mapping(uint256 => Amounts) public amountsByMigrationId;

    address immutable treasury = 0x9A315BdF513367C0377FB36545857d12e85813Ef;

    constructor(address _olympusAuthority) OlympusAccessControlledV2(IOlympusAuthority(_olympusAuthority)) {}

    
    
    
    
    
    
    
    
    function executeTx(
        address sushiRouter_,
        address uniRouter_,
        address sushiLpAddress_,
        address uniswapLpAddress_,
        uint256 amount_,
        uint256 removeLiquiditySlippage_,
        uint256 addLiquiditySlippage_
    ) external onlyGovernor {
        ITreasury(treasury).manage(sushiLpAddress_, amount_);

        uint256 amount = IUniswapV2Pair(sushiLpAddress_).balanceOf(address(this));

        (uint256 amountOHM, uint256 amountToken) = removeLiquidity(
            sushiLpAddress_,
            sushiRouter_,
            amount,
            removeLiquiditySlippage_
        );
        uint256 amountAfterTx = IUniswapV2Pair(sushiLpAddress_).balanceOf(address(this));
        (address token0, address token1, , ) = getTokenInfo(uniswapLpAddress_, address(this));

        (uint256 amountA, uint256 amountB, uint256 liquidity) = addLiquidity(
            uniRouter_,
            token0,
            token1,
            amountOHM,
            amountToken,
            addLiquiditySlippage_
        );

        amountsByMigrationId[txCount] = Amounts({
            sushiLpBeforeMigration: uint128(amount),
            leftoverSushiLpAfterMigration: uint128(amountAfterTx),
            uniPoolToken0AddedToPool: uint128(amountOHM),
            uniPoolToken1AddedToPool: uint128(amountToken),
            uniPoolLpReceived: uint128(liquidity),
            uniPoolToken0ReturnedToTreasury: uint128(amountA),
            uniPoolToken1ReturnedToTreasury: uint128(amountB)
        });

        txCount++;
    }

    
    
    
    
    
    function removeLiquidity(
        address pairAddr_,
        address router_,
        uint256 amount_,
        uint256 slippage_
    ) internal returns (uint256 amountOHM, uint256 amountToken) {
        (address token0, address token1, uint256 token0PoolBalance, uint256 token1PoolBalance) = getTokenInfo(
            pairAddr_,
            pairAddr_
        );

        uint256 amount1Min = (token0PoolBalance * amount_) / IUniswapV2Pair(pairAddr_).totalSupply();
        uint256 amount2Min = (token1PoolBalance * amount_) / IUniswapV2Pair(pairAddr_).totalSupply();

        IUniswapV2Pair(pairAddr_).approve(router_, amount_);

        (amountOHM, amountToken) = IUniswapV2Router(router_).removeLiquidity(
            token0,
            token1,
            amount_,
            (amount1Min * slippage_) / 1000,
            (amount2Min * slippage_) / 1000,
            address(this),
            type(uint256).max
        );
    }

    
    
    
    
    
    
    
    function addLiquidity(
        address router_,
        address token0_,
        address token1_,
        uint256 contractToken0Bal_,
        uint256 contractToken1Bal_,
        uint256 slippage_
    )
        internal
        returns (
            uint256 tokenAContractBalance,
            uint256 tokenBContractBalance,
            uint256 liquidity
        )
    {
        IERC20 token0 = IERC20(token0_);
        IERC20 token1 = IERC20(token1_);

        token0.approve(router_, contractToken0Bal_);
        token1.approve(router_, contractToken1Bal_);

        (, , liquidity) = IUniswapV2Router(router_).addLiquidity(
            token0_,
            token1_,
            contractToken0Bal_,
            contractToken1Bal_,
            (contractToken0Bal_ * slippage_) / 1000,
            (contractToken1Bal_ * slippage_) / 1000,
            treasury,
            type(uint256).max
        );

        tokenAContractBalance = token0.balanceOf((address(this)));
        tokenBContractBalance = token1.balanceOf((address(this)));

        if (tokenAContractBalance > 0) {
            token0.safeTransfer(treasury, tokenAContractBalance);
        }

        if (tokenBContractBalance > 0) {
            token1.safeTransfer(treasury, tokenBContractBalance);
        }
    }

    
    
    
    function getTokenInfo(address lp_, address addr_)
        public
        view
        returns (
            address,
            address,
            uint256,
            uint256
        )
    {
        address token0 = IUniswapV2Pair(lp_).token0();
        address token1 = IUniswapV2Pair(lp_).token1();

        uint256 token0Bal = IERC20(token0).balanceOf(addr_);
        uint256 token1Bal = IERC20(token1).balanceOf(addr_);

        return (token0, token1, token0Bal, token1Bal);
    }
}

// 
pragma solidity >=0.7.5;





/// Taken from Solmate
library SafeERC20 {
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FAILED");
    }

    function safeApprove(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.approve.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "APPROVE_FAILED");
    }

    function safeTransferETH(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}(new bytes(0));

        require(success, "ETH_TRANSFER_FAILED");
    }
}

// 
pragma solidity >=0.7.5;

interface ITreasury {
    function deposit(
        uint256 _amount,
        address _token,
        uint256 _profit
    ) external returns (uint256);

    function withdraw(uint256 _amount, address _token) external;

    function tokenValue(address _token, uint256 _amount) external view returns (uint256 value_);

    function mint(address _recipient, uint256 _amount) external;

    function manage(address _token, uint256 _amount) external;

    function incurDebt(uint256 amount_, address token_) external;

    function repayDebtWithReserve(uint256 amount_, address token_) external;

    function excessReserves() external view returns (uint256);

    function baseSupply() external view returns (uint256);
}

// 
pragma solidity >=0.7.5;



interface IUniswapV2Pair is IUniswapV2ERC20 {
    function token0() external pure returns (address);

    function token1() external pure returns (address);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function mint(address to) external returns (uint256 liquidity);

    function sync() external;
}

// 
pragma solidity >=0.7.5;

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// 
pragma solidity >=0.7.5;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// 
pragma solidity >=0.7.5;

interface IOlympusAuthority {
    /* ========== EVENTS ========== */

    event GovernorPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event GuardianPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event PolicyPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event VaultPushed(address indexed from, address indexed to, bool _effectiveImmediately);

    event GovernorPulled(address indexed from, address indexed to);
    event GuardianPulled(address indexed from, address indexed to);
    event PolicyPulled(address indexed from, address indexed to);
    event VaultPulled(address indexed from, address indexed to);

    /* ========== VIEW ========== */

    function governor() external view returns (address);

    function guardian() external view returns (address);

    function policy() external view returns (address);

    function vault() external view returns (address);
}