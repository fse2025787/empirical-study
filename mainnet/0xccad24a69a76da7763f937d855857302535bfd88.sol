
pragma solidity ^0.4.11;


/// `Owned` is a base level contract that assigns an `owner` that can be later changed
contract Owned {
    
    /// modifier
    modifier onlyOwner { require (msg.sender == owner); _; }

    address public owner;

    
    function Owned() public { owner = msg.sender;}

    
    
    ///  an unowned neutral vault, however that cannot be undone
    function changeOwner(address _newOwner)  onlyOwner public {
        owner = _newOwner;
    }
}


contract ERC20 {

  function balanceOf(address who) constant public returns (uint);
  function allowance(address owner, address spender) constant public returns (uint);

  function transfer(address to, uint value) public returns (bool ok);
  function transferFrom(address from, address to, uint value) public returns (bool ok);
  function approve(address spender, uint value) public returns (bool ok);

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);

}

contract TokenDistribution is Owned {

    ERC20 public tokenContract;
    
    function TokenDistribution ( address _tokenAddress ) public {
        tokenContract = ERC20(_tokenAddress); // The Deployed Token Contract
     }
          
    function distributeTokens(address[] _owners, uint256[] _tokens) onlyOwner public {

        require( _owners.length == _tokens.length );
        for(uint i=0;i<_owners.length;i++){
            require (tokenContract.transferFrom(this, _owners[i], _tokens[i]));
        }

    }

}