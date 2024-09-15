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
pragma solidity 0.8.10;

interface IAuthoriser {
    // function forEditing(address, string memory) external view returns (bool);
    function canRegister(bytes32 node, address sender, bytes[] memory blob) external view returns (bool);
}

// 
pragma solidity 0.8.10;




interface IRulesEngine {
    
    
    
    
    function isLabelValid(bytes32 node, string memory label) external view returns (bool);

    
    
    
    function subnodeOwner(address registrant) external view returns (address);

    
    
    
    
    
    function profileResolver(bytes32 node, string memory label, address registrant) external view returns (address);
}

// 
pragma solidity 0.8.10;

/*
  __  __   U _____ u  _____
U|' \/ '|u \| ___"|/ |___"/u
\| |\/| |/  |  _|"   U_|_ \/
 | |  | |   | |___    ___) |
 |_|  |_|   |_____|  |____/
<<,-,,-.    <<   >>   _// \\
 (./  \.)  (__) (__) (__)(__)

 ______     ______    _______    ________   ______   _________   ______     ________    ______
/_____/\   /_____/\  /______/\  /_______/\ /_____/\ /________/\ /_____/\   /_______/\  /_____/\
\:::_ \ \  \::::_\/_ \::::__\/__\__.::._\/ \::::_\/ \__.::.__\/ \:::_ \ \  \::: _  \ \ \:::_ \ \
 \:(_) ) )_ \:\/___/\ \:\ /____/\  \::\ \   \:\/___/\  \::\ \    \:(_) ) )_ \::(_)  \ \ \:(_) ) )_
  \: __ `\ \ \::___\/_ \:\\_  _\/  _\::\ \__ \_::._\:\  \::\ \    \: __ `\ \ \:: __  \ \ \: __ `\ \
   \ \ `\ \ \ \:\____/\ \:\_\ \ \ /__\::\__/\  /____\:\  \::\ \    \ \ `\ \ \ \:.\ \  \ \ \ \ `\ \ \
    \_\/ \_\/  \_____\/  \_____\/ \________\/  \_____\/   \__\/     \_\/ \_\/  \__\/\__\/  \_\/ \_\/

what
	> register subdomains for your NFT, DAO, or frenclub

from
	> charchar.me3.eth
	> brendan.me3.eth*/







interface IENS {
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    // https://docs.ens.domains/contract-api-reference/ens#set-subdomain-record
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl)
        external
        virtual;

    // https://docs.ens.domains/contract-api-reference/ens#get-owner
    function owner(bytes32 node) external view returns (address);
}

interface IRegistrar {
    
    
    
    
    function register(bytes32 node, string memory label, address owner, bytes[] memory authData) external;

    
    
    
    
    function valid(bytes32 node, string memory label) external view returns (bool);

    
    
    
    
    
    
    function setProjectNode(bytes32 node, IAuthoriser authoriser, IRulesEngine rules, bool enable, address projectOwner)
        external;
}





contract Registrar is IRegistrar, Owned(msg.sender) {
    IENS private ens;
    address private gateway;

    
    mapping(bytes32 => bool) public nodeEnabled;

    
    mapping(bytes32 => IAuthoriser) public nodeAuthorisers;

    
    mapping(bytes32 => IRulesEngine) public nodeRules;

    
    mapping(bytes32 => address) public nodeOwners;

    
    
    
    
    
    event SubnodeRegistered(bytes32 indexed node, bytes32 indexed label, address owner, address registrant);

    
    
    
    
    
    event ProjectStateChanged(bytes32 indexed node, address authoriser, address rules, bool enabled);

    modifier isAuthorised(bytes32 node, address user, bytes[] memory blob) {
        IAuthoriser authoriser = nodeAuthorisers[node];

        require(authoriser.canRegister(node, user, blob), "User is not authorised");
        _;
    }

    modifier permissionedCaller() {
        require(gateway != address(0x0), "Gateway must be set");
        require(msg.sender == owner || msg.sender == gateway, "Caller does not have permission");
        _;
    }

    modifier registeredNode(bytes32 node) {
        require(nodeEnabled[node], "Node is not enabled");
        _;
    }

    constructor(address _registry) {
        ens = IENS(_registry);
    }

    
    
    
    function setGateway(address _gateway) external onlyOwner {
        gateway = _gateway;
    }

    
    
    
    
    
    
    function setProjectNode(bytes32 node, IAuthoriser authoriser, IRulesEngine rules, bool enable, address projectOwner)
        external
        permissionedCaller
    {
        address currentOwner = nodeOwners[node];
        require(currentOwner == projectOwner || currentOwner == address(0x0), "Project owner mismatch");
        emit ProjectStateChanged(node, address(authoriser), address(rules), enable);

        nodeOwners[node] = projectOwner;
        nodeAuthorisers[node] = authoriser;
        nodeRules[node] = rules;
        nodeEnabled[node] = enable;
    }

    
    
    
    
    function register(bytes32 node, string memory label, address owner, bytes[] memory blob)
        public
        registeredNode(node)
        isAuthorised(node, msg.sender, blob)
    {
        require(valid(node, label), "Invalid according to project");
        require(available(node, label), "Label unavailable to register");

        bytes32 hashedLabel = Utilities.labelhash(label);
        address owner = nodeRules[node].subnodeOwner(msg.sender);
        address resolver = nodeRules[node].profileResolver(node, label, msg.sender);
        require(resolver != address(0x0), "Resolver must be set by project");

        emit SubnodeRegistered(node, hashedLabel, owner, msg.sender);
        ens.setSubnodeRecord(node, hashedLabel, owner, resolver, 86400);
    }

    
    
    
    
    function valid(bytes32 node, string memory label) public view returns (bool) {
        return nodeRules[node].isLabelValid(node, label);
    }

    function available(bytes32 node, string memory label) internal view returns (bool) {
        bytes32 fullNode = Utilities.namehash(node, Utilities.labelhash(label));
        return ens.owner(fullNode) == address(0x0);
    }
}

// 
pragma solidity 0.8.10;




library Utilities {
    
    
    
    function labelhash(string memory label) internal pure returns (bytes32) {
        return keccak256(bytes(label));
    }

    
    
    
    
    function namehash(bytes32 node, bytes32 label) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(node, label));
    }
}