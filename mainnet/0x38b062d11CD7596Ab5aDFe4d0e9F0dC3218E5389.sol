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






contract ServiceManager is GenericManager {
    event CreateMultisig(address indexed multisig);

    // Service registry address
    address public immutable serviceRegistry;

    constructor(address _serviceRegistry) {
        serviceRegistry = _serviceRegistry;
        owner = msg.sender;
    }

    
    
    
    
    
    
    function create(
        address serviceOwner,
        bytes32 configHash,
        uint32[] memory agentIds,
        IService.AgentParams[] memory agentParams,
        uint32 threshold
    ) external returns (uint256)
    {
        // Check if the minting is paused
        if (paused) {
            revert Paused();
        }
        return IService(serviceRegistry).create(serviceOwner, configHash, agentIds, agentParams,
            threshold);
    }

    
    
    
    
    
    
    
    function update(
        bytes32 configHash,
        uint32[] memory agentIds,
        IService.AgentParams[] memory agentParams,
        uint32 threshold,
        uint256 serviceId
    ) external returns (bool)
    {
        return IService(serviceRegistry).update(msg.sender, configHash, agentIds, agentParams,
            threshold, serviceId);
    }

    
    
    
    function activateRegistration(uint256 serviceId) external payable returns (bool success) {
        success = IService(serviceRegistry).activateRegistration{value: msg.value}(msg.sender, serviceId);
    }

    
    
    
    
    
    function registerAgents(
        uint256 serviceId,
        address[] memory agentInstances,
        uint32[] memory agentIds
    ) external payable returns (bool success) {
        success = IService(serviceRegistry).registerAgents{value: msg.value}(msg.sender, serviceId, agentInstances, agentIds);
    }

    
    
    
    
    
    function deploy(
        uint256 serviceId,
        address multisigImplementation,
        bytes memory data
    ) external returns (address multisig)
    {
        multisig = IService(serviceRegistry).deploy(msg.sender, serviceId, multisigImplementation, data);
        emit CreateMultisig(multisig);
    }

    
    
    
    
    function terminate(uint256 serviceId) external returns (bool success, uint256 refund) {
        (success, refund) = IService(serviceRegistry).terminate(msg.sender, serviceId);
    }

    
    
    
    
    function unbond(uint256 serviceId) external returns (bool success, uint256 refund) {
        (success, refund) = IService(serviceRegistry).unbond(msg.sender, serviceId);
    }
}

// 
pragma solidity ^0.8.15;


interface IService{
    struct AgentParams {
        // Number of agent instances
        uint32 slots;
        // Bond per agent instance
        uint96 bond;
    }

    
    
    
    
    
    
    
    function create(
        address serviceOwner,
        bytes32 configHash,
        uint32[] memory agentIds,
        AgentParams[] memory agentParams,
        uint32 threshold
    ) external returns (uint256 serviceId);

    
    
    
    
    
    
    
    
    function update(
        address serviceOwner,
        bytes32 configHash,
        uint32[] memory agentIds,
        AgentParams[] memory agentParams,
        uint32 threshold,
        uint256 serviceId
    ) external returns (bool success);

    
    
    
    
    function activateRegistration(address serviceOwner, uint256 serviceId) external payable returns (bool success);

    
    
    
    
    
    
    function registerAgents(
        address operator,
        uint256 serviceId,
        address[] memory agentInstances,
        uint32[] memory agentIds
    ) external payable returns (bool success);

    
    
    
    
    
    
    function deploy(
        address serviceOwner,
        uint256 serviceId,
        address multisigImplementation,
        bytes memory data
    ) external returns (address multisig);

    
    
    
    
    
    function terminate(address serviceOwner, uint256 serviceId) external returns (bool success, uint256 refund);

    
    
    
    
    
    function unbond(address operator, uint256 serviceId) external returns (bool success, uint256 refund);
}
