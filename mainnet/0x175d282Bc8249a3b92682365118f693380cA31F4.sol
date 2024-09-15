// SPDX-License-Identifier: GPL-3.0-or-later

/**
 *Submitted for verification at Etherscan.io on 2021-08-11
*/

// File: iface/IParassetGovernance.sol

// 

pragma solidity ^0.8.4;


interface IParassetGovernance {
    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external;

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view returns (uint);

    
    
    
    
    function checkGovernance(address addr, uint flag) external view returns (bool);
}
// File: ParassetGovernance.sol

pragma solidity ^0.8.4;


contract ParassetGovernance is IParassetGovernance {

	
    struct GovernanceInfo {
        address addr;
        uint96 flag;
    }

    
    mapping(address=>GovernanceInfo) _governanceMapping;

    constructor() {
		// Add msg.sender to governance
        _governanceMapping[msg.sender] = GovernanceInfo(msg.sender, uint96(0xFFFFFFFFFFFFFFFFFFFFFFFF));
    }

    //---------modifier------------

    modifier onlyGovernance() {
        require(checkGovernance(msg.sender, 0), "Parasset:!gov");
        _;
    }

    //---------view------------

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view override returns (uint) {
        return _governanceMapping[addr].flag;
    }

    
    
    
    
    function checkGovernance(address addr, uint flag) public view override returns (bool) {
        return _governanceMapping[addr].flag > flag;
    }

    //---------governance----------

    
    
    
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external override onlyGovernance {
        
        if (flag > 0) {
            _governanceMapping[addr] = GovernanceInfo(addr, uint96(flag));
        } else {
            _governanceMapping[addr] = GovernanceInfo(address(0), uint96(0));
        }
    }
}