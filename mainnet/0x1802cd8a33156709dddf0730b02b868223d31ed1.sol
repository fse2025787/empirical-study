// SPDX-License-Identifier: MIT
pragma abicoder v2;


// 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// 
pragma solidity 0.8.9;

interface IERC1271 {
    
    
    ///
    /// MUST return the bytes4 magic value 0x1626ba7e when function passes.
    ///
    /// MUST NOT modify state (using STATICCALL for solc < 0.5, view modifier for solc > 0.5)
    ///
    /// MUST allow external calls
    
    
    
    function isValidSignature(bytes32 _hash, bytes memory _signature) external view returns (bytes4 magicValue);
}

// 
pragma solidity 0.8.9;



interface IVault is IERC165 {
    

    function initialized() external view returns (bool);

    
    function nft() external view returns (uint256);

    
    function vaultGovernance() external view returns (IVaultGovernance);

    
    function vaultTokens() external view returns (address[] memory);

    
    
    
    function isVaultToken(address token) external view returns (bool);

    
    
    /// other DeFi protocol. For example, for USDC Yearn Vault this would be total USDC balance that could be withdrawn for Yearn to this contract.
    /// The tvl itself is estimated in some range. Sometimes the range is exact, sometimes it's not
    
    
    function tvl() external view returns (uint256[] memory minTokenAmounts, uint256[] memory maxTokenAmounts);

    
    function pullExistentials() external view returns (uint256[] memory);
}

// 
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;



/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface ICreditManagerV2Exceptions {
    
    ///      the connected Credit Facade, or an allowed adapter
    error AdaptersOrCreditFacadeOnlyException();

    
    ///      the connected Credit Facade
    error CreditFacadeOnlyException();

    
    ///      the connected Credit Configurator
    error CreditConfiguratorOnlyException();

    
    ///      to the zero address or an address that already owns a Credit Account
    error ZeroAddressOrUserAlreadyHasAccountException();

    
    ///      target contract
    error TargetContractNotAllowedException();

    
    error NotEnoughCollateralException();

    
    ///      or was forbidden
    error TokenNotAllowedException();

    
    error AllowanceFailedException();

    
    error HasNoOpenedAccountException();

    
    error TokenAlreadyAddedException();

    
    error TooManyTokensException();

    
    ///      and there are not enough unused token to disable
    error TooManyEnabledTokensException();

    
    error ReentrancyLockException();
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2021
pragma solidity ^0.8.9;



interface IPriceOracleV2Events {
    
    event NewPriceFeed(address indexed token, address indexed priceFeed);
}

interface IPriceOracleV2Exceptions {
    
    error ZeroPriceException();

    
    error ChainPriceStaleException();

    
    error PriceOracleNotExistsException();
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2021
pragma solidity ^0.8.9;



interface IVersion {
    
    function version() external view returns (uint256);
}

// 
pragma solidity 0.8.9;



interface IDefaultAccessControl is IAccessControlEnumerable {
    
    
    
    function isAdmin(address who) external view returns (bool);

    
    
    
    function isOperator(address who) external view returns (bool);
}

// 
pragma solidity 0.8.9;




interface IIntegrationVault is IVault, IERC1271 {
    
    /// the contract balance and convert it to yUSDC.
    
    ///
    /// Also notice that this operation doesn't guarantee that tokenAmounts will be invested in full.
    
    
    
    
    function push(
        address[] memory tokens,
        uint256[] memory tokenAmounts,
        bytes memory options
    ) external returns (uint256[] memory actualTokenAmounts);

    
    /// After the `push` it returns all the leftover tokens back (`push` method doesn't guarantee that tokenAmounts will be invested in full).
    
    
    
    
    function transferAndPush(
        address from,
        address[] memory tokens,
        uint256[] memory tokenAmounts,
        bytes memory options
    ) external returns (uint256[] memory actualTokenAmounts);

    
    
    /// Strategy is approved address for the vault NFT.
    /// When called by vault owner this method just pulls the tokens from the protocol to the `to` address
    /// When called by strategy on vault other than zero vault it pulls the tokens to zero vault (required `to` == zero vault)
    /// When called by strategy on zero vault it pulls the tokens to zero vault, pushes tokens on the `to` vault, and reclaims everything that's left.
    /// Thus any vault other than zero vault cannot have any tokens on it
    ///
    /// Tokens **must** be a subset of Vault Tokens. However, the convention is that if tokenAmount == 0 it is the same as token is missing.
    ///
    /// Pull is fulfilled on the best effort basis, i.e. if the tokenAmounts overflows available funds it withdraws all the funds.
    
    
    
    
    
    function pull(
        address to,
        address[] memory tokens,
        uint256[] memory tokenAmounts,
        bytes memory options
    ) external returns (uint256[] memory actualTokenAmounts);

    
    
    
    
    function reclaimTokens(address[] memory tokens) external returns (uint256[] memory actualTokenAmounts);

    
    
    /// Strategy is approved address for the vault NFT.
    ///
    /// Since this method allows sending arbitrary transactions, the destinations of the calls
    /// are whitelisted by Protocol Governance.
    
    
    
    
    function externalCall(
        address to,
        bytes4 selector,
        bytes memory data
    ) external payable returns (bytes memory result);
}

// 
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2021
pragma solidity ^0.8.9;


enum AdapterType {
    ABSTRACT,
    UNISWAP_V2_ROUTER,
    UNISWAP_V3_ROUTER,
    CURVE_V1_EXCHANGE_ONLY,
    YEARN_V2,
    CURVE_V1_2ASSETS,
    CURVE_V1_3ASSETS,
    CURVE_V1_4ASSETS,
    CURVE_V1_STECRV_POOL,
    CURVE_V1_WRAPPER,
    CONVEX_V1_BASE_REWARD_POOL,
    CONVEX_V1_BOOSTER,
    CONVEX_V1_CLAIM_ZAP,
    LIDO_V1,
    UNIVERSAL
}

interface IAdapterExceptions {
    
    ///      that is not recognized as collateral in the connected
    ///      Credit Manager
    error TokenIsNotInAllowedList(address);
}

// 
pragma solidity 0.8.9;











/// ### ERC-721
///
/// Each Vault should be registered in VaultRegistry and get corresponding VaultRegistry NFT.
///
/// ### Access control
///
/// `push` and `pull` methods are only allowed for owner / approved person of the NFT. However,
/// `pull` for approved person also checks that pull destination is another vault of the Vault System.
///
/// The semantics is: NFT owner owns all Vault liquidity, Approved person is liquidity manager.
/// ApprovedForAll person cannot do anything except ERC-721 token transfers.
///
/// Both NFT owner and approved person can call externalCall method which claims liquidity mining rewards (if any)
///
/// `reclaimTokens` for mistakenly transfered tokens (not included into vaultTokens) additionally can be withdrawn by
/// the protocol admin
abstract contract Vault is IVault, ERC165 {
    using SafeERC20 for IERC20;

    IVaultGovernance internal _vaultGovernance;
    address[] internal _vaultTokens;
    mapping(address => int256) internal _vaultTokensIndex;
    uint256 internal _nft;
    uint256[] internal _pullExistentials;

    constructor() {
        // lock initialization and thus all mutations for any deployed Vault
        _nft = type(uint256).max;
    }

    // -------------------  EXTERNAL, VIEW  -------------------

    
    function initialized() external view returns (bool) {
        return _nft != 0;
    }

    
    function isVaultToken(address token) public view returns (bool) {
        return _vaultTokensIndex[token] != 0;
    }

    
    function vaultGovernance() external view returns (IVaultGovernance) {
        return _vaultGovernance;
    }

    
    function vaultTokens() external view returns (address[] memory) {
        return _vaultTokens;
    }

    
    function nft() external view returns (uint256) {
        return _nft;
    }

    
    function tvl() public view virtual returns (uint256[] memory minTokenAmounts, uint256[] memory maxTokenAmounts);

    
    function pullExistentials() external view returns (uint256[] memory) {
        return _pullExistentials;
    }

    
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return super.supportsInterface(interfaceId) || (interfaceId == type(IVault).interfaceId);
    }

    // -------------------  INTERNAL, MUTATING  -------------------

    function _initialize(address[] memory vaultTokens_, uint256 nft_) internal virtual {
        require(_nft == 0, ExceptionsLibrary.INIT);
        require(CommonLibrary.isSortedAndUnique(vaultTokens_), ExceptionsLibrary.INVARIANT);
        require(nft_ != 0, ExceptionsLibrary.VALUE_ZERO); // guarantees that this method can only be called once
        IProtocolGovernance governance = IVaultGovernance(msg.sender).internalParams().protocolGovernance;
        require(
            vaultTokens_.length > 0 && vaultTokens_.length <= governance.maxTokensPerVault(),
            ExceptionsLibrary.INVALID_VALUE
        );
        for (uint256 i = 0; i < vaultTokens_.length; i++) {
            require(
                governance.hasPermission(vaultTokens_[i], PermissionIdsLibrary.ERC20_VAULT_TOKEN),
                ExceptionsLibrary.FORBIDDEN
            );
        }
        _vaultGovernance = IVaultGovernance(msg.sender);
        _vaultTokens = vaultTokens_;
        _nft = nft_;
        uint256 len = _vaultTokens.length;
        for (uint256 i = 0; i < len; ++i) {
            _vaultTokensIndex[vaultTokens_[i]] = int256(i + 1);

            IERC20Metadata token = IERC20Metadata(vaultTokens_[i]);
            _pullExistentials.push(10**(token.decimals() / 2));
        }
        emit Initialized(tx.origin, msg.sender, vaultTokens_, nft_);
    }

    // --------------------------  EVENTS  --------------------------

    
    
    
    
    
    event Initialized(address indexed origin, address indexed sender, address[] vaultTokens_, uint256 nft_);
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// 
pragma solidity >=0.5.0;



interface IDegenDistributorEvents {
    
    event Claimed(
        address indexed account,
        uint256 amount
    );

    
    event RootUpdated(bytes32 oldRoot, bytes32 indexed newRoot);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2022
pragma solidity ^0.8.9;



interface IDegenNFTExceptions {
    
    error CreditFacadeOrConfiguratorOnlyException();

    
    error MinterOnlyException();

    
    error InvalidCreditFacadeException();

    
    error InsufficientBalanceException();
}

interface IDegenNFTEvents {
    
    event NewMinterSet(address indexed);

    
    event NewCreditFacadeAdded(address indexed);

    
    event NewCreditFacadeRemoved(address indexed);
}

// 
pragma solidity 0.8.9;




interface IUnitPricesGovernance is IDefaultAccessControl, IERC165 {
    // -------------------  EXTERNAL, VIEW  -------------------

    
    
    
    function stagedUnitPrices(address token) external view returns (uint256);

    
    
    
    function stagedUnitPricesTimestamps(address token) external view returns (uint256);

    
    
    
    function unitPrices(address token) external view returns (uint256);

    // -------------------  EXTERNAL, MUTATING  -------------------

    
    
    
    function stageUnitPrice(address token, uint256 value) external;

    
    
    function rollbackUnitPrice(address token) external;

    
    
    function commitUnitPrice(address token) external;
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2021
pragma solidity ^0.8.9;




interface IConvexV1BaseRewardPoolAdapterErrors {
    
    ///      allowed in its corresponding Credit Manager
    error TokenIsNotAddedToCreditManagerException(address token);
}

interface ICreditFacadeEvents {
    
    ///      Credit Facade
    event OpenCreditAccount(
        address indexed onBehalfOf,
        address indexed creditAccount,
        uint256 borrowAmount,
        uint16 referralCode
    );

    
    event CloseCreditAccount(address indexed owner, address indexed to);

    
    event LiquidateCreditAccount(
        address indexed owner,
        address indexed liquidator,
        address indexed to,
        uint256 remainingFunds
    );

    
    event LiquidateExpiredCreditAccount(
        address indexed owner,
        address indexed liquidator,
        address indexed to,
        uint256 remainingFunds
    );

    
    event IncreaseBorrowedAmount(address indexed borrower, uint256 amount);

    
    event DecreaseBorrowedAmount(address indexed borrower, uint256 amount);

    
    event AddCollateral(
        address indexed onBehalfOf,
        address indexed token,
        uint256 value
    );

    
    event MultiCallStarted(address indexed borrower);

    
    event MultiCallFinished();

    
    event TransferAccount(address indexed oldOwner, address indexed newOwner);

    
    event TransferAccountAllowed(
        address indexed from,
        address indexed to,
        bool state
    );

    
    event TokenEnabled(address creditAccount, address token);

    
    event TokenDisabled(address creditAccount, address token);
}

interface ICreditFacadeExceptions is ICreditManagerV2Exceptions {
    
    ///      requires expirability
    error NotAllowedWhenNotExpirableException();

    
    ///      not allowed in whitelisted mode
    error NotAllowedInWhitelistedMode();

    
    error AccountTransferNotAllowedException();

    
    error CantLiquidateWithSuchHealthFactorException();

    
    error CantLiquidateNonExpiredException();

    
    error IncorrectCallDataException();

    
    ///      an account
    error ForbiddenDuringClosureException();

    
    error IncreaseAndDecreaseForbiddenInOneCallException();

    
    ///      during a multicall
    error UnknownMethodException();

    
    error IncreaseDebtForbiddenException();

    
    error CantTransferLiquidatableAccountException();

    
    error BorrowedBlockLimitException();

    
    error BorrowAmountOutOfLimitsException();

    
    ///      at the end of a multicall, if revertIfReceivedLessThan was called
    error BalanceLessThanMinimumDesiredException(address);

    
    error OpenAccountNotAllowedAfterExpirationException();

    
    error ExpectedBalancesAlreadySetException();

    
    ///      that is not allowed with any forbidden tokens enabled
    error ActionProhibitedWithForbiddenTokensException();
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2021
pragma solidity ^0.8.9;




interface ICurveV1AdapterExceptions {
    error IncorrectIndexException();
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2021
pragma solidity ^0.8.9;




interface IUniswapV3AdapterExceptions {
    error IncorrectPathLengthException();
}

interface IAdapter is IAdapterExceptions {
    
    function creditManager() external view returns (ICreditManagerV2);

    
    function creditFacade() external view returns (address);

    
    function targetContract() external view returns (address);

    
    function _gearboxAdapterType() external pure returns (AdapterType);

    
    function _gearboxAdapterVersion() external pure returns (uint16);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2021
pragma solidity ^0.8.9;




enum ClosureAction {
    CLOSE_ACCOUNT,
    LIQUIDATE_ACCOUNT,
    LIQUIDATE_EXPIRED_ACCOUNT,
    LIQUIDATE_PAUSED
}

interface ICreditManagerV2Events {
    
    event ExecuteOrder(address indexed borrower, address indexed target);

    
    event NewConfigurator(address indexed newConfigurator);
}


interface IPriceOracleV2 is
    IPriceOracleV2Events,
    IPriceOracleV2Exceptions,
    IVersion
{
    
    
    
    function convertToUSD(uint256 amount, address token)
        external
        view
        returns (uint256);

    
    
    
    function convertFromUSD(uint256 amount, address token)
        external
        view
        returns (uint256);

    
    ///
    
    
    
    function convert(
        uint256 amount,
        address tokenFrom,
        address tokenTo
    ) external view returns (uint256);

    
    
    
    
    
    
    
    function fastCheck(
        uint256 amountFrom,
        address tokenFrom,
        uint256 amountTo,
        address tokenTo
    ) external view returns (uint256 collateralFrom, uint256 collateralTo);

    
    
    function getPrice(address token) external view returns (uint256);

    
    
    function priceFeeds(address token)
        external
        view
        returns (address priceFeed);

    
    ///      with additional parameters
    
    function priceFeedsWithFlags(address token)
        external
        view
        returns (
            address priceFeed,
            bool skipCheck,
            uint256 decimals
        );
}

// 
pragma solidity ^0.8.9;


interface IBaseRewardPool {
    //
    // STATE CHANGING FUNCTIONS
    //

    function stake(uint256 _amount) external returns (bool);

    function stakeAll() external returns (bool);

    function stakeFor(address _for, uint256 _amount) external returns (bool);

    function withdraw(uint256 amount, bool claim) external returns (bool);

    function withdrawAll(bool claim) external;

    function withdrawAndUnwrap(uint256 amount, bool claim)
        external
        returns (bool);

    function withdrawAllAndUnwrap(bool claim) external;

    function getReward(address _account, bool _claimExtras)
        external
        returns (bool);

    function getReward() external returns (bool);

    function donate(uint256 _amount) external returns (bool);

    //
    // GETTERS
    //

    function earned(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function extraRewardsLength() external view returns (uint256);

    function lastTimeRewardApplicable() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);

    function rewardToken() external view returns (IERC20);

    function stakingToken() external view returns (IERC20);

    function duration() external view returns (uint256);

    function operator() external view returns (address);

    function rewardManager() external view returns (address);

    function pid() external view returns (uint256);

    function periodFinish() external view returns (uint256);

    function rewardRate() external view returns (uint256);

    function lastUpdateTime() external view returns (uint256);

    function rewardPerTokenStored() external view returns (uint256);

    function queuedRewards() external view returns (uint256);

    function currentRewards() external view returns (uint256);

    function historicalRewards() external view returns (uint256);

    function newRewardRatio() external view returns (uint256);

    function userRewardPerTokenPaid(address account)
        external
        view
        returns (uint256);

    function rewards(address account) external view returns (uint256);

    function extraRewards(uint256 i) external view returns (address);
}

// 
pragma solidity ^0.8.9;

interface ICurvePool {
    function coins(uint256 i) external view returns (address);

    function underlying_coins(uint256 i) external view returns (address);

    function balances(uint256 i) external view returns (uint256);

    function coins(int128) external view returns (address);

    function underlying_coins(int128) external view returns (address);

    function balances(int128) external view returns (uint256);

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;

    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function get_virtual_price() external view returns (uint256);

    function token() external view returns (address);

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_amount
    ) external;

    function A() external view returns (uint256);

    function A_precise() external view returns (uint256);

    function calc_withdraw_one_coin(uint256 _burn_amount, int128 i)
        external
        view
        returns (uint256);

    function admin_balances(uint256 i) external view returns (uint256);

    function admin() external view returns (address);

    function fee() external view returns (uint256);

    function admin_fee() external view returns (uint256);

    function block_timestamp_last() external view returns (uint256);

    function initial_A() external view returns (uint256);

    function future_A() external view returns (uint256);

    function initial_A_time() external view returns (uint256);

    function future_A_time() external view returns (uint256);

    // Some pools implement ERC20

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

// 
pragma solidity >=0.7.5;




interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    
    
    
    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    
    
    
    function exactInput(ExactInputParams calldata params)
        external
        payable
        returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    
    
    
    function exactOutputSingle(ExactOutputSingleParams calldata params)
        external
        payable
        returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    
    
    
    function exactOutput(ExactOutputParams calldata params)
        external
        payable
        returns (uint256 amountIn);
}

// 
pragma solidity 0.8.9;



interface IBaseValidator {
    
    
    struct ValidatorParams {
        IProtocolGovernance protocolGovernance;
    }

    
    function stagedValidatorParams() external view returns (ValidatorParams memory);

    
    function stagedValidatorParamsTimestamp() external view returns (uint256);

    
    function validatorParams() external view returns (ValidatorParams memory);

    
    
    function stageValidatorParams(ValidatorParams calldata newParams) external;

    
    function commitValidatorParams() external;
}

// 
pragma solidity 0.8.9;






interface IGearboxVault is IIntegrationVault {

    
    function creditFacade() external view returns (ICreditFacade);

    
    function creditManager() external view returns (ICreditManagerV2);

    
    function primaryToken() external view returns (address);

    
    function depositToken() external view returns (address);

    
    function helper() external view returns (GearboxHelper);

    
    /// For a vault with X usd of collateral and marginal factor T >= 1, total assets (collateral + debt) should be equal to X * T 
    function marginalFactorD9() external view returns (uint256);

    
    function merkleIndex() external view returns (uint256);

    
    function merkleTotalAmount() external view returns (uint256);

    
    function getMerkleProof() external view returns (bytes32[] memory);

    
    function poolId() external view returns (uint256);

    
    function primaryIndex() external view returns (int128);

    
    function convexOutputToken() external view returns (address);

    
    
    function addPoolsToAllowList(uint256[] calldata pools) external;

    
    
    function removePoolsFromAllowlist(uint256[] calldata pools) external;
    
    
    
    
    
    
    function initialize(uint256 nft_, address[] memory vaultTokens_, address helper_) external;

    
    
    function updateTargetMarginalFactor(uint256 marginalFactorD_) external;

    
    
    
    
    function setMerkleParameters(uint256 merkleIndex_, uint256 merkleTotalAmount_, bytes32[] memory merkleProof_) external;

    
    function adjustPosition() external;

    
    function openCreditAccount(address curveAdapter, address convexAdapter) external;

    
    function closeCreditAccount() external;

    
    /// Can be successfully called only by the helper
    function openCreditAccountInManager(uint256 currentPrimaryTokenAmount, uint16 referralCode) external;

    
    function getCreditAccount() external view returns (address);

    
    function getAllAssetsOnCreditAccountValue() external view returns (uint256 currentAllAssetsValue);

    
    function getClaimableRewardsValue() external view returns (uint256);

    
    /// Can be successfully called only by the helper
    function multicall(MultiCall[] memory calls) external;

    
    /// Can be successfully called only by the helper
    function swapExactOutput(ISwapRouter router, ISwapRouter.ExactOutputParams memory uniParams, address token, uint256 amount) external;
}

// 
pragma solidity 0.8.9;





interface IVaultGovernance {
    
    
    
    struct InternalParams {
        IProtocolGovernance protocolGovernance;
        IVaultRegistry registry;
        IVault singleton;
    }

    // -------------------  EXTERNAL, VIEW  -------------------

    
    
    function delayedStrategyParamsTimestamp(uint256 nft) external view returns (uint256);

    
    function delayedProtocolParamsTimestamp() external view returns (uint256);

    
    
    function delayedProtocolPerVaultParamsTimestamp(uint256 nft) external view returns (uint256);

    
    function internalParamsTimestamp() external view returns (uint256);

    
    function internalParams() external view returns (InternalParams memory);

    
    
    function stagedInternalParams() external view returns (InternalParams memory);

    // -------------------  EXTERNAL, MUTATING  -------------------

    
    
    function stageInternalParams(InternalParams memory newParams) external;

    
    function commitInternalParams() external;
}

// 
pragma solidity 0.8.9;
















/// ### ERC-721
///
/// Each Vault should be registered in VaultRegistry and get corresponding VaultRegistry NFT.
///
/// ### Access control
///
/// `push` and `pull` methods are only allowed for owner / approved person of the NFT. However,
/// `pull` for approved person also checks that pull destination is another vault of the Vault System.
///
/// The semantics is: NFT owner owns all Vault liquidity, Approved person is liquidity manager.
/// ApprovedForAll person cannot do anything except ERC-721 token transfers.
///
/// Both NFT owner and approved person can call externalCall method which claims liquidity mining rewards (if any)
///
/// `reclaimTokens` for claiming rewards given by an underlying protocol to erc20Vault in order to sell them there
abstract contract IntegrationVault is IIntegrationVault, ReentrancyGuard, Vault {
    using SafeERC20 for IERC20;

    // -------------------  EXTERNAL, VIEW  -------------------

    
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, Vault) returns (bool) {
        return
            super.supportsInterface(interfaceId) ||
            (interfaceId == type(IIntegrationVault).interfaceId) ||
            (interfaceId == type(IERC1271).interfaceId);
    }

    // -------------------  EXTERNAL, MUTATING  -------------------

    
    function push(
        address[] memory tokens,
        uint256[] memory tokenAmounts,
        bytes memory options
    ) public nonReentrant returns (uint256[] memory actualTokenAmounts) {
        uint256 nft_ = _nft;
        require(nft_ != 0, ExceptionsLibrary.INIT);
        IVaultRegistry vaultRegistry = _vaultGovernance.internalParams().registry;
        IVault ownerVault = IVault(vaultRegistry.ownerOf(nft_)); // Also checks that the token exists
        uint256 ownerNft = vaultRegistry.nftForVault(address(ownerVault));
        require(ownerNft != 0, ExceptionsLibrary.NOT_FOUND); // require deposits only through Vault
        uint256[] memory pTokenAmounts = _validateAndProjectTokens(tokens, tokenAmounts);
        uint256[] memory pActualTokenAmounts = _push(pTokenAmounts, options);
        actualTokenAmounts = CommonLibrary.projectTokenAmounts(tokens, _vaultTokens, pActualTokenAmounts);
        emit Push(pActualTokenAmounts);
    }

    
    function transferAndPush(
        address from,
        address[] memory tokens,
        uint256[] memory tokenAmounts,
        bytes memory options
    ) external returns (uint256[] memory actualTokenAmounts) {
        uint256 len = tokens.length;
        for (uint256 i = 0; i < len; ++i)
            if (tokenAmounts[i] != 0) {
                IERC20(tokens[i]).safeTransferFrom(from, address(this), tokenAmounts[i]);
            }

        actualTokenAmounts = push(tokens, tokenAmounts, options);
        for (uint256 i = 0; i < tokens.length; ++i) {
            uint256 leftover = actualTokenAmounts[i] < tokenAmounts[i] ? tokenAmounts[i] - actualTokenAmounts[i] : 0;
            if (leftover != 0) IERC20(tokens[i]).safeTransfer(from, leftover);
        }
    }

    
    function pull(
        address to,
        address[] memory tokens,
        uint256[] memory tokenAmounts,
        bytes memory options
    ) external nonReentrant returns (uint256[] memory actualTokenAmounts) {
        uint256 nft_ = _nft;
        require(nft_ != 0, ExceptionsLibrary.INIT);
        require(_isApprovedOrOwner(msg.sender), ExceptionsLibrary.FORBIDDEN); // Also checks that the token exists
        IVaultRegistry registry = _vaultGovernance.internalParams().registry;
        address owner = registry.ownerOf(nft_);
        IVaultRoot root = _root(registry, nft_, owner);
        if (owner != msg.sender) {
            address zeroVault = root.subvaultAt(0);
            if (zeroVault == address(this)) {
                // If we pull from zero vault
                require(
                    root.hasSubvault(registry.nftForVault(to)) && to != address(this),
                    ExceptionsLibrary.INVALID_TARGET
                );
            } else {
                // If we pull from other vault
                require(zeroVault == to, ExceptionsLibrary.INVALID_TARGET);
            }
        }
        uint256[] memory pTokenAmounts = _validateAndProjectTokens(tokens, tokenAmounts);
        uint256[] memory pActualTokenAmounts = _pull(to, pTokenAmounts, options);
        actualTokenAmounts = CommonLibrary.projectTokenAmounts(tokens, _vaultTokens, pActualTokenAmounts);
        emit Pull(to, actualTokenAmounts);
    }

    
    function reclaimTokens(address[] memory tokens)
        external
        virtual
        nonReentrant
        returns (uint256[] memory actualTokenAmounts)
    {
        uint256 nft_ = _nft;
        require(nft_ != 0, ExceptionsLibrary.INIT);
        IVaultGovernance.InternalParams memory params = _vaultGovernance.internalParams();
        IProtocolGovernance governance = params.protocolGovernance;
        IVaultRegistry registry = params.registry;
        address owner = registry.ownerOf(nft_);
        address to = _root(registry, nft_, owner).subvaultAt(0);
        actualTokenAmounts = new uint256[](tokens.length);
        if (to == address(this)) {
            return actualTokenAmounts;
        }
        for (uint256 i = 0; i < tokens.length; ++i) {
            if (
                _isReclaimForbidden(tokens[i]) ||
                !governance.hasPermission(tokens[i], PermissionIdsLibrary.ERC20_TRANSFER)
            ) {
                continue;
            }
            IERC20 token = IERC20(tokens[i]);
            actualTokenAmounts[i] = token.balanceOf(address(this));

            token.safeTransfer(to, actualTokenAmounts[i]);
        }
        emit ReclaimTokens(to, tokens, actualTokenAmounts);
    }

    
    function isValidSignature(bytes32 _hash, bytes memory _signature) external view returns (bytes4 magicValue) {
        IVaultGovernance.InternalParams memory params = _vaultGovernance.internalParams();
        IVaultRegistry registry = params.registry;
        IProtocolGovernance protocolGovernance = params.protocolGovernance;
        uint256 nft_ = _nft;
        if (nft_ == 0) {
            return 0xffffffff;
        }
        address strategy = registry.getApproved(nft_);
        if (!protocolGovernance.hasPermission(strategy, PermissionIdsLibrary.TRUSTED_STRATEGY)) {
            return 0xffffffff;
        }
        uint32 size;
        assembly {
            size := extcodesize(strategy)
        }
        if (size > 0) {
            if (IERC165(strategy).supportsInterface(type(IERC1271).interfaceId)) {
                return IERC1271(strategy).isValidSignature(_hash, _signature);
            } else {
                return 0xffffffff;
            }
        }
        if (CommonLibrary.recoverSigner(_hash, _signature) == strategy) {
            return 0x1626ba7e;
        }
        return 0xffffffff;
    }

    
    function externalCall(
        address to,
        bytes4 selector,
        bytes calldata data
    ) external payable nonReentrant returns (bytes memory result) {
        require(_nft != 0, ExceptionsLibrary.INIT);
        require(_isApprovedOrOwner(msg.sender), ExceptionsLibrary.FORBIDDEN);
        IProtocolGovernance protocolGovernance = _vaultGovernance.internalParams().protocolGovernance;
        IValidator validator = IValidator(protocolGovernance.validators(to));
        require(address(validator) != address(0), ExceptionsLibrary.FORBIDDEN);
        validator.validate(msg.sender, to, msg.value, selector, data);
        (bool res, bytes memory returndata) = to.call{value: msg.value}(abi.encodePacked(selector, data));
        if (!res) {
            assembly {
                let returndata_size := mload(returndata)
                // Bubble up revert reason
                revert(add(32, returndata), returndata_size)
            }
        }
        result = returndata;
    }

    // -------------------  INTERNAL, VIEW  -------------------

    function _validateAndProjectTokens(address[] memory tokens, uint256[] memory tokenAmounts)
        internal
        view
        returns (uint256[] memory pTokenAmounts)
    {
        require(CommonLibrary.isSortedAndUnique(tokens), ExceptionsLibrary.INVARIANT);
        require(tokens.length == tokenAmounts.length, ExceptionsLibrary.INVALID_VALUE);
        pTokenAmounts = CommonLibrary.projectTokenAmounts(_vaultTokens, tokens, tokenAmounts);
    }

    function _root(
        IVaultRegistry registry,
        uint256 thisNft,
        address thisOwner
    ) internal view returns (IVaultRoot) {
        uint256 thisOwnerNft = registry.nftForVault(thisOwner);
        require((thisNft != 0) && (thisOwnerNft != 0), ExceptionsLibrary.INIT);

        return IVaultRoot(thisOwner);
    }

    function _isApprovedOrOwner(address sender) internal view returns (bool) {
        IVaultRegistry registry = _vaultGovernance.internalParams().registry;
        uint256 nft_ = _nft;
        if (nft_ == 0) {
            return false;
        }
        return registry.getApproved(nft_) == sender || registry.ownerOf(nft_) == sender;
    }

    
    
    ///      for example to prevent YEarn tokens to reclaimed
    ///      if our vault is managing tokens, depositing it in YEarn
    
    
    function _isReclaimForbidden(address token) internal view virtual returns (bool);

    // -------------------  INTERNAL, MUTATING  -------------------

    /// Guaranteed to have exact signature matchinn vault tokens
    function _push(uint256[] memory tokenAmounts, bytes memory options)
        internal
        virtual
        returns (uint256[] memory actualTokenAmounts);

    /// Guaranteed to have exact signature matchinn vault tokens
    function _pull(
        address to,
        uint256[] memory tokenAmounts,
        bytes memory options
    ) internal virtual returns (uint256[] memory actualTokenAmounts);

    // --------------------------  EVENTS  --------------------------

    
    
    event Push(uint256[] tokenAmounts);

    
    
    
    event Pull(address to, uint256[] tokenAmounts);

    
    
    
    
    event ReclaimTokens(address to, address[] tokens, uint256[] tokenAmounts);
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;





/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// 
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        
        assembly {
            result := store
        }

        return result;
    }
}

interface IDegenDistributor is IDegenDistributorEvents {
    // Returns the address of the token distributed by this contract.
    function degenNFT() external view returns (IDegenNFT);

    // Returns the merkle root of the merkle tree containing account balances available to claim.
    function merkleRoot() external view returns (bytes32);

    
    function claimed(address user) external view returns (uint256);

    // Claim the given amount of the token to the given address. Reverts if the inputs are invalid.
    
    ///      or the total claimed amount for the account is more than the leaf amount.
    function claim(
        uint256 index,
        address account,
        uint256 totalAmount,
        bytes32[] calldata merkleProof
    ) external;
}

interface IDegenNFT is
    IDegenNFTExceptions,
    IDegenNFTEvents,
    IVersion,
    IERC721Metadata
{
    
    function minter() external view returns (address);

    
    function totalSupply() external view returns (uint256);

    
    function baseURI() external view returns (string memory);

    
    
    
    function mint(address to, uint256 amount) external;

    
    
    
    function burn(address from, uint256 amount) external;

    function setMinter(address minter_)
        external;
}

// 
pragma solidity 0.8.9;




interface IProtocolGovernance is IDefaultAccessControl, IUnitPricesGovernance {
    
    
    
    
    
    
    struct Params {
        uint256 maxTokensPerVault;
        uint256 governanceDelay;
        address protocolTreasury;
        uint256 forceAllowMask;
        uint256 withdrawLimit;
    }

    // -------------------  EXTERNAL, VIEW  -------------------

    
    
    
    function stagedPermissionGrantsTimestamps(address target) external view returns (uint256);

    
    
    
    function stagedPermissionGrantsMasks(address target) external view returns (uint256);

    
    
    
    function permissionMasks(address target) external view returns (uint256);

    
    
    function stagedParamsTimestamp() external view returns (uint256);

    
    function stagedParams() external view returns (Params memory);

    
    function params() external view returns (Params memory);

    
    function permissionAddresses() external view returns (address[] memory);

    
    function stagedPermissionGrantsAddresses() external view returns (address[] memory);

    
    
    
    function addressesByPermission(uint8 permissionId) external view returns (address[] memory);

    
    
    
    function hasPermission(address addr, uint8 permissionId) external view returns (bool);

    
    
    
    function hasAllPermissions(address target, uint8[] calldata permissionIds) external view returns (bool);

    
    function maxTokensPerVault() external view returns (uint256);

    
    function governanceDelay() external view returns (uint256);

    
    function protocolTreasury() external view returns (address);

    
    /// This bitmask is xored with ordinary mask.
    function forceAllowMask() external view returns (uint256);

    
    
    
    function withdrawLimit(address token) external view returns (uint256);

    
    function stagedValidatorsAddresses() external view returns (address[] memory);

    
    
    
    function stagedValidatorsTimestamps(address target) external view returns (uint256);

    
    
    
    function stagedValidators(address target) external view returns (address);

    
    function validatorsAddresses() external view returns (address[] memory);

    
    
    
    function validatorsAddress(uint256 i) external view returns (address);

    
    
    
    function validators(address target) external view returns (address);

    // -------------------  EXTERNAL, MUTATING, GOVERNANCE, IMMEDIATE  -------------------

    
    function rollbackStagedValidators() external;

    
    
    function revokeValidator(address target) external;

    
    
    
    function stageValidator(address target, address validator) external;

    
    
    
    function commitValidator(address target) external;

    
    
    function commitAllValidatorsSurpassedDelay() external returns (address[] memory);

    
    function rollbackStagedPermissionGrants() external;

    
    
    
    function commitPermissionGrants(address target) external;

    
    
    function commitAllPermissionGrantsSurpassedDelay() external returns (address[] memory);

    
    
    
    function revokePermissions(address target, uint8[] memory permissionIds) external;

    
    /// Reverts if governance delay has not passed yet.
    function commitParams() external;

    // -------------------  EXTERNAL, MUTATING, GOVERNANCE, DELAY  -------------------

    
    
    function stageParams(Params memory newParams) external;

    
    /// Resets commit delay and permissions if there are already staged permissions for this address.
    
    
    function stagePermissionGrants(address target, uint8[] memory permissionIds) external;
}

// 
pragma solidity =0.8.9;




interface IVaultRegistry is IERC721 {
    
    
    
    function vaultForNft(uint256 nftId) external view returns (address vault);

    
    
    
    function nftForVault(address vault) external view returns (uint256 nftId);

    
    
    
    function isLocked(uint256 nft) external view returns (bool);

    
    
    
    
    function registerVault(address vault, address owner) external returns (uint256 nft);

    
    function vaultsCount() external view returns (uint256);

    
    function vaults() external view returns (address[] memory);

    
    function protocolGovernance() external view returns (IProtocolGovernance);

    
    function stagedProtocolGovernance() external view returns (IProtocolGovernance);

    
    function stagedProtocolGovernanceTimestamp() external view returns (uint256);

    
    
    function stageProtocolGovernance(IProtocolGovernance newProtocolGovernance) external;

    
    function commitStagedProtocolGovernance() external;

    
    
    
    function lockNft(uint256 nft) external;
}

// 

pragma solidity 0.8.9;

interface IConvexToken {
    function totalSupply() external view returns (uint256);

    function reductionPerCliff() external view returns (uint256);

    function maxSupply() external view returns (uint256);

    function totalCliffs() external view returns (uint256);
}

// 
pragma solidity ^0.8.9;

interface ICurveGauge {
  function deposit(uint256) external;

  function balanceOf(address) external view returns (uint256);

  function withdraw(uint256) external;

  function claim_rewards() external;

  function reward_tokens(uint256) external view returns (address); //v2

  function rewarded_token() external view returns (address); //v1

  function lp_token() external view returns (address);
}

interface ICurveVoteEscrow {
  function create_lock(uint256, uint256) external;

  function increase_amount(uint256) external;

  function increase_unlock_time(uint256) external;

  function withdraw() external;

  function smart_wallet_checker() external view returns (address);
}

interface IWalletChecker {
  function check(address) external view returns (bool);
}

interface IVoting {
  function vote(
    uint256,
    bool,
    bool
  ) external; //voteId, support, executeIfDecided

  function getVote(uint256)
    external
    view
    returns (
      bool,
      bool,
      uint64,
      uint64,
      uint64,
      uint64,
      uint256,
      uint256,
      uint256,
      bytes memory
    );

  function vote_for_gauge_weights(address, uint256) external;
}

interface IMinter {
  function mint(address) external;
}

interface IRegistry {
  function get_registry() external view returns (address);

  function get_address(uint256 _id) external view returns (address);

  function gauge_controller() external view returns (address);

  function get_lp_token(address) external view returns (address);

  function get_gauges(address)
    external
    view
    returns (address[10] memory, uint128[10] memory);
}

interface IStaker {
  function deposit(address, address) external;

  function withdraw(address) external;

  function withdraw(
    address,
    address,
    uint256
  ) external;

  function withdrawAll(address, address) external;

  function createLock(uint256, uint256) external;

  function increaseAmount(uint256) external;

  function increaseTime(uint256) external;

  function release() external;

  function claimCrv(address) external returns (uint256);

  function claimRewards(address) external;

  function claimFees(address, address) external;

  function setStashAccess(address, bool) external;

  function vote(
    uint256,
    address,
    bool
  ) external;

  function voteGaugeWeight(address, uint256) external;

  function balanceOfPool(address) external view returns (uint256);

  function operator() external view returns (address);

  function execute(
    address _to,
    uint256 _value,
    bytes calldata _data
  ) external returns (bool, bytes memory);
}

interface IRewards {
  function stake(address, uint256) external;

  function stakeFor(address, uint256) external;

  function withdraw(address, uint256) external;

  function exit(address) external;

  function getReward(address) external;

  function queueNewRewards(uint256) external;

  function notifyRewardAmount(uint256) external;

  function addExtraReward(address) external;

  function stakingToken() external view returns (address);

  function rewardToken() external view returns (address);

  function earned(address account) external view returns (uint256);
}

interface IStash {
  function stashRewards() external returns (bool);

  function processStash() external returns (bool);

  function claimRewards() external returns (bool);

  function initialize(
    uint256 _pid,
    address _operator,
    address _staker,
    address _gauge,
    address _rewardFactory
  ) external;
}

interface IFeeDistro {
  function claim() external;

  function token() external view returns (address);
}

interface ITokenMinter {
  function mint(address, uint256) external;

  function burn(address, uint256) external;
}

interface IDeposit {
  function isShutdown() external view returns (bool);

  function balanceOf(address _account) external view returns (uint256);

  function totalSupply() external view returns (uint256);

  function poolInfo(uint256)
    external
    view
    returns (
      address,
      address,
      address,
      address,
      address,
      bool
    );

  function rewardClaimed(
    uint256,
    address,
    uint256
  ) external;

  function withdrawTo(
    uint256,
    uint256,
    address
  ) external;

  function claimRewards(uint256, address) external returns (bool);

  function rewardArbitrator() external returns (address);

  function setGaugeRedirect(uint256 _pid) external returns (bool);

  function owner() external returns (address);
}

interface ICrvDeposit {
  function deposit(uint256, bool) external;

  function lockIncentive() external view returns (uint256);
}

interface IRewardFactory {
  function setAccess(address, bool) external;

  function CreateCrvRewards(uint256, address) external returns (address);

  function CreateTokenRewards(
    address,
    address,
    address
  ) external returns (address);

  function activeRewardCount(address) external view returns (uint256);

  function addActiveReward(address, uint256) external returns (bool);

  function removeActiveReward(address, uint256) external returns (bool);
}

interface IStashFactory {
  function CreateStash(
    uint256,
    address,
    address,
    uint256
  ) external returns (address);
}

interface ITokenFactory {
  function CreateDepositToken(address) external returns (address);
}

interface IPools {
  function addPool(
    address _lptoken,
    address _gauge,
    uint256 _stashVersion
  ) external returns (bool);

  function forceAddPool(
    address _lptoken,
    address _gauge,
    uint256 _stashVersion
  ) external returns (bool);

  function shutdownPool(uint256 _pid) external returns (bool);

  function poolInfo(uint256)
    external
    view
    returns (
      address,
      address,
      address,
      address,
      address,
      bool
    );

  function poolLength() external view returns (uint256);

  function gaugeMap(address) external view returns (bool);

  function setPoolManager(address _poolM) external;
}

interface IVestedEscrow {
  function fund(address[] calldata _recipient, uint256[] calldata _amount)
    external
    returns (bool);
}

interface IConvexV1BaseRewardPoolAdapter is
    IAdapter,
    IBaseRewardPool,
    IConvexV1BaseRewardPoolAdapterErrors
{
    
    ///      staked in the adapter's targer Convex pool
    function curveLPtoken() external view returns (address);

    
    ///      a Credit Account's staked balance in a Convex
    ///      pool
    function stakedPhantomToken() external view returns (address);

    
    
    function extraReward1() external view returns (address);

    
    
    function extraReward2() external view returns (address);

    
    function cvx() external view returns (address);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2021
pragma solidity ^0.8.9;






interface ICreditFacadeExtended {
    
    ///      and compare with actual balances at the end of a multicall, reverts
    ///      if at least one is less than expected
    
    
    ///         itself and can only be used within a multicall
    function revertIfReceivedLessThan(Balance[] memory expected) external;

    
    
    
    ///         itself and can only be used within a multicall
    function disableToken(address token) external;
}

interface ICreditFacade is
    ICreditFacadeEvents,
    ICreditFacadeExceptions,
    IVersion
{
    //
    // CREDIT ACCOUNT MANAGEMENT
    //

    
    /// without any additional action.
    
    
    /// msg.sender != obBehalfOf
    
    /// as the user's own collateral, equivalent to 2x leverage.
    
    function openCreditAccount(
        uint256 amount,
        address onBehalfOf,
        uint16 leverageFactor,
        uint16 referralCode
    ) external payable;

    
    
    
    /// msg.sender != obBehalfOf
    
    /// at least a call to addCollateral, as otherwise the health check at the end will fail.
    
    function openCreditAccountMulticall(
        uint256 borrowedAmount,
        address onBehalfOf,
        MultiCall[] calldata calls,
        uint16 referralCode
    ) external payable;

    
    /// - Wraps ETH to WETH and sends it msg.sender if value > 0
    /// - Executes the multicall - the main purpose of a multicall when closing is to convert all assets to underlying
    /// in order to pay the debt.
    /// - Closes credit account:
    ///    + Checks the underlying balance: if it is greater than the amount paid to the pool, transfers the underlying
    ///      from the Credit Account and proceeds. If not, tries to transfer the shortfall from msg.sender.
    ///    + Transfers all enabled assets with non-zero balances to the "to" address, unless they are marked
    ///      to be skipped in skipTokenMask
    ///    + If convertWETH is true, converts WETH into ETH before sending to the recipient
    /// - Emits a CloseCreditAccount event
    ///
    
    
    
    
    function closeCreditAccount(
        address to,
        uint256 skipTokenMask,
        bool convertWETH,
        MultiCall[] calldata calls
    ) external payable;

    
    /// - Computes the total value and checks that hf < 1. An account can't be liquidated when hf >= 1.
    ///   Total value has to be computed before the multicall, otherwise the liquidator would be able
    ///   to manipulate it.
    /// - Wraps ETH to WETH and sends it to msg.sender (liquidator) if value > 0
    /// - Executes the multicall - the main purpose of a multicall when liquidating is to convert all assets to underlying
    ///   in order to pay the debt.
    /// - Liquidate credit account:
    ///    + Computes the amount that needs to be paid to the pool. If totalValue * liquidationDiscount < borrow + interest + fees,
    ///      only totalValue * liquidationDiscount has to be paid. Since liquidationDiscount < 1, the liquidator can take
    ///      totalValue * (1 - liquidationDiscount) as premium. Also computes the remaining funds to be sent to borrower
    ///      as totalValue * liquidationDiscount - amountToPool.
    ///    + Checks the underlying balance: if it is greater than amountToPool + remainingFunds, transfers the underlying
    ///      from the Credit Account and proceeds. If not, tries to transfer the shortfall from the liquidator.
    ///    + Transfers all enabled assets with non-zero balances to the "to" address, unless they are marked
    ///      to be skipped in skipTokenMask. If the liquidator is confident that all assets were converted
    ///      during the multicall, they can set the mask to uint256.max - 1, to only transfer the underlying
    ///    + If convertWETH is true, converts WETH into ETH before sending
    /// - Emits LiquidateCreditAccount event
    ///
    
    
    
    
    function liquidateCreditAccount(
        address borrower,
        address to,
        uint256 skipTokenMask,
        bool convertWETH,
        MultiCall[] calldata calls
    ) external payable;

    
    /// this Credit Facade is expired
    /// The general flow of liquidation is nearly the same as normal liquidations, with two main differences:
    ///     - An account can be liquidated on an expired Credit Facade even with hf > 1. However,
    ///       no accounts can be liquidated through this function if the Credit Facade is not expired.
    ///     - Liquidation premiums and fees for liquidating expired accounts are reduced.
    /// It is still possible to normally liquidate an underwater Credit Account, even when the Credit Facade
    /// is expired.
    
    
    
    
    
    function liquidateExpiredCreditAccount(
        address borrower,
        address to,
        uint256 skipTokenMask,
        bool convertWETH,
        MultiCall[] calldata calls
    ) external payable;

    
    /// - Borrows the requested amount from the pool
    /// - Updates the CA's borrowAmount / cumulativeIndexOpen
    ///   to correctly compute interest going forward
    /// - Performs a full collateral check
    ///
    
    function increaseDebt(uint256 amount) external;

    
    /// - Decreases the debt by paying the requested amount + accrued interest + fees back to the pool
    /// - It's also include to this payment interest accrued at the moment and fees
    /// - Updates cunulativeIndex to cumulativeIndex now
    ///
    
    function decreaseDebt(uint256 amount) external;

    
    
    
    
    function addCollateral(
        address onBehalfOf,
        address token,
        uint256 amount
    ) external payable;

    
    ///  - Wraps ETH and sends it back to msg.sender, if value > 0
    ///  - Executes the Multicall
    ///  - Performs a fullCollateralCheck to verify that hf > 1 after all actions
    
    function multicall(MultiCall[] calldata calls) external payable;

    
    
    function hasOpenedCreditAccount(address borrower)
        external
        view
        returns (bool);

    
    
    
    
    function approve(
        address targetContract,
        address token,
        uint256 amount
    ) external;

    
    
    
    function approveAccountTransfer(address from, bool state) external;

    
    
    function enableToken(address token) external;

    
    /// By default, this action is forbidden, and the user has to approve transfers from sender to itself
    /// by calling approveAccountTransfer.
    /// This is done to prevent malicious actors from transferring compromised accounts to other users.
    
    function transferAccountOwnership(address to) external;

    //
    // GETTERS
    //

    
    ///
    
    
    
    function calcTotalValue(address creditAccount)
        external
        view
        returns (uint256 total, uint256 twv);

    /**
     * @dev Calculates health factor for the credit account
     *
     *          sum(asset[i] * liquidation threshold[i])
     *   Hf = --------------------------------------------
     *         borrowed amount + interest accrued + fees
     *
     *
     * More info: https://dev.gearbox.fi/developers/credit/economy#health-factor
     *
     * @param creditAccount Credit account address
     * @return hf = Health factor in bp (see PERCENTAGE FACTOR in PercentageMath.sol)
     */
    function calcCreditAccountHealthFactor(address creditAccount)
        external
        view
        returns (uint256 hf);

    
    /// otherwise returns false
    
    function isTokenAllowed(address token) external view returns (bool);

    
    function creditManager() external view returns (ICreditManagerV2);

    
    
    
    function transfersAllowed(address from, address to)
        external
        view
        returns (bool);

    
    
    
    function params()
        external
        view
        returns (
            uint128 maxBorrowedAmountPerBlock,
            bool isIncreaseDebtForbidden,
            uint40 expirationDate
        );

    
    
    function limits()
        external
        view
        returns (uint128 minBorrowedAmount, uint128 maxBorrowedAmount);

    
    function degenNFT() external view returns (address);
}

interface ICurveV1Adapter is IAdapter, ICurvePool, ICurveV1AdapterExceptions {
    
    
    
    
    function exchange_all(
        int128 i,
        int128 j,
        uint256 rateMinRAY
    ) external;

    
    
    
    
    function exchange_all_underlying(
        int128 i,
        int128 j,
        uint256 rateMinRAY
    ) external;

    
    
    
    
    function add_liquidity_one_coin(
        uint256 amount,
        int128 i,
        uint256 minAmount
    ) external;

    
    
    
    function add_all_liquidity_one_coin(int128 i, uint256 rateMinRAY) external;

    
    
    
    function remove_all_liquidity_one_coin(int128 i, uint256 minRateRAY)
        external;

    //
    // GETTERS
    //

    
    function lp_token() external view returns (address);

    
    function metapoolBase() external view returns (address);

    
    function nCoins() external view returns (uint256);

    
    function token0() external view returns (address);

    
    function token1() external view returns (address);

    
    function token2() external view returns (address);

    
    function token3() external view returns (address);

    
    function underlying0() external view returns (address);

    
    function underlying1() external view returns (address);

    
    function underlying2() external view returns (address);

    
    function underlying3() external view returns (address);

    
    
    
    function calc_add_one_coin(uint256 amount, int128 i)
        external
        view
        returns (uint256);
}

interface IUniswapV3Adapter is
    IAdapter,
    ISwapRouter,
    IUniswapV3AdapterExceptions
{
    
    ///      which is unique to the Gearbox adapter
    
    
    
    
    
    ///                   used to calculate amountOutMin on the spot, since the input amount
    ///                   may not always be known in advance
    
    struct ExactAllInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        uint256 deadline;
        uint256 rateMinRAY;
        uint160 sqrtPriceLimitX96;
    }

    
    /// - Fills the `ExactInputSingleParams` struct
    /// - Makes a max allowance fast check call, passing the new struct as params
    
    function exactAllInputSingle(ExactAllInputSingleParams calldata params)
        external
        returns (uint256 amountOut);

    
    ///      which is unique to the Gearbox adapter
    
    ///             in the format TOKEN_FEE_TOKEN_FEE_TOKEN...
    
    
    ///                   used to calculate amountOutMin on the spot, since the input amount
    ///                   may not always be known in advance
    struct ExactAllInputParams {
        bytes path;
        uint256 deadline;
        uint256 rateMinRAY;
    }

    
    /// - Fills the `ExactAllInputParams` struct
    /// - Makes a max allowance fast check call, passing the new struct as `params`
    
    function exactAllInput(ExactAllInputParams calldata params)
        external
        returns (uint256 amountOut);
}


///         by the Credit Facade or allowed adapters. Users are not allowed to
///         interact with the Credit Manager directly
interface ICreditManagerV2 is
    ICreditManagerV2Events,
    ICreditManagerV2Exceptions,
    IVersion
{
    //
    // CREDIT ACCOUNT MANAGEMENT
    //

    
    /// - Takes Credit Account from the factory;
    /// - Requests the pool to lend underlying to the Credit Account
    ///
    
    
    function openCreditAccount(uint256 borrowedAmount, address onBehalfOf)
        external
        returns (address);

    
    /// - Checks whether the contract is paused, and, if so, if the payer is an emergency liquidator.
    ///   Only emergency liquidators are able to liquidate account while the CM is paused.
    ///   Emergency liquidations do not pay a liquidator premium or liquidation fees.
    /// - Calculates payments to various recipients on closure:
    ///    + Computes amountToPool, which is the amount to be sent back to the pool.
    ///      This includes the principal, interest and fees, but can't be more than
    ///      total position value
    ///    + Computes remainingFunds during liquidations - these are leftover funds
    ///      after paying the pool and the liquidator, and are sent to the borrower
    ///    + Computes protocol profit, which includes interest and liquidation fees
    ///    + Computes loss if the totalValue is less than borrow amount + interest
    /// - Checks the underlying token balance:
    ///    + if it is larger than amountToPool, then the pool is paid fully from funds on the Credit Account
    ///    + else tries to transfer the shortfall from the payer - either the borrower during closure, or liquidator during liquidation
    /// - Send assets to the "to" address, as long as they are not included into skipTokenMask
    /// - If convertWETH is true, the function converts WETH into ETH before sending
    /// - Returns the Credit Account back to factory
    ///
    
    
    
    
    
    
    
    function closeCreditAccount(
        address borrower,
        ClosureAction closureActionType,
        uint256 totalValue,
        address payer,
        address to,
        uint256 skipTokenMask,
        bool convertWETH
    ) external returns (uint256 remainingFunds);

    
    ///
    /// - Increase debt:
    ///   + Increases debt by transferring funds from the pool to the credit account
    ///   + Updates the cumulative index to keep interest the same. Since interest
    ///     is always computed dynamically as borrowedAmount * (cumulativeIndexNew / cumulativeIndexOpen - 1),
    ///     cumulativeIndexOpen needs to be updated, as the borrow amount has changed
    ///
    /// - Decrease debt:
    ///   + Repays debt partially + all interest and fees accrued thus far
    ///   + Updates cunulativeIndex to cumulativeIndex now
    ///
    
    
    
    
    function manageDebt(
        address creditAccount,
        uint256 amount,
        bool increase
    ) external returns (uint256 newBorrowedAmount);

    
    
    
    
    
    function addCollateral(
        address payer,
        address creditAccount,
        address token,
        uint256 amount
    ) external;

    
    
    
    function transferAccountOwnership(address from, address to) external;

    
    
    
    
    
    function approveCreditAccount(
        address borrower,
        address targetContract,
        address token,
        uint256 amount
    ) external;

    
    /// This is the intended pathway for state-changing interactions with 3rd-party protocols
    
    
    
    function executeOrder(
        address borrower,
        address targetContract,
        bytes memory data
    ) external returns (bytes memory);

    //
    // COLLATERAL VALIDITY AND ACCOUNT HEALTH CHECKS
    //

    
    /// into account health and total value calculations
    
    
    function checkAndEnableToken(address creditAccount, address token) external;

    
    
    ///         participate in the operation and computes a % change in weighted value between
    ///         inbound and outbound collateral. The cumulative negative change across several
    ///         swaps in sequence cannot be larger than feeLiquidation (a fee that the
    ///         protocol is ready to waive if needed). Since this records a % change
    ///         between just two tokens, the corresponding % change in TWV will always be smaller,
    ///         which makes this check safe.
    ///         More details at https://dev.gearbox.fi/docs/documentation/risk/fast-collateral-check#fast-check-protection
    
    
    
    
    
    function fastCollateralCheck(
        address creditAccount,
        address tokenIn,
        address tokenOut,
        uint256 balanceInBefore,
        uint256 balanceOutBefore
    ) external;

    
    /// value of all enabled collateral tokens
    
    function fullCollateralCheck(address creditAccount) external;

    
    ///      does not violate the maximal enabled token limit and tries
    ///      to disable unused tokens if it does
    
    function checkAndOptimizeEnabledTokens(address creditAccount) external;

    
    
    ///         but can also be called separately from the Credit Facade to remove
    ///         unwanted tokens
    function disableToken(address creditAccount, address token) external;

    //
    // GETTERS
    //

    
    
    function getCreditAccountOrRevert(address borrower)
        external
        view
        returns (address);

    
    
    
    ///        * CLOSE_ACCOUNT: The account is healthy and is closed normally
    ///        * LIQUIDATE_ACCOUNT: The account is unhealthy and is being liquidated to avoid bad debt
    ///        * LIQUIDATE_EXPIRED_ACCOUNT: The account has expired and is being liquidated (lowered liquidation premium)
    ///        * LIQUIDATE_PAUSED: The account is liquidated while the system is paused due to emergency (no liquidation premium)
    
    
    
    
    
    
    function calcClosePayments(
        uint256 totalValue,
        ClosureAction closureActionType,
        uint256 borrowedAmount,
        uint256 borrowedAmountWithInterest
    )
        external
        view
        returns (
            uint256 amountToPool,
            uint256 remainingFunds,
            uint256 profit,
            uint256 loss
        );

    
    
    
    
    
    function calcCreditAccountAccruedInterest(address creditAccount)
        external
        view
        returns (
            uint256 borrowedAmount,
            uint256 borrowedAmountWithInterest,
            uint256 borrowedAmountWithInterestAndFees
        );

    
    /// Only enabled tokens are counted as collateral for the Credit Account
    
    ///         the bit at the position equal to token's index to 1
    function enabledTokensMap(address creditAccount)
        external
        view
        returns (uint256);

    
    ///      the last full check, in RAY format
    function cumulativeDropAtFastCheckRAY(address creditAccount)
        external
        view
        returns (uint256);

    
    
    function collateralTokens(uint256 id)
        external
        view
        returns (address token, uint16 liquidationThreshold);

    
    
    function collateralTokensByMask(uint256 tokenMask)
        external
        view
        returns (address token, uint16 liquidationThreshold);

    
    function collateralTokensCount() external view returns (uint256);

    
    
    function tokenMasksMap(address token) external view returns (uint256);

    
    function forbiddenTokenMask() external view returns (uint256);

    
    function adapterToContract(address adapter) external view returns (address);

    
    function contractToAdapter(address targetContract)
        external
        view
        returns (address);

    
    function underlying() external view returns (address);

    
    function pool() external view returns (address);

    
    
    function poolService() external view returns (address);

    
    function creditAccounts(address borrower) external view returns (address);

    
    function creditConfigurator() external view returns (address);

    
    function wethAddress() external view returns (address);

    
    
    function liquidationThresholds(address token)
        external
        view
        returns (uint16);

    
    function maxAllowedEnabledTokenLength() external view returns (uint8);

    
    
    /// that are able to liquidate positions while the contracts are paused,
    /// e.g. when there is a risk of bad debt while an exploit is being patched.
    /// In the interest of fairness, emergency liquidators do not receive a premium
    /// And are compensated by the Gearbox DAO separately.
    function canLiquidateWhilePaused(address) external view returns (bool);

    
    
    
    ///         during unhealthy account liquidations
    
    ///         allowing the liquidator to take the unaccounted for remainder as premium. Equal to (1 - liquidationPremium)
    
    ///         during expired account liquidations
    
    ///         allowing the liquidator to take the unaccounted for remainder as premium. Equal to (1 - liquidationPremiumExpired)
    function fees()
        external
        view
        returns (
            uint16 feeInterest,
            uint16 feeLiquidation,
            uint16 liquidationDiscount,
            uint16 feeLiquidationExpired,
            uint16 liquidationDiscountExpired
        );

    
    function creditFacade() external view returns (address);

    
    function priceOracle() external view returns (IPriceOracleV2);

    
    function universalAdapter() external view returns (address);

    
    function version() external view returns (uint256);
}

interface IPriceOracleV2Ext is IPriceOracleV2 {
    
    
    
    function addPriceFeed(address token, address priceFeed) external;
}

// 
pragma solidity ^0.8.9;

interface IBooster {
    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        address stash;
        bool shutdown;
    }

    function deposit(
        uint256 _pid,
        uint256 _amount,
        bool _stake
    ) external returns (bool);

    function depositAll(uint256 _pid, bool _stake) external returns (bool);

    function withdraw(uint256 _pid, uint256 _amount) external returns (bool);

    function withdrawAll(uint256 _pid) external returns (bool);

    // function earmarkRewards(uint256 _pid) external returns (bool);

    // function earmarkFees() external returns (bool);

    //
    // GETTERS
    //

    function poolInfo(uint256 i) external view returns (PoolInfo memory);

    function poolLength() external view returns (uint256);

    function staker() external view returns (address);

    function minter() external view returns (address);

    function crv() external view returns (address);

    function registry() external view returns (address);

    function stakerRewards() external view returns (address);

    function lockRewards() external view returns (address);

    function lockFees() external view returns (address);
}

// 
// Gearbox Protocol. Generalized leverage for DeFi protocols
// (c) Gearbox Holdings, 2021
pragma solidity ^0.8.9;

struct Balance {
    address token;
    uint256 balance;
}

library BalanceOps {
    error UnknownToken(address);

    function copyBalance(Balance memory b)
        internal
        pure
        returns (Balance memory)
    {
        return Balance({ token: b.token, balance: b.balance });
    }

    function addBalance(
        Balance[] memory b,
        address token,
        uint256 amount
    ) internal pure {
        b[getIndex(b, token)].balance += amount;
    }

    function subBalance(
        Balance[] memory b,
        address token,
        uint256 amount
    ) internal pure {
        b[getIndex(b, token)].balance -= amount;
    }

    function getBalance(Balance[] memory b, address token)
        internal
        pure
        returns (uint256 amount)
    {
        return b[getIndex(b, token)].balance;
    }

    function setBalance(
        Balance[] memory b,
        address token,
        uint256 amount
    ) internal pure {
        b[getIndex(b, token)].balance = amount;
    }

    function getIndex(Balance[] memory b, address token)
        internal
        pure
        returns (uint256 index)
    {
        for (uint256 i; i < b.length; ) {
            if (b[i].token == token) {
                return i;
            }

            unchecked {
                ++i;
            }
        }
        revert UnknownToken(token);
    }

    function copy(Balance[] memory b, uint256 len)
        internal
        pure
        returns (Balance[] memory res)
    {
        res = new Balance[](len);
        for (uint256 i; i < len; ) {
            res[i] = copyBalance(b[i]);
            unchecked {
                ++i;
            }
        }
    }

    function clone(Balance[] memory b)
        internal
        pure
        returns (Balance[] memory)
    {
        return copy(b, b.length);
    }

    function getModifiedAfterSwap(
        Balance[] memory b,
        address tokenFrom,
        uint256 amountFrom,
        address tokenTo,
        uint256 amountTo
    ) internal pure returns (Balance[] memory res) {
        res = copy(b, b.length);
        setBalance(res, tokenFrom, getBalance(b, tokenFrom) - amountFrom);
        setBalance(res, tokenTo, getBalance(b, tokenTo) + amountTo);
    }
}

// 
pragma solidity ^0.8.9;

struct MultiCall {
    address target;
    bytes callData;
}

library MultiCallOps {
    function copyMulticall(MultiCall memory call)
        internal
        pure
        returns (MultiCall memory)
    {
        return MultiCall({ target: call.target, callData: call.callData });
    }

    function trim(MultiCall[] memory calls)
        internal
        pure
        returns (MultiCall[] memory trimmed)
    {
        uint256 len = calls.length;

        if (len == 0) return calls;

        uint256 foundLen;
        while (calls[foundLen].target != address(0)) {
            unchecked {
                ++foundLen;
                if (foundLen == len) return calls;
            }
        }

        if (foundLen > 0) return copy(calls, foundLen);
    }

    function copy(MultiCall[] memory calls, uint256 len)
        internal
        pure
        returns (MultiCall[] memory res)
    {
        res = new MultiCall[](len);
        for (uint256 i; i < len; ) {
            res[i] = copyMulticall(calls[i]);
            unchecked {
                ++i;
            }
        }
    }

    function clone(MultiCall[] memory calls)
        internal
        pure
        returns (MultiCall[] memory res)
    {
        return copy(calls, calls.length);
    }

    function append(MultiCall[] memory calls, MultiCall memory newCall)
        internal
        pure
        returns (MultiCall[] memory res)
    {
        uint256 len = calls.length;
        res = new MultiCall[](len + 1);
        for (uint256 i; i < len; ) {
            res[i] = copyMulticall(calls[i]);
            unchecked {
                ++i;
            }
        }
        res[len] = copyMulticall(newCall);
    }

    function prepend(MultiCall[] memory calls, MultiCall memory newCall)
        internal
        pure
        returns (MultiCall[] memory res)
    {
        uint256 len = calls.length;
        res = new MultiCall[](len + 1);
        res[0] = copyMulticall(newCall);

        for (uint256 i = 1; i < len + 1; ) {
            res[i] = copyMulticall(calls[i]);
            unchecked {
                ++i;
            }
        }
    }

    function concat(MultiCall[] memory calls1, MultiCall[] memory calls2)
        internal
        pure
        returns (MultiCall[] memory res)
    {
        uint256 len1 = calls1.length;
        uint256 lenTotal = len1 + calls2.length;

        if (lenTotal == calls1.length) return clone(calls1);
        if (lenTotal == calls2.length) return clone(calls2);

        res = new MultiCall[](lenTotal);

        for (uint256 i; i < lenTotal; ) {
            res[i] = (i < len1)
                ? copyMulticall(calls1[i])
                : copyMulticall(calls2[i - len1]);
            unchecked {
                ++i;
            }
        }
    }
}

// 
pragma solidity 0.8.9;




interface IValidator is IBaseValidator, IERC165 {
    // @notice Validate if call can be made to external contract.
    // @dev Reverts if validation failed. Returns nothing if validation is ok
    // @param sender Sender of the externalCall method
    // @param addr Address of the called contract
    // @param value Ether value for the call
    // @param selector Selector of the called method
    // @param data Call data after selector
    function validate(
        address sender,
        address addr,
        uint256 value,
        bytes4 selector,
        bytes calldata data
    ) external view;
}

// 
pragma solidity 0.8.9;




interface IGearboxVaultGovernance is IVaultGovernance {

    
    
    
    
    
    
    
    
    struct DelayedProtocolParams {
        address crv3Pool;
        address crv;
        address cvx;
        uint256 maxSlippageD9;
        uint256 maxSmallPoolsSlippageD9;
        uint256 maxCurveSlippageD9;
        address uniswapRouter;
    }

    
    
    
    
    
    
    
    struct DelayedProtocolPerVaultParams {
        address primaryToken;
        address univ3Adapter;
        address facade;
        uint256 withdrawDelay;
        uint256 initialMarginalValueD9;
        uint16 referralCode;
    }

    
    
    struct StrategyParams {
        uint24 largePoolFeeUsed;
    }

    // -------------------  EXTERNAL, VIEW  -------------------

    
    function delayedProtocolParams() external view returns (DelayedProtocolParams memory);

    
    function stagedDelayedProtocolParams() external view returns (DelayedProtocolParams memory);

    
    
    function stagedDelayedProtocolPerVaultParams(uint256 nft)
        external
        view
        returns (DelayedProtocolPerVaultParams memory);

    
    
    function delayedProtocolPerVaultParams(uint256 nft) external view returns (DelayedProtocolPerVaultParams memory);

    
    function strategyParams(uint256 nft) external view returns (StrategyParams memory);

    // -------------------  EXTERNAL, MUTATING  -------------------

    
    
    
    function stageDelayedProtocolParams(DelayedProtocolParams memory params) external;

    
    function commitDelayedProtocolParams() external;

    
    
    
    function stageDelayedProtocolPerVaultParams(uint256 nft, DelayedProtocolPerVaultParams calldata params) external;

    
    
    
    function commitDelayedProtocolPerVaultParams(uint256 nft) external;

    
    
    function setStrategyParams(uint256 nft, StrategyParams calldata params) external;

    
    
    
    
    function createVault(address[] memory vaultTokens_, address owner_, address helper_)
        external
        returns (IGearboxVault vault, uint256 nft);
}

// 
pragma solidity 0.8.9;

interface IVaultRoot {
    
    
    
    function hasSubvault(uint256 nft_) external view returns (bool);

    
    
    
    function subvaultAt(uint256 index) external view returns (address);

    
    
    
    function subvaultOneBasedIndex(uint256 nft_) external view returns (uint256);

    
    
    function subvaultNfts() external view returns (uint256[] memory);
}

// 
pragma solidity 0.8.9;





library CommonLibrary {
    uint256 constant DENOMINATOR = 10**9;
    uint256 constant D18 = 10**18;
    uint256 constant YEAR = 365 * 24 * 3600;
    uint256 constant Q128 = 2**128;
    uint256 constant Q96 = 2**96;
    uint256 constant Q48 = 2**48;
    uint256 constant Q160 = 2**160;
    uint256 constant UNI_FEE_DENOMINATOR = 10**6;

    
    
    function sortUint(uint256[] memory arr) internal pure {
        uint256 l = arr.length;
        for (uint256 i = 0; i < l; ++i) {
            for (uint256 j = i + 1; j < l; ++j) {
                if (arr[i] > arr[j]) {
                    uint256 temp = arr[i];
                    arr[i] = arr[j];
                    arr[j] = temp;
                }
            }
        }
    }

    
    
    
    function isSortedAndUnique(address[] memory tokens) internal pure returns (bool) {
        if (tokens.length < 2) {
            return true;
        }
        for (uint256 i = 0; i < tokens.length - 1; ++i) {
            if (tokens[i] >= tokens[i + 1]) {
                return false;
            }
        }
        return true;
    }

    
    
    /// Requires both sets of tokens to be sorted. When tokens are not sorted, it's undefined behavior.
    /// If there is a token in tokensToProject that is not part of tokens and corresponding tokenAmountsToProject > 0, reverts.
    /// Zero token amount is eqiuvalent to missing token
    function projectTokenAmounts(
        address[] memory tokens,
        address[] memory tokensToProject,
        uint256[] memory tokenAmountsToProject
    ) internal pure returns (uint256[] memory) {
        uint256[] memory res = new uint256[](tokens.length);
        uint256 t = 0;
        uint256 tp = 0;
        while ((t < tokens.length) && (tp < tokensToProject.length)) {
            if (tokens[t] < tokensToProject[tp]) {
                res[t] = 0;
                t++;
            } else if (tokens[t] > tokensToProject[tp]) {
                if (tokenAmountsToProject[tp] == 0) {
                    tp++;
                } else {
                    revert("TPS");
                }
            } else {
                res[t] = tokenAmountsToProject[tp];
                t++;
                tp++;
            }
        }
        while (t < tokens.length) {
            res[t] = 0;
            t++;
        }
        return res;
    }

    
    
    
    function sqrtX96(uint256 xX96) internal pure returns (uint256) {
        uint256 sqX96 = sqrt(xX96);
        return sqX96 << 48;
    }

    
    
    
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }

    
    
    
    
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    
    
    
    
    
    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, ExceptionsLibrary.INVALID_LENGTH);

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}

// 
pragma solidity 0.8.9;


library ExceptionsLibrary {
    string constant ADDRESS_ZERO = "AZ";
    string constant VALUE_ZERO = "VZ";
    string constant EMPTY_LIST = "EMPL";
    string constant NOT_FOUND = "NF";
    string constant INIT = "INIT";
    string constant DUPLICATE = "DUP";
    string constant NULL = "NULL";
    string constant TIMESTAMP = "TS";
    string constant FORBIDDEN = "FRB";
    string constant ALLOWLIST = "ALL";
    string constant LIMIT_OVERFLOW = "LIMO";
    string constant LIMIT_UNDERFLOW = "LIMU";
    string constant INVALID_VALUE = "INV";
    string constant INVARIANT = "INVA";
    string constant INVALID_TARGET = "INVTR";
    string constant INVALID_TOKEN = "INVTO";
    string constant INVALID_INTERFACE = "INVI";
    string constant INVALID_SELECTOR = "INVS";
    string constant INVALID_STATE = "INVST";
    string constant INVALID_LENGTH = "INVL";
    string constant LOCK = "LCKD";
    string constant DISABLED = "DIS";
}

//
pragma solidity 0.8.9;


library PermissionIdsLibrary {
    // The msg.sender is allowed to register vault
    uint8 constant REGISTER_VAULT = 0;
    // The msg.sender is allowed to create vaults
    uint8 constant CREATE_VAULT = 1;
    // The token is allowed to be transfered by vault
    uint8 constant ERC20_TRANSFER = 2;
    // The token is allowed to be added to vault
    uint8 constant ERC20_VAULT_TOKEN = 3;
    // Trusted protocols that are allowed to be approved of vault ERC20 tokens by any strategy
    uint8 constant ERC20_APPROVE = 4;
    // Trusted protocols that are allowed to be approved of vault ERC20 tokens by trusted strategy
    uint8 constant ERC20_APPROVE_RESTRICTED = 5;
    // Strategy allowed using restricted API
    uint8 constant TRUSTED_STRATEGY = 6;
}

// 
pragma solidity =0.8.9;




library FullMath {
    
    
    
    
    
    
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // diff: original lib works under 0.7.6 with overflows enabled
        unchecked {
            // 512-bit multiply [prod1 prod0] = a * b
            // Compute the product mod 2**256 and mod 2**256 - 1
            // then use the Chinese Remainder Theorem to reconstruct
            // the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2**256 + prod0
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division
            if (prod1 == 0) {
                require(denominator > 0);
                assembly {
                    result := div(prod0, denominator)
                }
                return result;
            }

            // Make sure the result is less than 2**256.
            // Also prevents denominator == 0
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0]
            // Compute remainder using mulmod
            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
            }
            // Subtract 256 bit number from 512 bit number
            assembly {
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator
            // Compute largest power of two divisor of denominator.
            // Always >= 1.
            // diff: original uint256 twos = -denominator & denominator;
            uint256 twos = uint256(-int256(denominator)) & denominator;
            // Divide denominator by power of two
            assembly {
                denominator := div(denominator, twos)
            }

            // Divide [prod1 prod0] by the factors of two
            assembly {
                prod0 := div(prod0, twos)
            }
            // Shift in bits from prod1 into prod0. For this we need
            // to flip `twos` such that it is 2**256 / twos.
            // If twos is zero, then it becomes one
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            // Invert denominator mod 2**256
            // Now that denominator is an odd number, it has an inverse
            // modulo 2**256 such that denominator * inv = 1 mod 2**256.
            // Compute the inverse by starting with a seed that is correct
            // correct for four bits. That is, denominator * inv = 1 mod 2**4
            uint256 inv = (3 * denominator) ^ 2;
            // Now use Newton-Raphson iteration to improve the precision.
            // Thanks to Hensel's lifting lemma, this also works in modular
            // arithmetic, doubling the correct bits in each step.
            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            // Because the division is now exact we can divide by multiplying
            // with the modular inverse of denominator. This will give us the
            // correct result modulo 2**256. Since the precoditions guarantee
            // that the outcome is less than 2**256, this is the final result.
            // We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inv;
            return result;
        }
    }

    
    
    
    
    
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // diff: original lib works under 0.7.6 with overflows enabled
        unchecked {
            result = mulDiv(a, b, denominator);
            if (mulmod(a, b, denominator) > 0) {
                require(result < type(uint256).max);
                result++;
            }
        }
    }
}

// 
pragma solidity 0.8.9;














contract GearboxHelper {
    using SafeERC20 for IERC20;

    uint256 public constant D9 = 10**9;
    uint256 public constant D27 = 10**27;
    bytes4 public constant GET_REWARD_SELECTOR = 0x7050ccd9;

    ICreditFacade public creditFacade;
    ICreditManagerV2 public creditManager;

    address public curveAdapter;
    address public convexAdapter;
    address public primaryToken;
    address public depositToken;

    bool public parametersSet;
    bool public is3crv;
    int128 crv3Index;

    IGearboxVault public gearboxVault;

    uint256 public vaultNft;

    function setParameters(
        ICreditFacade creditFacade_,
        ICreditManagerV2 creditManager_,
        address primaryToken_,
        address depositToken_,
        uint256 nft_
    ) external {
        require(!parametersSet, ExceptionsLibrary.FORBIDDEN);
        creditFacade = creditFacade_;
        creditManager = creditManager_;
        primaryToken = primaryToken_;
        depositToken = depositToken_;
        vaultNft = nft_;

        parametersSet = true;
        gearboxVault = IGearboxVault(msg.sender);
    }

    function setAdapters(address curveAdapter_, address convexAdapter_) external {
        require(msg.sender == address(gearboxVault), ExceptionsLibrary.FORBIDDEN);
        curveAdapter = curveAdapter_;
        convexAdapter = convexAdapter_;
    }

    function calcTvl(address creditAccount, address vaultGovernance) external view returns (uint256) {
        address depositToken_ = depositToken;
        address primaryToken_ = primaryToken;
        ICreditManagerV2 creditManager_ = creditManager;

        uint256 primaryTokenAmount = calculateClaimableRewards(creditAccount, vaultGovernance);

        if (primaryToken_ != depositToken_) {
            primaryTokenAmount += IERC20(primaryToken_).balanceOf(address(gearboxVault));
        }

        if (creditAccount != address(0)) {
            (uint256 currentAllAssetsValue, ) = creditFacade.calcTotalValue(creditAccount);
            (, , uint256 borrowAmountWithInterestAndFees) = creditManager_.calcCreditAccountAccruedInterest(
                creditAccount
            );

            if (currentAllAssetsValue >= borrowAmountWithInterestAndFees) {
                primaryTokenAmount += currentAllAssetsValue - borrowAmountWithInterestAndFees;
            }
        }

        if (primaryToken_ == depositToken_) {
            return primaryTokenAmount + IERC20(depositToken_).balanceOf(address(gearboxVault));
        } else {
            IPriceOracleV2 oracle = IPriceOracleV2(creditManager_.priceOracle());
            return
                oracle.convert(primaryTokenAmount, primaryToken_, depositToken_) +
                IERC20(depositToken_).balanceOf(address(gearboxVault));
        }
    }

    function verifyInstances(address vaultGovernance)
        external
        returns (
            int128 primaryIndex,
            address convexOutputToken,
            uint256 poolId
        )
    {
        require(msg.sender == address(gearboxVault), ExceptionsLibrary.FORBIDDEN);
        IGearboxVaultGovernance.DelayedProtocolParams memory protocolParams = IGearboxVaultGovernance(vaultGovernance)
            .delayedProtocolParams();

        ICurveV1Adapter curveAdapter_ = ICurveV1Adapter(curveAdapter);
        IConvexV1BaseRewardPoolAdapter convexAdapter_ = IConvexV1BaseRewardPoolAdapter(convexAdapter);

        poolId = convexAdapter_.pid();
        address primaryToken_ = primaryToken;

        require(creditFacade.isTokenAllowed(primaryToken_), ExceptionsLibrary.INVALID_TOKEN);

        bool havePrimaryTokenInCurve = false;
        is3crv = false;

        for (uint256 i = 0; i < curveAdapter_.nCoins(); ++i) {
            address tokenI = curveAdapter_.coins(i);
            if (tokenI == primaryToken_) {
                primaryIndex = int128(int256(i));
                havePrimaryTokenInCurve = true;
            }
        }

        if (!havePrimaryTokenInCurve) {
            ICurveV1Adapter crv3Adapter = ICurveV1Adapter(creditManager.contractToAdapter(protocolParams.crv3Pool));
            address crv3Token = crv3Adapter.lp_token();

            for (uint256 i = 0; i < curveAdapter_.nCoins(); ++i) {
                address tokenI = curveAdapter_.coins(i);
                if (tokenI == crv3Token) {
                    crv3Index = int128(uint128(i));
                    is3crv = true;
                    for (uint256 j = 0; j < 3; ++j) {
                        address tokenJ = crv3Adapter.coins(j);
                        if (tokenJ == primaryToken_) {
                            primaryIndex = int128(int256(j));
                            havePrimaryTokenInCurve = true;
                        }
                    }
                }
            }
        }

        require(havePrimaryTokenInCurve, ExceptionsLibrary.INVALID_TOKEN);

        convexOutputToken = address(convexAdapter_.stakedPhantomToken());
        require(curveAdapter_.lp_token() == convexAdapter_.curveLPtoken(), ExceptionsLibrary.INVALID_TARGET);
    }

    function calculateEarnedCvxAmountByEarnedCrvAmount(uint256 crvAmount, address cvxTokenAddress)
        public
        view
        returns (uint256)
    {
        IConvexToken cvxToken = IConvexToken(cvxTokenAddress);

        unchecked {
            uint256 supply = cvxToken.totalSupply();

            uint256 cliff = supply / cvxToken.reductionPerCliff();
            uint256 totalCliffs = cvxToken.totalCliffs();

            if (cliff < totalCliffs) {
                uint256 reduction = totalCliffs - cliff;
                uint256 cvxAmount = FullMath.mulDiv(crvAmount, reduction, totalCliffs);

                uint256 amtTillMax = cvxToken.maxSupply() - supply;
                if (cvxAmount > amtTillMax) {
                    cvxAmount = amtTillMax;
                }

                return cvxAmount;
            }

            return 0;
        }
    }

    function calculateClaimableRewards(address creditAccount, address vaultGovernance) public view returns (uint256) {
        if (creditAccount == address(0)) {
            return 0;
        }

        uint256 earnedCrvAmount = IConvexV1BaseRewardPoolAdapter(convexAdapter).earned(creditAccount);
        IPriceOracleV2 oracle = IPriceOracleV2(creditManager.priceOracle());

        IGearboxVaultGovernance.DelayedProtocolParams memory protocolParams = IGearboxVaultGovernance(vaultGovernance)
            .delayedProtocolParams();

        uint256 valueCrvToUsd = oracle.convertToUSD(earnedCrvAmount, protocolParams.crv);
        uint256 valueCvxToUsd = oracle.convertToUSD(
            calculateEarnedCvxAmountByEarnedCrvAmount(earnedCrvAmount, protocolParams.cvx),
            protocolParams.cvx
        );

        uint256 valueExtraToUsd = 0;

        IBaseRewardPool underlyingContract = IBaseRewardPool(creditManager.adapterToContract(convexAdapter));
        for (uint256 i = 0; i < underlyingContract.extraRewardsLength(); ++i) {
            IRewards rewardsContract = IRewards(underlyingContract.extraRewards(i));
            uint256 valueEarned = rewardsContract.earned(creditAccount);
            valueExtraToUsd += oracle.convertToUSD(valueEarned, rewardsContract.rewardToken());
        }

        return oracle.convertFromUSD(valueCrvToUsd + valueCvxToUsd + valueExtraToUsd, primaryToken);
    }

    function calculateDesiredTotalValue(
        address creditAccount,
        address vaultGovernance,
        uint256 marginalFactorD9
    ) external view returns (uint256 expectedAllAssetsValue, uint256 currentAllAssetsValue) {
        (currentAllAssetsValue, ) = creditFacade.calcTotalValue(creditAccount);
        currentAllAssetsValue += calculateClaimableRewards(creditAccount, vaultGovernance);

        (, , uint256 borrowAmountWithInterestAndFees) = creditManager.calcCreditAccountAccruedInterest(creditAccount);

        uint256 currentTvl = currentAllAssetsValue - borrowAmountWithInterestAndFees;
        expectedAllAssetsValue = FullMath.mulDiv(currentTvl, marginalFactorD9, D9);
    }

    function calcConvexTokensToWithdraw(
        uint256 desiredValueNominatedUnderlying,
        address creditAccount,
        address convexOutputToken
    ) public view returns (uint256) {
        uint256 currentConvexTokensAmount = IERC20(convexOutputToken).balanceOf(creditAccount);

        IPriceOracleV2 oracle = IPriceOracleV2(creditManager.priceOracle());
        uint256 valueInConvexNominatedUnderlying = oracle.convert(
            currentConvexTokensAmount,
            convexOutputToken,
            primaryToken
        );

        if (desiredValueNominatedUnderlying >= valueInConvexNominatedUnderlying) {
            return currentConvexTokensAmount;
        }

        return
            FullMath.mulDiv(
                currentConvexTokensAmount,
                desiredValueNominatedUnderlying,
                valueInConvexNominatedUnderlying
            );
    }

    function calcRateRAY(address tokenFrom, address tokenTo) public view returns (uint256) {
        IPriceOracleV2 oracle = IPriceOracleV2(creditManager.priceOracle());
        return oracle.convert(D27, tokenFrom, tokenTo);
    }

    function calculateAmountInMaximum(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 maxSlippageD9
    ) public view returns (uint256) {
        uint256 rateRAY = calcRateRAY(toToken, fromToken);
        uint256 amountInExpected = FullMath.mulDiv(amount, rateRAY, D27) + 1;
        return FullMath.mulDiv(amountInExpected, D9 + maxSlippageD9, D9) + 1;
    }

    function createUniswapMulticall(
        address tokenFrom,
        address tokenTo,
        uint256 fee,
        address adapter,
        uint256 slippage
    ) public view returns (MultiCall memory) {
        uint256 rateRAY = calcRateRAY(tokenFrom, tokenTo);

        IUniswapV3Adapter.ExactAllInputParams memory params = IUniswapV3Adapter.ExactAllInputParams({
            path: abi.encodePacked(tokenFrom, uint24(fee), tokenTo),
            deadline: block.timestamp + 1,
            rateMinRAY: FullMath.mulDiv(rateRAY, D9 - slippage, D9)
        });

        return
            MultiCall({
                target: adapter,
                callData: abi.encodeWithSelector(IUniswapV3Adapter.exactAllInput.selector, params)
            });
    }

    function checkNecessaryDepositExchange(
        uint256 expectedMaximalDepositTokenValueNominatedUnderlying,
        address vaultGovernance,
        address creditAccount
    ) public {
        require(msg.sender == address(gearboxVault), ExceptionsLibrary.FORBIDDEN);

        address depositToken_ = depositToken;
        address primaryToken_ = primaryToken;

        if (depositToken_ == primaryToken_) {
            return;
        }

        uint256 currentDepositTokenAmount = IERC20(depositToken_).balanceOf(creditAccount);
        IPriceOracleV2 oracle = IPriceOracleV2(creditManager.priceOracle());

        uint256 currentValueDepositTokenNominatedUnderlying = oracle.convert(
            currentDepositTokenAmount,
            depositToken_,
            primaryToken_
        );

        if (currentValueDepositTokenNominatedUnderlying > expectedMaximalDepositTokenValueNominatedUnderlying) {
            uint256 toSwap = FullMath.mulDiv(
                currentDepositTokenAmount,
                currentValueDepositTokenNominatedUnderlying - expectedMaximalDepositTokenValueNominatedUnderlying,
                currentValueDepositTokenNominatedUnderlying
            );
            swapExactInput(depositToken_, primaryToken_, toSwap, vaultGovernance, creditAccount);
        }
    }

    function claimRewards(
        address vaultGovernance,
        address creditAccount,
        address convexOutputToken
    ) public {
        IGearboxVault gearboxVault_ = gearboxVault;
        address primaryToken_ = primaryToken;

        require(msg.sender == address(gearboxVault_), ExceptionsLibrary.FORBIDDEN);

        uint256 balance = IERC20(convexOutputToken).balanceOf(creditAccount);
        if (balance == 0) {
            return;
        }

        IBaseRewardPool underlyingContract = IBaseRewardPool(creditManager.adapterToContract(convexAdapter));

        IGearboxVaultGovernance.DelayedProtocolParams memory protocolParams = IGearboxVaultGovernance(vaultGovernance)
            .delayedProtocolParams();

        IGearboxVaultGovernance.StrategyParams memory strategyParams = IGearboxVaultGovernance(vaultGovernance)
            .strategyParams(vaultNft);

        IGearboxVaultGovernance.DelayedProtocolPerVaultParams memory vaultParams = IGearboxVaultGovernance(
            vaultGovernance
        ).delayedProtocolPerVaultParams(vaultNft);

        address weth = creditManager.wethAddress();

        uint256 callsCount = 4;
        if (weth == primaryToken_ || weth == depositToken) {
            callsCount -= 1;
        }

        for (uint256 i = 0; i < underlyingContract.extraRewardsLength(); ++i) {
            address rewardToken = address(IRewards(underlyingContract.extraRewards(i)).rewardToken());
            if (rewardToken != depositToken && rewardToken != primaryToken_ && rewardToken != weth) {
                callsCount += 1;
            }
        }

        MultiCall[] memory calls = new MultiCall[](callsCount);

        calls[0] = MultiCall({ // taking crv and cvx
            target: convexAdapter,
            callData: abi.encodeWithSelector(GET_REWARD_SELECTOR, creditAccount, true)
        });

        calls[1] = createUniswapMulticall(
            protocolParams.crv,
            weth,
            10000,
            vaultParams.univ3Adapter,
            protocolParams.maxSmallPoolsSlippageD9
        );

        calls[2] = createUniswapMulticall(
            protocolParams.cvx,
            weth,
            10000,
            vaultParams.univ3Adapter,
            protocolParams.maxSmallPoolsSlippageD9
        );

        uint256 pointer = 3;

        for (uint256 i = 2; i < 2 + underlyingContract.extraRewardsLength(); ++i) {
            address rewardToken = address(IRewards(underlyingContract.extraRewards(i - 2)).rewardToken());
            if (rewardToken != depositToken && rewardToken != primaryToken_ && rewardToken != weth) {
                calls[pointer] = createUniswapMulticall(
                    rewardToken,
                    weth,
                    10000,
                    vaultParams.univ3Adapter,
                    protocolParams.maxSmallPoolsSlippageD9
                );
                pointer += 1;
            }
        }

        if (weth != primaryToken_ && weth != depositToken) {
            calls[callsCount - 1] = createUniswapMulticall(
                weth,
                primaryToken_,
                strategyParams.largePoolFeeUsed,
                vaultParams.univ3Adapter,
                protocolParams.maxSlippageD9
            );
        }

        gearboxVault_.multicall(calls);
    }

    function withdrawFromConvex(
        uint256 amount,
        address vaultGovernance,
        int128 primaryIndex
    ) public {
        if (amount == 0) {
            return;
        }

        IGearboxVault gearboxVault_ = gearboxVault;

        require(msg.sender == address(gearboxVault_), ExceptionsLibrary.FORBIDDEN);

        address curveLpToken = ICurveV1Adapter(curveAdapter).lp_token();
        IGearboxVaultGovernance.DelayedProtocolParams memory protocolParams = IGearboxVaultGovernance(vaultGovernance)
            .delayedProtocolParams();

        if (!is3crv) {
            uint256 rateRAY = calcRateRAY(curveLpToken, primaryToken);

            MultiCall[] memory calls = new MultiCall[](2);

            calls[0] = MultiCall({
                target: convexAdapter,
                callData: abi.encodeWithSelector(IBaseRewardPool.withdrawAndUnwrap.selector, amount, false)
            });

            calls[1] = MultiCall({
                target: curveAdapter,
                callData: abi.encodeWithSelector(
                    ICurveV1Adapter.remove_all_liquidity_one_coin.selector,
                    primaryIndex,
                    FullMath.mulDiv(rateRAY, D9 - protocolParams.maxCurveSlippageD9, D9)
                )
            });

            gearboxVault_.multicall(calls);
        } else {
            ICurveV1Adapter crv3Adapter = ICurveV1Adapter(creditManager.contractToAdapter(protocolParams.crv3Pool));
            address crv3Token = crv3Adapter.lp_token();

            uint256 rateRAY1 = calcRateRAY(curveLpToken, crv3Token);
            uint256 rateRAY2 = calcRateRAY(crv3Token, primaryToken);

            MultiCall[] memory calls = new MultiCall[](3);

            calls[0] = MultiCall({
                target: convexAdapter,
                callData: abi.encodeWithSelector(IBaseRewardPool.withdrawAndUnwrap.selector, amount, false)
            });

            calls[1] = MultiCall({
                target: curveAdapter,
                callData: abi.encodeWithSelector(
                    ICurveV1Adapter.remove_all_liquidity_one_coin.selector,
                    crv3Index,
                    FullMath.mulDiv(rateRAY1, D9 - protocolParams.maxCurveSlippageD9, D9)
                )
            });

            calls[2] = MultiCall({
                target: address(crv3Adapter),
                callData: abi.encodeWithSelector(
                    ICurveV1Adapter.remove_all_liquidity_one_coin.selector,
                    primaryIndex,
                    FullMath.mulDiv(rateRAY2, D9 - protocolParams.maxCurveSlippageD9, D9)
                )
            });

            gearboxVault_.multicall(calls);
        }
    }

    function depositToConvex(
        MultiCall memory debtManagementCall,
        IGearboxVaultGovernance.DelayedProtocolParams memory protocolParams,
        uint256 poolId,
        int128 primaryIndex
    ) public {
        IGearboxVault gearboxVault_ = gearboxVault;

        require(msg.sender == address(gearboxVault_), ExceptionsLibrary.FORBIDDEN);
        address curveLpToken = ICurveV1Adapter(curveAdapter).lp_token();

        if (!is3crv) {
            uint256 rateRAY = calcRateRAY(primaryToken, curveLpToken);

            MultiCall[] memory calls = new MultiCall[](3);

            calls[0] = debtManagementCall;

            calls[1] = MultiCall({
                target: curveAdapter,
                callData: abi.encodeWithSelector(
                    ICurveV1Adapter.add_all_liquidity_one_coin.selector,
                    primaryIndex,
                    FullMath.mulDiv(rateRAY, D9 - protocolParams.maxCurveSlippageD9, D9)
                )
            });

            calls[2] = MultiCall({
                target: creditManager.contractToAdapter(IConvexV1BaseRewardPoolAdapter(convexAdapter).operator()),
                callData: abi.encodeWithSelector(IBooster.depositAll.selector, poolId, true)
            });

            gearboxVault_.multicall(calls);
        } else {
            ICurveV1Adapter crv3Adapter = ICurveV1Adapter(creditManager.contractToAdapter(protocolParams.crv3Pool));
            address crv3Token = crv3Adapter.lp_token();

            uint256 rateRAY1 = calcRateRAY(primaryToken, crv3Token);
            uint256 rateRAY2 = calcRateRAY(crv3Token, curveLpToken);

            MultiCall[] memory calls = new MultiCall[](4);

            calls[0] = debtManagementCall;

            calls[1] = MultiCall({
                target: address(crv3Adapter),
                callData: abi.encodeWithSelector(
                    ICurveV1Adapter.add_all_liquidity_one_coin.selector,
                    primaryIndex,
                    FullMath.mulDiv(rateRAY1, D9 - protocolParams.maxCurveSlippageD9, D9)
                )
            });

            calls[2] = MultiCall({
                target: curveAdapter,
                callData: abi.encodeWithSelector(
                    ICurveV1Adapter.add_all_liquidity_one_coin.selector,
                    crv3Index,
                    FullMath.mulDiv(rateRAY2, D9 - protocolParams.maxCurveSlippageD9, D9)
                )
            });

            calls[3] = MultiCall({
                target: creditManager.contractToAdapter(IConvexV1BaseRewardPoolAdapter(convexAdapter).operator()),
                callData: abi.encodeWithSelector(IBooster.depositAll.selector, poolId, true)
            });

            gearboxVault_.multicall(calls);
        }
    }

    function adjustPosition(
        uint256 expectedAllAssetsValue,
        uint256 currentAllAssetsValue,
        address vaultGovernance,
        uint256 marginalFactorD9,
        int128 primaryIndex,
        uint256 poolId,
        address convexOutputToken,
        address creditAccount_
    ) external {
        require(msg.sender == address(gearboxVault), ExceptionsLibrary.FORBIDDEN);

        claimRewards(vaultGovernance, creditAccount_, convexOutputToken);

        IGearboxVaultGovernance.DelayedProtocolParams memory protocolParams = IGearboxVaultGovernance(vaultGovernance)
            .delayedProtocolParams();
        ICreditFacade creditFacade_ = creditFacade;

        checkNecessaryDepositExchange(
            FullMath.mulDiv(expectedAllAssetsValue, D9, marginalFactorD9),
            vaultGovernance,
            creditAccount_
        );

        if (expectedAllAssetsValue >= currentAllAssetsValue) {
            uint256 delta = expectedAllAssetsValue - currentAllAssetsValue;

            MultiCall memory increaseDebtCall = MultiCall({
                target: address(creditFacade_),
                callData: abi.encodeWithSelector(ICreditFacade.increaseDebt.selector, delta)
            });

            depositToConvex(increaseDebtCall, protocolParams, poolId, primaryIndex);
        } else {
            uint256 delta = currentAllAssetsValue - expectedAllAssetsValue;

            uint256 currentPrimaryTokenAmount = IERC20(primaryToken).balanceOf(creditAccount_);

            if (currentPrimaryTokenAmount >= delta) {
                MultiCall memory decreaseDebtCall = MultiCall({
                    target: address(creditFacade_),
                    callData: abi.encodeWithSelector(ICreditFacade.decreaseDebt.selector, delta)
                });

                depositToConvex(decreaseDebtCall, protocolParams, poolId, primaryIndex);
            } else {
                uint256 convexAmountToWithdraw = calcConvexTokensToWithdraw(
                    delta - currentPrimaryTokenAmount,
                    creditAccount_,
                    convexOutputToken
                );
                withdrawFromConvex(convexAmountToWithdraw, vaultGovernance, primaryIndex);

                currentPrimaryTokenAmount = IERC20(primaryToken).balanceOf(creditAccount_);
                if (currentPrimaryTokenAmount < delta) {
                    delta = currentPrimaryTokenAmount;
                }

                MultiCall[] memory decreaseCall = new MultiCall[](1);
                decreaseCall[0] = MultiCall({
                    target: address(creditFacade_),
                    callData: abi.encodeWithSelector(ICreditFacade.decreaseDebt.selector, delta)
                });

                gearboxVault.multicall(decreaseCall);
            }
        }

        emit PositionAdjusted(tx.origin, msg.sender, expectedAllAssetsValue);
    }

    function swapExactOutput(
        address fromToken,
        address toToken,
        uint256 amount,
        address vaultGovernance,
        address creditAccount
    ) external {
        require(msg.sender == address(gearboxVault), ExceptionsLibrary.FORBIDDEN);

        IGearboxVaultGovernance.DelayedProtocolParams memory protocolParams = IGearboxVaultGovernance(vaultGovernance)
            .delayedProtocolParams();

        IGearboxVaultGovernance.StrategyParams memory strategyParams = IGearboxVaultGovernance(vaultGovernance)
            .strategyParams(vaultNft);

        IGearboxVaultGovernance.DelayedProtocolPerVaultParams memory vaultParams = IGearboxVaultGovernance(
            vaultGovernance
        ).delayedProtocolPerVaultParams(vaultNft);

        uint256 amountInMaximum = calculateAmountInMaximum(fromToken, toToken, amount, protocolParams.maxSlippageD9);

        ISwapRouter.ExactOutputParams memory uniParams = ISwapRouter.ExactOutputParams({
            path: abi.encodePacked(toToken, strategyParams.largePoolFeeUsed, fromToken), // exactOutput arguments are in reversed order
            recipient: creditAccount,
            deadline: block.timestamp + 1,
            amountOut: amount,
            amountInMaximum: amountInMaximum
        });

        MultiCall[] memory calls = new MultiCall[](1);

        calls[0] = MultiCall({
            target: vaultParams.univ3Adapter,
            callData: abi.encodeWithSelector(ISwapRouter.exactOutput.selector, uniParams)
        });

        gearboxVault.multicall(calls);
    }

    function swapExactInput(
        address fromToken,
        address toToken,
        uint256 amount,
        address vaultGovernance,
        address creditAccount
    ) public {
        require(msg.sender == address(gearboxVault), ExceptionsLibrary.FORBIDDEN);

        IGearboxVaultGovernance.DelayedProtocolParams memory protocolParams = IGearboxVaultGovernance(vaultGovernance)
            .delayedProtocolParams();

        IGearboxVaultGovernance.StrategyParams memory strategyParams = IGearboxVaultGovernance(vaultGovernance)
            .strategyParams(vaultNft);

        IGearboxVaultGovernance.DelayedProtocolPerVaultParams memory vaultParams = IGearboxVaultGovernance(
            vaultGovernance
        ).delayedProtocolPerVaultParams(vaultNft);

        MultiCall[] memory calls = new MultiCall[](1);

        IPriceOracleV2 oracle = IPriceOracleV2(creditManager.priceOracle());
        uint256 expectedOutput = oracle.convert(amount, fromToken, toToken);

        ISwapRouter.ExactInputParams memory inputParams = ISwapRouter.ExactInputParams({
            path: abi.encodePacked(fromToken, strategyParams.largePoolFeeUsed, toToken),
            recipient: creditAccount,
            deadline: block.timestamp + 1,
            amountIn: amount,
            amountOutMinimum: FullMath.mulDiv(expectedOutput, D9 - protocolParams.maxSlippageD9, D9)
        });

        calls[0] = MultiCall({ // swap deposit to primary token
            target: vaultParams.univ3Adapter,
            callData: abi.encodeWithSelector(ISwapRouter.exactInput.selector, inputParams)
        });

        gearboxVault.multicall(calls);
    }

    function openCreditAccount(address vaultGovernance, uint256 marginalFactorD9) external {
        IGearboxVault gearboxVault_ = gearboxVault;

        require(msg.sender == address(gearboxVault_), ExceptionsLibrary.FORBIDDEN);

        ICreditFacade creditFacade_ = creditFacade;
        address primaryToken_ = primaryToken;
        address depositToken_ = depositToken;

        uint256 minimalNecessaryAmount;

        {
            (uint256 minBorrowingLimit, ) = creditFacade_.limits();
            minimalNecessaryAmount = FullMath.mulDiv(minBorrowingLimit, D9, (marginalFactorD9 - D9)) + 1;
        }

        uint256 currentPrimaryTokenAmount = IERC20(primaryToken_).balanceOf(address(gearboxVault_));

        IGearboxVaultGovernance vaultGovernance_ = IGearboxVaultGovernance(vaultGovernance);
        uint256 vaultNft_ = vaultNft;

        IGearboxVaultGovernance.DelayedProtocolParams memory protocolParams = vaultGovernance_.delayedProtocolParams();
        IGearboxVaultGovernance.StrategyParams memory strategyParams = vaultGovernance_.strategyParams(vaultNft_);
        IGearboxVaultGovernance.DelayedProtocolPerVaultParams memory vaultParams = vaultGovernance_
            .delayedProtocolPerVaultParams(vaultNft_);

        if (depositToken_ != primaryToken_ && currentPrimaryTokenAmount < minimalNecessaryAmount) {
            ISwapRouter router = ISwapRouter(protocolParams.uniswapRouter);
            uint256 amountInMaximum = calculateAmountInMaximum(
                depositToken_,
                primaryToken_,
                minimalNecessaryAmount - currentPrimaryTokenAmount,
                protocolParams.maxSlippageD9
            );
            require(IERC20(depositToken_).balanceOf(address(gearboxVault_)) >= amountInMaximum, ExceptionsLibrary.INVARIANT);

            ISwapRouter.ExactOutputParams memory uniParams = ISwapRouter.ExactOutputParams({
                path: abi.encodePacked(primaryToken_, strategyParams.largePoolFeeUsed, depositToken_), // exactOutput arguments are in reversed order
                recipient: address(gearboxVault_),
                deadline: block.timestamp + 1,
                amountOut: minimalNecessaryAmount - currentPrimaryTokenAmount,
                amountInMaximum: amountInMaximum
            });

            gearboxVault_.swapExactOutput(router, uniParams, depositToken_, amountInMaximum);

            currentPrimaryTokenAmount = IERC20(primaryToken_).balanceOf(address(gearboxVault_));
        }

        require(currentPrimaryTokenAmount >= minimalNecessaryAmount, ExceptionsLibrary.LIMIT_UNDERFLOW);
        gearboxVault_.openCreditAccountInManager(currentPrimaryTokenAmount, vaultParams.referralCode);
        emit CreditAccountOpened(tx.origin, msg.sender, creditManager.creditAccounts(address(gearboxVault_)));
    }

    
    
    
    
    event CreditAccountOpened(address indexed origin, address indexed sender, address creditAccount);

    
    
    
    
    event PositionAdjusted(address indexed origin, address indexed sender, uint256 newTotalAssetsValue);
}

// 
pragma solidity 0.8.9;






contract GearboxVault is IGearboxVault, IntegrationVault {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 public constant D9 = 10**9;
    uint256 public constant D7 = 10**7;

    bytes32[] private _merkleProof;

    EnumerableSet.UintSet private _poolsAllowList;

    
    GearboxHelper public helper;

    
    ICreditFacade public creditFacade;

    
    ICreditManagerV2 public creditManager;

    
    address public primaryToken;
    
    address public depositToken;

    
    int128 public primaryIndex;
    
    uint256 public poolId;
    
    address public convexOutputToken;

    
    uint256 public marginalFactorD9;

    
    uint256 public merkleIndex;

    
    uint256 public merkleTotalAmount;

    // -------------------  EXTERNAL, VIEW  -------------------

    function approvedPools() external view returns (uint256[] memory) {
        return _poolsAllowList.values();
    }

    
    function tvl() public view override returns (uint256[] memory minTokenAmounts, uint256[] memory maxTokenAmounts) {
        uint256 amount = helper.calcTvl(getCreditAccount(), address(_vaultGovernance));
        minTokenAmounts = new uint256[](1);

        minTokenAmounts[0] = amount;
        maxTokenAmounts = minTokenAmounts;
    }

    
    function supportsInterface(bytes4 interfaceId) public view override(IERC165, IntegrationVault) returns (bool) {
        return IntegrationVault.supportsInterface(interfaceId) || interfaceId == type(IGearboxVault).interfaceId;
    }

    
    function getCreditAccount() public view returns (address) {
        return creditManager.creditAccounts(address(this));
    }

    
    function getAllAssetsOnCreditAccountValue() external view returns (uint256 currentAllAssetsValue) {
        address creditAccount = getCreditAccount();
        if (creditAccount == address(0)) {
            return 0;
        }
        (currentAllAssetsValue, ) = creditFacade.calcTotalValue(creditAccount);
    }

    
    function getClaimableRewardsValue() external view returns (uint256) {
        address creditAccount = getCreditAccount();
        if (creditAccount == address(0)) {
            return 0;
        }
        return helper.calculateClaimableRewards(creditAccount, address(_vaultGovernance));
    }

    function getMerkleProof() external view returns (bytes32[] memory) {
        return _merkleProof;
    }

    // -------------------  EXTERNAL, MUTATING  -------------------

    
    function addPoolsToAllowList(uint256[] calldata pools) external {
        require(_isApprovedOrOwner(msg.sender), ExceptionsLibrary.FORBIDDEN);
        for (uint256 i = 0; i < pools.length; i++) {
            _poolsAllowList.add(pools[i]);
        }
    }

    
    function removePoolsFromAllowlist(uint256[] calldata pools) external {
        require(_isApprovedOrOwner(msg.sender), ExceptionsLibrary.FORBIDDEN);
        for (uint256 i = 0; i < pools.length; i++) {
            _poolsAllowList.remove(pools[i]);
        }
    }

    
    function initialize(
        uint256 nft_,
        address[] memory vaultTokens_,
        address helper_
    ) external {
        require(vaultTokens_.length == 1, ExceptionsLibrary.INVALID_LENGTH);

        _initialize(vaultTokens_, nft_);

        IGearboxVaultGovernance.DelayedProtocolPerVaultParams memory params = IGearboxVaultGovernance(
            address(_vaultGovernance)
        ).delayedProtocolPerVaultParams(nft_);
        primaryToken = params.primaryToken;
        depositToken = vaultTokens_[0];
        marginalFactorD9 = params.initialMarginalValueD9;

        creditFacade = ICreditFacade(params.facade);
        creditManager = ICreditManagerV2(creditFacade.creditManager());

        helper = GearboxHelper(helper_);
        helper.setParameters(creditFacade, creditManager, params.primaryToken, vaultTokens_[0], _nft);
    }

    
    function openCreditAccount(address curveAdapter, address convexAdapter) external {
        require(_isApprovedOrOwner(msg.sender), ExceptionsLibrary.FORBIDDEN);
        address creditAccount = getCreditAccount();
        require(creditAccount == address(0), ExceptionsLibrary.DUPLICATE);

        address degenNft = creditFacade.degenNFT();

        if (degenNft != address(0)) {
            IDegenNFT degenContract = IDegenNFT(degenNft);
            IDegenDistributor distributor = IDegenDistributor(degenContract.minter());
            if (distributor.claimed(address(this)) < merkleTotalAmount) {
                distributor.claim(merkleIndex, address(this), merkleTotalAmount, _merkleProof);
            }
        }

        helper.setAdapters(curveAdapter, convexAdapter);
        (primaryIndex, convexOutputToken, poolId) = helper.verifyInstances(address(_vaultGovernance));
        require(_poolsAllowList.contains(poolId), ExceptionsLibrary.FORBIDDEN);
        helper.openCreditAccount(address(_vaultGovernance), marginalFactorD9);

        if (depositToken != primaryToken) {
            creditFacade.enableToken(depositToken);
            _addDepositTokenAsCollateral();
        }
    }

    
    function closeCreditAccount() external {
        GearboxHelper helper_ = helper;

        IVaultRegistry registry = _vaultGovernance.internalParams().registry;
        require(registry.ownerOf(_nft) == msg.sender, ExceptionsLibrary.FORBIDDEN);

        address depositToken_ = depositToken;
        address primaryToken_ = primaryToken;
        address creditAccount_ = getCreditAccount();

        if (creditAccount_ == address(0)) {
            return;
        }

        helper_.claimRewards(address(_vaultGovernance), creditAccount_, convexOutputToken);
        helper_.withdrawFromConvex(
            IERC20(convexOutputToken).balanceOf(creditAccount_),
            address(_vaultGovernance),
            primaryIndex
        );

        (, , uint256 debtAmount) = creditManager.calcCreditAccountAccruedInterest(creditAccount_);
        uint256 underlyingBalance = IERC20(primaryToken_).balanceOf(creditAccount_);

        if (underlyingBalance < debtAmount + 1) {
            helper_.swapExactOutput(
                depositToken_,
                primaryToken_,
                debtAmount + 1 - underlyingBalance,
                address(_vaultGovernance),
                creditAccount_
            );
        } else if (primaryToken_ != depositToken_) {
            helper_.swapExactInput(
                primaryToken_,
                depositToken_,
                underlyingBalance - (debtAmount + 1),
                address(_vaultGovernance),
                creditAccount_
            );
        }

        MultiCall[] memory noCalls = new MultiCall[](0);
        creditFacade.closeCreditAccount(address(this), 0, false, noCalls);
    }

    
    function adjustPosition() public {
        require(_isApprovedOrOwner(msg.sender), ExceptionsLibrary.FORBIDDEN);
        address creditAccount = getCreditAccount();

        if (creditAccount == address(0)) {
            return;
        }

        uint256 marginalFactorD9_ = marginalFactorD9;
        GearboxHelper helper_ = helper;

        (uint256 expectedAllAssetsValue, uint256 currentAllAssetsValue) = helper_.calculateDesiredTotalValue(
            creditAccount,
            address(_vaultGovernance),
            marginalFactorD9_
        );
        helper_.adjustPosition(
            expectedAllAssetsValue,
            currentAllAssetsValue,
            address(_vaultGovernance),
            marginalFactorD9_,
            primaryIndex,
            poolId,
            convexOutputToken,
            creditAccount
        );
    }

    
    function setMerkleParameters(
        uint256 merkleIndex_,
        uint256 merkleTotalAmount_,
        bytes32[] memory merkleProof_
    ) public {
        require(_isApprovedOrOwner(msg.sender));
        merkleIndex = merkleIndex_;
        merkleTotalAmount = merkleTotalAmount_;
        _merkleProof = merkleProof_;
    }

    
    function updateTargetMarginalFactor(uint256 marginalFactorD9_) external {
        require(marginalFactorD9_ > D9, ExceptionsLibrary.INVALID_VALUE);

        marginalFactorD9 = marginalFactorD9_;
        adjustPosition();

        emit TargetMarginalFactorUpdated(tx.origin, msg.sender, marginalFactorD9_);
    }

    
    function multicall(MultiCall[] memory calls) external {
        require(msg.sender == address(helper), ExceptionsLibrary.FORBIDDEN);
        creditFacade.multicall(calls);
    }

    
    function swapExactOutput(
        ISwapRouter router,
        ISwapRouter.ExactOutputParams memory uniParams,
        address token,
        uint256 amount
    ) external {
        require(msg.sender == address(helper), ExceptionsLibrary.FORBIDDEN);
        IERC20(token).safeIncreaseAllowance(address(router), amount);
        router.exactOutput(uniParams);
        IERC20(token).safeApprove(address(router), 0);
    }

    
    function openCreditAccountInManager(uint256 currentPrimaryTokenAmount, uint16 referralCode) external {
        require(msg.sender == address(helper), ExceptionsLibrary.FORBIDDEN);

        address creditManagerAddress = address(creditManager);
        IERC20 primaryToken_ = IERC20(primaryToken);

        primaryToken_.safeIncreaseAllowance(creditManagerAddress, currentPrimaryTokenAmount);
        creditFacade.openCreditAccount(
            currentPrimaryTokenAmount,
            address(this),
            uint16((marginalFactorD9 - D9) / D7),
            referralCode
        );
        primaryToken_.safeApprove(creditManagerAddress, 0);
    }

    // -------------------  INTERNAL, VIEW  -------------------

    function _isReclaimForbidden(address) internal pure override returns (bool) {
        return false;
    }

    // -------------------  INTERNAL, MUTATING  -------------------

    function _push(uint256[] memory tokenAmounts, bytes memory) internal override returns (uint256[] memory) {
        require(tokenAmounts.length == 1, ExceptionsLibrary.INVALID_LENGTH);
        address creditAccount = getCreditAccount();

        if (creditAccount != address(0)) {
            _addDepositTokenAsCollateral();
        }

        return tokenAmounts;
    }

    function _pull(
        address to,
        uint256[] memory tokenAmounts,
        bytes memory
    ) internal override returns (uint256[] memory actualTokenAmounts) {
        require(tokenAmounts.length == 1, ExceptionsLibrary.INVALID_LENGTH);

        IERC20(depositToken).safeTransfer(to, tokenAmounts[0]);
        actualTokenAmounts = tokenAmounts;
    }

    
    function _addDepositTokenAsCollateral() internal {
        ICreditFacade creditFacade_ = creditFacade;
        MultiCall[] memory calls = new MultiCall[](1);
        address creditManagerAddress = address(creditManager);

        IERC20 token = IERC20(depositToken);
        uint256 amount = token.balanceOf(address(this));

        token.safeIncreaseAllowance(creditManagerAddress, amount);

        calls[0] = MultiCall({
            target: address(creditFacade_),
            callData: abi.encodeWithSelector(
                ICreditFacade.addCollateral.selector,
                address(this),
                address(token),
                amount
            )
        });

        creditFacade_.multicall(calls);
        token.safeApprove(creditManagerAddress, 0);
    }

    // --------------------------  EVENTS  --------------------------

    
    
    
    
    event TargetMarginalFactorUpdated(address indexed origin, address indexed sender, uint256 newMarginalFactorD9);
}

// 
pragma solidity 0.8.9;










/// define different params structs and use abi.decode / abi.encode to serialize
/// to bytes in this contract. It also should emit events on params change.
abstract contract VaultGovernance is IVaultGovernance, ERC165 {
    InternalParams internal _internalParams;
    InternalParams private _stagedInternalParams;
    uint256 internal _internalParamsTimestamp;

    mapping(uint256 => bytes) internal _delayedStrategyParams;
    mapping(uint256 => bytes) internal _stagedDelayedStrategyParams;
    mapping(uint256 => uint256) internal _delayedStrategyParamsTimestamp;

    mapping(uint256 => bytes) internal _delayedProtocolPerVaultParams;
    mapping(uint256 => bytes) internal _stagedDelayedProtocolPerVaultParams;
    mapping(uint256 => uint256) internal _delayedProtocolPerVaultParamsTimestamp;

    bytes internal _delayedProtocolParams;
    bytes internal _stagedDelayedProtocolParams;
    uint256 internal _delayedProtocolParamsTimestamp;

    mapping(uint256 => bytes) internal _strategyParams;
    bytes internal _protocolParams;
    bytes internal _operatorParams;

    
    
    constructor(InternalParams memory internalParams_) {
        require(address(internalParams_.protocolGovernance) != address(0), ExceptionsLibrary.ADDRESS_ZERO);
        require(address(internalParams_.registry) != address(0), ExceptionsLibrary.ADDRESS_ZERO);
        require(address(internalParams_.singleton) != address(0), ExceptionsLibrary.ADDRESS_ZERO);
        _internalParams = internalParams_;
    }

    // -------------------  EXTERNAL, VIEW  -------------------

    
    function delayedStrategyParamsTimestamp(uint256 nft) external view returns (uint256) {
        return _delayedStrategyParamsTimestamp[nft];
    }

    
    function delayedProtocolPerVaultParamsTimestamp(uint256 nft) external view returns (uint256) {
        return _delayedProtocolPerVaultParamsTimestamp[nft];
    }

    
    function delayedProtocolParamsTimestamp() external view returns (uint256) {
        return _delayedProtocolParamsTimestamp;
    }

    
    function internalParamsTimestamp() external view returns (uint256) {
        return _internalParamsTimestamp;
    }

    
    function internalParams() external view returns (InternalParams memory) {
        return _internalParams;
    }

    
    function stagedInternalParams() external view returns (InternalParams memory) {
        return _stagedInternalParams;
    }

    function supportsInterface(bytes4 interfaceID) public view virtual override(ERC165) returns (bool) {
        return super.supportsInterface(interfaceID) || interfaceID == type(IVaultGovernance).interfaceId;
    }

    // -------------------  EXTERNAL, MUTATING  -------------------

    
    function stageInternalParams(InternalParams memory newParams) external {
        _requireProtocolAdmin();
        require(address(newParams.protocolGovernance) != address(0), ExceptionsLibrary.ADDRESS_ZERO);
        require(address(newParams.registry) != address(0), ExceptionsLibrary.ADDRESS_ZERO);
        require(address(newParams.singleton) != address(0), ExceptionsLibrary.ADDRESS_ZERO);
        _stagedInternalParams = newParams;
        _internalParamsTimestamp = block.timestamp + _internalParams.protocolGovernance.governanceDelay();
        emit StagedInternalParams(tx.origin, msg.sender, newParams, _internalParamsTimestamp);
    }

    
    function commitInternalParams() external {
        _requireProtocolAdmin();
        require(_internalParamsTimestamp != 0, ExceptionsLibrary.NULL);
        require(block.timestamp >= _internalParamsTimestamp, ExceptionsLibrary.TIMESTAMP);
        _internalParams = _stagedInternalParams;
        delete _internalParamsTimestamp;
        delete _stagedInternalParams;
        emit CommitedInternalParams(tx.origin, msg.sender, _internalParams);
    }

    // -------------------  INTERNAL, VIEW  -------------------

    function _requireAtLeastStrategy(uint256 nft) internal view {
        require(
            (_internalParams.protocolGovernance.isAdmin(msg.sender) ||
                _internalParams.registry.getApproved(nft) == msg.sender ||
                (_internalParams.registry.ownerOf(nft) == msg.sender)),
            ExceptionsLibrary.FORBIDDEN
        );
    }

    function _requireProtocolAdmin() internal view {
        require(_internalParams.protocolGovernance.isAdmin(msg.sender), ExceptionsLibrary.FORBIDDEN);
    }

    function _requireAtLeastOperator() internal view {
        IProtocolGovernance governance = _internalParams.protocolGovernance;
        require(governance.isAdmin(msg.sender) || governance.isOperator(msg.sender), ExceptionsLibrary.FORBIDDEN);
    }

    // -------------------  INTERNAL, MUTATING  -------------------

    function _createVault(address owner) internal returns (address vault, uint256 nft) {
        IProtocolGovernance protocolGovernance = IProtocolGovernance(_internalParams.protocolGovernance);
        require(
            protocolGovernance.hasPermission(msg.sender, PermissionIdsLibrary.CREATE_VAULT),
            ExceptionsLibrary.FORBIDDEN
        );
        IVaultRegistry vaultRegistry = _internalParams.registry;
        nft = vaultRegistry.vaultsCount() + 1;
        vault = Clones.cloneDeterministic(address(_internalParams.singleton), bytes32(nft));
        vaultRegistry.registerVault(address(vault), owner);
    }

    
    
    
    function _stageDelayedStrategyParams(uint256 nft, bytes memory params) internal {
        _requireAtLeastStrategy(nft);
        _stagedDelayedStrategyParams[nft] = params;
        uint256 delayFactor = _delayedStrategyParams[nft].length == 0 ? 0 : 1;
        _delayedStrategyParamsTimestamp[nft] =
            block.timestamp +
            _internalParams.protocolGovernance.governanceDelay() *
            delayFactor;
    }

    
    function _commitDelayedStrategyParams(uint256 nft) internal {
        _requireAtLeastStrategy(nft);
        uint256 thisDelayedStrategyParamsTimestamp = _delayedStrategyParamsTimestamp[nft];
        require(thisDelayedStrategyParamsTimestamp != 0, ExceptionsLibrary.NULL);
        require(block.timestamp >= thisDelayedStrategyParamsTimestamp, ExceptionsLibrary.TIMESTAMP);
        _delayedStrategyParams[nft] = _stagedDelayedStrategyParams[nft];
        delete _stagedDelayedStrategyParams[nft];
        delete _delayedStrategyParamsTimestamp[nft];
    }

    
    
    
    function _stageDelayedProtocolPerVaultParams(uint256 nft, bytes memory params) internal {
        _requireProtocolAdmin();
        _stagedDelayedProtocolPerVaultParams[nft] = params;
        uint256 delayFactor = _delayedProtocolPerVaultParams[nft].length == 0 ? 0 : 1;
        _delayedProtocolPerVaultParamsTimestamp[nft] =
            block.timestamp +
            _internalParams.protocolGovernance.governanceDelay() *
            delayFactor;
    }

    
    function _commitDelayedProtocolPerVaultParams(uint256 nft) internal {
        _requireProtocolAdmin();
        uint256 thisDelayedProtocolPerVaultParamsTimestamp = _delayedProtocolPerVaultParamsTimestamp[nft];
        require(thisDelayedProtocolPerVaultParamsTimestamp != 0, ExceptionsLibrary.NULL);
        require(block.timestamp >= thisDelayedProtocolPerVaultParamsTimestamp, ExceptionsLibrary.TIMESTAMP);
        _delayedProtocolPerVaultParams[nft] = _stagedDelayedProtocolPerVaultParams[nft];
        delete _stagedDelayedProtocolPerVaultParams[nft];
        delete _delayedProtocolPerVaultParamsTimestamp[nft];
    }

    
    
    function _stageDelayedProtocolParams(bytes memory params) internal {
        _requireProtocolAdmin();
        uint256 delayFactor = _delayedProtocolParams.length == 0 ? 0 : 1;
        _stagedDelayedProtocolParams = params;
        _delayedProtocolParamsTimestamp =
            block.timestamp +
            _internalParams.protocolGovernance.governanceDelay() *
            delayFactor;
    }

    
    function _commitDelayedProtocolParams() internal {
        _requireProtocolAdmin();
        require(_delayedProtocolParamsTimestamp != 0, ExceptionsLibrary.NULL);
        require(block.timestamp >= _delayedProtocolParamsTimestamp, ExceptionsLibrary.TIMESTAMP);
        _delayedProtocolParams = _stagedDelayedProtocolParams;
        delete _stagedDelayedProtocolParams;
        delete _delayedProtocolParamsTimestamp;
    }

    
    
    
    
    function _setStrategyParams(uint256 nft, bytes memory params) internal {
        _requireAtLeastStrategy(nft);
        _strategyParams[nft] = params;
    }

    
    
    function _setOperatorParams(bytes memory params) internal {
        _requireAtLeastOperator();
        _operatorParams = params;
    }

    
    
    function _setProtocolParams(bytes memory params) internal {
        _requireProtocolAdmin();
        _protocolParams = params;
    }

    // --------------------------  EVENTS  --------------------------

    
    
    
    
    
    event StagedInternalParams(address indexed origin, address indexed sender, InternalParams params, uint256 when);

    
    
    
    
    event CommitedInternalParams(address indexed origin, address indexed sender, InternalParams params);

    
    
    
    
    
    
    
    
    event DeployedVault(
        address indexed origin,
        address indexed sender,
        address[] vaultTokens,
        bytes options,
        address owner,
        address vaultAddress,
        uint256 vaultNft
    );
}