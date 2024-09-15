// SPDX-License-Identifier: MIT


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

pragma solidity 0.8.13;














contract OrderHelper {
    using FullMath for uint;

    
    bytes32 internal constant ASSET_ROLE = keccak256("ASSET_ROLE");

    struct Order {
        uint shares;
        uint amountInAsset;
        uint amountInBase;
        uint assetPrice;
        address asset;
        uint8 decimals;
        bool isInactive;
        IOrderer.OrderSide side;
    }

    function orderOf(address _index) external returns (Order[] memory _orders) {
        IvTokenFactory vTokenFactory = IvTokenFactory(IIndex(_index).vTokenFactory());
        IIndexRegistry registry = IIndexRegistry(IIndex(_index).registry());
        IOrderer orderer = IOrderer(registry.orderer());
        IPriceOracle priceOracle = IPriceOracle(registry.priceOracle());

        IOrderer.Order memory order = orderer.orderOf(_index);
        _orders = new Order[](order.assets.length);

        for (uint i; i < order.assets.length; ++i) {
            IOrderer.OrderAsset memory asset = order.assets[i];
            IvToken vToken = IvToken(vTokenFactory.vTokenOf(asset.asset));
            uint vTokenBalance = vToken.balanceOf(_index);
            uint amountInAsset = vToken.assetBalanceForShares(asset.shares);
            uint assetPrice = priceOracle.refreshedAssetPerBaseInUQ(asset.asset);
            uint amountInBase = amountInAsset.mulDiv(FixedPoint112.Q112, assetPrice);

            _orders[i] = Order({
                assetPrice: assetPrice,
                shares: asset.shares,
                amountInAsset: amountInAsset,
                amountInBase: amountInBase,
                asset: asset.asset,
                decimals: IERC20Metadata(asset.asset).decimals(),
                // @notice if selling all shares, asset is inactive
                isInactive: asset.shares >= vTokenBalance,
                side: asset.side
            });
        }
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

pragma solidity 0.8.13;



library FixedPoint112 {
    uint8 internal constant RESOLUTION = 112;
    
    uint256 internal constant Q112 = 0x10000000000000000000000000000;
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

pragma solidity >=0.8.13;






interface IIndex is IIndexLayout, IAnatomyUpdater {
    
    
    function mint(address _recipient) external;

    
    
    function burn(address _recipient) external;

    
    
    
    function anatomy() external view returns (address[] memory _assets, uint8[] memory _weights);

    
    
    function inactiveAnatomy() external view returns (address[] memory);
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



interface IPriceOracle {
    
    
    function refreshedAssetPerBaseInUQ(address _asset) external returns (uint);

    
    
    function lastAssetPerBaseInUQ(address _asset) external view returns (uint);
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

    
    
    
    function updateOrderDetails(address _asset, uint _shares) external;

    
    
    
    
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