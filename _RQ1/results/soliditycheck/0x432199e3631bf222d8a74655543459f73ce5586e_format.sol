            pragma solidity >=0.6.0 <0.8.0;
 library Math {
 function max(uint256 a, uint256 b) internal pure returns (uint256) {
 return a >= b ? a : b;
 }
 function min(uint256 a, uint256 b) internal pure returns (uint256) {
 return a < b ? a : b;
 }
 function average(uint256 a, uint256 b) internal pure returns (uint256) {
 return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
 }
 }
 pragma solidity >=0.6.0 <0.8.0;
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
 pragma solidity >=0.6.2 <0.8.0;
 library Address {
 function isContract(address account) internal view returns (bool) {
 uint256 size;
 assembly {
 size := extcodesize(account) }
 return size > 0;
 }
 function sendValue(address payable recipient, uint256 amount) internal {
 require(address(this).balance >= amount, "Address: insufficient balance");
 (bool success, ) = recipient.call{
 value: amount }
 ("");
 require(success, "Address: unable to send value, recipient may have reverted");
 }
 function functionCall(address target, bytes memory data) internal returns (bytes memory) {
 return functionCall(target, data, "Address: low-level call failed");
 }
 function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
 return functionCallWithValue(target, data, 0, errorMessage);
 }
 function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
 return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
 }
 function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
 require(address(this).balance >= value, "Address: insufficient balance for call");
 require(isContract(target), "Address: call to non-contract");
 (bool success, bytes memory returndata) = target.call{
 value: value }
 (data);
 return _verifyCallResult(success, returndata, errorMessage);
 }
 function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
 return functionStaticCall(target, data, "Address: low-level static call failed");
 }
 function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
 require(isContract(target), "Address: static call to non-contract");
 (bool success, bytes memory returndata) = target.staticcall(data);
 return _verifyCallResult(success, returndata, errorMessage);
 }
 function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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
 pragma solidity >=0.6.0 <0.8.0;
 library SafeERC20 {
 using SafeMath for uint256;
 using Address for address;
 function safeTransfer(IERC20 token, address to, uint256 value) internal {
 _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
 }
 function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
 _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
 }
 function safeApprove(IERC20 token, address spender, uint256 value) internal {
 require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance" );
 _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
 }
 function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
 uint256 newAllowance = token.allowance(address(this), spender).add(value);
 _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
 }
 function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
 uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
 _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
 }
 function _callOptionalReturn(IERC20 token, bytes memory data) private {
 bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
 if (returndata.length > 0) {
 require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
 }
 }
 }
 pragma solidity >0.7.0;
 interface ILendingPool {
 function deposit( address asset, uint256 amount, address onBehalfOf, uint16 referralCode ) external;
 function withdraw( address asset, uint256 amount, address to ) external returns (uint256);
 function borrow( address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf ) external;
 function repay( address asset, uint256 amount, uint256 rateMode, address onBehalfOf ) external returns (uint256);
 function getReserveNormalizedIncome(address asset) external view returns (uint256);
 }
 contract Impl_WETH_AaveV2 {
 using SafeERC20 for IERC20;
 using Address for address;
 using SafeMath for uint256;
 address constant token = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
 address constant lendingpool = address(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
 address constant atoken = address(0x030bA81f1c18d280636F32af80b9AAd02Cf0854e);
 function dohardwork(bytes memory _data) public {
 }
 function deposit(uint256 _ne18) public {
 uint256 _amount = IERC20(token).balanceOf(address(this));
 _amount = _amount.mul(_ne18).div(1e18);
 if (_amount == 0) {
 return;
 }
 IERC20(token).safeApprove(lendingpool, 0);
 IERC20(token).safeApprove(lendingpool, _amount);
 ILendingPool(lendingpool).deposit(token, _amount, address(this), 0);
 }
 function withdraw(uint256 _ne18) public {
 uint256 _amount = IERC20(atoken).balanceOf(address(this));
 _amount = _amount.mul(_ne18).div(1e18);
 if (_amount == 0) {
 return;
 }
 ILendingPool(lendingpool).withdraw(token, _amount, address(this));
 }
 function deposited() public view returns (uint256) {
 return IERC20(atoken).balanceOf(address(this));
 }
 }
