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

    function __Controlled_init(
        address[] memory controllers_,
        address moduleMap_
    ) public initializer {
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
            IKernel(moduleMap.getModuleAddress(Modules.Kernel)).isOwner(
                msg.sender
            ),
            "Controlled::onlyOwner: Caller is not owner"
        );
        _;
    }

    modifier onlyManager() {
        require(
            IKernel(moduleMap.getModuleAddress(Modules.Kernel)).isManager(
                msg.sender
            ),
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
        IStrategyMap.Integration[] calldata integrations,
        IStrategyMap.Token[] calldata tokens
    ) external;

    /**
        @notice Updates a strategy's name
        @dev This is a pass through function to StrategyMap.updateName
     */
    function updateStrategyName(uint256 id, string calldata name) external;

    /**
      @notice Updates the tokens that a strategy accepts
      @dev This is a passthrough to StrategyMap.updateStrategyTokens
       */
    function updateStrategy(
        uint256 id,
        IStrategyMap.Integration[] calldata integrations,
        IStrategyMap.Token[] calldata tokens
    ) external;

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
        IStrategyMap.Integration[] calldata integrations,
        IStrategyMap.Token[] calldata tokens
    ) external override onlyManager {
        IIntegrationMap integrationMap = IIntegrationMap(
            moduleMap.getModuleAddress(Modules.IntegrationMap)
        );
        for (uint256 i = 0; i < integrations.length; i++) {
            require(
                integrationMap.getIsIntegrationAdded(
                    integrations[i].integration
                )
            );
        }
        IStrategyMap(moduleMap.getModuleAddress(Modules.StrategyMap))
            .addStrategy(name, integrations, tokens);
    }

    /**
    @notice Updates the whitelisted tokens a strategy accepts for new deposits
    @dev This is a passthrough to StrategyMap.updateStrategyTokens
     */
    function updateStrategy(
        uint256 id,
        IStrategyMap.Integration[] calldata integrations,
        IStrategyMap.Token[] calldata tokens
    ) external override onlyManager {
        IIntegrationMap integrationMap = IIntegrationMap(
            moduleMap.getModuleAddress(Modules.IntegrationMap)
        );
        for (uint256 i = 0; i < integrations.length; i++) {
            require(
                integrationMap.getIsIntegrationAdded(
                    integrations[i].integration
                )
            );
        }
        IStrategyMap(moduleMap.getModuleAddress(Modules.StrategyMap))
            .updateStrategy(id, integrations, tokens);
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
        IStrategyMap(moduleMap.getModuleAddress(Modules.StrategyMap))
            .updateName(id, name);
    }

    /**
        @notice Deletes a strategy
        @dev This is a pass through to StrategyMap.deleteStrategy
        */
    function deleteStrategy(uint256 id) external override onlyManager {
        IStrategyMap(moduleMap.getModuleAddress(Modules.StrategyMap))
            .deleteStrategy(id);
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

interface IIntegrationMap {
    struct Integration {
        bool added;
        string name;
    }

    struct Token {
        uint256 id;
        bool added;
        bool acceptingDeposits;
        bool acceptingWithdrawals;
        uint256 biosRewardWeight;
        uint256 reserveRatioNumerator;
    }

    
    
    function addIntegration(address contractAddress, string memory name)
        external;

    
    
    
    
    
    function addToken(
        address tokenAddress,
        bool acceptingDeposits,
        bool acceptingWithdrawals,
        uint256 biosRewardWeight,
        uint256 reserveRatioNumerator
    ) external;

    
    function enableTokenDeposits(address tokenAddress) external;

    
    function disableTokenDeposits(address tokenAddress) external;

    
    function enableTokenWithdrawals(address tokenAddress) external;

    
    function disableTokenWithdrawals(address tokenAddress) external;

    
    
    function updateTokenRewardWeight(address tokenAddress, uint256 rewardWeight)
        external;

    
    
    function updateTokenReserveRatioNumerator(
        address tokenAddress,
        uint256 reserveRatioNumerator
    ) external;

    
    
    function getIntegrationAddress(uint256 integrationId)
        external
        view
        returns (address);

    
    
    function getIntegrationName(address integrationAddress)
        external
        view
        returns (string memory);

    
    function getWethTokenAddress() external view returns (address);

    
    function getBiosTokenAddress() external view returns (address);

    
    
    function getTokenAddress(uint256 tokenId) external view returns (address);

    
    
    function getTokenId(address tokenAddress) external view returns (uint256);

    
    
    function getTokenBiosRewardWeight(address tokenAddress)
        external
        view
        returns (uint256);

    
    function getBiosRewardWeightSum()
        external
        view
        returns (uint256 rewardWeightSum);

    
    
    function getTokenAcceptingDeposits(address tokenAddress)
        external
        view
        returns (bool);

    
    
    function getTokenAcceptingWithdrawals(address tokenAddress)
        external
        view
        returns (bool);

    // @param tokenAddress The address of the token ERC20 contract
    // @return bool indicating whether the token has been added
    function getIsTokenAdded(address tokenAddress) external view returns (bool);

    // @param integrationAddress The address of the integration contract
    // @return bool indicating whether the integration has been added
    function getIsIntegrationAdded(address tokenAddress)
        external
        view
        returns (bool);

    
    
    function getTokenAddressesLength() external view returns (uint256);

    
    
    function getIntegrationAddressesLength() external view returns (uint256);

    
    
    function getTokenReserveRatioNumerator(address tokenAddress)
        external
        view
        returns (uint256);

    
    function getReserveRatioDenominator() external view returns (uint32);
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
  struct Integration {
    address integration;
    uint32 ammPoolID;
  }
  struct Token {
    uint256 integrationPairIdx;
    address token;
    uint32 weight;
  }

  struct Strategy {
    string name;
    Integration[] integrations;
    Token[] tokens;
    mapping(address => bool) availableTokens;
  }

  struct StrategyRecord {
    uint256 strategyId;
    uint256 timestamp;
  }

  struct StrategySummary {
    string name;
    Integration[] integrations;
    Token[] tokens;
  }

  struct TokenMovement {
    address token;
    uint256 amount;
  }

  struct StrategyBalance {
    uint256 strategyID;
    GeneralBalance[] tokens;
  }

  struct GeneralBalance {
    address token;
    uint256 balance;
  }

  // #### Events
  // NewStrategy, UpdateName, UpdateStrategy, DeleteStrategy, EnterStrategy, ExitStrategy
  event NewStrategy(
    uint256 indexed id,
    Integration[] integrations,
    Token[] tokens,
    string name
  );
  event UpdateName(uint256 indexed id, string name);
  event UpdateStrategy(
    uint256 indexed id,
    Integration[] integrations,
    Token[] tokens
  );
  event DeleteStrategy(uint256 indexed id);
  event EnterStrategy(
    uint256 indexed id,
    address indexed user,
    TokenMovement[] tokens
  );
  event ExitStrategy(
    uint256 indexed id,
    address indexed user,
    TokenMovement[] tokens
  );

  // #### Functions
  /**
     @notice Adds a new strategy to the list of available strategies
     @param name  the name of the new strategy
     @param integrations  the integrations and weights that form the strategy
     */
  function addStrategy(
    string calldata name,
    Integration[] calldata integrations,
    Token[] calldata tokens
  ) external;

  /**
    @notice Updates the strategy name
    @param name  the new name
     */
  function updateName(uint256 id, string calldata name) external;

  /**
    @notice Updates a strategy's integrations and tokens
    @param id  the strategy to update
    @param integrations  the new integrations that will be used
    @param tokens  the tokens accepted for new entries
    */
  function updateStrategy(
    uint256 id,
    Integration[] calldata integrations,
    Token[] calldata tokens
  ) external;

  /**
    @notice Deletes a strategy
    @dev This can only be called successfully if the strategy being deleted doesn't have any assets invested in it.
    @dev To delete a strategy with funds deployed in it, first update the strategy so that the existing tokens are no longer available in the strategy, then delete the strategy. This will unwind the users positions, and they will be able to withdraw their funds.
    @param id  the strategy to delete
     */
  function deleteStrategy(uint256 id) external;

  /**
    @notice Increases the amount of a set of tokens in a strategy
    @param id  the strategy to deposit into
    @param tokens  the tokens to deposit
    @param user  the user making the deposit
     */
  function enterStrategy(
    uint256 id,
    address user,
    TokenMovement[] calldata tokens
  ) external;

  /**
    @notice Decreases the amount of a set of tokens invested in a strategy
    @param id  the strategy to withdraw assets from
    @param tokens  details of the tokens being deposited
    @param user  the user making the withdrawal
     */
  function exitStrategy(
    uint256 id,
    address user,
    TokenMovement[] calldata tokens
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
    @notice Decreases the deployable amount after a deployment/withdrawal
    @param integration  the integration that was changed
    @param poolID  the pool within the integration that handled the tokens
    @param token  the token to decrease for
    @param amount  the amount to reduce the vector by
     */
  function decreaseDeployAmountChange(
    address integration,
    uint32 poolID,
    address token,
    uint256 amount
  ) external;

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
    @notice Returns the current amount awaiting deployment
    @param integration  the integration to deploy to
    @param poolID  the pool within the integration that should receive the tokens
    @param token  the token to be deployed
    @return the pending deploy amount
     */
  function getDeployAmount(
    address integration,
    uint32 poolID,
    address token
  ) external view returns (int256);

  /**
    @notice Returns a list of pool IDs for a given integration and token
    @param integration  the integration that contains the pool
    @param token  the token the pool takes
    @return an array of pool ids
     */
  function getPools(address integration, address token)
    external
    view
    returns (uint32[] memory);

  /**
    @notice Returns the amount a user has requested for withdrawal
    @dev To be used when withdrawing funds to a user's wallet in UserPositions contract
    @param user  the user requesting withdrawal
    @param token  the token the user is withdrawing
    @return the amount the user is requesting
     */
  function getUserWithdrawalVector(
    address user,
    address token,
    address integration,
    uint32 poolID
  ) external view returns (uint256);

  /**
    @notice Updates a user's withdrawal vector
    @dev This will decrease the user's withdrawal amount by the requested amount or 0 if the withdrawal amount is < amount. 
    @param user  the user who has withdrawn funds
    @param token  the token the user withdrew
    @param amount  the amount the user withdrew
     */
  function updateUserWithdrawalVector(
    address user,
    address token,
    address integration,
    uint32 poolID,
    uint256 amount
  ) external;

  /**
    @notice Returns a user's balances for requested strategies, and the users total invested amounts for each token requested
    @param user  the user to request for
    @param _strategies  the strategies to get balances for
    @param _tokens  the tokens to get balances for
    @return userStrategyBalances  The user's invested funds in the strategies
    @return userBalance  User total token balances
     */
  function getUserBalances(
    address user,
    uint256[] calldata _strategies,
    address[] calldata _tokens
  )
    external
    view
    returns (
      StrategyBalance[] memory userStrategyBalances,
      GeneralBalance[] memory userBalance
    );

  /**
    @notice Returns balances per strategy, and total invested balances
    @param _strategies  The strategies to retrieve balances for
    @param _tokens  The tokens to retrieve
     */
  function getStrategyBalances(
    uint256[] calldata _strategies,
    address[] calldata _tokens
  )
    external
    view
    returns (
      StrategyBalance[] memory strategyBalances,
      GeneralBalance[] memory generalBalances
    );

  /**
  @notice Returns 1 or more strategies in a single call.
  @param ids  The ids of the strategies to return.
   */
  function getMultipleStrategies(uint256[] calldata ids)
    external
    view
    returns (StrategySummary[] memory);

  
  function idCounter() external view returns (uint256);
}

// 
pragma solidity ^0.8.4;

interface IYieldManager {
    // #### Structs

    struct DeployRequest {
        address integration;
        address[] tokens; // If ammPoolID > 0, this should contain exactly two addresses
        uint32 ammPoolID; // The pool to deposit into. This is 0 for non-AMM integrations
    }

    // #### Functions
    
    function updateGasAccountTargetEthBalance(
        uint256 gasAccountTargetEthBalance_
    ) external;

    
    
    
    
    function updateEthDistributionWeights(
        uint32 biosBuyBackEthWeight_,
        uint32 treasuryEthWeight_,
        uint32 protocolFeeEthWeight_,
        uint32 rewardsEthWeight_
    ) external;

    
    function updateGasAccount(address payable gasAccount_) external;

    
    function updateTreasuryAccount(address payable treasuryAccount_) external;

    
    function deploy(DeployRequest[] calldata deployments) external;

    
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