// SPDX-License-Identifier: GPL-3.0-or-later


// 
pragma solidity ^0.8.13;

interface IObservabilityEvents {
    
    event CloneDeployed(
        address indexed factory,
        address indexed owner,
        address clone
    );

    
    event Sale(
        address indexed clone,
        address indexed to,
        uint256 pricePerToken,
        uint256 amount
    );

    
    event FundsWithdrawn(
        address indexed clone,
        address indexed withdrawnBy,
        address indexed withdrawnTo,
        uint256 amount
    );

    
    event DeploymentTargetRegistered(address indexed impl);

    
    event DeploymentTargetUnregistered(address indexed impl);

    
    
    
    event UpgradeRegistered(address indexed prevImpl, address indexed newImpl);

    
    
    
    event UpgradeUnregistered(
        address indexed prevImpl,
        address indexed newImpl
    );
}

interface IObservability {
    function emitCloneDeployed(address owner, address clone) external;

    function emitSale(
        address to,
        uint256 pricePerToken,
        uint256 amount
    ) external;

    function emitFundsWithdrawn(
        address withdrawnBy,
        address withdrawnTo,
        uint256 amount
    ) external;

    function emitDeploymentTargetRegistererd(address impl) external;

    function emitDeploymentTargetUnregistered(address imp) external;

    function emitUpgradeRegistered(address prevImpl, address impl) external;

    function emitUpgradeUnregistered(address prevImpl, address impl) external;
}// 
pragma solidity ^0.8.13;



contract Observability is IObservability, IObservabilityEvents {
    
    function emitCloneDeployed(address owner, address clone) external override {
        emit CloneDeployed(msg.sender, owner, clone);
    }

    
    function emitSale(
        address to,
        uint256 pricePerToken,
        uint256 amount
    ) external override {
        emit Sale(msg.sender, to, pricePerToken, amount);
    }

    
    function emitFundsWithdrawn(
        address withdrawnBy,
        address withdrawnTo,
        uint256 amount
    ) external override {
        emit FundsWithdrawn(msg.sender, withdrawnBy, withdrawnTo, amount);
    }

    
    function emitDeploymentTargetRegistererd(address impl) external override {
        emit DeploymentTargetRegistered(impl);
    }

    
    function emitDeploymentTargetUnregistered(address impl) external override {
        emit DeploymentTargetUnregistered(impl);
    }

    
    function emitUpgradeRegistered(
        address prevImpl,
        address impl
    ) external override {
        emit UpgradeRegistered(prevImpl, impl);
    }

    
    function emitUpgradeUnregistered(
        address prevImpl,
        address impl
    ) external override {
        emit UpgradeUnregistered(prevImpl, impl);
    }
}
