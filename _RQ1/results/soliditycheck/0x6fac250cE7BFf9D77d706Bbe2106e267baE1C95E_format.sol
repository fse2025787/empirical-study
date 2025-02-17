   pragma solidity ^0.4.24;
 library SafeMath {
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
 if (a == 0) {
 return 0;
 }
 uint256 c = a * b;
 assert(c / a == b);
 return c;
 }
 function div(uint256 a, uint256 b) internal pure returns (uint256) {
 return a / b;
 }
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 assert(b <= a);
 return a - b;
 }
 function add(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a + b;
 assert(c >= a);
 return c;
 }
 }
 contract ERC20Basic {
 function totalSupply() public view returns (uint256);
 function balanceOf(address who) public view returns (uint256);
 function transfer(address to, uint256 value) public returns (bool);
 event Transfer(address indexed from, address indexed to, uint256 value);
 }
 contract BasicToken is ERC20Basic {
 using SafeMath for uint256;
 mapping(address => uint256) balances;
 uint256 totalSupply_;
 function totalSupply() public view returns (uint256) {
 return totalSupply_;
 }
 function transfer(address _to, uint256 _value) public returns (bool) {
 require(_to != address(0));
 require(_to != address(this));
 require(_value <= balances[msg.sender]);
 balances[msg.sender] = balances[msg.sender].sub(_value);
 balances[_to] = balances[_to].add(_value);
 emit Transfer(msg.sender, _to, _value);
 return true;
 }
 function balanceOf(address _owner) public view returns (uint256 balance) {
 return balances[_owner];
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
 function transferOwnership(address newOwner) public onlyOwner {
 require(newOwner != address(0));
 emit OwnershipTransferred(owner, newOwner);
 owner = newOwner;
 }
 }
 contract ERC20 is ERC20Basic {
 function allowance(address owner, address spender) public view returns (uint256);
 function transferFrom(address from, address to, uint256 value) public returns (bool);
 function approve(address spender, uint256 value) public returns (bool);
 event Approval(address indexed owner, address indexed spender, uint256 value);
 }
 contract StandardToken is ERC20, BasicToken {
 mapping (address => mapping (address => uint256)) internal allowed;
 function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
 require(_to != address(0));
 require(_to != address(this));
 require(_value <= balances[_from]);
 require(_value <= allowed[_from][msg.sender]);
 balances[_from] = balances[_from].sub(_value);
 balances[_to] = balances[_to].add(_value);
 allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
 emit Transfer(_from, _to, _value);
 return true;
 }
 function approve(address _spender, uint256 _value) public returns (bool) {
 allowed[msg.sender][_spender] = _value;
 emit Approval(msg.sender, _spender, _value);
 return true;
 }
 function allowance(address _owner, address _spender) public view returns (uint256) {
 return allowed[_owner][_spender];
 }
 function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
 allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
 emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
 return true;
 }
 function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
 uint256 oldValue = allowed[msg.sender][_spender];
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
 contract PausableToken is StandardToken, Ownable {
 event Pause();
 event Unpause();
 bool public paused = false;
 modifier whenNotPaused() {
 require(!paused);
 _;
 }
 modifier whenPaused() {
 require(paused);
 _;
 }
 function pause() onlyOwner whenNotPaused public {
 paused = true;
 emit Pause();
 }
 function unpause() onlyOwner whenPaused public {
 paused = false;
 emit Unpause();
 }
 function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
 return super.transfer(_to, _value);
 }
 function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
 return super.transferFrom(_from, _to, _value);
 }
 function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
 return super.approve(_spender, _value);
 }
 function increaseApproval(address _spender, uint256 _addedValue) public whenNotPaused returns (bool success) {
 return super.increaseApproval(_spender, _addedValue);
 }
 function decreaseApproval(address _spender, uint256 _subtractedValue) public whenNotPaused returns (bool success) {
 return super.decreaseApproval(_spender, _subtractedValue);
 }
 }
 contract AegisEconomyCoin is PausableToken {
 string public constant name = "Oriad Coin";
 string public constant symbol= "ORI";
 uint256 public constant decimals= 18;
 uint256 private constant initialSupply = 50*(10**6)* (10**18);
 uint256 private constant per15Period = 365 days;
 uint256 private constant per12Period = 365 days;
 uint256 private constant per10Period = 48 * 365 days;
 uint256 private inflationPeriodStart = now;
 uint256 private releasedTokens;
 uint256 private constant calcresolution = 10000000;
 constructor() public {
 paused = false;
 }
 function balanceOf(address _owner) public view returns (uint256) {
 if (_owner == owner) {
 return totalSupply() - releasedTokens;
 }
 else {
 return balances[_owner];
 }
 }
 function totalSupply() public view returns (uint256 _supply) {
 uint256 per15perMinute = (150*calcresolution /(365*24*60) * initialSupply) /(calcresolution*1000);
 uint256 per12perMinute = (125*calcresolution /(365*24*60) * initialSupply) /(calcresolution*1000);
 uint256 per10perMinute = (100*calcresolution /(365*24*60) * initialSupply) /(calcresolution*1000);
 uint secondsFromStart = now - inflationPeriodStart;
 uint minutesFromStart = secondsFromStart/60;
 uint256 currentTime = now;
 if (currentTime > inflationPeriodStart + per15Period + per12Period) {
 uint minutes10perPeriod = (currentTime - (inflationPeriodStart + per15Period + per12Period))/60;
 uint supply = initialSupply + minutes10perPeriod*per10perMinute + (per12Period*per12perMinute/60) + (per15Period*per15perMinute/60);
 }
 else if (currentTime > inflationPeriodStart + per15Period) {
 uint minutes12perPeriod = (currentTime - (inflationPeriodStart + per15Period))/60;
 supply = initialSupply + minutes12perPeriod*per12perMinute + (per15Period*per15perMinute/60);
 }
 else {
 uint minutes15perPeriod = (currentTime - inflationPeriodStart)/60;
 supply = initialSupply + minutes15perPeriod*per15perMinute;
 }
 return supply;
 }
 function transfer(address _to, uint256 _value) public whenNotPaused returns (bool success) {
 require(balanceOf(msg.sender) >= _value);
 if(msg.sender == owner) {
 releasedTokens = releasedTokens.add(_value);
 }
 else {
 balances[msg.sender] = balances[msg.sender].sub(_value);
 }
 if(_to == owner) {
 releasedTokens = releasedTokens.sub(_value);
 }
 else {
 balances[_to] = balances[_to].add(_value);
 }
 Transfer(msg.sender, _to, _value);
 return true;
 }
 function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool success) {
 require(balanceOf(_from) >= _value);
 require(_value <= allowed[_from][msg.sender]);
 if(_from == owner) {
 releasedTokens = releasedTokens.add(_value);
 }
 else {
 balances[_from] = balances[_from].sub(_value);
 }
 if(_to == owner) {
 releasedTokens = releasedTokens.sub(_value);
 }
 else {
 balances[_to] = balances[_to].add(_value);
 }
 allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
 Transfer(_from, _to, _value);
 return true;
 }
 }
