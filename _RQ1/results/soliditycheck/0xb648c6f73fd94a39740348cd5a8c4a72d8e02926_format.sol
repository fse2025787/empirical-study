       pragma solidity ^0.7.6;
 interface IRenaswapV1Router {
 function factory() external view returns (address);
 function WETH() external view returns (address);
 function addLiquidity( address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline ) external returns (uint amountA, uint amountB, uint liquidity);
 function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
 function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
 function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
 function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
 function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
 function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
 function removeLiquidityETHSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external returns (uint amountETH);
 function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountETH);
 function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
 function swapExactETHForTokensSupportingFeeOnTransferTokens( uint amountOutMin, address[] calldata path, address to, uint deadline ) external payable;
 function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
 }
 pragma solidity ^0.7.6;
 interface IUniswapV2ERC20 {
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
 }
 pragma solidity ^0.7.6;
 contract RenaswapV1Router is IRenaswapV1Router {
 using SafeMath for uint;
 address public immutable override factory;
 address public immutable override WETH;
 modifier ensure(uint deadline) {
 require(deadline >= block.timestamp, 'RenaswapV1Router: EXPIRED');
 _;
 }
 constructor(address _factory, address _WETH) {
 factory = _factory;
 WETH = _WETH;
 }
 receive() external payable {
 assert(msg.sender == WETH);
 }
 function _addLiquidity( address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin ) internal virtual returns (uint amountA, uint amountB) {
 if (IUniswapV2Factory(factory).getPair(tokenA, tokenB) == address(0)) {
 IUniswapV2Factory(factory).createPair(tokenA, tokenB);
 }
 (uint reserveA, uint reserveB) = RenaswapV1Library.getReserves(factory, tokenA, tokenB);
 if (reserveA == 0 && reserveB == 0) {
 (amountA, amountB) = (amountADesired, amountBDesired);
 }
 else {
 uint amountBOptimal = RenaswapV1Library.quote(amountADesired, reserveA, reserveB);
 if (amountBOptimal <= amountBDesired) {
 require(amountBOptimal >= amountBMin, 'RenaswapV1Router: INSUFFICIENT_B_AMOUNT');
 (amountA, amountB) = (amountADesired, amountBOptimal);
 }
 else {
 uint amountAOptimal = RenaswapV1Library.quote(amountBDesired, reserveB, reserveA);
 assert(amountAOptimal <= amountADesired);
 require(amountAOptimal >= amountAMin, 'RenaswapV1Router: INSUFFICIENT_A_AMOUNT');
 (amountA, amountB) = (amountAOptimal, amountBDesired);
 }
 }
 }
 function addLiquidity( address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline ) external virtual override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
 (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
 address pair = RenaswapV1Library.pairFor(factory, tokenA, tokenB);
 TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
 TransferHelper.safeTransferFrom(IUniswapV2Pair(pair).token1(), msg.sender, pair, amountB);
 liquidity = IUniswapV2Pair(pair).mint(to);
 }
 function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external virtual override payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {
 (amountToken, amountETH) = _addLiquidity( token, WETH, amountTokenDesired, msg.value, amountTokenMin, amountETHMin );
 address pair = RenaswapV1Library.pairFor(factory, token, WETH);
 TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
 IWETH(WETH).deposit{
 value: amountETH}
 ();
 IERC20(WETH).approve(IUniswapV2Pair(pair).token1(), amountETH);
 TransferHelper.safeTransferFrom(IUniswapV2Pair(pair).token1(), address(this), pair, amountETH);
 liquidity = IUniswapV2Pair(pair).mint(to);
 if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
 }
 function removeLiquidity( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline ) public virtual override ensure(deadline) returns (uint amountA, uint amountB) {
 address pair = RenaswapV1Library.pairFor(factory, tokenA, tokenB);
 IUniswapV2Pair(pair).transferFrom(msg.sender, pair, liquidity);
 (uint amount0, uint amount1) = IUniswapV2Pair(pair).burn(to);
 (address token0,) = RenaswapV1Library.sortTokens(tokenA, tokenB);
 (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
 require(amountA >= amountAMin, 'RenaswapV1Router: INSUFFICIENT_A_AMOUNT');
 require(amountB >= amountBMin, 'RenaswapV1Router: INSUFFICIENT_B_AMOUNT');
 }
 function removeLiquidityETH( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) public virtual override ensure(deadline) returns (uint amountToken, uint amountETH) {
 (amountToken, amountETH) = removeLiquidity( token, WETH, liquidity, amountTokenMin, amountETHMin, address(this), deadline );
 TransferHelper.safeTransfer(token, to, amountToken);
 IWETH(WETH).withdraw(amountETH);
 TransferHelper.safeTransferETH(to, amountETH);
 }
 function removeLiquidityWithPermit( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external virtual override returns (uint amountA, uint amountB) {
 address pair = RenaswapV1Library.pairFor(factory, tokenA, tokenB);
 uint value = approveMax ? uint(-1) : liquidity;
 IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
 (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
 }
 function removeLiquidityETHWithPermit( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external virtual override returns (uint amountToken, uint amountETH) {
 address pair = RenaswapV1Library.pairFor(factory, token, WETH);
 uint value = approveMax ? uint(-1) : liquidity;
 IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
 (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
 }
 function removeLiquidityETHSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) public virtual override ensure(deadline) returns (uint amountETH) {
 (, amountETH) = removeLiquidity( token, WETH, liquidity, amountTokenMin, amountETHMin, address(this), deadline );
 TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
 IWETH(WETH).withdraw(amountETH);
 TransferHelper.safeTransferETH(to, amountETH);
 }
 function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external virtual override returns (uint amountETH) {
 address pair = RenaswapV1Library.pairFor(factory, token, WETH);
 uint value = approveMax ? uint(-1) : liquidity;
 IUniswapV2Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
 amountETH = removeLiquidityETHSupportingFeeOnTransferTokens( token, liquidity, amountTokenMin, amountETHMin, to, deadline );
 }
 function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
 for (uint i; i < path.length - 1; i++) {
 (address input, address output) = (path[i], path[i + 1]);
 (address token0,) = RenaswapV1Library.sortTokens(input, output);
 uint amountOut = amounts[i + 1];
 (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
 address to = i < path.length - 2 ? RenaswapV1Library.pairFor(factory, output, path[i + 2]) : _to;
 IUniswapV2Pair(RenaswapV1Library.pairFor(factory, input, output)).swap( amount0Out, amount1Out, to, new bytes(0) );
 }
 }
 function swapExactTokensForTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
 amounts = RenaswapV1Library.getAmountsOut(factory, amountIn, path);
 require(amounts[amounts.length - 1] >= amountOutMin, 'RenaswapV1Router: INSUFFICIENT_OUTPUT_AMOUNT');
 TransferHelper.safeTransferFrom( path[0], msg.sender, RenaswapV1Library.pairFor(factory, path[0], path[1]), amounts[0] );
 _swap(amounts, path, to);
 }
 function swapTokensForExactTokens( uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
 amounts = RenaswapV1Library.getAmountsIn(factory, amountOut, path);
 require(amounts[0] <= amountInMax, 'RenaswapV1Router: EXCESSIVE_INPUT_AMOUNT');
 TransferHelper.safeTransferFrom( path[0], msg.sender, RenaswapV1Library.pairFor(factory, path[0], path[1]), amounts[0] );
 _swap(amounts, path, to);
 }
 function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external virtual override payable ensure(deadline) returns (uint[] memory amounts) {
 require(path[0] == WETH, 'RenaswapV1Router: INVALID_PATH');
 amounts = RenaswapV1Library.getAmountsOut(factory, msg.value, path);
 require(amounts[amounts.length - 1] >= amountOutMin, 'RenaswapV1Router: INSUFFICIENT_OUTPUT_AMOUNT');
 IWETH(WETH).deposit{
 value: amounts[0]}
 ();
 assert(IWETH(WETH).transfer(RenaswapV1Library.pairFor(factory, path[0], path[1]), amounts[0]));
 _swap(amounts, path, to);
 }
 function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external virtual override ensure(deadline) returns (uint[] memory amounts) {
 require(path[path.length - 1] == WETH, 'RenaswapV1Router: INVALID_PATH');
 amounts = RenaswapV1Library.getAmountsIn(factory, amountOut, path);
 require(amounts[0] <= amountInMax, 'RenaswapV1Router: EXCESSIVE_INPUT_AMOUNT');
 TransferHelper.safeTransferFrom( path[0], msg.sender, RenaswapV1Library.pairFor(factory, path[0], path[1]), amounts[0] );
 _swap(amounts, path, address(this));
 IWETH(WETH).withdraw(amounts[amounts.length - 1]);
 TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
 }
 function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external virtual override ensure(deadline) returns (uint[] memory amounts) {
 require(path[path.length - 1] == WETH, 'RenaswapV1Router: INVALID_PATH');
 amounts = RenaswapV1Library.getAmountsOut(factory, amountIn, path);
 require(amounts[amounts.length - 1] >= amountOutMin, 'RenaswapV1Router: INSUFFICIENT_OUTPUT_AMOUNT');
 TransferHelper.safeTransferFrom( path[0], msg.sender, RenaswapV1Library.pairFor(factory, path[0], path[1]), amounts[0] );
 _swap(amounts, path, address(this));
 IWETH(WETH).withdraw(amounts[amounts.length - 1]);
 TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
 }
 function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external virtual override payable ensure(deadline) returns (uint[] memory amounts) {
 require(path[0] == WETH, 'RenaswapV1Router: INVALID_PATH');
 amounts = RenaswapV1Library.getAmountsIn(factory, amountOut, path);
 require(amounts[0] <= msg.value, 'RenaswapV1Router: EXCESSIVE_INPUT_AMOUNT');
 IWETH(WETH).deposit{
 value: amounts[0]}
 ();
 assert(IWETH(WETH).transfer(RenaswapV1Library.pairFor(factory, path[0], path[1]), amounts[0]));
 _swap(amounts, path, to);
 if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
 }
 function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
 for (uint i; i < path.length - 1; i++) {
 (address input, address output) = (path[i], path[i + 1]);
 IUniswapV2Pair pair = IUniswapV2Pair(RenaswapV1Library.pairFor(factory, output, input));
 uint amountInput;
 uint amountOutput;
 {
 (uint reserveOutput, uint reserveInput,) = pair.getReserves();
 amountInput = IRenaswapV1Wrapper(pair.token1()).balanceFor(input, address(pair)).sub(reserveInput);
 amountOutput = RenaswapV1Library.getAmountOut(amountInput, reserveInput, reserveOutput);
 }
 pair.swap(amountOutput, 0, _to, new bytes(0));
 }
 }
 function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external virtual override ensure(deadline) {
 address pair = RenaswapV1Library.pairFor(factory, path[1], path[0]);
 TransferHelper.safeTransferFrom( IUniswapV2Pair(pair).token1(), msg.sender, pair, amountIn );
 uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
 _swapSupportingFeeOnTransferTokens(path, to);
 require( IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin, 'RenaswapV1Router: INSUFFICIENT_OUTPUT_AMOUNT' );
 }
 function swapExactETHForTokensSupportingFeeOnTransferTokens( uint amountOutMin, address[] calldata path, address to, uint deadline ) external virtual override payable ensure(deadline) {
 require(path[0] == WETH, 'RenaswapV1Router: INVALID_PATH');
 uint amountIn = msg.value;
 IWETH(WETH).deposit{
 value: amountIn}
 ();
 address pair = RenaswapV1Library.pairFor(factory, path[1], path[0]);
 IERC20(WETH).approve(IUniswapV2Pair(pair).token1(), amountIn);
 TransferHelper.safeTransferFrom(IUniswapV2Pair(pair).token1(), address(this), pair, amountIn);
 uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
 _swapSupportingFeeOnTransferTokens(path, to);
 require( IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin, 'RenaswapV1Router: INSUFFICIENT_OUTPUT_AMOUNT' );
 }
 function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external virtual override ensure(deadline) {
 require(path[path.length - 1] == WETH, 'RenaswapV1Router: INVALID_PATH');
 TransferHelper.safeTransferFrom( path[0], msg.sender, RenaswapV1Library.pairFor(factory, path[1], path[0]), amountIn );
 _swapSupportingFeeOnTransferTokens(path, address(this));
 uint amountOut = IERC20(WETH).balanceOf(address(this));
 require(amountOut >= amountOutMin, 'RenaswapV1Router: INSUFFICIENT_OUTPUT_AMOUNT');
 IWETH(WETH).withdraw(amountOut);
 TransferHelper.safeTransferETH(to, amountOut);
 }
 function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual override returns (uint amountB) {
 return RenaswapV1Library.quote(amountA, reserveA, reserveB);
 }
 function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public pure virtual override returns (uint amountOut) {
 return RenaswapV1Library.getAmountOut(amountIn, reserveIn, reserveOut);
 }
 function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) public pure virtual override returns (uint amountIn) {
 return RenaswapV1Library.getAmountIn(amountOut, reserveIn, reserveOut);
 }
 function getAmountsOut(uint amountIn, address[] memory path) public view virtual override returns (uint[] memory amounts) {
 return RenaswapV1Library.getAmountsOut(factory, amountIn, path);
 }
 function getAmountsIn(uint amountOut, address[] memory path) public view virtual override returns (uint[] memory amounts) {
 return RenaswapV1Library.getAmountsIn(factory, amountOut, path);
 }
 }
 pragma solidity ^0.7.6;
 interface IUniswapV2Factory {
 event PairCreated(address indexed token0, address indexed token1, address pair, uint);
 function feeTo() external view returns (address);
 function feeToSetter() external view returns (address);
 function getPair(address tokenA, address tokenB) external view returns (address pair);
 function allPairs(uint) external view returns (address pair);
 function allPairsLength() external view returns (uint);
 function createPair(address tokenA, address tokenB) external returns (address pair);
 function setFeeTo(address) external;
 function setFeeToSetter(address) external;
 }
 pragma solidity ^0.7.6;
 library TransferHelper {
 function safeApprove( address token, address to, uint256 value ) internal {
 (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
 require( success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper::safeApprove: approve failed' );
 }
 function safeTransfer( address token, address to, uint256 value ) internal {
 (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
 require( success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper::safeTransfer: transfer failed' );
 }
 function safeTransferFrom( address token, address from, address to, uint256 value ) internal {
 (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
 require( success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper::transferFrom: transferFrom failed' );
 }
 function safeTransferETH(address to, uint256 value) internal {
 (bool success, ) = to.call{
 value: value}
 (new bytes(0));
 require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
 }
 }
 pragma solidity ^0.7.6;
 interface IRenaswapV1Wrapper {
 function addWrappedToken(address token, address pair) external returns (uint256 id);
 function balanceFor(address token, address account) external view returns (uint256);
 function rBurn(address token, uint256 burnDivisor) external;
 }
 pragma solidity ^0.7.6;
 library RenaswapV1Library {
 using SafeMath for uint;
 function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
 token0 = tokenA;
 token1 = tokenB;
 }
 function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
 (address token0, address token1) = sortTokens(tokenA, tokenB);
 pair = address(uint(keccak256(abi.encodePacked( hex'ff', factory, keccak256(abi.encodePacked(token0, token1)), hex'c346c428cf4a1855040b9f552358dc5437d9879f85fea3b4a793682741bcec03' ))));
 }
 function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
 (address token0,) = sortTokens(tokenA, tokenB);
 (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
 (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
 }
 function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
 require(amountA > 0, 'RenaswapV1Library: INSUFFICIENT_AMOUNT');
 require(reserveA > 0 && reserveB > 0, 'RenaswapV1Library: INSUFFICIENT_LIQUIDITY');
 amountB = amountA.mul(reserveB) / reserveA;
 }
 function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
 require(amountIn > 0, 'RenaswapV1Library: INSUFFICIENT_INPUT_AMOUNT');
 require(reserveIn > 0 && reserveOut > 0, 'RenaswapV1Library: INSUFFICIENT_LIQUIDITY');
 uint amountInWithFee = amountIn.mul(997);
 uint numerator = amountInWithFee.mul(reserveOut);
 uint denominator = reserveIn.mul(1000).add(amountInWithFee);
 amountOut = numerator / denominator;
 }
 function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
 require(amountOut > 0, 'RenaswapV1Library: INSUFFICIENT_OUTPUT_AMOUNT');
 require(reserveIn > 0 && reserveOut > 0, 'RenaswapV1Library: INSUFFICIENT_LIQUIDITY');
 uint numerator = reserveIn.mul(amountOut).mul(1000);
 uint denominator = reserveOut.sub(amountOut).mul(997);
 amountIn = (numerator / denominator).add(1);
 }
 function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
 require(path.length >= 2, 'RenaswapV1Library: INVALID_PATH');
 amounts = new uint[](path.length);
 amounts[0] = amountIn;
 for (uint i; i < path.length - 1; i++) {
 (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
 amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
 }
 }
 function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
 require(path.length >= 2, 'RenaswapV1Library: INVALID_PATH');
 amounts = new uint[](path.length);
 amounts[amounts.length - 1] = amountOut;
 for (uint i = path.length - 1; i > 0; i--) {
 (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
 amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
 }
 }
 }
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
 pragma solidity ^0.7.6;
 interface IWETH {
 function deposit() external payable;
 function transfer(address to, uint value) external returns (bool);
 function withdraw(uint) external;
 }
 pragma solidity ^0.7.6;
 interface IUniswapV2Pair is IUniswapV2ERC20 {
 event Mint(address indexed sender, uint amount0, uint amount1);
 event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
 event Sync(uint112 reserve0, uint112 reserve1);
 event Swap( address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to );
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
 pragma solidity ^0.7.6;
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
