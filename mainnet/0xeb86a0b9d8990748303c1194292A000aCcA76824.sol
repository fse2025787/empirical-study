// SPDX-License-Identifier: GPL-3.0


// 
pragma solidity >=0.7.0;





interface IPositionProxy {
    
    function fuseMarginController() external view returns (IFuseMarginController);

    
    
    
    
    function execute(address _target, bytes memory _data) external payable returns (bytes memory);

    
    
    
    
    
    function execute(
        address _target,
        bytes memory _data,
        uint256 tokenId
    ) external payable returns (bytes memory);
}

// 

pragma solidity >=0.6.0 <0.8.0;

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
pragma solidity ^0.7.6;









contract PositionProxy is IPositionProxy {
    
    IFuseMarginController public immutable override fuseMarginController;
    
    IERC721 private immutable fuseMarginERC721;

    
    constructor(address _fuseMarginController) {
        fuseMarginController = IFuseMarginController(_fuseMarginController);
        fuseMarginERC721 = IERC721(_fuseMarginController);
    }

    
    receive() external payable {}

    
    
    
    
    function execute(address _target, bytes memory _data) external payable override returns (bytes memory) {
        require(fuseMarginController.approvedContracts(msg.sender), "PositionProxy: Not approved contract");
        (bool success, bytes memory response) = _target.delegatecall(_data);
        require(success, "PositionProxy: delegatecall failed");
        return response;
    }

    
    
    
    
    
    function execute(
        address _target,
        bytes memory _data,
        uint256 tokenId
    ) external payable override returns (bytes memory) {
        require(address(this) == fuseMarginController.positions(tokenId), "PositionProxy: Invalid position");
        require(msg.sender == fuseMarginERC721.ownerOf(tokenId), "PositionProxy: Not approved user");
        require(fuseMarginController.approvedConnectors(_target), "PositionProxy: Not valid connector");
        (bool success, bytes memory response) = _target.delegatecall(_data);
        require(success, "PositionProxy: delegatecall failed");
        return response;
    }
}

// 

pragma solidity >=0.6.2 <0.8.0;



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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// 
pragma solidity >=0.5.16;

interface CErc20Interface {
    function isCEther() external returns (bool);

    /*** User Interface ***/

    function mint(uint256 mintAmount) external returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);

    function balanceOfUnderlying(address account) external view returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function borrowBalanceStored(address account) external view returns (uint256);
}

// 
pragma solidity >=0.7.0;



interface IFuseMarginController {
    
    
    
    event AddMarginContract(address indexed contractAddress, address owner);

    
    
    
    event RemoveMarginContract(address indexed contractAddress, address owner);

    
    
    
    event AddConnectorContract(address indexed contractAddress, address owner);

    
    
    
    event RemoveConnectorContract(address indexed contractAddress, address owner);

    
    
    event SetBaseURI(string indexed _metadataBaseURI);

    
    
    
    
    function newPosition(address user, address position) external returns (uint256);

    
    
    function closePosition(uint256 tokenId) external returns (address);

    
    
    function addMarginContract(address contractAddress) external;

    
    
    function removeMarginContract(address contractAddress) external;

    
    
    function addConnectorContract(address contractAddress) external;

    
    
    function removeConnectorContract(address contractAddress) external;

    
    
    function setBaseURI(string memory _metadataBaseURI) external;

    
    
    function getMarginContracts() external view returns (address[] memory);

    
    
    
    
    function tokensOfOwner(address user) external view returns (uint256[] memory, address[] memory);

    
    
    
    function positions(uint256 tokenId) external view returns (address);

    
    
    
    function marginContracts(uint256 index) external view returns (address);

    
    
    
    function approvedContracts(address contractAddress) external view returns (bool);

    
    
    
    function approvedConnectors(address contractAddress) external view returns (bool);

    
    
    function positionsLength() external view returns (uint256);
}

// 
pragma solidity >=0.5.16;

interface ComptrollerInterface {
    /*** Assets You Are In ***/

    function enterMarkets(address[] calldata cTokens) external returns (uint256[] memory);

    function exitMarket(address cToken) external returns (uint256);

    function getAssetsIn(address account) external view returns (address[] memory);

    /*** Policy Hooks ***/

    function mintAllowed(
        address cToken,
        address minter,
        uint256 mintAmount
    ) external returns (uint256);

    function mintWithinLimits(
        address cToken,
        uint256 exchangeRateMantissa,
        uint256 accountTokens,
        uint256 mintAmount
    ) external returns (uint256);

    function mintVerify(
        address cToken,
        address minter,
        uint256 mintAmount,
        uint256 mintTokens
    ) external;

    function redeemAllowed(
        address cToken,
        address redeemer,
        uint256 redeemTokens
    ) external returns (uint256);

    function redeemVerify(
        address cToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemTokens
    ) external;

    function borrowAllowed(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256);

    function borrowWithinLimits(address cToken, uint256 accountBorrowsNew) external returns (uint256);

    function borrowVerify(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external;

    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);

    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 borrowerIndex
    ) external;

    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);

    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount,
        uint256 seizeTokens
    ) external;

    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);

    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external;

    function transferAllowed(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external returns (uint256);

    function transferVerify(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external;

    /*** Liquidity/Liquidation Calculations ***/

    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint256 repayAmount
    ) external view returns (uint256, uint256);
}
