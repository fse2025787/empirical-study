

pragma solidity ^0.8.5;

/**
 * @notice Abstract contract for creating or interacting with a Trigger contract
 * @dev All trigger contracts created must inerit from this contract and conform to this interface
 */
abstract contract ITrigger {
  
  string public name;

  
  string public symbol;

  
  string public description;

  
  uint256[] public platformIds;

  
  address public immutable recipient;

  
  bool public isTriggered;

  
  event TriggerActivated();

  /**
   * @notice Returns array of IDs, where each ID corresponds to a platform covered by this trigger
   * @dev See documentation for mapping of ID numbers to platforms
   */
  function getPlatformIds() external view returns (uint256[] memory) {
    return platformIds;
  }

  /**
   * @dev Executes trigger-specific logic to check if market has been triggered
   * @return True if trigger condition occured, false otherwise
   */
  function checkTriggerCondition() internal virtual returns (bool);

  /**
   * @notice Checks trigger condition, sets isTriggered flag to true if condition is met, and returns the trigger status
   * @return True if trigger condition occured, false otherwise
   */
  function checkAndToggleTrigger() external returns (bool) {
    // Return true if trigger already toggled
    if (isTriggered) return true;

    // Return false if market has not been triggered
    if (!checkTriggerCondition()) return false;

    // Otherwise, market has been triggered
    emit TriggerActivated();
    isTriggered = true;
    return isTriggered;
  }

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _description,
    uint256[] memory _platformIds,
    address _recipient
  ) {
    name = _name;
    description = _description;
    symbol = _symbol;
    platformIds = _platformIds;
    recipient = _recipient;
  }
}
pragma solidity ^0.8.5;






/**
 * @notice Defines a trigger that is toggled if any of the following conditions occur:
 *   1. The price per share for the V2 yVault significantly decreases between consecutive checks. Under normal
 *      operation, this value should only increase. A decrease indicates something is wrong with the Yearn vault
 *   2. Curve 3Crypto token balances are significantly lower than what the pool expects them to be
 *   3. Curve 3Crypto virtual price drops significantly
 */
contract YearnCrv3Crypto is ITrigger {
  // --- Tokens ---
  // Token addresses
  IERC20 internal constant usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
  IERC20 internal constant wbtc = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
  IERC20 internal constant weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

  // Token indices in Curve pool arrays
  uint256 internal constant usdtIndex = 0;
  uint256 internal constant wbtcIndex = 1;
  uint256 internal constant wethIndex = 2;

  // --- Tolerances ---
  
  uint256 public constant scale = 1000;

  
  /// next six hours. Therefore we cannot simply check that the pricePerShare increases. Instead, we consider the vault
  /// triggered if the pricePerShare drops by more than 50% from it's previous value. This is conservative, but
  /// previous Yearn bugs resulted in pricePerShare drops of 0.5% – 10%, and were only temporary drops with users able
  /// to be made whole. Therefore this trigger requires a large 50% drop to minimize false positives. The tolerance
  /// is defined such that we trigger if: currentPricePerShare < lastPricePerShare * tolerance / 1000. This means
  /// if you want to trigger after a 20% drop, you should set the tolerance to 1000 - 200 = 800
  uint256 public constant vaultTol = scale - 500; // 50% drop, represented on a scale where 1000 = 100%

  
  /// per share, the virtual price is expected to decrease during normal operation, but it should never decrease by
  /// more than 50% during normal operation. Therefore we check for a 50% drop
  uint256 public constant virtualPriceTol = scale - 500; // 50% drop

  
  uint256 public constant balanceTol = scale - 500; // 50% drop

  // --- Trigger Data ---
  
  IYVaultV2 public immutable vault;

  
  ICurvePool public immutable curve;

  
  uint256 public lastPricePerShare;

  
  uint256 public lastVirtualPrice;

  // --- Constructor ---

  /**
   * @param _vault Address of the Yearn V2 vault this trigger should protect
   * @param _curve Address of the Curve 3Crypto pool uses by the above Yearn vault
   * @dev For definitions of other constructor parameters, see ITrigger.sol
   */
  constructor(
    string memory _name,
    string memory _symbol,
    string memory _description,
    uint256[] memory _platformIds,
    address _recipient,
    address _vault,
    address _curve
  ) ITrigger(_name, _symbol, _description, _platformIds, _recipient) {
    // Set vault
    vault = IYVaultV2(_vault);
    curve = ICurvePool(_curve);

    // Save current values (immutables can't be read at construction, so we don't use `vault` or `curve` directly)
    lastPricePerShare = IYVaultV2(_vault).pricePerShare();
    lastVirtualPrice = ICurvePool(_curve).get_virtual_price();
  }

  // --- Trigger condition ---

  /**
   * @dev Checks the yVault pricePerShare
   */
  function checkTriggerCondition() internal override returns (bool) {
    // Read this blocks share price and virtual price
    uint256 _currentPricePerShare = vault.pricePerShare();
    uint256 _currentVirtualPrice = curve.get_virtual_price();

    // Check trigger conditions. We could check one at a time and return as soon as one is true, but it is convenient
    // to have the data that caused the trigger saved into the state, so we don't do that
    bool _statusVault = _currentPricePerShare < ((lastPricePerShare * vaultTol) / scale);
    bool _statusVirtualPrice = _currentVirtualPrice < ((lastVirtualPrice * virtualPriceTol) / scale);
    bool _statusBalances = checkCurveBalances();

    // Save the new data
    lastPricePerShare = _currentPricePerShare;
    lastVirtualPrice = _currentVirtualPrice;

    // Return status
    return _statusVault || _statusVirtualPrice || _statusBalances;
  }

  /**
   * @dev Checks if the Curve internal balances are significantly lower than the true balances
   * @return True if balances are out of tolerance and trigger should be toggled
   */
  function checkCurveBalances() internal view returns (bool) {
    return
      (usdt.balanceOf(address(curve)) < ((curve.balances(usdtIndex) * balanceTol) / scale)) ||
      (wbtc.balanceOf(address(curve)) < ((curve.balances(wbtcIndex) * balanceTol) / scale)) ||
      (weth.balanceOf(address(curve)) < ((curve.balances(wethIndex) * balanceTol) / scale));
  }
}

pragma solidity ^0.8.5;

interface ICurvePool {
  
  function get_virtual_price() external view returns (uint256);

  
  function virtual_price() external view returns (uint256);

  
  function xcp_profit() external view returns (uint256);

  
  function xcp_profit_a() external view returns (uint256);

  
  function admin_fee() external view returns (uint256);

  
  function balances(uint256 index) external view returns (uint256);

  
  function coins(uint256 index) external view returns (address);
}

pragma solidity ^0.8.5;

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

pragma solidity ^0.8.5;

interface IYVaultV2 {
  function totalSupply() external view returns (uint256);

  function pricePerShare() external view returns (uint256);
}
