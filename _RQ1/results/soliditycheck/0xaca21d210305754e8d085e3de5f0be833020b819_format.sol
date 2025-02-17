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
 function safeTransferETH(address to, uint value) internal {
 (bool success,) = to.call{
 value:value}
 (new bytes(0));
 require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
 }
 }
 interface IERC20 {
 event Approval(address indexed owner, address indexed spender, uint value);
 event Transfer(address indexed from, address indexed to, uint value);
 function name() external view returns (string memory);
 function symbol() external view returns (string memory);
 function decimals() external view returns (uint8);
 function totalSupply() external view returns (uint);
 function balanceOf(address owner) external view returns (uint);
 function allowance(address owner, address spender) external view returns (uint);
 function approve(address spender, uint value) external returns (bool);
 function transfer(address to, uint value) external returns (bool);
 function transferFrom(address from, address to, uint value) external returns (bool);
 }
 interface IBank {
 function addReward( address token0, address token1, uint256 amount0, uint256 amount1 ) external;
 function addrewardtoken(address token, uint256 amount) external;
 }
 interface IFarm {
 function addLPInfo( IERC20 _lpToken, IERC20 _rewardToken0, IERC20 _rewardToken1 ) external;
 function addReward( address _lp, address token0, address token1, uint256 amount0, uint256 amount1 ) external;
 function addrewardtoken( address _lp, address token, uint256 amount ) external;
 }
 library SafeMathBabylonSwap {
 function add(uint x, uint y) internal pure returns (uint z) {
 require((z = x + y) >= x, 'ds-math-add-overflow');
 }
 function sub(uint x, uint y) internal pure returns (uint z) {
 require((z = x - y) <= x, 'ds-math-sub-underflow');
 }
 function mul(uint x, uint y) internal pure returns (uint z) {
 require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
 }
 function div(uint256 a, uint256 b) internal pure returns (uint256) {
 return div(a, b, "SafeMath: division by zero");
 }
 function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b > 0, errorMessage);
 uint256 c = a / b;
 return c;
 }
 }
 interface IBabylonSwapV2Callee {
 function BabylonSwapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
 }
 interface IBabylonSwapV2Router01 {
 function factory() external pure returns (address);
 function WETH() external pure returns (address);
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
 }
 library UQ112x112 {
 uint224 constant Q112 = 2**112;
 function encode(uint112 y) internal pure returns (uint224 z) {
 z = uint224(y) * Q112;
 }
 function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
 z = x / uint224(y);
 }
 }
 library Math {
 function min(uint x, uint y) internal pure returns (uint z) {
 z = x < y ? x : y;
 }
 function sqrt(uint y) internal pure returns (uint z) {
 if (y > 3) {
 z = y;
 uint x = y / 2 + 1;
 while (x < z) {
 z = x;
 x = (y / x + x) / 2;
 }
 }
 else if (y != 0) {
 z = 1;
 }
 }
 }
 contract BabylonSwapV2ERC20 {
 using SafeMathBabylonSwap for uint;
 string public constant name = 'BabylonSwap LP Token';
 string public constant symbol = 'BSLP';
 uint8 public constant decimals = 18;
 uint public totalSupply;
 mapping(address => uint) public balanceOf;
 mapping(address => mapping(address => uint)) public allowance;
 bytes32 public DOMAIN_SEPARATOR;
 bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
 mapping(address => uint) public nonces;
 event Approval(address indexed owner, address indexed spender, uint value);
 event Transfer(address indexed from, address indexed to, uint value);
 constructor() public {
 uint chainId;
 assembly {
 chainId := chainid() }
 DOMAIN_SEPARATOR = keccak256( abi.encode( keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'), keccak256(bytes(name)), keccak256(bytes('1')), chainId, address(this) ) );
 }
 function _mint(address to, uint value) internal {
 totalSupply = totalSupply.add(value);
 balanceOf[to] = balanceOf[to].add(value);
 emit Transfer(address(0), to, value);
 }
 function _burn(address from, uint value) internal {
 balanceOf[from] = balanceOf[from].sub(value);
 totalSupply = totalSupply.sub(value);
 emit Transfer(from, address(0), value);
 }
 function _approve(address owner, address spender, uint value) private {
 allowance[owner][spender] = value;
 emit Approval(owner, spender, value);
 }
 function _transfer(address from, address to, uint value) internal {
 balanceOf[from] = balanceOf[from].sub(value);
 balanceOf[to] = balanceOf[to].add(value);
 emit Transfer(from, to, value);
 }
 function approve(address spender, uint value) external returns (bool) {
 _approve(msg.sender, spender, value);
 return true;
 }
 function transfer(address to, uint value) public returns (bool) {
 _transfer(msg.sender, to, value);
 return true;
 }
 function transferFrom(address from, address to, uint value) external returns (bool) {
 if (allowance[from][msg.sender] != uint(-1)) {
 allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
 }
 _transfer(from, to, value);
 return true;
 }
 function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
 require(deadline >= block.timestamp, 'BabylonSwapV2: EXPIRED');
 bytes32 digest = keccak256( abi.encodePacked( '\x19\x01', DOMAIN_SEPARATOR, keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline)) ) );
 address recoveredAddress = ecrecover(digest, v, r, s);
 require(recoveredAddress != address(0) && recoveredAddress == owner, 'BabylonSwapV2: INVALID_SIGNATURE');
 _approve(owner, spender, value);
 }
 }
 interface IBabylonSwapV2Factory {
 event PairCreated(address indexed token0, address indexed token1, address pair, uint);
 function feeTo() external view returns (address);
 function feeToSetter() external view returns (address);
 function getPair(address tokenA, address tokenB) external view returns (address pair);
 function allPairs(uint) external view returns (address pair);
 function allPairsLength() external view returns (uint);
 function createPair(address tokenA, address tokenB) external returns (address pair);
 function setFeeToSetter(address) external;
 function PERCENT100() external view returns (uint256);
 function DEADADDRESS() external view returns (address);
 function lockFee() external view returns (uint256);
 function pause() external view returns (bool);
 function setRouter(address _router) external ;
 function feeTransfer() external view returns (address);
 function setFeeTransfer(address)external ;
 }
 contract BabylonSwapFeeTransfer {
 using SafeMathBabylonSwap for uint256;
 uint256 public constant PERCENT100 = 1000000;
 address public farm;
 address public miningBank;
 address public xbtBank;
 uint256 public miningbankFee = 300;
 uint256 public farmFee = 1000;
 uint256 public xbtbankFee = 200;
 constructor(address _farm, address _miningBank, address _xbtBank) public {
 farm = _farm;
 miningBank = _miningBank;
 xbtBank = _xbtBank;
 }
 function takeSwapFee(address lp, address token) public returns (uint256) {
 uint256 amount = IERC20(token).balanceOf(address(this));
 uint256[10] memory fees;
 fees[0] = amount.mul(miningbankFee).div(swaptotalFee());
 fees[1] = amount.mul(farmFee).div(swaptotalFee());
 fees[2] = amount.mul(xbtbankFee).div(swaptotalFee());
 _approvetokens(token, miningBank, amount);
 IBank(miningBank).addrewardtoken(token, fees[0]);
 _approvetokens(token, farm, amount);
 IFarm(farm).addrewardtoken(lp, token, fees[1]);
 _approvetokens(token, xbtBank, amount);
 IFarm(xbtBank).addrewardtoken(lp, token, fees[2]);
 }
 function swaptotalFee() public view returns (uint256) {
 return miningbankFee + farmFee + xbtbankFee;
 }
 function _approvetokens( address _token, address _receiver, uint256 _amount ) private {
 if ( _token != address(0x000) || IERC20(_token).allowance(address(this), _receiver) < _amount ) {
 IERC20(_token).approve(_receiver, _amount);
 }
 }
 }
 contract BabylonSwapV2Pair is BabylonSwapV2ERC20 {
 using SafeMathBabylonSwap for uint;
 using UQ112x112 for uint224;
 uint public constant MINIMUM_LIQUIDITY = 10**3;
 bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));
 address public factory;
 address public router;
 address public token0;
 address public token1;
 uint112 private reserve0;
 uint112 private reserve1;
 uint32 private blockTimestampLast;
 uint public price0CumulativeLast;
 uint public price1CumulativeLast;
 uint public kLast;
 uint private unlocked = 1;
 modifier lock() {
 require(unlocked == 1, 'BabylonSwapV2: LOCKED');
 unlocked = 0;
 _;
 unlocked = 1;
 }
 function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
 _reserve0 = reserve0;
 _reserve1 = reserve1;
 _blockTimestampLast = blockTimestampLast;
 }
 function _safeTransfer(address token, address to, uint value) private {
 (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
 require(success && (data.length == 0 || abi.decode(data, (bool))), 'BabylonSwapV2: TRANSFER_FAILED');
 }
 event Mint(address indexed sender, uint amount0, uint amount1);
 event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
 event Swap( address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to );
 event Sync(uint112 reserve0, uint112 reserve1);
 constructor() public {
 factory = msg.sender;
 }
 function initialize(address _token0, address _token1, address _router) external {
 require(msg.sender == factory, 'BabylonSwapV2: FORBIDDEN');
 token0 = _token0;
 token1 = _token1;
 router = _router;
 }
 function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
 require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'BabylonSwapV2: OVERFLOW');
 uint32 blockTimestamp = uint32(block.timestamp % 2**32);
 uint32 timeElapsed = blockTimestamp - blockTimestampLast;
 if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
 price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
 price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
 }
 reserve0 = uint112(balance0);
 reserve1 = uint112(balance1);
 blockTimestampLast = blockTimestamp;
 emit Sync(reserve0, reserve1);
 }
 function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
 address feeTo = IBabylonSwapV2Factory(factory).feeTo();
 feeOn = feeTo != address(0);
 uint _kLast = kLast;
 if (feeOn) {
 if (_kLast != 0) {
 uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
 uint rootKLast = Math.sqrt(_kLast);
 if (rootK > rootKLast) {
 uint numerator = totalSupply.mul(rootK.sub(rootKLast));
 uint denominator = rootK.mul(5).add(rootKLast);
 uint liquidity = numerator / denominator;
 if (liquidity > 0) _mint(feeTo, liquidity);
 }
 }
 }
 else if (_kLast != 0) {
 kLast = 0;
 }
 }
 function mint(address to) external lock returns (uint liquidity) {
 (uint112 _reserve0, uint112 _reserve1,) = getReserves();
 uint balance0 = IERC20(token0).balanceOf(address(this));
 uint balance1 = IERC20(token1).balanceOf(address(this));
 uint amount0 = balance0.sub(_reserve0);
 uint amount1 = balance1.sub(_reserve1);
 bool feeOn = _mintFee(_reserve0, _reserve1);
 uint _totalSupply = totalSupply;
 if (_totalSupply == 0) {
 liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
 _mint(address(0), MINIMUM_LIQUIDITY);
 }
 else {
 liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
 }
 require(liquidity > 0, 'BabylonSwapV2: INSUFFICIENT_LIQUIDITY_MINTED');
 if(IBabylonSwapV2Factory(factory).pause()== false){
 uint256 lockFee = liquidity.mul(IBabylonSwapV2Factory(factory).lockFee()).div(IBabylonSwapV2Factory(factory).PERCENT100());
 liquidity = liquidity.sub(lockFee);
 _mint(IBabylonSwapV2Factory(factory).DEADADDRESS(), lockFee);
 }
 _mint(to, liquidity);
 _update(balance0, balance1, _reserve0, _reserve1);
 if (feeOn) kLast = uint(reserve0).mul(reserve1);
 emit Mint(msg.sender, amount0, amount1);
 }
 event liq(uint256 ll);
 function burn(address to) external lock returns (uint amount0, uint amount1) {
 (uint112 _reserve0, uint112 _reserve1,) = getReserves();
 address _token0 = token0;
 address _token1 = token1;
 uint balance0 = IERC20(_token0).balanceOf(address(this));
 uint balance1 = IERC20(_token1).balanceOf(address(this));
 uint liquidity = balanceOf[address(this)];
 emit liq(liquidity);
 if(IBabylonSwapV2Factory(factory).pause() == false){
 uint256 _lockFee = (liquidity.mul(IBabylonSwapV2Factory(factory).lockFee()).div(IBabylonSwapV2Factory(factory).PERCENT100()));
 liquidity = liquidity.sub(_lockFee);
 _transfer(address(this), IBabylonSwapV2Factory(factory).DEADADDRESS(), _lockFee);
 }
 bool feeOn = _mintFee(_reserve0, _reserve1);
 uint _totalSupply = totalSupply;
 amount0 = liquidity.mul(balance0) / _totalSupply;
 amount1 = liquidity.mul(balance1) / _totalSupply;
 require(amount0 > 0 && amount1 > 0, 'BabylonSwapV2: INSUFFICIENT_LIQUIDITY_BURNED');
 _burn(address(this), liquidity);
 _safeTransfer(_token0, to, amount0);
 _safeTransfer(_token1, to, amount1);
 balance0 = IERC20(_token0).balanceOf(address(this));
 balance1 = IERC20(_token1).balanceOf(address(this));
 _update(balance0, balance1, _reserve0, _reserve1);
 if (feeOn) kLast = uint(reserve0).mul(reserve1);
 emit Burn(msg.sender, amount0, amount1, to);
 }
 function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {
 require(amount0Out > 0 || amount1Out > 0, 'BabylonSwapV2: INSUFFICIENT_OUTPUT_AMOUNT');
 (uint112 _reserve0, uint112 _reserve1,) = getReserves();
 require(amount0Out < _reserve0 && amount1Out < _reserve1, 'BabylonSwapV2: INSUFFICIENT_LIQUIDITY');
 uint balance0;
 uint balance1;
 {
 address _token0 = token0;
 address _token1 = token1;
 require(to != _token0 && to != _token1, 'BabylonSwapV2: INVALID_TO');
 if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out);
 if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out);
 if (data.length > 0) IBabylonSwapV2Callee(to).BabylonSwapV2Call(msg.sender, amount0Out, amount1Out, data);
 balance0 = IERC20(_token0).balanceOf(address(this));
 balance1 = IERC20(_token1).balanceOf(address(this));
 }
 uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
 uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
 require(amount0In > 0 || amount1In > 0, 'BabylonSwapV2: INSUFFICIENT_INPUT_AMOUNT');
 {
 uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
 uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
 require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), 'BabylonSwapV2: K');
 }
 _update(balance0, balance1, _reserve0, _reserve1);
 emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
 }
 function skim(address to) external lock {
 address _token0 = token0;
 address _token1 = token1;
 _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)).sub(reserve0));
 _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)).sub(reserve1));
 }
 function sync() external lock {
 _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
 }
 }
 contract BabylonSwapFactory is IBabylonSwapV2Factory {
 uint256 public override constant PERCENT100 = 1000000;
 address public override constant DEADADDRESS = 0x000000000000000000000000000000000000dEaD;
 address public override feeTo;
 address public override feeToSetter;
 address public router;
 address public override feeTransfer;
 uint256 public override lockFee = 2500;
 bool public override pause = false;
 mapping(address => mapping(address => address)) public override getPair;
 address[] public override allPairs;
 event PairCreated(address indexed token0, address indexed token1, address pair, uint);
 constructor(address _feeToSetter) public {
 require(_feeToSetter != address(0x000), "Zero address");
 feeToSetter = _feeToSetter;
 }
 function allPairsLength() external override view returns (uint) {
 return allPairs.length;
 }
 bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(BabylonSwapV2Pair).creationCode));
 function createPair(address tokenA, address tokenB) external override returns (address pair) {
 require(tokenA != tokenB, 'BabylonSwapV2: IDENTICAL_ADDRESSES');
 (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
 require(token0 != address(0), 'BabylonSwapV2: ZERO_ADDRESS');
 require(getPair[token0][token1] == address(0), 'BabylonSwapV2: PAIR_EXISTS');
 bytes memory bytecode = type(BabylonSwapV2Pair).creationCode;
 bytes32 salt = keccak256(abi.encodePacked(token0, token1));
 assembly {
 pair := create2(0, add(bytecode, 32), mload(bytecode), salt) }
 BabylonSwapV2Pair(pair).initialize(token0, token1, router);
 getPair[token0][token1] = pair;
 getPair[token1][token0] = pair;
 allPairs.push(pair);
 if(!pause){
 IFarm(BabylonSwapFeeTransfer(feeTransfer).farm()).addLPInfo(IERC20(pair), IERC20(tokenA), IERC20(tokenB));
 }
 emit PairCreated(token0, token1, pair, allPairs.length);
 }
 function setFeeToSetter(address _feeToSetter) external override {
 require(msg.sender == feeToSetter, 'BabylonSwapV2: FORBIDDEN');
 feeToSetter = _feeToSetter;
 }
 function pauseFee(bool _newStatus) external {
 require(msg.sender == feeToSetter, 'BabylonSwapV2: FORBIDDEN');
 require(_newStatus != pause, 'BabylonSwapV2: INVALID');
 pause = _newStatus;
 }
 function setRouter(address _router) public override {
 require(tx.origin == feeToSetter, 'BabylonSwapV2: FORBIDDEN');
 router = _router;
 }
 function setFeeTransfer(address _feeTransfer) public override {
 require(tx.origin == feeToSetter, 'BabylonSwapV2: FORBIDDEN');
 feeTransfer = _feeTransfer;
 }
 }
