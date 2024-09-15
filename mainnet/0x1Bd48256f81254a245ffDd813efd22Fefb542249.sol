// SPDX-License-Identifier: MIT
pragma abicoder v1;


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
}// 
pragma solidity =0.8.10;


/**
 *    ,,                           ,,                                
 *   *MM                           db                      `7MM      
 *    MM                                                     MM      
 *    MM,dMMb.      `7Mb,od8     `7MM      `7MMpMMMb.        MM  ,MP'
 *    MM    `Mb       MM' "'       MM        MM    MM        MM ;Y   
 *    MM     M8       MM           MM        MM    MM        MM;Mm   
 *    MM.   ,M9       MM           MM        MM    MM        MM `Mb. 
 *    P^YbmdP'      .JMML.       .JMML.    .JMML  JMML.    .JMML. YA.
 *
 *    NftLimitSwapVerifier.sol :: 0x1Bd48256f81254a245ffDd813efd22Fefb542249
 *    etherscan.io verified 2022-04-13
 */ 









contract NftLimitSwapVerifier {
  using NativeOrERC20 for address;

  ICallExecutor constant CALL_EXECUTOR = ICallExecutor(0xDE61dfE5fbF3F4Df70B16D0618f69B96A2754bf8);

  
  
  
  
  
  
  
  
  
  
  function tokenToNft(
    uint256 bitmapIndex, uint256 bit, address tokenIn, IERC721 nftOut, uint256 tokenInAmount, uint256 expiryBlock, address to,
    bytes calldata data
  )
    external
  {
    require(expiryBlock > block.number, 'Expired');
  
    Bit.useBit(bitmapIndex, bit);

    uint256 nftOutBalance = nftOut.balanceOf(address(this));

    if (tokenIn.isEth()) {
      CALL_EXECUTOR.proxyCall{value: tokenInAmount}(to, data);
    } else {
      IERC20(tokenIn).transfer(to, tokenInAmount);
      CALL_EXECUTOR.proxyCall(to, data);
    }

    uint256 nftOutAmountReceived = nftOut.balanceOf(address(this)) - nftOutBalance;
    require(nftOutAmountReceived >= 1, 'NotEnoughReceived');
  }

  
  
  
  
  
  
  
  
  
  
  
  function nftToToken(
    uint256 bitmapIndex, uint256 bit, IERC721 nftIn, address tokenOut, uint256 nftInID, uint256 tokenOutAmount, uint256 expiryBlock,
    address to, bytes calldata data
  )
    external
  {
    require(expiryBlock > block.number, 'Expired');
  
    Bit.useBit(bitmapIndex, bit);

    uint256 tokenOutBalance = tokenOut.balanceOf(address(this));

    nftIn.transferFrom(address(this), to, nftInID);
    CALL_EXECUTOR.proxyCall(to, data);

    uint256 tokenOutAmountReceived = tokenOut.balanceOf(address(this)) - tokenOutBalance;
    require(tokenOutAmountReceived >= tokenOutAmount, 'NotEnoughReceived');
  }

  
  
  
  
  
  
  
  
  
  
  function nftToNft(
    uint256 bitmapIndex, uint256 bit, IERC721 nftIn, IERC721 nftOut, uint256 nftInID, uint256 expiryBlock, address to, bytes calldata data
  )
    external
  {
    require(expiryBlock > block.number, 'Expired');
  
    Bit.useBit(bitmapIndex, bit);

    uint256 nftOutBalance = nftOut.balanceOf(address(this));

    nftIn.transferFrom(address(this), to, nftInID);
    CALL_EXECUTOR.proxyCall(to, data);

    uint256 nftOutAmountReceived = nftOut.balanceOf(address(this)) - nftOutBalance;
    require(nftOutAmountReceived >= 1, 'NotEnoughReceived');
  }
}

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
pragma solidity =0.8.10;


interface ICallExecutor {
  function proxyCall(address to, bytes memory data) external payable;
}

// 
pragma solidity =0.8.10;






library Bit {
  
  error InvalidBit();

  
  error BitUsed();

  
  
  uint256 constant INITIAL_BMP_PTR = 
  48874093989078844336340380824760280705349075126087700760297816282162649029611;

  
  
  
  
  function useBit(uint256 bitmapIndex, uint256 bit) internal {
    if (!validBit(bit)) {
      revert InvalidBit();
    }
    bytes32 ptr = bitmapPtr(bitmapIndex);
    uint256 bitmap = loadUint(ptr);
    if (bitmap & bit != 0) {
      revert BitUsed();
    }
    uint256 updatedBitmap = bitmap | bit;
    assembly { sstore(ptr, updatedBitmap) }
  }

  
  
  
  function validBit(uint256 bit) internal pure returns (bool isValid) {
    assembly {
      // equivalent to: isValid = (bit > 0 && bit & bit-1) == 0;
      isValid := and(
        iszero(iszero(bit)), 
        iszero(and(bit, sub(bit, 1)))
      )
    } 
  }

  
  
  function bitmapPtr (uint256 bitmapIndex) internal pure returns (bytes32) {
    return bytes32(INITIAL_BMP_PTR + bitmapIndex);
  }

  
  
  
  function loadUint(bytes32 ptr) internal view returns (uint256 val) {
    assembly { val := sload(ptr) }
  }
}

// 
pragma solidity =0.8.10;




library NativeOrERC20 {

  function balanceOf(address token, address owner) internal view returns (uint256) {
    if (isEth(token)) {
      return owner.balance;
    } else {
      return IERC20(token).balanceOf(owner);
    }
  }


  function isEth(address token) internal pure returns (bool) {
    return (token == address(0) || token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
  }

}
