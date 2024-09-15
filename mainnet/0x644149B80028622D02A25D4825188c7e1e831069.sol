// SPDX-License-Identifier: BUSL-1.1

/**
 *Submitted for verification at Etherscan.io on 2022-11-05
*/

// 
// File: contracts/libraries/math/IporMath.sol


pragma solidity 0.8.15;

library IporMath {
    //@notice Division with rounding up on last position, x, and y is with MD
    function division(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = (x + (y / 2)) / y;
    }

    function divisionInt(int256 x, int256 y) internal pure returns (int256 z) {
        z = (x + (y / 2)) / y;
    }

    function divisionWithoutRound(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x / y;
    }

    function convertWadToAssetDecimals(uint256 value, uint256 assetDecimals)
        internal
        pure
        returns (uint256)
    {
        if (assetDecimals == 18) {
            return value;
        } else if (assetDecimals > 18) {
            return value * 10**(assetDecimals - 18);
        } else {
            return division(value, 10**(18 - assetDecimals));
        }
    }

    function convertToWad(uint256 value, uint256 assetDecimals) internal pure returns (uint256) {
        if (value > 0) {
            if (assetDecimals == 18) {
                return value;
            } else if (assetDecimals > 18) {
                return division(value, 10**(assetDecimals - 18));
            } else {
                return value * 10**(18 - assetDecimals);
            }
        } else {
            return value;
        }
    }

    function absoluteValue(int256 value) internal pure returns (uint256) {
        return (uint256)(value < 0 ? -value : value);
    }

    function percentOf(uint256 value, uint256 rate) internal pure returns (uint256) {
        return division(value * rate, 1e18);
    }
}

// File: contracts/libraries/errors/MiltonErrors.sol


pragma solidity 0.8.15;


library MiltonErrors {
    // 300-399-milton
    
    string public constant LIQUIDITY_POOL_IS_EMPTY = "IPOR_300";

    
    string public constant LIQUIDITY_POOL_AMOUNT_TOO_LOW = "IPOR_301";

    
    string public constant LP_UTILIZATION_EXCEEDED = "IPOR_302";

    
    string public constant LP_UTILIZATION_PER_LEG_EXCEEDED = "IPOR_303";

    
    string public constant LIQUIDITY_POOL_BALANCE_IS_TOO_HIGH = "IPOR_304";

    
    string public constant LP_ACCOUNT_CONTRIBUTION_IS_TOO_HIGH = "IPOR_305";

    
    string public constant INCORRECT_SWAP_ID = "IPOR_306";

    
    string public constant INCORRECT_SWAP_STATUS = "IPOR_307";

    
    string public constant LEVERAGE_TOO_LOW = "IPOR_308";

    
    string public constant LEVERAGE_TOO_HIGH = "IPOR_309";

    
    string public constant TOTAL_AMOUNT_TOO_LOW = "IPOR_310";

    
    string public constant TOTAL_AMOUNT_LOWER_THAN_FEE = "IPOR_311";

    
    string public constant COLLATERAL_AMOUNT_TOO_HIGH = "IPOR_312";

    
    string public constant ACCEPTABLE_FIXED_INTEREST_RATE_EXCEEDED = "IPOR_313";

    
    string public constant SWAP_NOTIONAL_HIGHER_THAN_TOTAL_NOTIONAL = "IPOR_314";

    
    string public constant LIQUIDATION_LEG_LIMIT_EXCEEDED = "IPOR_315";

    
    
    string public constant SOAP_AND_LP_BALANCE_SUM_IS_TOO_LOW = "IPOR_316";

    
    string public constant CALC_TIMESTAMP_LOWER_THAN_SOAP_REBALANCE_TIMESTAMP = "IPOR_317";

    
    string public constant CALC_TIMESTAMP_LOWER_THAN_SWAP_OPEN_TIMESTAMP = "IPOR_318";

    
    string public constant CLOSING_TIMESTAMP_LOWER_THAN_SWAP_OPEN_TIMESTAMP = "IPOR_319";

    
    string public constant CANNOT_CLOSE_SWAP_LP_IS_TOO_LOW = "IPOR_320";

    
    string public constant CANNOT_CLOSE_SWAP_SENDER_IS_NOT_BUYER_AND_NO_MATURITY = "IPOR_321";

    
    string public constant INTEREST_FROM_STRATEGY_BELOW_ZERO = "IPOR_322";

    
    string public constant LIQUIDITY_POOL_ACCRUED_IS_EQUAL_ZERO = "IPOR_323";

    
    string public constant SPREAD_EMVAR_CANNOT_BE_HIGHER_THAN_ONE = "IPOR_324";

    
    string public constant SPREAD_ALPHA_CANNOT_BE_HIGHER_THAN_ONE = "IPOR_325";

    
    string public constant PUBLICATION_FEE_BALANCE_IS_TOO_LOW = "IPOR_326";

    
    string public constant CALLER_NOT_JOSEPH = "IPOR_327";

    
    string public constant DEPOSIT_AMOUNT_IS_TOO_LOW = "IPOR_328";

    
    string public constant VAULT_BALANCE_LOWER_THAN_DEPOSIT_VALUE = "IPOR_329";

    
    string public constant TREASURY_BALANCE_IS_TOO_LOW = "IPOR_330";
}

// File: contracts/libraries/errors/IporErrors.sol


pragma solidity 0.8.15;

library IporErrors {
    // 000-199 - general codes

    
    string public constant WRONG_ADDRESS = "IPOR_000";

    
    string public constant WRONG_DECIMALS = "IPOR_001";

    string public constant ADDRESSES_MISMATCH = "IPOR_002";

    //@notice Trader doesnt have enought tokens to execute transaction
    string public constant ASSET_BALANCE_TOO_LOW = "IPOR_003";

    string public constant VALUE_NOT_GREATER_THAN_ZERO = "IPOR_004";

    string public constant INPUT_ARRAYS_LENGTH_MISMATCH = "IPOR_005";

    //@notice Amount is too low to transfer
    string public constant NOT_ENOUGH_AMOUNT_TO_TRANSFER = "IPOR_006";

    //@notice msg.sender is not an appointed owner, so cannot confirm his appointment to be an owner of a specific smart contract
    string public constant SENDER_NOT_APPOINTED_OWNER = "IPOR_007";

    //only milton can have access to function
    string public constant CALLER_NOT_MILTON = "IPOR_008";

    string public constant CHUNK_SIZE_EQUAL_ZERO = "IPOR_009";

    string public constant CHUNK_SIZE_TOO_BIG = "IPOR_010";
}

// File: contracts/interfaces/types/AmmTypes.sol


pragma solidity 0.8.15;



library AmmTypes {
    
    enum SwapState {
        INACTIVE,
        ACTIVE
    }

    
    /// Refer to the documentation https://ipor-labs.gitbook.io/ipor-labs/automated-market-maker/ipor-swaps for more information.
    struct NewSwap {
        
        address buyer;
        
        uint256 openTimestamp;
        
        
        uint256 collateral;
        
        
        uint256 notional;
        
        
        uint256 ibtQuantity;
        
        
        uint256 fixedInterestRate;
        
        /// It can be both trader or community member. Trader receives the deposit back when he chooses to close the derivative before maturity.
        
        uint256 liquidationDepositAmount;
        
        
        uint256 openingFeeLPAmount;
        
        
        uint256 openingFeeTreasuryAmount;
    }

    
    
    struct OpenSwapMoney {
        
        uint256 totalAmount;
        
        uint256 collateral;
        
        uint256 notional;
        
        uint256 openingFeeLPAmount;
        
        
        uint256 openingFeeTreasuryAmount;
        
        uint256 iporPublicationFee;
        
        uint256 liquidationDepositAmount;
    }
}

// File: contracts/amm/libraries/types/AmmMiltonStorageTypes.sol


pragma solidity 0.8.15;



library AmmMiltonStorageTypes {
    struct IporSwap {
        
        uint32 id;
        
        address buyer;
        
        uint32 openTimestamp;
        
        
        /// During removal the last item in the array is switched with the one that just has been removed.
        uint32 idsIndex;
        
        
        uint128 collateral;
        
        
        uint128 notional;
        
        
        uint128 ibtQuantity;
        
        
        uint64 fixedInterestRate;
        
        
        uint32 liquidationDepositAmount;
        
        
        AmmTypes.SwapState state;
    }

    
    /// It describes swaps for a given leg.
    struct IporSwapContainer {
        
        mapping(uint32 => IporSwap) swaps;
        
        mapping(address => uint32[]) ids;
    }

    
    /// Those balances are used in various calculations across the protocol.
    
    struct Balances {
        
        uint128 totalCollateralPayFixed;
        
        uint128 totalCollateralReceiveFixed;
        
        
        uint128 liquidityPool;
        
        uint128 vault;
        
        uint128 iporPublicationFee;
        
        /// this ballance is fed by the income fee and part of the opening fee appointed by the DAO. For more information refer to the documentation:
        /// https://ipor-labs.gitbook.io/ipor-labs/automated-market-maker/ipor-swaps#fees
        uint128 treasury;
    }

    
    
    struct SoapIndicators {
        
        
        uint256 quasiHypotheticalInterestCumulative;
        
        
        uint128 totalNotional;
        
        
        uint128 totalIbtQuantity;
        
        
        uint64 averageInterestRate;
        
        uint32 rebalanceTimestamp;
    }

    
    
    struct SoapIndicatorsMemory {
        
        
        uint256 quasiHypotheticalInterestCumulative;
        
        
        uint256 totalNotional;
        
        
        uint256 totalIbtQuantity;
        
        
        uint256 averageInterestRate;
        
        uint256 rebalanceTimestamp;
    }
}

// File: contracts/interfaces/types/IporTypes.sol


pragma solidity 0.8.15;


library IporTypes {
    
    /// Namely, the interest that would be computed into IBT should the rebalance occur.
    struct AccruedIpor {
        
        
        uint256 indexValue;
        
        /// https://ipor-labs.gitbook.io/ipor-labs/interest-rate-derivatives/ibt
        
        uint256 ibtPrice;
        
        
        uint256 exponentialMovingAverage;
        
        
        uint256 exponentialWeightedMovingVariance;
    }

    
    struct IporSwapMemory {
        
        uint256 id;
        
        address buyer;
        
        uint256 openTimestamp;
        
        uint256 endTimestamp;
        
        
        /// During removal the last item in the array is switched with the one that just has been removed.
        uint256 idsIndex;
        
        
        uint256 collateral;
        
        
        uint256 notional;
        
        
        uint256 ibtQuantity;
        
        
        uint256 fixedInterestRate;
        
        
        uint256 liquidationDepositAmount;
        
        
        uint256 state;
    }

    
    
    struct MiltonBalancesMemory {
        
        uint256 totalCollateralPayFixed;
        
        uint256 totalCollateralReceiveFixed;
        
        
        uint256 liquidityPool;
        
        uint256 vault;
    }
}

// File: contracts/libraries/PaginationUtils.sol


pragma solidity 0.8.15;

library PaginationUtils {
    function resolveResultSetSize(
        uint256 totalSwapNumber,
        uint256 offset,
        uint256 chunkSize
    ) internal pure returns (uint256) {
        uint256 resultSetSize;
        if (offset > totalSwapNumber) {
            resultSetSize = 0;
        } else if (offset + chunkSize < totalSwapNumber) {
            resultSetSize = chunkSize;
        } else {
            resultSetSize = totalSwapNumber - offset;
        }

        return resultSetSize;
    }
}

// File: contracts/libraries/Constants.sol


pragma solidity 0.8.15;

library Constants {
    uint256 public constant MAX_VALUE =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    uint256 public constant D18 = 1e18;
    int256 public constant D18_INT = 1e18;
    uint256 public constant D36 = 1e36;
    uint256 public constant D54 = 1e54;

    uint256 public constant YEAR_IN_SECONDS = 365 days;
    uint256 public constant WAD_YEAR_IN_SECONDS = D18 * YEAR_IN_SECONDS;
    int256 public constant WAD_YEAR_IN_SECONDS_INT = int256(WAD_YEAR_IN_SECONDS);
    uint256 public constant WAD_P2_YEAR_IN_SECONDS = D18 * D18 * YEAR_IN_SECONDS;
    int256 public constant WAD_P2_YEAR_IN_SECONDS_INT = int256(WAD_P2_YEAR_IN_SECONDS);

    uint256 public constant MAX_CHUNK_SIZE = 50;

    //@notice By default every swap takes 28 days, this variable show this value in seconds
    uint256 public constant SWAP_DEFAULT_PERIOD_IN_SECONDS = 60 * 60 * 24 * 28;
}

// File: contracts/interfaces/types/MiltonStorageTypes.sol


pragma solidity 0.8.15;


library MiltonStorageTypes {
    
    
    struct IporSwapId {
        
        uint256 id;
        
        uint8 direction;
    }

    
    
    /// IPOR publication fee balance, treasury balance, all balances are in 18 decimals
    struct ExtendedBalancesMemory {
        
        uint256 totalCollateralPayFixed;
        
        uint256 totalCollateralReceiveFixed;
        
        uint256 liquidityPool;
        
        uint256 vault;
        
        uint256 iporPublicationFee;
        
        uint256 treasury;
    }
}

// File: contracts/interfaces/IMiltonStorage.sol


pragma solidity 0.8.15;





interface IMiltonStorage {
    
    
    function getVersion() external pure returns (uint256);

    
    
    
    function getLastSwapId() external view returns (uint256);

    
    
    /// # Pay Fixed Total Collateral
    /// # Receive Fixed Total Collateral
    /// # Liquidity Pool and Vault balances.
    
    function getBalance() external view returns (IporTypes.MiltonBalancesMemory memory);

    
    
    function getExtendedBalance()
        external
        view
        returns (MiltonStorageTypes.ExtendedBalancesMemory memory);

    
    
    
    function getTotalOutstandingNotional()
        external
        view
        returns (uint256 totalNotionalPayFixed, uint256 totalNotionalReceiveFixed);

    
    
    
    function getSwapPayFixed(uint256 swapId)
        external
        view
        returns (IporTypes.IporSwapMemory memory);

    
    
    
    function getSwapReceiveFixed(uint256 swapId)
        external
        view
        returns (IporTypes.IporSwapMemory memory);

    
    
    
    
    
    
    function getSwapsPayFixed(
        address account,
        uint256 offset,
        uint256 chunkSize
    ) external view returns (uint256 totalCount, IporTypes.IporSwapMemory[] memory swaps);

    
    
    
    
    
    
    function getSwapsReceiveFixed(
        address account,
        uint256 offset,
        uint256 chunkSize
    ) external view returns (uint256 totalCount, IporTypes.IporSwapMemory[] memory swaps);

    
    
    
    
    
    
    function getSwapPayFixedIds(
        address account,
        uint256 offset,
        uint256 chunkSize
    ) external view returns (uint256 totalCount, uint256[] memory ids);

    
    
    
    
    
    
    function getSwapReceiveFixedIds(
        address account,
        uint256 offset,
        uint256 chunkSize
    ) external view returns (uint256 totalCount, uint256[] memory ids);

    
    
    
    
    
    
    function getSwapIds(
        address account,
        uint256 offset,
        uint256 chunkSize
    ) external view returns (uint256 totalCount, MiltonStorageTypes.IporSwapId[] memory ids);

    
    
    
    
    
    
    function calculateSoap(uint256 ibtPrice, uint256 calculateTimestamp)
        external
        view
        returns (
            int256 soapPayFixed,
            int256 soapReceiveFixed,
            int256 soap
        );

    
    
    
    
    function calculateSoapPayFixed(uint256 ibtPrice, uint256 calculateTimestamp)
        external
        view
        returns (int256 soapPayFixed);

    
    
    
    
    function calculateSoapReceiveFixed(uint256 ibtPrice, uint256 calculateTimestamp)
        external
        view
        returns (int256 soapReceiveFixed);

    
    
    
    
    
    function addLiquidity(
        address account,
        uint256 assetAmount,
        uint256 cfgMaxLiquidityPoolBalance,
        uint256 cfgMaxLpAccountContribution
    ) external;

    
    
    function subtractLiquidity(uint256 assetAmount) external;

    
    
    
    
    function updateStorageWhenOpenSwapPayFixed(
        AmmTypes.NewSwap memory newSwap,
        uint256 cfgIporPublicationFee
    ) external returns (uint256);

    
    
    
    
    function updateStorageWhenOpenSwapReceiveFixed(
        AmmTypes.NewSwap memory newSwap,
        uint256 cfgIporPublicationFee
    ) external returns (uint256);

    
    
    
    
    
    
    
    /// position value required to close swap before maturity. Value represented in 18 decimals.
    
    /// maturity after which swap can be closed by anybody not only by swap's buyer.
    function updateStorageWhenCloseSwapPayFixed(
        address liquidator,
        IporTypes.IporSwapMemory memory iporSwap,
        int256 payoff,
        uint256 closingTimestamp,
        uint256 cfgIncomeFeeRate,
        uint256 cfgMinLiquidationThresholdToCloseBeforeMaturity,
        uint256 cfgSecondsToMaturityWhenPositionCanBeClosed
    ) external;

    
    /// Function is only available to Milton.
    
    
    
    
    
    
    /// position value required to close swap before maturity. Value represented in 18 decimals.
    
    /// maturity after which swap can be closed by anybody not only by swap's buyer.
    function updateStorageWhenCloseSwapReceiveFixed(
        address liquidator,
        IporTypes.IporSwapMemory memory iporSwap,
        int256 payoff,
        uint256 incomeFeeValue,
        uint256 closingTimestamp,
        uint256 cfgMinLiquidationThresholdToCloseBeforeMaturity,
        uint256 cfgSecondsToMaturityWhenPositionCanBeClosed
    ) external;

    
    
    
    function updateStorageWhenWithdrawFromStanley(uint256 withdrawnAmount, uint256 vaultBalance)
        external;

    
    
    
    function updateStorageWhenDepositToStanley(uint256 depositAmount, uint256 vaultBalance)
        external;

    
    
    function updateStorageWhenTransferToCharlieTreasury(uint256 transferredAmount) external;

    
    
    function updateStorageWhenTransferToTreasury(uint256 transferredAmount) external;

    
    
    function setMilton(address milton) external;

    
    
    function setJoseph(address joseph) external;

    
    
    function pause() external;

    
    
    function unpause() external;

    
    
    
    
    event MiltonChanged(address changedBy, address oldMilton, address newMilton);

    
    
    
    
    event JosephChanged(address changedBy, address oldJoseph, address newJoseph);
}

// File: @openzeppelin/contracts/utils/math/SafeCast.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248) {
        require(value >= type(int248).min && value <= type(int248).max, "SafeCast: value doesn't fit in 248 bits");
        return int248(value);
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240) {
        require(value >= type(int240).min && value <= type(int240).max, "SafeCast: value doesn't fit in 240 bits");
        return int240(value);
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232) {
        require(value >= type(int232).min && value <= type(int232).max, "SafeCast: value doesn't fit in 232 bits");
        return int232(value);
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224) {
        require(value >= type(int224).min && value <= type(int224).max, "SafeCast: value doesn't fit in 224 bits");
        return int224(value);
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216) {
        require(value >= type(int216).min && value <= type(int216).max, "SafeCast: value doesn't fit in 216 bits");
        return int216(value);
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208) {
        require(value >= type(int208).min && value <= type(int208).max, "SafeCast: value doesn't fit in 208 bits");
        return int208(value);
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200) {
        require(value >= type(int200).min && value <= type(int200).max, "SafeCast: value doesn't fit in 200 bits");
        return int200(value);
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192) {
        require(value >= type(int192).min && value <= type(int192).max, "SafeCast: value doesn't fit in 192 bits");
        return int192(value);
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184) {
        require(value >= type(int184).min && value <= type(int184).max, "SafeCast: value doesn't fit in 184 bits");
        return int184(value);
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176) {
        require(value >= type(int176).min && value <= type(int176).max, "SafeCast: value doesn't fit in 176 bits");
        return int176(value);
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168) {
        require(value >= type(int168).min && value <= type(int168).max, "SafeCast: value doesn't fit in 168 bits");
        return int168(value);
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160) {
        require(value >= type(int160).min && value <= type(int160).max, "SafeCast: value doesn't fit in 160 bits");
        return int160(value);
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152) {
        require(value >= type(int152).min && value <= type(int152).max, "SafeCast: value doesn't fit in 152 bits");
        return int152(value);
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144) {
        require(value >= type(int144).min && value <= type(int144).max, "SafeCast: value doesn't fit in 144 bits");
        return int144(value);
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136) {
        require(value >= type(int136).min && value <= type(int136).max, "SafeCast: value doesn't fit in 136 bits");
        return int136(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120) {
        require(value >= type(int120).min && value <= type(int120).max, "SafeCast: value doesn't fit in 120 bits");
        return int120(value);
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112) {
        require(value >= type(int112).min && value <= type(int112).max, "SafeCast: value doesn't fit in 112 bits");
        return int112(value);
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104) {
        require(value >= type(int104).min && value <= type(int104).max, "SafeCast: value doesn't fit in 104 bits");
        return int104(value);
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96) {
        require(value >= type(int96).min && value <= type(int96).max, "SafeCast: value doesn't fit in 96 bits");
        return int96(value);
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88) {
        require(value >= type(int88).min && value <= type(int88).max, "SafeCast: value doesn't fit in 88 bits");
        return int88(value);
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80) {
        require(value >= type(int80).min && value <= type(int80).max, "SafeCast: value doesn't fit in 80 bits");
        return int80(value);
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72) {
        require(value >= type(int72).min && value <= type(int72).max, "SafeCast: value doesn't fit in 72 bits");
        return int72(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56) {
        require(value >= type(int56).min && value <= type(int56).max, "SafeCast: value doesn't fit in 56 bits");
        return int56(value);
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48) {
        require(value >= type(int48).min && value <= type(int48).max, "SafeCast: value doesn't fit in 48 bits");
        return int48(value);
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40) {
        require(value >= type(int40).min && value <= type(int40).max, "SafeCast: value doesn't fit in 40 bits");
        return int40(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24) {
        require(value >= type(int24).min && value <= type(int24).max, "SafeCast: value doesn't fit in 24 bits");
        return int24(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// File: contracts/amm/libraries/SoapIndicatorLogic.sol


pragma solidity 0.8.15;






library SoapIndicatorLogic {
    using SafeCast for uint256;

    function calculateQuasiSoapPayFixed(
        AmmMiltonStorageTypes.SoapIndicatorsMemory memory si,
        uint256 calculateTimestamp,
        uint256 ibtPrice
    ) internal pure returns (int256) {
        return
            (si.totalIbtQuantity * ibtPrice * Constants.WAD_YEAR_IN_SECONDS).toInt256() -
            (si.totalNotional *
                Constants.WAD_P2_YEAR_IN_SECONDS +
                calculateQuasiHyphoteticalInterestTotal(si, calculateTimestamp)).toInt256();
    }

    
    function calculateQuasiSoapReceiveFixed(
        AmmMiltonStorageTypes.SoapIndicatorsMemory memory si,
        uint256 calculateTimestamp,
        uint256 ibtPrice
    ) internal pure returns (int256) {
        return
            (si.totalNotional *
                Constants.WAD_P2_YEAR_IN_SECONDS +
                calculateQuasiHyphoteticalInterestTotal(si, calculateTimestamp)).toInt256() -
            (si.totalIbtQuantity * ibtPrice * Constants.WAD_YEAR_IN_SECONDS).toInt256();
    }

    function rebalanceWhenOpenSwap(
        AmmMiltonStorageTypes.SoapIndicatorsMemory memory si,
        uint256 rebalanceTimestamp,
        uint256 derivativeNotional,
        uint256 swapFixedInterestRate,
        uint256 derivativeIbtQuantity
    ) internal pure returns (AmmMiltonStorageTypes.SoapIndicatorsMemory memory) {
        uint256 averageInterestRate = calculateAverageInterestRateWhenOpenSwap(
            si.totalNotional,
            si.averageInterestRate,
            derivativeNotional,
            swapFixedInterestRate
        );

        uint256 quasiHypotheticalInterestTotal = calculateQuasiHyphoteticalInterestTotal(
            si,
            rebalanceTimestamp
        );

        si.rebalanceTimestamp = rebalanceTimestamp;
        si.totalNotional = si.totalNotional + derivativeNotional;
        si.totalIbtQuantity = si.totalIbtQuantity + derivativeIbtQuantity;
        si.averageInterestRate = averageInterestRate;
        si.quasiHypotheticalInterestCumulative = quasiHypotheticalInterestTotal;

        return si;
    }

    function rebalanceWhenCloseSwap(
        AmmMiltonStorageTypes.SoapIndicatorsMemory memory si,
        uint256 rebalanceTimestamp,
        uint256 derivativeOpenTimestamp,
        uint256 derivativeNotional,
        uint256 swapFixedInterestRate,
        uint256 derivativeIbtQuantity
    ) internal pure returns (AmmMiltonStorageTypes.SoapIndicatorsMemory memory) {
        uint256 newAverageInterestRate = calculateAverageInterestRateWhenCloseSwap(
            si.totalNotional,
            si.averageInterestRate,
            derivativeNotional,
            swapFixedInterestRate
        );

        if (newAverageInterestRate > 0) {
            uint256 currentQuasiHypoteticalInterestTotal = calculateQuasiHyphoteticalInterestTotal(
                si,
                rebalanceTimestamp
            );

            uint256 quasiInterestPaidOut = calculateQuasiInterestPaidOut(
                rebalanceTimestamp,
                derivativeOpenTimestamp,
                derivativeNotional,
                swapFixedInterestRate
            );

            uint256 quasiHypotheticalInterestTotal = currentQuasiHypoteticalInterestTotal -
                quasiInterestPaidOut;

            si.rebalanceTimestamp = rebalanceTimestamp;
            si.quasiHypotheticalInterestCumulative = quasiHypotheticalInterestTotal;
            si.totalNotional = si.totalNotional - derivativeNotional;
            si.totalIbtQuantity = si.totalIbtQuantity - derivativeIbtQuantity;
            si.averageInterestRate = newAverageInterestRate;
        } else {
            
            si.rebalanceTimestamp = rebalanceTimestamp;
            si.quasiHypotheticalInterestCumulative = 0;
            si.totalNotional = 0;
            si.totalIbtQuantity = 0;
            si.averageInterestRate = 0;
        }

        return si;
    }

    function calculateQuasiInterestPaidOut(
        uint256 calculateTimestamp,
        uint256 derivativeOpenTimestamp,
        uint256 derivativeNotional,
        uint256 swapFixedInterestRate
    ) internal pure returns (uint256) {
        require(
            calculateTimestamp >= derivativeOpenTimestamp,
            MiltonErrors.CALC_TIMESTAMP_LOWER_THAN_SWAP_OPEN_TIMESTAMP
        );
        return
            derivativeNotional *
            swapFixedInterestRate *
            (calculateTimestamp - derivativeOpenTimestamp) *
            Constants.D18;
    }

    function calculateQuasiHyphoteticalInterestTotal(
        AmmMiltonStorageTypes.SoapIndicatorsMemory memory si,
        uint256 calculateTimestamp
    ) internal pure returns (uint256) {
        return
            si.quasiHypotheticalInterestCumulative +
            calculateQuasiHypotheticalInterestDelta(
                calculateTimestamp,
                si.rebalanceTimestamp,
                si.totalNotional,
                si.averageInterestRate
            );
    }

    
    function calculateQuasiHypotheticalInterestDelta(
        uint256 calculateTimestamp,
        uint256 lastRebalanceTimestamp,
        uint256 totalNotional,
        uint256 averageInterestRate
    ) internal pure returns (uint256) {
        require(
            calculateTimestamp >= lastRebalanceTimestamp,
            MiltonErrors.CALC_TIMESTAMP_LOWER_THAN_SOAP_REBALANCE_TIMESTAMP
        );
        return
            totalNotional *
            averageInterestRate *
            (calculateTimestamp - lastRebalanceTimestamp) *
            Constants.D18;
    }

    function calculateAverageInterestRateWhenOpenSwap(
        uint256 totalNotional,
        uint256 averageInterestRate,
        uint256 derivativeNotional,
        uint256 swapFixedInterestRate
    ) internal pure returns (uint256) {
        return
            IporMath.division(
                (totalNotional * averageInterestRate + derivativeNotional * swapFixedInterestRate),
                (totalNotional + derivativeNotional)
            );
    }

    function calculateAverageInterestRateWhenCloseSwap(
        uint256 totalNotional,
        uint256 averageInterestRate,
        uint256 derivativeNotional,
        uint256 swapFixedInterestRate
    ) internal pure returns (uint256) {
        require(
            derivativeNotional <= totalNotional,
            MiltonErrors.SWAP_NOTIONAL_HIGHER_THAN_TOTAL_NOTIONAL
        );
        if (derivativeNotional == totalNotional) {
            return 0;
        } else {
            return
                IporMath.division(
                    (totalNotional *
                        averageInterestRate -
                        derivativeNotional *
                        swapFixedInterestRate),
                    (totalNotional - derivativeNotional)
                );
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/StorageSlotUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

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

// File: @openzeppelin/contracts-upgradeable/proxy/beacon/IBeaconUpgradeable.sol


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

// File: @openzeppelin/contracts-upgradeable/interfaces/draft-IERC1822Upgradeable.sol


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

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


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

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;



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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: contracts/security/IporOwnableUpgradeable.sol


pragma solidity 0.8.15;



contract IporOwnableUpgradeable is OwnableUpgradeable {
    address private _appointedOwner;

    event AppointedToTransferOwnership(address indexed appointedOwner);

    function transferOwnership(address appointedOwner) public override onlyOwner {
        require(appointedOwner != address(0), IporErrors.WRONG_ADDRESS);
        _appointedOwner = appointedOwner;
        emit AppointedToTransferOwnership(appointedOwner);
    }

    function confirmTransferOwnership() public onlyAppointedOwner {
        _appointedOwner = address(0);
        _transferOwnership(_msgSender());
    }

    modifier onlyAppointedOwner() {
        require(_appointedOwner == _msgSender(), IporErrors.SENDER_NOT_APPOINTED_OWNER);
        _;
    }
}

// File: @openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol


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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol


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

// File: contracts/amm/MiltonStorage.sol


pragma solidity 0.8.15;













//@dev all stored valuse related with money are in 18 decimals.
contract MiltonStorage is
    Initializable,
    PausableUpgradeable,
    UUPSUpgradeable,
    IporOwnableUpgradeable,
    IMiltonStorage
{
    using SafeCast for uint256;
    using SoapIndicatorLogic for AmmMiltonStorageTypes.SoapIndicatorsMemory;

    uint32 private _lastSwapId;
    address private _milton;
    address private _joseph;

    AmmMiltonStorageTypes.Balances internal _balances;
    AmmMiltonStorageTypes.SoapIndicators internal _soapIndicatorsPayFixed;
    AmmMiltonStorageTypes.SoapIndicators internal _soapIndicatorsReceiveFixed;
    AmmMiltonStorageTypes.IporSwapContainer internal _swapsPayFixed;
    AmmMiltonStorageTypes.IporSwapContainer internal _swapsReceiveFixed;

    mapping(address => uint128) private _liquidityPoolAccountContribution;

    modifier onlyMilton() {
        require(_msgSender() == _milton, IporErrors.CALLER_NOT_MILTON);
        _;
    }

    modifier onlyJoseph() {
        require(_msgSender() == _joseph, MiltonErrors.CALLER_NOT_JOSEPH);
        _;
    }

    
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function getVersion() external pure virtual override returns (uint256) {
        return 1;
    }

    function getLastSwapId() external view override returns (uint256) {
        return _lastSwapId;
    }

    function getBalance()
        external
        view
        virtual
        override
        returns (IporTypes.MiltonBalancesMemory memory)
    {
        return
            IporTypes.MiltonBalancesMemory(
                _balances.totalCollateralPayFixed,
                _balances.totalCollateralReceiveFixed,
                _balances.liquidityPool,
                _balances.vault
            );
    }

    function getExtendedBalance()
        external
        view
        override
        returns (MiltonStorageTypes.ExtendedBalancesMemory memory)
    {
        return
            MiltonStorageTypes.ExtendedBalancesMemory(
                _balances.totalCollateralPayFixed,
                _balances.totalCollateralReceiveFixed,
                _balances.liquidityPool,
                _balances.vault,
                _balances.iporPublicationFee,
                _balances.treasury
            );
    }

    function getTotalOutstandingNotional()
        external
        view
        override
        returns (uint256 totalNotionalPayFixed, uint256 totalNotionalReceiveFixed)
    {
        totalNotionalPayFixed = _soapIndicatorsPayFixed.totalNotional;
        totalNotionalReceiveFixed = _soapIndicatorsReceiveFixed.totalNotional;
    }

    function getSwapPayFixed(uint256 swapId)
        external
        view
        override
        returns (IporTypes.IporSwapMemory memory)
    {
        uint32 id = swapId.toUint32();
        AmmMiltonStorageTypes.IporSwap storage swap = _swapsPayFixed.swaps[id];
        return
            IporTypes.IporSwapMemory(
                swap.id,
                swap.buyer,
                swap.openTimestamp,
                swap.openTimestamp + Constants.SWAP_DEFAULT_PERIOD_IN_SECONDS,
                swap.idsIndex,
                swap.collateral,
                swap.notional,
                swap.ibtQuantity,
                swap.fixedInterestRate,
                swap.liquidationDepositAmount * Constants.D18,
                uint256(swap.state)
            );
    }

    function getSwapReceiveFixed(uint256 swapId)
        external
        view
        override
        returns (IporTypes.IporSwapMemory memory)
    {
        uint32 id = swapId.toUint32();
        AmmMiltonStorageTypes.IporSwap storage swap = _swapsReceiveFixed.swaps[id];
        return
            IporTypes.IporSwapMemory(
                swap.id,
                swap.buyer,
                swap.openTimestamp,
                swap.openTimestamp + Constants.SWAP_DEFAULT_PERIOD_IN_SECONDS,
                swap.idsIndex,
                swap.collateral,
                swap.notional,
                swap.ibtQuantity,
                swap.fixedInterestRate,
                swap.liquidationDepositAmount * Constants.D18,
                uint256(swap.state)
            );
    }

    function getSwapsPayFixed(
        address account,
        uint256 offset,
        uint256 chunkSize
    ) external view override returns (uint256 totalCount, IporTypes.IporSwapMemory[] memory swaps) {
        uint32[] storage ids = _swapsPayFixed.ids[account];
        return (ids.length, _getPositions(_swapsPayFixed.swaps, ids, offset, chunkSize));
    }

    function getSwapsReceiveFixed(
        address account,
        uint256 offset,
        uint256 chunkSize
    ) external view override returns (uint256 totalCount, IporTypes.IporSwapMemory[] memory swaps) {
        uint32[] storage ids = _swapsReceiveFixed.ids[account];
        return (ids.length, _getPositions(_swapsReceiveFixed.swaps, ids, offset, chunkSize));
    }

    function getSwapPayFixedIds(
        address account,
        uint256 offset,
        uint256 chunkSize
    ) external view override returns (uint256 totalCount, uint256[] memory ids) {
        require(chunkSize > 0, IporErrors.CHUNK_SIZE_EQUAL_ZERO);
        require(chunkSize <= Constants.MAX_CHUNK_SIZE, IporErrors.CHUNK_SIZE_TOO_BIG);

        uint32[] storage idsRef = _swapsPayFixed.ids[account];
        totalCount = idsRef.length;

        uint256 resultSetSize = PaginationUtils.resolveResultSetSize(totalCount, offset, chunkSize);

        ids = new uint256[](resultSetSize);

        for (uint256 i = 0; i != resultSetSize; i++) {
            ids[i] = idsRef[offset + i];
        }
    }

    function getSwapReceiveFixedIds(
        address account,
        uint256 offset,
        uint256 chunkSize
    ) external view override returns (uint256 totalCount, uint256[] memory ids) {
        require(chunkSize > 0, IporErrors.CHUNK_SIZE_EQUAL_ZERO);
        require(chunkSize <= Constants.MAX_CHUNK_SIZE, IporErrors.CHUNK_SIZE_TOO_BIG);

        uint32[] storage idsRef = _swapsReceiveFixed.ids[account];
        totalCount = idsRef.length;

        uint256 resultSetSize = PaginationUtils.resolveResultSetSize(totalCount, offset, chunkSize);

        ids = new uint256[](resultSetSize);

        for (uint256 i = 0; i != resultSetSize; i++) {
            ids[i] = idsRef[offset + i];
        }
    }

    function getSwapIds(
        address account,
        uint256 offset,
        uint256 chunkSize
    )
        external
        view
        override
        returns (uint256 totalCount, MiltonStorageTypes.IporSwapId[] memory ids)
    {
        require(chunkSize > 0, IporErrors.CHUNK_SIZE_EQUAL_ZERO);
        require(chunkSize <= Constants.MAX_CHUNK_SIZE, IporErrors.CHUNK_SIZE_TOO_BIG);

        uint32[] storage payFixedIdsRef = _swapsPayFixed.ids[account];
        uint256 payFixedLength = payFixedIdsRef.length;

        uint32[] storage receiveFixedIdsRef = _swapsReceiveFixed.ids[account];
        uint256 receiveFixedLength = receiveFixedIdsRef.length;

        totalCount = payFixedLength + receiveFixedLength;

        uint256 resultSetSize = PaginationUtils.resolveResultSetSize(totalCount, offset, chunkSize);

        ids = new MiltonStorageTypes.IporSwapId[](resultSetSize);

        for (uint256 i = 0; i != resultSetSize; i++) {
            if (offset + i < payFixedLength) {
                ids[i] = MiltonStorageTypes.IporSwapId(payFixedIdsRef[offset + i], 0);
            } else {
                ids[i] = MiltonStorageTypes.IporSwapId(
                    receiveFixedIdsRef[offset + i - payFixedLength],
                    1
                );
            }
        }
    }

    function calculateSoap(uint256 ibtPrice, uint256 calculateTimestamp)
        external
        view
        override
        returns (
            int256 soapPayFixed,
            int256 soapReceiveFixed,
            int256 soap
        )
    {
        (int256 qSoapPf, int256 qSoapRf, int256 qSoap) = _calculateQuasiSoap(
            ibtPrice,
            calculateTimestamp
        );

        return (
            soapPayFixed = IporMath.divisionInt(qSoapPf, Constants.WAD_P2_YEAR_IN_SECONDS_INT),
            soapReceiveFixed = IporMath.divisionInt(qSoapRf, Constants.WAD_P2_YEAR_IN_SECONDS_INT),
            soap = IporMath.divisionInt(qSoap, Constants.WAD_P2_YEAR_IN_SECONDS_INT)
        );
    }

    function calculateSoapPayFixed(uint256 ibtPrice, uint256 calculateTimestamp)
        external
        view
        override
        returns (int256 soapPayFixed)
    {
        int256 qSoapPf = _calculateQuasiSoapPayFixed(ibtPrice, calculateTimestamp);

        soapPayFixed = IporMath.divisionInt(qSoapPf, Constants.WAD_P2_YEAR_IN_SECONDS_INT);
    }

    function calculateSoapReceiveFixed(uint256 ibtPrice, uint256 calculateTimestamp)
        external
        view
        override
        returns (int256 soapReceiveFixed)
    {
        int256 qSoapRf = _calculateQuasiSoapReceiveFixed(ibtPrice, calculateTimestamp);

        soapReceiveFixed = IporMath.divisionInt(qSoapRf, Constants.WAD_P2_YEAR_IN_SECONDS_INT);
    }

    function addLiquidity(
        address account,
        uint256 assetAmount,
        uint256 cfgMaxLiquidityPoolBalance,
        uint256 cfgMaxLpAccountContribution
    ) external override onlyJoseph {
        require(assetAmount > 0, MiltonErrors.DEPOSIT_AMOUNT_IS_TOO_LOW);

        uint128 newLiquidityPoolBalance = _balances.liquidityPool + assetAmount.toUint128();

        require(
            newLiquidityPoolBalance <= cfgMaxLiquidityPoolBalance,
            MiltonErrors.LIQUIDITY_POOL_BALANCE_IS_TOO_HIGH
        );

        uint128 newLiquidityPoolAccountContribution = _liquidityPoolAccountContribution[account] +
            assetAmount.toUint128();

        require(
            newLiquidityPoolAccountContribution <= cfgMaxLpAccountContribution,
            MiltonErrors.LP_ACCOUNT_CONTRIBUTION_IS_TOO_HIGH
        );

        _balances.liquidityPool = newLiquidityPoolBalance;
        _liquidityPoolAccountContribution[account] = newLiquidityPoolAccountContribution;
    }

    function subtractLiquidity(uint256 assetAmount) external override onlyJoseph {
        _balances.liquidityPool = _balances.liquidityPool - assetAmount.toUint128();
    }

    function updateStorageWhenOpenSwapPayFixed(
        AmmTypes.NewSwap memory newSwap,
        uint256 cfgIporPublicationFee
    ) external override onlyMilton returns (uint256) {
        uint256 id = _updateSwapsWhenOpenPayFixed(newSwap);
        _updateBalancesWhenOpenSwapPayFixed(
            newSwap.collateral,
            newSwap.openingFeeLPAmount,
            newSwap.openingFeeTreasuryAmount,
            cfgIporPublicationFee
        );

        _updateSoapIndicatorsWhenOpenSwapPayFixed(
            newSwap.openTimestamp,
            newSwap.notional,
            newSwap.fixedInterestRate,
            newSwap.ibtQuantity
        );
        return id;
    }

    function updateStorageWhenOpenSwapReceiveFixed(
        AmmTypes.NewSwap memory newSwap,
        uint256 cfgIporPublicationFee
    ) external override onlyMilton returns (uint256) {
        uint256 id = _updateSwapsWhenOpenReceiveFixed(newSwap);
        _updateBalancesWhenOpenSwapReceiveFixed(
            newSwap.collateral,
            newSwap.openingFeeLPAmount,
            newSwap.openingFeeTreasuryAmount,
            cfgIporPublicationFee
        );
        _updateSoapIndicatorsWhenOpenSwapReceiveFixed(
            newSwap.openTimestamp,
            newSwap.notional,
            newSwap.fixedInterestRate,
            newSwap.ibtQuantity
        );
        return id;
    }

    function updateStorageWhenCloseSwapPayFixed(
        address liquidator,
        IporTypes.IporSwapMemory memory iporSwap,
        int256 payoff,
        uint256 incomeFeeValue,
        uint256 closingTimestamp,
        uint256 cfgMinLiquidationThresholdToCloseBeforeMaturity,
        uint256 cfgSecondsBeforeMaturityWhenPositionCanBeClosed
    ) external override onlyMilton {
        _updateSwapsWhenClosePayFixed(iporSwap);
        _updateBalancesWhenCloseSwapPayFixed(
            liquidator,
            iporSwap,
            payoff,
            incomeFeeValue,
            closingTimestamp,
            cfgMinLiquidationThresholdToCloseBeforeMaturity,
            cfgSecondsBeforeMaturityWhenPositionCanBeClosed
        );
        _updateSoapIndicatorsWhenCloseSwapPayFixed(iporSwap, closingTimestamp);
    }

    function updateStorageWhenCloseSwapReceiveFixed(
        address liquidator,
        IporTypes.IporSwapMemory memory iporSwap,
        int256 payoff,
        uint256 incomeFeeValue,
        uint256 closingTimestamp,
        uint256 cfgMinLiquidationThresholdToCloseBeforeMaturity,
        uint256 cfgSecondsBeforeMaturityWhenPositionCanBeClosed
    ) external override onlyMilton {
        _updateSwapsWhenCloseReceiveFixed(iporSwap);
        _updateBalancesWhenCloseSwapReceiveFixed(
            liquidator,
            iporSwap,
            payoff,
            incomeFeeValue,
            closingTimestamp,
            cfgMinLiquidationThresholdToCloseBeforeMaturity,
            cfgSecondsBeforeMaturityWhenPositionCanBeClosed
        );
        _updateSoapIndicatorsWhenCloseSwapReceiveFixed(iporSwap, closingTimestamp);
    }

    function updateStorageWhenWithdrawFromStanley(uint256 withdrawnAmount, uint256 vaultBalance)
        external
        override
        onlyMilton
    {
        uint256 currentVaultBalance = _balances.vault;
        // We nedd this becouse for compound if we deposit and withdraw we could get negative intrest based on rounds
        require(
            vaultBalance + withdrawnAmount >= currentVaultBalance,
            MiltonErrors.INTEREST_FROM_STRATEGY_BELOW_ZERO
        );
        uint256 interest = vaultBalance + withdrawnAmount - currentVaultBalance;

        uint256 liquidityPoolBalance = _balances.liquidityPool + interest;
        _balances.liquidityPool = liquidityPoolBalance.toUint128();
        _balances.vault = vaultBalance.toUint128();
    }

    function updateStorageWhenDepositToStanley(uint256 depositAmount, uint256 vaultBalance)
        external
        override
        onlyMilton
    {
        require(vaultBalance >= depositAmount, MiltonErrors.VAULT_BALANCE_LOWER_THAN_DEPOSIT_VALUE);

        uint256 currentVaultBalance = _balances.vault;

        require(
            currentVaultBalance <= (vaultBalance - depositAmount),
            MiltonErrors.INTEREST_FROM_STRATEGY_BELOW_ZERO
        );
        uint256 interest = currentVaultBalance > 0
            ? (vaultBalance - currentVaultBalance - depositAmount)
            : 0;
        _balances.vault = vaultBalance.toUint128();
        uint256 liquidityPoolBalance = _balances.liquidityPool + interest;
        _balances.liquidityPool = liquidityPoolBalance.toUint128();
    }

    function updateStorageWhenTransferToCharlieTreasury(uint256 transferredAmount)
        external
        override
        onlyJoseph
    {
        require(transferredAmount > 0, IporErrors.NOT_ENOUGH_AMOUNT_TO_TRANSFER);

        uint256 balance = _balances.iporPublicationFee;

        require(transferredAmount <= balance, MiltonErrors.PUBLICATION_FEE_BALANCE_IS_TOO_LOW);

        balance = balance - transferredAmount;

        _balances.iporPublicationFee = balance.toUint128();
    }

    function updateStorageWhenTransferToTreasury(uint256 transferredAmount)
        external
        override
        onlyJoseph
    {
        require(transferredAmount > 0, IporErrors.NOT_ENOUGH_AMOUNT_TO_TRANSFER);

        uint256 balance = _balances.treasury;

        require(transferredAmount <= balance, MiltonErrors.TREASURY_BALANCE_IS_TOO_LOW);

        balance = balance - transferredAmount;

        _balances.treasury = balance.toUint128();
    }

    function setMilton(address newMilton) external override onlyOwner {
        require(newMilton != address(0), IporErrors.WRONG_ADDRESS);
        address oldMilton = _milton;
        _milton = newMilton;
        emit MiltonChanged(_msgSender(), oldMilton, newMilton);
    }

    function setJoseph(address newJoseph) external override onlyOwner {
        require(newJoseph != address(0), IporErrors.WRONG_ADDRESS);
        address oldJoseph = _joseph;
        _joseph = newJoseph;
        emit JosephChanged(_msgSender(), oldJoseph, newJoseph);
    }

    function pause() external override onlyOwner {
        _pause();
    }

    function unpause() external override onlyOwner {
        _unpause();
    }

    function getLiquidityPoolAccountContribution(address account) external view returns (uint256) {
        return _liquidityPoolAccountContribution[account];
    }

    function _getPositions(
        mapping(uint32 => AmmMiltonStorageTypes.IporSwap) storage swaps,
        uint32[] storage ids,
        uint256 offset,
        uint256 chunkSize
    ) internal view returns (IporTypes.IporSwapMemory[] memory) {
        require(chunkSize > 0, IporErrors.CHUNK_SIZE_EQUAL_ZERO);
        require(chunkSize <= Constants.MAX_CHUNK_SIZE, IporErrors.CHUNK_SIZE_TOO_BIG);

        uint256 swapsIdsLength = PaginationUtils.resolveResultSetSize(
            ids.length,
            offset,
            chunkSize
        );
        IporTypes.IporSwapMemory[] memory derivatives = new IporTypes.IporSwapMemory[](
            swapsIdsLength
        );

        for (uint256 i = 0; i != swapsIdsLength; i++) {
            uint32 id = ids[i + offset];
            AmmMiltonStorageTypes.IporSwap storage swap = swaps[id];
            derivatives[i] = IporTypes.IporSwapMemory(
                swap.id,
                swap.buyer,
                swap.openTimestamp,
                swap.openTimestamp + Constants.SWAP_DEFAULT_PERIOD_IN_SECONDS,
                swap.idsIndex,
                swap.collateral,
                swap.notional,
                swap.ibtQuantity,
                swap.fixedInterestRate,
                swap.liquidationDepositAmount * Constants.D18,
                uint256(swaps[id].state)
            );
        }
        return derivatives;
    }

    function _calculateQuasiSoap(uint256 ibtPrice, uint256 calculateTimestamp)
        internal
        view
        returns (
            int256 soapPayFixed,
            int256 soapReceiveFixed,
            int256 soap
        )
    {
        AmmMiltonStorageTypes.SoapIndicatorsMemory memory spf = AmmMiltonStorageTypes
            .SoapIndicatorsMemory(
                _soapIndicatorsPayFixed.quasiHypotheticalInterestCumulative,
                _soapIndicatorsPayFixed.totalNotional,
                _soapIndicatorsPayFixed.totalIbtQuantity,
                _soapIndicatorsPayFixed.averageInterestRate,
                _soapIndicatorsPayFixed.rebalanceTimestamp
            );
        int256 _soapPayFixed = spf.calculateQuasiSoapPayFixed(calculateTimestamp, ibtPrice);

        AmmMiltonStorageTypes.SoapIndicatorsMemory memory srf = AmmMiltonStorageTypes
            .SoapIndicatorsMemory(
                _soapIndicatorsReceiveFixed.quasiHypotheticalInterestCumulative,
                _soapIndicatorsReceiveFixed.totalNotional,
                _soapIndicatorsReceiveFixed.totalIbtQuantity,
                _soapIndicatorsReceiveFixed.averageInterestRate,
                _soapIndicatorsReceiveFixed.rebalanceTimestamp
            );
        int256 _soapReceiveFixed = srf.calculateQuasiSoapReceiveFixed(calculateTimestamp, ibtPrice);

        return (
            soapPayFixed = _soapPayFixed,
            soapReceiveFixed = _soapReceiveFixed,
            soap = _soapPayFixed + _soapReceiveFixed
        );
    }

    function _calculateQuasiSoapPayFixed(uint256 ibtPrice, uint256 calculateTimestamp)
        internal
        view
        returns (int256 soapPayFixed)
    {
        AmmMiltonStorageTypes.SoapIndicatorsMemory memory spf = AmmMiltonStorageTypes
            .SoapIndicatorsMemory(
                _soapIndicatorsPayFixed.quasiHypotheticalInterestCumulative,
                _soapIndicatorsPayFixed.totalNotional,
                _soapIndicatorsPayFixed.totalIbtQuantity,
                _soapIndicatorsPayFixed.averageInterestRate,
                _soapIndicatorsPayFixed.rebalanceTimestamp
            );
        soapPayFixed = spf.calculateQuasiSoapPayFixed(calculateTimestamp, ibtPrice);
    }

    function _calculateQuasiSoapReceiveFixed(uint256 ibtPrice, uint256 calculateTimestamp)
        internal
        view
        returns (int256 soapReceiveFixed)
    {
        AmmMiltonStorageTypes.SoapIndicatorsMemory memory srf = AmmMiltonStorageTypes
            .SoapIndicatorsMemory(
                _soapIndicatorsReceiveFixed.quasiHypotheticalInterestCumulative,
                _soapIndicatorsReceiveFixed.totalNotional,
                _soapIndicatorsReceiveFixed.totalIbtQuantity,
                _soapIndicatorsReceiveFixed.averageInterestRate,
                _soapIndicatorsReceiveFixed.rebalanceTimestamp
            );
        soapReceiveFixed = srf.calculateQuasiSoapReceiveFixed(calculateTimestamp, ibtPrice);
    }

    function _updateBalancesWhenOpenSwapPayFixed(
        uint256 collateral,
        uint256 openingFeeLPAmount,
        uint256 openingFeeTreasuryAmount,
        uint256 cfgIporPublicationFee
    ) internal {
        _balances.totalCollateralPayFixed =
            _balances.totalCollateralPayFixed +
            collateral.toUint128();

        _balances.iporPublicationFee =
            _balances.iporPublicationFee +
            cfgIporPublicationFee.toUint128();

        _balances.liquidityPool = _balances.liquidityPool + openingFeeLPAmount.toUint128();
        _balances.treasury = _balances.treasury + openingFeeTreasuryAmount.toUint128();
    }

    function _updateBalancesWhenOpenSwapReceiveFixed(
        uint256 collateral,
        uint256 openingFeeLPAmount,
        uint256 openingFeeTreasuryAmount,
        uint256 cfgIporPublicationFee
    ) internal {
        _balances.totalCollateralReceiveFixed =
            _balances.totalCollateralReceiveFixed +
            collateral.toUint128();

        _balances.iporPublicationFee =
            _balances.iporPublicationFee +
            cfgIporPublicationFee.toUint128();

        _balances.liquidityPool = _balances.liquidityPool + openingFeeLPAmount.toUint128();
        _balances.treasury = _balances.treasury + openingFeeTreasuryAmount.toUint128();
    }

    function _updateBalancesWhenCloseSwapPayFixed(
        address liquidator,
        IporTypes.IporSwapMemory memory swap,
        int256 payoff,
        uint256 closingTimestamp,
        uint256 cfgIncomeFeeRate,
        uint256 cfgMinLiquidationThresholdToCloseBeforeMaturity,
        uint256 cfgSecondsBeforeMaturityWhenPositionCanBeClosed
    ) internal {
        _updateBalancesWhenCloseSwap(
            liquidator,
            swap,
            payoff,
            closingTimestamp,
            cfgIncomeFeeRate,
            cfgMinLiquidationThresholdToCloseBeforeMaturity,
            cfgSecondsBeforeMaturityWhenPositionCanBeClosed
        );

        _balances.totalCollateralPayFixed =
            _balances.totalCollateralPayFixed -
            swap.collateral.toUint128();
    }

    function _updateBalancesWhenCloseSwapReceiveFixed(
        address liquidator,
        IporTypes.IporSwapMemory memory swap,
        int256 payoff,
        uint256 incomeFeeValue,
        uint256 closingTimestamp,
        uint256 cfgMinLiquidationThresholdToCloseBeforeMaturity,
        uint256 cfgSecondsBeforeMaturityWhenPositionCanBeClosed
    ) internal {
        _updateBalancesWhenCloseSwap(
            liquidator,
            swap,
            payoff,
            incomeFeeValue,
            closingTimestamp,
            cfgMinLiquidationThresholdToCloseBeforeMaturity,
            cfgSecondsBeforeMaturityWhenPositionCanBeClosed
        );

        _balances.totalCollateralReceiveFixed =
            _balances.totalCollateralReceiveFixed -
            swap.collateral.toUint128();
    }

    function _updateBalancesWhenCloseSwap(
        address liquidator,
        IporTypes.IporSwapMemory memory swap,
        int256 payoff,
        uint256 incomeFeeValue,
        uint256 closingTimestamp,
        uint256 cfgMinLiquidationThresholdToCloseBeforeMaturity,
        uint256 cfgSecondsBeforeMaturityWhenPositionCanBeClosed
    ) internal {
        uint256 absPayoff = IporMath.absoluteValue(payoff);
        uint256 minPayoffToCloseBeforeMaturity = IporMath.percentOf(
            swap.collateral,
            cfgMinLiquidationThresholdToCloseBeforeMaturity
        );
        if (absPayoff < minPayoffToCloseBeforeMaturity) {
            //verify if sender is an owner of swap if not then check if maturity - if not then reject,
            //if yes then close even if not an owner
            if (liquidator != swap.buyer) {
                require(
                    closingTimestamp >=
                        swap.endTimestamp - cfgSecondsBeforeMaturityWhenPositionCanBeClosed,
                    MiltonErrors.CANNOT_CLOSE_SWAP_SENDER_IS_NOT_BUYER_AND_NO_MATURITY
                );
            }
        }

        _balances.treasury = _balances.treasury + incomeFeeValue.toUint128();

        if (payoff > 0) {
            require(
                _balances.liquidityPool >= absPayoff,
                MiltonErrors.CANNOT_CLOSE_SWAP_LP_IS_TOO_LOW
            );

            _balances.liquidityPool = _balances.liquidityPool - absPayoff.toUint128();
        } else {
            _balances.liquidityPool =
                _balances.liquidityPool +
                (absPayoff - incomeFeeValue).toUint128();
        }
    }

    function _updateSwapsWhenOpenPayFixed(AmmTypes.NewSwap memory newSwap)
        internal
        returns (uint256)
    {
        _lastSwapId++;
        uint32 id = _lastSwapId;

        AmmMiltonStorageTypes.IporSwap storage swap = _swapsPayFixed.swaps[id];

        swap.id = id;
        swap.buyer = newSwap.buyer;
        swap.openTimestamp = newSwap.openTimestamp.toUint32();
        swap.idsIndex = _swapsPayFixed.ids[newSwap.buyer].length.toUint32();
        swap.collateral = newSwap.collateral.toUint128();
        swap.notional = newSwap.notional.toUint128();
        swap.ibtQuantity = newSwap.ibtQuantity.toUint128();
        swap.fixedInterestRate = newSwap.fixedInterestRate.toUint64();
        swap.liquidationDepositAmount = newSwap.liquidationDepositAmount.toUint32();
        swap.state = AmmTypes.SwapState.ACTIVE;

        _swapsPayFixed.ids[newSwap.buyer].push(id);
        _lastSwapId = id;

        return id;
    }

    function _updateSwapsWhenOpenReceiveFixed(AmmTypes.NewSwap memory newSwap)
        internal
        returns (uint256)
    {
        _lastSwapId++;
        uint32 id = _lastSwapId;

        AmmMiltonStorageTypes.IporSwap storage swap = _swapsReceiveFixed.swaps[id];

        swap.id = id;
        swap.buyer = newSwap.buyer;
        swap.openTimestamp = newSwap.openTimestamp.toUint32();
        swap.idsIndex = _swapsReceiveFixed.ids[newSwap.buyer].length.toUint32();
        swap.collateral = newSwap.collateral.toUint128();
        swap.notional = newSwap.notional.toUint128();
        swap.ibtQuantity = newSwap.ibtQuantity.toUint128();
        swap.fixedInterestRate = newSwap.fixedInterestRate.toUint64();
        swap.liquidationDepositAmount = newSwap.liquidationDepositAmount.toUint32();
        swap.state = AmmTypes.SwapState.ACTIVE;

        _swapsReceiveFixed.ids[newSwap.buyer].push(id);
        _lastSwapId = id;

        return id;
    }

    function _updateSwapsWhenClosePayFixed(IporTypes.IporSwapMemory memory iporSwap) internal {
        require(iporSwap.id > 0, MiltonErrors.INCORRECT_SWAP_ID);
        require(
            iporSwap.state != uint256(AmmTypes.SwapState.INACTIVE),
            MiltonErrors.INCORRECT_SWAP_STATUS
        );

        uint32 idsIndexToDelete = iporSwap.idsIndex.toUint32();
        address buyer = iporSwap.buyer;
        uint256 idsLength = _swapsPayFixed.ids[buyer].length - 1;
        if (idsIndexToDelete < idsLength) {
            uint32 accountDerivativeIdToMove = _swapsPayFixed.ids[buyer][idsLength];

            _swapsPayFixed.swaps[accountDerivativeIdToMove].idsIndex = idsIndexToDelete;

            _swapsPayFixed.ids[buyer][idsIndexToDelete] = accountDerivativeIdToMove;
        }

        _swapsPayFixed.swaps[iporSwap.id.toUint32()].state = AmmTypes.SwapState.INACTIVE;
        _swapsPayFixed.ids[buyer].pop();
    }

    function _updateSwapsWhenCloseReceiveFixed(IporTypes.IporSwapMemory memory iporSwap) internal {
        require(iporSwap.id > 0, MiltonErrors.INCORRECT_SWAP_ID);
        require(
            iporSwap.state != uint256(AmmTypes.SwapState.INACTIVE),
            MiltonErrors.INCORRECT_SWAP_STATUS
        );

        uint32 idsIndexToDelete = iporSwap.idsIndex.toUint32();
        address buyer = iporSwap.buyer;
        uint256 idsLength = _swapsReceiveFixed.ids[buyer].length - 1;

        if (idsIndexToDelete < idsLength) {
            uint32 accountDerivativeIdToMove = _swapsReceiveFixed.ids[buyer][idsLength];

            _swapsReceiveFixed.swaps[accountDerivativeIdToMove].idsIndex = idsIndexToDelete;

            _swapsReceiveFixed.ids[buyer][idsIndexToDelete] = accountDerivativeIdToMove;
        }

        _swapsReceiveFixed.swaps[iporSwap.id.toUint32()].state = AmmTypes.SwapState.INACTIVE;
        _swapsReceiveFixed.ids[buyer].pop();
    }

    function _updateSoapIndicatorsWhenOpenSwapPayFixed(
        uint256 openTimestamp,
        uint256 notional,
        uint256 fixedInterestRate,
        uint256 ibtQuantity
    ) internal {
        AmmMiltonStorageTypes.SoapIndicatorsMemory memory pf = AmmMiltonStorageTypes
            .SoapIndicatorsMemory(
                _soapIndicatorsPayFixed.quasiHypotheticalInterestCumulative,
                _soapIndicatorsPayFixed.totalNotional,
                _soapIndicatorsPayFixed.totalIbtQuantity,
                _soapIndicatorsPayFixed.averageInterestRate,
                _soapIndicatorsPayFixed.rebalanceTimestamp
            );

        pf.rebalanceWhenOpenSwap(openTimestamp, notional, fixedInterestRate, ibtQuantity);

        _soapIndicatorsPayFixed.rebalanceTimestamp = pf.rebalanceTimestamp.toUint32();
        _soapIndicatorsPayFixed.totalNotional = pf.totalNotional.toUint128();
        _soapIndicatorsPayFixed.averageInterestRate = pf.averageInterestRate.toUint64();
        _soapIndicatorsPayFixed.totalIbtQuantity = pf.totalIbtQuantity.toUint128();
        _soapIndicatorsPayFixed.quasiHypotheticalInterestCumulative = pf
            .quasiHypotheticalInterestCumulative;
    }

    function _updateSoapIndicatorsWhenOpenSwapReceiveFixed(
        uint256 openTimestamp,
        uint256 notional,
        uint256 fixedInterestRate,
        uint256 ibtQuantity
    ) internal {
        AmmMiltonStorageTypes.SoapIndicatorsMemory memory rf = AmmMiltonStorageTypes
            .SoapIndicatorsMemory(
                _soapIndicatorsReceiveFixed.quasiHypotheticalInterestCumulative,
                _soapIndicatorsReceiveFixed.totalNotional,
                _soapIndicatorsReceiveFixed.totalIbtQuantity,
                _soapIndicatorsReceiveFixed.averageInterestRate,
                _soapIndicatorsReceiveFixed.rebalanceTimestamp
            );
        rf.rebalanceWhenOpenSwap(openTimestamp, notional, fixedInterestRate, ibtQuantity);

        _soapIndicatorsReceiveFixed.rebalanceTimestamp = rf.rebalanceTimestamp.toUint32();
        _soapIndicatorsReceiveFixed.totalNotional = rf.totalNotional.toUint128();
        _soapIndicatorsReceiveFixed.averageInterestRate = rf.averageInterestRate.toUint64();
        _soapIndicatorsReceiveFixed.totalIbtQuantity = rf.totalIbtQuantity.toUint128();
        _soapIndicatorsReceiveFixed.quasiHypotheticalInterestCumulative = rf
            .quasiHypotheticalInterestCumulative;
    }

    function _updateSoapIndicatorsWhenCloseSwapPayFixed(
        IporTypes.IporSwapMemory memory swap,
        uint256 closingTimestamp
    ) internal {
        AmmMiltonStorageTypes.SoapIndicatorsMemory memory pf = AmmMiltonStorageTypes
            .SoapIndicatorsMemory(
                _soapIndicatorsPayFixed.quasiHypotheticalInterestCumulative,
                _soapIndicatorsPayFixed.totalNotional,
                _soapIndicatorsPayFixed.totalIbtQuantity,
                _soapIndicatorsPayFixed.averageInterestRate,
                _soapIndicatorsPayFixed.rebalanceTimestamp
            );

        pf.rebalanceWhenCloseSwap(
            closingTimestamp,
            swap.openTimestamp,
            swap.notional,
            swap.fixedInterestRate,
            swap.ibtQuantity
        );

        _soapIndicatorsPayFixed = AmmMiltonStorageTypes.SoapIndicators(
            pf.quasiHypotheticalInterestCumulative,
            pf.totalNotional.toUint128(),
            pf.totalIbtQuantity.toUint128(),
            pf.averageInterestRate.toUint64(),
            pf.rebalanceTimestamp.toUint32()
        );
    }

    function _updateSoapIndicatorsWhenCloseSwapReceiveFixed(
        IporTypes.IporSwapMemory memory swap,
        uint256 closingTimestamp
    ) internal {
        AmmMiltonStorageTypes.SoapIndicatorsMemory memory rf = AmmMiltonStorageTypes
            .SoapIndicatorsMemory(
                _soapIndicatorsReceiveFixed.quasiHypotheticalInterestCumulative,
                _soapIndicatorsReceiveFixed.totalNotional,
                _soapIndicatorsReceiveFixed.totalIbtQuantity,
                _soapIndicatorsReceiveFixed.averageInterestRate,
                _soapIndicatorsReceiveFixed.rebalanceTimestamp
            );

        rf.rebalanceWhenCloseSwap(
            closingTimestamp,
            swap.openTimestamp,
            swap.notional,
            swap.fixedInterestRate,
            swap.ibtQuantity
        );

        _soapIndicatorsReceiveFixed = AmmMiltonStorageTypes.SoapIndicators(
            rf.quasiHypotheticalInterestCumulative,
            rf.totalNotional.toUint128(),
            rf.totalIbtQuantity.toUint128(),
            rf.averageInterestRate.toUint64(),
            rf.rebalanceTimestamp.toUint32()
        );
    }

    //solhint-disable no-empty-blocks
    function _authorizeUpgrade(address) internal override onlyOwner {}
}

contract MiltonStorageUsdt is MiltonStorage {}

contract MiltonStorageUsdc is MiltonStorage {}

contract MiltonStorageDai is MiltonStorage {}