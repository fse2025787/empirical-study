
pragma solidity ^0.4.13;

contract ChooseWHGReturnAddress {
    
    mapping (address => address) returnAddresses;
    uint public endDate;
    
    
    /// the upgraded parity multisig will be locked in as the 'returnAddr'
    function ChooseWHGReturnAddress(uint _endDate) {
        endDate = _endDate;
    }
    
    /////////////////////////
    //   IMPORTANT
    /////////////////////////
    // @dev The `returnAddr` can be changed only once.
    //  We will send the funds to the chosen address. This is Crypto, if the
    //  address is wrong, your funds could be lost, please, proceed with extreme 
    //  caution and treat this like you are sending all of your funds to this 
    //  address.
    
    
    ///  This function can only be called once, PLEASE READ THE NOTE ABOVE.
    
    function requestReturn(address _returnAddr) {
    
        // After the end date, the newly deployed parity multisig will be 
        //  chosen if no transaction is made.
        require(now <= endDate);

        require(returnAddresses[msg.sender] == 0x0);
        returnAddresses[msg.sender] = _returnAddr;
        ReturnRequested(msg.sender, _returnAddr);
    }
    
    ///  address that the WHG will return the funds to
    
    
    function getReturnAddress(address _addr) constant returns (address) {
        if (returnAddresses[_addr] == 0x0) {
            return _addr;
        } else {
            return returnAddresses[_addr];
        }
    }
    
    function isReturnRequested(address _addr) constant returns (bool) {
        return returnAddresses[_addr] != 0x0;
    }
    
    event ReturnRequested(address indexed origin, address indexed returnAddress);
}