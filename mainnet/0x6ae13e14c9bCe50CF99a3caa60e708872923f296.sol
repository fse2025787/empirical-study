// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;


// 
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

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
        bool isTopLevelCall = _setInitializedVersion(1);
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
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// 

pragma solidity >=0.6.0 <0.9.0;






abstract contract AccessControlMixin {
    IAccessControlProxy public accessControlProxy;

    function _initAccessControl(address _accessControlProxy) internal {
        accessControlProxy = IAccessControlProxy(_accessControlProxy);
    }

    
    /// Revert with a standard message if `_account` is missing `_role`.
    modifier hasRole(bytes32 _role, address _account) {
        accessControlProxy.checkRole(_role, _account);
        _;
    }

    
    /// Reverts  with a standardized message including the required role.
    modifier onlyRole(bytes32 _role) {
        accessControlProxy.checkRole(_role, msg.sender);
        _;
    }

    
    /// Reverts  with a standardized message including the required role.
    modifier onlyGovOrDelegate() {
        accessControlProxy.checkGovOrDelegate(msg.sender);
        _;
    }

    
    modifier isVaultManager() {
        accessControlProxy.checkVaultOrGov(msg.sender);
        _;
    }

    
    modifier isKeeper() {
        accessControlProxy.checkKeeperOrVaultOrGov(msg.sender);
        _;
    }
}

// 

pragma solidity ^0.8.0;




interface IStrategy {

    
    
    struct OutputInfo {
        uint256 outputCode;
        address[] outputTokens;
    }

    
    
    event Borrow(address[] _assets, uint256[] _amounts);

    
    
    
    
    event Repay(uint256 _withdrawShares, uint256 _totalShares, address[] _assets, uint256[] _amounts);

    
    
    event SetIsWantRatioIgnorable(bool _oldValue, bool _newValue);

    
    function getVersion() external pure returns (string memory);

    
    function name() external view returns (string memory);

    
    function protocol() external view returns (uint16);

    
    function vault() external view returns (IVault);

    
    function harvester() external view returns (address);

    
    
    
    ///     The ratio is the proportion of each asset to total assets
    function getWantsInfo() external view returns (address[] memory _assets, uint256[] memory _ratios);

    
    function getWants() external view returns (address[] memory _wants);

    
    function getOutputsInfo() external view returns (OutputInfo[] memory _outputsInfo);

    
    
    ///    "false" is the opposite.
    function setIsWantRatioIgnorable(bool _isWantRatioIgnorable) external;

    
    
    
    
    
    function getPositionDetail()
        external
        view
        returns (
            address[] memory _tokens,
            uint256[] memory _amounts,
            bool _isUsd,
            uint256 _usdValue
        );

    
    function estimatedTotalAssets() external view returns (uint256);

    
    function get3rdPoolAssets() external view returns (uint256);

    
    ///     recognizing any profits or losses and adjusting the Strategy's position.
    
    
    function harvest() external returns (address[] memory _rewardsTokens, uint256[] memory _claimAmounts);

    
    
    
    function borrow(address[] memory _assets, uint256[] memory _amounts) external;

    
    
    
    
    
    
    function repay(
        uint256 _withdrawShares,
        uint256 _totalShares,
        uint256 _outputCode
    ) external returns (address[] memory _assets, uint256[] memory _amounts);

    
    function isWantRatioIgnorable() external view returns (bool);

    
    function poolQuota() external view returns (uint256);
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

pragma solidity ^0.8.0;













abstract contract BaseStrategy is IStrategy, Initializable, AccessControlMixin {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using StableMath for uint256;

    
    IVault public override vault;

    
    IValueInterpreter public valueInterpreter;

    
    address public override harvester;
    
    uint16 public override protocol;
    
    string public override name;

    
    address[] public wants;

    
    bool public override isWantRatioIgnorable;

    
    modifier onlyVault() {
        require(msg.sender == address(vault));
        _;
    }

    function _initialize(
        address _vault,
        address _harvester,
        string memory _name,
        uint16 _protocol,
        address[] memory _wants
    ) internal {
        protocol = _protocol;
        harvester = _harvester;
        name = _name;
        vault = IVault(_vault);
        valueInterpreter = IValueInterpreter(vault.valueInterpreter());

        _initAccessControl(vault.accessControlProxy());

        require(_wants.length > 0, "wants is required");
        for (uint256 i = 0; i < _wants.length; i++) {
            require(_wants[i] != address(0), "SAI");
        }
        wants = _wants;
    }

    
    function getVersion() external pure virtual override returns (string memory);

    
    function setIsWantRatioIgnorable(bool _isWantRatioIgnorable) external override isVaultManager {
        bool _oldValue = isWantRatioIgnorable;
        isWantRatioIgnorable = _isWantRatioIgnorable;
        emit SetIsWantRatioIgnorable(_oldValue, _isWantRatioIgnorable);
    }

    
    function getWantsInfo()
        external
        view
        virtual
        override
        returns (address[] memory _assets, uint256[] memory _ratios);

    
    function getWants() external view override returns (address[] memory) {
        return wants;
    }

    
    function getOutputsInfo() external view virtual override returns (OutputInfo[] memory _outputsInfo);

    
    function getPositionDetail()
        public
        view
        virtual
        override
        returns (
            address[] memory _tokens,
            uint256[] memory _amounts,
            bool _isUsd,
            uint256 _usdValue
        );

    
    function estimatedTotalAssets() external view virtual override returns (uint256) {
        (
            address[] memory _tokens,
            uint256[] memory _amounts,
            bool _isUsd,
            uint256 _usdValue
        ) = getPositionDetail();
        if (_isUsd) {
            return _usdValue;
        } else {
            uint256 _totalUsdValue = 0;
            for (uint256 i = 0; i < _tokens.length; i++) {
                _totalUsdValue += queryTokenValue(_tokens[i], _amounts[i]);
            }
            return _totalUsdValue;
        }
    }

    
    function get3rdPoolAssets() external view virtual override returns (uint256);

    
    function harvest()
        external
        virtual
        override
        returns (address[] memory _rewardsTokens, uint256[] memory _claimAmounts)
    {
        vault.report(_rewardsTokens, _claimAmounts);
    }

    
    function borrow(address[] memory _assets, uint256[] memory _amounts) external override onlyVault {
        depositTo3rdPool(_assets, _amounts);
        emit Borrow(_assets, _amounts);
    }

    
    function repay(
        uint256 _repayShares,
        uint256 _totalShares,
        uint256 _outputCode
    ) public virtual override onlyVault returns (address[] memory _assets, uint256[] memory _amounts) {
        require(_repayShares > 0 && _totalShares >= _repayShares, "cannot repay 0 shares");
        _assets = wants;
        uint256[] memory _balancesBefore = new uint256[](_assets.length);
        for (uint256 i = 0; i < _assets.length; i++) {
            _balancesBefore[i] = balanceOfToken(_assets[i]);
        }

        withdrawFrom3rdPool(_repayShares, _totalShares, _outputCode);
        _amounts = new uint256[](_assets.length);
        for (uint256 i = 0; i < _assets.length; i++) {
            uint256 _balanceAfter = balanceOfToken(_assets[i]);
            _amounts[i] =
                _balanceAfter -
                _balancesBefore[i] +
                (_balancesBefore[i] * _repayShares) /
                _totalShares;
        }

        transferTokensToTarget(address(vault), _assets, _amounts);

        emit Repay(_repayShares, _totalShares, _assets, _amounts);
    }

    
    function poolQuota() public view virtual override returns (uint256) {
        return type(uint256).max;
    }

    
    
    
    function depositTo3rdPool(address[] memory _assets, uint256[] memory _amounts) internal virtual;

    
    
    
    
    function withdrawFrom3rdPool(
        uint256 _withdrawShares,
        uint256 _totalShares,
        uint256 _outputCode
    ) internal virtual;

    
    function balanceOfToken(address _tokenAddress) internal view returns (uint256) {
        return IERC20Upgradeable(_tokenAddress).balanceOf(address(this));
    }

    
    function queryTokenValue(address _token, uint256 _amount)
        internal
        view
        returns (uint256 _valueInUSD)
    {
        _valueInUSD = valueInterpreter.calcCanonicalAssetValueInUsd(_token, _amount);
    }

    
    function decimalUnitOfToken(address _token) internal view returns (uint256) {
        return 10**IERC20MetadataUpgradeable(_token).decimals();
    }

    
    
    
    
    function transferTokensToTarget(
        address _target,
        address[] memory _assets,
        uint256[] memory _amounts
    ) internal {
        for (uint256 i = 0; i < _assets.length; i++) {
            uint256 _amount = _amounts[i];
            if (_amount > 0) {
                IERC20Upgradeable(_assets[i]).safeTransfer(address(_target), _amount);
            }
        }
    }
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolImmutables {
    
    
    function factory() external view returns (address);

    
    
    function token0() external view returns (address);

    
    
    function token1() external view returns (address);

    
    
    function fee() external view returns (uint24);

    
    
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    
    function tickSpacing() external view returns (int24);

    
    
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    
    function maxLiquidityPerTick() external view returns (uint128);
}

// 
pragma solidity >=0.5.0;



/// per transaction
interface IUniswapV3PoolState {
    
    /// when accessed externally.
    
    /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// observationIndex The index of the last oracle observation that was written,
    /// observationCardinality The current maximum number of observations stored in the pool,
    /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    
    
    function feeGrowthGlobal0X128() external view returns (uint256);

    
    
    function feeGrowthGlobal1X128() external view returns (uint256);

    
    
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    
    
    function liquidity() external view returns (uint128);

    
    
    
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    
    
    
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    
    
    
    /// ago, rather than at a specific index in the array.
    
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}

// 
pragma solidity >=0.5.0;



/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    
    
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    
    
    
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    
    
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    
    
    
    
    
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolActions {
    
    
    
    function initialize(uint160 sqrtPriceX96) external;

    
    
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    
    
    
    
    
    
    
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    
    
    
    
    
    
    
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    
    
    
    
    
    
    
    
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    
    
    
    
    
    
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    
    
    
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    
    
    
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    
    
    
    
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    
    
    /// the input observationCardinalityNext.
    
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolOwnerActions {
    
    
    
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    
    
    
    
    
    
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolEvents {
    
    
    
    
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    
    
    
    
    
    
    
    
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    
    
    
    
    
    
    
    
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    
    
    
    
    
    
    
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    
    
    /// just before a mint/swap/burn.
    
    
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    
    
    
    
    
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    
    
    
    
    
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}
// 
pragma solidity ^0.8.0;
















contract AaveLendingStEthStrategy is BaseStrategy {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address internal constant UNISWAP_V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address internal constant CURVE_POOL_ADDRESS = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022;
    address internal constant QUOTER = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;
    address public constant DEBT_W_ETH = 0xF63B34710400CAd3e044cFfDcAb00a0f32E33eCf;
    address public constant W_ETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant ST_ETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address public constant A_ST_ETH = 0x1982b2F5814301d4e9a8b0201555376e62F82428;
    address public constant A_WETH = 0x030bA81f1c18d280636F32af80b9AAd02Cf0854e;
    uint256 public constant RESERVE_ID_OF_ST_ETH = 31;
    uint256 public constant BPS = 10000;
    address private aToken;
    uint256 private reserveIdOfToken;
    /**
     * @dev Aave Lending Pool Provider
     */
    ILendingPoolAddressesProvider internal constant aaveProvider =
        ILendingPoolAddressesProvider(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5);
    uint256 public stETHBorrowFactor;
    uint256 public stETHBorrowFactorMax;
    uint256 public stETHBorrowFactorMin;
    uint256 public borrowFactor;
    uint256 public borrowFactorMax;
    uint256 public borrowFactorMin;
    uint256 public borrowCount;
    address public uniswapV3Pool;
    uint256 public leverage;
    uint256 public leverageMax;
    uint256 public leverageMin;
    address internal constant EULER_ADDRESS = 0x27182842E098f60e3D576794A5bFFb0777E025d3;
    address internal constant W_ETH_EULER_D_TOKEN = 0x62e28f054efc24b26A794F5C1249B6349454352C;

    /// Events

    
    event UpdateStETHBorrowFactor(uint256 _stETHBorrowFactor);
    
    event UpdateStETHBorrowFactorMax(uint256 _stETHBorrowFactorMax);
    
    event UpdateStETHBorrowFactorMin(uint256 _stETHBorrowFactorMin);
    
    event UpdateBorrowFactor(uint256 _borrowFactor);
    
    event UpdateBorrowFactorMax(uint256 _borrowFactorMax);
    
    event UpdateBorrowFactorMin(uint256 _borrowFactorMin);
    
    event UpdateBorrowCount(uint256 _borrowCount);
    
    
    event Rebalance(uint256 _remainingAmount, uint256 _overflowAmount);

    receive() external payable {}

    fallback() external payable {}

    function initialize(
        address _vault,
        address _harvester,
        string memory _name,
        address _wantToken,
        address _wantAToken,
        uint256 _reserveIdOfToken,
        address _uniswapV3Pool
    ) external initializer {
        address[] memory _wants = new address[](1);
        _wants[0] = _wantToken;
        aToken = _wantAToken;
        reserveIdOfToken = _reserveIdOfToken;
        uniswapV3Pool = _uniswapV3Pool;
        stETHBorrowFactor = 6500;
        stETHBorrowFactorMax = 6900;
        stETHBorrowFactorMin = 6100;
        borrowFactor = 6500;
        borrowFactorMin = 6100;
        borrowFactorMax = 6900;
        borrowCount = 3;
        leverage = _calLeverage(6500, 6500, 10000, 3);
        leverageMax = _calLeverage(6900, 6900, 10000, 3);
        leverageMin = _calLeverage(6100, 6100, 10000, 3);

        address _lendingPoolAddress = aaveProvider.getLendingPool();
        IERC20Upgradeable(ST_ETH).safeApprove(_lendingPoolAddress, type(uint256).max);
        IERC20Upgradeable(_wantToken).safeApprove(_lendingPoolAddress, type(uint256).max);
        IERC20Upgradeable(W_ETH).safeApprove(_lendingPoolAddress, type(uint256).max);
        IERC20Upgradeable(ST_ETH).safeApprove(CURVE_POOL_ADDRESS, type(uint256).max);
        IERC20Upgradeable(_wantToken).safeApprove(UNISWAP_V3_ROUTER, type(uint256).max);
        IERC20Upgradeable(W_ETH).safeApprove(UNISWAP_V3_ROUTER, type(uint256).max);

        super._initialize(_vault, _harvester, _name, uint16(ProtocolEnum.Aave), _wants);
    }

    
    
    /// Requirements: only vault manager can call
    function setStETHBorrowFactor(uint256 _stETHBorrowFactor) external isVaultManager {
        require(_stETHBorrowFactor < BPS, "setting output the range");
        stETHBorrowFactor = _stETHBorrowFactor;
        leverage = _getNewLeverage(borrowFactor, _stETHBorrowFactor);

        emit UpdateStETHBorrowFactor(_stETHBorrowFactor);
    }

    
    
    /// Requirements: only vault manager can call
    function setStETHBorrowFactorMax(uint256 _stETHBorrowFactorMax) external isVaultManager {
        require(
            _stETHBorrowFactorMax < BPS && _stETHBorrowFactorMax > stETHBorrowFactor,
            "setting output the range"
        );
        stETHBorrowFactorMax = _stETHBorrowFactorMax;
        leverageMax = _getNewLeverage(borrowFactorMax, _stETHBorrowFactorMax);

        emit UpdateStETHBorrowFactorMax(_stETHBorrowFactorMax);
    }

    
    
    /// Requirements: only vault manager can call
    function setStETHBorrowFactorMin(uint256 _stETHBorrowFactorMin) external isVaultManager {
        require(
            _stETHBorrowFactorMin < BPS && _stETHBorrowFactorMin < stETHBorrowFactor,
            "setting output the range"
        );
        stETHBorrowFactorMin = _stETHBorrowFactorMin;
        leverageMin = _getNewLeverage(borrowFactorMin, _stETHBorrowFactorMin);

        emit UpdateStETHBorrowFactorMin(_stETHBorrowFactorMin);
    }

    
    
    /// Requirements: only vault manager can call
    function setBorrowFactor(uint256 _borrowFactor) external isVaultManager {
        require(
            _borrowFactor < BPS &&
                _borrowFactor >= borrowFactorMin &&
                _borrowFactor <= borrowFactorMax,
            "setting output the range"
        );
        borrowFactor = _borrowFactor;
        leverage = _getNewLeverage(_borrowFactor, stETHBorrowFactor);

        emit UpdateBorrowFactor(_borrowFactor);
    }

    
    
    /// Requirements: only vault manager can call
    function setBorrowFactorMax(uint256 _borrowFactorMax) external isVaultManager {
        require(
            _borrowFactorMax < BPS && _borrowFactorMax > borrowFactor,
            "setting output the range"
        );
        borrowFactorMax = _borrowFactorMax;
        leverageMax = _getNewLeverage(_borrowFactorMax, stETHBorrowFactorMax);

        emit UpdateBorrowFactorMax(_borrowFactorMax);
    }

    
    
    /// Requirements: only vault manager can call
    function setBorrowFactorMin(uint256 _borrowFactorMin) external isVaultManager {
        require(
            _borrowFactorMin < BPS && _borrowFactorMin < borrowFactor,
            "setting output the range"
        );
        borrowFactorMin = _borrowFactorMin;
        leverageMin = _getNewLeverage(_borrowFactorMin, stETHBorrowFactorMin);

        emit UpdateBorrowFactorMin(_borrowFactorMin);
    }

    
    
    /// Requirements: only vault manager can call
    function setBorrowCount(uint256 _borrowCount) external isVaultManager {
        require(_borrowCount <= 10 && _borrowCount > 0, "setting output the range");
        borrowCount = _borrowCount;
        _updateAllLeverage(_borrowCount);

        emit UpdateBorrowCount(_borrowCount);
    }

    
    function getVersion() external pure virtual override returns (string memory) {
        return "1.0.1";
    }

    
    function getWantsInfo()
        external
        view
        virtual
        override
        returns (address[] memory _assets, uint256[] memory _ratios)
    {
        _assets = wants;
        _ratios = new uint256[](1);
        _ratios[0] = 1e18;
    }

    
    function getOutputsInfo()
        external
        view
        virtual
        override
        returns (OutputInfo[] memory _outputsInfo)
    {
        _outputsInfo = new OutputInfo[](1);
        OutputInfo memory _info = _outputsInfo[0];
        _info.outputCode = 0;
        _info.outputTokens = wants;
    }

    
    function getPositionDetail()
        public
        view
        virtual
        override
        returns (
            address[] memory _tokens,
            uint256[] memory _amounts,
            bool _isUsd,
            uint256 _usdValue
        )
    {
        _tokens = wants;
        _amounts = new uint256[](1);
        address _token = _tokens[0];

        uint256 _wethDebtAmount = balanceOfToken(DEBT_W_ETH);
        uint256 _tokenAmount = balanceOfToken(_token) + balanceOfToken(aToken);
        uint256 _wethAmount = balanceOfToken(W_ETH) + address(this).balance;
        uint256 _stEthAmount = balanceOfToken(A_ST_ETH) + balanceOfToken(ST_ETH);
        _isUsd = true;
        if (_wethAmount > _wethDebtAmount) {
            _usdValue =
                queryTokenValue(_token, _tokenAmount) +
                queryTokenValue(ST_ETH, _stEthAmount) +
                queryTokenValue(W_ETH, _wethAmount - _wethDebtAmount);
        } else if (_wethAmount < _wethDebtAmount) {
            _usdValue =
                queryTokenValue(_token, _tokenAmount) +
                queryTokenValue(ST_ETH, _stEthAmount) -
                queryTokenValue(W_ETH, _wethDebtAmount - _wethAmount);
        } else {
            _usdValue =
                queryTokenValue(_token, _tokenAmount) +
                queryTokenValue(ST_ETH, _stEthAmount);
        }
    }

    
    function get3rdPoolAssets() external view override returns (uint256) {
        return queryTokenValue(ST_ETH, IERC20Upgradeable(ST_ETH).totalSupply());
    }

    
    function depositTo3rdPool(address[] memory _assets, uint256[] memory _amounts)
        internal
        override
    {
        uint256 _amount = _amounts[0];
        address _asset = _assets[0];
        address _aStETH = A_ST_ETH;
        address _stETH = ST_ETH;
        address _lendingPoolAddress = aaveProvider.getLendingPool();
        ILendingPool(_lendingPoolAddress).deposit(_asset, _amount, address(this), 0);
        {
            uint256 _userConfigurationData = ILendingPool(_lendingPoolAddress)
                .getUserConfiguration(address(this))
                .data;

            if (!UserConfiguration.isUsingAsCollateral(_userConfigurationData, reserveIdOfToken)) {
                ILendingPool(_lendingPoolAddress).setUserUseReserveAsCollateral(_asset, true);
            }
            if (
                balanceOfToken(_aStETH) > 0 &&
                !UserConfiguration.isUsingAsCollateral(
                    _userConfigurationData,
                    RESERVE_ID_OF_ST_ETH
                )
            ) {
                ILendingPool(_lendingPoolAddress).setUserUseReserveAsCollateral(_stETH, true);
            }
        }

        (uint256 _stETHPrice, uint256 _tokenPrice) = _getAssetsPrices(_stETH, _asset);

        address _curvePoolAddress = CURVE_POOL_ADDRESS;
        (uint256 _remainingAmount, uint256 _overflowAmount) = _borrowStandardInfo(
            _aStETH,
            _stETHPrice,
            _tokenPrice,
            _curvePoolAddress
        );
        _rebalance(_remainingAmount, _overflowAmount, _stETHPrice, _curvePoolAddress);
    }

    
    function withdrawFrom3rdPool(
        uint256 _withdrawShares,
        uint256 _totalShares,
        uint256 _outputCode
    ) internal override {
        uint256 _redeemAstETHAmount = (balanceOfToken(A_ST_ETH) * _withdrawShares) / _totalShares;
        uint256 _redeemATokenAmount = (balanceOfToken(aToken) * _withdrawShares) / _totalShares;
        uint256 _repayBorrowAmount = (balanceOfToken(DEBT_W_ETH) * _withdrawShares) / _totalShares;
        _repay(_redeemAstETHAmount, _redeemATokenAmount, _repayBorrowAmount);
    }

    
    
    
    function borrowInfo() public view returns (uint256 _remainingAmount, uint256 _overflowAmount) {
        address _stETH = ST_ETH;
        address _tokenAddress = wants[0];
        (uint256 _stETHPrice, uint256 _tokenPrice) = _getAssetsPrices(_stETH, _tokenAddress);
        address _curvePoolAddress = CURVE_POOL_ADDRESS;
        (_remainingAmount, _overflowAmount) = _borrowInfo(
            _stETHPrice,
            _tokenPrice,
            _curvePoolAddress
        );
    }

    
    /// Requirements: only keeper can call
    function rebalance() external isKeeper {
        address _stETH = ST_ETH;
        address _tokenAddress = wants[0];
        (uint256 _stETHPrice, uint256 _tokenPrice) = _getAssetsPrices(_stETH, _tokenAddress);
        address _curvePoolAddress = CURVE_POOL_ADDRESS;
        (uint256 _remainingAmount, uint256 _overflowAmount) = _borrowInfo(
            _stETHPrice,
            _tokenPrice,
            _curvePoolAddress
        );
        _rebalance(_remainingAmount, _overflowAmount, _stETHPrice, _curvePoolAddress);
    }

    // euler flashload call only by  euler
    function onFlashLoan(bytes memory data) external {
        address _eulerAddress = EULER_ADDRESS;
        require(msg.sender == _eulerAddress, "invalid call");
        (
            uint256 _operationCode,
            uint256[] memory _customParams,
            uint256 _flashLoanAmount,
            uint256 _origBalance
        ) = abi.decode(data, (uint256, uint256[], uint256, uint256));
        address _wETH = W_ETH;
        uint256 _wETHAmount = balanceOfToken(_wETH);
        require(_wETHAmount >= _origBalance + _flashLoanAmount, "not received enough");
        ILendingPool _aaveLendingPool = ILendingPool(aaveProvider.getLendingPool());
        // 0 - deposit stETH wantToken; 1 - withdraw stETH wantToken
        if (_operationCode < 1) {
            IWeth(_wETH).withdraw(_wETHAmount);
            ICurveLiquidityFarmingPool(CURVE_POOL_ADDRESS).exchange{value: _wETHAmount}(
                0,
                1,
                _wETHAmount,
                0
            );
            address _asset = ST_ETH;
            uint256 _amount = balanceOfToken(_asset);
            _aaveLendingPool.deposit(_asset, _amount, address(this), 0);

            //_customParams = [_borrowAmount,_depositAmount]
            uint256 _borrowAmount = _customParams[0];
            _aaveLendingPool.borrow(
                _wETH,
                _borrowAmount,
                uint256(DataTypes.InterestRateMode.VARIABLE),
                0,
                address(this)
            );
        } else {
            //_customParams = [_redeemAstETHAmount,_redeemATokenAmount,_repayBorrowAmount]
            uint256 _redeemAStETHAmount = _customParams[0];
            uint256 _redeemATokenAmount = _customParams[1];
            uint256 _repayBorrowAmount = _customParams[2];
            if (_repayBorrowAmount > 0) {
                _aaveLendingPool.repay(
                    _wETH,
                    _repayBorrowAmount,
                    uint256(DataTypes.InterestRateMode.VARIABLE),
                    address(this)
                );
            }
            if (_redeemAStETHAmount > 0) {
                address _stETH = ST_ETH;
                _aaveLendingPool.withdraw(_stETH, _redeemAStETHAmount, address(this));
                uint256 _stETHAmount = balanceOfToken(_stETH);
                ICurveLiquidityFarmingPool(CURVE_POOL_ADDRESS).exchange(1, 0, _stETHAmount, 0);
                IWeth(_wETH).deposit{value: address(this).balance}();
            }
            address _want = wants[0];
            if (_redeemATokenAmount > 0) {
                _aaveLendingPool.withdraw(_want, _redeemATokenAmount, address(this));
            }

            uint256 _wETHAmount = balanceOfToken(_wETH);
            if (_wETHAmount > _flashLoanAmount) {
                IUniswapV3(UNISWAP_V3_ROUTER).exactInputSingle(
                    IUniswapV3.ExactInputSingleParams(
                        _wETH,
                        _want,
                        500,
                        address(this),
                        block.timestamp,
                        _wETHAmount - _flashLoanAmount,
                        0,
                        0
                    )
                );
            } else if (_wETHAmount < _flashLoanAmount) {
                IUniswapV3(UNISWAP_V3_ROUTER).exactOutputSingle(
                    IUniswapV3.ExactOutputSingleParams(
                        _want,
                        _wETH,
                        500,
                        address(this),
                        block.timestamp,
                        _flashLoanAmount - _wETHAmount,
                        balanceOfToken(_want),
                        0
                    )
                );
            }
        }
        IERC20Upgradeable(_wETH).safeTransfer(_eulerAddress, _flashLoanAmount);
    }

    function _getAssetsPrices(address _asset1, address _asset2)
        private
        view
        returns (uint256 _price1, uint256 _price2)
    {
        address[] memory _assets = new address[](2);
        _assets[0] = _asset1;
        _assets[1] = _asset2;
        IPriceOracleGetter _aaveOracle = IPriceOracleGetter(aaveProvider.getPriceOracle());
        uint256[] memory _prices = _aaveOracle.getAssetsPrices(_assets);
        _price1 = _prices[0];
        _price2 = _prices[1];
    }

    
    function _repay(
        uint256 _redeemAstETHAmount,
        uint256 _redeemATokenAmount,
        uint256 _repayBorrowAmount
    ) internal {
        // 0 - deposit stETH wantToken; 1 - withdraw stETH wantToken
        uint256 _operationCode = 1;
        uint256[] memory _customParams = new uint256[](3);
        //_redeemAstETHAmount
        _customParams[0] = _redeemAstETHAmount;
        //_redeemATokenAmount
        _customParams[1] = _redeemATokenAmount;
        //_repayBorrowAmount
        _customParams[2] = _repayBorrowAmount;
        uint256 _flashLoanAmount = _repayBorrowAmount;
        bytes memory _params = abi.encode(
            _operationCode,
            _customParams,
            _flashLoanAmount,
            balanceOfToken(W_ETH)
        );
        IEulerDToken(W_ETH_EULER_D_TOKEN).flashLoan(_flashLoanAmount, _params);
    }

    
    function _rebalance(
        uint256 _remainingAmount,
        uint256 _overflowAmount,
        uint256 _stETHPrice,
        address _curvePoolAddress
    ) internal {
        ICurveLiquidityFarmingPool _curvePool = ICurveLiquidityFarmingPool(_curvePoolAddress);
        if (_remainingAmount > 0) {
            // 0 - deposit stETH wantToken; 1 - withdraw stETH wantToken
            uint256 _operationCode = 0;
            uint256[] memory _customParams = new uint256[](2);
            //uint256 _borrowAmount = _remainingAmount;
            _customParams[0] = _remainingAmount;
            //uint256 _depositAmount = type(uint256).max;
            _customParams[1] = type(uint256).max;
            uint256 _flashLoanAmount = _remainingAmount;
            bytes memory _params = abi.encode(
                _operationCode,
                _customParams,
                _flashLoanAmount,
                balanceOfToken(W_ETH)
            );
            IEulerDToken(W_ETH_EULER_D_TOKEN).flashLoan(_flashLoanAmount, _params);
        } else if (_overflowAmount > 0) {
            uint256 _repayBorrowAmount = _curvePool.get_dy(1, 0, _overflowAmount);
            uint256 _redeemAStETHAmount = _overflowAmount;
            uint256 _redeemATokenAmount = 0;
            //stETH
            uint256 _aStETHAmount = balanceOfToken(A_ST_ETH);
            if (_aStETHAmount < _redeemAStETHAmount) {
                _redeemAStETHAmount = _aStETHAmount;
            } else if (_aStETHAmount > _redeemAStETHAmount) {
                if (_aStETHAmount > _redeemAStETHAmount + 1) {
                    _redeemAStETHAmount = _redeemAStETHAmount + 2;
                } else {
                    _redeemAStETHAmount = _redeemAStETHAmount + 1;
                }
            }
            _repay(_redeemAStETHAmount, _redeemATokenAmount, _repayBorrowAmount);
        }
        if (_remainingAmount + _overflowAmount > 0) {
            emit Rebalance(_remainingAmount, _overflowAmount);
        }
    }

    
    
    /// _debtAmount_now / _needCollateralAmount = （_leverage - 10000) / _leverage;
    /// _leverage = (capitalAmount + _debtAmount_now) *10000 / capitalAmount;
    /// _debtAmount_now = capitalAmount * (_leverage - 10000)
    
    
    function _borrowInfo(
        uint256 _stETHPrice,
        uint256 _tokenPrice,
        address _curvePoolAddress
    ) private view returns (uint256 _remainingAmount, uint256 _overflowAmount) {
        uint256 _bps = BPS;
        uint256 _leverage = leverage;
        uint256 _debtAmountMax;
        uint256 _debtAmountMin;
        uint256 _debtAmount = balanceOfToken(DEBT_W_ETH);
        address _aToken = aToken;
        uint256 _collateralAmountInETH = (balanceOfToken(A_ST_ETH) * _stETHPrice) /
            1e18 +
            (balanceOfToken(_aToken) * _tokenPrice) /
            decimalUnitOfToken(_aToken);

        {
            uint256 _leverageMax = leverageMax;
            uint256 _leverageMin = leverageMin;
            uint256 _capitalAmountInETH = (_collateralAmountInETH - _debtAmount);
            _debtAmountMax = (_capitalAmountInETH * (_leverageMax - _bps)) / _bps;
            _debtAmountMin = (_capitalAmountInETH * (_leverageMin - _bps)) / _bps;
        }

        if (_debtAmount > _debtAmountMax) {
            //(_debtAmount-x*_exchangeRate)/(_collateralAmountInETH- x * _stETHPrice) = (leverage-BPS)/leverage
            // stETH to ETH
            uint256 _exchangeRate = ICurveLiquidityFarmingPool(_curvePoolAddress).get_dy(
                1,
                0,
                1e18
            );
            _overflowAmount =
                (_debtAmount * _leverage - _collateralAmountInETH * (_leverage - _bps)) /
                ((_leverage * _exchangeRate) / 1e18 - ((_leverage - _bps) * _stETHPrice) / 1e18);
        } else if (_debtAmount < _debtAmountMin) {
            //(_debtAmount+x)/(_collateralAmountInETH+_exchangeRate * x) = (leverage-BPS)/leverage
            // ETH to stETH
            uint256 _exchangeRate = ICurveLiquidityFarmingPool(_curvePoolAddress).get_dy(
                0,
                1,
                1e18
            );
            _remainingAmount =
                (_collateralAmountInETH * (_leverage - _bps) - _debtAmount * _leverage) /
                (_leverage - ((_leverage - _bps) * _exchangeRate) / 1e18);
        }
    }

    
    
    
    function _borrowStandardInfo(
        address _aStETH,
        uint256 _stETHPrice,
        uint256 _tokenPrice,
        address _curvePoolAddress
    ) private view returns (uint256 _remainingAmount, uint256 _overflowAmount) {
        uint256 _leverage = leverage;
        uint256 _bps = BPS;

        uint256 _newDebtAmount = balanceOfToken(DEBT_W_ETH) * _leverage;
        uint256 _newCollateralAmount;
        {
            address _aToken = aToken;
            _newCollateralAmount =
                ((balanceOfToken(_aStETH) * _stETHPrice) /
                    1e18 +
                    (balanceOfToken(_aToken) * _tokenPrice) /
                    decimalUnitOfToken(_aToken)) *
                (_leverage - _bps);
        }

        address _curvePoolAddress = CURVE_POOL_ADDRESS;
        if (_newDebtAmount > _newCollateralAmount) {
            //(_debtAmount-x*_exchangeRate)/(_collateralAmountInETH- x * _stETHPrice) = (leverage-BPS)/leverage
            // stETH to ETH
            uint256 _exchangeRate = ICurveLiquidityFarmingPool(_curvePoolAddress).get_dy(
                1,
                0,
                1e18
            );
            _overflowAmount =
                (_newDebtAmount - _newCollateralAmount) /
                ((_leverage * _exchangeRate) / 1e18 - ((_leverage - _bps) * _stETHPrice) / 1e18);
        } else if (_newDebtAmount < _newCollateralAmount) {
            //(_debtAmount+x)/(_collateralAmountInETH+_exchangeRate * x) = (leverage-BPS)/leverage
            // ETH to stETH
            uint256 _exchangeRate = ICurveLiquidityFarmingPool(_curvePoolAddress).get_dy(
                0,
                1,
                1e18
            );
            _remainingAmount =
                (_newCollateralAmount - _newDebtAmount) /
                (_leverage - ((_leverage - _bps) * _exchangeRate) / 1e18);
        }
    }

    
    
    function _getNewLeverage(uint256 _borrowFactor, uint256 _stETHBorrowFactor)
        internal
        view
        returns (uint256)
    {
        return _calLeverage(_borrowFactor, _stETHBorrowFactor, BPS, borrowCount);
    }

    
    function _updateAllLeverage(uint256 _borrowCount) internal {
        uint256 _bps = BPS;
        leverage = _calLeverage(borrowFactor, stETHBorrowFactor, _bps, _borrowCount);
        leverageMax = _calLeverage(borrowFactorMax, stETHBorrowFactorMax, _bps, _borrowCount);
        leverageMin = _calLeverage(borrowFactorMin, stETHBorrowFactorMin, _bps, _borrowCount);
    }

    
    
    function _calLeverage(
        uint256 _borrowFactor,
        uint256 _stETHBorrowFactor,
        uint256 _bps,
        uint256 _borrowCount
    ) private pure returns (uint256) {
        // q = borrowFactor/bps
        // n = borrowCount + 1;
        // _leverage = (1-q^n)/(1-q),(n>=1, q=0.8)
        uint256 _leverage = _bps + _borrowFactor;
        if (_borrowCount >= 1) {
            _leverage =
                (_bps *
                    _bps -
                    (_stETHBorrowFactor**(_borrowCount + 1)) /
                    (_bps**(_borrowCount - 1))) /
                (_bps - _stETHBorrowFactor);
            _leverage = _bps + (_borrowFactor * _leverage) / _bps;
        }
        return _leverage;
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// 
pragma solidity >=0.5.0;










/// to the ERC20 specification

interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}

// 
pragma solidity >=0.6.0 <0.9.0;

enum ProtocolEnum {
    Balancer,
    UniswapV2,
    Dodo,
    Sushi_Kashi,
    Sushi_Swap,
    Convex,
    Rari,
    UniswapV3,
    YearnEarn,
    YearnV2,
    YearnIronBank,
    GUni,
    Stargate,
    DForce,
    Synapse,
    Aura,
    Aave,
    Euler
}

// 

pragma solidity ^0.8.0;





interface ILendingPool {


  /**
   * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying aTokens.
   * - E.g. User deposits 100 USDC and gets in return 100 aUSDC
   * @param asset The address of the underlying asset to deposit
   * @param amount The amount to be deposited
   * @param onBehalfOf The address that will receive the aTokens, same as msg.sender if the user
   *   wants to receive them on his own wallet, or a different address if the beneficiary of aTokens
   *   is a different wallet
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the action is executed directly by the user, without any middle-man
   **/
  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;

  /**
   * @dev Withdraws an `amount` of underlying asset from the reserve, burning the equivalent aTokens owned
   * E.g. User has 100 aUSDC, calls withdraw() and receives 100 USDC, burning the 100 aUSDC
   * @param asset The address of the underlying asset to withdraw
   * @param amount The underlying amount to be withdrawn
   *   - Send the value type(uint256).max in order to withdraw the whole aToken balance
   * @param to Address that will receive the underlying, same as msg.sender if the user
   *   wants to receive it on his own wallet, or a different address if the beneficiary is a
   *   different wallet
   * @return The final amount withdrawn
   **/
  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256);

  /**
   * @dev Allows users to borrow a specific `amount` of the reserve underlying asset, provided that the borrower
   * already deposited enough collateral, or he was given enough allowance by a credit delegator on the
   * corresponding debt token (StableDebtToken or VariableDebtToken)
   * - E.g. User borrows 100 USDC passing as `onBehalfOf` his own address, receiving the 100 USDC in his wallet
   *   and 100 stable/variable debt tokens, depending on the `interestRateMode`
   * @param asset The address of the underlying asset to borrow
   * @param amount The amount to be borrowed
   * @param interestRateMode The interest rate mode at which the user wants to borrow: 1 for Stable, 2 for Variable
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the action is executed directly by the user, without any middle-man
   * @param onBehalfOf Address of the user who will receive the debt. Should be the address of the borrower itself
   * calling the function if he wants to borrow against his own collateral, or the address of the credit delegator
   * if he has been given credit delegation allowance
   **/
  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referralCode,
    address onBehalfOf
  ) external;

  /**
   * @notice Repays a borrowed `amount` on a specific reserve, burning the equivalent debt tokens owned
   * - E.g. User repays 100 USDC, burning 100 variable/stable debt tokens of the `onBehalfOf` address
   * @param asset The address of the borrowed underlying asset previously borrowed
   * @param amount The amount to repay
   * - Send the value type(uint256).max in order to repay the whole debt for `asset` on the specific `debtMode`
   * @param rateMode The interest rate mode at of the debt the user wants to repay: 1 for Stable, 2 for Variable
   * @param onBehalfOf Address of the user who will get his debt reduced/removed. Should be the address of the
   * user calling the function if he wants to reduce/remove his own debt, or the address of any other
   * other borrower whose debt should be removed
   * @return The final amount repaid
   **/
  function repay(
    address asset,
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external returns (uint256);

  /**
   * @dev Allows a borrower to swap his debt between stable and variable mode, or viceversa
   * @param asset The address of the underlying asset borrowed
   * @param rateMode The rate mode that the user wants to swap to
   **/
  function swapBorrowRateMode(address asset, uint256 rateMode) external;

  /**
   * @dev Rebalances the stable interest rate of a user to the current stable rate defined on the reserve.
   * - Users can be rebalanced if the following conditions are satisfied:
   *     1. Usage ratio is above 95%
   *     2. the current deposit APY is below REBALANCE_UP_THRESHOLD * maxVariableBorrowRate, which means that too much has been
   *        borrowed at a stable rate and depositors are not earning enough
   * @param asset The address of the underlying asset borrowed
   * @param user The address of the user to be rebalanced
   **/
  function rebalanceStableBorrowRate(address asset, address user) external;

  /**
   * @dev Allows depositors to enable/disable a specific deposited asset as collateral
   * @param asset The address of the underlying asset deposited
   * @param useAsCollateral `true` if the user wants to use the deposit as collateral, `false` otherwise
   **/
  function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;

  /**
   * @dev Function to liquidate a non-healthy position collateral-wise, with Health Factor below 1
   * - The caller (liquidator) covers `debtToCover` amount of debt of the user getting liquidated, and receives
   *   a proportionally amount of the `collateralAsset` plus a bonus to cover market risk
   * @param collateralAsset The address of the underlying asset used as collateral, to receive as result of the liquidation
   * @param debtAsset The address of the underlying borrowed asset to be repaid with the liquidation
   * @param user The address of the borrower getting liquidated
   * @param debtToCover The debt amount of borrowed `asset` the liquidator wants to cover
   * @param receiveAToken `true` if the liquidators wants to receive the collateral aTokens, `false` if he wants
   * to receive the underlying collateral asset directly
   **/
  function liquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256 debtToCover,
    bool receiveAToken
  ) external;

  /**
   * @dev Allows smartcontracts to access the liquidity of the pool within one transaction,
   * as long as the amount taken plus a fee is returned.
   * IMPORTANT There are security concerns for developers of flashloan receiver contracts that must be kept into consideration.
   * For further details please visit https://developers.aave.com
   * @param receiverAddress The address of the contract receiving the funds, implementing the IFlashLoanReceiver interface
   * @param assets The addresses of the assets being flash-borrowed
   * @param amounts The amounts amounts being flash-borrowed
   * @param modes Types of the debt to open if the flash loan is not returned:
   *   0 -> Don't open any debt, just revert if funds can't be transferred from the receiver
   *   1 -> Open debt at stable rate for the value of the amount flash-borrowed to the `onBehalfOf` address
   *   2 -> Open debt at variable rate for the value of the amount flash-borrowed to the `onBehalfOf` address
   * @param onBehalfOf The address  that will receive the debt in the case of using on `modes` 1 or 2
   * @param params Variadic packed params to pass to the receiver as extra information
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the action is executed directly by the user, without any middle-man
   **/
  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referralCode
  ) external;

  /**
   * @dev Returns the user account data across all the reserves
   * @param user The address of the user
   * @return totalCollateralETH the total collateral in ETH of the user
   * @return totalDebtETH the total debt in ETH of the user
   * @return availableBorrowsETH the borrowing power left of the user
   * @return currentLiquidationThreshold the liquidation threshold of the user
   * @return ltv the loan to value of the user
   * @return healthFactor the current health factor of the user
   **/
  function getUserAccountData(address user)
    external
    view
    returns (
      uint256 totalCollateralETH,
      uint256 totalDebtETH,
      uint256 availableBorrowsETH,
      uint256 currentLiquidationThreshold,
      uint256 ltv,
      uint256 healthFactor
    );

  function initReserve(
    address reserve,
    address aTokenAddress,
    address stableDebtAddress,
    address variableDebtAddress,
    address interestRateStrategyAddress
  ) external;

  function setReserveInterestRateStrategyAddress(address reserve, address rateStrategyAddress)
    external;

  function setConfiguration(address reserve, uint256 configuration) external;

  /**
   * @dev Returns the configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The configuration of the reserve
   **/
  function getConfiguration(address asset)
    external
    view
    returns (DataTypes.ReserveConfigurationMap memory);

  /**
   * @dev Returns the configuration of the user across all the reserves
   * @param user The user address
   * @return The configuration of the user
   **/
  function getUserConfiguration(address user)
    external
    view
    returns (DataTypes.UserConfigurationMap memory);

  /**
   * @dev Returns the normalized income normalized income of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The reserve's normalized income
   */
  function getReserveNormalizedIncome(address asset) external view returns (uint256);

  /**
   * @dev Returns the normalized variable debt per unit of asset
   * @param asset The address of the underlying asset of the reserve
   * @return The reserve normalized variable debt
   */
  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);

  /**
   * @dev Returns the state and configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The state of the reserve
   **/
  function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);

  function finalizeTransfer(
    address asset,
    address from,
    address to,
    uint256 amount,
    uint256 balanceFromAfter,
    uint256 balanceToBefore
  ) external;

  function getReservesList() external view returns (address[] memory);

  function getAddressesProvider() external view returns (ILendingPoolAddressesProvider);

  function setPause(bool val) external;

  function paused() external view returns (bool);
}

// 

pragma solidity ^0.8.0;

/**
 * @title UserConfiguration library
 * @author Aave
 * @notice Implements the bitmap logic to handle the user configuration
 */
library UserConfiguration {
    uint256 internal constant BORROWING_MASK =
    0x5555555555555555555555555555555555555555555555555555555555555555;

    /**
     * @dev Used to validate if a user has been using the reserve for borrowing or as collateral
   * @param _dataLocal The configuration object data
   * @param reserveIndex The index of the reserve in the bitmap
   * @return True if the user has been using a reserve for borrowing or as collateral, false otherwise
   **/
    function isUsingAsCollateralOrBorrowing(uint256 _dataLocal, uint256 reserveIndex)
    internal
    pure
    returns (bool)
    {
        require(reserveIndex < 128, "UL_INVALID_INDEX");
        return (_dataLocal >> (reserveIndex * 2)) & 3 != 0;
    }

    /**
     * @dev Used to validate if a user has been using the reserve for borrowing
   * @param _dataLocal The configuration object data
   * @param reserveIndex The index of the reserve in the bitmap
   * @return True if the user has been using a reserve for borrowing, false otherwise
   **/
    function isBorrowing(uint256 _dataLocal, uint256 reserveIndex)
    internal
    pure
    returns (bool)
    {
        require(reserveIndex < 128, "UL_INVALID_INDEX");
        return (_dataLocal >> (reserveIndex * 2)) & 1 != 0;
    }

    /**
     * @dev Used to validate if a user has been using the reserve as collateral
   * @param _dataLocal The configuration object data
   * @param reserveIndex The index of the reserve in the bitmap
   * @return True if the user has been using a reserve as collateral, false otherwise
   **/
    function isUsingAsCollateral(uint256 _dataLocal, uint256 reserveIndex)
    internal
    pure
    returns (bool)
    {
        require(reserveIndex < 128, "UL_INVALID_INDEX");
        return (_dataLocal >> (reserveIndex * 2 + 1)) & 1 != 0;
    }

    /**
     * @dev Used to validate if a user has been borrowing from any reserve
   * @param _dataLocal The configuration object data
   * @return True if the user has been borrowing any reserve, false otherwise
   **/
    function isBorrowingAny(uint256 _dataLocal) internal pure returns (bool) {
        return _dataLocal & BORROWING_MASK != 0;
    }

    /**
     * @dev Used to validate if a user has not been using any reserve
   * @param _dataLocal The configuration object data
   * @return True if the user has been borrowing any reserve, false otherwise
   **/
    function isEmpty(uint256 _dataLocal) internal pure returns (bool) {
        return _dataLocal == 0;
    }
}

// 

pragma solidity ^0.8.0;

library DataTypes {
    // refer to the whitepaper, section 1.1 basic concepts for a formal description of these properties.
    struct ReserveData {
        //stores the reserve configuration
        ReserveConfigurationMap configuration;
        //the liquidity index. Expressed in ray
        uint128 liquidityIndex;
        //variable borrow index. Expressed in ray
        uint128 variableBorrowIndex;
        //the current supply rate. Expressed in ray
        uint128 currentLiquidityRate;
        //the current variable borrow rate. Expressed in ray
        uint128 currentVariableBorrowRate;
        //the current stable borrow rate. Expressed in ray
        uint128 currentStableBorrowRate;
        uint40 lastUpdateTimestamp;
        //tokens addresses
        address aTokenAddress;
        address stableDebtTokenAddress;
        address variableDebtTokenAddress;
        //address of the interest rate strategy
        address interestRateStrategyAddress;
        //the id of the reserve. Represents the position in the list of the active reserves
        uint8 id;
    }

    struct ReserveConfigurationMap {
        //bit 0-15: LTV
        //bit 16-31: Liq. threshold
        //bit 32-47: Liq. bonus
        //bit 48-55: Decimals
        //bit 56: Reserve is active
        //bit 57: reserve is frozen
        //bit 58: borrowing is enabled
        //bit 59: stable rate borrowing enabled
        //bit 60-63: reserved
        //bit 64-79: reserve factor
        uint256 data;
    }

    struct UserConfigurationMap {
        uint256 data;
    }

    enum InterestRateMode {
        NONE,
        STABLE,
        VARIABLE
    }
}

// 

pragma solidity ^0.8.0;

/**
 * @title LendingPoolAddressesProvider contract
 * @dev Main registry of addresses part of or connected to the protocol, including permissioned roles
 * - Acting also as factory of proxies and admin of those, so with right to change its implementations
 **/
interface ILendingPoolAddressesProvider {
    event MarketIdSet(string newMarketId);
    event LendingPoolUpdated(address indexed newAddress);
    event ConfigurationAdminUpdated(address indexed newAddress);
    event EmergencyAdminUpdated(address indexed newAddress);
    event LendingPoolConfiguratorUpdated(address indexed newAddress);
    event LendingPoolCollateralManagerUpdated(address indexed newAddress);
    event PriceOracleUpdated(address indexed newAddress);
    event LendingRateOracleUpdated(address indexed newAddress);
    event ProxyCreated(bytes32 id, address indexed newAddress);
    event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

    function getMarketId() external view returns (string memory);

    function setMarketId(string calldata marketId) external;

    function setAddress(bytes32 id, address newAddress) external;

    function setAddressAsProxy(bytes32 id, address impl) external;

    function getAddress(bytes32 id) external view returns (address);

    function getLendingPool() external view returns (address);

    function setLendingPoolImpl(address pool) external;

    function getLendingPoolConfigurator() external view returns (address);

    function setLendingPoolConfiguratorImpl(address configurator) external;

    function getLendingPoolCollateralManager() external view returns (address);

    function setLendingPoolCollateralManager(address manager) external;

    function getPoolAdmin() external view returns (address);

    function setPoolAdmin(address admin) external;

    function getEmergencyAdmin() external view returns (address);

    function setEmergencyAdmin(address admin) external;

    function getPriceOracle() external view returns (address);

    function setPriceOracle(address priceOracle) external;

    function getLendingRateOracle() external view returns (address);

    function setLendingRateOracle(address lendingRateOracle) external;
}

// 

pragma solidity ^0.8.0;

interface IPriceOracleGetter {
  
  
  function getAssetPrice(address asset) external view returns (uint256);
  
  
  function getAssetsPrices(address[] calldata assets) external view returns (uint256[] memory);
}

pragma solidity >=0.8.0 <0.9.0;

interface ICurveLiquidityFarmingPool {

    function exchange(
        int128 from,
        int128 to,
        uint256 _from_amount,
        uint256 _min_to_amount
    ) external payable returns (uint256);

    function balances(uint256) external view returns (uint256);

    function fee() external view returns (uint256);

    function get_dy(
        int128 from,
        int128 to,
        uint256 _from_amount
    ) external view returns (uint256);

}

// 
pragma solidity ^0.8.0;

interface IEulerDToken {

    
    function underlyingAsset() external view returns (address);

    
    function totalSupply() external view returns (uint);

    
    function totalSupplyExact() external view returns (uint);

    
    function balanceOf(address account) external view returns (uint);

    
    function balanceOfExact(address account) external view returns (uint);

    
    
    
    function borrow(uint subAccountId, uint amount) external;

    
    
    
    function repay(uint subAccountId, uint amount) external;

    
    
    
    function flashLoan(uint amount, bytes calldata data) external;

    
    
    
    
    function approveDebt(uint subAccountId, address spender, uint amount) external returns (bool) ;

    
    
    
    function debtAllowance(address holder, address spender) external view returns (uint);
}

pragma solidity >=0.8.0 <0.9.0;

interface IWeth {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

// 
pragma solidity >=0.8.0 <0.9.0;

interface IUniswapV3 {
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// 

pragma solidity >=0.6.0 <0.9.0;

library BocRoles {
    bytes32 internal constant GOV_ROLE = 0x00;

    bytes32 internal constant DELEGATE_ROLE = keccak256("DELEGATE_ROLE");

    bytes32 internal constant VAULT_ROLE = keccak256("VAULT_ROLE");

    bytes32 internal constant KEEPER_ROLE = keccak256("KEEPER_ROLE");
}

// 

pragma solidity ^0.8.0;



// Based on StableMath from Stability Labs Pty. Ltd.
// https://github.com/mstable/mStable-contracts/blob/master/contracts/shared/StableMath.sol

library StableMath {

    /**
     * @dev Scaling unit for use in specific calculations,
     * where 1 * 10**18, or 1e18 represents a unit '1'
     */
    uint256 private constant FULL_SCALE = 1e18;

    /***************************************
                    Helpers
    ****************************************/

    /**
     * @dev Adjust the scale of an integer
     * @param to Decimals to scale to
     * @param from Decimals to scale from
     */
    function scaleBy(
        uint256 x,
        uint256 to,
        uint256 from
    ) internal pure returns (uint256) {
        if (to > from) {
            x = x * (10 ** (to - from));
        } else if (to < from) {
            x = x / (10 ** (from - to));
        }
        return x;
    }

    /***************************************
               Precise Arithmetic
    ****************************************/

    /**
     * @dev Multiplies two precise units, and then truncates by the full scale
     * @param x Left hand input to multiplication
     * @param y Right hand input to multiplication
     * @return Result after multiplying the two inputs and then dividing by the shared
     *         scale unit
     */
    function mulTruncate(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulTruncateScale(x, y, FULL_SCALE);
    }

    /**
     * @dev Multiplies two precise units, and then truncates by the given scale. For example,
     * when calculating 90% of 10e18, (10e18 * 9e17) / 1e18 = (9e36) / 1e18 = 9e18
     * @param x Left hand input to multiplication
     * @param y Right hand input to multiplication
     * @param scale Scale unit
     * @return Result after multiplying the two inputs and then dividing by the shared
     *         scale unit
     */
    function mulTruncateScale(
        uint256 x,
        uint256 y,
        uint256 scale
    ) internal pure returns (uint256) {
        // e.g. assume scale = fullScale
        // z = 10e18 * 9e17 = 9e36
        uint256 z = x * y;
        // return 9e36 / 1e18 = 9e18
        return z / scale;
    }

    /**
     * @dev Multiplies two precise units, and then truncates by the full scale, rounding up the result
     * @param x Left hand input to multiplication
     * @param y Right hand input to multiplication
     * @return Result after multiplying the two inputs and then dividing by the shared
     *          scale unit, rounded up to the closest base unit.
     */
    function mulTruncateCeil(uint256 x, uint256 y)
    internal
    pure
    returns (uint256)
    {
        // e.g. 8e17 * 17268172638 = 138145381104e17
        uint256 scaled = x * y;
        // e.g. 138145381104e17 + 9.99...e17 = 138145381113.99...e17
        uint256 ceil = scaled + (FULL_SCALE - 1);
        // e.g. 13814538111.399...e18 / 1e18 = 13814538111
        return ceil / FULL_SCALE;
    }

    /**
     * @dev Precisely divides two units, by first scaling the left hand operand. Useful
     *      for finding percentage weightings, i.e. 8e18/10e18 = 80% (or 8e17)
     * @param x Left hand input to division
     * @param y Right hand input to division
     * @return Result after multiplying the left operand by the scale, and
     *         executing the division on the right hand input.
     */
    function divPrecisely(uint256 x, uint256 y)
    internal
    pure
    returns (uint256)
    {
        // e.g. 8e18 * 1e18 = 8e36
        uint256 z = x * FULL_SCALE;
        // e.g. 8e36 / 10e18 = 8e17
        return z / y;
    }

    /**
     * @dev Precisely divides two units, by first scaling the left hand operand. Useful
     *      for finding percentage weightings, i.e. 8e18/10e18 = 80% (or 8e17)
     * @param x Left hand input to division
     * @param y Right hand input to division
     * @return Result after multiplying the left operand by the scale, and
     *         executing the division on the right hand input.
     */
    function divPreciselyScale(uint256 x, uint256 y, uint256 scale)
    internal
    pure
    returns (uint256)
    {
        // e.g. 8e18 * 1e18 = 8e36
        uint256 z = x * scale;
        // e.g. 8e36 / 10e18 = 8e17
        return z / y;
    }
}

// 

pragma solidity ^0.8.0;


interface IValueInterpreter {

    
    
    
    
    
    
    function calcCanonicalAssetValue(
        address _baseAsset,
        uint256 _amount,
        address _quoteAsset
    ) external view returns (uint256);

    
    
    
    
    
    
    /// Does not handle a derivative quote asset.
    function calcCanonicalAssetsTotalValue(
        address[] calldata _baseAssets,
        uint256[] calldata _amounts,
        address _quoteAsset
    ) external view returns (uint256);

    
    
    
    
    
    function calcCanonicalAssetValueInUsd(
        address _baseAsset,
        uint256 _amount
    ) external view returns (uint256);

     
    
    
    
    function price(address _baseAsset) external view returns (uint256);
}

// 

pragma solidity >=0.6.0 <0.9.0;


interface IAccessControlProxy {
    function isGovOrDelegate(address _account) external view returns (bool);

    function isVaultOrGov(address _account) external view returns (bool);

    function isKeeperOrVaultOrGov(address _account) external view returns (bool);

    function hasRole(bytes32 _role, address _account) external view returns (bool);

    function checkRole(bytes32 _role, address _account) external view;

    function checkGovOrDelegate(address _account) external view;

    function checkVaultOrGov(address _account) external view;

    function checkKeeperOrVaultOrGov(address _account) external;
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// 

pragma solidity ^0.8.0;





interface IVault {
    
    
    
    
    
    struct StrategyParams {
        uint256 lastReport;
        uint256 totalDebt;
        uint256 profitLimitRatio;
        uint256 lossLimitRatio;
        bool enforceChangeLimit;
    }

    
    
    
    struct StrategyAdd {
        address strategy;
        uint256 profitLimitRatio;
        uint256 lossLimitRatio;
    }

    
    event AddAsset(address _asset);

    
    event RemoveAsset(address _asset);

    
    event AddStrategies(address[] _strategies);

    
    event RemoveStrategies(address[] _strategies);

    
    event RemoveStrategyByForce(address _strategy);

    
    
    
    
    event Mint(address _account, address[] _assets, uint256[] _amounts, uint256 _mintAmount);

    
    
    
    
    
    
    event Burn(
        address _account,
        uint256 _amount,
        uint256 _actualAmount,
        uint256 _shareAmount,
        address[] _assets,
        uint256[] _amounts
    );

    
    
    
    
    
    event Exchange(
        address _platform,
        address _srcAsset,
        uint256 _srcAmount,
        address _distAsset,
        uint256 _distAmount
    );

    
    
    
    
    event Redeem(
        address _strategy, 
        uint256 _debtChangeAmount, 
        address[] _assets, 
        uint256[] _amounts
    );

    
    
    
    
    event LendToStrategy(
        address indexed _strategy,
        address[] _wants,
        uint256[] _amounts,
        uint256 _lendValue
    );

    
    
    
    
    
    event RepayFromStrategy(
        address indexed _strategy,
        uint256 _strategyWithdrawValue,
        uint256 _strategyTotalValue,
        address[] _assets,
        uint256[] _amounts
    );

    
    event RemoveStrategyFromQueue(address[] _strategies);

    
    event SetEmergencyShutdown(bool _shutdown);

    event RebasePaused();
    event RebaseUnpaused();

    
    event RebaseThresholdUpdated(uint256 _threshold);

    
    event TrusteeFeeBpsChanged(uint256 _basis);

    
    event MaxTimestampBetweenTwoReportedChanged(uint256 _maxTimestampBetweenTwoReported);

    
    event MinCheckedStrategyTotalDebtChanged(uint256 _minCheckedStrategyTotalDebt);

    
    event MinimumInvestmentAmountChanged(uint256 _minimumInvestmentAmount);

    
    event TreasuryAddressChanged(address _address);

    
    event ExchangeManagerAddressChanged(address _address);

    
    event SetAdjustPositionPeriod(bool _adjustPositionPeriod);

    
    event RedeemFeeUpdated(uint256 _redeemFeeBps);

    
    event SetWithdrawalQueue(address[] _queues);

    
    
    
    event Rebase(uint256 _totalShares, uint256 _totalValue, uint256 _newUnderlyingUnitsPerShare);

    
    
    
    
    
    
    
    
    event StrategyReported(
        address indexed _strategy,
        uint256 _gain,
        uint256 _loss,
        uint256 _lastStrategyTotalDebt,
        uint256 _nowStrategyTotalDebt,
        address[] _rewardTokens,
        uint256[] _claimAmounts,
        uint256 _type
    );

    
    
    
    
    event StartAdjustPosition(
        uint256 _totalDebtOfBeforeAdjustPosition,
        address[] _trackedAssets,
        uint256[] _vaultCashDetatil,
        uint256[] _vaultBufferCashDetail
    );

    
    
    
    
    
    event EndAdjustPosition(
        uint256 _transferValue,
        uint256 _redeemValue,
        uint256 _totalDebt,
        uint256 _totalValueOfAfterAdjustPosition,
        uint256 _totalValueOfBeforeAdjustPosition
    );

    
    
    
    event PegTokenSwapCash(uint256 _pegTokenAmount, address[] _assets, uint256[] _amounts);

    
    function getVersion() external pure returns (string memory);

    
    function getSupportAssets() external view returns (address[] memory _assets);

    
    function checkIsSupportAsset(address _asset) external view;

    
    function getTrackedAssets() external view returns (address[] memory _assets);

    
    function valueOfTrackedTokens() external view returns (uint256 _totalValue);

    
    function valueOfTrackedTokensIncludeVaultBuffer() external view returns (uint256 _totalValue);

    
    function totalAssets() external view returns (uint256);

    
    function totalAssetsIncludeVaultBuffer() external view returns (uint256);

    
    function totalValue() external view returns (uint256);

    
    function startAdjustPosition() external;

    
    function endAdjustPosition() external;

    
    function underlyingUnitsPerShare() external view returns (uint256);

    
    function getPegTokenPrice() external view returns (uint256);

    
    
    function totalValueInVault() external view returns (uint256 _value);

    
    
    function totalValueInStrategies() external view returns (uint256 _value);

    
    function getStrategies() external view returns (address[] memory _strategies);

    
    function checkActiveStrategy(address _strategy) external view;

    
    
    
    
    
    function estimateMint(address[] memory _assets, uint256[] memory _amounts)
        external
        view
        returns (uint256 _shareAmount);

    
    
    
    
    
    function mint(
        address[] memory _assets,
        uint256[] memory _amounts,
        uint256 _minimumAmount
    ) external returns (uint256 _shareAmount);

    
    
    
    
    
    function burn(uint256 _amount, uint256 _minimumAmount)
        external
        returns (address[] memory _assets, uint256[] memory _amounts);

    
    function rebase() external;

    
    
    
    function lend(address _strategy, IExchangeAggregator.ExchangeToken[] calldata _exchangeTokens)
        external;

    
    
    
    
    function redeem(
        address _strategy,
        uint256 _amount,
        uint256 _outputCode
    ) external;

    
    
    
    
    
    
    /// Emits a {Exchange} event.
    function exchange(
        address _fromToken,
        address _toToken,
        uint256 _amount,
        IExchangeAggregator.ExchangeParam memory _exchangeParam
    ) external returns (uint256);

    
    
    /// Requirement: only keeper call
    /// Emits a {StrategyReported} event.
    function reportByKeeper(address[] memory _strategies) external;

    
    /// Requirement: only the strategy caller is active
    /// Emits a {StrategyReported} event.
    function reportWithoutClaim() external;

    
    
    
    /// Emits a {StrategyReported} event.
    function report(address[] memory _rewardTokens, uint256[] memory _claimAmounts) external;

    
    function setEmergencyShutdown(bool _active) external;

    
    function setAdjustPositionPeriod(bool _adjustPositionPeriod) external;

    
    
    function setRebaseThreshold(uint256 _threshold) external;

    
    
    function setRedeemFeeBps(uint256 _redeemFeeBps) external;

    
    ///      Setting to the zero address disables this feature.
    function setTreasuryAddress(address _address) external;

    
    function setExchangeManagerAddress(address _exchangeManagerAddress) external;

    
    ///      received in basis points.
    function setTrusteeFeeBps(uint256 _basis) external;

    
    function setWithdrawalQueue(address[] memory _queues) external;

    
    function setStrategyEnforceChangeLimit(address _strategy, bool _enabled) external;

    
    ///         Sets '_profitLimitRatio' to the 'profitLimitRatio' field of '_strategy'
    function setStrategySetLimitRatio(
        address _strategy,
        uint256 _lossRatioLimit,
        uint256 _profitLimitRatio
    ) external;

    
    function pauseRebase() external;

    
    function unpauseRebase() external;

    
    function addAsset(address _asset) external;

    
    function removeAsset(address _asset) external;

    
    
    ///      Vault may invest funds into the strategy,
    ///      and the strategy will invest the funds in the 3rd protocol
    function addStrategy(StrategyAdd[] memory _strategyAdds) external;

    
    
    function removeStrategy(address[] memory _strategies) external;

    
    function forceRemoveStrategy(address _strategy) external;

    /////////////////////////////////////////
    //           WithdrawalQueue           //
    /////////////////////////////////////////
    
    
    function getWithdrawalQueue() external view returns (address[] memory);

    
    
    function removeStrategyFromQueue(address[] memory _strategies) external;

    
    function adjustPositionPeriod() external view returns (bool);

    
    function emergencyShutdown() external view returns (bool);

    
    function rebasePaused() external view returns (bool);

    
    /// over this difference ratio automatically rebase.
    /// rebaseThreshold is the numerator and the denominator is 1e7, 
    /// the real ratio is `rebaseThreshold`/1e7.
    function rebaseThreshold() external view returns (uint256);

    
    function trusteeFeeBps() external view returns (uint256);

    
    function redeemFeeBps() external view returns (uint256);

    
    function totalDebt() external view returns (uint256);

    
    function exchangeManager() external view returns (address);

    
    function strategies(address _strategy) external view returns (StrategyParams memory);

    
    function withdrawQueue() external view returns (address[] memory);

    
    function treasury() external view returns (address);

    
    function valueInterpreter() external view returns (address);

    
    function accessControlProxy() external view returns (address);

    
    ///     that will be checked for the strategy reporting
    function setMinCheckedStrategyTotalDebt(uint256 _minCheckedStrategyTotalDebt) external;

    
    ///     that will be checked for the strategy reporting
    function minCheckedStrategyTotalDebt() external view returns (uint256);

    
    function setMaxTimestampBetweenTwoReported(uint256 _maxTimestampBetweenTwoReported) external;

    
    function maxTimestampBetweenTwoReported() external view returns (uint256);

    
    function setMinimumInvestmentAmount(uint256 _minimumInvestmentAmount) external;

    
    function minimumInvestmentAmount() external view returns (uint256);

    
    function setVaultBufferAddress(address _address) external;

    
    function vaultBufferAddress() external view returns (address);

    
    function setPegTokenAddress(address _address) external;

    
    function pegTokenAddress() external view returns (address);

    
    function setAdminImpl(address _newImpl) external;
}

// 

pragma solidity ^0.8.0;




interface IExchangeAggregator {

    
    
    
    
    
    struct ExchangeParam {
        address platform;
        uint8 method;
        bytes encodeExchangeArgs;
        uint256 slippage;
        uint256 oracleAdditionalSlippage;
    }

    
    
    
    
    struct SwapParam {
        address platform;
        uint8 method;
        bytes data;
        IExchangeAdapter.SwapDescription swapDescription;
    }

    
    
    
    
    struct ExchangeToken {
        address fromToken;
        address toToken;
        uint256 fromAmount;
        ExchangeParam exchangeParam;
    }

    
    event ExchangeAdapterAdded(address[] _exchangeAdapters);

    
    event ExchangeAdapterRemoved(address[] _exchangeAdapters);

    
    
    
    
    
    
    
    event Swap(
        address _platform,
        uint256 _amount,
        address _srcToken,
        address _dstToken,
        uint256 _exchangeAmount,
        address indexed _receiver,
        address _sender
    );

    
    
    
    
    
    
    
    function swap(
        address _platform,
        uint8 _method,
        bytes calldata _data,
        IExchangeAdapter.SwapDescription calldata _sd
    ) external payable returns (uint256);

    
    
    
    function batchSwap(SwapParam[] calldata _swapParams) external payable returns (uint256[] memory);

    
    function getExchangeAdapters()
        external
        view
        returns (address[] memory _exchangeAdapters, string[] memory _identifiers);

    
    
    function addExchangeAdapters(address[] calldata _exchangeAdapters) external;

    
    
    function removeExchangeAdapters(address[] calldata _exchangeAdapters) external;
}

// 

pragma solidity >=0.6.0 <0.9.0;



interface IExchangeAdapter {
    
    
    
    
    struct SwapDescription {
        uint256 amount;
        address srcToken;
        address dstToken;
        address receiver;
    }

    
    function identifier() external pure returns (string memory _identifier);

    
    
    
    
    
    function swap(
        uint8 _method,
        bytes calldata _encodedCallArgs,
        SwapDescription calldata _sd
    ) external payable returns (uint256);
}