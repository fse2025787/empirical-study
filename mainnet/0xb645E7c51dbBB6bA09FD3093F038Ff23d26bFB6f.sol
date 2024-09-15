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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
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
//
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        ██████████████                                        ██████████████
//        ██████████████          ▄▄████████████████▄▄         ▐█████████████▌
//        ██████████████    ▄█████████████████████████████▄    ██████████████
//         ██████████▀   ▄█████████████████████████████████   ██████████████▌
//          ██████▀   ▄██████████████████████████████████▀  ▄███████████████
//           ███▀   ██████████████████████████████████▀   ▄████████████████
//            ▀▀  ████████████████████████████████▀▀   ▄█████████████████▌
//              █████████████████████▀▀▀▀▀▀▀      ▄▄███████████████████▀
//             ██████████████████▀    ▄▄▄█████████████████████████████▀
//            ████████████████▀   ▄█████████████████████████████████▀  ██▄
//          ▐███████████████▀  ▄██████████████████████████████████▀   █████▄
//          ██████████████▀  ▄█████████████████████████████████▀   ▄████████
//         ██████████████▀   ███████████████████████████████▀   ▄████████████
//        ▐█████████████▌     ▀▀▀▀████████████████████▀▀▀▀      █████████████▌
//        ██████████████                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████

pragma solidity ^0.8.10;







///

/// asset as collateral to other protocols by signing a message, called an "entitlement", that gives
/// a specific account the ability to change the owner.
///
/// The vault can work with multiple assets via the assetId, where the asset or set of assets covered by
/// each segment is granted an individual id.
/// Every asset must be identified by an assetId to comply with this interface, even if the vault only contains
/// one asset.
///
/// ENTITLEMENTS -
///     (1) only one entitlement can be placed at a time.
///     (2) entitlements must expire, but can also be cleared by the entitled party
///     (3) if an entitlement expires, the current beneficial owner gains immediate sole control over the
///        asset
///     (4) the entitled entity can modify the beneficial owner of the asset, but cannot withdrawal.
///     (5) the beneficial owner cannot modify the beneficial owner while an entitlement is in place
///
interface IHookVault is IERC165 {
  
  event EntitlementImposed(
    uint32 assetId,
    address entitledAccount,
    uint32 expiry,
    address beneficialOwner
  );

  
  event EntitlementCleared(uint256 assetId, address beneficialOwner);

  
  
  /// imposed that also modifies the beneficial owner.
  event BeneficialOwnerSet(
    uint32 assetId,
    address beneficialOwner,
    address setBy
  );

  
  event AssetReceived(
    address owner,
    address sender,
    address contractAddress,
    uint32 assetId
  );

  
  event Approval(
    address indexed beneficialOwner,
    address indexed approved,
    uint32 indexed assetId
  );

  
  event AssetWithdrawn(uint32 assetId, address to, address beneficialOwner);

  
  
  function withdrawalAsset(uint32 assetId) external;

  
  
  
  function setBeneficialOwner(uint32 assetId, address newBeneficialOwner)
    external;

  
  
  
  
  
  
  
  function imposeEntitlement(
    address operator,
    uint32 expiry,
    uint32 assetId,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  
  
  
  function grantEntitlement(Entitlements.Entitlement calldata entitlement)
    external;

  
  
  function clearEntitlement(uint32 assetId) external;

  
  
  
  function clearEntitlementAndDistribute(uint32 assetId, address receiver)
    external;

  
  
  
  function getBeneficialOwner(uint32 assetId) external view returns (address);

  
  
  
  function getHoldsAsset(uint32 assetId) external view returns (bool);

  
  
  
  function assetAddress(uint32 assetId) external view returns (address);

  
  
  function getCurrentEntitlementOperator(uint32 assetId)
    external
    view
    returns (bool, address);

  
  
  
  function entitlementExpiration(uint32 assetId) external view returns (uint32);

  
  ///
  
  ///   * Requirements:
  ///
  /// -  The caller must be the beneficial owner
  /// - `tokenId` must exist.
  ///
  /// Emits an {Approval} event.
  function approveOperator(address to, uint32 assetId) external;

  
  ///
  /// Requirements:
  ///
  /// - `assetId` must exist.
  ///
  function getApprovedOperator(uint32 assetId) external view returns (address);
}

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
                version == 1 && !Address.isContract(address(this)),
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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

// 
//
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        ██████████████                                        ██████████████
//        ██████████████          ▄▄████████████████▄▄         ▐█████████████▌
//        ██████████████    ▄█████████████████████████████▄    ██████████████
//         ██████████▀   ▄█████████████████████████████████   ██████████████▌
//          ██████▀   ▄██████████████████████████████████▀  ▄███████████████
//           ███▀   ██████████████████████████████████▀   ▄████████████████
//            ▀▀  ████████████████████████████████▀▀   ▄█████████████████▌
//              █████████████████████▀▀▀▀▀▀▀      ▄▄███████████████████▀
//             ██████████████████▀    ▄▄▄█████████████████████████████▀
//            ████████████████▀   ▄█████████████████████████████████▀  ██▄
//          ▐███████████████▀  ▄██████████████████████████████████▀   █████▄
//          ██████████████▀  ▄█████████████████████████████████▀   ▄████████
//         ██████████████▀   ███████████████████████████████▀   ▄████████████
//        ▐█████████████▌     ▀▀▀▀████████████████████▀▀▀▀      █████████████▌
//        ██████████████                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████

pragma solidity ^0.8.10;







///

/// specifically designed to hold and receive ERC721 Tokens.
///
/// FLASH LOAN -
///     (1) beneficial owners are able to borrow the vaulted asset for a single function call
///     (2) to borrow the asset, they must implement and deploy a {IERC721FlashLoanReceiver}
///         contract, and then call the flashLoan method.
///     (3) At the end of the flashLoan, we ensure the asset is still owned by the vault.
interface IHookERC721Vault is IHookVault, IERC721Receiver {
  
  
  /// denoted by the tokenId emitted.
  event AssetFlashLoaned(address owner, uint256 tokenId, address flashLoanImpl);

  
  function assetTokenId(uint32 assetId) external view returns (uint256);

  
  /// may perform the flashloan
  
  /// before returning.
  
  /// asset while it is loaned out
  
  function flashLoan(
    uint32 assetId,
    address receiverAddress,
    bytes calldata params
  ) external;
}

// 
//
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        ██████████████                                        ██████████████
//        ██████████████          ▄▄████████████████▄▄         ▐█████████████▌
//        ██████████████    ▄█████████████████████████████▄    ██████████████
//         ██████████▀   ▄█████████████████████████████████   ██████████████▌
//          ██████▀   ▄██████████████████████████████████▀  ▄███████████████
//           ███▀   ██████████████████████████████████▀   ▄████████████████
//            ▀▀  ████████████████████████████████▀▀   ▄█████████████████▌
//              █████████████████████▀▀▀▀▀▀▀      ▄▄███████████████████▀
//             ██████████████████▀    ▄▄▄█████████████████████████████▀
//            ████████████████▀   ▄█████████████████████████████████▀  ██▄
//          ▐███████████████▀  ▄██████████████████████████████████▀   █████▄
//          ██████████████▀  ▄█████████████████████████████████▀   ▄████████
//         ██████████████▀   ███████████████████████████████▀   ▄████████████
//        ▐█████████████▌     ▀▀▀▀████████████████████▀▀▀▀      █████████████▌
//        ██████████████                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████

pragma solidity ^0.8.10;


abstract contract EIP712 {
  
  bytes32 public EIP712_DOMAIN_SEPARATOR;

  function setAddressForEipDomain(address hookAddress) internal {
    // Compute `EIP712_DOMAIN_SEPARATOR`
    {
      uint256 chainId;
      assembly {
        chainId := chainid()
      }
      EIP712_DOMAIN_SEPARATOR = keccak256(
        abi.encode(
          keccak256(
            "EIP712Domain("
            "string name,"
            "string version,"
            "uint256 chainId,"
            "address verifyingContract"
            ")"
          ),
          keccak256("Hook"),
          keccak256("1.0.0"),
          chainId,
          hookAddress
        )
      );
    }
  }

  function _getEIP712Hash(bytes32 structHash)
    internal
    view
    returns (bytes32)
  {
    return
      keccak256(
        abi.encodePacked(hex"1901", EIP712_DOMAIN_SEPARATOR, structHash)
      );
  }
}// 
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

// 
//
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        ██████████████                                        ██████████████
//        ██████████████          ▄▄████████████████▄▄         ▐█████████████▌
//        ██████████████    ▄█████████████████████████████▄    ██████████████
//         ██████████▀   ▄█████████████████████████████████   ██████████████▌
//          ██████▀   ▄██████████████████████████████████▀  ▄███████████████
//           ███▀   ██████████████████████████████████▀   ▄████████████████
//            ▀▀  ████████████████████████████████▀▀   ▄█████████████████▌
//              █████████████████████▀▀▀▀▀▀▀      ▄▄███████████████████▀
//             ██████████████████▀    ▄▄▄█████████████████████████████▀
//            ████████████████▀   ▄█████████████████████████████████▀  ██▄
//          ▐███████████████▀  ▄██████████████████████████████████▀   █████▄
//          ██████████████▀  ▄█████████████████████████████████▀   ▄████████
//         ██████████████▀   ███████████████████████████████▀   ▄████████████
//        ▐█████████████▌     ▀▀▀▀████████████████████▀▀▀▀      █████████████▌
//        ██████████████                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████

pragma solidity ^0.8.10;
















/// are able to register "entitlements" for a fixed period of time on the asset, which give them the ability to
/// change the vault's owner.

/// This contract views the tokenId for the asset on the ERC721 contract as the corresponding assetId for that asset
/// when deposited into the vault
contract HookERC721MultiVaultImplV1 is
  IHookERC721Vault,
  EIP712,
  Initializable,
  ReentrancyGuard
{
  /// ----------------  STORAGE ---------------- ///

  
  IERC721 internal _nftContract;

  struct Asset {
    address beneficialOwner;
    address operator;
    uint32 expiry;
  }

  
  /// for the asset
  /// if the entitled operator field is non-null, it means an unreleased entitlement has been
  /// applied; however, that entitlement could still be expired (if block.timestamp > entitlement.expiry)
  mapping(uint32 => Asset) internal assets;

  // Mapping from asset ID to approved address
  mapping(uint32 => address) private _assetApprovals;

  IHookProtocol internal _hookProtocol;

  /// Upgradeable Implementations cannot have a constructor, so we call the initialize instead;
  constructor() {}

  ///-constructor
  function initialize(address nftContract, address hookAddress)
    public
    initializer
  {
    setAddressForEipDomain(hookAddress);
    _nftContract = IERC721(nftContract);
    _hookProtocol = IHookProtocol(hookAddress);
  }

  /// ---------------- PUBLIC FUNCTIONS ---------------- ///

  ///
  
  ///
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    returns (bool)
  {
    return
      interfaceId == type(IHookERC721Vault).interfaceId ||
      interfaceId == type(IERC165).interfaceId;
  }

  
  
  function withdrawalAsset(uint32 assetId) public virtual nonReentrant {
    require(
      !hasActiveEntitlement(assetId),
      "withdrawalAsset-the asset cannot be withdrawn with an active entitlement"
    );
    require(
      assets[assetId].beneficialOwner == msg.sender,
      "withdrawalAsset-only the beneficial owner can withdrawal an asset"
    );

    _nftContract.safeTransferFrom(
      address(this),
      assets[assetId].beneficialOwner,
      _assetTokenId(assetId)
    );

    emit AssetWithdrawn(assetId, msg.sender, assets[assetId].beneficialOwner);
  }

  
  
  /// entitlement
  function imposeEntitlement(
    address operator,
    uint32 expiry,
    uint32 assetId,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public virtual {
    // check that the asset has a current beneficial owner
    // before creating a new entitlement
    require(
      assets[assetId].beneficialOwner != address(0),
      "imposeEntitlement-beneficial owner must be set to impose an entitlement"
    );

    // the beneficial owner of an asset is able to set any entitlement on their own asset
    // as long as it has not already been committed to someone else.
    _verifyAndRegisterEntitlement(operator, expiry, assetId, v, r, s);
  }

  
  
  function grantEntitlement(Entitlements.Entitlement calldata entitlement)
    external
  {
    require(
      assets[entitlement.assetId].beneficialOwner == msg.sender ||
        _assetApprovals[entitlement.assetId] == msg.sender,
      "grantEntitlement-only the beneficial owner or approved operator can grant an entitlement"
    );

    // the beneficial owner of an asset is able to directly set any entitlement on their own asset
    // as long as it has not already been committed to someone else.

    _registerEntitlement(
      entitlement.assetId,
      entitlement.operator,
      entitlement.expiry,
      msg.sender
    );
  }

  
  ///
  /// Always returns `IERC721Receiver.onERC721Received.selector`.
  function onERC721Received(
    address operator, // this arg is the address of the operator
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external virtual override returns (bytes4) {
    require(
      tokenId <= type(uint32).max,
      "onERC721Received-tokenId is out of range"
    );
    /// (1) When receiving a nft from the ERC-721 contract this vault covers, create a new entitlement entry
    /// with the sender as the beneficial owner to track the asset within the vault.
    ///
    /// (1a) If the transfer additionally specifies data (i.e. an abi-encoded entitlement), the entitlement will
    /// be imposed via that transfer, including a new beneficial owner.
    ///     NOTE: this is an opinionated approach, however, the authors believe that anyone with the ability to
    ///     transfer the asset into this contract could also trivially transfer the asset to another address
    ///     they control and then deposit, so allowing this method of setting the beneficial owner simply
    ///     saves gas and has no practical impact on the rights a hypothetical sender has regarding the asset.
    ///
    /// (2) If another nft is sent to the contract, we should verify that airdrops are allowed to this vault;
    /// if they are disabled, we should not return the selector, otherwise we can allow them.
    ///
    /// IMPORTANT: If an unrelated contract is currently holding the asset on behalf of an owner and then
    /// subsequently transfers the asset into the contract, it needs to manually call (setBeneficialOwner)
    /// after making this call to ensure that the true owner of the asset is known to the vault. Otherwise,
    /// the owner will lose the ability to reclaim their asset. Alternatively, they could pass an entitlement
    /// in pre-populated with the correct beneficial owner, which will give that owner the ability to reclaim
    /// the asset.
    if (msg.sender == address(_nftContract)) {
      // There is no need to check if we currently have this token or an entitlement set.
      // Even if the contract were able to get into this state, it should still accept the asset
      // which will allow it to enforce the entitlement.

      // If additional data is sent with the transfer, we attempt to parse an entitlement from it.
      // this allows the entitlement to be registered ahead of time.
      if (data.length > 0) {
        /// If the abi-encoded parameters are 3 words long, assume no approved operator was provided.
        if (data.length == 3 * 32) {
          // Decode the order, signature from `data`. If `data` does not encode such parameters, this
          // will throw.
          (
            address beneficialOwner,
            address entitledOperator,
            uint32 expirationTime
          ) = abi.decode(data, (address, address, uint32));

          // if someone has the asset, they should be able to set whichever beneficial owner they'd like.
          // equally, they could transfer the asset first to themselves and subsequently grant a specific
          // entitlement, which is equivalent to this.
          _registerEntitlement(
            uint32(tokenId),
            entitledOperator,
            expirationTime,
            beneficialOwner
          );
        } else {
          /// additionally decode the approved operator from the payload. The abi decoder ensures that the
          /// there are exactly 4 parameters
          (
            address beneficialOwner,
            address entitledOperator,
            uint32 expirationTime,
            address approvedOperator
          ) = abi.decode(data, (address, address, uint32, address));

          _registerEntitlement(
            uint32(tokenId),
            entitledOperator,
            expirationTime,
            beneficialOwner
          );

          /// if an approved operator is provided with this contract call, set the approval accepting it for the
          /// same reason.

          _approve(approvedOperator, uint32(tokenId));
        }
      } else {
        _setBeneficialOwner(uint32(tokenId), from);
      }
      emit AssetReceived(
        this.getBeneficialOwner(uint32(tokenId)),
        operator,
        msg.sender,
        uint32(tokenId)
      );
    } else {
      // If we're receiving an airdrop or other asset uncovered by escrow to this address, we should ensure
      // that this is allowed by our current settings.
      require(
        _hookProtocol.getCollectionConfig(
          address(_nftContract),
          keccak256("vault.multiAirdropsAllowed")
        ),
        "onERC721Received-non-escrow asset returned when airdrops are disabled"
      );
    }
    return this.onERC721Received.selector;
  }

  
  function flashLoan(
    uint32 assetId,
    address receiverAddress,
    bytes calldata params
  ) external override nonReentrant {
    IERC721FlashLoanReceiver receiver = IERC721FlashLoanReceiver(
      receiverAddress
    );
    require(receiverAddress != address(0), "flashLoan-zero address");
    require(
      _assetOwner(assetId) == address(this),
      "flashLoan-asset not in vault"
    );
    require(
      msg.sender == assets[assetId].beneficialOwner,
      "flashLoan-not called by the asset owner"
    );

    require(
      !_hookProtocol.getCollectionConfig(
        address(_nftContract),
        keccak256("vault.flashLoanDisabled")
      ),
      "flashLoan-flashLoan feature disabled for this contract"
    );

    // (1) store a hash of our current entitlement state as a snapshot to diff
    bytes32 startState = keccak256(abi.encode(assets[assetId]));

    // (2) send the flashloan contract the vaulted NFT
    _nftContract.safeTransferFrom(
      address(this),
      receiverAddress,
      _assetTokenId(assetId)
    );

    // (3) call the flashloan contract, giving it a chance to do whatever it wants
    // NOTE: The flashloan contract MUST approve this vault contract as an operator
    // for the nft, such that we're able to make sure it has arrived.
    require(
      receiver.executeOperation(
        address(_nftContract),
        _assetTokenId(assetId),
        msg.sender,
        address(this),
        params
      ),
      "flashLoan-the flash loan contract must return true"
    );

    // (4) return the nft back into the vault
    //        Use transferFrom instead of safeTransfer from because transferFrom
    //        would modify our state ( it calls erc721Receiver ). and because we know
    //        for sure that this contract can handle ERC-721s.
    _nftContract.transferFrom(
      receiverAddress,
      address(this),
      _assetTokenId(assetId)
    );

    // (5) sanity check to ensure the asset was actually returned to the vault.
    // this is a concern because its possible that the safeTransferFrom implemented by
    // some contract fails silently
    require(_assetOwner(assetId) == address(this));

    // (6) additional sanity check to ensure that the internal state of
    // the entitlement has not somehow been modified during the flash loan, for example
    // via some re-entrancy attack or by sending the asset back into the contract
    // prematurely
    require(
      startState == keccak256(abi.encode(assets[assetId])),
      "flashLoan-entitlement state cannot be modified"
    );

    // (7) emit an event to record the flashloan
    emit AssetFlashLoaned(
      assets[assetId].beneficialOwner,
      assetId,
      receiverAddress
    );
  }

  
  function entitlementExpiration(uint32 assetId)
    external
    view
    returns (uint32)
  {
    if (!hasActiveEntitlement(assetId)) {
      return 0;
    } else {
      return assets[assetId].expiry;
    }
  }

  
  function getBeneficialOwner(uint32 assetId) external view returns (address) {
    return assets[assetId].beneficialOwner;
  }

  
  function getHoldsAsset(uint32 assetId) external view returns (bool) {
    return _assetOwner(assetId) == address(this);
  }

  function assetAddress(uint32) external view returns (address) {
    return address(_nftContract);
  }

  
  /// the tokenId == the assetId
  function assetTokenId(uint32 assetId) external view returns (uint256) {
    return _assetTokenId(assetId);
  }

  
  /// setBeneficialOwner can only be called by the entitlementContract if there is an activeEntitlement.
  function setBeneficialOwner(uint32 assetId, address newBeneficialOwner)
    public
    virtual
  {
    if (hasActiveEntitlement(assetId)) {
      require(
        msg.sender == assets[assetId].operator,
        "setBeneficialOwner-only the contract with the active entitlement can update the beneficial owner"
      );
    } else {
      require(
        msg.sender == assets[assetId].beneficialOwner,
        "setBeneficialOwner-only the current owner can update the beneficial owner"
      );
    }
    _setBeneficialOwner(assetId, newBeneficialOwner);
  }

  
  
  function clearEntitlement(uint32 assetId) public {
    require(
      hasActiveEntitlement(assetId),
      "clearEntitlement-an active entitlement must exist"
    );
    require(
      msg.sender == assets[assetId].operator,
      "clearEntitlement-only the entitled address can clear the entitlement"
    );
    _clearEntitlement(assetId);
  }

  
  
  /// intended receiver, which should match the beneficialOwner. The function will throw if
  /// the receiver and owner do not match.
  
  
  function clearEntitlementAndDistribute(uint32 assetId, address receiver)
    external
    nonReentrant
  {
    require(
      assets[assetId].beneficialOwner == receiver,
      "clearEntitlementAndDistribute-Only the beneficial owner can receive the asset"
    );
    require(
      receiver != address(0),
      "clearEntitlementAndDistribute-assets cannot be sent to null address"
    );
    clearEntitlement(assetId);
    IERC721(_nftContract).safeTransferFrom(
      address(this),
      receiver,
      _assetTokenId(assetId)
    );
    emit AssetWithdrawn(assetId, receiver, assets[assetId].beneficialOwner);
  }

  
  /// EIP-712 signed by the beneficial owner specified in the entitlement.
  function validateEntitlementSignature(
    address operator,
    uint32 expiry,
    uint32 assetId,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public view {
    bytes32 entitlementHash = _getEIP712Hash(
      Entitlements.getEntitlementStructHash(
        Entitlements.Entitlement({
          beneficialOwner: assets[assetId].beneficialOwner,
          expiry: expiry,
          operator: operator,
          assetId: assetId,
          vaultAddress: address(this)
        })
      )
    );
    address signer = ecrecover(entitlementHash, v, r, s);

    require(signer != address(0), "recovered address is null");
    require(
      signer == assets[assetId].beneficialOwner,
      "validateEntitlementSignature --- not signed by beneficialOwner"
    );
  }

  ///
  
  ///
  function approveOperator(address to, uint32 assetId) public virtual override {
    address beneficialOwner = assets[assetId].beneficialOwner;

    require(
      to != beneficialOwner,
      "approve-approval to current beneficialOwner"
    );

    require(
      msg.sender == beneficialOwner,
      "approve-approve caller is not current beneficial owner"
    );

    _approve(to, assetId);
  }

  
  function getApprovedOperator(uint32 assetId)
    public
    view
    virtual
    override
    returns (address)
  {
    return _assetApprovals[assetId];
  }

  
  ///
  /// Emits an {Approval} event.
  
  
  function _approve(address to, uint32 assetId) internal virtual {
    _assetApprovals[assetId] = to;
    emit Approval(assets[assetId].beneficialOwner, to, assetId);
  }

  /// ---------------- INTERNAL/PRIVATE FUNCTIONS ---------------- ///

  
  
  
  
  
  
  
  
  function _verifyAndRegisterEntitlement(
    address operator,
    uint32 expiry,
    uint32 assetId,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) private {
    validateEntitlementSignature(operator, expiry, assetId, v, r, s);
    _registerEntitlement(
      assetId,
      operator,
      expiry,
      assets[assetId].beneficialOwner
    );
  }

  function _registerEntitlement(
    uint32 assetId,
    address operator,
    uint32 expiry,
    address beneficialOwner
  ) internal {
    require(
      !hasActiveEntitlement(assetId),
      "_registerEntitlement-existing entitlement must be cleared before registering a new one"
    );

    require(
      expiry > block.timestamp,
      "_registerEntitlement-entitlement must expire in the future"
    );
    assets[assetId] = Asset({
      operator: operator,
      expiry: expiry,
      beneficialOwner: beneficialOwner
    });
    emit EntitlementImposed(assetId, operator, expiry, beneficialOwner);
  }

  function _clearEntitlement(uint32 assetId) private {
    assets[assetId].expiry = 0;
    assets[assetId].operator = address(0);
    emit EntitlementCleared(assetId, assets[assetId].beneficialOwner);
  }

  function hasActiveEntitlement(uint32 assetId) public view returns (bool) {
    /// Although we do clear the expiry in _clearEntitlement, making the second half of the AND redundant,
    /// we choose to include it here because we rely on this field being null to clear an entitlement.
    return
      block.timestamp < assets[assetId].expiry &&
      assets[assetId].operator != address(0);
  }

  function getCurrentEntitlementOperator(uint32 assetId)
    external
    view
    returns (bool, address)
  {
    bool isActive = hasActiveEntitlement(assetId);
    address operator = assets[assetId].operator;

    return (isActive, operator);
  }

  
  /// on that assets assetId within this vault.
  ///
  /// this function can be overridden if the assetId -> tokenId mapping is modified.
  function _assetOwner(uint32 assetId) internal view returns (address) {
    return _nftContract.ownerOf(_assetTokenId(assetId));
  }

  
  ///
  /// this function can be overridden if the assetId -> tokenId mapping is modified.
  function _assetTokenId(uint32 assetId)
    internal
    view
    virtual
    returns (uint256)
  {
    return assetId;
  }

  
  function _setBeneficialOwner(uint32 assetId, address newBeneficialOwner)
    internal
  {
    require(
      newBeneficialOwner != address(0),
      "_setBeneficialOwner-new owner is the zero address"
    );
    assets[assetId].beneficialOwner = newBeneficialOwner;
    _approve(address(0), assetId);
    emit BeneficialOwnerSet(assetId, newBeneficialOwner, msg.sender);
  }
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
//
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        ██████████████                                        ██████████████
//        ██████████████          ▄▄████████████████▄▄         ▐█████████████▌
//        ██████████████    ▄█████████████████████████████▄    ██████████████
//         ██████████▀   ▄█████████████████████████████████   ██████████████▌
//          ██████▀   ▄██████████████████████████████████▀  ▄███████████████
//           ███▀   ██████████████████████████████████▀   ▄████████████████
//            ▀▀  ████████████████████████████████▀▀   ▄█████████████████▌
//              █████████████████████▀▀▀▀▀▀▀      ▄▄███████████████████▀
//             ██████████████████▀    ▄▄▄█████████████████████████████▀
//            ████████████████▀   ▄█████████████████████████████████▀  ██▄
//          ▐███████████████▀  ▄██████████████████████████████████▀   █████▄
//          ██████████████▀  ▄█████████████████████████████████▀   ▄████████
//         ██████████████▀   ███████████████████████████████▀   ▄████████████
//        ▐█████████████▌     ▀▀▀▀████████████████████▀▀▀▀      █████████████▌
//        ██████████████                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████

pragma solidity ^0.8.10;







/// to register "entitlements" for a fixed period of time on the asset, which give them the ability to
/// change the vault's owner.

/// asset as assetId 0 in all cases.
///
/// SEND TRANSACTION -
///     (1) owners are able to forward transactions to this vault to other wallets
///     (2) calls to the ERC-721 address are blocked to prevent approvals from being set on the
///         NFT while in escrow, which could allow for theft
///     (3) At the end of each transaction, the ownerOf the vaulted token must still be the vault
contract HookERC721VaultImplV1 is HookERC721MultiVaultImplV1 {
  uint32 private constant ASSET_ID = 0;

  /// ----------------  STORAGE ---------------- ///

  
  uint256 internal _tokenId;

  /// Upgradeable Implementations cannot have a constructor, so we call the initialize instead;
  constructor() HookERC721MultiVaultImplV1() {}

  ///-constructor
  function initialize(
    address nftContract,
    uint256 tokenId,
    address hookAddress
  ) public {
    _tokenId = tokenId;
    // the super function calls "Initialize"
    super.initialize(nftContract, hookAddress);
  }

  /// ---------------- PUBLIC/EXTERNAL FUNCTIONS ---------------- ///

  
  
  function withdrawalAsset(uint32 assetId)
    public
    override
    assetIdIsZero(assetId)
  {
    super.withdrawalAsset(assetId);
  }

  
  
  /// function and successfully impose the entitlement as long as the signature is valid.
  function imposeEntitlement(
    address operator,
    uint32 expiry,
    uint32 assetId,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public override assetIdIsZero(assetId) {
    super.imposeEntitlement(operator, expiry, assetId, v, r, s);
  }

  
  ///
  /// Always returns `IERC721Receiver.onERC721Received.selector`.
  ///
  /// This method requires an override implementation because the the arguments must be embedded in the body of the
  /// function
  function onERC721Received(
    address operator, // this arg is the address of the operator
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external virtual override returns (bytes4) {
    /// (1) If the contract is specified to hold a specific NFT, and that NFT is sent to the contract,
    /// set the beneficial owner of this vault to be current owner of the asset getting sent. Alternatively,
    /// the sender can specify an entitlement which contains a different beneficial owner. We accept this because
    /// that same sender could alternatively first send the token, become the beneficial owner, and then set it
    /// the beneficial owner to someone else and finally specify an entitlement.
    ///
    /// (2) If another nft is sent to the contract, we should verify that airdrops are allowed to this vault;
    /// if they are disabled, we should not return the selector, otherwise we can allow them.
    ///
    /// IMPORTANT: If an unrelated contract is currently holding the asset on behalf of an owner and then
    /// subsequently transfers the asset into the contract, it needs to manually call (setBeneficialOwner)
    /// after making this call to ensure that the true owner of the asset is known to the vault. Otherwise,
    /// the owner will lose the ability to reclaim their asset. Alternatively, they could pass an entitlement
    /// in pre-populated with the correct beneficial owner, which will give that owner the ability to reclaim
    /// the asset.
    if (msg.sender == address(_nftContract) && tokenId == _tokenId) {
      // There is no need to check if we currently have this token or an entitlement set.
      // Even if the contract were able to get into this state, it should still accept the asset
      // which will allow it to enforce the entitlement.
      _setBeneficialOwner(ASSET_ID, from);

      // If additional data is sent with the transfer, we attempt to parse an entitlement from it.
      // this allows the entitlement to be registered ahead of time.
      if (data.length > 0) {
        // Decode the order, signature from `data`. If `data` does not encode such parameters, this
        // will throw.
        (
          address _beneficialOwner,
          address entitledOperator,
          uint32 expirationTime
        ) = abi.decode(data, (address, address, uint32));
        // if someone has the asset, they should be able to set whichever beneficial owner they'd like.
        // equally, they could transfer the asset first to themselves and subsequently grant a specific
        // entitlement, which is equivalent to this.
        _setBeneficialOwner(ASSET_ID, _beneficialOwner);
        _registerEntitlement(
          ASSET_ID,
          entitledOperator,
          expirationTime,
          assets[ASSET_ID].beneficialOwner
        );
      }
      emit AssetReceived(
        this.getBeneficialOwner(uint32(ASSET_ID)),
        operator,
        msg.sender,
        ASSET_ID
      );
    } else {
      // If we're receiving an airdrop or other asset uncovered by escrow to this address, we should ensure
      // that this is allowed by our current settings.
      require(
        !_hookProtocol.getCollectionConfig(
          address(_nftContract),
          keccak256("vault.airdropsProhibited")
        ),
        "onERC721Received-non-escrow asset returned when airdrops are disabled"
      );
    }
    return this.onERC721Received.selector;
  }

  
  
  /// is still owned by us after the transaction. The ether value sent is forwarded. Return value is suppressed.
  ///
  /// Because this contract holds only a single asset owned by a single address, it supports calling exec
  /// transaction from this address because such calls are unlikely to impact other owner's assets.
  function execTransaction(address to, bytes memory data)
    external
    payable
    virtual
    returns (bool)
  {
    // Only the beneficial owner can make this call
    require(
      msg.sender == assets[ASSET_ID].beneficialOwner,
      "execTransaction-only the beneficial owner can use the transaction"
    );

    // block transactions to the NFT contract to ensure that people cant set approvals as the owner.
    require(
      to != address(_nftContract),
      "execTransaction-cannot send transactions to the NFT contract itself"
    );

    // block transactions to the vault to mitigate reentrancy vulnerabilities
    require(
      to != address(this),
      "execTransaction-cannot call the vault contract"
    );

    require(
      !_hookProtocol.getCollectionConfig(
        address(_nftContract),
        keccak256("vault.execTransactionDisabled")
      ),
      "execTransaction-feature is disabled for this collection"
    );

    // Execute transaction without further confirmations.
    (bool success, ) = address(to).call{value: msg.value}(data);

    require(_assetOwner(ASSET_ID) == address(this));

    return success;
  }

  
  function setBeneficialOwner(uint32 assetId, address newBeneficialOwner)
    public
    override
    assetIdIsZero(assetId)
  {
    super.setBeneficialOwner(assetId, newBeneficialOwner);
  }

  
  /// may be passed into this vault.
  modifier assetIdIsZero(uint256 assetId) {
    require(
      assetId == ASSET_ID,
      "assetIdIsZero-this vault only supports asset id 0"
    );
    _;
  }

  
  /// token in this vault is checked on the ERC-721 contract
  function _assetTokenId(uint32 assetId)
    internal
    view
    override
    assetIdIsZero(assetId)
    returns (uint256)
  {
    return _tokenId;
  }
}

// 
//
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        ██████████████                                        ██████████████
//        ██████████████          ▄▄████████████████▄▄         ▐█████████████▌
//        ██████████████    ▄█████████████████████████████▄    ██████████████
//         ██████████▀   ▄█████████████████████████████████   ██████████████▌
//          ██████▀   ▄██████████████████████████████████▀  ▄███████████████
//           ███▀   ██████████████████████████████████▀   ▄████████████████
//            ▀▀  ████████████████████████████████▀▀   ▄█████████████████▌
//              █████████████████████▀▀▀▀▀▀▀      ▄▄███████████████████▀
//             ██████████████████▀    ▄▄▄█████████████████████████████▀
//            ████████████████▀   ▄█████████████████████████████████▀  ██▄
//          ▐███████████████▀  ▄██████████████████████████████████▀   █████▄
//          ██████████████▀  ▄█████████████████████████████████▀   ▄████████
//         ██████████████▀   ███████████████████████████████▀   ▄████████████
//        ▐█████████████▌     ▀▀▀▀████████████████████▀▀▀▀      █████████████▌
//        ██████████████                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████

pragma solidity ^0.8.10;







/// receive the asset. Users may want to receive the asset within a single block to claim airdrops, participate
/// in governance, and other things with their assets.
///
/// The implementer may do whatever they like with the vaulted NFT within the executeOperation method,
/// so long as they approve the vault (passed as a param) to operate the underlying NFT. The Vault
/// will move the asset back into the vault after executionOperation returns, and also validate that
/// it is the owner of the asset.
///
/// The flashloan receiver is able to abort a flashloan by returning false from the executeOperation method.
interface IERC721FlashLoanReceiver is IERC721Receiver {
  
  
  /// the asset is returned to the vault by the vault contract. The executeOperation implementation MUST
  /// approve the {vault} to operate the transferred NFT
  /// i.e. `IERC721(nftContract).setApprovalForAll(vault, true);`
  ///
  
  
  
  
  
  function executeOperation(
    address nftContract,
    uint256 tokenId,
    address beneficialOwner,
    address vault,
    bytes calldata params
  ) external returns (bool);
}

// 
//
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        ██████████████                                        ██████████████
//        ██████████████          ▄▄████████████████▄▄         ▐█████████████▌
//        ██████████████    ▄█████████████████████████████▄    ██████████████
//         ██████████▀   ▄█████████████████████████████████   ██████████████▌
//          ██████▀   ▄██████████████████████████████████▀  ▄███████████████
//           ███▀   ██████████████████████████████████▀   ▄████████████████
//            ▀▀  ████████████████████████████████▀▀   ▄█████████████████▌
//              █████████████████████▀▀▀▀▀▀▀      ▄▄███████████████████▀
//             ██████████████████▀    ▄▄▄█████████████████████████████▀
//            ████████████████▀   ▄█████████████████████████████████▀  ██▄
//          ▐███████████████▀  ▄██████████████████████████████████▀   █████▄
//          ██████████████▀  ▄█████████████████████████████████▀   ▄████████
//         ██████████████▀   ███████████████████████████████▀   ▄████████████
//        ▐█████████████▌     ▀▀▀▀████████████████████▀▀▀▀      █████████████▌
//        ██████████████                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████

pragma solidity ^0.8.10;






///

/// is correct as, if it is not, all assets contained within protocol contracts
/// can be easily compromised.
interface IHookProtocol is IAccessControl {
  
  function coveredCallContract() external view returns (address);

  
  function vaultContract() external view returns (address);

  
  function throwWhenPaused() external;

  
  
  /// mainnet: 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
  /// kovan: 0xd0a1e359811322d97991e03f863a0c30c2cf029c
  /// ropsten: 0xc778417e063141139fce010982780140aa0cd5ab
  /// rinkeby: 0xc778417e063141139fce010982780140aa0cd5ab
  
  function getWETHAddress() external view returns (address);

  
  
  
  
  function getCollectionConfig(address collectionAddress, bytes32 conf)
    external
    view
    returns (bool);
}

// 
//
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        ██████████████                                        ██████████████
//        ██████████████          ▄▄████████████████▄▄         ▐█████████████▌
//        ██████████████    ▄█████████████████████████████▄    ██████████████
//         ██████████▀   ▄█████████████████████████████████   ██████████████▌
//          ██████▀   ▄██████████████████████████████████▀  ▄███████████████
//           ███▀   ██████████████████████████████████▀   ▄████████████████
//            ▀▀  ████████████████████████████████▀▀   ▄█████████████████▌
//              █████████████████████▀▀▀▀▀▀▀      ▄▄███████████████████▀
//             ██████████████████▀    ▄▄▄█████████████████████████████▀
//            ████████████████▀   ▄█████████████████████████████████▀  ██▄
//          ▐███████████████▀  ▄██████████████████████████████████▀   █████▄
//          ██████████████▀  ▄█████████████████████████████████▀   ▄████████
//         ██████████████▀   ███████████████████████████████▀   ▄████████████
//        ▐█████████████▌     ▀▀▀▀████████████████████▀▀▀▀      █████████████▌
//        ██████████████                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████

pragma solidity ^0.8.10;



library Entitlements {
  uint256 private constant _ENTITLEMENT_TYPEHASH =
    uint256(
      keccak256(
        abi.encodePacked(
          "Entitlement(",
          "address beneficialOwner,",
          "address operator,",
          "address vaultAddress,",
          "uint32 assetId,",
          "uint32 expiry",
          ")"
        )
      )
    );

  /// ---- STRUCTS -----
  struct Entitlement {
    
    address beneficialOwner;
    
    address operator;
    
    address vaultAddress;
    
    uint32 assetId;
    
    uint32 expiry;
  }

  function getEntitlementStructHash(Entitlement memory entitlement)
    internal
    pure
    returns (bytes32)
  {
    // TODO: Hash in place to save gas.
    return
      keccak256(
        abi.encode(
          _ENTITLEMENT_TYPEHASH,
          entitlement.beneficialOwner,
          entitlement.operator,
          entitlement.vaultAddress,
          entitlement.assetId,
          entitlement.expiry
        )
      );
  }
}

// 
//
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        ██████████████                                        ██████████████
//        ██████████████          ▄▄████████████████▄▄         ▐█████████████▌
//        ██████████████    ▄█████████████████████████████▄    ██████████████
//         ██████████▀   ▄█████████████████████████████████   ██████████████▌
//          ██████▀   ▄██████████████████████████████████▀  ▄███████████████
//           ███▀   ██████████████████████████████████▀   ▄████████████████
//            ▀▀  ████████████████████████████████▀▀   ▄█████████████████▌
//              █████████████████████▀▀▀▀▀▀▀      ▄▄███████████████████▀
//             ██████████████████▀    ▄▄▄█████████████████████████████▀
//            ████████████████▀   ▄█████████████████████████████████▀  ██▄
//          ▐███████████████▀  ▄██████████████████████████████████▀   █████▄
//          ██████████████▀  ▄█████████████████████████████████▀   ▄████████
//         ██████████████▀   ███████████████████████████████▀   ▄████████████
//        ▐█████████████▌     ▀▀▀▀████████████████████▀▀▀▀      █████████████▌
//        ██████████████                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████

pragma solidity ^0.8.10;


library Signatures {
  
  enum SignatureType {
    EIP712
  }

  
  struct Signature {
    // How to validate the signature.
    SignatureType signatureType;
    // EC Signature data.
    uint8 v;
    // EC Signature data.
    bytes32 r;
    // EC Signature data.
    bytes32 s;
  }
}
