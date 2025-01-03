     pragma solidity ^0.4.4;
 library SafeMath {
 function add(uint a, uint b) internal pure returns (uint c) {
 c = a + b;
 require(c >= a);
 }
 function sub(uint a, uint b) internal pure returns (uint c) {
 require(b <= a);
 c = a - b;
 }
 function mul(uint a, uint b) internal pure returns (uint c) {
 c = a * b;
 require(a == 0 || c / a == b);
 }
 function div(uint a, uint b) internal pure returns (uint c) {
 require(b > 0);
 c = a / b;
 }
 }
 contract ERC20Interface {
 function balanceOf(address tokenOwner) public view returns (uint balance);
 function allowance(address tokenOwner, address spender) public view returns (uint remaining);
 function transfer(address to, uint tokens) public returns (bool success);
 function approve(address spender, uint tokens) public returns (bool success);
 function transferFrom(address from, address to, uint tokens) public returns (bool success);
 event Transfer(address indexed from, address indexed to, uint tokens);
 event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
 }
 interface tokenRecipient {
 function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
 }
 contract Owned {
 address public owner;
 address public newOwner;
 event OwnershipTransferred(address indexed _from, address indexed _to);
 constructor() public {
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
 emit OwnershipTransferred(owner, newOwner);
 owner = newOwner;
 newOwner = address(0);
 }
 }
 contract PayFoToken is ERC20Interface, Owned {
 using SafeMath for uint;
 string public symbol;
 string public name;
 uint8 public decimals;
 uint public totalSupply;
 mapping(address => uint) balances;
 mapping(address => mapping(address => uint)) allowed;
 constructor(string _symbol, string _name, uint8 _decimals, uint _totalSupply ) public {
 symbol = _symbol;
 name = _name;
 decimals = _decimals;
 totalSupply = _totalSupply * 10**uint(_decimals);
 balances[owner] = _totalSupply;
 emit Transfer(address(0), owner, totalSupply);
 }
 function balanceOf(address tokenOwner) public view returns (uint balance) {
 return balances[tokenOwner];
 }
 function transfer(address to, uint tokens) public returns (bool success) {
 balances[msg.sender] = balances[msg.sender].sub(tokens);
 balances[to] = balances[to].add(tokens);
 emit Transfer(msg.sender, to, tokens);
 return true;
 }
 function approve(address spender, uint tokens) public returns (bool success) {
 allowed[msg.sender][spender] = tokens;
 emit Approval(msg.sender, spender, tokens);
 return true;
 }
 function transferFrom(address from, address to, uint tokens) public returns (bool success) {
 balances[from] = balances[from].sub(tokens);
 allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
 balances[to] = balances[to].add(tokens);
 emit Transfer(from, to, tokens);
 return true;
 }
 function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
 return allowed[tokenOwner][spender];
 }
 function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
 tokenRecipient spender = tokenRecipient(_spender);
 if (approve(_spender, _value)) {
 spender.receiveApproval(msg.sender, _value, this, _extraData);
 return true;
 }
 }
 function () public payable {
 revert();
 }
 function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
 return ERC20Interface(tokenAddress).transfer(owner, tokens);
 }
 function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
 allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
 emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
 return true;
 }
 function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
 uint oldValue = allowed[msg.sender][_spender];
 if (_subtractedValue > oldValue) {
 allowed[msg.sender][_spender] = 0;
 }
 else {
 allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
 }
 emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
 return true;
 }
 }
