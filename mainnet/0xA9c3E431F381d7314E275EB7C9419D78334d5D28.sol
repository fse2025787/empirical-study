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

interface IBiosRewards {
  
  
  
  function notifyRewardAmount(
    address token,
    uint256 reward,
    uint32 duration
  ) external;

  function increaseRewards(
    address token,
    address account,
    uint256 amount
  ) external;

  function decreaseRewards(
    address token,
    address account,
    uint256 amount
  ) external;

  function claimReward(address asset, address account)
    external
    returns (uint256 reward);

  function lastTimeRewardApplicable(address token)
    external
    view
    returns (uint256);

  function rewardPerToken(address token) external view returns (uint256);

  function earned(address token, address account)
    external
    view
    returns (uint256);

  function getUserBiosRewards(address account)
    external
    view
    returns (uint256 userBiosRewards);

  function getTotalClaimedBiosRewards() external view returns (uint256);

  function getTotalUserClaimedBiosRewards(address account)
    external
    view
    returns (uint256);

  function getBiosRewards() external view returns (uint256);
}

// 

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// 
pragma solidity ^0.8.4;








contract BiosRewards is
  Initializable,
  ModuleMapConsumer,
  Controlled,
  IBiosRewards
{
  uint256 private totalBiosRewards;
  uint256 private totalClaimedBiosRewards;
  mapping(address => uint256) private totalUserClaimedBiosRewards;
  mapping(address => uint256) public periodFinish;
  mapping(address => uint256) public rewardRate;
  mapping(address => uint256) public lastUpdateTime;
  mapping(address => uint256) public rewardPerTokenStored;
  mapping(address => mapping(address => uint256)) public userRewardPerTokenPaid;
  mapping(address => mapping(address => uint256)) public rewards;

  event RewardAdded(address indexed token, uint256 reward, uint32 duration);

  function initialize(address[] memory controllers_, address moduleMap_)
    public
    initializer
  {
    __Controlled_init(controllers_, moduleMap_);
    __ModuleMapConsumer_init(moduleMap_);
  }

  modifier updateReward(address token, address account) {
    rewardPerTokenStored[token] = rewardPerToken(token);
    lastUpdateTime[token] = lastTimeRewardApplicable(token);
    if (account != address(0)) {
      rewards[token][account] = earned(token, account);
      userRewardPerTokenPaid[token][account] = rewardPerTokenStored[token];
    }
    _;
  }

  
  
  
  function notifyRewardAmount(
    address token,
    uint256 reward,
    uint32 duration
  ) external override onlyController updateReward(token, address(0)) {
    if (block.timestamp >= periodFinish[token]) {
      rewardRate[token] = reward / duration;
    } else {
      uint256 remaining = periodFinish[token] - block.timestamp;
      uint256 leftover = remaining * rewardRate[token];
      rewardRate[token] = (reward + leftover) / duration;
    }
    lastUpdateTime[token] = block.timestamp;
    periodFinish[token] = block.timestamp + duration;
    totalBiosRewards += reward;
    emit RewardAdded(token, reward, duration);
  }

  function increaseRewards(
    address token,
    address account,
    uint256 amount
  ) public override onlyController updateReward(token, account) {
    require(amount > 0, "BiosRewards::increaseRewards: Cannot increase 0");
  }

  function decreaseRewards(
    address token,
    address account,
    uint256 amount
  ) public override onlyController updateReward(token, account) {
    require(amount > 0, "BiosRewards::decreaseRewards: Cannot decrease 0");
  }

  function claimReward(address token, address account)
    public
    override
    onlyController
    updateReward(token, account)
    returns (uint256 reward)
  {
    reward = earned(token, account);
    if (reward > 0) {
      rewards[token][account] = 0;
      totalBiosRewards -= reward;
      totalClaimedBiosRewards += reward;
      totalUserClaimedBiosRewards[account] += reward;
    }
    return reward;
  }

  function lastTimeRewardApplicable(address token)
    public
    view
    override
    returns (uint256)
  {
    return MathUpgradeable.min(block.timestamp, periodFinish[token]);
  }

  function rewardPerToken(address token)
    public
    view
    override
    returns (uint256)
  {
    uint256 totalSupply = IUserPositions(
      moduleMap.getModuleAddress(Modules.UserPositions)
    ).totalTokenBalance(token);
    if (totalSupply == 0) {
      return rewardPerTokenStored[token];
    }
    return
      rewardPerTokenStored[token] +
      (((lastTimeRewardApplicable(token) - lastUpdateTime[token]) *
        rewardRate[token] *
        1e18) / totalSupply);
  }

  function earned(address token, address account)
    public
    view
    override
    returns (uint256)
  {
    IUserPositions userPositions = IUserPositions(
      moduleMap.getModuleAddress(Modules.UserPositions)
    );
    return
      ((userPositions.userTokenBalance(token, account) *
        (rewardPerToken(token) - userRewardPerTokenPaid[token][account])) /
        1e18) + rewards[token][account];
  }

  function getUserBiosRewards(address account)
    external
    view
    override
    returns (uint256 userBiosRewards)
  {
    IIntegrationMap integrationMap = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    );

    for (
      uint256 tokenId;
      tokenId < integrationMap.getTokenAddressesLength();
      tokenId++
    ) {
      userBiosRewards += earned(
        integrationMap.getTokenAddress(tokenId),
        account
      );
    }
  }

  function getTotalClaimedBiosRewards()
    external
    view
    override
    returns (uint256)
  {
    return totalClaimedBiosRewards;
  }

  function getTotalUserClaimedBiosRewards(address account)
    external
    view
    override
    returns (uint256)
  {
    return totalUserClaimedBiosRewards[account];
  }

  function getBiosRewards() external view override returns (uint256) {
    return totalBiosRewards;
  }
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

  
  
  function addIntegration(address contractAddress, string memory name) external;

  
  
  
  
  
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

interface IUserPositions {
  
  function setBiosRewardsDuration(uint32 biosRewardsDuration_) external;

  
  
  function seedBiosRewards(address sender, uint256 biosAmount) external;

  
  function increaseBiosRewards() external;

  
  
  
  
  
  function deposit(
    address depositor,
    address[] memory tokens,
    uint256[] memory amounts,
    uint256 ethAmount
  ) external;

  
  
  
  
  
  function withdraw(
    address recipient,
    address[] memory tokens,
    uint256[] memory amounts,
    bool withdrawWethAsEth
  ) external returns (uint256 ethWithdrawn);

  
  
  
  
  
  
  
  
  function withdrawAllAndClaim(
    address recipient,
    address[] memory tokens,
    bool withdrawWethAsEth
  )
    external
    returns (
      uint256[] memory tokenAmounts,
      uint256 ethWithdrawn,
      uint256 ethClaimed,
      uint256 biosClaimed
    );

  
  function claimEthRewards(address user) external returns (uint256 ethClaimed);

  
  
  function claimBiosRewards(address recipient)
    external
    returns (uint256 biosClaimed);

  
  
  function totalTokenBalance(address asset) external view returns (uint256);

  
  
  function userTokenBalance(address asset, address account)
    external
    view
    returns (uint256);

  
  function getBiosRewardsDuration() external view returns (uint32);

  
  
  
  
  
  function transferToStrategy(
    address recipient,
    address[] memory tokens,
    uint256[] memory amounts
  ) external;

  
  
  
  
  
  function transferFromStrategy(
    address recipient,
    address[] memory tokens,
    uint256[] memory amounts
  ) external;
}