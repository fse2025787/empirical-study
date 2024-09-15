// SPDX-License-Identifier: Unlicense


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
}// 
pragma solidity >=0.8.4;






error PRBProxyRegistry__ProxyAlreadyExists(address owner);



contract PRBProxyRegistry is IPRBProxyRegistry {
    /// PUBLIC STORAGE ///

    
    IPRBProxyFactory public factory;

    /// INTERNAL STORAGE ///

    
    mapping(address => IPRBProxy) internal currentProxies;

    /// CONSTRUCTOR ///

    constructor(IPRBProxyFactory factory_) {
        factory = factory_;
    }

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    function getCurrentProxy(address owner) external view returns (IPRBProxy proxy) {
        proxy = currentProxies[owner];
    }

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    function deploy() external returns (address payable proxy) {
        proxy = deployFor(msg.sender);
    }

    
    function deployFor(address owner) public returns (address payable proxy) {
        IPRBProxy currentProxy = currentProxies[owner];

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




interface IPRBProxy {
    /// EVENTS ///

    event Execute(address indexed target, bytes data, bytes response);

    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    /// contract and function selector.
    function getPermission(
        address envoy,
        address target,
        bytes4 selector
    ) external view returns (bool);

    
    function owner() external view returns (address);

    
    
    function minGasReserve() external view returns (uint256);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    /// including when the contract call reverts with a reason or custom error.
    ///
    
    /// - The caller must be either an owner or an envoy.
    /// - `target` must be a deployed contract.
    /// - The owner cannot be changed during the DELEGATECALL.
    ///
    
    
    
    function execute(address target, bytes calldata data) external payable returns (bytes memory response);

    
    
    /// - The caller must be the owner.
    
    function setMinGasReserve(uint256 newMinGasReserve) external;

    
    /// on behalf of the owner.
    
    ///
    /// Requirements:
    /// - The caller must be the owner.
    ///
    
    
    
    
    function setPermission(
        address envoy,
        address target,
        bytes4 selector,
        bool permission
    ) external;

    
    
    /// - The caller must be the owner.
    
    function transferOwnership(address newOwner) external;
}

// 
pragma solidity >=0.8.4;




interface IPRBProxyFactory {
    /// EVENTS ///

    event DeployProxy(
        address indexed origin,
        address indexed deployer,
        address indexed owner,
        bytes32 seed,
        bytes32 salt,
        address proxy
    );

    /// PUBLIC CONSTANT FUNCTIONS ///

    
    
    function getNextSeed(address eoa) external view returns (bytes32 result);

    
    
    function isProxy(address proxy) external view returns (bool result);

    
    
    function version() external view returns (uint256);

    /// PUBLIC NON-CONSTANT FUNCTIONS ///

    
    
    
    function deploy() external returns (address payable proxy);

    
    
    
    function deployFor(address owner) external returns (address payable proxy);
}
