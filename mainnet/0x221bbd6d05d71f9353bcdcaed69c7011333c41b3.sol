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

pragma solidity 0.8.12;










contract BaseAMOStorage is Initializable {
    // =========================== Constant Address ================================

    
    address internal constant _oneInch = 0x1111111254fb6c44bAC0beD2854e76F90643097d;

    // ================================= Reference =================================

    
    IAMOMinter public amoMinter;

    // ================================= Mappings ==================================

    
    /// gains and losses made on a specific token
    mapping(IERC20 => uint256) public lastBalances;
    
    mapping(IERC20 => uint256) public protocolDebts;
    
    mapping(IERC20 => uint256) public protocolGains;

    uint256[46] private __gapStorage;

    // =============================== Events ======================================

    event Recovered(address tokenAddress, address to, uint256 amountToRecover);

    // =============================== Errors ======================================

    error IncompatibleLengths();
    error NotAMOMinter();
    error NotApproved();
    error NotGovernor();
    error OneInchSwapFailed();
    error TooSmallAmountOut();
    error ZeroAddress();

    
    constructor() initializer {}
}

// 

pragma solidity 0.8.12;







/// contracts of the protocol
interface IAMO {
    // ================================ Views ======================================

    
    
    
    function balance(IERC20 token) external view returns (uint256);

    
    
    function debt(IERC20 token) external view returns (uint256);

    
    /// excluding the loose balance of `token`
    
    
    function getNavOfInvestedAssets(IERC20 token) external view returns (uint256);

    // ========================== Restricted Functions =============================

    
    
    
    
    
    function pushSurplus(
        IERC20 token,
        address to,
        bytes[] memory data
    ) external;

    
    
    /// to claim it
    function claimRewards(IERC20[] memory tokens) external;

    
    
    
    
    function sellRewards(uint256 minAmountOut, bytes memory payload) external;

    
    
    
    
    function changeAllowance(
        IERC20[] calldata tokens,
        address[] calldata spenders,
        uint256[] calldata amounts
    ) external;

    
    
    function recoverERC20(
        address tokenAddress,
        address to,
        uint256 amountToRecover
    ) external;

    // ========================== Only AMOMinter Functions =========================

    
    
    
    
    
    
    /// otherwise the call will revert
    function pull(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes[] memory data
    ) external returns (uint256[] memory);

    
    
    
    
    function push(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes[] memory data
    ) external;

    
    
    
    function setAMOMinter(address amoMinter_) external;

    
    
    function setToken(IERC20 token) external;

    
    
    function removeToken(IERC20 token) external;
}

// 

pragma solidity 0.8.12;







abstract contract BaseAMO is BaseAMOStorage, IAMO {
    using SafeERC20 for IERC20;

    
    
    function _initialize(address amoMinter_) internal initializer {
        if (amoMinter_ == address(0)) revert ZeroAddress();
        amoMinter = IAMOMinter(amoMinter_);
    }

    // =============================== Modifiers ===================================

    
    modifier onlyGovernor() {
        if (!amoMinter.isGovernor(msg.sender)) revert NotGovernor();
        _;
    }

    
    modifier onlyApproved() {
        if (!amoMinter.isApproved(msg.sender)) revert NotApproved();
        _;
    }

    
    modifier onlyAMOMinter() {
        if (msg.sender != address(amoMinter)) revert NotAMOMinter();
        _;
    }

    // ========================= View Functions ====================================

    
    function balance(IERC20 token) external view returns (uint256) {
        uint256 tokenIdleBalance = token.balanceOf(address(this));
        uint256 netAssets = _getNavOfInvestedAssets(token);
        return tokenIdleBalance + netAssets;
    }

    
    function debt(IERC20 token) external view returns (uint256) {
        return amoMinter.callerDebt(token);
    }

    
    function getNavOfInvestedAssets(IERC20 token) external view returns (uint256) {
        return _getNavOfInvestedAssets(token);
    }

    // ====================== Restricted Governance Functions ======================

    
    function pushSurplus(
        IERC20 token,
        address to,
        bytes[] memory data
    ) external onlyApproved {
        if (to == address(0)) revert ZeroAddress();
        uint256 amountToRecover = protocolGains[token];

        IERC20[] memory tokens = new IERC20[](1);
        uint256[] memory amounts = new uint256[](1);
        tokens[0] = token;
        amounts[0] = amountToRecover;
        uint256 amountAvailable = _pull(tokens, amounts, data)[0];

        amountToRecover = amountToRecover <= amountAvailable ? amountToRecover : amountAvailable;
        protocolGains[token] -= amountToRecover;
        token.transfer(to, amountToRecover);
    }

    
    function claimRewards(IERC20[] memory tokens) external onlyApproved {
        _claimRewards(tokens);
    }

    
    function sellRewards(uint256 minAmountOut, bytes memory payload) external onlyApproved {
        //solhint-disable-next-line
        (bool success, bytes memory result) = _oneInch.call(payload);
        if (!success) _revertBytes(result);

        uint256 amountOut = abi.decode(result, (uint256));
        if (amountOut < minAmountOut) revert TooSmallAmountOut();
    }

    
    function changeAllowance(
        IERC20[] calldata tokens,
        address[] calldata spenders,
        uint256[] calldata amounts
    ) external onlyApproved {
        if (tokens.length != spenders.length || tokens.length != amounts.length || tokens.length == 0)
            revert IncompatibleLengths();
        for (uint256 i = 0; i < tokens.length; i++) {
            _changeAllowance(tokens[i], spenders[i], amounts[i]);
        }
    }

    
    
    /// happens through an `onlyApproved` function
    function recoverERC20(
        address tokenAddress,
        address to,
        uint256 amountToRecover
    ) external onlyApproved {
        IERC20(tokenAddress).safeTransfer(to, amountToRecover);
        emit Recovered(tokenAddress, to, amountToRecover);
    }

    
    function execute(address _to, bytes calldata _data) external onlyGovernor returns (bool, bytes memory) {
        //solhint-disable-next-line
        (bool success, bytes memory result) = _to.call(_data);
        return (success, result);
    }

    // ========================== Only AMOMinter Functions =========================

    
    function pull(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes[] memory data
    ) external onlyAMOMinter returns (uint256[] memory) {
        return _pull(tokens, amounts, data);
    }

    
    function push(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes[] memory data
    ) external onlyAMOMinter {
        _push(tokens, amounts, data);
    }

    
    function setAMOMinter(address amoMinter_) external onlyAMOMinter {
        amoMinter = IAMOMinter(amoMinter_);
    }

    
    function setToken(IERC20 token) external onlyAMOMinter {
        _setToken(token);
    }

    
    function removeToken(IERC20 token) external onlyAMOMinter {
        _removeToken(token);
    }

    // ========================== Internal Actions =================================

    
    function _pull(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes[] memory data
    ) internal virtual returns (uint256[] memory) {}

    
    function _push(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes[] memory data
    ) internal virtual {}

    
    function _setToken(IERC20 token) internal virtual {}

    
    function _removeToken(IERC20 token) internal virtual {}

    
    function _claimRewards(IERC20[] memory tokens) internal virtual returns (uint256) {}

    
    function _getNavOfInvestedAssets(IERC20 token) internal view virtual returns (uint256 amountInvested) {}

    
    
    
    
    
    function _report(IERC20 token, uint256 amountAdded)
        internal
        virtual
        returns (uint256 netAssets, uint256 idleTokens)
    {
        // Assumed to be positive
        netAssets = _getNavOfInvestedAssets(token);
        idleTokens = token.balanceOf(address(this));

        // Always positive otherwise we couldn't do the operation, and idleTokens >= amountAdded
        uint256 total = idleTokens + netAssets - amountAdded;
        uint256 lastBalance_ = lastBalances[token];

        if (total > lastBalance_) {
            // In case of a yield gain, if there is already a loss, the gain is used to compensate the previous loss
            uint256 gain = total - lastBalance_;
            uint256 protocolDebtPre = protocolDebts[token];
            if (protocolDebtPre <= gain) {
                protocolGains[token] += gain - protocolDebtPre;
                protocolDebts[token] = 0;
            } else protocolDebts[token] -= gain;
        } else if (total < lastBalance_) {
            // In case of a loss, we first try to compensate it from previous gains for the part that concerns
            // the protocol
            uint256 loss = lastBalance_ - total;
            uint256 protocolGainBeforeLoss = protocolGains[token];
            // If the loss can not be entirely soaked by the gains already made then
            // the protocol keeps track of the debt
            if (loss > protocolGainBeforeLoss) {
                protocolDebts[token] += loss - protocolGainBeforeLoss;
                protocolGains[token] = 0;
            } else protocolGains[token] -= loss;
        }
    }

    
    
    
    
    function _changeAllowance(
        IERC20 token,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = token.allowance(address(this), spender);
        if (currentAllowance < amount) {
            token.safeIncreaseAllowance(spender, amount - currentAllowance);
        } else if (currentAllowance > amount) {
            token.safeDecreaseAllowance(spender, currentAllowance - amount);
        }
    }

    
    
    
    function _approveMaxSpend(address token, address spender) internal {
        IERC20(token).safeApprove(spender, type(uint256).max);
    }

    
    function _revertBytes(bytes memory errMsg) internal pure {
        if (errMsg.length > 0) {
            //solhint-disable-next-line
            assembly {
                revert(add(32, errMsg), mload(errMsg))
            }
        }
        revert OneInchSwapFailed();
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
pragma solidity >=0.8.0;









abstract contract BaseCurveAMO is BaseAMO {
    
    IERC20 public agToken;
    
    address public mainPool;

    uint256[48] private __gapBaseCurveAMO;

    // =================================== ERRORS ==================================

    error IncompatibleTokens();
    error IncompatibleValues();

    // =============================== INITIALIZATION ==============================

    
    
    
    
    function _initializeBaseCurve(
        address amoMinter_,
        IERC20 agToken_,
        address basePool_
    ) internal {
        if (address(agToken_) == address(0) || basePool_ == address(0)) revert ZeroAddress();
        _initialize(amoMinter_);
        agToken = agToken_;
        mainPool = basePool_;
    }

    // ============================== INTERNAL ACTIONS =============================

    
    function _push(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes[] memory data
    ) internal override {
        (tokens, amounts) = _checkTokensList(tokens, amounts);

        // Checking first for profit / loss made on each token (in this case just the `agToken`)
        for (uint256 i = 0; i < tokens.length; i++) {
            (uint256 netAssets, uint256 idleAssets) = _report(tokens[i], amounts[i]);
            // As the `add_liquidity` function on Curve can only deposit the right amount
            // we can compute directly `lastBalance`
            lastBalances[tokens[i]] = netAssets + idleAssets;
        }

        _curvePoolDeposit(amounts, data);
        _depositLPToken();
    }

    
    
    function _pull(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes[] memory data
    ) internal override returns (uint256[] memory amountsAvailable) {
        (tokens, amounts) = _checkTokensList(tokens, amounts);

        uint256[] memory idleTokens = new uint256[](tokens.length);

        // Check for profit / loss made on each token. This doesn't take into account rewards
        for (uint256 i = 0; i < tokens.length; i++) {
            (uint256 netAssets, uint256 idleAssets) = _report(tokens[i], 0);
            lastBalances[tokens[i]] = netAssets + idleAssets - amounts[i];
            idleTokens[i] = idleAssets;
        }

        // We first need to unstake and withdraw the staker(s) LP token to get the Curve LP token
        // We unstake all from the staker(s) as we don't know how much will be needed to get back `amounts`
        _withdrawLPToken();
        amountsAvailable = _curvePoolWithdraw(tokens, amounts, idleTokens, data);
        // The leftover Curve LP token balance is staked back
        _depositLPToken();

        return amountsAvailable;
    }

    // =========================== VIRTUAL CURVE ACTIONS ===========================

    
    
    
    
    function _curvePoolDeposit(uint256[] memory amounts, bytes[] memory data)
        internal
        virtual
        returns (uint256 lpTokenReceived);

    
    
    
    
    
    function _curvePoolWithdraw(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory idleTokens,
        bytes[] memory data
    ) internal virtual returns (uint256[] memory);

    // ========================== INTERNAL STAKER ACTIONS ==========================

    
    function _depositLPToken() internal virtual;

    
    function _withdrawLPToken() internal virtual;

    
    function _balanceLPStaked() internal view virtual returns (uint256);

    // ========================== Internal Computations ============================

    
    
    
    
    
    function _calcRemoveLiquidityStablePool(
        uint256 tokenSupply,
        uint256 totalLpSupply,
        uint256 myLpSupply
    ) internal pure returns (uint256 tokenWithdrawn) {
        if (totalLpSupply > 0) tokenWithdrawn = (tokenSupply * myLpSupply) / totalLpSupply;
    }

    // ============================= VIRTUAL FUNCTIONS =============================

    
    /// reverting if the tokens are not supported and filling the arrays if they are missing entries
    
    
    function _checkTokensList(IERC20[] memory tokens, uint256[] memory amounts)
        internal
        virtual
        returns (IERC20[] memory, uint256[] memory);
}

// 
pragma solidity >=0.8.0;








/// the agToken is the first token of the pool (like agEUR in the agEUR/EUROC pool)
abstract contract BaseCurveBPAMO is BaseCurveAMO {
    
    uint256 public constant decimalNormalizer = 10**12;

    uint256[50] private __gapBaseCurveBPAMO;

    // =============================== INITIALIZATION ==============================

    
    function _initializeBaseCurveBPAMO(
        address amoMinter_,
        IERC20 agToken_,
        address basePool_
    ) internal {
        _initializeBaseCurve(amoMinter_, agToken_, basePool_);
    }

    // =============================== VIEW FUNCTIONS ==============================

    
    function keeperInfo()
        external
        view
        virtual
        returns (
            address,
            address,
            uint256
        )
    {
        return (mainPool, address(agToken), uint256(0));
    }

    // ========================== Internal Actions =================================

    
    
    
    function _getNavOfInvestedAssets(IERC20) internal view override returns (uint256 netInvested) {
        // Should be null at all times because invested on a staking platform
        uint256 lpTokenOwned = IMetaPool2(mainPool).balanceOf(address(this));
        // Staked LP tokens in Convex or StakeDAO vault
        uint256 stakedLptoken = _balanceLPStaked();
        lpTokenOwned = lpTokenOwned + stakedLptoken;

        if (lpTokenOwned != 0) {
            uint256 lpSupply = IMetaPool2(mainPool).totalSupply();
            uint256[2] memory balances = IMetaPool2(mainPool).get_balances();
            netInvested = _calcRemoveLiquidityStablePool(balances[0], lpSupply, lpTokenOwned);
            // Here we consider that the `collateral` is tradable 1:1 for `agToken`
            netInvested += _calcRemoveLiquidityStablePool(balances[1], lpSupply, lpTokenOwned) * decimalNormalizer;
        }
    }

    
    function _checkTokensList(IERC20[] memory tokens, uint256[] memory amounts)
        internal
        view
        override
        returns (IERC20[] memory, uint256[] memory)
    {
        if (tokens.length != 1) revert IncompatibleLengths();
        if (address(tokens[0]) != address(agToken)) revert IncompatibleTokens();
        return (tokens, amounts);
    }

    // ======================== Internal Curve actions =============================

    
    
    function _curvePoolDeposit(uint256[] memory amounts, bytes[] memory data)
        internal
        override
        returns (uint256 lpTokenReceived)
    {
        uint256 minLpAmount = abi.decode(data[0], (uint256));
        _changeAllowance(agToken, address(mainPool), amounts[0]);
        lpTokenReceived = IMetaPool2(mainPool).add_liquidity([amounts[0], 0], minLpAmount);
        return lpTokenReceived;
    }

    
    function _curvePoolWithdraw(
        IERC20[] memory,
        uint256[] memory amounts,
        uint256[] memory,
        bytes[] memory data
    ) internal override returns (uint256[] memory) {
        uint256 maxLpBurnt = abi.decode(data[0], (uint256));
        IMetaPool2(mainPool).remove_liquidity_imbalance([amounts[0], 0], maxLpBurnt);
        return amounts;
    }
}

// 
pragma solidity >=0.8.0;














abstract contract MultiStakerCurveBPAMO is BaseCurveBPAMO {
    uint256 private constant _BASE_PARAMS = 10**9;

    
    IConvexBooster private constant _convexBooster = IConvexBooster(0xF403C135812408BFbE8713b5A23a04b3D48AAE31);
    IConvexClaimZap private constant _convexClaimZap = IConvexClaimZap(0xDd49A93FDcae579AE50B4b9923325e9e335ec82B);

    
    uint256 public stakeDAOProportion;

    // // if we want to accept a loss when withdrawing
    // uint256 private constant _MAX_LOSS = 10**6;

    uint256[49] private __gapMultiStakerCurveBPAMO;

    // =================================== ERRORS ==================================

    error WithdrawFeeTooLarge();

    // =============================== INITIALIZATION ==============================

    
    function initialize(
        address amoMinter_,
        IERC20 agToken_,
        address basePool_
    ) external {
        _initializeBaseCurveBPAMO(amoMinter_, agToken_, basePool_);
    }

    // =================================== SETTER ==================================

    
    /// to Convex
    function setStakeDAOProportion(uint256 _newProp) external onlyApproved {
        if (_newProp > _BASE_PARAMS) revert IncompatibleValues();
        stakeDAOProportion = _newProp;
    }

    // ============================= INTERNAL ACTIONS ==============================

    
    
    function _depositLPToken() internal override {
        uint256 balanceLP = IERC20(mainPool).balanceOf(address(this));

        // Compute what should go to Stake and Convex respectively
        uint256 lpForStakeDAO = (balanceLP * stakeDAOProportion) / _BASE_PARAMS;
        uint256 lpForConvex = balanceLP - lpForStakeDAO;

        if (lpForStakeDAO > 0) {
            // Approve the vault contract for the Curve LP tokens
            _changeAllowance(IERC20(mainPool), address(_vault()), lpForStakeDAO);
            // Deposit the Curve LP tokens into the vault contract and stake
            _vault().deposit(address(this), lpForStakeDAO, true);
        }

        if (lpForConvex > 0) {
            // Deposit the Curve LP tokens into the convex contract and stake
            _changeAllowance(IERC20(mainPool), address(_convexBooster), lpForConvex);
            _convexBooster.deposit(_poolPid(), lpForConvex, true);
        }
    }

    
    function _withdrawLPToken() internal override {
        uint256 lpInStakeDAO = _stakeDAOLPStaked();
        uint256 lpInConvex = _convexLPStaked();
        if (lpInStakeDAO > 0) {
            if (_vault().withdrawalFee() > 0) revert WithdrawFeeTooLarge();
            _vault().withdraw(lpInStakeDAO);
        }
        if (lpInConvex > 0) _baseRewardPool().withdrawAllAndUnwrap(true);
    }

    
    
    
    
    
    /// the new contract
    function _claimRewards(IERC20[] memory) internal override returns (uint256) {
        // Claim on StakeDAO
        _gauge().claim_rewards(address(this));
        // Claim on Convex
        address[] memory rewardContracts = new address[](1);
        rewardContracts[0] = address(_baseRewardPool());

        _convexClaimZap.claimRewards(
            rewardContracts,
            new address[](0),
            new address[](0),
            new address[](0),
            0,
            0,
            0,
            0,
            0
        );
        return 0;
    }

    // ========================== INTERNAL VIEW FUNCTIONS ==========================

    
    function _balanceLPStaked() internal view override returns (uint256) {
        return _convexLPStaked() + _stakeDAOLPStaked();
    }

    
    function _stakeDAOLPStaked() internal view returns (uint256) {
        return _gauge().balanceOf(address(this));
    }

    
    function _convexLPStaked() internal view returns (uint256) {
        return _baseRewardPool().balanceOf(address(this));
    }

    // ============================= VIRTUAL FUNCTIONS =============================
    
    
    function _vault() internal pure virtual returns (IStakeCurveVault);

    
    function _gauge() internal pure virtual returns (ILiquidityGauge);

    
    function _baseRewardPool() internal pure virtual returns (IConvexBaseRewardPool);

    
    function _poolPid() internal pure virtual returns (uint256);
}

// 

pragma solidity 0.8.12;



//solhint-disable
interface IMetaPoolBase is IERC20 {
    function admin_fee() external view returns (uint256);

    function A() external view returns (uint256);

    function A_precise() external view returns (uint256);

    function get_virtual_price() external view returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        address _receiver
    ) external returns (uint256);

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        address _receiver
    ) external returns (uint256);

    function calc_withdraw_one_coin(uint256 _burn_amount, int128 i) external view returns (uint256);

    function calc_withdraw_one_coin(
        uint256 _burn_amount,
        int128 i,
        bool _previous
    ) external view returns (uint256);

    function remove_liquidity_one_coin(
        uint256 _burn_amount,
        int128 i,
        uint256 _min_received
    ) external returns (uint256);

    function remove_liquidity_one_coin(
        uint256 _burn_amount,
        int128 i,
        uint256 _min_received,
        address _receiver
    ) external returns (uint256);

    function admin_balances(uint256 i) external view returns (uint256);

    function withdraw_admin_fees() external;
}
// 
pragma solidity >=0.8.0;






contract MultiStakerCurveAgEURvEUROCAMO is MultiStakerCurveBPAMO {
    IStakeCurveVault private constant _stakeDAOVault = IStakeCurveVault(0xDe46532a49c88af504594F488822F452b7FBc7BD);
    ILiquidityGauge private constant _liquidityGauge = ILiquidityGauge(0x63f222079608EEc2DDC7a9acdCD9344a21428Ce7);
    IConvexBaseRewardPool private constant _convexBaseRewardPool =
        IConvexBaseRewardPool(0xA91fccC1ec9d4A2271B7A86a7509Ca05057C1A98);
    uint256 private constant _convexPoolPid = 113;

    
    function _vault() internal pure override returns (IStakeCurveVault) {
        return _stakeDAOVault;
    }

    
    function _gauge() internal pure override returns (ILiquidityGauge) {
        return _liquidityGauge;
    }

    
    function _baseRewardPool() internal pure override returns (IConvexBaseRewardPool) {
        return _convexBaseRewardPool;
    }

    
    function _poolPid() internal pure override returns (uint256) {
        return _convexPoolPid;
    }
}

// 

pragma solidity 0.8.12;

//solhint-disable
interface IConvexBooster {
    function FEE_DENOMINATOR() external view returns (uint256);

    function addPool(
        address _lptoken,
        address _gauge,
        uint256 _stashVersion
    ) external returns (bool);

    function claimRewards(uint256 _pid, address _gauge) external returns (bool);

    function deposit(
        uint256 _pid,
        uint256 _amount,
        bool _stake
    ) external returns (bool);

    function depositAll(uint256 _pid, bool _stake) external returns (bool);

    function gaugeMap(address) external view returns (bool);

    function poolInfo(uint256)
        external
        view
        returns (
            address lptoken,
            address token,
            address gauge,
            address crvRewards,
            address stash,
            bool shutdown
        );

    function staker() external view returns (address);

    function withdraw(uint256 _pid, uint256 _amount) external returns (bool);

    function withdrawAll(uint256 _pid) external returns (bool);

    function withdrawTo(
        uint256 _pid,
        uint256 _amount,
        address _to
    ) external returns (bool);
}

// 

pragma solidity 0.8.12;

//solhint-disable
interface IConvexBaseRewardPool {
    function balanceOf(address account) external view returns (uint256);

    function duration() external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function extraRewards(uint256) external view returns (address);

    function extraRewardsLength() external view returns (uint256);

    function getReward() external returns (bool);

    function getReward(address _account, bool _claimExtras) external returns (bool);

    function lastTimeRewardApplicable() external view returns (uint256);

    function lastUpdateTime() external view returns (uint256);

    function newRewardRatio() external view returns (uint256);

    function periodFinish() external view returns (uint256);

    function pid() external view returns (uint256);

    function queueNewRewards(uint256 _rewards) external returns (bool);

    function rewardRate() external view returns (uint256);

    function rewardToken() external view returns (address);

    function stake(uint256 _amount) external returns (bool);

    function stakeAll() external returns (bool);

    function stakeFor(address _for, uint256 _amount) external returns (bool);

    function stakingToken() external view returns (address);

    function totalSupply() external view returns (uint256);

    function withdraw(uint256 amount, bool claim) external returns (bool);

    function withdrawAll(bool claim) external;

    function withdrawAllAndUnwrap(bool claim) external;

    function withdrawAndUnwrap(uint256 amount, bool claim) external returns (bool);
}

// 

pragma solidity 0.8.12;

//solhint-disable
interface IConvexClaimZap {
    function claimRewards(
        address[] calldata rewardContracts,
        address[] calldata extraRewardContracts,
        address[] calldata tokenRewardContracts,
        address[] calldata tokenRewardTokens,
        uint256 depositCrvMaxAmount,
        uint256 minAmountOut,
        uint256 depositCvxMaxAmount,
        uint256 spendCvxAmount,
        uint256 options
    ) external;
}

// 

pragma solidity 0.8.12;

interface ICvxRewardPool {
    function balanceOf(address account) external view returns (uint256);

    function duration() external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function extraRewards(uint256) external view returns (address);

    function extraRewardsLength() external view returns (uint256);

    function getReward(bool stake) external returns (bool);

    function getReward(
        address _account,
        bool _claimExtras,
        bool stake
    ) external returns (bool);

    function lastTimeRewardApplicable() external view returns (uint256);

    function rewardRate() external view returns (uint256);

    function stake(uint256 _amount) external returns (bool);

    function stakeAll() external returns (bool);

    function stakeFor(address _for, uint256 _amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function withdraw(uint256 amount, bool claim) external returns (bool);

    function withdrawAll(bool claim) external;
}

// 

pragma solidity 0.8.12;

interface IStakeCurveVault {
    
    
    
    
    function deposit(
        address _staker,
        uint256 _amount,
        bool _earn
    ) external;

    
    
    // cautious with the withdraw fee
    function withdraw(uint256 _shares) external;

    
    function withdrawAll() external;

    function setWithdrawnFee(uint256 _newFee) external;

    function withdrawalFee() external returns (uint256);

    function accumulatedFee() external returns (uint256);
}

// 

pragma solidity 0.8.12;

interface IClaimerRewards {
    
    
    function claimRewards(address[] calldata _gauges) external;
}

// 

pragma solidity 0.8.12;



interface ILiquidityGauge is IERC20 {
    // solhint-disable-next-line
    function claim_rewards(address _addr) external;

    // solhint-disable-next-line
    function claim_rewards(address _addr, address _receiver) external;

    // solhint-disable-next-line
    function claim_rewards_for(address _addr, address _receiver) external;

    // solhint-disable-next-line
    function deposit_reward_token(address _reward_token, uint256 _amount) external;
}

// 

pragma solidity 0.8.12;



uint256 constant N_COINS = 2;

//solhint-disable
interface IMetaPool2 is IMetaPoolBase {
    function coins() external view returns (uint256[N_COINS] memory);

    function get_balances() external view returns (uint256[N_COINS] memory);

    function get_previous_balances() external view returns (uint256[N_COINS] memory);

    function get_price_cumulative_last() external view returns (uint256[N_COINS] memory);

    function get_twap_balances(
        uint256[N_COINS] memory _first_balances,
        uint256[N_COINS] memory _last_balances,
        uint256 _time_elapsed
    ) external view returns (uint256[N_COINS] memory);

    function calc_token_amount(uint256[N_COINS] memory _amounts, bool _is_deposit) external view returns (uint256);

    function calc_token_amount(
        uint256[N_COINS] memory _amounts,
        bool _is_deposit,
        bool _previous
    ) external view returns (uint256);

    function add_liquidity(uint256[N_COINS] memory _amounts, uint256 _min_mint_amount) external returns (uint256);

    function add_liquidity(
        uint256[N_COINS] memory _amounts,
        uint256 _min_mint_amount,
        address _receiver
    ) external returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx,
        uint256[N_COINS] memory _balances
    ) external view returns (uint256);

    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256[N_COINS] memory _balances
    ) external view returns (uint256);

    function remove_liquidity(uint256 _burn_amount, uint256[N_COINS] memory _min_amounts)
        external
        returns (uint256[N_COINS] memory);

    function remove_liquidity(
        uint256 _burn_amount,
        uint256[N_COINS] memory _min_amounts,
        address _receiver
    ) external returns (uint256[N_COINS] memory);

    function remove_liquidity_imbalance(uint256[N_COINS] memory _amounts, uint256 _max_burn_amount)
        external
        returns (uint256);

    function remove_liquidity_imbalance(
        uint256[N_COINS] memory _amounts,
        uint256 _max_burn_amount,
        address _receiver
    ) external returns (uint256);
}

// 

pragma solidity 0.8.12;



// this interface doesn't wok with 3Pool as it doesn't return anything on add_liquidity, remove_liquidity_one_coin
//solhint-disable
interface IStableSwapPool is IERC20 {
    function A() external view returns (uint256);

    function get_virtual_price() external view returns (uint256);

    function calc_token_amount(uint256[3] memory amounts, bool deposit) external view returns (uint256);

    function add_liquidity(uint256[3] memory amounts, uint256 min_mint_amount) external returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;

    function remove_liquidity(uint256 _amount, uint256[3] memory min_amounts) external;

    function remove_liquidity_imbalance(uint256[3] memory amounts, uint256 max_burn_amount) external;

    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_amount
    ) external returns (uint256);
}

// 

pragma solidity 0.8.12;



//solhint-disable
interface IMetaPool is IERC20 {
    function coins() external view returns (uint256[] memory);

    function get_balances() external view returns (uint256[] memory);

    function get_previous_balances() external view returns (uint256[] memory);

    function get_twap_balances(
        uint256[] memory _first_balances,
        uint256[] memory _last_balances,
        uint256 _time_elapsed
    ) external view returns (uint256[] memory);

    function get_price_cumulative_last() external view returns (uint256[] memory);

    function admin_fee() external view returns (uint256);

    function A() external view returns (uint256);

    function A_precise() external view returns (uint256);

    function get_virtual_price() external view returns (uint256);

    function calc_token_amount(uint256[] memory _amounts, bool _is_deposit) external view returns (uint256);

    function calc_token_amount(
        uint256[] memory _amounts,
        bool _is_deposit,
        bool _previous
    ) external view returns (uint256);

    function add_liquidity(uint256[] memory _amounts, uint256 _min_mint_amount) external returns (uint256);

    function add_liquidity(
        uint256[] memory _amounts,
        uint256 _min_mint_amount,
        address _receiver
    ) external returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx,
        uint256[] memory _balances
    ) external view returns (uint256);

    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256[] memory _balances
    ) external view returns (uint256);

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        address _receiver
    ) external returns (uint256);

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        address _receiver
    ) external returns (uint256);

    function remove_liquidity(uint256 _burn_amount, uint256[] memory _min_amounts) external returns (uint256[] memory);

    function remove_liquidity(
        uint256 _burn_amount,
        uint256[] memory _min_amounts,
        address _receiver
    ) external returns (uint256[] memory);

    function remove_liquidity_imbalance(uint256[] memory _amounts, uint256 _max_burn_amount) external returns (uint256);

    function remove_liquidity_imbalance(
        uint256[] memory _amounts,
        uint256 _max_burn_amount,
        address _receiver
    ) external returns (uint256);

    function calc_withdraw_one_coin(uint256 _burn_amount, int128 i) external view returns (uint256);

    function calc_withdraw_one_coin(
        uint256 _burn_amount,
        int128 i,
        bool _previous
    ) external view returns (uint256);

    function remove_liquidity_one_coin(
        uint256 _burn_amount,
        int128 i,
        uint256 _min_received
    ) external returns (uint256);

    function remove_liquidity_one_coin(
        uint256 _burn_amount,
        int128 i,
        uint256 _min_received,
        address _receiver
    ) external returns (uint256);

    function admin_balances(uint256 i) external view returns (uint256);

    function withdraw_admin_fees() external;
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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

pragma solidity 0.8.12;








/// by other contracts of the protocol
interface IAMOMinter {
    
    function isGovernor(address admin) external view returns (bool);

    
    /// is expected to be an AMO
    function isApproved(address admin) external view returns (bool);

    
    
    function callerDebt(IERC20 token) external view returns (uint256);

    
    function amoDebts(IAMO amo, IERC20 token) external view returns (uint256);

    
    
    
    
    
    
    
    
    function sendToAMO(
        IAMO amo,
        IERC20[] memory tokens,
        bool[] memory isStablecoin,
        uint256[] memory amounts,
        bytes[] memory data
    ) external;

    
    
    
    
    
    
    function receiveFromAMO(
        IAMO amo,
        IERC20[] memory tokens,
        bool[] memory isStablecoin,
        uint256[] memory amounts,
        address[] memory to,
        bytes[] memory data
    ) external;
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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