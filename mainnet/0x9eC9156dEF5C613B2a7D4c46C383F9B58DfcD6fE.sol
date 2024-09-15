// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.15;


interface IErrorsRegistries {
    
    
    
    error ManagerOnly(address sender, address manager);

    
    
    
    error OwnerOnly(address sender, address owner);

    
    error HashExists();

    
    error ZeroAddress();

    
    
    error WrongAgentId(uint256 agentId);

    
    
    
    error WrongArrayLength(uint256 numValues1, uint256 numValues2);

    
    
    error AgentNotFound(uint256 agentId);

    
    
    error ComponentNotFound(uint256 componentId);

    
    
    
    
    error WrongThreshold(uint256 currentThreshold, uint256 minThreshold, uint256 maxThreshold);

    
    
    error AgentInstanceRegistered(address operator);

    
    
    error WrongOperator(uint256 serviceId);

    
    
    
    error OperatorHasNoInstances(address operator, uint256 serviceId);

    
    
    
    error AgentNotInService(uint256 agentId, uint256 serviceId);

    
    error Paused();

    
    error ZeroValue();

    
    
    
    error Overflow(uint256 provided, uint256 max);

    
    
    error ServiceMustBeInactive(uint256 serviceId);

    
    
    error AgentInstancesSlotsFilled(uint256 serviceId);

    
    
    
    error WrongServiceState(uint256 state, uint256 serviceId);

    
    
    
    
    error OnlyOwnServiceMultisig(address provided, address expected, uint256 serviceId);

    
    
    error UnauthorizedMultisig(address multisig);

    
    
    
    
    error IncorrectRegistrationDepositValue(uint256 sent, uint256 expected, uint256 serviceId);

    
    
    
    
    error IncorrectAgentBondingValue(uint256 sent, uint256 expected, uint256 serviceId);

    
    
    
    
    
    error TransferFailed(address token, address from, address to, uint256 value);

    
    error ReentrancyGuard();
}
// 
pragma solidity ^0.8.15;





abstract contract GenericManager is IErrorsRegistries {
    event OwnerUpdated(address indexed owner);
    event Pause(address indexed owner);
    event Unpause(address indexed owner);

    // Owner address
    address public owner;
    // Pause switch
    bool public paused;

    
    
    function changeOwner(address newOwner) external virtual {
        // Check for the ownership
        if (msg.sender != owner) {
            revert OwnerOnly(msg.sender, owner);
        }

        // Check for the zero address
        if (newOwner == address(0)) {
            revert ZeroAddress();
        }

        owner = newOwner;
        emit OwnerUpdated(newOwner);
    }

    
    function pause() external virtual {
        // Check for the ownership
        if (msg.sender != owner) {
            revert OwnerOnly(msg.sender, owner);
        }

        paused = true;
        emit Pause(msg.sender);
    }

    
    function unpause() external virtual {
        // Check for the ownership
        if (msg.sender != owner) {
            revert OwnerOnly(msg.sender, owner);
        }

        paused = false;
        emit Unpause(msg.sender);
    }
}
// 
pragma solidity ^0.8.15;






contract RegistriesManager is GenericManager {
    // Component registry address
    address public immutable componentRegistry;
    // Agent registry address
    address public immutable agentRegistry;

    constructor(address _componentRegistry, address _agentRegistry) {
        componentRegistry = _componentRegistry;
        agentRegistry = _agentRegistry;
        owner = msg.sender;
    }

    
    
    
    
    
    
    function create(
        IRegistry.UnitType unitType,
        address unitOwner,
        bytes32 unitHash,
        uint32[] memory dependencies
    ) external returns (uint256 unitId)
    {
        // Check if the creation is paused
        if (paused) {
            revert Paused();
        }
        if (unitType == IRegistry.UnitType.Component) {
            unitId = IRegistry(componentRegistry).create(unitOwner, unitHash, dependencies);
        } else {
            unitId = IRegistry(agentRegistry).create(unitOwner, unitHash, dependencies);
        }
    }

    
    
    
    
    
    function updateHash(IRegistry.UnitType unitType, uint256 unitId, bytes32 unitHash) external returns (bool success) {
        if (unitType == IRegistry.UnitType.Component) {
            success = IRegistry(componentRegistry).updateHash(msg.sender, unitId, unitHash);
        } else {
            success = IRegistry(agentRegistry).updateHash(msg.sender, unitId, unitHash);
        }
    }
}

// 
pragma solidity ^0.8.15;


interface IRegistry {
    enum UnitType {
        Component,
        Agent
    }

    
    
    
    
    
    function create(
        address unitOwner,
        bytes32 unitHash,
        uint32[] memory dependencies
    ) external returns (uint256);

    
    
    
    
    
    function updateHash(address owner, uint256 unitId, bytes32 unitHash) external returns (bool success);

    
    
    
    
    function getLocalSubComponents(uint256 unitId) external view returns (uint32[] memory subComponentIds, uint256 numSubComponents);

    
    
    
    function calculateSubComponents(uint32[] memory unitIds) external view returns (uint32[] memory subComponentIds);

    
    
    
    
    function getUpdatedHashes(uint256 unitId) external view returns (uint256 numHashes, bytes32[] memory unitHashes);

    
    
    function totalSupply() external view returns (uint256);
}
