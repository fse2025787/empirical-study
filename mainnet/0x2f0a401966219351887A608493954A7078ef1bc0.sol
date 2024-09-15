// SPDX-License-Identifier: BUSL-1.1
pragma abicoder v2;


// 
pragma solidity >=0.7.6 <0.9.0;


interface IPriceProvider {
    
    /// It unifies all tokens decimal to 18, examples:
    /// - if asses == quote it returns 1e18
    /// - if asset is USDC and quote is ETH and ETH costs ~$3300 then it returns ~0.0003e18 WETH per 1 USDC
    
    
    function getPrice(address _asset) external view returns (uint256 price);

    
    /// Some providers implementations need time to "build" buffer for TWAP price,
    /// so price may not be available yet but this method will return true.
    
    
    function assetSupported(address _asset) external view returns (bool);

    
    
    function quoteToken() external view returns (address);

    
    
    /// but this should NOT be treated as security check
    
    function priceProviderPing() external pure returns (bytes4);
}

// 
pragma solidity >=0.7.6 <0.9.0;



/// The only difference is that it adds a possibility to transfer ownership in two steps. Single step ownership
/// transfer is still supported.

/// transfer is meant to be used by smart contracts to avoid over-complicated two step integration. For that reason,
/// both ways are supported.
abstract contract TwoStepOwnable {
    
    address private _owner;
    
    address private _pendingOwner;

    
    
    event OwnershipTransferred(address indexed newOwner);
    
    
    event OwnershipPending(address indexed newPendingOwner);

    /**
     *  error OnlyOwner();
     *  error OnlyPendingOwner();
     *  error OwnerIsZero();
     */

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        if (owner() != msg.sender) revert("OnlyOwner");
        _;
    }

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) revert("OwnerIsZero");
        _setOwner(newOwner);
    }

    /**
     * @dev Transfers pending ownership of the contract to a new account (`newPendingOwner`) and clears any existing
     * pending ownership.
     * Can only be called by the current owner.
     */
    function transferPendingOwnership(address newPendingOwner) public virtual onlyOwner {
        _setPendingOwner(newPendingOwner);
    }

    /**
     * @dev Clears the pending ownership.
     * Can only be called by the current owner.
     */
    function removePendingOwnership() public virtual onlyOwner {
        _setPendingOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a pending owner
     * Can only be called by the pending owner.
     */
    function acceptOwnership() public virtual {
        if (msg.sender != pendingOwner()) revert("OnlyPendingOwner");
        _setOwner(pendingOwner());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Sets the new owner and emits the corresponding event.
     */
    function _setOwner(address newOwner) private {
        if (_owner == newOwner) revert("OwnerDidNotChange");

        _owner = newOwner;
        emit OwnershipTransferred(newOwner);

        if (_pendingOwner != address(0)) {
            _setPendingOwner(address(0));
        }
    }

    /**
     * @dev Sets the new pending owner and emits the corresponding event.
     */
    function _setPendingOwner(address newPendingOwner) private {
        if (_pendingOwner == newPendingOwner) revert("PendingOwnerDidNotChange");

        _pendingOwner = newPendingOwner;
        emit OwnershipPending(newPendingOwner);
    }
}

// 
pragma solidity >=0.7.6 <0.9.0;








/// like Chainlink to calculate TWAP prices for assets. Each price provider should support a single price source
/// and multiple assets.
abstract contract PriceProvider is IPriceProvider {
    
    IPriceProvidersRepository public immutable priceProvidersRepository;

    
    address public immutable override quoteToken;

    modifier onlyManager() {
        if (priceProvidersRepository.manager() != msg.sender) revert("OnlyManager");
        _;
    }

    
    constructor(IPriceProvidersRepository _priceProvidersRepository) {
        if (
            !Ping.pong(_priceProvidersRepository.priceProvidersRepositoryPing)            
        ) {
            revert("InvalidPriceProviderRepository");
        }

        priceProvidersRepository = _priceProvidersRepository;
        quoteToken = _priceProvidersRepository.quoteToken();
    }

    
    function priceProviderPing() external pure override returns (bytes4) {
        return this.priceProviderPing.selector;
    }

    function _revertBytes(bytes memory _errMsg, string memory _customErr) internal pure {
        if (_errMsg.length > 0) {
            assembly { // solhint-disable-line no-inline-assembly
                revert(add(32, _errMsg), mload(_errMsg))
            }
        }

        revert(_customErr);
    }
}

// 
pragma solidity 0.7.6;











//  but with virtual methods and without private variables
abstract contract UniswapV3PriceProviderV3 is PriceProvider, TwoStepOwnable {
    using RevertBytes for bytes;

    struct PriceCalculationData {
        // Number of seconds for which time-weighted average should be calculated, ie. 1800 means 30 min
        uint32 periodForAvgPrice;

        // Estimated blockchain block time
        uint8 blockTime;
    }

    struct PricePath {
        IUniswapV3Pool pool;
        // if target/interim token is token0, then TRUE
        bool token0IsInterim;
    }

    bytes32 private constant _OLD_ERROR_HASH = keccak256(abi.encodeWithSignature("Error(string)", "OLD"));

    
    uint256 public immutable QUOTE_TOKEN_DECIMALS; // solhint-disable-line var-name-mixedcase

    
    /// block time tends to go down (not up), temporary deviations are not important
    /// Ethereum's block time is almost never higher than ~15 sec, so in practice we shouldn't need to set it above that
    /// 60 was chosen as an arbitrary maximum just to prevent human errors
    uint256 public constant MAX_ACCEPTED_BLOCK_TIME = 60;

    
    IUniswapV3Factory public immutable uniswapV3Factory;

    
    /// - periodForAvgPrice: Number of seconds for which time-weighted average should be calculated, ie. 1800 is 30 min
    /// - blockTime: Estimated blockchain block time
    PriceCalculationData public priceCalculationData;

    
    mapping(address => PricePath[]) internal _assetPath;

    
    
    event NewPeriod(uint32 period);

    
    
    event NewBlockTime(uint8 blockTime);

    
    
    
    event PoolsForAsset(address indexed asset, IUniswapV3Pool[] pools);

    
    
    
    /// - _periodForAvgPrice period in seconds for TWAP price, ie. 1800 means 30 min
    /// - _blockTime estimated block time, it is better to set it bit lower than higher that avg block time
    ///   eg. if ETH block time is 13~13.5s, you can set it to 12s
    constructor(
        IPriceProvidersRepository _priceProvidersRepository,
        IUniswapV3Factory _factory,
        PriceCalculationData memory _priceCalculationData
    ) PriceProvider(_priceProvidersRepository) {
        uint24 defaultFee = 500;
        // Ping for _priceProvidersRepository is not needed here, because PriceProvider does it
        if (_factory.feeAmountTickSpacing(defaultFee) == 0) revert("InvalidFactory");
        if (_priceCalculationData.periodForAvgPrice == 0) revert("InvalidPeriodForAvgPrice");

        if (
            _priceCalculationData.blockTime == 0 || _priceCalculationData.blockTime >= MAX_ACCEPTED_BLOCK_TIME
        ) {
            revert("InvalidBlockTime");
        }

        _validatePriceCalculationData(
            _priceCalculationData.periodForAvgPrice,
            _priceCalculationData.blockTime
        );

        uniswapV3Factory = _factory;
        priceCalculationData = _priceCalculationData;

        QUOTE_TOKEN_DECIMALS = IERC20Like(_priceProvidersRepository.quoteToken()).decimals();
    }

    
    /// Notice: pool must be ready for providing price. See `adjustOracleCardinality`.
    
    
    /// in case UniV3 does not have pool for asset-quote, we can provide as many intermediary pools as necessary
    /// to reach quote token eg: [pool0(asset, tokenA), pool1(tokenB, tokenA), pool2(tokenB, quote)]
    /// pools must be in the right order
    function setupAsset(address _asset, IUniswapV3Pool[] calldata _pools) external virtual onlyManager {
        PricePath[] memory path = verifyPools(_asset, _pools);
        delete _assetPath[_asset];

        for (uint256 i; i < path.length; i++) {
            _assetPath[_asset].push(path[i]);
        }

        emit PoolsForAsset(_asset, _pools);

        // make sure getPrice does not revert
        getPrice(_asset);
    }

    
    
    /// and set as oracle for asset, will not immediately adjust to new time window.
    /// We need to call `adjustOracleCardinality` and then wait for buffer to filled up.
    /// Until that happen, TWAP price will be fetched for shorter period (because of time window adjustment feature).
    
    function changePeriodForAvgPrice(uint32 _period) external virtual onlyManager {
        // `_period < block.timestamp` is because we making sure we do not underflow
        if (_period == 0 || _period >= block.timestamp) revert("InvalidPeriodForAvgPrice");
        if (priceCalculationData.periodForAvgPrice == _period) revert("PeriodForAvgPriceDidNotChange");

        _validatePriceCalculationData(_period, priceCalculationData.blockTime);

        priceCalculationData.periodForAvgPrice = _period;

        emit NewPeriod(_period);
    }

    
    
    /// eg. if ETH block time is 13~13.5s, you can set it to 11-12s
    /// based on `priceCalculationData.periodForAvgPrice` and `priceCalculationData.blockTime` price provider calculates
    /// number of blocks for (cardinality) requires for TWAP price. Unfortunately block time can change and this
    /// can lead to issues with getting price. Edge case will be when we set `_blockTime` to 1, then we have 100%
    /// guarantee, that no matter how real block time changes, we always can get price.
    /// Downside will be cost of initialization. That's why it is better to set a bit lower
    /// and adjust (decrease) in case of issues.
    function changeBlockTime(uint8 _blockTime) external virtual onlyManager {
        if (_blockTime == 0 || _blockTime >= MAX_ACCEPTED_BLOCK_TIME) revert("InvalidBlockTime");
        if (priceCalculationData.blockTime == _blockTime) revert("BlockTimeDidNotChange");

        _validatePriceCalculationData(priceCalculationData.periodForAvgPrice, _blockTime);

        priceCalculationData.blockTime = _blockTime;
        emit NewBlockTime(_blockTime);
    }

    
    /// Call `observationsStatus` to see, if you need to execute this method.
    /// This method prepares pool for setup for price provider. In order to run `setupAsset` for asset,
    /// pool must have buffer to provide TWAP price. By calling this adjustment (and waiting necessary amount of time)
    /// pool will be ready for setup. It will collect valid number of observations, so the pool can be used
    /// once price data is ready.
    
    /// We should call it on init and when we are changing the pool (univ3 can have multiple pools for the same tokens)
    
    function adjustOracleCardinality(IUniswapV3Pool[] calldata _pools) external virtual {
        PriceCalculationData memory data = priceCalculationData;
        // ideally we want to have data at every block during periodForAvgPrice
        // If we want to get TWAP for 5 minutes and assuming we have tx in every block, and block time is 15 sec,
        // then for 5 minutes we will have 20 blocks, that means our requiredCardinality is 20.
        uint256 requiredCardinality = data.periodForAvgPrice / data.blockTime;

        for (uint256 i; i < _pools.length; i++) {
            (,,,, uint16 cardinalityNext,,) = _pools[i].slot0();

            if (cardinalityNext >= requiredCardinality) revert("NotNecessary");

            // initialize required amount of slots, it will cost!
            _pools[i].increaseObservationCardinalityNext(uint16(requiredCardinality));
        }
    }

    function pools(address _asset) external view virtual returns (PricePath[] memory) {
        return _assetPath[_asset];
    }

    
    function assetSupported(address _asset) external view virtual override returns (bool) {
        return _assetPath[_asset].length != 0 || _asset == quoteToken;
    }

    
    /// it does NOT validate input pool, so you must be sure you providing correct one
    /// otherwise result will be wrong or function will throw.
    /// If pool is correct and it still throwing, please check `observationsStatus(_pool)`.
    
    function quotePrice(IUniswapV3Pool _pool) external view virtual returns (uint256 price) {
        address base = quoteToken;
        address token0 = _pool.token0();
        address quote = base == token0 ? _pool.token1() : token0;
        uint128 baseAmount = uint128(10 ** QUOTE_TOKEN_DECIMALS);

        int24 timeWeightedAverageTick = _consult(_pool);
        price = OracleLibrary.getQuoteAtTick(timeWeightedAverageTick, baseAmount, base, quote);
    }

    function assetOldestTimestamp(address _asset) external view virtual returns (uint32[] memory oldestTimestamps) {
        uint256 pathLength = _assetPath[_asset].length;
        oldestTimestamps = new uint32[](pathLength);

        for (uint256 i; i < pathLength; i++) {
            (,, uint16 observationIndex, uint16 currentObservationCardinality,,,) = _assetPath[_asset][i].pool.slot0();

            oldestTimestamps[i] = resolveOldestObservationTimestamp(
                _assetPath[_asset][i].pool, observationIndex, currentObservationCardinality
            );
        }
    }

    
    /// If it does not have, please execute `adjustOracleCardinality`.
    
    
    
    function observationsStatus(IUniswapV3Pool _pool)
        public
        view
        virtual
        returns (
            bool bufferFull,
            bool enoughObservations,
            uint16 currentCardinality
        )
    {
        PriceCalculationData memory data = priceCalculationData;

        (
            ,,, uint16 currentObservationCardinality,
            uint16 observationCardinalityNext,,
        ) = _pool.slot0();

        // ideally we want to have data at every block during periodForAvgPrice
        uint256 requiredCardinality = data.periodForAvgPrice / data.blockTime;

        bufferFull = currentObservationCardinality >= requiredCardinality;
        enoughObservations = observationCardinalityNext >= requiredCardinality;
        currentCardinality = currentObservationCardinality;
     }

    
    /// Throws when there is no pool or pool is empty (zero liquidity) or not ready for price
    
    
    /// in case UniV3 does not have pool for asset-quote, we can provide as many intermediary pools as necessary
    /// to reach quote token eg: [pool0(asset, tokenA), pool1(tokenB, tokenA), pool2(tokenB, quote)]
    
    function verifyPools(address _asset, IUniswapV3Pool[] calldata _pools)
        public
        view
        virtual
        returns (PricePath[] memory path)
    {
        if (_asset == address(0)) revert("AssetIsZero");

        address fromToken = _asset;
        address interimQuote;

        path = new PricePath[](_pools.length);

        for (uint256 i; i < _pools.length; i++) {
            if (address(_pools[i]) == address(0)) revert("PoolIsZero");

            address token1 = _pools[i].token1();
            path[i].pool = _pools[i];
            path[i].token0IsInterim = fromToken == token1;

            interimQuote = path[i].token0IsInterim ? _pools[i].token0() : token1;

            _verifyPool(_pools[i], fromToken, interimQuote);

            fromToken = interimQuote;
        }

        if (interimQuote != quoteToken) revert("InterimIsNotQuote");
    }

    
    /// Mint and burn will write observation only when "current tick is inside the passed range" of ticks.
    /// I think that means, that if we minting/burning outside ticks range  (so outside current price)
    /// it will not modify observation. So we left with swap.
    ///
    /// Swap will write observation under this condition:
    ///     // update tick and write an oracle entry if the tick change
    ///     if (state.tick != slot0Start.tick) {
    /// that means, it is possible that price will be up to date (in a range of same tick)
    /// but observation timestamp will be old.
    ///
    /// Every pool by default comes with just one slot for observation (cardinality == 1).
    /// We can increase number of slots so TWAP price will be "better".
    /// When we increase, we have to wait until new tx will write new observation.
    /// Based on all above, we can tell how old is observation, but this does not mean the price is wrong.
    /// UniV3 recommends to use `observe` and `OracleLibrary.consult` uses it.
    /// `observe` reverts if `secondsAgo` > oldest observation, means, if there is any price observation in selected
    /// time frame, it will revert. Otherwise it will return either exact TWAP price or by interpolation.
    ///
    /// Conclusion: we can choose how many observation pool will be storing, but we need to remember,
    /// not all of them might be used to provide our price. Final question is: how many observations we need?
    ///
    /// How UniV3 calculates TWAP
    /// we ask for TWAP on time range ago:now using `OracleLibrary.consult`, it is all about find the right tick
    /// - we call `IUniswapV3Pool(pool).observe(secondAgo)` that returns two accumulator values (for ago and now)
    /// - each observation is resolved by `observeSingle`
    ///   - for _now_ we just using latest observation, and if it does not match timestamp, we interpolate (!)
    ///     and this is how we got the _tickCumulative_, so in extreme situation, if last observation was made day ago,
    ///     UniV3 will interpolate to reflect _tickCumulative_ at current time
    ///   - for _ago_ we search for observation using `getSurroundingObservations` that give us
    ///     before and after observation, base on which we calculate "avg" and we have target _tickCumulative_
    ///     - getSurroundingObservations: it's job is to find 2 observations based on which we calculate tickCumulative
    ///       here is where all calculations can revert, if ago < oldest observation, otherwise it will be calculated
    ///       either by interpolation or we will have exact match
    /// - now with both _tickCumulative_s we calculating TWAP
    ///
    /// recommended observations are = 30 min / blockTime
    
    function getPrice(address _asset) public view virtual override returns (uint256 price) {
        address quote = quoteToken;

        if (_asset == quote) {
            return 10 ** QUOTE_TOKEN_DECIMALS;
        }

        uint256 decimals = IERC20Like(_asset).decimals();
        if (decimals > 38) revert("power overflow"); // we need 10**decimals be less than 2**128

        PricePath[] memory path = _assetPath[_asset];
        if (path.length == 0) revert("PoolNotSetForAsset");

        price = 10 ** decimals;

        if (path.length == 1) {
            return _getPrice(path[0].pool, uint128(price), _asset, quote);
        }

        address interimQuote;

        for (uint256 i; i < path.length; i++) {
            interimQuote = path[i].token0IsInterim ? path[i].pool.token0() : path[i].pool.token1();

            if (price >= type(uint128).max) revert("PriceOverflow");

            price = _getPrice(path[i].pool, uint128(price), _asset, interimQuote);

            _asset = interimQuote;
        }
    }

    
    
    
    
    function resolveOldestObservationTimestamp(
        IUniswapV3Pool _pool,
        uint16 _currentObservationIndex,
        uint16 _currentObservationCardinality
    )
        public
        view
        virtual
        returns (uint32 oldestTimestamp)
    {
        bool initialized;

        (
            oldestTimestamp,,,
            initialized
        ) = _pool.observations((_currentObservationIndex + 1) % _currentObservationCardinality);

        // if not initialized, we just check id#0 as this will be the oldest
        if (!initialized) {
            (oldestTimestamp,,,) = _pool.observations(0);
        }
    }

    
    
    
    
    function _verifyPool(IUniswapV3Pool _pool, address _fromToken, address _targetToken) internal view virtual {
        if (uniswapV3Factory.getPool(_fromToken, _targetToken, _pool.fee()) != address(_pool)) {
            revert("InvalidPoolForAsset");
        }

        uint256 liquidity = IERC20Like(_targetToken).balanceOf(address(_pool));
        if (liquidity == 0) revert("EmptyPool");

        (bool bufferFull,,) = observationsStatus(_pool);
        if (!bufferFull) revert("BufferNotFull");
    }

    
    
    
    
    
    
    function _getPrice(IUniswapV3Pool _pool, uint128 _amount, address _asset, address _denominator)
        internal
        view
        virtual
        returns (uint256 quoteAmount)
    {
        int24 timeWeightedAverageTick = _consult(_pool);
        quoteAmount = OracleLibrary.getQuoteAtTick(timeWeightedAverageTick, _amount, _asset, _denominator);
    }

    
    
    /// to available pool observations
    
    
    function _consult(IUniswapV3Pool _pool) internal view virtual returns (int24 timeWeightedAverageTick) {
        (uint32 period, int56[] memory tickCumulatives) = _calculatePeriodAndTicks(_pool);
        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        timeWeightedAverageTick = int24(tickCumulativesDelta / period);

        // Always round to negative infinity
        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % period != 0)) timeWeightedAverageTick--;
    }

    
    
    
    function _calculatePeriodAndTicks(IUniswapV3Pool _pool)
        internal
        view
        virtual
        returns (uint32 period, int56[] memory tickCumulatives)
    {
        period = priceCalculationData.periodForAvgPrice;
        bool old;

        (tickCumulatives, old) = _observe(_pool, period);

        if (old) {
            (,, uint16 observationIndex, uint16 currentObservationCardinality,,,) = _pool.slot0();

            uint32 latestTimestamp =
                resolveOldestObservationTimestamp(_pool, observationIndex, currentObservationCardinality);

            period = uint32(block.timestamp - latestTimestamp);

            (tickCumulatives, old) = _observe(_pool, period);
            if (old) revert("STILL OLD");
        }
    }

    
    
    function _observe(IUniswapV3Pool _pool, uint32 _period)
        internal
        view
        virtual
        returns (int56[] memory tickCumulatives, bool old)
    {
        uint32[] memory secondAgos = new uint32[](2);
        secondAgos[0] = _period;
        // secondAgos[1] = 0; // default is 0

        try _pool.observe(secondAgos)
            returns (int56[] memory ticks, uint160[] memory)
        {
            tickCumulatives = ticks;
            old = false;
        }
        catch (bytes memory reason) {
            if (keccak256(reason) != _OLD_ERROR_HASH) reason.revertBytes("_observe");
            old = true;
        }
    }

    function _validatePriceCalculationData(uint32 _periodForAvgPrice, uint8 _blockTime) internal pure virtual {
        uint256 requiredCardinality = _periodForAvgPrice / _blockTime;
        if (requiredCardinality > type(uint16).max) revert("InvalidRequiredCardinality");
    }
}

// 
pragma solidity >=0.5.0;



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

// 
pragma solidity >=0.5.0;



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
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    
    
    
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
    
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}

// 
pragma solidity >=0.5.0;



/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    
    
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    
    
    
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    
    
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    
    
    
    
    
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}

// 
pragma solidity >=0.5.0;



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
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    
    
    
    
    
    
    
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

// 
pragma solidity >=0.5.0;



interface IUniswapV3PoolOwnerActions {
    
    
    
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    
    
    
    
    
    
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}

// 
pragma solidity >=0.5.0;



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
        uint128 liquidity,
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
// 
pragma solidity 0.7.6;





contract UniswapV3PriceProviderXAI is UniswapV3PriceProviderV3 {
    uint256 public constant VERSION = 0x584149; // XAI in hex

    address public immutable XAI_ADDRESS; // solhint-disable-line var-name-mixedcase

    
    address public immutable XAI_VIRTUAL_ADDRESS; // solhint-disable-line var-name-mixedcase

    
    
    
    
    
    constructor(
        IPriceProvidersRepository _priceProvidersRepository,
        IUniswapV3Factory _factory,
        PriceCalculationData memory _priceCalculationData,
        address _xaiAddress,
        address _xaiVirtualAddress
    ) UniswapV3PriceProviderV3(_priceProvidersRepository, _factory, _priceCalculationData) {
        bytes32 symbolHash = keccak256(abi.encodePacked(IERC20LikeV3(_xaiAddress).symbol()));

        if (symbolHash != keccak256(abi.encodePacked("XAI")) && symbolHash != keccak256(abi.encodePacked("X"))) {
            revert("Not a XAI");
        }

        // sanity check
        IERC20LikeV3(_xaiVirtualAddress).symbol();

        XAI_ADDRESS = _xaiAddress;
        XAI_VIRTUAL_ADDRESS = _xaiVirtualAddress;
    }

    
    
    function assetSupported(address _asset) external view override returns (bool) {
        if (_asset == XAI_ADDRESS) {
            return _assetPath[XAI_ADDRESS].length != 0 && _assetPath[XAI_VIRTUAL_ADDRESS].length != 0;
        } else {
            return _assetPath[_asset].length != 0 || _asset == quoteToken;
        }
    }

    
    
    /// in case `_asset` is XAI, it returns price for XAI_VIRTUAL_ADDRESS token
    function getPrice(address _asset) public view override returns (uint256 price) {
        if (_asset == XAI_ADDRESS) {
            return super.getPrice(XAI_VIRTUAL_ADDRESS);
        }

        return super.getPrice(_asset);
    }
}

// 
pragma solidity >=0.7.6;


/// Solidity version than the rest of the codebase. This way de won't need to include
/// an additional version of OpenZeppelin's library.
interface IERC20LikeV3 {
    function decimals() external view returns (uint8);
    function balanceOf(address) external view returns(uint256);
    function symbol() external view returns(string memory);
}

// 
pragma solidity >=0.5.0 <0.8.0;









library OracleLibrary {
    
    
    
    
    function consult(address pool, uint32 period) internal view returns (int24 timeWeightedAverageTick) {
        require(period != 0, 'BP');

        uint32[] memory secondAgos = new uint32[](2);
        secondAgos[0] = period;
        secondAgos[1] = 0;

        (int56[] memory tickCumulatives, ) = IUniswapV3Pool(pool).observe(secondAgos);
        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        timeWeightedAverageTick = int24(tickCumulativesDelta / period);

        // Always round to negative infinity
        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % period != 0)) timeWeightedAverageTick--;
    }

    
    
    
    
    
    
    function getQuoteAtTick(
        int24 tick,
        uint128 baseAmount,
        address baseToken,
        address quoteToken
    ) internal pure returns (uint256 quoteAmount) {
        uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);

        // Calculate quoteAmount with better precision if it doesn't overflow when multiplied by itself
        if (sqrtRatioX96 <= type(uint128).max) {
            uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX192, baseAmount, 1 << 192)
                : FullMath.mulDiv(1 << 192, baseAmount, ratioX192);
        } else {
            uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX128, baseAmount, 1 << 128)
                : FullMath.mulDiv(1 << 128, baseAmount, ratioX128);
        }
    }

    
    
    
    function getOldestObservationSecondsAgo(address pool) internal view returns (uint32) {
        (, , uint16 observationIndex, uint16 observationCardinality, , , ) = IUniswapV3Pool(pool).slot0();
        require(observationCardinality > 0, 'NI');

        (uint32 observationTimestamp, , , bool initialized) =
            IUniswapV3Pool(pool).observations((observationIndex + 1) % observationCardinality);

        // The next index might not be initialized if the cardinality is in the process of increasing
        // In this case the oldest observation is always in index 0
        if (!initialized) {
            (observationTimestamp, , , ) = IUniswapV3Pool(pool).observations(0);
        }

        return uint32(block.timestamp) - observationTimestamp;
    }
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3Factory {
    
    
    
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    
    
    
    
    
    
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    
    
    
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    
    
    
    function owner() external view returns (address);

    
    
    
    
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    
    
    
    
    
    
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    
    
    
    
    
    /// from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
    /// are invalid.
    
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    
    
    
    function setOwner(address _owner) external;

    
    
    
    
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}

// 
pragma solidity >=0.7.6 <=0.9.0;

library RevertBytes {
    function revertBytes(bytes memory _errMsg, string memory _customErr) internal pure {
        if (_errMsg.length > 0) {
            assembly { // solhint-disable-line no-inline-assembly
                revert(add(32, _errMsg), mload(_errMsg))
            }
        }

        revert(_customErr);
    }
}

// 
pragma solidity 0.7.6;


/// Solidity version than the rest of the codebase. This way de won't need to include
/// an additional version of OpenZeppelin's library.
interface IERC20Like {
    function decimals() external view returns (uint8);
    function balanceOf(address) external view returns(uint256);
}

// 
pragma solidity >=0.4.0;




library FullMath {
    
    
    
    
    
    
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
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
        uint256 twos = -denominator & denominator;
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

    
    
    
    
    
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}

// 
pragma solidity >=0.5.0;



/// prices between 2**-128 and 2**128
library TickMath {
    
    int24 internal constant MIN_TICK = -887272;
    
    int24 internal constant MAX_TICK = -MIN_TICK;

    
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    
    
    
    
    /// at the given tick
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        require(absTick <= uint256(MAX_TICK), 'T');

        uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
        // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
        // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }

    
    
    /// ever return.
    
    
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        // second inequality must be < because the price can never reach the price at the max tick
        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, 'R');
        uint256 ratio = uint256(sqrtPriceX96) << 32;

        uint256 r = ratio;
        uint256 msb = 0;

        assembly {
            let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(5, gt(r, 0xFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(4, gt(r, 0xFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(3, gt(r, 0xFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(2, gt(r, 0xF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(1, gt(r, 0x3))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := gt(r, 0x1)
            msb := or(msb, f)
        }

        if (msb >= 128) r = ratio >> (msb - 127);
        else r = ratio << (127 - msb);

        int256 log_2 = (int256(msb) - 128) << 64;

        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(63, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(62, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(61, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(60, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(59, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(58, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(57, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(56, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(55, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(54, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(53, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(52, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(51, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(50, f))
        }

        int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

        int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
        int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

        tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
    }
}

// 
pragma solidity >=0.5.0;










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

// 
pragma solidity >=0.7.0;



library LowGasSafeMath {
    
    
    
    
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    
    
    
    
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    
    
    
    
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    
    
    
    
    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x + y) >= x == (y >= 0));
    }

    
    
    
    
    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x - y) <= x == (y >= 0));
    }
}

// 
pragma solidity >=0.5.0;


library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    
    
    
    
    
    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    
    
    
    
    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encode(key.token0, key.token1, key.fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            )
        );
    }
}

// 
pragma solidity >=0.7.6 <0.9.0;


library Ping {
    function pong(function() external pure returns(bytes4) pingFunction) internal pure returns (bool) {
        return pingFunction.address != address(0) && pingFunction.selector == pingFunction();
    }
}

// 
pragma solidity >=0.7.6 <0.9.0;



interface IPriceProvidersRepository {
    
    
    event NewPriceProvider(IPriceProvider indexed newPriceProvider);

    
    
    event PriceProviderRemoved(IPriceProvider indexed priceProvider);

    
    
    
    event PriceProviderForAsset(address indexed asset, IPriceProvider indexed priceProvider);

    
    
    function addPriceProvider(IPriceProvider _priceProvider) external;

    
    
    function removePriceProvider(IPriceProvider _priceProvider) external;

    
    
    
    
    function setPriceProviderForAsset(address _asset, IPriceProvider _priceProvider) external;

    
    
    
    function getPrice(address _asset) external view returns (uint256 price);

    
    
    
    function priceProviders(address _asset) external view returns (IPriceProvider priceProvider);

    
    
    function quoteToken() external view returns (address);

    
    
    function manager() external view returns (address);

    
    
    
    function providersReadyForAsset(address _asset) external view returns (bool);

    
    
    
    function isPriceProvider(IPriceProvider _provider) external view returns (bool);

    
    
    function providersCount() external view returns (uint256);

    
    
    function providerList() external view returns (address[] memory);

    
    
    function priceProvidersRepositoryPing() external pure returns (bytes4);
}