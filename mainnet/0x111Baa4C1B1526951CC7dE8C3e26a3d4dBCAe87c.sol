// SPDX-License-Identifier: MIT


// 

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// 

pragma solidity ^0.8.0;


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// 

pragma solidity ^0.8.0;




/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// 


pragma solidity >=0.7.0 <0.9.0;



abstract contract FactoryFriendly is OwnableUpgradeable {
    function setUp(bytes memory initializeParams) public virtual;
}

// 
pragma solidity >=0.7.0 <0.9.0;







contract Guardable is OwnableUpgradeable {
    event ChangedGuard(address guard);

    address public guard;

    
    
    function setGuard(address _guard) external onlyOwner {
        if (_guard != address(0)) {
            require(
                BaseGuard(_guard).supportsInterface(type(IGuard).interfaceId),
                "Guard does not implement IERC165"
            );
        }
        guard = _guard;
        emit ChangedGuard(guard);
    }

    function getGuard() external view returns (address _guard) {
        return guard;
    }
}

// 


pragma solidity >=0.7.0 <0.9.0;





abstract contract Module is FactoryFriendly, Guardable {
    
    event AvatarSet(address indexed previousAvatar, address indexed newAvatar);
    
    event TargetSet(address indexed previousTarget, address indexed newTarget);

    
    address public avatar;
    
    address public target;

    
    
    function setAvatar(address _avatar) public onlyOwner {
        address previousAvatar = avatar;
        avatar = _avatar;
        emit AvatarSet(previousAvatar, _avatar);
    }

    
    
    function setTarget(address _target) public onlyOwner {
        address previousTarget = target;
        target = _target;
        emit TargetSet(previousTarget, _target);
    }

    
    
    
    
    
    
    function exec(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) internal returns (bool success) {
        /// check if a transactioon guard is enabled.
        if (guard != address(0)) {
            IGuard(guard).checkTransaction(
                /// Transaction info used by module transactions
                to,
                value,
                data,
                operation,
                /// Zero out the redundant transaction information only used for Safe multisig transctions
                0,
                0,
                0,
                address(0),
                payable(0),
                bytes("0x"),
                address(0)
            );
        }
        success = IAvatar(target).execTransactionFromModule(
            to,
            value,
            data,
            operation
        );
        if (guard != address(0)) {
            IGuard(guard).checkAfterExecution(bytes32("0x"), success);
        }
        return success;
    }

    
    
    
    
    
    
    function execAndReturnData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) internal returns (bool success, bytes memory returnData) {
        /// check if a transactioon guard is enabled.
        if (guard != address(0)) {
            IGuard(guard).checkTransaction(
                /// Transaction info used by module transactions
                to,
                value,
                data,
                operation,
                /// Zero out the redundant transaction information only used for Safe multisig transctions
                0,
                0,
                0,
                address(0),
                payable(0),
                bytes("0x"),
                address(0)
            );
        }
        (success, returnData) = IAvatar(target)
            .execTransactionFromModuleReturnData(to, value, data, operation);
        if (guard != address(0)) {
            IGuard(guard).checkAfterExecution(bytes32("0x"), success);
        }
        return (success, returnData);
    }
}

// 
pragma solidity ^0.8.0;

interface IFactorySafeHelper {
    function createAndSetupSafe(bytes32 salt)
        external
        returns (address safeAddress, address);
}

// 
pragma solidity >=0.8.0;




abstract contract RealityModule is Module {
    bytes32 public constant INVALIDATED =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    bytes32 public constant DOMAIN_SEPARATOR_TYPEHASH =
        0x47e79534a245952e8b16893a336b85a3d9ea9fa8c573f3d803afb92a79469218;
    // keccak256(
    //     "EIP712Domain(uint256 chainId,address verifyingContract)"
    // );

    bytes32 public constant TRANSACTION_TYPEHASH =
        0x72e9670a7ee00f5fbf1049b8c38e3f22fab7e9b85029e85cf9412f17fdd5c2ad;
    // keccak256(
    //     "Transaction(address to,uint256 value,bytes data,uint8 operation,uint256 nonce)"
    // );

    event ProposalQuestionCreated(
        bytes32 indexed questionId,
        string indexed proposalId
    );

    event RealityModuleSetup(
        address indexed initiator,
        address indexed owner,
        address indexed avatar,
        address target
    );

    RealitioV3 public oracle;
    uint256 public template;
    uint32 public questionTimeout;
    uint32 public questionCooldown;
    uint32 public answerExpiration;
    address public questionArbitrator;
    uint256 public minimumBond;

    // Mapping of question hash to question id. Special case: INVALIDATED for question hashes that have been invalidated
    mapping(bytes32 => bytes32) public questionIds;
    // Mapping of questionHash to transactionHash to execution state
    mapping(bytes32 => mapping(bytes32 => bool))
        public executedProposalTransactions;

    
    
    
    
    
    
    
    
    
    
    constructor(
        address _owner,
        address _avatar,
        address _target,
        RealitioV3 _oracle,
        uint32 timeout,
        uint32 cooldown,
        uint32 expiration,
        uint256 bond,
        uint256 templateId
    ) {
        bytes memory initParams = abi.encode(
            _owner,
            _avatar,
            _target,
            _oracle,
            timeout,
            cooldown,
            expiration,
            bond,
            templateId
        );
        setUp(initParams);
    }

    function setUp(bytes memory initParams) public override {
        (
            address _owner,
            address _avatar,
            address _target,
            RealitioV3 _oracle,
            uint32 timeout,
            uint32 cooldown,
            uint32 expiration,
            uint256 bond,
            uint256 templateId
        ) = abi.decode(
                initParams,
                (
                    address,
                    address,
                    address,
                    RealitioV3,
                    uint32,
                    uint32,
                    uint32,
                    uint256,
                    uint256
                )
            );
        __Ownable_init();
        require(_avatar != address(0), "Avatar can not be zero address");
        require(_target != address(0), "Target can not be zero address");
        require(timeout > 0, "Timeout has to be greater 0");
        require(
            expiration == 0 || expiration - cooldown >= 60,
            "There need to be at least 60s between end of cooldown and expiration"
        );
        avatar = _avatar;
        target = _target;
        oracle = _oracle;
        answerExpiration = expiration;
        questionTimeout = timeout;
        questionCooldown = cooldown;
        questionArbitrator = address(oracle);
        minimumBond = bond;
        template = templateId;

        transferOwnership(_owner);

        emit RealityModuleSetup(msg.sender, _owner, avatar, target);
    }

    
    function setQuestionTimeout(uint32 timeout) public onlyOwner {
        require(timeout > 0, "Timeout has to be greater 0");
        questionTimeout = timeout;
    }

    
    
    
    
    function setQuestionCooldown(uint32 cooldown) public onlyOwner {
        uint32 expiration = answerExpiration;
        require(
            expiration == 0 || expiration - cooldown >= 60,
            "There need to be at least 60s between end of cooldown and expiration"
        );
        questionCooldown = cooldown;
    }

    
    
    
    
    
    function setAnswerExpiration(uint32 expiration) public onlyOwner {
        require(
            expiration == 0 || expiration - questionCooldown >= 60,
            "There need to be at least 60s between end of cooldown and expiration"
        );
        answerExpiration = expiration;
    }

    
    
    
    function setArbitrator(address arbitrator) public onlyOwner {
        questionArbitrator = arbitrator;
    }

    
    
    
    function setMinimumBond(uint256 bond) public onlyOwner {
        minimumBond = bond;
    }

    
    
    
    
    function setTemplate(uint256 templateId) public onlyOwner {
        template = templateId;
    }

    
    
    
    
    function addProposal(string memory proposalId, bytes32[] memory txHashes)
        public
    {
        addProposalWithNonce(proposalId, txHashes, 0);
    }

    
    
    
    
    function addProposalWithNonce(
        string memory proposalId,
        bytes32[] memory txHashes,
        uint256 nonce
    ) public {
        // We generate the question string used for the oracle
        string memory question = buildQuestion(proposalId, txHashes);
        bytes32 questionHash = keccak256(bytes(question));
        if (nonce > 0) {
            // Previous nonce must have been invalidated by the oracle.
            // However, if the proposal was internally invalidated, it should not be possible to ask it again.
            bytes32 currentQuestionId = questionIds[questionHash];
            require(
                currentQuestionId != INVALIDATED,
                "This proposal has been marked as invalid"
            );
            require(
                oracle.resultFor(currentQuestionId) == INVALIDATED,
                "Previous proposal was not invalidated"
            );
        } else {
            require(
                questionIds[questionHash] == bytes32(0),
                "Proposal has already been submitted"
            );
        }
        bytes32 expectedQuestionId = getQuestionId(question, nonce);
        // Set the question hash for this question id
        questionIds[questionHash] = expectedQuestionId;
        bytes32 questionId = askQuestion(question, nonce);
        require(expectedQuestionId == questionId, "Unexpected question id");
        emit ProposalQuestionCreated(questionId, proposalId);
    }

    function askQuestion(string memory question, uint256 nonce)
        internal
        virtual
        returns (bytes32);

    
    
    
    
    function markProposalAsInvalid(
        string memory proposalId,
        bytes32[] memory txHashes // owner only is checked in markProposalAsInvalidByHash(bytes32)
    ) public {
        string memory question = buildQuestion(proposalId, txHashes);
        bytes32 questionHash = keccak256(bytes(question));
        markProposalAsInvalidByHash(questionHash);
    }

    
    
    
    function markProposalAsInvalidByHash(bytes32 questionHash)
        public
        onlyOwner
    {
        questionIds[questionHash] = INVALIDATED;
    }

    
    
    function markProposalWithExpiredAnswerAsInvalid(bytes32 questionHash)
        public
    {
        uint32 expirationDuration = answerExpiration;
        require(expirationDuration > 0, "Answers are valid forever");
        bytes32 questionId = questionIds[questionHash];
        require(questionId != INVALIDATED, "Proposal is already invalidated");
        require(
            questionId != bytes32(0),
            "No question id set for provided proposal"
        );
        require(
            oracle.resultFor(questionId) == bytes32(uint256(1)),
            "Only positive answers can expire"
        );
        uint32 finalizeTs = oracle.getFinalizeTS(questionId);
        require(
            finalizeTs + uint256(expirationDuration) < block.timestamp,
            "Answer has not expired yet"
        );
        questionIds[questionHash] = INVALIDATED;
    }

    
    
    
    
    
    
    
    
    function executeProposal(
        string memory proposalId,
        bytes32[] memory txHashes,
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) public {
        executeProposalWithIndex(
            proposalId,
            txHashes,
            to,
            value,
            data,
            operation,
            0
        );
    }

    
    
    
    
    
    
    
    
    function executeProposalWithIndex(
        string memory proposalId,
        bytes32[] memory txHashes,
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 txIndex
    ) public {
        // We use the hash of the question to check the execution state, as the other parameters might change, but the question not
        bytes32 questionHash = keccak256(
            bytes(buildQuestion(proposalId, txHashes))
        );
        // Lookup question id for this proposal
        bytes32 questionId = questionIds[questionHash];
        // Question hash needs to set to be eligible for execution
        require(
            questionId != bytes32(0),
            "No question id set for provided proposal"
        );
        require(questionId != INVALIDATED, "Proposal has been invalidated");

        bytes32 txHash = getTransactionHash(
            to,
            value,
            data,
            operation,
            txIndex
        );
        require(txHashes[txIndex] == txHash, "Unexpected transaction hash");

        // Check that the result of the question is 1 (true)
        require(
            oracle.resultFor(questionId) == bytes32(uint256(1)),
            "Transaction was not approved"
        );
        uint256 minBond = minimumBond;
        require(
            minBond == 0 || minBond <= oracle.getBond(questionId),
            "Bond on question not high enough"
        );
        uint32 finalizeTs = oracle.getFinalizeTS(questionId);
        // The answer is valid in the time after the cooldown and before the expiration time (if set).
        require(
            finalizeTs + uint256(questionCooldown) < block.timestamp,
            "Wait for additional cooldown"
        );
        uint32 expiration = answerExpiration;
        require(
            expiration == 0 ||
                finalizeTs + uint256(expiration) >= block.timestamp,
            "Answer has expired"
        );
        // Check this is either the first transaction in the list or that the previous question was already approved
        require(
            txIndex == 0 ||
                executedProposalTransactions[questionHash][
                    txHashes[txIndex - 1]
                ],
            "Previous transaction not executed yet"
        );
        // Check that this question was not executed yet
        require(
            !executedProposalTransactions[questionHash][txHash],
            "Cannot execute transaction again"
        );
        // Mark transaction as executed
        executedProposalTransactions[questionHash][txHash] = true;
        // Execute the transaction via the target.
        require(exec(to, value, data, operation), "Module transaction failed");
    }

    
    
    
    function buildQuestion(string memory proposalId, bytes32[] memory txHashes)
        public
        pure
        returns (string memory)
    {
        string memory txsHash = bytes32ToAsciiString(
            keccak256(abi.encodePacked(txHashes))
        );
        return string(abi.encodePacked(proposalId, bytes3(0xe2909f), txsHash));
    }

    
    
    function getQuestionId(string memory question, uint256 nonce)
        public
        view
        returns (bytes32)
    {
        // Ask the question with a starting time of 0, so that it can be immediately answered
        bytes32 contentHash = keccak256(
            abi.encodePacked(template, uint32(0), question)
        );
        return
            keccak256(
                abi.encodePacked(
                    contentHash,
                    questionArbitrator,
                    questionTimeout,
                    minimumBond,
                    oracle,
                    this,
                    nonce
                )
            );
    }

    
    function getChainId() public view returns (uint256) {
        uint256 id;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            id := chainid()
        }
        return id;
    }

    
    function generateTransactionHashData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 nonce
    ) public view returns (bytes memory) {
        uint256 chainId = getChainId();
        bytes32 domainSeparator = keccak256(
            abi.encode(DOMAIN_SEPARATOR_TYPEHASH, chainId, this)
        );
        bytes32 transactionHash = keccak256(
            abi.encode(
                TRANSACTION_TYPEHASH,
                to,
                value,
                keccak256(data),
                operation,
                nonce
            )
        );
        return
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0x01),
                domainSeparator,
                transactionHash
            );
    }

    function getTransactionHash(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 nonce
    ) public view returns (bytes32) {
        return
            keccak256(
                generateTransactionHashData(to, value, data, operation, nonce)
            );
    }

    function bytes32ToAsciiString(bytes32 _bytes)
        internal
        pure
        returns (string memory)
    {
        bytes memory s = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            uint8 b = uint8(bytes1(_bytes << (i * 8)));
            uint8 hi = uint8(b) / 16;
            uint8 lo = uint8(b) % 16;
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(uint8 b) internal pure returns (bytes1 c) {
        if (b < 10) return bytes1(b + 0x30);
        else return bytes1(b + 0x57);
    }
}

// 
pragma solidity >=0.8.0;

interface RealitioV3 {
    
    
    
    function isFinalized(bytes32 question_id) external view returns (bool);

    
    
    
    function resultFor(bytes32 question_id) external view returns (bytes32);

    
    
    function getFinalizeTS(bytes32 question_id) external view returns (uint32);

    
    
    function isPendingArbitration(bytes32 question_id)
        external
        view
        returns (bool);

    
    /// Placeholders should use gettext() syntax, eg %s.
    
    
    
    function createTemplate(string calldata content) external returns (uint256);

    
    
    function getBond(bytes32 question_id) external view returns (uint256);

    
    
    function getContentHash(bytes32 question_id)
        external
        view
        returns (bytes32);
}

// 
pragma solidity >=0.7.0 <0.9.0;


interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// 
pragma solidity ^0.8.0;







contract FactorySafeHelper is IFactorySafeHelper {
    IGnosisSafeProxyFactory public immutable GNOSIS_SAFE_PROXY_FACTORY;
    RealitioV3 public immutable ORACLE;
    address public immutable GNOSIS_SAFE_TEMPLATE_ADDRESS;
    address public immutable GNOSIS_SAFE_FALLBACK_HANDLER;
    address public immutable SZNS_DAO;
    uint256 public immutable REALITIO_TEMPLATE_ID;

    uint256 public immutable DAO_MODULE_BOND;
    uint32 public immutable DAO_MODULE_EXPIRATION;
    uint32 public immutable DAO_MODULE_TIMEOUT;

    constructor(
        address proxyFactoryAddress,
        address realitioAddress,
        address safeTemplateAddress,
        address safeFallbackHandler,
        address sznsDao,
        uint256 realitioTemplateId,
        uint256 bond,
        uint32 expiration,
        uint32 timeout
    ) {
        GNOSIS_SAFE_PROXY_FACTORY = IGnosisSafeProxyFactory(
            proxyFactoryAddress
        );
        ORACLE = RealitioV3(realitioAddress);

        GNOSIS_SAFE_TEMPLATE_ADDRESS = safeTemplateAddress;
        GNOSIS_SAFE_FALLBACK_HANDLER = safeFallbackHandler;
        SZNS_DAO = sznsDao;
        REALITIO_TEMPLATE_ID = realitioTemplateId;

        DAO_MODULE_BOND = bond;
        DAO_MODULE_EXPIRATION = expiration;
        DAO_MODULE_TIMEOUT = timeout;
    }

    function createAndSetupSafe(bytes32 salt)
        external
        override
        returns (address safeAddress, address realityModule)
    {
        salt = keccak256(abi.encodePacked(salt, msg.sender, address(this)));
        // Deploy safe
        IGnosisSafe safe = GNOSIS_SAFE_PROXY_FACTORY.createProxyWithNonce(
            GNOSIS_SAFE_TEMPLATE_ADDRESS,
            "",
            uint256(salt)
        );
        safeAddress = address(safe);
        // Deploy reality module
        realityModule = address(
            new RealityModuleETH{salt: ""}(
                safeAddress,
                safeAddress,
                safeAddress,
                ORACLE,
                DAO_MODULE_TIMEOUT,
                0, // cooldown, hard-coded to 0
                DAO_MODULE_EXPIRATION,
                DAO_MODULE_BOND,
                REALITIO_TEMPLATE_ID
            )
        );
        // Initialize safe
        address[] memory owners = new address[](1);
        owners[0] = 0x000000000000000000000000000000000000dEaD;
        safe.setup(
            owners, // owners
            1, // threshold
            address(this), // to
            abi.encodeWithSignature(
                "initSafe(address,address)",
                realityModule,
                SZNS_DAO
            ), // data
            GNOSIS_SAFE_FALLBACK_HANDLER, // fallbackHandler
            address(0), // paymentToken
            0, // payment
            payable(0) // paymentReceiver
        );
    }

    function initSafe(address realityModuleAddress, address arbitrator)
        external
    {
        IGnosisSafe safe = IGnosisSafe(address(this));
        safe.enableModule(realityModuleAddress);
        RealityModuleETH(realityModuleAddress).setArbitrator(arbitrator);
    }
}

// 
pragma solidity >=0.8.0;




contract RealityModuleETH is RealityModule {
    
    
    
    
    
    
    
    
    
    
    constructor(
        address _owner,
        address _avatar,
        address _target,
        RealitioV3 _oracle,
        uint32 timeout,
        uint32 cooldown,
        uint32 expiration,
        uint256 bond,
        uint256 templateId
    )
        RealityModule(
            _owner,
            _avatar,
            _target,
            _oracle,
            timeout,
            cooldown,
            expiration,
            bond,
            templateId
        )
    {}

    function askQuestion(string memory question, uint256 nonce)
        internal
        override
        returns (bytes32)
    {
        // Ask the question with a starting time of 0, so that it can be immediately answered
        return
            RealitioV3ETH(address(oracle)).askQuestionWithMinBond(
                template,
                question,
                questionArbitrator,
                questionTimeout,
                0,
                nonce,
                minimumBond
            );
    }
}

// 
pragma solidity >=0.7.0 <0.9.0;

// Pared down version of @gnosis.pm/safe-contracts/contracts/GnosisSafe.sol




interface IGnosisSafe {
    
    
    
    
    
    
    
    
    
    function setup(
        address[] calldata _owners,
        uint256 _threshold,
        address to,
        bytes calldata data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver
    ) external;

    
    ///      This can only be done via a Safe transaction.
    
    
    function enableModule(address module) external;

    
    
    function isModuleEnabled(address module) external view returns (bool);
}

// 
pragma solidity >=0.7.0 <0.9.0;

// Pared down version of @gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol





interface IGnosisSafeProxyFactory {
    
    
    
    
    function createProxyWithNonce(
        address _singleton,
        bytes memory initializer,
        uint256 saltNonce
    ) external returns (IGnosisSafe proxy);
}

interface RealitioV3ETH is RealitioV3 {
    
    
    
    
    
    
    
    
    
    
    function askQuestionWithMinBond(
        uint256 template_id,
        string memory question,
        address arbitrator,
        uint32 timeout,
        uint32 opening_ts,
        uint256 nonce,
        uint256 min_bond
    ) external payable returns (bytes32);
}

interface RealitioV3ERC20 is RealitioV3 {
    
    
    
    
    
    
    
    
    
    
    
    function askQuestionWithMinBondERC20(
        uint256 template_id,
        string memory question,
        address arbitrator,
        uint32 timeout,
        uint32 opening_ts,
        uint256 nonce,
        uint256 min_bond,
        uint256 tokens
    ) external returns (bytes32);
}

// 


pragma solidity >=0.7.0 <0.9.0;



interface IAvatar {
    
    
    
    
    
    function enableModule(address module) external;

    
    
    
    
    
    function disableModule(address prevModule, address module) external;

    
    
    
    
    
    
    
    
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) external returns (bool success);

    
    
    
    
    
    
    
    
    function execTransactionFromModuleReturnData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) external returns (bool success, bytes memory returnData);

    
    
    function isModuleEnabled(address module) external view returns (bool);

    
    
    
    
    
    function getModulesPaginated(address start, uint256 pageSize)
        external
        view
        returns (address[] memory array, address next);
}

// 
pragma solidity >=0.7.0 <0.9.0;



contract Enum {
    enum Operation {Call, DelegateCall}
}

// 
pragma solidity >=0.7.0 <0.9.0;





abstract contract BaseGuard is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceId == type(IGuard).interfaceId || // 0xe6d7a83a
            interfaceId == type(IERC165).interfaceId; // 0x01ffc9a7
    }

    /// Module transactions only use the first four parameters: to, value, data, and operation.
    /// Module.sol hardcodes the remaining parameters as 0 since they are not used for module transactions.
    /// This interface is used to maintain compatibilty with Gnosis Safe transaction guards.
    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external virtual;

    function checkAfterExecution(bytes32 txHash, bool success) external virtual;
}

// 
pragma solidity >=0.7.0 <0.9.0;



interface IGuard {
    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external;

    function checkAfterExecution(bytes32 txHash, bool success) external;
}
