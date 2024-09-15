// SPDX-License-Identifier: LGPL-3.0-only


// 
pragma solidity ^0.8.0;

struct StateContext {
    bool _writable;
    bytes32 _hash; // writable
    uint256 _startBlock; // writable
    // readable
    uint8 _epoch;
}

struct KeyValuePair {
    bytes key;
    bytes value;
}

// 
pragma solidity ^0.8.0;

interface IERCHandler {
    
    
    
    function _resourceIDToTokenContractAddress(bytes32 resourceID)
        external
        view
        returns (address);

    
    
    
    function setResource(bytes32 resourceID, address contractAddress) external;

    
    
    function setBurnable(address contractAddress) external;

    
    
    function withdraw(bytes memory data) external;
}
// 
pragma solidity ^0.8.0;





contract HandlerHelpers is IERCHandler {
    address public immutable _bridgeAddress;

    // resourceID => token contract address
    mapping(bytes32 => address) public _resourceIDToTokenContractAddress;

    // token contract address => resourceID
    mapping(address => bytes32) public _tokenContractAddressToResourceID;

    // token contract address => is whitelisted
    mapping(address => bool) public _contractWhitelist;

    // token contract address => is burnable
    mapping(address => bool) public _burnList;

    modifier onlyBridge() {
        _onlyBridge();
        _;
    }

    
    constructor(address bridgeAddress) {
        _bridgeAddress = bridgeAddress;
    }

    function _onlyBridge() private view {
        require(msg.sender == _bridgeAddress, "sender must be bridge contract");
    }

    
    /// {_contractAddressToResourceID} with {resourceID},
    /// and {_contractWhitelist} to true for {contractAddress}.
    
    
    function setResource(bytes32 resourceID, address contractAddress)
        external
        override
        onlyBridge
    {
        _setResource(resourceID, contractAddress);
    }

    
    /// to true.
    
    function setBurnable(address contractAddress) external override onlyBridge {
        _setBurnable(contractAddress);
    }

    function withdraw(bytes memory data) external virtual override {}

    function _setResource(bytes32 resourceID, address contractAddress)
        internal
    {
        _resourceIDToTokenContractAddress[resourceID] = contractAddress;
        _tokenContractAddressToResourceID[contractAddress] = resourceID;

        _contractWhitelist[contractAddress] = true;
    }

    function _setBurnable(address contractAddress) internal {
        // solhint-disable-next-line reason-string
        require(
            _contractWhitelist[contractAddress],
            "provided contract is not whitelisted"
        );
        _burnList[contractAddress] = true;
    }
}

// 
pragma solidity ^0.8.0;

interface IExecuteProposal {
    
    
    
    function executeProposal(bytes32 resourceID, bytes calldata data) external;
}

// 
pragma solidity ^0.8.0;

interface IGetRollupInfo {
    function getRollupInfo(
        uint8 originDomainID,
        bytes32 resourceID,
        uint64 nonce
    )
        external
        view
        returns (
            address,
            bytes32,
            uint64
        );
}
// 
pragma solidity ^0.8.0;






contract RollupHandler is IGetRollupInfo, IExecuteProposal, HandlerHelpers {
    constructor(address bridgeAddress) HandlerHelpers(bridgeAddress) {}

    mapping(uint72 => Metadata) public rollupMetadata;

    struct Metadata {
        uint8 domainID;
        bytes32 resourceID;
        uint64 nonce;
        bytes32 rootHash;
        uint64 totalBatches;
    }

    
    ///
    
    /// - It must be called by only bridge.
    /// - {resourceID} must exist.
    /// - {contractAddress} must be allowed.
    /// - {resourceID} must be equal to the resource ID from metadata
    /// - Sender resource ID must exist.
    /// - Sender contract address must be allowed.
    ///
    
    ///
    
    /// len(data)                              uint256     bytes  0  - 32
    /// data                                   bytes       bytes  32 - END
    ///
    
    /// {metaData} is expected to consist of needed function arguments.
    function executeProposal(bytes32 resourceID, bytes calldata data)
        external
        onlyBridge
    {
        address contractAddress = _resourceIDToTokenContractAddress[resourceID];
        require(contractAddress != address(0), "invalid resource ID");
        require(
            _contractWhitelist[contractAddress],
            "not an allowed contract address"
        );

        Metadata memory md = abi.decode(data, (Metadata));
        require(md.resourceID == resourceID, "different resource IDs");

        uint72 nonceAndID = (uint72(md.nonce) << 8) | uint72(md.domainID);
        rollupMetadata[nonceAndID] = md;
    }

    
    ///
    
    /// - {resourceID} must exist.
    /// - {resourceID} must be equal to the resource ID from metadata
    function getRollupInfo(
        uint8 originDomainID,
        bytes32 resourceID,
        uint64 nonce
    )
        external
        view
        returns (
            address,
            bytes32,
            uint64
        )
    {
        address settleableAddress = _resourceIDToTokenContractAddress[
            resourceID
        ];
        require(settleableAddress != address(0), "invalid resource ID");

        uint72 nonceAndID = (uint72(nonce) << 8) | uint72(originDomainID);
        Metadata memory md = rollupMetadata[nonceAndID];
        require(md.resourceID == resourceID, "different resource IDs");

        return (settleableAddress, md.rootHash, md.totalBatches);
    }
}
