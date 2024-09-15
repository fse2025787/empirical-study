// SPDX-License-Identifier: MIT


// 
pragma solidity 0.8.15;

interface IBase {
    error TransfersPaused();
    error CallerNotEoA();
    error EmptyString();
    /**
        RBAC
    */
    error CallerNotAuthorized();
    event TransfersLockedChanged(address indexed sender, bool locked);
}

// 
pragma solidity 0.8.15;







abstract contract Base is IBase {
    AppStorage internal s;
    uint256 private constant MAX_UINT = type(uint256).max;

    modifier onlyEoA() {
         // solhint-disable-next-line avoid-tx-origin
        if(tx.origin != msg.sender) revert CallerNotEoA();
        _;
    }

    modifier isTransferable() {
        if(!s.nftStorage.transfersEnabled) revert TransfersPaused();
        _;
    }

    modifier tokenLocked(uint256 tokenId) {
        if(s.nftStorage.lockedTokens[tokenId]) revert ISecurity.TokenLocked();
        _;
    }

    
    
    
    modifier isEmpty(string calldata string_) {
        if (bytes(string_).length == 0 ) revert EmptyString();
        _;
    }
}

// 
pragma solidity 0.8.15;

interface IApproval {
    error InvalidApprovalZeroAddress();
    error CallerNotOwnerOrApprovedOperator();

    
    
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    
    
    
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    
    
    ///  The operator can manage all NFTs of the owner.
    
    
    
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function approve(address _approved, uint256 _tokenId) external;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}
// 
pragma solidity 0.8.15;






contract ApprovalFacet is Base, IApproval {
    modifier canOperate(address _operator) {
        if(!mayOperate(_operator)) revert IOperatorFilter.IllegalOperator();
        _;
    }
    
    
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    
    
    function approve(address _approved, uint256 _tokenId) external isTransferable tokenLocked(_tokenId) canOperate(_approved) {
        if (_approved == address(0)) revert InvalidApprovalZeroAddress();
        address owner = LibTokenOwnership.ownerOf(_tokenId);
        if (owner != msg.sender && !s.nftStorage.operators[msg.sender][_approved] && s.nftStorage.tokenOperators[_tokenId] != msg.sender)
            revert CallerNotOwnerOrApprovedOperator();

        s.nftStorage.tokenOwners[_tokenId] = owner;
        s.nftStorage.tokenOperators[_tokenId] = _approved;

        emit Approval(msg.sender, _approved, _tokenId);
    }

    
    ///  all of `msg.sender`'s assets
    
    ///  multiple operators per owner.
    
    
    function setApprovalForAll(address _operator, bool _approved) external isTransferable canOperate(_operator) {
        s.nftStorage.operators[msg.sender][_operator] = _approved;

        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    
    
    
    
    function getApproved(uint256 _tokenId) external view tokenLocked(_tokenId) returns (address) {
        return LibTokenOwnership.ownerOf(_tokenId);
    }

    
    
    
    
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        if(!mayOperate(_operator)) return false;
        return s.nftStorage.operators[_owner][_operator];
    }



    function mayOperate(address _operator) private view returns (bool) {
        IOperatorFilter filter = IOperatorFilter(s.operatorFilter);
        if (address(filter) == address(0)) return true;
        return filter.mayTransfer(_operator);
    }
}

// 
pragma solidity 0.8.15;




library LibTokenOwnership {
    function ownerOf(uint256 _tokenId) internal view returns (address) {
        bytes memory functionCall = abi.encodeWithSelector(IERC721.ownerOf.selector, _tokenId);
        (bool success, bytes memory returndata) = address(this).staticcall(functionCall);
        if(success == false) {
            if(returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("Function call reverted");
            }
        }
        return abi.decode(returndata, (address));
    }

    function delegatedOwnerOf(uint256 _tokenId) internal returns (address) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        address facet = ds.selectorToFacetAndPosition[IERC721.ownerOf.selector].facetAddress;
        require(facet != address(0), "Diamond: Function does not exist");
        bytes memory functionCall = abi.encodeWithSelector(IERC721.ownerOf.selector, _tokenId);
        (bool success, bytes memory returndata) = address(facet).delegatecall(functionCall); // solhint-disable-line
        if(success == false) {
            if(returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("Function call reverted");
            }
        }
        return abi.decode(returndata, (address));
    }
}

// 
pragma solidity 0.8.15;

interface IOperatorFilter {
    error IllegalOperator();
    function mayTransfer(address operator) external view returns (bool);
}

// 
pragma solidity 0.8.15;




struct AppStorage {
    LibNFTStorage nftStorage;
    LibRoyaltyStorage royaltyStorage;
    mapping(uint256 => uint256) flaggedPasses;
    mapping(uint256 => uint256) reversedFlaggedPasses;
    uint256  flaggedPassHead;
    mapping(address => address)  flaggedAddresses;
    mapping(address => address)  reversedFlaggedAddresses;
    address  flaggedAddressHead;
    bool  isRefundingGas;
    uint256  maxRefundAmount;
    uint256  refundGasBuffer;
    uint256  flaggedAddressesCount;
    uint256  flaggedPassesCount;
    mapping(address => bool) adminTransferUsers;
    address operatorFilter;
}

// 
pragma solidity 0.8.15;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
* EIP-2535 Diamond Standard: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/







library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct FacetAddressAndPosition {
        address facetAddress;
        uint16 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array

    }

    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint16 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct DiamondStorage {
        // maps function selector to the facet address and
        // the position of the selector in the facetFunctionSelectors.selectors array
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        // maps facet addresses to function selectors
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        // maps function selector to role based access control
        mapping(bytes4 => bytes32[]) selectorToAccessControl;
        // facet addresses
        address[] facetAddresses;
        // Used to query if a contract implements an interface.
        // Used to implement ERC-165.
        mapping(bytes4 => bool) supportedInterfaces;
        // Owner of the contract
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(LibMeta.msgSender() == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    function addDiamondFunctions(
        address _diamondCutFacet,
        address _diamondLoupeFacet,
        address _ownershipFacet
    ) internal {
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](3);
        IDiamondCut.FunctionSelector[] memory functionSelectors = new IDiamondCut.FunctionSelector[](1);
        bytes32[] memory roles = new bytes32[](0);
        functionSelectors[0] = IDiamondCut.FunctionSelector(IDiamondCut.diamondCut.selector, roles);
        cut[0] = IDiamondCut.FacetCut({facetAddress: _diamondCutFacet, action: IDiamondCut.FacetCutAction.Add, functionSelectors: functionSelectors});
        functionSelectors = new IDiamondCut.FunctionSelector[](5);
        functionSelectors[0] = IDiamondCut.FunctionSelector(IDiamondLoupe.facets.selector, roles);
        functionSelectors[1] = IDiamondCut.FunctionSelector(IDiamondLoupe.facetFunctionSelectors.selector, roles);
        functionSelectors[2] = IDiamondCut.FunctionSelector(IDiamondLoupe.facetAddresses.selector, roles);
        functionSelectors[3] = IDiamondCut.FunctionSelector(IDiamondLoupe.facetAddress.selector, roles);
        functionSelectors[4] = IDiamondCut.FunctionSelector(IERC165.supportsInterface.selector, roles);
        cut[1] = IDiamondCut.FacetCut({
            facetAddress: _diamondLoupeFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });
        functionSelectors = new IDiamondCut.FunctionSelector[](2);
        functionSelectors[0] = IDiamondCut.FunctionSelector(IERC173.transferOwnership.selector, roles);
        functionSelectors[1] = IDiamondCut.FunctionSelector(IERC173.owner.selector, roles);
        cut[2] = IDiamondCut.FacetCut({facetAddress: _ownershipFacet, action: IDiamondCut.FacetCutAction.Add, functionSelectors: functionSelectors});
        diamondCut(cut, address(0), "");
    }

    // Internal function version of diamondCut
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            IDiamondCut.FacetCutAction action = _diamondCut[facetIndex].action;
            if (action == IDiamondCut.FacetCutAction.Add) {
                addFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                replaceFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                removeFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);
            } else {
                revert("LibDiamondCut: Incorrect FacetCutAction");
            }
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addFunctions(address _facetAddress, IDiamondCut.FunctionSelector[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        // uint16 selectorCount = uint16(diamondStorage().selectors.length);
        require(_facetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");
        uint16 selectorPosition = uint16(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            enforceHasContractCode(_facetAddress, "LibDiamondCut: New facet has no code");
            ds.facetFunctionSelectors[_facetAddress].facetAddressPosition = uint16(ds.facetAddresses.length);
            ds.facetAddresses.push(_facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex].selector;
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            require(oldFacetAddress == address(0), "LibDiamondCut: Can't add function that already exists");
            ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(selector);
            ds.selectorToFacetAndPosition[selector].facetAddress = _facetAddress;
            ds.selectorToFacetAndPosition[selector].functionSelectorPosition = selectorPosition;
            ds.selectorToAccessControl[selector] = _functionSelectors[selectorIndex].roles;
            selectorPosition++;
        }
    }

    function replaceFunctions(address _facetAddress, IDiamondCut.FunctionSelector[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        require(_facetAddress != address(0), "LibDiamondCut: Add facet can't be address(0)");
        uint16 selectorPosition = uint16(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);
        // add new facet address if it does not exist
        if (selectorPosition == 0) {
            enforceHasContractCode(_facetAddress, "LibDiamondCut: New facet has no code");
            ds.facetFunctionSelectors[_facetAddress].facetAddressPosition = uint16(ds.facetAddresses.length);
            ds.facetAddresses.push(_facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex].selector;
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            require(oldFacetAddress != _facetAddress, "LibDiamondCut: Can't replace function with same function");
            removeFunction(oldFacetAddress, selector);
            // add function
            ds.selectorToFacetAndPosition[selector].functionSelectorPosition = selectorPosition;
            ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(selector);
            ds.selectorToFacetAndPosition[selector].facetAddress = _facetAddress;
            ds.selectorToAccessControl[selector] = _functionSelectors[selectorIndex].roles;
            selectorPosition++;
        }
    }

    function removeFunctions(address _facetAddress, IDiamondCut.FunctionSelector[] memory _functionSelectors) internal {
        require(_functionSelectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        DiamondStorage storage ds = diamondStorage();
        // if function does not exist then do nothing and return
        require(_facetAddress == address(0), "LibDiamondCut: Remove facet address must be address(0)");
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
            bytes4 selector = _functionSelectors[selectorIndex].selector;
            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;
            removeFunction(oldFacetAddress, selector);
        }
    }

    function removeFunction(address _facetAddress, bytes4 _selector) internal {
        DiamondStorage storage ds = diamondStorage();
        require(_facetAddress != address(0), "LibDiamondCut: Can't remove function that doesn't exist");
        // an immutable function is a function defined directly in a diamond
        require(_facetAddress != address(this), "LibDiamondCut: Can't remove immutable function");
        // replace selector with last selector, then delete last selector
        uint256 selectorPosition = ds.selectorToFacetAndPosition[_selector].functionSelectorPosition;
        uint256 lastSelectorPosition = ds.facetFunctionSelectors[_facetAddress].functionSelectors.length - 1;
        // if not the same then replace _selector with lastSelector
        if (selectorPosition != lastSelectorPosition) {
            bytes4 lastSelector = ds.facetFunctionSelectors[_facetAddress].functionSelectors[lastSelectorPosition];
            ds.facetFunctionSelectors[_facetAddress].functionSelectors[selectorPosition] = lastSelector;
            ds.selectorToFacetAndPosition[lastSelector].functionSelectorPosition = uint16(selectorPosition);
        }
        // delete the last selector
        ds.facetFunctionSelectors[_facetAddress].functionSelectors.pop();
        delete ds.selectorToFacetAndPosition[_selector];

        // if no more selectors for facet address then delete the facet address
        if (lastSelectorPosition == 0) {
            // replace facet address with last facet address and delete last facet address
            uint256 lastFacetAddressPosition = ds.facetAddresses.length - 1;
            uint256 facetAddressPosition = ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
            if (facetAddressPosition != lastFacetAddressPosition) {
                address lastFacetAddress = ds.facetAddresses[lastFacetAddressPosition];
                ds.facetAddresses[facetAddressPosition] = lastFacetAddress;
                ds.facetFunctionSelectors[lastFacetAddress].facetAddressPosition = uint16(facetAddressPosition);
            }
            ds.facetAddresses.pop();
            delete ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;
        }

        // delete role based access control of selector
        delete ds.selectorToAccessControl[_selector];
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "LibDiamondCut: _init is address(0) but_calldata is not empty");
        } else {
            require(_calldata.length > 0, "LibDiamondCut: _calldata is empty but _init is not address(0)");
            if (_init != address(this)) {
                enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (success == false) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert("LibDiamondCut: _init function reverted");
                }
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize != 0, _errorMessage);
    }
}

// 
pragma solidity 0.8.15;

interface ISecurity {
    event PassFlagged(address indexed sender, uint256 tokenId);
    event PassUnflagged(address indexed sender, uint256 tokenId);
    event AddressFlagged(address indexed sender, address flaggedAddress);
    event AddressUnflagged(address indexed sender, address unflaggedAddress);
    event PassBurned(address indexed sender, uint256 tokenId);

    error TokenNotOwnedByFromAddress();
    error TokenLocked();
    error FlagZeroAddress();
    error AddressAlreadyFlagged();
    error AddressNotFlagged();
    error PassAlreadyFlagged();
    error PassNotFlagged();
    event TokensLocked(address indexed owner, uint256[] tokenIds);
    event TokensUnlocked(address indexed sender, address indexed owner, uint256[] tokenIds);
}

// https://eips.ethereum.org/EIPS/eip-721, http://erc721.org/
// 
pragma solidity 0.8.15;



///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface IERC721 /* is ERC165 */ {
    
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    
    
    ///  function throws for queries about the zero address.
    
    
    function balanceOf(address _owner) external view returns (uint256);

    
    
    ///  about them do throw.
    
    
    function ownerOf(uint256 _tokenId) external view returns (address);

    
    
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    
    
    
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;

    
    
    ///  except this function just sets data to "".
    
    
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    
    
    
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    
    
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    
    
    function approve(address _approved, uint256 _tokenId) external payable;

    
    ///  all of `msg.sender`'s assets
    
    ///  multiple operators per owner.
    
    
    function setApprovalForAll(address _operator, bool _approved) external;

    
    
    
    
    function getApproved(uint256 _tokenId) external view returns (address);

    
    
    
    
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface ERC165 {
    
    
    
    ///  uses less than 30,000 gas.
    
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

// 
pragma solidity 0.8.15;

struct LibNFTStorage {
    string name;
    string symbol;
    string baseURI;
    string contractURI;

    uint256 nextTokenId;
    uint256 startingTokenId;
    uint256 burnCounter;

    bool initialized;
    bool transfersEnabled;

    mapping(uint256 => bool) lockedTokens;
    mapping(uint256 => address) tokenOwners;
    mapping(uint256 => address) tokenOperators;
    mapping(uint256 => bool) burnedTokens;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => bool)) operators;
}

// 
pragma solidity 0.8.15;

struct LibRoyaltyStorage {
    uint256 denominator;
    uint256 numerator;
    address receiver;
    mapping(uint256 => uint256) tokenNumerators;
}

// 
pragma solidity 0.8.15;

/******************************************************************************\
* Author: Nick Mudge <[email protected]> (https://twitter.com/mudgen)
/******************************************************************************/

interface IDiamondCut {
    enum FacetCutAction {Add, Replace, Remove}

    struct FunctionSelector {
        bytes4 selector;
        bytes32[] roles;
    }

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        FunctionSelector[] functionSelectors;
    }

    
    ///         a function with delegatecall
    
    
    
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

// 
pragma solidity 0.8.15;

// A loupe is a small magnifying glass used to look at diamonds.
// These functions look at diamonds
interface IDiamondLoupe {
    /// These functions are expected to be called frequently
    /// by tools.

    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    
    
    function facets() external view returns (Facet[] memory facets_);

    
    
    
    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);

    
    
    function facetAddresses() external view returns (address[] memory facetAddresses_);

    
    
    
    
    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
}

// 
pragma solidity 0.8.15;

interface IERC165 {
    
    
    
    ///  uses less than 30,000 gas.
    
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// 
pragma solidity 0.8.15;


///  Note: the ERC-165 identifier for this interface is 0x7f5828d0
/* is ERC165 */
interface IERC173 {
    
    
    function owner() external view returns (address owner_);

    
    
    
    function transferOwnership(address _newOwner) external;
}

// 
pragma solidity 0.8.15;

library LibMeta {
    bytes32 internal constant EIP712_DOMAIN_TYPEHASH =
        keccak256(bytes("EIP712Domain(string name,string version,uint256 salt,address verifyingContract)"));

    function domainSeparator(string memory name, string memory version) internal view returns (bytes32 domainSeparator_) {
        domainSeparator_ = keccak256(
            abi.encode(EIP712_DOMAIN_TYPEHASH, keccak256(bytes(name)), keccak256(bytes(version)), getChainID(), address(this))
        );
    }

    function getChainID() internal view returns (uint256 id) {
        assembly {
            id := chainid()
        }
    }

    function msgSender() internal view returns (address sender_) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender_ := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
            }
        } else {
            sender_ = msg.sender;
        }
    }
}