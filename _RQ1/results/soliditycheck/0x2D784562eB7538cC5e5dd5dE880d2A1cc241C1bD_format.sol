   pragma solidity ^0.4.18;
 contract owned {
 address public owner;
 constructor() public {
 owner = msg.sender;
 }
 modifier onlyOwner {
 require(msg.sender == owner);
 _;
 }
 function transferOwnership(address newOwner) onlyOwner public {
 owner = newOwner;
 }
 }
 interface tokenRecipient {
 function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
 }
 contract Token {
 string public name;
 string public symbol;
 string public author = 'GMMGHoldings: DobroCoin (ByVitiook) v 1.1';
 uint8 public decimals = 8;
 uint256 public totalSupply;
 mapping (address => uint256) public balanceOf;
 mapping (address => mapping (address => uint256)) public allowance;
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 event Burn(address indexed from, uint256 value);
 constructor( uint256 initialSupply, string tokenName, string tokenSymbol, string tokenAuthor ) public {
 totalSupply = initialSupply * 10 ** uint256(decimals);
 balanceOf[msg.sender] = totalSupply;
 name = tokenName;
 symbol = tokenSymbol;
 author = tokenAuthor;
 }
 function _transfer(address _from, address _to, uint _value) internal {
 require(_to != 0x0);
 require(balanceOf[_from] >= _value);
 require(balanceOf[_to] + _value > balanceOf[_to]);
 uint previousBalances = balanceOf[_from] + balanceOf[_to];
 balanceOf[_from] -= _value;
 balanceOf[_to] += _value;
 emit Transfer(_from, _to, _value);
 assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
 }
 function transfer(address _to, uint256 _value) public returns (bool success) {
 _transfer(msg.sender, _to, _value);
 return true;
 }
 function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
 require(_value <= allowance[_from][msg.sender]);
 allowance[_from][msg.sender] -= _value;
 _transfer(_from, _to, _value);
 return true;
 }
 function approve(address _spender, uint256 _value) public returns (bool success) {
 allowance[msg.sender][_spender] = _value;
 emit Approval(msg.sender, _spender, _value);
 return true;
 }
 function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
 tokenRecipient spender = tokenRecipient(_spender);
 if (approve(_spender, _value)) {
 spender.receiveApproval(msg.sender, _value, this, _extraData);
 return true;
 }
 }
 }
 contract DobrocoinContract is owned, Token {
 uint256 public sellPrice;
 uint256 public buyPrice;
 uint256 public AutoBuy = 1;
 uint256 public AutoSell = 1;
 address[] public ReservedAddress;
 mapping (address => bool) public frozenAccount;
 event FrozenFunds(address target, bool frozen);
 constructor( uint256 initialSupply, string tokenName, string tokenSymbol, string tokenAuthor ) Token(initialSupply, tokenName, tokenSymbol, tokenAuthor) public {
 }
 function _transfer(address _from, address _to, uint _value) internal {
 require (_to != 0x0);
 require (balanceOf[_from] >= _value);
 require (balanceOf[_to] + _value >= balanceOf[_to]);
 require(!frozenAccount[_from]);
 require(!frozenAccount[_to]);
 balanceOf[_from] -= _value;
 balanceOf[_to] += _value;
 emit Transfer(_from, _to, _value);
 }
 function mintToken(address target, uint256 mintedAmount) onlyOwner public {
 balanceOf[target] += mintedAmount;
 totalSupply += mintedAmount;
 emit Transfer(0, this, mintedAmount);
 emit Transfer(this, target, mintedAmount);
 }
 function freezeAccount(address target, bool freeze) onlyOwner public {
 frozenAccount[target] = freeze;
 emit FrozenFunds(target, freeze);
 }
 function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
 sellPrice = newSellPrice;
 buyPrice = newBuyPrice;
 }
 function burn(uint256 _value) public returns (bool success) {
 require(balanceOf[msg.sender] >= _value);
 balanceOf[msg.sender] -= _value;
 totalSupply -= _value;
 emit Burn(msg.sender, _value);
 return true;
 }
 function burnFrom(address _from, uint256 _value) public returns (bool success) {
 require(balanceOf[_from] >= _value);
 require(_value <= allowance[_from][msg.sender]);
 balanceOf[_from] -= _value;
 allowance[_from][msg.sender] -= _value;
 totalSupply -= _value;
 emit Burn(_from, _value);
 return true;
 }
 function setAutoBuy(uint256 newAutoBuy) onlyOwner public {
 AutoBuy = newAutoBuy;
 }
 function setName(string newName) onlyOwner public {
 name = newName;
 }
 function setAuthor(string newAuthor) onlyOwner public {
 author = newAuthor;
 }
 function setAutoSell(uint256 newAutoSell) onlyOwner public {
 AutoSell = newAutoSell;
 }
 function buy() payable public {
 if(AutoBuy > 0) {
 uint amount = msg.value / buyPrice;
 _transfer(this, msg.sender, amount);
 }
 }
 function sell(uint256 amount) public {
 if(AutoSell > 0){
 address myAddress = this;
 require(myAddress.balance >= amount * sellPrice);
 _transfer(msg.sender, this, amount);
 msg.sender.transfer(amount * sellPrice);
 }
 }
 }
