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
 pragma solidity >=0.6.0 <0.8.0;
 abstract contract Ownable is Context {
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
 pragma solidity >=0.6.2;
 interface IPYESwapRouter01 {
 function factory() external pure returns (address);
 function WETH() external pure returns (address);
 function addLiquidity( address tokenA, address tokenB, bool supportsTokenFee, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline ) external returns (uint amountA, uint amountB, uint liquidity);
 function addLiquidityETH( address token, bool supportsTokenFee, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
 function removeLiquidity( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline ) external returns (uint amountA, uint amountB);
 function removeLiquidityETH( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external returns (uint amountToken, uint amountETH);
 function removeLiquidityWithPermit( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountA, uint amountB);
 function removeLiquidityETHWithPermit( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountToken, uint amountETH);
 function swapExactTokensForTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external returns (uint[] memory amounts);
 function swapTokensForExactTokens( uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline ) external returns (uint[] memory amounts);
 function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
 function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
 function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
 function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
 }
 pragma solidity 0.6.12;
 contract PresaleLockForwarder is Ownable {
 IPresaleFactory public PRESALE_FACTORY;
 IMoonForceSwapLocker public MOON_FORCE_LOCKER;
 IMoonForceSwapFactory public MOON_FORCE_FACTORY;
 IPYESwapRouter public PYESwapRouter;
 constructor() public {
 PRESALE_FACTORY = IPresaleFactory(0x931d82cc98F8Bca90949382A619295Ed5467C2F9);
 MOON_FORCE_LOCKER = IMoonForceSwapLocker(0x60F90Ad88E50B562b39C0f33aD579bc91e0c09A2);
 MOON_FORCE_FACTORY = IMoonForceSwapFactory(0xA2F8f1FAb81300c48208dc0aE540c6675d19f4cd);
 PYESwapRouter = IPYESwapRouter(0x4F71E29C3D5934A15308005B19Ca263061E99616);
 }
 function moonForcePairIsInitialised (address _token0, address _token1) public view returns (bool) {
 address pairAddress = MOON_FORCE_FACTORY.getPair(_token0, _token1);
 if (pairAddress == address(0)) {
 return false;
 }
 uint256 balance = IERC20(_token0).balanceOf(pairAddress);
 if (balance > 0) {
 return true;
 }
 return false;
 }
 function lockLiquidity (IERC20 _baseToken, IERC20 _saleToken, uint256 _baseAmount, uint256 _saleAmount, uint256 _unlock_date, address payable _withdrawer) external {
 require(PRESALE_FACTORY.presaleIsRegistered(msg.sender), 'PRESALE NOT REGISTERED');
 address pair = MOON_FORCE_FACTORY.getPair(address(_baseToken), address(_saleToken));
 bool supportsTokenFee = false;
 try IToken(address(_saleToken)).getTotalFee() {
 supportsTokenFee = true;
 }
 catch {
 supportsTokenFee = false;
 }
 if (pair == address(0)) {
 MOON_FORCE_FACTORY.createPair(address(_saleToken), address(_baseToken), supportsTokenFee);
 pair = MOON_FORCE_FACTORY.getPair(address(_baseToken), address(_saleToken));
 }
 TransferHelper.safeTransferFrom(address(_baseToken), msg.sender, address(this), _baseAmount);
 TransferHelper.safeTransferFrom(address(_saleToken), msg.sender, address(this), _saleAmount);
 TransferHelper.safeApprove(address(_baseToken), address(PYESwapRouter), _baseAmount);
 TransferHelper.safeApprove(address(_saleToken), address(PYESwapRouter), _saleAmount);
 PYESwapRouter.addLiquidity(address(_saleToken), address(_baseToken), supportsTokenFee, _saleAmount, _baseAmount, 0, 0, address(this), block.timestamp);
 uint256 totalLPTokensMinted = IMoonForceSwapPair(pair).balanceOf(address(this));
 require(totalLPTokensMinted != 0 , "LP creation failed");
 TransferHelper.safeApprove(pair, address(MOON_FORCE_LOCKER), totalLPTokensMinted);
 uint256 unlock_date = _unlock_date > 9999999999 ? 9999999999 : _unlock_date;
 MOON_FORCE_LOCKER.lockLPToken(pair, totalLPTokensMinted, unlock_date, address(0), true, _withdrawer);
 }
 }
 pragma solidity ^0.6.12;
 interface IToken {
 function getTotalFee() external returns (uint256);
 function getOwnedBalance(address account) external view returns (uint);
 }
 pragma solidity >=0.5.0;
 interface IERC20 {
 event Approval(address indexed owner, address indexed spender, uint value);
 event Transfer(address indexed from, address indexed to, uint value);
 function decimals() external view returns (uint8);
 function totalSupply() external view returns (uint);
 function balanceOf(address owner) external view returns (uint);
 function allowance(address owner, address spender) external view returns (uint);
 function approve(address spender, uint value) external returns (bool);
 function transfer(address to, uint value) external returns (bool);
 function transferFrom(address from, address to, uint value) external returns (bool);
 }
 pragma solidity >=0.6.2;
 interface IPYESwapRouter is IPYESwapRouter01 {
 function removeLiquidityETHSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external returns (uint amountETH);
 function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountETH);
 function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
 function swapExactETHForTokensSupportingFeeOnTransferTokens( uint amountOutMin, address[] calldata path, address to, uint deadline ) external payable;
 function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
 }
 pragma solidity >=0.5.0;
 interface IMoonForceSwapPair {
 event Approval(address indexed owner, address indexed spender, uint value);
 event Transfer(address indexed from, address indexed to, uint value);
 function name() external pure returns (string memory);
 function symbol() external pure returns (string memory);
 function decimals() external pure returns (uint8);
 function totalSupply() external view returns (uint);
 function balanceOf(address owner) external view returns (uint);
 function allowance(address owner, address spender) external view returns (uint);
 function approve(address spender, uint value) external returns (bool);
 function transfer(address to, uint value) external returns (bool);
 function transferFrom(address from, address to, uint value) external returns (bool);
 function DOMAIN_SEPARATOR() external view returns (bytes32);
 function PERMIT_TYPEHASH() external pure returns (bytes32);
 function nonces(address owner) external view returns (uint);
 function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
 event Mint(address indexed sender, uint amount0, uint amount1);
 event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
 event Swap( address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to );
 event Sync(uint112 reserve0, uint112 reserve1);
 function MINIMUM_LIQUIDITY() external pure returns (uint);
 function factory() external view returns (address);
 function token0() external view returns (address);
 function token1() external view returns (address);
 function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
 function price0CumulativeLast() external view returns (uint);
 function price1CumulativeLast() external view returns (uint);
 function kLast() external view returns (uint);
 function mint(address to) external returns (uint liquidity);
 function burn(address to) external returns (uint amount0, uint amount1);
 function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
 function skim(address to) external;
 function sync() external;
 function initialize(address, address) external;
 }
 pragma solidity >=0.5.0;
 interface IMoonForceSwapFactory {
 event PairCreated(address indexed token0, address indexed token1, address pair, uint);
 function feeTo() external view returns (address);
 function feeToSetter() external view returns (address);
 function getPair(address tokenA, address tokenB) external view returns (address pair);
 function allPairs(uint) external view returns (address pair);
 function allPairsLength() external view returns (uint);
 function createPair(address tokenA, address tokenB, bool supportsTokenFee) external returns (address pair);
 function setFeeTo(address) external;
 function setFeeToSetter(address) external;
 }
 pragma solidity 0.6.12;
 interface IMoonForceSwapLocker {
 function lockLPToken (address _lpToken, uint256 _amount, uint256 _unlock_date, address payable _referral, bool _fee_in_eth, address payable _withdrawer) external payable;
 }
 pragma solidity 0.6.12;
 interface IPresaleFactory {
 function registerPresale (address _presaleAddress) external;
 function presaleIsRegistered(address _presaleAddress) external view returns (bool);
 }
 pragma solidity 0.6.12;
 library TransferHelper {
 function safeApprove(address token, address to, uint value) internal {
 (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
 require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
 }
 function safeTransfer(address token, address to, uint value) internal {
 (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
 require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
 }
 function safeTransferFrom(address token, address from, address to, uint value) internal {
 (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
 require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
 }
 function safeTransferBaseToken(address token, address payable to, uint value, bool isERC20) internal {
 if (!isERC20) {
 (bool success, ) = to.call{
 value: value}
 ("");
 require(success, 'TransferHelper: TRANSFER_FAILED');
 }
 else {
 (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
 require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
 }
 }
 }
