  pragma abicoder v2;
 pragma solidity 0.7.6;
 interface IERC20 {
 event Approval(address indexed owner, address indexed spender, uint256 value);
 event Transfer(address indexed from, address indexed to, uint256 value);
 function name() external view returns (string memory);
 function symbol() external view returns (string memory);
 function decimals() external view returns (uint8);
 function totalSupply() external view returns (uint256);
 function balanceOf(address owner) external view returns (uint256);
 function allowance(address owner, address spender) external view returns (uint256);
 function approve(address spender, uint256 value) external returns (bool);
 function transfer(address to, uint256 value) external returns (bool);
 function transferFrom( address from, address to, uint256 value ) external returns (bool);
 }
 pragma solidity 0.7.6;
 interface ITwapRelayer {
 event OwnerSet(address owner);
 event DelaySet(address delay);
 event PairEnabledSet(address pair, bool enabled);
 event SwapFeeSet(address pair, uint256 fee);
 event TwapIntervalSet(address pair, uint32 interval);
 event EthTransferGasCostSet(uint256 gasCost);
 event ExecutionGasLimitSet(uint256 limit);
 event GasPriceMultiplierSet(uint256 multiplier);
 event TokenLimitMinSet(address token, uint256 limit);
 event TokenLimitMaxMultiplierSet(address token, uint256 limit);
 event ToleranceSet(address pair, uint16 tolerance);
 event Approve(address token, address to, uint256 amount);
 event Withdraw(address token, address to, uint256 amount);
 event Swap( address indexed sender, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut, bool wrapUnwrap, uint256 fee, address indexed to, uint256 indexed orderId );
 function factory() external view returns (address);
 function delay() external view returns (address);
 function setDelay(address _delay) external;
 function weth() external view returns (address);
 function owner() external view returns (address);
 function setOwner(address _owner) external;
 function swapFee(address pair) external view returns (uint256);
 function setSwapFee(address pair, uint256 fee) external;
 function twapInterval(address pair) external view returns (uint32);
 function setTwapInterval(address pair, uint32 _interval) external;
 function isPairEnabled(address pair) external view returns (bool);
 function setPairEnabled(address pair, bool enabled) external;
 function ethTransferGasCost() external view returns (uint256);
 function setEthTransferGasCost(uint256 gasCost) external;
 function executionGasLimit() external view returns (uint256);
 function setExecutionGasLimit(uint256 limit) external;
 function gasPriceMultiplier() external view returns (uint256);
 function setGasPriceMultiplier(uint256 multiplier) external;
 function tokenLimitMin(address token) external view returns (uint256);
 function setTokenLimitMin(address token, uint256 limit) external;
 function tokenLimitMaxMultiplier(address token) external view returns (uint256);
 function setTokenLimitMaxMultiplier(address token, uint256 multiplier) external;
 function tolerance(address pair) external view returns (uint16);
 function setTolerance(address pair, uint16 _tolerance) external;
 struct SellParams {
 address tokenIn;
 address tokenOut;
 uint256 amountIn;
 uint256 amountOutMin;
 bool wrapUnwrap;
 address to;
 uint32 submitDeadline;
 }
 function sell(SellParams memory sellParams) external payable returns (uint256 orderId);
 struct BuyParams {
 address tokenIn;
 address tokenOut;
 uint256 amountInMax;
 uint256 amountOut;
 bool wrapUnwrap;
 address to;
 uint32 submitDeadline;
 }
 function buy(BuyParams memory buyParams) external payable returns (uint256 orderId);
 function getPriceByPairAddress(address pair, bool inverted) external view returns ( uint8 xDecimals, uint8 yDecimals, uint256 price );
 function getPriceByTokenAddresses(address tokenIn, address tokenOut) external view returns (uint256 price);
 function getPoolState(address token0, address token1) external view returns ( uint256 price, uint256 fee, uint256 limitMin0, uint256 limitMax0, uint256 limitMin1, uint256 limitMax1 );
 function quoteSell( address tokenIn, address tokenOut, uint256 amountIn ) external view returns (uint256 amountOut);
 function quoteBuy( address tokenIn, address tokenOut, uint256 amountOut ) external view returns (uint256 amountIn);
 function approve( address token, uint256 amount, address to ) external;
 function withdraw( address token, uint256 amount, address to ) external;
 }
 pragma solidity 0.7.6;
 interface ITwapOracle {
 event OwnerSet(address owner);
 event UniswapPairSet(address uniswapPair);
 function decimalsConverter() external view returns (int256);
 function xDecimals() external view returns (uint8);
 function yDecimals() external view returns (uint8);
 function owner() external view returns (address);
 function uniswapPair() external view returns (address);
 function getPriceInfo() external view returns (uint256 priceAccumulator, uint32 priceTimestamp);
 function getSpotPrice() external view returns (uint256);
 function getAveragePrice(uint256 priceAccumulator, uint32 priceTimestamp) external view returns (uint256);
 function setOwner(address _owner) external;
 function setUniswapPair(address _uniswapPair) external;
 function tradeX( uint256 xAfter, uint256 xBefore, uint256 yBefore, bytes calldata data ) external view returns (uint256 yAfter);
 function tradeY( uint256 yAfter, uint256 yBefore, uint256 xBefore, bytes calldata data ) external view returns (uint256 xAfter);
 function depositTradeXIn( uint256 xLeft, uint256 xBefore, uint256 yBefore, bytes calldata data ) external view returns (uint256 xIn);
 function depositTradeYIn( uint256 yLeft, uint256 yBefore, uint256 xBefore, bytes calldata data ) external view returns (uint256 yIn);
 function getSwapAmount0Out( uint256 swapFee, uint256 amount1In, bytes calldata data ) external view returns (uint256 amount0Out);
 function getSwapAmount1Out( uint256 swapFee, uint256 amount0In, bytes calldata data ) external view returns (uint256 amount1Out);
 function getSwapAmountInMaxOut( bool inverse, uint256 swapFee, uint256 _amountOut, bytes calldata data ) external view returns (uint256 amountIn, uint256 amountOut);
 function getSwapAmountInMinOut( bool inverse, uint256 swapFee, uint256 _amountOut, bytes calldata data ) external view returns (uint256 amountIn, uint256 amountOut);
 }
 pragma solidity 0.7.6;
 interface ITwapERC20 is IERC20 {
 function PERMIT_TYPEHASH() external pure returns (bytes32);
 function nonces(address owner) external view returns (uint256);
 function permit( address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s ) external;
 function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
 function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
 }
 pragma solidity 0.7.6;
 interface IReserves {
 function getReserves() external view returns (uint112 reserve0, uint112 reserve1);
 function getFees() external view returns (uint256 fee0, uint256 fee1);
 }
 pragma solidity >=0.5.0;
 interface IUniswapV3PoolImmutables {
 function factory() external view returns (address);
 function token0() external view returns (address);
 function token1() external view returns (address);
 function fee() external view returns (uint24);
 function tickSpacing() external view returns (int24);
 function maxLiquidityPerTick() external view returns (uint128);
 }
 pragma solidity >=0.5.0;
 interface IUniswapV3PoolState {
 function slot0() external view returns ( uint160 sqrtPriceX96, int24 tick, uint16 observationIndex, uint16 observationCardinality, uint16 observationCardinalityNext, uint8 feeProtocol, bool unlocked );
 function feeGrowthGlobal0X128() external view returns (uint256);
 function feeGrowthGlobal1X128() external view returns (uint256);
 function protocolFees() external view returns (uint128 token0, uint128 token1);
 function liquidity() external view returns (uint128);
 function ticks(int24 tick) external view returns ( uint128 liquidityGross, int128 liquidityNet, uint256 feeGrowthOutside0X128, uint256 feeGrowthOutside1X128, int56 tickCumulativeOutside, uint160 secondsPerLiquidityOutsideX128, uint32 secondsOutside, bool initialized );
 function tickBitmap(int16 wordPosition) external view returns (uint256);
 function positions(bytes32 key) external view returns ( uint128 _liquidity, uint256 feeGrowthInside0LastX128, uint256 feeGrowthInside1LastX128, uint128 tokensOwed0, uint128 tokensOwed1 );
 function observations(uint256 index) external view returns ( uint32 blockTimestamp, int56 tickCumulative, uint160 secondsPerLiquidityCumulativeX128, bool initialized );
 }
 pragma solidity >=0.5.0;
 interface IUniswapV3PoolDerivedState {
 function observe(uint32[] calldata secondsAgos) external view returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);
 function snapshotCumulativesInside(int24 tickLower, int24 tickUpper) external view returns ( int56 tickCumulativeInside, uint160 secondsPerLiquidityInsideX128, uint32 secondsInside );
 }
 pragma solidity >=0.5.0;
 interface IUniswapV3PoolActions {
 function initialize(uint160 sqrtPriceX96) external;
 function mint( address recipient, int24 tickLower, int24 tickUpper, uint128 amount, bytes calldata data ) external returns (uint256 amount0, uint256 amount1);
 function collect( address recipient, int24 tickLower, int24 tickUpper, uint128 amount0Requested, uint128 amount1Requested ) external returns (uint128 amount0, uint128 amount1);
 function burn( int24 tickLower, int24 tickUpper, uint128 amount ) external returns (uint256 amount0, uint256 amount1);
 function swap( address recipient, bool zeroForOne, int256 amountSpecified, uint160 sqrtPriceLimitX96, bytes calldata data ) external returns (int256 amount0, int256 amount1);
 function flash( address recipient, uint256 amount0, uint256 amount1, bytes calldata data ) external;
 function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
 }
 pragma solidity >=0.5.0;
 interface IUniswapV3PoolEvents {
 event Initialize(uint160 sqrtPriceX96, int24 tick);
 event Mint( address sender, address indexed owner, int24 indexed tickLower, int24 indexed tickUpper, uint128 amount, uint256 amount0, uint256 amount1 );
 event Collect( address indexed owner, address recipient, int24 indexed tickLower, int24 indexed tickUpper, uint128 amount0, uint128 amount1 );
 event Burn( address indexed owner, int24 indexed tickLower, int24 indexed tickUpper, uint128 amount, uint256 amount0, uint256 amount1 );
 event Swap( address indexed sender, address indexed recipient, int256 amount0, int256 amount1, uint160 sqrtPriceX96, uint128 liquidity, int24 tick );
 event Flash( address indexed sender, address indexed recipient, uint256 amount0, uint256 amount1, uint256 paid0, uint256 paid1 );
 event IncreaseObservationCardinalityNext( uint16 observationCardinalityNextOld, uint16 observationCardinalityNextNew );
 event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);
 event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
 }
 pragma solidity >=0.5.0;
 interface IUniswapV3PoolOwnerActions {
 function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;
 function collectProtocol( address recipient, uint128 amount0Requested, uint128 amount1Requested ) external returns (uint128 amount0, uint128 amount1);
 }
 pragma solidity 0.7.6;
 contract TwapRelayer is ITwapRelayer {
 using SafeMath for uint256;
 uint256 private constant PRECISION = 10**18;
 uint16 private constant MAX_TOLERANCE = 10;
 address public immutable override factory;
 address public immutable override weth;
 address public override delay;
 address public override owner;
 mapping(address => uint256) public override swapFee;
 mapping(address => uint32) public override twapInterval;
 mapping(address => bool) public override isPairEnabled;
 mapping(address => uint256) public override tokenLimitMin;
 mapping(address => uint256) public override tokenLimitMaxMultiplier;
 mapping(address => uint16) public override tolerance;
 uint256 public override ethTransferGasCost;
 uint256 public override executionGasLimit;
 uint256 public override gasPriceMultiplier;
 constructor( address _factory, address _delay, address _weth ) {
 factory = _factory;
 delay = _delay;
 weth = _weth;
 owner = msg.sender;
 ethTransferGasCost = 2600 + 1504;
 emit DelaySet(_delay);
 emit OwnerSet(msg.sender);
 emit EthTransferGasCostSet(ethTransferGasCost);
 }
 uint256 private locked;
 modifier lock() {
 require(locked == 0, 'TR06');
 locked = 1;
 _;
 locked = 0;
 }
 function setDelay(address _delay) external override {
 require(msg.sender == owner, 'TR00');
 require(_delay != delay, 'TR01');
 require(_delay != address(0), 'TR02');
 delay = _delay;
 emit DelaySet(_delay);
 }
 function setOwner(address _owner) external override {
 require(msg.sender == owner, 'TR00');
 require(_owner != owner, 'TR01');
 require(_owner != address(0), 'TR02');
 owner = _owner;
 emit OwnerSet(_owner);
 }
 function setSwapFee(address pair, uint256 fee) external override {
 require(msg.sender == owner, 'TR00');
 require(fee != swapFee[pair], 'TR01');
 swapFee[pair] = fee;
 emit SwapFeeSet(pair, fee);
 }
 function setTwapInterval(address pair, uint32 interval) external override {
 require(msg.sender == owner, 'TR00');
 require(interval != twapInterval[pair], 'TR01');
 require(interval > 0, 'TR56');
 twapInterval[pair] = interval;
 emit TwapIntervalSet(pair, interval);
 }
 function setPairEnabled(address pair, bool enabled) external override {
 require(msg.sender == owner, 'TR00');
 require(enabled != isPairEnabled[pair], 'TR01');
 isPairEnabled[pair] = enabled;
 emit PairEnabledSet(pair, enabled);
 }
 function setEthTransferGasCost(uint256 gasCost) external override {
 require(msg.sender == owner, 'TR00');
 require(gasCost != ethTransferGasCost, 'TR01');
 ethTransferGasCost = gasCost;
 emit EthTransferGasCostSet(gasCost);
 }
 function setExecutionGasLimit(uint256 limit) external override {
 require(msg.sender == owner, 'TR00');
 require(limit != executionGasLimit, 'TR01');
 executionGasLimit = limit;
 emit ExecutionGasLimitSet(limit);
 }
 function setGasPriceMultiplier(uint256 multiplier) external override {
 require(msg.sender == owner, 'TR00');
 require(multiplier != gasPriceMultiplier, 'TR01');
 gasPriceMultiplier = multiplier;
 emit GasPriceMultiplierSet(multiplier);
 }
 function setTokenLimitMin(address token, uint256 limit) external override {
 require(msg.sender == owner, 'TR00');
 require(limit != tokenLimitMin[token], 'TR01');
 tokenLimitMin[token] = limit;
 emit TokenLimitMinSet(token, limit);
 }
 function setTokenLimitMaxMultiplier(address token, uint256 multiplier) external override {
 require(msg.sender == owner, 'TR00');
 require(multiplier != tokenLimitMaxMultiplier[token], 'TR01');
 require(multiplier <= PRECISION, 'TR3A');
 tokenLimitMaxMultiplier[token] = multiplier;
 emit TokenLimitMaxMultiplierSet(token, multiplier);
 }
 function setTolerance(address pair, uint16 _tolerance) external override {
 require(msg.sender == owner, 'TR00');
 require(_tolerance != tolerance[pair], 'TR01');
 require(_tolerance <= MAX_TOLERANCE, 'TR54');
 tolerance[pair] = _tolerance;
 emit ToleranceSet(pair, _tolerance);
 }
 function sell(SellParams calldata sellParams) external payable override lock returns (uint256 orderId) {
 require( sellParams.to != sellParams.tokenIn && sellParams.to != sellParams.tokenOut && sellParams.to != address(0), 'TR26' );
 if (sellParams.wrapUnwrap && sellParams.tokenIn == weth) {
 require(msg.value == sellParams.amountIn, 'TR59');
 }
 else {
 require(msg.value == 0, 'TR58');
 }
 (address pair, bool inverted) = getPair(sellParams.tokenIn, sellParams.tokenOut);
 require(isPairEnabled[pair], 'TR5A');
 (uint256 amountIn, uint256 amountOut, uint256 fee) = swapExactIn( pair, inverted, sellParams.tokenIn, sellParams.tokenOut, sellParams.amountIn, sellParams.wrapUnwrap, sellParams.to );
 require(amountOut >= sellParams.amountOutMin, 'TR37');
 orderId = ITwapDelay(delay).sell{
 value: calculatePrepay() }
 ( Orders.SellParams( sellParams.tokenIn, sellParams.tokenOut, amountIn, 0, false, address(this), executionGasLimit, sellParams.submitDeadline ) );
 emit Swap( msg.sender, sellParams.tokenIn, sellParams.tokenOut, amountIn, amountOut, sellParams.wrapUnwrap, fee, sellParams.to, orderId );
 }
 function buy(BuyParams calldata buyParams) external payable override lock returns (uint256 orderId) {
 require( buyParams.to != buyParams.tokenIn && buyParams.to != buyParams.tokenOut && buyParams.to != address(0), 'TR26' );
 if (!buyParams.wrapUnwrap || buyParams.tokenIn != weth) {
 require(msg.value == 0, 'TR58');
 }
 (address pair, bool inverted) = getPair(buyParams.tokenIn, buyParams.tokenOut);
 require(isPairEnabled[pair], 'TR5A');
 uint256 balanceBefore = address(this).balance.sub(msg.value);
 (uint256 amountIn, uint256 amountOut, uint256 fee) = swapExactOut( pair, inverted, buyParams.tokenIn, buyParams.tokenOut, buyParams.amountOut, buyParams.wrapUnwrap, buyParams.to );
 require(amountIn <= buyParams.amountInMax, 'TR08');
 orderId = ITwapDelay(delay).sell{
 value: calculatePrepay() }
 ( Orders.SellParams( buyParams.tokenIn, buyParams.tokenOut, amountIn, 0, false, address(this), executionGasLimit, buyParams.submitDeadline ) );
 emit Swap( msg.sender, buyParams.tokenIn, buyParams.tokenOut, amountIn, amountOut, buyParams.wrapUnwrap, fee, buyParams.to, orderId );
 if (buyParams.wrapUnwrap && buyParams.tokenIn == weth) {
 uint256 balanceAfter = address(this).balance;
 if (balanceAfter > balanceBefore) {
 TransferHelper.safeTransferETH(msg.sender, balanceAfter.sub(balanceBefore), ethTransferGasCost);
 }
 }
 }
 function getPair(address tokenA, address tokenB) internal view returns (address pair, bool inverted) {
 inverted = tokenA > tokenB;
 pair = ITwapFactory(factory).getPair(tokenA, tokenB);
 require(pair != address(0), 'TR17');
 }
 function calculatePrepay() internal returns (uint256) {
 require(executionGasLimit > 0, 'TR3D');
 require(gasPriceMultiplier > 0, 'TR3C');
 return ITwapDelay(delay).gasPrice().mul(gasPriceMultiplier).mul(executionGasLimit).div(PRECISION);
 }
 function swapExactIn( address pair, bool inverted, address tokenIn, address tokenOut, uint256 amountIn, bool wrapUnwrap, address to ) internal returns ( uint256 _amountIn, uint256 _amountOut, uint256 fee ) {
 _amountIn = transferIn(tokenIn, amountIn, wrapUnwrap);
 fee = _amountIn.mul(swapFee[pair]).div(PRECISION);
 uint256 amountInMinusFee = _amountIn.sub(fee);
 uint256 calculatedAmountOut = calculateAmountOut(pair, inverted, amountInMinusFee);
 _amountOut = transferOut(to, tokenOut, calculatedAmountOut, wrapUnwrap);
 require(_amountOut <= calculatedAmountOut.add(tolerance[pair]), 'TR2E');
 }
 function swapExactOut( address pair, bool inverted, address tokenIn, address tokenOut, uint256 amountOut, bool wrapUnwrap, address to ) internal returns ( uint256 _amountIn, uint256 _amountOut, uint256 fee ) {
 _amountOut = transferOut(to, tokenOut, amountOut, wrapUnwrap);
 uint256 calculatedAmountIn = calculateAmountIn(pair, inverted, _amountOut);
 uint256 amountInPlusFee = calculatedAmountIn.mul(PRECISION).ceil_div(PRECISION.sub(swapFee[pair]));
 fee = amountInPlusFee.sub(calculatedAmountIn);
 _amountIn = transferIn(tokenIn, amountInPlusFee, wrapUnwrap);
 require(_amountIn >= amountInPlusFee.sub(tolerance[pair]), 'TR2E');
 }
 function calculateAmountIn( address pair, bool inverted, uint256 amountOut ) internal view returns (uint256 amountIn) {
 (uint8 xDecimals, uint8 yDecimals, uint256 price) = getPriceByPairAddress(pair, inverted);
 uint256 decimalsConverter = getDecimalsConverter(xDecimals, yDecimals, inverted);
 amountIn = amountOut.mul(decimalsConverter).ceil_div(price);
 }
 function calculateAmountOut( address pair, bool inverted, uint256 amountIn ) internal view returns (uint256 amountOut) {
 (uint8 xDecimals, uint8 yDecimals, uint256 price) = getPriceByPairAddress(pair, inverted);
 uint256 decimalsConverter = getDecimalsConverter(xDecimals, yDecimals, inverted);
 amountOut = amountIn.mul(price).div(decimalsConverter);
 }
 function getDecimalsConverter( uint8 xDecimals, uint8 yDecimals, bool inverted ) internal pure returns (uint256 decimalsConverter) {
 decimalsConverter = 10**(18 + (inverted ? yDecimals - xDecimals : xDecimals - yDecimals));
 }
 function getPriceByPairAddress(address pair, bool inverted) public view override returns ( uint8 xDecimals, uint8 yDecimals, uint256 price ) {
 uint256 spotPrice;
 uint256 averagePrice;
 (spotPrice, averagePrice, xDecimals, yDecimals) = getPricesFromOracle(pair);
 if (inverted) {
 price = uint256(10**36).div(spotPrice > averagePrice ? spotPrice : averagePrice);
 }
 else {
 price = spotPrice < averagePrice ? spotPrice : averagePrice;
 }
 }
 function getPriceByTokenAddresses(address tokenIn, address tokenOut) public view override returns (uint256 price) {
 (address pair, bool inverted) = getPair(tokenIn, tokenOut);
 (, , price) = getPriceByPairAddress(pair, inverted);
 }
 function getPoolState(address token0, address token1) external view override returns ( uint256 price, uint256 fee, uint256 limitMin0, uint256 limitMax0, uint256 limitMin1, uint256 limitMax1 ) {
 (address pair, ) = getPair(token0, token1);
 require(isPairEnabled[pair], 'TR5A');
 fee = swapFee[pair];
 price = getPriceByTokenAddresses(token0, token1);
 limitMin0 = tokenLimitMin[token0];
 limitMax0 = IERC20(token0).balanceOf(address(this)).mul(tokenLimitMaxMultiplier[token0]).div(PRECISION);
 limitMin1 = tokenLimitMin[token1];
 limitMax1 = IERC20(token1).balanceOf(address(this)).mul(tokenLimitMaxMultiplier[token1]).div(PRECISION);
 }
 function quoteSell( address tokenIn, address tokenOut, uint256 amountIn ) external view override returns (uint256 amountOut) {
 require(amountIn > 0, 'TR24');
 (address pair, bool inverted) = getPair(tokenIn, tokenOut);
 uint256 fee = amountIn.mul(swapFee[pair]).div(PRECISION);
 uint256 amountInMinusFee = amountIn.sub(fee);
 amountOut = calculateAmountOut(pair, inverted, amountInMinusFee);
 checkLimits(tokenOut, amountOut);
 }
 function quoteBuy( address tokenIn, address tokenOut, uint256 amountOut ) external view override returns (uint256 amountIn) {
 require(amountOut > 0, 'TR23');
 (address pair, bool inverted) = getPair(tokenIn, tokenOut);
 checkLimits(tokenOut, amountOut);
 uint256 calculatedAmountIn = calculateAmountIn(pair, inverted, amountOut);
 amountIn = calculatedAmountIn.mul(PRECISION).ceil_div(PRECISION.sub(swapFee[pair]));
 }
 function getPricesFromOracle(address pair) internal view returns ( uint256 spotPrice, uint256 averagePrice, uint8 xDecimals, uint8 yDecimals ) {
 ITwapOracleV3 oracle = ITwapOracleV3(ITwapPair(pair).oracle());
 xDecimals = oracle.xDecimals();
 yDecimals = oracle.yDecimals();
 spotPrice = oracle.getSpotPrice();
 address uniswapPair = oracle.uniswapPair();
 averagePrice = getAveragePrice(pair, uniswapPair, getDecimalsConverter(xDecimals, yDecimals, false));
 }
 function getAveragePrice( address pair, address uniswapPair, uint256 decimalsConverter ) internal view returns (uint256) {
 uint32 secondsAgo = twapInterval[pair];
 require(secondsAgo > 0, 'TR55');
 uint32[] memory secondsAgos = new uint32[](2);
 secondsAgos[0] = secondsAgo;
 secondsAgos[1] = 0;
 (int56[] memory tickCumulatives, ) = IUniswapV3Pool(uniswapPair).observe(secondsAgos);
 int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
 int24 arithmeticMeanTick = int24(tickCumulativesDelta / secondsAgo);
 if (tickCumulativesDelta < 0 && (tickCumulativesDelta % secondsAgo != 0)) arithmeticMeanTick--;
 uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(arithmeticMeanTick);
 if (sqrtRatioX96 <= type(uint128).max) {
 uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
 return FullMath.mulDiv(ratioX192, decimalsConverter, 1 << 192);
 }
 else {
 uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
 return FullMath.mulDiv(ratioX128, decimalsConverter, 1 << 128);
 }
 }
 function transferIn( address token, uint256 amount, bool wrap ) internal returns (uint256) {
 if (amount == 0) {
 return 0;
 }
 if (token == weth) {
 if (wrap) {
 require(msg.value >= amount, 'TR03');
 IWETH(token).deposit{
 value: amount }
 ();
 }
 else {
 TransferHelper.safeTransferFrom(token, msg.sender, address(this), amount);
 }
 return amount;
 }
 else {
 uint256 balanceBefore = IERC20(token).balanceOf(address(this));
 TransferHelper.safeTransferFrom(token, msg.sender, address(this), amount);
 uint256 balanceAfter = IERC20(token).balanceOf(address(this));
 require(balanceAfter > balanceBefore, 'TR2C');
 return balanceAfter.sub(balanceBefore);
 }
 }
 function transferOut( address to, address token, uint256 amount, bool unwrap ) internal returns (uint256) {
 if (amount == 0) {
 return 0;
 }
 checkLimits(token, amount);
 if (token == weth) {
 if (unwrap) {
 IWETH(token).withdraw(amount);
 TransferHelper.safeTransferETH(to, amount, ethTransferGasCost);
 }
 else {
 TransferHelper.safeTransfer(token, to, amount);
 }
 return amount;
 }
 else {
 uint256 balanceBefore = IERC20(token).balanceOf(address(this));
 TransferHelper.safeTransfer(token, to, amount);
 uint256 balanceAfter = IERC20(token).balanceOf(address(this));
 require(balanceBefore > balanceAfter, 'TR2C');
 return balanceBefore.sub(balanceAfter);
 }
 }
 function checkLimits(address token, uint256 amount) internal view {
 require(amount >= tokenLimitMin[token], 'TR03');
 require( amount <= IERC20(token).balanceOf(address(this)).mul(tokenLimitMaxMultiplier[token]).div(PRECISION), 'TR3A' );
 }
 function approve( address token, uint256 amount, address to ) external override lock {
 require(msg.sender == owner, 'TR00');
 require(to != address(0), 'TR02');
 require(IERC20(token).approve(to, amount), 'TR2F');
 emit Approve(token, to, amount);
 }
 function withdraw( address token, uint256 amount, address to ) external override lock {
 require(msg.sender == owner, 'TR00');
 require(to != address(0), 'TR02');
 if (token == address(0)) {
 TransferHelper.safeTransferETH(to, amount, ethTransferGasCost);
 }
 else {
 TransferHelper.safeTransfer(token, to, amount);
 }
 emit Withdraw(token, to, amount);
 }
 receive() external payable {
 }
 }
 pragma solidity 0.7.6;
 interface ITwapDelay {
 event OrderExecuted(uint256 indexed id, bool indexed success, bytes data, uint256 gasSpent, uint256 ethRefunded);
 event RefundFailed(address indexed to, address indexed token, uint256 amount, bytes data);
 event EthRefund(address indexed to, bool indexed success, uint256 value);
 event OwnerSet(address owner);
 event BotSet(address bot, bool isBot);
 event DelaySet(uint256 delay);
 event MaxGasLimitSet(uint256 maxGasLimit);
 event GasPriceInertiaSet(uint256 gasPriceInertia);
 event MaxGasPriceImpactSet(uint256 maxGasPriceImpact);
 event TransferGasCostSet(address token, uint256 gasCost);
 event ToleranceSet(address pair, uint16 amount);
 event OrderDisabled(address pair, Orders.OrderType orderType, bool disabled);
 event UnwrapFailed(address to, uint256 amount);
 event Execute(address sender, uint256 n);
 function factory() external returns (address);
 function owner() external returns (address);
 function isBot(address bot) external returns (bool);
 function tolerance(address pair) external returns (uint16);
 function gasPriceInertia() external returns (uint256);
 function gasPrice() external returns (uint256);
 function maxGasPriceImpact() external returns (uint256);
 function maxGasLimit() external returns (uint256);
 function delay() external returns (uint32);
 function totalShares(address token) external returns (uint256);
 function weth() external returns (address);
 function getTransferGasCost(address token) external returns (uint256);
 function getDepositOrder(uint256 orderId) external returns (Orders.DepositOrder memory order);
 function getWithdrawOrder(uint256 orderId) external returns (Orders.WithdrawOrder memory order);
 function getSellOrder(uint256 orderId) external returns (Orders.SellOrder memory order);
 function getBuyOrder(uint256 orderId) external returns (Orders.BuyOrder memory order);
 function getDepositDisabled(address pair) external returns (bool);
 function getWithdrawDisabled(address pair) external returns (bool);
 function getBuyDisabled(address pair) external returns (bool);
 function getSellDisabled(address pair) external returns (bool);
 function getOrderStatus(uint256 orderId) external view returns (Orders.OrderStatus);
 function setOrderDisabled( address pair, Orders.OrderType orderType, bool disabled ) external payable;
 function setOwner(address _owner) external payable;
 function setBot(address _bot, bool _isBot) external payable;
 function setMaxGasLimit(uint256 _maxGasLimit) external payable;
 function setDelay(uint32 _delay) external payable;
 function setGasPriceInertia(uint256 _gasPriceInertia) external payable;
 function setMaxGasPriceImpact(uint256 _maxGasPriceImpact) external payable;
 function setTransferGasCost(address token, uint256 gasCost) external payable;
 function setTolerance(address pair, uint16 amount) external payable;
 function deposit(Orders.DepositParams memory depositParams) external payable returns (uint256 orderId);
 function withdraw(Orders.WithdrawParams memory withdrawParams) external payable returns (uint256 orderId);
 function sell(Orders.SellParams memory sellParams) external payable returns (uint256 orderId);
 function buy(Orders.BuyParams memory buyParams) external payable returns (uint256 orderId);
 function execute(uint256 n) external payable;
 function retryRefund(uint256 orderId) external;
 function cancelOrder(uint256 orderId) external;
 }
 pragma solidity 0.7.6;
 interface ITwapOracleV3 is ITwapOracle {
 event TwapIntervalSet(uint32 interval);
 function setTwapInterval(uint32 _interval) external;
 }
 pragma solidity 0.7.6;
 interface ITwapPair is ITwapERC20, IReserves {
 event Mint(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 liquidityOut, address indexed to);
 event Burn(address indexed sender, uint256 amount0Out, uint256 amount1Out, uint256 liquidityIn, address indexed to);
 event Swap( address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to );
 event SetMintFee(uint256 fee);
 event SetBurnFee(uint256 fee);
 event SetSwapFee(uint256 fee);
 event SetOracle(address account);
 event SetTrader(address trader);
 function MINIMUM_LIQUIDITY() external pure returns (uint256);
 function factory() external view returns (address);
 function token0() external view returns (address);
 function token1() external view returns (address);
 function oracle() external view returns (address);
 function trader() external view returns (address);
 function mintFee() external view returns (uint256);
 function setMintFee(uint256 fee) external;
 function mint(address to) external returns (uint256 liquidity);
 function burnFee() external view returns (uint256);
 function setBurnFee(uint256 fee) external;
 function burn(address to) external returns (uint256 amount0, uint256 amount1);
 function swapFee() external view returns (uint256);
 function setSwapFee(uint256 fee) external;
 function setOracle(address account) external;
 function setTrader(address account) external;
 function collect(address to) external;
 function swap( uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data ) external;
 function sync() external;
 function initialize( address _token0, address _token1, address _oracle, address _trader ) external;
 function getSwapAmount0In(uint256 amount1Out, bytes calldata data) external view returns (uint256 swapAmount0In);
 function getSwapAmount1In(uint256 amount0Out, bytes calldata data) external view returns (uint256 swapAmount1In);
 function getSwapAmount0Out(uint256 amount1In, bytes calldata data) external view returns (uint256 swapAmount0Out);
 function getSwapAmount1Out(uint256 amount0In, bytes calldata data) external view returns (uint256 swapAmount1Out);
 function getDepositAmount0In(uint256 amount0, bytes calldata data) external view returns (uint256 depositAmount0In);
 function getDepositAmount1In(uint256 amount1, bytes calldata data) external view returns (uint256 depositAmount1In);
 }
 pragma solidity 0.7.6;
 interface ITwapFactory {
 event PairCreated(address indexed token0, address indexed token1, address pair, uint256);
 event OwnerSet(address owner);
 function owner() external view returns (address);
 function getPair(address tokenA, address tokenB) external view returns (address pair);
 function allPairs(uint256) external view returns (address pair);
 function allPairsLength() external view returns (uint256);
 function createPair( address tokenA, address tokenB, address oracle, address trader ) external returns (address pair);
 function setOwner(address) external;
 function setMintFee( address tokenA, address tokenB, uint256 fee ) external;
 function setBurnFee( address tokenA, address tokenB, uint256 fee ) external;
 function setSwapFee( address tokenA, address tokenB, uint256 fee ) external;
 function setOracle( address tokenA, address tokenB, address oracle ) external;
 function setTrader( address tokenA, address tokenB, address trader ) external;
 function collect( address tokenA, address tokenB, address to ) external;
 function withdraw( address tokenA, address tokenB, uint256 amount, address to ) external;
 }
 pragma solidity 0.7.6;
 library SafeMath {
 int256 private constant _INT256_MIN = -2**255;
 function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
 require((z = x + y) >= x, 'SM4E');
 }
 function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
 z = sub(x, y, 'SM12');
 }
 function sub( uint256 x, uint256 y, string memory message ) internal pure returns (uint256 z) {
 require((z = x - y) <= x, message);
 }
 function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
 require(y == 0 || (z = x * y) / y == x, 'SM2A');
 }
 function div(uint256 a, uint256 b) internal pure returns (uint256) {
 require(b > 0, 'SM43');
 return a / b;
 }
 function ceil_div(uint256 a, uint256 b) internal pure returns (uint256 c) {
 c = div(a, b);
 if (a != mul(b, c)) {
 return add(c, 1);
 }
 }
 function toUint32(uint256 n) internal pure returns (uint32) {
 require(n <= type(uint32).max, 'SM50');
 return uint32(n);
 }
 function toUint112(uint256 n) internal pure returns (uint112) {
 require(n <= type(uint112).max, 'SM51');
 return uint112(n);
 }
 function toInt256(uint256 unsigned) internal pure returns (int256 signed) {
 require(unsigned <= uint256(type(int256).max), 'SM34');
 signed = int256(unsigned);
 }
 function add(int256 a, int256 b) internal pure returns (int256 c) {
 c = a + b;
 require((b >= 0 && c >= a) || (b < 0 && c < a), 'SM4D');
 }
 function sub(int256 a, int256 b) internal pure returns (int256 c) {
 c = a - b;
 require((b >= 0 && c <= a) || (b < 0 && c > a), 'SM11');
 }
 function mul(int256 a, int256 b) internal pure returns (int256 c) {
 if (a == 0) {
 return 0;
 }
 require(!(a == -1 && b == _INT256_MIN), 'SM29');
 c = a * b;
 require(c / a == b, 'SM29');
 }
 function div(int256 a, int256 b) internal pure returns (int256) {
 require(b != 0, 'SM43');
 require(!(b == -1 && a == _INT256_MIN), 'SM42');
 return a / b;
 }
 function neg_floor_div(int256 a, int256 b) internal pure returns (int256 c) {
 c = div(a, b);
 if ((a < 0 && b > 0) || (a >= 0 && b < 0)) {
 if (a != mul(b, c)) {
 c = sub(c, 1);
 }
 }
 }
 }
 pragma solidity 0.7.6;
 library Orders {
 using SafeMath for uint256;
 using TokenShares for TokenShares.Data;
 using TransferHelper for address;
 enum OrderType {
 Empty, Deposit, Withdraw, Sell, Buy }
 enum OrderStatus {
 NonExistent, EnqueuedWaiting, EnqueuedReady, ExecutedSucceeded, ExecutedFailed, Canceled }
 event MaxGasLimitSet(uint256 maxGasLimit);
 event GasPriceInertiaSet(uint256 gasPriceInertia);
 event MaxGasPriceImpactSet(uint256 maxGasPriceImpact);
 event TransferGasCostSet(address token, uint256 gasCost);
 event DepositEnqueued(uint256 indexed orderId, uint32 validAfterTimestamp, uint256 gasPrice);
 event WithdrawEnqueued(uint256 indexed orderId, uint32 validAfterTimestamp, uint256 gasPrice);
 event SellEnqueued(uint256 indexed orderId, uint32 validAfterTimestamp, uint256 gasPrice);
 event BuyEnqueued(uint256 indexed orderId, uint32 validAfterTimestamp, uint256 gasPrice);
 event OrderDisabled(address pair, Orders.OrderType orderType, bool disabled);
 event RefundFailed(address indexed to, address indexed token, uint256 amount, bytes data);
 uint8 private constant DEPOSIT_TYPE = 1;
 uint8 private constant WITHDRAW_TYPE = 2;
 uint8 private constant BUY_TYPE = 3;
 uint8 private constant BUY_INVERTED_TYPE = 4;
 uint8 private constant SELL_TYPE = 5;
 uint8 private constant SELL_INVERTED_TYPE = 6;
 uint8 private constant UNWRAP_NOT_FAILED = 0;
 uint8 private constant KEEP_NOT_FAILED = 1;
 uint8 private constant UNWRAP_FAILED = 2;
 uint8 private constant KEEP_FAILED = 3;
 uint256 private constant ETHER_TRANSFER_COST = 2600 + 1504;
 uint256 private constant BUFFER_COST = 10000;
 uint256 private constant ORDER_EXECUTED_EVENT_COST = 3700;
 uint256 private constant EXECUTE_PREPARATION_COST = 55000;
 uint256 public constant ETHER_TRANSFER_CALL_COST = 10000;
 uint256 public constant PAIR_TRANSFER_COST = 55000;
 uint256 public constant REFUND_BASE_COST = 2 * ETHER_TRANSFER_COST + BUFFER_COST + ORDER_EXECUTED_EVENT_COST;
 uint256 public constant ORDER_BASE_COST = EXECUTE_PREPARATION_COST + REFUND_BASE_COST;
 uint8 private constant DEPOSIT_MASK = uint8(1 << uint8(OrderType.Deposit));
 uint8 private constant WITHDRAW_MASK = uint8(1 << uint8(OrderType.Withdraw));
 uint8 private constant SELL_MASK = uint8(1 << uint8(OrderType.Sell));
 uint8 private constant BUY_MASK = uint8(1 << uint8(OrderType.Buy));
 struct PairInfo {
 address pair;
 address token0;
 address token1;
 }
 struct Data {
 uint32 delay;
 uint256 newestOrderId;
 uint256 lastProcessedOrderId;
 mapping(uint256 => StoredOrder) orderQueue;
 address factory;
 uint256 maxGasLimit;
 uint256 gasPrice;
 uint256 gasPriceInertia;
 uint256 maxGasPriceImpact;
 mapping(uint32 => PairInfo) pairs;
 mapping(address => uint256) transferGasCosts;
 mapping(uint256 => bool) canceled;
 mapping(address => uint8) orderDisabled;
 }
 struct StoredOrder {
 uint8 orderType;
 uint32 validAfterTimestamp;
 uint8 unwrapAndFailure;
 uint32 timestamp;
 uint32 gasLimit;
 uint32 gasPrice;
 uint112 liquidity;
 uint112 value0;
 uint112 value1;
 uint32 pairId;
 address to;
 uint32 minSwapPrice;
 uint32 maxSwapPrice;
 bool swap;
 uint256 priceAccumulator;
 uint112 amountLimit0;
 uint112 amountLimit1;
 }
 struct DepositOrder {
 uint32 pairId;
 uint256 share0;
 uint256 share1;
 uint256 minSwapPrice;
 uint256 maxSwapPrice;
 bool unwrap;
 bool swap;
 address to;
 uint256 gasPrice;
 uint256 gasLimit;
 uint32 validAfterTimestamp;
 uint256 priceAccumulator;
 uint32 timestamp;
 }
 struct WithdrawOrder {
 uint32 pairId;
 uint256 liquidity;
 uint256 amount0Min;
 uint256 amount1Min;
 bool unwrap;
 address to;
 uint256 gasPrice;
 uint256 gasLimit;
 uint32 validAfterTimestamp;
 }
 struct SellOrder {
 uint32 pairId;
 bool inverse;
 uint256 shareIn;
 uint256 amountOutMin;
 bool unwrap;
 address to;
 uint256 gasPrice;
 uint256 gasLimit;
 uint32 validAfterTimestamp;
 uint256 priceAccumulator;
 uint32 timestamp;
 }
 struct BuyOrder {
 uint32 pairId;
 bool inverse;
 uint256 shareInMax;
 uint256 amountOut;
 bool unwrap;
 address to;
 uint256 gasPrice;
 uint256 gasLimit;
 uint32 validAfterTimestamp;
 uint256 priceAccumulator;
 uint32 timestamp;
 }
 function decodeType(uint256 internalType) internal pure returns (OrderType orderType) {
 if (internalType == DEPOSIT_TYPE) {
 orderType = OrderType.Deposit;
 }
 else if (internalType == WITHDRAW_TYPE) {
 orderType = OrderType.Withdraw;
 }
 else if (internalType == BUY_TYPE) {
 orderType = OrderType.Buy;
 }
 else if (internalType == BUY_INVERTED_TYPE) {
 orderType = OrderType.Buy;
 }
 else if (internalType == SELL_TYPE) {
 orderType = OrderType.Sell;
 }
 else if (internalType == SELL_INVERTED_TYPE) {
 orderType = OrderType.Sell;
 }
 else {
 orderType = OrderType.Empty;
 }
 }
 function getOrder(Data storage data, uint256 orderId) internal view returns (OrderType orderType, uint32 validAfterTimestamp) {
 StoredOrder storage order = data.orderQueue[orderId];
 validAfterTimestamp = order.validAfterTimestamp;
 orderType = decodeType(order.orderType);
 }
 function getOrderStatus(Data storage data, uint256 orderId) internal view returns (OrderStatus orderStatus) {
 if (orderId > data.newestOrderId) {
 return OrderStatus.NonExistent;
 }
 if (data.canceled[orderId]) {
 return OrderStatus.Canceled;
 }
 if (isRefundFailed(data, orderId)) {
 return OrderStatus.ExecutedFailed;
 }
 (OrderType orderType, uint32 validAfterTimestamp) = getOrder(data, orderId);
 if (orderType == OrderType.Empty) {
 return OrderStatus.ExecutedSucceeded;
 }
 if (validAfterTimestamp >= block.timestamp) {
 return OrderStatus.EnqueuedWaiting;
 }
 return OrderStatus.EnqueuedReady;
 }
 function getPair( Data storage data, address tokenA, address tokenB ) internal returns ( address pair, uint32 pairId, bool inverted ) {
 inverted = tokenA > tokenB;
 (address token0, address token1) = inverted ? (tokenB, tokenA) : (tokenA, tokenB);
 pair = ITwapFactory(data.factory).getPair(token0, token1);
 require(pair != address(0), 'OS17');
 pairId = uint32(bytes4(keccak256(abi.encodePacked(pair))));
 if (data.pairs[pairId].pair == address(0)) {
 data.pairs[pairId] = PairInfo(pair, token0, token1);
 }
 }
 function getPairInfo(Data storage data, uint32 pairId) internal view returns ( address pair, address token0, address token1 ) {
 PairInfo storage info = data.pairs[pairId];
 pair = info.pair;
 token0 = info.token0;
 token1 = info.token1;
 }
 function getDepositDisabled(Data storage data, address pair) internal view returns (bool) {
 return data.orderDisabled[pair] & DEPOSIT_MASK != 0;
 }
 function getWithdrawDisabled(Data storage data, address pair) internal view returns (bool) {
 return data.orderDisabled[pair] & WITHDRAW_MASK != 0;
 }
 function getSellDisabled(Data storage data, address pair) internal view returns (bool) {
 return data.orderDisabled[pair] & SELL_MASK != 0;
 }
 function getBuyDisabled(Data storage data, address pair) internal view returns (bool) {
 return data.orderDisabled[pair] & BUY_MASK != 0;
 }
 function getDepositOrder(Data storage data, uint256 index) public view returns ( DepositOrder memory order, uint256 amountLimit0, uint256 amountLimit1 ) {
 StoredOrder memory stored = data.orderQueue[index];
 require(stored.orderType == DEPOSIT_TYPE, 'OS32');
 order.pairId = stored.pairId;
 order.share0 = stored.value0;
 order.share1 = stored.value1;
 order.minSwapPrice = float32ToUint(stored.minSwapPrice);
 order.maxSwapPrice = float32ToUint(stored.maxSwapPrice);
 order.unwrap = getUnwrap(stored.unwrapAndFailure);
 order.swap = stored.swap;
 order.to = stored.to;
 order.gasPrice = uint32ToGasPrice(stored.gasPrice);
 order.gasLimit = stored.gasLimit;
 order.validAfterTimestamp = stored.validAfterTimestamp;
 order.priceAccumulator = stored.priceAccumulator;
 order.timestamp = stored.timestamp;
 amountLimit0 = stored.amountLimit0;
 amountLimit1 = stored.amountLimit1;
 }
 function getWithdrawOrder(Data storage data, uint256 index) public view returns (WithdrawOrder memory order) {
 StoredOrder memory stored = data.orderQueue[index];
 require(stored.orderType == WITHDRAW_TYPE, 'OS32');
 order.pairId = stored.pairId;
 order.liquidity = stored.liquidity;
 order.amount0Min = stored.value0;
 order.amount1Min = stored.value1;
 order.unwrap = getUnwrap(stored.unwrapAndFailure);
 order.to = stored.to;
 order.gasPrice = uint32ToGasPrice(stored.gasPrice);
 order.gasLimit = stored.gasLimit;
 order.validAfterTimestamp = stored.validAfterTimestamp;
 }
 function getSellOrder(Data storage data, uint256 index) public view returns (SellOrder memory order, uint256 amountLimit) {
 StoredOrder memory stored = data.orderQueue[index];
 require(stored.orderType == SELL_TYPE || stored.orderType == SELL_INVERTED_TYPE, 'OS32');
 order.pairId = stored.pairId;
 order.inverse = stored.orderType == SELL_INVERTED_TYPE;
 order.shareIn = stored.value0;
 order.amountOutMin = stored.value1;
 order.unwrap = getUnwrap(stored.unwrapAndFailure);
 order.to = stored.to;
 order.gasPrice = uint32ToGasPrice(stored.gasPrice);
 order.gasLimit = stored.gasLimit;
 order.validAfterTimestamp = stored.validAfterTimestamp;
 order.priceAccumulator = stored.priceAccumulator;
 order.timestamp = stored.timestamp;
 amountLimit = stored.amountLimit0;
 }
 function getBuyOrder(Data storage data, uint256 index) public view returns (BuyOrder memory order, uint256 amountLimit) {
 StoredOrder memory stored = data.orderQueue[index];
 require(stored.orderType == BUY_TYPE || stored.orderType == BUY_INVERTED_TYPE, 'OS32');
 order.pairId = stored.pairId;
 order.inverse = stored.orderType == BUY_INVERTED_TYPE;
 order.shareInMax = stored.value0;
 order.amountOut = stored.value1;
 order.unwrap = getUnwrap(stored.unwrapAndFailure);
 order.to = stored.to;
 order.gasPrice = uint32ToGasPrice(stored.gasPrice);
 order.gasLimit = stored.gasLimit;
 order.validAfterTimestamp = stored.validAfterTimestamp;
 order.timestamp = stored.timestamp;
 order.priceAccumulator = stored.priceAccumulator;
 amountLimit = stored.amountLimit0;
 }
 function getFailedOrderType(Data storage data, uint256 orderId) internal view returns (OrderType orderType, uint32 validAfterTimestamp) {
 require(isRefundFailed(data, orderId), 'OS21');
 (orderType, validAfterTimestamp) = getOrder(data, orderId);
 }
 function getUnwrap(uint8 unwrapAndFailure) private pure returns (bool) {
 return unwrapAndFailure == UNWRAP_FAILED || unwrapAndFailure == UNWRAP_NOT_FAILED;
 }
 function getUnwrapAndFailure(bool unwrap) private pure returns (uint8) {
 return unwrap ? UNWRAP_NOT_FAILED : KEEP_NOT_FAILED;
 }
 function timestampToUint32(uint256 timestamp) private pure returns (uint32 timestamp32) {
 if (timestamp == type(uint256).max) {
 return type(uint32).max;
 }
 timestamp32 = timestamp.toUint32();
 }
 function gasPriceToUint32(uint256 gasPrice) private pure returns (uint32 gasPrice32) {
 require((gasPrice / 1e6) * 1e6 == gasPrice, 'OS3C');
 gasPrice32 = (gasPrice / 1e6).toUint32();
 }
 function uint32ToGasPrice(uint32 gasPrice32) public pure returns (uint256 gasPrice) {
 gasPrice = uint256(gasPrice32) * 1e6;
 }
 function uintToFloat32(uint256 number) internal pure returns (uint32 float32) {
 if (number < 1 << 24) {
 return uint32(number << 8);
 }
 uint32 exponent;
 for (; exponent < 256 - 24; ++exponent) {
 if (number & 1 == 1) {
 break;
 }
 number = number >> 1;
 }
 require(number < 1 << 24, 'OS1A');
 float32 = uint32(number << 8) | exponent;
 }
 function float32ToUint(uint32 float32) internal pure returns (uint256 number) {
 uint256 exponent = float32 & 0xFF;
 require(exponent <= 256 - 24, 'OS1B');
 uint256 mantissa = (float32 & 0xFFFFFF00) >> 8;
 number = mantissa << exponent;
 }
 function setOrderDisabled( Data storage data, address pair, Orders.OrderType orderType, bool disabled ) external {
 require(orderType != Orders.OrderType.Empty, 'OS32');
 uint8 currentSettings = data.orderDisabled[pair];
 uint8 mask = uint8(1 << uint8(orderType));
 if (disabled) {
 currentSettings = currentSettings | mask;
 }
 else {
 currentSettings = currentSettings & (mask ^ 0xff);
 }
 require(currentSettings != data.orderDisabled[pair], 'OS01');
 data.orderDisabled[pair] = currentSettings;
 emit OrderDisabled(pair, orderType, disabled);
 }
 function enqueueDepositOrder( Data storage data, DepositOrder memory depositOrder, uint256 amountIn0, uint256 amountIn1 ) internal {
 ++data.newestOrderId;
 emit DepositEnqueued(data.newestOrderId, depositOrder.validAfterTimestamp, depositOrder.gasPrice);
 data.orderQueue[data.newestOrderId] = StoredOrder( DEPOSIT_TYPE, depositOrder.validAfterTimestamp, getUnwrapAndFailure(depositOrder.unwrap), depositOrder.timestamp, depositOrder.gasLimit.toUint32(), gasPriceToUint32(depositOrder.gasPrice), 0, depositOrder.share0.toUint112(), depositOrder.share1.toUint112(), depositOrder.pairId, depositOrder.to, uintToFloat32(depositOrder.minSwapPrice), uintToFloat32(depositOrder.maxSwapPrice), depositOrder.swap, depositOrder.priceAccumulator, amountIn0.toUint112(), amountIn1.toUint112() );
 }
 function enqueueWithdrawOrder(Data storage data, WithdrawOrder memory withdrawOrder) internal {
 ++data.newestOrderId;
 emit WithdrawEnqueued(data.newestOrderId, withdrawOrder.validAfterTimestamp, withdrawOrder.gasPrice);
 data.orderQueue[data.newestOrderId] = StoredOrder( WITHDRAW_TYPE, withdrawOrder.validAfterTimestamp, getUnwrapAndFailure(withdrawOrder.unwrap), 0, withdrawOrder.gasLimit.toUint32(), gasPriceToUint32(withdrawOrder.gasPrice), withdrawOrder.liquidity.toUint112(), withdrawOrder.amount0Min.toUint112(), withdrawOrder.amount1Min.toUint112(), withdrawOrder.pairId, withdrawOrder.to, 0, 0, false, 0, 0, 0 );
 }
 function enqueueSellOrder( Data storage data, SellOrder memory sellOrder, uint256 amountIn ) internal {
 ++data.newestOrderId;
 emit SellEnqueued(data.newestOrderId, sellOrder.validAfterTimestamp, sellOrder.gasPrice);
 data.orderQueue[data.newestOrderId] = StoredOrder( sellOrder.inverse ? SELL_INVERTED_TYPE : SELL_TYPE, sellOrder.validAfterTimestamp, getUnwrapAndFailure(sellOrder.unwrap), sellOrder.timestamp, sellOrder.gasLimit.toUint32(), gasPriceToUint32(sellOrder.gasPrice), 0, sellOrder.shareIn.toUint112(), sellOrder.amountOutMin.toUint112(), sellOrder.pairId, sellOrder.to, 0, 0, false, sellOrder.priceAccumulator, amountIn.toUint112(), 0 );
 }
 function enqueueBuyOrder( Data storage data, BuyOrder memory buyOrder, uint256 amountInMax ) internal {
 ++data.newestOrderId;
 emit BuyEnqueued(data.newestOrderId, buyOrder.validAfterTimestamp, buyOrder.gasPrice);
 data.orderQueue[data.newestOrderId] = StoredOrder( buyOrder.inverse ? BUY_INVERTED_TYPE : BUY_TYPE, buyOrder.validAfterTimestamp, getUnwrapAndFailure(buyOrder.unwrap), buyOrder.timestamp, buyOrder.gasLimit.toUint32(), gasPriceToUint32(buyOrder.gasPrice), 0, buyOrder.shareInMax.toUint112(), buyOrder.amountOut.toUint112(), buyOrder.pairId, buyOrder.to, 0, 0, false, buyOrder.priceAccumulator, amountInMax.toUint112(), 0 );
 }
 function isRefundFailed(Data storage data, uint256 index) internal view returns (bool) {
 uint8 unwrapAndFailure = data.orderQueue[index].unwrapAndFailure;
 return unwrapAndFailure == UNWRAP_FAILED || unwrapAndFailure == KEEP_FAILED;
 }
 function markRefundFailed(Data storage data) internal {
 StoredOrder storage stored = data.orderQueue[data.lastProcessedOrderId];
 stored.unwrapAndFailure = stored.unwrapAndFailure == UNWRAP_NOT_FAILED ? UNWRAP_FAILED : KEEP_FAILED;
 }
 struct DepositParams {
 address token0;
 address token1;
 uint256 amount0;
 uint256 amount1;
 uint256 minSwapPrice;
 uint256 maxSwapPrice;
 bool wrap;
 bool swap;
 address to;
 uint256 gasLimit;
 uint32 submitDeadline;
 }
 function deposit( Data storage data, DepositParams calldata depositParams, TokenShares.Data storage tokenShares ) external {
 {
 uint256 token0TransferCost = data.transferGasCosts[depositParams.token0];
 uint256 token1TransferCost = data.transferGasCosts[depositParams.token1];
 require(token0TransferCost != 0 && token1TransferCost != 0, 'OS0F');
 checkOrderParams( data, depositParams.to, depositParams.gasLimit, depositParams.submitDeadline, ORDER_BASE_COST.add(token0TransferCost).add(token1TransferCost) );
 }
 require(depositParams.amount0 != 0 || depositParams.amount1 != 0, 'OS25');
 (address pairAddress, uint32 pairId, bool inverted) = getPair(data, depositParams.token0, depositParams.token1);
 require(!getDepositDisabled(data, pairAddress), 'OS46');
 {
 uint256 value = msg.value;
 if (depositParams.wrap) {
 if (depositParams.token0 == tokenShares.weth) {
 value = msg.value.sub(depositParams.amount0, 'OS1E');
 }
 else if (depositParams.token1 == tokenShares.weth) {
 value = msg.value.sub(depositParams.amount1, 'OS1E');
 }
 }
 allocateGasRefund(data, value, depositParams.gasLimit);
 }
 uint256 shares0 = tokenShares.amountToShares( inverted ? depositParams.token1 : depositParams.token0, inverted ? depositParams.amount1 : depositParams.amount0, depositParams.wrap );
 uint256 shares1 = tokenShares.amountToShares( inverted ? depositParams.token0 : depositParams.token1, inverted ? depositParams.amount0 : depositParams.amount1, depositParams.wrap );
 (uint256 priceAccumulator, uint32 timestamp) = ITwapOracle(ITwapPair(pairAddress).oracle()).getPriceInfo();
 enqueueDepositOrder( data, DepositOrder( pairId, shares0, shares1, depositParams.minSwapPrice, depositParams.maxSwapPrice, depositParams.wrap, depositParams.swap, depositParams.to, data.gasPrice, depositParams.gasLimit, timestamp + data.delay, priceAccumulator, timestamp ), inverted ? depositParams.amount1 : depositParams.amount0, inverted ? depositParams.amount0 : depositParams.amount1 );
 }
 struct WithdrawParams {
 address token0;
 address token1;
 uint256 liquidity;
 uint256 amount0Min;
 uint256 amount1Min;
 bool unwrap;
 address to;
 uint256 gasLimit;
 uint32 submitDeadline;
 }
 function withdraw(Data storage data, WithdrawParams calldata withdrawParams) external {
 (address pair, uint32 pairId, bool inverted) = getPair(data, withdrawParams.token0, withdrawParams.token1);
 require(!getWithdrawDisabled(data, pair), 'OS0A');
 checkOrderParams( data, withdrawParams.to, withdrawParams.gasLimit, withdrawParams.submitDeadline, ORDER_BASE_COST.add(PAIR_TRANSFER_COST) );
 require(withdrawParams.liquidity != 0, 'OS22');
 allocateGasRefund(data, msg.value, withdrawParams.gasLimit);
 pair.safeTransferFrom(msg.sender, address(this), withdrawParams.liquidity);
 enqueueWithdrawOrder( data, WithdrawOrder( pairId, withdrawParams.liquidity, inverted ? withdrawParams.amount1Min : withdrawParams.amount0Min, inverted ? withdrawParams.amount0Min : withdrawParams.amount1Min, withdrawParams.unwrap, withdrawParams.to, data.gasPrice, withdrawParams.gasLimit, timestampToUint32(block.timestamp) + data.delay ) );
 }
 struct SellParams {
 address tokenIn;
 address tokenOut;
 uint256 amountIn;
 uint256 amountOutMin;
 bool wrapUnwrap;
 address to;
 uint256 gasLimit;
 uint32 submitDeadline;
 }
 function sell( Data storage data, SellParams calldata sellParams, TokenShares.Data storage tokenShares ) external {
 uint256 tokenTransferCost = data.transferGasCosts[sellParams.tokenIn];
 require(tokenTransferCost != 0, 'OS0F');
 checkOrderParams( data, sellParams.to, sellParams.gasLimit, sellParams.submitDeadline, ORDER_BASE_COST.add(tokenTransferCost) );
 require(sellParams.amountIn != 0, 'OS24');
 (address pairAddress, uint32 pairId, bool inverted) = getPair(data, sellParams.tokenIn, sellParams.tokenOut);
 require(!getSellDisabled(data, pairAddress), 'OS13');
 uint256 value = msg.value;
 if (sellParams.tokenIn == tokenShares.weth && sellParams.wrapUnwrap) {
 value = msg.value.sub(sellParams.amountIn, 'OS1E');
 }
 allocateGasRefund(data, value, sellParams.gasLimit);
 uint256 shares = tokenShares.amountToShares(sellParams.tokenIn, sellParams.amountIn, sellParams.wrapUnwrap);
 (uint256 priceAccumulator, uint32 timestamp) = ITwapOracle(ITwapPair(pairAddress).oracle()).getPriceInfo();
 enqueueSellOrder( data, SellOrder( pairId, inverted, shares, sellParams.amountOutMin, sellParams.wrapUnwrap, sellParams.to, data.gasPrice, sellParams.gasLimit, timestamp + data.delay, priceAccumulator, timestamp ), sellParams.amountIn );
 }
 struct BuyParams {
 address tokenIn;
 address tokenOut;
 uint256 amountInMax;
 uint256 amountOut;
 bool wrapUnwrap;
 address to;
 uint256 gasLimit;
 uint32 submitDeadline;
 }
 function buy( Data storage data, BuyParams calldata buyParams, TokenShares.Data storage tokenShares ) external {
 uint256 tokenTransferCost = data.transferGasCosts[buyParams.tokenIn];
 require(tokenTransferCost != 0, 'OS0F');
 checkOrderParams( data, buyParams.to, buyParams.gasLimit, buyParams.submitDeadline, ORDER_BASE_COST.add(tokenTransferCost) );
 require(buyParams.amountOut != 0, 'OS23');
 (address pairAddress, uint32 pairId, bool inverted) = getPair(data, buyParams.tokenIn, buyParams.tokenOut);
 require(!getBuyDisabled(data, pairAddress), 'OS49');
 uint256 value = msg.value;
 if (buyParams.tokenIn == tokenShares.weth && buyParams.wrapUnwrap) {
 value = msg.value.sub(buyParams.amountInMax, 'OS1E');
 }
 allocateGasRefund(data, value, buyParams.gasLimit);
 uint256 shares = tokenShares.amountToShares(buyParams.tokenIn, buyParams.amountInMax, buyParams.wrapUnwrap);
 (uint256 priceAccumulator, uint32 timestamp) = ITwapOracle(ITwapPair(pairAddress).oracle()).getPriceInfo();
 enqueueBuyOrder( data, BuyOrder( pairId, inverted, shares, buyParams.amountOut, buyParams.wrapUnwrap, buyParams.to, data.gasPrice, buyParams.gasLimit, timestamp + data.delay, priceAccumulator, timestamp ), buyParams.amountInMax );
 }
 function checkOrderParams( Data storage data, address to, uint256 gasLimit, uint32 submitDeadline, uint256 minGasLimit ) private view {
 require(submitDeadline >= block.timestamp, 'OS04');
 require(gasLimit <= data.maxGasLimit, 'OS3E');
 require(gasLimit >= minGasLimit, 'OS3D');
 require(to != address(0), 'OS26');
 }
 function allocateGasRefund( Data storage data, uint256 value, uint256 gasLimit ) private returns (uint256 futureFee) {
 futureFee = data.gasPrice.mul(gasLimit);
 require(value >= futureFee, 'OS1E');
 if (value > futureFee) {
 TransferHelper.safeTransferETH(msg.sender, value.sub(futureFee), data.transferGasCosts[address(0)]);
 }
 }
 function updateGasPrice(Data storage data, uint256 gasUsed) external {
 uint256 scale = Math.min(gasUsed, data.maxGasPriceImpact);
 uint256 updated = data.gasPrice.mul(data.gasPriceInertia.sub(scale)).add(tx.gasprice.mul(scale)).div( data.gasPriceInertia );
 data.gasPrice = updated - (updated % 1e6);
 }
 function setMaxGasLimit(Data storage data, uint256 _maxGasLimit) external {
 require(_maxGasLimit != data.maxGasLimit, 'OS01');
 require(_maxGasLimit <= 10000000, 'OS2B');
 data.maxGasLimit = _maxGasLimit;
 emit MaxGasLimitSet(_maxGasLimit);
 }
 function setGasPriceInertia(Data storage data, uint256 _gasPriceInertia) external {
 require(_gasPriceInertia != data.gasPriceInertia, 'OS01');
 require(_gasPriceInertia >= 1, 'OS35');
 data.gasPriceInertia = _gasPriceInertia;
 emit GasPriceInertiaSet(_gasPriceInertia);
 }
 function setMaxGasPriceImpact(Data storage data, uint256 _maxGasPriceImpact) external {
 require(_maxGasPriceImpact != data.maxGasPriceImpact, 'OS01');
 require(_maxGasPriceImpact <= data.gasPriceInertia, 'OS33');
 data.maxGasPriceImpact = _maxGasPriceImpact;
 emit MaxGasPriceImpactSet(_maxGasPriceImpact);
 }
 function setTransferGasCost( Data storage data, address token, uint256 gasCost ) external {
 require(gasCost != data.transferGasCosts[token], 'OS01');
 data.transferGasCosts[token] = gasCost;
 emit TransferGasCostSet(token, gasCost);
 }
 function refundLiquidity( address pair, address to, uint256 liquidity, bytes4 selector ) internal returns (bool) {
 if (liquidity == 0) {
 return true;
 }
 (bool success, bytes memory data) = address(this).call{
 gas: PAIR_TRANSFER_COST }
 ( abi.encodeWithSelector(selector, pair, to, liquidity, false) );
 if (!success) {
 emit RefundFailed(to, pair, liquidity, data);
 }
 return success;
 }
 function getNextOrder(Data storage data) internal view returns (OrderType orderType, uint256 validAfterTimestamp) {
 return getOrder(data, data.lastProcessedOrderId + 1);
 }
 function dequeueCanceledOrder(Data storage data) internal {
 ++data.lastProcessedOrderId;
 }
 function dequeueDepositOrder(Data storage data) external returns ( DepositOrder memory order, uint256 amountLimit0, uint256 amountLimit1 ) {
 ++data.lastProcessedOrderId;
 (order, amountLimit0, amountLimit1) = getDepositOrder(data, data.lastProcessedOrderId);
 }
 function dequeueWithdrawOrder(Data storage data) external returns (WithdrawOrder memory order) {
 ++data.lastProcessedOrderId;
 order = getWithdrawOrder(data, data.lastProcessedOrderId);
 }
 function dequeueSellOrder(Data storage data) external returns (SellOrder memory order, uint256 amountLimit) {
 ++data.lastProcessedOrderId;
 (order, amountLimit) = getSellOrder(data, data.lastProcessedOrderId);
 }
 function dequeueBuyOrder(Data storage data) external returns (BuyOrder memory order, uint256 amountLimit) {
 ++data.lastProcessedOrderId;
 (order, amountLimit) = getBuyOrder(data, data.lastProcessedOrderId);
 }
 function forgetOrder(Data storage data, uint256 orderId) internal {
 delete data.orderQueue[orderId];
 }
 function forgetLastProcessedOrder(Data storage data) internal {
 delete data.orderQueue[data.lastProcessedOrderId];
 }
 }
 pragma solidity 0.7.6;
 interface IWETH {
 function deposit() external payable;
 function transfer(address to, uint256 value) external returns (bool);
 function withdraw(uint256) external;
 }
 pragma solidity 0.7.6;
 library TransferHelper {
 function safeApprove( address token, address to, uint256 value ) internal {
 (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
 require(success && (data.length == 0 || abi.decode(data, (bool))), 'TH4B');
 }
 function safeTransfer( address token, address to, uint256 value ) internal {
 (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
 require(success && (data.length == 0 || abi.decode(data, (bool))), 'TH05');
 }
 function safeTransferFrom( address token, address from, address to, uint256 value ) internal {
 (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
 require(success && (data.length == 0 || abi.decode(data, (bool))), 'TH0E');
 }
 function safeTransferETH( address to, uint256 value, uint256 gasLimit ) internal {
 (bool success, ) = to.call{
 value: value, gas: gasLimit }
 ('');
 require(success, 'TH3F');
 }
 function transferETH( address to, uint256 value, uint256 gasLimit ) internal returns (bool success) {
 (success, ) = to.call{
 value: value, gas: gasLimit }
 ('');
 }
 }
 pragma solidity >=0.4.0 <0.8.0;
 library FullMath {
 function mulDiv( uint256 a, uint256 b, uint256 denominator ) internal pure returns (uint256 result) {
 uint256 prod0;
 uint256 prod1;
 assembly {
 let mm := mulmod(a, b, not(0)) prod0 := mul(a, b) prod1 := sub(sub(mm, prod0), lt(mm, prod0)) }
 if (prod1 == 0) {
 require(denominator > 0);
 assembly {
 result := div(prod0, denominator) }
 return result;
 }
 require(denominator > prod1);
 uint256 remainder;
 assembly {
 remainder := mulmod(a, b, denominator) }
 assembly {
 prod1 := sub(prod1, gt(remainder, prod0)) prod0 := sub(prod0, remainder) }
 uint256 twos = -denominator & denominator;
 assembly {
 denominator := div(denominator, twos) }
 assembly {
 prod0 := div(prod0, twos) }
 assembly {
 twos := add(div(sub(0, twos), twos), 1) }
 prod0 |= prod1 * twos;
 uint256 inv = (3 * denominator) ^ 2;
 inv *= 2 - denominator * inv;
 inv *= 2 - denominator * inv;
 inv *= 2 - denominator * inv;
 inv *= 2 - denominator * inv;
 inv *= 2 - denominator * inv;
 inv *= 2 - denominator * inv;
 result = prod0 * inv;
 return result;
 }
 function mulDivRoundingUp( uint256 a, uint256 b, uint256 denominator ) internal pure returns (uint256 result) {
 result = mulDiv(a, b, denominator);
 if (mulmod(a, b, denominator) > 0) {
 require(result < type(uint256).max);
 result++;
 }
 }
 }
 pragma solidity >=0.5.0 <0.8.0;
 library OracleLibrary {
 function consult(address pool, uint32 secondsAgo) internal view returns (int24 arithmeticMeanTick, uint128 harmonicMeanLiquidity) {
 require(secondsAgo != 0, 'BP');
 uint32[] memory secondsAgos = new uint32[](2);
 secondsAgos[0] = secondsAgo;
 secondsAgos[1] = 0;
 (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) = IUniswapV3Pool(pool).observe(secondsAgos);
 int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
 uint160 secondsPerLiquidityCumulativesDelta = secondsPerLiquidityCumulativeX128s[1] - secondsPerLiquidityCumulativeX128s[0];
 arithmeticMeanTick = int24(tickCumulativesDelta / secondsAgo);
 if (tickCumulativesDelta < 0 && (tickCumulativesDelta % secondsAgo != 0)) arithmeticMeanTick--;
 uint192 secondsAgoX160 = uint192(secondsAgo) * type(uint160).max;
 harmonicMeanLiquidity = uint128(secondsAgoX160 / (uint192(secondsPerLiquidityCumulativesDelta) << 32));
 }
 function getQuoteAtTick( int24 tick, uint128 baseAmount, address baseToken, address quoteToken ) internal pure returns (uint256 quoteAmount) {
 uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);
 if (sqrtRatioX96 <= type(uint128).max) {
 uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
 quoteAmount = baseToken < quoteToken ? FullMath.mulDiv(ratioX192, baseAmount, 1 << 192) : FullMath.mulDiv(1 << 192, baseAmount, ratioX192);
 }
 else {
 uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
 quoteAmount = baseToken < quoteToken ? FullMath.mulDiv(ratioX128, baseAmount, 1 << 128) : FullMath.mulDiv(1 << 128, baseAmount, ratioX128);
 }
 }
 function getOldestObservationSecondsAgo(address pool) internal view returns (uint32 secondsAgo) {
 (, , uint16 observationIndex, uint16 observationCardinality, , , ) = IUniswapV3Pool(pool).slot0();
 require(observationCardinality > 0, 'NI');
 (uint32 observationTimestamp, , , bool initialized) = IUniswapV3Pool(pool).observations((observationIndex + 1) % observationCardinality);
 if (!initialized) {
 (observationTimestamp, , , ) = IUniswapV3Pool(pool).observations(0);
 }
 secondsAgo = uint32(block.timestamp) - observationTimestamp;
 }
 function getBlockStartingTickAndLiquidity(address pool) internal view returns (int24, uint128) {
 (, int24 tick, uint16 observationIndex, uint16 observationCardinality, , , ) = IUniswapV3Pool(pool).slot0();
 require(observationCardinality > 1, 'NEO');
 (uint32 observationTimestamp, int56 tickCumulative, uint160 secondsPerLiquidityCumulativeX128, ) = IUniswapV3Pool(pool).observations(observationIndex);
 if (observationTimestamp != uint32(block.timestamp)) {
 return (tick, IUniswapV3Pool(pool).liquidity());
 }
 uint256 prevIndex = (uint256(observationIndex) + observationCardinality - 1) % observationCardinality;
 ( uint32 prevObservationTimestamp, int56 prevTickCumulative, uint160 prevSecondsPerLiquidityCumulativeX128, bool prevInitialized ) = IUniswapV3Pool(pool).observations(prevIndex);
 require(prevInitialized, 'ONI');
 uint32 delta = observationTimestamp - prevObservationTimestamp;
 tick = int24((tickCumulative - prevTickCumulative) / delta);
 uint128 liquidity = uint128( (uint192(delta) * type(uint160).max) / (uint192(secondsPerLiquidityCumulativeX128 - prevSecondsPerLiquidityCumulativeX128) << 32) );
 return (tick, liquidity);
 }
 struct WeightedTickData {
 int24 tick;
 uint128 weight;
 }
 function getWeightedArithmeticMeanTick(WeightedTickData[] memory weightedTickData) internal pure returns (int24 weightedArithmeticMeanTick) {
 int256 numerator;
 uint256 denominator;
 for (uint256 i; i < weightedTickData.length; i++) {
 numerator += weightedTickData[i].tick * int256(weightedTickData[i].weight);
 denominator += weightedTickData[i].weight;
 }
 weightedArithmeticMeanTick = int24(numerator / int256(denominator));
 if (numerator < 0 && (numerator % int256(denominator) != 0)) weightedArithmeticMeanTick--;
 }
 function getChainedPrice(address[] memory tokens, int24[] memory ticks) internal pure returns (int256 syntheticTick) {
 require(tokens.length - 1 == ticks.length, 'DL');
 for (uint256 i = 1; i <= ticks.length; i++) {
 tokens[i - 1] < tokens[i] ? syntheticTick += ticks[i - 1] : syntheticTick -= ticks[i - 1];
 }
 }
 }
 pragma solidity 0.7.6;
 library Math {
 function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
 z = x < y ? x : y;
 }
 function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
 z = x > y ? x : y;
 }
 function sqrt(uint256 y) internal pure returns (uint256 z) {
 if (y > 3) {
 z = y;
 uint256 x = y / 2 + 1;
 while (x < z) {
 z = x;
 x = (y / x + x) / 2;
 }
 }
 else if (y != 0) {
 z = 1;
 }
 }
 }
 pragma solidity 0.7.6;
 library TokenShares {
 using SafeMath for uint256;
 using TransferHelper for address;
 uint256 private constant PRECISION = 10**18;
 uint256 private constant TOLERANCE = 10**18 + 10**16;
 event UnwrapFailed(address to, uint256 amount);
 struct Data {
 mapping(address => uint256) totalShares;
 address weth;
 }
 function sharesToAmount( Data storage data, address token, uint256 share, uint256 amountLimit, address refundTo ) external returns (uint256) {
 if (share == 0) {
 return 0;
 }
 if (token == data.weth) {
 return share;
 }
 uint256 totalTokenShares = data.totalShares[token];
 require(totalTokenShares >= share, 'TS3A');
 uint256 balance = IERC20(token).balanceOf(address(this));
 uint256 value = balance.mul(share).div(totalTokenShares);
 data.totalShares[token] = totalTokenShares.sub(share);
 if (amountLimit > 0) {
 uint256 amountLimitWithTolerance = amountLimit.mul(TOLERANCE).div(PRECISION);
 if (value > amountLimitWithTolerance) {
 TransferHelper.safeTransfer(token, refundTo, value.sub(amountLimitWithTolerance));
 return amountLimitWithTolerance;
 }
 }
 return value;
 }
 function amountToShares( Data storage data, address token, uint256 amount, bool wrap ) external returns (uint256) {
 if (amount == 0) {
 return 0;
 }
 if (token == data.weth) {
 if (wrap) {
 require(msg.value >= amount, 'TS03');
 IWETH(token).deposit{
 value: amount }
 ();
 }
 else {
 token.safeTransferFrom(msg.sender, address(this), amount);
 }
 return amount;
 }
 else {
 uint256 balanceBefore = IERC20(token).balanceOf(address(this));
 uint256 totalTokenShares = data.totalShares[token];
 require(balanceBefore > 0 || totalTokenShares == 0, 'TS30');
 if (totalTokenShares == 0) {
 totalTokenShares = balanceBefore;
 }
 token.safeTransferFrom(msg.sender, address(this), amount);
 uint256 balanceAfter = IERC20(token).balanceOf(address(this));
 require(balanceAfter > balanceBefore, 'TS2C');
 if (balanceBefore > 0) {
 uint256 newShares = totalTokenShares.mul(balanceAfter).div(balanceBefore);
 data.totalShares[token] = newShares;
 return newShares - totalTokenShares;
 }
 else {
 data.totalShares[token] = balanceAfter;
 return balanceAfter;
 }
 }
 }
 function onUnwrapFailed( Data storage data, address to, uint256 amount ) external {
 emit UnwrapFailed(to, amount);
 IWETH(data.weth).deposit{
 value: amount }
 ();
 TransferHelper.safeTransfer(data.weth, to, amount);
 }
 }
 pragma solidity >=0.5.0 <0.8.0;
 library TickMath {
 int24 internal constant MIN_TICK = -887272;
 int24 internal constant MAX_TICK = -MIN_TICK;
 uint160 internal constant MIN_SQRT_RATIO = 4295128739;
 uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;
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
 sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
 }
 function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
 require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, 'R');
 uint256 ratio = uint256(sqrtPriceX96) << 32;
 uint256 r = ratio;
 uint256 msb = 0;
 assembly {
 let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) msb := or(msb, f) r := shr(f, r) }
 assembly {
 let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF)) msb := or(msb, f) r := shr(f, r) }
 assembly {
 let f := shl(5, gt(r, 0xFFFFFFFF)) msb := or(msb, f) r := shr(f, r) }
 assembly {
 let f := shl(4, gt(r, 0xFFFF)) msb := or(msb, f) r := shr(f, r) }
 assembly {
 let f := shl(3, gt(r, 0xFF)) msb := or(msb, f) r := shr(f, r) }
 assembly {
 let f := shl(2, gt(r, 0xF)) msb := or(msb, f) r := shr(f, r) }
 assembly {
 let f := shl(1, gt(r, 0x3)) msb := or(msb, f) r := shr(f, r) }
 assembly {
 let f := gt(r, 0x1) msb := or(msb, f) }
 if (msb >= 128) r = ratio >> (msb - 127);
 else r = ratio << (127 - msb);
 int256 log_2 = (int256(msb) - 128) << 64;
 assembly {
 r := shr(127, mul(r, r)) let f := shr(128, r) log_2 := or(log_2, shl(63, f)) r := shr(f, r) }
 assembly {
 r := shr(127, mul(r, r)) let f := shr(128, r) log_2 := or(log_2, shl(62, f)) r := shr(f, r) }
 assembly {
 r := shr(127, mul(r, r)) let f := shr(128, r) log_2 := or(log_2, shl(61, f)) r := shr(f, r) }
 assembly {
 r := shr(127, mul(r, r)) let f := shr(128, r) log_2 := or(log_2, shl(60, f)) r := shr(f, r) }
 assembly {
 r := shr(127, mul(r, r)) let f := shr(128, r) log_2 := or(log_2, shl(59, f)) r := shr(f, r) }
 assembly {
 r := shr(127, mul(r, r)) let f := shr(128, r) log_2 := or(log_2, shl(58, f)) r := shr(f, r) }
 assembly {
 r := shr(127, mul(r, r)) let f := shr(128, r) log_2 := or(log_2, shl(57, f)) r := shr(f, r) }
 assembly {
 r := shr(127, mul(r, r)) let f := shr(128, r) log_2 := or(log_2, shl(56, f)) r := shr(f, r) }
 assembly {
 r := shr(127, mul(r, r)) let f := shr(128, r) log_2 := or(log_2, shl(55, f)) r := shr(f, r) }
 assembly {
 r := shr(127, mul(r, r)) let f := shr(128, r) log_2 := or(log_2, shl(54, f)) r := shr(f, r) }
 assembly {
 r := shr(127, mul(r, r)) let f := shr(128, r) log_2 := or(log_2, shl(53, f)) r := shr(f, r) }
 assembly {
 r := shr(127, mul(r, r)) let f := shr(128, r) log_2 := or(log_2, shl(52, f)) r := shr(f, r) }
 assembly {
 r := shr(127, mul(r, r)) let f := shr(128, r) log_2 := or(log_2, shl(51, f)) r := shr(f, r) }
 assembly {
 r := shr(127, mul(r, r)) let f := shr(128, r) log_2 := or(log_2, shl(50, f)) }
 int256 log_sqrt10001 = log_2 * 255738958999603826347141;
 int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
 int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);
 tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
 }
 }
 pragma solidity >=0.5.0;
 interface IUniswapV3Pool is IUniswapV3PoolImmutables, IUniswapV3PoolState, IUniswapV3PoolDerivedState, IUniswapV3PoolActions, IUniswapV3PoolOwnerActions, IUniswapV3PoolEvents {
 }
