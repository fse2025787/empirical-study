// SPDX-License-Identifier: MIT

// 

// solhint-disable-next-line compiler-version
pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// 
pragma solidity ^0.8.4;




abstract contract ModuleMapConsumer is Initializable {
  IModuleMap public moduleMap;

  function __ModuleMapConsumer_init(address moduleMap_) internal initializer {
    moduleMap = IModuleMap(moduleMap_);
  }
}

// 
pragma solidity ^0.8.4;





abstract contract Controlled is Initializable, ModuleMapConsumer {
  // controller address => is a controller
  mapping(address => bool) internal _controllers;
  address[] public controllers;

  function __Controlled_init(address[] memory controllers_, address moduleMap_)
    public
    initializer
  {
    for (uint256 i; i < controllers_.length; i++) {
      _controllers[controllers_[i]] = true;
    }
    controllers = controllers_;
    __ModuleMapConsumer_init(moduleMap_);
  }

  function addController(address controller) external onlyOwner {
    _controllers[controller] = true;
    bool added;
    for (uint256 i; i < controllers.length; i++) {
      if (controller == controllers[i]) {
        added = true;
      }
    }
    if (!added) {
      controllers.push(controller);
    }
  }

  modifier onlyOwner() {
    require(
      IKernel(moduleMap.getModuleAddress(Modules.Kernel)).isOwner(msg.sender),
      "Controlled::onlyOwner: Caller is not owner"
    );
    _;
  }

  modifier onlyManager() {
    require(
      IKernel(moduleMap.getModuleAddress(Modules.Kernel)).isManager(msg.sender),
      "Controlled::onlyManager: Caller is not manager"
    );
    _;
  }

  modifier onlyController() {
    require(
      _controllers[msg.sender],
      "Controlled::onlyController: Caller is not controller"
    );
    _;
  }
}

// 
pragma solidity ^0.8.4;


interface IStrategyManager {
  // #### Functions

  /**
  @notice Adds a new strategy to the strategy map. 
  @dev This is a passthrough to StrategyMap.addStrategy
   */
  function addStrategy(
    string calldata name,
    IStrategyMap.WeightedIntegration[] memory integrations,
    address[] calldata tokens
  ) external;

  /**
    @notice Updates a strategy's name
    @dev This is a pass through function to StrategyMap.updateName
 */
  function updateStrategyName(uint256 id, string calldata name) external;

  /**
    @notice Updates a strategy's integrations
    @dev This is a pass through to StrategyMap.updateIntegrations
 */
  function updateStrategyIntegrations(
    uint256 id,
    IStrategyMap.WeightedIntegration[] memory integrations
  ) external;

  /**
  @notice Updates the tokens that a strategy accepts
  @dev This is a passthrough to StrategyMap.updateStrategyTokens
   */
  function updateStrategyTokens(uint256 id, address[] calldata tokens) external;

  /**
    @notice Deletes a strategy
    @dev This is a pass through to StrategyMap.deleteStrategy
    */
  function deleteStrategy(uint256 id) external;
}

// 
pragma solidity ^0.8.4;








contract StrategyManager is
  Initializable,
  ModuleMapConsumer,
  Controlled,
  IStrategyManager
{
  // #### Functions
  function initialize(address[] memory controllers_, address moduleMap_)
    public
    initializer
  {
    __Controlled_init(controllers_, moduleMap_);
  }

  /**
  @notice Adds a new strategy to the strategy map. 
  @dev This is a passthrough to StrategyMap.addStrategy
   */
  function addStrategy(
    string calldata name,
    IStrategyMap.WeightedIntegration[] memory integrations,
    address[] calldata tokens
  ) external override onlyManager {
    IStrategyMap(moduleMap.getModuleAddress(Modules.StrategyMap)).addStrategy(
      name,
      integrations,
      tokens
    );
  }

  /**
@notice Updates the whitelisted tokens a strategy accepts for new deposits
@dev This is a passthrough to StrategyMap.updateStrategyTokens
 */
  function updateStrategyTokens(uint256 id, address[] calldata tokens)
    external
    override
    onlyManager
  {
    IStrategyMap(moduleMap.getModuleAddress(Modules.StrategyMap)).updateTokens(
      id,
      tokens
    );
  }

  /**
    @notice Updates a strategy's name
    @dev This is a pass through function to StrategyMap.updateName
 */
  function updateStrategyName(uint256 id, string calldata name)
    external
    override
    onlyManager
  {
    IStrategyMap(moduleMap.getModuleAddress(Modules.StrategyMap)).updateName(
      id,
      name
    );
  }

  /**
    @notice Updates a strategy's integrations
    @dev This is a pass through to StrategyMap.updateIntegrations
 */
  function updateStrategyIntegrations(
    uint256 id,
    IStrategyMap.WeightedIntegration[] memory integrations
  ) external override onlyManager {
    IStrategyMap(moduleMap.getModuleAddress(Modules.StrategyMap))
      .updateIntegrations(id, integrations);
    IYieldManager(moduleMap.getModuleAddress(Modules.YieldManager)).deploy();
  }

  /**
    @notice Deletes a strategy
    @dev This is a pass through to StrategyMap.deleteStrategy
    */
  function deleteStrategy(uint256 id) external override onlyManager {
    IStrategyMap(moduleMap.getModuleAddress(Modules.StrategyMap))
      .deleteStrategy(id);
    IYieldManager(moduleMap.getModuleAddress(Modules.YieldManager)).rebalance();
  }
}

// 
pragma solidity ^0.8.4;

interface IIntegration {
  
  
  function deposit(address tokenAddress, uint256 amount) external;

  
  
  function withdraw(address tokenAddress, uint256 amount) external;

  
  function deploy() external;

  
  function harvestYield() external;

  
  
  
  
  function getBalance(address tokenAddress) external view returns (uint256);
}

// 
pragma solidity ^0.8.4;

interface IKernel {
  
  
  function isManager(address account) external view returns (bool);

  
  
  function isOwner(address account) external view returns (bool);
}

// 
pragma solidity ^0.8.4;

enum Modules {
  Kernel, // 0
  UserPositions, // 1
  YieldManager, // 2
  IntegrationMap, // 3
  BiosRewards, // 4
  EtherRewards, // 5
  SushiSwapTrader, // 6
  UniswapTrader, // 7
  StrategyMap, // 8
  StrategyManager // 9
}

interface IModuleMap {
  function getModuleAddress(Modules key) external view returns (address);
}

// 
pragma solidity ^0.8.4;


interface IStrategyMap {
  // #### Structs
  struct WeightedIntegration {
    address integration;
    uint256 weight;
  }

  struct Strategy {
    string name;
    uint256 totalStrategyWeight;
    mapping(address => bool) enabledTokens;
    address[] tokens;
    WeightedIntegration[] integrations;
  }

  struct StrategySummary {
    string name;
    uint256 totalStrategyWeight;
    address[] tokens;
    WeightedIntegration[] integrations;
  }

  struct StrategyTransaction {
    uint256 amount;
    address token;
  }

  // #### Events
  event NewStrategy(
    uint256 indexed id,
    string name,
    WeightedIntegration[] integrations,
    address[] tokens
  );
  event UpdateName(uint256 indexed id, string name);
  event UpdateIntegrations(
    uint256 indexed id,
    WeightedIntegration[] integrations
  );
  event UpdateTokens(uint256 indexed id, address[] tokens);
  event DeleteStrategy(
    uint256 indexed id,
    string name,
    address[] tokens,
    WeightedIntegration[] integrations
  );

  event EnterStrategy(
    uint256 indexed id,
    address indexed user,
    address[] tokens,
    uint256[] amounts
  );
  event ExitStrategy(
    uint256 indexed id,
    address indexed user,
    address[] tokens,
    uint256[] amounts
  );

  // #### Functions
  /**
     @notice Adds a new strategy to the list of available strategies
     @param name  the name of the new strategy
     @param integrations  the integrations and weights that form the strategy
     */
  function addStrategy(
    string calldata name,
    WeightedIntegration[] memory integrations,
    address[] calldata tokens
  ) external;

  /**
    @notice Updates the strategy name
    @param name  the new name
     */
  function updateName(uint256 id, string calldata name) external;

  /**
  @notice Updates a strategy's accepted tokens
  @param id  The strategy ID
  @param tokens  The new tokens to allow
  */
  function updateTokens(uint256 id, address[] calldata tokens) external;

  /**
    @notice Updates the strategy integrations 
    @param integrations  the new integrations
     */
  function updateIntegrations(
    uint256 id,
    WeightedIntegration[] memory integrations
  ) external;

  /**
    @notice Deletes a strategy
    @dev This can only be called successfully if the strategy being deleted doesn't have any assets invested in it
    @param id  the strategy to delete
     */
  function deleteStrategy(uint256 id) external;

  /**
    @notice Increases the amount of a set of tokens in a strategy
    @param id  the strategy to deposit into
    @param tokens  the tokens to deposit
    @param amounts  The amounts to be deposited
     */
  function enterStrategy(
    uint256 id,
    address user,
    address[] calldata tokens,
    uint256[] calldata amounts
  ) external;

  /**
    @notice Decreases the amount of a set of tokens invested in a strategy
    @param id  the strategy to withdraw assets from
    @param tokens  the tokens to withdraw
    @param amounts  The amounts to be withdrawn
     */
  function exitStrategy(
    uint256 id,
    address user,
    address[] calldata tokens,
    uint256[] calldata amounts
  ) external;

  /**
    @notice Getter function to return the nested arrays as well as the name
    @param id  the strategy to return
     */
  function getStrategy(uint256 id)
    external
    view
    returns (StrategySummary memory);

  /**
    @notice Returns the expected balance of a given token in a given integration
    @param integration  the integration the amount should be invested in
    @param token  the token that is being invested
    @return balance  the balance of the token that should be currently invested in the integration 
     */
  function getExpectedBalance(address integration, address token)
    external
    view
    returns (uint256 balance);

  /**
    @notice Returns the amount of a given token currently invested in a strategy
    @param id  the strategy id to check
    @param token  The token to retrieve the balance for
    @return amount  the amount of token that is invested in the strategy
     */
  function getStrategyTokenBalance(uint256 id, address token)
    external
    view
    returns (uint256 amount);

  /**
    @notice returns the amount of a given token a user has invested in a given strategy
    @param id  the strategy id
    @param token  the token address
    @param user  the user who holds the funds
    @return amount  the amount of token that the user has invested in the strategy 
     */
  function getUserStrategyBalanceByToken(
    uint256 id,
    address token,
    address user
  ) external view returns (uint256 amount);

  /**
    @notice Returns the amount of a given token that a user has invested across all strategies
    @param token  the token address
    @param user  the user holding the funds
    @return amount  the amount of tokens the user has invested across all strategies
     */
  function getUserInvestedAmountByToken(address token, address user)
    external
    view
    returns (uint256 amount);

  /**
    @notice Returns the total amount of a token invested across all strategies
    @param token  the token to fetch the balance for
    @return amount  the amount of the token currently invested
    */
  function getTokenTotalBalance(address token)
    external
    view
    returns (uint256 amount);

  /**
  @notice Returns the weight of an individual integration within the system
  @param integration  the integration to look up
  @return The weight of the integration
   */
  function getIntegrationWeight(address integration)
    external
    view
    returns (uint256);

  /**
  @notice Returns the sum of all weights in the system.
  @return The sum of all integration weights within the system
   */
  function getIntegrationWeightSum() external view returns (uint256);

  
  function idCounter() external view returns(uint256);
}

// 
pragma solidity ^0.8.4;

interface IYieldManager {
  
  function updateGasAccountTargetEthBalance(uint256 gasAccountTargetEthBalance_)
    external;

  
  
  
  
  function updateEthDistributionWeights(
    uint32 biosBuyBackEthWeight_,
    uint32 treasuryEthWeight_,
    uint32 protocolFeeEthWeight_,
    uint32 rewardsEthWeight_
  ) external;

  
  function updateGasAccount(address payable gasAccount_) external;

  
  function updateTreasuryAccount(address payable treasuryAccount_) external;

  
  function rebalance() external;

  
  function deploy() external;

  
  function harvestYield() external;

  
  function processYield() external;

  
  function distributeEth() external;

  
  function biosBuyBack() external;

  
  
  function getHarvestedTokenBalance(address tokenAddress)
    external
    view
    returns (uint256);

  
  
  function getReserveTokenBalance(address tokenAddress)
    external
    view
    returns (uint256);

  
  
  function getDesiredReserveTokenBalance(address tokenAddress)
    external
    view
    returns (uint256);

  
  function getEthWeightSum() external view returns (uint32 ethWeightSum);

  
  function getProcessedWethSum()
    external
    view
    returns (uint256 processedWethSum);

  
  
  function getProcessedWethByToken(address tokenAddress)
    external
    view
    returns (uint256);

  
  function getProcessedWethByTokenSum()
    external
    view
    returns (uint256 processedWethByTokenSum);

  
  
  function getTokenTotalIntegrationBalance(address tokenAddress)
    external
    view
    returns (uint256 tokenTotalIntegrationBalance);

  
  function getGasAccount() external view returns (address);

  
  function getTreasuryAccount() external view returns (address);

  
  function getLastEthRewardsAmount() external view returns (uint256);

  
  function getGasAccountTargetEthBalance() external view returns (uint256);

  
  
  
  
  function getEthDistributionWeights()
    external
    view
    returns (
      uint32,
      uint32,
      uint32,
      uint32
    );
}