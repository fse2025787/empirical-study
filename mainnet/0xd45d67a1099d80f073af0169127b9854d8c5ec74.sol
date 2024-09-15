// SPDX-License-Identifier: Apache-2.0

/**
 *Submitted for verification at Etherscan.io on 2022-05-24
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

    
    
    function authorize(address who) external onlyOwner() {
        _authorize(who);
    }

    
    
    function deauthorize(address who) external onlyOwner() {
        authorized[who] = false;
    }

    
    
    function setOwner(address who) public onlyOwner() {
        owner = who;
    }

    
    
    function _authorize(address who) internal {
        authorized[who] = true;
    }
}

interface IVotingVault {
    
    
    
    
    function queryVotePowerView(
        address user,
        uint256 blockNumber
    ) external view returns (uint256);
}

contract BalanceQuery is Authorizable {
    // stores approved voting vaults
    IVotingVault[] public vaults;

    
    
    
    constructor(address _owner, address[] memory votingVaults) {
        // create a new array of voting vaults
        vaults = new IVotingVault[](votingVaults.length);
        // populate array with each vault passed into constructor
        for (uint256 i = 0; i < votingVaults.length; i++) {
            vaults[i] = IVotingVault(votingVaults[i]);
        }

        // authorize the owner address to be able to add/remove vaults
        _authorize(_owner);
    }

    
    
    
    function balanceOf(address user) public view returns (uint256) {
        uint256 votingPower = 0;
        // query voting power from each vault and add to total
        for (uint256 i = 0; i < vaults.length; i++) {
            try vaults[i].queryVotePowerView(user, block.number - 1) returns (uint v) {
                votingPower = votingPower + v;
            } catch {}
        }
        // return that balance
        return votingPower;
    }

    
    
    function updateVaults(address[] memory _vaults) external onlyAuthorized {
        // reset our array in storage
        vaults = new IVotingVault[](_vaults.length);

        // populate with each vault passed into the method
        for (uint256 i = 0; i < _vaults.length; i++) {
            vaults[i] = IVotingVault(_vaults[i]);
        }
    }
}