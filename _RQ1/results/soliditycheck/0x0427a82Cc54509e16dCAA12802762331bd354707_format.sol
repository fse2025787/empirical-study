       pragma solidity 0.6.12;
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
 value: amount }
 ("");
 require(success, "Address: unable to send value, recipient may have reverted");
 }
 function functionCall(address target, bytes memory data) internal returns (bytes memory) {
 return functionCall(target, data, "Address: low-level call failed");
 }
 function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
 return _functionCallWithValue(target, data, 0, errorMessage);
 }
 function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
 return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
 }
 function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
 require(address(this).balance >= value, "Address: insufficient balance for call");
 return _functionCallWithValue(target, data, value, errorMessage);
 }
 function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
 require(isContract(target), "Address: call to non-contract");
 (bool success, bytes memory returndata) = target.call{
 value: weiValue }
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
 interface IRewardsDistributionRecipient {
 function notifyRewardAmount(address _rewardToken, uint256 reward) external;
 }
 contract RewardDistributorPermissioned {
 using SafeERC20 for IERC20;
 using SafeMath for uint;
 address public governance;
 mapping(address => bool) public distributableTokens;
 address[] public recipients;
 uint256[] public percentages;
 constructor() public {
 governance = msg.sender;
 }
 function setGovernance(address _governance) external onlyGov {
 governance = _governance;
 }
 function allowDistribution(address _token) external onlyGov {
 distributableTokens[_token] = true;
 }
 function disableDistribution(address _token) external onlyGov {
 distributableTokens[_token] = false;
 }
 function setAllocations( address[] calldata _recipients, uint256[] calldata _percentages ) external onlyGov {
 require(_recipients.length == _percentages.length, "length does not match");
 uint total = 0;
 for (uint i=0; i<_percentages.length; i++) {
 total = total + _percentages[i];
 }
 require(total == 100, "total percentage is not 100");
 recipients = _recipients;
 percentages = _percentages;
 }
 function rescue(address _rewardToken) external onlyGov {
 uint _balance = IERC20(_rewardToken).balanceOf(address(this));
 IERC20(_rewardToken).safeTransfer(governance, _balance);
 }
 function distributeRewards( IERC20 _token ) external {
 require(distributableTokens[address(_token)] == true, "Not allowed to distribute this token");
 uint total = _token.balanceOf(address(this));
 if (total == 0) {
 return;
 }
 for(uint i = 0; i < recipients.length; i++){
 uint256 amount = total.mul(percentages[i]).div(100);
 address recipient = recipients[i];
 _token.safeTransfer(recipient, amount);
 IRewardsDistributionRecipient(recipient).notifyRewardAmount(address(_token), amount);
 emit DistributedReward(recipient, address(_token), amount);
 }
 }
 modifier onlyGov() {
 require(msg.sender == governance, "!governance");
 _;
 }
 event DistributedReward(address recipient, address rewardToken, uint256 amount);
 }
