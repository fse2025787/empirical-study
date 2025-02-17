  pragma experimental ABIEncoderV2;
 pragma solidity 0.7.6;
 interface IERC20 {
 function totalSupply() external view returns (uint256);
 function balanceOf(address account) external view returns (uint256);
 function allowance(address owner, address spender) external view returns (uint256);
 function approve(address spender, uint256 amount) external returns (bool);
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed owner, address indexed spender, uint256 value);
 function permit( address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s ) external;
 }
 interface IDaiPermit {
 function permit( address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s ) external;
 }
 library BoringERC20 {
 bytes4 private constant SIG_SYMBOL = 0x95d89b41;
 bytes4 private constant SIG_NAME = 0x06fdde03;
 bytes4 private constant SIG_DECIMALS = 0x313ce567;
 bytes4 private constant SIG_TRANSFER = 0xa9059cbb;
 bytes4 private constant SIG_TRANSFER_FROM = 0x23b872dd;
 function safeTransfer( IERC20 token, address to, uint256 amount ) internal {
 (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER, to, amount));
 require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: Transfer failed");
 }
 function safeTransferFrom( IERC20 token, address from, address to, uint256 amount ) internal {
 (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(SIG_TRANSFER_FROM, from, to, amount));
 require(success && (data.length == 0 || abi.decode(data, (bool))), "BoringERC20: TransferFrom failed");
 }
 }
 contract BaseBoringBatchable {
 function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
 if (_returnData.length < 68) return "Transaction reverted silently";
 assembly {
 _returnData := add(_returnData, 0x04) }
 return abi.decode(_returnData, (string));
 }
 function batch(bytes[] calldata calls, bool revertOnFail) external payable {
 for (uint256 i = 0; i < calls.length; i++) {
 (bool success, bytes memory result) = address(this).delegatecall(calls[i]);
 if (!success && revertOnFail) {
 revert(_getRevertMsg(result));
 }
 }
 }
 }
 contract BoringBatchableWithDai is BaseBoringBatchable {
 function permitDai( IDaiPermit token, address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s ) public {
 token.permit(holder, spender, nonce, expiry, allowed, v, r, s);
 }
 function permitToken( IERC20 token, address from, address to, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s ) public {
 token.permit(from, to, amount, deadline, v, r, s);
 }
 }
 library Babylonian {
 function sqrt(uint256 x) internal pure returns (uint256) {
 if (x == 0) return 0;
 uint256 xx = x;
 uint256 r = 1;
 if (xx >= 0x100000000000000000000000000000000) {
 xx >>= 128;
 r <<= 64;
 }
 if (xx >= 0x10000000000000000) {
 xx >>= 64;
 r <<= 32;
 }
 if (xx >= 0x100000000) {
 xx >>= 32;
 r <<= 16;
 }
 if (xx >= 0x10000) {
 xx >>= 16;
 r <<= 8;
 }
 if (xx >= 0x100) {
 xx >>= 8;
 r <<= 4;
 }
 if (xx >= 0x10) {
 xx >>= 4;
 r <<= 2;
 }
 if (xx >= 0x8) {
 r <<= 1;
 }
 r = (r + x / r) >> 1;
 r = (r + x / r) >> 1;
 r = (r + x / r) >> 1;
 r = (r + x / r) >> 1;
 r = (r + x / r) >> 1;
 r = (r + x / r) >> 1;
 r = (r + x / r) >> 1;
 uint256 r1 = x / r;
 return (r < r1 ? r : r1);
 }
 }
 interface ISushiSwap {
 function factory() external view returns (address);
 function getPair(address tokenA, address tokenB) external view returns (address pair);
 function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
 function token0() external pure returns (address);
 function token1() external pure returns (address);
 function createPair(address tokenA, address tokenB) external returns (address pair);
 function mint(address to) external returns (uint liquidity);
 function burn(address to) external returns (uint amount0, uint amount1);
 function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
 function transferFrom(address from, address to, uint value) external returns (bool);
 function addLiquidity( address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline ) external returns ( uint256 amountA, uint256 amountB, uint256 liquidity );
 function swapExactTokensForTokens( uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external returns (uint256[] memory amounts);
 }
 interface IWETH {
 function deposit() external payable;
 function transfer(address to, uint value) external returns (bool);
 function withdraw(uint) external;
 }
 library SafeMath {
 function add(uint x, uint y) internal pure returns (uint z) {
 require((z = x + y) >= x, 'ds-math-add-overflow');
 }
 function sub(uint x, uint y) internal pure returns (uint z) {
 require((z = x - y) <= x, 'ds-math-sub-underflow');
 }
 function mul(uint x, uint y) internal pure returns (uint z) {
 require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
 }
 }
 library UniswapV2Library {
 using SafeMath for uint;
 function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
 require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
 (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
 require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
 }
 function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
 (address token0, address token1) = sortTokens(tokenA, tokenB);
 pair = address(uint(keccak256(abi.encodePacked( hex'ff', factory, keccak256(abi.encodePacked(token0, token1)), hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' ))));
 }
 function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
 (address token0,) = sortTokens(tokenA, tokenB);
 (uint reserve0, uint reserve1,) = ISushiSwap(pairFor(factory, tokenA, tokenB)).getReserves();
 (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
 }
 function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
 require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
 require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
 amountB = amountA.mul(reserveB) / reserveA;
 }
 function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
 require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
 require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
 uint amountInWithFee = amountIn.mul(997);
 uint numerator = amountInWithFee.mul(reserveOut);
 uint denominator = reserveIn.mul(1000).add(amountInWithFee);
 amountOut = numerator / denominator;
 }
 function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
 require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
 amounts = new uint[](path.length);
 amounts[0] = amountIn;
 for (uint i; i < path.length - 1; i++) {
 (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
 amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
 }
 }
 }
 library TransferHelper {
 function safeTransfer(address token, address to, uint value) internal {
 (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
 require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
 }
 function safeTransferFrom(address token, address from, address to, uint value) internal {
 (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
 require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
 }
 }
 contract UniswapV2Router02 {
 using SafeMath for uint;
 address constant factory = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
 address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
 modifier ensure(uint deadline) {
 require(deadline >= block.timestamp, 'UniswapV2Router: EXPIRED');
 _;
 }
 function _swap(uint[] memory amounts, address[] memory path, address _to) internal {
 for (uint i; i < path.length - 1; i++) {
 (address input, address output) = (path[i], path[i + 1]);
 (address token0,) = UniswapV2Library.sortTokens(input, output);
 uint amountOut = amounts[i + 1];
 (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
 address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
 ISushiSwap(UniswapV2Library.pairFor(factory, input, output)).swap( amount0Out, amount1Out, to, new bytes(0) );
 }
 }
 function swapExactTokensForTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external ensure(deadline) returns (uint[] memory amounts) {
 amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
 require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
 TransferHelper.safeTransferFrom( path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0] );
 _swap(amounts, path, to);
 }
 }
 interface IAaveBridge {
 function UNDERLYING_ASSET_ADDRESS() external view returns (address);
 function deposit( address asset, uint256 amount, address onBehalfOf, uint16 referralCode ) external;
 function withdraw( address token, uint256 amount, address destination ) external;
 }
 interface IBentoBridge {
 function balanceOf(IERC20, address) external view returns (uint256);
 function registerProtocol() external;
 function setMasterContractApproval( address user, address masterContract, bool approved, uint8 v, bytes32 r, bytes32 s ) external;
 function deposit( IERC20 token_, address from, address to, uint256 amount, uint256 share ) external payable returns (uint256 amountOut, uint256 shareOut);
 function withdraw( IERC20 token_, address from, address to, uint256 amount, uint256 share ) external returns (uint256 amountOut, uint256 shareOut);
 }
 interface ICompoundBridge {
 function underlying() external view returns (address);
 function mint(uint mintAmount) external returns (uint);
 function redeem(uint redeemTokens) external returns (uint);
 }
 interface ISushiBarBridge {
 function enter(uint256 amount) external;
 function leave(uint256 share) external;
 }
 contract Sushiswap_ZapIn_General_V3 is UniswapV2Router02 {
 using SafeMath for uint256;
 using BoringERC20 for IERC20;
 address constant sushiSwapFactory = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
 ISushiSwap constant sushiSwapRouter = ISushiSwap(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);
 uint256 constant deadline = 0xf000000000000000000000000000000000000000000000000000000000000000;
 bytes32 constant pairCodeHash = 0xe18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303;
 event ZapIn(address sender, address pool, uint256 tokensRec);
 function balanceOfOptimized(address token) internal view returns (uint256 amount) {
 (bool success, bytes memory data) = token.staticcall(abi.encodeWithSelector(IERC20.balanceOf.selector, address(this)));
 require(success && data.length >= 32);
 amount = abi.decode(data, (uint256));
 }
 function zapIn( address to, address _FromTokenContractAddress, address _pairAddress, uint256 _amount, uint256 _minPoolTokens, address _swapTarget, bytes calldata swapData ) external payable returns (uint256) {
 uint256 toInvest = _pullTokens( _FromTokenContractAddress, _amount );
 uint256 LPBought = _performZapIn( _FromTokenContractAddress, _pairAddress, toInvest, _swapTarget, swapData );
 require(LPBought >= _minPoolTokens, 'ERR: High Slippage');
 emit ZapIn(to, _pairAddress, LPBought);
 IERC20(_pairAddress).safeTransfer(to, LPBought);
 return LPBought;
 }
 function _getPairTokens(address _pairAddress) internal pure returns (address token0, address token1) {
 ISushiSwap sushiPair = ISushiSwap(_pairAddress);
 token0 = sushiPair.token0();
 token1 = sushiPair.token1();
 }
 function _pullTokens(address token, uint256 amount) internal returns (uint256 value) {
 if (token == address(0)) {
 require(msg.value > 0, 'No eth sent');
 return msg.value;
 }
 require(amount > 0, 'Invalid token amount');
 require(msg.value == 0, 'Eth sent with token');
 IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
 return amount;
 }
 function _performZapIn( address _FromTokenContractAddress, address _pairAddress, uint256 _amount, address _swapTarget, bytes memory swapData ) internal returns (uint256) {
 uint256 intermediateAmt;
 address intermediateToken;
 ( address _ToSushipoolToken0, address _ToSushipoolToken1 ) = _getPairTokens(_pairAddress);
 if ( _FromTokenContractAddress != _ToSushipoolToken0 && _FromTokenContractAddress != _ToSushipoolToken1 ) {
 (intermediateAmt, intermediateToken) = _fillQuote( _FromTokenContractAddress, _pairAddress, _amount, _swapTarget, swapData );
 }
 else {
 intermediateToken = _FromTokenContractAddress;
 intermediateAmt = _amount;
 }
 (uint256 token0Bought, uint256 token1Bought) = _swapIntermediate( intermediateToken, _ToSushipoolToken0, _ToSushipoolToken1, intermediateAmt );
 return _sushiDeposit( _ToSushipoolToken0, _ToSushipoolToken1, token0Bought, token1Bought );
 }
 function _sushiDeposit( address _ToUnipoolToken0, address _ToUnipoolToken1, uint256 token0Bought, uint256 token1Bought ) internal returns (uint256) {
 IERC20(_ToUnipoolToken0).approve(address(sushiSwapRouter), 0);
 IERC20(_ToUnipoolToken1).approve(address(sushiSwapRouter), 0);
 IERC20(_ToUnipoolToken0).approve( address(sushiSwapRouter), token0Bought );
 IERC20(_ToUnipoolToken1).approve( address(sushiSwapRouter), token1Bought );
 (uint256 amountA, uint256 amountB, uint256 LP) = sushiSwapRouter .addLiquidity( _ToUnipoolToken0, _ToUnipoolToken1, token0Bought, token1Bought, 1, 1, address(this), deadline );
 if (token0Bought.sub(amountA) > 0) {
 IERC20(_ToUnipoolToken0).safeTransfer( msg.sender, token0Bought.sub(amountA) );
 }
 if (token1Bought.sub(amountB) > 0) {
 IERC20(_ToUnipoolToken1).safeTransfer( msg.sender, token1Bought.sub(amountB) );
 }
 return LP;
 }
 function _fillQuote( address _fromTokenAddress, address _pairAddress, uint256 _amount, address _swapTarget, bytes memory swapCallData ) internal returns (uint256 amountBought, address intermediateToken) {
 uint256 valueToSend;
 if (_fromTokenAddress == address(0)) {
 valueToSend = _amount;
 }
 else {
 IERC20 fromToken = IERC20(_fromTokenAddress);
 fromToken.approve(address(_swapTarget), 0);
 fromToken.approve(address(_swapTarget), _amount);
 }
 (address _token0, address _token1) = _getPairTokens(_pairAddress);
 IERC20 token0 = IERC20(_token0);
 IERC20 token1 = IERC20(_token1);
 uint256 initialBalance0 = balanceOfOptimized(address(token0));
 uint256 initialBalance1 = balanceOfOptimized(address(token1));
 (bool success, ) = _swapTarget.call{
 value: valueToSend}
 (swapCallData);
 require(success, 'Error Swapping Tokens 1');
 uint256 finalBalance0 = balanceOfOptimized(address(token0)).sub( initialBalance0 );
 uint256 finalBalance1 = balanceOfOptimized(address(token1)).sub( initialBalance1 );
 if (finalBalance0 > finalBalance1) {
 amountBought = finalBalance0;
 intermediateToken = _token0;
 }
 else {
 amountBought = finalBalance1;
 intermediateToken = _token1;
 }
 require(amountBought > 0, 'Swapped to Invalid Intermediate');
 }
 function _swapIntermediate( address _toContractAddress, address _ToSushipoolToken0, address _ToSushipoolToken1, uint256 _amount ) internal returns (uint256 token0Bought, uint256 token1Bought) {
 (address token0, address token1) = _ToSushipoolToken0 < _ToSushipoolToken1 ? (_ToSushipoolToken0, _ToSushipoolToken1) : (_ToSushipoolToken1, _ToSushipoolToken0);
 ISushiSwap pair = ISushiSwap( uint256( keccak256(abi.encodePacked(hex"ff", sushiSwapFactory, keccak256(abi.encodePacked(token0, token1)), pairCodeHash)) ) );
 (uint256 res0, uint256 res1, ) = pair.getReserves();
 if (_toContractAddress == _ToSushipoolToken0) {
 uint256 amountToSwap = calculateSwapInAmount(res0, _amount);
 if (amountToSwap <= 0) amountToSwap = _amount / 2;
 token1Bought = _token2Token( _toContractAddress, _ToSushipoolToken1, amountToSwap );
 token0Bought = _amount.sub(amountToSwap);
 }
 else {
 uint256 amountToSwap = calculateSwapInAmount(res1, _amount);
 if (amountToSwap <= 0) amountToSwap = _amount / 2;
 token0Bought = _token2Token( _toContractAddress, _ToSushipoolToken0, amountToSwap );
 token1Bought = _amount.sub(amountToSwap);
 }
 }
 function calculateSwapInAmount(uint256 reserveIn, uint256 userIn) internal pure returns (uint256) {
 return Babylonian .sqrt( reserveIn.mul(userIn.mul(3988000) + reserveIn.mul(3988009)) ) .sub(reserveIn.mul(1997)) / 1994;
 }
 function _token2Token( address _FromTokenContractAddress, address _ToTokenContractAddress, uint256 tokens2Trade ) internal returns (uint256 tokenBought) {
 if (_FromTokenContractAddress == _ToTokenContractAddress) {
 return tokens2Trade;
 }
 IERC20(_FromTokenContractAddress).approve( address(sushiSwapRouter), 0 );
 IERC20(_FromTokenContractAddress).approve( address(sushiSwapRouter), tokens2Trade );
 (address token0, address token1) = _FromTokenContractAddress < _ToTokenContractAddress ? (_FromTokenContractAddress, _ToTokenContractAddress) : (_ToTokenContractAddress, _FromTokenContractAddress);
 address pair = address( uint256( keccak256(abi.encodePacked(hex"ff", sushiSwapFactory, keccak256(abi.encodePacked(token0, token1)), pairCodeHash)) ) );
 require(pair != address(0), 'No Swap Available');
 address[] memory path = new address[](2);
 path[0] = _FromTokenContractAddress;
 path[1] = _ToTokenContractAddress;
 tokenBought = sushiSwapRouter.swapExactTokensForTokens( tokens2Trade, 1, path, address(this), deadline )[path.length - 1];
 require(tokenBought > 0, 'Error Swapping Tokens 2');
 }
 function zapOut( address pair, address to, uint256 amount ) external returns (uint256 amount0, uint256 amount1) {
 IERC20(pair).safeTransferFrom(msg.sender, pair, amount);
 (amount0, amount1) = ISushiSwap(pair).burn(to);
 }
 function zapOutBalance( address pair, address to ) external returns (uint256 amount0, uint256 amount1) {
 IERC20(pair).safeTransfer(pair, balanceOfOptimized(pair));
 (amount0, amount1) = ISushiSwap(pair).burn(to);
 }
 }
 interface IMasterChefV2 {
 function lpToken(uint256 pid) external view returns (IERC20);
 function deposit(uint256 pid, uint256 amount, address to) external;
 }
 contract InariV1 is BoringBatchableWithDai, Sushiswap_ZapIn_General_V3 {
 using SafeMath for uint256;
 using BoringERC20 for IERC20;
 IERC20 constant sushiToken = IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
 address constant sushiBar = 0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272;
 IMasterChefV2 constant masterChefv2 = IMasterChefV2(0xEF0881eC094552b2e128Cf945EF17a6752B4Ec5d);
 ISushiSwap constant sushiSwapSushiETHPair = ISushiSwap(0x795065dCc9f64b5614C407a6EFDC400DA6221FB0);
 IAaveBridge constant aave = IAaveBridge(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
 IERC20 constant aaveSushiToken = IERC20(0xF256CC7847E919FAc9B808cC216cAc87CCF2f47a);
 IBentoBridge constant bento = IBentoBridge(0xF5BCE5077908a1b7370B9ae04AdC565EBd643966);
 address constant crSushiToken = 0x338286C0BC081891A4Bda39C7667ae150bf5D206;
 address constant crXSushiToken = 0x228619CCa194Fbe3Ebeb2f835eC1eA5080DaFbb2;
 address constant wETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
 constructor() {
 bento.registerProtocol();
 }
 function bridgeToken(IERC20[] calldata token, address[] calldata to) external {
 for (uint256 i = 0; i < token.length; i++) {
 token[i].approve(to[i], type(uint256).max);
 }
 }
 receive() external payable {
 }
 function withdrawETHbalance(address to) external payable {
 (bool success, ) = to.call{
 value: address(this).balance}
 ("");
 require(success, '!payable');
 }
 function depositBalanceToWETH() external payable {
 IWETH(wETH).deposit{
 value: address(this).balance}
 ();
 }
 function withdrawBalanceFromWETH(address to) external {
 uint256 balance = balanceOfOptimized(WETH);
 IWETH(wETH).withdraw(balance);
 (bool success, ) = to.call{
 value: balance}
 ("");
 require(success, '!payable');
 }
 function withdrawTokenBalance(IERC20 token, address to) external {
 token.safeTransfer(to, balanceOfOptimized(address(token)));
 }
 function stakeSushiBalance(address to) external {
 ISushiBarBridge(sushiBar).enter(balanceOfOptimized(address(sushiToken)));
 IERC20(sushiBar).safeTransfer(to, balanceOfOptimized(sushiBar));
 }
 function depositToMasterChefv2(uint256 amount, uint256 pid, address to) external {
 masterChefv2.deposit(pid, amount, to);
 }
 function balanceToMasterChefv2(address lpToken, uint256 pid, address to) external {
 masterChefv2.deposit(pid, balanceOfOptimized(lpToken), to);
 }
 function balanceToAave(address underlying, address to) external {
 aave.deposit(underlying, balanceOfOptimized(underlying), to, 0);
 }
 function balanceFromAave(address aToken, address to) external {
 address underlying = IAaveBridge(aToken).UNDERLYING_ASSET_ADDRESS();
 aave.withdraw(underlying, balanceOfOptimized(aToken), to);
 }
 function aaveToBento(address aToken, address to, uint256 amount) external returns (uint256 amountOut, uint256 shareOut) {
 IERC20(aToken).safeTransferFrom(msg.sender, address(this), amount);
 address underlying = IAaveBridge(aToken).UNDERLYING_ASSET_ADDRESS();
 aave.withdraw(underlying, amount, address(bento));
 (amountOut, shareOut) = bento.deposit(IERC20(underlying), address(bento), to, amount, 0);
 }
 function bentoToAave(IERC20 underlying, address to, uint256 amount) external {
 bento.withdraw(underlying, msg.sender, address(this), amount, 0);
 aave.deposit(address(underlying), amount, to, 0);
 }
 function aaveToCompound(address aToken, address cToken, address to, uint256 amount) external {
 IERC20(aToken).safeTransferFrom(msg.sender, address(this), amount);
 address underlying = IAaveBridge(aToken).UNDERLYING_ASSET_ADDRESS();
 aave.withdraw(underlying, amount, address(this));
 ICompoundBridge(cToken).mint(amount);
 IERC20(cToken).safeTransfer(to, balanceOfOptimized(cToken));
 }
 function compoundToAave(address cToken, address to, uint256 amount) external {
 IERC20(cToken).safeTransferFrom(msg.sender, address(this), amount);
 ICompoundBridge(cToken).redeem(amount);
 address underlying = ICompoundBridge(cToken).underlying();
 aave.deposit(underlying, balanceOfOptimized(underlying), to, 0);
 }
 function stakeSushiToAave(address to, uint256 amount) external {
 sushiToken.safeTransferFrom(msg.sender, address(this), amount);
 ISushiBarBridge(sushiBar).enter(amount);
 aave.deposit(sushiBar, balanceOfOptimized(sushiBar), to, 0);
 }
 function unstakeSushiFromAave(address to, uint256 amount) external {
 aaveSushiToken.safeTransferFrom(msg.sender, address(this), amount);
 aave.withdraw(sushiBar, amount, address(this));
 ISushiBarBridge(sushiBar).leave(amount);
 sushiToken.safeTransfer(to, balanceOfOptimized(address(sushiToken)));
 }
 function zapToBento( address to, address _FromTokenContractAddress, address _pairAddress, uint256 _amount, uint256 _minPoolTokens, address _swapTarget, bytes calldata swapData ) external payable returns (uint256) {
 uint256 toInvest = _pullTokens( _FromTokenContractAddress, _amount );
 uint256 LPBought = _performZapIn( _FromTokenContractAddress, _pairAddress, toInvest, _swapTarget, swapData );
 require(LPBought >= _minPoolTokens, "ERR: High Slippage");
 emit ZapIn(to, _pairAddress, LPBought);
 bento.deposit(IERC20(_pairAddress), address(this), to, LPBought, 0);
 return LPBought;
 }
 function zapFromBento( address pair, address to, uint256 amount ) external returns (uint256 amount0, uint256 amount1) {
 bento.withdraw(IERC20(pair), msg.sender, pair, amount, 0);
 (amount0, amount1) = ISushiSwap(pair).burn(to);
 }
 function balanceToBento(IERC20 token, address to) external returns (uint256 amountOut, uint256 shareOut) {
 (amountOut, shareOut) = bento.deposit(token, address(this), to, balanceOfOptimized(address(token)), 0);
 }
 function depositFromBento(IERC20 token, uint256 amount) external returns (uint256 amountOut, uint256 shareOut) {
 (amountOut, shareOut) = bento.withdraw(token, msg.sender, address(this), amount, 0);
 }
 function setBentoApproval( address user, address masterContract, bool approved, uint8 v, bytes32 r, bytes32 s ) external {
 bento.setMasterContractApproval(user, masterContract, approved, v, r, s);
 }
 function stakeSushiToBento(address to, uint256 amount) external returns (uint256 amountOut, uint256 shareOut) {
 sushiToken.safeTransferFrom(msg.sender, address(this), amount);
 ISushiBarBridge(sushiBar).enter(amount);
 (amountOut, shareOut) = bento.deposit(IERC20(sushiBar), address(this), to, balanceOfOptimized(sushiBar), 0);
 }
 function unstakeSushiFromBento(address to, uint256 amount) external {
 bento.withdraw(IERC20(sushiBar), msg.sender, address(this), amount, 0);
 ISushiBarBridge(sushiBar).leave(amount);
 sushiToken.safeTransfer(to, balanceOfOptimized(address(sushiToken)));
 }
 function balanceToCompound(ICompoundBridge cToken) external {
 IERC20 underlying = IERC20(ICompoundBridge(cToken).underlying());
 cToken.mint(balanceOfOptimized(address(underlying)));
 }
 function balanceFromCompound(address cToken) external {
 ICompoundBridge(cToken).redeem(balanceOfOptimized(cToken));
 }
 function compoundToBento(address cToken, address to, uint256 cTokenAmount) external returns (uint256 amountOut, uint256 shareOut) {
 IERC20(cToken).safeTransferFrom(msg.sender, address(this), cTokenAmount);
 ICompoundBridge(cToken).redeem(cTokenAmount);
 IERC20 underlying = IERC20(ICompoundBridge(cToken).underlying());
 (amountOut, shareOut) = bento.deposit(underlying, address(this), to, balanceOfOptimized(address(underlying)), 0);
 }
 function bentoToCompound(address cToken, address to, uint256 underlyingAmount) external {
 IERC20 underlying = IERC20(ICompoundBridge(cToken).underlying());
 bento.withdraw(underlying, msg.sender, address(this), underlyingAmount, 0);
 ICompoundBridge(cToken).mint(underlyingAmount);
 IERC20(cToken).safeTransfer(to, balanceOfOptimized(cToken));
 }
 function sushiToCreamToBento(address to, uint256 amount) external returns (uint256 amountOut, uint256 shareOut) {
 sushiToken.safeTransferFrom(msg.sender, address(this), amount);
 ICompoundBridge(crSushiToken).mint(amount);
 (amountOut, shareOut) = bento.deposit(IERC20(crSushiToken), address(this), to, balanceOfOptimized(crSushiToken), 0);
 }
 function sushiFromCreamFromBento(address to, uint256 cTokenAmount) external {
 bento.withdraw(IERC20(crSushiToken), msg.sender, address(this), cTokenAmount, 0);
 ICompoundBridge(crSushiToken).redeem(cTokenAmount);
 sushiToken.safeTransfer(to, balanceOfOptimized(address(sushiToken)));
 }
 function stakeSushiToCream(address to, uint256 amount) external {
 sushiToken.safeTransferFrom(msg.sender, address(this), amount);
 ISushiBarBridge(sushiBar).enter(amount);
 ICompoundBridge(crXSushiToken).mint(balanceOfOptimized(sushiBar));
 IERC20(crXSushiToken).safeTransfer(to, balanceOfOptimized(crXSushiToken));
 }
 function unstakeSushiFromCream(address to, uint256 cTokenAmount) external {
 IERC20(crXSushiToken).safeTransferFrom(msg.sender, address(this), cTokenAmount);
 ICompoundBridge(crXSushiToken).redeem(cTokenAmount);
 ISushiBarBridge(sushiBar).leave(balanceOfOptimized(sushiBar));
 sushiToken.safeTransfer(to, balanceOfOptimized(address(sushiToken)));
 }
 function stakeSushiToCreamToBento(address to, uint256 amount) external returns (uint256 amountOut, uint256 shareOut) {
 sushiToken.safeTransferFrom(msg.sender, address(this), amount);
 ISushiBarBridge(sushiBar).enter(amount);
 ICompoundBridge(crXSushiToken).mint(balanceOfOptimized(sushiBar));
 (amountOut, shareOut) = bento.deposit(IERC20(crXSushiToken), address(this), to, balanceOfOptimized(crXSushiToken), 0);
 }
 function unstakeSushiFromCreamFromBento(address to, uint256 cTokenAmount) external {
 bento.withdraw(IERC20(crXSushiToken), msg.sender, address(this), cTokenAmount, 0);
 ICompoundBridge(crXSushiToken).redeem(cTokenAmount);
 ISushiBarBridge(sushiBar).leave(balanceOfOptimized(sushiBar));
 sushiToken.safeTransfer(to, balanceOfOptimized(address(sushiToken)));
 }
 function inariZushi(address to) external payable returns (uint256 amountOut, uint256 shareOut) {
 (uint256 reserve0, uint256 reserve1, ) = sushiSwapSushiETHPair.getReserves();
 uint256 amountInWithFee = msg.value.mul(997);
 uint256 out = amountInWithFee.mul(reserve0) / reserve1.mul(1000).add(amountInWithFee);
 IWETH(wETH).deposit{
 value: msg.value}
 ();
 IERC20(wETH).safeTransfer(address(sushiSwapSushiETHPair), msg.value);
 sushiSwapSushiETHPair.swap(out, 0, address(this), "");
 ISushiBarBridge(sushiBar).enter(balanceOfOptimized(address(sushiToken)));
 (amountOut, shareOut) = bento.deposit(IERC20(sushiBar), address(this), to, balanceOfOptimized(sushiBar), 0);
 }
 function swapSingle(address fromToken, address toToken, address to, uint256 amountIn) external returns (uint256 amountOut) {
 (address token0, address token1) = fromToken < toToken ? (fromToken, toToken) : (toToken, fromToken);
 ISushiSwap pair = ISushiSwap( uint256( keccak256(abi.encodePacked(hex"ff", sushiSwapFactory, keccak256(abi.encodePacked(token0, token1)), pairCodeHash)) ) );
 (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
 uint256 amountInWithFee = amountIn.mul(997);
 IERC20(fromToken).safeTransferFrom(msg.sender, address(this), amountIn);
 if (toToken > fromToken) {
 amountOut = amountInWithFee.mul(reserve1) / reserve0.mul(1000).add(amountInWithFee);
 IERC20(fromToken).safeTransfer(address(pair), amountIn);
 pair.swap(0, amountOut, to, "");
 }
 else {
 amountOut = amountInWithFee.mul(reserve0) / reserve1.mul(1000).add(amountInWithFee);
 IERC20(fromToken).safeTransfer(address(pair), amountIn);
 pair.swap(amountOut, 0, to, "");
 }
 }
 function swapBalance(address fromToken, address toToken, address to) external returns (uint256 amountOut) {
 (address token0, address token1) = fromToken < toToken ? (fromToken, toToken) : (toToken, fromToken);
 ISushiSwap pair = ISushiSwap( uint256( keccak256(abi.encodePacked(hex"ff", sushiSwapFactory, keccak256(abi.encodePacked(token0, token1)), pairCodeHash)) ) );
 uint256 amountIn = balanceOfOptimized(fromToken);
 (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
 uint256 amountInWithFee = amountIn.mul(997);
 if (toToken > fromToken) {
 amountOut = amountInWithFee.mul(reserve1) / reserve0.mul(1000).add(amountInWithFee);
 IERC20(fromToken).safeTransfer(address(pair), amountIn);
 pair.swap(0, amountOut, to, "");
 }
 else {
 amountOut = amountInWithFee.mul(reserve0) / reserve1.mul(1000).add(amountInWithFee);
 IERC20(fromToken).safeTransfer(address(pair), amountIn);
 pair.swap(amountOut, 0, to, "");
 }
 }
 }
