         pragma solidity >=0.6.0 <0.8.0;
 abstract contract Context {
 function _msgSender() internal view virtual returns (address payable) {
 return msg.sender;
 }
 function _msgData() internal view virtual returns (bytes memory) {
 this;
 return msg.data;
 }
 }
 pragma solidity ^0.7.0;
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
 pragma solidity ^0.7.0;
 abstract contract Ownable is Context {
 address private _owner;
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 constructor () {
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
 interface IUniswapV2Router01 {
 function factory() external pure returns (address);
 function WETH() external pure returns (address);
 function addLiquidity( address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline ) external returns ( uint256 amountA, uint256 amountB, uint256 liquidity );
 function addLiquidityETH( address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline ) external payable returns ( uint256 amountToken, uint256 amountETH, uint256 liquidity );
 function removeLiquidity( address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline ) external returns (uint256 amountA, uint256 amountB);
 function removeLiquidityETH( address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline ) external returns (uint256 amountToken, uint256 amountETH);
 function removeLiquidityWithPermit( address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint256 amountA, uint256 amountB);
 function removeLiquidityETHWithPermit( address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint256 amountToken, uint256 amountETH);
 function swapExactTokensForTokens( uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external returns (uint256[] memory amounts);
 function swapTokensForExactTokens( uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline ) external returns (uint256[] memory amounts);
 function swapExactETHForTokens( uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external payable returns (uint256[] memory amounts);
 function swapTokensForExactETH( uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline ) external returns (uint256[] memory amounts);
 function swapExactTokensForETH( uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external returns (uint256[] memory amounts);
 function swapETHForExactTokens( uint256 amountOut, address[] calldata path, address to, uint256 deadline ) external payable returns (uint256[] memory amounts);
 function quote( uint256 amountA, uint256 reserveA, uint256 reserveB ) external pure returns (uint256 amountB);
 function getAmountOut( uint256 amountIn, uint256 reserveIn, uint256 reserveOut ) external pure returns (uint256 amountOut);
 function getAmountIn( uint256 amountOut, uint256 reserveIn, uint256 reserveOut ) external pure returns (uint256 amountIn);
 function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
 function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
 }
 pragma solidity 0.7.6;
 contract XKawa is Context, IERC20, Ownable {
 using SafeMath for uint256;
 using Address for address;
 mapping(address => uint256) private _rOwned;
 mapping(address => uint256) private _tOwned;
 mapping(address => mapping(address => uint256)) private _allowances;
 mapping(address => bool) private _isExcludedFromFee;
 mapping(address => bool) private _isExcluded;
 address[] private _excluded;
 uint256 private constant MAX = ~uint256(0);
 uint256 private _tTotal = 500000000 * 10**18;
 uint256 private _rTotal = (MAX - (MAX % _tTotal));
 uint256 private _tFeeTotal;
 string private _name = 'xKAWA';
 string private _symbol = 'xKAWA';
 uint8 private _decimals = 18;
 address public devAddress = address(0x93837577c98E01CFde883c23F64a0f608A70B90F);
 uint256 public devFee = 4;
 uint256 public _taxFee = 4;
 uint256 private _previousTaxFee = _taxFee;
 uint256 public _liquidityFee = 0;
 uint256 private _previousLiquidityFee = _liquidityFee;
 IUniswapV2Router02 public uniswapV2Router;
 address public uniswapV2Pair;
 bool inSwapAndLiquify;
 bool public swapAndLiquifyEnabled = true;
 bool public limitTransferAmount = true;
 uint256 public maxTxAmount = 500000 * 10**18;
 uint256 public maxWalletAmount = 2500000 * 10**18;
 event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
 event SwapAndLiquifyEnabledUpdated(bool enabled);
 event SwapAndLiquify( uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity );
 modifier lockTheSwap() {
 inSwapAndLiquify = true;
 _;
 inSwapAndLiquify = false;
 }
 constructor() public {
 _rOwned[_msgSender()] = _rTotal;
 IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02( 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D );
 uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair( address(this), _uniswapV2Router.WETH() );
 uniswapV2Router = _uniswapV2Router;
 _isExcludedFromFee[owner()] = true;
 _isExcludedFromFee[address(this)] = true;
 _isExcludedFromFee[devAddress] = true;
 _isExcluded[owner()] = true;
 _isExcluded[address(this)] = true;
 _isExcluded[devAddress] = true;
 _isExcluded[uniswapV2Pair] = true;
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
 function allowance(address _owner, address spender) public view override returns (uint256) {
 return _allowances[_owner][spender];
 }
 function approve(address spender, uint256 amount) public override returns (bool) {
 _approve(_msgSender(), spender, amount);
 return true;
 }
 function transferFrom( address sender, address recipient, uint256 amount ) public override returns (bool) {
 _transfer(sender, recipient, amount);
 _approve( sender, _msgSender(), _allowances[sender][_msgSender()].sub( amount, 'ERC20: transfer amount exceeds allowance' ) );
 return true;
 }
 function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
 _approve( _msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue) );
 return true;
 }
 function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
 _approve( _msgSender(), spender, _allowances[_msgSender()][spender].sub( subtractedValue, 'ERC20: decreased allowance below zero' ) );
 return true;
 }
 function isExcludedFromReward(address account) public view returns (bool) {
 return _isExcluded[account];
 }
 function totalFees() public view returns (uint256) {
 return _tFeeTotal;
 }
 function deliver(uint256 tAmount) public {
 address sender = _msgSender();
 require( !_isExcluded[sender], 'Excluded addresses cannot call this function' );
 (uint256 rAmount, , , , , ) = _getValues(tAmount);
 _rOwned[sender] = _rOwned[sender].sub(rAmount);
 _rTotal = _rTotal.sub(rAmount);
 _tFeeTotal = _tFeeTotal.add(tAmount);
 }
 function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns (uint256) {
 require(tAmount <= _tTotal, 'Amount must be less than supply');
 if (!deductTransferFee) {
 (uint256 rAmount, , , , , ) = _getValues(tAmount);
 return rAmount;
 }
 else {
 (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
 return rTransferAmount;
 }
 }
 function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
 require(rAmount <= _rTotal, 'Amount must be less than total reflections');
 uint256 currentRate = _getRate();
 return rAmount.div(currentRate);
 }
 function excludeFromReward(address account) public onlyOwner {
 require(!_isExcluded[account], 'Account is already excluded');
 if (_rOwned[account] > 0) {
 _tOwned[account] = tokenFromReflection(_rOwned[account]);
 }
 _isExcluded[account] = true;
 _excluded.push(account);
 }
 function includeInReward(address account) external onlyOwner {
 require(_isExcluded[account], 'Account is already excluded');
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
 function updateLimitTransferAmount(bool _limit) external onlyOwner {
 limitTransferAmount = _limit;
 }
 function _transferBothExcluded( address sender, address recipient, uint256 tAmount ) private {
 ( uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity ) = _getValues(tAmount);
 _tOwned[sender] = _tOwned[sender].sub(tAmount);
 _rOwned[sender] = _rOwned[sender].sub(rAmount);
 _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
 _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
 _takeLiquidity(tLiquidity);
 _reflectFee(rFee, tFee);
 emit Transfer(sender, recipient, tTransferAmount);
 }
 function excludeFromFee(address account) public onlyOwner {
 _isExcludedFromFee[account] = true;
 }
 function includeInFee(address account) public onlyOwner {
 _isExcludedFromFee[account] = false;
 }
 function setDevFeePercent(uint256 fee) external onlyOwner {
 devFee = fee;
 }
 function setDevAddress(address account) external onlyOwner {
 devAddress = account;
 }
 function setTaxFeePercent(uint256 taxFee) external onlyOwner {
 _taxFee = taxFee;
 }
 function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
 _liquidityFee = liquidityFee;
 }
 function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
 swapAndLiquifyEnabled = _enabled;
 emit SwapAndLiquifyEnabledUpdated(_enabled);
 }
 receive() external payable {
 }
 function _reflectFee(uint256 rFee, uint256 tFee) private {
 _rTotal = _rTotal.sub(rFee);
 _tFeeTotal = _tFeeTotal.add(tFee);
 }
 function _getValues(uint256 tAmount) private view returns ( uint256, uint256, uint256, uint256, uint256, uint256 ) {
 (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues( tAmount );
 (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues( tAmount, tFee, tLiquidity, _getRate() );
 return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
 }
 function _getTValues(uint256 tAmount) private view returns ( uint256, uint256, uint256 ) {
 uint256 tFee = calculateTaxFee(tAmount);
 uint256 tLiquidity = calculateLiquidityFee(tAmount);
 uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
 return (tTransferAmount, tFee, tLiquidity);
 }
 function _getRValues( uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate ) private pure returns ( uint256, uint256, uint256 ) {
 uint256 rAmount = tAmount.mul(currentRate);
 uint256 rFee = tFee.mul(currentRate);
 uint256 rLiquidity = tLiquidity.mul(currentRate);
 uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
 return (rAmount, rTransferAmount, rFee);
 }
 function _getRate() private view returns (uint256) {
 (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
 return rSupply.div(tSupply);
 }
 function _getCurrentSupply() private view returns (uint256, uint256) {
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
 function _takeLiquidity(uint256 tLiquidity) private {
 uint256 currentRate = _getRate();
 uint256 rLiquidity = tLiquidity.mul(currentRate);
 _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
 if (_isExcluded[address(this)]) _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
 }
 function calculateTaxFee(uint256 _amount) private view returns (uint256) {
 return _amount.mul(_taxFee).div(10**2);
 }
 function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
 return _amount.mul(_liquidityFee).div(10**2);
 }
 function removeAllFee() private {
 if (_taxFee == 0 && _liquidityFee == 0) return;
 _previousTaxFee = _taxFee;
 _previousLiquidityFee = _liquidityFee;
 _taxFee = 0;
 _liquidityFee = 0;
 }
 function restoreAllFee() private {
 _taxFee = _previousTaxFee;
 _liquidityFee = _previousLiquidityFee;
 }
 function isExcludedFromFee(address account) public view returns (bool) {
 return _isExcludedFromFee[account];
 }
 function _approve( address _owner, address spender, uint256 amount ) private {
 require(_owner != address(0), 'ERC20: approve from the zero address');
 require(spender != address(0), 'ERC20: approve to the zero address');
 _allowances[_owner][spender] = amount;
 emit Approval(_owner, spender, amount);
 }
 function _transfer( address from, address to, uint256 amount ) private {
 require(from != address(0), 'ERC20: transfer from the zero address');
 require(to != address(0), 'ERC20: transfer to the zero address');
 require(amount > 0, 'Transfer amount must be greater than zero');
 if ( limitTransferAmount && !isExcludedFromFee(to) && !isExcludedFromFee(from) ) {
 uint256 tokenBalance = balanceOf(to);
 require(amount <= maxTxAmount, 'Transfer amount exceeds the max amount');
 require( amount.add(tokenBalance) <= maxWalletAmount, 'Wallet amount exceeds the max amount' );
 }
 uint256 contractTokenBalance = balanceOf(address(this));
 if ( contractTokenBalance > 0 && !inSwapAndLiquify && from != address(uniswapV2Router) && to == uniswapV2Pair && !isExcludedFromFee(from) ) {
 swapAndSendToDev(contractTokenBalance);
 }
 if ( !inSwapAndLiquify && (from == uniswapV2Pair || to == uniswapV2Pair) && !isExcludedFromFee(from) && !isExcludedFromFee(to) ) {
 uint256 devAmount = amount.mul(devFee).div(100);
 uint256 remainingAmount = amount.sub(devAmount);
 _tokenTransfer(from, address(this), devAmount, false);
 _tokenTransfer(from, to, remainingAmount, true);
 }
 else {
 _tokenTransfer(from, to, amount, false);
 }
 }
 function swapAndSendToDev(uint256 tokenAmount) private lockTheSwap {
 swapTokensForEth(tokenAmount);
 uint256 devAmountETH = address(this).balance;
 payable(devAddress).call{
 value: devAmountETH}
 ('');
 }
 function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
 uint256 half = contractTokenBalance.div(2);
 uint256 otherHalf = contractTokenBalance.sub(half);
 uint256 initialBalance = address(this).balance;
 swapTokensForEth(half);
 uint256 newBalance = address(this).balance.sub(initialBalance);
 addLiquidity(otherHalf, newBalance);
 emit SwapAndLiquify(half, newBalance, otherHalf);
 }
 function swapTokensForEth(uint256 tokenAmount) private {
 address[] memory path = new address[](2);
 path[0] = address(this);
 path[1] = uniswapV2Router.WETH();
 _approve(address(this), address(uniswapV2Router), tokenAmount);
 uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens( tokenAmount, 0, path, address(this), block.timestamp );
 }
 function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
 _approve(address(this), address(uniswapV2Router), tokenAmount);
 uniswapV2Router.addLiquidityETH{
 value: ethAmount}
 ( address(this), tokenAmount, 0, 0, owner(), block.timestamp );
 }
 function _tokenTransfer( address sender, address recipient, uint256 amount, bool takeFee ) private {
 if (!takeFee) removeAllFee();
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
 if (!takeFee) restoreAllFee();
 }
 function _transferStandard( address sender, address recipient, uint256 tAmount ) private {
 ( uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity ) = _getValues(tAmount);
 _rOwned[sender] = _rOwned[sender].sub(rAmount);
 _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
 _takeLiquidity(tLiquidity);
 _reflectFee(rFee, tFee);
 emit Transfer(sender, recipient, tTransferAmount);
 }
 function _transferToExcluded( address sender, address recipient, uint256 tAmount ) private {
 ( uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity ) = _getValues(tAmount);
 _rOwned[sender] = _rOwned[sender].sub(rAmount);
 _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
 _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
 _takeLiquidity(tLiquidity);
 _reflectFee(rFee, tFee);
 emit Transfer(sender, recipient, tTransferAmount);
 }
 function _transferFromExcluded( address sender, address recipient, uint256 tAmount ) private {
 ( uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity ) = _getValues(tAmount);
 _tOwned[sender] = _tOwned[sender].sub(tAmount);
 _rOwned[sender] = _rOwned[sender].sub(rAmount);
 _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
 _takeLiquidity(tLiquidity);
 _reflectFee(rFee, tFee);
 emit Transfer(sender, recipient, tTransferAmount);
 }
 }
 pragma solidity ^0.7.0;
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
 pragma solidity ^0.7.0;
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
 function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
 return functionDelegateCall(target, data, "Address: low-level delegate call failed");
 }
 function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
 require(isContract(target), "Address: delegate call to non-contract");
 (bool success, bytes memory returndata) = target.delegatecall(data);
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
 interface IUniswapV2Pair {
 event Approval(address indexed owner, address indexed spender, uint256 value);
 event Transfer(address indexed from, address indexed to, uint256 value);
 function name() external pure returns (string memory);
 function symbol() external pure returns (string memory);
 function decimals() external pure returns (uint8);
 function totalSupply() external view returns (uint256);
 function balanceOf(address owner) external view returns (uint256);
 function allowance(address owner, address spender) external view returns (uint256);
 function approve(address spender, uint256 value) external returns (bool);
 function transfer(address to, uint256 value) external returns (bool);
 function transferFrom( address from, address to, uint256 value ) external returns (bool);
 function DOMAIN_SEPARATOR() external view returns (bytes32);
 function PERMIT_TYPEHASH() external pure returns (bytes32);
 function nonces(address owner) external view returns (uint256);
 function permit( address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s ) external;
 event Mint(address indexed sender, uint256 amount0, uint256 amount1);
 event Burn( address indexed sender, uint256 amount0, uint256 amount1, address indexed to );
 event Swap( address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to );
 event Sync(uint112 reserve0, uint112 reserve1);
 function MINIMUM_LIQUIDITY() external pure returns (uint256);
 function factory() external view returns (address);
 function token0() external view returns (address);
 function token1() external view returns (address);
 function getReserves() external view returns ( uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast );
 function price0CumulativeLast() external view returns (uint256);
 function price1CumulativeLast() external view returns (uint256);
 function kLast() external view returns (uint256);
 function mint(address to) external returns (uint256 liquidity);
 function burn(address to) external returns (uint256 amount0, uint256 amount1);
 function swap( uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data ) external;
 function skim(address to) external;
 function sync() external;
 function initialize(address, address) external;
 }
 interface IUniswapV2Factory {
 event PairCreated( address indexed token0, address indexed token1, address pair, uint256 );
 function feeTo() external view returns (address);
 function feeToSetter() external view returns (address);
 function getPair(address tokenA, address tokenB) external view returns (address pair);
 function allPairs(uint256) external view returns (address pair);
 function allPairsLength() external view returns (uint256);
 function createPair(address tokenA, address tokenB) external returns (address pair);
 function setFeeTo(address) external;
 function setFeeToSetter(address) external;
 }
 interface IUniswapV2Router02 is IUniswapV2Router01 {
 function removeLiquidityETHSupportingFeeOnTransferTokens( address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline ) external returns (uint256 amountETH);
 function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens( address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint256 amountETH);
 function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external;
 function swapExactETHForTokensSupportingFeeOnTransferTokens( uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external payable;
 function swapExactTokensForETHSupportingFeeOnTransferTokens( uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external;
 }
