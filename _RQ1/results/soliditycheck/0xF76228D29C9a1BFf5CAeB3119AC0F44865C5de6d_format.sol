                           pragma solidity >=0.6.2;
 abstract contract Context {
 function _msgSender() internal view virtual returns (address payable) {
 return msg.sender;
 }
 function _msgData() internal view virtual returns (bytes memory) {
 this;
 return msg.data;
 }
 }
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
 contract Ownable is Context {
 address private _owner;
 address private _previousOwner;
 uint256 private _lockTime;
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
 function geUnlockTime() public view returns (uint256) {
 return _lockTime;
 }
 function lock(uint256 time) public virtual onlyOwner {
 _previousOwner = _owner;
 _owner = address(0);
 _lockTime = now + time;
 emit OwnershipTransferred(_owner, address(0));
 }
 function unlock() public virtual {
 require(_previousOwner == msg.sender, "You don't have permission to unlock");
 require(now > _lockTime , "Contract is locked until 7 days");
 emit OwnershipTransferred(_owner, _previousOwner);
 _owner = _previousOwner;
 }
 }
 contract eINF is Context, IERC20, Ownable {
 using SafeMath for uint256;
 using Address for address;
 mapping (address => uint256) private _rOwned;
 mapping (address => uint256) private _tOwned;
 mapping (address => mapping (address => uint256)) private _allowances;
 mapping (address => bool) private _isExcluded;
 address[] private _excluded;
 mapping (address => bool) private _isBlackListedBot;
 address[] private _blackListedBots;
 uint256 private constant MAX = ~uint256(0);
 uint256 private _tTotal = 100000000000 * 10**9;
 uint256 private _rTotal = (MAX - (MAX % _tTotal));
 uint256 private _tFeeTotal;
 uint256 private _tBurnTotal;
 string private _name = 'Ethereum Infinity';
 string private _symbol = 'eINF';
 uint8 private _decimals = 9;
 uint256 private _taxFee = 0;
 uint256 private _burnFee = 5;
 uint256 private _maxTxAmount = 100000000000e9;
 constructor () public {
 _rOwned[_msgSender()] = _rTotal;
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
 function totalSupply() public view override returns (uint256) {
 return _tTotal;
 }
 function balanceOf(address account) public view override returns (uint256) {
 if (_isExcluded[account]) return _tOwned[account];
 return tokenFromReflection(_rOwned[account]);
 }
 function transfer(address recipient, uint256 amount) public override returns (bool) {
 _transfer(_msgSender(), recipient, amount);
 return true;
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
 function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
 _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
 return true;
 }
 function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
 _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
 return true;
 }
 function isExcluded(address account) public view returns (bool) {
 return _isExcluded[account];
 }
 function totalFees() public view returns (uint256) {
 return _tFeeTotal;
 }
 function totalBurn() public view returns (uint256) {
 return _tBurnTotal;
 }
 function deliver(uint256 tAmount) public {
 address sender = _msgSender();
 require(!_isExcluded[sender], "Excluded addresses cannot call this function");
 (uint256 rAmount,,,,,) = _getValues(tAmount);
 _rOwned[sender] = _rOwned[sender].sub(rAmount);
 _rTotal = _rTotal.sub(rAmount);
 _tFeeTotal = _tFeeTotal.add(tAmount);
 }
 function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
 require(tAmount <= _tTotal, "Amount must be less than supply");
 if (!deductTransferFee) {
 (uint256 rAmount,,,,,) = _getValues(tAmount);
 return rAmount;
 }
 else {
 (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
 return rTransferAmount;
 }
 }
 function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
 require(rAmount <= _rTotal, "Amount must be less than total reflections");
 uint256 currentRate = _getRate();
 return rAmount.div(currentRate);
 }
 function excludeAccount(address account) external onlyOwner() {
 require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
 require(!_isExcluded[account], "Account is already excluded");
 if(_rOwned[account] > 0) {
 _tOwned[account] = tokenFromReflection(_rOwned[account]);
 }
 _isExcluded[account] = true;
 _excluded.push(account);
 }
 function includeAccount(address account) external onlyOwner() {
 require(_isExcluded[account], "Account is already excluded");
 for (uint256 i = 0; i < _excluded.length; i++) {
 if (_excluded[i] == account) {
 _excluded[i] = _excluded[_excluded.length - 1];
 _tOwned[account] = 0;
 _isExcluded[account] = false;
 _excluded.pop();
 break;
 }
 }
 }
 function addBotToBlackList(address account) external onlyOwner() {
 require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not blacklist Uniswap router.');
 require(!_isBlackListedBot[account], "Account is already blacklisted");
 _isBlackListedBot[account] = true;
 _blackListedBots.push(account);
 }
 function removeBotFromBlackList(address account) external onlyOwner() {
 require(_isBlackListedBot[account], "Account is not blacklisted");
 for (uint256 i = 0; i < _blackListedBots.length; i++) {
 if (_blackListedBots[i] == account) {
 _blackListedBots[i] = _blackListedBots[_blackListedBots.length - 1];
 _isBlackListedBot[account] = false;
 _blackListedBots.pop();
 break;
 }
 }
 }
 function _approve(address owner, address spender, uint256 amount) private {
 require(owner != address(0), "ERC20: approve from the zero address");
 require(spender != address(0), "ERC20: approve to the zero address");
 _allowances[owner][spender] = amount;
 emit Approval(owner, spender, amount);
 }
 function _transfer(address sender, address recipient, uint256 amount) private {
 require(sender != address(0), "ERC20: transfer from the zero address");
 require(recipient != address(0), "ERC20: transfer to the zero address");
 require(amount > 0, "Transfer amount must be greater than zero");
 require(!_isBlackListedBot[recipient], "You have no power here!");
 require(!_isBlackListedBot[msg.sender], "You have no power here!");
 require(!_isBlackListedBot[sender], "You have no power here!");
 if(sender != owner() && recipient != owner()) require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
 if (_isExcluded[sender] && !_isExcluded[recipient]) {
 _transferFromExcluded(sender, recipient, amount);
 }
 else if (!_isExcluded[sender] && _isExcluded[recipient]) {
 _transferToExcluded(sender, recipient, amount);
 }
 else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
 _transferStandard(sender, recipient, amount);
 }
 else if (_isExcluded[sender] && _isExcluded[recipient]) {
 _transferBothExcluded(sender, recipient, amount);
 }
 else {
 _transferStandard(sender, recipient, amount);
 }
 }
 function _transferStandard(address sender, address recipient, uint256 tAmount) private {
 uint256 currentRate = _getRate();
 (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tBurn) = _getValues(tAmount);
 uint256 rBurn = tBurn.mul(currentRate);
 _rOwned[sender] = _rOwned[sender].sub(rAmount);
 _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
 _reflectFee(rFee, rBurn, tFee, tBurn);
 emit Transfer(sender, recipient, tTransferAmount);
 }
 function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
 uint256 currentRate = _getRate();
 (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tBurn) = _getValues(tAmount);
 uint256 rBurn = tBurn.mul(currentRate);
 _rOwned[sender] = _rOwned[sender].sub(rAmount);
 _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
 _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
 _reflectFee(rFee, rBurn, tFee, tBurn);
 emit Transfer(sender, recipient, tTransferAmount);
 }
 function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
 uint256 currentRate = _getRate();
 (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tBurn) = _getValues(tAmount);
 uint256 rBurn = tBurn.mul(currentRate);
 _tOwned[sender] = _tOwned[sender].sub(tAmount);
 _rOwned[sender] = _rOwned[sender].sub(rAmount);
 _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
 _reflectFee(rFee, rBurn, tFee, tBurn);
 emit Transfer(sender, recipient, tTransferAmount);
 }
 function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
 uint256 currentRate = _getRate();
 (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tBurn) = _getValues(tAmount);
 uint256 rBurn = tBurn.mul(currentRate);
 _tOwned[sender] = _tOwned[sender].sub(tAmount);
 _rOwned[sender] = _rOwned[sender].sub(rAmount);
 _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
 _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
 _reflectFee(rFee, rBurn, tFee, tBurn);
 emit Transfer(sender, recipient, tTransferAmount);
 }
 function _reflectFee(uint256 rFee, uint256 rBurn, uint256 tFee, uint256 tBurn) private {
 _rTotal = _rTotal.sub(rFee).sub(rBurn);
 _tFeeTotal = _tFeeTotal.add(tFee);
 _tBurnTotal = _tBurnTotal.add(tBurn);
 _tTotal = _tTotal.sub(tBurn);
 }
 function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
 (uint256 tTransferAmount, uint256 tFee, uint256 tBurn) = _getTValues(tAmount, _taxFee, _burnFee);
 uint256 currentRate = _getRate();
 (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tBurn, currentRate);
 return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tBurn);
 }
 function _getTValues(uint256 tAmount, uint256 taxFee, uint256 burnFee) private pure returns (uint256, uint256, uint256) {
 uint256 tFee = tAmount.mul(taxFee).div(100);
 uint256 tBurn = tAmount.mul(burnFee).div(100);
 uint256 tTransferAmount = tAmount.sub(tFee).sub(tBurn);
 return (tTransferAmount, tFee, tBurn);
 }
 function _getRValues(uint256 tAmount, uint256 tFee, uint256 tBurn, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
 uint256 rAmount = tAmount.mul(currentRate);
 uint256 rFee = tFee.mul(currentRate);
 uint256 rBurn = tBurn.mul(currentRate);
 uint256 rTransferAmount = rAmount.sub(rFee).sub(rBurn);
 return (rAmount, rTransferAmount, rFee);
 }
 function _getRate() private view returns(uint256) {
 (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
 return rSupply.div(tSupply);
 }
 function _getCurrentSupply() private view returns(uint256, uint256) {
 uint256 rSupply = _rTotal;
 uint256 tSupply = _tTotal;
 for (uint256 i = 0; i < _excluded.length; i++) {
 if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
 rSupply = rSupply.sub(_rOwned[_excluded[i]]);
 tSupply = tSupply.sub(_tOwned[_excluded[i]]);
 }
 if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
 return (rSupply, tSupply);
 }
 function _getTaxFee() private view returns(uint256) {
 return _taxFee;
 }
 function _getMaxTxAmount() private view returns(uint256) {
 return _maxTxAmount;
 }
 function _setTaxFee(uint256 taxFee) external onlyOwner() {
 require(taxFee >= _taxFee && taxFee <= 10, 'taxFee can only be increased and max is 10');
 _taxFee = taxFee;
 }
 function _setBurnFee(uint256 burnFee) external onlyOwner() {
 require(burnFee >= _burnFee && burnFee <= 10, 'burnFee can only be increased and max is 10');
 _burnFee = burnFee;
 }
 function _setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
 require(maxTxAmount >= 100000000000e9 , 'maxTxAmount should be greater than 100000000000e9');
 _maxTxAmount = maxTxAmount;
 }
 }
