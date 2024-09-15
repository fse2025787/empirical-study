// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Metadata.sol)

pragma solidity ^0.8.0;



// 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// 
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}





/// of this module
interface IVaultManagerStorage {
    
    /// determines the minimum collateral ratio of a position
    function collateralFactor() external view returns (uint64);

    
    /// the same rights as this `VaultManager` on the stablecoin contract
    function stablecoin() external view returns (IAgToken);

    
    function treasury() external view returns (ITreasury);

    
    function oracle() external view returns (IOracle);

    
    /// The stored value is not necessarily the true value: this one is recomputed every time an action takes place
    /// within the protocol. It is in base `BASE_INTEREST`
    function interestAccumulator() external view returns (uint256);

    
    function collateral() external view returns (IERC20);

    
    /// This value is expressed in the base of Angle stablecoins (`BASE_TOKENS = 10**18`)
    function totalNormalizedDebt() external view returns (uint256);

    
    function debtCeiling() external view returns (uint256);

    
    function vaultData(uint256 vaultID) external view returns (uint256 collateralAmount, uint256 normalizedDebt);

    
    /// `vaultID` for each vault: it is like `tokenID` in basic ERC721 contracts
    function vaultIDCount() external view returns (uint256);
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// 

pragma solidity ^0.8.12;






















// solhint-disable-next-line max-states-count
contract VaultManagerStorage is IVaultManagerStorage, Initializable, ReentrancyGuardUpgradeable {
    
    uint256 public constant BASE_PARAMS = 10**9;
    
    uint256 public constant BASE_INTEREST = 10**27;
    
    uint256 public constant HALF_BASE_INTEREST = 10**27 / 2;

    // ================================= REFERENCES ================================

    
    ITreasury public treasury;
    
    IERC20 public collateral;
    
    IAgToken public stablecoin;
    
    IOracle public oracle;
    
    IVeBoostProxy public veBoostProxy;
    
    uint256 internal _collatBase;

    // ================================= PARAMETERS ================================
    // Unless specified otherwise, parameters of this contract are expressed in `BASE_PARAMS`

    
    /// not be bigger than `type(uint256).max / BASE_INTEREST` otherwise there may be some overflows in the `increaseDebt` function
    uint256 public debtCeiling;
    
    /// should normally be 2. The base of the x-values in this array should be `BASE_TOKENS`
    uint256[] public xLiquidationBoost;
    
    uint256[] public yLiquidationBoost;
    
    uint64 public collateralFactor;
    
    uint64 public targetHealthFactor;
    
    uint64 public borrowFee;
    
    /// than the liquidation surcharge (cf below) to avoid exploits where people voluntarily get liquidated at a 0
    /// discount to pay smaller repaying fees
    uint64 public repayFee;
    
    /// that is to say in base 10**27
    uint64 public interestRate;
    
    /// For instance for a 2% fee, `liquidationSurcharge` should be 98%
    uint64 public liquidationSurcharge;
    
    uint64 public maxLiquidationDiscount;
    
    bool public whitelistingActivated;
    
    bool public paused;

    // ================================= VARIABLES =================================

    
    uint256 public lastInterestAccumulatorUpdated;
    
    uint256 public interestAccumulator;
    
    uint256 public totalNormalizedDebt;
    
    /// when the value is communicated to the treasury contract
    uint256 public surplus;
    
    /// of stablecoins
    uint256 public badDebt;

    // ================================== MAPPINGS =================================

    
    mapping(uint256 => Vault) public vaultData;
    
    mapping(address => uint256) public isWhitelisted;

    // ================================ ERC721 DATA ================================

    
    uint256 public vaultIDCount;

    
    string internal _baseURI;

    // Mapping from `vaultID` to owner address
    mapping(uint256 => address) internal _owners;

    // Mapping from owner address to vault owned count
    mapping(address => uint256) internal _balances;

    // Mapping from `vaultID` to approved address
    mapping(uint256 => address) internal _vaultApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => uint256)) internal _operatorApprovals;

    uint256[50] private __gap;

    // =================================== EVENTS ==================================

    event AccruedToTreasury(uint256 surplusEndValue, uint256 badDebtEndValue);
    event CollateralAmountUpdated(uint256 vaultID, uint256 collateralAmount, uint8 isIncrease);
    event InterestAccumulatorUpdated(uint256 value, uint256 timestamp);
    event InternalDebtUpdated(uint256 vaultID, uint256 internalAmount, uint8 isIncrease);
    event FiledUint64(uint64 param, bytes32 what);
    event DebtCeilingUpdated(uint256 debtCeiling);
    event LiquidationBoostParametersUpdated(address indexed _veBoostProxy, uint256[] xBoost, uint256[] yBoost);
    event LiquidatedVaults(uint256[] vaultIDs);
    event DebtTransferred(uint256 srcVaultID, uint256 dstVaultID, address dstVaultManager, uint256 amount);

    // =================================== ERRORS ==================================

    error ApprovalToOwner();
    error ApprovalToCaller();
    error DustyLeftoverAmount();
    error DebtCeilingExceeded();
    error HealthyVault();
    error IncompatibleLengths();
    error InsolventVault();
    error InvalidParameterValue();
    error InvalidParameterType();
    error InvalidSetOfParameters();
    error InvalidTreasury();
    error NonERC721Receiver();
    error NonexistentVault();
    error NotApproved();
    error NotGovernor();
    error NotGovernorOrGuardian();
    error NotTreasury();
    error NotWhitelisted();
    error NotVaultManager();
    error Paused();
    error TooHighParameterValue();
    error TooSmallParameterValue();
    error ZeroAddress();

    
    constructor() initializer {}
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// 

pragma solidity ^0.8.12;






abstract contract VaultManagerERC721 is IERC721MetadataUpgradeable, VaultManagerStorage {
    using SafeERC20 for IERC20;
    using Address for address;

    
    string public name;
    
    string public symbol;

    // ================================= MODIFIERS =================================

    
    
    
    modifier onlyApprovedOrOwner(address caller, uint256 vaultID) {
        if (!_isApprovedOrOwner(caller, vaultID)) revert NotApproved();
        _;
    }

    // ================================ ERC721 LOGIC ===============================

    
    
    
    
    function isApprovedOrOwner(address spender, uint256 vaultID) external view returns (bool) {
        return _isApprovedOrOwner(spender, vaultID);
    }

    
    function tokenURI(uint256 vaultID) external view returns (string memory) {
        if (!_exists(vaultID)) revert NonexistentVault();
        // There is no vault with `vaultID` equal to 0, so the following variable is
        // always greater than zero
        uint256 temp = vaultID;
        uint256 digits;
        while (temp != 0) {
            ++digits;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (vaultID != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(vaultID % 10)));
            vaultID /= 10;
        }
        return bytes(_baseURI).length != 0 ? string(abi.encodePacked(_baseURI, string(buffer))) : "";
    }

    
    function balanceOf(address owner) external view returns (uint256) {
        if (owner == address(0)) revert ZeroAddress();
        return _balances[owner];
    }

    
    function ownerOf(uint256 vaultID) external view returns (address) {
        return _ownerOf(vaultID);
    }

    
    function approve(address to, uint256 vaultID) external {
        address owner = _ownerOf(vaultID);
        if (to == owner) revert ApprovalToOwner();
        if (msg.sender != owner && !isApprovedForAll(owner, msg.sender)) revert NotApproved();

        _approve(to, vaultID);
    }

    
    function getApproved(uint256 vaultID) external view returns (address) {
        if (!_exists(vaultID)) revert NonexistentVault();
        return _getApproved(vaultID);
    }

    
    function setApprovalForAll(address operator, bool approved) external {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator] == 1;
    }

    
    function transferFrom(
        address from,
        address to,
        uint256 vaultID
    ) external onlyApprovedOrOwner(msg.sender, vaultID) {
        _transfer(from, to, vaultID);
    }

    
    function safeTransferFrom(
        address from,
        address to,
        uint256 vaultID
    ) external {
        safeTransferFrom(from, to, vaultID, "");
    }

    
    function safeTransferFrom(
        address from,
        address to,
        uint256 vaultID,
        bytes memory _data
    ) public onlyApprovedOrOwner(msg.sender, vaultID) {
        _safeTransfer(from, to, vaultID, _data);
    }

    // ================================ ERC165 LOGIC ===============================

    
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IVaultManager).interfaceId ||
            interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    // ================== INTERNAL FUNCTIONS FOR THE ERC721 LOGIC ==================

    
    function _ownerOf(uint256 vaultID) internal view returns (address owner) {
        owner = _owners[vaultID];
        if (owner == address(0)) revert NonexistentVault();
    }

    
    function _getApproved(uint256 vaultID) internal view returns (address) {
        return _vaultApprovals[vaultID];
    }

    
    function _safeTransfer(
        address from,
        address to,
        uint256 vaultID,
        bytes memory _data
    ) internal {
        _transfer(from, to, vaultID);
        if (!_checkOnERC721Received(from, to, vaultID, _data)) revert NonERC721Receiver();
    }

    
    
    
    function _exists(uint256 vaultID) internal view returns (bool) {
        return _owners[vaultID] != address(0);
    }

    
    function _isApprovedOrOwner(address spender, uint256 vaultID) internal view returns (bool) {
        // The following checks if the vault exists
        address owner = _ownerOf(vaultID);
        return (spender == owner || _getApproved(vaultID) == spender || _operatorApprovals[owner][spender] == 1);
    }

    
    /// Mints `vaultID` and transfers it to `to`
    
    
    function _mint(address to) internal returns (uint256 vaultID) {
        if (whitelistingActivated && (isWhitelisted[to] != 1 || isWhitelisted[msg.sender] != 1))
            revert NotWhitelisted();
        if (to == address(0)) revert ZeroAddress();

        unchecked {
            vaultIDCount += 1;
        }

        vaultID = vaultIDCount;
        _beforeTokenTransfer(address(0), to, vaultID);

        unchecked {
            _balances[to] += 1;
        }

        _owners[vaultID] = to;
        emit Transfer(address(0), to, vaultID);
        if (!_checkOnERC721Received(address(0), to, vaultID, "")) revert NonERC721Receiver();
    }

    
    
    
    function _burn(uint256 vaultID) internal {
        address owner = _ownerOf(vaultID);

        _beforeTokenTransfer(owner, address(0), vaultID);
        // Clear approvals
        _approve(address(0), vaultID);
        // The following line cannot underflow as the owner's balance is necessarily
        // greater than 1
        unchecked {
            _balances[owner] -= 1;
        }
        delete _owners[vaultID];
        delete vaultData[vaultID];

        emit Transfer(owner, address(0), vaultID);
    }

    
    /// this imposes no restrictions on msg.sender
    
    
    
    function _transfer(
        address from,
        address to,
        uint256 vaultID
    ) internal {
        if (_ownerOf(vaultID) != from) revert NotApproved();
        if (to == address(0)) revert ZeroAddress();
        if (whitelistingActivated && isWhitelisted[to] != 1) revert NotWhitelisted();

        _beforeTokenTransfer(from, to, vaultID);

        // Clear approvals from the previous owner
        _approve(address(0), vaultID);
        unchecked {
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[vaultID] = to;

        emit Transfer(from, to, vaultID);
    }

    
    function _approve(address to, uint256 vaultID) internal {
        _vaultApprovals[vaultID] = to;
        emit Approval(_ownerOf(vaultID), to, vaultID);
    }

    
    
    /// address, and this signature is given to the contract by another address (like a router)
    function _setApprovalForAll(
        address approver,
        address operator,
        bool approved
    ) internal {
        if (operator == approver) revert ApprovalToCaller();
        uint256 approval = approved ? 1 : 0;
        _operatorApprovals[approver][operator] = approval;
        emit ApprovalForAll(approver, operator, approved);
    }

    
    /// The call is not executed if the target address is not a contract
    
    
    
    
    
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 vaultID,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(msg.sender, from, vaultID, _data) returns (
                bytes4 retval
            ) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert NonERC721Receiver();
                } else {
                    // solhint-disable-next-line no-inline-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    
    ///  Calling conditions:
    ///
    ///  - When `from` and `to` are both non-zero, `from`'s `vaultID` will be
    ///  transferred to `to`.
    ///  - When `from` is zero, `vaultID` will be minted for `to`.
    ///  - When `to` is zero, `from`'s `vaultID` will be burned.
    ///  - `from` and `to` are never both zero.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 vaultID
    ) internal virtual {}
}

// 
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Metadata.sol)

pragma solidity ^0.8.0;



// 
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// 

pragma solidity ^0.8.12;







abstract contract VaultManagerPermit is Initializable, VaultManagerERC721 {
    using Address for address;

    mapping(address => uint256) private _nonces;
    /* solhint-disable var-name-mixedcase */
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private _PERMIT_TYPEHASH;
    /* solhint-enable var-name-mixedcase */

    error ExpiredDeadline();
    error InvalidSignature();

    //solhint-disable-next-line
    function __ERC721Permit_init(string memory _name) internal onlyInitializing {
        _PERMIT_TYPEHASH = keccak256(
            "Permit(address owner,address spender,bool approved,uint256 nonce,uint256 deadline)"
        );
        _HASHED_NAME = keccak256(bytes(_name));
        _HASHED_VERSION = keccak256(bytes("1"));
    }

    
    
    
    
    
    
    function permit(
        address owner,
        address spender,
        bool approved,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (block.timestamp > deadline) revert ExpiredDeadline();
        // Additional signature checks performed in the `ECDSAUpgradeable.recover` function
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0 || (v != 27 && v != 28))
            revert InvalidSignature();

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                _domainSeparatorV4(),
                keccak256(
                    abi.encode(
                        _PERMIT_TYPEHASH,
                        // 0x3f43a9c6bafb5c7aab4e0cfe239dc5d4c15caf0381c6104188191f78a6640bd8,
                        owner,
                        spender,
                        approved,
                        _useNonce(owner),
                        deadline
                    )
                )
            )
        );
        if (owner.isContract()) {
            if (IERC1271(owner).isValidSignature(digest, abi.encodePacked(r, s, v)) != 0x1626ba7e)
                revert InvalidSignature();
        } else {
            address signer = ecrecover(digest, v, r, s);
            if (signer != owner || signer == address(0)) revert InvalidSignature();
        }

        _setApprovalForAll(owner, spender, approved);
    }

    
    function nonces(address owner) public view returns (uint256) {
        return _nonces[owner];
    }

    
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    
    function _domainSeparatorV4() internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    // keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)')
                    0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
                    _HASHED_NAME,
                    _HASHED_VERSION,
                    block.chainid,
                    address(this)
                )
            );
    }

    
    function _useNonce(address owner) internal returns (uint256 current) {
        current = _nonces[owner];
        _nonces[owner] = current + 1;
    }

    uint256[49] private __gap;
}

// 

pragma solidity ^0.8.12;






// ========================= Key Structs and Enums =============================


/// to parameters which signification is detailed in the `VaultManagerStorage` file
struct VaultParameters {
    uint256 debtCeiling;
    uint64 collateralFactor;
    uint64 targetHealthFactor;
    uint64 interestRate;
    uint64 liquidationSurcharge;
    uint64 maxLiquidationDiscount;
    bool whitelistingActivated;
    uint256 baseBoost;
}


struct Vault {
    // Amount of collateral deposited in the vault, in collateral decimals. For example, if the collateral
    // is USDC with 6 decimals, then `collateralAmount` will be in base 10**6
    uint256 collateralAmount;
    // Normalized value of the debt (that is to say of the stablecoins borrowed). It is expressed
    // in the base of Angle stablecoins (i.e. `BASE_TOKENS = 10**18`)
    uint256 normalizedDebt;
}


/// amount that could be repaid by liquidating the position

struct LiquidationOpportunity {
    // Maximum stablecoin amount that can be repaid upon liquidating the vault
    uint256 maxStablecoinAmountToRepay;
    // Collateral amount given to the person in the case where the maximum amount to repay is given
    uint256 maxCollateralAmountGiven;
    // Threshold value of stablecoin amount to repay: it is ok for a liquidator to repay below threshold,
    // but if this threshold is non null and the liquidator wants to repay more than threshold, it should repay
    // the max stablecoin amount given in this vault
    uint256 thresholdRepayAmount;
    // Discount proposed to the liquidator on the collateral
    uint256 discount;
    // Amount of debt in the vault
    uint256 currentDebt;
}


/// essential data for vaults being liquidated
struct LiquidatorData {
    // Current amount of stablecoins the liquidator should give to the contract
    uint256 stablecoinAmountToReceive;
    // Current amount of collateral the contract should give to the liquidator
    uint256 collateralAmountToGive;
    // Bad debt accrued across the liquidation process
    uint256 badDebtFromLiquidation;
    // Oracle value (in stablecoin base) at the time of the liquidation
    uint256 oracleValue;
    // Value of the `interestAccumulator` at the time of the call
    uint256 newInterestAccumulator;
}


/// to the caller or associated addresses
struct PaymentData {
    // Stablecoin amount the contract should give
    uint256 stablecoinAmountToGive;
    // Stablecoin amount owed to the contract
    uint256 stablecoinAmountToReceive;
    // Collateral amount the contract should give
    uint256 collateralAmountToGive;
    // Collateral amount owed to the contract
    uint256 collateralAmountToReceive;
}


enum ActionType {
    createVault,
    closeVault,
    addCollateral,
    removeCollateral,
    repayDebt,
    borrow,
    getDebtIn,
    permit
}

// ========================= Interfaces =============================





/// of this module (without getters)
interface IVaultManagerFunctions {
    
    
    
    
    function accrueInterestToTreasury() external returns (uint256 surplusValue, uint256 badDebtValue);

    
    
    
    /// internal debt amount
    
    /// arbitraging difference in minting fees
    
    /// differences in repay fees
    
    function getDebtOut(
        uint256 vaultID,
        uint256 amountStablecoins,
        uint256 senderBorrowFee,
        uint256 senderRepayFee
    ) external;

    
    
    
    function getVaultDebt(uint256 vaultID) external view returns (uint256);

    
    
    /// over time
    function getTotalDebt() external view returns (uint256);

    
    
    
    /// calling this function
    function setTreasury(address _treasury) external;

    
    
    
    
    function createVault(address toVault) external returns (uint256);

    
    /// this function can perform any of the allowed actions in the order of their choice
    
    
    
    /// should either be the `msg.sender` or be approved by the latter
    
    
    
    
    /// or how much has been received). Note that the values in the struct are not aggregated and you could have in the output
    /// a positive amount of stablecoins to receive as well as a positive amount of stablecoins to give
    
    /// or computations (like `oracleValue`) are done only once
    
    /// use the latest `vaultID`. This is the default behavior, and unless you're engaging into some complex protocol actions
    /// it is encouraged to use `vaultID = 0` only when the first action of the batch is `createVault`
    function angle(
        ActionType[] memory actions,
        bytes[] memory datas,
        address from,
        address to,
        address who,
        bytes memory repayData
    ) external returns (PaymentData memory paymentData);

    
    /// without having to provide `who` and `repayData` parameters
    function angle(
        ActionType[] memory actions,
        bytes[] memory datas,
        address from,
        address to
    ) external returns (PaymentData memory paymentData);

    
    
    
    
    
    
    /// contract has been initialized
    
    /// boost
    function initialize(
        ITreasury _treasury,
        IERC20 _collateral,
        IOracle _oracle,
        VaultParameters calldata params,
        string memory _symbol
    ) external;

    
    function dust() external view returns (uint256);
}

// 

pragma solidity ^0.8.12;






/// logic (fees and interest rate) as well as the liquidation logic


contract VaultManager is VaultManagerPermit, IVaultManagerFunctions {
    using SafeERC20 for IERC20;
    using Address for address;

    
    uint256 public dust;

    
    /// in a vault during a liquidation where the health factor function is decreasing
    uint256 internal _dustCollateral;

    uint256[48] private __gapVaultManager;

    
    function initialize(
        ITreasury _treasury,
        IERC20 _collateral,
        IOracle _oracle,
        VaultParameters calldata params,
        string memory _symbol
    ) external initializer {
        if (_oracle.treasury() != _treasury) revert InvalidTreasury();
        treasury = _treasury;
        collateral = _collateral;
        _collatBase = 10**(IERC20Metadata(address(collateral)).decimals());
        stablecoin = IAgToken(_treasury.stablecoin());
        oracle = _oracle;
        string memory _name = string.concat("Angle Protocol ", _symbol, " Vault");
        name = _name;
        __ERC721Permit_init(_name);
        symbol = string.concat(_symbol, "-vault");

        interestAccumulator = BASE_INTEREST;
        lastInterestAccumulatorUpdated = block.timestamp;

        // Checking if the parameters have been correctly initialized
        if (
            params.collateralFactor > params.liquidationSurcharge ||
            params.liquidationSurcharge > BASE_PARAMS ||
            BASE_PARAMS > params.targetHealthFactor ||
            params.maxLiquidationDiscount >= BASE_PARAMS ||
            params.baseBoost == 0
        ) revert InvalidSetOfParameters();

        debtCeiling = params.debtCeiling;
        collateralFactor = params.collateralFactor;
        targetHealthFactor = params.targetHealthFactor;
        interestRate = params.interestRate;
        liquidationSurcharge = params.liquidationSurcharge;
        maxLiquidationDiscount = params.maxLiquidationDiscount;
        whitelistingActivated = params.whitelistingActivated;
        yLiquidationBoost = [params.baseBoost];
        paused = true;
    }

    // ================================= MODIFIERS =================================

    
    modifier onlyGovernor() {
        if (!treasury.isGovernor(msg.sender)) revert NotGovernor();
        _;
    }

    
    modifier onlyGovernorOrGuardian() {
        if (!treasury.isGovernorOrGuardian(msg.sender)) revert NotGovernorOrGuardian();
        _;
    }

    
    modifier onlyTreasury() {
        if (msg.sender != address(treasury)) revert NotTreasury();
        _;
    }

    
    modifier whenNotPaused() {
        if (paused) revert Paused();
        _;
    }

    // ============================== VAULT FUNCTIONS ==============================

    
    function createVault(address toVault) external whenNotPaused returns (uint256) {
        return _mint(toVault);
    }

    
    function angle(
        ActionType[] memory actions,
        bytes[] memory datas,
        address from,
        address to
    ) external returns (PaymentData memory) {
        return angle(actions, datas, from, to, address(0), new bytes(0));
    }

    
    function angle(
        ActionType[] memory actions,
        bytes[] memory datas,
        address from,
        address to,
        address who,
        bytes memory repayData
    ) public whenNotPaused nonReentrant returns (PaymentData memory paymentData) {
        if (actions.length != datas.length || actions.length == 0) revert IncompatibleLengths();
        // `newInterestAccumulator` and `oracleValue` are expensive to compute. Therefore, they are computed
        // only once inside the first action where they are necessary, then they are passed forward to further actions
        uint256 newInterestAccumulator;
        uint256 oracleValue;
        uint256 collateralAmount;
        uint256 stablecoinAmount;
        uint256 vaultID;
        for (uint256 i; i < actions.length; ++i) {
            ActionType action = actions[i];
            // Processing actions which do not need the value of the oracle or of the `interestAccumulator`
            if (action == ActionType.createVault) {
                _mint(abi.decode(datas[i], (address)));
            } else if (action == ActionType.addCollateral) {
                (vaultID, collateralAmount) = abi.decode(datas[i], (uint256, uint256));
                if (vaultID == 0) vaultID = vaultIDCount;
                _addCollateral(vaultID, collateralAmount);
                paymentData.collateralAmountToReceive += collateralAmount;
            } else if (action == ActionType.permit) {
                address owner;
                bytes32 r;
                bytes32 s;
                // Watch out naming conventions for permit are not respected to save some space and reduce the stack size
                // `vaultID` is used in place of the `deadline` parameter
                // Same for `collateralAmount` used in place of `value`
                // `stablecoinAmount` is used in place of the `v`
                (owner, collateralAmount, vaultID, stablecoinAmount, r, s) = abi.decode(
                    datas[i],
                    (address, uint256, uint256, uint256, bytes32, bytes32)
                );
                IERC20PermitUpgradeable(address(collateral)).permit(
                    owner,
                    address(this),
                    collateralAmount,
                    vaultID,
                    uint8(stablecoinAmount),
                    r,
                    s
                );
            } else {
                // Processing actions which rely on the `interestAccumulator`: first accruing it to make
                // sure surplus is correctly taken into account between debt changes
                if (newInterestAccumulator == 0) newInterestAccumulator = _accrue();
                if (action == ActionType.repayDebt) {
                    (vaultID, stablecoinAmount) = abi.decode(datas[i], (uint256, uint256));
                    if (vaultID == 0) vaultID = vaultIDCount;
                    stablecoinAmount = _repayDebt(vaultID, stablecoinAmount, newInterestAccumulator);
                    uint256 stablecoinAmountPlusRepayFee = (stablecoinAmount * BASE_PARAMS) / (BASE_PARAMS - repayFee);
                    surplus += stablecoinAmountPlusRepayFee - stablecoinAmount;
                    paymentData.stablecoinAmountToReceive += stablecoinAmountPlusRepayFee;
                } else {
                    // Processing actions which need the oracle value
                    if (oracleValue == 0) oracleValue = oracle.read();
                    if (action == ActionType.closeVault) {
                        vaultID = abi.decode(datas[i], (uint256));
                        if (vaultID == 0) vaultID = vaultIDCount;
                        (stablecoinAmount, collateralAmount) = _closeVault(
                            vaultID,
                            oracleValue,
                            newInterestAccumulator
                        );
                        paymentData.collateralAmountToGive += collateralAmount;
                        paymentData.stablecoinAmountToReceive += stablecoinAmount;
                    } else if (action == ActionType.removeCollateral) {
                        (vaultID, collateralAmount) = abi.decode(datas[i], (uint256, uint256));
                        if (vaultID == 0) vaultID = vaultIDCount;
                        _removeCollateral(vaultID, collateralAmount, oracleValue, newInterestAccumulator);
                        paymentData.collateralAmountToGive += collateralAmount;
                    } else if (action == ActionType.borrow) {
                        (vaultID, stablecoinAmount) = abi.decode(datas[i], (uint256, uint256));
                        if (vaultID == 0) vaultID = vaultIDCount;
                        stablecoinAmount = _borrow(vaultID, stablecoinAmount, oracleValue, newInterestAccumulator);
                        paymentData.stablecoinAmountToGive += stablecoinAmount;
                    } else if (action == ActionType.getDebtIn) {
                        address vaultManager;
                        uint256 dstVaultID;
                        (vaultID, vaultManager, dstVaultID, stablecoinAmount) = abi.decode(
                            datas[i],
                            (uint256, address, uint256, uint256)
                        );
                        if (vaultID == 0) vaultID = vaultIDCount;
                        _getDebtIn(
                            vaultID,
                            IVaultManager(vaultManager),
                            dstVaultID,
                            stablecoinAmount,
                            oracleValue,
                            newInterestAccumulator
                        );
                    }
                }
            }
        }

        // Processing the different cases for the repayment, there are 4 of them:
        // - (1) Stablecoins to receive + collateral to send
        // - (2) Stablecoins to receive + collateral to receive
        // - (3) Stablecoins to send + collateral to send
        // - (4) Stablecoins to send + collateral to receive
        if (paymentData.stablecoinAmountToReceive >= paymentData.stablecoinAmountToGive) {
            uint256 stablecoinPayment = paymentData.stablecoinAmountToReceive - paymentData.stablecoinAmountToGive;
            if (paymentData.collateralAmountToGive >= paymentData.collateralAmountToReceive) {
                // In the case where all amounts are null, the function will enter here and nothing will be done
                // for the repayment
                _handleRepay(
                    // Collateral payment is the difference between what to give and what to receive
                    paymentData.collateralAmountToGive - paymentData.collateralAmountToReceive,
                    stablecoinPayment,
                    from,
                    to,
                    who,
                    repayData
                );
            } else {
                if (stablecoinPayment != 0) stablecoin.burnFrom(stablecoinPayment, from, msg.sender);
                // In this case the collateral amount is necessarily non null
                collateral.safeTransferFrom(
                    msg.sender,
                    address(this),
                    paymentData.collateralAmountToReceive - paymentData.collateralAmountToGive
                );
            }
        } else {
            uint256 stablecoinPayment = paymentData.stablecoinAmountToGive - paymentData.stablecoinAmountToReceive;
            // `stablecoinPayment` is strictly positive in this case
            stablecoin.mint(to, stablecoinPayment);
            if (paymentData.collateralAmountToGive > paymentData.collateralAmountToReceive) {
                collateral.safeTransfer(to, paymentData.collateralAmountToGive - paymentData.collateralAmountToReceive);
            } else {
                uint256 collateralPayment = paymentData.collateralAmountToReceive - paymentData.collateralAmountToGive;
                if (collateralPayment != 0) {
                    if (repayData.length != 0) {
                        ISwapper(who).swap(
                            IERC20(address(stablecoin)),
                            collateral,
                            msg.sender,
                            // As per the `ISwapper` interface, we must first give the amount of token owed by the address before
                            // the amount of token it (or another related address) obtained
                            collateralPayment,
                            stablecoinPayment,
                            repayData
                        );
                    }
                    collateral.safeTransferFrom(msg.sender, address(this), collateralPayment);
                }
            }
        }
    }

    
    function getDebtOut(
        uint256 vaultID,
        uint256 stablecoinAmount,
        uint256 senderBorrowFee,
        uint256 senderRepayFee
    ) external whenNotPaused {
        if (!treasury.isVaultManager(msg.sender)) revert NotVaultManager();
        // Getting debt out of a vault is equivalent to repaying a portion of your debt, and this could leave exploits:
        // someone could borrow from a vault and transfer its debt to a `VaultManager` contract where debt repayment will
        // be cheaper: in which case we're making people pay the delta
        uint256 _repayFee;
        if (repayFee > senderRepayFee) {
            _repayFee = repayFee - senderRepayFee;
        }
        // Checking the delta of borrow fees to eliminate the risk of exploits here: a similar thing could happen: people
        // could mint from where it is cheap to mint and then transfer their debt to places where it is more expensive
        // to mint
        uint256 _borrowFee;
        if (senderBorrowFee > borrowFee) {
            _borrowFee = senderBorrowFee - borrowFee;
        }

        uint256 stablecoinAmountLessFeePaid = (stablecoinAmount *
            (BASE_PARAMS - _repayFee) *
            (BASE_PARAMS - _borrowFee)) / (BASE_PARAMS**2);
        surplus += stablecoinAmount - stablecoinAmountLessFeePaid;
        _repayDebt(vaultID, stablecoinAmountLessFeePaid, 0);
    }

    // =============================== VIEW FUNCTIONS ==============================

    
    function getVaultDebt(uint256 vaultID) external view returns (uint256) {
        return (vaultData[vaultID].normalizedDebt * _calculateCurrentInterestAccumulator()) / BASE_INTEREST;
    }

    
    function getTotalDebt() external view returns (uint256) {
        return (totalNormalizedDebt * _calculateCurrentInterestAccumulator()) / BASE_INTEREST;
    }

    
    
    
    
    
    function checkLiquidation(uint256 vaultID, address liquidator)
        external
        view
        returns (LiquidationOpportunity memory liqOpp)
    {
        liqOpp = _checkLiquidation(
            vaultData[vaultID],
            liquidator,
            oracle.read(),
            _calculateCurrentInterestAccumulator()
        );
    }

    // ====================== INTERNAL UTILITY VIEW FUNCTIONS ======================

    
    /// (i.e. should be liquidated or not)
    
    
    
    
    
    
    function _isSolvent(
        Vault memory vault,
        uint256 oracleValue,
        uint256 newInterestAccumulator
    )
        internal
        view
        returns (
            uint256 healthFactor,
            uint256 currentDebt,
            uint256 collateralAmountInStable
        )
    {
        currentDebt = (vault.normalizedDebt * newInterestAccumulator) / BASE_INTEREST;
        collateralAmountInStable = (vault.collateralAmount * oracleValue) / _collatBase;
        if (currentDebt == 0) healthFactor = type(uint256).max;
        else healthFactor = (collateralAmountInStable * collateralFactor) / currentDebt;
    }

    
    /// in storage
    
    /// (1+x)^n = 1+n*x+[n/2*(n-1)]*x^2+[n/6*(n-1)*(n-2)*x^3...
    
    
    function _calculateCurrentInterestAccumulator() internal view returns (uint256) {
        uint256 exp = block.timestamp - lastInterestAccumulatorUpdated;
        uint256 ratePerSecond = interestRate;
        if (exp == 0 || ratePerSecond == 0) return interestAccumulator;
        uint256 expMinusOne = exp - 1;
        uint256 expMinusTwo = exp > 2 ? exp - 2 : 0;
        uint256 basePowerTwo = (ratePerSecond * ratePerSecond + HALF_BASE_INTEREST) / BASE_INTEREST;
        uint256 basePowerThree = (basePowerTwo * ratePerSecond + HALF_BASE_INTEREST) / BASE_INTEREST;
        uint256 secondTerm = (exp * expMinusOne * basePowerTwo) / 2;
        uint256 thirdTerm = (exp * expMinusOne * expMinusTwo * basePowerThree) / 6;
        return (interestAccumulator * (BASE_INTEREST + ratePerSecond * exp + secondTerm + thirdTerm)) / BASE_INTEREST;
    }

    // ================= INTERNAL UTILITY STATE-MODIFYING FUNCTIONS ================

    
    
    
    
    
    
    
    function _closeVault(
        uint256 vaultID,
        uint256 oracleValue,
        uint256 newInterestAccumulator
    ) internal onlyApprovedOrOwner(msg.sender, vaultID) returns (uint256, uint256) {
        Vault memory vault = vaultData[vaultID];
        (uint256 healthFactor, uint256 currentDebt, ) = _isSolvent(vault, oracleValue, newInterestAccumulator);
        if (healthFactor <= BASE_PARAMS) revert InsolventVault();
        totalNormalizedDebt -= vault.normalizedDebt;
        _burn(vaultID);
        uint256 currentDebtPlusRepayFee = (currentDebt * BASE_PARAMS) / (BASE_PARAMS - repayFee);
        surplus += currentDebtPlusRepayFee - currentDebt;
        return (currentDebtPlusRepayFee, vault.collateralAmount);
    }

    
    
    
    function _addCollateral(uint256 vaultID, uint256 collateralAmount) internal {
        if (!_exists(vaultID)) revert NonexistentVault();
        _checkpointCollateral(vaultID, collateralAmount, true);
        vaultData[vaultID].collateralAmount += collateralAmount;
        emit CollateralAmountUpdated(vaultID, collateralAmount, 1);
    }

    
    
    
    
    
    /// computed yet)
    function _removeCollateral(
        uint256 vaultID,
        uint256 collateralAmount,
        uint256 oracleValue,
        uint256 interestAccumulator_
    ) internal onlyApprovedOrOwner(msg.sender, vaultID) {
        _checkpointCollateral(vaultID, collateralAmount, false);
        vaultData[vaultID].collateralAmount -= collateralAmount;
        (uint256 healthFactor, , ) = _isSolvent(vaultData[vaultID], oracleValue, interestAccumulator_);
        if (healthFactor <= BASE_PARAMS) revert InsolventVault();
        emit CollateralAmountUpdated(vaultID, collateralAmount, 0);
    }

    
    
    
    
    
    
    function _borrow(
        uint256 vaultID,
        uint256 stablecoinAmount,
        uint256 oracleValue,
        uint256 newInterestAccumulator
    ) internal onlyApprovedOrOwner(msg.sender, vaultID) returns (uint256 toMint) {
        stablecoinAmount = _increaseDebt(vaultID, stablecoinAmount, oracleValue, newInterestAccumulator);
        uint256 borrowFeePaid = (borrowFee * stablecoinAmount) / BASE_PARAMS;
        surplus += borrowFeePaid;
        toMint = stablecoinAmount - borrowFeePaid;
    }

    
    
    
    
    
    /// to a normalized value in both `VaultManager` contracts
    
    
    /// computed yet)
    
    
    /// from any vaultManager contract can see its debt reduced by this means
    function _getDebtIn(
        uint256 srcVaultID,
        IVaultManager vaultManager,
        uint256 dstVaultID,
        uint256 stablecoinAmount,
        uint256 oracleValue,
        uint256 newInterestAccumulator
    ) internal onlyApprovedOrOwner(msg.sender, srcVaultID) {
        emit DebtTransferred(srcVaultID, dstVaultID, address(vaultManager), stablecoinAmount);
        // The `stablecoinAmount` needs to be rounded down in the `_increaseDebt` function to reduce the room for exploits
        stablecoinAmount = _increaseDebt(srcVaultID, stablecoinAmount, oracleValue, newInterestAccumulator);
        if (address(vaultManager) == address(this)) {
            // No repayFees taken in this case, otherwise the same stablecoin may end up paying fees twice
            _repayDebt(dstVaultID, stablecoinAmount, newInterestAccumulator);
        } else {
            // No need to check the integrity of `VaultManager` here because `_getDebtIn` can be entered only through the
            // `angle` function which is non reentrant. Also, `getDebtOut` failing would be at the attacker loss, as they
            // would get their debt increasing in the current vault without decreasing it in the remote vault.
            vaultManager.getDebtOut(dstVaultID, stablecoinAmount, borrowFee, repayFee);
        }
    }

    
    
    
    /// normalized debt using the pre-computed (or not) `newInterestAccumulator` value
    
    
    /// computed yet)
    
    
    /// amount of stablecoins minted is smaller than the debt increase
    function _increaseDebt(
        uint256 vaultID,
        uint256 stablecoinAmount,
        uint256 oracleValue,
        uint256 newInterestAccumulator
    ) internal returns (uint256) {
        // We normalize the amount by dividing it by `newInterestAccumulator`. This makes accounting easier, since
        // it allows us to process all (past and future) debts like debts created at the inception of the contract.
        uint256 changeAmount = (stablecoinAmount * BASE_INTEREST) / newInterestAccumulator;
        // if there was no previous debt, we have to check that the debt creation will be higher than `dust`
        if (vaultData[vaultID].normalizedDebt == 0)
            if (stablecoinAmount <= dust) revert DustyLeftoverAmount();
        vaultData[vaultID].normalizedDebt += changeAmount;
        totalNormalizedDebt += changeAmount;
        if (totalNormalizedDebt * newInterestAccumulator > debtCeiling * BASE_INTEREST) revert DebtCeilingExceeded();
        (uint256 healthFactor, , ) = _isSolvent(vaultData[vaultID], oracleValue, newInterestAccumulator);
        if (healthFactor <= BASE_PARAMS) revert InsolventVault();
        emit InternalDebtUpdated(vaultID, changeAmount, 1);
        return (changeAmount * newInterestAccumulator) / BASE_INTEREST;
    }

    
    /// to a dusty amount or no debt at all
    
    
    /// normalized debt using the pre-computed (or not) `newInterestAccumulator` value
    /// To repay the whole debt, one can pass `type(uint256).max`
    
    /// computed yet, like in `getDebtOut`)
    
    
    function _repayDebt(
        uint256 vaultID,
        uint256 stablecoinAmount,
        uint256 newInterestAccumulator
    ) internal returns (uint256) {
        if (newInterestAccumulator == 0) newInterestAccumulator = _accrue();
        uint256 newVaultNormalizedDebt = vaultData[vaultID].normalizedDebt;
        // To save one variable declaration, `changeAmount` is first expressed in stablecoin amount before being converted
        // to a normalized amount. Here we first store the maximum amount that can be repaid given the current debt
        uint256 changeAmount = (newVaultNormalizedDebt * newInterestAccumulator) / BASE_INTEREST;
        // In some situations (e.g. liquidations), the `stablecoinAmount` is rounded above and we want to make
        // sure to avoid underflows in all situations
        if (stablecoinAmount >= changeAmount) {
            stablecoinAmount = changeAmount;
            changeAmount = newVaultNormalizedDebt;
        } else {
            changeAmount = (stablecoinAmount * BASE_INTEREST) / newInterestAccumulator;
        }
        newVaultNormalizedDebt -= changeAmount;
        totalNormalizedDebt -= changeAmount;
        if (newVaultNormalizedDebt != 0 && newVaultNormalizedDebt * newInterestAccumulator <= dust * BASE_INTEREST)
            revert DustyLeftoverAmount();
        vaultData[vaultID].normalizedDebt = newVaultNormalizedDebt;
        emit InternalDebtUpdated(vaultID, changeAmount, 0);
        return stablecoinAmount;
    }

    
    
    
    
    /// approved by it
    
    
    
    /// to the `from` address
    
    function _handleRepay(
        uint256 collateralAmountToGive,
        uint256 stableAmountToRepay,
        address from,
        address to,
        address who,
        bytes memory data
    ) internal {
        if (collateralAmountToGive != 0) collateral.safeTransfer(to, collateralAmountToGive);
        if (stableAmountToRepay != 0) {
            if (data.length != 0) {
                ISwapper(who).swap(
                    collateral,
                    IERC20(address(stablecoin)),
                    from,
                    stableAmountToRepay,
                    collateralAmountToGive,
                    data
                );
            }
            stablecoin.burnFrom(stableAmountToRepay, from, msg.sender);
        }
    }

    // ====================== TREASURY RELATIONSHIP FUNCTIONS ======================

    
    function accrueInterestToTreasury() external onlyTreasury returns (uint256 surplusValue, uint256 badDebtValue) {
        _accrue();
        surplusValue = surplus;
        badDebtValue = badDebt;
        surplus = 0;
        badDebt = 0;
        if (surplusValue >= badDebtValue) {
            surplusValue -= badDebtValue;
            badDebtValue = 0;
            stablecoin.mint(address(treasury), surplusValue);
        } else {
            badDebtValue -= surplusValue;
            surplusValue = 0;
        }
        emit AccruedToTreasury(surplusValue, badDebtValue);
    }

    
    
    
    /// value is about to change
    function _accrue() internal returns (uint256 newInterestAccumulator) {
        newInterestAccumulator = _calculateCurrentInterestAccumulator();
        uint256 interestAccrued = (totalNormalizedDebt * (newInterestAccumulator - interestAccumulator)) /
            BASE_INTEREST;
        surplus += interestAccrued;
        interestAccumulator = newInterestAccumulator;
        lastInterestAccumulatorUpdated = block.timestamp;
        emit InterestAccumulatorUpdated(newInterestAccumulator, block.timestamp);
        return newInterestAccumulator;
    }

    // ================================ LIQUIDATIONS ===============================

    
    
    /// a `who` and a `data` parameter
    function liquidate(
        uint256[] memory vaultIDs,
        uint256[] memory amounts,
        address from,
        address to
    ) external returns (LiquidatorData memory) {
        return liquidate(vaultIDs, amounts, from, to, address(0), new bytes(0));
    }

    
    
    
    
    /// or have received an approval
    
    
    
    /// stablecoins to get the discounted collateral. If not, it is used by the repayment contract to swap a portion or all
    /// of the collateral received to stablecoins to be sent to the `from` address. More details in the `_handleRepay` function
    
    /// stablecoins have been repaid, how much collateral has been received)
    
    function liquidate(
        uint256[] memory vaultIDs,
        uint256[] memory amounts,
        address from,
        address to,
        address who,
        bytes memory data
    ) public whenNotPaused nonReentrant returns (LiquidatorData memory liqData) {
        uint256 vaultIDsLength = vaultIDs.length;
        if (vaultIDsLength != amounts.length || vaultIDsLength == 0) revert IncompatibleLengths();
        // Stores all the data about an ongoing liquidation of multiple vaults
        liqData.oracleValue = oracle.read();
        liqData.newInterestAccumulator = _accrue();
        emit LiquidatedVaults(vaultIDs);
        for (uint256 i; i < vaultIDsLength; ++i) {
            Vault memory vault = vaultData[vaultIDs[i]];
            // Computing if liquidation can take place for a vault
            LiquidationOpportunity memory liqOpp = _checkLiquidation(
                vault,
                msg.sender,
                liqData.oracleValue,
                liqData.newInterestAccumulator
            );

            // Makes sure not to leave a dusty amount in the vault by either not liquidating too much
            // or everything
            if (
                (liqOpp.thresholdRepayAmount != 0 && amounts[i] >= liqOpp.thresholdRepayAmount) ||
                amounts[i] > liqOpp.maxStablecoinAmountToRepay
            ) amounts[i] = liqOpp.maxStablecoinAmountToRepay;

            // liqOpp.discount stores in fact `1-discount`
            uint256 collateralReleased = (amounts[i] * BASE_PARAMS * _collatBase) /
                (liqOpp.discount * liqData.oracleValue);

            _checkpointCollateral(
                vaultIDs[i],
                vault.collateralAmount <= collateralReleased ? vault.collateralAmount : collateralReleased,
                false
            );
            // Because we're rounding up in some divisions, `collateralReleased` can be greater than the `collateralAmount` of the vault
            // In this case, `stablecoinAmountToReceive` is still rounded up
            if (vault.collateralAmount <= collateralReleased) {
                collateralReleased = vault.collateralAmount;
                // Remove all the vault's debt (debt repayed + bad debt) from VaultManager totalDebt
                totalNormalizedDebt -= vault.normalizedDebt;
                // Reinitializing the `vaultID`: we're not burning the vault in this case for integration purposes
                delete vaultData[vaultIDs[i]];
                {
                    uint256 debtReimbursed = (amounts[i] * liquidationSurcharge) / BASE_PARAMS;
                    liqData.badDebtFromLiquidation += debtReimbursed < liqOpp.currentDebt
                        ? liqOpp.currentDebt - debtReimbursed
                        : 0;
                }
                // There may be an edge case in which: `amounts[i] = (currentDebt * BASE_PARAMS) / surcharge + 1`
                // In this case, as long as `surcharge < BASE_PARAMS`, there cannot be any underflow in the operation
                // above
                emit InternalDebtUpdated(vaultIDs[i], vault.normalizedDebt, 0);
            } else {
                vaultData[vaultIDs[i]].collateralAmount -= collateralReleased;
                _repayDebt(
                    vaultIDs[i],
                    (amounts[i] * liquidationSurcharge) / BASE_PARAMS,
                    liqData.newInterestAccumulator
                );
            }
            liqData.collateralAmountToGive += collateralReleased;
            liqData.stablecoinAmountToReceive += amounts[i];
        }
        // Normalization of good and bad debt is already handled in the `accrueInterestToTreasury` function
        surplus += (liqData.stablecoinAmountToReceive * (BASE_PARAMS - liquidationSurcharge)) / BASE_PARAMS;
        badDebt += liqData.badDebtFromLiquidation;
        _handleRepay(liqData.collateralAmountToGive, liqData.stablecoinAmountToReceive, from, to, who, data);
    }

    
    
    /// and `newInterestAccumulator` should have always been computed
    function _checkLiquidation(
        Vault memory vault,
        address liquidator,
        uint256 oracleValue,
        uint256 newInterestAccumulator
    ) internal view returns (LiquidationOpportunity memory liqOpp) {
        // Checking if the vault can be liquidated
        (uint256 healthFactor, uint256 currentDebt, uint256 collateralAmountInStable) = _isSolvent(
            vault,
            oracleValue,
            newInterestAccumulator
        );
        // Health factor of a vault that does not exist is `type(uint256).max`
        if (healthFactor >= BASE_PARAMS) revert HealthyVault();

        uint256 liquidationDiscount = (_computeLiquidationBoost(liquidator) * (BASE_PARAMS - healthFactor)) /
            BASE_PARAMS;
        // In fact `liquidationDiscount` is stored here as 1 minus discount to save some computation costs
        // This value is necessarily != 0 as `maxLiquidationDiscount < BASE_PARAMS`
        liquidationDiscount = liquidationDiscount >= maxLiquidationDiscount
            ? BASE_PARAMS - maxLiquidationDiscount
            : BASE_PARAMS - liquidationDiscount;
        // Same for the surcharge here: it's in fact 1 - the fee taken by the protocol
        uint256 surcharge = liquidationSurcharge;
        // Checking if we're in a situation where the health factor is an increasing or a decreasing function of the
        // amount repaid
        uint256 maxAmountToRepay;
        uint256 thresholdRepayAmount;
        // In the first case, the health factor is an increasing function of the stablecoin amount to repay,
        // this means that the liquidator can bring the vault to the target health ratio
        if (healthFactor * liquidationDiscount * surcharge >= collateralFactor * BASE_PARAMS**2) {
            // This is the max amount to repay that will bring the person to the target health factor
            // Denom is always positive when a vault gets liquidated in this case and when the health factor
            // is an increasing function of the amount of stablecoins repaid
            // And given that most parameters are in base 9, the numerator can very hardly overflow here
            maxAmountToRepay =
                ((targetHealthFactor * currentDebt - collateralAmountInStable * collateralFactor) *
                    BASE_PARAMS *
                    liquidationDiscount) /
                (surcharge * targetHealthFactor * liquidationDiscount - (BASE_PARAMS**2) * collateralFactor);
            // The quantity below tends to be rounded in the above direction, which means that governance or guardians should
            // set the `targetHealthFactor` accordingly
            // Need to check for the dust: liquidating should not leave a dusty amount in the vault
            if (currentDebt * BASE_PARAMS <= maxAmountToRepay * surcharge + dust * BASE_PARAMS) {
                // If liquidating to the target threshold would leave a dusty amount: the liquidator can repay all
                // We're rounding up the max amount to repay to make sure all the debt ends up being paid
                // and we're computing again the real value of the debt to avoid propagation of rounding errors
                maxAmountToRepay =
                    (vault.normalizedDebt * newInterestAccumulator * BASE_PARAMS) /
                    (surcharge * BASE_INTEREST) +
                    1;
                // In this case the threshold amount is such that it leaves just enough dust: amount is rounded
                // down such that if a liquidator repays this amount then there would be more than `dust` left in
                // the liquidated vault
                if (currentDebt > dust)
                    thresholdRepayAmount = ((currentDebt - dust) * BASE_PARAMS) / surcharge;
                    // If there is from the beginning a dusty debt (because of an implementation upgrade), then
                    // liquidator should repay everything that's left
                else thresholdRepayAmount = 1;
            }
        } else {
            // In all cases the liquidator can repay stablecoins such that they'll end up getting exactly the collateral
            // in the liquidated vault
            // Rounding up to make sure all gets liquidated in this case: the liquidator will never get more than the collateral
            // amount in the vault however: we're performing the computation of the `collateralAmountInStable` again to avoid
            // propagation of rounding errors
            maxAmountToRepay =
                (vault.collateralAmount * liquidationDiscount * oracleValue) /
                (BASE_PARAMS * _collatBase) +
                1;
            // It should however make sure not to leave a dusty amount of collateral (in stablecoin value) in the vault
            if (collateralAmountInStable > _dustCollateral)
                // There's no issue with this amount being rounded down
                thresholdRepayAmount =
                    ((collateralAmountInStable - _dustCollateral) * liquidationDiscount) /
                    BASE_PARAMS;
                // If there is from the beginning a dusty amount of collateral, liquidator should repay everything that's left
            else thresholdRepayAmount = 1;
        }
        liqOpp.maxStablecoinAmountToRepay = maxAmountToRepay;
        liqOpp.maxCollateralAmountGiven =
            (maxAmountToRepay * BASE_PARAMS * _collatBase) /
            (oracleValue * liquidationDiscount);
        liqOpp.thresholdRepayAmount = thresholdRepayAmount;
        liqOpp.discount = liquidationDiscount;
        liqOpp.currentDebt = currentDebt;
    }

    // ================================== SETTERS ==================================

    
    
    
    
    
    /// and hence when liquidating a vault is going to decrease its health factor, `discount = max discount`.
    /// Otherwise, it may be profitable for the liquidator to liquidate in multiple times: as it will decrease
    /// the HF and therefore increase the discount between each time
    function setUint64(uint64 param, bytes32 what) external onlyGovernorOrGuardian {
        if (what == "CF") {
            if (param > liquidationSurcharge) revert TooHighParameterValue();
            collateralFactor = param;
        } else if (what == "THF") {
            if (param < BASE_PARAMS) revert TooSmallParameterValue();
            targetHealthFactor = param;
        } else if (what == "BF") {
            if (param > BASE_PARAMS) revert TooHighParameterValue();
            borrowFee = param;
        } else if (what == "RF") {
            // As liquidation surcharge is stored as `1-fee` and as we need `repayFee` to be smaller
            // then the liquidation surcharge, then we need to have:
            // `liquidationSurcharge <= BASE_PARAMS - repayFee` and as such `liquidationSurcharge + repayFee <= BASE_PARAMS`
            if (param + liquidationSurcharge > BASE_PARAMS) revert TooHighParameterValue();
            repayFee = param;
        } else if (what == "IR") {
            _accrue();
            interestRate = param;
        } else if (what == "LS") {
            if (collateralFactor > param || param + repayFee > BASE_PARAMS) revert InvalidParameterValue();
            liquidationSurcharge = param;
        } else if (what == "MLD") {
            if (param > BASE_PARAMS) revert TooHighParameterValue();
            maxLiquidationDiscount = param;
        } else {
            revert InvalidParameterType();
        }
        emit FiledUint64(param, what);
    }

    
    
    
    function setDebtCeiling(uint256 _debtCeiling) external onlyGovernorOrGuardian {
        debtCeiling = _debtCeiling;
        emit DebtCeilingUpdated(_debtCeiling);
    }

    
    function setLiquidationBoostParameters(
        address _veBoostProxy,
        uint256[] memory xBoost,
        uint256[] memory yBoost
    ) external virtual onlyGovernorOrGuardian {
        if (yBoost[0] == 0) revert InvalidSetOfParameters();
        yLiquidationBoost = yBoost;
        emit LiquidationBoostParametersUpdated(_veBoostProxy, xBoost, yBoost);
    }

    
    function togglePause() external onlyGovernorOrGuardian {
        paused = !paused;
    }

    
    function setBaseURI(string memory baseURI_) external onlyGovernorOrGuardian {
        _baseURI = baseURI_;
    }

    
    
    
    /// for all addresses
    function toggleWhitelist(address target) external onlyGovernor {
        if (target != address(0)) {
            isWhitelisted[target] = 1 - isWhitelisted[target];
        } else {
            whitelistingActivated = !whitelistingActivated;
        }
    }

    
    
    function setOracle(address _oracle) external onlyGovernor {
        if (IOracle(_oracle).treasury() != treasury) revert InvalidTreasury();
        oracle = IOracle(_oracle);
    }

    
    
    
    
    function setDusts(uint256 _dust, uint256 dustCollateral_) external onlyGovernor {
        dust = _dust;
        _dustCollateral = dustCollateral_;
    }

    
    function setTreasury(address _treasury) external onlyTreasury {
        treasury = ITreasury(_treasury);
        // This function makes sure to propagate the change to the associated contract
        // even though a single oracle contract could be used in different places
        oracle.setTreasury(_treasury);
    }

    // ============================= VIRTUAL FUNCTIONS =============================

    
    
    function _computeLiquidationBoost(address) internal view virtual returns (uint256) {
        return yLiquidationBoost[0];
    }

    
    
    
    
    
    function _checkpointCollateral(
        uint256 vaultID,
        uint256 amount,
        bool add
    ) internal virtual {}
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




interface IVaultManager is IVaultManagerFunctions, IVaultManagerStorage, IERC721Metadata {
    function isApprovedOrOwner(address spender, uint256 vaultID) external view returns (bool);
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

pragma solidity ^0.8.12;






contract VaultManagerLiquidationBoost is VaultManager {
    using SafeERC20 for IERC20;
    using Address for address;

    // =================================== SETTER ==================================

    
    
    
    
    
    /// When boost is enabled, `xBoost` and `yBoost` should have a length of 2, but if they have a
    /// higher length contract will still work as expected. Contract will also work as expected if their
    /// length differ
    /// When boost is disabled, `_veBoostProxy` needs to be zero address and `yBoost[0]` is the base boost
    function setLiquidationBoostParameters(
        address _veBoostProxy,
        uint256[] memory xBoost,
        uint256[] memory yBoost
    ) external override onlyGovernorOrGuardian {
        if (
            (xBoost.length != yBoost.length) ||
            (yBoost[0] == 0) ||
            ((_veBoostProxy != address(0)) && (xBoost[1] <= xBoost[0] || yBoost[1] < yBoost[0]))
        ) revert InvalidSetOfParameters();
        veBoostProxy = IVeBoostProxy(_veBoostProxy);
        xLiquidationBoost = xBoost;
        yLiquidationBoost = yBoost;
        emit LiquidationBoostParametersUpdated(_veBoostProxy, xBoost, yBoost);
    }

    // ======================== OVERRIDEN VIRTUAL FUNCTIONS ========================

    
    function _computeLiquidationBoost(address liquidator) internal view override returns (uint256) {
        if (address(veBoostProxy) == address(0)) {
            return yLiquidationBoost[0];
        } else {
            uint256 adjustedBalance = veBoostProxy.adjusted_balance_of(liquidator);
            if (adjustedBalance >= xLiquidationBoost[1]) return yLiquidationBoost[1];
            else if (adjustedBalance <= xLiquidationBoost[0]) return yLiquidationBoost[0];
            else
                return
                    yLiquidationBoost[0] +
                    ((yLiquidationBoost[1] - yLiquidationBoost[0]) * (adjustedBalance - xLiquidationBoost[0])) /
                    (xLiquidationBoost[1] - xLiquidationBoost[0]);
        }
    }
}

// 
pragma solidity ^0.8.12;




interface IERC1271 {
    
    
    /// MUST NOT modify state (using STATICCALL for solc < 0.5, view modifier for solc > 0.5).
    /// MUST allow external calls.
    
    
    
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
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
interface IERC20PermitUpgradeable {
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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

pragma solidity ^0.8.12;







/// of this module or of the first module of the Angle Protocol
interface IAgToken is IERC20Upgradeable {
    // ======================= Minter Role Only Functions ===========================

    
    
    
    
    /// associated to this stablecoin as well as the flash loan module (if activated) and potentially contracts
    /// whitelisted by governance
    function mint(address account, uint256 amount) external;

    
    
    
    
    
    /// to do so by a `sender` address willing to burn tokens from another `burner` address
    
    function burnFrom(
        uint256 amount,
        address burner,
        address sender
    ) external;

    
    
    
    
    /// requested to do so by an address willing to burn tokens from its address
    function burnSelf(uint256 amount, address burner) external;

    // ========================= Treasury Only Functions ===========================

    
    
    
    function addMinter(address minter) external;

    
    
    
    function removeMinter(address minter) external;

    
    
    function setTreasury(address _treasury) external;

    // ========================= External functions ================================

    
    
    
    function isMinter(address minter) external view returns (bool);
}

// 

pragma solidity ^0.8.12;







/// of this module
interface IOracle {
    
    
    /// of the out currency
    
    /// value is 10**18
    function read() external view returns (uint256);

    
    
    
    /// this function after being requested to do so by a `treasury` contract
    
    /// to the `oracle` contract and as such we may need governors to be able to call this function as well
    function setTreasury(address _treasury) external;

    
    function treasury() external view returns (ITreasury treasury);
}

// 

pragma solidity ^0.8.12;







/// Angle
interface ISwapper {
    
    
    
    
    
    
    /// to the call to this function
    
    function swap(
        IERC20 inToken,
        IERC20 outToken,
        address outTokenRecipient,
        uint256 outTokenOwed,
        uint256 inTokenObtained,
        bytes calldata data
    ) external;
}

// 

pragma solidity ^0.8.12;









/// of this module
interface ITreasury {
    
    function stablecoin() external view returns (IAgToken);

    
    
    
    
    function isGovernor(address admin) external view returns (bool);

    
    
    
    
    /// queries the `CoreBorrow` contract
    function isGovernorOrGuardian(address admin) external view returns (bool);

    
    /// as a `VaultManager`
    
    
    function isVaultManager(address _vaultManager) external view returns (bool);

    
    
    
    /// it to the new module
    function setFlashLoanModule(address _flashLoanModule) external;
}




interface IVaultManagerListing is IVaultManager {
    
    
    function getUserCollateral(address user) external view returns (uint256);
}

// 

pragma solidity ^0.8.12;





/// of this module

interface IVeBoostProxy {
    
    //solhint-disable-next-line
    function adjusted_balance_of(address) external view returns (uint256);
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

pragma solidity ^0.8.12;





/// of this module
interface ICoreBorrow {
    
    /// module initialized on it
    
    
    function isFlashLoanerTreasury(address treasury) external view returns (bool);

    
    
    
    function isGovernor(address admin) external view returns (bool);

    
    
    
    
    /// role by calling the `addGovernor` function
    function isGovernorOrGuardian(address admin) external view returns (bool);
}

// 

pragma solidity ^0.8.12;








/// of this module
interface IFlashAngle {
    
    function core() external view returns (ICoreBorrow);

    
    
    
    
    function accrueInterestToTreasury(IAgToken stablecoin) external returns (uint256 balance);

    
    
    
    function addStablecoinSupport(address _treasury) external;

    
    
    
    function removeStablecoinSupport(address _treasury) external;

    
    
    
    function setCore(address _core) external;
}
