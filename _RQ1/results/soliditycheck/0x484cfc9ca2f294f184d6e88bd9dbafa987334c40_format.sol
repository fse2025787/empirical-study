       pragma solidity ^0.5.0;
 contract ERC20Interface {
 function totalSupply() public view returns (uint);
 function balanceOf(address tokenOwner) public view returns (uint balance);
 function allowance(address tokenOwner, address spender) public view returns (uint remaining);
 function transfer(address to, uint tokens) public returns (bool success);
 function approve(address spender, uint tokens) public returns (bool success);
 function transferFrom(address from, address to, uint tokens) public returns (bool success);
 event Transfer(address indexed from, address indexed to, uint tokens);
 event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
 }
 contract SafeMath {
 function safeAdd(uint a, uint b) public pure returns (uint c) {
 c = a + b;
 require(c >= a);
 }
 function safeSub(uint a, uint b) public pure returns (uint c) {
 require(b <= a);
 c = a - b;
 }
 function safeMul(uint a, uint b) public pure returns (uint c) {
 c = a * b;
 require(a == 0 || c / a == b);
 }
 function safeDiv(uint a, uint b) public pure returns (uint c) {
 require(b > 0);
 c = a / b;
 }
 }
 contract Ownable {
 address public owner;
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 constructor() public {
 owner = msg.sender;
 }
 modifier onlyOwner() {
 require(msg.sender == owner);
 _;
 }
 function transferOwnership(address newOwner) onlyOwner public {
 require(newOwner != address(0));
 emit OwnershipTransferred(owner, newOwner);
 owner = newOwner;
 }
 }
 contract TPStone is ERC20Interface, SafeMath, Ownable {
 string public name;
 string public symbol;
 uint8 public decimals;
 uint256 public _totalSupply;
 mapping(address => uint) balances;
 mapping(address => mapping(address => uint)) allowed;
 constructor() public {
 name = "Trade Precious Stone";
 symbol = "TPStone";
 decimals = 6;
 _totalSupply = 100000000;
 balances[msg.sender] = _totalSupply;
 emit Transfer(address(0), msg.sender, _totalSupply);
 }
 function totalSupply() public view returns (uint) {
 return _totalSupply - balances[address(0)];
 }
 function balanceOf(address tokenOwner) public view returns (uint balance) {
 return balances[tokenOwner];
 }
 function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
 return allowed[tokenOwner][spender];
 }
 function approve(address spender, uint tokens) public returns (bool success) {
 allowed[msg.sender][spender] = tokens;
 emit Approval(msg.sender, spender, tokens);
 return true;
 }
 function transfer(address to, uint tokens) public returns (bool success) {
 if(balances[msg.sender] >= tokens) {
 balances[msg.sender] = safeSub(balances[msg.sender], tokens);
 balances[to] = safeAdd(balances[to], tokens);
 emit Transfer(msg.sender, to, tokens);
 return true;
 }
 else {
 return false;
 }
 }
 function transferFrom(address from, address to, uint tokens) public returns (bool success) {
 if(balances[from] >= tokens) {
 balances[from] = safeSub(balances[from], tokens);
 allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
 balances[to] = safeAdd(balances[to], tokens);
 emit Transfer(from, to, tokens);
 return true;
 }
 else {
 return false;
 }
 }
 function mint(address account, uint256 amount) public onlyOwner {
 require(account != address(0), "ERC20: mint to the zero address");
 _totalSupply = safeAdd(_totalSupply, amount);
 balances[account] = safeAdd(balances[account], amount);
 emit Transfer(address(0), account, amount);
 }
 }
