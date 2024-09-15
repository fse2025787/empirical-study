// SPDX-License-Identifier: MIT

// 
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;






interface IAntePool {
    
    
    
    
    event Stake(address indexed staker, uint256 amount, uint256 commitTime);

    
    
    
    
    event ExtendStake(address indexed staker, uint256 additionalTime, uint256 commitTime);

    
    
    
    event RegisterChallenge(address indexed challenger, uint256 amount);

    
    
    
    event ConfirmChallenge(address indexed challenger, uint256 confirmedShares);

    
    
    
    
    event Unstake(address indexed staker, uint256 amount, bool indexed isChallenger);

    
    
    event TestChecked(address indexed checker);

    
    
    event FailureOccurred(address indexed checker);

    
    
    
    event ClaimPaid(address indexed claimer, uint256 amount);

    
    
    
    event RewardPaid(address indexed author, uint256 amount);

    
    
    
    event WithdrawStake(address indexed staker, uint256 amount);

    
    
    
    event CancelWithdraw(address indexed staker, uint256 amount);

    
    
    
    
    event DecayUpdated(uint256 decayThisUpdate, uint256 challengerMultiplier, uint256 stakerMultiplier);

    
    event DecayStarted();

    
    event DecayPaused();

    
    
    
    
    
    
    
    /// the invariant validation currently passes
    function initialize(
        IAnteTest _anteTest,
        IERC20 _token,
        uint256 _tokenMinimum,
        uint256 _decayRate,
        uint256 _payoutRatio,
        uint256 _testAuthorRewardRate
    ) external;

    
    
    /// then decides to cancel that withdraw
    function cancelPendingWithdraw() external;

    
    /// without updating the state
    
    function checkTest() external;

    
    
    
    function checkTestWithState(bytes memory _testState) external;

    
    
    /// claiming and that balance is zeroed out once the claim is done
    function claim() external;

    
    
    /// claiming and that balance is zeroed out once the claim is done
    function claimReward() external;

    
    
    
    function stake(uint256 amount, uint256 commitTime) external;

    
    
    function extendStakeLock(uint256 additionalTime) external;

    
    
    /// the challenge.
    
    function registerChallenge(uint256 amount) external;

    
    
    /// the challenge.
    function confirmChallenge() external;

    
    
    
    function unstake(uint256 amount, bool isChallenger) external;

    
    
    function unstakeAll(bool isChallenger) external;

    
    
    /// decay amounts and pools accurate
    function updateDecay() external;

    
    
    
    function updateVerifiedState(address _verifier) external;

    
    
    
    /// all linked ante pools as soon as a checkTest() call has failed on a single AntePool
    function updateFailureState(address _verifier) external;

    
    
    /// users from removing their stake when a challenger is going to verify test
    function withdrawStake() external;

    
    
    function anteTest() external view returns (IAnteTest);

    
    
    function decayRate() external view returns (uint256);

    
    
    function challengerPayoutRatio() external view returns (uint256);

    
    
    function testAuthorRewardRate() external view returns (uint256);

    
    
    function getTestAuthorReward() external view returns (uint256);

    
    
    ///         totalAmount The total value locked in the challenger pool in wei
    ///         decayMultiplier The current multiplier for decay
    function challengerInfo() external view returns (uint256 numUsers, uint256 totalAmount, uint256 decayMultiplier);

    
    
    ///         totalAmount The total value locked in the staker pool in wei
    ///         decayMultiplier The current multiplier for decay
    function stakingInfo() external view returns (uint256 numUsers, uint256 totalAmount, uint256 decayMultiplier);

    
    
    /// 12 blocks to receive payout, this is to mitigate other challengers
    /// from trying to stick in a challenge right before the verification
    
    function eligibilityInfo() external view returns (uint256 eligibleAmount);

    
    
    function factory() external view returns (address);

    
    
    /// have logically failed beforehand, but without having a user initiating
    /// the verify test action
    
    function failedBlock() external view returns (uint256);

    
    
    /// have logically failed beforehand, but without having a user initiating
    /// the verify test action
    
    function failedTimestamp() external view returns (uint256);

    
    
    function getChallengerInfo(
        address challenger
    )
        external
        view
        returns (
            uint256 startAmount,
            uint256 lastStakedTimestamp,
            uint256 claimableShares,
            uint256 claimableSharesStartMultiplier
        );

    
    
    
    /// value is an estimate
    
    function getChallengerPayout(address challenger) external view returns (uint256);

    
    
    
    /// withdraw process
    
    function getPendingWithdrawAllowedTime(address _user) external view returns (uint256);

    
    
    
    
    function getUnstakeAllowedTime(address _user) external view returns (uint256);

    
    
    
    function getPendingWithdrawAmount(address _user) external view returns (uint256);

    
    
    
    
    /// decay has been either added (staker) or subtracted (challenger)
    
    function getStoredBalance(address _user, bool isChallenger) external view returns (uint256);

    
    
    function getTotalChallengerEligibleBalance() external view returns (uint256);

    
    
    function getTotalChallengerStaked() external view returns (uint256);

    
    
    function getTotalPendingWithdraw() external view returns (uint256);

    
    
    function getTotalStaked() external view returns (uint256);

    
    
    
    
    /// added to respective side
    
    function getUserStartAmount(address _user, bool isChallenger) external view returns (uint256);

    
    
    
    
    /// added to respective side
    
    function getUserStartDecayMultiplier(address _user, bool isChallenger) external view returns (uint256);

    
    
    
    function getVerifierBounty() external view returns (uint256);

    
    
    
    function getCheckTestAllowedBlock(address _user) external view returns (uint256);

    
    
    /// Pool contract
    
    function lastUpdateBlock() external view returns (uint256);

    
    
    /// Pool contract
    
    function lastUpdateTimestamp() external view returns (uint256);

    
    
    
    function minChallengerStake() external view returns (uint256);

    
    
    
    function minSupporterStake() external view returns (uint256);

    
    
    /// the Ante Test fails
    
    function lastVerifiedBlock() external view returns (uint256);

    
    
    /// the Ante Test fails
    
    function lastVerifiedTimestamp() external view returns (uint256);

    
    
    function numPaidOut() external view returns (uint256);

    
    
    function numTimesVerified() external view returns (uint256);

    
    
    function pendingFailure() external view returns (bool);

    
    
    function totalPaidOut() external view returns (uint256);

    
    
    function token() external view returns (IERC20);

    
    
    function isDecaying() external view returns (bool);

    
    
    
    function verifier() external view returns (address);

    
    
    function withdrawInfo() external view returns (uint256 totalAmount);
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// 
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// 

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;













contract AntePoolLogic is IAntePool, ReentrancyGuard {
    using Math for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    
    struct BalanceInfo {
        // How many tokens this user deposited
        uint256 startAmount;
        // How much decay this side of the pool accrued between (0, this user's
        // entry block), stored as a multiplier expressed as an 18-decimal
        // mantissa. For example, if this side of the pool accrued a decay of
        // 20% during this time period, we'd store 1.2e18 (staking side) or
        // 0.8e18 (challenger side)
        uint256 startDecayMultiplier;
    }

    
    struct StakerInfo {
        // Amount and decay info;
        BalanceInfo balanceInfo;
        // When the user can unstake
        uint256 unlockTimestamp;
    }

    
    struct ChallengerInfo {
        // Staked amount and decay info;
        BalanceInfo balanceInfo;
        // Confirmed tokens amount and decay info;
        BalanceInfo claimableShares;
        // When the user last registered a challenge
        uint256 lastStakedTimestamp;
        // Block number of the last challenge for this user
        uint256 lastStakedBlock;
    }

    
    struct PoolSideInfo {
        // Number of users on this side of the pool.
        uint256 numUsers;
        // Amount staked across all users on this side of the pool,, as of
        // `lastUpdateTimestamp`.
        uint256 totalAmount;
        // How much decay this side of the pool accrued between (0,
        // lastUpdateTimestamp), stored as a multiplier expressed as an 18-decimal
        // mantissa. For example, if this side of the pool accrued a decay of
        // 20% during this time period, we'd store 1.2e18 (staking side) or
        // 0.8e18 (challenger side).
        uint256 decayMultiplier;
    }

    
    struct ChallengerEligibilityInfo {
        uint256 totalShares;
    }

    
    struct StakerWithdrawInfo {
        mapping(address => UserUnstakeInfo) userUnstakeInfo;
        uint256 totalAmount;
    }

    
    struct UserUnstakeInfo {
        uint256 lastUnstakeTimestamp;
        uint256 amount;
    }

    
    IAnteTest public override anteTest;
    
    uint256 public override decayRate;
    
    uint256 public override challengerPayoutRatio;
    
    uint256 public override testAuthorRewardRate;
    
    address public override factory;
    
    uint256 public override numTimesVerified;
    
    uint256 public constant VERIFIER_BOUNTY = 5;
    
    uint256 public override failedBlock;
    
    uint256 public override failedTimestamp;
    
    uint256 public override lastVerifiedBlock;
    
    uint256 public override lastVerifiedTimestamp;
    
    address public override verifier;
    
    uint256 public override numPaidOut;
    
    uint256 public override totalPaidOut;
    
    IERC20 public override token;
    
    bool public override isDecaying;

    
    bool internal _initialized = false;
    
    uint256 internal _bounty;
    
    uint256 internal _remainingStake;
    
    uint256 internal _authorReward;

    
    /// eligible for payout on test failure
    uint8 public constant CHALLENGER_BLOCK_DELAY = 12;

    
    uint256 public constant MAX_AUTHOR_REWARD_RATE = 10;

    
    uint256 public constant MIN_ANNUAL_DECAY_RATE = 5;

    
    uint256 public constant MAX_ANNUAL_DECAY_RATE = 600;

    
    uint256 public constant MIN_CHALLENGER_PAYOUT_RATIO = 2;

    
    uint256 public constant MAX_CHALLENGER_PAYOUT_RATIO = 20;

    
    /// starts when staker initiates the unstake action
    uint256 public constant UNSTAKE_DELAY = 24 hours;

    
    /// multiplier for annual decay rate
    uint256 public constant ONE_YEAR = 365 days;

    
    /// can initiate the unstake action
    uint256 public constant MIN_STAKE_COMMITMENT = 24 hours;

    
    /// can initiate the unstake action
    uint256 public constant MAX_STAKE_COMMITMENT = 730 days;

    
    /// confirm to be eligible for payout on test failure
    uint256 public constant MIN_CHALLENGER_DELAY = 180 seconds;

    
    uint256 private constant ONE = 1e18;

    
    PoolSideInfo public override stakingInfo;
    
    PoolSideInfo public override challengerInfo;
    
    ChallengerEligibilityInfo public override eligibilityInfo;
    
    mapping(address => ChallengerInfo) private challengers;
    
    mapping(address => StakerInfo) private stakers;
    
    StakerWithdrawInfo public override withdrawInfo;

    
    uint256 public override lastUpdateBlock;

    
    uint256 public override lastUpdateTimestamp;

    
    uint256 public override minChallengerStake;

    
    uint256 public override minSupporterStake;

    address immutable _this;

    
    modifier testNotFailed() {
        _testNotFailed();
        _;
    }

    modifier notInitialized() {
        require(!_initialized, "ANTE: Pool already initialized");
        _;
    }

    modifier altersDecayState() {
        _;
        if (!isDecaying && _canDecay()) {
            isDecaying = true;
            emit DecayStarted();
        } else if (isDecaying && !_canDecay()) {
            isDecaying = false;
            emit DecayPaused();
        }
    }

    modifier onlyDelegate() {
        require(address(this) != _this, "ANTE: Only delegate calls are allowed.");
        _;
    }

    
    /// It must be initialized only by delegated calls.
    /// pendingFailure set to true in order to avoid
    /// people staking in logic contract
    constructor() {
        _initialized = true;
        _this = address(this);
    }

    
    function initialize(
        IAnteTest _anteTest,
        IERC20 _token,
        uint256 _tokenMinimum,
        uint256 _decayRate,
        uint256 _payoutRatio,
        uint256 _testAuthorRewardRate
    ) external override notInitialized nonReentrant {
        require(address(msg.sender).isContract(), "ANTE: Factory must be a contract");
        require(address(_anteTest).isContract(), "ANTE: AnteTest must be a smart contract");
        // Check that anteTest has checkTestPasses function and that it currently passes
        // place check here to minimize reentrancy risk - most external function calls are locked
        // while pendingFailure is true
        require(
            _testAuthorRewardRate <= MAX_AUTHOR_REWARD_RATE,
            "ANTE: Reward rate cannot be greater than MAX_AUTHOR_REWARD_RATE"
        );
        require(
            _decayRate >= MIN_ANNUAL_DECAY_RATE && _decayRate <= MAX_ANNUAL_DECAY_RATE,
            "ANTE: Decay rate must be between MIN_ANNUAL_DECAY_RATE and MAX_ANNUAL_DECAY_RATE"
        );
        require(
            _payoutRatio >= MIN_CHALLENGER_PAYOUT_RATIO && _payoutRatio <= MAX_CHALLENGER_PAYOUT_RATIO,
            "ANTE: Challenger payout ratio must be between MIN_CHALLENGER_PAYOUT_RATIO and MAX_CHALLENGER_PAYOUT_RATIO"
        );

        _initialized = true;

        factory = msg.sender;
        stakingInfo.decayMultiplier = ONE;
        challengerInfo.decayMultiplier = ONE;
        lastUpdateBlock = block.number;
        anteTest = _anteTest;
        token = _token;
        minChallengerStake = _tokenMinimum;
        testAuthorRewardRate = _testAuthorRewardRate;
        decayRate = _decayRate;
        challengerPayoutRatio = _payoutRatio;
        minSupporterStake = _tokenMinimum * _payoutRatio;
        isDecaying = false;

        require(_anteTest.checkTestPasses(), "ANTE: AnteTest does not implement checkTestPasses or test fails");
    }

    /*****************************************************
     * ================ USER INTERFACE ================= *
     *****************************************************/
    
    
    function stake(uint256 amount, uint256 commitTime) external override onlyDelegate testNotFailed altersDecayState {
        require(amount >= minSupporterStake, "ANTE: Supporter must stake more than minSupporterStake");
        require(commitTime >= MIN_STAKE_COMMITMENT, "ANTE: Cannot commit stake for less than 24 hours");
        require(commitTime <= MAX_STAKE_COMMITMENT, "ANTE: Cannot commit stake for more than 730 days");
        uint256 unlockTimestamp = block.timestamp + commitTime;
        StakerInfo storage user = stakers[msg.sender];
        require(
            unlockTimestamp > user.unlockTimestamp,
            "ANTE: Cannot commit a stake that expires before the current time commitment"
        );
        updateDecay();
        PoolSideInfo storage side = stakingInfo;
        BalanceInfo storage balanceInfo = user.balanceInfo;
        user.unlockTimestamp = unlockTimestamp;
        // Calculate how much the user already has staked, including the
        // effects of any previously accrued decay.
        //   prevAmount = startAmount * decayMultipiler / startDecayMultiplier
        //   newAmount = amount + prevAmount
        if (balanceInfo.startAmount > 0) {
            balanceInfo.startAmount = amount + _storedBalance(balanceInfo, side.decayMultiplier);
        } else {
            balanceInfo.startAmount = amount;
            side.numUsers++;
        }
        side.totalAmount += amount;
        // Reset the startDecayMultiplier for this user, since we've updated
        // the startAmount to include any already-accrued decay.
        balanceInfo.startDecayMultiplier = side.decayMultiplier;
        token.safeTransferFrom(msg.sender, address(this), amount);
        emit Stake(msg.sender, amount, commitTime);
    }

    
    function extendStakeLock(uint256 additionalTime) external override testNotFailed altersDecayState {
        require(additionalTime >= MIN_STAKE_COMMITMENT, "ANTE: Additional time must be greater than 24 hours");
        require(additionalTime <= MAX_STAKE_COMMITMENT, "ANTE: Additional time must be less than 730 days");
        StakerInfo storage user = stakers[msg.sender];
        BalanceInfo storage balanceInfo = user.balanceInfo;
        require(balanceInfo.startAmount > 0, "ANTE: Only an existing staker can extend the stake lock");
        uint256 currentUnlockTime = user.unlockTimestamp < block.timestamp ? block.timestamp : user.unlockTimestamp;
        updateDecay();

        // If the previous lock is expired, add additionalTime from now
        user.unlockTimestamp = currentUnlockTime + additionalTime;
        emit ExtendStake(msg.sender, additionalTime, user.unlockTimestamp);
    }

    
    function registerChallenge(uint256 amount) external override onlyDelegate testNotFailed altersDecayState {
        require(amount >= minChallengerStake, "ANTE: Challenger must stake more than minChallengerStake");
        updateDecay();
        uint256 newRatio = stakingInfo.totalAmount / (challengerInfo.totalAmount + amount);
        require(newRatio >= challengerPayoutRatio, "ANTE: Challenge amount exceeds maximum challenge ratio.");

        PoolSideInfo storage side = challengerInfo;
        ChallengerInfo storage user = challengers[msg.sender];
        BalanceInfo storage balanceInfo = user.balanceInfo;

        // Calculate how much the user already has challenger, including the
        // effects of any previously accrued decay.
        //   prevAmount = startAmount * decayMultipiler / startDecayMultiplier
        //   newAmount = amount + prevAmount
        if (balanceInfo.startAmount > 0) {
            balanceInfo.startAmount = amount + _storedBalance(balanceInfo, side.decayMultiplier);
        } else {
            balanceInfo.startAmount = amount;
            side.numUsers++;
        }
        user.lastStakedTimestamp = block.timestamp;
        user.lastStakedBlock = block.number;

        side.totalAmount += amount;

        // Reset the startDecayMultiplier for this user, since we've updated
        // the startAmount to include any already-accrued decay.
        balanceInfo.startDecayMultiplier = side.decayMultiplier;

        token.safeTransferFrom(msg.sender, address(this), amount);
        emit RegisterChallenge(msg.sender, amount);
    }

    
    function confirmChallenge() external override testNotFailed altersDecayState {
        ChallengerInfo storage user = challengers[msg.sender];
        BalanceInfo storage balanceInfo = user.balanceInfo;
        BalanceInfo storage claimableShares = user.claimableShares;
        require(balanceInfo.startAmount > 0, "ANTE: Only an existing challenger can confirm");
        require(
            user.lastStakedTimestamp <= block.timestamp - MIN_CHALLENGER_DELAY,
            "ANTE: Challenger must wait at least MIN_CHALLENGER_DELAY after registering a challenge."
        );
        updateDecay();
        uint256 challengerBalance = _storedBalance(balanceInfo, challengerInfo.decayMultiplier);
        uint256 previousShares = _storedBalance(claimableShares, challengerInfo.decayMultiplier);
        uint256 confirmingShares = challengerBalance - previousShares;
        claimableShares.startAmount = challengerBalance;
        claimableShares.startDecayMultiplier = challengerInfo.decayMultiplier;
        eligibilityInfo.totalShares += confirmingShares;
        emit ConfirmChallenge(msg.sender, confirmingShares);
    }

    
    
    function unstake(uint256 amount, bool isChallenger) external override testNotFailed nonReentrant altersDecayState {
        require(amount > 0, "ANTE: Cannot unstake 0.");
        require(
            isChallenger || getUnstakeAllowedTime(msg.sender) <= block.timestamp,
            "ANTE: Staker cannot unstake before commited time"
        );

        updateDecay();

        PoolSideInfo storage side = isChallenger ? challengerInfo : stakingInfo;

        BalanceInfo storage balanceInfo = isChallenger
            ? challengers[msg.sender].balanceInfo
            : stakers[msg.sender].balanceInfo;
        _unstake(amount, isChallenger, side, balanceInfo);
    }

    
    function unstakeAll(bool isChallenger) external override nonReentrant altersDecayState {
        if (isChallenger) {
            // Prevent challengers (isChallenger=true) moving forward if test has failed.
            _testNotFailed();
        } else {
            // Allow stakers (isChallenger = false) to unstake all if test has failed and there are no challengers
            require(
                !pendingFailure() || challengerInfo.numUsers == 0,
                pendingFailure() ? "ANTE: Test already failed." : "ANTE: Cannot unstake"
            );
            require(
                getUnstakeAllowedTime(msg.sender) <= block.timestamp,
                "ANTE: Staker cannot unstake before commited time"
            );
        }

        updateDecay();

        PoolSideInfo storage side = isChallenger ? challengerInfo : stakingInfo;

        BalanceInfo storage balanceInfo = isChallenger
            ? challengers[msg.sender].balanceInfo
            : stakers[msg.sender].balanceInfo;

        uint256 amount = _storedBalance(balanceInfo, side.decayMultiplier);
        require(amount > 0, "ANTE: Nothing to unstake");

        _unstake(amount, isChallenger, side, balanceInfo);
    }

    
    function withdrawStake() external override nonReentrant {
        // Allow stakers to withdraw stake if test has failed and there are no challengers
        require(!pendingFailure() || challengerInfo.numUsers == 0, "ANTE: Cannot withdraw");

        UserUnstakeInfo storage unstakeUser = withdrawInfo.userUnstakeInfo[msg.sender];

        require(
            unstakeUser.lastUnstakeTimestamp < block.timestamp - UNSTAKE_DELAY,
            "ANTE: must wait 24 hours to withdraw stake"
        );
        require(unstakeUser.amount > 0, "ANTE: Nothing to withdraw");

        uint256 amount = unstakeUser.amount;
        withdrawInfo.totalAmount -= amount;
        unstakeUser.amount = 0;

        token.safeTransfer(msg.sender, amount);

        emit WithdrawStake(msg.sender, amount);
    }

    
    function cancelPendingWithdraw() external override testNotFailed altersDecayState {
        UserUnstakeInfo storage unstakeUser = withdrawInfo.userUnstakeInfo[msg.sender];

        require(unstakeUser.amount > 0, "ANTE: No pending withdraw balance");
        uint256 amount = unstakeUser.amount;
        unstakeUser.amount = 0;

        updateDecay();

        BalanceInfo storage user = stakers[msg.sender].balanceInfo;
        if (user.startAmount > 0) {
            user.startAmount = amount + _storedBalance(user, stakingInfo.decayMultiplier);
        } else {
            user.startAmount = amount;
            stakingInfo.numUsers++;
        }
        stakingInfo.totalAmount += amount;
        user.startDecayMultiplier = stakingInfo.decayMultiplier;

        withdrawInfo.totalAmount -= amount;

        emit CancelWithdraw(msg.sender, amount);
    }

    
    function checkTest() external override testNotFailed {
        checkTestWithState("");
    }

    
    function checkTestWithState(bytes memory _testState) public override testNotFailed nonReentrant {
        bytes32 configHash = keccak256(
            abi.encodePacked(
                address(anteTest),
                address(token),
                minChallengerStake,
                challengerPayoutRatio,
                decayRate,
                testAuthorRewardRate
            )
        );
        IAntePoolFactory(factory).checkTestWithState(_testState, msg.sender, configHash);
    }

    
    function claim() external override nonReentrant {
        require(pendingFailure(), "ANTE: Test has not failed");

        ChallengerInfo storage user = challengers[msg.sender];
        require(user.balanceInfo.startAmount > 0, "ANTE: No Challenger Staking balance");

        uint256 amount = _calculateChallengerPayout(user, msg.sender);
        // Zero out the user so they can't claim again.
        user.balanceInfo.startAmount = 0;
        user.claimableShares.startAmount = 0;

        numPaidOut++;
        totalPaidOut += amount;

        token.safeTransfer(msg.sender, amount);
        emit ClaimPaid(msg.sender, amount);
    }

    
    function claimReward() external override nonReentrant altersDecayState {
        require(msg.sender == anteTest.testAuthor(), "ANTE: Only author can claim");

        updateDecay();

        require(_authorReward > 0, "ANTE: No reward");

        uint256 amount = _authorReward;
        _authorReward = 0;

        token.safeTransfer(msg.sender, amount);
        emit RewardPaid(msg.sender, amount);
    }

    
    function updateDecay() public override {
        (
            uint256 decayMultiplierThisUpdate,
            uint256 decayThisUpdate,
            uint256 decayForStakers,
            uint256 decayForAuthor
        ) = _computeDecay();

        lastUpdateBlock = block.number;
        lastUpdateTimestamp = block.timestamp;

        if (decayThisUpdate == 0) return;

        uint256 totalStaked = stakingInfo.totalAmount;
        uint256 totalChallengerStaked = challengerInfo.totalAmount;

        // update total accrued decay amounts for challengers
        // decayMultiplier for challengers = decayMultiplier for challengers * decayMultiplierThisUpdate
        // totalChallengerStaked = totalChallengerStaked - decayThisUpdate
        challengerInfo.decayMultiplier = challengerInfo.decayMultiplier.mulDiv(decayMultiplierThisUpdate, ONE);
        challengerInfo.totalAmount = totalChallengerStaked - decayThisUpdate;

        // Decay the total confirmed shares
        eligibilityInfo.totalShares = eligibilityInfo.totalShares.mulDiv(
            decayMultiplierThisUpdate,
            ONE,
            Math.Rounding.Up
        );

        // Update the new accrued decay amounts for stakers.
        //   totalStaked_new = totalStaked_old + decayThisUpdate
        //   decayMultipilerThisUpdate = totalStaked_new / totalStaked_old
        //   decayMultiplier_staker = decayMultiplier_staker * decayMultiplierThisUpdate
        uint256 totalStakedNew = totalStaked + decayForStakers;

        stakingInfo.decayMultiplier = stakingInfo.decayMultiplier.mulDiv(totalStakedNew, totalStaked);
        stakingInfo.totalAmount = totalStakedNew;

        _authorReward += decayForAuthor;
        emit DecayUpdated(decayThisUpdate, challengerInfo.decayMultiplier, stakingInfo.decayMultiplier);
    }

    
    function updateVerifiedState(address _verifier) public override testNotFailed {
        require(msg.sender == factory, "ANTE: Must be called by factory");
        numTimesVerified++;
        lastVerifiedBlock = block.number;
        lastVerifiedTimestamp = block.timestamp;
        emit TestChecked(_verifier);
    }

    
    function updateFailureState(address _verifier) public override {
        require(msg.sender == factory, "ANTE: Must be called by factory");
        _updateFailureState(_verifier);
    }

    /*****************************************************
     * ================ VIEW FUNCTIONS ================= *
     *****************************************************/

    
    function pendingFailure() public view override returns (bool) {
        return IAntePoolFactory(factory).hasTestFailed(address(anteTest));
    }

    
    function getTotalChallengerStaked() external view override returns (uint256) {
        return challengerInfo.totalAmount;
    }

    
    function getTotalStaked() external view override returns (uint256) {
        return stakingInfo.totalAmount;
    }

    
    function getTotalPendingWithdraw() external view override returns (uint256) {
        return withdrawInfo.totalAmount;
    }

    
    function getTotalChallengerEligibleBalance() external view override returns (uint256) {
        return eligibilityInfo.totalShares;
    }

    
    function getChallengerInfo(
        address challenger
    )
        external
        view
        override
        returns (
            uint256 startAmount,
            uint256 lastStakedTimestamp,
            uint256 claimableShares,
            uint256 claimableSharesStartMultiplier
        )
    {
        ChallengerInfo storage user = challengers[challenger];
        startAmount = user.balanceInfo.startAmount;
        lastStakedTimestamp = user.lastStakedTimestamp;
        claimableShares = user.claimableShares.startAmount;
        claimableSharesStartMultiplier = user.claimableShares.startDecayMultiplier;
    }

    
    function getChallengerPayout(address challenger) external view override returns (uint256) {
        ChallengerInfo storage user = challengers[challenger];
        require(user.balanceInfo.startAmount > 0, "ANTE: No Challenger Staking balance");

        // If called before test failure returns an estimate
        if (pendingFailure()) {
            return _calculateChallengerPayout(user, challenger);
        } else {
            uint256 amount = _storedBalance(user.balanceInfo, challengerInfo.decayMultiplier);
            uint256 claimableShares = _storedBalance(user.claimableShares, challengerInfo.decayMultiplier);
            uint256 bounty = getVerifierBounty();
            uint256 totalStake = stakingInfo.totalAmount + withdrawInfo.totalAmount - bounty;

            return amount + totalStake.mulDiv(claimableShares, eligibilityInfo.totalShares);
        }
    }

    
    function getStoredBalance(address _user, bool isChallenger) external view override returns (uint256) {
        (uint256 decayMultiplierThisUpdate, , uint256 decayForStakers, ) = _computeDecay();

        BalanceInfo storage user = isChallenger ? challengers[_user].balanceInfo : stakers[_user].balanceInfo;

        if (user.startAmount == 0) return 0;

        uint256 decayMultiplier;

        if (isChallenger) {
            decayMultiplier = challengerInfo.decayMultiplier.mulDiv(decayMultiplierThisUpdate, ONE);
        } else {
            uint256 totalStaked = stakingInfo.totalAmount;
            uint256 totalStakedNew = totalStaked + decayForStakers;
            decayMultiplier = stakingInfo.decayMultiplier.mulDiv(totalStakedNew, totalStaked);
        }

        return _storedBalance(user, decayMultiplier);
    }

    
    function getPendingWithdrawAmount(address _user) external view override returns (uint256) {
        return withdrawInfo.userUnstakeInfo[_user].amount;
    }

    
    function getPendingWithdrawAllowedTime(address _user) external view override returns (uint256) {
        UserUnstakeInfo storage user = withdrawInfo.userUnstakeInfo[_user];
        require(user.amount > 0, "ANTE: nothing to withdraw");

        return user.lastUnstakeTimestamp + UNSTAKE_DELAY;
    }

    
    function getUnstakeAllowedTime(address _user) public view override returns (uint256) {
        return stakers[_user].unlockTimestamp;
    }

    
    function getCheckTestAllowedBlock(address _user) external view override returns (uint256) {
        return challengers[_user].lastStakedBlock + CHALLENGER_BLOCK_DELAY;
    }

    
    function getUserStartAmount(address _user, bool isChallenger) external view override returns (uint256) {
        return isChallenger ? challengers[_user].balanceInfo.startAmount : stakers[_user].balanceInfo.startAmount;
    }

    
    function getUserStartDecayMultiplier(address _user, bool isChallenger) external view override returns (uint256) {
        return
            isChallenger
                ? challengers[_user].balanceInfo.startDecayMultiplier
                : stakers[_user].balanceInfo.startDecayMultiplier;
    }

    
    function getVerifierBounty() public view override returns (uint256) {
        uint256 totalStake = stakingInfo.totalAmount + withdrawInfo.totalAmount;
        return totalStake.mulDiv(VERIFIER_BOUNTY, 100);
    }

    
    function getTestAuthorReward() public view override returns (uint256) {
        (, , , uint256 decayForAuthor) = _computeDecay();
        return _authorReward + decayForAuthor;
    }

    /*****************************************************
     * =============== INTERNAL HELPERS ================ *
     *****************************************************/

    
    
    
    
    
    
    /// immediately, if the user is a staker, the amount is moved to the withdraw
    /// info and then the 24 hour waiting period starts
    function _unstake(
        uint256 amount,
        bool isChallenger,
        PoolSideInfo storage side,
        BalanceInfo storage balanceInfo
    ) internal {
        // Calculate how much the user has available to unstake, including the
        // effects of any previously accrued decay.
        //   prevAmount = startAmount * decayMultiplier / startDecayMultiplier
        uint256 prevAmount = _storedBalance(balanceInfo, side.decayMultiplier);

        if (prevAmount == amount) {
            balanceInfo.startAmount = 0;
            balanceInfo.startDecayMultiplier = 0;
            side.numUsers--;

            // Remove from set of existing challengers
            if (isChallenger) {
                BalanceInfo storage claimableShares = challengers[msg.sender].claimableShares;
                uint256 sharesToRemove = _storedBalance(claimableShares, challengerInfo.decayMultiplier);
                eligibilityInfo.totalShares -= sharesToRemove;
                delete challengers[msg.sender];
            }
        } else {
            require(amount <= prevAmount, "ANTE: Withdraw request exceeds balance.");
            require(
                (isChallenger && (prevAmount - amount > minChallengerStake)) ||
                    (!isChallenger && (prevAmount - amount > minSupporterStake)),
                "ANTE: balance must be zero or greater than min"
            );
            balanceInfo.startAmount = prevAmount - amount;
            // Reset the startDecayMultiplier for this user, since we've updated
            // the startAmount to include any already-accrued decay.
            balanceInfo.startDecayMultiplier = side.decayMultiplier;

            if (isChallenger) {
                BalanceInfo storage claimableShares = challengers[msg.sender].claimableShares;
                // Use LIFO ordering for unstaking, if there is unconfirmed stake, unstake that first
                // The remaining amount to unstake detracts from the confirmed shares
                uint256 confirmedShares = _storedBalance(claimableShares, challengerInfo.decayMultiplier);
                uint256 unconfirmedShares = prevAmount - confirmedShares;

                uint256 confirmedSharesToRemove = amount - _min(unconfirmedShares, amount);
                claimableShares.startAmount = confirmedShares - confirmedSharesToRemove;
                claimableShares.startDecayMultiplier = challengerInfo.decayMultiplier;
                eligibilityInfo.totalShares -= confirmedSharesToRemove;
            }
        }
        side.totalAmount -= amount;

        if (isChallenger) token.safeTransfer(msg.sender, amount);
        else {
            // Just initiate the withdraw if staker
            UserUnstakeInfo storage unstakeUser = withdrawInfo.userUnstakeInfo[msg.sender];
            unstakeUser.lastUnstakeTimestamp = block.timestamp;
            unstakeUser.amount += amount;

            withdrawInfo.totalAmount += amount;
        }

        emit Unstake(msg.sender, amount, isChallenger);
    }

    
    
    /// decay computation
    
    
    
    
    function _computeDecay()
        internal
        view
        returns (
            uint256 decayMultiplierThisUpdate,
            uint256 decayThisUpdate,
            uint256 decayForStakers,
            uint256 decayForAuthor
        )
    {
        decayMultiplierThisUpdate = ONE;
        decayThisUpdate = 0;
        decayForStakers = 0;
        decayForAuthor = 0;

        if (block.timestamp <= lastUpdateTimestamp) {
            return (decayMultiplierThisUpdate, decayThisUpdate, decayForStakers, decayForAuthor);
        }

        if (!_canDecay()) {
            return (decayMultiplierThisUpdate, decayThisUpdate, decayForStakers, decayForAuthor);
        }

        uint256 numSeconds = block.timestamp - lastUpdateTimestamp;

        // The rest of the function updates the new accrued decay amounts
        //   decayRateThisUpdate = ONE * numSeconds * (decayRate / 100) / ONE_YEAR_IN_SECONDS
        //   decayMultiplierThisUpdate = 1 - decayRateThisUpdate
        //   decayThisUpdate = totalChallengerStaked * decayRateThisUpdate
        uint256 decayRateThisUpdate = ONE.mulDiv(decayRate, 100).mulDiv(numSeconds, ONE_YEAR);

        uint256 totalChallengerStaked = challengerInfo.totalAmount;
        // Failsafe to avoid underflow when calculating decayMultiplierThisUpdate
        if (decayRateThisUpdate >= ONE) {
            decayMultiplierThisUpdate = 0;
            decayThisUpdate = totalChallengerStaked;
        } else {
            decayMultiplierThisUpdate = ONE - decayRateThisUpdate;
            decayThisUpdate = totalChallengerStaked.mulDiv(decayRateThisUpdate, ONE);
        }
        decayForAuthor = decayThisUpdate.mulDiv(testAuthorRewardRate, 100);
        decayForStakers = decayThisUpdate - decayForAuthor;
    }

    
    
    
    
    /// are no longer estimates
    
    function _calculateChallengerPayout(
        ChallengerInfo storage user,
        address challenger
    ) internal view returns (uint256) {
        // Calculate this user's challenging balance.
        uint256 amount = _storedBalance(user.balanceInfo, challengerInfo.decayMultiplier);
        // Calculate how much of the staking pool this user gets, and add that
        // to the user's challenging balance.
        uint256 claimableShares = _storedBalance(user.claimableShares, challengerInfo.decayMultiplier);
        if (claimableShares > 0) {
            amount += claimableShares.mulDiv(_remainingStake, eligibilityInfo.totalShares);
        }
        return challenger == verifier ? amount + _bounty : amount;
    }

    
    
    
    
    
    function _storedBalance(BalanceInfo storage balanceInfo, uint256 decayMultiplier) internal view returns (uint256) {
        if (balanceInfo.startAmount == 0) return 0;

        require(balanceInfo.startDecayMultiplier > 0, "ANTE: Invalid startDecayMultiplier");

        uint256 balance = balanceInfo.startAmount.mulDiv(decayMultiplier, balanceInfo.startDecayMultiplier);

        return balance;
    }

    
    
    function _updateFailureState(address _verifier) internal {
        updateDecay();
        verifier = _verifier;
        failedBlock = block.number;
        failedTimestamp = block.timestamp;
        isDecaying = false;

        // If the verifier is not a challenger there will be no bounty to remeed.
        // As such, all the funds will be remeemable by challengers.
        // This can happen if the pool is failed through the factory
        // when the underlying test was failed by another pool.
        if (challengers[_verifier].balanceInfo.startAmount == 0) {
            _bounty = 0;
        } else {
            _bounty = getVerifierBounty();
        }

        uint256 totalStake = stakingInfo.totalAmount + withdrawInfo.totalAmount;
        _remainingStake = totalStake - _bounty;

        emit DecayPaused();
        emit FailureOccurred(_verifier);
    }

    
    
    
    
    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    
    function _testNotFailed() internal view {
        require(!pendingFailure(), "ANTE: Test already failed.");
    }

    
    /// Pool can decay only if there are stakers and challengers
    /// and if there are challenger funds to be decayed
    function _canDecay() internal view returns (bool) {
        return
            stakingInfo.numUsers > 0 &&
            challengerInfo.totalAmount > 0 &&
            challengerInfo.numUsers > 0 &&
            !pendingFailure();
    }
}

// 

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;





interface IAntePoolFactory {
    
    
    
    
    
    
    
    
    
    event AntePoolCreated(
        address indexed testAddr,
        address tokenAddr,
        uint256 tokenMinimum,
        uint256 payoutRatio,
        uint256 decayRate,
        uint256 authorRewardRate,
        address testPool,
        address poolCreator
    );

    
    event PoolFailureReverted();

    
    
    
    
    
    
    
    function createPool(
        address testAddr,
        address tokenAddr,
        uint256 payoutRatio,
        uint256 decayRate,
        uint256 authorRewardRate
    ) external returns (address testPool);

    
    
    function hasTestFailed(address testAddr) external view returns (bool);

    
    
    
    
    function checkTestWithState(
        bytes memory _testState,
        address verifier,
        bytes32 poolConfig
    ) external;

    
    
    
    function allPools(uint256 i) external view returns (address);

    
    
    
    function getPoolsByTest(address testAddr) external view returns (address[] memory);

    
    
    
    function getNumPoolsByTest(address testAddr) external view returns (uint256);

    
    
    
    function poolByConfig(bytes32 configHash) external view returns (address);

    
    
    function numPools() external view returns (uint256);

    
    
    function controller() external view returns (IAntePoolFactoryController);
}

// 

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;



interface IAntePoolFactoryController {
    
    
    
    event TokenAdded(address indexed tokenAddr, uint256 min);

    
    
    event TokenRemoved(address indexed tokenAddr);

    
    
    
    event TokenMinimumUpdated(address indexed tokenAddr, uint256 min);

    
    
    
    event AntePoolImplementationUpdated(address oldImplAddress, address implAddress);

    
    
    
    function addToken(address _tokenAddr, uint256 _min) external;

    
    /// It reverts only if no token was added
    
    
    function addTokens(address[] memory _tokenAddresses, uint256[] memory _mins) external;

    
    
    function removeToken(address _tokenAddr) external;

    
    /// This is used by the factory when creating a new pool
    
    function setPoolLogicAddr(address _antePoolLogicAddr) external;

    
    
    
    function isTokenAllowed(address _tokenAddr) external view returns (bool);

    
    
    
    function setTokenMinimum(address _tokenAddr, uint256 _min) external;

    
    
    
    function getTokenMinimum(address _tokenAddr) external view returns (uint256);

    
    
    function getAllowedTokens() external view returns (address[] memory);

    
    
    function antePoolLogicAddr() external view returns (address);
}

// 

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;



interface IAnteTest {
    
    
    
    event TestAuthorChanged(address indexed previousAuthor, address indexed newAuthor);

    
    
    
    function setStateAndCheckTestPasses(bytes memory _state) external returns (bool);

    
    
    
    function checkTestPasses() external returns (bool);

    
    
    
    function testAuthor() external view returns (address);

    
    
    
    function setTestAuthor(address _testAuthor) external;

    
    
    
    function protocolName() external view returns (string memory);

    
    
    
    
    function testedContracts(uint256 i) external view returns (address);

    
    
    
    function testName() external view returns (string memory);

    
    
    function getStateTypes() external pure returns (string memory);

    
    
    function getStateNames() external pure returns (string memory);
}