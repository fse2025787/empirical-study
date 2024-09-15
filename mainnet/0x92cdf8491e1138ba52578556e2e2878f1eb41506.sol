// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;


// 

pragma solidity >=0.4.24 <0.7.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}
// 
pragma solidity ^0.6.0;




contract APContract is Initializable {
    address public yieldsterDAO;

    address public yieldsterTreasury;

    address public yieldsterGOD;

    address public emergencyVault;

    address public yieldsterExchange;

    address public stringUtils;

    address public whitelistModule;

    address public whitelistManager;

    address public proxyFactory;

    address public priceModule;

    address public platFormManagementFee;

    address public profitManagementFee;

    address public stockDeposit;

    address public stockWithdraw;

    address public safeMinter;

    address public safeUtils;

    address public exchangeRegistry;

    struct Vault {
        mapping(address => bool) vaultAssets;
        mapping(address => bool) vaultDepositAssets;
        mapping(address => bool) vaultWithdrawalAssets;
        mapping(address => bool) vaultEnabledStrategy;
        address depositStrategy;
        address withdrawStrategy;
        address vaultAPSManager;
        address vaultStrategyManager;
        uint256[] whitelistGroup;
        bool created;
        uint256 slippage;
    }

    struct VaultActiveStrategy {
        mapping(address => bool) isActiveStrategy;
        mapping(address => uint256) activeStrategyIndex;
        address[] activeStrategyList;
    }

    struct Strategy {
        mapping(address => bool) strategyProtocols;
        bool created;
        address minter;
        address executor;
        address benefeciary;
        uint256 managementFeePercentage;
    }

    struct SmartStrategy {
        address minter;
        address executor;
        bool created;
    }

    struct vaultActiveManagemetFee {
        mapping(address => bool) isActiveManagementFee;
        mapping(address => uint256) activeManagementFeeIndex;
        address[] activeManagementFeeList;
    }

    event VaultCreation(address vaultAddress);

    mapping(address => vaultActiveManagemetFee) managementFeeStrategies;

    mapping(address => mapping(address => mapping(address => bool))) vaultStrategyEnabledProtocols;

    mapping(address => VaultActiveStrategy) vaultActiveStrategies;

    mapping(address => bool) assets;

    mapping(address => bool) protocols;

    mapping(address => Vault) vaults;

    mapping(address => Strategy) strategies;

    mapping(address => SmartStrategy) smartStrategies;

    mapping(address => bool) vaultCreated;

    mapping(address => bool) APSManagers;

    mapping(address => address) minterStrategyMap;

    function initialize(
        address _yieldsterDAO,
        address _yieldsterTreasury,
        address _yieldsterGOD,
        address _emergencyVault,
        address _apsManager
    ) external initializer {
        yieldsterDAO = _yieldsterDAO;
        yieldsterTreasury = _yieldsterTreasury;
        yieldsterGOD = _yieldsterGOD;
        emergencyVault = _emergencyVault;
        APSManagers[_apsManager] = true;
    }

    function configureAPS(
        address _whitelistModule,
        address _platformManagementFee,
        address _profitManagementFee,
        address _stringUtils,
        address _yieldsterExchange,
        address _exchangeRegistry,
        address _priceModule,
        address _safeUtils
    ) external onlyYieldsterDAO {
        whitelistModule = _whitelistModule;
        platFormManagementFee = _platformManagementFee;
        stringUtils = _stringUtils;
        yieldsterExchange = _yieldsterExchange;
        exchangeRegistry = _exchangeRegistry;
        priceModule = _priceModule;
        safeUtils = _safeUtils;
        profitManagementFee = _profitManagementFee;
    }

    
    
    function addProxyFactory(address _proxyFactory) external onlyManager {
        proxyFactory = _proxyFactory;
    }

    function setProfitAndPlatformManagementFeeStrategies(
        address _platformManagement,
        address _profitManagement
    ) external onlyYieldsterDAO {
        if (_profitManagement != address(0))
            profitManagementFee = _profitManagement;
        if (_platformManagement != address(0))
            platFormManagementFee = _platformManagement;
    }

    //Modifiers
    modifier onlyYieldsterDAO {
        require(
            yieldsterDAO == msg.sender,
            "Only Yieldster DAO is allowed to perform this operation"
        );
        _;
    }

    modifier onlyManager {
        require(
            APSManagers[msg.sender],
            "Only APS managers allowed to perform this operation!"
        );
        _;
    }

    function isVault(address _address) external view returns (bool) {
        return vaults[_address].created;
    }

    
    
    function addManager(address _manager) external onlyYieldsterDAO {
        APSManagers[_manager] = true;
    }

    
    
    function removeManager(address _manager) external onlyYieldsterDAO {
        APSManagers[_manager] = false;
    }

    
    
    function changeWhitelistManager(address _whitelistManager)
        external
        onlyYieldsterDAO
    {
        whitelistManager = _whitelistManager;
    }

    
    
    function setYieldsterGOD(address _yieldsterGOD) external {
        require(
            msg.sender == yieldsterGOD,
            "Only Yieldster GOD can perform this operation"
        );
        yieldsterGOD = _yieldsterGOD;
    }

    
    
    function setYieldsterDAO(address _yieldsterDAO) external {
        require(
            msg.sender == yieldsterDAO,
            "Only Yieldster DAO can perform this operation"
        );
        yieldsterDAO = _yieldsterDAO;
    }

    
    
    function setYieldsterTreasury(address _yieldsterTreasury) external {
        require(
            msg.sender == yieldsterDAO,
            "Only Yieldster DAO can perform this operation"
        );
        yieldsterTreasury = _yieldsterTreasury;
    }

    
    function disableYieldsterGOD() external {
        require(
            msg.sender == yieldsterGOD,
            "Only Yieldster GOD can perform this operation"
        );
        yieldsterGOD = address(0);
    }

    
    
    function setEmergencyVault(address _emergencyVault)
        external
        onlyYieldsterDAO
    {
        emergencyVault = _emergencyVault;
    }

    
    
    function setSafeMinter(address _safeMinter) external onlyYieldsterDAO {
        safeMinter = _safeMinter;
    }

    
    
    function setSafeUtils(address _safeUtils) external onlyYieldsterDAO {
        safeUtils = _safeUtils;
    }

    
    
    function setStringUtils(address _stringUtils) external onlyYieldsterDAO {
        stringUtils = _stringUtils;
    }

    
    
    function setWhitelistModule(address _whitelistModule)
        external
        onlyYieldsterDAO
    {
        whitelistModule = _whitelistModule;
    }

    
    
    function setExchangeRegistry(address _exchangeRegistry)
        external
        onlyYieldsterDAO
    {
        exchangeRegistry = _exchangeRegistry;
    }

    
    
    function getStrategyFromMinter(address _minter)
        external
        view
        returns (address)
    {
        return minterStrategyMap[_minter];
    }

    
    
    function setYieldsterExchange(address _yieldsterExchange)
        external
        onlyYieldsterDAO
    {
        yieldsterExchange = _yieldsterExchange;
    }

    
    
    
    function setStockDepositWithdraw(
        address _stockDeposit,
        address _stockWithdraw
    ) external onlyYieldsterDAO {
        stockDeposit = _stockDeposit;
        stockWithdraw = _stockWithdraw;
    }

    
    
    function changeVaultAPSManager(address _vaultAPSManager) external {
        require(vaults[msg.sender].created, "Vault is not present");
        vaults[msg.sender].vaultAPSManager = _vaultAPSManager;
    }

    
    
    function changeVaultStrategyManager(address _vaultStrategyManager)
        external
    {
        require(vaults[msg.sender].created, "Vault is not present");
        vaults[msg.sender].vaultStrategyManager = _vaultStrategyManager;
    }

    
    
    function setVaultSlippage(uint256 _slippage) external {
        require(vaults[msg.sender].created, "Vault is not present");
        vaults[msg.sender].slippage = _slippage;
    }

    
    function getVaultSlippage() external view returns (uint256) {
        require(vaults[msg.sender].created, "Vault is not present");
        return vaults[msg.sender].slippage;
    }

    //Price Module
    
    
    function setPriceModule(address _priceModule) external onlyManager {
        priceModule = _priceModule;
    }

    
    
    function getUSDPrice(address _tokenAddress)
        external
        view
        returns (uint256)
    {
        return IPriceModule(priceModule).getUSDPrice(_tokenAddress);
    }

    //Vaults
    
    
    function createVault(address _vaultAddress) external {
        require(
            msg.sender == proxyFactory,
            "Only Proxy Factory can perform this operation"
        );
        vaultCreated[_vaultAddress] = true;
    }

    
    
    
    
    function addVault(
        address _vaultAPSManager,
        address _vaultStrategyManager,
        uint256[] calldata _whitelistGroup
    ) external {
        require(vaultCreated[msg.sender], "Vault not created");
        Vault memory newVault = Vault({
            vaultAPSManager: _vaultAPSManager,
            vaultStrategyManager: _vaultStrategyManager,
            whitelistGroup: _whitelistGroup,
            depositStrategy: stockDeposit,
            withdrawStrategy: stockWithdraw,
            created: true,
            slippage: 50
        });
        vaults[msg.sender] = newVault;

        //applying Platform management fee
        managementFeeStrategies[msg.sender].isActiveManagementFee[
            platFormManagementFee
        ] = true;
        managementFeeStrategies[msg.sender].activeManagementFeeIndex[
            platFormManagementFee
        ] = managementFeeStrategies[msg.sender].activeManagementFeeList.length;
        managementFeeStrategies[msg.sender].activeManagementFeeList.push(
            platFormManagementFee
        );

        //applying Profit management fee
        managementFeeStrategies[msg.sender].isActiveManagementFee[
            profitManagementFee
        ] = true;
        managementFeeStrategies[msg.sender].activeManagementFeeIndex[
            profitManagementFee
        ] = managementFeeStrategies[msg.sender].activeManagementFeeList.length;
        managementFeeStrategies[msg.sender].activeManagementFeeList.push(
            profitManagementFee
        );
    }

    
    
    
    
    
    function setVaultAssets(
        address[] calldata _enabledDepositAsset,
        address[] calldata _enabledWithdrawalAsset,
        address[] calldata _disabledDepositAsset,
        address[] calldata _disabledWithdrawalAsset
    ) external {
        require(vaults[msg.sender].created, "Vault not present");

        for (uint256 i = 0; i < _enabledDepositAsset.length; i++) {
            address asset = _enabledDepositAsset[i];
            require(_isAssetPresent(asset), "Asset not supported by Yieldster");
            vaults[msg.sender].vaultAssets[asset] = true;
            vaults[msg.sender].vaultDepositAssets[asset] = true;
        }

        for (uint256 i = 0; i < _enabledWithdrawalAsset.length; i++) {
            address asset = _enabledWithdrawalAsset[i];
            require(_isAssetPresent(asset), "Asset not supported by Yieldster");
            vaults[msg.sender].vaultAssets[asset] = true;
            vaults[msg.sender].vaultWithdrawalAssets[asset] = true;
        }

        for (uint256 i = 0; i < _disabledDepositAsset.length; i++) {
            address asset = _disabledDepositAsset[i];
            require(_isAssetPresent(asset), "Asset not supported by Yieldster");
            vaults[msg.sender].vaultAssets[asset] = false;
            vaults[msg.sender].vaultDepositAssets[asset] = false;
        }

        for (uint256 i = 0; i < _disabledWithdrawalAsset.length; i++) {
            address asset = _disabledWithdrawalAsset[i];
            require(_isAssetPresent(asset), "Asset not supported by Yieldster");
            vaults[msg.sender].vaultAssets[asset] = false;
            vaults[msg.sender].vaultWithdrawalAssets[asset] = false;
        }
    }

    
    function getVaultManagementFee() external view returns (address[] memory) {
        require(vaults[msg.sender].created, "Vault not present");
        return managementFeeStrategies[msg.sender].activeManagementFeeList;
    }

    
    function getDepositStrategy() external view returns (address) {
        require(vaults[msg.sender].created, "Vault not present");
        return vaults[msg.sender].depositStrategy;
    }

    
    function getWithdrawStrategy() external view returns (address) {
        require(vaults[msg.sender].created, "Vault not present");
        return vaults[msg.sender].withdrawStrategy;
    }

    
    
    
    function setManagementFeeStrategies(
        address _vaultAddress,
        address _managementFeeAddress
    ) external {
        require(vaults[_vaultAddress].created, "Vault not present");
        require(
            vaults[_vaultAddress].vaultStrategyManager == msg.sender,
            "Sender not Authorized"
        );
        managementFeeStrategies[_vaultAddress].isActiveManagementFee[
            _managementFeeAddress
        ] = true;
        managementFeeStrategies[_vaultAddress].activeManagementFeeIndex[
            _managementFeeAddress
        ] = managementFeeStrategies[_vaultAddress]
        .activeManagementFeeList
        .length;
        managementFeeStrategies[_vaultAddress].activeManagementFeeList.push(
            _managementFeeAddress
        );
    }

    
    
    function removeManagementFeeStrategies(
        address _vaultAddress,
        address _managementFeeAddress
    ) external {
        require(vaults[_vaultAddress].created, "Vault not present");
        require(
            managementFeeStrategies[_vaultAddress].isActiveManagementFee[
                _managementFeeAddress
            ],
            "Provided ManagementFee is not active"
        );
        require(
            vaults[_vaultAddress].vaultStrategyManager == msg.sender ||
                yieldsterDAO == msg.sender,
            "Sender not Authorized"
        );
        require(
            platFormManagementFee != _managementFeeAddress ||
                yieldsterDAO == msg.sender,
            "Platfrom Management only changable by dao!"
        );
        managementFeeStrategies[_vaultAddress].isActiveManagementFee[
            _managementFeeAddress
        ] = false;

        if (
            managementFeeStrategies[_vaultAddress]
            .activeManagementFeeList
            .length == 1
        ) {
            managementFeeStrategies[_vaultAddress]
                .activeManagementFeeList
                .pop();
        } else {
            uint256 index = managementFeeStrategies[_vaultAddress]
            .activeManagementFeeIndex[_managementFeeAddress];
            uint256 lastIndex = managementFeeStrategies[_vaultAddress]
            .activeManagementFeeList
            .length - 1;
            delete managementFeeStrategies[_vaultAddress]
                .activeManagementFeeList[index];
            managementFeeStrategies[_vaultAddress].activeManagementFeeIndex[
                managementFeeStrategies[_vaultAddress].activeManagementFeeList[
                    lastIndex
                ]
            ] = index;
            managementFeeStrategies[_vaultAddress].activeManagementFeeList[
                index
            ] = managementFeeStrategies[_vaultAddress].activeManagementFeeList[
                lastIndex
            ];
            managementFeeStrategies[_vaultAddress]
                .activeManagementFeeList
                .pop();
        }
    }

    
    
    function setVaultActiveStrategy(address _strategyAddress) external {
        require(vaults[msg.sender].created, "Vault not present");
        require(
            _isStrategyEnabled(msg.sender, _strategyAddress),
            "This strategy is not enabled"
        );
        require(strategies[_strategyAddress].created, "Strategy not present");
        vaultActiveStrategies[msg.sender].isActiveStrategy[
            _strategyAddress
        ] = true;
        vaultActiveStrategies[msg.sender].activeStrategyIndex[
            _strategyAddress
        ] = vaultActiveStrategies[msg.sender].activeStrategyList.length;
        vaultActiveStrategies[msg.sender].activeStrategyList.push(
            _strategyAddress
        );
    }

    
    
    function deactivateVaultStrategy(address _strategyAddress) external {
        require(vaults[msg.sender].created, "Vault not present");
        require(
            vaultActiveStrategies[msg.sender].isActiveStrategy[
                _strategyAddress
            ],
            "Provided strategy is not active"
        );
        vaultActiveStrategies[msg.sender].isActiveStrategy[
            _strategyAddress
        ] = false;

        if (vaultActiveStrategies[msg.sender].activeStrategyList.length == 1) {
            vaultActiveStrategies[msg.sender].activeStrategyList.pop();
        } else {
            uint256 index = vaultActiveStrategies[msg.sender]
            .activeStrategyIndex[_strategyAddress];
            uint256 lastIndex = vaultActiveStrategies[msg.sender]
            .activeStrategyList
            .length - 1;
            delete vaultActiveStrategies[msg.sender].activeStrategyList[index];
            vaultActiveStrategies[msg.sender].activeStrategyIndex[
                vaultActiveStrategies[msg.sender].activeStrategyList[lastIndex]
            ] = index;
            vaultActiveStrategies[msg.sender].activeStrategyList[
                index
            ] = vaultActiveStrategies[msg.sender].activeStrategyList[lastIndex];
            vaultActiveStrategies[msg.sender].activeStrategyList.pop();
        }
    }

    
    function getVaultActiveStrategy(address _vaultAddress)
        external
        view
        returns (address[] memory)
    {
        require(vaults[_vaultAddress].created, "Vault not present");
        return vaultActiveStrategies[_vaultAddress].activeStrategyList;
    }

    function isStrategyActive(address _vaultAddress, address _strategyAddress)
        external
        view
        returns (bool)
    {
        return
            vaultActiveStrategies[_vaultAddress].isActiveStrategy[
                _strategyAddress
            ];
    }

    function getStrategyManagementDetails(
        address _vaultAddress,
        address _strategyAddress
    ) external view returns (address, uint256) {
        require(vaults[_vaultAddress].created, "Vault not present");
        require(strategies[_strategyAddress].created, "Strategy not present");
        require(
            vaultActiveStrategies[_vaultAddress].isActiveStrategy[
                _strategyAddress
            ],
            "Strategy not Active"
        );
        return (
            strategies[_strategyAddress].benefeciary,
            strategies[_strategyAddress].managementFeePercentage
        );
    }

    
    
    
    
    
    function setVaultStrategyAndProtocol(
        address _vaultStrategy,
        address[] calldata _enabledStrategyProtocols,
        address[] calldata _disabledStrategyProtocols,
        address[] calldata _assetsToBeEnabled
    ) external {
        require(vaults[msg.sender].created, "Vault not present");
        require(strategies[_vaultStrategy].created, "Strategy not present");
        vaults[msg.sender].vaultEnabledStrategy[_vaultStrategy] = true;

        for (uint256 i = 0; i < _enabledStrategyProtocols.length; i++) {
            address protocol = _enabledStrategyProtocols[i];
            require(
                _isProtocolPresent(protocol),
                "Protocol not supported by Yieldster"
            );
            vaultStrategyEnabledProtocols[msg.sender][_vaultStrategy][
                protocol
            ] = true;
        }

        for (uint256 i = 0; i < _disabledStrategyProtocols.length; i++) {
            address protocol = _disabledStrategyProtocols[i];
            require(
                _isProtocolPresent(protocol),
                "Protocol not supported by Yieldster"
            );
            vaultStrategyEnabledProtocols[msg.sender][_vaultStrategy][
                protocol
            ] = false;
        }

        for (uint256 i = 0; i < _assetsToBeEnabled.length; i++) {
            address asset = _assetsToBeEnabled[i];
            require(_isAssetPresent(asset), "Asset not supported by Yieldster");
            vaults[msg.sender].vaultAssets[asset] = true;
            vaults[msg.sender].vaultDepositAssets[asset] = true;
            vaults[msg.sender].vaultWithdrawalAssets[asset] = true;
        }
    }

    
    
    
    function disableVaultStrategy(
        address _strategyAddress,
        address[] calldata _assetsToBeDisabled
    ) external {
        require(vaults[msg.sender].created, "Vault not present");
        require(strategies[_strategyAddress].created, "Strategy not present");
        require(
            vaults[msg.sender].vaultEnabledStrategy[_strategyAddress],
            "Strategy was not enabled"
        );
        vaults[msg.sender].vaultEnabledStrategy[_strategyAddress] = false;

        for (uint256 i = 0; i < _assetsToBeDisabled.length; i++) {
            address asset = _assetsToBeDisabled[i];
            require(_isAssetPresent(asset), "Asset not supported by Yieldster");
            vaults[msg.sender].vaultAssets[asset] = false;
            vaults[msg.sender].vaultDepositAssets[asset] = false;
            vaults[msg.sender].vaultWithdrawalAssets[asset] = false;
        }
    }

    
    
    
    function setVaultSmartStrategy(address _smartStrategyAddress, uint256 _type)
        external
    {
        require(vaults[msg.sender].created, "Vault not present");
        require(
            _isSmartStrategyPresent(_smartStrategyAddress),
            "Smart Strategy not Supported by Yieldster"
        );
        if (_type == 1) {
            vaults[msg.sender].depositStrategy = _smartStrategyAddress;
        } else if (_type == 2) {
            vaults[msg.sender].withdrawStrategy = _smartStrategyAddress;
        } else {
            revert("Invalid type provided");
        }
    }

    
    
    
    
    function _isStrategyProtocolEnabled(
        address _vaultAddress,
        address _strategyAddress,
        address _protocolAddress
    ) external view returns (bool) {
        if (
            vaults[_vaultAddress].created &&
            strategies[_strategyAddress].created &&
            protocols[_protocolAddress] &&
            vaults[_vaultAddress].vaultEnabledStrategy[_strategyAddress] &&
            vaultStrategyEnabledProtocols[_vaultAddress][_strategyAddress][
                _protocolAddress
            ]
        ) {
            return true;
        } else {
            return false;
        }
    }

    
    
    
    function _isStrategyEnabled(address _vaultAddress, address _strategyAddress)
        public
        view
        returns (bool)
    {
        if (
            vaults[_vaultAddress].created &&
            strategies[_strategyAddress].created &&
            vaults[_vaultAddress].vaultEnabledStrategy[_strategyAddress]
        ) {
            return true;
        } else {
            return false;
        }
    }

    
    
    function _isVaultAsset(address cleanUpAsset) external view returns (bool) {
        require(vaults[msg.sender].created, "Vault is not present");
        return vaults[msg.sender].vaultAssets[cleanUpAsset];
    }

    // Assets
    
    
    function _isAssetPresent(address _address) private view returns (bool) {
        return assets[_address];
    }

    
    
    function addAsset(address _tokenAddress) external onlyManager {
        require(!_isAssetPresent(_tokenAddress), "Asset already present!");
        assets[_tokenAddress] = true;
    }

    
    
    function removeAsset(address _tokenAddress) external onlyManager {
        require(_isAssetPresent(_tokenAddress), "Asset not present!");
        delete assets[_tokenAddress];
    }

    
    
    function isDepositAsset(address _assetAddress)
        external
        view
        returns (bool)
    {
        require(vaults[msg.sender].created, "Vault not present");
        return vaults[msg.sender].vaultDepositAssets[_assetAddress];
    }

    
    
    function isWithdrawalAsset(address _assetAddress)
        external
        view
        returns (bool)
    {
        require(vaults[msg.sender].created, "Vault not present");
        return vaults[msg.sender].vaultWithdrawalAssets[_assetAddress];
    }

    //Strategies
    
    
    function _isStrategyPresent(address _address) private view returns (bool) {
        return strategies[_address].created;
    }

    
    
    
    
    
    function addStrategy(
        address _strategyAddress,
        address[] calldata _strategyProtocols,
        address _minter,
        address _executor,
        address _benefeciary,
        uint256 _managementFeePercentage
    ) external onlyManager {
        require(
            !_isStrategyPresent(_strategyAddress),
            "Strategy already present!"
        );
        Strategy memory newStrategy = Strategy({
            created: true,
            minter: _minter,
            executor: _executor,
            benefeciary: _benefeciary,
            managementFeePercentage: _managementFeePercentage
        });
        strategies[_strategyAddress] = newStrategy;
        minterStrategyMap[_minter] = _strategyAddress;

        for (uint256 i = 0; i < _strategyProtocols.length; i++) {
            address protocol = _strategyProtocols[i];
            require(
                _isProtocolPresent(protocol),
                "Protocol not supported by Yieldster"
            );
            strategies[_strategyAddress].strategyProtocols[protocol] = true;
        }
    }

    
    
    function removeStrategy(address _strategyAddress) external onlyManager {
        require(_isStrategyPresent(_strategyAddress), "Strategy not present!");
        delete strategies[_strategyAddress];
    }

    
    
    function strategyExecutor(address _strategy)
        external
        view
        returns (address)
    {
        return strategies[_strategy].executor;
    }

    
    
    
    function changeStrategyExecutor(address _strategyAddress, address _executor)
        external
        onlyManager
    {
        require(_isStrategyPresent(_strategyAddress), "Strategy not present!");
        strategies[_strategyAddress].executor = _executor;
    }

    //Smart Strategy
    
    
    function _isSmartStrategyPresent(address _address)
        private
        view
        returns (bool)
    {
        return smartStrategies[_address].created;
    }

    
    
    function addSmartStrategy(
        address _smartStrategyAddress,
        address _minter,
        address _executor
    ) external onlyManager {
        require(
            !_isSmartStrategyPresent(_smartStrategyAddress),
            "Smart Strategy already present!"
        );
        SmartStrategy memory newSmartStrategy = SmartStrategy({
            minter: _minter,
            executor: _executor,
            created: true
        });
        smartStrategies[_smartStrategyAddress] = newSmartStrategy;
        minterStrategyMap[_minter] = _smartStrategyAddress;
    }

    
    
    function removeSmartStrategy(address _smartStrategyAddress)
        external
        onlyManager
    {
        require(
            !_isSmartStrategyPresent(_smartStrategyAddress),
            "Smart Strategy not present"
        );
        delete smartStrategies[_smartStrategyAddress];
    }

    
    
    function smartStrategyExecutor(address _smartStrategy)
        external
        view
        returns (address)
    {
        return smartStrategies[_smartStrategy].executor;
    }

    
    
    
    function changeSmartStrategyExecutor(
        address _smartStrategy,
        address _executor
    ) external onlyManager {
        require(
            _isSmartStrategyPresent(_smartStrategy),
            "Smart Strategy not present!"
        );
        smartStrategies[_smartStrategy].executor = _executor;
    }

    // Protocols
    
    
    function _isProtocolPresent(address _address) private view returns (bool) {
        return protocols[_address];
    }

    
    
    function addProtocol(address _protocolAddress) external onlyManager {
        require(
            !_isProtocolPresent(_protocolAddress),
            "Protocol already present!"
        );
        protocols[_protocolAddress] = true;
    }

    
    
    function removeProtocol(address _protocolAddress) external onlyManager {
        require(_isProtocolPresent(_protocolAddress), "Protocol not present!");
        delete protocols[_protocolAddress];
    }
}

// 
pragma solidity >=0.5.0 <0.7.0;


interface IPriceModule
{
    function getUSDPrice(address ) external view returns(uint256);
}
