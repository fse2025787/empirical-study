
pragma solidity 0.4.24;


interface iERC20 {
    function totalSupply() external constant returns (uint256 supply);
    function balanceOf(address owner) external constant returns (uint256 balance);    
    function transfer(address to, uint tokens) external returns (bool success);
}



/// This contract must also own some quantity of the token it's selling.
/// Note: This is not meant to be feature complete.

contract MeerkatICO {
    iERC20 token;
    address owner;
    address tokenCo;
    uint rateMe;
    
    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }


    // @notice Initialises the contract.
    // @param _main The address of an ERC20 compatible token to sell.
   constructor(address _main) public {
        token = iERC20(_main);
        tokenCo = _main;
        owner = msg.sender;
        rateMe = 0;
    }

    
    function withdraw() public ownerOnly {
        owner.transfer(address(this).balance);
    }

    
    
    
    function setRate(uint _rateMe) public ownerOnly {
        rateMe = _rateMe;
    }
    
    function CurrentRate() public constant returns (uint rate) {
        return rateMe;
    }
    
    function TokenLinked() public constant returns (address _token, uint _amountLeft) {
        return (tokenCo, (token.balanceOf(address(this)) / 10**18)) ;
    }
    
    
    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public ownerOnly returns (bool success) {
        return iERC20(tokenAddress).transfer(owner, tokens);
    }

    
    
	
    function () public payable {
        // minimum contribution is 0.1 ETH
	    // STOP selling if the rate is set to 0
        require( (msg.value >= 100000000000000000) && (rateMe != 0) );
        
        uint value = msg.value * rateMe;
        
        // Overflow detection/protection:
        require(value/msg.value == rateMe);
        
        token.transfer(msg.sender, value);
        
    }
}