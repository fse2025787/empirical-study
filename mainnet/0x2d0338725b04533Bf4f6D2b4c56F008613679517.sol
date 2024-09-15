// SPDX-License-Identifier: GPL-3.0-or-later


// 
pragma solidity ^0.8.4;

interface IVanillaV1Safelist01 {
    
    
    
    function isSafelisted(address token) external view returns (bool);

    
    
    function nextVersion() external view returns (address);

    
    
    event TokensAdded (address[] tokens);

    
    
    event TokensRemoved (address[] tokens);

    
    error UnauthorizedAccess ();
}
// 
pragma solidity ^0.8.4;



contract VanillaV1Safelist01 is IVanillaV1Safelist01 {

    address private immutable owner;
    
    mapping(address => bool) public override isSafelisted;

    
    address public override nextVersion;

    constructor(address safeListOwner) {
        owner = safeListOwner;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert UnauthorizedAccess();
        }
        _;
    }

    
    
    
    
    function modify(address[] calldata added, address[] calldata removed) external onlyOwner {
        uint numAdded = added.length;
        if (numAdded > 0) {
            for (uint i = 0; i < numAdded; i++) {
                isSafelisted[added[i]] = true;
            }
            emit TokensAdded(added);
        }

        uint numRemoved = removed.length;
        if (numRemoved > 0) {
            for (uint i = 0; i < numRemoved; i++) {
                delete isSafelisted[removed[i]];
            }
            emit TokensRemoved(removed);
        }
    }

    
    
    function approveNextVersion(address implementation) external onlyOwner {
        nextVersion = implementation;
    }

}
