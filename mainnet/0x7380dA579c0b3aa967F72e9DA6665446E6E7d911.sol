// SPDX-License-Identifier: MIT OR Apache-2.0


pragma solidity ^0.7.0;

// 






contract Config {
    
    uint256 constant WITHDRAWAL_GAS_LIMIT = 100000;

    
    uint8 constant CHUNK_BYTES = 9;

    
    uint8 constant ADDRESS_BYTES = 20;

    uint8 constant PUBKEY_HASH_BYTES = 20;

    
    uint8 constant PUBKEY_BYTES = 32;

    
    uint8 constant ETH_SIGN_RS_BYTES = 32;

    
    uint8 constant SUCCESS_FLAG_BYTES = 1;

    
    uint16 constant MAX_AMOUNT_OF_REGISTERED_TOKENS = 511;

    
    uint32 internal constant MAX_ACCOUNT_ID = 16777215;

    
    uint128 internal constant MAX_DEPOSIT_AMOUNT = 20282409603651670423947251286015;

    
    uint128 internal constant MAX_ERC20_TOKEN_BALANCE = (2**126) - 1;

    
    uint256 constant BLOCK_PERIOD = 15 seconds;

    
    
    
    uint256 constant EXPECT_VERIFICATION_IN = 0 hours / BLOCK_PERIOD;

    uint256 constant NOOP_BYTES = 1 * CHUNK_BYTES;
    uint256 constant DEPOSIT_BYTES = 6 * CHUNK_BYTES;
    uint256 constant TRANSFER_TO_NEW_BYTES = 6 * CHUNK_BYTES;
    uint256 constant WITHDRAW_BYTES = 6 * CHUNK_BYTES;
    uint256 constant TRANSFER_BYTES = 2 * CHUNK_BYTES;
    uint256 constant FORCED_EXIT_BYTES = 6 * CHUNK_BYTES;
    // NEW ADD
    uint256 constant CREATE_PAIR_BYTES = 4 * CHUNK_BYTES;

    
    uint256 constant FULL_EXIT_BYTES = 6 * CHUNK_BYTES;

    
    uint256 constant CHANGE_PUBKEY_BYTES = 6 * CHUNK_BYTES;

    
    
    
    uint256 constant PRIORITY_EXPIRATION_PERIOD = 14 days;

    
    uint256 constant PRIORITY_EXPIRATION = PRIORITY_EXPIRATION_PERIOD / BLOCK_PERIOD;

    
    
    
    uint64 constant MAX_PRIORITY_REQUESTS_TO_DELETE_IN_VERIFY = 6;

    
    uint256 constant MASS_FULL_EXIT_PERIOD = 9 days;

    
    uint256 constant TIME_TO_WITHDRAW_FUNDS_FROM_FULL_EXIT = 2 days;

    
    
    uint256 constant UPGRADE_NOTICE_PERIOD = 0 days;

    
    uint256 constant COMMIT_TIMESTAMP_NOT_OLDER = 168 hours;

    
    
    uint256 constant COMMIT_TIMESTAMP_APPROXIMATION_DELTA = 15 minutes;

    
    uint256 constant INPUT_MASK = (~uint256(0) >> 3);
}pragma solidity ^0.7.0;

// 









contract Governance is Config {
    
    event NewToken(address indexed token, uint16 indexed tokenId);

    
    event NewGovernor(address newGovernor);

    
    event ValidatorStatusUpdate(address indexed validatorAddress, bool isActive);

    event TokenPausedUpdate(address indexed token, bool paused);

    
    address public networkGovernor;

    
    uint16 public totalTokens;

    
    mapping(uint16 => address) public tokenAddresses;

    
    mapping(address => uint16) public tokenIds;

    
    mapping(address => bool) public validators;

    
    mapping(uint16 => bool) public pausedTokens;

    
    
    ///     _networkGovernor The address of network governor
    function initialize(bytes calldata initializationParameters) external {
        address _networkGovernor = abi.decode(initializationParameters, (address));

        networkGovernor = _networkGovernor;
    }

    
    
    function upgrade(bytes calldata upgradeParameters) external {}

    
    
    function changeGovernor(address _newGovernor) external {
        requireGovernor(msg.sender);
        if (networkGovernor != _newGovernor) {
            networkGovernor = _newGovernor;
            emit NewGovernor(_newGovernor);
        }
    }

    
    
    function addToken(address _token) external {
        requireGovernor(msg.sender);
        require(_token != address(0), "1e0");
        require(tokenIds[_token] == 0, "1e"); // token exists
        require(totalTokens < MAX_AMOUNT_OF_REGISTERED_TOKENS, "1f"); // no free identifiers for tokens

        totalTokens++;
        uint16 newTokenId = totalTokens; // it is not `totalTokens - 1` because tokenId = 0 is reserved for eth

        // tokenId -> token
        tokenAddresses[newTokenId] = _token;
        // token -> tokenId
        tokenIds[_token] = newTokenId;
        emit NewToken(_token, newTokenId);
    }

    
    
    
    function setTokenPaused(address _tokenAddr, bool _tokenPaused) external {
        requireGovernor(msg.sender);

        uint16 tokenId = this.validateTokenAddress(_tokenAddr);
        if (pausedTokens[tokenId] != _tokenPaused) {
            pausedTokens[tokenId] = _tokenPaused;
            emit TokenPausedUpdate(_tokenAddr, _tokenPaused);
        }
    }

    
    
    
    function setValidator(address _validator, bool _active) external {
        requireGovernor(msg.sender);
        if (validators[_validator] != _active) {
            validators[_validator] = _active;
            emit ValidatorStatusUpdate(_validator, _active);
        }
    }

    
    
    function requireGovernor(address _address) public view {
        require(_address == networkGovernor, "1g"); // only by governor
    }

    
    
    function requireActiveValidator(address _address) external view {
        require(validators[_address], "1h"); // validator is not active
    }

    
    
    
    function isValidTokenId(uint16 _tokenId) external view returns (bool) {
        return _tokenId <= totalTokens;
    }

    
    
    
    function validateTokenAddress(address _tokenAddr) external view returns (uint16) {
        uint16 tokenId = tokenIds[_tokenAddr];
        require(tokenId != 0, "1i"); // 0 is not a valid token
        return tokenId;
    }
}
