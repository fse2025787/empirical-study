         pragma solidity 0.7.6;
 library Address {
 function isContract(address account) internal view returns (bool) {
 uint size;
 assembly {
 size := extcodesize(account) }
 return size > 0;
 }
 function sendValue(address payable recipient, uint amount) internal {
 require(address(this).balance >= amount, "Address: insufficient balance");
 (bool success, ) = recipient.call{
 value: amount}
 ("");
 require(success, "Address: unable to send value, recipient may have reverted");
 }
 function functionCall(address target, bytes memory data) internal returns (bytes memory) {
 return functionCall(target, data, "Address: low-level call failed");
 }
 function functionCall( address target, bytes memory data, string memory errorMessage ) internal returns (bytes memory) {
 return functionCallWithValue(target, data, 0, errorMessage);
 }
 function functionCallWithValue( address target, bytes memory data, uint value ) internal returns (bytes memory) {
 return functionCallWithValue( target, data, value, "Address: low-level call with value failed" );
 }
 function functionCallWithValue( address target, bytes memory data, uint value, string memory errorMessage ) internal returns (bytes memory) {
 require( address(this).balance >= value, "Address: insufficient balance for call" );
 require(isContract(target), "Address: call to non-contract");
 (bool success, bytes memory returndata) = target.call{
 value: value}
 (data);
 return _verifyCallResult(success, returndata, errorMessage);
 }
 function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
 return functionStaticCall(target, data, "Address: low-level static call failed");
 }
 function functionStaticCall( address target, bytes memory data, string memory errorMessage ) internal view returns (bytes memory) {
 require(isContract(target), "Address: static call to non-contract");
 (bool success, bytes memory returndata) = target.staticcall(data);
 return _verifyCallResult(success, returndata, errorMessage);
 }
 function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
 return functionDelegateCall( target, data, "Address: low-level delegate call failed" );
 }
 function functionDelegateCall( address target, bytes memory data, string memory errorMessage ) internal returns (bytes memory) {
 require(isContract(target), "Address: delegate call to non-contract");
 (bool success, bytes memory returndata) = target.delegatecall(data);
 return _verifyCallResult(success, returndata, errorMessage);
 }
 function _verifyCallResult( bool success, bytes memory returndata, string memory errorMessage ) private pure returns (bytes memory) {
 if (success) {
 return returndata;
 }
 else {
 if (returndata.length > 0) {
 assembly {
 let returndata_size := mload(returndata) revert(add(32, returndata), returndata_size) }
 }
 else {
 revert(errorMessage);
 }
 }
 }
 }
 interface BaseRewardPool {
 function balanceOf(address _account) external view returns (uint);
 function getReward(address _account, bool _claimExtras) external returns (bool);
 function withdrawAndUnwrap(uint amount, bool claim) external returns (bool);
 }
 interface Booster {
 function poolInfo(uint _pid) external view returns ( address lptoken, address token, address gauge, address crvRewards, address stash, bool shutdown );
 function deposit( uint _pid, uint _amount, bool _stake ) external returns (bool);
 function withdraw(uint _pid, uint _amount) external returns (bool);
 }
 interface DepositZapUsdp3Crv {
 function add_liquidity(uint[4] calldata _amounts, uint _min_mint_amount) external returns (uint);
 function remove_liquidity_one_coin( uint _burn_amount, int128 _i, uint _min_amount ) external returns (uint);
 function calc_withdraw_one_coin( address _pool, uint _amount, int128 _i ) external view returns (uint);
 }
 interface IERC20 {
 function totalSupply() external view returns (uint);
 function balanceOf(address account) external view returns (uint);
 function transfer(address recipient, uint amount) external returns (bool);
 function allowance(address owner, address spender) external view returns (uint);
 function approve(address spender, uint amount) external returns (bool);
 function transferFrom( address sender, address recipient, uint amount ) external returns (bool);
 event Transfer(address indexed from, address indexed to, uint value);
 event Approval(address indexed owner, address indexed spender, uint value);
 }
 interface IFundManager {
 function token() external view returns (address);
 function borrow(uint amount) external returns (uint);
 function repay(uint amount) external returns (uint);
 function report(uint gain, uint loss) external;
 function getDebt(address strategy) external view returns (uint);
 }
 library SafeERC20 {
 using SafeMath for uint;
 using Address for address;
 function safeTransfer( IERC20 token, address to, uint value ) internal {
 _callOptionalReturn( token, abi.encodeWithSelector(token.transfer.selector, to, value) );
 }
 function safeTransferFrom( IERC20 token, address from, address to, uint value ) internal {
 _callOptionalReturn( token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value) );
 }
 function safeApprove( IERC20 token, address spender, uint value ) internal {
 require( (value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance" );
 _callOptionalReturn( token, abi.encodeWithSelector(token.approve.selector, spender, value) );
 }
 function safeIncreaseAllowance( IERC20 token, address spender, uint value ) internal {
 uint newAllowance = token.allowance(address(this), spender).add(value);
 _callOptionalReturn( token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance) );
 }
 function safeDecreaseAllowance( IERC20 token, address spender, uint value ) internal {
 uint newAllowance = token.allowance(address(this), spender).sub( value, "SafeERC20: decreased allowance below zero" );
 _callOptionalReturn( token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance) );
 }
 function _callOptionalReturn(IERC20 token, bytes memory data) private {
 bytes memory returndata = address(token).functionCall( data, "SafeERC20: low-level call failed" );
 if (returndata.length > 0) {
 require( abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed" );
 }
 }
 }
 library SafeMath {
 function tryAdd(uint a, uint b) internal pure returns (bool, uint) {
 uint c = a + b;
 if (c < a) return (false, 0);
 return (true, c);
 }
 function trySub(uint a, uint b) internal pure returns (bool, uint) {
 if (b > a) return (false, 0);
 return (true, a - b);
 }
 function tryMul(uint a, uint b) internal pure returns (bool, uint) {
 if (a == 0) return (true, 0);
 uint c = a * b;
 if (c / a != b) return (false, 0);
 return (true, c);
 }
 function tryDiv(uint a, uint b) internal pure returns (bool, uint) {
 if (b == 0) return (false, 0);
 return (true, a / b);
 }
 function tryMod(uint a, uint b) internal pure returns (bool, uint) {
 if (b == 0) return (false, 0);
 return (true, a % b);
 }
 function add(uint a, uint b) internal pure returns (uint) {
 uint c = a + b;
 require(c >= a, "SafeMath: addition overflow");
 return c;
 }
 function sub(uint a, uint b) internal pure returns (uint) {
 require(b <= a, "SafeMath: subtraction overflow");
 return a - b;
 }
 function mul(uint a, uint b) internal pure returns (uint) {
 if (a == 0) return 0;
 uint c = a * b;
 require(c / a == b, "SafeMath: multiplication overflow");
 return c;
 }
 function div(uint a, uint b) internal pure returns (uint) {
 require(b > 0, "SafeMath: division by zero");
 return a / b;
 }
 function mod(uint a, uint b) internal pure returns (uint) {
 require(b > 0, "SafeMath: modulo by zero");
 return a % b;
 }
 function sub( uint a, uint b, string memory errorMessage ) internal pure returns (uint) {
 require(b <= a, errorMessage);
 return a - b;
 }
 function div( uint a, uint b, string memory errorMessage ) internal pure returns (uint) {
 require(b > 0, errorMessage);
 return a / b;
 }
 function mod( uint a, uint b, string memory errorMessage ) internal pure returns (uint) {
 require(b > 0, errorMessage);
 return a % b;
 }
 }
 interface StableSwapUsdp3Crv {
 function coins(uint _i) external view returns (address);
 function get_virtual_price() external view returns (uint);
 }
 abstract contract Strategy {
 using SafeERC20 for IERC20;
 using SafeMath for uint;
 event SetNextTimeLock(address nextTimeLock);
 event AcceptTimeLock(address timeLock);
 event SetAdmin(address admin);
 event Authorize(address addr, bool authorized);
 event SetTreasury(address treasury);
 event SetFundManager(address fundManager);
 event Deposit(uint amount, uint borrowed);
 event Repay(uint amount, uint repaid);
 event Withdraw(uint amount, uint withdrawn, uint loss);
 event ClaimRewards(uint profit);
 event Skim(uint total, uint debt, uint profit);
 event Report(uint gain, uint loss, uint free, uint total, uint debt);
 address public timeLock;
 address public nextTimeLock;
 address public admin;
 address public treasury;
 mapping(address => bool) public authorized;
 IERC20 public immutable token;
 IFundManager public fundManager;
 uint public perfFee = 1000;
 uint private constant PERF_FEE_CAP = 2000;
 uint internal constant PERF_FEE_MAX = 10000;
 bool public claimRewardsOnMigrate = true;
 constructor( address _token, address _fundManager, address _treasury ) {
 require(_treasury != address(0), "treasury = 0 address");
 timeLock = msg.sender;
 admin = msg.sender;
 treasury = _treasury;
 require( IFundManager(_fundManager).token() == _token, "fund manager token != token" );
 fundManager = IFundManager(_fundManager);
 token = IERC20(_token);
 IERC20(_token).safeApprove(_fundManager, type(uint).max);
 }
 modifier onlyTimeLock() {
 require(msg.sender == timeLock, "!time lock");
 _;
 }
 modifier onlyTimeLockOrAdmin() {
 require(msg.sender == timeLock || msg.sender == admin, "!auth");
 _;
 }
 modifier onlyAuthorized() {
 require( msg.sender == timeLock || msg.sender == admin || authorized[msg.sender], "!auth" );
 _;
 }
 modifier onlyFundManager() {
 require(msg.sender == address(fundManager), "!fund manager");
 _;
 }
 function setNextTimeLock(address _nextTimeLock) external onlyTimeLock {
 nextTimeLock = _nextTimeLock;
 emit SetNextTimeLock(_nextTimeLock);
 }
 function acceptTimeLock() external {
 require(msg.sender == nextTimeLock, "!next time lock");
 timeLock = msg.sender;
 nextTimeLock = address(0);
 emit AcceptTimeLock(msg.sender);
 }
 function setAdmin(address _admin) external onlyTimeLockOrAdmin {
 require(_admin != address(0), "admin = 0 address");
 admin = _admin;
 emit SetAdmin(_admin);
 }
 function authorize(address _addr, bool _authorized) external onlyTimeLockOrAdmin {
 require(_addr != address(0), "addr = 0 address");
 authorized[_addr] = _authorized;
 emit Authorize(_addr, _authorized);
 }
 function setTreasury(address _treasury) external onlyTimeLockOrAdmin {
 require(_treasury != address(0), "treasury = 0 address");
 treasury = _treasury;
 emit SetTreasury(_treasury);
 }
 function setPerfFee(uint _fee) external onlyTimeLockOrAdmin {
 require(_fee <= PERF_FEE_CAP, "fee > cap");
 perfFee = _fee;
 }
 function setFundManager(address _fundManager) external onlyTimeLock {
 if (address(fundManager) != address(0)) {
 token.safeApprove(address(fundManager), 0);
 }
 require( IFundManager(_fundManager).token() == address(token), "new fund manager token != token" );
 fundManager = IFundManager(_fundManager);
 token.safeApprove(_fundManager, type(uint).max);
 emit SetFundManager(_fundManager);
 }
 function setClaimRewardsOnMigrate(bool _claimRewards) external onlyTimeLockOrAdmin {
 claimRewardsOnMigrate = _claimRewards;
 }
 function transferTokenFrom(address _from, uint _amount) external onlyAuthorized {
 token.safeTransferFrom(_from, address(this), _amount);
 }
 function totalAssets() external view virtual returns (uint);
 function deposit(uint _amount, uint _min) external virtual;
 function withdraw(uint _amount) external virtual returns (uint);
 function repay(uint _amount, uint _min) external virtual;
 function claimRewards(uint _minProfit) external virtual;
 function skim() external virtual;
 function report(uint _minTotal, uint _maxTotal) external virtual;
 function harvest( uint _minProfit, uint _minTotal, uint _maxTotal ) external virtual;
 function migrate(address _strategy) external virtual;
 function sweep(address _token) external virtual;
 }
 contract StrategyConvexUsdp is Strategy {
 using SafeERC20 for IERC20;
 using SafeMath for uint;
 address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
 uint private constant NUM_REWARDS = 3;
 address[NUM_REWARDS] public dex;
 address private constant CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;
 address private constant CVX = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
 address[NUM_REWARDS] private REWARDS = [CRV, CVX];
 Booster private constant BOOSTER = Booster(0xF403C135812408BFbE8713b5A23a04b3D48AAE31);
 uint private constant PID = 28;
 BaseRewardPool private constant REWARD = BaseRewardPool(0x24DfFd1949F888F91A0c8341Fc98a3F280a782a8);
 bool public shouldClaimExtras = true;
 DepositZapUsdp3Crv private constant ZAP = DepositZapUsdp3Crv(0x3c8cAee4E09296800f8D29A68Fa3837e2dae4940);
 StableSwapUsdp3Crv private constant CURVE_POOL = StableSwapUsdp3Crv(0x42d7025938bEc20B69cBae5A77421082407f053A);
 IERC20 private constant CURVE_LP = IERC20(0x7Eb40E450b9655f4B3cC4259BCC731c63ff55ae6);
 uint public slip = 100;
 uint private constant SLIP_MAX = 10000;
 uint[4] private MULS = [1, 1, 1e12, 1e12];
 uint private immutable MUL;
 uint private immutable INDEX;
 constructor( address _token, address _fundManager, address _treasury, uint _index ) Strategy(_token, _fundManager, _treasury) {
 require(_index > 0, "index = 0");
 INDEX = _index;
 MUL = MULS[_index];
 (address lptoken, , , address crvRewards, , ) = BOOSTER.poolInfo(PID);
 require(address(CURVE_LP) == lptoken, "curve pool lp != pool info lp");
 require(address(REWARD) == crvRewards, "reward != pool info reward");
 IERC20(_token).safeApprove(address(ZAP), type(uint).max);
 CURVE_LP.safeApprove(address(BOOSTER), type(uint).max);
 CURVE_LP.safeApprove(address(ZAP), type(uint).max);
 _setDex(0, 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);
 _setDex(1, 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);
 }
 function _setDex(uint _i, address _dex) private {
 IERC20 reward = IERC20(REWARDS[_i]);
 if (dex[_i] != address(0)) {
 reward.safeApprove(dex[_i], 0);
 }
 dex[_i] = _dex;
 reward.safeApprove(_dex, type(uint).max);
 }
 function setDex(uint _i, address _dex) external onlyTimeLock {
 require(_dex != address(0), "dex = 0 address");
 _setDex(_i, _dex);
 }
 function setSlip(uint _slip) external onlyAuthorized {
 require(_slip <= SLIP_MAX, "slip > max");
 slip = _slip;
 }
 function setShouldClaimExtras(bool _shouldClaimExtras) external onlyAuthorized {
 shouldClaimExtras = _shouldClaimExtras;
 }
 function _totalAssets() private view returns (uint total) {
 uint lpBal = REWARD.balanceOf(address(this));
 total = lpBal.mul(CURVE_POOL.get_virtual_price()) / (MUL * 1e18);
 total = total.add(token.balanceOf(address(this)));
 }
 function totalAssets() external view override returns (uint) {
 return _totalAssets();
 }
 function _deposit() private {
 uint bal = token.balanceOf(address(this));
 if (bal > 0) {
 uint[4] memory amounts;
 amounts[INDEX] = bal;
 uint pricePerShare = CURVE_POOL.get_virtual_price();
 uint shares = bal.mul(MUL).mul(1e18).div(pricePerShare);
 uint min = shares.mul(SLIP_MAX - slip) / SLIP_MAX;
 ZAP.add_liquidity(amounts, min);
 }
 uint lpBal = CURVE_LP.balanceOf(address(this));
 if (lpBal > 0) {
 require(BOOSTER.deposit(PID, lpBal, true), "deposit failed");
 }
 }
 function deposit(uint _amount, uint _min) external override onlyAuthorized {
 require(_amount > 0, "deposit = 0");
 uint borrowed = fundManager.borrow(_amount);
 require(borrowed >= _min, "borrowed < min");
 _deposit();
 emit Deposit(_amount, borrowed);
 }
 function _calcSharesToWithdraw( uint _amount, uint _total, uint _totalShares ) private pure returns (uint) {
 if (_total > 0) {
 if (_amount >= _total) {
 return _totalShares;
 }
 return _amount.mul(_totalShares) / _total;
 }
 return 0;
 }
 function _withdraw(uint _amount) private returns (uint) {
 uint bal = token.balanceOf(address(this));
 if (_amount <= bal) {
 return _amount;
 }
 uint total = _totalAssets();
 if (_amount >= total) {
 _amount = total;
 }
 uint need = _amount - bal;
 uint totalShares = REWARD.balanceOf(address(this));
 uint shares = _calcSharesToWithdraw(need, total - bal, totalShares);
 if (shares > 0) {
 require(REWARD.withdrawAndUnwrap(shares, false), "reward withdraw failed");
 }
 uint lpBal = CURVE_LP.balanceOf(address(this));
 if (shares > lpBal) {
 shares = lpBal;
 }
 if (shares > 0) {
 uint min = need.mul(SLIP_MAX - slip) / SLIP_MAX;
 ZAP.remove_liquidity_one_coin(shares, int128(INDEX), min);
 }
 uint balAfter = token.balanceOf(address(this));
 if (balAfter < _amount) {
 return balAfter;
 }
 if (_amount >= total) {
 return balAfter;
 }
 return _amount;
 }
 function withdraw(uint _amount) external override onlyFundManager returns (uint loss) {
 require(_amount > 0, "withdraw = 0");
 uint available = _withdraw(_amount);
 uint debt = fundManager.getDebt(address(this));
 uint total = _totalAssets();
 if (debt > total) {
 loss = debt - total;
 }
 if (available > 0) {
 token.safeTransfer(msg.sender, available);
 }
 emit Withdraw(_amount, available, loss);
 }
 function repay(uint _amount, uint _min) external override onlyAuthorized {
 require(_amount > 0, "repay = 0");
 uint available = _withdraw(_amount);
 uint repaid = fundManager.repay(available);
 require(repaid >= _min, "repaid < min");
 emit Repay(_amount, repaid);
 }
 function _swap( address _dex, address _tokenIn, address _tokenOut, uint _amount ) private {
 address[] memory path = new address[](3);
 path[0] = _tokenIn;
 path[1] = WETH;
 path[2] = _tokenOut;
 UniswapV2Router(_dex).swapExactTokensForTokens( _amount, 1, path, address(this), block.timestamp );
 }
 function _claimRewards(uint _minProfit) private {
 uint diff = token.balanceOf(address(this));
 require( REWARD.getReward(address(this), shouldClaimExtras), "get reward failed" );
 for (uint i = 0; i < NUM_REWARDS; i++) {
 uint rewardBal = IERC20(REWARDS[i]).balanceOf(address(this));
 if (rewardBal > 0) {
 _swap(dex[i], REWARDS[i], address(token), rewardBal);
 }
 }
 diff = token.balanceOf(address(this)) - diff;
 require(diff >= _minProfit, "profit < min");
 if (diff > 0) {
 uint fee = diff.mul(perfFee) / PERF_FEE_MAX;
 if (fee > 0) {
 token.safeTransfer(treasury, fee);
 diff = diff.sub(fee);
 }
 }
 emit ClaimRewards(diff);
 }
 function claimRewards(uint _minProfit) external override onlyAuthorized {
 _claimRewards(_minProfit);
 }
 function _skim() private {
 uint total = _totalAssets();
 uint debt = fundManager.getDebt(address(this));
 require(total > debt, "total <= debt");
 uint profit = total - debt;
 profit = _withdraw(profit);
 emit Skim(total, debt, profit);
 }
 function skim() external override onlyAuthorized {
 _skim();
 }
 function _report(uint _minTotal, uint _maxTotal) private {
 uint total = _totalAssets();
 require(total >= _minTotal, "total < min");
 require(total <= _maxTotal, "total > max");
 uint gain = 0;
 uint loss = 0;
 uint free = 0;
 uint debt = fundManager.getDebt(address(this));
 if (total > debt) {
 gain = total - debt;
 free = token.balanceOf(address(this));
 if (gain > free) {
 gain = free;
 }
 }
 else {
 loss = debt - total;
 }
 if (gain > 0 || loss > 0) {
 fundManager.report(gain, loss);
 }
 emit Report(gain, loss, free, total, debt);
 }
 function report(uint _minTotal, uint _maxTotal) external override onlyAuthorized {
 _report(_minTotal, _maxTotal);
 }
 function harvest( uint _minProfit, uint _minTotal, uint _maxTotal ) external override onlyAuthorized {
 _claimRewards(_minProfit);
 _skim();
 _report(_minTotal, _maxTotal);
 }
 function migrate(address _strategy) external override onlyFundManager {
 Strategy strat = Strategy(_strategy);
 require(address(strat.token()) == address(token), "strategy token != token");
 require( address(strat.fundManager()) == address(fundManager), "strategy fund manager != fund manager" );
 if (claimRewardsOnMigrate) {
 _claimRewards(1);
 }
 uint bal = _withdraw(type(uint).max);
 token.safeApprove(_strategy, bal);
 strat.transferTokenFrom(address(this), bal);
 }
 function sweep(address _token) external override onlyAuthorized {
 for (uint i = 0; i < NUM_REWARDS; i++) {
 require(_token != REWARDS[i], "protected token");
 }
 IERC20(_token).safeTransfer(admin, IERC20(_token).balanceOf(address(this)));
 }
 }
 interface UniswapV2Router {
 function swapExactTokensForTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external returns (uint[] memory amounts);
 function swapExactTokensForETH( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external returns (uint[] memory amounts);
 }
 contract StrategyConvexUsdpUsdc is StrategyConvexUsdp {
 constructor(address _fundManager, address _treasury) StrategyConvexUsdp( 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, _fundManager, _treasury, 2 ) {
 }
 }
