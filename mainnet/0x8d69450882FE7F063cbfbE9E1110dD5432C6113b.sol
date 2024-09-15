// SPDX-License-Identifier: BUSL-1.1

/**
 *Submitted for verification at Etherscan.io on 2022-09-14
*/

// 

pragma solidity ^0.8.0;

interface WETH9 {
    event Approval(address indexed src, address indexed guy, uint256 wad);
    event Transfer(address indexed src, address indexed dst, uint256 wad);
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function totalSupply() external view returns (uint256);

    function approve(address guy, uint256 wad) external returns (bool);

    function transfer(address dst, uint256 wad) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);
}



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



interface ILimitrRouter {
    
    function registry() external view returns (address);

    
    function weth() external view returns (address);

    // order creation functions

    
    
    
    
    
    
    
    
    function newOrder(
        address gotToken,
        address wantToken,
        uint256 price,
        uint256 amount,
        address trader,
        uint256 deadline
    ) external returns (uint256);

    
    
    
    
    
    
    
    
    
    function newOrderWithPointer(
        address gotToken,
        address wantToken,
        uint256 price,
        uint256 amount,
        address trader,
        uint256 deadline,
        uint256 pointer
    ) external returns (uint256);

    
    
    
    
    
    
    
    
    
    function newOrderWithPointers(
        address gotToken,
        address wantToken,
        uint256 price,
        uint256 amount,
        address trader,
        uint256 deadline,
        uint256[] memory pointers
    ) external returns (uint256);

    
    
    
    
    
    
    function newETHOrder(
        address wantToken,
        uint256 price,
        address trader,
        uint256 deadline
    ) external payable returns (uint256);

    
    
    
    
    
    
    
    function newETHOrderWithPointer(
        address wantToken,
        uint256 price,
        address trader,
        uint256 deadline,
        uint256 pointer
    ) external payable returns (uint256);

    
    
    
    
    
    
    
    function newETHOrderWithPointers(
        address wantToken,
        uint256 price,
        address trader,
        uint256 deadline,
        uint256[] memory pointers
    ) external payable returns (uint256);

    // order cancellation functions

    
    
    
    
    
    
    function cancelETHOrder(
        address wantToken,
        uint256 orderID,
        uint256 amount,
        address payable receiver,
        uint256 deadline
    ) external;

    // trading functions

    
    ///         vault with a maximum price (per order). This function includes
    ///         the fee in the limit set by `maxAmountIn`
    
    
    
    
    
    
    
    
    function tradeAtMaxPrice(
        address wantToken,
        address gotToken,
        uint256 maxPrice,
        uint256 maxAmountIn,
        address receiver,
        uint256 deadline
    ) external returns (uint256 cost, uint256 received);

    
    ///         vault with a maximum price (per order). This function includes
    ///         the fee in the limit set by `maxAmountIn`
    
    
    
    
    
    
    
    function tradeForETHAtMaxPrice(
        address gotToken,
        uint256 maxPrice,
        uint256 maxAmountIn,
        address payable receiver,
        uint256 deadline
    ) external returns (uint256 cost, uint256 received);

    
    ///         (per order). This function includes the fee in the limit set by `msg.value`
    
    
    
    
    
    
    function tradeETHAtMaxPrice(
        address wantToken,
        uint256 maxPrice,
        address receiver,
        uint256 deadline
    ) external payable returns (uint256 cost, uint256 received);

    
    
    
    
    function withdrawETH(
        address gotToken,
        address payable to,
        uint256 amount
    ) external;
}



///         vault creation
contract LimitrRouter is ILimitrRouter {
    
    address public immutable override registry;

    
    address public immutable override weth;

    constructor(address _weth, address _registry) {
        weth = _weth;
        registry = _registry;
    }

    receive() external payable {}

    // order creation functions

    
    
    
    
    
    
    
    
    function newOrder(
        address gotToken,
        address wantToken,
        uint256 price,
        uint256 amount,
        address trader,
        uint256 deadline
    ) external override returns (uint256) {
        return
            newOrderWithPointer(
                gotToken,
                wantToken,
                price,
                amount,
                trader,
                deadline,
                0
            );
    }

    
    
    
    
    
    
    
    
    
    function newOrderWithPointer(
        address gotToken,
        address wantToken,
        uint256 price,
        uint256 amount,
        address trader,
        uint256 deadline,
        uint256 pointer
    ) public override returns (uint256) {
        uint256[] memory pointers = new uint256[](1);
        pointers[0] = pointer;
        return
            newOrderWithPointers(
                gotToken,
                wantToken,
                price,
                amount,
                trader,
                deadline,
                pointers
            );
    }

    
    
    
    
    
    
    
    
    
    function newOrderWithPointers(
        address gotToken,
        address wantToken,
        uint256 price,
        uint256 amount,
        address trader,
        uint256 deadline,
        uint256[] memory pointers
    ) public override returns (uint256) {
        ILimitrVault v = _getOrCreateVault(gotToken, wantToken);
        _tokenTransferFrom(gotToken, msg.sender, address(this), amount);
        _tokenApprove(gotToken, address(v), amount);
        return
            v.newOrderWithPointers(
                gotToken,
                price,
                amount,
                trader,
                deadline,
                pointers
            );
    }

    
    
    
    
    
    
    function newETHOrder(
        address wantToken,
        uint256 price,
        address trader,
        uint256 deadline
    ) external payable override returns (uint256) {
        return newETHOrderWithPointer(wantToken, price, trader, deadline, 0);
    }

    
    
    
    
    
    
    
    function newETHOrderWithPointer(
        address wantToken,
        uint256 price,
        address trader,
        uint256 deadline,
        uint256 pointer
    ) public payable override returns (uint256) {
        uint256[] memory pointers = new uint256[](1);
        pointers[0] = pointer;
        return
            newETHOrderWithPointers(
                wantToken,
                price,
                trader,
                deadline,
                pointers
            );
    }

    
    
    
    
    
    
    
    function newETHOrderWithPointers(
        address wantToken,
        uint256 price,
        address trader,
        uint256 deadline,
        uint256[] memory pointers
    ) public payable override returns (uint256) {
        ILimitrVault v = _getOrCreateVault(weth, wantToken);
        uint256 amt = _wrapBalance();
        _tokenApprove(weth, address(v), amt);
        return
            v.newOrderWithPointers(
                weth,
                price,
                amt,
                trader,
                deadline,
                pointers
            );
    }

    // order cancellation functions

    
    
    
    
    
    
    function cancelETHOrder(
        address wantToken,
        uint256 orderID,
        uint256 amount,
        address payable receiver,
        uint256 deadline
    ) external override {
        ILimitrVault v = _getExistingVault(weth, wantToken);
        require(v.isAllowed(msg.sender, orderID), "LimitrRouter: not allowed");
        v.cancelOrder(orderID, amount, address(this), deadline);
        _unwrapBalance();
        _returnETHBalance(receiver);
    }

    // trading functions

    
    ///         vault with a maximum price (per order). This function includes
    ///         the fee in the limit set by `maxAmountIn`
    
    
    
    
    
    
    
    
    function tradeAtMaxPrice(
        address wantToken,
        address gotToken,
        uint256 maxPrice,
        uint256 maxAmountIn,
        address receiver,
        uint256 deadline
    ) external override returns (uint256 cost, uint256 received) {
        ILimitrVault v = _getExistingVault(wantToken, gotToken);
        _tokenTransferFrom(gotToken, msg.sender, address(this), maxAmountIn);
        _tokenApprove(gotToken, address(v), maxAmountIn);
        (cost, received) = v.tradeAtMaxPrice(
            wantToken,
            maxPrice,
            maxAmountIn,
            receiver,
            deadline
        );
        _returnTokenBalance(gotToken, msg.sender);
    }

    
    ///         vault with a maximum price (per order). This function includes
    ///         the fee in the limit set by `maxAmountIn`
    
    
    
    
    
    
    
    function tradeForETHAtMaxPrice(
        address gotToken,
        uint256 maxPrice,
        uint256 maxAmountIn,
        address payable receiver,
        uint256 deadline
    ) external override returns (uint256 cost, uint256 received) {
        ILimitrVault v = _getExistingVault(weth, gotToken);
        _tokenTransferFrom(gotToken, msg.sender, address(this), maxAmountIn);
        _tokenApprove(gotToken, address(v), maxAmountIn);
        (cost, received) = v.tradeAtMaxPrice(
            weth,
            maxPrice,
            maxAmountIn,
            address(this),
            deadline
        );
        _unwrapBalance();
        _returnETHBalance(receiver);
        _returnTokenBalance(gotToken, msg.sender);
    }

    
    ///         (per order). This function includes the fee in the limit set by `msg.value`
    
    
    
    
    
    
    function tradeETHAtMaxPrice(
        address wantToken,
        uint256 maxPrice,
        address receiver,
        uint256 deadline
    ) external payable override returns (uint256 cost, uint256 received) {
        ILimitrVault v = _getExistingVault(weth, wantToken);
        uint256 maxAmountIn = _wrapBalance();
        _tokenApprove(weth, address(v), maxAmountIn);
        (cost, received) = v.tradeAtMaxPrice(
            wantToken,
            maxPrice,
            maxAmountIn,
            receiver,
            deadline
        );
        _unwrapBalance();
        _returnETHBalance(payable(msg.sender));
    }

    
    
    
    
    function withdrawETH(
        address gotToken,
        address payable to,
        uint256 amount
    ) external override {
        ILimitrVault v = _getExistingVault(weth, gotToken);
        v.withdrawFor(weth, msg.sender, address(this), amount);
        _unwrapBalance();
        _returnETHBalance(to);
    }

    // internal / private functions

    function _getOrCreateVault(address tokenA, address tokenB)
        internal
        returns (ILimitrVault)
    {
        ILimitrRegistry r = ILimitrRegistry(registry);
        address v = r.vaultFor(tokenA, tokenB);
        if (v == address(0)) {
            v = r.createVault(tokenA, tokenB);
        }
        return ILimitrVault(v);
    }

    function _getExistingVault(address tokenA, address tokenB)
        internal
        view
        returns (ILimitrVault)
    {
        address v = ILimitrRegistry(registry).vaultFor(tokenA, tokenB);
        require(v != address(0), "LimitrRouter: vault doesn't exist");
        return ILimitrVault(v);
    }

    function _returnETHBalance(address payable receiver) internal {
        uint256 amt = address(this).balance;
        if (amt == 0) {
            return;
        }
        receiver.transfer(amt);
    }

    function _returnTokenBalance(address token, address receiver) internal {
        IERC20 t = IERC20(token);
        uint256 amt = t.balanceOf(address(this));
        if (amt == 0) {
            return;
        }
        _tokenTransfer(token, receiver, amt);
    }

    function _tokenApprove(
        address token,
        address spender,
        uint256 amount
    ) internal {
        IERC20(token).approve(spender, amount);
    }

    function _tokenTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {
        bool ok = IERC20(token).transfer(to, amount);
        require(ok, "LimitrRouter: can't transfer()");
    }

    function _tokenTransferFrom(
        address token,
        address owner,
        address to,
        uint256 amount
    ) internal {
        bool ok = IERC20(token).transferFrom(owner, to, amount);
        require(ok, "LimitrRouter: can't transferFrom()");
    }

    function _wrapBalance() internal returns (uint256) {
        uint256 amt = address(this).balance;
        WETH9(weth).deposit{value: amt}();
        return amt;
    }

    function _unwrapBalance() internal {
        uint256 amt = IERC20(weth).balanceOf(address(this));
        if (amt == 0) {
            return;
        }
        WETH9(weth).withdraw(amt);
    }
}