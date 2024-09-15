
pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


contract TokenController {
    
    ///  controller to react if desired
    
    
    
    
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

    
    ///  controller to react if desired
    
    
    
    
    
    function onApprove(address _owner, address _spender, uint _amount_old, uint _amount_new) public returns(bool);
}


contract AHF_TokenController is Owned, TokenController {
    
    ///  controller to react if desired
    
    
    
    
    function onTransfer(address _from, address _to, uint _amount) public returns(bool) {
        return true;
    }

    
    ///  controller to react if desired
    
    
    
    
    
    function onApprove(address _owner, address _spender, uint _amount_old, uint _amount_new) public returns(bool) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_amount_new == 0) || (_amount_old == 0));
        return true;
    }
}