   pragma solidity ^0.4.18;
 contract owned {
 address public owner;
 constructor() owned() internal {
 owner = msg.sender;
 }
 modifier onlyOwner {
 require(msg.sender == owner);
 _;
 }
 function transferOwnership(address newOwner) onlyOwner internal {
 owner = newOwner;
 }
 }
 interface tokenRecipient {
 function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
 }
 contract GOAToken is owned {
 string public name;
 string public symbol;
 uint8 public decimals;
 mapping (address => uint256) public balanceOf;
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 event Burn(address indexed from, uint256 value);
 constructor(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits) public {
 balanceOf[msg.sender] = initialSupply;
 name = tokenName;
 symbol = tokenSymbol;
 decimals = decimalUnits;
 }
 function transfer(address _to, uint256 _value) public {
 require(balanceOf[msg.sender] >= _value && balanceOf[_to] + _value >= balanceOf[_to]);
 balanceOf[msg.sender] -= _value;
 balanceOf[_to] += _value;
 emit Transfer(msg.sender, _to, _value);
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
 }
