// SPDX-License-Identifier: WTFPL


// 
pragma solidity >=0.8.4;







/// have one proxy at a time.
interface IPRBProxyRegistry {
    /// PUBLIC CONSTANT FUNCTIONS ///

    
    function factory() external view returns (IPRBProxyFactory proxyFactory);

    
    
    function getCurrentProxy(address owner) external view returns (IPRBProxy proxy);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    
    ///
    /// Requirements:
    /// - All from "deployFor".
    ///
    
    function deploy() external returns (address payable proxy);

    
    ///
    
    /// - The proxy must either not exist or its ownership must have been transferred by the owner.
    ///
    
    
    function deployFor(address owner) external returns (address payable proxy);
}

// 
pragma solidity >=0.8.4;




/// account (an owner) that can be granted exclusive access to specific functions.
///
/// By default, the owner account will be the one that deploys the contract. This can later be
/// changed with {transfer}.
///
/// This module is used through inheritance. It will make available the modifier `onlyOwner`,
/// which can be applied to your functions to restrict their use to the owner.
///

/// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/Ownable.sol
interface IOwnable {
    /// EVENTS ///

    
    
    
    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    /// NON-CONSTANT FUNCTIONS ///

    
    /// functions anymore.
    ///
    /// WARNING: Doing this will leave the contract without an owner, thereby removing any
    /// functionality that is only available to the owner.
    ///
    /// Requirements:
    ///
    /// - The caller must be the owner.
    function renounceOwnership() external;

    
    /// called by the current owner.
    
    function transferOwnership(address newOwner) external;

    /// CONSTANT FUNCTIONS ///

    
    
    function owner() external view returns (address);
}
// 
pragma solidity >=0.8.4;






error PRBProxyRegistry__ProxyAlreadyExists(address owner);



contract PRBProxyRegistry is IPRBProxyRegistry {
    /// PUBLIC STORAGE ///

    
    IPRBProxyFactory public override factory;

    /// INTERNAL STORAGE ///

    
    mapping(address => IPRBProxy) internal currentProxies;

    /// CONSTRUCTOR ///

    constructor(IPRBProxyFactory factory_) {
        factory = factory_;
    }

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    function getCurrentProxy(address owner) public view override returns (IPRBProxy proxy) {
        proxy = currentProxies[owner];
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function deploy() external override returns (address payable proxy) {
        proxy = deployFor(msg.sender);
    }

    
    function deployFor(address owner) public override returns (address payable proxy) {
        IPRBProxy currentProxy = getCurrentProxy(owner);

        // Do not deploy if the proxy already exists and the owner is the same.
        if (address(currentProxy) != address(0) && currentProxy.owner() == owner) {
            revert PRBProxyRegistry__ProxyAlreadyExists(owner);
        }

        // Deploy the proxy via the factory.
        proxy = factory.deployFor(owner);

        // Set or override the current proxy for the owner.
        currentProxies[owner] = IPRBProxy(proxy);
    }
}

// 
pragma solidity >=0.8.4;






interface IPRBProxy is IOwnable {
    /// EVENTS ///

    event Execute(address indexed target, bytes data, bytes response);

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    function minGasReserve() external view returns (uint256);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    /// the data it gets back, including when the contract call reverts with a reason or custom error.
    ///
    
    /// - The caller must be the owner.
    /// - `target` must be a contract.
    ///
    
    
    
    function execute(address target, bytes memory data) external payable returns (bytes memory response);

    
    ///
    
    ///
    /// Requirements:
    /// - Can only be called once.
    ///
    
    function initialize(address owner_) external;

    
    
    /// - The caller must be the owner.
    function setMinGasReserve(uint256 newMinGasReserve) external;
}

// 
pragma solidity >=0.8.4;






interface IPRBProxyFactory {
    /// EVENTS ///

    event DeployProxy(
        address indexed origin,
        address indexed deployer,
        address indexed owner,
        bytes32 salt,
        bytes32 finalSalt,
        address proxy
    );

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    
    function getNextSalt(address eoa) external view returns (bytes32 result);

    
    function implementation() external view returns (IPRBProxy proxy);

    
    
    function isProxy(address proxy) external view returns (bool result);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    
    
    function deploy() external returns (address payable proxy);

    
    ///
    
    /// - The CREATE2 must not have been used.
    ///
    
    
    function deployFor(address owner) external returns (address payable proxy);
}
