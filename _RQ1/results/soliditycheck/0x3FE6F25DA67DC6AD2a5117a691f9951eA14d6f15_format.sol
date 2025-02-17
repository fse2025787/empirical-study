  pragma abicoder v2;
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
 interface IUniswapV3PoolOwnerActions {
 function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;
 function collectProtocol( address recipient, uint128 amount0Requested, uint128 amount1Requested ) external returns (uint128 amount0, uint128 amount1);
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
 pragma solidity 0.7.6;
 contract Admin {
 address public admin;
 address public advisor;
 event whitelistAdd(address pos, address listed);
 event whitelistRemove(address pos, address unlisted);
 event whitelistOn(address pos, bool whitelisted);
 modifier onlyAdvisor {
 require(msg.sender == advisor, "only advisor");
 _;
 }
 modifier onlyAdmin {
 require(msg.sender == admin, "only admin");
 _;
 }
 constructor(address _admin, address _advisor) {
 require(_admin != address(0), "_admin should be non-zero");
 require(_advisor != address(0), "_advisor should be non-zero");
 admin = _admin;
 advisor = _advisor;
 }
 function rebalance( address _hypervisor, int24 _baseLower, int24 _baseUpper, int24 _limitLower, int24 _limitUpper, address _feeRecipient, int256 swapQuantity, int256 amountMin, uint160 sqrtPriceLimitX96 ) external onlyAdvisor {
 IHypervisor(_hypervisor).rebalance(_baseLower, _baseUpper, _limitLower, _limitUpper, _feeRecipient, swapQuantity, amountMin, sqrtPriceLimitX96);
 }
 function pullLiquidity( address _hypervisor, uint256 shares ) external onlyAdvisor returns( uint256 base0, uint256 base1, uint256 limit0, uint256 limit1 ) {
 (base0, base1, limit0, limit1) = IHypervisor(_hypervisor).pullLiquidity(shares);
 }
 function addBaseLiquidity(address _hypervisor, uint256 amount0, uint256 amount1) external onlyAdvisor {
 IHypervisor(_hypervisor).addBaseLiquidity(amount0, amount1);
 }
 function addLimitLiquidity(address _hypervisor, uint256 amount0, uint256 amount1) external onlyAdvisor {
 IHypervisor(_hypervisor).addLimitLiquidity(amount0, amount1);
 }
 function pendingFees(address _hypervisor) external onlyAdvisor returns (uint256 fees0, uint256 fees1) {
 (fees0, fees1) = IHypervisor(_hypervisor).pendingFees();
 }
 function setDepositMax(address _hypervisor, uint256 _deposit0Max, uint256 _deposit1Max) external onlyAdmin {
 IHypervisor(_hypervisor).setDepositMax(_deposit0Max, _deposit1Max);
 }
 function setMaxTotalSupply(address _hypervisor, uint256 _maxTotalSupply) external onlyAdmin {
 IHypervisor(_hypervisor).setMaxTotalSupply(_maxTotalSupply);
 }
 function toggleWhitelist(address _hypervisor) external onlyAdmin {
 IHypervisor(_hypervisor).toggleWhitelist();
 emit whitelistOn(_hypervisor, IHypervisor(_hypervisor).whitelisted());
 }
 function appendList(address _hypervisor, address[] memory listed) external onlyAdmin {
 for(uint8 i; i < listed.length; i++) {
 emit whitelistAdd(_hypervisor, listed[i]);
 }
 IHypervisor(_hypervisor).appendList(listed);
 }
 function removeListed(address _hypervisor, address listed) external onlyAdmin {
 emit whitelistRemove(_hypervisor, listed);
 IHypervisor(_hypervisor).removeListed(listed);
 }
 function transferAdmin(address newAdmin) external onlyAdmin {
 require(newAdmin != address(0), "newAdmin should be non-zero");
 admin = newAdmin;
 }
 function transferAdvisor(address newAdvisor) external onlyAdmin {
 require(newAdvisor != address(0), "newAdvisor should be non-zero");
 advisor = newAdvisor;
 }
 function transferHypervisorOwner(address _hypervisor, address newOwner) external onlyAdmin {
 IHypervisor(_hypervisor).transferOwnership(newOwner);
 }
 function rescueERC20(IERC20 token, address recipient) external onlyAdmin {
 require(recipient != address(0), "recipient should be non-zero");
 require(token.transfer(recipient, token.balanceOf(address(this))));
 }
 }
 pragma solidity 0.7.6;
 interface IHypervisor {
 function deposit( uint256, uint256, address ) external returns (uint256);
 function deposit( uint256, uint256, address, address ) external returns (uint256);
 function withdraw( uint256, address, address ) external returns (uint256, uint256);
 function rebalance( int24 _baseLower, int24 _baseUpper, int24 _limitLower, int24 _limitUpper, address _feeRecipient, int256 swapQuantity, int256 amountMin, uint160 sqrtPriceLimitX96 ) external;
 function addBaseLiquidity( uint256 amount0, uint256 amount1 ) external;
 function addLimitLiquidity( uint256 amount0, uint256 amount1 ) external;
 function pullLiquidity(uint256 shares) external returns( uint256 base0, uint256 base1, uint256 limit0, uint256 limit1 );
 function compound() external returns( uint128 baseToken0Owed, uint128 baseToken1Owed, uint128 limitToken0Owed, uint128 limitToken1Owed );
 function whitelisted() external view returns (bool);
 function pool() external view returns (IUniswapV3Pool);
 function currentTick() external view returns (int24 tick);
 function token0() external view returns (IERC20);
 function token1() external view returns (IERC20);
 function deposit0Max() external view returns (uint256);
 function deposit1Max() external view returns (uint256);
 function balanceOf(address) external view returns (uint256);
 function approve(address, uint256) external returns (bool);
 function transferFrom(address, address, uint256) external returns (bool);
 function transfer(address, uint256) external returns (bool);
 function getTotalAmounts() external view returns (uint256 total0, uint256 total1);
 function pendingFees() external returns (uint256 fees0, uint256 fees1);
 function totalSupply() external view returns (uint256 );
 function setMaxTotalSupply(uint256 _maxTotalSupply) external;
 function setDepositMax(uint256 _deposit0Max, uint256 _deposit1Max) external;
 function appendList(address[] memory listed) external;
 function removeListed(address listed) external;
 function toggleWhitelist() external;
 function transferOwnership(address newOwner) external;
 }
 pragma solidity >=0.6.0 <0.8.0;
 interface IERC20 {
 function totalSupply() external view returns (uint256);
 function balanceOf(address account) external view returns (uint256);
 function transfer(address recipient, uint256 amount) external returns (bool);
 function allowance(address owner, address spender) external view returns (uint256);
 function approve(address spender, uint256 amount) external returns (bool);
 function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed owner, address indexed spender, uint256 value);
 }
 pragma solidity >=0.5.0;
 interface IUniswapV3Pool is IUniswapV3PoolImmutables, IUniswapV3PoolState, IUniswapV3PoolDerivedState, IUniswapV3PoolActions, IUniswapV3PoolOwnerActions, IUniswapV3PoolEvents {
 }
