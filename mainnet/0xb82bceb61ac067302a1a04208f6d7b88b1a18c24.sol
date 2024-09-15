
/**
 *Submitted for verification at Etherscan.io on 2022-06-16
*/

pragma solidity ^0.6.7;



interface IUniswapV3PoolImmutables {
    
    
    function factory() external view returns (address);

    
    
    function token0() external view returns (address);

    
    
    function token1() external view returns (address);

    
    
    function fee() external view returns (uint24);

    
    
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    
    function tickSpacing() external view returns (int24);

    
    
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    
    function maxLiquidityPerTick() external view returns (uint128);
}



/// per transaction
interface IUniswapV3PoolState {
    
    /// when accessed externally.
    
    /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// observationIndex The index of the last oracle observation that was written,
    /// observationCardinality The current maximum number of observations stored in the pool,
    /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    
    
    function feeGrowthGlobal0X128() external view returns (uint256);

    
    
    function feeGrowthGlobal1X128() external view returns (uint256);

    
    
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    
    
    function liquidity() external view returns (uint128);

    
    
    
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// feeGrowthOutsideX128 values can only be used if the tick is initialized,
    /// i.e. if liquidityGross is greater than 0. In addition, these values are only relative and are used to
    /// compute snapshots.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128
        );

    
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    
    function secondsOutside(int24 wordPosition) external view returns (uint256);

    
    
    
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    
    
    
    /// ago, rather than at a specific index in the array.
    
    /// Returns tickCumulative the current tick multiplied by seconds elapsed for the life of the pool as of the
    /// observation,
    /// Returns liquidityCumulative the current liquidity multiplied by seconds elapsed for the life of the pool as of
    /// the observation,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 liquidityCumulative,
            bool initialized
        );
}



/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    
    /// tickLower and tickUpper
    
    /// by this method should be checkpointed externally after a position is minted, and again before a position is
    /// burned. Thus the external contract must control the lifecycle of the position.
    
    
    
    function secondsInside(int24 tickLower, int24 tickUpper) external view returns (uint32);

    
    
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    
    
    
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory liquidityCumulatives);
}



interface IUniswapV3PoolActions {
  
  
  
  function initialize(uint160 sqrtPriceX96) external;

  
  
  /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
  /// on tickLower, tickUpper, the amount of liquidity, and the current price.
  
  
  
  
  
  
  
  function mint(
    address recipient,
    int24 tickLower,
    int24 tickUpper,
    uint128 amount,
    bytes calldata data
  ) external returns (uint256 amount0, uint256 amount1);

  
  
  /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
  /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
  /// actual tokens owed, e.g. (0 - uint128(1)). Tokens owed may be from accumulated swap fees or burned liquidity.
  
  
  
  
  
  
  
  function collect(
    address recipient,
    int24 tickLower,
    int24 tickUpper,
    uint128 amount0Requested,
    uint128 amount1Requested
  ) external returns (uint128 amount0, uint128 amount1);

  
  
  
  
  
  
  
  
  function burn(
    int24 tickLower,
    int24 tickUpper,
    uint128 amount
  ) external returns (uint256 amount0, uint256 amount1);

  
  
  
  
  
  
  /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
  
  
  
  function swap(
    address recipient,
    bool zeroForOne,
    int256 amountSpecified,
    uint160 sqrtPriceLimitX96,
    bytes calldata data
  ) external returns (int256 amount0, int256 amount1);

  
  
  
  /// with 0 amount{0,1} and sending the donation amount(s) from the callback
  
  
  
  
  function flash(
    address recipient,
    uint256 amount0,
    uint256 amount1,
    bytes calldata data
  ) external;

  
  
  /// the input observationCardinalityNext.
  
  function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}



interface IUniswapV3PoolOwnerActions {
    
    
    
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    
    
    
    
    
    
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}




interface IUniswapV3PoolEvents {
    
    
    
    
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    
    
    
    
    
    
    
    
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    
    
    
    
    
    
    
    
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    
    
    
    
    
    
    
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        int24 tick
    );

    
    
    
    
    
    
    
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    
    
    /// just before a mint/swap/burn.
    
    
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    
    
    
    
    
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    
    
    
    
    
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}



/// to the ERC20 specification

interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}

abstract contract AuctionHouseLike {
    function bids(uint256) virtual external view returns (uint, uint);
    function buyCollateral(uint256 id, uint256 wad) external virtual;
    function liquidationEngine() view public virtual returns (LiquidationEngineLike);
    function collateralType() view public virtual returns (bytes32);
}

abstract contract SAFEEngineLike {
    mapping (bytes32 => mapping (address => uint256))  public tokenCollateral;  // [wad]
    function canModifySAFE(address, address) virtual public view returns (uint);
    function collateralTypes(bytes32) virtual public view returns (uint, uint, uint, uint, uint);
    function coinBalance(address) virtual public view returns (uint);
    function safes(bytes32, address) virtual public view returns (uint, uint);
    function modifySAFECollateralization(bytes32, address, address, address, int, int) virtual public;
    function approveSAFEModification(address) virtual public;
    function transferInternalCoins(address, address, uint) virtual public;
}

abstract contract CollateralJoinLike {
    function decimals() virtual public returns (uint);
    function collateral() virtual public returns (CollateralLike);
    function join(address, uint) virtual public payable;
    function exit(address, uint) virtual public;
}

abstract contract CoinJoinLike {
    function safeEngine() virtual public returns (SAFEEngineLike);
    function systemCoin() virtual public returns (CollateralLike);
    function join(address, uint) virtual public payable;
    function exit(address, uint) virtual public;
}

abstract contract CollateralLike {
    function approve(address, uint) virtual public;
    function transfer(address, uint) virtual public;
    function transferFrom(address, address, uint) virtual public;
    function deposit() virtual public payable;
    function withdraw(uint) virtual public;
    function balanceOf(address) virtual public view returns (uint);
}

abstract contract LiquidationEngineLike {
    function chosenSAFESaviour(bytes32, address) virtual public view returns (address);
    function safeSaviours(address) virtual public view returns (uint256);
    function liquidateSAFE(bytes32 collateralType, address safe) virtual external returns (uint256 auctionId);
    function safeEngine() view public virtual returns (SAFEEngineLike);
}




contract GebUniswapV3KeeperFlashProxyETH {
    AuctionHouseLike       public auctionHouse;
    SAFEEngineLike         public safeEngine;
    CollateralLike         public weth;
    CollateralLike         public coin;
    CoinJoinLike           public coinJoin;
    CoinJoinLike           public ethJoin;
    IUniswapV3Pool         public uniswapPair;
    LiquidationEngineLike  public liquidationEngine;
    address payable        public caller;
    bytes32                public collateralType;

    uint256 public   constant ZERO           = 0;
    uint256 public   constant ONE            = 1;
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    
    
    
    
    
    
    
    constructor(
        address auctionHouseAddress,
        address wethAddress,
        address systemCoinAddress,
        address uniswapPairAddress,
        address coinJoinAddress,
        address ethJoinAddress
    ) public {
        require(auctionHouseAddress != address(0), "GebUniswapV3KeeperFlashProxyETH/null-auction-house");
        require(wethAddress != address(0), "GebUniswapV3KeeperFlashProxyETH/null-weth");
        require(systemCoinAddress != address(0), "GebUniswapV3KeeperFlashProxyETH/null-system-coin");
        require(uniswapPairAddress != address(0), "GebUniswapV3KeeperFlashProxyETH/null-uniswap-pair");
        require(coinJoinAddress != address(0), "GebUniswapV3KeeperFlashProxyETH/null-coin-join");
        require(ethJoinAddress != address(0), "GebUniswapV3KeeperFlashProxyETH/null-eth-join");

        auctionHouse        = AuctionHouseLike(auctionHouseAddress);
        weth                = CollateralLike(wethAddress);
        coin                = CollateralLike(systemCoinAddress);
        uniswapPair         = IUniswapV3Pool(uniswapPairAddress);
        coinJoin            = CoinJoinLike(coinJoinAddress);
        ethJoin             = CoinJoinLike(ethJoinAddress);
        collateralType      = auctionHouse.collateralType();
        liquidationEngine   = auctionHouse.liquidationEngine();
        safeEngine          = liquidationEngine.safeEngine();

        safeEngine.approveSAFEModification(address(auctionHouse));
    }

    // --- Math ---
    function addition(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "GebUniswapV3KeeperFlashProxyETH/add-overflow");
    }
    function subtract(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "GebUniswapV3KeeperFlashProxyETH/sub-underflow");
    }
    function multiply(uint x, uint y) internal pure returns (uint z) {
        require(y == ZERO || (z = x * y) / y == x, "GebUniswapV3KeeperFlashProxyETH/mul-overflow");
    }
    function wad(uint rad) internal pure returns (uint) {
        return rad / 10 ** 27;
    }

    // --- External Utils ---
    
    
    
    function bid(uint auctionId, uint amount) external {
        require(msg.sender == address(this), "GebUniswapV3KeeperFlashProxyETH/only-self");
        auctionHouse.buyCollateral(auctionId, amount);
    }
    
    
    
    function multipleBid(uint[] calldata auctionIds, uint[] calldata amounts) external {
        require(msg.sender == address(this), "GebUniswapV3KeeperFlashProxyETH/only-self");
        for (uint i = ZERO; i < auctionIds.length; i++) {
            auctionHouse.buyCollateral(auctionIds[i], amounts[i]);
        }
    }
    
    
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    
    function uniswapV3SwapCallback(int256 _amount0, int256 _amount1, bytes calldata _data) external {
        require(msg.sender == address(uniswapPair), "GebUniswapV3KeeperFlashProxyETH/invalid-uniswap-pair");

        // join COIN
        uint amount = coin.balanceOf(address(this));
        coin.approve(address(coinJoin), amount);
        coinJoin.join(address(this), amount);

        // bid
        (bool success, ) = address(this).call(_data);
        require(success, "failed bidding");

        // exit WETH
        ethJoin.exit(address(this), safeEngine.tokenCollateral(collateralType, address(this)));

        // repay loan
        uint amountToRepay = _amount0 > int(ZERO) ? uint(_amount0) : uint(_amount1);
        weth.transfer(address(uniswapPair), amountToRepay);

        // send profit back
        uint profit = weth.balanceOf(address(this));
        weth.withdraw(profit);
        caller.call{value: profit}("");
        caller = address(0x0);
    }

    // --- Internal Utils ---
    
    
    
    function _startSwap(uint amount, bytes memory data) internal {
        caller = msg.sender;

        bool zeroForOne = address(coin) == uniswapPair.token1() ? true : false;
        uint160 sqrtLimitPrice = zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1;

        uniswapPair.swap(address(this), zeroForOne, int256(amount) * -1, sqrtLimitPrice, data);
    }
    
    
    
    
    
    function _getOpenAuctionsBidSizes(uint[] memory auctionIds) internal view returns (uint[] memory, uint[] memory, uint) {
        uint            amountToRaise;
        uint            totalAmount;
        uint            opportunityCount;

        uint[] memory   ids = new uint[](auctionIds.length);
        uint[] memory   bidAmounts = new uint[](auctionIds.length);

        for (uint i = ZERO; i < auctionIds.length; i++) {
            (, amountToRaise) = auctionHouse.bids(auctionIds[i]);

            if (amountToRaise > ZERO) {
                totalAmount                  = addition(totalAmount, addition(wad(amountToRaise), ONE));
                ids[opportunityCount]        = auctionIds[i];
                bidAmounts[opportunityCount] = amountToRaise;
                opportunityCount++;
            }
        }

        assembly {
            mstore(ids, opportunityCount)
            mstore(bidAmounts, opportunityCount)
        }

        return(ids, bidAmounts, totalAmount);
    }

    // --- Core Bidding and Settling Logic ---
    
    
    
    
    function liquidateAndSettleSAFE(address safe) public returns (uint auction) {
        if (liquidationEngine.safeSaviours(liquidationEngine.chosenSAFESaviour(collateralType, safe)) == 1) {
            require (liquidationEngine.chosenSAFESaviour(collateralType, safe) == address(0),
            "safe-is-protected.");
        }

        auction = liquidationEngine.liquidateSAFE(collateralType, safe);
        settleAuction(auction);
    }
    
    
    function settleAuction(uint auctionId) public {
        (, uint amountToRaise) = auctionHouse.bids(auctionId);
        require(amountToRaise > ZERO, "GebUniswapV3KeeperFlashProxyETH/auction-already-settled");

        bytes memory callbackData = abi.encodeWithSelector(this.bid.selector, auctionId, amountToRaise);

        _startSwap(addition(wad(amountToRaise), ONE), callbackData);
    }
    
    
    function settleAuction(uint[] memory auctionIds) public {
        (uint[] memory ids, uint[] memory bidAmounts, uint totalAmount) = _getOpenAuctionsBidSizes(auctionIds);
        require(totalAmount > ZERO, "GebUniswapV3KeeperFlashProxyETH/all-auctions-already-settled");

        bytes memory callbackData = abi.encodeWithSelector(this.multipleBid.selector, ids, bidAmounts);

        _startSwap(totalAmount, callbackData);
    }

    // --- Fallback ---
    receive() external payable {
        require(msg.sender == address(weth), "GebUniswapV3KeeperFlashProxyETH/only-weth-withdrawals-allowed");
    }
}