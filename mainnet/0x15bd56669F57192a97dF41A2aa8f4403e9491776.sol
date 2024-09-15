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





abstract contract UnitRegistry is GenericRegistry {
    event CreateUnit(uint256 unitId, UnitType uType, bytes32 unitHash);
    event UpdateUnitHash(uint256 unitId, UnitType uType, bytes32 unitHash);

    enum UnitType {
        Component,
        Agent
    }

    // Unit parameters
    struct Unit {
        // Primary IPFS hash of the unit
        bytes32 unitHash;
        // Set of component dependencies (agents are also based on components)
        // We assume that the system is expected to support no more than 2^32-1 components
        uint32[] dependencies;
    }

    // Type of the unit: component or unit
    UnitType public immutable unitType;
    // Map of unit Id => set of updated IPFS hashes
    mapping(uint256 => bytes32[]) public mapUnitIdHashes;
    // Map of unit Id => set of subcomponents (possible to derive from any registry)
    mapping(uint256 => uint32[]) public mapSubComponents;
    // Map of unit Id => unit
    mapping(uint256 => Unit) public mapUnits;

    constructor(UnitType _unitType) {
        unitType = _unitType;
    }

    
    
    
    function _checkDependencies(uint32[] memory dependencies, uint32 maxUnitId) internal virtual;

    
    
    
    
    
    function create(address unitOwner, bytes32 unitHash, uint32[] memory dependencies)
        external virtual returns (uint256 unitId)
    {
        // Reentrancy guard
        if (_locked > 1) {
            revert ReentrancyGuard();
        }
        _locked = 2;

        // Check for the manager privilege for a unit creation
        if (manager != msg.sender) {
            revert ManagerOnly(msg.sender, manager);
        }

        // Checks for a non-zero owner address
        if(unitOwner == address(0)) {
            revert ZeroAddress();
        }

        // Check for the non-zero hash value
        if (unitHash == 0) {
            revert ZeroValue();
        }
        
        // Check for dependencies validity: must be already allocated, must not repeat
        unitId = totalSupply;
        _checkDependencies(dependencies, uint32(unitId));

        // Unit with Id = 0 is left empty not to do additional checks for the index zero
        unitId++;

        // Initialize the unit and mint its token
        Unit storage unit = mapUnits[unitId];
        unit.unitHash = unitHash;
        unit.dependencies = dependencies;

        // Update the map of subcomponents with calculated subcomponents for the new unit Id
        // In order to get the correct set of subcomponents, we need to differentiate between the callers of this function
        // Self contract (unit registry) can only call subcomponents calculation from the component level
        uint32[] memory subComponentIds = _calculateSubComponents(UnitType.Component, dependencies);
        // We need to add a current component Id to the set of subcomponents if the unit is a component
        // For example, if component 3 (c3) has dependencies of [c1, c2], then the subcomponents will return [c1, c2].
        // The resulting set will be [c1, c2, c3]. So we write into the map of component subcomponents: c3=>[c1, c2, c3].
        // This is done such that the subcomponents start getting explored, and when the agent calls its subcomponents,
        // it would have [c1, c2, c3] right away instead of adding c3 manually and then (for services) checking
        // if another agent also has c3 as a component dependency. The latter will consume additional computation.
        if (unitType == UnitType.Component) {
            uint256 numSubComponents = subComponentIds.length;
            uint32[] memory addSubComponentIds = new uint32[](numSubComponents + 1);
            for (uint256 i = 0; i < numSubComponents; ++i) {
                addSubComponentIds[i] = subComponentIds[i];
            }
            // Adding self component Id
            addSubComponentIds[numSubComponents] = uint32(unitId);
            subComponentIds = addSubComponentIds;
        }
        mapSubComponents[unitId] = subComponentIds;

        // Set total supply to the unit Id number
        totalSupply = unitId;
        // Safe mint is needed since contracts can create units as well
        _safeMint(unitOwner, unitId);

        emit CreateUnit(unitId, unitType, unitHash);
        _locked = 1;
    }

    
    
    
    
    
    function updateHash(address unitOwner, uint256 unitId, bytes32 unitHash) external virtual
        returns (bool success)
    {
        // Check the manager privilege for a unit modification
        if (manager != msg.sender) {
            revert ManagerOnly(msg.sender, manager);
        }

        // Checking the unit ownership
        if (ownerOf(unitId) != unitOwner) {
            if (unitType == UnitType.Component) {
                revert ComponentNotFound(unitId);
            } else {
                revert AgentNotFound(unitId);
            }
        }

        // Check for the hash value
        if (unitHash == 0) {
            revert ZeroValue();
        }

        mapUnitIdHashes[unitId].push(unitHash);
        success = true;

        emit UpdateUnitHash(unitId, unitType, unitHash);
    }

    
    
    
    function getUnit(uint256 unitId) external view virtual returns (Unit memory unit) {
        unit = mapUnits[unitId];
    }

    
    
    
    
    function getDependencies(uint256 unitId) external view virtual
        returns (uint256 numDependencies, uint32[] memory dependencies)
    {
        Unit memory unit = mapUnits[unitId];
        return (unit.dependencies.length, unit.dependencies);
    }

    
    
    
    
    function getUpdatedHashes(uint256 unitId) external view virtual
        returns (uint256 numHashes, bytes32[] memory unitHashes)
    {
        unitHashes = mapUnitIdHashes[unitId];
        return (unitHashes.length, unitHashes);
    }

    
    
    
    
    function getLocalSubComponents(uint256 unitId) external view
        returns (uint32[] memory subComponentIds, uint256 numSubComponents)
    {
        subComponentIds = mapSubComponents[uint256(unitId)];
        numSubComponents = subComponentIds.length;
    }

    
    
    
    
    function _getSubComponents(UnitType subcomponentsFromType, uint32 unitId) internal view virtual
        returns (uint32[] memory subComponentIds);

    
    
    
    
    function _calculateSubComponents(UnitType subcomponentsFromType, uint32[] memory unitIds) internal view virtual
        returns (uint32[] memory subComponentIds)
    {
        uint32 numUnits = uint32(unitIds.length);
        // Array of numbers of components per each unit Id
        uint32[] memory numComponents = new uint32[](numUnits);
        // 2D array of all the sets of components per each unit Id
        uint32[][] memory components = new uint32[][](numUnits);

        // Get total possible number of components and lists of components
        uint32 maxNumComponents;
        for (uint32 i = 0; i < numUnits; ++i) {
            // Get subcomponents for each unit Id based on the subcomponentsFromType
            components[i] = _getSubComponents(subcomponentsFromType, unitIds[i]);
            numComponents[i] = uint32(components[i].length);
            maxNumComponents += numComponents[i];
        }

        // Lists of components are sorted, take unique values in ascending order
        uint32[] memory allComponents = new uint32[](maxNumComponents);
        // Processed component counter
        uint32[] memory processedComponents = new uint32[](numUnits);
        // Minimal component Id
        uint32 minComponent;
        // Overall component counter
        uint32 counter;
        // Iterate until we process all components, at the maximum of the sum of all the components in all units
        for (counter = 0; counter < maxNumComponents; ++counter) {
            // Index of a minimal component
            uint32 minIdxComponent;
            // Amount of components identified as the next minimal component number
            uint32 numComponentsCheck;
            uint32 tryMinComponent = type(uint32).max;
            // Assemble an array of all first components from each component array
            for (uint32 i = 0; i < numUnits; ++i) {
                // Either get a component that has a higher id than the last one ore reach the end of the processed Ids
                for (; processedComponents[i] < numComponents[i]; ++processedComponents[i]) {
                    if (minComponent < components[i][processedComponents[i]]) {
                        // Out of those component Ids that are higher than the last one, pick the minimal one
                        if (components[i][processedComponents[i]] < tryMinComponent) {
                            tryMinComponent = components[i][processedComponents[i]];
                            minIdxComponent = i;
                        }
                        // If we found a minimal component Id, we increase the counter and break to start the search again
                        numComponentsCheck++;
                        break;
                    }
                }
            }
            minComponent = tryMinComponent;

            // If minimal component Id is greater than the last one, it should be added, otherwise we reached the end
            if (numComponentsCheck > 0) {
                allComponents[counter] = minComponent;
                processedComponents[minIdxComponent]++;
            } else {
                break;
            }
        }

        // Return the exact set of found subcomponents with the counter length
        subComponentIds = new uint32[](counter);
        for (uint32 i = 0; i < counter; ++i) {
            subComponentIds[i] = allComponents[i];
        }
    }

    
    
    
    function _getUnitHash(uint256 unitId) internal view override returns (bytes32) {
        return mapUnits[unitId].unitHash;
    }
}
// 
pragma solidity ^0.8.15;





contract ComponentRegistry is UnitRegistry {
    // Component registry version number
    string public constant VERSION = "1.0.0";

    
    
    
    
    constructor(string memory _name, string memory _symbol, string memory _baseURI)
        UnitRegistry(UnitType.Component)
        ERC721(_name, _symbol)
    {
        baseURI = _baseURI;
        owner = msg.sender;
    }

    
    
    
    function _checkDependencies(uint32[] memory dependencies, uint32 maxComponentId) internal virtual override {
        uint32 lastId;
        for (uint256 iDep = 0; iDep < dependencies.length; ++iDep) {
            if (dependencies[iDep] < (lastId + 1) || dependencies[iDep] > maxComponentId) {
                revert ComponentNotFound(dependencies[iDep]);
            }
            lastId = dependencies[iDep];
        }
    }

    
    
    
    
    function _getSubComponents(UnitType, uint32 componentId) internal view virtual override
        returns (uint32[] memory subComponentIds)
    {
        subComponentIds = mapSubComponents[uint256(componentId)];
    }
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
