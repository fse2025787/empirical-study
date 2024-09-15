// SPDX-License-Identifier: MIT


// 
pragma solidity >=0.8.0;



abstract contract ERC721 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) internal _ownerOf;

    mapping(address => uint256) internal _balanceOf;

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        require((owner = _ownerOf[id]) != address(0), "NOT_MINTED");
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");

        return _balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual {
        address owner = _ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == _ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        if (to.code.length != 0)
            require(
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                    ERC721TokenReceiver.onERC721Received.selector,
                "UNSAFE_RECIPIENT"
            );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        if (to.code.length != 0)
            require(
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                    ERC721TokenReceiver.onERC721Received.selector,
                "UNSAFE_RECIPIENT"
            );
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");

        require(_ownerOf[id] == address(0), "ALREADY_MINTED");

        // Counter overflow is incredibly unrealistic.
        unchecked {
            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id];

        require(owner != address(0), "NOT_MINTED");

        // Ownership check above ensures no underflow.
        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        if (to.code.length != 0)
            require(
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                    ERC721TokenReceiver.onERC721Received.selector,
                "UNSAFE_RECIPIENT"
            );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        if (to.code.length != 0)
            require(
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                    ERC721TokenReceiver.onERC721Received.selector,
                "UNSAFE_RECIPIENT"
            );
    }
}

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






abstract contract GenericRegistry is IErrorsRegistries, ERC721 {
    event OwnerUpdated(address indexed owner);
    event ManagerUpdated(address indexed manager);
    event BaseURIChanged(string baseURI);

    // Owner address
    address public owner;
    // Unit manager
    address public manager;
    // Base URI
    string public baseURI;
    // Unit counter
    uint256 public totalSupply;
    // Reentrancy lock
    uint256 internal _locked = 1;
    // To better understand the CID anatomy, please refer to: https://proto.school/anatomy-of-a-cid/05
    // CID = <multibase_encoding>multibase_encoding(<cid-version><multicodec><multihash-algorithm><multihash-length><multihash-hash>)
    // CID prefix = <multibase_encoding>multibase_encoding(<cid-version><multicodec><multihash-algorithm><multihash-length>)
    // to complement the multibase_encoding(<multihash-hash>)
    // multibase_encoding = base16 = "f"
    // cid-version = version 1 = "0x01"
    // multicodec = dag-pb = "0x70"
    // multihash-algorithm = sha2-256 = "0x12"
    // multihash-length = 256 bits = "0x20"
    string public constant CID_PREFIX = "f01701220";

    
    
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

    
    
    function changeManager(address newManager) external virtual {
        if (msg.sender != owner) {
            revert OwnerOnly(msg.sender, owner);
        }

        // Check for the zero address
        if (newManager == address(0)) {
            revert ZeroAddress();
        }

        manager = newManager;
        emit ManagerUpdated(newManager);
    }

    
    
    
    
    function exists(uint256 unitId) external view virtual returns (bool) {
        return unitId > 0 && unitId < (totalSupply + 1);
    }
    
    
    
    function setBaseURI(string memory bURI) external virtual {
        // Check for the ownership
        if (msg.sender != owner) {
            revert OwnerOnly(msg.sender, owner);
        }

        // Check for the zero value
        if (bytes(bURI).length == 0) {
            revert ZeroValue();
        }

        baseURI = bURI;
        emit BaseURIChanged(bURI);
    }

    
    
    
    
    function tokenByIndex(uint256 id) external view virtual returns (uint256 unitId) {
        unitId = id + 1;
        if (unitId > totalSupply) {
            revert Overflow(unitId, totalSupply);
        }
    }

    // Open sourced from: https://stackoverflow.com/questions/67893318/solidity-how-to-represent-bytes32-as-string
    
    
    
    
    function _toHex16(bytes16 data) internal pure returns (bytes32 result) {
        result = bytes32 (data) & 0xFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000 |
        (bytes32 (data) & 0x0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000000000) >> 64;
        result = result & 0xFFFFFFFF000000000000000000000000FFFFFFFF000000000000000000000000 |
        (result & 0x00000000FFFFFFFF000000000000000000000000FFFFFFFF0000000000000000) >> 32;
        result = result & 0xFFFF000000000000FFFF000000000000FFFF000000000000FFFF000000000000 |
        (result & 0x0000FFFF000000000000FFFF000000000000FFFF000000000000FFFF00000000) >> 16;
        result = result & 0xFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000 |
        (result & 0x00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000) >> 8;
        result = (result & 0xF000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000) >> 4 |
        (result & 0x0F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F00) >> 8;
        result = bytes32 (0x3030303030303030303030303030303030303030303030303030303030303030 +
        uint256 (result) +
            (uint256 (result) + 0x0606060606060606060606060606060606060606060606060606060606060606 >> 4 &
            0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F) * 39);
    }

    
    
    
    function _getUnitHash(uint256 unitId) internal view virtual returns (bytes32);

    
    
    
    
    function tokenURI(uint256 unitId) public view virtual override returns (string memory) {
        bytes32 unitHash = _getUnitHash(unitId);
        // Parse 2 parts of bytes32 into left and right hex16 representation, and concatenate into string
        // adding the base URI and a cid prefix for the full base16 multibase prefix IPFS hash representation
        return string(abi.encodePacked(baseURI, CID_PREFIX, _toHex16(bytes16(unitHash)),
            _toHex16(bytes16(unitHash << 128))));
    }
}
// 
pragma solidity ^0.8.15;





// This struct is 128 bits in total
struct AgentParams {
    // Number of agent instances. This number is limited by the number of agent instances
    uint32 slots;
    // Bond per agent instance. This is enough for 1b+ ETH or 1e27
    uint96 bond;
}

// This struct is 192 bits in total
struct AgentInstance {
    // Address of an agent instance
    address instance;
    // Canonical agent Id. This number is limited by the max number of agent Ids (see UnitRegistry contract)
    uint32 agentId;
}



contract ServiceRegistry is GenericRegistry {
    event DrainerUpdated(address indexed drainer);
    event Deposit(address indexed sender, uint256 amount);
    event Refund(address indexed receiver, uint256 amount);
    event CreateService(uint256 indexed serviceId);
    event UpdateService(uint256 indexed serviceId, bytes32 configHash);
    event RegisterInstance(address indexed operator, uint256 indexed serviceId, address indexed agentInstance, uint256 agentId);
    event CreateMultisigWithAgents(uint256 indexed serviceId, address indexed multisig);
    event ActivateRegistration(uint256 indexed serviceId);
    event TerminateService(uint256 indexed serviceId);
    event OperatorSlashed(uint256 amount, address indexed operator, uint256 indexed serviceId);
    event OperatorUnbond(address indexed operator, uint256 indexed serviceId);
    event DeployService(uint256 indexed serviceId);
    event Drain(address indexed drainer, uint256 amount);

    enum ServiceState {
        NonExistent,
        PreRegistration,
        ActiveRegistration,
        FinishedRegistration,
        Deployed,
        TerminatedBonded
    }

    // Service parameters
    struct Service {
        // Registration activation deposit
        // This is enough for 1b+ ETH or 1e27
        uint96 securityDeposit;
        // Multisig address for agent instances
        address multisig;
        // IPFS hashes pointing to the config metadata
        bytes32 configHash;
        // Agent instance signers threshold: must no less than ceil((n * 2 + 1) / 3) of all the agent instances combined
        // This number will be enough to have ((2^32 - 1) * 3 - 1) / 2, which is bigger than 6.44b
        uint32 threshold;
        // Total number of agent instances. We assume that the number of instances is bounded by 2^32 - 1
        uint32 maxNumAgentInstances;
        // Actual number of agent instances. This number is less or equal to maxNumAgentInstances
        uint32 numAgentInstances;
        // Service state
        ServiceState state;
        // Canonical agent Ids for the service. Individual agent Id is bounded by the max number of agent Id
        uint32[] agentIds;
    }

    // Agent Registry address
    address public immutable agentRegistry;
    // The amount of funds slashed. This is enough for 1b+ ETH or 1e27
    uint96 public slashedFunds;
    // Drainer address: set by the government and is allowed to drain ETH funds accumulated in this contract
    address public drainer;
    // Service registry version number
    string public constant VERSION = "1.0.0";
    // Map of service Id => set of IPFS hashes pointing to the config metadata
    mapping (uint256 => bytes32[]) public mapConfigHashes;
    // Map of operator address and serviceId => set of registered agent instance addresses
    mapping(uint256 => AgentInstance[]) public mapOperatorAndServiceIdAgentInstances;
    // Service Id and canonical agent Id => number of agent instances and correspondent instance registration bond
    mapping(uint256 => AgentParams) public mapServiceAndAgentIdAgentParams;
    // Actual agent instance addresses. Service Id and canonical agent Id => Set of agent instance addresses.
    mapping(uint256 => address[]) public mapServiceAndAgentIdAgentInstances;
    // Map of operator address and serviceId => agent instance bonding / escrow balance
    mapping(uint256 => uint96) public mapOperatorAndServiceIdOperatorBalances;
    // Map of agent instance address => service id it is registered with and operator address that supplied the instance
    mapping (address => address) public mapAgentInstanceOperators;
    // Map of service Id => set of unique component Ids
    // Updated during the service deployment via deploy() function
    mapping (uint256 => uint32[]) public mapServiceIdSetComponentIds;
    // Map of service Id => set of unique agent Ids
    mapping (uint256 => uint32[]) public mapServiceIdSetAgentIds;
    // Map of policy for multisig implementations
    mapping (address => bool) public mapMultisigs;
    // Map of service counter => service
    mapping (uint256 => Service) public mapServices;

    
    
    
    
    
    constructor(string memory _name, string memory _symbol, string memory _baseURI, address _agentRegistry)
        ERC721(_name, _symbol)
    {
        baseURI = _baseURI;
        agentRegistry = _agentRegistry;
        owner = msg.sender;
    }

    
    
    function changeDrainer(address newDrainer) external {
        if (msg.sender != owner) {
            revert OwnerOnly(msg.sender, owner);
        }

        // Check for the zero address
        if (newDrainer == address(0)) {
            revert ZeroAddress();
        }

        drainer = newDrainer;
        emit DrainerUpdated(newDrainer);
    }

    
    
    
    
    function _initialChecks(
        bytes32 configHash,
        uint32[] memory agentIds,
        AgentParams[] memory agentParams
    ) private view
    {
        // Check for the non-zero hash value
        if (configHash == 0) {
            revert ZeroValue();
        }

        // Checking for non-empty arrays and correct number of values in them
        if (agentIds.length == 0 || agentIds.length != agentParams.length) {
            revert WrongArrayLength(agentIds.length, agentParams.length);
        }

        // Check for duplicate canonical agent Ids
        uint256 agentTotalSupply = IRegistry(agentRegistry).totalSupply();
        uint256 lastId;
        for (uint256 i = 0; i < agentIds.length; i++) {
            if (agentIds[i] < (lastId + 1) || agentIds[i] > agentTotalSupply) {
                revert WrongAgentId(agentIds[i]);
            }
            lastId = agentIds[i];
        }
    }

    
    
    
    
    
    
    function _setServiceData(
        Service memory service,
        uint32[] memory agentIds,
        AgentParams[] memory agentParams,
        uint256 size,
        uint256 serviceId
    ) private
    {
        // Security deposit
        uint96 securityDeposit;
        // Add canonical agent Ids for the service and the slots map
        service.agentIds = new uint32[](size);
        for (uint256 i = 0; i < size; i++) {
            service.agentIds[i] = agentIds[i];
            // Push a pair of key defining variables into one key. Service or agent Ids are not enough by themselves
            // As with other units, we assume that the system is not expected to support more than than 2^32-1 services
            // Need to carefully check pairings, since it's hard to find if something is incorrectly misplaced bitwise
            // serviceId occupies first 32 bits
            uint256 serviceAgent = serviceId;
            // agentId takes the second 32 bits
            serviceAgent |= uint256(agentIds[i]) << 32;
            mapServiceAndAgentIdAgentParams[serviceAgent] = agentParams[i];
            service.maxNumAgentInstances += agentParams[i].slots;
            // Security deposit is the maximum of the canonical agent registration bond
            if (agentParams[i].bond > securityDeposit) {
                securityDeposit = agentParams[i].bond;
            }
        }
        service.securityDeposit = securityDeposit;

        // Check for the correct threshold: no less than ceil((n * 2 + 1) / 3) of all the agent instances combined
        uint256 checkThreshold = uint256(service.maxNumAgentInstances * 2 + 1);
        if (checkThreshold % 3 == 0) {
            checkThreshold = checkThreshold / 3;
        } else {
            checkThreshold = checkThreshold / 3 + 1;
        }
        if (service.threshold < checkThreshold || service.threshold > service.maxNumAgentInstances) {
            revert WrongThreshold(service.threshold, checkThreshold, service.maxNumAgentInstances);
        }
    }

    
    
    
    
    
    
    
    function create(
        address serviceOwner,
        bytes32 configHash,
        uint32[] memory agentIds,
        AgentParams[] memory agentParams,
        uint32 threshold
    ) external returns (uint256 serviceId)
    {
        // Reentrancy guard
        if (_locked > 1) {
            revert ReentrancyGuard();
        }
        _locked = 2;

        // Check for the manager privilege for a service management
        if (manager != msg.sender) {
            revert ManagerOnly(msg.sender, manager);
        }

        // Check for the non-empty service owner address
        if (serviceOwner == address(0)) {
            revert ZeroAddress();
        }

        // Execute initial checks
        _initialChecks(configHash, agentIds, agentParams);

        // Check that there are no zero number of slots for a specific canonical agent id and no zero registration bond
        for (uint256 i = 0; i < agentIds.length; i++) {
            if (agentParams[i].slots == 0 || agentParams[i].bond == 0) {
                revert ZeroValue();
            }
        }

        // Create a new service Id
        serviceId = totalSupply;
        serviceId++;

        // Set high-level data components of the service instance
        Service memory service;
        // Updating high-level data components of the service
        service.threshold = threshold;
        // Assigning the initial hash
        service.configHash = configHash;
        // Set the initial service state
        service.state = ServiceState.PreRegistration;

        // Set service data
        _setServiceData(service, agentIds, agentParams, agentIds.length, serviceId);
        mapServices[serviceId] = service;
        totalSupply = serviceId;

        // Mint the service instance to the service owner and record the service structure
        _safeMint(serviceOwner, serviceId);

        emit CreateService(serviceId);

        _locked = 1;
    }

    
    
    
    
    
    
    
    
    function update(
        address serviceOwner,
        bytes32 configHash,
        uint32[] memory agentIds,
        AgentParams[] memory agentParams,
        uint32 threshold,
        uint256 serviceId
    ) external returns (bool success)
    {
        // Check for the manager privilege for a service management
        if (manager != msg.sender) {
            revert ManagerOnly(msg.sender, manager);
        }

        // Check for the service ownership
        address actualOwner = ownerOf(serviceId);
        if (actualOwner != serviceOwner) {
            revert OwnerOnly(serviceOwner, actualOwner);
        }

        Service memory service = mapServices[serviceId];
        if (service.state != ServiceState.PreRegistration) {
            revert WrongServiceState(uint256(service.state), serviceId);
        }

        // Execute initial checks
        _initialChecks(configHash, agentIds, agentParams);

        // Updating high-level data components of the service
        service.threshold = threshold;
        service.maxNumAgentInstances = 0;

        // Collect non-zero canonical agent ids and slots / costs, remove any canonical agent Ids from the params map
        uint32[] memory newAgentIds = new uint32[](agentIds.length);
        AgentParams[] memory newAgentParams = new AgentParams[](agentIds.length);
        uint256 size;
        for (uint256 i = 0; i < agentIds.length; i++) {
            if (agentParams[i].slots == 0) {
                // Push a pair of key defining variables into one key. Service or agent Ids are not enough by themselves
                // serviceId occupies first 32 bits, agentId gets the next 32 bits
                uint256 serviceAgent = serviceId;
                serviceAgent |= uint256(agentIds[i]) << 32;
                delete mapServiceAndAgentIdAgentParams[serviceAgent];
            } else {
                newAgentIds[size] = agentIds[i];
                newAgentParams[size] = agentParams[i];
                size++;
            }
        }
        // Check if the previous hash is the same / hash was not updated
        bytes32 lastConfigHash = service.configHash;
        if (lastConfigHash != configHash) {
            mapConfigHashes[serviceId].push(lastConfigHash);
            service.configHash = configHash;
        }

        // Set service data and record the modified service struct
        _setServiceData(service, newAgentIds, newAgentParams, size, serviceId);
        mapServices[serviceId] = service;

        emit UpdateService(serviceId, configHash);
        success = true;
    }

    
    
    
    
    function activateRegistration(address serviceOwner, uint256 serviceId) external payable returns (bool success)
    {
        // Check for the manager privilege for a service management
        if (manager != msg.sender) {
            revert ManagerOnly(msg.sender, manager);
        }

        // Check for the service ownership
        address actualOwner = ownerOf(serviceId);
        if (actualOwner != serviceOwner) {
            revert OwnerOnly(serviceOwner, actualOwner);
        }

        Service storage service = mapServices[serviceId];
        // Service must be inactive
        if (service.state != ServiceState.PreRegistration) {
            revert ServiceMustBeInactive(serviceId);
        }

        if (msg.value != service.securityDeposit) {
            revert IncorrectRegistrationDepositValue(msg.value, service.securityDeposit, serviceId);
        }

        // Activate the agent instance registration
        service.state = ServiceState.ActiveRegistration;

        emit ActivateRegistration(serviceId);
        success = true;
    }

    
    
    
    
    
    
    function registerAgents(
        address operator,
        uint256 serviceId,
        address[] memory agentInstances,
        uint32[] memory agentIds
    ) external payable returns (bool success)
    {
        // Check for the manager privilege for a service management
        if (manager != msg.sender) {
            revert ManagerOnly(msg.sender, manager);
        }

        // Check if the length of canonical agent instance addresses array and ids array have the same length
        if (agentInstances.length != agentIds.length) {
            revert WrongArrayLength(agentInstances.length, agentIds.length);
        }

        Service storage service = mapServices[serviceId];
        // The service has to be active to register agents
        if (service.state != ServiceState.ActiveRegistration) {
            revert WrongServiceState(uint256(service.state), serviceId);
        }

        // Check for the sufficient amount of bond fee is provided
        uint256 numAgents = agentInstances.length;
        uint256 totalBond = 0;
        for (uint256 i = 0; i < numAgents; ++i) {
            // Check if canonical agent Id exists in the service
            // Push a pair of key defining variables into one key. Service or agent Ids are not enough by themselves
            // serviceId occupies first 32 bits, agentId gets the next 32 bits
            uint256 serviceAgent = serviceId;
            serviceAgent |= uint256(agentIds[i]) << 32;
            AgentParams memory agentParams = mapServiceAndAgentIdAgentParams[serviceAgent];
            if (agentParams.slots == 0) {
                revert AgentNotInService(agentIds[i], serviceId);
            }
            totalBond += agentParams.bond;
        }
        if (msg.value != totalBond) {
            revert IncorrectAgentBondingValue(msg.value, totalBond, serviceId);
        }

        // Operator address must not be used as an agent instance anywhere else
        if (mapAgentInstanceOperators[operator] != address(0)) {
            revert WrongOperator(serviceId);
        }

        // Push a pair of key defining variables into one key. Service Id or operator are not enough by themselves
        // operator occupies first 160 bits
        uint256 operatorService = uint256(uint160(operator));
        // serviceId occupies next 32 bits assuming it is not greater than 2^32 - 1 in value
        operatorService |= serviceId << 160;
        for (uint256 i = 0; i < numAgents; ++i) {
            address agentInstance = agentInstances[i];
            uint32 agentId = agentIds[i];

            // Operator address must be different from agent instance one
            if (operator == agentInstance) {
                revert WrongOperator(serviceId);
            }

            // Check if the agent instance is already engaged with another service
            if (mapAgentInstanceOperators[agentInstance] != address(0)) {
                revert AgentInstanceRegistered(mapAgentInstanceOperators[agentInstance]);
            }

            // Check if there is an empty slot for the agent instance in this specific service
            // serviceId occupies first 32 bits, agentId gets the next 32 bits
            uint256 serviceAgent = serviceId;
            serviceAgent |= uint256(agentIds[i]) << 32;
            if (mapServiceAndAgentIdAgentInstances[serviceAgent].length == mapServiceAndAgentIdAgentParams[serviceAgent].slots) {
                revert AgentInstancesSlotsFilled(serviceId);
            }

            // Add agent instance and operator and set the instance engagement
            mapServiceAndAgentIdAgentInstances[serviceAgent].push(agentInstance);
            mapOperatorAndServiceIdAgentInstances[operatorService].push(AgentInstance(agentInstance, agentId));
            service.numAgentInstances++;
            mapAgentInstanceOperators[agentInstance] = operator;

            emit RegisterInstance(operator, serviceId, agentInstance, agentId);
        }

        // If the service agent instance capacity is reached, the service becomes finished-registration
        if (service.numAgentInstances == service.maxNumAgentInstances) {
            service.state = ServiceState.FinishedRegistration;
        }

        // Update operator's bonding balance
        mapOperatorAndServiceIdOperatorBalances[operatorService] += uint96(msg.value);

        emit Deposit(operator, msg.value);
        success = true;
    }

    
    
    
    
    
    
    function deploy(
        address serviceOwner,
        uint256 serviceId,
        address multisigImplementation,
        bytes memory data
    ) external returns (address multisig)
    {
        // Reentrancy guard
        if (_locked > 1) {
            revert ReentrancyGuard();
        }
        _locked = 2;

        // Check for the manager privilege for a service management
        if (manager != msg.sender) {
            revert ManagerOnly(msg.sender, manager);
        }

        // Check for the service ownership
        address actualOwner = ownerOf(serviceId);
        if (actualOwner != serviceOwner) {
            revert OwnerOnly(serviceOwner, actualOwner);
        }

        // Check for the whitelisted multisig implementation
        if (!mapMultisigs[multisigImplementation]) {
            revert UnauthorizedMultisig(multisigImplementation);
        }

        Service storage service = mapServices[serviceId];
        if (service.state != ServiceState.FinishedRegistration) {
            revert WrongServiceState(uint256(service.state), serviceId);
        }

        // Get all agent instances for the multisig
        address[] memory agentInstances = _getAgentInstances(service, serviceId);

        // Create a multisig with agent instances
        multisig = IMultisig(multisigImplementation).create(agentInstances, service.threshold, data);

        // Update maps of service Id to subcomponent and agent Ids
        mapServiceIdSetAgentIds[serviceId] = service.agentIds;
        mapServiceIdSetComponentIds[serviceId] = IRegistry(agentRegistry).calculateSubComponents(service.agentIds);

        service.multisig = multisig;
        service.state = ServiceState.Deployed;

        emit CreateMultisigWithAgents(serviceId, multisig);
        emit DeployService(serviceId);

        _locked = 1;
    }

    
    
    
    
    
    function slash(address[] memory agentInstances, uint96[] memory amounts, uint256 serviceId) external
        returns (bool success)
    {
        // Check if the service is deployed
        // Since we do not kill (burn) services, we want this check to happen in a right service state.
        // If the service is deployed, it definitely exists and is running. We do not want this function to be abused
        // when the service was deployed, then terminated, then in a sleep mode or before next deployment somebody
        // could use this function and try to slash operators.
        Service memory service = mapServices[serviceId];
        if (service.state != ServiceState.Deployed) {
            revert WrongServiceState(uint256(service.state), serviceId);
        }

        // Check for the array size
        if (agentInstances.length != amounts.length) {
            revert WrongArrayLength(agentInstances.length, amounts.length);
        }

        // Only the multisig of a correspondent address can slash its agent instances
        if (msg.sender != service.multisig) {
            revert OnlyOwnServiceMultisig(msg.sender, service.multisig, serviceId);
        }

        // Loop over each agent instance
        uint256 numInstancesToSlash = agentInstances.length;
        for (uint256 i = 0; i < numInstancesToSlash; ++i) {
            // Get the service Id from the agentInstance map
            address operator = mapAgentInstanceOperators[agentInstances[i]];
            // Push a pair of key defining variables into one key. Service Id or operator are not enough by themselves
            // operator occupies first 160 bits
            uint256 operatorService = uint256(uint160(operator));
            // serviceId occupies next 32 bits
            operatorService |= serviceId << 160;
            // Slash the balance of the operator, make sure it does not go below zero
            uint96 balance = mapOperatorAndServiceIdOperatorBalances[operatorService];
            if ((amounts[i] + 1) > balance) {
                // We cannot add to the slashed amount more than the balance of the operator
                slashedFunds += balance;
                balance = 0;
            } else {
                slashedFunds += amounts[i];
                balance -= amounts[i];
            }
            mapOperatorAndServiceIdOperatorBalances[operatorService] = balance;

            emit OperatorSlashed(amounts[i], operator, serviceId);
        }
        success = true;
    }

    
    
    
    
    
    function terminate(address serviceOwner, uint256 serviceId) external returns (bool success, uint256 refund)
    {
        // Reentrancy guard
        if (_locked > 1) {
            revert ReentrancyGuard();
        }
        _locked = 2;

        // Check for the manager privilege for a service management
        if (manager != msg.sender) {
            revert ManagerOnly(msg.sender, manager);
        }

        // Check for the service ownership
        address actualOwner = ownerOf(serviceId);
        if (actualOwner != serviceOwner) {
            revert OwnerOnly(serviceOwner, actualOwner);
        }

        Service storage service = mapServices[serviceId];
        // Check if the service is already terminated
        if (service.state == ServiceState.PreRegistration || service.state == ServiceState.TerminatedBonded) {
            revert WrongServiceState(uint256(service.state), serviceId);
        }
        // Define the state of the service depending on the number of bonded agent instances
        if (service.numAgentInstances > 0) {
            service.state = ServiceState.TerminatedBonded;
        } else {
            service.state = ServiceState.PreRegistration;
        }
        
        // Delete the sensitive data
        delete mapServiceIdSetComponentIds[serviceId];
        delete mapServiceIdSetAgentIds[serviceId];
        for (uint256 i = 0; i < service.agentIds.length; ++i) {
            // serviceId occupies first 32 bits, agentId gets the next 32 bits
            uint256 serviceAgent = serviceId;
            serviceAgent |= uint256(service.agentIds[i]) << 32;
            delete mapServiceAndAgentIdAgentInstances[serviceAgent];
        }

        // Return registration deposit back to the service owner
        refund = service.securityDeposit;
        // By design, the refund is always a non-zero value, so no check is needed here fo that
        (bool result, ) = serviceOwner.call{value: refund}("");
        if (!result) {
            revert TransferFailed(address(0), address(this), serviceOwner, refund);
        }

        emit Refund(serviceOwner, refund);
        emit TerminateService(serviceId);
        success = true;

        _locked = 1;
    }

    
    
    
    
    
    function unbond(address operator, uint256 serviceId) external returns (bool success, uint256 refund) {
        // Reentrancy guard
        if (_locked > 1) {
            revert ReentrancyGuard();
        }
        _locked = 2;

        // Check for the manager privilege for a service management
        if (manager != msg.sender) {
            revert ManagerOnly(msg.sender, manager);
        }

        // Checks if the operator address is not zero
        if (operator == address(0)) {
            revert ZeroAddress();
        }

        Service storage service = mapServices[serviceId];
        // Service can only be in the terminated-bonded state or expired-registration in order to proceed
        if (service.state != ServiceState.TerminatedBonded) {
            revert WrongServiceState(uint256(service.state), serviceId);
        }

        // Check for the operator and unbond all its agent instances
        // Push a pair of key defining variables into one key. Service Id or operator are not enough by themselves
        // operator occupies first 160 bits
        uint256 operatorService = uint256(uint160(operator));
        // serviceId occupies next 32 bits
        operatorService |= serviceId << 160;
        AgentInstance[] memory agentInstances = mapOperatorAndServiceIdAgentInstances[operatorService];
        uint256 numAgentsUnbond = agentInstances.length;
        if (numAgentsUnbond == 0) {
            revert OperatorHasNoInstances(operator, serviceId);
        }

        // Subtract number of unbonded agent instances
        service.numAgentInstances -= uint32(numAgentsUnbond);
        // When number of instances is equal to zero, all the operators have unbonded and the service is moved into
        // the PreRegistration state, from where it can be updated / start registration / get deployed again
        if (service.numAgentInstances == 0) {
            service.state = ServiceState.PreRegistration;
        }
        // else condition is redundant here, since the service is either in the TerminatedBonded state, or moved
        // into the PreRegistration state and unbonding is not possible before the new TerminatedBonded state is reached

        // Calculate registration refund and free all agent instances
        for (uint256 i = 0; i < numAgentsUnbond; i++) {
            // serviceId occupies first 32 bits, agentId gets the next 32 bits
            uint256 serviceAgent = serviceId;
            serviceAgent |= uint256(agentInstances[i].agentId) << 32;
            refund += mapServiceAndAgentIdAgentParams[serviceAgent].bond;
            // Clean-up the sensitive data such that it is not reused later
            delete mapAgentInstanceOperators[agentInstances[i].instance];
        }
        // Clean all the operator agent instances records for this service
        delete mapOperatorAndServiceIdAgentInstances[operatorService];

        // Calculate the refund
        uint96 balance = mapOperatorAndServiceIdOperatorBalances[operatorService];
        // This situation is possible if the operator was slashed for the agent instance misbehavior
        if (refund > balance) {
            refund = balance;
        }

        // Refund the operator
        if (refund > 0) {
            // Operator's balance is essentially zero after the refund
            mapOperatorAndServiceIdOperatorBalances[operatorService] = 0;
            // Send the refund
            (bool result, ) = operator.call{value: refund}("");
            if (!result) {
                revert TransferFailed(address(0), address(this), operator, refund);
            }
            emit Refund(operator, refund);
        }

        emit OperatorUnbond(operator, serviceId);
        success = true;

        _locked = 1;
    }

    
    
    
    function getService(uint256 serviceId) external view returns (Service memory service) {
        service = mapServices[serviceId];
    }

    
    
    
    
    function getAgentParams(uint256 serviceId) external view
        returns (uint256 numAgentIds, AgentParams[] memory agentParams)
    {
        Service memory service = mapServices[serviceId];
        numAgentIds = service.agentIds.length;
        agentParams = new AgentParams[](numAgentIds);
        for (uint256 i = 0; i < numAgentIds; ++i) {
            uint256 serviceAgent = serviceId;
            serviceAgent |= uint256(service.agentIds[i]) << 32;
            agentParams[i] = mapServiceAndAgentIdAgentParams[serviceAgent];
        }
    }

    
    
    
    
    
    function getInstancesForAgentId(uint256 serviceId, uint256 agentId) external view
        returns (uint256 numAgentInstances, address[] memory agentInstances)
    {
        uint256 serviceAgent = serviceId;
        serviceAgent |= agentId << 32;
        numAgentInstances = mapServiceAndAgentIdAgentInstances[serviceAgent].length;
        agentInstances = new address[](numAgentInstances);
        for (uint256 i = 0; i < numAgentInstances; i++) {
            agentInstances[i] = mapServiceAndAgentIdAgentInstances[serviceAgent][i];
        }
    }

    
    
    
    
    function _getAgentInstances(Service memory service, uint256 serviceId) private view
        returns (address[] memory agentInstances)
    {
        agentInstances = new address[](service.numAgentInstances);
        uint256 count;
        for (uint256 i = 0; i < service.agentIds.length; i++) {
            // serviceId occupies first 32 bits, agentId gets the next 32 bits
            uint256 serviceAgent = serviceId;
            serviceAgent |= uint256(service.agentIds[i]) << 32;
            for (uint256 j = 0; j < mapServiceAndAgentIdAgentInstances[serviceAgent].length; j++) {
                agentInstances[count] = mapServiceAndAgentIdAgentInstances[serviceAgent][j];
                count++;
            }
        }
    }

    
    
    
    
    function getAgentInstances(uint256 serviceId) external view
        returns (uint256 numAgentInstances, address[] memory agentInstances)
    {
        Service memory service = mapServices[serviceId];
        agentInstances = _getAgentInstances(service, serviceId);
        numAgentInstances = agentInstances.length;
    }

    
    
    
    
    function getPreviousHashes(uint256 serviceId) external view
        returns (uint256 numHashes, bytes32[] memory configHashes)
    {
        configHashes = mapConfigHashes[serviceId];
        numHashes = configHashes.length;
    }

    
    
    
    
    
    function getUnitIdsOfService(IRegistry.UnitType unitType, uint256 serviceId) external view
        returns (uint256 numUnitIds, uint32[] memory unitIds)
    {
        if (unitType == IRegistry.UnitType.Component) {
            unitIds = mapServiceIdSetComponentIds[serviceId];
        } else {
            unitIds = mapServiceIdSetAgentIds[serviceId];
        }
        numUnitIds = unitIds.length;
    }

    
    
    
    
    function getOperatorBalance(address operator, uint256 serviceId) external view returns (uint256 balance)
    {
        uint256 operatorService = uint256(uint160(operator));
        operatorService |= serviceId << 160;
        balance = mapOperatorAndServiceIdOperatorBalances[operatorService];
    }

    
    
    
    
    function changeMultisigPermission(address multisig, bool permission) external returns (bool success) {
        // Check for the contract ownership
        if (msg.sender != owner) {
            revert OwnerOnly(msg.sender, owner);
        }

        if (multisig == address(0)) {
            revert ZeroAddress();
        }
        mapMultisigs[multisig] = permission;
        success = true;
    }

    
    
    function drain() external returns (uint256 amount) {
        // Reentrancy guard
        if (_locked > 1) {
            revert ReentrancyGuard();
        }
        _locked = 2;

        // Check for the drainer address
        if (msg.sender != drainer) {
            revert ManagerOnly(msg.sender, drainer);
        }

        // Drain the slashed funds
        amount = slashedFunds;
        if (amount > 0) {
            slashedFunds = 0;
            // Send the refund
            (bool result, ) = msg.sender.call{value: amount}("");
            if (!result) {
                revert TransferFailed(address(0), address(this), msg.sender, amount);
            }
            emit Drain(msg.sender, amount);
        }

        _locked = 1;
    }

    
    
    
    function _getUnitHash(uint256 serviceId) internal view override returns (bytes32) {
        return mapServices[serviceId].configHash;
    }
}

// 
pragma solidity ^0.8.15;


interface IMultisig {
    
    
    
    
    
    function create(
        address[] memory owners,
        uint256 threshold,
        bytes memory data
    ) external returns (address multisig);
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



abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
