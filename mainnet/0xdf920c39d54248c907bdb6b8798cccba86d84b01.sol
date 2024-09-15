// SPDX-License-Identifier: UNLICENSED

/**
 *Submitted for verification at Etherscan.io on 2022-06-29
*/

// 
pragma solidity 0.8.13;



contract DPDRepository {
    
    struct DPD {
        bytes cid;
        address owner;
    }

    
    DPD[] public dpds;

    
    
    mapping(uint256 => uint256) public versions;

    
    
    mapping(uint256 => address) public updaters;

    
    event DPDAdded(uint256 indexed dpdId, address owner, address updater, bytes cid);

    
    event DPDUpdated(uint256 indexed dpdId, uint256 indexed version, bytes cid);

    
    event DPDOwnerChanged(uint256 indexed dpdId, address newOwner);

    
    event DPDUpdaterChanged(uint256 indexed dpdId, address newUpdater);

    
    
    
    
    function addDpd(bytes calldata cid, address owner, address updater) external returns (uint256) {
        dpds.push(DPD(cid, owner));
        uint256 dpdId = dpds.length - 1;
        updaters[dpdId] = updater;
        emit DPDAdded(dpdId, owner, updater, cid);
        return dpdId;
    }

    
    
    
    function updateDpd(uint256 dpdId, bytes memory cid) external returns (uint256) {
        address updater = updaters[dpdId];
        require(msg.sender == updater || (msg.sender == dpds[dpdId].owner && updater == address(0)), "Only DPD updater (or owner if no updater) can update this DPD.");
        dpds[dpdId].cid = cid;
        uint256 newVersion = versions[dpdId]++;
        emit DPDUpdated(dpdId, newVersion, cid);
        return newVersion;
    }

    
    
    
    function setDpdOwner(uint256 dpdId, address newOwner) external {
        require(msg.sender == dpds[dpdId].owner, "Only DPD owner can update this DPD's owner.");
        dpds[dpdId].owner = newOwner;
        emit DPDOwnerChanged(dpdId, newOwner);
    }

    
    
    
    function setDpdUpdater(uint256 dpdId, address newUpdater) external {
        require(msg.sender == dpds[dpdId].owner, "Only DPD owner can update this DPD's updater.");
        updaters[dpdId] = newUpdater;
        emit DPDUpdaterChanged(dpdId, newUpdater);
    }
}