// SPDX-License-Identifier: GPL-3.0

// 
pragma solidity 0.8.17;






interface ITokenDistributor {
    enum TokenType {
        Native,
        Erc20
    }

    // Info on a distribution, created by createDistribution().
    struct DistributionInfo {
        // Type of distribution/token.
        TokenType tokenType;
        // ID of the distribution. Assigned by createDistribution().
        uint256 distributionId;
        // The party whose members can claim the distribution.
        ITokenDistributorParty party;
        // Who can claim `fee`.
        address payable feeRecipient;
        // The token being distributed.
        address token;
        // Total amount of `token` that can be claimed by party members.
        uint128 memberSupply;
        // Amount of `token` to be redeemed by `feeRecipient`.
        uint128 fee;
    }

    event DistributionCreated(
        ITokenDistributorParty indexed party,
        DistributionInfo info
    );
    event DistributionFeeClaimed(
        ITokenDistributorParty indexed party,
        address indexed feeRecipient,
        TokenType tokenType,
        address token,
        uint256 amount
    );
    event DistributionClaimedByPartyToken(
        ITokenDistributorParty indexed party,
        uint256 indexed partyTokenId,
        address indexed owner,
        TokenType tokenType,
        address token,
        uint256 amountClaimed
    );

    
    ///         governed by a party.
    
    ///      immediately prior (same tx) to calling `createDistribution()` or
    ///      attached to the call itself.
    
    
    
    
    function createNativeDistribution(
        ITokenDistributorParty party,
        address payable feeRecipient,
        uint16 feeBps
    )
        external
        payable
        returns (DistributionInfo memory info);

    
    ///         governed by a party.
    
    ///      immediately prior (same tx) to calling `createDistribution()` or
    ///      attached to the call itself.
    
    
    
    
    
    function createErc20Distribution(
        IERC20 token,
        ITokenDistributorParty party,
        address payable feeRecipient,
        uint16 feeBps
    )
        external
        returns (DistributionInfo memory info);

    
    ///         to the party that created the distribution. The caller
    ///         must own this token.
    
    
    
    function claim(DistributionInfo calldata info, uint256 partyTokenId)
        external
        returns (uint128 amountClaimed);

    
    ///         can call this.
    
    
    function claimFee(DistributionInfo calldata info, address payable recipient)
        external;

    
    
    
    
    function batchClaim(DistributionInfo[] calldata infos, uint256[] calldata partyTokenIds)
        external
        returns (uint128[] memory amountsClaimed);

    
    
    
    function batchClaimFee(DistributionInfo[] calldata infos, address payable[] calldata recipients)
        external;

    
    ///         member, identified by the `partyTokenId`.
    
    
    
    
    function getClaimAmount(
        ITokenDistributorParty party,
        uint256 memberSupply,
        uint256 partyTokenId
    )
        external
        view
        returns (uint128);

    
    
    
    
    function wasFeeClaimed(ITokenDistributorParty party, uint256 distributionId)
        external
        view
        returns (bool);

    
    
    
    
    
    function hasPartyTokenIdClaimed(
        ITokenDistributorParty party,
        uint256 partyTokenId,
        uint256 distributionId
    )
        external
        view returns (bool);

    
    
    
    
    function getRemainingMemberSupply(
        ITokenDistributorParty party,
        uint256 distributionId
    )
        external
        view
        returns (uint128);
}

// 
pragma solidity 0.8.17;

// Interface the caller of `ITokenDistributor.createDistribution()` must implement.
interface ITokenDistributorParty {
    
    
    
    function ownerOf(uint256 tokenId) external view returns (address);
    
    ///         of 1e18. I.e., 1e18 = 100%.
    
    
    function getDistributionShareOf(uint256 tokenId) external view returns (uint256);
}

// 
pragma solidity 0.8.17;












///         implements `ITokenDistributorParty`).
contract TokenDistributor is ITokenDistributor {
    using LibAddress for address payable;
    using LibERC20Compat for IERC20;
    using LibRawResult for bytes;
    using LibSafeCast for uint256;

    struct DistributionState {
        // The hash of the `DistributionInfo`.
        bytes32 distributionHash;
        // The remaining member supply.
        uint128 remainingMemberSupply;
        // Whether the distribution's feeRecipient has claimed its fee.
        bool wasFeeClaimed;
        // Whether a governance token has claimed its distribution share.
        mapping(uint256 => bool) hasPartyTokenClaimed;
    }

    // Arguments for `_createDistribution()`.
    struct CreateDistributionArgs {
        ITokenDistributorParty party;
        TokenType tokenType;
        address token;
        uint256 currentTokenBalance;
        address payable feeRecipient;
        uint16 feeBps;
    }

    event EmergencyExecute(address target, bytes data);

    error OnlyPartyDaoError(address notDao, address partyDao);
    error InvalidDistributionInfoError(DistributionInfo info);
    error DistributionAlreadyClaimedByPartyTokenError(uint256 distributionId, uint256 partyTokenId);
    error DistributionFeeAlreadyClaimedError(uint256 distributionId);
    error MustOwnTokenError(address sender, address expectedOwner, uint256 partyTokenId);
    error EmergencyActionsNotAllowedError();
    error InvalidDistributionSupplyError(uint128 supply);
    error OnlyFeeRecipientError(address caller, address feeRecipient);
    error InvalidFeeBpsError(uint16 feeBps);

    // Token address used to indicate a native distribution (i.e. distribution of ETH).
    address private constant NATIVE_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    
    ///         is immutable and it’s address will never change.
    IGlobals public immutable GLOBALS;
    
    uint40 public immutable EMERGENCY_DISABLED_TIMESTAMP;

    
    mapping(ITokenDistributorParty => uint256) public lastDistributionIdPerParty;
    /// Last known balance of a token, identified by an ID derived from the token.
    /// Gets lazily updated when creating and claiming a distribution (transfers).
    /// Allows one to simply transfer and call `createDistribution()` without
    /// fussing with allowances.
    mapping(bytes32 => uint256) private _storedBalances;
    // tokenDistributorParty => distributionId => DistributionState
    mapping(ITokenDistributorParty => mapping(uint256 => DistributionState)) private _distributionStates;

    // msg.sender == DAO
    modifier onlyPartyDao() {
        {
            address partyDao = GLOBALS.getAddress(LibGlobals.GLOBAL_DAO_WALLET);
            if (msg.sender != partyDao) {
                revert OnlyPartyDaoError(msg.sender, partyDao);
            }
        }
        _;
    }

    // emergencyActionsDisabled == false
    modifier onlyIfEmergencyActionsAllowed() {
        if (block.timestamp > EMERGENCY_DISABLED_TIMESTAMP) {
            revert EmergencyActionsNotAllowedError();
        }
        _;
    }

    // Set the `Globals` contract.
    constructor(IGlobals globals, uint40 emergencyDisabledTimestamp) {
        GLOBALS = globals;
        EMERGENCY_DISABLED_TIMESTAMP = emergencyDisabledTimestamp;
    }

    
    function createNativeDistribution(
        ITokenDistributorParty party,
        address payable feeRecipient,
        uint16 feeBps
    )
        external
        payable
        returns (DistributionInfo memory info)
    {
        info = _createDistribution(CreateDistributionArgs({
            party: party,
            tokenType: TokenType.Native,
            token: NATIVE_TOKEN_ADDRESS,
            currentTokenBalance: address(this).balance,
            feeRecipient: feeRecipient,
            feeBps: feeBps
        }));
    }

    
    function createErc20Distribution(
        IERC20 token,
        ITokenDistributorParty party,
        address payable feeRecipient,
        uint16 feeBps
    )
        external
        returns (DistributionInfo memory info)
    {
        info = _createDistribution(CreateDistributionArgs({
            party: party,
            tokenType: TokenType.Erc20,
            token: address(token),
            currentTokenBalance: token.balanceOf(address(this)),
            feeRecipient: feeRecipient,
            feeBps: feeBps
        }));
    }

    
    function claim(DistributionInfo calldata info, uint256 partyTokenId)
        public
        returns (uint128 amountClaimed)
    {
        // Caller must own the party token.
        {
            address ownerOfPartyToken = info.party.ownerOf(partyTokenId);
            if (msg.sender != ownerOfPartyToken) {
                revert MustOwnTokenError(msg.sender, ownerOfPartyToken, partyTokenId);
            }
        }
        // DistributionInfo must be correct for this distribution ID.
        DistributionState storage state = _distributionStates[info.party][info.distributionId];
        if (state.distributionHash != _getDistributionHash(info)) {
            revert InvalidDistributionInfoError(info);
        }
        // The partyTokenId must not have claimed its distribution yet.
        if (state.hasPartyTokenClaimed[partyTokenId]) {
            revert DistributionAlreadyClaimedByPartyTokenError(info.distributionId, partyTokenId);
        }
        // Mark the partyTokenId as having claimed their distribution.
        state.hasPartyTokenClaimed[partyTokenId] = true;

        // Compute amount owed to partyTokenId.
        amountClaimed = getClaimAmount(info.party, info.memberSupply, partyTokenId);

        // Cap at the remaining member supply. Otherwise a malicious
        // party could drain more than the distribution supply.
        uint128 remainingMemberSupply = state.remainingMemberSupply;
        amountClaimed = amountClaimed > remainingMemberSupply
            ? remainingMemberSupply
            : amountClaimed;
        state.remainingMemberSupply = remainingMemberSupply - amountClaimed;

        // Transfer tokens owed.
        _transfer(
            info.tokenType,
            info.token,
            payable(msg.sender),
            amountClaimed
        );
        emit DistributionClaimedByPartyToken(
            info.party,
            partyTokenId,
            msg.sender,
            info.tokenType,
            info.token,
            amountClaimed
        );
    }

    
    function claimFee(DistributionInfo calldata info, address payable recipient)
        public
    {
        // DistributionInfo must be correct for this distribution ID.
        DistributionState storage state = _distributionStates[info.party][info.distributionId];
        if (state.distributionHash != _getDistributionHash(info)) {
            revert InvalidDistributionInfoError(info);
        }
        // Caller must be the fee recipient.
        if (info.feeRecipient != msg.sender) {
            revert OnlyFeeRecipientError(msg.sender, info.feeRecipient);
        }
        // Must not have claimed the fee yet.
        if (state.wasFeeClaimed) {
            revert DistributionFeeAlreadyClaimedError(info.distributionId);
        }
        // Mark the fee as claimed.
        state.wasFeeClaimed = true;
        // Transfer the tokens owed.
        _transfer(
            info.tokenType,
            info.token,
            recipient,
            info.fee
        );
        emit DistributionFeeClaimed(
            info.party,
            info.feeRecipient,
            info.tokenType,
            info.token,
            info.fee
        );
    }

    
    function batchClaim(DistributionInfo[] calldata infos, uint256[] calldata partyTokenIds)
        external
        returns (uint128[] memory amountsClaimed)
    {
        amountsClaimed = new uint128[](infos.length);
        for (uint256 i = 0; i < infos.length; ++i) {
            amountsClaimed[i] = claim(infos[i], partyTokenIds[i]);
        }
    }

    
    function batchClaimFee(DistributionInfo[] calldata infos, address payable[] calldata recipients)
        external
    {
        for (uint256 i = 0; i < infos.length; ++i) {
            claimFee(infos[i], recipients[i]);
        }
    }

    
    function getClaimAmount(
        ITokenDistributorParty party,
        uint256 memberSupply,
        uint256 partyTokenId
    )
        public
        view
        returns (uint128)
    {
        // getDistributionShareOf() is the fraction of the memberSupply partyTokenId
        // is entitled to, scaled by 1e18.
        // We round up here to prevent dust amounts getting trapped in this contract.
        return (
            (
                uint256(party.getDistributionShareOf(partyTokenId))
                * memberSupply
                + (1e18 - 1)
            )
            / 1e18
        ).safeCastUint256ToUint128();
    }

    
    function wasFeeClaimed(ITokenDistributorParty party, uint256 distributionId)
        external
        view
        returns (bool)
    {
        return _distributionStates[party][distributionId].wasFeeClaimed;
    }

    
    function hasPartyTokenIdClaimed(
        ITokenDistributorParty party,
        uint256 partyTokenId,
        uint256 distributionId
    )
        external
        view returns (bool)
    {
        return _distributionStates[party][distributionId].hasPartyTokenClaimed[partyTokenId];
    }

    
    function getRemainingMemberSupply(
        ITokenDistributorParty party,
        uint256 distributionId
    )
        external
        view
        returns (uint128)
    {
        return _distributionStates[party][distributionId].remainingMemberSupply;
    }

    
    
    
    
    function emergencyExecute(
        address targetAddress,
        bytes calldata targetCallData
    )
        external
        onlyPartyDao
        onlyIfEmergencyActionsAllowed
    {
        (bool success, bytes memory res) = targetAddress.delegatecall(targetCallData);
        if (!success) {
            res.rawRevert();
        }
        emit EmergencyExecute(targetAddress, targetCallData);
    }

    function _createDistribution(CreateDistributionArgs memory args)
        private
        returns (DistributionInfo memory info)
    {
        if (args.feeBps > 1e4) {
            revert InvalidFeeBpsError(args.feeBps);
        }
        uint128 supply;
        {
            bytes32 balanceId = _getBalanceId(args.tokenType, args.token);
            supply = (args.currentTokenBalance - _storedBalances[balanceId])
                .safeCastUint256ToUint128();
            // Supply must be nonzero.
            if (supply == 0) {
                revert InvalidDistributionSupplyError(supply);
            }
            // Update stored balance.
            _storedBalances[balanceId] = args.currentTokenBalance;
        }

        // Create a distribution.
        uint128 fee = supply * args.feeBps / 1e4;
        uint128 memberSupply = supply - fee;

        info = DistributionInfo({
            tokenType: args.tokenType,
            distributionId: ++lastDistributionIdPerParty[args.party],
            token: args.token,
            party: args.party,
            memberSupply: memberSupply,
            feeRecipient: args.feeRecipient,
            fee: fee
        });
        (
            _distributionStates[args.party][info.distributionId].distributionHash,
            _distributionStates[args.party][info.distributionId].remainingMemberSupply
        ) = (_getDistributionHash(info), memberSupply);
        emit DistributionCreated(args.party, info);
    }

    function _transfer(
        TokenType tokenType,
        address token,
        address payable recipient,
        uint256 amount
    )
        private
    {
        bytes32 balanceId = _getBalanceId(tokenType, token);
        // Reduce stored token balance.
        uint256 storedBalance = _storedBalances[balanceId] - amount;
        // Temporarily set to max as a reentrancy guard. An interesing attack
        // could occur if we didn't do this where an attacker could `claim()` and
        // reenter upon transfer (eg. in the `tokensToSend` hook of an ERC777) to
        // `createERC20Distribution()`. Since the `balanceOf(address(this))`
        // would not of been updated yet, the supply would be miscalculated and
        // the attacker would create a distribution that essentially steals from
        // the last distribution they were claiming from. Here, we prevent that
        // by causing an arithmetic underflow with the supply calculation if
        // this were to be attempted.
        _storedBalances[balanceId] = type(uint256).max;
        if (tokenType == TokenType.Native) {
            recipient.transferEth(amount);
        } else {
            assert(tokenType == TokenType.Erc20);
            IERC20(token).compatTransfer(recipient, amount);
        }
        _storedBalances[balanceId] = storedBalance;
    }

    function _getDistributionHash(DistributionInfo memory info)
        internal
        pure
        returns (bytes32 hash)
    {
        assembly {
            hash := keccak256(info, 0xe0)
        }
    }

    function _getBalanceId(TokenType tokenType, address token)
        private
        pure
        returns (bytes32 balanceId)
    {
        if (tokenType == TokenType.Native) {
            return bytes32(uint256(uint160(NATIVE_TOKEN_ADDRESS)));
        }
        assert(tokenType == TokenType.Erc20);
        return bytes32(uint256(uint160(token)));
    }
}

// 
pragma solidity 0.8.17;



// Single registry of global values controlled by multisig.
// See `LibGlobals` for all valid keys.
interface IGlobals {
    function getBytes32(uint256 key) external view returns (bytes32);
    function getUint256(uint256 key) external view returns (uint256);
    function getBool(uint256 key) external view returns (bool);
    function getAddress(uint256 key) external view returns (address);
    function getImplementation(uint256 key) external view returns (Implementation);
    function getIncludesBytes32(uint256 key, bytes32 value) external view returns (bool);
    function getIncludesUint256(uint256 key, uint256 value) external view returns (bool);
    function getIncludesAddress(uint256 key, address value) external view returns (bool);

    function setBytes32(uint256 key, bytes32 value) external;
    function setUint256(uint256 key, uint256 value) external;
    function setBool(uint256 key, bool value) external;
    function setAddress(uint256 key, address value) external;
    function setIncludesBytes32(uint256 key, bytes32 value, bool isIncluded) external;
    function setIncludesUint256(uint256 key, uint256 value, bool isIncluded) external;
    function setIncludesAddress(uint256 key, address value, bool isIncluded) external;
}

// 
pragma solidity 0.8.17;

// Valid keys in `IGlobals`. Append-only.
library LibGlobals {
    uint256 internal constant GLOBAL_PARTY_IMPL                     = 1;
    uint256 internal constant GLOBAL_PROPOSAL_ENGINE_IMPL           = 2;
    uint256 internal constant GLOBAL_PARTY_FACTORY                  = 3;
    uint256 internal constant GLOBAL_GOVERNANCE_NFT_RENDER_IMPL     = 4;
    uint256 internal constant GLOBAL_CF_NFT_RENDER_IMPL             = 5;
    uint256 internal constant GLOBAL_OS_ZORA_AUCTION_TIMEOUT        = 6;
    uint256 internal constant GLOBAL_OS_ZORA_AUCTION_DURATION       = 7;
    uint256 internal constant GLOBAL_AUCTION_CF_IMPL                = 8;
    uint256 internal constant GLOBAL_BUY_CF_IMPL                    = 9;
    uint256 internal constant GLOBAL_COLLECTION_BUY_CF_IMPL         = 10;
    uint256 internal constant GLOBAL_DAO_WALLET                     = 11;
    uint256 internal constant GLOBAL_TOKEN_DISTRIBUTOR              = 12;
    uint256 internal constant GLOBAL_OPENSEA_CONDUIT_KEY            = 13;
    uint256 internal constant GLOBAL_OPENSEA_ZONE                   = 14;
    uint256 internal constant GLOBAL_PROPOSAL_MAX_CANCEL_DURATION   = 15;
    uint256 internal constant GLOBAL_ZORA_MIN_AUCTION_DURATION      = 16;
    uint256 internal constant GLOBAL_ZORA_MAX_AUCTION_DURATION      = 17;
    uint256 internal constant GLOBAL_ZORA_MAX_AUCTION_TIMEOUT       = 18;
    uint256 internal constant GLOBAL_OS_MIN_ORDER_DURATION          = 19;
    uint256 internal constant GLOBAL_OS_MAX_ORDER_DURATION          = 20;
    uint256 internal constant GLOBAL_DISABLE_PARTY_ACTIONS          = 21;
    uint256 internal constant GLOBAL_RENDERER_STORAGE               = 22;
    uint256 internal constant GLOBAL_PROPOSAL_MIN_CANCEL_DURATION   = 23;
}

// 
pragma solidity ^0.8;

// Minimal ERC20 interface.
interface IERC20 {
    event Transfer(address indexed owner, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 allowance);

    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 allowance) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
}

// 
pragma solidity 0.8.17;

// Base contract for all contracts intended to be delegatecalled into.
abstract contract Implementation {
    error OnlyDelegateCallError();
    error OnlyConstructorError();

    address public immutable IMPL;

    constructor() { IMPL = address(this); }

    // Reverts if the current function context is not inside of a delegatecall.
    modifier onlyDelegateCall() virtual {
        if (address(this) == IMPL) {
            revert OnlyDelegateCallError();
        }
        _;
    }

    // Reverts if the current function context is not inside of a constructor.
    modifier onlyConstructor() {
        uint256 codeSize;
        assembly { codeSize := extcodesize(address()) }
        if (codeSize != 0) {
            revert OnlyConstructorError();
        }
        _;
    }
}

// 
pragma solidity 0.8.17;

library LibAddress {
    error EthTransferFailed(address receiver, bytes errData);

    // Transfer ETH with full gas stipend.
    function transferEth(address payable receiver, uint256 amount)
        internal
    {
        if (amount == 0) return;

        (bool s, bytes memory r) = receiver.call{value: amount}("");
        if (!s) {
            revert EthTransferFailed(receiver, r);
        }
    }
}

// 
pragma solidity 0.8.17;



// Compatibility helpers for ERC20s.
library LibERC20Compat {
    error NotATokenError(IERC20 token);
    error TokenTransferFailedError(IERC20 token, address to, uint256 amount);

    // Perform an `IERC20.transfer()` handling non-compliant implementations.
    function compatTransfer(IERC20 token, address to, uint256 amount)
        internal
    {
        (bool s, bytes memory r) =
            address(token).call(abi.encodeCall(IERC20.transfer, (to, amount)));
        if (s) {
            if (r.length == 0) {
                uint256 cs;
                assembly { cs := extcodesize(token) }
                if (cs == 0) {
                    revert NotATokenError(token);
                }
                return;
            }
            if (abi.decode(r, (bool))) {
                return;
            }
        }
        revert TokenTransferFailedError(token, to, amount);
    }
}

// 
pragma solidity 0.8.17;

library LibRawResult {
    // Revert with the data in `b`.
    function rawRevert(bytes memory b)
        internal
        pure
    {
        assembly { revert(add(b, 32), mload(b)) }
    }

    // Return with the data in `b`.
    function rawReturn(bytes memory b)
        internal
        pure
    {
        assembly { return(add(b, 32), mload(b)) }
    }
}

// 
pragma solidity 0.8.17;

library LibSafeCast {
    error Uint256ToUint96CastOutOfRange(uint256 v);
    error Uint256ToInt192CastOutOfRange(uint256 v);
    error Int192ToUint96CastOutOfRange(int192 i192);
    error Uint256ToInt128CastOutOfRangeError(uint256 u256);
    error Uint256ToUint128CastOutOfRangeError(uint256 u256);
    error Uint256ToUint40CastOutOfRangeError(uint256 u256);

    function safeCastUint256ToUint96(uint256 v) internal pure returns (uint96) {
        if (v > uint256(type(uint96).max)) {
            revert Uint256ToUint96CastOutOfRange(v);
        }
        return uint96(v);
    }

    function safeCastUint256ToUint128(uint256 v) internal pure returns (uint128) {
        if (v > uint256(type(uint128).max)) {
            revert Uint256ToUint128CastOutOfRangeError(v);
        }
        return uint128(v);
    }

    function safeCastUint256ToInt192(uint256 v) internal pure returns (int192) {
        if (v > uint256(uint192(type(int192).max))) {
            revert Uint256ToInt192CastOutOfRange(v);
        }
        return int192(uint192(v));
    }

    function safeCastUint96ToInt192(uint96 v) internal pure returns (int192) {
        return int192(uint192(v));
    }

    function safeCastInt192ToUint96(int192 i192) internal pure returns (uint96) {
        if (i192 < 0 || i192 > int192(uint192(type(uint96).max))) {
            revert Int192ToUint96CastOutOfRange(i192);
        }
        return uint96(uint192(i192));
    }

    function safeCastUint256ToInt128(uint256 x)
        internal
        pure
        returns (int128)
    {
        if (x > uint256(uint128(type(int128).max))) {
            revert Uint256ToInt128CastOutOfRangeError(x);
        }
        return int128(uint128(x));
    }

    function safeCastUint256ToUint40(uint256 x)
        internal
        pure
        returns (uint40)
    {
        if (x > uint256(type(uint40).max)) {
            revert Uint256ToUint40CastOutOfRangeError(x);
        }
        return uint40(x);
    }
}