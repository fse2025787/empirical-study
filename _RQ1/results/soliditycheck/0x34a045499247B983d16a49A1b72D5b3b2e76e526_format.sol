  pragma experimental ABIEncoderV2;
 pragma solidity 0.6.12;
 interface IGauge {
 struct VotedSlope {
 uint slope;
 uint power;
 uint end;
 }
 struct Point {
 uint bias;
 uint slope;
 }
 function vote_user_slopes(address, address) external view returns (VotedSlope memory);
 function last_user_vote(address, address) external view returns (uint);
 function points_weight(address, uint256) external view returns (Point memory);
 function checkpoint_gauge(address) external;
 function time_total() external view returns (uint);
 }
 interface IStrategy {
 function estimatedTotalAssets() external view returns (uint);
 function rewardsContract() external view returns (address);
 }
 interface IRewards {
 function getReward(address, bool) external;
 }
 interface IYveCRV {
 function deposit(uint) external;
 }
 contract Splitter {
 using SafeMath for uint256;
 event Split(uint yearnAmount, uint keep, uint templeAmount, uint period);
 event PeriodUpdated(uint period, uint globalSlope, uint userSlope);
 event YearnUpdated(address recipient, uint keepCRV);
 event TempleUpdated(address recipient);
 event ShareUpdated(uint share);
 event PendingShareUpdated(address setter, uint share);
 event Sweep(address sweeper, address token, uint amount);
 struct Yearn{
 address recipient;
 address voter;
 address admin;
 uint share;
 uint keepCRV;
 }
 struct Period{
 uint period;
 uint globalSlope;
 uint userSlope;
 }
 uint internal constant precision = 10_000;
 uint internal constant WEEK = 7 days;
 IERC20 internal constant crv = IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);
 IYveCRV internal constant yvecrv = IYveCRV(0xc5bDdf9843308380375a611c18B50Fb9341f502A);
 IERC20 public constant liquidityPool = IERC20(0xdaDfD00A2bBEb1abc4936b1644a3033e1B653228);
 IGauge public constant gaugeController = IGauge(0x2F50D538606Fa9EDD2B11E2446BEb18C9D5846bB);
 address public constant gauge = 0x8f162742a7BCDb87EB52d83c687E43356055a68B;
 mapping(address => uint) pendingShare;
 Yearn yearn;
 Period period;
 address public strategy;
 address templeRecipient = 0xE97CB3a6A0fb5DA228976F3F2B8c37B6984e7915;
 constructor() public {
 crv.approve(address(yvecrv), type(uint).max);
 yearn = Yearn( address(0x93A62dA5a14C80f265DAbC077fCEE437B1a0Efde), address(0xF147b8125d2ef93FB6965Db97D6746952a133934), address(0xFEB4acf3df3cDEA7399794D0869ef76A6EfAff52), 8_000, 5_000 );
 }
 function split() external {
 _split();
 }
 function claimAndSplit() external {
 IRewards(IStrategy(strategy).rewardsContract()).getReward(strategy, true);
 _split();
 }
 function _split() internal {
 address _strategy = strategy;
 if(_strategy == address(0)) return;
 uint crvBalance = crv.balanceOf(_strategy);
 if (crvBalance == 0) {
 emit Split(0, 0, 0, period.period);
 return;
 }
 if (block.timestamp / WEEK * WEEK > period.period) _updatePeriod();
 (uint yRatio, uint tRatio) = _computeSplitRatios();
 if (yRatio == 0) {
 crv.transferFrom(_strategy, templeRecipient, crvBalance);
 emit Split(0, 0, crvBalance, period.period);
 return;
 }
 uint yearnAmount = crvBalance * yRatio / precision;
 uint templeAmount = crvBalance * tRatio / precision;
 uint keep = yearnAmount * yearn.keepCRV / precision;
 if (keep > 0) {
 crv.transferFrom(_strategy, address(this), keep);
 yvecrv.deposit(keep);
 IERC20(address(yvecrv)).transfer(yearn.recipient, keep);
 }
 crv.transferFrom(_strategy, yearn.recipient, yearnAmount.sub(keep));
 crv.transferFrom(_strategy, templeRecipient, templeAmount);
 emit Split(yearnAmount, keep, templeAmount, period.period);
 }
 function _updatePeriod() internal {
 uint _period = block.timestamp / WEEK * WEEK;
 period.period = _period;
 gaugeController.checkpoint_gauge(gauge);
 uint _userSlope = gaugeController.vote_user_slopes(yearn.voter, gauge).slope;
 uint _globalSlope = gaugeController.points_weight(gauge, _period).slope;
 period.userSlope = _userSlope;
 period.globalSlope = _globalSlope;
 emit PeriodUpdated(_period, _userSlope, _globalSlope);
 }
 function _computeSplitRatios() internal view returns (uint yRatio, uint tRatio) {
 uint userSlope = period.userSlope;
 if(userSlope == 0) return (0, 10_000);
 uint relativeSlope = period.globalSlope == 0 ? 0 : userSlope * precision / period.globalSlope;
 uint lpSupply = liquidityPool.totalSupply();
 if (lpSupply == 0) return (10_000, 0);
 uint gaugeDominance = IStrategy(strategy).estimatedTotalAssets() * precision / lpSupply;
 if (gaugeDominance == 0) return (10_000, 0);
 yRatio = relativeSlope * yearn.share / gaugeDominance;
 if (yRatio > 10_000){
 return (10_000, 0);
 }
 tRatio = precision.sub(yRatio);
 }
 function estimateSplit() external view returns (uint ySplit, uint tSplit) {
 (uint y, uint t) = _computeSplitRatios();
 uint bal = crv.balanceOf(strategy);
 ySplit = bal * y / precision;
 tSplit = bal.sub(ySplit);
 }
 function estimateSplitRatios() external view returns (uint ySplit, uint tSplit) {
 (ySplit, tSplit) = _computeSplitRatios();
 }
 function updatePeriod() external {
 _updatePeriod();
 }
 function setStrategy(address _strategy) external {
 require(msg.sender == yearn.admin);
 strategy = _strategy;
 }
 function setYearn(address _recipient, uint _keepCRV) external {
 require(msg.sender == yearn.admin);
 require(_keepCRV <= 10_000, "TooHigh");
 address recipient = yearn.recipient;
 if(recipient != _recipient){
 pendingShare[recipient] = 0;
 yearn.recipient = _recipient;
 }
 yearn.keepCRV = _keepCRV;
 emit YearnUpdated(_recipient, _keepCRV);
 }
 function setTemple(address _recipient) external {
 address recipient = templeRecipient;
 require(msg.sender == recipient);
 if(recipient != _recipient){
 pendingShare[recipient] = 0;
 templeRecipient = _recipient;
 emit TempleUpdated(_recipient);
 }
 }
 function updateYearnShare(uint _share) external {
 require(_share <= 10_000 && _share != 0, "OutOfRange");
 require(msg.sender == yearn.admin || msg.sender == templeRecipient);
 if(msg.sender == yearn.admin && pendingShare[msg.sender] != _share){
 pendingShare[msg.sender] = _share;
 emit PendingShareUpdated(msg.sender, _share);
 if (pendingShare[templeRecipient] == _share) {
 yearn.share = _share;
 emit ShareUpdated(_share);
 }
 }
 else if(msg.sender == templeRecipient && pendingShare[msg.sender] != _share){
 pendingShare[msg.sender] = _share;
 emit PendingShareUpdated(msg.sender, _share);
 if (pendingShare[yearn.admin] == _share) {
 yearn.share = _share;
 emit ShareUpdated(_share);
 }
 }
 }
 function sweep(address _token) external {
 require(msg.sender == templeRecipient || msg.sender == yearn.admin);
 IERC20 token = IERC20(_token);
 uint amt = token.balanceOf(address(this));
 token.transfer(msg.sender, amt);
 emit Sweep(msg.sender, _token, amt);
 }
 }
 pragma solidity ^0.6.0;
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
 pragma solidity ^0.6.0;
 library SafeMath {
 function add(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a + b;
 require(c >= a, "SafeMath: addition overflow");
 return c;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 return sub(a, b, "SafeMath: subtraction overflow");
 }
 function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b <= a, errorMessage);
 uint256 c = a - b;
 return c;
 }
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
 if (a == 0) {
 return 0;
 }
 uint256 c = a * b;
 require(c / a == b, "SafeMath: multiplication overflow");
 return c;
 }
 function div(uint256 a, uint256 b) internal pure returns (uint256) {
 return div(a, b, "SafeMath: division by zero");
 }
 function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b > 0, errorMessage);
 uint256 c = a / b;
 return c;
 }
 function mod(uint256 a, uint256 b) internal pure returns (uint256) {
 return mod(a, b, "SafeMath: modulo by zero");
 }
 function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b != 0, errorMessage);
 return a % b;
 }
 }
