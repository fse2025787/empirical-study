  pragma experimental ABIEncoderV2;
 pragma solidity =0.7.6;
 interface IERC20 {
 function totalSupply() external view returns (uint256 supply);
 function balanceOf(address _owner) external view returns (uint256 balance);
 function transfer(address _to, uint256 _value) external returns (bool success);
 function transferFrom( address _from, address _to, uint256 _value ) external returns (bool success);
 function approve(address _spender, uint256 _value) external returns (bool success);
 function allowance(address _owner, address _spender) external view returns (uint256 remaining);
 function decimals() external view returns (uint256 digits);
 event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 }
 abstract contract IWETH {
 function allowance(address, address) public virtual view returns (uint256);
 function balanceOf(address) public virtual view returns (uint256);
 function approve(address, uint256) public virtual;
 function transfer(address, uint256) public virtual returns (bool);
 function transferFrom( address, address, uint256 ) public virtual returns (bool);
 function deposit() public payable virtual;
 function withdraw(uint256) public virtual;
 }
 library Address {
 function isContract(address account) internal view returns (bool) {
 bytes32 codehash;
 bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
 assembly {
 codehash := extcodehash(account) }
 return (codehash != accountHash && codehash != 0x0);
 }
 function sendValue(address payable recipient, uint256 amount) internal {
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
 return _functionCallWithValue(target, data, 0, errorMessage);
 }
 function functionCallWithValue( address target, bytes memory data, uint256 value ) internal returns (bytes memory) {
 return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
 }
 function functionCallWithValue( address target, bytes memory data, uint256 value, string memory errorMessage ) internal returns (bytes memory) {
 require(address(this).balance >= value, "Address: insufficient balance for call");
 return _functionCallWithValue(target, data, value, errorMessage);
 }
 function _functionCallWithValue( address target, bytes memory data, uint256 weiValue, string memory errorMessage ) private returns (bytes memory) {
 require(isContract(target), "Address: call to non-contract");
 (bool success, bytes memory returndata) = target.call{
 value: weiValue}
 (data);
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
 library SafeMath {
 function add(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a + b;
 require(c >= a, "SafeMath: addition overflow");
 return c;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 return sub(a, b, "SafeMath: subtraction overflow");
 }
 function sub( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
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
 function div( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
 require(b > 0, errorMessage);
 uint256 c = a / b;
 return c;
 }
 function mod(uint256 a, uint256 b) internal pure returns (uint256) {
 return mod(a, b, "SafeMath: modulo by zero");
 }
 function mod( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
 require(b != 0, errorMessage);
 return a % b;
 }
 }
 library SafeERC20 {
 using SafeMath for uint256;
 using Address for address;
 function safeTransfer( IERC20 token, address to, uint256 value ) internal {
 _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
 }
 function safeTransferFrom( IERC20 token, address from, address to, uint256 value ) internal {
 _callOptionalReturn( token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value) );
 }
 function safeApprove( IERC20 token, address spender, uint256 value ) internal {
 _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
 _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
 }
 function safeIncreaseAllowance( IERC20 token, address spender, uint256 value ) internal {
 uint256 newAllowance = token.allowance(address(this), spender).add(value);
 _callOptionalReturn( token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance) );
 }
 function safeDecreaseAllowance( IERC20 token, address spender, uint256 value ) internal {
 uint256 newAllowance = token.allowance(address(this), spender).sub( value, "SafeERC20: decreased allowance below zero" );
 _callOptionalReturn( token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance) );
 }
 function _callOptionalReturn(IERC20 token, bytes memory data) private {
 bytes memory returndata = address(token).functionCall( data, "SafeERC20: low-level call failed" );
 if (returndata.length > 0) {
 require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
 }
 }
 }
 library TokenUtils {
 using SafeERC20 for IERC20;
 address public constant WETH_ADDR = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
 address public constant ETH_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
 function approveToken( address _tokenAddr, address _to, uint256 _amount ) internal {
 if (_tokenAddr == ETH_ADDR) return;
 if (IERC20(_tokenAddr).allowance(address(this), _to) < _amount) {
 IERC20(_tokenAddr).safeApprove(_to, _amount);
 }
 }
 function pullTokensIfNeeded( address _token, address _from, uint256 _amount ) internal returns (uint256) {
 if (_amount == type(uint256).max) {
 _amount = getBalance(_token, _from);
 }
 if (_from != address(0) && _from != address(this) && _token != ETH_ADDR && _amount != 0) {
 IERC20(_token).safeTransferFrom(_from, address(this), _amount);
 }
 return _amount;
 }
 function withdrawTokens( address _token, address _to, uint256 _amount ) internal returns (uint256) {
 if (_amount == type(uint256).max) {
 _amount = getBalance(_token, address(this));
 }
 if (_to != address(0) && _to != address(this) && _amount != 0) {
 if (_token != ETH_ADDR) {
 IERC20(_token).safeTransfer(_to, _amount);
 }
 else {
 payable(_to).transfer(_amount);
 }
 }
 return _amount;
 }
 function depositWeth(uint256 _amount) internal {
 IWETH(WETH_ADDR).deposit{
 value: _amount}
 ();
 }
 function withdrawWeth(uint256 _amount) internal {
 IWETH(WETH_ADDR).withdraw(_amount);
 }
 function getBalance(address _tokenAddr, address _acc) internal view returns (uint256) {
 if (_tokenAddr == ETH_ADDR) {
 return _acc.balance;
 }
 else {
 return IERC20(_tokenAddr).balanceOf(_acc);
 }
 }
 function getTokenDecimals(address _token) internal view returns (uint256) {
 if (_token == ETH_ADDR) return 18;
 return IERC20(_token).decimals();
 }
 }
 interface IExchangeV3 {
 function sell(address _srcAddr, address _destAddr, uint _srcAmount, bytes memory _additionalData) external returns (uint);
 function buy(address _srcAddr, address _destAddr, uint _destAmount, bytes memory _additionalData) external returns(uint);
 function getSellRate(address _srcAddr, address _destAddr, uint _srcAmount, bytes memory _additionalData) external returns (uint);
 function getBuyRate(address _srcAddr, address _destAddr, uint _srcAmount, bytes memory _additionalData) external returns (uint);
 }
 interface IUniswapV3SwapCallback {
 function uniswapV3SwapCallback( int256 amount0Delta, int256 amount1Delta, bytes calldata data ) external;
 }
 interface ISwapRouter is IUniswapV3SwapCallback {
 struct ExactInputSingleParams {
 address tokenIn;
 address tokenOut;
 uint24 fee;
 address recipient;
 uint256 deadline;
 uint256 amountIn;
 uint256 amountOutMinimum;
 uint160 sqrtPriceLimitX96;
 }
 function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
 struct ExactInputParams {
 bytes path;
 address recipient;
 uint256 deadline;
 uint256 amountIn;
 uint256 amountOutMinimum;
 }
 function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);
 struct ExactOutputSingleParams {
 address tokenIn;
 address tokenOut;
 uint24 fee;
 address recipient;
 uint256 deadline;
 uint256 amountOut;
 uint256 amountInMaximum;
 uint160 sqrtPriceLimitX96;
 }
 function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);
 struct ExactOutputParams {
 bytes path;
 address recipient;
 uint256 deadline;
 uint256 amountOut;
 uint256 amountInMaximum;
 }
 function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
 }
 interface IQuoter {
 function quoteExactInput(bytes memory path, uint256 amountIn) external returns (uint256 amountOut);
 function quoteExactInputSingle( address tokenIn, address tokenOut, uint24 fee, uint256 amountIn, uint160 sqrtPriceLimitX96 ) external returns (uint256 amountOut);
 function quoteExactOutput(bytes memory path, uint256 amountOut) external returns (uint256 amountIn);
 function quoteExactOutputSingle( address tokenIn, address tokenOut, uint24 fee, uint256 amountOut, uint160 sqrtPriceLimitX96 ) external returns (uint256 amountIn);
 }
 contract DSMath {
 function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
 require((z = x + y) >= x, "");
 }
 function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
 require((z = x - y) <= x, "");
 }
 function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
 require(y == 0 || (z = x * y) / y == x, "");
 }
 function div(uint256 x, uint256 y) internal pure returns (uint256 z) {
 return x / y;
 }
 function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
 return x <= y ? x : y;
 }
 function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
 return x >= y ? x : y;
 }
 function imin(int256 x, int256 y) internal pure returns (int256 z) {
 return x <= y ? x : y;
 }
 function imax(int256 x, int256 y) internal pure returns (int256 z) {
 return x >= y ? x : y;
 }
 uint256 constant WAD = 10**18;
 uint256 constant RAY = 10**27;
 function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
 z = add(mul(x, y), WAD / 2) / WAD;
 }
 function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
 z = add(mul(x, y), RAY / 2) / RAY;
 }
 function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
 z = add(mul(x, WAD), y / 2) / y;
 }
 function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
 z = add(mul(x, RAY), y / 2) / y;
 }
 function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {
 z = n % 2 != 0 ? x : RAY;
 for (n /= 2; n != 0; n /= 2) {
 x = rmul(x, x);
 if (n % 2 != 0) {
 z = rmul(z, x);
 }
 }
 }
 }
 abstract contract IDFSRegistry {
 function getAddr(bytes32 _id) public view virtual returns (address);
 function addNewContract( bytes32 _id, address _contractAddr, uint256 _waitPeriod ) public virtual;
 function startContractChange(bytes32 _id, address _newContractAddr) public virtual;
 function approveContractChange(bytes32 _id) public virtual;
 function cancelContractChange(bytes32 _id) public virtual;
 function changeWaitPeriod(bytes32 _id, uint256 _newWaitPeriod) public virtual;
 }
 contract AdminVault {
 address public owner;
 address public admin;
 constructor() {
 owner = msg.sender;
 admin = 0x25eFA336886C74eA8E282ac466BdCd0199f85BB9;
 }
 function changeOwner(address _owner) public {
 require(admin == msg.sender, "msg.sender not admin");
 owner = _owner;
 }
 function changeAdmin(address _admin) public {
 require(admin == msg.sender, "msg.sender not admin");
 admin = _admin;
 }
 }
 contract AdminAuth {
 using SafeERC20 for IERC20;
 address public constant ADMIN_VAULT_ADDR = 0xCCf3d848e08b94478Ed8f46fFead3008faF581fD;
 AdminVault public constant adminVault = AdminVault(ADMIN_VAULT_ADDR);
 modifier onlyOwner() {
 require(adminVault.owner() == msg.sender, "msg.sender not owner");
 _;
 }
 modifier onlyAdmin() {
 require(adminVault.admin() == msg.sender, "msg.sender not admin");
 _;
 }
 function withdrawStuckFunds(address _token, address _receiver, uint256 _amount) public onlyOwner {
 if (_token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
 payable(_receiver).transfer(_amount);
 }
 else {
 IERC20(_token).safeTransfer(_receiver, _amount);
 }
 }
 function kill() public onlyAdmin {
 selfdestruct(payable(msg.sender));
 }
 }
 contract UniV3WrapperV3 is DSMath, IExchangeV3, AdminAuth {
 using TokenUtils for address;
 using SafeERC20 for IERC20;
 address public constant KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
 ISwapRouter public constant router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
 IQuoter public constant quoter = IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
 function sell(address _srcAddr, address, uint _srcAmount, bytes calldata _additionalData) external override returns (uint) {
 IERC20(_srcAddr).safeApprove(address(router), _srcAmount);
 ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
 path: _additionalData, recipient: msg.sender, deadline: block.timestamp + 1, amountIn: _srcAmount, amountOutMinimum: 1 }
 );
 uint amountOut = router.exactInput(params);
 return amountOut;
 }
 function buy(address _srcAddr, address, uint _destAmount, bytes calldata _additionalData) external override returns(uint) {
 uint srcAmount = _srcAddr.getBalance(address(this));
 IERC20(_srcAddr).safeApprove(address(router), srcAmount);
 ISwapRouter.ExactOutputParams memory params = ISwapRouter.ExactOutputParams({
 path: _additionalData, recipient: msg.sender, deadline: block.timestamp + 1, amountOut: _destAmount, amountInMaximum: type(uint).max }
 );
 uint amountIn = router.exactOutput(params);
 sendLeftOver(_srcAddr);
 return amountIn;
 }
 function getSellRate(address, address, uint _srcAmount, bytes memory _additionalData) public override returns (uint) {
 uint amountOut = quoter.quoteExactInput(_additionalData, _srcAmount);
 return wdiv(amountOut, _srcAmount);
 }
 function getBuyRate(address, address, uint _destAmount, bytes memory _additionalData) public override returns (uint) {
 uint amountIn = quoter.quoteExactOutput(_additionalData, _destAmount);
 return wdiv(_destAmount, amountIn);
 }
 function sendLeftOver(address _srcAddr) internal {
 msg.sender.transfer(address(this).balance);
 if (_srcAddr != KYBER_ETH_ADDRESS) {
 IERC20(_srcAddr).safeTransfer(msg.sender, IERC20(_srcAddr).balanceOf(address(this)));
 }
 }
 receive() external payable {
 }
 }
