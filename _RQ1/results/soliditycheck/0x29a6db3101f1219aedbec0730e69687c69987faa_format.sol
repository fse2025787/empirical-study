            pragma solidity ^0.6.12;
 interface IERC20 {
 function totalSupply() external view returns (uint256);
 function balanceOf(address account) external view returns (uint256);
 function transfer(address recipient, uint256 amount) external returns (bool);
 function allowance(address owner, address spender) external view returns (uint256);
 function approve(address spender, uint256 amount) external returns (bool);
 function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval( address indexed owner, address indexed spender, uint256 value );
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
 abstract contract Context {
 function _msgSender() internal view virtual returns (address payable) {
 return msg.sender;
 }
 function _msgData() internal view virtual returns (bytes memory) {
 this;
 return msg.data;
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
 require( address(this).balance >= amount, "Address: insufficient balance" );
 (bool success, ) = recipient.call{
 value: amount}
 ("");
 require( success, "Address: unable to send value, recipient may have reverted" );
 }
 function functionCall(address target, bytes memory data) internal returns (bytes memory) {
 return functionCall(target, data, "Address: low-level call failed");
 }
 function functionCall( address target, bytes memory data, string memory errorMessage ) internal returns (bytes memory) {
 return _functionCallWithValue(target, data, 0, errorMessage);
 }
 function functionCallWithValue( address target, bytes memory data, uint256 value ) internal returns (bytes memory) {
 return functionCallWithValue( target, data, value, "Address: low-level call with value failed" );
 }
 function functionCallWithValue( address target, bytes memory data, uint256 value, string memory errorMessage ) internal returns (bytes memory) {
 require( address(this).balance >= value, "Address: insufficient balance for call" );
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
 contract Ownable is Context {
 address private _owner;
 address private _previousOwner;
 uint256 private _lockTime;
 event OwnershipTransferred( address indexed previousOwner, address indexed newOwner );
 constructor() internal {
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
 require( newOwner != address(0), "Ownable: new owner is the zero address" );
 emit OwnershipTransferred(_owner, newOwner);
 _owner = newOwner;
 }
 function geUnlockTime() public view returns (uint256) {
 return _lockTime;
 }
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
 interface IUniswapV2Pair {
 event Approval( address indexed owner, address indexed spender, uint256 value );
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
 interface IUniswapV2Router02 is IUniswapV2Router01 {
 function removeLiquidityETHSupportingFeeOnTransferTokens( address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline ) external returns (uint256 amountETH);
 function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens( address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint256 amountETH);
 function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external;
 function swapExactETHForTokensSupportingFeeOnTransferTokens( uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external payable;
 function swapExactTokensForETHSupportingFeeOnTransferTokens( uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external;
 }
 contract GoatCoin is Context, IERC20, Ownable {
 using SafeMath for uint256;
 using Address for address;
 mapping (address => bool) private _isSniper;
 address[] private _confirmedSnipers;
 mapping(address => uint256) private _rOwned;
 mapping(address => uint256) private _tOwned;
 mapping(address => mapping(address => uint256)) private _allowances;
 mapping(address => bool) private _isExcludedFromFee;
 mapping(address => bool) private _isExcluded;
 address[] private _excluded;
 uint256 private constant MAX = ~uint256(0);
 uint256 private _tTotal = 10000000000 * 10**1 * 10**9;
 uint256 private _rTotal = (MAX - (MAX % _tTotal));
 uint256 private _tFeeTotal;
 string private _name = "Goat";
 string private _symbol = "GOAT \xF0\x9F\x90\x90";
 uint8 private _decimals = 9;
 address payable public _teamWalletAddress;
 uint256 public _taxFee = 0;
 uint256 private _previousTaxFee = _taxFee;
 uint256 public _liquidityFee = 9;
 uint256 private _previousLiquidityFee = _liquidityFee;
 uint256 private _liqFeeRatio = 6;
 IUniswapV2Router02 public immutable uniswapV2Router;
 address public immutable uniswapV2Pair;
 bool inSwapAndLiquify;
 bool public swapAndLiquifyEnabled = true;
 uint256 public _maxTxAmount = 100000000 * 10**1 * 10**9;
 uint256 private numTokensSellToAddToLiquidity = 60000000 * 10**1 * 10**9;
 event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
 event SwapAndLiquifyEnabledUpdated(bool enabled);
 event SwapAndLiquify( uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity );
 event SwapToTeam(uint256 tokensSwapped);
 modifier lockTheSwap {
 inSwapAndLiquify = true;
 _;
 inSwapAndLiquify = false;
 }
 constructor(address payable teamAddress) public {
 _teamWalletAddress = teamAddress;
 _rOwned[_msgSender()] = _rTotal;
 IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
 uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()) .createPair(address(this), _uniswapV2Router.WETH());
 uniswapV2Router = _uniswapV2Router;
 _isExcludedFromFee[owner()] = true;
 _isExcludedFromFee[address(this)] = true;
 _isSniper[address(0x7589319ED0fD750017159fb4E4d96C63966173C1)] = true;
 _confirmedSnipers.push(address(0x7589319ED0fD750017159fb4E4d96C63966173C1));
 _isSniper[address(0x65A67DF75CCbF57828185c7C050e34De64d859d0)] = true;
 _confirmedSnipers.push(address(0x65A67DF75CCbF57828185c7C050e34De64d859d0));
 _isSniper[address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce)] = true;
 _confirmedSnipers.push(address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce));
 _isSniper[address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce)] = true;
 _confirmedSnipers.push(address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce));
 _isSniper[address(0xe516bDeE55b0b4e9bAcaF6285130De15589B1345)] = true;
 _confirmedSnipers.push(address(0xe516bDeE55b0b4e9bAcaF6285130De15589B1345));
 _isSniper[address(0xa1ceC245c456dD1bd9F2815a6955fEf44Eb4191b)] = true;
 _confirmedSnipers.push(address(0xa1ceC245c456dD1bd9F2815a6955fEf44Eb4191b));
 _isSniper[address(0xd7d3EE77D35D0a56F91542D4905b1a2b1CD7cF95)] = true;
 _confirmedSnipers.push(address(0xd7d3EE77D35D0a56F91542D4905b1a2b1CD7cF95));
 _isSniper[address(0xFe76f05dc59fEC04184fA0245AD0C3CF9a57b964)] = true;
 _confirmedSnipers.push(address(0xFe76f05dc59fEC04184fA0245AD0C3CF9a57b964));
 _isSniper[address(0xDC81a3450817A58D00f45C86d0368290088db848)] = true;
 _confirmedSnipers.push(address(0xDC81a3450817A58D00f45C86d0368290088db848));
 _isSniper[address(0x45fD07C63e5c316540F14b2002B085aEE78E3881)] = true;
 _confirmedSnipers.push(address(0x45fD07C63e5c316540F14b2002B085aEE78E3881));
 _isSniper[address(0x27F9Adb26D532a41D97e00206114e429ad58c679)] = true;
 _confirmedSnipers.push(address(0x27F9Adb26D532a41D97e00206114e429ad58c679));
 _isSniper[address(0x9282dc5c422FA91Ff2F6fF3a0b45B7BF97CF78E7)] = true;
 _confirmedSnipers.push(address(0x9282dc5c422FA91Ff2F6fF3a0b45B7BF97CF78E7));
 _isSniper[address(0xfad95B6089c53A0D1d861eabFaadd8901b0F8533)] = true;
 _confirmedSnipers.push(address(0xfad95B6089c53A0D1d861eabFaadd8901b0F8533));
 _isSniper[address(0x1d6E8BAC6EA3730825bde4B005ed7B2B39A2932d)] = true;
 _confirmedSnipers.push(address(0x1d6E8BAC6EA3730825bde4B005ed7B2B39A2932d));
 _isSniper[address(0x000000000000084e91743124a982076C59f10084)] = true;
 _confirmedSnipers.push(address(0x000000000000084e91743124a982076C59f10084));
 _isSniper[address(0x6dA4bEa09C3aA0761b09b19837D9105a52254303)] = true;
 _confirmedSnipers.push(address(0x6dA4bEa09C3aA0761b09b19837D9105a52254303));
 _isSniper[address(0x323b7F37d382A68B0195b873aF17CeA5B67cd595)] = true;
 _confirmedSnipers.push(address(0x323b7F37d382A68B0195b873aF17CeA5B67cd595));
 _isSniper[address(0x000000005804B22091aa9830E50459A15E7C9241)] = true;
 _confirmedSnipers.push(address(0x000000005804B22091aa9830E50459A15E7C9241));
 _isSniper[address(0xA3b0e79935815730d942A444A84d4Bd14A339553)] = true;
 _confirmedSnipers.push(address(0xA3b0e79935815730d942A444A84d4Bd14A339553));
 _isSniper[address(0xf6da21E95D74767009acCB145b96897aC3630BaD)] = true;
 _confirmedSnipers.push(address(0xf6da21E95D74767009acCB145b96897aC3630BaD));
 _isSniper[address(0x0000000000007673393729D5618DC555FD13f9aA)] = true;
 _confirmedSnipers.push(address(0x0000000000007673393729D5618DC555FD13f9aA));
 _isSniper[address(0x00000000000003441d59DdE9A90BFfb1CD3fABf1)] = true;
 _confirmedSnipers.push(address(0x00000000000003441d59DdE9A90BFfb1CD3fABf1));
 _isSniper[address(0x59903993Ae67Bf48F10832E9BE28935FEE04d6F6)] = true;
 _confirmedSnipers.push(address(0x59903993Ae67Bf48F10832E9BE28935FEE04d6F6));
 _isSniper[address(0x000000917de6037d52b1F0a306eeCD208405f7cd)] = true;
 _confirmedSnipers.push(address(0x000000917de6037d52b1F0a306eeCD208405f7cd));
 _isSniper[address(0x7100e690554B1c2FD01E8648db88bE235C1E6514)] = true;
 _confirmedSnipers.push(address(0x7100e690554B1c2FD01E8648db88bE235C1E6514));
 _isSniper[address(0x72b30cDc1583224381132D379A052A6B10725415)] = true;
 _confirmedSnipers.push(address(0x72b30cDc1583224381132D379A052A6B10725415));
 _isSniper[address(0x9eDD647D7d6Eceae6bB61D7785Ef66c5055A9bEE)] = true;
 _confirmedSnipers.push(address(0x9eDD647D7d6Eceae6bB61D7785Ef66c5055A9bEE));
 _isSniper[address(0xfe9d99ef02E905127239E85A611c29ad32c31c2F)] = true;
 _confirmedSnipers.push(address(0xfe9d99ef02E905127239E85A611c29ad32c31c2F));
 _isSniper[address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b)] = true;
 _confirmedSnipers.push(address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b));
 _isSniper[address(0xc496D84215d5018f6F53E7F6f12E45c9b5e8e8A9)] = true;
 _confirmedSnipers.push(address(0xc496D84215d5018f6F53E7F6f12E45c9b5e8e8A9));
 _isSniper[address(0x59341Bc6b4f3Ace878574b05914f43309dd678c7)] = true;
 _confirmedSnipers.push(address(0x59341Bc6b4f3Ace878574b05914f43309dd678c7));
 _isSniper[address(0xe986d48EfeE9ec1B8F66CD0b0aE8e3D18F091bDF)] = true;
 _confirmedSnipers.push(address(0xe986d48EfeE9ec1B8F66CD0b0aE8e3D18F091bDF));
 _isSniper[address(0x4aEB32e16DcaC00B092596ADc6CD4955EfdEE290)] = true;
 _confirmedSnipers.push(address(0x4aEB32e16DcaC00B092596ADc6CD4955EfdEE290));
 _isSniper[address(0x136F4B5b6A306091b280E3F251fa0E21b1280Cd5)] = true;
 _confirmedSnipers.push(address(0x136F4B5b6A306091b280E3F251fa0E21b1280Cd5));
 _isSniper[address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b)] = true;
 _confirmedSnipers.push(address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b));
 _isSniper[address(0x5B83A351500B631cc2a20a665ee17f0dC66e3dB7)] = true;
 _confirmedSnipers.push(address(0x5B83A351500B631cc2a20a665ee17f0dC66e3dB7));
 _isSniper[address(0xbCb05a3F85d34f0194C70d5914d5C4E28f11Cc02)] = true;
 _confirmedSnipers.push(address(0xbCb05a3F85d34f0194C70d5914d5C4E28f11Cc02));
 _isSniper[address(0x22246F9BCa9921Bfa9A3f8df5baBc5Bc8ee73850)] = true;
 _confirmedSnipers.push(address(0x22246F9BCa9921Bfa9A3f8df5baBc5Bc8ee73850));
 _isSniper[address(0x42d4C197036BD9984cA652303e07dD29fA6bdB37)] = true;
 _confirmedSnipers.push(address(0x42d4C197036BD9984cA652303e07dD29fA6bdB37));
 _isSniper[address(0x00000000003b3cc22aF3aE1EAc0440BcEe416B40)] = true;
 _confirmedSnipers.push(address(0x00000000003b3cc22aF3aE1EAc0440BcEe416B40));
 _isSniper[address(0x231DC6af3C66741f6Cf618884B953DF0e83C1A2A)] = true;
 _confirmedSnipers.push(address(0x231DC6af3C66741f6Cf618884B953DF0e83C1A2A));
 _isSniper[address(0xC6bF34596f74eb22e066a878848DfB9fC1CF4C65)] = true;
 _confirmedSnipers.push(address(0xC6bF34596f74eb22e066a878848DfB9fC1CF4C65));
 _isSniper[address(0x20f6fCd6B8813c4f98c0fFbD88C87c0255040Aa3)] = true;
 _confirmedSnipers.push(address(0x20f6fCd6B8813c4f98c0fFbD88C87c0255040Aa3));
 _isSniper[address(0xD334C5392eD4863C81576422B968C6FB90EE9f79)] = true;
 _confirmedSnipers.push(address(0xD334C5392eD4863C81576422B968C6FB90EE9f79));
 _isSniper[address(0xFFFFF6E70842330948Ca47254F2bE673B1cb0dB7)] = true;
 _confirmedSnipers.push(address(0xFFFFF6E70842330948Ca47254F2bE673B1cb0dB7));
 _isSniper[address(0xA39C50bf86e15391180240938F469a7bF4fDAe9a)] = true;
 _confirmedSnipers.push(address(0xA39C50bf86e15391180240938F469a7bF4fDAe9a));
 _isSniper[address(0xA39C50bf86e15391180240938F469a7bF4fDAe9a)] = true;
 _confirmedSnipers.push(address(0xA39C50bf86e15391180240938F469a7bF4fDAe9a));
 emit Transfer(address(0), _msgSender(), _tTotal);
 }
 function isRemovedSniper(address account) public view returns (bool) {
 return _isSniper[account];
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
 function transferFrom( address sender, address recipient, uint256 amount ) public override returns (bool) {
 _transfer(sender, recipient, amount);
 _approve( sender, _msgSender(), _allowances[sender][_msgSender()].sub( amount, "ERC20: transfer amount exceeds allowance" ) );
 return true;
 }
 function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
 _approve( _msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue) );
 return true;
 }
 function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
 _approve( _msgSender(), spender, _allowances[_msgSender()][spender].sub( subtractedValue, "ERC20: decreased allowance below zero" ) );
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
 require( !_isExcluded[sender], "Excluded addresses cannot call this function" );
 (uint256 rAmount, , , , , ) = _getValues(tAmount);
 _rOwned[sender] = _rOwned[sender].sub(rAmount);
 _rTotal = _rTotal.sub(rAmount);
 _tFeeTotal = _tFeeTotal.add(tAmount);
 }
 function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns (uint256) {
 require(tAmount <= _tTotal, "Amount must be less than supply");
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
 require( rAmount <= _rTotal, "Amount must be less than total reflections" );
 uint256 currentRate = _getRate();
 return rAmount.div(currentRate);
 }
 function excludeFromReward(address account) public onlyOwner() {
 require(!_isExcluded[account], "Account is already excluded");
 if (_rOwned[account] > 0) {
 _tOwned[account] = tokenFromReflection(_rOwned[account]);
 }
 _isExcluded[account] = true;
 _excluded.push(account);
 }
 function includeInReward(address account) external onlyOwner() {
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
 function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
 require(taxFee <= 9, "TaxFee > 9");
 _taxFee = taxFee;
 }
 function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
 require(liquidityFee <= 9, "liq fee > 9");
 _liquidityFee = liquidityFee;
 }
 function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
 require(maxTxPercent > 0, "Maxtx <= 0");
 _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**2);
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
 (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
 (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
 return ( rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity );
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
 if ( _rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply ) return (_rTotal, _tTotal);
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
 function _approve( address owner, address spender, uint256 amount ) private {
 require(owner != address(0), "ERC20: approve from the zero address");
 require(spender != address(0), "ERC20: approve to the zero address");
 _allowances[owner][spender] = amount;
 emit Approval(owner, spender, amount);
 }
 function _transfer( address from, address to, uint256 amount ) private {
 require(from != address(0), "ERC20: transfer from the zero address");
 require(to != address(0), "ERC20: transfer to the zero address");
 require(!_isSniper[to], "You have no power here!");
 require(!_isSniper[msg.sender], "You have no power here!");
 require(amount > 0, "Transfer amount must be greater than zero");
 if (from != owner() && to != owner()) require( amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount." );
 uint256 contractTokenBalance = balanceOf(address(this));
 if (contractTokenBalance >= _maxTxAmount) {
 contractTokenBalance = _maxTxAmount;
 }
 bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
 if ( overMinTokenBalance && !inSwapAndLiquify && from != uniswapV2Pair && swapAndLiquifyEnabled ) {
 contractTokenBalance = numTokensSellToAddToLiquidity;
 swapForFees(contractTokenBalance);
 }
 bool takeFee = true;
 if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
 takeFee = false;
 }
 _tokenTransfer(from, to, amount, takeFee);
 }
 function swapForFees(uint256 contractTokenBalance) private lockTheSwap {
 sendBNBToTeam(contractTokenBalance);
 emit SwapToTeam(contractTokenBalance);
 }
 function swapTokensForEth(uint256 tokenAmount) private {
 address[] memory path = new address[](2);
 path[0] = address(this);
 path[1] = uniswapV2Router.WETH();
 _approve(address(this), address(uniswapV2Router), tokenAmount);
 uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens( tokenAmount, 0, path, address(this), block.timestamp );
 }
 function sendBNBToTeam(uint256 amount) private {
 swapTokensForEth(amount);
 _teamWalletAddress.transfer(address(this).balance);
 }
 function _setTeamWallet(address payable teamWalletAddress) external onlyOwner() {
 _teamWalletAddress = teamWalletAddress;
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
