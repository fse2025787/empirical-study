// SPDX-License-Identifier: BUSL-1.1

/**
 *Submitted for verification at Etherscan.io on 2022-09-14
*/

// 

pragma solidity ^0.8.0;

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



contract LimitrRegistry is ILimitrRegistry {
    
    address public override admin;

    
    address public override router;

    
    address public override vaultImplementation;

    
    address public override feeReceiver;

    
    address[] public override vault;

    
    mapping(bytes32 => address) public override vaultByHash;

    
    address public override vaultScanner;

    address private _deployer;

    constructor() {
        admin = msg.sender;
        feeReceiver = msg.sender;
        _deployer = msg.sender;
    }

    
    
    
    
    function initialize(
        address _router,
        address _vaultScanner,
        address _vaultImplementation
    ) external override {
        require(msg.sender == _deployer, "LimitrRegistry: not the deployer");
        require(router == address(0), "LimitrRegistry: already initialized");
        router = _router;
        vaultScanner = _vaultScanner;
        vaultImplementation = _vaultImplementation;
    }

    string[] internal _uriNames;

    
    function JS_names() external view override returns (string[] memory) {
        return _uriNames;
    }

    
    mapping(string => string) public override JS_get;

    
    function JS_getAll()
        external
        view
        override
        returns (string[] memory, string[] memory)
    {
        string[] memory rn = new string[](_uriNames.length);
        string[] memory ru = new string[](_uriNames.length);
        for (uint256 i = 0; i < _uriNames.length; i++) {
            rn[i] = _uriNames[i];
            ru[i] = JS_get[rn[i]];
        }
        return (rn, ru);
    }

    
    
    
    function JS_add(string calldata name, string calldata uri)
        external
        override
        onlyAdmin
    {
        require(bytes(JS_get[name]).length == 0, "JSM: Already exists");
        _uriNames.push(name);
        JS_get[name] = uri;
    }

    
    
    function JS_remove(string calldata name) external override onlyAdmin {
        bytes32 nameK = keccak256(abi.encodePacked(name));
        for (uint256 i = 0; i < _uriNames.length; i++) {
            if (nameK != keccak256(abi.encodePacked(_uriNames[i]))) {
                continue;
            }
            _uriNames[i] = _uriNames[_uriNames.length - 1];
            _uriNames.pop();
            delete JS_get[name];
            return;
        }
        require(true == false, "JSM: Not found");
    }

    
    
    
    function JS_update(string calldata name, string calldata newUri)
        external
        override
        onlyAdmin
    {
        require(bytes(JS_get[name]).length != 0, "JSM: Not found");
        JS_get[name] = newUri;
    }

    
    
    function transferAdmin(address newAdmin) external override onlyAdmin {
        admin = newAdmin;
        emit AdminUpdated(newAdmin);
    }

    
    
    function setFeeReceiver(address newFeeReceiver)
        external
        override
        onlyAdmin
    {
        feeReceiver = newFeeReceiver;
        emit FeeReceiverUpdated(newFeeReceiver);
    }

    
    
    function setVaultImplementation(address newVaultImplementation)
        external
        override
        onlyAdmin
    {
        vaultImplementation = newVaultImplementation;
        emit VaultImplementationUpdated(newVaultImplementation);
    }

    
    
    
    
    function createVault(address tokenA, address tokenB)
        external
        override
        noZeroAddress(tokenA)
        noZeroAddress(tokenB)
        returns (address)
    {
        require(tokenA != tokenB, "LimitrRegistry: equal src and dst tokens");
        (address t0, address t1) = _sortTokens(tokenA, tokenB);
        bytes32 hash = keccak256(abi.encodePacked(t0, t1));
        require(
            vaultByHash[hash] == address(0),
            "LimitrRegistry: vault already exists"
        );
        address addr = _deployClone(vaultImplementation);
        ILimitrVault(addr).initialize(t0, t1);
        vaultByHash[hash] = addr;
        vault.push(addr);
        emit VaultCreated(addr, t0, t1);
        return addr;
    }

    
    function vaultsCount() external view override returns (uint256) {
        return vault.length;
    }

    
    
    
    function vaults(uint256 idx, uint256 n)
        public
        view
        override
        returns (address[] memory)
    {
        address[] memory r = new address[](n);
        for (uint256 i = 0; i < n && idx + i < vault.length; i++) {
            r[i] = vault[idx + i];
        }
        return r;
    }

    
    
    
    function vaultFor(address tokenA, address tokenB)
        external
        view
        override
        noZeroAddress(tokenA)
        noZeroAddress(tokenB)
        returns (address)
    {
        require(
            tokenA != tokenB,
            "LimitrRegistry: equal base and counter tokens"
        );
        return vaultByHash[_vaultHash(tokenA, tokenB)];
    }

    
    
    
    
    function vaultHash(address tokenA, address tokenB)
        public
        pure
        override
        returns (bytes32)
    {
        require(tokenA != tokenB, "LimitrRegistry: equal src and dst tokens");
        return _vaultHash(tokenA, tokenB);
    }

    // modifiers

    
    modifier noZeroAddress(address addr) {
        require(addr != address(0), "LimitrRegistry: zero address not allowed");
        _;
    }

    
    modifier onlyAdmin() {
        require(msg.sender == admin, "LimitrRegistry: not the admin");
        _;
    }

    // private/internal functions

    function _sortTokens(address a, address b)
        internal
        pure
        returns (address, address)
    {
        return a < b ? (a, b) : (b, a);
    }

    function _vaultHash(address a, address b) internal pure returns (bytes32) {
        (address t0, address t1) = _sortTokens(a, b);
        return keccak256(abi.encodePacked(t0, t1));
    }

    function _buildCloneBytecode(address impl)
        internal
        pure
        returns (bytes memory)
    {
        // calldatacopy(0, 0, calldatasize())
        // 3660008037

        // 0x36 CALLDATASIZE
        // 0x60 PUSH1 0x00
        // 0x80 DUP1
        // 0x37 CALLDATACOPY

        // let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
        // 600080368173xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx5af4

        // 0x60 PUSH1 0x00
        // 0x80 DUP1
        // 0x36 CALLDATASIZE
        // 0x81 DUP2
        // 0x73 PUSH20 <concat-address-here>
        // 0x5A GAS
        // 0xF4 DELEGATECALL

        // returndatacopy(0, 0, returndatasize())
        // 3d6000803e

        // 0x3D RETURNDATASIZE
        // 0x60 PUSH1 0x00
        // 0x80 DUP1
        // 0x3E RETURNDATACOPY

        // switch result
        // case 0 { revert(0, returndatasize()) }
        // case 1 { return(0, returndatasize()) }
        // 60003d91600114603157fd5bf3

        // 0x60 PUSH1 0x00
        // 0x3D RETURNDATASIZE
        // 0x91 SWAP2
        // 0x60 PUSH1 0x01
        // 0x14 EQ
        // 0x60 PUSH1 0x31
        // 0x57 JUMPI
        // 0xFD REVERT
        // 0x5B JUMPEST
        // 0xF3 RETURN

        return
            bytes.concat(
                bytes(hex"3660008037600080368173"),
                bytes20(impl),
                bytes(hex"5af43d6000803e60003d91600114603157fd5bf3")
            );
    }

    function _prependCloneConstructor(address impl)
        internal
        pure
        returns (bytes memory)
    {
        // codecopy(0, ofs, codesize() - ofs)
        // return(0, codesize() - ofs)

        // 0x60 PUSH1 0x0D
        // 0x80 DUP1
        // 0x38 CODESIZE
        // 0x03 SUB
        // 0x80 DUP1
        // 0x91 SWAP2
        // 0x60 PUSH1 0x00
        // 0x39 CODECOPY
        // 0x60 PUSH1 0x00
        // 0xF3 RETURN
        // <concat-contract-code-here>

        // 0x600D80380380916000396000F3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        return
            bytes.concat(
                hex"600D80380380916000396000F3",
                _buildCloneBytecode(impl)
            );
    }

    function _deployClone(address impl)
        internal
        returns (address deploymentAddr)
    {
        bytes memory code = _prependCloneConstructor(impl);
        assembly {
            deploymentAddr := create(callvalue(), add(code, 0x20), mload(code))
        }
        require(
            deploymentAddr != address(0),
            "LimitrRegistry: clone deployment failed"
        );
    }
}