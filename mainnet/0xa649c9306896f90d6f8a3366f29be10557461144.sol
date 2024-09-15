// SPDX-License-Identifier: MIT
pragma abicoder v2;


// 

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
pragma solidity ^0.8.6;






interface IDCAPairParameters {
  
  
  
  function globalParameters() external view returns (IDCAGlobalParameters);

  
  
  function tokenA() external view returns (IERC20Metadata);

  
  
  function tokenB() external view returns (IERC20Metadata);

  
  
  
  
  
  
  function swapAmountDelta(
    uint32 _swapInterval,
    address _from,
    uint32 _swap
  ) external view returns (int256 _delta);

  
  
  
  
  function isSwapIntervalActive(uint32 _swapInterval) external view returns (bool _isActive);

  
  
  
  function performedSwaps(uint32 _swapInterval) external view returns (uint32 _swaps);
}

// 
pragma solidity ^0.8.6;











abstract contract DCAPairParameters is IDCAPairParameters {
  using EnumerableSet for EnumerableSet.UintSet;

  // Internal constants
  uint112 internal _magnitudeA;
  uint112 internal _magnitudeB;
  uint24 internal _feePrecision;

  // Basic setup
  IDCAGlobalParameters public override globalParameters;
  IERC20Metadata public override tokenA;
  IERC20Metadata public override tokenB;

  // Tracking
  mapping(uint32 => mapping(address => mapping(uint32 => int256))) public override swapAmountDelta; // swap interval => from token => swap number => delta
  mapping(uint32 => uint32) public override performedSwaps; // swap interval => performed swaps
  mapping(uint32 => mapping(address => mapping(uint32 => uint256))) internal _accumRatesPerUnit; // swap interval => from token => swap number => accum
  mapping(address => uint256) internal _balances;
  EnumerableSet.UintSet internal _activeSwapIntervals;

  constructor(
    IDCAGlobalParameters _globalParameters,
    IERC20Metadata _tokenA,
    IERC20Metadata _tokenB
  ) {
    if (address(_globalParameters) == address(0) || address(_tokenA) == address(0) || address(_tokenB) == address(0))
      revert CommonErrors.ZeroAddress();
    globalParameters = _globalParameters;
    _feePrecision = globalParameters.FEE_PRECISION();
    tokenA = _tokenA;
    tokenB = _tokenB;
    _magnitudeA = uint112(10**_tokenA.decimals());
    _magnitudeB = uint112(10**_tokenB.decimals());
  }

  function isSwapIntervalActive(uint32 _activeSwapInterval) external view override returns (bool _isIntervalActive) {
    _isIntervalActive = _activeSwapIntervals.contains(_activeSwapInterval);
  }

  function _getFeeFromAmount(uint32 _feeAmount, uint256 _amount) internal view returns (uint256) {
    return (_amount * _feeAmount) / _feePrecision / 100;
  }
}

// 

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

pragma solidity ^0.8.0;

/*
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

// 

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



interface IDCAPairPositionHandler is IDCAPairParameters {
  
  struct UserPosition {
    // The token that the user deposited and will be swapped in exchange for "to"
    IERC20Metadata from;
    // The token that the user will get in exchange for their "from" tokens in each swap
    IERC20Metadata to;
    // How frequently the position's swaps should be executed
    uint32 swapInterval;
    // How many swaps were executed since deposit, last modification, or last withdraw
    uint32 swapsExecuted;
    // How many "to" tokens can currently be withdrawn
    uint256 swapped;
    // How many swaps left the position has to execute
    uint32 swapsLeft;
    // How many "from" tokens there are left to swap
    uint256 remaining;
    // How many "from" tokens need to be traded in each swap
    uint160 rate;
  }

  
  
  
  
  
  event Terminated(address indexed _user, uint256 _dcaId, uint256 _returnedUnswapped, uint256 _returnedSwapped);

  
  
  
  
  
  
  
  
  event Deposited(
    address indexed _user,
    uint256 _dcaId,
    address _fromToken,
    uint160 _rate,
    uint32 _startingSwap,
    uint32 _swapInterval,
    uint32 _lastSwap
  );

  
  
  
  
  
  event Withdrew(address indexed _user, uint256 _dcaId, address _token, uint256 _amount);

  
  
  
  
  
  event WithdrewMany(address indexed _user, uint256[] _dcaIds, uint256 _swappedTokenA, uint256 _swappedTokenB);

  
  
  
  
  
  
  event Modified(address indexed _user, uint256 _dcaId, uint160 _rate, uint32 _startingSwap, uint32 _lastSwap);

  
  error InvalidToken();

  
  error InvalidInterval();

  
  error InvalidPosition();

  
  error UnauthorizedCaller();

  
  error ZeroRate();

  
  error ZeroSwaps();

  
  error ZeroAmount();

  
  error PositionCompleted();

  
  /// is thrown so that the user doesn't lose any funds. The error indicates that the user must perform a withdraw
  /// before modifying their position
  error MandatoryWithdraw();

  
  
  
  function userPosition(uint256 _dcaId) external view returns (UserPosition memory _position);

  
  
  /// With InvalidToken if _tokenAddress is neither token A nor token B
  /// With ZeroRate if _rate is zero
  /// With ZeroSwaps if _amountOfSwaps is zero
  /// With InvalidInterval if _swapInterval is not a valid swap interval
  
  
  
  
  
  function deposit(
    address _tokenAddress,
    uint160 _rate,
    uint32 _amountOfSwaps,
    uint32 _swapInterval
  ) external returns (uint256 _dcaId);

  
  
  /// With InvalidPosition if _dcaId is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position
  
  
  function withdrawSwapped(uint256 _dcaId) external returns (uint256 _swapped);

  
  
  /// With InvalidPosition if any of the ids in _dcaIds is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to any of the positions in _dcaIds
  
  
  
  function withdrawSwappedMany(uint256[] calldata _dcaIds) external returns (uint256 _swappedTokenA, uint256 _swappedTokenB);

  
  /// depending on whether the new rate is greater than the previous one.
  
  /// With InvalidPosition if _dcaId is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position
  /// With PositionCompleted if position has already been completed
  /// With ZeroRate if _newRate is zero
  /// With MandatoryWithdraw if the user must execute a withdraw before modifying their position
  
  
  function modifyRate(uint256 _dcaId, uint160 _newRate) external;

  
  /// deposited funds depending on whether the new amount of swaps is greater than the swaps left.
  
  /// With InvalidPosition if _dcaId is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position
  /// With MandatoryWithdraw if the user must execute a withdraw before modifying their position
  
  
  function modifySwaps(uint256 _dcaId, uint32 _newSwaps) external;

  
  /// deposited funds depending on whether the new parameters require more or less than the the unswapped funds.
  
  /// With InvalidPosition if _dcaId is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position
  /// With ZeroRate if _newRate is zero
  /// With MandatoryWithdraw if the user must execute a withdraw before modifying their position
  
  
  
  function modifyRateAndSwaps(
    uint256 _dcaId,
    uint160 _newRate,
    uint32 _newSwaps
  ) external;

  
  /// it is executed in _newSwaps swaps
  
  /// With InvalidPosition if _dcaId is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position
  /// With ZeroAmount if _amount is zero
  /// With ZeroSwaps if _newSwaps is zero
  /// With MandatoryWithdraw if the user must execute a withdraw before modifying their position
  
  
  
  function addFundsToPosition(
    uint256 _dcaId,
    uint256 _amount,
    uint32 _newSwaps
  ) external;

  
  
  /// With InvalidPosition if _dcaId is invalid
  /// With UnauthorizedCaller if the caller doesn't have access to the position
  
  function terminate(uint256 _dcaId) external;
}



interface IDCAPairSwapHandler {
  
  struct SwapInformation {
    // The affected swap interval
    uint32 interval;
    // The number of the swap that will be performed
    uint32 swapToPerform;
    // The amount of token A that needs swapping
    uint256 amountToSwapTokenA;
    // The amount of token B that needs swapping
    uint256 amountToSwapTokenB;
  }

  
  struct NextSwapInformation {
    // All swaps that can be executed
    SwapInformation[] swapsToPerform;
    // How many entries of the swapsToPerform array are valid
    uint8 amountOfSwaps;
    // How much can be borrowed in token A during a flash swap
    uint256 availableToBorrowTokenA;
    // How much can be borrowed in token B during a flash swap
    uint256 availableToBorrowTokenB;
    // How much 10**decimals(tokenB) is when converted to token A
    uint256 ratePerUnitBToA;
    // How much 10**decimals(tokenA) is when converted to token B
    uint256 ratePerUnitAToB;
    // How much token A will be sent to the platform in terms of fee
    uint256 platformFeeTokenA;
    // How much token B will be sent to the platform in terms of fee
    uint256 platformFeeTokenB;
    // The amount of tokens that need to be provided by the swapper
    uint256 amountToBeProvidedBySwapper;
    // The amount of tokens that will be sent to the swapper optimistically
    uint256 amountToRewardSwapperWith;
    // The token that needs to be provided by the swapper
    IERC20Metadata tokenToBeProvidedBySwapper;
    // The token that will be sent to the swapper optimistically
    IERC20Metadata tokenToRewardSwapperWith;
  }

  
  
  
  
  
  
  
  event Swapped(
    address indexed _sender,
    address indexed _to,
    uint256 _amountBorrowedTokenA,
    uint256 _amountBorrowedTokenB,
    uint32 _fee,
    NextSwapInformation _nextSwapInformation
  );

  
  error NoSwapsToExecute();

  
  
  
  /// be in the past
  function nextSwapAvailable(uint32 _swapInterval) external view returns (uint32 _when);

  
  
  
  
  function swapAmountAccumulator(uint32 _swapInterval, address _from) external view returns (uint256);

  
  
  function getNextSwapInfo() external view returns (NextSwapInformation memory _nextSwapInformation);

  
  
  /// Paused if swaps are paused by protocol
  /// NoSwapsToExecute if there are no swaps to execute
  /// LiquidityNotReturned if the required tokens were not sent before calling the function
  function swap() external;

  
  
  /// Paused if swaps are paused by protocol
  /// NoSwapsToExecute if there are no swaps to execute
  /// InsufficientLiquidity if asked to borrow more than the actual reserves
  /// LiquidityNotReturned if the required tokens were not back during the callback
  
  
  
  
  function swap(
    uint256 _amountToBorrowTokenA,
    uint256 _amountToBorrowTokenB,
    address _to,
    bytes calldata _data
  ) external;

  
  
  function secondsUntilNextSwap() external view returns (uint32 _secondsUntilNextSwap);
}



interface IDCAPairLoanHandler {
  
  
  
  
  
  
  event Loaned(address indexed _sender, address indexed _to, uint256 _amountBorrowedTokenA, uint256 _amountBorrowedTokenB, uint32 _loanFee);

  // @notice Thrown when trying to execute a flash loan but without actually asking for tokens
  error ZeroLoan();

  
  
  
  function availableToBorrow() external view returns (uint256 _amountToBorrowTokenA, uint256 _amountToBorrowTokenB);

  
  
  /// With ZeroLoan if both _amountToBorrowTokenA & _amountToBorrowTokenB are 0
  /// With Paused if loans are paused by protocol
  /// With InsufficientLiquidity if asked for more that reserves
  
  
  
  
  function loan(
    uint256 _amountToBorrowTokenA,
    uint256 _amountToBorrowTokenB,
    address _to,
    bytes calldata _data
  ) external;
}

// 

pragma solidity ^0.8.0;









/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// 

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
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// 
pragma solidity ^0.8.6;






abstract contract DCAPairPositionHandler is ReentrancyGuard, DCAPairParameters, IDCAPairPositionHandler, ERC721 {
  struct DCA {
    uint32 lastWithdrawSwap;
    uint32 lastSwap;
    uint32 swapInterval;
    uint160 rate;
    bool fromTokenA;
    uint248 swappedBeforeModified;
  }

  using SafeERC20 for IERC20Metadata;
  using EnumerableSet for EnumerableSet.UintSet;

  mapping(uint256 => DCA) internal _userPositions;
  uint256 internal _idCounter;

  constructor(IERC20Metadata _tokenA, IERC20Metadata _tokenB)
    ERC721(string(abi.encodePacked('DCA: ', _tokenA.symbol(), ' - ', _tokenB.symbol())), 'DCA')
  {}

  function userPosition(uint256 _dcaId) external view override returns (UserPosition memory _userPosition) {
    DCA memory _position = _userPositions[_dcaId];
    _userPosition.from = _position.fromTokenA ? tokenA : tokenB;
    _userPosition.to = _position.fromTokenA ? tokenB : tokenA;
    _userPosition.swapInterval = _position.swapInterval;
    _userPosition.swapsExecuted = _position.swapInterval > 0 ? performedSwaps[_position.swapInterval] - _position.lastWithdrawSwap : 0;
    _userPosition.swapped = _calculateSwapped(_dcaId);
    _userPosition.swapsLeft = _position.lastSwap > performedSwaps[_position.swapInterval]
      ? _position.lastSwap - performedSwaps[_position.swapInterval]
      : 0;
    _userPosition.remaining = _calculateUnswapped(_dcaId);
    _userPosition.rate = _position.rate;
  }

  function deposit(
    address _tokenAddress,
    uint160 _rate,
    uint32 _amountOfSwaps,
    uint32 _swapInterval
  ) external override nonReentrant returns (uint256) {
    if (_tokenAddress != address(tokenA) && _tokenAddress != address(tokenB)) revert InvalidToken();
    if (_amountOfSwaps == 0) revert ZeroSwaps();
    if (!_activeSwapIntervals.contains(_swapInterval) && !globalParameters.isSwapIntervalAllowed(_swapInterval)) revert InvalidInterval();
    IERC20Metadata _from = _tokenAddress == address(tokenA) ? tokenA : tokenB;
    uint256 _amount = _rate * _amountOfSwaps;
    _from.safeTransferFrom(msg.sender, address(this), _amount);
    _balances[_tokenAddress] += _amount;
    _idCounter += 1;
    _safeMint(msg.sender, _idCounter);
    _activeSwapIntervals.add(_swapInterval);
    (uint32 _startingSwap, uint32 _lastSwap) = _addPosition(_idCounter, _tokenAddress, _rate, _amountOfSwaps, 0, _swapInterval);
    emit Deposited(msg.sender, _idCounter, _tokenAddress, _rate, _startingSwap, _swapInterval, _lastSwap);
    return _idCounter;
  }

  function withdrawSwapped(uint256 _dcaId) external override nonReentrant returns (uint256 _swapped) {
    _assertPositionExistsAndCanBeOperatedByCaller(_dcaId);

    _swapped = _calculateSwapped(_dcaId);

    _userPositions[_dcaId].lastWithdrawSwap = performedSwaps[_userPositions[_dcaId].swapInterval];
    _userPositions[_dcaId].swappedBeforeModified = 0;

    IERC20Metadata _to = _getTo(_dcaId);
    _balances[address(_to)] -= _swapped;
    _to.safeTransfer(msg.sender, _swapped);

    emit Withdrew(msg.sender, _dcaId, address(_to), _swapped);
  }

  function withdrawSwappedMany(uint256[] calldata _dcaIds)
    external
    override
    nonReentrant
    returns (uint256 _swappedTokenA, uint256 _swappedTokenB)
  {
    for (uint256 i; i < _dcaIds.length; i++) {
      uint256 _dcaId = _dcaIds[i];
      _assertPositionExistsAndCanBeOperatedByCaller(_dcaId);
      uint256 _swappedDCA = _calculateSwapped(_dcaId);
      if (_userPositions[_dcaId].fromTokenA) {
        _swappedTokenB += _swappedDCA;
      } else {
        _swappedTokenA += _swappedDCA;
      }
      _userPositions[_dcaId].lastWithdrawSwap = performedSwaps[_userPositions[_dcaId].swapInterval];
      _userPositions[_dcaId].swappedBeforeModified = 0;
    }

    if (_swappedTokenA > 0) {
      _balances[address(tokenA)] -= _swappedTokenA;
      tokenA.safeTransfer(msg.sender, _swappedTokenA);
    }

    if (_swappedTokenB > 0) {
      _balances[address(tokenB)] -= _swappedTokenB;
      tokenB.safeTransfer(msg.sender, _swappedTokenB);
    }
    emit WithdrewMany(msg.sender, _dcaIds, _swappedTokenA, _swappedTokenB);
  }

  function terminate(uint256 _dcaId) external override nonReentrant {
    _assertPositionExistsAndCanBeOperatedByCaller(_dcaId);

    uint256 _swapped = _calculateSwapped(_dcaId);
    uint256 _unswapped = _calculateUnswapped(_dcaId);

    IERC20Metadata _from = _getFrom(_dcaId);
    IERC20Metadata _to = _getTo(_dcaId);
    _removePosition(_dcaId);
    _burn(_dcaId);

    if (_swapped > 0) {
      _balances[address(_to)] -= _swapped;
      _to.safeTransfer(msg.sender, _swapped);
    }

    if (_unswapped > 0) {
      _balances[address(_from)] -= _unswapped;
      _from.safeTransfer(msg.sender, _unswapped);
    }

    emit Terminated(msg.sender, _dcaId, _unswapped, _swapped);
  }

  function modifyRate(uint256 _dcaId, uint160 _newRate) external override nonReentrant {
    _assertPositionExistsAndCanBeOperatedByCaller(_dcaId);
    uint32 _swapsLeft = _userPositions[_dcaId].lastSwap - performedSwaps[_userPositions[_dcaId].swapInterval];
    if (_swapsLeft == 0) revert PositionCompleted();

    _modifyRateAndSwaps(_dcaId, _newRate, _swapsLeft);
  }

  function modifySwaps(uint256 _dcaId, uint32 _newSwaps) external override nonReentrant {
    _modifyRateAndSwaps(_dcaId, _userPositions[_dcaId].rate, _newSwaps);
  }

  function modifyRateAndSwaps(
    uint256 _dcaId,
    uint160 _newRate,
    uint32 _newAmountOfSwaps
  ) external override nonReentrant {
    _modifyRateAndSwaps(_dcaId, _newRate, _newAmountOfSwaps);
  }

  function addFundsToPosition(
    uint256 _dcaId,
    uint256 _amount,
    uint32 _newSwaps
  ) external override nonReentrant {
    if (_amount == 0) revert ZeroAmount();
    if (_newSwaps == 0) revert ZeroSwaps();

    uint256 _unswapped = _calculateUnswapped(_dcaId);
    uint256 _total = _unswapped + _amount;

    _modifyPosition(_dcaId, _total, _unswapped, uint160(_total / _newSwaps), _newSwaps);
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    return globalParameters.nftDescriptor().tokenURI(this, tokenId);
  }

  /** Helper function to modify a position */
  function _modifyRateAndSwaps(
    uint256 _dcaId,
    uint160 _newRate,
    uint32 _newAmountOfSwaps
  ) internal {
    _modifyPosition(_dcaId, _newRate * _newAmountOfSwaps, _calculateUnswapped(_dcaId), _newRate, _newAmountOfSwaps);
  }

  function _modifyPosition(
    uint256 _dcaId,
    uint256 _totalNecessary,
    uint256 _unswapped,
    uint160 _newRate,
    uint32 _newAmountOfSwaps
  ) internal {
    _assertPositionExistsAndCanBeOperatedByCaller(_dcaId);
    IERC20Metadata _from = _getFrom(_dcaId);

    uint256 _swapped = _calculateSwapped(_dcaId);
    if (_swapped > type(uint248).max) revert MandatoryWithdraw(); // You should withdraw before modifying, to avoid losing funds

    uint32 _swapInterval = _userPositions[_dcaId].swapInterval;
    _removePosition(_dcaId);
    (uint32 _startingSwap, uint32 _lastSwap) = _addPosition(
      _dcaId,
      address(_from),
      _newRate,
      _newAmountOfSwaps,
      uint248(_swapped),
      _swapInterval
    );

    if (_totalNecessary > _unswapped) {
      // We need to ask for more funds
      _from.safeTransferFrom(msg.sender, address(this), _totalNecessary - _unswapped);
      _balances[address(_from)] += _totalNecessary - _unswapped;
    } else if (_totalNecessary < _unswapped) {
      // We need to return to the owner the amount that won't be used anymore
      _balances[address(_from)] -= _unswapped - _totalNecessary;
      _from.safeTransfer(msg.sender, _unswapped - _totalNecessary);
    }

    emit Modified(msg.sender, _dcaId, _newRate, _startingSwap, _lastSwap);
  }

  function _assertPositionExistsAndCanBeOperatedByCaller(uint256 _dcaId) internal view {
    if (_userPositions[_dcaId].rate == 0) revert InvalidPosition();
    if (!_isApprovedOrOwner(msg.sender, _dcaId)) revert UnauthorizedCaller();
  }

  function _addPosition(
    uint256 _dcaId,
    address _from,
    uint160 _rate,
    uint32 _amountOfSwaps,
    uint248 _swappedBeforeModified,
    uint32 _swapInterval
  ) internal returns (uint32 _startingSwap, uint32 _lastSwap) {
    if (_rate == 0) revert ZeroRate();
    uint32 _performedSwaps = performedSwaps[_swapInterval];
    _startingSwap = _performedSwaps + 1;
    _lastSwap = _performedSwaps + _amountOfSwaps;
    swapAmountDelta[_swapInterval][_from][_startingSwap] += int160(_rate);
    swapAmountDelta[_swapInterval][_from][_lastSwap + 1] -= int160(_rate);
    _userPositions[_dcaId] = DCA(_performedSwaps, _lastSwap, _swapInterval, _rate, _from == address(tokenA), _swappedBeforeModified);
  }

  function _removePosition(uint256 _dcaId) internal {
    uint32 _swapInterval = _userPositions[_dcaId].swapInterval;
    uint32 _lastSwap = _userPositions[_dcaId].lastSwap;
    uint32 _performedSwaps = performedSwaps[_swapInterval];

    if (_lastSwap > _performedSwaps) {
      int160 _rate = int160(_userPositions[_dcaId].rate);
      address _from = address(_getFrom(_dcaId));
      swapAmountDelta[_swapInterval][_from][_performedSwaps + 1] -= _rate;
      swapAmountDelta[_swapInterval][_from][_lastSwap + 1] += _rate;
    }
    delete _userPositions[_dcaId];
  }

  /** Returns the amount of tokens swapped in TO */
  function _calculateSwapped(uint256 _dcaId) internal view returns (uint256 _swapped) {
    DCA memory _userDCA = _userPositions[_dcaId];
    address _from = _userDCA.fromTokenA ? address(tokenA) : address(tokenB);
    uint256 _accumRatesLastSwap = _accumRatesPerUnit[_userDCA.swapInterval][_from][
      performedSwaps[_userDCA.swapInterval] < _userDCA.lastSwap ? performedSwaps[_userDCA.swapInterval] : _userDCA.lastSwap
    ];

    uint256 _accumPerUnit = _accumRatesLastSwap - _accumRatesPerUnit[_userDCA.swapInterval][_from][_userDCA.lastWithdrawSwap];
    uint256 _magnitude = _userDCA.fromTokenA ? _magnitudeA : _magnitudeB;
    (bool _ok, uint256 _mult) = Math.tryMul(_accumPerUnit, _userDCA.rate);
    uint256 _swappedInCurrentPosition = _ok ? _mult / _magnitude : (_accumPerUnit / _magnitude) * _userDCA.rate;
    _swapped = _swappedInCurrentPosition + _userDCA.swappedBeforeModified;
  }

  /** Returns how many FROM remains unswapped  */
  function _calculateUnswapped(uint256 _dcaId) internal view returns (uint256 _unswapped) {
    uint32 _performedSwaps = performedSwaps[_userPositions[_dcaId].swapInterval];
    uint32 _lastSwap = _userPositions[_dcaId].lastSwap;

    if (_lastSwap <= _performedSwaps) return 0;
    _unswapped = (_lastSwap - _performedSwaps) * _userPositions[_dcaId].rate;
  }

  function _getFrom(uint256 _dcaId) internal view returns (IERC20Metadata _from) {
    _from = _userPositions[_dcaId].fromTokenA ? tokenA : tokenB;
  }

  function _getTo(uint256 _dcaId) internal view returns (IERC20Metadata _to) {
    _to = _userPositions[_dcaId].fromTokenA ? tokenB : tokenA;
  }
}

// 
pragma solidity ^0.8.6;









abstract contract DCAPairSwapHandler is ReentrancyGuard, DCAPairParameters, IDCAPairSwapHandler {
  using SafeERC20 for IERC20Metadata;
  using EnumerableSet for EnumerableSet.UintSet;

  mapping(uint32 => mapping(address => uint256)) public override swapAmountAccumulator; // swap interval => from token => swap amount accum

  mapping(uint32 => uint32) public override nextSwapAvailable; // swap interval => timestamp

  function _addNewRatePerUnit(
    uint32 _swapInterval,
    address _address,
    uint32 _performedSwap,
    uint256 _ratePerUnit
  ) internal {
    uint256 _accumRatesPerUnitPreviousSwap = _accumRatesPerUnit[_swapInterval][_address][_performedSwap - 1];
    _accumRatesPerUnit[_swapInterval][_address][_performedSwap] = _accumRatesPerUnitPreviousSwap + _ratePerUnit;
  }

  function _registerSwap(
    uint32 _swapInterval,
    address _token,
    uint256 _internalAmountUsedToSwap,
    uint256 _ratePerUnit,
    uint32 _swapToRegister
  ) internal {
    swapAmountAccumulator[_swapInterval][_token] = _internalAmountUsedToSwap;
    _addNewRatePerUnit(_swapInterval, _token, _swapToRegister, _ratePerUnit);
    delete swapAmountDelta[_swapInterval][_token][_swapToRegister];
  }

  function _getAmountToSwap(
    uint32 _swapInterval,
    address _address,
    uint32 _swapToPerform
  ) internal view returns (uint256 _swapAmountAccumulator) {
    unchecked {
      _swapAmountAccumulator =
        swapAmountAccumulator[_swapInterval][_address] +
        uint256(swapAmountDelta[_swapInterval][_address][_swapToPerform]);
    }
  }

  function _convertTo(
    uint256 _fromTokenMagnitude,
    uint256 _amountFrom,
    uint256 _rateFromTo
  ) internal pure returns (uint256 _amountTo) {
    _amountTo = (_amountFrom * _rateFromTo) / _fromTokenMagnitude;
  }

  function _getNextSwapsToPerform() internal view virtual returns (SwapInformation[] memory _swapsToPerform, uint8 _amountOfSwapsToPerform) {
    uint256 _activeSwapIntervalsLength = _activeSwapIntervals.length();
    _swapsToPerform = new SwapInformation[](_activeSwapIntervalsLength);
    for (uint256 i; i < _activeSwapIntervalsLength; i++) {
      uint32 _swapInterval = uint32(_activeSwapIntervals.at(i));
      if (nextSwapAvailable[_swapInterval] <= _getTimestamp()) {
        uint32 _swapToPerform = performedSwaps[_swapInterval] + 1;
        _swapsToPerform[_amountOfSwapsToPerform++] = SwapInformation({
          interval: _swapInterval,
          swapToPerform: _swapToPerform,
          amountToSwapTokenA: _getAmountToSwap(_swapInterval, address(tokenA), _swapToPerform),
          amountToSwapTokenB: _getAmountToSwap(_swapInterval, address(tokenB), _swapToPerform)
        });
      }
    }
  }

  function secondsUntilNextSwap() external view override returns (uint32 _secondsUntil) {
    _secondsUntil = type(uint32).max;
    uint32 _timestamp = _getTimestamp();
    for (uint256 i; i < _activeSwapIntervals.length(); i++) {
      uint32 _swapInterval = uint32(_activeSwapIntervals.at(i));
      if (nextSwapAvailable[_swapInterval] <= _timestamp) {
        _secondsUntil = 0;
        break;
      } else {
        uint32 _diff = nextSwapAvailable[_swapInterval] - _timestamp;
        if (_diff < _secondsUntil) {
          _secondsUntil = _diff;
        }
      }
    }
  }

  function getNextSwapInfo() external view override returns (NextSwapInformation memory _nextSwapInformation) {
    IDCAGlobalParameters.SwapParameters memory _swapParameters = globalParameters.swapParameters();
    (_nextSwapInformation, , ) = _getNextSwapInfo(_swapParameters.swapFee, _swapParameters.oracle);
  }

  function _getNextSwapInfo(uint32 _swapFee, ITimeWeightedOracle _oracle)
    internal
    view
    virtual
    returns (
      NextSwapInformation memory _nextSwapInformation,
      uint256 _ratePerUnitBToAWithFee,
      uint256 _ratePerUnitAToBWithFee
    )
  {
    uint256 _amountToSwapTokenA;
    uint256 _amountToSwapTokenB;
    {
      (SwapInformation[] memory _swapsToPerform, uint8 _amountOfSwaps) = _getNextSwapsToPerform();
      for (uint256 i; i < _amountOfSwaps; i++) {
        _amountToSwapTokenA += _swapsToPerform[i].amountToSwapTokenA;
        _amountToSwapTokenB += _swapsToPerform[i].amountToSwapTokenB;
      }
      _nextSwapInformation.swapsToPerform = _swapsToPerform;
      _nextSwapInformation.amountOfSwaps = _amountOfSwaps;
    }

    _nextSwapInformation.ratePerUnitBToA = _oracle.quote(address(tokenB), _magnitudeB, address(tokenA));
    _nextSwapInformation.ratePerUnitAToB = (uint256(_magnitudeB) * _magnitudeA) / _nextSwapInformation.ratePerUnitBToA;

    _ratePerUnitBToAWithFee = _nextSwapInformation.ratePerUnitBToA - _getFeeFromAmount(_swapFee, _nextSwapInformation.ratePerUnitBToA);
    _ratePerUnitAToBWithFee = _nextSwapInformation.ratePerUnitAToB - _getFeeFromAmount(_swapFee, _nextSwapInformation.ratePerUnitAToB);

    uint256 _finalNeededTokenA = _convertTo(_magnitudeB, _amountToSwapTokenB, _ratePerUnitBToAWithFee);
    uint256 _finalNeededTokenB = _convertTo(_magnitudeA, _amountToSwapTokenA, _ratePerUnitAToBWithFee);

    uint256 _amountOfTokenAIfTokenBSwapped = _convertTo(_magnitudeB, _amountToSwapTokenB, _nextSwapInformation.ratePerUnitBToA);
    if (_amountOfTokenAIfTokenBSwapped < _amountToSwapTokenA) {
      _nextSwapInformation.tokenToBeProvidedBySwapper = tokenB;
      _nextSwapInformation.tokenToRewardSwapperWith = tokenA;
      _nextSwapInformation.platformFeeTokenA = _getFeeFromAmount(_swapFee, _amountOfTokenAIfTokenBSwapped);
      _nextSwapInformation.platformFeeTokenB = _getFeeFromAmount(_swapFee, _amountToSwapTokenB);
      _nextSwapInformation.amountToBeProvidedBySwapper = _finalNeededTokenB + _nextSwapInformation.platformFeeTokenB - _amountToSwapTokenB;
      _nextSwapInformation.amountToRewardSwapperWith = _amountToSwapTokenA - _finalNeededTokenA - _nextSwapInformation.platformFeeTokenA;
      _nextSwapInformation.availableToBorrowTokenA = _balances[address(tokenA)] - _nextSwapInformation.amountToRewardSwapperWith;
      _nextSwapInformation.availableToBorrowTokenB = _balances[address(tokenB)];
    } else if (_amountOfTokenAIfTokenBSwapped > _amountToSwapTokenA) {
      _nextSwapInformation.tokenToBeProvidedBySwapper = tokenA;
      _nextSwapInformation.tokenToRewardSwapperWith = tokenB;
      _nextSwapInformation.platformFeeTokenA = _getFeeFromAmount(_swapFee, _amountToSwapTokenA);
      _nextSwapInformation.platformFeeTokenB = _getFeeFromAmount(
        _swapFee,
        (_amountToSwapTokenA * _magnitudeB) / _nextSwapInformation.ratePerUnitBToA
      );
      _nextSwapInformation.amountToBeProvidedBySwapper = _finalNeededTokenA + _nextSwapInformation.platformFeeTokenA - _amountToSwapTokenA;
      _nextSwapInformation.amountToRewardSwapperWith = _amountToSwapTokenB - _finalNeededTokenB - _nextSwapInformation.platformFeeTokenB;
      _nextSwapInformation.availableToBorrowTokenA = _balances[address(tokenA)];
      _nextSwapInformation.availableToBorrowTokenB = _balances[address(tokenB)] - _nextSwapInformation.amountToRewardSwapperWith;
    } else {
      _nextSwapInformation.platformFeeTokenA = _getFeeFromAmount(_swapFee, _amountToSwapTokenA);
      _nextSwapInformation.platformFeeTokenB = _getFeeFromAmount(_swapFee, _amountToSwapTokenB);
      _nextSwapInformation.availableToBorrowTokenA = _balances[address(tokenA)];
      _nextSwapInformation.availableToBorrowTokenB = _balances[address(tokenB)];
    }
  }

  function swap() external override {
    swap(0, 0, msg.sender, '');
  }

  function swap(
    uint256 _amountToBorrowTokenA,
    uint256 _amountToBorrowTokenB,
    address _to,
    bytes memory _data
  ) public override nonReentrant {
    IDCAGlobalParameters.SwapParameters memory _swapParameters = globalParameters.swapParameters();
    if (_swapParameters.isPaused) revert CommonErrors.Paused();

    NextSwapInformation memory _nextSwapInformation;

    {
      uint256 _ratePerUnitBToAWithFee;
      uint256 _ratePerUnitAToBWithFee;
      (_nextSwapInformation, _ratePerUnitBToAWithFee, _ratePerUnitAToBWithFee) = _getNextSwapInfo(
        _swapParameters.swapFee,
        _swapParameters.oracle
      );
      if (_nextSwapInformation.amountOfSwaps == 0) revert NoSwapsToExecute();

      uint32 _timestamp = _getTimestamp();
      for (uint256 i; i < _nextSwapInformation.amountOfSwaps; i++) {
        uint32 _swapInterval = _nextSwapInformation.swapsToPerform[i].interval;
        uint32 _swapToPerform = _nextSwapInformation.swapsToPerform[i].swapToPerform;
        if (_nextSwapInformation.swapsToPerform[i].amountToSwapTokenA > 0 || _nextSwapInformation.swapsToPerform[i].amountToSwapTokenB > 0) {
          _registerSwap(
            _swapInterval,
            address(tokenA),
            _nextSwapInformation.swapsToPerform[i].amountToSwapTokenA,
            _ratePerUnitAToBWithFee,
            _swapToPerform
          );
          _registerSwap(
            _swapInterval,
            address(tokenB),
            _nextSwapInformation.swapsToPerform[i].amountToSwapTokenB,
            _ratePerUnitBToAWithFee,
            _swapToPerform
          );
          performedSwaps[_swapInterval] = _swapToPerform;
          nextSwapAvailable[_swapInterval] = ((_timestamp / _swapInterval) + 1) * _swapInterval;
        } else {
          _activeSwapIntervals.remove(_swapInterval);
        }
      }
    }

    if (
      _amountToBorrowTokenA > _nextSwapInformation.availableToBorrowTokenA ||
      _amountToBorrowTokenB > _nextSwapInformation.availableToBorrowTokenB
    ) revert CommonErrors.InsufficientLiquidity();

    uint256 _finalAmountToHaveTokenA = _nextSwapInformation.availableToBorrowTokenA - _nextSwapInformation.platformFeeTokenA;
    uint256 _finalAmountToHaveTokenB = _nextSwapInformation.availableToBorrowTokenB - _nextSwapInformation.platformFeeTokenB;

    {
      // scope for _amountToSendToken{A,B}, avoids stack too deep errors
      uint256 _amountToSendTokenA = _amountToBorrowTokenA;
      uint256 _amountToSendTokenB = _amountToBorrowTokenB;

      if (_nextSwapInformation.tokenToRewardSwapperWith == tokenA) {
        _amountToSendTokenA += _nextSwapInformation.amountToRewardSwapperWith;
        _finalAmountToHaveTokenB += _nextSwapInformation.amountToBeProvidedBySwapper;
      } else {
        _amountToSendTokenB += _nextSwapInformation.amountToRewardSwapperWith;
        _finalAmountToHaveTokenA += _nextSwapInformation.amountToBeProvidedBySwapper;
      }

      // Optimistically transfer tokens
      if (_amountToSendTokenA > 0) tokenA.safeTransfer(_to, _amountToSendTokenA);
      if (_amountToSendTokenB > 0) tokenB.safeTransfer(_to, _amountToSendTokenB);
    }

    if (_data.length > 0) {
      // Make call
      IDCAPairSwapCallee(_to).DCAPairSwapCall(
        msg.sender,
        tokenA,
        tokenB,
        _amountToBorrowTokenA,
        _amountToBorrowTokenB,
        _nextSwapInformation.tokenToRewardSwapperWith == tokenA,
        _nextSwapInformation.amountToRewardSwapperWith,
        _nextSwapInformation.amountToBeProvidedBySwapper,
        _data
      );
    }

    uint256 _balanceTokenA = tokenA.balanceOf(address(this));
    uint256 _balanceTokenB = tokenB.balanceOf(address(this));

    // Make sure that they sent the tokens back
    if (
      _balanceTokenA < (_finalAmountToHaveTokenA + _nextSwapInformation.platformFeeTokenA) ||
      _balanceTokenB < (_finalAmountToHaveTokenB + _nextSwapInformation.platformFeeTokenB)
    ) revert CommonErrors.LiquidityNotReturned();

    // Update balances
    _balances[address(tokenA)] = _finalAmountToHaveTokenA;
    _balances[address(tokenB)] = _finalAmountToHaveTokenB;

    // Send fees and extra
    uint256 _toFeeRecipientTokenA = _balanceTokenA - _finalAmountToHaveTokenA;
    uint256 _toFeeRecipientTokenB = _balanceTokenB - _finalAmountToHaveTokenB;
    if (_toFeeRecipientTokenA > 0) tokenA.safeTransfer(_swapParameters.feeRecipient, _toFeeRecipientTokenA);
    if (_toFeeRecipientTokenB > 0) tokenB.safeTransfer(_swapParameters.feeRecipient, _toFeeRecipientTokenB);

    // Emit event
    emit Swapped(msg.sender, _to, _amountToBorrowTokenA, _amountToBorrowTokenB, _swapParameters.swapFee, _nextSwapInformation);
  }

  function _getTimestamp() internal view virtual returns (uint32 _blockTimestamp) {
    _blockTimestamp = uint32(block.timestamp);
  }
}

// 
pragma solidity ^0.8.6;








abstract contract DCAPairLoanHandler is ReentrancyGuard, DCAPairParameters, IDCAPairLoanHandler {
  using SafeERC20 for IERC20Metadata;

  function availableToBorrow() external view override returns (uint256 _amountToBorrowTokenA, uint256 _amountToBorrowTokenB) {
    _amountToBorrowTokenA = _balances[address(tokenA)];
    _amountToBorrowTokenB = _balances[address(tokenB)];
  }

  function loan(
    uint256 _amountToBorrowTokenA,
    uint256 _amountToBorrowTokenB,
    address _to,
    bytes calldata _data
  ) external override nonReentrant {
    if (_amountToBorrowTokenA == 0 && _amountToBorrowTokenB == 0) revert ZeroLoan();

    IDCAGlobalParameters.LoanParameters memory _loanParameters = globalParameters.loanParameters();

    if (_loanParameters.isPaused) revert CommonErrors.Paused();

    uint256 _beforeBalanceTokenA = _balances[address(tokenA)];
    uint256 _beforeBalanceTokenB = _balances[address(tokenB)];

    if (_amountToBorrowTokenA > _beforeBalanceTokenA || _amountToBorrowTokenB > _beforeBalanceTokenB)
      revert CommonErrors.InsufficientLiquidity();

    // Calculate fees
    uint256 _feeTokenA = _amountToBorrowTokenA > 0 ? _getFeeFromAmount(_loanParameters.loanFee, _amountToBorrowTokenA) : 0;
    uint256 _feeTokenB = _amountToBorrowTokenB > 0 ? _getFeeFromAmount(_loanParameters.loanFee, _amountToBorrowTokenB) : 0;

    if (_amountToBorrowTokenA > 0) tokenA.safeTransfer(_to, _amountToBorrowTokenA);
    if (_amountToBorrowTokenB > 0) tokenB.safeTransfer(_to, _amountToBorrowTokenB);

    // Make call
    IDCAPairLoanCallee(_to).DCAPairLoanCall(
      msg.sender,
      tokenA,
      tokenB,
      _amountToBorrowTokenA,
      _amountToBorrowTokenB,
      _feeTokenA,
      _feeTokenB,
      _data
    );

    uint256 _afterBalanceTokenA = tokenA.balanceOf(address(this));
    uint256 _afterBalanceTokenB = tokenB.balanceOf(address(this));

    // Make sure that they sent the tokens back
    if (_afterBalanceTokenA < (_beforeBalanceTokenA + _feeTokenA) || _afterBalanceTokenB < (_beforeBalanceTokenB + _feeTokenB))
      revert CommonErrors.LiquidityNotReturned();

    {
      // Send fees and extra (if any)
      uint256 _toFeeRecipientTokenA = _afterBalanceTokenA - _beforeBalanceTokenA;
      uint256 _toFeeRecipientTokenB = _afterBalanceTokenB - _beforeBalanceTokenB;
      if (_toFeeRecipientTokenA > 0) tokenA.safeTransfer(_loanParameters.feeRecipient, _toFeeRecipientTokenA);
      if (_toFeeRecipientTokenB > 0) tokenB.safeTransfer(_loanParameters.feeRecipient, _toFeeRecipientTokenB);
    }

    // Emit event
    emit Loaned(msg.sender, _to, _amountToBorrowTokenA, _amountToBorrowTokenB, _loanParameters.loanFee);
  }
}

interface IDCAPair is IDCAPairParameters, IDCAPairSwapHandler, IDCAPairPositionHandler, IDCAPairLoanHandler {}

// 

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// 
pragma solidity >=0.5.0;





interface ITimeWeightedOracle {
  
  
  
  event AddedSupportForPair(address _tokenA, address _tokenB);

  
  
  
  
  
  function canSupportPair(address _tokenA, address _tokenB) external view returns (bool _canSupport);

  
  
  
  
  
  function quote(
    address _tokenIn,
    uint128 _amountIn,
    address _tokenOut
  ) external view returns (uint256 _amountOut);

  
  /// configure the pair for future quotes. Could be called more than one in order to let the oracle re-configure for a new context.
  
  
  
  function addSupportForPair(address _tokenA, address _tokenB) external;
}
// 
pragma solidity ^0.8.6;







contract DCAPair is DCAPairParameters, DCAPairSwapHandler, DCAPairPositionHandler, DCAPairLoanHandler, IDCAPair {
  constructor(
    IDCAGlobalParameters _globalParameters,
    IERC20Metadata _tokenA,
    IERC20Metadata _tokenB
  ) DCAPairParameters(_globalParameters, _tokenA, _tokenB) DCAPairPositionHandler(_tokenA, _tokenB) {}
}

// 

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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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
     * @dev Returns the number of values on the set. O(1).
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
}

// 

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
pragma solidity ^0.8.6;






interface IDCAGlobalParameters {
  
  struct SwapParameters {
    // The address of the fee recipient
    address feeRecipient;
    // Whether swaps are paused or not
    bool isPaused;
    // The swap fee
    uint32 swapFee;
    // The oracle contract
    ITimeWeightedOracle oracle;
  }

  
  struct LoanParameters {
    // The address of the fee recipient
    address feeRecipient;
    // Whether loans are paused or not
    bool isPaused;
    // The loan fee
    uint32 loanFee;
  }

  
  
  event FeeRecipientSet(address _feeRecipient);

  
  
  event NFTDescriptorSet(IDCATokenDescriptor _descriptor);

  
  
  event OracleSet(ITimeWeightedOracle _oracle);

  
  
  event SwapFeeSet(uint32 _feeSet);

  
  
  event LoanFeeSet(uint32 _feeSet);

  
  
  
  event SwapIntervalsAllowed(uint32[] _swapIntervals, string[] _descriptions);

  
  
  event SwapIntervalsForbidden(uint32[] _swapIntervals);

  
  error HighFee();

  
  error InvalidParams();

  
  error ZeroInterval();

  
  error EmptyDescription();

  
  
  function feeRecipient() external view returns (address _feeRecipient);

  
  
  function swapFee() external view returns (uint32 _swapFee);

  
  
  function loanFee() external view returns (uint32 _loanFee);

  
  
  function nftDescriptor() external view returns (IDCATokenDescriptor _nftDescriptor);

  
  
  function oracle() external view returns (ITimeWeightedOracle _oracle);

  
  
  
  // solhint-disable-next-line func-name-mixedcase
  function FEE_PRECISION() external view returns (uint24 _precision);

  
  
  
  // solhint-disable-next-line func-name-mixedcase
  function MAX_FEE() external view returns (uint32 _maxFee);

  
  
  function allowedSwapIntervals() external view returns (uint32[] memory _allowedSwapIntervals);

  
  
  function intervalDescription(uint32 _swapInterval) external view returns (string memory _description);

  
  
  function isSwapIntervalAllowed(uint32 _swapInterval) external view returns (bool _isAllowed);

  
  
  function paused() external view returns (bool _isPaused);

  
  
  function swapParameters() external view returns (SwapParameters memory _swapParameters);

  
  
  function loanParameters() external view returns (LoanParameters memory _loanParameters);

  
  
  
  function setFeeRecipient(address _feeRecipient) external;

  
  
  
  function setSwapFee(uint32 _fee) external;

  
  
  
  function setLoanFee(uint32 _fee) external;

  
  
  
  function setNFTDescriptor(IDCATokenDescriptor _descriptor) external;

  
  
  
  function setOracle(ITimeWeightedOracle _oracle) external;

  
  
  /// InvalidParams if the amount of swap intervals is different from the amount of descriptions passed
  /// ZeroInterval if any of the swap intervals is zero
  /// EmptyDescription if any of the descriptions is empty
  
  
  function addSwapIntervalsToAllowedList(uint32[] calldata _swapIntervals, string[] calldata _descriptions) external;

  
  
  function removeSwapIntervalsFromAllowedList(uint32[] calldata _swapIntervals) external;

  
  function pause() external;

  
  function unpause() external;
}

// 
pragma solidity ^0.8.6;

library CommonErrors {
  error ZeroAddress();
  error Paused();
  error InsufficientLiquidity();
  error LiquidityNotReturned();
}

// 
pragma solidity ^0.8.6;

library Math {
  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
      // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
      // benefit is lost if 'b' is also tested.
      // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
      if (a == 0) return (true, 0);
      uint256 c = a * b;
      if (c / a != b) return (false, 0);
      return (true, c);
    }
  }
}

// 

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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



interface IUniswapV3OracleAggregator is ITimeWeightedOracle {
  
  
  event AddedFeeTier(uint24 _feeTier);

  
  
  event PeriodChanged(uint32 _period);

  
  
  function factory() external view returns (IUniswapV3Factory _factory);

  
  
  function supportedFeeTiers() external view returns (uint24[] memory _feeTiers);

  
  
  
  function poolsUsedForPair(address _tokenA, address _tokenB) external view returns (address[] memory _pools);

  
  
  function period() external view returns (uint16 _period);

  
  
  
  // solhint-disable-next-line func-name-mixedcase
  function MINIMUM_PERIOD() external view returns (uint16);

  
  
  
  // solhint-disable-next-line func-name-mixedcase
  function MAXIMUM_PERIOD() external view returns (uint16);

  
  
  /// goes below the threshold, then it will still be used for the quote calculation
  
  // solhint-disable-next-line func-name-mixedcase
  function MINIMUM_LIQUIDITY_THRESHOLD() external view returns (uint16);

  
  
  
  function addFeeTier(uint24 _feeTier) external;

  
  
  /// WARNING: increasing the period could cause big problems, because Uniswap V3 pools might not support a TWAP so old.
  
  function setPeriod(uint16 _period) external;
}

// 
pragma solidity ^0.8.6;





interface IDCATokenDescriptor {
  
  
  
  
  function tokenURI(IDCAPairPositionHandler _positionHandler, uint256 _tokenId) external view returns (string memory _description);
}

// 
pragma solidity >=0.5.0;



interface IUniswapV3Factory {
    
    
    
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    
    
    
    
    
    
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    
    
    
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    
    
    
    function owner() external view returns (address);

    
    
    
    
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    
    
    
    
    
    
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    
    
    
    
    
    /// from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
    /// are invalid.
    
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    
    
    
    function setOwner(address _owner) external;

    
    
    
    
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}

// 

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// 

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// 
pragma solidity ^0.8.6;





interface IDCAPairSwapCallee {
  
  
  
  
  
  
  
  
  
  
  // solhint-disable-next-line func-name-mixedcase
  function DCAPairSwapCall(
    address _sender,
    IERC20Metadata _tokenA,
    IERC20Metadata _tokenB,
    uint256 _amountBorrowedTokenA,
    uint256 _amountBorrowedTokenB,
    bool _isRewardTokenA,
    uint256 _rewardAmount,
    uint256 _amountToProvide,
    bytes calldata _data
  ) external;
}

// 
pragma solidity ^0.8.6;





interface IDCAPairLoanCallee {
  
  
  
  
  
  
  
  
  
  // solhint-disable-next-line func-name-mixedcase
  function DCAPairLoanCall(
    address _sender,
    IERC20Metadata _tokenA,
    IERC20Metadata _tokenB,
    uint256 _amountBorrowedTokenA,
    uint256 _amountBorrowedTokenB,
    uint256 _feeTokenA,
    uint256 _feeTokenB,
    bytes calldata _data
  ) external;
}
