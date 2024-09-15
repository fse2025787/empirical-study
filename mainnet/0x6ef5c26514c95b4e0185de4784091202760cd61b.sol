// SPDX-License-Identifier: Apache-2.0
pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2021-03-10
*/

// 
pragma solidity ^0.7.0;

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

// File: contracts/lib/ReentrancyGuard.sol

// Copyright 2017 Loopring Technology Limited.





///      Changing the value of the same storage value multiple times in a transaction
///      is cheap (starting from Istanbul) so there is no need to minimize
///      the number of times the value is changed
contract ReentrancyGuard
{
    //The default value must be 0 in order to work behind a proxy.
    uint private _guardValue;

    // Use this modifier on a function to prevent reentrancy
    modifier nonReentrant()
    {
        // Check if the guard value has its original value
        require(_guardValue == 0, "REENTRANCY");

        // Set the value to something else
        _guardValue = 1;

        // Function body
        _;

        // Set the value back
        _guardValue = 0;
    }
}

// File: contracts/lib/AddressSet.sol

// Copyright 2017 Loopring Technology Limited.




contract AddressSet
{
    struct Set
    {
        address[] addresses;
        mapping (address => uint) positions;
        uint count;
    }
    mapping (bytes32 => Set) private sets;

    function addAddressToSet(
        bytes32 key,
        address addr,
        bool maintainList
        ) internal
    {
        Set storage set = sets[key];
        require(set.positions[addr] == 0, "ALREADY_IN_SET");

        if (maintainList) {
            require(set.addresses.length == set.count, "PREVIOUSLY_NOT_MAINTAILED");
            set.addresses.push(addr);
        } else {
            require(set.addresses.length == 0, "MUST_MAINTAIN");
        }

        set.count += 1;
        set.positions[addr] = set.count;
    }

    function removeAddressFromSet(
        bytes32 key,
        address addr
        )
        internal
    {
        Set storage set = sets[key];
        uint pos = set.positions[addr];
        require(pos != 0, "NOT_IN_SET");

        delete set.positions[addr];
        set.count -= 1;

        if (set.addresses.length > 0) {
            address lastAddr = set.addresses[set.count];
            if (lastAddr != addr) {
                set.addresses[pos - 1] = lastAddr;
                set.positions[lastAddr] = pos;
            }
            set.addresses.pop();
        }
    }

    function removeSet(bytes32 key)
        internal
    {
        delete sets[key];
    }

    function isAddressInSet(
        bytes32 key,
        address addr
        )
        internal
        view
        returns (bool)
    {
        return sets[key].positions[addr] != 0;
    }

    function numAddressesInSet(bytes32 key)
        internal
        view
        returns (uint)
    {
        Set storage set = sets[key];
        return set.count;
    }

    function addressesInSet(bytes32 key)
        internal
        view
        returns (address[] memory)
    {
        Set storage set = sets[key];
        require(set.count == set.addresses.length, "NOT_MAINTAINED");
        return sets[key].addresses;
    }
}

// File: contracts/lib/OwnerManagable.sol

// Copyright 2017 Loopring Technology Limited.




contract OwnerManagable is Claimable, AddressSet
{
    bytes32 internal constant MANAGER = keccak256("__MANAGED__");

    event ManagerAdded  (address indexed manager);
    event ManagerRemoved(address indexed manager);

    modifier onlyManager
    {
        require(isManager(msg.sender), "NOT_MANAGER");
        _;
    }

    modifier onlyOwnerOrManager
    {
        require(msg.sender == owner || isManager(msg.sender), "NOT_OWNER_OR_MANAGER");
        _;
    }

    constructor() Claimable() {}

    
    
    function managers()
        public
        view
        returns (address[] memory)
    {
        return addressesInSet(MANAGER);
    }

    
    
    function numManagers()
        public
        view
        returns (uint)
    {
        return numAddressesInSet(MANAGER);
    }

    
    
    
    function isManager(address addr)
        public
        view
        returns (bool)
    {
        return isAddressInSet(MANAGER, addr);
    }

    
    
    function addManager(address manager)
        public
        onlyOwner
    {
        addManagerInternal(manager);
    }

    
    
    function removeManager(address manager)
        public
        onlyOwner
    {
        removeAddressFromSet(MANAGER, manager);
        emit ManagerRemoved(manager);
    }

    function addManagerInternal(address manager)
        internal
    {
        addAddressToSet(MANAGER, manager, true);
        emit ManagerAdded(manager);
    }
}

// File: contracts/lib/AddressUtil.sol

// Copyright 2017 Loopring Technology Limited.





library AddressUtil
{
    using AddressUtil for *;

    function isContract(
        address addr
        )
        internal
        view
        returns (bool)
    {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(addr) }
        return (codehash != 0x0 &&
                codehash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);
    }

    function toPayable(
        address addr
        )
        internal
        pure
        returns (address payable)
    {
        return payable(addr);
    }

    // Works like address.send but with a customizable gas limit
    // Make sure your code is safe for reentrancy when using this function!
    function sendETH(
        address to,
        uint    amount,
        uint    gasLimit
        )
        internal
        returns (bool success)
    {
        if (amount == 0) {
            return true;
        }
        address payable recipient = to.toPayable();
        /* solium-disable-next-line */
        (success, ) = recipient.call{value: amount, gas: gasLimit}("");
    }

    // Works like address.transfer but with a customizable gas limit
    // Make sure your code is safe for reentrancy when using this function!
    function sendETHAndVerify(
        address to,
        uint    amount,
        uint    gasLimit
        )
        internal
        returns (bool success)
    {
        success = to.sendETH(amount, gasLimit);
        require(success, "TRANSFER_FAILURE");
    }

    // Works like call but is slightly more efficient when data
    // needs to be copied from memory to do the call.
    function fastCall(
        address to,
        uint    gasLimit,
        uint    value,
        bytes   memory data
        )
        internal
        returns (bool success, bytes memory returnData)
    {
        if (to != address(0)) {
            assembly {
                // Do the call
                success := call(gasLimit, to, value, add(data, 32), mload(data), 0, 0)
                // Copy the return data
                let size := returndatasize()
                returnData := mload(0x40)
                mstore(returnData, size)
                returndatacopy(add(returnData, 32), 0, size)
                // Update free memory pointer
                mstore(0x40, add(returnData, add(32, size)))
            }
        }
    }

    // Like fastCall, but throws when the call is unsuccessful.
    function fastCallAndVerify(
        address to,
        uint    gasLimit,
        uint    value,
        bytes   memory data
        )
        internal
        returns (bytes memory returnData)
    {
        bool success;
        (success, returnData) = fastCall(to, gasLimit, value, data);
        if (!success) {
            assembly {
                revert(add(returnData, 32), mload(returnData))
            }
        }
    }
}

// File: contracts/lib/ERC20.sol

// Copyright 2017 Loopring Technology Limited.





abstract contract ERC20
{
    function totalSupply()
        public
        virtual
        view
        returns (uint);

    function balanceOf(
        address who
        )
        public
        virtual
        view
        returns (uint);

    function allowance(
        address owner,
        address spender
        )
        public
        virtual
        view
        returns (uint);

    function transfer(
        address to,
        uint value
        )
        public
        virtual
        returns (bool);

    function transferFrom(
        address from,
        address to,
        uint    value
        )
        public
        virtual
        returns (bool);

    function approve(
        address spender,
        uint    value
        )
        public
        virtual
        returns (bool);
}

// File: contracts/lib/ERC20SafeTransfer.sol

// Copyright 2017 Loopring Technology Limited.





library ERC20SafeTransfer
{
    function safeTransferAndVerify(
        address token,
        address to,
        uint    value
        )
        internal
    {
        safeTransferWithGasLimitAndVerify(
            token,
            to,
            value,
            gasleft()
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint    value
        )
        internal
        returns (bool)
    {
        return safeTransferWithGasLimit(
            token,
            to,
            value,
            gasleft()
        );
    }

    function safeTransferWithGasLimitAndVerify(
        address token,
        address to,
        uint    value,
        uint    gasLimit
        )
        internal
    {
        require(
            safeTransferWithGasLimit(token, to, value, gasLimit),
            "TRANSFER_FAILURE"
        );
    }

    function safeTransferWithGasLimit(
        address token,
        address to,
        uint    value,
        uint    gasLimit
        )
        internal
        returns (bool)
    {
        // A transfer is successful when 'call' is successful and depending on the token:
        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)
        // - A single boolean is returned: this boolean needs to be true (non-zero)

        // bytes4(keccak256("transfer(address,uint256)")) = 0xa9059cbb
        bytes memory callData = abi.encodeWithSelector(
            bytes4(0xa9059cbb),
            to,
            value
        );
        (bool success, ) = token.call{gas: gasLimit}(callData);
        return checkReturnValue(success);
    }

    function safeTransferFromAndVerify(
        address token,
        address from,
        address to,
        uint    value
        )
        internal
    {
        safeTransferFromWithGasLimitAndVerify(
            token,
            from,
            to,
            value,
            gasleft()
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint    value
        )
        internal
        returns (bool)
    {
        return safeTransferFromWithGasLimit(
            token,
            from,
            to,
            value,
            gasleft()
        );
    }

    function safeTransferFromWithGasLimitAndVerify(
        address token,
        address from,
        address to,
        uint    value,
        uint    gasLimit
        )
        internal
    {
        bool result = safeTransferFromWithGasLimit(
            token,
            from,
            to,
            value,
            gasLimit
        );
        require(result, "TRANSFER_FAILURE");
    }

    function safeTransferFromWithGasLimit(
        address token,
        address from,
        address to,
        uint    value,
        uint    gasLimit
        )
        internal
        returns (bool)
    {
        // A transferFrom is successful when 'call' is successful and depending on the token:
        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)
        // - A single boolean is returned: this boolean needs to be true (non-zero)

        // bytes4(keccak256("transferFrom(address,address,uint256)")) = 0x23b872dd
        bytes memory callData = abi.encodeWithSelector(
            bytes4(0x23b872dd),
            from,
            to,
            value
        );
        (bool success, ) = token.call{gas: gasLimit}(callData);
        return checkReturnValue(success);
    }

    function checkReturnValue(
        bool success
        )
        internal
        pure
        returns (bool)
    {
        // A transfer/transferFrom is successful when 'call' is successful and depending on the token:
        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)
        // - A single boolean is returned: this boolean needs to be true (non-zero)
        if (success) {
            assembly {
                switch returndatasize()
                // Non-standard ERC20: nothing is returned so if 'call' was successful we assume the transfer succeeded
                case 0 {
                    success := 1
                }
                // Standard ERC20: a single boolean value is returned which needs to be true
                case 32 {
                    returndatacopy(0, 0, 32)
                    success := mload(0)
                }
                // None of the above: not successful
                default {
                    success := 0
                }
            }
        }
        return success;
    }
}

// File: contracts/lib/Drainable.sol

// Copyright 2017 Loopring Technology Limited.








abstract contract Drainable
{
    using AddressUtil       for address;
    using ERC20SafeTransfer for address;

    event Drained(
        address to,
        address token,
        uint    amount
    );

    function drain(
        address to,
        address token
        )
        public
        returns (uint amount)
    {
        require(canDrain(msg.sender, token), "UNAUTHORIZED");

        if (token == address(0)) {
            amount = address(this).balance;
            to.sendETHAndVerify(amount, gasleft());   // ETH
        } else {
            amount = ERC20(token).balanceOf(address(this));
            token.safeTransferAndVerify(to, amount);  // ERC20 token
        }

        emit Drained(to, token, amount);
    }

    // Needs to return if the address is authorized to call drain.
    function canDrain(address drainer, address token)
        public
        virtual
        view
        returns (bool);
}

// File: contracts/aux/agents/ForcedWithdrawalAgent.sol

// Copyright 2017 Loopring Technology Limited.







contract ForcedWithdrawalAgent is ReentrancyGuard, OwnerManagable, Drainable
{
    using AddressUtil for address;

    string constant public version = "3.1.2";

    function canDrain(address /*drainer*/, address /*token*/)
        public
        override
        view
        returns (bool) {
        return msg.sender == owner || isManager(msg.sender);
    }

    function doForcedWithdrawalFor(
        address exchangeAddress,
        address owner,
        address token,
        uint32 accountID
        )
        external
        payable
        nonReentrant
        onlyOwnerOrManager
    {
        IExchangeV3(exchangeAddress).forceWithdraw{value: msg.value}(owner, token, accountID);

        if (address(this).balance > 0) {
            drain(msg.sender, address(0));
        }
    }

    receive() external payable { }
}