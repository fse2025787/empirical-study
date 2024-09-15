// SPDX-License-Identifier: Apache-2.0
pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2021-03-22
*/

// 
pragma solidity ^0.7.0;

// File: contracts/lib/EIP712.sol

// Copyright 2017 Loopring Technology Limited.


library EIP712
{
    struct Domain {
        string  name;
        string  version;
        address verifyingContract;
    }

    bytes32 constant internal EIP712_DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    string constant internal EIP191_HEADER = "\x19\x01";

    function hash(Domain memory domain)
        internal
        pure
        returns (bytes32)
    {
        uint _chainid;
        assembly { _chainid := chainid() }

        return keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(domain.name)),
                keccak256(bytes(domain.version)),
                _chainid,
                domain.verifyingContract
            )
        );
    }

    function hashPacked(
        bytes32 domainHash,
        bytes32 dataHash
        )
        internal
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encodePacked(
                EIP191_HEADER,
                domainHash,
                dataHash
            )
        );
    }
}

// File: contracts/core/iface/IAgentRegistry.sol

// Copyright 2017 Loopring Technology Limited.

interface IAgent{}

abstract contract IAgentRegistry
{
    
    
    
    
    function isAgent(
        address owner,
        address agent
        )
        external
        virtual
        view
        returns (bool);

    
    
    
    
    function isAgent(
        address[] calldata owners,
        address            agent
        )
        external
        virtual
        view
        returns (bool);

    
    
    
    function isUniversalAgent(address agent)
        public
        virtual
        view
        returns (bool);
}

// File: contracts/lib/Ownable.sol

// Copyright 2017 Loopring Technology Limited.





///      authorization control functions, this simplifies the implementation of
///      "user permissions".
contract Ownable
{
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    
    ///      to the sender.
    constructor()
    {
        owner = msg.sender;
    }

    
    modifier onlyOwner()
    {
        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }

    
    ///      new owner.
    
    function transferOwnership(
        address newOwner
        )
        public
        virtual
        onlyOwner
    {
        require(newOwner != address(0), "ZERO_ADDRESS");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership()
        public
        onlyOwner
    {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}

// File: contracts/lib/Claimable.sol

// Copyright 2017 Loopring Technology Limited.






///      to be claimed. This allows the new owner to accept the transfer.
contract Claimable is Ownable
{
    address public pendingOwner;

    
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner, "UNAUTHORIZED");
        _;
    }

    
    
    function transferOwnership(
        address newOwner
        )
        public
        override
        onlyOwner
    {
        require(newOwner != address(0) && newOwner != owner, "INVALID_ADDRESS");
        pendingOwner = newOwner;
    }

    
    function claimOwnership()
        public
        onlyPendingOwner
    {
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}

// File: contracts/core/iface/IBlockVerifier.sol

// Copyright 2017 Loopring Technology Limited.





abstract contract IBlockVerifier is Claimable
{
    // -- Events --

    event CircuitRegistered(
        uint8  indexed blockType,
        uint16         blockSize,
        uint8          blockVersion
    );

    event CircuitDisabled(
        uint8  indexed blockType,
        uint16         blockSize,
        uint8          blockVersion
    );

    // -- Public functions --

    
    ///      Every block permutation needs its own circuit and thus its own set of
    ///      verification keys. Only a limited number of block sizes per block
    ///      type are supported.
    
    
    
    
    function registerCircuit(
        uint8    blockType,
        uint16   blockSize,
        uint8    blockVersion,
        uint[18] calldata vk
        )
        external
        virtual;

    
    
    
    
    function disableCircuit(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion
        )
        external
        virtual;

    
    ///      Verifying a block makes sure all requests handled in the block
    ///      are correctly handled by the operator.
    
    
    
    
    
    
    function verifyProofs(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion,
        uint[] calldata publicInputs,
        uint[] calldata proofs
        )
        external
        virtual
        view
        returns (bool);

    
    
    
    
    
    function isCircuitRegistered(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion
        )
        external
        virtual
        view
        returns (bool);

    
    
    
    
    
    function isCircuitEnabled(
        uint8  blockType,
        uint16 blockSize,
        uint8  blockVersion
        )
        external
        virtual
        view
        returns (bool);
}

// File: contracts/core/iface/IDepositContract.sol

// Copyright 2017 Loopring Technology Limited.




///
///        ERC1155 tokens can be supported by registering pseudo token addresses calculated
///        as `address(keccak256(real_token_address, token_params))`. Then the custom
///        deposit contract can look up the real token address and paramsters with the
///        pseudo token address before doing the transfers.

interface IDepositContract
{
    
    function isTokenSupported(address token)
        external
        view
        returns (bool);

    
    ///      be called when a user deposits funds to the exchange.
    ///      In a simple implementation the funds are simply stored inside the
    ///      deposit contract directly. More advanced implementations may store the funds
    ///      in some DeFi application to earn interest, so this function could directly
    ///      call the necessary functions to store the funds there.
    ///
    ///      This function needs to throw when an error occurred!
    ///
    ///      This function can only be called by the exchange.
    ///
    
    
    
    
    
    function deposit(
        address from,
        address token,
        uint96  amount,
        bytes   calldata extraData
        )
        external
        payable
        returns (uint96 amountReceived);

    
    ///      be called when a withdrawal is done for a user on the exchange.
    ///      In the simplest implementation the funds are simply stored inside the
    ///      deposit contract directly so this simply transfers the requested tokens back
    ///      to the user. More advanced implementations may store the funds
    ///      in some DeFi application to earn interest so the function would
    ///      need to get those tokens back from the DeFi application first before they
    ///      can be transferred to the user.
    ///
    ///      This function needs to throw when an error occurred!
    ///
    ///      This function can only be called by the exchange.
    ///
    
    
    
    
    
    function withdraw(
        address from,
        address to,
        address token,
        uint    amount,
        bytes   calldata extraData
        )
        external
        payable;

    
    ///      for the exchange. This way the approval can be used for all functionality (and
    ///      extended functionality) of the exchange.
    ///      Should NOT be used to deposit/withdraw user funds, `deposit`/`withdraw`
    ///      should be used for that as they will contain specialised logic for those operations.
    ///      This function can be called by the exchange to transfer onchain funds of users
    ///      necessary for Agent functionality.
    ///
    ///      This function needs to throw when an error occurred!
    ///
    ///      This function can only be called by the exchange.
    ///
    
    
    
    
    function transfer(
        address from,
        address to,
        address token,
        uint    amount
        )
        external
        payable;

    
    ///      Is used while depositing to send the correct ETH amount to the deposit contract.
    ///
    ///      Note that 0x0 is always registered for deposting ETH when the exchange is created!
    ///      This function allows additional addresses to be used for depositing ETH, the deposit
    ///      contract can implement different behaviour based on the address value.
    ///
    
    
    function isETH(address addr)
        external
        view
        returns (bool);
}

// File: contracts/core/iface/ILoopringV3.sol

// Copyright 2017 Loopring Technology Limited.






abstract contract ILoopringV3 is Claimable
{
    // == Events ==
    event ExchangeStakeDeposited(address exchangeAddr, uint amount);
    event ExchangeStakeWithdrawn(address exchangeAddr, uint amount);
    event ExchangeStakeBurned(address exchangeAddr, uint amount);
    event SettingsUpdated(uint time);

    // == Public Variables ==
    mapping (address => uint) internal exchangeStake;

    uint    public totalStake;
    address public blockVerifierAddress;
    uint    public forcedWithdrawalFee;
    uint    public tokenRegistrationFeeLRCBase;
    uint    public tokenRegistrationFeeLRCDelta;
    uint8   public protocolTakerFeeBips;
    uint8   public protocolMakerFeeBips;

    address payable public protocolFeeVault;

    // == Public Functions ==

    
    
    function lrcAddress()
        external
        view
        virtual
        returns (address);

    
    ///      This function can only be called by the owner of this contract.
    ///
    ///      Warning: these new values will be used by existing and
    ///      new Loopring exchanges.
    function updateSettings(
        address payable _protocolFeeVault,   // address(0) not allowed
        address _blockVerifierAddress,       // address(0) not allowed
        uint    _forcedWithdrawalFee
        )
        external
        virtual;

    
    ///      This function can only be called by the owner of this contract.
    ///
    ///      Warning: these new values will be used by existing and
    ///      new Loopring exchanges.
    function updateProtocolFeeSettings(
        uint8 _protocolTakerFeeBips,
        uint8 _protocolMakerFeeBips
        )
        external
        virtual;

    
    
    
    function getExchangeStake(
        address exchangeAddr
        )
        public
        virtual
        view
        returns (uint stakedLRC);

    
    ///      This function is meant to be called only from exchange contracts.
    
    ///         the staked amount, all staked LRC will be burned.
    function burnExchangeStake(
        uint amount
        )
        external
        virtual
        returns (uint burnedLRC);

    
    
    
    
    function depositExchangeStake(
        address exchangeAddr,
        uint    amountLRC
        )
        external
        virtual
        returns (uint stakedLRC);

    
    ///      This function is meant to be called only from within exchange contracts.
    
    
    
    function withdrawExchangeStake(
        address recipient,
        uint    requestedAmount
        )
        external
        virtual
        returns (uint amountLRC);

    
    
    
    function getProtocolFeeValues(
        )
        public
        virtual
        view
        returns (
            uint8 takerFeeBips,
            uint8 makerFeeBips
        );
}

// File: contracts/core/iface/ExchangeData.sol

// Copyright 2017 Loopring Technology Limited.








///      to deploy this library independently.


library ExchangeData
{
    // -- Enums --
    enum TransactionType
    {
        NOOP,
        DEPOSIT,
        WITHDRAWAL,
        TRANSFER,
        SPOT_TRADE,
        ACCOUNT_UPDATE,
        AMM_UPDATE,
        SIGNATURE_VERIFICATION
    }

    // -- Structs --
    struct Token
    {
        address token;
    }

    struct ProtocolFeeData
    {
        uint32 syncedAt; // only valid before 2105 (85 years to go)
        uint8  takerFeeBips;
        uint8  makerFeeBips;
        uint8  previousTakerFeeBips;
        uint8  previousMakerFeeBips;
    }

    // General auxiliary data for each conditional transaction
    struct AuxiliaryData
    {
        uint  txIndex;
        bool  approved;
        bytes data;
    }

    // This is the (virtual) block the owner  needs to submit onchain to maintain the
    // per-exchange (virtual) blockchain.
    struct Block
    {
        uint8      blockType;
        uint16     blockSize;
        uint8      blockVersion;
        bytes      data;
        uint256[8] proof;

        // Whether we should store the @BlockInfo for this block on-chain.
        bool storeBlockInfoOnchain;

        // Block specific data that is only used to help process the block on-chain.
        // It is not used as input for the circuits and it is not necessary for data-availability.
        // This bytes array contains the abi encoded AuxiliaryData[] data.
        bytes auxiliaryData;

        // Arbitrary data, mainly for off-chain data-availability, i.e.,
        // the multihash of the IPFS file that contains the block data.
        bytes offchainData;
    }

    struct BlockInfo
    {
        // The time the block was submitted on-chain.
        uint32  timestamp;
        // The public data hash of the block (the 28 most significant bytes).
        bytes28 blockDataHash;
    }

    // Represents an onchain deposit request.
    struct Deposit
    {
        uint96 amount;
        uint64 timestamp;
    }

    // A forced withdrawal request.
    // If the actual owner of the account initiated the request (we don't know who the owner is
    // at the time the request is being made) the full balance will be withdrawn.
    struct ForcedWithdrawal
    {
        address owner;
        uint64  timestamp;
    }

    struct Constants
    {
        uint SNARK_SCALAR_FIELD;
        uint MAX_OPEN_FORCED_REQUESTS;
        uint MAX_AGE_FORCED_REQUEST_UNTIL_WITHDRAW_MODE;
        uint TIMESTAMP_HALF_WINDOW_SIZE_IN_SECONDS;
        uint MAX_NUM_ACCOUNTS;
        uint MAX_NUM_TOKENS;
        uint MIN_AGE_PROTOCOL_FEES_UNTIL_UPDATED;
        uint MIN_TIME_IN_SHUTDOWN;
        uint TX_DATA_AVAILABILITY_SIZE;
        uint MAX_AGE_DEPOSIT_UNTIL_WITHDRAWABLE_UPPERBOUND;
    }

    // This is the prime number that is used for the alt_bn128 elliptic curve, see EIP-196.
    uint public constant SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    uint public constant MAX_OPEN_FORCED_REQUESTS = 4096;
    uint public constant MAX_AGE_FORCED_REQUEST_UNTIL_WITHDRAW_MODE = 15 days;
    uint public constant TIMESTAMP_HALF_WINDOW_SIZE_IN_SECONDS = 7 days;
    uint public constant MAX_NUM_ACCOUNTS = 2 ** 32;
    uint public constant MAX_NUM_TOKENS = 2 ** 16;
    uint public constant MIN_AGE_PROTOCOL_FEES_UNTIL_UPDATED = 7 days;
    uint public constant MIN_TIME_IN_SHUTDOWN = 30 days;
    // The amount of bytes each rollup transaction uses in the block data for data-availability.
    // This is the maximum amount of bytes of all different transaction types.
    uint32 public constant MAX_AGE_DEPOSIT_UNTIL_WITHDRAWABLE_UPPERBOUND = 15 days;
    uint32 public constant ACCOUNTID_PROTOCOLFEE = 0;

    uint public constant TX_DATA_AVAILABILITY_SIZE = 68;
    uint public constant TX_DATA_AVAILABILITY_SIZE_PART_1 = 29;
    uint public constant TX_DATA_AVAILABILITY_SIZE_PART_2 = 39;

    struct AccountLeaf
    {
        uint32   accountID;
        address  owner;
        uint     pubKeyX;
        uint     pubKeyY;
        uint32   nonce;
        uint     feeBipsAMM;
    }

    struct BalanceLeaf
    {
        uint16   tokenID;
        uint96   balance;
        uint96   weightAMM;
        uint     storageRoot;
    }

    struct MerkleProof
    {
        ExchangeData.AccountLeaf accountLeaf;
        ExchangeData.BalanceLeaf balanceLeaf;
        uint[48]                 accountMerkleProof;
        uint[24]                 balanceMerkleProof;
    }

    struct BlockContext
    {
        bytes32 DOMAIN_SEPARATOR;
        uint32  timestamp;
    }

    // Represents the entire exchange state except the owner of the exchange.
    struct State
    {
        uint32  maxAgeDepositUntilWithdrawable;
        bytes32 DOMAIN_SEPARATOR;

        ILoopringV3      loopring;
        IBlockVerifier   blockVerifier;
        IAgentRegistry   agentRegistry;
        IDepositContract depositContract;


        // The merkle root of the offchain data stored in a Merkle tree. The Merkle tree
        // stores balances for users using an account model.
        bytes32 merkleRoot;

        // List of all blocks
        mapping(uint => BlockInfo) blocks;
        uint  numBlocks;

        // List of all tokens
        Token[] tokens;

        // A map from a token to its tokenID + 1
        mapping (address => uint16) tokenToTokenId;

        // A map from an accountID to a tokenID to if the balance is withdrawn
        mapping (uint32 => mapping (uint16 => bool)) withdrawnInWithdrawMode;

        // A map from an account to a token to the amount withdrawable for that account.
        // This is only used when the automatic distribution of the withdrawal failed.
        mapping (address => mapping (uint16 => uint)) amountWithdrawable;

        // A map from an account to a token to the forced withdrawal (always full balance)
        mapping (uint32 => mapping (uint16 => ForcedWithdrawal)) pendingForcedWithdrawals;

        // A map from an address to a token to a deposit
        mapping (address => mapping (uint16 => Deposit)) pendingDeposits;

        // A map from an account owner to an approved transaction hash to if the transaction is approved or not
        mapping (address => mapping (bytes32 => bool)) approvedTx;

        // A map from an account owner to a destination address to a tokenID to an amount to a storageID to a new recipient address
        mapping (address => mapping (address => mapping (uint16 => mapping (uint => mapping (uint32 => address))))) withdrawalRecipient;


        // Counter to keep track of how many of forced requests are open so we can limit the work that needs to be done by the owner
        uint32 numPendingForcedTransactions;

        // Cached data for the protocol fee
        ProtocolFeeData protocolFeeData;

        // Time when the exchange was shutdown
        uint shutdownModeStartTime;

        // Time when the exchange has entered withdrawal mode
        uint withdrawalModeStartTime;

        // Last time the protocol fee was withdrawn for a specific token
        mapping (address => uint) protocolFeeLastWithdrawnTime;
    }
}

// File: contracts/core/iface/IExchangeV3.sol

// Copyright 2017 Loopring Technology Limited.






///      ensure all data members are declared on IExchangeV3 to make it
///      easy to support upgradability through proxies.
///
///      Subclasses of this contract must NOT define constructor to
///      initialize data.
///


abstract contract IExchangeV3 is Claimable
{
    // -- Events --

    event ExchangeCloned(
        address exchangeAddress,
        address owner,
        bytes32 genesisMerkleRoot
    );

    event TokenRegistered(
        address token,
        uint16  tokenId
    );

    event Shutdown(
        uint timestamp
    );

    event WithdrawalModeActivated(
        uint timestamp
    );

    event BlockSubmitted(
        uint    indexed blockIdx,
        bytes32         merkleRoot,
        bytes32         publicDataHash
    );

    event DepositRequested(
        address from,
        address to,
        address token,
        uint16  tokenId,
        uint96  amount
    );

    event ForcedWithdrawalRequested(
        address owner,
        address token,
        uint32  accountID
    );

    event WithdrawalCompleted(
        uint8   category,
        address from,
        address to,
        address token,
        uint    amount
    );

    event WithdrawalFailed(
        uint8   category,
        address from,
        address to,
        address token,
        uint    amount
    );

    event ProtocolFeesUpdated(
        uint8 takerFeeBips,
        uint8 makerFeeBips,
        uint8 previousTakerFeeBips,
        uint8 previousMakerFeeBips
    );

    event TransactionApproved(
        address owner,
        bytes32 transactionHash
    );


    // -- Initialization --
    
    
    
    
    function initialize(
        address loopring,
        address owner,
        bytes32 genesisMerkleRoot
        )
        virtual
        external;

    
    ///      Can only be called by the exchange owner once.
    
    function setAgentRegistry(address agentRegistry)
        external
        virtual;

    
    
    function getAgentRegistry()
        external
        virtual
        view
        returns (IAgentRegistry);

    ///      Can only be called by the exchange owner once.
    
    function setDepositContract(address depositContract)
        external
        virtual;

    
    function refreshBlockVerifier()
        external
        virtual;

    
    
    function getDepositContract()
        external
        virtual
        view
        returns (IDepositContract);

    // @dev Exchange owner withdraws fees from the exchange.
    // @param token Fee token address
    // @param feeRecipient Fee recipient address
    function withdrawExchangeFees(
        address token,
        address feeRecipient
        )
        external
        virtual;

    // -- Constants --
    
    
    function getConstants()
        external
        virtual
        pure
        returns(ExchangeData.Constants memory);

    // -- Mode --
    
    
    function isInWithdrawalMode()
        external
        virtual
        view
        returns (bool);

    
    
    function isShutdown()
        external
        virtual
        view
        returns (bool);

    // -- Tokens --
    
    ///      different ids for the same ERC20 token.
    ///
    ///      Please note that 1 is reserved for Ether (ETH), 2 is reserved for Wrapped Ether (ETH),
    ///      and 3 is reserved for Loopring Token (LRC).
    ///
    ///      This function is only callable by the exchange owner.
    ///
    
    
    function registerToken(
        address tokenAddress
        )
        external
        virtual
        returns (uint16 tokenID);

    
    
    
    function getTokenID(
        address tokenAddress
        )
        external
        virtual
        view
        returns (uint16 tokenID);

    
    
    
    function getTokenAddress(
        uint16 tokenID
        )
        external
        virtual
        view
        returns (address tokenAddress);

    // -- Stakes --
    
    ///      The stake will be burned if the exchange does not fulfill its duty by
    ///      processing user requests in time. Please note that order matching may potentially
    ///      performed by another party and is not part of the exchange's duty.
    ///
    
    function getExchangeStake()
        external
        virtual
        view
        returns (uint);

    
    ///      This can only be done if the exchange has been correctly shutdown:
    ///      - The exchange owner has shutdown the exchange
    ///      - All deposit requests are processed
    ///      - All funds are returned to the users (merkle root is reset to initial state)
    ///
    ///      Can only be called by the exchange owner.
    ///
    
    function withdrawExchangeStake(
        address recipient
        )
        external
        virtual
        returns (uint amountLRC);

    
    ///      conditions are fulfilled.
    ///
    ///      Currently this will only burn the stake of the exchange if
    ///      the exchange is in withdrawal mode.
    function burnExchangeStake()
        external
        virtual;

    // -- Blocks --

    
    
    function getMerkleRoot()
        external
        virtual
        view
        returns (bytes32);

    
    ///      new exchange is 1.
    
    function getBlockHeight()
        external
        virtual
        view
        returns (uint);

    
    ///      A DEX can use this function to implement a payment receipt verification
    ///      contract with a challange-response scheme.
    
    function getBlockInfo(uint blockIdx)
        external
        virtual
        view
        returns (ExchangeData.BlockInfo memory);

    
    ///
    ///      This function can only be called by the exchange operator.
    ///
    
    ///      - blockType: The type of the new block
    ///      - blockSize: The number of onchain or offchain requests/settlements
    ///        that have been processed in this block
    ///      - blockVersion: The circuit version to use for verifying the block
    ///      - storeBlockInfoOnchain: If the block info for this block needs to be stored on-chain
    ///      - data: The data for this block
    ///      - offchainData: Arbitrary data, mainly for off-chain data-availability, i.e.,
    ///        the multihash of the IPFS file that contains the block data.
    function submitBlocks(ExchangeData.Block[] calldata blocks)
        external
        virtual;

    
    
    function getNumAvailableForcedSlots()
        external
        virtual
        view
        returns (uint);

    // -- Deposits --

    
    ///
    ///      This function is only callable by an agent of 'from'.
    ///
    ///      A fee to the owner is paid in ETH to process the deposit.
    ///      The operator is not forced to do the deposit and the user can send
    ///      any fee amount.
    ///
    
    
    
    
    
    function deposit(
        address from,
        address to,
        address tokenAddress,
        uint96  amount,
        bytes   calldata auxiliaryData
        )
        external
        virtual
        payable;

    
    
    
    
    function getPendingDepositAmount(
        address owner,
        address tokenAddress
        )
        external
        virtual
        view
        returns (uint96);

    // -- Withdrawals --
    
    ///      This request always withdraws the full balance.
    ///
    ///      This function is only callable by an agent of the account.
    ///
    ///      The total fee in ETH that the user needs to pay is 'withdrawalFee'.
    ///      If the user sends too much ETH the surplus is sent back immediately.
    ///
    ///      Note that after such an operation, it will take the owner some
    ///      time (no more than MAX_AGE_FORCED_REQUEST_UNTIL_WITHDRAW_MODE) to process the request
    ///      and create the deposit to the offchain account.
    ///
    
    
    
    function forceWithdraw(
        address owner,
        address tokenAddress,
        uint32  accountID
        )
        external
        virtual
        payable;

    
    
    
    
    function isForcedWithdrawalPending(
        uint32  accountID,
        address token
        )
        external
        virtual
        view
        returns (bool);

    
    ///      protocol fees account. The complete balance is always withdrawn.
    ///
    ///      Anyone can request a withdrawal of the protocol fees.
    ///
    ///      Note that after such an operation, it will take the owner some
    ///      time (no more than MAX_AGE_FORCED_REQUEST_UNTIL_WITHDRAW_MODE) to process the request
    ///      and create the deposit to the offchain account.
    ///
    
    function withdrawProtocolFees(
        address tokenAddress
        )
        external
        virtual
        payable;

    
    
    
    function getProtocolFeeLastWithdrawnTime(
        address tokenAddress
        )
        external
        virtual
        view
        returns (uint);

    
    ///      in the Merkle tree. The funds will be sent to the owner of the acount.
    ///
    ///      Can only be used in withdrawal mode (i.e. when the owner has stopped
    ///      committing blocks and is not able to commit any more blocks).
    ///
    ///      This will NOT modify the onchain merkle root! The merkle root stored
    ///      onchain will remain the same after the withdrawal. We store if the user
    ///      has withdrawn the balance in State.withdrawnInWithdrawMode.
    ///
    
    function withdrawFromMerkleTree(
        ExchangeData.MerkleProof calldata merkleProof
        )
        external
        virtual;

    
    
    
    
    function isWithdrawnInWithdrawalMode(
        uint32  accountID,
        address token
        )
        external
        virtual
        view
        returns (bool);

    
    ///      it was never processed by the owner within the maximum time allowed.
    ///
    ///      Can be called by anyone. The deposited tokens will be sent back to
    ///      the owner of the account they were deposited in.
    ///
    
    
    function withdrawFromDepositRequest(
        address owner,
        address token
        )
        external
        virtual;

    
    ///      or offchain) was submitted in a block by the operator.
    ///
    ///      Can be called by anyone. The withdrawn tokens will be sent to
    ///      the owner of the account they were withdrawn out.
    ///
    ///      Normally it is should not be needed for users to call this manually.
    ///      Funds from withdrawal requests will be sent to the account owner
    ///      immediately by the owner when the block is submitted.
    ///      The user will however need to call this manually if the transfer failed.
    ///
    ///      Tokens and owners must have the same size.
    ///
    
    
    function withdrawFromApprovedWithdrawals(
        address[] calldata owners,
        address[] calldata tokens
        )
        external
        virtual;

    
    
    
    
    function getAmountWithdrawable(
        address owner,
        address token
        )
        external
        virtual
        view
        returns (uint);

    
    ///      If this is indeed the case, the exchange will enter withdrawal mode.
    ///
    ///      Can be called by anyone.
    ///
    
    
    function notifyForcedRequestTooOld(
        uint32  accountID,
        address token
        )
        external
        virtual;

    
    ///      than initialy specified in the withdrawal request. This can be used to
    ///      implement functionality like fast withdrawals.
    ///
    ///      This function can only be called by an agent.
    ///
    
    
    
    
    
    
    function setWithdrawalRecipient(
        address from,
        address to,
        address token,
        uint96  amount,
        uint32  storageID,
        address newRecipient
        )
        external
        virtual;

    
    ///
    
    
    
    
    
    function getWithdrawalRecipient(
        address from,
        address to,
        address token,
        uint96  amount,
        uint32  storageID
        )
        external
        virtual
        view
        returns (address);

    
    ///      the user has set for the exchange. This way the user only needs to approve a single exchange contract
    ///      for all exchange/agent features, which allows for a more seamless user experience.
    ///
    ///      This function can only be called by an agent.
    ///
    
    
    
    
    function onchainTransferFrom(
        address from,
        address to,
        address token,
        uint    amount
        )
        external
        virtual;

    
    ///
    ///      This function can only be called by an agent.
    ///
    
    
    function approveTransaction(
        address owner,
        bytes32 txHash
        )
        external
        virtual;

    
    ///
    ///      This function can only be called by an agent.
    ///
    
    
    function approveTransactions(
        address[] calldata owners,
        bytes32[] calldata txHashes
        )
        external
        virtual;

    
    ///
    
    
    
    function isTransactionApproved(
        address owner,
        bytes32 txHash
        )
        external
        virtual
        view
        returns (bool);

    // -- Admins --
    
    
    
    function setMaxAgeDepositUntilWithdrawable(
        uint32 newValue
        )
        external
        virtual
        returns (uint32);

    
    
    function getMaxAgeDepositUntilWithdrawable()
        external
        virtual
        view
        returns (uint32);

    
    ///      Once the exchange is shutdown all onchain requests are permanently disabled.
    ///      When all requirements are fulfilled the exchange owner can withdraw
    ///      the exchange stake with withdrawStake.
    ///
    ///      Note that the exchange can still enter the withdrawal mode after this function
    ///      has been invoked successfully. To prevent entering the withdrawal mode before the
    ///      the echange stake can be withdrawn, all withdrawal requests still need to be handled
    ///      for at least MIN_TIME_IN_SHUTDOWN seconds.
    ///
    ///      Can only be called by the exchange owner.
    ///
    
    function shutdown()
        external
        virtual
        returns (bool success);

    
    
    
    
    
    
    function getProtocolFeeValues()
        external
        virtual
        view
        returns (
            uint32 syncedAt,
            uint8 takerFeeBips,
            uint8 makerFeeBips,
            uint8 previousTakerFeeBips,
            uint8 previousMakerFeeBips
        );

    
    function getDomainSeparator()
        external
        virtual
        view
        returns (bytes32);

    
    function setAmmFeeBips(uint8 _feeBips)
        external
        virtual;

    
    function getAmmFeeBips()
        external
        virtual
        view
        returns (uint8);
}

// File: contracts/amm/libamm/IAmmSharedConfig.sol

// Copyright 2017 Loopring Technology Limited.

interface IAmmSharedConfig
{
    function maxForcedExitAge() external view returns (uint);
    function maxForcedExitCount() external view returns (uint);
    function forcedExitFee() external view returns (uint);
}

// File: contracts/amm/libamm/AmmData.sol

// Copyright 2017 Loopring Technology Limited.






library AmmData
{
    uint public constant POOL_TOKEN_BASE = 100 * (10 ** 8);
    uint public constant POOL_TOKEN_MINTED_SUPPLY = uint96(-1);

    enum PoolTxType
    {
        NOOP,
        JOIN,
        EXIT
    }

    struct PoolConfig
    {
        address   sharedConfig;
        address   exchange;
        string    poolName;
        uint32    accountID;
        address[] tokens;
        uint96[]  weights;
        uint8     feeBips;
        string    tokenSymbol;
    }

    struct PoolJoin
    {
        address   owner;
        uint96[]  joinAmounts;
        uint32[]  joinStorageIDs;
        uint96    mintMinAmount;
        uint96    fee;
        uint32    validUntil;
    }

    struct PoolExit
    {
        address   owner;
        uint96    burnAmount;
        uint32    burnStorageID; // for pool token withdrawal from user to the pool
        uint96[]  exitMinAmounts; // the amount to receive BEFORE paying the fee.
        uint96    fee;
        uint32    validUntil;
    }

    struct PoolTx
    {
        PoolTxType txType;
        bytes      data;
        bytes      signature;
    }

    struct Token
    {
        address addr;
        uint96  weight;
        uint16  tokenID;
    }

    struct Context
    {
        // functional parameters
        uint txIdx;

        // AMM pool state variables
        bytes32 domainSeparator;
        uint32  accountID;

        uint16  poolTokenID;
        uint8   feeBips;
        uint    totalSupply;

        Token[]  tokens;
        uint96[] tokenBalancesL2;
    }

    struct State {
        // Pool token state variables
        string poolName;
        string symbol;
        uint   _totalSupply;

        mapping(address => uint) balanceOf;
        mapping(address => mapping(address => uint)) allowance;
        mapping(address => uint) nonces;

        // AMM pool state variables
        IAmmSharedConfig sharedConfig;

        Token[]     tokens;

        // The order of the following variables important to minimize loads
        bytes32     exchangeDomainSeparator;
        bytes32     domainSeparator;
        IExchangeV3 exchange;
        uint32      accountID;
        uint16      poolTokenID;
        uint8       feeBips;

        address     exchangeOwner;

        uint64      shutdownTimestamp;
        uint16      forcedExitCount;

        // A map from a user to the forced exit.
        mapping (address => PoolExit) forcedExit;
        mapping (bytes32 => bool) approvedTx;
    }
}

// File: contracts/amm/libamm/AmmJoinRequest.sol

// Copyright 2017 Loopring Technology Limited.





library AmmJoinRequest
{
    bytes32 constant private POOLJOIN_TYPEHASH = keccak256(
        "PoolJoin(address owner,uint96[] joinAmounts,uint32[] joinStorageIDs,uint96 mintMinAmount,uint96 fee,uint32 validUntil)"
    );

    event PoolJoinRequested(AmmData.PoolJoin join);

    function joinPool(
        AmmData.State storage S,
        uint96[]     calldata joinAmounts,
        uint96                mintMinAmount,
        uint96                fee
        )
        public
    {
        require(joinAmounts.length == S.tokens.length,"INVALID_PARAM_SIZE");

        for (uint i = 0; i < S.tokens.length; i++) {
            require(joinAmounts[i] > 0, "INVALID_VALUE");
        }

        AmmData.PoolJoin memory join = AmmData.PoolJoin({
            owner: msg.sender,
            joinAmounts: joinAmounts,
            joinStorageIDs: new uint32[](0),
            mintMinAmount: mintMinAmount,
            fee: fee,
            validUntil: uint32(block.timestamp + S.sharedConfig.maxForcedExitAge())
        });

        // Approve the join
        bytes32 txHash = hash(S.domainSeparator, join);
        S.approvedTx[txHash] = true;

        emit PoolJoinRequested(join);
    }

    function hash(
        bytes32 domainSeparator,
        AmmData.PoolJoin memory join
        )
        internal
        pure
        returns (bytes32)
    {
        return EIP712.hashPacked(
            domainSeparator,
            keccak256(
                abi.encode(
                    POOLJOIN_TYPEHASH,
                    join.owner,
                    keccak256(abi.encodePacked(join.joinAmounts)),
                    keccak256(abi.encodePacked(join.joinStorageIDs)),
                    join.mintMinAmount,
                    join.fee,
                    join.validUntil
                )
            )
        );
    }
}