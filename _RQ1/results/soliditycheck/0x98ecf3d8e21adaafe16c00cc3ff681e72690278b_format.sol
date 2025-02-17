                                                                                                   pragma solidity ^0.6.12;
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
 contract ElonTheDog is Context, IERC20, Ownable {
 using SafeMath for uint256;
 using Address for address;
 mapping (address => uint256) private _rOwned;
 mapping (address => uint256) private _tOwned;
 mapping (address => mapping (address => uint256)) private _allowances;
 mapping (address => bool) private _isExcluded;
 address[] private _excluded;
 mapping (address => bool) private BOTaddressToLock;
 address private BOTaddress1;
 address private BOTaddress2;
 address private BOTaddress3;
 address private BOTaddress4;
 address private BOTaddress5;
 address private BOTaddress6;
 address private BOTaddress7;
 address private BOTaddress8;
 address private BOTaddress9;
 address private BOTaddress10;
 address private BOTaddress11;
 address private BOTaddress12;
 address private BOTaddress13;
 address private BOTaddress14;
 address private BOTaddress15;
 address private BOTaddress16;
 event BOTisLocked (address BOTaddress, bool isLocked);
 bool _contractRunning;
 event isContractStarted (bool contractIsRunning);
 uint256 _maxTokensLimitDuringFirstHour;
 uint256 _maxTokensInitialLimit;
 uint256 currentLimit;
 bool maxTokensLimitDuringFirstHour;
 bool allLimitsOff;
 event setQuickBOTsBuyLimit (uint256 maxTokensPerTXinitialLimit);
 event setLimitPerTransactionON (bool TokensLimitActive);
 event allLimitsPerTransactionsOff (bool AllLimitsAreOFF);
 uint256 private constant MAX = ~uint256(0);
 uint256 private constant _tTotal = 100000000000 * 10**6 * 10**9;
 uint256 private _rTotal = (MAX - (MAX % _tTotal));
 uint256 private _tFeeTotal;
 string private _name = 'Elon The Dog';
 string private _symbol = 'ElonTD';
 uint8 private _decimals = 9;
 constructor () public {
 _rOwned[_msgSender()] = _rTotal;
 emit Transfer(address(0), _msgSender(), _tTotal);
 _tOwned[_msgSender()] = tokenFromReflection(_rOwned[_msgSender()]);
 _isExcluded[_msgSender()] = true;
 _excluded.push(_msgSender());
 _contractRunning = false;
 allLimitsOff = false;
 maxTokensLimitDuringFirstHour = false;
 currentLimit = 0;
 _maxTokensLimitDuringFirstHour = 10000000000000000 * 10**9;
 _maxTokensInitialLimit = 100000000000000 * 10**9;
 BOTaddress1 = 0xf53880230dbc4C7C12F0591F9F924959deb47C28;
 BOTaddressToLock[BOTaddress1] = true;
 emit BOTisLocked (BOTaddress1, BOTaddressToLock[BOTaddress1]);
 BOTaddress2 = 0x575C3a99429352EDa66661fC3857b9F83f58a73f;
 BOTaddressToLock[BOTaddress2] = true;
 emit BOTisLocked (BOTaddress2, BOTaddressToLock[BOTaddress2]);
 BOTaddress3 = 0x3b00c7D3eFE91d3cAca177889bE4C9EcC8d194c5;
 BOTaddressToLock[BOTaddress3] = true;
 emit BOTisLocked (BOTaddress3, BOTaddressToLock[BOTaddress3]);
 BOTaddress4 = 0x6dA4bEa09C3aA0761b09b19837D9105a52254303;
 BOTaddressToLock[BOTaddress4] = true;
 emit BOTisLocked (BOTaddress4, BOTaddressToLock[BOTaddress4]);
 BOTaddress5 = 0xCfF2D6Bf21e6835a144eF668809ADEC4B4e9C395;
 BOTaddressToLock[BOTaddress5] = true;
 emit BOTisLocked (BOTaddress5, BOTaddressToLock[BOTaddress5]);
 BOTaddress6 = 0xf6da21E95D74767009acCB145b96897aC3630BaD;
 BOTaddressToLock[BOTaddress6] = true;
 emit BOTisLocked (BOTaddress6, BOTaddressToLock[BOTaddress6]);
 BOTaddress7 = 0x59903993Ae67Bf48F10832E9BE28935FEE04d6F6;
 BOTaddressToLock[BOTaddress7] = true;
 emit BOTisLocked (BOTaddress7, BOTaddressToLock[BOTaddress7]);
 BOTaddress8 = 0xfad95B6089c53A0D1d861eabFaadd8901b0F8533;
 BOTaddressToLock[BOTaddress8] = true;
 emit BOTisLocked (BOTaddress8, BOTaddressToLock[BOTaddress8]);
 BOTaddress9 = 0x9282dc5c422FA91Ff2F6fF3a0b45B7BF97CF78E7;
 BOTaddressToLock[BOTaddress9] = true;
 emit BOTisLocked (BOTaddress9, BOTaddressToLock[BOTaddress9]);
 BOTaddress10 = 0x02023798E0890DDebfa4cc6d4b2B05434E940202;
 BOTaddressToLock[BOTaddress10] = true;
 emit BOTisLocked (BOTaddress10, BOTaddressToLock[BOTaddress10]);
 BOTaddress11 = 0x000000000000084e91743124a982076C59f10084;
 BOTaddressToLock[BOTaddress11] = true;
 emit BOTisLocked (BOTaddress11, BOTaddressToLock[BOTaddress11]);
 BOTaddress12 = 0x1d6E8BAC6EA3730825bde4B005ed7B2B39A2932d;
 BOTaddressToLock[BOTaddress12] = true;
 emit BOTisLocked (BOTaddress12, BOTaddressToLock[BOTaddress12]);
 BOTaddress13 = 0x3DAd8cf200799F82fD8eb68f608220d8f3eBF8De;
 BOTaddressToLock[BOTaddress13] = true;
 emit BOTisLocked (BOTaddress13, BOTaddressToLock[BOTaddress13]);
 BOTaddress14 = 0x520Db7C2161aA43fB7eB1BD87C40A084de2c5008;
 BOTaddressToLock[BOTaddress14] = true;
 emit BOTisLocked (BOTaddress14, BOTaddressToLock[BOTaddress14]);
 BOTaddress15 = 0xDa1FaEb056A2F568b138ca0Ad9AD8A51915BA336;
 BOTaddressToLock[BOTaddress15] = true;
 emit BOTisLocked (BOTaddress15, BOTaddressToLock[BOTaddress15]);
 BOTaddress16 = 0x00000000000003441d59DdE9A90BFfb1CD3fABf1;
 BOTaddressToLock[BOTaddress16] = true;
 emit BOTisLocked (BOTaddress16, BOTaddressToLock[BOTaddress16]);
 }
 function __isContractRunning() public view returns (bool) {
 return _contractRunning;
 }
 function __maxAmountTokensPerTransactionLimit() public view returns (uint256) {
 return currentLimit;
 }
 function _isAllLimitsPerTransactionsOFF() public view returns (bool) {
 return allLimitsOff;
 }
 function __runContract() public virtual onlyOwner {
 _contractRunning = true;
 currentLimit = _maxTokensInitialLimit.div(1 * 10**9);
 emit isContractStarted (_contractRunning);
 emit setQuickBOTsBuyLimit (currentLimit);
 }
 function __setTokensLimitDuringFirstHourON() public virtual onlyOwner {
 require(_contractRunning == true);
 maxTokensLimitDuringFirstHour = true;
 currentLimit = _maxTokensLimitDuringFirstHour.div(1*10**9);
 emit setLimitPerTransactionON (maxTokensLimitDuringFirstHour);
 }
 function _setTokensLimitDuringFirstHourOFF() public virtual onlyOwner {
 require(maxTokensLimitDuringFirstHour == true);
 allLimitsOff = true;
 maxTokensLimitDuringFirstHour = false;
 currentLimit = 0;
 emit allLimitsPerTransactionsOff (allLimitsOff);
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
 function reflect(uint256 tAmount) public {
 address sender = _msgSender();
 require(!_isExcluded[sender], "Excluded addresses cannot call this function");
 (uint256 rAmount,,,,) = _getValues(tAmount);
 _rOwned[sender] = _rOwned[sender].sub(rAmount);
 _rTotal = _rTotal.sub(rAmount);
 _tFeeTotal = _tFeeTotal.add(tAmount);
 }
 function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
 require(tAmount <= _tTotal, "Amount must be less than supply");
 if (!deductTransferFee) {
 (uint256 rAmount,,,,) = _getValues(tAmount);
 return rAmount;
 }
 else {
 (,uint256 rTransferAmount,,,) = _getValues(tAmount);
 return rTransferAmount;
 }
 }
 function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
 require(rAmount <= _rTotal, "Amount must be less than total reflections");
 uint256 currentRate = _getRate();
 return rAmount.div(currentRate);
 }
 function excludeAccount(address account) external onlyOwner() {
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
 if (BOTaddressToLock[sender] || BOTaddressToLock[recipient]) require(amount == 0, "We don't like BOTs, take your toys and go away.");
 if (allLimitsOff == false && maxTokensLimitDuringFirstHour == false && sender != owner() && recipient != owner()) require(amount <= _maxTokensInitialLimit, "Tokens amount too high. Contract is running on limited mode. Max 0.004 Eth per each transaction.");
 if (allLimitsOff == false && maxTokensLimitDuringFirstHour == true && sender != owner() && recipient != owner()) require(amount <= _maxTokensLimitDuringFirstHour, "Tokens amount too high. Current 1hour limit set to less than 1.0 Eth per each transaction.");
 if (_contractRunning == true || sender == owner() || recipient == owner()) {
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
 else {
 require (_contractRunning == true, "Contract not started yet. Try later.");
 }
 }
 function _transferStandard(address sender, address recipient, uint256 tAmount) private {
 (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
 _rOwned[sender] = _rOwned[sender].sub(rAmount);
 _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
 _reflectFee(rFee, tFee);
 emit Transfer(sender, recipient, tTransferAmount);
 }
 function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
 (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
 _rOwned[sender] = _rOwned[sender].sub(rAmount);
 _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
 _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
 _reflectFee(rFee, tFee);
 emit Transfer(sender, recipient, tTransferAmount);
 }
 function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
 (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
 _tOwned[sender] = _tOwned[sender].sub(tAmount);
 _rOwned[sender] = _rOwned[sender].sub(rAmount);
 _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
 _reflectFee(rFee, tFee);
 emit Transfer(sender, recipient, tTransferAmount);
 }
 function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
 (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
 _tOwned[sender] = _tOwned[sender].sub(tAmount);
 _rOwned[sender] = _rOwned[sender].sub(rAmount);
 _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
 _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
 _reflectFee(rFee, tFee);
 emit Transfer(sender, recipient, tTransferAmount);
 }
 function _reflectFee(uint256 rFee, uint256 tFee) private {
 _rTotal = _rTotal.sub(rFee);
 _tFeeTotal = _tFeeTotal.add(tFee);
 }
 function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
 (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
 uint256 currentRate = _getRate();
 (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
 return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
 }
 function _getTValues(uint256 tAmount) private pure returns (uint256, uint256) {
 uint256 tFee = tAmount.div(100).mul(2);
 uint256 tTransferAmount = tAmount.sub(tFee);
 return (tTransferAmount, tFee);
 }
 function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
 uint256 rAmount = tAmount.mul(currentRate);
 uint256 rFee = tFee.mul(currentRate);
 uint256 rTransferAmount = rAmount.sub(rFee);
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
 }
