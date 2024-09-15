

pragma solidity ^0.5.0;





contract Config {

    
    uint256 constant ERC20_WITHDRAWAL_GAS_LIMIT = 350000;

    
    uint256 constant ERC721_WITHDRAWAL_GAS_LIMIT = 350000;

    
    uint256 constant ETH_WITHDRAWAL_GAS_LIMIT = 10000;

    
    uint8 constant CHUNK_BYTES = 11;

    
    uint8 constant ADDRESS_BYTES = 20;

    uint8 constant PUBKEY_HASH_BYTES = 20;

    
    uint8 constant PUBKEY_BYTES = 32;

    
    uint8 constant ETH_SIGN_RS_BYTES = 32;

    
    uint8 constant SUCCESS_FLAG_BYTES = 1;

    
    uint16 constant MAX_AMOUNT_OF_REGISTERED_FEE_TOKENS = 32 - 1;

    
    uint16 constant USER_TOKENS_START_ID = 32;

    
    uint16 constant MAX_AMOUNT_OF_REGISTERED_USER_TOKENS = 16352;

    
    uint16 constant MAX_AMOUNT_OF_REGISTERED_TOKENS = 16384 - 1;

    
    uint32 constant MAX_ACCOUNT_ID = (2 ** 27) - 1;

    
    uint64 constant MAX_NFT_ID = 2**(27+16);

    
    uint256 constant BLOCK_PERIOD = 15 seconds;

    
    /// Blocks can be reverted if they are not verified for at least EXPECT_VERIFICATION_IN.
    /// If set to 0 validator can revert blocks at any time.
    uint256 constant EXPECT_VERIFICATION_IN = 0 hours / BLOCK_PERIOD;

    uint256 constant NOOP_BYTES = 1 * CHUNK_BYTES;
    uint256 constant CREATE_PAIR_BYTES = 3 * CHUNK_BYTES;
    uint256 constant DEPOSIT_BYTES = 4 * CHUNK_BYTES;
    uint256 constant TRANSFER_TO_NEW_BYTES = 4 * CHUNK_BYTES;
    uint256 constant PARTIAL_EXIT_BYTES = 5 * CHUNK_BYTES;
    uint256 constant TRANSFER_BYTES = 2 * CHUNK_BYTES;
    uint256 constant UNISWAP_ADD_LIQ_BYTES = 3 * CHUNK_BYTES;
    uint256 constant UNISWAP_RM_LIQ_BYTES = 3 * CHUNK_BYTES;
    uint256 constant UNISWAP_SWAP_BYTES = 2 * CHUNK_BYTES;
    uint256 constant DEPOSIT_NFT_BYTES = 7 * CHUNK_BYTES;
    uint256 constant MINT_NFT_BYTES = 5 * CHUNK_BYTES;
    uint256 constant TRANSFER_NFT_BYTES = 3 * CHUNK_BYTES;
    uint256 constant TRANSFER_TO_NEW_NFT_BYTES = 4 * CHUNK_BYTES;
    uint256 constant PARTIAL_EXIT_NFT_BYTES = 7 * CHUNK_BYTES;
    uint256 constant FULL_EXIT_NFT_BYTES = 7 * CHUNK_BYTES;
    uint256 constant APPROVE_NFT_BYTES = 3 * CHUNK_BYTES;
    uint256 constant EXCHANGE_NFT = 4 * CHUNK_BYTES;

    
    uint256 constant FULL_EXIT_BYTES = 4 * CHUNK_BYTES;

    
    uint256 constant ONCHAIN_WITHDRAWAL_BYTES = 40;


    
    /// (uint8 isNFTWithdraw uint8 addToPendingWithdrawalsQueue, uint64 globalId, uint32 creator,
    //  uint32 seqId, address _toAddr, uint8 isValid)
    uint256 constant ONCHAIN_WITHDRAWAL_NFT_BYTES = 71;


    
    uint256 constant CHANGE_PUBKEY_BYTES = 5 * CHUNK_BYTES;

    
    /// NOTE: Priority expiration should be > (EXPECT_VERIFICATION_IN * BLOCK_PERIOD), otherwise incorrect block with priority op could not be reverted.
    uint256 constant PRIORITY_EXPIRATION_PERIOD = 3 days;

    
    uint256 constant PRIORITY_EXPIRATION = PRIORITY_EXPIRATION_PERIOD / BLOCK_PERIOD;

    
    
    
    uint64 constant MAX_PRIORITY_REQUESTS_TO_DELETE_IN_VERIFY = 6;

    
    uint constant MASS_FULL_EXIT_PERIOD = 3 days;

    
    uint constant TIME_TO_WITHDRAW_FUNDS_FROM_FULL_EXIT = 2 days;

    
    // NOTE: we must reserve for users enough time to send full exit operation, wait maximum time for processing this operation and withdraw funds from it.
    uint constant UPGRADE_NOTICE_PERIOD = MASS_FULL_EXIT_PERIOD + PRIORITY_EXPIRATION_PERIOD + TIME_TO_WITHDRAW_FUNDS_FROM_FULL_EXIT;

    // @notice Default amount limit for each ERC20 deposit
    uint128 constant DEFAULT_MAX_DEPOSIT_AMOUNT = 2 ** 85;
}pragma solidity ^0.5.0;







contract Governance is Config {

    
    event NewToken(
        address indexed token,
        uint16 indexed tokenId
    );

    
    event NewGovernor(
        address newGovernor
    );

    
    event NewTokenLister(
        address newTokenLister
    );

    
    event ValidatorStatusUpdate(
        address indexed validatorAddress,
        bool isActive
    );

    
    address public networkGovernor;

    
    uint16 public totalFeeTokens;

    
    uint16 public totalUserTokens;

    
    mapping(uint16 => address) public tokenAddresses;

    
    mapping(address => uint16) public tokenIds;

    
    mapping(address => bool) public validators;

    address public tokenLister;

    constructor() public {
        networkGovernor = msg.sender;
    }

    
    
    ///     _networkGovernor The address of network governor
    function initialize(bytes calldata initializationParameters) external {
        require(networkGovernor == address(0), "init0");
        (address _networkGovernor, address _tokenLister) = abi.decode(initializationParameters, (address, address));

        networkGovernor = _networkGovernor;
        tokenLister = _tokenLister;
    }

    
    
    function upgrade(bytes calldata upgradeParameters) external {}

    
    
    function changeGovernor(address _newGovernor) external {
        requireGovernor(msg.sender);
        require(_newGovernor != address(0), "zero address is passed as _newGovernor");
        if (networkGovernor != _newGovernor) {
            networkGovernor = _newGovernor;
            emit NewGovernor(_newGovernor);
        }
    }

    
    
    function changeTokenLister(address _newTokenLister) external {
        requireGovernor(msg.sender);
        require(_newTokenLister != address(0), "zero address is passed as _newTokenLister");
        if (tokenLister != _newTokenLister) {
            tokenLister = _newTokenLister;
            emit NewTokenLister(_newTokenLister);
        }
    }

    
    
    function addFeeToken(address _token) external {
        requireGovernor(msg.sender);
        require(tokenIds[_token] == 0, "gan11"); // token exists
        require(totalFeeTokens < MAX_AMOUNT_OF_REGISTERED_FEE_TOKENS, "fee12"); // no free identifiers for tokens
	require(
            _token != address(0), "address cannot be zero"
        );

        totalFeeTokens++;
        uint16 newTokenId = totalFeeTokens; // it is not `totalTokens - 1` because tokenId = 0 is reserved for eth

        tokenAddresses[newTokenId] = _token;
        tokenIds[_token] = newTokenId;
        emit NewToken(_token, newTokenId);
    }

    
    
    function addToken(address _token) external {
        requireTokenLister(msg.sender);
        require(tokenIds[_token] == 0, "gan11"); // token exists
        require(totalUserTokens < MAX_AMOUNT_OF_REGISTERED_USER_TOKENS, "gan12"); // no free identifiers for tokens
        require(
            _token != address(0), "address cannot be zero"
        );

        uint16 newTokenId = USER_TOKENS_START_ID + totalUserTokens;
        totalUserTokens++;

        tokenAddresses[newTokenId] = _token;
        tokenIds[_token] = newTokenId;
        emit NewToken(_token, newTokenId);
    }

    
    
    
    function setValidator(address _validator, bool _active) external {
        requireGovernor(msg.sender);
        if (validators[_validator] != _active) {
            validators[_validator] = _active;
            emit ValidatorStatusUpdate(_validator, _active);
        }
    }

    
    
    function requireGovernor(address _address) public view {
        require(_address == networkGovernor, "grr11"); // only by governor
    }

    
    
    function requireTokenLister(address _address) public view {
        require(_address == networkGovernor || _address == tokenLister, "grr11"); // token lister or governor
    }

    
    
    function requireActiveValidator(address _address) external view {
        require(validators[_address], "grr21"); // validator is not active
    }

    
    
    
    function isValidTokenId(uint16 _tokenId) external view returns (bool) {
        return (_tokenId <= totalFeeTokens) || (_tokenId >= USER_TOKENS_START_ID && _tokenId < (USER_TOKENS_START_ID + totalUserTokens  ));
    }

    
    
    
    function validateTokenAddress(address _tokenAddr) external view returns (uint16) {
        uint16 tokenId = tokenIds[_tokenAddr];
        require(tokenId != 0, "gvs11"); // 0 is not a valid token
	require(tokenId <= MAX_AMOUNT_OF_REGISTERED_TOKENS, "gvs12");
        return tokenId;
    }

    function getTokenAddress(uint16 _tokenId) external view returns (address) {
        address tokenAddr = tokenAddresses[_tokenId];
        return tokenAddr;
    }
}
