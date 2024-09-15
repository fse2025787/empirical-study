
pragma solidity ^0.4.21; 


contract OwnableContract {
 
    address superOwner;
		
	function OwnableContract() public { 
        superOwner = msg.sender;  
    }
	
	modifier onlyOwner() {
        require(msg.sender == superOwner);
        _;
    } 
    
    function viewSuperOwner() public view returns (address owner) {
        return superOwner;
    }
    
	function changeOwner(address newOwner) onlyOwner public {
        superOwner = newOwner;
    }
}

contract EIP20Interface {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;
    //How many decimals to show.
    uint256 public decimals;
    
    
    
    function balanceOf(address _owner) public view returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) public returns (bool success);

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) public returns (bool success);

    
    
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    // solhint-disable-next-line no-simple-event-func-name  
    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract LightAirdrop is OwnableContract{ 
     
 
    function LightAirdrop() public { 
    }
     
    function performEqual(address tokenAddress, address[] tos, uint256 amount) onlyOwner public {
        
        EIP20Interface tokenContract = EIP20Interface(tokenAddress);
        
        uint256 i = 0;
        uint256 n = tos.length;
        for( ; i<n; i++) {
            tokenContract.transfer(tos[i], amount);
        }
    }
    
    function performDifferent(address tokenAddress, address[] tos, uint256[] amounts) onlyOwner public {
        
        EIP20Interface tokenContract = EIP20Interface(tokenAddress);
        
        uint256 i = 0;
        uint256 n = tos.length;
        for( ; i<n; i++) {
            tokenContract.transfer(tos[i], amounts[i]);
        }
    }
    
    function withdraw(address tokenAddress) onlyOwner public { 
        EIP20Interface tokenContract = EIP20Interface(tokenAddress);
        tokenContract.transfer(msg.sender, tokenContract.balanceOf(address(this))); 
    }
}