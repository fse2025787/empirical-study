// SPDX-License-Identifier: AGPL-3.0-only

// 
pragma solidity >=0.8.0;



abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

// 
pragma solidity ^0.8.13;


/// ID.
interface IAccountRegistry {
    
    /// Subject must not yet have an account.
    function createAccount(address subject, string calldata metadata)
        external
        returns (uint64 id);

    
    function resolveId(address subject) external view returns (uint64 id);
}

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





/// ID.
/// - Accounts are identified by a uint64 ID
/// - Accounts are owned by an address
/// - Accounts can broadcast arbitrary strings, keyed by a topic, as blockchain events
contract AccountRegistry is IAccountRegistry, Owned {
    // ---
    // Events
    // ---

    
    event AccountCreated(
        uint64 indexed id,
        address indexed subject,
        string metadata
    );

    
    event AccountBroadcast(uint64 indexed id, string topic, string message);

    
    event AccountTransfered(uint64 indexed id, address newOwner);

    
    event AccountIssuerSet(address indexed issuer, bool authorized);

    // ---
    // Errors
    // ---

    
    error NoAccount();

    
    error AccountAlreadyExists();

    
    /// create an account.
    error NotAuthorizedAccountIssuer();

    // ---
    // Storage
    // ---

    
    uint64 public totalAccountCount;

    
    mapping(address => uint64) public accountIds;

    
    /// authorized to issue accounts.
    mapping(address => bool) public isAccountIssuer;

    // ---
    // Constructor
    // ---

    constructor(address _contractOwner) Owned(_contractOwner) {}

    // ---
    // Owner functionality
    // ---

    
    function setAccountIssuer(address issuer, bool authorized)
        external
        onlyOwner
    {
        isAccountIssuer[issuer] = authorized;
        emit AccountIssuerSet(issuer, authorized);
    }

    // ---
    // Account creation functionality
    // ---

    
    function createAccount(address subject, string calldata metadata)
        external
        returns (uint64 id)
    {
        if (accountIds[subject] != 0) revert AccountAlreadyExists();

        // So long as an owner is set, account issuance is permissioned and
        // msg.sender must be an approved account issuer
        if (owner != address(0) && !isAccountIssuer[msg.sender]) {
            revert NotAuthorizedAccountIssuer();
        }

        id = ++totalAccountCount;
        accountIds[subject] = id;
        emit AccountCreated(id, subject, metadata);
    }

    // ---
    // Account functionality
    // ---

    
    function broadcast(string calldata topic, string calldata message)
        external
    {
        uint64 id = accountIds[msg.sender];
        if (id == 0) revert NoAccount();

        emit AccountBroadcast(id, topic, message);
    }

    
    /// have an account, and msg.sender must currently own the account.
    function transferAccount(address newOwner) external {
        uint64 id = accountIds[msg.sender];
        if (id == 0) revert NoAccount();
        if (accountIds[newOwner] != 0) revert AccountAlreadyExists();

        accountIds[newOwner] = id;
        delete accountIds[msg.sender];
        emit AccountTransfered(id, newOwner);
    }

    // ---
    // Views
    // ---

    
    function resolveId(address subject) external view returns (uint64 id) {
        id = accountIds[subject];
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





/// catalog logical entities and manage access control in the Metalabel
/// universe.
/// - Nodes anchor metadata for logical entites
/// - Nodes express a logical hierarchy between entities
/// - Nodes have access control semantics that can be used to determine
///     authorization around various actions
/// - Nodes anchor broadcast messages and stored strings
contract NodeRegistry is INodeRegistry {
    // ---
    // Events
    // ---

    
    event NodeCreated(
        uint64 indexed id,
        uint16 indexed nodeType,
        uint64 indexed owner,
        uint64 parent,
        uint64 groupNode,
        string metadata
    );

    
    event NodeOwnerTransferPending(
        uint64 indexed id,
        uint64 indexed pendingOwner
    );

    
    event NodeOwnerSet(uint64 indexed id, uint64 indexed owner);

    
    event NodeParentSet(uint64 indexed id, uint64 indexed parent);

    
    event NodeGroupNodeSet(uint64 indexed id, uint64 indexed groupNode);

    
    event NodeBroadcast(uint64 indexed id, string topic, string message);

    
    event NodeControllerSet(
        uint64 indexed id,
        address indexed controller,
        bool isAuthorized
    );

    // ---
    // Errors
    // ---

    
    error NotAuthorizedForNode();

    
    error InvalidNodeCreate();

    // ---
    // Storage
    // ---

    
    uint64 public totalNodeCount;

    
    mapping(uint64 => NodeData) public nodes;

    
    AccountRegistry public immutable accounts;

    
    /// nodes or manage existing nodes.
    
    mapping(uint64 => mapping(address => bool)) public controllers;

    
    
    mapping(uint64 => mapping(string => string)) public messageStorage;

    
    mapping(uint64 => uint64) public pendingNodeOwnerTransfers;

    // ---
    // Constructor
    // ---

    constructor(AccountRegistry _accounts) {
        accounts = _accounts;
    }

    // ---
    // Access control modifiers
    // ---

    
    modifier onlyAuthorized(uint64 nodeId) {
        if (!isAuthorizedAddressForNode(nodeId, msg.sender)) {
            revert NotAuthorizedForNode();
        }
        _;
    }

    // ---
    // Node creation
    // ---

    
    function createNode(
        uint16 nodeType,
        uint64 owner,
        uint64 parent,
        uint64 groupNode,
        address[] memory initialControllers,
        string memory metadata
    ) external returns (uint64 id) {
        // nodeType > 0 is used to check if a node exists
        if (nodeType == 0) revert InvalidNodeCreate();

        // If owner is set, it must be msg.sender.
        if (owner != 0 && owner != accounts.resolveId(msg.sender)) {
            revert NotAuthorizedForNode();
        }

        if (parent != 0) {
            // Ensure parent node exists
            if (nodes[parent].nodeType == 0) {
                revert InvalidNodeCreate();
            }
            // Ensure msg.sender is authorized to manage the parent node.
            if (!isAuthorizedAddressForNode(parent, msg.sender)) {
                revert NotAuthorizedForNode();
            }
        }

        if (groupNode != 0) {
            // Ensure group node exists
            if (nodes[groupNode].nodeType == 0) {
                revert InvalidNodeCreate();
            }
            // Ensure msg.sender is authorized to manage the group node.
            if (!isAuthorizedAddressForNode(groupNode, msg.sender)) {
                revert NotAuthorizedForNode();
            }
        }

        // Create the node.
        id = ++totalNodeCount;
        nodes[id] = NodeData({
            nodeType: nodeType,
            owner: owner,
            parent: parent,
            groupNode: groupNode
        });
        emit NodeCreated(id, nodeType, owner, parent, groupNode, metadata);

        // Add any initial controllers provided.
        for (uint256 i = 0; i < initialControllers.length; i++) {
            address controller = initialControllers[i];
            controllers[id][controller] = true;
            emit NodeControllerSet(id, controller, true);
        }
    }

    // ---
    // Node management
    // ---

    
    function removeNodeOwner(uint64 id) external {
        NodeData memory node = nodes[id];
        uint64 accountId = accounts.resolveId(msg.sender);

        if (node.owner != accountId) {
            revert NotAuthorizedForNode();
        }

        nodes[id].owner = 0;
        delete pendingNodeOwnerTransfers[id];
        emit NodeOwnerSet(id, 0);
    }

    
    /// the existing node owner if there is one, or by the group owner if not.
    /// if newOwner = 0, the node owner transfer will be canceled effectively
    function startNodeOwnerTransfer(uint64 id, uint64 newOwner) external {
        NodeData memory node = nodes[id];
        uint64 accountId = accounts.resolveId(msg.sender);

        // If this node has an owner, it must be msg.sender
        if (node.owner != 0 && node.owner != accountId) {
            revert NotAuthorizedForNode();
        }
        // Else if this node has no owner, node must have a group node and
        // msg.sender must be group node owner. We are only checking the owner
        // here because we do not want to allow controllers to set the owner.
        else if (
            node.owner == 0 &&
            (node.groupNode == 0 || nodes[node.groupNode].owner != accountId)
        ) {
            revert NotAuthorizedForNode();
        }

        // start transfer process
        emit NodeOwnerTransferPending(id, newOwner);
        pendingNodeOwnerTransfers[id] = newOwner;
    }

    
    /// by the new owner
    function completeNodeOwnerTransfer(uint64 id) external {
        uint64 newOwner = pendingNodeOwnerTransfers[id];
        uint64 accountId = accounts.resolveId(msg.sender);

        if (newOwner != accountId) revert NotAuthorizedForNode();

        nodes[id].owner = newOwner;
        delete pendingNodeOwnerTransfers[id];
        emit NodeOwnerSet(id, newOwner);
    }

    
    /// the node, AND authorized to manage the new parent node. This is a
    /// restrictive check, but creative use of future controllers can make it
    /// easier to re-parent a node
    function setParentNode(uint64 id, uint64 parent)
        external
        onlyAuthorized(id)
        onlyAuthorized(parent)
    {
        nodes[id].parent = parent;
        emit NodeParentSet(id, parent);
    }

    
    /// manage the node AND authorized to manage the new group node.
    /// group node.  This is a restrictive check, but creative use of future
    /// controllers can make it easier to re-parent a node
    function setNodeGroupNode(uint64 id, uint64 groupNode)
        external
        onlyAuthorized(id)
        onlyAuthorized(groupNode)
    {
        nodes[id].groupNode = groupNode;
        emit NodeGroupNodeSet(id, groupNode);
    }

    
    /// authorized to manage the node
    function broadcast(
        uint64 id,
        string calldata topic,
        string calldata message
    ) external onlyAuthorized(id) {
        emit NodeBroadcast(id, topic, message);
    }

    
    /// a node. Msg.sender must be authorized to manage the node
    function broadcastAndStore(
        uint64 id,
        string calldata topic,
        string calldata message
    ) external onlyAuthorized(id) {
        emit NodeBroadcast(id, topic, message);
        messageStorage[id][topic] = message;
    }

    
    /// be the node owner or group node owner, controllers cannot add additional
    /// controllers
    function setController(
        uint64 node,
        address controller,
        bool isAuthorized
    ) external {
        // using isAuthorizedAccountForNode here instead of
        // isAuthorizedAddressForNode, we dont want controllers to be able to
        // add additional controllers
        if (!isAuthorizedAccountForNode(node, accounts.resolveId(msg.sender))) {
            revert NotAuthorizedForNode();
        }

        controllers[node][controller] = isAuthorized;
        emit NodeControllerSet(node, controller, isAuthorized);
    }

    // ---
    // Node views
    // ---

    
    function ownerOf(uint64 id) external view returns (uint64) {
        return nodes[id].owner;
    }

    
    function groupNodeOf(uint64 id) external view returns (uint64) {
        return nodes[id].groupNode;
    }

    
    function parentOf(uint64 id) external view returns (uint64) {
        return nodes[id].parent;
    }

    
    /// must own the node, or own the group node of this node
    function isAuthorizedAccountForNode(uint64 node, uint64 account)
        public
        view
        returns (bool isAuthorized)
    {
        NodeData memory mnode = nodes[node];

        // Ensure invalid account or invalid node is always NOT authorized.
        if (account == 0 || mnode.nodeType == 0) {
            isAuthorized = false;
        }
        // If this node is directly owned by the account, then it's authorized.
        else if (mnode.owner == account) {
            isAuthorized = true;
        }
        // If this node's group node is owned by the account, then its
        // authorized. Not checking if groupNode or groupNode owner is zero,
        // since we know account is non-zero
        else if (nodes[mnode.groupNode].owner == account) {
            isAuthorized = true;
        }

        // Otherwise, not authorized.
    }

    
    function isAuthorizedAddressForNode(uint64 node, address subject)
        public
        view
        returns (bool isAuthorized)
    {
        NodeData memory mnode = nodes[node];
        uint64 account = accounts.resolveId(subject);

        // invalid or root node has no authorized addresses
        if (node == 0) {
            isAuthorized = false;
        }
        // If this node is directly owned by the resolved account, then it's
        // authorized.
        else if (mnode.owner == account && account != 0) {
            isAuthorized = true;
        }
        // Else, if this node's group node is owned by the resolved
        // account, then it's authorized.
        else if (nodes[mnode.groupNode].owner == account && account != 0) {
            isAuthorized = true;
        }
        // Else, if the address is authorized to manage the node, then it's
        // authorized
        else if (controllers[node][subject]) {
            isAuthorized = true;
        }
        // Else, if the address is authorized to manage the group node,
        // then it's authorized
        else if (controllers[mnode.groupNode][subject]) {
            isAuthorized = true;
        }

        // Otherise, not authorized.
    }
}