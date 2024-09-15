// SPDX-License-Identifier: UNLICENSED

/**
 *Submitted for verification at Etherscan.io on 2022-04-08
*/

// 
pragma solidity 0.8.13;

// OpenZeppelin Contracts (last updated v4.6.0-rc.0) (token/ERC20/IERC20.sol)



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



///         inappropriate.
///

error IllegalArgument(string message);


///

error IllegalState(string message);


///

error UnsupportedOperation(string message);


///

error Unauthorized(string message);


///

abstract contract Multicall {
    error MulticallFailed(bytes data, bytes result);

    function multicall(
        bytes[] calldata data
    ) external payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                revert MulticallFailed(data[i], result);
            }

            results[i] = result;
        }
    }
}


///

abstract contract Mutex {
    enum State {
        RESERVED,
        UNLOCKED,
        LOCKED
    }

    
    State private _lockState = State.UNLOCKED;

    
    modifier lock() {
        _claimLock();

        _;

        _freeLock();
    }

    
    ///
    
    function _isLocked() internal view returns (bool) {
        return _lockState == State.LOCKED;
    }

    
    function _claimLock() internal {
        // Check that the lock has not been claimed yet.
        if (_lockState != State.UNLOCKED) {
            revert IllegalState("Lock already claimed");
        }

        // Claim the lock.
        _lockState = State.LOCKED;
    }

    
    function _freeLock() internal {
        _lockState = State.UNLOCKED;
    }
}



interface IERC20TokenReceiver {
    
    ///
    
    
    function onERC20Received(address token, uint256 value) external;
}
interface IConvexBooster {
    function deposit(uint256 pid, uint256 amount, bool stake) external returns (bool);
    function withdraw(uint256 pid, uint256 amount) external returns (bool);
}
interface IConvexRewards {
    function rewardToken() external view returns (IERC20);
    function earned(address account) external view returns (uint256);
    function extraRewards(uint256 index) external view returns (address);
    function balanceOf(address account) external returns(uint256);
    function withdraw(uint256 amount, bool claim) external returns (bool);
    function withdrawAndUnwrap(uint256 amount, bool claim) external returns (bool);
    function getReward() external returns (bool);
    function getReward(address recipient, bool claim) external returns (bool);
    function stake(uint256 amount) external returns (bool);
    function stakeFor(address account, uint256 amount) external returns (bool);
}
interface IConvexToken is IERC20 {
    function maxSupply() external view returns (uint256);
    function totalCliffs() external view returns (uint256);
    function reductionPerCliff() external view returns (uint256);
}


uint256 constant NUM_META_COINS = 2;

interface IStableMetaPool is IERC20 {
    function get_balances() external view returns (uint256[NUM_META_COINS] memory);

    function coins(uint256 index) external view returns (IERC20);

    function A() external view returns (uint256);

    function get_virtual_price() external view returns (uint256);

    function calc_token_amount(
        uint256[NUM_META_COINS] calldata amounts,
        bool deposit
    ) external view returns (uint256 amount);

    function add_liquidity(
        uint256[NUM_META_COINS] calldata amounts,
        uint256 minimumMintAmount
    ) external returns (uint256 minted);

    function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256 dy);

    function get_dy_underlying(int128 i, int128 j, uint256 dx, uint256[NUM_META_COINS] calldata balances) external view returns (uint256 dy);

    function exchange(int128 i, int128 j, uint256 dx, uint256 minimumDy) external returns (uint256);

    function remove_liquidity(uint256 amount, uint256[NUM_META_COINS] calldata minimumAmounts) external;

    function remove_liquidity_imbalance(
        uint256[NUM_META_COINS] calldata amounts,
        uint256 maximumBurnAmount
    ) external returns (uint256);

    function calc_withdraw_one_coin(uint256 tokenAmount, int128 i) external view returns (uint256);

    function remove_liquidity_one_coin(
        uint256 tokenAmount,
        int128 i,
        uint256 minimumAmount
    ) external returns (uint256);

    function get_price_cumulative_last() external view returns (uint256[NUM_META_COINS] calldata);

    function block_timestamp_last() external view returns (uint256);

    function get_twap_balances(
        uint256[NUM_META_COINS] calldata firstBalances,
        uint256[NUM_META_COINS] calldata lastBalances,
        uint256 timeElapsed
    ) external view returns (uint256[NUM_META_COINS] calldata);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx,
        uint256[NUM_META_COINS] calldata balances
    ) external view returns (uint256);
}

uint256 constant NUM_STABLE_COINS = 3;

interface IStableSwap3Pool {
    function coins(uint256 index) external view returns (IERC20);

    function A() external view returns (uint256);

    function get_virtual_price() external view returns (uint256);

    function calc_token_amount(
        uint256[NUM_STABLE_COINS] calldata amounts,
        bool deposit
    ) external view returns (uint256 amount);

    function add_liquidity(uint256[NUM_STABLE_COINS] calldata amounts, uint256 minimumMintAmount) external;

    function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256 dy);

    function get_dy_underlying(int128 i, int128 j, uint256 dx) external view returns (uint256 dy);

    function exchange(int128 i, int128 j, uint256 dx, uint256 minimumDy) external returns (uint256);

    function remove_liquidity(uint256 amount, uint256[NUM_STABLE_COINS] calldata minimumAmounts) external;

    function remove_liquidity_imbalance(
        uint256[NUM_STABLE_COINS] calldata amounts,
        uint256 maximumBurnAmount
    ) external;

    function calc_withdraw_one_coin(uint256 tokenAmount, int128 i) external view returns (uint256);

    function remove_liquidity_one_coin(
        uint256 tokenAmount,
        int128 i,
        uint256 minimumAmount
    ) external;
}



interface IERC20Metadata {
    
    ///
    
    function name() external view returns (string memory);

    
    ///
    
    function symbol() external view returns (string memory);

    
    ///
    
    function decimals() external view returns (uint8);
}



library SafeERC20 {
    
    ///
    
    
    
    ///                success. Otherwise, this is malformed data when the call was a success.
    error ERC20CallFailed(address target, bool success, bytes data);

    
    ///
    
    ///      unexpected value.
    ///
    
    ///
    
    function expectDecimals(address token) internal view returns (uint8) {
        (bool success, bytes memory data) = token.staticcall(
            abi.encodeWithSelector(IERC20Metadata.decimals.selector)
        );

        if (!success || data.length < 32) {
            revert ERC20CallFailed(token, success, data);
        }

        return abi.decode(data, (uint8));
    }

    
    ///
    
    ///      unexpected value.
    ///
    
    
    
    function safeTransfer(address token, address recipient, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transfer.selector, recipient, amount)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///      unexpected value.
    ///
    
    
    
    function safeApprove(address token, address spender, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.approve.selector, spender, value)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }

    
    ///
    
    ///      unexpected value.
    ///
    
    
    
    
    function safeTransferFrom(address token, address owner, address recipient, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, owner, recipient, amount)
        );

        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert ERC20CallFailed(token, success, data);
        }
    }
}


///         in the contract to prevent naming collisions.
struct InitializationParams {
    address admin;
    address operator;
    address rewardReceiver;
    address transmuterBuffer;
    IERC20 curveToken;
    IStableSwap3Pool threePool;
    IStableMetaPool metaPool;
    uint256 threePoolSlippage;
    uint256 metaPoolSlippage;
    IConvexToken convexToken;
    IConvexBooster convexBooster;
    IConvexRewards convexRewards;
    uint256 convexPoolId;
}


uint256 constant SLIPPAGE_PRECISION = 1e4;


uint256 constant CURVE_PRECISION = 1e18;


///

enum ThreePoolAsset {
    DAI, USDC, USDT
}


///

enum MetaPoolAsset {
    ALUSD, THREE_POOL
}



contract ThreePoolAssetManager is Multicall, Mutex, IERC20TokenReceiver {
    
    ///
    
    event AdminUpdated(address admin);

    
    ///
    
    event PendingAdminUpdated(address pendingAdmin);

    
    ///
    
    event OperatorUpdated(address operator);

    
    ///
    
    event RewardReceiverUpdated(address rewardReceiver);

    
    ///
    
    event TransmuterBufferUpdated(address transmuterBuffer);

    
    ///
    
    event ThreePoolSlippageUpdated(uint256 threePoolSlippage);

    
    ///
    
    event MetaPoolSlippageUpdated(uint256 metaPoolSlippage);

    
    ///
    
    
    event MintThreePoolTokens(uint256[NUM_STABLE_COINS] amounts, uint256 mintedThreePoolTokens);

    
    ///
    
    
    
    event MintThreePoolTokens(ThreePoolAsset asset, uint256 amount, uint256 mintedThreePoolTokens);

    
    ///
    
    
    
    event BurnThreePoolTokens(ThreePoolAsset asset, uint256 amount, uint256 withdrawn);

    
    ///
    
    
    event MintMetaPoolTokens(uint256[NUM_META_COINS] amounts, uint256 mintedThreePoolTokens);

    
    ///
    
    
    
    event MintMetaPoolTokens(MetaPoolAsset asset, uint256 amount, uint256 minted);

    
    ///
    
    
    
    event BurnMetaPoolTokens(MetaPoolAsset asset, uint256 amount, uint256 withdrawn);

    
    ///
    
    
    event DepositMetaPoolTokens(uint256 amount, bool success);

    
    ///
    
    
    event WithdrawMetaPoolTokens(uint256 amount, bool success);

    
    ///
    
    
    
    event ClaimRewards(bool success, uint256 amountCurve, uint256 amountConvex);

    
    ///
    
    
    event ReclaimThreePoolAsset(ThreePoolAsset asset, uint256 amount);

    
    address public admin;

    
    address public pendingAdmin;

    
    address public operator;

    // @notice The reward receiver.
    address public rewardReceiver;

    
    address public transmuterBuffer;

    
    IERC20 public immutable curveToken;

    
    IStableSwap3Pool public immutable threePool;

    
    IStableMetaPool public immutable metaPool;

    
    ///         from the stable swap pool. In units of basis points.
    uint256 public threePoolSlippage;

    
    ///         from the meta pool. In units of basis points.
    uint256 public metaPoolSlippage;

    
    IConvexToken public immutable convexToken;

    
    IConvexBooster public immutable convexBooster;

    
    IConvexRewards public immutable convexRewards;

    
    uint256 public immutable convexPoolId;

    
    IERC20[NUM_STABLE_COINS] private _threePoolAssetCache;

    
    IERC20[NUM_META_COINS] private _metaPoolAssetCache;

    
    modifier onlyAdmin() {
        if (msg.sender != admin) {
            revert Unauthorized("Not admin");
        }
        _;
    }

    
    modifier onlyOperator() {
        if (msg.sender != operator) {
            revert Unauthorized("Not operator");
        }
        _;
    }

    constructor(InitializationParams memory params) {
        admin             = params.admin;
        operator          = params.operator;
        rewardReceiver    = params.rewardReceiver;
        transmuterBuffer  = params.transmuterBuffer;
        curveToken        = params.curveToken;
        threePool         = params.threePool;
        metaPool          = params.metaPool;
        threePoolSlippage = params.threePoolSlippage;
        metaPoolSlippage  = params.metaPoolSlippage;
        convexToken       = params.convexToken;
        convexBooster     = params.convexBooster;
        convexRewards     = params.convexRewards;
        convexPoolId      = params.convexPoolId;

        for (uint256 i = 0; i < NUM_STABLE_COINS; i++) {
            _threePoolAssetCache[i] = params.threePool.coins(i);
        }

        for (uint256 i = 0; i < NUM_META_COINS; i++) {
            _metaPoolAssetCache[i] = params.metaPool.coins(i);
        }

        emit AdminUpdated(admin);
        emit OperatorUpdated(operator);
        emit RewardReceiverUpdated(rewardReceiver);
        emit TransmuterBufferUpdated(transmuterBuffer);
        emit ThreePoolSlippageUpdated(threePoolSlippage);
        emit MetaPoolSlippageUpdated(metaPoolSlippage);
    }

    
    ///
    
    function metaPoolReserves() external view returns (uint256) {
        return metaPool.balanceOf(address(this));
    }

    
    ///
    
    ///
    
    function threePoolAssetReserves(ThreePoolAsset asset) external view returns (uint256) {
        IERC20 token = getTokenForThreePoolAsset(asset);
        return token.balanceOf(address(this));
    }

    
    ///
    
    ///
    
    function metaPoolAssetReserves(MetaPoolAsset asset) external view returns (uint256) {
        IERC20 token = getTokenForMetaPoolAsset(asset);
        return token.balanceOf(address(this));
    }

    
    ///
    
    ///
    
    function exchangeRate(ThreePoolAsset asset) public view returns (uint256) {
        IERC20 alUSD = getTokenForMetaPoolAsset(MetaPoolAsset.ALUSD);

        uint256[NUM_META_COINS] memory metaBalances = metaPool.get_balances();
        uint256 amountThreePool = metaPool.get_dy(
            int128(uint128(uint256(MetaPoolAsset.ALUSD))),
            int128(uint128(uint256(MetaPoolAsset.THREE_POOL))),
            10**SafeERC20.expectDecimals(address(alUSD)),
            metaBalances
        );

        return threePool.calc_withdraw_one_coin(amountThreePool, int128(uint128(uint256(asset))));
    }

    
    struct CalculateRebalanceLocalVars {
        uint256 minimum;
        uint256 maximum;
        uint256 minimumDistance;
        uint256 minimizedBalance;
        uint256 startingBalance;
    }

    
    ///         to reach a target exchange rate for a specified 3pool asset.
    ///
    
    
    
    ///
    
    
    function calculateRebalance(
        MetaPoolAsset rebalanceAsset,
        ThreePoolAsset targetExchangeAsset,
        uint256 targetExchangeRate
    ) public view returns (uint256 delta, bool add) {
        uint256 decimals;
        {
            IERC20 alUSD = getTokenForMetaPoolAsset(MetaPoolAsset.ALUSD);
            decimals     = SafeERC20.expectDecimals(address(alUSD));
        }

        uint256[NUM_META_COINS] memory startingBalances = metaPool.get_balances();
        uint256[NUM_META_COINS] memory currentBalances  = [startingBalances[0], startingBalances[1]];

        CalculateRebalanceLocalVars memory v;
        v.minimum          = 0;
        v.maximum          = type(uint96).max;
        v.minimumDistance  = type(uint256).max;
        v.minimizedBalance = type(uint256).max;
        v.startingBalance  = startingBalances[uint256(rebalanceAsset)];

        uint256 previousBalance;

        for (uint256 i = 0; i < 256; i++) {
            uint256 examineBalance;
            if ((examineBalance = (v.maximum + v.minimum) / 2) == previousBalance) break;

            currentBalances[uint256(rebalanceAsset)] = examineBalance;

            uint256 amountThreePool = metaPool.get_dy(
                int128(uint128(uint256(MetaPoolAsset.ALUSD))),
                int128(uint128(uint256(MetaPoolAsset.THREE_POOL))),
                10**decimals,
                currentBalances
            );

            uint256 exchangeRate = threePool.calc_withdraw_one_coin(
                amountThreePool,
                int128(uint128(uint256(targetExchangeAsset)))
            );

            uint256 distance = abs(exchangeRate, targetExchangeRate);

            if (distance < v.minimumDistance) {
                v.minimumDistance  = distance;
                v.minimizedBalance = examineBalance;
            } else if(distance == v.minimumDistance) {
                uint256 examineDelta = abs(examineBalance, v.startingBalance);
                uint256 currentDelta = abs(v.minimizedBalance, v.startingBalance);
                v.minimizedBalance = currentDelta > examineDelta ? examineBalance : v.minimizedBalance;
            }

            if (exchangeRate > targetExchangeRate) {
                if (rebalanceAsset == MetaPoolAsset.ALUSD) {
                    v.minimum = examineBalance;
                } else {
                    v.maximum = examineBalance;
                }
            } else {
                if (rebalanceAsset == MetaPoolAsset.ALUSD) {
                    v.maximum = examineBalance;
                } else {
                    v.minimum = examineBalance;
                }
            }

            previousBalance = examineBalance;
        }

        return v.minimizedBalance > v.startingBalance
            ? (v.minimizedBalance - v.startingBalance, true)
            : (v.startingBalance - v.minimizedBalance, false);
    }

    
    ///
    
    
    function claimableRewards() public view returns (uint256 amountCurve, uint256 amountConvex) {
        amountCurve  = convexRewards.earned(address(this));
        amountConvex = _getEarnedConvex(amountCurve);
    }

    
    ///
    
    ///
    
    function getTokenForThreePoolAsset(ThreePoolAsset asset) public view returns (IERC20) {
        uint256 index = uint256(asset);
        if (index >= NUM_STABLE_COINS) {
            revert IllegalArgument("Asset index out of bounds");
        }
        return _threePoolAssetCache[index];
    }

    
    ///
    
    ///
    
    function getTokenForMetaPoolAsset(MetaPoolAsset asset) public view returns (IERC20) {
        uint256 index = uint256(asset);
        if (index >= NUM_META_COINS) {
            revert IllegalArgument("Asset index out of bounds");
        }
        return _metaPoolAssetCache[index];
    }

    
    ///
    /// The caller must be the admin. Setting the pending timelock to the zero address will stop
    /// the process of setting a new timelock.
    ///
    
    function setPendingAdmin(address value) external onlyAdmin {
        pendingAdmin = value;
        emit PendingAdminUpdated(value);
    }

    
    ///
    /// The pending admin must be set and the caller must be the pending admin. After this function
    /// is successfully executed, the admin will be set to the pending admin and the pending admin
    /// will be reset.
    function acceptAdmin() external {
        if (pendingAdmin == address(0)) {
            revert IllegalState("Pending admin unset");
        }

        if (pendingAdmin != msg.sender) {
            revert Unauthorized("Not pending admin");
        }

        admin = pendingAdmin;
        pendingAdmin = address(0);

        emit AdminUpdated(admin);
        emit PendingAdminUpdated(address(0));
    }

    
    ///
    /// The caller must be the admin.
    ///
    
    function setOperator(address value) external onlyAdmin {
        operator = value;
        emit OperatorUpdated(value);
    }

    
    ///
    
    function setRewardReceiver(address value) external onlyAdmin {
        rewardReceiver = value;
        emit RewardReceiverUpdated(value);
    }

    
    ///
    
    function setTransmuterBuffer(address value) external onlyAdmin {
        transmuterBuffer = value;
        emit TransmuterBufferUpdated(value);
    }

    
    ///         assets. The slippage has a resolution of 6 decimals.
    ///
    /// The operator is allowed to set the slippage because it is a volatile parameter that may need
    /// fine adjustment in a short time window.
    ///
    
    function setThreePoolSlippage(uint256 value) external onlyOperator {
        if (value > SLIPPAGE_PRECISION) {
            revert IllegalArgument("Slippage not in range");
        }
        threePoolSlippage = value;
        emit ThreePoolSlippageUpdated(value);
    }

    
    ///         assets. The slippage has a resolution of 6 decimals.
    ///
    /// The operator is allowed to set the slippage because it is a volatile parameter that may need
    /// fine adjustment in a short time window.
    ///
    
    function setMetaPoolSlippage(uint256 value) external onlyOperator {
        if (value > SLIPPAGE_PRECISION) {
            revert IllegalArgument("Slippage not in range");
        }
        metaPoolSlippage = value;
        emit MetaPoolSlippageUpdated(value);
    }

    
    ///
    
    ///
    
    function mintThreePoolTokens(
        uint256[NUM_STABLE_COINS] calldata amounts
    ) external lock onlyOperator returns (uint256 minted) {
        return _mintThreePoolTokens(amounts);
    }

    
    ///
    
    
    ///
    
    function mintThreePoolTokens(
        ThreePoolAsset asset,
        uint256 amount
    ) external lock onlyOperator returns (uint256 minted) {
        return _mintThreePoolTokens(asset, amount);
    }

    
    ///
    
    
    ///
    
    function burnThreePoolTokens(
        ThreePoolAsset asset,
        uint256 amount
    ) external lock onlyOperator returns (uint256 withdrawn) {
        return _burnThreePoolTokens(asset, amount);
    }

    
    ///
    
    ///
    
    function mintMetaPoolTokens(
        uint256[NUM_META_COINS] calldata amounts
    ) external lock onlyOperator returns (uint256 minted) {
        return _mintMetaPoolTokens(amounts);
    }

    
    ///
    
    
    ///
    
    function mintMetaPoolTokens(
        MetaPoolAsset asset,
        uint256 amount
    ) external lock onlyOperator returns (uint256 minted) {
        return _mintMetaPoolTokens(asset, amount);
    }

    
    ///
    
    
    ///
    
    function burnMetaPoolTokens(
        MetaPoolAsset asset,
        uint256 amount
    ) external lock onlyOperator returns (uint256 withdrawn) {
        return _burnMetaPoolTokens(asset, amount);
    }

    
    ///
    
    ///
    
    function depositMetaPoolTokens(
        uint256 amount
    ) external lock onlyOperator returns (bool success) {
        return _depositMetaPoolTokens(amount);
    }

    
    ///
    
    ///
    
    function withdrawMetaPoolTokens(
        uint256 amount
    ) external lock onlyOperator returns (bool success) {
        return _withdrawMetaPoolTokens(amount);
    }

    
    ///
    
    function claimRewards() external lock onlyOperator returns (bool success) {
        success = convexRewards.getReward();

        uint256 curveBalance  = curveToken.balanceOf(address(this));
        uint256 convexBalance = convexToken.balanceOf(address(this));

        SafeERC20.safeTransfer(address(curveToken), rewardReceiver, curveBalance);
        SafeERC20.safeTransfer(address(convexToken), rewardReceiver, convexBalance);

        emit ClaimRewards(success, curveBalance, convexBalance);
    }

    
    ///         minting meta pool tokens using the 3pool tokens, and then depositing the meta pool
    ///         tokens into convex.
    ///
    /// This function is provided for ease of use.
    ///
    
    ///
    
    function flush(
        uint256[NUM_STABLE_COINS] calldata amounts
    ) external lock onlyOperator returns (uint256) {
        uint256 mintedThreePoolTokens = _mintThreePoolTokens(amounts);

        uint256 mintedMetaPoolTokens = _mintMetaPoolTokens(
            MetaPoolAsset.THREE_POOL,
            mintedThreePoolTokens
        );

        if (!_depositMetaPoolTokens(mintedMetaPoolTokens)) {
            revert IllegalState("Deposit into convex failed");
        }

        return mintedMetaPoolTokens;
    }

    
    ///         minting meta pool tokens using the 3pool tokens, and then depositing the meta pool
    ///         tokens into convex.
    ///
    /// This function is provided for ease of use.
    ///
    
    
    ///
    
    function flush(
        ThreePoolAsset asset,
        uint256 amount
    ) external lock onlyOperator returns (uint256) {
        uint256 mintedThreePoolTokens = _mintThreePoolTokens(asset, amount);

        uint256 mintedMetaPoolTokens = _mintMetaPoolTokens(
            MetaPoolAsset.THREE_POOL,
            mintedThreePoolTokens
        );

        if (!_depositMetaPoolTokens(mintedMetaPoolTokens)) {
            revert IllegalState("Deposit into convex failed");
        }

        return mintedMetaPoolTokens;
    }

    
    ///         convex, burning the meta pool tokens for 3pool tokens, and then burning the 3pool
    ///         tokens for an asset.
    ///
    /// This function is provided for ease of use.
    ///
    
    
    ///
    
    function recall(
        ThreePoolAsset asset,
        uint256 amount
    ) external lock onlyOperator returns (uint256) {
        if (!_withdrawMetaPoolTokens(amount)) {
            revert IllegalState("Withdraw from convex failed");
        }
        uint256 withdrawnThreePoolTokens = _burnMetaPoolTokens(MetaPoolAsset.THREE_POOL, amount);
        return _burnThreePoolTokens(asset, withdrawnThreePoolTokens);
    }

    
    ///
    
    
    function reclaimThreePoolAsset(ThreePoolAsset asset, uint256 amount) public lock onlyAdmin {
        IERC20 token = getTokenForThreePoolAsset(asset);
        SafeERC20.safeTransfer(address(token), transmuterBuffer, amount);

        IERC20TokenReceiver(transmuterBuffer).onERC20Received(address(token), amount);

        emit ReclaimThreePoolAsset(asset, amount);
    }

    
    ///
    
    
    function sweep(address token, uint256 amount) external lock onlyAdmin {
        SafeERC20.safeTransfer(address(token), msg.sender, amount);
    }

    
    ///
    
    function onERC20Received(address token, uint256 value) external { /* noop */ }

    
    ///
    
    ///
    
    function _getEarnedConvex(uint256 amountCurve) internal view returns (uint256) {
        uint256 supply      = convexToken.totalSupply();
        uint256 cliff       = supply / convexToken.reductionPerCliff();
        uint256 totalCliffs = convexToken.totalCliffs();

        if (cliff >= totalCliffs) return 0;

        uint256 reduction = totalCliffs - cliff;
        uint256 earned    = amountCurve * reduction / totalCliffs;

        uint256 available = convexToken.maxSupply() - supply;
        return earned > available ? available : earned;
    }

    
    ///
    
    ///
    
    function _mintThreePoolTokens(
        uint256[NUM_STABLE_COINS] calldata amounts
    ) internal returns (uint256 minted) {
        IERC20[NUM_STABLE_COINS] memory tokens = _threePoolAssetCache;

        IERC20 threePoolToken = getTokenForMetaPoolAsset(MetaPoolAsset.THREE_POOL);

        uint256 threePoolDecimals = SafeERC20.expectDecimals(address(threePoolToken));
        uint256 normalizedTotal   = 0;

        for (uint256 i = 0; i < NUM_STABLE_COINS; i++) {
            if (amounts[i] == 0) continue;

            uint256 tokenDecimals   = SafeERC20.expectDecimals(address(tokens[i]));
            uint256 missingDecimals = threePoolDecimals - tokenDecimals;

            normalizedTotal += amounts[i] * 10**missingDecimals;

            // For assets like USDT, the approval must be first set to zero before updating it.
            SafeERC20.safeApprove(address(tokens[i]), address(threePool), 0);
            SafeERC20.safeApprove(address(tokens[i]), address(threePool), amounts[i]);
        }

        // Calculate what the normalized value of the tokens is.
        uint256 expectedOutput = normalizedTotal * CURVE_PRECISION / threePool.get_virtual_price();

        // Calculate the minimum amount of 3pool lp tokens that we are expecting out when
        // adding liquidity for all of the assets. This value is based off the optimistic
        // assumption that one of each token is approximately equal to one 3pool lp token.
        uint256 minimumMintAmount = expectedOutput * threePoolSlippage / SLIPPAGE_PRECISION;

        // Record the amount of 3pool lp tokens that we start with before adding liquidity
        // so that we can determine how many we minted.
        uint256 startingBalance = threePoolToken.balanceOf(address(this));

        // Add the liquidity to the pool.
        threePool.add_liquidity(amounts, minimumMintAmount);

        // Calculate how many 3pool lp tokens were minted.
        minted = threePoolToken.balanceOf(address(this)) - startingBalance;

        emit MintThreePoolTokens(amounts, minted);
    }

    
    ///
    
    
    ///
    
    function _mintThreePoolTokens(
        ThreePoolAsset asset,
        uint256 amount
    ) internal returns (uint256 minted) {
        IERC20 token          = getTokenForThreePoolAsset(asset);
        IERC20 threePoolToken = getTokenForMetaPoolAsset(MetaPoolAsset.THREE_POOL);

        uint256 threePoolDecimals = SafeERC20.expectDecimals(address(threePoolToken));
        uint256 missingDecimals   = threePoolDecimals - SafeERC20.expectDecimals(address(token));

        uint256[NUM_STABLE_COINS] memory amounts;
        amounts[uint256(asset)] = amount;

        // Calculate the minimum amount of 3pool lp tokens that we are expecting out when
        // adding single sided liquidity. This value is based off the optimistic assumption that
        // one of each token is approximately equal to one 3pool lp token.
        uint256 normalizedAmount  = amount * 10**missingDecimals;
        uint256 expectedOutput    = normalizedAmount * CURVE_PRECISION / threePool.get_virtual_price();
        uint256 minimumMintAmount = expectedOutput * threePoolSlippage / SLIPPAGE_PRECISION;

        // Record the amount of 3pool lp tokens that we start with before adding liquidity
        // so that we can determine how many we minted.
        uint256 startingBalance = threePoolToken.balanceOf(address(this));

        // For assets like USDT, the approval must be first set to zero before updating it.
        SafeERC20.safeApprove(address(token), address(threePool), 0);
        SafeERC20.safeApprove(address(token), address(threePool), amount);

        // Add the liquidity to the pool.
        threePool.add_liquidity(amounts, minimumMintAmount);

        // Calculate how many 3pool lp tokens were minted.
        minted = threePoolToken.balanceOf(address(this)) - startingBalance;

        emit MintThreePoolTokens(asset, amount, minted);
    }

    
    ///
    
    
    ///
    
    function _burnThreePoolTokens(
        ThreePoolAsset asset,
        uint256 amount
    ) internal returns (uint256 withdrawn) {
        IERC20 token          = getTokenForThreePoolAsset(asset);
        IERC20 threePoolToken = getTokenForMetaPoolAsset(MetaPoolAsset.THREE_POOL);

        uint256 index = uint256(asset);

        uint256 threePoolDecimals = SafeERC20.expectDecimals(address(threePoolToken));
        uint256 missingDecimals   = threePoolDecimals - SafeERC20.expectDecimals(address(token));

        // Calculate the minimum amount of underlying tokens that we are expecting out when
        // removing single sided liquidity. This value is based off the optimistic assumption that
        // one of each token is approximately equal to one 3pool lp token.
        uint256 normalizedAmount = amount * threePoolSlippage / SLIPPAGE_PRECISION;
        uint256 expectedOutput   = normalizedAmount * threePool.get_virtual_price() / CURVE_PRECISION;
        uint256 minimumAmountOut = expectedOutput / 10**missingDecimals;

        // Record the amount of underlying tokens that we start with before removing liquidity
        // so that we can determine how many we withdrew from the pool.
        uint256 startingBalance = token.balanceOf(address(this));

        SafeERC20.safeApprove(address(threePoolToken), address(threePool), 0);
        SafeERC20.safeApprove(address(threePoolToken), address(threePool), amount);

        // Remove the liquidity from the pool.
        threePool.remove_liquidity_one_coin(amount, int128(uint128(index)), minimumAmountOut);

        // Calculate how many underlying tokens that were withdrawn.
        withdrawn = token.balanceOf(address(this)) - startingBalance;

        emit BurnThreePoolTokens(asset, amount, withdrawn);
    }

    
    ///
    
    ///
    
    function _mintMetaPoolTokens(
        uint256[NUM_META_COINS] calldata amounts
    ) internal returns (uint256 minted) {
        IERC20[NUM_META_COINS] memory tokens = _metaPoolAssetCache;

        uint256 total = 0;
        for (uint256 i = 0; i < NUM_META_COINS; i++) {
            if (amounts[i] == 0) continue;

            total += amounts[i];

            // For assets like USDT, the approval must be first set to zero before updating it.
            SafeERC20.safeApprove(address(tokens[i]), address(metaPool), 0);
            SafeERC20.safeApprove(address(tokens[i]), address(metaPool), amounts[i]);
        }

        // Calculate the minimum amount of 3pool lp tokens that we are expecting out when
        // adding liquidity for all of the assets. This value is based off the optimistic
        // assumption that one of each token is approximately equal to one 3pool lp token.
        uint256 expectedOutput    = total * CURVE_PRECISION / metaPool.get_virtual_price();
        uint256 minimumMintAmount = expectedOutput * metaPoolSlippage / SLIPPAGE_PRECISION;

        // Add the liquidity to the pool.
        minted = metaPool.add_liquidity(amounts, minimumMintAmount);

        emit MintMetaPoolTokens(amounts, minted);
    }

    
    ///
    
    
    ///
    
    function _mintMetaPoolTokens(
        MetaPoolAsset asset,
        uint256 amount
    ) internal returns (uint256 minted) {
        IERC20 token = getTokenForMetaPoolAsset(asset);

        uint256[NUM_META_COINS] memory amounts;
        amounts[uint256(asset)] = amount;

        // Calculate the minimum amount of 3pool lp tokens that we are expecting out when
        // adding single sided liquidity. This value is based off the optimistic assumption that
        uint256 minimumMintAmount = amount * metaPoolSlippage / SLIPPAGE_PRECISION;

        // For assets like USDT, the approval must be first set to zero before updating it.
        SafeERC20.safeApprove(address(token), address(metaPool), 0);
        SafeERC20.safeApprove(address(token), address(metaPool), amount);

        // Add the liquidity to the pool.
        minted = metaPool.add_liquidity(amounts, minimumMintAmount);

        emit MintMetaPoolTokens(asset, amount, minted);
    }

    
    ///
    
    
    ///
    
    function _burnMetaPoolTokens(
        MetaPoolAsset asset,
        uint256 amount
    ) internal returns (uint256 withdrawn) {
        uint256 index = uint256(asset);

        // Calculate the minimum amount of the meta pool asset that we are expecting out when
        // removing single sided liquidity. This value is based off the optimistic assumption that
        // one of each token is approximately equal to one meta pool lp token.
        uint256 expectedOutput   = amount * metaPool.get_virtual_price() / CURVE_PRECISION;
        uint256 minimumAmountOut = expectedOutput * metaPoolSlippage / SLIPPAGE_PRECISION;

        // Remove the liquidity from the pool.
        withdrawn = metaPool.remove_liquidity_one_coin(
            amount,
            int128(uint128(index)),
            minimumAmountOut
        );

        emit BurnMetaPoolTokens(asset, amount, withdrawn);
    }

    
    ///
    
    ///
    
    function _depositMetaPoolTokens(uint256 amount) internal returns (bool success) {
        SafeERC20.safeApprove(address(metaPool), address(convexBooster), 0);
        SafeERC20.safeApprove(address(metaPool), address(convexBooster), amount);

        success = convexBooster.deposit(convexPoolId, amount, true /* always stake into rewards */);

        emit DepositMetaPoolTokens(amount, success);
    }

    
    ///
    
    ///
    
    function _withdrawMetaPoolTokens(uint256 amount) internal returns (bool success) {
        success = convexRewards.withdrawAndUnwrap(amount, false /* never claim */);
        emit WithdrawMetaPoolTokens(amount, success);
    }

    
    ///
    
    function _claimRewards() internal returns (bool success) {
        success = convexRewards.getReward();

        uint256 curveBalance  = curveToken.balanceOf(address(this));
        uint256 convexBalance = convexToken.balanceOf(address(this));

        SafeERC20.safeTransfer(address(curveToken), rewardReceiver, curveBalance);
        SafeERC20.safeTransfer(address(convexToken), rewardReceiver, convexBalance);

        emit ClaimRewards(success, curveBalance, convexBalance);
    }

    
    ///
    
    
    ///
    
    function min(uint256 x , uint256 y) private pure returns (uint256) {
        return x > y ? y : x;
    }

    
    ///
    
    
    ///
    
    function abs(uint256 x , uint256 y) private pure returns (uint256) {
        return x > y ? x - y : y - x;
    }
}