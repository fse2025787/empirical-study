
pragma solidity ^0.4.24;
/**
 * Math operations with safety checks
 */
contract SafeMath {

	function safeMul(uint256 a, uint256 b) pure internal returns (uint256) {
		uint256 c = a * b;
		judgement(a == 0 || c / a == b);
		return c;
	}

	function safeDiv(uint256 a, uint256 b) pure internal returns (uint256) {
		judgement(b > 0);
		uint256 c = a / b;
		judgement(a == b * c + a % b);
		return c;
	}

	function safeSub(uint256 a, uint256 b) pure internal returns (uint256) {
		judgement(b <= a);
		return a - b;
	}

	function safeAdd(uint256 a, uint256 b) pure internal returns (uint256) {
		uint256 c = a + b;
		judgement(c>=a && c>=b);
		return c;
	}
	function safeMulWithPresent(uint256 a , uint256 b) pure internal returns (uint256){
		uint256 c = safeDiv(safeMul(a,b),1000);
		judgement(b == (c*1000)/a);
		return c;
	}
	function judgement(bool assertion) pure internal {
		if (!assertion) {
			revert();
		}
	}
}
contract HCBPerm{
	address public owner;
	constructor () public{
		owner = msg.sender;
	}
	event LogOwnerChanged (address msgSender );

	///notice check if the msgSender is owner
	modifier onlyOwner{
		assert(msg.sender == owner);
		_;
	}

	function setOwner (address newOwner) public onlyOwner returns (bool){
		if (owner == msg.sender){
			owner = newOwner;
			emit LogOwnerChanged(msg.sender);
			return true;
		}else{
			return false;
		}
	}

}
contract HCBFreeze is HCBPerm{
	bool internal stopped = false;

	modifier stoppable {
		assert (!stopped);
		_;
	}

	function status() view public returns (bool){
		return stopped;
	}
	//freeze all env
	function stop() public onlyOwner{
		stopped = true;
	}
	//unfreeze
	function start() public onlyOwner{
		stopped = false;
	}

}
contract Token is SafeMath {
	/*
		Basic ERC20 token
	*/
	uint256 public totalSupply;                                 /// total amount of tokens
	
	
	function balanceOf(address _owner) public view returns (uint256 balance);

	
	
	
	
	function transfer(address _to, uint256 _value) public returns (bool success);

	
	
	function burn(uint256 amount) public returns (bool);

	
	
	
	function frozenCheck(address _from , address _to) view private returns (bool);

	
	
	function freezeAccount(address target , bool freeze) public;

	
	/// return weather operation was successful or not
	function register(string key) public returns(bool);

	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Burn    (address indexed _owner , uint256 _value);
	event LogRegister (address user, string key);
}
contract BasicToken is Token ,HCBFreeze{

	function transfer(address _to, uint256 _value) stoppable public returns (bool ind) {
		//Default assumes totalSupply can't be over max (2^256 - 1).
		//If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
		//Replace the if with this one instead.
		require(_to!= address(0));
		require(frozenCheck(msg.sender,_to));
		if (balances[msg.sender] >= _value && _value > 0) {
			balances[msg.sender] = safeSub(balances[msg.sender] , _value);
			balances[_to]  = safeAdd(balances[_to],_value);
			emit Transfer(msg.sender, _to, _value);
			return true;
		} else { return false; }
	}

	function balanceOf(address _owner) public view returns (uint256 balance) {
		return balances[_owner];
	}

	function burn(uint256 amount) stoppable onlyOwner public returns (bool){
		if(balances[msg.sender] > amount ){
			balances[msg.sender] = safeSub(balances[msg.sender],amount);
			totalSupply = safeSub(totalSupply,amount);
			emit Burn(msg.sender,amount);
			return true;
		}else{
			return false;
		}
	}
	function frozenCheck(address _from , address _to) view private returns (bool){
		require(!frozenAccount[_from]);
		require(!frozenAccount[_to]);
		return true;
	}
	function freezeAccount(address target , bool freeze) onlyOwner public{
		frozenAccount[target] = freeze;
	}
	function register(string key) public returns(bool){
		assert(bytes(key).length <= 64);
		require(!status());

		keys[msg.sender] = key;
		emit LogRegister(msg.sender,key);
		return true;
	}
	mapping (address => uint256)                      internal balances;
	mapping (address => bool)                         private  frozenAccount;    //Save frozen account
	mapping (address => string)                       private  keys;            //mapping main chain's public key and Eth key
}
contract HCBToken is BasicToken{

	string public name = "HiggsCandyBox";                         /// Set the full name of this contract
	uint256 public decimals = 18;                                 /// Set the decimal
	string public symbol = "HCB";                                 /// Set the symbol of this contract

	constructor() public {
		owner = msg.sender;
		totalSupply = 1000000000000000000000000000;
		balances[msg.sender] = totalSupply;
	}

	function () stoppable public {
		revert();
	}

}