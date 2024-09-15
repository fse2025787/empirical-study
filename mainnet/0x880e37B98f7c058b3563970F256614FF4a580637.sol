// SPDX-License-Identifier: LGPL-3.0-only

// 
pragma solidity >=0.8.0;



contract Enum {
    enum Operation {
        Call, DelegateCall
    }
}

interface Executor {
    
    
    
    
    
    function execTransactionFromModule(address to, uint256 value, bytes calldata data, Enum.Operation operation)
        external
        returns (bool success);
}

contract DaoModule {

    bytes32 public constant INVALIDATED = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    bytes32 public constant DOMAIN_SEPARATOR_TYPEHASH = 0x47e79534a245952e8b16893a336b85a3d9ea9fa8c573f3d803afb92a79469218;
    // keccak256(
    //     "EIP712Domain(uint256 chainId,address verifyingContract)"
    // );

    bytes32 public constant TRANSACTION_TYPEHASH = 0x72e9670a7ee00f5fbf1049b8c38e3f22fab7e9b85029e85cf9412f17fdd5c2ad;
    // keccak256(
    //     "Transaction(address to,uint256 value,bytes data,uint8 operation,uint256 nonce)"
    // );

    event ProposalQuestionCreated(
        bytes32 indexed questionId,
        string indexed proposalId
    );

    Executor public immutable executor;
    Realitio public immutable oracle;
    uint256 public template;
    uint32 public questionTimeout;
    uint32 public questionCooldown;
    uint32 public answerExpiration;
    address public questionArbitrator;
    uint256 public minimumBond;
    // Mapping of question hash to question id. Special case: INVALIDATED for question hashes that have been invalidated
    mapping(bytes32 => bytes32) public questionIds;
    // Mapping of questionHash to transactionHash to execution state
    mapping(bytes32 => mapping(bytes32 => bool)) public executedProposalTransactions;

    
    
    
    
    
    
    
    
    constructor(Executor _executor, Realitio _oracle, uint32 timeout, uint32 cooldown, uint32 expiration, uint256 bond, uint256 templateId) {
        require(timeout > 0, "Timeout has to be greater 0");
        require(expiration == 0 || expiration - cooldown >= 60 , "There need to be at least 60s between end of cooldown and expiration");
        executor = _executor;
        oracle = _oracle;
        answerExpiration = expiration;
        questionTimeout = timeout;
        questionCooldown = cooldown;
        questionArbitrator = address(_executor);
        minimumBond = bond;
        template = templateId;
    }

    modifier executorOnly() {
        require(msg.sender == address(executor), "Not authorized");
        _;
    }

    
    function setQuestionTimeout(uint32 timeout)
        public
        executorOnly()
    {
        require(timeout > 0, "Timeout has to be greater 0");
        questionTimeout = timeout;
    }

    
    
    
    
    function setQuestionCooldown(uint32 cooldown)
        public
        executorOnly()
    {
        uint32 expiration = answerExpiration;
        require(expiration == 0 || expiration - cooldown >= 60 , "There need to be at least 60s between end of cooldown and expiration");
        questionCooldown = cooldown;
    }

    
    
    
    
    
    function setAnswerExpiration(uint32 expiration)
        public
        executorOnly()
    {
        require(expiration == 0 || expiration - questionCooldown >= 60 , "There need to be at least 60s between end of cooldown and expiration");
        answerExpiration = expiration;
    }

    
    
    
    function setArbitrator(address arbitrator)
        public
        executorOnly()
    {
        questionArbitrator = arbitrator;
    }

    
    
    
    function setMinimumBond(uint256 bond)
        public
        executorOnly()
    {
        minimumBond = bond;
    }

    
    
    
    
    function setTemplate(uint256 templateId)
        public
        executorOnly()
    {
        template = templateId;
    }

    
    
    
    
    function addProposal(string memory proposalId, bytes32[] memory txHashes) public {
        addProposalWithNonce(proposalId, txHashes, 0);
    }

    
    
    
    
    function addProposalWithNonce(string memory proposalId, bytes32[] memory txHashes, uint256 nonce) public {
        // We load some storage variables into memory to save gas
        uint256 templateId = template;
        uint32 timeout = questionTimeout;
        address arbitrator = questionArbitrator;
        // We generate the question string used for the oracle
        string memory question = buildQuestion(proposalId, txHashes);
        bytes32 questionHash = keccak256(bytes(question));
        if (nonce > 0) {
            // Previous nonce must have been invalidated by the oracle.
            // However, if the proposal was internally invalidated, it should not be possible to ask it again.
            bytes32 currentQuestionId = questionIds[questionHash];
            require(currentQuestionId != INVALIDATED, "This proposal has been marked as invalid");
            require(oracle.resultFor(currentQuestionId) == INVALIDATED, "Previous proposal was not invalidated");
        } else {
            require(questionIds[questionHash] == bytes32(0), "Proposal has already been submitted");
        }
        bytes32 expectedQuestionId = getQuestionId(
            templateId, question, arbitrator, timeout, 0, nonce
        );
        // Set the question hash for this quesion id
        questionIds[questionHash] = expectedQuestionId;
        // Ask the question with a starting time of 0, so that it can be immediately answered
        bytes32 questionId = oracle.askQuestion(templateId, question, arbitrator, timeout, 0, nonce);
        require(expectedQuestionId == questionId, "Unexpected question id");
        emit ProposalQuestionCreated(questionId, proposalId);
    }

    
    
    
    
    function markProposalAsInvalid(string memory proposalId, bytes32[] memory txHashes)
        public
        // Executor only is checked in markProposalAsInvalidByHash(bytes32)
    {
        string memory question = buildQuestion(proposalId, txHashes);
        bytes32 questionHash = keccak256(bytes(question));
        markProposalAsInvalidByHash(questionHash);
    }

    
    
    
    function markProposalAsInvalidByHash(bytes32 questionHash)
        public
        executorOnly()
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
        require(questionId != bytes32(0), "No question id set for provided proposal");
        require(oracle.resultFor(questionId) == bytes32(uint256(1)), "Only positive answers can expire");
        uint32 finalizeTs = oracle.getFinalizeTS(questionId);
        require(finalizeTs + uint256(expirationDuration) < block.timestamp, "Answer has not expired yet");
        questionIds[questionHash] = INVALIDATED;
    }

    
    
    
    
    
    
    
    
    function executeProposal(string memory proposalId, bytes32[] memory txHashes, address to, uint256 value, bytes memory data, Enum.Operation operation) public {
        executeProposalWithIndex(proposalId, txHashes, to, value, data, operation, 0);
    }

    
    
    
    
    
    
    
    
    function executeProposalWithIndex(string memory proposalId, bytes32[] memory txHashes, address to, uint256 value, bytes memory data, Enum.Operation operation, uint256 txIndex) public {
        // We use the hash of the question to check the execution state, as the other parameters might change, but the question not
        bytes32 questionHash = keccak256(bytes(buildQuestion(proposalId, txHashes)));
        // Lookup question id for this proposal
        bytes32 questionId = questionIds[questionHash];
        // Question hash needs to set to be eligible for execution
        require(questionId != bytes32(0), "No question id set for provided proposal");
        require(questionId != INVALIDATED, "Proposal has been invalidated");

        bytes32 txHash = getTransactionHash(to, value, data, operation, txIndex);
        require(txHashes[txIndex] == txHash, "Unexpected transaction hash");

        // Check that the result of the question is 1 (true)
        require(oracle.resultFor(questionId) == bytes32(uint256(1)), "Transaction was not approved");
        uint256 minBond = minimumBond;
        require(minBond == 0 || minBond <= oracle.getBond(questionId), "Bond on question not high enough");
        uint32 finalizeTs = oracle.getFinalizeTS(questionId);
        // The answer is valid in the time after the cooldown and before the expiration time (if set).
        require(finalizeTs + uint256(questionCooldown) < block.timestamp, "Wait for additional cooldown");
        uint32 expiration = answerExpiration;
        require(expiration == 0 || finalizeTs + uint256(expiration) >= block.timestamp, "Answer has expired");
        // Check this is either the first transaction in the list or that the previous question was already approved
        require(txIndex == 0 || executedProposalTransactions[questionHash][txHashes[txIndex - 1]], "Previous transaction not executed yet");
        // Check that this question was not executed yet
        require(!executedProposalTransactions[questionHash][txHash], "Cannot execute transaction again");
        // Mark transaction as executed
        executedProposalTransactions[questionHash][txHash] = true;
        // Execute the transaction via the executor.
        require(executor.execTransactionFromModule(to, value, data, operation), "Module transaction failed");
    }

    
    
    
    function buildQuestion(string memory proposalId, bytes32[] memory txHashes) public pure returns(string memory) {
        string memory txsHash = bytes32ToAsciiString(keccak256(abi.encodePacked(txHashes)));
        return string(abi.encodePacked(proposalId, bytes3(0xe2909f), txsHash));
    }

    
    
    function getQuestionId(uint256 templateId, string memory question, address arbitrator, uint32 timeout, uint32 openingTs, uint256 nonce) public view returns(bytes32) {
        bytes32 contentHash = keccak256(abi.encodePacked(templateId, openingTs, question));
        return keccak256(abi.encodePacked(contentHash, arbitrator, timeout, this, nonce));
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
    ) public view returns(bytes memory) {
        uint256 chainId = getChainId();
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_SEPARATOR_TYPEHASH, chainId, this));
        bytes32 transactionHash = keccak256(
            abi.encode(TRANSACTION_TYPEHASH, to, value, keccak256(data), operation, nonce)
        );
        return abi.encodePacked(bytes1(0x19), bytes1(0x01), domainSeparator, transactionHash);
    }

    function getTransactionHash(address to, uint256 value, bytes memory data, Enum.Operation operation, uint256 nonce) public view returns(bytes32) {
        return keccak256(generateTransactionHashData(to, value, data, operation, nonce));
    }

    function bytes32ToAsciiString(bytes32 _bytes) internal pure returns (string memory) {
        bytes memory s = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            uint8 b = uint8(bytes1(_bytes << i * 8));
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

interface Realitio {

    // mapping(bytes32 => Question) public questions;

    
    
    
    
    
    
    
    
    
    
    
    function askQuestion(
        uint256 template_id, string calldata question, address arbitrator, uint32 timeout, uint32 opening_ts, uint256 nonce
    ) external returns (bytes32);

    
    
    
    function isFinalized(bytes32 question_id) view external returns (bool);

    
    
    
    function resultFor(bytes32 question_id) external view returns (bytes32);

    
    
    function getFinalizeTS(bytes32 question_id) external view returns (uint32);

    
    
    function isPendingArbitration(bytes32 question_id) external view returns (bool);

    
    /// Placeholders should use gettext() syntax, eg %s.
    
    
    
    function createTemplate(string calldata content) external returns (uint256);

    
    
    function getBond(bytes32 question_id) external view returns (uint256);

    
    
    function getContentHash(bytes32 question_id) external view returns (bytes32);
}

