// SPDX-License-Identifier: MIT


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
// Based on OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Enumerable.sol)
pragma solidity ^0.8.0;

/**
 * @title Adapted ERC-721 enumeration interface for escrow contracts
 */
interface IEnumerableEscrow {
	/**
	 * @dev Returns the users balance of tokens stored by the contract.
	 */
	function balanceOf(address owner) external view returns (uint256);

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

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

error CallerNotTheOwner();
error NewOwnerIsZeroAddress();

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
abstract contract Ownable {
	address private _contractOwner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	/**
	 * @dev Initializes the given owner as the initial owner.
	 */
	constructor(address contractOwner_) {
		_transferOwnership(contractOwner_);
	}

	/**
	 * @dev Returns the address of the current owner.
	 */
	function owner() public view virtual returns (address) {
		return _contractOwner;
	}

	/**
	 * @dev Throws if called by any account other than the owner.
	 */
	modifier onlyOwner() {
		if (owner() != msg.sender) revert CallerNotTheOwner();
		_;
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
		if (newOwner == address(0)) revert NewOwnerIsZeroAddress();
		_transferOwnership(newOwner);
	}

	/**
	 * @dev Transfers ownership of the contract to a new account (`newOwner`).
	 * Internal function without access restriction.
	 */
	function _transferOwnership(address newOwner) internal virtual {
		address oldOwner = _contractOwner;
		_contractOwner = newOwner;
		emit OwnershipTransferred(oldOwner, newOwner);
	}
}

// 
pragma solidity ^0.8.0;




interface IStakingHideout is IEnumerableEscrow {
	
	
	
	event RewardPaid(address indexed user, uint256 reward);

	
	
	
	event Stashed(address indexed user, uint256 indexed tokenId);

	
	
	
	event Unstashed(address indexed user, uint256 indexed tokenId);

	
	
	
	function stash(uint256 tokenId) external;

	
	
	/// allow the approval and transfer the StolenNFT in a single Transaction using EIP-2612 Permits
	/// Emits a {Stashed} Event and updates token rewards
	
	
	
	
	
	function stashWithPermit(
		uint256 tokenId,
		uint256 deadline,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external;

	
	
	
	function unstash(uint256 tokenId) external;

	
	
	
	function getStaker(uint256 tokenId) external view returns (address);

	
	function getReward() external;

	
	
	function rewardPerToken() external view returns (uint256);

	
	
	function earned(address account) external view returns (uint256);
}

// 
// Based on OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)
pragma solidity ^0.8.0;



error OwnerIndexOutOfBounds(uint256 index);
error GlobalIndexOutOfBounds(uint256 index);

/**
 * @title Adapted ERC-721 enumeration extension for escrow contracts
 */
abstract contract EnumerableEscrow is IEnumerableEscrow {
	// Mapping from owner to amount of tokens stored in escrow
	mapping(address => uint256) private _ownedTokenBalances;

	// Mapping from owner to list of owned token IDs
	mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

	// Mapping from token ID to index of the owner tokens list
	mapping(uint256 => uint256) private _ownedTokensIndex;

	// Array with all token ids, used for enumeration
	uint256[] private _allTokens;

	// Mapping from token id to position in the allTokens array
	mapping(uint256 => uint256) private _allTokensIndex;

	/**
	 * @dev See {IEnumerableEscrow-tokenOfOwnerByIndex}.
	 */
	function balanceOf(address owner) public view returns (uint256) {
		return _ownedTokenBalances[owner];
	}

	/**
	 * @dev See {IEnumerableEscrow-tokenOfOwnerByIndex}.
	 */
	function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
		if (index >= _ownedTokenBalances[owner]) revert OwnerIndexOutOfBounds(index);
		return _ownedTokens[owner][index];
	}

	/**
	 * @dev See {IEnumerableEscrow-totalSupply}.
	 */
	function totalSupply() public view returns (uint256) {
		return _allTokens.length;
	}

	/**
	 * @dev See {IEnumerableEscrow-tokenByIndex}.
	 */
	function tokenByIndex(uint256 index) public view returns (uint256) {
		if (index >= EnumerableEscrow.totalSupply()) revert GlobalIndexOutOfBounds(index);
		return _allTokens[index];
	}

	/**
	 * @dev Internal function to remove a token from this extension's token-and-ownership-tracking data structures.
	 * Checks whether token is part of the collection beforehand, so it can be used as part of token recovery
	 * @param owner address representing the previous owner of the given token ID
	 * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
	 */
	function _removeTokenFromEnumeration(address owner, uint256 tokenId) internal {
		_removeTokenFromAllTokensEnumeration(tokenId);
		_removeTokenFromOwnerEnumeration(owner, tokenId);
	}

	/**
	 * @dev Internal function to add a token to this extension's token-and-ownership-tracking data structures.
	 * @param owner address representing the new owner of the given token ID
	 * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
	 */
	function _addTokenToEnumeration(address owner, uint256 tokenId) internal {
		_addTokenToAllTokensEnumeration(tokenId);
		_addTokenToOwnerEnumeration(owner, tokenId);
	}

	/**
	 * @dev Private function to add a token to this extension's ownership-tracking data structures.
	 * @param owner address representing the new owner of the given token ID
	 * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
	 */
	function _addTokenToOwnerEnumeration(address owner, uint256 tokenId) private {
		uint256 length = _ownedTokenBalances[owner];
		_ownedTokens[owner][length] = tokenId;
		_ownedTokensIndex[tokenId] = length;
		_ownedTokenBalances[owner]++;
	}

	/**
	 * @dev Private function to add a token to this extension's token tracking data structures.
	 * @param tokenId uint256 ID of the token to be added to the tokens list
	 */
	function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
		_allTokensIndex[tokenId] = _allTokens.length;
		_allTokens.push(tokenId);
	}

	/**
	 * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
	 * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
	 * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
	 * This has O(1) time complexity, but alters the order of the _ownedTokens array.
	 * @param owner address representing the previous owner of the given token ID
	 * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
	 */
	function _removeTokenFromOwnerEnumeration(address owner, uint256 tokenId) private {
		// To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
		// then delete the last slot (swap and pop).

		uint256 lastTokenIndex = _ownedTokenBalances[owner] - 1;
		uint256 tokenIndex = _ownedTokensIndex[tokenId];

		// When the token to delete is the last token, the swap operation is unnecessary
		if (tokenIndex != lastTokenIndex) {
			uint256 lastTokenId = _ownedTokens[owner][lastTokenIndex];

			_ownedTokens[owner][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
			_ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
		}

		// This also deletes the contents at the last position of the array
		delete _ownedTokensIndex[tokenId];
		delete _ownedTokens[owner][lastTokenIndex];
		_ownedTokenBalances[owner]--;
	}

	/**
	 * @dev Private function to remove a token from this extension's token tracking data structures.
	 * This has O(1) time complexity, but alters the order of the _allTokens array.
	 * @param tokenId uint256 ID of the token to be removed from the tokens list
	 */
	function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
		// To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
		// then delete the last slot (swap and pop).

		uint256 lastTokenIndex = _allTokens.length - 1;
		uint256 tokenIndex = _allTokensIndex[tokenId];

		// When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
		// rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
		// an 'if' statement (like in _removeTokenFromOwnerEnumeration)
		uint256 lastTokenId = _allTokens[lastTokenIndex];

		_allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
		_allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

		// This also deletes the contents at the last position of the array
		delete _allTokensIndex[tokenId];
		_allTokens.pop();
	}
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
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;



/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

/// 

pragma solidity ^0.8.0;



/**
 * @dev Interface of extending the IERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC721 approval (see {IERC721-approval}) by
 * presenting a message signed by the account. By not relying on `{IERC721-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC721Permit is IERC20Permit {

}
// 
pragma solidity ^0.8.0;







error NotTheStaker();
error NotTheTokenOwner();
error StashIsFull();
error TokenNotStashed();



contract StakingHideout is IStakingHideout, EnumerableEscrow, Ownable {
	/// Maximum number of NFTs that can be staked per thief
	uint256 public balanceLimit = 5;
	/// The staking reward rate, default 100000eth/day = 100000/(60*60*24) = 1.1574074074
	uint256 public rewardRate = 1157407407407407407;
	/// Timestamp of the last time the calculations were run
	uint256 public lastUpdateTime;
	/// Stored reward rate for a staked token
	uint256 public rewardPerTokenStored;

	/// Amount of staker's rewards per token since the last update
	mapping(address => uint256) public userRewardPerTokenPaid;
	/// Amount of rewards earned by a staker that can be withdrawn
	mapping(address => uint256) public rewards;

	/// IERC721 token used to stake and earn rewards with
	IStolenNFT public stakingNft;
	/// IERC20 token used to pay rewards
	ICounterfeitMoney public rewardsToken;

	/// Mapping from a staked token to its staker
	mapping(uint256 => address) private _stakers;

	constructor(
		address _owner,
		address _stakingNft,
		address _rewardsToken
	) Ownable(_owner) {
		stakingNft = IStolenNFT(_stakingNft);
		rewardsToken = ICounterfeitMoney(_rewardsToken);
	}

	
	function stash(uint256 tokenId) public override updateReward(msg.sender) {
		if (stakingNft.ownerOf(tokenId) != msg.sender) revert NotTheTokenOwner();
		if (EnumerableEscrow.balanceOf(msg.sender) >= balanceLimit) revert StashIsFull();

		EnumerableEscrow._addTokenToEnumeration(msg.sender, tokenId);
		_stakers[tokenId] = msg.sender;

		emit Stashed(msg.sender, tokenId);

		stakingNft.transferFrom(msg.sender, address(this), tokenId);
	}

	
	function stashWithPermit(
		uint256 tokenId,
		uint256 deadline,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external override {
		stakingNft.permit(msg.sender, address(this), tokenId, deadline, v, r, s);
		stash(tokenId);
	}

	
	function unstash(uint256 tokenId) external override updateReward(_stakers[tokenId]) {
		address staker = _stakers[tokenId];
		if (msg.sender != staker && msg.sender != Ownable.owner()) revert NotTheStaker();

		EnumerableEscrow._removeTokenFromEnumeration(staker, tokenId);
		delete _stakers[tokenId];

		emit Unstashed(staker, tokenId);

		stakingNft.transferFrom(address(this), staker, tokenId);
	}

	
	
	
	function setRewardRate(uint256 _rewardRate) external onlyOwner updateReward(address(0)) {
		rewardRate = _rewardRate;
		emit RewardRateChange(_rewardRate);
	}

	
	
	
	function setBalanceLimit(uint256 _balanceLimit) external onlyOwner {
		balanceLimit = _balanceLimit;
		emit BalanceLimitChange(_balanceLimit);
	}

	
	function getStaker(uint256 tokenId) external view override returns (address) {
		if (_stakers[tokenId] == address(0)) revert TokenNotStashed();
		return _stakers[tokenId];
	}

	
	function getReward() external override updateReward(msg.sender) {
		uint256 reward = rewards[msg.sender];
		emit RewardPaid(msg.sender, reward);
		if (reward > 0) {
			rewards[msg.sender] = 0;
			rewardsToken.print(msg.sender, reward);
		}
	}

	
	function rewardPerToken() public view override returns (uint256) {
		if (EnumerableEscrow.totalSupply() == 0) {
			return rewardPerTokenStored;
		}

		return
			rewardPerTokenStored +
			(((block.timestamp - lastUpdateTime) * rewardRate * 1e18) /
				EnumerableEscrow.totalSupply());
	}

	
	function earned(address account) public view override returns (uint256) {
		return
			((EnumerableEscrow.balanceOf(account) *
				(rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) + rewards[account];
	}

	
	modifier updateReward(address account) {
		rewardPerTokenStored = rewardPerToken();
		lastUpdateTime = block.timestamp;
		if (account != address(0)) {
			rewards[account] = earned(account);
			userRewardPerTokenPaid[account] = rewardPerTokenStored;
		}
		_;
	}

	
	
	event RewardRateChange(uint256 newRewardRate);

	
	
	event BalanceLimitChange(uint256 newBalanceLimit);
}

// 
pragma solidity ^0.8.0;






interface ICounterfeitMoney is IERC20, IERC20Permit {
	
	
	
	
	function print(address to, uint256 amount) external;

	
	
	
	
	function burn(address from, uint256 amount) external;
}

// 
pragma solidity ^0.8.0;









interface IStolenNFT is IERC2981, IERC721Metadata, IERC721Enumerable, IERC721Permit {
	
	
	
	
	
	
	event Stolen(
		address indexed thief,
		uint64 originalChainId,
		address indexed originalContract,
		uint256 indexed originalId,
		uint256 stolenId
	);

	
	
	
	
	
	
	event Seized(
		address indexed thief,
		uint64 originalChainId,
		address originalContract,
		uint256 originalId,
		uint256 indexed stolenId
	);

	
	struct NftData {
		uint32 tokenRoyalty;
		uint64 chainId;
		address contractAddress;
		uint256 tokenId;
	}

	
	
	
	
	
	
	
	
	function steal(
		uint64 originalChainId,
		address originalAddress,
		uint256 originalId,
		address mintFrom,
		uint32 royaltyFee,
		string memory uri
	) external payable returns (uint256);

	
	
	
	function swatted(uint256 stolenId) external;

	
	
	
	function surrender(uint256 stolenId) external;

	
	
	
	
	function getStolen(address originalAddress, uint256 originalId)
		external
		view
		returns (uint256);

	
	
	
	
	
	function getOriginal(uint256 stolenId)
		external
		view
		returns (
			uint64,
			address,
			uint256
		);
}
