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
 pragma solidity 0.6.12;
 contract SuniBar is ERC20("SuniBar", "xSuni"){
 using SafeMath for uint256;
 IERC20 public SUWP;
 constructor(IERC20 _suwp) public {
 SUWP = _suwp;
 }
 function enter(uint256 _amount) public {
 uint256 totalSuwp = SUWP.balanceOf(address(this));
 uint256 totalShares = totalSupply();
 if (totalShares == 0 || totalSuwp == 0) {
 _mint(msg.sender, _amount);
 }
 else {
 uint256 what = _amount.mul(totalShares).div(totalSuwp);
 _mint(msg.sender, what);
 }
 SUWP.transferFrom(msg.sender, address(this), _amount);
 }
 function leave(uint256 _share) public {
 uint256 totalShares = totalSupply();
 uint256 what = _share.mul(SUWP.balanceOf(address(this))).div(totalShares);
 _burn(msg.sender, _share);
 SUWP.transfer(msg.sender, what);
 }
 }
