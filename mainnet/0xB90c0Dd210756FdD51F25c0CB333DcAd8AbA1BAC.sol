// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
}

// 
pragma solidity 0.8.9;

interface IClearpoolLens {
    
    struct MarketData {
        address tokenAddress;
        uint256 value;
    }

    
    
    
    function getSupplyRatesIndexesByMarkets(address[] calldata markets)
        external
        view
        returns (MarketData[] memory rates);

    
    
    
    function getBorrowRatesIndexesByMarkets(address[] calldata markets)
        external
        view
        returns (MarketData[] memory rates);

    
    
    
    function getTotalLiquidityByMarkets(address[] calldata markets)
        external
        view
        returns (MarketData[] memory liquidity);

    
    
    
    function getTotalInterestsByMarkets(address[] calldata markets)
        external
        view
        returns (MarketData[] memory interests);

    
    
    
    function getTotalBorrowsByMarkets(address[] calldata markets)
        external
        view
        returns (MarketData[] memory borrows);

    
    
    
    function getTotalPrincipalsByMarkets(address[] calldata markets)
        external
        view
        returns (MarketData[] memory principals);

    
    
    
    function getTotalReservesByMarkets(address[] calldata markets)
        external
        view
        returns (MarketData[] memory reserves);

    
    
    
    
    function getPoolCpoolApr(address poolAddress, uint256 cpoolPrice)
        external
        view
        returns (uint256 apr);

    
    
    
    function getAprIndexByMarket(address[] calldata markets, uint256 cpoolPrice)
        external
        view
        returns (MarketData[] memory currencyApr, MarketData[] memory cpoolApr);
}
// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
pragma solidity 0.8.9;






contract ClearpoolLens is IClearpoolLens {
    
    IPoolFactory public factory;

    
    uint256 public constant SECONDS_PER_YEAR = 31536000;

    
    
    constructor(IPoolFactory factory_) {
        factory = factory_;
    }

    
    
    
    function getSupplyRatesIndexesByMarkets(address[] calldata markets)
        external
        view
        returns (MarketData[] memory rates)
    {
        rates = new MarketData[](markets.length);
        for (uint256 i = 0; i < markets.length; i++) {
            address market = markets[i];

            uint256 rate;
            uint256 totalPoolSize;

            address[] memory pools = factory.getPoolsByMarket(market);
            uint256 poolCount = pools.length;
            for (uint256 j = 0; j < poolCount; j++) {
                IPoolMaster pool = IPoolMaster(pools[j]);
                uint256 poolSize = pool.poolSize();

                totalPoolSize += poolSize;
                rate += pool.getSupplyRate() * poolSize;
            }
            rate /= totalPoolSize;
            rates[i] = MarketData(market, rate);
        }
    }

    
    
    
    function getBorrowRatesIndexesByMarkets(address[] calldata markets)
        external
        view
        returns (MarketData[] memory rates)
    {
        rates = new MarketData[](markets.length);

        for (uint256 i = 0; i < markets.length; i++) {
            address market = markets[i];

            uint256 rate;
            uint256 totalPoolSize;

            address[] memory pools = factory.getPoolsByMarket(market);
            uint256 poolCount = pools.length;
            for (uint256 j = 0; j < poolCount; j++) {
                IPoolMaster pool = IPoolMaster(pools[j]);

                uint256 poolSize = pool.poolSize();

                totalPoolSize += poolSize;
                rate += pool.getBorrowRate() * poolSize;
            }
            rate /= totalPoolSize;

            rates[i] = MarketData(market, rate);
        }
    }

    
    
    
    function getTotalLiquidityByMarkets(address[] calldata markets)
        external
        view
        returns (MarketData[] memory liquidity)
    {
        liquidity = new MarketData[](markets.length);
        for (uint256 i = 0; i < markets.length; i++) {
            address market = markets[i];

            uint256 poolsLiquidity;

            address[] memory pools = factory.getPoolsByMarket(market);
            uint256 poolCount = pools.length;
            for (uint256 j = 0; j < poolCount; j++) {
                IPoolMaster pool = IPoolMaster(pools[j]);
                poolsLiquidity +=
                    pool.cash() +
                    pool.borrows() -
                    pool.insurance() -
                    pool.reserves();
            }
            liquidity[i] = MarketData(market, poolsLiquidity);
        }
    }

    
    
    
    function getTotalInterestsByMarkets(address[] calldata markets)
        external
        view
        returns (MarketData[] memory interests)
    {
        interests = new MarketData[](markets.length);
        for (uint256 i = 0; i < markets.length; i++) {
            address market = markets[i];

            uint256 poolsInterests;

            address[] memory pools = factory.getPoolsByMarket(market);
            uint256 poolCount = pools.length;
            for (uint256 j = 0; j < poolCount; j++) {
                IPoolMaster pool = IPoolMaster(pools[j]);

                poolsInterests += pool.interest();
            }
            interests[i] = MarketData(markets[i], poolsInterests);
        }
    }

    
    
    
    function getTotalBorrowsByMarkets(address[] calldata markets)
        external
        view
        returns (MarketData[] memory borrows)
    {
        borrows = new MarketData[](markets.length);
        for (uint256 i = 0; i < markets.length; i++) {
            address market = markets[i];

            uint256 poolsBorrows;

            address[] memory pools = factory.getPoolsByMarket(market);
            uint256 poolCount = pools.length;
            for (uint256 j = 0; j < poolCount; j++) {
                IPoolMaster pool = IPoolMaster(pools[j]);

                poolsBorrows += pool.borrows();
            }
            borrows[i] = MarketData(markets[i], poolsBorrows);
        }
    }

    
    
    
    function getTotalPrincipalsByMarkets(address[] calldata markets)
        external
        view
        returns (MarketData[] memory principals)
    {
        principals = new MarketData[](markets.length);
        for (uint256 i = 0; i < markets.length; i++) {
            address market = markets[i];

            uint256 poolsPrincipals;

            address[] memory pools = factory.getPoolsByMarket(market);
            uint256 poolCount = pools.length;
            for (uint256 j = 0; j < poolCount; j++) {
                IPoolMaster pool = IPoolMaster(pools[j]);

                poolsPrincipals += pool.principal();
            }
            principals[i] = MarketData(markets[i], poolsPrincipals);
        }
    }

    
    
    
    function getTotalReservesByMarkets(address[] calldata markets)
        external
        view
        returns (MarketData[] memory reserves)
    {
        reserves = new MarketData[](markets.length);
        for (uint256 i = 0; i < markets.length; i++) {
            address market = markets[i];

            uint256 poolsReserves;

            address[] memory pools = factory.getPoolsByMarket(market);
            uint256 poolCount = pools.length;
            for (uint256 j = 0; j < poolCount; j++) {
                IPoolMaster pool = IPoolMaster(pools[j]);

                poolsReserves += pool.reserves();
            }
            reserves[i] = MarketData(markets[i], poolsReserves);
        }
    }

    
    function _toWei(uint256 value, uint256 decimals)
        internal
        pure
        returns (uint256)
    {
        return value * 10**(18 - decimals);
    }

    
    
    
    
    function getPoolCpoolApr(address poolAddress, uint256 cpoolPrice)
        public
        view
        returns (uint256 apr)
    {
        IPoolMaster pool = IPoolMaster(poolAddress);

        uint256 poolDecimals = IERC20MetadataUpgradeable(pool.currency())
            .decimals();

        uint256 totalSupply = _toWei(pool.totalSupply(), poolDecimals);
        if (totalSupply == 0) {
            return 0; // prevent division by 0
        }
        
        uint256 exchangeRate = pool.getCurrentExchangeRate();
        uint256 rewardPerSecond = pool.rewardPerSecond();
        uint256 poolSupply = totalSupply * exchangeRate;
        uint256 usdRewardPerYear = rewardPerSecond * SECONDS_PER_YEAR * cpoolPrice;

        return usdRewardPerYear * 1e18 / poolSupply;
    }

    
    
    
    
    function _getWeightedAverage(
        uint256[] memory nums,
        uint256[] memory weights
    ) internal pure returns (uint256 average) {
        uint256 sum = 0;
        uint256 weightSum = 0;

        for (uint256 i = 0; i < weights.length; i++) {
            sum += nums[i] * weights[i];
            weightSum += weights[i];
        }

        if (weightSum == 0) {
            return 0;
        }

        return sum / weightSum;
    }

    
    
    
    
    
    function getAprIndexByMarket(address[] calldata markets, uint256 cpoolPrice)
        external
        view
        returns (MarketData[] memory currencyAprs, MarketData[] memory cpoolAprs)
    {
        currencyAprs = new MarketData[](markets.length);
        cpoolAprs = new MarketData[](markets.length);

        for (uint256 i = 0; i < markets.length; i++) {
            address market = markets[i];
            address[] memory pools = factory.getPoolsByMarket(market);

            uint256 size = pools.length;

            uint256[] memory marketCurrencyAprs = new uint256[](size);
            uint256[] memory marketCpoolAprs = new uint256[](size);
            uint256[] memory poolSizes = new uint256[](size);

            for (uint256 j = 0; j < size; j++) {
                IPoolMaster pool = IPoolMaster(pools[j]);

                uint256 poolDecimals = IERC20MetadataUpgradeable(pool.currency())
                .decimals();

                poolSizes[j] = _toWei(pool.poolSize(), poolDecimals);
                marketCurrencyAprs[j] = pool.getSupplyRate() * SECONDS_PER_YEAR;
                marketCpoolAprs[j] = getPoolCpoolApr(pools[j], cpoolPrice);
            }

            uint256 currencyApr = _getWeightedAverage(marketCurrencyAprs, poolSizes);
            uint256 cpoolApr = _getWeightedAverage(marketCpoolAprs, poolSizes);

            currencyAprs[i] = MarketData(markets[i], currencyApr);
            cpoolAprs[i] = MarketData(markets[i], cpoolApr);
        }
    }
}

// 
pragma solidity 0.8.9;

interface IPoolFactory {
    function getPoolSymbol(address currency, address manager)
        external
        view
        returns (string memory);

    function isPool(address pool) external view returns (bool);

    function getPoolsByMarket(address market)
        external
        view
        returns (address[] memory);

    function interestRateModel() external view returns (address);

    function auction() external view returns (address);

    function treasury() external view returns (address);

    function reserveFactor() external view returns (uint256);

    function insuranceFactor() external view returns (uint256);

    function warningUtilization() external view returns (uint256);

    function provisionalDefaultUtilization() external view returns (uint256);

    function warningGracePeriod() external view returns (uint256);

    function maxInactivePeriod() external view returns (uint256);

    function periodToStartAuction() external view returns (uint256);

    function owner() external view returns (address);

    function closePool() external;

    function burnStake() external;

    function getPools() external view returns (address[] memory);
}

// 
pragma solidity 0.8.9;

interface IPoolMaster {
    function manager() external view returns (address);

    function currency() external view returns (address);

    function borrows() external view returns (uint256);

    function insurance() external view returns (uint256);

    function reserves() external view returns (uint256);

    function getBorrowRate() external view returns (uint256);

    function getSupplyRate() external view returns (uint256);

    function poolSize() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function getCurrentExchangeRate() external view returns (uint256);

    function rewardPerSecond() external view returns (uint256);

    function cash() external view returns (uint256);

    function interest() external view returns (uint256);

    function principal() external view returns (uint256);

    enum State {
        Active,
        Warning,
        ProvisionalDefault,
        Default,
        Closed
    }

    function state() external view returns (State);

    function initialize(address manager_, address currency_) external;

    function setRewardPerSecond(uint256 rewardPerSecond_) external;

    function withdrawReward(address account) external returns (uint256);

    function transferReserves() external;

    function processAuctionStart() external;

    function processDebtClaim() external;

    function setManager(address manager_) external;
}