// SPDX-License-Identifier: BUSL-1.1

/**
 *Submitted for verification at Etherscan.io on 2022-09-14
*/

// 

pragma solidity ^0.8.0;



interface IERC20 {
    
    
    
    
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    
    
    
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    function name() external view returns (string memory);

    
    function symbol() external view returns (string memory);

    
    function decimals() external view returns (uint8);

    
    function totalSupply() external view returns (uint256);

    
    
    function balanceOf(address owner) external view returns (uint256);

    
    
    
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    
    
    
    
    function approve(address spender, uint256 amount) external returns (bool);

    
    
    
    
    function transfer(address to, uint256 amount) external returns (bool);

    
    
    
    
    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}




interface IERC721Receiver {
    
    ///      by `operator` from `from`, this function is called.
    ///      It must return its Solidity selector to confirm the token transfer.
    ///      If any other value is returned or the interface is not implemented
    ///      by the recipient, the transfer will be reverted.
    ///      The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
    
    
    
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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

// double linked list
struct DLL {
    mapping(uint256 => uint256) _next;
    mapping(uint256 => uint256) _prev;
}

// double linked list handling
library DoubleLinkedList {
    // first entry
    function first(DLL storage dll) internal view returns (uint256) {
        return dll._next[0];
    }

    // last entry
    function last(DLL storage dll) internal view returns (uint256) {
        return dll._prev[0];
    }

    // next entry
    function next(DLL storage dll, uint256 current)
        internal
        view
        returns (uint256)
    {
        return dll._next[current];
    }

    // previous entry
    function previous(DLL storage dll, uint256 current)
        internal
        view
        returns (uint256)
    {
        return dll._prev[current];
    }

    // insert at the beginning
    function insertBeginning(DLL storage dll, uint256 value) internal {
        insertAfter(dll, value, 0);
    }

    // insert at the end
    function insertEnd(DLL storage dll, uint256 value) internal {
        insertBefore(dll, value, 0);
    }

    // insert after an entry
    function insertAfter(
        DLL storage dll,
        uint256 value,
        uint256 _prev
    ) internal {
        uint256 _next = dll._next[_prev];
        dll._next[_prev] = value;
        dll._prev[_next] = value;
        dll._next[value] = _next;
        dll._prev[value] = _prev;
    }

    // insert before an entry
    function insertBefore(
        DLL storage dll,
        uint256 value,
        uint256 _next
    ) internal {
        uint256 _prev = dll._prev[_next];
        dll._next[_prev] = value;
        dll._prev[_next] = value;
        dll._next[value] = _next;
        dll._prev[value] = _prev;
    }

    // remove an entry
    function remove(DLL storage dll, uint256 value) internal {
        uint256 p = dll._prev[value];
        uint256 n = dll._next[value];
        dll._prev[n] = p;
        dll._next[p] = n;
        dll._prev[value] = 0;
        dll._next[value] = 0;
    }
}

// sorted double linked list
struct SDLL {
    mapping(uint256 => uint256) _next;
    mapping(uint256 => uint256) _prev;
}

// sorted double linked list handling
library SortedDoubleLinkedList {
    // first entry
    function first(SDLL storage s) internal view returns (uint256) {
        return s._next[0];
    }

    // last entry
    function last(SDLL storage s) internal view returns (uint256) {
        return s._prev[0];
    }

    // next entry
    function next(SDLL storage s, uint256 current)
        internal
        view
        returns (uint256)
    {
        return s._next[current];
    }

    // previous entry
    function previous(SDLL storage s, uint256 current)
        internal
        view
        returns (uint256)
    {
        return s._prev[current];
    }

    // insert with a pointer
    function insertWithPointer(
        SDLL storage s,
        uint256 value,
        uint256 pointer
    ) internal returns (bool) {
        uint256 n = pointer;
        while (true) {
            n = s._next[n];
            if (n == 0 || n > value) {
                break;
            }
        }
        uint256 p = s._prev[n];
        s._next[p] = value;
        s._prev[n] = value;
        s._next[value] = n;
        s._prev[value] = p;
        return true;
    }

    // insert using 0 as a pointer
    function insert(SDLL storage s, uint256 value) internal returns (bool) {
        return insertWithPointer(s, value, 0);
    }

    // remove an entry
    function remove(SDLL storage s, uint256 value) internal {
        uint256 p = s._prev[value];
        uint256 n = s._next[value];
        s._prev[n] = p;
        s._next[p] = n;
        s._prev[value] = 0;
        s._next[value] = 0;
    }
}



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


struct Order {
    uint256 price;
    uint256 amount;
    address trader;
}


struct TradeHandler {
    uint256 amountIn;
    uint256 amountOut;
    uint256 availableAmountIn;
}


library TradeHandlerLib {
    function update(
        TradeHandler memory _trade,
        uint256 amountIn,
        uint256 amountOut
    ) internal pure {
        _trade.amountIn += amountIn;
        _trade.amountOut += amountOut;
        _trade.availableAmountIn -= amountIn;
    }
}



contract LimitrVault is ILimitrVault {
    using DoubleLinkedList for DLL;
    using SortedDoubleLinkedList for SDLL;
    using TradeHandlerLib for TradeHandler;

    address private _deployer;

    constructor() {
        _deployer = msg.sender;
    }

    
    
    
    function initialize(address _token0, address _token1) external override {
        require(registry == address(0), "LimitrVault: already initialized");
        require(
            _token0 != _token1,
            "LimitrVault: base and counter tokens are the same"
        );
        require(_token0 != address(0), "LimitrVault: zero address not allowed");
        require(_token1 != address(0), "LimitrVault: zero address not allowed");
        token0 = _token0;
        token1 = _token1;
        registry = msg.sender;
        _oneToken[_token0] = 10**IERC20(_token0).decimals();
        _oneToken[_token1] = 10**IERC20(_token1).decimals();
        feePercentage = 2 * 10**15; // 0.2 %
    }

    
    uint256 public override feePercentage;

    
    ///         Emits a NewFeePercentage event
    
    function setFeePercentage(uint256 newFeePercentage)
        external
        override
        onlyAdmin
    {
        require(
            newFeePercentage < feePercentage,
            "LimitrVault: can only set a smaller fee"
        );
        uint256 oldPercentage = feePercentage;
        feePercentage = newFeePercentage;
        emit NewFeePercentage(oldPercentage, newFeePercentage);
    }

    // factory and token addresses

    
    address public override registry;

    
    address public override token0;

    
    address public override token1;

    // price listing functions

    
    
    function firstPrice(address token) public view override returns (uint256) {
        return _prices[token].first();
    }

    
    
    function lastPrice(address token) public view override returns (uint256) {
        return _prices[token].last();
    }

    
    
    
    function previousPrice(address token, uint256 current)
        public
        view
        override
        returns (uint256)
    {
        return _prices[token].previous(current);
    }

    
    
    
    function nextPrice(address token, uint256 current)
        public
        view
        override
        returns (uint256)
    {
        return _prices[token].next(current);
    }

    
    
    
    
    function prices(
        address token,
        uint256 current,
        uint256 n
    ) external view override returns (uint256[] memory) {
        SDLL storage priceList = _prices[token];
        uint256 c = current;
        uint256[] memory r = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            c = priceList.next(c);
            if (c == 0) {
                break;
            }
            r[i] = c;
        }
        return r;
    }

    
    
    
    
    function pricePointers(
        address token,
        uint256 price,
        uint256 nPointers
    ) external view override returns (uint256[] memory) {
        uint256[] memory r = new uint256[](nPointers);
        uint256 c;
        SDLL storage priceList = _prices[token];
        if (_lastOrder[token][price] != 0) {
            c = price;
        } else {
            c = 0;
            while (c < price) {
                c = priceList.next(c);
                if (c == 0) {
                    break;
                }
            }
        }
        for (uint256 i = 0; i < nPointers; i++) {
            c = priceList.previous(c);
            if (c == 0) {
                break;
            }
            r[i] = c;
        }
        return r;
    }

    // orders listing functions

    
    
    function firstOrder(address token) public view override returns (uint256) {
        return _orders[token].first();
    }

    
    
    function lastOrder(address token) public view override returns (uint256) {
        return _orders[token].last();
    }

    
    
    
    function previousOrder(address token, uint256 currentID)
        public
        view
        override
        returns (uint256)
    {
        return _orders[token].previous(currentID);
    }

    
    
    
    function nextOrder(address token, uint256 currentID)
        public
        view
        override
        returns (uint256)
    {
        return _orders[token].next(currentID);
    }

    
    
    
    
    function orders(
        address token,
        uint256 current,
        uint256 n
    ) external view override returns (uint256[] memory) {
        uint256 c = current;
        uint256[] memory r = new uint256[](n);
        DLL storage orderList = _orders[token];
        for (uint256 i = 0; i < n; i++) {
            c = orderList.next(c);
            if (c == 0) {
                break;
            }
            r[i] = c;
        }
        return r;
    }

    
    ///         starting after `current`
    
    
    
    
    
    
    
    function ordersInfo(
        address token,
        uint256 current,
        uint256 n
    )
        external
        view
        override
        returns (
            uint256[] memory id,
            uint256[] memory price,
            uint256[] memory amount,
            address[] memory trader
        )
    {
        uint256 c = current;
        id = new uint256[](n);
        price = new uint256[](n);
        amount = new uint256[](n);
        trader = new address[](n);
        for (uint256 i = 0; i < n; i++) {
            c = _orders[token].next(c);
            if (c == 0) {
                break;
            }
            id[i] = c;
            Order memory t = orderInfo[token][c];
            price[i] = t.price;
            amount[i] = t.amount;
            trader[i] = t.trader;
        }
    }

    
    
    function orderToken(uint256 orderID)
        public
        view
        override
        returns (address)
    {
        return
            orderInfo[token0][orderID].trader != address(0) ? token0 : token1;
    }

    
    mapping(address => mapping(uint256 => Order)) public override orderInfo;

    
    uint256 public override lastID;

    /// liquidity functions

    
    mapping(address => mapping(uint256 => uint256))
        public
        override liquidityByPrice;

    
    
    
    
    
    
    function liquidity(
        address token,
        uint256 current,
        uint256 n
    )
        external
        view
        override
        returns (uint256[] memory price, uint256[] memory priceLiquidity)
    {
        uint256 c = current;
        price = new uint256[](n);
        priceLiquidity = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            c = _prices[token].next(c);
            if (c == 0) {
                break;
            }
            price[i] = c;
            priceLiquidity[i] = liquidityByPrice[token][c];
        }
    }

    
    mapping(address => uint256) public override totalLiquidity;

    // trader order listing functions

    
    
    
    function firstTraderOrder(address token, address trader)
        public
        view
        override
        returns (uint256)
    {
        return _traderOrders[token][trader].first();
    }

    
    
    
    function lastTraderOrder(address token, address trader)
        public
        view
        override
        returns (uint256)
    {
        return _traderOrders[token][trader].last();
    }

    
    
    
    
    function previousTraderOrder(
        address token,
        address trader,
        uint256 currentID
    ) public view override returns (uint256) {
        return _traderOrders[token][trader].previous(currentID);
    }

    
    
    
    
    function nextTraderOrder(
        address token,
        address trader,
        uint256 currentID
    ) public view override returns (uint256) {
        return _traderOrders[token][trader].next(currentID);
    }

    
    
    
    
    
    function traderOrders(
        address token,
        address trader,
        uint256 current,
        uint256 n
    ) external view override returns (uint256[] memory) {
        uint256 c = current;
        uint256[] memory r = new uint256[](n);
        DLL storage traderOrderList = _traderOrders[token][trader];
        for (uint256 i = 0; i < n; i++) {
            c = traderOrderList.next(c);
            if (c == 0) {
                break;
            }
            r[i] = c;
        }
        return r;
    }

    // fee calculation functions

    
    
    function feeOf(uint256 amount) public view override returns (uint256) {
        if (feePercentage == 0 || amount == 0) {
            return 0;
        }
        return (amount * feePercentage) / 10**18;
    }

    
    
    function feeFor(uint256 amount) public view override returns (uint256) {
        if (feePercentage == 0 || amount == 0) {
            return 0;
        }
        return (amount * feePercentage) / (10**18 - feePercentage);
    }

    
    
    function withoutFee(uint256 amount) public view override returns (uint256) {
        return amount - feeOf(amount);
    }

    
    
    function withFee(uint256 amount) public view override returns (uint256) {
        return amount + feeFor(amount);
    }

    // trade amounts calculation functions

    
    ///         Fees not included
    
    
    function costAtPrice(
        address wantToken,
        uint256 amountOut,
        uint256 price
    ) public view override returns (uint256) {
        if (price == 0 || amountOut == 0) {
            return 0;
        }
        return (price * amountOut) / _oneToken[wantToken];
    }

    
    ///         `price`. Fees not included.
    
    
    
    function returnAtPrice(
        address wantToken,
        uint256 amountIn,
        uint256 price
    ) public view override returns (uint256) {
        if (price == 0 || amountIn == 0) {
            return 0;
        }
        return (_oneToken[wantToken] * amountIn) / price;
    }

    
    ///         maximum of `maxPrice`. Fees not included
    
    
    
    
    
    function costAtMaxPrice(
        address wantToken,
        uint256 maxAmountOut,
        uint256 maxPrice
    ) public view override returns (uint256 amountIn, uint256 amountOut) {
        return
            _returnAtMaxPrice(
                wantToken,
                costAtPrice(wantToken, maxAmountOut, maxPrice),
                maxPrice
            );
    }

    
    ///         at a maximum price of `maxPrice`. Fees not included.
    
    
    
    
    
    function returnAtMaxPrice(
        address wantToken,
        uint256 maxAmountIn,
        uint256 maxPrice
    ) public view override returns (uint256 amountIn, uint256 amountOut) {
        return _returnAtMaxPrice(wantToken, maxAmountIn, maxPrice);
    }

    // order creation functions

    
    
    
    
    
    
    
    function newOrder(
        address gotToken,
        uint256 price,
        uint256 amount,
        address trader,
        uint256 deadline
    ) public override returns (uint256) {
        (uint256 orderID, bool created) = _newOrderWithPointer(
            gotToken,
            price,
            amount,
            trader,
            deadline,
            0
        );
        require(created, "LimitrVault: can't create new order");
        return orderID;
    }

    
    
    
    
    
    
    
    
    function newOrderWithPointer(
        address gotToken,
        uint256 price,
        uint256 amount,
        address trader,
        uint256 deadline,
        uint256 pointer
    ) public override returns (uint256) {
        (uint256 orderID, bool created) = _newOrderWithPointer(
            gotToken,
            price,
            amount,
            trader,
            deadline,
            pointer
        );
        require(created, "LimitrVault: can't create new order");
        return orderID;
    }

    
    
    
    
    
    
    
    
    function newOrderWithPointers(
        address gotToken,
        uint256 price,
        uint256 amount,
        address trader,
        uint256 deadline,
        uint256[] memory pointers
    ) public override returns (uint256) {
        for (uint256 i = 0; i < pointers.length; i++) {
            (uint256 orderID, bool created) = _newOrderWithPointer(
                gotToken,
                price,
                amount,
                trader,
                deadline,
                pointers[i]
            );
            if (created) {
                return orderID;
            }
        }
        revert("LimitrVault: can't create new order");
    }

    // order cancellation functions

    
    
    
    
    
    function cancelOrder(
        uint256 orderID,
        uint256 amount,
        address receiver,
        uint256 deadline
    ) public override withinDeadline(deadline) senderAllowed(orderID) lock {
        address t = orderToken(orderID);
        Order memory _order = orderInfo[t][orderID];
        uint256 _amount = amount != 0 ? amount : _order.amount;
        _cancelOrder(t, orderID, amount);
        _withdrawToken(t, receiver, _amount);
    }

    // trading functions

    
    ///         (per order). This function includes the fee in the limit set
    ///         by `maxAmountIn`
    
    
    
    
    
    
    
    function tradeAtMaxPrice(
        address wantToken,
        uint256 maxPrice,
        uint256 maxAmountIn,
        address receiver,
        uint256 deadline
    )
        public
        override
        withinDeadline(deadline)
        validToken(wantToken)
        lock
        isTrading
        returns (uint256, uint256)
    {
        return _trade(wantToken, maxPrice, maxAmountIn, receiver, _postTrade);
    }

    // trader balances

    
    mapping(address => mapping(address => uint256))
        public
        override traderBalance;

    
    
    
    
    function withdraw(
        address token,
        address to,
        uint256 amount
    ) external override lock {
        _withdraw(token, msg.sender, to, amount);
    }

    
    
    
    
    
    function withdrawFor(
        address token,
        address trader,
        address receiver,
        uint256 amount
    ) external override {
        address router = ILimitrRegistry(registry).router();
        require(msg.sender == router, "LimitrVault: not the router");
        _withdraw(token, trader, receiver, amount);
    }

    
    
    
    function isAllowed(address sender, uint256 tokenId)
        public
        view
        override
        returns (bool)
    {
        address owner = ownerOf(tokenId);
        return
            sender == owner ||
            isApprovedForAll[owner][sender] ||
            sender == _approvals[tokenId] ||
            sender == ILimitrRegistry(registry).router();
    }

    
    function implementationVersion() external pure override returns (uint16) {
        return 1;
    }

    
    function implementationAddress() external view override returns (address) {
        bytes memory code = address(this).code;
        require(code.length == 51, "LimitrVault: expecting 51 bytes of code");
        uint160 r;
        for (uint256 i = 11; i < 31; i++) {
            r = (r << 8) | uint8(code[i]);
        }
        return address(r);
    }

    // ERC165

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(ILimitrVault).interfaceId;
    }

    // ERC721

    
    mapping(address => uint256) public override balanceOf;

    
    mapping(address => mapping(address => bool))
        public
        override isApprovedForAll;

    
    
    
    function ownerOf(uint256 tokenId)
        public
        view
        override
        ERC721TokenMustExist(tokenId)
        returns (address)
    {
        address t = orderInfo[token0][tokenId].trader;
        if (t != address(0)) {
            return t;
        }
        return orderInfo[token1][tokenId].trader;
    }

    
    ///         The token/order must exists
    
    
    function approve(address to, uint256 tokenId) public override lock {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        bool allowed = msg.sender == owner ||
            isApprovedForAll[owner][msg.sender];
        require(allowed, "ERC721: not the owner or operator");
        _ERC721Approve(owner, to, tokenId);
    }

    
    ///         The token/order must exists
    
    
    function getApproved(uint256 tokenId)
        public
        view
        override
        ERC721TokenMustExist(tokenId)
        returns (address)
    {
        return _approvals[tokenId];
    }

    
    
    
    function setApprovalForAll(address operator, bool approved)
        public
        override
        lock
    {
        require(msg.sender != operator, "ERC721: can't approve yourself");
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    
    ///         or approved operators
    
    
    
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        _ERC721Transfer(from, to, tokenId);
    }

    
    ///         of the ERC721 protocol to prevent tokens from being forever locked.
    
    
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    
    ///         of the ERC721 protocol to prevent tokens from being forever locked.
    
    
    
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {
        _ERC721SafeTransfer(from, to, tokenId, _data);
    }

    
    
    
    
    
    
    
    function arbitrageAmountsOut(
        address profitToken,
        uint256 maxAmountIn,
        uint256 maxPrice
    )
        external
        view
        override
        validToken(profitToken)
        returns (
            uint256 profitIn,
            uint256 profitOut,
            uint256 otherOut
        )
    {
        address other = _otherToken(profitToken);
        uint256 buyOut;
        (profitIn, buyOut) = _returnAtMaxPrice(
            other,
            withoutFee(maxAmountIn),
            maxPrice != 0 ? maxPrice : _prices[other].last()
        );
        profitIn = withFee(profitIn);
        uint256 dumpIn;
        (dumpIn, profitOut) = _returnAtMaxPrice(
            profitToken,
            withoutFee(buyOut),
            _prices[profitToken].last()
        );
        dumpIn = withFee(dumpIn);
        otherOut = buyOut - dumpIn;
    }

    
    ///         the other side
    
    
    
    
    
    function arbitrageTrade(
        address profitToken,
        uint256 maxBorrow,
        uint256 maxPrice,
        address receiver,
        uint256 deadline
    )
        external
        override
        withinDeadline(deadline)
        validToken(profitToken)
        lock
        isTrading
        returns (uint256 profitAmount, uint256 otherAmount)
    {
        address otherToken = _otherToken(profitToken);
        // borrow borrowedProfitIn and buy otherOut with it
        uint256 p = maxPrice != 0 ? maxPrice : _prices[otherToken].last();
        (uint256 borrowedProfitIn, uint256 otherOut) = _trade(
            otherToken,
            p,
            maxBorrow,
            receiver,
            _postBorrowTrade
        );
        // borrow borrowedOtherIn and buy profitOut with it
        p = _prices[profitToken].last();
        (uint256 borrowedOtherIn, uint256 profitOut) = _trade(
            profitToken,
            p,
            otherOut,
            receiver,
            _postBorrowTrade
        );
        require(
            profitOut > borrowedProfitIn,
            "LimitrVault: no arbitrage profit"
        );
        profitAmount = profitOut - borrowedProfitIn;
        otherAmount = otherOut - borrowedOtherIn;
        _withdrawToken(profitToken, receiver, profitAmount);
        _withdrawToken(otherToken, receiver, otherAmount);
        emit ArbitrageProfitTaken(
            profitToken,
            profitAmount,
            otherAmount,
            receiver
        );
    }

    
    bool public override isTradingPaused = false;

    
    function pauseTrading() external override onlyAdmin {
        isTradingPaused = true;
    }

    
    function resumeTrading() external override onlyAdmin {
        isTradingPaused = false;
    }

    // modifiers

    modifier isTrading() {
        require(isTradingPaused == false, "LimitrVault: trading is paused");
        _;
    }

    modifier validToken(address token) {
        require(
            token == token0 || token == token1,
            "LimitrVault: invalid token"
        );
        _;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == ILimitrRegistry(registry).admin(),
            "LimitrVault: only for the admin"
        );
        _;
    }

    modifier withinDeadline(uint256 deadline) {
        if (deadline > 0) {
            require(
                block.timestamp <= deadline,
                "LimitrVault: past the deadline"
            );
        }
        _;
    }

    bool internal _locked;

    modifier lock() {
        require(!_locked, "LimitrVault: already locked");
        _locked = true;
        _;
        _locked = false;
    }

    modifier postExecBalanceCheck(address token) {
        _;
        require(
            IERC20(token).balanceOf(address(this)) >= _expectedBalance[token],
            "LimitrVault:  Deflationary token"
        );
    }

    modifier senderAllowed(uint256 tokenId) {
        require(
            isAllowed(msg.sender, tokenId),
            "ERC721: not the owner, approved or operator"
        );
        _;
    }

    modifier ERC721TokenMustExist(uint256 tokenId) {
        require(
            orderToken(tokenId) != address(0),
            "ERC721: token does not exist"
        );
        _;
    }

    // internal variables and methods

    mapping(address => uint256) internal _oneToken;

    mapping(address => uint256) internal _expectedBalance;

    mapping(address => mapping(uint256 => uint256)) internal _lastOrder;

    mapping(address => SDLL) internal _prices;

    mapping(address => DLL) internal _orders;

    mapping(address => mapping(address => DLL)) internal _traderOrders;

    mapping(uint256 => address) private _approvals;

    function _withdraw(
        address token,
        address sender,
        address to,
        uint256 amount
    ) internal {
        require(
            traderBalance[token][sender] >= amount,
            "LimitrVault: can't withdraw(): not enough balance"
        );
        if (amount == 0) {
            amount = traderBalance[token][sender];
        }
        traderBalance[token][sender] -= amount;
        _withdrawToken(token, to, amount);
        emit TokenWithdraw(token, sender, to, amount);
    }

    function _tokenTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {
        bool ok = IERC20(token).transfer(to, amount);
        require(ok, "LimitrVault: can't transfer()");
    }

    function _tokenTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool ok = IERC20(token).transferFrom(from, to, amount);
        require(ok, "LimitrVault: can't transferFrom()");
    }

    
    function _withdrawToken(
        address token,
        address to,
        uint256 amount
    ) internal postExecBalanceCheck(token) {
        _expectedBalance[token] -= amount;
        _tokenTransfer(token, to, amount);
    }

    
    function _depositToken(
        address token,
        address from,
        uint256 amount
    ) internal postExecBalanceCheck(token) {
        _expectedBalance[token] += amount;
        _tokenTransferFrom(token, from, address(this), amount);
    }

    
    function _nextID() internal returns (uint256) {
        lastID++;
        return lastID;
    }

    
    
    
    
    
    
    
    
    function _newOrderWithPointer(
        address gotToken,
        uint256 price,
        uint256 amount,
        address trader,
        uint256 deadline,
        uint256 pointer
    )
        internal
        withinDeadline(deadline)
        validToken(gotToken)
        lock
        isTrading
        returns (uint256 orderID, bool created)
    {
        (orderID, created) = _createNewOrder(
            gotToken,
            price,
            amount,
            trader,
            pointer
        );
        if (!created) {
            return (0, false);
        }
        _depositToken(gotToken, msg.sender, amount);
        emit OrderCreated(gotToken, orderID, trader, price, amount);
    }

    function _createNewOrder(
        address gotToken,
        uint256 price,
        uint256 amount,
        address trader,
        uint256 pointer
    ) internal returns (uint256, bool) {
        require(trader != address(0), "LimitrVault: zero address not allowed");
        require(amount > 0, "LimitrVault: zero amount not allowed");
        require(price > 0, "LimitrVault: zero price not allowed");
        // validate pointer
        if (pointer != 0 && _lastOrder[gotToken][pointer] == 0) {
            return (0, false);
        }
        // save the order
        uint256 orderID = _nextID();
        orderInfo[gotToken][orderID] = Order(price, amount, trader);
        // insert order into the order list and insert the price in the
        // price list if necessary
        if (!_insertOrder(gotToken, orderID, price, pointer)) {
            return (0, false);
        }
        // insert order in the trader orders
        _traderOrders[gotToken][trader].insertEnd(orderID);
        // update erc721 balance
        balanceOf[trader] += 1;
        emit Transfer(address(0), trader, orderID);
        // update the liquidity info
        liquidityByPrice[gotToken][price] += amount;
        totalLiquidity[gotToken] += amount;
        return (orderID, true);
    }

    function _insertOrder(
        address gotToken,
        uint256 orderID,
        uint256 price,
        uint256 pointer
    ) internal returns (bool) {
        mapping(uint256 => uint256) storage _last = _lastOrder[gotToken];
        // the insert point is after the last order at the same price
        uint256 _prevID = _last[price];
        if (_prevID == 0) {
            // price doesn't exist. insert it
            if (pointer != 0 && _last[pointer] == 0) {
                return false;
            }
            SDLL storage priceList = _prices[gotToken];
            if (!priceList.insertWithPointer(price, pointer)) {
                return false;
            }
            _prevID = _last[priceList.previous(price)];
        }
        _orders[gotToken].insertAfter(orderID, _prevID);
        _last[price] = orderID;
        return true;
    }

    function _cancelOrder(
        address gotToken,
        uint256 orderID,
        uint256 amount
    ) internal {
        Order memory _order = orderInfo[gotToken][orderID];
        // can only cancel up to the amount of the order
        require(
            _order.amount >= amount,
            "LimitrVault: can't cancel a bigger amount than the order size"
        );
        // 0 means full amount
        uint256 _amount = amount != 0 ? amount : _order.amount;
        uint256 remAmount = _order.amount - _amount;
        if (remAmount == 0) {
            // remove the order from the list. remove the price also if no
            // other order exists at the same price
            _removeOrder(gotToken, orderID);
        } else {
            // update the available amount
            orderInfo[gotToken][orderID].amount = remAmount;
        }
        // update the available liquidity info
        liquidityByPrice[gotToken][_order.price] -= _amount;
        totalLiquidity[gotToken] -= _amount;
        emit OrderCanceled(gotToken, orderID, _order.price, _amount);
    }

    
    function _removeOrder(address gotToken, uint256 orderID) internal {
        uint256 orderPrice = orderInfo[gotToken][orderID].price;
        address orderTrader = orderInfo[gotToken][orderID].trader;
        DLL storage orderList = _orders[gotToken];
        // find previous order
        uint256 _prevID = orderList.previous(orderID);
        // is the previous order at the same price?
        bool prevPriceNotEqual = orderPrice !=
            orderInfo[gotToken][_prevID].price;
        // single order at the price
        bool onlyOrderAtPrice = prevPriceNotEqual &&
            orderPrice != orderInfo[gotToken][orderList.next(orderID)].price;
        // delete the order and remove it from the list
        delete orderInfo[gotToken][orderID];
        orderList.remove(orderID);
        // update _last
        mapping(uint256 => uint256) storage _last = _lastOrder[gotToken];
        if (_last[orderPrice] == orderID) {
            if (prevPriceNotEqual) {
                delete _last[orderPrice];
            } else {
                _last[orderPrice] = _prevID;
            }
        }
        if (onlyOrderAtPrice) {
            // remove price
            _prices[gotToken].remove(orderPrice);
        }
        // update trader orders and ERC721 balance
        _traderOrders[gotToken][orderTrader].remove(orderID);
        balanceOf[orderTrader] -= 1;
        emit Transfer(orderTrader, address(0), orderID);
    }

    function _ERC721SafeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {
        _ERC721Transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _ERC721Transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal lock ERC721TokenMustExist(tokenId) senderAllowed(tokenId) {
        require(
            ownerOf(tokenId) == from,
            "ERC721: transfer of token that is not own"
        );
        require(to != address(0), "ERC721: transfer to the zero address");
        // reset approval for the order
        _approvals[tokenId] = address(0);
        // update balances
        balanceOf[from] -= 1;
        balanceOf[to] += 1;
        // update order
        address t = orderToken(tokenId);
        orderInfo[t][tokenId].trader = to;
        // update trader orders
        _traderOrders[t][from].remove(tokenId);
        _traderOrders[t][to].insertEnd(tokenId);
        emit Transfer(from, to, tokenId);
    }

    function _ERC721Approve(
        address owner,
        address to,
        uint256 tokenId
    ) internal {
        _approvals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.code.length == 0) {
            return true;
        }
        try
            IERC721Receiver(to).onERC721Received(
                msg.sender,
                from,
                tokenId,
                _data
            )
        returns (bytes4 retval) {
            return retval == IERC721Receiver.onERC721Received.selector;
        } catch {
            return false;
        }
    }

    function _returnAtMaxPrice(
        address wantToken,
        uint256 maxAmountIn,
        uint256 maxPrice
    ) internal view returns (uint256 amountIn, uint256 amountOut) {
        uint256 orderID = 0;
        Order memory _order;
        DLL storage orderList = _orders[wantToken];
        while (true) {
            orderID = orderList.next(orderID);
            if (orderID == 0) {
                break;
            }
            _order = orderInfo[wantToken][orderID];
            if (_order.trader == address(0)) {
                break;
            }
            if (_order.price > maxPrice) {
                break;
            }
            uint256 buyAmount = returnAtPrice(
                wantToken,
                maxAmountIn,
                _order.price
            );
            if (buyAmount > _order.amount) {
                buyAmount = _order.amount;
            }
            amountOut += buyAmount;
            uint256 price = costAtPrice(wantToken, buyAmount, _order.price);
            amountIn += price;
            maxAmountIn -= price;
            if (maxAmountIn == 0) {
                break;
            }
        }
    }

    function _otherToken(address token) internal view returns (address) {
        return token == token0 ? token1 : token0;
    }

    function _tradeFirstOrder(
        address wantToken,
        address gotToken,
        TradeHandler memory trade,
        uint256 maxPrice
    ) internal returns (bool) {
        // get the order ID
        uint256 orderID = _orders[wantToken].first();
        if (orderID == 0) {
            return false;
        }
        // get the order
        Order memory _order = orderInfo[wantToken][orderID];
        if (_order.price > maxPrice) {
            return false;
        }
        uint256 buyAmount = returnAtPrice(
            wantToken,
            trade.availableAmountIn,
            _order.price
        );
        if (buyAmount > _order.amount) {
            buyAmount = _order.amount;
        }
        uint256 cost = costAtPrice(wantToken, buyAmount, _order.price);
        // update order owner balance
        traderBalance[gotToken][_order.trader] += cost;
        // update liquidity info
        liquidityByPrice[wantToken][_order.price] -= buyAmount;
        totalLiquidity[wantToken] -= buyAmount;
        // update order
        _order.amount -= buyAmount;
        if (_order.amount == 0) {
            _removeOrder(wantToken, orderID);
        } else {
            orderInfo[wantToken][orderID].amount -= buyAmount;
        }
        // update trade data
        trade.update(cost, buyAmount);
        emit OrderTaken(
            wantToken,
            orderID,
            _order.trader,
            buyAmount,
            _order.price
        );
        if (_order.amount != 0) {
            return false;
        }
        return true;
    }

    function _trade(
        address wantToken,
        uint256 price,
        uint256 maxAmountIn,
        address receiver,
        function(
            address,
            address,
            TradeHandler memory,
            address
        ) _postTradeHandler
    ) internal returns (uint256 amountIn, uint256 amountOut) {
        TradeHandler memory trade = TradeHandler(0, 0, withoutFee(maxAmountIn));
        address gotToken = _otherToken(wantToken);
        while (trade.availableAmountIn > 0) {
            if (!_tradeFirstOrder(wantToken, gotToken, trade, price)) {
                break;
            }
        }
        require(
            trade.amountIn > 0 && trade.amountOut > 0,
            "LimitrVault: no trade"
        );
        _postTradeHandler(wantToken, gotToken, trade, receiver);
        return (withFee(trade.amountIn), trade.amountOut);
    }

    // deposit payment
    // collect fee
    // withdraw purchased tokens
    function _postTrade(
        address wantToken,
        address gotToken,
        TradeHandler memory trade,
        address receiver
    ) internal {
        // deposit payment
        _depositToken(gotToken, msg.sender, trade.amountIn);
        // calculate fee
        uint256 fee = feeFor(trade.amountIn);
        // collect fee
        _tokenTransferFrom(
            gotToken,
            msg.sender,
            ILimitrRegistry(registry).feeReceiver(),
            fee
        );
        emit FeeCollected(gotToken, fee);
        // transfer purchased tokens
        _withdrawToken(wantToken, receiver, trade.amountOut);
    }

    // only collect fee from the vault
    function _postBorrowTrade(
        address,
        address gotToken,
        TradeHandler memory trade,
        address
    ) internal {
        // calculate fee
        uint256 fee = feeFor(trade.amountIn);
        // collect fee
        _withdrawToken(gotToken, ILimitrRegistry(registry).feeReceiver(), fee);
        emit FeeCollected(gotToken, fee);
    }
}