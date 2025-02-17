  pragma experimental ABIEncoderV2;
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
 pragma solidity ^0.7.3;
 library ZapLib {
 using SafeMath for uint256;
 using SafeERC20 for IERC20;
 struct ZapData {
 address curve;
 address base;
 address quote;
 uint256 zapAmount;
 uint256 curveBaseBal;
 uint8 curveBaseDecimals;
 uint256 curveQuoteBal;
 }
 struct DepositData {
 address curve;
 address base;
 address quote;
 uint256 curBaseAmount;
 uint256 curQuoteAmount;
 uint256 maxBaseAmount;
 uint256 maxQuoteAmount;
 }
 function zap( address _curve, uint256 _zapAmount, uint256 _deadline, uint256 _minLPAmount, bool isFromBase ) public {
 address base = ICurve(_curve).reserves(0);
 address quote = ICurve(_curve).reserves(1);
 uint256 swapAmount = calcSwapAmountForZap( _curve, base, quote, _zapAmount, isFromBase );
 if (isFromBase) {
 IERC20(base).safeTransferFrom( msg.sender, address(this), _zapAmount );
 IERC20(base).safeApprove(_curve, 0);
 IERC20(base).safeApprove(_curve, swapAmount);
 ICurve(_curve).originSwap(base, quote, swapAmount, 0, _deadline);
 }
 else {
 IERC20(quote).safeTransferFrom( msg.sender, address(this), _zapAmount );
 IERC20(quote).safeApprove(_curve, 0);
 IERC20(quote).safeApprove(_curve, swapAmount);
 ICurve(_curve).originSwap(quote, base, swapAmount, 0, _deadline);
 }
 uint256 baseAmount = IERC20(base).balanceOf(address(this));
 uint256 quoteAmount = IERC20(quote).balanceOf(address(this));
 (uint256 depositAmount, , ) = _calcDepositAmount( DepositData({
 curve: _curve, base: base, quote: quote, curBaseAmount: baseAmount, curQuoteAmount: quoteAmount, maxBaseAmount: baseAmount, maxQuoteAmount: quoteAmount }
 ) );
 IERC20(base).safeApprove(_curve, 0);
 IERC20(base).safeApprove(_curve, baseAmount);
 IERC20(quote).safeApprove(_curve, 0);
 IERC20(quote).safeApprove(_curve, quoteAmount);
 (uint256 lpAmount, ) = ICurve(_curve).deposit(depositAmount, _deadline);
 require(lpAmount >= _minLPAmount, "ZapLib/not-enough-lp-amount");
 }
 function calcSwapAmountForZap( address _curve, address _base, address _quote, uint256 _zapAmount, bool isFromBase ) public view returns (uint256) {
 uint256 curveBaseBal = IERC20(_base).balanceOf(_curve);
 uint8 curveBaseDecimals = ERC20(_base).decimals();
 uint256 curveQuoteBal = IERC20(_quote).balanceOf(_curve);
 uint256 initialSwapAmount = _zapAmount.div(2);
 if (isFromBase) {
 return ( _calcBaseSwapAmount( initialSwapAmount, ZapData({
 curve: _curve, base: _base, quote: _quote, zapAmount: _zapAmount, curveBaseBal: curveBaseBal, curveBaseDecimals: curveBaseDecimals, curveQuoteBal: curveQuoteBal }
 ) ) );
 }
 return ( _calcQuoteSwapAmount( initialSwapAmount, ZapData({
 curve: _curve, base: _base, quote: _quote, zapAmount: _zapAmount, curveBaseBal: curveBaseBal, curveBaseDecimals: curveBaseDecimals, curveQuoteBal: curveQuoteBal }
 ) ) );
 }
 function _calcQuoteSwapAmount( uint256 initialSwapAmount, ZapData memory zapData ) public view returns (uint256) {
 uint256 swapAmount = initialSwapAmount;
 uint256 delta = initialSwapAmount.div(2);
 uint256 recvAmount;
 uint256 curveRatio;
 uint256 userRatio;
 for (uint256 i = 0; i < 32; i++) {
 recvAmount = ICurve(zapData.curve).viewOriginSwap( zapData.quote, zapData.base, swapAmount );
 userRatio = recvAmount .mul(10**(36 - uint256(zapData.curveBaseDecimals))) .div(zapData.zapAmount.sub(swapAmount).mul(1e12));
 curveRatio = zapData .curveBaseBal .sub(recvAmount) .mul(10**(36 - uint256(zapData.curveBaseDecimals))) .div(zapData.curveQuoteBal.add(swapAmount).mul(1e12));
 if (userRatio.div(1e16) == curveRatio.div(1e16)) {
 return swapAmount;
 }
 else if (userRatio > curveRatio) {
 swapAmount = swapAmount.sub(delta);
 }
 else if (userRatio < curveRatio) {
 swapAmount = swapAmount.add(delta);
 }
 if (swapAmount > zapData.zapAmount) {
 swapAmount = zapData.zapAmount - 1;
 }
 delta = delta.div(2);
 }
 revert("ZapLib/not-converging");
 }
 function _calcBaseSwapAmount( uint256 initialSwapAmount, ZapData memory zapData ) public view returns (uint256) {
 uint256 swapAmount = initialSwapAmount;
 uint256 delta = initialSwapAmount.div(2);
 uint256 recvAmount;
 uint256 curveRatio;
 uint256 userRatio;
 for (uint256 i = 0; i < 32; i++) {
 recvAmount = ICurve(zapData.curve).viewOriginSwap( zapData.base, zapData.quote, swapAmount );
 userRatio = zapData .zapAmount .sub(swapAmount) .mul(10**(36 - uint256(zapData.curveBaseDecimals))) .div(recvAmount.mul(1e12));
 curveRatio = zapData .curveBaseBal .add(swapAmount) .mul(10**(36 - uint256(zapData.curveBaseDecimals))) .div(zapData.curveQuoteBal.sub(recvAmount).mul(1e12));
 if (userRatio.div(1e16) == curveRatio.div(1e16)) {
 return swapAmount;
 }
 else if (userRatio > curveRatio) {
 swapAmount = swapAmount.add(delta);
 }
 else if (userRatio < curveRatio) {
 swapAmount = swapAmount.sub(delta);
 }
 if (swapAmount > zapData.zapAmount) {
 swapAmount = zapData.zapAmount - 1;
 }
 delta = delta.div(2);
 }
 revert("ZapLib/not-converging");
 }
 function _calcDepositAmount(DepositData memory dd) public view returns ( uint256, uint256, uint256[] memory ) {
 uint8 curveBaseDecimals = ERC20(dd.base).decimals();
 uint256 curveRatio = IERC20(dd.base) .balanceOf(dd.curve) .mul(10**(36 - uint256(curveBaseDecimals))) .div(IERC20(dd.quote).balanceOf(dd.curve).mul(1e12));
 uint256 usdcDepositAmount = dd.curQuoteAmount.mul(1e12);
 uint256 baseDepositAmount = dd.curBaseAmount.mul( 10**(18 - uint256(curveBaseDecimals)) );
 uint256 depositAmount = usdcDepositAmount.add( baseDepositAmount.mul(1e18).div(curveRatio) );
 depositAmount = _roundDown(depositAmount);
 (uint256 lps, uint256[] memory outs) = ICurve(dd.curve).viewDeposit( depositAmount );
 uint256 baseDelta = outs[0] > dd.maxBaseAmount ? outs[0].sub(dd.curBaseAmount) : 0;
 uint256 usdcDelta = outs[1] > dd.maxQuoteAmount ? outs[1].sub(dd.curQuoteAmount) : 0;
 if (baseDelta > 0 || usdcDelta > 0) {
 dd.curBaseAmount = _roundDown(dd.curBaseAmount.sub(baseDelta));
 dd.curQuoteAmount = _roundDown(dd.curQuoteAmount.sub(usdcDelta));
 return _calcDepositAmount(dd);
 }
 return (depositAmount, lps, outs);
 }
 function _roundDown(uint256 a) public pure returns (uint256) {
 return a.mul(99999999).div(100000000);
 }
 }
 pragma solidity >=0.6.0 <0.8.0;
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
 pragma solidity >=0.6.0 <0.8.0;
 contract ERC20 is Context, IERC20 {
 using SafeMath for uint256;
 mapping (address => uint256) private _balances;
 mapping (address => mapping (address => uint256)) private _allowances;
 uint256 private _totalSupply;
 string private _name;
 string private _symbol;
 uint8 private _decimals;
 constructor (string memory name_, string memory symbol_) public {
 _name = name_;
 _symbol = symbol_;
 _decimals = 18;
 }
 function name() public view virtual returns (string memory) {
 return _name;
 }
 function symbol() public view virtual returns (string memory) {
 return _symbol;
 }
 function decimals() public view virtual returns (uint8) {
 return _decimals;
 }
 function totalSupply() public view virtual override returns (uint256) {
 return _totalSupply;
 }
 function balanceOf(address account) public view virtual override returns (uint256) {
 return _balances[account];
 }
 function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
 _transfer(_msgSender(), recipient, amount);
 return true;
 }
 function allowance(address owner, address spender) public view virtual override returns (uint256) {
 return _allowances[owner][spender];
 }
 function approve(address spender, uint256 amount) public virtual override returns (bool) {
 _approve(_msgSender(), spender, amount);
 return true;
 }
 function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
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
 function _transfer(address sender, address recipient, uint256 amount) internal virtual {
 require(sender != address(0), "ERC20: transfer from the zero address");
 require(recipient != address(0), "ERC20: transfer to the zero address");
 _beforeTokenTransfer(sender, recipient, amount);
 _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
 _balances[recipient] = _balances[recipient].add(amount);
 emit Transfer(sender, recipient, amount);
 }
 function _mint(address account, uint256 amount) internal virtual {
 require(account != address(0), "ERC20: mint to the zero address");
 _beforeTokenTransfer(address(0), account, amount);
 _totalSupply = _totalSupply.add(amount);
 _balances[account] = _balances[account].add(amount);
 emit Transfer(address(0), account, amount);
 }
 function _burn(address account, uint256 amount) internal virtual {
 require(account != address(0), "ERC20: burn from the zero address");
 _beforeTokenTransfer(account, address(0), amount);
 _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
 _totalSupply = _totalSupply.sub(amount);
 emit Transfer(account, address(0), amount);
 }
 function _approve(address owner, address spender, uint256 amount) internal virtual {
 require(owner != address(0), "ERC20: approve from the zero address");
 require(spender != address(0), "ERC20: approve to the zero address");
 _allowances[owner][spender] = amount;
 emit Approval(owner, spender, amount);
 }
 function _setupDecimals(uint8 decimals_) internal virtual {
 _decimals = decimals_;
 }
 function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {
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
 pragma solidity ^0.7.6;
 interface ICurve {
 function allowance(address _owner, address _spender) external view returns (uint256 allowance_);
 function approve(address _spender, uint256 _amount) external returns (bool success_);
 function assimilator(address _derivative) external view returns (address assimilator_);
 function balanceOf(address _account) external view returns (uint256 balance_);
 function curve() external view returns ( int128 alpha_, int128 beta_, int128 delta_, int128 epsilon_, int128 lambda_, uint256 cap_, uint256 totalSupply_ );
 function decimals() external view returns (uint8);
 function deposit(uint256 _deposit, uint256 _deadline) external returns (uint256, uint256[] memory);
 function derivatives(uint256) external view returns (address);
 function emergency() external view returns (bool);
 function emergencyWithdraw(uint256 _curvesToBurn, uint256 _deadline) external returns (uint256[] memory withdrawals_);
 function excludeDerivative(address _derivative) external;
 function frozen() external view returns (bool);
 function liquidity() external view returns (uint256 total_, uint256[] memory individual_);
 function name() external view returns (string memory);
 function numeraires(uint256) external view returns (address);
 function originSwap( address _origin, address _target, uint256 _originAmount, uint256 _minTargetAmount, uint256 _deadline ) external returns (uint256 targetAmount_);
 function owner() external view returns (address);
 function reserves(uint256) external view returns (address);
 function setCap(uint256 _cap) external;
 function setEmergency(bool _emergency) external;
 function setFrozen(bool _toFreezeOrNotToFreeze) external;
 function setParams( uint256 _alpha, uint256 _beta, uint256 _feeAtHalt, uint256 _epsilon, uint256 _lambda ) external;
 function supportsInterface(bytes4 _interface) external pure returns (bool supports_);
 function symbol() external view returns (string memory);
 function targetSwap( address _origin, address _target, uint256 _maxOriginAmount, uint256 _targetAmount, uint256 _deadline ) external returns (uint256 originAmount_);
 function totalSupply() external view returns (uint256 totalSupply_);
 function transfer(address _recipient, uint256 _amount) external returns (bool success_);
 function transferFrom( address _sender, address _recipient, uint256 _amount ) external returns (bool success_);
 function transferOwnership(address _newOwner) external;
 function viewCurve() external view returns ( uint256 alpha_, uint256 beta_, uint256 delta_, uint256 epsilon_, uint256 lambda_ );
 function viewDeposit(uint256 _deposit) external view returns (uint256, uint256[] memory);
 function viewOriginSwap( address _origin, address _target, uint256 _originAmount ) external view returns (uint256 targetAmount_);
 function viewTargetSwap( address _origin, address _target, uint256 _targetAmount ) external view returns (uint256 originAmount_);
 function viewWithdraw(uint256 _curvesToBurn) external view returns (uint256[] memory);
 function withdraw(uint256 _curvesToBurn, uint256 _deadline) external returns (uint256[] memory withdrawals_);
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
