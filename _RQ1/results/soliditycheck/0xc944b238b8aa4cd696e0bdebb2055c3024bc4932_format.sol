         pragma solidity ^0.8.0;
 interface ICSSRAdapter {
 function update(address _asset, bytes memory _data) external returns (float memory price);
 function support(address _asset) external view returns (bool);
 function getPrice(address _asset) external view returns (float memory price);
 function getLiquidity(address _asset) external view returns (uint256 _liquidity);
 }
 pragma solidity ^0.8.0;
 contract UniswapV2TokenAdapter is ICSSRAdapter {
 IGovernanceOwned public immutable owned;
 ICSSRRouter public immutable cssrRouter;
 IUniswapV2CSSR public immutable uniswapCSSR;
 IUniswapV2CSSR public immutable sushiCSSR;
 address[] public keyCurrency;
 uint256 public minimumLiquidity;
 mapping(address => bool) public isKeyCurrency;
 modifier onlyGov() {
 require(msg.sender == owned.governance(), "!gov");
 _;
 }
 constructor( address _owned, address _router, address _uniCSSR, address _sushiCSSR ) {
 owned = IGovernanceOwned(_owned);
 cssrRouter = ICSSRRouter(_router);
 uniswapCSSR = IUniswapV2CSSR(_uniCSSR);
 sushiCSSR = IUniswapV2CSSR(_sushiCSSR);
 }
 function addKeyCurrency(address _currency) external onlyGov {
 keyCurrency.push(_currency);
 isKeyCurrency[_currency] = true;
 }
 function removeKeyCurrency(uint256 _idx, address _currency) external onlyGov {
 require(keyCurrency[_idx] == _currency, "!match");
 keyCurrency[_idx] = keyCurrency[keyCurrency.length - 1];
 keyCurrency.pop();
 isKeyCurrency[_currency] = false;
 }
 function setMinimumLiquidity(uint256 _liquidity) external onlyGov {
 minimumLiquidity = _liquidity;
 }
 function support(address _asset) external view override returns (bool) {
 for (uint256 i = 0; i < keyCurrency.length; i++) {
 if (aboveLiquidity(_asset, keyCurrency[i])) {
 return true;
 }
 }
 return false;
 }
 function update(address _asset, bytes memory _data) external override returns (float memory) {
 (uint256 cssrType, bytes memory data) = abi.decode(_data, (uint256, bytes));
 if(cssrType == 0){
 ( address p, bytes memory bd, bytes memory ap, bytes memory rp, bytes memory pp0, bytes memory pp1 ) = abi.decode(data, (address, bytes, bytes, bytes, bytes, bytes));
 require(isKeyCurrency[p], "!keyCurrency");
 (, uint256 bn, ) = uniswapCSSR.saveState(bd);
 address pair = UniswapV2Library.pairFor( uniswapCSSR.uniswapFactory(), _asset, p );
 uniswapCSSR.saveReserve(bn, pair, ap, rp, pp0, pp1);
 }
 else if(cssrType == 1){
 ( address p, bytes memory bd, bytes memory ap, bytes memory rp, bytes memory pp0, bytes memory pp1 ) = abi.decode(data, (address, bytes, bytes, bytes, bytes, bytes));
 require(isKeyCurrency[p], "!keyCurrency");
 (, uint256 bn, ) = sushiCSSR.saveState(bd);
 address pair = SushiswapV2Library.pairFor( sushiCSSR.uniswapFactory(), _asset, p );
 sushiCSSR.saveReserve(bn, pair, ap, rp, pp0, pp1);
 }
 else {
 revert("!supported type");
 }
 return getPrice(_asset);
 }
 function getPriceRaw(address _asset) public view returns (uint256 sumPrice, uint256 sumLiquidity) {
 for (uint256 i = 0; i < keyCurrency.length; i++) {
 address key = keyCurrency[i];
 float memory currencyPrice = cssrRouter.getPrice(key);
 if (_asset == key) {
 continue;
 }
 try uniswapCSSR.getLiquidity(_asset, key) returns (uint256 liq) {
 uint256 liquidityValue = convertToValue(liq, currencyPrice);
 if (liquidityValue >= minimumLiquidity) {
 sumLiquidity += liquidityValue;
 sumPrice += convertToValue( uniswapCSSR.getExchangeRatio(_asset, key), currencyPrice ) * liquidityValue;
 }
 }
 catch {
 }
 try sushiCSSR.getLiquidity(_asset, key) returns (uint256 liq) {
 uint256 liq = sushiCSSR.getLiquidity(_asset,key);
 uint256 liquidityValue = convertToValue(liq, currencyPrice);
 if (liquidityValue >= minimumLiquidity) {
 sumLiquidity += liquidityValue;
 sumPrice += convertToValue( sushiCSSR.getExchangeRatio(_asset, key), currencyPrice ) * liquidityValue;
 }
 }
 catch {
 }
 }
 }
 function getPrice(address _asset) public view override returns (float memory price) {
 (uint256 sumPrice, uint256 sumLiquidity) = getPriceRaw(_asset);
 require(sumLiquidity > 0, "!updated");
 return float({
 numerator: sumPrice / 2**112, denominator: sumLiquidity}
 );
 }
 function getLiquidity(address _asset) external view override returns (uint256 sum) {
 for (uint256 i = 0; i < keyCurrency.length; i++) {
 address key = keyCurrency[i];
 float memory currencyPrice = cssrRouter.getPrice(key);
 if (_asset == key) {
 continue;
 }
 try uniswapCSSR.getLiquidity(_asset, key) returns (uint256 liq) {
 uint256 liquidityValue = convertToValue(liq, currencyPrice);
 if (liquidityValue >= minimumLiquidity) {
 sum += liquidityValue;
 }
 }
 catch {
 }
 try sushiCSSR.getLiquidity(_asset, key) returns (uint256 liq) {
 uint256 liquidityValue = convertToValue(liq, currencyPrice);
 if (liquidityValue >= minimumLiquidity) {
 sum += liquidityValue;
 }
 }
 catch {
 }
 }
 }
 function aboveLiquidity(address _asset, address _pairedWith) public view returns (bool) {
 try uniswapCSSR.getLiquidity(_asset, _pairedWith) returns ( uint256 liq ) {
 float memory price = cssrRouter.getPrice(_pairedWith);
 return convertToValue(liq, price) >= minimumLiquidity;
 }
 catch {
 try sushiCSSR.getLiquidity(_asset, _pairedWith) returns ( uint256 liq ) {
 float memory price = cssrRouter.getPrice(_pairedWith);
 return convertToValue(liq, price) >= minimumLiquidity;
 }
 catch {
 return false;
 }
 }
 }
 function convertToValue(uint256 _amount, float memory _price) internal pure returns (uint256) {
 return (_amount * _price.numerator) / _price.denominator;
 }
 }
 pragma solidity ^0.8.0;
 library UniswapV2Library {
 function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
 require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
 (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
 require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
 }
 function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
 (address token0, address token1) = sortTokens(tokenA, tokenB);
 pair = address(bytes20(uint160(uint256(keccak256(abi.encodePacked( hex'ff', factory, keccak256(abi.encodePacked(token0, token1)), hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' ))))));
 }
 function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
 (address token0,) = sortTokens(tokenA, tokenB);
 (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
 (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
 }
 function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
 require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
 require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
 amountB = amountA * reserveB / reserveA;
 }
 function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
 require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
 require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
 uint amountInWithFee = amountIn * 997;
 uint numerator = amountInWithFee * reserveOut;
 uint denominator = reserveIn * 1000 + amountInWithFee;
 amountOut = numerator / denominator;
 }
 function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
 require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
 require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
 uint numerator = reserveIn * amountOut * 1000;
 uint denominator = (reserveOut - amountOut) * 997;
 amountIn = (numerator / denominator) + 1;
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
 function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
 require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
 amounts = new uint[](path.length);
 amounts[amounts.length - 1] = amountOut;
 for (uint i = path.length - 1; i > 0; i--) {
 (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
 amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
 }
 }
 }
 pragma solidity ^0.8.0;
 library SushiswapV2Library {
 function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
 require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
 (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
 require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
 }
 function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
 (address token0, address token1) = sortTokens(tokenA, tokenB);
 pair = address(bytes20(uint160(uint256(keccak256(abi.encodePacked( hex'ff', factory, keccak256(abi.encodePacked(token0, token1)), hex'e18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303' ))))));
 }
 function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
 (address token0,) = sortTokens(tokenA, tokenB);
 (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
 (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
 }
 function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
 require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
 require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
 amountB = amountA * reserveB / reserveA;
 }
 function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
 require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
 require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
 uint amountInWithFee = amountIn * 997;
 uint numerator = amountInWithFee * reserveOut;
 uint denominator = reserveIn * 1000 + amountInWithFee;
 amountOut = numerator / denominator;
 }
 function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
 require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
 require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
 uint numerator = reserveIn * amountOut * 1000;
 uint denominator = (reserveOut - amountOut) * 997;
 amountIn = (numerator / denominator) + 1;
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
 function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
 require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
 amounts = new uint[](path.length);
 amounts[amounts.length - 1] = amountOut;
 for (uint i = path.length - 1; i > 0; i--) {
 (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
 amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
 }
 }
 }
 pragma solidity ^0.8.0;
 interface ICSSRRouter {
 function update(address _asset, bytes memory _data) external returns (float memory);
 function getPrice(address _asset) external view returns (float memory);
 function getLiquidity(address _asset) external view returns (uint256);
 }
 pragma solidity ^0.8.0;
 struct Window {
 uint128 from;
 uint128 to;
 }
 struct BlockData {
 uint256 blockTimestamp;
 bytes32 stateRoot;
 }
 struct ObservedData {
 uint32 reserveTimestamp;
 uint112 reserve0;
 uint112 reserve1;
 uint256 price0Data;
 uint256 price1Data;
 }
 interface IUniswapV2CSSR {
 function uniswapFactory() external view returns (address);
 function getExchangeRatio(address token, address denominator) external view returns (uint256);
 function getLiquidity(address token, address denominator) external view returns (uint256);
 function saveState(bytes memory blockData) external returns ( bytes32 stateRoot, uint256 blockNumber, uint256 blockTimestamp );
 function saveReserve( uint256 blockNumber, address pair, bytes memory accountProof, bytes memory reserveProof, bytes memory price0Proof, bytes memory price1Proof ) external returns (ObservedData memory data);
 }
 pragma solidity ^0.8.0;
 interface IGovernanceOwned {
 function governance() external view returns (address);
 }
 pragma solidity >=0.5.0;
 interface IUniswapV2Pair {
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
 pragma solidity ^0.8.0;
 struct float {
 uint256 numerator;
 uint256 denominator;
 }
 library Float {
 function multiply(uint256 a, float memory f) internal pure returns(uint256) {
 require(f.denominator != 0, "div 0");
 return a * f.numerator / f.denominator;
 }
 function inverse(float memory f) internal pure returns(float memory) {
 require(f.numerator != 0 && f.denominator != 0, "div 0");
 return float({
 numerator: f.denominator, denominator: f.numerator }
 );
 }
 function divide(uint256 a, float memory f) internal pure returns(uint256) {
 require(f.denominator != 0, "div 0");
 return a * f.denominator / f.numerator;
 }
 function add(float memory a, float memory b) internal pure returns(float memory res) {
 require(a.denominator != 0 && b.denominator != 0, "div 0");
 res = float({
 numerator : a.numerator*b.denominator + a.denominator*b.numerator, denominator : a.denominator*b.denominator }
 );
 if(res.numerator > 2**128 && res.denominator > 2**128){
 res.numerator = res.numerator / 2**64;
 res.denominator = res.denominator / 2**64;
 }
 }
 function sub(float memory a, float memory b) internal pure returns(float memory res) {
 require(a.denominator != 0 && b.denominator != 0, "div 0");
 res = float({
 numerator : a.numerator*b.denominator - b.numerator*a.denominator, denominator : a.denominator*b.denominator }
 );
 if(res.numerator > 2**128 && res.denominator > 2**128){
 res.numerator = res.numerator / 2**64;
 res.denominator = res.denominator / 2**64;
 }
 }
 function mul(float memory a, float memory b) internal pure returns(float memory res) {
 require(a.denominator != 0 && b.denominator != 0, "div 0");
 res = float({
 numerator : a.numerator * b.numerator, denominator : a.denominator * b.denominator }
 );
 if(res.numerator > 2**128 && res.denominator > 2**128){
 res.numerator = res.numerator / 2**64;
 res.denominator = res.denominator / 2**64;
 }
 }
 function gt(float memory a, float memory b) internal pure returns(bool) {
 require(a.denominator != 0 && b.denominator != 0, "div 0");
 return a.numerator * b.denominator > a.denominator * b.numerator;
 }
 function lt(float memory a, float memory b) internal pure returns(bool) {
 require(a.denominator != 0 && b.denominator != 0, "div 0");
 return a.numerator * b.denominator < a.denominator * b.numerator;
 }
 function gte(float memory a, float memory b) internal pure returns(bool) {
 require(a.denominator != 0 && b.denominator != 0, "div 0");
 return a.numerator * b.denominator >= a.denominator * b.numerator;
 }
 function lte(float memory a, float memory b) internal pure returns(bool) {
 require(a.denominator != 0 && b.denominator != 0, "div 0");
 return a.numerator * b.denominator <= a.denominator * b.numerator;
 }
 function equals(float memory a, float memory b) internal pure returns(bool) {
 require(a.denominator != 0 && b.denominator != 0, "div 0");
 return a.numerator * b.denominator == b.numerator * a.denominator;
 }
 }
