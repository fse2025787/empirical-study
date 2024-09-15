// SPDX-License-Identifier: MIT


// 
pragma solidity ^0.8.10;




interface ISafeOwnable {
    ///                                                          ///
    ///                            EVENTS                        ///
    ///                                                          ///

    
    
    
    event OwnerUpdated(address indexed prevOwner, address indexed newOwner);

    
    
    
    event OwnerPending(address indexed owner, address indexed pendingOwner);

    
    
    
    event OwnerCanceled(address indexed owner, address indexed canceledOwner);

    ///                                                          ///
    ///                            ERRORS                        ///
    ///                                                          ///

    
    error ONLY_OWNER();

    
    error ONLY_PENDING_OWNER();

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    function owner() external view returns (address);

    
    function pendingOwner() external view returns (address);

    
    
    function transferOwnership(address newOwner) external;

    
    
    function safeTransferOwnership(address newOwner) external;

    
    function acceptOwnership() external;

    
    function cancelOwnershipTransfer() external;
}

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
pragma solidity ^0.8.10;






/// - Uses custom errors declared in IOwnable
/// - Adds optional two-step ownership transfer (`safeTransferOwnership` + `acceptOwnership`)
contract SafeOwnable is ISafeOwnable {
    ///                                                          ///
    ///                            STORAGE                       ///
    ///                                                          ///

    
    address internal _owner;

    
    address internal _pendingOwner;

    ///                                                          ///
    ///                           MODIFIERS                      ///
    ///                                                          ///

    
    modifier onlyOwner() {
        if (msg.sender != _owner) revert ONLY_OWNER();
        _;
    }

    
    modifier onlyPendingOwner() {
        if (msg.sender != _pendingOwner) revert ONLY_PENDING_OWNER();
        _;
    }

    ///                                                          ///
    ///                           FUNCTIONS                      ///
    ///                                                          ///

    
    
    function __Ownable_init(address _initialOwner) internal {
        _owner = _initialOwner;

        emit OwnerUpdated(address(0), _initialOwner);
    }

    
    function owner() public virtual view returns (address) {
        return _owner;
    }

    
    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    
    
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    
    
    
    function _transferOwnership(address _newOwner) internal {
        emit OwnerUpdated(_owner, _newOwner);

        _owner = _newOwner;

        if (_pendingOwner != address(0)) delete _pendingOwner;
    }

    
    
    function safeTransferOwnership(address _newOwner) public onlyOwner {
        _pendingOwner = _newOwner;

        emit OwnerPending(_owner, _newOwner);
    }

    
    function acceptOwnership() public onlyPendingOwner {
        emit OwnerUpdated(_owner, msg.sender);

        _owner = _pendingOwner;

        delete _pendingOwner;
    }

    
    function cancelOwnershipTransfer() public onlyOwner {
        emit OwnerCanceled(_owner, _pendingOwner);

        delete _pendingOwner;
    }
}// 
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;



// 
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// 
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
}

// 
pragma solidity ^0.8.10;



/**

 ________   _____   ____    ______      ____
/\_____  \ /\  __`\/\  _`\ /\  _  \    /\  _`\
\/____//'/'\ \ \/\ \ \ \L\ \ \ \L\ \   \ \ \/\ \  _ __   ___   _____     ____
     //'/'  \ \ \ \ \ \ ,  /\ \  __ \   \ \ \ \ \/\`'__\/ __`\/\ '__`\  /',__\
    //'/'___ \ \ \_\ \ \ \\ \\ \ \/\ \   \ \ \_\ \ \ \//\ \L\ \ \ \L\ \/\__, `\
    /\_______\\ \_____\ \_\ \_\ \_\ \_\   \ \____/\ \_\\ \____/\ \ ,__/\/\____/
    \/_______/ \/_____/\/_/\/ /\/_/\/_/    \/___/  \/_/ \/___/  \ \ \/  \/___/
                                                                 \ \_\
                                                                  \/_/

*/


interface IERC721Drop {
    // Access errors

    
    error Access_OnlyAdmin();
    
    error Access_MissingRoleOrAdmin(bytes32 role);
    
    error Access_WithdrawNotAllowed();
    
    error Withdraw_FundsSendFailure();

    // Sale/Purchase errors
    
    error Sale_Inactive();
    
    error Presale_Inactive();
    
    error Presale_MerkleNotApproved();
    
    error Purchase_WrongPrice(uint256 correctPrice);
    
    error Mint_SoldOut();
    
    error Purchase_TooManyForAddress();
    
    error Presale_TooManyForAddress();

    // Admin errors
    
    error Setup_RoyaltyPercentageTooHigh(uint16 maxRoyaltyBPS);
    
    error Admin_InvalidUpgradeAddress(address proposedAddress);
    
    error Admin_UnableToFinalizeNotOpenEdition();

    
    
    
    
    
    event Sale(
        address indexed to,
        uint256 indexed quantity,
        uint256 indexed pricePerToken,
        uint256 firstPurchasedTokenId
    );

    
    
    
    event SalesConfigChanged(address indexed changedBy);

    
    
    
    event FundsRecipientChanged(
        address indexed newAddress,
        address indexed changedBy
    );

    
    
    
    
    
    
    event FundsWithdrawn(
        address indexed withdrawnBy,
        address indexed withdrawnTo,
        uint256 amount,
        address feeRecipient,
        uint256 feeAmount
    );

    
    
    
    event OpenMintFinalized(address indexed sender, uint256 numberOfMints);

    
    
    
    event UpdatedMetadataRenderer(address sender, IMetadataRenderer renderer);


    
    struct Configuration {
        
        IMetadataRenderer metadataRenderer;
        
        uint64 editionSize;
        
        uint16 royaltyBPS;
        
        address payable fundsRecipient;
    }

    
    
    struct SalesConfiguration {
        
        uint104 publicSalePrice;
        
        
        uint32 maxSalePurchasePerAddress;
        
        
        uint64 publicSaleStart;
        
        uint64 publicSaleEnd;
        
        
        uint64 presaleStart;
        
        uint64 presaleEnd;
        
        bytes32 presaleMerkleRoot;
    }

    
    struct SaleDetails {
        // Synthesized status variables for sale and presale
        bool publicSaleActive;
        bool presaleActive;
        // Price for public sale
        uint256 publicSalePrice;
        // Timed sale actions for public sale
        uint64 publicSaleStart;
        uint64 publicSaleEnd;
        // Timed sale actions for presale
        uint64 presaleStart;
        uint64 presaleEnd;
        // Merkle root (includes address, quantity, and price data for each entry)
        bytes32 presaleMerkleRoot;
        // Limit public sale to a specific number of mints per wallet
        uint256 maxSalePurchasePerAddress;
        // Information about the rest of the supply
        // Total that have been minted
        uint256 totalMinted;
        // The total supply available
        uint256 maxSupply;
    }

    
    struct AddressMintDetails {
        /// Number of total mints from the given address
        uint256 totalMints;
        /// Number of presale mints from the given address
        uint256 presaleMints;
        /// Number of public mints from the given address
        uint256 publicMints;
    }

    
    
    
    function purchase(uint256 quantity) external payable returns (uint256);

    
    
    
    
    
    
    function purchasePresale(
        uint256 quantity,
        uint256 maxQuantity,
        uint256 pricePerToken,
        bytes32[] memory merkleProof
    ) external payable returns (uint256);

    
    function saleDetails() external view returns (SaleDetails memory);

    
    
    function mintedPerAddress(address minter)
        external
        view
        returns (AddressMintDetails memory);

    
    function owner() external view returns (address);

    
    
    
    function setMetadataRenderer(IMetadataRenderer newRenderer, bytes memory setupRenderer) external;

    
    
    
    
    function adminMint(address to, uint256 quantity) external returns (uint256);

    
    
    
    function adminMintAirdrop(address[] memory to) external returns (uint256);

    
    
    function isAdmin(address user) external view returns (bool);
}

// 
pragma solidity ^0.8.10;

interface IMetadataRenderer {
    function tokenURI(uint256) external view returns (string memory);
    function contractURI() external view returns (string memory);
    function initializeWithData(bytes memory initData) external;
}

// 
pragma solidity ^0.8.10;






// This is the token-gated (noun owners) minting Disco minting contract
contract ERC721NounsExchangeSwapMinter is SafeOwnable {
    IERC721 internal immutable nounsToken; // the nouns contract
    IERC721Drop internal immutable discoGlasses; // the disco contract
    uint256 public maxAirdropCutoffNounId; // max number of free disco units
    uint256 public costPerNoun; // cost of each disco unit

    uint256 public claimPeriodEnd; // end of the claim period

    mapping(uint256 => bool) public claimedPerNoun; // nounId => isClaimed

    error ClaimPeriodOver();
    error MustWaitUntilAfterClaimPeriod();
    error NotQualifiedForAirdrop();
    error QualifiedForAirdrop();
    error YouNeedToOwnTheNoun();
    error YouAlreadyMinted();
    error WrongPrice();

    event ClaimedFromNoun(
        address indexed claimee,
        uint256 newId,
        uint256 nounId
    );

    event UpdatedMaxAirdropCutoffNounId(uint256);

    constructor(
        address _nounsToken,
        address _discoGlasses,
        uint256 _maxAirdropCutoffNounId,
        uint256 _costPerNoun,
        address _initialOwner,
        uint256 _claimPeriodEnd
    ) {
        // Set variables
        discoGlasses = IERC721Drop(_discoGlasses);
        nounsToken = IERC721(_nounsToken);
        maxAirdropCutoffNounId = _maxAirdropCutoffNounId;
        costPerNoun = _costPerNoun;
        claimPeriodEnd = _claimPeriodEnd;

        // Setup ownership
        __Ownable_init(_initialOwner);
    }

    
    function updateAirdropQuantity(uint256 _maxAirdropCutoffNounId)
        external
        onlyOwner
    {
        maxAirdropCutoffNounId = _maxAirdropCutoffNounId;
        emit UpdatedMaxAirdropCutoffNounId(_maxAirdropCutoffNounId);
    }

    
    function updateCostPerNoun(uint256 _newCost) external onlyOwner {
        costPerNoun = _newCost;
    }

    
    function updateClaimPeriodEnd(uint256 _claimPeriodEnd) external onlyOwner {
        claimPeriodEnd = _claimPeriodEnd;
    }

    // internal minting function which checks if the noun has been claimed
    // and then mints a disco unit
    function _mintWithNoun(uint256 nounId) internal returns (uint256) {
        if (claimedPerNoun[nounId]) {
            revert YouAlreadyMinted();
        }

        claimedPerNoun[nounId] = true;

        // make an admin mint
        uint256 newId = discoGlasses.adminMint(msg.sender, 1);

        emit ClaimedFromNoun(msg.sender, newId, nounId);

        return newId;
    }

    function claimAirdrop(uint256[] memory nounIds)
        external
        returns (uint256 mintedId)
    {
        if (block.timestamp > claimPeriodEnd) {
            revert ClaimPeriodOver();
        }
        // check to see if the current time is within the airdrop claim period
        // go to each nounID and check if the sender is the current owner of the nounID
        for (uint256 i = 0; i < nounIds.length; i++) {
            uint256 nounID = nounIds[i];
            if (nounsToken.ownerOf(nounID) != msg.sender) {
                revert YouNeedToOwnTheNoun();
            }

            // if the user provided nounID is outside the airdrop range, revert.
            if (nounID >= maxAirdropCutoffNounId) {
                revert NotQualifiedForAirdrop();
            }

            // If your noun ID qualifies for the aidrop, then mint a disco unit
            mintedId = _mintWithNoun(nounIds[i]);
        }

        return mintedId;
    }

    function mintDiscoWithNouns(uint256[] memory nounIds)
        external
        payable
        returns (uint256 mintedId)
    {
        // TODO: If the airdrop claim period is over open it up for everyone
        // if the total minted is greater than the airdrop max count, then the user must pay
        if (msg.value != nounIds.length * costPerNoun) {
            revert WrongPrice();
        }

        // for each of nounIDs passed check if the sender is the current owner of the nounID
        // if so, mint a disco unit, and set the nounID to claimed.
        // if the sender doesnt own the noun ID, revert
        for (uint256 i = 0; i < nounIds.length; i++) {
            uint256 nounID = nounIds[i];

            // if the user is not the owner of the nounID, revert.
            if (nounsToken.ownerOf(nounID) != msg.sender) {
                revert YouNeedToOwnTheNoun();
            }

            // checks while claim period is active
            if (block.timestamp < claimPeriodEnd) {
                // if the user provided nounID is within the aidrop,
                // revert because they qualify for an airdrop.
                if (nounID < maxAirdropCutoffNounId) {
                    revert QualifiedForAirdrop();
                }

                // During the claim period, only nounIDs that are less than the max supply
                // are allowed to buy a disco unit. If the nounID is greater than the max supply
                // of the disco units, revert.
                if (nounID >= discoGlasses.saleDetails().maxSupply) {
                    revert MustWaitUntilAfterClaimPeriod();
                }
            }

            mintedId = _mintWithNoun(nounID);
        }
        return mintedId;
    }

    function withdraw() external onlyOwner {
        Address.sendValue(payable(owner()), address(this).balance);
    }
}
