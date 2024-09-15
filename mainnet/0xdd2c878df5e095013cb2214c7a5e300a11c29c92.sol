// SPDX-License-Identifier: AGPL-3.0-only


// 
pragma solidity >=0.8.0;



abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnerUpdated(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnerUpdated(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function setOwner(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}// 
pragma solidity ^0.8.13;


contract RefundEntrants is Owned(msg.sender) {
    mapping (address => uint256) public entrantBalance;
    uint public pot = 0;
    uint constant ENTRY_FEE = 0.08 ether;

    error ZeroBalance();

    
    
    
    function load(address[] memory entrants, uint[] memory numEntered) public onlyOwner {
        require(entrants.length == numEntered.length, "different length arrays");
        for (uint i=0; i < entrants.length; i++) {
            entrantBalance[entrants[i]] = numEntered[i] * ENTRY_FEE;
            pot += numEntered[i] * ENTRY_FEE;
        }
    }

    function withdraw() public {
        uint amount = entrantBalance[msg.sender];
        if (amount == 0){
            revert ZeroBalance();
        }
        entrantBalance[msg.sender] = 0;
        (bool sent, bytes memory data) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    
    function sweepEth() public onlyOwner {
         (bool sent, bytes memory data) = owner.call{value: address(this).balance}("");
         require(sent, "Failed to send Ether");
    }

    receive() external payable {}
    fallback() external payable {} 
}
