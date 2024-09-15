// SPDX-License-Identifier: GPL-3.0

/**
 *Submitted for verification at Etherscan.io on 2021-11-01
*/

// Sources flattened with hardhat v2.6.7 https://hardhat.org

// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]

// 

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}


// File @openzeppelin/contracts-upgradeable/utils/[email protected]



pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}


// File @openzeppelin/contracts-upgradeable/security/[email protected]



pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}


// File @openzeppelin/contracts-upgradeable/token/ERC721/[email protected]



pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
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


// File @openzeppelin/contracts-upgradeable/utils/introspection/[email protected]



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
interface IERC165Upgradeable {
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


// File @openzeppelin/contracts-upgradeable/token/ERC721/[email protected]



pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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


// File @openzeppelin/contracts-upgradeable/utils/introspection/[email protected]



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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}


// File @openzeppelin/contracts-upgradeable/utils/[email protected]



pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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


// File @openzeppelin/contracts-upgradeable/utils/[email protected]



pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}


// File @openzeppelin/contracts/token/ERC20/[email protected]



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


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]



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


// File @openzeppelin/contracts/utils/[email protected]



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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]



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


// File @openzeppelin/contracts-upgradeable/utils/[email protected]



pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
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


// File contracts/interfaces/IAccessControl.sol



pragma solidity ^0.8.7;




interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}


// File contracts/external/AccessControlUpgradeable.sol



pragma solidity ^0.8.7;


/**
 * @dev This contract is fully forked from OpenZeppelin `AccessControlUpgradeable`.
 * The only difference is the removal of the ERC165 implementation as it's not
 * needed in Angle.
 *
 * Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, IAccessControl {
    function __AccessControl_init() internal initializer {
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {}

    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, msg.sender);
        _;
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external override {
        require(account == msg.sender, "71");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) internal {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
    }

    function _revokeRole(bytes32 role, address account) internal {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
    }

    uint256[49] private __gap;
}


// File contracts/interfaces/IFeeManager.sol



pragma solidity ^0.8.7;




interface IFeeManagerFunctions is IAccessControl {
    // ================================= Keepers ===================================

    function updateUsersSLP() external;

    function updateHA() external;

    // ================================= Governance ================================

    function deployCollateral(
        address[] memory governorList,
        address guardian,
        address _perpetualManager
    ) external;

    function setFees(
        uint256[] memory xArray,
        uint64[] memory yArray,
        uint8 typeChange
    ) external;

    function setHAFees(uint64 _haFeeDeposit, uint64 _haFeeWithdraw) external;
}





interface IFeeManager is IFeeManagerFunctions {
    function stableMaster() external view returns (address);

    function perpetualManager() external view returns (address);
}


// File @openzeppelin/contracts/utils/introspection/[email protected]



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


// File contracts/interfaces/IERC721.sol



pragma solidity ^0.8.7;

interface IERC721 is IERC165 {
    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}


// File contracts/interfaces/IOracle.sol



pragma solidity ^0.8.7;




/// from just UniswapV3 or from just Chainlink
interface IOracle {
    function read() external view returns (uint256);

    function readAll() external view returns (uint256 lowerRate, uint256 upperRate);

    function readLower() external view returns (uint256);

    function readUpper() external view returns (uint256);

    function readQuote(uint256 baseAmount) external view returns (uint256);

    function readQuoteLower(uint256 baseAmount) external view returns (uint256);

    function inBase() external view returns (uint256);
}


// File contracts/interfaces/IPerpetualManager.sol



pragma solidity ^0.8.7;







interface IPerpetualManagerFront is IERC721Metadata {
    function openPerpetual(
        address owner,
        uint256 amountBrought,
        uint256 amountCommitted,
        uint256 maxOracleRate,
        uint256 minNetMargin
    ) external returns (uint256 perpetualID);

    function closePerpetual(
        uint256 perpetualID,
        address to,
        uint256 minCashOutAmount
    ) external;

    function addToPerpetual(uint256 perpetualID, uint256 amount) external;

    function removeFromPerpetual(
        uint256 perpetualID,
        uint256 amount,
        address to
    ) external;

    function liquidatePerpetuals(uint256[] memory perpetualIDs) external;

    function forceClosePerpetuals(uint256[] memory perpetualIDs) external;

    // ========================= External View Functions =============================

    function getCashOutAmount(uint256 perpetualID, uint256 rate) external view returns (uint256, uint256);

    function isApprovedOrOwner(address spender, uint256 perpetualID) external view returns (bool);
}




/// interacted with in other parts of the protocol
interface IPerpetualManagerFunctions is IAccessControl {
    // ================================= Governance ================================

    function deployCollateral(
        address[] memory governorList,
        address guardian,
        IFeeManager feeManager,
        IOracle oracle_
    ) external;

    function setFeeManager(IFeeManager feeManager_) external;

    function setHAFees(
        uint64[] memory _xHAFees,
        uint64[] memory _yHAFees,
        uint8 deposit
    ) external;

    function setTargetAndLimitHAHedge(uint64 _targetHAHedge, uint64 _limitHAHedge) external;

    function setKeeperFeesLiquidationRatio(uint64 _keeperFeesLiquidationRatio) external;

    function setKeeperFeesCap(uint256 _keeperFeesLiquidationCap, uint256 _keeperFeesClosingCap) external;

    function setKeeperFeesClosing(uint64[] memory _xKeeperFeesClosing, uint64[] memory _yKeeperFeesClosing) external;

    function setLockTime(uint64 _lockTime) external;

    function setBoundsPerpetual(uint64 _maxLeverage, uint64 _maintenanceMargin) external;

    function pause() external;

    function unpause() external;

    // ==================================== Keepers ================================

    function setFeeKeeper(uint64 feeDeposit, uint64 feesWithdraw) external;

    // =============================== StableMaster ================================

    function setOracle(IOracle _oracle) external;
}




interface IPerpetualManager is IPerpetualManagerFunctions {
    function poolManager() external view returns (address);

    function oracle() external view returns (address);

    function targetHAHedge() external view returns (uint64);

    function totalHedgeAmount() external view returns (uint256);
}


// File contracts/interfaces/IPoolManager.sol



pragma solidity ^0.8.7;



// Struct for the parameters associated to a strategy interacting with a collateral `PoolManager`
// contract
struct StrategyParams {
    // Timestamp of last report made by this strategy
    // It is also used to check if a strategy has been initialized
    uint256 lastReport;
    // Total amount the strategy is expected to have
    uint256 totalStrategyDebt;
    // The share of the total assets in the `PoolManager` contract that the `strategy` can access to.
    uint256 debtRatio;
}




/// a given stablecoin

interface IPoolManagerFunctions {
    // ============================ Constructor ====================================

    function deployCollateral(
        address[] memory governorList,
        address guardian,
        IPerpetualManager _perpetualManager,
        IFeeManager feeManager,
        IOracle oracle
    ) external;

    // ============================ Yield Farming ==================================

    function creditAvailable() external view returns (uint256);

    function debtOutstanding() external view returns (uint256);

    function report(
        uint256 _gain,
        uint256 _loss,
        uint256 _debtPayment
    ) external;

    // ============================ Governance =====================================

    function addGovernor(address _governor) external;

    function removeGovernor(address _governor) external;

    function setGuardian(address _guardian, address guardian) external;

    function revokeGuardian(address guardian) external;

    function setFeeManager(IFeeManager _feeManager) external;

    // ============================= Getters =======================================

    function getBalance() external view returns (uint256);

    function getTotalAsset() external view returns (uint256);
}





interface IPoolManager is IPoolManagerFunctions {
    function stableMaster() external view returns (address);

    function perpetualManager() external view returns (address);

    function token() external view returns (address);

    function feeManager() external view returns (address);

    function totalDebt() external view returns (uint256);

    function strategies(address _strategy) external view returns (StrategyParams memory);
}


// File contracts/interfaces/IStakingRewards.sol



pragma solidity ^0.8.7;




interface IStakingRewardsFunctions {
    function notifyRewardAmount(uint256 reward) external;

    function recoverERC20(
        address tokenAddress,
        address to,
        uint256 tokenAmount
    ) external;

    function setNewRewardsDistribution(address newRewardsDistribution) external;
}




interface IStakingRewards is IStakingRewardsFunctions {
    function rewardToken() external view returns (IERC20);
}


// File contracts/interfaces/IRewardsDistributor.sol



pragma solidity ^0.8.7;



/// (https://github.com/fei-protocol/fei-protocol-core/blob/master/contracts/staking/IRewardsDistributor.sol)

interface IRewardsDistributor {
    // ========================= Public Parameter Getter ===========================

    function rewardToken() external view returns (IERC20);

    // ======================== External User Available Function ===================

    function drip(IStakingRewards stakingContract) external returns (uint256);

    // ========================= Governor Functions ================================

    function governorWithdrawRewardToken(uint256 amount, address governance) external;

    function governorRecover(
        address tokenAddress,
        address to,
        uint256 amount,
        IStakingRewards stakingContract
    ) external;

    function setUpdateFrequency(uint256 _frequency, IStakingRewards stakingContract) external;

    function setIncentiveAmount(uint256 _incentiveAmount, IStakingRewards stakingContract) external;

    function setAmountToDistribute(uint256 _amountToDistribute, IStakingRewards stakingContract) external;

    function setDuration(uint256 _duration, IStakingRewards stakingContract) external;

    function setStakingContract(
        address _stakingContract,
        uint256 _duration,
        uint256 _incentiveAmount,
        uint256 _dripFrequency,
        uint256 _amountToDistribute
    ) external;

    function setNewRewardsDistributor(address newRewardsDistributor) external;

    function removeStakingContract(IStakingRewards stakingContract) external;
}


// File @openzeppelin/contracts-upgradeable/token/ERC20/[email protected]



pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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


// File contracts/interfaces/ISanToken.sol



pragma solidity ^0.8.7;




/// contributing to a collateral for a given stablecoin
interface ISanToken is IERC20Upgradeable {
    // ================================== StableMaster =============================

    function mint(address account, uint256 amount) external;

    function burnFrom(
        uint256 amount,
        address burner,
        address sender
    ) external;

    function burnSelf(uint256 amount, address burner) external;

    function stableMaster() external view returns (address);

    function poolManager() external view returns (address);
}


// File contracts/interfaces/IStableMaster.sol



pragma solidity ^0.8.7;

// Normally just importing `IPoolManager` should be sufficient, but for clarity here
// we prefer to import all concerned interfaces




// Struct to handle all the parameters to manage the fees
// related to a given collateral pool (associated to the stablecoin)
struct MintBurnData {
    // Values of the thresholds to compute the minting fees
    // depending on HA hedge (scaled by `BASE_PARAMS`)
    uint64[] xFeeMint;
    // Values of the fees at thresholds (scaled by `BASE_PARAMS`)
    uint64[] yFeeMint;
    // Values of the thresholds to compute the burning fees
    // depending on HA hedge (scaled by `BASE_PARAMS`)
    uint64[] xFeeBurn;
    // Values of the fees at thresholds (scaled by `BASE_PARAMS`)
    uint64[] yFeeBurn;
    // Max proportion of collateral from users that can be covered by HAs
    // It is exactly the same as the parameter of the same name in `PerpetualManager`, whenever one is updated
    // the other changes accordingly
    uint64 targetHAHedge;
    // Minting fees correction set by the `FeeManager` contract: they are going to be multiplied
    // to the value of the fees computed using the hedge curve
    // Scaled by `BASE_PARAMS`
    uint64 bonusMalusMint;
    // Burning fees correction set by the `FeeManager` contract: they are going to be multiplied
    // to the value of the fees computed using the hedge curve
    // Scaled by `BASE_PARAMS`
    uint64 bonusMalusBurn;
    // Parameter used to limit the number of stablecoins that can be issued using the concerned collateral
    uint256 capOnStableMinted;
}

// Struct to handle all the variables and parameters to handle SLPs in the protocol
// including the fraction of interests they receive or the fees to be distributed to
// them
struct SLPData {
    // Last timestamp at which the `sanRate` has been updated for SLPs
    uint256 lastBlockUpdated;
    // Fees accumulated from previous blocks and to be distributed to SLPs
    uint256 lockedInterests;
    // Max interests used to update the `sanRate` in a single block
    // Should be in collateral token base
    uint256 maxInterestsDistributed;
    // Amount of fees left aside for SLPs and that will be distributed
    // when the protocol is collateralized back again
    uint256 feesAside;
    // Part of the fees normally going to SLPs that is left aside
    // before the protocol is collateralized back again (depends on collateral ratio)
    // Updated by keepers and scaled by `BASE_PARAMS`
    uint64 slippageFee;
    // Portion of the fees from users minting and burning
    // that goes to SLPs (the rest goes to surplus)
    uint64 feesForSLPs;
    // Slippage factor that's applied to SLPs exiting (depends on collateral ratio)
    // If `slippage = BASE_PARAMS`, SLPs can get nothing, if `slippage = 0` they get their full claim
    // Updated by keepers and scaled by `BASE_PARAMS`
    uint64 slippage;
    // Portion of the interests from lending
    // that goes to SLPs (the rest goes to surplus)
    uint64 interestsForSLPs;
}




interface IStableMasterFunctions {
    function deploy(
        address[] memory _governorList,
        address _guardian,
        address _agToken
    ) external;

    // ============================== Lending ======================================

    function accumulateInterest(uint256 gain) external;

    function signalLoss(uint256 loss) external;

    // ============================== HAs ==========================================

    function getStocksUsers() external view returns (uint256 maxCAmountInStable);

    function convertToSLP(uint256 amount, address user) external;

    // ============================== Keepers ======================================

    function getCollateralRatio() external returns (uint256);

    function setFeeKeeper(
        uint64 feeMint,
        uint64 feeBurn,
        uint64 _slippage,
        uint64 _slippageFee
    ) external;

    // ============================== AgToken ======================================

    function updateStocksUsers(uint256 amount, address poolManager) external;

    // ============================= Governance ====================================

    function setCore(address newCore) external;

    function addGovernor(address _governor) external;

    function removeGovernor(address _governor) external;

    function setGuardian(address newGuardian, address oldGuardian) external;

    function revokeGuardian(address oldGuardian) external;

    function setCapOnStableAndMaxInterests(
        uint256 _capOnStableMinted,
        uint256 _maxInterestsDistributed,
        IPoolManager poolManager
    ) external;

    function setIncentivesForSLPs(
        uint64 _feesForSLPs,
        uint64 _interestsForSLPs,
        IPoolManager poolManager
    ) external;

    function setUserFees(
        IPoolManager poolManager,
        uint64[] memory _xFee,
        uint64[] memory _yFee,
        uint8 _mint
    ) external;

    function setTargetHAHedge(uint64 _targetHAHedge) external;

    function pause(bytes32 agent, IPoolManager poolManager) external;

    function unpause(bytes32 agent, IPoolManager poolManager) external;
}




interface IStableMaster is IStableMasterFunctions {
    function agToken() external view returns (address);

    function collateralMap(IPoolManager poolManager)
        external
        view
        returns (
            IERC20 token,
            ISanToken sanToken,
            IPerpetualManager perpetualManager,
            IOracle oracle,
            uint256 stocksUsers,
            uint256 sanRate,
            uint256 collatBase,
            SLPData memory slpData,
            MintBurnData memory feeData
        );
}


// File contracts/utils/FunctionUtils.sol



pragma solidity ^0.8.7;






contract FunctionUtils {
    
    uint256 public constant BASE_TOKENS = 10**18;
    
    /// that are defined as ratios)
    uint256 public constant BASE_PARAMS = 10**9;

    
    
    
    
    
    
    /// equal to the first or last value of the yArray
    
    /// everything will be as if `x` is equal to the greater element of the `xArray`
    function _piecewiseLinear(
        uint64 x,
        uint64[] memory xArray,
        uint64[] memory yArray
    ) internal pure returns (uint64) {
        if (x >= xArray[xArray.length - 1]) {
            return yArray[xArray.length - 1];
        } else if (x <= xArray[0]) {
            return yArray[0];
        } else {
            uint256 lower;
            uint256 upper = xArray.length - 1;
            uint256 mid;
            while (upper - lower > 1) {
                mid = lower + (upper - lower) / 2;
                if (xArray[mid] <= x) {
                    lower = mid;
                } else {
                    upper = mid;
                }
            }
            if (yArray[upper] > yArray[lower]) {
                // There is no risk of overflow here as in the product of the difference of `y`
                // with the difference of `x`, the product is inferior to `BASE_PARAMS**2` which does not
                // overflow for `uint64`
                return
                    yArray[lower] +
                    ((yArray[upper] - yArray[lower]) * (x - xArray[lower])) /
                    (xArray[upper] - xArray[lower]);
            } else {
                return
                    yArray[lower] -
                    ((yArray[lower] - yArray[upper]) * (x - xArray[lower])) /
                    (xArray[upper] - xArray[lower]);
            }
        }
    }

    
    
    
    
    
    /// in the `xArray` are in ascending order and if the values in the `xArray` and in the `yArray` are not superior
    /// to `BASE_PARAMS`
    modifier onlyCompatibleInputArrays(uint64[] memory xArray, uint64[] memory yArray) {
        require(xArray.length == yArray.length && xArray.length > 0, "5");
        for (uint256 i = 0; i <= yArray.length - 1; i++) {
            require(yArray[i] <= uint64(BASE_PARAMS) && xArray[i] <= uint64(BASE_PARAMS), "6");
            if (i > 0) {
                require(xArray[i] > xArray[i - 1], "7");
            }
        }
        _;
    }

    
    /// if it corresponds to a ratio)
    
    modifier onlyCompatibleFees(uint64 fees) {
        require(fees <= BASE_PARAMS, "4");
        _;
    }

    
    
    
    modifier zeroCheck(address newAddress) {
        require(newAddress != address(0), "0");
        _;
    }
}


// File contracts/perpetualManager/PerpetualManagerEvents.sol



pragma solidity ^0.8.7;















// Used in the `forceCashOutPerpetuals` function to store owners of perpetuals which have been force cashed
// out, along with the amount associated to it
struct Pairs {
    address owner;
    uint256 netCashOutAmount;
}






contract PerpetualManagerEvents {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event PerpetualUpdated(uint256 _perpetualID, uint256 _margin);

    event PerpetualOpened(uint256 _perpetualID, uint256 _entryRate, uint256 _margin, uint256 _committedAmount);

    event PerpetualClosed(uint256 _perpetualID, uint256 _closeAmount);

    event PerpetualsForceClosed(uint256[] perpetualIDs, Pairs[] ownerAndCashOut, address keeper, uint256 reward);

    event KeeperTransferred(address keeperAddress, uint256 liquidationFees);

    // ============================== Parameters ===================================

    event BaseURIUpdated(string _baseURI);

    event LockTimeUpdated(uint64 _lockTime);

    event KeeperFeesCapUpdated(uint256 _keeperFeesLiquidationCap, uint256 _keeperFeesClosingCap);

    event TargetAndLimitHAHedgeUpdated(uint64 _targetHAHedge, uint64 _limitHAHedge);

    event BoundsPerpetualUpdated(uint64 _maxLeverage, uint64 _maintenanceMargin);

    event HAFeesUpdated(uint64[] _xHAFees, uint64[] _yHAFees, uint8 deposit);

    event KeeperFeesLiquidationRatioUpdated(uint64 _keeperFeesLiquidationRatio);

    event KeeperFeesClosingUpdated(uint64[] xKeeperFeesClosing, uint64[] yKeeperFeesClosing);

    // =============================== Reward ======================================

    event RewardAdded(uint256 _reward);

    event RewardPaid(address indexed _user, uint256 _reward);

    event RewardsDistributionUpdated(address indexed _rewardsDistributor);

    event RewardsDistributionDurationUpdated(uint256 _rewardsDuration, address indexed _rewardsDistributor);

    event Recovered(address indexed tokenAddress, address indexed to, uint256 amount);
}


// File contracts/perpetualManager/PerpetualManagerStorage.sol



pragma solidity ^0.8.7;

struct Perpetual {
    // Oracle value at the moment of perpetual opening
    uint256 entryRate;
    // Timestamp at which the perpetual was opened
    uint256 entryTimestamp;
    // Amount initially brought in the perpetual (net from fees) + amount added - amount removed from it
    // This is the only element that can be modified in the perpetual after its creation
    uint256 margin;
    // Amount of collateral covered by the perpetual. This cannot be modified once the perpetual is opened.
    // The amount covered is used interchangeably with the amount hedged
    uint256 committedAmount;
}






// solhint-disable-next-line max-states-count
contract PerpetualManagerStorage is PerpetualManagerEvents, FunctionUtils {
    // Base used in the collateral implementation (ERC20 decimal)
    uint256 internal _collatBase;

    // ============================== Perpetual Variables ==========================

    
    /// collateral thanks to HAs)
    /// When a HA opens a perpetual, it covers/hedges a fixed amount of stablecoins for the protocol, equal to
    /// the committed amount times the entry rate
    /// `totalHedgeAmount` is the sum of all these hedged amounts
    uint256 public totalHedgeAmount;

    // Counter to generate a unique `perpetualID` for each perpetual
    CountersUpgradeable.Counter internal _perpetualIDcount;

    // ========================== Mutable References ============================

    
    /// with respect to the price of the stablecoin
    /// This reference can be modified by the corresponding `StableMaster` contract
    IOracle public oracle;

    // `FeeManager` address allowed to update the way fees are computed for this contract
    // This reference can be modified by the `PoolManager` contract
    IFeeManager internal _feeManager;

    // ========================== Immutable References ==========================

    
    /// As of Angle V1, only a single `rewardToken` can be distributed to HAs who own a perpetual
    /// This implementation assumes that reward tokens have a base of 18 decimals
    IERC20 public rewardToken;

    
    IPoolManager public poolManager;

    // Address of the `StableMaster` instance
    IStableMaster internal _stableMaster;

    // Interface for the underlying token accepted by this contract
    // This reference cannot be changed, it is taken from the `PoolManager`
    IERC20 internal _token;

    // ======================= Fees and other Parameters ===========================

    /// Deposit fees for HAs depend on the hedge ratio that is the ratio between what is hedged
    /// (or covered, this is a synonym) by HAs compared with the total amount to hedge
    
    /// The bigger the ratio the bigger the fees will be because this means that the max amount
    /// to insure is soon to be reached
    uint64[] public xHAFeesDeposit;

    
    /// This array should have the same length as the array above
    /// The evolution of the fees between two threshold values is linear
    uint64[] public yHAFeesDeposit;

    /// Withdraw fees for HAs also depend on the hedge ratio
    
    uint64[] public xHAFeesWithdraw;

    
    uint64[] public yHAFeesWithdraw;

    
    /// The margin ratio is defined for a perpetual as: `(initMargin + PnL) / committedAmount` where
    /// `PnL = committedAmount * (1 - initRate/currentRate)`
    /// If the `marginRatio` is below `maintenanceMargin`: then the perpetual can be liquidated
    uint64 public maintenanceMargin;

    
    /// Leverage for a perpetual here corresponds to the ratio between the amount committed
    /// and the margin of the perpetual
    uint64 public maxLeverage;

    
    /// This variable is exactly the same as the one in the `StableMaster` contract for this collateral.
    /// Above this hedge ratio, HAs cannot open new perpetuals
    /// When keepers are forcing the closing of some perpetuals, they are incentivized to bringing
    /// the hedge ratio to this proportion
    uint64 public targetHAHedge;

    
    /// Above this ratio `forceCashOut` is activated and anyone can see its perpetual cashed out
    uint64 public limitHAHedge;

    
    /// can be used to change deposit fees. It works as a bonus - malus fee, if `haBonusMalusDeposit > BASE_PARAMS`,
    /// then the fee will be larger than `haFeesDeposit`, if `haBonusMalusDeposit < BASE_PARAMS`, fees will be smaller.
    /// This parameter, updated by keepers in the `FeeManager` contract, could most likely depend on the collateral ratio
    uint64 public haBonusMalusDeposit;

    
    /// can be used to change withdraw fees. It works as a bonus - malus fee, if `haBonusMalusWithdraw > BASE_PARAMS`,
    /// then the fee will be larger than `haFeesWithdraw`, if `haBonusMalusWithdraw < BASE_PARAMS`, fees will be smaller
    uint64 public haBonusMalusWithdraw;

    
    /// either using `removeFromPerpetual` or `closePerpetual`. New perpetuals cannot be forced closed in
    /// situations where the `forceClosePerpetuals` function is activated before this `lockTime` elapsed
    uint64 public lockTime;

    // ================================= Keeper fees ======================================
    // All these parameters can be modified by their corresponding governance function

    
    /// liquidating keepers
    uint64 public keeperFeesLiquidationRatio;

    
    /// If a keeper liquidates n perpetuals in a single transaction, then this keeper is entitled to get as much as
    /// `n * keeperFeesLiquidationCap` as a reward
    uint256 public keeperFeesLiquidationCap;

    
    /// (hedge ratio above `limitHAHedge`)
    /// If a keeper forces the closing of n perpetuals in a single transaction, then this keeper is entitled to get
    /// as much as `keeperFeesClosingCap`. This cap amount is independent of the number of perpetuals closed
    uint256 public keeperFeesClosingCap;

    
    /// target hedged amount by HAs (`targetHedgeAmount`) divided by 2. A value of `0.5` corresponds to a hedge ratio
    /// of `1`. Doing this allows to maintain an array with values of `x` inferior to `BASE_PARAMS`.
    uint64[] public xKeeperFeesClosing;

    
    uint64[] public yKeeperFeesClosing;

    // =========================== Staking Parameters ==============================

    
    /// to be able to compute rewards from staking (having perpetuals here) correctly
    uint256 public periodFinish;
    uint256 public rewardRate;
    uint256 public rewardsDuration;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    address public rewardsDistribution;

    // ============================== ERC721 Base URI ==============================

    
    string public baseURI;

    // =============================== Mappings ====================================

    
    mapping(uint256 => Perpetual) public perpetualData;

    
    mapping(uint256 => uint256) public perpetualRewardPerTokenPaid;

    
    // identified by its ID
    mapping(uint256 => uint256) public rewards;

    // Mapping from `perpetualID` to owner address
    mapping(uint256 => address) internal _owners;

    // Mapping from owner address to perpetual owned count
    mapping(address => uint256) internal _balances;

    // Mapping from `perpetualID` to approved address
    mapping(uint256 => address) internal _perpetualApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) internal _operatorApprovals;
}


// File contracts/perpetualManager/PerpetualManagerInternal.sol



pragma solidity ^0.8.7;






contract PerpetualManagerInternal is PerpetualManagerStorage {
    using Address for address;
    using SafeERC20 for IERC20;

    // ======================== State Modifying Functions ==========================

    
    /// in the contract
    
    
    function _closePerpetual(uint256 perpetualID, Perpetual memory perpetual) internal {
        // Handling the staking logic
        // Reward should always be updated before the `totalHedgeAmount`
        // Rewards are distributed to the perpetual which is liquidated
        uint256 hedge = perpetual.committedAmount * perpetual.entryRate;
        _getReward(perpetualID, hedge);
        delete perpetualRewardPerTokenPaid[perpetualID];

        // Updating `totalHedgeAmount` to represent the fact that less money is insured
        totalHedgeAmount -= hedge / _collatBase;

        _burn(perpetualID);
    }

    
    /// not enough reserves
    
    
    
    /// then the owner is reimbursed by receiving what is missing in sanTokens at the correct value
    function _secureTransfer(address owner, uint256 amount) internal {
        uint256 curBalance = poolManager.getBalance();
        if (curBalance >= amount && amount > 0) {
            // Case where there is enough in reserves to reimburse the person
            _token.safeTransferFrom(address(poolManager), owner, amount);
        } else if (amount > 0) {
            // When there is not enough to reimburse the entire amount, the protocol reimburses
            // what it can using its reserves and the rest is paid in sanTokens at the current
            // exchange rate
            uint256 amountLeft = amount - curBalance;
            _token.safeTransferFrom(address(poolManager), owner, curBalance);
            _stableMaster.convertToSLP(amountLeft, owner);
        }
    }

    
    
    
    
    
    
    
    /// it's the one that is most at the advantage of the protocol, hence the `rateDown` parameter
    function _checkLiquidation(
        uint256 perpetualID,
        Perpetual memory perpetual,
        uint256 rateDown
    ) internal returns (uint256, uint256) {
        uint256 liquidated;
        (uint256 cashOutAmount, uint256 reachMaintenanceMargin) = _getCashOutAmount(perpetual, rateDown);
        if (cashOutAmount == 0 || reachMaintenanceMargin == 1) {
            _closePerpetual(perpetualID, perpetual);
            // No need for an event to find out that a perpetual is liquidated
            liquidated = 1;
        }
        return (cashOutAmount, liquidated);
    }

    // ========================= Internal View Functions ===========================

    
    
    
    
    
    /// compared with its initial position
    
    
    function _getCashOutAmount(Perpetual memory perpetual, uint256 rate)
        internal
        view
        returns (uint256 cashOutAmount, uint256 reachMaintenanceMargin)
    {
        // All these computations are made just because we are working with uint and not int
        // so we cannot do x-y if x<y
        uint256 newCommit = (perpetual.committedAmount * perpetual.entryRate) / rate;
        // Checking if a liquidation is needed: for this to happen the `cashOutAmount` should be inferior
        // to the maintenance margin of the perpetual
        reachMaintenanceMargin;
        if (newCommit >= perpetual.committedAmount + perpetual.margin) cashOutAmount = 0;
        else {
            // The definition of the margin ratio is `(margin + PnL) / committedAmount`
            // where `PnL = commit * (1-entryRate/currentRate)`
            // So here: `newCashOutAmount = margin + PnL`
            cashOutAmount = perpetual.committedAmount + perpetual.margin - newCommit;
            if (cashOutAmount * BASE_PARAMS <= perpetual.committedAmount * maintenanceMargin)
                reachMaintenanceMargin = 1;
        }
    }

    
    
    
    
    /// the same value is returned twice
    function _getOraclePrice() internal view returns (uint256, uint256) {
        return oracle.readAll();
    }

    
    /// which value falls below its maintenance margin
    
    
    /// of the `committedAmount`, keepers are incentivized to react fast when a perpetual is below the maintenance margin
    
    /// this is not the case here
    function _computeKeeperLiquidationFees(uint256 cashOutAmount) internal view returns (uint256 keeperFees) {
        keeperFees = (cashOutAmount * keeperFeesLiquidationRatio) / BASE_PARAMS;
        keeperFees = keeperFees < keeperFeesLiquidationCap ? keeperFees : keeperFeesLiquidationCap;
    }

    
    /// and the target amount that should be hedged by them
    
    
    /// and the target amount to hedge
    function _computeHedgeRatio(uint256 currentHedgeAmount) internal view returns (uint64 ratio) {
        // Fetching info from the `StableMaster`: the amount to hedge is based on the `stocksUsers`
        // of the given collateral
        uint256 targetHedgeAmount = (_stableMaster.getStocksUsers() * targetHAHedge) / BASE_PARAMS;
        if (currentHedgeAmount < targetHedgeAmount)
            ratio = uint64((currentHedgeAmount * BASE_PARAMS) / targetHedgeAmount);
        else ratio = uint64(BASE_PARAMS);
    }

    // =========================== Fee Computation =================================

    
    
    
    
    /// paid by the HA
    
    
    function _getNetMargin(
        uint256 margin,
        uint256 totalHedgeAmountUpdate,
        uint256 committedAmount
    ) internal view returns (uint256 netMargin) {
        // Checking if the HA has the right to open a perpetual with such amount
        // If HAs hedge more than the target amount, then new HAs will not be able to create perpetuals
        // The amount hedged by HAs after opening the perpetual is going to be:
        uint64 ratio = _computeHedgeRatio(totalHedgeAmount + totalHedgeAmountUpdate);
        require(ratio < uint64(BASE_PARAMS), "25");
        // Computing the net margin of HAs to store in the perpetual: it consists simply in deducing fees
        // Those depend on how much is already hedged by HAs compared with what's to hedge
        uint256 haFeesDeposit = (haBonusMalusDeposit * _piecewiseLinear(ratio, xHAFeesDeposit, yHAFeesDeposit)) /
            BASE_PARAMS;
        // Fees are rounded to the advantage of the protocol
        haFeesDeposit = committedAmount - (committedAmount * (BASE_PARAMS - haFeesDeposit)) / BASE_PARAMS;
        // Fees are computed based on the committed amount of the perpetual
        // The following reverts if fees are too big compared to the margin
        netMargin = margin - haFeesDeposit;
    }

    
    
    
    
    
    
    
    /// function
    
    /// when too much is covered
    function _getNetCashOutAmount(
        uint256 cashOutAmount,
        uint256 committedAmount,
        uint64 ratio
    ) internal view returns (uint256 netCashOutAmount, uint256 feesPaid) {
        feesPaid = (haBonusMalusWithdraw * _piecewiseLinear(ratio, xHAFeesWithdraw, yHAFeesWithdraw)) / BASE_PARAMS;
        // Rounding the fees at the protocol's advantage
        feesPaid = committedAmount - (committedAmount * (BASE_PARAMS - feesPaid)) / BASE_PARAMS;
        if (feesPaid >= cashOutAmount) {
            netCashOutAmount = 0;
            feesPaid = cashOutAmount;
        } else {
            netCashOutAmount = cashOutAmount - feesPaid;
        }
    }

    // ========================= Reward Distribution ===============================

    
    
    function _lastTimeRewardApplicable() internal view returns (uint256) {
        uint256 returnValue = block.timestamp < periodFinish ? block.timestamp : periodFinish;
        return returnValue;
    }

    
    
    /// was last updated multiplied by the `rewardRate` divided by the number of tokens
    
    /// and `totalHedgeAmount` is in `BASE_TOKENS` here: as this function concerns an amount of reward
    /// tokens, the output of this function should be in the base of the reward token too
    function _rewardPerToken() internal view returns (uint256) {
        if (totalHedgeAmount == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            ((_lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * BASE_TOKENS) /
            totalHedgeAmount;
    }

    
    
    
    
    
    /// to the owner of the perpetual, and not necessarily to the address getting the proceeds of the perpetual
    function _getReward(uint256 perpetualID, uint256 hedge) internal {
        _updateReward(perpetualID, hedge);
        uint256 reward = rewards[perpetualID];
        if (reward > 0) {
            rewards[perpetualID] = 0;
            address owner = _owners[perpetualID];
            // Attention here, there may be reentrancy attacks because of the following call
            // to an external contract done before other things are modified. Yet since the `rewardToken`
            // is mostly going to be a trusted contract controlled by governance (namely the ANGLE token), then
            // there is no point in putting an expensive `nonReentrant` modifier in the functions in `PerpetualManagerFront`
            // that allow indirect interactions with `_updateReward`. If new `rewardTokens` are set, we could think about
            // upgrading the `PerpetualManagerFront` contract
            rewardToken.safeTransfer(owner, reward);
            emit RewardPaid(owner, reward);
        }
    }

    
    
    
    
    
    /// equal to `committedAmount * entryRate / _collatBase`, here as the `hedge` corresponds to `committedAmount * entryRate`,
    /// we just need to divide by `_collatBase`
    
    function _earned(uint256 perpetualID, uint256 hedge) internal view returns (uint256) {
        return
            (hedge * (_rewardPerToken() - perpetualRewardPerTokenPaid[perpetualID])) /
            BASE_TOKENS /
            _collatBase +
            rewards[perpetualID];
    }

    
    
    
    
    /// exists
    function _updateReward(uint256 perpetualID, uint256 hedge) internal {
        rewardPerTokenStored = _rewardPerToken();
        lastUpdateTime = _lastTimeRewardApplicable();
        // No need to check if the `perpetualID` exists here, it has already been checked
        // in the code before when this internal function is called
        rewards[perpetualID] = _earned(perpetualID, hedge);
        perpetualRewardPerTokenPaid[perpetualID] = rewardPerTokenStored;
    }

    // =============================== ERC721 Logic ================================

    
    
    
    function _ownerOf(uint256 perpetualID) internal view returns (address owner) {
        owner = _owners[perpetualID];
        require(owner != address(0), "2");
    }

    
    
    
    function _getApproved(uint256 perpetualID) internal view returns (address) {
        return _perpetualApprovals[perpetualID];
    }

    
    /// are aware of the ERC721 protocol to prevent tokens from being forever locked
    
    
    
    /// implement alternative mechanisms to perform token transfer, such as signature-based
    
    ///     - `from` cannot be the zero address.
    ///     - `to` cannot be the zero address.
    ///     - `perpetualID` token must exist and be owned by `from`.
    ///     - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
    function _safeTransfer(
        address from,
        address to,
        uint256 perpetualID,
        bytes memory _data
    ) internal {
        _transfer(from, to, perpetualID);
        require(_checkOnERC721Received(from, to, perpetualID, _data), "24");
    }

    
    
    
    /// and stop existing when they are burned (`_burn`)
    function _exists(uint256 perpetualID) internal view returns (bool) {
        return _owners[perpetualID] != address(0);
    }

    
    
    function _isApprovedOrOwner(address spender, uint256 perpetualID) internal view returns (bool) {
        // The following checks if the perpetual exists
        address owner = _ownerOf(perpetualID);
        return (spender == owner || _getApproved(perpetualID) == spender || _operatorApprovals[owner][spender]);
    }

    
    
    
    
    /// comes from a counter that has been incremented
    
    function _mint(address to, uint256 perpetualID) internal {
        _balances[to] += 1;
        _owners[perpetualID] = to;
        emit Transfer(address(0), to, perpetualID);
        require(_checkOnERC721Received(address(0), to, perpetualID, ""), "24");
    }

    
    
    
    function _burn(uint256 perpetualID) internal {
        address owner = _ownerOf(perpetualID);

        // Clear approvals
        _approve(address(0), perpetualID);

        _balances[owner] -= 1;
        delete _owners[perpetualID];
        delete perpetualData[perpetualID];

        emit Transfer(owner, address(0), perpetualID);
    }

    
    /// this imposes no restrictions on msg.sender
    
    
    function _transfer(
        address from,
        address to,
        uint256 perpetualID
    ) internal {
        require(_ownerOf(perpetualID) == from, "1");
        require(to != address(0), "26");

        // Clear approvals from the previous owner
        _approve(address(0), perpetualID);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[perpetualID] = to;

        emit Transfer(from, to, perpetualID);
    }

    
    function _approve(address to, uint256 perpetualID) internal {
        _perpetualApprovals[perpetualID] = to;
        emit Approval(_ownerOf(perpetualID), to, perpetualID);
    }

    
    /// The call is not executed if the target address is not a contract
    
    
    
    
    
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 perpetualID,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(msg.sender, from, perpetualID, _data) returns (
                bytes4 retval
            ) {
                return retval == IERC721ReceiverUpgradeable(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("24");
                } else {
                    // solhint-disable-next-line no-inline-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}


// File contracts/perpetualManager/PerpetualManager.sol



pragma solidity ^0.8.7;






/// by `StableMaster`, by the `PoolManager`, by the `FeeManager` and by governance
contract PerpetualManager is
    PerpetualManagerInternal,
    IPerpetualManagerFunctions,
    IStakingRewardsFunctions,
    AccessControlUpgradeable,
    PausableUpgradeable
{
    using SafeERC20 for IERC20;

    
    /// Made for the `StableMaster` to be able to update some parameters
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");
    
    bytes32 public constant POOLMANAGER_ROLE = keccak256("POOLMANAGER_ROLE");

    // ============================== Modifiers ====================================

    
    
    
    
    /// they are able to interact with
    modifier onlyApprovedOrOwner(address caller, uint256 perpetualID) {
        require(_isApprovedOrOwner(caller, perpetualID), "21");
        _;
    }

    
    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "1");
        _;
    }

    // =============================== Deployer ====================================

    
    /// to this contract and grants the correct roles
    
    
    
    
    
    
    function deployCollateral(
        address[] memory governorList,
        address guardian,
        IFeeManager feeManager_,
        IOracle oracle_
    ) external override onlyRole(POOLMANAGER_ROLE) {
        for (uint256 i = 0; i < governorList.length; i++) {
            _grantRole(GUARDIAN_ROLE, governorList[i]);
        }
        // In the end guardian should be revoked by governance
        _grantRole(GUARDIAN_ROLE, guardian);
        _grantRole(GUARDIAN_ROLE, address(_stableMaster));
        _feeManager = feeManager_;
        oracle = oracle_;
    }

    // ========================== Rewards Distribution =============================

    
    
    
    
    function notifyRewardAmount(uint256 reward) external override onlyRewardsDistribution {
        rewardPerTokenStored = _rewardPerToken();

        if (block.timestamp >= periodFinish) {
            // If the period is not done, then the reward rate changes
            rewardRate = reward / rewardsDuration;
        } else {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            // If the period is not over, we compute the reward left and increase reward duration
            rewardRate = (reward + leftover) / rewardsDuration;
        }
        // Ensuring the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of `rewardRate` in the earned and `rewardsPerToken` functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = rewardToken.balanceOf(address(this));

        require(rewardRate <= balance / rewardsDuration, "22");

        lastUpdateTime = block.timestamp;
        // Change the duration
        periodFinish = block.timestamp + rewardsDuration;
        emit RewardAdded(reward);
    }

    
    /// or tokens that were mistakenly
    
    
    
    function recoverERC20(
        address tokenAddress,
        address to,
        uint256 tokenAmount
    ) external override onlyRewardsDistribution {
        require(tokenAddress != address(rewardToken), "20");
        IERC20(tokenAddress).safeTransfer(to, tokenAmount);
        emit Recovered(tokenAddress, to, tokenAmount);
    }

    
    
    
    /// a change of rewards distributor notified by the current `rewardsDistribution` address
    
    /// this function that the `newRewardsDistributor` had a compatible reward token
    
    function setNewRewardsDistribution(address _rewardsDistribution) external override onlyRewardsDistribution {
        rewardsDistribution = _rewardsDistribution;
        emit RewardsDistributionUpdated(_rewardsDistribution);
    }

    // ================================= Keepers ===================================

    
    
    
    
    /// in this case it will be done through the `FeeManager` contract
    
    function setFeeKeeper(uint64 feeDeposit, uint64 feeWithdraw) external override {
        require(msg.sender == address(_feeManager), "1");
        haBonusMalusDeposit = feeDeposit;
        haBonusMalusWithdraw = feeWithdraw;
    }

    // ======== Governance - Guardian Functions - Staking and Pauses ===============

    
    
    /// or claim their rewards on it
    function pause() external override onlyRole(GUARDIAN_ROLE) {
        _pause();
    }

    
    function unpause() external override onlyRole(GUARDIAN_ROLE) {
        _unpause();
    }

    
    
    
    
    /// at which this distribution is done
    
    /// in the rewards distribution contract when activating this as a staking contract,
    /// so if a reward distributor is set here but does not have a compatible reward token, then this reward
    /// distributor will not be able to set this contract as a staking contract
    function setRewardDistribution(uint256 _rewardsDuration, address _rewardsDistribution)
        external
        onlyRole(GUARDIAN_ROLE)
        zeroCheck(_rewardsDistribution)
    {
        rewardsDuration = _rewardsDuration;
        rewardsDistribution = _rewardsDistribution;
        emit RewardsDistributionDurationUpdated(rewardsDuration, rewardsDistribution);
    }

    // ============ Governance - Guardian Functions - Parameters ===================

    
    
    function setBaseURI(string memory _baseURI) external onlyRole(GUARDIAN_ROLE) {
        baseURI = _baseURI;
        emit BaseURIUpdated(_baseURI);
    }

    
    
    
    /// of insiders' information they may have due to oracle latency
    function setLockTime(uint64 _lockTime) external override onlyRole(GUARDIAN_ROLE) {
        lockTime = _lockTime;
        emit LockTimeUpdated(_lockTime);
    }

    
    /// perpetuals can be liquidated
    
    
    
    
    function setBoundsPerpetual(uint64 _maxLeverage, uint64 _maintenanceMargin)
        external
        override
        onlyRole(GUARDIAN_ROLE)
        onlyCompatibleFees(_maintenanceMargin)
    {
        // Checking the compatibility of the parameters
        require(BASE_PARAMS**2 > _maxLeverage * _maintenanceMargin, "8");
        maxLeverage = _maxLeverage;
        maintenanceMargin = _maintenanceMargin;
        emit BoundsPerpetualUpdated(_maxLeverage, _maintenanceMargin);
    }

    
    /// divided by what's to hedge with HAs at which fees will change as well as
    /// `yHAFees` that is the value of the deposit or withdraw fees at threshold
    
    
    
    
    
    
    /// the higher y should be (the more expensive it should be for HAs to come in)
    
    function setHAFees(
        uint64[] memory _xHAFees,
        uint64[] memory _yHAFees,
        uint8 deposit
    ) external override onlyRole(GUARDIAN_ROLE) onlyCompatibleInputArrays(_xHAFees, _yHAFees) {
        if (deposit == 1) {
            xHAFeesDeposit = _xHAFees;
            yHAFeesDeposit = _yHAFees;
        } else {
            xHAFeesWithdraw = _xHAFees;
            yHAFeesWithdraw = _yHAFees;
        }
        emit HAFeesUpdated(_xHAFees, _yHAFees, deposit);
    }

    
    
    
    /// cashed out
    
    
    function setTargetAndLimitHAHedge(uint64 _targetHAHedge, uint64 _limitHAHedge)
        external
        override
        onlyRole(GUARDIAN_ROLE)
        onlyCompatibleFees(_targetHAHedge)
        onlyCompatibleFees(_limitHAHedge)
    {
        require(_targetHAHedge <= _limitHAHedge, "8");
        limitHAHedge = _limitHAHedge;
        targetHAHedge = _targetHAHedge;
        // Updating the value in the `stableMaster` contract
        _stableMaster.setTargetHAHedge(_targetHAHedge);
        emit TargetAndLimitHAHedgeUpdated(_targetHAHedge, _limitHAHedge);
    }

    
    
    
    function setKeeperFeesLiquidationRatio(uint64 _keeperFeesLiquidationRatio)
        external
        override
        onlyRole(GUARDIAN_ROLE)
        onlyCompatibleFees(_keeperFeesLiquidationRatio)
    {
        keeperFeesLiquidationRatio = _keeperFeesLiquidationRatio;
        emit KeeperFeesLiquidationRatioUpdated(keeperFeesLiquidationRatio);
    }

    
    /// because too much was hedged by HAs or when liquidating a perpetual
    
    
    /// of perpetuals
    function setKeeperFeesCap(uint256 _keeperFeesLiquidationCap, uint256 _keeperFeesClosingCap)
        external
        override
        onlyRole(GUARDIAN_ROLE)
    {
        keeperFeesLiquidationCap = _keeperFeesLiquidationCap;
        keeperFeesClosingCap = _keeperFeesClosingCap;
        emit KeeperFeesCapUpdated(keeperFeesLiquidationCap, keeperFeesClosingCap);
    }

    
    /// value of the proportions of the fees going to keepers closing perpetuals
    
    
    
    
    function setKeeperFeesClosing(uint64[] memory _xKeeperFeesClosing, uint64[] memory _yKeeperFeesClosing)
        external
        override
        onlyRole(GUARDIAN_ROLE)
        onlyCompatibleInputArrays(_xKeeperFeesClosing, _yKeeperFeesClosing)
    {
        xKeeperFeesClosing = _xKeeperFeesClosing;
        yKeeperFeesClosing = _yKeeperFeesClosing;
        emit KeeperFeesClosingUpdated(xKeeperFeesClosing, yKeeperFeesClosing);
    }

    // ================ Governance - `PoolManager` Functions =======================

    
    
    
    
    /// a `FEEMANAGER_ROLE` for which `PoolManager` was the admin
    function setFeeManager(IFeeManager feeManager_) external override onlyRole(POOLMANAGER_ROLE) {
        _feeManager = feeManager_;
    }

    // ======================= `StableMaster` Function =============================

    
    
    
    /// is hence directly set by the `StableMaster`
    function setOracle(IOracle oracle_) external override {
        require(msg.sender == address(_stableMaster), "1");
        oracle = oracle_;
    }
}


// File contracts/perpetualManager/PerpetualManagerFront.sol



pragma solidity ^0.8.7;






/// with by external agents. These functions are the ones that need to be called to open, modify or close
/// perpetuals

/// https://github.com/SetProtocol/index-coop-contracts/blob/master/contracts/staking/StakingRewardsV2.sol

contract PerpetualManagerFront is PerpetualManager, IPerpetualManagerFront {
    using SafeERC20 for IERC20;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    // =============================== Deployer ====================================

    
    
    
    
    
    
    /// the `rewardToken_` is checked
    
    /// the setters in this contract
    function initialize(IPoolManager poolManager_, IERC20 rewardToken_)
        external
        initializer
        zeroCheck(address(rewardToken_))
    {
        // Initializing contracts
        __Pausable_init();
        __AccessControl_init();

        // Creating references
        poolManager = poolManager_;
        _token = IERC20(poolManager_.token());
        _stableMaster = IStableMaster(poolManager_.stableMaster());
        rewardToken = rewardToken_;
        _collatBase = 10**(IERC20Metadata(address(_token)).decimals());
        // The references to the `feeManager` and to the `oracle` contracts are to be set when the contract is deployed

        // Setting up Access Control for this contract
        // There is no need to store the reference to the `PoolManager` address here
        // Once the `POOLMANAGER_ROLE` has been granted, no new addresses can be granted or revoked
        // from this role: a `PerpetualManager` contract can only have one `PoolManager` associated
        _setupRole(POOLMANAGER_ROLE, address(poolManager));
        // `PoolManager` is admin of all the roles. Most of the time, changes are propagated from it
        _setRoleAdmin(GUARDIAN_ROLE, POOLMANAGER_ROLE);
        _setRoleAdmin(POOLMANAGER_ROLE, POOLMANAGER_ROLE);
        // Pausing the contract because it is not functional till the collateral has really been deployed by the
        // `StableMaster`
        _pause();
    }

    
    constructor() initializer {}

    // ================================= HAs =======================================

    
    
    
    
    
    
    
    
    
    
    
    function openPerpetual(
        address owner,
        uint256 margin,
        uint256 committedAmount,
        uint256 maxOracleRate,
        uint256 minNetMargin
    ) external override whenNotPaused zeroCheck(owner) returns (uint256 perpetualID) {
        // Transaction will revert anyway if `margin` is zero
        require(committedAmount > 0, "27");

        // There could be a reentrancy attack as a call to an external contract is done before state variables
        // updates. Yet in this case, the call involves a transfer from the `msg.sender` to the contract which
        // eliminates the risk
        _token.safeTransferFrom(msg.sender, address(poolManager), margin);

        // Computing the oracle value
        // Only the highest oracle value (between Chainlink and Uniswap) we get is stored in the perpetual
        (, uint256 rateUp) = _getOraclePrice();
        // Checking if the oracle rate is not too big: a too big oracle rate could mean for a HA that the price
        // has become too high to make it interesting to open a perpetual
        require(rateUp <= maxOracleRate, "28");

        // Computing the total amount of stablecoins that this perpetual is going to hedge for the protocol
        uint256 totalHedgeAmountUpdate = (committedAmount * rateUp) / _collatBase;
        // Computing the net amount brought by the HAs to store in the perpetual
        uint256 netMargin = _getNetMargin(margin, totalHedgeAmountUpdate, committedAmount);
        require(netMargin >= minNetMargin, "29");
        // Checking if the perpetual is not too leveraged, even after computing the fees
        require((committedAmount * BASE_PARAMS) <= maxLeverage * netMargin, "30");

        // ERC721 logic
        _perpetualIDcount.increment();
        perpetualID = _perpetualIDcount.current();

        // In the logic of the staking contract, the `_updateReward` should be called
        // before the perpetual is opened
        _updateReward(perpetualID, 0);

        // Updating the total amount of stablecoins hedged by HAs and creating the perpetual
        totalHedgeAmount += totalHedgeAmountUpdate;

        perpetualData[perpetualID] = Perpetual(rateUp, block.timestamp, netMargin, committedAmount);

        // Following ERC721 logic, the function `_mint(...)` calls `_checkOnERC721Received` and could then be used as
        // a reentrancy vector. Minting should then only be done at the very end after updating all variables.
        _mint(owner, perpetualID);
        emit PerpetualOpened(perpetualID, rateUp, netMargin, committedAmount);
    }

    
    /// to this `PerpetualManager` contract
    
    
    
    /// perpetual
    
    /// and current oracle value minus some transaction fees computed on the committed amount
    
    
    /// receive sanTokens
    
    /// from fees that would have become too high and from a too big decrease in oracle value
    function closePerpetual(
        uint256 perpetualID,
        address to,
        uint256 minCashOutAmount
    ) external override whenNotPaused onlyApprovedOrOwner(msg.sender, perpetualID) {
        // Loading perpetual data and getting the oracle price
        Perpetual memory perpetual = perpetualData[perpetualID];
        (uint256 rateDown, ) = _getOraclePrice();
        // The lowest oracle price between Chainlink and Uniswap is used to compute the perpetual's position at
        // the time of closing: it is the one that is most at the advantage of the protocol
        (uint256 cashOutAmount, uint256 liquidated) = _checkLiquidation(perpetualID, perpetual, rateDown);
        if (liquidated == 0) {
            // You need to wait `lockTime` before being able to withdraw funds from the protocol as a HA
            require(perpetual.entryTimestamp + lockTime <= block.timestamp, "31");
            // Cashing out the perpetual internally
            _closePerpetual(perpetualID, perpetual);
            // Computing exit fees: they depend on how much is already hedgeded by HAs compared with what's to hedge
            (uint256 netCashOutAmount, ) = _getNetCashOutAmount(
                cashOutAmount,
                perpetual.committedAmount,
                // The perpetual has already been cashed out when calling this function, so there is no
                // `committedAmount` to add to the `totalHedgeAmount` to get the `currentHedgeAmount`
                _computeHedgeRatio(totalHedgeAmount)
            );
            require(netCashOutAmount >= minCashOutAmount, "32");
            emit PerpetualClosed(perpetualID, netCashOutAmount);
            _secureTransfer(to, netCashOutAmount);
        }
    }

    
    /// stablecoin/collateral pair
    
    
    
    
    
    /// it to the owner of the perpetual
    
    function addToPerpetual(uint256 perpetualID, uint256 amount) external override whenNotPaused {
        // Loading perpetual data and getting the oracle price
        Perpetual memory perpetual = perpetualData[perpetualID];
        (uint256 rateDown, ) = _getOraclePrice();
        (, uint256 liquidated) = _checkLiquidation(perpetualID, perpetual, rateDown);
        if (liquidated == 0) {
            // Overflow check
            _token.safeTransferFrom(msg.sender, address(poolManager), amount);
            perpetualData[perpetualID].margin += amount;
            emit PerpetualUpdated(perpetualID, perpetual.margin + amount);
        }
    }

    
    /// stablecoin/collateral pair
    
    
    
    
    
    function removeFromPerpetual(
        uint256 perpetualID,
        uint256 amount,
        address to
    ) external override whenNotPaused onlyApprovedOrOwner(msg.sender, perpetualID) {
        // Loading perpetual data and getting the oracle price
        Perpetual memory perpetual = perpetualData[perpetualID];
        (uint256 rateDown, ) = _getOraclePrice();

        (uint256 cashOutAmount, uint256 liquidated) = _checkLiquidation(perpetualID, perpetual, rateDown);
        if (liquidated == 0) {
            // Checking if money can be withdrawn from the perpetual
            require(
                // The perpetual should not have been opened too soon
                (perpetual.entryTimestamp + lockTime <= block.timestamp) &&
                    // The amount to withdraw should not be more important than the perpetual's `cashOutAmount` and `margin`
                    (amount < cashOutAmount) &&
                    (amount < perpetual.margin) &&
                    // Withdrawing collateral should not make the leverage of the perpetual too important
                    // Checking both on `cashOutAmount` and `perpetual.margin` (as we can have either
                    // `cashOutAmount >= perpetual.margin` or `cashOutAmount<perpetual.margin`)
                    // No checks are done on `maintenanceMargin`, as conditions on `maxLeverage` are more restrictive
                    perpetual.committedAmount * BASE_PARAMS <= (cashOutAmount - amount) * maxLeverage &&
                    perpetual.committedAmount * BASE_PARAMS <= (perpetual.margin - amount) * maxLeverage,
                "33"
            );
            perpetualData[perpetualID].margin -= amount;
            emit PerpetualUpdated(perpetualID, perpetual.margin - amount);

            _secureTransfer(to, amount);
        }
    }

    
    /// under the maintenance margin
    
    
    /// and nothing will happen if the perpetual is still healthy
    
    
    /// we may have to put an access control logic for this function to only allow white-listed addresses to act
    /// as keepers for the protocol
    function liquidatePerpetuals(uint256[] memory perpetualIDs) external override whenNotPaused {
        // Getting the oracle price
        (uint256 rateDown, ) = _getOraclePrice();
        uint256 liquidationFees;
        for (uint256 i = 0; i < perpetualIDs.length; i++) {
            uint256 perpetualID = perpetualIDs[i];
            if (_exists(perpetualID)) {
                // Loading perpetual data
                Perpetual memory perpetual = perpetualData[perpetualID];
                (uint256 cashOutAmount, uint256 liquidated) = _checkLiquidation(perpetualID, perpetual, rateDown);
                if (liquidated == 1) {
                    // Computing the incentive for the keeper as a function of the `cashOutAmount` of the perpetual
                    // This incentivizes keepers to react fast when the price starts to go below the liquidation
                    // margin
                    liquidationFees += _computeKeeperLiquidationFees(cashOutAmount);
                }
            }
        }
        emit KeeperTransferred(msg.sender, liquidationFees);
        _secureTransfer(msg.sender, liquidationFees);
    }

    
    /// users is hedged by HAs
    
    
    
    
    
    /// we may have to put an access control logic for this function to only allow white-listed addresses to act
    /// as keepers for the protocol
    function forceClosePerpetuals(uint256[] memory perpetualIDs) external override whenNotPaused {
        // Getting the oracle prices
        // `rateUp` is used to compute the cost of manipulation of the covered amounts
        (uint256 rateDown, uint256 rateUp) = _getOraclePrice();

        // Fetching `stocksUsers` to check if perpetuals cover too much collateral
        uint256 stocksUsers = _stableMaster.getStocksUsers();
        uint256 targetHedgeAmount = (stocksUsers * targetHAHedge) / BASE_PARAMS;

        // `totalHedgeAmount` should be greater than the limit hedge amount
        require(totalHedgeAmount > (stocksUsers * limitHAHedge) / BASE_PARAMS, "34");
        uint256 liquidationFees;
        uint256 cashOutFees;

        // Array of pairs `(owner, netCashOutAmount)`
        Pairs[] memory outputPairs = new Pairs[](perpetualIDs.length);

        for (uint256 i = 0; i < perpetualIDs.length; i++) {
            uint256 perpetualID = perpetualIDs[i];
            address owner = _owners[perpetualID];
            if (owner != address(0)) {
                // Loading perpetual data and getting the oracle price
                Perpetual memory perpetual = perpetualData[perpetualID];
                // First checking if the perpetual should not be liquidated
                (uint256 cashOutAmount, uint256 liquidated) = _checkLiquidation(perpetualID, perpetual, rateDown);
                if (liquidated == 1) {
                    // This results in the perpetual being liquidated and the keeper being paid the same amount of fees as
                    // what would have been paid if the perpetual had been liquidated using the `liquidatePerpetualFunction`
                    // Computing the incentive for the keeper as a function of the `cashOutAmount` of the perpetual
                    // This incentivizes keepers to react fast
                    liquidationFees += _computeKeeperLiquidationFees(cashOutAmount);
                } else if (perpetual.entryTimestamp + lockTime <= block.timestamp) {
                    // It is impossible to force the closing a perpetual that was just created: in the other case, this
                    // function could be used to do some insider trading and to bypass the `lockTime` limit
                    // If too much collateral is hedged by HAs, then the perpetual can be cashed out
                    _closePerpetual(perpetualID, perpetual);
                    uint64 ratioPostCashOut;
                    // In this situation, `totalHedgeAmount` is the `currentHedgeAmount`
                    if (targetHedgeAmount > totalHedgeAmount) {
                        ratioPostCashOut = uint64((totalHedgeAmount * BASE_PARAMS) / targetHedgeAmount);
                    } else {
                        ratioPostCashOut = uint64(BASE_PARAMS);
                    }
                    // Computing how much the HA will get and the amount of fees paid at closing
                    (uint256 netCashOutAmount, uint256 fees) = _getNetCashOutAmount(
                        cashOutAmount,
                        perpetual.committedAmount,
                        ratioPostCashOut
                    );
                    cashOutFees += fees;
                    // Storing the owners of perpetuals that were forced cash out in a memory array to avoid
                    // reentrancy attacks
                    outputPairs[i] = Pairs(owner, netCashOutAmount);
                }

                // Checking if at this point enough perpetuals have been cashed out
                if (totalHedgeAmount <= targetHedgeAmount) break;
            }
        }

        uint64 ratio = (targetHedgeAmount == 0)
            ? 0
            : uint64((totalHedgeAmount * BASE_PARAMS) / (2 * targetHedgeAmount));
        // Computing the rewards given to the keeper calling this function
        // and transferring the rewards to the keeper
        // Using a cache value of `cashOutFees` to save some gas
        // The value below is the amount of fees that should go to the keeper forcing the closing of perpetuals
        // In the linear by part function, if `xKeeperFeesClosing` is greater than 0.5 (meaning we are not at target yet)
        // then keepers should get almost no fees
        cashOutFees = (cashOutFees * _piecewiseLinear(ratio, xKeeperFeesClosing, yKeeperFeesClosing)) / BASE_PARAMS;
        // The amount of fees that can go to keepers is capped by a parameter set by governance
        cashOutFees = cashOutFees < keeperFeesClosingCap ? cashOutFees : keeperFeesClosingCap;
        // A malicious attacker could take advantage of this function to take a flash loan, burn agTokens
        // to diminish the stocks users and then force close some perpetuals. We also need to check that assuming
        // really small burn transaction fees (of 0.05%), an attacker could make a profit with such flash loan
        // if current hedge is below the target hedge by making such flash loan.
        // The formula for the cost of such flash loan is:
        // `fees * (limitHAHedge - targetHAHedge) * stocksUsers / oracle`
        // In order to avoid doing multiplications after divisions, and to get everything in the correct base, we do:
        uint256 estimatedCost = (5 * (limitHAHedge - targetHAHedge) * stocksUsers * _collatBase) /
            (rateUp * 10000 * BASE_PARAMS);
        cashOutFees = cashOutFees < estimatedCost ? cashOutFees : estimatedCost;

        emit PerpetualsForceClosed(perpetualIDs, outputPairs, msg.sender, cashOutFees + liquidationFees);

        // Processing transfers after all calculations have been performed
        for (uint256 j = 0; j < perpetualIDs.length; j++) {
            if (outputPairs[j].netCashOutAmount > 0) {
                _secureTransfer(outputPairs[j].owner, outputPairs[j].netCashOutAmount);
            }
        }
        _secureTransfer(msg.sender, cashOutFees + liquidationFees);
    }

    // =========================== External View Function ==========================

    
    
    
    
    
    /// be liquidated
    
    function getCashOutAmount(uint256 perpetualID, uint256 rate) external view override returns (uint256, uint256) {
        Perpetual memory perpetual = perpetualData[perpetualID];
        return _getCashOutAmount(perpetual, rate);
    }

    // =========================== Reward Distribution =============================

    
    
    function earned(uint256 perpetualID) external view returns (uint256) {
        return _earned(perpetualID, perpetualData[perpetualID].committedAmount * perpetualData[perpetualID].entryRate);
    }

    
    
    
    function getReward(uint256 perpetualID) external whenNotPaused onlyApprovedOrOwner(msg.sender, perpetualID) {
        _getReward(perpetualID, perpetualData[perpetualID].committedAmount * perpetualData[perpetualID].entryRate);
    }

    // =============================== ERC721 logic ================================

    
    function name() external pure override returns (string memory) {
        return "AnglePerp";
    }

    
    function symbol() external pure override returns (string memory) {
        return "AnglePerp";
    }

    
    
    function tokenURI(uint256 perpetualID) external view override returns (string memory) {
        require(_exists(perpetualID), "2");
        // There is no perpetual with `perpetualID` equal to 0, so the following variable is
        // always greater than zero
        uint256 temp = perpetualID;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (perpetualID != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(perpetualID % 10)));
            perpetualID /= 10;
        }
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, string(buffer))) : "";
    }

    
    
    
    function balanceOf(address owner) external view override returns (uint256) {
        require(owner != address(0), "0");
        return _balances[owner];
    }

    
    
    function ownerOf(uint256 perpetualID) external view override returns (address) {
        return _ownerOf(perpetualID);
    }

    
    
    
    
    /// on behalf of the owner, to add or remove collateral in it and to choose the destination
    /// address that will be able to receive the proceeds of the perpetual
    function approve(address to, uint256 perpetualID) external override {
        address owner = _ownerOf(perpetualID);
        require(to != owner, "35");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "21");

        _approve(to, perpetualID);
    }

    
    
    function getApproved(uint256 perpetualID) external view override returns (address) {
        require(_exists(perpetualID), "2");
        return _getApproved(perpetualID);
    }

    
    
    
    function setApprovalForAll(address operator, bool approved) external override {
        require(operator != msg.sender, "36");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    
    
    
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    
    
    function isApprovedOrOwner(address spender, uint256 perpetualID) external view override returns (bool) {
        return _isApprovedOrOwner(spender, perpetualID);
    }

    
    
    
    
    function transferFrom(
        address from,
        address to,
        uint256 perpetualID
    ) external override onlyApprovedOrOwner(msg.sender, perpetualID) {
        _transfer(from, to, perpetualID);
    }

    
    
    
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 perpetualID
    ) external override {
        safeTransferFrom(from, to, perpetualID, "");
    }

    
    
    
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 perpetualID,
        bytes memory _data
    ) public override onlyApprovedOrOwner(msg.sender, perpetualID) {
        _safeTransfer(from, to, perpetualID, _data);
    }

    // =============================== ERC165 logic ================================

    
    
    
    /// Required by the ERC721 standard, so used to check that the IERC721 is implemented.
    
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceId) external pure override(IERC165) returns (bool) {
        return
            interfaceId == type(IPerpetualManagerFront).interfaceId ||
            interfaceId == type(IPerpetualManagerFunctions).interfaceId ||
            interfaceId == type(IStakingRewards).interfaceId ||
            interfaceId == type(IStakingRewardsFunctions).interfaceId ||
            interfaceId == type(IAccessControl).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}