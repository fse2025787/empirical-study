           pragma solidity ^0.5.12;
 library SafeMath {
 function add(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a + b;
 require(c >= a, "SafeMath: addition overflow");
 return c;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 require(b <= a, "SafeMath: subtraction overflow");
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
 require(b > 0, "SafeMath: division by zero");
 uint256 c = a / b;
 return c;
 }
 }
 contract Context {
 function _msgSender() internal view returns (address payable) {
 return msg.sender;
 }
 function _msgData() internal view returns (bytes memory) {
 this;
 return msg.data;
 }
 }
 contract owned {
 address public owner;
 constructor() public {
 owner = msg.sender;
 }
 modifier onlyOwner {
 require(msg.sender == owner, "owner calls only!");
 _;
 }
 function setOwner(address _add) public onlyOwner{
 owner = _add;
 }
 }
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
 contract ERC20 is Context, IERC20,owned {
 using SafeMath for uint256;
 mapping (address => uint256) private _balances;
 mapping (address => mapping (address => uint256)) private _allowances;
 uint256 private _totalSupply;
 string private _name;
 string private _symbol;
 uint8 private _decimals;
 constructor (string memory name, string memory symbol, uint256 valueFounder, uint8 decimals) public {
 _name = name;
 _symbol = symbol;
 _decimals = decimals;
 _mint(msg.sender, valueFounder * 10 ** uint256(decimals));
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
 function totalSupply() public view returns (uint256) {
 return _totalSupply;
 }
 function balanceOf(address account) public view returns (uint256) {
 return _balances[account];
 }
 function transfer(address recipient, uint256 amount) public returns (bool) {
 _transfer(_msgSender(), recipient, amount);
 return true;
 }
 function allowance(address owner, address spender) public view returns (uint256) {
 return _allowances[owner][spender];
 }
 function approve(address spender, uint256 amount) public returns (bool) {
 _approve(_msgSender(), spender, amount);
 return true;
 }
 function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
 _transfer(sender, recipient, amount);
 _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
 return true;
 }
 function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
 _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
 return true;
 }
 function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
 _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue));
 return true;
 }
 function _transfer(address sender, address recipient, uint256 amount) internal {
 require(sender != address(0), "ERC20: transfer from the zero address");
 require(recipient != address(0), "ERC20: transfer to the zero address");
 _beforeTokenTransfer(sender, recipient, amount);
 _balances[sender] = _balances[sender].sub(amount);
 _balances[recipient] = _balances[recipient].add(amount);
 emit Transfer(sender, recipient, amount);
 }
 function _mint(address account, uint256 amount) internal {
 require(account != address(0), "ERC20: mint to the zero address");
 _beforeTokenTransfer(address(0), account, amount);
 _totalSupply = _totalSupply.add(amount);
 _balances[account] = _balances[account].add(amount);
 emit Transfer(address(0), account, amount);
 }
 function _burn(address account, uint256 amount) internal {
 require(account != address(0), "ERC20: burn from the zero address");
 _beforeTokenTransfer(account, address(0), amount);
 _balances[account] = _balances[account].sub(amount);
 _totalSupply = _totalSupply.sub(amount);
 emit Transfer(account, address(0), amount);
 }
 function _approve(address owner, address spender, uint256 amount) internal {
 require(owner != address(0), "ERC20: approve from the zero address");
 require(spender != address(0), "ERC20: approve to the zero address");
 _allowances[owner][spender] = amount;
 emit Approval(owner, spender, amount);
 }
 function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
 }
 }
