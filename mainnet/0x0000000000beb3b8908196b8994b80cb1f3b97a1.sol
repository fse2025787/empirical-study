// SPDX-License-Identifier: MIT


// 
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
pragma solidity =0.8.11;






contract BaseAggregator {
    
    uint256 internal status;

    
    mapping(address => bool) public swapTargets;

    
    modifier nonReentrant() {
        // On the first call to nonReentrant, status will be 1
        require(status != 2, "NON_REENTRANT");

        // Any calls to nonReentrant after this point will fail
        status = 2;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        status = 1;
    }

    
    modifier onlyApprovedTarget(address target) {
        require(swapTargets[target], "TARGET_NOT_AUTH");
        _;
    }

    /** EXTERNAL **/

    
    
    
    
    function fillQuoteEthToToken(
        address buyTokenAddress,
        address payable target,
        bytes calldata swapCallData,
        uint256 feeAmount
    ) external payable nonReentrant onlyApprovedTarget(target) {
        // 1 - Get the initial balances
        uint256 initialTokenBalance = ERC20(buyTokenAddress).balanceOf(
            address(this)
        );
        uint256 initialEthAmount = address(this).balance - msg.value;
        uint256 sellAmount = msg.value - feeAmount;

        // 2 - Call the encoded swap function call on the contract at `target`,
        // passing along any ETH attached to this function call to cover protocol fees
        // minus our fees, which are kept in this contract
        (bool success, bytes memory res) = target.call{value: sellAmount}(
            swapCallData
        );

        // Get the revert message of the call and revert with it if the call failed
        if (!success) {
            assembly {
                let returndata_size := mload(res)
                revert(add(32, res), returndata_size)
            }
        }

        // 3 - Make sure we received the tokens
        {
            uint256 finalTokenBalance = ERC20(buyTokenAddress).balanceOf(
                address(this)
            );
            require(initialTokenBalance < finalTokenBalance, "NO_TOKENS");
        }

        // 4 - Send the received tokens back to the user
        SafeTransferLib.safeTransfer(
            ERC20(buyTokenAddress),
            msg.sender,
            ERC20(buyTokenAddress).balanceOf(address(this)) -
                initialTokenBalance
        );

        // 5 - Return the remaining ETH to the user (if any)
        {
            uint256 finalEthAmount = address(this).balance - feeAmount;
            if (finalEthAmount > initialEthAmount) {
                SafeTransferLib.safeTransferETH(
                    msg.sender,
                    finalEthAmount - initialEthAmount
                );
            }
        }
    }

    
    
    
    
    
    
    function fillQuoteTokenToToken(
        address sellTokenAddress,
        address buyTokenAddress,
        address payable target,
        bytes calldata swapCallData,
        uint256 sellAmount,
        uint256 feeAmount
    ) external payable nonReentrant onlyApprovedTarget(target) {
        _fillQuoteTokenToToken(
            sellTokenAddress,
            buyTokenAddress,
            target,
            swapCallData,
            sellAmount,
            feeAmount
        );
    }

    
    // and accepts a signature to use permit, so the user doesn't have to make an previous approval transaction
    
    
    
    
    
    
    
    function fillQuoteTokenToTokenWithPermit(
        address sellTokenAddress,
        address buyTokenAddress,
        address payable target,
        bytes calldata swapCallData,
        uint256 sellAmount,
        uint256 feeAmount,
        PermitHelper.Permit calldata permitData
    ) external payable nonReentrant onlyApprovedTarget(target) {
        // 1 - Apply permit
        PermitHelper.permit(
            permitData,
            sellTokenAddress,
            msg.sender,
            address(this)
        );

        //2 - Call fillQuoteTokenToToken
        _fillQuoteTokenToToken(
            sellTokenAddress,
            buyTokenAddress,
            target,
            swapCallData,
            sellAmount,
            feeAmount
        );
    }

    
    
    
    
    
    
    function fillQuoteTokenToEth(
        address sellTokenAddress,
        address payable target,
        bytes calldata swapCallData,
        uint256 sellAmount,
        uint256 feePercentageBasisPoints
    ) external payable nonReentrant onlyApprovedTarget(target) {
        _fillQuoteTokenToEth(
            sellTokenAddress,
            target,
            swapCallData,
            sellAmount,
            feePercentageBasisPoints
        );
    }

    
    // and accepts a signature to use permit, so the user doesn't have to make an previous approval transaction
    
    
    
    
    
    
    function fillQuoteTokenToEthWithPermit(
        address sellTokenAddress,
        address payable target,
        bytes calldata swapCallData,
        uint256 sellAmount,
        uint256 feePercentageBasisPoints,
        PermitHelper.Permit calldata permitData
    ) external payable nonReentrant onlyApprovedTarget(target) {
        // 1 - Apply permit
        PermitHelper.permit(
            permitData,
            sellTokenAddress,
            msg.sender,
            address(this)
        );

        // 2 - call fillQuoteTokenToEth
        _fillQuoteTokenToEth(
            sellTokenAddress,
            target,
            swapCallData,
            sellAmount,
            feePercentageBasisPoints
        );
    }

    /** INTERNAL **/

    
    function _fillQuoteTokenToEth(
        address sellTokenAddress,
        address payable target,
        bytes calldata swapCallData,
        uint256 sellAmount,
        uint256 feePercentageBasisPoints
    ) internal {
        // 1 - Get the initial ETH amount
        uint256 initialEthAmount = address(this).balance - msg.value;

        // 2 - Move the tokens to this contract
        // NOTE: This implicitly assumes that the the necessary approvals have been granted
        // from msg.sender to the BaseAggregator
        SafeTransferLib.safeTransferFrom(
            ERC20(sellTokenAddress),
            msg.sender,
            address(this),
            sellAmount
        );

        // 3 - Approve the aggregator's contract to swap the tokens
        SafeTransferLib.safeApprove(
            ERC20(sellTokenAddress),
            target,
            sellAmount
        );

        // 4 - Call the encoded swap function call on the contract at `target`,
        // passing along any ETH attached to this function call to cover protocol fees.
        (bool success, bytes memory res) = target.call{value: msg.value}(
            swapCallData
        );

        // Get the revert message of the call and revert with it if the call failed
        if (!success) {
            assembly {
                let returndata_size := mload(res)
                revert(add(32, res), returndata_size)
            }
        }

        // 5 - Check that the tokens were fully spent during the swap
        uint256 allowance = ERC20(sellTokenAddress).allowance(
            address(this),
            target
        );
        require(allowance == 0, "ALLOWANCE_NOT_ZERO");

        // 6 - Subtract the fees and send the rest to the user
        // Fees will be held in this contract
        uint256 finalEthAmount = address(this).balance;
        uint256 ethDiff = finalEthAmount - initialEthAmount;

        require(ethDiff > 0, "NO_ETH_BACK");

        if (feePercentageBasisPoints > 0) {
            uint256 fees = (ethDiff * feePercentageBasisPoints) / 1e18;
            uint256 amountMinusFees = ethDiff - fees;
            SafeTransferLib.safeTransferETH(msg.sender, amountMinusFees);
            // when there's no fee, 1inch sends the funds directly to the user
            // we check to prevent sending 0 ETH in that case
        } else if (ethDiff > 0) {
            SafeTransferLib.safeTransferETH(msg.sender, ethDiff);
        }
    }

    
    function _fillQuoteTokenToToken(
        address sellTokenAddress,
        address buyTokenAddress,
        address payable target,
        bytes calldata swapCallData,
        uint256 sellAmount,
        uint256 feeAmount
    ) internal {
        // 1 - Get the initial output token balance
        uint256 initialOutputTokenAmount = ERC20(buyTokenAddress).balanceOf(
            address(this)
        );

        // 2 - Move the tokens to this contract (which includes our fees)
        // NOTE: This implicitly assumes that the the necessary approvals have been granted
        // from msg.sender to the BaseAggregator
        SafeTransferLib.safeTransferFrom(
            ERC20(sellTokenAddress),
            msg.sender,
            address(this),
            sellAmount
        );

        // 3 - Approve the aggregator's contract to swap the tokens if needed
        SafeTransferLib.safeApprove(
            ERC20(sellTokenAddress),
            target,
            sellAmount - feeAmount
        );

        // 4 - Call the encoded swap function call on the contract at `target`,
        // passing along any ETH attached to this function call to cover protocol fees.
        (bool success, bytes memory res) = target.call{value: msg.value}(
            swapCallData
        );

        // Get the revert message of the call and revert with it if the call failed
        if (!success) {
            assembly {
                let returndata_size := mload(res)
                revert(add(32, res), returndata_size)
            }
        }

        // 5 - Check that the tokens were fully spent during the swap
        uint256 allowance = ERC20(sellTokenAddress).allowance(
            address(this),
            target
        );
        require(allowance == 0, "ALLOWANCE_NOT_ZERO");

        // 6 - Make sure we received the tokens
        uint256 finalOutputTokenAmount = ERC20(buyTokenAddress).balanceOf(
            address(this)
        );
        require(initialOutputTokenAmount < finalOutputTokenAmount, "NO_TOKENS");

        // 7 - Send tokens to the user
        SafeTransferLib.safeTransfer(
            ERC20(buyTokenAddress),
            msg.sender,
            finalOutputTokenAmount - initialOutputTokenAmount
        );
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
pragma solidity >=0.5.0;



interface IERC20PermitAllowed {
    
    
    
    
    
    
    
    
    
    
    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}//
pragma solidity =0.8.11;





contract RainbowRouter is BaseAggregator {
    
    address public owner;

    
    event OwnerChanged(address indexed newOwner, address indexed oldOwner);

    
    event SwapTargetAdded(address indexed target);

    
    event SwapTargetRemoved(address indexed target);

    
    event TokenWithdrawn(
        address indexed token,
        address indexed target,
        uint256 amount
    );

    
    event EthWithdrawn(address indexed target, uint256 amount);

    
    modifier onlyOwner() {
        require(msg.sender == owner, "ONLY_OWNER");
        _;
    }

    constructor() {
        owner = msg.sender;
        status = 1;
    }

    
    /// or the owner (for testing purposes), which can also withdraw
    /// This is done by evaluating the value of status, which is set to 2
    /// only during swaps due to the "nonReentrant" modifier
    receive() external payable {
        require(status == 2 || msg.sender == owner, "NO_RECEIVE");
    }

    
    /// This is required so we only approve "trusted" swap targets
    /// to transfer tokens out of this contract
    
    
    function updateSwapTargets(address target, bool add) external onlyOwner {
        swapTargets[target] = add;
        if (add) {
            emit SwapTargetAdded(target);
        } else {
            emit SwapTargetRemoved(target);
        }
    }

    
    
    
    
    function withdrawToken(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        require(to != address(0), "ZERO_ADDRESS");
        SafeTransferLib.safeTransfer(ERC20(token), to, amount);
        emit TokenWithdrawn(token, to, amount);
    }

    
    
    
    function withdrawEth(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "ZERO_ADDRESS");
        SafeTransferLib.safeTransferETH(to, amount);
        emit EthWithdrawn(to, amount);
    }

    
    
    /// Can only be called by the current owner.
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "ZERO_ADDRESS");
        require(newOwner != owner, "SAME_OWNER");
        address previousOwner = owner;
        owner = newOwner;
        emit OwnerChanged(newOwner, previousOwner);
    }
}

// 
pragma solidity >=0.8.0;







library SafeTransferLib {
    /*///////////////////////////////////////////////////////////////
                            ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool callStatus;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            callStatus := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(callStatus, "ETH_TRANSFER_FAILED");
    }

    /*///////////////////////////////////////////////////////////////
                           ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool callStatus;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata to memory piece by piece:
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it succeeded or not.
            // We use 100 because the calldata length is 4 + 32 * 3.
            callStatus := call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool callStatus;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata to memory piece by piece:
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it succeeded or not.
            // We use 68 because the calldata length is 4 + 32 * 2.
            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool callStatus;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata to memory piece by piece:
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000) // Begin with the function selector.
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Finally append the "amount" argument. No mask as it's a full 32 byte value.

            // Call the token and store if it succeeded or not.
            // We use 68 because the calldata length is 4 + 32 * 2.
            callStatus := call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)
        }

        require(didLastOptionalReturnCallSucceed(callStatus), "APPROVE_FAILED");
    }

    /*///////////////////////////////////////////////////////////////
                         INTERNAL HELPER LOGIC
    //////////////////////////////////////////////////////////////*/

    function didLastOptionalReturnCallSucceed(bool callStatus) private pure returns (bool success) {
        assembly {
            // Get how many bytes the call returned.
            let returnDataSize := returndatasize()

            // If the call reverted:
            if iszero(callStatus) {
                // Copy the revert message into memory.
                returndatacopy(0, 0, returnDataSize)

                // Revert with the same message.
                revert(0, returnDataSize)
            }

            switch returnDataSize
            case 32 {
                // Copy the return data into memory.
                returndatacopy(0, 0, returnDataSize)

                // Set success to whether it returned true.
                success := iszero(iszero(mload(0)))
            }
            case 0 {
                // There was no return data.
                success := 1
            }
            default {
                // It returned some malformed input.
                success := 0
            }
        }
    }
}

// 
pragma solidity >=0.8.0;





abstract contract ERC20 {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*///////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*///////////////////////////////////////////////////////////////
                             EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*///////////////////////////////////////////////////////////////
                              ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*///////////////////////////////////////////////////////////////
                              EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            bytes32 digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
                )
            );

            address recoveredAddress = ecrecover(digest, v, r, s);

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*///////////////////////////////////////////////////////////////
                       INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

//
pragma solidity =0.8.11;





library PermitHelper {
    struct Permit {
        uint256 value;
        uint256 nonce;
        uint256 deadline;
        bool isDaiStylePermit;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    
    // DAI vs ERC2612 tokens
    
    
    
    
    function permit(
        Permit memory permitData,
        address tokenAddress,
        address holder,
        address spender
    ) internal {
        if (permitData.isDaiStylePermit) {
            IDAI(tokenAddress).permit(
                holder,
                spender,
                permitData.nonce,
                permitData.deadline,
                true,
                permitData.v,
                permitData.r,
                permitData.s
            );
        } else {
            IERC2612(tokenAddress).permit(
                holder,
                spender,
                permitData.value,
                permitData.deadline,
                permitData.v,
                permitData.r,
                permitData.s
            );
        }
    }
}

//
pragma solidity =0.8.11;




interface IERC2612 is IERC20Metadata, IERC20Permit {
    function _nonces(address owner) external view returns (uint256);

    function version() external view returns (string memory);
}

//
pragma solidity =0.8.11;




interface IDAI is IERC20Metadata, IERC20PermitAllowed {
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function version() external view returns (string memory);
}
