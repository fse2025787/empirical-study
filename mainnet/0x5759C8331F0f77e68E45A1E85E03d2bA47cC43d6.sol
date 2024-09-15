// SPDX-License-Identifier: BUSL-1.1

/**
 *Submitted for verification at Etherscan.io on 2022-09-14
*/

// 

pragma solidity ^0.8.0;



interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}



interface IERC721 is IERC165 {
    // events

    
    
    
    
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    
    
    
    
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    
    
    
    
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    
    
    function balanceOf(address owner) external view returns (uint256 balance);

    
    
    
    function ownerOf(uint256 tokenId) external view returns (address owner);

    
    ///         The token/order must exists
    
    
    function approve(address to, uint256 tokenId) external;

    
    ///         The token/order must exists
    
    
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    
    
    
    function setApprovalForAll(address operator, bool _approved) external;

    
    
    
    
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    
    ///         or approved operators
    
    
    
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    
    ///         of the ERC721 protocol to prevent tokens from being forever locked.
    
    
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    
    ///         of the ERC721 protocol to prevent tokens from being forever locked.
    
    
    
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}



interface ILimitrVault is IERC721 {
    // events

    
    
    
    event NewFeePercentage(uint256 oldFeePercentage, uint256 newFeePercentage);

    
    
    
    
    
    
    event OrderCreated(
        address indexed token,
        uint256 indexed id,
        address indexed trader,
        uint256 price,
        uint256 amount
    );

    
    
    
    
    
    event OrderCanceled(
        address indexed token,
        uint256 indexed id,
        uint256 indexed price,
        uint256 amount
    );

    
    
    
    
    
    
    event OrderTaken(
        address indexed token,
        uint256 indexed id,
        address indexed owner,
        uint256 amount,
        uint256 price
    );

    
    
    
    
    
    event TokenWithdraw(
        address indexed token,
        address indexed owner,
        address indexed receiver,
        uint256 amount
    );

    
    
    
    
    
    event ArbitrageProfitTaken(
        address indexed profitToken,
        uint256 profitAmount,
        uint256 otherAmount,
        address indexed receiver
    );

    
    
    
    event FeeCollected(address indexed token, uint256 amount);

    
    event TradingPaused();

    
    event TradingResumed();

    
    
    
    function initialize(address _token0, address _token1) external;

    // fee functions

    
    function feePercentage() external view returns (uint256);

    
    ///         Emits a NewFeePercentage event
    
    function setFeePercentage(uint256 newFeePercentage) external;

    // factory and token addresses

    
    function registry() external view returns (address);

    
    function token0() external view returns (address);

    
    function token1() external view returns (address);

    // price listing functions

    
    
    function firstPrice(address token) external view returns (uint256);

    
    
    function lastPrice(address token) external view returns (uint256);

    
    
    
    function previousPrice(address token, uint256 current)
        external
        view
        returns (uint256);

    
    
    
    function nextPrice(address token, uint256 current)
        external
        view
        returns (uint256);

    
    
    
    
    function prices(
        address token,
        uint256 current,
        uint256 n
    ) external view returns (uint256[] memory);

    
    
    
    
    function pricePointers(
        address token,
        uint256 price,
        uint256 nPointers
    ) external view returns (uint256[] memory);

    // orders functions

    
    
    function firstOrder(address token) external view returns (uint256);

    
    
    function lastOrder(address token) external view returns (uint256);

    
    
    
    function previousOrder(address token, uint256 currentID)
        external
        view
        returns (uint256);

    
    
    
    function nextOrder(address token, uint256 currentID)
        external
        view
        returns (uint256);

    
    
    
    
    function orders(
        address token,
        uint256 current,
        uint256 n
    ) external view returns (uint256[] memory);

    
    ///         starting after `current`
    
    
    
    
    
    
    
    function ordersInfo(
        address token,
        uint256 current,
        uint256 n
    )
        external
        view
        returns (
            uint256[] memory id,
            uint256[] memory price,
            uint256[] memory amount,
            address[] memory trader
        );

    
    
    
    
    
    
    function orderInfo(address token, uint256 orderID)
        external
        view
        returns (
            uint256 price,
            uint256 amount,
            address trader
        );

    
    
    function orderToken(uint256 orderID) external view returns (address);

    
    function lastID() external view returns (uint256);

    /// liquidity functions

    
    
    
    function liquidityByPrice(address token, uint256 price)
        external
        view
        returns (uint256);

    
    
    
    
    
    
    function liquidity(
        address token,
        uint256 current,
        uint256 n
    )
        external
        view
        returns (uint256[] memory price, uint256[] memory priceLiquidity);

    
    
    function totalLiquidity(address token) external view returns (uint256);

    // trader order functions

    
    
    
    function firstTraderOrder(address token, address trader)
        external
        view
        returns (uint256);

    
    
    
    function lastTraderOrder(address token, address trader)
        external
        view
        returns (uint256);

    
    
    
    
    function previousTraderOrder(
        address token,
        address trader,
        uint256 currentID
    ) external view returns (uint256);

    
    
    
    
    function nextTraderOrder(
        address token,
        address trader,
        uint256 currentID
    ) external view returns (uint256);

    
    
    
    
    
    function traderOrders(
        address token,
        address trader,
        uint256 current,
        uint256 n
    ) external view returns (uint256[] memory);

    // fee calculation functions

    
    
    function feeOf(uint256 amount) external view returns (uint256);

    
    
    function feeFor(uint256 amount) external view returns (uint256);

    
    
    function withoutFee(uint256 amount) external view returns (uint256);

    
    
    function withFee(uint256 amount) external view returns (uint256);

    // trade amounts calculation functions

    
    ///         Fees not included
    
    
    
    function costAtPrice(
        address wantToken,
        uint256 amountOut,
        uint256 price
    ) external view returns (uint256);

    
    ///         `price`. Fees not included.
    
    
    
    function returnAtPrice(
        address wantToken,
        uint256 amountIn,
        uint256 price
    ) external view returns (uint256);

    
    ///         maximum of `maxPrice`. Fees not included
    
    
    
    
    
    function costAtMaxPrice(
        address wantToken,
        uint256 maxAmountOut,
        uint256 maxPrice
    ) external view returns (uint256 amountIn, uint256 amountOut);

    
    ///         at a maximum price of `maxPrice`. Fees not included.
    
    
    
    
    
    function returnAtMaxPrice(
        address wantToken,
        uint256 maxAmountIn,
        uint256 maxPrice
    ) external view returns (uint256 amountIn, uint256 amountOut);

    // order creation functions

    
    
    
    
    
    
    
    function newOrder(
        address gotToken,
        uint256 price,
        uint256 amount,
        address trader,
        uint256 deadline
    ) external returns (uint256);

    
    
    
    
    
    
    
    
    function newOrderWithPointer(
        address gotToken,
        uint256 price,
        uint256 amount,
        address trader,
        uint256 deadline,
        uint256 pointer
    ) external returns (uint256);

    
    
    
    
    
    
    
    
    function newOrderWithPointers(
        address gotToken,
        uint256 price,
        uint256 amount,
        address trader,
        uint256 deadline,
        uint256[] memory pointers
    ) external returns (uint256);

    // order cancellation functions

    
    
    
    
    
    function cancelOrder(
        uint256 orderID,
        uint256 amount,
        address receiver,
        uint256 deadline
    ) external;

    // trading functions

    
    ///         (per order). This function includes the fee in the limit set
    ///         by `maxAmountIn`
    
    
    
    
    
    
    
    function tradeAtMaxPrice(
        address wantToken,
        uint256 maxPrice,
        uint256 maxAmountIn,
        address receiver,
        uint256 deadline
    ) external returns (uint256 cost, uint256 received);

    // trader balances

    
    
    
    function traderBalance(address token, address trader)
        external
        view
        returns (uint256);

    
    
    
    
    function withdraw(
        address token,
        address to,
        uint256 amount
    ) external;

    
    
    
    
    function withdrawFor(
        address token,
        address trader,
        address receiver,
        uint256 amount
    ) external;

    // function arbitrage_trade() external;

    
    
    
    function isAllowed(address sender, uint256 tokenId)
        external
        view
        returns (bool);

    
    function implementationVersion() external view returns (uint16);

    
    function implementationAddress() external view returns (address);

    
    
    
    
    
    
    
    function arbitrageAmountsOut(
        address profitToken,
        uint256 maxAmountIn,
        uint256 maxPrice
    )
        external
        view
        returns (
            uint256 profitIn,
            uint256 profitOut,
            uint256 otherOut
        );

    
    ///         the other side
    
    
    
    
    
    function arbitrageTrade(
        address profitToken,
        uint256 maxBorrow,
        uint256 maxPrice,
        address receiver,
        uint256 deadline
    ) external returns (uint256 profitAmount, uint256 otherAmount);

    
    function isTradingPaused() external view returns (bool);

    
    function pauseTrading() external;

    
    function resumeTrading() external;
}

interface IJumpstart {
    
    function JS_names() external view returns (string[] memory);

    
    
    function JS_get(string memory name) external view returns (string memory);

    
    function JS_getAll()
        external
        view
        returns (string[] memory, string[] memory);
}

interface IJumpstartManager {
    
    
    
    function JS_add(string calldata name, string calldata uri) external;

    
    
    function JS_remove(string calldata name) external;

    
    
    
    function JS_update(string calldata name, string calldata newUri) external;
}

interface ILimitrRegistry is IJumpstart, IJumpstartManager {
    // events

    
    
    event VaultImplementationUpdated(address indexed newVaultImplementation);

    
    
    event AdminUpdated(address indexed newAdmin);

    
    
    event FeeReceiverUpdated(address indexed newFeeReceiver);

    
    /// param vault The address of the vault created
    
    
    event VaultCreated(
        address indexed vault,
        address indexed token0,
        address indexed token1
    );

    
    
    
    
    function initialize(
        address _router,
        address _vaultScanner,
        address _vaultImplementation
    ) external;

    
    function admin() external view returns (address);

    
    
    function transferAdmin(address newAdmin) external;

    
    function feeReceiver() external view returns (address);

    
    
    function setFeeReceiver(address newFeeReceiver) external;

    
    function router() external view returns (address);

    
    function vaultImplementation() external view returns (address);

    
    
    function setVaultImplementation(address newVaultImplementation) external;

    
    
    
    
    function createVault(address tokenA, address tokenB)
        external
        returns (address);

    
    function vaultsCount() external view returns (uint256);

    
    
    function vault(uint256 idx) external view returns (address);

    
    
    
    function vaults(uint256 idx, uint256 n)
        external
        view
        returns (address[] memory);

    
    
    
    function vaultFor(address tokenA, address tokenB)
        external
        view
        returns (address);

    
    
    function vaultByHash(bytes32 hash) external view returns (address);

    
    
    
    
    function vaultHash(address tokenA, address tokenB)
        external
        pure
        returns (bytes32);

    
    function vaultScanner() external view returns (address);
}



interface ILimitrVaultScanner {
    
    function registry() external view returns (address);

    
    
    
    
    function availableBalances(
        uint256 idx,
        uint256 n,
        address trader
    ) external view returns (address[] memory);

    
    
    function availableBalancesAll(address trader)
        external
        view
        returns (address[] memory);

    
    
    
    
    function openOrders(
        uint256 idx,
        uint256 n,
        address trader
    ) external view returns (address[] memory);

    
    
    function openOrdersAll(address trader)
        external
        view
        returns (address[] memory);

    
    ///         orders or available balance
    
    
    
    function memorable(
        uint256 idx,
        uint256 n,
        address trader
    ) external view returns (address[] memory);

    
    
    function memorableAll(address trader)
        external
        view
        returns (address[] memory);

    
    
    
    
    function token(
        uint256 idx,
        uint256 n,
        address _token
    ) external view returns (address[] memory);

    
    
    function tokenAll(address _token) external view returns (address[] memory);
}



contract LimitrVaultScanner is ILimitrVaultScanner {
    address public override registry;

    constructor(address _registry) {
        registry = _registry;
    }

    
    
    
    
    function availableBalances(
        uint256 idx,
        uint256 n,
        address trader
    ) public view override returns (address[] memory) {
        address[] memory r = ILimitrRegistry(registry).vaults(idx, n);
        for (uint256 i = 0; i < r.length; i++) {
            if (r[i] == address(0)) {
                break;
            }
            if (!_vaultGotBalance(r[i], trader)) {
                r[i] = address(0);
            }
        }
        return r;
    }

    
    
    function availableBalancesAll(address trader)
        external
        view
        override
        returns (address[] memory)
    {
        return
            availableBalances(
                0,
                ILimitrRegistry(registry).vaultsCount(),
                trader
            );
    }

    
    
    
    
    function openOrders(
        uint256 idx,
        uint256 n,
        address trader
    ) public view override returns (address[] memory) {
        address[] memory r = ILimitrRegistry(registry).vaults(idx, n);
        for (uint256 i = 0; i < r.length; i++) {
            if (r[i] == address(0)) {
                break;
            }
            if (!_vaultGotOrders(r[i], trader)) {
                r[i] = address(0);
            }
        }
        return r;
    }

    
    
    function openOrdersAll(address trader)
        external
        view
        override
        returns (address[] memory)
    {
        return openOrders(0, ILimitrRegistry(registry).vaultsCount(), trader);
    }

    
    ///         orders or available balance
    
    
    
    function memorable(
        uint256 idx,
        uint256 n,
        address trader
    ) public view override returns (address[] memory) {
        address[] memory r = ILimitrRegistry(registry).vaults(idx, n);
        for (uint256 i = 0; i < r.length; i++) {
            if (r[i] == address(0)) {
                break;
            }
            if (!_vaultIsMemorable(r[i], trader)) {
                r[i] = address(0);
            }
        }
        return r;
    }

    
    
    function memorableAll(address trader)
        external
        view
        override
        returns (address[] memory)
    {
        return memorable(0, ILimitrRegistry(registry).vaultsCount(), trader);
    }

    
    
    
    
    function token(
        uint256 idx,
        uint256 n,
        address _token
    ) public view override returns (address[] memory) {
        address[] memory r = ILimitrRegistry(registry).vaults(idx, n);
        for (uint256 i = 0; i < r.length; i++) {
            if (r[i] == address(0)) {
                break;
            }
            if (!_vaultGotToken(r[i], _token)) {
                r[i] = address(0);
            }
        }
        return r;
    }

    
    
    function tokenAll(address _token)
        external
        view
        override
        returns (address[] memory)
    {
        return token(0, ILimitrRegistry(registry).vaultsCount(), _token);
    }

    function _vaultGotOrders(address _vault, address trader)
        internal
        view
        returns (bool)
    {
        ILimitrVault v = ILimitrVault(_vault);
        return
            v.firstTraderOrder(v.token0(), trader) != 0 ||
            v.firstTraderOrder(v.token1(), trader) != 0;
    }

    function _vaultGotBalance(address _vault, address trader)
        internal
        view
        returns (bool)
    {
        ILimitrVault v = ILimitrVault(_vault);
        return
            v.traderBalance(v.token0(), trader) != 0 ||
            v.traderBalance(v.token1(), trader) != 0;
    }

    function _vaultIsMemorable(address _vault, address trader)
        internal
        view
        returns (bool)
    {
        return
            _vaultGotOrders(_vault, trader) || _vaultGotBalance(_vault, trader);
    }

    function _vaultGotToken(address _vault, address _token)
        internal
        view
        returns (bool)
    {
        ILimitrVault v = ILimitrVault(_vault);
        return v.token0() == _token || v.token1() == _token;
    }
}