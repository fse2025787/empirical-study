 pragma experimental ABIEncoderV2;
 pragma solidity ^0.5.16;
 contract Initializable {
 bool private initialized;
 bool private initializing;
 modifier initializer() {
 require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");
 bool isTopLevelCall = !initializing;
 if (isTopLevelCall) {
 initializing = true;
 initialized = true;
 }
 _;
 if (isTopLevelCall) {
 initializing = false;
 }
 }
 function isConstructor() private view returns (bool) {
 address self = address(this);
 uint256 cs;
 assembly {
 cs := extcodesize(self) }
 return cs == 0;
 }
 uint256[50] private ______gap;
 }
 contract Ownable is Initializable {
 address payable public owner;
 address payable internal newOwnerCandidate;
 function checkAuth() private view {
 require(msg.sender == owner, "Permission denied");
 }
 modifier onlyOwner {
 checkAuth();
 _;
 }
 function initialize() public initializer {
 owner = msg.sender;
 }
 function initialize(address payable newOwner) public initializer {
 owner = newOwner;
 }
 function changeOwner(address payable newOwner) public onlyOwner {
 newOwnerCandidate = newOwner;
 }
 function acceptOwner() public {
 require(msg.sender == newOwnerCandidate);
 owner = newOwnerCandidate;
 }
 uint256[50] private ______gap;
 }
 contract Adminable is Initializable, Ownable {
 mapping(address => bool) public admins;
 function checkAuthAdmin() private view {
 require(msg.sender == owner || admins[msg.sender], "Permission denied");
 }
 modifier onlyOwnerOrAdmin {
 checkAuthAdmin();
 _;
 }
 function initialize() public initializer {
 Ownable.initialize();
 }
 function initialize(address payable newOwner) public initializer {
 Ownable.initialize(newOwner);
 }
 function setAdminPermission(address _admin, bool _status) public onlyOwner {
 admins[_admin] = _status;
 }
 uint256[50] private ______gap;
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
 return (codehash != 0x0 && codehash != accountHash);
 }
 function toPayable(address account) internal pure returns (address payable) {
 return address(uint160(account));
 }
 function sendValue(address payable recipient, uint256 amount) internal {
 require(address(this).balance >= amount, "Address: insufficient balance");
 (bool success, ) = recipient.call.value(amount)("");
 require(success, "Address: unable to send value, recipient may have reverted");
 }
 }
 interface IToken {
 function decimals() external view returns (uint);
 function allowance(address owner, address spender) external view returns (uint);
 function balanceOf(address account) external view returns (uint);
 function approve(address spender, uint value) external;
 function transfer(address to, uint value) external returns (bool);
 function transferFrom(address from, address to, uint value) external returns (bool);
 function deposit() external payable;
 function mint(address, uint256) external;
 function withdraw(uint amount) external;
 function totalSupply() view external returns (uint256);
 function burnFrom(address account, uint256 amount) external;
 function symbol() external view returns (string memory);
 }
 library SafeERC20 {
 using SafeMath for uint256;
 using Address for address;
 function safeTransfer(IToken token, address to, uint256 value) internal {
 callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
 }
 function safeTransferFrom(IToken token, address from, address to, uint256 value) internal {
 callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
 }
 function safeApprove(IToken token, address spender, uint256 value) internal {
 require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance" );
 callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
 }
 function safeIncreaseAllowance(IToken token, address spender, uint256 value) internal {
 uint256 newAllowance = token.allowance(address(this), spender).add(value);
 callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
 }
 function safeDecreaseAllowance(IToken token, address spender, uint256 value) internal {
 uint256 newAllowance = token.allowance(address(this), spender).sub(value);
 callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
 }
 function callOptionalReturn(IToken token, bytes memory data) private {
 require(address(token).isContract(), "SafeERC20: call to non-contract");
 (bool success, bytes memory returndata) = address(token).call(data);
 require(success, "SafeERC20: low-level call failed");
 if (returndata.length > 0) {
 require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
 }
 }
 }
 library UniversalERC20 {
 using SafeMath for uint256;
 using SafeERC20 for IToken;
 IToken private constant ZERO_ADDRESS = IToken(0x0000000000000000000000000000000000000000);
 IToken private constant ETH_ADDRESS = IToken(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
 function universalTransfer(IToken token, address to, uint256 amount) internal {
 universalTransfer(token, to, amount, false);
 }
 function universalSymbol(IToken token) internal view returns (string memory) {
 if (token == ETH_ADDRESS) return "ETH";
 return token.symbol();
 }
 function universalDecimals(IToken token) internal view returns (uint) {
 if (token == ETH_ADDRESS) return 18;
 return token.decimals();
 }
 function universalTransfer(IToken token, address to, uint256 amount, bool mayFail) internal returns(bool) {
 if (amount == 0) {
 return true;
 }
 if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
 if (mayFail) {
 return address(uint160(to)).send(amount);
 }
 else {
 address(uint160(to)).transfer(amount);
 return true;
 }
 }
 else {
 token.safeTransfer(to, amount);
 return true;
 }
 }
 function universalApprove(IToken token, address to, uint256 amount) internal {
 if (token != ZERO_ADDRESS && token != ETH_ADDRESS) {
 token.safeApprove(to, amount);
 }
 }
 function universalTransferFrom(IToken token, address from, address to, uint256 amount) internal {
 if (amount == 0) {
 return;
 }
 if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
 require(from == msg.sender && msg.value >= amount, "msg.value is zero");
 if (to != address(this)) {
 address(uint160(to)).transfer(amount);
 }
 if (msg.value > amount) {
 msg.sender.transfer(uint256(msg.value).sub(amount));
 }
 }
 else {
 token.safeTransferFrom(from, to, amount);
 }
 }
 function universalBalanceOf(IToken token, address who) internal view returns (uint256) {
 if (token == ZERO_ADDRESS || token == ETH_ADDRESS) {
 return who.balance;
 }
 else {
 return token.balanceOf(who);
 }
 }
 }
 contract RewardWallet is Initializable, Adminable {
 using UniversalERC20 for IToken;
 function initialize() public initializer {
 Adminable.initialize();
 }
 function initialize(address payable newOwner) public initializer {
 Adminable.initialize(newOwner);
 }
 function withdraw(address token, uint256 amount) public onlyOwnerOrAdmin {
 if (token == address(0x0)) {
 owner.transfer(amount);
 }
 else {
 IToken(token).universalTransfer(owner, amount);
 }
 }
 function withdrawAll(address[] memory tokens) public onlyOwnerOrAdmin {
 for(uint256 i = 0; i < tokens.length; i++) {
 withdraw(tokens[i], IToken(tokens[i]).universalBalanceOf(address(this)));
 }
 }
 function externalCall(address payable[] memory _to, bytes[] memory _data, uint256[] memory _ethAmount) public onlyOwnerOrAdmin payable {
 for(uint256 i = 0; i < _to.length; i++) {
 _cast(_to[i], _data[i], _ethAmount[i]);
 }
 }
 function _cast(address payable _to, bytes memory _data, uint256 _ethAmount) internal {
 bytes32 response;
 assembly {
 let succeeded := call(sub(gas, 5000), _to, _ethAmount, add(_data, 0x20), mload(_data), 0, 32) response := mload(0) switch iszero(succeeded) case 1 {
 revert(0, 0) }
 }
 }
 }
