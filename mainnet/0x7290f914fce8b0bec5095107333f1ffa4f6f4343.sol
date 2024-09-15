// SPDX-License-Identifier: MIT

/**
 *Submitted for verification at Etherscan.io on 2022-08-24
*/

// 
pragma solidity ^0.8.7;


contract Ownable {
    
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Mortal is Ownable {
    function executeSelfdestruct() public onlyOwner {
        selfdestruct(payable(owner));
    }
}


/// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
interface ERC20 {
    function totalSupply() external view returns(uint);
    function balanceOf(address who) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    
    function allowance(address owner, address spender) external view returns (uint);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract Airdropper is Mortal {
    
    mapping (address => bool) public whitelisted;

    
    
    

    function airdrop(address _token,address[] memory dests, uint256[] memory values) public onlyOwner{
        require(dests.length == values.length);
       for(uint i = 0; i < dests.length; i++) {
            ERC20(_token).transfer(dests[i], values[i]*1e18);
        }
    }
}