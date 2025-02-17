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
 abstract contract Ownable is Context {
 address private _owner;
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 constructor () internal {
 address msgSender = _msgSender();
 _owner = msgSender;
 emit OwnershipTransferred(address(0), msgSender);
 }
 function owner() public view virtual returns (address) {
 return _owner;
 }
 modifier onlyOwner() {
 require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
 interface IUniswapV2Factory {
 function createPair(address tokenA, address tokenB) external returns (address pair);
 }
 interface IUniswapV2Router02 {
 function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
 function factory() external pure returns (address);
 function WETH() external pure returns (address);
 function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
 function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
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
 library EnumerableSet {
 struct Set {
 bytes32[] _values;
 mapping(bytes32 => uint256) _indexes;
 }
 function _add(Set storage set, bytes32 value) private returns (bool) {
 if (!_contains(set, value)) {
 set._values.push(value);
 set._indexes[value] = set._values.length;
 return true;
 }
 else {
 return false;
 }
 }
 function _remove(Set storage set, bytes32 value) private returns (bool) {
 uint256 valueIndex = set._indexes[value];
 if (valueIndex != 0) {
 uint256 toDeleteIndex = valueIndex - 1;
 uint256 lastIndex = set._values.length - 1;
 if (lastIndex != toDeleteIndex) {
 bytes32 lastvalue = set._values[lastIndex];
 set._values[toDeleteIndex] = lastvalue;
 set._indexes[lastvalue] = valueIndex;
 }
 set._values.pop();
 delete set._indexes[value];
 return true;
 }
 else {
 return false;
 }
 }
 function _contains(Set storage set, bytes32 value) private view returns (bool) {
 return set._indexes[value] != 0;
 }
 function _length(Set storage set) private view returns (uint256) {
 return set._values.length;
 }
 function _at(Set storage set, uint256 index) private view returns (bytes32) {
 return set._values[index];
 }
 function _values(Set storage set) private view returns (bytes32[] memory) {
 return set._values;
 }
 struct Bytes32Set {
 Set _inner;
 }
 function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
 return _add(set._inner, value);
 }
 function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
 return _remove(set._inner, value);
 }
 function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
 return _contains(set._inner, value);
 }
 function length(Bytes32Set storage set) internal view returns (uint256) {
 return _length(set._inner);
 }
 function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
 return _at(set._inner, index);
 }
 function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
 return _values(set._inner);
 }
 struct AddressSet {
 Set _inner;
 }
 function add(AddressSet storage set, address value) internal returns (bool) {
 return _add(set._inner, bytes32(uint256(uint160(value))));
 }
 function remove(AddressSet storage set, address value) internal returns (bool) {
 return _remove(set._inner, bytes32(uint256(uint160(value))));
 }
 function contains(AddressSet storage set, address value) internal view returns (bool) {
 return _contains(set._inner, bytes32(uint256(uint160(value))));
 }
 function length(AddressSet storage set) internal view returns (uint256) {
 return _length(set._inner);
 }
 function at(AddressSet storage set, uint256 index) internal view returns (address) {
 return address(uint160(uint256(_at(set._inner, index))));
 }
 function values(AddressSet storage set) internal view returns (address[] memory) {
 bytes32[] memory store = _values(set._inner);
 address[] memory result;
 assembly {
 result := store }
 return result;
 }
 struct UintSet {
 Set _inner;
 }
 function add(UintSet storage set, uint256 value) internal returns (bool) {
 return _add(set._inner, bytes32(value));
 }
 function remove(UintSet storage set, uint256 value) internal returns (bool) {
 return _remove(set._inner, bytes32(value));
 }
 function contains(UintSet storage set, uint256 value) internal view returns (bool) {
 return _contains(set._inner, bytes32(value));
 }
 function length(UintSet storage set) internal view returns (uint256) {
 return _length(set._inner);
 }
 function at(UintSet storage set, uint256 index) internal view returns (uint256) {
 return uint256(_at(set._inner, index));
 }
 function values(UintSet storage set) internal view returns (uint256[] memory) {
 bytes32[] memory store = _values(set._inner);
 uint256[] memory result;
 assembly {
 result := store }
 return result;
 }
 }
 abstract contract GShibaRNG is Ownable {
 using SafeMath for uint256;
 using EnumerableSet for EnumerableSet.AddressSet;
 address payable public platinumWinner;
 address payable public goldWinner;
 address payable public silverWinner;
 address payable public bronzeWinner;
 EnumerableSet.AddressSet platinumSet;
 EnumerableSet.AddressSet goldSet;
 EnumerableSet.AddressSet silverSet;
 EnumerableSet.AddressSet bronzeSet;
 EnumerableSet.AddressSet[] gamblingWallets;
 uint256 public platinumMinWeight = 2 * 10 ** 5;
 uint256 public goldMinWeight = 10 ** 5;
 uint256 public silverMinWeight = 5 * 10 ** 4;
 mapping(address => uint256) public gamblingWeights;
 mapping(address => uint256) public ethAmounts;
 mapping(address => bool) public excludedFromGambling;
 mapping(address => bool) public isEthAmountNegative;
 IUniswapV2Router02 public uniswapV2Router;
 uint256 public feeMin = 0.1 * 10 ** 18;
 uint256 public feeMax = 0.3 * 10 ** 18;
 uint256 internal lastTotalFee;
 uint256 public ethWeight = 10 ** 10;
 mapping(address => bool) isGoverner;
 address[] governers;
 event newWinnersSelected(uint256 timestamp, address platinumWinner, address goldWinner, address silverWinner, address bronzeWinner, uint256 platinumEthAmount, uint256 goldEthAmount, uint256 silverEthAmount, uint256 bronzeEthAmount, uint256 platinumGShibaAmount, uint256 goldGShibaAmount, uint256 silverGShibaAmount, uint256 bronzeGShibaAmount, uint256 lastTotalFee);
 modifier onlyGoverner() {
 require(isGoverner[_msgSender()], "Not governer");
 _;
 }
 constructor(address payable _initialWinner) public {
 platinumWinner = _initialWinner;
 goldWinner = _initialWinner;
 silverWinner = _initialWinner;
 bronzeWinner = _initialWinner;
 platinumSet.add(_initialWinner);
 goldSet.add(_initialWinner);
 silverSet.add(_initialWinner);
 bronzeSet.add(_initialWinner);
 gamblingWallets.push(platinumSet);
 gamblingWallets.push(goldSet);
 gamblingWallets.push(silverSet);
 gamblingWallets.push(bronzeSet);
 uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
 isGoverner[owner()] = true;
 governers.push(owner());
 }
 function checkTierFromWeight(uint256 weight) public view returns(uint256) {
 if (weight > platinumMinWeight) {
 return 0;
 }
 if (weight > goldMinWeight) {
 return 1;
 }
 if (weight > silverMinWeight) {
 return 2;
 }
 return 3;
 }
 function calcWeight(uint256 ethAmount, uint256 gShibaAmount) public view returns(uint256) {
 return ethAmount.div(10 ** 13) + gShibaAmount.div(10 ** 13).div(ethWeight);
 }
 function addNewWallet(address _account, uint256 tier) internal {
 gamblingWallets[tier].add(_account);
 }
 function removeWallet(address _account, uint256 tier) internal {
 gamblingWallets[tier].remove(_account);
 }
 function addWalletToGamblingList(address _account, uint256 _amount) internal {
 if (!excludedFromGambling[_account]) {
 address[] memory path = new address[](2);
 path[0] = uniswapV2Router.WETH();
 path[1] = address(this);
 uint256 ethAmount = uniswapV2Router.getAmountsIn(_amount, path)[0];
 uint256 oldWeight = gamblingWeights[_account];
 if (isEthAmountNegative[_account]) {
 if (ethAmount > ethAmounts[_account]) {
 ethAmounts[_account] = ethAmount - ethAmounts[_account];
 isEthAmountNegative[_account] = false;
 gamblingWeights[_account] = calcWeight(ethAmounts[_account], IERC20(address(this)).balanceOf(_account) + _amount);
 }
 else {
 ethAmounts[_account] = ethAmounts[_account] - ethAmount;
 gamblingWeights[_account] = 0;
 }
 }
 else {
 ethAmounts[_account] += ethAmount;
 gamblingWeights[_account] = calcWeight(ethAmounts[_account], IERC20(address(this)).balanceOf(_account) + _amount);
 }
 if (!isEthAmountNegative[_account]) {
 uint256 oldTier = checkTierFromWeight(oldWeight);
 uint256 newTier = checkTierFromWeight(gamblingWeights[_account]);
 if (oldTier != newTier) {
 removeWallet(_account, oldTier);
 }
 addNewWallet(_account, newTier);
 }
 }
 }
 function removeWalletFromGamblingList(address _account, uint256 _amount) internal {
 if (!excludedFromGambling[_account]) {
 address[] memory path = new address[](2);
 path[0] = uniswapV2Router.WETH();
 path[1] = address(this);
 uint256 ethAmount = uniswapV2Router.getAmountsIn(_amount, path)[0];
 uint256 oldWeight = gamblingWeights[_account];
 if (isEthAmountNegative[_account]) {
 ethAmounts[_account] += ethAmount;
 gamblingWeights[_account] = 0;
 }
 else if (ethAmounts[_account] >= ethAmount) {
 ethAmounts[_account] -= ethAmount;
 gamblingWeights[_account] = calcWeight(ethAmounts[_account], IERC20(address(this)).balanceOf(_account));
 }
 else {
 ethAmounts[_account] = ethAmount - ethAmounts[_account];
 isEthAmountNegative[_account] = true;
 gamblingWeights[_account] = 0;
 }
 uint256 oldTier = checkTierFromWeight(oldWeight);
 removeWallet(_account, oldTier);
 }
 }
 function rand(uint256 max) private view returns(uint256) {
 if (max == 1) {
 return 0;
 }
 uint256 seed = uint256(keccak256(abi.encodePacked( block.timestamp + block.difficulty + ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) + block.gaslimit + ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) + block.number )));
 return (seed - ((seed / (max - 1)) * (max - 1))) + 1;
 }
 function checkAndChangeGamblingWinner() internal {
 uint256 randFee = rand(feeMax - feeMin) + feeMin;
 if (lastTotalFee >= randFee) {
 uint256 platinumWinnerIndex = rand(gamblingWallets[0].length());
 uint256 goldWinnerIndex = rand(gamblingWallets[1].length());
 uint256 silverWinnerIndex = rand(gamblingWallets[2].length());
 uint256 bronzeWinnerIndex = rand(gamblingWallets[3].length());
 platinumWinner = payable(gamblingWallets[0].at(platinumWinnerIndex));
 goldWinner = payable(gamblingWallets[1].at(goldWinnerIndex));
 silverWinner = payable(gamblingWallets[2].at(silverWinnerIndex));
 bronzeWinner = payable(gamblingWallets[3].at(bronzeWinnerIndex));
 emit newWinnersSelected( block.timestamp, platinumWinner, goldWinner, silverWinner, bronzeWinner, ethAmounts[platinumWinner], ethAmounts[goldWinner], ethAmounts[silverWinner], ethAmounts[bronzeWinner], IERC20(address(this)).balanceOf(platinumWinner), IERC20(address(this)).balanceOf(goldWinner), IERC20(address(this)).balanceOf(silverWinner), IERC20(address(this)).balanceOf(bronzeWinner), lastTotalFee );
 }
 }
 function setEthWeight(uint256 _ethWeight) external onlyGoverner {
 ethWeight = _ethWeight;
 }
 function setTierWeights(uint256 _platinumMin, uint256 _goldMin, uint256 _silverMin) external onlyGoverner {
 require(_platinumMin > _goldMin && _goldMin > _silverMin, "Weights should be descending order");
 platinumMinWeight = _platinumMin;
 goldMinWeight = _goldMin;
 silverMinWeight = _silverMin;
 }
 function setFeeMinMax(uint256 _feeMin, uint256 _feeMax) external onlyGoverner {
 require(_feeMin < _feeMax, "feeMin should be smaller than feeMax");
 feeMin = _feeMin;
 feeMax = _feeMax;
 }
 function addGoverner(address _governer) public onlyGoverner {
 if (!isGoverner[_governer]) {
 isGoverner[_governer] = true;
 governers.push(_governer);
 }
 }
 function removeGoverner(address _governer) external onlyGoverner {
 if (isGoverner[_governer]) {
 isGoverner[_governer] = false;
 for (uint i = 0; i < governers.length; i ++) {
 if (governers[i] == _governer) {
 governers[i] = governers[governers.length - 1];
 governers.pop();
 break;
 }
 }
 }
 }
 function migrate(address _user, uint256 _gShibaAmount) external onlyGoverner returns(bool) {
 uint256 ethAmount = _gShibaAmount.div(10 ** 10);
 uint256 weight = calcWeight(ethAmount, _gShibaAmount);
 uint256 tier = checkTierFromWeight(weight);
 gamblingWallets[tier].add(_user);
 ethAmounts[_user] = ethAmount;
 gamblingWeights[_user] = weight;
 return true;
 }
 }
 contract GamblerShiba is IERC20, Ownable, GShibaRNG {
 using SafeMath for uint256;
 using Address for address;
 mapping (address => uint256) private _tOwned;
 mapping (address => mapping (address => uint256)) private _allowances;
 mapping (address => uint256) public timestamp;
 uint256 private eligibleRNG = block.timestamp;
 mapping (address => bool) private _isExcludedFromFee;
 mapping (address => bool) private _isBlackListedBot;
 uint256 private _tTotal = 1000000000000 * 10 ** 18;
 uint256 public _coolDown = 30 seconds;
 string private _name = 'Gambler Shiba';
 string private _symbol = 'GSHIBA';
 uint8 private _decimals = 18;
 uint256 public _devFee = 12;
 uint256 private _previousdevFee = _devFee;
 address payable private _feeWalletAddress;
 address public uniswapV2Pair;
 bool inSwap = false;
 bool public swapEnabled = true;
 bool public feeEnabled = true;
 bool public tradingEnabled = false;
 bool public cooldownEnabled = true;
 uint256 public _maxTxAmount = _tTotal / 400;
 uint256 private _numOfTokensToExchangeFordev = 5000000000000000;
 address public migrator;
 event SwapEnabledUpdated(bool enabled);
 modifier lockTheSwap {
 inSwap = true;
 _;
 inSwap = false;
 }
 constructor (address payable feeWalletAddress) GShibaRNG(feeWalletAddress) public {
 _feeWalletAddress = feeWalletAddress;
 _tOwned[_msgSender()] = _tTotal;
 uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()) .createPair(address(this), uniswapV2Router.WETH());
 _isExcludedFromFee[owner()] = true;
 _isExcludedFromFee[address(this)] = true;
 excludedFromGambling[address(this)] = true;
 excludedFromGambling[uniswapV2Pair] = true;
 excludedFromGambling[owner()] = true;
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
 return _tOwned[account];
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
 function isBlackListed(address account) public view returns (bool) {
 return _isBlackListedBot[account];
 }
 function setExcludeFromFee(address account, bool excluded) external onlyGoverner {
 _isExcludedFromFee[account] = excluded;
 }
 function addBotToBlackList(address account) external onlyOwner() {
 require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not blacklist Uniswap router.');
 require(!_isBlackListedBot[account], "Account is already blacklisted");
 _isBlackListedBot[account] = true;
 }
 function addBotsToBlackList(address[] memory bots) external onlyOwner() {
 for (uint i = 0; i < bots.length; i++) {
 _isBlackListedBot[bots[i]] = true;
 }
 }
 function removeBotFromBlackList(address account) external onlyOwner() {
 require(_isBlackListedBot[account], "Account is not blacklisted");
 _isBlackListedBot[account] = false;
 }
 function removeAllFee() private {
 if(_devFee == 0) return;
 _previousdevFee = _devFee;
 _devFee = 0;
 }
 function restoreAllFee() private {
 _devFee = _previousdevFee;
 }
 function isExcludedFromFee(address account) public view returns(bool) {
 return _isExcludedFromFee[account];
 }
 function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
 _maxTxAmount = _tTotal.mul(maxTxPercent).div( 10**2 );
 }
 function setMaxTxAmount(uint256 maxTx) external onlyOwner() {
 _maxTxAmount = maxTx;
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
 require(!_isBlackListedBot[recipient], "Go away");
 require(!_isBlackListedBot[sender], "Go away");
 if(sender != owner() && recipient != owner() && sender != migrator && recipient != migrator) {
 require(amount <= _maxTxAmount, "Transfer amount exceeds the max amount.");
 if (sender == uniswapV2Pair || recipient == uniswapV2Pair) {
 require(tradingEnabled, "Trading is not enabled");
 }
 }
 if(cooldownEnabled) {
 if (sender == uniswapV2Pair ) {
 timestamp[recipient] = block.timestamp.add(_coolDown);
 }
 if(sender != owner() && sender != uniswapV2Pair) {
 require(block.timestamp >= timestamp[sender], "Cooldown");
 }
 }
 if (sender == uniswapV2Pair) {
 if (recipient != owner() && feeEnabled) {
 addWalletToGamblingList(recipient, amount);
 }
 }
 uint256 contractTokenBalance = balanceOf(address(this));
 if (contractTokenBalance >= _maxTxAmount) {
 contractTokenBalance = _maxTxAmount;
 }
 bool overMinTokenBalance = contractTokenBalance >= _numOfTokensToExchangeFordev;
 if (!inSwap && swapEnabled && overMinTokenBalance && sender != uniswapV2Pair) {
 swapTokensForEth(contractTokenBalance);
 uint256 contractETHBalance = address(this).balance;
 if(contractETHBalance > 0) {
 sendETHTodev(address(this).balance);
 }
 }
 bool takeFee = true;
 if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
 takeFee = false;
 }
 _tokenTransfer(sender, recipient, amount, takeFee);
 }
 function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
 address[] memory path = new address[](2);
 path[0] = address(this);
 path[1] = uniswapV2Router.WETH();
 _approve(address(this), address(uniswapV2Router), tokenAmount);
 uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens( tokenAmount, 0, path, address(this), block.timestamp );
 }
 function sendETHTodev(uint256 amount) private {
 if (block.timestamp >= eligibleRNG) {
 checkAndChangeGamblingWinner();
 }
 uint256 winnerReward = amount.div(30);
 lastTotalFee += winnerReward;
 platinumWinner.transfer(winnerReward.mul(4));
 goldWinner.transfer(winnerReward.mul(3));
 silverWinner.transfer(winnerReward.mul(2));
 bronzeWinner.transfer(winnerReward.mul(1));
 _feeWalletAddress.transfer(amount.mul(2).div(3));
 }
 function manualSwap() external onlyGoverner {
 uint256 contractBalance = balanceOf(address(this));
 swapTokensForEth(contractBalance);
 }
 function manualSend() external onlyGoverner {
 uint256 contractETHBalance = address(this).balance;
 sendETHTodev(contractETHBalance);
 }
 function setSwapEnabled(bool enabled) external onlyOwner(){
 swapEnabled = enabled;
 emit SwapEnabledUpdated(enabled);
 }
 function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
 if(!takeFee) removeAllFee();
 _transferStandard(sender, recipient, amount);
 if(!takeFee) restoreAllFee();
 }
 function _transferStandard(address sender, address recipient, uint256 tAmount) private {
 uint256 tdev = tAmount.mul(_devFee).div(100);
 uint256 transferAmount = tAmount.sub(tdev);
 _tOwned[sender] = _tOwned[sender].sub(tAmount);
 _tOwned[recipient] = _tOwned[recipient].add(transferAmount);
 removeWalletFromGamblingList(sender, tAmount);
 _takedev(tdev);
 emit Transfer(sender, recipient, transferAmount);
 }
 function _takedev(uint256 tdev) private {
 _tOwned[address(this)] = _tOwned[address(this)].add(tdev);
 }
 receive() external payable {
 }
 function _getMaxTxAmount() private view returns(uint256) {
 return _maxTxAmount;
 }
 function _getETHBalance() public view returns(uint256 balance) {
 return address(this).balance;
 }
 function allowDex(bool _tradingEnabled) external onlyOwner() {
 tradingEnabled = _tradingEnabled;
 eligibleRNG = block.timestamp + 25 minutes;
 }
 function toggleCoolDown(bool _cooldownEnabled) external onlyOwner() {
 cooldownEnabled = _cooldownEnabled;
 }
 function toggleFeeEnabled(bool _feeEnabled) external onlyOwner() {
 feeEnabled = _feeEnabled;
 }
 function setMigrationContract(address _migrator) external onlyGoverner {
 excludedFromGambling[_migrator] = true;
 _isExcludedFromFee[_migrator] = true;
 addGoverner(_migrator);
 migrator = _migrator;
 }
 }
