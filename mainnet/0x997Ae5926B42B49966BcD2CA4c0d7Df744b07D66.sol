// SPDX-License-Identifier: MIXED

/**
 *Submitted for verification at Etherscan.io on 2021-06-20
*/

// 

// File @boringcrypto/boring-solidity/contracts/libraries/[email protected]
// License-Identifier: MIT
pragma solidity 0.8.4;

// Audit on 5-Jan-2021 by Keno and BoringCrypto
// Source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol + Claimable.sol
// Edited by BoringCrypto

contract BoringOwnableData {
    address public owner;
    address public pendingOwner;
}

contract BoringOwnable is BoringOwnableData {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    
    /// Can only be invoked by the current `owner`.
    
    
    
    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) public onlyOwner {
        if (direct) {
            // Checks
            require(newOwner != address(0) || renounce, "Ownable: zero address");

            // Effects
            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            pendingOwner = address(0);
        } else {
            // Effects
            pendingOwner = newOwner;
        }
    }

    
    function claimOwnership() public {
        address _pendingOwner = pendingOwner;

        // Checks
        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        // Effects
        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}

// License-Identifier: MIT

interface Cauldron {
    function accrue() external;
    function withdrawFees() external;
}

contract SimpleWithdrawer is BoringOwnable {
    
    Cauldron[] public cauldrons;
    
    event LogNotEnoughFunds(Cauldron indexed cauldron);
    
    constructor(Cauldron[] memory pools) {
        cauldrons = pools;
    }
    
    function withdraw() external {
        for(uint256 i = 0; i < cauldrons.length; i++) {
            cauldrons[i].accrue();
            try cauldrons[i].withdrawFees() {
                
            } catch {
                emit LogNotEnoughFunds(cauldrons[i]);
            }
        }
        
    }
    
    function addPool(Cauldron pool) external onlyOwner {
        cauldrons.push(pool);
    }
    
    function addPools(Cauldron[] memory pools) external onlyOwner {
        for(uint256 i = 0; i < pools.length; i++) {
            cauldrons.push(pools[i]);
        }
    }
    
}

