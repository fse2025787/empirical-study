  pragma experimental ABIEncoderV2;
 pragma solidity =0.7.6;
 abstract contract ReentrancyGuard {
 uint256 private constant _NOT_ENTERED = 1;
 uint256 private constant _ENTERED = 2;
 AppStorage internal s;
 modifier updateSilo() {
 LibInternal.updateSilo(msg.sender);
 _;
 }
 modifier updateSiloNonReentrant() {
 require(s.reentrantStatus != _ENTERED, "ReentrancyGuard: reentrant call");
 s.reentrantStatus = _ENTERED;
 LibInternal.updateSilo(msg.sender);
 _;
 s.reentrantStatus = _NOT_ENTERED;
 }
 modifier nonReentrant() {
 require(s.reentrantStatus != _ENTERED, "ReentrancyGuard: reentrant call");
 s.reentrantStatus = _ENTERED;
 _;
 s.reentrantStatus = _NOT_ENTERED;
 }
 }
 pragma solidity =0.7.6;
 contract BeanDibbler is ReentrancyGuard{
 using SafeMath for uint256;
 using LibSafeMath32 for uint32;
 using Decimal for Decimal.D256;
 event Sow(address indexed account, uint256 index, uint256 beans, uint256 pods);
 function totalPods() public view returns (uint256) {
 return s.f.pods.sub(s.f.harvested);
 }
 function podIndex() public view returns (uint256) {
 return s.f.pods;
 }
 function harvestableIndex() public view returns (uint256) {
 return s.f.harvestable;
 }
 function harvestedIndex() public view returns (uint256) {
 return s.f.harvested;
 }
 function totalHarvestable() public view returns (uint256) {
 return s.f.harvestable.sub(s.f.harvested);
 }
 function totalUnripenedPods() public view returns (uint256) {
 return s.f.pods.sub(s.f.harvestable);
 }
 function plot(address account, uint256 plotId) public view returns (uint256) {
 return s.a[account].field.plots[plotId];
 }
 function totalSoil() public view returns (uint256) {
 return s.f.soil;
 }
 function _sowBeans(uint256 amount) internal returns (uint256 pods) {
 pods = LibDibbler.sow(amount, msg.sender);
 bean().burn(amount);
 LibCheck.beanBalanceCheck();
 }
 function bean() internal view returns (IBean) {
 return IBean(s.c.bean);
 }
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
 pragma solidity >=0.6.2;
 interface IUniswapV2Router01 {
 function factory() external pure returns (address);
 function WETH() external pure returns (address);
 function addLiquidity( address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline ) external returns (uint amountA, uint amountB, uint liquidity);
 function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
 function removeLiquidity( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline ) external returns (uint amountA, uint amountB);
 function removeLiquidityETH( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external returns (uint amountToken, uint amountETH);
 function removeLiquidityWithPermit( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountA, uint amountB);
 function removeLiquidityETHWithPermit( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountToken, uint amountETH);
 function swapExactTokensForTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external returns (uint[] memory amounts);
 function swapTokensForExactTokens( uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline ) external returns (uint[] memory amounts);
 function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
 function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
 function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
 function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
 function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
 function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
 function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
 function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
 function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
 }
 pragma solidity =0.7.6;
 contract FieldFacet is BeanDibbler {
 using SafeMath for uint256;
 using Decimal for Decimal.D256;
 function claimAndSowBeans(uint256 amount, LibClaim.Claim calldata claim) external nonReentrant returns (uint256 pods) {
 allocateBeans(claim, amount);
 pods = _sowBeans(amount);
 LibMarket.claimRefund(claim);
 }
 function claimBuyAndSowBeans( uint256 amount, uint256 buyAmount, LibClaim.Claim calldata claim ) external payable nonReentrant returns (uint256 pods) {
 allocateBeans(claim, amount);
 uint256 boughtAmount = LibMarket.buyAndDeposit(buyAmount);
 pods = _sowBeans(amount.add(boughtAmount));
 }
 function sowBeans(uint256 amount) external returns (uint256) {
 bean().transferFrom(msg.sender, address(this), amount);
 return _sowBeans(amount);
 }
 function buyAndSowBeans(uint256 amount, uint256 buyAmount) external payable nonReentrant returns (uint256 pods) {
 uint256 boughtAmount = LibMarket.buyAndDeposit(buyAmount);
 if (amount > 0) bean().transferFrom(msg.sender, address(this), amount);
 pods = _sowBeans(amount.add(boughtAmount));
 }
 function allocateBeans(LibClaim.Claim calldata c, uint256 transferBeans) private {
 LibClaim.claim(c);
 LibMarket.allocateBeans(transferBeans);
 }
 }
 pragma solidity =0.7.6;
 library LibClaim {
 using SafeMath for uint256;
 using LibSafeMath32 for uint32;
 event BeanClaim(address indexed account, uint32[] withdrawals, uint256 beans);
 event LPClaim(address indexed account, uint32[] withdrawals, uint256 lp);
 event EtherClaim(address indexed account, uint256 ethereum);
 event Harvest(address indexed account, uint256[] plots, uint256 beans);
 event PodListingCancelled(address indexed account, uint256 indexed index);
 struct Claim {
 uint32[] beanWithdrawals;
 uint32[] lpWithdrawals;
 uint256[] plots;
 bool claimEth;
 bool convertLP;
 uint256 minBeanAmount;
 uint256 minEthAmount;
 bool toWallet;
 }
 function claim(Claim calldata c) public returns (uint256 beansClaimed) {
 AppStorage storage s = LibAppStorage.diamondStorage();
 if (c.beanWithdrawals.length > 0) beansClaimed = beansClaimed.add(claimBeans(c.beanWithdrawals));
 if (c.plots.length > 0) beansClaimed = beansClaimed.add(harvest(c.plots));
 if (c.lpWithdrawals.length > 0) {
 if (c.convertLP) {
 if (!c.toWallet) beansClaimed = beansClaimed.add(removeClaimLPAndWrapBeans(c.lpWithdrawals, c.minBeanAmount, c.minEthAmount));
 else removeAndClaimLP(c.lpWithdrawals, c.minBeanAmount, c.minEthAmount);
 }
 else claimLP(c.lpWithdrawals);
 }
 if (c.claimEth) claimEth();
 if (beansClaimed > 0) {
 if (c.toWallet) IBean(s.c.bean).transfer(msg.sender, beansClaimed);
 else s.a[msg.sender].wrappedBeans = s.a[msg.sender].wrappedBeans.add(beansClaimed);
 }
 }
 function claimBeans(uint32[] calldata withdrawals) public returns (uint256 beansClaimed) {
 AppStorage storage s = LibAppStorage.diamondStorage();
 for (uint256 i = 0; i < withdrawals.length; i++) {
 require(withdrawals[i] <= s.season.current, "Claim: Withdrawal not recievable.");
 beansClaimed = beansClaimed.add(claimBeanWithdrawal(msg.sender, withdrawals[i]));
 }
 emit BeanClaim(msg.sender, withdrawals, beansClaimed);
 }
 function claimBeanWithdrawal(address account, uint32 _s) private returns (uint256) {
 AppStorage storage s = LibAppStorage.diamondStorage();
 uint256 amount = s.a[account].bean.withdrawals[_s];
 require(amount > 0, "Claim: Bean withdrawal is empty.");
 delete s.a[account].bean.withdrawals[_s];
 s.bean.withdrawn = s.bean.withdrawn.sub(amount);
 return amount;
 }
 function claimLP(uint32[] calldata withdrawals) public {
 AppStorage storage s = LibAppStorage.diamondStorage();
 uint256 lpClaimed = _claimLP(withdrawals);
 IUniswapV2Pair(s.c.pair).transfer(msg.sender, lpClaimed);
 }
 function removeAndClaimLP( uint32[] calldata withdrawals, uint256 minBeanAmount, uint256 minEthAmount ) public returns (uint256 beans) {
 uint256 lpClaimd = _claimLP(withdrawals);
 (beans,) = LibMarket.removeLiquidity(lpClaimd, minBeanAmount, minEthAmount);
 }
 function removeClaimLPAndWrapBeans( uint32[] calldata withdrawals, uint256 minBeanAmount, uint256 minEthAmount ) private returns (uint256 beans) {
 uint256 lpClaimd = _claimLP(withdrawals);
 (beans,) = LibMarket.removeLiquidityWithBeanAllocation(lpClaimd, minBeanAmount, minEthAmount);
 }
 function _claimLP(uint32[] calldata withdrawals) private returns (uint256) {
 AppStorage storage s = LibAppStorage.diamondStorage();
 uint256 lpClaimd = 0;
 for(uint256 i = 0; i < withdrawals.length; i++) {
 require(withdrawals[i] <= s.season.current, "Claim: Withdrawal not recievable.");
 lpClaimd = lpClaimd.add(claimLPWithdrawal(msg.sender, withdrawals[i]));
 }
 emit LPClaim(msg.sender, withdrawals, lpClaimd);
 return lpClaimd;
 }
 function claimLPWithdrawal(address account, uint32 _s) private returns (uint256) {
 AppStorage storage s = LibAppStorage.diamondStorage();
 uint256 amount = s.a[account].lp.withdrawals[_s];
 require(amount > 0, "Claim: LP withdrawal is empty.");
 delete s.a[account].lp.withdrawals[_s];
 s.lp.withdrawn = s.lp.withdrawn.sub(amount);
 return amount;
 }
 function claimEth() public {
 LibInternal.updateSilo(msg.sender);
 uint256 eth = claimPlenty(msg.sender);
 emit EtherClaim(msg.sender, eth);
 }
 function claimPlenty(address account) private returns (uint256) {
 AppStorage storage s = LibAppStorage.diamondStorage();
 if (s.sop.base == 0) return 0;
 uint256 eth = s.a[account].sop.base.mul(s.sop.weth).div(s.sop.base);
 s.sop.weth = s.sop.weth.sub(eth);
 s.sop.base = s.sop.base.sub(s.a[account].sop.base);
 s.a[account].sop.base = 0;
 IWETH(s.c.weth).withdraw(eth);
 (bool success, ) = account.call{
 value: eth}
 ("");
 require(success, "WETH: ETH transfer failed");
 return eth;
 }
 function harvest(uint256[] calldata plots) public returns (uint256 beansHarvested) {
 AppStorage storage s = LibAppStorage.diamondStorage();
 for (uint256 i = 0; i < plots.length; i++) {
 require(plots[i] < s.f.harvestable, "Claim: Plot not harvestable.");
 require(s.a[msg.sender].field.plots[plots[i]] > 0, "Claim: Plot not harvestable.");
 uint256 harvested = harvestPlot(msg.sender, plots[i]);
 beansHarvested = beansHarvested.add(harvested);
 }
 require(s.f.harvestable.sub(s.f.harvested) >= beansHarvested, "Claim: Not enough Harvestable.");
 s.f.harvested = s.f.harvested.add(beansHarvested);
 emit Harvest(msg.sender, plots, beansHarvested);
 }
 function harvestPlot(address account, uint256 plotId) private returns (uint256) {
 AppStorage storage s = LibAppStorage.diamondStorage();
 uint256 pods = s.a[account].field.plots[plotId];
 require(pods > 0, "Claim: Plot is empty.");
 uint256 harvestablePods = s.f.harvestable.sub(plotId);
 delete s.a[account].field.plots[plotId];
 if (s.podListings[plotId] > 0){
 cancelPodListing(plotId);
 }
 if (harvestablePods >= pods) return pods;
 s.a[account].field.plots[plotId.add(harvestablePods)] = pods.sub(harvestablePods);
 return harvestablePods;
 }
 function cancelPodListing(uint256 index) internal {
 AppStorage storage s = LibAppStorage.diamondStorage();
 delete s.podListings[index];
 emit PodListingCancelled(msg.sender, index);
 }
 }
 pragma solidity =0.7.6;
 abstract contract IBean is IERC20 {
 function burn(uint256 amount) public virtual;
 function burnFrom(address account, uint256 amount) public virtual;
 function mint(address account, uint256 amount) public virtual returns (bool);
 }
 pragma solidity =0.7.6;
 library LibDibbler {
 using SafeMath for uint256;
 using LibSafeMath32 for uint32;
 using Decimal for Decimal.D256;
 event Sow(address indexed account, uint256 index, uint256 beans, uint256 pods);
 function sow(uint256 amount, address account) internal returns (uint256) {
 AppStorage storage s = LibAppStorage.diamondStorage();
 s.f.soil = s.f.soil.sub(amount, "Field: Not enough outstanding Soil.");
 return sowNoSoil(amount, account);
 }
 function sowNoSoil(uint256 amount, address account) internal returns (uint256) {
 AppStorage storage s = LibAppStorage.diamondStorage();
 uint256 pods = beansToPods(amount, s.w.yield);
 require(pods > 0, "Field: Must receive non-zero Pods.");
 sowPlot(account, amount, pods);
 s.f.pods = s.f.pods.add(pods);
 saveSowTime();
 return pods;
 }
 function sowPlot(address account, uint256 beans, uint256 pods) private {
 AppStorage storage s = LibAppStorage.diamondStorage();
 s.a[account].field.plots[s.f.pods] = pods;
 emit Sow(account, s.f.pods, beans, pods);
 }
 function beansToPods(uint256 beanstalks, uint256 y) private pure returns (uint256) {
 Decimal.D256 memory rate = Decimal.ratio(y, 100).add(Decimal.one());
 return Decimal.from(beanstalks).mul(rate).asUint256();
 }
 function saveSowTime() private {
 AppStorage storage s = LibAppStorage.diamondStorage();
 uint256 totalBeanSupply = IBean(s.c.bean).totalSupply();
 uint256 soil = s.f.soil;
 if (soil >= totalBeanSupply.div(C.getComplexWeatherDenominator())) return;
 uint256 sowTime = block.timestamp.sub(s.season.timestamp);
 s.w.nextSowTime = uint32(sowTime);
 if (!s.w.didSowBelowMin) s.w.didSowBelowMin = true;
 if (s.w.didSowFaster || s.w.lastSowTime == type(uint32).max || s.w.lastDSoil == 0 ) return;
 uint256 soilPercent = soil.mul(1e18).div(totalBeanSupply);
 if (soilPercent <= C.getUpperBoundPodRate().mul(s.w.lastSoilPercent).asUint256()) {
 uint256 deltaSoil = s.w.startSoil.sub(soil);
 if (Decimal.ratio(deltaSoil, s.w.lastDSoil).greaterThan(C.getLowerBoundDPD())) {
 uint256 fasterTime = s.w.lastSowTime > C.getSteadySowTime() ? s.w.lastSowTime.sub(C.getSteadySowTime()) : 0;
 if (sowTime < fasterTime) s.w.didSowFaster = true;
 else s.w.lastSowTime = type(uint32).max;
 }
 }
 }
 }
 pragma solidity =0.7.6;
 library C {
 using Decimal for Decimal.D256;
 using SafeMath for uint256;
 uint256 private constant PERCENT_BASE = 1e18;
 uint256 private constant CHAIN_ID = 1;
 uint256 private constant CURRENT_SEASON_PERIOD = 3600;
 uint256 private constant HARVESET_PERCENTAGE = 0.5e18;
 uint256 private constant POD_RATE_LOWER_BOUND = 0.05e18;
 uint256 private constant OPTIMAL_POD_RATE = 0.15e18;
 uint256 private constant POD_RATE_UPPER_BOUND = 0.25e18;
 uint256 private constant DELTA_POD_DEMAND_LOWER_BOUND = 0.95e18;
 uint256 private constant DELTA_POD_DEMAND_UPPER_BOUND = 1.05e18;
 uint32 private constant STEADY_SOW_TIME = 60;
 uint256 private constant RAIN_TIME = 24;
 uint32 private constant GOVERNANCE_PERIOD = 168;
 uint32 private constant GOVERNANCE_EMERGENCY_PERIOD = 86400;
 uint256 private constant GOVERNANCE_PASS_THRESHOLD = 5e17;
 uint256 private constant GOVERNANCE_EMERGENCY_THRESHOLD_NUMERATOR = 2;
 uint256 private constant GOVERNANCE_EMERGENCY_THRESHOLD_DEMONINATOR = 3;
 uint32 private constant GOVERNANCE_EXPIRATION = 24;
 uint256 private constant GOVERNANCE_PROPOSAL_THRESHOLD = 0.001e18;
 uint256 private constant BASE_COMMIT_INCENTIVE = 100e6;
 uint256 private constant MAX_PROPOSITIONS = 5;
 uint256 private constant BASE_ADVANCE_INCENTIVE = 100e6;
 uint32 private constant WITHDRAW_TIME = 25;
 uint256 private constant SEEDS_PER_BEAN = 2;
 uint256 private constant SEEDS_PER_LP_BEAN = 4;
 uint256 private constant STALK_PER_BEAN = 10000;
 uint256 private constant ROOTS_BASE = 1e12;
 uint256 private constant MAX_SOIL_DENOMINATOR = 4;
 uint256 private constant COMPLEX_WEATHER_DENOMINATOR = 1000;
 function getSeasonPeriod() internal pure returns (uint256) {
 return CURRENT_SEASON_PERIOD;
 }
 function getGovernancePeriod() internal pure returns (uint32) {
 return GOVERNANCE_PERIOD;
 }
 function getGovernanceEmergencyPeriod() internal pure returns (uint32) {
 return GOVERNANCE_EMERGENCY_PERIOD;
 }
 function getGovernanceExpiration() internal pure returns (uint32) {
 return GOVERNANCE_EXPIRATION;
 }
 function getGovernancePassThreshold() internal pure returns (Decimal.D256 memory) {
 return Decimal.D256({
 value: GOVERNANCE_PASS_THRESHOLD}
 );
 }
 function getGovernanceEmergencyThreshold() internal pure returns (Decimal.D256 memory) {
 return Decimal.ratio(GOVERNANCE_EMERGENCY_THRESHOLD_NUMERATOR,GOVERNANCE_EMERGENCY_THRESHOLD_DEMONINATOR);
 }
 function getGovernanceProposalThreshold() internal pure returns (Decimal.D256 memory) {
 return Decimal.D256({
 value: GOVERNANCE_PROPOSAL_THRESHOLD}
 );
 }
 function getAdvanceIncentive() internal pure returns (uint256) {
 return BASE_ADVANCE_INCENTIVE;
 }
 function getCommitIncentive() internal pure returns (uint256) {
 return BASE_COMMIT_INCENTIVE;
 }
 function getSiloWithdrawSeasons() internal pure returns (uint32) {
 return WITHDRAW_TIME;
 }
 function getComplexWeatherDenominator() internal pure returns (uint256) {
 return COMPLEX_WEATHER_DENOMINATOR;
 }
 function getMaxSoilDenominator() internal pure returns (uint256) {
 return MAX_SOIL_DENOMINATOR;
 }
 function getHarvestPercentage() internal pure returns (uint256) {
 return HARVESET_PERCENTAGE;
 }
 function getChainId() internal pure returns (uint256) {
 return CHAIN_ID;
 }
 function getOptimalPodRate() internal pure returns (Decimal.D256 memory) {
 return Decimal.ratio(OPTIMAL_POD_RATE, PERCENT_BASE);
 }
 function getUpperBoundPodRate() internal pure returns (Decimal.D256 memory) {
 return Decimal.ratio(POD_RATE_UPPER_BOUND, PERCENT_BASE);
 }
 function getLowerBoundPodRate() internal pure returns (Decimal.D256 memory) {
 return Decimal.ratio(POD_RATE_LOWER_BOUND, PERCENT_BASE);
 }
 function getUpperBoundDPD() internal pure returns (Decimal.D256 memory) {
 return Decimal.ratio(DELTA_POD_DEMAND_UPPER_BOUND, PERCENT_BASE);
 }
 function getLowerBoundDPD() internal pure returns (Decimal.D256 memory) {
 return Decimal.ratio(DELTA_POD_DEMAND_LOWER_BOUND, PERCENT_BASE);
 }
 function getSteadySowTime() internal pure returns (uint32) {
 return STEADY_SOW_TIME;
 }
 function getRainTime() internal pure returns (uint256) {
 return RAIN_TIME;
 }
 function getMaxPropositions() internal pure returns (uint256) {
 return MAX_PROPOSITIONS;
 }
 function getSeedsPerBean() internal pure returns (uint256) {
 return SEEDS_PER_BEAN;
 }
 function getSeedsPerLPBean() internal pure returns (uint256) {
 return SEEDS_PER_LP_BEAN;
 }
 function getStalkPerBean() internal pure returns (uint256) {
 return STALK_PER_BEAN;
 }
 function getStalkPerLPSeed() internal pure returns (uint256) {
 return STALK_PER_BEAN/SEEDS_PER_LP_BEAN;
 }
 function getRootsBase() internal pure returns (uint256) {
 return ROOTS_BASE;
 }
 }
 pragma solidity =0.7.6;
 library Decimal {
 using SafeMath for uint256;
 uint256 constant BASE = 10**18;
 struct D256 {
 uint256 value;
 }
 function zero() internal pure returns (D256 memory) {
 return D256({
 value: 0 }
 );
 }
 function one() internal pure returns (D256 memory) {
 return D256({
 value: BASE }
 );
 }
 function from( uint256 a ) internal pure returns (D256 memory) {
 return D256({
 value: a.mul(BASE) }
 );
 }
 function ratio( uint256 a, uint256 b ) internal pure returns (D256 memory) {
 return D256({
 value: getPartial(a, BASE, b) }
 );
 }
 function add( D256 memory self, uint256 b ) internal pure returns (D256 memory) {
 return D256({
 value: self.value.add(b.mul(BASE)) }
 );
 }
 function sub( D256 memory self, uint256 b ) internal pure returns (D256 memory) {
 return D256({
 value: self.value.sub(b.mul(BASE)) }
 );
 }
 function sub( D256 memory self, uint256 b, string memory reason ) internal pure returns (D256 memory) {
 return D256({
 value: self.value.sub(b.mul(BASE), reason) }
 );
 }
 function mul( D256 memory self, uint256 b ) internal pure returns (D256 memory) {
 return D256({
 value: self.value.mul(b) }
 );
 }
 function div( D256 memory self, uint256 b ) internal pure returns (D256 memory) {
 return D256({
 value: self.value.div(b) }
 );
 }
 function pow( D256 memory self, uint256 b ) internal pure returns (D256 memory) {
 if (b == 0) {
 return one();
 }
 D256 memory temp = D256({
 value: self.value }
 );
 for (uint256 i = 1; i < b; i++) {
 temp = mul(temp, self);
 }
 return temp;
 }
 function add( D256 memory self, D256 memory b ) internal pure returns (D256 memory) {
 return D256({
 value: self.value.add(b.value) }
 );
 }
 function sub( D256 memory self, D256 memory b ) internal pure returns (D256 memory) {
 return D256({
 value: self.value.sub(b.value) }
 );
 }
 function sub( D256 memory self, D256 memory b, string memory reason ) internal pure returns (D256 memory) {
 return D256({
 value: self.value.sub(b.value, reason) }
 );
 }
 function mul( D256 memory self, D256 memory b ) internal pure returns (D256 memory) {
 return D256({
 value: getPartial(self.value, b.value, BASE) }
 );
 }
 function div( D256 memory self, D256 memory b ) internal pure returns (D256 memory) {
 return D256({
 value: getPartial(self.value, BASE, b.value) }
 );
 }
 function equals(D256 memory self, D256 memory b) internal pure returns (bool) {
 return self.value == b.value;
 }
 function greaterThan(D256 memory self, D256 memory b) internal pure returns (bool) {
 return compareTo(self, b) == 2;
 }
 function lessThan(D256 memory self, D256 memory b) internal pure returns (bool) {
 return compareTo(self, b) == 0;
 }
 function greaterThanOrEqualTo(D256 memory self, D256 memory b) internal pure returns (bool) {
 return compareTo(self, b) > 0;
 }
 function lessThanOrEqualTo(D256 memory self, D256 memory b) internal pure returns (bool) {
 return compareTo(self, b) < 2;
 }
 function isZero(D256 memory self) internal pure returns (bool) {
 return self.value == 0;
 }
 function asUint256(D256 memory self) internal pure returns (uint256) {
 return self.value.div(BASE);
 }
 function getPartial( uint256 target, uint256 numerator, uint256 denominator ) private pure returns (uint256) {
 return target.mul(numerator).div(denominator);
 }
 function compareTo( D256 memory a, D256 memory b ) private pure returns (uint256) {
 if (a.value == b.value) {
 return 1;
 }
 return a.value > b.value ? 2 : 0;
 }
 }
 pragma solidity =0.7.6;
 library LibCheck {
 using SafeMath for uint256;
 function beanBalanceCheck() internal view {
 AppStorage storage s = LibAppStorage.diamondStorage();
 require( IBean(s.c.bean).balanceOf(address(this)) >= s.f.harvestable.sub(s.f.harvested).add(s.bean.deposited).add(s.bean.withdrawn), "Check: Bean balance fail." );
 }
 function lpBalanceCheck() internal view {
 AppStorage storage s = LibAppStorage.diamondStorage();
 require( IUniswapV2Pair(s.c.pair).balanceOf(address(this)) >= s.lp.deposited.add(s.lp.withdrawn), "Check: LP balance fail." );
 }
 function balanceCheck() internal view {
 AppStorage storage s = LibAppStorage.diamondStorage();
 require( IBean(s.c.bean).balanceOf(address(this)) >= s.f.harvestable.sub(s.f.harvested).add(s.bean.deposited).add(s.bean.withdrawn), "Check: Bean balance fail." );
 require( IUniswapV2Pair(s.c.pair).balanceOf(address(this)) >= s.lp.deposited.add(s.lp.withdrawn), "Check: LP balance fail." );
 }
 }
 pragma solidity =0.7.6;
 library LibAppStorage {
 function diamondStorage() internal pure returns (AppStorage storage ds) {
 assembly {
 ds.slot := 0 }
 }
 }
 pragma solidity >=0.6.0 <0.8.0;
 library SafeMath {
 function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 uint256 c = a + b;
 if (c < a) return (false, 0);
 return (true, c);
 }
 function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 if (b > a) return (false, 0);
 return (true, a - b);
 }
 function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 if (a == 0) return (true, 0);
 uint256 c = a * b;
 if (c / a != b) return (false, 0);
 return (true, c);
 }
 function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 if (b == 0) return (false, 0);
 return (true, a / b);
 }
 function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
 if (b == 0) return (false, 0);
 return (true, a % b);
 }
 function add(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a + b;
 require(c >= a, "SafeMath: addition overflow");
 return c;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 require(b <= a, "SafeMath: subtraction overflow");
 return a - b;
 }
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
 if (a == 0) return 0;
 uint256 c = a * b;
 require(c / a == b, "SafeMath: multiplication overflow");
 return c;
 }
 function div(uint256 a, uint256 b) internal pure returns (uint256) {
 require(b > 0, "SafeMath: division by zero");
 return a / b;
 }
 function mod(uint256 a, uint256 b) internal pure returns (uint256) {
 require(b > 0, "SafeMath: modulo by zero");
 return a % b;
 }
 function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b <= a, errorMessage);
 return a - b;
 }
 function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b > 0, errorMessage);
 return a / b;
 }
 function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b > 0, errorMessage);
 return a % b;
 }
 }
 pragma solidity >=0.5.0;
 interface IUniswapV2Pair {
 event Approval(address indexed owner, address indexed spender, uint value);
 event Transfer(address indexed from, address indexed to, uint value);
 function name() external pure returns (string memory);
 function symbol() external pure returns (string memory);
 function decimals() external pure returns (uint8);
 function totalSupply() external view returns (uint);
 function balanceOf(address owner) external view returns (uint);
 function allowance(address owner, address spender) external view returns (uint);
 function approve(address spender, uint value) external returns (bool);
 function transfer(address to, uint value) external returns (bool);
 function transferFrom(address from, address to, uint value) external returns (bool);
 function DOMAIN_SEPARATOR() external view returns (bytes32);
 function PERMIT_TYPEHASH() external pure returns (bytes32);
 function nonces(address owner) external view returns (uint);
 function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
 event Mint(address indexed sender, uint amount0, uint amount1);
 event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
 event Swap( address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to );
 event Sync(uint112 reserve0, uint112 reserve1);
 function MINIMUM_LIQUIDITY() external pure returns (uint);
 function factory() external view returns (address);
 function token0() external view returns (address);
 function token1() external view returns (address);
 function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
 function price0CumulativeLast() external view returns (uint);
 function price1CumulativeLast() external view returns (uint);
 function kLast() external view returns (uint);
 function mint(address to) external returns (uint liquidity);
 function burn(address to) external returns (uint amount0, uint amount1);
 function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
 function skim(address to) external;
 function sync() external;
 function initialize(address, address) external;
 }
 pragma solidity >=0.6.0 <0.8.0;
 library LibSafeMath32 {
 function tryAdd(uint32 a, uint32 b) internal pure returns (bool, uint32) {
 uint32 c = a + b;
 if (c < a) return (false, 0);
 return (true, c);
 }
 function trySub(uint32 a, uint32 b) internal pure returns (bool, uint32) {
 if (b > a) return (false, 0);
 return (true, a - b);
 }
 function tryMul(uint32 a, uint32 b) internal pure returns (bool, uint32) {
 if (a == 0) return (true, 0);
 uint32 c = a * b;
 if (c / a != b) return (false, 0);
 return (true, c);
 }
 function tryDiv(uint32 a, uint32 b) internal pure returns (bool, uint32) {
 if (b == 0) return (false, 0);
 return (true, a / b);
 }
 function tryMod(uint32 a, uint32 b) internal pure returns (bool, uint32) {
 if (b == 0) return (false, 0);
 return (true, a % b);
 }
 function add(uint32 a, uint32 b) internal pure returns (uint32) {
 uint32 c = a + b;
 require(c >= a, "SafeMath: addition overflow");
 return c;
 }
 function sub(uint32 a, uint32 b) internal pure returns (uint32) {
 require(b <= a, "SafeMath: subtraction overflow");
 return a - b;
 }
 function mul(uint32 a, uint32 b) internal pure returns (uint32) {
 if (a == 0) return 0;
 uint32 c = a * b;
 require(c / a == b, "SafeMath: multiplication overflow");
 return c;
 }
 function div(uint32 a, uint32 b) internal pure returns (uint32) {
 require(b > 0, "SafeMath: division by zero");
 return a / b;
 }
 function mod(uint32 a, uint32 b) internal pure returns (uint32) {
 require(b > 0, "SafeMath: modulo by zero");
 return a % b;
 }
 function sub(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {
 require(b <= a, errorMessage);
 return a - b;
 }
 function div(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {
 require(b > 0, errorMessage);
 return a / b;
 }
 function mod(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {
 require(b > 0, errorMessage);
 return a % b;
 }
 }
 pragma solidity =0.7.6;
 contract Account {
 struct Field {
 mapping(uint256 => uint256) plots;
 mapping(address => uint256) podAllowances;
 }
 struct AssetSilo {
 mapping(uint32 => uint256) withdrawals;
 mapping(uint32 => uint256) deposits;
 mapping(uint32 => uint256) depositSeeds;
 }
 struct Deposit {
 uint128 amount;
 uint128 bdv;
 }
 struct Silo {
 uint256 stalk;
 uint256 seeds;
 }
 struct SeasonOfPlenty {
 uint256 base;
 uint256 roots;
 uint256 basePerRoot;
 }
 struct State {
 Field field;
 AssetSilo bean;
 AssetSilo lp;
 Silo s;
 uint32 votedUntil;
 uint32 lastUpdate;
 uint32 lastSop;
 uint32 lastRain;
 uint32 lastSIs;
 uint32 proposedUntil;
 SeasonOfPlenty sop;
 uint256 roots;
 uint256 wrappedBeans;
 mapping(address => mapping(uint32 => Deposit)) deposits;
 mapping(address => mapping(uint32 => uint256)) withdrawals;
 }
 }
 contract Storage {
 struct Contracts {
 address bean;
 address pair;
 address pegPair;
 address weth;
 }
 struct Field {
 uint256 soil;
 uint256 pods;
 uint256 harvested;
 uint256 harvestable;
 }
 struct Bip {
 address proposer;
 uint32 start;
 uint32 period;
 bool executed;
 int pauseOrUnpause;
 uint128 timestamp;
 uint256 roots;
 uint256 endTotalRoots;
 }
 struct DiamondCut {
 IDiamondCut.FacetCut[] diamondCut;
 address initAddress;
 bytes initData;
 }
 struct Governance {
 uint32[] activeBips;
 uint32 bipIndex;
 mapping(uint32 => DiamondCut) diamondCuts;
 mapping(uint32 => mapping(address => bool)) voted;
 mapping(uint32 => Bip) bips;
 }
 struct AssetSilo {
 uint256 deposited;
 uint256 withdrawn;
 }
 struct IncreaseSilo {
 uint256 beans;
 uint256 stalk;
 }
 struct V1IncreaseSilo {
 uint256 beans;
 uint256 stalk;
 uint256 roots;
 }
 struct SeasonOfPlenty {
 uint256 weth;
 uint256 base;
 uint32 last;
 }
 struct Silo {
 uint256 stalk;
 uint256 seeds;
 uint256 roots;
 }
 struct Oracle {
 bool initialized;
 uint256 cumulative;
 uint256 pegCumulative;
 uint32 timestamp;
 uint32 pegTimestamp;
 }
 struct Rain {
 uint32 start;
 bool raining;
 uint256 pods;
 uint256 roots;
 }
 struct Season {
 uint32 current;
 uint32 sis;
 uint8 withdrawSeasons;
 uint256 start;
 uint256 period;
 uint256 timestamp;
 }
 struct Weather {
 uint256 startSoil;
 uint256 lastDSoil;
 uint96 lastSoilPercent;
 uint32 lastSowTime;
 uint32 nextSowTime;
 uint32 yield;
 bool didSowBelowMin;
 bool didSowFaster;
 }
 struct Fundraiser {
 address payee;
 address token;
 uint256 total;
 uint256 remaining;
 uint256 start;
 }
 struct SiloSettings {
 bytes4 selector;
 uint32 seeds;
 uint32 stalk;
 }
 }
 struct AppStorage {
 uint8 index;
 int8[32] cases;
 bool paused;
 uint128 pausedAt;
 Storage.Season season;
 Storage.Contracts c;
 Storage.Field f;
 Storage.Governance g;
 Storage.Oracle o;
 Storage.Rain r;
 Storage.Silo s;
 uint256 reentrantStatus;
 Storage.Weather w;
 Storage.AssetSilo bean;
 Storage.AssetSilo lp;
 Storage.IncreaseSilo si;
 Storage.SeasonOfPlenty sop;
 Storage.V1IncreaseSilo v1SI;
 uint256 unclaimedRoots;
 uint256 v2SIBeans;
 mapping (uint32 => uint256) sops;
 mapping (address => Account.State) a;
 uint32 bip0Start;
 uint32 hotFix3Start;
 mapping (uint32 => Storage.Fundraiser) fundraisers;
 uint32 fundraiserIndex;
 mapping (address => bool) isBudget;
 mapping(uint256 => bytes32) podListings;
 mapping(bytes32 => uint256) podOrders;
 mapping(address => Storage.AssetSilo) siloBalances;
 mapping(address => Storage.SiloSettings) ss;
 uint256 refundStatus;
 uint256 beanRefundAmount;
 uint256 ethRefundAmount;
 }
 pragma solidity =0.7.6;
 interface IDiamondCut {
 enum FacetCutAction {
 Add, Replace, Remove}
 struct FacetCut {
 address facetAddress;
 FacetCutAction action;
 bytes4[] functionSelectors;
 }
 function diamondCut( FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata ) external;
 event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
 }
 pragma solidity =0.7.6;
 interface ISiloUpdate {
 function updateSilo(address account) external payable;
 }
 library LibInternal {
 bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");
 struct FacetAddressAndPosition {
 address facetAddress;
 uint16 functionSelectorPosition;
 }
 struct FacetFunctionSelectors {
 bytes4[] functionSelectors;
 uint16 facetAddressPosition;
 }
 struct DiamondStorage {
 mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
 mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
 address[] facetAddresses;
 mapping(bytes4 => bool) supportedInterfaces;
 address contractOwner;
 }
 function diamondStorage() internal pure returns (DiamondStorage storage ds) {
 bytes32 position = DIAMOND_STORAGE_POSITION;
 assembly {
 ds.slot := position }
 }
 function updateSilo(address account) internal {
 DiamondStorage storage ds = diamondStorage();
 address facet = ds.selectorToFacetAndPosition[ISiloUpdate.updateSilo.selector].facetAddress;
 bytes memory myFunctionCall = abi.encodeWithSelector(ISiloUpdate.updateSilo.selector, account);
 (bool success,) = address(facet).delegatecall(myFunctionCall);
 require(success, "Silo: updateSilo failed.");
 }
 }
 pragma solidity =0.7.6;
 library LibMarket {
 event BeanAllocation(address indexed account, uint256 beans);
 struct DiamondStorage {
 address bean;
 address weth;
 address router;
 }
 struct AddLiquidity {
 uint256 beanAmount;
 uint256 minBeanAmount;
 uint256 minEthAmount;
 }
 using SafeMath for uint256;
 bytes32 private constant MARKET_STORAGE_POSITION = keccak256("diamond.standard.market.storage");
 function diamondStorage() internal pure returns (DiamondStorage storage ds) {
 bytes32 position = MARKET_STORAGE_POSITION;
 assembly {
 ds.slot := position }
 }
 function initMarket(address bean, address weth, address router) internal {
 DiamondStorage storage ds = diamondStorage();
 ds.bean = bean;
 ds.weth = weth;
 ds.router = router;
 }
 function buy(uint256 buyBeanAmount) internal returns (uint256 amount) {
 (, amount) = _buy(buyBeanAmount, msg.value, msg.sender);
 }
 function buyAndDeposit(uint256 buyBeanAmount) internal returns (uint256 amount) {
 (, amount) = _buy(buyBeanAmount, msg.value, address(this));
 }
 function buyExactTokensToWallet(uint256 buyBeanAmount, address to, bool toWallet) internal returns (uint256 amount) {
 AppStorage storage s = LibAppStorage.diamondStorage();
 if (toWallet) amount = buyExactTokens(buyBeanAmount, to);
 else {
 amount = buyExactTokens(buyBeanAmount, address(this));
 s.a[to].wrappedBeans = s.a[to].wrappedBeans.add(amount);
 }
 }
 function buyExactTokens(uint256 buyBeanAmount, address to) internal returns (uint256 amount) {
 (uint256 ethAmount, uint256 beanAmount) = _buyExactTokens(buyBeanAmount, msg.value, to);
 allocateEthRefund(msg.value, ethAmount, false);
 return beanAmount;
 }
 function sellToWETH(uint256 sellBeanAmount, uint256 minBuyEthAmount) internal returns (uint256 amount) {
 (,uint256 outAmount) = _sell(sellBeanAmount, minBuyEthAmount, address(this));
 return outAmount;
 }
 function removeLiquidity(uint256 liqudity, uint256 minBeanAmount,uint256 minEthAmount) internal returns (uint256 beanAmount, uint256 ethAmount) {
 DiamondStorage storage ds = diamondStorage();
 return IUniswapV2Router02(ds.router).removeLiquidityETH( ds.bean, liqudity, minBeanAmount, minEthAmount, msg.sender, block.timestamp );
 }
 function removeLiquidityWithBeanAllocation(uint256 liqudity, uint256 minBeanAmount,uint256 minEthAmount) internal returns (uint256 beanAmount, uint256 ethAmount) {
 DiamondStorage storage ds = diamondStorage();
 (beanAmount, ethAmount) = IUniswapV2Router02(ds.router).removeLiquidity( ds.bean, ds.weth, liqudity, minBeanAmount, minEthAmount, address(this), block.timestamp );
 allocateEthRefund(ethAmount, 0, true);
 }
 function addAndDepositLiquidity(AddLiquidity calldata al) internal returns (uint256) {
 allocateBeans(al.beanAmount);
 (, uint256 liquidity) = addLiquidity(al);
 return liquidity;
 }
 function addLiquidity(AddLiquidity calldata al) internal returns (uint256, uint256) {
 (uint256 beansDeposited, uint256 ethDeposited, uint256 liquidity) = _addLiquidity( msg.value, al.beanAmount, al.minEthAmount, al.minBeanAmount );
 allocateEthRefund(msg.value, ethDeposited, false);
 allocateBeanRefund(al.beanAmount, beansDeposited);
 return (beansDeposited, liquidity);
 }
 function swapAndAddLiquidity( uint256 buyBeanAmount, uint256 buyEthAmount, LibMarket.AddLiquidity calldata al ) internal returns (uint256) {
 uint256 boughtLP;
 if (buyBeanAmount > 0) boughtLP = LibMarket.buyBeansAndAddLiquidity(buyBeanAmount, al);
 else if (buyEthAmount > 0) boughtLP = LibMarket.buyEthAndAddLiquidity(buyEthAmount, al);
 else boughtLP = LibMarket.addAndDepositLiquidity(al);
 return boughtLP;
 }
 function buyBeansAndAddLiquidity(uint256 buyBeanAmount, AddLiquidity calldata al) internal returns (uint256 liquidity) {
 DiamondStorage storage ds = diamondStorage();
 IWETH(ds.weth).deposit{
 value: msg.value}
 ();
 address[] memory path = new address[](2);
 path[0] = ds.weth;
 path[1] = ds.bean;
 uint256[] memory amounts = IUniswapV2Router02(ds.router).getAmountsIn(buyBeanAmount, path);
 (uint256 ethSold, uint256 beans) = _buyWithWETH(buyBeanAmount, amounts[0], address(this));
 if (al.beanAmount > buyBeanAmount) {
 uint256 newBeanAmount = al.beanAmount - buyBeanAmount;
 allocateBeans(newBeanAmount);
 beans = beans.add(newBeanAmount);
 }
 uint256 ethAdded;
 (beans, ethAdded, liquidity) = _addLiquidityWETH( msg.value.sub(ethSold), beans, al.minEthAmount, al.minBeanAmount );
 allocateBeanRefund(al.beanAmount, beans);
 allocateEthRefund(msg.value, ethAdded.add(ethSold), true);
 return liquidity;
 }
 function buyEthAndAddLiquidity(uint256 buyWethAmount, AddLiquidity calldata al) internal returns (uint256) {
 DiamondStorage storage ds = diamondStorage();
 uint256 sellBeans = _amountIn(buyWethAmount);
 allocateBeans(al.beanAmount.add(sellBeans));
 (uint256 beansSold, uint256 wethBought) = _sell(sellBeans, buyWethAmount, address(this));
 if (msg.value > 0) IWETH(ds.weth).deposit{
 value: msg.value}
 ();
 (uint256 beans, uint256 ethAdded, uint256 liquidity) = _addLiquidityWETH( msg.value.add(wethBought), al.beanAmount, al.minEthAmount, al.minBeanAmount );
 allocateBeanRefund(al.beanAmount.add(sellBeans), beans.add(beansSold));
 allocateEthRefund(msg.value.add(wethBought), ethAdded, true);
 return liquidity;
 }
 function _sell(uint256 sellBeanAmount, uint256 minBuyEthAmount, address to) internal returns (uint256 inAmount, uint256 outAmount) {
 DiamondStorage storage ds = diamondStorage();
 address[] memory path = new address[](2);
 path[0] = ds.bean;
 path[1] = ds.weth;
 uint[] memory amounts = IUniswapV2Router02(ds.router).swapExactTokensForTokens( sellBeanAmount, minBuyEthAmount, path, to, block.timestamp );
 return (amounts[0], amounts[1]);
 }
 function _buy(uint256 beanAmount, uint256 ethAmount, address to) private returns (uint256 inAmount, uint256 outAmount) {
 DiamondStorage storage ds = diamondStorage();
 address[] memory path = new address[](2);
 path[0] = ds.weth;
 path[1] = ds.bean;
 uint[] memory amounts = IUniswapV2Router02(ds.router).swapExactETHForTokens{
 value: ethAmount}
 ( beanAmount, path, to, block.timestamp );
 return (amounts[0], amounts[1]);
 }
 function _buyExactTokens(uint256 beanAmount, uint256 ethAmount, address to) private returns (uint256 inAmount, uint256 outAmount) {
 DiamondStorage storage ds = diamondStorage();
 address[] memory path = new address[](2);
 path[0] = ds.weth;
 path[1] = ds.bean;
 uint[] memory amounts = IUniswapV2Router02(ds.router).swapETHForExactTokens{
 value: ethAmount}
 ( beanAmount, path, to, block.timestamp );
 return (amounts[0], amounts[1]);
 }
 function _buyWithWETH(uint256 beanAmount, uint256 ethAmount, address to) internal returns (uint256 inAmount, uint256 outAmount) {
 DiamondStorage storage ds = diamondStorage();
 address[] memory path = new address[](2);
 path[0] = ds.weth;
 path[1] = ds.bean;
 uint[] memory amounts = IUniswapV2Router02(ds.router).swapExactTokensForTokens( ethAmount, beanAmount, path, to, block.timestamp );
 return (amounts[0], amounts[1]);
 }
 function _addLiquidity(uint256 ethAmount, uint256 beanAmount, uint256 minEthAmount, uint256 minBeanAmount) private returns (uint256, uint256, uint256) {
 DiamondStorage storage ds = diamondStorage();
 return IUniswapV2Router02(ds.router).addLiquidityETH{
 value: ethAmount}
 ( ds.bean, beanAmount, minBeanAmount, minEthAmount, address(this), block.timestamp);
 }
 function _addLiquidityWETH(uint256 wethAmount, uint256 beanAmount, uint256 minWethAmount, uint256 minBeanAmount) internal returns (uint256, uint256, uint256) {
 DiamondStorage storage ds = diamondStorage();
 return IUniswapV2Router02(ds.router).addLiquidity( ds.bean, ds.weth, beanAmount, wethAmount, minBeanAmount, minWethAmount, address(this), block.timestamp);
 }
 function _amountIn(uint256 buyWethAmount) internal view returns (uint256) {
 DiamondStorage storage ds = diamondStorage();
 address[] memory path = new address[](2);
 path[0] = ds.bean;
 path[1] = ds.weth;
 uint256[] memory amounts = IUniswapV2Router02(ds.router).getAmountsIn(buyWethAmount, path);
 return amounts[0];
 }
 function allocateBeansToWallet(uint256 amount, address to, bool toWallet) internal {
 AppStorage storage s = LibAppStorage.diamondStorage();
 if (toWallet) LibMarket.allocateBeansTo(amount, to);
 else {
 LibMarket.allocateBeansTo(amount, address(this));
 s.a[to].wrappedBeans = s.a[to].wrappedBeans.add(amount);
 }
 }
 function transferBeans(address to, uint256 amount, bool toWallet) internal {
 AppStorage storage s = LibAppStorage.diamondStorage();
 if (toWallet) IBean(s.c.bean).transferFrom(msg.sender, to, amount);
 else {
 IBean(s.c.bean).transferFrom(msg.sender, address(this), amount);
 s.a[to].wrappedBeans = s.a[to].wrappedBeans.add(amount);
 }
 }
 function allocateBeans(uint256 amount) internal {
 allocateBeansTo(amount, address(this));
 }
 function allocateBeansTo(uint256 amount, address to) internal {
 AppStorage storage s = LibAppStorage.diamondStorage();
 uint wrappedBeans = s.a[msg.sender].wrappedBeans;
 uint remainingBeans = amount;
 if (wrappedBeans > 0) {
 if (remainingBeans > wrappedBeans) {
 s.a[msg.sender].wrappedBeans = 0;
 remainingBeans = remainingBeans - wrappedBeans;
 }
 else {
 s.a[msg.sender].wrappedBeans = wrappedBeans - remainingBeans;
 remainingBeans = 0;
 }
 uint fromWrappedBeans = amount - remainingBeans;
 emit BeanAllocation(msg.sender, fromWrappedBeans);
 if (to != address(this)) IBean(s.c.bean).transfer(to, fromWrappedBeans);
 }
 if (remainingBeans > 0) IBean(s.c.bean).transferFrom(msg.sender, to, remainingBeans);
 }
 function allocateBeanRefund(uint256 inputAmount, uint256 amount) internal {
 if (inputAmount > amount) {
 AppStorage storage s = LibAppStorage.diamondStorage();
 if (s.refundStatus % 2 == 1) {
 s.refundStatus += 1;
 s.beanRefundAmount = inputAmount - amount;
 }
 else s.beanRefundAmount = s.beanRefundAmount.add(inputAmount - amount);
 }
 }
 function allocateEthRefund(uint256 inputAmount, uint256 amount, bool weth) internal {
 if (inputAmount > amount) {
 AppStorage storage s = LibAppStorage.diamondStorage();
 if (weth) IWETH(s.c.weth).withdraw(inputAmount - amount);
 if (s.refundStatus < 3) {
 s.refundStatus += 2;
 s.ethRefundAmount = inputAmount - amount;
 }
 else s.ethRefundAmount = s.ethRefundAmount.add(inputAmount - amount);
 }
 }
 function claimRefund(LibClaim.Claim calldata c) internal {
 if (c.convertLP && !c.toWallet && c.lpWithdrawals.length > 0) refund();
 }
 function refund() internal {
 AppStorage storage s = LibAppStorage.diamondStorage();
 uint256 rs = s.refundStatus;
 if(rs > 1) {
 if (rs > 2) {
 (bool success,) = msg.sender.call{
 value: s.ethRefundAmount }
 ("");
 require(success, "Market: Refund failed.");
 rs -= 2;
 s.ethRefundAmount = 1;
 }
 if (rs == 2) {
 IBean(s.c.bean).transfer(msg.sender, s.beanRefundAmount);
 s.beanRefundAmount = 1;
 }
 s.refundStatus = 1;
 }
 }
 }
 pragma solidity =0.7.6;
 interface IWETH is IERC20 {
 function deposit() external payable;
 function withdraw(uint) external;
 }
 pragma solidity >=0.6.2;
 interface IUniswapV2Router02 is IUniswapV2Router01 {
 function removeLiquidityETHSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external returns (uint amountETH);
 function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountETH);
 function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
 function swapExactETHForTokensSupportingFeeOnTransferTokens( uint amountOutMin, address[] calldata path, address to, uint deadline ) external payable;
 function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
 }
