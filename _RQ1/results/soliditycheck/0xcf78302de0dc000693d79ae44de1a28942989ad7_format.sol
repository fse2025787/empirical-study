   pragma solidity ^0.4.11;
 library SafeMath {
 function mul(uint a, uint b) internal returns (uint) {
 uint c = a * b;
 assert(a == 0 || c / a == b);
 return c;
 }
 function div(uint a, uint b) internal returns (uint) {
 uint c = a / b;
 return c;
 }
 function sub(uint a, uint b) internal returns (uint) {
 assert(b <= a);
 return a - b;
 }
 function add(uint a, uint b) internal returns (uint) {
 uint c = a + b;
 assert(c >= a);
 return c;
 }
 function max64(uint64 a, uint64 b) internal constant returns (uint64) {
 return a >= b ? a : b;
 }
 function min64(uint64 a, uint64 b) internal constant returns (uint64) {
 return a < b ? a : b;
 }
 function max256(uint256 a, uint256 b) internal constant returns (uint256) {
 return a >= b ? a : b;
 }
 function min256(uint256 a, uint256 b) internal constant returns (uint256) {
 return a < b ? a : b;
 }
 function assert(bool assertion) internal {
 if (!assertion) {
 throw;
 }
 }
 }
 contract ERC20Basic {
 uint public totalSupply;
 function balanceOf(address who) constant returns (uint);
 function transfer(address to, uint value);
 event Transfer(address indexed from, address indexed to, uint value);
 }
 contract BasicToken is ERC20Basic {
 using SafeMath for uint;
 mapping(address => uint) balances;
 modifier onlyPayloadSize(uint size) {
 if(msg.data.length < size + 4) {
 throw;
 }
 _;
 }
 function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
 balances[msg.sender] = balances[msg.sender].sub(_value);
 balances[_to] = balances[_to].add(_value);
 Transfer(msg.sender, _to, _value);
 }
 function balanceOf(address _owner) constant returns (uint balance) {
 return balances[_owner];
 }
 }
 contract ERC20 is ERC20Basic {
 function allowance(address owner, address spender) constant returns (uint);
 function transferFrom(address from, address to, uint value);
 function approve(address spender, uint value);
 event Approval(address indexed owner, address indexed spender, uint value);
 }
 contract StandardToken is BasicToken, ERC20 {
 mapping (address => mapping (address => uint)) allowed;
 function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) {
 var _allowance = allowed[_from][msg.sender];
 balances[_to] = balances[_to].add(_value);
 balances[_from] = balances[_from].sub(_value);
 allowed[_from][msg.sender] = _allowance.sub(_value);
 Transfer(_from, _to, _value);
 }
 function approve(address _spender, uint _value) {
 if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;
 allowed[msg.sender][_spender] = _value;
 Approval(msg.sender, _spender, _value);
 }
 function allowance(address _owner, address _spender) constant returns (uint remaining) {
 return allowed[_owner][_spender];
 }
 }
 contract Ownable {
 address public owner;
 function Ownable() {
 owner = msg.sender;
 }
 modifier onlyOwner() {
 if (msg.sender != owner) {
 throw;
 }
 _;
 }
 function transferOwnership(address newOwner) onlyOwner {
 if (newOwner != address(0)) {
 owner = newOwner;
 }
 }
 }
 contract PayaToken is StandardToken, Ownable {
 event Paya(address indexed to, uint value);
 event PayaFinished();
 bool public payaFinished = false;
 uint public totalSupply = 0;
 modifier canPaya() {
 if(payaFinished) throw;
 _;
 }
 function mint(address _to, uint _amount) onlyOwner canPaya returns (bool) {
 totalSupply = totalSupply.add(_amount);
 balances[_to] = balances[_to].add(_amount);
 Paya(_to, _amount);
 return true;
 }
 function finishPayaning() onlyOwner returns (bool) {
 payaFinished = true;
 PayaFinished();
 return true;
 }
 }
 contract Pausable is Ownable {
 event Pause();
 event Unpause();
 bool public paused = false;
 modifier whenNotPaused() {
 if (paused) throw;
 _;
 }
 modifier whenPaused {
 if (!paused) throw;
 _;
 }
 function pause() onlyOwner whenNotPaused returns (bool) {
 paused = true;
 Pause();
 return true;
 }
 function unpause() onlyOwner whenPaused returns (bool) {
 paused = false;
 Unpause();
 return true;
 }
 }
 contract PausableToken is StandardToken, Pausable {
 function transfer(address _to, uint _value) whenNotPaused {
 super.transfer(_to, _value);
 }
 function transferFrom(address _from, address _to, uint _value) whenNotPaused {
 super.transferFrom(_from, _to, _value);
 }
 }
 contract TokenTimelock {
 ERC20Basic token;
 address beneficiary;
 uint releaseTime;
 function TokenTimelock(ERC20Basic _token, address _beneficiary, uint _releaseTime) {
 require(_releaseTime > now);
 token = _token;
 beneficiary = _beneficiary;
 releaseTime = _releaseTime;
 }
 function claim() {
 require(msg.sender == beneficiary);
 require(now >= releaseTime);
 uint amount = token.balanceOf(this);
 require(amount > 0);
 token.transfer(beneficiary, amount);
 }
 }
 contract PAYA is PausableToken, PayaToken {
 using SafeMath for uint256;
 string public name = "PAYA";
 string public symbol = "PAYA";
 uint public decimals = 9;
 string public version = 'H1.0';
 function () {
 throw;
 }
 function PAYA( ) {
 balances[msg.sender] = 21000000000000000000;
 totalSupply = 21000000000000000000;
 }
 function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
 allowed[msg.sender][_spender] = _value;
 Approval(msg.sender, _spender, _value);
 if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) {
 throw;
 }
 return true;
 }
 }
