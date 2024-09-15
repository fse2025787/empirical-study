// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

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
        bool isTopLevelCall = _setInitializedVersion(1);
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
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;







/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;





/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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

// 

pragma solidity >=0.8.13;



interface IIndexRouter {
    struct MintParams {
        address index;
        uint amountInBase;
        address recipient;
    }

    struct MintSwapParams {
        address index;
        address inputToken;
        uint amountInInputToken;
        address recipient;
        MintQuoteParams[] quotes;
    }

    struct MintSwapValueParams {
        address index;
        address recipient;
        MintQuoteParams[] quotes;
    }

    struct BurnParams {
        address index;
        uint amount;
        address recipient;
    }

    struct BurnSwapParams {
        address index;
        uint amount;
        address outputAsset;
        address recipient;
        BurnQuoteParams[] quotes;
    }

    struct MintQuoteParams {
        address asset;
        address swapTarget;
        uint buyAssetMinAmount;
        bytes assetQuote;
    }

    struct BurnQuoteParams {
        address swapTarget;
        uint buyAssetMinAmount;
        bytes assetQuote;
    }

    
    receive() external payable;

    
    
    
    function initialize(address _WETH, address _registry) external;

    
    
    
    function mint(MintParams calldata _params) external returns (uint _amount);

    
    
    
    function mintSwap(MintSwapParams calldata _params) external returns (uint _amount);

    
    
    
    
    
    
    
    function mintSwapWithPermit(
        MintSwapParams calldata _params,
        uint _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external returns (uint _amount);

    
    
    
    function mintSwapValue(MintSwapValueParams calldata _params) external payable returns (uint _amount);

    
    
    function burn(BurnParams calldata _params) external;

    
    
    
    function burnWithAmounts(BurnParams calldata _params) external returns (uint[] memory _amounts);

    
    
    
    
    
    
    function burnWithPermit(
        BurnParams calldata _params,
        uint _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    
    
    function burnSwap(BurnSwapParams calldata _params) external returns (uint _amount);

    
    
    
    
    
    
    function burnSwapWithPermit(
        BurnSwapParams calldata _params,
        uint _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external returns (uint _amount);

    
    
    function burnSwapValue(BurnSwapParams calldata _params) external returns (uint _amount);

    
    
    
    
    
    
    function burnSwapValueWithPermit(
        BurnSwapParams calldata _params,
        uint _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external returns (uint _amount);

    
    
    function registry() external view returns (address);

    
    
    function WETH() external view returns (address);

    
    
    
    function mintSwapIndexAmount(MintSwapParams calldata _params) external view returns (uint _amount);

    
    
    
    
    function burnTokensAmount(address _index, uint _amount) external view returns (uint[] memory _amounts);
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

// 

pragma solidity >=0.8.13;



interface IIndexLayout {
    
    
    function factory() external view returns (address);

    
    
    function vTokenFactory() external view returns (address);

    
    
    function registry() external view returns (address);
}

// 

pragma solidity >=0.8.13;



interface IAnatomyUpdater {
    event UpdateAnatomy(address asset, uint8 weight);
    event AssetRemoved(address asset);
}

// 

pragma solidity >=0.8.13;



interface IPriceOracle {
    
    
    function refreshedAssetPerBaseInUQ(address _asset) external returns (uint);

    
    
    function lastAssetPerBaseInUQ(address _asset) external view returns (uint);
}// 

pragma solidity 0.8.13;
























contract IndexRouter is IIndexRouter, UUPSUpgradeable, ReentrancyGuardUpgradeable {
    using FullMath for uint;
    using SafeERC20 for IERC20;
    using IndexLibrary for uint;
    using ERC165Checker for address;

    struct MintDetails {
        uint minAmountInBase;
        uint[] amountsInBase;
        uint[] inputAmountInToken;
        IvTokenFactory vTokenFactory;
    }

    
    uint internal constant MIN_SWAP_AMOUNT = 1_000_000;

    
    bytes32 internal constant INDEX_ROLE = keccak256("INDEX_ROLE");
    
    bytes32 internal constant ASSET_ROLE = keccak256("ASSET_ROLE");
    
    bytes32 internal constant EXCHANGE_ADMIN_ROLE = keccak256("EXCHANGE_ADMIN_ROLE");
    
    bytes32 internal constant SKIPPED_ASSET_ROLE = keccak256("SKIPPED_ASSET_ROLE");
    
    bytes32 internal constant EXCHANGE_TARGET_ROLE = keccak256("EXCHANGE_TARGET_ROLE");

    
    address public override WETH;
    
    address public override registry;

    
    
    modifier isValidIndex(address _index) {
        require(IAccessControl(registry).hasRole(INDEX_ROLE, _index), "IndexRouter: INVALID");
        _;
    }

    
    constructor() initializer {}

    
    function initialize(address _WETH, address _registry) external override initializer {
        require(_WETH != address(0), "IndexRouter: ZERO");

        bytes4[] memory interfaceIds = new bytes4[](2);
        interfaceIds[0] = type(IAccessControl).interfaceId;
        interfaceIds[1] = type(IIndexRegistry).interfaceId;
        require(_registry.supportsAllInterfaces(interfaceIds), "IndexRouter: INTERFACE");

        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        WETH = _WETH;
        registry = _registry;
    }

    
    
    receive() external payable override {
        require(msg.sender == WETH);
    }

    
    function mintSwapIndexAmount(MintSwapParams calldata _params) external view override returns (uint _amount) {
        (address[] memory _assets, uint8[] memory _weights) = IIndex(_params.index).anatomy();

        uint assetBalanceInBase;
        uint minAmountInBase = type(uint).max;

        for (uint i; i < _weights.length; ) {
            if (_weights[i] != 0) {
                uint _amount = _params.quotes[i].buyAssetMinAmount;

                uint assetPerBaseInUQ = IPhuturePriceOracle(IIndexRegistry(registry).priceOracle())
                    .lastAssetPerBaseInUQ(_assets[i]);
                {
                    uint _minAmountInBase = _amount.mulDiv(
                        FixedPoint112.Q112 * IndexLibrary.MAX_WEIGHT,
                        assetPerBaseInUQ * _weights[i]
                    );
                    if (_minAmountInBase < minAmountInBase) {
                        minAmountInBase = _minAmountInBase;
                    }
                }

                IvToken vToken = IvToken(IvTokenFactory(IIndex(_params.index).vTokenFactory()).vTokenOf(_assets[i]));
                if (address(vToken) != address(0)) {
                    assetBalanceInBase += vToken.lastAssetBalanceOf(_params.index).mulDiv(
                        FixedPoint112.Q112,
                        assetPerBaseInUQ
                    );
                }
            }

            unchecked {
                i = i + 1;
            }
        }

        IPhuturePriceOracle priceOracle = IPhuturePriceOracle(IIndexRegistry(registry).priceOracle());
        {
            address[] memory inactiveAssets = IIndex(_params.index).inactiveAnatomy();

            uint inactiveAssetsCount = inactiveAssets.length;
            for (uint i; i < inactiveAssetsCount; ) {
                address inactiveAsset = inactiveAssets[i];
                if (!IAccessControl(registry).hasRole(SKIPPED_ASSET_ROLE, inactiveAsset)) {
                    uint balanceInAsset = IvToken(
                        IvTokenFactory((IIndex(_params.index).vTokenFactory())).vTokenOf(inactiveAsset)
                    ).lastAssetBalanceOf(_params.index);

                    assetBalanceInBase += balanceInAsset.mulDiv(
                        FixedPoint112.Q112,
                        priceOracle.lastAssetPerBaseInUQ(inactiveAsset)
                    );
                }
                unchecked {
                    i = i + 1;
                }
            }
        }

        assert(minAmountInBase != type(uint).max);

        uint8 _indexDecimals = IERC20Metadata(_params.index).decimals();
        if (IERC20(_params.index).totalSupply() != 0) {
            _amount =
                (priceOracle.convertToIndex(minAmountInBase, _indexDecimals) * IERC20(_params.index).totalSupply()) /
                priceOracle.convertToIndex(assetBalanceInBase, _indexDecimals);
        } else {
            _amount = priceOracle.convertToIndex(minAmountInBase, _indexDecimals) - IndexLibrary.INITIAL_QUANTITY;
        }

        uint256 fee = (_amount * IFeePool(IIndexRegistry(registry).feePool()).mintingFeeInBPOf(_params.index)) /
            BP.DECIMAL_FACTOR;
        _amount -= fee;
    }

    
    function burnTokensAmount(address _index, uint _amount) external view override returns (uint[] memory _amounts) {
        (address[] memory _assets, uint8[] memory _weights) = IIndex(_index).anatomy();
        address[] memory inactiveAssets = IIndex(_index).inactiveAnatomy();
        _amounts = new uint[](_weights.length + inactiveAssets.length);

        uint assetsCount = _assets.length;

        bool containsBlacklistedAssets;
        for (uint i; i < assetsCount; ) {
            if (!IAccessControl(registry).hasRole(ASSET_ROLE, _assets[i])) {
                containsBlacklistedAssets = true;
                break;
            }

            unchecked {
                i = i + 1;
            }
        }

        if (!containsBlacklistedAssets) {
            _amount -=
                (_amount * IFeePool(IIndexRegistry(registry).feePool()).burningFeeInBPOf(_index)) /
                BP.DECIMAL_FACTOR;
        }

        uint totalAssetsCount = assetsCount + inactiveAssets.length;
        for (uint i; i < totalAssetsCount; ) {
            address asset = i < assetsCount ? _assets[i] : inactiveAssets[i - assetsCount];
            if (!(containsBlacklistedAssets && IAccessControl(registry).hasRole(SKIPPED_ASSET_ROLE, asset))) {
                uint indexAssetBalance = IvToken(IvTokenFactory(IIndex(_index).vTokenFactory()).vTokenOf(asset))
                    .balanceOf(_index);

                _amounts[i] = (_amount * indexAssetBalance) / IERC20(_index).totalSupply();
            }

            unchecked {
                i = i + 1;
            }
        }
    }

    
    function mint(MintParams calldata _params)
        external
        override
        nonReentrant
        isValidIndex(_params.index)
        returns (uint)
    {
        IIndex index = IIndex(_params.index);
        (address[] memory _assets, uint8[] memory _weights) = index.anatomy();

        IvTokenFactory vTokenFactory = IvTokenFactory(index.vTokenFactory());
        IPriceOracle oracle = IPriceOracle(IIndexRegistry(registry).priceOracle());

        uint assetsCount = _assets.length;
        for (uint i; i < assetsCount; ) {
            if (_weights[i] > 0) {
                address asset = _assets[i];
                IERC20(asset).safeTransferFrom(
                    msg.sender,
                    vTokenFactory.createdVTokenOf(_assets[i]),
                    oracle.refreshedAssetPerBaseInUQ(asset).amountInAsset(_weights[i], _params.amountInBase)
                );
            }

            unchecked {
                i = i + 1;
            }
        }

        uint balance = IERC20(_params.index).balanceOf(_params.recipient);
        index.mint(_params.recipient);

        return IERC20(_params.index).balanceOf(_params.recipient) - balance;
    }

    
    function mintSwap(MintSwapParams calldata _params)
        public
        override
        nonReentrant
        isValidIndex(_params.index)
        returns (uint)
    {
        IERC20(_params.inputToken).safeTransferFrom(msg.sender, address(this), _params.amountInInputToken);
        _mint(_params.index, _params.inputToken, _params.amountInInputToken, _params.quotes);

        uint balance = IERC20(_params.index).balanceOf(_params.recipient);
        IIndex(_params.index).mint(_params.recipient);

        return IERC20(_params.index).balanceOf(_params.recipient) - balance;
    }

    
    function mintSwapWithPermit(
        MintSwapParams calldata _params,
        uint _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override returns (uint) {
        IERC20Permit(_params.inputToken).permit(
            msg.sender,
            address(this),
            _params.amountInInputToken,
            _deadline,
            _v,
            _r,
            _s
        );

        return mintSwap(_params);
    }

    
    function mintSwapValue(MintSwapValueParams calldata _params)
        external
        payable
        override
        nonReentrant
        isValidIndex(_params.index)
        returns (uint)
    {
        IWETH(WETH).deposit{ value: msg.value }();
        _mint(_params.index, WETH, msg.value, _params.quotes);

        uint balance = IERC20(_params.index).balanceOf(_params.recipient);
        IIndex(_params.index).mint(_params.recipient);

        return IERC20(_params.index).balanceOf(_params.recipient) - balance;
    }

    
    function burn(BurnParams calldata _params) public override nonReentrant isValidIndex(_params.index) {
        IERC20(_params.index).safeTransferFrom(msg.sender, _params.index, _params.amount);
        IIndex(_params.index).burn(_params.recipient);
    }

    
    function burnWithAmounts(BurnParams calldata _params)
        external
        override
        nonReentrant
        isValidIndex(_params.index)
        returns (uint[] memory _amounts)
    {
        IERC20(_params.index).safeTransferFrom(msg.sender, _params.index, _params.amount);

        (address[] memory _assets, ) = IIndex(_params.index).anatomy();
        uint assetsCount = _assets.length;
        address[] memory inactiveAssets = IIndex(_params.index).inactiveAnatomy();
        uint totalAssetsCount = assetsCount + inactiveAssets.length;
        uint[] memory balancesBefore = new uint[](totalAssetsCount);
        for (uint i; i < totalAssetsCount; ++i) {
            address asset = i < assetsCount ? _assets[i] : inactiveAssets[i - assetsCount];
            balancesBefore[i] = IERC20(asset).balanceOf(_params.recipient);
        }

        IIndex(_params.index).burn(_params.recipient);

        _amounts = new uint[](totalAssetsCount);
        for (uint i; i < totalAssetsCount; ++i) {
            address asset = i < assetsCount ? _assets[i] : inactiveAssets[i - assetsCount];
            _amounts[i] = IERC20(asset).balanceOf(_params.recipient) - balancesBefore[i];
        }
    }

    
    function burnSwap(BurnSwapParams calldata _params)
        public
        override
        nonReentrant
        isValidIndex(_params.index)
        returns (uint)
    {
        _burn(_params);

        uint balance = IERC20(_params.outputAsset).balanceOf(_params.recipient);
        IERC20(_params.outputAsset).safeTransfer(
            _params.recipient,
            IERC20(_params.outputAsset).balanceOf(address(this))
        );

        return IERC20(_params.outputAsset).balanceOf(_params.recipient) - balance;
    }

    
    function burnSwapValue(BurnSwapParams calldata _params)
        public
        override
        nonReentrant
        isValidIndex(_params.index)
        returns (uint wethBalance)
    {
        require(_params.outputAsset == WETH, "IndexRouter: OUTPUT_ASSET");
        _burn(_params);
        wethBalance = IERC20(WETH).balanceOf(address(this));
        IWETH(WETH).withdraw(wethBalance);
        TransferHelper.safeTransferETH(_params.recipient, wethBalance);
    }

    
    function burnWithPermit(
        BurnParams calldata _params,
        uint _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override {
        IERC20Permit(_params.index).permit(msg.sender, address(this), _params.amount, _deadline, _v, _r, _s);
        burn(_params);
    }

    
    function burnSwapWithPermit(
        BurnSwapParams calldata _params,
        uint _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override returns (uint) {
        IERC20Permit(_params.index).permit(msg.sender, address(this), _params.amount, _deadline, _v, _r, _s);
        return burnSwap(_params);
    }

    
    function burnSwapValueWithPermit(
        BurnSwapParams calldata _params,
        uint _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override returns (uint) {
        IERC20Permit(_params.index).permit(msg.sender, address(this), _params.amount, _deadline, _v, _r, _s);
        return burnSwapValue(_params);
    }

    
    
    
    
    
    function _mint(
        address _index,
        address _inputToken,
        uint _amountInInputToken,
        MintQuoteParams[] calldata _quotes
    ) internal {
        uint quotesCount = _quotes.length;
        IvTokenFactory vTokenFactory = IvTokenFactory(IIndex(_index).vTokenFactory());
        uint _inputBalanceBefore = IERC20(_inputToken).balanceOf(address(this));
        for (uint i; i < quotesCount; i++) {
            address asset = _quotes[i].asset;

            // if one of the assets is inputToken we transfer it directly to the vault
            if (asset == _inputToken) {
                IERC20(_inputToken).safeTransfer(
                    vTokenFactory.createdVTokenOf(_inputToken),
                    _quotes[i].buyAssetMinAmount
                );
                continue;
            }
            address swapTarget = _quotes[i].swapTarget;
            require(IAccessControl(registry).hasRole(EXCHANGE_TARGET_ROLE, swapTarget), "IndexRouter: INVALID_TARGET");
            _safeApprove(_inputToken, swapTarget, _amountInInputToken);
            // execute the swap with the quote for the asset
            _fillQuote(swapTarget, _quotes[i].assetQuote);
            uint assetBalanceAfter = IERC20(asset).balanceOf(address(this));
            require(assetBalanceAfter >= _quotes[i].buyAssetMinAmount, "IndexRouter: UNDERBOUGHT_ASSET");
            IERC20(asset).safeTransfer(vTokenFactory.createdVTokenOf(asset), assetBalanceAfter);
        }
        require(
            _inputBalanceBefore - IERC20(_inputToken).balanceOf(address(this)) == _amountInInputToken,
            "IndexRouter: INVALID_INPUT_AMOUNT"
        );
    }

    
    
    function _burn(BurnSwapParams calldata _params) internal {
        IERC20(_params.index).safeTransferFrom(msg.sender, _params.index, _params.amount);
        IIndex(_params.index).burn(address(this));

        (address[] memory assets, ) = IIndex(_params.index).anatomy();
        address[] memory inactiveAssets = IIndex(_params.index).inactiveAnatomy();

        uint assetsCount = assets.length;
        uint totalAssetsCount = assetsCount + inactiveAssets.length;
        IPriceOracle priceOracle = IPhuturePriceOracle(IIndexRegistry(registry).priceOracle());
        for (uint i; i < totalAssetsCount; ) {
            IERC20 inputAsset = IERC20(i < assetsCount ? assets[i] : inactiveAssets[i - assetsCount]);
            uint inputAssetBalanceBefore = inputAsset.balanceOf(address(this));
            // if asset is input asset no need to swap => (address(inputAsset) != _params.outputAsset)
            if (inputAssetBalanceBefore > 0 && address(inputAsset) != _params.outputAsset) {
                // if the amount of asset is less than minimum directly transfer to the user
                if (
                    inputAssetBalanceBefore.mulDiv(
                        FixedPoint112.Q112,
                        priceOracle.refreshedAssetPerBaseInUQ(address(inputAsset))
                    ) < MIN_SWAP_AMOUNT
                ) {
                    inputAsset.safeTransfer(_params.recipient, inputAssetBalanceBefore);
                }
                // otherwise exchange the asset for the desired output asset
                else {
                    address swapTarget = _params.quotes[i].swapTarget;
                    require(
                        IAccessControl(registry).hasRole(EXCHANGE_TARGET_ROLE, swapTarget),
                        "IndexRouter: INVALID_TARGET"
                    );
                    uint outputAssetBalanceBefore = IERC20(_params.outputAsset).balanceOf(address(this));

                    _safeApprove(address(inputAsset), swapTarget, inputAssetBalanceBefore);
                    _fillQuote(swapTarget, _params.quotes[i].assetQuote);

                    // checks if all input asset was exchanged and output asset generated from the swap is greater than minOutputAmount desired.
                    // it is important to estimate correctly the inputAmount for each asset for the index amount to burn,
                    // otherwise the transaction will revert due to over or under estimation.
                    // this ensures if all swaps are successful there is no leftover assets in indexRouter's ownership.
                    require(
                        IERC20(_params.outputAsset).balanceOf(address(this)) - outputAssetBalanceBefore >=
                            _params.quotes[i].buyAssetMinAmount,
                        "IndexRouter: INVALID_SWAP"
                    );
                }
            }

            unchecked {
                i = i + 1;
            }
        }
    }

    
    
    
    function _fillQuote(address _swapTarget, bytes memory _quote) internal {
        (bool success, bytes memory returnData) = _swapTarget.call(_quote);
        if (!success) {
            if (returnData.length == 0) {
                revert("IndexRouter: INVALID_SWAP");
            } else {
                assembly {
                    revert(add(32, returnData), mload(returnData))
                }
            }
        }
    }

    
    
    
    
    function _safeApprove(
        address _token,
        address _spender,
        uint _requiredAllowance
    ) internal {
        uint allowance = IERC20(_token).allowance(address(this), _spender);
        if (allowance < _requiredAllowance) {
            IERC20(_token).safeIncreaseAllowance(_spender, type(uint256).max - allowance);
        }
    }

    
    function _authorizeUpgrade(address _newImpl) internal view override {
        require(IAccessControl(registry).hasRole(EXCHANGE_ADMIN_ROLE, msg.sender), "IndexRouter: FORBIDDEN");
    }

    uint256[44] private __gap;
}

// 
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;



/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
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

pragma solidity 0.8.13;



library BP {
    
    
    uint16 constant DECIMAL_FACTOR = 10_000;
}

// 

pragma solidity 0.8.13;






library IndexLibrary {
    using FullMath for uint;

    
    uint constant INITIAL_QUANTITY = 10000;

    
    uint8 constant MAX_WEIGHT = type(uint8).max;

    
    
    
    
    
    function amountInAsset(
        uint _assetPerBaseInUQ,
        uint8 _weight,
        uint _amountInBase
    ) internal pure returns (uint) {
        require(_assetPerBaseInUQ != 0, "IndexLibrary: ORACLE");

        return ((_amountInBase * _weight) / MAX_WEIGHT).mulDiv(_assetPerBaseInUQ, FixedPoint112.Q112);
    }
}

// 

pragma solidity >=0.8.13;






interface IIndex is IIndexLayout, IAnatomyUpdater {
    
    
    function mint(address _recipient) external;

    
    
    function burn(address _recipient) external;

    
    
    
    function anatomy() external view returns (address[] memory _assets, uint8[] memory _weights);

    
    
    function inactiveAnatomy() external view returns (address[] memory);
}

// 

pragma solidity >=0.8.13;



interface IvToken {
    struct AssetData {
        uint maxShares;
        uint amountInAsset;
    }

    event UpdateDeposit(address indexed account, uint depositedAmount);
    event SetVaultController(address vaultController);
    event VTokenTransfer(address indexed from, address indexed to, uint amount);

    
    
    
    function initialize(address _asset, address _registry) external;

    
    
    function setController(address _vaultController) external;

    
    function deposit() external;

    
    function withdraw() external;

    
    
    
    
    function transferFrom(
        address _from,
        address _to,
        uint _shares
    ) external;

    
    
    
    
    function transferAsset(address _recipient, uint _amount) external;

    
    
    function mint() external returns (uint shares);

    
    
    
    function burn(address _recipient) external returns (uint amount);

    
    
    
    function transfer(address _recipient, uint _amount) external;

    
    function sync() external;

    
    
    
    function mintFor(address _recipient) external returns (uint);

    
    
    
    function burnFor(address _recipient) external returns (uint);

    
    
    function virtualTotalAssetSupply() external view returns (uint);

    
    
    function totalAssetSupply() external view returns (uint);

    
    
    function deposited() external view returns (uint);

    
    
    
    function mintableShares(uint _amount) external view returns (uint);

    
    
    function assetDataOf(address _account, uint _shares) external view returns (AssetData memory);

    
    
    
    function assetBalanceForShares(uint _shares) external view returns (uint);

    
    
    
    function assetBalanceOf(address _account) external view returns (uint);

    
    
    
    function lastAssetBalanceOf(address _account) external view returns (uint);

    
    
    function lastAssetBalance() external view returns (uint);

    
    
    function totalSupply() external view returns (uint);

    
    
    
    function balanceOf(address _account) external view returns (uint);

    
    
    
    
    
    function shareChange(address _account, uint _amountInAsset) external view returns (uint newShares, uint oldShares);

    
    
    function vaultController() external view returns (address);

    
    
    function asset() external view returns (address);

    
    
    function registry() external view returns (address);

    
    
    function currentDepositedPercentageInBP() external view returns (uint);
}

// 

pragma solidity >=0.8.13;



interface IFeePool {
    struct MintBurnInfo {
        address recipient;
        uint share;
    }

    event Mint(address indexed index, address indexed recipient, uint share);
    event Burn(address indexed index, address indexed recipient, uint share);
    event SetMintingFeeInBP(address indexed account, address indexed index, uint16 mintingFeeInBP);
    event SetBurningFeeInBP(address indexed account, address indexed index, uint16 burningFeeInPB);
    event SetAUMScaledPerSecondsRate(address indexed account, address indexed index, uint AUMScaledPerSecondsRate);

    event Withdraw(address indexed index, address indexed recipient, uint amount);

    
    
    function initialize(address _registry) external;

    
    
    
    
    
    
    function initializeIndex(
        address _index,
        uint16 _mintingFeeInBP,
        uint16 _burningFeeInBP,
        uint _AUMScaledPerSecondsRate,
        MintBurnInfo[] calldata _mintInfo
    ) external;

    
    
    
    function mint(address _index, MintBurnInfo calldata _mintInfo) external;

    
    
    
    function burn(address _index, MintBurnInfo calldata _burnInfo) external;

    
    
    
    function mintMultiple(address _index, MintBurnInfo[] calldata _mintInfo) external;

    
    
    
    function burnMultiple(address _index, MintBurnInfo[] calldata _burnInfo) external;

    
    
    
    function setMintingFeeInBP(address _index, uint16 _mintingFeeInBP) external;

    
    
    
    function setBurningFeeInBP(address _index, uint16 _burningFeeInBP) external;

    
    
    
    function setAUMScaledPerSecondsRate(address _index, uint _AUMScaledPerSecondsRate) external;

    
    
    function withdraw(address _index) external;

    
    
    
    function withdrawPlatformFeeOf(address _index, address _recipient) external;

    
    
    function totalSharesOf(address _index) external view returns (uint);

    
    
    function shareOf(address _index, address _account) external view returns (uint);

    
    
    function mintingFeeInBPOf(address _index) external view returns (uint16);

    
    
    function burningFeeInBPOf(address _index) external view returns (uint16);

    
    
    function AUMScaledPerSecondsRateOf(address _index) external view returns (uint);

    
    
    
    function withdrawableAmountOf(address _index, address _account) external view returns (uint);
}

// 

pragma solidity >=0.8.13;



interface IvTokenFactory {
    event VTokenCreated(address vToken, address asset);

    
    
    
    function initialize(address _registry, address _vTokenImpl) external;

    
    
    function upgradeBeaconTo(address _vTokenImpl) external;

    
    
    function createVToken(address _asset) external;

    
    
    function createdVTokenOf(address _asset) external returns (address);

    
    
    function beacon() external view returns (address);

    
    
    
    function vTokenOf(address _asset) external view returns (address);
}

// 

pragma solidity >=0.8.13;





interface IIndexRegistry {
    event SetIndexLogic(address indexed account, address indexLogic);
    event SetMaxComponents(address indexed account, uint maxComponents);
    event UpdateAsset(address indexed asset, uint marketCap);
    event SetOrderer(address indexed account, address orderer);
    event SetFeePool(address indexed account, address feePool);
    event SetPriceOracle(address indexed account, address priceOracle);

    
    
    
    function initialize(address _indexLogic, uint _maxComponents) external;

    
    
    function setMaxComponents(uint _maxComponents) external;

    
    
    function indexLogic() external returns (address);

    
    
    function setIndexLogic(address _indexLogic) external;

    
    
    
    function setRoleAdmin(bytes32 _role, bytes32 _adminRole) external;

    
    
    
    function registerIndex(address _index, IIndexFactory.NameDetails calldata _nameDetails) external;

    
    
    
    function addAsset(address _asset, uint _marketCap) external;

    
    
    function removeAsset(address _asset) external;

    
    
    
    function updateAssetMarketCap(address _asset, uint _marketCap) external;

    
    
    function setPriceOracle(address _priceOracle) external;

    
    
    function setOrderer(address _orderer) external;

    
    
    function setFeePool(address _feePool) external;

    
    
    function maxComponents() external view returns (uint);

    
    
    function marketCapOf(address _asset) external view returns (uint);

    
    
    
    
    function marketCapsOf(address[] calldata _assets)
        external
        view
        returns (uint[] memory _marketCaps, uint _totalMarketCap);

    
    
    function totalMarketCap() external view returns (uint);

    
    
    function priceOracle() external view returns (address);

    
    
    function orderer() external view returns (address);

    
    
    function feePool() external view returns (address);
}

// 

pragma solidity >=0.8.13;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;
}

// 

pragma solidity >=0.8.13;





interface IPhuturePriceOracle is IPriceOracle {
    
    
    
    function initialize(address _registry, address _base) external;

    
    
    
    function setOracleOf(address _asset, address _oracle) external;

    
    
    function removeOracleOf(address _asset) external;

    
    
    
    
    function convertToIndex(uint _baseAmount, uint8 _indexDecimals) external view returns (uint);

    
    
    
    function containsOracleOf(address _asset) external view returns (bool);

    
    
    
    function priceOracleOf(address _asset) external view returns (address);
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// 
pragma solidity 0.8.13;




library FullMath {
    
    
    
    
    
    
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = a * b
            // Compute the product mod 2**256 and mod 2**256 - 1
            // then use the Chinese Remainder Theorem to reconstruct
            // the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2**256 + prod0
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division
            if (prod1 == 0) {
                require(denominator > 0);
                assembly {
                    result := div(prod0, denominator)
                }
                return result;
            }

            // Make sure the result is less than 2**256.
            // Also prevents denominator == 0
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0]
            // Compute remainder using mulmod
            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
            }
            // Subtract 256 bit number from 512 bit number
            assembly {
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator
            // Compute largest power of two divisor of denominator.
            // Always >= 1.
            uint256 twos = (~denominator + 1) & denominator;
            // Divide denominator by power of two
            assembly {
                denominator := div(denominator, twos)
            }

            // Divide [prod1 prod0] by the factors of two
            assembly {
                prod0 := div(prod0, twos)
            }
            // Shift in bits from prod1 into prod0. For this we need
            // to flip `twos` such that it is 2**256 / twos.
            // If twos is zero, then it becomes one
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            // Invert denominator mod 2**256
            // Now that denominator is an odd number, it has an inverse
            // modulo 2**256 such that denominator * inv = 1 mod 2**256.
            // Compute the inverse by starting with a seed that is correct
            // correct for four bits. That is, denominator * inv = 1 mod 2**4
            uint256 inv = (3 * denominator) ^ 2;
            // Now use Newton-Raphson iteration to improve the precision.
            // Thanks to Hensel's lifting lemma, this also works in modular
            // arithmetic, doubling the correct bits in each step.
            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            // Because the division is now exact we can divide by multiplying
            // with the modular inverse of denominator. This will give us the
            // correct result modulo 2**256. Since the precoditions guarantee
            // that the outcome is less than 2**256, this is the final result.
            // We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inv;
            return result;
        }
    }
}

// 

pragma solidity 0.8.13;



library FixedPoint112 {
    uint8 internal constant RESOLUTION = 112;
    
    uint256 internal constant Q112 = 0x10000000000000000000000000000;
}

// 

pragma solidity >=0.8.13;



interface IIndexFactory {
    struct NameDetails {
        string name;
        string symbol;
    }

    event SetVTokenFactory(address vTokenFactory);
    event SetDefaultMintingFeeInBP(address indexed account, uint16 mintingFeeInBP);
    event SetDefaultBurningFeeInBP(address indexed account, uint16 burningFeeInBP);
    event SetDefaultAUMScaledPerSecondsRate(address indexed account, uint AUMScaledPerSecondsRate);

    
    
    
    function setDefaultMintingFeeInBP(uint16 _mintingFeeInBP) external;

    
    
    
    function setDefaultBurningFeeInBP(uint16 _burningFeeInBP) external;

    
    
    function setReweightingLogic(address _reweightingLogic) external;

    
    /**
        @dev Will be set in FeePool on index creation.
        Effective management fee rate (annual, in percent, after dilution) is calculated by the given formula:
        fee = (rpow(scaledPerSecondRate, numberOfSeconds, 10*27) - 10**27) * totalSupply / 10**27, where:

        totalSupply - total index supply;
        numberOfSeconds - delta time for calculation period;
        scaledPerSecondRate - scaled rate, calculated off chain by the given formula:

        scaledPerSecondRate = ((1 + k) ** (1 / 365 days)) * AUMCalculationLibrary.RATE_SCALE_BASE, where:
        k = (aumFeeInBP / BP) / (1 - aumFeeInBP / BP);

        Note: rpow and RATE_SCALE_BASE are provided by AUMCalculationLibrary
        More info: https://docs.enzyme.finance/fee-formulas/management-fee

        After value calculated off chain, scaledPerSecondRate is set to setDefaultAUMScaledPerSecondsRate
    */
    
    function setDefaultAUMScaledPerSecondsRate(uint _AUMScaledPerSecondsRate) external;

    
    
    function withdrawToFeePool(address _index) external;

    
    
    function registry() external view returns (address);

    
    
    function vTokenFactory() external view returns (address);

    
    
    function defaultMintingFeeInBP() external view returns (uint16);

    
    
    function defaultBurningFeeInBP() external view returns (uint16);

    
    ///         See setDefaultAUMScaledPerSecondsRate method description for more details.
    
    function defaultAUMScaledPerSecondsRate() external view returns (uint);

    
    
    function reweightingLogic() external view returns (address);
}
