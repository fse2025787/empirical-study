// SPDX-License-Identifier: MIT

// 
pragma solidity ^0.8.13;


struct NodeData {
    uint16 nodeType;
    uint64 owner;
    uint64 parent;
    uint64 groupNode;
    // 6 bytes remaining
}


/// catalog logical entities and manage access control in the Metalabel
/// universe.
interface INodeRegistry {
    
    /// will be used to determine ownership, and a separate logical parent that
    /// expresses the entity relationship.  Child nodes can only be created if
    /// msg.sender is an authorized manager of the parent node.
    function createNode(
        uint16 nodeType,
        uint64 owner,
        uint64 parent,
        uint64 groupNode,
        address[] memory initialControllers,
        string memory metadata
    ) external returns (uint64 id);

    
    /// A node can be managed by an address if any of the following conditions
    /// are true:
    ///   - The address's account is the owner of the node
    ///   - The address's account is the owner of the node's group node
    ///   - The address is an authorized controller of the node
    ///   - The address is an authorized controller of the node's group node
    function isAuthorizedAddressForNode(uint64 node, address subject)
        external
        view
        returns (bool isAuthorized);
}

// 
pragma solidity ^0.8.13;




/// are intended to be cataloged within the Metalabel universe.
interface IResourceFactory {
    
    event ResourceBroadcast(
        address indexed resource,
        string topic,
        string message
    );

    
    function nodeRegistry() external view returns (INodeRegistry);

    
    function controlNode(address resource)
        external
        view
        returns (uint64 nodeId);

    
    function messageStorage(address resource, string calldata topic)
        external
        view
        returns (string memory message);

    
    /// be authorized to manage the resource's control node.
    function broadcast(
        address resource,
        string calldata topic,
        string calldata message
    ) external;

    
    /// given resource. msg.sender must be authorized to manage the resource's
    /// control node.
    function broadcastAndStore(
        address resource,
        string calldata topic,
        string calldata message
    ) external;
}

// 
pragma solidity ^0.8.13;

/*

███╗   ███╗███████╗████████╗ █████╗ ██╗      █████╗ ██████╗ ███████╗██╗
████╗ ████║██╔════╝╚══██╔══╝██╔══██╗██║     ██╔══██╗██╔══██╗██╔════╝██║
██╔████╔██║█████╗     ██║   ███████║██║     ███████║██████╔╝█████╗  ██║
██║╚██╔╝██║██╔══╝     ██║   ██╔══██║██║     ██╔══██║██╔══██╗██╔══╝  ██║
██║ ╚═╝ ██║███████╗   ██║   ██║  ██║███████╗██║  ██║██████╔╝███████╗███████╗
╚═╝     ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝


Deployed by Metalabel with 💖 as a permanent application on the Ethereum blockchain.

Metalabel is a growing universe of tools, knowledge, and resources for
metalabels and cultural collectives.

Our purpose is to establish the metalabel as key infrastructure for creative
collectives and to inspire a new culture of creative collaboration and mutual
support.

OUR SQUAD

Anna Bulbrook (Curator)
Austin Robey (Community)
Brandon Valosek (Engineer)
Ilya Yudanov (Designer)
Lauren Dorman (Engineer)
Rob Kalin (Board)
Yancey Strickler (Director)

https://metalabel.xyz

*/





/// on-chain resources that can be cataloged on the Metalabel protocol.
abstract contract ResourceFactory is IResourceFactory {
    // ---
    // Errors
    // ---

    
    error NotAuthorized();

    // ---
    // Storage
    // ---

    
    mapping(address => mapping(string => string)) public messageStorage;

    
    INodeRegistry public immutable nodeRegistry;

    
    mapping(address => uint64) public controlNode;

    // ---
    // Constructor
    // ---

    constructor(INodeRegistry _nodeRegistry) {
        nodeRegistry = _nodeRegistry;
    }

    // ---
    // Modifiers
    // ---

    
    /// to manage the control node of this resource
    modifier onlyAuthorized(address resource) {
        if (
            !nodeRegistry.isAuthorizedAddressForNode(
                controlNode[resource],
                msg.sender
            )
        ) {
            revert NotAuthorized();
        }
        _;
    }

    // ---
    // Permissioned functionality
    // ---

    
    function broadcast(
        address waterfall,
        string calldata topic,
        string calldata message
    ) external onlyAuthorized(waterfall) {
        emit ResourceBroadcast(waterfall, topic, message);
    }

    
    function broadcastAndStore(
        address waterfall,
        string calldata topic,
        string calldata message
    ) external onlyAuthorized(waterfall) {
        messageStorage[waterfall][topic] = message;
        emit ResourceBroadcast(waterfall, topic, message);
    }
}

// 
pragma solidity ^0.8.13;

/*

███╗   ███╗███████╗████████╗ █████╗ ██╗      █████╗ ██████╗ ███████╗██╗
████╗ ████║██╔════╝╚══██╔══╝██╔══██╗██║     ██╔══██╗██╔══██╗██╔════╝██║
██╔████╔██║█████╗     ██║   ███████║██║     ███████║██████╔╝█████╗  ██║
██║╚██╔╝██║██╔══╝     ██║   ██╔══██║██║     ██╔══██║██╔══██╗██╔══╝  ██║
██║ ╚═╝ ██║███████╗   ██║   ██║  ██║███████╗██║  ██║██████╔╝███████╗███████╗
╚═╝     ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝


Deployed by Metalabel with 💖 as a permanent application on the Ethereum blockchain.

Metalabel is a growing universe of tools, knowledge, and resources for
metalabels and cultural collectives.

Our purpose is to establish the metalabel as key infrastructure for creative
collectives and to inspire a new culture of creative collaboration and mutual
support.

OUR SQUAD

Anna Bulbrook (Curator)
Austin Robey (Community)
Brandon Valosek (Engineer)
Ilya Yudanov (Designer)
Lauren Dorman (Engineer)
Rob Kalin (Board)
Yancey Strickler (Director)

https://metalabel.xyz

*/





/// https://github.com/0xSplits/splits-waterfall/blob/master/src/WaterfallModuleFactory.sol
interface IWaterfallModuleFactory {
    function createWaterfallModule(
        address token,
        address nonWaterfallRecipient,
        address[] calldata recipients,
        uint256[] calldata thresholds
    ) external returns (address wm);
}


/// resources in the Metalabel protocol.
contract WaterfallFactory is ResourceFactory {
    // ---
    // Events
    // ---

    
    event WaterfallCreated(
        address indexed waterfall,
        uint64 nodeId,
        address token,
        address nonWaterfallRecipient,
        address[] recipients,
        uint256[] thresholds,
        string metadata
    );

    // ---
    // Storage
    // ---

    
    IWaterfallModuleFactory public immutable waterfallFactory;

    // ---
    // Constructor
    // ---

    constructor(
        INodeRegistry _nodeRegistry,
        IWaterfallModuleFactory _waterfallFactory
    ) ResourceFactory(_nodeRegistry) {
        waterfallFactory = _waterfallFactory;
    }

    // ---
    // Public funcionality
    // ---

    
    function createWaterfall(
        address token,
        address nonWaterfallRecipient,
        address[] calldata recipients,
        uint256[] calldata thresholds,
        uint64 controlNodeId,
        string calldata metadata
    ) external returns (address waterfall) {
        // Ensure msg.sender is authorized to manage the control node.
        if (
            !nodeRegistry.isAuthorizedAddressForNode(controlNodeId, msg.sender)
        ) {
            revert NotAuthorized();
        }

        // Deploy and store the split.
        waterfall = waterfallFactory.createWaterfallModule(
            token,
            nonWaterfallRecipient,
            recipients,
            thresholds
        );
        controlNode[waterfall] = controlNodeId;
        emit WaterfallCreated(
            waterfall,
            controlNodeId,
            token,
            nonWaterfallRecipient,
            recipients,
            thresholds,
            metadata
        );
    }
}