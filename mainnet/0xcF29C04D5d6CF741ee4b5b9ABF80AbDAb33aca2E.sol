// SPDX-License-Identifier: MIT
pragma abicoder v2;


// 
pragma solidity >=0.7.0;

contract DSMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x - y <= x ? x - y : 0;
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    uint256 internal constant WAD = 10**18;
    uint256 internal constant RAY = 10**27;

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
}
// 
pragma solidity >=0.8.0;



contract Helpers is DSMath {
    
    NotionalInterface internal constant notional = NotionalInterface(0x1344A36A1B56144C3Bc62E7757377D288fDE0369);
}
// 
pragma solidity >=0.8.0;





contract Resolver is Helpers {
    
    
    function getAccount(address account)
        external
        view
        returns (
            AccountContext memory accountContext,
            AccountBalance[] memory accountBalances,
            PortfolioAsset[] memory portfolio
        )
    {
        return notional.getAccount(account);
    }

    
    /// asset cash amounts
    
    function getFreeCollateral(address account) external view returns (int256, int256[] memory) {
        return notional.getFreeCollateral(account);
    }

    
    
    
    function getCurrencyAndRates(uint16 currencyId)
        external
        view
        returns (
            Token memory assetToken,
            Token memory underlyingToken,
            ETHRate memory ethRate,
            AssetRateParameters memory assetRate
        )
    {
        return notional.getCurrencyAndRates(currencyId);
    }

    
    
    
    function getSettlementRate(uint16 currencyId, uint40 maturity) external view returns (AssetRateParameters memory) {
        return notional.getSettlementRate(currencyId, maturity);
    }

    
    
    function getActiveMarkets(uint16 currencyId) external view returns (MarketParameters[] memory) {
        return notional.getActiveMarkets(currencyId);
    }

    
    
    
    
    function nTokenGetClaimableIncentives(address account, uint256 blockTime) external view returns (uint256) {
        return notional.nTokenGetClaimableIncentives(account, blockTime);
    }

    
    
    
    function calculateNTokensToMint(uint16 currencyId, uint88 amountToDepositExternalPrecision)
        external
        view
        returns (uint256)
    {
        return notional.calculateNTokensToMint(currencyId, amountToDepositExternalPrecision);
    }

    
    
    
    /// what is returned by the balanceOf selector (not scaledBalanceOf).
    
    
    
    
    
    
    
    function getfCashLendFromDeposit(
        uint16 currencyId,
        uint256 depositAmountExternal,
        uint256 maturity,
        uint32 minLendRate,
        uint256 blockTime,
        bool useUnderlying
    )
        external
        view
        returns (
            uint88 fCashAmount,
            uint8 marketIndex,
            bytes32 encodedTrade
        )
    {
        return
            notional.getfCashLendFromDeposit(
                currencyId,
                depositAmountExternal,
                maturity,
                minLendRate,
                blockTime,
                useUnderlying
            );
    }

    
    
    
    /// what is returned by the balanceOf selector (not scaledBalanceOf).
    
    
    
    
    
    /// balance in Notional
    
    
    function getfCashBorrowFromPrincipal(
        uint16 currencyId,
        uint256 borrowedAmountExternal,
        uint256 maturity,
        uint32 maxBorrowRate,
        uint256 blockTime,
        bool useUnderlying
    )
        external
        view
        returns (
            uint88 fCashDebt,
            uint8 marketIndex,
            bytes32 encodedTrade
        )
    {
        return
            notional.getfCashBorrowFromPrincipal(
                currencyId,
                borrowedAmountExternal,
                maturity,
                maxBorrowRate,
                blockTime,
                useUnderlying
            );
    }

    
    /// trade, deposit either underlying or asset tokens (not both). Asset tokens tend to be more gas efficient.
    
    
    
    
    
    
    
    
    
    function getDepositFromfCashLend(
        uint16 currencyId,
        uint256 fCashAmount,
        uint256 maturity,
        uint32 minLendRate,
        uint256 blockTime
    )
        external
        view
        returns (
            uint256 depositAmountUnderlying,
            uint256 depositAmountAsset,
            uint8 marketIndex,
            bytes32 encodedTrade
        )
    {
        return notional.getDepositFromfCashLend(currencyId, fCashAmount, maturity, minLendRate, blockTime);
    }

    
    /// trade, choose to receive either underlying or asset tokens (not both). Asset tokens tend to be more gas efficient.
    
    
    
    
    
    
    
    
    
    function getPrincipalFromfCashBorrow(
        uint16 currencyId,
        uint256 fCashBorrow,
        uint256 maturity,
        uint32 maxBorrowRate,
        uint256 blockTime
    )
        external
        view
        returns (
            uint256 borrowAmountUnderlying,
            uint256 borrowAmountAsset,
            uint8 marketIndex,
            bytes32 encodedTrade
        )
    {
        return notional.getPrincipalFromfCashBorrow(currencyId, fCashBorrow, maturity, maxBorrowRate, blockTime);
    }

    
    
    
    
    
    function convertCashBalanceToExternal(
        uint16 currencyId,
        int256 cashBalanceInternal,
        bool convertToUnderlying
    ) external view returns (int256) {
        return notional.convertCashBalanceToExternal(currencyId, cashBalanceInternal, convertToUnderlying);
    }
}

contract InstaNotionalResolver is Resolver {
    string public constant name = "Notional-Resolver-v1";
}

// 
pragma solidity >=0.8.0;


enum AssetStorageState {
    NoChange,
    Update,
    Delete,
    RevertIfStored
}


///  - UnderlyingToken: underlying asset for a cToken (except for Ether)
///  - cToken: Compound interest bearing token
///  - cETH: Special handling for cETH tokens
///  - Ether: the one and only
///  - NonMintable: tokens that do not have an underlying (therefore not cTokens)
///  - aToken: Aave interest bearing tokens
enum TokenType {
    UnderlyingToken,
    cToken,
    cETH,
    Ether,
    NonMintable,
    aToken
}


/// free collateral actions. Total storage is 28 bytes
struct AccountContext {
    // Used to check when settlement must be triggered on an account
    uint40 nextSettleTime;
    // For lenders that never incur debt, we use this flag to skip the free collateral check.
    bytes1 hasDebt;
    // Length of the account's asset array
    uint8 assetArrayLength;
    // If this account has bitmaps set, this is the corresponding currency id
    uint16 bitmapCurrencyId;
    // 9 total active currencies possible (2 bytes each)
    bytes18 activeCurrencies;
}


struct AccountBalance {
    uint16 currencyId;
    int256 cashBalance;
    int256 nTokenBalance;
    uint256 lastClaimTime;
    uint256 lastClaimIntegralSupply;
}


struct PortfolioAsset {
    // Asset currency id
    uint256 currencyId;
    uint256 maturity;
    // Asset type, fCash or liquidity token.
    uint256 assetType;
    // fCash amount or liquidity token amount
    int256 notional;
    // Used for managing portfolio asset state
    uint256 storageSlot;
    // The state of the asset for when it is written to storage
    AssetStorageState storageState;
}


struct Token {
    address tokenAddress;
    bool hasTransferFee;
    int256 decimals;
    TokenType tokenType;
    uint256 maxCollateralBalance;
}


struct ETHRate {
    // The decimals (i.e. 10^rateDecimalPlaces) of the exchange rate, defined by the rate oracle
    int256 rateDecimals;
    // The exchange rate from base to ETH (if rate invert is required it is already done)
    int256 rate;
    // Amount of buffer as a multiple with a basis of 100 applied to negative balances.
    int256 buffer;
    // Amount of haircut as a multiple with a basis of 100 applied to positive balances
    int256 haircut;
    // Liquidation discount as a multiple with a basis of 100 applied to the exchange rate
    // as an incentive given to liquidators.
    int256 liquidationDiscount;
}


struct AssetRateParameters {
    // Address of the asset rate oracle
    AssetRateAdapter rateOracle;
    // The exchange rate from base to quote (if invert is required it is already done)
    int256 rate;
    // The decimals of the underlying, the rate converts to the underlying decimals
    int256 underlyingDecimals;
}


struct MarketParameters {
    bytes32 storageSlot;
    uint256 maturity;
    // Total amount of fCash available for purchase in the market.
    int256 totalfCash;
    // Total amount of cash available for purchase in the market.
    int256 totalAssetCash;
    // Total amount of liquidity tokens (representing a claim on liquidity) in the market.
    int256 totalLiquidity;
    // This is the previous annualized interest rate in RATE_PRECISION that the market traded
    // at. This is used to calculate the rate anchor to smooth interest rates over time.
    uint256 lastImpliedRate;
    // Time lagged version of lastImpliedRate, used to value fCash assets at market rates while
    // remaining resistent to flash loan attacks.
    uint256 oracleRate;
    // This is the timestamp of the previous trade
    uint256 previousTradeTime;
}


/// underlying token. Follows the cToken interface, however, can be adapted
/// for other interest bearing tokens.
interface AssetRateAdapter {
    function token() external view returns (address);

    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function underlying() external view returns (address);

    function getExchangeRateStateful() external returns (int256);

    function getExchangeRateView() external view returns (int256);

    function getAnnualizedSupplyRate() external view returns (uint256);
}


interface NotionalInterface {
    function getAccount(address account)
        external
        view
        returns (
            AccountContext memory accountContext,
            AccountBalance[] memory accountBalances,
            PortfolioAsset[] memory portfolio
        );

    function getFreeCollateral(address account) external view returns (int256, int256[] memory);

    function getCurrencyAndRates(uint16 currencyId)
        external
        view
        returns (
            Token memory assetToken,
            Token memory underlyingToken,
            ETHRate memory ethRate,
            AssetRateParameters memory assetRate
        );

    function getSettlementRate(uint16 currencyId, uint40 maturity) external view returns (AssetRateParameters memory);

    function getActiveMarkets(uint16 currencyId) external view returns (MarketParameters[] memory);

    function nTokenGetClaimableIncentives(address account, uint256 blockTime) external view returns (uint256);

    function calculateNTokensToMint(uint16 currencyId, uint88 amountToDepositExternalPrecision)
        external
        view
        returns (uint256);

    function getfCashLendFromDeposit(
        uint16 currencyId,
        uint256 depositAmountExternal,
        uint256 maturity,
        uint32 minLendRate,
        uint256 blockTime,
        bool useUnderlying
    )
        external
        view
        returns (
            uint88 fCashAmount,
            uint8 marketIndex,
            bytes32 encodedTrade
        );

    function getfCashBorrowFromPrincipal(
        uint16 currencyId,
        uint256 borrowedAmountExternal,
        uint256 maturity,
        uint32 maxBorrowRate,
        uint256 blockTime,
        bool useUnderlying
    )
        external
        view
        returns (
            uint88 fCashDebt,
            uint8 marketIndex,
            bytes32 encodedTrade
        );

    function getDepositFromfCashLend(
        uint16 currencyId,
        uint256 fCashAmount,
        uint256 maturity,
        uint32 minLendRate,
        uint256 blockTime
    )
        external
        view
        returns (
            uint256 depositAmountUnderlying,
            uint256 depositAmountAsset,
            uint8 marketIndex,
            bytes32 encodedTrade
        );

    function getPrincipalFromfCashBorrow(
        uint16 currencyId,
        uint256 fCashBorrow,
        uint256 maturity,
        uint32 maxBorrowRate,
        uint256 blockTime
    )
        external
        view
        returns (
            uint256 borrowAmountUnderlying,
            uint256 borrowAmountAsset,
            uint8 marketIndex,
            bytes32 encodedTrade
        );

    function convertCashBalanceToExternal(
        uint16 currencyId,
        int256 cashBalanceInternal,
        bool useUnderlying
    ) external view returns (int256);
}
