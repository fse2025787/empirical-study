// SPDX-License-Identifier: GPL-3.0-or-later
pragma abicoder v1;

// 
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
 *    LimitSwapVerifier.sol :: 0x53D468E719694f3e542Dda96a237Af08eb394f2C
 *    etherscan.io verified 2021-12-18
 */ 







contract LimitSwapVerifier {
  
  error Expired();

  
  error NotEnoughReceived(uint256 amountReceived);

  ICallExecutor internal immutable CALL_EXECUTOR;

  constructor(ICallExecutor callExecutor) {
    CALL_EXECUTOR = callExecutor;
  }

  
  
  
  
  
  
  
  
  
  
  
  function tokenToToken(
    uint256 bitmapIndex, uint256 bit, IERC20 tokenIn, IERC20 tokenOut, uint256 tokenInAmount, uint256 tokenOutAmount,
    uint256 expiryBlock, address to, bytes calldata data
  )
    external
  {
    if (expiryBlock <= block.number) {
      revert Expired();
    }
  
    Bit.useBit(bitmapIndex, bit);

    uint256 tokenOutBalance = tokenOut.balanceOf(address(this));

    tokenIn.transfer(to, tokenInAmount);

    CALL_EXECUTOR.proxyCall(to, data);

    uint256 tokenOutAmountReceived = tokenOut.balanceOf(address(this)) - tokenOutBalance;
    if (tokenOutAmountReceived < tokenOutAmount) {
      revert NotEnoughReceived(tokenOutAmountReceived);
    }
  }

  
  
  
  
  
  
  
  
  
  
  function ethToToken(
    uint256 bitmapIndex, uint256 bit, IERC20 token, uint256 ethAmount, uint256 tokenAmount, uint256 expiryBlock,
    address to, bytes calldata data
  )
    external
  {
    if (expiryBlock <= block.number) {
      revert Expired();
    }

    Bit.useBit(bitmapIndex, bit);

    uint256 tokenBalance = token.balanceOf(address(this));

    CALL_EXECUTOR.proxyCall{value: ethAmount}(to, data);

    uint256 tokenAmountReceived = token.balanceOf(address(this)) - tokenBalance;
    if (tokenAmountReceived < tokenAmount) {
      revert NotEnoughReceived(tokenAmountReceived);
    }
  }

  
  
  
  
  
  
  
  
  
  
  function tokenToEth(
    uint256 bitmapIndex, uint256 bit, IERC20 token, uint256 tokenAmount, uint256 ethAmount, uint256 expiryBlock,
    address to, bytes calldata data
  )
    external
  {
    if (expiryBlock <= block.number) {
      revert Expired();
    }

    Bit.useBit(bitmapIndex, bit);
    
    uint256 ethBalance = address(this).balance;

    token.transfer(to, tokenAmount);

    CALL_EXECUTOR.proxyCall(to, data);

    uint256 ethAmountReceived = address(this).balance - ethBalance;
    if (ethAmountReceived < ethAmount) {
      revert NotEnoughReceived(ethAmountReceived);
    }
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