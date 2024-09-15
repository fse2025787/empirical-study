// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;



/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * 
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;




/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// 

pragma solidity ^0.8.3;



struct ChainlinkDataFeed {
    AggregatorV3Interface usdPriceAggrigator;
    bool enabled;
    uint256 decimals;
}

interface IPriceConsumer {
    event PriceFeedAdded(
        address indexed token,
        address indexed usdPriceAggrigator,
        bool enabled,
        uint256 decimals
    );
    event PriceFeedAddedBulk(
        address[] indexed tokens,
        address[] indexed chainlinkFeedAddress,
        bool[] enabled,
        uint256[] decimals
    );
    event PriceFeedStatusUpdated(address indexed token, bool indexed status);

    event PathAdded(address _tokenAddress, address[] indexed _pathRoute);

    
    
    
    
    function getLatestUsdPriceFromChainlink(address priceFeedToken)
        external
        view
        returns (int256, uint8);

    
    
    
    
    
    function getLatestUsdPricesFromChainlink(address[] memory priceFeedToken)
        external
        view
        returns (
            address[] memory tokens,
            int256[] memory prices,
            uint8[] memory decimals
        );

    
    function getNetworkPriceFromChainlinkinUSD() external view returns (int256);

    
    
    
    
    function getSwapData(
        address _collateralToken,
        uint256 _collateralAmount,
        address _borrowStableCoin
    ) external view returns (uint256, uint256);

    
    
    
    
    
    function getNetworkCoinSwapData(
        uint256 _collateralAmount,
        address _borrowStableCoin
    ) external view returns (uint256, uint256);

    
    
    function getSwapInterface(address _collateralTokenAddress)
        external
        view
        returns (address);

    function getSwapInterfaceForETH() external view returns (address);

    
    
    
    
    
    function getDexTokenPrice(
        address _stable,
        address _alt,
        uint256 _amount
    ) external view returns (uint256);

    function getETHPriceFromDex(
        address _stable,
        address _alt,
        uint256 _amount
    ) external view returns (uint256);

    
    function isChainlinFeedEnabled(address _tokenAddress)
        external
        view
        returns (bool);

    
    
    
    function getusdPriceAggrigators(address _tokenAddress)
        external
        view
        returns (ChainlinkDataFeed memory);

    
    
    function getAllChainlinkAggiratorsContract()
        external
        view
        returns (address[] memory);

    
    
    function getAllGovAggiratorsTokens()
        external
        view
        returns (address[] memory);

    
    function WETHAddress() external view returns (address);

    
    
    
    
    
    function getAltCoinPriceinStable(
        address _stableCoin,
        address _altCoin,
        uint256 _collateralAmount
    ) external view returns (uint256);

    
    
    
    
    
    function getClaimTokenPrice(
        address _stable,
        address _alt,
        uint256 _amount
    ) external view returns (uint256);

    
    
    
    
    
    

    function calculateLTV(
        uint256[] memory _stakedCollateralAmounts,
        address[] memory _stakedCollateralTokens,
        address _borrowedToken,
        uint256 _loanAmount
    ) external view returns (uint256);

    
    
    
    
    
    
    function getSUNTokenPrice(
        address _claimToken,
        address _stable,
        address _sunToken,
        uint256 _amount
    ) external view returns (uint256);
}

// 

pragma solidity ^0.8.3;



abstract contract SuperAdminControl {
    
    modifier onlySuperAdmin(address govAdminRegistry, address admin) {
        require(
            IAdminRegistry(govAdminRegistry).isSuperAdminAccess(admin),
            "not super admin"
        );
        _;
    }
}

// 

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

pragma solidity ^0.8.3;














contract PriceConsumer is
    IPriceConsumer,
    OwnableUpgradeable,
    SuperAdminControl
{
    // mapping for the chainlink price feed aggrigator
    mapping(address => ChainlinkDataFeed) public usdPriceAggrigators;
    //chainlink feed contract addresses
    address[] public allFeedContractsChainlink;
    //chainlink feed ERC20 token contract addresses
    address[] public allFeedTokenAddress;

    address public AdminRegistry;
    address public addressProvider;
    IProtocolRegistry public govProtocolRegistry;
    IClaimToken public govClaimTokenContract;
    IUniswapV2Router02 public swapRouterv2;

    
    AggregatorV3Interface public networkCoinUsdPriceFeed;

    
    
    function initialize(address _swapRouterv2) external initializer {
        __Ownable_init();

        swapRouterv2 = IUniswapV2Router02(_swapRouterv2);
    }

    
    
    modifier onlyPriceFeedTokenRole(address admin) {
        require(
            IAdminRegistry(AdminRegistry).isAddTokenRole(admin),
            "GPC: No admin right to add price feed tokens."
        );
        _;
    }

    
    
    function setNetworkCoinUsdPriceFeed(address _networkPriceFeedAddress)
        external
        onlyPriceFeedTokenRole(msg.sender)
    {
        require(_networkPriceFeedAddress != address(0), "GPC: null address");
        networkCoinUsdPriceFeed = AggregatorV3Interface(
            _networkPriceFeedAddress
        );
    }

    
    function updateAddresses() external onlyOwner {
        govProtocolRegistry = IProtocolRegistry(
            IAddressProvider(addressProvider).getProtocolRegistry()
        );
        govClaimTokenContract = IClaimToken(
            IAddressProvider(addressProvider).getClaimTokenContract()
        );
        AdminRegistry = IAddressProvider(addressProvider).getAdminRegistry();
    }

    
    
    function setAddressProvider(address _addressProvider) external onlyOwner {
        require(_addressProvider != address(0), "zero address");
        addressProvider = _addressProvider;
    }

    
    function setSwapRouter(address _swapRouterV2) external onlyOwner {
        require(_swapRouterV2 != address(0), "router null address");
         swapRouterv2 = IUniswapV2Router02(_swapRouterV2);
    }

    
    
    function _isAddedChainlinkFeedAddress(address _chainlinkFeedAddress)
        internal
        view
        returns (bool)
    {
        uint256 length = allFeedContractsChainlink.length;
        for (uint256 i = 0; i < length; i++) {
            if (allFeedContractsChainlink[i] == _chainlinkFeedAddress) {
                return true;
            }
        }
        return false;
    }

    
    /// param _tokenAddress The new token for price feed.
    /// param _chainlinkFeedAddress chainlink feed address
    /// param _enabled    if true then enabled
    /// param _decimals decimals of the chainlink price feed

    function addUsdPriceAggrigator(
        address _tokenAddress,
        address _chainlinkFeedAddress,
        bool _enabled,
        uint256 _decimals
    ) public onlyPriceFeedTokenRole(msg.sender) {
        require(
            !_isAddedChainlinkFeedAddress(_chainlinkFeedAddress),
            "GPC: already added price feed"
        );
        usdPriceAggrigators[_tokenAddress] = ChainlinkDataFeed(
            AggregatorV3Interface(_chainlinkFeedAddress),
            _enabled,
            _decimals
        );
        allFeedContractsChainlink.push(_chainlinkFeedAddress);
        allFeedTokenAddress.push(_tokenAddress);

        emit PriceFeedAdded(
            _tokenAddress,
            _chainlinkFeedAddress,
            _enabled,
            _decimals
        );
    }

    
    
    
    
    

    function addUsdPriceAggrigatorBulk(
        address[] memory _tokenAddress,
        address[] memory _chainlinkFeedAddress,
        bool[] memory _enabled,
        uint256[] memory _decimals
    ) external onlyPriceFeedTokenRole(msg.sender) {
        require(
            (_tokenAddress.length == _chainlinkFeedAddress.length) &&
                (_enabled.length == _decimals.length) &&
                (_enabled.length == _tokenAddress.length)
        );
        for (uint256 i = 0; i < _tokenAddress.length; i++) {
    
            addUsdPriceAggrigator(
                _tokenAddress[i],
                _chainlinkFeedAddress[i],
                _enabled[i],
                _decimals[i]
            );
        }
        emit PriceFeedAddedBulk(
            _tokenAddress,
            _chainlinkFeedAddress,
            _enabled,
            _decimals
        );
    }

    
    

    function changeStatusPriceAggrigator(address _tokenAddress, bool _status)
        external
        onlyPriceFeedTokenRole(msg.sender)
    {
        require(
            usdPriceAggrigators[_tokenAddress].enabled != _status,
            "GPC: already in desired state"
        );
        usdPriceAggrigators[_tokenAddress].enabled = _status;
        emit PriceFeedStatusUpdated(_tokenAddress, _status);
    }

    
    
    
    

    function getLatestUsdPriceFromChainlink(address priceFeedToken)
        external
        view
        override
        returns (int256, uint8)
    {
        (, int256 price, , , ) = usdPriceAggrigators[priceFeedToken]
            .usdPriceAggrigator
            .latestRoundData();
        uint8 decimals = usdPriceAggrigators[priceFeedToken]
            .usdPriceAggrigator
            .decimals();

        return (price, decimals);
    }

    
    
    
    
    
    function getLatestUsdPricesFromChainlink(address[] memory priceFeedToken)
        external
        view
        override
        returns (
            address[] memory tokens,
            int256[] memory prices,
            uint8[] memory decimals
        )
    {
        decimals = new uint8[](priceFeedToken.length);
        tokens = new address[](priceFeedToken.length);
        prices = new int256[](priceFeedToken.length);
        for (uint256 i = 0; i < priceFeedToken.length; i++) {
            (, int256 price, , , ) = usdPriceAggrigators[priceFeedToken[i]]
                .usdPriceAggrigator
                .latestRoundData();
            decimals[i] = usdPriceAggrigators[priceFeedToken[i]]
                .usdPriceAggrigator
                .decimals();
            tokens[i] = priceFeedToken[i];
            prices[i] = price;
        }
        return (tokens, prices, decimals);
    }

    
    
    
    
    
    function getDexTokenPrice(
        address _stable,
        address _alt,
        uint256 _amount
     ) external view override returns (uint256) {
        IDexPair pairALTWETH;
        IDexPair pairWETHSTABLE;

        uint256 priceOfCollateralinWETH;

        Market memory marketData = govProtocolRegistry.getSingleApproveToken(
            _alt
        );

        IUniswapV2Router02 swapRouter;

        if(marketData.dexRouter != address(0x0)) {
            swapRouter = IUniswapV2Router02(marketData.dexRouter);
        } else {
            swapRouter = swapRouterv2;
        }
        {
        pairALTWETH = IDexPair(
            IDexFactory(swapRouter.factory()).getPair(_alt, WETHAddress())
        );

        uint256 token0DecimalsALTWETH = IERC20Extras(pairALTWETH.token0())
            .decimals();
        uint256 token1DecimalsALTWETH = IERC20Extras(pairALTWETH.token1())
            .decimals();

        (uint256 reserve0, uint256 reserve1, ) = pairALTWETH.getReserves();
        //identify the stablecoin out  of token0 and token1
        if (pairALTWETH.token0() == WETHAddress()) {
            // uint256 resD = reserve0 * (10**token1DecimalsALTWETH); //18+18  decimals
            priceOfCollateralinWETH = (_amount * ((reserve0 * (10**token1DecimalsALTWETH)) / (reserve1))) / (10**token1DecimalsALTWETH); // (18+(18-18))-18 = 0 = stable coin decimals
        } else {
            // uint256 resD = reserve1 * (10**token0DecimalsALTWETH);
            priceOfCollateralinWETH = (_amount * ((reserve1 * (10**token0DecimalsALTWETH)) / (reserve0))) / (10**token0DecimalsALTWETH); //
        }
        }

        pairWETHSTABLE = IDexPair(
            IDexFactory(swapRouter.factory()).getPair(_stable, WETHAddress())
        );

        uint256 token0Decimals = IERC20Extras(pairWETHSTABLE.token0())
            .decimals();
        uint256 token1Decimals = IERC20Extras(pairWETHSTABLE.token1())
            .decimals();

        (uint256 res0, uint256 res1, ) = pairWETHSTABLE.getReserves();
        //identify the stablecoin out  of token0 and token1
        if (pairWETHSTABLE.token0() == _stable) {
            // uint256 resD = res0 * (10**token1Decimals); //18+18  decimals
            return (priceOfCollateralinWETH * ((res0 * (10**token1Decimals)) / (res1))) / (10**token1Decimals); // (18+(18-18))-18 = 0 = stable coin decimals
        } else {
            // uint256 resD = res1 * (10**token0Decimals);
            return (priceOfCollateralinWETH * ((res1 * (10**token0Decimals)) / (res0))) / (10**token0Decimals); //
        }
    }

    
    function getETHPriceFromDex(
        address _stable,
        address _alt,
        uint256 _amount
    ) external view override returns (uint256) {

        IDexPair pair = IDexPair(IDexFactory(swapRouterv2.factory()).getPair(_stable, _alt));
    
        uint256 token0Decimals = IERC20Extras(pair.token0()).decimals();
        uint256 token1Decimals = IERC20Extras(pair.token1()).decimals();

        (uint256 res0, uint256 res1, ) = pair.getReserves();
        //identify the stablecoin out  of token0 and token1
        if (pair.token0() == _stable) {
            uint256 resD = res0 * (10**token1Decimals); //18+18  decimals
            return (_amount * (resD / (res1))) / (10**token1Decimals); // (18+(18-18))-18 = 0 = stable coin decimals
        } else {
            uint256 resD = res1 * (10**token0Decimals);
            return (_amount * (resD / (res0))) / (10**token0Decimals); //
        }
    }

    
    
    
    
    

    function getClaimTokenPrice(
        address _stable,
        address _claimToken,
        uint256 _amount
    ) external view override returns (uint256) {
        require(
            govClaimTokenContract.isClaimToken(_claimToken),
            "GPC: not approved claim token"
        );
        ClaimTokenData memory claimTokenData = govClaimTokenContract
            .getClaimTokensData(_claimToken);

        IDexPair pairALTWETH;
        IDexPair pairWETHSTABLE;

        uint256 priceOfCollateralinWETH;

        IUniswapV2Router02 swapRouter;

        if (claimTokenData.dexRouter != address(0x0)) {
            swapRouter = IUniswapV2Router02(claimTokenData.dexRouter);
        } else {
            swapRouter = swapRouterv2;
        }
        // using block scoping here for stack too deep error
        {
            pairALTWETH = IDexPair(
                IDexFactory(swapRouter.factory()).getPair(
                    _claimToken,
                    WETHAddress()
                )
            );

            uint256 token0DecimalsALTWETH = IERC20Extras(pairALTWETH.token0())
                .decimals();
            uint256 token1DecimalsALTWETH = IERC20Extras(pairALTWETH.token1())
                .decimals();

            (uint256 reserve0, uint256 reserve1, ) = pairALTWETH.getReserves();
            //identify the stablecoin out  of token0 and token1
            if (pairALTWETH.token0() == WETHAddress()) {
                // uint256 resD = reserve0 * (10**token1DecimalsALTWETH); //18+18  decimals
                priceOfCollateralinWETH =
                    (_amount *
                        ((reserve0 * (10**token1DecimalsALTWETH)) /
                            (reserve1))) /
                    (10**token1DecimalsALTWETH); // (18+(18-18))-18 = 0 = stable coin decimals
            } else {
                // uint256 resD = reserve1 * (10**token0DecimalsALTWETH);
                priceOfCollateralinWETH =
                    (_amount *
                        ((reserve1 * (10**token0DecimalsALTWETH)) /
                            (reserve0))) /
                    (10**token0DecimalsALTWETH); //
            }
        }

        pairWETHSTABLE = IDexPair(
            IDexFactory(swapRouter.factory()).getPair(_stable, WETHAddress())
        );

        uint256 token0Decimals = IERC20Extras(pairWETHSTABLE.token0())
            .decimals();
        uint256 token1Decimals = IERC20Extras(pairWETHSTABLE.token1())
            .decimals();

        (uint256 res0, uint256 res1, ) = pairWETHSTABLE.getReserves();
        //identify the stablecoin out  of token0 and token1
        if (pairWETHSTABLE.token0() == _stable) {
            // uint256 resD = res0 * (10**token1Decimals); //18+18  decimals
            return
                (priceOfCollateralinWETH *
                    ((res0 * (10**token1Decimals)) / (res1))) /
                (10**token1Decimals); // (18+(18-18))-18 = 0 = stable coin decimals
        } else {
            // uint256 resD = res1 * (10**token0Decimals);
            return
                (priceOfCollateralinWETH *
                    ((res1 * (10**token0Decimals)) / (res0))) /
                (10**token0Decimals); //
        }
    }

    
    
    
    

    function getSUNTokenPrice(
        address _claimToken,
        address _stable,
        address _sunToken,
        uint256 _amount
    ) external view override returns (uint256) {
        require(
            govClaimTokenContract.isClaimToken(_claimToken),
            "GPC: not approved claim token"
        );
        ClaimTokenData memory claimTokenData = govClaimTokenContract
            .getClaimTokensData(_claimToken);

        uint256 pegTokensPricePercentage;
        uint256 claimTokenPrice = this.getClaimTokenPrice(
            _stable,
            _claimToken,
            _amount
        );
        uint256 lengthPegTokens = claimTokenData.pegTokens.length;
        for (uint256 i = 0; i < lengthPegTokens; i++) {
            if (claimTokenData.pegTokens[i] == _sunToken) {
                pegTokensPricePercentage = claimTokenData
                    .pegTokensPricePercentage[i];
            }
        }

        return (claimTokenPrice * pegTokensPricePercentage) / 10000;
    }

    
    

    function getNetworkPriceFromChainlinkinUSD()
        external
        view
        override
        returns (int256)
    {
        (, int256 price, , , ) = networkCoinUsdPriceFeed.latestRoundData();
        return price;
    }

    
    
    
    
    
    

    function getSwapData(
        address _collateralToken,
        uint256 _collateralAmount,
        address _borrowStableCoin
    ) external view override returns (uint256, uint256) {
        Market memory marketData = govProtocolRegistry.getSingleApproveToken(
            _collateralToken
        );

        // swap router address uniswap or sushiswap or any uniswap like modal dex
        IUniswapV2Router02 swapRouter = IUniswapV2Router02(
            marketData.dexRouter
        );

        IDexPair pair;

        if (marketData.dexRouter != address(0x0)) {
            pair = IDexPair(
                IDexFactory(swapRouter.factory()).getPair(
                    _borrowStableCoin,
                    _collateralToken
                )
            );
        } else {
            pair = IDexPair(
                IDexFactory(swapRouterv2.factory()).getPair(
                    _borrowStableCoin,
                    _collateralToken
                )
            );
        }

        (uint256 reserveIn, uint256 reserveOut, ) = IDexPair(pair)
            .getReserves();
        uint256 amountOut = swapRouter.getAmountOut(
            _collateralAmount,
            reserveIn,
            reserveOut
        );
        uint256 amountIn = swapRouter.getAmountIn(
            amountOut,
            reserveIn,
            reserveOut
        );
        return (amountIn, amountOut);
    }

    
    
    
    
    

    function getNetworkCoinSwapData(
        uint256 _collateralAmount,
        address _borrowStableCoin
    ) external view override returns (uint256, uint256) {
        IDexPair pair;

        pair = IDexPair(
            IDexFactory(swapRouterv2.factory()).getPair(
                this.WETHAddress(),
                _borrowStableCoin
            )
        );

        (uint256 reserveIn, uint256 reserveOut, ) = IDexPair(pair)
            .getReserves();
        uint256 amountOut = swapRouterv2.getAmountOut(
            _collateralAmount,
            reserveOut,
            reserveIn
        );
        uint256 amountIn = swapRouterv2.getAmountIn(
            amountOut,
            reserveOut,
            reserveIn
        );
        return (amountIn, amountOut);
    }

    
    
    
    function getSwapInterface(address _approvedCollateralToken)
        external
        view
        override
        returns (address)
    {
        Market memory marketData = govProtocolRegistry.getSingleApproveToken(
            _approvedCollateralToken
        );

        // swap router address uniswap or sushiswap or any uniswap like modal dex
        IUniswapV2Router02 swapRouter = IUniswapV2Router02(
            marketData.dexRouter
        );
        return address(swapRouter);
    }

    
    
    function getSwapInterfaceForETH() external view override returns (address) {
        return address(swapRouterv2);
    }

    
    
    
    function isChainlinFeedEnabled(address _tokenAddress)
        external
        view
        override
        returns (bool)
    {
        return usdPriceAggrigators[_tokenAddress].enabled;
    }

    
    function getusdPriceAggrigators(address _tokenAddress)
        external
        view
        override
        returns (ChainlinkDataFeed memory)
    {
        return usdPriceAggrigators[_tokenAddress];
    }

    
    function getAllChainlinkAggiratorsContract()
        external
        view
        override
        returns (address[] memory)
    {
        return allFeedContractsChainlink;
    }

    
    function getAllGovAggiratorsTokens()
        external
        view
        override
        returns (address[] memory)
    {
        return allFeedTokenAddress;
    }

    
    function WETHAddress() public view override returns (address) {
        return swapRouterv2.WETH();
    }

    
    
    
    

    function calculateLTV(
        uint256[] memory _stakedCollateralAmounts,
        address[] memory _stakedCollateralTokens,
        address _borrowedToken,
        uint256 _loanAmount
    ) external view override returns (uint256) {
        //IERC20Extras stableDecimals = IERC20Extras(stkaedCollateralTokens);
        uint256 totalCollateralInBorrowedToken;

        for (uint256 i = 0; i < _stakedCollateralAmounts.length; i++) {
            uint256 collatetralInBorrowed;
            address claimToken = govClaimTokenContract.getClaimTokenofSUNToken(
                _stakedCollateralTokens[i]
            );

            if (govClaimTokenContract.isClaimToken(claimToken)) {
                collatetralInBorrowed =
                    collatetralInBorrowed +
                    (
                        this.getSUNTokenPrice(
                            claimToken,
                            _borrowedToken,
                            _stakedCollateralTokens[i],
                            _stakedCollateralAmounts[i]
                        )
                    );
            } else {
                collatetralInBorrowed =
                    collatetralInBorrowed +
                    (
                        this.getAltCoinPriceinStable(
                            _borrowedToken,
                            _stakedCollateralTokens[i],
                            _stakedCollateralAmounts[i]
                        )
                    );
            }

            totalCollateralInBorrowedToken =
                totalCollateralInBorrowedToken +
                collatetralInBorrowed;
        }
        return (totalCollateralInBorrowedToken * 100) / _loanAmount;
    }

    
    
    
    

    function getAltCoinPriceinStable(
        address _stableCoin,
        address _altCoin,
        uint256 _collateralAmount
    ) external view override returns (uint256) {
        uint256 collateralAmountinStable;
        if (
            this.isChainlinFeedEnabled(_altCoin) &&
            this.isChainlinFeedEnabled(_stableCoin)
        ) {
            (int256 collateralChainlinkUsd, uint8 atlCoinDecimals) = this
                .getLatestUsdPriceFromChainlink(_altCoin);
            uint256 collateralUsd = (uint256(collateralChainlinkUsd) *
                _collateralAmount) / (atlCoinDecimals);
            (int256 priceFromChainLinkinStable, uint8 stableDecimals) = this
                .getLatestUsdPriceFromChainlink(_stableCoin);
            collateralAmountinStable =
                collateralAmountinStable +
                ((collateralUsd / (uint256(priceFromChainLinkinStable))) *
                    (stableDecimals));
            return collateralAmountinStable;
        } else {

            address claimToken = govClaimTokenContract
                .getClaimTokenofSUNToken(_altCoin);

            if (govClaimTokenContract.isClaimToken(claimToken)) {
                collateralAmountinStable =
                    collateralAmountinStable +
                    (
                        this.getSUNTokenPrice(
                            claimToken,
                            _stableCoin,
                            _altCoin,
                            _collateralAmount
                        )
                    );
            }
            else {
            collateralAmountinStable =
                collateralAmountinStable +
                (
                    this.getDexTokenPrice(
                        _stableCoin,
                        _altCoin,
                        _collateralAmount
                    )
                );
            }
            return collateralAmountinStable;
        }
    }
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// 

pragma solidity ^0.8.3;

interface IDexFactory {
    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);
}

// 

pragma solidity ^0.8.3;

interface IDexPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

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

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

// 

pragma solidity ^0.8.3;

interface IERC20Extras {
    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);
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
}

// 
pragma solidity ^0.8.3;

enum TokenType {
    ISDEX,
    ISELITE,
    ISVIP
}

// Token Market Data
struct Market {
    address dexRouter;
    address gToken;
    bool isMint;
    TokenType tokenType;
    bool isTokenEnabledAsCollateral;
}

interface IProtocolRegistry {
    
    
    
    function isTokenApproved(address _tokenAddress)
        external
        view
        returns (bool);

    
    
    

    function isTokenEnabledForCreateLoan(address _tokenAddress)
        external
        view
        returns (bool);

    function getGovPlatformFee() external view returns (uint256);

    function getThresholdPercentage() external view returns (uint256);

    function getAutosellPercentage() external view returns (uint256);

    function getSingleApproveToken(address _tokenAddress)
        external
        view
        returns (Market memory);

    function getSingleApproveTokenData(address _tokenAddress)
        external
        view
        returns (
            address,
            bool,
            uint256
        );

    function isSyntheticMintOn(address _token) external view returns (bool);

    function getTokenMarket() external view returns (address[] memory);

    function getSingleTokenSps(address _tokenAddress)
        external
        view
        returns (address[] memory);

    function isAddedSPWallet(address _tokenAddress, address _walletAddress)
        external
        view
        returns (bool);

    function isStableApproved(address _stable) external view returns (bool);
}

// 

pragma solidity ^0.8.3;

struct ClaimTokenData {
    // token type is used for token type sun or peg token
    uint256 tokenType;
    address[] pegTokens;
    uint256[] pegTokensPricePercentage;
    address dexRouter; //this address will get the price from the AMM DEX (uniswap, sushiswap etc...)
}

interface IClaimToken {
    function isClaimToken(address _claimTokenAddress)
        external
        view
        returns (bool);

    function getClaimTokensData(address _claimTokenAddress)
        external
        view
        returns (ClaimTokenData memory);

    function getClaimTokenofSUNToken(address _sunToken)
        external
        view
        returns (address);
}

// 

pragma solidity ^0.8.3;


interface IAddressProvider {
    function getAdminRegistry() external view returns (address);

    function getProtocolRegistry() external view returns (address);

    function getPriceConsumer() external view returns (address);

    function getClaimTokenContract() external view returns (address);

    function getGTokenFactory() external view returns (address);

    function getLiquidator() external view returns (address);

    function getTokenMarketRegistry() external view returns (address);

    function getTokenMarket() external view returns (address);

    function getNftMarket() external view returns (address);

    function getNetworkMarket() external view returns (address);

    function govTokenAddress() external view returns (address);

    function getGovTier() external view returns (address);

    function getgovGovToken() external view returns (address);

    function getGovNFTTier() external view returns (address);

    function getVCTier() external view returns (address);

    function getUserTier() external view returns (address);
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

// 
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// 
pragma solidity ^0.8.3;

interface IAdminRegistry {
    struct AdminAccess {
        //access-modifier variables to add projects to gov-intel
        bool addGovIntel;
        bool editGovIntel;
        //access-modifier variables to add tokens to gov-world protocol
        bool addToken;
        bool editToken;
        //access-modifier variables to add strategic partners to gov-world protocol
        bool addSp;
        bool editSp;
        //access-modifier variables to add gov-world admins to gov-world protocol
        bool addGovAdmin;
        bool editGovAdmin;
        //access-modifier variables to add bridges to gov-world protocol
        bool addBridge;
        bool editBridge;
        //access-modifier variables to add pools to gov-world protocol
        bool addPool;
        bool editPool;
        //superAdmin role assigned only by the super admin
        bool superAdmin;
    }

    function isAddGovAdminRole(address admin) external view returns (bool);

    //using this function externally in Gov Tier Level Smart Contract
    function isEditAdminAccessGranted(address admin)
        external
        view
        returns (bool);

    //using this function externally in other Smart Contracts
    function isAddTokenRole(address admin) external view returns (bool);

    //using this function externally in other Smart Contracts
    function isEditTokenRole(address admin) external view returns (bool);

    //using this function externally in other Smart Contracts
    function isAddSpAccess(address admin) external view returns (bool);

    //using this function externally in other Smart Contracts
    function isEditSpAccess(address admin) external view returns (bool);

    //using this function in loan smart contracts to withdraw network balance
    function isSuperAdminAccess(address admin) external view returns (bool);
}