

pragma solidity ^0.5.0;





contract Config {

    
    uint256 constant ERC20_WITHDRAWAL_GAS_LIMIT = 250000;

    
    uint256 constant ETH_WITHDRAWAL_GAS_LIMIT = 10000;

    
    uint8 constant CHUNK_BYTES = 9;

    
    uint8 constant ADDRESS_BYTES = 20;

    uint8 constant PUBKEY_HASH_BYTES = 20;

    
    uint8 constant PUBKEY_BYTES = 32;

    
    uint8 constant ETH_SIGN_RS_BYTES = 32;

    
    uint8 constant SUCCESS_FLAG_BYTES = 1;

    
    uint16 constant MAX_AMOUNT_OF_REGISTERED_TOKENS = 128 - 1;

    
    uint32 constant MAX_ACCOUNT_ID = (2 ** 24) - 1;

    
    uint256 constant BLOCK_PERIOD = 15 seconds;

    
    /// Blocks can be reverted if they are not verified for at least EXPECT_VERIFICATION_IN.
    /// If set to 0 validator can revert blocks at any time.
    uint256 constant EXPECT_VERIFICATION_IN = 0 hours / BLOCK_PERIOD;

    uint256 constant NOOP_BYTES = 1 * CHUNK_BYTES;
    uint256 constant CREATE_PAIR_BYTES = 4 * CHUNK_BYTES;
    uint256 constant DEPOSIT_BYTES = 6 * CHUNK_BYTES;
    uint256 constant TRANSFER_TO_NEW_BYTES = 6 * CHUNK_BYTES;
    uint256 constant PARTIAL_EXIT_BYTES = 6 * CHUNK_BYTES;
    uint256 constant TRANSFER_BYTES = 2 * CHUNK_BYTES;
    uint256 constant UNISWAP_ADD_RM_LIQ_BYTES = 6 * CHUNK_BYTES;
    uint256 constant UNISWAP_SWAP_BYTES = 4 * CHUNK_BYTES;

    
    uint256 constant FULL_EXIT_BYTES = 6 * CHUNK_BYTES;

    
    uint256 constant ONCHAIN_WITHDRAWAL_BYTES = 1 + 20 + 2 + 16; // (uint8 addToPendingWithdrawalsQueue, address _to, uint16 _tokenId, uint128 _amount)

    
    uint256 constant CHANGE_PUBKEY_BYTES = 6 * CHUNK_BYTES;

    
    /// NOTE: Priority expiration should be > (EXPECT_VERIFICATION_IN * BLOCK_PERIOD), otherwise incorrect block with priority op could not be reverted.
    uint256 constant PRIORITY_EXPIRATION_PERIOD = 3 days;

    
    uint256 constant PRIORITY_EXPIRATION = PRIORITY_EXPIRATION_PERIOD / BLOCK_PERIOD;

    
    
    
    uint64 constant MAX_PRIORITY_REQUESTS_TO_DELETE_IN_VERIFY = 6;

    
    uint constant MASS_FULL_EXIT_PERIOD = 3 days;

    
    uint constant TIME_TO_WITHDRAW_FUNDS_FROM_FULL_EXIT = 2 days;

    
    // NOTE: we must reserve for users enough time to send full exit operation, wait maximum time for processing this operation and withdraw funds from it.
    uint constant UPGRADE_NOTICE_PERIOD = MASS_FULL_EXIT_PERIOD + PRIORITY_EXPIRATION_PERIOD + TIME_TO_WITHDRAW_FUNDS_FROM_FULL_EXIT;

}
pragma solidity ^0.5.0;







contract Governance is Config {

    
    event NewToken(
        address indexed token,
        uint16 indexed tokenId
    );

    
    event NewGovernor(
        address newGovernor
    );

    
    event ValidatorStatusUpdate(
        address indexed validatorAddress,
        bool isActive
    );

    
    address public networkGovernor;

    
    uint16 public totalTokens;

    
    mapping(uint16 => address) public tokenAddresses;

    
    mapping(address => uint16) public tokenIds;

    
    mapping(address => bool) public validators;

    constructor() public {}

    
    
    ///     _networkGovernor The address of network governor
    function initialize(bytes calldata initializationParameters) external {
        address _networkGovernor = abi.decode(initializationParameters, (address));

        networkGovernor = _networkGovernor;
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

    
    
    function addToken(address _token) external {
        requireGovernor(msg.sender);
        require(tokenIds[_token] == 0, "gan11"); // token exists
        require(totalTokens < MAX_AMOUNT_OF_REGISTERED_TOKENS, "gan12"); // no free identifiers for tokens
        require(
            _token != address(0), "address cannot be zero"
        );

        totalTokens++;
        uint16 newTokenId = totalTokens; // it is not `totalTokens - 1` because tokenId = 0 is reserved for eth

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

    
    
    function requireActiveValidator(address _address) external view {
        require(validators[_address], "grr21"); // validator is not active
    }

    
    
    
    function isValidTokenId(uint16 _tokenId) external view returns (bool) {
        return _tokenId <= totalTokens;
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
