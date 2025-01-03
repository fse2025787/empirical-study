          pragma solidity >=0.4.24 <0.8.0;
 abstract contract Initializable {
 bool private _initialized;
 bool private _initializing;
 modifier initializer() {
 require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");
 bool isTopLevelCall = !_initializing;
 if (isTopLevelCall) {
 _initializing = true;
 _initialized = true;
 }
 _;
 if (isTopLevelCall) {
 _initializing = false;
 }
 }
 function _isConstructor() private view returns (bool) {
 return !AddressUpgradeable.isContract(address(this));
 }
 }
 pragma solidity >=0.6.0 <0.8.0;
 interface IERC20Upgradeable {
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
 abstract contract ContextUpgradeable is Initializable {
 function __Context_init() internal initializer {
 __Context_init_unchained();
 }
 function __Context_init_unchained() internal initializer {
 }
 function _msgSender() internal view virtual returns (address payable) {
 return msg.sender;
 }
 function _msgData() internal view virtual returns (bytes memory) {
 this;
 return msg.data;
 }
 uint256[50] private __gap;
 }
 pragma solidity >=0.4.22 <0.9.0;
 interface IToken {
 function uniswapPairAddress() external view returns (address);
 function setUniswapPair(address _uniswapPair) external;
 function burnDistributorTokensAndUnlock() external;
 }
 pragma solidity >=0.6.0 <0.8.0;
 contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {
 using SafeMathUpgradeable for uint256;
 mapping (address => uint256) private _balances;
 mapping (address => mapping (address => uint256)) private _allowances;
 uint256 private _totalSupply;
 string private _name;
 string private _symbol;
 uint8 private _decimals;
 function __ERC20_init(string memory name_, string memory symbol_) internal initializer {
 __Context_init_unchained();
 __ERC20_init_unchained(name_, symbol_);
 }
 function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {
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
 uint256[44] private __gap;
 }
 pragma solidity >=0.4.22 <0.9.0;
 contract Token is ERC20Upgradeable, IToken {
 uint256 public constant BURN_PERCENT = 5;
 address private distributor;
 address private treasury;
 address private transferLimiter;
 address private uniswapPair;
 bool private isLocked;
 mapping(address => bool) nonBurnableSenders;
 mapping(address => bool) nonBurnableRecipients;
 function initialize( string memory _name, string memory _symbol, address _distributor, address _treasury, address _transferLimiter, address _rcFarm, address _rcEthFarm ) public initializer {
 __Token_init(_name, _symbol, _distributor, _treasury, _transferLimiter, _rcFarm, _rcEthFarm);
 }
 function __Token_init( string memory _name, string memory _symbol, address _distributor, address _treasury, address _transferLimiter, address _rcFarm, address _rcEthFarm ) internal initializer {
 __Context_init_unchained();
 __ERC20_init_unchained(_name, _symbol);
 __Token_init_unchained(_distributor, _treasury, _transferLimiter, _rcFarm, _rcEthFarm);
 }
 function __Token_init_unchained( address _distributor, address _treasury, address _transferLimiter, address _rcFarm, address _rcEthFarm ) internal initializer {
 distributor = _distributor;
 treasury = _treasury;
 transferLimiter = _transferLimiter;
 isLocked = true;
 nonBurnableSenders[_distributor] = true;
 nonBurnableRecipients[_distributor] = true;
 nonBurnableSenders[_treasury] = true;
 nonBurnableRecipients[_treasury] = true;
 nonBurnableSenders[_rcFarm] = true;
 nonBurnableRecipients[_rcFarm] = true;
 nonBurnableSenders[_rcEthFarm] = true;
 nonBurnableRecipients[_rcEthFarm] = true;
 uint256 mintAmount = ITokenDistributor(distributor).getMaxSupply();
 _mint(distributor, mintAmount);
 }
 modifier tokensTransferable(address _from, address _to) {
 require(!isLocked || _from == distributor || _to == distributor, "Tokens are not transferable.");
 _;
 }
 modifier transferableAmount(address _to, uint256 _amount) {
 if (_to == uniswapPair) {
 uint256 transferLimitPerETH = ITransferLimiter(transferLimiter).getTransferLimitPerETH();
 if (transferLimitPerETH > 0) {
 uint256 transferLimit = transferLimitPerETH.div(2);
 require(_amount <= transferLimit, "Transfer amount is too big.");
 }
 }
 _;
 }
 modifier onlyDistributor() {
 require(msg.sender == distributor, "Only distributor allowed.");
 _;
 }
 modifier uniswapPairNotSet() {
 require(uniswapPair == address(0), "Uniswap pair is already set.");
 _;
 }
 function uniswapPairAddress() external view override returns (address) {
 return uniswapPair;
 }
 function setUniswapPair(address _uniswapPair) external override uniswapPairNotSet {
 uniswapPair = _uniswapPair;
 nonBurnableSenders[uniswapPair] = true;
 }
 function burnDistributorTokensAndUnlock() external override onlyDistributor {
 uint256 burnAmount = balanceOf(distributor);
 _burn(distributor, burnAmount);
 isLocked = false;
 }
 function _beforeTokenTransfer( address from, address to, uint256 amount ) internal virtual override tokensTransferable(from, to) transferableAmount(to, amount) {
 super._beforeTokenTransfer(from, to, amount);
 }
 function _transfer( address sender, address recipient, uint256 amount ) internal virtual override {
 bool shouldBurnTokens = !nonBurnableSenders[sender] && !nonBurnableRecipients[recipient];
 if (shouldBurnTokens) {
 uint256 burnAmount = amount.mul(BURN_PERCENT).div(100);
 super._transfer(sender, treasury, burnAmount);
 amount = amount.sub(burnAmount);
 }
 super._transfer(sender, recipient, amount);
 }
 uint256[43] private __gap;
 }
 pragma solidity >=0.4.22 <0.9.0;
 interface ITokenDistributor {
 function getMaxSupply() external view returns (uint256);
 }
 pragma solidity >=0.4.22 <0.9.0;
 interface ITransferLimiter {
 function getTransferLimitPerETH() external view returns (uint256);
 }
 pragma solidity >=0.6.0 <0.8.0;
 library SafeMathUpgradeable {
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
 pragma solidity >=0.6.2 <0.8.0;
 library AddressUpgradeable {
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
