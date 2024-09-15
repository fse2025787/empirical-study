pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2022-11-03
*/

// Sources flattened with hardhat v2.9.9 https://hardhat.org

// File src/interfaces/external/aave/IRewardsController.sol

pragma solidity >=0.8.10;

/**
 * @title IRewardsController
 * @author Aave
 * @notice Defines the basic interface for a Rewards Controller.
 */
interface IRewardsController {

  /**
   * @dev Whitelists an address to claim the rewards on behalf of another address
   * @param user The address of the user
   * @param claimer The address of the claimer
   */
  function setClaimer(address user, address claimer) external;

  /**
   * @dev Get the price aggregator oracle address
   * @param reward The address of the reward
   * @return The price oracle of the reward
   */
  function getRewardOracle(address reward) external view returns (address);

  /**
   * @dev Returns the whitelisted claimer for a certain address (0x0 if not set)
   * @param user The address of the user
   * @return The claimer address
   */
  function getClaimer(address user) external view returns (address);

  /**
   * @dev Returns the Transfer Strategy implementation contract address being used for a reward address
   * @param reward The address of the reward
   * @return The address of the TransferStrategy contract
   */
  function getTransferStrategy(address reward) external view returns (address);

  /**
   * @dev Called by the corresponding asset on any update that affects the rewards distribution
   * @param user The address of the user
   * @param userBalance The user balance of the asset
   * @param totalSupply The total supply of the asset
   **/
  function handleAction(
    address user,
    uint256 userBalance,
    uint256 totalSupply
  ) external;

  /**
   * @dev Claims reward for a user to the desired address, on all the assets of the pool, accumulating the pending rewards
   * @param assets List of assets to check eligible distributions before claiming rewards
   * @param amount The amount of rewards to claim
   * @param to The address that will be receiving the rewards
   * @param reward The address of the reward token
   * @return The amount of rewards claimed
   **/
  function claimRewards(
    address[] calldata assets,
    uint256 amount,
    address to,
    address reward
  ) external returns (uint256);

  /**
   * @dev Returns a single rewards balance of a user, including virtually accrued and unrealized claimable rewards.
   * @param assets List of incentivized assets to check eligible distributions
   * @param user The address of the user
   * @param reward The address of the reward token
   * @return The rewards amount
   **/
  function getUserRewards(
    address[] calldata assets,
    address user,
    address reward
  ) external view returns (uint256);

  /**
   * @dev Claims reward for a user on behalf, on all the assets of the pool, accumulating the pending rewards. The
   * caller must be whitelisted via "allowClaimOnBehalf" function by the RewardsAdmin role manager
   * @param assets The list of assets to check eligible distributions before claiming rewards
   * @param amount The amount of rewards to claim
   * @param user The address to check and claim rewards
   * @param to The address that will be receiving the rewards
   * @param reward The address of the reward token
   * @return The amount of rewards claimed
   **/
  function claimRewardsOnBehalf(
    address[] calldata assets,
    uint256 amount,
    address user,
    address to,
    address reward
  ) external returns (uint256);

  /**
   * @dev Claims reward for msg.sender, on all the assets of the pool, accumulating the pending rewards
   * @param assets The list of assets to check eligible distributions before claiming rewards
   * @param amount The amount of rewards to claim
   * @param reward The address of the reward token
   * @return The amount of rewards claimed
   **/
  function claimRewardsToSelf(
    address[] calldata assets,
    uint256 amount,
    address reward
  ) external returns (uint256);

  /**
   * @dev Claims all rewards for a user to the desired address, on all the assets of the pool, accumulating the pending rewards
   * @param assets The list of assets to check eligible distributions before claiming rewards
   * @param to The address that will be receiving the rewards
   * @return rewardsList List of addresses of the reward tokens
   * @return claimedAmounts List that contains the claimed amount per reward, following same order as "rewardList"
   **/
  function claimAllRewards(address[] calldata assets, address to)
    external
    returns (address[] memory rewardsList, uint256[] memory claimedAmounts);

  /**
   * @dev Claims all rewards for a user on behalf, on all the assets of the pool, accumulating the pending rewards. The caller must
   * be whitelisted via "allowClaimOnBehalf" function by the RewardsAdmin role manager
   * @param assets The list of assets to check eligible distributions before claiming rewards
   * @param user The address to check and claim rewards
   * @param to The address that will be receiving the rewards
   * @return rewardsList List of addresses of the reward tokens
   * @return claimedAmounts List that contains the claimed amount per reward, following same order as "rewardsList"
   **/
  function claimAllRewardsOnBehalf(
    address[] calldata assets,
    address user,
    address to
  ) external returns (address[] memory rewardsList, uint256[] memory claimedAmounts);

  /**
   * @dev Claims all reward for msg.sender, on all the assets of the pool, accumulating the pending rewards
   * @param assets The list of assets to check eligible distributions before claiming rewards
   * @return rewardsList List of addresses of the reward tokens
   * @return claimedAmounts List that contains the claimed amount per reward, following same order as "rewardsList"
   **/
  function claimAllRewardsToSelf(address[] calldata assets)
    external
    returns (address[] memory rewardsList, uint256[] memory claimedAmounts);


  /**
   * @dev Returns the accrued rewards balance of a user, not including virtually accrued rewards since last distribution.
   * @param user The address of the user
   * @param reward The address of the reward token
   * @return Unclaimed rewards, not including new distributions
   **/
  function getUserAccruedRewards(address user, address reward) external view returns (uint256);
}


// File src/interfaces/IRewardCollector.sol

pragma solidity ^0.8.13;

interface IRewardCollector {
    
    ///
    
    function version() external view returns (string memory);

    
    ///
    
    function rewardToken() external view returns (address);

    
    ///
    
    function swapRouter() external view returns (address);

    
    ///
    
    function debtToken() external view returns (address);

    
    ///
    
    
    ///
    
    function claimAndDistributeRewards(address token, uint256 minimumAmountOut) external returns (uint256 claimed);
}


// File src/interfaces/external/velodrome/IVelodromeSwapRouter.sol

pragma solidity >=0.5.0;


interface IVelodromeSwapRouter {
    struct route {
        address from;
        address to;
        bool stable;
    }
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        route[] calldata routes,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsOut(
        uint amountIn,
        route[] memory routes
    ) external view returns (uint[] memory amounts);
}


// File lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

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


// File src/interfaces/external/aave/IScaledBalanceToken.sol

pragma solidity >=0.5.0;

interface IScaledBalanceToken {
  
  ///      divided by the reserve's liquidity index at the moment of the update.
  ///
  
  ///
  
  function scaledBalanceOf(address user) external view returns (uint256);

  
  ///
  
  ///
  
  
  function getScaledUserBalanceAndSupply(address user)
    external view
    returns (
      uint256 scaledBalance,
      uint256 scaledTotalSupply
    );

  
  ///
  
  function scaledTotalSupply() external view returns (uint256);
}


// File src/interfaces/external/aave/DataTypes.sol

pragma solidity >=0.5.0;

// @dev Refer to the whitepaper, section 1.1 basic concepts for a formal description of these properties.
struct ReserveData {
  // Stores the reserve configuration.
  ReserveConfigurationMap configuration;
  // The liquidity index. Expressed in ray.
  uint128 liquidityIndex;
  // Variable borrow index. Expressed in ray.
  uint128 variableBorrowIndex;
  // The current supply rate. Expressed in ray.
  uint128 currentLiquidityRate;
  // The current variable borrow rate. Expressed in ray.
  uint128 currentVariableBorrowRate;
  // The current stable borrow rate. Expressed in ray.
  uint128 currentStableBorrowRate;
  uint40 lastUpdateTimestamp;
  // Tokens addresses.
  address aTokenAddress;
  address stableDebtTokenAddress;
  address variableDebtTokenAddress;
  // Address of the interest rate strategy.
  address interestRateStrategyAddress;
  // The id of the reserve. Represents the position in the list of the active reserves.
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


// File src/interfaces/external/aave/ILendingPoolAddressesProvider.sol

pragma solidity >=0.5.0;



///

///
/// - Acting also as factory of proxies and admin of those, so with right to change its implementations.
/// - Owned by the Aave Governance.
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


// File src/interfaces/external/aave/ILendingPool.sol

pragma solidity >=0.5.0;

interface ILendingPool {
  
  ///
  
  
  
  
  
  event Deposit(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint16 indexed referral
  );

  
  ///
  
  
  
  
  event Withdraw(address indexed reserve, address indexed user, address indexed to, uint256 amount);
  
  
  ///
  
  
  ///                       initiator of the transaction on `flashLoan`.
  
  
  
  
  
  event Borrow(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint256 borrowRateMode,
    uint256 borrowRate,
    uint16 indexed referral
  );

  
  ///
  
  
  
  
  event Repay(address indexed reserve, address indexed user, address indexed repayer, uint256 amount);
  
  
  ///
  
  
  
  event Swap(address indexed reserve, address indexed user, uint256 rateMode);
  
  
  ///
  
  
  event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);

  
  ///
  
  
  event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);
  
  
  ///
  
  
  event RebalanceStableBorrowRate(address indexed reserve, address indexed user);

  
  ///
  
  
  
  
  
  
  event FlashLoan(
    address indexed target,
    address indexed initiator,
    address indexed asset,
    uint256 amount,
    uint256 premium,
    uint16 referralCode
  );

  
  event Paused();

  
  event Unpaused();

  
  ///      manager using a DELEGATECALL.
  ///
  /// This allows to have the events in the generated ABI for LendingPool.
  ///
  
  ///                                   the liquidation.
  
  
  
  
  
  
  ///                                   he wants to receive the underlying collateral asset directly.
  event LiquidationCall(
    address indexed collateralAsset,
    address indexed debtAsset,
    address indexed user,
    uint256 debtToCover,
    uint256 liquidatedCollateralAmount,
    address liquidator,
    bool receiveAToken
  );

  
  ///
  /// NOTE: This event is actually declared in the ReserveLogic library and emitted in the `updateInterestRates`
  /// function. Since the function is internal, the event will actually be fired by the LendingPool contract. The event
  /// is therefore replicated here so it gets added to the LendingPool ABI.
  ///
  
  
  
  
  
  
  event ReserveDataUpdated(
    address indexed reserve,
    uint256 liquidityRate,
    uint256 stableBorrowRate,
    uint256 variableBorrowRate,
    uint256 liquidityIndex,
    uint256 variableBorrowIndex
  );

  
  ///
  /// - E.g. User deposits 100 USDC and gets in return 100 aUSDC.
  ///
  
  
  
  ///                     them on his own wallet, or a different address if the beneficiary of aTokens is a different
  ///                     wallet.
  
  ///                     action is executed directly by the user, without any middle-man
  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;

  
  ///
  /// E.g. User has 100 aUSDC, calls `withdraw` and receives 100 USDC, burning the 100 aUSDC.
  ///
  
  
  
  ///               own wallet, or a different address if the beneficiary is a different wallet.
  ///
  
  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256 amountWithdrawn);

  
  ///     already deposited enough collateral, or he was given enough allowance by a credit delegator on the
  ///     corresponding debt token (StableDebtToken or VariableDebtToken).
  ///
  /// - E.g. User borrows 100 USDC passing as `onBehalfOf` his own address, receiving the 100 USDC in his wallet and
  ///   100 stable/variable debt tokens, depending on the `interestRateMode`.
  ///
  
  
  
  
  ///                         0 if the action is executed directly by the user, without any middle-man
  
  ///                         itself calling the function if he wants to borrow against his own collateral, or the
  ///                         address of the credit delegator if he has been given credit delegation allowance
  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referralCode,
    address onBehalfOf
  ) external;

  
  ///
  /// - E.g. User repays 100 USDC, burning 100 variable/stable debt tokens of the `onBehalfOf` address.
  ///
  
  
  
  
  ///                   calling the function if he wants to reduce/remove his own debt, or the address of any other
  ///                   other borrower whose debt should be removed.
  ///
  
  function repay(
    address asset,
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external returns (uint256 amountRepaid);

  
  ///
  
  
  function swapBorrowRateMode(address asset, uint256 rateMode) external;

  
  ///
  /// - Users can be rebalanced if the following conditions are satisfied:
  ///   1. Usage ratio is above 95%
  ///   2. the current deposit APY is below REBALANCE_UP_THRESHOLD  maxVariableBorrowRate, which means that too much
  ///      has been borrowed at a stable rate and depositors are not earning enough.
  ///
  
  
  function rebalanceStableBorrowRate(address asset, address user) external;

  
  ///
  
  
  function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;
  
  
  ///
  /// - The caller (liquidator) covers `debtToCover` amount of debt of the user getting liquidated, and receives a
  ///   proportionally amount of the `collateralAsset` plus a bonus to cover market risk.
  ///
  
  ///                        liquidation.
  
  
  
  
  ///                        receive the underlying collateral asset directly
  function liquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256 debtToCover,
    bool receiveAToken
  ) external;

  
  ///      taken plus a fee is returned.
  ///
  /// IMPORTANT There are security concerns for developers of flash loan receiver contracts that must be kept into
  /// consideration.
  ///
  /// For further details please visit https://developers.aave.com.
  ///
  
  ///                        interface.
  
  
  
  
  
  
  ///                        if the action is executed directly by the user, without any middle-man
  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referralCode
  ) external;

  
  ///
  
  ///
  
  
  
  
  
  
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

    /**
   * @notice Supplies an `amount` of underlying asset into the reserve, receiving in return overlying aTokens.
   * - E.g. User supplies 100 USDC and gets in return 100 aUSDC
   * @param asset The address of the underlying asset to supply
   * @param amount The amount to be supplied
   * @param onBehalfOf The address that will receive the aTokens, same as msg.sender if the user
   *   wants to receive them on his own wallet, or a different address if the beneficiary of aTokens
   *   is a different wallet
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the action is executed directly by the user, without any middle-man
   **/
  function supply(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;

  function setReserveInterestRateStrategyAddress(address reserve, address rateStrategyAddress) external;

  function setConfiguration(address reserve, uint256 configuration) external;

  
  ///
  
  ///
  
  function getConfiguration(address asset) external view returns (ReserveConfigurationMap memory);

  
  ///
  
  ///
  
  function getUserConfiguration(address user) external view returns (UserConfigurationMap memory);
  
  
  ///
  
  ///
  
  function getReserveNormalizedIncome(address asset) external view returns (uint256);

  
  ///
  
  ///
  
  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);

  
  ///
  
  ///
  
  function getReserveData(address asset) external view returns (ReserveData memory);

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


// File src/interfaces/external/aave/IAaveIncentivesController.sol

pragma solidity >=0.5.0;


interface IAaveIncentivesController {
  event RewardsAccrued(address indexed user, uint256 amount);

  event RewardsClaimed(address indexed user, address indexed to, uint256 amount);

  event RewardsClaimed(
    address indexed user,
    address indexed to,
    address indexed claimer,
    uint256 amount
  );

  event ClaimerSet(address indexed user, address indexed claimer);

  /*
   * @dev Returns the configuration of the distribution for a certain asset
   * @param asset The address of the reference asset of the distribution
   * @return The asset index, the emission per second and the last updated timestamp
   **/
  function getAssetData(address asset)
    external
    view
    returns (
      uint256,
      uint256,
      uint256
    );

  /**
   * @dev Whitelists an address to claim the rewards on behalf of another address
   * @param user The address of the user
   * @param claimer The address of the claimer
   */
  function setClaimer(address user, address claimer) external;

  /**
   * @dev Returns the whitelisted claimer for a certain address (0x0 if not set)
   * @param user The address of the user
   * @return The claimer address
   */
  function getClaimer(address user) external view returns (address);

  /**
   * @dev Configure assets for a certain rewards emission
   * @param assets The assets to incentivize
   * @param emissionsPerSecond The emission for each asset
   */
  function configureAssets(address[] calldata assets, uint256[] calldata emissionsPerSecond)
    external;

  /**
   * @dev Called by the corresponding asset on any update that affects the rewards distribution
   * @param asset The address of the user
   * @param userBalance The balance of the user of the asset in the lending pool
   * @param totalSupply The total supply of the asset in the lending pool
   **/
  function handleAction(
    address asset,
    uint256 userBalance,
    uint256 totalSupply
  ) external;

  /**
   * @dev Returns the total of rewards of an user, already accrued + not yet accrued
   * @param user The address of the user
   * @return The rewards
   **/
  function getRewardsBalance(address[] calldata assets, address user)
    external
    view
    returns (uint256);

  /**
   * @dev Claims reward for an user, on all the assets of the lending pool, accumulating the pending rewards
   * @param amount Amount of rewards to claim
   * @param to Address that will be receiving the rewards
   * @return Rewards claimed
   **/
  function claimRewards(
    address[] calldata assets,
    uint256 amount,
    address to
  ) external returns (uint256);

  /**
   * @dev Claims reward for an user on behalf, on all the assets of the lending pool, accumulating the pending rewards. The caller must
   * be whitelisted via "allowClaimOnBehalf" function by the RewardsAdmin role manager
   * @param amount Amount of rewards to claim
   * @param user Address to check and claim rewards
   * @param to Address that will be receiving the rewards
   * @return Rewards claimed
   **/
  function claimRewardsOnBehalf(
    address[] calldata assets,
    uint256 amount,
    address user,
    address to
  ) external returns (uint256);

  /**
   * @dev returns the unclaimed rewards of the user
   * @param user the address of the user
   * @return the unclaimed user rewards
   */
  function getUserUnclaimedRewards(address user) external view returns (uint256);

  /**
   * @dev returns the unclaimed rewards of the user
   * @param user the address of the user
   * @param asset The asset to incentivize
   * @return the user index for the asset
   */
  function getUserAssetData(address user, address asset) external view returns (uint256);

  /**
   * @dev for backward compatibility with previous implementation of the Incentives controller
   */
  function REWARD_TOKEN() external view returns (address);

  /**
   * @dev for backward compatibility with previous implementation of the Incentives controller
   */
  function PRECISION() external view returns (uint8);
}


// File src/interfaces/external/aave/IInitializableAToken.sol

pragma solidity >=0.5.0;


/**
 * @title IInitializableAToken
 * @notice Interface for the initialize function on AToken
 * @author Aave
 **/
interface IInitializableAToken {
  /**
   * @dev Emitted when an aToken is initialized
   * @param underlyingAsset The address of the underlying asset
   * @param pool The address of the associated lending pool
   * @param treasury The address of the treasury
   * @param incentivesController The address of the incentives controller for this aToken
   * @param aTokenDecimals the decimals of the underlying
   * @param aTokenName the name of the aToken
   * @param aTokenSymbol the symbol of the aToken
   * @param params A set of encoded parameters for additional initialization
   **/
  event Initialized(
    address indexed underlyingAsset,
    address indexed pool,
    address treasury,
    address incentivesController,
    uint8 aTokenDecimals,
    string aTokenName,
    string aTokenSymbol,
    bytes params
  );

  /**
   * @dev Initializes the aToken
   * @param pool The address of the lending pool where this aToken will be used
   * @param treasury The address of the Aave treasury, receiving the fees on this aToken
   * @param underlyingAsset The address of the underlying asset of this aToken (E.g. WETH for aWETH)
   * @param incentivesController The smart contract managing potential incentives distribution
   * @param aTokenDecimals The decimals of the aToken, same as the underlying asset's
   * @param aTokenName The name of the aToken
   * @param aTokenSymbol The symbol of the aToken
   */
  function initialize(
    ILendingPool pool,
    address treasury,
    address underlyingAsset,
    IAaveIncentivesController incentivesController,
    uint8 aTokenDecimals,
    string calldata aTokenName,
    string calldata aTokenSymbol,
    bytes calldata params
  ) external;
}


// File src/interfaces/external/aave/IAToken.sol

pragma solidity >=0.5.0;




interface IAToken is IERC20, IScaledBalanceToken, IInitializableAToken {
  /**
   * @dev Emitted after the mint action
   * @param from The address performing the mint
   * @param value The amount being
   * @param index The new liquidity index of the reserve
   **/
  event Mint(address indexed from, uint256 value, uint256 index);

  /**
   * @dev Mints `amount` aTokens to `user`
   * @param user The address receiving the minted tokens
   * @param amount The amount of tokens getting minted
   * @param index The new liquidity index of the reserve
   * @return `true` if the the previous balance of the user was 0
   */
  function mint(
    address user,
    uint256 amount,
    uint256 index
  ) external returns (bool);

  /**
   * @dev Emitted after aTokens are burned
   * @param from The owner of the aTokens, getting them burned
   * @param target The address that will receive the underlying
   * @param value The amount being burned
   * @param index The new liquidity index of the reserve
   **/
  event Burn(address indexed from, address indexed target, uint256 value, uint256 index);

  /**
   * @dev Emitted during the transfer action
   * @param from The user whose tokens are being transferred
   * @param to The recipient
   * @param value The amount being transferred
   * @param index The new liquidity index of the reserve
   **/
  event BalanceTransfer(address indexed from, address indexed to, uint256 value, uint256 index);

  /**
   * @dev Burns aTokens from `user` and sends the equivalent amount of underlying to `receiverOfUnderlying`
   * @param user The owner of the aTokens, getting them burned
   * @param receiverOfUnderlying The address that will receive the underlying
   * @param amount The amount being burned
   * @param index The new liquidity index of the reserve
   **/
  function burn(
    address user,
    address receiverOfUnderlying,
    uint256 amount,
    uint256 index
  ) external;

  /**
   * @dev Mints aTokens to the reserve treasury
   * @param amount The amount of tokens getting minted
   * @param index The new liquidity index of the reserve
   */
  function mintToTreasury(uint256 amount, uint256 index) external;

  /**
   * @dev Transfers aTokens in the event of a borrow being liquidated, in case the liquidators reclaims the aToken
   * @param from The address getting liquidated, current owner of the aTokens
   * @param to The recipient
   * @param value The amount of tokens getting transferred
   **/
  function transferOnLiquidation(
    address from,
    address to,
    uint256 value
  ) external;

  /**
   * @dev Transfers the underlying asset to `target`. Used by the LendingPool to transfer
   * assets in borrow(), withdraw() and flashLoan()
   * @param user The recipient of the underlying
   * @param amount The amount getting transferred
   * @return The amount transferred
   **/
  function transferUnderlyingTo(address user, uint256 amount) external returns (uint256);

  /**
   * @dev Invoked to execute actions on the aToken side after a repayment.
   * @param user The user executing the repayment
   * @param amount The amount getting repaid
   **/
  function handleRepayment(address user, uint256 amount) external;

  /**
   * @dev Returns the address of the incentives controller contract
   **/
  function getIncentivesController() external view returns (IAaveIncentivesController);

  /**
   * @dev Returns the address of the underlying asset of this aToken (E.g. WETH for aWETH)
   **/
  function UNDERLYING_ASSET_ADDRESS() external view returns (address);
}


// File src/interfaces/external/aave/IStaticAToken.sol

pragma solidity >=0.5.0;




///

///      increase automatically, but uses an ever-increasing exchange rate. Only supporting deposits and withdrawals.
interface IStaticAToken is IERC20 {
  struct SignatureParams {
    uint8 v;
    bytes32 r;
    bytes32 s;
  }

  function LENDING_POOL() external returns (ILendingPool);
  function ATOKEN() external view returns (IERC20);
  function ASSET() external returns (IERC20);

  function _nonces(address owner) external returns (uint256);

  function claimRewards() external;

  function deposit(
    address recipient,
    uint256 amount,
    uint16 referralCode,
    bool fromUnderlying
  ) external returns (uint256);

  function withdraw(
    address recipient,
    uint256 amount,
    bool toUnderlying
  ) external returns (uint256, uint256);

  function withdrawDynamicAmount(
    address recipient,
    uint256 amount,
    bool toUnderlying
  ) external returns (uint256, uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s,
    uint256 chainId
  ) external;

  function metaDeposit(
    address depositor,
    address recipient,
    uint256 value,
    uint16 referralCode,
    bool fromUnderlying,
    uint256 deadline,
    SignatureParams calldata sigParams,
    uint256 chainId
  ) external returns (uint256);

  function metaWithdraw(
    address owner,
    address recipient,
    uint256 staticAmount,
    uint256 dynamicAmount,
    bool toUnderlying,
    uint256 deadline,
    SignatureParams calldata sigParams,
    uint256 chainId
  ) external returns (uint256, uint256);

  function dynamicBalanceOf(address account) external view returns (uint256);

  
  ///      liquidity index on Aave.
  ///
  
  ///
  
  function staticToDynamicAmount(uint256 amount) external view returns (uint256 dynamicAmount);

  
  ///      function of the principal and the liquidity index.
  ///
  
  ///
  
  function dynamicToStaticAmount(uint256 amount) external view returns (uint256 staticAmount);

  
  ///      an ever-increasing exchange rate.
  ///
  
  function rate() external view returns (uint256);

  
  ///
  
  ///
  
  function getDomainSeparator(uint256 chainId) external returns (bytes32);
}


// File src/interfaces/keepers/IResolver.sol

pragma solidity ^0.8.13;

interface IResolver {
    function checker()
        external
        view
        returns (bool canExec, bytes memory execPayload);
}


// File src/interfaces/alchemist/IAlchemistV2Actions.sol

pragma solidity >=0.5.0;



///

interface IAlchemistV2Actions {
    
    ///
    /// **_NOTE:_** This function is WHITELISTED.
    ///
    
    
    function approveMint(address spender, uint256 amount) external;

    
    ///
    
    ///
    
    
    
    function approveWithdraw(
        address spender,
        address yieldToken,
        uint256 shares
    ) external;

    
    ///
    
    function poke(address owner) external;

    
    ///
    
    ///
    
    
    
    
    
    ///
    
    ///
    
    ///
    
    ///
    
    
    
    
    
    
    
    ///
    
    
    
    ///
    
    function deposit(
        address yieldToken,
        uint256 amount,
        address recipient
    ) external returns (uint256 sharesIssued);

    
    ///
    
    ///
    
    
    
    ///
    
    ///
    
    
    ///
    
    
    
    
    
    
    ///
    
    
    
    
    ///
    
    function depositUnderlying(
        address yieldToken,
        uint256 amount,
        address recipient,
        uint256 minimumAmountOut
    ) external returns (uint256 sharesIssued);

    
    ///
    
    
    ///
    
    ///
    
    ///
    
    
    
    
    
    
    
    ///
    
    
    
    ///
    
    function withdraw(
        address yieldToken,
        uint256 shares,
        address recipient
    ) external returns (uint256 amountWithdrawn);

    
    ///
    
    ///
    
    
    ///
    
    ///
    
    ///
    
    
    
    
    
    
    
    ///
    
    
    
    
    ///
    
    function withdrawFrom(
        address owner,
        address yieldToken,
        uint256 shares,
        address recipient
    ) external returns (uint256 amountWithdrawn);

    
    ///
    
    
    
    ///
    
    ///
    
    
    ///
    
    
    
    
    
    
    
    ///
    
    
    
    
    ///
    
    function withdrawUnderlying(
        address yieldToken,
        uint256 shares,
        address recipient,
        uint256 minimumAmountOut
    ) external returns (uint256 amountWithdrawn);

    
    ///
    
    
    
    ///
    
    ///
    
    
    ///
    
    
    
    
    
    
    
    ///
    
    
    
    
    
    ///
    
    function withdrawUnderlyingFrom(
        address owner,
        address yieldToken,
        uint256 shares,
        address recipient,
        uint256 minimumAmountOut
    ) external returns (uint256 amountWithdrawn);

    
    ///
    
    
    ///
    
    ///
    
    ///
    
    
    
    
    
    ///
    
    
    function mint(uint256 amount, address recipient) external;

    
    ///
    
    
    ///
    
    ///
    
    
    ///
    
    
    
    
    
    ///
    
    
    
    function mintFrom(
        address owner,
        uint256 amount,
        address recipient
    ) external;

    
    ///
    
    ///
    
    
    
    ///
    
    ///
    
    ///
    
    
    
    
    
    ///
    
    
    ///
    
    function burn(uint256 amount, address recipient) external returns (uint256 amountBurned);

    
    ///
    
    ///
    
    
    
    
    ///
    
    
    ///
    
    
    
    
    
    
    ///
    
    
    
    ///
    
    function repay(
        address underlyingToken,
        uint256 amount,
        address recipient
    ) external returns (uint256 amountRepaid);

    
    ///
    
    ///
    
    
    
    
    
    
    ///
    
    ///
    
    ///
    
    
    
    
    
    
    ///
    
    
    
    ///
    
    function liquidate(
        address yieldToken,
        uint256 shares,
        uint256 minimumAmountOut
    ) external returns (uint256 sharesLiquidated);

    
    ///
    
    
    ///
    
    ///
    
    ///
    
    
    
    
    
    
    ///
    
    
    function donate(address yieldToken, uint256 amount) external;

    
    ///
    
    
    
    ///
    
    ///
    
    
    function harvest(address yieldToken, uint256 minimumAmountOut) external;
}


// File src/interfaces/alchemist/IAlchemistV2AdminActions.sol

pragma solidity >=0.5.0;



///

interface IAlchemistV2AdminActions {
    
    struct InitializationParams {
        // The initial admin account.
        address admin;
        // The ERC20 token used to represent debt.
        address debtToken;
        // The initial transmuter or transmuter buffer.
        address transmuter;
        // The minimum collateralization ratio that an account must maintain.
        uint256 minimumCollateralization;
        // The percentage fee taken from each harvest measured in units of basis points.
        uint256 protocolFee;
        // The address that receives protocol fees.
        address protocolFeeReceiver;
        // A limit used to prevent administrators from making minting functionality inoperable.
        uint256 mintingLimitMinimum;
        // The maximum number of tokens that can be minted per period of time.
        uint256 mintingLimitMaximum;
        // The number of blocks that it takes for the minting limit to be refreshed.
        uint256 mintingLimitBlocks;
        // The address of the whitelist.
        address whitelist;
    }

    
    struct UnderlyingTokenConfig {
        // A limit used to prevent administrators from making repayment functionality inoperable.
        uint256 repayLimitMinimum;
        // The maximum number of underlying tokens that can be repaid per period of time.
        uint256 repayLimitMaximum;
        // The number of blocks that it takes for the repayment limit to be refreshed.
        uint256 repayLimitBlocks;
        // A limit used to prevent administrators from making liquidation functionality inoperable.
        uint256 liquidationLimitMinimum;
        // The maximum number of underlying tokens that can be liquidated per period of time.
        uint256 liquidationLimitMaximum;
        // The number of blocks that it takes for the liquidation limit to be refreshed.
        uint256 liquidationLimitBlocks;
    }

    
    struct YieldTokenConfig {
        // The adapter used by the system to interop with the token.
        address adapter;
        // The maximum percent loss in expected value that can occur before certain actions are disabled measured in
        // units of basis points.
        uint256 maximumLoss;
        // The maximum value that can be held by the system before certain actions are disabled measured in the
        // underlying token.
        uint256 maximumExpectedValue;
        // The number of blocks that credit will be distributed over to depositors.
        uint256 creditUnlockBlocks;
    }

    
    ///
    
    
    ///
    
    
    
    
    
    
    ///
    
    function initialize(InitializationParams memory params) external;

    
    ///
    
    ///
    
    ///
    
    ///
    
    function setPendingAdmin(address value) external;

    
    ///
    
    
    ///
    
    ///
    
    
    function acceptAdmin() external;

    
    ///
    
    ///
    
    
    function setSentinel(address sentinel, bool flag) external;

    
    ///
    
    ///
    
    
    function setKeeper(address keeper, bool flag) external;

    
    ///
    
    ///
    
    
    function addUnderlyingToken(
        address underlyingToken,
        UnderlyingTokenConfig calldata config
    ) external;

    
    ///
    
    ///
    
    
    
    ///
    
    
    function addYieldToken(address yieldToken, YieldTokenConfig calldata config)
        external;

    
    ///
    
    
    ///
    
    ///
    
    
    function setUnderlyingTokenEnabled(address underlyingToken, bool enabled)
        external;

    
    ///
    
    
    ///
    
    ///
    
    
    function setYieldTokenEnabled(address yieldToken, bool enabled) external;

    
    ///
    
    
    ///
    
    ///
    
    
    
    function configureRepayLimit(
        address underlyingToken,
        uint256 maximum,
        uint256 blocks
    ) external;

    
    ///
    
    
    ///
    
    ///
    
    
    
    function configureLiquidationLimit(
        address underlyingToken,
        uint256 maximum,
        uint256 blocks
    ) external;

    
    ///
    
    
    ///
    
    ///
    
    function setTransmuter(address value) external;

    
    ///
    
    ///
    
    ///
    
    function setMinimumCollateralization(uint256 value) external;

    
    ///
    
    
    ///
    
    ///
    
    function setProtocolFee(uint256 value) external;

    
    ///
    
    
    ///
    
    ///
    
    function setProtocolFeeReceiver(address value) external;

    
    ///
    
    ///
    
    ///
    
    
    function configureMintingLimit(uint256 maximum, uint256 blocks) external;

    
    ///
    
    ///
    
    
    function configureCreditUnlockRate(address yieldToken, uint256 blocks) external;

    
    ///
    
    
    
    ///
    
    ///
    
    
    function setTokenAdapter(address yieldToken, address adapter) external;

    
    ///
    
    
    ///
    
    
    function setMaximumExpectedValue(address yieldToken, uint256 value)
        external;

    
    ///
    
    
    ///
    
    ///
    
    
    function setMaximumLoss(address yieldToken, uint256 value) external;

    
    ///
    
    
    ///
    
    ///
    
    function snap(address yieldToken) external;

    
    ///
    
    
    ///
    
    
    function sweepRewardTokens(address rewardToken, address yieldToken) external;

     
    ///
    
    
    ///
    
    
    function sweepTokens(address token, uint256 amount) external;

    
    ///
    
    ///
    
    function setTransferAdapterAddress(address transferAdapterAddress) external;

    
    ///
    
    ///
    
    
    function transferDebtV1(address owner, int256 debt) external;
}


// File src/interfaces/alchemist/IAlchemistV2Errors.sol

pragma solidity >=0.5.0;



///

interface IAlchemistV2Errors {
    
    ///
    
    error UnsupportedToken(address token);

    
    ///
    
    error TokenDisabled(address token);

    
    error Undercollateralized();

    
    ///
    
    
    
    error ExpectedValueExceeded(address yieldToken, uint256 expectedValue, uint256 maximumExpectedValue);

    
    ///
    
    
    
    error LossExceeded(address yieldToken, uint256 loss, uint256 maximumLoss);

    
    ///
    
    
    error MintingLimitExceeded(uint256 amount, uint256 available);

    
    ///
    
    
    
    error RepayLimitExceeded(address underlyingToken, uint256 amount, uint256 available);

    
    ///
    
    
    
    error LiquidationLimitExceeded(address underlyingToken, uint256 amount, uint256 available);

    
    ///
    
    
    ///                         the operation.
    error SlippageExceeded(uint256 amount, uint256 minimumAmountOut);
}


// File src/interfaces/alchemist/IAlchemistV2Immutables.sol

pragma solidity >=0.5.0;



interface IAlchemistV2Immutables {
    
    ///
    
    function version() external view returns (string memory);

    
    ///
    
    function debtToken() external view returns (address);
}


// File src/interfaces/alchemist/IAlchemistV2Events.sol

pragma solidity >=0.5.0;



interface IAlchemistV2Events {
    
    ///
    
    event PendingAdminUpdated(address pendingAdmin);

    
    ///
    
    event AdminUpdated(address admin);

    
    ///
    
    
    event SentinelSet(address sentinel, bool flag);

    
    ///
    
    
    event KeeperSet(address sentinel, bool flag);

    
    ///
    
    event AddUnderlyingToken(address indexed underlyingToken);

    
    ///
    
    event AddYieldToken(address indexed yieldToken);

    
    ///
    
    
    event UnderlyingTokenEnabled(address indexed underlyingToken, bool enabled);

    
    ///
    
    
    event YieldTokenEnabled(address indexed yieldToken, bool enabled);

    
    ///
    
    
    
    event RepayLimitUpdated(address indexed underlyingToken, uint256 maximum, uint256 blocks);

    
    ///
    
    
    
    event LiquidationLimitUpdated(address indexed underlyingToken, uint256 maximum, uint256 blocks);

    
    ///
    
    event TransmuterUpdated(address transmuter);

    
    ///
    
    event MinimumCollateralizationUpdated(uint256 minimumCollateralization);

    
    ///
    
    event ProtocolFeeUpdated(uint256 protocolFee);
    
    
    ///
    
    event ProtocolFeeReceiverUpdated(address protocolFeeReceiver);

    
    ///
    
    
    event MintingLimitUpdated(uint256 maximum, uint256 blocks);

    
    ///
    
    
    event CreditUnlockRateUpdated(address yieldToken, uint256 blocks);

    
    ///
    
    
    event TokenAdapterUpdated(address yieldToken, address tokenAdapter);

    
    ///
    
    
    event MaximumExpectedValueUpdated(address indexed yieldToken, uint256 maximumExpectedValue);

    
    ///
    
    
    event MaximumLossUpdated(address indexed yieldToken, uint256 maximumLoss);

    
    ///
    
    
    event Snap(address indexed yieldToken, uint256 expectedValue);

    
    ///
    
    
    event SweepRewardTokens(address indexed rewardToken, uint256 amount);

    
    ///
    
    
    event SweepTokens(address indexed token, uint256 amount);

    
    ///
    
    
    
    event ApproveMint(address indexed owner, address indexed spender, uint256 amount);

    
    ///
    
    
    
    
    event ApproveWithdraw(address indexed owner, address indexed spender, address indexed yieldToken, uint256 amount);

    
    ///
    
    ///         underlying tokens were wrapped.
    ///
    
    
    
    
    event Deposit(address indexed sender, address indexed yieldToken, uint256 amount, address recipient);

    
    ///         by `owner` to `recipient`.
    ///
    
    ///         were unwrapped.
    ///
    
    
    
    
    event Withdraw(address indexed owner, address indexed yieldToken, uint256 shares, address recipient);

    
    ///
    
    
    
    event Mint(address indexed owner, uint256 amount, address recipient);

    
    ///
    
    
    
    event Burn(address indexed sender, uint256 amount, address recipient);

    
    ///
    
    
    
    
    
    event Repay(address indexed sender, address indexed underlyingToken, uint256 amount, address recipient, uint256 credit);

    
    ///
    
    
    
    
    
    event Liquidate(address indexed owner, address indexed yieldToken, address indexed underlyingToken, uint256 shares, uint256 credit);

    
    ///
    
    
    
    event Donate(address indexed sender, address indexed yieldToken, uint256 amount);

    
    ///
    
    
    
    
    event Harvest(address indexed yieldToken, uint256 minimumAmountOut, uint256 totalHarvested, uint256 credit);
}


// File src/interfaces/alchemist/IAlchemistV2State.sol

pragma solidity >=0.5.0;



interface IAlchemistV2State {
    
    struct UnderlyingTokenParams {
        // The number of decimals the token has. This value is cached once upon registering the token so it is important
        // that the decimals of the token are immutable or the system will begin to have computation errors.
        uint8 decimals;
        // A coefficient used to normalize the token to a value comparable to the debt token. For example, if the
        // underlying token is 8 decimals and the debt token is 18 decimals then the conversion factor will be
        // 10^10. One unit of the underlying token will be comparably equal to one unit of the debt token.
        uint256 conversionFactor;
        // A flag to indicate if the token is enabled.
        bool enabled;
    }

    
    struct YieldTokenParams {
        // The number of decimals the token has. This value is cached once upon registering the token so it is important
        // that the decimals of the token are immutable or the system will begin to have computation errors.
        uint8 decimals;
        // The associated underlying token that can be redeemed for the yield-token.
        address underlyingToken;
        // The adapter used by the system to wrap, unwrap, and lookup the conversion rate of this token into its
        // underlying token.
        address adapter;
        // The maximum percentage loss that is acceptable before disabling certain actions.
        uint256 maximumLoss;
        // The maximum value of yield tokens that the system can hold, measured in units of the underlying token.
        uint256 maximumExpectedValue;
        // The percent of credit that will be unlocked per block. The representation of this value is a 18  decimal
        // fixed point integer.
        uint256 creditUnlockRate;
        // The current balance of yield tokens which are held by users.
        uint256 activeBalance;
        // The current balance of yield tokens which are earmarked to be harvested by the system at a later time.
        uint256 harvestableBalance;
        // The total number of shares that have been minted for this token.
        uint256 totalShares;
        // The expected value of the tokens measured in underlying tokens. This value controls how much of the token
        // can be harvested. When users deposit yield tokens, it increases the expected value by how much the tokens
        // are exchangeable for in the underlying token. When users withdraw yield tokens, it decreases the expected
        // value by how much the tokens are exchangeable for in the underlying token.
        uint256 expectedValue;
        // The current amount of credit which is will be distributed over time to depositors.
        uint256 pendingCredit;
        // The amount of the pending credit that has been distributed.
        uint256 distributedCredit;
        // The block number which the last credit distribution occurred.
        uint256 lastDistributionBlock;
        // The total accrued weight. This is used to calculate how much credit a user has been granted over time. The
        // representation of this value is a 18 decimal fixed point integer.
        uint256 accruedWeight;
        // A flag to indicate if the token is enabled.
        bool enabled;
    }

    
    ///
    
    function admin() external view returns (address admin);

    
    ///
    
    function pendingAdmin() external view returns (address pendingAdmin);

    
    ///
    
    function transferAdapter() external view returns (address transferAdapter);

    
    ///
    
    ///
    
    function sentinels(address sentinel) external view returns (bool isSentinel);

    
    ///
    
    ///
    
    function keepers(address keeper) external view returns (bool isKeeper);

    
    ///
    
    function transmuter() external view returns (address transmuter);

    
    ///
    
    ///
    
    ///
    
    function minimumCollateralization() external view returns (uint256 minimumCollateralization);

    
    ///
    
    function protocolFee() external view returns (uint256 protocolFee);

    
    ///
    
    function protocolFeeReceiver() external view returns (address protocolFeeReceiver);

    
    ///
    
    function whitelist() external view returns (address whitelist);
    
    
    ///
    
    ///
    
    function getUnderlyingTokensPerShare(address yieldToken) external view returns (uint256 rate);

    
    ///
    
    ///
    
    function getYieldTokensPerShare(address yieldToken) external view returns (uint256 rate);

    
    ///
    
    ///
    
    function getSupportedUnderlyingTokens() external view returns (address[] memory tokens);

    
    ///
    
    ///
    
    function getSupportedYieldTokens() external view returns (address[] memory tokens);

    
    ///
    
    ///
    
    function isSupportedUnderlyingToken(address underlyingToken) external view returns (bool isSupported);

    
    ///
    
    ///
    
    function isSupportedYieldToken(address yieldToken) external view returns (bool isSupported);

    
    ///
    
    ///
    
    
    function accounts(address owner) external view returns (int256 debt, address[] memory depositedTokens);

    
    ///
    
    
    ///
    
    
    function positions(address owner, address yieldToken)
        external view
        returns (
            uint256 shares,
            uint256 lastAccruedWeight
        );

    
    ///
    
    
    ///
    
    function mintAllowance(address owner, address spender) external view returns (uint256 allowance);

    
    ///
    
    
    
    ///
    
    function withdrawAllowance(address owner, address spender, address yieldToken) external view returns (uint256 allowance);

    
    ///
    
    ///
    
    function getUnderlyingTokenParameters(address underlyingToken)
        external view
        returns (UnderlyingTokenParams memory params);

    
    ///
    
    ///
    
    function getYieldTokenParameters(address yieldToken)
        external view
        returns (YieldTokenParams memory params);

    
    ///
    
    
    
    function getMintLimitInfo()
        external view
        returns (
            uint256 currentLimit,
            uint256 rate,
            uint256 maximum
        );

    
    ///
    
    ///
    
    
    
    function getRepayLimitInfo(address underlyingToken)
        external view
        returns (
            uint256 currentLimit,
            uint256 rate,
            uint256 maximum
        );

    
    ///
    
    ///
    
    
    
    function getLiquidationLimitInfo(address underlyingToken)
        external view
        returns (
            uint256 currentLimit,
            uint256 rate,
            uint256 maximum
        );
}


// File src/interfaces/IAlchemistV2.sol

pragma solidity >=0.5.0;








interface IAlchemistV2 is
    IAlchemistV2Actions,
    IAlchemistV2AdminActions,
    IAlchemistV2Errors,
    IAlchemistV2Immutables,
    IAlchemistV2Events,
    IAlchemistV2State
{ }


// File src/interfaces/keepers/IAlchemixHarvester.sol

pragma solidity ^0.8.13;

interface IAlchemixHarvester {
  function harvest(
    address alchemist,
    address yieldToken,
    uint256 minimumAmountOut,
    uint256 expectedExchange
  ) external;
}


// File src/interfaces/ITokenAdapter.sol

pragma solidity >=0.5.0;



interface ITokenAdapter {
    
    ///
    
    function version() external view returns (string memory);

    
    ///
    
    function token() external view returns (address);

    
    ///
    
    function underlyingToken() external view returns (address);

    
    ///         for.
    ///
    
    function price() external view returns (uint256);

    
    ///
    
    
    ///
    
    function wrap(uint256 amount, address recipient)
        external
        returns (uint256 amountYieldTokens);

    
    ///
    
    
    ///
    
    function unwrap(uint256 amount, address recipient)
        external
        returns (uint256 amountUnderlyingTokens);
}


// File src/interfaces/external/vesper/IVesperRewards.sol


pragma solidity >=0.6.12;

interface IVesperRewards {
    function claimReward(address) external;

    function claimable(address) external view returns (address[] memory, uint256[] memory);

    function rewardTokens(uint256) external view returns (address);
}


// File src/interfaces/external/chainlink/IChainlinkOracle.sol

pragma solidity >= 0.6.6;

interface IChainlinkOracle {
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}


// File src/interfaces/external/uniswap/IUniswapV3Factory.sol

pragma solidity >=0.5.0;



interface IUniswapV3Factory {
    
    
    
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    
    
    
    
    
    
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    
    
    
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    
    
    
    function owner() external view returns (address);

    
    
    
    
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    
    
    
    
    
    
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    
    
    
    
    
    /// from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
    /// are invalid.
    
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    
    
    
    function setOwner(address _owner) external;

    
    
    
    
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}


// File src/interfaces/external/uniswap/pool/IUniswapV3PoolState.sol

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


// File src/interfaces/external/uniswap/IUniswapV3Pool.sol

pragma solidity >=0.5.0;

// import './pool/IUniswapV3PoolImmutables.sol';

// import './pool/IUniswapV3PoolDerivedState.sol';
// import './pool/IUniswapV3PoolActions.sol';
// import './pool/IUniswapV3PoolOwnerActions.sol';
// import './pool/IUniswapV3PoolEvents.sol';



/// to the ERC20 specification

interface IUniswapV3Pool is
    // IUniswapV3PoolImmutables,
    IUniswapV3PoolState
    // IUniswapV3PoolDerivedState,
    // IUniswapV3PoolActions,
    // IUniswapV3PoolOwnerActions,
    // IUniswapV3PoolEvents
{

}


// File src/utils/UniswapEstimatedPrice.sol

pragma solidity ^0.8.13;




contract UniswapEstimatedPrice {
    // Set `token2` == 0 address for only one swap
    function getExpectedExchange(address factory, address token0, address token1, uint24 fee0, address token2, uint24 fee1, uint256 amount) external returns (uint256) {
        IUniswapV3Factory uniswapFactory = IUniswapV3Factory(factory);

        IUniswapV3Pool pool = IUniswapV3Pool(uniswapFactory.getPool(token0, token1, fee0));
        (uint160 sqrtPriceX96,,,,,,) =  pool.slot0();
        uint256 price0 = uint(sqrtPriceX96) * (uint(sqrtPriceX96)) * (1e18) >> (96 * 2);

        if (token2 == address(0)) return amount * price0 / 1e18;

        pool = IUniswapV3Pool(uniswapFactory.getPool(token1, token2, fee1));
        ( sqrtPriceX96,,,,,,) =  pool.slot0();
        uint256 price1 = uint(sqrtPriceX96) * (uint(sqrtPriceX96)) * (1e18) >> (96 * 2);

        return amount * price0 / price1;
    }
}


// File lib/openzeppelin-contracts/contracts/utils/Context.sol

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File lib/openzeppelin-contracts/contracts/access/Ownable.sol

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
}


// File lib/openzeppelin-contracts/contracts/utils/math/SafeMath.sol

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


// File src/base/Errors.sol

pragma solidity ^0.8.13;


///         `msg.origin` is not authorized.
error Unauthorized();


///         or entered an illegal condition which is not recoverable from.
error IllegalState();


///         to the function.
error IllegalArgument();


// File src/libraries/SafeCast.sol

pragma solidity >=0.5.0;



library SafeCast {
  
  
  
  function toInt256(uint256 y) internal pure returns (int256 z) {
    if (y >= 2**255) {
      revert IllegalArgument();
    }
    z = int256(y);
  }

  
  
  
  function toUint256(int256 y) internal pure returns (uint256 z) {
    if (y < 0) {
      revert IllegalArgument();
    }
    z = uint256(y);
  }
}


// File src/keepers/HarvestResolver.sol

pragma solidity ^0.8.13;
















contract HarvestResolver is IResolver, Ownable {
  address constant alUsdOptimism = 0xCB8FA9a76b8e203D8C3797bF438d8FB81Ea3326A;
  address constant alEthOptimism = 0x3E29D3A9316dAB217754d13b28646B76607c5f04;
  address constant ethAlchemistAddress = 0x062Bf725dC4cDF947aa79Ca2aaCCD4F385b13b5c;
  address constant usdAlchemistAddress = 0x5C6374a2ac4EBC38DeA0Fc1F8716e5Ea1AdD94dd;
  address constant dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address constant opRewardsController = 0x929EC64c34a17401F460460D4B9390518E5B473e;
  address constant opToUsdOracle = 0x0D276FC14719f9292D5C1eA2198673d1f4269246;
  address constant ethToUsdOracle = 0x13e3Ee699D1909E989722E753853AE30b17e08c5;
  address constant uniswapFactory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
  address constant wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address constant vaDAI = 0x0538C8bAc84E95A9dF8aC10Aad17DbE81b9E36ee;
  address constant vaUSDC = 0xa8b607Aa09B6A2E306F93e74c282Fb13f6A80452;
  address constant vaETH = 0xd1C117319B3595fbc39b471AB1fd485629eb05F2;
  address constant vesperRewardsDai = 0x35864296944119F72AA1B468e13449222f3f0E67;
  address constant vesperRewardsUsdc = 0x2F59B0F98A08E733C66dFB42Bd8E366dC2cfedA6;
  address constant vesperRewardsEth = 0x2F59B0F98A08E733C66dFB42Bd8E366dC2cfedA6;
  address constant vspRewardToken = 0x1b40183EFB4Dd766f11bDa7A7c3AD8982e998421;

  
  error YieldTokenDisabled();
  
  error HarvestJobDoesNotExist();

  
  event SetHarvestJob(
    bool active,
    address alchemist,
    address reward,
    address yieldToken,
    uint256 minimumHarvestAmount,
    uint256 minimumDelay,
    uint256 slippageBps
  );
  
  event SetHarvester(address harvester, bool status);

  
  event RemoveHarvestJob(address yieldToken);

  
  event RecordHarvest(address yieldToken);

  struct HarvestJob {
    bool active;
    address alchemist;
    address reward;
    address yieldToken;
    uint256 lastHarvest;
    uint256 minimumHarvestAmount;
    uint256 minimumDelay;
    uint256 slippageBps;
  }

  uint256 public constant SLIPPAGE_PRECISION = 10000;

  
  address[] public yieldTokens;

  
  mapping(address => HarvestJob) public harvestJobs;

  
  bool public paused;

  
  mapping(address => bool) public harvesters;

  constructor() Ownable() {}

  modifier onlyHarvester() {
    if (!harvesters[msg.sender]) {
      revert Unauthorized();
    }
    _;
  }

  
  ///
  
  
  function setHarvester(address harvester, bool status) external onlyOwner {
    harvesters[harvester] = status;
    emit SetHarvester(harvester, status);
  }

  
  ///
  
  function setPause(bool pauseState) external onlyOwner {
    paused = pauseState;
  }

  
  ///
  
  function recoverFunds(address token) external onlyOwner {
    IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
  }

  
  ///
  
  
  
  
  
  
  function addHarvestJob(
    bool active,
    address alchemist,
    address reward,
    address yieldToken,
    uint256 minimumHarvestAmount,
    uint256 minimumDelay,
    uint256 slippageBps
  ) external onlyOwner {
    IAlchemistV2.YieldTokenParams memory ytp = IAlchemistV2(alchemist).getYieldTokenParameters(yieldToken);
    if (!ytp.enabled) {
      revert YieldTokenDisabled();
    }

    if (slippageBps > SLIPPAGE_PRECISION) {
      revert IllegalArgument();
    }

    harvestJobs[yieldToken] = HarvestJob(
      active,
      alchemist,
      reward,
      yieldToken,
      block.timestamp,
      minimumHarvestAmount,
      minimumDelay,
      slippageBps
    );

    emit SetHarvestJob(active, alchemist, reward, yieldToken, minimumHarvestAmount, minimumDelay, slippageBps);

    // Only add the yield token to the list if it doesnt exist yet.
    for (uint256 i = 0; i < yieldTokens.length; i++) {
      if (yieldTokens[i] == yieldToken) {
        return;
      }
    }
    yieldTokens.push(yieldToken);
  }

  
  ///
  
  
  function setActive(address yieldToken, bool active) external onlyOwner {
    harvestJobs[yieldToken].active = active;
  }

  
  ///
  
  
  function setAlchemist(address yieldToken, address alchemist) external onlyOwner {
    IAlchemistV2.YieldTokenParams memory ytp = IAlchemistV2(alchemist).getYieldTokenParameters(yieldToken);
    if (!ytp.enabled) {
      revert YieldTokenDisabled();
    }
    harvestJobs[yieldToken].alchemist = alchemist;
  }

  
  ///
  
  
  function setMinimumHarvestAmount(address yieldToken, uint256 minimumHarvestAmount) external onlyOwner {
    harvestJobs[yieldToken].minimumHarvestAmount = minimumHarvestAmount;
  }

  
  ///
  
  
  function setMinimumDelay(address yieldToken, uint256 minimumDelay) external onlyOwner {
    harvestJobs[yieldToken].minimumDelay = minimumDelay;
  }

  
  ///
  
  
  function setSlippageBps(address yieldToken, uint256 slippageBps) external onlyOwner {
    harvestJobs[yieldToken].slippageBps = slippageBps;
  }

  
  ///
  
  function removeHarvestJob(address yieldToken) external onlyOwner {
    int256 idx = -1;
    for (uint256 i = 0; i < yieldTokens.length; i++) {
      if (yieldTokens[i] == yieldToken) {
        idx = SafeCast.toInt256(i);
      }
    }
    if (idx > -1) {
      delete harvestJobs[yieldToken];
      yieldTokens[SafeCast.toUint256(idx)] = yieldTokens[yieldTokens.length - 1];
      yieldTokens.pop();
      emit RemoveHarvestJob(yieldToken);
    } else {
      revert HarvestJobDoesNotExist();
    }
  }

  
  ///
  /// Returns FALSE if the resolver is paused.
  /// Returns TRUE for the first harvest job that meets the following criteria:
  ///     - the harvest job is active
  ///     - `yieldToken` is enabled in the Alchemist
  ///     - minimumDelay seconds have passed since the `yieldToken` was last harvested
  ///     - the expected harvest amount is greater than minimumHarvestAmount
  /// Returns FALSE if no harvest jobs meet the above criteria.
  ///
  
  
  function checker() external view returns (bool canExec, bytes memory execPayload) {
    if (paused) {
      return (false, abi.encode(0));
    }

    for (uint256 i = 0; i < yieldTokens.length; i++) {
      address yieldToken = yieldTokens[i];
      HarvestJob memory h = harvestJobs[yieldToken];
      if (h.active) {
        IAlchemistV2.YieldTokenParams memory ytp = IAlchemistV2(h.alchemist).getYieldTokenParameters(yieldToken);

        if (ytp.enabled) {
          uint256 pps = ITokenAdapter(ytp.adapter).price();
          uint256 currentValue = ((ytp.activeBalance + ytp.harvestableBalance) * pps) / 10**ytp.decimals;
          if (
            (block.timestamp >= h.lastHarvest + h.minimumDelay) &&
            (currentValue > ytp.expectedValue + h.minimumHarvestAmount)
          ) {
            uint256 minimumAmountOut = currentValue - ytp.expectedValue;
            minimumAmountOut = minimumAmountOut - (minimumAmountOut * h.slippageBps) / SLIPPAGE_PRECISION;

            uint256 expectedExchange;

            // If vault has rewards to be collected
            if (h.reward == vspRewardToken) {
              // alUSD route for vesper swap
              if (h.alchemist == usdAlchemistAddress) {
                if (h.yieldToken == vaDAI) {
                  (address[] memory tokens, uint256[] memory amounts) = IVesperRewards(vesperRewardsDai).claimable(usdAlchemistAddress);
                  expectedExchange = _getExpectedExchange(uniswapFactory, h.reward, wethAddress, uint24(3000), dai, uint24(3000), amounts[0]);
                } else if (h.yieldToken == vaUSDC) {
                  (address[] memory tokens, uint256[] memory amounts) = IVesperRewards(vesperRewardsUsdc).claimable(usdAlchemistAddress);
                  expectedExchange = _getExpectedExchange(uniswapFactory, h.reward, wethAddress, uint24(3000), dai, uint24(3000), amounts[0]);
                }
              // alETH route for vesper swap
              } else if (h.alchemist == ethAlchemistAddress) {
                (address[] memory tokens, uint256[] memory amounts) = IVesperRewards(vesperRewardsEth).claimable(ethAlchemistAddress);
                expectedExchange = _getExpectedExchange(uniswapFactory, h.reward, wethAddress, uint24(3000), address(0), uint24(0), amounts[0]);
              }
              return (
                true,
                abi.encodeWithSelector(IAlchemixHarvester.harvest.selector, h.alchemist, yieldToken, minimumAmountOut, expectedExchange * 9900 / 10000)
              );
            }

            // If reward is not the address of a token then it is the address of a reward collector.
            // We can assume that this is optimism and handle rewards accordingly.
            if (h.reward != address(0)) {
              address[] memory token = new address[](1);
              token[0] = address(IStaticAToken(h.yieldToken).ATOKEN());
              uint256 claimable = IRewardsController(opRewardsController).getUserRewards(token, yieldToken, IRewardCollector(h.reward).rewardToken());
              // Find expected amount out before calling harvest
              if (IRewardCollector(h.reward).debtToken() == alUsdOptimism) {
                expectedExchange = claimable * uint(IChainlinkOracle(opToUsdOracle).latestAnswer()) / 1e8;
              } else if (IRewardCollector(h.reward).debtToken() == alEthOptimism) {
                expectedExchange = claimable * uint(IChainlinkOracle(opToUsdOracle).latestAnswer()) / uint(IChainlinkOracle(ethToUsdOracle).latestAnswer());
              } else {
                  revert IllegalState();
              }
              return (
                true,
                abi.encodeWithSelector(IAlchemixHarvester.harvest.selector, h.alchemist, yieldToken, minimumAmountOut, expectedExchange * 9900 / 10000)
              );
            // If reward equals the 0 address then we handle the harvest without rewards.
            } else {
              return (
                true,
                abi.encodeWithSelector(IAlchemixHarvester.harvest.selector, h.alchemist, yieldToken, minimumAmountOut, 0)
              );
            }
          }
        }
      }
    }
    return (false, abi.encode(0));
  }
  
  // Get expected exchange from reward token to debt token.
  function _getExpectedExchange(address factory, address token0, address token1, uint24 fee0, address token2, uint24 fee1, uint256 amount) internal view returns (uint256) {
      IUniswapV3Factory uniswapFactory = IUniswapV3Factory(factory);

      IUniswapV3Pool pool = IUniswapV3Pool(uniswapFactory.getPool(token0, token1, fee0));
      (uint160 sqrtPriceX96,,,,,,) =  pool.slot0();
      uint256 price0 = uint(sqrtPriceX96) * (uint(sqrtPriceX96)) * (1e18) >> (96 * 2);

      if (token2 == address(0)) return amount * price0 / 1e18;

      pool = IUniswapV3Pool(uniswapFactory.getPool(token1, token2, fee1));
      ( sqrtPriceX96,,,,,,) =  pool.slot0();
      uint256 price1 = uint(sqrtPriceX96) * (uint(sqrtPriceX96)) * (1e18) >> (96 * 2);

      return amount * price0 / price1;
  }

  function recordHarvest(address yieldToken) external onlyHarvester {
    harvestJobs[yieldToken].lastHarvest = block.timestamp;
    emit RecordHarvest(yieldToken);
  }
}