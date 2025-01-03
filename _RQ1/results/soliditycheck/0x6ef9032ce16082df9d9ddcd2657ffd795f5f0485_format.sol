   pragma solidity ^0.4.18;
 contract SafeMath {
 function safeAdd(uint a, uint b) internal pure returns (uint c) {
 c = a + b;
 require(c >= a);
 }
 function safeSub(uint a, uint b) internal pure returns (uint c) {
 require(b <= a);
 c = a - b;
 }
 function safeMul(uint a, uint b) internal pure returns (uint c) {
 c = a * b;
 require(a == 0 || c / a == b);
 }
 function safeDiv(uint a, uint b) internal pure returns (uint c) {
 require(b > 0);
 c = a / b;
 }
 }
 contract ERC20Interface {
 function totalSupply() public constant returns (uint);
 function balanceOf(address tokenOwner) public constant returns (uint balance);
 function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
 function transfer(address to, uint tokens) public returns (bool success);
 function approve(address spender, uint tokens) public returns (bool success);
 function transferFrom(address from, address to, uint tokens) public returns (bool success);
 event Transfer(address indexed from, address indexed to, uint tokens);
 event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
 }
 contract ApproveAndCallFallBack {
 function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
 }
 contract Owned {
 address public owner;
 address public newOwner;
 event OwnershipTransferred(address indexed _from, address indexed _to);
 function Owned() public {
 owner = msg.sender;
 }
 modifier onlyOwner {
 require(msg.sender == owner);
 _;
 }
 function transferOwnership(address _newOwner) public onlyOwner {
 newOwner = _newOwner;
 }
 function acceptOwnership() public {
 require(msg.sender == newOwner);
 OwnershipTransferred(owner, newOwner);
 owner = newOwner;
 newOwner = address(0);
 }
 }
 contract SODIUMTOKEN is ERC20Interface, Owned, SafeMath {
 string public symbol;
 string public name;
 uint8 public decimals;
 uint public _totalSupply;
 uint public startDate;
 uint public bonusEnds;
 uint public endDate;
 mapping(address => uint) balances;
 mapping(address => mapping(address => uint)) allowed;
 function SODIUMTOKEN() public {
 symbol = "SODIUM";
 name = "SODIUM TOKEN";
 decimals = 18;
 _totalSupply = 30000000000000000000000000000;
 balances[0x78437f6724C41756619910e389B716EE00B0F1EA] = _totalSupply;
 Transfer(address(0), 0x8B877f7464818843908D289A458A58C87fAAA174, _totalSupply);
 bonusEnds = now + 4 weeks;
 endDate = now + 8 weeks;
 }
 function totalSupply() public constant returns (uint) {
 return _totalSupply - balances[address(0)];
 }
 function balanceOf(address tokenOwner) public constant returns (uint balance) {
 return balances[tokenOwner];
 }
 function transfer(address to, uint tokens) public returns (bool success) {
 balances[msg.sender] = safeSub(balances[msg.sender], tokens);
 balances[to] = safeAdd(balances[to], tokens);
 Transfer(msg.sender, to, tokens);
 return true;
 }
 function approve(address spender, uint tokens) public returns (bool success) {
 allowed[msg.sender][spender] = tokens;
 Approval(msg.sender, spender, tokens);
 return true;
 }
 function transferFrom(address from, address to, uint tokens) public returns (bool success) {
 balances[from] = safeSub(balances[from], tokens);
 allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
 balances[to] = safeAdd(balances[to], tokens);
 Transfer(from, to, tokens);
 return true;
 }
 function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
 return allowed[tokenOwner][spender];
 }
 function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
 allowed[msg.sender][spender] = tokens;
 Approval(msg.sender, spender, tokens);
 ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
 return true;
 }
 function () public payable {
 require(now >= startDate && now <= endDate);
 uint tokens;
 if (now <= bonusEnds) {
 tokens = msg.value * 22000000;
 }
 else {
 tokens = msg.value * 20000000;
 }
 balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
 _totalSupply = safeAdd(_totalSupply, tokens);
 Transfer(address(0), msg.sender, tokens);
 owner.transfer(msg.value);
 }
 function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
 return ERC20Interface(tokenAddress).transfer(owner, tokens);
 }
 }
