// SPDX-License-Identifier: AGPL-3.0
pragma experimental ABIEncoderV2;

// 
pragma solidity ^0.8.15;


enum VaultType {
    LEGACY,
    DEFAULT,
    AUTOMATED
}

interface IDetails {
    // get details from curve
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);
}

interface IGaugeController {
    // check if gauge has weight
    function get_gauge_weight(address) external view returns (uint256);
}

interface IVoter {
    // get details from our curve voter
    function strategy() external view returns (address);
}

interface IProxy {
    function approveStrategy(address gauge, address strategy) external;

    function strategies(address gauge) external view returns (address);
}

interface IRegistry {
    function newVault(
        address _token,
        address _governance,
        address _guardian,
        address _rewards,
        string calldata _name,
        string calldata _symbol,
        uint256 _releaseDelta,
        uint256 _type
    ) external returns (address);

    function latestVaultOfType(
        address token,
        uint256 _type
    ) external view returns (address);
}

interface IPoolManager {
    function addPool(address _gauge) external returns (bool);
}

interface IPoolRegistry {
    function poolInfo(
        uint256 _pid
    )
        external
        view
        returns (
            address implementation,
            address stakingAddress,
            address stakingToken,
            address rewardsAddress,
            uint8 isActive
        );

    function poolLength() external view returns (uint256);
}

interface IStakingToken {
    function convexPoolId() external view returns (uint256);
}

interface ICurveGauge {
    function deposit(uint256) external;

    function balanceOf(address) external view returns (uint256);

    function withdraw(uint256) external;

    function claim_rewards() external;

    function reward_tokens(uint256) external view returns (address); //v2

    function rewarded_token() external view returns (address); //v1

    function lp_token() external view returns (address);
}

interface IStrategy {
    function cloneStrategyConvex(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        address _tradeFactory,
        uint256 _pid,
        uint256 _harvestProfitMinInUsdc,
        uint256 _harvestProfitMaxInUsdc,
        address _booster,
        address _convexToken
    ) external returns (address newStrategy);

    function cloneStrategyCurveBoosted(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        address _tradeFactory,
        address _proxy,
        address _gauge
    ) external returns (address newStrategy);

    function cloneStrategyConvexFrax(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        address _tradeFactory,
        uint256 _fraxPid,
        address _stakingAddress,
        uint256 _harvestProfitMinInUsdc,
        uint256 _harvestProfitMaxInUsdc,
        address _booster
    ) external returns (address newStrategy);

    function setVoter(address _curveVoter) external;

    function setVoters(address _curveVoter, address _convexVoter) external;

    function setVoters(
        address _curveVoter,
        address _convexVoter,
        address _fxsVoter
    ) external;

    function setLocalKeepCrvs(
        uint256 _keepCrv,
        uint256 _keepCvx,
        uint256 _keepFxs
    ) external;

    function setLocalKeepCrvs(uint256 _keepCrv, uint256 _keepCvx) external;

    function setLocalKeepCrv(uint256 _keepCrv) external;

    function setHealthCheck(address) external;

    function setBaseFeeOracle(address) external;
}

interface IBooster {
    function gaugeMap(address) external view returns (bool);

    // deposit into convex, receive a tokenized deposit.  parameter to stake immediately (we always do this).
    function deposit(
        uint256 _pid,
        uint256 _amount,
        bool _stake
    ) external returns (bool);

    // burn a tokenized deposit (Convex deposit tokens) to receive curve lp tokens back
    function withdraw(uint256 _pid, uint256 _amount) external returns (bool);

    function poolLength() external view returns (uint256);

    // give us info about a pool based on its pid
    function poolInfo(
        uint256
    ) external view returns (address, address, address, address, address, bool);
}

interface Vault {
    function setGovernance(address) external;

    function setManagement(address) external;

    function managementFee() external view returns (uint256);

    function setManagementFee(uint256) external;

    function performanceFee() external view returns (uint256);

    function setPerformanceFee(uint256) external;

    function setDepositLimit(uint256) external;

    function addStrategy(address, uint256, uint256, uint256, uint256) external;
}

contract CurveGlobal {
    event NewAutomatedVault(
        uint256 indexed category,
        address indexed lpToken,
        address gauge,
        address indexed vault,
        address convexStrategy,
        address curveStrategy,
        address convexFraxStrategy
    );

    /* ========== STATE VARIABLES ========== */

    
    address[] public deployedVaults;

    
    
    uint256 public constant CATEGORY = 0;

    
    address public owner;

    // @notice Pending owner of the factory.
    
    address public pendingOwner;

    
    address public constant CVX = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;

    
    
    address public convexPoolManager =
        0xD1f9b3de42420A295C33c07aa5C9e04eDC6a4447;

    
    
    address public convexFraxPoolRegistry =
        0x41a5881c17185383e19Df6FA4EC158a6F4851A69;

    
    IRegistry public registry;

    
    IBooster public booster =
        IBooster(0xF403C135812408BFbE8713b5A23a04b3D48AAE31);

    
    IBooster public fraxBooster =
        IBooster(0x569f5B842B5006eC17Be02B8b94510BA8e79FbCa);

    
    address public governance = 0xFEB4acf3df3cDEA7399794D0869ef76A6EfAff52;

    
    address public management = 0x16388463d60FFE0661Cf7F1f31a7D658aC790ff7;

    
    address public guardian = 0x846e211e8ba920B353FB717631C015cf04061Cc9;

    
    address public treasury = 0x93A62dA5a14C80f265DAbC077fCEE437B1a0Efde;

    
    address public keeper = 0x256e6a486075fbAdbB881516e9b6b507fd082B5D;

    
    address public healthCheck = 0xDDCea799fF1699e98EDF118e0629A974Df7DF012;

    
    address public tradeFactory = 0xd6a8ae62f4d593DAf72E2D7c9f7bDB89AB069F06;

    
    address public baseFeeOracle = 0x1E7eFAbF282614Aa2543EDaA50517ef5a23c868b;

    
    
    address public convexStratImplementation;

    
    
    address public curveStratImplementation;

    
    
    address public convexFraxStratImplementation;

    
    uint256 public keepCRV;

    
    address public curveVoter = 0xF147b8125d2ef93FB6965Db97D6746952a133934;

    
    uint256 public keepCVX;

    
    address public convexVoter;

    
    uint256 public keepFXS;

    
    address public fraxVoter;

    
    uint256 public harvestProfitMinInUsdc = 7_500 * 1e6;

    
    uint256 public harvestProfitMaxInUsdc = 100_000 * 1e6;

    
    uint256 public performanceFee = 1_000;

    
    uint256 public managementFee = 0;

    
    uint256 public depositLimit = 10_000_000_000_000 * 1e18;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _registry,
        address _convexStratImplementation,
        address _curveStratImplementation,
        address _convexFraxStratImplementation,
        address _owner
    ) {
        registry = IRegistry(_registry);
        convexStratImplementation = _convexStratImplementation;
        curveStratImplementation = _curveStratImplementation;
        convexFraxStratImplementation = _convexFraxStratImplementation;
        owner = _owner;
        pendingOwner = _owner;
    }

    /* ========== STATE VARIABLE SETTERS ========== */

    
    
    ///  New owner will have to accept before transition is complete.
    
    function setOwner(address newOwner) external {
        if (msg.sender != owner) {
            revert();
        }
        pendingOwner = newOwner;
    }

    
    
    function acceptOwner() external {
        if (msg.sender != pendingOwner) {
            revert();
        }
        owner = pendingOwner;
    }

    
    
    
    function setConvexPoolManager(address _convexPoolManager) external {
        if (msg.sender != owner) {
            revert();
        }
        convexPoolManager = _convexPoolManager;
    }

    
    
    
    function setConvexFraxPoolRegistry(
        address _convexFraxPoolRegistry
    ) external {
        if (msg.sender != owner) {
            revert();
        }
        convexFraxPoolRegistry = _convexFraxPoolRegistry;
    }

    
    
    
    function setRegistry(address _registry) external {
        if (msg.sender != owner) {
            revert();
        }
        registry = IRegistry(_registry);
    }

    
    
    
    function setBooster(address _booster) external {
        if (msg.sender != owner) {
            revert();
        }
        booster = IBooster(_booster);
    }

    
    
    
    function setFraxBooster(address _fraxBooster) external {
        if (msg.sender != owner) {
            revert();
        }
        fraxBooster = IBooster(_fraxBooster);
    }

    
    
    
    function setGovernance(address _governance) external {
        if (msg.sender != owner) {
            revert();
        }
        governance = _governance;
    }

    
    
    
    function setManagement(address _management) external {
        if (msg.sender != owner) {
            revert();
        }
        management = _management;
    }

    
    
    
    function setGuardian(address _guardian) external {
        if (msg.sender != owner) {
            revert();
        }
        guardian = _guardian;
    }

    
    
    
    function setTreasury(address _treasury) external {
        if (msg.sender != owner) {
            revert();
        }
        treasury = _treasury;
    }

    
    
    
    function setKeeper(address _keeper) external {
        if (!(msg.sender == owner || msg.sender == management)) {
            revert();
        }
        keeper = _keeper;
    }

    
    
    ///  ensure that harvest profits are within expected limits before executing.
    
    function setHealthcheck(address _health) external {
        if (!(msg.sender == owner || msg.sender == management)) {
            revert();
        }
        healthCheck = _health;
    }

    
    
    
    function setTradeFactory(address _tradeFactory) external {
        if (msg.sender != owner) {
            revert();
        }
        tradeFactory = _tradeFactory;
    }

    
    
    ///  fee so strategy can avoid harvesting during periods of network congestion.
    
    function setBaseFeeOracle(address _baseFeeOracle) external {
        if (!(msg.sender == owner || msg.sender == management)) {
            revert();
        }
        baseFeeOracle = _baseFeeOracle;
    }

    
    
    
    function setDepositLimit(uint256 _depositLimit) external {
        if (!(msg.sender == owner || msg.sender == management)) {
            revert();
        }
        depositLimit = _depositLimit;
    }

    
    
    
    function setConvexStratImplementation(
        address _convexStratImplementation
    ) external {
        if (msg.sender != owner) {
            revert();
        }
        convexStratImplementation = _convexStratImplementation;
    }

    
    
    
    function setCurveStratImplementation(
        address _curveStratImplementation
    ) external {
        if (msg.sender != owner) {
            revert();
        }
        curveStratImplementation = _curveStratImplementation;
    }

    
    
    
    function setConvexFraxStratImplementation(
        address _convexFraxStratImplementation
    ) external {
        if (msg.sender != owner) {
            revert();
        }
        convexFraxStratImplementation = _convexFraxStratImplementation;
    }

    
    
    
    
    function setKeepCRV(uint256 _keepCRV, address _curveVoter) external {
        if (msg.sender != owner) {
            revert();
        }
        if (_keepCRV > 10_000) {
            revert();
        }

        // since we use the voter to pull our strategyProxy, can't be zero address
        if (_curveVoter == address(0)) {
            revert();
        }

        keepCRV = _keepCRV;
        curveVoter = _curveVoter;
    }

    
    
    
    
    function setKeepCVX(uint256 _keepCVX, address _convexVoter) external {
        if (msg.sender != owner) {
            revert();
        }
        if (_keepCVX > 10_000) {
            revert();
        }
        if (_keepCVX > 0) {
            if (_convexVoter == address(0)) {
                revert();
            }
        }

        keepCVX = _keepCVX;
        convexVoter = _convexVoter;
    }

    
    
    
    
    function setKeepFXS(uint256 _keepFXS, address _fraxVoter) external {
        if (msg.sender != owner) {
            revert();
        }
        if (_keepFXS > 10_000) {
            revert();
        }
        if (_keepFXS > 0) {
            if (_fraxVoter == address(0)) {
                revert();
            }
        }

        keepFXS = _keepFXS;
        fraxVoter = _fraxVoter;
    }

    
    
    ///  Must be called by owner or management.
    
    function setHarvestProfitMinInUsdc(
        uint256 _harvestProfitMinInUsdc
    ) external {
        if (!(msg.sender == owner || msg.sender == management)) {
            revert();
        }
        harvestProfitMinInUsdc = _harvestProfitMinInUsdc;
    }

    
    
    ///  Must be called by owner or management.
    
    function setHarvestProfitMaxInUsdc(
        uint256 _harvestProfitMaxInUsdc
    ) external {
        if (!(msg.sender == owner || msg.sender == management)) {
            revert();
        }
        harvestProfitMaxInUsdc = _harvestProfitMaxInUsdc;
    }

    
    
    ///  Default amount is 10%.
    
    function setPerformanceFee(uint256 _performanceFee) external {
        if (msg.sender != owner) {
            revert();
        }
        if (_performanceFee > 5_000) {
            revert();
        }
        performanceFee = _performanceFee;
    }

    
    
    ///  Default amount is 0%.
    
    function setManagementFee(uint256 _managementFee) external {
        if (msg.sender != owner) {
            revert();
        }
        if (_managementFee > 1_000) {
            revert();
        }
        managementFee = _managementFee;
    }

    /* ========== VIEWS ========== */

    
    
    function allDeployedVaults() external view returns (address[] memory) {
        return deployedVaults;
    }

    
    
    function numVaults() external view returns (uint256) {
        return deployedVaults.length;
    }

    
    ///  create a vault for corresponding LP token.
    
    
    function canCreateVaultPermissionlessly(
        address _gauge
    ) public view returns (bool) {
        return latestStandardVaultFromGauge(_gauge) == address(0);
    }

    
    ///  If no vault of either LEGACY, DEFAULT, or AUTOMATED types exists for this gauge, 0x0 is returned from registry.
    
    
    function latestStandardVaultFromGauge(
        address _gauge
    ) public view returns (address) {
        address lptoken = ICurveGauge(_gauge).lp_token();
        address latest;

        // we only care about types 0-2 here, so enforce that
        for (uint256 i; i < 3; ++i) {
            latest = registry.latestVaultOfType(lptoken, i);
            if (latest != address(0)) {
                break;
            }
        }
        return latest;
    }

    
    
    ///  though in reality our curve voter should always stay the same.
    
    
    function doesStrategyProxyHaveGauge(
        address _gauge
    ) public view returns (bool) {
        address strategyProxy = getProxy();
        return IProxy(strategyProxy).strategies(_gauge) != address(0);
    }

    
    
    
    
    function getPid(address _gauge) public view returns (uint256 pid) {
        IBooster _booster = booster;
        if (!_booster.gaugeMap(_gauge)) {
            return type(uint256).max;
        }

        for (uint256 i = _booster.poolLength(); i > 0; --i) {
            //we start at the end and work back for most recent
            (, , address gauge, , , ) = _booster.poolInfo(i - 1);

            if (_gauge == gauge) {
                return i - 1;
            }
        }
    }

    
    
    
    
    
    
    function getFraxInfo(
        uint256 _convexPid
    )
        public
        view
        returns (
            bool hasFraxPool,
            uint256 convexFraxPid,
            address stakingAddress
        )
    {
        IPoolRegistry _convexFraxPoolRegistry = IPoolRegistry(
            convexFraxPoolRegistry
        );
        for (uint256 i = _convexFraxPoolRegistry.poolLength(); i > 0; --i) {
            // we start at the end and work back for most recent
            (
                ,
                address _stakingAddress,
                address stakingToken,
                ,
                uint8 isActive
            ) = _convexFraxPoolRegistry.poolInfo(i - 1);
            if (isActive == 0) {
                // pool isn't active, skip
                continue;
            }

            // check the convex pool pid for this frax pool pid. some staking tokens don't have this view
            try IStakingToken(stakingToken).convexPoolId() returns (
                uint256 currentPoolConvexPid
            ) {
                if (_convexPid == currentPoolConvexPid) {
                    return (true, (i - 1), _stakingAddress);
                }
            } catch {}
        }
    }

    
    
    function getProxy() public view returns (address proxy) {
        proxy = IVoter(curveVoter).strategy();
    }

    /* ========== CORE FUNCTIONS ========== */

    
    
    ///  Must be called by owner or management.
    
    
    
    
    
    
    
    function createNewVaultsAndStrategiesPermissioned(
        address _gauge,
        string memory _name,
        string memory _symbol
    )
        external
        returns (
            address vault,
            address convexStrategy,
            address curveStrategy,
            address convexFraxStrategy
        )
    {
        if (!(msg.sender == owner || msg.sender == management)) {
            revert();
        }

        return _createNewVaultsAndStrategies(_gauge, true, _name, _symbol);
    }

    
    
    ///  then this call will revert.
    
    
    
    
    
    function createNewVaultsAndStrategies(
        address _gauge
    )
        external
        returns (
            address vault,
            address convexStrategy,
            address curveStrategy,
            address convexFraxStrategy
        )
    {
        return
            _createNewVaultsAndStrategies(_gauge, false, "default", "default");
    }

    // create a new vault along with strategies to match
    function _createNewVaultsAndStrategies(
        address _gauge,
        bool _permissionedUser,
        string memory _name,
        string memory _symbol
    )
        internal
        returns (
            address vault,
            address convexStrategy,
            address curveStrategy,
            address convexFraxStrategy
        )
    {
        // a curve gauge must have weight for a vault to be deployed
        IGaugeController gaugeController = IGaugeController(
            0x2F50D538606Fa9EDD2B11E2446BEb18C9D5846bB
        );
        require(
            gaugeController.get_gauge_weight(_gauge) > 0,
            "Gauge must have weight"
        );

        // if a legacy vault already exists, only permissioned users can deploy another
        if (!_permissionedUser) {
            require(
                canCreateVaultPermissionlessly(_gauge),
                "Vault already exists"
            );
        }
        address lptoken = ICurveGauge(_gauge).lp_token();

        // make sure we don't already have a curve strategy setup for this gauge
        require(
            !doesStrategyProxyHaveGauge(_gauge),
            "Voter strategy already exists"
        );

        // get convex pid. if no pid create one
        uint256 pid = getPid(_gauge);
        if (pid == type(uint256).max) {
            //when we add the new pool it will be added to the end of the pools in convexDeposit.
            pid = booster.poolLength();
            //add pool
            require(
                IPoolManager(convexPoolManager).addPool(_gauge),
                "Unable to add pool to Convex"
            );
        }

        if (_permissionedUser) {
            // allow trusted users to input the name and symbol or deploy a factory version of a legacy vault
            vault = _createCustomVault(lptoken, _name, _symbol);
        } else {
            // anyone can create a vault, but it will have an auto-generated name and symbol
            vault = _createStandardVault(lptoken);
        }

        // setup our fees, deposit limit, gov, etc
        _setupVaultParams(vault);

        // setup our strategies as needed
        (convexStrategy, curveStrategy, convexFraxStrategy) = _setupStrategies(
            vault,
            _gauge,
            pid
        );

        emit NewAutomatedVault(
            CATEGORY,
            lptoken,
            _gauge,
            vault,
            convexStrategy,
            curveStrategy,
            convexFraxStrategy
        );
    }

    // permissioned users may pass custom name and symbol inputs
    function _createCustomVault(
        address lptoken,
        string memory _name,
        string memory _symbol
    ) internal returns (address vault) {
        vault = registry.newVault(
            lptoken,
            address(this),
            guardian,
            treasury,
            _name,
            _symbol,
            0,
            uint256(VaultType.AUTOMATED)
        );
    }

    // standard vaults create default name and symbols using on-chain data
    function _createStandardVault(
        address lptoken
    ) internal returns (address vault) {
        vault = registry.newVault(
            lptoken,
            address(this),
            guardian,
            treasury,
            string(
                abi.encodePacked(
                    "Curve ",
                    IDetails(address(lptoken)).symbol(),
                    " Factory yVault"
                )
            ),
            string(
                abi.encodePacked(
                    "yvCurve-",
                    IDetails(address(lptoken)).symbol(),
                    "-f"
                )
            ),
            0,
            uint256(VaultType.AUTOMATED)
        );
    }

    // set vault management, gov, deposit limit, and fees
    function _setupVaultParams(address _vault) internal {
        // record our new vault for posterity
        deployedVaults.push(_vault);

        Vault v = Vault(_vault);
        v.setManagement(management);

        // set governance to ychad who needs to accept before it is finalised. until then governance is this factory
        v.setGovernance(governance);
        v.setDepositLimit(depositLimit);

        if (v.managementFee() != managementFee) {
            v.setManagementFee(managementFee);
        }
        if (v.performanceFee() != performanceFee) {
            v.setPerformanceFee(performanceFee);
        }
    }

    // time to attach our strategies to the vault
    function _setupStrategies(
        address _vault,
        address _gauge,
        uint256 _pid
    )
        internal
        returns (
            address convexStrategy,
            address curveStrategy,
            address convexFraxStrategy
        )
    {
        // check if we can add a convex frax strategy for this pool, ganache can't handle this (use tenderly)
        (
            bool hasFraxPool,
            uint256 fraxPid,
            address stakingAddress
        ) = getFraxInfo(_pid);

        // we have a frax implementation, so we know we at least want convex and curve boosted strategies
        convexStrategy = _addConvexStrategy(_vault, _pid);
        curveStrategy = _addCurveStrategy(_vault, _gauge, hasFraxPool);

        if (hasFraxPool) {
            // we attach a frax strategy here since this is a frax pool
            convexFraxStrategy = _addConvexFraxStrategy(
                _vault,
                fraxPid,
                stakingAddress
            );
        }
    }

    // deploy and attach a new convex strategy using our factory's existing implementation
    function _addConvexStrategy(
        address _vault,
        uint256 _pid
    ) internal returns (address convexStrategy) {
        convexStrategy = IStrategy(convexStratImplementation)
            .cloneStrategyConvex(
                _vault,
                management,
                treasury,
                keeper,
                tradeFactory,
                _pid,
                harvestProfitMinInUsdc,
                harvestProfitMaxInUsdc,
                address(booster),
                CVX
            );

        // set up health check and the base fee oracle for our new strategy
        IStrategy(convexStrategy).setHealthCheck(healthCheck);
        IStrategy(convexStrategy).setBaseFeeOracle(baseFeeOracle);

        // if we're keeping any tokens, then setup our voters
        if (keepCRV > 0 || keepCVX > 0) {
            IStrategy(convexStrategy).setVoters(curveVoter, convexVoter);
            IStrategy(convexStrategy).setLocalKeepCrvs(keepCRV, keepCVX);
        }

        // convex debtRatio can always start at 0
        Vault(_vault).addStrategy(convexStrategy, 0, 0, type(uint256).max, 0);
    }

    // deploy and attach a new curve boosted strategy using our factory's existing implementation
    function _addCurveStrategy(
        address _vault,
        address _gauge,
        bool _hasFraxPool
    ) internal returns (address curveStrategy) {
        // pull our strategyProxy from our voter
        IProxy proxy = IProxy(getProxy());

        // create the curve voter strategy
        curveStrategy = IStrategy(curveStratImplementation)
            .cloneStrategyCurveBoosted(
                _vault,
                management,
                treasury,
                keeper,
                tradeFactory,
                address(proxy),
                _gauge
            );

        // set up health check and the base fee oracle for our new strategy
        IStrategy(curveStrategy).setHealthCheck(healthCheck);
        IStrategy(curveStrategy).setBaseFeeOracle(baseFeeOracle);

        // must set our voter, this is used to deposit
        IStrategy(curveStrategy).setVoter(curveVoter);

        // if we're keeping any tokens, then setup our keepCRV
        if (keepCRV > 0) {
            IStrategy(curveStrategy).setLocalKeepCrv(keepCRV);
        }

        uint256 curveDebtRatio = 10_000;
        if (_hasFraxPool) {
            curveDebtRatio = 2_000;
        }

        Vault(_vault).addStrategy(
            curveStrategy,
            curveDebtRatio,
            0,
            type(uint256).max,
            0
        );

        // approve our new voter strategy on the proxy
        proxy.approveStrategy(_gauge, curveStrategy);
    }

    // deploy and attach a new convex frax strategy using our factory's existing implementation
    function _addConvexFraxStrategy(
        address _vault,
        uint256 _fraxPid,
        address _stakingAddress
    ) internal returns (address convexFraxStrategy) {
        convexFraxStrategy = IStrategy(convexFraxStratImplementation)
            .cloneStrategyConvexFrax(
                _vault,
                management,
                treasury,
                keeper,
                tradeFactory,
                _fraxPid,
                _stakingAddress,
                harvestProfitMinInUsdc,
                harvestProfitMaxInUsdc,
                address(fraxBooster)
            );

        // set up health check and the base fee oracle for our new strategy
        IStrategy(convexFraxStrategy).setHealthCheck(healthCheck);
        IStrategy(convexFraxStrategy).setBaseFeeOracle(baseFeeOracle);

        // if we're keeping any tokens, then setup our voters
        if (keepCRV > 0 || keepCVX > 0 || keepFXS > 0) {
            IStrategy(convexFraxStrategy).setVoters(
                curveVoter,
                convexVoter,
                fraxVoter
            );
            IStrategy(convexFraxStrategy).setLocalKeepCrvs(
                keepCRV,
                keepCVX,
                keepFXS
            );
        }

        // for frax pools, Convex-Frax is the most profitable strategy, but it can be illiquid. default 80%.
        Vault(_vault).addStrategy(
            convexFraxStrategy,
            8_000,
            0,
            type(uint256).max,
            0
        );
    }
}