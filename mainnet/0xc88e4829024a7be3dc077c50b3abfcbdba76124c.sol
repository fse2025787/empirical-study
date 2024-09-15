// SPDX-License-Identifier: MIT


// 
pragma solidity 0.8.16;




interface IInitializable {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    event Initialized(uint256 version);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error ADDRESS_ZERO();

    
    error INITIALIZING();

    
    error NOT_INITIALIZING();

    
    error ALREADY_INITIALIZED();
}

// 
pragma solidity 0.8.16;




interface IERC721 {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    
    
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    
    
    
    
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    
    
    
    
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error INVALID_APPROVAL();

    
    error INVALID_OWNER();

    
    error INVALID_RECIPIENT();

    
    error ALREADY_MINTED();

    
    error NOT_MINTED();

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    function balanceOf(address owner) external view returns (uint256);

    
    
    function ownerOf(uint256 tokenId) external view returns (address);

    
    
    function getApproved(uint256 tokenId) external view returns (address);

    
    
    
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    
    
    
    function approve(address to, uint256 tokenId) external;

    
    
    
    function setApprovalForAll(address operator, bool approved) external;

    
    
    
    
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    
    
    
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    
    
    
    
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

// 
pragma solidity 0.8.16;







/// - Uses custom errors declared in IInitializable
abstract contract Initializable is IInitializable {
    ///                                                          ///
    ///                           STORAGE                        ///
    ///                                                          ///

    
    uint8 internal _initialized;

    
    bool internal _initializing;

    ///                                                          ///
    ///                          MODIFIERS                       ///
    ///                                                          ///

    
    modifier onlyInitializing() {
        if (!_initializing) revert NOT_INITIALIZING();
        _;
    }

    
    modifier initializer() {
        bool isTopLevelCall = !_initializing;

        if ((!isTopLevelCall || _initialized != 0) && (Address.isContract(address(this)) || _initialized != 1)) revert ALREADY_INITIALIZED();

        _initialized = 1;

        if (isTopLevelCall) {
            _initializing = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;

            emit Initialized(1);
        }
    }

    
    
    modifier reinitializer(uint8 _version) {
        if (_initializing || _initialized >= _version) revert ALREADY_INITIALIZED();

        _initialized = _version;

        _initializing = true;

        _;

        _initializing = false;

        emit Initialized(_version);
    }

    ///                                                          ///
    ///                          FUNCTIONS                       ///
    ///                                                          ///

    
    function _disableInitializers() internal virtual {
        if (_initializing) revert INITIALIZING();

        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;

            emit Initialized(type(uint8).max);
        }
    }
}

// 
pragma solidity 0.8.16;




interface IEIP712 {
    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error EXPIRED_SIGNATURE();

    
    error INVALID_SIGNATURE();

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    function nonce(address account) external view returns (uint256);

    
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
// 
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// 
pragma solidity 0.8.16;




interface IERC1967Upgrade {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    
    event Upgraded(address impl);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    
    error INVALID_UPGRADE(address impl);

    
    error UNSUPPORTED_UUID();

    
    error ONLY_UUPS();
}

// 
pragma solidity 0.8.16;







interface IERC721Votes is IERC721, IEIP712 {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    event DelegateChanged(address indexed delegator, address indexed from, address indexed to);

    
    event DelegateVotesChanged(address indexed delegate, uint256 prevTotalVotes, uint256 newTotalVotes);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error INVALID_TIMESTAMP();

    ///                                                          ///
    ///                            STRUCTS                       ///
    ///                                                          ///

    
    
    
    struct Checkpoint {
        uint64 timestamp;
        uint192 votes;
    }

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    function getVotes(address account) external view returns (uint256);

    
    
    
    function getPastVotes(address account, uint256 timestamp) external view returns (uint256);

    
    
    function delegates(address account) external view returns (address);

    
    
    function delegate(address to) external;

    
    
    
    
    
    
    
    function delegateBySig(
        address from,
        address to,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// 
pragma solidity 0.8.16;




interface IOwnable {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    
    
    event OwnerUpdated(address indexed prevOwner, address indexed newOwner);

    
    
    
    event OwnerPending(address indexed owner, address indexed pendingOwner);

    
    
    
    event OwnerCanceled(address indexed owner, address indexed canceledOwner);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error ONLY_OWNER();

    
    error ONLY_PENDING_OWNER();

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    function owner() external view returns (address);

    
    function pendingOwner() external view returns (address);

    
    
    function transferOwnership(address newOwner) external;

    
    
    function safeTransferOwnership(address newOwner) external;

    
    function acceptOwnership() external;

    
    function cancelOwnershipTransfer() external;
}

// 
pragma solidity ^0.8.16;







interface IUUPS is IERC1967Upgrade, IERC1822Proxiable {
    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error ONLY_CALL();

    
    error ONLY_DELEGATECALL();

    
    error ONLY_PROXY();

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    function upgradeTo(address newImpl) external;

    
    
    
    function upgradeToAndCall(address newImpl, bytes memory data) external payable;
}

// 
pragma solidity 0.8.16;









/// - Uses custom errors declared in IERC721
abstract contract ERC721 is IERC721, Initializable {
    ///                                                          ///
    ///                            STORAGE                       ///
    ///                                                          ///

    
    string public name;

    
    string public symbol;

    
    
    mapping(uint256 => address) internal owners;

    
    
    mapping(address => uint256) internal balances;

    
    
    mapping(uint256 => address) internal tokenApprovals;

    
    
    mapping(address => mapping(address => bool)) internal operatorApprovals;

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    
    function __ERC721_init(string memory _name, string memory _symbol) internal onlyInitializing {
        name = _name;
        symbol = _symbol;
    }

    
    
    function tokenURI(uint256 _tokenId) public view virtual returns (string memory) {}

    
    function contractURI() public view virtual returns (string memory) {}

    
    
    function supportsInterface(bytes4 _interfaceId) external pure returns (bool) {
        return
            _interfaceId == 0x01ffc9a7 || // ERC165 Interface ID
            _interfaceId == 0x80ac58cd || // ERC721 Interface ID
            _interfaceId == 0x5b5e139f; // ERC721Metadata Interface ID
    }

    
    
    function getApproved(uint256 _tokenId) external view returns (address) {
        return tokenApprovals[_tokenId];
    }

    
    
    
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    
    
    function balanceOf(address _owner) public view returns (uint256) {
        if (_owner == address(0)) revert ADDRESS_ZERO();

        return balances[_owner];
    }

    
    
    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = owners[_tokenId];

        if (owner == address(0)) revert INVALID_OWNER();

        return owner;
    }

    
    
    
    function approve(address _to, uint256 _tokenId) external {
        address owner = owners[_tokenId];

        if (msg.sender != owner && !operatorApprovals[owner][msg.sender]) revert INVALID_APPROVAL();

        tokenApprovals[_tokenId] = _to;

        emit Approval(owner, _to, _tokenId);
    }

    
    
    
    function setApprovalForAll(address _operator, bool _approved) external {
        operatorApprovals[msg.sender][_operator] = _approved;

        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    
    
    
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public {
        if (_from != owners[_tokenId]) revert INVALID_OWNER();

        if (_to == address(0)) revert ADDRESS_ZERO();

        if (msg.sender != _from && !operatorApprovals[_from][msg.sender] && msg.sender != tokenApprovals[_tokenId]) revert INVALID_APPROVAL();

        _beforeTokenTransfer(_from, _to, _tokenId);

        unchecked {
            --balances[_from];

            ++balances[_to];
        }

        owners[_tokenId] = _to;

        delete tokenApprovals[_tokenId];

        emit Transfer(_from, _to, _tokenId);

        _afterTokenTransfer(_from, _to, _tokenId);
    }

    
    
    
    
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        transferFrom(_from, _to, _tokenId);

        if (
            Address.isContract(_to) &&
            ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, "") != ERC721TokenReceiver.onERC721Received.selector
        ) revert INVALID_RECIPIENT();
    }

    
    
    
    
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    ) external {
        transferFrom(_from, _to, _tokenId);

        if (
            Address.isContract(_to) &&
            ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data) != ERC721TokenReceiver.onERC721Received.selector
        ) revert INVALID_RECIPIENT();
    }

    
    
    
    function _mint(address _to, uint256 _tokenId) internal virtual {
        if (_to == address(0)) revert ADDRESS_ZERO();

        if (owners[_tokenId] != address(0)) revert ALREADY_MINTED();

        _beforeTokenTransfer(address(0), _to, _tokenId);

        unchecked {
            ++balances[_to];
        }

        owners[_tokenId] = _to;

        emit Transfer(address(0), _to, _tokenId);

        _afterTokenTransfer(address(0), _to, _tokenId);
    }

    
    
    function _burn(uint256 _tokenId) internal virtual {
        address owner = owners[_tokenId];

        if (owner == address(0)) revert NOT_MINTED();

        _beforeTokenTransfer(owner, address(0), _tokenId);

        unchecked {
            --balances[owner];
        }

        delete owners[_tokenId];

        delete tokenApprovals[_tokenId];

        emit Transfer(owner, address(0), _tokenId);

        _afterTokenTransfer(owner, address(0), _tokenId);
    }

    
    
    
    
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual {}

    
    
    
    
    function _afterTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual {}
}

// 
pragma solidity 0.8.16;







/// - Uses custom errors declared in IEIP712
/// - Caches `INITIAL_CHAIN_ID` and `INITIAL_DOMAIN_SEPARATOR` upon initialization
/// - Adds mapping for account nonces
abstract contract EIP712 is IEIP712, Initializable {
    ///                                                          ///
    ///                          CONSTANTS                       ///
    ///                                                          ///

    
    bytes32 internal constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    ///                                                          ///
    ///                           STORAGE                        ///
    ///                                                          ///

    
    bytes32 internal HASHED_NAME;

    
    bytes32 internal HASHED_VERSION;

    
    bytes32 internal INITIAL_DOMAIN_SEPARATOR;

    
    uint256 internal INITIAL_CHAIN_ID;

    
    
    mapping(address => uint256) internal nonces;

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    
    function __EIP712_init(string memory _name, string memory _version) internal onlyInitializing {
        HASHED_NAME = keccak256(bytes(_name));
        HASHED_VERSION = keccak256(bytes(_version));

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = _computeDomainSeparator();
    }

    
    
    function nonce(address _account) external view returns (uint256) {
        return nonces[_account];
    }

    
    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : _computeDomainSeparator();
    }

    
    function _computeDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(DOMAIN_TYPEHASH, HASHED_NAME, HASHED_VERSION, block.chainid, address(this)));
    }
}

// 
pragma solidity 0.8.16;






interface TokenTypesV1 {
    
    
    
    
    
    
    
    struct Settings {
        address auction;
        uint88 totalSupply;
        uint8 numFounders;
        IBaseMetadata metadataRenderer;
        uint88 mintCount;
        uint8 totalOwnership;
    }

    
    
    
    
    struct Founder {
        address wallet;
        uint8 ownershipPct;
        uint32 vestExpiry;
    }
}

// 
pragma solidity 0.8.16;




interface TokenTypesV2 {
    struct MinterParams {
        address minter;
        bool allowed;
    }
}
// 
pragma solidity 0.8.16;







interface GovernorTypesV1 {
    
    
    
    
    
    
    
    
    struct Settings {
        Token token;
        uint16 proposalThresholdBps;
        uint16 quorumThresholdBps;
        Treasury treasury;
        uint48 votingDelay;
        uint48 votingPeriod;
        address vetoer;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    struct Proposal {
        address proposer;
        uint32 timeCreated;
        uint32 againstVotes;
        uint32 forVotes;
        uint32 abstainVotes;
        uint32 voteStart;
        uint32 voteEnd;
        uint32 proposalThreshold;
        uint32 quorumVotes;
        bool executed;
        bool canceled;
        bool vetoed;
    }

    
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed,
        Vetoed
    }
}

// 
pragma solidity 0.8.16;




contract TreasuryTypesV1 {
    
    
    
    struct Settings {
        uint128 gracePeriod;
        uint128 delay;
    }
}

// 
pragma solidity 0.8.16;










/// - Uses custom errors declared in IERC1967Upgrade
/// - Removes ERC1967 admin and beacon support
abstract contract ERC1967Upgrade is IERC1967Upgrade {
    ///                                                          ///
    ///                          CONSTANTS                       ///
    ///                                                          ///

    
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    ///                                                          ///
    ///                          FUNCTIONS                       ///
    ///                                                          ///

    
    
    
    function _upgradeToAndCallUUPS(
        address _newImpl,
        bytes memory _data,
        bool _forceCall
    ) internal {
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(_newImpl);
        } else {
            try IERC1822Proxiable(_newImpl).proxiableUUID() returns (bytes32 slot) {
                if (slot != _IMPLEMENTATION_SLOT) revert UNSUPPORTED_UUID();
            } catch {
                revert ONLY_UUPS();
            }

            _upgradeToAndCall(_newImpl, _data, _forceCall);
        }
    }

    
    
    
    function _upgradeToAndCall(
        address _newImpl,
        bytes memory _data,
        bool _forceCall
    ) internal {
        _upgradeTo(_newImpl);

        if (_data.length > 0 || _forceCall) {
            Address.functionDelegateCall(_newImpl, _data);
        }
    }

    
    
    function _upgradeTo(address _newImpl) internal {
        _setImplementation(_newImpl);

        emit Upgraded(_newImpl);
    }

    
    
    function _setImplementation(address _impl) private {
        if (!Address.isContract(_impl)) revert INVALID_UPGRADE(_impl);

        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = _impl;
    }

    
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }
}

// 
pragma solidity 0.8.16;

abstract contract VersionedContract {
    function contractVersion() external pure returns (string memory) {
        return "1.2.0";
    }
}

// 
pragma solidity 0.8.16;










interface IGovernor is IUUPS, IOwnable, IEIP712, GovernorTypesV1 {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    event ProposalCreated(
        bytes32 proposalId,
        address[] targets,
        uint256[] values,
        bytes[] calldatas,
        string description,
        bytes32 descriptionHash,
        Proposal proposal
    );

    
    event ProposalQueued(bytes32 proposalId, uint256 eta);

    
    
    event ProposalExecuted(bytes32 proposalId);

    
    event ProposalCanceled(bytes32 proposalId);

    
    event ProposalVetoed(bytes32 proposalId);

    
    event VoteCast(address voter, bytes32 proposalId, uint256 support, uint256 weight, string reason);

    
    event VotingDelayUpdated(uint256 prevVotingDelay, uint256 newVotingDelay);

    
    event VotingPeriodUpdated(uint256 prevVotingPeriod, uint256 newVotingPeriod);

    
    event ProposalThresholdBpsUpdated(uint256 prevBps, uint256 newBps);

    
    event QuorumVotesBpsUpdated(uint256 prevBps, uint256 newBps);

    
    event VetoerUpdated(address prevVetoer, address newVetoer);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    error INVALID_PROPOSAL_THRESHOLD_BPS();

    error INVALID_QUORUM_THRESHOLD_BPS();

    error INVALID_VOTING_DELAY();

    error INVALID_VOTING_PERIOD();

    
    
    error PROPOSAL_EXISTS(bytes32 proposalId);

    
    
    error PROPOSAL_NOT_QUEUED(bytes32 proposalId);

    
    error PROPOSAL_TARGET_MISSING();

    
    error PROPOSAL_LENGTH_MISMATCH();

    
    error PROPOSAL_UNSUCCESSFUL();

    
    error PROPOSAL_ALREADY_EXECUTED();

    
    error PROPOSAL_DOES_NOT_EXIST();

    
    error BELOW_PROPOSAL_THRESHOLD();

    
    error VOTING_NOT_STARTED();

    
    error ONLY_VETOER();

    
    error ALREADY_VOTED();

    
    error INVALID_CANCEL();

    
    error INVALID_VOTE();

    
    error ONLY_MANAGER();

    ///                                                          ///
    ///                          FUNCTIONS                       ///
    ///                                                          ///

    
    
    
    
    
    
    
    
    function initialize(
        address treasury,
        address token,
        address vetoer,
        uint256 votingDelay,
        uint256 votingPeriod,
        uint256 proposalThresholdBps,
        uint256 quorumThresholdBps
    ) external;

    
    
    
    
    
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) external returns (bytes32);

    
    
    
    function castVote(bytes32 proposalId, uint256 support) external returns (uint256);

    
    
    
    
    function castVoteWithReason(
        bytes32 proposalId,
        uint256 support,
        string memory reason
    ) external returns (uint256);

    
    
    
    
    
    
    
    
    function castVoteBySig(
        address voter,
        bytes32 proposalId,
        uint256 support,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256);

    
    
    function queue(bytes32 proposalId) external returns (uint256 eta);

    
    
    
    
    
    
    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash,
        address proposer
    ) external payable returns (bytes32);

    
    
    function cancel(bytes32 proposalId) external;

    
    
    function veto(bytes32 proposalId) external;

    
    
    function state(bytes32 proposalId) external view returns (ProposalState);

    
    
    
    function getVotes(address account, uint256 timestamp) external view returns (uint256);

    
    function proposalThreshold() external view returns (uint256);

    
    function quorum() external view returns (uint256);

    
    
    function getProposal(bytes32 proposalId) external view returns (Proposal memory);

    
    
    function proposalSnapshot(bytes32 proposalId) external view returns (uint256);

    
    
    function proposalDeadline(bytes32 proposalId) external view returns (uint256);

    
    
    function proposalVotes(bytes32 proposalId)
        external
        view
        returns (
            uint256 againstVotes,
            uint256 forVotes,
            uint256 abstainVotes
        );

    
    
    function proposalEta(bytes32 proposalId) external view returns (uint256);

    
    function proposalThresholdBps() external view returns (uint256);

    
    function quorumThresholdBps() external view returns (uint256);

    
    function votingDelay() external view returns (uint256);

    
    function votingPeriod() external view returns (uint256);

    
    function vetoer() external view returns (address);

    
    function token() external view returns (address);

    
    function treasury() external view returns (address);

    
    
    function updateVotingDelay(uint256 newVotingDelay) external;

    
    
    function updateVotingPeriod(uint256 newVotingPeriod) external;

    
    
    function updateProposalThresholdBps(uint256 newProposalThresholdBps) external;

    
    
    function updateQuorumThresholdBps(uint256 newQuorumVotesBps) external;

    
    
    function updateVetoer(address newVetoer) external;

    
    function burnVetoer() external;

    
    function VOTE_TYPEHASH() external view returns (bytes32);
}

// 
pragma solidity 0.8.16;




abstract contract ProposalHasher {
    ///                                                          ///
    ///                         HASH PROPOSAL                    ///
    ///                                                          ///

    
    
    
    
    
    
    function hashProposal(
        address[] memory _targets,
        uint256[] memory _values,
        bytes[] memory _calldatas,
        bytes32 _descriptionHash,
        address _proposer
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_targets, _values, _calldatas, _descriptionHash, _proposer));
    }
}

// 
pragma solidity 0.8.16;






contract GovernorStorageV1 is GovernorTypesV1 {
    
    Settings internal settings;

    
    
    mapping(bytes32 => Proposal) internal proposals;

    
    
    mapping(bytes32 => mapping(address => bool)) internal hasVoted;
}

// 
pragma solidity 0.8.16;







interface ITreasury is IUUPS, IOwnable {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    event TransactionScheduled(bytes32 proposalId, uint256 timestamp);

    
    event TransactionCanceled(bytes32 proposalId);

    
    event TransactionExecuted(bytes32 proposalId, address[] targets, uint256[] values, bytes[] payloads);

    
    event DelayUpdated(uint256 prevDelay, uint256 newDelay);

    
    event GracePeriodUpdated(uint256 prevGracePeriod, uint256 newGracePeriod);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error PROPOSAL_ALREADY_QUEUED();

    
    error PROPOSAL_NOT_QUEUED();

    
    
    error EXECUTION_NOT_READY(bytes32 proposalId);

    
    
    error EXECUTION_FAILED(uint256 txIndex);

    
    error EXECUTION_EXPIRED();

    
    error ONLY_TREASURY();

    
    error ONLY_MANAGER();

    ///                                                          ///
    ///                          FUNCTIONS                       ///
    ///                                                          ///

    
    
    
    function initialize(address governor, uint256 timelockDelay) external;

    
    
    function timestamp(bytes32 proposalId) external view returns (uint256);

    
    
    function isQueued(bytes32 proposalId) external view returns (bool);

    
    
    function isReady(bytes32 proposalId) external view returns (bool);

    
    
    function isExpired(bytes32 proposalId) external view returns (bool);

    
    
    function queue(bytes32 proposalId) external returns (uint256 eta);

    
    
    function cancel(bytes32 proposalId) external;

    
    
    
    
    
    
    function execute(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata calldatas,
        bytes32 descriptionHash,
        address proposer
    ) external payable;

    
    function delay() external view returns (uint256);

    
    function gracePeriod() external view returns (uint256);

    
    
    function updateDelay(uint256 newDelay) external;

    
    
    function updateGracePeriod(uint256 newGracePeriod) external;
}

// 
pragma solidity 0.8.16;






contract TreasuryStorageV1 is TreasuryTypesV1 {
    
    Settings internal settings;

    
    
    mapping(bytes32 => uint256) internal timestamps;
}

// 
pragma solidity 0.8.16;




interface IPausable {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    
    event Paused(address user);

    
    
    event Unpaused(address user);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error PAUSED();

    
    error UNPAUSED();

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    function paused() external view returns (bool);
}

// 
pragma solidity 0.8.16;







/// - Uses custom errors declared in IUUPS
/// - Inherits a modern, minimal ERC1967Upgrade
abstract contract UUPS is IUUPS, ERC1967Upgrade {
    ///                                                          ///
    ///                          IMMUTABLES                      ///
    ///                                                          ///

    
    address private immutable __self = address(this);

    ///                                                          ///
    ///                           MODIFIERS                      ///
    ///                                                          ///

    
    modifier onlyProxy() {
        if (address(this) == __self) revert ONLY_DELEGATECALL();
        if (_getImplementation() != __self) revert ONLY_PROXY();
        _;
    }

    
    modifier notDelegated() {
        if (address(this) != __self) revert ONLY_CALL();
        _;
    }

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    function _authorizeUpgrade(address _newImpl) internal virtual;

    
    
    function upgradeTo(address _newImpl) external onlyProxy {
        _authorizeUpgrade(_newImpl);
        _upgradeToAndCallUUPS(_newImpl, "", false);
    }

    
    
    
    function upgradeToAndCall(address _newImpl, bytes memory _data) external payable onlyProxy {
        _authorizeUpgrade(_newImpl);
        _upgradeToAndCallUUPS(_newImpl, _data, true);
    }

    
    function proxiableUUID() external view notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }
}

// 
pragma solidity 0.8.16;








/// - Uses custom errors defined in IERC721Votes
/// - Checkpoints are based on timestamps instead of block numbers
/// - Tokens are self-delegated by default
/// - The total number of votes is the token supply itself
abstract contract ERC721Votes is IERC721Votes, EIP712, ERC721 {
    ///                                                          ///
    ///                          CONSTANTS                       ///
    ///                                                          ///

    
    bytes32 internal constant DELEGATION_TYPEHASH = keccak256("Delegation(address from,address to,uint256 nonce,uint256 deadline)");

    ///                                                          ///
    ///                           STORAGE                        ///
    ///                                                          ///

    
    
    mapping(address => address) internal delegation;

    
    
    mapping(address => uint256) internal numCheckpoints;

    
    
    mapping(address => mapping(uint256 => Checkpoint)) internal checkpoints;

    ///                                                          ///
    ///                        VOTING WEIGHT                     ///
    ///                                                          ///

    
    
    function getVotes(address _account) public view returns (uint256) {
        // Get the account's number of checkpoints
        uint256 nCheckpoints = numCheckpoints[_account];

        // Cannot underflow as `nCheckpoints` is ensured to be greater than 0 if reached
        unchecked {
            // Return the number of votes at the latest checkpoint if applicable
            return nCheckpoints != 0 ? checkpoints[_account][nCheckpoints - 1].votes : 0;
        }
    }

    
    
    
    function getPastVotes(address _account, uint256 _timestamp) public view returns (uint256) {
        // Ensure the given timestamp is in the past
        if (_timestamp >= block.timestamp) revert INVALID_TIMESTAMP();

        // Get the account's number of checkpoints
        uint256 nCheckpoints = numCheckpoints[_account];

        // If there are none return 0
        if (nCheckpoints == 0) return 0;

        // Get the account's checkpoints
        mapping(uint256 => Checkpoint) storage accountCheckpoints = checkpoints[_account];

        unchecked {
            // Get the latest checkpoint id
            // Cannot underflow as `nCheckpoints` is ensured to be greater than 0
            uint256 lastCheckpoint = nCheckpoints - 1;

            // If the latest checkpoint has a valid timestamp, return its number of votes
            if (accountCheckpoints[lastCheckpoint].timestamp <= _timestamp) return accountCheckpoints[lastCheckpoint].votes;

            // If the first checkpoint doesn't have a valid timestamp, return 0
            if (accountCheckpoints[0].timestamp > _timestamp) return 0;

            // Otherwise, find a checkpoint with a valid timestamp
            // Use the latest id as the initial upper bound
            uint256 high = lastCheckpoint;
            uint256 low;
            uint256 middle;

            // Used to temporarily hold a checkpoint
            Checkpoint memory cp;

            // While a valid checkpoint is to be found:
            while (high > low) {
                // Find the id of the middle checkpoint
                middle = high - (high - low) / 2;

                // Get the middle checkpoint
                cp = accountCheckpoints[middle];

                // If the timestamp is a match:
                if (cp.timestamp == _timestamp) {
                    // Return the voting weight
                    return cp.votes;

                    // Else if the timestamp is before the one looking for:
                } else if (cp.timestamp < _timestamp) {
                    // Update the lower bound
                    low = middle;

                    // Else update the upper bound
                } else {
                    high = middle - 1;
                }
            }

            return accountCheckpoints[low].votes;
        }
    }

    ///                                                          ///
    ///                          DELEGATION                      ///
    ///                                                          ///

    
    
    function delegates(address _account) public view returns (address) {
        address current = delegation[_account];
        return current == address(0) ? _account : current;
    }

    
    
    function delegate(address _to) external {
        _delegate(msg.sender, _to);
    }

    
    
    
    
    
    
    
    function delegateBySig(
        address _from,
        address _to,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        // Ensure the signature has not expired
        if (block.timestamp > _deadline) revert EXPIRED_SIGNATURE();

        // Used to store the digest
        bytes32 digest;

        // Cannot realistically overflow
        unchecked {
            // Compute the hash of the domain seperator with the typed delegation data
            digest = keccak256(
                abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), keccak256(abi.encode(DELEGATION_TYPEHASH, _from, _to, nonces[_from]++, _deadline)))
            );
        }

        // Recover the message signer
        address recoveredAddress = ecrecover(digest, _v, _r, _s);

        // Ensure the recovered signer is the voter
        if (recoveredAddress == address(0) || recoveredAddress != _from) revert INVALID_SIGNATURE();

        // Update the delegate
        _delegate(_from, _to);
    }

    
    
    
    function _delegate(address _from, address _to) internal {
        // If address(0) is being delegated to, update the op as a self-delegate
        if (_to == address(0)) _to = _from;

        // Get the previous delegate
        address prevDelegate = delegates(_from);

        // Store the new delegate
        delegation[_from] = _to;

        emit DelegateChanged(_from, prevDelegate, _to);

        // Transfer voting weight from the previous delegate to the new delegate
        _moveDelegateVotes(prevDelegate, _to, balanceOf(_from));
    }

    
    
    
    
    function _moveDelegateVotes(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        unchecked {
            // If voting weight is being transferred:
            if (_from != _to && _amount > 0) {
                // If this isn't a token mint:
                if (_from != address(0)) {
                    // Get the sender's number of checkpoints
                    uint256 newCheckpointId = numCheckpoints[_from];

                    // Used to store their previous checkpoint id
                    uint256 prevCheckpointId;

                    // Used to store their previous checkpoint's voting weight
                    uint256 prevTotalVotes;

                    // Used to store their previous checkpoint's timestamp
                    uint256 prevTimestamp;

                    // If this isn't the sender's first checkpoint:
                    if (newCheckpointId != 0) {
                        // Get their previous checkpoint's id
                        prevCheckpointId = newCheckpointId - 1;

                        // Get their previous checkpoint's voting weight
                        prevTotalVotes = checkpoints[_from][prevCheckpointId].votes;

                        // Get their previous checkpoint's timestamp
                        prevTimestamp = checkpoints[_from][prevCheckpointId].timestamp;
                    }

                    // Update their voting weight
                    _writeCheckpoint(_from, newCheckpointId, prevCheckpointId, prevTimestamp, prevTotalVotes, prevTotalVotes - _amount);
                }

                // If this isn't a token burn:
                if (_to != address(0)) {
                    // Get the recipients's number of checkpoints
                    uint256 nCheckpoints = numCheckpoints[_to];

                    // Used to store their previous checkpoint id
                    uint256 prevCheckpointId;

                    // Used to store their previous checkpoint's voting weight
                    uint256 prevTotalVotes;

                    // Used to store their previous checkpoint's timestamp
                    uint256 prevTimestamp;

                    // If this isn't the recipient's first checkpoint:
                    if (nCheckpoints != 0) {
                        // Get their previous checkpoint's id
                        prevCheckpointId = nCheckpoints - 1;

                        // Get their previous checkpoint's voting weight
                        prevTotalVotes = checkpoints[_to][prevCheckpointId].votes;

                        // Get their previous checkpoint's timestamp
                        prevTimestamp = checkpoints[_to][prevCheckpointId].timestamp;
                    }

                    // Update their voting weight
                    _writeCheckpoint(_to, nCheckpoints, prevCheckpointId, prevTimestamp, prevTotalVotes, prevTotalVotes + _amount);
                }
            }
        }
    }

    
    
    
    
    
    
    
    function _writeCheckpoint(
        address _account,
        uint256 _newId,
        uint256 _prevId,
        uint256 _prevTimestamp,
        uint256 _prevTotalVotes,
        uint256 _newTotalVotes
    ) private {
        unchecked {
            // If the new checkpoint is not the user's first AND has the timestamp of the previous checkpoint:
            if (_newId > 0 && _prevTimestamp == block.timestamp) {
                // Just update the previous checkpoint's votes
                checkpoints[_account][_prevId].votes = uint192(_newTotalVotes);

                // Else write a new checkpoint:
            } else {
                // Get the pointer to store the checkpoint
                Checkpoint storage checkpoint = checkpoints[_account][_newId];

                // Store the new voting weight and the current time
                checkpoint.votes = uint192(_newTotalVotes);
                checkpoint.timestamp = uint64(block.timestamp);

                // Increment the account's number of checkpoints
                ++numCheckpoints[_account];
            }

            emit DelegateVotesChanged(_account, _prevTotalVotes, _newTotalVotes);
        }
    }

    
    
    
    
    function _afterTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal override {
        // Transfer 1 vote from the sender to the recipient
        _moveDelegateVotes(delegates(_from), delegates(_to), 1);

        super._afterTokenTransfer(_from, _to, _tokenId);
    }
}

// 
pragma solidity 0.8.16;







/// - Uses custom errors declared in IOwnable
/// - Adds optional two-step ownership transfer (`safeTransferOwnership` + `acceptOwnership`)
abstract contract Ownable is IOwnable, Initializable {
    ///                                                          ///
    ///                            STORAGE                       ///
    ///                                                          ///

    
    address internal _owner;

    
    address internal _pendingOwner;

    ///                                                          ///
    ///                           MODIFIERS                      ///
    ///                                                          ///

    
    modifier onlyOwner() {
        if (msg.sender != _owner) revert ONLY_OWNER();
        _;
    }

    
    modifier onlyPendingOwner() {
        if (msg.sender != _pendingOwner) revert ONLY_PENDING_OWNER();
        _;
    }

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    function __Ownable_init(address _initialOwner) internal onlyInitializing {
        _owner = _initialOwner;

        emit OwnerUpdated(address(0), _initialOwner);
    }

    
    function owner() public virtual view returns (address) {
        return _owner;
    }

    
    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    
    
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    
    
    
    function _transferOwnership(address _newOwner) internal {
        emit OwnerUpdated(_owner, _newOwner);

        _owner = _newOwner;

        if (_pendingOwner != address(0)) delete _pendingOwner;
    }

    
    
    function safeTransferOwnership(address _newOwner) public onlyOwner {
        _pendingOwner = _newOwner;

        emit OwnerPending(_owner, _newOwner);
    }

    
    function acceptOwnership() public onlyPendingOwner {
        emit OwnerUpdated(_owner, msg.sender);

        _owner = _pendingOwner;

        delete _pendingOwner;
    }

    
    function cancelOwnershipTransfer() public onlyOwner {
        emit OwnerCanceled(_owner, _pendingOwner);

        delete _pendingOwner;
    }
}

// 
pragma solidity 0.8.16;




/// - Uses custom error `REENTRANCY()`
abstract contract ReentrancyGuard is Initializable {
    ///                                                          ///
    ///                            STORAGE                       ///
    ///                                                          ///

    
    uint256 internal constant _NOT_ENTERED = 1;

    
    uint256 internal constant _ENTERED = 2;

    
    uint256 internal _status;

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error REENTRANCY();

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    function __ReentrancyGuard_init() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    
    modifier nonReentrant() {
        if (_status == _ENTERED) revert REENTRANCY();

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

// 
pragma solidity 0.8.16;










interface IToken is IUUPS, IERC721Votes, TokenTypesV1, TokenTypesV2 {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    
    
    
    event MintScheduled(uint256 baseTokenId, uint256 founderId, Founder founder);

    
    
    
    
    event MintUnscheduled(uint256 baseTokenId, uint256 founderId, Founder founder);

    
    
    event FounderAllocationsCleared(IManager.FounderParams[] newFounders);

    
    
    
    event MinterUpdated(address minter, bool allowed);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error INVALID_FOUNDER_OWNERSHIP();

    
    error ONLY_AUCTION();

    
    error ONLY_AUCTION_OR_MINTER();

    
    error ONLY_TOKEN_OWNER();

    
    error NO_METADATA_GENERATED();

    
    error ONLY_MANAGER();

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    
    
    
    function initialize(
        IManager.FounderParams[] calldata founders,
        bytes calldata initStrings,
        address metadataRenderer,
        address auction,
        address initialOwner
    ) external;

    
    function mint() external returns (uint256 tokenId);

    
    
    function burn(uint256 tokenId) external;

    
    
    function tokenURI(uint256 tokenId) external view returns (string memory);

    
    function contractURI() external view returns (string memory);

    
    function totalFounders() external view returns (uint256);

    
    function totalFounderOwnership() external view returns (uint256);

    
    
    function getFounder(uint256 founderId) external view returns (Founder memory);

    
    function getFounders() external view returns (Founder[] memory);

    
    
    function updateFounders(IManager.FounderParams[] calldata newFounders) external;

    
    /// NOTE: If a founder is returned, there's no guarantee they'll receive the token as vesting expiration is not considered
    
    function getScheduledRecipient(uint256 tokenId) external view returns (Founder memory);

    
    function totalSupply() external view returns (uint256);

    
    function auction() external view returns (address);

    
    function metadataRenderer() external view returns (address);

    
    function owner() external view returns (address);

    
    
    function updateMinters(MinterParams[] calldata _minters) external;

    
    function onFirstAuctionStarted() external;
}

// 
pragma solidity 0.8.16;






contract TokenStorageV1 is TokenTypesV1 {
    
    Settings internal settings;

    
    
    mapping(uint256 => Founder) internal founder;

    
    
    mapping(uint256 => Founder) internal tokenRecipient;
}

// 
pragma solidity 0.8.16;






contract TokenStorageV2 is TokenTypesV2 {
    
    mapping(address => bool) public minter;
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        
        assembly {
            r.slot := slot
        }
    }
}

// 
pragma solidity 0.8.16;








interface IAuction is IUUPS, IOwnable, IPausable {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    
    
    
    
    
    event AuctionBid(uint256 tokenId, address bidder, uint256 amount, bool extended, uint256 endTime);

    
    
    
    
    event AuctionSettled(uint256 tokenId, address winner, uint256 amount);

    
    
    
    
    event AuctionCreated(uint256 tokenId, uint256 startTime, uint256 endTime);

    
    
    event DurationUpdated(uint256 duration);

    
    
    event ReservePriceUpdated(uint256 reservePrice);

    
    
    event MinBidIncrementPercentageUpdated(uint256 minBidIncrementPercentage);

    
    
    event TimeBufferUpdated(uint256 timeBuffer);

    ///                                                          ///
    ///                           ERRORS                         ///
    ///                                                          ///

    
    error INVALID_TOKEN_ID();

    
    error AUCTION_OVER();

    
    error AUCTION_NOT_STARTED();

    
    error AUCTION_ACTIVE();

    
    error AUCTION_SETTLED();

    
    error RESERVE_PRICE_NOT_MET();

    
    error MINIMUM_BID_NOT_MET();

    
    error MIN_BID_INCREMENT_1_PERCENT();

    
    error INSOLVENT();

    
    error ONLY_MANAGER();

    
    error FAILING_WETH_TRANSFER();

    
    error AUCTION_CREATE_FAILED_TO_LAUNCH();

    ///                                                          ///
    ///                          FUNCTIONS                       ///
    ///                                                          ///

    
    
    
    
    
    
    function initialize(
        address token,
        address founder,
        address treasury,
        uint256 duration,
        uint256 reservePrice
    ) external;

    
    
    function createBid(uint256 tokenId) external payable;

    
    function settleCurrentAndCreateNewAuction() external;

    
    function settleAuction() external;

    
    function pause() external;

    
    function unpause() external;

    
    function duration() external view returns (uint256);

    
    function reservePrice() external view returns (uint256);

    
    function timeBuffer() external view returns (uint256);

    
    function minBidIncrement() external view returns (uint256);

    
    
    function setDuration(uint256 duration) external;

    
    
    function setReservePrice(uint256 reservePrice) external;

    
    
    function setTimeBuffer(uint256 timeBuffer) external;

    
    
    function setMinimumBidIncrement(uint256 percentage) external;

    
    function treasury() external returns (address);
}

// 
pragma solidity 0.8.16;


















/// Modified from:
/// - OpenZeppelin Contracts v4.7.3 (governance/extensions/GovernorTimelockControl.sol)
/// - NounsDAOLogicV1.sol commit 2cbe6c7 - licensed under the BSD-3-Clause license.
contract Governor is IGovernor, VersionedContract, UUPS, Ownable, EIP712, ProposalHasher, GovernorStorageV1 {
    ///                                                          ///
    ///                         IMMUTABLES                       ///
    ///                                                          ///

    
    bytes32 public immutable VOTE_TYPEHASH = keccak256("Vote(address voter,uint256 proposalId,uint256 support,uint256 nonce,uint256 deadline)");

    
    uint256 public immutable MIN_PROPOSAL_THRESHOLD_BPS = 1;

    
    uint256 public immutable MAX_PROPOSAL_THRESHOLD_BPS = 1000;

    
    uint256 public immutable MIN_QUORUM_THRESHOLD_BPS = 200;

    
    uint256 public immutable MAX_QUORUM_THRESHOLD_BPS = 2000;

    
    uint256 public immutable MIN_VOTING_DELAY = 1 seconds;

    
    uint256 public immutable MAX_VOTING_DELAY = 24 weeks;

    
    uint256 public immutable MIN_VOTING_PERIOD = 10 minutes;

    
    uint256 public immutable MAX_VOTING_PERIOD = 24 weeks;

    
    uint256 private immutable BPS_PER_100_PERCENT = 10_000;

    
    IManager private immutable manager;

    ///                                                          ///
    ///                         CONSTRUCTOR                      ///
    ///                                                          ///

    
    constructor(address _manager) payable initializer {
        manager = IManager(_manager);
    }

    ///                                                          ///
    ///                         INITIALIZER                      ///
    ///                                                          ///

    
    
    
    
    
    
    
    
    function initialize(
        address _treasury,
        address _token,
        address _vetoer,
        uint256 _votingDelay,
        uint256 _votingPeriod,
        uint256 _proposalThresholdBps,
        uint256 _quorumThresholdBps
    ) external initializer {
        // Ensure the caller is the contract manager
        if (msg.sender != address(manager)) revert ONLY_MANAGER();

        // Ensure non-zero addresses are provided
        if (_treasury == address(0)) revert ADDRESS_ZERO();
        if (_token == address(0)) revert ADDRESS_ZERO();

        // If a vetoer is specified, store its address
        if (_vetoer != address(0)) settings.vetoer = _vetoer;

        // Ensure the specified governance settings are valid
        if (_proposalThresholdBps < MIN_PROPOSAL_THRESHOLD_BPS || _proposalThresholdBps > MAX_PROPOSAL_THRESHOLD_BPS)
            revert INVALID_PROPOSAL_THRESHOLD_BPS();
        if (_quorumThresholdBps < MIN_QUORUM_THRESHOLD_BPS || _quorumThresholdBps > MAX_QUORUM_THRESHOLD_BPS) revert INVALID_QUORUM_THRESHOLD_BPS();
        if (_proposalThresholdBps >= _quorumThresholdBps) revert INVALID_PROPOSAL_THRESHOLD_BPS();
        if (_votingDelay < MIN_VOTING_DELAY || _votingDelay > MAX_VOTING_DELAY) revert INVALID_VOTING_DELAY();
        if (_votingPeriod < MIN_VOTING_PERIOD || _votingPeriod > MAX_VOTING_PERIOD) revert INVALID_VOTING_PERIOD();

        // Store the governor settings
        settings.treasury = Treasury(payable(_treasury));
        settings.token = Token(_token);
        settings.votingDelay = SafeCast.toUint48(_votingDelay);
        settings.votingPeriod = SafeCast.toUint48(_votingPeriod);
        settings.proposalThresholdBps = SafeCast.toUint16(_proposalThresholdBps);
        settings.quorumThresholdBps = SafeCast.toUint16(_quorumThresholdBps);

        // Initialize EIP-712 support
        __EIP712_init(string.concat(settings.token.symbol(), " GOV"), "1");

        // Grant ownership to the treasury
        __Ownable_init(_treasury);
    }

    ///                                                          ///
    ///                        CREATE PROPOSAL                   ///
    ///                                                          ///

    
    
    
    
    
    function propose(
        address[] memory _targets,
        uint256[] memory _values,
        bytes[] memory _calldatas,
        string memory _description
    ) external returns (bytes32) {
        // Get the current proposal threshold
        uint256 currentProposalThreshold = proposalThreshold();

        // Cannot realistically underflow and `getVotes` would revert
        unchecked {
            // Ensure the caller's voting weight is greater than or equal to the threshold
            if (getVotes(msg.sender, block.timestamp - 1) <= proposalThreshold()) {
                revert BELOW_PROPOSAL_THRESHOLD();
            }
        }

        // Cache the number of targets
        uint256 numTargets = _targets.length;

        // Ensure at least one target exists
        if (numTargets == 0) revert PROPOSAL_TARGET_MISSING();

        // Ensure the number of targets matches the number of values and calldata
        if (numTargets != _values.length) revert PROPOSAL_LENGTH_MISMATCH();
        if (numTargets != _calldatas.length) revert PROPOSAL_LENGTH_MISMATCH();

        // Compute the description hash
        bytes32 descriptionHash = keccak256(bytes(_description));

        // Compute the proposal id
        bytes32 proposalId = hashProposal(_targets, _values, _calldatas, descriptionHash, msg.sender);

        // Get the pointer to store the proposal
        Proposal storage proposal = proposals[proposalId];

        // Ensure the proposal doesn't already exist
        if (proposal.voteStart != 0) revert PROPOSAL_EXISTS(proposalId);

        // Used to store the snapshot and deadline
        uint256 snapshot;
        uint256 deadline;

        // Cannot realistically overflow
        unchecked {
            // Compute the snapshot and deadline
            snapshot = block.timestamp + settings.votingDelay;
            deadline = snapshot + settings.votingPeriod;
        }

        // Store the proposal data
        proposal.voteStart = SafeCast.toUint32(snapshot);
        proposal.voteEnd = SafeCast.toUint32(deadline);
        proposal.proposalThreshold = SafeCast.toUint32(currentProposalThreshold);
        proposal.quorumVotes = SafeCast.toUint32(quorum());
        proposal.proposer = msg.sender;
        proposal.timeCreated = SafeCast.toUint32(block.timestamp);

        emit ProposalCreated(proposalId, _targets, _values, _calldatas, _description, descriptionHash, proposal);

        return proposalId;
    }

    ///                                                          ///
    ///                          CAST VOTE                       ///
    ///                                                          ///

    
    
    
    function castVote(bytes32 _proposalId, uint256 _support) external returns (uint256) {
        return _castVote(_proposalId, msg.sender, _support, "");
    }

    
    
    
    
    function castVoteWithReason(
        bytes32 _proposalId,
        uint256 _support,
        string memory _reason
    ) external returns (uint256) {
        return _castVote(_proposalId, msg.sender, _support, _reason);
    }

    
    
    
    
    
    
    
    
    function castVoteBySig(
        address _voter,
        bytes32 _proposalId,
        uint256 _support,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external returns (uint256) {
        // Ensure the deadline has not passed
        if (block.timestamp > _deadline) revert EXPIRED_SIGNATURE();

        // Used to store the signed digest
        bytes32 digest;

        // Cannot realistically overflow
        unchecked {
            // Compute the message
            digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(VOTE_TYPEHASH, _voter, _proposalId, _support, nonces[_voter]++, _deadline))
                )
            );
        }

        // Recover the message signer
        address recoveredAddress = ecrecover(digest, _v, _r, _s);

        // Ensure the recovered signer is the given voter
        if (recoveredAddress == address(0) || recoveredAddress != _voter) revert INVALID_SIGNATURE();

        return _castVote(_proposalId, _voter, _support, "");
    }

    
    
    
    
    function _castVote(
        bytes32 _proposalId,
        address _voter,
        uint256 _support,
        string memory _reason
    ) internal returns (uint256) {
        // Ensure voting is active
        if (state(_proposalId) != ProposalState.Active) revert VOTING_NOT_STARTED();

        // Ensure the voter hasn't already voted
        if (hasVoted[_proposalId][_voter]) revert ALREADY_VOTED();

        // Ensure the vote is valid
        if (_support > 2) revert INVALID_VOTE();

        // Record the voter as having voted
        hasVoted[_proposalId][_voter] = true;

        // Get the pointer to the proposal
        Proposal storage proposal = proposals[_proposalId];

        // Used to store the voter's weight
        uint256 weight;

        // Cannot realistically underflow and `getVotes` would revert
        unchecked {
            // Get the voter's weight at the time the proposal was created
            weight = getVotes(_voter, proposal.timeCreated);

            // If the vote is against:
            if (_support == 0) {
                // Update the total number of votes against
                proposal.againstVotes += SafeCast.toUint32(weight);

                // Else if the vote is for:
            } else if (_support == 1) {
                // Update the total number of votes for
                proposal.forVotes += SafeCast.toUint32(weight);

                // Else if the vote is to abstain:
            } else if (_support == 2) {
                // Update the total number of votes abstaining
                proposal.abstainVotes += SafeCast.toUint32(weight);
            }
        }

        emit VoteCast(_voter, _proposalId, _support, weight, _reason);

        return weight;
    }

    ///                                                          ///
    ///                        QUEUE PROPOSAL                    ///
    ///                                                          ///

    
    
    function queue(bytes32 _proposalId) external returns (uint256 eta) {
        // Ensure the proposal has succeeded
        if (state(_proposalId) != ProposalState.Succeeded) revert PROPOSAL_UNSUCCESSFUL();

        // Schedule the proposal for execution
        eta = settings.treasury.queue(_proposalId);

        emit ProposalQueued(_proposalId, eta);
    }

    ///                                                          ///
    ///                       EXECUTE PROPOSAL                   ///
    ///                                                          ///

    
    
    
    
    
    
    function execute(
        address[] calldata _targets,
        uint256[] calldata _values,
        bytes[] calldata _calldatas,
        bytes32 _descriptionHash,
        address _proposer
    ) external payable returns (bytes32) {
        // Get the proposal id
        bytes32 proposalId = hashProposal(_targets, _values, _calldatas, _descriptionHash, _proposer);

        // Ensure the proposal is queued
        if (state(proposalId) != ProposalState.Queued) revert PROPOSAL_NOT_QUEUED(proposalId);

        // Mark the proposal as executed
        proposals[proposalId].executed = true;

        // Execute the proposal
        settings.treasury.execute{ value: msg.value }(_targets, _values, _calldatas, _descriptionHash, _proposer);

        emit ProposalExecuted(proposalId);

        return proposalId;
    }

    ///                                                          ///
    ///                        CANCEL PROPOSAL                   ///
    ///                                                          ///

    
    
    function cancel(bytes32 _proposalId) external {
        // Ensure the proposal hasn't been executed
        if (state(_proposalId) == ProposalState.Executed) revert PROPOSAL_ALREADY_EXECUTED();

        // Get a copy of the proposal
        Proposal memory proposal = proposals[_proposalId];

        // Cannot realistically underflow and `getVotes` would revert
        unchecked {
            // Ensure the caller is the proposer or the proposer's voting weight has dropped below the proposal threshold
            if (msg.sender != proposal.proposer && getVotes(proposal.proposer, block.timestamp - 1) >= proposal.proposalThreshold)
                revert INVALID_CANCEL();
        }

        // Update the proposal as canceled
        proposals[_proposalId].canceled = true;

        // If the proposal was queued:
        if (settings.treasury.isQueued(_proposalId)) {
            // Cancel the proposal
            settings.treasury.cancel(_proposalId);
        }

        emit ProposalCanceled(_proposalId);
    }

    ///                                                          ///
    ///                        VETO PROPOSAL                     ///
    ///                                                          ///

    
    
    function veto(bytes32 _proposalId) external {
        // Ensure the caller is the vetoer
        if (msg.sender != settings.vetoer) revert ONLY_VETOER();

        // Ensure the proposal has not been executed
        if (state(_proposalId) == ProposalState.Executed) revert PROPOSAL_ALREADY_EXECUTED();

        // Get the pointer to the proposal
        Proposal storage proposal = proposals[_proposalId];

        // Update the proposal as vetoed
        proposal.vetoed = true;

        // If the proposal was queued:
        if (settings.treasury.isQueued(_proposalId)) {
            // Cancel the proposal
            settings.treasury.cancel(_proposalId);
        }

        emit ProposalVetoed(_proposalId);
    }

    ///                                                          ///
    ///                        PROPOSAL STATE                    ///
    ///                                                          ///

    
    
    function state(bytes32 _proposalId) public view returns (ProposalState) {
        // Get a copy of the proposal
        Proposal memory proposal = proposals[_proposalId];

        // Ensure the proposal exists
        if (proposal.voteStart == 0) revert PROPOSAL_DOES_NOT_EXIST();

        // If the proposal was executed:
        if (proposal.executed) {
            return ProposalState.Executed;

            // Else if the proposal was canceled:
        } else if (proposal.canceled) {
            return ProposalState.Canceled;

            // Else if the proposal was vetoed:
        } else if (proposal.vetoed) {
            return ProposalState.Vetoed;

            // Else if voting has not started:
        } else if (block.timestamp < proposal.voteStart) {
            return ProposalState.Pending;

            // Else if voting has not ended:
        } else if (block.timestamp < proposal.voteEnd) {
            return ProposalState.Active;

            // Else if the proposal failed (outvoted OR didn't reach quorum):
        } else if (proposal.forVotes <= proposal.againstVotes || proposal.forVotes < proposal.quorumVotes) {
            return ProposalState.Defeated;

            // Else if the proposal has not been queued:
        } else if (settings.treasury.timestamp(_proposalId) == 0) {
            return ProposalState.Succeeded;

            // Else if the proposal can no longer be executed:
        } else if (settings.treasury.isExpired(_proposalId)) {
            return ProposalState.Expired;

            // Else the proposal is queued
        } else {
            return ProposalState.Queued;
        }
    }

    
    
    
    function getVotes(address _account, uint256 _timestamp) public view returns (uint256) {
        return settings.token.getPastVotes(_account, _timestamp);
    }

    
    function proposalThreshold() public view returns (uint256) {
        unchecked {
            return (settings.token.totalSupply() * settings.proposalThresholdBps) / BPS_PER_100_PERCENT;
        }
    }

    
    function quorum() public view returns (uint256) {
        unchecked {
            return (settings.token.totalSupply() * settings.quorumThresholdBps) / BPS_PER_100_PERCENT;
        }
    }

    
    
    function getProposal(bytes32 _proposalId) external view returns (Proposal memory) {
        return proposals[_proposalId];
    }

    
    
    function proposalSnapshot(bytes32 _proposalId) external view returns (uint256) {
        return proposals[_proposalId].voteStart;
    }

    
    
    function proposalDeadline(bytes32 _proposalId) external view returns (uint256) {
        return proposals[_proposalId].voteEnd;
    }

    
    
    function proposalVotes(bytes32 _proposalId)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        Proposal memory proposal = proposals[_proposalId];

        return (proposal.againstVotes, proposal.forVotes, proposal.abstainVotes);
    }

    
    
    function proposalEta(bytes32 _proposalId) external view returns (uint256) {
        return settings.treasury.timestamp(_proposalId);
    }

    ///                                                          ///
    ///                      GOVERNOR SETTINGS                   ///
    ///                                                          ///

    
    function proposalThresholdBps() external view returns (uint256) {
        return settings.proposalThresholdBps;
    }

    
    function quorumThresholdBps() external view returns (uint256) {
        return settings.quorumThresholdBps;
    }

    
    function votingDelay() external view returns (uint256) {
        return settings.votingDelay;
    }

    
    function votingPeriod() external view returns (uint256) {
        return settings.votingPeriod;
    }

    
    function vetoer() external view returns (address) {
        return settings.vetoer;
    }

    
    function token() external view returns (address) {
        return address(settings.token);
    }

    
    function treasury() external view returns (address) {
        return address(settings.treasury);
    }

    ///                                                          ///
    ///                       UPDATE SETTINGS                    ///
    ///                                                          ///

    
    
    function updateVotingDelay(uint256 _newVotingDelay) external onlyOwner {
        if (_newVotingDelay < MIN_VOTING_DELAY || _newVotingDelay > MAX_VOTING_DELAY) revert INVALID_VOTING_DELAY();

        emit VotingDelayUpdated(settings.votingDelay, _newVotingDelay);

        settings.votingDelay = uint48(_newVotingDelay);
    }

    
    
    function updateVotingPeriod(uint256 _newVotingPeriod) external onlyOwner {
        if (_newVotingPeriod < MIN_VOTING_PERIOD || _newVotingPeriod > MAX_VOTING_PERIOD) revert INVALID_VOTING_PERIOD();

        emit VotingPeriodUpdated(settings.votingPeriod, _newVotingPeriod);

        settings.votingPeriod = uint48(_newVotingPeriod);
    }

    
    
    function updateProposalThresholdBps(uint256 _newProposalThresholdBps) external onlyOwner {
        if (
            _newProposalThresholdBps < MIN_PROPOSAL_THRESHOLD_BPS ||
            _newProposalThresholdBps > MAX_PROPOSAL_THRESHOLD_BPS ||
            _newProposalThresholdBps >= settings.quorumThresholdBps
        ) revert INVALID_PROPOSAL_THRESHOLD_BPS();

        emit ProposalThresholdBpsUpdated(settings.proposalThresholdBps, _newProposalThresholdBps);

        settings.proposalThresholdBps = uint16(_newProposalThresholdBps);
    }

    
    
    function updateQuorumThresholdBps(uint256 _newQuorumVotesBps) external onlyOwner {
        if (
            _newQuorumVotesBps < MIN_QUORUM_THRESHOLD_BPS ||
            _newQuorumVotesBps > MAX_QUORUM_THRESHOLD_BPS ||
            settings.proposalThresholdBps >= _newQuorumVotesBps
        ) revert INVALID_QUORUM_THRESHOLD_BPS();

        emit QuorumVotesBpsUpdated(settings.quorumThresholdBps, _newQuorumVotesBps);

        settings.quorumThresholdBps = uint16(_newQuorumVotesBps);
    }

    
    
    function updateVetoer(address _newVetoer) external onlyOwner {
        if (_newVetoer == address(0)) revert ADDRESS_ZERO();

        emit VetoerUpdated(settings.vetoer, _newVetoer);

        settings.vetoer = _newVetoer;
    }

    
    function burnVetoer() external onlyOwner {
        emit VetoerUpdated(settings.vetoer, address(0));

        delete settings.vetoer;
    }

    ///                                                          ///
    ///                       GOVERNOR UPGRADE                   ///
    ///                                                          ///

    
    
    
    function _authorizeUpgrade(address _newImpl) internal view override onlyOwner {
        // Ensure the new implementation is a registered upgrade
        if (!manager.isRegisteredUpgrade(_getImplementation(), _newImpl)) revert INVALID_UPGRADE(_newImpl);
    }
}

// 
pragma solidity 0.8.16;
















/// Modified from:
/// - OpenZeppelin Contracts v4.7.3 (governance/TimelockController.sol)
/// - NounsDAOExecutor.sol commit 2cbe6c7 - licensed under the BSD-3-Clause license.
contract Treasury is ITreasury, VersionedContract, UUPS, Ownable, ProposalHasher, TreasuryStorageV1 {
    ///                                                          ///
    ///                         CONSTANTS                        ///
    ///                                                          ///

    
    uint128 private constant INITIAL_GRACE_PERIOD = 2 weeks;

    ///                                                          ///
    ///                         IMMUTABLES                       ///
    ///                                                          ///

    
    IManager private immutable manager;

    ///                                                          ///
    ///                         CONSTRUCTOR                      ///
    ///                                                          ///

    
    constructor(address _manager) payable initializer {
        manager = IManager(_manager);
    }

    ///                                                          ///
    ///                         INITIALIZER                      ///
    ///                                                          ///

    
    
    
    function initialize(address _governor, uint256 _delay) external initializer {
        // Ensure the caller is the contract manager
        if (msg.sender != address(manager)) revert ONLY_MANAGER();

        // Ensure a governor address was provided
        if (_governor == address(0)) revert ADDRESS_ZERO();

        // Grant ownership to the governor
        __Ownable_init(_governor);

        // Store the time delay
        settings.delay = SafeCast.toUint128(_delay);

        // Set the default grace period
        settings.gracePeriod = INITIAL_GRACE_PERIOD;

        emit DelayUpdated(0, _delay);
    }

    ///                                                          ///
    ///                      TRANSACTION STATE                   ///
    ///                                                          ///

    
    
    function timestamp(bytes32 _proposalId) external view returns (uint256) {
        return timestamps[_proposalId];
    }

    
    
    function isExpired(bytes32 _proposalId) external view returns (bool) {
        unchecked {
            return block.timestamp > (timestamps[_proposalId] + settings.gracePeriod);
        }
    }

    
    
    function isQueued(bytes32 _proposalId) public view returns (bool) {
        return timestamps[_proposalId] != 0;
    }

    
    
    function isReady(bytes32 _proposalId) public view returns (bool) {
        return timestamps[_proposalId] != 0 && block.timestamp >= timestamps[_proposalId];
    }

    ///                                                          ///
    ///                        QUEUE PROPOSAL                    ///
    ///                                                          ///

    
    
    function queue(bytes32 _proposalId) external onlyOwner returns (uint256 eta) {
        // Ensure the proposal was not already queued
        if (isQueued(_proposalId)) revert PROPOSAL_ALREADY_QUEUED();

        // Cannot realistically overflow
        unchecked {
            // Compute the timestamp that the proposal will be valid to execute
            eta = block.timestamp + settings.delay;
        }

        // Store the timestamp
        timestamps[_proposalId] = eta;

        emit TransactionScheduled(_proposalId, eta);
    }

    ///                                                          ///
    ///                       EXECUTE PROPOSAL                   ///
    ///                                                          ///

    
    
    
    
    
    
    function execute(
        address[] calldata _targets,
        uint256[] calldata _values,
        bytes[] calldata _calldatas,
        bytes32 _descriptionHash,
        address _proposer
    ) external payable onlyOwner {
        // Get the proposal id
        bytes32 proposalId = hashProposal(_targets, _values, _calldatas, _descriptionHash, _proposer);

        // Ensure the proposal is ready to execute
        if (!isReady(proposalId)) revert EXECUTION_NOT_READY(proposalId);

        // Remove the proposal from the queue
        delete timestamps[proposalId];

        // Cache the number of targets
        uint256 numTargets = _targets.length;

        // Cannot realistically overflow
        unchecked {
            // For each target:
            for (uint256 i = 0; i < numTargets; ++i) {
                // Execute the transaction
                (bool success, ) = _targets[i].call{ value: _values[i] }(_calldatas[i]);

                // Ensure the transaction succeeded
                if (!success) revert EXECUTION_FAILED(i);
            }
        }

        emit TransactionExecuted(proposalId, _targets, _values, _calldatas);
    }

    ///                                                          ///
    ///                       CANCEL PROPOSAL                    ///
    ///                                                          ///

    
    
    function cancel(bytes32 _proposalId) external onlyOwner {
        // Ensure the proposal is queued
        if (!isQueued(_proposalId)) revert PROPOSAL_NOT_QUEUED();

        // Remove the proposal from the queue
        delete timestamps[_proposalId];

        emit TransactionCanceled(_proposalId);
    }

    ///                                                          ///
    ///                      TREASURY SETTINGS                   ///
    ///                                                          ///

    
    function delay() external view returns (uint256) {
        return settings.delay;
    }

    
    function gracePeriod() external view returns (uint256) {
        return settings.gracePeriod;
    }

    ///                                                          ///
    ///                       UPDATE SETTINGS                    ///
    ///                                                          ///

    
    
    function updateDelay(uint256 _newDelay) external {
        // Ensure the caller is the treasury itself
        if (msg.sender != address(this)) revert ONLY_TREASURY();

        emit DelayUpdated(settings.delay, _newDelay);

        // Update the delay
        settings.delay = SafeCast.toUint128(_newDelay);
    }

    
    
    function updateGracePeriod(uint256 _newGracePeriod) external {
        // Ensure the caller is the treasury itself
        if (msg.sender != address(this)) revert ONLY_TREASURY();

        emit GracePeriodUpdated(settings.gracePeriod, _newGracePeriod);

        // Update the grace period
        settings.gracePeriod = SafeCast.toUint128(_newGracePeriod);
    }

    ///                                                          ///
    ///                        RECEIVE TOKENS                    ///
    ///                                                          ///

    
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public pure returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }

    
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public pure returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    
    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public pure returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }

    
    receive() external payable {}

    ///                                                          ///
    ///                       TREASURY UPGRADE                   ///
    ///                                                          ///

    
    
    
    function _authorizeUpgrade(address _newImpl) internal view override {
        // Ensure the caller is the treasury itself
        if (msg.sender != address(this)) revert ONLY_TREASURY();

        // Ensure the new implementation is a registered upgrade
        if (!manager.isRegisteredUpgrade(_getImplementation(), _newImpl)) revert INVALID_UPGRADE(_newImpl);
    }
}

// 
pragma solidity 0.8.16;




/// - Uses custom errors `INVALID_TARGET()` & `DELEGATE_CALL_FAILED()`
/// - Adds util converting address to bytes32
library Address {
    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error INVALID_TARGET();

    
    error DELEGATE_CALL_FAILED();

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    function toBytes32(address _account) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_account)) << 96);
    }

    
    function isContract(address _account) internal view returns (bool rv) {
        assembly {
            rv := gt(extcodesize(_account), 0)
        }
    }

    
    function functionDelegateCall(address _target, bytes memory _data) internal returns (bytes memory) {
        if (!isContract(_target)) revert INVALID_TARGET();

        (bool success, bytes memory returndata) = _target.delegatecall(_data);

        return verifyCallResult(success, returndata);
    }

    
    function verifyCallResult(bool _success, bytes memory _returndata) internal pure returns (bytes memory) {
        if (_success) {
            return _returndata;
        } else {
            if (_returndata.length > 0) {
                assembly {
                    let returndata_size := mload(_returndata)

                    revert(add(32, _returndata), returndata_size)
                }
            } else {
                revert DELEGATE_CALL_FAILED();
            }
        }
    }
}

// 
pragma solidity 0.8.16;


/// - Uses custom error `UNSAFE_CAST()`
library SafeCast {
    error UNSAFE_CAST();

    function toUint128(uint256 x) internal pure returns (uint128) {
        if (x > type(uint128).max) revert UNSAFE_CAST();

        return uint128(x);
    }

    function toUint64(uint256 x) internal pure returns (uint64) {
        if (x > type(uint64).max) revert UNSAFE_CAST();

        return uint64(x);
    }

    function toUint48(uint256 x) internal pure returns (uint48) {
        if (x > type(uint48).max) revert UNSAFE_CAST();

        return uint48(x);
    }

    function toUint40(uint256 x) internal pure returns (uint40) {
        if (x > type(uint40).max) revert UNSAFE_CAST();

        return uint40(x);
    }

    function toUint32(uint256 x) internal pure returns (uint32) {
        if (x > type(uint32).max) revert UNSAFE_CAST();

        return uint32(x);
    }

    function toUint16(uint256 x) internal pure returns (uint16) {
        if (x > type(uint16).max) revert UNSAFE_CAST();

        return uint16(x);
    }

    function toUint8(uint256 x) internal pure returns (uint8) {
        if (x > type(uint8).max) revert UNSAFE_CAST();

        return uint8(x);
    }
}

// 
pragma solidity ^0.8.0;


abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }
}


abstract contract ERC1155TokenReceiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// 
pragma solidity 0.8.16;







interface IManager is IUUPS, IOwnable {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    
    
    
    
    
    event DAODeployed(address token, address metadata, address auction, address treasury, address governor);

    
    
    
    event UpgradeRegistered(address baseImpl, address upgradeImpl);

    
    
    
    event UpgradeRemoved(address baseImpl, address upgradeImpl);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error FOUNDER_REQUIRED();

    ///                                                          ///
    ///                            STRUCTS                       ///
    ///                                                          ///

    
    
    
    
    struct FounderParams {
        address wallet;
        uint256 ownershipPct;
        uint256 vestExpiry;
    }

    
    struct DAOVersionInfo {
        string token;
        string metadata;
        string auction;
        string treasury;
        string governor; 
    }

    
    
    struct TokenParams {
        bytes initStrings;
    }

    
    
    
    struct AuctionParams {
        uint256 reservePrice;
        uint256 duration;
    }

    
    
    
    
    
    
    
    struct GovParams {
        uint256 timelockDelay;
        uint256 votingDelay;
        uint256 votingPeriod;
        uint256 proposalThresholdBps;
        uint256 quorumThresholdBps;
        address vetoer;
    }

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    function tokenImpl() external view returns (address);

    
    function metadataImpl() external view returns (address);

    
    function auctionImpl() external view returns (address);

    
    function treasuryImpl() external view returns (address);

    
    function governorImpl() external view returns (address);

    
    
    
    
    
    function deploy(
        FounderParams[] calldata founderParams,
        TokenParams calldata tokenParams,
        AuctionParams calldata auctionParams,
        GovParams calldata govParams
    )
        external
        returns (
            address token,
            address metadataRenderer,
            address auction,
            address treasury,
            address governor
        );

    
    
    function getAddresses(address token)
        external
        returns (
            address metadataRenderer,
            address auction,
            address treasury,
            address governor
        );

    
    
    
    function isRegisteredUpgrade(address baseImpl, address upgradeImpl) external view returns (bool);

    
    
    
    function registerUpgrade(address baseImpl, address upgradeImpl) external;

    
    
    
    function removeUpgrade(address baseImpl, address upgradeImpl) external;
}

// 
pragma solidity 0.8.16;


















contract Token is IToken, VersionedContract, UUPS, Ownable, ReentrancyGuard, ERC721Votes, TokenStorageV1, TokenStorageV2 {
    ///                                                          ///
    ///                         IMMUTABLES                       ///
    ///                                                          ///

    
    IManager private immutable manager;

    ///                                                          ///
    ///                          MODIFIERS                       ///
    ///                                                          ///

    
    modifier onlyAuctionOrMinter() {
        if (msg.sender != settings.auction && !minter[msg.sender]) {
            revert ONLY_AUCTION_OR_MINTER();
        }

        _;
    }

    ///                                                          ///
    ///                         CONSTRUCTOR                      ///
    ///                                                          ///

    
    constructor(address _manager) payable initializer {
        manager = IManager(_manager);
    }

    ///                                                          ///
    ///                         INITIALIZER                      ///
    ///                                                          ///

    
    
    
    
    
    
    function initialize(
        IManager.FounderParams[] calldata _founders,
        bytes calldata _initStrings,
        address _metadataRenderer,
        address _auction,
        address _initialOwner
    ) external initializer {
        // Ensure the caller is the contract manager
        if (msg.sender != address(manager)) {
            revert ONLY_MANAGER();
        }

        // Initialize the reentrancy guard
        __ReentrancyGuard_init();

        // Setup ownable
        __Ownable_init(_initialOwner);

        // Store the founders and compute their allocations
        _addFounders(_founders);

        // Decode the token name and symbol
        (string memory _name, string memory _symbol, , , , ) = abi.decode(_initStrings, (string, string, string, string, string, string));

        // Initialize the ERC-721 token
        __ERC721_init(_name, _symbol);

        // Store the metadata renderer and auction house
        settings.metadataRenderer = IBaseMetadata(_metadataRenderer);
        settings.auction = _auction;
    }

    
    
    function onFirstAuctionStarted() external override {
        if (msg.sender != settings.auction) {
            revert ONLY_AUCTION();
        }

        // Force transfer ownership to the treasury
        _transferOwnership(IAuction(settings.auction).treasury());
    }

    
    
    
    function _addFounders(IManager.FounderParams[] calldata _founders) internal {
        // Used to store the total percent ownership among the founders
        uint256 totalOwnership;

        uint8 numFoundersAdded = 0;

        unchecked {
            // For each founder:
            for (uint256 i; i < _founders.length; ++i) {
                // Cache the percent ownership
                uint256 founderPct = _founders[i].ownershipPct;

                // Continue if no ownership is specified
                if (founderPct == 0) {
                    continue;
                }

                // Update the total ownership and ensure it's valid
                totalOwnership += founderPct;

                // Check that founders own less than 100% of tokens
                if (totalOwnership > 99) {
                    revert INVALID_FOUNDER_OWNERSHIP();
                }

                // Compute the founder's id
                uint256 founderId = numFoundersAdded++;

                // Get the pointer to store the founder
                Founder storage newFounder = founder[founderId];

                // Store the founder's vesting details
                newFounder.wallet = _founders[i].wallet;
                newFounder.vestExpiry = uint32(_founders[i].vestExpiry);
                // Total ownership cannot be above 100 so this fits safely in uint8
                newFounder.ownershipPct = uint8(founderPct);

                // Compute the vesting schedule
                uint256 schedule = 100 / founderPct;

                // Used to store the base token id the founder will recieve
                uint256 baseTokenId;

                // For each token to vest:
                for (uint256 j; j < founderPct; ++j) {
                    // Get the available token id
                    baseTokenId = _getNextTokenId(baseTokenId);

                    // Store the founder as the recipient
                    tokenRecipient[baseTokenId] = newFounder;

                    emit MintScheduled(baseTokenId, founderId, newFounder);

                    // Update the base token id
                    baseTokenId = (baseTokenId + schedule) % 100;
                }
            }

            // Store the founders' details
            settings.totalOwnership = uint8(totalOwnership);
            settings.numFounders = numFoundersAdded;
        }
    }

    
    
    function _getNextTokenId(uint256 _tokenId) internal view returns (uint256) {
        unchecked {
            while (tokenRecipient[_tokenId].wallet != address(0)) {
                _tokenId = (++_tokenId) % 100;
            }

            return _tokenId;
        }
    }

    ///                                                          ///
    ///                             MINT                         ///
    ///                                                          ///

    
    function mint() external nonReentrant onlyAuctionOrMinter returns (uint256 tokenId) {
        return _mintWithVesting(msg.sender);
    }

    
    function mint(address recipient) external nonReentrant onlyAuctionOrMinter returns (uint256 tokenId) {
        return _mintWithVesting(recipient);
    }

    function _mintWithVesting(address recipient) internal returns (uint256 tokenId) {
        // Cannot realistically overflow
        unchecked {
            do {
                // Get the next token to mint
                tokenId = settings.mintCount++;

                // Lookup whether the token is for a founder, and mint accordingly if so
            } while (_isForFounder(tokenId));
        }

        // Mint the next available token to the auction house for bidding
        _mint(recipient, tokenId);
    }

    
    
    
    function _mint(address _to, uint256 _tokenId) internal override {
        // Mint the token
        super._mint(_to, _tokenId);

        // Increment the total supply
        unchecked {
            ++settings.totalSupply;
        }

        // Generate the token attributes
        if (!settings.metadataRenderer.onMinted(_tokenId)) revert NO_METADATA_GENERATED();
    }

    
    
    function _isForFounder(uint256 _tokenId) private returns (bool) {
        // Get the base token id
        uint256 baseTokenId = _tokenId % 100;

        // If there is no scheduled recipient:
        if (tokenRecipient[baseTokenId].wallet == address(0)) {
            return false;

            // Else if the founder is still vesting:
        } else if (block.timestamp < tokenRecipient[baseTokenId].vestExpiry) {
            // Mint the token to the founder
            _mint(tokenRecipient[baseTokenId].wallet, _tokenId);

            return true;

            // Else the founder has finished vesting:
        } else {
            // Remove them from future lookups
            delete tokenRecipient[baseTokenId];

            return false;
        }
    }

    ///                                                          ///
    ///                             BURN                         ///
    ///                                                          ///

    
    
    function burn(uint256 _tokenId) external onlyAuctionOrMinter {
        if (ownerOf(_tokenId) != msg.sender) {
            revert ONLY_TOKEN_OWNER();
        }

        _burn(_tokenId);
    }

    function _burn(uint256 _tokenId) internal override {
        super._burn(_tokenId);

        unchecked {
            --settings.totalSupply;
        }
    }

    ///                                                          ///
    ///                           METADATA                       ///
    ///                                                          ///

    
    
    function tokenURI(uint256 _tokenId) public view override(IToken, ERC721) returns (string memory) {
        return settings.metadataRenderer.tokenURI(_tokenId);
    }

    
    function contractURI() public view override(IToken, ERC721) returns (string memory) {
        return settings.metadataRenderer.contractURI();
    }

    ///                                                          ///
    ///                           FOUNDERS                       ///
    ///                                                          ///

    
    function totalFounders() external view returns (uint256) {
        return settings.numFounders;
    }

    
    function totalFounderOwnership() external view returns (uint256) {
        return settings.totalOwnership;
    }

    
    
    function getFounder(uint256 _founderId) external view returns (Founder memory) {
        return founder[_founderId];
    }

    
    function getFounders() external view returns (Founder[] memory) {
        // Cache the number of founders
        uint256 numFounders = settings.numFounders;

        // Get a temporary array to hold all founders
        Founder[] memory founders = new Founder[](numFounders);

        // Cannot realistically overflow
        unchecked {
            // Add each founder to the array
            for (uint256 i; i < numFounders; ++i) {
                founders[i] = founder[i];
            }
        }

        return founders;
    }

    
    /// NOTE: If a founder is returned, there's no guarantee they'll receive the token as vesting expiration is not considered
    
    function getScheduledRecipient(uint256 _tokenId) external view returns (Founder memory) {
        return tokenRecipient[_tokenId % 100];
    }

    
    
    function updateFounders(IManager.FounderParams[] calldata newFounders) external onlyOwner {
        // Cache the number of founders
        uint256 numFounders = settings.numFounders;

        // Get a temporary array to hold all founders
        Founder[] memory cachedFounders = new Founder[](numFounders);

        // Cannot realistically overflow
        unchecked {
            // Add each founder to the array
            for (uint256 i; i < numFounders; ++i) {
                cachedFounders[i] = founder[i];
            }
        }

        // Keep a mapping of all the reserved token IDs we're set to clear.
        bool[] memory clearedTokenIds = new bool[](100);

        unchecked {
            // for each existing founder:
            for (uint256 i; i < cachedFounders.length; ++i) {
                // copy the founder into memory
                Founder memory cachedFounder = cachedFounders[i];

                // Delete the founder from the stored mapping
                delete founder[i];

                // Some DAOs were initialized with 0 percentage ownership.
                // This skips them to avoid a division by zero error.
                if (cachedFounder.ownershipPct == 0) {
                    continue;
                }

                // using the ownership percentage, get reserved token percentages
                uint256 schedule = 100 / cachedFounder.ownershipPct;

                // Used to reverse engineer the indices the founder has reserved tokens in.
                uint256 baseTokenId;

                for (uint256 j; j < cachedFounder.ownershipPct; ++j) {
                    // Get the next index that hasn't already been cleared
                    while (clearedTokenIds[baseTokenId] != false) {
                        baseTokenId = (++baseTokenId) % 100;
                    }

                    delete tokenRecipient[baseTokenId];
                    clearedTokenIds[baseTokenId] = true;

                    emit MintUnscheduled(baseTokenId, i, cachedFounder);

                    // Update the base token id
                    baseTokenId = (baseTokenId + schedule) % 100;
                }
            }
        }

        settings.numFounders = 0;
        settings.totalOwnership = 0;
        emit FounderAllocationsCleared(newFounders);

        _addFounders(newFounders);
    }

    ///                                                          ///
    ///                           SETTINGS                       ///
    ///                                                          ///

    
    function totalSupply() external view returns (uint256) {
        return settings.totalSupply;
    }

    
    function auction() external view returns (address) {
        return settings.auction;
    }

    
    function metadataRenderer() external view returns (address) {
        return address(settings.metadataRenderer);
    }

    function owner() public view override(IToken, Ownable) returns (address) {
        return super.owner();
    }

    
    
    function updateMinters(MinterParams[] calldata _minters) external onlyOwner {
        // Update each minter
        for (uint256 i; i < _minters.length; ++i) {
            // Skip if the minter is already set to the correct value
            if (minter[_minters[i].minter] == _minters[i].allowed) continue;

            emit MinterUpdated(_minters[i].minter, _minters[i].allowed);

            // Update the minter
            minter[_minters[i].minter] = _minters[i].allowed;
        }
    }

    ///                                                          ///
    ///                         TOKEN UPGRADE                    ///
    ///                                                          ///

    
    
    
    function _authorizeUpgrade(address _newImpl) internal view override {
        // Ensure the caller is the shared owner of the token and metadata renderer
        if (msg.sender != owner()) revert ONLY_OWNER();

        // Ensure the implementation is valid
        if (!manager.isRegisteredUpgrade(_getImplementation(), _newImpl)) revert INVALID_UPGRADE(_newImpl);
    }
}

// 
pragma solidity 0.8.16;







interface IBaseMetadata is IUUPS {
    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error ONLY_MANAGER();

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    
    function initialize(
        bytes calldata initStrings,
        address token
    ) external;

    
    
    function onMinted(uint256 tokenId) external returns (bool);

    
    
    function tokenURI(uint256 tokenId) external view returns (string memory);

    
    function contractURI() external view returns (string memory);

    
    function token() external view returns (address);

    
    function owner() external view returns (address);
}
