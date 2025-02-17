       pragma solidity ^0.6.0;
 library SafeMath {
 function add(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a + b;
 require(c >= a, "SafeMath: addition overflow");
 return c;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 return sub(a, b, "SafeMath: subtraction overflow");
 }
 function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
 function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b > 0, errorMessage);
 uint256 c = a / b;
 return c;
 }
 function mod(uint256 a, uint256 b) internal pure returns (uint256) {
 return mod(a, b, "SafeMath: modulo by zero");
 }
 function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
 require(b != 0, errorMessage);
 return a % b;
 }
 }
 contract ERC20 {
 using SafeMath for uint256;
 mapping (address => uint256) internal _balances;
 mapping (address => mapping (address => uint256)) internal _allowed;
 uint256 internal _totalSupply;
 function totalSupply() public view returns (uint256) {
 return _totalSupply;
 }
 function balanceOf(address owner) public view returns (uint256) {
 return _balances[owner];
 }
 function allowance(address owner, address spender) public view returns (uint256) {
 return _allowed[owner][spender];
 }
 function transfer(address to, uint256 value) public virtual returns (bool) {
 _transfer(msg.sender, to, value);
 return true;
 }
 function approve(address spender, uint256 value) public virtual returns (bool) {
 _approve(msg.sender, spender, value);
 return true;
 }
 function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
 _transfer(from, to, value);
 _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
 return true;
 }
 function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
 _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
 return true;
 }
 function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
 _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
 return true;
 }
 function _transfer(address from, address to, uint256 value) internal {
 require(to != address(0));
 _balances[from] = _balances[from].sub(value);
 _balances[to] = _balances[to].add(value);
 emit Transfer(from, to, value);
 }
 function _mint(address account, uint256 value) internal {
 require(account != address(0));
 _totalSupply = _totalSupply.add(value);
 _balances[account] = _balances[account].add(value);
 emit Transfer(address(0), account, value);
 }
 function _burn(address account, uint256 value) internal {
 require(account != address(0));
 _totalSupply = _totalSupply.sub(value);
 _balances[account] = _balances[account].sub(value);
 emit Transfer(account, address(0), value);
 }
 function _approve(address owner, address spender, uint256 value) internal {
 require(spender != address(0));
 require(owner != address(0));
 _allowed[owner][spender] = value;
 emit Approval(owner, spender, value);
 }
 function _burnFrom(address account, uint256 value) internal {
 _burn(account, value);
 _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
 }
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed owner, address indexed spender, uint256 value);
 }
 contract KonomiToken is ERC20 {
 string public constant name = "Konomi";
 uint8 public constant decimals = 18;
 string public constant symbol = "KONO";
 uint public constant supply = 100 * 10**6 * 10**uint(decimals);
 constructor() public {
 _mint(msg.sender, supply);
 }
 }
