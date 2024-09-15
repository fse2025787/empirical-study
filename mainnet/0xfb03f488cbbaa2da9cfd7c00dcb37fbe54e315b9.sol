// SPDX-License-Identifier: BUSL-1.1

// 
pragma solidity 0.8.15;

/**
 * @title  IDiagonalOrgBeacon contract interface
 * @author Diagonal Finance
 */
interface IDiagonalOrgBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     */
    function implementation() external view returns (address);

    /**
     * @dev OrgBeacon owner.
     */
    function owner() external view returns (address);

    /**
     * @dev Update DiagonalOrg implementation.
     */
    function updateImplementation(address newImplementation) external;

    /**
     * @dev Update DiagonalBeacon owner.
     */
    function updateOwner(address newOwner) external;
}

// 
pragma solidity 0.8.15;



contract DiagonalOrgBeacon is IDiagonalOrgBeacon {
    /*******************************
     * Errors *
     *******************************/

    error InvalidOwnerAddress();
    error ImplementationNotContract();
    error NotOwner();

    /*******************************
     * Events *
     *******************************/

    event ImplementationUpdated(address indexed implementation);
    event OwnerUpdated(address indexed owner);

    /*******************************
     * State vars *
     *******************************/

    
    address public implementation;

    
    address public owner;

    /*******************************
     * Modifiers *
     *******************************/

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /*******************************
     * Constructor *
     *******************************/

    constructor(address _implementation, address _owner) {
        _setImplementation(_implementation);
        _setOwner(_owner);
    }

    /*******************************
     * Functions start *
     *******************************/

    
    function updateImplementation(address newImplementation) external onlyOwner {
        _setImplementation(newImplementation);
        emit ImplementationUpdated(implementation);
    }

    
    function updateOwner(address newOwner) external onlyOwner {
        _setOwner(newOwner);
        emit OwnerUpdated(newOwner);
    }

    function _setImplementation(address newImplementation) private {
        if (newImplementation.code.length == 0) revert ImplementationNotContract();
        implementation = newImplementation;
    }

    function _setOwner(address newOwner) private {
        if (newOwner == address(0)) revert InvalidOwnerAddress();
        owner = newOwner;
    }
}