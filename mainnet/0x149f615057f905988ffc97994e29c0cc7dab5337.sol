// SPDX-License-Identifier: Apache-2.0

/**
 *Submitted for verification at Etherscan.io on 2022-05-02
*/

// 
pragma solidity ^0.8.0;

contract Authorizable {
    // This contract allows a flexible authorization scheme

    // The owner who can change authorization status
    address public owner;
    // A mapping from an address to its authorization status
    mapping(address => bool) public authorized;

    
    constructor() {
        owner = msg.sender;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Sender not owner");
        _;
    }

    
    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "Sender not Authorized");
        _;
    }

    
    
    
    function isAuthorized(address who) public view returns (bool) {
        return authorized[who];
    }

    
    
    function authorize(address who) external onlyOwner {
        _authorize(who);
    }

    
    
    function deauthorize(address who) external onlyOwner {
        authorized[who] = false;
    }

    
    
    function setOwner(address who) public onlyOwner {
        owner = who;
    }

    
    
    function _authorize(address who) internal {
        authorized[who] = true;
    }
}

contract WrapperRegistry is Authorizable {
    address[] public wrappers;

    
    
    constructor(address _owner) {
        // authorize the owner address to be able to execute the validations
        _authorize(_owner);
    }

    
    
    function registerWrapper(address wrapper) external onlyAuthorized {
        wrappers.push(wrapper);
    }

    
    
    function viewRegistry() external view returns (address[] memory) {
        return wrappers;
    }
}