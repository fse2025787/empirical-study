
/**
 *Submitted for verification at Etherscan.io on 2022-12-13
*/

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

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

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// File: contracts/interfaces/IXDEFIDistribution.sol



pragma solidity =0.8.12;


interface IXDEFIDistribution is IERC721Enumerable {
    /***********/
    /* Structs */
    /***********/

    struct Position {
        uint96 units; // 240,000,000,000,000,000,000,000,000 XDEFI * 2.55x bonus (which fits in a `uint96`).
        uint88 depositedXDEFI; // XDEFI cap is 240000000000000000000000000 (which fits in a `uint88`).
        uint32 expiry; // block timestamps for the next 50 years (which fits in a `uint32`).
        uint32 created;
        uint256 pointsCorrection;
    }

    /**********/
    /* Errors */
    /**********/

    error BeyondConsumeLimit();
    error CannotUnlock();
    error ConsumePermitExpired();
    error EmptyArray();
    error IncorrectBonusMultiplier();
    error InsufficientAmountUnlocked();
    error InsufficientCredits();
    error InvalidConsumePermit();
    error InvalidDuration();
    error InvalidMultiplier();
    error InvalidToken();
    error LockingIsDisabled();
    error LockResultsInTooFewUnits();
    error MustMergeMultiple();
    error NoReentering();
    error NoUnitSupply();
    error NotApprovedOrOwnerOfToken();
    error NotInEmergencyMode();
    error PositionAlreadyUnlocked();
    error PositionStillLocked();
    error TokenDoesNotExist();
    error Unauthorized();

    /**********/
    /* Events */
    /**********/

    
    event BaseURISet(string baseURI);

    
    event CreditsConsumed(uint256 indexed tokenId, address indexed consumer, uint256 amount);

    
    event DistributionUpdated(address indexed caller, uint256 amount);

    
    event EmergencyModeActivated();

    
    event LockPeriodSet(uint256 indexed duration, uint256 indexed bonusMultiplier);

    
    event LockPositionCreated(uint256 indexed tokenId, address indexed owner, uint256 amount, uint256 indexed duration);

    
    event LockPositionWithdrawn(uint256 indexed tokenId, address indexed owner, uint256 amount);

    
    event OwnershipAccepted(address indexed previousOwner, address indexed owner);

    
    event OwnershipProposed(address indexed owner, address indexed pendingOwner);

    
    event TokensMerged(uint256[] mergedTokenIds, uint256 tokenId, uint256 credits);

    /*************/
    /* Constants */
    /*************/

    
    function DOMAIN_SEPARATOR() external view returns (bytes32 domainSeparator_);

    
    function MINIMUM_UNITS() external view returns (uint256 minimumUnits_);

    /*********/
    /* State */
    /*********/

    
    function baseURI() external view returns (string memory baseURI_);

    
    function bonusMultiplierOf(uint256 duration_) external view returns (uint256 bonusMultiplier_);

    
    function consumePermitNonce(uint256 tokenId_) external view returns (uint256 nonce_);

    
    function creditsOf(uint256 tokenId_) external view returns (uint256 credits_);

    
    function distributableXDEFI() external view returns (uint256 distributableXDEFI_);

    
    function inEmergencyMode() external view returns (bool lockingDisabled_);

    
    function owner() external view returns (address owner_);

    
    function pendingOwner() external view returns (address pendingOwner_);

    
    function positionOf(uint256 tokenId_) external view returns (Position memory position_);

    
    function totalDepositedXDEFI() external view returns (uint256 totalDepositedXDEFI_);

    
    function totalUnits() external view returns (uint256 totalUnits_);

    
    function xdefi() external view returns (address XDEFI_);

    /*******************/
    /* Admin Functions */
    /*******************/

    
    function acceptOwnership() external;

    
    function activateEmergencyMode() external;

    
    function proposeOwnership(address newOwner_) external;

    
    function setBaseURI(string calldata baseURI_) external;

    
    function setLockPeriods(uint256[] calldata durations_, uint256[] calldata multipliers) external;

    /**********************/
    /* Position Functions */
    /**********************/

    
    function emergencyUnlock(uint256 tokenId_, address destination_) external returns (uint256 amountUnlocked_);

    
    function getBonusMultiplierOf(uint256 tokenId_) external view returns (uint256 bonusMultiplier_);

    
    function lock(
        uint256 amount_,
        uint256 duration_,
        uint256 bonusMultiplier_,
        address destination_
    ) external returns (uint256 tokenId_);

    
    function lockWithPermit(
        uint256 amount_,
        uint256 duration_,
        uint256 bonusMultiplier_,
        address destination_,
        uint256 deadline_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external returns (uint256 tokenId_);

    
    function relock(
        uint256 tokenId_,
        uint256 lockAmount_,
        uint256 duration_,
        uint256 bonusMultiplier_,
        address destination_
    ) external returns (uint256 amountUnlocked_, uint256 newTokenId_);

    
    function unlock(uint256 tokenId_, address destination_) external returns (uint256 amountUnlocked_);

    
    function updateDistribution() external;

    
    function withdrawableOf(uint256 tokenId_) external view returns (uint256 withdrawableXDEFI_);

    /****************************/
    /* Batch Position Functions */
    /****************************/

    
    function relockBatch(
        uint256[] calldata tokenIds_,
        uint256 lockAmount_,
        uint256 duration_,
        uint256 bonusMultiplier_,
        address destination_
    ) external returns (uint256 amountUnlocked_, uint256 newTokenId_);

    
    function unlockBatch(uint256[] calldata tokenIds_, address destination_) external returns (uint256 amountUnlocked_);

    /*****************/
    /* NFT Functions */
    /*****************/

    
    function attributesOf(uint256 tokenId_)
        external
        view
        returns (
            uint256 tier_,
            uint256 credits_,
            uint256 withdrawable_,
            uint256 expiry_
        );

    
    function consume(uint256 tokenId_, uint256 amount_) external returns (uint256 remainingCredits_);

    
    function consumeWithPermit(
        uint256 tokenId_,
        uint256 amount_,
        uint256 limit_,
        uint256 deadline_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external returns (uint256 remainingCredits_);

    
    function contractURI() external view returns (string memory contractURI_);

    
    function getCredits(uint256 amount_, uint256 duration_) external pure returns (uint256 credits_);

    
    function getTier(uint256 credits_) external pure returns (uint256 tier_);

    
    function merge(uint256[] calldata tokenIds_) external returns (uint256 tokenId_, uint256 credits_);

    
    function tokenURI(uint256 tokenId_) external view returns (string memory tokenURI_);
}

// File: contracts/interfaces/IXDEFIDistributionHelper.sol



pragma solidity =0.8.12;


interface IXDEFIDistributionLike {
    struct Position {
        uint96 units;
        uint88 depositedXDEFI;
        uint32 expiry;
        uint32 created;
        uint256 pointsCorrection;
    }

    function balanceOf(address account_) external view returns (uint256 balance_);

    function creditsOf(uint256 tokenId_) external view returns (uint256 credits_);

    function positionOf(uint256 tokenId_) external view returns (Position memory position_);

    function tokenOfOwnerByIndex(address account_, uint256 index_) external view returns (uint256 tokenId_);

    function withdrawableOf(uint256 tokenId_) external view returns (uint256 withdrawableXDEFI_);
}

interface IXDEFIDistributionHelper {
    function getAllTokensForAccount(address xdefiDistribution_, address account_) external view returns (uint256[] memory tokenIds_);

    function getAllTokensAndCreditsForAccount(address xdefiDistribution_, address account_) external view returns (uint256[] memory tokenIds_, uint256[] memory credits_);

    function getAllLockedPositionsForAccount(address xdefiDistribution_, address account_)
        external
        view
        returns (
            uint256[] memory tokenIds_,
            IXDEFIDistributionLike.Position[] memory positions_,
            uint256[] memory withdrawables_
        );

    function getAllLockedPositionsAndCreditsForAccount(address xdefiDistribution_, address account_)
        external
        view
        returns (
            uint256[] memory tokenIds_,
            IXDEFIDistributionLike.Position[] memory positions_,
            uint256[] memory withdrawables_,
            uint256[] memory credits_
        );
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/4_XDEFIDistributionHelper2.sol



pragma solidity =0.8.12;




contract XDEFIDistributionHelper2 is Ownable {

    address public xdefiAddress;
    address public xdefiDistributionHelperAddress;

    constructor() {
    }

    function setConfig(address xdefiAddress_, address xdefiDistributionHelperAddress_) public onlyOwner {
        xdefiAddress = xdefiAddress_;
        xdefiDistributionHelperAddress = xdefiDistributionHelperAddress_;
    }

    
    function balanceOfStakedXDEFI(address account_) public view returns (uint256 totalStakedXDEFI) {
        IXDEFIDistributionLike.Position[] memory positions;
        
        (, positions, ) = IXDEFIDistributionHelper(xdefiDistributionHelperAddress).getAllLockedPositionsForAccount(xdefiAddress, account_);

        totalStakedXDEFI = 0;
        for (uint256 i; i < positions.length; ) {
            totalStakedXDEFI += uint256(positions[i].depositedXDEFI);

            unchecked {
                ++i;
            }
        }
    }

}