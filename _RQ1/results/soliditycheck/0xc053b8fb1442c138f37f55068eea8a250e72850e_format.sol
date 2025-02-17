   pragma solidity ^0.4.18;
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
 contract MetamToken is ERC20Interface{
 string public symbol;
 string public name;
 uint8 public decimals;
 uint public _totalSupply;
 mapping(address => uint) balances;
 mapping(address => mapping(address => uint)) allowed;
 constructor() public {
 symbol = "MTMX";
 name = "Metam";
 decimals = 4;
 _totalSupply = 1000000000000;
 balances[0x5A86f0cafD4ef3ba4f0344C138afcC84bd1ED222] = _totalSupply;
 emit Transfer(address(0), 0x5A86f0cafD4ef3ba4f0344C138afcC84bd1ED222, _totalSupply);
 }
 function totalSupply() public constant returns (uint) {
 return _totalSupply - balances[address(0)];
 }
 function balanceOf(address tokenOwner) public constant returns (uint balance) {
 return balances[tokenOwner];
 }
 function transfer(address to, uint tokens) public returns (bool success) {
 balances[msg.sender] = balances[msg.sender] - tokens;
 balances[to] = balances[to] + tokens;
 emit Transfer(msg.sender, to, tokens);
 return true;
 }
 function approve(address spender, uint tokens) public returns (bool success) {
 allowed[msg.sender][spender] = tokens;
 emit Approval(msg.sender, spender, tokens);
 return true;
 }
 function transferFrom(address from, address to, uint tokens) public returns (bool success) {
 balances[from] = balances[from] - tokens;
 allowed[from][msg.sender] = allowed[from][msg.sender] - tokens;
 balances[to] = balances[to] + tokens;
 emit Transfer(from, to, tokens);
 return true;
 }
 function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
 return allowed[tokenOwner][spender];
 }
 function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
 allowed[msg.sender][spender] = tokens;
 emit Approval(msg.sender, spender, tokens);
 ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
 return true;
 }
 function () public payable {
 revert();
 }
 }
