// SPDX-License-Identifier: MIT

// 
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

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

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pragma solidity ^0.8.0;






contract AntePool is Proxy {
    
    /// This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
    bytes32 internal constant _IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    
    constructor(address _antePoolLogicAddr) {
        require(Address.isContract(_antePoolLogicAddr), "ANTE: implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = _antePoolLogicAddr;
    }

    
    function _implementation() internal view override returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
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










contract AntePoolFactory is IAntePoolFactory, ReentrancyGuard {
    struct TestStateInfo {
        bool hasFailed;
        address verifier;
        uint256 failedBlock;
        uint256 failedTimestamp;
    }

    mapping(address => TestStateInfo) private stateByTest;

    // Stores all the pools associated with a test
    mapping(address => address[]) public poolsByTest;
    
    mapping(bytes32 => address) public override poolByConfig;
    
    address[] public override allPools;

    
    uint256 public constant MAX_POOLS_PER_TEST = 10;

    
    IAntePoolFactoryController public override controller;

    
    constructor(address _controller) {
        controller = IAntePoolFactoryController(_controller);
    }

    
    function createPool(
        address testAddr,
        address tokenAddr,
        uint256 payoutRatio,
        uint256 decayRate,
        uint256 authorRewardRate
    ) external override returns (address testPool) {
        // Checks that a non-zero AnteTest address is passed in and that
        // an AntePool has not already been created for that AnteTest
        require(testAddr != address(0), "ANTE: Test address is 0");
        require(!stateByTest[testAddr].hasFailed, "ANTE: Test has previously failed");
        require(controller.isTokenAllowed(tokenAddr), "ANTE: Token not allowed");
        require(poolsByTest[testAddr].length < MAX_POOLS_PER_TEST, "ANTE: Max pools per test reached");

        uint256 tokenMinimum = controller.getTokenMinimum(tokenAddr);
        bytes32 configHash = keccak256(
            abi.encodePacked(testAddr, tokenAddr, tokenMinimum, payoutRatio, decayRate, authorRewardRate)
        );
        address poolAddr = poolByConfig[configHash];
        require(poolAddr == address(0), "ANTE: Pool with the same config already exists");

        IAnteTest anteTest = IAnteTest(testAddr);

        testPool = address(new AntePool{salt: configHash}(controller.antePoolLogicAddr()));

        require(testPool != address(0), "ANTE: Pool creation failed");

        poolsByTest[testAddr].push(testPool);
        poolByConfig[configHash] = testPool;
        allPools.push(testPool);

        IAntePool(testPool).initialize(
            anteTest,
            IERC20(tokenAddr),
            tokenMinimum,
            decayRate,
            payoutRatio,
            authorRewardRate
        );

        emit AntePoolCreated(
            testAddr,
            tokenAddr,
            tokenMinimum,
            payoutRatio,
            decayRate,
            authorRewardRate,
            testPool,
            msg.sender
        );
    }

    
    function hasTestFailed(address testAddr) external view override returns (bool) {
        return stateByTest[testAddr].hasFailed;
    }

    
    function checkTestWithState(
        bytes memory _testState,
        address verifier,
        bytes32 poolConfig
    ) public override nonReentrant {
        address poolAddr = poolByConfig[poolConfig];
        require(poolAddr == msg.sender, "ANTE: Must be called by a pool");

        IAntePool pool = IAntePool(msg.sender);
        (, , uint256 claimableShares, ) = pool.getChallengerInfo(verifier);
        require(claimableShares > 0, "ANTE: Only confirmed challengers can checkTest");
        require(
            pool.getCheckTestAllowedBlock(verifier) < block.number,
            "ANTE: must wait 12 blocks after challenging to call checkTest"
        );
        IAnteTest anteTest = pool.anteTest();
        bool hasFailed = stateByTest[address(anteTest)].hasFailed;
        require(!hasFailed, "ANTE: Test already failed.");

        pool.updateVerifiedState(verifier);
        if (!_checkTestNoRevert(anteTest, _testState)) {
            _setFailureStateForTest(address(anteTest), verifier);
        }
    }

    
    function getPoolsByTest(address testAddr) external view override returns (address[] memory) {
        return poolsByTest[testAddr];
    }

    
    function getNumPoolsByTest(address testAddr) external view override returns (uint256) {
        return poolsByTest[testAddr].length;
    }

    
    function numPools() external view override returns (uint256) {
        return allPools.length;
    }

    /*****************************************************
     * =============== INTERNAL HELPERS ================ *
     *****************************************************/

    
    /// setStateAndCheckTestPasses or checkTestPasses reverts
    
    function _checkTestNoRevert(IAnteTest anteTest, bytes memory _testState) internal returns (bool) {
        // This condition replicates the logic from AnteTest(v0.6).setStateAndCheckTestPasses
        // It is used for backward compatibility with v0.5 tests
        if (_testState.length > 0) {
            try anteTest.setStateAndCheckTestPasses(_testState) returns (bool passes) {
                return passes;
            } catch {
                return true;
            }
        }

        try anteTest.checkTestPasses() returns (bool passes) {
            return passes;
        } catch {
            return true;
        }
    }

    function _setFailureStateForTest(address testAddr, address verifier) internal {
        TestStateInfo storage testState = stateByTest[testAddr];
        testState.hasFailed = true;
        testState.failedBlock = block.number;
        testState.failedTimestamp = block.timestamp;
        testState.verifier = verifier;

        address[] memory pools = poolsByTest[testAddr];
        uint256 numPoolsByTest = pools.length;
        for (uint256 i = 0; i < numPoolsByTest; i++) {
            try IAntePool(pools[i]).updateFailureState(verifier) {} catch {
                emit PoolFailureReverted();
            }
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

// 

// ┏━━━┓━━━━━┏┓━━━━━━━━━┏━━━┓━━━━━━━━━━━━━━━━━━━━━━━
// ┃┏━┓┃━━━━┏┛┗┓━━━━━━━━┃┏━━┛━━━━━━━━━━━━━━━━━━━━━━━
// ┃┗━┛┃┏━┓━┗┓┏┛┏━━┓━━━━┃┗━━┓┏┓┏━┓━┏━━┓━┏━┓━┏━━┓┏━━┓
// ┃┏━┓┃┃┏┓┓━┃┃━┃┏┓┃━━━━┃┏━━┛┣┫┃┏┓┓┗━┓┃━┃┏┓┓┃┏━┛┃┏┓┃
// ┃┃ ┃┃┃┃┃┃━┃┗┓┃┃━┫━┏┓━┃┃━━━┃┃┃┃┃┃┃┗┛┗┓┃┃┃┃┃┗━┓┃┃━┫
// ┗┛ ┗┛┗┛┗┛━┗━┛┗━━┛━┗┛━┗┛━━━┗┛┗┛┗┛┗━━━┛┗┛┗┛┗━━┛┗━━┛
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inspired by https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/StorageSlot.sol

pragma solidity ^0.8.0;

library StorageSlot {
    struct AddressSlot {
        address value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        
        assembly {
            r.slot := slot
        }
    }
}