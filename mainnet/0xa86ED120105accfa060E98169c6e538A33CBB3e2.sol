
/**
 *Submitted for verification at Etherscan.io on 2022-02-08
*/

pragma solidity 0.8.10;




contract OnChainPayroll {

    /// STATE VARIABLES ///

    
    address immutable public owner;
    
    uint public ethPayed;
    
    mapping(address => uint) public addressToPaid;

    /// CONSTRUCTOR ///

    
    constructor (address _owner) {
        owner = _owner;
    }

     /// PAY FUNCTION ///

    
    
    function pay(address payable _payee) external payable {
        require(msg.sender == owner, "not owner");
        
        ethPayed += msg.value;
        addressToPaid[_payee] += msg.value;
        _payee.transfer(msg.value); 
    }
}