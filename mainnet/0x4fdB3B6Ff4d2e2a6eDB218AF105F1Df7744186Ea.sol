// SPDX-License-Identifier: GPL-3.0-or-later"


pragma solidity ^0.7.0;

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
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

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
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

pragma solidity ^0.7.0;


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

pragma solidity ^0.7.0;




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
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}
// "

pragma solidity 0.7.6;










contract VaultFactory is OwnableUpgradeSafe {
    address[] internal _vaults;

    IAddressRegistry public derivativeSpecificationRegistry;
    IAddressRegistry public oracleRegistry;
    IAddressRegistry public collateralTokenRegistry;
    IAddressRegistry public collateralSplitRegistry;
    address public tokenBuilder;
    address public feeLogger;

    
    uint256 public protocolFee;
    
    address public feeWallet;
    
    uint256 public authorFeeLimit;

    IVaultBuilder public vaultBuilder;
    IAddressRegistry public oracleIteratorRegistry;

    
    uint256 public settlementDelay;

    event VaultCreated(
        bytes32 indexed derivativeSymbol,
        address vault,
        address specification
    );

    
    
    function initialize(
        address _derivativeSpecificationRegistry,
        address _oracleRegistry,
        address _oracleIteratorRegistry,
        address _collateralTokenRegistry,
        address _collateralSplitRegistry,
        address _tokenBuilder,
        address _feeLogger,
        uint256 _protocolFee,
        address _feeWallet,
        uint256 _authorFeeLimit,
        address _vaultBuilder,
        uint256 _settlementDelay
    ) external initializer {
        __Ownable_init();

        setDerivativeSpecificationRegistry(_derivativeSpecificationRegistry);
        setOracleRegistry(_oracleRegistry);
        setOracleIteratorRegistry(_oracleIteratorRegistry);
        setCollateralTokenRegistry(_collateralTokenRegistry);
        setCollateralSplitRegistry(_collateralSplitRegistry);

        setTokenBuilder(_tokenBuilder);
        setFeeLogger(_feeLogger);
        setVaultBuilder(_vaultBuilder);

        setSettlementDelay(_settlementDelay);

        protocolFee = _protocolFee;
        authorFeeLimit = _authorFeeLimit;

        require(_feeWallet != address(0), "Fee wallet");
        feeWallet = _feeWallet;
    }

    
    
    
    
    function createVault(bytes32 _derivativeSymbolHash, uint256 _liveTime)
        external
    {
        IDerivativeSpecification derivativeSpecification =
            IDerivativeSpecification(
                derivativeSpecificationRegistry.get(_derivativeSymbolHash)
            );
        require(
            address(derivativeSpecification) != address(0),
            "Specification is absent"
        );

        address collateralToken =
            collateralTokenRegistry.get(
                derivativeSpecification.collateralTokenSymbol()
            );
        address collateralSplit =
            collateralSplitRegistry.get(
                derivativeSpecification.collateralSplitSymbol()
            );

        address[] memory oracles;
        address[] memory oracleIterators;
        (oracles, oracleIterators) = getOraclesAndIterators(
            derivativeSpecification
        );

        require(_liveTime > 0, "Zero live time");

        address vault =
            vaultBuilder.buildVault(
                _liveTime,
                protocolFee,
                feeWallet,
                address(derivativeSpecification),
                collateralToken,
                oracles,
                oracleIterators,
                collateralSplit,
                tokenBuilder,
                feeLogger,
                authorFeeLimit,
                settlementDelay
            );
        emit VaultCreated(
            _derivativeSymbolHash,
            vault,
            address(derivativeSpecification)
        );
        _vaults.push(vault);
    }

    function getOraclesAndIterators(
        IDerivativeSpecification _derivativeSpecification
    )
        internal
        returns (address[] memory _oracles, address[] memory _oracleIterators)
    {
        bytes32[] memory oracleSymbols =
            _derivativeSpecification.oracleSymbols();
        bytes32[] memory oracleIteratorSymbols =
            _derivativeSpecification.oracleIteratorSymbols();
        require(
            oracleSymbols.length == oracleIteratorSymbols.length,
            "Oracles and iterators length"
        );

        _oracles = new address[](oracleSymbols.length);
        _oracleIterators = new address[](oracleIteratorSymbols.length);
        for (uint256 i = 0; i < oracleSymbols.length; i++) {
            address oracle = oracleRegistry.get(oracleSymbols[i]);
            require(address(oracle) != address(0), "Oracle is absent");
            _oracles[i] = oracle;

            address oracleIterator =
                oracleIteratorRegistry.get(oracleIteratorSymbols[i]);
            require(
                address(oracleIterator) != address(0),
                "OracleIterator is absent"
            );
            _oracleIterators[i] = oracleIterator;
        }
    }

    function setProtocolFee(uint256 _protocolFee) external onlyOwner {
        protocolFee = _protocolFee;
    }

    function setAuthorFeeLimit(uint256 _authorFeeLimit) external onlyOwner {
        authorFeeLimit = _authorFeeLimit;
    }

    function setTokenBuilder(address _tokenBuilder) public onlyOwner {
        require(_tokenBuilder != address(0), "Token builder");
        tokenBuilder = _tokenBuilder;
    }

    function setFeeLogger(address _feeLogger) public onlyOwner {
        require(_feeLogger != address(0), "Fee logger");
        feeLogger = _feeLogger;
    }

    function setVaultBuilder(address _vaultBuilder) public onlyOwner {
        require(_vaultBuilder != address(0), "Vault builder");
        vaultBuilder = IVaultBuilder(_vaultBuilder);
    }

    function setSettlementDelay(uint256 _settlementDelay) public onlyOwner {
        settlementDelay = _settlementDelay;
    }

    function setDerivativeSpecificationRegistry(
        address _derivativeSpecificationRegistry
    ) public onlyOwner {
        require(
            _derivativeSpecificationRegistry != address(0),
            "Derivative specification registry"
        );
        derivativeSpecificationRegistry = IAddressRegistry(
            _derivativeSpecificationRegistry
        );
    }

    function setOracleRegistry(address _oracleRegistry) public onlyOwner {
        require(_oracleRegistry != address(0), "Oracle registry");
        oracleRegistry = IAddressRegistry(_oracleRegistry);
    }

    function setOracleIteratorRegistry(address _oracleIteratorRegistry)
        public
        onlyOwner
    {
        require(
            _oracleIteratorRegistry != address(0),
            "Oracle iterator registry"
        );
        oracleIteratorRegistry = IAddressRegistry(_oracleIteratorRegistry);
    }

    function setCollateralTokenRegistry(address _collateralTokenRegistry)
        public
        onlyOwner
    {
        require(
            _collateralTokenRegistry != address(0),
            "Collateral token registry"
        );
        collateralTokenRegistry = IAddressRegistry(_collateralTokenRegistry);
    }

    function setCollateralSplitRegistry(address _collateralSplitRegistry)
        public
        onlyOwner
    {
        require(
            _collateralSplitRegistry != address(0),
            "Collateral split registry"
        );
        collateralSplitRegistry = IAddressRegistry(_collateralSplitRegistry);
    }

    function pauseVault(address _vault) public onlyOwner {
        IPausableVault(_vault).pause();
    }

    function unpauseVault(address _vault) public onlyOwner {
        IPausableVault(_vault).unpause();
    }

    function setDerivativeSpecification(address _value) external {
        derivativeSpecificationRegistry.set(_value);
    }

    function setOracle(address _value) external {
        oracleRegistry.set(_value);
    }

    function setOracleIterator(address _value) external {
        oracleIteratorRegistry.set(_value);
    }

    function setCollateralToken(address _value) external {
        collateralTokenRegistry.set(_value);
    }

    function setCollateralSplit(address _value) external {
        collateralSplitRegistry.set(_value);
    }

    
    
    
    function getVault(uint256 _index) external view returns (address) {
        return _vaults[_index];
    }

    
    
    function getLastVaultIndex() external view returns (uint256) {
        return _vaults.length - 1;
    }

    
    
    function getAllVaults() external view returns (address[] memory) {
        return _vaults;
    }

    uint256[50] private __gap;
}

// "

pragma solidity 0.7.6;




interface IDerivativeSpecification {
    
    
    
    function isDerivativeSpecification() external pure returns (bool);

    
    /// between the start and the end of the Live period
    
    
    function oracleSymbols() external view returns (bytes32[] memory);

    
    /// finds the value closest to a given timestamp
    
    
    function oracleIteratorSymbols() external view returns (bytes32[] memory);

    
    
    
    function collateralTokenSymbol() external view returns (bytes32);

    
    /// and the initial collateral split to the final collateral split
    
    
    function collateralSplitSymbol() external view returns (bytes32);

    
    
    
    function livePeriod() external view returns (uint256);

    
    
    
    function primaryNominalValue() external view returns (uint256);

    
    
    
    function complementNominalValue() external view returns (uint256);

    
    
    
    function authorFee() external view returns (uint256);

    
    
    
    function symbol() external view returns (string memory);

    
    
    
    function name() external view returns (string memory);

    
    
    
    function baseURI() external view returns (string memory);

    
    
    
    function author() external view returns (address);
}

// "

pragma solidity 0.7.6;

interface IAddressRegistry {
    function get(bytes32 _key) external view returns (address);

    function set(address _value) external;
}

// "

pragma solidity 0.7.6;

interface IVaultBuilder {
    function buildVault(
        uint256 _liveTime,
        uint256 _protocolFee,
        address _feeWallet,
        address _derivativeSpecification,
        address _collateralToken,
        address[] calldata _oracles,
        address[] calldata _oracleIterators,
        address _collateralSplit,
        address _tokenBuilder,
        address _feeLogger,
        uint256 _authorFeeLimit,
        uint256 _settlementDelay
    ) external returns (address);
}

// "

pragma solidity 0.7.6;

interface IPausableVault {
    function pause() external;

    function unpause() external;
}
