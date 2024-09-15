// SPDX-License-Identifier: MIT


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


interface ICriminalRecords {
	
	
	
	event Wanted(address indexed criminal, uint256 level);

	
	
	
	
	event Reported(address indexed snitch, address indexed thief, uint256 indexed stolenId);

	
	
	
	
	event Arrested(address indexed snitch, address indexed thief, uint256 indexed stolenId);

	
	struct Report {
		uint256 stolenId;
		uint256 timestamp;
	}

	
	
	function maximumWanted() external view returns (uint8);

	
	
	function sentence() external view returns (uint8);

	
	
	function thiefCaughtChance() external view returns (uint8);

	
	
	function reportDelay() external view returns (uint32);

	
	
	function reportValidity() external view returns (uint32);

	
	
	function bribePerLevel() external view returns (uint256);

	
	
	function reward() external view returns (uint256);

	
	
	/// then needed it will not be transferred / burned.
	/// Emits a {Wanted} Event
	
	
	
	function bribe(address criminal, uint256 amount) external returns (uint256);

	
	
	/// allow the approval and transfer of CounterfeitMoney in a single Transaction using EIP-2612 Permits
	/// Emits a {Wanted} Event
	
	
	
	
	
	
	
	function bribeCheque(
		address criminal,
		uint256 amount,
		uint256 deadline,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint256);

	
	
	
	function reportTheft(uint256 stolenId) external;

	
	/// If the arrest is successful the stolen NFT will be returned / burned
	/// If the thief gets away another report has to be filed
	
	
	function arrest() external returns (bool);

	
	
	
	function getWanted(address criminal) external view returns (uint256);

	// @notice Returns whether report data and processing state
	
	
	
	
	function getReport(address reporter)
		external
		view
		returns (
			uint256,
			uint256,
			bool
		);

	
	
	
	function crimeWitnessed(address criminal) external;

	
	
	
	
	function exchangeWitnessed(address from, address to) external;

	
	
	
	function surrender(address criminal) external;
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

}// 
pragma solidity ^0.8.0;







error BribeIsNotEnough();
error CaseNotFound();
error NotTheLaw();
error ProcessingReport();
error ReportAlreadyFiled();
error SurrenderInstead();
error SuspectNotWanted();
error TheftNotReported();
error ThiefGotAway();
error ThiefIsHiding();


contract CriminalRecords is ICriminalRecords, Ownable {
	
	uint8 public override maximumWanted = 50;
	
	uint8 public override sentence = 2;
	
	uint8 public override thiefCaughtChance = 40;
	
	uint32 public override reportDelay = 2 minutes;
	
	uint32 public override reportValidity = 24 hours;
	
	uint256 public override reward = 100 ether;
	
	uint256 public override bribePerLevel = 100 ether;

	/// ERC20 token used to pay bribes and rewards
	ICounterfeitMoney public money;
	/// ERC721 token which is being monitored by the authorities
	IStolenNFT public stolenNFT;
	/// Contracts that cannot be sentenced
	mapping(address => bool) public aboveTheLaw;
	/// Officers / Contracts that can track and sentence others
	mapping(address => bool) public theLaw;

	/// Tracking the reports for identification
	uint256 private _caseNumber;
	/// Tracking the crime reporters and the time since their last report
	mapping(address => Report) private _reports;
	/// Tracking the criminals and their wanted level
	mapping(address => uint8) private _wantedLevel;

	constructor(
		address _owner,
		address _stolenNft,
		address _money,
		address _stakingHideout,
		address _blackMarket
	) Ownable(_owner) {
		stolenNFT = IStolenNFT(_stolenNft);
		money = ICounterfeitMoney(_money);

		theLaw[_stolenNft] = true;
		aboveTheLaw[address(0)] = true;
		aboveTheLaw[_stakingHideout] = true;
		aboveTheLaw[_blackMarket] = true;
	}

	
	function bribe(address criminal, uint256 amount) public override returns (uint256) {
		uint256 wantedLevel = _wantedLevel[criminal];
		if (wantedLevel == 0) revert SuspectNotWanted();
		if (amount < bribePerLevel) revert BribeIsNotEnough();

		uint256 levels = amount / bribePerLevel;
		if (wantedLevel < levels) {
			levels = wantedLevel;
		}
		uint256 cost = levels * bribePerLevel;

		_decreaseWanted(criminal, uint8(levels));

		money.burn(msg.sender, cost);

		return levels;
	}

	
	function bribeCheque(
		address criminal,
		uint256 amount,
		uint256 deadline,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external override returns (uint256) {
		money.permit(criminal, address(this), amount, deadline, v, r, s);
		return bribe(criminal, amount);
	}

	
	function reportTheft(uint256 stolenId) external override {
		address holder = stolenNFT.ownerOf(stolenId);

		if (msg.sender == holder) revert SurrenderInstead();
		if (aboveTheLaw[holder]) revert ThiefIsHiding();
		if (_wantedLevel[holder] == 0) revert SuspectNotWanted();
		if (
			_reports[msg.sender].stolenId == stolenId &&
			block.timestamp - _reports[msg.sender].timestamp <= reportValidity
		) revert ReportAlreadyFiled();

		_reports[msg.sender] = Report(stolenId, block.timestamp);

		emit Reported(msg.sender, holder, stolenId);
	}

	
	function arrest() external override returns (bool) {
		Report memory report = _reports[msg.sender];
		if (report.stolenId == 0) revert TheftNotReported();
		if (block.timestamp - report.timestamp < reportDelay) revert ProcessingReport();
		if (block.timestamp - report.timestamp > reportValidity) revert ThiefGotAway();

		delete _reports[msg.sender];
		_caseNumber++;

		address holder = stolenNFT.ownerOf(report.stolenId);
		uint256 holderWanted = _wantedLevel[holder];

		uint256 kindaRandom = uint256(
			keccak256(
				abi.encodePacked(
					_caseNumber,
					holder,
					holderWanted,
					report.timestamp,
					block.timestamp,
					blockhash(block.number)
				)
			)
		) % 100; //0-100

		// Arrest is not possible if thief managed to hide or get rid of wanted level
		bool arrested = !aboveTheLaw[holder] &&
			holderWanted > 0 &&
			kindaRandom < thiefCaughtChance + holderWanted;

		if (arrested) {
			_increaseWanted(holder, sentence);

			emit Arrested(msg.sender, holder, report.stolenId);

			stolenNFT.swatted(report.stolenId);

			money.print(msg.sender, reward * holderWanted);
		}

		return arrested;
	}

	
	function crimeWitnessed(address criminal) external override onlyTheLaw {
		_increaseWanted(criminal, sentence);
	}

	
	function exchangeWitnessed(address from, address to) external override onlyTheLaw {
		if (_wantedLevel[from] > 0 && from != to) {
			_increaseWanted(to, sentence);
		}
	}

	
	function surrender(address criminal) external override onlyTheLaw {
		_decreaseWanted(criminal, sentence);
	}

	
	
	
	
	
	
	
	
	function setWantedParameters(
		uint8 _maxWanted,
		uint8 _sentence,
		uint8 _thiefCaughtChance,
		uint32 _reportDelay,
		uint32 _reportValidity,
		uint256 _reward,
		uint256 _bribePerLevel
	) external onlyOwner {
		maximumWanted = _maxWanted;
		sentence = _sentence;
		thiefCaughtChance = _thiefCaughtChance;
		reportDelay = _reportDelay;
		reportValidity = _reportValidity;
		reward = _reward;
		bribePerLevel = _bribePerLevel;

		emit WantedParamChange(
			maximumWanted,
			sentence,
			thiefCaughtChance,
			reportDelay,
			reportValidity,
			reward,
			bribePerLevel
		);
	}

	
	
	
	
	function setAboveTheLaw(address badgeNumber, bool state) public onlyOwner {
		aboveTheLaw[badgeNumber] = state;
		emit Promotion(badgeNumber, true, state);
	}

	
	
	
	
	function setTheLaw(address badgeNumber, bool state) external onlyOwner {
		theLaw[badgeNumber] = state;
		emit Promotion(badgeNumber, false, state);
	}

	
	function getReport(address reporter)
		external
		view
		returns (
			uint256,
			uint256,
			bool
		)
	{
		if (_reports[reporter].stolenId == 0) revert CaseNotFound();
		bool processed = block.timestamp - _reports[reporter].timestamp >= reportDelay &&
			block.timestamp - _reports[reporter].timestamp <= reportValidity;

		return (_reports[reporter].stolenId, _reports[reporter].timestamp, processed);
	}

	
	function getWanted(address criminal) external view override returns (uint256) {
		return _wantedLevel[criminal];
	}

	
	
	/// aboveTheLaw[msg.sender] avoids increasing e.g. the BlackMarket buyers wanted level
	
	
	function _increaseWanted(address criminal, uint8 increase) internal {
		if (aboveTheLaw[criminal] || aboveTheLaw[msg.sender]) return;

		uint8 currentLevel = _wantedLevel[criminal];
		uint8 nextLevel;

		unchecked {
			nextLevel = currentLevel + increase;
		}
		if (nextLevel < currentLevel || nextLevel > maximumWanted) {
			nextLevel = maximumWanted;
		}

		_wantedLevel[criminal] = nextLevel;
		emit Wanted(criminal, nextLevel);
	}

	
	
	
	
	function _decreaseWanted(address criminal, uint8 decrease) internal {
		if (aboveTheLaw[criminal] || aboveTheLaw[msg.sender]) return;

		uint8 currentLevel = _wantedLevel[criminal];
		uint8 nextLevel = 0;

		if (currentLevel > maximumWanted) {
			currentLevel = maximumWanted;
		}

		unchecked {
			if (decrease < currentLevel) {
				nextLevel = currentLevel - decrease;
			}
		}

		_wantedLevel[criminal] = nextLevel;
		emit Wanted(criminal, nextLevel);
	}

	
	modifier onlyTheLaw() {
		if (!theLaw[msg.sender]) revert NotTheLaw();
		_;
	}

	
	
	
	
	event Promotion(address indexed user, bool aboveTheLaw, bool state);

	
	
	
	
	
	
	
	
	event WantedParamChange(
		uint8 maxWanted,
		uint8 sentence,
		uint256 thiefCaughtChance,
		uint256 reportDelay,
		uint256 reportValidity,
		uint256 reward,
		uint256 bribePerLevel
	);
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
