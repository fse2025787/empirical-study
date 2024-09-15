
pragma solidity ^0.4.24;

contract MOB {
    function buy(address _referredBy) public payable returns(uint256);
    function exit() public;
}

contract MOBDividends {
    MOB MOBContract = MOB(0x81b88b12CD8e228e976DF92bB6aD2E74ECCa1d08);
    
    
    function () public payable {
    }
    
    
    ///     repeatedly until practically all dividends have been distributed.
    
    function distribute(uint256 rounds) external {
        for (uint256 i = 0; i < rounds; i++) {
            if (address(this).balance < 0.001 ether) {
                // Balance is very low. Not worth the gas to distribute.
                break;
            }
            
            MOBContract.buy.value(address(this).balance)(0x0);
            MOBContract.exit();
        }
    }
}