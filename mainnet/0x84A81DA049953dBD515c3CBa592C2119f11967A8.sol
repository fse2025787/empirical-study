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

pragma solidity >=0.8.13;



interface IAnatomyUpdater {
    event UpdateAnatomy(address asset, uint8 weight);
    event AssetRemoved(address asset);
}

// 

pragma solidity >=0.8.13;



interface IIndexLayout {
    
    
    function factory() external view returns (address);

    
    
    function vTokenFactory() external view returns (address);

    
    
    function registry() external view returns (address);
}
// 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// 

pragma solidity >=0.8.13;





interface IManagedIndexReweightingLogic is IAnatomyUpdater {
    
    
    
    function reweight(address[] calldata _assets, uint8[] calldata _weights) external;
}

// 

pragma solidity 0.8.13;







abstract contract IndexLayout is IIndexLayout {
    
    address public override factory;
    
    address public override vTokenFactory;
    
    address public override registry;

    
    uint96 internal lastTransferTime;

    
    EnumerableSet.AddressSet internal assets;
    
    EnumerableSet.AddressSet internal inactiveAssets;
    
    mapping(address => uint8) internal weightOf;
}

// 

pragma solidity >=0.8.13;



interface IPriceOracle {
    
    
    function refreshedAssetPerBaseInUQ(address _asset) external returns (uint);

    
    
    function lastAssetPerBaseInUQ(address _asset) external view returns (uint);
}
// 

pragma solidity 0.8.13;

















contract ManagedIndexReweightingLogic is IndexLayout, IManagedIndexReweightingLogic, ERC165 {
    using FullMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;

    
    bytes32 internal constant ASSET_ROLE = keccak256("ASSET_ROLE");

    
    function reweight(address[] calldata _updatedAssets, uint8[] calldata _updatedWeights) external override {
        uint updatedAssetsCount = _updatedAssets.length;
        require(updatedAssetsCount > 1 && updatedAssetsCount == _updatedWeights.length, "ManagedIndex: INVALID");

        IPhuturePriceOracle oracle = IPhuturePriceOracle(IIndexRegistry(registry).priceOracle());
        uint virtualEvaluationInBase;

        uint activeAssetCount = assets.length();
        uint totalAssetCount = activeAssetCount + inactiveAssets.length();
        for (uint i; i < totalAssetCount; ) {
            address asset = i < activeAssetCount ? assets.at(i) : inactiveAssets.at(i - activeAssetCount);
            uint assetBalance = IvToken(IvTokenFactory(vTokenFactory).createdVTokenOf(asset)).assetBalanceOf(
                address(this)
            );
            virtualEvaluationInBase += assetBalance.mulDiv(FixedPoint112.Q112, oracle.refreshedAssetPerBaseInUQ(asset));

            unchecked {
                i = i + 1;
            }
        }

        IOrderer orderer = IOrderer(IIndexRegistry(registry).orderer());
        uint orderId = orderer.placeOrder();

        uint _totalWeight = IndexLibrary.MAX_WEIGHT;

        for (uint i; i < updatedAssetsCount; ) {
            address asset = _updatedAssets[i];
            require(asset != address(0), "ManagedIndex: ZERO");

            if (i != 0) {
                // makes sure that there are no duplicate assets
                require(_updatedAssets[i - 1] < asset, "ManagedIndex: SORT");
            }

            uint8 newWeight = _updatedWeights[i];
            if (newWeight != 0) {
                require(IAccessControl(registry).hasRole(ASSET_ROLE, asset), "ManagedIndex: INVALID_ASSET");
                assets.add(asset);
                inactiveAssets.remove(asset);

                uint8 prevWeight = weightOf[asset];
                if (prevWeight != newWeight) {
                    emit UpdateAnatomy(asset, newWeight);
                }

                _totalWeight = _totalWeight + newWeight - prevWeight;
                weightOf[asset] = newWeight;

                uint amountInBase = (virtualEvaluationInBase * weightOf[asset]) / IndexLibrary.MAX_WEIGHT;
                uint amountInAsset = amountInBase.mulDiv(oracle.refreshedAssetPerBaseInUQ(asset), FixedPoint112.Q112);
                (uint newShares, uint oldShares) = IvToken(IvTokenFactory(vTokenFactory).createdVTokenOf(asset))
                    .shareChange(address(this), amountInAsset);

                if (newShares > oldShares) {
                    orderer.addOrderDetails(orderId, asset, newShares - oldShares, IOrderer.OrderSide.Buy);
                } else if (oldShares > newShares) {
                    orderer.addOrderDetails(orderId, asset, oldShares - newShares, IOrderer.OrderSide.Sell);
                }
            } else {
                require(assets.remove(asset), "ManagedIndex: INVALID");

                inactiveAssets.add(asset);
                _totalWeight -= weightOf[asset];

                delete weightOf[asset];

                emit UpdateAnatomy(asset, 0);
            }

            unchecked {
                i = i + 1;
            }
        }

        require(assets.length() <= IIndexRegistry(registry).maxComponents(), "ManagedIndex: COMPONENTS");

        address[] memory _inactiveAssets = inactiveAssets.values();

        uint inactiveAssetsCount = _inactiveAssets.length;
        for (uint i; i < inactiveAssetsCount; ) {
            address inactiveAsset = _inactiveAssets[i];
            uint shares = IvToken(IvTokenFactory(vTokenFactory).vTokenOf(inactiveAsset)).balanceOf(address(this));
            if (shares > 0) {
                orderer.addOrderDetails(orderId, inactiveAsset, shares, IOrderer.OrderSide.Sell);
            } else {
                inactiveAssets.remove(inactiveAsset);
                emit AssetRemoved(inactiveAsset);
            }

            unchecked {
                i = i + 1;
            }
        }

        require(_totalWeight == IndexLibrary.MAX_WEIGHT, "ManagedIndex: MAX");
    }

    
    function supportsInterface(bytes4 _interfaceId) public view virtual override returns (bool) {
        return _interfaceId == type(IManagedIndexReweightingLogic).interfaceId || super.supportsInterface(_interfaceId);
    }
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





interface IOrderer {
    struct Order {
        uint creationTimestamp;
        OrderAsset[] assets;
    }

    struct OrderAsset {
        address asset;
        OrderSide side;
        uint shares;
    }

    struct InternalSwap {
        address sellAccount;
        address buyAccount;
        uint maxSellShares;
        address[] buyPath;
    }

    struct ExternalSwap {
        address factory;
        address account;
        uint maxSellShares;
        uint minSwapOutputAmount;
        address[] buyPath;
    }

    enum OrderSide {
        Sell,
        Buy
    }

    event PlaceOrder(address creator, uint id);
    event UpdateOrder(uint id, address asset, uint share, bool isSellSide);
    event CompleteOrder(uint id, address sellAsset, uint soldShares, address buyAsset, uint boughtShares);

    
    
    
    
    function initialize(
        address _registry,
        uint64 _orderLifetime,
        uint16 _maxAllowedPriceImpactInBP
    ) external;

    
    
    function setMaxAllowedPriceImpactInBP(uint16 _maxAllowedPriceImpactInBP) external;

    
    
    function setOrderLifetime(uint64 _orderLifetime) external;

    
    
    function placeOrder() external returns (uint);

    
    
    
    
    
    function addOrderDetails(
        uint _orderId,
        address _asset,
        uint _shares,
        OrderSide _side
    ) external;

    
    
    
    
    function reduceOrderAsset(
        address _asset,
        uint _newTotalSupply,
        uint _oldTotalSupply
    ) external;

    
    
    function reweight(address _index) external;

    
    
    function internalSwap(InternalSwap calldata _info) external;

    
    
    function externalSwap(ExternalSwap calldata _info) external;

    
    
    function maxAllowedPriceImpactInBP() external view returns (uint16);

    
    
    function orderLifetime() external view returns (uint64);

    
    
    
    function orderOf(address _account) external view returns (Order memory order);

    
    
    
    function lastOrderIdOf(address _account) external view returns (uint);
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





interface IPhuturePriceOracle is IPriceOracle {
    
    
    
    function initialize(address _registry, address _base) external;

    
    
    
    function setOracleOf(address _asset, address _oracle) external;

    
    
    function removeOracleOf(address _asset) external;

    
    
    
    
    function convertToIndex(uint _baseAmount, uint8 _indexDecimals) external view returns (uint);

    
    
    
    function containsOracleOf(address _asset) external view returns (bool);

    
    
    
    function priceOracleOf(address _asset) external view returns (address);
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

// 
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}
